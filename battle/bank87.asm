; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 87  (Battle menu sub-screens / status detail)
; ============================================================================
;
; File offset $15C000-$15FFFF  (16 KB, mapped at $4000-$7FFF)
;
; Support bank for the battle command/status menu. fn0 ($4013) dispatches on
; wBattleMenuSub ($D9EE) via RST $00 into 8 sub-screens; the remaining fns are
; per-line/per-field renderers invoked from bank82/83.
;
; Callers: bank82 (7x) and bank88 (via fn6/fn7/fn8). Calls back into bank82/88.
; ============================================================================

SECTION "Bank87_ID", ROMX[$4000], BANK[87]
    DB $57

SECTION "Bank87_JumpTable", ROMX[$4001], BANK[87]
    DW BattleSub_Dispatch               ; fn0 @ $4013
    DW Bank87_fn1                       ; fn1 @ $4E49
    DW Bank87_fn2                       ; fn2 @ $51D6
    DW Bank87_fn3                       ; fn3 @ $524D
    DW Bank87_fn4                       ; fn4 @ $52F9
    DW Bank87_fn5                       ; fn5 @ $5355
    DW Bank87_fn6                       ; fn6 @ $53B1
    DW Bank87_fn7                       ; fn7 @ $540D
    DW Bank87_fn8                       ; fn8 @ $5469

SECTION "Bank87_Code", ROMX[$4013], BANK[87]
BattleSub_Dispatch:
    LD A,($D9EE)
    RST $00
    DW .L402F                           ; state 0
    DW .L432E                           ; state 1
    DW .L45BE                           ; state 2
    DW .L472E                           ; state 3
    DW .L463E                           ; state 4
    DW .L47A7                           ; state 5
    DW .L4A5E                           ; state 6
    DW .L4A6A                           ; state 7
.L4027:
    LD A,$06
    LD ($D9EE),A
    JP .L4A5E
.L402F:
    LD A,($D9ED)
    CP $16
    JR C,.L4055
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$FF
    LD (HL+),A
    LD (HL),A
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$01
.L4055:
    LD HL,$DCE4
    LD BC,$0008
    XOR A
    CALL $169A
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $01
    JR NZ,.L4027
    LD HL,$DCFC
    LD BC,$0007
    XOR A
    CALL $169A
    XOR A
    LD ($DB50),A
    LD ($DB51),A
    LD ($DB52),A
    LD A,($DB88)
    CALL $3345
    JR C,.L40BE
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    JR NZ,.L40BE
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 6,(HL)
    JR Z,.L40C6
    LD A,($DB88)
    CP $03
    JR C,.L4124
    JR Z,.L40BE
    CP $07
    JR Z,.L40BE
    LD A,($C86C)
    OR A
    JR Z,.L40BE
    JR .L4124
.L40BE:
    LD HL,$D9EE
    INC (HL)
    JP .L432E
    DB $C9
.L40C6:
    LD A,($C86C)
    OR A
    JR NZ,.L40D1
    LD A,($C8DA)
    JR .L40E0
.L40D1:
    LD A,($DB88)
    CP $04
    JR NC,.L40DD
    LD A,($C1D5)
    JR .L40E0
.L40DD:
    LD A,($C1D6)
.L40E0:
    LD ($DD72),A
    LD A,(HL)
    CALL .L4AD9
    CALL .L4B0A
    CALL .L4B1F
    CALL .L4C08
    CALL .L4C1B
    CALL .L4C62
    JP NC,.L4191
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$FF
    LD (HL+),A
    LD (HL),A
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    SET 6,(HL)
    LD A,($DD72)
    CP $81
    JP NZ,.L432E
    LD HL,$D9EE
    INC (HL)
.L4124:
    LD A,($D9ED)
    CP $01
    JR NZ,.L4169
    LD A,($DB88)
    CALL $3374
    JP C,.L432E
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    AND $DC
    JP NZ,.L432E
    INC HL
    INC HL
    INC HL
    LD A,(HL)
    AND $1F
    JP NZ,.L432E
    INC HL
    BIT 2,(HL)
    JP NZ,.L432E
    INC HL
    LD A,(HL)
    AND $D0
    JP NZ,.L432E
    CALL .L5087
    LD A,$B4
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
.L4169:
    LD A,$06
    LD ($D9EE),A
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    LD (HL+),A
    LD A,(HL)
    AND $CF
    LD (HL),A
    CALL .L5164
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),B
    RET
.L4191:
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD B,A
    CP $03
    JR NZ,.L41C1
    LD A,($DD72)
    CP $81
    JR Z,.L41D7
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$3A
    LD A,$06
    LD ($D9EE),A
    JP .L4A5E
.L41C1:
    LD HL,$DB50
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DD72)
    CP $81
    JR Z,.L41D5
    LD (HL),$14
    JR .L41D7
.L41D5:
    LD (HL),$2D
.L41D7:
    LD A,($D9EC)
    CP $05
    JR Z,.L41E5
    LD HL,$D9EE
    INC (HL)
    JP .L432E
.L41E5:
    LD A,($C86C)
    OR A
    JP NZ,.L432E
    LD A,($DD72)
    CP $81
    JP NZ,.L432E
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $03
    JR Z,.L421C
    CP $02
    JR Z,.L4217
    CP $01
    JR Z,.L4212
    LD HL,$42AE
    JR .L421F
.L4212:
    LD HL,$42CE
    JR .L421F
.L4217:
    LD HL,$42EE
    JR .L421F
.L421C:
    LD HL,$430E
.L421F:
    LD DE,$0000
    LD A,($DB88)
    LD BC,$DC5C
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,(BC)
    CP $97
    JR C,.L4235
    LD D,$10
.L4235:
    LD A,($DB88)
    LD BC,$DB9B
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,(BC)
    CP $0A
    JR C,.L4255
    CP $14
    JR C,.L4250
    CP $1E
    JR C,.L424F
    INC E
.L424F:
    INC E
.L4250:
    INC E
    LD A,E
    ADD A,A
    ADD A,A
    LD E,A
.L4255:
    LD A,D
    ADD A,E
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB88)
    LD BC,$DC44
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    CALL .L4297
    INC HL
    LD A,$08
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    CALL .L4297
    INC HL
    LD A,$08
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    CALL .L4297
    INC HL
    LD A,$08
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    CALL .L4297
    LD HL,$D9EE
    INC (HL)
    JP .L432E
.L4297:
    BIT 7,(HL)
    JR NZ,.L42A3
    LD A,(BC)
    ADD A,(HL)
    JR NC,.L42AC
    LD A,$FF
    JR .L42AC
.L42A3:
    LD A,(HL)
    CPL
    INC A
    LD D,A
    LD A,(BC)
    SUB D
    JR NC,.L42AC
    XOR A
.L42AC:
    LD (BC),A
    RET
    DB $07,$FF,$00,$03,$05,$FF,$00,$02,$03,$FF,$00,$01,$02,$FF,$00,$01
    DB $0A,$FF,$00,$04,$07,$FF,$00,$03,$05,$FF,$00,$02,$05,$00,$00,$01
    DB $00,$07,$FE,$03,$00,$05,$FE,$02,$00,$04,$FF,$01,$00,$03,$FF,$01
    DB $00,$0A,$FD,$04,$00,$07,$FE,$03,$00,$05,$FF,$02,$00,$05,$00,$01
    DB $FE,$00,$07,$03,$FE,$00,$05,$02,$FF,$00,$04,$01,$FF,$00,$03,$01
    DB $FE,$00,$0A,$04,$FE,$00,$07,$03,$FF,$00,$05,$02,$00,$00,$05,$01
    DB $00,$00,$00,$FF,$00,$00,$00,$FE,$00,$00,$00,$FE,$00,$00,$00,$FF
    DB $00,$00,$00,$FF,$00,$00,$00,$FE,$00,$00,$00,$FE,$00,$00,$00,$FF
.L432E:
    LD A,($C86C)
    OR A
    JR Z,.L4345
    LD A,($DB88)
    CP $04
    JR NC,.L4340
    LD A,($C1D5)
    JR .L4348
.L4340:
    LD A,($C1D6)
    JR .L4348
.L4345:
    LD A,($C8DA)
.L4348:
    CP $81
    JR NZ,.L4365
    LD A,($DB88)
    CP $03
    JR Z,.L4365
    CP $07
    JR Z,.L4365
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $03
    JR Z,.L4391
.L4365:
    CALL .L43BE
    LD A,($DB76)
    OR A
    CALL Z,.L43A0
    CALL .L4527
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR A
    JR Z,.L4389
    LD HL,$D9EE
    INC (HL)
    JP .L45BE
.L4389:
    LD A,$05
    LD ($D9EE),A
    JP .L47A7
.L4391:
    LD A,$06
    LD ($D9EE),A
    JP .L4A5E
    DB $CD,$31,$51,$FA,$99,$C8,$C9
.L43A0:
    LD A,($DB88)
    CP $04
    JR NC,.L43AD
    LD A,($C8DA)
    CP $81
    RET Z
.L43AD:
    LD A,($DCFE)
    CP $1E
    JR NC,.L43B8
    LD A,$00
    JR .L43BA
.L43B8:
    SUB $1E
.L43BA:
    LD ($DCFE),A
    RET
.L43BE:
    LD C,$00
    LD D,C
    LD A,($C86C)
    OR A
    JR NZ,.L43CE
    LD A,($DB88)
    CP $03
    JR NC,.L43D4
.L43CE:
    LD D,$01
    LD A,($DB50)
    LD C,A
.L43D4:
    LD A,($DB88)
    LD HL,$DC44
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    LD HL,$DCFC
    CALL .L44D3
    LD A,D
    OR A
    JR NZ,.L43ED
    JR .L440B
.L43ED:
    LD A,($C86C)
    OR A
    JR NZ,.L43F8
    LD A,($C8DA)
    JR .L4407
.L43F8:
    LD A,($C863)
    BIT 1,A
    JR NZ,.L4404
    LD A,($C1D5)
    JR .L4407
.L4404:
    LD A,($C1D6)
.L4407:
    CP $81
    JR Z,.L442D
.L440B:
    LD A,($DB88)
    LD HL,$DB03
    ADD A,A
    ADD A,A
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    AND $0C
    JR NZ,.L4426
    INC HL
    INC HL
    LD A,(HL)
    AND $33
    JR Z,.L442D
.L4426:
    LD A,$1E
    LD HL,$DCFC
    ADD A,(HL)
    LD (HL),A
.L442D:
    LD A,($DB51)
    LD C,A
    LD A,($DB88)
    LD HL,$DC4C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    LD HL,$DCFD
    CALL .L44D3
    LD A,($DB52)
    LD C,A
    LD A,($DB88)
    LD HL,$DC54
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    LD HL,$DCFE
    CALL .L44D3
    LD A,($DB88)
    LD D,A
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    RET NZ
    LD A,($DB88)
    CP $04
    JR C,.L4478
    LD A,($DB75)
    JR .L447B
.L4478:
    LD A,($DB74)
.L447B:
    LD B,A
    LD A,($DB88)
    AND $04
    LD C,A
.L4482:
    LD A,C
    CALL $3374
    JR C,.L449D
    PUSH BC
    CALL $33A9
    PUSH HL
    LD A,C
    CALL $33B7
    ADD HL,HL
    LD B,H
    LD C,L
    ADD HL,BC
    ADD HL,BC
    POP BC
    CALL $3314
    POP BC
    JR C,.L44A2
.L449D:
    INC C
    DEC B
    JR NZ,.L4482
    RET
.L44A2:
    LD A,($DB88)
    LD HL,$DC65
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,$08
.L44B2:
    LD A,(HL+)
    CP $FF
    RET Z
    CP $2B
    JR C,.L44C6
    CP $30
    JR C,.L44CB
    CP $93
    JR Z,.L44CB
    CP $94
    JR Z,.L44CB
.L44C6:
    INC HL
    DEC B
    JR NZ,.L44B2
    RET
.L44CB:
    LD A,$1E
    LD HL,$DCFE
    ADD A,(HL)
    LD (HL),A
    RET
.L44D3:
    PUSH HL
    PUSH DE
    LD A,B
    LD ($DD72),A
    CALL .L4AD3
    LD A,C
    ADD A,B
    LD B,A
    CALL .L5131
    PUSH BC
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    LD A,($C86C)
    OR A
    JR NZ,.L451B
    LD A,($DB88)
    CP $03
    JR C,.L451B
    LD A,($DD72)
    CP $32
    JR C,.L450F
    CP $64
    JR C,.L4513
    CP $96
    JR C,.L4517
    CP $C8
    JR C,.L451B
    LD A,$0A
    JR .L451D
.L450F:
    LD A,$1E
    JR .L451D
.L4513:
    LD A,$19
    JR .L451D
.L4517:
    LD A,$14
    JR .L451D
.L451B:
    LD A,$0A
.L451D:
    CALL $21DC
    POP BC
    POP DE
    ADD A,B
    LD B,A
    POP HL
    LD (HL),B
    RET
.L4527:
    LD A,$01
    LD ($DCFF),A
    LD A,$02
    LD ($DD00),A
    LD A,$03
    LD ($DD01),A
    LD A,($DCFC)
    LD L,A
    LD A,($DCFD)
    LD C,A
    XOR A
    LD H,A
    LD B,A
    CALL $3314
    JR NC,.L4552
    LD L,C
    LD H,B
    LD A,$02
    LD ($DCFF),A
    LD A,$01
    LD ($DD00),A
.L4552:
    LD A,($DCFE)
    LD C,A
    LD B,$00
    CALL $3314
    JR NC,.L456B
    LD A,($DCFF)
    LD B,A
    LD A,($DD01)
    LD ($DCFF),A
    LD A,B
    LD ($DD01),A
.L456B:
    CALL .L45AA
    CALL Z,.L45B6
    LD A,($DD01)
    DEC A
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    LD B,$00
    LD A,($DD00)
    DEC A
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$00
    CALL $3314
    JR NC,.L45A4
    LD A,($DD00)
    LD B,A
    LD A,($DD01)
    LD ($DD00),A
    LD A,B
    LD ($DD01),A
.L45A4:
    LD A,$03
    LD ($DD02),A
    RET
.L45AA:
    LD A,($DD00)
    CP $01
    RET Z
    LD A,($DD01)
    CP $01
    RET
.L45B6:
    LD HL,$DCFC
    LD A,$1E
    ADD A,(HL)
    LD (HL),A
    RET
.L45BE:
    LD A,($DD02)
    CP $06
    JR Z,.L45F2
    CP $04
    JR Z,.L45F6
    CP $03
    JR Z,.L45DE
    LD B,A
    DEC A
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $01
    JR Z,.L45F2
    LD A,B
.L45DE:
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DD6A),A
    LD HL,$D9EE
    INC (HL)
    JP .L472E
.L45F2:
    LD C,$3A
    JR .L461D
.L45F6:
    LD A,($DCFF)
    CP $01
    JR Z,.L45F2
    CP $03
    LD A,($DD02)
    JR NZ,.L45DE
    LD A,($D9ED)
    CP $15
    LD A,($DD02)
    JR NC,.L45F2
    CALL .L49A9
    LD A,($DD02)
    JR NZ,.L45DE
    CALL .L49B9
    JR NC,.L45F2
    LD C,$8D
.L461D:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),C
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    JP .L4A5E
.L463E:
    LD A,($C1FE)
    LD L,A
    LD A,($C1FF)
    LD H,A
.L4646:
    LD A,(HL)
    OR A
    JP Z,.L46CF
    LD A,($DD6A)
    CP (HL)
    JR NZ,.L468C
    XOR A
    LD ($DD26),A
    LD ($DD27),A
    INC HL
    LD A,(HL)
    LD ($DB8A),A
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,$07
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    LD ($DD6B),A
    LD A,($DD6A)
    DEC A
    LD HL,$54C5
    CALL .L572A
    LD A,L
    LD ($C1FA),A
    LD A,H
    LD ($C1FB),A
    LD A,$07
    LD ($D9EE),A
    RET
.L468C:
    LD A,($C1FC)
    LD HL,$DCE4
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    XOR A
    LD (HL),A
    LD ($DD26),A
    LD ($DD27),A
.L46A0:
    LD A,($C1FE)
    LD L,A
    LD A,($C1FF)
    LD H,A
    INC HL
    INC HL
    LD A,L
    LD ($C1FE),A
    LD A,H
    LD ($C1FF),A
    LD A,($C1FC)
    LD C,A
    LD A,($C1FD)
    LD B,A
    INC C
    DEC B
    LD A,C
    LD ($C1FC),A
    LD A,B
    LD ($C1FD),A
    JP NZ,.L4646
