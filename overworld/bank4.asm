; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 4  (Player movement, D-pad handler, warp detection)
; ============================================================================
;
; Called from: bank1/fn1 (state 1 per-frame) via LD HL,$0404/$0402/$0405; RST $10
;
; Bank 4 memory map:
;   File offset $10000-$13FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 4
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; Function table at $10001 (bank 4 $4001) — 7 entries (dw), code starts $400F:
;   fn0: $400F ← push metasprite table $401D → ROM0 $1164 (shared loader)
;   fn1: $4016 ← push metasprite table $401D → local Sub_40CD (OAM composer)
;   fn2: $4081 ← scroll-speed dispatcher (slow=ROM0 $1164 / fast=bank16/17 fn0)
;   fn3: $40A7 ← scroll-speed dispatcher (slow=Sub_40CD / fast=bank16/17 fn1)
;   fn4: $4167 ← main per-frame movement/scroll engine (called every VBlank from state 1)
;   fn5: $55EC ← movement reset (called to initialise step counter before a new move)
;   fn6: $56FA ← flush a queued text event (per-frame)
;
; Cross-bank calls from this bank:
;   bank17/fn0 (HL=$1100) → see bank17.asm
;   bank16/fn0 (HL=$1000) → see bank16.asm
;   bank12/fn0 (HL=$0C00) → see bank12.asm  (area type < $06)
;   bank13/fn0 (HL=$0D00) → see bank13.asm  (area type $06–$1F)
;   bank14/fn0 (HL=$0E00) → see bank14.asm  (area type $20–$3F)
;   bank15/fn0 (HL=$0F00) → see bank15.asm  (area type >= $40)
;
; ROM0 calls from this bank:
;   $1164 (ROM0) — map data loader / transition helper
;
; ============================================================================
;
; Key WRAM variables used in this bank
; ──────────────────────────────────────────────────────────────────────────
; $C825              — wAudioState     : nonzero while audio channel engine is loading
; $C850              — wAnimActive     : nonzero while VBlank animation is running
; $C8A4/$C8A5        — wFrameCtr       : 16-bit frame counter (incremented every VBlank)
; $C8A6              — wFrameCtrLo     : alias for low byte of wFrameCtr (used for parity)
; $C8EB              — wStateFlags     : bitfield; bits other than 0/2 block movement
;                        bit0 = scroll in-progress (wait for wDisplayCtr==$0B)
;                        bit2 = sub-scroll mode (wait for wScrollSubDir==2)
;                        bit3 = bank25/fn0 queued (SELECT in area with exit point)
; $C915              — wDisplayCtr     : scroll phase counter; movement resumes at $0B
; $C91E              — wScrollSubDir   : sub-direction counter for scroll sync; resumes at 2
; $D8D3              — wAreaType       : map type id → selects bank12/13/14/15 dispatcher
; $D8D5/$D8D6        — wStepCtr        : 16-bit step counter (incremented by Fn5 before move)
; $D8D7              — wSaveMode
;
;   DUAL USE — same byte, two different phases:
;
;   At startup (bank1/bank21):
;     0 = new game (no SRAM data loaded)
;     nonzero = save data was loaded (continue mode)
;     bank1/bank21 write 0 here to reset this flag or to prepare for bank4/fn5.
;
;   During gameplay (bank4 movement engine):
;     Per-move mode bitfield.  ALL writers listed below.
;
;     bit0  movement active
;           SET by: bank4/Sub_55F5 ($5613 path) when bank12–15 returns movement
;           CLR by: bank4/Sub_55F5 when bank12–15 returns B=C=$FF (idle/blocked);
;                   bank1 ($1350) and bank6 ($61B7) write 0 before calling bank4/fn5
;
;     bit1  movement locked (warp destination queued)
;           SET by: bank4/Sub_55F5 ($56EC path) when bank12–15 returns B≠$FF
;                   (B/C hold destination address → stored to wWarpDest)
;           CLR by: writing 0 to whole byte (same paths as bit0)
;
;     bit2  countdown timer mode
;           SET by: bank12–15 (indirectly, via warp/tile-action handlers)
;           CLR by: bank4/Fn4 ($41C8 path): when wScrollCountdown reaches 0
;
;     bit3  scroll animation in progress (camera moving 1px/frame)
;           SET by: bank12–15 after deciding a valid D-pad step; they also write
;                   wScrollX/wScrollY pixel budgets at the same time
;           CLR by: bank4/Fn4 ($42C0 path): both wScrollX and wScrollY reached 0
;                   bank4/Fn4 ($43C7 path): tile-action Y-scroll completion
;
;     bit4  warp event being processed
;           SET by: bank4/Sub_443D and bank4/Sub_4584 when a warp slot is active
;           CLR by: bank4/$43EC after all warp slots are processed (RES 4 + RES 6)
;
;     bit5  suppress sprite direction update
;           SET by: bank12–15 during forced/scripted movement
;           CLR by: same as bit0
;
;     bit6  secondary warp trigger
;           SET by: bank12–15 or warp handlers for chained warps
;           CLR by: bank4/$43EC (cleared together with bit4)
;
;   Lifecycle for one tile step (see Bank4_Fn4, Bank4_Fn5, Bank4_Sub_55F5):
;     1. Caller writes 0 to $D8D7 (bank1/bank6), then calls bank4/fn5
;     2. fn5 zeros wStepCtr, calls bank12–15 via Sub_71EF
;     3. bank12–15 reads joypad, checks collision; if valid:
;        → writes wScrollX/wScrollY, SETs bit3 in $D8D7, returns non-$FF in B/C
;     4. Sub_55F5 SETs bit0 (movement active)
;     5. Every subsequent frame: Fn4 sees bit3 → ticks hSCX/hSCY 1px
;     6. When both budgets reach 0: Fn4 CLRs bit3, CLRs hBusyFlag → step complete
;
; $D8D8              — wSaveMode2      : auxiliary mode flags
;                        bit2 = secondary countdown active
; $D8D9/$D8DA        — wWarpDest       : warp destination (area id / room index)
; $D8DB              — wScrollCountdown: frames remaining in countdown mode (Fn4 decrements
;                                        by 1 every 8 frames; clears bit2/bit3 at 0)
; $D8DC              — wWarpLock       : if nonzero, defer scroll start ($41E0 path)
; $D8DD/$D8DE        — wScrollX        : signed 16-bit X-scroll pixel budget (pos=right, neg=left)
; $D8DF/$D8E0        — wScrollY        : signed 16-bit Y-scroll pixel budget (pos=down, neg=up)
; $D8E3              — wZoneCount      : number of zone/area segments in current region
; $D8E4              — wScrollStyle    : animation curve id (1–3) for scroll stepper
; $D8E9              — wWarpSlot0      : primary warp event record (8 bytes)
; $D8F1–$D921        — wWarpSlot1–6   : six additional warp event records (8 bytes each)
;                        Record layout: [active_flag, ?, ?, action_type, ...]
; $D7D2              — wTileActionTbl  : tile-action table; indexed as (type-1)*32 bytes/entry
; $CA37              — wScrollHistIdx  : ring-buffer write index (0..$30); 49 entries max
; $C973+idx*4        — wScrollHistory  : ring buffer storing (SCX_lo, SCY_lo, packed_hi, dir)
;
; Key HRAM variables
; ──────────────────────────────────────────────────────────────────────────
; $FF8D              — hWalkStep_lo    : walk animation step accumulator (low byte)
; $FF8E              — hScrollDir      : last scroll direction (0=up 1=left 2=down 3=right)
; $FF8F              — hWalkStep_hi    : walk animation step accumulator (high byte)
; $FF90 bit0         — hBusyFlag       : set while warp/scroll action is queued
; $FF92/$FF93        — hSCX_lo/hi      : shadow SCX (16-bit pixel precision)
; $FF95/$FF96        — hSCY_lo/hi      : shadow SCY (16-bit pixel precision)
; $FFC7              — hScrollSpeed    : current scroll speed index
; $FFCA              — hScrollFlags    : scroll mode accumulation flags
; $FFD5/$FFD6        — hCollResult     : pointer lo/hi into $D7D2 tile-action table
; $FFD7/$FFD8        — hWarpPtr        : pointer lo/hi to active warp record in WRAM
;
; ============================================================================

SECTION "Bank 4 Functions", ROMX[$4000], BANK[4]



; ============================================================================
; FUNCTION-TABLE FUNCTIONS (fn0-fn6) — byte-exact.  Table @ $4001 (7 dw):
;   fn0 $400F  fn1 $4016  fn2 $4081  fn3 $40A7  fn4 $4167  fn5 $55EC  fn6 $56FA
; fn0/fn1 push a metasprite layout table ($401D); fn2/fn3 are scroll-speed
; dispatchers; fn4 is the per-VBlank movement/scroll engine (see its header).
; ============================================================================

; fn0/fn1: hand DE=$401D (sprite layout table) to a metasprite builder.
;   fn0 -> ROM0 $1164 (shared loader);  fn1 -> local Sub_40CD (OAM composer).
Bank4_Fn0:  ; $400F
    LD DE,$401D                    ; $400F [11 1D 40]  ; DE = &SpriteLayoutTbl ($401D)
    CALL $1164                     ; $4012 [CD 64 11]  ; ROM0 $1164: load metasprite/map data from (DE)
    RET                            ; $4015 [C9]
Bank4_Fn1:  ; $4016
    LD DE,$401D                    ; $4016 [11 1D 40]  ; DE = &SpriteLayoutTbl ($401D)
    CALL $40CD                     ; $4019 [CD CD 40]  ; local Sub_40CD: compose OAM sprites from (DE)
    RET                            ; $401C [C9]

Bank4_SpriteLayoutTbl:  ; $401D-$4080  metasprite layout data (DE for fn0/fn1)
    db $23,$40,$2A,$40,$3D,$40,$25,$40,$00,$00,$00,$00,$80,$2C,$40,$00   ; $401D
    db $00,$00,$10,$00,$08,$01,$10,$08,$00,$02,$10,$08,$08,$03,$10,$80   ; $402D
    db $45,$40,$4E,$40,$63,$40,$70,$40,$00,$00,$90,$00,$08,$00,$91,$00   ; $403D
    db $80,$00,$00,$A6,$00,$00,$08,$A7,$00,$00,$10,$A8,$00,$00,$30,$A4   ; $404D
    db $00,$08,$30,$A5,$00,$80,$F8,$08,$00,$00,$00,$00,$01,$00,$00,$08   ; $405D
    db $02,$00,$80,$00,$00,$00,$00,$00,$08,$01,$00,$08,$00,$10,$00,$08   ; $406D
    db $08,$11,$00,$80   ; $407D

