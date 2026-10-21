; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 88  (Battle menu input / monster stat computation)
; ============================================================================
;
; File offset $160000-$163FFF  (16 KB, mapped at $4000-$7FFF)
;
; Support bank for the battle command/status menu. fn0 ($401D) dispatches on
; wBattleMenuPhase ($D9ED) via RST $00 into 7 handlers; other fns compute and
; format the per-monster values shown on the status/skill pages (HP/MP, stats,
; skill lists) and process cursor input.
;
; Callers: bank80/81/82/83/87. Heavily calls bank82/fn6 (shared draw helper).
; ============================================================================

SECTION "Bank88_ID", ROMX[$4000], BANK[88]
    DB $58

SECTION "Bank88_JumpTable", ROMX[$4001], BANK[88]
    DW BattleInput_Dispatch             ; fn0 @ $401D
    DW Bank88_fn1                       ; fn1 @ $4397
    DW Bank88_fn2                       ; fn2 @ $45A3
    DW Bank88_fn3                       ; fn3 @ $462A
    DW Bank88_fn4                       ; fn4 @ $6379
    DW Bank88_fn5                       ; fn5 @ $642C
    DW Bank88_fn6                       ; fn6 @ $4413
    DW Bank88_fn7                       ; fn7 @ $43F2
    DW Bank88_fn8                       ; fn8 @ $40E6
    DW Bank88_fn9                       ; fn9 @ $456C
    DW Bank88_fn10                      ; fn10 @ $4AB0
    DW Bank88_fn11                      ; fn11 @ $67BA
    DW Bank88_fn12                      ; fn12 @ $4896
    DW Bank88_fn13                      ; fn13 @ $6737

SECTION "Bank88_Code", ROMX[$401D], BANK[88]
BattleInput_Dispatch:
    LD A,($D9ED)
    RST $00
    DW .L402D                           ; state 0
    DW .L406C                           ; state 1
    DW .L4075                           ; state 2
    DW .L411F                           ; state 3
    DW .L4210                           ; state 4
    DW .L4355                           ; state 5
.L402D:
    LD A,($C86C)
    OR A
    CALL NZ,.L4866
    LD A,($DB88)
    CP $08
    JR Z,.L405F
    LD E,A
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $01
    JR Z,.L4051
    INC E
    LD A,E
    LD ($DB88),A
    JR .L406B
.L4051:
    LD A,E
    LD ($DB88),A
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
    JR .L406B
.L405F:
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
.L406B:
    RET
.L406C:
    LD HL,$5700
    RST $10  ; -> bank87/fn0
    RET
    DB $2A,$66,$6F,$E9
.L4075:
    XOR A
    LD ($DD69),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $FF
    JR NZ,.L40C6
    LD A,($DB88)
    CALL $3345
    JR NC,.L40A9
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$3A
    LD (HL+),A
    LD A,($DB88)
    LD (HL),A
    JR .L40C6
.L40A9:
    LD A,($C88B)
    OR A
    CALL NZ,.L466E
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $FF
    CALL Z,.L411C
    CALL Bank88_fn8
.L40C6:
    CALL .L468E
    CALL .L47EF
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$02
    LD (HL),A
    XOR A
    LD ($D9ED),A
    LD HL,$DB88
    INC (HL)
    JP .L402D
Bank88_fn8:
    LD A,($D9ED)
    CP $16
    JR C,.L40FF
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$FF
    LD (HL-),A
    JR .L410C
.L40FF:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
.L410C:
    LD A,(HL)
    LD ($DB8A),A
    LD HL,$48E4
    LD C,A
    LD B,$00
    ADD HL,BC
    ADD HL,BC
    CALL $0008
    RET
.L411C:
    LD (HL),$3A
    RET
.L411F:
    LD HL,$DB79
    LD BC,$0009
    LD A,$FF
    CALL $169A
    LD HL,$DB4C
    LD BC,$0009
    LD A,$FF
    CALL $169A
    LD HL,$DB61
    LD BC,$0010
    LD A,$00
    CALL $169A
    XOR A
    LD ($DB82),A
    LD ($DB55),A
    LD HL,$DB61
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD DE,$0800
.L4155:
    PUSH DE
    LD A,($C86C)
    OR A
    CALL NZ,.L4866
    POP DE
    LD A,E
    CALL $3374
    JR C,.L41D5
    LD A,E
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    JR NZ,.L41D5
    LD A,E
    LD HL,$DC03
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    LD A,E
    CALL .L42B0
    LD A,B
    OR A
    JR NZ,.L4191
    LD A,C
    CP $02
    JR NC,.L4191
    LD BC,$0002
.L4191:
    LD A,E
    CALL .L431D
    JR C,.L41AF
    LD A,E
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $55
    CALL Z,.L4207
    CP $56
    CALL Z,.L420C
    JR .L41B3
.L41AF:
    LD A,B
    ADD A,$06
    LD B,A
.L41B3:
    LD HL,$DB5E
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB55)
    LD HL,$DB4C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),E
    LD HL,$DB55
    INC (HL)
    LD HL,$DB5E
    INC (HL)
    LD HL,$DB5E
    INC (HL)
.L41D5:
    INC E
    DEC D
    JP NZ,.L4155
    LD A,($C86C)
    OR A
    JR NZ,.L4201
    LD A,($DB77)
    CP $FF
    JR Z,.L4201
    LD BC,$0200
    LD HL,$DB5E
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB55)
    LD HL,$DB4C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$10
.L4201:
    LD HL,$D9ED
    INC (HL)
    JR .L4210
.L4207:
    LD A,B
    ADD A,$02
    LD B,A
    RET
.L420C:
    LD BC,$0001
    RET
.L4210:
    LD D,$08
.L4212:
    LD HL,$DB61
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    LD HL,$DB63
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD E,$00
.L4228:
    CALL $3314
    JR C,.L4263
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    LD A,C
    LD ($DB58),A
    LD A,B
    LD ($DB59),A
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,($DB56)
    LD (HL+),A
    LD A,($DB57)
    LD (HL+),A
    LD A,($DB58)
    LD (HL+),A
    LD A,($DB59)
    LD (HL),A
    LD A,E
    LD HL,$DB4C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD (HL-),A
    LD (HL),B
.L4263:
    INC E
    LD A,E
    CP D
    JR Z,.L4283
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    INC HL
    INC HL
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    INC HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    JR .L4228
.L4283:
    DEC D
    JR NZ,.L4212
    LD A,($DB82)
    LD DE,$DB79
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,($DB82)
    LD HL,$DB4C
    LD B,$08
.L429A:
    LD A,(HL+)
    CP $FF
    JR Z,.L42A4
    LD (DE),A
    INC DE
    DEC B
    JR NZ,.L429A
.L42A4:
    LD A,$00
    LD ($DB82),A
    LD HL,$D9ED
    INC (HL)
    JP .L4355
.L42B0:
    PUSH HL
    PUSH DE
    PUSH AF
    PUSH BC
    CALL .L488C
    LD HL,$0001
    POP BC
    LD A,B
    OR C
    JR NZ,.L42C2
    LD BC,$0001
.L42C2:
    LD D,B
    LD E,C
    SRL B
    RR C
    SRL B
    RR C
    ADD HL,BC
    SRL B
    RR C
    SRL B
    RR C
    ADD HL,BC
    LD A,E
    SUB L
    LD E,A
    LD A,D
    SBC A,H
    LD D,A
    LD B,H
    LD C,L
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    LD A,H
    AND $03
    LD H,A
.L42EA:
    CALL $3314
    JR Z,.L42F9
    JR C,.L42F9
    LD A,L
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR .L42EA
.L42F9:
    ADD HL,DE
    LD B,H
    LD C,L
    POP AF
    LD E,A
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $55
    JR NZ,.L4313
    LD A,B
    ADD A,$02
    LD B,A
    JR .L431A
.L4313:
    CP $56
    JR NZ,.L431A
    LD BC,$0000
.L431A:
    POP DE
    POP HL
    RET
.L431D:
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $2A
    JR Z,.L4353
    CP $7F
    JR Z,.L4353
    CP $88
    JR Z,.L4353
    CP $89
    JR Z,.L4353
    CP $8C
    JR Z,.L4353
    CP $8D
    JR Z,.L4353
    CP $8E
    JR Z,.L4353
    CP $8F
    JR Z,.L4353
    CP $90
    JR Z,.L4353
    CP $DC
    JR Z,.L4353
    XOR A
    JR .L4354
.L4353:
    SCF
.L4354:
    RET
.L4355:
    XOR A
    LD ($D9ED),A
    LD ($DB82),A
    LD ($DB88),A
    LD ($DB89),A
    LD ($DB8A),A
    LD HL,$D9EC
    INC (HL)
    RET
    DB $E5,$FA,$88,$DB,$21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$44
    DB $4D,$FA,$99,$C8,$E6,$07,$87,$85,$6F,$3E,$00,$8C,$67,$7E,$FE,$FF
    DB $20,$07,$0A,$FE,$FF,$20,$02,$3E,$3A,$4F,$E1,$71,$C9
Bank88_fn1:
    LD A,$02
    LD ($D9F0),A
    LD A,($C86C)
    OR A
    JR Z,.L43B4
    LD A,($C863)
    BIT 1,A
    JR Z,.L43B4
    LD A,($DB89)
    BIT 2,A
    RET NZ
    LD A,($DB89)
    JR .L43BF
.L43B4:
    LD A,($DB89)
    BIT 2,A
    RET Z
    LD A,($DB89)
    SUB $04
.L43BF:
    CP $02
    JR Z,.L43D1
    CP $01
    JR Z,.L43CC
    LD HL,$9000
    JR .L43D4
.L43CC:
    LD HL,$9240
    JR .L43D4
.L43D1:
    LD HL,$9480
.L43D4:
    LD C,$24
.L43D6:
    LD B,$08
.L43D8:
    DI
.L43D9:
    LDH A,($FF41)
    BIT 1,A
    JR NZ,.L43D9
    LD A,$FF
    LD (HL+),A
    LD A,$00
    LD (HL+),A
    EI
    DEC B
    JR NZ,.L43D8
    DEC C
    JR NZ,.L43D6
    LD A,$05
    LD ($D9ED),A
    RET
Bank88_fn7:
    LD A,($DB78)
    CP $C2
    JR C,.L4434
    CP $C7
    JR NC,.L4434
    LD B,A
    LD A,$01
    LD ($C822),A
    LD A,($DB77)
    CP $04
    JR NC,.L4410
    CALL .L461D
    JP .L4546
.L4410:
    JP .L4536
Bank88_fn6:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    JR NZ,.L4442
    INC HL
    BIT 4,(HL)
    JR NZ,.L4448
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
.L4434:
    LD HL,$4454
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB4C),A
    RET
.L4442:
    LD A,$33
    LD ($DB4C),A
    RET