.L46C7:
    LD A,$05
    LD ($D9EE),A
    JP .L47A7
.L46CF:
    LD A,($C1FC)
    LD HL,$DCE4
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    XOR A
.L46DC:
    LD (HL+),A
    DEC B
    JR NZ,.L46DC
    JR .L46C7
    DB $E5,$D5,$C5,$7E,$EA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB,$3E
    DB $07,$EA,$4E,$DB,$21,$00,$54,$D7,$FA,$4C,$DB,$EA,$6B,$DD,$FA,$6A
    DB $DD,$3D,$21,$C5,$54,$CD,$2A,$57,$CD,$11,$47,$C1,$D1,$E1,$C9,$2A
    DB $57,$3A,$B2,$28,$12,$E5,$CD,$2A,$47,$E1,$FA,$27,$DD,$FE,$FF,$28
    DB $06,$23,$23,$E5,$E1,$18,$E8,$C9,$2A,$66,$6F,$E9
.L472E:
    LD BC,$0800
    LD A,($DB88)
    LD HL,$DC65
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
.L473F:
    LD A,(HL)
    CP $FF
    JR Z,.L4779
    PUSH HL
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,$03
    LD ($DB4E),A
    PUSH BC
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    POP BC
    LD A,C
    LD HL,$DCE4
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB4C)
    ADD A,(HL)
    LD (HL),A
    JR NC,.L476B
    LD (HL),$FF
.L476B:
    PUSH HL
    LD A,$10
    CALL .L4C98
    POP HL
    ADD A,(HL)
    LD (HL),A
    JR NC,.L4778
    LD (HL),$FF
.L4778:
    POP HL
.L4779:
    INC HL
    INC HL
    INC C
    DEC B
    JR NZ,.L473F
    LD HL,$D9EE
    INC (HL)
    LD BC,$0800
    LD A,C
    LD ($C1FC),A
    LD A,B
    LD ($C1FD),A
    LD A,($DB88)
    LD HL,$DC64
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,L
    LD ($C1FE),A
    LD A,H
    LD ($C1FF),A
    JP .L463E
.L47A7:
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    JP NZ,.L48C2
    INC HL
    INC HL
    INC HL
    INC HL
    BIT 2,(HL)
    JP NZ,.L48BA
    INC HL
    BIT 4,(HL)
    JP NZ,.L48CA
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR A
    JP Z,.L48E4
    LD HL,$DCE4
    LD BC,$0701
    LD D,(HL)
    INC HL
    LD E,$00
.L47DF:
    LD A,D
    OR A
    JR NZ,.L47F1
    LD A,(HL+)
    LD D,A
    INC E
    INC C
    DEC B
    JR NZ,.L47DF
    LD A,D
    OR A
    JP Z,.L48AE
    JR .L47FF
.L47F1:
    LD A,(HL)
    CP D
    JP Z,.L48A0
    JR C,.L47FA
.L47F8:
    LD D,(HL)
    LD E,C
.L47FA:
    INC HL
    INC C
    DEC B
    JR NZ,.L47F1
.L47FF:
    LD A,($DD02)
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $01
    JR Z,.L4855
    CP $02
    JR Z,.L4833
    LD A,D
    CP $14
    JR NC,.L4837
    LD A,($D9ED)
    CP $15
    JP NC,.L48AE
    CALL .L49A9
    JP NZ,.L48AE
    CALL .L49B9
    JP NC,.L488B
    CALL .L48D2
    LD (HL),$8D
    RET
.L4833:
    LD A,D
    OR A
    JR Z,.L48AE
.L4837:
    CALL .L48D2
    PUSH HL
    LD A,($DB88)
    LD HL,$DC65
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,E
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
    LD (HL),A
    RET
.L4855:
    PUSH DE
    LD HL,$580B
    RST $10  ; -> bank88/fn11
    LD A,($DD26)
    POP DE
    CP D
    JR NC,.L488B
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    LD A,($DB88)
    LD HL,$DC65
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,E
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
    CP $FF
    JR NZ,.L489A
.L488B:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$3A
.L489A:
    LD (HL),A
    LD HL,$D9EE
    INC (HL)
    RET
.L48A0:
    CALL .L5131
    LD A,($C899)
    BIT 0,A
    JP Z,.L47FA
    JP .L47F8
.L48AE:
    LD HL,$DD02
    INC (HL)
    LD A,$02
    LD ($D9EE),A
    JP .L45BE
.L48BA:
    CALL .L48D2
    LD (HL),$42
    JP .L4A5E
.L48C2:
    CALL .L48D2
    LD (HL),$3A
    JP .L4A5E
.L48CA:
    CALL .L48D2
    LD (HL),$95
    JP .L4A5E
.L48D2:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    RET
.L48E4:
    LD B,$0A
    LD HL,$DB61
    XOR A
.L48EA:
    LD (HL+),A
    DEC B
    JR NZ,.L48EA
.L48EE:
    LD A,($DD02)
    LD HL,$DCFC
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD D,(HL)
    LD E,$00
    LD HL,$DC64
    LD A,($DB88)
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD BC,$0800
.L490E:
    LD A,(HL+)
    CP D
    JR NZ,.L4929
    PUSH HL
    CALL .L5131
    LD HL,$DB61
    LD A,C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($C899)
    AND $07
    INC A
    LD (HL),A
    POP HL
    INC E
.L4929:
    INC HL
    INC C
    DEC B
    JR NZ,.L490E
    CALL .L5131
    LD A,D
    CP $02
    JR Z,.L4946
    LD HL,$DB69
    CP $01
    JR Z,.L493E
    INC HL
.L493E:
    LD A,($C89A)
    AND $07
    INC A
    LD (HL),A
    INC E
.L4946:
    LD A,E
    OR A
    JR NZ,.L4966
    LD A,D
    CP $02
    JR NZ,.L4955
    LD HL,$DD02
    INC (HL)
    JR .L48EE
.L4955:
    CP $03
    JR Z,.L495D
.L4959:
    LD B,$3A
    JR .L49A5
.L495D:
    CALL .L49A9
    JR NZ,.L4959
    LD B,$8D
    JR .L49A5
.L4966:
    LD BC,$0A00
    LD HL,$DB61
.L496C:
    LD A,(HL+)
    OR A
    JR NZ,.L4978
    INC C
    DEC B
    JR NZ,.L496C
    LD B,$3A
    JR .L49A5
.L4978:
    LD D,A
    LD E,C
    INC C
.L497B:
    LD A,(HL+)
    CP D
    JR C,.L4981
    LD D,A
    LD E,C
.L4981:
    INC C
    DEC B
    JR NZ,.L497B
    LD A,E
    CP $09
    JR NC,.L495D
    CP $08
    JR Z,.L4959
    LD A,($DB88)
    LD HL,$DC65
    SWAP A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,E
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
.L49A5:
    CALL .L48D2
    LD (HL),B
.L49A9:
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    RET
.L49B9:
    LD A,($DB88)
    LD C,A
    AND $03
    CP $03
    JR Z,.L49F7
    LD A,($C86C)
    OR A
    JR NZ,.L49CD
    BIT 2,C
    JR NZ,.L49F7
.L49CD:
    LD A,C
    XOR $04
    AND $04
    LD C,A
    CALL .L49FA
    JR NC,.L49F5
    INC C
    CALL .L49FA
    JR NC,.L49F5
    INC C
    CALL .L49FA
    JR NC,.L49F5
    CALL .L4A2D
    JR NC,.L49F7
    DEC C
    CALL .L4A2D
    JR NC,.L49F7
    DEC C
    CALL .L4A2D
    JR NC,.L49F7
.L49F5:
    SCF
    RET
.L49F7:
    SCF
    CCF
    RET
.L49FA:
    LD A,C
    CALL $3374
    RET C
    PUSH BC
    LD A,C
    LD HL,$DBE3
    CALL .L572A
    PUSH HL
    LD A,($DB88)
    LD HL,$DBA3
    CALL .L572A
    SRL H
    RR L
    PUSH HL
    LD A,($DB88)
    LD HL,$DBF3
    CALL .L572A
    SRL H
    RR L
    POP BC
    ADD HL,BC
    LD B,H
    LD C,L
    POP HL
    CALL $3314
    POP BC
    RET
.L4A2D:
    LD A,C
    CALL $3374
    RET C
    PUSH BC
    LD A,($DB88)
    LD HL,$DBE3
    CALL .L572A
    PUSH HL
    LD A,C
    LD HL,$DBB3
    CALL .L572A
    SRL H
    RR L
    PUSH HL
    LD A,C
    LD HL,$DBF3
    CALL .L572A
    SRL H
    RR L
    POP BC
    ADD HL,BC
    LD B,H
    LD C,L
    POP HL
    CALL $3314
    POP BC
    RET
.L4A5E:
    LD A,($DB88)
    XOR A
    LD ($D9EE),A
    LD HL,$D9ED
    INC (HL)
    RET
.L4A6A:
    LD A,($C1FA)
    LD L,A
    LD A,($C1FB)
    LD H,A
.L4A72:
    LD A,(HL+)
    LD D,A
    LD A,(HL-)
    OR D
    JR Z,.L4AA7
    PUSH HL
    CALL .L4ACF
    POP HL
    LD A,($DD27)
    CP $FF
    JR Z,.L4A90
    INC HL
    INC HL
    LD A,L
    LD ($C1FA),A
    LD A,H
    LD ($C1FB),A
    JR .L4A72
.L4A90:
    XOR A
    LD ($DD26),A
    LD ($DD27),A
    LD A,($C1FC)
    LD HL,$DCE4
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$00
    JR .L4AC6
.L4AA7:
    LD A,($C1FC)
    LD HL,$DCE4
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DD27)
    CP $FF
    JR Z,.L4A90
    LD E,A
    LD A,($DD26)
    SUB E
    JR C,.L4A90
    LD ($DD26),A
    ADD A,(HL)
    LD (HL),A
.L4AC6:
    LD A,$04
    LD ($D9EE),A
    JP .L46A0
    DB $C9
.L4ACF:
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    JP HL
.L4AD3:
    LD A,$0A
    CALL $21CA
    RET
.L4AD9:
    CP $03
    JR Z,.L4AEA
    CP $02
    JR Z,.L4AF5
    CP $01
    JR Z,.L4AF0
    LD HL,$DC44
    JR .L4AF8
.L4AEA:
    LD A,$00
    LD ($DB4C),A
    RET
.L4AF0:
    LD HL,$DC4C
    JR .L4AF8
.L4AF5:
    LD HL,$DC54
.L4AF8:
    LD A,($DB88)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    CALL .L4AD3
    LD A,B
    LD ($DB4C),A
    RET
.L4B0A:
    LD A,($DB88)
    LD HL,$DC5C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,(HL)
    CALL .L4AD3
    LD A,B
    LD ($DB4D),A
    RET
.L4B1F:
    LD B,$00
    LD A,($DB88)
    LD HL,$DC44
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $C0
    JR NC,.L4B3C
    CP $40
    JR NC,.L4B3A
    LD B,$12
    JR .L4B3C
.L4B3A:
    LD B,$09
.L4B3C:
    LD A,($DB88)
    LD HL,$DC54
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $C0
    JR NC,.L4B59
    CP $40
    JR NC,.L4B55
    LD A,$06
    JR .L4B57
.L4B55:
    LD A,$03
.L4B57:
    ADD A,B
    LD B,A
.L4B59:
    LD A,($DB88)
    LD HL,$DC4C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $C0
    JR NC,.L4B75
    CP $40
    JR NC,.L4B74
    INC B
    INC B
    LD A,$02
    JR .L4B75
.L4B74:
    INC B
.L4B75:
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
.L4B82:
    LD A,C
    OR A
    JR Z,.L4B8D
    LD A,$1B
    ADD A,B
    LD B,A
    DEC C
    JR .L4B82
.L4B8D:
    ADD A,B
    LD HL,$4B9C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB53),A
    RET
    DB $19,$19,$19,$14,$14,$19,$19,$19,$19,$14,$0F,$0A,$14,$14,$14,$14
    DB $0F,$14,$05,$0F,$0A,$14,$0A,$0A,$14,$05,$05,$14,$0A,$05,$14,$05
    DB $0A,$0F,$0A,$05,$19,$14,$19,$19,$0F,$14,$14,$14,$0A,$19,$0F,$0A
    DB $14,$0A,$14,$19,$0F,$05,$14,$05,$05,$14,$05,$0A,$05,$0F,$05,$19
    DB $14,$19,$19,$14,$14,$14,$0A,$0A,$19,$14,$0A,$0F,$0A,$0A,$0F,$19
    DB $05,$14,$05,$05,$05,$05,$0A,$05,$05,$05,$19,$0F,$0A,$19,$14,$0A
    DB $05,$05,$05,$19,$14,$0F,$14,$14,$19,$14,$19,$05
.L4C08:
    LD A,($DB88)
    LD HL,$DC23
    CALL .L57AD
    LD B,(HL)
    SRL B
    SRL B
    LD A,B
    LD ($DB4E),A
    RET
.L4C1B:
    LD A,($DB88)
    LD HL,$DC23
    CALL .L57AD
    LD A,(HL)
    CP $20
    JR C,.L4C3D
    CP $40
    JR C,.L4C41
    CP $60
    JR C,.L4C45
    CP $90
    JR C,.L4C49
    CP $C0
    JR C,.L4C4D
    LD B,$0F
    JR .L4C4F
.L4C3D:
    LD B,$05
    JR .L4C4F
.L4C41:
    LD B,$07
    JR .L4C4F
.L4C45:
    LD B,$09
    JR .L4C4F
.L4C49:
    LD B,$0B
    JR .L4C4F
.L4C4D:
    LD B,$0D
.L4C4F:
    CALL .L5131
    LD A,($C899)
    AND $3F
.L4C57:
    CP B
    JR C,.L4C5E
    SUB B
    JR NZ,.L4C57
    LD A,B
.L4C5E:
    LD ($DB4F),A
    RET
.L4C62:
    LD A,($DB88)
    ADD A,A
    LD HL,$DC23
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR A
    JR Z,.L4C93
    CP $15
    JR C,.L4C93
    CP $F0
    JR NC,.L4C96
    LD A,($DB4E)
    LD B,A
    LD A,($DB4F)
    ADD A,B
    LD B,A
    LD A,($DB4C)
    LD C,A
    LD A,($DB4D)
    ADD A,C
    LD C,A
    LD A,($DB53)
    ADD A,C
    SUB B
    RET
.L4C93:
    SCF
    CCF
    RET
.L4C96:
    SCF
    RET