; ------------------------------------------------------------
; Bank4_Fn2 / Bank4_Fn3 — scroll-speed dispatchers (hScrollSpeed $FFC7):
;   < $10  : slow  -> accumulate flag + load map data ($4137)
;   $10-$8F: fast-right -> speed-=$10, bank16
;   >= $90 : fast-left  -> speed-=$90, bank17
;   fn2 slow uses ROM0 $1164 & calls bank16/17 fn0;
;   fn3 slow uses local Sub_40CD & calls bank16/17 fn1.
; ------------------------------------------------------------
Bank4_Fn2:  ; $4081
    LDH A,($C7)                    ; $4081 [F0 C7]  ; hScrollSpeed
    CP $90                         ; $4083 [FE 90]  ; >= $90? -> fast-left
    JR NC,$409E                    ; $4085 [30 17]
    CP $10                         ; $4087 [FE 10]  ; >= $10? -> fast-right
    JR NC,$4095                    ; $4089 [30 0A]
    CALL $4126                     ; $408B [CD 26 41]  ; slow: hScrollFlags |= FlagTbl[speed]
    LD DE,$4137                    ; $408E [11 37 41]  ; DE = &MapXitTbl ($4137)
    CALL $1164                     ; $4091 [CD 64 11]  ; ROM0 $1164 loader
    RET                            ; $4094 [C9]
    SUB $10                        ; $4095 [D6 10]  ; fast-right: speed -= $10
    LDH ($C7),A                    ; $4097 [E0 C7]
    LD HL,$1000                    ; $4099 [21 00 10]  ; bank16 fn0
    RST $10                        ; $409C [D7]
    RET                            ; $409D [C9]
    SUB $90                        ; $409E [D6 90]  ; fast-left: speed -= $90
    LDH ($C7),A                    ; $40A0 [E0 C7]
    LD HL,$1100                    ; $40A2 [21 00 11]  ; bank17 fn0
    RST $10                        ; $40A5 [D7]
    RET                            ; $40A6 [C9]
Bank4_Fn3:  ; $40A7
    LDH A,($C7)                    ; $40A7 [F0 C7]  ; hScrollSpeed
    CP $90                         ; $40A9 [FE 90]
    JR NC,$40C4                    ; $40AB [30 17]
    CP $10                         ; $40AD [FE 10]
    JR NC,$40BB                    ; $40AF [30 0A]
    CALL $4126                     ; $40B1 [CD 26 41]  ; hScrollFlags |= FlagTbl[speed]
    LD DE,$4137                    ; $40B4 [11 37 41]  ; DE = &MapXitTbl ($4137)
    CALL $40CD                     ; $40B7 [CD CD 40]  ; slow: local OAM composer (not ROM0)
    RET                            ; $40BA [C9]
    SUB $10                        ; $40BB [D6 10]
    LDH ($C7),A                    ; $40BD [E0 C7]
    LD HL,$1001                    ; $40BF [21 01 10]  ; bank16 fn1
    RST $10                        ; $40C2 [D7]
    RET                            ; $40C3 [C9]
    SUB $90                        ; $40C4 [D6 90]
    LDH ($C7),A                    ; $40C6 [E0 C7]
    LD HL,$1101                    ; $40C8 [21 01 11]  ; bank17 fn1
    RST $10                        ; $40CB [D7]
    RET                            ; $40CC [C9]
Bank4_Sub_40CD:  ; $40CD  (OAM metasprite composer; DE=layout table)
    PUSH AF                        ; $40CD [F5]
    PUSH BC                        ; $40CE [C5]
    PUSH DE                        ; $40CF [D5]
    PUSH HL                        ; $40D0 [E5]
    LDH A,($CB)                    ; $40D1 [F0 CB]  ; hSpriteCount ($FFCB); >= $28(40)? -> done
    CP $28                         ; $40D3 [FE 28]
    JR NC,$4121                    ; $40D5 [30 4A]
    LDH A,($C7)                    ; $40D7 [F0 C7]  ; hIdxA ($FFC7): index into table -> DE = row base
    LD L,A                         ; $40D9 [6F]
    LD H,$00                       ; $40DA [26 00]
    ADD HL,HL                      ; $40DC [29]
    ADD HL,DE                      ; $40DD [19]
    LD E,(HL)                      ; $40DE [5E]
    INC HL                         ; $40DF [23]
    LD D,(HL)                      ; $40E0 [56]
    LDH A,($C8)                    ; $40E1 [F0 C8]  ; hIdxB ($FFC8): 2nd index -> DE = sprite src
    LD L,A                         ; $40E3 [6F]
    LD H,$00                       ; $40E4 [26 00]
    ADD HL,HL                      ; $40E6 [29]
    ADD HL,DE                      ; $40E7 [19]
    LD E,(HL)                      ; $40E8 [5E]
    INC HL                         ; $40E9 [23]
    LD D,(HL)                      ; $40EA [56]
    LDH A,($CB)                    ; $40EB [F0 CB]  ; sprite# * 4 -> HL = &OAM[$C000 + n*4]
    SLA A                          ; $40ED [CB 27]
    SLA A                          ; $40EF [CB 27]
    LD L,A                         ; $40F1 [6F]
    LD H,$C0                       ; $40F2 [26 C0]
    LD A,(DE)                      ; $40F4 [1A]  ; src Y; $80 = end-of-list sentinel
    INC DE                         ; $40F5 [13]
    CP $80                         ; $40F6 [FE 80]
    JR Z,$4121                     ; $40F8 [28 27]
    LD B,A                         ; $40FA [47]
    LDH A,($C5)                    ; $40FB [F0 C5]  ; OAM.Y = hYBase($FFC5) + srcY + $10
    ADD A,B                        ; $40FD [80]
    ADD A,$10                      ; $40FE [C6 10]
    LD (HL+),A                     ; $4100 [22]
    LD A,(DE)                      ; $4101 [1A]
    INC DE                         ; $4102 [13]
    LD B,A                         ; $4103 [47]
    LDH A,($C3)                    ; $4104 [F0 C3]  ; OAM.X = hXBase($FFC3) + srcX + $08
    ADD A,B                        ; $4106 [80]
    ADD A,$08                      ; $4107 [C6 08]
    LD (HL+),A                     ; $4109 [22]
    LDH A,($C9)                    ; $410A [F0 C9]  ; OAM.tile = hTileBase($FFC9) + src
    LD B,A                         ; $410C [47]
    LD A,(DE)                      ; $410D [1A]
    INC DE                         ; $410E [13]
    ADD A,B                        ; $410F [80]
    LD (HL+),A                     ; $4110 [22]
    LD A,(DE)                      ; $4111 [1A]
    INC DE                         ; $4112 [13]
    LD B,A                         ; $4113 [47]
    LDH A,($CA)                    ; $4114 [F0 CA]  ; OAM.attr = hAttrXor($FFCA) ^ src
    XOR B                          ; $4116 [A8]
    LD (HL+),A                     ; $4117 [22]
    LDH A,($CB)                    ; $4118 [F0 CB]  ; sprite# ++; loop while < $28 (40 sprites)
    INC A                          ; $411A [3C]
    LDH ($CB),A                    ; $411B [E0 CB]
    CP $28                         ; $411D [FE 28]
    JR C,$40F4                     ; $411F [38 D3]
    POP HL                         ; $4121 [E1]
    POP DE                         ; $4122 [D1]
    POP BC                         ; $4123 [C1]
    POP AF                         ; $4124 [F1]
    RET                            ; $4125 [C9]
Bank4_Sub_4126:  ; $4126  (hScrollFlags |= ScrollFlagTable[hScrollSpeed])
    LDH A,($C7)                    ; $4126 [F0 C7]  ; hScrollSpeed = index into ScrollFlagTable
    LD HL,$4157                    ; $4128 [21 57 41]
    ADD A,L                        ; $412B [85]
    LD L,A                         ; $412C [6F]
    LD A,$00                       ; $412D [3E 00]
    ADC A,H                        ; $412F [8C]
    LD H,A                         ; $4130 [67]
    LDH A,($CA)                    ; $4131 [F0 CA]  ; hScrollFlags |= table[speed]
    OR (HL)                        ; $4133 [B6]
    LDH ($CA),A                    ; $4134 [E0 CA]
    RET                            ; $4136 [C9]

Bank4_MapXitTbl:  ; $4137-$4156  map/scroll-exit data (DE for fn2/fn3 slow path)
    db $37,$72,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77   ; $4137
    db $38,$77,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77,$38,$77   ; $4147

Bank4_ScrollFlagTable:  ; $4157-$4166  hScrollFlags OR-mask per speed (Sub_4126)
    db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02   ; $4157

