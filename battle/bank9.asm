; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 9  (Battle-scene animation + view state machines)
; ============================================================================
;
; File offset $24000-$27FFF  (16 KB, mapped at $4000-$7FFF)
;
; ENTRY / OWNERSHIP:
;   Both functions run as OVERWORLD scene-mode overlays, ticked by bank6 fn6:
;     $C8EB bit4 -> fn0 (BattleAnim)   $C8EB bit7 -> fn1 (BattleView)
;   bit4 is raised by bank81 (battle screen) $6805, which arms $C8EF=$FF and
;   $C905=0. fn0 states 1 & 14 (Reset) clear bit4 to end the overlay and hand
;   the frame back to the field; state 15 falls through to fn1. So this bank IS
;   the "battle sub-screen" behind bank6 fn6's bit4/bit7. (See c8eb-scene-modes.)
;
; fn0 ($4005): BattleAnim — outer dispatch on $C8EF (16 phases)
;   Phase 0/12 ($45F6): sub-dispatch on $C905 (5 states)
;     S0 ($4604): C906 sub-dispatch via $470A (11 states → $4724-$4ACD)
;     S1 ($464F): C906 sub-dispatch via $4AEE (13 states → $4B0C-$4EEB)
;   Phase 2 ($4EFC): sub-dispatch on $C905 (7 states)
;     S0 ($4F0E): C906 sub-dispatch via $511D (9 states → $5133-$53A1)
;     S1 ($4F59): C906 sub-dispatch via $53B2 (5 states → $53C0-$5502)
;     S2 ($4FB6): C906 sub-dispatch via $551C (9 states → $5532-$577F)
;     S3 ($5026): C906 sub-dispatch via $5790 (5 states → $579E-$58F5)
;   Phase 4 ($5B67): sub-dispatch on $C905 (5 states)
;     S0 ($5B75): C906 sub-dispatch via $5C0D (9 states → $5C23-$5EB9)
;   Phase 13 ($5ECD): sub-dispatch on $C905 (4 states)
;   fn0 state 15 → BattleView ($60E2)
;
; fn1 ($60E2): BattleView — dispatch on $C905 (11 states)
;
; Cross-bank calls from this bank:
;   RST $10 $0A00 → bank10/fn0  (BattleAnim states 5,6,7,11)
;   RST $10 $1200 → bank18/fn0  (BattleAnim states 3,8,9,10)
;   RST $10 $0403 → bank4/fn3   (BattleView body)
; ============================================================================

SECTION "Bank9_ID", ROMX[$4000], BANK[9]
    DB $09

SECTION "Bank9_JumpTable", ROMX[$4001], BANK[9]
    DW BattleAnim                          ; fn0 @ $4005
    DW BattleView                          ; fn1 @ $60E2


; ============================================================================
; Bank9 fn0 = BattleAnim ($4005) — BATTLE-SCENE animation master state machine.
; ----------------------------------------------------------------------------
; ENTRY: called every frame from bank6 fn6 when $C8EB bit4 is set (the battle
;   overlay). bit4 is raised by bank81 (battle screen) $6805, which also sets
;   $C8EF=$FF and $C905=0 to arm this machine. States 1 & 14 (Reset) clear bit4
;   to hand the frame back to the field; state 15 falls through to fn1 (BattleView).
; Outer state index = $C8EF (16 phases). Phases 3/8/9/10 defer to bank18 fn0
;   (BnkCallB) and 5/6/7/11 to bank10 fn0 (BnkCallA) — the per-effect animators.
; ============================================================================
SECTION "BattleAnim", ROMX[$4005], BANK[9]
BattleAnim:
    LD A,($C8EF)                             ; $4005 [FA EF C8]  ; outer phase index (armed to $FF by bank81)
    RST $00                                   ; $4008 [C7]         ; dispatch via the 16-entry dw table below
    DW BattleAnim_Phase0                      ; $4009 [F6 45]  state 0  ($45F6) intro/build
    DW BattleAnim_Reset                       ; $400B [33 40]  state 1  exit: clear bit4
    DW BattleAnim_Phase2                      ; $400D [FC 4E]  state 2  ($4EFC)
    DW BattleAnim_BnkCallB                    ; $400F [2E 40]  state 3  -> bank18 fn0
    DW BattleAnim_Phase4                      ; $4011 [67 5B]  state 4  ($5B67)
    DW BattleAnim_BnkCallA                    ; $4013 [29 40]  state 5  -> bank10 fn0
    DW BattleAnim_BnkCallA                    ; $4015 [29 40]  state 6  -> bank10 fn0
    DW BattleAnim_BnkCallA                    ; $4017 [29 40]  state 7  -> bank10 fn0
    DW BattleAnim_BnkCallB                    ; $4019 [2E 40]  state 8  -> bank18 fn0
    DW BattleAnim_BnkCallB                    ; $401B [2E 40]  state 9  -> bank18 fn0
    DW BattleAnim_BnkCallB                    ; $401D [2E 40]  state 10 -> bank18 fn0
    DW BattleAnim_BnkCallA                    ; $401F [29 40]  state 11 -> bank10 fn0
    DW BattleAnim_Phase0                      ; $4021 [F6 45]  state 12 (reuses Phase0)
    DW BattleAnim_Phase13                     ; $4023 [CD 5E]  state 13 ($5ECD)
    DW BattleAnim_Reset                       ; $4025 [33 40]  state 14 exit: clear bit4
    DW BattleView                             ; $4027 [E2 60]  state 15 -> fn1 (BattleView)

; --- per-effect delegators + exit ------------------------------------------
SECTION "BattleAnim_Helpers", ROMX[$4029], BANK[9]
BattleAnim_BnkCallA:                          ; states 5/6/7/11
    LD HL,$0A00                               ; $4029 [21 00 0A]
    RST $10                                   ; $402C [D7]         ; bankcall -> bank10 fn0 (effect animator A)
    RET                                       ; $402D [C9]
BattleAnim_BnkCallB:                          ; states 3/8/9/10
    LD HL,$1200                               ; $402E [21 00 12]
    RST $10                                   ; $4031 [D7]         ; bankcall -> bank18 fn0 (effect animator B)
    RET                                       ; $4032 [C9]
BattleAnim_Reset:                             ; states 1/14 = END the battle overlay
    LD HL,$C8EB                               ; $4033 [21 EB C8]  ; wStateFlags
    RES 4,(HL)                                ; $4036 [CB A6]      ; clear bit4 -> field resumes next frame (fn6)
    XOR A                                     ; $4038 [AF]
    LD ($C905),A                              ; $4039 [EA 05 C9]  ; reset inner state = 0
    RET                                       ; $403C [C9]

SECTION "BattleAnim_TileHelpers", ROMX[$403D], BANK[9]
BattleAnim_TileWriteInc:
    LD A,(HL)
    ADD A,$04
    LD (HL+),A
    LD A,(HL)
    ADC A,$00
    LD (HL-),A
    LD A,(HL)
    AND $F8
    LD (HL),A
    RET
BattleAnim_ColumnAdvance:
    PUSH AF
    LD A,L
    AND $E0
    PUSH AF
    LD A,L
    INC A
    AND $1F
    LD L,A
    POP AF
    OR L
    LD L,A
    POP AF
    RET
BattleAnim_VRAMAddrSet:
    LD A,($C909)
    ADD A,L
    LD L,A
    LD A,($C90A)
    ADC A,H
    AND $03
    LD H,A
    LD A,($C90A)
    AND $FC
    OR H
    LD H,A
    RET
BattleAnim_ColumnAdvSimple:
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    RET
BattleAnim_WriteColumn:
    PUSH BC
    LD B,L
    LD A,L
    AND $E0
    LD L,A
    CALL BattleAnim_VRAMAddrSet
    LD A,B
    AND $1F
    JR Z,Lbl9_408B
    LD B,A
Lbl9_4085:
    CALL BattleAnim_ColumnAdvance
    DEC B
    JR NZ,Lbl9_4085
Lbl9_408B:
    POP BC
    RET
BattleAnim_StreamFull:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    CALL BattleAnim_WriteColumn
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
Lbl9_409C:
    LD A,(DE)
    INC DE
    CP $D9
    RET Z
    CP $D8
    JR NZ,Lbl9_40C1
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$20
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    JR Lbl9_409C
Lbl9_40C1:
    CALL $1E80
    CALL BattleAnim_ColumnAdvance
    JR Lbl9_409C
BattleAnim_StreamSimple:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    CALL BattleAnim_ColumnAdvSimple
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
Lbl9_40D8:
    LD A,(DE)
    INC DE
    CP $D9
    RET Z
    CP $D8
    JR NZ,Lbl9_40F7
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$20
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    JR Lbl9_40D8
Lbl9_40F7:
    LD (HL+),A
    JR Lbl9_40D8
BattleAnim_VRAMFill:
    LD A,($C909)
    LD L,A
    LD A,($C90A)
    LD H,A
    LD DE,$C500
    LD C,$12
Lbl9_4107:
    LD B,$20
    PUSH HL
Lbl9_410A:
    LD A,(DE)
    CALL $1E80
    LD A,L
    AND $E0
    PUSH AF
    LD A,L
    INC A
    AND $1F
    LD L,A
    POP AF
    OR L
    LD L,A
    INC DE
    DEC B
    JR NZ,Lbl9_410A
    POP HL
    PUSH BC
    LD BC,$0020
    ADD HL,BC
    LD A,H
    AND $03
    OR $98
    LD H,A
    POP BC
    DEC C
    JR NZ,Lbl9_4107
    RET
Fn9_412F:
    LD A,($C827)
    LD C,A
    LD A,($C828)
    LD B,A
    PUSH BC
    LD A,($C829)
    LD C,A
    LD A,($C82A)
    LD B,A
    PUSH BC
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    LD HL,$4102
    RST $10
    POP DE
    POP HL
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    RET
Fn9_4168:
    PUSH HL
    LD HL,$C180
    CALL $106C
    POP HL
    LD A,($C827)
    LD C,A
    LD A,($C828)
    LD B,A
    PUSH BC
    LD A,($C829)
    LD C,A
    LD A,($C82A)
    LD B,A
    PUSH BC
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD DE,$0401
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    LD A,$02
    LD ($C822),A
    LD A,$00
    LD ($C823),A
    LD HL,$4102
    RST $10
    POP DE
    POP HL
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    RET
Fn9_41B6:
    LD ($C180),A
    LD A,$F0
    LD ($C181),A
    LD A,($C827)
    LD C,A
    LD A,($C828)
    LD B,A
    PUSH BC
    LD A,($C829)
    LD C,A
    LD A,($C82A)
    LD B,A
    PUSH BC
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD DE,$0101
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    LD A,$02
    LD ($C822),A
    LD A,$00
    LD ($C823),A
    LD HL,$4102
    RST $10
    POP DE
    POP HL
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    RET

SECTION "BattleAnim_VRAMHelpers", ROMX[$4204], BANK[9]
BattleAnim_CopyToVRAM:
    LD HL,$C500
    LD DE,$C300
    LD BC,$0200
Lbl9_420D:
    LD A,(DE)
    INC DE
    LD (HL+),A
    DEC BC
    LD A,B
    OR C
    JR NZ,Lbl9_420D
    LD DE,$C1C0
    LD C,$02
Lbl9_421A:
    LD B,$14
Lbl9_421C:
    LD A,(DE)
    INC DE
    LD (HL+),A
    DEC B
    JR NZ,Lbl9_421C
    LD A,E
    ADD A,$0C
    LD E,A
    LD A,D
    ADC A,$00
    LD D,A
    LD A,L
    ADD A,$0C
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    DEC C
    JR NZ,Lbl9_421A
    RET
BattleAnim_CopyC0C8:
    LD HL,$C500
    LD BC,$0240
Lbl9_423C:
    LD A,$E0
    LD (HL+),A
    DEC BC
    LD A,B
    OR C
    JR NZ,Lbl9_423C
    RET
BattleAnim_ClearVRAM9800:
    LD HL,$9800
    LD BC,$0400
Lbl9_424B:
    LD A,$E0
    CALL $1E8C
    DEC BC
    LD A,B
    OR C
    JR NZ,Lbl9_424B
    RET
Fn9_4256:
    LD A,C
    LD ($C8E1),A
BattleAnim_ReadSlotByte:
    RET Z
    INC DE
    INC DE
    LD A,($C825)
    OR A
    JP NZ,Fn9_42BD
    LD A,($C847)
    BIT 5,A
    JR Z,Lbl9_4283
    INC HL
    LD A,(HL)
    DEC A
    PUSH AF
    PUSH DE
    PUSH BC
    LD A,B
    LD B,C
    DEC B
    CALL $21CA
    LD A,B
    INC A
    POP BC
    POP DE
    LD C,A
    POP AF
    CP C
    JR C,Lbl9_42A1
    LD A,C
    DEC A
    JR Lbl9_42A1
Lbl9_4283:
    LD A,($C847)
    BIT 4,A
    JR Z,Fn9_42BD
    INC HL
    LD A,(HL)
    INC A
    PUSH AF
    PUSH DE
    PUSH BC
    LD A,B
    LD B,C
    DEC B
    CALL $21CA
    LD A,B
    INC A
    POP BC
    POP DE
    LD C,A
    POP AF
    CP C
    JR C,Lbl9_42A1
    LD A,$00
Lbl9_42A1:
    LD (HL-),A
    DEC C
    CP C
    JR NZ,Lbl9_4300
    LD A,($C8E1)
    LD C,A
    PUSH DE
    PUSH BC
    LD A,B
    LD B,C
    CALL $21CA
    POP BC
    POP DE
    OR A
    JR Z,Lbl9_4300
    DEC A
    CP (HL)
    JR NC,Lbl9_4300
    LD (HL),A
    JR Lbl9_4300
Fn9_42BD:
    PUSH BC
    PUSH DE
    PUSH HL
    CALL Fn9_447C
    POP HL
    POP DE
    POP BC
    PUSH DE
    PUSH BC
    LD A,B
    LD B,C
    DEC B
    CALL $21CA
    LD ($C8E1),A
    LD A,B
    POP BC
    POP DE
    LD C,A
    INC HL
    LD A,(HL-)
    CP C
    JR NZ,Fn9_42DF
    LD A,($C8E1)
    INC A
    LD B,A
Fn9_42DF:
    RES 7,(HL)
    LD A,($C847)
    BIT 6,A
    JR Z,Lbl9_42F1
    LD A,(HL)
    DEC A
    CP B
    JR C,Lbl9_42FF
    DEC B
    LD A,B
    JR Lbl9_42FF
Lbl9_42F1:
    LD A,($C847)
    BIT 7,A
    JR Z,Lbl9_4308
    LD A,(HL)
    INC A
    CP B
    JR C,Lbl9_42FF
    LD A,$00
Lbl9_42FF:
    LD (HL),A
Lbl9_4300:
    XOR A
    LD ($C90C),A
    PUSH HL
    PUSH DE
    POP DE
    POP HL
Lbl9_4308:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_4311
    SET 7,(HL)
Lbl9_4311:
    LD A,(HL)
    CALL Fn9_441D
    RET

SECTION "BattleAnim_SlotHelpers", ROMX[$4316], BANK[9]
BattleAnim_SlotScanA:
    RES 7,(HL)
    LD A,($C847)
    BIT 5,A
    JR Z,Lbl9_4328
    LD A,(HL)
    DEC A
    CP B
    JR C,Lbl9_42FF
    DEC B
    LD A,B
    JR Lbl9_42FF