.L4C98:
    PUSH BC
    PUSH AF
    CALL .L5131
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    POP AF
    CALL $21DC
    POP BC
    RET
    DB $FA,$4C,$DB,$67,$7B,$B7,$28,$0A,$FE,$01,$28,$0A,$FE,$02,$28,$0A
    DB $7C,$C9,$7C,$07,$07,$C9,$7C,$CB,$37,$C9,$7C,$0F,$0F,$C9,$C5,$FA
    DB $56,$DB,$6F,$FA,$57,$DB,$67,$2A,$66,$6F,$E5,$FA,$58,$DB,$6F,$FA
    DB $59,$DB,$67,$2A,$66,$6F,$7C,$B7,$20,$0F,$7D,$0F,$0F,$E6,$3F,$B7
    DB $28,$03,$6F,$18,$0C,$2E,$01,$18,$0C,$CB,$2C,$CB,$1D,$CB,$2C,$CB
    DB $1D,$44,$4D,$29,$09,$C1,$CD,$14,$33,$C1,$C9,$C5,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$2A,$66,$6F,$E5,$FA,$58,$DB,$6F,$FA,$59,$DB,$67
    DB $2A,$66,$6F,$7C,$B7,$20,$0E,$7D,$0F,$E6,$7F,$B7,$28,$03,$6F,$18
    DB $08,$2E,$01,$18,$04,$CB,$2C,$CB,$1D,$C1,$CD,$14,$33,$C1,$C9,$C5
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$2A,$46,$4F,$C5,$FA,$58,$DB,$6F
    DB $FA,$59,$DB,$67,$2A,$66,$6F,$01,$04,$00,$CD,$1A,$33,$C1,$CD,$14
    DB $33,$C1,$C9,$C5,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$2A,$46,$4F,$C5
    DB $FA,$58,$DB,$6F,$FA,$59,$DB,$67,$2A,$66,$6F,$01,$0A,$00,$CD,$1A
    DB $33,$C1,$CD,$14,$33,$C1,$C9,$79,$21,$65,$DC,$CB,$37,$85,$6F,$3E
    DB $00,$8C,$67,$16,$08,$2A,$FE,$FF,$28,$14,$FE,$5C,$38,$0C,$FE,$64
    DB $38,$10,$FE,$6A,$38,$04,$FE,$6E,$38,$08,$23,$15,$20,$E7,$3E,$01
    DB $B7,$C9,$AF,$C9,$FE,$03,$30,$0E,$E5,$21,$C2,$CA,$CD,$F8,$25,$5D
    DB $54,$E1,$CD,$6C,$10,$C9,$F5,$EA,$60,$DB,$E5,$21,$3C,$DC,$85,$6F
    DB $3E,$00,$8C,$67,$7E,$6F,$26,$05,$D1,$7B,$EA,$5E,$DB,$7A,$EA,$5F
    DB $DB,$CD,$67,$0D,$F1,$21,$04,$51,$D7,$C9,$F5,$C5,$D5,$E5,$FA,$88
    DB $DB,$21,$05,$DB,$CD,$3B,$33,$7E,$E6,$C0,$77,$E1,$D1,$C1,$F1,$C9
    DB $7E,$E6,$0C,$28,$14,$FE,$04,$28,$0C,$FE,$08,$28,$04,$06,$60,$18
    DB $0A,$06,$A0,$18,$06,$06,$E0,$18,$02,$06,$FF,$FA,$99,$C8,$B8,$28
    DB $1C,$38,$1A,$7E,$E6,$F3,$47,$7E,$E6,$0C,$3D,$C5,$F5,$C1,$CB,$69
    DB $C1,$20,$04,$E6,$0C,$18,$01,$AF,$B0,$77,$3E,$0F,$C9,$7E,$E6,$73
    DB $77,$FA,$88,$DB,$EA,$89,$DB,$21,$04,$50,$D7,$3E,$DB,$C9
Bank87_fn1:
    LD A,($DB88)
    LD HL,$DB08
    CALL $333B
    BIT 0,(HL)
    JR NZ,.L4E57
    RET
.L4E57:
    LD A,($DB8A)
    CP $52
    JR Z,.L4E67
    CP $53
    JR Z,.L4E67
    CP $AB
    JR Z,.L4E6B
    RET
.L4E67:
    LD A,$03
    JR .L4E6D
.L4E6B:
    LD A,$08
.L4E6D:
    LD ($DD6D),A
    RES 0,(HL)
    RET
    DB $FA,$88,$DB,$21,$0B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E,$FE,$02,$C9
    DB $FA,$8A,$DB,$FE,$3B,$28,$2E,$FE,$3D,$28,$2A,$FE,$42,$28,$26,$FE
    DB $44,$38,$20,$FE,$4F,$28,$1C,$FE,$52,$38,$1A,$FE,$55,$38,$14,$FE
    DB $58,$38,$12,$FE,$67,$38,$0C,$FE,$6A,$38,$0A,$FE,$D6,$38,$04,$FE
    DB $D9,$38,$02,$AF,$C9,$37,$C9,$FA,$8A,$DB,$FE,$3B,$28,$22,$FE,$3D
    DB $28,$1E,$FE,$3F,$28,$1A,$FE,$40,$28,$16,$FE,$42,$28,$12,$FE,$50
    DB $28,$0E,$FE,$51,$28,$0A,$FE,$55,$38,$04,$FE,$58,$38,$02,$AF,$C9
    DB $37,$C9,$FA,$8A,$DB,$FE,$14,$38,$16,$FE,$4F,$28,$12,$FE,$52,$28
    DB $0E,$FE,$53,$28,$0A,$FE,$58,$38,$04,$FE,$66,$38,$02,$AF,$C9,$37
    DB $C9,$FA,$88,$DB,$21,$A3,$DB,$CD,$2A,$57,$44,$4D,$09,$09,$E5,$FA
    DB $88,$DB,$21,$B3,$DB,$CD,$2A,$57,$29,$C1,$CD,$14,$33,$C9,$C9,$FA
    DB $88,$DB,$21,$D3,$DB,$CD,$AD,$57,$2A,$46,$4F,$CB,$38,$CB,$19,$FA
    DB $88,$DB,$CD,$BE,$33,$CD,$14,$33,$C9,$FA,$88,$DB,$21,$B3,$DB,$CD
    DB $AD,$57,$2A,$46,$4F,$FA,$88,$DB,$CD,$B0,$33,$CD,$14,$33,$C9,$CD
    DB $78,$4F,$AF,$EA,$54,$DB,$21,$55,$DB,$34,$79,$EA,$89,$DB,$7A,$EA
    DB $4C,$DB,$D5,$C5,$21,$06,$52,$D7,$C1,$D1,$CD,$AB,$4C,$E6,$03,$21
    DB $54,$DB,$86,$77,$C9,$FA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB
    DB $3E,$05,$EA,$4E,$DB,$21,$00,$54,$D7,$FA,$4C,$DB,$E6,$03,$5F,$FA
    DB $4C,$DB,$0F,$0F,$E6,$0F,$57,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06
    DB $03,$AF,$EA,$55,$DB,$C9,$21,$55,$DB,$34,$79,$EA,$89,$DB,$7A,$EA
    DB $4C,$DB,$D5,$C5,$21,$06,$52,$D7,$C1,$D1,$CD,$AB,$4C,$E6,$03,$C9
    DB $FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$11,$00,$00,$7B,$EA,$56
    DB $DB,$7A,$EA,$57,$DB,$79,$CD,$74,$33,$38,$12,$79,$21,$F3,$DB,$CD
    DB $AD,$57,$FA,$56,$DB,$86,$22,$FA,$57,$DB,$8E,$77,$14,$0C,$05,$20
    DB $E4,$7A,$FE,$01,$C8,$FE,$02,$28,$14,$FA,$56,$DB,$6F,$FA,$57,$DB
    DB $67,$CD,$DC,$21,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$FA,$56,$DB
    DB $6F,$FA,$57,$DB,$67,$CB,$2C,$CB,$1D,$7D,$EA,$56,$DB,$7C,$EA,$57
    DB $DB,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$11,$00,$00,$7B
    DB $EA,$58,$DB,$7A,$EA,$59,$DB,$79,$CD,$74,$33,$38,$12,$79,$21,$F3
    DB $DB,$CD,$AD,$57,$FA,$58,$DB,$86,$22,$FA,$59,$DB,$8E,$77,$14,$0C
    DB $05,$20,$E4,$7A,$FE,$01,$C8,$FE,$02,$28,$14,$FA,$58,$DB,$6F,$FA
    DB $59,$DB,$67,$CD,$DC,$21,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$C9,$FA
    DB $58,$DB,$6F,$FA,$59,$DB,$67,$CB,$2C,$CB,$1D,$7D,$EA,$58,$DB,$7C
    DB $EA,$59,$DB,$C9
.L5087:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    CALL .L7ECC
    RET
    DB $C5,$E5,$21,$65,$DC,$CD,$CF,$51,$06,$08,$2A,$FE,$FF,$28,$14,$FE
    DB $3A,$38,$14,$FE,$D5,$28,$10,$FE,$DA,$28,$0C,$FE,$DC,$28,$08,$23
    DB $05,$20,$E7,$E1,$C1,$37,$C9,$E1,$C1,$AF,$B7,$C9,$C5,$E5,$21,$65
    DB $DC,$CD,$CF,$51,$06,$08,$2A,$FE,$FF,$28,$1C,$FE,$43,$28,$1C,$FE
    DB $5C,$38,$10,$FE,$64,$38,$14,$FE,$6A,$38,$08,$FE,$6E,$38,$0C,$FE
    DB $8F,$28,$08,$23,$05,$20,$DF,$E1,$C1,$37,$C9,$E1,$C1,$AF,$B7,$C9
    DB $C5,$E5,$21,$65,$DC,$CD,$CF,$51,$06,$08,$2A,$FE,$FF,$28,$20,$FE
    DB $6E,$28,$20,$FE,$71,$28,$1C,$FE,$75,$38,$10,$FE,$79,$38,$14,$FE
    DB $91,$28,$10,$FE,$94,$28,$0C,$FE,$96,$28,$08,$23,$05,$20,$DB,$E1
    DB $C1,$37,$C9,$E1,$C1,$AF,$B7,$C9
.L5131:
    PUSH BC
    LD A,($C86C)
    OR A
    JR NZ,.L513D
    CALL $16A3
    JR .L5162
.L513D:
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
.L5162:
    POP BC
    RET
.L5164:
    LD HL,$DB4C
    XOR A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL),A
    LD A,($DB88)
    LD HL,$DC44
    CALL .L51C7
    LD ($DB4D),A
    CP $3F
    JR C,.L5181
    LD A,$01
    LD ($DB4C),A
.L5181:
    LD A,($DB88)
    LD HL,$DC4C
    CALL .L51C7
    LD ($DB4E),A
    CP $3F
    JR C,.L5196
    LD HL,$DB4C
    SET 1,(HL)
.L5196:
    LD A,($DB88)
    LD HL,$DC54
    CALL .L51C7
    LD ($DB4F),A
    CP $3F
    JR C,.L51AB
    LD HL,$DB4C
    SET 2,(HL)
.L51AB:
    LD B,$98
    LD A,($DB4C)
    OR A
    RET Z
    LD B,$3A
    BIT 0,A
    JR Z,.L51C4
    LD A,($DB4D)
    LD HL,$DB4E
    CP (HL)
    JR C,.L51C4
    INC HL
    CP (HL)
    RET NC
.L51C4:
    LD B,$8D
    RET
.L51C7:
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    RET
    DB $87,$87,$87,$CD,$AD,$57,$C9
Bank87_fn2:
    LD A,($DB88)
    LD B,A
    LD A,($DB89)
    LD C,A
    PUSH BC
    LD A,($DB88)
    AND $04
    XOR $04
    LD D,A
    LD ($DB4D),A
    LD BC,$0400
.L51ED:
    LD A,D
    CALL $3374
    JR C,.L51F4
    INC C
.L51F4:
    INC D
    DEC B
    JR NZ,.L51ED
    LD A,C
    ADD A,A
    LD D,A
    ADD A,A
    ADD A,A
    ADD A,D
    LD ($DB4E),A
    LD A,($DB4C)
    LD ($DB88),A
    LD B,$04
.L5209:
    PUSH BC
    LD A,($DB4D)
    LD ($DB89),A
    LD HL,$5205
    RST $10  ; -> bank82/fn5
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,($DB4E)
    CALL $21B5
    PUSH HL
    LD A,($DB4C)
    CALL $33B7
    POP BC
    CALL $3314
    POP BC
    JR NC,.L523E
    LD HL,$DB4D
    INC (HL)
    DEC B
    JR NZ,.L5209
    LD A,$00
    LD ($DB4E),A
    JR .L5243
.L523E:
    LD A,$01
    LD ($DB4E),A
.L5243:
    POP BC
    LD A,B
    LD ($DB88),A
    LD A,C
    LD ($DB89),A
    RET
Bank87_fn3:
    LD A,($DB88)
    LD B,A
    LD A,($DB89)
    LD C,A
    PUSH BC
    LD A,($DB4C)
    AND $03
    LD HL,$DB58
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,L
    LD ($DB4F),A
    LD A,H
    LD ($DB50),A
    LD A,$00
    LD (HL+),A
    LD A,$00
    LD (HL),A
    LD A,($DB4C)
    LD ($DB89),A
    LD A,($DB4C)
    AND $04
    XOR $04
    LD ($DB88),A
    LD A,$00
    LD ($DB4D),A
    LD A,$04
    LD ($DB4E),A
.L528D:
    LD A,($DB88)
    CALL $3374
    JR C,.L52BE
    LD HL,$DB4D
    INC (HL)
    LD HL,$5205
    RST $10  ; -> bank82/fn5
    LD A,($DB4F)
    LD L,A
    LD A,($DB50)
    LD H,A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    ADD HL,BC
    LD A,($DB4F)
    LD C,A
    LD A,($DB50)
    LD B,A
    LD A,L
    LD (BC),A
    INC BC
    LD A,H
    LD (BC),A
.L52BE:
    LD HL,$DB88
    INC (HL)
    LD A,($DB4E)
    DEC A
    LD ($DB4E),A
    JR NZ,.L528D
    LD A,($DB4C)
    CALL $33A9
    PUSH HL
    LD A,($DB4F)
    LD L,A
    LD A,($DB50)
    LD H,A
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    POP HL
    CALL $331A
    PUSH HL
    LD A,($DB4F)
    LD L,A
    LD A,($DB50)
    LD H,A
    POP BC
    LD A,C
    LD (HL+),A
    LD A,B
    LD (HL),A
    POP BC
    LD A,B
    LD ($DB88),A
    LD A,C
    LD ($DB89),A
    RET
Bank87_fn4:
    LD A,($DD72)
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L532D
    LD A,B
    CP $03
    JR C,.L532D
    AND $03
    CP $03
    JR Z,.L533D
    LD A,B
    SUB $04
    LD HL,$DA03
    CALL .L572A
.L5317:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA1D)
    LD C,A
    LD A,($DA1E)
    LD B,A
    JR .L534C
.L532D:
    LD A,B
    AND $03
    CP $03
    JR Z,.L533D
    LD A,B
    LD HL,$CB13
    CALL $261E
    JR .L534C
.L533D:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L5317
.L534C:
    LD A,C
    LD ($DD72),A
    LD A,B
    LD ($DD73),A
    RET
Bank87_fn5:
    LD A,($DD72)
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L5389
    LD A,B
    CP $03
    JR C,.L5389
    AND $03
    CP $03
    JR Z,.L5399
    LD A,B
    SUB $04
    LD HL,$DA03
    CALL .L572A
.L5373:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA1F)
    LD C,A
    LD A,($DA20)
    LD B,A
    JR .L53A8
.L5389:
    LD A,B
    AND $03
    CP $03
    JR Z,.L5399
    LD A,B
    LD HL,$CB17
    CALL $261E
    JR .L53A8
.L5399:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L5373
.L53A8:
    LD A,C
    LD ($DD72),A
    LD A,B
    LD ($DD73),A
    RET
Bank87_fn6:
    LD A,($DD72)
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L53E5
    LD A,B
    CP $03
    JR C,.L53E5
    AND $03
    CP $03
    JR Z,.L53F5
    LD A,B
    SUB $04
    LD HL,$DA03
    CALL .L572A
.L53CF:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA21)
    LD C,A
    LD A,($DA22)
    LD B,A
    JR .L5404
.L53E5:
    LD A,B
    AND $03
    CP $03
    JR Z,.L53F5
    LD A,B
    LD HL,$CB19
    CALL $261E
    JR .L5404
.L53F5:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L53CF
.L5404:
    LD A,C
    LD ($DD72),A
    LD A,B
    LD ($DD73),A
    RET
Bank87_fn7:
    LD A,($DD72)
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L5441
    LD A,B
    CP $03
    JR C,.L5441
    AND $03
    CP $03
    JR Z,.L5451
    LD A,B
    SUB $04
    LD HL,$DA03
    CALL .L572A
.L542B:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA23)
    LD C,A
    LD A,($DA24)
    LD B,A
    JR .L5460
.L5441:
    LD A,B
    AND $03
    CP $03
    JR Z,.L5451
    LD A,B
    LD HL,$CB1B
    CALL $261E
    JR .L5460
.L5451:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L542B
.L5460:
    LD A,C
    LD ($DD72),A
    LD A,B
    LD ($DD73),A
    RET
Bank87_fn8:
    LD A,($DD72)
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L549D
    LD A,B
    CP $03
    JR C,.L549D
    AND $03
    CP $03
    JR Z,.L54AD
    LD A,B
    SUB $04
    LD HL,$DA03
    CALL .L572A
.L5487:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA25)
    LD C,A
    LD A,($DA26)
    LD B,A
    JR .L54BC
.L549D:
    LD A,B
    AND $03
    CP $03
    JR Z,.L54AD
    LD A,B
    LD HL,$CB1D
    CALL $261E
    JR .L54BC