; ============================================================================
; Bank4_Fn4 ($4167) — PER-VBLANK MOVEMENT / SCROLL ENGINE  (the important one)
; ----------------------------------------------------------------------------
; Called every frame from bank1 state-1 (LD HL,$0404; RST $10). Advances one
; queued player/camera/object move by ONE pixel-step per eligible frame.
;
; 3 GATES first: (1) if any $C8EB mode bit other than 0/2 is set, another
; subsystem owns the frame -> RET. (2) sync to scroll phase ($C915==$0B for
; bit0, or $C91E==2 for bit2). (3) RET while anim ($C850) or audio ($C825) busy.
;
; Then dispatch on wSaveMode $D8D7: bit0=0 or bit1 -> RET; bit4/bit6 -> scan
; warp slots (Sub_43EC); bit2 -> countdown ($41C8); bit3 -> smooth scroll-move
; ($41E0, walks camera HRAM $92/$93 & $95/$96 toward target, sets facing $8E,
; or moves an object record if wWarpLock $D8DC set); else -> Sub_55F5 (step).
;
; Key WRAM/HRAM: $D8DD:DE=signed remaining X, $D8DF:E0=remaining Y (16-bit,
; counted down to 0), hCamX $92/$93, hCamY $95/$96, hFacing $8E (0=U,1=R,2=D,
; 3=L), hFrameCtr $C8A4 (phase throttle), hBusyFlag $FF90 bit0.
; ============================================================================
Bank4_Fn4:  ; $4167
    LD A,($C8EB)                   ; $4167 [FA EB C8]  ; --- GATE 1: other mode owns the frame? ---  wStateFlags
    RES 0,A                        ; $416A [CB 87]  ; ignore bit0 (scroll-in-progress)
    RES 2,A                        ; $416C [CB 97]  ; ignore bit2 (zone-scroll)
    OR A                           ; $416E [B7]
    RET NZ                         ; $416F [C0]  ; any OTHER bit set (party/dialog/shop/...) -> skip movement
    LD A,($C8EB)                   ; $4170 [FA EB C8]  ; --- GATE 2: scroll-phase sync ---
    BIT 0,A                        ; $4173 [CB 47]  ; scroll in progress?
    JR Z,$417F                     ; $4175 [28 08]
    LD A,($C915)                   ; $4177 [FA 15 C9]  ; wScrollPhaseCtr $C915
    CP $0B                         ; $417A [FE 0B]  ; == $0B (ready for next step)?
    RET NZ                         ; $417C [C0]  ; not yet -> wait
    JR $4189                       ; $417D [18 0A]
    BIT 2,A                        ; $417F [CB 57]  ; zone-scroll (bit2)?
    JR Z,$4189                     ; $4181 [28 06]
    LD A,($C91E)                   ; $4183 [FA 1E C9]  ; wAreaMode $C91E
    CP $02                         ; $4186 [FE 02]  ; == 2 (mid-transition)?
    RET NZ                         ; $4188 [C0]
    LD A,($C850)                   ; $4189 [FA 50 C8]  ; --- GATE 3: anim/audio idle ---  wAnimActive $C850
    OR A                           ; $418C [B7]
    RET NZ                         ; $418D [C0]
    LD A,($C825)                   ; $418E [FA 25 C8]  ; wAudioState $C825
    OR A                           ; $4191 [B7]
    RET NZ                         ; $4192 [C0]
    LD A,($D8D7)                   ; $4193 [FA D7 D8]  ; --- DISPATCH on wSaveMode $D8D7 ---
    BIT 0,A                        ; $4196 [CB 47]  ; bit0 = move-command queued?
    JP Z,$41C7                     ; $4198 [CA C7 41]  ; not queued -> RET ($41C7)
    BIT 1,A                        ; $419B [CB 4F]  ; bit1 = movement locked?
    JP NZ,$41C7                    ; $419D [C2 C7 41]
    LD A,($D8D7)                   ; $41A0 [FA D7 D8]  ; wSaveMode
    BIT 4,A                        ; $41A3 [CB 67]  ; bit4 = primary warp pending?
    CALL NZ,$43EC                  ; $41A5 [C4 EC 43]  ; -> scan warp slots (Sub_43EC)
    LD A,($D8D7)                   ; $41A8 [FA D7 D8]
    BIT 6,A                        ; $41AB [CB 77]  ; bit6 = secondary warp pending?
    CALL NZ,$43EC                  ; $41AD [C4 EC 43]  ; -> scan warp slots again
    LD A,($D8D7)                   ; $41B0 [FA D7 D8]
    BIT 2,A                        ; $41B3 [CB 57]  ; bit2 = countdown timer?
    JR NZ,$41C8                    ; $41B5 [20 11]  ; -> countdown path ($41C8)
    BIT 3,A                        ; $41B7 [CB 5F]  ; bit3 = smooth scroll-move?
    JP NZ,$41E0                    ; $41B9 [C2 E0 41]  ; -> scroll-move path ($41E0)
    LD A,($D8D8)                   ; $41BC [FA D8 D8]  ; wMoveFlags2 $D8D8
    BIT 2,A                        ; $41BF [CB 57]  ; bit2 = 2nd countdown?
    JP NZ,$43DB                    ; $41C1 [C2 DB 43]  ; -> Sub_43DB
    CALL $55F5                     ; $41C4 [CD F5 55]  ; else: normal step-and-move (Sub_55F5)
    RET                            ; $41C7 [C9]  ; shared RET
.lbl_41C8:
    LD A,($C8A4)                   ; $41C8 [FA A4 C8]  ; --- COUNTDOWN path (bit2) ---  hFrameCtr $C8A4
    AND $07                        ; $41CB [E6 07]  ; every 8th frame only
    JR NZ,$41DD                    ; $41CD [20 0E]
    LD A,($D8DB)                   ; $41CF [FA DB D8]  ; wCountdown $D8DB
    DEC A                          ; $41D2 [3D]
    LD ($D8DB),A                   ; $41D3 [EA DB D8]  ; store back
    JR NZ,$41DD                    ; $41D6 [20 05]  ; not 0 yet -> stay
    LD HL,$D8D7                    ; $41D8 [21 D7 D8]
    RES 2,(HL)                     ; $41DB [CB 96]  ; reached 0 -> clear wSaveMode bit2
    JP $41C7                       ; $41DD [C3 C7 41]  ; -> RET
.lbl_41E0:
    LD A,($D8DC)                   ; $41E0 [FA DC D8]  ; --- SCROLL-MOVE path (bit3): pixel-walk camera to target ---  wWarpLock $D8DC
    OR A                           ; $41E3 [B7]
    JP NZ,$42CD                    ; $41E4 [C2 CD 42]  ; warp-lock set -> object-move variant ($42CD)
    LD HL,$FF90                    ; $41E7 [21 90 FF]  ; hBusyFlag $FF90
    SET 0,(HL)                     ; $41EA [CB C6]  ; set bit0 = busy this frame
    LD A,($C8A4)                   ; $41EC [FA A4 C8]  ; hFrameCtr $C8A4
    AND $03                        ; $41EF [E6 03]
    CP $01                         ; $41F1 [FE 01]  ; phase 1 of 4? -> skip this frame ($43D8)
    JP Z,$43D8                     ; $41F3 [CA D8 43]
    LD A,($D8DD)                   ; $41F6 [FA DD D8]  ; wDeltaX lo $D8DD
    LD L,A                         ; $41F9 [6F]
    LD A,($D8DE)                   ; $41FA [FA DE D8]  ; wDeltaX hi $D8DE
    LD H,A                         ; $41FD [67]
    LD A,H                         ; $41FE [7C]
    OR L                           ; $41FF [B5]  ; X delta == 0? -> do Y ($425A)
    JR Z,$425A                     ; $4200 [28 58]
    BIT 7,H                        ; $4202 [CB 7C]  ; X delta negative? -> move +X ($4231)
    JR NZ,$4231                    ; $4204 [20 2B]
    LD A,($D8DD)                   ; $4206 [FA DD D8]  ; --- X delta > 0: step player -X, camera +X ---
    SUB $01                        ; $4209 [D6 01]
    LD ($D8DD),A                   ; $420B [EA DD D8]
    LD A,($D8DE)                   ; $420E [FA DE D8]
    SBC A,$00                      ; $4211 [DE 00]
    LD ($D8DE),A                   ; $4213 [EA DE D8]
    LDH A,($92)                    ; $4216 [F0 92]  ; hCamX lo $92
    ADD A,$01                      ; $4218 [C6 01]
    LDH ($92),A                    ; $421A [E0 92]
    LDH A,($93)                    ; $421C [F0 93]
    ADC A,$00                      ; $421E [CE 00]
    LDH ($93),A                    ; $4220 [E0 93]
    LD A,($D8D7)                   ; $4222 [FA D7 D8]
    BIT 5,A                        ; $4225 [CB 6F]  ; wSaveMode bit5 (suppress facing)?
    JP NZ,$42BA                    ; $4227 [C2 BA 42]
    LD A,$03                       ; $422A [3E 03]
    LDH ($8E),A                    ; $422C [E0 8E]  ; hFacing $8E = 3 (left)
    JP $42BA                       ; $422E [C3 BA 42]
    LD A,($D8DD)                   ; $4231 [FA DD D8]  ; --- X delta < 0: step player +X, camera -X ---
    ADD A,$01                      ; $4234 [C6 01]
    LD ($D8DD),A                   ; $4236 [EA DD D8]
    LD A,($D8DE)                   ; $4239 [FA DE D8]
    ADC A,$00                      ; $423C [CE 00]
    LD ($D8DE),A                   ; $423E [EA DE D8]
    LDH A,($92)                    ; $4241 [F0 92]  ; hCamX lo $92
    SUB $01                        ; $4243 [D6 01]
    LDH ($92),A                    ; $4245 [E0 92]
    LDH A,($93)                    ; $4247 [F0 93]
    SBC A,$00                      ; $4249 [DE 00]
    LDH ($93),A                    ; $424B [E0 93]
    LD A,($D8D7)                   ; $424D [FA D7 D8]
    BIT 5,A                        ; $4250 [CB 6F]
    JR NZ,$42BA                    ; $4252 [20 66]
    LD A,$01                       ; $4254 [3E 01]
    LDH ($8E),A                    ; $4256 [E0 8E]  ; hFacing $8E = 1 (right)
    JR $42BA                       ; $4258 [18 60]
    LD A,($D8DF)                   ; $425A [FA DF D8]  ; wDeltaY lo $D8DF
    LD L,A                         ; $425D [6F]
    LD A,($D8E0)                   ; $425E [FA E0 D8]  ; wDeltaY hi $D8E0
    LD H,A                         ; $4261 [67]
    LD A,H                         ; $4262 [7C]
    OR L                           ; $4263 [B5]  ; Y delta == 0? -> both done ($42C0)
    JR Z,$42C0                     ; $4264 [28 5A]
    BIT 7,H                        ; $4266 [CB 7C]  ; Y delta negative? -> move +Y ($4293)
    JR NZ,$4293                    ; $4268 [20 29]
    LD A,($D8DF)                   ; $426A [FA DF D8]  ; --- Y delta > 0: step -Y, camera +Y ---
    SUB $01                        ; $426D [D6 01]
    LD ($D8DF),A                   ; $426F [EA DF D8]
    LD A,($D8E0)                   ; $4272 [FA E0 D8]
    SBC A,$00                      ; $4275 [DE 00]
    LD ($D8E0),A                   ; $4277 [EA E0 D8]
    LDH A,($95)                    ; $427A [F0 95]  ; hCamY lo $95
    ADD A,$01                      ; $427C [C6 01]
    LDH ($95),A                    ; $427E [E0 95]
    LDH A,($96)                    ; $4280 [F0 96]
    ADC A,$00                      ; $4282 [CE 00]
    LDH ($96),A                    ; $4284 [E0 96]
    LD A,($D8D7)                   ; $4286 [FA D7 D8]
    BIT 5,A                        ; $4289 [CB 6F]
    JR NZ,$42BA                    ; $428B [20 2D]
    LD A,$00                       ; $428D [3E 00]
    LDH ($8E),A                    ; $428F [E0 8E]  ; hFacing $8E = 0 (up)
    JR $42BA                       ; $4291 [18 27]
    LD A,($D8DF)                   ; $4293 [FA DF D8]  ; --- Y delta < 0: step +Y, camera -Y ---
    ADD A,$01                      ; $4296 [C6 01]
    LD ($D8DF),A                   ; $4298 [EA DF D8]
    LD A,($D8E0)                   ; $429B [FA E0 D8]
    ADC A,$00                      ; $429E [CE 00]
    LD ($D8E0),A                   ; $42A0 [EA E0 D8]
    LDH A,($95)                    ; $42A3 [F0 95]  ; hCamY lo $95
    SUB $01                        ; $42A5 [D6 01]
    LDH ($95),A                    ; $42A7 [E0 95]
    LDH A,($96)                    ; $42A9 [F0 96]
    SBC A,$00                      ; $42AB [DE 00]
    LDH ($96),A                    ; $42AD [E0 96]
    LD A,($D8D7)                   ; $42AF [FA D7 D8]
    BIT 5,A                        ; $42B2 [CB 6F]
    JR NZ,$42BA                    ; $42B4 [20 04]
    LD A,$02                       ; $42B6 [3E 02]
    LDH ($8E),A                    ; $42B8 [E0 8E]  ; hFacing $8E = 2 (down)