.L4448:
    LD A,$4F
    LD ($DB4C),A
    RET
    DB $3E,$FF,$EA,$4C,$DB,$C9,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23
    DB $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23
    DB $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23
    DB $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$22,$22,$23
    DB $22,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$34,$24,$24,$24,$24,$24,$24
    DB $24,$24,$24,$24,$24,$35,$24,$24,$36,$37,$38,$39,$3A,$24,$24,$3B
    DB $3C,$3D,$25,$25,$25,$25,$25,$25,$25,$25,$3E,$3F,$40,$22,$22,$22
    DB $25,$25,$25,$25,$26,$41,$44,$26,$42,$24,$24,$26,$26,$43,$26,$45
    DB $45,$46,$24,$48,$22,$50,$27,$27,$27,$70,$49,$49,$49,$49,$51,$52
    DB $4A,$4B,$53,$28,$54,$56,$55,$26,$4C,$4D,$26,$4E,$26,$2A,$18,$22
    DB $22,$57,$58,$5C,$59,$5A,$5B,$29,$6F,$FF,$FF,$70,$71,$FF,$FF,$73
    DB $FF,$74,$75,$FF,$FF,$77,$5D,$5D,$5F,$60,$5D,$5D,$5D,$5D,$5D,$5D
    DB $5D,$5D,$FF,$FF,$FF,$FF,$FF,$FF,$5E,$5E,$5E,$5E,$5E,$61,$62,$63
    DB $64,$65,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$66,$23,$24,$24,$24,$24
    DB $23,$29,$23,$44,$67,$68,$FF,$6A
.L4536:
    LD A,($DB89)
    PUSH AF
    LD A,$04
    LD ($DB89),A
    CALL Bank88_fn2
    POP AF
    LD ($DB89),A
.L4546:
    LD A,($DB78)
    CP $C5
    JR NZ,.L4555
    LD A,($DD72)
    ADD A,$03
    LD ($DD72),A
.L4555:
    LD A,($DD72)
    LD HL,$4566
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB4C),A
    RET
    DB $00,$01,$02,$00,$01,$02
Bank88_fn9:
    CALL .L4859
    CP $04
    CALL NC,.L458B
    LD A,($DD72)
    LD HL,$4585
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($C823),A
    RET
    DB $03,$05,$07,$04,$06,$08
.L458B:
    LD HL,$C180
    JR .L4593
.L4590:
    LD HL,$C1A0
.L4593:
    LD A,(HL)
    CP $F0
    JR Z,.L459B
    INC HL
    JR .L4593
.L459B:
    DEC HL
    LD A,(HL)
    CP $24
    RET NC
    LD (HL),$F0
    RET
Bank88_fn2:
    XOR A
    LD ($DD72),A
    LD ($DD73),A
    LD A,($DB89)
    AND $04
    LD C,A
    LD B,$03
    LD A,($C86C)
    OR A
    JR NZ,.L45BD
    LD A,C
    CP $04
    JR NC,.L45D6
.L45BD:
    LD A,C
    CALL $3374
    JR C,.L45C7
    LD HL,$DD72
    INC (HL)
.L45C7:
    INC C
    DEC B
    JR NZ,.L45BD
    LD A,($DD72)
    DEC A
    OR A
    JR Z,.L4626
    LD A,$01
    JR .L4626
.L45D6:
    LD A,C
    CALL $3374
    JR C,.L4607
    LD HL,$DD72
    INC (HL)
    LD HL,$DD73
    LD A,(HL)
    OR A
    JR NZ,.L45F6
    LD A,C
    LD DE,$DC3C
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD D,A
    INC (HL)
    JR .L4607
.L45F6:
    PUSH BC
    LD A,C
    LD BC,$DC3C
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,(BC)
    POP BC
    CP D
    JR Z,.L4607
    INC (HL)
.L4607:
    INC C
    DEC B
    JR NZ,.L45D6
    LD A,($DD72)
    CP $01
    JR Z,.L461D
    LD A,($DD73)
    CP $01
    JR Z,.L4621
    LD A,$02
    JR .L4626
.L461D:
    LD A,$00
    JR .L4626
.L4621:
    CALL .L4590
    LD A,$01
.L4626:
    LD ($DD72),A
    RET
Bank88_fn3:
    LD HL,$C180
    LD A,($C86C)
    OR A
    JR NZ,.L463F
    LD A,($DB89)
    CP $03
    JR C,.L463F
    CALL .L4650
    JR .L464C
.L463F:
    PUSH HL
    LD HL,$CAC2
    CALL $25F8
    LD E,L
    LD D,H
    POP HL
    CALL $106C
.L464C:
    CALL Bank88_fn2
    RET
.L4650:
    LD ($DB60),A
    PUSH HL
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD L,A
    LD H,$05
    POP DE
    LD A,E
    LD ($DB5E),A
    LD A,D
    LD ($DB5F),A
    CALL $0D67
    RET
.L466E:
    CALL .L488C
    LD A,($C88C)
    OR A
    JR Z,.L467C
    LD HL,$C899
    CP (HL)
    RET C
.L467C:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($C88D)
    LD (HL),A
    RET
.L468E:
    LD A,($DB88)
    CALL $3345
    RET C
    LD A,($C86C)
    OR A
    JR Z,.L46A8
    CALL .L4866
    LD A,($DB88)
    AND $03
    CP $03
    RET Z
    JR .L46B1
.L46A8:
    LD A,($DB88)
    CP $03
    RET NC
    CALL .L488C
.L46B1:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL+)
    AND $0C
    RET NZ
    LD A,(HL)
    AND $0C
    JP NZ,.L476C
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $12
    RET C
    CP $14
    RET Z
    CP $1B
    RET Z
    CP $1E
    JR C,.L4749
    CP $20
    JR Z,.L4749
    CP $21
    JR Z,.L4749
    CP $2B
    RET C
    CP $32
    RET Z
    CP $37
    JR C,.L4757
    CP $3A
    JR Z,.L473B
    CP $44
    RET C
    CP $4F
    RET Z
    CP $52
    JR C,.L473B
    CP $55
    JR Z,.L473B
    CP $67
    RET C
    CP $6A
    JR C,.L473B
    CP $77
    JR Z,.L476C
    CP $7E
    JR C,.L4749
    CP $81
    JR Z,.L4757
    CP $82
    JR Z,.L4749
    CP $8C
    JR Z,.L475E
    CP $8D
    JR Z,.L4742
    CP $8E
    JR Z,.L4742
    CP $90
    JR Z,.L4742
    RET C
    CP $93
    JR C,.L4749
    CP $96
    JR C,.L4757
    CP $D6
    RET C
    CP $D9
    JR C,.L473B
    RET
.L473B:
    LD HL,$DC44
    LD D,$01
    JR .L4773
.L4742:
    LD HL,$DC44
    LD D,$02
    JR .L47B1
.L4749:
    LD HL,$DC4C
    LD D,$04
    JR .L4773
.L4750:
    LD HL,$DC4C
    LD D,$08
    JR .L47B1
.L4757:
    LD HL,$DC54
    LD D,$10
    JR .L4773
.L475E:
    LD HL,$DC54
    LD D,$20
    JR .L47B1
.L4765:
    LD HL,$DC5C
    LD D,$40
    JR .L4773
.L476C:
    LD HL,$DC5C
    LD D,$80
    JR .L47B1
.L4773:
    LD A,($DB88)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $81
    RET C
    CP $A2
    JR C,.L478E
    CP $C3
    JR C,.L4792
    CP $E4
    JR C,.L4796
    JR .L479A
.L478E:
    LD B,$01
    JR .L479C
.L4792:
    LD B,$02
    JR .L479C
.L4796:
    LD B,$04
    JR .L479C
.L479A:
    LD B,$08
.L479C:
    LD A,($C899)
    CP B
    RET NC
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR D
    LD (HL),A
    RET
.L47B1:
    LD A,($DB88)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $80
    RET NC
    CP $60
    JR NC,.L47CC
    CP $3F
    JR NC,.L47D0
    CP $1E
    JR NC,.L47D4
    JR .L47D8
.L47CC:
    LD B,$02
    JR .L47DA
.L47D0:
    LD B,$04
    JR .L47DA
.L47D4:
    LD B,$08
    JR .L47DA
.L47D8:
    LD B,$10
.L47DA:
    LD A,($C899)
    CP B
    RET NC
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR D
    LD (HL),A
    RET
.L47EF:
    LD A,($DB88)
    CALL $3345
    RET C
    LD A,($C86C)
    OR A
    JR Z,.L4809
    CALL .L4866
    LD A,($DB88)
    AND $03
    CP $03
    RET Z
    JR .L4812
.L4809:
    LD A,($DB88)
    CP $03
    RET NC
    CALL .L488C
.L4812:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL+)
    AND $0C
    RET NZ
    LD A,(HL)
    AND $0C
    RET NZ
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $90
    JR Z,.L4855
    CP $12
    JR C,.L4851
    CP $3A
    JR Z,.L4851
    CP $44
    RET C
    CP $52
    JR C,.L4851
    CP $55
    RET C
    CP $6A
    JR C,.L4851
    CP $D6
    RET C
    CP $DA
    RET NC
.L4851:
    CALL .L4765
    RET
.L4855:
    CALL .L4750
    RET
.L4859:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    RET Z
    LD A,($DB88)
    RET
.L4866:
    PUSH HL
    LD A,($C1ED)
    LD L,A
    LD A,($C1EE)
    LD H,A
    LD A,L
    LD ($C899),A
    LD A,H
    LD ($C89A),A
    CALL $16A3
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    LD A,L
    LD ($C1ED),A
    LD A,H
    LD ($C1EE),A
    POP HL
    RET
.L488C:
    LD A,($C86C)
    OR A
    JR NZ,.L4866
    CALL $16A3
    RET
Bank88_fn12:
    CALL Bank88_fn8
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD ($DB8A),A
    LD A,(HL)
    LD ($DB89),A
    LD A,($D9ED)
    CP $17
    JR Z,.L48BC
    LD A,$02
    LD ($D9EF),A
    JR .L48C1
.L48BC:
    LD A,$01
    LD ($D9EF),A