.L54AD:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L5487
.L54BC:
    LD A,C
    LD ($DD72),A
    LD A,B
    LD ($DD73),A
    RET
    DB $CB,$54,$1B,$55,$C7,$55,$47,$79,$B5,$57,$C5,$58,$E8,$58,$08,$59
    DB $48,$59,$B9,$5C,$00,$5D,$D6,$5D,$10,$6F,$A8,$70,$E2,$70,$54,$71
    DB $2A,$74,$07,$76,$BE,$76,$0B,$7A,$D0,$7B,$2A,$7C,$25,$7E,$51,$6F
    DB $4F,$5D,$59,$77,$DC,$77,$8F,$5D,$04,$5E,$19,$5F,$BC,$5F,$DB,$5F
    DB $F9,$5F,$39,$60,$17,$66,$71,$6D,$C0,$71,$43,$73,$BE,$78,$D3,$79
    DB $4C,$7D,$4F,$7E,$00,$00,$47,$79,$B5,$57,$48,$58,$C5,$58,$E8,$58
    DB $08,$59,$48,$59,$9C,$59,$B8,$59,$E4,$59,$06,$5A,$28,$5A,$53,$5A
    DB $C5,$5A,$57,$5C,$8F,$5C,$B9,$5C,$00,$5D,$D6,$5D,$56,$66,$F7,$6C
    DB $0D,$6D,$90,$6D,$B8,$6D,$E8,$6D,$20,$6E,$8B,$6E,$10,$6F,$A3,$6F
    DB $BD,$6F,$D3,$6F,$01,$70,$41,$70,$67,$70,$7E,$70,$A8,$70,$E2,$70
    DB $54,$71,$2A,$74,$6B,$74,$45,$75,$73,$75,$A6,$75,$D7,$75,$07,$76
    DB $37,$76,$60,$76,$8F,$76,$3E,$78,$1A,$79,$21,$7B,$38,$7B,$D0,$7B
    DB $77,$7C,$B8,$7C,$8E,$7D,$D2,$7D,$87,$67,$99,$67,$25,$7E,$83,$7E
    DB $59,$77,$DC,$77,$8E,$7B,$8F,$5D,$81,$66,$A7,$66,$DE,$66,$B9,$67
    DB $23,$68,$FC,$68,$BF,$69,$05,$6A,$00,$6B,$BA,$6B,$C0,$71,$0D,$72
    DB $51,$72,$8B,$72,$CA,$72,$07,$73,$43,$73,$7F,$73,$B4,$73,$EF,$73
    DB $00,$00,$47,$79,$B5,$57,$2C,$5B,$46,$5B,$60,$5B,$7A,$5B,$1F,$5C
    DB $57,$5C,$E8,$6D,$D9,$6E,$10,$6F,$E2,$70,$54,$71,$BE,$76,$3E,$78
    DB $97,$78,$74,$79,$48,$59,$7C,$60,$A7,$60,$F1,$60,$24,$61,$57,$61
    DB $76,$61,$95,$61,$EF,$61,$7F,$62,$D6,$62,$0C,$63,$9D,$63,$9F,$64
    DB $2D,$65,$79,$65,$A0,$65,$D4,$65,$F7,$65,$B9,$67,$0F,$6C,$B2,$6C
    DB $98,$79,$00,$00,$79,$CD,$74,$33,$38,$03,$7E,$A3,$C8,$0C,$3E,$08
    DB $85,$6F,$3E,$00,$8C,$67,$05,$20,$EB,$3E,$FF,$EA,$27,$DD,$C9,$79
    DB $CD,$74,$33,$38,$12,$2A,$5E,$57,$1B,$7A,$B3,$C0,$23,$0C,$05,$20
    DB $EE,$3E,$FF,$EA,$27,$DD,$C9,$23,$18,$F2,$79,$CD,$74,$33,$38,$03
    DB $7E,$A3,$C0,$0C,$3E,$08,$85,$6F,$3E,$00,$8C,$67,$05,$20,$EB,$3E
    DB $FF,$EA,$27,$DD,$C9,$79,$CD,$74,$33,$38,$1D,$79,$21,$3C,$DC,$85
    DB $6F,$3E,$00,$8C,$67,$7E,$EA,$31,$DA,$C5,$21,$01,$03,$D7,$C1,$FA
    DB $33,$DA,$21,$4C,$DB,$BE,$28,$05,$0C,$05,$20,$FC,$C9,$21,$26,$DD
    DB $06,$14,$CD,$22,$57,$C9,$79,$CD,$74,$33,$38,$04,$7E,$A2,$20,$0D
    DB $0C,$3E,$08,$85,$6F,$3E,$00,$8C,$67,$05,$20,$EA,$C9,$21,$26,$DD
    DB $43,$CD,$22,$57,$C9,$AF,$EA,$56,$DB,$AF,$EA,$57,$DB,$AF,$EA,$4C
    DB $DB,$79,$CD,$74,$33,$38,$22,$FA,$4C,$DB,$3C,$EA,$4C,$DB,$E5,$2A
    DB $66,$6F,$FA,$56,$DB,$5F,$FA,$57,$DB,$57,$7B,$85,$5F,$7A,$8C,$57
    DB $7B,$EA,$56,$DB,$7A,$EA,$57,$DB,$E1,$23,$23,$0C,$05,$20,$D2,$C9
    DB $FA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB,$3E,$05,$EA,$4E,$DB
    DB $21,$00,$54,$D7,$FA,$4C,$DB,$E6,$03,$5F,$FA,$4C,$DB,$0F,$0F,$E6
    DB $0F,$57,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$C9,$7E,$80,$77
    DB $D0,$3E,$FF,$77,$C9
.L572A:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    RET
    DB $79,$21,$08,$DB,$CD,$3B,$33,$7E,$E6,$08,$C9,$E5,$47,$FA,$6C,$C8
    DB $B7,$20,$2D,$78,$FE,$03,$38,$2E,$E6,$03,$FE,$03,$28,$30,$78,$D6
    DB $04,$21,$03,$DA,$CD,$AD,$57,$2A,$66,$6F,$7D,$EA,$12,$DA,$7C,$EA
    DB $13,$DA,$21,$01,$14,$D7,$FA,$25,$DA,$4F,$FA,$26,$DA,$47,$18,$1D
    DB $E6,$03,$FE,$03,$28,$08,$21,$1D,$CB,$CD,$1E,$26,$18,$0F,$78,$21
    DB $3C,$DC,$85,$6F,$3E,$00,$8C,$67,$6E,$26,$01,$18,$CD,$E1,$C9,$7C
    DB $B7,$20,$0A,$7D,$B7,$28,$04,$FE,$01,$20,$02,$37,$C9,$3E,$02,$FE
    DB $01,$C9,$3E,$FF,$EA,$27,$DD,$C9