.lbl_42BA:
    CALL $454B                     ; $42BA [CD 4B 45]  ; commit step (Sub_454B)
    JP $43D8                       ; $42BD [C3 D8 43]  ; -> tail ($43D8)
.lbl_42C0:
    LD HL,$FF90                    ; $42C0 [21 90 FF]  ; --- both deltas exhausted: move done ---
    RES 0,(HL)                     ; $42C3 [CB 86]  ; clear hBusyFlag bit0
    LD HL,$D8D7                    ; $42C5 [21 D7 D8]
    RES 3,(HL)                     ; $42C8 [CB 9E]  ; clear wSaveMode bit3 (scroll-move done)
    JP $43D8                       ; $42CA [C3 D8 43]
.lbl_42CD:
    DEC A                          ; $42CD [3D]  ; --- OBJECT-MOVE variant (warp-lock set): move an NPC/object record ---
    SWAP A                         ; $42CE [CB 37]  ; (wWarpLock-1)*32 ...
    ADD A,A                        ; $42D0 [87]
    LD HL,$D7D2                    ; $42D1 [21 D2 D7]  ; wObjectTable $D7D2
    ADD A,L                        ; $42D4 [85]
    LD L,A                         ; $42D5 [6F]
    LD A,$00                       ; $42D6 [3E 00]
    ADC A,H                        ; $42D8 [8C]
    LD H,A                         ; $42D9 [67]
    LD A,L                         ; $42DA [7D]
    LDH ($D5),A                    ; $42DB [E0 D5]  ; hObjPtr $FFD5:D6
    LD A,H                         ; $42DD [7C]
    LDH ($D6),A                    ; $42DE [E0 D6]
    LD A,L                         ; $42E0 [7D]
    ADD A,$05                      ; $42E1 [C6 05]  ; record+5 (state byte)
    LD L,A                         ; $42E3 [6F]
    LD A,H                         ; $42E4 [7C]
    ADC A,$00                      ; $42E5 [CE 00]
    LD H,A                         ; $42E7 [67]
    SET 0,(HL)                     ; $42E8 [CB C6]  ; set bit0 (moving)
    RES 6,(HL)                     ; $42EA [CB B6]  ; clear bit6
    LD A,($C8A4)                   ; $42EC [FA A4 C8]  ; hFrameCtr $C8A4
    AND $03                        ; $42EF [E6 03]
    CP $01                         ; $42F1 [FE 01]
    JP Z,$43D8                     ; $42F3 [CA D8 43]  ; phase 1? -> skip
    LD A,($D8DD)                   ; $42F6 [FA DD D8]  ; obj wDeltaX $D8DD
    LD E,A                         ; $42F9 [5F]
    LD A,($D8DE)                   ; $42FA [FA DE D8]
    LD D,A                         ; $42FD [57]
    LD A,D                         ; $42FE [7A]
    OR E                           ; $42FF [B3]  ; ==0 -> obj Y ($435F)
    JR Z,$435F                     ; $4300 [28 5D]
    BIT 7,D                        ; $4302 [CB 7A]  ; negative? -> +X ($4333)
    JR NZ,$4333                    ; $4304 [20 2D]
    LD A,($D8DD)                   ; $4306 [FA DD D8]
    SUB $01                        ; $4309 [D6 01]
    LD ($D8DD),A                   ; $430B [EA DD D8]
    LD A,($D8DE)                   ; $430E [FA DE D8]
    SBC A,$00                      ; $4311 [DE 00]
    LD ($D8DE),A                   ; $4313 [EA DE D8]
    INC HL                         ; $4316 [23]
    LD A,($D8D7)                   ; $4317 [FA D7 D8]
    BIT 5,A                        ; $431A [CB 6F]
    JR NZ,$4320                    ; $431C [20 02]
    LD (HL),$03                    ; $431E [36 03]
    LD A,L                         ; $4320 [7D]
    ADD A,$12                      ; $4321 [C6 12]  ; record +$12 = obj X word; ++
    LD L,A                         ; $4323 [6F]
    LD A,H                         ; $4324 [7C]
    ADC A,$00                      ; $4325 [CE 00]
    LD H,A                         ; $4327 [67]
    LD A,(HL+)                     ; $4328 [2A]
    LD D,(HL)                      ; $4329 [56]
    LD E,A                         ; $432A [5F]
    INC DE                         ; $432B [13]
    DEC HL                         ; $432C [2B]
    LD (HL),E                      ; $432D [73]
    INC HL                         ; $432E [23]
    LD (HL),D                      ; $432F [72]
    JP $43D8                       ; $4330 [C3 D8 43]  ; -> tail
    LD A,($D8DD)                   ; $4333 [FA DD D8]
    ADD A,$01                      ; $4336 [C6 01]
    LD ($D8DD),A                   ; $4338 [EA DD D8]
    LD A,($D8DE)                   ; $433B [FA DE D8]
    ADC A,$00                      ; $433E [CE 00]
    LD ($D8DE),A                   ; $4340 [EA DE D8]
    INC HL                         ; $4343 [23]
    LD A,($D8D7)                   ; $4344 [FA D7 D8]
    BIT 5,A                        ; $4347 [CB 6F]
    JR NZ,$434D                    ; $4349 [20 02]
    LD (HL),$01                    ; $434B [36 01]
    LD A,L                         ; $434D [7D]
    ADD A,$12                      ; $434E [C6 12]  ; record +$12 = obj X word; --
    LD L,A                         ; $4350 [6F]
    LD A,H                         ; $4351 [7C]
    ADC A,$00                      ; $4352 [CE 00]
    LD H,A                         ; $4354 [67]
    LD A,(HL+)                     ; $4355 [2A]
    LD D,(HL)                      ; $4356 [56]
    LD E,A                         ; $4357 [5F]
    DEC DE                         ; $4358 [1B]
    DEC HL                         ; $4359 [2B]
    LD (HL),E                      ; $435A [73]
    INC HL                         ; $435B [23]
    LD (HL),D                      ; $435C [72]
    JR $43D8                       ; $435D [18 79]
    LD A,($D8DF)                   ; $435F [FA DF D8]  ; obj wDeltaY $D8DF
    LD E,A                         ; $4362 [5F]
    LD A,($D8E0)                   ; $4363 [FA E0 D8]
    LD D,A                         ; $4366 [57]
    LD A,D                         ; $4367 [7A]
    OR E                           ; $4368 [B3]  ; ==0 -> obj done ($43C7)
    JR Z,$43C7                     ; $4369 [28 5C]
    BIT 7,D                        ; $436B [CB 7A]  ; negative? -> +Y ($439B)
    JR NZ,$439B                    ; $436D [20 2C]
    LD A,($D8DF)                   ; $436F [FA DF D8]
    SUB $01                        ; $4372 [D6 01]
    LD ($D8DF),A                   ; $4374 [EA DF D8]
    LD A,($D8E0)                   ; $4377 [FA E0 D8]
    SBC A,$00                      ; $437A [DE 00]
    LD ($D8E0),A                   ; $437C [EA E0 D8]
    INC HL                         ; $437F [23]
    LD A,($D8D7)                   ; $4380 [FA D7 D8]
    BIT 5,A                        ; $4383 [CB 6F]
    JR NZ,$4389                    ; $4385 [20 02]
    LD (HL),$00                    ; $4387 [36 00]
    LD A,L                         ; $4389 [7D]
    ADD A,$14                      ; $438A [C6 14]  ; record +$14 = obj Y word; ++
    LD L,A                         ; $438C [6F]
    LD A,H                         ; $438D [7C]
    ADC A,$00                      ; $438E [CE 00]
    LD H,A                         ; $4390 [67]
    LD A,(HL+)                     ; $4391 [2A]
    LD D,(HL)                      ; $4392 [56]
    LD E,A                         ; $4393 [5F]
    INC DE                         ; $4394 [13]
    DEC HL                         ; $4395 [2B]
    LD (HL),E                      ; $4396 [73]
    INC HL                         ; $4397 [23]
    LD (HL),D                      ; $4398 [72]
    JR $43D8                       ; $4399 [18 3D]
    LD A,($D8DF)                   ; $439B [FA DF D8]
    ADD A,$01                      ; $439E [C6 01]
    LD ($D8DF),A                   ; $43A0 [EA DF D8]
    LD A,($D8E0)                   ; $43A3 [FA E0 D8]
    ADC A,$00                      ; $43A6 [CE 00]
    LD ($D8E0),A                   ; $43A8 [EA E0 D8]
    INC HL                         ; $43AB [23]
    LD A,($D8D7)                   ; $43AC [FA D7 D8]
    BIT 5,A                        ; $43AF [CB 6F]
    JR NZ,$43B5                    ; $43B1 [20 02]
    LD (HL),$02                    ; $43B3 [36 02]
    LD A,L                         ; $43B5 [7D]
    ADD A,$14                      ; $43B6 [C6 14]  ; record +$14 = obj Y word; --
    LD L,A                         ; $43B8 [6F]
    LD A,H                         ; $43B9 [7C]
    ADC A,$00                      ; $43BA [CE 00]
    LD H,A                         ; $43BC [67]
    LD A,(HL+)                     ; $43BD [2A]
    LD D,(HL)                      ; $43BE [56]
    LD E,A                         ; $43BF [5F]
    DEC DE                         ; $43C0 [1B]
    DEC HL                         ; $43C1 [2B]
    LD (HL),E                      ; $43C2 [73]
    INC HL                         ; $43C3 [23]
    LD (HL),D                      ; $43C4 [72]
    JR $43D8                       ; $43C5 [18 11]
.lbl_43C7:
    LDH A,($D5)                    ; $43C7 [F0 D5]  ; --- object move done: clear its moving bit ---
    ADD A,$05                      ; $43C9 [C6 05]  ; record+5
    LD L,A                         ; $43CB [6F]
    LDH A,($D6)                    ; $43CC [F0 D6]
    ADC A,$00                      ; $43CE [CE 00]
    LD H,A                         ; $43D0 [67]
    RES 0,(HL)                     ; $43D1 [CB 86]  ; clear bit0 (stopped)
    LD HL,$D8D7                    ; $43D3 [21 D7 D8]
    RES 3,(HL)                     ; $43D6 [CB 9E]  ; clear wSaveMode bit3
.lbl_43D8:
    JP $41C7                       ; $43D8 [C3 C7 41]  ; tail: -> RET via $41C7
Bank4_Sub_43DB:  ; $43DB  (2nd countdown timer)
    LD A,($D8DB)                   ; $43DB [FA DB D8]  ; --- Sub_43DB: 2nd countdown (wMoveFlags2 bit2) ---  wCountdown $D8DB
    DEC A                          ; $43DE [3D]
    LD ($D8DB),A                   ; $43DF [EA DB D8]
    JR NZ,$43E9                    ; $43E2 [20 05]
    LD HL,$D8D8                    ; $43E4 [21 D8 D8]
    RES 2,(HL)                     ; $43E7 [CB 96]  ; reached 0 -> clear wMoveFlags2 bit2
    JP $41C7                       ; $43E9 [C3 C7 41]  ; -> RET