Lbl9_4328:
    LD A,($C847)
    BIT 4,A
    JR Z,Lbl9_4308
    LD A,(HL)
    INC A
    CP B
    JR C,Lbl9_42FF
    LD A,$00
    JR Lbl9_42FF
BattleAnim_SlotScanB:
    RES 7,(HL)
    LD A,C
    LDH ($FFD7),A
    LD A,($C847)
    BIT 7,A
    JR Z,Lbl9_434E
    LD A,$10
    LD ($C90C),A
    CALL Fn9_43A5
    JR Lbl9_4382
Lbl9_434E:
    LD A,($C847)
    BIT 6,A
    JR Z,Lbl9_435F
    LD A,$10
    LD ($C90C),A
    CALL Fn9_43EC
    JR Lbl9_4382
Lbl9_435F:
    LD A,($C847)
    BIT 5,A
    JR Z,Lbl9_436F
    LD A,(HL)
    DEC A
    CP B
    JR C,Lbl9_437D
    DEC B
    LD A,B
    JR Lbl9_437D
Lbl9_436F:
    LD A,($C847)
    BIT 4,A
    JR Z,Lbl9_4386
    LD A,(HL)
    INC A
    CP B
    JR C,Lbl9_437D
    LD A,$00
Lbl9_437D:
    LD (HL),A
    XOR A
    LD ($C90C),A
Lbl9_4382:
    PUSH HL
    PUSH DE
    POP DE
    POP HL
Lbl9_4386:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_438F
    SET 7,(HL)
Lbl9_438F:
    LDH A,($FFD7)
    INC HL
    CP (HL)
    DEC HL
    JR NC,Lbl9_4398
    INC HL
    LD (HL-),A
Lbl9_4398:
    INC HL
    LD A,(HL)
    OR A
    JR NZ,Lbl9_439F
    LD (HL),$01
Lbl9_439F:
    DEC HL
    LD A,(HL)
    CALL Fn9_455B
    RET
Fn9_43A5:
    PUSH DE
    LD A,(HL)
    PUSH HL
    INC HL
    LD C,(HL)
    LD B,$00
    LD HL,$C0A0
    CALL $247C
    POP HL
    LD A,(HL)
    LD DE,$C0A0
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    AND $0F
    DEC A
    LD (DE),A
    CP $FF
    JR NZ,Lbl9_43C9
    LD A,$09
    LD (DE),A
Lbl9_43C9:
    CALL Fn9_43D7
    POP DE
    OR A
    RET NZ
    LD A,(HL)
    OR A
    RET Z
    LD A,$09
    INC HL
    LD (HL-),A
    RET
Fn9_43D7:
    PUSH HL
    LD A,($C0A0)
    AND $0F
    LD C,$0A
    CALL $218D
    LD A,($C0A1)
    AND $0F
    ADD A,L
    POP HL
    INC HL
    LD (HL-),A
    RET
Fn9_43EC:
    PUSH DE
    LD A,(HL)
    PUSH HL
    INC HL
    LD C,(HL)
    LD B,$00
    LD HL,$C0A0
    CALL $247C
    POP HL
    LD DE,$C0A1
    LD A,(HL)
    LD DE,$C0A0
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    AND $0F
    INC A
    LD (DE),A
    CP $0A
    JR NZ,Lbl9_4413
    LD A,$00
    LD (DE),A
Lbl9_4413:
    CALL Fn9_43D7
    POP DE
    RET

SECTION "BattleAnim_SpriteHelper", ROMX[$4418], BANK[9]
BattleAnim_LoadSpriteData:
    XOR A
    LD ($C90C),A
    RET
Fn9_441D:
    LD C,A
    BIT 7,A
    JR NZ,Lbl9_4432
    LD A,($C90C)
    AND $0F
    PUSH AF
    LD A,($C90C)
    INC A
    LD ($C90C),A
    POP AF
    LD A,C
    RET NZ
Lbl9_4432:
    LD C,A
    LD B,$00
Lbl9_4435:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,C
    AND $7F
    CP B
    LD A,$E0
    JR NZ,Lbl9_4465
    LD A,$E9
    BIT 7,C
    JR NZ,Lbl9_4465
    LD A,($C90C)
    BIT 4,A
    LD A,$E0
    JR NZ,Lbl9_4465
    LD A,$E8
Lbl9_4465:
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    INC B
    JR Lbl9_4435
Fn9_447C:
    LD A,B
    CP C
    RET NC
    INC HL
    LD C,(HL)
    DEC DE
    DEC DE
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    DEC HL
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    LD A,C
    AND $7F
    CP $09
    JR Z,Lbl9_44A4
    ADD A,$F1
    CALL Fn9_44C9
    LD A,$EE
    JR Lbl9_44AB
Lbl9_44A4:
    LD A,$F0
    CALL Fn9_44C9
    LD A,$F1
Lbl9_44AB:
    PUSH AF
    LDH A,($FFD5)
    SUB $01
    LDH ($FFD5),A
    LDH A,($FFD6)
    SBC A,$00
    LDH ($FFD6),A
    POP AF
    CALL Fn9_44C9
    LDH A,($FFD5)
    ADD A,$01
    LDH ($FFD5),A
    LDH A,($FFD6)
    ADC A,$00
    LDH ($FFD6),A
    RET
Fn9_44C9:
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    POP AF
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    RET
Fn9_44ED:
    LD A,(HL+)
    PUSH AF
    PUSH HL
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    INC DE
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    LD A,B
    CP C
    LD A,$EE
    JR NC,Lbl9_4506
    LD A,$E7
Lbl9_4506:
    LD (HL-),A
    POP BC
    JR NC,Lbl9_451D
    LD A,(BC)
    CP $09
    JR Z,Lbl9_4517
    ADD A,$F1
    LD (HL-),A
    LD A,$EE
    LD (HL+),A
    JR Lbl9_451D
Lbl9_4517:
    LD A,$F0
    LD (HL-),A
    LD A,$F1
    LD (HL+),A
Lbl9_451D:
    POP AF
Fn9_451E:
    LD C,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,$E9
    BIT 7,C
    JR NZ,Lbl9_4549
    LD A,($C90C)
    BIT 4,A
    LD A,$E0
    JR NZ,Lbl9_4549
    LD A,$E8
Lbl9_4549:
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    RET
Fn9_455B:
    LD C,A
    INC HL
    PUSH DE
    PUSH BC
    LD C,(HL)
    LD B,$00
    LD HL,$C0A0
    CALL $247C
    POP BC
    POP DE
    BIT 7,C
    JR NZ,Lbl9_457E
    LD A,($C90C)
    AND $0F
    PUSH AF
    LD A,($C90C)
    INC A
    LD ($C90C),A
    POP AF
    LD A,C
    RET NZ
Lbl9_457E:
    LD C,A
    LD B,$00
Lbl9_4581:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,C
    AND $7F
    CP B
    LD A,$E0
    JR NZ,Lbl9_45AB
    LD A,($C90C)
    BIT 4,A
    LD A,$E0
    JR NZ,Lbl9_45AB
    LD A,$E6
Lbl9_45AB:
    CP $E0
    JR NZ,Lbl9_45BC
    PUSH HL
    LD A,B
    LD HL,$C0A0
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
Lbl9_45BC:
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    INC B
    JR Lbl9_4581
; ----------------------------------------------------------------------------
; Fn9_45D3 — display a battle message via the global message-bank router
;   On entry HL = a base message id.  Adds the 16-bit event offset
;   $C8F1:$C8F0 (wMsgId) to it, giving the final GLOBAL message id, then calls
;   MsgBankRouter ($0EC5, ROM0).  The router splits the id by high/low byte,
;   re-bases it to a bank-local index (-> $C822/$C823), and RST $10s into the
;   owning text bank's fn0 (banks 66-75/78) to load + print the line.
;   So $C8F0/$C8F1 selects WHICH battle line (e.g. "<mon> appeared!") is shown.
; ----------------------------------------------------------------------------
Fn9_45D3:
    LD A,($C8F0)                            ; wMsgId lo (event message offset)
    ADD A,L
    LD L,A
    LD A,($C8F1)                            ; wMsgId hi
    ADC A,H
    LD H,A                                  ; HL = base id + $C8F1:$C8F0 = global msg id
    CALL $0EC5                              ; MsgBankRouter (ROM0) → route to text bank, print
    RET

SECTION "BattleAnim_Phase0", ROMX[$45E1], BANK[9]
BattleAnim_UpdateC0C8:
    OR A
    RET Z
    PUSH AF
Lbl9_45E4:
    LD A,(DE)
    INC DE
    CP $F0
    JR NZ,Lbl9_45E4
    DEC DE
    LD A,$A2
    LD (DE),A
    INC DE
    POP AF
    LD L,E
    LD H,D
    CALL $0D90
    RET
BattleAnim_Phase0:
    LD A,($C905)
    RST $00
    DW BattleAnim_P0S0                        ; state 0
    DW BattleAnim_P0S1                        ; state 1
    DW BattleAnim_P0S2                        ; state 2
    DW BattleAnim_P0S3                        ; state 3
    DW BattleAnim_P0S4                        ; state 4
BattleAnim_P0S0:
    LD HL,$FFB7
    CALL BattleAnim_TileWriteInc
    LD HL,$FFBB
    CALL BattleAnim_TileWriteInc
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LDH A,($FFBB)
    LD L,A
    LD H,$00
    ADD HL,HL
    ADD HL,HL
    LDH A,($FFB7)
    RRCA
    RRCA
    RRCA
    ADD A,L
    LD L,A
    LD A,H
    ADC A,$98
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LD ($C909),A
    LD A,H
    LD ($C90A),A
    CALL BattleAnim_CopyToVRAM
    LD DE,$2E0E
    LD HL,$8800
    CALL $194A
    CALL BattleAnim_LoadSpriteData
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P0S1:
    LD HL,$C905
    INC (HL)
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_465D
    CALL BattleAnim_VRAMFill
    RET
Fn9_465D:
    LD DE,$6C55
    CALL BattleAnim_StreamSimple
    LD DE,$6C38
    CALL BattleAnim_StreamSimple
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    LD A,($CA4B)
    LDH ($FFD5),A
    LD A,($CA4C)
    LDH ($FFD6),A
    LD A,($CA4D)
    LDH ($FFD7),A
    LD HL,$002E
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    CALL BattleAnim_LoadSpriteData
    LD DE,$46E2
    LD A,($C8DA)
    CALL Fn9_451E
    RET
BattleAnim_P0S2:
    LD DE,$46E2
    LD HL,$C8DA
    LD B,$03
    CALL Fn9_42DF
    LD A,($C846)
    AND $0A
    JR Z,Lbl9_46B0
    LD HL,$C905
    INC (HL)
    LD HL,$C905
    INC (HL)
    JR Lbl9_46E1
Lbl9_46B0:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_46E1
    LD A,$59
    CALL $1EFF
    LD HL,$C905
    INC (HL)
    XOR A
    LD ($C906),A
    LD HL,$C8DA
    SET 7,(HL)
    LD HL,$C8DB
    LD BC,$0007
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    JR Lbl9_46E1
Lbl9_46E1:
    RET
; data $46E2-$46E9
    DB $21, $00, $61, $00, $A1, $00, $FF, $FF
BattleAnim_P0S3:
    LD A,($C8DA)
    RST $00
; data $46EE-$46F3
    DB $0A, $47, $EE, $4A, $F4, $46
BattleAnim_P0S4:
    CALL BattleAnim_CopyToVRAM
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_VRAMFill
    LD HL,$C8EB
    RES 4,(HL)
    XOR A
    LD ($C905),A
    RET

SECTION "BattleAnim_P0S0_Disp", ROMX[$470A], BANK[9]
BattleAnim_P0S0_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P0S0_D0                     ; state 0
    DW BattleAnim_P0S0_D1                     ; state 1
    DW BattleAnim_P0S0_D2                     ; state 2
    DW BattleAnim_P0S0_D3                     ; state 3
    DW BattleAnim_P0S0_D4                     ; state 4
    DW BattleAnim_P0S0_D5                     ; state 5
    DW BattleAnim_P0S0_D6                     ; state 6
    DW BattleAnim_P0S0_D7                     ; state 7
    DW BattleAnim_P0S0_D8                     ; state 8
    DW BattleAnim_P0S0_D9                     ; state 9
    DW BattleAnim_P0S0_D10                    ; state 10

SECTION "BattleAnim_P0S0_States", ROMX[$4724], BANK[9]
BattleAnim_P0S0_D0:
    LD HL,$0003
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    LD A,($C968)
    LD HL,$478F
    CP $50
    JR Z,Lbl9_4757
    LD A,($C925)
    LD HL,$476E
    CP $00
    JR Z,Lbl9_4757
    LD HL,$4777
    CP $02
    JR Z,Lbl9_4757
    LD HL,$4780
    CP $04
    JR Z,Lbl9_4757
    LD HL,$4787
    CP $05
    JR Z,Lbl9_4757
Lbl9_4757:
    PUSH HL
    LD HL,$C0D8
    LD BC,$0014
    XOR A
    CALL $169A
    POP HL
    LD DE,$C0D8
Lbl9_4766:
    LD A,(HL+)
    LD (DE),A
    INC DE
    CP $FF
    RET Z
    JR Lbl9_4766
; data $476E-$4797
    DB $01, $02, $07, $28, $13, $14, $1D, $26, $FF, $05, $04, $03, $0C, $2A, $2B, $15
    DB $1A, $FF, $1F, $20, $21, $22, $23, $24, $FF, $17, $29, $19, $1B, $18, $1C, $25
    DB $FF, $01, $02, $07, $08, $0B, $09, $0A, $0C, $FF
BattleAnim_P0S0_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_4878
    CALL Fn9_47D0
    CALL Fn9_47AB
    LD HL,$C906
    INC (HL)
    RET
Fn9_47AB:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_465D
    LD DE,$6C96
    CALL BattleAnim_StreamSimple
    CALL Fn9_480D
    CALL BattleAnim_LoadSpriteData
    LD DE,$48EF
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    CALL BattleAnim_VRAMFill
    RET
Fn9_47D0:
    LD DE,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$8800
    CALL Fn9_47EA
    CALL Fn9_47EA
    CALL Fn9_47EA
Fn9_47EA:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CP $FF
    JR NZ,Lbl9_47F3
    LD A,$00
Lbl9_47F3:
    LD ($C823),A
    LD A,$08
    LD ($C822),A
    LD DE,$0901
    CALL Fn9_412F
    POP HL
    LD A,L
    ADD A,$90
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_480D:
    LD DE,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$00AD
    CALL Fn9_4827
    CALL Fn9_4827
    CALL Fn9_4827
Fn9_4827:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CP $00
    JR Z,Lbl9_4832
    CP $FF
    JR NZ,Lbl9_483F
Lbl9_4832:
    CALL BattleAnim_ColumnAdvSimple
    LD A,$E0
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    JR Lbl9_486C
Lbl9_483F:
    PUSH HL
    LD A,(DE)
    LD ($DA5E),A
    LD HL,$0302
    RST $10
    POP HL
    PUSH HL
    CALL BattleAnim_ColumnAdvSimple
    LD A,($DA63)
    LDH ($FFD5),A
    LD A,($DA64)
    LDH ($FFD6),A
    LD A,$00
    LDH ($FFD7),A
    CALL $2388
    POP HL
    LD A,L
    ADD A,$05
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    CALL BattleAnim_ColumnAdvSimple
    LD (HL),$DD