.L57AD:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    RET
    DB $FA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB,$3E,$04,$EA,$4E,$DB
    DB $21,$00,$54,$D7,$FA,$4C,$DB,$B7,$28,$11,$4F,$06,$00,$FA,$88,$DB
    DB $CD,$BE,$33,$CD,$14,$33,$30,$03,$CD,$A7,$57,$FA,$6B,$DD,$CB,$77
    DB $28,$10,$FA,$88,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$46,$28,$03,$CD
    DB $A7,$57,$FA,$6B,$DD,$CB,$6F,$28,$10,$FA,$88,$DB,$21,$03,$DB,$CD
    DB $3B,$33,$CB,$76,$28,$03,$CD,$A7,$57,$FA,$6B,$DD,$CB,$67,$28,$10
    DB $FA,$88,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$7E,$28,$03,$CD,$A7,$57
    DB $FA,$8A,$DB,$FE,$83,$28,$06,$FA,$6B,$DD,$CB,$77,$C8,$FA,$88,$DB
    DB $FE,$04,$38,$05,$21,$01,$DB,$18,$03,$21,$00,$DB,$CB,$5E,$C8,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$41,$20,$11,$FA,$88,$DB,$21,$06,$DB
    DB $CD,$3B,$33,$7E,$E6,$03,$28,$03,$CD,$A7,$57,$FA,$8A,$DB,$FE,$54
    DB $20,$11,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$E6,$C0,$28,$03
    DB $CD,$A7,$57,$FA,$8A,$DB,$FE,$8F,$20,$10,$FA,$88,$DB,$21,$08,$DB
    DB $CD,$3B,$33,$CB,$4E,$28,$03,$CD,$A7,$57,$FA,$8A,$DB,$FE,$27,$28
    DB $04,$FE,$28,$20,$11,$FA,$88,$DB,$21,$04,$DB,$CD,$3B,$33,$7E,$E6
    DB $22,$28,$03,$CD,$A7,$57,$FA,$8A,$DB,$FE,$24,$C0,$FA,$88,$DB,$E6
    DB $04,$4F,$06,$03,$21,$04,$DB,$CD,$3B,$33,$1E,$04,$CD,$19,$56,$C9
    DB $FA,$8A,$DB,$FE,$6E,$D0,$FE,$67,$28,$03,$FE,$6C,$D8,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$1E,$02,$CD
    DB $19,$56,$C9,$FA,$8A,$DB,$FE,$67,$28,$03,$FE,$6C,$C0,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$1E,$03,$CD
    DB $19,$56,$C9,$FA,$8A,$DB,$FE,$15,$D8,$FE,$17,$38,$20,$FE,$2A,$28
    DB $1C,$FE,$68,$28,$18,$FE,$6A,$28,$14,$FE,$70,$D8,$FE,$71,$C8,$FE
    DB $74,$38,$0A,$FE,$78,$D8,$FE,$7E,$38,$03,$FE,$DC,$C0,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$1E,$8C,$CD
    DB $19,$56,$C9,$FA,$8A,$DB,$FE,$15,$D8,$FE,$1A,$38,$34,$FE,$1C,$D8
    DB $FE,$29,$C8,$FE,$2B,$38,$2A,$FE,$68,$D8,$FE,$6C,$38,$23,$FE,$6E
    DB $28,$1F,$FE,$70,$D8,$FE,$71,$C8,$FE,$74,$38,$15,$FE,$77,$D8,$FE
    DB $81,$38,$0E,$FE,$88,$D8,$FE,$93,$38,$07,$FE,$DA,$38,$03,$FE,$DC
    DB $C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$21,$02,$DB,$CD,$3B
    DB $33,$1E,$40,$CD,$19,$56,$C9,$FA,$8A,$DB,$FE,$18,$C0,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$06,$03,$21,$03,$DB,$CD,$3B,$33,$1E,$02,$CD
    DB $19,$56,$C9,$FA,$8A,$DB,$FE,$19,$28,$0F,$FE,$2A,$28,$0B,$FE,$6E
    DB $28,$07,$FE,$DA,$28,$03,$FE,$DC,$C0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$1E,$10,$CD,$19,$56,$C9,$FA
    DB $8A,$DB,$FE,$1C,$28,$03,$FE,$1D,$C0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$21,$F3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$CD,$34,$56
    DB $C9,$FA,$8A,$DB,$FE,$20,$28,$03,$FE,$21,$C0,$FA,$88,$DB,$E6,$04
    DB $EE,$04,$4F,$06,$03,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$CD
    DB $34,$56,$C9,$FA,$8A,$DB,$FE,$2A,$28,$0E,$FE,$70,$28,$0A,$FE,$78
    DB $D8,$FE,$7E,$38,$03,$FE,$DC,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$21,$05,$DB,$CD,$3B,$33,$1E,$3F,$CD,$19,$56,$C9,$FA,$8A
    DB $DB,$FE,$1E,$28,$03,$FE,$1F,$C0,$FA,$88,$DB,$E6,$04,$EA,$4C,$DB
    DB $06,$03,$C5,$FA,$4C,$DB,$CD,$74,$33,$38,$49,$FA,$4C,$DB,$E5,$EA
    DB $72,$DD,$21,$07,$57,$D7,$FA,$72,$DD,$4F,$FA,$73,$DD,$47,$E1,$FA
    DB $4C,$DB,$CD,$A2,$33,$FA,$6C,$C8,$B7,$28,$0B,$FA,$4C,$DB,$E6,$03
    DB $FE,$03,$28,$0D,$18,$07,$FA,$4C,$DB,$FE,$03,$30,$04,$CB,$21,$CB
    DB $10,$CB,$21,$CB,$10,$CD,$14,$33,$30,$0A,$01,$E7,$03,$CD,$14,$33
    DB $30,$02,$C1,$C9,$21,$4C,$DB,$34,$C1,$05,$20,$A6,$CD,$A7,$57,$C9
    DB $FA,$8A,$DB,$FE,$22,$28,$03,$FE,$23,$C0,$FA,$88,$DB,$E6,$04,$EA
    DB $4C,$DB,$06,$03,$C5,$FA,$4C,$DB,$CD,$74,$33,$38,$3E,$FA,$4C,$DB
    DB $CD,$40,$57,$FA,$4C,$DB,$21,$03,$DC,$CD,$2A,$57,$FA,$6C,$C8,$B7
    DB $28,$0B,$FA,$4C,$DB,$E6,$03,$FE,$03,$28,$0D,$18,$07,$FA,$4C,$DB
    DB $FE,$03,$30,$04,$CB,$21,$CB,$10,$CB,$21,$CB,$10,$CD,$14,$33,$30
    DB $0A,$01,$FF,$01,$CD,$14,$33,$30,$02,$C1,$C9,$21,$4C,$DB,$34,$C1
    DB $05,$20,$B1,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$34,$C0,$FA,$88,$DB
    DB $E6,$04,$4F,$21,$02,$DB,$CD,$3B,$33,$06,$03,$1E,$C0,$CD,$4F,$56
    DB $C9,$FA,$8A,$DB,$FE,$35,$C0,$FA,$88,$DB,$E6,$04,$4F,$21,$02,$DB
    DB $CD,$3B,$33,$06,$03,$1E,$10,$CD,$4F,$56,$C9,$FA,$8A,$DB,$FE,$36
    DB $C0,$FA,$88,$DB,$E6,$04,$4F,$21,$02,$DB,$CD,$3B,$33,$06,$03,$1E
    DB $20,$CD,$4F,$56,$C9,$FA,$8A,$DB,$FE,$2B,$D8,$FE,$93,$28,$6A,$FE
    DB $94,$28,$03,$FE,$30,$D0,$06,$03,$FA,$88,$DB,$E6,$04,$4F,$21,$A3
    DB $DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB
    DB $79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C
    DB $EA,$59,$DB,$79,$CD,$74,$33,$38,$04,$CD,$C9,$4C,$D0,$FA,$56,$DB
    DB $6F,$FA,$57,$DB,$67,$23,$23,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA
    DB $58,$DB,$6F,$FA,$59,$DB,$67,$23,$23,$7D,$EA,$58,$DB,$7C,$EA,$59
    DB $DB,$0C,$05,$20,$CE,$CD,$A7,$57,$C9,$FA,$88,$DB,$4F,$21,$A3,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$79
    DB $21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C,$EA
    DB $59,$DB,$79,$CD,$C9,$4C,$38,$CD,$C9,$C9,$FA,$8A,$DB,$FE,$14,$28
    DB $07,$FE,$32,$28,$03,$FE,$96,$C0,$FA,$88,$DB,$57,$E6,$04,$4F,$06
    DB $03,$1E,$00,$79,$BA,$28,$10,$CD,$74,$33,$38,$0B,$1C,$79,$21,$02
    DB $DB,$CD,$3B,$33,$CB,$76,$C8,$0C,$05,$20,$E8,$7B,$B7,$C8,$CD,$A7
    DB $57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$24,$28,$0F,$FE,$8A,$28
    DB $0B,$FE,$8B,$28,$07,$FE,$8F,$28,$03,$FE,$92,$C0,$FA,$88,$DB,$E6
    DB $04,$EE,$04,$4F,$06,$03,$16,$10,$79,$CD,$74,$33,$38,$04,$CD,$82
    DB $4D,$C8,$0C,$05,$20,$F2,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$43,$C0
    DB $FA,$88,$DB,$21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$06,$08
    DB $2A,$FE,$FF,$28,$0B,$FE,$5C,$38,$03,$FE,$64,$D8,$23,$05,$20,$F0
    DB $CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$03,$D8,$FE,$12,$C8,$FE,$15,$C8
    DB $FE,$1D,$28,$0B,$FE,$21,$28,$07,$FE,$DA,$28,$03,$FE,$1A,$D0,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$21,$04,$DB,$CD,$3B,$33,$79
    DB $CD,$74,$33,$38,$05,$7E,$E6,$22,$20,$0D,$0C,$3E,$08,$85,$6F,$3E
    DB $00,$8C,$67,$05,$20,$E9,$C9,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$5C
    DB $D8,$FE,$64,$38,$06,$FE,$6E,$D0,$FE,$6A,$D8,$FA,$88,$DB,$E6,$04
    DB $EE,$04,$4F,$06,$03,$79,$CB,$3F,$CB,$3F,$21,$00,$DB,$85,$6F,$3E
    DB $00,$8C,$67,$7E,$E6,$60,$20,$1E,$79,$CD,$74,$33,$38,$13,$79,$21
    DB $04,$DB,$CD,$3B,$33,$2A,$23,$23,$23,$E6,$48,$20,$09,$CB,$4E,$20
    DB $05,$0C,$05,$20,$E3,$C9,$CD,$A7,$57,$C9,$CD,$73,$4E,$C0,$FA,$6B
    DB $DD,$CB,$7F,$C8,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$21,$08
    DB $DB,$CD,$3B,$33,$79,$CD,$74,$33,$38,$0A,$CB,$6E,$20,$13,$23,$7E
    DB $E6,$05,$20,$0D,$0C,$3E,$07,$85,$6F,$3E,$00,$8C,$67,$05,$20,$E4
    DB $C9,$21,$27,$DD,$06,$14,$CD,$22,$57,$C9,$CD,$F5,$56,$FA,$4C,$DB
    DB $B7,$C8,$AF,$21,$54,$DB,$22,$77,$79,$CD,$74,$33,$38,$1E,$21,$55
    DB $DB,$34,$79,$EA,$89,$DB,$7A,$EA,$4C,$DB,$D5,$C5,$21,$06,$52,$D7
    DB $C1,$D1,$CD,$AB,$4C,$E6,$03,$21,$54,$DB,$86,$77,$0C,$05,$20,$D8
    DB $FA,$55,$DB,$21,$54,$DB,$BE,$D8,$21,$26,$DD,$06,$14,$CD,$22,$57
    DB $C9,$CD,$F5,$56,$79,$CD,$74,$33,$38,$18,$79,$EA,$89,$DB,$7A,$EA
    DB $4C,$DB,$D5,$C5,$21,$06,$52,$D7,$C1,$D1,$CD,$AB,$4C,$E6,$03,$FE
    DB $03,$C0,$0C,$05,$20,$DE,$21,$54,$DB,$86,$77,$CD,$A7,$57,$C9,$FA
    DB $8A,$DB,$FE,$3F,$D8,$FE,$41,$DA,$EC,$5E,$FE,$48,$D8,$FE,$50,$38
    DB $0F,$FE,$D6,$D8,$FE,$D9,$D0,$FA,$8A,$DB,$D6,$D6,$C6,$08,$18,$05
    DB $FA,$8A,$DB,$D6,$48,$C7,$EC,$5E,$54,$5E,$67,$5E,$7A,$5E,$B3,$5E
    DB $C6,$5E,$D9,$5E,$C6,$5E,$41,$5E,$8D,$5E,$A0,$5E,$FA,$88,$DB,$E6
    DB $04,$EE,$04,$4F,$06,$03,$3E,$00,$EA,$4C,$DB,$CD,$6A,$56,$C9,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$01,$EA,$4C,$DB,$CD,$6A
    DB $56,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$02,$EA,$4C
    DB $DB,$CD,$6A,$56,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E
    DB $03,$EA,$4C,$DB,$CD,$6A,$56,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$3E,$05,$EA,$4C,$DB,$CD,$6A,$56,$C9,$FA,$88,$DB,$E6,$04
    DB $EE,$04,$4F,$06,$03,$3E,$04,$EA,$4C,$DB,$CD,$6A,$56,$C9,$FA,$88
    DB $DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$06,$EA,$4C,$DB,$CD,$6A,$56
    DB $C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$07,$EA,$4C,$DB
    DB $CD,$6A,$56,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$08
    DB $EA,$4C,$DB,$CD,$6A,$56,$C9,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06
    DB $03,$79,$CD,$74,$33,$38,$0E,$79,$21,$8B,$DB,$85,$6F,$3E,$00,$8C
    DB $67,$CB,$46,$20,$05,$0C,$05,$20,$E8,$C9,$21,$26,$DD,$06,$14,$CD
    DB $22,$57,$C9,$C9,$CD,$83,$4E,$D0,$CD,$C3,$4F,$FA,$88,$DB,$CD,$9B
    DB $33,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33,$38,$08,$21,$26
    DB $DD,$06,$0A,$CD,$22,$57,$3E,$FF,$21,$56,$DB,$22,$77,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$79,$CD,$74,$33,$38,$0C,$79,$CD,$A2,$33,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$0C,$79,$CD,$74,$33,$38,$1B,$79,$CD
    DB $A2,$33,$C5,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33,$C1,$30
    DB $08,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$0C,$79,$CD,$74,$33,$38,$1B
    DB $79,$CD,$A2,$33,$C5,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33
    DB $C1,$30,$08,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$88,$DB,$CD,$9B
    DB $33,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33,$D8,$21,$26,$DD
    DB $06,$05,$CD,$22,$57,$C9,$C9,$CD,$BA,$4E,$D0,$CD,$04,$4F,$38,$08
    DB $21,$26,$DD,$06,$05,$CD,$22,$57,$CD,$3C,$4F,$D0,$21,$26,$DD,$06
    DB $05,$CD,$22,$57,$C9,$C9,$CD,$E5,$4E,$D0,$CD,$22,$4F,$30,$08,$21
    DB $26,$DD,$06,$0A,$CD,$22,$57,$CD,$3C,$4F,$D8,$21,$26,$DD,$06,$0A
    DB $CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$03,$D8,$FE,$12,$28,$11,$FE,$14
    DB $38,$0D,$FE,$4F,$28,$09,$FE,$57,$D8,$FE,$58,$C8,$FE,$67,$D0,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$1E,$00,$D5,$79,$CD,$74,$33
    DB $D1,$38,$01,$1C,$05,$20,$F4,$7B,$FE,$02,$D8,$21,$26,$DD,$06,$14
    DB $CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$3F,$28,$03,$FE,$40,$C0,$FA,$88
    DB $DB,$E6,$04,$EE,$04,$5F,$16,$03,$CD,$9B,$33,$29,$4D,$44,$7B,$CD
    DB $74,$33,$38,$15,$7B,$21,$F3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A
    DB $66,$6F,$CD,$14,$33,$38,$02,$30,$05,$1C,$15,$20,$E1,$C9,$21,$26
    DB $DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$95,$28,$06,$FE,$30
    DB $D8,$FE,$32,$D0,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$79,$CD,$74,$33
    DB $28,$02,$38,$05,$0C,$05,$20,$F4,$C9,$21,$26,$DD,$06,$2D,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$32,$28,$03,$FE,$96,$C0,$FA,$88,$DB,$57
    DB $E6,$04,$4F,$28,$05,$FA,$75,$DB,$18,$03,$FA,$74,$DB,$FE,$01,$C8
    DB $47,$79,$BA,$28,$04,$CD,$74,$33,$D0,$0C,$05,$20,$F4,$7A,$CD,$B7
    DB $33,$E5,$7A,$21,$B3,$DB,$CD,$2A,$57,$3E,$05,$CD,$DC,$21,$C1,$CD
    DB $14,$33,$D8,$21,$26,$DD,$06,$64,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE
    DB $33,$28,$03,$FE,$81,$C0,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$21,$02
    DB $DB,$CD,$3B,$33,$11,$0F,$01,$CD,$9B,$56,$FA,$88,$DB,$E6,$04,$4F
    DB $06,$03,$21,$02,$DB,$CD,$3B,$33,$11,$0F,$02,$CD,$9B,$56,$C9,$FA
    DB $8A,$DB,$FE,$34,$28,$03,$FE,$81,$C0,$FA,$88,$DB,$E6,$04,$4F,$06
    DB $03,$21,$02,$DB,$CD,$3B,$33,$11,$0F,$40,$CD,$9B,$56,$FA,$88,$DB
    DB $E6,$04,$4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$11,$0F,$8C,$CD,$9B
    DB $56,$C9,$FA,$8A,$DB,$FE,$35,$28,$03,$FE,$81,$C0,$FA,$88,$DB,$E6
    DB $04,$4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$11,$0F,$10,$CD,$9B,$56
    DB $C9,$FA,$8A,$DB,$FE,$36,$28,$03,$FE,$81,$C0,$FA,$88,$DB,$E6,$04
    DB $4F,$06,$03,$21,$02,$DB,$CD,$3B,$33,$11,$0F,$20,$CD,$9B,$56,$C9
    DB $FA,$8A,$DB,$FE,$93,$28,$0A,$FE,$94,$28,$06,$FE,$2B,$D8,$FE,$30
    DB $D0,$AF,$EA,$61,$DB,$FA,$88,$DB,$4F,$21,$A3,$DB,$87,$85,$6F,$3E
    DB $00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87
    DB $85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$79,$CD
    DB $C9,$4C,$D8,$3E,$01,$EA,$61,$DB,$FA,$8A,$DB,$FE,$2D,$C8,$FE,$2F
    DB $C8,$21,$26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$93,$28
    DB $0A,$FE,$94,$28,$06,$FE,$2B,$D8,$FE,$30,$D0,$AF,$EA,$63,$DB,$FA
    DB $88,$DB,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56
    DB $DB,$7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67
    DB $7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$79,$CD,$06,$4D,$D8,$3E,$01,$EA
    DB $63,$DB,$21,$26,$DD,$06,$0A,$CD,$22,$57,$AF,$EA,$65,$DB,$FA,$88
    DB $DB,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D
    DB $EA,$58,$DB,$7C,$EA,$59,$DB,$79,$CD,$3A,$4D,$D8,$3E,$01,$EA,$65
    DB $DB,$21,$26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$93,$28
    DB $0A,$FE,$94,$28,$06,$FE,$2B,$D8,$FE,$30,$D0,$AF,$EA,$67,$DB,$FA
    DB $88,$DB,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56
    DB $DB,$7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67
    DB $7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$79,$CD,$5E,$4D,$D8,$3E,$01,$EA
    DB $67,$DB,$FA,$8A,$DB,$FE,$2E,$C8,$21,$26,$DD,$06,$05,$CD,$22,$57
    DB $C9,$FA,$8A,$DB,$FE,$93,$28,$0A,$FE,$94,$28,$06,$FE,$2B,$D8,$FE
    DB $30,$D0,$AF,$EA,$69,$DB,$FA,$88,$DB,$4F,$CD,$B7,$33,$FE,$01,$C0
    DB $7C,$B7,$C0,$3E,$01,$EA,$69,$DB,$FA,$8A,$DB,$FE,$2E,$C8,$21,$26
    DB $DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94,$28,$06,$FE,$2B
    DB $D8,$FE,$30,$D0,$CD,$34,$75,$AF,$EA,$62,$DB,$FA,$88,$DB,$57,$E6
    DB $04,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D
    DB $EA,$58,$DB,$7C,$EA,$59,$DB,$79,$BA,$28,$0E,$CD,$74,$33,$38,$09
    DB $CD,$C9,$4C,$38,$04,$21,$62,$DB,$34,$FA,$56,$DB,$6F,$FA,$57,$DB
    DB $67,$23,$23,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$58,$DB,$6F,$FA
    DB $59,$DB,$67,$23,$23,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$0C,$05,$20
    DB $C6,$FA,$8A,$DB,$FE,$2D,$C8,$FE,$2F,$C8,$FA,$62,$DB,$B7,$C8,$21
    DB $26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94,$28,$06,$FE
    DB $2B,$D8,$FE,$30,$D0,$CD,$34,$75,$AF,$EA,$64,$DB,$FA,$88,$DB,$57
    DB $E6,$04,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56
    DB $DB,$7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67
    DB $7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$79,$BA,$28,$0E,$CD,$74,$33,$38
    DB $09,$CD,$06,$4D,$38,$04,$21,$64,$DB,$34,$FA,$56,$DB,$6F,$FA,$57
    DB $DB,$67,$23,$23,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$58,$DB,$6F
    DB $FA,$59,$DB,$67,$23,$23,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$0C,$05
    DB $20,$C6,$FA,$64,$DB,$B7,$C8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$CD
    DB $34,$75,$AF,$EA,$66,$DB,$FA,$88,$DB,$57,$E6,$04,$4F,$21,$A3,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$79
    DB $21,$B3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C,$EA
    DB $59,$DB,$79,$BA,$28,$0E,$CD,$74,$33,$38,$09,$CD,$3A,$4D,$38,$04
    DB $21,$66,$DB,$34,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$23,$23,$7D,$EA
    DB $56,$DB,$7C,$EA,$57,$DB,$FA,$58,$DB,$6F,$FA,$59,$DB,$67,$23,$23
    DB $7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$0C,$05,$20,$C6,$FA,$66,$DB,$B7
    DB $C8,$21,$26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94,$28
    DB $06,$FE,$2B,$D8,$FE,$30,$D0,$CD,$34,$75,$AF,$EA,$68,$DB,$FA,$88
    DB $DB,$57,$E6,$04,$4F,$21,$A3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$79,$21,$B3,$DB,$87,$85,$6F,$3E,$00
    DB $8C,$67,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$79,$BA,$28,$0E,$CD,$74
    DB $33,$38,$09,$CD,$5E,$4D,$38,$04,$21,$68,$DB,$34,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$23,$23,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$58
    DB $DB,$6F,$FA,$59,$DB,$67,$23,$23,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB
    DB $0C,$05,$20,$C6,$FA,$68,$DB,$B7,$C8,$FA,$8A,$DB,$FE,$2E,$C8,$21
    DB $26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94,$28,$06,$FE
    DB $2B,$D8,$FE,$30,$D0,$CD,$34,$75,$AF,$EA,$6A,$DB,$FA,$88,$DB,$57
    DB $E6,$04,$4F,$79,$BA,$28,$15,$CD,$74,$33,$38,$10,$79,$CD,$B7,$33
    DB $FE,$01,$20,$08,$7C,$B7,$20,$04,$21,$6A,$DB,$34,$0C,$05,$20,$E3
    DB $FA,$6A,$DB,$B7,$C8,$FA,$8A,$DB,$FE,$2E,$C8,$21,$26,$DD,$06,$05
    DB $CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94,$28,$06,$FE,$2E,$D8,$FE,$30
    DB $D0,$FA,$61,$DB,$47,$FA,$62,$DB,$80,$FE,$02,$D8,$FA,$8A,$DB,$FE
    DB $2F,$C8,$21,$26,$DD,$06,$05,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$94
    DB $28,$06,$FE,$2E,$D8,$FE,$30,$D0,$FA,$63,$DB,$47,$FA,$64,$DB,$80
    DB $FE,$02,$D8,$21,$26,$DD,$06,$0F,$CD,$22,$57,$FA,$65,$DB,$47,$FA
    DB $66,$DB,$80,$FE,$02,$D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA
    DB $8A,$DB,$FE,$2E,$D8,$FE,$30,$D0,$FA,$67,$DB,$47,$FA,$68,$DB,$80
    DB $FE,$02,$D8,$FA,$8A,$DB,$FE,$2E,$C8,$21,$26,$DD,$06,$0A,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$2F,$C0,$FA,$69,$DB,$47,$FA,$6A,$DB,$80
    DB $FE,$02,$D8,$FA,$8A,$DB,$FE,$2E,$C8,$21,$26,$DD,$06,$0A,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$4F,$C8,$FE,$44,$D8,$FE,$52,$38,$15,$FE
    DB $D9,$D0,$FE,$D6,$30,$0E,$FE,$6A,$D0,$FE,$67,$30,$07,$FE,$55,$28
    DB $03,$FE,$57,$C0,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$3A,$E6,$03
    DB $20,$06,$2B,$2B,$7E,$E6,$0C,$C8,$21,$26,$DD,$06,$14,$CD,$22,$57
    DB $C9,$FA,$8A,$DB,$FE,$25,$28,$03,$FE,$41,$C0,$FA,$88,$DB,$E6,$04
    DB $4F,$06,$03,$79,$CD,$74,$33,$38,$0B,$79,$21,$03,$DB,$CD,$3B,$33
    DB $7E,$E6,$0C,$C8,$0C,$05,$20,$EB,$CD,$A7,$57,$C9,$CD,$73,$4E,$C0
    DB $FA,$8A,$DB,$FE,$25,$28,$07,$FE,$7A,$28,$03,$FE,$41,$C0,$FA,$88
    DB $DB,$5F,$CD,$A3,$74,$CD,$E4,$74,$D8,$21,$26,$DD,$06,$14,$CD,$22
    DB $57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$7A,$28,$0E,$FE,$82,$28
    DB $0A,$FE,$25,$28,$06,$FE,$1C,$D8,$FE,$1E,$D0,$CD,$A3,$74,$FA,$88
    DB $DB,$E6,$04,$5F,$16,$03,$CD,$E4,$74,$30,$05,$1C,$15,$20,$F7,$C9
    DB $21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB
    DB $FE,$18,$28,$11,$FE,$1E,$D8,$FE,$20,$38,$0A,$FE,$72,$D8,$FE,$74
    DB $38,$03,$FE,$77,$C0,$AF,$EA,$6C,$DB,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$AF,$EA,$56,$DB,$EA,$57,$DB,$79,$CD,$74,$33,$38,$2D
    DB $79,$21,$03,$DB,$CD,$3B,$33,$CB,$4E,$20,$09,$23,$23,$23,$23,$7E
    DB $E6,$03,$28,$19,$FA,$56,$DB,$5F,$FA,$57,$DB,$57,$79,$CD,$9B,$33
    DB $19,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$21,$6C,$DB,$34,$0C,$05,$20
    DB $C9,$FA,$6C,$DB,$B7,$C8,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$DC
    DB $21,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB,$FA,$88,$DB,$E6,$04,$CD,$CA
    DB $4F,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CB,$25,$CB,$14,$FA,$58,$DB
    DB $4F,$FA,$59,$DB,$47,$CD,$14,$33,$D0,$21,$26,$DD,$06,$0A,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$24,$C0,$FA,$88,$DB,$E6,$04,$4F,$06,$03
    DB $CD,$0F,$75,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$26,$28,$07,$FE
    DB $7F,$28,$03,$FE,$43,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03
    DB $CD,$0F,$75,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$17,$28,$0A,$FE
    DB $26,$D8,$FE,$7F,$28,$03,$FE,$29,$D0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$79,$CD,$74,$33,$38,$37,$79,$21,$64,$DC,$CB,$37,$85
    DB $6F,$3E,$00,$8C,$67,$16,$08,$2A,$B7,$28,$25,$FE,$01,$20,$1D,$7E
    DB $FE,$02,$28,$21,$FE,$05,$28,$1D,$FE,$08,$28,$19,$FE,$0B,$28,$15
    DB $FE,$0E,$28,$11,$FE,$11,$38,$04,$FE,$14,$38,$09,$23,$15,$20,$D7
    DB $0C,$05,$20,$BF,$C9,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$CD,$73
    DB $4E,$C0,$FA,$8A,$DB,$FE,$20,$D8,$FE,$24,$D0,$FA,$88,$DB,$E6,$04
    DB $EE,$04,$4F,$06,$03,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$CD
    DB $BA,$56,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$FA,$4C,$DB,$CD,$DC,$21
    DB $7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$88,$DB,$E6,$04,$5F,$16,$03
    DB $21,$03,$DC,$87,$85,$6F,$3E,$00,$8C,$67,$FA,$56,$DB,$4F,$FA,$57
    DB $DB,$47,$7B,$CD,$74,$33,$38,$0A,$E5,$2A,$66,$6F,$CD,$14,$33,$E1
    DB $38,$08,$23,$23,$1C,$15,$20,$EA,$18,$08,$21,$26,$DD,$06,$0A,$CD
    DB $22,$57,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$21,$03,$DC,$87
    DB $85,$6F,$3E,$00,$8C,$67,$CD,$BA,$56,$FA,$56,$DB,$6F,$FA,$57,$DB
    DB $67,$FA,$4C,$DB,$CD,$DC,$21,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA
    DB $88,$DB,$E6,$04,$4F,$06,$03,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C
    DB $67,$CD,$BA,$56,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$FA,$4C,$DB,$CD
    DB $DC,$21,$FA,$58,$DB,$4F,$FA,$59,$DB,$47,$CD,$14,$33,$D0,$21,$26
    DB $DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$29,$C0,$CD,$73,$4E
    DB $C0,$FA,$88,$DB,$21,$B3,$DB,$87,$5F,$CD,$2A,$57,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$7B,$CD,$B0,$33,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB
    DB $7B,$CD,$9B,$33,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB,$7B,$CD,$A2,$33
    DB $7D,$EA,$5C,$DB,$7C,$EA,$5D,$DB,$FA,$88,$DB,$E6,$04,$EE,$04,$5F
    DB $16,$03,$AF,$EA,$4C,$DB,$7B,$CD,$74,$33,$DA,$B0,$69,$7B,$21,$B3
    DB $DB,$CD,$2A,$57,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33,$38
    DB $04,$21,$4C,$DB,$34,$7B,$CD,$B0,$33,$FA,$58,$DB,$4F,$FA,$59,$DB
    DB $47,$CD,$14,$33,$18,$04,$21,$4C,$DB,$34,$7B,$CD,$9B,$33,$FA,$5A
    DB $DB,$4F,$FA,$5B,$DB,$47,$CD,$14,$33,$38,$04,$21,$4C,$DB,$34,$7B
    DB $CD,$A2,$33,$FA,$5C,$DB,$4F,$FA,$5D,$DB,$47,$CD,$14,$33,$38,$04
    DB $21,$4C,$DB,$34,$FA,$4C,$DB,$FE,$03,$30,$06,$1C,$15,$C2,$4B,$69
    DB $C9,$21,$26,$DD,$06,$14,$CD,$22,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A
    DB $DB,$FE,$76,$28,$06,$FE,$1A,$D8,$FE,$1C,$D0,$FA,$88,$DB,$87,$57
    DB $21,$C3,$DB,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57
    DB $DB,$7A,$21,$D3,$DB,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C
    DB $EA,$59,$DB,$CD,$5E,$4D,$D0,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9
    DB $FA,$8A,$DB,$FE,$80,$C0,$CD,$73,$4E,$C0,$FA,$88,$DB,$E6,$04,$EE
    DB $04,$4F,$06,$03,$21,$03,$DB,$CD,$3B,$33,$7D,$EA,$56,$DB,$7C,$EA
    DB $57,$DB,$AF,$EA,$4C,$DB,$79,$CD,$74,$33,$DA,$D1,$6A,$7E,$E6,$3F
    DB $28,$1E,$CB,$46,$C4,$EF,$6A,$CB,$4E,$C4,$EF,$6A,$CB,$56,$C4,$EF
    DB $6A,$CB,$5E,$C4,$EF,$6A,$CB,$66,$C4,$EF,$6A,$CB,$6E,$C4,$EF,$6A
    DB $23,$7E,$E6,$7F,$28,$23,$CB,$46,$C4,$EF,$6A,$CB,$4E,$C4,$EF,$6A
    DB $CB,$56,$C4,$EF,$6A,$CB,$5E,$C4,$EF,$6A,$CB,$66,$C4,$EF,$6A,$CB
    DB $6E,$C4,$EF,$6A,$CB,$76,$C4,$EF,$6A,$23,$7E,$E6,$C0,$28,$0A,$CB
    DB $76,$C4,$EF,$6A,$CB,$7E,$C4,$EF,$6A,$23,$23,$7E,$E6,$CC,$28,$0B
    DB $E6,$C0,$C4,$EF,$6A,$7E,$E6,$0C,$C4,$EF,$6A,$23,$CB,$76,$C4,$EF
    DB $6A,$FA,$88,$DB,$0F,$0F,$E6,$01,$21,$00,$DB,$85,$6F,$3E,$00,$8C
    DB $67,$7E,$E6,$2C,$28,$0F,$CB,$56,$C4,$EF,$6A,$CB,$5E,$C4,$EF,$6A
    DB $CB,$6E,$C4,$EF,$6A,$FA,$4C,$DB,$FE,$03,$30,$26,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$3E,$08,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$0C,$05,$C2,$2B,$6A,$C9,$FA,$4C,$DB,$3C,$EA,$4C
    DB $DB,$C9,$21,$26,$DD,$06,$14,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$83
    DB $C0,$CD,$73,$4E,$C0,$AF,$EA,$4C,$DB,$EA,$4D,$DB,$FA,$88,$DB,$E6
    DB $04,$4F,$06,$03,$79,$CD,$74,$33,$38,$35,$79,$21,$65,$DC,$CB,$37
    DB $85,$6F,$3E,$00,$8C,$67,$FA,$4D,$DB,$3C,$EA,$4D,$DB,$16,$08,$2A
    DB $FE,$FF,$28,$1B,$FE,$3A,$38,$0C,$FE,$D5,$28,$08,$FE,$DA,$28,$04
    DB $FE,$DC,$20,$07,$FA,$4C,$DB,$3C,$EA,$4C,$DB,$23,$15,$20,$E0,$0C
    DB $05,$20,$C1,$FA,$4C,$DB,$4F,$FA,$4D,$DB,$B9,$D8,$FA,$88,$DB,$E6
    DB $04,$EE,$04,$4F,$06,$03,$16,$00,$79,$CD,$74,$33,$38,$39,$79,$21
    DB $65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$1E,$08,$2A,$FE,$FF,$28
    DB $22,$FE,$02,$28,$18,$FE,$05,$28,$14,$FE,$08,$28,$10,$FE,$0B,$28
    DB $0C,$FE,$0E,$28,$08,$FE,$11,$38,$0A,$FE,$14,$30,$06,$14,$7A,$FE
    DB $02,$30,$09,$23,$1D,$20,$D5,$0C,$05,$20,$BD,$C9,$21,$26,$DD,$06
    DB $14,$CD,$22,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$26,$28,$03
    DB $FE,$7F,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$21,$65
    DB $DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$1E,$08,$2A,$FE,$FF,$28,$21
    DB $FE,$4F,$28,$1D,$FE,$59,$28,$19,$FE,$5B,$28,$15,$FE,$64,$28,$11
    DB $FE,$65,$28,$0D,$FE,$D9,$28,$09,$23,$1D,$20,$DF,$0C,$05,$20,$CD
    DB $C9,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$8F,$28
    DB $06,$FE,$88,$D8,$FE,$8A,$D0,$FA,$88,$DB,$57,$7A,$CD,$B7,$33,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$7A,$21,$B3,$DB,$CD,$2A,$57,$7D,$EA
    DB $58,$DB,$7C,$EA,$59,$DB,$3E,$0A,$CD,$DC,$21,$FA,$56,$DB,$4F,$FA
    DB $57,$DB,$47,$09,$FA,$58,$DB,$4F,$FA,$59,$DB,$47,$CD,$14,$33,$D8
    DB $FA,$88,$DB,$57,$E6,$04,$4F,$06,$03,$AF,$EA,$4C,$DB,$79,$BA,$28
    DB $1A,$CD,$74,$33,$38,$15,$79,$CD,$B7,$33,$CD,$92,$6C,$C5,$FA,$56
    DB $DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33,$C1,$D0,$0C,$05,$20,$DE,$FA
    DB $4C,$DB,$B7,$C8,$21,$26,$DD,$06,$14,$CD,$22,$57,$C9,$D5,$C5,$E5
    DB $79,$CD,$A9,$33,$3E,$0A,$CD,$DC,$21,$7D,$B4,$20,$01,$23,$C1,$C5
    DB $CD,$14,$33,$38,$04,$21,$4C,$DB,$34,$E1,$C1,$D1,$C9,$FA,$8A,$DB
    DB $FE,$8D,$C8,$FE,$8F,$C8,$FE,$8C,$D8,$FE,$91,$D0,$FA,$88,$DB,$21
    DB $A3,$DB,$87,$4F,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA
    DB $57,$DB,$79,$21,$B3,$DB,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB
    DB $7C,$EA,$59,$DB,$79,$CD,$5E,$4D,$D8,$21,$26,$DD,$06,$14,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$41,$C0,$FA,$88,$DB,$21,$03,$DB,$CD,$3B
    DB $33,$CB,$56,$C8,$CD,$A7,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE
    DB $27,$D8,$FE,$29,$D0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79
    DB $CD,$74,$33,$DA,$66,$6D,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$46,$20
    DB $30,$16,$08,$79,$21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$2A
    DB $FE,$FF,$28,$1D,$FE,$1B,$38,$14,$FE,$1C,$28,$10,$FE,$1D,$28,$0C
    DB $FE,$20,$28,$08,$FE,$21,$28,$04,$FE,$DA,$20,$01,$C9,$23,$15,$20
    DB $DE,$0C,$05,$C2,$24,$6D,$CD,$A7,$57,$C9,$C9,$C9,$FA,$8A,$DB,$FE
    DB $5C,$D8,$FE,$64,$D0,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$E6
    DB $30,$C8,$21,$26,$DD,$06,$1E,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$6F
    DB $C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38
    DB $0A,$79,$21,$02,$DB,$CD,$3B,$33,$CB,$6E,$C8,$0C,$05,$20,$EC,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$17,$28,$07,$FE,$27,$28,$03,$FE,$28
    DB $C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38
    DB $0A,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$46,$C8,$0C,$05,$20,$EC,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$24,$28,$0F,$FE,$8A,$28,$0B,$FE,$8B
    DB $28,$07,$FE,$8F,$28,$03,$FE,$92,$C0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$79,$CD,$74,$33,$38,$0A,$79,$21,$03,$DB,$CD,$3B,$33
    DB $CB,$7E,$C8,$0C,$05,$20,$EC,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$91
    DB $C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$C5,$79,$CD,$74,$33
    DB $38,$0B,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$76,$28,$07,$0C,$05,$20
    DB $EB,$C1,$18,$3E,$C1,$CD,$73,$4E,$C0,$79,$CD,$74,$33,$38,$2F,$79
    DB $21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$16,$08,$2A,$FE,$FF
    DB $28,$1C,$FE,$6E,$C8,$FE,$71,$C8,$FE,$75,$38,$12,$FE,$79,$D8,$FE
    DB $91,$C8,$FE,$94,$C8,$FE,$96,$C8,$23,$15,$20,$E1,$18,$04,$0C,$05
    DB $20,$C7,$CD,$A7,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$17,$28
    DB $07,$FE,$27,$28,$03,$FE,$28,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$79,$CD,$74,$33,$38,$23,$79,$21,$65,$DC,$CB,$37,$85,$6F
    DB $3E,$00,$8C,$67,$16,$08,$2A,$FE,$FF,$28,$10,$FE,$3A,$D8,$FE,$D5
    DB $C8,$FE,$DA,$C8,$FE,$DC,$C8,$23,$15,$20,$EB,$0C,$05,$20,$D3,$CD
    DB $A7,$57,$C9,$C9,$FA,$8A,$DB,$FE,$81,$C0,$FA,$88,$DB,$E6,$04,$4F
    DB $06,$03,$79,$CD,$74,$33,$38,$1B,$79,$21,$02,$DB,$CD,$3B,$33,$2A
    DB $B7,$C0,$2A,$E6,$C3,$C0,$23,$2A,$E6,$80,$C0,$23,$2A,$E6,$03,$C0
    DB $CB,$7E,$C0,$0C,$05,$20,$DB,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$14
    DB $28,$17,$FE,$30,$D8,$FE,$33,$C8,$FE,$36,$38,$0D,$FE,$88,$D8,$FE
    DB $8A,$38,$06,$FE,$95,$D8,$FE,$97,$D0,$FA,$88,$DB,$E6,$04,$21,$1B
    DB $DD,$85,$6F,$3E,$00,$8C,$67,$06,$03,$16,$00,$2A,$FE,$FF,$28,$01
    DB $14,$05,$20,$F7,$7A,$FE,$02,$D0,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE
    DB $03,$D8,$FE,$12,$38,$19,$FE,$13,$28,$15,$FE,$14,$28,$11,$FE,$4F
    DB $28,$0D,$FE,$58,$C8,$FE,$57,$D8,$FE,$67,$38,$03,$FE,$71,$C0,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$16,$00,$79,$CD,$74,$33,$38
    DB $01,$14,$0C,$05,$20,$F5,$7A,$FE,$01,$C0,$FA,$8A,$DB,$FE,$57,$28
    DB $09,$21,$27,$DD,$06,$14,$CD,$22,$57,$C9,$CD,$A7,$57,$C9,$FA,$8A
    DB $DB,$FE,$8A,$D8,$FE,$8C,$D0,$FA,$88,$DB,$21,$04,$DB,$CD,$3B,$33
    DB $7E,$E6,$48,$C8,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$1B,$C0,$FA,$88
    DB $DB,$21,$04,$DB,$CD,$3B,$33,$CB,$46,$C8,$CD,$A7,$57,$C9,$FA,$8A
    DB $DB,$FE,$7B,$D8,$FE,$7D,$D0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06
    DB $03,$79,$CD,$74,$33,$38,$0D,$79,$21,$8B,$DB,$85,$6F,$3E,$00,$8C
    DB $67,$CB,$66,$C8,$0C,$05,$20,$E9,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE
    DB $74,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33
    DB $38,$22,$79,$EA,$89,$DB,$3E,$02,$EA,$4C,$DB,$C5,$21,$06,$52,$D7
    DB $C1,$FA,$4C,$DB,$E6,$30,$FE,$30,$28,$0A,$79,$21,$05,$DB,$CD,$3B
    DB $33,$CB,$7E,$C8,$0C,$05,$20,$D4,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE
    DB $26,$C0,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$79,$CD,$74,$33,$38,$0A
    DB $79,$21,$05,$DB,$CD,$3B,$33,$CB,$76,$C8,$0C,$05,$20,$EC,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$77,$C0,$FA,$88,$DB,$21,$07,$DB,$CD,$3B
    DB $33,$7E,$E6,$0C,$C8,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$72,$D8,$FE
    DB $74,$D0,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$79,$CD,$74,$33,$38,$0B
    DB $79,$21,$07,$DB,$CD,$3B,$33,$7E,$E6,$03,$C8,$0C,$05,$20,$EB,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$1A,$38,$10,$FE,$1C,$D8,$FE,$1E,$C8
    DB $FE,$1F,$C8,$FE,$DA,$28,$03,$FE,$22,$D0,$FA,$88,$DB,$E6,$04,$EE
    DB $04,$4F,$06,$03,$79,$CD,$74,$33,$38,$0B,$79,$21,$04,$DB,$CD,$3B
    DB $33,$7E,$E6,$22,$C8,$0C,$05,$20,$EB,$CD,$A7,$57,$C9,$FA,$8A,$DB
    DB $FE,$1A,$38,$48,$FE,$1C,$D8,$FE,$1E,$38,$41,$FE,$20,$D8,$FE,$22
    DB $38,$3A,$FE,$2A,$28,$36,$FE,$3B,$D8,$FE,$41,$38,$2F,$FE,$44,$28
    DB $2B,$FE,$53,$28,$27,$FE,$55,$D8,$FE,$80,$38,$20,$FE,$82,$28,$1C
    DB $FE,$88,$D8,$FE,$8A,$38,$15,$FE,$8C,$D8,$FE,$93,$38,$0E,$FE,$D6
    DB $D8,$FE,$DB,$38,$07,$FE,$DC,$38,$03,$FE,$DD,$C0,$FA,$88,$DB,$E6
    DB $04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38,$0B,$79,$21,$07,$DB
    DB $CD,$3B,$33,$7E,$E6,$C0,$C8,$0C,$05,$20,$EB,$CD,$A7,$57,$C9,$FA
    DB $8A,$DB,$FE,$15,$D8,$FE,$17,$38,$4B,$FE,$19,$28,$47,$FE,$2A,$28
    DB $43,$FE,$6A,$D8,$FE,$6C,$38,$3C,$FE,$6E,$28,$38,$FE,$70,$28,$34
    DB $FE,$72,$D8,$FE,$74,$38,$2D,$FE,$77,$D8,$FE,$79,$38,$26,$FE,$7A
    DB $D8,$FE,$7E,$38,$1F,$FE,$80,$D8,$FE,$83,$38,$18,$FE,$88,$D8,$FE
    DB $8A,$38,$11,$FE,$8C,$D8,$FE,$8D,$C8,$FE,$DA,$28,$07,$FE,$DC,$28
    DB $03,$FE,$91,$D0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD
    DB $45,$33,$D0,$0C,$05,$20,$F7,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$15
    DB $D8,$FE,$17,$38,$20,$FE,$19,$28,$1C,$FE,$68,$D8,$FE,$6C,$38,$15
    DB $FE,$6E,$28,$11,$FE,$70,$28,$0D,$FE,$78,$D8,$FE,$7A,$C8,$FE,$7E
    DB $38,$03,$FE,$DA,$C0,$CD,$52,$4F,$79,$CD,$45,$33,$38,$03,$CD,$59
    DB $4F,$0C,$05,$20,$F3,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE,$D8,$21
    DB $26,$DD,$06,$14,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$18,$28,$06,$FE
    DB $72,$D8,$FE,$74,$D0,$CD,$52,$4F,$79,$CD,$74,$33,$38,$17,$79,$21
    DB $03,$DB,$CD,$3B,$33,$CB,$4E,$20,$0C,$23,$23,$23,$23,$7E,$E6,$03
    DB $20,$03,$CD,$59,$4F,$0C,$05,$20,$DF,$FA,$55,$DB,$B7,$C8,$21,$54
    DB $DB,$BE,$D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE
    DB $17,$C0,$CD,$52,$4F,$79,$CD,$74,$33,$38,$14,$79,$CD,$99,$50,$38
    DB $0E,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$46,$20,$03,$CD,$59,$4F,$0C
    DB $05,$20,$E2,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE,$D8,$21,$26,$DD
    DB $06,$1E,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$17,$28,$06,$FE,$75,$D8
    DB $FE,$77,$D0,$CD,$52,$4F,$79,$CD,$74,$33,$38,$12,$79,$21,$C3,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$2A,$B6,$28,$03,$CD,$59,$4F,$0C,$05
    DB $20,$E4,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE,$D8,$21,$26,$DD,$06
    DB $0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$7A,$28,$06,$FE,$1C,$D8,$FE
    DB $1E,$D0,$CD,$52,$4F,$79,$CD,$74,$33,$38,$10,$79,$CD,$A2,$33,$7D
    DB $FE,$02,$30,$04,$7C,$B7,$28,$03,$CD,$59,$4F,$0C,$05,$20,$E6,$FA
    DB $55,$DB,$B7,$C8,$21,$54,$DB,$BE,$D8,$21,$26,$DD,$06,$0A,$CD,$22
    DB $57,$C9,$FA,$8A,$DB,$FE,$20,$D8,$FE,$22,$D0,$CD,$52,$4F,$79,$CD
    DB $74,$33,$38,$13,$79,$21,$03,$DC,$CD,$2A,$57,$7D,$FE,$02,$30,$04
    DB $7C,$B7,$28,$03,$CD,$59,$4F,$0C,$05,$20,$E3,$FA,$55,$DB,$B7,$C8
    DB $21,$54,$DB,$BE,$D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A
    DB $DB,$FE,$67,$28,$06,$FE,$6C,$D8,$FE,$6E,$D0,$CD,$52,$4F,$79,$CD
    DB $74,$33,$38,$0F,$79,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$03,$20,$03
    DB $CD,$59,$4F,$0C,$05,$20,$E7,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE
    DB $D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$6F,$C0
    DB $CD,$52,$4F,$79,$CD,$74,$33,$38,$0F,$79,$21,$02,$DB,$CD,$3B,$33
    DB $7E,$E6,$20,$20,$03,$CD,$59,$4F,$0C,$05,$20,$E7,$FA,$55,$DB,$B7
    DB $C8,$21,$54,$DB,$BE,$D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA
    DB $8A,$DB,$FE,$91,$C0,$CD,$52,$4F,$79,$CD,$74,$33,$38,$15,$79,$CD
    DB $F9,$50,$38,$0F,$79,$21,$03,$DB,$CD,$3B,$33,$7E,$E6,$40,$20,$03
    DB $CD,$59,$4F,$0C,$05,$20,$E1,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE
    DB $D8,$21,$26,$DD,$06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$92,$C0
    DB $CD,$52,$4F,$79,$CD,$74,$33,$38,$15,$79,$CD,$C5,$50,$38,$0F,$79
    DB $21,$03,$DB,$CD,$3B,$33,$7E,$E6,$80,$20,$03,$CD,$59,$4F,$0C,$05
    DB $20,$E1,$FA,$55,$DB,$B7,$C8,$21,$54,$DB,$BE,$D8,$21,$26,$DD,$06
    DB $0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$15,$D8,$FE,$17,$38,$20,$FE
    DB $19,$28,$1C,$FE,$68,$D8,$FE,$6C,$38,$15,$FE,$6E,$28,$11,$FE,$70
    DB $28,$0D,$FE,$78,$D8,$FE,$7A,$C8,$FE,$7E,$38,$03,$FE,$DA,$C0,$CD
    DB $78,$4F,$79,$CD,$45,$33,$38,$06,$CD,$A9,$4F,$FE,$03,$C0,$0C,$05
    DB $20,$F0,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$18,$28,$06,$FE,$72,$D8
    DB $FE,$74,$D0,$CD,$78,$4F,$79,$CD,$74,$33,$38,$1A,$79,$21,$03,$DB
    DB $CD,$3B,$33,$CB,$4E,$20,$0F,$23,$23,$23,$23,$7E,$E6,$03,$20,$06
    DB $CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$DC,$CD,$A7,$57,$C9,$FA,$88
    DB $DB,$E6,$04,$EE,$04,$5F,$21,$00,$00,$CD,$74,$33,$38,$03,$CD,$A2
    DB $33,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$1C,$16,$02,$7B,$CD,$74,$33
    DB $38,$18,$CD,$A2,$33,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CD,$14,$33
    DB $30,$08,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$1C,$15,$20,$DE,$C9,$FA
    DB $56,$DB,$4F,$FA,$57,$DB,$47,$CB,$38,$CB,$19,$7B,$CD,$9B,$33,$CD
    DB $14,$33,$38,$14,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$CB,$3C,$CB,$1D
    DB $CD,$14,$33,$30,$03,$AF,$B7,$C9,$37,$C9,$79,$CD,$74,$33,$38,$17
    DB $79,$EA,$89,$DB,$3E,$04,$EA,$4C,$DB,$C5,$21,$06,$52,$D7,$C1,$FA
    DB $4C,$DB,$E6,$3C,$FE,$3C,$C0,$0C,$05,$20,$DF,$CD,$A7,$57,$C9,$FA
    DB $88,$DB,$FE,$04,$30,$05,$FA,$74,$DB,$18,$03,$FA,$75,$DB,$47,$C9
    DB $FA,$8A,$DB,$FE,$17,$C0,$CD,$78,$4F,$79,$CD,$74,$33,$38,$17,$79
    DB $CD,$99,$50,$38,$11,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$46,$20,$06
    DB $CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$DF,$CD,$A7,$57,$C9,$FA,$8A
    DB $DB,$FE,$1A,$28,$06,$FE,$75,$D8,$FE,$77,$D0,$CD,$78,$4F,$79,$CD
    DB $74,$33,$38,$15,$79,$21,$C3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A
    DB $B6,$28,$06,$CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$E1,$CD,$A7,$57
    DB $C9,$FA,$8A,$DB,$FE,$1C,$D8,$FE,$1E,$38,$03,$FE,$7A,$C0,$CD,$78
    DB $4F,$79,$CD,$74,$33,$38,$13,$79,$CD,$A2,$33,$7D,$FE,$02,$30,$04
    DB $7C,$B7,$28,$06,$CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$E3,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$20,$D8,$FE,$22,$D0,$CD,$78,$4F,$79,$CD
    DB $74,$33,$38,$16,$79,$21,$03,$DC,$CD,$2A,$57,$7D,$FE,$02,$30,$04
    DB $7C,$B7,$28,$06,$CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$E0,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$67,$28,$06,$FE,$6C,$D8,$FE,$6E,$D0,$CD
    DB $78,$4F,$79,$CD,$74,$33,$38,$12,$79,$21,$02,$DB,$CD,$3B,$33,$7E
    DB $E6,$03,$20,$06,$CD,$A9,$4F,$FE,$03,$C0,$0C,$05,$20,$E4,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$6F,$C0,$CD,$78,$4F,$79,$CD,$74,$33,$38
    DB $12,$79,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$20,$20,$06,$CD,$A9,$4F
    DB $FE,$03,$C0,$0C,$05,$20,$E4,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$91
    DB $C0,$CD,$78,$4F,$79,$CD,$74,$33,$38,$18,$79,$CD,$F9,$50,$38,$12
    DB $79,$21,$03,$DB,$CD,$3B,$33,$7E,$E6,$40,$20,$06,$CD,$A9,$4F,$FE
    DB $03,$C0,$0C,$05,$20,$DE,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$92,$C0
    DB $CD,$78,$4F,$79,$CD,$74,$33,$38,$18,$79,$CD,$C5,$50,$38,$12,$79
    DB $21,$03,$DB,$CD,$3B,$33,$7E,$E6,$80,$20,$06,$CD,$A9,$4F,$FE,$03
    DB $C0,$0C,$05,$20,$DE,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$14,$28,$07
    DB $FE,$32,$28,$03,$FE,$96,$C0,$AF,$EA,$66,$DB,$FA,$88,$DB,$E6,$04
    DB $4F,$06,$03,$C5,$79,$CD,$74,$33,$38,$78,$79,$21,$A3,$DB,$87,$85
    DB $6F,$3E,$00,$8C,$67,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$79,$21,$B3
    DB $DB,$87,$85,$6F,$3E,$00,$8C,$67,$7D,$EA,$58,$DB,$7C,$EA,$59,$DB
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$2A,$66,$6F,$E5,$FA,$58,$DB,$6F
    DB $FA,$59,$DB,$67,$2A,$66,$6F,$FA,$58,$DB,$6F,$FA,$59,$DB,$67,$7C
    DB $B7,$20,$0F,$7B,$0F,$0F,$E6,$3F,$B7,$28,$03,$5F,$18,$0C,$1E,$01
    DB $18,$08,$CB,$2C,$CB,$1D,$CB,$2C,$CB,$1D,$C1,$CD,$14,$33,$38,$12
    DB $21,$66,$DB,$34,$C1,$0C,$05,$20,$8A,$FA,$66,$DB,$B7,$C8,$CD,$A7
    DB $57,$C9,$C1,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$03,$D8,$FE,$12
    DB $C8,$FE,$15,$C8,$FE,$1A,$38,$4C,$FE,$1D,$28,$48,$FE,$21,$28,$44
    DB $FE,$3C,$D8,$FE,$3D,$C8,$FE,$3F,$38,$3A,$FE,$4F,$D8,$28,$35,$FE
    DB $52,$D8,$28,$30,$FE,$53,$28,$2C,$FE,$57,$D8,$28,$27,$FE,$59,$D8
    DB $FE,$67,$38,$20,$FE,$6A,$D8,$FE,$70,$C8,$FE,$72,$38,$16,$FE,$7C
    DB $D8,$FE,$7E,$38,$0F,$FE,$D5,$28,$0B,$FE,$D9,$28,$07,$FE,$DA,$28
    DB $03,$FE,$DC,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD
    DB $74,$33,$38,$05,$CD,$35,$57,$20,$05,$0C,$05,$20,$F1,$C9,$21,$27
    DB $DD,$06,$1E,$CD,$22,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB,$FE,$1B
    DB $C8,$FE,$1E,$38,$33,$FE,$20,$D8,$FE,$22,$38,$2C,$FE,$3B,$D8,$FE
    DB $41,$C8,$FE,$43,$C8,$FE,$54,$C8,$FE,$77,$C8,$FE,$7E,$38,$19,$FE
    DB $82,$28,$15,$FE,$91,$D8,$FE,$93,$38,$0E,$FE,$D5,$D8,$FE,$DA,$28
    DB $07,$FE,$DC,$28,$03,$FE,$DA,$D0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$79,$CD,$74,$33,$38,$04,$CD,$35,$57,$C8,$0C,$05,$20,$F2
    DB $21,$27,$DD,$06,$14,$CD,$22,$57,$C9,$CD,$73,$4E,$C0,$FA,$8A,$DB
    DB $FE,$17,$28,$28,$FE,$1A,$28,$24,$FE,$1B,$28,$20,$FE,$24,$28,$1C
    DB $FE,$26,$D8,$FE,$29,$38,$15,$FE,$75,$D8,$FE,$77,$38,$0E,$FE,$8A
    DB $D8,$FE,$8C,$38,$07,$FE,$8F,$28,$03,$FE,$92,$C0,$FA,$88,$DB,$E6
    DB $04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38,$0E,$79,$21,$C3,$DB
    DB $87,$85,$6F,$3E,$00,$8C,$67,$2A,$B6,$C0,$0C,$05,$20,$E8,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$33,$C0,$FA,$88,$DB,$E6,$04,$4F,$06,$03
    DB $79,$CD,$74,$33,$38,$0B,$79,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$03
    DB $C0,$0C,$05,$20,$EB,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$3C,$28,$03
    DB $FE,$3E,$C0,$FA,$88,$DB,$CD,$B7,$33,$44,$4D,$CB,$38,$CB,$19,$09
    DB $7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$79,$CD,$74,$33,$38,$1F,$C5,$79,$21,$A3,$DB,$87,$85,$6F
    DB $3E,$00,$8C,$67,$2A,$46,$4F,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD
    DB $14,$33,$C1,$28,$02,$38,$05,$0C,$05,$20,$D7,$C9,$21,$26,$DD,$06
    DB $14,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$84,$D8,$FE,$88,$D0,$FA,$88
    DB $DB,$E6,$04,$CB,$3F,$CB,$3F,$21,$00,$DB,$85,$6F,$3E,$00,$8C,$67
    DB $CB,$56,$C8,$FA,$88,$DB,$E6,$04,$C6,$03,$CD,$74,$33,$D8,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$2A,$28,$1C,$FE,$55,$D8,$FE,$57,$38,$15
    DB $FE,$7F,$28,$11,$FE,$88,$D8,$FE,$8A,$38,$0A,$FE,$8C,$D8,$FE,$91
    DB $38,$03,$FE,$DC,$C0,$FA,$ED,$D9,$FE,$15,$D8,$CD,$A7,$57,$C9,$FA
    DB $8A,$DB,$FE,$95,$28,$06,$FE,$30,$D8,$FE,$32,$D0,$FA,$88,$DB,$E6
    DB $04,$4F,$06,$03,$79,$CD,$74,$33,$28,$01,$D8,$0C,$05,$20,$F5,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$81,$C0,$FA,$88,$DB,$E6,$04,$4F,$06
    DB $03,$79,$CD,$74,$33,$38,$19,$79,$21,$03,$DB,$CD,$3B,$33,$2A,$E6
    DB $C3,$20,$12,$23,$23,$23,$2A,$E6,$03,$20,$0A,$7E,$E6,$80,$20,$05
    DB $0C,$05,$20,$DD,$C9,$21,$26,$DD,$06,$0F,$CD,$22,$57,$C9,$FA,$8A
    DB $DB,$FE,$14,$38,$0A,$FE,$4F,$28,$06,$FE,$58,$D8,$FE,$67,$D0,$FA
    DB $88,$DB,$CD,$74,$33,$D8,$FA,$88,$DB,$21,$03,$DB,$CD,$3B,$33,$2A
    DB $E6,$02,$20,$09,$23,$23,$23,$7E,$E6,$03,$20,$01,$C9,$21,$26,$DD
    DB $06,$0A,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$48,$D8,$FE,$4F,$38,$0A
    DB $FE,$D6,$D8,$FE,$D9,$D0,$D6,$CF,$18,$02,$D6,$48,$C7,$36,$7A,$5A
    DB $7A,$92,$7A,$A3,$7A,$B4,$7A,$C5,$7A,$D6,$7A,$E7,$7A,$F9,$7A,$0B
    DB $7B,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38
    DB $0D,$79,$21,$8B,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$46,$C0,$0C,$05
    DB $20,$E9,$C3,$1D,$7B,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E
    DB $01,$EA,$4C,$DB,$79,$CD,$74,$33,$38,$1C,$79,$21,$3C,$DC,$85,$6F
    DB $3E,$00,$8C,$67,$7E,$EA,$31,$DA,$C5,$21,$01,$03,$D7,$C1,$FA,$33
    DB $DA,$21,$4C,$DB,$BE,$C8,$0C,$05,$20,$DA,$C3,$1D,$7B,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$4F,$06,$03,$3E,$02,$EA,$4C,$DB,$18,$C6,$FA,$88
    DB $DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$03,$EA,$4C,$DB,$18,$B5,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$06,$EA,$4C,$DB,$18,$A4
    DB $FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$07,$EA,$4C,$DB,$18
    DB $93,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$08,$EA,$4C,$DB
    DB $18,$82,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$00,$EA,$4C
    DB $DB,$C3,$69,$7A,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$3E,$05
    DB $EA,$4C,$DB,$C3,$69,$7A,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03
    DB $3E,$04,$EA,$4C,$DB,$C3,$69,$7A,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE
    DB $43,$C0,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$E6,$30,$C8,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$82,$C0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$79,$CD,$74,$33,$38,$38,$79,$EA,$89,$DB,$3E,$02,$EA
    DB $4C,$DB,$C5,$21,$06,$52,$D7,$C1,$FA,$4C,$DB,$E6,$30,$FE,$30,$28
    DB $20,$79,$21,$03,$DC,$CD,$2A,$57,$CD,$94,$57,$D0,$79,$21,$F3,$DB
    DB $CD,$2A,$57,$CD,$94,$57,$D0,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$4E
    DB $C8,$0C,$05,$20,$BE,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$80,$C0,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33,$38,$27,$79
    DB $21,$02,$DB,$CD,$3B,$33,$2A,$2A,$E6,$C2,$20,$11,$2A,$E6,$10,$20
    DB $0C,$2A,$23,$2A,$E6,$03,$20,$05,$7E,$E6,$80,$28,$09,$21,$27,$DD
    DB $06,$14,$CD,$22,$57,$C9,$0C,$05,$20,$CF,$C9,$FA,$8A,$DB,$FE,$3B
    DB $D8,$FE,$41,$38,$2D,$FE,$44,$D8,$FE,$4F,$38,$26,$FE,$50,$D8,$FE
    DB $54,$38,$1F,$FE,$55,$D8,$FE,$58,$38,$18,$FE,$67,$D8,$FE,$6A,$38
    DB $11,$FE,$70,$28,$0D,$FE,$79,$D8,$FE,$7D,$38,$06,$FE,$D6,$D8,$FE
    DB $DA,$D0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD,$74,$33
    DB $38,$0B,$79,$21,$06,$DB,$CD,$3B,$33,$7E,$E6,$0C,$C8,$0C,$05,$20
    DB $EB,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$55,$C0,$FA,$88,$DB,$21,$03
    DB $DC,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F,$44,$4D,$09,$09,$3E
    DB $0A,$CD,$DC,$21,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06,$03,$79,$CD
    DB $74,$33,$38,$16,$C5,$E5,$79,$21,$03,$DC,$87,$85,$6F,$3E,$00,$8C
    DB $67,$2A,$46,$4F,$E1,$CD,$14,$33,$C1,$D8,$0C,$05,$20,$E0,$CD,$A7
    DB $57,$C9,$FA,$8A,$DB,$FE,$1A,$28,$07,$FE,$1B,$28,$03,$FE,$76,$C0
    DB $FA,$88,$DB,$87,$21,$C3,$DB,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F
    DB $FA,$88,$DB,$87,$21,$D3,$DB,$85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F
    DB $CB,$3C,$CB,$1D,$54,$5D,$CB,$3C,$CB,$1D,$19,$CD,$14,$33,$D0,$CD
    DB $A7,$57,$C9,$FA,$8A,$DB,$FE,$83,$C0,$FA,$88,$DB,$E6,$04,$EE,$04
    DB $4F,$06,$03,$79,$CD,$74,$33,$38,$37,$79,$21,$64,$DC,$CB,$37,$85
    DB $6F,$3E,$00,$8C,$67,$16,$08,$2A,$B7,$28,$25,$FE,$01,$20,$1D,$7E
    DB $FE,$02,$28,$22,$FE,$05,$28,$1E,$FE,$08,$28,$1A,$FE,$0B,$28,$16
    DB $FE,$0E,$28,$12,$FE,$11,$38,$04,$FE,$14,$38,$0A,$23,$15,$20,$D7
    DB $0C,$05,$20,$BF,$18,$3D,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$1E,$00
    DB $79,$CD,$74,$33,$38,$22,$79,$21,$64,$DC,$CB,$37,$85,$6F,$3E,$00
    DB $8C,$67,$16,$08,$2A,$B7,$28,$10,$FE,$01,$20,$08,$FE,$2B,$38,$04
    DB $FE,$33,$38,$09,$23,$15,$20,$EC,$0C,$05,$20,$D4,$C9,$1C,$5F,$FE
    DB $02,$38,$F1,$CD,$A7,$57,$C9,$FA,$8A,$DB,$FE,$3B,$28,$03,$FE,$3D
    DB $C0,$FA,$88,$DB,$87,$21,$A3,$DB,$85,$6F,$3E,$00,$8C,$67,$2A,$46
    DB $4F,$FA,$88,$DB,$87,$21,$B3,$DB,$85,$6F,$3E,$00,$8C,$67,$2A,$66
    DB $6F,$CB,$3C,$CB,$1D,$54,$5D,$CB,$3C,$CB,$1D,$19,$CD,$14,$33,$D8
    DB $21,$26,$DD,$06,$14,$CD,$22,$57,$C9,$FA,$8A,$DB,$FE,$80,$C0,$FA
    DB $88,$DB,$E6,$04,$EE,$04,$4F,$CB,$3F,$CB,$3F,$21,$00,$DB,$85,$6F
    DB $3E,$00,$8C,$67,$7E,$E6,$2C,$C0,$06,$03,$79,$21,$03,$DB,$CD,$3B
    DB $33,$2A,$E6,$3C,$C0,$2A,$E6,$6F,$C0,$2A,$E6,$40,$C0,$23,$2A,$E6
    DB $CC,$C0,$2A,$E6,$40,$C0,$05,$20,$E1,$CD,$A7,$57,$C9,$CD,$73,$4E
    DB $C0,$FA,$8A,$DB,$FE,$26,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F,$06
    DB $03,$1E,$08,$79,$21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C,$67,$7E
    DB $FE,$FF,$28,$24,$2A,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB,$3E,$06,$EA
    DB $4E,$DB,$F5,$C5,$D5,$E5,$21,$00,$54,$D7,$E1,$D1,$C1,$F1,$FA,$4C
    DB $DB,$FE,$00,$C0,$23,$1D,$20,$D7,$0C,$05,$20,$C5,$CD,$A7,$57,$C9
    DB $FA,$6C,$C8,$B7,$C0,$FA,$88,$DB,$FE,$04,$D0,$FA,$73,$DB,$FE,$01
    DB $C0,$FA,$8A,$DB,$FE,$12,$D8,$FE,$15,$38,$0B,$FE,$69,$28,$07,$FE
    DB $6B,$28,$03,$FE,$71,$C0,$CD,$A7,$57,$C9,$FA,$6C,$C8,$B7,$C0,$FA
    DB $88,$DB,$FE,$04,$D8,$FE,$07,$C8,$FA,$8A,$DB,$FE,$15,$38,$16,$FE
    DB $3B,$D8,$FE,$41,$C8,$FE,$43,$C8,$FE,$54,$C8,$FE,$6A,$38,$06,$FE
    DB $D6,$D8,$FE,$DA,$D0,$21,$26,$DD,$06,$14,$CD,$22,$57,$C9,$FA,$8A
    DB $DB,$FE,$24,$C0,$CD,$73,$4E,$C0,$FA,$88,$DB,$E6,$04,$EE,$04,$4F
    DB $06,$03,$79,$CD,$74,$33,$38,$05,$CD,$AB,$7E,$38,$08,$0C,$05,$20
    DB $F1,$CD,$A7,$57,$C9,$C9,$21,$65,$DC,$CB,$37,$85,$6F,$3E,$00,$8C
    DB $67,$16,$08,$2A,$CD,$C3,$7E,$D8,$23,$15,$20,$F7,$B7,$C9,$FE,$5C
    DB $38,$03,$FE,$64,$D8,$B7,$C9