Bank4_Sub_43EC:  ; $43EC  (scan 8 warp-event slots)
    LD A,($D8E9)                   ; $43EC [FA E9 D8]  ; --- Sub_43EC: scan 8 warp-event slots ---  wWarpSlot0 flag $D8E9
    PUSH AF                        ; $43EF [F5]
    CALL $443D                     ; $43F0 [CD 3D 44]  ; primary slot handler (Sub_443D)
    POP AF                         ; $43F3 [F1]
    LD HL,$D8F1                    ; $43F4 [21 F1 D8]  ; OR slot1 flag $D8F1
    OR (HL)                        ; $43F7 [B6]
    PUSH AF                        ; $43F8 [F5]
    CALL $4584                     ; $43F9 [CD 84 45]  ; Sub_4584 (slot handler)
    POP AF                         ; $43FC [F1]
    LD HL,$D8F9                    ; $43FD [21 F9 D8]  ; OR slot2 $D8F9
    OR (HL)                        ; $4400 [B6]
    PUSH AF                        ; $4401 [F5]
    CALL $4584                     ; $4402 [CD 84 45]
    POP AF                         ; $4405 [F1]
    LD HL,$D901                    ; $4406 [21 01 D9]  ; OR slot3 $D901
    OR (HL)                        ; $4409 [B6]
    PUSH AF                        ; $440A [F5]
    CALL $4584                     ; $440B [CD 84 45]
    POP AF                         ; $440E [F1]
    LD HL,$D909                    ; $440F [21 09 D9]  ; OR slot4 $D909
    OR (HL)                        ; $4412 [B6]
    PUSH AF                        ; $4413 [F5]
    CALL $4584                     ; $4414 [CD 84 45]
    POP AF                         ; $4417 [F1]
    LD HL,$D911                    ; $4418 [21 11 D9]  ; OR slot5 $D911
    OR (HL)                        ; $441B [B6]
    PUSH AF                        ; $441C [F5]
    CALL $4584                     ; $441D [CD 84 45]
    POP AF                         ; $4420 [F1]
    LD HL,$D919                    ; $4421 [21 19 D9]  ; OR slot6 $D919
    OR (HL)                        ; $4424 [B6]
    PUSH AF                        ; $4425 [F5]
    CALL $4584                     ; $4426 [CD 84 45]
    POP AF                         ; $4429 [F1]
    LD HL,$D921                    ; $442A [21 21 D9]  ; OR slot7 $D921
    OR (HL)                        ; $442D [B6]
    PUSH AF                        ; $442E [F5]
    CALL $4584                     ; $442F [CD 84 45]
    POP AF                         ; $4432 [F1]
    OR A                           ; $4433 [B7]  ; any slot still active? -> come back next frame
    RET NZ                         ; $4434 [C0]
    LD HL,$D8D7                    ; $4435 [21 D7 D8]
    RES 4,(HL)                     ; $4438 [CB A6]  ; all idle: clear wSaveMode bit4
    RES 6,(HL)                     ; $443A [CB B6]  ; ... and bit6
    RET                            ; $443C [C9]


; ------------------------------------------------------------
; Bank4_Sub_443D — primary warp slot handler
;   Checks wWarpSlot0 ($D8E9): if zero, no pending warp → return.
;   Sets wSaveMode bit4 (warp in progress), saves $D8E9 ptr to hWarpPtr ($FFD7/$FFD8).
;   Reads warp action type from $D8EB and dispatches to the appropriate handler.
;   Known action types (primary slot only):
;     $01 → $4742  (door/staircase warp)
;     $03 → $47BE  (area transition with scroll)
;     $04 → $4857  (animated warp type 4)
;     $06 → $48E2  (animated warp type 6)
;     $07 → $4931  (animated warp type 7)
;     $1A → $55A9  (special warp $1A)
;   Unknown types: set hBusyFlag, throttle on frame phase, tick $D8ED/$D8EE X-scroll.
; ------------------------------------------------------------
Bank4_Sub_443D:
    LD A,($D8E9)                        ; wWarpSlot0 active flag
    OR A
    RET Z                               ; no pending warp → done
    LD A,($D8D7)                        ; wSaveMode
    SET 4,A
    LD ($D8D7),A                        ; wSaveMode bit4 = 1 (warp processing)
    LD HL,$D8E9                         ; point to wWarpSlot0 record
    LD A,L
    LDH ($D7),A                         ; hWarpPtr lo = $E9
    LD A,H
    LDH ($D8),A                         ; hWarpPtr hi = $D8
    LD A,($D8EB)                        ; warp action type (at record+2)
    LD HL,$FF95                         ; preload HL (used by some handlers)
    CP $01
    JP Z,$4742                          ; door/staircase warp
    CP $03
    JP Z,$47BE                          ; area transition with scroll
    CP $04
    JP Z,$4857                          ; animated warp type 4
    CP $06
    JP Z,$48E2                          ; animated warp type 6
    CP $07
    JP Z,$4931                          ; animated warp type 7
    CP $1A
    JP Z,$55A9                          ; special warp $1A
    ; unknown type: busy-flag + frame-gated X-scroll tick
    LD HL,$FF90
    SET 0,(HL)                          ; hBusyFlag = 1
    LD A,($C8A4)                        ; wFrameCtr low byte
    AND $03                             ; frame phase (0-3)
    CP $01                              ; phase 1?
    RET Z                               ; yes → skip this frame                               
    LD A,($D8ED)                        
    LD L,A                              
    LD A,($D8EE)                        
    LD H,A                              
    LD A,H                              
    OR L                                
    JR Z,$44EA                          
    BIT 7,H                             
    JR NZ,$44BF                         
    LD A,($D8ED)                        
    SUB $01                             
    LD ($D8ED),A                        
    LD A,($D8EE)                        
    SBC A,$00                           
    LD ($D8EE),A                        
    LDH A,($92)                         ; hSCX_lo
    ADD A,$01                           
    LDH ($92),A                         ; → hSCX_lo
    LDH A,($93)                         ; hSCX_hi
    ADC A,$00                           
    LDH ($93),A                         ; → hSCX_hi
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JP NZ,$454B                         
    LD A,$03                            
    LDH ($8E),A                         
    JP $454B                              ; → Bank4_Sub_454B
    LD A,($D8ED)                        
    ADD A,$01                           
    LD ($D8ED),A                        
    LD A,($D8EE)                        
    ADC A,$00                           
    LD ($D8EE),A                        
    LDH A,($92)                         ; hSCX_lo
    SUB $01                             
    LDH ($92),A                         ; → hSCX_lo
    LDH A,($93)                         ; hSCX_hi
    SBC A,$00                           
    LDH ($93),A                         ; → hSCX_hi
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JP NZ,$454B                         
    LD A,$01                            
    LDH ($8E),A                         
    JP $454B                              ; → Bank4_Sub_454B
    LD A,($D8EF)                        
    LD L,A                              
    LD A,($D8F0)                        
    LD H,A                              
    LD A,H                              
    OR L                                
    JP Z,$457A                          
    BIT 7,H                             
    JR NZ,$4524                         
    LD A,($D8EF)                        
    SUB $01                             
    LD ($D8EF),A                        
    LD A,($D8F0)                        
    SBC A,$00                           
    LD ($D8F0),A                        
    LDH A,($95)                         ; hSCY_lo
    ADD A,$01                           
    LDH ($95),A                         ; → hSCY_lo
    LDH A,($96)                         ; hSCY_hi
    ADC A,$00                           
    LDH ($96),A                         ; → hSCY_hi
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$454B                         
    LD A,$00                            
    LDH ($8E),A                         
    JR $454B                            
    LD A,($D8EF)                        
    ADD A,$01                           
    LD ($D8EF),A                        
    LD A,($D8F0)                        
    ADC A,$00                           
    LD ($D8F0),A                        
    LDH A,($95)                         ; hSCY_lo
    SUB $01                             
    LDH ($95),A                         ; → hSCY_lo
    LDH A,($96)                         ; hSCY_hi
    SBC A,$00                           
    LDH ($96),A                         ; → hSCY_hi
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$454B                         
    LD A,$02                            
    LDH ($8E),A                         

; ------------------------------------------------------------
; Bank4_Sub_454B — seed walk-animation accumulator from scroll direction
;   Reads hScrollDir ($FF8E) and loads the 16-bit walk-step accumulator
;   (hWalkStep_lo $FF8D, hWalkStep_hi $FF8F) with a per-direction seed so
;   the sprite's walk cycle advances at the right rate for that axis:
;     dir 0 (up)    → $0000
;     dir 1 (left)  → $0120
;     dir 2 (down)  → $0200
;     dir 3 (right) → $0100
;   Called at the tail of every scroll-tick path in Sub_443D.
; ------------------------------------------------------------
Bank4_Sub_454B:
    LD A,$00
    LDH ($8D),A                         ; hWalkStep_lo = 0
    LD A,$00
    LDH ($8F),A                         ; hWalkStep_hi = 0  (default = dir 0 / up)
    LDH A,($8E)                         ; hScrollDir
    OR A
    RET Z                               ; dir 0 → keep $0000
    LD A,$20
    LDH ($8D),A                         ; hWalkStep_lo = $20
    LD A,$01
    LDH ($8F),A                         ; hWalkStep_hi = 1  → $0120
    LDH A,($8E)                         ; hScrollDir
    CP $01                              ; dir 1 (left)?
    RET Z
    LD A,$00
    LDH ($8D),A
    LD A,$02
    LDH ($8F),A                         ; → $0200
    LDH A,($8E)                         ; hScrollDir
    CP $02                              ; dir 2 (down)?
    RET Z
    LD A,$00
    LDH ($8D),A
    LD A,$01
    LDH ($8F),A                         ; dir 3 (right) → $0100
    RET
    ; warp-complete tail ($4578): clear busy flag and retire warp slot 0
    LD HL,$FF90
    RES 0,(HL)                          ; hBusyFlag = 0 (action finished)
    XOR A
    LD ($D8E9),A                        ; wWarpSlot0 active flag = 0 (slot retired)
    RET