Lbl9_486C:
    POP HL
    LD A,L
    ADD A,$40
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_4878:
    LD HL,$C0D8
    CALL Fn9_4883
    LD A,C
    LD ($C8E9),A
    RET
Fn9_4883:
    LD B,$14
    LD C,$00
Lbl9_4887:
    LD A,(HL+)
    CP $00
    RET Z
    CP $FF
    RET Z
    INC C
    DEC B
    JR NZ,Lbl9_4887
    RET
BattleAnim_P0S0_D2:
    LD DE,$48EF
    LD HL,$C8E2
    LD A,($C8E9)
    LD C,A
    LD B,$04
    INC HL
    LD A,(HL-)
    PUSH AF
    LD A,(HL)
    PUSH AF
    CALL Fn9_4256
    POP AF
    LD HL,$C8E2
    AND $7F
    LD B,A
    LD A,(HL)
    AND $7F
    CP B
    JR Z,Lbl9_48B4
Lbl9_48B4:
    POP AF
    LD HL,$C8E3
    CP (HL)
    JR Z,Lbl9_48C4
    CALL Fn9_47D0
    CALL Fn9_480D
    CALL BattleAnim_VRAMFill
Lbl9_48C4:
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_48D8
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    JR Fn9_48EE
Lbl9_48D8:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_48EE
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
    LD A,$01
    LD ($C8DD),A
Fn9_48EE:
    RET
; data $48EF-$48FA
    DB $92, $01, $A2, $00, $E2, $00, $22, $01, $62, $01, $FF, $FF
BattleAnim_P0S0_D3:
    LD HL,$0005
    CALL Fn9_45D3
    LD A,$01
    LD ($C8DC),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S0_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_4918
    LD HL,$C906
    INC (HL)
    RET
Fn9_4918:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_465D
    LD DE,$6C96
    CALL BattleAnim_StreamSimple
    CALL Fn9_480D
    LD DE,$48EF
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    LD DE,$6D4C
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$4990
    LD HL,$C8DC
    LD B,$02
    LD A,(HL)
    CALL Fn9_455B
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P0S0_D5:
    LD DE,$4990
    LD HL,$C8DC
    LD B,$02
    LD C,$14
    CALL BattleAnim_SlotScanB
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_497E
    CALL Fn9_47AB
    LD HL,$0004
    CALL Fn9_45D3
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_498F
Lbl9_497E:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_498F
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_498F:
    RET
; data $4990-$4995
    DB $61, $01, $62, $01, $FF, $FF
BattleAnim_P0S0_D6:
    LD HL,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DA5E),A
    LD L,A
    LD H,$08
    LD DE,$C180
    CALL $0D67
    LD A,($C8DD)
    LD HL,$C190
    CALL $0D90
    LD HL,$0302
    RST $10
    LD A,($DA63)
    LD C,A
    LD A,($DA64)
    LD B,A
    LD A,($C8DD)
    CALL $21B5
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    LD A,E
    LDH ($FFD7),A
    LD A,L
    LD ($C8E4),A
    LD A,H
    LD ($C8E5),A
    LD A,E
    LD ($C8E6),A
    LD HL,$C1A0
    CALL $0DB3
    LD HL,$0006
    CALL Fn9_45D3
    XOR A
    LD ($C8DE),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S0_D7:
    LD A,($C825)
    OR A
    RET NZ
    LD A,$5C
    CALL $1EFF
    LD DE,$6C13
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$4A67
    LD A,($C8DE)
    CALL Fn9_451E
    CALL BattleAnim_VRAMFill
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S0_D8:
    LD DE,$4A67
    LD HL,$C8DE
    LD B,$02
    CALL Fn9_42DF
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_4A4E
Lbl9_4A33:
    CALL Fn9_4918
    LD HL,$0005
    CALL Fn9_45D3
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_4A66
Lbl9_4A4E:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_4A66
    LD A,$59
    CALL $1EFF
    LD A,($C8DE)
    CP $81
    JR Z,Lbl9_4A33
    LD HL,$C906
    INC (HL)
Fn9_4A66:
    RET
; data $4A67-$4A6C
    DB $2F, $01, $6F, $01, $FF, $FF
BattleAnim_P0S0_D9:
    LD HL,$0305
    RST $10
    LD HL,$C8E4
    LD A,($CA4B)
    SUB (HL)
    INC HL
    LD A,($CA4C)
    SBC A,(HL)
    INC HL
    LD A,($CA4D)
    SBC A,(HL)
    LD HL,$0007
    JR C,Lbl9_4AC5
    LD HL,$CA51
    CALL Fn9_4883
    LD A,($C8DD)
    ADD A,C
    CP $15
    LD HL,$0008
    JR NC,Lbl9_4AC5
    LD A,($C8E4)
    LD L,A
    LD A,($C8E5)
    LD H,A
    LD A,($C8E6)
    LD E,A
    CALL $27F3
    LD HL,$CA51
    CALL Fn9_4883
    LD A,C
    LD HL,$CA51
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($C8DD)
    LD B,A
    LD A,($DA5E)
Lbl9_4ABE:
    LD (HL+),A
    DEC B
    JR NZ,Lbl9_4ABE
    LD HL,$0009
Lbl9_4AC5:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S0_D10:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C8DB
    LD BC,$0007
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD A,$00
    LD ($C906),A
    RET

SECTION "BattleAnim_P0S1_Disp", ROMX[$4AEE], BANK[9]
BattleAnim_P0S1_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P0S1_D0                     ; state 0
    DW BattleAnim_P0S1_D1                     ; state 1
    DW BattleAnim_P0S1_D2                     ; state 2
    DW BattleAnim_P0S1_D3                     ; state 3
    DW BattleAnim_P0S1_D4                     ; state 4
    DW BattleAnim_P0S1_D5                     ; state 5
    DW BattleAnim_P0S1_D6                     ; state 6
    DW BattleAnim_P0S1_D7                     ; state 7
    DW BattleAnim_P0S1_D8                     ; state 8
    DW BattleAnim_P0S1_D9                     ; state 9
    DW BattleAnim_P0S1_D10                    ; state 10
    DW BattleAnim_P0S1_D11                    ; state 11
    DW BattleAnim_P0S1_D12                    ; state 12

SECTION "BattleAnim_P0S1_States", ROMX[$4B0C], BANK[9]
BattleAnim_P0S1_D0:
    CALL Fn9_4C27
    LD HL,$C0D8
    CALL Fn9_4883
    LD A,C
    OR A
    JR NZ,Lbl9_4B1F
    LD A,$0B
    LD ($C906),A
    RET
Lbl9_4B1F:
    LD HL,$000A
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_4C27
    CALL Fn9_4878
    CALL Fn9_47D0
    CALL Fn9_4B40
    LD HL,$C906
    INC (HL)
    RET
Fn9_4B40:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_465D
    LD DE,$6C96
    CALL BattleAnim_StreamSimple
    CALL Fn9_4B65
    CALL BattleAnim_LoadSpriteData
    LD DE,$4CE0
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    CALL BattleAnim_VRAMFill
    RET
Fn9_4B65:
    LD DE,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$00AD
    CALL Fn9_4B7F
    CALL Fn9_4B7F
    CALL Fn9_4B7F
Fn9_4B7F:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CP $00
    JR Z,Lbl9_4B8A
    CP $FF
    JR NZ,Lbl9_4B97
Lbl9_4B8A:
    CALL BattleAnim_ColumnAdvSimple
    LD A,$E0
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    JR Lbl9_4BBF
Lbl9_4B97:
    PUSH HL
    PUSH HL
    LD A,(DE)
    LD ($DA5E),A
    CALL Fn9_4BCB
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    LD A,$00
    LDH ($FFD7),A
    POP HL
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    POP HL
    LD A,L
    ADD A,$05
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    CALL BattleAnim_ColumnAdvSimple
    LD (HL),$DD
Lbl9_4BBF:
    POP HL
    LD A,L
    ADD A,$40
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_4BCB:
    LD HL,$0302
    RST $10
    LD A,($DA63)
    LD L,A
    LD A,($DA64)
    LD H,A
    LD A,($C968)
    CP $50
    RET Z
    LD A,($DA5E)
    CP $18
    JR Z,Lbl9_4BFE
    CP $19
    JR Z,Lbl9_4BFE
    CP $1A
    JR Z,Lbl9_4BFE
    CP $1B
    JR Z,Lbl9_4BFE
    CP $1C
    JR Z,Lbl9_4BFE
    CP $25
    JR Z,Lbl9_4BFE
    CP $27
    JR Z,Lbl9_4BFE
    JR Lbl9_4C0C
Lbl9_4BFE:
    LD A,($DA63)
    LD L,A
    LD A,($DA64)
    LD H,A
    LD A,$0A
    CALL $21DC
    RET
Lbl9_4C0C:
    LD A,($DA63)
    LD L,A
    LD A,($DA64)
    LD H,A
    SRL H
    RR L
    SRL H
    RR L
    LD A,($DA63)
    SUB L
    LD L,A
    LD A,($DA64)
    SBC A,H
    LD H,A
    RET
Fn9_4C27:
    LD HL,$0305
    RST $10
    LD HL,$D665
    LD BC,$0030
    XOR A
    CALL $169A
    LD HL,$C0D8
    LD BC,$0014
    XOR A
    CALL $169A
    LD DE,$CA51
    LD B,$14
Lbl9_4C44:
    LD A,(DE)
    OR A
    JR Z,Lbl9_4C6E
    CP $FF
    JR Z,Lbl9_4C6E
    LD ($DA5E),A
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    PUSH DE
    PUSH BC
    LD HL,$0302
    RST $10
    POP BC
    POP DE
    POP HL
    INC DE
    LD A,($DA6D)
    BIT 0,A
    JR NZ,Lbl9_4C6B
    INC (HL)
Lbl9_4C6B:
    DEC B
    JR NZ,Lbl9_4C44
Lbl9_4C6E:
    LD HL,$D666
    LD DE,$C0D8
    LD B,$2F
    LD C,$01
Lbl9_4C78:
    LD A,(HL+)
    OR A
    JR Z,Lbl9_4C7F
    LD A,C
    LD (DE),A
    INC DE
Lbl9_4C7F:
    INC C
    DEC B
    JR NZ,Lbl9_4C78
    RET
BattleAnim_P0S1_D2:
    LD DE,$4CE0
    LD HL,$C8E2
    LD A,($C8E9)
    LD C,A
    LD B,$04
    INC HL
    LD A,(HL-)
    PUSH AF
    LD A,(HL)
    PUSH AF
    CALL Fn9_4256
    POP AF
    LD HL,$C8E2
    AND $7F
    LD B,A
    LD A,(HL)
    AND $7F
    CP B
    JR Z,Lbl9_4CA5
Lbl9_4CA5:
    POP AF
    LD HL,$C8E3
    CP (HL)
    JR Z,Lbl9_4CB5
    CALL Fn9_47D0
    CALL Fn9_4B65
    CALL BattleAnim_VRAMFill
Lbl9_4CB5:
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_4CC9
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    JR Fn9_4CDF
Lbl9_4CC9:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_4CDF
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
    LD A,$01
    LD ($C8DD),A
Fn9_4CDF:
    RET
; data $4CE0-$4CEB
    DB $92, $01, $A2, $00, $E2, $00, $22, $01, $62, $01, $FF, $FF
BattleAnim_P0S1_D3:
    LD HL,$000C
    CALL Fn9_45D3
    LD A,$01
    LD ($C8DC),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_4D09
    LD HL,$C906
    INC (HL)
    RET
Fn9_4D09:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_465D
    LD DE,$6C96
    CALL BattleAnim_StreamSimple
    CALL Fn9_4B65
    LD DE,$4CE0
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    LD DE,$6D5D
    CALL BattleAnim_StreamSimple
    LD HL,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DA5E),A
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$00
    LD HL,$0164
    CALL BattleAnim_ColumnAdvSimple
    CALL $2451
    CALL BattleAnim_LoadSpriteData
    LD DE,$4DB8
    LD HL,$C8DC
    LD B,$02
    LD A,(HL)
    CALL Fn9_455B
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P0S1_D5:
    LD DE,$4DB8
    LD HL,$D665
    LD A,($DA5E)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$02
    LD HL,$C8DC
    CALL BattleAnim_SlotScanB
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_4DA6
    CALL Fn9_4B40
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_4DB7
Lbl9_4DA6:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_4DB7
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_4DB7:
    RET
; data $4DB8-$4DBD
    DB $61, $01, $62, $01, $FF, $FF
BattleAnim_P0S1_D6:
    LD A,($DA5E)
    LD L,A
    LD H,$08
    LD DE,$C180
    CALL $0D67
    LD A,($C8DD)
    LD HL,$C190
    CALL $0D90
    CALL Fn9_4BCB
    LD C,L
    LD B,H
    LD A,($C8DD)
    CALL $21B5
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    LD A,E
    LDH ($FFD7),A
    LD A,L
    LD ($C8E4),A
    LD A,H
    LD ($C8E5),A
    LD A,E
    LD ($C8E6),A
    LD HL,$C1A0
    CALL $0DB3
    LD HL,$000D
    CALL Fn9_45D3
    XOR A
    LD ($C8DE),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D7:
    LD A,($C825)
    OR A
    RET NZ
    LD A,$5C
    CALL $1EFF
    LD DE,$6C13
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$4E70
    LD A,($C8DE)
    CALL Fn9_451E
    CALL BattleAnim_VRAMFill
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D8:
    LD DE,$4E70
    LD HL,$C8DE
    LD B,$02
    CALL Fn9_42DF
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_4E57
Lbl9_4E3E:
    CALL Fn9_4D09
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_4E6F
Lbl9_4E57:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_4E6F
    LD A,$59
    CALL $1EFF
    LD A,($C8DE)
    CP $81
    JR Z,Lbl9_4E3E
    LD HL,$C906
    INC (HL)
Fn9_4E6F:
    RET
; data $4E70-$4E75
    DB $2F, $01, $6F, $01, $FF, $FF
BattleAnim_P0S1_D9:
    LD HL,$C8E4
    LD A,($CA4B)
    ADD A,(HL)
    LD E,A
    INC HL
    LD A,($CA4C)
    ADC A,(HL)
    LD D,A
    INC HL
    LD A,($CA4D)
    ADC A,(HL)
    LD C,A
    LD A,E
    SUB $A0
    LD A,D
    SBC A,$86
    LD A,C
    SBC A,$01
    LD HL,$000E
    JR NC,Lbl9_4EB7
    LD A,($C8E4)
    LD L,A
    LD A,($C8E5)
    LD H,A
    LD A,($C8E6)
    LD E,A
    CALL $27E9
    LD A,($C8DD)
    LD B,A
Lbl9_4EAB:
    PUSH BC
    LD HL,$0307
    RST $10
    POP BC
    DEC B
    JR NZ,Lbl9_4EAB
    LD HL,$000F
Lbl9_4EB7:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D10:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C8DB
    LD BC,$0007
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD A,$00
    LD ($C906),A
    RET
BattleAnim_P0S1_D11:
    LD HL,$000B
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P0S1_D12:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    RET