.L7ECC:
    CP $03
    JR NC,.L7EEA
.L7ED0:
    PUSH HL
    LD HL,$CAC2
    CALL $25F8
    LD E,L
    LD D,H
    POP HL
    PUSH HL
    CALL $106C
    POP HL
.L7EDF:
    LD A,(HL)
    CP $F0
    RET Z
    INC HL
    JR .L7EDF
.L7EE6:
    LD A,B
    POP BC
    JR .L7ED0
.L7EEA:
    PUSH BC
    LD B,A
    AND $03
    CP $03
    LD A,B
    POP BC
    JR Z,.L7F13
    PUSH BC
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L7EE6
    PUSH HL
    LD A,B
    AND $03
    LD HL,$C1CA
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
    CP $FF
    JR NZ,.L7F10
    LD A,B
.L7F10:
    POP BC
    JR NZ,.L7F3B
.L7F13:
    PUSH AF
    CALL .L7F1D
    POP AF
    LD HL,$5104
    RST $10  ; -> bank81/fn4
    RET
.L7F1D:
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
.L7F3B:
    CALL .L7ED0
    LD A,$47
    LD (HL+),A
    LD A,$38
    LD (HL+),A
    LD A,$8D
    LD (HL+),A
    LD A,$2A
    LD (HL+),A
    LD (HL),$F0
    PUSH HL
    LD HL,$C1CA
    LD A,($DB50)
    AND $03
    CP $01
    JR Z,.L7F67
    CP $02
    JR Z,.L7F71
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F8D
    INC HL
    CP (HL)
    JR Z,.L7F8D
    JR .L7F9C