; ------------------------------------------------------------
; Bank4_Sub_4584 — tile-action dispatcher (HL = warp/tile record)
;   Entry HL points at a record whose byte[0] is an active flag
;   (0 = empty → return). When active:
;     - set wSaveMode bit4 (warp/action processing),
;     - save the record pointer into hWarpPtr ($FFD7:D8),
;     - read the tile-action TYPE from record[3], convert to a table
;       offset (type-1)*32 into wTileActionTbl ($D7D2), and cache that
;       pointer in hCollResult ($FFD5:D6),
;     - read the ACTION sub-code from record+2 (via BC) and dispatch to
;       the matching handler ($01..$15+, big JP-Z table below).
;   This is the general per-tile event handler: doors, stairs, warps,
;   scripted tiles, etc. — each action code has its own routine.
; ------------------------------------------------------------
Bank4_Sub_4584:
    LD A,(HL)                           ; record[0] = active flag
    OR A
    RET Z                               ; empty slot → nothing to do
    LD A,($D8D7)                        ; wSaveMode
    SET 4,A
    LD ($D8D7),A                        ; wSaveMode bit4 = 1 (processing)
    LD A,L
    LDH ($D7),A                         ; hWarpPtr lo = record ptr lo
    LD A,H
    LDH ($D8),A                         ; hWarpPtr hi = record ptr hi
    INC HL
    INC HL
    INC HL                              ; HL → record[3] (tile-action type)
    LD A,(HL)
    DEC A                               ; type-1
    SWAP A                              ; (type-1) * 16
    ADD A,A                             ; (type-1) * 32  = table offset
    LD HL,$D7D2                         ; wTileActionTbl base
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A                              ; HL = &wTileActionTbl[(type-1)*32]
    LD A,L
    LDH ($D5),A                         ; hCollResult lo = table entry ptr
    LD A,H
    LDH ($D6),A                         ; hCollResult hi
    LDH A,($D7)                         
    ADD A,$02                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    ADD A,$1A                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    POP AF                              
    CP $01                              ; = 1
    JP Z,$4742                          
    CP $02                              ; = 2
    JP Z,$478A                          
    CP $04                              ; = 4
    JP Z,$4857                          
    CP $05                              ; = 5
    JP Z,$487F                          
    CP $08                              ; = 8
    JP Z,$498C                          
    CP $09                              ; = 9
    JP Z,$49D2                          
    CP $0A                              ; = 10
    JP Z,$4A2C                          
    CP $0B                              ; = 11
    JP Z,$4A52                          
    CP $0C                              ; = 12
    JP Z,$4AA2                          
    CP $0D                              ; = 13
    JP Z,$4B27                          
    CP $0E                              ; = 14
    JP Z,$4B6D                          
    CP $0F                              ; = 15
    JP Z,$4B9B                          
    CP $10                              ; = 16
    JP Z,$4BE7                          
    CP $11                              
    JP Z,$4C33                          
    CP $12                              
    JP Z,$4C65                          
    CP $13                              
    JP Z,$4C9F                          
    CP $14                              
    JP Z,$4D27                          
    CP $15                              
    JP Z,$4DA8                          
    CP $16                              
    JP Z,$507B                          
    CP $17                              
    JP Z,$50C6                          
    CP $18                              
    JP Z,$54C8                          
    CP $19                              
    JP Z,$5546                          
    LDH A,($D5)                         ; hCollResult
    ADD A,$05                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    SET 0,(HL)                          
    RES 6,(HL)                          
    LD A,($C8A4)                        
    AND $03                             ; joypad: A+B
    CP $01                              ; = 1
    RET Z                               
    LDH A,($D7)                         
    ADD A,$04                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    LD E,A                              
    INC BC                              
    LD A,(BC)                           
    LD D,A                              
    LD A,D                              
    OR E                                
    JR Z,$46BA                          
    BIT 7,D                             
    JR NZ,$468C                         
    LDH A,($D7)                         
    ADD A,$04                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    SUB $01                             
    LD (BC),A                           
    INC BC                              
    LD A,(BC)                           
    SBC A,$00                           
    LD (BC),A                           
    INC HL                              
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$467B                         
    LD (HL),$03                         
    LD A,L                              
    ADD A,$12                           
    LD L,A                              
    LD A,H                              
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD D,(HL)                           
    LD E,A                              
    INC DE                              
    DEC HL                              
    LD (HL),E                           
    INC HL                              
    LD (HL),D                           
    RET                                 
    LDH A,($D7)                         
    ADD A,$04                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    ADD A,$01                           
    LD (BC),A                           
    INC BC                              
    LD A,(BC)                           
    ADC A,$00                           
    LD (BC),A                           
    INC HL                              
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$46A9                         
    LD (HL),$01                         
    LD A,L                              
    ADD A,$12                           
    LD L,A                              
    LD A,H                              
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD D,(HL)                           
    LD E,A                              
    DEC DE                              
    DEC HL                              
    LD (HL),E                           
    INC HL                              
    LD (HL),D                           
    RET                                 
    LDH A,($D7)                         
    ADD A,$06                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    LD E,A                              
    INC BC                              
    LD A,(BC)                           
    LD D,A                              
    LD A,D                              
    OR E                                
    JR Z,$472D                          
    BIT 7,D                             
    JR NZ,$46FF                         
    LDH A,($D7)                         
    ADD A,$06                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    SUB $01                             
    LD (BC),A                           
    INC BC                              
    LD A,(BC)                           
    SBC A,$00                           
    LD (BC),A                           
    INC HL                              
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$46EE                         
    LD (HL),$00                         
    LD A,L                              
    ADD A,$14                           
    LD L,A                              
    LD A,H                              
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD D,(HL)                           
    LD E,A                              
    INC DE                              
    DEC HL                              
    LD (HL),E                           
    INC HL                              
    LD (HL),D                           
    RET                                 
    LDH A,($D7)                         
    ADD A,$06                           
    LD C,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD B,A                              
    LD A,(BC)                           
    ADD A,$01                           
    LD (BC),A                           
    INC BC                              
    LD A,(BC)                           
    ADC A,$00                           
    LD (BC),A                           
    INC HL                              
    LD A,($D8D7)                        ; wSaveMode
    BIT 5,A                             
    JR NZ,$471C                         
    LD (HL),$02                         
    LD A,L                              
    ADD A,$14                           
    LD L,A                              
    LD A,H                              
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD D,(HL)                           
    LD E,A                              
    DEC DE                              
    DEC HL                              
    LD (HL),E                           
    INC HL                              
    LD (HL),D                           
    RET                                 
    LDH A,($D5)                         ; hCollResult
    ADD A,$05                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    RES 0,(HL)                          
    LDH A,($D7)                         
    LD L,A                              
    LDH A,($D8)                         
    LD H,A                              
    LD (HL),$00                         
    RET                                 
    LD BC,$4770                         

; ------------------------------------------------------------
; Bank4_Sub_4745 — scripted-motion stepper (curve-table driven)
;   Advances one step of a scripted scroll/warp animation.
;   Inputs:  BC = base of a motion-curve table (2 bytes per step,
;                 a signed 16-bit delta; $80 in the low byte = end marker)
;            HL = 16-bit accumulator to add the delta into (scroll budget)
;            hWarpPtr ($FFD7:D8) → warp record; record[1] = step counter
;   Each call:
;     1. load & increment the step counter at record[1] (post-increment),
;     2. index the curve table at BC + 2*counter,
;     3. if the entry's low byte == $80 → animation done: zero the step
;        counter (via the $4767 tail) and return,
;     4. otherwise add the 16-bit curve delta to (HL) and return.
;   The blocks that follow each preload BC with a specific curve address
;   ($4790/$47D9/$485D/$4892/…) — one per warp/door/stair animation type —
;   and then CALL/JP here.
; ------------------------------------------------------------
Bank4_Sub_4745:
    LDH A,($D7)                         ; hWarpPtr lo
    ADD A,$01
    LD E,A
    LDH A,($D8)                         ; hWarpPtr hi
    ADC A,$00
    LD D,A                              ; DE = &record[1] (step counter)
    LD A,(DE)
    PUSH AF                             ; save current step
    INC A
    LD (DE),A                           ; record[1]++ (advance step)
    POP AF
    ADD A,A                             ; step * 2 (word stride)
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A                              ; BC = &curve[step]
    LD A,(BC)
    CP $80                              ; end-of-curve marker?
    JR Z,$4767                          ; yes → reset counter (tail below)
    ADD A,(HL)                          ; accumulator += delta (low byte)
    LD (HL+),A
    INC BC
    LD A,(BC)
    ADC A,(HL)                          ; accumulator += delta (high byte)
    LD (HL),A
    RET
    ; $4767 tail: curve finished → clear the step counter at record[1]
    LDH A,($D7)
    LD L,A
    LDH A,($D8)
    LD H,A
    LD (HL),$00
    RET
    LD BC,$4790                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$47D9                         
    CALL $4745                            ; → Bank4_Sub_4745
    LD A,($C850)                        ; wAnimActive
    OR A                                
    RET NZ                              
    LD A,($C8A6)                        ; wFrameCntLo
    AND $03                             ; joypad: A+B
    RET Z                               
    LDH A,($8E)                         
    INC A                               
    AND $03                             ; joypad: A+B
    LDH ($8E),A                         
    JP $454B                              ; → Bank4_Sub_454B
    LD BC,$485D                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4892                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    INC (HL)                            
    INC (HL)                            
    RET                                 
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    INC A                               
    LD (DE),A                           
    CP $40                              
    JR NZ,$48FC                         
    LDH A,($D7)                         
    LD L,A                              
    LDH A,($D8)                         
    LD H,A                              
    LD (HL),$00                         
    RET                                 
    LD A,($CA37)                        
    LD L,A                              
    LD H,$00                            
    ADD HL,HL                           
    ADD HL,HL                           
    LD A,L                              
    ADD A,$73                           
    LD L,A                              
    LD A,H                              
    ADC A,$C9                           
    LD H,A                              
    LDH A,($92)                         ; hSCX_lo
    LD (HL+),A                          
    LDH A,($95)                         ; hSCY_lo
    LD (HL+),A                          
    LDH A,($93)                         ; hSCX_hi
    SWAP A                              
    LD C,A                              
    LDH A,($96)                         ; hSCY_hi
    OR C                                
    LD (HL+),A                          
    LDH A,($8B)                         
    LD C,A                              
    LDH A,($8D)                         
    OR C                                
    LD (HL+),A                          
    LD A,($CA37)                        
    INC A                               
    LD ($CA37),A                        
    CP $31                              
    RET C                               
    XOR A                               
    LD ($CA37),A                        
    RET                                 
    LD BC,$494C                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($92)                         ; hSCX_lo
    LD L,A                              
    LDH A,($93)                         ; hSCX_hi
    LD H,A                              
    LD A,L                              
    SUB $02                             
    LD L,A                              
    LD A,H                              
    SBC A,$00                           
    LD H,A                              
    LD A,L                              
    LDH ($92),A                         ; → hSCX_lo
    LD A,H                              
    LDH ($93),A                         ; → hSCX_hi
    RET                                 
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    INC A                               
    LD (DE),A                           
    CP $FF                              
    JR NZ,$49AE                         
    LDH A,($D7)                         
    LD L,A                              
    LDH A,($D8)                         
    LD H,A                              
    LD (HL),$00                         
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    LD (HL),$00                         
    RET                                 
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    POP AF                              
    LD B,$0F                            
    CP $20                              
    JR C,$49CA                          
    LD B,$07                            
    CP $50                              
    JR C,$49CA                          
    LD B,$03                            
    CP $90                              
    JR C,$49CA                          
    LD B,$01                            
    AND B                               
    OR A                                
    LD (HL),$00                         
    RET Z                               
    LD (HL),$40                         
    RET                                 
    LD BC,$4A0A                         
    CALL $4745                            ; → Bank4_Sub_4745
    LD A,($C850)                        ; wAnimActive
    OR A                                
    RET NZ                              
    LDH A,($D5)                         ; hCollResult
    ADD A,$05                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD (HL),$00                         
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    SRL A                               
    SRL A                               
    AND $03                             ; joypad: A+B
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    ADD A,$06                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    POP AF                              
    LD (HL),A                           
    JP $454B                              ; → Bank4_Sub_454B
    LD BC,$4A32                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4A58                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4AB5                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    DEC (HL)                            
    DEC (HL)                            
    RET                                 
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    INC A                               
    LD (DE),A                           
    CP $FF                              
    JR NZ,$4B49                         
    LDH A,($D7)                         
    LD L,A                              
    LDH A,($D8)                         
    LD H,A                              
    LD (HL),$00                         
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    LD (HL),$40                         
    RET                                 
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    POP AF                              
    LD B,$0F                            
    CP $20                              
    JR C,$4B65                          
    LD B,$07                            
    CP $50                              
    JR C,$4B65                          
    LD B,$03                            
    CP $90                              
    JR C,$4B65                          
    LD B,$01                            
    AND B                               
    OR A                                
    LD (HL),$40                         
    RET Z                               
    LD (HL),$00                         
    RET                                 
    LD A,($C8A6)                        ; wFrameCntLo
    AND $03                             ; joypad: A+B
    RET NZ                              
    LD BC,$4B79                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4BA1                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4BED                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4C39                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4C6B                         
    JP $4745                              ; → Bank4_Sub_4745
    LD BC,$4CA5                         
    JP $4745                              ; → Bank4_Sub_4745
    CALL $4D5C                            ; → Bank4_Sub_4D5C
    LD A,($C850)                        ; wAnimActive
    OR A                                
    RET NZ                              
    LDH A,($D5)                         ; hCollResult
    ADD A,$05                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD (HL),$00                         
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    SRL A                               
    SRL A                               
    AND $03                             ; joypad: A+B
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    ADD A,$06                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    POP AF                              
    LD (HL),A                           
    JP $454B                              ; → Bank4_Sub_454B


