; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 22  (Monster storage + area scroll boundary handler)
; ============================================================================
;
; Called from: bank11/fn8 (sub-area scroll check, via fn8/fn9 here)
;              various battle/monster management code (via fn0–fn7)
;
; Bank 22 memory map:
;   File offset $58000-$5BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 22 ($16)
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; TWO SYSTEMS in this bank:
;
; [1] MONSTER STORAGE MANAGER (fn0–fn7)
;   Manages the monster team / storage box WRAM arrays.
;   Monster records at $CAC1, stride = $95 bytes, max 20 slots ($14 count).
;   $CAC0: index of last-used / active slot.
;   fn0: scans for free slot (first zero byte in slot array),
;        initializes it with zeroed + $FF-filled regions, copies ROM
;        template data ($D66E→$DA6F, $D703→$DA70), calls bank3/fn1
;        (LD HL,$0301; RST $10 → monster stat loader), sets up
;        stat/EXP fields from $DA71, $DA33, $DA77 (clamped to 99 = $63).
;
; [2] AREA SCROLL BOUNDARY HANDLER (fn8–fn9)
;   fn8: checks if the player is at an area scroll boundary:
;     Guard flags: $C8EB bits 2/5/6 (busy flags), $C850 (palette fade),
;       $C93E bit 1.  All must be clear to proceed.
;     Main area (wSubAreaFlag==0): BC = $0050 (areas $54/$55/$56) or $0064.
;     Sub-area (wSubAreaFlag!=0): uses table $6FAB[wAreaID × 8] indexed by
;       hScrollDir >> 2, loads 2-byte threshold BC.
;     Calls bank1/fn13 (LD HL,$010D; RST $10) with scroll threshold in BC.
;   fn9: sub-area tile data pointer resolver:
;     DE = $7896 (type A) or $7A96 (type B, when wSubAreaTypeFlag == $02)
;     idx = wSubAreaScrollIdxArr[wScrollCount]
;     returns DE = table[idx × 2] (tile data ROM ptr for current sub-area scroll)
;
; Function table at $58001 (bank 22 $4001):
;   fn0:  $4015  ← monster slot finder + initializer
;   fn1:  $485C
;   fn2:  $456E  ← monster stat setup helper (called by fn0)
;   fn3:  $45A3
;   fn4:  $474A
;   fn5:  $5B4E
;   fn6:  $5FE4
;   fn7:  $6DB0
;   fn8:  $6F05  ← area scroll boundary check (called from bank11/fn8)
;   fn9:  $7033  ← sub-area tile data pointer resolver
;   fn10: addr in WRAM ($C111) — likely a RAM-based trampoline
;   fn11: ROM0 range ($06CA) — called from ROM0
;
; Key WRAM variables:
;   $CA40           — monster slot index (copy of $CAC0)
;   $CAC0           — active/free monster slot index (0-based)
;   $CAC1           — monster data array base (20 × $95 bytes per monster)
;   $CAEA           — secondary monster field region (within slot 0 area)
;   $CAF2           — tertiary monster field region
;   $CACA, $CACB    — monster stats (HP-related, loaded from $DA71/$DA33)
;   $CB23           — monster stat (EXP or level, clamped to $63 = 99 max)
;   $C8A9           — scroll/area state index (used by fn8 sub-area lookup)
;   $C8EB           — busy flag byte (bits 2/5/6 gate fn8)
;   $C850           — palette fade active (gates fn8)
;   $C93E           — scroll state flags (bit 1 gates fn8)
;   $C925  wScrollCount  — current scroll zone index
;   $C93F  wSubAreaTypeFlag  — 0/$01 = type A, $02 = type B (fn9 table select)
;          RESOLVED: this is the WORLD CATEGORY = catTable($6056)[worldid % 5];
;          $6056 bytes = 00 00 00 01 02 (categories 0/0/0/1/2). ($21CA = 8-bit
;          divide: in B=dividend,A=divisor → out B=quotient, A=remainder.)
;   $C940  wSubAreaScrollIdxArr — scroll index array = a 4x4 ROOM GRID (16 entries,
;          indexed by wScrollCount $C925 = row*4+col). Each entry = a layout id
;          into bank23 $5215 → {block, bank61}. fn6 ($5FE4→$6060) FILLS it:
;          category 2 → copy 16 bytes raw from $7736 + (worldid%21)*16;
;          else → build from $7096 with per-room remap ($6744/$6800) + SWAP
;          nibbles + per-world offset. So a "world" = up to 16 rooms of outdoor
;          screens (the DQM traveler's-gate "dungeons"). WHICH world = runtime
;          ($C899 world idx, set by gate scripts in banks $50/$52/$53/$57/$58).
;   $C968  wAreaID  — area number (fn8 area branch)
;   $C969  wSubAreaFlag  — non-zero = sub-area mode
;   $FFAA  hScrollDir  — scroll direction (fn8: >> 2 to compare $0C/$0D/$0E)

SECTION "Bank22 Functions", ROMX[$4000], BANK[$16]


; ============================================================================
; Bank22_Fn0  ($4015)  — Monster slot finder + initializer
; ============================================================================
; Finds the first free slot in the monster record array ($CAC1, 20 entries,
; stride $95 = 149 bytes each) by scanning for the first entry where byte[0] == 0.
; Saves the free slot index C to $CAC0 and $CA40.
; Initializes the new monster record:
;   CALL $41B1 (set HL to slot pointer), memset $95 bytes with $00 (CALL $169A)
;   Fills $CAEA+8 bytes with $FF (unset marker)
;   Fills $CAF2+$19 bytes with $FF
;   CALL $41B1 → (HL) = $01 (mark slot as active)
;   Copy ROM template values: $D66E→$DA6F (base stat), $D703→$DA70 (stat 2)
;   Set $DA75=$14 (20), $DA76=$15 (21) (max level parameters)
;   CALL Bank22_Fn2 ($456E) (monster stat calculator)
;   CALL bank3/fn1 (LD HL,$0301; RST $10) (load monster species data)
;   Read $DA71 → $CACA, $DA33 → $CACB (HP / stat fields)
;   Read $DA77 (experience base), clamp to $63 (99 max), write to $CB23
Bank22_Fn0:                                 ; $4015
    LD DE,$CAC1                             ; monster record array base
    LD B,$14                                ; 20 monster slots
    LD C,$00                                ; slot counter
    ; scan loop: find first slot with byte[0] == 0
    LD A,(DE)                               ; $401C
    OR A
    JR Z,$402D                              ; found free slot at index C
    LD A,E
    ADD A,$95                               ; advance by $95 bytes (one slot)
    LD E,A
    LD A,D
    ADC A,$00
    LD D,A
    INC C
    DEC B
    JR NZ,$401C                             ; next slot
    RET                                     ; no free slot found
    ; --- free slot found at index C ---
    LD A,C
    LD ($CAC0),A                            ; save free slot index
    LD ($CA40),A
    LD HL,$CAC1
    CALL $41B1                              ; Sub_41B1: HL = &$CAC1[C × $95]
    LD BC,$0095
    XOR A
    CALL $169A                              ; ROM0 memset: zero $95 bytes
    LD HL,$CAEA
    CALL $41B1
    LD BC,$0008
    LD A,$FF
    CALL $169A                              ; fill 8 bytes with $FF
    LD HL,$CAF2
    CALL $41B1
    LD BC,$0019
    LD A,$FF
    CALL $169A                              ; fill $19 bytes with $FF
    LD HL,$CAC1
    CALL $41B1
    LD (HL),$01                             ; mark slot as active
    LD A,($D66E)
    LD ($DA6F),A                            ; copy base stat template
    LD A,($D703)
    LD ($DA70),A                            ; copy stat 2 template
    LD A,$14
    LD ($DA75),A                            ; max level param
    LD A,$15
    LD ($DA76),A
    CALL $456E                              ; Bank22_Fn2: stat calculator
    ; ... continues with bank3/fn1 call and stat copy ...

; ============================================================================
; Bank22_Sub_41B1  ($41B1)  — Slot pointer calculator
; ============================================================================
; Returns HL = base_array + C × stride.
; Used by fn0 to get pointer to the active monster slot.

; ============================================================================
; Bank22_Fn8  ($6F05)  — Area scroll boundary check
; ============================================================================
; Checks if the player is positioned at a scroll zone boundary and if so,
; initiates a scroll transition.
;
; Guard conditions (all must pass for scroll to trigger):
;   $C8EB bit 2 → RET NZ  (animation busy)
;   $C8EB bit 5 → RET NZ  (scroll busy)
;   $C8EB bit 6 → RET NZ  (transition busy)
;   $C850 != 0  → RET NZ  (palette fade active)
;   $C93E bit 1 → RET NZ  (scroll pending)
;
; Scroll threshold selection:
;   wSubAreaFlag == 0 (main area):
;     BC = $0050 if wAreaID ∈ {$54,$55,$56} (island areas, smaller threshold)
;     BC = $0064 otherwise (standard threshold)
;   wSubAreaFlag != 0 (sub-area):
;     HL = $6FAB + wAreaID × 8 (per-area direction table, 8 bytes = 4 entries)
;     hScrollDir = hAA >> 2 → compare $0C (north)/$0D (south)/$0E (east/west)
;     BC = HL[dir_offset] (2-byte threshold from table)
;     If direction not found → RET (no scroll threshold for this direction)
;
; After threshold selection: PUSH BC
;   Calls bank1/fn13 (LD HL,$010D; RST $10) with scroll params
;   Reads $702B + $C8A9 (scroll boundary data table, indexed by area scroll state)
;   Calls $21B5, $21ED with A=$40 (scroll position handlers)
;
; ROM data table $6FAB:
;   8-byte entries per area, 4 × 2-byte thresholds [N, E, S, W]:
;   Entry format (little-endian 16-bit per direction):
;     All known entries use $008A ($138) or $0096 ($150) or $0000 (unused)
Bank22_Fn8:                                 ; $6F05
    LD A,($C8EB)
    BIT 2,A
    RET NZ                                  ; animation busy
    BIT 5,A
    RET NZ                                  ; scroll busy
    BIT 6,A
    RET NZ                                  ; transition busy
    LD A,($C850)
    OR A
    RET NZ                                  ; palette fade active
    LD A,($C93E)
    BIT 1,A
    RET NZ                                  ; scroll pending
    LD A,($C969)                            ; wSubAreaFlag
    OR A
    JR NZ,$6F39                             ; sub-area path
    ; main area path
    LD BC,$0050                             ; default threshold for island areas
    LD A,($C968)                            ; wAreaID
    CP $54
    JR Z,$6F62                             ; island area → BC=$0050
    CP $55
    JR Z,$6F62
    CP $56
    JR Z,$6F62
    LD BC,$0064                             ; standard threshold
    JR $6F62
    ; sub-area path ($6F39)
    LD HL,$6FAB                             ; per-area direction table
    LD A,($C968)                            ; wAreaID
    ADD A,A
    ADD A,A
    ADD A,A                                 ; × 8
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A                                  ; HL = $6FAB + wAreaID × 8
    LDH A,($AA)                             ; hScrollDir
    SRL A
    SRL A                                   ; >> 2 (normalize direction)
    CP $0C
    JR Z,$6F5F                              ; north → HL[+0]
    INC HL
    INC HL
    CP $0D
    JR Z,$6F5F                              ; south → HL[+2]
    INC HL
    INC HL
    CP $0E
    JR Z,$6F5F                              ; east/west → HL[+4]
    RET                                     ; other direction → no scroll
    LD A,(HL+)
    LD B,(HL)
    LD C,A                                  ; BC = threshold from table
    ; $6F62: trigger scroll
    PUSH BC
    LD HL,$010D
    RST $10                                 ; bank1/fn13 (scroll trigger)
    LD HL,$702B
    LD A,($C8A9)                            ; scroll area state index
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP BC
    CALL $21B5                              ; scroll position handler
    LD A,$40
    CALL $21ED                              ; finalize scroll position

; ============================================================================
; Bank22_Fn9  ($7033)  — Sub-area tile data pointer resolver
; ============================================================================
; Resolves a 2-byte ROM pointer to sub-area tile data for the current
; scroll zone, using the same wSubAreaTypeFlag / wSubAreaScrollIdxArr
; mechanism as bank23/fn0 but looking up bank22's local tables.
;
; Input:  wSubAreaTypeFlag ($C93F), wScrollCount ($C925),
;         wSubAreaScrollIdxArr ($C940)
; Output: DE = tile data ROM ptr from $7896/$7A96 table
;
; Table select:
;   wSubAreaTypeFlag == $02 → DE base = $7A96 (type B)
;   otherwise              → DE base = $7896 (type A)
; Lookup:
;   idx = $C940[wScrollCount]
;   DE = (DE_base + idx × 2) → 2-byte ROM ptr
Bank22_Fn9:                                 ; $7033
    LD DE,$7896                             ; default: type A sub-area table
    LD A,($C93F)                            ; wSubAreaTypeFlag
    CP $02
    JR NZ,$7040
    LD DE,$7A96                             ; type B table
    LD A,($C925)                            ; wScrollCount
    LD HL,$C940                             ; wSubAreaScrollIdxArr
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A                                  ; HL = &wSubAreaScrollIdxArr[wScrollCount]
    LD L,(HL)                               ; idx = wSubAreaScrollIdxArr[wScrollCount]
    LD H,$00
    ADD HL,HL                               ; idx × 2
    ADD HL,DE                               ; HL = table_base + idx × 2
    LD E,(HL)
    INC HL
    LD D,(HL)                               ; DE = tile data ptr
    RET

; ============================================================================
; ROM DATA  ($6FAB)
; ============================================================================
; $6FAB  Per-area scroll boundary threshold table
;        8 bytes per area entry (4 × 16-bit thresholds for N/E/S/W directions)
;        Known values: $008A = 138 pixels, $0096 = 150 pixels, $0000 = no threshold
;
; $7896  Sub-area type A tile data ptr table (indexed by scroll idx × 2)
; $7A96  Sub-area type B tile data ptr table

; ============================================================================
; SPECIAL BREEDING RECIPES  $4974..$4B2E  (221 entries, indexed by CHILD id)
; ============================================================================
; 2 bytes per child: {parent1, parent2}. $FFFF = no special recipe; $0000 = end.
; Checked by Bank22_Fn3 AFTER the main $4B30 table. parent id may be $F0-$F9
; family wildcard (or $FA = any). Result child = the entry's index.
; ============================================================================
Bank22_SpecialBreed:                        ; $4974
    DB $F0,$F1   ; $4974  child $00(Slime) <- AnySlime x AnyDragon
    DB $F0,$F2   ; $4976  child $01(Slime) <- AnySlime x AnyBeast
    DB $F0,$F3   ; $4978  child $02(Slime) <- AnySlime x AnyBird
    DB $F0,$F4   ; $497A  child $03(Slime) <- AnySlime x AnyPlant
    DB $F0,$F5   ; $497C  child $04(Slime) <- AnySlime x AnyBug
    DB $F0,$F6   ; $497E  child $05(Slime) <- AnySlime x AnyDevil
    DB $F0,$F7   ; $4980  child $06(Slime) <- AnySlime x AnyZomby
    DB $F0,$F8   ; $4982  child $07(Slime) <- AnySlime x AnyMaterl
    DB $FF,$FF   ; $4984  (no special recipe)
    DB $F0,$5A   ; $4986  child $09(Slime) <- AnySlime x Plant
    DB $F0,$2E   ; $4988  child $0A(Slime) <- AnySlime x Beast
    DB $F0,$C6   ; $498A  child $0B(Slime) <- AnySlime x Materl
    DB $F0,$BD   ; $498C  child $0C(Slime) <- AnySlime x Materl
    DB $F0,$33   ; $498E  child $0D(Slime) <- AnySlime x Beast
    DB $FF,$FF   ; $4990  (no special recipe)
    DB $F0,$F9   ; $4992  child $0F(Slime) <- AnySlime x Any???
    DB $F0,$B9   ; $4994  child $10(Slime) <- AnySlime x Materl
    DB $10,$10   ; $4996  child $11(Slime) <- Slime x Slime
    DB $11,$11   ; $4998  child $12(Slime) <- Slime x Slime
    DB $12,$12   ; $499A  child $13(Slime) <- Slime x Slime
    DB $F1,$F0   ; $499C  child $14(Dragon) <- AnyDragon x AnySlime
    DB $F1,$F2   ; $499E  child $15(Dragon) <- AnyDragon x AnyBeast
    DB $F1,$F3   ; $49A0  child $16(Dragon) <- AnyDragon x AnyBird
    DB $F1,$F4   ; $49A2  child $17(Dragon) <- AnyDragon x AnyPlant
    DB $F1,$F5   ; $49A4  child $18(Dragon) <- AnyDragon x AnyBug
    DB $F1,$F6   ; $49A6  child $19(Dragon) <- AnyDragon x AnyDevil
    DB $F1,$F7   ; $49A8  child $1A(Dragon) <- AnyDragon x AnyZomby
    DB $F1,$F8   ; $49AA  child $1B(Dragon) <- AnyDragon x AnyMaterl
    DB $14,$14   ; $49AC  child $1C(Dragon) <- Dragon x Dragon
    DB $F1,$46   ; $49AE  child $1D(Dragon) <- AnyDragon x Bird
    DB $F1,$32   ; $49B0  child $1E(Dragon) <- AnyDragon x Beast
    DB $F1,$53   ; $49B2  child $1F(Dragon) <- AnyDragon x Bird
    DB $F1,$B8   ; $49B4  child $20(Dragon) <- AnyDragon x Materl
    DB $F1,$77   ; $49B6  child $21(Dragon) <- AnyDragon x Bug
    DB $F1,$5F   ; $49B8  child $22(Dragon) <- AnyDragon x Plant
    DB $F1,$06   ; $49BA  child $23(Dragon) <- AnyDragon x Slime
    DB $F1,$7D   ; $49BC  child $24(Dragon) <- AnyDragon x Bug
    DB $FF,$FF   ; $49BE  (no special recipe)
    DB $F1,$4F   ; $49C0  child $26(Dragon) <- AnyDragon x Bird
    DB $26,$26   ; $49C2  child $27(Dragon) <- Dragon x Dragon
    DB $27,$27   ; $49C4  child $28(Dragon) <- Dragon x Dragon
    DB $22,$8C   ; $49C6  child $29(Dragon) <- Dragon x Devil
    DB $F1,$8D   ; $49C8  child $2A(Dragon) <- AnyDragon x Devil
    DB $F1,$55   ; $49CA  child $2B(Dragon) <- AnyDragon x Bird
    DB $2B,$29   ; $49CC  child $2C(Dragon) <- Dragon x Dragon
    DB $F2,$F0   ; $49CE  child $2D(Beast) <- AnyBeast x AnySlime
    DB $F2,$F1   ; $49D0  child $2E(Beast) <- AnyBeast x AnyDragon
    DB $F2,$F3   ; $49D2  child $2F(Beast) <- AnyBeast x AnyBird
    DB $F2,$F4   ; $49D4  child $30(Beast) <- AnyBeast x AnyPlant
    DB $F2,$F5   ; $49D6  child $31(Beast) <- AnyBeast x AnyBug
    DB $FF,$FF   ; $49D8  (no special recipe)
    DB $F2,$F7   ; $49DA  child $33(Beast) <- AnyBeast x AnyZomby
    DB $F2,$F8   ; $49DC  child $34(Beast) <- AnyBeast x AnyMaterl
    DB $FF,$FF   ; $49DE  (no special recipe)
    DB $F2,$A4   ; $49E0  child $36(Beast) <- AnyBeast x Zomby
    DB $F2,$15   ; $49E2  child $37(Beast) <- AnyBeast x Dragon
    DB $F2,$4A   ; $49E4  child $38(Beast) <- AnyBeast x Bird
    DB $F2,$62   ; $49E6  child $39(Beast) <- AnyBeast x Plant
    DB $F2,$F6   ; $49E8  child $3A(Beast) <- AnyBeast x AnyDevil
    DB $F2,$8F   ; $49EA  child $3B(Beast) <- AnyBeast x Devil
    DB $F2,$BB   ; $49EC  child $3C(Beast) <- AnyBeast x Materl
    DB $F2,$21   ; $49EE  child $3D(Beast) <- AnyBeast x Dragon
    DB $F2,$0A   ; $49F0  child $3E(Beast) <- AnyBeast x Slime
    DB $F2,$00   ; $49F2  child $3F(Beast) <- AnyBeast x Slime
    DB $F2,$4B   ; $49F4  child $40(Beast) <- AnyBeast x Bird
    DB $40,$40   ; $49F6  child $41(Beast) <- Beast x Beast
    DB $41,$41   ; $49F8  child $42(Beast) <- Beast x Beast
    DB $F2,$F9   ; $49FA  child $43(Beast) <- AnyBeast x Any???
    DB $F2,$1C   ; $49FC  child $44(Beast) <- AnyBeast x Dragon
    DB $F2,$87   ; $49FE  child $45(Beast) <- AnyBeast x Devil
    DB $F3,$F0   ; $4A00  child $46(Bird) <- AnyBird x AnySlime
    DB $F3,$F1   ; $4A02  child $47(Bird) <- AnyBird x AnyDragon
    DB $F3,$F2   ; $4A04  child $48(Bird) <- AnyBird x AnyBeast
    DB $F3,$F4   ; $4A06  child $49(Bird) <- AnyBird x AnyPlant
    DB $F3,$F5   ; $4A08  child $4A(Bird) <- AnyBird x AnyBug
    DB $F3,$F6   ; $4A0A  child $4B(Bird) <- AnyBird x AnyDevil
    DB $F3,$F7   ; $4A0C  child $4C(Bird) <- AnyBird x AnyZomby
    DB $F3,$F8   ; $4A0E  child $4D(Bird) <- AnyBird x AnyMaterl
    DB $FF,$FF   ; $4A10  (no special recipe)
    DB $FF,$FF   ; $4A12  (no special recipe)
    DB $F3,$0B   ; $4A14  child $50(Bird) <- AnyBird x Slime
    DB $FF,$FF   ; $4A16  (no special recipe)
    DB $F3,$7C   ; $4A18  child $52(Bird) <- AnyBird x Bug
    DB $F3,$B2   ; $4A1A  child $53(Bird) <- AnyBird x Materl
    DB $F3,$C1   ; $4A1C  child $54(Bird) <- AnyBird x Materl
    DB $F3,$BF   ; $4A1E  child $55(Bird) <- AnyBird x Materl
    DB $F3,$F9   ; $4A20  child $56(Bird) <- AnyBird x Any???
    DB $F3,$1F   ; $4A22  child $57(Bird) <- AnyBird x Dragon
    DB $F3,$64   ; $4A24  child $58(Bird) <- AnyBird x Plant
    DB $54,$55   ; $4A26  child $59(Bird) <- Bird x Bird
    DB $F4,$F0   ; $4A28  child $5A(Plant) <- AnyPlant x AnySlime
    DB $F4,$F1   ; $4A2A  child $5B(Plant) <- AnyPlant x AnyDragon
    DB $F4,$F2   ; $4A2C  child $5C(Plant) <- AnyPlant x AnyBeast
    DB $F4,$F3   ; $4A2E  child $5D(Plant) <- AnyPlant x AnyBird
    DB $F4,$F5   ; $4A30  child $5E(Plant) <- AnyPlant x AnyBug
    DB $F4,$F6   ; $4A32  child $5F(Plant) <- AnyPlant x AnyDevil
    DB $F4,$F7   ; $4A34  child $60(Plant) <- AnyPlant x AnyZomby
    DB $F4,$F8   ; $4A36  child $61(Plant) <- AnyPlant x AnyMaterl
    DB $FF,$FF   ; $4A38  (no special recipe)
    DB $F4,$70   ; $4A3A  child $63(Plant) <- AnyPlant x Bug
    DB $F4,$B3   ; $4A3C  child $64(Plant) <- AnyPlant x Materl
    DB $F4,$82   ; $4A3E  child $65(Plant) <- AnyPlant x Devil
    DB $F4,$A5   ; $4A40  child $66(Plant) <- AnyPlant x Zomby
    DB $F4,$58   ; $4A42  child $67(Plant) <- AnyPlant x Bird
    DB $F4,$30   ; $4A44  child $68(Plant) <- AnyPlant x Beast
    DB $F4,$86   ; $4A46  child $69(Plant) <- AnyPlant x Devil
    DB $69,$69   ; $4A48  child $6A(Plant) <- Plant x Plant
    DB $6A,$6A   ; $4A4A  child $6B(Plant) <- Plant x Plant
    DB $F4,$F9   ; $4A4C  child $6C(Plant) <- AnyPlant x Any???
    DB $FF,$FF   ; $4A4E  (no special recipe)
    DB $F5,$F0   ; $4A50  child $6E(Bug) <- AnyBug x AnySlime
    DB $F5,$F1   ; $4A52  child $6F(Bug) <- AnyBug x AnyDragon
    DB $F5,$F2   ; $4A54  child $70(Bug) <- AnyBug x AnyBeast
    DB $F5,$F3   ; $4A56  child $71(Bug) <- AnyBug x AnyBird
    DB $F5,$F4   ; $4A58  child $72(Bug) <- AnyBug x AnyPlant
    DB $F5,$F6   ; $4A5A  child $73(Bug) <- AnyBug x AnyDevil
    DB $F5,$F7   ; $4A5C  child $74(Bug) <- AnyBug x AnyZomby
    DB $F5,$F8   ; $4A5E  child $75(Bug) <- AnyBug x AnyMaterl
    DB $FF,$FF   ; $4A60  (no special recipe)
    DB $FF,$FF   ; $4A62  (no special recipe)
    DB $F5,$5C   ; $4A64  child $78(Bug) <- AnyBug x Plant
    DB $F5,$37   ; $4A66  child $79(Bug) <- AnyBug x Beast
    DB $F5,$61   ; $4A68  child $7A(Bug) <- AnyBug x Plant
    DB $F5,$31   ; $4A6A  child $7B(Bug) <- AnyBug x Beast
    DB $F5,$9B   ; $4A6C  child $7C(Bug) <- AnyBug x Zomby
    DB $F5,$A0   ; $4A6E  child $7D(Bug) <- AnyBug x Zomby
    DB $F5,$3D   ; $4A70  child $7E(Bug) <- AnyBug x Beast
    DB $75,$75   ; $4A72  child $7F(Bug) <- Bug x Bug
    DB $7F,$7F   ; $4A74  child $80(Bug) <- Bug x Bug
    DB $F5,$F9   ; $4A76  child $81(Bug) <- AnyBug x Any???
    DB $F6,$F0   ; $4A78  child $82(Devil) <- AnyDevil x AnySlime
    DB $F6,$F9   ; $4A7A  child $83(Devil) <- AnyDevil x Any???
    DB $FF,$FF   ; $4A7C  (no special recipe)
    DB $F6,$F3   ; $4A7E  child $85(Devil) <- AnyDevil x AnyBird
    DB $F6,$F4   ; $4A80  child $86(Devil) <- AnyDevil x AnyPlant
    DB $F6,$F5   ; $4A82  child $87(Devil) <- AnyDevil x AnyBug
    DB $F6,$F7   ; $4A84  child $88(Devil) <- AnyDevil x AnyZomby
    DB $F6,$F8   ; $4A86  child $89(Devil) <- AnyDevil x AnyMaterl
    DB $FF,$FF   ; $4A88  (no special recipe)
    DB $F6,$F2   ; $4A8A  child $8B(Devil) <- AnyDevil x AnyBeast
    DB $F6,$F1   ; $4A8C  child $8C(Devil) <- AnyDevil x AnyDragon
    DB $F6,$19   ; $4A8E  child $8D(Devil) <- AnyDevil x Dragon
    DB $F6,$43   ; $4A90  child $8E(Devil) <- AnyDevil x Beast
    DB $F6,$68   ; $4A92  child $8F(Devil) <- AnyDevil x Plant
    DB $F6,$39   ; $4A94  child $90(Devil) <- AnyDevil x Beast
    DB $85,$85   ; $4A96  child $91(Devil) <- Devil x Devil
    DB $8A,$8A   ; $4A98  child $92(Devil) <- Devil x Devil
    DB $F6,$1E   ; $4A9A  child $93(Devil) <- AnyDevil x Dragon
    DB $93,$93   ; $4A9C  child $94(Devil) <- Devil x Devil
    DB $F6,$B6   ; $4A9E  child $95(Devil) <- AnyDevil x Materl
    DB $F6,$45   ; $4AA0  child $96(Devil) <- AnyDevil x Beast
    DB $FF,$FF   ; $4AA2  (no special recipe)
    DB $F6,$79   ; $4AA4  child $98(Devil) <- AnyDevil x Bug
    DB $94,$59   ; $4AA6  child $99(Devil) <- Devil x Bird
    DB $97,$C7   ; $4AA8  child $9A(Devil) <- Devil x Materl
    DB $F7,$F0   ; $4AAA  child $9B(Zomby) <- AnyZomby x AnySlime
    DB $F7,$1B   ; $4AAC  child $9C(Zomby) <- AnyZomby x Dragon
    DB $F7,$F2   ; $4AAE  child $9D(Zomby) <- AnyZomby x AnyBeast
    DB $F7,$F3   ; $4AB0  child $9E(Zomby) <- AnyZomby x AnyBird
    DB $F7,$F4   ; $4AB2  child $9F(Zomby) <- AnyZomby x AnyPlant
    DB $F7,$F5   ; $4AB4  child $A0(Zomby) <- AnyZomby x AnyBug
    DB $F7,$F6   ; $4AB6  child $A1(Zomby) <- AnyZomby x AnyDevil
    DB $F7,$F8   ; $4AB8  child $A2(Zomby) <- AnyZomby x AnyMaterl
    DB $FF,$FF   ; $4ABA  (no special recipe)
    DB $F7,$6E   ; $4ABC  child $A4(Zomby) <- AnyZomby x Bug
    DB $F7,$4D   ; $4ABE  child $A5(Zomby) <- AnyZomby x Bird
    DB $F7,$F1   ; $4AC0  child $A6(Zomby) <- AnyZomby x AnyDragon
    DB $F7,$34   ; $4AC2  child $A7(Zomby) <- AnyZomby x Beast
    DB $F7,$72   ; $4AC4  child $A8(Zomby) <- AnyZomby x Bug
    DB $A1,$A1   ; $4AC6  child $A9(Zomby) <- Zomby x Zomby
    DB $F7,$F9   ; $4AC8  child $AA(Zomby) <- AnyZomby x Any???
    DB $A3,$A3   ; $4ACA  child $AB(Zomby) <- Zomby x Zomby
    DB $AB,$AB   ; $4ACC  child $AC(Zomby) <- Zomby x Zomby
    DB $AC,$AC   ; $4ACE  child $AD(Zomby) <- Zomby x Zomby
    DB $FF,$FF   ; $4AD0  (no special recipe)
    DB $F8,$F0   ; $4AD2  child $AF(Materl) <- AnyMaterl x AnySlime
    DB $F8,$F1   ; $4AD4  child $B0(Materl) <- AnyMaterl x AnyDragon
    DB $F8,$F2   ; $4AD6  child $B1(Materl) <- AnyMaterl x AnyBeast
    DB $F8,$F3   ; $4AD8  child $B2(Materl) <- AnyMaterl x AnyBird
    DB $F8,$F4   ; $4ADA  child $B3(Materl) <- AnyMaterl x AnyPlant
    DB $F8,$F5   ; $4ADC  child $B4(Materl) <- AnyMaterl x AnyBug
    DB $F8,$F6   ; $4ADE  child $B5(Materl) <- AnyMaterl x AnyDevil
    DB $F8,$F7   ; $4AE0  child $B6(Materl) <- AnyMaterl x AnyZomby
    DB $FF,$FF   ; $4AE2  (no special recipe)
    DB $F8,$74   ; $4AE4  child $B8(Materl) <- AnyMaterl x Bug
    DB $F8,$22   ; $4AE6  child $B9(Materl) <- AnyMaterl x Dragon
    DB $F8,$F9   ; $4AE8  child $BA(Materl) <- AnyMaterl x Any???
    DB $F8,$73   ; $4AEA  child $BB(Materl) <- AnyMaterl x Bug
    DB $F8,$5D   ; $4AEC  child $BC(Materl) <- AnyMaterl x Plant
    DB $F8,$88   ; $4AEE  child $BD(Materl) <- AnyMaterl x Devil
    DB $F8,$04   ; $4AF0  child $BE(Materl) <- AnyMaterl x Slime
    DB $B7,$5B   ; $4AF2  child $BF(Materl) <- Materl x Plant
    DB $B9,$83   ; $4AF4  child $C0(Materl) <- Materl x Devil
    DB $BD,$42   ; $4AF6  child $C1(Materl) <- Materl x Beast
    DB $F8,$07   ; $4AF8  child $C2(Materl) <- AnyMaterl x Slime
    DB $B7,$B7   ; $4AFA  child $C3(Materl) <- Materl x Materl
    DB $C3,$C3   ; $4AFC  child $C4(Materl) <- Materl x Materl
    DB $C4,$C4   ; $4AFE  child $C5(Materl) <- Materl x Materl
    DB $B4,$B4   ; $4B00  child $C6(Materl) <- Materl x Materl
    DB $C1,$C0   ; $4B02  child $C7(Materl) <- Materl x Materl
    DB $AD,$25   ; $4B04  child $C8(???) <- Zomby x Dragon
    DB $C8,$2C   ; $4B06  child $C9(???) <- ??? x Dragon
    DB $AA,$12   ; $4B08  child $CA(???) <- Zomby x Slime
    DB $99,$6C   ; $4B0A  child $CB(???) <- Devil x Plant
    DB $CA,$29   ; $4B0C  child $CC(???) <- ??? x Dragon
    DB $C8,$CB   ; $4B0E  child $CD(???) <- ??? x ???
    DB $9A,$2C   ; $4B10  child $CE(???) <- Devil x Dragon
    DB $CE,$42   ; $4B12  child $CF(???) <- ??? x Beast
    DB $CF,$13   ; $4B14  child $D0(???) <- ??? x Slime
    DB $D0,$24   ; $4B16  child $D1(???) <- ??? x Dragon
    DB $CC,$43   ; $4B18  child $D2(???) <- ??? x Beast
    DB $CD,$D0   ; $4B1A  child $D3(???) <- ??? x ???
    DB $D3,$80   ; $4B1C  child $D4(???) <- ??? x Bug
    DB $D4,$D2   ; $4B1E  child $D5(???) <- ??? x ???
    DB $D5,$6D   ; $4B20  child $D6(???) <- ??? x Plant
    DB $FF,$FF   ; $4B22  (no special recipe)
    DB $FF,$FF   ; $4B24  (no special recipe)
    DB $FF,$FF   ; $4B26  (no special recipe)
    DB $FF,$FF   ; $4B28  (no special recipe)
    DB $FF,$FF   ; $4B2A  (no special recipe)
    DB $FF,$FF   ; $4B2C  (no special recipe)
    DB $00,$00   ; end

; ============================================================================
; Bank22_Fn3 / BREEDING DRIVER  ($45A3)  — resolve child + child '+' from 2 parents
; ============================================================================
; In:  $DA6F parent1 species, $DA70 parent2 species, $DA75/$DA76 parent slots.
; Out: $DA71 child species, $DA77 child '+' value.
; Order: compute parents' '+' -> scan MAIN table $4B30 (Bank22_BreedMatch) ->
;        scan SPECIAL-pair table $4974 -> else child = parent1 (no-op result).
; (Two breeding tables: $4B30 = general/family recipes; $4974 = special pairs.)
; ============================================================================
Bank22_Fn3_BreedDriver:                     ; $45A3
    LD A,$FF                          ; $45A3  [3E FF]  ; init result $DA71, wildcards $DA72-74, plus $DA77 = $FF
    LD ($DA71),A                      ; $45A5  [EA 71 DA]
    LD A,$FF                          ; $45A8  [3E FF]
    LD ($DA72),A                      ; $45AA  [EA 72 DA]
    LD A,$FF                          ; $45AD  [3E FF]
    LD ($DA73),A                      ; $45AF  [EA 73 DA]
    LD A,$FF                          ; $45B2  [3E FF]
    LD ($DA74),A                      ; $45B4  [EA 74 DA]
    LD A,$FF                          ; $45B7  [3E FF]
    LD ($DA77),A                      ; $45B9  [EA 77 DA]
    CALL $4653                        ; $45BC  [CD 53 46]  ; compute parents' '+' ($DA77) THEN fall into main matcher $46C6 ($4B30 table)
    LD A,($DA71)                      ; $45BF  [FA 71 DA]  ; child found in main $4B30 table? -> done
    CP $FF                            ; $45C2  [FE FF]
    RET NZ                            ; $45C4  [C0]
    CALL $45D5                        ; $45C5  [CD D5 45]  ; else try SPECIAL-recipe table via $45D5 (table $4974)
    LD A,($DA71)                      ; $45C8  [FA 71 DA]  ; child found in special table? -> done
    CP $FF                            ; $45CB  [FE FF]
    RET NZ                            ; $45CD  [C0]
    LD A,($DA6F)                      ; $45CE  [FA 6F DA]  ; default: child = parent1 (breeding produced nothing new)
    LD ($DA71),A                      ; $45D1  [EA 71 DA]
    RET                               ; $45D4  [C9]
    LD A,($DA70)                      ; $45D5  [FA 70 DA]  ; parent2 species
    CP $F0                            ; $45D8  [FE F0]  ; already a family wildcard?
    JR NC,$45FF                       ; $45DA  [30 23]
    LD A,($DA6F)                      ; $45DC  [FA 6F DA]
    PUSH AF                           ; $45DF  [F5]
    CALL $45FF                        ; $45E0  [CD FF 45]
    POP AF                            ; $45E3  [F1]
    LD ($DA6F),A                      ; $45E4  [EA 6F DA]  ; restore parent1
    LD A,($DA71)                      ; $45E7  [FA 71 DA]
    CP $FF                            ; $45EA  [FE FF]
    RET NZ                            ; $45EC  [C0]
    LD A,($DA70)                      ; $45ED  [FA 70 DA]  ; compute parent2 family-wildcard -> $DA70
    LD ($DA31),A                      ; $45F0  [EA 31 DA]
    LD HL,$0301                       ; $45F3  [21 01 03]
    RST $10                           ; $45F6  [D7]
    LD A,($DA33)                      ; $45F7  [FA 33 DA]
    ADD A,$F0                         ; $45FA  [C6 F0]
    LD ($DA70),A                      ; $45FC  [EA 70 DA]
    LD A,($DA6F)                      ; $45FF  [FA 6F DA]  ; parent1 species
    CP $F0                            ; $4602  [FE F0]
    JR NC,$4615                       ; $4604  [30 0F]
    LD ($DA31),A                      ; $4606  [EA 31 DA]
    LD HL,$0301                       ; $4609  [21 01 03]
    RST $10                           ; $460C  [D7]
    LD A,($DA33)                      ; $460D  [FA 33 DA]
    ADD A,$F0                         ; $4610  [C6 F0]
    LD ($DA72),A                      ; $4612  [EA 72 DA]  ; parent1 family-wildcard -> $DA72
    LD HL,$4974                       ; $4615  [21 74 49]  ; HL = special table $4974
    LD D,$FF                          ; $4618  [16 FF]
    INC D                             ; $461A  [14]
    LD B,(HL)                         ; $461B  [46]  ; B=record.parent1, C=record.parent2
    INC HL                            ; $461C  [23]
    LD C,(HL)                         ; $461D  [4E]
    INC HL                            ; $461E  [23]
    LD A,B                            ; $461F  [78]
    OR C                              ; $4620  [B1]  ; 00 00 -> end of table
    RET Z                             ; $4621  [C8]
    LD A,B                            ; $4622  [78]
    AND C                             ; $4623  [A1]
    CP $FF                            ; $4624  [FE FF]  ; FF FF entry -> skip
    JR Z,$461A                        ; $4626  [28 F2]
    LD A,($DA70)                      ; $4628  [FA 70 DA]  ; parent2 wildcard family?
    AND $F0                           ; $462B  [E6 F0]
    CP $F0                            ; $462D  [FE F0]
    JR NZ,$4636                       ; $462F  [20 05]
    LD A,C                            ; $4631  [79]
    CP $FA                            ; $4632  [FE FA]
    JR Z,$463C                        ; $4634  [28 06]
    LD A,($DA70)                      ; $4636  [FA 70 DA]
    CP C                              ; $4639  [B9]  ; record.parent2 == parent2 species?
    JR NZ,$461A                       ; $463A  [20 DE]
    LD A,($DA6F)                      ; $463C  [FA 6F DA]
    CP B                              ; $463F  [B8]  ; record.parent1 == parent1 species?
    JR Z,$464E                        ; $4640  [28 0C]
    LD A,($DA72)                      ; $4642  [FA 72 DA]
    CP B                              ; $4645  [B8]  ; == parent1 family-wildcard?
    JR NZ,$464C                       ; $4646  [20 04]
    LD A,D                            ; $4648  [7A]
    LD ($DA71),A                      ; $4649  [EA 71 DA]  ; $DA71 = D (special-recipe result index)
    JR $461A                          ; $464C  [18 CC]
    LD A,D                            ; $464E  [7A]
    LD ($DA71),A                      ; $464F  [EA 71 DA]  ; $DA71 = D (result)
    RET                               ; $4652  [C9]
    LD A,($DA75)                      ; $4653  [FA 75 DA]  ; --- PLUS computation: parents' level/'+' -> $DA77 ---
    LD HL,$CB23                       ; $4656  [21 23 CB]  ; $CB23[slot] via $260A (149-byte instance row lookup)
    CALL $260A                        ; $4659  [CD 0A 26]
    LD A,(HL)                         ; $465C  [7E]
    LD B,A                            ; $465D  [47]
    LD A,($C86C)                      ; $465E  [FA 6C C8]
    OR A                              ; $4661  [B7]
    JR NZ,$467D                       ; $4662  [20 19]
    LD A,($DA75)                      ; $4664  [FA 75 DA]
    LD HL,$CB23                       ; $4667  [21 23 CB]
    CALL $260A                        ; $466A  [CD 0A 26]
    LD B,(HL)                         ; $466D  [46]
    PUSH BC                           ; $466E  [C5]
    LD A,($DA76)                      ; $466F  [FA 76 DA]
    LD HL,$CB23                       ; $4672  [21 23 CB]
    CALL $260A                        ; $4675  [CD 0A 26]
    LD A,(HL)                         ; $4678  [7E]
    POP BC                            ; $4679  [C1]
    CP B                              ; $467A  [B8]
    JR NC,$467E                       ; $467B  [30 01]
    LD A,B                            ; $467D  [78]
    INC A                             ; $467E  [3C]  ; $DA77 = max(parent+ ) + 1
    LD ($DA77),A                      ; $467F  [EA 77 DA]
    LD A,($DA75)                      ; $4682  [FA 75 DA]
    LD HL,$CB0C                       ; $4685  [21 0C CB]  ; $CB0C[slot] = each parent's '+' value
    CALL $260A                        ; $4688  [CD 0A 26]
    LD B,(HL)                         ; $468B  [46]
    PUSH BC                           ; $468C  [C5]
    LD A,($DA76)                      ; $468D  [FA 76 DA]
    LD HL,$CB0C                       ; $4690  [21 0C CB]
    CALL $260A                        ; $4693  [CD 0A 26]
    LD A,(HL)                         ; $4696  [7E]
    POP BC                            ; $4697  [C1]
    ADD A,B                           ; $4698  [80]  ; sum of parents' '+'
    LD C,$04                          ; $4699  [0E 04]
    CP $64                            ; $469B  [FE 64]  ; tiered bonus by sum: >=$64->+4 >=$4C->+3 >=$3C->+2 >=$28->+1 else +0
    JR NC,$46B3                       ; $469D  [30 14]
    LD C,$03                          ; $469F  [0E 03]
    CP $4C                            ; $46A1  [FE 4C]
    JR NC,$46B3                       ; $46A3  [30 0E]
    LD C,$02                          ; $46A5  [0E 02]
    CP $3C                            ; $46A7  [FE 3C]
    JR NC,$46B3                       ; $46A9  [30 08]
    LD C,$01                          ; $46AB  [0E 01]
    CP $28                            ; $46AD  [FE 28]
    JR NC,$46B3                       ; $46AF  [30 02]
    LD C,$00                          ; $46B1  [0E 00]
    LD A,($DA77)                      ; $46B3  [FA 77 DA]
    ADD A,C                           ; $46B6  [81]  ; $DA77 += tier bonus
    LD ($DA77),A                      ; $46B7  [EA 77 DA]
    LD A,($DA77)                      ; $46BA  [FA 77 DA]
    CP $63                            ; $46BD  [FE 63]  ; clamp $DA77 to 99 ($63)
    JR C,$46C6                        ; $46BF  [38 05]
    LD A,$63                          ; $46C1  [3E 63]
    LD ($DA77),A                      ; $46C3  [EA 77 DA]

; ============================================================================
; Bank22 BREEDING MATCHER  ($46C6)  — resolve child from two parents
; ============================================================================
; In:  $DA6F parent1 species, $DA70 parent2 species, $DA77 parents' combined '+'
; Out: $DA71 child species ($FF = no valid pairing)
; Scans Bank22_BreedTable ($4B30). A record matches when:
;   record.parent1 == parent1 species OR parent1 family-wildcard ($F0+fam), AND
;   record.parent2 == parent2 species OR parent2 family-wildcard,            AND
;   parents' '+' ($DA77) >= record.required '+'.  Then child = record+3.
; (This CONFIRMS the 5-byte record layout: p1,p2,req+,child,bonus.)
; ============================================================================
Bank22_BreedMatch:                          ; $46C6
    LD A,($DA6F)                      ; $46C6  [FA 6F DA]  ; parent1 species id (input)
    CP $F0                            ; $46C9  [FE F0]  ; $F0-$F9 = already a family wildcard? skip family lookup
    JR NC,$46DC                       ; $46CB  [30 0F]
    LD ($DA31),A                      ; $46CD  [EA 31 DA]  ; $DA31 = species -> bank3/fn1 will load its record
    LD HL,$0301                       ; $46D0  [21 01 03]  ; bankcall bank3/fn1 (species data loader)
    RST $10                           ; $46D3  [D7]
    LD A,($DA33)                      ; $46D4  [FA 33 DA]  ; $DA33 = family id of parent1
    ADD A,$F0                         ; $46D7  [C6 F0]  ; + $F0 => family-WILDCARD code
    LD ($DA73),A                      ; $46D9  [EA 73 DA]  ; $DA73 = parent1 family-wildcard ($F0+fam)
    LD A,($DA70)                      ; $46DC  [FA 70 DA]  ; parent2 species id
    CP $F0                            ; $46DF  [FE F0]
    JR NC,$46F2                       ; $46E1  [30 0F]  ; already a wildcard? skip
    LD ($DA31),A                      ; $46E3  [EA 31 DA]  ; load parent2 record...
    LD HL,$0301                       ; $46E6  [21 01 03]
    RST $10                           ; $46E9  [D7]
    LD A,($DA33)                      ; $46EA  [FA 33 DA]
    ADD A,$F0                         ; $46ED  [C6 F0]
    LD ($DA74),A                      ; $46EF  [EA 74 DA]  ; $DA74 = parent2 family-wildcard
    LD HL,$4B30                       ; $46F2  [21 30 4B]  ; HL = breeding table base ($4B30)
    LD A,(HL)                         ; $46F5  [7E]  ; A = record parent1 field
    CP $FF                            ; $46F6  [FE FF]  ; $FF => end of table
    JR Z,$4710                        ; $46F8  [28 16]
    PUSH HL                           ; $46FA  [E5]
    CALL $471C                        ; $46FB  [CD 1C 47]  ; CALL matcher (sets $DA71=child on match)
    POP HL                            ; $46FE  [E1]
    LD A,($DA71)                      ; $46FF  [FA 71 DA]  ; child found? ($DA71 != $FF)
    CP $FF                            ; $4702  [FE FF]
    JR NZ,$4710                       ; $4704  [20 0A]
    LD A,L                            ; $4706  [7D]  ; advance HL by 5 (next record)
    ADD A,$05                         ; $4707  [C6 05]
    LD L,A                            ; $4709  [6F]
    LD A,H                            ; $470A  [7C]
    ADC A,$00                         ; $470B  [CE 00]
    LD H,A                            ; $470D  [67]
    JR $46F5                          ; $470E  [18 E5]  ; loop to next record
    LD A,($DA77)                      ; $4710  [FA 77 DA]  ; clamp parents' '+' ($DA77) to 99 ($63) max
    CP $63                            ; $4713  [FE 63]
    RET C                             ; $4715  [D8]
    LD A,$63                          ; $4716  [3E 63]
    LD ($DA77),A                      ; $4718  [EA 77 DA]
    RET                               ; $471B  [C9]
    LD A,($DA6F)                      ; $471C  [FA 6F DA]  ; A = parent1 species
    CP (HL)                           ; $471F  [BE]  ; == record.parent1 ? (exact species)
    JR Z,$4728                        ; $4720  [28 06]
    LD A,($DA73)                      ; $4722  [FA 73 DA]  ; else A = parent1 family-wildcard
    CP (HL)                           ; $4725  [BE]  ; == record.parent1 ? (family match)
    JR NZ,$4749                       ; $4726  [20 21]  ; neither -> no match
    INC HL                            ; $4728  [23]  ; advance to record.parent2
    LD A,($DA70)                      ; $4729  [FA 70 DA]  ; A = parent2 species
    CP (HL)                           ; $472C  [BE]  ; == record.parent2 ?
    JR Z,$4735                        ; $472D  [28 06]
    LD A,($DA74)                      ; $472F  [FA 74 DA]  ; else parent2 family-wildcard
    CP (HL)                           ; $4732  [BE]
    JR NZ,$4749                       ; $4733  [20 14]  ; no match
    INC HL                            ; $4735  [23]  ; advance to record.reqPlus
    LD A,($DA77)                      ; $4736  [FA 77 DA]  ; A = parents' '+' ($DA77)
    CP (HL)                           ; $4739  [BE]  ; parents' + < required + ? -> no match
    JR C,$4749                        ; $473A  [38 0D]
    INC HL                            ; $473C  [23]  ; advance to record.child
    LD A,(HL)                         ; $473D  [7E]  ; A = child id
    LD ($DA71),A                      ; $473E  [EA 71 DA]  ; $DA71 = CHILD (result!)
    INC HL                            ; $4741  [23]
    LD A,($DA77)                      ; $4742  [FA 77 DA]
    ADD A,(HL)                        ; $4745  [86]
    LD ($DA77),A                      ; $4746  [EA 77 DA]
    RET                               ; $4749  [C9]
    LD HL,$CB21                       ; $474A  [21 21 CB]

; ############################################################################
; MONSTER BREEDING TABLE   $4B30..$5B4D   (825 records x 5 bytes)
; ############################################################################
; Record: parent1, parent2, required '+' , child, child-bonus '+'.
;   +0 parent1   +1 parent2 : monster id, OR $F0-$F9 = ANY monster of family
;                              (family = id-$F0: $F0=Slime .. $F9=???)
;   +2 REQUIRED '+' : plus-level the PARENTS must have for this recipe
;   +3 CHILD monster id (result of the pairing)
;   +4 BONUS '+'    : plus-level ADDED to the CHILD after breeding (its
;                     starting +N). Usually $00; e.g. $02 = child born at +2.
; Read as:  parent1 x parent2 (req +N)  ->  child (born +M)
; Includes SPECIFIC pair recipes AND family-wildcard ($Fn) general breeding.
; ============================================================================
Bank22_BreedTable:                          ; $4B30
;  --- parent1 = $00 (Slime) ---
    DB $00,$1B,$00,$0C,$00   ; $4B30  Slime x Dragon -> Slime
    DB $00,$24,$00,$0C,$00   ; $4B35  Slime x Dragon -> Slime
    DB $00,$25,$00,$0C,$00   ; $4B3A  Slime x Dragon -> Slime
    DB $00,$2A,$00,$0C,$00   ; $4B3F  Slime x Dragon -> Slime
    DB $00,$2B,$00,$0C,$00   ; $4B44  Slime x Dragon -> Slime
;  --- parent1 = $05 (Slime) ---
    DB $05,$1B,$00,$0C,$00   ; $4B49  Slime x Dragon -> Slime
    DB $05,$24,$00,$0C,$00   ; $4B4E  Slime x Dragon -> Slime
    DB $05,$25,$00,$0C,$00   ; $4B53  Slime x Dragon -> Slime
    DB $05,$2A,$00,$0C,$00   ; $4B58  Slime x Dragon -> Slime
    DB $05,$2B,$00,$0C,$00   ; $4B5D  Slime x Dragon -> Slime
;  --- parent1 = $0B (Slime) ---
    DB $0B,$1B,$00,$0C,$00   ; $4B62  Slime x Dragon -> Slime
    DB $0B,$24,$00,$0C,$00   ; $4B67  Slime x Dragon -> Slime
    DB $0B,$25,$00,$0C,$00   ; $4B6C  Slime x Dragon -> Slime
    DB $0B,$2A,$00,$0C,$00   ; $4B71  Slime x Dragon -> Slime
    DB $0B,$2B,$00,$0C,$00   ; $4B76  Slime x Dragon -> Slime
;  --- parent1 = $11 (Slime) ---
    DB $11,$1B,$00,$0C,$00   ; $4B7B  Slime x Dragon -> Slime
    DB $11,$24,$00,$0C,$00   ; $4B80  Slime x Dragon -> Slime
    DB $11,$25,$00,$0C,$00   ; $4B85  Slime x Dragon -> Slime
    DB $11,$2A,$00,$0C,$00   ; $4B8A  Slime x Dragon -> Slime
    DB $11,$2B,$00,$0C,$00   ; $4B8F  Slime x Dragon -> Slime
;  --- parent1 = $0F (Slime) ---
    DB $0F,$25,$00,$0E,$00   ; $4B94  Slime x Dragon -> Slime
    DB $0F,$2A,$00,$0E,$00   ; $4B99  Slime x Dragon -> Slime
    DB $0F,$2C,$00,$0E,$00   ; $4B9E  Slime x Dragon -> Slime
    DB $0F,$3E,$00,$0E,$00   ; $4BA3  Slime x Beast -> Slime
    DB $0F,$42,$00,$0E,$00   ; $4BA8  Slime x Beast -> Slime
    DB $0F,$53,$00,$0E,$00   ; $4BAD  Slime x Bird -> Slime
    DB $0F,$56,$00,$0E,$00   ; $4BB2  Slime x Bird -> Slime
    DB $0F,$57,$00,$0E,$00   ; $4BB7  Slime x Bird -> Slime
    DB $0F,$96,$00,$0E,$00   ; $4BBC  Slime x Devil -> Slime
    DB $0F,$97,$00,$0E,$00   ; $4BC1  Slime x Devil -> Slime
    DB $0F,$A9,$00,$0E,$00   ; $4BC6  Slime x Zomby -> Slime
    DB $0F,$AA,$00,$0E,$00   ; $4BCB  Slime x Zomby -> Slime
;  --- parent1 = $12 (Slime) ---
    DB $12,$25,$00,$0E,$00   ; $4BD0  Slime x Dragon -> Slime
    DB $12,$2A,$00,$0E,$00   ; $4BD5  Slime x Dragon -> Slime
    DB $12,$2C,$00,$0E,$00   ; $4BDA  Slime x Dragon -> Slime
    DB $12,$3E,$00,$0E,$00   ; $4BDF  Slime x Beast -> Slime
    DB $12,$42,$00,$0E,$00   ; $4BE4  Slime x Beast -> Slime
    DB $12,$53,$00,$0E,$00   ; $4BE9  Slime x Bird -> Slime
    DB $12,$56,$00,$0E,$00   ; $4BEE  Slime x Bird -> Slime
    DB $12,$57,$00,$0E,$00   ; $4BF3  Slime x Bird -> Slime
    DB $12,$96,$00,$0E,$00   ; $4BF8  Slime x Devil -> Slime
    DB $12,$97,$00,$0E,$00   ; $4BFD  Slime x Devil -> Slime
    DB $12,$A9,$00,$0E,$00   ; $4C02  Slime x Zomby -> Slime
    DB $12,$AA,$00,$0E,$00   ; $4C07  Slime x Zomby -> Slime
;  --- parent1 = $0E (Slime) ---
    DB $0E,$25,$00,$0F,$00   ; $4C0C  Slime x Dragon -> Slime
    DB $0E,$2A,$00,$0F,$00   ; $4C11  Slime x Dragon -> Slime
    DB $0E,$2C,$00,$0F,$00   ; $4C16  Slime x Dragon -> Slime
    DB $0E,$3E,$00,$0F,$00   ; $4C1B  Slime x Beast -> Slime
    DB $0E,$42,$00,$0F,$00   ; $4C20  Slime x Beast -> Slime
    DB $0E,$53,$00,$0F,$00   ; $4C25  Slime x Bird -> Slime
    DB $0E,$56,$00,$0F,$00   ; $4C2A  Slime x Bird -> Slime
    DB $0E,$57,$00,$0F,$00   ; $4C2F  Slime x Bird -> Slime
    DB $0E,$96,$00,$0F,$00   ; $4C34  Slime x Devil -> Slime
    DB $0E,$97,$00,$0F,$00   ; $4C39  Slime x Devil -> Slime
    DB $0E,$A9,$00,$0F,$00   ; $4C3E  Slime x Zomby -> Slime
    DB $0E,$AA,$00,$0F,$00   ; $4C43  Slime x Zomby -> Slime
;  --- parent1 = $08 (Slime) ---
    DB $08,$08,$05,$0F,$00   ; $4C48  Slime x Slime (req +5) -> Slime
;  --- parent1 = $01 (Slime) ---
    DB $01,$01,$05,$0E,$00   ; $4C4D  Slime x Slime (req +5) -> Slime
;  --- parent1 = $0E (Slime) ---
    DB $0E,$C7,$00,$13,$00   ; $4C52  Slime x Materl -> Slime
;  --- parent1 = $0F (Slime) ---
    DB $0F,$C7,$00,$13,$00   ; $4C57  Slime x Materl -> Slime
;  --- parent1 = $12 (Slime) ---
    DB $12,$C7,$00,$13,$00   ; $4C5C  Slime x Materl -> Slime
;  --- parent1 = $0E (Slime) ---
    DB $0E,$B9,$00,$12,$00   ; $4C61  Slime x Materl -> Slime
;  --- parent1 = $0F (Slime) ---
    DB $0F,$B9,$00,$12,$00   ; $4C66  Slime x Materl -> Slime
;  --- parent1 = $14 (Dragon) ---
    DB $14,$14,$04,$25,$00   ; $4C6B  Dragon x Dragon (req +4) -> Dragon
    DB $14,$14,$00,$1C,$00   ; $4C70  Dragon x Dragon -> Dragon
;  --- parent1 = $1C (Dragon) ---
    DB $1C,$1C,$04,$25,$00   ; $4C75  Dragon x Dragon (req +4) -> Dragon
;  --- parent1 = $17 (Dragon) ---
    DB $17,$3F,$00,$22,$00   ; $4C7A  Dragon x Beast -> Dragon
    DB $17,$41,$00,$22,$00   ; $4C7F  Dragon x Beast -> Dragon
    DB $17,$53,$00,$22,$00   ; $4C84  Dragon x Bird -> Dragon
    DB $17,$57,$00,$22,$00   ; $4C89  Dragon x Bird -> Dragon
    DB $17,$58,$00,$22,$00   ; $4C8E  Dragon x Bird -> Dragon
    DB $17,$83,$00,$22,$00   ; $4C93  Dragon x Devil -> Dragon
    DB $17,$8D,$00,$22,$00   ; $4C98  Dragon x Devil -> Dragon
    DB $17,$8E,$00,$22,$00   ; $4C9D  Dragon x Devil -> Dragon
    DB $17,$90,$00,$22,$00   ; $4CA2  Dragon x Devil -> Dragon
    DB $17,$94,$00,$22,$00   ; $4CA7  Dragon x Devil -> Dragon
    DB $17,$A9,$00,$22,$00   ; $4CAC  Dragon x Zomby -> Dragon
    DB $17,$C4,$00,$22,$00   ; $4CB1  Dragon x Materl -> Dragon
;  --- parent1 = $1E (Dragon) ---
    DB $1E,$3F,$00,$22,$00   ; $4CB6  Dragon x Beast -> Dragon
    DB $1E,$41,$00,$22,$00   ; $4CBB  Dragon x Beast -> Dragon
    DB $1E,$53,$00,$22,$00   ; $4CC0  Dragon x Bird -> Dragon
    DB $1E,$57,$00,$22,$00   ; $4CC5  Dragon x Bird -> Dragon
    DB $1E,$58,$00,$22,$00   ; $4CCA  Dragon x Bird -> Dragon
    DB $1E,$83,$00,$22,$00   ; $4CCF  Dragon x Devil -> Dragon
    DB $1E,$8D,$00,$22,$00   ; $4CD4  Dragon x Devil -> Dragon
    DB $1E,$8E,$00,$22,$00   ; $4CD9  Dragon x Devil -> Dragon
    DB $1E,$90,$00,$22,$00   ; $4CDE  Dragon x Devil -> Dragon
    DB $1E,$94,$00,$22,$00   ; $4CE3  Dragon x Devil -> Dragon
    DB $1E,$A9,$00,$22,$00   ; $4CE8  Dragon x Zomby -> Dragon
    DB $1E,$C4,$00,$22,$00   ; $4CED  Dragon x Materl -> Dragon
;  --- parent1 = $2A (Dragon) ---
    DB $2A,$3F,$00,$22,$00   ; $4CF2  Dragon x Beast -> Dragon
    DB $2A,$41,$00,$22,$00   ; $4CF7  Dragon x Beast -> Dragon
    DB $2A,$53,$00,$22,$00   ; $4CFC  Dragon x Bird -> Dragon
    DB $2A,$57,$00,$22,$00   ; $4D01  Dragon x Bird -> Dragon
    DB $2A,$58,$00,$22,$00   ; $4D06  Dragon x Bird -> Dragon
    DB $2A,$83,$00,$22,$00   ; $4D0B  Dragon x Devil -> Dragon
    DB $2A,$8D,$00,$22,$00   ; $4D10  Dragon x Devil -> Dragon
    DB $2A,$8E,$00,$22,$00   ; $4D15  Dragon x Devil -> Dragon
    DB $2A,$90,$00,$22,$00   ; $4D1A  Dragon x Devil -> Dragon
    DB $2A,$94,$00,$22,$00   ; $4D1F  Dragon x Devil -> Dragon
    DB $2A,$A9,$00,$22,$00   ; $4D24  Dragon x Zomby -> Dragon
    DB $2A,$C4,$00,$22,$00   ; $4D29  Dragon x Materl -> Dragon
;  --- parent1 = $2B (Dragon) ---
    DB $2B,$3F,$00,$22,$00   ; $4D2E  Dragon x Beast -> Dragon
    DB $2B,$41,$00,$22,$00   ; $4D33  Dragon x Beast -> Dragon
    DB $2B,$53,$00,$22,$00   ; $4D38  Dragon x Bird -> Dragon
    DB $2B,$57,$00,$22,$00   ; $4D3D  Dragon x Bird -> Dragon
    DB $2B,$58,$00,$22,$00   ; $4D42  Dragon x Bird -> Dragon
    DB $2B,$83,$00,$22,$00   ; $4D47  Dragon x Devil -> Dragon
    DB $2B,$8D,$00,$22,$00   ; $4D4C  Dragon x Devil -> Dragon
    DB $2B,$8E,$00,$22,$00   ; $4D51  Dragon x Devil -> Dragon
    DB $2B,$90,$00,$22,$00   ; $4D56  Dragon x Devil -> Dragon
    DB $2B,$94,$00,$22,$00   ; $4D5B  Dragon x Devil -> Dragon
    DB $2B,$A9,$00,$22,$00   ; $4D60  Dragon x Zomby -> Dragon
    DB $2B,$C4,$00,$22,$00   ; $4D65  Dragon x Materl -> Dragon
;  --- parent1 = $19 (Dragon) ---
    DB $19,$02,$00,$1F,$00   ; $4D6A  Dragon x Slime -> Dragon
    DB $19,$41,$00,$1F,$00   ; $4D6F  Dragon x Beast -> Dragon
    DB $19,$44,$00,$1F,$00   ; $4D74  Dragon x Beast -> Dragon
    DB $19,$66,$00,$1F,$00   ; $4D79  Dragon x Plant -> Dragon
    DB $19,$8D,$00,$1F,$00   ; $4D7E  Dragon x Devil -> Dragon
    DB $19,$8E,$00,$1F,$00   ; $4D83  Dragon x Devil -> Dragon
    DB $19,$91,$00,$1F,$00   ; $4D88  Dragon x Devil -> Dragon
    DB $19,$96,$00,$1F,$00   ; $4D8D  Dragon x Devil -> Dragon
;  --- parent1 = $16 (Dragon) ---
    DB $16,$43,$00,$28,$00   ; $4D92  Dragon x Beast -> Dragon
    DB $16,$95,$00,$28,$00   ; $4D97  Dragon x Devil -> Dragon
    DB $16,$AE,$00,$28,$00   ; $4D9C  Dragon x Zomby -> Dragon
    DB $16,$C5,$00,$28,$00   ; $4DA1  Dragon x Materl -> Dragon
;  --- parent1 = $17 (Dragon) ---
    DB $17,$43,$00,$28,$00   ; $4DA6  Dragon x Beast -> Dragon
    DB $17,$95,$00,$28,$00   ; $4DAB  Dragon x Devil -> Dragon
    DB $17,$AE,$00,$28,$00   ; $4DB0  Dragon x Zomby -> Dragon
    DB $17,$C5,$00,$28,$00   ; $4DB5  Dragon x Materl -> Dragon
;  --- parent1 = $19 (Dragon) ---
    DB $19,$43,$00,$28,$00   ; $4DBA  Dragon x Beast -> Dragon
    DB $19,$95,$00,$28,$00   ; $4DBF  Dragon x Devil -> Dragon
    DB $19,$AE,$00,$28,$00   ; $4DC4  Dragon x Zomby -> Dragon
    DB $19,$C5,$00,$28,$00   ; $4DC9  Dragon x Materl -> Dragon
;  --- parent1 = $2A (Dragon) ---
    DB $2A,$43,$00,$28,$00   ; $4DCE  Dragon x Beast -> Dragon
    DB $2A,$95,$00,$28,$00   ; $4DD3  Dragon x Devil -> Dragon
    DB $2A,$AE,$00,$28,$00   ; $4DD8  Dragon x Zomby -> Dragon
    DB $2A,$C5,$00,$28,$00   ; $4DDD  Dragon x Materl -> Dragon
;  --- parent1 = $2B (Dragon) ---
    DB $2B,$43,$00,$28,$00   ; $4DE2  Dragon x Beast -> Dragon
    DB $2B,$95,$00,$28,$00   ; $4DE7  Dragon x Devil -> Dragon
    DB $2B,$AE,$00,$28,$00   ; $4DEC  Dragon x Zomby -> Dragon
    DB $2B,$C5,$00,$28,$00   ; $4DF1  Dragon x Materl -> Dragon
;  --- parent1 = $22 (Dragon) ---
    DB $22,$0C,$00,$B9,$00   ; $4DF6  Dragon x Slime -> Materl
    DB $22,$0F,$00,$B9,$00   ; $4DFB  Dragon x Slime -> Materl
    DB $22,$81,$00,$B9,$00   ; $4E00  Dragon x Bug -> Materl
    DB $22,$9C,$00,$B9,$00   ; $4E05  Dragon x Zomby -> Materl
    DB $22,$BD,$00,$B9,$00   ; $4E0A  Dragon x Materl -> Materl
    DB $22,$C4,$00,$B9,$00   ; $4E0F  Dragon x Materl -> Materl
    DB $22,$C5,$00,$B9,$00   ; $4E14  Dragon x Materl -> Materl
;  --- parent1 = $24 (Dragon) ---
    DB $24,$0C,$00,$B9,$00   ; $4E19  Dragon x Slime -> Materl
    DB $24,$0F,$00,$B9,$00   ; $4E1E  Dragon x Slime -> Materl
    DB $24,$81,$00,$B9,$00   ; $4E23  Dragon x Bug -> Materl
    DB $24,$9C,$00,$B9,$00   ; $4E28  Dragon x Zomby -> Materl
    DB $24,$BD,$00,$B9,$00   ; $4E2D  Dragon x Materl -> Materl
    DB $24,$C4,$00,$B9,$00   ; $4E32  Dragon x Materl -> Materl
    DB $24,$C5,$00,$B9,$00   ; $4E37  Dragon x Materl -> Materl
;  --- parent1 = $25 (Dragon) ---
    DB $25,$0C,$00,$B9,$00   ; $4E3C  Dragon x Slime -> Materl
    DB $25,$0F,$00,$B9,$00   ; $4E41  Dragon x Slime -> Materl
    DB $25,$81,$00,$B9,$00   ; $4E46  Dragon x Bug -> Materl
    DB $25,$9C,$00,$B9,$00   ; $4E4B  Dragon x Zomby -> Materl
    DB $25,$BD,$00,$B9,$00   ; $4E50  Dragon x Materl -> Materl
    DB $25,$C4,$00,$B9,$00   ; $4E55  Dragon x Materl -> Materl
    DB $25,$C5,$00,$B9,$00   ; $4E5A  Dragon x Materl -> Materl
;  --- parent1 = $22 (Dragon) ---
    DB $22,$8C,$00,$29,$00   ; $4E5F  Dragon x Devil -> Dragon
;  --- parent1 = $25 (Dragon) ---
    DB $25,$8C,$00,$29,$00   ; $4E64  Dragon x Devil -> Dragon
;  --- parent1 = $37 (Beast) ---
    DB $37,$16,$00,$3B,$00   ; $4E69  Beast x Dragon -> Beast
    DB $37,$17,$00,$3B,$00   ; $4E6E  Beast x Dragon -> Beast
    DB $37,$1B,$00,$3B,$00   ; $4E73  Beast x Dragon -> Beast
    DB $37,$1E,$00,$3B,$00   ; $4E78  Beast x Dragon -> Beast
    DB $37,$2A,$00,$3B,$00   ; $4E7D  Beast x Dragon -> Beast
    DB $37,$2B,$00,$3B,$00   ; $4E82  Beast x Dragon -> Beast
;  --- parent1 = $3F (Beast) ---
    DB $3F,$16,$00,$3B,$00   ; $4E87  Beast x Dragon -> Beast
    DB $3F,$17,$00,$3B,$00   ; $4E8C  Beast x Dragon -> Beast
    DB $3F,$1B,$00,$3B,$00   ; $4E91  Beast x Dragon -> Beast
    DB $3F,$1E,$00,$3B,$00   ; $4E96  Beast x Dragon -> Beast
    DB $3F,$2A,$00,$3B,$00   ; $4E9B  Beast x Dragon -> Beast
    DB $3F,$2B,$00,$3B,$00   ; $4EA0  Beast x Dragon -> Beast
;  --- parent1 = $40 (Beast) ---
    DB $40,$16,$00,$3B,$00   ; $4EA5  Beast x Dragon -> Beast
    DB $40,$17,$00,$3B,$00   ; $4EAA  Beast x Dragon -> Beast
    DB $40,$1B,$00,$3B,$00   ; $4EAF  Beast x Dragon -> Beast
    DB $40,$1E,$00,$3B,$00   ; $4EB4  Beast x Dragon -> Beast
    DB $40,$2A,$00,$3B,$00   ; $4EB9  Beast x Dragon -> Beast
    DB $40,$2B,$00,$3B,$00   ; $4EBE  Beast x Dragon -> Beast
;  --- parent1 = $44 (Beast) ---
    DB $44,$16,$00,$3B,$00   ; $4EC3  Beast x Dragon -> Beast
    DB $44,$17,$00,$3B,$00   ; $4EC8  Beast x Dragon -> Beast
    DB $44,$1B,$00,$3B,$00   ; $4ECD  Beast x Dragon -> Beast
    DB $44,$1E,$00,$3B,$00   ; $4ED2  Beast x Dragon -> Beast
    DB $44,$2A,$00,$3B,$00   ; $4ED7  Beast x Dragon -> Beast
    DB $44,$2B,$00,$3B,$00   ; $4EDC  Beast x Dragon -> Beast
;  --- parent1 = $2D (Beast) ---
    DB $2D,$03,$00,$36,$00   ; $4EE1  Beast x Slime -> Beast
    DB $2D,$0A,$00,$36,$00   ; $4EE6  Beast x Slime -> Beast
    DB $2D,$1E,$00,$36,$00   ; $4EEB  Beast x Dragon -> Beast
    DB $2D,$58,$00,$36,$00   ; $4EF0  Beast x Bird -> Beast
    DB $2D,$5A,$00,$36,$00   ; $4EF5  Beast x Plant -> Beast
    DB $2D,$66,$00,$36,$00   ; $4EFA  Beast x Plant -> Beast
    DB $2D,$74,$00,$36,$00   ; $4EFF  Beast x Bug -> Beast
    DB $2D,$85,$00,$36,$00   ; $4F04  Beast x Devil -> Beast
    DB $2D,$8B,$00,$36,$00   ; $4F09  Beast x Devil -> Beast
    DB $2D,$AE,$00,$36,$00   ; $4F0E  Beast x Zomby -> Beast
    DB $2D,$AF,$00,$36,$00   ; $4F13  Beast x Materl -> Beast
    DB $2D,$C2,$00,$36,$00   ; $4F18  Beast x Materl -> Beast
;  --- parent1 = $32 (Beast) ---
    DB $32,$03,$00,$36,$00   ; $4F1D  Beast x Slime -> Beast
    DB $32,$0A,$00,$36,$00   ; $4F22  Beast x Slime -> Beast
    DB $32,$1E,$00,$36,$00   ; $4F27  Beast x Dragon -> Beast
    DB $32,$58,$00,$36,$00   ; $4F2C  Beast x Bird -> Beast
    DB $32,$5A,$00,$36,$00   ; $4F31  Beast x Plant -> Beast
    DB $32,$66,$00,$36,$00   ; $4F36  Beast x Plant -> Beast
    DB $32,$74,$00,$36,$00   ; $4F3B  Beast x Bug -> Beast
    DB $32,$85,$00,$36,$00   ; $4F40  Beast x Devil -> Beast
    DB $32,$8B,$00,$36,$00   ; $4F45  Beast x Devil -> Beast
    DB $32,$AE,$00,$36,$00   ; $4F4A  Beast x Zomby -> Beast
    DB $32,$AF,$00,$36,$00   ; $4F4F  Beast x Materl -> Beast
    DB $32,$C2,$00,$36,$00   ; $4F54  Beast x Materl -> Beast
;  --- parent1 = $2D (Beast) ---
    DB $2D,$51,$00,$41,$00   ; $4F59  Beast x Bird -> Beast
    DB $2D,$53,$00,$41,$00   ; $4F5E  Beast x Bird -> Beast
    DB $2D,$56,$00,$41,$00   ; $4F63  Beast x Bird -> Beast
    DB $2D,$57,$00,$41,$00   ; $4F68  Beast x Bird -> Beast
;  --- parent1 = $32 (Beast) ---
    DB $32,$51,$00,$41,$00   ; $4F6D  Beast x Bird -> Beast
    DB $32,$53,$00,$41,$00   ; $4F72  Beast x Bird -> Beast
    DB $32,$56,$00,$41,$00   ; $4F77  Beast x Bird -> Beast
    DB $32,$57,$00,$41,$00   ; $4F7C  Beast x Bird -> Beast
;  --- parent1 = $3A (Beast) ---
    DB $3A,$51,$00,$41,$00   ; $4F81  Beast x Bird -> Beast
    DB $3A,$53,$00,$41,$00   ; $4F86  Beast x Bird -> Beast
    DB $3A,$56,$00,$41,$00   ; $4F8B  Beast x Bird -> Beast
    DB $3A,$57,$00,$41,$00   ; $4F90  Beast x Bird -> Beast
;  --- parent1 = $3B (Beast) ---
    DB $3B,$51,$00,$41,$00   ; $4F95  Beast x Bird -> Beast
    DB $3B,$53,$00,$41,$00   ; $4F9A  Beast x Bird -> Beast
    DB $3B,$56,$00,$41,$00   ; $4F9F  Beast x Bird -> Beast
    DB $3B,$57,$00,$41,$00   ; $4FA4  Beast x Bird -> Beast
;  --- parent1 = $2D (Beast) ---
    DB $2D,$81,$00,$32,$00   ; $4FA9  Beast x Bug -> Beast
    DB $2D,$9C,$00,$32,$00   ; $4FAE  Beast x Zomby -> Beast
    DB $2D,$A9,$00,$32,$00   ; $4FB3  Beast x Zomby -> Beast
    DB $2D,$AA,$00,$32,$00   ; $4FB8  Beast x Zomby -> Beast
    DB $2D,$AC,$00,$32,$00   ; $4FBD  Beast x Zomby -> Beast
;  --- parent1 = $3A (Beast) ---
    DB $3A,$81,$00,$32,$00   ; $4FC2  Beast x Bug -> Beast
    DB $3A,$9C,$00,$32,$00   ; $4FC7  Beast x Zomby -> Beast
    DB $3A,$A9,$00,$32,$00   ; $4FCC  Beast x Zomby -> Beast
    DB $3A,$AA,$00,$32,$00   ; $4FD1  Beast x Zomby -> Beast
    DB $3A,$AC,$00,$32,$00   ; $4FD6  Beast x Zomby -> Beast
;  --- parent1 = $3B (Beast) ---
    DB $3B,$81,$00,$32,$00   ; $4FDB  Beast x Bug -> Beast
    DB $3B,$9C,$00,$32,$00   ; $4FE0  Beast x Zomby -> Beast
    DB $3B,$A9,$00,$32,$00   ; $4FE5  Beast x Zomby -> Beast
    DB $3B,$AA,$00,$32,$00   ; $4FEA  Beast x Zomby -> Beast
    DB $3B,$AC,$00,$32,$00   ; $4FEF  Beast x Zomby -> Beast
;  --- parent1 = $3E (Beast) ---
    DB $3E,$81,$00,$32,$00   ; $4FF4  Beast x Bug -> Beast
    DB $3E,$9C,$00,$32,$00   ; $4FF9  Beast x Zomby -> Beast
    DB $3E,$A9,$00,$32,$00   ; $4FFE  Beast x Zomby -> Beast
    DB $3E,$AA,$00,$32,$00   ; $5003  Beast x Zomby -> Beast
    DB $3E,$AC,$00,$32,$00   ; $5008  Beast x Zomby -> Beast
;  --- parent1 = $40 (Beast) ---
    DB $40,$81,$00,$32,$00   ; $500D  Beast x Bug -> Beast
    DB $40,$9C,$00,$32,$00   ; $5012  Beast x Zomby -> Beast
    DB $40,$A9,$00,$32,$00   ; $5017  Beast x Zomby -> Beast
    DB $40,$AA,$00,$32,$00   ; $501C  Beast x Zomby -> Beast
    DB $40,$AC,$00,$32,$00   ; $5021  Beast x Zomby -> Beast
;  --- parent1 = $41 (Beast) ---
    DB $41,$81,$00,$32,$00   ; $5026  Beast x Bug -> Beast
    DB $41,$9C,$00,$32,$00   ; $502B  Beast x Zomby -> Beast
    DB $41,$A9,$00,$32,$00   ; $5030  Beast x Zomby -> Beast
    DB $41,$AA,$00,$32,$00   ; $5035  Beast x Zomby -> Beast
    DB $41,$AC,$00,$32,$00   ; $503A  Beast x Zomby -> Beast
;  --- parent1 = $37 (Beast) ---
    DB $37,$B9,$00,$32,$00   ; $503F  Beast x Materl -> Beast
    DB $37,$BD,$00,$32,$00   ; $5044  Beast x Materl -> Beast
    DB $37,$C0,$00,$32,$00   ; $5049  Beast x Materl -> Beast
    DB $37,$C1,$00,$32,$00   ; $504E  Beast x Materl -> Beast
    DB $37,$C4,$00,$32,$00   ; $5053  Beast x Materl -> Beast
    DB $37,$C5,$00,$32,$00   ; $5058  Beast x Materl -> Beast
;  --- parent1 = $3A (Beast) ---
    DB $3A,$B9,$00,$32,$00   ; $505D  Beast x Materl -> Beast
    DB $3A,$BD,$00,$32,$00   ; $5062  Beast x Materl -> Beast
    DB $3A,$C0,$00,$32,$00   ; $5067  Beast x Materl -> Beast
    DB $3A,$C1,$00,$32,$00   ; $506C  Beast x Materl -> Beast
    DB $3A,$C4,$00,$32,$00   ; $5071  Beast x Materl -> Beast
    DB $3A,$C5,$00,$32,$00   ; $5076  Beast x Materl -> Beast
;  --- parent1 = $3B (Beast) ---
    DB $3B,$B9,$00,$32,$00   ; $507B  Beast x Materl -> Beast
    DB $3B,$BD,$00,$32,$00   ; $5080  Beast x Materl -> Beast
    DB $3B,$C0,$00,$32,$00   ; $5085  Beast x Materl -> Beast
    DB $3B,$C1,$00,$32,$00   ; $508A  Beast x Materl -> Beast
    DB $3B,$C4,$00,$32,$00   ; $508F  Beast x Materl -> Beast
    DB $3B,$C5,$00,$32,$00   ; $5094  Beast x Materl -> Beast
;  --- parent1 = $3E (Beast) ---
    DB $3E,$B9,$00,$32,$00   ; $5099  Beast x Materl -> Beast
    DB $3E,$BD,$00,$32,$00   ; $509E  Beast x Materl -> Beast
    DB $3E,$C0,$00,$32,$00   ; $50A3  Beast x Materl -> Beast
    DB $3E,$C1,$00,$32,$00   ; $50A8  Beast x Materl -> Beast
    DB $3E,$C4,$00,$32,$00   ; $50AD  Beast x Materl -> Beast
    DB $3E,$C5,$00,$32,$00   ; $50B2  Beast x Materl -> Beast
;  --- parent1 = $3F (Beast) ---
    DB $3F,$B9,$00,$32,$00   ; $50B7  Beast x Materl -> Beast
    DB $3F,$BD,$00,$32,$00   ; $50BC  Beast x Materl -> Beast
    DB $3F,$C0,$00,$32,$00   ; $50C1  Beast x Materl -> Beast
    DB $3F,$C1,$00,$32,$00   ; $50C6  Beast x Materl -> Beast
    DB $3F,$C4,$00,$32,$00   ; $50CB  Beast x Materl -> Beast
    DB $3F,$C5,$00,$32,$00   ; $50D0  Beast x Materl -> Beast
;  --- parent1 = $40 (Beast) ---
    DB $40,$B9,$00,$32,$00   ; $50D5  Beast x Materl -> Beast
    DB $40,$BD,$00,$32,$00   ; $50DA  Beast x Materl -> Beast
    DB $40,$C0,$00,$32,$00   ; $50DF  Beast x Materl -> Beast
    DB $40,$C1,$00,$32,$00   ; $50E4  Beast x Materl -> Beast
    DB $40,$C4,$00,$32,$00   ; $50E9  Beast x Materl -> Beast
    DB $40,$C5,$00,$32,$00   ; $50EE  Beast x Materl -> Beast
;  --- parent1 = $32 (Beast) ---
    DB $32,$B9,$00,$41,$00   ; $50F3  Beast x Materl -> Beast
    DB $32,$BA,$00,$41,$00   ; $50F8  Beast x Materl -> Beast
    DB $32,$BD,$00,$41,$00   ; $50FD  Beast x Materl -> Beast
    DB $32,$C0,$00,$41,$00   ; $5102  Beast x Materl -> Beast
    DB $32,$C1,$00,$41,$00   ; $5107  Beast x Materl -> Beast
    DB $32,$C4,$00,$41,$00   ; $510C  Beast x Materl -> Beast
    DB $32,$C5,$00,$41,$00   ; $5111  Beast x Materl -> Beast
;  --- parent1 = $41 (Beast) ---
    DB $41,$B9,$00,$42,$00   ; $5116  Beast x Materl -> Beast
    DB $41,$BA,$00,$42,$00   ; $511B  Beast x Materl -> Beast
    DB $41,$C7,$00,$42,$00   ; $5120  Beast x Materl -> Beast
;  --- parent1 = $51 (Bird) ---
    DB $51,$0B,$00,$57,$00   ; $5125  Bird x Slime -> Bird
    DB $51,$0C,$00,$57,$00   ; $512A  Bird x Slime -> Bird
    DB $51,$81,$00,$57,$00   ; $512F  Bird x Bug -> Bird
    DB $51,$B9,$00,$57,$00   ; $5134  Bird x Materl -> Bird
    DB $51,$C4,$00,$57,$00   ; $5139  Bird x Materl -> Bird
    DB $51,$C5,$00,$57,$00   ; $513E  Bird x Materl -> Bird
;  --- parent1 = $52 (Bird) ---
    DB $52,$0B,$00,$57,$00   ; $5143  Bird x Slime -> Bird
    DB $52,$0C,$00,$57,$00   ; $5148  Bird x Slime -> Bird
    DB $52,$81,$00,$57,$00   ; $514D  Bird x Bug -> Bird
    DB $52,$B9,$00,$57,$00   ; $5152  Bird x Materl -> Bird
    DB $52,$C4,$00,$57,$00   ; $5157  Bird x Materl -> Bird
    DB $52,$C5,$00,$57,$00   ; $515C  Bird x Materl -> Bird
;  --- parent1 = $53 (Bird) ---
    DB $53,$0B,$00,$57,$00   ; $5161  Bird x Slime -> Bird
    DB $53,$0C,$00,$57,$00   ; $5166  Bird x Slime -> Bird
    DB $53,$81,$00,$57,$00   ; $516B  Bird x Bug -> Bird
    DB $53,$B9,$00,$57,$00   ; $5170  Bird x Materl -> Bird
    DB $53,$C4,$00,$57,$00   ; $5175  Bird x Materl -> Bird
    DB $53,$C5,$00,$57,$00   ; $517A  Bird x Materl -> Bird
;  --- parent1 = $54 (Bird) ---
    DB $54,$0B,$00,$57,$00   ; $517F  Bird x Slime -> Bird
    DB $54,$0C,$00,$57,$00   ; $5184  Bird x Slime -> Bird
    DB $54,$81,$00,$57,$00   ; $5189  Bird x Bug -> Bird
    DB $54,$B9,$00,$57,$00   ; $518E  Bird x Materl -> Bird
    DB $54,$C4,$00,$57,$00   ; $5193  Bird x Materl -> Bird
    DB $54,$C5,$00,$57,$00   ; $5198  Bird x Materl -> Bird
;  --- parent1 = $56 (Bird) ---
    DB $56,$0B,$00,$57,$00   ; $519D  Bird x Slime -> Bird
    DB $56,$0C,$00,$57,$00   ; $51A2  Bird x Slime -> Bird
    DB $56,$81,$00,$57,$00   ; $51A7  Bird x Bug -> Bird
    DB $56,$B9,$00,$57,$00   ; $51AC  Bird x Materl -> Bird
    DB $56,$C4,$00,$57,$00   ; $51B1  Bird x Materl -> Bird
    DB $56,$C5,$00,$57,$00   ; $51B6  Bird x Materl -> Bird
;  --- parent1 = $53 (Bird) ---
    DB $53,$BF,$00,$56,$00   ; $51BB  Bird x Materl -> Bird
;  --- parent1 = $55 (Bird) ---
    DB $55,$BF,$00,$56,$00   ; $51C0  Bird x Materl -> Bird
;  --- parent1 = $57 (Bird) ---
    DB $57,$BF,$00,$56,$00   ; $51C5  Bird x Materl -> Bird
;  --- parent1 = $71 (Bug) ---
    DB $71,$71,$00,$7C,$00   ; $51CA  Bug x Bug -> Bug
    DB $71,$78,$00,$7C,$00   ; $51CF  Bug x Bug -> Bug
    DB $71,$7A,$00,$7C,$00   ; $51D4  Bug x Bug -> Bug
;  --- parent1 = $78 (Bug) ---
    DB $78,$71,$00,$7C,$00   ; $51D9  Bug x Bug -> Bug
    DB $78,$78,$00,$7C,$00   ; $51DE  Bug x Bug -> Bug
    DB $78,$7A,$00,$7C,$00   ; $51E3  Bug x Bug -> Bug
;  --- parent1 = $7A (Bug) ---
    DB $7A,$71,$00,$7C,$00   ; $51E8  Bug x Bug -> Bug
    DB $7A,$78,$00,$7C,$00   ; $51ED  Bug x Bug -> Bug
    DB $7A,$7A,$00,$7C,$00   ; $51F2  Bug x Bug -> Bug
;  --- parent1 = $84 (Devil) ---
    DB $84,$0E,$00,$83,$00   ; $51F7  Devil x Slime -> Devil
    DB $84,$0F,$00,$83,$00   ; $51FC  Devil x Slime -> Devil
    DB $84,$12,$00,$83,$00   ; $5201  Devil x Slime -> Devil
    DB $84,$22,$00,$83,$00   ; $5206  Devil x Dragon -> Devil
    DB $84,$25,$00,$83,$00   ; $520B  Devil x Dragon -> Devil
    DB $84,$29,$00,$83,$00   ; $5210  Devil x Dragon -> Devil
    DB $84,$41,$00,$83,$00   ; $5215  Devil x Beast -> Devil
    DB $84,$42,$00,$83,$00   ; $521A  Devil x Beast -> Devil
    DB $84,$56,$00,$83,$00   ; $521F  Devil x Bird -> Devil
    DB $84,$57,$00,$83,$00   ; $5224  Devil x Bird -> Devil
    DB $84,$B9,$00,$83,$00   ; $5229  Devil x Materl -> Devil
    DB $84,$C5,$00,$83,$00   ; $522E  Devil x Materl -> Devil
;  --- parent1 = $93 (Devil) ---
    DB $93,$0E,$00,$83,$00   ; $5233  Devil x Slime -> Devil
    DB $93,$0F,$00,$83,$00   ; $5238  Devil x Slime -> Devil
    DB $93,$12,$00,$83,$00   ; $523D  Devil x Slime -> Devil
    DB $93,$22,$00,$83,$00   ; $5242  Devil x Dragon -> Devil
    DB $93,$25,$00,$83,$00   ; $5247  Devil x Dragon -> Devil
    DB $93,$29,$00,$83,$00   ; $524C  Devil x Dragon -> Devil
    DB $93,$41,$00,$83,$00   ; $5251  Devil x Beast -> Devil
    DB $93,$42,$00,$83,$00   ; $5256  Devil x Beast -> Devil
    DB $93,$56,$00,$83,$00   ; $525B  Devil x Bird -> Devil
    DB $93,$57,$00,$83,$00   ; $5260  Devil x Bird -> Devil
    DB $93,$B9,$00,$83,$00   ; $5265  Devil x Materl -> Devil
    DB $93,$C5,$00,$83,$00   ; $526A  Devil x Materl -> Devil
;  --- parent1 = $96 (Devil) ---
    DB $96,$0E,$00,$83,$00   ; $526F  Devil x Slime -> Devil
    DB $96,$0F,$00,$83,$00   ; $5274  Devil x Slime -> Devil
    DB $96,$12,$00,$83,$00   ; $5279  Devil x Slime -> Devil
    DB $96,$22,$00,$83,$00   ; $527E  Devil x Dragon -> Devil
    DB $96,$25,$00,$83,$00   ; $5283  Devil x Dragon -> Devil
    DB $96,$29,$00,$83,$00   ; $5288  Devil x Dragon -> Devil
    DB $96,$41,$00,$83,$00   ; $528D  Devil x Beast -> Devil
    DB $96,$42,$00,$83,$00   ; $5292  Devil x Beast -> Devil
    DB $96,$56,$00,$83,$00   ; $5297  Devil x Bird -> Devil
    DB $96,$57,$00,$83,$00   ; $529C  Devil x Bird -> Devil
    DB $96,$B9,$00,$83,$00   ; $52A1  Devil x Materl -> Devil
    DB $96,$C5,$00,$83,$00   ; $52A6  Devil x Materl -> Devil
;  --- parent1 = $84 (Devil) ---
    DB $84,$0C,$00,$91,$00   ; $52AB  Devil x Slime -> Devil
    DB $84,$1B,$00,$91,$00   ; $52B0  Devil x Dragon -> Devil
    DB $84,$28,$00,$91,$00   ; $52B5  Devil x Dragon -> Devil
    DB $84,$4D,$00,$91,$00   ; $52BA  Devil x Bird -> Devil
    DB $84,$53,$00,$91,$00   ; $52BF  Devil x Bird -> Devil
    DB $84,$6C,$00,$91,$00   ; $52C4  Devil x Plant -> Devil
    DB $84,$7B,$00,$91,$00   ; $52C9  Devil x Bug -> Devil
    DB $84,$9C,$00,$91,$00   ; $52CE  Devil x Zomby -> Devil
    DB $84,$A9,$00,$91,$00   ; $52D3  Devil x Zomby -> Devil
    DB $84,$AA,$00,$91,$00   ; $52D8  Devil x Zomby -> Devil
;  --- parent1 = $93 (Devil) ---
    DB $93,$0C,$00,$91,$00   ; $52DD  Devil x Slime -> Devil
    DB $93,$1B,$00,$91,$00   ; $52E2  Devil x Dragon -> Devil
    DB $93,$28,$00,$91,$00   ; $52E7  Devil x Dragon -> Devil
    DB $93,$4D,$00,$91,$00   ; $52EC  Devil x Bird -> Devil
    DB $93,$53,$00,$91,$00   ; $52F1  Devil x Bird -> Devil
    DB $93,$6C,$00,$91,$00   ; $52F6  Devil x Plant -> Devil
    DB $93,$7B,$00,$91,$00   ; $52FB  Devil x Bug -> Devil
    DB $93,$9C,$00,$91,$00   ; $5300  Devil x Zomby -> Devil
    DB $93,$A9,$00,$91,$00   ; $5305  Devil x Zomby -> Devil
    DB $93,$AA,$00,$91,$00   ; $530A  Devil x Zomby -> Devil
;  --- parent1 = $96 (Devil) ---
    DB $96,$0C,$00,$91,$00   ; $530F  Devil x Slime -> Devil
    DB $96,$1B,$00,$91,$00   ; $5314  Devil x Dragon -> Devil
    DB $96,$28,$00,$91,$00   ; $5319  Devil x Dragon -> Devil
    DB $96,$4D,$00,$91,$00   ; $531E  Devil x Bird -> Devil
    DB $96,$53,$00,$91,$00   ; $5323  Devil x Bird -> Devil
    DB $96,$6C,$00,$91,$00   ; $5328  Devil x Plant -> Devil
    DB $96,$7B,$00,$91,$00   ; $532D  Devil x Bug -> Devil
    DB $96,$9C,$00,$91,$00   ; $5332  Devil x Zomby -> Devil
    DB $96,$A9,$00,$91,$00   ; $5337  Devil x Zomby -> Devil
    DB $96,$AA,$00,$91,$00   ; $533C  Devil x Zomby -> Devil
;  --- parent1 = $84 (Devil) ---
    DB $84,$32,$00,$90,$00   ; $5341  Devil x Beast -> Devil
    DB $84,$3E,$00,$90,$00   ; $5346  Devil x Beast -> Devil
    DB $84,$81,$00,$90,$00   ; $534B  Devil x Bug -> Devil
    DB $84,$BD,$00,$90,$00   ; $5350  Devil x Materl -> Devil
;  --- parent1 = $93 (Devil) ---
    DB $93,$32,$00,$90,$00   ; $5355  Devil x Beast -> Devil
    DB $93,$3E,$00,$90,$00   ; $535A  Devil x Beast -> Devil
    DB $93,$81,$00,$90,$00   ; $535F  Devil x Bug -> Devil
    DB $93,$BD,$00,$90,$00   ; $5364  Devil x Materl -> Devil
;  --- parent1 = $96 (Devil) ---
    DB $96,$32,$00,$90,$00   ; $5369  Devil x Beast -> Devil
    DB $96,$3E,$00,$90,$00   ; $536E  Devil x Beast -> Devil
    DB $96,$81,$00,$90,$00   ; $5373  Devil x Bug -> Devil
    DB $96,$BD,$00,$90,$00   ; $5378  Devil x Materl -> Devil
;  --- parent1 = $83 (Devil) ---
    DB $83,$91,$00,$94,$00   ; $537D  Devil x Devil -> Devil
;  --- parent1 = $9F (Zomby) ---
    DB $9F,$0B,$00,$AB,$00   ; $5382  Zomby x Slime -> Zomby
    DB $9F,$0C,$00,$AB,$00   ; $5387  Zomby x Slime -> Zomby
    DB $9F,$51,$00,$AB,$00   ; $538C  Zomby x Bird -> Zomby
    DB $9F,$52,$00,$AB,$00   ; $5391  Zomby x Bird -> Zomby
    DB $9F,$5C,$00,$AB,$00   ; $5396  Zomby x Plant -> Zomby
    DB $9F,$7F,$00,$AB,$00   ; $539B  Zomby x Bug -> Zomby
    DB $9F,$8B,$00,$AB,$00   ; $53A0  Zomby x Devil -> Zomby
;  --- parent1 = $A1 (Zomby) ---
    DB $A1,$0B,$00,$AB,$00   ; $53A5  Zomby x Slime -> Zomby
    DB $A1,$0C,$00,$AB,$00   ; $53AA  Zomby x Slime -> Zomby
    DB $A1,$51,$00,$AB,$00   ; $53AF  Zomby x Bird -> Zomby
    DB $A1,$52,$00,$AB,$00   ; $53B4  Zomby x Bird -> Zomby
    DB $A1,$5C,$00,$AB,$00   ; $53B9  Zomby x Plant -> Zomby
    DB $A1,$7F,$00,$AB,$00   ; $53BE  Zomby x Bug -> Zomby
    DB $A1,$8B,$00,$AB,$00   ; $53C3  Zomby x Devil -> Zomby
;  --- parent1 = $A3 (Zomby) ---
    DB $A3,$0B,$00,$AB,$00   ; $53C8  Zomby x Slime -> Zomby
    DB $A3,$0C,$00,$AB,$00   ; $53CD  Zomby x Slime -> Zomby
    DB $A3,$51,$00,$AB,$00   ; $53D2  Zomby x Bird -> Zomby
    DB $A3,$52,$00,$AB,$00   ; $53D7  Zomby x Bird -> Zomby
    DB $A3,$5C,$00,$AB,$00   ; $53DC  Zomby x Plant -> Zomby
    DB $A3,$7F,$00,$AB,$00   ; $53E1  Zomby x Bug -> Zomby
    DB $A3,$8B,$00,$AB,$00   ; $53E6  Zomby x Devil -> Zomby
;  --- parent1 = $9F (Zomby) ---
    DB $9F,$32,$00,$AC,$00   ; $53EB  Zomby x Beast -> Zomby
    DB $9F,$3A,$00,$AC,$00   ; $53F0  Zomby x Beast -> Zomby
    DB $9F,$44,$00,$AC,$00   ; $53F5  Zomby x Beast -> Zomby
    DB $9F,$4C,$00,$AC,$00   ; $53FA  Zomby x Bird -> Zomby
    DB $9F,$53,$00,$AC,$00   ; $53FF  Zomby x Bird -> Zomby
    DB $9F,$89,$00,$AC,$00   ; $5404  Zomby x Devil -> Zomby
    DB $9F,$90,$00,$AC,$00   ; $5409  Zomby x Devil -> Zomby
    DB $9F,$C4,$00,$AC,$00   ; $540E  Zomby x Materl -> Zomby
    DB $9F,$C5,$00,$AC,$00   ; $5413  Zomby x Materl -> Zomby
;  --- parent1 = $A1 (Zomby) ---
    DB $A1,$32,$00,$AC,$00   ; $5418  Zomby x Beast -> Zomby
    DB $A1,$3A,$00,$AC,$00   ; $541D  Zomby x Beast -> Zomby
    DB $A1,$44,$00,$AC,$00   ; $5422  Zomby x Beast -> Zomby
    DB $A1,$4C,$00,$AC,$00   ; $5427  Zomby x Bird -> Zomby
    DB $A1,$53,$00,$AC,$00   ; $542C  Zomby x Bird -> Zomby
    DB $A1,$89,$00,$AC,$00   ; $5431  Zomby x Devil -> Zomby
    DB $A1,$90,$00,$AC,$00   ; $5436  Zomby x Devil -> Zomby
    DB $A1,$C4,$00,$AC,$00   ; $543B  Zomby x Materl -> Zomby
    DB $A1,$C5,$00,$AC,$00   ; $5440  Zomby x Materl -> Zomby
;  --- parent1 = $A3 (Zomby) ---
    DB $A3,$32,$00,$AC,$00   ; $5445  Zomby x Beast -> Zomby
    DB $A3,$3A,$00,$AC,$00   ; $544A  Zomby x Beast -> Zomby
    DB $A3,$44,$00,$AC,$00   ; $544F  Zomby x Beast -> Zomby
    DB $A3,$4C,$00,$AC,$00   ; $5454  Zomby x Bird -> Zomby
    DB $A3,$53,$00,$AC,$00   ; $5459  Zomby x Bird -> Zomby
    DB $A3,$89,$00,$AC,$00   ; $545E  Zomby x Devil -> Zomby
    DB $A3,$90,$00,$AC,$00   ; $5463  Zomby x Devil -> Zomby
    DB $A3,$C4,$00,$AC,$00   ; $5468  Zomby x Materl -> Zomby
    DB $A3,$C5,$00,$AC,$00   ; $546D  Zomby x Materl -> Zomby
;  --- parent1 = $A4 (Zomby) ---
    DB $A4,$32,$00,$AC,$00   ; $5472  Zomby x Beast -> Zomby
    DB $A4,$3A,$00,$AC,$00   ; $5477  Zomby x Beast -> Zomby
    DB $A4,$44,$00,$AC,$00   ; $547C  Zomby x Beast -> Zomby
    DB $A4,$4C,$00,$AC,$00   ; $5481  Zomby x Bird -> Zomby
    DB $A4,$53,$00,$AC,$00   ; $5486  Zomby x Bird -> Zomby
    DB $A4,$89,$00,$AC,$00   ; $548B  Zomby x Devil -> Zomby
    DB $A4,$90,$00,$AC,$00   ; $5490  Zomby x Devil -> Zomby
    DB $A4,$C4,$00,$AC,$00   ; $5495  Zomby x Materl -> Zomby
    DB $A4,$C5,$00,$AC,$00   ; $549A  Zomby x Materl -> Zomby
    DB $A4,$83,$00,$A9,$00   ; $549F  Zomby x Devil -> Zomby
    DB $A4,$8D,$00,$A9,$00   ; $54A4  Zomby x Devil -> Zomby
    DB $A4,$91,$00,$A9,$00   ; $54A9  Zomby x Devil -> Zomby
    DB $A4,$B9,$00,$A9,$00   ; $54AE  Zomby x Materl -> Zomby
    DB $A4,$BD,$00,$A9,$00   ; $54B3  Zomby x Materl -> Zomby
;  --- parent1 = $A6 (Zomby) ---
    DB $A6,$83,$00,$A9,$00   ; $54B8  Zomby x Devil -> Zomby
    DB $A6,$8D,$00,$A9,$00   ; $54BD  Zomby x Devil -> Zomby
    DB $A6,$91,$00,$A9,$00   ; $54C2  Zomby x Devil -> Zomby
    DB $A6,$B9,$00,$A9,$00   ; $54C7  Zomby x Materl -> Zomby
    DB $A6,$BD,$00,$A9,$00   ; $54CC  Zomby x Materl -> Zomby
;  --- parent1 = $AB (Zomby) ---
    DB $AB,$83,$00,$A9,$00   ; $54D1  Zomby x Devil -> Zomby
    DB $AB,$8D,$00,$A9,$00   ; $54D6  Zomby x Devil -> Zomby
    DB $AB,$91,$00,$A9,$00   ; $54DB  Zomby x Devil -> Zomby
    DB $AB,$B9,$00,$A9,$00   ; $54E0  Zomby x Materl -> Zomby
    DB $AB,$BD,$00,$A9,$00   ; $54E5  Zomby x Materl -> Zomby
;  --- parent1 = $AC (Zomby) ---
    DB $AC,$83,$00,$A9,$00   ; $54EA  Zomby x Devil -> Zomby
    DB $AC,$8D,$00,$A9,$00   ; $54EF  Zomby x Devil -> Zomby
    DB $AC,$91,$00,$A9,$00   ; $54F4  Zomby x Devil -> Zomby
    DB $AC,$B9,$00,$A9,$00   ; $54F9  Zomby x Materl -> Zomby
    DB $AC,$BD,$00,$A9,$00   ; $54FE  Zomby x Materl -> Zomby
;  --- parent1 = $9C (Zomby) ---
    DB $9C,$0E,$00,$AA,$00   ; $5503  Zomby x Slime -> Zomby
    DB $9C,$0F,$00,$AA,$00   ; $5508  Zomby x Slime -> Zomby
    DB $9C,$12,$00,$AA,$00   ; $550D  Zomby x Slime -> Zomby
    DB $9C,$22,$00,$AA,$00   ; $5512  Zomby x Dragon -> Zomby
    DB $9C,$25,$00,$AA,$00   ; $5517  Zomby x Dragon -> Zomby
    DB $9C,$42,$00,$AA,$00   ; $551C  Zomby x Beast -> Zomby
    DB $9C,$54,$00,$AA,$00   ; $5521  Zomby x Bird -> Zomby
    DB $9C,$56,$00,$AA,$00   ; $5526  Zomby x Bird -> Zomby
    DB $9C,$57,$00,$AA,$00   ; $552B  Zomby x Bird -> Zomby
    DB $9C,$C7,$00,$AA,$00   ; $5530  Zomby x Materl -> Zomby
;  --- parent1 = $A9 (Zomby) ---
    DB $A9,$0E,$00,$AA,$00   ; $5535  Zomby x Slime -> Zomby
    DB $A9,$0F,$00,$AA,$00   ; $553A  Zomby x Slime -> Zomby
    DB $A9,$12,$00,$AA,$00   ; $553F  Zomby x Slime -> Zomby
    DB $A9,$22,$00,$AA,$00   ; $5544  Zomby x Dragon -> Zomby
    DB $A9,$25,$00,$AA,$00   ; $5549  Zomby x Dragon -> Zomby
    DB $A9,$42,$00,$AA,$00   ; $554E  Zomby x Beast -> Zomby
    DB $A9,$54,$00,$AA,$00   ; $5553  Zomby x Bird -> Zomby
    DB $A9,$56,$00,$AA,$00   ; $5558  Zomby x Bird -> Zomby
    DB $A9,$57,$00,$AA,$00   ; $555D  Zomby x Bird -> Zomby
    DB $A9,$C7,$00,$AA,$00   ; $5562  Zomby x Materl -> Zomby
;  --- parent1 = $AB (Zomby) ---
    DB $AB,$0E,$00,$AA,$00   ; $5567  Zomby x Slime -> Zomby
    DB $AB,$0F,$00,$AA,$00   ; $556C  Zomby x Slime -> Zomby
    DB $AB,$12,$00,$AA,$00   ; $5571  Zomby x Slime -> Zomby
    DB $AB,$22,$00,$AA,$00   ; $5576  Zomby x Dragon -> Zomby
    DB $AB,$25,$00,$AA,$00   ; $557B  Zomby x Dragon -> Zomby
    DB $AB,$42,$00,$AA,$00   ; $5580  Zomby x Beast -> Zomby
    DB $AB,$54,$00,$AA,$00   ; $5585  Zomby x Bird -> Zomby
    DB $AB,$56,$00,$AA,$00   ; $558A  Zomby x Bird -> Zomby
    DB $AB,$57,$00,$AA,$00   ; $558F  Zomby x Bird -> Zomby
    DB $AB,$C7,$00,$AA,$00   ; $5594  Zomby x Materl -> Zomby
;  --- parent1 = $AC (Zomby) ---
    DB $AC,$0E,$00,$AA,$00   ; $5599  Zomby x Slime -> Zomby
    DB $AC,$0F,$00,$AA,$00   ; $559E  Zomby x Slime -> Zomby
    DB $AC,$12,$00,$AA,$00   ; $55A3  Zomby x Slime -> Zomby
    DB $AC,$22,$00,$AA,$00   ; $55A8  Zomby x Dragon -> Zomby
    DB $AC,$25,$00,$AA,$00   ; $55AD  Zomby x Dragon -> Zomby
    DB $AC,$42,$00,$AA,$00   ; $55B2  Zomby x Beast -> Zomby
    DB $AC,$54,$00,$AA,$00   ; $55B7  Zomby x Bird -> Zomby
    DB $AC,$56,$00,$AA,$00   ; $55BC  Zomby x Bird -> Zomby
    DB $AC,$57,$00,$AA,$00   ; $55C1  Zomby x Bird -> Zomby
    DB $AC,$C7,$00,$AA,$00   ; $55C6  Zomby x Materl -> Zomby
;  --- parent1 = $9C (Zomby) ---
    DB $9C,$AE,$00,$A9,$00   ; $55CB  Zomby x Zomby -> Zomby
;  --- parent1 = $A1 (Zomby) ---
    DB $A1,$AE,$00,$A9,$00   ; $55D0  Zomby x Zomby -> Zomby
;  --- parent1 = $A4 (Zomby) ---
    DB $A4,$AE,$00,$A9,$00   ; $55D5  Zomby x Zomby -> Zomby
;  --- parent1 = $AB (Zomby) ---
    DB $AB,$AE,$00,$A9,$00   ; $55DA  Zomby x Zomby -> Zomby
;  --- parent1 = $AC (Zomby) ---
    DB $AC,$AE,$00,$A9,$00   ; $55DF  Zomby x Zomby -> Zomby
;  --- parent1 = $C4 (Materl) ---
    DB $C4,$00,$00,$B8,$00   ; $55E4  Materl x Slime -> Materl
    DB $C4,$04,$00,$B8,$00   ; $55E9  Materl x Slime -> Materl
    DB $C4,$05,$00,$B8,$00   ; $55EE  Materl x Slime -> Materl
    DB $C4,$0B,$00,$B8,$00   ; $55F3  Materl x Slime -> Materl
;  --- parent1 = $C5 (Materl) ---
    DB $C5,$00,$00,$B8,$00   ; $55F8  Materl x Slime -> Materl
    DB $C5,$04,$00,$B8,$00   ; $55FD  Materl x Slime -> Materl
    DB $C5,$05,$00,$B8,$00   ; $5602  Materl x Slime -> Materl
    DB $C5,$0B,$00,$B8,$00   ; $5607  Materl x Slime -> Materl
;  --- parent1 = $B0 (Materl) ---
    DB $B0,$51,$00,$BB,$00   ; $560C  Materl x Bird -> Materl
    DB $B0,$52,$00,$BB,$00   ; $5611  Materl x Bird -> Materl
    DB $B0,$55,$00,$BB,$00   ; $5616  Materl x Bird -> Materl
    DB $B0,$58,$00,$BB,$00   ; $561B  Materl x Bird -> Materl
;  --- parent1 = $B8 (Materl) ---
    DB $B8,$51,$00,$BB,$00   ; $5620  Materl x Bird -> Materl
    DB $B8,$52,$00,$BB,$00   ; $5625  Materl x Bird -> Materl
    DB $B8,$55,$00,$BB,$00   ; $562A  Materl x Bird -> Materl
    DB $B8,$58,$00,$BB,$00   ; $562F  Materl x Bird -> Materl
;  --- parent1 = $C4 (Materl) ---
    DB $C4,$51,$00,$BB,$00   ; $5634  Materl x Bird -> Materl
    DB $C4,$52,$00,$BB,$00   ; $5639  Materl x Bird -> Materl
    DB $C4,$55,$00,$BB,$00   ; $563E  Materl x Bird -> Materl
    DB $C4,$58,$00,$BB,$00   ; $5643  Materl x Bird -> Materl
;  --- parent1 = $C5 (Materl) ---
    DB $C5,$51,$00,$BB,$00   ; $5648  Materl x Bird -> Materl
    DB $C5,$52,$00,$BB,$00   ; $564D  Materl x Bird -> Materl
    DB $C5,$55,$00,$BB,$00   ; $5652  Materl x Bird -> Materl
    DB $C5,$58,$00,$BB,$00   ; $5657  Materl x Bird -> Materl
;  --- parent1 = $B1 (Materl) ---
    DB $B1,$00,$00,$BF,$00   ; $565C  Materl x Slime -> Materl
    DB $B1,$47,$00,$BF,$00   ; $5661  Materl x Bird -> Materl
    DB $B1,$4D,$00,$BF,$00   ; $5666  Materl x Bird -> Materl
    DB $B1,$55,$00,$BF,$00   ; $566B  Materl x Bird -> Materl
    DB $B1,$5B,$00,$BF,$00   ; $5670  Materl x Plant -> Materl
    DB $B1,$69,$00,$BF,$00   ; $5675  Materl x Plant -> Materl
;  --- parent1 = $B5 (Materl) ---
    DB $B5,$00,$00,$BF,$00   ; $567A  Materl x Slime -> Materl
    DB $B5,$47,$00,$BF,$00   ; $567F  Materl x Bird -> Materl
    DB $B5,$4D,$00,$BF,$00   ; $5684  Materl x Bird -> Materl
    DB $B5,$55,$00,$BF,$00   ; $5689  Materl x Bird -> Materl
    DB $B5,$5B,$00,$BF,$00   ; $568E  Materl x Plant -> Materl
    DB $B5,$69,$00,$BF,$00   ; $5693  Materl x Plant -> Materl
;  --- parent1 = $B7 (Materl) ---
    DB $B7,$00,$00,$BF,$00   ; $5698  Materl x Slime -> Materl
    DB $B7,$47,$00,$BF,$00   ; $569D  Materl x Bird -> Materl
    DB $B7,$4D,$00,$BF,$00   ; $56A2  Materl x Bird -> Materl
    DB $B7,$55,$00,$BF,$00   ; $56A7  Materl x Bird -> Materl
    DB $B7,$5B,$00,$BF,$00   ; $56AC  Materl x Plant -> Materl
    DB $B7,$69,$00,$BF,$00   ; $56B1  Materl x Plant -> Materl
;  --- parent1 = $BB (Materl) ---
    DB $BB,$0C,$00,$BD,$00   ; $56B6  Materl x Slime -> Materl
    DB $BB,$25,$00,$BD,$00   ; $56BB  Materl x Dragon -> Materl
    DB $BB,$3E,$00,$BD,$00   ; $56C0  Materl x Beast -> Materl
    DB $BB,$90,$00,$BD,$00   ; $56C5  Materl x Devil -> Materl
    DB $BB,$93,$00,$BD,$00   ; $56CA  Materl x Devil -> Materl
    DB $BB,$98,$00,$BD,$00   ; $56CF  Materl x Devil -> Materl
    DB $BB,$A9,$00,$BD,$00   ; $56D4  Materl x Zomby -> Materl
    DB $BB,$AC,$00,$BD,$00   ; $56D9  Materl x Zomby -> Materl
;  --- parent1 = $B9 (Materl) ---
    DB $B9,$9C,$00,$C1,$00   ; $56DE  Materl x Zomby -> Materl
    DB $B9,$AA,$00,$C1,$00   ; $56E3  Materl x Zomby -> Materl
    DB $B9,$29,$00,$C0,$00   ; $56E8  Materl x Dragon -> Materl
    DB $B9,$42,$00,$C0,$00   ; $56ED  Materl x Beast -> Materl
    DB $B9,$56,$00,$C0,$00   ; $56F2  Materl x Bird -> Materl
    DB $B9,$83,$00,$C0,$00   ; $56F7  Materl x Devil -> Materl
    DB $B9,$97,$00,$C0,$00   ; $56FC  Materl x Devil -> Materl
;  --- parent1 = $BD (Materl) ---
    DB $BD,$32,$00,$42,$00   ; $5701  Materl x Beast -> Beast
    DB $BD,$36,$00,$42,$00   ; $5706  Materl x Beast -> Beast
    DB $BD,$3E,$00,$42,$00   ; $570B  Materl x Beast -> Beast
    DB $BD,$41,$00,$42,$00   ; $5710  Materl x Beast -> Beast
    DB $BD,$43,$00,$42,$00   ; $5715  Materl x Beast -> Beast
    DB $BD,$44,$00,$42,$00   ; $571A  Materl x Beast -> Beast
    DB $BD,$42,$00,$C1,$00   ; $571F  Materl x Beast -> Materl
;  --- parent1 = $94 (Devil) ---
    DB $94,$59,$00,$99,$00   ; $5724  Devil x Bird -> Devil
;  --- parent1 = $59 (Bird) ---
    DB $59,$94,$00,$99,$00   ; $5729  Bird x Devil -> Devil
;  --- parent1 = $C7 (Materl) ---
    DB $C7,$97,$00,$9A,$00   ; $572E  Materl x Devil -> Devil
;  --- parent1 = $97 (Devil) ---
    DB $97,$C7,$00,$9A,$00   ; $5733  Devil x Materl -> Devil
;  --- parent1 = $AD (Zomby) ---
    DB $AD,$22,$00,$C8,$00   ; $5738  Zomby x Dragon -> ???
    DB $AD,$25,$00,$C8,$00   ; $573D  Zomby x Dragon -> ???
;  --- parent1 = $AA (Zomby) ---
    DB $AA,$12,$00,$CA,$00   ; $5742  Zomby x Slime -> ???
;  --- parent1 = $99 (Devil) ---
    DB $99,$6C,$00,$CB,$00   ; $5747  Devil x Plant -> ???
;  --- parent1 = $CA (???) ---
    DB $CA,$29,$00,$CC,$00   ; $574C  ??? x Dragon -> ???
;  --- parent1 = $C8 (???) ---
    DB $C8,$CB,$00,$CD,$00   ; $5751  ??? x ??? -> ???
;  --- parent1 = $C9 (???) ---
    DB $C9,$CB,$00,$CD,$00   ; $5756  ??? x ??? -> ???
;  --- parent1 = $9A (Devil) ---
    DB $9A,$2C,$00,$CE,$00   ; $575B  Devil x Dragon -> ???
;  --- parent1 = $CE (???) ---
    DB $CE,$42,$00,$CF,$00   ; $5760  ??? x Beast -> ???
;  --- parent1 = $CF (???) ---
    DB $CF,$13,$00,$D0,$00   ; $5765  ??? x Slime -> ???
;  --- parent1 = $D0 (???) ---
    DB $D0,$24,$00,$D1,$00   ; $576A  ??? x Dragon -> ???
;  --- parent1 = $CC (???) ---
    DB $CC,$43,$00,$D2,$00   ; $576F  ??? x Beast -> ???
;  --- parent1 = $CD (???) ---
    DB $CD,$D0,$00,$D3,$00   ; $5774  ??? x ??? -> ???
    DB $CD,$D1,$00,$D3,$00   ; $5779  ??? x ??? -> ???
;  --- parent1 = $D0 (???) ---
    DB $D0,$CD,$00,$D3,$00   ; $577E  ??? x ??? -> ???
;  --- parent1 = $D1 (???) ---
    DB $D1,$CD,$00,$D3,$00   ; $5783  ??? x ??? -> ???
;  --- parent1 = $D3 (???) ---
    DB $D3,$80,$00,$D4,$00   ; $5788  ??? x Bug -> ???
;  --- parent1 = $D4 (???) ---
    DB $D4,$D2,$00,$D5,$00   ; $578D  ??? x ??? -> ???
;  --- parent1 = $D5 (???) ---
    DB $D5,$6D,$00,$D6,$00   ; $5792  ??? x Plant -> ???
;  --- parent1 = $17 (Dragon) ---
    DB $17,$F2,$00,$1E,$00   ; $5797  Dragon x AnyBeast -> Dragon
;  --- parent1 = $3A (Beast) ---
    DB $3A,$F1,$00,$32,$00   ; $579C  Beast x AnyDragon -> Beast
;  --- parent1 = $3B (Beast) ---
    DB $3B,$F1,$00,$32,$00   ; $57A1  Beast x AnyDragon -> Beast
;  --- parent1 = $41 (Beast) ---
    DB $41,$F1,$00,$32,$00   ; $57A6  Beast x AnyDragon -> Beast
;  --- parent1 = $45 (Beast) ---
    DB $45,$F1,$00,$32,$00   ; $57AB  Beast x AnyDragon -> Beast
;  --- parent1 = $2E (Beast) ---
    DB $2E,$F1,$00,$40,$00   ; $57B0  Beast x AnyDragon -> Beast
;  --- parent1 = $36 (Beast) ---
    DB $36,$F1,$00,$41,$00   ; $57B5  Beast x AnyDragon -> Beast
;  --- parent1 = $2D (Beast) ---
    DB $2D,$F0,$00,$3E,$00   ; $57BA  Beast x AnySlime -> Beast
;  --- parent1 = $32 (Beast) ---
    DB $32,$F0,$00,$3E,$00   ; $57BF  Beast x AnySlime -> Beast
;  --- parent1 = $3A (Beast) ---
    DB $3A,$F0,$00,$3E,$00   ; $57C4  Beast x AnySlime -> Beast
;  --- parent1 = $3B (Beast) ---
    DB $3B,$F0,$00,$3E,$00   ; $57C9  Beast x AnySlime -> Beast
;  --- parent1 = $3F (Beast) ---
    DB $3F,$F0,$00,$3E,$00   ; $57CE  Beast x AnySlime -> Beast
;  --- parent1 = $40 (Beast) ---
    DB $40,$F0,$00,$3E,$00   ; $57D3  Beast x AnySlime -> Beast
;  --- parent1 = $41 (Beast) ---
    DB $41,$F0,$00,$3E,$00   ; $57D8  Beast x AnySlime -> Beast
;  --- parent1 = $2F (Beast) ---
    DB $2F,$F3,$00,$34,$00   ; $57DD  Beast x AnyBird -> Beast
;  --- parent1 = $3A (Beast) ---
    DB $3A,$F6,$00,$32,$00   ; $57E2  Beast x AnyDevil -> Beast
;  --- parent1 = $31 (Beast) ---
    DB $31,$F1,$00,$35,$00   ; $57E7  Beast x AnyDragon -> Beast
;  --- parent1 = $47 (Bird) ---
    DB $47,$F1,$00,$52,$00   ; $57EC  Bird x AnyDragon -> Bird
;  --- parent1 = $51 (Bird) ---
    DB $51,$F1,$00,$52,$00   ; $57F1  Bird x AnyDragon -> Bird
;  --- parent1 = $53 (Bird) ---
    DB $53,$F1,$00,$52,$00   ; $57F6  Bird x AnyDragon -> Bird
;  --- parent1 = $55 (Bird) ---
    DB $55,$F1,$00,$52,$00   ; $57FB  Bird x AnyDragon -> Bird
;  --- parent1 = $48 (Bird) ---
    DB $48,$F2,$00,$51,$00   ; $5800  Bird x AnyBeast -> Bird
;  --- parent1 = $51 (Bird) ---
    DB $51,$F6,$00,$53,$00   ; $5805  Bird x AnyDevil -> Bird
;  --- parent1 = $47 (Bird) ---
    DB $47,$F7,$00,$52,$00   ; $580A  Bird x AnyZomby -> Bird
;  --- parent1 = $51 (Bird) ---
    DB $51,$F7,$00,$52,$00   ; $580F  Bird x AnyZomby -> Bird
;  --- parent1 = $53 (Bird) ---
    DB $53,$F7,$00,$52,$00   ; $5814  Bird x AnyZomby -> Bird
;  --- parent1 = $55 (Bird) ---
    DB $55,$F7,$00,$52,$00   ; $5819  Bird x AnyZomby -> Bird
;  --- parent1 = $46 (Bird) ---
    DB $46,$F0,$00,$4E,$00   ; $581E  Bird x AnySlime -> Bird
;  --- parent1 = $5A (Plant) ---
    DB $5A,$F2,$00,$64,$00   ; $5823  Plant x AnyBeast -> Plant
;  --- parent1 = $64 (Plant) ---
    DB $64,$F6,$00,$67,$00   ; $5828  Plant x AnyDevil -> Plant
;  --- parent1 = $67 (Plant) ---
    DB $67,$F1,$00,$66,$00   ; $582D  Plant x AnyDragon -> Plant
;  --- parent1 = $61 (Plant) ---
    DB $61,$F2,$00,$62,$00   ; $5832  Plant x AnyBeast -> Plant
;  --- parent1 = $6E (Bug) ---
    DB $6E,$F0,$00,$76,$00   ; $5837  Bug x AnySlime -> Bug
;  --- parent1 = $74 (Bug) ---
    DB $74,$F0,$00,$7C,$00   ; $583C  Bug x AnySlime -> Bug
;  --- parent1 = $6F (Bug) ---
    DB $6F,$F2,$00,$7A,$00   ; $5841  Bug x AnyBeast -> Bug
;  --- parent1 = $73 (Bug) ---
    DB $73,$F8,$00,$79,$00   ; $5846  Bug x AnyMaterl -> Bug
;  --- parent1 = $71 (Bug) ---
    DB $71,$F6,$00,$7B,$00   ; $584B  Bug x AnyDevil -> Bug
;  --- parent1 = $7A (Bug) ---
    DB $7A,$F7,$00,$7E,$00   ; $5850  Bug x AnyZomby -> Bug
;  --- parent1 = $7C (Bug) ---
    DB $7C,$F7,$00,$7E,$00   ; $5855  Bug x AnyZomby -> Bug
;  --- parent1 = $72 (Bug) ---
    DB $72,$F4,$00,$78,$00   ; $585A  Bug x AnyPlant -> Bug
;  --- parent1 = $7C (Bug) ---
    DB $7C,$F1,$00,$79,$00   ; $585F  Bug x AnyDragon -> Bug
;  --- parent1 = $79 (Bug) ---
    DB $79,$F6,$00,$7F,$00   ; $5864  Bug x AnyDevil -> Bug
;  --- parent1 = $82 (Devil) ---
    DB $82,$F0,$00,$8A,$00   ; $5869  Devil x AnySlime -> Devil
;  --- parent1 = $85 (Devil) ---
    DB $85,$F0,$00,$8A,$00   ; $586E  Devil x AnySlime -> Devil
;  --- parent1 = $87 (Devil) ---
    DB $87,$F0,$00,$8A,$00   ; $5873  Devil x AnySlime -> Devil
;  --- parent1 = $86 (Devil) ---
    DB $86,$F7,$00,$8C,$00   ; $5878  Devil x AnyZomby -> Devil
;  --- parent1 = $8A (Devil) ---
    DB $8A,$F7,$00,$8C,$00   ; $587D  Devil x AnyZomby -> Devil
;  --- parent1 = $8B (Devil) ---
    DB $8B,$F7,$00,$8C,$00   ; $5882  Devil x AnyZomby -> Devil
;  --- parent1 = $88 (Devil) ---
    DB $88,$F1,$00,$84,$00   ; $5887  Devil x AnyDragon -> Devil
;  --- parent1 = $89 (Devil) ---
    DB $89,$F1,$00,$84,$00   ; $588C  Devil x AnyDragon -> Devil
;  --- parent1 = $8B (Devil) ---
    DB $8B,$F1,$00,$84,$00   ; $5891  Devil x AnyDragon -> Devil
;  --- parent1 = $8C (Devil) ---
    DB $8C,$F1,$00,$84,$00   ; $5896  Devil x AnyDragon -> Devil
;  --- parent1 = $88 (Devil) ---
    DB $88,$F2,$00,$93,$00   ; $589B  Devil x AnyBeast -> Devil
;  --- parent1 = $89 (Devil) ---
    DB $89,$F2,$00,$93,$00   ; $58A0  Devil x AnyBeast -> Devil
;  --- parent1 = $8B (Devil) ---
    DB $8B,$F2,$00,$93,$00   ; $58A5  Devil x AnyBeast -> Devil
;  --- parent1 = $8C (Devil) ---
    DB $8C,$F2,$00,$93,$00   ; $58AA  Devil x AnyBeast -> Devil
;  --- parent1 = $88 (Devil) ---
    DB $88,$F7,$00,$96,$00   ; $58AF  Devil x AnyZomby -> Devil
;  --- parent1 = $89 (Devil) ---
    DB $89,$F7,$00,$96,$00   ; $58B4  Devil x AnyZomby -> Devil
;  --- parent1 = $8B (Devil) ---
    DB $8B,$F7,$00,$96,$00   ; $58B9  Devil x AnyZomby -> Devil
;  --- parent1 = $8C (Devil) ---
    DB $8C,$F7,$00,$96,$00   ; $58BE  Devil x AnyZomby -> Devil
;  --- parent1 = $83 (Devil) ---
    DB $83,$F1,$00,$97,$00   ; $58C3  Devil x AnyDragon -> Devil
    DB $83,$F8,$00,$98,$00   ; $58C8  Devil x AnyMaterl -> Devil
    DB $83,$F7,$00,$8D,$00   ; $58CD  Devil x AnyZomby -> Devil
    DB $83,$F2,$00,$8E,$00   ; $58D2  Devil x AnyBeast -> Devil
;  --- parent1 = $91 (Devil) ---
    DB $91,$F1,$00,$90,$00   ; $58D7  Devil x AnyDragon -> Devil
    DB $91,$F8,$00,$98,$00   ; $58DC  Devil x AnyMaterl -> Devil
    DB $91,$F7,$00,$83,$00   ; $58E1  Devil x AnyZomby -> Devil
    DB $91,$F2,$00,$97,$00   ; $58E6  Devil x AnyBeast -> Devil
;  --- parent1 = $90 (Devil) ---
    DB $90,$F1,$00,$83,$00   ; $58EB  Devil x AnyDragon -> Devil
    DB $90,$F8,$00,$98,$00   ; $58F0  Devil x AnyMaterl -> Devil
    DB $90,$F2,$00,$97,$00   ; $58F5  Devil x AnyBeast -> Devil
    DB $90,$F7,$00,$91,$00   ; $58FA  Devil x AnyZomby -> Devil
;  --- parent1 = $9B (Zomby) ---
    DB $9B,$F2,$00,$A3,$00   ; $58FF  Zomby x AnyBeast -> Zomby
    DB $9B,$F6,$00,$A8,$00   ; $5904  Zomby x AnyDevil -> Zomby
;  --- parent1 = $A3 (Zomby) ---
    DB $A3,$F6,$00,$A8,$00   ; $5909  Zomby x AnyDevil -> Zomby
;  --- parent1 = $A0 (Zomby) ---
    DB $A0,$F6,$00,$A5,$00   ; $590E  Zomby x AnyDevil -> Zomby
;  --- parent1 = $A6 (Zomby) ---
    DB $A6,$F6,$00,$A5,$00   ; $5913  Zomby x AnyDevil -> Zomby
;  --- parent1 = $9C (Zomby) ---
    DB $9C,$F3,$00,$A6,$00   ; $5918  Zomby x AnyBird -> Zomby
;  --- parent1 = $A1 (Zomby) ---
    DB $A1,$F3,$00,$A6,$00   ; $591D  Zomby x AnyBird -> Zomby
;  --- parent1 = $A4 (Zomby) ---
    DB $A4,$F3,$00,$A6,$00   ; $5922  Zomby x AnyBird -> Zomby
;  --- parent1 = $A9 (Zomby) ---
    DB $A9,$F3,$00,$A6,$00   ; $5927  Zomby x AnyBird -> Zomby
;  --- parent1 = $AB (Zomby) ---
    DB $AB,$F3,$00,$A6,$00   ; $592C  Zomby x AnyBird -> Zomby
;  --- parent1 = $AC (Zomby) ---
    DB $AC,$F3,$00,$A6,$00   ; $5931  Zomby x AnyBird -> Zomby
;  --- parent1 = $9E (Zomby) ---
    DB $9E,$F3,$00,$A7,$00   ; $5936  Zomby x AnyBird -> Zomby
;  --- parent1 = $AA (Zomby) ---
    DB $AA,$F6,$00,$AD,$00   ; $593B  Zomby x AnyDevil -> Zomby
;  --- parent1 = $9C (Zomby) ---
    DB $9C,$F1,$00,$9C,$00   ; $5940  Zomby x AnyDragon -> Zomby
;  --- parent1 = $A9 (Zomby) ---
    DB $A9,$F1,$00,$9C,$00   ; $5945  Zomby x AnyDragon -> Zomby
;  --- parent1 = $AA (Zomby) ---
    DB $AA,$F1,$00,$9C,$00   ; $594A  Zomby x AnyDragon -> Zomby
;  --- parent1 = $AB (Zomby) ---
    DB $AB,$F1,$00,$9C,$00   ; $594F  Zomby x AnyDragon -> Zomby
;  --- parent1 = $AC (Zomby) ---
    DB $AC,$F1,$00,$9C,$00   ; $5954  Zomby x AnyDragon -> Zomby
;  --- parent1 = $A6 (Zomby) ---
    DB $A6,$F1,$00,$AC,$00   ; $5959  Zomby x AnyDragon -> Zomby
;  --- parent1 = $AF (Materl) ---
    DB $AF,$F0,$00,$B7,$00   ; $595E  Materl x AnySlime -> Materl
;  --- parent1 = $BD (Materl) ---
    DB $BD,$F1,$00,$B9,$00   ; $5963  Materl x AnyDragon -> Materl
;  --- parent1 = $BF (Materl) ---
    DB $BF,$F6,$00,$BE,$00   ; $5968  Materl x AnyDevil -> Materl
;  --- parent1 = $C0 (Materl) ---
    DB $C0,$F6,$00,$BA,$00   ; $596D  Materl x AnyDevil -> Materl
;  --- parent1 = $C1 (Materl) ---
    DB $C1,$F6,$00,$BA,$00   ; $5972  Materl x AnyDevil -> Materl
;  --- parent1 = $B9 (Materl) ---
    DB $B9,$F1,$00,$B9,$02   ; $5977  Materl x AnyDragon -> Materl (born +2)
;  --- parent1 = $BD (Materl) ---
    DB $BD,$F5,$00,$C6,$00   ; $597C  Materl x AnyBug -> Materl
    DB $BD,$F7,$00,$C2,$00   ; $5981  Materl x AnyZomby -> Materl
    DB $BD,$F3,$00,$BC,$00   ; $5986  Materl x AnyBird -> Materl
;  --- parent1 = $F0 (AnySlime) ---
    DB $F0,$30,$00,$09,$00   ; $598B  AnySlime x Beast -> Slime
    DB $F0,$58,$00,$09,$00   ; $5990  AnySlime x Bird -> Slime
    DB $F0,$AE,$00,$09,$00   ; $5995  AnySlime x Zomby -> Slime
    DB $F0,$1A,$00,$06,$00   ; $599A  AnySlime x Dragon -> Slime
    DB $F0,$7B,$00,$06,$00   ; $599F  AnySlime x Bug -> Slime
    DB $F0,$F9,$00,$0F,$02   ; $59A4  AnySlime x Any??? -> Slime (born +2)
    DB $F0,$A1,$00,$0B,$00   ; $59A9  AnySlime x Zomby -> Slime
    DB $F0,$C4,$00,$0B,$00   ; $59AE  AnySlime x Materl -> Slime
    DB $F0,$C5,$00,$0B,$00   ; $59B3  AnySlime x Materl -> Slime
    DB $F0,$32,$00,$0A,$00   ; $59B8  AnySlime x Beast -> Slime
    DB $F0,$41,$00,$0A,$00   ; $59BD  AnySlime x Beast -> Slime
    DB $F0,$42,$00,$0A,$00   ; $59C2  AnySlime x Beast -> Slime
    DB $F0,$43,$00,$0A,$00   ; $59C7  AnySlime x Beast -> Slime
    DB $F0,$44,$00,$0A,$00   ; $59CC  AnySlime x Beast -> Slime
    DB $F0,$B9,$00,$10,$00   ; $59D1  AnySlime x Materl -> Slime
    DB $F0,$81,$00,$0B,$00   ; $59D6  AnySlime x Bug -> Slime
;  --- parent1 = $F1 (AnyDragon) ---
    DB $F1,$F9,$00,$29,$00   ; $59DB  AnyDragon x Any??? -> Dragon
    DB $F1,$0E,$00,$25,$00   ; $59E0  AnyDragon x Slime -> Dragon
    DB $F1,$0F,$00,$25,$00   ; $59E5  AnyDragon x Slime -> Dragon
    DB $F1,$12,$00,$25,$00   ; $59EA  AnyDragon x Slime -> Dragon
    DB $F1,$2A,$00,$25,$00   ; $59EF  AnyDragon x Dragon -> Dragon
    DB $F1,$3E,$00,$25,$00   ; $59F4  AnyDragon x Beast -> Dragon
    DB $F1,$56,$00,$25,$00   ; $59F9  AnyDragon x Bird -> Dragon
    DB $F1,$57,$00,$25,$00   ; $59FE  AnyDragon x Bird -> Dragon
    DB $F1,$96,$00,$25,$00   ; $5A03  AnyDragon x Devil -> Dragon
    DB $F1,$97,$00,$25,$00   ; $5A08  AnyDragon x Devil -> Dragon
    DB $F1,$42,$00,$2A,$00   ; $5A0D  AnyDragon x Beast -> Dragon
    DB $F1,$90,$00,$2A,$00   ; $5A12  AnyDragon x Devil -> Dragon
    DB $F1,$95,$00,$2A,$00   ; $5A17  AnyDragon x Devil -> Dragon
    DB $F1,$98,$00,$2A,$00   ; $5A1C  AnyDragon x Devil -> Dragon
    DB $F1,$9C,$00,$9C,$00   ; $5A21  AnyDragon x Zomby -> Zomby
    DB $F1,$A9,$00,$9C,$00   ; $5A26  AnyDragon x Zomby -> Zomby
    DB $F1,$AA,$00,$9C,$00   ; $5A2B  AnyDragon x Zomby -> Zomby
    DB $F1,$AD,$00,$9C,$00   ; $5A30  AnyDragon x Zomby -> Zomby
    DB $F1,$81,$00,$24,$00   ; $5A35  AnyDragon x Bug -> Dragon
;  --- parent1 = $F2 (AnyBeast) ---
    DB $F2,$19,$00,$3F,$00   ; $5A3A  AnyBeast x Dragon -> Beast
    DB $F2,$B9,$00,$3A,$00   ; $5A3F  AnyBeast x Materl -> Beast
    DB $F2,$BD,$00,$3A,$00   ; $5A44  AnyBeast x Materl -> Beast
    DB $F2,$C0,$00,$3A,$00   ; $5A49  AnyBeast x Materl -> Beast
    DB $F2,$C1,$00,$3A,$00   ; $5A4E  AnyBeast x Materl -> Beast
    DB $F2,$C4,$00,$3A,$00   ; $5A53  AnyBeast x Materl -> Beast
    DB $F2,$C5,$00,$3A,$00   ; $5A58  AnyBeast x Materl -> Beast
;  --- parent1 = $F3 (AnyBird) ---
    DB $F3,$00,$00,$55,$00   ; $5A5D  AnyBird x Slime -> Bird
    DB $F3,$32,$00,$55,$00   ; $5A62  AnyBird x Beast -> Bird
    DB $F3,$37,$00,$55,$00   ; $5A67  AnyBird x Beast -> Bird
    DB $F3,$3A,$00,$55,$00   ; $5A6C  AnyBird x Beast -> Bird
    DB $F3,$83,$00,$55,$00   ; $5A71  AnyBird x Devil -> Bird
    DB $F3,$AE,$00,$55,$00   ; $5A76  AnyBird x Zomby -> Bird
    DB $F3,$C0,$00,$55,$00   ; $5A7B  AnyBird x Materl -> Bird
    DB $F3,$10,$00,$54,$00   ; $5A80  AnyBird x Slime -> Bird
    DB $F3,$11,$00,$54,$00   ; $5A85  AnyBird x Slime -> Bird
    DB $F3,$36,$00,$54,$00   ; $5A8A  AnyBird x Beast -> Bird
    DB $F3,$3B,$00,$54,$00   ; $5A8F  AnyBird x Beast -> Bird
    DB $F3,$3F,$00,$54,$00   ; $5A94  AnyBird x Beast -> Bird
    DB $F3,$41,$00,$54,$00   ; $5A99  AnyBird x Beast -> Bird
    DB $F3,$9C,$00,$54,$00   ; $5A9E  AnyBird x Zomby -> Bird
    DB $F3,$A9,$00,$54,$00   ; $5AA3  AnyBird x Zomby -> Bird
    DB $F3,$AA,$00,$54,$00   ; $5AA8  AnyBird x Zomby -> Bird
    DB $F3,$AC,$00,$54,$00   ; $5AAD  AnyBird x Zomby -> Bird
    DB $F3,$AD,$00,$54,$00   ; $5AB2  AnyBird x Zomby -> Bird
;  --- parent1 = $F4 (AnyPlant) ---
    DB $F4,$0B,$00,$69,$00   ; $5AB7  AnyPlant x Slime -> Plant
    DB $F4,$45,$00,$69,$00   ; $5ABC  AnyPlant x Beast -> Plant
    DB $F4,$4A,$00,$69,$00   ; $5AC1  AnyPlant x Bird -> Plant
    DB $F4,$71,$00,$69,$00   ; $5AC6  AnyPlant x Bug -> Plant
    DB $F4,$7A,$00,$69,$00   ; $5ACB  AnyPlant x Bug -> Plant
    DB $F4,$87,$00,$69,$00   ; $5AD0  AnyPlant x Devil -> Plant
    DB $F4,$B5,$00,$69,$00   ; $5AD5  AnyPlant x Materl -> Plant
;  --- parent1 = $F7 (AnyZomby) ---
    DB $F7,$1B,$00,$9C,$00   ; $5ADA  AnyZomby x Dragon -> Zomby
    DB $F7,$1B,$00,$9C,$00   ; $5ADF  AnyZomby x Dragon -> Zomby
    DB $F7,$1F,$00,$9C,$00   ; $5AE4  AnyZomby x Dragon -> Zomby
    DB $F7,$22,$00,$9C,$00   ; $5AE9  AnyZomby x Dragon -> Zomby
    DB $F7,$25,$00,$9C,$00   ; $5AEE  AnyZomby x Dragon -> Zomby
    DB $F7,$29,$00,$9C,$00   ; $5AF3  AnyZomby x Dragon -> Zomby
    DB $F7,$2A,$00,$9C,$00   ; $5AF8  AnyZomby x Dragon -> Zomby
    DB $F7,$2C,$00,$9C,$00   ; $5AFD  AnyZomby x Dragon -> Zomby
    DB $F7,$07,$00,$A4,$00   ; $5B02  AnyZomby x Slime -> Zomby
    DB $F7,$0A,$00,$A4,$00   ; $5B07  AnyZomby x Slime -> Zomby
    DB $F7,$2D,$00,$A4,$00   ; $5B0C  AnyZomby x Beast -> Zomby
    DB $F7,$3B,$00,$A4,$00   ; $5B11  AnyZomby x Beast -> Zomby
    DB $F7,$58,$00,$A4,$00   ; $5B16  AnyZomby x Bird -> Zomby
    DB $F7,$5A,$00,$A4,$00   ; $5B1B  AnyZomby x Plant -> Zomby
    DB $F7,$64,$00,$A4,$00   ; $5B20  AnyZomby x Plant -> Zomby
    DB $F7,$74,$00,$A4,$00   ; $5B25  AnyZomby x Bug -> Zomby
    DB $F7,$7C,$00,$A4,$00   ; $5B2A  AnyZomby x Bug -> Zomby
;  --- parent1 = $F8 (AnyMaterl) ---
    DB $F8,$32,$00,$BD,$00   ; $5B2F  AnyMaterl x Beast -> Materl
    DB $F8,$3A,$00,$BD,$00   ; $5B34  AnyMaterl x Beast -> Materl
    DB $F8,$41,$00,$BD,$00   ; $5B39  AnyMaterl x Beast -> Materl
    DB $F8,$42,$00,$BD,$00   ; $5B3E  AnyMaterl x Beast -> Materl
    DB $F8,$7F,$00,$C5,$00   ; $5B43  AnyMaterl x Bug -> Materl
    DB $F8,$81,$00,$C5,$00   ; $5B48  AnyMaterl x Bug -> Materl

; ============================================================================
; FUNCTION-TABLE ENTRIES fn1/fn2/fn4/fn5/fn6/fn7  (recursive-descent disasm)
; ----------------------------------------------------------------------------
; The 10-entry table @$4001 is fn0..fn9 (all in-bank). fn0/fn3/fn8/fn9 are
; disassembled above; the six below were previously undisassembled. Decoded by
; following control flow from each entry (tools/sm83rec.py), so bytes reached
; as code are instructions and any interspersed data shows as db. Each range is
; byte-exact vs terry.gbc. Note fn6 sits among data tables ($6056 catTable,
; $6744/$6800 remap); the decode stops at the code boundary, not into them.
; ============================================================================

; ------------------------------------------------------------
; Bank22_Fn1  ($485C)  — fn1 — word-table lookup at $4974 indexed by $DA6F (monster id) -> $DA71/$DA72.
; ------------------------------------------------------------
Bank22_Fn1:                                 ; $485C
    LD A,($DA6F)               ; $485C  [FA 6F DA]
    LD L,A                     ; $485F  [6F]
    LD H,$00                   ; $4860  [26 00]
    ADD HL,HL                  ; $4862  [29]
    LD A,L                     ; $4863  [7D]
    ADD A,$74                  ; $4864  [C6 74]
    LD L,A                     ; $4866  [6F]
    LD A,H                     ; $4867  [7C]
    ADC A,$49                  ; $4868  [CE 49]
    LD H,A                     ; $486A  [67]
    LD A,(HL+)                 ; $486B  [2A]
    LD ($DA71),A               ; $486C  [EA 71 DA]
    LD A,(HL)                  ; $486F  [7E]
    LD ($DA72),A               ; $4870  [EA 72 DA]
    RET                        ; $4873  [C9]

; ------------------------------------------------------------
; Bank22_Fn2  ($456E)  — fn2 — monster stat setup helper (called by fn0): seed $DA71-$DA77=$FF, then
;        resolve via $4653/$45D5/$44D0; default $DA71 from $DA6F.
; ------------------------------------------------------------
Bank22_Fn2:                                 ; $456E
    LD A,$FF                   ; $456E  [3E FF]
    LD ($DA71),A               ; $4570  [EA 71 DA]
    LD A,$FF                   ; $4573  [3E FF]
    LD ($DA72),A               ; $4575  [EA 72 DA]
    LD A,$FF                   ; $4578  [3E FF]
    LD ($DA73),A               ; $457A  [EA 73 DA]
    LD A,$FF                   ; $457D  [3E FF]
    LD ($DA74),A               ; $457F  [EA 74 DA]
    LD A,$FF                   ; $4582  [3E FF]
    LD ($DA77),A               ; $4584  [EA 77 DA]
    CALL $4653                 ; $4587  [CD 53 46]
    LD A,($DA71)               ; $458A  [FA 71 DA]
    CP $FF                     ; $458D  [FE FF]
    RET NZ                     ; $458F  [C0]
    CALL $45D5                 ; $4590  [CD D5 45]
    CALL $44D0                 ; $4593  [CD D0 44]
    LD A,($DA71)               ; $4596  [FA 71 DA]
    CP $FF                     ; $4599  [FE FF]
    RET NZ                     ; $459B  [C0]
    LD A,($DA6F)               ; $459C  [FA 6F DA]
    LD ($DA71),A               ; $459F  [EA 71 DA]
    RET                        ; $45A2  [C9]

; ------------------------------------------------------------
; Bank22_Fn4  ($474A)  — fn4 — monster-record field init/copy ($CB21 clear; copy $CACD->$CA42 x8, ...).
; ------------------------------------------------------------
Bank22_Fn4:                                 ; $474A
    LD HL,$CB21                ; $474A  [21 21 CB]
    CALL $47E0                 ; $474D  [CD E0 47]
    XOR A                      ; $4750  [AF]
    LD (HL+),A                 ; $4751  [22]
    LD (HL),A                  ; $4752  [77]
    LD HL,$CACD                ; $4753  [21 CD CA]
    LD DE,$CA42                ; $4756  [11 42 CA]
    LD B,$08                   ; $4759  [06 08]
    CALL $47E7                 ; $475B  [CD E7 47]
    LD HL,$CAD5                ; $475E  [21 D5 CA]
    CALL $47E0                 ; $4761  [CD E0 47]
    LD A,($CA4A)               ; $4764  [FA 4A CA]
    LD (HL),A                  ; $4767  [77]
    LD HL,$C0D8                ; $4768  [21 D8 C0]
    LD BC,$0019                ; $476B  [01 19 00]
    LD A,$FF                   ; $476E  [3E FF]
    CALL $169A                 ; $4770  [CD 9A 16]
    LD HL,$CACA                ; $4773  [21 CA CA]
    CALL $47E0                 ; $4776  [CD E0 47]
    LD A,(HL)                  ; $4779  [7E]
    LD ($DA31),A               ; $477A  [EA 31 DA]
    LD HL,$0301                ; $477D  [21 01 03]
    RST $10                    ; $4780  [D7]
    LD DE,$DA39                ; $4781  [11 39 DA]
    LD B,$03                   ; $4784  [06 03]
    CALL $47F8                 ; $4786  [CD F8 47]
    LD HL,$CAD6                ; $4789  [21 D6 CA]
    CALL $47E0                 ; $478C  [CD E0 47]
    LD A,(HL)                  ; $478F  [7E]
    CP $FF                     ; $4790  [FE FF]
    JR Z,$47B9                 ; $4792  [28 25]
    LD ($DA31),A               ; $4794  [EA 31 DA]
    LD HL,$0301                ; $4797  [21 01 03]
    RST $10                    ; $479A  [D7]
    LD DE,$DA39                ; $479B  [11 39 DA]
    LD B,$03                   ; $479E  [06 03]
    CALL $47F8                 ; $47A0  [CD F8 47]
    LD HL,$CAD7                ; $47A3  [21 D7 CA]
    CALL $47E0                 ; $47A6  [CD E0 47]
    LD A,(HL)                  ; $47A9  [7E]
    LD ($DA31),A               ; $47AA  [EA 31 DA]
    LD HL,$0301                ; $47AD  [21 01 03]
    RST $10                    ; $47B0  [D7]
    LD DE,$DA39                ; $47B1  [11 39 DA]
    LD B,$03                   ; $47B4  [06 03]
    CALL $47F8                 ; $47B6  [CD F8 47]
    LD HL,$CAF2                ; $47B9  [21 F2 CA]
    CALL $47E0                 ; $47BC  [CD E0 47]
    LD E,L                     ; $47BF  [5D]
    LD D,H                     ; $47C0  [54]
    LD B,$19                   ; $47C1  [06 19]
    CALL $4805                 ; $47C3  [CD 05 48]
    LD HL,$CAF2                ; $47C6  [21 F2 CA]
    CALL $47E0                 ; $47C9  [CD E0 47]
    LD DE,$C0D8                ; $47CC  [11 D8 C0]
    LD B,$19                   ; $47CF  [06 19]
    LD A,(DE)                  ; $47D1  [1A]
    LD (HL+),A                 ; $47D2  [22]
    INC DE                     ; $47D3  [13]
    DEC B                      ; $47D4  [05]
    JR NZ,$47D1                ; $47D5  [20 FA]
    LD HL,$CB24                ; $47D7  [21 24 CB]
    CALL $47E0                 ; $47DA  [CD E0 47]
    LD (HL),$00                ; $47DD  [36 00]
    RET                        ; $47DF  [C9]

; ------------------------------------------------------------
; Bank22_Fn5  ($5B4E)  — fn5 — sub-area update, gated by $C969 (sub-area) and $C8EA bit7; bumps $C939.
; ------------------------------------------------------------
Bank22_Fn5:                                 ; $5B4E
    LD A,($C969)               ; $5B4E  [FA 69 C9]
    OR A                       ; $5B51  [B7]
    RET Z                      ; $5B52  [C8]
    LD A,($C8EA)               ; $5B53  [FA EA C8]
    BIT 7,A                    ; $5B56  [CB 7F]
    RET NZ                     ; $5B58  [C0]
    LD HL,$C939                ; $5B59  [21 39 C9]
    INC (HL)                   ; $5B5C  [34]
    XOR A                      ; $5B5D  [AF]
    LD ($C93E),A               ; $5B5E  [EA 3E C9]
    LD A,($C969)               ; $5B61  [FA 69 C9]
    BIT 7,A                    ; $5B64  [CB 7F]
    JR NZ,$5B72                ; $5B66  [20 0A]
    LD A,($C968)               ; $5B68  [FA 68 C9]
    LD ($C935),A               ; $5B6B  [EA 35 C9]
    XOR A                      ; $5B6E  [AF]
    LD ($C939),A               ; $5B6F  [EA 39 C9]
    LD HL,$010C                ; $5B72  [21 0C 01]
    RST $10                    ; $5B75  [D7]
    LD A,($C935)               ; $5B76  [FA 35 C9]
    ADD A,A                    ; $5B79  [87]
    ADD A,A                    ; $5B7A  [87]
    ADD A,A                    ; $5B7B  [87]
    LD HL,$70A6                ; $5B7C  [21 A6 70]
    ADD A,L                    ; $5B7F  [85]
    LD L,A                     ; $5B80  [6F]
    LD A,$00                   ; $5B81  [3E 00]
    ADC A,H                    ; $5B83  [8C]
    LD H,A                     ; $5B84  [67]
    LD A,(HL+)                 ; $5B85  [2A]
    LD ($C936),A               ; $5B86  [EA 36 C9]
    LD A,(HL+)                 ; $5B89  [2A]
    LD ($C937),A               ; $5B8A  [EA 37 C9]
    LD A,(HL+)                 ; $5B8D  [2A]
    LD ($C938),A               ; $5B8E  [EA 38 C9]
    PUSH HL                    ; $5B91  [E5]
    LD A,(HL+)                 ; $5B92  [2A]
    LD ($C93A),A               ; $5B93  [EA 3A C9]
    LD A,(HL+)                 ; $5B96  [2A]
    LD ($C93B),A               ; $5B97  [EA 3B C9]
    INC HL                     ; $5B9A  [23]
    INC HL                     ; $5B9B  [23]
    LD A,(HL)                  ; $5B9C  [7E]
    LD ($C93C),A               ; $5B9D  [EA 3C C9]
    POP HL                     ; $5BA0  [E1]
    LD A,($C939)               ; $5BA1  [FA 39 C9]
    LD B,A                     ; $5BA4  [47]
    INC A                      ; $5BA5  [3C]
    CP (HL)                    ; $5BA6  [BE]
    JR Z,$5BE1                 ; $5BA7  [28 38]
    LD A,($C935)               ; $5BA9  [FA 35 C9]
    OR A                       ; $5BAC  [B7]
    JR Z,$5BBF                 ; $5BAD  [28 10]
    LD A,($C899)               ; $5BAF  [FA 99 C8]
    BIT 4,A                    ; $5BB2  [CB 67]
    JR Z,$5BBF                 ; $5BB4  [28 09]
    LD A,$03                   ; $5BB6  [3E 03]
    CALL $21CA                 ; $5BB8  [CD CA 21]
    CP $02                     ; $5BBB  [FE 02]
    JR Z,$5C1C                 ; $5BBD  [28 5D]
    LD A,($C936)               ; $5BBF  [FA 36 C9]
    ADD A,A                    ; $5BC2  [87]
    ADD A,A                    ; $5BC3  [87]
    ADD A,A                    ; $5BC4  [87]
    ADD A,A                    ; $5BC5  [87]
    LD HL,$71A6                ; $5BC6  [21 A6 71]
    ADD A,L                    ; $5BC9  [85]
    LD L,A                     ; $5BCA  [6F]
    LD A,$00                   ; $5BCB  [3E 00]
    ADC A,H                    ; $5BCD  [8C]
    LD H,A                     ; $5BCE  [67]
    CALL $5FC0                 ; $5BCF  [CD C0 5F]
    LD ($C936),A               ; $5BD2  [EA 36 C9]
    LD A,($C936)               ; $5BD5  [FA 36 C9]
    LD ($C968),A               ; $5BD8  [EA 68 C9]
    LD A,$01                   ; $5BDB  [3E 01]
    LD ($C969),A               ; $5BDD  [EA 69 C9]
    RET                        ; $5BE0  [C9]
    LD A,($C935)               ; $5BE1  [FA 35 C9]
    ADD A,A                    ; $5BE4  [87]
    ADD A,A                    ; $5BE5  [87]
    ADD A,A                    ; $5BE6  [87]
    LD HL,$70AA                ; $5BE7  [21 AA 70]
    ADD A,L                    ; $5BEA  [85]
    LD L,A                     ; $5BEB  [6F]
    LD A,$00                   ; $5BEC  [3E 00]
    ADC A,H                    ; $5BEE  [8C]
    LD H,A                     ; $5BEF  [67]
    LD A,(HL+)                 ; $5BF0  [2A]
    LD ($C968),A               ; $5BF1  [EA 68 C9]
    LD A,$00                   ; $5BF4  [3E 00]
    LD ($C969),A               ; $5BF6  [EA 69 C9]
    LD A,(HL+)                 ; $5BF9  [2A]
    SWAP A                     ; $5BFA  [CB 37]
    LD B,A                     ; $5BFC  [47]
    AND $F0                    ; $5BFD  [E6 F0]
    OR $08                     ; $5BFF  [F6 08]
    LD ($C96F),A               ; $5C01  [EA 6F C9]
    LD A,B                     ; $5C04  [78]
    AND $0F                    ; $5C05  [E6 0F]
    LD ($C970),A               ; $5C07  [EA 70 C9]
    LD A,(HL+)                 ; $5C0A  [2A]
    SWAP A                     ; $5C0B  [CB 37]
    LD B,A                     ; $5C0D  [47]
    AND $F0                    ; $5C0E  [E6 F0]
    OR $08                     ; $5C10  [F6 08]
    LD ($C971),A               ; $5C12  [EA 71 C9]
    LD A,B                     ; $5C15  [78]
    AND $0F                    ; $5C16  [E6 0F]
    LD ($C972),A               ; $5C18  [EA 72 C9]
    RET                        ; $5C1B  [C9]
    LD A,($C937)               ; $5C1C  [FA 37 C9]
    ADD A,A                    ; $5C1F  [87]
    ADD A,A                    ; $5C20  [87]
    ADD A,A                    ; $5C21  [87]
    LD HL,$72A6                ; $5C22  [21 A6 72]
    ADD A,L                    ; $5C25  [85]
    LD L,A                     ; $5C26  [6F]
    LD A,$00                   ; $5C27  [3E 00]
    ADC A,H                    ; $5C29  [8C]
    LD H,A                     ; $5C2A  [67]
    CALL $5FC0                 ; $5C2B  [CD C0 5F]
    LD ($C937),A               ; $5C2E  [EA 37 C9]
    RST $00                    ; $5C31  [C7]
    LD B,D                     ; $5C32  [42]
    LD E,H                     ; $5C33  [5C]
    CP C                       ; $5C34  [B9]
    LD E,H                     ; $5C35  [5C]
    BIT 3,H                    ; $5C36  [CB 5C]
    db $EC                     ; $5C38  [EC]
    LD E,H                     ; $5C39  [5C]
    DEC C                      ; $5C3A  [0D]
    LD E,L                     ; $5C3B  [5D]
    LD L,$5D                   ; $5C3C  [2E 5D]
    RET C                      ; $5C3E  [D8]
    LD E,(HL)                  ; $5C3F  [5E]
    LD C,H                     ; $5C40  [4C]
    LD E,A                     ; $5C41  [5F]
    CALL $6DB0                 ; $5C42  [CD B0 6D]
    LD A,($C899)               ; $5C45  [FA 99 C8]
    LD B,A                     ; $5C48  [47]
    LD A,$03                   ; $5C49  [3E 03]
    CALL $21CA                 ; $5C4B  [CD CA 21]
    CP $01                     ; $5C4E  [FE 01]
    JR Z,$5C77                 ; $5C50  [28 25]
    CP $02                     ; $5C52  [FE 02]
    JR Z,$5C98                 ; $5C54  [28 42]
    LD A,$5A                   ; $5C56  [3E 5A]
    LD ($C968),A               ; $5C58  [EA 68 C9]
    LD A,$00                   ; $5C5B  [3E 00]
    LD ($C969),A               ; $5C5D  [EA 69 C9]
    LD HL,$0048                ; $5C60  [21 48 00]
    LD A,L                     ; $5C63  [7D]
    LD ($C96F),A               ; $5C64  [EA 6F C9]
    LD A,H                     ; $5C67  [7C]
    LD ($C970),A               ; $5C68  [EA 70 C9]
    LD HL,$0048                ; $5C6B  [21 48 00]
    LD A,L                     ; $5C6E  [7D]
    LD ($C971),A               ; $5C6F  [EA 71 C9]
    LD A,H                     ; $5C72  [7C]
    LD ($C972),A               ; $5C73  [EA 72 C9]
    RET                        ; $5C76  [C9]
    LD A,$5B                   ; $5C77  [3E 5B]
    LD ($C968),A               ; $5C79  [EA 68 C9]
    LD A,$00                   ; $5C7C  [3E 00]
    LD ($C969),A               ; $5C7E  [EA 69 C9]
    LD HL,$0048                ; $5C81  [21 48 00]
    LD A,L                     ; $5C84  [7D]
    LD ($C96F),A               ; $5C85  [EA 6F C9]
    LD A,H                     ; $5C88  [7C]
    LD ($C970),A               ; $5C89  [EA 70 C9]
    LD HL,$0048                ; $5C8C  [21 48 00]
    LD A,L                     ; $5C8F  [7D]
    LD ($C971),A               ; $5C90  [EA 71 C9]
    LD A,H                     ; $5C93  [7C]
    LD ($C972),A               ; $5C94  [EA 72 C9]
    RET                        ; $5C97  [C9]
    LD A,$5C                   ; $5C98  [3E 5C]
    LD ($C968),A               ; $5C9A  [EA 68 C9]
    LD A,$00                   ; $5C9D  [3E 00]
    LD ($C969),A               ; $5C9F  [EA 69 C9]
    LD HL,$0068                ; $5CA2  [21 68 00]
    LD A,L                     ; $5CA5  [7D]
    LD ($C96F),A               ; $5CA6  [EA 6F C9]
    LD A,H                     ; $5CA9  [7C]
    LD ($C970),A               ; $5CAA  [EA 70 C9]
    LD HL,$0048                ; $5CAD  [21 48 00]
    LD A,L                     ; $5CB0  [7D]
    LD ($C971),A               ; $5CB1  [EA 71 C9]
    LD A,H                     ; $5CB4  [7C]
    LD ($C972),A               ; $5CB5  [EA 72 C9]
    RET                        ; $5CB8  [C9]

; ------------------------------------------------------------
; Bank22_Fn6  ($5FE4)  — BUILD the world's 4x4 ROOM-LAYOUT GRID + scroll/warp setup
; ------------------------------------------------------------
; Called by bank11/fn0 ($4083) at area load. Fills wRoomGrid $C940 (16 bytes = a
; 4x4 grid of room-layout ids, indexed by wScrollCount $C925 = row*4+col; each id
; -> bank23 $5215 -> {block, bank61}), then computes the current room's scroll
; bounds and neighbour/warp records.
;
;   $5FE4        CALL $6E14 (prep).
;   $5FE7-$6001  MAIN-AREA case ($C969==0): no world grid -> $C926=$FF, zero
;                $C92B-$C92E, RET. (Only gate "worlds"/sub-areas have a grid.)
;   $6002-$6049  SUB-AREA: load 8 world/gate tile blocks $2E15-$2E1C -> VRAM
;                $8500-$86C0 (SafeTileLoad $194A).
;   $604A-$6055  if $C8EA bit7 (re-entry guard): clear $C8EC, RET.
;   $6056        catTable  db 00,00,00,01,02   (world CATEGORY = worldid % 5).
;   $605B  ==>   GRID-BUILD ENTRY (also the JP Z,$605B retry target below):
;                category = catTable[$C899 % 5] -> $C93F; clear $C950..+16,
;                fill $C940..+16 with $FF.
;   $6089        DISPATCH on category:
;                * cat 2: copy 16 bytes RAW from $7736+(worldid%21)*16 -> $C940,
;                  then JP $616C.
;                * cat 0/1 ($60B9): build $C940 from the $7096 template with a
;                  per-room remap (lookup $6744 + apply $6800); final pass ($6145)
;                  SWAP-nibbles each entry and adds a per-world tile offset
;                  (cat 1 = +$0C; else $C899 % 12).
;   $616C  ==>   ROOM SCROLL/WARP SETUP (retry-guarded by the $C0A9 countdown;
;                calls $66AE/$6AFB/$6585/$661B/$68C6 to settle scroll bounds):
;                $C925->$C960, snapshot scroll shadow $FFA5-A8; compute screen pos
;                $C962/3 + camera $C964-C967 from ROM0 per-zone base $3176; load
;                this room's neighbour/warp record ($C927-C92A, later $C96F-C972)
;                from $3176[$C925]; set scroll-mode flags $C92B-C92E from category
;                + world descriptor $C938 vs $C899 ($7886 threshold table); build a
;                warp list at $D793 (via $6432) from $732F[$C938].
;   $63AE        RET.
;
; Key data: catTable $6056 · cat-0/1 template $7096 (+remap $6744/$6800) · cat-2
; raw grids $7736 · per-zone base coords ROM0 $3176 · world thresholds $7886 ·
; warp-list source $732F. worldid = $C899; ROM0 $21CA = 8-bit divide (B/A -> A=rem).
; See the file header and the world-map memory notes.
; ------------------------------------------------------------
Bank22_Fn6:                                 ; $5FE4
    CALL $6E14                 ; $5FE4  [CD 14 6E]
    LD A,($C969)               ; $5FE7  [FA 69 C9]
    OR A                       ; $5FEA  [B7]
    JR NZ,$6002                ; $5FEB  [20 15]
    LD A,$FF                   ; $5FED  [3E FF]
    LD ($C926),A               ; $5FEF  [EA 26 C9]
    XOR A                      ; $5FF2  [AF]
    LD ($C92B),A               ; $5FF3  [EA 2B C9]
    LD ($C92C),A               ; $5FF6  [EA 2C C9]
    XOR A                      ; $5FF9  [AF]
    LD ($C92D),A               ; $5FFA  [EA 2D C9]
    XOR A                      ; $5FFD  [AF]
    LD ($C92E),A               ; $5FFE  [EA 2E C9]
    RET                        ; $6001  [C9]
    LD DE,$2E15                ; $6002  [11 15 2E]
    LD HL,$8500                ; $6005  [21 00 85]
    CALL $194A                 ; $6008  [CD 4A 19]
    LD DE,$2E16                ; $600B  [11 16 2E]
    LD HL,$8540                ; $600E  [21 40 85]
    CALL $194A                 ; $6011  [CD 4A 19]
    LD DE,$2E17                ; $6014  [11 17 2E]
    LD HL,$8580                ; $6017  [21 80 85]
    CALL $194A                 ; $601A  [CD 4A 19]
    LD DE,$2E18                ; $601D  [11 18 2E]
    LD HL,$85C0                ; $6020  [21 C0 85]
    CALL $194A                 ; $6023  [CD 4A 19]
    LD DE,$2E19                ; $6026  [11 19 2E]
    LD HL,$8600                ; $6029  [21 00 86]
    CALL $194A                 ; $602C  [CD 4A 19]
    LD DE,$2E1A                ; $602F  [11 1A 2E]
    LD HL,$8640                ; $6032  [21 40 86]
    CALL $194A                 ; $6035  [CD 4A 19]
    LD DE,$2E1B                ; $6038  [11 1B 2E]
    LD HL,$8680                ; $603B  [21 80 86]
    CALL $194A                 ; $603E  [CD 4A 19]
    LD DE,$2E1C                ; $6041  [11 1C 2E]
    LD HL,$86C0                ; $6044  [21 C0 86]
    CALL $194A                 ; $6047  [CD 4A 19]
    LD A,($C8EA)               ; $604A  [FA EA C8]
    BIT 7,A                    ; $604D  [CB 7F]
    JR Z,$605B                 ; $604F  [28 0A]
    XOR A                      ; $6051  [AF]
    LD ($C8EC),A               ; $6052  [EA EC C8]
    RET                        ; $6055  [C9]
    db $00,$00,$00,$01,$02     ; $6056  (data)  catTable: world category = worldid % 5
; --- GRID-BUILD ENTRY / retry target ($605B): category -> $C93F, init $C940/$C950 ---
    CALL $16A3                 ; $605B  [CD A3 16]
    LD A,($C899)               ; $605E  [FA 99 C8]
    LD B,A                     ; $6061  [47]
    LD A,$05                   ; $6062  [3E 05]
    CALL $21CA                 ; $6064  [CD CA 21]
    LD HL,$6056                ; $6067  [21 56 60]
    ADD A,L                    ; $606A  [85]
    LD L,A                     ; $606B  [6F]
    LD A,$00                   ; $606C  [3E 00]
    ADC A,H                    ; $606E  [8C]
    LD H,A                     ; $606F  [67]
    LD A,(HL)                  ; $6070  [7E]
    LD ($C93F),A               ; $6071  [EA 3F C9]
    LD HL,$C950                ; $6074  [21 50 C9]
    LD BC,$0010                ; $6077  [01 10 00]
    XOR A                      ; $607A  [AF]
    CALL $169A                 ; $607B  [CD 9A 16]
    LD HL,$C940                ; $607E  [21 40 C9]
    LD BC,$0010                ; $6081  [01 10 00]
    LD A,$FF                   ; $6084  [3E FF]
    CALL $169A                 ; $6086  [CD 9A 16]
; --- DISPATCH on category ($6089): cat 2 = raw-copy, cat 0/1 = template+remap ---
    LD A,($C93F)               ; $6089  [FA 3F C9]
    CP $02                     ; $608C  [FE 02]
    JR NZ,$60B9                ; $608E  [20 29]  ; cat != 2 -> template build at $60B9
    CALL $16A3                 ; $6090  [CD A3 16]
    LD A,($C899)               ; $6093  [FA 99 C8]
    LD B,A                     ; $6096  [47]
    LD A,$15                   ; $6097  [3E 15]
    CALL $21CA                 ; $6099  [CD CA 21]
    LD L,A                     ; $609C  [6F]
    LD H,$00                   ; $609D  [26 00]
    ADD HL,HL                  ; $609F  [29]
    ADD HL,HL                  ; $60A0  [29]
    ADD HL,HL                  ; $60A1  [29]
    ADD HL,HL                  ; $60A2  [29]
    LD A,L                     ; $60A3  [7D]
    ADD A,$36                  ; $60A4  [C6 36]
    LD L,A                     ; $60A6  [6F]
    LD A,H                     ; $60A7  [7C]
    ADC A,$77                  ; $60A8  [CE 77]
    LD H,A                     ; $60AA  [67]
    LD DE,$C940                ; $60AB  [11 40 C9]
    LD B,$10                   ; $60AE  [06 10]
    LD A,(HL+)                 ; $60B0  [2A]
    LD (DE),A                  ; $60B1  [12]
    INC DE                     ; $60B2  [13]
    DEC B                      ; $60B3  [05]
    JR NZ,$60B0                ; $60B4  [20 FA]
    JP $616C                   ; $60B6  [C3 6C 61]  ; cat 2 done -> scroll/warp setup
; --- cat 0/1: build $C940 from $7096 template with per-room remap ($6744/$6800) ---
    LD HL,$7096                ; $60B9  [21 96 70]
    LD A,($C93D)               ; $60BC  [FA 3D C9]
    INC A                      ; $60BF  [3C]
    LD B,A                     ; $60C0  [47]
    PUSH HL                    ; $60C1  [E5]
    LD A,(HL)                  ; $60C2  [7E]
    LD C,A                     ; $60C3  [4F]
    PUSH BC                    ; $60C4  [C5]
    LD A,B                     ; $60C5  [78]
    CP $09                     ; $60C6  [FE 09]
    LD BC,$0000                ; $60C8  [01 00 00]
    JR NC,$60D8                ; $60CB  [30 0B]
    LD A,($C899)               ; $60CD  [FA 99 C8]
    LD B,A                     ; $60D0  [47]
    INC B                      ; $60D1  [04]
    LD A,B                     ; $60D2  [78]
    AND $05                    ; $60D3  [E6 05]
    JR Z,$60D1                 ; $60D5  [28 FA]
    LD B,A                     ; $60D7  [47]
    PUSH BC                    ; $60D8  [C5]
    CALL $6800                 ; $60D9  [CD 00 68]
    POP BC                     ; $60DC  [C1]
    CP $0F                     ; $60DD  [FE 0F]
    JR Z,$60D8                 ; $60DF  [28 F7]
    POP BC                     ; $60E1  [C1]
    PUSH AF                    ; $60E2  [F5]
    LD A,C                     ; $60E3  [79]
    LD HL,$C940                ; $60E4  [21 40 C9]
    ADD A,L                    ; $60E7  [85]
    LD L,A                     ; $60E8  [6F]
    LD A,$00                   ; $60E9  [3E 00]
    ADC A,H                    ; $60EB  [8C]
    LD H,A                     ; $60EC  [67]
    POP AF                     ; $60ED  [F1]
    LD (HL),A                  ; $60EE  [77]
    POP HL                     ; $60EF  [E1]
    INC HL                     ; $60F0  [23]
    DEC B                      ; $60F1  [05]
    PUSH HL                    ; $60F2  [E5]
    LD A,(HL)                  ; $60F3  [7E]
    LD C,A                     ; $60F4  [4F]
    PUSH BC                    ; $60F5  [C5]
    CALL $6744                 ; $60F6  [CD 44 67]
    LD A,B                     ; $60F9  [78]
    OR A                       ; $60FA  [B7]
    LD A,$FF                   ; $60FB  [3E FF]
    JR Z,$6102                 ; $60FD  [28 03]
    CALL $6800                 ; $60FF  [CD 00 68]
    POP BC                     ; $6102  [C1]
    PUSH AF                    ; $6103  [F5]
    LD A,C                     ; $6104  [79]
    LD HL,$C940                ; $6105  [21 40 C9]
    ADD A,L                    ; $6108  [85]
    LD L,A                     ; $6109  [6F]
    LD A,$00                   ; $610A  [3E 00]
    ADC A,H                    ; $610C  [8C]
    LD H,A                     ; $610D  [67]
    POP AF                     ; $610E  [F1]
    LD (HL),A                  ; $610F  [77]
    POP HL                     ; $6110  [E1]
    INC HL                     ; $6111  [23]
    DEC B                      ; $6112  [05]
    JR NZ,$60F2                ; $6113  [20 DD]
    LD HL,$7096                ; $6115  [21 96 70]
    LD B,$10                   ; $6118  [06 10]
    PUSH HL                    ; $611A  [E5]
    LD A,(HL)                  ; $611B  [7E]
    CP $FF                     ; $611C  [FE FF]
    JR Z,$6140                 ; $611E  [28 20]
    LD C,A                     ; $6120  [4F]
    PUSH BC                    ; $6121  [C5]
    CALL $6744                 ; $6122  [CD 44 67]
    LD A,B                     ; $6125  [78]
    OR A                       ; $6126  [B7]
    LD A,$0F                   ; $6127  [3E 0F]
    JR Z,$6132                 ; $6129  [28 07]
    LD A,B                     ; $612B  [78]
    XOR $0F                    ; $612C  [EE 0F]
    LD C,A                     ; $612E  [4F]
    CALL $6800                 ; $612F  [CD 00 68]
    POP BC                     ; $6132  [C1]
    PUSH AF                    ; $6133  [F5]
    LD A,C                     ; $6134  [79]
    LD HL,$C940                ; $6135  [21 40 C9]
    ADD A,L                    ; $6138  [85]
    LD L,A                     ; $6139  [6F]
    LD A,$00                   ; $613A  [3E 00]
    ADC A,H                    ; $613C  [8C]
    LD H,A                     ; $613D  [67]
    POP AF                     ; $613E  [F1]
    LD (HL),A                  ; $613F  [77]
    POP HL                     ; $6140  [E1]
    INC HL                     ; $6141  [23]
    DEC B                      ; $6142  [05]
    JR NZ,$611A                ; $6143  [20 D5]
    LD HL,$C940                ; $6145  [21 40 C9]
    LD B,$10                   ; $6148  [06 10]
    PUSH BC                    ; $614A  [C5]
    PUSH HL                    ; $614B  [E5]
    LD C,$0C                   ; $614C  [0E 0C]
    LD A,($C93F)               ; $614E  [FA 3F C9]
    CP $01                     ; $6151  [FE 01]
    JR Z,$6162                 ; $6153  [28 0D]
    CALL $16A3                 ; $6155  [CD A3 16]
    LD A,($C899)               ; $6158  [FA 99 C8]
    LD B,A                     ; $615B  [47]
    LD A,$0C                   ; $615C  [3E 0C]
    CALL $21CA                 ; $615E  [CD CA 21]
    LD C,A                     ; $6161  [4F]
    POP HL                     ; $6162  [E1]
    LD A,(HL)                  ; $6163  [7E]
    SWAP A                     ; $6164  [CB 37]
    ADD A,C                    ; $6166  [81]
    LD (HL+),A                 ; $6167  [22]
    POP BC                     ; $6168  [C1]
    DEC B                      ; $6169  [05]
    JR NZ,$614A                ; $616A  [20 DE]
; --- ROOM SCROLL/WARP SETUP ($616C): scroll bounds, camera, neighbour/warp recs ---
    LD A,$40                   ; $616C  [3E 40]  ; $C0A9 = retry/settle countdown
    LD ($C0A9),A               ; $616E  [EA A9 C0]
    LD A,($C0A9)               ; $6171  [FA A9 C0]
    DEC A                      ; $6174  [3D]
    LD ($C0A9),A               ; $6175  [EA A9 C0]
    JP Z,$605B                 ; $6178  [CA 5B 60]
    CALL $66AE                 ; $617B  [CD AE 66]
    LD A,($C925)               ; $617E  [FA 25 C9]
    LD ($C960),A               ; $6181  [EA 60 C9]
    LDH A,($A5)                ; $6184  [F0 A5]
    LD ($C0A5),A               ; $6186  [EA A5 C0]
    LDH A,($A6)                ; $6189  [F0 A6]
    LD ($C0A6),A               ; $618B  [EA A6 C0]
    LDH A,($A7)                ; $618E  [F0 A7]
    LD ($C0A7),A               ; $6190  [EA A7 C0]
    LDH A,($A8)                ; $6193  [F0 A8]
    LD ($C0A8),A               ; $6195  [EA A8 C0]
    CALL $6AFB                 ; $6198  [CD FB 6A]
    JR Z,$6171                 ; $619B  [28 D4]
    LD A,($C0A7)               ; $619D  [FA A7 C0]
    LD ($C966),A               ; $61A0  [EA 66 C9]
    AND $F0                    ; $61A3  [E6 F0]
    LD L,A                     ; $61A5  [6F]
    LD A,($C0A8)               ; $61A6  [FA A8 C0]
    LD ($C967),A               ; $61A9  [EA 67 C9]
    SLA L                      ; $61AC  [CB 25]
    RLA                        ; $61AE  [17]
    SLA L                      ; $61AF  [CB 25]
    RLA                        ; $61B1  [17]
    LD H,A                     ; $61B2  [67]
    LD A,($C0A6)               ; $61B3  [FA A6 C0]
    LD ($C965),A               ; $61B6  [EA 65 C9]
    LD D,A                     ; $61B9  [57]
    LD A,($C0A5)               ; $61BA  [FA A5 C0]
    LD ($C964),A               ; $61BD  [EA 64 C9]
    SRL D                      ; $61C0  [CB 3A]
    RRA                        ; $61C2  [1F]
    SRL D                      ; $61C3  [CB 3A]
    RRA                        ; $61C5  [1F]
    SRL D                      ; $61C6  [CB 3A]
    RRA                        ; $61C8  [1F]
    AND $1E                    ; $61C9  [E6 1E]
    LD E,A                     ; $61CB  [5F]
    LD D,$00                   ; $61CC  [16 00]
    ADD HL,DE                  ; $61CE  [19]
    LD A,L                     ; $61CF  [7D]
    LD ($C962),A               ; $61D0  [EA 62 C9]
    LD A,H                     ; $61D3  [7C]
    LD ($C963),A               ; $61D4  [EA 63 C9]
    LD A,($C960)               ; $61D7  [FA 60 C9]
    ADD A,A                    ; $61DA  [87]
    ADD A,A                    ; $61DB  [87]
    LD HL,$3176                ; $61DC  [21 76 31]
    ADD A,L                    ; $61DF  [85]
    LD L,A                     ; $61E0  [6F]
    LD A,$00                   ; $61E1  [3E 00]
    ADC A,H                    ; $61E3  [8C]
    LD H,A                     ; $61E4  [67]
    LD A,($C964)               ; $61E5  [FA 64 C9]
    ADD A,(HL)                 ; $61E8  [86]
    LD ($C964),A               ; $61E9  [EA 64 C9]
    INC HL                     ; $61EC  [23]
    LD A,($C965)               ; $61ED  [FA 65 C9]
    ADC A,(HL)                 ; $61F0  [8E]
    LD ($C965),A               ; $61F1  [EA 65 C9]
    INC HL                     ; $61F4  [23]
    LD A,($C966)               ; $61F5  [FA 66 C9]
    ADD A,(HL)                 ; $61F8  [86]
    LD ($C966),A               ; $61F9  [EA 66 C9]
    INC HL                     ; $61FC  [23]
    LD A,($C967)               ; $61FD  [FA 67 C9]
    ADC A,(HL)                 ; $6200  [8E]
    LD ($C967),A               ; $6201  [EA 67 C9]
    INC HL                     ; $6204  [23]
    LD A,$40                   ; $6205  [3E 40]
    LD ($C0A9),A               ; $6207  [EA A9 C0]
    LD A,($C0A9)               ; $620A  [FA A9 C0]
    DEC A                      ; $620D  [3D]
    LD ($C0A9),A               ; $620E  [EA A9 C0]
    JP Z,$605B                 ; $6211  [CA 5B 60]
    CALL $6585                 ; $6214  [CD 85 65]
    LD A,($C960)               ; $6217  [FA 60 C9]
    LD B,A                     ; $621A  [47]
    LD A,($C925)               ; $621B  [FA 25 C9]
    CP B                       ; $621E  [B8]
    JR Z,$620A                 ; $621F  [28 E9]
    LD A,($C925)               ; $6221  [FA 25 C9]
    LD ($C926),A               ; $6224  [EA 26 C9]
    ADD A,A                    ; $6227  [87]
    ADD A,A                    ; $6228  [87]
    LD HL,$3176                ; $6229  [21 76 31]
    ADD A,L                    ; $622C  [85]
    LD L,A                     ; $622D  [6F]
    LD A,$00                   ; $622E  [3E 00]
    ADC A,H                    ; $6230  [8C]
    LD H,A                     ; $6231  [67]
    LD A,(HL+)                 ; $6232  [2A]
    LD ($C927),A               ; $6233  [EA 27 C9]
    LD A,(HL+)                 ; $6236  [2A]
    LD ($C928),A               ; $6237  [EA 28 C9]
    LD A,(HL+)                 ; $623A  [2A]
    LD ($C929),A               ; $623B  [EA 29 C9]
    LD A,(HL+)                 ; $623E  [2A]
    LD ($C92A),A               ; $623F  [EA 2A C9]
    LD HL,$C927                ; $6242  [21 27 C9]
    LDH A,($A5)                ; $6245  [F0 A5]
    ADD A,(HL)                 ; $6247  [86]
    LD (HL+),A                 ; $6248  [22]
    LDH A,($A6)                ; $6249  [F0 A6]
    ADC A,(HL)                 ; $624B  [8E]
    LD (HL),A                  ; $624C  [77]
    LD HL,$C929                ; $624D  [21 29 C9]
    LDH A,($A7)                ; $6250  [F0 A7]
    ADD A,(HL)                 ; $6252  [86]
    LD (HL+),A                 ; $6253  [22]
    LDH A,($A8)                ; $6254  [F0 A8]
    ADC A,(HL)                 ; $6256  [8E]
    LD (HL),A                  ; $6257  [77]
    LD A,($CAB4)               ; $6258  [FA B4 CA]
    OR A                       ; $625B  [B7]
    JR Z,$6262                 ; $625C  [28 04]
    CP $01                     ; $625E  [FE 01]
    JR NZ,$6266                ; $6260  [20 04]
    XOR A                      ; $6262  [AF]
    LD ($C92D),A               ; $6263  [EA 2D C9]
    LD A,($C92D)               ; $6266  [FA 2D C9]
    LD ($C92B),A               ; $6269  [EA 2B C9]
    CP $04                     ; $626C  [FE 04]
    JR Z,$627E                 ; $626E  [28 0E]
    CP $05                     ; $6270  [FE 05]
    JR Z,$627E                 ; $6272  [28 0A]
    CP $06                     ; $6274  [FE 06]
    JR Z,$627E                 ; $6276  [28 06]
    CP $07                     ; $6278  [FE 07]
    JR Z,$627E                 ; $627A  [28 02]
    JR $628A                   ; $627C  [18 0C]
    CALL $16A3                 ; $627E  [CD A3 16]
    LD A,($C899)               ; $6281  [FA 99 C8]
    BIT 0,A                    ; $6284  [CB 47]
    JR Z,$62CF                 ; $6286  [28 47]
    JR $629F                   ; $6288  [18 15]
    CALL $16A3                 ; $628A  [CD A3 16]
    LD A,($C938)               ; $628D  [FA 38 C9]
    LD HL,$7886                ; $6290  [21 86 78]
    ADD A,L                    ; $6293  [85]
    LD L,A                     ; $6294  [6F]
    LD A,$00                   ; $6295  [3E 00]
    ADC A,H                    ; $6297  [8C]
    LD H,A                     ; $6298  [67]
    LD A,($C899)               ; $6299  [FA 99 C8]
    CP (HL)                    ; $629C  [BE]
    JR C,$62B5                 ; $629D  [38 16]
    XOR A                      ; $629F  [AF]
    LD ($C92B),A               ; $62A0  [EA 2B C9]
    LD ($C92C),A               ; $62A3  [EA 2C C9]
    XOR A                      ; $62A6  [AF]
    LD ($C92D),A               ; $62A7  [EA 2D C9]
    XOR A                      ; $62AA  [AF]
    LD ($C92E),A               ; $62AB  [EA 2E C9]
    LD A,$FF                   ; $62AE  [3E FF]
    LD ($C926),A               ; $62B0  [EA 26 C9]
    JR $62CF                   ; $62B3  [18 1A]
    CALL $16A3                 ; $62B5  [CD A3 16]
    LD A,($C899)               ; $62B8  [FA 99 C8]
    LD B,A                     ; $62BB  [47]
    LD A,$05                   ; $62BC  [3E 05]
    CALL $21CA                 ; $62BE  [CD CA 21]
    LD ($C92C),A               ; $62C1  [EA 2C C9]
    CALL $16A3                 ; $62C4  [CD A3 16]
    LD A,($C899)               ; $62C7  [FA 99 C8]
    AND $03                    ; $62CA  [E6 03]
    LD ($C92B),A               ; $62CC  [EA 2B C9]
    XOR A                      ; $62CF  [AF]
    LD ($C92D),A               ; $62D0  [EA 2D C9]
    LD A,$40                   ; $62D3  [3E 40]
    LD ($C0A9),A               ; $62D5  [EA A9 C0]
    LD A,($C0A9)               ; $62D8  [FA A9 C0]
    DEC A                      ; $62DB  [3D]
    LD ($C0A9),A               ; $62DC  [EA A9 C0]
    JP Z,$605B                 ; $62DF  [CA 5B 60]
    CALL $661B                 ; $62E2  [CD 1B 66]
    LD HL,$C960                ; $62E5  [21 60 C9]
    LD A,($C925)               ; $62E8  [FA 25 C9]
    CP (HL)                    ; $62EB  [BE]
    JR NZ,$62F1                ; $62EC  [20 03]
    CALL $661B                 ; $62EE  [CD 1B 66]
    LD A,($C925)               ; $62F1  [FA 25 C9]
    LD ($C0AF),A               ; $62F4  [EA AF C0]
    CALL $68C6                 ; $62F7  [CD C6 68]
    JP Z,$62D8                 ; $62FA  [CA D8 62]
    LD A,($C926)               ; $62FD  [FA 26 C9]
    LD B,A                     ; $6300  [47]
    LD A,($C925)               ; $6301  [FA 25 C9]
    CP B                       ; $6304  [B8]
    JR Z,$62D8                 ; $6305  [28 D1]
    LD A,($C925)               ; $6307  [FA 25 C9]
    LD ($C0A0),A               ; $630A  [EA A0 C0]
    ADD A,A                    ; $630D  [87]
    ADD A,A                    ; $630E  [87]
    LD HL,$3176                ; $630F  [21 76 31]
    ADD A,L                    ; $6312  [85]
    LD L,A                     ; $6313  [6F]
    LD A,$00                   ; $6314  [3E 00]
    ADC A,H                    ; $6316  [8C]
    LD H,A                     ; $6317  [67]
    LD A,(HL+)                 ; $6318  [2A]
    LD ($C96F),A               ; $6319  [EA 6F C9]
    LD A,(HL+)                 ; $631C  [2A]
    LD ($C970),A               ; $631D  [EA 70 C9]
    LD A,(HL+)                 ; $6320  [2A]
    LD ($C971),A               ; $6321  [EA 71 C9]
    LD A,(HL+)                 ; $6324  [2A]
    LD ($C972),A               ; $6325  [EA 72 C9]
    LDH A,($A5)                ; $6328  [F0 A5]
    LD ($C0A1),A               ; $632A  [EA A1 C0]
    LDH A,($A6)                ; $632D  [F0 A6]
    LD ($C0A2),A               ; $632F  [EA A2 C0]
    LDH A,($A7)                ; $6332  [F0 A7]
    LD ($C0A3),A               ; $6334  [EA A3 C0]
    LDH A,($A8)                ; $6337  [F0 A8]
    LD ($C0A4),A               ; $6339  [EA A4 C0]
    LD HL,$C96F                ; $633C  [21 6F C9]
    LDH A,($A5)                ; $633F  [F0 A5]
    ADD A,(HL)                 ; $6341  [86]
    LD (HL+),A                 ; $6342  [22]
    LDH A,($A6)                ; $6343  [F0 A6]
    ADC A,(HL)                 ; $6345  [8E]
    LD (HL),A                  ; $6346  [77]
    LD HL,$C971                ; $6347  [21 71 C9]
    LDH A,($A7)                ; $634A  [F0 A7]
    ADD A,(HL)                 ; $634C  [86]
    LD (HL+),A                 ; $634D  [22]
    LDH A,($A8)                ; $634E  [F0 A8]
    ADC A,(HL)                 ; $6350  [8E]
    LD (HL),A                  ; $6351  [77]
    LD HL,$C100                ; $6352  [21 00 C1]
    LD BC,$0010                ; $6355  [01 10 00]
    XOR A                      ; $6358  [AF]
    CALL $169A                 ; $6359  [CD 9A 16]
    LD A,($C938)               ; $635C  [FA 38 C9]
    LD HL,$732F                ; $635F  [21 2F 73]
    ADD A,A                    ; $6362  [87]
    ADD A,A                    ; $6363  [87]
    ADD A,A                    ; $6364  [87]
    ADD A,A                    ; $6365  [87]
    ADD A,L                    ; $6366  [85]
    LD L,A                     ; $6367  [6F]
    LD A,$00                   ; $6368  [3E 00]
    ADC A,H                    ; $636A  [8C]
    LD H,A                     ; $636B  [67]
    LD A,(HL+)                 ; $636C  [2A]
    PUSH AF                    ; $636D  [F5]
    LD A,($C899)               ; $636E  [FA 99 C8]
    LD B,A                     ; $6371  [47]
    LD A,(HL+)                 ; $6372  [2A]
    INC A                      ; $6373  [3C]
    PUSH HL                    ; $6374  [E5]
    CALL $21CA                 ; $6375  [CD CA 21]
    POP HL                     ; $6378  [E1]
    LD B,A                     ; $6379  [47]
    POP AF                     ; $637A  [F1]
    ADD A,B                    ; $637B  [80]
    LD B,A                     ; $637C  [47]
    LD C,(HL)                  ; $637D  [4E]
    PUSH BC                    ; $637E  [C5]
    LD HL,$C940                ; $637F  [21 40 C9]
    LD B,$10                   ; $6382  [06 10]
    LD C,$00                   ; $6384  [0E 00]
    LD A,(HL+)                 ; $6386  [2A]
    AND $F0                    ; $6387  [E6 F0]
    CP $F0                     ; $6389  [FE F0]
    JR Z,$638E                 ; $638B  [28 01]
    INC C                      ; $638D  [0C]
    DEC B                      ; $638E  [05]
    JR NZ,$6386                ; $638F  [20 F5]
    LD A,C                     ; $6391  [79]
    POP BC                     ; $6392  [C1]
    CP $06                     ; $6393  [FE 06]
    JR NC,$639B                ; $6395  [30 04]
    SRL B                      ; $6397  [CB 38]
    RES 7,B                    ; $6399  [CB B8]
    LD HL,$D793                ; $639B  [21 93 D7]
    LD A,B                     ; $639E  [78]
    OR A                       ; $639F  [B7]
    JR Z,$63AC                 ; $63A0  [28 0A]
    PUSH BC                    ; $63A2  [C5]
    LD (HL),$FF                ; $63A3  [36 FF]
    CALL $6432                 ; $63A5  [CD 32 64]
    POP BC                     ; $63A8  [C1]
    DEC B                      ; $63A9  [05]
    JR NZ,$63A2                ; $63AA  [20 F6]
    LD (HL),$FF                ; $63AC  [36 FF]
    RET                        ; $63AE  [C9]

; ------------------------------------------------------------
; Bank22_Fn7  ($6DB0)  — fn7 — build 8-entry table at $D9CF via helper $6DC1 (8 iterations).
; ------------------------------------------------------------
Bank22_Fn7:                                 ; $6DB0
    LD HL,$D9CF                ; $6DB0  [21 CF D9]
    LD B,$08                   ; $6DB3  [06 08]
    PUSH BC                    ; $6DB5  [C5]
    PUSH HL                    ; $6DB6  [E5]
    CALL $6DC1                 ; $6DB7  [CD C1 6D]
    POP HL                     ; $6DBA  [E1]
    POP BC                     ; $6DBB  [C1]
    LD (HL+),A                 ; $6DBC  [22]
    DEC B                      ; $6DBD  [05]
    JR NZ,$6DB5                ; $6DBE  [20 F5]
    RET                        ; $6DC0  [C9]
