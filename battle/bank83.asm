; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 83  (Battle menu screen implementations)
; ============================================================================
;
; File offset $14C000-$14FFFF  (16 KB, mapped at $4000-$7FFF)
;
; Companion to bank82. Each function here is one menu SCREEN, itself a small
; state machine dispatching on wBattleMenuSub ($D9EE) via RST $00. bank82's
; phase dispatcher calls into these via RST $10 (LD HL,$53xx).
;
; fn0  ($4025)  screen: 9 sub-states  (command list build/animate)
; fn5  ($4D35)  screen: 16 sub-states (largest — monster status / stat page)
; fn17 ($5A62)  screen: 4 sub-states
; (fn6/fn7/fn8 share $586F; fn8 is an alias entry)
;
; Uses the same wBattleMenu* WRAM block as bank82 ($D9ED/$D9EE/$DB88/$DB8A).
; Renders windows/text by calling ROM0 tile/window primitives and bank85/87/88.
; ============================================================================

SECTION "Bank83_ID", ROMX[$4000], BANK[83]
    DB $53

SECTION "Bank83_JumpTable", ROMX[$4001], BANK[83]
    DW BattleScreen_fn0                 ; fn0 @ $4025
    DW Bank83_fn1                       ; fn1 @ $4738
    DW Bank83_fn2                       ; fn2 @ $479D
    DW Bank83_fn3                       ; fn3 @ $48CB
    DW Bank83_fn4                       ; fn4 @ $4A99
    DW BattleScreen_StatusPage          ; fn5 @ $4D35
    DW Bank83_fn6                       ; fn6 @ $5809
    DW Bank83_fn8                       ; fn7 @ $586F
    DW Bank83_fn8                       ; fn8 @ $586F
    DW Bank83_fn9                       ; fn9 @ $5982
    DW Bank83_fn10                      ; fn10 @ $5B69
    DW Bank83_fn11                      ; fn11 @ $5C00
    DW Bank83_fn12                      ; fn12 @ $60F9
    DW Bank83_fn13                      ; fn13 @ $625B
    DW Bank83_fn14                      ; fn14 @ $65E3
    DW Bank83_fn15                      ; fn15 @ $672A
    DW Bank83_fn16                      ; fn16 @ $4CF7
    DW Bank83_fn17                      ; fn17 @ $5A62

SECTION "Bank83_Code", ROMX[$4025], BANK[83]
BattleScreen_fn0:
    LD A,($D9EE)
    RST $00
    DW .L403B                           ; state 0
    DW .L41ED                           ; state 1
    DW .L435B                           ; state 2
    DW .L4535                           ; state 3
    DW .L4599                           ; state 4
    DW .L45A2                           ; state 5
    DW .L460E                           ; state 6
    DW .L4A7F                           ; state 7
    DW .L4A8C                           ; state 8
.L403B:
    XOR A
    LD ($DD72),A
    LD A,($D9ED)
    CP $12
    JR NZ,.L405B
    LD ($DD72),A
    XOR A
    LD ($D9ED),A
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$02
.L405B:
    XOR A
    LD ($DD69),A
    LD ($D9EF),A
    LD ($D9F0),A
    LD ($DD6D),A
    LD ($DD6E),A
    LD ($DD62),A
    LD A,($C86C)
    OR A
    JR NZ,.L4079
    LD A,$00
    LD ($C1D5),A
.L4079:
    LD A,$01
    LD ($DA82),A
    LD A,$FF
    LD ($DB89),A
    LD A,($DD6C)
    OR A
    JR NZ,.L40AA
    LD A,($DB82)
    CP $09
    JP Z,.L419B
    LD HL,$DB79
    CALL .L4730
    CP $10
    JR NZ,.L40A1
    LD A,$09
    LD ($D9ED),A
    RET
.L40A1:
    LD ($DB88),A
    CALL $3374
    JP C,.L4196
.L40AA:
    LD A,($DB88)
    LD HL,$DD13
    CALL .L4730
    CP $02
    JP NZ,.L4196
    LD A,($DB88)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $C0
    JR Z,.L40CB
    LD A,$11
    JP .L4187
.L40CB:
    LD A,L
    SUB $05
    LD L,A
    LD ($DB61),A
    LD A,H
    SBC A,$00
    LD H,A
    LD ($DB62),A
    BIT 6,(HL)
    JR Z,.L40E2
    LD A,$13
    JP .L4187
.L40E2:
    BIT 7,(HL)
    JR Z,.L40EC
    CALL .L4638
    JP .L4187
.L40EC:
    INC HL
    INC HL
    INC HL
    LD A,(HL)
    OR A
    JR Z,.L4125
    BIT 2,A
    JR Z,.L40FC
    LD A,$16
    JP .L4187
.L40FC:
    BIT 0,A
    JR Z,.L4105
    LD A,$12
    JP .L4187
.L4105:
    BIT 1,A
    JR Z,.L410D
    LD A,$14
    JR .L4187
.L410D:
    BIT 3,A
    JR Z,.L4115
    LD A,$15
    JR .L4187
.L4115:
    BIT 4,A
    JR Z,.L411D
    LD A,$17
    JR .L4187
.L411D:
    BIT 5,A
    JR Z,.L4125
    LD A,$18
    JR .L4187
.L4125:
    CALL .L4980
    LD A,($DB61)
    LD L,A
    LD A,($DB62)
    LD H,A
    BIT 5,(HL)
    JR Z,.L4154
    LD A,($C899)
    CP $40
    JR NC,.L4154
    CALL Bank83_fn2
    LD A,($DB88)
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    OR (HL)
    RET NZ
    LD A,$05
    LD ($D9EE),A
    RET
.L4154:
    BIT 4,(HL)
    JR Z,.L417C
    CALL .L6C42
    LD A,$10
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$11
    LD ($D9ED),A
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$00
    RET
.L417C:
    CALL .L49B0
    JR C,.L41A7
    LD HL,$D9EE
    INC (HL)
    JR .L41D7
.L4187:
    LD ($DB4C),A
    LD HL,$5007
    RST $10  ; -> bank80/fn7
    CALL .L4686
    LD A,$07
    LD ($D9EE),A
.L4196:
    LD HL,$DB82
    INC (HL)
    RET
.L419B:
    XOR A
    LD ($D9ED),A
    LD ($D9EE),A
    LD HL,$D9EC
    INC (HL)
    RET
.L41A7:
    CALL .L4529
    JR NZ,.L41B2
    LD HL,$D9EE
    INC (HL)
    JR .L41D7
.L41B2:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$3A
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$00
    CALL .L42E6
    LD A,$01
    LD ($C1D5),A
.L41D7:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB8A),A
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    RET
.L41ED:
    LD HL,$D9EE
    INC (HL)
    LD A,($D9EF)
    OR A
    JR Z,.L4203
    CP $02
    JP Z,.L4322
    LD HL,$D9EE
    INC (HL)
    JP .L4322
.L4203:
    LD A,($DD72)
    OR A
    JP NZ,.L428E
    LD A,($C88B)
    OR A
    JP NZ,.L428E
    LD A,($DB88)
    LD HL,$DD0B
    CALL .L4730
    CP $02
    JR NZ,.L428E
    CALL .L494E
    JR Z,.L428E
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR A
    JR NZ,.L428E
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB8A),A
    LD A,($DB8A)
    CP $55
    JR Z,.L428E
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD A,($DCFD)
    BIT 3,A
    JR NZ,.L428E
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    JR NZ,.L428E
    LD BC,$0004
    ADD HL,BC
    BIT 2,(HL)
    JR NZ,.L428E
    INC HL
    BIT 4,(HL)
    JR NZ,.L428E
    LD A,($DB82)
    OR A
    JR Z,.L428E
    XOR A
    LD ($D9EE),A
    LD A,$18
    LD ($D9ED),A
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$01
    RET
.L428E:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    CALL .L4730
    LD ($DB8A),A
    INC HL
    LD A,(HL)
    LD ($DB89),A
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD A,($DB8A)
    CP $14
    JR Z,.L42E6
    CP $32
    RET Z
    CP $96
    RET Z
    CP $95
    RET Z
    CP $AD
    RET Z
    LD A,($DB89)
    CALL $3374
    JR C,.L42FF
    LD A,($DB88)
    LD HL,$DD0B
    CALL .L4730
    OR A
    RET Z
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    RET NZ
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $03
    RET Z
.L42E6:
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF
    XOR A
    LD ($D9EE),A
    LD A,$19
    LD ($D9ED),A
    RET
.L42FF:
    LD A,($DB8A)
    CP $51
    JR Z,.L431E
    CP $52
    JR Z,.L431E
    CP $53
    JR Z,.L431E
    LD A,($DCFC)
    AND $01
    JR Z,.L4335
    CALL .L4529
    OR A
    RET Z
    CALL .L494E
    RET Z
.L431E:
    LD HL,$5808
    RST $10  ; -> bank88/fn8
.L4322:
    XOR A
    LD ($D9EF),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    JR .L4356
.L4335:
    LD A,($DB89)
    AND $04
    LD C,A
    LD B,$03
.L433D:
    LD A,C
    CALL $3374
    JR NC,.L4348
    INC C
    DEC B
    JR NZ,.L433D
    RET
.L4348:
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),C
.L4356:
    LD A,(HL)
    LD ($DB89),A
    RET
.L435B:
    LD HL,$D9EE
    INC (HL)
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD A,($DB8A)
    LD ($DB4C),A
    XOR A
    LD ($DB4D),A
    LD A,$04
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    LD C,A
    OR A
    JP Z,.L43BE
    LD B,$00
    LD A,($DB88)
    CALL $33BE
    CALL $3314
    JR Z,.L43BE
    LD A,L
    SUB C
    LD A,H
    SBC A,B
    JR NC,.L43BE
    CALL .L448A
    JR C,.L43BE
    CALL .L4529
    CALL Z,.L4457
    LD A,($DCFD)
    BIT 6,A
    JR Z,.L43A8
    LD A,$F7
    JP .L4432
.L43A8:
    BIT 5,A
    JR Z,.L43B1
    LD A,$F9
    JP .L4432
.L43B1:
    BIT 4,A
    JR Z,.L43BA
    LD A,$F8
    JP .L4432
.L43BA:
    CALL .L44B0
    RET
.L43BE:
    LD A,($DCFD)
    BIT 6,A
    JR Z,.L43FC
    LD A,($DB88)
    RRCA
    RRCA
    AND $01
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 3,(HL)
    JR Z,.L43E6
    CALL .L4529
    CALL Z,.L4457
    CALL .L469C
    LD A,$1F
    JR .L442D
.L43E6:
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 0,(HL)
    RET Z
    CALL .L4529
    CALL Z,.L4457
    LD A,$1E
    JR .L442D
.L43FC:
    BIT 5,A
    JR Z,.L4416
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 6,(HL)
    RET Z
    CALL .L4529
    CALL Z,.L4457
    LD A,$21
    JR .L442D
.L4416:
    BIT 4,A
    RET Z
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 7,(HL)
    RET Z
    CALL .L4529
    CALL Z,.L4457
    LD A,$20
.L442D:
    PUSH AF
    CALL .L4551
    POP AF
.L4432:
    LD ($DB4C),A
    LD HL,$5007
    RST $10  ; -> bank80/fn7
.L4439:
    LD A,($DD6C)
    OR A
    JR NZ,.L4448
    LD HL,$DB82
    INC (HL)
    XOR A
    LD ($D9EE),A
    RET
.L4448:
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    LD A,$20
    LD ($DD6C),A
    RET