SECTION "BattleAnim_Phase2", ROMX[$4EFC], BANK[9]
BattleAnim_Phase2:
    LD A,($C905)
    RST $00
    DW BattleAnim_P2S0                        ; state 0
    DW BattleAnim_P2S1                        ; state 1
    DW BattleAnim_P2S2                        ; state 2
    DW BattleAnim_P2S3                        ; state 3
    DW BattleAnim_P2S4                        ; state 4
    DW BattleAnim_P2S5                        ; state 5
    DW BattleAnim_P2S6                        ; state 6

SECTION "BattleAnim_Phase2_States", ROMX[$4F0E], BANK[9]
BattleAnim_P2S0:
    LD HL,$FFB7
    CALL BattleAnim_TileWriteInc
    LD HL,$FFBB
    CALL BattleAnim_TileWriteInc
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LDH A,($FFBB)
    LD L,A
    LD H,$00
    ADD HL,HL
    ADD HL,HL
    LDH A,($FFB7)
    RRCA
    RRCA
    RRCA
    ADD A,L
    LD L,A
    LD A,H
    ADC A,$98
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LD ($C909),A
    LD A,H
    LD ($C90A),A
    CALL BattleAnim_CopyToVRAM
    LD DE,$2E0F
    LD HL,$8800
    CALL $194A
    CALL BattleAnim_LoadSpriteData
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P2S1:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C905
    INC (HL)
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_4F6C
    CALL BattleAnim_VRAMFill
    RET
Fn9_4F6C:
    LD A,$02
    LD ($C822),A
    LD A,$0B
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    LD DE,$7522
    CALL BattleAnim_StreamSimple
    LD DE,$6C38
    CALL BattleAnim_StreamSimple
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    LD A,($CA4B)
    LDH ($FFD5),A
    LD A,($CA4C)
    LDH ($FFD6),A
    LD A,($CA4D)
    LDH ($FFD7),A
    LD HL,$002E
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    CALL BattleAnim_LoadSpriteData
    LD DE,$501E
    LD A,($C8DA)
    CALL Fn9_451E
    RET
BattleAnim_P2S2:
    LD A,($C825)
    OR A
    RET NZ
    LD DE,$501E
    LD HL,$C8DA
    LD B,$03
    CALL Fn9_42DF
    LD A,($C846)
    AND $0A
    JR Z,Lbl9_4FDF
    LD HL,$C905
    INC (HL)
    LD HL,$C905
    INC (HL)
    LD HL,$C905
    INC (HL)
    LD HL,$C905
    INC (HL)
    JR Lbl9_501D
Lbl9_4FDF:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_501D
    LD A,$59
    CALL $1EFF
    LD A,($C8DA)
    CP $82
    JP Z,BattleAnim_P2S6
    LD HL,$C905
    INC (HL)
    XOR A
    LD ($C906),A
    LD HL,$C8DA
    SET 7,(HL)
    LD HL,$C8DB
    LD BC,$0007
    LD A,$00
    CALL $169A
    LD HL,$0003
    LD A,($C8DA)
    AND $7F
    JR Z,Lbl9_5018
    LD HL,$000E
Lbl9_5018:
    CALL Fn9_45D3
    JR Lbl9_501D
Lbl9_501D:
    RET
; data $501E-$5025
    DB $21, $00, $61, $00, $A1, $00, $FF, $FF
BattleAnim_P2S3:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C905
    INC (HL)
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    CALL BattleAnim_VRAMFill
    LD A,$02
    LD ($C822),A
    LD A,$0C
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    RET
Fn9_504C:
    LD DE,$7522
    CALL BattleAnim_StreamSimple
    LD DE,$6C38
    CALL BattleAnim_StreamSimple
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    LD A,($CA4B)
    LDH ($FFD5),A
    LD A,($CA4C)
    LDH ($FFD6),A
    LD A,($CA4D)
    LDH ($FFD7),A
    LD HL,$002E
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    CALL BattleAnim_LoadSpriteData
    LD DE,$50B3
    LD A,($C8DB)
    CALL Fn9_451E
    RET
BattleAnim_P2S4:
    LD A,($C825)
    OR A
    RET NZ
    LD DE,$50B3
    LD HL,$C8DB
    LD B,$03
    CALL Fn9_42DF
    LD A,($C846)
    AND $0A
    JR Z,Lbl9_50BB
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_4F6C
    CALL BattleAnim_VRAMFill
    LD HL,$0001
    CALL Fn9_45D3
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    JR Lbl9_50EA
; data $50B3-$50BA
    DB $21, $00, $61, $00, $A1, $00, $FF, $FF
Lbl9_50BB:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_50EA
    LD A,$59
    CALL $1EFF
    LD HL,$C905
    INC (HL)
    XOR A
    LD ($C906),A
    LD HL,$C8DB
    SET 7,(HL)
    LD HL,$C8DC
    LD BC,$0006
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
Lbl9_50EA:
    RET
BattleAnim_P2S5:
    LD A,($C8DA)
    RST $00
; data $50EF-$5106
    DB $F3, $50, $FD, $50, $FA, $DB, $C8, $C7, $1D, $51, $B2, $53, $07, $51, $FA, $DB
    DB $C8, $C7, $1C, $55, $90, $57, $07, $51
BattleAnim_P2S6:
    CALL BattleAnim_CopyToVRAM
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_VRAMFill
    LD HL,$C8EB
    RES 4,(HL)
    XOR A
    LD ($C905),A
    RET

SECTION "BattleAnim_P2S0_Disp", ROMX[$511D], BANK[9]
BattleAnim_P2S0_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P2S0_D0                     ; state 0
    DW BattleAnim_P2S0_D1                     ; state 1
    DW BattleAnim_P2S0_D2                     ; state 2
    DW BattleAnim_P2S0_D3                     ; state 3
    DW BattleAnim_P2S0_D4                     ; state 4
    DW BattleAnim_P2S0_D5                     ; state 5
    DW BattleAnim_P2S0_D6                     ; state 6
    DW BattleAnim_P2S0_D7                     ; state 7
    DW BattleAnim_P2S0_D8                     ; state 8

SECTION "BattleAnim_P2S0_States", ROMX[$5133], BANK[9]
BattleAnim_P2S0_D0:
    LD HL,$CA51
    CALL Fn9_51F3
    LD A,C
    OR A
    LD HL,$0005
    JR Z,Lbl9_515B
    LD HL,$CA65
    LD B,$28
    CALL Fn9_51F5
    LD A,C
    CP $28
    LD HL,$0006
    JR NC,Lbl9_515B
    LD HL,$C906
    INC (HL)
    LD HL,$0004
    CALL Fn9_45D3
    RET
Lbl9_515B:
    CALL Fn9_45D3
    LD A,$08
    LD ($C906),A
    RET
BattleAnim_P2S0_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_519C
    CALL Fn9_51E8
    CALL Fn9_47D0
    CALL Fn9_517A
    LD HL,$C906
    INC (HL)
    RET
Fn9_517A:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD DE,$6E6C
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$5275
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    CALL BattleAnim_VRAMFill
    RET
Fn9_519C:
    LD HL,$0305
    RST $10
    LD HL,$D665
    LD BC,$0030
    XOR A
    CALL $169A
    LD HL,$C0D8
    LD BC,$0028
    XOR A
    CALL $169A
    LD DE,$CA51
    LD B,$14
Lbl9_51B9:
    LD A,(DE)
    OR A
    JR Z,Lbl9_51D2
    CP $FF
    JR Z,Lbl9_51D2
    LD ($DA5E),A
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    INC DE
    INC (HL)
    DEC B
    JR NZ,Lbl9_51B9
Lbl9_51D2:
    LD HL,$D666
    LD DE,$C0D8
    LD B,$2F
    LD C,$01
Lbl9_51DC:
    LD A,(HL+)
    OR A
    JR Z,Lbl9_51E3
    LD A,C
    LD (DE),A
    INC DE
Lbl9_51E3:
    INC C
    DEC B
    JR NZ,Lbl9_51DC
    RET
Fn9_51E8:
    LD HL,$C0D8
    CALL Fn9_51F3
    LD A,C
    LD ($C8E9),A
    RET
Fn9_51F3:
    LD B,$28
Fn9_51F5:
    LD C,$00
Lbl9_51F7:
    LD A,(HL+)
    CP $00
    RET Z
    CP $FF
    RET Z
    INC C
    DEC B
    JR NZ,Lbl9_51F7
    RET
BattleAnim_P2S0_D2:
    LD DE,$5275
    LD HL,$C8E2
    LD A,($C8E9)
    LD C,A
    LD B,$04
    INC HL
    LD A,(HL-)
    PUSH AF
    LD A,(HL)
    PUSH AF
    CALL Fn9_4256
    POP AF
    LD HL,$C8E2
    AND $7F
    LD B,A
    LD A,(HL)
    AND $7F
    CP B
    JR Z,Lbl9_5224
Lbl9_5224:
    POP AF
    LD HL,$C8E3
    CP (HL)
    JR Z,Lbl9_522E
    CALL Fn9_47D0
Lbl9_522E:
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_525E
    LD A,$02
    LD ($C822),A
    LD A,$0C
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    CALL BattleAnim_VRAMFill
    LD HL,$0003
    CALL Fn9_45D3
    LD A,$04
    LD ($C905),A
    JR Fn9_5274
Lbl9_525E:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5274
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
    LD A,$01
    LD ($C8DE),A
Fn9_5274:
    RET
; data $5275-$5280
    DB $72, $01, $89, $00, $C9, $00, $09, $01, $49, $01, $FF, $FF
BattleAnim_P2S0_D3:
    LD HL,$0007
    CALL Fn9_45D3
    LD A,$01
    LD ($C8DD),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S0_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_529E
    LD HL,$C906
    INC (HL)
    RET
Fn9_529E:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD DE,$6E6C
    CALL BattleAnim_StreamSimple
    LD DE,$5275
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    LD DE,$6D5D
    CALL BattleAnim_StreamSimple
    LD HL,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DA5E),A
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$00
    LD HL,$0164
    CALL BattleAnim_ColumnAdvSimple
    CALL $2451
    CALL BattleAnim_LoadSpriteData
    LD DE,$534C
    LD HL,$C8DD
    LD B,$02
    LD A,(HL)
    CALL Fn9_455B
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P2S0_D5:
    LD DE,$534C
    LD HL,$D665
    LD A,($DA5E)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$02
    LD HL,$C8DD
    CALL BattleAnim_SlotScanB
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_533A
    CALL Fn9_517A
    LD HL,$0004
    CALL Fn9_45D3
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_534B
Lbl9_533A:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_534B
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_534B:
    RET
; data $534C-$5351
    DB $61, $01, $62, $01, $FF, $FF
BattleAnim_P2S0_D6:
    LD HL,$CA65
    LD B,$28
    CALL Fn9_51F5
    LD A,($C8DE)
    ADD A,C
    CP $29
    LD HL,$0008
    JR NC,Lbl9_5378
    LD A,($C8DE)
    LD B,A
Lbl9_5369:
    PUSH BC
    LD HL,$0307
    RST $10
    CALL Fn9_5B1D
    POP BC
    DEC B
    JR NZ,Lbl9_5369
    LD HL,$0009
Lbl9_5378:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S0_D7:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C8DC
    LD BC,$0006
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD A,$00
    LD ($C906),A
    RET
BattleAnim_P2S0_D8:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    RET

SECTION "BattleAnim_P2S1_Disp", ROMX[$53B2], BANK[9]
BattleAnim_P2S1_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P2S1_D0                     ; state 0
    DW BattleAnim_P2S1_D1                     ; state 1
    DW BattleAnim_P2S1_D2                     ; state 2
    DW BattleAnim_P2S1_D3                     ; state 3
    DW BattleAnim_P2S1_D4                     ; state 4

SECTION "BattleAnim_P2S1_States", ROMX[$53C0], BANK[9]
BattleAnim_P2S1_D0:
    LD HL,$000A
    CALL Fn9_45D3
    LD A,$02
    LD ($C8DC),A
    LD A,$00
    LD ($C8DF),A
    LD A,$00
    LD ($C8E0),A
    LD A,$00
    LD ($C8E1),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S1_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_53EC
    LD HL,$C906
    INC (HL)
    RET
Fn9_53EC:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD A,$02
    LD ($C822),A
    LD A,$55
    LD ($C823),A
    LD HL,$8A00
    LD DE,$0401
    CALL Fn9_412F
    LD DE,$6EE3
    CALL BattleAnim_StreamSimple
    LD DE,$6F00
    CALL BattleAnim_StreamSimple
    LD A,($CA4E)
    LDH ($FFD5),A
    LD A,($CA4F)
    LDH ($FFD6),A
    LD A,($CA50)
    LDH ($FFD7),A
    LD HL,$016D
    CALL BattleAnim_ColumnAdvSimple
    CALL $2374
    CALL BattleAnim_LoadSpriteData
    LD DE,$5492
    LD HL,$C8DC
    LD B,$02
    LD A,(HL)
    CALL Fn9_5A6A
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P2S1_D2:
    LD DE,$5492
    LD HL,$C8DC
    LD B,$03
    CALL Fn9_590F
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_5477
    LD A,$02
    LD ($C822),A
    LD A,$0C
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    CALL BattleAnim_VRAMFill
    LD HL,$0003
    CALL Fn9_45D3
    LD A,$04
    LD ($C905),A
    JR Fn9_5491
Lbl9_5477:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5491
    LD HL,$C8DF
    LD A,(HL+)
    OR (HL)
    INC HL
    OR (HL)
    JR Z,Fn9_5491
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_5491:
    RET
; data $5492-$549D
    DB $8E, $00, $8F, $00, $90, $00, $91, $00, $92, $00, $FF, $FF
BattleAnim_P2S1_D3:
    LD HL,$C8DF
    LD A,($CA4B)
    SUB (HL)
    INC HL
    LD A,($CA4C)
    SBC A,(HL)
    INC HL
    LD A,($CA4D)
    SBC A,(HL)
    LD HL,$000B
    JR C,Lbl9_54FA
    LD HL,$C8DF
    LD A,($CA4E)
    ADD A,(HL)
    LD E,A
    INC HL
    LD A,($CA4F)
    ADC A,(HL)
    LD D,A
    INC HL
    LD A,($CA50)
    ADC A,(HL)
    LD C,A
    LD A,E
    SUB $40
    LD A,D
    SBC A,$42
    LD A,C
    SBC A,$0F
    LD HL,$000C
    JR NC,Lbl9_54FA
    LD A,($C8DF)
    LD L,A
    LD A,($C8E0)
    LD H,A
    LD A,($C8E1)
    LD E,A
    CALL $27F3
    LD A,($C8DF)
    LD L,A
    LD A,($C8E0)
    LD H,A
    LD A,($C8E1)
    LD E,A
    CALL $27FD
    CALL Fn9_53EC
    LD HL,$000D
Lbl9_54FA:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S1_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_4F6C
    CALL BattleAnim_VRAMFill
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    RET

SECTION "BattleAnim_P2S2_Disp", ROMX[$551C], BANK[9]
BattleAnim_P2S2_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P2S2_D0                     ; state 0
    DW BattleAnim_P2S2_D1                     ; state 1
    DW BattleAnim_P2S2_D2                     ; state 2
    DW BattleAnim_P2S2_D3                     ; state 3
    DW BattleAnim_P2S2_D4                     ; state 4
    DW BattleAnim_P2S2_D5                     ; state 5
    DW BattleAnim_P2S2_D6                     ; state 6
    DW BattleAnim_P2S2_D7                     ; state 7
    DW BattleAnim_P2S2_D8                     ; state 8

