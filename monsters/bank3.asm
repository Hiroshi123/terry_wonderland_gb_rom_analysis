; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 3  (MONSTER SPECIES DATABASE + link cable handler)
; ============================================================================
;
; *** THIS BANK HOLDS THE MONSTER SPECIES DATABASE ***  (the long-open
; question). Embedded between the link-cable routines is a table of 221
; monster species records, 43 ($2B) bytes each, at $4461-$697F, indexed by
; species id. It is the per-species template (family, base stats,
; resistances, rank) used to instantiate any monster — see the
; "MONSTER SPECIES DATABASE" section below.
;
; Called from: state machine and game logic for 2-player link cable exchange.
;   bank3/fn0 is the per-frame link cable protocol driver.
;   bank22/fn0 calls bank3/fn1 (LD HL,$0301; RST $10) after monster init —
;     fn1 loads the species record for id $DA31 into $DA33 (43 bytes).
;
; Bank 3 memory map:
;   File offset $0C000-$0FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 3
;   $4001-$4012  function table (fn0..fn8)
;   $4013-$4460  fn0/fn1 code + link handshake
;   $4461-$697F  MONSTER SPECIES DATABASE (221 × 43 bytes)   <== the data
;   $6980+       fn2..fn8 code (link/trade sequencers)
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; SYSTEM: LINK CABLE SERIAL PROTOCOL  (2-player battle & monster trade)
;   GBC serial I/O: $FF01 (SB data), $FF02 (SC control).
;   fn0 negotiates the connection, decides which console is player 1 vs
;   player 2, then hands off per-frame control to the appropriate mode:
;     • link BATTLE   → bank80 fn2  (the battle scene sequencer)
;     • link menu/lobby→ bank21 fn2 / fn3
;   The monster-exchange sequencing itself lives in fn3/fn4 (44-step
;   state machines) and the "monsters offered" list is managed by fn5–fn8.
;
;   Handshake bytes seen on SB ($FF01):
;     $F0 = sync/attention   $F1 = role-claim (become player 1)
;     $F2 = role-claim ack   $F3 = alternate role token
;   (In state 0, receiving $F2 while local phase $C8DA&$7F==2, or $F3 while
;    ==3, is what settles the master/slave roles — see $402C below.)
;
;   $C864: link cable state byte.
;     bit 7: link-blocked flag — if set, bank3/fn0 sets bit 6 and returns.
;     bit 6: link-busy flag — set when link transfer in progress.
;     (fn0 writes $C864=3 at the end of a handshake step — "committed".)
;   $C865: link sub-state (RST $00 dispatch index in fn0, 0-3)
;   $C863: role/side flags — bit0 = link established, bit1 = "player 2"
;          side (same side flag bank80/bank21 read for battle sides).
;   $C866: inner sub-state for the per-mode driver ($415E/$4193/$41C8)
;   $C86C: "linked / connected" flag (1 once a partner is present).
;
; Function table at $0C001 (bank 3 $4001) — 9 functions (fn0..fn8):
;   fn0:  $4013  ← per-frame link driver / handshake state machine (4 states)
;   fn1:  $443F  ← monster species loader: record[$DA31] → $DA33 (43 bytes)
;   fn2:  $6980  ← secondary-stat copy: record[$DA5E] → $DA62 (12 bytes)
;   fn3:  $69A2  ← trade/exchange sequencer A (44-state, keyed on $DA5E)
;   fn4:  $6E24  ← trade/exchange sequencer B (44-state; calls fn2 first)
;   fn5:  $7160  ← rebuild+compact the "offered monsters" list ($CA51,20)
;   fn6:  $7190  ← append current monster ($DA5E) to the offered list
;   fn7:  $71B6  ← remove current monster ($DA5E) from the list, recompact
;   fn8:  $7134  ← conditional removal (price/weight check) then recompact
;   (The byte after the table, $4013, is fn0's own code — there is no fn9.)
;
; Key WRAM variables:
;   $C863        wLinkRole     — bit0 established, bit1 = player-2 side
;   $C864        wLinkState    — bit 7=blocked, bit 6=busy (3 = committed)
;   $C865        wLinkSubState — fn0 RST $00 dispatch index (0-3)
;   $C866        wLinkInnerSt  — inner driver sub-state (0-1)
;   $C86C        wLinkConnected— nonzero once a partner is detected
;   $C8DA        wLinkPhase    — local negotiation phase (low 7 bits)
;   $C8A2        wLinkFlags    — bit1/bit7 transfer-progress flags
;   $DA31        wMonsterIdx   — monster list index ($DA33 table index)
;   $DA33        wMonsterData  — monster data region (43 = $2B bytes)
;   $DA5E        wTradeIdx     — current monster index (0-43; $FF = none/idle)
;   $DA5F        wTradeSlot    — slot index into $CA51 list
;   $DA62        wMonsterData2 — secondary monster data region (12 = $0C bytes)
;   $CA51        wOfferList    — 20-byte list of monster indices offered to trade
;   $C0D8        wOfferSrc     — source copy of the offer list (fn5 rebuilds from here)
;   $FF01        SB            — serial data byte (GBC hardware)
;   $FF02        SC            — serial control (GBC hardware)

SECTION "Bank3 Functions", ROMX[$4000], BANK[3]


; ============================================================================
; Bank3_Fn0  ($4013)  — Per-frame link driver / handshake state machine
; ============================================================================
; Entry guard: reads $C864.
;   If bit 7 set → SET bit6 (mark busy), RET (blocked this frame).
; Else: reads $C865 (wLinkSubState) and RST $00-dispatches to 4 states.
;
; Jump table is AT $4024 (the 4 DW entries); the handlers are:
;   state 0 → $402C   HANDSHAKE: run one serial exchange, classify the
;                     received byte, settle master/slave roles, and on
;                     success advance $C865 to 2 or 3.
;   state 1 → $414D   RUN as player-1 side: drive inner sub-machine, then
;                     bankcall bank80 fn2 (battle sequencer).
;   state 2 → $4182   RUN as player-2 side: same, but bankcall bank21 fn2.
;   state 3 → $41B7   RUN alternate mode: same, but bankcall bank21 fn3.
Bank3_Fn0:                                  ; $4013
    LD A,($C864)                           ; wLinkState
    BIT 7,A
    JR Z,$4020                             ; not blocked → proceed
    SET 6,A                                ; mark link busy
    LD ($C864),A
    RET                                    ; blocked → exit
$4020:
    LD A,($C865)                           ; wLinkSubState (0-3)
    RST $00                                ; dispatch
    ; RST $00 jump table ($4024):
    DW $402C                               ;   state 0 → handshake
    DW $414D                               ;   state 1 → run (bank80 battle)
    DW $4182                               ;   state 2 → run (bank21 fn2)
    DW $41B7                               ;   state 3 → run (bank21 fn3)

; ---- state 0 ($402C): HANDSHAKE ------------------------------------------
; Runs one serial byte exchange (ROM0 $15F3 fires SC, then SB holds the
; byte from the partner), reads it into B, and classifies:
;   $F0 or $F1  → $4071  (partner is claiming/acking a role → role logic)
;   $F2         → if local phase $C8DA&$7F == 2 → accept ($405E) else reject
;   $F3         → if local phase $C8DA&$7F == 3 → accept ($405E) else reject
;   anything else → $4056: write $C8DF=$FF (abort), fall to commit ($4142)
; On accept ($405E): set $C863 bit0 (link established), clear bit1, then
;   B==$F2 → $4107   (become player-2 side, $C865:=3)
;   else   → $40C8   (become player-1 side, $C865:=2)
; Both commit paths ($40C8/$4107): play SFX $59, clear $C841, set connected
;   flag $C86C=1, DI; ROM0 $2581; EI, (player-1 also bankcalls bank1 fn9),
;   seed the $C88A handshake block, bump $C88E, set $C865, clear
;   $C866/$C867/$C86D, then fall through to $4142.
; $4142 (commit tail): $C864=3 ("committed"), SFX $F8 (ROM0 $1648), RET.
$402C:
    CALL $15F3                             ; ROM0 serial tick (exchange 1 byte)
    LDH A,($01)                            ; A = (SB) received byte
    LD B,A                                 ; keep it in B
    CP $F0
    JR Z,$4071                             ; $F0 → role logic
    CP $F1
    JR Z,$4071                             ; $F1 → role logic
    CP $F2
    ; (full body of state 0 and the shared commit tail continues in the
    ;  raw disassembly $403E-$414C; the flow is summarized above.)

; ---- states 1/2/3 ($414D / $4182 / $41B7): RUN ---------------------------
; All three share the same shape:
;   if $C86C (connected) and $C863 bit0 (established): call the inner
;   driver, which RST $00-dispatches on $C866 (0/1):
;     sub 0 → $42D5  (wait / prepare the frame)
;     sub 1 → $4387  (perform the transfer step), then check $C8A2 bit7,
;             call $441B (post-step fixup) and bankcall the mode handler:
;               state 1 → bank80 fn2   ($5002)
;               state 2 → bank21 fn2   ($1502)
;               state 3 → bank21 fn3   ($1503)
;             finally clear $C8A2 bit1.
; So once the handshake settles, fn0 is just a thin per-frame pump that
; forwards to the battle/menu engine in the partner-appropriate bank.


; ============================================================================
; Bank3_Fn1  ($443F)  — Monster species-data loader  (reads the DATABASE)
; ============================================================================
; Loads the species record for id $DA31 out of the MONSTER SPECIES DATABASE
; (this bank, $4461) into the 43-byte buffer at $DA33.
; Called by bank22/fn0 when instantiating a monster (and during link trade).
;
; Sub_4446: src = $4461 + $DA31 × $2B  (base $4461, stride 43); copies 43
;   bytes to DE ($DA33). $218D just computes index × stride (HL); the base
;   $4461 is added right after (ADD A,$61 / ADC A,$44) — NOTE this is the
;   real ROM address of the database, not an offset.
Bank3_Fn1:                                  ; $443F
    LD DE,$DA33                            ; destination: species-record buffer
    CALL $4446                             ; Sub_4446: indexed data copy
    RET

Bank3_Sub_4446:                             ; $4446
    PUSH DE
    LD A,($DA31)                           ; species id (index into the database)
    LD C,$2B                               ; record stride = 43 bytes
    CALL $218D                             ; ROM0: HL = id × 43
    LD A,L
    ADD A,$61                              ; \ HL += $4461  (database base address)
    LD L,A                                 ; |
    LD A,H                                 ; |
    ADC A,$44                              ; /  (was mis-read as +$61/ADC $00)
    LD H,A                                 ; HL = &MonsterDB[id]
    POP DE
    LD B,$2B                               ; copy 43 bytes → $DA33
$4458:
    LD A,(HL+)
    LD (DE),A                              ; copy byte
    INC DE
    DEC B
    JR NZ,$4458
    RET

; ============================================================================
; MONSTER SPECIES DATABASE  ($4461-$697F)  — 221 records × $2B (43) bytes
; ============================================================================
; The per-species template for every monster. record[id] = $4461 + id*$2B.
; bank3/fn1 copies one record into $DA33 by species id; the monster-creation
; code (bank22) and breeding/level-up then derive an instance's stats from it.
; (Records are grouped by family: byte+0 rises 0→9 down the table.)
;
; Record format (43 bytes; verified across records 0,1,2,50,100,150,200):
;   +$00  FAMILY id (0=Slime … 9), monsters are ordered by family
;   +$01  MAX LEVEL [CONFIRMED] (level cap; only clean values used:
;         20,25,30,35,40,45,50,60,70,80)
;   +$02  EXPERIENCE TYPE [CONFIRMED] (0-31; selects the monster's XP/level
;         growth curve — which experience table it uses)
;   +$03  GENDER-PROBABILITY type [CONFIRMED] (0-3; mostly 2 = 50/50)
;   +$04  FLIGHT type [CONFIRMED] (0=grounded / 1=flying; 48 flyers in DB)
;   +$05  METAL type [CONFIRMED] (0=normal / 1=metal; only 3 metal monsters
;         in the whole DB — the metal-slime rarity)
;   +$06-$08  THREE native SKILL/SPELL ids the species can learn [CONFIRMED].
;             Each byte is a spell id → index into the SPELL DATABASE in
;             bank84 ($54) to get that skill's damage/heal/MP (bank84 record
;             = $41CF + id*$13). All 663 values across the DB are < 222 (the
;             bank84 spell count), i.e. every one is a valid spell id.
;             0 = empty/no-skill slot. (So: this bank = which skills; bank84
;             = what those skills DO.)
;   +$09-$0E  SIX base stats: HP, MP, ATTACK, DEFENSE, AGILITY, WISDOM
;             (higher for stronger species)
;
;   +$0F-$28  RESISTANCES — 26 values, each a 0-3 LEVEL (0=weak … 3=immune).
;     This whole block is resistance data (confirmed). It splits as:
;   +$0F-$14  SPELL-ELEMENT resistances, 6 values [CONFIRMED order]:
;               +$0F Mela (メラ, fire)      +$10 Gira (ギラ, flame)
;               +$11 Io   (イオ, blast)     +$12 Bagi (バギ, wind)
;               +$13 Dain (デイン, light)   +$14 Hyad (ヒャド, ice)
;   +$15-$1E  STATUS / SPECIAL-SPELL resistances, 10 values [CONFIRMED order]:
;               +$15 Manusa  (マヌーサ, blind)   +$16 Rariho  (ラリホー, sleep)
;               +$17 Zaki    (ザキ, death)       +$18 Mahotora(マホトラ, MP drain)
;               +$19 Mahotone(マホトーン, seal)  +$1A Medapani(メダパニ, confusion)
;               +$1B Rukani  (ルカニ, def-down)  +$1C Bomie   (ボミエ, agi-down)
;               +$1D Megante (メガンテ, sacrifice)+$1E Madante (マダンテ, MP-burst)
;   +$1F-$28  BREATH / MISC resistances, 10 values [CONFIRMED order]:
;               +$1F Frame (flame breath)     +$20 Breeze (cold breath)
;               +$21 Poison                    +$22 Paralysis
;               +$23 Curse                     +$24 Skip (lose turn)
;               +$25 Dance (forced dance)      +$26 Stop-breath (breath seal)
;               +$27 Call-out (call for help)  +$28 Gigaslash
;   +$29  always $00 across all 221 records (padding / table terminator).
;   +$2A  rank / growth-class byte ($00-$07)
;
; NOTE: ALL THREE resistance blocks are now CONFIRMED (user):
;   +$0F-$14 spell elements  : Mela, Gira, Io, Bagi, Dain, Hyad
;   +$15-$1E status/special  : Manusa, Rariho, Zaki, Mahotora, Mahotone,
;                              Medapani, Rukani, Bomie, Megante, Madante
;   +$1F-$28 breath/misc     : Frame, Breeze, Poison, Paralysis, Curse,
;                              Skip, Dance, Stop-breath, Call-out, Gigaslash
; = 26 resistance levels (each 0-3) per monster. The stat-block order
; (+$09-$0E) is still best-fit. (An earlier revision wrongly read +$0F-$14
; as "growth" flags — corrected: resistances.)
;
; The database is emitted here as raw bytes (record[id] = $4461 + id*$2B);
; not re-listed in full — read live with:  species = $4461 + id*43.
; ============================================================================

; ----------------------------------------------------------------------------
; Species records $00-$3B analyzed. Record labels are HEX species ids
; (.rec00 = species $00, .rec32 = species $32 = 50 decimal, …).
; Family blocks: family 0 Slime = recs $00-$13; family 1 Dragon = $14-$2C;
; family 2 Beast starts $2D.
; Per record: fam / maxLvl expType / gender flight metal / SKILLS[3](bank84 ids) / STATS[6] /
;   SPELL-RES[6] (Mela,Gira,Io,Bagi,Dain,Hyad) / RES2[10] / RES3[10]+pad / rank
; STATS order (best-fit): HP, MP, ATK, DEF, AGI, WIS
; RES orders CONFIRMED (user); all resist values are 0-3 (0=weak..3=immune)
; ----------------------------------------------------------------------------
MonsterDB:                                  ; $4461  (record[id] = $4461 + id*$2B)
.rec00:                                     ; $4461  species $00
    DB $00                                 ; +$00 family=0 (Slime)
    DB $2D,$0D                             ; +$01 maxLvl=45, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $43,$5C,$D5                         ; +$06 SKILLS (bank84 ids): 67,92,213
    DB $10,$0A,$0D,$08,$14,$10             ; +$09 STATS HP=16 MP=10 ATK=13 DEF=8 AGI=20 WIS=16
    DB $01,$01,$01,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$02,$02,$02,$02,$02,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=3 Madante=2
    DB $02,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 Paralysis=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec01:                                     ; $448C  species $01
    DB $00                                 ; +$00 family=0 (Slime)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $52,$79,$7F                         ; +$06 SKILLS (bank84 ids): 82,121,127
    DB $11,$01,$11,$04,$11,$08             ; +$09 STATS HP=17 MP=1 ATK=17 DEF=4 AGI=17 WIS=8
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$02,$02,$02,$03,$03,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=2 Rukani=3 Bomie=3 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec02:                                     ; $44B7  species $02
    DB $00                                 ; +$00 family=0 (Slime)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $55,$58,$8A                         ; +$06 SKILLS (bank84 ids): 85,88,138
    DB $0D,$02,$0B,$0B,$18,$08             ; +$09 STATS HP=13 MP=2 ATK=11 DEF=11 AGI=24 WIS=8
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec03:                                     ; $44E2  species $03
    DB $00                                 ; +$00 family=0 (Slime)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1C,$69,$6A                         ; +$06 SKILLS (bank84 ids): 28,105,106
    DB $0D,$0B,$08,$0E,$11,$11             ; +$09 STATS HP=13 MP=11 ATK=8 DEF=14 AGI=17 WIS=17
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$02,$02,$03,$03,$02,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=3 Mahotone=3 Medapani=2 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec04:                                     ; $450D  species $04
    DB $00                                 ; +$00 family=0 (Slime)
    DB $1E,$08                             ; +$01 maxLvl=30, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$34,$52                         ; +$06 SKILLS (bank84 ids): 12,52,82
    DB $0B,$0A,$11,$14,$14,$08             ; +$09 STATS HP=11 MP=10 ATK=17 DEF=20 AGI=20 WIS=8
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$03,$02,$02,$03,$02,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=3 Zaki=2 Mahotora=2 Mahotone=3 Medapani=2 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec05:                                     ; $4538  species $05
    DB $00                                 ; +$00 family=0 (Slime)
    DB $28,$0F                             ; +$01 maxLvl=40, +$02 expType=15
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$2B,$4A                         ; +$06 SKILLS (bank84 ids): 30,43,74
    DB $0E,$01,$0F,$0E,$14,$0E             ; +$09 STATS HP=14 MP=1 ATK=15 DEF=14 AGI=20 WIS=14
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $02,$02,$03,$02,$02,$02,$02,$02,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=3 Madante=2
    DB $01,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Paralysis=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec06:                                     ; $4563  species $06
    DB $00                                 ; +$00 family=0 (Slime)
    DB $2D,$0C                             ; +$01 maxLvl=45, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $18,$67,$74                         ; +$06 SKILLS (bank84 ids): 24,103,116
    DB $11,$07,$11,$08,$0E,$0D             ; +$09 STATS HP=17 MP=7 ATK=17 DEF=8 AGI=14 WIS=13
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $03,$03,$03,$02,$02,$03,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=2 Medapani=3 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$03,$01,$01,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=1 Curse=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec07:                                     ; $458E  species $07
    DB $00                                 ; +$00 family=0 (Slime)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$1E,$3C                         ; +$06 SKILLS (bank84 ids): 0,30,60
    DB $0B,$0A,$0E,$13,$0E,$0D             ; +$09 STATS HP=11 MP=10 ATK=14 DEF=19 AGI=14 WIS=13
    DB $00,$00,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $02,$02,$03,$02,$02,$02,$02,$02,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=3 Madante=2
    DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec08:                                     ; $45B9  species $08
    DB $00                                 ; +$00 family=0 (Slime)
    DB $28,$10                             ; +$01 maxLvl=40, +$02 expType=16
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$66,$73                         ; +$06 SKILLS (bank84 ids): 3,102,115
    DB $16,$0B,$0E,$11,$0B,$0D             ; +$09 STATS HP=22 MP=11 ATK=14 DEF=17 AGI=11 WIS=13
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $00                                 ; +$2A rank=0