.L4457:
    LD A,($DD6C)
    OR A
    RET NZ
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    RET NZ
    LD A,($DD72)
    OR A
    RET NZ
    CALL .L494E
    RET Z
    LD A,$16
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$01
    POP AF
    RET
.L448A:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    BIT 2,(HL)
    JR NZ,.L449E
    INC HL
    BIT 4,(HL)
    JR NZ,.L44A7
.L449C:
    XOR A
    RET
.L449E:
    LD A,($DB8A)
    CP $42
    JR NZ,.L449C
    JR .L44AE
.L44A7:
    LD A,($DB8A)
    CP $95
    JR NZ,.L449C
.L44AE:
    SCF
    RET
.L44B0:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L6B52
    LD HL,$C190
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L6B52
    LD A,($DB8A)
    CP $42
    JR Z,.L4500
    CP $52
    JR Z,.L4504
    CP $53
    JR Z,.L4504
    CP $56
    JR Z,.L4508
    CP $6F
    JR Z,.L450C
    CP $8F
    JR Z,.L4510
    CP $92
    JR Z,.L4514
    CP $95
    JR Z,.L4518
    LD A,$1D
    JP .L4432
.L4500:
    LD A,$0C
    JR .L451A
.L4504:
    LD A,$0D
    JR .L451A
.L4508:
    LD A,$0E
    JR .L451A
.L450C:
    LD A,$0F
    JR .L451A
.L4510:
    LD A,$10
    JR .L451A
.L4514:
    LD A,$11
    JR .L451A
.L4518:
    LD A,$12
.L451A:
    LD ($C823),A
    LD A,$01
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    JP .L4439
.L4529:
    LD A,($DB88)
    LD HL,$DD0B
    CALL .L4730
    CP $02
    RET
.L4535:
    CALL .L4529
    JR NZ,.L4549
    CALL .L49B0
    JR NC,.L4549
    LD A,($C1D5)
    OR A
    JR NZ,.L4549
    CALL .L41B2
    RET
.L4549:
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
.L4551:
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 4,(HL)
    RET NZ
    LD A,($DB8A)
    LD ($DB4C),A
    CALL .L46DF
    RET C
    XOR A
    LD ($DB4D),A
    LD A,$04
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    LD C,A
    LD A,($DB88)
    LD HL,$DBC3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,$00
    LD (HL),A
    LD A,($DB8A)
    CP $32
    RET NZ
    XOR A
    LD (HL-),A
    LD (HL),A
    RET
.L4599:
    XOR A
    LD ($D9EE),A
    LD HL,$DB82
    INC (HL)
    RET
.L45A2:
    LD A,($DB88)
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    OR (HL)
    JR Z,.L45B9
    LD A,$01
    LD ($D9EE),A
    RET
.L45B9:
    CALL .L6C42
    LD A,($DB88)
    LD B,A
    AND $03
    CP $03
    JR NZ,.L45E6
    LD A,B
    RRCA
    RRCA
    AND $01
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    RES 2,(HL)
    LD A,B
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF
    LD A,$E6
    JR .L45FD
.L45E6:
    LD A,B
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$01
    CALL .L67A1
    JR C,.L45FB
    LD A,$E7
    JR .L45FD
.L45FB:
    LD A,$E3
.L45FD:
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$06
    LD ($D9EE),A
    RET
.L460E:
    LD HL,$5202
    RST $10  ; -> bank82/fn2
    XOR A
    LD ($D9EE),A
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD HL,$5201
    RST $10  ; -> bank82/fn1
    LD A,($DD6B)
    CP $FF
    RET Z
    XOR A
    LD HL,$D9ED
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD ($DB4E),A
    LD A,$0A
    LD ($D9EC),A
    RET
.L4638:
    LD A,(HL)
    AND $0C
    JR Z,.L4651
    CP $04
    JR Z,.L464D
    CP $08
    JR Z,.L4649
    LD B,$60
    JR .L4653
.L4649:
    LD B,$A0
    JR .L4653
.L464D:
    LD B,$E0
    JR .L4653
.L4651:
    LD B,$FF
.L4653:
    LD A,($C899)
    CP B
    JR Z,.L4675
    JR C,.L4675
    LD A,(HL)
    AND $F3
    LD B,A
    LD A,(HL)
    AND $0C
    DEC A
    PUSH BC
    PUSH AF
    POP BC
    BIT 5,C
    POP BC
    JR NZ,.L466F
    AND $0C
    JR .L4670
.L466F:
    XOR A
.L4670:
    OR B
    LD (HL),A
    LD A,$0F
    RET
.L4675:
    LD A,(HL)
    AND $73
    LD (HL),A
    LD A,($DB88)
    LD ($DB89),A
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD A,$DB
    RET
.L4686:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    LD A,($DB88)
    LD HL,$DB05
    CALL $333B
    LD A,(HL)
    AND $C0
    LD (HL),A
    POP HL
    POP DE
    POP BC
    POP AF
    RET
.L469C:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    LD A,($DB8A)
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,$04
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    LD C,A
    LD B,$00
    LD A,($DB88)
    LD HL,$DBC3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR NC,.L46D4
    LD HL,$0000
.L46D4:
    POP BC
    LD A,L
    LD (BC),A
    INC BC
    LD A,H
    LD (BC),A
    POP HL
    POP DE
    POP BC
    POP AF
    RET
.L46DF:
    CP $32
    JR Z,.L471E
    CP $42
    JR Z,.L4710
    CP $66
    JR Z,.L471E
    CP $95
    JR Z,.L4720
    CP $96
    JR Z,.L471E
    LD A,($DCFD)
    BIT 6,A
    JR Z,.L471E
    LD A,($DB88)
    RRCA
    RRCA
    AND $01
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 3,(HL)
    JR NZ,.L472E
    JR .L471E
.L4710:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    JR NZ,.L472E
.L471E:
    XOR A
    RET
.L4720:
    LD A,($DB88)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $30
    JR Z,.L471E
.L472E:
    SCF
    RET
.L4730:
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    RET
Bank83_fn1:
    CALL .L4980
    LD A,($C899)
    BIT 1,A
    JR NZ,.L4768
    BIT 0,A
    JR NZ,.L476C
    LD A,($C86C)
    OR A
    JR NZ,.L4770
    LD A,($DB88)
    CP $04
    JR C,.L4770
    LD A,($C89A)
    AND $07
    ADD A,$9A
    CP $A1
    JR NZ,.L477F
    LD B,A
    LD A,($DB73)
    OR A
    LD A,B
    JR Z,.L477F
    JR Bank83_fn1
.L4768:
    LD A,$99
    JR .L477F
.L476C:
    LD A,$9A
    JR .L477F
.L4770:
    LD A,($C89A)
    CP $55
    JR C,.L477D
    AND $01
    ADD A,$9B
    JR .L477F
.L477D:
    LD A,$9E
.L477F:
    LD ($DB8A),A
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB8A)
    LD (HL),A
    LD A,$10
    LD ($D9ED),A
    LD HL,$5808
    RST $10  ; -> bank88/fn8
    RET
Bank83_fn2:
    LD A,($DB89)
    PUSH AF
    LD A,($DB88)
    LD ($DB89),A
    CALL .L6C2D
    POP AF
    LD ($DB89),A
    LD A,($C89A)
    CP $40
    JR C,.L47D4
    CP $80
    JR C,.L47E4
    CP $C0
    JR C,.L4806
    LD A,$11
    LD ($D9ED),A
    LD A,($DB88)
    LD HL,$DB02
    CALL $333B
    SET 4,(HL)
    LD A,$19
    LD ($C823),A
    JR .L4829
.L47D4:
    LD A,$04
    LD ($D9EE),A
    XOR A
    LD ($D9ED),A
    LD A,$1A
    LD ($C823),A
    JR .L4829
.L47E4:
    LD A,$05
    LD ($D9EE),A
    LD A,($DB88)
    LD DE,$DBA3
    CALL .L4832
    RET Z
    LD A,($DB88)
    CALL .L4839
    JR NC,.L47FF
    XOR A
    LD (DE),A
    DEC DE
    LD (DE),A
.L47FF:
    LD A,$1B
    LD ($C823),A
    JR .L4829
.L4806:
    LD A,$05
    LD ($D9EE),A
    CALL .L486A
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,L
    OR H
    RET Z
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L4B4A
    LD A,$1C
    LD ($C823),A
.L4829:
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4832:
    PUSH HL
    LD H,D
    LD L,E
    LD A,(HL+)
    OR (HL)
    POP HL
    RET
.L4839:
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    PUSH DE
    LD A,$10
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
    LD A,$06
    CALL $21DC
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    PUSH HL
    CALL .L4B4A
    POP HL
    POP DE
    LD A,(DE)
    SUB L
    LD (DE),A
    INC DE
    LD A,(DE)
    SBC A,$00
    LD (DE),A
    RET
.L486A:
    LD A,($DB88)
    CALL $33B0
    OR H
    JR Z,.L48C2
    LD A,$06
    CALL $21DC
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    LD A,($DB88)
    LD HL,$DBC3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,L
    LD ($DB58),A
    LD A,H
    LD ($DB59),A
    LD A,(HL+)
    OR (HL)
    JR NZ,.L489D
    LD H,(HL)
    LD L,A
    JR .L48C2
.L489D:
    LD A,(HL-)
    LD C,(HL)
    LD B,A
    LD A,C
    LD ($DB5A),A
    LD A,B
    LD ($DB5B),A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,B
    LD (HL),A
    RET NC
    XOR A
    LD (HL-),A
    LD (HL),A
    LD A,($DB5A)
    LD L,A
    LD A,($DB5B)
    LD H,A
.L48C2:
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    RET
Bank83_fn3:
    CALL .L4980
    LD A,($C899)
    AND $0F
    OR A
    JR Z,.L48DE
    CP $01
    JR Z,.L48E2
    ADD A,$A0
    JR .L48E4
.L48DE:
    LD A,$A9
    JR .L48E4
.L48E2:
    LD A,$A3
.L48E4:
    LD ($DB8A),A
    LD ($DB4C),A
    XOR A
    LD ($DB4D),A
    LD A,$09
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB73)
    OR A
    JR Z,.L4904
    LD A,($DB4C)
    BIT 1,A
    JR Z,Bank83_fn3
.L4904:
    LD A,($C86C)
    OR A
    JR NZ,.L491C
    LD A,($DB88)
    CP $03
    JR C,.L491C
    LD A,($DB8A)
    CP $A2
    JR Z,Bank83_fn3
    CP $A4
    JR Z,Bank83_fn3
.L491C:
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB8A)
    LD (HL),A
    LD A,($DD69)
    PUSH AF
    XOR A
    LD ($DD69),A
    LD HL,$5808
    RST $10  ; -> bank88/fn8
    POP AF
    LD ($DD69),A
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($D9ED),A
    XOR A
    LD ($D9EF),A
    XOR A
    LD ($DD69),A
    RET
.L494E:
    LD A,($DD72)
    OR A
    RET NZ
    LD A,($DB88)
    LD HL,$DD03
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $03
    RET NZ
    LD A,($C86C)
    OR A
    JR NZ,.L496E
    LD A,($C8DA)
    JR .L497D
.L496E:
    LD A,($DB88)
    CP $04
    JR NC,.L497A
    LD A,($C1D5)
    JR .L497D
.L497A:
    LD A,($C1D6)
.L497D:
    CP $81
    RET
.L4980:
    LD A,($C86C)
    OR A
    JR NZ,.L498A
    CALL $16A3
    RET