.L48C1:
    XOR A
    LD ($D9ED),A
    LD A,$02
    LD ($D9EE),A
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    RET NZ
    LD A,($DD72)
    OR A
    RET NZ
    LD HL,$D9EE
    INC (HL)
    RET
    DB $30,$59,$30,$59,$30,$59,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62
    DB $BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62
    DB $BF,$62,$BF,$62,$99,$58,$BF,$62,$BF,$62,$D8,$5A,$BF,$62,$BF,$62
    DB $BF,$62,$BF,$62,$70,$5B,$67,$63,$1B,$51,$BF,$62,$12,$50,$CD,$62
    DB $72,$51,$BF,$62,$D5,$51,$CD,$62,$CD,$62,$D2,$4F,$CD,$62,$67,$63
    DB $67,$63,$9F,$57,$CD,$62,$BE,$4D,$BE,$4D,$BE,$4D,$CD,$62,$CD,$62
    DB $65,$4F,$65,$4F,$5F,$63,$8E,$4F,$CD,$62,$CD,$62,$CD,$62,$B0,$4A
    DB $B0,$4A,$D6,$63,$B0,$4A,$B0,$4A,$C7,$59,$B0,$4A,$C7,$59,$79,$63
    DB $B0,$4A,$67,$63,$2C,$64,$67,$63,$00,$5C,$19,$5C,$32,$5C,$4B,$5C
    DB $E1,$55,$24,$56,$34,$56,$44,$56,$54,$56,$64,$56,$74,$56,$BF,$62
    DB $B0,$4A,$2C,$64,$2C,$64,$2C,$64,$D6,$63,$B0,$4A,$B0,$4A,$BF,$62
    DB $64,$5C,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62
    DB $BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$B4,$56
    DB $4C,$55,$00,$57,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$BF,$62
    DB $4C,$57,$BF,$62,$BF,$62,$BF,$62,$BF,$62,$98,$55,$98,$55,$67,$63
    DB $BF,$62,$4C,$57,$3B,$54,$EB,$54,$BF,$62,$BF,$62,$B0,$4A,$67,$63
    DB $BF,$62,$CD,$62,$E8,$52,$FD,$62,$D6,$63,$D6,$63,$D6,$63,$D6,$63
    DB $81,$53,$CD,$62,$67,$63,$CD,$62,$67,$63,$67,$63,$67,$63,$CD,$62
    DB $67,$63,$BF,$62,$ED,$53,$67,$63,$CD,$62,$5F,$63,$5F,$63,$67,$63
    DB $67,$63,$79,$64,$2C,$64,$67,$63,$67,$63,$67,$63,$2C,$64,$67,$63
    DB $67,$63,$67,$63,$FD,$62,$CD,$62,$BF,$62,$FD,$62,$CD,$62,$BF,$62
    DB $BF,$62,$67,$63,$67,$63,$BF,$62,$BF,$62,$5F,$63,$CD,$62,$BF,$62
    DB $D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63
    DB $D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63
    DB $D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63
    DB $D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63
    DB $D6,$63,$D6,$63,$D6,$63,$D6,$63,$D6,$63,$67,$63,$84,$56,$94,$56
    DB $A4,$56,$7D,$5C,$2B,$5A,$67,$63,$67,$63,$B0,$4A,$67,$63,$67,$63
    DB $67,$63,$67,$63,$67,$63,$67,$63,$67,$63,$67,$63
Bank88_fn10:
    LD HL,$DB56
    LD BC,$0008
    XOR A
    CALL $169A
    CALL .L654D
    RET Z
    LD A,($C86C)
    OR A
    JP NZ,.L4ACD
    LD A,($DB88)
    CP $04
    JP NC,.L4CE2
.L4ACD:
    LD A,($DB88)
    AND $04
    XOR $04
    LD ($DB89),A
    LD B,$03
    LD C,A
.L4ADA:
    LD A,C
    CALL $3374
    JR C,.L4AE5
    CALL .L660D
    JR C,.L4AEF
.L4AE5:
    INC C
    DEC B
    JR NZ,.L4ADA
    CALL .L4BF3
    JP .L4BE1
.L4AEF:
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4AF5:
    LD A,C
    CALL $3374
    JR C,.L4B00
    CALL .L4CB1
    JR Z,.L4B0A
.L4B00:
    INC C
    DEC B
    JR NZ,.L4AF5
    CALL .L4C4B
    JP .L4BE1
.L4B0A:
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    JR NZ,.L4B37
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4B21:
    LD A,C
    CALL .L4CB1
    JR NZ,.L4B2D
    LD A,C
    CALL $3345
    JR NC,.L4B8D
.L4B2D:
    INC C
    DEC B
    JR NZ,.L4B21
    CALL .L4C4B
    JP .L4BE1
.L4B37:
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4B3D:
    PUSH BC
    LD A,C
    CALL $3374
    JR C,.L4B6D
    CALL .L4CB1
    JR NZ,.L4B6D
    CALL .L4CC6
    LD A,C
    CALL $33B7
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,L
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR NC,.L4B63
    LD HL,$0000
.L4B63:
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L4B75
.L4B6D:
    LD A,$FF
    LD ($DB56),A
    LD ($DB57),A
.L4B75:
    POP BC
    CALL .L586E
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L4C9E
    INC C
    DEC B
    JR NZ,.L4B3D
    CALL .L4C05
    JR .L4BE1
.L4B8D:
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4B93:
    PUSH BC
    LD A,C
    CALL $3345
    JR C,.L4BC3
    CALL .L4CB1
    JR NZ,.L4BC3
    CALL .L4CC6
    LD A,C
    CALL $33B7
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,L
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR NC,.L4BB9
    LD HL,$0000
.L4BB9:
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L4BCB
.L4BC3:
    LD A,$FF
    LD ($DB56),A
    LD ($DB57),A
.L4BCB:
    POP BC
    CALL .L586E
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L4C9E
    INC C
    DEC B
    JR NZ,.L4B93
    CALL .L4C05
.L4BE1:
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB89)
    LD (HL),A
    RET
.L4BF3:
    LD A,$00
    LD ($DB63),A
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4BFE:
    CALL .L4C71
    INC C
    DEC B
    JR NZ,.L4BFE
.L4C05:
    LD A,$00
    LD ($DB61),A
    LD A,($DB58)
    LD C,A
    LD A,($DB59)
    LD B,A
    LD DE,$0201
.L4C15:
    LD A,E
    LD HL,$DB58
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    CALL $3314
    JR Z,.L4C32
    JR NC,.L4C3C
.L4C2A:
    LD B,H
    LD C,L
    LD A,E
    LD ($DB61),A
    JR .L4C3C
.L4C32:
    CALL .L488C
    LD A,($C899)
    BIT 1,A
    JR Z,.L4C2A
.L4C3C:
    INC E
    DEC D
    JR NZ,.L4C15
    LD HL,$DB89
    LD A,($DB61)
    ADD A,(HL)
    LD ($DB89),A
    RET
.L4C4B:
    LD A,$01
    LD ($DB63),A
    LD B,$03
    LD A,($DB89)
    LD C,A
.L4C56:
    LD A,C
    LD HL,$DB06
    CALL $333B
    BIT 2,(HL)
    JR NZ,.L4C66
    CALL .L4C71
    JR .L4C69
.L4C66:
    CALL .L4C9B
.L4C69:
    INC C
    DEC B
    JR NZ,.L4C56
    CALL .L4C05
    RET
.L4C71:
    LD A,C
    CALL $3374
    JR C,.L4C9B
    CALL $33B7
    PUSH HL
    LD A,C
    CALL $33A2
    LD A,($DB63)
    OR A
    JR Z,.L4C97
    PUSH HL
    LD A,C
    LD HL,$DB08
    CALL $333B
    LD A,(HL)
    POP HL
    BIT 2,A
    JR Z,.L4C97
    SRL H
    RR L
.L4C97:
    POP DE
    ADD HL,DE
    JR .L4C9E
.L4C9B:
    LD HL,$FFFF
.L4C9E:
    LD A,C
    AND $03
    ADD A,A
    LD DE,$DB58
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,L
    LD (DE),A
    INC DE
    LD A,H
    LD (DE),A
    RET
.L4CB1:
    LD HL,$DB06
    CALL $333B
    BIT 2,(HL)
    JR NZ,.L4CC5
    INC HL
    INC HL
    LD A,(HL+)
    AND $20
    JR NZ,.L4CC5
    LD A,(HL)
    AND $07
.L4CC5:
    RET
.L4CC6:
    PUSH BC
    LD A,($DB8A)
    CP $37
    JR C,.L4CDC
    CP $D9
    JR Z,.L4CDC
    CP $DD
    JR Z,.L4CDC
    LD HL,$5203
    RST $10  ; -> bank82/fn3
    JR .L4CE0
.L4CDC:
    LD HL,$5403
    RST $10  ; -> bank84/fn3
.L4CE0:
    POP BC
    RET
.L4CE2:
    CALL .L654D
    RET Z
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    JR Z,.L4D51
    CALL .L5E5B
    CALL .L5E75
.L4CFD:
    XOR A
    LD ($DB89),A
.L4D01:
    LD A,D
    DEC A
    RST $00
    DW .L4D2A                           ; state 0
    DW .L4D1A                           ; state 1
    DW .L4D0A                           ; state 2
.L4D0A:
    PUSH BC
    CALL .L488C
    POP BC
    LD A,($C899)
    CP $80
    JR C,.L4D2A
    LD HL,$DB89
    INC (HL)
.L4D1A:
    PUSH BC
    CALL .L488C
    POP BC
    LD A,($C899)
    CP $AA
    JR C,.L4D2A
    LD HL,$DB89
    INC (HL)
.L4D2A:
    LD HL,$DB4C
    LD A,($DB89)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB89),A
    CALL $3374
    JR C,.L4D01
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB89)
    LD (HL),A
    RET
.L4D51:
    CALL .L5E19
.L4D54:
    LD A,C
    CALL $3374
    JR C,.L4D79
    LD A,C
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    LD A,C
    CALL $33A2
    SRL H
    RR L
    SRL D
    RR E
    ADD HL,DE
    LD D,H
    LD E,L
    JR .L4D7C
.L4D79:
    LD DE,$FFFF
.L4D7C:
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,E
    LD (HL+),A
    LD A,D
    LD (HL+),A
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    INC C
    DEC B
    JR NZ,.L4D54
    CALL .L5E5B
    CALL .L5E75
    LD A,D
    CP $02
    JR C,.L4DBA
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    CALL .L5E81
    POP HL
    POP DE
    POP BC
    POP AF
    LD A,D
    CP $03
    JR C,.L4DBA
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    CALL .L5EBF
    POP HL
    POP DE
    POP BC
    POP AF