.rec09:                                     ; $45E4  species $09
    DB $00                                 ; +$00 family=0 (Slime)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$2B,$2E                         ; +$06 SKILLS (bank84 ids): 30,43,46
    DB $0B,$0F,$0B,$0B,$14,$12             ; +$09 STATS HP=11 MP=15 ATK=11 DEF=11 AGI=20 WIS=18
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$02,$02,$03,$03,$02,$02,$02,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=3 Mahotone=3 Medapani=2 Rukani=2 Bomie=2 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$01,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=1 Dance=2 StopBreath=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec0A:                                     ; $460F  species $0A
    DB $00                                 ; +$00 family=0 (Slime)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $41,$52,$7D                         ; +$06 SKILLS (bank84 ids): 65,82,125
    DB $19,$01,$12,$0D,$14,$0D             ; +$09 STATS HP=25 MP=1 ATK=18 DEF=13 AGI=20 WIS=13
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$03,$02,$02,$02,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $00,$00,$00,$01,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Paralysis=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec0B:                                     ; $463A  species $0B
    DB $00                                 ; +$00 family=0 (Slime)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $42,$5B,$8E                         ; +$06 SKILLS (bank84 ids): 66,91,142
    DB $0D,$0A,$0E,$17,$10,$0E             ; +$09 STATS HP=13 MP=10 ATK=14 DEF=23 AGI=16 WIS=14
    DB $00,$00,$01,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=0 Dain=0 Hyad=2
    DB $02,$02,$03,$02,$02,$02,$02,$02,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=3 Madante=2
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec0C:                                     ; $4665  species $0C
    DB $00                                 ; +$00 family=0 (Slime)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $57,$5A,$90                         ; +$06 SKILLS (bank84 ids): 87,90,144
    DB $12,$0B,$14,$0F,$0E,$0D             ; +$09 STATS HP=18 MP=11 ATK=20 DEF=15 AGI=14 WIS=13
    DB $01,$01,$00,$01,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=1 Dain=2 Hyad=1
    DB $02,$02,$03,$02,$02,$03,$02,$02,$03,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=2
    DB $01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec0D:                                     ; $4690  species $0D
    DB $00                                 ; +$00 family=0 (Slime)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $77,$7B,$7E                         ; +$06 SKILLS (bank84 ids): 119,123,126
    DB $0F,$07,$0E,$08,$15,$0F             ; +$09 STATS HP=15 MP=7 ATK=14 DEF=8 AGI=21 WIS=15
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$02,$02,$02,$03,$03,$02,$02   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=2 Rukani=3 Bomie=3 Megante=2 Madante=2
    DB $00,$00,$00,$00,$00,$02,$01,$01,$02,$01,$00  ; +$1F BREATH-RES: Skip=2 Dance=1 StopBreath=1 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec0E:                                     ; $46BB  species $0E
    DB $00                                 ; +$00 family=0 (Slime)
    DB $28,$09                             ; +$01 maxLvl=40, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $4E,$68,$92                         ; +$06 SKILLS (bank84 ids): 78,104,146
    DB $12,$0B,$12,$0B,$14,$0F             ; +$09 STATS HP=18 MP=11 ATK=18 DEF=11 AGI=20 WIS=15
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $03,$02,$03,$02,$02,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $01,$01,$00,$01,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec0F:                                     ; $46E6  species $0F
    DB $00                                 ; +$00 family=0 (Slime)
    DB $28,$0C                             ; +$01 maxLvl=40, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $24,$2B,$30                         ; +$06 SKILLS (bank84 ids): 36,43,48
    DB $12,$0E,$0F,$0E,$14,$0F             ; +$09 STATS HP=18 MP=14 ATK=15 DEF=14 AGI=20 WIS=15
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $03,$02,$03,$02,$02,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=1 Paralysis=1 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec10:                                     ; $4711  species $10
    DB $00                                 ; +$00 family=0 (Slime)
    DB $14,$19                             ; +$01 maxLvl=20, +$02 expType=25
    DB $02,$00,$01                         ; +$03 gender=2, flight=0, metal=1
    DB $00,$0C,$12                         ; +$06 SKILLS (bank84 ids): 0,12,18
    DB $00,$1E,$0B,$1E,$1F,$0D             ; +$09 STATS HP=0 MP=30 ATK=11 DEF=30 AGI=31 WIS=13
    DB $03,$03,$03,$03,$03,$03             ; +$0F SPELL-RES Mela=3 Gira=3 Io=3 Bagi=3 Dain=3 Hyad=3
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $03,$03,$03,$03,$03,$00,$00,$00,$03,$00,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=3 Paralysis=3 Curse=3 CallOut=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec11:                                     ; $473C  species $11
    DB $00                                 ; +$00 family=0 (Slime)
    DB $28,$1B                             ; +$01 maxLvl=40, +$02 expType=27
    DB $02,$00,$01                         ; +$03 gender=2, flight=0, metal=1
    DB $03,$06,$14                         ; +$06 SKILLS (bank84 ids): 3,6,20
    DB $00,$1E,$0E,$1F,$1F,$0F             ; +$09 STATS HP=0 MP=30 ATK=14 DEF=31 AGI=31 WIS=15
    DB $03,$03,$03,$03,$03,$03             ; +$0F SPELL-RES Mela=3 Gira=3 Io=3 Bagi=3 Dain=3 Hyad=3
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $03,$03,$03,$03,$03,$00,$00,$00,$03,$00,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=3 Paralysis=3 Curse=3 CallOut=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec12:                                     ; $4767  species $12
    DB $00                                 ; +$00 family=0 (Slime)
    DB $3C,$1D                             ; +$01 maxLvl=60, +$02 expType=29
    DB $02,$00,$01                         ; +$03 gender=2, flight=0, metal=1
    DB $0F,$2A,$64                         ; +$06 SKILLS (bank84 ids): 15,42,100
    DB $00,$1F,$0F,$1F,$1F,$12             ; +$09 STATS HP=0 MP=31 ATK=15 DEF=31 AGI=31 WIS=18
    DB $03,$03,$03,$03,$03,$03             ; +$0F SPELL-RES Mela=3 Gira=3 Io=3 Bagi=3 Dain=3 Hyad=3
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $03,$03,$03,$03,$03,$00,$00,$00,$03,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=3 Paralysis=3 Curse=3 CallOut=3 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec13:                                     ; $4792  species $13
    DB $00                                 ; +$00 family=0 (Slime)
    DB $50,$1F                             ; +$01 maxLvl=80, +$02 expType=31
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $39,$65,$81                         ; +$06 SKILLS (bank84 ids): 57,101,129
    DB $00,$1F,$13,$1F,$1F,$12             ; +$09 STATS HP=0 MP=31 ATK=19 DEF=31 AGI=31 WIS=18
    DB $03,$03,$03,$03,$03,$03             ; +$0F SPELL-RES Mela=3 Gira=3 Io=3 Bagi=3 Dain=3 Hyad=3
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $03,$03,$03,$03,$03,$01,$01,$01,$03,$02,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 1 (Dragon) begins ---
.rec14:                                     ; $47BD  species $14
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $19,$07                             ; +$01 maxLvl=25, +$02 expType=7
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $5C,$6A,$8C                         ; +$06 SKILLS (bank84 ids): 92,106,140
    DB $0A,$03,$11,$02,$05,$05             ; +$09 STATS HP=10 MP=3 ATK=17 DEF=2 AGI=5 WIS=5
    DB $01,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $01,$01,$01,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec15:                                     ; $47E8  species $15
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$11                             ; +$01 maxLvl=35, +$02 expType=17
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $27,$2A,$5A                         ; +$06 SKILLS (bank84 ids): 39,42,90
    DB $0F,$0B,$12,$06,$07,$0D             ; +$09 STATS HP=15 MP=11 ATK=18 DEF=6 AGI=7 WIS=13
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Rukani=1 Bomie=1 Megante=2
    DB $02,$01,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec16:                                     ; $4813  species $16
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$10                             ; +$01 maxLvl=35, +$02 expType=16
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $03,$58,$8A                         ; +$06 SKILLS (bank84 ids): 3,88,138
    DB $0E,$0B,$12,$02,$14,$04             ; +$09 STATS HP=14 MP=11 ATK=18 DEF=2 AGI=20 WIS=4
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Megante=2
    DB $02,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec17:                                     ; $483E  species $17
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $32,$12                             ; +$01 maxLvl=50, +$02 expType=18
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $14,$32,$3D                         ; +$06 SKILLS (bank84 ids): 20,50,61
    DB $11,$0F,$0D,$0B,$07,$12             ; +$09 STATS HP=17 MP=15 ATK=13 DEF=11 AGI=7 WIS=18
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$01,$01,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Mahotora=1 Mahotone=1 Megante=2
    DB $02,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec18:                                     ; $4869  species $18
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $1E,$0F                             ; +$01 maxLvl=30, +$02 expType=15
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $18,$6A,$79                         ; +$06 SKILLS (bank84 ids): 24,106,121
    DB $09,$0D,$11,$10,$0E,$04             ; +$09 STATS HP=9 MP=13 ATK=17 DEF=16 AGI=14 WIS=4
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$01,$00,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Medapani=1 Megante=2
    DB $02,$00,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec19:                                     ; $4894  species $19
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $28,$14                             ; +$01 maxLvl=40, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $40,$4A,$D9                         ; +$06 SKILLS (bank84 ids): 64,74,217
    DB $11,$0A,$13,$0D,$05,$10             ; +$09 STATS HP=17 MP=10 ATK=19 DEF=13 AGI=5 WIS=16
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$01,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=1 Megante=3
    DB $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec1A:                                     ; $48BF  species $1A
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $2D,$13                             ; +$01 maxLvl=45, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $67,$6C,$79                         ; +$06 SKILLS (bank84 ids): 103,108,121
    DB $15,$10,$0F,$0D,$07,$01             ; +$09 STATS HP=21 MP=16 ATK=15 DEF=13 AGI=7 WIS=1
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $01,$01,$01,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Medapani=1 Megante=2
    DB $02,$00,$02,$01,$01,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Poison=2 Paralysis=1 Curse=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec1B:                                     ; $48EA  species $1B
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $32,$14                             ; +$01 maxLvl=50, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $4E,$57,$90                         ; +$06 SKILLS (bank84 ids): 78,87,144
    DB $09,$03,$17,$06,$01,$05             ; +$09 STATS HP=9 MP=3 ATK=23 DEF=6 AGI=1 WIS=5
    DB $02,$02,$03,$00,$00,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=3 Bagi=0 Dain=0 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=1 Megante=3
    DB $02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec1C:                                     ; $4915  species $1C
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $28,$14                             ; +$01 maxLvl=40, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $44,$5C,$8F                         ; +$06 SKILLS (bank84 ids): 68,92,143
    DB $11,$01,$14,$10,$07,$04             ; +$09 STATS HP=17 MP=1 ATK=20 DEF=16 AGI=7 WIS=4
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$02,$00,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=1 Megante=2
    DB $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec1D:                                     ; $4940  species $1D
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$10                             ; +$01 maxLvl=35, +$02 expType=16
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3C,$52,$72                         ; +$06 SKILLS (bank84 ids): 60,82,114
    DB $0E,$08,$11,$0E,$12,$0A             ; +$09 STATS HP=14 MP=8 ATK=17 DEF=14 AGI=18 WIS=10
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Megante=2
    DB $02,$00,$00,$00,$00,$02,$01,$02,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Skip=2 Dance=1 StopBreath=2 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec1E:                                     ; $496B  species $1E
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$13                             ; +$01 maxLvl=35, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3F,$40,$78                         ; +$06 SKILLS (bank84 ids): 63,64,120
    DB $13,$00,$15,$05,$08,$00             ; +$09 STATS HP=19 MP=0 ATK=21 DEF=5 AGI=8 WIS=0
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$01,$00,$00,$00,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Rariho=1 Rukani=1 Bomie=1 Megante=2
    DB $02,$00,$00,$00,$00,$02,$02,$01,$02,$02,$00  ; +$1F BREATH-RES: Frame=2 Skip=2 Dance=2 StopBreath=1 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec1F:                                     ; $4996  species $1F
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$11                             ; +$01 maxLvl=35, +$02 expType=17
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $46,$4C,$67                         ; +$06 SKILLS (bank84 ids): 70,76,103
    DB $0E,$02,$11,$10,$0F,$05             ; +$09 STATS HP=14 MP=2 ATK=17 DEF=16 AGI=15 WIS=5
    DB $02,$02,$02,$02,$02,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=0
    DB $00,$02,$00,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=1 Megante=2
    DB $02,$01,$00,$00,$00,$00,$02,$01,$02,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 Dance=2 StopBreath=1 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec20:                                     ; $49C1  species $20
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $32,$13                             ; +$01 maxLvl=50, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $19,$69,$6B                         ; +$06 SKILLS (bank84 ids): 25,105,107
    DB $11,$12,$0B,$06,$08,$0D             ; +$09 STATS HP=17 MP=18 ATK=11 DEF=6 AGI=8 WIS=13
    DB $01,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$00,$02,$01,$00,$03,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=1 Medapani=3 Megante=3
    DB $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec21:                                     ; $49EC  species $21
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $1E,$10                             ; +$01 maxLvl=30, +$02 expType=16
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $03,$58,$5C                         ; +$06 SKILLS (bank84 ids): 3,88,92
    DB $0B,$0B,$11,$11,$0D,$05             ; +$09 STATS HP=11 MP=11 ATK=17 DEF=17 AGI=13 WIS=5
    DB $01,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$01,$00,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Medapani=1 Megante=2
    DB $03,$00,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec22:                                     ; $4A17  species $22
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $32,$16                             ; +$01 maxLvl=50, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$18,$6C                         ; +$06 SKILLS (bank84 ids): 9,24,108
    DB $15,$0F,$13,$11,$13,$0C             ; +$09 STATS HP=21 MP=15 ATK=19 DEF=17 AGI=19 WIS=12
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$02,$02,$02,$00,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=2 Mahotora=2 Medapani=2 Megante=2
    DB $02,$02,$00,$00,$00,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec23:                                     ; $4A42  species $23
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $28,$14                             ; +$01 maxLvl=40, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $67,$6F,$71                         ; +$06 SKILLS (bank84 ids): 103,111,113
    DB $12,$08,$10,$0D,$13,$0B             ; +$09 STATS HP=18 MP=8 ATK=16 DEF=13 AGI=19 WIS=11
    DB $01,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $01,$01,$01,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $02,$00,$02,$00,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Poison=2 Curse=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec24:                                     ; $4A6D  species $24
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $1E,$13                             ; +$01 maxLvl=30, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3D,$3E,$5B                         ; +$06 SKILLS (bank84 ids): 61,62,91
    DB $14,$08,$13,$18,$01,$02             ; +$09 STATS HP=20 MP=8 ATK=19 DEF=24 AGI=1 WIS=2
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $00,$01,$01,$00,$00,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=1 Medapani=1 Megante=3
    DB $02,$00,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec25:                                     ; $4A98  species $25
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $3C,$17                             ; +$01 maxLvl=60, +$02 expType=23
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $47,$60,$8F                         ; +$06 SKILLS (bank84 ids): 71,96,143
    DB $15,$05,$17,$0E,$10,$0B             ; +$09 STATS HP=21 MP=5 ATK=23 DEF=14 AGI=16 WIS=11
    DB $02,$03,$02,$01,$01,$01             ; +$0F SPELL-RES Mela=2 Gira=3 Io=2 Bagi=1 Dain=1 Hyad=1
    DB $01,$02,$03,$01,$01,$02,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Rukani=1 Bomie=1 Megante=3
    DB $03,$01,$01,$03,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=1 Paralysis=3 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec26:                                     ; $4AC3  species $26
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$12                             ; +$01 maxLvl=35, +$02 expType=18
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $17,$67,$D5                         ; +$06 SKILLS (bank84 ids): 23,103,213
    DB $0E,$04,$0F,$05,$13,$08             ; +$09 STATS HP=14 MP=4 ATK=15 DEF=5 AGI=19 WIS=8
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Megante=2
    DB $02,$00,$00,$00,$00,$02,$02,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Skip=2 Dance=2 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec27:                                     ; $4AEE  species $27
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $2D,$14                             ; +$01 maxLvl=45, +$02 expType=20
    DB $01,$00,$00                         ; +$03 gender=1, flight=0, metal=0
    DB $42,$55,$6C                         ; +$06 SKILLS (bank84 ids): 66,85,108
    DB $0F,$08,$14,$11,$0E,$0B             ; +$09 STATS HP=15 MP=8 ATK=20 DEF=17 AGI=14 WIS=11
    DB $03,$03,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=3 Gira=3 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$02,$00,$01,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=2 Mahotone=1 Megante=3
    DB $03,$00,$00,$00,$00,$02,$02,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Skip=2 Dance=2 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec28:                                     ; $4B19  species $28
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $3C,$17                             ; +$01 maxLvl=60, +$02 expType=23
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$40,$45                         ; +$06 SKILLS (bank84 ids): 6,64,69
    DB $19,$0E,$14,$16,$12,$0E             ; +$09 STATS HP=25 MP=14 ATK=20 DEF=22 AGI=18 WIS=14
    DB $02,$02,$02,$01,$01,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=1
    DB $01,$02,$02,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $03,$01,$01,$01,$01,$02,$02,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec29:                                     ; $4B44  species $29
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $3C,$16                             ; +$01 maxLvl=60, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $44,$50,$5C                         ; +$06 SKILLS (bank84 ids): 68,80,92
    DB $18,$0D,$18,$15,$0B,$08             ; +$09 STATS HP=24 MP=13 ATK=24 DEF=21 AGI=11 WIS=8
    DB $02,$02,$02,$01,$01,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=1
    DB $02,$02,$02,$01,$01,$03,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3
    DB $03,$01,$02,$02,$02,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec2A:                                     ; $4B6F  species $2A
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $3C,$16                             ; +$01 maxLvl=60, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $40,$48,$5C                         ; +$06 SKILLS (bank84 ids): 64,72,92
    DB $17,$10,$1A,$14,$11,$10             ; +$09 STATS HP=23 MP=16 ATK=26 DEF=20 AGI=17 WIS=16
    DB $02,$02,$02,$02,$02,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=1
    DB $01,$02,$02,$01,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $03,$01,$01,$02,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=1 Paralysis=2 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec2B:                                     ; $4B9A  species $2B
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $23,$12                             ; +$01 maxLvl=35, +$02 expType=18
    DB $03,$01,$00                         ; +$03 gender=3, flight=1, metal=0
    DB $43,$4F,$5C                         ; +$06 SKILLS (bank84 ids): 67,79,92
    DB $0F,$0B,$14,$0E,$12,$08             ; +$09 STATS HP=15 MP=11 ATK=20 DEF=14 AGI=18 WIS=8
    DB $01,$02,$02,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=1
    DB $01,$02,$02,$01,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $03,$01,$01,$02,$01,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=1 Paralysis=2 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec2C:                                     ; $4BC5  species $2C
    DB $01                                 ; +$00 family=1 (Dragon)
    DB $50,$1C                             ; +$01 maxLvl=80, +$02 expType=28
    DB $03,$01,$00                         ; +$03 gender=3, flight=1, metal=0
    DB $60,$65,$93                         ; +$06 SKILLS (bank84 ids): 96,101,147
    DB $1A,$19,$1C,$18,$14,$17             ; +$09 STATS HP=26 MP=25 ATK=28 DEF=24 AGI=20 WIS=23
    DB $02,$03,$03,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=3 Io=3 Bagi=2 Dain=2 Hyad=2
    DB $02,$02,$03,$02,$02,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=2 Mahotone=2 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $03,$02,$02,$03,$02,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=3 Breeze=2 Poison=2 Paralysis=3 Curse=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 2 (Beast) begins ---