.L498A:
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
.L49B0:
    LD A,($C86C)
    OR A
    JR NZ,.L49FB
    LD A,($DB88)
    CP $04
    JR C,.L49FB
    CP $07
    JR Z,.L49FB
    SUB $04
    LD HL,$DA03
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
    ADD A,$6C
    LD L,A
    LD A,H
    ADC A,$69
    LD H,A
    LD A,(HL)
    OR A
    JR Z,.L49FB
    LD A,($DB82)
    OR A
    JR Z,.L49FB
    LD B,A
    LD HL,$DB79
.L49E6:
    LD A,(HL+)
    CP $FF
    JR Z,.L49FB
    CP $04
    JR NC,.L49F4
    DEC B
    JR NZ,.L49E6
    JR .L49FB
.L49F4:
    CALL .L49FE
    JR NZ,.L49E6
    SCF
    RET
.L49FB:
    SCF
    CCF
    RET
.L49FE:
    PUSH HL
    PUSH BC
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD C,A
    LD A,($DB88)
    LD HL,$DCEC
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP C
    JR NZ,.L4A20
    CALL .L4A23
.L4A20:
    POP BC
    POP HL
    RET
.L4A23:
    LD HL,$4A31
.L4A26:
    LD A,(HL+)
    CP $FF
    JR Z,.L4A2F
    CP C
    RET Z
    JR .L4A26
.L4A2F:
    OR A
    RET
    DB $03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12
    DB $13,$14,$16,$17,$18,$1D,$1F,$21,$23,$2E,$2F,$30,$31,$32,$3B,$3C
    DB $3E,$3F,$40,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$51,$52,$53,$57,$59
    DB $5A,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$66,$69,$6A,$6B
    DB $6D,$6E,$71,$78,$7C,$7D,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$FF
.L4A7F:
    LD A,($C8EE)
    ADD A,$03
    LD ($DB4C),A
    LD HL,$D9EE
    INC (HL)
    RET
.L4A8C:
    LD A,($DB4C)
    DEC A
    LD ($DB4C),A
    RET NZ
    XOR A
    LD ($D9EE),A
    RET
Bank83_fn4:
    LD A,($D9EE)
    RST $00
    DW .L4AA5                           ; state 0
    DW .L4B1F                           ; state 1
    DW .L4B23                           ; state 2
    DW .L4B27                           ; state 3
.L4AA5:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR NC,.L4AB8
.L4AB1:
    LD HL,$D9EE
    INC (HL)
    JP .L4B23
.L4AB8:
    LD A,($DB89)
    CP $04
    JR C,.L4AC4
    LD HL,$DB01
    JR .L4AC7
.L4AC4:
    LD HL,$DB00
.L4AC7:
    BIT 4,(HL)
    JR NZ,.L4AB1
    LD A,($DB8A)
    CP $89
    JR NZ,.L4AEF
    SET 4,(HL)
    LD A,$4A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB88)
    AND $03
    SWAP A
    OR (HL)
    LD (HL),A
    LD A,($DB89)
    AND $04
    LD C,A
    LD B,$03
    JR .L4AF5
.L4AEF:
    LD A,($DB89)
    LD C,A
    LD B,$01
.L4AF5:
    LD A,C
    CALL $3374
    JR C,.L4B1A
    LD A,C
    LD HL,$DB88
    CP (HL)
    JR Z,.L4B1A
    LD HL,$DB08
    CALL $333B
    BIT 4,(HL)
    JR NZ,.L4B1A
    SET 4,(HL)
    INC HL
    LD A,($DB88)
    AND $0F
    SWAP A
    LD D,A
    LD A,(HL)
    OR D
    LD (HL),A
.L4B1A:
    INC C
    DEC B
    JR NZ,.L4AF5
    RET
.L4B1F:
    LD HL,$D9EE
    INC (HL)
.L4B23:
    LD HL,$D9EE
    INC (HL)
.L4B27:
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($DD72),A
    XOR A
    LD ($DD73),A
    RET
.L4B40:
    CALL .L6C2D
    CALL .L4B4A
    CALL .L4B59
    RET
.L4B4A:
    LD HL,$C190
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    CALL $0E68
    RET
.L4B59:
    LD HL,$C1A0
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L6B52
    RET
.L4B6E:
    LD A,($DB89)
    AND $04
    LD B,A
    LD A,C
    AND $04
    CP B
    JR NZ,.L4B7D
    XOR $04
    LD C,A
.L4B7D:
    LD A,C
    AND $04
    XOR $04
    LD E,A
    CALL .L4CDF
    JP NC,.L4C8D
    INC E
    LD A,E
    CALL .L4CDF
    JP NC,.L4C8D
    INC E
    JP .L4C8D
.L4B95:
    LD A,C
    AND $04
    XOR $04
    LD D,A
    LD A,($C89A)
    AND $02
    LD C,A
    OR D
    LD E,A
    CALL .L4CDF
    JP NC,.L4C8D
    LD A,E
    XOR $02
    LD E,A
    CALL .L4CDF
    JP NC,.L4C8D
    INC D
    LD E,D
    JP .L4C8D
.L4BB8:
    LD A,($C89A)
    AND $01
    INC A
    LD D,A
    LD A,C
    AND $04
    XOR $04
    LD C,A
    ADD A,D
    LD E,A
    CALL .L4CDF
    JP NC,.L4C8D
    LD A,D
    XOR $03
    LD D,A
    LD A,C
    SUB D
    LD E,A
    CALL .L4CDF
    JP NC,.L4C8D
    LD E,C
    JP .L4C8D
.L4BDE:
    XOR A
    LD ($DB61),A
    LD A,($DB89)
    CALL $3345
    RET C
    LD A,($DB89)
    LD C,A
    CALL .L4980
    LD A,($C899)
    CP $33
    JR C,.L4C5F
    CP $66
    JP C,.L4B6E
    CP $99
    JR C,.L4B95
    CP $CC
    JR C,.L4BB8
    LD A,C
    AND $04
    LD B,A
    LD A,($C89A)
    AND $01
    LD D,A
    LD A,C
    AND $03
    CP $00
    JR Z,.L4C35
    CP $01
    JR Z,.L4C39
    INC D
    SUB D
.L4C1B:
    OR B
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
    LD A,D
    XOR $03
    CP $03
    JR NZ,.L4C2B
    LD A,$01
.L4C2B:
    OR B
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
    LD E,C
    JR .L4C7D
.L4C35:
    INC D
    LD A,D
    JR .L4C1B
.L4C39:
    LD A,D
    OR A
    JR Z,.L4C4F
    LD A,C
    INC A
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
    LD A,C
    DEC A
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
    JR .L4C7D
.L4C4F:
    LD A,C
    DEC A
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
    LD A,C
    INC A
    LD E,A
    CALL .L4CDF
    JR NC,.L4C8D
.L4C5F:
    LD A,($DB89)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 5,(HL)
    JP NZ,.L4B6E
    LD A,$7F
    LD ($C823),A
    LD A,($DB89)
    LD ($DB4C),A
    JR .L4CBB
.L4C7D:
    LD A,($C899)
    CP $55
    JP C,.L4B6E
    CP $AA
    JP C,.L4B95
    JP .L4BB8
.L4C8D:
    LD A,E
    CALL $3374
    JR C,.L4C5F
    LD A,($DB89)
    LD ($DB4C),A
    CP E
    JP Z,.L4BDE
    LD A,E
    LD ($DB89),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),E
    LD A,$7E
    LD ($C823),A
    JR .L4CBB
    DB $3E,$7F,$EA,$23,$C8
.L4CBB:
    LD HL,$C1A0
    LD A,($C823)
    PUSH AF
    LD A,($DB4C)
    CALL .L6B52
    POP AF
    LD ($C823),A
    LD A,($DD72)
    OR A
    RET NZ
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$01
    LD ($DB61),A
    RET
.L4CDF:
    CALL $3374
    JR C,.L4CF5
    LD A,E
    PUSH HL
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    POP HL
    JR NZ,.L4CF5
    SCF
    CCF
    RET
.L4CF5:
    SCF
    RET
Bank83_fn16:
    LD A,($C86C)
    OR A
    JR NZ,.L4D2A
    LD A,($DB89)
    CP $04
    JR C,.L4D2A
    LD A,($DB73)
    CP $01
    JR NZ,.L4D2A
    LD A,($DB8A)
    CP $12
    JR Z,.L4D30
    CP $13
    JR Z,.L4D30
    CP $14
    JR Z,.L4D30
    CP $3E
    JR Z,.L4D30
    CP $69
    JR Z,.L4D30
    CP $6B
    JR Z,.L4D30
    CP $71
    JR Z,.L4D30
.L4D2A:
    LD A,$01
    LD ($DB4C),A
    RET
.L4D30:
    XOR A
    LD ($DB4C),A
    RET
BattleScreen_StatusPage:
    LD A,($D9EE)
    RST $00
    DW .L4D59                           ; state 0
    DW .L4D8F                           ; state 1
    DW .L4DC7                           ; state 2
    DW .L4E36                           ; state 3
    DW .L4EAB                           ; state 4
    DW .L4EC7                           ; state 5
    DW .L4EF6                           ; state 6
    DW .L4F5E                           ; state 7
    DW .L516F                           ; state 8
    DW .L51F5                           ; state 9
    DW .L53B7                           ; state 10
    DW .L5443                           ; state 11
    DW .L5448                           ; state 12
    DW .L55BC                           ; state 13
    DW .L563A                           ; state 14
    DW .L5654                           ; state 15
.L4D59:
    LD HL,$D9EE
    INC (HL)
    LD HL,$DD69
    INC (HL)
.L4D61:
    XOR A
    LD ($DD6E),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB89),A
    CP $FF
    JR NZ,.L4D80
    LD HL,$5808
    RST $10  ; -> bank88/fn8
    JR .L4D61
.L4D80:
    LD A,($DD69)
    CP $01
    JR Z,.L4D8F
    LD A,$07
    LD ($D9EE),A
    JP .L4F5E
.L4D8F:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $54
    JR Z,.L4DC7
    PUSH AF
    CALL .L6C42
    POP AF
    BIT 6,A
    JR NZ,.L4DB9
    BIT 2,A
    JR NZ,.L4DB5
    LD A,$6B
    JR .L4DBB
.L4DB5:
    LD A,$69
    JR .L4DBB
.L4DB9:
    LD A,$6D
.L4DBB:
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4DC7:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD6C)
    OR A
    JR Z,.L4DD6
    CP $08
    JR Z,.L4DD6
    RET
.L4DD6:
    LD HL,$5806
    RST $10  ; -> bank88/fn6
    LD HL,$5007
    RST $10  ; -> bank80/fn7
    LD HL,$5500
    RST $10  ; -> bank85/fn0
    LD A,$18
    LD ($DA33),A
    LD A,($DB8A)
    CP $14
    JR Z,.L4E15
    CP $24
    JR Z,.L4E15
    CP $26
    JR Z,.L4E15
    CP $2A
    JR Z,.L4E15
    CP $89
    JR Z,.L4E15
    CP $80
    JR Z,.L4E15
    CP $8A
    JR Z,.L4E15
    CP $8B
    JR Z,.L4E15
    CP $8F
    JR Z,.L4E15
    CP $83
    JR Z,.L4E15
    CP $A5
    RET NZ
.L4E15:
    LD A,($DB89)
    CALL $3374
    RET NC
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    CP $03
    RET Z
    INC (HL)
    LD A,(HL)
    LD ($DB89),A
    JR .L4E15