.L4DBA:
    CALL .L4CFD
    RET
    DB $CD,$56,$65,$C8,$FA,$88,$DB,$E6,$04,$5F,$16,$03,$FA,$88,$DB,$21
    DB $0B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E,$FE,$02,$CA,$58,$4E,$7B,$EA
    DB $4F,$DB,$7A,$EA,$50,$DB,$7B,$CD,$74,$33,$30,$08,$01,$00,$00,$21
    DB $00,$00,$18,$22,$7B,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A
    DB $46,$4F,$7B,$CD,$A9,$33,$CD,$14,$33,$20,$08,$01,$01,$00,$21,$00
    DB $00,$18,$03,$CD,$1A,$33,$E5,$FA,$4F,$DB,$5F,$FA,$50,$DB,$57,$3E
    DB $03,$92,$21,$61,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$79,$22,$70,$E1
    DB $44,$4D,$FA,$4F,$DB,$5F,$FA,$50,$DB,$57,$3E,$03,$92,$21,$58,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$79,$22,$70,$FA,$4F,$DB,$5F,$FA,$50
    DB $DB,$57,$1C,$15,$20,$88,$CD,$5A,$66,$C9,$AF,$EA,$4C,$DB,$42,$4B
    DB $AF,$21,$51,$DB,$22,$22,$77,$79,$EA,$4F,$DB,$78,$EA,$50,$DB,$79
    DB $CD,$74,$33,$38,$35,$21,$4C,$DB,$34,$79,$CD,$A9,$33,$79,$11,$8B
    DB $DB,$83,$5F,$3E,$00,$8A,$57,$1A,$CB,$47,$28,$07,$3E,$1E,$CD,$B5
    DB $21,$18,$02,$1E,$00,$FA,$51,$DB,$85,$EA,$51,$DB,$FA,$52,$DB,$8C
    DB $EA,$52,$DB,$FA,$53,$DB,$8B,$EA,$53,$DB,$FA,$4F,$DB,$4F,$FA,$50
    DB $DB,$47,$0C,$05,$20,$B1,$FA,$51,$DB,$6F,$FA,$52,$DB,$67,$FA,$53
    DB $DB,$5F,$FA,$4C,$DB,$CD,$ED,$21,$FA,$4C,$DB,$CD,$ED,$21,$7D,$EA
    DB $61,$DB,$7C,$EA,$62,$DB,$FA,$88,$DB,$E6,$04,$5F,$16,$03,$3E,$FF
    DB $EA,$4E,$DB,$7B,$EA,$4C,$DB,$7A,$EA,$4D,$DB,$7B,$CD,$74,$33,$38
    DB $46,$7B,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F,$7B
    DB $CD,$B7,$33,$CD,$14,$33,$28,$2F,$FA,$61,$DB,$4F,$FA,$62,$DB,$47
    DB $CD,$14,$33,$28,$12,$30,$20,$7D,$EA,$61,$DB,$7C,$EA,$62,$DB,$FA
    DB $4C,$DB,$EA,$4E,$DB,$18,$10,$CD,$8C,$48,$FA,$99,$C8,$FE,$80,$38
    DB $06,$FA,$4C,$DB,$EA,$4E,$DB,$FA,$4C,$DB,$5F,$FA,$4D,$DB,$57,$1C
    DB $15,$20,$A0,$FA,$4E,$DB,$FE,$FF,$28,$12,$FA,$88,$DB,$21,$ED,$DC
    DB $87,$85,$6F,$3E,$00,$8C,$67,$FA,$4E,$DB,$77,$C9,$FA,$88,$DB,$E6
    DB $04,$5F,$16,$03,$C3,$DC,$4D,$FA,$88,$DB,$E6,$04,$F6,$02,$4F,$06
    DB $03,$79,$CD,$74,$33,$30,$02,$20,$08,$0D,$05,$20,$F4,$FA,$88,$DB
    DB $4F,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$71,$C9
    DB $CD,$56,$65,$C8,$FA,$88,$DB,$E6,$04,$F6,$02,$4F,$EA,$89,$DB,$06
    DB $03,$79,$21,$02,$DB,$CD,$3B,$33,$CB,$4E,$20,$19,$0D,$05,$20,$F1
    DB $FA,$89,$DB,$4F,$06,$02,$79,$21,$02,$DB,$CD,$3B,$33,$CB,$46,$20
    DB $04,$0D,$05,$20,$F1,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00
    DB $8C,$67,$71,$C9,$CD,$56,$65,$C8,$CD,$7C,$62,$79,$EE,$04,$4F,$79
    DB $CD,$74,$33,$38,$1E,$11,$01,$00,$79,$21,$03,$DB,$CD,$3B,$33,$CB
    DB $56,$20,$13,$79,$21,$E3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$56
    DB $5F,$18,$03,$11,$00,$00,$CD,$92,$62,$0C,$05,$20,$D2,$CD,$9A,$61
    DB $CD,$88,$61,$C9,$CD,$56,$65,$C8,$21,$61,$DB,$7D,$EA,$4C,$DB,$7C
    DB $EA,$4D,$DB,$FA,$88,$DB,$E6,$04,$EA,$4E,$DB,$06,$03,$C5,$FA,$4E
    DB $DB,$CD,$74,$33,$38,$40,$FA,$4E,$DB,$CD,$96,$5C,$FA,$4E,$DB,$CD
    DB $A2,$33,$FA,$6C,$C8,$B7,$20,$07,$FA,$88,$DB,$FE,$04,$30,$0F,$FA
    DB $4E,$DB,$E6,$03,$FE,$03,$FE,$03,$28,$04,$CB,$21,$CB,$10,$CB,$21
    DB $CB,$10,$CD,$14,$33,$30,$0A,$01,$E7,$03,$CD,$14,$33,$30,$02,$18
    DB $08,$21,$FE,$FF,$18,$03,$21,$FF,$FF,$E5,$D1,$FA,$4C,$DB,$6F,$FA
    DB $4D,$DB,$67,$73,$23,$72,$23,$7D,$EA,$4C,$DB,$7C,$EA,$4D,$DB,$C1
    DB $21,$4E,$DB,$34,$05,$20,$96,$21,$61,$DB,$2A,$46,$4F,$21,$63,$DB
    DB $7D,$EA,$4C,$DB,$7C,$EA,$4D,$DB,$FA,$88,$DB,$E6,$04,$EA,$4E,$DB
    DB $3C,$EA,$4F,$DB,$3E,$02,$EA,$50,$DB,$FA,$4C,$DB,$6F,$FA,$4D,$DB
    DB $67,$2A,$66,$6F,$CD,$14,$33,$38,$14,$20,$1A,$F5,$C5,$D5,$E5,$CD
    DB $8C,$48,$E1,$D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$08,$E5,$C1,$FA
    DB $4F,$DB,$EA,$4E,$DB,$FA,$4C,$DB,$6F,$FA,$4D,$DB,$67,$23,$23,$7D
    DB $EA,$4C,$DB,$7C,$EA,$4D,$DB,$21,$4F,$DB,$34,$21,$50,$DB,$35,$FA
    DB $50,$DB,$B7,$20,$B4,$FA,$4E,$DB,$EA,$89,$DB,$FA,$88,$DB,$21,$ED
    DB $DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9,$CD,$4D,$65
    DB $C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38,$3A,$11,$01,$00,$79,$CD
    DB $A2,$33,$FE,$01,$38,$32,$20,$04,$7C,$B7,$28,$2C,$13,$E5,$79,$21
    DB $04,$DB,$CD,$3B,$33,$7E,$E1,$E6,$22,$20,$1D,$E5,$3E,$03,$EA,$4C
    DB $DB,$79,$EA,$89,$DB,$21,$06,$52,$D7,$FA,$4C,$DB,$EE,$30,$E6,$30
    DB $D1,$B2,$57,$18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$B4
    DB $CD,$9A,$61,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33
    DB $38,$46,$11,$01,$00,$79,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C,$67
    DB $2A,$66,$6F,$FE,$01,$38,$34,$20,$04,$67,$B7,$28,$2E,$13,$E5,$79
    DB $21,$04,$DB,$CD,$3B,$33,$7E,$E1,$E6,$22,$20,$1F,$E5,$3E,$03,$EA
    DB $4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7,$FA,$4C,$DB,$07,$07,$EE
    DB $30,$E6,$30,$D1,$B2,$57,$18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C
    DB $05,$20,$A8,$CD,$9A,$61,$C9,$CD,$56,$65,$C8,$21,$61,$DB,$7D,$EA
    DB $4C,$DB,$7C,$EA,$4D,$DB,$FA,$88,$DB,$E6,$04,$EA,$4E,$DB,$06,$03
    DB $C5,$FA,$4E,$DB,$CD,$74,$33,$38,$4A,$FA,$4E,$DB,$CD,$F3,$60,$FA
    DB $4E,$DB,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F,$C5
    DB $01,$FF,$01,$CD,$14,$33,$C1,$30,$25,$FA,$6C,$C8,$B7,$20,$07,$FA
    DB $88,$DB,$FE,$04,$30,$0D,$FA,$4E,$DB,$E6,$03,$FE,$03,$28,$04,$CB
    DB $21,$CB,$10,$CB,$21,$CB,$10,$CD,$14,$33,$30,$02,$18,$08,$21,$FE
    DB $FF,$18,$03,$21,$FF,$FF,$E5,$D1,$FA,$4C,$DB,$6F,$FA,$4D,$DB,$67
    DB $73,$23,$72,$23,$7D,$EA,$4C,$DB,$7C,$EA,$4D,$DB,$C1,$21,$4E,$DB
    DB $34,$05,$20,$8C,$21,$61,$DB,$2A,$46,$4F,$21,$63,$DB,$7D,$EA,$4C
    DB $DB,$7C,$EA,$4D,$DB,$FA,$88,$DB,$E6,$04,$EA,$4E,$DB,$3C,$EA,$4F
    DB $DB,$3E,$02,$EA,$50,$DB,$FA,$4C,$DB,$6F,$FA,$4D,$DB,$67,$2A,$66
    DB $6F,$CD,$14,$33,$38,$14,$20,$1A,$F5,$C5,$D5,$E5,$CD,$8C,$48,$E1
    DB $D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$08,$E5,$C1,$FA,$4F,$DB,$EA
    DB $4E,$DB,$FA,$4C,$DB,$6F,$FA,$4D,$DB,$67,$23,$23,$7D,$EA,$4C,$DB
    DB $7C,$EA,$4D,$DB,$21,$4F,$DB,$34,$21,$50,$DB,$35,$FA,$50,$DB,$B7
    DB $20,$B4,$FA,$4E,$DB,$EA,$89,$DB,$FA,$88,$DB,$21,$ED,$DC,$87,$85
    DB $6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9,$CD,$4D,$65,$C8,$FA,$88
    DB $DB,$E6,$04,$EE,$04,$4F,$06,$03,$C5,$AF,$21,$50,$DB,$22,$22,$77
    DB $79,$CD,$74,$33,$38,$50,$79,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C
    DB $67,$2A,$66,$6F,$CD,$E0,$60,$38,$2C,$79,$CD,$A2,$33,$CD,$E0,$60
    DB $38,$23,$C5,$3E,$02,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7
    DB $C1,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$FA,$4C,$DB
    DB $E6,$30,$77,$18,$20,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C
    DB $67,$3E,$FE,$77,$18,$0F,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00
    DB $8C,$67,$3E,$FF,$77,$0C,$05,$20,$97,$C1,$79,$EA,$4C,$DB,$E6,$03
    DB $21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$7E,$EA,$4D,$DB,$0C,$05,$CD
    DB $0C,$5F,$C9,$CD,$56,$65,$C8,$FA,$88,$DB,$E6,$04,$EA,$89,$DB,$4F
    DB $06,$03,$C5,$79,$CD,$74,$33,$38,$20,$FA,$88,$DB,$B9,$28,$1A,$79
    DB $CD,$B7,$33,$E5,$79,$21,$8B,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$46
    DB $E1,$28,$09,$01,$00,$02,$09,$18,$03,$21,$FF,$FF,$54,$5D,$C1,$79
    DB $E6,$03,$21,$58,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7B,$22,$72,$0C
    DB $05,$20,$BF,$CD,$24,$62,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E
    DB $00,$8C,$67,$7E,$E5,$CD,$74,$33,$E1,$D0,$FA,$88,$DB,$77,$C9,$CD
    DB $4D,$65,$C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38,$31,$11,$01,$00
    DB $79,$CD,$6E,$65,$30,$2B,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$7E,$20
    DB $20,$11,$FF,$00,$D5,$3E,$06,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06
    DB $52,$D7,$FA,$4C,$DB,$EE,$C0,$E6,$C0,$D1,$B2,$57,$18,$03,$11,$00
    DB $00,$CD,$92,$62,$C1,$0C,$05,$20,$BD,$CD,$9A,$61,$C9,$CD,$4D,$65
    DB $C8,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$C5,$AF,$21,$50,$DB
    DB $22,$22,$77,$C5,$79,$CD,$74,$33,$C1,$38,$66,$79,$CD,$A2,$33,$FE
    DB $01,$38,$3C,$20,$04,$7C,$B7,$28,$36,$79,$21,$02,$DB,$CD,$3B,$33
    DB $2A,$E6,$C0,$20,$3B,$23,$23,$7E,$E6,$3F,$20,$34,$C5,$3E,$03,$EA
    DB $4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7,$C1,$79,$E6,$03,$21,$50
    DB $DB,$85,$6F,$3E,$00,$8C,$67,$FA,$4C,$DB,$E6,$30,$77,$18,$31,$79
    DB $E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FD,$77,$18,$20
    DB $79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FE,$77,$18
    DB $0F,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FF,$77
    DB $0C,$05,$C2,$51,$54,$C1,$79,$EA,$4C,$DB,$E6,$03,$21,$50,$DB,$85
    DB $6F,$3E,$00,$8C,$67,$7E,$EA,$4D,$DB,$CD,$0C,$5F,$C9,$CD,$4D,$65
    DB $C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38,$44,$11,$01,$00,$79,$21
    DB $8B,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$66,$20,$36,$11,$02,$00,$79
    DB $21,$02,$DB,$CD,$3B,$33,$2A,$E6,$D0,$20,$27,$23,$23,$7E,$E6,$3F
    DB $20,$20,$11,$FF,$00,$D5,$3E,$05,$EA,$4C,$DB,$79,$EA,$89,$DB,$21
    DB $06,$52,$D7,$FA,$4C,$DB,$EE,$0C,$E6,$0C,$D1,$B2,$57,$18,$03,$11
    DB $00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$AA,$CD,$9A,$61,$C9,$CD,$4D
    DB $65,$C8,$CD,$29,$66,$C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38,$2B
    DB $11,$01,$00,$79,$21,$02,$DB,$CD,$3B,$33,$CB,$7E,$20,$20,$21,$FF
    DB $00,$E5,$3E,$02,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7,$FA
    DB $4C,$DB,$EE,$C0,$E6,$C0,$D1,$B2,$57,$18,$03,$11,$00,$00,$CD,$92
    DB $62,$C1,$0C,$05,$20,$C3,$CD,$9A,$61,$C9,$CD,$4D,$65,$C8,$CD,$7C
    DB $62,$C5,$79,$CD,$74,$33,$38,$2C,$79,$21,$C3,$DB,$87,$85,$6F,$3E
    DB $00,$8C,$67,$2A,$B6,$28,$1D,$3E,$02,$EA,$4C,$DB,$79,$EA,$89,$DB
    DB $21,$06,$52,$D7,$11,$01,$00,$FA,$4C,$DB,$07,$07,$EE,$30,$E6,$30
    DB $B2,$57,$18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$C2,$CD
    DB $9A,$61,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38
    DB $26,$11,$01,$00,$79,$21,$8B,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$46
    DB $28,$18,$79,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$EE,$FF
    DB $5F,$7E,$EE,$FF,$57,$18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C,$05
    DB $20,$C8,$CD,$9A,$61,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$01,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$02,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$03,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$06,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$07,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$08,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$00,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$05,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$7C,$62,$3E,$04,$EA
    DB $4C,$DB,$CD,$FC,$64,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$7C
    DB $62,$C5,$79,$CD,$74,$33,$38,$2B,$11,$01,$00,$79,$21,$02,$DB,$CD
    DB $3B,$33,$7E,$E6,$03,$20,$1F,$11,$FF,$00,$D5,$3E,$04,$EA,$4C,$DB
    DB $79,$EA,$89,$DB,$21,$06,$52,$D7,$FA,$4C,$DB,$E6,$03,$EE,$03,$D1
    DB $57,$18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$C3,$CD,$9A
    DB $61,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$7C,$62,$C5,$79,$CD
    DB $74,$33,$38,$2B,$11,$01,$00,$79,$21,$02,$DB,$CD,$3B,$33,$7E,$E6
    DB $CC,$20,$1F,$11,$FF,$00,$D5,$3E,$05,$EA,$4C,$DB,$79,$EA,$89,$DB
    DB $21,$06,$52,$D7,$FA,$4C,$DB,$E6,$C0,$EE,$C0,$D1,$57,$18,$03,$11
    DB $00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$C3,$CD,$9A,$61,$C9,$CD,$4D
    DB $65,$C8,$CD,$29,$66,$C8,$CD,$7C,$62,$C5,$79,$CD,$74,$33,$38,$32
    DB $11,$01,$00,$79,$21,$02,$DB,$CD,$3B,$33,$2A,$E6,$D0,$20,$26,$23
    DB $23,$7E,$E6,$3F,$20,$1F,$11,$FF,$00,$D5,$3E,$05,$EA,$4C,$DB,$79
    DB $EA,$89,$DB,$21,$06,$52,$D7,$FA,$4C,$DB,$E6,$0C,$EE,$0C,$D1,$57
    DB $18,$03,$11,$00,$00,$CD,$92,$62,$C1,$0C,$05,$20,$BC,$CD,$9A,$61
    DB $C9,$CD,$4D,$65,$C8,$FA,$88,$DB,$E6,$04,$EE,$04,$EA,$4C,$DB,$3C
    DB $EA,$4D,$DB,$3E,$02,$EA,$4E,$DB,$FA,$4C,$DB,$CD,$74,$33,$38,$25
    DB $21,$B3,$DB,$FA,$4C,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F
    DB $21,$D3,$DB,$FA,$4C,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$56,$5F
    DB $CD,$01,$5F,$18,$05,$01,$00,$00,$1E,$00,$21,$56,$DB,$79,$22,$78
    DB $22,$7B,$77,$FA,$4D,$DB,$CD,$74,$33,$38,$25,$21,$B3,$DB,$FA,$4D
    DB $DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F,$21,$D3,$DB,$FA,$4D
    DB $DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$56,$5F,$CD,$01,$5F,$18,$05
    DB $01,$00,$00,$1E,$00,$21,$58,$DB,$7B,$BE,$38,$1D,$20,$0C,$2B,$78
    DB $BE,$38,$16,$20,$05,$2B,$79,$BE,$38,$0F,$21,$56,$DB,$79,$22,$78
    DB $22,$7B,$77,$FA,$4D,$DB,$EA,$4C,$DB,$21,$4D,$DB,$34,$21,$4E,$DB
    DB $35,$FA,$4E,$DB,$B7,$C2,$F1,$57,$FA,$4C,$DB,$EA,$89,$DB,$FA,$88
    DB $DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9