SECTION "BattleAnim_P2S2_States", ROMX[$5532], BANK[9]
BattleAnim_P2S2_D0:
    LD HL,$CA65
    LD B,$28
    CALL Fn9_51F5
    LD A,C
    OR A
    LD HL,$0011
    JR Z,Lbl9_555A
    LD HL,$CA51
    CALL Fn9_51F3
    LD A,C
    CP $14
    LD HL,$0012
    JR NC,Lbl9_555A
    LD HL,$C906
    INC (HL)
    LD HL,$0010
    CALL Fn9_45D3
    RET
Lbl9_555A:
    CALL Fn9_45D3
    LD A,$08
    LD ($C906),A
    RET
BattleAnim_P2S2_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_559B
    CALL Fn9_51E8
    CALL Fn9_47D0
    CALL Fn9_5579
    LD HL,$C906
    INC (HL)
    RET
Fn9_5579:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD DE,$6E6C
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$5655
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    CALL BattleAnim_VRAMFill
    RET
Fn9_559B:
    CALL Fn9_5AED
    LD HL,$D665
    LD BC,$0030
    XOR A
    CALL $169A
    LD HL,$C0D8
    LD BC,$0028
    XOR A
    CALL $169A
    LD DE,$CA65
    LD B,$28
Lbl9_55B7:
    LD A,(DE)
    OR A
    JR Z,Lbl9_55CD
    CP $FF
    JR Z,Lbl9_55CD
    INC DE
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    INC (HL)
    DEC B
    JR NZ,Lbl9_55B7
Lbl9_55CD:
    LD HL,$D666
    LD DE,$C0D8
    LD B,$2F
    LD C,$01
Lbl9_55D7:
    LD A,(HL+)
    OR A
    JR Z,Lbl9_55DE
    LD A,C
    LD (DE),A
    INC DE
Lbl9_55DE:
    INC C
    DEC B
    JR NZ,Lbl9_55D7
    RET
BattleAnim_P2S2_D2:
    LD DE,$5655
    LD HL,$C8E2
    LD A,($C8E9)
    LD C,A
    LD B,$04
    INC HL
    LD A,(HL-)
    PUSH AF
    LD A,(HL)
    PUSH AF
    CALL Fn9_4256
    POP AF
    LD HL,$C8E2
    AND $7F
    LD B,A
    LD A,(HL)
    AND $7F
    CP B
    JR Z,Lbl9_5604
Lbl9_5604:
    POP AF
    LD HL,$C8E3
    CP (HL)
    JR Z,Lbl9_560E
    CALL Fn9_47D0
Lbl9_560E:
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_563E
    LD A,$02
    LD ($C822),A
    LD A,$0C
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    CALL BattleAnim_VRAMFill
    LD HL,$000E
    CALL Fn9_45D3
    LD A,$04
    LD ($C905),A
    JR Fn9_5654
Lbl9_563E:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5654
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
    LD A,$01
    LD ($C8DE),A
Fn9_5654:
    RET
; data $5655-$5660
    DB $72, $01, $89, $00, $C9, $00, $09, $01, $49, $01, $FF, $FF
BattleAnim_P2S2_D3:
    LD HL,$0013
    CALL Fn9_45D3
    LD A,$01
    LD ($C8DD),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S2_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_567E
    LD HL,$C906
    INC (HL)
    RET
Fn9_567E:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD DE,$6E6C
    CALL BattleAnim_StreamSimple
    LD DE,$5655
    LD B,$04
    LD A,($C8E9)
    LD C,A
    LD HL,$C8E2
    CALL Fn9_44ED
    LD DE,$6D5D
    CALL BattleAnim_StreamSimple
    LD HL,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DA5E),A
    LD HL,$D665
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$00
    LD HL,$0164
    CALL BattleAnim_ColumnAdvSimple
    CALL $2451
    CALL BattleAnim_LoadSpriteData
    LD DE,$572C
    LD HL,$C8DD
    LD B,$02
    LD A,(HL)
    CALL Fn9_455B
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P2S2_D5:
    LD DE,$572C
    LD HL,$D665
    LD A,($DA5E)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$02
    LD HL,$C8DD
    CALL BattleAnim_SlotScanB
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_571A
    CALL Fn9_5579
    LD HL,$0010
    CALL Fn9_45D3
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_572B
Lbl9_571A:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_572B
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_572B:
    RET
; data $572C-$5731
    DB $61, $01, $62, $01, $FF, $FF
BattleAnim_P2S2_D6:
    LD HL,$CA51
    CALL Fn9_51F3
    LD A,($C8DE)
    ADD A,C
    CP $15
    LD HL,$0014
    JR NC,Lbl9_5756
    LD A,($C8DE)
    LD B,A
Lbl9_5747:
    PUSH BC
    CALL Fn9_5B43
    LD HL,$0306
    RST $10
    POP BC
    DEC B
    JR NZ,Lbl9_5747
    LD HL,$0015
Lbl9_5756:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S2_D7:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C8DC
    LD BC,$0006
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD A,$00
    LD ($C906),A
    RET
BattleAnim_P2S2_D8:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    RET

SECTION "BattleAnim_P2S3_Disp", ROMX[$5790], BANK[9]
BattleAnim_P2S3_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P2S3_D0                     ; state 0
    DW BattleAnim_P2S3_D1                     ; state 1
    DW BattleAnim_P2S3_D2                     ; state 2
    DW BattleAnim_P2S3_D3                     ; state 3
    DW BattleAnim_P2S3_D4                     ; state 4

SECTION "BattleAnim_P2S3_States", ROMX[$579E], BANK[9]
BattleAnim_P2S3_D0:
    LD HL,$CA4E
    LD A,(HL+)
    OR (HL)
    INC HL
    OR (HL)
    JR NZ,Lbl9_57B3
    LD HL,$000F
    CALL Fn9_45D3
    LD A,$04
    LD ($C906),A
    RET
Lbl9_57B3:
    LD HL,$0016
    CALL Fn9_45D3
    LD A,$02
    LD ($C8DC),A
    LD A,$00
    LD ($C8DF),A
    LD A,$00
    LD ($C8E0),A
    LD A,$00
    LD ($C8E1),A
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S3_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_57DF
    LD HL,$C906
    INC (HL)
    RET
Fn9_57DF:
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    LD A,$02
    LD ($C822),A
    LD A,$55
    LD ($C823),A
    LD HL,$8A00
    LD DE,$0401
    CALL Fn9_412F
    LD DE,$6EE3
    CALL BattleAnim_StreamSimple
    LD DE,$6F00
    CALL BattleAnim_StreamSimple
    LD A,($CA4E)
    LDH ($FFD5),A
    LD A,($CA4F)
    LDH ($FFD6),A
    LD A,($CA50)
    LDH ($FFD7),A
    LD HL,$016D
    CALL BattleAnim_ColumnAdvSimple
    CALL $2374
    CALL BattleAnim_LoadSpriteData
    LD DE,$5885
    LD HL,$C8DC
    LD B,$02
    LD A,(HL)
    CALL Fn9_5A6A
    CALL BattleAnim_VRAMFill
    RET
BattleAnim_P2S3_D2:
    LD DE,$5885
    LD HL,$C8DC
    LD B,$03
    CALL Fn9_590F
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_586A
    LD A,$02
    LD ($C822),A
    LD A,$0C
    LD ($C823),A
    LD HL,$8A40
    LD DE,$0C01
    CALL Fn9_412F
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_504C
    CALL BattleAnim_VRAMFill
    LD HL,$000E
    CALL Fn9_45D3
    LD A,$04
    LD ($C905),A
    JR Fn9_5884
Lbl9_586A:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5884
    LD HL,$C8DF
    LD A,(HL+)
    OR (HL)
    INC HL
    OR (HL)
    JR Z,Fn9_5884
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
Fn9_5884:
    RET
; data $5885-$5890
    DB $8E, $00, $8F, $00, $90, $00, $91, $00, $92, $00, $FF, $FF
BattleAnim_P2S3_D3:
    LD HL,$C8DF
    LD A,($CA4E)
    SUB (HL)
    INC HL
    LD A,($CA4F)
    SBC A,(HL)
    INC HL
    LD A,($CA50)
    SBC A,(HL)
    LD HL,$0017
    JR C,Lbl9_58ED
    LD HL,$C8DF
    LD A,($CA4B)
    ADD A,(HL)
    LD E,A
    INC HL
    LD A,($CA4C)
    ADC A,(HL)
    LD D,A
    INC HL
    LD A,($CA4D)
    ADC A,(HL)
    LD C,A
    LD A,E
    SUB $A0
    LD A,D
    SBC A,$86
    LD A,C
    SBC A,$01
    LD HL,$0018
    JR NC,Lbl9_58ED
    LD A,($C8DF)
    LD L,A
    LD A,($C8E0)
    LD H,A
    LD A,($C8E1)
    LD E,A
    CALL $2807
    LD A,($C8DF)
    LD L,A
    LD A,($C8E0)
    LD H,A
    LD A,($C8E1)
    LD E,A
    CALL $27E9
    CALL Fn9_57DF
    LD HL,$0019
Lbl9_58ED:
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P2S3_D4:
    LD A,($C825)
    OR A
    RET NZ
    CALL BattleAnim_CopyToVRAM
    CALL Fn9_4F6C
    CALL BattleAnim_VRAMFill
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C905),A
    RET
Fn9_590F:
    RES 7,(HL)
    PUSH DE
    LD A,($C847)
    BIT 7,A
    JR Z,Lbl9_5923
    LD A,$10
    LD ($C90C),A
    CALL Fn9_5968
    JR Lbl9_5957
Lbl9_5923:
    LD A,($C847)
    BIT 6,A
    JR Z,Lbl9_5934
    LD A,$10
    LD ($C90C),A
    CALL Fn9_5A33
    JR Lbl9_5957
Lbl9_5934:
    LD A,($C847)
    BIT 5,A
    JR Z,Lbl9_5944
    LD A,(HL)
    DEC A
    CP B
    JR C,Lbl9_5952
    DEC B
    LD A,B
    JR Lbl9_5952
Lbl9_5944:
    LD A,($C847)
    BIT 4,A
    JR Z,Lbl9_5959
    LD A,(HL)
    INC A
    CP B
    JR C,Lbl9_5952
    LD A,$00
Lbl9_5952:
    LD (HL),A
    XOR A
    LD ($C90C),A
Lbl9_5957:
    PUSH HL
    POP HL
Lbl9_5959:
    LD A,($C847)
    BIT 0,A
    JR Z,Lbl9_5962
    SET 7,(HL)
Lbl9_5962:
    POP DE
    LD A,(HL)
    CALL Fn9_5A6A
    RET
Fn9_5968:
    PUSH DE
    LD A,(HL)
    PUSH HL
    LD A,($C8DF)
    LDH ($FFD5),A
    LD A,($C8E0)
    LDH ($FFD6),A
    LD A,($C8E1)
    LDH ($FFD7),A
    LD HL,$C0A0
    CALL $23C7
    POP HL
    LD A,(HL)
    LD DE,$C0A0
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    AND $0F
    DEC A
    LD (DE),A
    CP $FF
    JR NZ,Lbl9_5997
    LD A,$09
    LD (DE),A
Lbl9_5997:
    CALL Fn9_599C
    POP DE
    RET
Fn9_599C:
    PUSH HL
    LD BC,$2710
    LD A,($C0A0)
    AND $0F
    CALL $21B5
    LD A,L
    LD ($C8DF),A
    LD A,H
    LD ($C8E0),A
    LD A,E
    LD ($C8E1),A
    LD BC,$03E8
    LD A,($C0A1)
    AND $0F
    CALL $21B5
    LD A,($C8DF)
    ADD A,L
    LD ($C8DF),A
    LD A,($C8E0)
    ADC A,H
    LD ($C8E0),A
    LD A,($C8E1)
    ADC A,E
    LD ($C8E1),A
    LD BC,$0064
    LD A,($C0A2)
    AND $0F
    CALL $21B5
    LD A,($C8DF)
    ADD A,L
    LD ($C8DF),A
    LD A,($C8E0)
    ADC A,H
    LD ($C8E0),A
    LD A,($C8E1)
    ADC A,E
    LD ($C8E1),A
    LD BC,$000A
    LD A,($C0A3)
    AND $0F
    CALL $21B5
    LD A,($C8DF)
    ADD A,L
    LD ($C8DF),A
    LD A,($C8E0)
    ADC A,H
    LD ($C8E0),A
    LD A,($C8E1)
    ADC A,E
    LD ($C8E1),A
    LD A,($C0A4)
    AND $0F
    LD L,A
    LD A,($C8DF)
    ADD A,L
    LD ($C8DF),A
    LD A,($C8E0)
    ADC A,$00
    LD ($C8E0),A
    LD A,($C8E1)
    ADC A,$00
    LD ($C8E1),A
    POP HL
    RET
Fn9_5A33:
    PUSH DE
    LD A,(HL)
    PUSH HL
    LD A,($C8DF)
    LDH ($FFD5),A
    LD A,($C8E0)
    LDH ($FFD6),A
    LD A,($C8E1)
    LDH ($FFD7),A
    LD HL,$C0A0
    CALL $23C7
    POP HL
    LD DE,$C0A1
    LD A,(HL)
    LD DE,$C0A0
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    AND $0F
    INC A
    LD (DE),A
    CP $0A
    JR NZ,Lbl9_5A65
    LD A,$00
    LD (DE),A
Lbl9_5A65:
    CALL Fn9_599C
    POP DE
    RET
Fn9_5A6A:
    LD C,A
    PUSH DE
    PUSH BC
    LD A,($C8DF)
    LDH ($FFD5),A
    LD A,($C8E0)
    LDH ($FFD6),A
    LD A,($C8E1)
    LDH ($FFD7),A
    LD HL,$C0A0
    CALL $23C7
    POP BC
    POP DE
    BIT 7,C
    JR NZ,Lbl9_5A98
    LD A,($C90C)
    AND $0F
    PUSH AF
    LD A,($C90C)
    INC A
    LD ($C90C),A
    POP AF
    LD A,C
    RET NZ
Lbl9_5A98:
    LD C,A
    LD B,$00
Lbl9_5A9B:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,C
    AND $7F
    CP B
    LD A,$E0
    JR NZ,Lbl9_5AC5
    LD A,($C90C)
    BIT 4,A
    LD A,$E0
    JR NZ,Lbl9_5AC5
    LD A,$E6
Lbl9_5AC5:
    CP $E0
    JR NZ,Lbl9_5AD6
    PUSH HL
    LD A,B
    LD HL,$C0A0
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
Lbl9_5AD6:
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    INC B
    JR Lbl9_5A9B
Fn9_5AED:
    LD HL,$D665
    LD DE,$CA65
    LD B,$28
Lbl9_5AF5:
    LD A,(DE)
    LD (HL+),A
    INC DE
    DEC B
    JR NZ,Lbl9_5AF5
    LD HL,$CA65
    LD BC,$0028
    LD A,$FF
    CALL $169A
    LD HL,$D665
    LD DE,$CA65
    LD B,$28
Lbl9_5B0E:
    LD A,(HL+)
    CP $FF
    JR Z,Lbl9_5B19
    CP $00
    JR Z,Lbl9_5B19
    LD (DE),A
    INC DE
Lbl9_5B19:
    DEC B
    JR NZ,Lbl9_5B0E
    RET