; ------------------------------------------------------------
; Bank4_Sub_4D5C — warp animation stepper with blink phase
;   Runs on even frames only (skips when wFrameCntLo bit0 set → ~30 Hz).
;   Advances the warp record's step counter (record[1]); when it wraps to
;   $FF the animation is over — it zeroes both the step counter and the
;   cached tile-action entry (hCollResult) and returns.
;   Otherwise it drives a two-phase effect:
;     • blink phase ($4DA0): pick a bit-mask from the counter magnitude
;       ($0F under $20, $07 under $50, $03 under $90, else $01) and toggle
;       the target tile byte between $00 and $40 — a flashing sprite.
;     • scroll phase ($4DBB+): seed the step from wZoneCount ($D8E3) and
;       pick a motion-curve table via wScrollStyle ($D8E4)
;       ($4DF3 for style 1, $4E95 for style 2, …) to animate the camera.
; ------------------------------------------------------------
Bank4_Sub_4D5C:
    LD A,($C8A6)                        ; wFrameCntLo
    AND $01                             ; run on even frames only
    RET NZ
    LDH A,($D7)                         ; hWarpPtr lo
    ADD A,$01
    LD E,A
    LDH A,($D8)                         ; hWarpPtr hi
    ADC A,$00
    LD D,A                              ; DE = &record[1] (step counter)
    LD A,(DE)
    INC A
    LD (DE),A                           ; step++
    CP $FF                              
    JR NZ,$4D84                         
    LDH A,($D7)                         
    LD L,A                              
    LDH A,($D8)                         
    LD H,A                              
    LD (HL),$00                         
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    LD (HL),$00                         
    RET                                 
    PUSH AF                             
    LDH A,($D5)                         ; hCollResult
    LD L,A                              
    LDH A,($D6)                         
    LD H,A                              
    POP AF                              
    LD B,$0F                            
    CP $20                              
    JR C,$4DA0                          
    LD B,$07                            
    CP $50                              
    JR C,$4DA0                          
    LD B,$03                            
    CP $90                              
    JR C,$4DA0                          
    LD B,$01                            
    AND B                               
    OR A                                
    LD (HL),$00                         
    RET Z                               
    LD (HL),$40                         
    RET                                 
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    OR A                                
    JR NZ,$4DC2                         
    LD A,($D8E3)                        
    LD C,A                              
    LD A,$0A                            
    SUB C                               
    ADD A,A                             
    ADD A,A                             
    ADD A,A                             
    INC A                               
    LD (DE),A                           
    LD A,($D8E4)                        
    LD BC,$4DF3                         
    CP $01                              ; = 1
    JR Z,$4DDD                          
    LD BC,$4E95                         
    CP $02                              ; = 2
    JR Z,$4DDD                          
    LD BC,$4F37                         
    CP $03                              ; = 3
    JR Z,$4DDD                          
    LD BC,$4FD9                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD B,(HL)                           
    LD C,A                              
    DEC BC                              
    DEC BC                              
    LD A,B                              
    LD (HL-),A                          
    LD (HL),C                           
    RET                                 
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    OR A                                
    JR NZ,$5095                         
    LD A,($D8E3)                        
    LD C,A                              
    LD A,$0A                            
    SUB C                               
    ADD A,A                             
    ADD A,A                             
    ADD A,A                             
    INC A                               
    LD (DE),A                           
    LD A,($D8E4)                        
    LD BC,$4DF3                         
    CP $01                              ; = 1
    JR Z,$50B0                          
    LD BC,$4E95                         
    CP $02                              ; = 2
    JR Z,$50B0                          
    LD BC,$4F37                         
    CP $03                              ; = 3
    JR Z,$50B0                          
    LD BC,$4FD9                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD B,(HL)                           
    LD C,A                              
    INC BC                              
    INC BC                              
    LD A,B                              
    LD (HL-),A                          
    LD (HL),C                           
    RET                                 
    LD A,($D8E3)                        
    LD BC,$5144                         
    CP $01                              ; = 1
    JR Z,$510B                          
    LD BC,$5156                         
    CP $02                              ; = 2
    JR Z,$510B                          
    LD BC,$5178                         
    CP $03                              ; = 3
    JR Z,$510B                          
    LD BC,$51AA                         
    CP $04                              ; = 4
    JR Z,$510B                          
    LD BC,$51EC                         
    CP $05                              ; = 5
    JR Z,$510B                          
    LD BC,$523E                         
    CP $06                              ; = 6
    JR Z,$510B                          
    LD BC,$52A0                         
    CP $07                              ; = 7
    JR Z,$510B                          
    LD BC,$5312                         
    CP $08                              ; = 8
    JR Z,$510B                          
    LD BC,$5394                         
    CP $09                              ; = 9
    JR Z,$510B                          
    LD BC,$5426                         
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    PUSH AF                             
    INC A                               
    LD (DE),A                           
    POP AF                              
    ADD A,A                             
    ADD A,C                             
    LD C,A                              
    LD A,$00                            
    ADC A,B                             
    LD B,A                              
    LD A,(BC)                           
    CP $80                              
    JP Z,$4767                          
    LD D,A                              
    LD A,(HL)                           
    SUB D                               
    LD (HL+),A                          
    INC BC                              
    LD A,(BC)                           
    LD D,A                              
    LD A,(HL)                           
    SBC A,D                             
    LD (HL),A                           
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD B,(HL)                           
    LD C,A                              
    DEC BC                              
    DEC BC                              
    LD A,B                              
    LD (HL-),A                          
    LD (HL),C                           
    RET                                 
    LD A,($D8E3)                        
    LD BC,$5144                         
    CP $01                              ; = 1
    JR Z,$550D                          
    LD BC,$5156                         
    CP $02                              ; = 2
    JR Z,$550D                          
    LD BC,$5178                         
    CP $03                              ; = 3
    JR Z,$550D                          
    LD BC,$51AA                         
    CP $04                              ; = 4
    JR Z,$550D                          
    LD BC,$51EC                         
    CP $05                              ; = 5
    JR Z,$550D                          
    LD BC,$523E                         
    CP $06                              ; = 6
    JR Z,$550D                          
    LD BC,$52A0                         
    CP $07                              ; = 7
    JR Z,$550D                          
    LD BC,$5312                         
    CP $08                              ; = 8
    JR Z,$550D                          
    LD BC,$5394                         
    CP $09                              ; = 9
    JR Z,$550D                          
    LD BC,$5426                         
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    PUSH AF                             
    INC A                               
    LD (DE),A                           
    POP AF                              
    ADD A,A                             
    ADD A,C                             
    LD C,A                              
    LD A,$00                            
    ADC A,B                             
    LD B,A                              
    LD A,(BC)                           
    CP $80                              
    JP Z,$4767                          
    LD D,A                              
    LD A,(HL)                           
    SUB D                               
    LD (HL+),A                          
    INC BC                              
    LD A,(BC)                           
    LD D,A                              
    LD A,(HL)                           
    SBC A,D                             
    LD (HL),A                           
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    LD A,(HL+)                          
    LD B,(HL)                           
    LD C,A                              
    INC BC                              
    INC BC                              
    LD A,B                              
    LD (HL-),A                          
    LD (HL),C                           
    RET                                 
    LD BC,$5559                         
    CALL $4745                            ; → Bank4_Sub_4745
    LDH A,($D5)                         ; hCollResult
    ADD A,$18                           
    LD L,A                              
    LDH A,($D6)                         
    ADC A,$00                           
    LD H,A                              
    DEC (HL)                            
    DEC (HL)                            
    RET                                 
    LD BC,$55CA                         
    CALL $4745                            ; → Bank4_Sub_4745
    LD A,($C850)                        ; wAnimActive
    OR A                                
    RET NZ                              
    LDH A,($D7)                         
    ADD A,$01                           
    LD E,A                              
    LDH A,($D8)                         
    ADC A,$00                           
    LD D,A                              
    LD A,(DE)                           
    SRL A                               
    SRL A                               
    AND $03                             ; joypad: A+B
    LDH ($8E),A                         
    JP $454B                              ; → Bank4_Sub_454B