.L586E:
    LD A,C
    LD HL,$DB8B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 0,(HL)
    RET Z
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,$32
    CALL $21B5
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    POP HL
    POP DE
    POP BC
    POP AF
    RET
    DB $CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$19,$5E,$C5,$79,$CD,$74,$33
    DB $38,$3A,$3E,$02,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7,$C1
    DB $C5,$79,$E6,$03,$11,$50,$DB,$83,$5F,$3E,$00,$8A,$57,$FA,$4C,$DB
    DB $E6,$30,$12,$D5,$CD,$2F,$5E,$E1,$28,$02,$CB,$F6,$79,$21,$A3,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$2A,$56,$5F,$18,$12,$79,$E6,$03,$11
    DB $50,$DB,$83,$5F,$3E,$00,$8A,$57,$3E,$FF,$12,$11,$00,$00,$FA,$5E
    DB $DB,$6F,$FA,$5F,$DB,$67,$7B,$22,$7A,$77,$FA,$5E,$DB,$C6,$01,$EA
    DB $5E,$DB,$FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$FA,$5E,$DB,$C6,$01,$EA
    DB $5E,$DB,$FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$C1,$0C,$05,$C2,$A4,$58
    DB $CD,$86,$5D,$CD,$3A,$5E,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD
    DB $19,$5E,$C5,$79,$CD,$74,$33,$38,$3A,$3E,$00,$EA,$4C,$DB,$79,$EA
    DB $89,$DB,$21,$06,$52,$D7,$C1,$C5,$79,$E6,$03,$11,$50,$DB,$83,$5F
    DB $3E,$00,$8A,$57,$FA,$4C,$DB,$E6,$30,$12,$D5,$CD,$2F,$5E,$E1,$28
    DB $02,$CB,$F6,$79,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$56
    DB $5F,$18,$12,$79,$E6,$03,$11,$50,$DB,$83,$5F,$3E,$00,$8A,$57,$3E
    DB $FF,$12,$11,$FF,$FF,$FA,$5E,$DB,$6F,$FA,$5F,$DB,$67,$7B,$22,$7A
    DB $77,$FA,$5E,$DB,$C6,$01,$EA,$5E,$DB,$FA,$5F,$DB,$CE,$00,$EA,$5F
    DB $DB,$FA,$5E,$DB,$C6,$01,$EA,$5E,$DB,$FA,$5F,$DB,$CE,$00,$EA,$5F
    DB $DB,$C1,$0C,$05,$C2,$3B,$59,$CD,$EF,$5C,$CD,$3A,$5E,$C9,$CD,$4D
    DB $65,$C8,$CD,$29,$66,$C8,$CD,$19,$5E,$AF,$EA,$50,$DB,$EA,$51,$DB
    DB $EA,$52,$DB,$EA,$53,$DB,$79,$CD,$74,$33,$38,$24,$11,$01,$00,$79
    DB $21,$08,$DB,$CD,$3B,$33,$CB,$6E,$20,$19,$23,$7E,$E6,$05,$20,$13
    DB $79,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$56,$5F,$18,$03
    DB $11,$00,$00,$FA,$5E,$DB,$6F,$FA,$5F,$DB,$67,$73,$23,$72,$23,$7D
    DB $EA,$5E,$DB,$7C,$EA,$5F,$DB,$0C,$05,$20,$BB,$CD,$86,$5D,$CD,$3A
    DB $5E,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$FA,$6C,$C8,$B7,$C2,$BF
    DB $62,$FA,$88,$DB,$FE,$04,$DA,$BF,$62,$CD,$19,$5E,$79,$EA,$60,$DB
    DB $79,$CD,$74,$33,$38,$24,$16,$FE,$79,$21,$02,$DB,$CD,$3B,$33,$CB
    DB $66,$20,$19,$C5,$3E,$03,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06,$52
    DB $D7,$C1,$FA,$4C,$DB,$E6,$C0,$57,$18,$02,$16,$FF,$7A,$EA,$50,$DB
    DB $79,$EA,$60,$DB,$0C,$05,$79,$CD,$74,$33,$38,$25,$79,$21,$02,$DB
    DB $CD,$3B,$33,$CB,$66,$20,$16,$C5,$3E,$03,$EA,$4C,$DB,$79,$EA,$89
    DB $DB,$21,$06,$52,$D7,$C1,$FA,$4C,$DB,$E6,$C0,$18,$06,$3E,$FE,$18
    DB $02,$3E,$FF,$57,$21,$50,$DB,$BE,$38,$14,$20,$1A,$F5,$C5,$D5,$E5
    DB $CD,$8C,$48,$E1,$D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$08,$7A,$EA
    DB $50,$DB,$79,$EA,$60,$DB,$0C,$05,$C2,$7F,$5A,$CD,$3A,$5E,$C9,$CD
    DB $4D,$65,$C8,$CD,$29,$66,$C8,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06
    DB $03,$C5,$AF,$21,$50,$DB,$22,$22,$77,$C5,$79,$CD,$74,$33,$C1,$38
    DB $4B,$79,$21,$02,$DB,$CD,$3B,$33,$2A,$E6,$C0,$20,$2E,$23,$2A,$E6
    DB $22,$20,$28,$7E,$E6,$3F,$20,$23,$C5,$3E,$02,$EA,$4C,$DB,$79,$EA
    DB $89,$DB,$21,$06,$52,$D7,$C1,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E
    DB $00,$8C,$67,$FA,$4C,$DB,$E6,$C0,$77,$18,$20,$79,$E6,$03,$21,$50
    DB $DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FE,$77,$18,$0F,$79,$E6,$03,$21
    DB $50,$DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FF,$77,$0C,$05,$20,$9A,$C1
    DB $79,$EA,$4C,$DB,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$7E
    DB $EA,$4D,$DB,$CD,$0C,$5F,$C9,$CD,$4D,$65,$C8,$FA,$88,$DB,$E6,$04
    DB $EE,$04,$4F,$06,$03,$C5,$AF,$21,$50,$DB,$22,$22,$77,$C5,$79,$CD
    DB $74,$33,$C1,$38,$47,$79,$CD,$BE,$33,$B4,$28,$40,$79,$21,$04,$DB
    DB $CD,$3B,$33,$7E,$E6,$22,$20,$23,$C5,$3E,$02,$EA,$4C,$DB,$79,$EA
    DB $89,$DB,$21,$06,$52,$D7,$C1,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E
    DB $00,$8C,$67,$FA,$4C,$DB,$E6,$0C,$77,$18,$20,$79,$E6,$03,$21,$50
    DB $DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FE,$77,$18,$0F,$79,$E6,$03,$21
    DB $50,$DB,$85,$6F,$3E,$00,$8C,$67,$3E,$FF,$77,$0C,$05,$20,$9E,$C1
    DB $79,$EA,$4C,$DB,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00,$8C,$67,$7E
    DB $EA,$4D,$DB,$CD,$0C,$5F,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD
    DB $19,$5E,$3E,$00,$EA,$4E,$DB,$3E,$C0,$EA,$4F,$DB,$CD,$A6,$5F,$C9
    DB $CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$19,$5E,$3E,$01,$EA,$4E,$DB
    DB $3E,$30,$EA,$4F,$DB,$CD,$A6,$5F,$C9,$CD,$4D,$65,$C8,$CD,$29,$66
    DB $C8,$CD,$19,$5E,$3E,$01,$EA,$4E,$DB,$3E,$C0,$EA,$4F,$DB,$CD,$A6
    DB $5F,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$19,$5E,$3E,$01,$EA
    DB $4E,$DB,$3E,$0C,$EA,$4F,$DB,$CD,$A6,$5F,$C9,$CD,$4D,$65,$C8,$CD
    DB $29,$66,$C8,$CD,$19,$5E,$3E,$01,$EA,$4E,$DB,$3E,$C0,$EA,$4F,$DB
    DB $CD,$43,$60,$C9,$CD,$4D,$65,$C8,$CD,$29,$66,$C8,$CD,$19,$5E,$3E
    DB $06,$EA,$4E,$DB,$3E,$0C,$EA,$4F,$DB,$CD,$43,$60,$C9,$E5,$47,$FA
    DB $6C,$C8,$B7,$20,$31,$78,$FE,$03,$38,$33,$E6,$03,$FE,$03,$28,$35
    DB $78,$D6,$04,$21,$03,$DA,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F
    DB $7D,$EA,$12,$DA,$7C,$EA,$13,$DA,$21,$01,$14,$D7,$FA,$23,$DA,$4F
    DB $FA,$24,$DA,$47,$18,$1E,$78,$E6,$03,$FE,$03,$28,$08,$21,$1B,$CB
    DB $CD,$1E,$26,$18,$0F,$78,$21,$3C,$DC,$85,$6F,$3E,$00,$8C,$67,$6E
    DB $26,$01,$18,$CC,$E1,$C9