.L7F67:
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F92
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F8D
    JR .L7F9C
.L7F71:
    LD D,$00
    INC HL
    INC HL
    LD A,(HL-)
    DEC HL
    CP (HL)
    JR NZ,.L7F7B
    INC D
.L7F7B:
    INC HL
    CP (HL)
    JR NZ,.L7F80
    INC D
.L7F80:
    LD A,D
    OR A
    JR Z,.L7F9C
    CP $01
    JR Z,.L7F92
    POP HL
    LD A,$0C
    JR .L7F95
.L7F8D:
    POP HL
    LD A,$0A
    JR .L7F95
.L7F92:
    POP HL
    LD A,$0B
.L7F95:
    LD ($DB4D),A
    LD (HL+),A
    LD (HL),$F0
    RET
.L7F9C:
    POP HL
    XOR A
    LD ($DB4D),A
    RET


; ============================================================================
; ANALYSIS NOTE — NORMAL-ATTACK damage: ATTACK vs DEFENSE  (tiered curve)
; ============================================================================
; The physical-attack strength is a TIERED function of the attacker's
; ATTACK relative to the target's DEFENSE. It is computed into the
; accumulator $DD26 (see also the fuller version at bank88 $67BA).
;
; ROM0 stat accessors used (see rom0_vblank_callees.asm "GetBattleStat"):
;   $339B GetAttack  → HL = attacker ATTACK  (working $DBE3, record +$58)
;   $33A2 GetDefense → HL = defender DEFENSE (working $DBF3, record +$5A)
;   $3314 CmpHL_BC   → 16-bit compare HL vs BC
;   $3374 SlotAvail  → is monster slot A present?
; $5722 / bank88 $6918 = saturating byte add:  (HL) += B, clamp at $FF.
;
; THE FORMULA (confirmed; bank88 $67BA is the clearest copy):
;   1. $DD26 = $14 (20)                    ; base strength
;   2. build a threshold from the target's DEFENSE ($68A5 reads $DBF3)
;      into $DB56/$DB57.
;   3. repeatedly: compare attacker ATTACK (GetAttack) vs the threshold;
;      if ATTACK >= threshold → $DD26 += $0A (10, saturating at $FF), then
;      grow the threshold (×1, ×1.5, ×2, ×2.5 … via ADD HL,BC with BC and
;      BC>>1) and test again. Stop when ATTACK < threshold.
;   ⇒ $DD26 = 20 + 10 × (number of DEFENSE-multiples the ATTACK clears),
;             capped at 255.
;   So the more your ATTACK exceeds the enemy's DEFENSE, the higher the
;   base hit; a weak attacker vs a tough defender stays near 20.
;
; This $DD26 strength then feeds the on-screen damage (consumed at
; bank87 $485A / $4ABB) and ultimately the HP-subtract in bank80 ($4E82),
; where the working value in $DB56/$DB57 is taken from the target's HP.
; ($DB56/$DB57 is a general 16-bit scratch pair, reused all over the
;  battle code — here it holds the DEFENSE threshold during the loop.)
;
; Bank87 $5F23 is a single-tier variant of the same idea (one +$0A bump,
; then it reduces $DB56/$DB57 to the MINIMUM live-defender DEFENSE — i.e.
; it targets/uses the weakest defense on the side).
;
; ANSWER to "does a normal attack use the monster's attack value?": YES.
; The attack stat is read (GetAttack) and compared against DEFENSE-derived
; thresholds to build the hit strength ($DD26). Remaining unknown: the
; final RNG/variance applied to $DD26 before HP loss (if any).
; ============================================================================