.rec2D:                                     ; $4BF0  species $2D
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0C                             ; +$01 maxLvl=40, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $68,$6A,$79                         ; +$06 SKILLS (bank84 ids): 104,106,121
    DB $0E,$05,$0F,$0C,$0B,$10             ; +$09 STATS HP=14 MP=5 ATK=15 DEF=12 AGI=11 WIS=16
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$01,$01,$01,$01,$01,$03,$03,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=3 Bomie=3 Megante=1 Madante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec2E:                                     ; $4C1B  species $2E
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$0D                             ; +$01 maxLvl=45, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $15,$3D,$41                         ; +$06 SKILLS (bank84 ids): 21,61,65
    DB $12,$05,$0E,$09,$0F,$04             ; +$09 STATS HP=18 MP=5 ATK=14 DEF=9 AGI=15 WIS=4
    DB $01,$01,$01,$00,$00,$00             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Rukani=2 Bomie=2 Megante=1
    DB $01,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec2F:                                     ; $4C46  species $2F
    DB $02                                 ; +$00 family=2 (Beast)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $17,$20,$75                         ; +$06 SKILLS (bank84 ids): 23,32,117
    DB $0B,$0A,$0D,$08,$12,$0E             ; +$09 STATS HP=11 MP=10 ATK=13 DEF=8 AGI=18 WIS=14
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$02,$02,$00,$00   ; +$15 STATUS-RES: Rukani=2 Bomie=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec30:                                     ; $4C71  species $30
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3C,$52,$77                         ; +$06 SKILLS (bank84 ids): 60,82,119
    DB $0E,$11,$08,$08,$13,$0D             ; +$09 STATS HP=14 MP=17 ATK=8 DEF=8 AGI=19 WIS=13
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$01,$01,$00,$02,$02,$00,$00   ; +$15 STATUS-RES: Mahotora=1 Mahotone=1 Rukani=2 Bomie=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec31:                                     ; $4C9C  species $31
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$09                             ; +$01 maxLvl=40, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$56,$6B                         ; +$06 SKILLS (bank84 ids): 30,86,107
    DB $10,$05,$09,$11,$00,$0D             ; +$09 STATS HP=16 MP=5 ATK=9 DEF=17 AGI=0 WIS=13
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$01,$00,$00,$00,$01,$02,$02,$00,$00   ; +$15 STATUS-RES: Rariho=1 Medapani=1 Rukani=2 Bomie=2
    DB $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec32:                                     ; $4CC7  species $32
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$0D                             ; +$01 maxLvl=45, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3C,$3F,$7D                         ; +$06 SKILLS (bank84 ids): 60,63,125
    DB $18,$01,$1A,$0D,$07,$01             ; +$09 STATS HP=24 MP=1 ATK=26 DEF=13 AGI=7 WIS=1
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Zaki=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec33:                                     ; $4CF2  species $33
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$0C                             ; +$01 maxLvl=45, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $41,$49,$6E                         ; +$06 SKILLS (bank84 ids): 65,73,110
    DB $0E,$0A,$0B,$08,$10,$02             ; +$09 STATS HP=14 MP=10 ATK=11 DEF=8 AGI=16 WIS=2
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$01,$01,$00,$00,$01,$02,$02,$01,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Medapani=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec34:                                     ; $4D1D  species $34
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$0C,$46                         ; +$06 SKILLS (bank84 ids): 9,12,70
    DB $0D,$14,$0D,$0F,$0F,$0D             ; +$09 STATS HP=13 MP=20 ATK=13 DEF=15 AGI=15 WIS=13
    DB $00,$00,$00,$02,$00,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=0 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Zaki=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$01,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Breeze=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec35:                                     ; $4D48  species $35
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$08                             ; +$01 maxLvl=40, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $48,$55,$79                         ; +$06 SKILLS (bank84 ids): 72,85,121
    DB $0E,$07,$11,$0B,$09,$0B             ; +$09 STATS HP=14 MP=7 ATK=17 DEF=11 AGI=9 WIS=11
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$02,$02,$00,$00   ; +$15 STATUS-RES: Rukani=2 Bomie=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $00                                 ; +$2A rank=0

.rec36:                                     ; $4D73  species $36
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$09                             ; +$01 maxLvl=45, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $71,$7F,$94                         ; +$06 SKILLS (bank84 ids): 113,127,148
    DB $12,$07,$0D,$0C,$0B,$07             ; +$09 STATS HP=18 MP=7 ATK=13 DEF=12 AGI=11 WIS=7
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$02,$01,$00,$00,$02,$02,$02,$00,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=1 Medapani=2 Rukani=2 Bomie=2
    DB $00,$00,$01,$01,$01,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec37:                                     ; $4D9E  species $37
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$0A                             ; +$01 maxLvl=45, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $27,$88,$8E                         ; +$06 SKILLS (bank84 ids): 39,136,142
    DB $12,$05,$11,$17,$02,$0B             ; +$09 STATS HP=18 MP=5 ATK=17 DEF=23 AGI=2 WIS=11
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $00,$00,$00,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Rukani=2 Bomie=2 Megante=1
    DB $02,$02,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec38:                                     ; $4DC9  species $38
    DB $02                                 ; +$00 family=2 (Beast)
    DB $23,$0B                             ; +$01 maxLvl=35, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$78,$92                         ; +$06 SKILLS (bank84 ids): 12,120,146
    DB $0E,$0B,$10,$0E,$14,$08             ; +$09 STATS HP=14 MP=11 ATK=16 DEF=14 AGI=20 WIS=8
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$01,$00,$00,$01,$02,$02,$00,$00   ; +$15 STATUS-RES: Zaki=1 Medapani=1 Rukani=2 Bomie=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec39:                                     ; $4DF4  species $39
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3E,$40,$41                         ; +$06 SKILLS (bank84 ids): 62,64,65
    DB $11,$13,$11,$0B,$11,$0A             ; +$09 STATS HP=17 MP=19 ATK=17 DEF=11 AGI=17 WIS=10
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$02,$02,$00,$02,$02,$00,$00   ; +$15 STATUS-RES: Mahotora=2 Mahotone=2 Rukani=2 Bomie=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec3A:                                     ; $4E1F  species $3A
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0E                             ; +$01 maxLvl=40, +$02 expType=14
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3B,$55,$7B                         ; +$06 SKILLS (bank84 ids): 59,85,123
    DB $14,$00,$1B,$07,$09,$01             ; +$09 STATS HP=20 MP=0 ATK=27 DEF=7 AGI=9 WIS=1
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Zaki=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$00,$00,$00,$00,$03,$02,$02,$03,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=2 StopBreath=2 CallOut=3 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec3B:                                     ; $4E4A  species $3B
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0D                             ; +$01 maxLvl=40, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$47,$7D                         ; +$06 SKILLS (bank84 ids): 12,71,125
    DB $12,$0B,$0F,$09,$0A,$08             ; +$09 STATS HP=18 MP=11 ATK=15 DEF=9 AGI=10 WIS=8
    DB $01,$01,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $00,$00,$01,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Zaki=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$03,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Breeze=3 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec3C:                                     ; $4E75  species $3C
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $41,$4B,$4D                         ; +$06 SKILLS (bank84 ids): 65,75,77
    DB $0E,$0D,$11,$09,$08,$0B             ; +$09 STATS HP=14 MP=13 ATK=17 DEF=9 AGI=8 WIS=11
    DB $01,$01,$00,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=0 Dain=0 Hyad=1
    DB $00,$00,$02,$00,$00,$00,$02,$02,$02,$00   ; +$15 STATUS-RES: Zaki=2 Rukani=2 Bomie=2 Megante=2
    DB $01,$01,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec3D:                                     ; $4EA0  species $3D
    DB $02                                 ; +$00 family=2 (Beast)
    DB $2D,$0B                             ; +$01 maxLvl=45, +$02 expType=11
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $18,$20,$D6                         ; +$06 SKILLS (bank84 ids): 24,32,214
    DB $0C,$05,$0D,$0E,$11,$07             ; +$09 STATS HP=12 MP=5 ATK=13 DEF=14 AGI=17 WIS=7
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $00,$01,$00,$00,$00,$01,$02,$02,$01,$00   ; +$15 STATUS-RES: Rariho=1 Medapani=1 Rukani=2 Bomie=2 Megante=1
    DB $01,$01,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec3E:                                     ; $4ECB  species $3E
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0E                             ; +$01 maxLvl=50, +$02 expType=14
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $2B,$30,$33                         ; +$06 SKILLS (bank84 ids): 43,48,51
    DB $13,$15,$0E,$0D,$0C,$19             ; +$09 STATS HP=19 MP=21 ATK=14 DEF=13 AGI=12 WIS=25
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$02,$02,$01,$01,$02,$03,$03,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=2 Rukani=3 Bomie=3 Megante=1 Madante=1
    DB $00,$02,$00,$01,$01,$03,$02,$02,$03,$02,$00  ; +$1F BREATH-RES: Breeze=2 Paralysis=1 Curse=1 Skip=3 Dance=2 StopBreath=2 CallOut=3 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec3F:                                     ; $4EF6  species $3F
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$20,$6A                         ; +$06 SKILLS (bank84 ids): 3,32,106
    DB $13,$09,$11,$0D,$11,$03             ; +$09 STATS HP=19 MP=9 ATK=17 DEF=13 AGI=17 WIS=3
    DB $00,$01,$01,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=2
    DB $01,$01,$01,$01,$01,$01,$03,$03,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=3 Bomie=3 Megante=1 Madante=1
    DB $01,$02,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec40:                                     ; $4F21  species $40
    DB $02                                 ; +$00 family=2 (Beast)
    DB $23,$0D                             ; +$01 maxLvl=35, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3B,$52,$7B                         ; +$06 SKILLS (bank84 ids): 59,82,123
    DB $0D,$01,$14,$0A,$08,$04             ; +$09 STATS HP=13 MP=1 ATK=20 DEF=10 AGI=8 WIS=4
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$01,$00,$00,$00,$02,$02,$01,$00   ; +$15 STATUS-RES: Zaki=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec41:                                     ; $4F4C  species $41
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0E                             ; +$01 maxLvl=50, +$02 expType=14
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3D,$72,$7D                         ; +$06 SKILLS (bank84 ids): 61,114,125
    DB $11,$08,$15,$11,$0E,$0D             ; +$09 STATS HP=17 MP=8 ATK=21 DEF=17 AGI=14 WIS=13
    DB $00,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=0 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$00,$02,$00,$00,$01,$02,$03,$01,$00   ; +$15 STATUS-RES: Zaki=2 Medapani=1 Rukani=2 Bomie=3 Megante=1
    DB $00,$01,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Breeze=1 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec42:                                     ; $4F77  species $42
    DB $02                                 ; +$00 family=2 (Beast)
    DB $46,$0F                             ; +$01 maxLvl=70, +$02 expType=15
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$50,$60                         ; +$06 SKILLS (bank84 ids): 3,80,96
    DB $14,$0E,$18,$17,$11,$0E             ; +$09 STATS HP=20 MP=14 ATK=24 DEF=23 AGI=17 WIS=14
    DB $01,$01,$01,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=1
    DB $01,$01,$03,$01,$01,$02,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $01,$02,$01,$02,$01,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=1 Paralysis=2 Curse=1 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec43:                                     ; $4FA2  species $43
    DB $02                                 ; +$00 family=2 (Beast)
    DB $32,$0D                             ; +$01 maxLvl=50, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $15,$17,$56                         ; +$06 SKILLS (bank84 ids): 21,23,86
    DB $11,$04,$13,$12,$0A,$0C             ; +$09 STATS HP=17 MP=4 ATK=19 DEF=18 AGI=10 WIS=12
    DB $01,$01,$00,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=0 Dain=0 Hyad=1
    DB $01,$02,$03,$01,$03,$01,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=3 Mahotora=1 Mahotone=3 Medapani=1 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $01,$01,$00,$02,$01,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=2 Curse=1 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec44:                                     ; $4FCD  species $44
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0C                             ; +$01 maxLvl=40, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $46,$55,$7B                         ; +$06 SKILLS (bank84 ids): 70,85,123
    DB $0F,$07,$12,$0E,$11,$0B             ; +$09 STATS HP=15 MP=7 ATK=18 DEF=14 AGI=17 WIS=11
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $00,$01,$03,$00,$00,$00,$02,$02,$03,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=3 Rukani=2 Bomie=2 Megante=3
    DB $01,$01,$00,$01,$00,$03,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=1 Skip=3 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec45:                                     ; $4FF8  species $45
    DB $02                                 ; +$00 family=2 (Beast)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$2B,$60                         ; +$06 SKILLS (bank84 ids): 12,43,96
    DB $0E,$08,$0E,$0B,$07,$09             ; +$09 STATS HP=14 MP=8 ATK=14 DEF=11 AGI=7 WIS=9
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$01,$03,$00,$02,$00,$02,$02,$03,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=3 Mahotone=2 Rukani=2 Bomie=2 Megante=3
    DB $00,$00,$00,$01,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Paralysis=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

    ; --- family 3 (Bird) begins ---
.rec46:                                     ; $5023  species $46
    DB $03                                 ; +$00 family=3 (Bird)
    DB $28,$04                             ; +$01 maxLvl=40, +$02 expType=4
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $18,$1C,$D7                         ; +$06 SKILLS (bank84 ids): 24,28,215
    DB $0B,$0C,$0E,$08,$12,$0D             ; +$09 STATS HP=11 MP=12 ATK=14 DEF=8 AGI=18 WIS=13
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=1 Madante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec47:                                     ; $504E  species $47
    DB $03                                 ; +$00 family=3 (Bird)
    DB $2D,$06                             ; +$01 maxLvl=45, +$02 expType=6
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $15,$2B,$60                         ; +$06 SKILLS (bank84 ids): 21,43,96
    DB $11,$0D,$13,$0B,$10,$14             ; +$09 STATS HP=17 MP=13 ATK=19 DEF=11 AGI=16 WIS=20
    DB $01,$01,$01,$02,$02,$00             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Megante=1
    DB $01,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec48:                                     ; $5079  species $48
    DB $03                                 ; +$00 family=3 (Bird)
    DB $23,$05                             ; +$01 maxLvl=35, +$02 expType=5
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3C,$41,$D8                         ; +$06 SKILLS (bank84 ids): 60,65,216
    DB $0E,$08,$11,$09,$06,$04             ; +$09 STATS HP=14 MP=8 ATK=17 DEF=9 AGI=6 WIS=4
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$01,$01,$00,$00   ; +$15 STATUS-RES: Rukani=1 Bomie=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec49:                                     ; $50A4  species $49
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$05                             ; +$01 maxLvl=50, +$02 expType=5
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $22,$4A,$95                         ; +$06 SKILLS (bank84 ids): 34,74,149
    DB $06,$12,$0C,$03,$15,$13             ; +$09 STATS HP=6 MP=18 ATK=12 DEF=3 AGI=21 WIS=19
    DB $00,$00,$00,$03,$03,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=3 Dain=3 Hyad=0
    DB $00,$00,$00,$01,$01,$00,$00,$00,$00,$00   ; +$15 STATUS-RES: Mahotora=1 Mahotone=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec4A:                                     ; $50CF  species $4A
    DB $03                                 ; +$00 family=3 (Bird)
    DB $1E,$03                             ; +$01 maxLvl=30, +$02 expType=3
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $15,$19,$6F                         ; +$06 SKILLS (bank84 ids): 21,25,111
    DB $0B,$0B,$09,$0C,$12,$07             ; +$09 STATS HP=11 MP=11 ATK=9 DEF=12 AGI=18 WIS=7
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$01,$00,$00,$00,$01,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=1 Medapani=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec4B:                                     ; $50FA  species $4B
    DB $03                                 ; +$00 family=3 (Bird)
    DB $28,$04                             ; +$01 maxLvl=40, +$02 expType=4
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$1C,$46                         ; +$06 SKILLS (bank84 ids): 9,28,70
    DB $09,$07,$14,$0E,$17,$0D             ; +$09 STATS HP=9 MP=7 ATK=20 DEF=14 AGI=23 WIS=13
    DB $01,$01,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=1 Megante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec4C:                                     ; $5125  species $4C
    DB $03                                 ; +$00 family=3 (Bird)
    DB $2D,$05                             ; +$01 maxLvl=45, +$02 expType=5
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $42,$49,$8A                         ; +$06 SKILLS (bank84 ids): 66,73,138
    DB $06,$0E,$11,$0C,$12,$05             ; +$09 STATS HP=6 MP=14 ATK=17 DEF=12 AGI=18 WIS=5
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $01,$01,$01,$00,$00,$01,$00,$00,$00,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Medapani=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec4D:                                     ; $5150  species $4D
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$05                             ; +$01 maxLvl=50, +$02 expType=5
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $18,$24,$74                         ; +$06 SKILLS (bank84 ids): 24,36,116
    DB $0C,$11,$08,$0F,$16,$0D             ; +$09 STATS HP=12 MP=17 ATK=8 DEF=15 AGI=22 WIS=13
    DB $00,$00,$00,$02,$02,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$01,$00,$00,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=1 Megante=1
    DB $00,$01,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Breeze=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec4E:                                     ; $517B  species $4E
    DB $03                                 ; +$00 family=3 (Bird)
    DB $28,$02                             ; +$01 maxLvl=40, +$02 expType=2
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $15,$1A,$33                         ; +$06 SKILLS (bank84 ids): 21,26,51
    DB $0B,$04,$08,$0D,$11,$0B             ; +$09 STATS HP=11 MP=4 ATK=8 DEF=13 AGI=17 WIS=11
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; +$15 STATUS-RES: (all 0)
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $00                                 ; +$2A rank=0