.L5CEF:
    LD HL,$DB58
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD A,$00
    LD ($DB60),A
    LD HL,$DB56
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD DE,$0201
.L5D08:
    PUSH HL
    PUSH DE
    PUSH BC
    CALL .L488C
    LD A,($DB60)
    LD HL,$DB50
    AND $03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD B,A
    LD A,E
    AND $03
    LD HL,$DB50
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP B
    POP BC
    POP DE
    POP HL
    JR C,.L5D50
    JR NZ,.L5D61
    PUSH HL
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    POP HL
    CALL $3314
    JR C,.L5D61
    JR NZ,.L5D5B
    LD A,($C899)
    CP $80
    JR C,.L5D61
    JR .L5D5B
.L5D50:
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
.L5D5B:
    LD H,B
    LD L,C
    LD A,E
    LD ($DB60),A
.L5D61:
    LD A,($DB5E)
    ADD A,$01
    LD ($DB5E),A
    LD A,($DB5F)
    ADC A,$00
    LD ($DB5F),A
    LD A,($DB5E)
    ADD A,$01
    LD ($DB5E),A
    LD A,($DB5F)
    ADC A,$00
    LD ($DB5F),A
    INC E
    DEC D
    JR NZ,.L5D08
    RET
.L5D86:
    LD HL,$DB58
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD A,$00
    LD ($DB60),A
    LD HL,$DB56
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD DE,$0201
.L5D9F:
    PUSH HL
    PUSH DE
    PUSH BC
    CALL .L488C
    LD A,($DB60)
    LD HL,$DB50
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD B,A
    LD A,E
    LD HL,$DB50
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP B
    POP BC
    POP DE
    POP HL
    JR C,.L5DE3
    JR NZ,.L5DF4
    PUSH HL
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    POP HL
    CALL $3314
    JR C,.L5DEE
    JR NZ,.L5DF4
    LD A,($C899)
    CP $80
    JR C,.L5DF4
    JR .L5DEE
.L5DE3:
    LD A,($DB5E)
    LD L,A
    LD A,($DB5F)
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
.L5DEE:
    LD H,B
    LD L,C
    LD A,E
    LD ($DB60),A
.L5DF4:
    LD A,($DB5E)
    ADD A,$01
    LD ($DB5E),A
    LD A,($DB5F)
    ADC A,$00
    LD ($DB5F),A
    LD A,($DB5E)
    ADD A,$01
    LD ($DB5E),A
    LD A,($DB5F)
    ADC A,$00
    LD ($DB5F),A
    INC E
    DEC D
    JR NZ,.L5D9F
    RET
.L5E19:
    LD HL,$DB56
    LD A,L
    LD ($DB5E),A
    LD A,H
    LD ($DB5F),A
    LD A,($DB88)
    AND $04
    XOR $04
    LD C,A
    LD B,$03
    RET
    DB $79,$21,$04,$DB,$CD,$3B,$33,$7E,$E6,$22,$C9,$FA,$60,$DB,$4F,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$81,$EA,$89,$DB,$FA,$88,$DB,$21,$ED,$DC
    DB $87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9
.L5E5B:
    CALL .L5E75
    LD B,$03
    LD D,$00
.L5E62:
    LD A,C
    CALL $3374
    JR C,.L5E6D
    LD A,C
    LD (HL+),A
    INC D
    JR .L5E70
.L5E6D:
    CALL .L66E7
.L5E70:
    INC C
    DEC B
    JR NZ,.L5E62
    RET
.L5E75:
    LD HL,$DB4C
    LD A,($DB88)
    AND $04
    XOR $04
    LD C,A
    RET
.L5E81:
    XOR A
    LD HL,$DB50
    LD (HL+),A
    LD (HL+),A
    LD (HL),A
    CALL .L5CEF
    LD A,($DB60)
    LD HL,$DB4C
    LD DE,$DB4C
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD B,A
    LD A,(HL)
    LD (DE),A
    LD A,B
    LD (HL),A
    LD HL,$DB56
    LD A,($DB60)
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD D,(HL)
    PUSH HL
    LD E,A
    LD HL,$DB56
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    LD A,D
    LD (HL-),A
    LD (HL),E
    POP HL
    LD A,B
    LD (HL-),A
    LD (HL),C
    RET