; ------------------------------------------------------------
; Bank4_Fn5  ($55EC)  — first-step initiator
; Called by bank1/bank6 (always with wSaveMode already zeroed by the caller).
; Resets wStepCtr to 0, then falls into Bank4_Sub_55F5 past the counter
; increment — so the first query to bank12–15 happens with step number 0.
; Subsequent per-frame calls come from Fn4, which calls Sub_55F5 directly
; (incrementing wStepCtr before each query).
; ------------------------------------------------------------
Bank4_Fn5:
    XOR A
    LD ($D8D5),A                        ; wStepCtr lo = 0
    LD ($D8D6),A                        ; wStepCtr hi = 0
    JR $5605                            ; jump into Sub_55F5 past the wStepCtr++ → CALL $71EF

; ------------------------------------------------------------
; Bank4_Sub_55F5  ($55F5)  — step counter increment + movement dispatch
; Increments wStepCtr, calls Bank4_Sub_71EF (→ bank12/13/14/15 based on wAreaType),
; then acts on the return values in B and C:
;
;   B AND C == $FF  (both $FF):
;       No joypad input or player blocked this frame.
;       wSaveMode = 0 (nothing queued), return.
;
;   B AND C != $FF  (at least one not $FF):
;       Movement or event was triggered by bank12–15.
;       SET wSaveMode bit0 (movement active), then:
;
;       B == $FF, C = warp type:
;           RST $00 dispatch on C — jump to warp-type handler via vector table.
;           (bank12–15 also set wScrollX/wScrollY and bit3 at this point)
;
;       B != $FF  (B = dest_hi, C = dest_lo):
;           SET wSaveMode bit1 (warp destination queued).
;           Store wWarpDest = {C, B} ($D8D9/$D8DA).
; ------------------------------------------------------------
Bank4_Sub_55F5:
    LD A,($D8D5)
    ADD A,$01
    LD ($D8D5),A                        ; wStepCtr lo++
    LD A,($D8D6)
    ADC A,$00
    LD ($D8D6),A                        ; wStepCtr hi (carry)
    CALL $71EF                            ; → Bank4_Sub_71EF (area-type dispatcher → bank12–15)
    ; --- $5605: check return values ---
    LD A,B
    AND C
    CP $FF
    JR NZ,$5613                         ; not both $FF → movement triggered
    ; B=C=$FF: idle / blocked — clear everything
    XOR A
    LD ($D8D7),A                        ; wSaveMode = 0 (no movement this frame)
    RET
    ; --- $5613: movement triggered — set bit0 ---
    LD HL,$D8D7
    SET 0,(HL)                          ; wSaveMode bit0 = 1 (movement active)
    LD A,B
    CP $FF
    JP NZ,$56EC                         ; B != $FF → warp destination path
    ; B == $FF: cell is walkable/behavioural — low byte C = TILE-BEHAVIOR TYPE
    LD A,C                              ; C = tile-behavior type ($00..$65)
    RST $00                             ; → dispatch through the $5620 table (below)
    ; --- TILE-BEHAVIOR DISPATCH TABLE ($5620, 102 entries) ---
    ;   Reached when the faced cell value's high byte is $FF (walkable, not text).
    ;   The low byte selects one of 102 handlers. MOST handlers advance the map
    ;   coordinate ($D8D5++) to continue the step and then do tile-specific work;
    ;   others trigger scroll / warp / state changes / SFX / text.  Notable types:
    ;     $00-$05  plain walkable step (per area class)
    ;     $19      gated on wSaveMode $D8D7 bit4
    ;     $1D/$1E  SET/RES $D8D7 bit5 (suppress sprite-direction update)
    ;     $20      SET $C8EB bit6        ;  $22  SET $D8D7 bit6
    ;     $24      → bank12 fn1 (scroll, LD HL,$0C01) when wAreaType<$06
    ;     $27/$35  → bank1 fn9 + fn3 (RST $10 $0109/$0103 — state transition)
    ;     $39      → Bank4_ExamineCell ($64A7) — query cell + SHOW ITS TEXT
    ;     $3C/$3D  SET $D8D8 bit0/bit1
    ;     $3E      CALL $1A5B (SFX) + touch $C88E    ;  $4B  CALL $1EB4 (SFX)
    ;     $4C      gated on wJoyEdge $C846           ;  $61  → bank12 fn2 (attr paint)
    ;     $62      $8DA0 VRAM fill                   ;  many others = door/warp/event
    ; ------------------------------------------------------------
    ; TileBehaviorTable  ($5620)  — 102 dw handlers, indexed by the cell low byte.
    ; (RST $00 at $561F dispatches through this; JP NZ,$56EC below skips it when
    ;  the cell is a text event.  Sits inline between the RST $00 and $56EC.)
    ; ------------------------------------------------------------
TileBehaviorTable:                     ; $5620  (102 handlers, indexed by cell low byte)
    dw $5711,$5740,$576F,$5788,$57A1,$57EB,$5819,$5824   ; $5620 (types $00-$07)
    dw $5842,$5843,$5860,$5898,$58D0,$5968,$59D2,$5A02   ; $5630 (types $08-$0F)
    dw $5A6F,$5AC5,$5B1B,$5B49,$5B79,$5B8F,$5BD4,$5BDB   ; $5640 (types $10-$17)
    dw $5C14,$5C6D,$5C86,$5CCF,$5D1A,$5D4B,$5D53,$5D5B   ; $5650 (types $18-$1F)
    dw $5E5E,$5E6D,$5E87,$5E8F,$5F13,$5F36,$5F52,$5F5C   ; $5660 (types $20-$27)
    dw $5F67,$5F9A,$5FDB,$6002,$6064,$6093,$61E0,$623A   ; $5670 (types $28-$2F)
    dw $6253,$62AB,$62DD,$6332,$634F,$63BB,$63C6,$6401   ; $5680 (types $30-$37)
    dw $643F,$64A7,$64C2,$65AB,$6618,$6620,$6628,$6632   ; $5690 (types $38-$3F)
    dw $6646,$669D,$66BD,$6723,$676F,$67B1,$67FD,$6822   ; $56A0 (types $40-$47)
    dw $684D,$6866,$687F,$6898,$68A1,$68BA,$68D7,$690B   ; $56B0 (types $48-$4F)
    dw $6957,$696C,$69A9,$6A61,$6ACE,$6AFA,$6B3A,$6B73   ; $56C0 (types $50-$57)
    dw $6BA0,$6BDF,$6D56,$6D84,$6D93,$6F64,$6F89,$6F9B   ; $56D0 (types $58-$5F)
    dw $6FFB,$7038,$705B,$707F,$70D5,$71D2   ; $56E0 (types $60-$65)
    ; --- $56EC: TEXT/EVENT path (B != $FF: cell value B:C is a message id) ---
    LD HL,$D8D7
    SET 1,(HL)                          ; wSaveMode bit1 = 1 (destination queued / locked)
    LD A,C
    LD ($D8D9),A                        ; wWarpDest/wEventVal lo = C
    LD A,B
    LD ($D8DA),A                        ; wWarpDest/wEventVal hi = B
    RET

; ============================================================================
; TEXT EVENTS — the map-cell value doubles as a MESSAGE ID
; ============================================================================
; Sub_71EF forwards the "cell in front of the player" query to bank12-15 fn0,
; which returns that map cell's 16-bit VALUE in BC (see overworld/bank12.asm:
; Bank12_Fn0). For sign / NPC / event cells that value is a GLOBAL MESSAGE ID.
; Two paths below hand it to MsgBankRouter (ROM0 $0EC5), which splits the id by
; high/low byte, re-bases it to a bank-local index ($C822/$C823), and RST $10s
; into the owning text bank's fn0 (banks 66-75/78) — e.g. bank66 (NPC dialogue)
; for ids $0000-$00E1.
; ------------------------------------------------------------
; Bank4_Fn6  ($56FA)  — flush a QUEUED text event (per-frame)
;   If Sub_55F5 queued an event last frame (wSaveMode $D8D7 bit1), consume the
;   flag and display the stored cell value ($D8D9/$D8DA) as a message.
;   (The "wWarpDest" slot $D8D9/$D8DA is really the queued cell value = event id.)
; ------------------------------------------------------------
Bank4_Fn6:
    LD A,($D8D7)                        ; wSaveMode
    BIT 1,A
    RET Z                               ; bit1 clear → nothing queued
    LD HL,$D8D7
    RES 1,(HL)                          ; consume the queued-event flag
    LD A,($D8D9)
    LD L,A                              ; L = queued cell value lo
    LD A,($D8DA)
    LD H,A                              ; HL = cell value = GLOBAL message id
    CALL $0EC5                          ; MsgBankRouter (ROM0) → route to text bank + print
    RET

; ------------------------------------------------------------
; Bank4_ExamineCell  ($64A7)  — step, show the faced cell's message, then move
;   Bumps wStepCtr, queries the cell in front (Sub_71EF → bank12-15 fn0 → BC =
;   16-bit cell value), displays it via MsgBankRouter, then tail-jumps to the
;   movement dispatch (Sub_55F5).  This is the direct examine/interact path.
; ------------------------------------------------------------
Bank4_ExamineCell:
    LD A,($D8D5)
    ADD A,$01
    LD ($D8D5),A                        ; wStepCtr lo++
    LD A,($D8D6)
    ADC A,$00
    LD ($D8D6),A                        ; wStepCtr hi
    CALL $71EF                          ; Sub_71EF → bank12-15 fn0: BC = faced cell value
    LD L,C
    LD H,B                              ; HL = cell value = GLOBAL message id
    CALL $0EC5                          ; MsgBankRouter → route + print
    JP $55F5                            ; tail → Bank4_Sub_55F5 (movement dispatch)
; ============================================================================


; ------------------------------------------------------------
; Bank4_Sub_71EF — area-type → collision-bank dispatcher
;   Reads wAreaType ($D8D3) and forwards the movement/collision query to
;   the bank that owns that class of map, by area-type range:
;     < $06        → bank12/fn0   (e.g. towns / interiors)
;     $06 .. $1F   → bank13/fn0   (e.g. overworld)
;     $20 .. $3F   → bank14/fn0   (e.g. dungeons)
;     >= $40       → bank15/fn0   (e.g. special / battle maps)
;   Each target reads the joypad, tests collision, and returns the step
;   result in B/C (see Sub_55F5). Called by Fn5 and Sub_55F5.
; ------------------------------------------------------------
Bank4_Sub_71EF:
    LD A,($D8D3)                        ; wAreaType
    CP $06                              ; < 6?
    JR NC,$71FB                         ; no → check next range
    LD HL,$0C00
    RST $10                               ; → bank12/fn0  (area type < $06)
    RET
    CP $20                              ; < $20?
    JR NC,$7204
    LD HL,$0D00
    RST $10                               ; → bank13/fn0  (area type $06–$1F)
    RET
    CP $40                              ; < $40?
    JR NC,$720D
    LD HL,$0E00
    RST $10                               ; → bank14/fn0  (area type $20–$3F)
    RET
    LD HL,$0F00
    RST $10                               ; → bank15/fn0  (area type >= $40)
    RET