.rec4F:                                     ; $51A6  species $4F
    DB $03                                 ; +$00 family=3 (Bird)
    DB $28,$03                             ; +$01 maxLvl=40, +$02 expType=3
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $46,$72,$8C                         ; +$06 SKILLS (bank84 ids): 70,114,140
    DB $08,$05,$0E,$0C,$11,$08             ; +$09 STATS HP=8 MP=5 ATK=14 DEF=12 AGI=17 WIS=8
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; +$15 STATUS-RES: (all 0)
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec50:                                     ; $51D1  species $50
    DB $03                                 ; +$00 family=3 (Bird)
    DB $28,$06                             ; +$01 maxLvl=40, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $25,$57,$D7                         ; +$06 SKILLS (bank84 ids): 37,87,215
    DB $10,$0C,$14,$14,$0E,$0B             ; +$09 STATS HP=16 MP=12 ATK=20 DEF=20 AGI=14 WIS=11
    DB $00,$00,$00,$02,$02,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=2
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=1 Madante=1
    DB $00,$02,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Breeze=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec51:                                     ; $51FC  species $51
    DB $03                                 ; +$00 family=3 (Bird)
    DB $23,$07                             ; +$01 maxLvl=35, +$02 expType=7
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$45,$77                         ; +$06 SKILLS (bank84 ids): 9,69,119
    DB $0F,$0A,$15,$0D,$0B,$12             ; +$09 STATS HP=15 MP=10 ATK=21 DEF=13 AGI=11 WIS=18
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$01,$01,$00,$00,$01,$02,$02,$01,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=1 Medapani=1 Rukani=2 Bomie=2 Megante=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec52:                                     ; $5227  species $52
    DB $03                                 ; +$00 family=3 (Bird)
    DB $1E,$05                             ; +$01 maxLvl=30, +$02 expType=5
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $19,$75,$78                         ; +$06 SKILLS (bank84 ids): 25,117,120
    DB $11,$06,$11,$0F,$14,$08             ; +$09 STATS HP=17 MP=6 ATK=17 DEF=15 AGI=20 WIS=8
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$02,$01,$00,$00,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=1 Medapani=2
    DB $00,$00,$02,$01,$01,$02,$02,$02,$03,$03,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec53:                                     ; $5252  species $53
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$06                             ; +$01 maxLvl=50, +$02 expType=6
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $03,$2E,$4F                         ; +$06 SKILLS (bank84 ids): 3,46,79
    DB $0E,$0B,$12,$0C,$11,$0D             ; +$09 STATS HP=14 MP=11 ATK=18 DEF=12 AGI=17 WIS=13
    DB $01,$01,$00,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$02,$00,$01,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Mahotone=1 Medapani=1 Megante=2
    DB $01,$02,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec54:                                     ; $527D  species $54
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$07                             ; +$01 maxLvl=50, +$02 expType=7
    DB $03,$01,$00                         ; +$03 gender=3, flight=1, metal=0
    DB $12,$47,$60                         ; +$06 SKILLS (bank84 ids): 18,71,96
    DB $14,$07,$0B,$11,$13,$0B             ; +$09 STATS HP=20 MP=7 ATK=11 DEF=17 AGI=19 WIS=11
    DB $01,$01,$00,$02,$02,$03             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=2 Dain=2 Hyad=3
    DB $00,$00,$02,$00,$00,$01,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=2 Medapani=1 Megante=1
    DB $01,$03,$00,$01,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=3 Paralysis=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec55:                                     ; $52A8  species $55
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$07                             ; +$01 maxLvl=50, +$02 expType=7
    DB $01,$01,$00                         ; +$03 gender=1, flight=1, metal=0
    DB $55,$5C,$8A                         ; +$06 SKILLS (bank84 ids): 85,92,138
    DB $10,$0D,$13,$08,$13,$0C             ; +$09 STATS HP=16 MP=13 ATK=19 DEF=8 AGI=19 WIS=12
    DB $02,$02,$02,$01,$01,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=0
    DB $00,$00,$00,$01,$01,$01,$00,$00,$00,$00   ; +$15 STATUS-RES: Mahotora=1 Mahotone=1 Medapani=1
    DB $03,$00,$00,$01,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Frame=3 Paralysis=1 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec56:                                     ; $52D3  species $56
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$07                             ; +$01 maxLvl=50, +$02 expType=7
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $45,$5A,$64                         ; +$06 SKILLS (bank84 ids): 69,90,100
    DB $14,$07,$13,$11,$16,$0C             ; +$09 STATS HP=20 MP=7 ATK=19 DEF=17 AGI=22 WIS=12
    DB $01,$01,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $00,$00,$01,$02,$00,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=2 Medapani=2 Megante=1
    DB $01,$01,$00,$01,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=1 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec57:                                     ; $52FE  species $57
    DB $03                                 ; +$00 family=3 (Bird)
    DB $3C,$0F                             ; +$01 maxLvl=60, +$02 expType=15
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $2A,$83,$84                         ; +$06 SKILLS (bank84 ids): 42,131,132
    DB $1B,$13,$0C,$14,$17,$17             ; +$09 STATS HP=27 MP=19 ATK=12 DEF=20 AGI=23 WIS=23
    DB $01,$01,$01,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=1
    DB $01,$01,$02,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=2 Medapani=1 Megante=2
    DB $01,$01,$00,$02,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec58:                                     ; $5329  species $58
    DB $03                                 ; +$00 family=3 (Bird)
    DB $32,$05                             ; +$01 maxLvl=50, +$02 expType=5
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $6E,$94,$96                         ; +$06 SKILLS (bank84 ids): 110,148,150
    DB $0E,$14,$08,$09,$10,$14             ; +$09 STATS HP=14 MP=20 ATK=8 DEF=9 AGI=16 WIS=20
    DB $00,$00,$00,$03,$03,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=3 Dain=3 Hyad=0
    DB $01,$00,$02,$01,$01,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Megante=3
    DB $00,$00,$00,$02,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Paralysis=2 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec59:                                     ; $5354  species $59
    DB $03                                 ; +$00 family=3 (Bird)
    DB $46,$18                             ; +$01 maxLvl=70, +$02 expType=24
    DB $01,$00,$00                         ; +$03 gender=1, flight=0, metal=0
    DB $66,$81,$8E                         ; +$06 SKILLS (bank84 ids): 102,129,142
    DB $19,$1B,$0F,$18,$12,$18             ; +$09 STATS HP=25 MP=27 ATK=15 DEF=24 AGI=18 WIS=24
    DB $02,$02,$02,$03,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=3 Dain=2 Hyad=2
    DB $01,$01,$02,$01,$01,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=2 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $02,$03,$01,$02,$01,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Frame=2 Breeze=3 Poison=1 Paralysis=2 Curse=1 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 4 (Plant) begins ---
.rec5A:                                     ; $537F  species $5A
    DB $04                                 ; +$00 family=4 (Plant)
    DB $28,$0A                             ; +$01 maxLvl=40, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1C,$20,$34                         ; +$06 SKILLS (bank84 ids): 28,32,52
    DB $0F,$18,$0B,$0D,$06,$12             ; +$09 STATS HP=15 MP=24 ATK=11 DEF=13 AGI=6 WIS=18
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $01,$01,$01,$03,$03,$01,$01,$01,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=3 Mahotone=3 Medapani=1 Rukani=1 Bomie=1 Megante=1 Madante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec5B:                                     ; $53AA  species $5B
    DB $04                                 ; +$00 family=4 (Plant)
    DB $2D,$0F                             ; +$01 maxLvl=45, +$02 expType=15
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$35,$6B                         ; +$06 SKILLS (bank84 ids): 0,53,107
    DB $0E,$1A,$0A,$0C,$05,$11             ; +$09 STATS HP=14 MP=26 ATK=10 DEF=12 AGI=5 WIS=17
    DB $01,$01,$01,$02,$02,$00             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$02,$02,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Mahotora=2 Mahotone=2 Megante=1
    DB $02,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec5C:                                     ; $53D5  species $5C
    DB $04                                 ; +$00 family=4 (Plant)
    DB $23,$07                             ; +$01 maxLvl=35, +$02 expType=7
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$33,$36                         ; +$06 SKILLS (bank84 ids): 3,51,54
    DB $11,$14,$06,$09,$02,$13             ; +$09 STATS HP=17 MP=20 ATK=6 DEF=9 AGI=2 WIS=19
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$02,$02,$00,$01,$01,$00,$00   ; +$15 STATUS-RES: Mahotora=2 Mahotone=2 Rukani=1 Bomie=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec5D:                                     ; $5400  species $5D
    DB $04                                 ; +$00 family=4 (Plant)
    DB $23,$07                             ; +$01 maxLvl=35, +$02 expType=7
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $32,$37,$4D                         ; +$06 SKILLS (bank84 ids): 50,55,77
    DB $0C,$14,$06,$0B,$0E,$07             ; +$09 STATS HP=12 MP=20 ATK=6 DEF=11 AGI=14 WIS=7
    DB $00,$00,$00,$03,$03,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=3 Dain=3 Hyad=0
    DB $00,$00,$00,$02,$02,$00,$00,$00,$00,$00   ; +$15 STATUS-RES: Mahotora=2 Mahotone=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec5E:                                     ; $542B  species $5E
    DB $04                                 ; +$00 family=4 (Plant)
    DB $1E,$06                             ; +$01 maxLvl=30, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $42,$69,$75                         ; +$06 SKILLS (bank84 ids): 66,105,117
    DB $12,$12,$0C,$0F,$09,$05             ; +$09 STATS HP=18 MP=18 ATK=12 DEF=15 AGI=9 WIS=5
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$01,$00,$02,$02,$01,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=1 Mahotora=2 Mahotone=2 Medapani=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$01,$01,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec5F:                                     ; $5456  species $5F
    DB $04                                 ; +$00 family=4 (Plant)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$15,$68                         ; +$06 SKILLS (bank84 ids): 9,21,104
    DB $10,$11,$09,$06,$02,$0E             ; +$09 STATS HP=16 MP=17 ATK=9 DEF=6 AGI=2 WIS=14
    DB $01,$01,$01,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$01,$02,$02,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=2 Mahotone=2 Megante=1
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec60:                                     ; $5481  species $60
    DB $04                                 ; +$00 family=4 (Plant)
    DB $2D,$09                             ; +$01 maxLvl=45, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $68,$6A,$92                         ; +$06 SKILLS (bank84 ids): 104,106,146
    DB $0E,$12,$08,$09,$0D,$0D             ; +$09 STATS HP=14 MP=18 ATK=8 DEF=9 AGI=13 WIS=13
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $01,$01,$01,$02,$02,$01,$00,$00,$01,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=2 Mahotone=2 Medapani=1 Megante=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec61:                                     ; $54AC  species $61
    DB $04                                 ; +$00 family=4 (Plant)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $24,$25,$26                         ; +$06 SKILLS (bank84 ids): 36,37,38
    DB $0C,$18,$08,$11,$0C,$0A             ; +$09 STATS HP=12 MP=24 ATK=8 DEF=17 AGI=12 WIS=10
    DB $00,$00,$00,$02,$02,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$01,$02,$02,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=2 Mahotone=2 Megante=1
    DB $00,$01,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec62:                                     ; $54D7  species $62
    DB $04                                 ; +$00 family=4 (Plant)
    DB $28,$08                             ; +$01 maxLvl=40, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $15,$37,$4D                         ; +$06 SKILLS (bank84 ids): 21,55,77
    DB $11,$0B,$04,$02,$09,$0E             ; +$09 STATS HP=17 MP=11 ATK=4 DEF=2 AGI=9 WIS=14
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$00,$02,$02,$00,$00,$00,$00,$00   ; +$15 STATUS-RES: Mahotora=2 Mahotone=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec63:                                     ; $5502  species $63
    DB $04                                 ; +$00 family=4 (Plant)
    DB $23,$09                             ; +$01 maxLvl=35, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1A,$41,$6A                         ; +$06 SKILLS (bank84 ids): 26,65,106
    DB $0D,$14,$0E,$0B,$03,$10             ; +$09 STATS HP=13 MP=20 ATK=14 DEF=11 AGI=3 WIS=16
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$01,$00,$02,$02,$01,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=1 Mahotora=2 Mahotone=2 Medapani=1
    DB $00,$00,$01,$01,$01,$02,$02,$02,$01,$01,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 Skip=2 Dance=2 StopBreath=2 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec64:                                     ; $552D  species $64
    DB $04                                 ; +$00 family=4 (Plant)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $71,$77,$78                         ; +$06 SKILLS (bank84 ids): 113,119,120
    DB $0B,$15,$07,$06,$14,$0B             ; +$09 STATS HP=11 MP=21 ATK=7 DEF=6 AGI=20 WIS=11
    DB $01,$01,$00,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$02,$03,$02,$00,$00,$00,$01,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=3 Mahotone=2 Megante=1
    DB $01,$01,$00,$00,$00,$02,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Skip=2 Dance=3 StopBreath=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec65:                                     ; $5558  species $65
    DB $04                                 ; +$00 family=4 (Plant)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$2B,$36                         ; +$06 SKILLS (bank84 ids): 12,43,54
    DB $0F,$12,$08,$03,$0C,$0F             ; +$09 STATS HP=15 MP=18 ATK=8 DEF=3 AGI=12 WIS=15
    DB $01,$01,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $00,$01,$02,$02,$02,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Mahotora=2 Mahotone=2 Medapani=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec66:                                     ; $5583  species $66
    DB $04                                 ; +$00 family=4 (Plant)
    DB $2D,$09                             ; +$01 maxLvl=45, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $17,$6F,$75                         ; +$06 SKILLS (bank84 ids): 23,111,117
    DB $0C,$14,$0B,$08,$0A,$11             ; +$09 STATS HP=12 MP=20 ATK=11 DEF=8 AGI=10 WIS=17
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $01,$02,$02,$02,$02,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Mahotora=2 Mahotone=2 Medapani=1 Megante=3
    DB $00,$00,$01,$02,$02,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=2 Curse=2 Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec67:                                     ; $55AE  species $67
    DB $04                                 ; +$00 family=4 (Plant)
    DB $28,$0D                             ; +$01 maxLvl=40, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $54,$6F,$91                         ; +$06 SKILLS (bank84 ids): 84,111,145
    DB $13,$11,$07,$0A,$0F,$17             ; +$09 STATS HP=19 MP=17 ATK=7 DEF=10 AGI=15 WIS=23
    DB $00,$00,$00,$03,$03,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=3 Dain=3 Hyad=0
    DB $00,$00,$02,$02,$02,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=2 Mahotone=2 Megante=3
    DB $00,$00,$00,$02,$00,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Paralysis=2 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec68:                                     ; $55D9  species $68
    DB $04                                 ; +$00 family=4 (Plant)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1A,$25,$38                         ; +$06 SKILLS (bank84 ids): 26,37,56
    DB $0E,$0F,$0C,$0E,$0F,$09             ; +$09 STATS HP=14 MP=15 ATK=12 DEF=14 AGI=15 WIS=9
    DB $00,$00,$00,$02,$02,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=2 Hyad=0
    DB $00,$00,$01,$02,$02,$00,$01,$01,$01,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=2 Mahotone=2 Rukani=1 Bomie=1 Megante=1
    DB $00,$00,$00,$00,$00,$03,$03,$03,$02,$02,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec69:                                     ; $5604  species $69
    DB $04                                 ; +$00 family=4 (Plant)
    DB $1E,$06                             ; +$01 maxLvl=30, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $4E,$69,$73                         ; +$06 SKILLS (bank84 ids): 78,105,115
    DB $08,$0B,$08,$05,$01,$03             ; +$09 STATS HP=8 MP=11 ATK=8 DEF=5 AGI=1 WIS=3
    DB $01,$01,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $00,$00,$01,$02,$02,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=2 Mahotone=2 Medapani=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec6A:                                     ; $562F  species $6A
    DB $04                                 ; +$00 family=4 (Plant)
    DB $32,$09                             ; +$01 maxLvl=50, +$02 expType=9
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $49,$56,$6A                         ; +$06 SKILLS (bank84 ids): 73,86,106
    DB $0E,$0C,$13,$07,$0A,$06             ; +$09 STATS HP=14 MP=12 ATK=19 DEF=7 AGI=10 WIS=6
    DB $01,$01,$01,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$01,$03,$03,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=1 Mahotora=3 Mahotone=3 Medapani=1 Megante=2
    DB $00,$00,$00,$00,$00,$03,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec6B:                                     ; $565A  species $6B
    DB $04                                 ; +$00 family=4 (Plant)
    DB $3C,$0B                             ; +$01 maxLvl=60, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $17,$52,$57                         ; +$06 SKILLS (bank84 ids): 23,82,87
    DB $11,$0E,$14,$0D,$0A,$10             ; +$09 STATS HP=17 MP=14 ATK=20 DEF=13 AGI=10 WIS=16
    DB $01,$01,$01,$02,$02,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=1
    DB $00,$00,$02,$03,$03,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=3 Mahotone=3 Medapani=1 Megante=3
    DB $00,$00,$00,$00,$00,$03,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Skip=3 Dance=3 StopBreath=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec6C:                                     ; $5685  species $6C
    DB $04                                 ; +$00 family=4 (Plant)
    DB $50,$18                             ; +$01 maxLvl=80, +$02 expType=24
    DB $03,$00,$00                         ; +$03 gender=3, flight=0, metal=0
    DB $50,$82,$90                         ; +$06 SKILLS (bank84 ids): 80,130,144
    DB $18,$1E,$17,$15,$12,$12             ; +$09 STATS HP=24 MP=30 ATK=23 DEF=21 AGI=18 WIS=18
    DB $01,$01,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $01,$01,$02,$03,$03,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=2 Mahotora=3 Mahotone=3 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $01,$01,$01,$02,$01,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=1 Paralysis=2 Curse=1 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec6D:                                     ; $56B0  species $6D
    DB $04                                 ; +$00 family=4 (Plant)
    DB $50,$00                             ; +$01 maxLvl=80, +$02 expType=0
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $39,$7E,$7F                         ; +$06 SKILLS (bank84 ids): 57,126,127
    DB $0A,$1B,$0B,$0E,$18,$1E             ; +$09 STATS HP=10 MP=27 ATK=11 DEF=14 AGI=24 WIS=30
    DB $02,$02,$02,$03,$03,$03             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=3 Dain=3 Hyad=3
    DB $01,$03,$03,$03,$03,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $02,$03,$03,$03,$03,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=3 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 5 (Bug) begins ---