.L4E36:
    LD A,($DA33)
    OR A
    JR Z,.L4E41
    DEC A
    LD ($DA33),A
    RET
.L4E41:
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD A,($DB8A)
    CP $42
    JR NZ,.L4E60
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    JR NZ,.L4E60
    LD A,$0B
    LD ($D9EE),A
    RET
.L4E60:
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB89),A
    LD ($DD73),A
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    JR Z,.L4EAB
    PUSH AF
    CALL .L6C42
    POP AF
    BIT 1,A
    JR Z,.L4E96
    LD A,$68
    JR .L4E9F
.L4E96:
    LD A,($DCFE)
    BIT 4,A
    JR Z,.L4EAB
    LD A,$67
.L4E9F:
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4EAB:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L4EC7
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD A,($DA80)
    CP $01
    RET Z
    LD HL,$D9EE
    INC (HL)
    JR .L4EF6
.L4EC7:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD68)
    CP $02
    JR NZ,.L4EF6
    LD A,($DB89)
    LD C,A
.L4ED6:
    AND $03
    CP $02
    JR Z,.L4EF0
    INC C
    LD A,C
    CALL $3374
    LD A,C
    JR C,.L4ED6
    LD ($DB89),A
    LD HL,$D9EE
    DEC (HL)
    LD HL,$D9EE
    DEC (HL)
    RET
.L4EF0:
    LD A,($DD73)
    LD ($DB89),A
.L4EF6:
    LD HL,$D9EE
    INC (HL)
    LD A,($DCFD)
    BIT 7,A
    JR Z,.L4F5E
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB89),A
    LD A,($DB89)
    CALL $3345
    JR C,.L4F5E
    LD A,($DB89)
    LD ($C1C8),A
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 5,(HL)
    JR Z,.L4F5E
    LD A,(HL)
    LD ($DD72),A
    CALL .L4BDE
    LD A,($C1C8)
    LD HL,$C180
    LD ($DB50),A
    CALL .L6B52
    LD A,($DB89)
    LD HL,$C190
    LD ($DB50),A
    CALL .L6B52
    LD A,$6C
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$D9EE
    INC (HL)
    RET
.L4F5E:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD6C)
    BIT 3,A
    JP NZ,.L5023
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    CALL .L4980
    LD A,($DB89)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    JR Z,.L4FA5
    LD A,($DCFF)
    BIT 5,A
    JR Z,.L4FA5
    LD A,$05
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    CALL .L6C2D
    LD A,$C1
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$6F
    CALL $1EFF
    RET
.L4FA5:
    LD A,($DCFD)
    BIT 4,A
    JP Z,.L5023
    LD A,($DB89)
    RRCA
    RRCA
    AND $01
    LD B,A
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 6,(HL)
    JP Z,.L5023
    LD A,($DD6C)
    OR A
    JP NZ,.L516F
    LD A,($DB8A)
    CP $8F
    JP Z,.L516F
    LD A,B
    LD HL,$DB4A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    RRCA
    RRCA
    AND $03
    LD C,A
    LD A,($DB89)
    AND $04
    OR C
    LD C,A
    CALL $3345
    JP C,.L516F
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD (HL),C
    LD B,A
    LD A,C
    SUB B
    LD B,A
    LD A,($DD69)
    ADD A,B
    LD ($DD69),A
    LD A,C
    LD ($DB89),A
    LD B,$02
    CALL .L5A1B
    CALL .L6C2D
    LD A,$81
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5023:
    LD A,($DCFE)
    BIT 1,A
    JR Z,.L509A
    LD A,($DD6E)
    OR A
    JR NZ,.L509A
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    BIT 4,(HL)
    JR Z,.L509A
    LD A,($DB89)
    LD HL,$DB09
    CALL $333B
    LD A,(HL)
    SWAP A
    AND $0F
    LD B,A
    CALL $3345
    JR C,.L5091
.L5051:
    LD A,B
    LD HL,$C180
    PUSH BC
    LD ($DB50),A
    CALL .L6B52
    LD A,($DB89)
    LD ($C1C8),A
    LD HL,$C190
    LD ($DB50),A
    CALL .L6B52
    POP BC
    LD A,B
    LD ($DB89),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),B
    LD A,$80
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$04
    LD ($DD6E),A
    RET
.L5091:
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
.L509A:
    LD A,($DD6C)
    OR A
    JP NZ,.L516F
    LD A,($DCFD)
    BIT 7,A
    JR Z,.L50E1
    LD A,($DB89)
    CALL $3345
    JP C,.L516F
    PUSH HL
    LD A,($DB89)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 5,(HL)
    POP HL
    JR NZ,.L50C7
    BIT 5,(HL)
    JR Z,.L50E1
.L50C7:
    XOR A
    LD ($DD72),A
    LD A,($DB89)
    LD ($C1C8),A
    CALL .L4BDE
    LD A,($DB61)
    OR A
    JP Z,.L516F
    LD A,$02
    LD ($DD6E),A
    RET
.L50E1:
    LD A,($DCFD)
    BIT 4,A
    JP Z,.L5117
    LD A,($DD6C)
    OR A
    JP NZ,.L516F
    CALL .L57EE
    JR Z,.L5117
    RES 6,(HL)
    CALL .L6C2D
    LD A,$01
    CALL .L5985
    LD A,$02
    LD ($DD6D),A
    LD A,$02
    LD ($DD6E),A
    LD A,$7D
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5117:
    LD A,($DCFE)
    BIT 0,A
    JP Z,.L516F
    LD A,($DD6C)
    OR A
    JP NZ,.L516F
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    LD A,(HL)
    AND $22
    JP Z,.L516F
    LD A,$00
    LD ($DD6D),A
    BIT 1,(HL)
    JR NZ,.L5145
    RES 5,(HL)
    LD A,$07
    LD ($DD6D),A
.L5145:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    JR Z,.L5152
    LD A,($DB88)
.L5152:
    RRCA
    RRCA
    AND $01
    ADD A,$7B
    LD A,A
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$04
    CALL .L5985
    LD A,$02
    LD ($DD6E),A
    RET
.L516F:
    LD A,($DD6E)
    OR A
    JR Z,.L5189
    CP $01
    JR Z,.L5183
    CP $02
    JR NZ,.L5189
    CP $04
    JR Z,.L5183
    JR .L51C5
.L5183:
    LD HL,$D9EE
    INC (HL)
    JR .L51F5
.L5189:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3345
    JR C,.L51F5
    LD A,($DCFE)
    BIT 7,A
    JR Z,.L51F5
    LD A,($DB89)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 7,(HL)
    JR Z,.L51F5
    CALL .L6C2D
    LD A,$6E
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    CALL .L5387
    LD A,$6F
    CALL $1EFF
    RET
.L51C5:
    LD A,($DCFE)
    BIT 1,A
    JR Z,.L5189
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    BIT 4,(HL)
    JR Z,.L5189
    LD A,($DB89)
    LD HL,$DB09
    CALL $333B
    LD A,(HL)
    SWAP A
    AND $0F
    LD B,A
    CALL $3345
    JR C,.L5189
    CALL .L5051
    LD HL,$DD6E
    INC (HL)
    RET
.L51F5:
    LD A,($DB8A)
    CP $30
    JR Z,.L522E
    CP $31
    JR Z,.L522E
    CP $32
    JR Z,.L522E
    CP $95
    JR Z,.L522E
    CP $96
    JR Z,.L522E
    CP $AD
    JR Z,.L522E
    CP $8F
    JR Z,.L522E
    CP $89
    JR Z,.L522E
    CP $8B
    JR Z,.L522E
    LD A,($DB89)
    CALL $3374
    JR NC,.L522E
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    RET
.L522E:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $C0
    JR Z,.L5294
    LD A,($DCFE)
    BIT 2,A
    JR Z,.L5294
    CALL .L5391
    JR Z,.L5294
    LD A,($DB8A)
    CP $52
    JR Z,.L5262
    CP $53
    JR Z,.L5262
    CP $14
    JR Z,.L5293
.L525B:
    CALL .L5387
    LD A,$BA
    JR .L527E
.L5262:
    LD A,($DD69)
    CP $02
    JR NC,.L525B
    LD A,$00
    LD ($C1C9),A
    LD A,$10
    LD ($DD69),A
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    LD A,$C2
.L527E:
    PUSH AF
    CALL .L6C2D
    POP AF
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$6F
    CALL $1EFF
.L5293:
    RET
.L5294:
    LD A,($DCFD)
    BIT 7,A
    JR Z,.L52B0
    LD A,($DB89)
    LD HL,$DB06
    CALL $333B
    BIT 2,(HL)
    JR Z,.L52B0
    CALL .L6C2D
    LD A,$C1
    JP .L5377
.L52B0:
    CALL .L4980
    LD A,($DCFD)
    BIT 1,A
    JR Z,.L52EB
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 1,(HL)
    JR Z,.L52D2
    LD A,($C899)
    CP $A0
    JR NC,.L52D2
    CALL .L535D
    RET
.L52D2:
    LD A,($DB88)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $03
    JR Z,.L52EB
    LD A,($C89A)
    CP $60
    JR NC,.L52EB
    CALL .L535D
    RET
.L52EB:
    LD A,($DCFE)
    BIT 7,A
    JR Z,.L5342
    LD A,($DB89)
    CALL $3345
    JR C,.L5342
    CALL .L53A4
    JR Z,.L5342
    LD A,($DB89)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $0C
    JR Z,.L5315
    LD A,($C899)
    AND $01
    JP Z,.L533E
.L5315:
    LD A,($DB89)
    LD HL,$DC03
    CALL .L58B5
    LD BC,$01C0
    CALL $3314
    JR NC,.L5332
    LD BC,$0020
    CALL $3314
    JR NC,.L5336
    LD B,$02
    JR .L5338
.L5332:
    LD B,$2B
    JR .L5338
.L5336:
    LD B,$08
.L5338:
    LD A,($C899)
    CP B
    JR NC,.L5342
.L533E:
    CALL .L5344
    RET
.L5342:
    JR .L53B7
.L5344:
    CALL .L6C2D
    LD A,$78
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    CALL .L5387
    LD A,$6F
    CALL $1EFF
    RET
.L535D:
    CALL .L6C2D
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    JR Z,.L536D
    LD A,($DB88)
.L536D:
    CP $04
    JR C,.L5375
    LD A,$B6
    JR .L5377
.L5375:
    LD A,$B7
.L5377:
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$6F
    CALL $1EFF
.L5387:
    LD A,$05
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    RET
.L5391:
    LD A,($DB8A)
    CP $42
    RET NZ
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    RET
.L53A4:
    LD A,($DB8A)
    CP $41
    RET NZ
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $03
    RET
.L53B7:
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD HL,$D9EE
    INC (HL)
    LD A,($DCFE)
    AND $70
    RET Z
    BIT 5,A
    JR Z,.L53D8
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 2,(HL)
    RET NZ
    LD A,($DCFE)
.L53D8:
    BIT 4,A
    JR Z,.L5437
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 0,(HL)
    JR NZ,.L5401
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 3,(HL)
    JR NZ,.L5401
    CALL .L4980
    CALL .L5A26
    JR NC,.L5437
.L5401:
    LD A,($DB88)
    LD HL,$DB04
    CALL $333B
    SET 7,(HL)
    LD A,($DB88)
    RRCA
    RRCA
    AND $01
    LD D,A
    LD A,($C863)
    BIT 1,A
    LD A,D
    JR Z,.L541E
    XOR $01