.L5EBF:
    CALL .L5D86
    LD A,($DB60)
    LD HL,$DB4E
    LD DE,$DB4C
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD B,A
    LD A,(HL)
    LD (DE),A
    LD A,B
    LD (HL),A
    LD HL,$DB56
    LD A,($DB60)
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD D,(HL)
    PUSH HL
    LD E,A
    LD HL,$DB5A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    LD A,D
    LD (HL-),A
    LD (HL),E
    POP HL
    LD A,B
    LD (HL-),A
    LD (HL),C
    RET
    DB $7D,$81,$6F,$7C,$88,$67,$AF,$CE,$00,$4F,$C9,$79,$83,$4F,$78,$8A
    DB $47,$AF,$CE,$00,$5F,$C9,$79,$E6,$03,$21,$50,$DB,$85,$6F,$3E,$00
    DB $8C,$67,$56,$FA,$4D,$DB,$BA,$38,$1C,$20,$12,$F5,$C5,$D5,$E5,$CD
    DB $8C,$48,$E1,$D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$08,$79,$EA,$4C
    DB $DB,$7A,$EA,$4D,$DB,$0C,$05,$20,$CD,$FA,$4C,$DB,$EA,$89,$DB,$FA
    DB $88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77
    DB $C9,$E5,$C5,$79,$CD,$74,$33,$C1,$38,$17,$79,$21,$A3,$DB,$87,$85
    DB $6F,$3E,$00,$8C,$67,$2A,$56,$5F,$79,$CD,$A2,$33,$19,$30,$0A,$18
    DB $05,$3E,$FF,$EA,$4C,$DB,$21,$FF,$FF,$54,$5D,$E1,$C9,$E5,$C5,$79
    DB $CD,$74,$33,$C1,$38,$10,$79,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C
    DB $67,$2A,$56,$5F,$18,$08,$3E,$FF,$EA,$4C,$DB,$11,$FF,$FF,$E1,$C9
    DB $79,$EA,$60,$DB,$C5,$FA,$4E,$DB,$EA,$4C,$DB,$79,$EA,$89,$DB,$21
    DB $06,$52,$D7,$C1,$CD,$57,$5F,$FA,$4C,$DB,$21,$4F,$DB,$A6,$EA,$50
    DB $DB,$21,$56,$DB,$7B,$22,$72,$0C,$05,$C5,$FA,$4E,$DB,$EA,$4C,$DB
    DB $79,$EA,$89,$DB,$21,$06,$52,$D7,$C1,$CD,$57,$5F,$FA,$4C,$DB,$21
    DB $4F,$DB,$A6,$67,$FA,$50,$DB,$BC,$38,$37,$20,$21,$21,$57,$DB,$3A
    DB $BA,$38,$2E,$20,$18,$7E,$BB,$38,$28,$20,$12,$F5,$C5,$D5,$E5,$CD
    DB $8C,$48,$E1,$D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$14,$FA,$4C,$DB
    DB $21,$4F,$DB,$A6,$EA,$50,$DB,$21,$56,$DB,$7B,$22,$72,$79,$EA,$60
    DB $DB,$0C,$05,$20,$A4,$FA,$60,$DB,$EA,$89,$DB,$FA,$88,$DB,$21,$ED
    DB $DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9,$79,$EA,$60
    DB $DB,$C5,$FA,$4E,$DB,$EA,$4C,$DB,$79,$EA,$89,$DB,$21,$06,$52,$D7
    DB $C1,$CD,$83,$5F,$FA,$4C,$DB,$21,$4F,$DB,$A6,$EA,$50,$DB,$21,$56
    DB $DB,$7B,$22,$72,$0C,$05,$C5,$FA,$4E,$DB,$EA,$4C,$DB,$79,$EA,$89
    DB $DB,$21,$06,$52,$D7,$C1,$CD,$83,$5F,$FA,$4C,$DB,$21,$4F,$DB,$A6
    DB $67,$FA,$50,$DB,$BC,$38,$37,$20,$21,$21,$57,$DB,$3A,$BA,$38,$2E
    DB $20,$18,$7E,$BB,$38,$28,$20,$12,$F5,$C5,$D5,$E5,$CD,$8C,$48,$E1
    DB $D1,$C1,$F1,$FA,$99,$C8,$FE,$80,$38,$14,$FA,$4C,$DB,$21,$4F,$DB
    DB $A6,$EA,$50,$DB,$21,$56,$DB,$7B,$22,$72,$79,$EA,$60,$DB,$0C,$05
    DB $20,$A4,$FA,$60,$DB,$EA,$89,$DB,$FA,$88,$DB,$21,$ED,$DC,$87,$85
    DB $6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9,$7C,$B7,$20,$0A,$7D,$B7
    DB $28,$04,$FE,$01,$20,$02,$37,$C9,$3E,$02,$FE,$01,$C9,$E5,$47,$FA
    DB $6C,$C8,$B7,$20,$31,$78,$FE,$03,$38,$32,$E6,$03,$FE,$03,$28,$34
    DB $78,$D6,$04,$21,$03,$DA,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F
    DB $7D,$EA,$12,$DA,$7C,$EA,$13,$DA,$21,$01,$14,$D7,$FA,$25,$DA,$4F
    DB $FA,$26,$DA,$47,$18,$1D,$E6,$03,$FE,$03,$28,$08,$21,$1D,$CB,$CD
    DB $1E,$26,$18,$0F,$78,$21,$3C,$DC,$85,$6F,$3E,$00,$8C,$67,$6E,$26
    DB $01,$18,$CD,$E1,$C9,$E5,$01,$00,$00,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $5F,$16,$03,$AF,$EA,$50,$DB,$7B,$CD,$74,$33,$38,$15,$7B,$21,$03
    DB $DC,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F,$09,$44,$4D,$21,$50
    DB $DB,$34,$1C,$15,$20,$E1,$FA,$50,$DB,$60,$69,$CD,$DC,$21,$44,$4D
    DB $E1,$C9,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$7E
    DB $EE,$04,$77,$C9,$21,$58,$DB,$7D,$EA,$5E,$DB,$7C,$EA,$5F,$DB,$3E
    DB $00,$EA,$60,$DB,$21,$56,$DB,$2A,$66,$6F,$11,$01,$02,$E5,$FA,$5E
    DB $DB,$6F,$FA,$5F,$DB,$67,$2A,$46,$4F,$E1,$CD,$14,$33,$38,$14,$20
    DB $18,$F5,$C5,$D5,$E5,$CD,$8C,$48,$E1,$D1,$C1,$F1,$FA,$99,$C8,$FE
    DB $80,$38,$06,$60,$69,$7B,$EA,$60,$DB,$FA,$5E,$DB,$C6,$01,$EA,$5E
    DB $DB,$FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$FA,$5E,$DB,$C6,$01,$EA,$5E
    DB $DB,$FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$1C,$15,$20,$B0,$FA,$60,$DB
    DB $4F,$FA,$88,$DB,$E6,$04,$EE,$04,$81,$EA,$89,$DB,$FA,$88,$DB,$21
    DB $ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9,$3E,$00
    DB $EA,$60,$DB,$FA,$58,$DB,$6F,$FA,$59,$DB,$67,$FA,$5A,$DB,$4F,$FA
    DB $5B,$DB,$47,$CD,$14,$33,$38,$0D,$3E,$01,$EA,$60,$DB,$FA,$5A,$DB
    DB $6F,$FA,$5B,$DB,$67,$FA,$5C,$DB,$4F,$FA,$5D,$DB,$47,$CD,$14,$33
    DB $38,$05,$3E,$02,$EA,$60,$DB,$FA,$60,$DB,$4F,$FA,$88,$DB,$E6,$04
    DB $81,$EA,$89,$DB,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C
    DB $67,$FA,$89,$DB,$77,$C9,$21,$56,$DB,$7D,$EA,$5E,$DB,$7C,$EA,$5F
    DB $DB,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$C9,$FA,$5E,$DB,$6F
    DB $FA,$5F,$DB,$67,$7B,$22,$7A,$77,$FA,$5E,$DB,$C6,$01,$EA,$5E,$DB
    DB $FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$FA,$5E,$DB,$C6,$01,$EA,$5E,$DB
    DB $FA,$5F,$DB,$CE,$00,$EA,$5F,$DB,$C9,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $EA,$4C,$DB,$CD,$D9,$62,$C9,$FA,$88,$DB,$E6,$04,$EA,$4C,$DB,$CD
    DB $D9,$62,$C9,$FA,$4C,$DB,$4F,$06,$03,$79,$CD,$74,$33,$30,$08,$0C
    DB $05,$20,$F6,$FA,$4C,$DB,$4F,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F
    DB $3E,$00,$8C,$67,$79,$77,$C9,$FA,$69,$DD,$B7,$20,$27,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$79,$CD,$74,$33,$30,$0A,$79,$E6,$03,$FE,$03
    DB $28,$12,$0C,$18,$F0,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00
    DB $8C,$67,$71,$C9,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C
    DB $67,$7E,$4F,$79,$E6,$03,$FE,$03,$38,$0F,$79,$E6,$04,$EE,$04,$47
    DB $FA,$88,$DB,$E6,$04,$B8,$C0,$70,$C9,$0C,$79,$CD,$74,$33,$30,$C5
    DB $79,$E6,$03,$FE,$03,$C8,$0C,$18,$F1,$FA,$88,$DB,$E6,$04,$4F,$18
    DB $86,$FA,$88,$DB,$21,$ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$88
    DB $DB,$77,$C9
Bank88_fn4:
    LD A,($C899)
    LD C,A
    AND $07
    CALL $3374
    JR NC,.L63B4
    LD A,($C89A)
    LD B,A
    AND $07
    CALL $3374
    JR NC,.L63B7
    OR C
    AND $07
    CALL $3374
    LD C,A
    JR NC,.L63B4
    OR B
    AND $07
    CALL $3374
    JR NC,.L63BA
    LD A,B
    ADD A,C
    AND $07
    CALL $3374
    JR NC,.L63BE
.L63A9:
    DEC B
    LD A,B
    AND $07
    CALL $3374
    JR C,.L63A9
    JR .L63B7
.L63B4:
    LD A,C
    JR .L63C0
.L63B7:
    LD A,B
    JR .L63C0
.L63BA:
    LD A,C
    OR B
    JR .L63C0
.L63BE:
    LD A,B
    ADD A,C
.L63C0:
    AND $07
    LD C,A
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD ($DB8A),A
    LD (HL),C
    RET
    DB $FA,$88,$DB,$21,$EC,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$EA,$8A
    DB $DB,$FA,$88,$DB,$77,$C9
.L63EC:
    LD C,E
    LD B,$03
    LD D,$00
.L63F1:
    LD A,C
    CALL $3374
    JR C,.L63F8
    INC D
.L63F8:
    INC C
    DEC B
    JR NZ,.L63F1
    RET
.L63FD:
    CALL .L488C
    LD A,($C899)
    LD B,A
    LD A,D
    PUSH DE
    CALL $21CA
    POP BC
    INC A
    LD E,A
.L640C:
    LD A,C
    CALL $3374
    JR NC,.L6415
.L6412:
    INC C
    JR .L640C
.L6415:
    DEC E
    JR NZ,.L6412
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD ($DB8A),A
    LD A,C
    LD (HL),A
    RET