Fn9_5B1D:
    LD A,($DA5E)
    CP $00
    RET Z
    CP $FF
    RET Z
    LD HL,$CA65
    LD B,$28
Lbl9_5B2B:
    LD A,(HL)
    CP $00
    JR Z,Lbl9_5B3E
    CP $FF
    JR Z,Lbl9_5B3E
    INC HL
    DEC B
    JR NZ,Lbl9_5B2B
    LD A,$FF
    LD ($DA5E),A
    RET
Lbl9_5B3E:
    LD A,($DA5E)
    LD (HL),A
    RET
Fn9_5B43:
    LD A,($DA5E)
    CP $00
    RET Z
    CP $FF
    RET Z
    LD HL,$CA65
    LD B,$28
Lbl9_5B51:
    LD A,($DA5E)
    CP (HL)
    JR Z,Lbl9_5B61
    INC HL
    DEC B
    JR NZ,Lbl9_5B51
    LD A,$FF
    LD ($DA5E),A
    RET
Lbl9_5B61:
    LD (HL),$FF
    CALL Fn9_5AED
    RET

SECTION "BattleAnim_Phase4", ROMX[$5B67], BANK[9]
BattleAnim_Phase4:
    LD A,($C905)
    RST $00
    DW BattleAnim_P4S0                        ; state 0
    DW BattleAnim_P4S1                        ; state 1
    DW BattleAnim_P4S2                        ; state 2
    DW BattleAnim_P4S3                        ; state 3
    DW BattleAnim_P4S4                        ; state 4

SECTION "BattleAnim_P4S0_States", ROMX[$5B75], BANK[9]
BattleAnim_P4S0:
    LD HL,$FFB7
    CALL BattleAnim_TileWriteInc
    LD HL,$FFBB
    CALL BattleAnim_TileWriteInc
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LDH A,($FFBB)
    LD L,A
    LD H,$00
    ADD HL,HL
    ADD HL,HL
    LDH A,($FFB7)
    RRCA
    RRCA
    RRCA
    ADD A,L
    LD L,A
    LD A,H
    ADC A,$98
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LD ($C909),A
    LD A,H
    LD ($C90A),A
    CALL BattleAnim_CopyToVRAM
    LD DE,$2E11
    LD HL,$8800
    CALL $194A
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P4S1:
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P4S2:
    LD HL,$C905
    INC (HL)
    XOR A
    LD ($C906),A
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD HL,$C8E2
    LD BC,$0008
    LD A,$00
    CALL $169A
    LD A,($CAB4)
    AND $03
    LD ($C8E2),A
    LD A,($CAB4)
    CP $04
    RET C
    LD A,$01
    LD ($C8E3),A
    RET
BattleAnim_P4S3:
    JP BattleAnim_P4S0_Disp
BattleAnim_P4S4:
    CALL BattleAnim_CopyToVRAM
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_VRAMFill
    LD HL,$C8EB
    RES 4,(HL)
    XOR A
    LD ($C905),A
    RET

SECTION "BattleAnim_P4S0_Disp", ROMX[$5C0D], BANK[9]
BattleAnim_P4S0_Disp:
    LD A,($C906)
    RST $00
    DW BattleAnim_P4S0_D0                     ; state 0
    DW BattleAnim_P4S0_D1                     ; state 1
    DW BattleAnim_P4S0_D2                     ; state 2
    DW BattleAnim_P4S0_D3                     ; state 3
    DW BattleAnim_P4S0_D4                     ; state 4
    DW BattleAnim_P4S0_D5                     ; state 5
    DW BattleAnim_P4S0_D6                     ; state 6
    DW BattleAnim_P4S0_D7                     ; state 7
    DW BattleAnim_P4S0_D8                     ; state 8

SECTION "BattleAnim_P4S0_SubStates", ROMX[$5C23], BANK[9]
BattleAnim_P4S0_D0:
    CALL Fn9_5C2B
    LD HL,$C906
    INC (HL)
    RET
Fn9_5C2B:
    LD HL,$C0D8
    LD BC,$0008
    LD A,$90
    CALL $169A
    LD A,($CAB4)
    OR A
    RET Z
    LD B,A
    LD HL,$C0D8
Lbl9_5C3F:
    LD (HL),$AC
    INC HL
    DEC B
    JR NZ,Lbl9_5C3F
    RET
BattleAnim_P4S0_D1:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_5C9A
    CALL Fn9_5C56
    LD HL,$C906
    INC (HL)
    RET
Fn9_5C56:
    CALL BattleAnim_CopyToVRAM
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    LD DE,$719C
    CALL BattleAnim_StreamSimple
    LD DE,$6C38
    CALL BattleAnim_StreamSimple
    CALL Fn9_5CE3
    LD A,($CA4B)
    LDH ($FFD5),A
    LD A,($CA4C)
    LDH ($FFD6),A
    LD A,($CA4D)
    LDH ($FFD7),A
    LD HL,$002E
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    CALL BattleAnim_LoadSpriteData
    LD DE,$5DA5
    LD B,$04
    LD C,$04
    LD HL,$C8E2
    CALL Fn9_44ED
    CALL BattleAnim_VRAMFill
    RET
Fn9_5C9A:
    LD DE,$5D1E
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$8800
    CALL Fn9_5CD1
    CALL Fn9_5CD1
    CALL Fn9_5CD1
    CALL Fn9_5CD1
    LD DE,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$8840
    CALL Fn9_5CD1
    CALL Fn9_5CD1
    CALL Fn9_5CD1
Fn9_5CD1:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CALL Fn9_41B6
    POP HL
    LD A,L
    ADD A,$10
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_5CE3:
    LD DE,$5D26
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$00A8
    CALL Fn9_5CFE
    CALL Fn9_5CFE
    CALL Fn9_5CFE
Fn9_5CFE:
    PUSH DE
    PUSH HL
    LD A,(DE)
    LDH ($FFD5),A
    INC DE
    LD A,(DE)
    LDH ($FFD6),A
    LD A,$00
    LDH ($FFD7),A
    CALL BattleAnim_ColumnAdvSimple
    CALL $2388
    POP HL
    LD A,L
    ADD A,$40
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    INC DE
    RET
; data $5D1E-$5D35
    DB $10, $0F, $0E, $0D, $0C, $0B, $0A, $1C, $00, $00, $0A, $00, $32, $00, $64, $00
    DB $F4, $01, $E8, $03, $88, $13, $10, $27
BattleAnim_P4S0_D2:
    LD DE,$5DA7
    LD HL,$C8E2
    LD B,$04
    INC HL
    LD A,(HL-)
    PUSH AF
    CALL Fn9_42DF
    POP AF
    LD HL,$C8E3
    CP (HL)
    JR Z,Lbl9_5D54
    CALL Fn9_5C9A
    CALL Fn9_5CE3
    CALL BattleAnim_VRAMFill
Lbl9_5D54:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5D93
    LD HL,$C0D8
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $90
    JP Z,Fn9_5D84
    LD HL,$0006
    CALL Fn9_45D3
    LD A,$08
    LD ($C906),A
    JR Fn9_5DA4
Fn9_5D84:
    LD A,$59
    CALL $1EFF
    LD HL,$C906
    INC (HL)
    XOR A
    LD ($C8DE),A
    JR Fn9_5DA4
Fn9_5D93:
    LD A,($C846)
    BIT 1,A
    JP Z,Fn9_5DA4
    LD A,$FF
    LD ($D9CD),A
    LD HL,$C905
    INC (HL)
Fn9_5DA4:
    RET
; data $5DA5-$5DB0
    DB $8C, $01, $A2, $00, $E2, $00, $22, $01, $62, $01, $FF, $FF
BattleAnim_P4S0_D3:
    LD HL,$5D26
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($CA4B)
    SUB (HL)
    INC HL
    LD A,($CA4C)
    SBC A,(HL)
    INC HL
    LD A,($CA4D)
    SBC A,$00
    JR NC,Lbl9_5DE4
    LD HL,$0005
    CALL Fn9_45D3
    LD A,$08
    LD ($C906),A
    RET
Lbl9_5DE4:
    LD DE,$5D1E
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD ($C180),A
    LD A,$F0
    LD ($C181),A
    LD HL,$0004
    CALL Fn9_45D3
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P4S0_D4:
    LD A,($C825)
    OR A
    RET NZ
    LD A,$5C
    CALL $1EFF
    LD DE,$6C13
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$5EA4
    LD A,($C8DE)
    CALL Fn9_451E
    CALL BattleAnim_VRAMFill
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P4S0_D5:
    LD DE,$5EA4
    LD HL,$C8DE
    LD B,$02
    CALL Fn9_42DF
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_5E5E
Lbl9_5E43:
    CALL Fn9_5C56
    LD HL,$0001
    CALL Fn9_45D3
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    LD HL,$C906
    DEC (HL)
    JR Fn9_5EA3
Lbl9_5E5E:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_5EA3
    LD A,$59
    CALL $1EFF
    LD A,($C8DE)
    CP $81
    JR Z,Lbl9_5E43
    LD HL,$5D26
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD E,$00
    CALL $27F3
    LD A,($C8E3)
    ADD A,A
    ADD A,A
    LD B,A
    LD A,($C8E2)
    AND $7F
    ADD A,B
    LD ($D9CE),A
    LD HL,$C906
    INC (HL)
Fn9_5EA3:
    RET
; data $5EA4-$5EA9
    DB $2F, $01, $6F, $01, $FF, $FF
BattleAnim_P4S0_D6:
    LD HL,$C906
    INC (HL)
    RET
BattleAnim_P4S0_D7:
    LD A,($C825)
    OR A
    RET NZ
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P4S0_D8:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_5C56
    LD HL,$0001
    CALL Fn9_45D3
    LD A,$01
    LD ($C906),A
    RET

SECTION "BattleAnim_Phase13", ROMX[$5ECD], BANK[9]
BattleAnim_Phase13:
    LD A,($C905)
    RST $00
    DW BattleAnim_P13S0                       ; state 0
    DW BattleAnim_P13S1                       ; state 1
    DW BattleAnim_P13S2                       ; state 2
    DW BattleAnim_P13S3                       ; state 3

SECTION "BattleAnim_Phase13_States", ROMX[$5ED9], BANK[9]
BattleAnim_P13S0:
    LD HL,$FFB7
    CALL BattleAnim_TileWriteInc
    LD HL,$FFBB
    CALL BattleAnim_TileWriteInc
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LDH A,($FFBB)
    LD L,A
    LD H,$00
    ADD HL,HL
    ADD HL,HL
    LDH A,($FFB7)
    RRCA
    RRCA
    RRCA
    ADD A,L
    LD L,A
    LD A,H
    ADC A,$98
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LD ($C909),A
    LD A,H
    LD ($C90A),A
    CALL BattleAnim_CopyC0C8
    CALL BattleAnim_VRAMFill
    CALL BattleAnim_LoadSpriteData
    LD A,$01
    LD ($C8EC),A
    LD HL,$C905
    INC (HL)
    RET
BattleAnim_P13S1:
    LD HL,$C905
    INC (HL)
    CALL BattleAnim_CopyC0C8
    CALL Fn9_600F
    CALL Fn9_5F4C
    CALL Fn9_5F37
    CALL BattleAnim_VRAMFill
    RET
Fn9_5F37:
    LD DE,$76C4
    CALL BattleAnim_StreamSimple
    LD A,($C8E9)
    CP $09
    RET C
    LD HL,$0212
    CALL BattleAnim_ColumnAdvSimple
    LD (HL),$E7
    RET
Fn9_5F4C:
    LD DE,$C0D8
    LD A,($C8DB)
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$9380
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    CALL Fn9_5FA1
    LD DE,$C0D8
    LD A,($C8DB)
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD HL,$8880
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    CALL Fn9_5FC6
    RET
Fn9_5FA1:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CP $FF
    JR NZ,Lbl9_5FAA
    LD A,$10
Lbl9_5FAA:
    ADD A,$5F
    LD ($C823),A
    LD A,$02
    LD ($C822),A
    LD DE,$0901
    CALL Fn9_412F
    POP HL
    LD A,L
    ADD A,$90
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_5FC6:
    PUSH DE
    PUSH HL
    LD A,(DE)
    CP $FF
    LD A,$E0
    JR Z,Lbl9_5FF5
    LD A,(DE)
    PUSH DE
    LD DE,$6040
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    PUSH BC
    LD A,(DE)
    LD C,A
    LD B,$00
    PUSH HL
    CALL $2A7D
    POP HL
    POP BC
    POP DE
    LD A,$E0
    JR Z,Lbl9_5FF5
    LD A,(DE)
    LD DE,$6050
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
Lbl9_5FF5:
    LD ($C823),A
    LD A,$05
    LD ($C822),A
    LD DE,$0901
    CALL Fn9_412F
    POP HL
    LD A,L
    ADD A,$90
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    POP DE
    INC DE
    RET
Fn9_600F:
    LD HL,$C0D8
    LD BC,$0010
    LD A,$FF
    CALL $169A
    LD HL,$C0D8
    LD DE,$6060
    LD B,$00
Lbl9_6022:
    PUSH BC
    PUSH DE
    PUSH HL
    LD A,(DE)
    LD C,A
    LD B,$00
    CALL $2A7D
    POP HL
    POP DE
    POP BC
    JR Z,Lbl9_6034
    LD (HL),B
    INC HL
    INC C
Lbl9_6034:
    INC DE
    INC B
    LD A,B
    CP $10
    JR NZ,Lbl9_6022
    LD A,C
    LD ($C8E9),A
    RET
; data $6040-$606F
    DB $10, $11, $12, $13, $14, $16, $17, $19, $1D, $1C, $1A, $1F, $20, $22, $23, $25
    DB $09, $1C, $C4, $44, $66, $0A, $45, $C5, $2A, $58, $2B, $99, $AD, $43, $94, $9A
    DB $00, $30, $30, $31, $31, $32, $32, $33, $33, $34, $34, $35, $35, $36, $36, $37
BattleAnim_P13S2:
    LD DE,$60B4
    LD HL,$C8DA
    LD C,$01
    LD A,($C8E9)
    CP $09
    JR C,Lbl9_6081
    LD C,$02
Lbl9_6081:
    LD B,$01
    LD A,($C8DB)
    PUSH AF
    CALL Fn9_4256
    POP AF
    LD HL,$C8DB
    CP (HL)
    JR Z,Lbl9_6094
    CALL Fn9_5F4C
Lbl9_6094:
    LD A,($C846)
    AND $0A
    JR Z,Lbl9_60A1
    LD HL,$C905
    INC (HL)
    JR Lbl9_60B3
Lbl9_60A1:
    LD A,($C846)
    BIT 0,A
    JR Z,Lbl9_60B3
    LD A,$59
    CALL $1EFF
    LD HL,$C905
    INC (HL)
    JR Lbl9_60B3
Lbl9_60B3:
    RET
; data $60B4-$60BB
    DB $12, $02, $FF, $FF, $FF, $FF, $FF, $FF
BattleAnim_P13S3:
    CALL BattleAnim_CopyC0C8
    CALL BattleAnim_VRAMFill
    LD HL,$0B01
    RST $10
    LD HL,$0B02
    RST $10
    CALL $28E7
    CALL $29C0
    LD HL,$0604
    RST $10
    XOR A
    LD ($C8EC),A
    LD HL,$C8EB
    RES 4,(HL)
    XOR A
    LD ($C905),A
    RET