.L541E:
    ADD A,$79
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$6E
    CALL $1EFF
    LD HL,$D9EE
    INC (HL)
    JR .L5448
    DB $C9
.L5437:
    LD A,($DB88)
    LD HL,$DB04
    CALL $333B
    RES 7,(HL)
    RET
.L5443:
    LD HL,$D9EE
    INC (HL)
    RET
.L5448:
    LD A,($DB88)
    LD HL,$DB04
    CALL $333B
    BIT 7,(HL)
    JR Z,.L545F
    LD A,($DD80)
    LD HL,$DD9A
    AND (HL)
    CP $FF
    RET NZ
.L545F:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 2,(HL)
    JR Z,.L548E
    LD A,($DCFE)
    BIT 5,A
    JR Z,.L548E
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    SLA L
    RL H
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JP .L5510
.L548E:
    INC HL
    BIT 7,(HL)
    JR Z,.L54C5
    RES 7,(HL)
    LD HL,$B682
    LD A,$A8
    LD ($DD6F),A
    LD A,L
    LD ($DD70),A
    LD A,H
    LD ($DD71),A
    LD A,($DB88)
    CALL $339B
    LD A,($DB8A)
    CP $51
    CALL Z,.L54C0
    CALL .L58C0
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L5510
.L54C0:
    SRL H
    RR L
    RET
.L54C5:
    INC HL
    INC HL
    BIT 0,(HL)
    JR Z,.L54E7
    LD A,($DCFE)
    BIT 6,A
    JR Z,.L54E7
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L58FE
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L5510
.L54E7:
    BIT 4,(HL)
    JR Z,.L5510
    LD A,($DCFD)
    BIT 4,A
    JR Z,.L5510
    LD A,($DB8A)
    CP $5C
    JR C,.L5510
    CP $64
    JR NC,.L5510
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L58FE
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
.L5510:
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 6,(HL)
    JR Z,.L5539
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD B,H
    LD C,L
    SRL H
    RR L
    ADD HL,BC
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L5539
.L5539:
    LD A,($DB89)
    LD HL,$DB09
    CALL $333B
    LD A,(HL)
    AND $07
    JR Z,.L5591
    AND $03
    LD C,A
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    JR NZ,.L5562
    LD A,($DCFD)
    BIT 7,A
    JP Z,.L55BC
.L555C:
    SRL H
    RR L
    JR .L5572
.L5562:
    LD A,($DCFD)
    BIT 0,A
    JR Z,.L55BC
    BIT 0,C
    JR NZ,.L555C
    LD A,$0A
    CALL $21DC
.L5572:
    LD A,($DB89)
    LD DE,$DB42
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    BIT 1,A
    JR Z,.L5587
    SRL H
    RR L
.L5587:
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    JR .L55BC
.L5591:
    DEC HL
    BIT 2,(HL)
    JR Z,.L55BC
    LD A,($DCFD)
    BIT 7,A
    JR Z,.L55BC
    LD A,($DB8A)
    CP $3C
    JR Z,.L55BC
    CP $3E
    JR Z,.L55BC
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    SLA L
    RL H
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
.L55BC:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD6F)
    BIT 6,A
    JR Z,.L5601
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    LD A,($DD6F)
    BIT 7,A
    RET Z
    CALL .L4B40
    LD A,($DD70)
    LD L,A
    LD A,($DD71)
    LD H,A
    LD A,L
    LD ($C822),A
    LD A,H
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$5501
    RST $10  ; -> bank85/fn1
    LD A,$01
    LD ($C1C9),A
    LD A,($DB8A)
    CP $1B
    RET NZ
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    RET
.L5601:
    LD A,($DD6F)
    LD B,A
    BIT 5,A
    JR Z,.L561F
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,H
    OR L
    JR Z,.L5619
    SET 4,B
    JR .L561B
.L5619:
    RES 4,B
.L561B:
    LD A,B
    LD ($DD6F),A
.L561F:
    LD A,($DD6F)
    BIT 4,A
    JR Z,.L5639
    BIT 2,A
    JR NZ,.L5639
    LD HL,$5501
    RST $10  ; -> bank85/fn1
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD A,($DA80)
    CP $01
    JR Z,.L563A
.L5639:
    RET
.L563A:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD6F)
    BIT 2,A
    RET NZ
    BIT 4,A
    RET Z
    LD HL,$5502
    RST $10  ; -> bank85/fn2
    LD HL,$5F04
    RST $10  ; -> bank95/fn4
    LD A,$01
    LD ($C1C9),A
.L5654:
    LD A,($DB8A)
    CP $84
    JR C,.L5664
    CP $88
    JR NC,.L5664
    LD A,($DA82)
    OR A
    RET Z
.L5664:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD6F)
    BIT 4,A
    JR Z,.L5699
    CALL Bank83_fn6
    LD A,($DD70)
    LD ($C823),A
    LD A,($DD6F)
    BIT 3,A
    JR Z,.L5687
    CALL .L57DA
    JR NC,.L5687
    CALL .L5713
.L5687:
    XOR A
    LD ($C822),A
    LD A,($DD6F)
    BIT 0,A
    JR Z,.L56BC
    LD A,$01
    LD ($C822),A
    JR .L56C6
.L5699:
    LD HL,$5503
    RST $10  ; -> bank85/fn3
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    LD A,($DD71)
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD A,($DD6F)
    BIT 1,A
    JR Z,.L56BC
    LD A,$01
    LD ($C822),A
.L56BC:
    LD A,($DD6F)
    BIT 3,A
    JR Z,.L56C6
    CALL .L5754
.L56C6:
    LD A,($C822)
    LD L,A
    LD A,($C823)
    LD H,A
    PUSH HL
    CALL .L4B40
    POP HL
    LD A,L
    LD ($C822),A
    LD A,H
    LD ($C823),A
    LD A,($DB8A)
    CP $24
    CALL Z,.L56FA
    LD A,($C823)
    CP $29
    JR NZ,.L56F5
    LD A,($C822)
    OR A
    JR NZ,.L56F5
    LD A,$6D
    CALL $1EFF
.L56F5:
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L56FA:
    LD A,($DD72)
    CP $01
    RET NZ
    LD HL,$C180
.L5703:
    LD A,(HL)
    CP $F0
    JR Z,.L570B
    INC HL
    JR .L5703
.L570B:
    DEC HL
    LD A,(HL)
    CP $24
    RET NC
    LD (HL),$F0
    RET
.L5713:
    LD A,($C823)
    CP $82
    JR Z,.L5743
    CP $CC
    JR Z,.L5743
    CP $E8
    JR Z,.L5748
    CP $88
    JR Z,.L5743
    CP $8A
    JR Z,.L5743
    CP $86
    JR Z,.L5743
    CP $8E
    JR Z,.L5743
    CP $95
    JR Z,.L5743
    CP $B0
    JR Z,.L5743
    CP $B2
    JR Z,.L5743
    CP $B5
    JR Z,.L574E
    RET
.L5743:
    LD HL,$C823
    INC (HL)
    RET
.L5748:
    LD A,$E3
    LD ($C823),A
    RET
.L574E:
    LD A,$D2
    LD ($C823),A
    RET
.L5754:
    LD A,($C823)
    CP $CA
    JR Z,.L576C
    CP $C3
    JR Z,.L577D
    CP $B6
    JR Z,.L5787
    CP $B8
    JR Z,.L5791
    CP $C9
    JR Z,.L576C
    RET
.L576C:
    CALL .L57DA
    RET NC
    LD A,($DB8A)
    CP $7D
    JR Z,.L57BB
    LD A,$C7
    LD ($C823),A
    RET
.L577D:
    CALL .L57DA
    RET C
    LD A,$B8
    LD ($C823),A
    RET
.L5787:
    CALL .L57DA
    RET NC
    LD A,$B7
    LD ($C823),A
    RET
.L5791:
    CALL .L57DA
    RET NC
    LD A,($DB8A)
    CP $6B
    RET C
    CP $6E
    RET Z
    CP $71
    RET Z
    CP $75
    RET NC
    CP $6E
    JR C,.L57B5
    CP $6F
    JR Z,.L57BB
    CP $70
    JR Z,.L57C7
    CP $75
    JR C,.L57C1
    RET
.L57B5:
    LD A,$C3
    LD ($C823),A
    RET
.L57BB:
    LD A,$C4
    LD ($C823),A
    RET
.L57C1:
    ADD A,$53
    LD ($C823),A
    RET
.L57C7:
    LD A,$CA
    LD ($C823),A
    RET
    DB $FA,$63,$C8,$CB,$4F,$FA,$89,$DB,$C8,$FA,$88,$DB,$C9
.L57DA:
    LD A,($C863)
    BIT 1,A
    JR NZ,.L57E7
    LD A,($DB89)
    CP $04
    RET
.L57E7:
    LD A,($DB89)
    CP $04
    CCF
    RET
.L57EE:
    LD A,($DCFD)
    BIT 4,A
    RET Z
    LD A,($DB8A)
    CP $43
    RET Z
    CP $8F
    RET Z
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    BIT 6,(HL)
    RET
Bank83_fn6:
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    BIT 0,(HL)
    RET Z
    LD HL,$5402
    RST $10  ; -> bank84/fn2
    LD A,($DCFF)
    BIT 0,A
    RET Z
    LD A,($DB8A)
    LD ($DB4C),A
    XOR A
    LD ($DB4D),A
    LD A,$04
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    LD C,A
    LD B,$00
    LD E,C
    LD D,B
    LD A,($DB89)
    CALL $33BE
    ADD HL,BC
    PUSH HL
    LD A,($DB89)
    CALL $33B0
    POP BC
    CALL $3314
    JR NC,.L5863
    LD A,C
    SUB L
    LD C,A
    LD A,B
    SBC A,H
    LD B,A
    LD A,E
    SUB C
    LD E,A
    LD A,D
    SBC A,B
    LD D,A
    JR NC,.L5861
    LD DE,$0000
    JR .L5863
.L5861:
    LD B,H
    LD C,L
.L5863:
    LD A,E
    LD ($D9F2),A
    LD A,D
    LD ($D9F3),A
    LD A,$01
    OR A
    RET
Bank83_fn8:
    CALL Bank83_fn6
    LD A,($D9F2)
    LD C,A
    LD A,($D9F3)
    LD B,A
    LD A,($DB89)
    LD HL,$DBC3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    ADD A,C
    LD (HL+),A
    LD A,(HL)
    ADC A,B
    LD (HL),A
    LD HL,$C190
    CALL $0E68
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L6B52
    LD A,$8D
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L58B5:
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
.L58C0:
    PUSH HL
    LD A,$0A
    CALL $21DC
    POP DE
    LD A,H
    OR L
    JR NZ,.L58CF
    LD H,D
    LD L,E
    JR .L58FD
.L58CF:
    LD A,($C899)
    LD C,A
    LD A,($C89A)
    LD B,A
    LD A,B
    AND $03
    LD B,A
.L58DB:
    CALL $3314
    JR NC,.L58E8
    LD A,C
    SUB L
    LD C,A
    LD A,B
    SBC A,H
    LD B,A
    JR .L58DB
.L58E8:
    LD H,D
    LD L,E
    SRL B
    RR C
    JR C,.L58F3
    ADD HL,BC
    JR .L58FD
.L58F3:
    LD A,L
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR NC,.L58FD
    LD H,D
    LD L,E
.L58FD:
    RET
.L58FE:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    CALL .L4980
    POP HL
    POP DE
    POP BC
    POP AF
    LD B,H
    LD C,L
    SRL B
    RR C
    LD A,B
    OR C
    JR NZ,.L5915
    LD C,$01