.rec6E:                                     ; $56DB  species $6E
    DB $05                                 ; +$00 family=5 (Bug)
    DB $23,$02                             ; +$01 maxLvl=35, +$02 expType=2
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $79,$7E,$8C                         ; +$06 SKILLS (bank84 ids): 121,126,140
    DB $0B,$08,$0E,$09,$0B,$07             ; +$09 STATS HP=11 MP=8 ATK=14 DEF=9 AGI=11 WIS=7
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$03,$01,$01,$01,$03,$01,$01,$01,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=1 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=1 Madante=1
    DB $00,$00,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec6F:                                     ; $5706  species $6F
    DB $05                                 ; +$00 family=5 (Bug)
    DB $28,$04                             ; +$01 maxLvl=40, +$02 expType=4
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$6C,$83                         ; +$06 SKILLS (bank84 ids): 30,108,131
    DB $0D,$05,$0B,$0E,$0B,$09             ; +$09 STATS HP=13 MP=5 ATK=11 DEF=14 AGI=11 WIS=9
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $00,$02,$00,$00,$00,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2 Megante=1
    DB $01,$01,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec70:                                     ; $5731  species $70
    DB $05                                 ; +$00 family=5 (Bug)
    DB $1E,$01                             ; +$01 maxLvl=30, +$02 expType=1
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $12,$27,$52                         ; +$06 SKILLS (bank84 ids): 18,39,82
    DB $06,$0B,$0E,$12,$08,$07             ; +$09 STATS HP=6 MP=11 ATK=14 DEF=18 AGI=8 WIS=7
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$02,$00,$00,$00,$02,$01,$01,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2 Rukani=1 Bomie=1
    DB $00,$00,$02,$02,$02,$02,$02,$02,$03,$03,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=2 Dance=2 StopBreath=2 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec71:                                     ; $575C  species $71
    DB $05                                 ; +$00 family=5 (Bug)
    DB $1E,$00                             ; +$01 maxLvl=30, +$02 expType=0
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $18,$52,$6F                         ; +$06 SKILLS (bank84 ids): 24,82,111
    DB $0B,$02,$0D,$07,$0C,$08             ; +$09 STATS HP=11 MP=2 ATK=13 DEF=7 AGI=12 WIS=8
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$02,$00,$00,$00,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$03,$03,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec72:                                     ; $5787  species $72
    DB $05                                 ; +$00 family=5 (Bug)
    DB $2D,$04                             ; +$01 maxLvl=45, +$02 expType=4
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1A,$24,$26                         ; +$06 SKILLS (bank84 ids): 26,36,38
    DB $11,$0D,$0A,$0C,$05,$13             ; +$09 STATS HP=17 MP=13 ATK=10 DEF=12 AGI=5 WIS=19
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$02,$00,$01,$01,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Mahotora=1 Mahotone=1 Medapani=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec73:                                     ; $57B2  species $73
    DB $05                                 ; +$00 family=5 (Bug)
    DB $23,$06                             ; +$01 maxLvl=35, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $37,$4A,$75                         ; +$06 SKILLS (bank84 ids): 55,74,117
    DB $0D,$08,$10,$08,$0D,$0E             ; +$09 STATS HP=13 MP=8 ATK=16 DEF=8 AGI=13 WIS=14
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$02,$01,$00,$00,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=1 Medapani=2 Megante=1
    DB $00,$00,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec74:                                     ; $57DD  species $74
    DB $05                                 ; +$00 family=5 (Bug)
    DB $28,$04                             ; +$01 maxLvl=40, +$02 expType=4
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $68,$70,$79                         ; +$06 SKILLS (bank84 ids): 104,112,121
    DB $0C,$08,$09,$09,$04,$01             ; +$09 STATS HP=12 MP=8 ATK=9 DEF=9 AGI=4 WIS=1
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$03,$01,$00,$00,$03,$00,$00,$01,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=1 Medapani=3 Megante=1
    DB $00,$00,$03,$03,$03,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec75:                                     ; $5808  species $75
    DB $05                                 ; +$00 family=5 (Bug)
    DB $2D,$03                             ; +$01 maxLvl=45, +$02 expType=3
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $15,$5C,$7B                         ; +$06 SKILLS (bank84 ids): 21,92,123
    DB $0D,$07,$10,$14,$09,$07             ; +$09 STATS HP=13 MP=7 ATK=16 DEF=20 AGI=9 WIS=7
    DB $01,$01,$00,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=0 Dain=0 Hyad=1
    DB $00,$02,$01,$00,$00,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=1 Medapani=2 Megante=1
    DB $01,$01,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec76:                                     ; $5833  species $76
    DB $05                                 ; +$00 family=5 (Bug)
    DB $23,$02                             ; +$01 maxLvl=35, +$02 expType=2
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3E,$52,$68                         ; +$06 SKILLS (bank84 ids): 62,82,104
    DB $08,$04,$0B,$11,$0D,$01             ; +$09 STATS HP=8 MP=4 ATK=11 DEF=17 AGI=13 WIS=1
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$02,$00,$00,$00,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2
    DB $00,$00,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec77:                                     ; $585E  species $77
    DB $05                                 ; +$00 family=5 (Bug)
    DB $23,$00                             ; +$01 maxLvl=35, +$02 expType=0
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1A,$41,$52                         ; +$06 SKILLS (bank84 ids): 26,65,82
    DB $0B,$04,$08,$0E,$0E,$04             ; +$09 STATS HP=11 MP=4 ATK=8 DEF=14 AGI=14 WIS=4
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$02,$00,$00,$00,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2
    DB $00,$00,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec78:                                     ; $5889  species $78
    DB $05                                 ; +$00 family=5 (Bug)
    DB $2D,$05                             ; +$01 maxLvl=45, +$02 expType=5
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $47,$6C,$73                         ; +$06 SKILLS (bank84 ids): 71,108,115
    DB $0C,$0A,$10,$0B,$0E,$05             ; +$09 STATS HP=12 MP=10 ATK=16 DEF=11 AGI=14 WIS=5
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$02,$00,$01,$01,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Mahotora=1 Mahotone=1 Medapani=2
    DB $00,$00,$02,$02,$02,$01,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec79:                                     ; $58B4  species $79
    DB $05                                 ; +$00 family=5 (Bug)
    DB $1E,$06                             ; +$01 maxLvl=30, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$25,$3B                         ; +$06 SKILLS (bank84 ids): 30,37,59
    DB $0F,$0A,$11,$14,$0B,$02             ; +$09 STATS HP=15 MP=10 ATK=17 DEF=20 AGI=11 WIS=2
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$02,$00,$00,$00,$02,$00,$00,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2
    DB $01,$01,$02,$02,$02,$01,$01,$01,$03,$03,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec7A:                                     ; $58DF  species $7A
    DB $05                                 ; +$00 family=5 (Bug)
    DB $2D,$04                             ; +$01 maxLvl=45, +$02 expType=4
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $03,$2B,$38                         ; +$06 SKILLS (bank84 ids): 3,43,56
    DB $09,$0B,$06,$03,$0A,$09             ; +$09 STATS HP=9 MP=11 ATK=6 DEF=3 AGI=10 WIS=9
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $00,$02,$01,$01,$01,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=1 Mahotora=1 Mahotone=1 Medapani=2 Megante=1
    DB $00,$00,$02,$02,$02,$01,$01,$01,$02,$02,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec7B:                                     ; $590A  species $7B
    DB $05                                 ; +$00 family=5 (Bug)
    DB $1E,$02                             ; +$01 maxLvl=30, +$02 expType=2
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $58,$69,$73                         ; +$06 SKILLS (bank84 ids): 88,105,115
    DB $0E,$09,$10,$0C,$14,$0C             ; +$09 STATS HP=14 MP=9 ATK=16 DEF=12 AGI=20 WIS=12
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$03,$01,$00,$00,$02,$01,$01,$01,$00   ; +$15 STATUS-RES: Rariho=3 Zaki=1 Medapani=2 Rukani=1 Bomie=1 Megante=1
    DB $00,$00,$03,$02,$02,$01,$01,$01,$03,$03,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec7C:                                     ; $5935  species $7C
    DB $05                                 ; +$00 family=5 (Bug)
    DB $28,$05                             ; +$01 maxLvl=40, +$02 expType=5
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $20,$37,$D8                         ; +$06 SKILLS (bank84 ids): 32,55,216
    DB $11,$0A,$0F,$10,$07,$0E             ; +$09 STATS HP=17 MP=10 ATK=15 DEF=16 AGI=7 WIS=14
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$03,$01,$01,$00,$03,$00,$00,$01,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=1 Mahotora=1 Medapani=3 Megante=1
    DB $00,$00,$03,$03,$03,$01,$01,$01,$02,$02,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 StopBreath=1 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec7D:                                     ; $5960  species $7D
    DB $05                                 ; +$00 family=5 (Bug)
    DB $28,$06                             ; +$01 maxLvl=40, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1E,$48,$52                         ; +$06 SKILLS (bank84 ids): 30,72,82
    DB $10,$08,$0E,$13,$05,$01             ; +$09 STATS HP=16 MP=8 ATK=14 DEF=19 AGI=5 WIS=1
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $01,$03,$01,$00,$00,$03,$00,$00,$00,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=1 Medapani=3
    DB $00,$00,$03,$03,$03,$00,$00,$00,$03,$03,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec7E:                                     ; $598B  species $7E
    DB $05                                 ; +$00 family=5 (Bug)
    DB $28,$07                             ; +$01 maxLvl=40, +$02 expType=7
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $67,$69,$8A                         ; +$06 SKILLS (bank84 ids): 103,105,138
    DB $14,$05,$13,$0D,$14,$04             ; +$09 STATS HP=20 MP=5 ATK=19 DEF=13 AGI=20 WIS=4
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $00,$02,$00,$00,$00,$02,$01,$01,$00,$00   ; +$15 STATUS-RES: Rariho=2 Medapani=2 Rukani=1 Bomie=1
    DB $01,$01,$02,$02,$02,$01,$01,$01,$03,$03,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec7F:                                     ; $59B6  species $7F
    DB $05                                 ; +$00 family=5 (Bug)
    DB $32,$07                             ; +$01 maxLvl=50, +$02 expType=7
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $45,$4C,$5B                         ; +$06 SKILLS (bank84 ids): 69,76,91
    DB $15,$13,$17,$14,$0C,$0E             ; +$09 STATS HP=21 MP=19 ATK=23 DEF=20 AGI=12 WIS=14
    DB $02,$02,$02,$00,$00,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=2
    DB $00,$02,$01,$00,$00,$02,$00,$00,$01,$00   ; +$15 STATUS-RES: Rariho=2 Zaki=1 Medapani=2 Megante=1
    DB $02,$02,$02,$03,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=2 Paralysis=3 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec80:                                     ; $59E1  species $80
    DB $05                                 ; +$00 family=5 (Bug)
    DB $3C,$18                             ; +$01 maxLvl=60, +$02 expType=24
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $40,$4D,$57                         ; +$06 SKILLS (bank84 ids): 64,77,87
    DB $16,$14,$18,$17,$0F,$12             ; +$09 STATS HP=22 MP=20 ATK=24 DEF=23 AGI=15 WIS=18
    DB $02,$02,$02,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=2
    DB $01,$03,$02,$01,$01,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=3 Zaki=2 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $02,$02,$03,$03,$03,$01,$01,$01,$03,$03,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 StopBreath=1 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec81:                                     ; $5A0C  species $81
    DB $05                                 ; +$00 family=5 (Bug)
    DB $32,$0B                             ; +$01 maxLvl=50, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $32,$8E,$8F                         ; +$06 SKILLS (bank84 ids): 50,142,143
    DB $18,$0A,$13,$1A,$01,$0F             ; +$09 STATS HP=24 MP=10 ATK=19 DEF=26 AGI=1 WIS=15
    DB $01,$01,$01,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=1
    DB $01,$02,$02,$00,$00,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=2 Medapani=2 Megante=3
    DB $01,$01,$02,$02,$02,$00,$00,$00,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=2 Paralysis=2 Curse=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 6 (Devil) begins ---