; ============================================================================
; Bank9 fn1 = BattleView ($60E2) — BATTLE presentation/turn viewer.
; ----------------------------------------------------------------------------
; Reached from fn0 state 15, and directly from bank6 fn6 when $C8EB bit7 is set.
; Inner state = $C905 (11 states). For states 2..8 it first rebuilds the active
; monster's on-screen SPRITE by filling the OAM metasprite params in HRAM
; ($FFC3-$FFCA) and calling bank4 fn3 (the OAM composer, Sub_40CD) — see
; overworld/bank4.asm. Params: hXBase=$19, hYBase=$21, hIdxA=$C8F4 (scroll/
; frame), hIdxB=0/1 (blink via $C8A4 bit4), hTileBase=$50, hAttrXor=0.
; ============================================================================
SECTION "BattleView", ROMX[$60E2], BANK[9]
BattleView:
    LD A,($C905)                             ; $60E2 [FA 05 C9]  ; inner state
    CP $09                                    ; $60E5 [FE 09]      ; state >= 9?
    JR NC,Lbl9_6117                           ; $60E7 [30 2E]      ; yes -> skip sprite rebuild
    CP $02                                    ; $60E9 [FE 02]      ; state < 2?
    JR C,Lbl9_6117                            ; $60EB [38 2A]      ; yes -> skip sprite rebuild
    ; --- rebuild active monster sprite (states 2..8) via bank4 fn3 OAM composer ---
    LD HL,$FFC3                               ; $60ED [21 C3 FF]  ; HL = hXBase (OAM param block)
    LD A,$19                                  ; $60F0 [3E 19]
    LD (HL+),A                                ; $60F2 [22]         ; hXBase   $FFC3 = $19
    LD A,$00                                  ; $60F3 [3E 00]
    LD (HL+),A                                ; $60F5 [22]         ; $FFC4 = 0
    LD A,$21                                  ; $60F6 [3E 21]
    LD (HL+),A                                ; $60F8 [22]         ; hYBase   $FFC5 = $21
    LD A,$00                                  ; $60F9 [3E 00]
    LD (HL+),A                                ; $60FB [22]         ; $FFC6 = 0
    LD A,($C8F4)                              ; $60FC [FA F4 C8]  ; battle scroll/frame param
    LD (HL+),A                                ; $60FF [22]         ; hIdxA    $FFC7 = $C8F4
    LD B,$00                                  ; $6100 [06 00]
    LD A,($C8A4)                              ; $6102 [FA A4 C8]  ; global frame counter
    BIT 4,A                                   ; $6105 [CB 67]      ; bit4 = blink phase
    JR Z,Lbl9_610B                            ; $6107 [28 02]
    LD B,$01                                  ; $6109 [06 01]      ; alternate sprite frame
Lbl9_610B:
    LD A,B                                    ; $610B [78]
    LD (HL+),A                                ; $610C [22]         ; hIdxB    $FFC8 = 0/1 (blink)
    LD A,$50                                  ; $610D [3E 50]
    LD (HL+),A                                ; $610F [22]         ; hTileBase $FFC9 = $50
    LD A,$00                                  ; $6110 [3E 00]
    LD (HL),A                                 ; $6112 [77]         ; hAttrXor  $FFCA = 0
    LD HL,$0403                               ; $6113 [21 03 04]
    RST $10                                   ; $6116 [D7]         ; bankcall -> bank4 fn3 (compose OAM metasprite)
Lbl9_6117:
    LD A,($C905)                             ; $6117 [FA 05 C9]  ; inner state
    RST $00                                   ; $611A [C7]         ; dispatch via 11-entry dw table
    DW BattleView_S0                          ; $611B [36 61]  state 0  ($6136)
    DW BattleView_S1                          ; $611D [3F 61]  state 1  ($613F)
    DW BattleView_S2                          ; $611F [2C 62]  state 2  ($622C)
    DW BattleView_S3                          ; $6121 [BE 62]  state 3  ($62BE)
    DW BattleView_S4                          ; $6123 [86 65]  state 4  ($6586)
    DW BattleView_S5                          ; $6125 [C0 65]  state 5  ($65C0)
    DW BattleView_S6                          ; $6127 [D5 65]  state 6  ($65D5)
    DW BattleView_S7                          ; $6129 [39 66]  state 7  ($6639)
    DW BattleView_S8                          ; $612B [5D 66]  state 8  ($665D)
    DW BattleView_IncrState                   ; $612D [31 61]  state 9  ($6131) advance & wait
    DW BattleView_S10                         ; $612F [AB 66]  state 10 ($66AB)

SECTION "BattleView_States", ROMX[$6131], BANK[9]
BattleView_IncrState:
    LD HL,$C905
    INC (HL)
    RET
BattleView_S0:
    LD HL,$C905
    INC (HL)
    LD A,($C850)
    OR A
    RET Z
BattleView_S1:
    LD HL,$FFB7
    CALL BattleAnim_TileWriteInc
    LD HL,$FFBB
    CALL BattleAnim_TileWriteInc
    LD HL,$C0C8
    LD BC,$0010
    LD A,$9F
    CALL $169A
    CALL Fn9_61E1
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A
    LDH A,($FFBB)
    LD L,A
    LD H,$00
    ADD HL,HL
    ADD HL,HL
    LDH A,($FFB7)
    RRCA
    RRCA
    RRCA
    ADD A,L
    LD L,A
    LD A,H
    ADC A,$98
    LD H,A
    LD A,H
    AND $03
    OR $98
    LD H,A
    LD A,L
    LD ($C909),A
    LD A,H
    LD ($C90A),A
    LD HL,$01C0
    CALL BattleAnim_VRAMAddrSet
    CALL BattleAnim_ColumnAdvance
    LD A,L
    LD ($C83E),A
    LD A,H
    LD ($C83F),A
    CALL BattleAnim_CopyC0C8
    CALL BattleAnim_VRAMFill
    LD DE,$2E1E
    LD HL,$9000
    CALL $194A
    LD DE,$2E1F
    LD HL,$8800
    CALL $194A
    LD DE,$2E20
    LD HL,$8A00
    CALL $194A
    LD A,($C8F4)
    LD L,A
    LD H,$00
    ADD HL,HL
    LD A,L
    ADD A,$DA
    LD L,A
    LD A,H
    ADC A,$69
    LD H,A
    LD E,(HL)
    INC HL
    LD D,(HL)
    LD HL,$8500
    CALL $194A
    CALL BattleAnim_LoadSpriteData
    CALL Fn9_621F
    LD HL,$1702
    RST $10
    LD HL,$1708
    RST $10
    LD HL,$C905
    INC (HL)
    RET
Fn9_61E1:
    LD B,$08
    LD A,($C8F2)
    LD L,A
    LD A,($C8F3)
    LD H,A
    LD DE,$C0C8
    CALL Fn9_620F
    LD A,($C8F4)
    CP $00
    RET Z
    LD A,($C0C8)
    CP $9F
    RET NZ
    LD A,($C8F5)
    LD L,A
    LD H,$07
    LD DE,$C180
    CALL $0D67
    LD HL,$C180
    LD DE,$C0C8
Fn9_620F:
    LD A,(HL+)
    CP $00
    RET Z
    CP $F0
    RET Z
    CP $9F
    RET Z
    LD (DE),A
    INC DE
    DEC B
    JR NZ,Fn9_620F
    RET
Fn9_621F:
    LD DE,$C0C8
    LD HL,$9000
    CALL Fn9_4168
    CALL BattleView_AnimUpdate
    RET
BattleView_S2:
    LD HL,$C905
    INC (HL)
    CALL BattleAnim_CopyC0C8
    CALL Fn9_623D
    CALL BattleView_AnimUpdate
    CALL BattleAnim_VRAMFill
    RET
Fn9_623D:
    LD A,($C8F4)
    OR A
    JR Z,Lbl9_62A2
    LD A,($C8F6)
    AND $01
    ADD A,$A7
    LD ($C180),A
    LD A,$F0
    LD ($C181),A
    LD A,($C827)
    LD C,A
    LD A,($C828)
    LD B,A
    PUSH BC
    LD A,($C829)
    LD C,A
    LD A,($C82A)
    LD B,A
    PUSH BC
    LD HL,$8AF0
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD DE,$0101
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    LD A,$02
    LD ($C822),A
    LD A,$00
    LD ($C823),A
    LD HL,$4102
    RST $10
    POP DE
    POP HL
    LD A,L
    LD ($C827),A
    LD A,H
    LD ($C828),A
    LD A,E
    LD ($C829),A
    LD A,D
    LD ($C82A),A
    LD HL,$0064
    CALL BattleAnim_ColumnAdvSimple
    LD (HL),$AF
Lbl9_62A2:
    LD DE,$7AF6
    CALL BattleAnim_StreamSimple
    LD DE,$7B1C
    LD A,($C8DC)
    OR A
    JR NZ,Lbl9_62B4
    LD DE,$7C1A
Lbl9_62B4:
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    CALL BattleView_CursorScan
    RET
BattleView_S3:
    LD A,($C847)
    BIT 5,A
    JR Z,Lbl9_62D7
    LD A,($C8DA)
    DEC A
    LD ($C8DA),A
    CP $0F
    JR C,Lbl9_6323
    LD A,$0E
    LD ($C8DA),A
    JR Lbl9_6323
Lbl9_62D7:
    LD A,($C847)
    BIT 4,A
    JR Z,Lbl9_62F0
    LD A,($C8DA)
    INC A
    LD ($C8DA),A
    CP $0F
    JR C,Lbl9_6323
    LD A,$00
    LD ($C8DA),A
    JR Lbl9_6323
Lbl9_62F0:
    LD A,($C847)
    BIT 6,A
    JR Z,Lbl9_6309
    LD A,($C8DB)
    DEC A
    LD ($C8DB),A
    CP $05
    JR C,Lbl9_6323
    LD A,$04
    LD ($C8DB),A
    JR Lbl9_6323
Lbl9_6309:
    LD A,($C847)
    BIT 7,A
    JP Z,Fn9_63A6
    LD A,($C8DB)
    INC A
    LD ($C8DB),A
    CP $05
    JR C,Lbl9_6323
    LD A,$00
    LD ($C8DB),A
    JR Lbl9_6323
Lbl9_6323:
    XOR A
    LD ($C90C),A
    LD A,($C8DB)
    LD C,$0F
    CALL $218D
    LD A,($C8DA)
    ADD A,L
    CP $24
    JR NZ,Lbl9_634A
    LD A,$05
    LD ($C8DA),A
    LD A,($C847)
    BIT 4,A
    JR Z,Fn9_63A6
    LD A,$07
    LD ($C8DA),A
    JR Fn9_63A6
Lbl9_634A:
    CP $26
    JR NZ,Lbl9_6361
    LD A,$07
    LD ($C8DA),A
    LD A,($C847)
    BIT 4,A
    JR Z,Fn9_63A6
    LD A,$09
    LD ($C8DA),A
    JR Fn9_63A6
Lbl9_6361:
    CP $29
    JR Z,Lbl9_6393
    CP $2A
    JR Z,Lbl9_6393
    CP $2B
    JR Z,Lbl9_6393
    CP $2C
    JR Z,Lbl9_6393
    CP $38
    JR Z,Lbl9_6393
    CP $39
    JR Z,Lbl9_6393
    CP $3A
    JR Z,Lbl9_6393
    CP $3B
    JR Z,Lbl9_6393
    CP $47
    JR Z,Lbl9_6393
    CP $48
    JR Z,Lbl9_6393
    CP $49
    JR Z,Lbl9_6393
    CP $4A
    JR Z,Lbl9_6393
    JR Fn9_63A6
Lbl9_6393:
    LD A,$0A
    LD ($C8DA),A
    LD A,($C847)
    BIT 4,A
    JR Z,Fn9_63A6
    LD A,$00
    LD ($C8DA),A
    JR Fn9_63A6
Fn9_63A6:
    CALL BattleView_CursorScan
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_63D6
Lbl9_63B0:
    LD DE,$C0C8
    LD A,(DE)
    CP $9F
    JP Z,Fn9_64ED
Lbl9_63B9:
    INC DE
    LD A,(DE)
    CP $9F
    JR NZ,Lbl9_63B9
    DEC DE
    LD A,(DE)
    CP $8D
    JR Z,Lbl9_63C9
    CP $8E
    JR NZ,Lbl9_63CD
Lbl9_63C9:
    LD A,$9F
    LD (DE),A
    DEC DE
Lbl9_63CD:
    LD A,$9F
    LD (DE),A
    CALL Fn9_621F
    JP Fn9_64ED
Lbl9_63D6:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_64DA
    LD A,($C8DB)
    LD C,$0F
    CALL $218D
    LD A,($C8DA)
    ADD A,L
    CP $46
    JR NZ,Lbl9_63F5
    LD HL,$C905
    INC (HL)
    JP Fn9_64ED
Lbl9_63F5:
    CP $37
    JR Z,Lbl9_63B0
    CP $28
    JR NZ,Lbl9_640C
    LD A,($C8DC)
    XOR $01
    LD ($C8DC),A
    LD HL,$C905
    DEC (HL)
    JP Fn9_64ED
Lbl9_640C:
    LD HL,$64EE
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD A,L
    ADD A,$E0
    LD L,A
    LD A,H
    ADC A,$C4
    LD H,A
    PUSH HL
    CALL BattleView_FindFreeOAM
    POP HL
    LD A,C
    CP $04
    JR NZ,Lbl9_6441
    LD A,$0A
    LD ($C8DA),A
    LD A,$04
    LD ($C8DB),A
    LD A,(HL)
    CP $8D
    JR Z,Lbl9_644F
    CP $8E
    JR Z,Lbl9_644F
    JP Fn9_64ED
Lbl9_6441:
    OR A
    JR NZ,Lbl9_644F
    LD A,(HL)
    CP $8D
    JP Z,Fn9_64ED
    CP $8E
    JP Z,Fn9_64ED
Lbl9_644F:
    LD DE,$C0C8
Lbl9_6452:
    LD A,(DE)
    INC DE
    CP $9F
    JR NZ,Lbl9_6452
    DEC DE
    LD A,(HL)
    CP $8D
    JR Z,Lbl9_6462
    CP $8E
    JR NZ,Lbl9_6499
Lbl9_6462:
    DEC DE
    LD A,(DE)
    INC DE
    CP $8D
    JP Z,Fn9_64ED
    CP $8E
    JR Z,Fn9_64ED
    PUSH HL
    LD A,C
    LD HL,$C0D2
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    POP HL
    LD A,B
    CP $01
    JR Z,Lbl9_6499
    LD A,(HL)
    CP $8E
    JR Z,Fn9_64ED
    LD A,B
    CP $03
    JR Z,Lbl9_6499
    CP $06
    JR Z,Lbl9_6499
    CP $09
    JR Z,Lbl9_6499
    DEC DE
    LD A,(DE)
    INC DE
    CP $5A
    JR NZ,Fn9_64ED
Lbl9_6499:
    LD A,(HL)
    LD (DE),A
    CALL Fn9_621F
    LD A,$59
    CALL $1EFF
    CALL BattleView_FindFreeOAM
    LD A,C
    LD HL,$C0D2
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    LD A,($C8DB)
    LD C,$0F
    CALL $218D
    LD A,($C8DA)
    ADD A,L
    LD B,A
    LD A,$05
    CALL $21CA
    LD A,B
    POP HL
    LD (HL),A
    CALL BattleView_FindFreeOAM
    LD A,C
    CP $04
    JR NZ,Fn9_64ED
    LD A,$0A
    LD ($C8DA),A
    LD A,$04
    LD ($C8DB),A
    JR Fn9_64ED