.L5915:
    PUSH HL
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
.L591E:
    CALL $3314
    JR C,.L592B
    LD A,L
    SUB C
    LD L,A
    LD A,H
    SBC A,B
    LD H,A
    JR .L591E
.L592B:
    LD B,H
    LD C,L
    POP HL
    SLA L
    RL H
    ADD HL,BC
    RET
.L5934:
    LD ($DD6C),A
    LD HL,$C1C0
    LD A,($DB88)
    LD (HL+),A
    LD A,($DB89)
    LD (HL+),A
    LD A,($DD69)
    LD (HL+),A
    LD A,($DB88)
    LD DE,$DCEC
    ADD A,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD (HL+),A
    INC DE
    LD A,(DE)
    LD (HL+),A
    LD A,($DB89)
    LD BC,$DCEC
    ADD A,A
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,(BC)
    LD (HL+),A
    INC BC
    LD A,(BC)
    LD (HL+),A
    LD A,(DE)
    LD (BC),A
    DEC BC
    DEC DE
    LD A,(DE)
    LD (BC),A
    LD A,($DB89)
    LD DE,$DD13
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    LD (HL),A
    LD A,$02
    LD (DE),A
    RET
Bank83_fn9:
    LD A,($DB4C)
.L5985:
    CALL .L5934
    LD A,($DB89)
    LD ($DB88),A
    LD A,($DCFC)
    BIT 0,A
    JR NZ,.L59A0
    LD A,($DD6C)
    CP $04
    JR Z,.L59A0
    CP $01
    JR NZ,.L59B6
.L59A0:
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($C1C0)
    LD ($DB89),A
    LD (HL),A
    JR .L59CB
.L59B6:
    LD HL,$5808
    RST $10  ; -> bank88/fn8
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DB89),A
.L59CB:
    XOR A
    LD ($DD69),A
    LD A,$00
    LD ($D9ED),A
    LD A,$02
    LD ($D9EE),A
    LD A,($DD6C)
    CP $08
    RET Z
    CP $01
    CALL Z,.L59ED
    LD A,$01
    LD HL,$D9ED
    LD (HL+),A
    XOR A
    LD (HL),A
    RET
.L59ED:
    LD A,($DB88)
    RRCA
    RRCA
    AND $01
    LD HL,$DB4A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    RET Z
    LD A,(HL)
    AND $FC
    LD (HL),A
    LD A,($DB88)
    AND $04
    LD C,A
    LD B,$01
.L5A0D:
    LD A,C
    LD HL,$DB04
    CALL $333B
    RES 6,(HL)
    INC C
    DEC B
    JR NZ,.L5A0D
    RET
.L5A1B:
    PUSH BC
    LD A,B
    CALL .L5934
    POP BC
    LD A,C
    LD ($DB89),A
    RET
.L5A26:
    LD A,($C86C)
    OR A
    JR NZ,.L5A38
    LD A,($DB88)
    CP $04
    JR C,.L5A38
    LD DE,$688F
    JR .L5A3B
.L5A38:
    LD DE,$67B2
.L5A3B:
    LD A,($DB88)
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    OR A
    JR Z,.L5A5C
    CP $01
    JR Z,.L5A5C
    CP $02
    JR Z,.L5A5C
    LD A,$04
.L5A5C:
    LD B,A
    LD A,($C899)
    CP B
    RET
Bank83_fn17:
    LD A,($D9EE)
    RST $00
    DW .L5A6E                           ; state 0
    DW .L5ABB                           ; state 1
    DW .L5B03                           ; state 2
    DW .L5B3D                           ; state 3
.L5A6E:
    LD HL,$D9F2
    LD A,(HL+)
    OR (HL)
    CALL NZ,.L5B47
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    AND $90
    JR Z,.L5AB3
    LD A,($DCFF)
    BIT 3,A
    JR Z,.L5AB3
    CALL .L4980
    LD A,($C86C)
    OR A
    JR NZ,.L5A9F
    LD A,($DB89)
    CP $04
    JR C,.L5A9F
    LD B,$40
    JR .L5AA1
.L5A9F:
    LD B,$AA
.L5AA1:
    LD A,($C899)
    CP B
    JR NC,.L5AB3
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9F2
    LD A,(HL+)
    OR (HL)
    JR Z,.L5ABB
    RET
.L5AB3:
    LD A,$03
    LD ($D9EE),A
    JP .L5B3D
.L5ABB:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    BIT 7,(HL)
    RET Z
    LD A,(HL)
    AND $63
    LD (HL),A
    LD HL,$D9EE
    INC (HL)
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L6B52
    LD A,$DB
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
.L5AF4:
    LD A,($DB89)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$03
    RET
.L5B03:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    BIT 4,(HL)
    JR Z,.L5B3D
    LD A,(HL)
    AND $63
    LD (HL),A
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L6B52
    LD A,$DC
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    CALL .L5AF4
    RET
.L5B3D:
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    RET
.L5B47:
    LD A,($DD6C)
    OR A
    RET NZ
    LD A,($DD6E)
    OR A
    RET NZ
    LD A,($DB89)
    CALL $3374
    RET C
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    BIT 0,(HL)
    RET Z
    LD HL,$5307
    RST $10  ; -> bank83/fn7
    RET
Bank83_fn10:
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    AND $90
    CALL NZ,.L5BEF
    XOR A
    LD (HL+),A
    LD A,(HL)
    AND $3C
    LD (HL+),A
    INC HL
    RES 7,(HL)
    INC HL
    INC HL
    LD A,(HL)
    AND $FC
    LD (HL),A
    INC HL
    BIT 7,(HL)
    RET Z
    RES 7,(HL)
    LD A,($DB89)
    LD ($DD72),A
    LD HL,$5708
    RST $10  ; -> bank87/fn8
    LD A,($DB89)
    LD HL,$DC03
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    CALL $3314
    POP HL
    JR NC,.L5BBE
    LD A,($DD72)
    LD (HL+),A
    LD A,($DD73)
    LD (HL),A
.L5BBE:
    LD A,($DB89)
    LD ($DD72),A
    LD HL,$5707
    RST $10  ; -> bank87/fn7
    LD A,($DB89)
    LD HL,$DBF3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    CALL $3314
    POP HL
    RET NC
    LD A,($DD72)
    LD (HL+),A
    LD A,($DD73)
    LD (HL),A
    RET
.L5BEF:
    PUSH HL
    LD A,($DB89)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$03
    POP HL
    RET
Bank83_fn11:
    LD A,($D9EE)
    RST $00
    DW .L5C16                           ; state 0
    DW .L5C2A                           ; state 1
    DW .L5C7F                           ; state 2
    DW .L5C9F                           ; state 3
    DW .L5CCB                           ; state 4
    DW .L5D0F                           ; state 5
    DW .L5D30                           ; state 6
    DW .L5D58                           ; state 7
    DW .L5D9F                           ; state 8
.L5C16:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR NC,.L5C2A
    LD A,$05
    LD ($D9EE),A
    JP .L5D0F
.L5C2A:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    INC HL
    LD A,(HL)
    AND $30
    LD (HL+),A
    LD A,(HL)
    AND $C8
    LD (HL+),A
    LD A,(HL)
    AND $3F
    LD (HL+),A
    INC HL
    LD A,(HL)
    LD B,A
    AND $C0
    LD A,B
    JR Z,.L5C5C
    PUSH HL
    LD A,($DB89)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$03
    POP HL
.L5C5C:
    AND $33
    LD (HL+),A
    LD A,(HL)
    AND $3D
    LD (HL+),A
    RES 2,(HL)
    LD A,($DB89)
    LD HL,$C180
    LD ($DB50),A
    CALL .L6B52
    LD A,$AC
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5C7F:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    LD A,(HL)
    OR A
    RET Z
    LD (HL),$00
    LD A,$D9
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5C9F:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB03
    CALL $333B
    LD A,(HL)
    OR A
    JR NZ,.L5CB8
    CALL .L5FC9
    LD HL,$D9EE
    INC (HL)
    RET
.L5CB8:
    LD (HL),$00
    CALL .L5DB8
    LD A,$AD
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5CCB:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD B,A
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    CALL .L609C
    LD A,($DB89)
    LD HL,$C1CD
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $80
    LD (HL),A
    LD A,($DB89)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$03
    LD A,($DB89)
    AND $03
    LD HL,$C1CA
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF
    RET
.L5D0F:
    LD A,($DB89)
    AND $03
    CP $02
    JR Z,.L5D21
    LD HL,$DB89
    INC (HL)
    XOR A
    LD ($D9EE),A
    RET
.L5D21:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    AND $04
    OR $03
    LD ($DB89),A
    RET
.L5D30:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    RET C
    CALL .L6059
    LD A,($DB89)
    LD HL,$C180
    LD ($DB50),A
    CALL .L6B52
    LD A,$D8
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5D58:
    LD HL,$D9EE
    INC (HL)
    LD HL,$DB00
    RES 3,(HL)
    INC HL
    RES 3,(HL)
    LD A,($DB89)
    CP $04
    JR C,.L5D70
    LD HL,$DB01
    JR .L5D73
.L5D70:
    LD HL,$DB00
.L5D73:
    LD A,(HL)
    AND $10
    LD (HL),A
    LD A,($DB8A)
    CP $83
    JR Z,.L5D81
    CP $A5
    RET NZ
.L5D81:
    LD HL,$DB00
    SET 3,(HL)
    INC HL
    SET 3,(HL)
    LD A,($DB88)
    AND $04
    LD B,A
    LD A,($DB89)
    AND $04
    CP B
    RET Z
    LD A,B
    LD ($DB89),A
    XOR A
    LD ($D9EE),A
    RET
.L5D9F:
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($DD72),A
    XOR A
    LD ($DD73),A
    RET
.L5DB8:
    LD A,($DB89)
    LD ($DB4C),A
    LD HL,$510A
    RST $10  ; -> bank81/fn10
    LD A,($C86C)
    OR A
    JR NZ,.L5DD4
    LD A,($DB89)
    CP $04
    JR C,.L5DD4
    CALL .L5F14
    JR .L5DD7
.L5DD4:
    CALL .L5E3E
.L5DD7:
    LD A,($DB89)
    LD HL,$DBA3
    CALL .L5E1C
    PUSH HL
    LD A,($DB89)
    LD HL,$DBB3
    CALL .L5E1C
    POP BC
    CALL $3314
    JR NC,.L5DF9
    LD A,($DB89)
    LD HL,$DBA3
    CALL .L5E27
.L5DF9:
    LD A,($DB89)
    LD HL,$DBC3
    CALL .L5E1C
    PUSH HL
    LD A,($DB89)
    LD HL,$DBD3
    CALL .L5E1C
    POP BC
    CALL $3314
    JR NC,.L5E1B
    LD A,($DB89)
    LD HL,$DBC3
    CALL .L5E27
.L5E1B:
    RET
.L5E1C:
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
.L5E27:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD B,H
    LD C,L
    LD A,L
    ADD A,$10
    LD L,A
    LD A,H
    ADC A,$00
    LD H,A
    LD A,(HL+)
    LD (BC),A
    INC BC
    LD A,(HL)
    LD (BC),A
    RET