Bank88_fn5:
    LD A,($DB88)
    AND $04
    XOR $04
    LD E,A
    CALL .L63EC
    CALL .L63FD
    RET
    DB $CD,$8C,$48,$FA,$88,$DB,$E6,$04,$EE,$04,$47,$FA,$99,$C8,$E6,$03
    DB $B0,$4F,$79,$CD,$74,$33,$30,$0F,$79,$D6,$01,$4F,$38,$03,$B8,$30
    DB $F1,$78,$F6,$03,$4F,$18,$EB,$78,$B1,$4F,$FA,$88,$DB,$21,$EC,$DC
    DB $87,$85,$6F,$3E,$00,$8C,$67,$2A,$EA,$8A,$DB,$79,$77,$C9,$FA,$88
    DB $DB,$E6,$04,$5F,$CD,$EC,$63,$CD,$FD,$63,$C9,$FA,$88,$DB,$E6,$04
    DB $47,$FA,$99,$C8,$E6,$03,$B0,$4F,$FA,$88,$DB,$21,$EC,$DC,$87,$85
    DB $6F,$3E,$00,$8C,$67,$7E,$FE,$30,$28,$07,$FE,$31,$28,$03,$79,$18
    DB $1F,$79,$4F,$21,$1B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E,$FE,$FF,$20
    DB $25,$79,$D6,$01,$38,$03,$B8,$30,$E9,$FA,$88,$DB,$F6,$03,$18,$E2
    DB $4F,$CD,$74,$33,$30,$10,$79,$D6,$01,$4F,$38,$03,$B8,$30,$F1,$FA
    DB $88,$DB,$F6,$03,$18,$EA,$FA,$88,$DB,$E6,$04,$B1,$4F,$FA,$88,$DB
    DB $21,$EC,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$EA,$8A,$DB,$79,$77
    DB $C9,$C5,$79,$CD,$74,$33,$38,$1C,$CD,$33,$65,$20,$1C,$C1,$C5,$79
    DB $21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$EE,$FF,$5F,$7E,$EE
    DB $FF,$57,$18,$08,$11,$00,$00,$18,$03,$11,$01,$00,$CD,$92,$62,$C1
    DB $0C,$05,$20,$CD,$CD,$9A,$61,$C9,$79,$21,$3C,$DC,$85,$6F,$3E,$00
    DB $8C,$67,$7E,$EA,$31,$DA,$21,$01,$03,$D7,$FA,$33,$DA,$21,$4C,$DB
    DB $BE,$C9
.L654D:
    CALL .L655F
    RET NZ
    CALL Bank88_fn5
    XOR A
    RET
    DB $CD,$5F,$65,$C0,$CD,$79,$64,$AF,$C9
.L655F:
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR A
    RET
    DB $21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$06,$08,$7E,$FE,$43
    DB $28,$1B,$FE,$5C,$38,$10,$FE,$64,$38,$13,$FE,$6A,$38,$08,$FE,$6E
    DB $38,$0B,$FE,$8F,$28,$07,$23,$23,$05,$20,$E2,$AF,$C9,$37,$C9,$C5
    DB $D5,$E5,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$1E,$00,$16,$00
    DB $79,$D5,$CD,$74,$33,$D1,$38,$19,$1C,$79,$21,$06,$DB,$CD,$3B,$33
    DB $2A,$E6,$0C,$20,$0B,$23,$2A,$E6,$28,$20,$05,$7E,$E6,$07,$28,$01
    DB $14,$0C,$05,$20,$DB,$7A,$BB,$28,$03,$37,$18,$04,$3E,$0A,$FE,$01
    DB $E1,$D1,$C1,$C9,$E5,$FA,$89,$DB,$CD,$74,$33,$38,$1C,$FA,$89,$DB
    DB $21,$06,$DB,$CD,$3B,$33,$2A,$E6,$0C,$20,$0E,$23,$2A,$E6,$28,$20
    DB $08,$7E,$E6,$07,$20,$03,$37,$18,$04,$3E,$0A,$FE,$01,$E1,$C9
.L660D:
    PUSH HL
    LD A,C
    CALL $3374
    JR C,.L6623
    LD A,C
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    JR NZ,.L6623
    SCF
    JR .L6627
.L6623:
    LD A,$0A
    CP $01
.L6627:
    POP HL
    RET
    DB $FA,$88,$DB,$21,$0B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E,$FE,$02,$28
    DB $1C,$FA,$88,$DB,$E6,$03,$FE,$03,$28,$0D,$FA,$6C,$C8,$B7,$20,$0D
    DB $FA,$88,$DB,$FE,$04,$38,$06,$CD,$E2,$4C,$AF,$B7,$C9,$3E,$01,$B7
    DB $C9,$3E,$00,$EA,$5E,$DB,$3E,$01,$EA,$5F,$DB,$3E,$02,$EA,$60,$DB
    DB $FA,$5F,$DB,$21,$58,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F
    DB $FA,$5E,$DB,$21,$58,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F
    DB $CD,$14,$33,$38,$27,$20,$2B,$FA,$5F,$DB,$21,$61,$DB,$87,$85,$6F
    DB $3E,$00,$8C,$67,$2A,$46,$4F,$FA,$5E,$DB,$21,$61,$DB,$87,$85,$6F
    DB $3E,$00,$8C,$67,$2A,$66,$6F,$CD,$14,$33,$30,$06,$FA,$5F,$DB,$EA
    DB $5E,$DB,$21,$5F,$DB,$34,$FA,$60,$DB,$3D,$EA,$60,$DB,$20,$A1,$FA
    DB $5E,$DB,$4F,$FA,$88,$DB,$E6,$04,$81,$EA,$89,$DB,$FA,$88,$DB,$21
    DB $ED,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$89,$DB,$77,$C9
.L66E7:
    PUSH HL
    PUSH DE
    LD A,C
    AND $03
    CP $02
    JR Z,.L6734
    CP $01
    JR Z,.L6714
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,($DB58)
    LD E,A
    LD A,($DB59)
    LD D,A
    LD A,L
    LD ($DB58),A
    LD A,H
    LD ($DB59),A
    LD A,E
    LD ($DB56),A
    LD A,D
    LD ($DB57),A
.L6714:
    LD A,($DB58)
    LD L,A
    LD A,($DB59)
    LD H,A
    LD A,($DB5A)
    LD E,A
    LD A,($DB5B)
    LD D,A
    LD A,L
    LD ($DB5A),A
    LD A,H
    LD ($DB5B),A
    LD A,E
    LD ($DB58),A
    LD A,D
    LD ($DB59),A
.L6734:
    POP DE
    POP HL
    RET
Bank88_fn13:
    LD A,($DB88)
    CP $10
    JR Z,.L6750
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD ($DB4C),A
    CALL .L6794
    RET
.L6750:
    LD HL,$DB78
    LD A,(HL-)
    LD ($DB4C),A
    CP $C2
    JR C,.L6794
    CP $C7
    JR NC,.L6794
    LD A,(HL)
    CP $04
    RET C
    AND $04
    LD C,A
    LD B,$03
    LD D,$FF
.L676A:
    LD A,C
    CALL $3374
    JR NC,.L677B
.L6770:
    INC C
    DEC B
    JR NZ,.L676A
    LD A,D
    CP $FF
    RET Z
    LD C,D
    JR .L678D
.L677B:
    LD A,D
    CP $FF
    CALL Z,.L6792
    LD A,C
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $C0
    JR NZ,.L6770
.L678D:
    LD HL,$DB77
    LD (HL),C
    RET
.L6792:
    LD D,C
    RET
.L6794:
    LD A,$00
    LD ($DB4D),A
    LD A,$02
    LD ($DB4E),A
    PUSH HL
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    POP HL
    LD A,($DB4C)
    AND $03
    CP $01
    RET Z
.L67AC:
    LD A,(HL)
    CALL $3374
    RET NC
    LD A,(HL)
    AND $03
    CP $02
    RET Z
    INC (HL)
    JR .L67AC
Bank88_fn11:
    LD A,$14
    LD ($DD26),A
    CALL .L68A5
    LD A,($DB88)
    CALL $339B
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    CALL $3314
    JP C,.L6859
    LD HL,$DD26
    LD B,$0A
    CALL .L6918
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    SRL B
    RR C
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    ADD HL,BC
    PUSH HL
    LD A,($DB88)
    CALL $339B
    POP BC
    CALL $3314
    JR C,.L6859
    LD HL,$DD26
    LD B,$0A
    CALL .L6918
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    ADD HL,BC
    PUSH HL
    LD A,($DB88)
    CALL $339B
    POP BC
    CALL $3314
    JR C,.L6859
    LD HL,$DD26
    LD B,$0A
    CALL .L6918
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    ADD HL,HL
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    SRL B
    RR C
    ADD HL,BC
    PUSH HL
    LD A,($DB88)
    CALL $339B
    POP BC
    CALL $3314
    JR C,.L6859
    LD HL,$DD26
    LD B,$0A
    CALL .L6918
.L6859:
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    LD A,(HL+)
    AND $0C
    JR NZ,.L686E
    INC HL
    INC HL
    LD A,(HL)
    AND $03
    JR Z,.L6876
.L686E:
    LD HL,$DD26
    LD B,$1E
    CALL .L6918
.L6876:
    LD A,($DB88)
    AND $04
    XOR $04
    LD C,A
    LD B,$03
.L6880:
    LD A,C
    CALL $3374
    JR C,.L689B
    LD A,C
    LD HL,$DB06
    CALL $333B
    LD A,(HL+)
    AND $0C
    JR NZ,.L689B
    INC HL
    BIT 5,(HL)
    JR NZ,.L689B
    INC HL
    BIT 2,(HL)
    RET Z
.L689B:
    INC C
    DEC B
    JR NZ,.L6880
    LD A,$01
    LD ($DD26),A
    RET
.L68A5:
    LD A,($DB88)
    AND $04
    XOR $04
    LD C,A
    LD B,$03
.L68AF:
    LD A,C
    CALL $3374
    JR C,.L68C5
    LD A,C
    LD HL,$DBF3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    JR .L68C8
.L68C5:
    LD DE,$FFFF
.L68C8:
    LD A,$03
    SUB B
    LD HL,$DB58
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),E
    INC HL
    LD (HL),D
    INC C
    DEC B
    JR NZ,.L68AF
    LD A,($DB58)
    LD L,A
    LD A,($DB59)
    LD H,A
    LD A,($DB5A)
    LD C,A
    LD A,($DB5B)
    LD B,A
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    CALL $3314
    JR C,.L6903
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    LD H,B
    LD L,C
.L6903:
    LD A,($DB5C)
    LD C,A
    LD A,($DB5D)
    LD B,A
    CALL $3314
    RET C
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    RET
.L6918:
    LD A,(HL)
    ADD A,B
    LD (HL),A
    RET NC
    LD A,$FF
    LD (HL),A
    RET