Fn9_64DA:
    LD A,($C846)
    BIT 3,A
    JR Z,Fn9_64ED
    LD A,$0A
    LD ($C8DA),A
    LD A,$04
    LD ($C8DB),A
    JR Fn9_64ED
Fn9_64ED:
    RET
; data $64EE-$6585
    DB $E1, $00, $E2, $00, $E3, $00, $E4, $00, $E5, $00, $E7, $00, $E8, $00, $E9, $00
    DB $EA, $00, $EB, $00, $EE, $00, $EF, $00, $F0, $00, $F1, $00, $F2, $00, $21, $01
    DB $22, $01, $23, $01, $24, $01, $25, $01, $27, $01, $28, $01, $29, $01, $2A, $01
    DB $2B, $01, $2E, $01, $2F, $01, $30, $01, $31, $01, $32, $01, $61, $01, $62, $01
    DB $63, $01, $64, $01, $65, $01, $67, $01, $68, $01, $69, $01, $6A, $01, $6B, $01
    DB $6E, $01, $6F, $01, $70, $01, $71, $01, $72, $01, $A1, $01, $A2, $01, $A3, $01
    DB $A4, $01, $A5, $01, $A7, $01, $A8, $01, $A9, $01, $AA, $01, $AB, $01, $AE, $01
    DB $AF, $01, $B0, $01, $B1, $01, $B2, $01, $E1, $01, $E2, $01, $E3, $01, $E4, $01
    DB $E5, $01, $E7, $01, $E8, $01, $E9, $01, $EA, $01, $EB, $01, $EE, $01, $EF, $01
    DB $F0, $01, $F1, $01, $F2, $01, $FF, $FF
BattleView_S4:
    XOR A
    LD ($C90C),A
    CALL BattleView_CursorScan
    LD A,($C0C8)
    CP $9F
    JR NZ,Lbl9_659D
    CALL Fn9_675C
    CALL Fn9_67A7
    CALL Fn9_621F
Lbl9_659D:
    CALL Fn9_67BD
    JR C,Lbl9_65AC
    LD HL,$C905
    INC (HL)
    LD HL,$C905
    INC (HL)
    JR Lbl9_65BF
Lbl9_65AC:
    LD HL,$020A
    CALL $0D5A
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_VRAMFill
    LD HL,$C905
    INC (HL)
Lbl9_65BF:
    RET
BattleView_S5:
    LD A,($C825)
    OR A
    RET NZ
    CALL Fn9_621F
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    RET
BattleView_S6:
    LD A,($C8F4)
    CP $00
    JR Z,Lbl9_65FB
    LD A,($C8F5)
    LD L,A
    LD H,$05
    LD DE,$C190
    CALL $0D67
    LD HL,$C190
Lbl9_65EB:
    LD A,(HL+)
    CP $F0
    JR NZ,Lbl9_65EB
    DEC HL
    LD A,($C8F6)
    AND $01
    ADD A,$A7
    LD (HL+),A
    LD (HL),$F0
Lbl9_65FB:
    LD HL,$C180
    LD DE,$C0C8
    LD B,$08
Lbl9_6603:
    LD A,(DE)
    CP $9F
    JR Z,Lbl9_660D
    LD (HL+),A
    INC DE
    DEC B
    JR NZ,Lbl9_6603
Lbl9_660D:
    LD (HL),$F0
    LD HL,$0209
    LD A,($C8F4)
    CP $00
    JR Z,Lbl9_6624
    CALL Fn9_67F8
    LD HL,$0245
    JR C,Lbl9_6624
    LD HL,$020F
Lbl9_6624:
    CALL $0D5A
    LD DE,$31D6
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_VRAMFill
    LD HL,$C905
    INC (HL)
    XOR A
    LD ($C8DE),A
    RET
BattleView_S7:
    LD A,($C825)
    OR A
    RET NZ
    LD A,$5C
    CALL $1EFF
    LD DE,$6C13
    CALL BattleAnim_StreamSimple
    CALL BattleAnim_LoadSpriteData
    LD DE,$66A5
    LD A,($C8DE)
    CALL Fn9_451E
    CALL BattleAnim_VRAMFill
    LD HL,$C905
    INC (HL)
    RET
BattleView_S8:
    LD DE,$66A5
    LD HL,$C8DE
    LD B,$02
    CALL Fn9_42DF
    LD A,($C846)
    BIT 1,A
    JR Z,Lbl9_668C
Lbl9_666F:
    CALL Fn9_621F
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    LD HL,$C905
    DEC (HL)
    JR Fn9_66A4
Lbl9_668C:
    LD A,($C846)
    BIT 0,A
    JP Z,Fn9_66A4
    LD A,$59
    CALL $1EFF
    LD A,($C8DE)
    CP $81
    JR Z,Lbl9_666F
    LD HL,$C905
    INC (HL)
Fn9_66A4:
    RET
; data $66A5-$66AA
    DB $2F, $01, $6F, $01, $FF, $FF
BattleView_S10:
    LD A,($C8F2)
    LD L,A
    LD A,($C8F3)
    LD H,A
    LD BC,$0008
    LD A,$F0
    CALL $169A
    LD A,($C8F2)
    LD L,A
    LD A,($C8F3)
    LD H,A
    LD DE,$C0C8
    LD B,$08
Lbl9_66C8:
    LD A,(DE)
    CP $9F
    JR Z,Lbl9_66D2
    LD (HL+),A
    INC DE
    DEC B
    JR NZ,Lbl9_66C8
Lbl9_66D2:
    LD HL,$C8EB
    BIT 7,(HL)
    JR NZ,Lbl9_66E0
    LD A,($C8EF)
    CP $FF
    JR Z,Lbl9_6748
Lbl9_66E0:
    CALL BattleAnim_CopyC0C8
    CALL BattleAnim_VRAMFill
    LD HL,$0B01
    RST $10
    LD HL,$0B02
    RST $10
    CALL $28E7
    CALL $29C0
    LD A,($C969)
    OR A
    JR NZ,Lbl9_6700
    LD HL,$0604
    RST $10
    JR Lbl9_6748
Lbl9_6700:
    LD DE,$2E15
    LD HL,$8500
    CALL $194A
    LD DE,$2E16
    LD HL,$8540
    CALL $194A
    LD DE,$2E17
    LD HL,$8580
    CALL $194A
    LD DE,$2E18
    LD HL,$85C0
    CALL $194A
    LD DE,$2E19
    LD HL,$8600
    CALL $194A
    LD DE,$2E1A
    LD HL,$8640
    CALL $194A
    LD DE,$2E1B
    LD HL,$8680
    CALL $194A
    LD DE,$2E1C
    LD HL,$86C0
    CALL $194A
Lbl9_6748:
    LD HL,$C8EB
    BIT 7,(HL)
    JR NZ,Lbl9_6756
    RES 4,(HL)
    XOR A
    LD ($C905),A
    RET
Lbl9_6756:
    LD HL,$C8EB
    RES 7,(HL)
    RET
Fn9_675C:
    LD A,($C8F4)
    CP $00
    JR NZ,Lbl9_6778
    LD A,$6E
    LD ($C0C8),A
    LD A,$86
    LD ($C0C9),A
    LD A,$9C
    LD ($C0CA),A
    LD A,$F0
    LD ($C0CB),A
    RET
Lbl9_6778:
    CALL $16A3
    LD A,($C8F4)
    SUB $10
    LD ($DA31),A
    LD HL,$0301
    RST $10
    LD A,($DA33)
    LD C,A
    LD A,($C899)
    AND $07
    SWAP C
    OR C
    LD C,A
    LD A,($C8F6)
    AND $01
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,C
    LD L,A
    LD H,$03
    LD DE,$C0C8
    CALL $0D67
    RET
Fn9_67A7:
    LD HL,$C0C8
    LD B,$10
Lbl9_67AC:
    LD A,(HL)
    CP $F0
    JR Z,Lbl9_67B6
    INC HL
    DEC B
    JR NZ,Lbl9_67AC
    RET
Lbl9_67B6:
    LD A,$9F
    LD (HL+),A
    DEC B
    JR NZ,Lbl9_67B6
    RET
Fn9_67BD:
    LD HL,$C0C8
    LD A,(HL+)
    CP (HL)
    JR NZ,Lbl9_67D2
    INC HL
    CP (HL)
    JR NZ,Lbl9_67D2
    INC HL
    CP (HL)
    JR NZ,Lbl9_67D2
    INC HL
    LD A,(HL)
    CP $9F
    JR Z,Lbl9_67E5
Lbl9_67D2:
    LD HL,$6853
Lbl9_67D5:
    LD DE,$C0C8
    LD B,$08
    PUSH HL
Lbl9_67DB:
    LD A,(DE)
    CP (HL)
    INC HL
    INC DE
    JR NZ,Lbl9_67E7
    DEC B
    JR NZ,Lbl9_67DB
    POP HL
Lbl9_67E5:
    SCF
    RET
Lbl9_67E7:
    POP HL
    LD A,L
    ADD A,$08
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    LD A,(HL)
    CP $FF
    JR NZ,Lbl9_67D5
    SCF
    CCF
    RET
Fn9_67F8:
    LD C,$00
Lbl9_67FA:
    LD A,C
    PUSH BC
    LD HL,$CAC1
    CALL $260A
    POP BC
    LD A,(HL)
    OR A
    JR Z,Lbl9_6850
    LD A,L
    ADD A,$01
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    LD A,($C8F2)
    LD E,A
    LD A,($C8F3)
    LD D,A
    LD A,E
    SUB L
    LD E,A
    LD A,D
    SBC A,H
    LD D,A
    LD A,D
    OR E
    JR Z,Lbl9_684A
    LD DE,$C0C8
    LD B,$08
Lbl9_6826:
    LD A,(DE)
Lbl9_6827:
    CP $9F
    JR Z,Lbl9_683D
    CP $F0
    JR Z,Lbl9_683D
    CP $00
    JR Z,Lbl9_683D
    CP (HL)
    INC HL
    INC DE
    JR NZ,Lbl9_684A
    DEC B
    JR NZ,Lbl9_6826
Lbl9_683B:
    SCF
    RET
Lbl9_683D:
    LD A,(HL)
    CP $9F
    JR Z,Lbl9_683B
    CP $F0
    JR Z,Lbl9_683B
    CP $00
    JR Z,Lbl9_683B
Lbl9_684A:
    INC C
    LD A,C
    CP $14
    JR NZ,Lbl9_67FA
Lbl9_6850:
    SCF
    CCF
    RET

SECTION "BattleView_CursorData", ROMX[$6853], BANK[9]
BattleView_CursorData:
    INC (HL)
    LD D,L
    LD B,D
    ADC A,(HL)
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    INC (HL)
    LD D,L
    LD B,D
    ADC A,(HL)
    DEC L
    SBC A,A
    SBC A,A
    SBC A,A
    INC (HL)
    LD D,L
    INC (HL)
    LD D,L
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    JR Z,Lbl9_68B0
    LD D,L
    DEC L
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    LD B,E
    LD D,L
    DEC L
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    JR Z,Lbl9_68C3
    DEC L
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    LD SP,$2B36
    JR NC,Lbl9_6827
    SBC A,A
    SBC A,A
    SBC A,A
    LD L,B
    LD L,L
    LD H,D
    LD H,A
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    LD H,$55
    DEC L
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    LD A,(HL+)
    LD D,L
    INC SP
    LD B,E
    SBC A,A
    SBC A,A
    SBC A,A
    SBC A,A
    RST $38

SECTION "BattleView_CursorHelpers", ROMX[$68A4], BANK[9]
BattleView_CursorScan:
    LD A,($C8DB)
    LD C,$0F
    CALL $218D
    LD A,($C8DA)
    ADD A,L
Lbl9_68B0:
    LD DE,$64EE
    LD C,A
    BIT 7,A
    JR NZ,Lbl9_68C8
    LD A,($C90C)
    AND $0F
    PUSH AF
    LD A,($C90C)
    INC A
    LD ($C90C),A
Lbl9_68C3:
    INC C
    RET
    POP AF
    LD A,C
    RET NZ
Lbl9_68C8:
    LD C,A
    LD B,$00
Fn9_68CB:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,C
    AND $7F
    CP B
    LD A,$E0
    JR NZ,Lbl9_68FB
    LD A,$A0
    BIT 7,C
    JR NZ,Lbl9_68FB
    LD A,($C90C)
    BIT 4,A
    LD A,$E0
    JR NZ,Lbl9_68FB
    LD A,$A0
Lbl9_68FB:
    LDH ($FFD7),A
    LD A,B
    CP $29
    JR Z,Lbl9_6949
    CP $2A
    JR Z,Lbl9_6949
    CP $2B
    JR Z,Lbl9_6949
    CP $2C
    JR Z,Lbl9_6949
    CP $38
    JR Z,Lbl9_6949
    CP $39
    JR Z,Lbl9_6949
    CP $3A
    JR Z,Lbl9_6949
    CP $3B
    JR Z,Lbl9_6949
    CP $47
    JR Z,Lbl9_6949
    CP $48
    JR Z,Lbl9_6949
    CP $49
    JR Z,Lbl9_6949
    CP $4A
    JR Z,Lbl9_6949
    CALL Fn9_6960
    LD A,B
    CP $28
    JR Z,Lbl9_6940
    CP $37
    JR Z,Lbl9_6943
    CP $46
    JR Z,Lbl9_6943
    JR Lbl9_6949
Lbl9_6940:
    CALL Fn9_694D
Lbl9_6943:
    CALL Fn9_694D
    CALL Fn9_694D
Lbl9_6949:
    INC B
    JP Fn9_68CB
Fn9_694D:
    PUSH AF
    LD HL,$FFD5
    INC (HL)
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    POP AF
Fn9_6960:
    LDH A,($FFD7)
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    RET

SECTION "BattleView_AnimHelpers", ROMX[$6977], BANK[9]
BattleView_FindFreeOAM:
    LD HL,$C0C8
    LD B,$08
    LD C,$00
Lbl9_697E:
    LD A,(HL+)
    DEC B
    RET Z
    INC DE
    CP $8D
    JR Z,Lbl9_697E
    CP $8E
    JR Z,Lbl9_697E
    CP $9F
    JR Z,Lbl9_697E
    INC C
    JR Lbl9_697E
; data $6991-$6991
    DB $C9
BattleView_AnimUpdate:
    CALL BattleView_FindFreeOAM
    LD DE,$69D0
    LD B,$00
Lbl9_699A:
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE
    AND L
    CP $FF
    RET Z
    LD A,L
    LDH ($FFD5),A
    LD A,H
    LDH ($FFD6),A
    PUSH DE
    PUSH BC
    CALL BattleAnim_WriteColumn
    POP BC
    POP DE
    LD A,C
    CP B
    LD A,$E0
    JR NZ,Lbl9_69B9
    LD A,$A0
Lbl9_69B9:
    CALL $1E80
    PUSH AF
    LDH A,($FFD5)
    LD L,A
    LDH A,($FFD6)
    LD H,A
    LD A,L
    ADD A,$00
    LD L,A
    LD A,H
    ADC A,$C5
    LD H,A
    POP AF
    LD (HL),A
    INC B
    JR Lbl9_699A

; End of Bank 9