.L5E3E:
    LD A,($DB89)
    AND $03
    CP $03
    JP Z,.L5F14
    LD A,($DB89)
    LD HL,$CB13
    CALL $261E
    LD A,($DB89)
    LD HL,$DBB3
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB17
    CALL $261E
    LD A,($DB89)
    LD HL,$DBD3
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB19
    CALL $261E
    LD A,($DB89)
    LD HL,$DBE3
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB1B
    CALL $261E
    LD A,($DB89)
    LD HL,$DBF3
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB1D
    CALL $261E
    LD A,($DB89)
    LD HL,$DC03
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB1F
    CALL $261E
    LD A,($DB89)
    LD HL,$DC13
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB0C
    CALL $2619
    LD B,A
    LD A,($DB89)
    LD HL,$DB9B
    CALL .L6093
    LD A,($DB89)
    LD HL,$CB25
    CALL $2619
    LD B,A
    LD A,($DB89)
    LD HL,$DC44
    CALL .L6093
    LD A,($DB89)
    LD HL,$CB26
    CALL $2619
    LD B,A
    LD A,($DB89)
    LD HL,$DC54
    CALL .L6093
    LD A,($DB89)
    LD HL,$CB28
    CALL $2619
    LD B,A
    LD A,($DB89)
    LD HL,$DC4C
    CALL .L6093
    LD A,($DB89)
    LD HL,$CB27
    CALL $2619
    LD B,A
    LD A,($DB89)
    LD HL,$DC5C
    CALL .L6093
    RET
.L5F14:
    SUB $04
    LD HL,$DA03
    CALL .L58B5
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD HL,$DA1C
    LD A,($DB89)
    LD DE,$DB9B
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    LD A,($DB89)
    LD B,A
    LD DE,$DBB3
    ADD A,A
    LD C,A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,C
    LD DE,$DBD3
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,C
    LD DE,$DBE3
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,C
    LD DE,$DBF3
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,C
    LD DE,$DC03
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,C
    LD DE,$DC13
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    LD A,B
    LD DE,$DC44
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    LD A,B
    LD DE,$DC54
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    LD A,B
    LD DE,$DC4C
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    LD A,B
    LD DE,$DC5C
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    RET
.L5FC9:
    LD A,($C86C)
    OR A
    JR NZ,.L5FDA
    LD A,($DB89)
    CP $03
    JR C,.L5FDA
    CALL .L6007
    RET
.L5FDA:
    LD A,($DB89)
    AND $03
    CP $03
    RET Z
    LD A,($DB89)
    LD HL,$CB1B
    CALL $261E
    LD A,($DB89)
    LD HL,$DBF3
    CALL .L6088
    LD A,($DB89)
    LD HL,$CB1D
    CALL $261E
    LD A,($DB89)
    LD HL,$DC03
    CALL .L6088
    RET
.L6007:
    LD A,($DB89)
    AND $03
    CP $03
    RET Z
    LD HL,$DA03
    CALL .L58B5
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD HL,$DA25
    LD A,($DB89)
    ADD A,A
    LD DE,$DC03
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL)
    LD (DE),A
    LD HL,$DA23
    LD A,($DB89)
    ADD A,A
    LD DE,$DBF3
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL+)
    LD (DE),A
    INC DE
    LD A,(HL)
    LD (DE),A
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    LD A,(HL)
    AND $3F
    LD (HL),A
    RET
.L6059:
    LD A,($DB89)
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF
    LD A,($DB89)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$FF
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    XOR A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL),A
    RET
.L6088:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,C
    LD (HL+),A
    LD (HL),B
    RET
.L6093:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),B
    RET
.L609C:
    CALL .L60E0
    LD A,($C863)
    BIT 1,A
    LD A,B
    JR Z,.L60AD
    CP $03
    JR NC,.L60DF
    JR .L60B7
.L60AD:
    CP $04
    JR C,.L60DF
    CP $07
    JR Z,.L60DF
    SUB $04
.L60B7:
    PUSH BC
    LD BC,$0240
    CALL $21B5
    LD BC,$9000
    ADD HL,BC
    POP BC
    PUSH HL
    LD L,C
    LD H,$00
    ADD HL,HL
    LD A,L
    ADD A,$6E
    LD L,A
    LD A,H
    ADC A,$2F
    LD H,A
    LD E,(HL)
    INC HL
    LD D,(HL)
    POP HL
    CALL $194A
    LD HL,$5110
    RST $10  ; -> bank81/fn16
    LD HL,$1708
    RST $10  ; -> bank23/fn8
.L60DF:
    RET
.L60E0:
    LD A,($C81D)
    OR A
    RET Z
    LD A,$02
    LDH ($FF70),A
    LD A,B
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),C
    LD A,$00
    LDH ($FF70),A
    RET
Bank83_fn12:
    LD A,($D9EE)
    RST $00
    DW .L6107                           ; state 0
    DW .L6168                           ; state 1
    DW .L61C9                           ; state 2
    DW .L61F3                           ; state 3
    DW .L620A                           ; state 4
.L6107:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD ($DD72),A
    LD HL,$5707
    RST $10  ; -> bank87/fn7
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    SRL B
    RR C
    CALL .L622E
    LD A,($DB89)
    LD HL,$DBF3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    CALL .L6235
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    CALL .L6223
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,H
    OR L
    JR Z,.L6167
    CALL .L4B40
    LD A,$86
    LD ($C823),A
    CALL .L6247
    LD A,$72
    CALL $1EFF
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    SET 7,(HL)
    RET
.L6167:
    RET
.L6168:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD ($DD72),A
    LD HL,$5708
    RST $10  ; -> bank87/fn8
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    SRL B
    RR C
    CALL .L622E
    LD A,($DB89)
    LD HL,$DC03
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    CALL .L6235
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    CALL .L6223
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,H
    OR L
    JR Z,.L61C8
    CALL .L4B40
    LD A,$95
    LD ($C823),A
    CALL .L6247
    LD A,$72
    CALL $1EFF
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    SET 7,(HL)
    RET
.L61C8:
    RET
.L61C9:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DB03
    CALL $333B
    BIT 1,(HL)
    JR NZ,.L61F2
    SET 1,(HL)
    CALL .L6C2D
    LD A,$98
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$84
    CALL $1EFF
    RET
.L61F2:
    RET
.L61F3:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    RET C
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    SET 7,(HL)
    RET
.L620A:
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($DD72),A
    XOR A
    LD ($DD73),A
    RET
.L6223:
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,B
    LD (HL),A
    RET NC
    XOR A
    LD (HL-),A
    LD (HL),A
    RET
.L622E:
    LD A,B
    OR C
    RET NZ
    LD BC,$0001
    RET
.L6235:
    LD A,(HL+)
    SUB C
    LD E,A
    LD A,(HL-)
    SBC A,B
    LD D,A
    JR C,.L6241
    OR E
    JR Z,.L6241
    RET NC
.L6241:
    LD A,(HL+)
    LD C,A
    LD A,(HL-)
    LD B,A
    DEC BC
    RET
.L6247:
    LD A,($DB89)
    CP $04
    JR NC,.L6252
    LD HL,$C823
    INC (HL)
.L6252:
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
Bank83_fn13:
    LD A,($D9EE)
    RST $00
    DW .L626D                           ; state 0
    DW .L62F6                           ; state 1
    DW .L63B3                           ; state 2
    DW .L6401                           ; state 3
    DW .L64BE                           ; state 4
    DW .L6551                           ; state 5
    DW .L65D1                           ; state 6
.L626D:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L6298
    LD A,($DB89)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $C0
    JR Z,.L629F
    CALL .L6C2D
    LD A,$BA
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
.L6298:
    LD A,$03
    LD ($D9EE),A
    JR .L62F5
.L629F:
    LD A,($DD6E)
    OR A
    JR NZ,.L62F5
    INC HL
    BIT 4,(HL)
    JR Z,.L62F5
    INC HL
    LD A,(HL)
    SWAP A
    AND $0F
    LD B,A
    CALL $3345
    JR C,.L62F5
    LD A,B
    LD HL,$C180
    PUSH BC
    LD ($DB50),A
    CALL .L6B52
    LD A,($DB89)
    LD ($C1C8),A
    LD HL,$C190
    LD ($DB50),A
    CALL .L6B52
    POP BC
    LD A,B
    LD ($DB89),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),B
    LD A,$80
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$04
    LD ($DD6E),A
.L62F5:
    RET
.L62F6:
    LD HL,$D9EE
    INC (HL)
    CALL Bank83_fn16
    OR A
    JP Z,.L63A5
    CALL .L4980
    LD A,($DB89)
    LD HL,$DD2B
    LD B,A
    ADD A,A
    ADD A,B
    ADD A,A
    ADD A,B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    CP $03
    JP Z,.L63A5
    CP $02
    JR C,.L6328
    LD A,($C899)
    CP $C0
    JR NC,.L63A5
.L6328:
    CALL .L6C2D
    LD A,($DB89)
    CALL $33B7
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    LD A,($C89A)
    CP $7F
    JR C,.L637F
    LD A,$64
    CALL $21DC
    LD A,H
    OR L
    JR NZ,.L634C
    LD HL,$0001
.L634C:
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,C
    SUB L
    LD C,A
    LD A,B
    SBC A,H
    LD B,A
    JR C,.L637F
    OR C
    JR Z,.L637F
    LD A,$6C
    LD ($DD73),A
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    CALL .L4B4A
    LD A,$82
    LD ($C823),A
    CALL .L6790
    JR NC,.L6393
    LD HL,$C823
    INC (HL)
    JR .L6393
.L637F:
    LD A,$E9
    LD ($C823),A
    LD A,$9C
    LD ($DD73),A
    CALL .L6790
    JR NC,.L6393
    LD A,$E3
    LD ($C823),A
.L6393:
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,($DD73)
    CP $FF
    RET Z
    CALL $1EFF
    RET
.L63A5:
    LD HL,$D9EE
    INC (HL)
    CALL .L6C2D
    LD A,$B8
    LD ($C823),A
    JR .L6393
.L63B3:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,B
    LD (HL-),A
    OR (HL)
    RET NZ
    LD A,($DB89)
    LD ($DB4C),A
    XOR A
    LD ($D9F0),A
    LD HL,$5103
    RST $10  ; -> bank81/fn3
    CALL .L6790
    JR C,.L63FC
    LD HL,$5801
    RST $10  ; -> bank88/fn1
    LD A,$03
    LD ($D9ED),A
    LD A,($C86C)
    OR A
    RET NZ
    LD A,($DB89)
    LD ($DD61),A
    RET
.L63FC:
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    RET
.L6401:
    LD A,($C1C8)
    CP $FF
    JR Z,.L642C
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD A,($C1C8)
    LD ($DB89),A
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
    LD A,$FF
    LD ($C1C8),A
    XOR A
    LD ($DD6E),A
.L642C:
    LD A,($DD6C)
    OR A
    JR NZ,.L644A
    LD HL,$D9EE
    INC (HL)
.L6436:
    LD A,($DB89)
    AND $03
    CP $02
    RET Z
    LD HL,$DB89
    INC (HL)
    CALL .L645B
    XOR A
    LD ($D9EE),A
    RET
.L644A:
    LD HL,$5207
    RST $10  ; -> bank82/fn7
    CALL .L6436
    RET
    DB $21,$ED,$D9,$34,$AF,$EA,$EE,$D9,$C9
.L645B:
    LD A,($DCFE)
    BIT 0,A
    RET Z
    LD A,($DD6C)
    BIT 2,A
    RET NZ
    LD A,($DB89)
    LD HL,$DB04
    CALL $333B
    LD A,(HL)
    AND $22
    RET Z
    LD A,$00
    LD ($DD6D),A
    BIT 1,(HL)
    JR NZ,.L6484
    RES 5,(HL)
    LD A,$07
    LD ($DD6D),A