.rec82:                                     ; $5A37  species $82
    DB $06                                 ; +$00 family=6 (Devil)
    DB $28,$13                             ; +$01 maxLvl=40, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $22,$25,$33                         ; +$06 SKILLS (bank84 ids): 34,37,51
    DB $0B,$07,$0F,$08,$0F,$04             ; +$09 STATS HP=11 MP=7 ATK=15 DEF=8 AGI=15 WIS=4
    DB $02,$02,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $01,$01,$03,$02,$02,$02,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec83:                                     ; $5A62  species $83
    DB $06                                 ; +$00 family=6 (Devil)
    DB $2D,$14                             ; +$01 maxLvl=45, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$45,$4B                         ; +$06 SKILLS (bank84 ids): 6,69,75
    DB $0E,$0D,$11,$0C,$07,$15             ; +$09 STATS HP=14 MP=13 ATK=17 DEF=12 AGI=7 WIS=21
    DB $02,$03,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=3 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$03,$00,$01,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Mahotone=1 Megante=3
    DB $01,$00,$00,$02,$01,$00,$00,$00,$00,$01,$00  ; +$1F BREATH-RES: Frame=1 Paralysis=2 Curse=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec84:                                     ; $5A8D  species $84
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$10                             ; +$01 maxLvl=35, +$02 expType=16
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$14,$6A                         ; +$06 SKILLS (bank84 ids): 3,20,106
    DB $10,$0B,$12,$0C,$10,$13             ; +$09 STATS HP=16 MP=11 ATK=18 DEF=12 AGI=16 WIS=19
    DB $01,$01,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Zaki=2 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$01,$01,$02,$01,$00  ; +$1F BREATH-RES: Skip=2 Dance=1 StopBreath=1 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec85:                                     ; $5AB8  species $85
    DB $06                                 ; +$00 family=6 (Devil)
    DB $19,$0D                             ; +$01 maxLvl=25, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$44,$60                         ; +$06 SKILLS (bank84 ids): 0,68,96
    DB $0D,$01,$05,$04,$09,$14             ; +$09 STATS HP=13 MP=1 ATK=5 DEF=4 AGI=9 WIS=20
    DB $01,$01,$01,$03,$03,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Megante=2
    DB $00,$00,$00,$00,$00,$01,$02,$02,$02,$01,$00  ; +$1F BREATH-RES: Skip=1 Dance=2 StopBreath=2 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec86:                                     ; $5AE3  species $86
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$12                             ; +$01 maxLvl=50, +$02 expType=18
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $48,$6B,$73                         ; +$06 SKILLS (bank84 ids): 72,107,115
    DB $0B,$12,$0A,$10,$09,$0C             ; +$09 STATS HP=11 MP=18 ATK=10 DEF=16 AGI=9 WIS=12
    DB $02,$02,$01,$03,$03,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=1 Bagi=3 Dain=3 Hyad=1
    DB $00,$00,$02,$01,$01,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=1 Mahotone=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$02,$01,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec87:                                     ; $5B0E  species $87
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$10                             ; +$01 maxLvl=35, +$02 expType=16
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $27,$2A,$7D                         ; +$06 SKILLS (bank84 ids): 39,42,125
    DB $10,$11,$0E,$0E,$0D,$08             ; +$09 STATS HP=16 MP=17 ATK=14 DEF=14 AGI=13 WIS=8
    DB $02,$02,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$01,$02,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Medapani=1 Megante=2
    DB $00,$00,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec88:                                     ; $5B39  species $88
    DB $06                                 ; +$00 family=6 (Devil)
    DB $2D,$12                             ; +$01 maxLvl=45, +$02 expType=18
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $44,$57,$7B                         ; +$06 SKILLS (bank84 ids): 68,87,123
    DB $11,$0B,$11,$0D,$0F,$0C             ; +$09 STATS HP=17 MP=11 ATK=17 DEF=13 AGI=15 WIS=12
    DB $02,$02,$02,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=2
    DB $01,$01,$03,$00,$00,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Medapani=1 Megante=3
    DB $00,$00,$02,$02,$01,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec89:                                     ; $5B64  species $89
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$14                             ; +$01 maxLvl=50, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$2A,$60                         ; +$06 SKILLS (bank84 ids): 3,42,96
    DB $10,$0A,$14,$16,$04,$0C             ; +$09 STATS HP=16 MP=10 ATK=20 DEF=22 AGI=4 WIS=12
    DB $02,$02,$01,$02,$02,$03             ; +$0F SPELL-RES Mela=2 Gira=2 Io=1 Bagi=2 Dain=2 Hyad=3
    DB $00,$00,$03,$01,$01,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Megante=3
    DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec8A:                                     ; $5B8F  species $8A
    DB $06                                 ; +$00 family=6 (Devil)
    DB $19,$0D                             ; +$01 maxLvl=25, +$02 expType=13
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $00,$03,$0C                         ; +$06 SKILLS (bank84 ids): 0,3,12
    DB $0A,$01,$05,$09,$09,$11             ; +$09 STATS HP=10 MP=1 ATK=5 DEF=9 AGI=9 WIS=17
    DB $01,$01,$01,$02,$02,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$03,$00,$01,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Mahotone=1 Megante=3
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec8B:                                     ; $5BBA  species $8B
    DB $06                                 ; +$00 family=6 (Devil)
    DB $19,$0D                             ; +$01 maxLvl=25, +$02 expType=13
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $03,$17,$2B                         ; +$06 SKILLS (bank84 ids): 3,23,43
    DB $0D,$07,$08,$04,$02,$12             ; +$09 STATS HP=13 MP=7 ATK=8 DEF=4 AGI=2 WIS=18
    DB $02,$02,$02,$01,$01,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=1
    DB $00,$00,$03,$00,$00,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Medapani=1 Megante=3
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec8C:                                     ; $5BE5  species $8C
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$13                             ; +$01 maxLvl=35, +$02 expType=19
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $18,$1C,$D8                         ; +$06 SKILLS (bank84 ids): 24,28,216
    DB $0B,$0D,$0E,$0F,$08,$0B             ; +$09 STATS HP=11 MP=13 ATK=14 DEF=15 AGI=8 WIS=11
    DB $02,$02,$02,$01,$01,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=1
    DB $00,$01,$02,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Medapani=1 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec8D:                                     ; $5C10  species $8D
    DB $06                                 ; +$00 family=6 (Devil)
    DB $2D,$15                             ; +$01 maxLvl=45, +$02 expType=21
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$2E,$46                         ; +$06 SKILLS (bank84 ids): 9,46,70
    DB $0F,$0B,$0E,$0F,$0C,$13             ; +$09 STATS HP=15 MP=11 ATK=14 DEF=15 AGI=12 WIS=19
    DB $03,$03,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=3 Gira=3 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$03,$01,$01,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Megante=3
    DB $02,$02,$00,$00,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Curse=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec8E:                                     ; $5C3B  species $8E
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$16                             ; +$01 maxLvl=35, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$09,$0C                         ; +$06 SKILLS (bank84 ids): 6,9,12
    DB $14,$0B,$11,$0D,$0B,$14             ; +$09 STATS HP=20 MP=11 ATK=17 DEF=13 AGI=11 WIS=20
    DB $02,$02,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$03,$00,$01,$01,$02,$02,$03,$00   ; +$15 STATUS-RES: Zaki=3 Mahotone=1 Medapani=1 Rukani=2 Bomie=2 Megante=3
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec8F:                                     ; $5C66  species $8F
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$11                             ; +$01 maxLvl=50, +$02 expType=17
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1C,$30,$4B                         ; +$06 SKILLS (bank84 ids): 28,48,75
    DB $13,$07,$13,$0D,$0D,$12             ; +$09 STATS HP=19 MP=7 ATK=19 DEF=13 AGI=13 WIS=18
    DB $01,$01,$01,$03,$03,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=3 Hyad=2
    DB $00,$00,$02,$01,$01,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=1 Mahotone=1 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec90:                                     ; $5C91  species $90
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$13                             ; +$01 maxLvl=35, +$02 expType=19
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3F,$48,$57                         ; +$06 SKILLS (bank84 ids): 63,72,87
    DB $0F,$08,$14,$0C,$0A,$0C             ; +$09 STATS HP=15 MP=8 ATK=20 DEF=12 AGI=10 WIS=12
    DB $01,$01,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Zaki=2 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$00,$00,$00,$02,$02,$02,$02,$01,$00  ; +$1F BREATH-RES: Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec91:                                     ; $5CBC  species $91
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$17                             ; +$01 maxLvl=50, +$02 expType=23
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$4E,$83                         ; +$06 SKILLS (bank84 ids): 0,78,131
    DB $12,$0C,$12,$0E,$0A,$0E             ; +$09 STATS HP=18 MP=12 ATK=18 DEF=14 AGI=10 WIS=14
    DB $02,$02,$02,$03,$03,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=3 Dain=3 Hyad=2
    DB $01,$01,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Megante=3
    DB $00,$00,$00,$00,$00,$01,$02,$02,$02,$01,$00  ; +$1F BREATH-RES: Skip=1 Dance=2 StopBreath=2 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec92:                                     ; $5CE7  species $92
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$16                             ; +$01 maxLvl=50, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $25,$46,$55                         ; +$06 SKILLS (bank84 ids): 37,70,85
    DB $11,$0C,$14,$0B,$14,$0F             ; +$09 STATS HP=17 MP=12 ATK=20 DEF=11 AGI=20 WIS=15
    DB $02,$02,$02,$02,$02,$03             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=3
    DB $01,$00,$03,$01,$01,$00,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Zaki=3 Mahotora=1 Mahotone=1 Rukani=1 Bomie=1 Megante=3
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec93:                                     ; $5D12  species $93
    DB $06                                 ; +$00 family=6 (Devil)
    DB $3C,$14                             ; +$01 maxLvl=60, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $44,$49,$88                         ; +$06 SKILLS (bank84 ids): 68,73,136
    DB $17,$01,$12,$18,$0C,$0C             ; +$09 STATS HP=23 MP=1 ATK=18 DEF=24 AGI=12 WIS=12
    DB $02,$02,$02,$02,$02,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=1
    DB $01,$01,$03,$01,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: (all 0) (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec94:                                     ; $5D3D  species $94
    DB $06                                 ; +$00 family=6 (Devil)
    DB $50,$1E                             ; +$01 maxLvl=80, +$02 expType=30
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$54,$60                         ; +$06 SKILLS (bank84 ids): 6,84,96
    DB $18,$1E,$17,$15,$12,$15             ; +$09 STATS HP=24 MP=30 ATK=23 DEF=21 AGI=18 WIS=21
    DB $02,$02,$03,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=3 Bagi=2 Dain=2 Hyad=2
    DB $01,$02,$03,$01,$03,$02,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=3 Mahotora=1 Mahotone=3 Medapani=2 Rukani=1 Bomie=1 Megante=3
    DB $02,$01,$00,$02,$00,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 Paralysis=2 Skip=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec95:                                     ; $5D68  species $95
    DB $06                                 ; +$00 family=6 (Devil)
    DB $32,$17                             ; +$01 maxLvl=50, +$02 expType=23
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3F,$4A,$D9                         ; +$06 SKILLS (bank84 ids): 63,74,217
    DB $11,$09,$12,$14,$0A,$0C             ; +$09 STATS HP=17 MP=9 ATK=18 DEF=20 AGI=10 WIS=12
    DB $02,$02,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $01,$01,$03,$00,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $01,$01,$00,$02,$00,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=2 Skip=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec96:                                     ; $5D93  species $96
    DB $06                                 ; +$00 family=6 (Devil)
    DB $23,$16                             ; +$01 maxLvl=35, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $40,$41,$4D                         ; +$06 SKILLS (bank84 ids): 64,65,77
    DB $1B,$00,$1B,$07,$00,$00             ; +$09 STATS HP=27 MP=0 ATK=27 DEF=7 AGI=0 WIS=0
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $00,$01,$03,$00,$00,$00,$02,$02,$03,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=3 Rukani=2 Bomie=2 Megante=3
    DB $00,$00,$00,$02,$00,$02,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Paralysis=2 Skip=2 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.rec97:                                     ; $5DBE  species $97
    DB $06                                 ; +$00 family=6 (Devil)
    DB $2D,$17                             ; +$01 maxLvl=45, +$02 expType=23
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $17,$44,$57                         ; +$06 SKILLS (bank84 ids): 23,68,87
    DB $14,$01,$18,$15,$12,$13             ; +$09 STATS HP=20 MP=1 ATK=24 DEF=21 AGI=18 WIS=19
    DB $03,$03,$02,$01,$01,$02             ; +$0F SPELL-RES Mela=3 Gira=3 Io=2 Bagi=1 Dain=1 Hyad=2
    DB $00,$00,$02,$00,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Zaki=2 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $01,$01,$00,$02,$00,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=2 Skip=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec98:                                     ; $5DE9  species $98
    DB $06                                 ; +$00 family=6 (Devil)
    DB $1E,$16                             ; +$01 maxLvl=30, +$02 expType=22
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $44,$45,$49                         ; +$06 SKILLS (bank84 ids): 68,69,73
    DB $10,$01,$11,$1D,$05,$0D             ; +$09 STATS HP=16 MP=1 ATK=17 DEF=29 AGI=5 WIS=13
    DB $02,$02,$02,$02,$02,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=1
    DB $00,$01,$03,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=3 Medapani=1 Megante=2
    DB $00,$00,$01,$02,$01,$01,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=1 Paralysis=2 Curse=1 Skip=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec99:                                     ; $5E14  species $99
    DB $06                                 ; +$00 family=6 (Devil)
    DB $3C,$15                             ; +$01 maxLvl=60, +$02 expType=21
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$50,$8A                         ; +$06 SKILLS (bank84 ids): 0,80,138
    DB $18,$09,$15,$18,$17,$12             ; +$09 STATS HP=24 MP=9 ATK=21 DEF=24 AGI=23 WIS=18
    DB $02,$02,$02,$03,$03,$01             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=3 Dain=3 Hyad=1
    DB $01,$01,$03,$01,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $00,$00,$00,$02,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Paralysis=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.rec9A:                                     ; $5E3F  species $9A
    DB $06                                 ; +$00 family=6 (Devil)
    DB $46,$1C                             ; +$01 maxLvl=70, +$02 expType=28
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $49,$4B,$58                         ; +$06 SKILLS (bank84 ids): 73,75,88
    DB $19,$18,$17,$0F,$11,$14             ; +$09 STATS HP=25 MP=24 ATK=23 DEF=15 AGI=17 WIS=20
    DB $02,$02,$03,$02,$01,$03             ; +$0F SPELL-RES Mela=2 Gira=2 Io=3 Bagi=2 Dain=1 Hyad=3
    DB $02,$02,$03,$01,$02,$02,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=2 Medapani=2 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $01,$01,$03,$03,$02,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=3 Paralysis=3 Curse=2 Skip=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 7 (Zombie) begins ---
.rec9B:                                     ; $5E6A  species $9B
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $73,$79,$92                         ; +$06 SKILLS (bank84 ids): 115,121,146
    DB $0B,$0C,$0D,$08,$12,$0F             ; +$09 STATS HP=11 MP=12 ATK=13 DEF=8 AGI=18 WIS=15
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $03,$03,$03,$01,$01,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $00,$00,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.rec9C:                                     ; $5E95  species $9C
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $2D,$0D                             ; +$01 maxLvl=45, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3B,$47,$60                         ; +$06 SKILLS (bank84 ids): 59,71,96
    DB $06,$01,$17,$0F,$04,$06             ; +$09 STATS HP=6 MP=1 ATK=23 DEF=15 AGI=4 WIS=6
    DB $01,$01,$01,$00,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=2
    DB $02,$02,$02,$00,$00,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Megante=3
    DB $00,$02,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec9D:                                     ; $5EC0  species $9D
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $23,$06                             ; +$01 maxLvl=35, +$02 expType=6
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1C,$20,$27                         ; +$06 SKILLS (bank84 ids): 28,32,39
    DB $11,$0D,$11,$08,$0B,$04             ; +$09 STATS HP=17 MP=13 ATK=17 DEF=8 AGI=11 WIS=4
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$00,$00,$02,$01,$01,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec9E:                                     ; $5EEB  species $9E
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $23,$05                             ; +$01 maxLvl=35, +$02 expType=5
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3E,$45,$5A                         ; +$06 SKILLS (bank84 ids): 62,69,90
    DB $0E,$08,$0C,$0B,$12,$09             ; +$09 STATS HP=14 MP=8 ATK=12 DEF=11 AGI=18 WIS=9
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$02,$02,$00,$00,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.rec9F:                                     ; $5F16  species $9F
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $32,$0A                             ; +$01 maxLvl=50, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $40,$52,$69                         ; +$06 SKILLS (bank84 ids): 64,82,105
    DB $0F,$11,$0C,$09,$04,$08             ; +$09 STATS HP=15 MP=17 ATK=12 DEF=9 AGI=4 WIS=8
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$02,$02,$01,$01,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=2 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recA0:                                     ; $5F41  species $A0
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $1E,$08                             ; +$01 maxLvl=30, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $26,$2A,$37                         ; +$06 SKILLS (bank84 ids): 38,42,55
    DB $0C,$08,$0F,$14,$01,$0B             ; +$09 STATS HP=12 MP=8 ATK=15 DEF=20 AGI=1 WIS=11
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$03,$02,$00,$00,$03,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=3 Zaki=2 Medapani=3 Megante=2
    DB $00,$00,$03,$03,$03,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recA1:                                     ; $5F6C  species $A1
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $2D,$0D                             ; +$01 maxLvl=45, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $2B,$35,$36                         ; +$06 SKILLS (bank84 ids): 43,53,54
    DB $11,$07,$13,$09,$0C,$08             ; +$09 STATS HP=17 MP=7 ATK=19 DEF=9 AGI=12 WIS=8
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $02,$02,$03,$00,$00,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Medapani=2 Megante=3
    DB $00,$00,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recA2:                                     ; $5F97  species $A2
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $60,$71,$83                         ; +$06 SKILLS (bank84 ids): 96,113,131
    DB $09,$06,$06,$14,$08,$0C             ; +$09 STATS HP=9 MP=6 ATK=6 DEF=20 AGI=8 WIS=12
    DB $00,$00,$00,$00,$00,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=1
    DB $02,$02,$03,$00,$00,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Medapani=2 Megante=3
    DB $00,$01,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA3:                                     ; $5FC2  species $A3
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $28,$08                             ; +$01 maxLvl=40, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $6C,$74,$79                         ; +$06 SKILLS (bank84 ids): 108,116,121
    DB $11,$0D,$10,$08,$0B,$0A             ; +$09 STATS HP=17 MP=13 ATK=16 DEF=8 AGI=11 WIS=10
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$02,$00,$00,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Megante=2
    DB $00,$00,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA4:                                     ; $5FED  species $A4
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $1E,$0A                             ; +$01 maxLvl=30, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $12,$2B,$30                         ; +$06 SKILLS (bank84 ids): 18,43,48
    DB $06,$0A,$0B,$11,$07,$0E             ; +$09 STATS HP=6 MP=10 ATK=11 DEF=17 AGI=7 WIS=14
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$03,$02,$00,$00,$03,$01,$01,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=3 Zaki=2 Medapani=3 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$03,$03,$03,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA5:                                     ; $6018  species $A5
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $23,$0C                             ; +$01 maxLvl=35, +$02 expType=12
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $58,$5A,$5C                         ; +$06 SKILLS (bank84 ids): 88,90,92
    DB $11,$04,$0A,$03,$0F,$09             ; +$09 STATS HP=17 MP=4 ATK=10 DEF=3 AGI=15 WIS=9
    DB $00,$00,$00,$02,$01,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=1 Hyad=1
    DB $02,$02,$02,$00,$00,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA6:                                     ; $6043  species $A6
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $32,$0D                             ; +$01 maxLvl=50, +$02 expType=13
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $6A,$73,$83                         ; +$06 SKILLS (bank84 ids): 106,115,131
    DB $0E,$0C,$0F,$0C,$10,$0A             ; +$09 STATS HP=14 MP=12 ATK=15 DEF=12 AGI=16 WIS=10
    DB $00,$00,$00,$01,$01,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=1
    DB $02,$02,$03,$01,$01,$03,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=3 Megante=3
    DB $00,$00,$02,$02,$02,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recA7:                                     ; $606E  species $A7
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $23,$09                             ; +$01 maxLvl=35, +$02 expType=9
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $09,$24,$36                         ; +$06 SKILLS (bank84 ids): 9,36,54
    DB $10,$13,$13,$0C,$0D,$06             ; +$09 STATS HP=16 MP=19 ATK=19 DEF=12 AGI=13 WIS=6
    DB $00,$00,$00,$03,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=3 Dain=1 Hyad=0
    DB $02,$02,$02,$00,$00,$02,$01,$01,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Medapani=2 Rukani=1 Bomie=1 Megante=2
    DB $00,$00,$02,$02,$02,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA8:                                     ; $6099  species $A8
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $32,$0A                             ; +$01 maxLvl=50, +$02 expType=10
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $4C,$6F,$74                         ; +$06 SKILLS (bank84 ids): 76,111,116
    DB $13,$03,$15,$11,$13,$06             ; +$09 STATS HP=19 MP=3 ATK=21 DEF=17 AGI=19 WIS=6
    DB $00,$00,$00,$01,$01,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=0
    DB $02,$03,$02,$01,$01,$03,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=3 Zaki=2 Mahotora=1 Mahotone=1 Medapani=3 Megante=2
    DB $00,$01,$03,$03,$03,$01,$01,$00,$01,$01,$00  ; +$1F BREATH-RES: Breeze=1 Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recA9:                                     ; $60C4  species $A9
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $32,$10                             ; +$01 maxLvl=50, +$02 expType=16
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $12,$2E,$84                         ; +$06 SKILLS (bank84 ids): 18,46,132
    DB $15,$02,$1A,$13,$0F,$0D             ; +$09 STATS HP=21 MP=2 ATK=26 DEF=19 AGI=15 WIS=13
    DB $01,$01,$01,$02,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=1 Hyad=2
    DB $02,$02,$03,$01,$01,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Megante=3
    DB $00,$02,$02,$03,$02,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 Poison=2 Paralysis=3 Curse=2 Skip=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recAA:                                     ; $60EF  species $AA
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $46,$19                             ; +$01 maxLvl=70, +$02 expType=25
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$0F,$39                         ; +$06 SKILLS (bank84 ids): 9,15,57
    DB $14,$18,$0E,$14,$0F,$1B             ; +$09 STATS HP=20 MP=24 ATK=14 DEF=20 AGI=15 WIS=27
    DB $01,$01,$02,$03,$01,$03             ; +$0F SPELL-RES Mela=1 Gira=1 Io=2 Bagi=3 Dain=1 Hyad=3
    DB $02,$02,$03,$01,$01,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $01,$02,$03,$03,$03,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recAB:                                     ; $611A  species $AB
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $28,$0A                             ; +$01 maxLvl=40, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$45,$4B                         ; +$06 SKILLS (bank84 ids): 6,69,75
    DB $0E,$0D,$11,$0C,$07,$01             ; +$09 STATS HP=14 MP=13 ATK=17 DEF=12 AGI=7 WIS=1
    DB $00,$00,$00,$01,$00,$01             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=0 Hyad=1
    DB $02,$02,$02,$01,$01,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=2 Mahotora=1 Mahotone=1 Medapani=2 Megante=2
    DB $00,$00,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recAC:                                     ; $6145  species $AC
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $3C,$0C                             ; +$01 maxLvl=60, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $1C,$4B,$50                         ; +$06 SKILLS (bank84 ids): 28,75,80
    DB $10,$0B,$12,$0C,$10,$13             ; +$09 STATS HP=16 MP=11 ATK=18 DEF=12 AGI=16 WIS=19
    DB $00,$00,$01,$02,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=2 Dain=0 Hyad=2
    DB $02,$02,$03,$01,$01,$02,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Megante=3
    DB $00,$01,$02,$02,$02,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 Poison=2 Paralysis=2 Curse=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recAD:                                     ; $6170  species $AD
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $50,$14                             ; +$01 maxLvl=80, +$02 expType=20
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$0C,$54                         ; +$06 SKILLS (bank84 ids): 0,12,84
    DB $17,$15,$19,$12,$0F,$14             ; +$09 STATS HP=23 MP=21 ATK=25 DEF=18 AGI=15 WIS=20
    DB $01,$01,$03,$02,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=3 Bagi=2 Dain=1 Hyad=2
    DB $02,$02,$03,$01,$01,$03,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=3 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $01,$02,$03,$03,$03,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recAE:                                     ; $619B  species $AE
    DB $07                                 ; +$00 family=7 (Zombie)
    DB $28,$01                             ; +$01 maxLvl=40, +$02 expType=1
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $29,$75,$7F                         ; +$06 SKILLS (bank84 ids): 41,117,127
    DB $0B,$14,$01,$02,$15,$05             ; +$09 STATS HP=11 MP=20 ATK=1 DEF=2 AGI=21 WIS=5
    DB $00,$00,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $02,$02,$03,$00,$00,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Medapani=2 Megante=2
    DB $00,$00,$02,$03,$02,$01,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Poison=2 Paralysis=3 Curse=2 Skip=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

    ; --- family 8 (Material) begins ---
.recAF:                                     ; $61C6  species $AF
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0C                             ; +$01 maxLvl=40, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $03,$17,$19                         ; +$06 SKILLS (bank84 ids): 3,23,25
    DB $0D,$0B,$09,$12,$11,$0F             ; +$09 STATS HP=13 MP=11 ATK=9 DEF=18 AGI=17 WIS=15
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $01,$01,$03,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recB0:                                     ; $61F1  species $B0
    DB $08                                 ; +$00 family=8 (Material)
    DB $32,$0E                             ; +$01 maxLvl=50, +$02 expType=14
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $35,$38,$60                         ; +$06 SKILLS (bank84 ids): 53,56,96
    DB $0E,$0F,$11,$0C,$09,$0D             ; +$09 STATS HP=14 MP=15 ATK=17 DEF=12 AGI=9 WIS=13
    DB $01,$01,$01,$00,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=2
    DB $00,$00,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Megante=3
    DB $01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recB1:                                     ; $621C  species $B1
    DB $08                                 ; +$00 family=8 (Material)
    DB $23,$0A                             ; +$01 maxLvl=35, +$02 expType=10
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$56,$7E                         ; +$06 SKILLS (bank84 ids): 0,86,126
    DB $0C,$0A,$0E,$06,$11,$0C             ; +$09 STATS HP=12 MP=10 ATK=14 DEF=6 AGI=17 WIS=12
    DB $02,$02,$00,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=0 Bagi=0 Dain=0 Hyad=0
    DB $00,$00,$02,$00,$00,$00,$01,$01,$02,$00   ; +$15 STATUS-RES: Zaki=2 Rukani=1 Bomie=1 Megante=2
    DB $02,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recB2:                                     ; $6247  species $B2
    DB $08                                 ; +$00 family=8 (Material)
    DB $23,$08                             ; +$01 maxLvl=35, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $34,$35,$8F                         ; +$06 SKILLS (bank84 ids): 52,53,143
    DB $10,$0D,$05,$0E,$0E,$07             ; +$09 STATS HP=16 MP=13 ATK=5 DEF=14 AGI=14 WIS=7
    DB $00,$00,$00,$01,$01,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Megante=2
    DB $00,$02,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Breeze=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recB3:                                     ; $6272  species $B3
    DB $08                                 ; +$00 family=8 (Material)
    DB $32,$0C                             ; +$01 maxLvl=50, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $09,$14,$95                         ; +$06 SKILLS (bank84 ids): 9,20,149
    DB $08,$17,$0B,$0C,$03,$13             ; +$09 STATS HP=8 MP=23 ATK=11 DEF=12 AGI=3 WIS=19
    DB $00,$00,$00,$01,$01,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=1 Dain=1 Hyad=2
    DB $00,$00,$02,$01,$01,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=1 Mahotone=1 Megante=2
    DB $00,$02,$00,$00,$00,$01,$01,$01,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 Skip=1 Dance=1 StopBreath=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recB4:                                     ; $629D  species $B4
    DB $08                                 ; +$00 family=8 (Material)
    DB $1E,$08                             ; +$01 maxLvl=30, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $14,$42,$D6                         ; +$06 SKILLS (bank84 ids): 20,66,214
    DB $09,$0D,$0E,$11,$07,$0B             ; +$09 STATS HP=9 MP=13 ATK=14 DEF=17 AGI=7 WIS=11
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $00,$01,$02,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Medapani=1 Megante=2
    DB $00,$02,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Breeze=2 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recB5:                                     ; $62C8  species $B5
    DB $08                                 ; +$00 family=8 (Material)
    DB $2D,$0E                             ; +$01 maxLvl=45, +$02 expType=14
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $27,$29,$38                         ; +$06 SKILLS (bank84 ids): 39,41,56
    DB $0F,$0B,$08,$06,$0B,$13             ; +$09 STATS HP=15 MP=11 ATK=8 DEF=6 AGI=11 WIS=19
    DB $01,$01,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $00,$00,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Megante=3
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recB6:                                     ; $62F3  species $B6
    DB $08                                 ; +$00 family=8 (Material)
    DB $2D,$0C                             ; +$01 maxLvl=45, +$02 expType=12
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $2B,$40,$48                         ; +$06 SKILLS (bank84 ids): 43,64,72
    DB $0E,$04,$14,$15,$0A,$0D             ; +$09 STATS HP=14 MP=4 ATK=20 DEF=21 AGI=10 WIS=13
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $01,$01,$03,$00,$00,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Medapani=1 Megante=3
    DB $00,$02,$01,$01,$01,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 Poison=1 Paralysis=1 Curse=1 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recB7:                                     ; $631E  species $B7
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$08                             ; +$01 maxLvl=40, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $52,$7B,$8C                         ; +$06 SKILLS (bank84 ids): 82,123,140
    DB $08,$0D,$0B,$0E,$07,$04             ; +$09 STATS HP=8 MP=13 ATK=11 DEF=14 AGI=7 WIS=4
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Megante=2
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recB8:                                     ; $6349  species $B8
    DB $08                                 ; +$00 family=8 (Material)
    DB $23,$0B                             ; +$01 maxLvl=35, +$02 expType=11
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $18,$19,$1C                         ; +$06 SKILLS (bank84 ids): 24,25,28
    DB $0E,$11,$0C,$0C,$08,$0E             ; +$09 STATS HP=14 MP=17 ATK=12 DEF=12 AGI=8 WIS=14
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $00,$01,$02,$00,$00,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Medapani=1 Megante=2
    DB $00,$02,$02,$02,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Breeze=2 Poison=2 Paralysis=2 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recB9:                                     ; $6374  species $B9
    DB $08                                 ; +$00 family=8 (Material)
    DB $2D,$0F                             ; +$01 maxLvl=45, +$02 expType=15
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $3F,$5B,$72                         ; +$06 SKILLS (bank84 ids): 63,91,114
    DB $12,$0D,$14,$17,$09,$0A             ; +$09 STATS HP=18 MP=13 ATK=20 DEF=23 AGI=9 WIS=10
    DB $01,$01,$01,$00,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=0 Dain=0 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=2 Megante=3
    DB $01,$03,$02,$02,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=3 Poison=2 Paralysis=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recBA:                                     ; $639F  species $BA
    DB $08                                 ; +$00 family=8 (Material)
    DB $23,$0D                             ; +$01 maxLvl=35, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $06,$0F,$4F                         ; +$06 SKILLS (bank84 ids): 6,15,79
    DB $15,$0B,$17,$15,$12,$13             ; +$09 STATS HP=21 MP=11 ATK=23 DEF=21 AGI=18 WIS=19
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $01,$01,$02,$01,$01,$01,$01,$01,$02,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=2 Madante=1
    DB $00,$02,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Breeze=2 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recBB:                                     ; $63CA  species $BB
    DB $08                                 ; +$00 family=8 (Material)
    DB $1E,$0B                             ; +$01 maxLvl=30, +$02 expType=11
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $1A,$4C,$69                         ; +$06 SKILLS (bank84 ids): 26,76,105
    DB $08,$03,$09,$0B,$0C,$06             ; +$09 STATS HP=8 MP=3 ATK=9 DEF=11 AGI=12 WIS=6
    DB $00,$00,$01,$01,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=1 Dain=0 Hyad=2
    DB $00,$01,$02,$01,$01,$01,$00,$00,$02,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=2 Mahotora=1 Mahotone=1 Medapani=1 Megante=2
    DB $00,$02,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Breeze=2 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recBC:                                     ; $63F5  species $BC
    DB $08                                 ; +$00 family=8 (Material)
    DB $32,$09                             ; +$01 maxLvl=50, +$02 expType=9
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $1E,$22,$25                         ; +$06 SKILLS (bank84 ids): 30,34,37
    DB $0C,$12,$09,$13,$0D,$0F             ; +$09 STATS HP=12 MP=18 ATK=9 DEF=19 AGI=13 WIS=15
    DB $00,$00,$00,$02,$01,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=1 Hyad=2
    DB $00,$00,$02,$01,$01,$00,$00,$00,$02,$00   ; +$15 STATUS-RES: Zaki=2 Mahotora=1 Mahotone=1 Megante=2
    DB $00,$02,$00,$00,$00,$02,$02,$02,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 Skip=2 Dance=2 StopBreath=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recBD:                                     ; $6420  species $BD
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0D                             ; +$01 maxLvl=40, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $50,$55,$57                         ; +$06 SKILLS (bank84 ids): 80,85,87
    DB $0C,$05,$15,$16,$18,$11             ; +$09 STATS HP=12 MP=5 ATK=21 DEF=22 AGI=24 WIS=17
    DB $01,$01,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $01,$02,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=2 Zaki=3 Megante=3
    DB $01,$02,$02,$02,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=2 Paralysis=2 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.recBE:                                     ; $644B  species $BE
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $12,$15,$3F                         ; +$06 SKILLS (bank84 ids): 18,21,63
    DB $12,$13,$0F,$12,$09,$13             ; +$09 STATS HP=18 MP=19 ATK=15 DEF=18 AGI=9 WIS=19
    DB $00,$00,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $02,$02,$03,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $03                                 ; +$2A rank=3

.recBF:                                     ; $6476  species $BF
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$09                             ; +$01 maxLvl=40, +$02 expType=9
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $43,$5C,$60                         ; +$06 SKILLS (bank84 ids): 67,92,96
    DB $0D,$0F,$0B,$0E,$14,$12             ; +$09 STATS HP=13 MP=15 ATK=11 DEF=14 AGI=20 WIS=18
    DB $00,$00,$00,$02,$01,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=0 Bagi=2 Dain=1 Hyad=2
    DB $00,$00,$02,$00,$00,$00,$00,$01,$02,$00   ; +$15 STATUS-RES: Zaki=2 Bomie=1 Megante=2
    DB $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=2 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recC0:                                     ; $64A1  species $C0
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0D                             ; +$01 maxLvl=40, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $00,$5C,$88                         ; +$06 SKILLS (bank84 ids): 0,92,136
    DB $12,$0C,$11,$18,$04,$07             ; +$09 STATS HP=18 MP=12 ATK=17 DEF=24 AGI=4 WIS=7
    DB $03,$03,$01,$02,$00,$01             ; +$0F SPELL-RES Mela=3 Gira=3 Io=1 Bagi=2 Dain=0 Hyad=1
    DB $00,$00,$03,$00,$00,$01,$00,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Medapani=1 Megante=3
    DB $03,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recC1:                                     ; $64CC  species $C1
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0D                             ; +$01 maxLvl=40, +$02 expType=13
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $0C,$60,$8E                         ; +$06 SKILLS (bank84 ids): 12,96,142
    DB $10,$06,$12,$18,$04,$07             ; +$09 STATS HP=16 MP=6 ATK=18 DEF=24 AGI=4 WIS=7
    DB $01,$01,$01,$02,$00,$03             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=0 Hyad=3
    DB $00,$00,$03,$00,$00,$00,$01,$00,$03,$00   ; +$15 STATUS-RES: Zaki=3 Rukani=1 Megante=3
    DB $01,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recC2:                                     ; $64F7  species $C2
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$0B                             ; +$01 maxLvl=40, +$02 expType=11
    DB $02,$01,$00                         ; +$03 gender=2, flight=1, metal=0
    DB $00,$12,$37                         ; +$06 SKILLS (bank84 ids): 0,18,55
    DB $19,$0A,$14,$0C,$01,$14             ; +$09 STATS HP=25 MP=10 ATK=20 DEF=12 AGI=1 WIS=20
    DB $00,$00,$01,$02,$01,$02             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=2 Dain=1 Hyad=2
    DB $01,$01,$03,$01,$01,$01,$01,$01,$03,$01   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3 Madante=1
    DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recC3:                                     ; $6522  species $C3
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$08                             ; +$01 maxLvl=40, +$02 expType=8
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $75,$77,$94                         ; +$06 SKILLS (bank84 ids): 117,119,148
    DB $0C,$03,$0D,$0E,$01,$0F             ; +$09 STATS HP=12 MP=3 ATK=13 DEF=14 AGI=1 WIS=15
    DB $00,$00,$01,$01,$00,$03             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=1 Dain=0 Hyad=3
    DB $01,$00,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Zaki=3 Megante=3
    DB $00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; +$1F BREATH-RES: Breeze=3 (+pad $29=0)
    DB $04                                 ; +$2A rank=4

.recC4:                                     ; $654D  species $C4
    DB $08                                 ; +$00 family=8 (Material)
    DB $28,$12                             ; +$01 maxLvl=40, +$02 expType=18
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $41,$56,$8E                         ; +$06 SKILLS (bank84 ids): 65,86,142
    DB $11,$04,$0C,$15,$04,$06             ; +$09 STATS HP=17 MP=4 ATK=12 DEF=21 AGI=4 WIS=6
    DB $00,$00,$01,$01,$00,$03             ; +$0F SPELL-RES Mela=0 Gira=0 Io=1 Bagi=1 Dain=0 Hyad=3
    DB $01,$01,$03,$00,$00,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Megante=3
    DB $00,$03,$00,$00,$00,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Breeze=3 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.recC5:                                     ; $6578  species $C5
    DB $08                                 ; +$00 family=8 (Material)
    DB $32,$0F                             ; +$01 maxLvl=50, +$02 expType=15
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $88,$8F,$93                         ; +$06 SKILLS (bank84 ids): 136,143,147
    DB $18,$0A,$17,$18,$01,$0E             ; +$09 STATS HP=24 MP=10 ATK=23 DEF=24 AGI=1 WIS=14
    DB $01,$01,$01,$01,$00,$03             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=0 Hyad=3
    DB $01,$01,$03,$00,$01,$00,$00,$00,$03,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=3 Mahotone=1 Megante=3
    DB $01,$03,$00,$02,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=3 Paralysis=2 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recC6:                                     ; $65A3  species $C6
    DB $08                                 ; +$00 family=8 (Material)
    DB $32,$0E                             ; +$01 maxLvl=50, +$02 expType=14
    DB $02,$00,$00                         ; +$03 gender=2, flight=0, metal=0
    DB $14,$32,$93                         ; +$06 SKILLS (bank84 ids): 20,50,147
    DB $0F,$0B,$11,$14,$00,$0D             ; +$09 STATS HP=15 MP=11 ATK=17 DEF=20 AGI=0 WIS=13
    DB $01,$01,$00,$00,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=0 Dain=0 Hyad=2
    DB $00,$01,$03,$01,$01,$01,$01,$01,$03,$00   ; +$15 STATUS-RES: Rariho=1 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1 Megante=3
    DB $01,$02,$01,$01,$01,$00,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=1 Paralysis=1 Curse=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $05                                 ; +$2A rank=5

.recC7:                                     ; $65CE  species $C7
    DB $08                                 ; +$00 family=8 (Material)
    DB $50,$12                             ; +$01 maxLvl=80, +$02 expType=18
    DB $01,$00,$00                         ; +$03 gender=1, flight=0, metal=0
    DB $65,$81,$84                         ; +$06 SKILLS (bank84 ids): 101,129,132
    DB $18,$15,$18,$1B,$11,$17             ; +$09 STATS HP=24 MP=21 ATK=24 DEF=27 AGI=17 WIS=23
    DB $02,$02,$02,$02,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=1 Hyad=2
    DB $03,$03,$03,$03,$03,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $02,$02,$03,$03,$03,$02,$02,$02,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=2 Dance=2 StopBreath=2 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

    ; --- family 9 (???) begins ---
.recC8:                                     ; $65F9  species $C8
    DB $09                                 ; +$00 family=9 (???)
    DB $32,$18                             ; +$01 maxLvl=50, +$02 expType=24
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $03,$93,$D5                         ; +$06 SKILLS (bank84 ids): 3,147,213
    DB $14,$1E,$15,$14,$17,$17             ; +$09 STATS HP=20 MP=30 ATK=21 DEF=20 AGI=23 WIS=23
    DB $01,$01,$00,$00,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=0 Bagi=0 Dain=0 Hyad=1
    DB $03,$03,$03,$02,$03,$03,$03,$03,$03,$00   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3
    DB $01,$01,$03,$02,$03,$03,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recC9:                                     ; $6624  species $C9
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$19                             ; +$01 maxLvl=80, +$02 expType=25
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $3F,$5C,$81                         ; +$06 SKILLS (bank84 ids): 63,92,129
    DB $15,$1E,$18,$15,$17,$15             ; +$09 STATS HP=21 MP=30 ATK=24 DEF=21 AGI=23 WIS=21
    DB $02,$02,$01,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=1 Bagi=1 Dain=1 Hyad=2
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $02,$02,$03,$03,$03,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCA:                                     ; $664F  species $CA
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$18                             ; +$01 maxLvl=70, +$02 expType=24
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $03,$06,$84                         ; +$06 SKILLS (bank84 ids): 3,6,132
    DB $13,$1E,$14,$15,$17,$17             ; +$09 STATS HP=19 MP=30 ATK=20 DEF=21 AGI=23 WIS=23
    DB $01,$01,$01,$01,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=0 Hyad=1
    DB $03,$03,$03,$02,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $00,$00,$03,$02,$03,$03,$03,$03,$02,$00,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCB:                                     ; $667A  species $CB
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$19                             ; +$01 maxLvl=80, +$02 expType=25
    DB $00,$01,$00                         ; +$03 gender=0, flight=1, metal=0
    DB $5C,$60,$64                         ; +$06 SKILLS (bank84 ids): 92,96,100
    DB $18,$1E,$18,$15,$17,$17             ; +$09 STATS HP=24 MP=30 ATK=24 DEF=21 AGI=23 WIS=23
    DB $01,$01,$01,$01,$01,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=1 Hyad=1
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $00,$00,$03,$03,$03,$03,$03,$03,$02,$01,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCC:                                     ; $66A5  species $CC
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$18                             ; +$01 maxLvl=70, +$02 expType=24
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $06,$5B,$64                         ; +$06 SKILLS (bank84 ids): 6,91,100
    DB $14,$1E,$14,$14,$16,$15             ; +$09 STATS HP=20 MP=30 ATK=20 DEF=20 AGI=22 WIS=21
    DB $01,$01,$01,$02,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=2 Dain=0 Hyad=2
    DB $03,$03,$03,$02,$03,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $01,$01,$03,$03,$03,$03,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCD:                                     ; $66D0  species $CD
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$19                             ; +$01 maxLvl=80, +$02 expType=25
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $60,$65,$80                         ; +$06 SKILLS (bank84 ids): 96,101,128
    DB $18,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=24 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $01,$02,$03,$03,$01,$03             ; +$0F SPELL-RES Mela=1 Gira=2 Io=3 Bagi=3 Dain=1 Hyad=3
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=2
    DB $02,$02,$03,$03,$03,$03,$03,$03,$02,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCE:                                     ; $66FB  species $CE
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$18                             ; +$01 maxLvl=70, +$02 expType=24
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $50,$5C,$64                         ; +$06 SKILLS (bank84 ids): 80,92,100
    DB $15,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=21 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $01,$01,$01,$01,$00,$02             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=1 Dain=0 Hyad=2
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $00,$00,$03,$03,$03,$03,$03,$03,$02,$01,$00  ; +$1F BREATH-RES: Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recCF:                                     ; $6726  species $CF
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$1F                             ; +$01 maxLvl=80, +$02 expType=31
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $57,$80,$D9                         ; +$06 SKILLS (bank84 ids): 87,128,217
    DB $1D,$1E,$1A,$18,$17,$17             ; +$09 STATS HP=29 MP=30 ATK=26 DEF=24 AGI=23 WIS=23
    DB $01,$02,$02,$02,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=2 Dain=0 Hyad=1
    DB $03,$03,$03,$03,$03,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $02,$01,$03,$02,$03,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=2 Breeze=1 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD0:                                     ; $6751  species $D0
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$1E                             ; +$01 maxLvl=70, +$02 expType=30
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$06,$0F                         ; +$06 SKILLS (bank84 ids): 0,6,15
    DB $15,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=21 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $02,$02,$02,$01,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=2 Hyad=2
    DB $03,$03,$03,$02,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $01,$02,$03,$02,$03,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD1:                                     ; $677C  species $D1
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$1F                             ; +$01 maxLvl=80, +$02 expType=31
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $43,$5C,$80                         ; +$06 SKILLS (bank84 ids): 67,92,128
    DB $1D,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=29 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $02,$02,$02,$00,$00,$00             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=0
    DB $03,$03,$03,$03,$03,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $03,$01,$03,$03,$03,$03,$03,$03,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Breeze=1 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD2:                                     ; $67A7  species $D2
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$1C                             ; +$01 maxLvl=70, +$02 expType=28
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $5C,$60,$6C                         ; +$06 SKILLS (bank84 ids): 92,96,108
    DB $15,$1E,$1A,$18,$17,$17             ; +$09 STATS HP=21 MP=30 ATK=26 DEF=24 AGI=23 WIS=23
    DB $01,$01,$01,$03,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=1 Bagi=3 Dain=0 Hyad=1
    DB $03,$03,$03,$02,$03,$03,$02,$03,$03,$00   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=2 Bomie=3 Megante=3
    DB $03,$03,$03,$02,$03,$03,$03,$03,$00,$00,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD3:                                     ; $67D2  species $D3
    DB $09                                 ; +$00 family=9 (???)
    DB $3C,$1B                             ; +$01 maxLvl=60, +$02 expType=27
    DB $00,$01,$00                         ; +$03 gender=0, flight=1, metal=0
    DB $64,$65,$84                         ; +$06 SKILLS (bank84 ids): 100,101,132
    DB $15,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=21 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $01,$02,$02,$01,$01,$02             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=2
    DB $03,$03,$03,$02,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $01,$02,$03,$02,$03,$03,$03,$03,$01,$00,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD4:                                     ; $67FD  species $D4
    DB $09                                 ; +$00 family=9 (???)
    DB $46,$1D                             ; +$01 maxLvl=70, +$02 expType=29
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $3C,$5C,$82                         ; +$06 SKILLS (bank84 ids): 60,92,130
    DB $18,$1E,$1A,$15,$17,$17             ; +$09 STATS HP=24 MP=30 ATK=26 DEF=21 AGI=23 WIS=23
    DB $02,$02,$02,$01,$01,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=1 Dain=1 Hyad=2
    DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=3 Bomie=3 Megante=3 Madante=1
    DB $01,$02,$03,$02,$03,$03,$03,$03,$02,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=3 Paralysis=2 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=2 Gigaslash=1 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD5:                                     ; $6828  species $D5
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$1F                             ; +$01 maxLvl=80, +$02 expType=31
    DB $00,$01,$00                         ; +$03 gender=0, flight=1, metal=0
    DB $54,$65,$80                         ; +$06 SKILLS (bank84 ids): 84,101,128
    DB $1D,$1E,$1E,$18,$17,$17             ; +$09 STATS HP=29 MP=30 ATK=30 DEF=24 AGI=23 WIS=23
    DB $02,$02,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $03,$03,$03,$03,$03,$03,$02,$02,$03,$01   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=3 Mahotone=3 Medapani=3 Rukani=2 Bomie=2 Megante=3 Madante=1
    DB $02,$02,$03,$03,$03,$03,$03,$03,$03,$02,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=2 (+pad $29=0)
    DB $06                                 ; +$2A rank=6

.recD6:                                     ; $6853  species $D6
    DB $09                                 ; +$00 family=9 (???)
    DB $50,$1E                             ; +$01 maxLvl=80, +$02 expType=30
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $0F,$5C,$60                         ; +$06 SKILLS (bank84 ids): 15,92,96
    DB $1F,$1E,$1F,$18,$17,$17             ; +$09 STATS HP=31 MP=30 ATK=31 DEF=24 AGI=23 WIS=23
    DB $02,$02,$02,$02,$02,$03             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=3
    DB $03,$03,$02,$02,$03,$03,$02,$03,$03,$02   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=2 Mahotora=2 Mahotone=3 Medapani=3 Rukani=2 Bomie=3 Megante=3 Madante=2
    DB $02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$00  ; +$1F BREATH-RES: Frame=2 Breeze=2 Poison=3 Paralysis=3 Curse=3 Skip=3 Dance=3 StopBreath=3 CallOut=3 Gigaslash=3 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recD7:                                     ; $687E  species $D7
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$00,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=0 DEF=0 AGI=0 WIS=0
    DB $01,$02,$01,$01,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=2 Io=1 Bagi=1 Dain=0 Hyad=1
    DB $02,$03,$03,$01,$01,$02,$00,$00,$02,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=3 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Megante=2
    DB $01,$01,$00,$03,$00,$01,$00,$00,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Paralysis=3 Skip=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recD8:                                     ; $68A9  species $D8
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$00,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=0 DEF=0 AGI=0 WIS=0
    DB $01,$01,$02,$02,$03,$01             ; +$0F SPELL-RES Mela=1 Gira=1 Io=2 Bagi=2 Dain=3 Hyad=1
    DB $01,$01,$01,$01,$01,$01,$01,$01,$00,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=1 Mahotora=1 Mahotone=1 Medapani=1 Rukani=1 Bomie=1
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=1 Poison=1 Paralysis=1 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recD9:                                     ; $68D4  species $D9
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$00,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=0 DEF=0 AGI=0 WIS=0
    DB $03,$02,$02,$00,$00,$01             ; +$0F SPELL-RES Mela=3 Gira=2 Io=2 Bagi=0 Dain=0 Hyad=1
    DB $01,$01,$02,$01,$00,$01,$01,$01,$00,$00   ; +$15 STATUS-RES: Manusa=1 Rariho=1 Zaki=2 Mahotora=1 Medapani=1 Rukani=1 Bomie=1
    DB $03,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=3 Poison=1 Paralysis=1 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recDA:                                     ; $68FF  species $DA
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$00,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=0 DEF=0 AGI=0 WIS=0
    DB $01,$02,$01,$03,$00,$01             ; +$0F SPELL-RES Mela=1 Gira=2 Io=1 Bagi=3 Dain=0 Hyad=1
    DB $02,$02,$03,$01,$01,$01,$00,$01,$00,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=1 Bomie=1
    DB $01,$02,$01,$01,$01,$01,$01,$01,$01,$01,$00  ; +$1F BREATH-RES: Frame=1 Breeze=2 Poison=1 Paralysis=1 Curse=1 Skip=1 Dance=1 StopBreath=1 CallOut=1 Gigaslash=1 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recDB:                                     ; $692A  species $DB
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$00,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=0 DEF=0 AGI=0 WIS=0
    DB $01,$02,$02,$01,$02,$03             ; +$0F SPELL-RES Mela=1 Gira=2 Io=2 Bagi=1 Dain=2 Hyad=3
    DB $03,$03,$03,$02,$02,$02,$02,$02,$01,$00   ; +$15 STATUS-RES: Manusa=3 Rariho=3 Zaki=3 Mahotora=2 Mahotone=2 Medapani=2 Rukani=2 Bomie=2 Megante=1
    DB $01,$03,$02,$02,$02,$02,$02,$02,$02,$02,$00  ; +$1F BREATH-RES: Frame=1 Breeze=3 Poison=2 Paralysis=2 Curse=2 Skip=2 Dance=2 StopBreath=2 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $07                                 ; +$2A rank=7

.recDC:                                     ; $6955  species $DC
    DB $09                                 ; +$00 family=9 (???)
    DB $00,$00                             ; +$01 maxLvl=0, +$02 expType=0
    DB $00,$00,$00                         ; +$03 gender=0, flight=0, metal=0
    DB $00,$00,$00                         ; +$06 SKILLS (bank84 ids): 0,0,0
    DB $00,$00,$14,$00,$00,$00             ; +$09 STATS HP=0 MP=0 ATK=20 DEF=0 AGI=0 WIS=0
    DB $02,$02,$02,$02,$02,$02             ; +$0F SPELL-RES Mela=2 Gira=2 Io=2 Bagi=2 Dain=2 Hyad=2
    DB $02,$02,$03,$01,$01,$02,$02,$01,$01,$00   ; +$15 STATUS-RES: Manusa=2 Rariho=2 Zaki=3 Mahotora=1 Mahotone=1 Medapani=2 Rukani=2 Bomie=1 Megante=1
    DB $03,$03,$02,$03,$02,$02,$01,$01,$02,$02,$00  ; +$1F BREATH-RES: Frame=3 Breeze=3 Poison=2 Paralysis=3 Curse=2 Skip=2 Dance=1 StopBreath=1 CallOut=2 Gigaslash=2 (+pad $29=0)
    DB $07                                 ; +$2A rank=7





; ============================================================================
; Bank3_Fn2  ($6980)  — Monster stat copy (DA5E region)
; ============================================================================
; Similar structure to fn1 but uses $DA5E region (12 bytes) and
; $DA5E index ($0C stride).
; Called for secondary monster statistics (speed, resistance, etc.).
Bank3_Fn2:                                  ; $6980
    LD DE,$DA62                            ; destination
    CALL $6987                             ; Sub_6987: indexed copy
    RET

Bank3_Sub_6987:                             ; $6987
    PUSH DE
    LD A,($DA5E)                           ; secondary monster index
    LD C,$0C                               ; record stride = 12 bytes
    CALL $218D                             ; indexed table lookup
    LD A,L
    ADD A,$DA
    LD L,A
    LD A,H
    ADC A,$71
    LD H,A                                 ; HL = $71DA + index*$0C (table base)
    POP DE
    LD B,$0C                               ; copy 12 bytes
$6999:
    LD A,(HL+)
    LD (DE),A
    INC DE
    DEC B
    JR NZ,$6999
    RET

; ============================================================================
; Bank3_Fn3  ($69A2)  — Trade/exchange sequencer A  (44-state machine)
; ============================================================================
; Guard: if wTradeIdx ($DA5E) == $FF → RET (no monster selected / idle).
; Otherwise RST $00-dispatches on $DA5E (0..43) — one step per monster
; index — through a 44-entry jump table at $69AC.
;
; This is the visual/logic half of a monster exchange: each state draws or
; advances one stage of the "offer a monster / see partner's monster /
; confirm" flow. Notable entries:
;   state 0  ($6A04)  RET (no-op / index 0 reserved)
;   states 1-2 ($6A05) coordinate math on $DA60 via ROM0 $261E (screen
;                      position lookup) — position the monster sprite
;   states 3-4 ($6A2C) …
;   states 19-23 all → $6C48 ; states 24-30 all → $6C4C  (shared handlers
;                      for ranges of indices — grouped monster classes)
;   state 43 ($6DEA)  final stage
; The many single-entry states $6B29..$6DEA are per-stage draw routines.
; (Full bodies are in the raw disassembly; they are display steps that
;  read $DA60 and blit via ROM0 $261E / $26xx helpers.)
Bank3_Fn3:                                  ; $69A2
    LD A,($DA5E)                           ; wTradeIdx
    CP $FF
    RET Z                                  ; idle → nothing to do
    LD A,($DA5E)
    RST $00                                ; dispatch on $DA5E (0-43)
    ; RST $00 jump table at $69AC — 44 entries (see raw disassembly).


; ============================================================================
; Bank3_Fn4  ($6E24)  — Trade/exchange sequencer B  (44-state machine)
; ============================================================================
; Same shape as fn3 (guard on $DA5E==$FF, then a 44-entry RST $00 table at
; $6E31), but FIRST calls fn2 ($6980) to refresh the 12-byte secondary
; stat record for the current monster before dispatching. Where fn3 drives
; the on-screen presentation, fn4 is the data/stat half of the same step —
; the two are called in tandem, once per frame, keyed on the same $DA5E.
;   states 19-21 → $7015 ; states 24-31 → $7050..$705A (grouped handlers)
Bank3_Fn4:                                  ; $6E24
    LD A,($DA5E)                           ; wTradeIdx
    CP $FF
    RET Z
    CALL $6980                             ; fn2: reload secondary stats ($DA62)
    LD A,($DA5E)
    RST $00                                ; dispatch on $DA5E (0-43)
    ; RST $00 jump table at $6E31 — 44 entries (see raw disassembly).


; ============================================================================
; Offered-monster list helpers (fn5-fn8)  — list at $CA51, 20 bytes
; ============================================================================
; $CA51 holds up to 20 monster indices the player has flagged to trade.
; $00 and $FF are both treated as "empty slot" markers. $DA5E is the
; "current" monster index being added/removed.

; ---- Bank3_Fn5 ($7160) — rebuild & compact the list -----------------------
; Copies 20 bytes from the master copy $C0D8 into $CA51, wipes $CA51 to
; $FF, then walks the copy and writes back only the non-$00/$FF entries,
; packed from the start. Net effect: remove holes so active entries are
; contiguous. Called after any removal (fn7/fn8).
Bank3_Fn5:                                  ; $7160
    LD HL,$C0D8                            ; master copy (src)
    LD DE,$CA51                            ; working list (dst)
    LD B,$14                               ; 20 bytes
$7168:
    LD A,(DE)
    LDI (HL),A                             ; snapshot list → $C0D8
    INC DE
    DEC B
    JR NZ,$7168
    LD HL,$CA51
    LD BC,$0014
    LD A,$FF
    CALL $169A                             ; wipe $CA51 to $FF
    LD HL,$C0D8                            ; re-read snapshot
    LD DE,$CA51
    LD B,$14
$7181:
    LDI A,(HL)
    CP $FF
    JR Z,$718C                             ; skip empty
    CP $00
    JR Z,$718C                             ; skip empty
    LD (DE),A                              ; keep active entry (packed)
    INC DE
$718C:
    DEC B
    JR NZ,$7181
    RET

; ---- Bank3_Fn6 ($7190) — append current monster to the list ---------------
; If $DA5E is 0 or $FF (no selection) → RET. Otherwise scan $CA51 for the
; first empty ($00/$FF) slot and store $DA5E there. If the list is full
; (no empty slot found), set $DA5E=$FF to signal failure.
Bank3_Fn6:                                  ; $7190
    LD A,($DA5E)
    CP $00
    RET Z
    CP $FF
    RET Z
    LD HL,$CA51
    LD B,$14
$719E:
    LD A,(HL)
    CP $00
    JR Z,$71B1                             ; found empty slot
    CP $FF
    JR Z,$71B1
    INC HL
    DEC B
    JR NZ,$719E
    LD A,$FF
    LD ($DA5E),A                           ; list full → fail
    RET
$71B1:
    LD A,($DA5E)
    LD (HL),A                              ; store index in the slot
    RET

; ---- Bank3_Fn7 ($71B6) — remove current monster, then recompact -----------
; Scan $CA51 for an entry equal to $DA5E; if found, mark it $FF and call
; fn5 to recompact. If not present, set $DA5E=$FF (nothing removed).
Bank3_Fn7:                                  ; $71B6
    LD A,($DA5E)
    CP $00
    RET Z
    CP $FF
    RET Z
    LD HL,$CA51
    LD B,$14
$71C4:
    LD A,($DA5E)
    CP (HL)
    JR Z,$71D4                             ; found it
    INC HL
    DEC B
    JR NZ,$71C4
    LD A,$FF
    LD ($DA5E),A                           ; not found
    RET
$71D4:
    LD (HL),$FF                            ; clear the slot
    CALL $7160                             ; fn5: recompact
    RET

; ---- Bank3_Fn8 ($7134) — conditional removal (capacity/price check) -------
; Reads a 16-bit value from $C899:C89A (via ROM0 $16A3), scales it by $64
; (ROM0 $21DC), and compares against $DA65. If the scaled value is >=
; $DA65 (RET NC) it does nothing. Otherwise it removes the current entry:
; set $DA5E=$FF, mark the $CA51 slot addressed by $DA5F as $FF, and call
; fn5 to recompact. (Looks like a "can't afford / over capacity → drop the
; offer" guard used during the trade negotiation.)
Bank3_Fn8:                                  ; $7134
    CALL $16A3                             ; ROM0: fetch 16-bit value → $C899:C89A
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    LD A,$64
    CALL $21DC                             ; ROM0: HL = HL * $64 (or /$64 scale)
    LD HL,$DA65
    CP (HL)
    RET NC                                 ; value >= $DA65 → keep, done
    LD A,$FF
    LD ($DA5E),A                           ; drop current monster
    LD A,($DA5F)                           ; slot index into list
    LD HL,$CA51
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF                            ; clear that slot
    CALL $7160                             ; fn5: recompact
    RET


; ============================================================================
; ROM DATA / REFERENCE
; ============================================================================
; RST $00 jump tables in this bank (all "DW target" arrays):
;   $4024  fn0 sub-state table       — 4 entries  ($402C/$414D/$4182/$41B7)
;   $4162  fn0 state-1 inner table   — 2 entries  ($4166/$416A)
;   $4197  fn0 state-2 inner table   — 2 entries  ($419B/$419F)
;   $41CC  fn0 state-3 inner table   — 2 entries  ($41D0/$41D4)
;   $69AC  fn3 sequencer table       — 44 entries
;   $6E31  fn4 sequencer table       — 44 entries
;
; ROM0 helpers used here:
;   $15F3  serial I/O tick — fires SC start bit, advances the transfer
;   $218D  indexed table lookup (A=index, C=stride → HL = &record)
;   $21DC  16-bit scale/multiply helper (used by fn8's price check)
;   $261E  screen/coordinate lookup (fn3 sprite positioning)
;   $2581  serial init / connect helper (called under DI in fn0 commit)
;   $16A3  fetch 16-bit value into $C899:C89A
;
; Monster data layout:
;   $DA31: monster list index (used by fn1 to select the species record)
;   $DA33: 43-byte ($2B) primary monster record (species, stats, name)
;   $DA62: 12-byte ($0C) secondary record (speed, resistances, etc.),
;          loaded by fn2 from record index $DA5E
;   $CA51: 20-byte "offered monsters" list managed by fn5-fn8
;
; Cross-bank hand-off (once handshake settles in fn0):
;   $C865==1 → bank80 fn2 (battle),  ==2 → bank21 fn2,  ==3 → bank21 fn3
;
; Note: bank3 writes wGameState=$00 (not $03) after a link session
;   completes, returning to the title screen rather than staying in
;   state 3.