.L6484:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    JR Z,.L6491
    LD A,($DB88)
.L6491:
    RRCA
    RRCA
    AND $01
    ADD A,$7B
    LD A,A
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$04
    CALL .L5985
    LD A,$02
    LD ($DD6E),A
    LD A,$03
    LD ($D9ED),A
    LD A,$03
    LD ($D9EE),A
    RET
.L64B8:
    LD A,($DB88)
    LD ($DB89),A
.L64BE:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    CALL $3374
    RET C
    CALL .L4980
    CALL .L6C42
    LD A,($DB88)
    CALL $33B7
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    LD A,($C899)
    CP $7F
    JR C,.L6524
    LD A,$64
    CALL $21DC
    LD A,H
    OR L
    JR NZ,.L64F0
    LD HL,$0001
.L64F0:
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,C
    SUB L
    LD C,A
    LD A,B
    SBC A,H
    LD B,A
    OR C
    JR Z,.L6524
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    CALL .L4B4A
    LD A,$85
    LD ($C823),A
    LD A,$FF
    LD ($DD73),A
    JR .L653F
.L6518:
    LD A,$E5
    LD ($C823),A
    LD A,$FF
    LD ($DD73),A
    JR .L653F
.L6524:
    LD A,($DB8A)
    CP $96
    JR Z,.L6518
    LD A,$FF
    LD ($DD73),A
    LD A,$E7
    LD ($C823),A
    CALL .L67A1
    JR NC,.L653F
    LD A,$EA
    LD ($C823),A
.L653F:
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,($DD73)
    CP $FF
    RET Z
    CALL $1EFF
    RET
.L6551:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,B
    LD (HL-),A
    OR (HL)
    RET NZ
    LD A,($DB88)
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$01
    LD (HL),A
    LD A,($DB88)
    LD ($DB4C),A
    XOR A
    LD ($D9F0),A
    LD HL,$5103
    RST $10  ; -> bank81/fn3
    LD A,($DB89)
    PUSH AF
    LD A,($DB88)
    LD ($DB89),A
    CALL .L67A1
    JR C,.L65B8
    LD A,($D9ED)
    PUSH AF
    LD HL,$5801
    RST $10  ; -> bank88/fn1
    POP AF
    LD ($D9ED),A
    LD A,($C86C)
    OR A
    JR NZ,.L65BC
    LD A,($DB89)
    LD ($DD61),A
    JR .L65BC
.L65B8:
    LD HL,$5004
    RST $10  ; -> bank80/fn4
.L65BC:
    POP AF
    LD ($DB89),A
    RET
.L65C1:
    LD A,($DB88)
    LD HL,$DBC3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    XOR A
    LD (HL+),A
    LD (HL),A
.L65D1:
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($DD72),A
    XOR A
    LD ($DD73),A
    RET
Bank83_fn14:
    LD A,($D9EE)
    RST $00
    DW .L65F5                           ; state 0
    DW .L6625                           ; state 1
    DW .L669B                           ; state 2
    DW .L66C6                           ; state 3
    DW .L64B8                           ; state 4
    DW .L6551                           ; state 5
    DW .L65C1                           ; state 6
.L65F5:
    LD HL,$D9EE
    INC (HL)
    XOR A
    LD ($DD73),A
    LD A,($DB89)
    LD HL,$DB88
    CP (HL)
    JR Z,.L661C
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $FF
    JR Z,.L661C
    CP $01
    RET Z
    LD HL,$D9EE
    INC (HL)
    RET
.L661C:
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    RET
.L6625:
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    LD A,$9E
    LD ($DD73),A
    CALL .L6709
    LD A,($DB89)
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$00
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    XOR A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL),A
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    LD B,A
    JR NZ,.L6666
    CP $03
    JR C,.L6679
    JR .L666A
.L6666:
    CP $03
    JR NC,.L6679
.L666A:
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    CALL .L609C
    JR .L668A
.L6679:
    SWAP A
    LD HL,$8DA0
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD DE,$5B02
    CALL $194A
.L668A:
    LD A,$9E
    LD ($DD73),A
    LD A,$FF
    LD ($DB5C),A
    CALL .L6C2D
    RET
    DB $25,$2B,$31
.L669B:
    LD HL,$D9EE
    INC (HL)
    CALL .L6709
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD A,$84
    LD ($DD73),A
    CALL .L6C2D
    LD A,($C86C)
    OR A
    JR Z,.L66BA
    CALL .L67A1
    RET NC
    JR .L66C0
.L66BA:
    LD A,($DB88)
    CP $04
    RET NC
.L66C0:
    LD A,$70
    LD ($DB5C),A
    RET
.L66C6:
    LD HL,$D9EE
    INC (HL)
    LD A,($DD73)
    OR A
    JR Z,.L66F8
    LD A,($DD73)
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,($DB5C)
    CP $FF
    JR Z,.L66F8
    LD A,($C86C)
    OR A
    JR NZ,.L66F2
    LD A,($DB88)
    CP $04
    JR NC,.L66F8
.L66F2:
    LD A,($DB5C)
    CALL $1EFF
.L66F8:
    LD A,($DB89)
    AND $03
    CP $02
    RET Z
    LD HL,$DB89
    INC (HL)
    XOR A
    LD ($D9EE),A
    RET
.L6709:
    LD A,($DB89)
    LD HL,$DBB3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    LD A,($DB89)
    LD HL,$DBA3
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),E
    INC HL
    LD (HL),D
    RET
Bank83_fn15:
    LD A,($DB89)
    CP $03
    JR Z,.L6786
    CP $06
    JR Z,.L6752
    CP $03
    JR C,.L6763
    INC A
    LD ($DB89),A
    CALL $3374
    JR C,Bank83_fn15
    LD A,$01
    LD ($D9ED),A
    LD A,$0B
    LD ($D9EE),A
    LD A,$00
    LD ($D9F0),A
    RET
.L6752:
    LD A,($DB8A)
    CP $A4
    JR Z,.L6786
    LD A,$00
    LD ($DB89),A
    CALL $3374
    JR C,Bank83_fn15
.L6763:
    CALL $3374
    JR C,.L6780
    LD A,($DB89)
    CALL .L6C2D
    LD A,$AA
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$DB89
    INC (HL)
    RET
.L6780:
    LD HL,$DB89
    INC (HL)
    JR Bank83_fn15
.L6786:
    LD A,$06
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    RET
.L6790:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    JR NZ,.L679D
    CP $04
    RET
.L679D:
    CP $04
    CCF
    RET
.L67A1:
    LD A,($C863)
    BIT 1,A
    LD A,($DB88)
    JR NZ,.L67AE
    CP $04
    RET
.L67AE:
    CP $04
    CCF
    RET
    DB $02,$02,$02,$02,$02,$03,$02,$02,$03,$02,$03,$02,$03,$02,$02,$02
    DB $02,$02,$01,$01,$01,$01,$01,$01,$01,$02,$01,$02,$02,$02,$00,$01
    DB $01,$01,$01,$02,$01,$01,$02,$02,$01,$01,$01,$01,$00,$01,$02,$01
    DB $02,$02,$01,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$00,$01,$01,$01,$02,$02,$03,$02,$02,$02,$02,$02,$03,$02
    DB $02,$02,$02,$02,$02,$02,$02,$01,$02,$01,$02,$02,$02,$02,$03,$03
    DB $02,$02,$02,$02,$03,$02,$02,$02,$03,$02,$03,$01,$01,$03,$02,$01
    DB $02,$02,$02,$02,$01,$01,$02,$03,$02,$01,$01,$02,$02,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$00,$01,$00,$00,$01,$00,$00,$02,$01,$02,$02,$02
    DB $01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$01,$02,$01,$00,$02,$02
    DB $01,$02,$02,$02,$02,$02,$01,$02,$02,$01,$01,$02,$02,$01,$02,$02
    DB $01,$01,$02,$02,$01,$01,$02,$00,$01,$00,$01,$00,$01,$00,$00,$00
    DB $01,$00,$01,$01,$00,$00,$00,$00,$02,$02,$01,$01,$02,$00,$00,$01
    DB $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00
    DB $00,$00,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00,$01,$01,$01,$01
    DB $01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01
    DB $00,$01,$00,$01,$01,$00,$01,$01,$01,$01,$00,$01,$01,$01,$01,$00
    DB $00,$00,$00,$00,$01,$00,$00,$01,$00,$01,$01,$00,$00,$01,$01,$01
    DB $01,$01,$01,$01,$01,$00,$00,$01,$01,$00,$00,$01,$01,$00,$01,$00
    DB $01,$00,$00,$00,$01,$00,$00,$01,$01,$01,$03,$00,$00,$00,$00,$01
    DB $00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00,$01,$01,$01,$00,$00
    DB $01,$01,$00,$01,$00,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01,$01
    DB $01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01
    DB $00,$00,$01,$01,$00,$01,$01,$01,$00,$01,$00,$00,$01,$01,$00,$00
    DB $00,$00,$01,$00,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$00
    DB $00,$00,$03,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00
    DB $00,$01,$01,$01,$01,$01,$01,$00,$01,$00,$00,$01,$01,$01,$01,$01
    DB $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.L6B52:
    CP $03
    JR NC,.L6B70
.L6B56:
    PUSH HL
    LD HL,$CAC2
    CALL $25F8
    LD E,L
    LD D,H
    POP HL
    PUSH HL
    CALL $106C
    POP HL
.L6B65:
    LD A,(HL)
    CP $F0
    RET Z
    INC HL
    JR .L6B65
.L6B6C:
    LD A,B
    POP BC
    JR .L6B56
.L6B70:
    PUSH BC
    LD B,A
    AND $03
    CP $03
    LD A,B
    POP BC
    JR Z,.L6B99
    PUSH BC
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L6B6C
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
    JR NZ,.L6B96
    LD A,B
.L6B96:
    POP BC
    JR NZ,.L6BC1
.L6B99:
    PUSH AF
    CALL .L6BA3
    POP AF
    LD HL,$5104
    RST $10  ; -> bank81/fn4
    RET
.L6BA3:
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
.L6BC1:
    CALL .L6B56
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
    JR Z,.L6BED
    CP $02
    JR Z,.L6BF7
    LD A,(HL+)
    CP (HL)
    JR Z,.L6C13
    INC HL
    CP (HL)
    JR Z,.L6C13
    JR .L6C22
.L6BED:
    LD A,(HL+)
    CP (HL)
    JR Z,.L6C18
    LD A,(HL+)
    CP (HL)
    JR Z,.L6C13
    JR .L6C22
.L6BF7:
    LD D,$00
    INC HL
    INC HL
    LD A,(HL-)
    DEC HL
    CP (HL)
    JR NZ,.L6C01
    INC D
.L6C01:
    INC HL
    CP (HL)
    JR NZ,.L6C06
    INC D
.L6C06:
    LD A,D
    OR A
    JR Z,.L6C22
    CP $01
    JR Z,.L6C18
    POP HL
    LD A,$0C
    JR .L6C1B
.L6C13:
    POP HL
    LD A,$0A
    JR .L6C1B
.L6C18:
    POP HL
    LD A,$0B
.L6C1B:
    LD ($DB4D),A
    LD (HL+),A
    LD (HL),$F0
    RET
.L6C22:
    POP HL
    XOR A
    LD ($DB4D),A
    RET
    DB $21,$A0,$C1,$18,$03
.L6C2D:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L6B52
    RET
.L6C42:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L6B52
    RET
