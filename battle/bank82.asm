; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 82  (Battle command/menu master dispatcher)
; ============================================================================
;
; File offset $148000-$14BFFF  (16 KB, mapped at $4000-$7FFF)
;
; This bank is the TOP-LEVEL state machine of the in-battle monster command &
; status menu system. It runs during game-state 2 (battle execution, bank80).
;
; fn0 ($4011) BattleMenu_Dispatch:
;   Dispatches on wBattleMenuPhase ($D9ED) via RST $00 into 28 phase handlers.
;   Each phase drives a menu screen: command selection for the active monster,
;   target selection, "check status" (monster stats/HP/MP), skill/spell list,
;   item use, party-order changes, flee, etc.
;   wBattleMenuSub ($D9EE) is the per-phase sub-cursor / animation step.
;
; Key WRAM used:
;   $D9ED  wBattleMenuPhase   top-level menu phase (0-27), RST00 dispatch key
;   $D9EE  wBattleMenuSub     per-phase sub-state / cursor step
;   $DB88  wMenuSelection     current highlighted option / input result
;   $DB8A  wMenuInputCode     button/command code being processed
;   $DA82  wMenuBusyFlag      nonzero = a sub-action is running (skip input)
;   $DD69/$DD72/$DD80  per-monster menu scratch (target, flags)
;
; Cross-bank calls (RST $10):
;   LD HL,$53xx -> bank83 fnXX  (menu screen renderers / sub-machines)
;   Also calls bank80/81/85/87/88/95 for shared battle helpers.
;
; Callers: entered from bank80 (battle root) at $4304 (fn0) / $4352 (fn1).
; ============================================================================

SECTION "Bank82_ID", ROMX[$4000], BANK[82]
    DB $52

SECTION "Bank82_JumpTable", ROMX[$4001], BANK[82]
    DW BattleMenu_Dispatch              ; fn0 @ $4011
    DW Bank82_fn1                       ; fn1 @ $4A8B
    DW Bank82_fn2                       ; fn2 @ $4DDB
    DW Bank82_fn3                       ; fn3 @ $672E
    DW Bank82_fn4                       ; fn4 @ $6662
    DW Bank82_fn5                       ; fn5 @ $746B
    DW Bank82_fn6                       ; fn6 @ $7E18
    DW Bank82_fn7                       ; fn7 @ $52B4

SECTION "Bank82_Code", ROMX[$4011], BANK[82]
BattleMenu_Dispatch:
    LD A,($DA82)
    OR A
    JR NZ,.L4020
    LD HL,$5F05
    RST $10  ; -> bank95/fn5
    LD A,($DA82)
    OR A
    RET Z
.L4020:
    LD A,($D9ED)
    RST $00
    DW .L405C                           ; state 0
    DW .L4076                           ; state 1
    DW .L411A                           ; state 2
    DW .L41EF                           ; state 3
    DW .L4238                           ; state 4
    DW .L431A                           ; state 5
    DW .L43BE                           ; state 6
    DW .L45EA                           ; state 7
    DW .L4605                           ; state 8
    DW .L463D                           ; state 9
    DW .L4713                           ; state 10
    DW .L47D9                           ; state 11
    DW .L4837                           ; state 12
    DW .L48B0                           ; state 13
    DW .L48B4                           ; state 14
    DW .L4953                           ; state 15
    DW .L495C                           ; state 16
    DW .L4966                           ; state 17
    DW .L405C                           ; state 18
    DW .L496B                           ; state 19
    DW .L4977                           ; state 20
    DW .L5278                           ; state 21
    DW .L529C                           ; state 22
    DW .L52A1                           ; state 23
    DW .L529C                           ; state 24
    DW .L52A1                           ; state 25
    DW .L52A6                           ; state 26
    DW .L52AB                           ; state 27
.L405C:
    LD HL,$5300
    RST $10  ; -> bank83/fn0
    LD A,($D9ED)
    CP $09
    RET NZ
    XOR A
    LD HL,$D9EE
    LD (HL+),A
    LD A,$FF
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD A,$FE
    LD (HL),A
    JP .L463D
.L4076:
    LD A,($D9EE)
    CP $0B
    JR Z,.L408B
    CP $10
    JR Z,.L40B6
    LD HL,$5305
    RST $10  ; -> bank83/fn5
    LD A,($D9EE)
    CP $0B
    RET NZ
.L408B:
    LD HL,$D9EE
    INC (HL)
    XOR A
    LD ($C1C9),A
    LD A,($DB8A)
    LD C,A
    LD B,$00
    LD HL,$53B0
    ADD HL,BC
    ADD HL,BC
    CALL $0008
    LD A,($D9EE)
    CP $0C
    RET NZ
    LD A,($D9ED)
    CP $01
    RET NZ
    LD HL,$5305
    RST $10  ; -> bank83/fn5
    RET
    DB $2A,$66,$6F,$E9
.L40B6:
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($D9EE),A
    LD A,($DB8A)
    CP $29
    JR Z,.L40E4
    CP $AA
    JR Z,.L40CE
    CP $D5
    JP NZ,.L411A
.L40CE:
    LD A,$04
    LD ($D9ED),A
    CALL .L7A12
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    SET 4,(HL)
    JP .L4238
.L40E4:
    LD A,$05
    LD ($D9ED),A
    CALL .L72FD
    LD HL,$D9ED
    INC (HL)
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    SET 5,(HL)
    LD A,($C86C)
    OR A
    JP NZ,.L431A
    LD A,($DB88)
    CP $04
    JP C,.L431A
    AND $03
    LD HL,$C1CA
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,($DB89)
    LD (HL),A
    RET
.L411A:
    LD A,($DD80)
    LD HL,$DD9A
    AND (HL)
    CP $FF
    RET NZ
    LD A,($DA82)
    OR A
    RET Z
    LD A,($DB8A)
    CP $A4
    JR Z,.L4134
    CP $A2
    JR NZ,.L413B
.L4134:
    LD HL,$D9ED
    INC (HL)
    JP .L4233
.L413B:
    XOR A
    LD ($DD72),A
    LD HL,$D9ED
    INC (HL)
    LD HL,$D9ED
    INC (HL)
    LD A,($DB8A)
    CP $1A
    JP Z,.L41B6
    CP $75
    JP Z,.L41B6
    CP $76
    JP Z,.L41B6
    CP $15
    JR C,.L4174
    CP $71
    JP Z,.L41B6
    CP $37
    JR Z,.L4174
    CP $38
    JR Z,.L4174
    CP $3A
    JP C,.L41B6
    CP $94
    JP Z,.L41B6
.L4174:
    LD A,($DB8A)
    CP $12
    JP Z,.L41B6
    CP $13
    JP Z,.L41B6
    LD A,($DD6F)
    BIT 5,A
    JP Z,.L41B6
    LD A,($DB89)
    LD HL,$DBA3
    CALL .L7E46
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,E
    SUB C
    LD E,A
    LD A,D
    SBC A,B
    LD D,A
    JR C,.L41AC
    LD A,D
    LD (HL-),A
    LD (HL),E
    OR E
    JP NZ,.L41B6
.L41AC:
    LD A,$1A
    LD ($D9ED),A
    XOR A
    LD ($D9F1),A
    RET
.L41B6:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    JR Z,.L41C6
    CP $03
    JR NC,.L41EA
    JR .L41CE
.L41C6:
    CP $04
    JR C,.L41EA
    CP $07
    JR Z,.L41EA
.L41CE:
    LD A,($DB89)
    CALL $3374
    JR NC,.L41EA
    LD A,$1A
    LD ($D9ED),A
    XOR A
    LD ($D9F1),A
    RET
    DB $21,$06,$50,$D7,$3E,$01,$EA,$7E,$C8,$C9
.L41EA:
    LD HL,$5006
    RST $10  ; -> bank80/fn6
    RET
.L41EF:
    LD A,($DB8A)
    CP $14
    JR Z,.L4224
    CP $80
    JR Z,.L421F
    CP $82
    JR Z,.L4229
    CP $83
    JR Z,.L421F
    CP $A5
    JR Z,.L421F
    CP $88
    JR Z,.L422E
    CP $89
    JR Z,.L422E
    CP $A2
    JR Z,.L4233
    CP $A4
    JR Z,.L4233
    LD HL,$D9ED
    INC (HL)
    INC (HL)
    INC (HL)
    JP .L43BE
.L421F:
    LD HL,$530B
    RST $10  ; -> bank83/fn11
    RET
.L4224:
    LD HL,$530D
    RST $10  ; -> bank83/fn13
    RET
.L4229:
    LD HL,$530C
    RST $10  ; -> bank83/fn12
    RET
.L422E:
    LD HL,$5304
    RST $10  ; -> bank83/fn4
    RET
.L4233:
    LD HL,$530F
    RST $10  ; -> bank83/fn15
    RET
.L4238:
    LD A,($C825)
    OR A
    RET NZ
    LD A,($DA82)
    OR A
    RET Z
    LD A,($DA33)
    OR A
    JR Z,.L424D
    DEC A
    LD ($DA33),A
    RET
.L424D:
    LD A,($DB8A)
    CP $32
    JR Z,.L42B5
    CP $96
    JR Z,.L42B5
    CP $3B
    JR Z,.L42BA
    CP $3E
    JR Z,.L42C6
    CP $3C
    JR Z,.L42D2
    CP $67
    JR Z,.L42DE
    CP $68
    JR Z,.L42E8
    CP $69
    JP Z,.L42F2
    CP $80
    JP Z,.L42FC
    CP $95
    JP Z,.L4306
    CP $AA
    JP Z,.L4312
    CP $D5
    JP Z,.L4312
    CALL .L4293
    JP NZ,.L4316
    LD HL,$D9ED
    INC (HL)
    JP .L431A
    DB $C9
.L4293:
    LD A,($DD6E)
    OR A
    JR Z,.L429B
    XOR A
    RET
.L429B:
    LD A,($DD6C)
    AND $08
    CP $08
    RET Z
    LD A,($DB89)
    LD HL,$DB09
    CALL $333B
    BIT 2,(HL)
    RET Z
    LD A,($DCFD)
    BIT 7,A
    RET
.L42B5:
    LD HL,$530E
    RST $10  ; -> bank83/fn14
    RET
.L42BA:
    LD A,($D9EE)
    RST $00
    DW .L4B8B                           ; state 0
    DW .L4BA5                           ; state 1
    DW .L4CE3                           ; state 2
    DW .L4D3F                           ; state 3
.L42C6:
    LD A,($D9EE)
    RST $00
    DW .L4C55                           ; state 0
    DW .L4C66                           ; state 1
    DW .L4CE3                           ; state 2
    DW .L4D3F                           ; state 3
.L42D2:
    LD A,($D9EE)
    RST $00
    DW .L4D67                           ; state 0
    DW .L4D78                           ; state 1
    DW .L4CE3                           ; state 2
    DW .L4D3F                           ; state 3
.L42DE:
    LD A,($D9EE)
    RST $00
    DW .L4EF4                           ; state 0
    DW .L4D51                           ; state 1
    DW .L4D3F                           ; state 2
.L42E8:
    LD A,($D9EE)
    RST $00
    DW .L4F38                           ; state 0
    DW .L4D51                           ; state 1
    DW .L4D3F                           ; state 2
.L42F2:
    LD A,($D9EE)
    RST $00
    DW .L4F7A                           ; state 0
    DW .L4D51                           ; state 1
    DW .L4D3F                           ; state 2
.L42FC:
    LD A,($D9EE)
    RST $00
    DW .L4E0C                           ; state 0
    DW .L4E22                           ; state 1
    DW .L4D3F                           ; state 2
.L4306:
    LD A,($D9EE)
    RST $00
    DW .L4E2C                           ; state 0
    DW .L4E43                           ; state 1
    DW .L4E58                           ; state 2
    DW .L4D3F                           ; state 3
.L4312:
    CALL .L4E78
    RET
.L4316:
    CALL .L4FAF
    RET
.L431A:
    LD HL,$5311
    RST $10  ; -> bank83/fn17
    RET
.L431F:
    RES 6,(HL)
    LD A,($DCFF)
    BIT 4,A
    JP Z,.L4430
    CALL .L539B
    JP C,.L4430
    LD A,$12
    LD ($D9ED),A
    RET
.L4335:
    LD A,($DD69)
    CP $04
    JP Z,.L4430
    LD HL,$5805
    RST $10  ; -> bank88/fn5
    LD A,$01
    LD ($D9ED),A
    RET
.L4347:
    LD A,($DD69)
    CP $02
    JP Z,.L4430
    LD A,$01
    LD ($D9ED),A
    LD A,($DB89)
    CALL $3374
    RET NC
    LD HL,$5805
    RST $10  ; -> bank88/fn5
    RET
.L4360:
    LD A,($DD69)
    CP $13
    JP Z,.L4430
    LD B,$03
    JR .L4376
.L436C:
    LD A,($DD69)
    CP $17
    JP Z,.L4430
    LD B,$07
.L4376:
    AND B
    LD C,A
    LD A,($C89A)
    AND B
    CP C
    JP Z,.L4430
    LD A,($DB88)
    LD HL,$DB08
    CALL $333B
    BIT 0,(HL)
    JP Z,.L4430
    LD HL,$5805
    RST $10  ; -> bank88/fn5
    LD A,$01
    LD ($D9ED),A
    RET
.L4398:
    LD A,($DD69)
    CP $04
    JP NC,.L4430
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    LD A,(HL)
    INC A
    LD (HL),A
    AND $03
    CP $03
    JR Z,.L4430
    LD A,(HL)
    CALL $3374
    JR C,.L4398
    LD A,$01
    LD ($D9ED),A
    RET
.L43BE:
    LD A,($DA33)
    OR A
    JR Z,.L43C9
    DEC A
    LD ($DA33),A
    RET
.L43C9:
    LD A,($C1C8)
    CP $FF
    JR Z,.L43F0
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
.L43F0:
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    CALL .L5248
    CALL .L4B45
    JP C,.L44A4
    CALL .L519A
    RET C
    XOR A
    LD ($DD6B),A
    LD A,($DB8A)
    CP $50
    JP Z,.L4347
    CP $51
    JP Z,.L4335
    CP $52
    JP Z,.L4360
    CP $53
    JP Z,.L436C
    CP $57
    JP Z,.L4398
    CP $A7
    JP Z,.L450F
    CP $A8
    JP Z,.L450F
    CP $AF
    JP Z,.L450F
.L4430:
    LD A,($DB88)
    LD HL,$DD13
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,$03
    LD (HL),A
    LD A,($DCFC)
    AND $03
    CP $01
    JP NZ,.L4547
.L4449:
    CALL .L513A
    LD A,($DD6D)
    OR A
    CALL NZ,.L513F
    CALL .L4EDD
    LD A,($DB88)
    LD ($DB89),A
    CP $04
    JR NC,.L4468
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD HL,$5006
    RST $10  ; -> bank80/fn6
.L4468:
    CALL .L5190
    BIT 6,(HL)
    JP NZ,.L431F
    CALL Bank82_fn7
    JP NC,.L4430
.L4476:
    LD A,($DB82)
    INC A
    LD ($DB82),A
    CP $09
    JR NC,.L44E3
    CALL .L4B45
    JR C,.L44A4
    LD A,($DB82)
    LD HL,$DB79
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $FF
    JR Z,.L44E3
    CP $10
    JR Z,.L44A0
    CALL $3374
    JR C,.L4476
.L44A0:
    LD HL,$D9EC
    DEC (HL)
.L44A4:
    LD A,($DB8A)
    CP $52
    JR C,.L44D1
    CP $54
    JR NC,.L44D1
    LD A,($C1C9)
    OR A
    JR Z,.L44D4
    CALL $08B9
    LD A,$DA
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$1B
    LD ($D9ED),A
    LD A,$07
    LD ($D9EC),A
    RET
.L44D1:
    CALL Bank82_fn1
.L44D4:
    CALL .L4EDD
    XOR A
    LD HL,$D9ED
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL+),A
    LD (HL),A
    RET
.L44E3:
    XOR A
    LD ($DB82),A
    LD HL,$D9EC
    INC (HL)
    LD HL,$DB00
    LD A,(HL)
    AND $50
    CALL NZ,.L44FC
    INC HL
    LD A,(HL)
    AND $50
    CALL NZ,.L44FC
    RET
.L44FC:
    PUSH HL
    LD A,(HL)
    AND $AF
    LD (HL),A
    LD A,$4A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    LD (HL),A
    POP HL
    RET
.L450F:
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    LD A,($DD69)
    CP $08
    JP NC,.L4430
    CP $04
    JR NZ,.L452C
    LD A,(HL)
    AND $04
    XOR $04
    LD (HL),A
    JR .L4539
.L452C:
    INC (HL)
    LD A,(HL)
    CALL $3374
    JR NC,.L4539
    LD HL,$DD69
    INC (HL)
    JR .L450F
.L4539:
    LD A,$01
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    XOR A
    LD ($D9EF),A
    RET
.L4547:
    LD A,($DD6C)
    CP $02
    JP Z,.L45BB
    CP $10
    JR Z,.L455F
    CP $04
    JR Z,.L455B
    CP $01
    JR NZ,.L455F
.L455B:
    CALL Bank82_fn7
    RET
.L455F:
    LD A,($DB89)
    BIT 2,A
    PUSH AF
    JR Z,.L456B
    LD A,$07
    JR .L456D
.L456B:
    LD A,$03
.L456D:
    LD C,A
    POP AF
    CP C
    JP Z,.L4449
    INC A
    PUSH AF
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    POP AF
    LD (HL),A
    LD ($DB89),A
    LD A,($DB8A)
    CP $95
    JR Z,.L459A
    CP $96
    JR Z,.L459A
    CP $AD
    JR Z,.L459A
    LD A,($DB89)
    CALL $3374
    JR C,.L4547
.L459A:
    LD HL,$DD13
    LD A,($DB88)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$02
    LD A,$01
    LD ($D9ED),A
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    LD A,($DB89)
    LD (HL),A
    RET
.L45BB:
    LD A,($DB89)
    CALL $3345
    JP C,.L4449
    CALL .L7FB1
    LD A,($DB8A)
    LD L,A
    LD H,$06
    LD DE,$C190
    CALL $0D67
    XOR A
    LD ($C822),A
    LD A,$D7
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$40
    LD ($DB4C),A
    LD HL,$5309
    RST $10  ; -> bank83/fn9
    RET
.L45EA:
    XOR A
    LD ($D9ED),A
    LD HL,$D9EC
    INC (HL)
    RET
    DB $21,$06,$5F,$D7,$21,$EE,$D9,$34,$C9,$21,$00,$4C,$D7,$21,$EE,$D9
    DB $34,$C9
.L4605:
    LD A,($DB89)
    LD ($DB4C),A
    LD HL,$5103
    RST $10  ; -> bank81/fn3
    LD A,($C87E)
    OR A
    JR NZ,.L461A
    LD A,($C825)
    OR A
    RET NZ
.L461A:
    LD A,($D9F0)
    CP $01
    JR NZ,.L4625
    LD HL,$5801
    RST $10  ; -> bank88/fn1
.L4625:
    XOR A
    LD ($C87E),A
    LD HL,$5005
    RST $10  ; -> bank80/fn5
    LD A,($DB8A)
    CP $3B
    JR Z,.L4637
    CP $3E
    RET NZ
.L4637:
    LD A,$04
    LD ($D9ED),A
    RET
.L463D:
    LD A,($DB78)
    CP $D5
    JR NZ,.L4649
    LD HL,$5408
    RST $10  ; -> bank84/fn8
    RET
.L4649:
    XOR A
    LD ($D9EF),A
    XOR A
    LD ($D9F0),A
    LD A,$80
    LD ($C8DA),A
    LD A,$10
    LD ($DB88),A
    LD HL,$580D
    RST $10  ; -> bank88/fn13
    LD A,$00
    LD ($DB8A),A
    LD DE,$CA42
    LD HL,$C180
    CALL $106C
    LD A,($DB78)
    SUB $AF
    LD L,A
    LD H,$08
    LD DE,$C190
    CALL $0D67
    LD HL,$C1A0
    LD A,($DB77)
    LD ($DB50),A
    CALL .L7ED6
    LD HL,$5807
    RST $10  ; -> bank88/fn7
    LD A,$18
    LD ($DA33),A
    LD A,($DB4C)
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD A,($DB78)
    CP $C2
    JR C,.L46BE
    CP $C7
    JR NC,.L46BE
    LD A,$01
    LD ($C822),A
    LD A,($DB77)
    CP $04
    JR NZ,.L46BE
    LD A,($DC40)
    CP $D7
    JR NZ,.L46BE
    LD A,$14
    LD ($D9ED),A
.L46BE:
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$D9ED
    INC (HL)
    LD A,($DB77)
    LD ($DB52),A
    LD A,$10
    LD ($DB88),A
    RET
.L46D2:
    LD HL,$C180
    LD A,($DB89)
    LD ($DB50),A
    CALL .L7ED6
    LD A,$BA
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$0C
    LD ($D9ED),A
    LD A,($DB78)
    CP $C2
    RET C
    LD A,$01
    LD ($DB8A),A
    RET
.L46FD:
    LD A,($DB77)
    LD HL,$DB07
    CALL $333B
    LD A,(HL)
    AND $C0
    JR NZ,.L46D2
    LD HL,$D9EF
    INC (HL)
    CALL .L6928
    RET
.L4713:
    LD A,($DA33)
    OR A
    JR Z,.L471E
    DEC A
    LD ($DA33),A
    RET
.L471E:
    LD A,($D9EF)
    OR A
    JR Z,.L4738
    CP $01
    JR Z,.L4776
    CP $02
    JR Z,.L477F
    CP $03
    JR Z,.L46FD
    CP $04
    JP Z,.L47B3
    JP .L47B3
.L4738:
    LD A,($DB77)
    CALL $3374
    JR NC,.L4760
    LD A,($DB78)
    CP $BB
    JR Z,.L4760
.L4747:
    LD A,$00
    LD ($C822),A
    LD A,$BB
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$0C
    LD ($D9ED),A
    LD A,$00
    LD ($DB8A),A
    RET
.L4760:
    LD HL,$D9EF
    INC (HL)
    LD A,($DB77)
    LD ($DB89),A
    LD A,($DB78)
    LD ($DB8A),A
    CALL .L4978
    RET C
    JR .L4747
.L4776:
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD HL,$D9EF
    INC (HL)
    RET
.L477F:
    LD HL,$D9EF
    INC (HL)
    LD HL,$D9F0
    INC (HL)
    LD A,($DD68)
    CP $02
    RET NZ
    LD A,($DB53)
    LD B,A
    LD A,($D9F0)
    CP B
    RET Z
.L4796:
    LD A,($DB89)
    INC A
    LD ($DB89),A
    AND $03
    CP $03
    RET Z
    LD A,($DB89)
    CALL $3374
    JR C,.L4796
    LD HL,$D9EF
    DEC (HL)
    LD HL,$D9EF
    DEC (HL)
    RET
.L47B3:
    XOR A
    LD ($D9F0),A
    LD A,($DD6B)
    OR A
    JR NZ,.L47CB
    LD HL,$D9ED
    INC (HL)
    LD A,$04
    LD ($D9EF),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L47CB:
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    XOR A
    LD ($DD6B),A
    LD A,$0A
    LD ($D9ED),A
    RET
.L47D9:
    LD A,($DB89)
    CALL $3374
    JR C,.L47EB
    LD HL,$D9ED
    INC (HL)
    XOR A
    LD ($DB53),A
    JR .L4837
.L47EB:
    LD A,($DB89)
    AND $03
    CP $03
    JR Z,.L480E
    LD A,($DB77)
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $FF
    JR Z,.L482D
    CALL .L4605
    LD A,($DB77)
    LD ($DD61),A
.L480E:
    LD HL,$C180
    LD A,($DB77)
    LD ($DB50),A
    CALL .L7ED6
    LD A,$E4
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$05
    LD ($DA33),A
.L482D:
    LD A,$0C
    LD ($D9ED),A
    XOR A
    LD ($DB53),A
    RET
.L4837:
    LD A,($DA33)
    OR A
    JR Z,.L4842
    DEC A
    LD ($DA33),A
    RET
.L4842:
    LD A,($DB53)
    OR A
    JR NZ,.L4894
    LD HL,$5006
    RST $10  ; -> bank80/fn6
    LD A,($DB78)
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,$02
    LD ($DB4E),A
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    LD A,($DB4C)
    BIT 0,A
    JR Z,.L4898
.L4867:
    LD A,($DB78)
    CP $C5
    JR NZ,.L4872
    CALL .L48BE
    RET NC
.L4872:
    LD A,($DB78)
    LD B,A
    LD A,$FF
    LD ($DB77),A
    LD A,$FF
    LD ($DB78),A
    LD A,($DB8A)
    OR A
    JR NZ,.L488B
    LD A,B
    CP $C9
    JR NZ,.L4894
.L488B:
    LD HL,$5406
    RST $10  ; -> bank84/fn6
    LD A,($DB53)
    OR A
    RET NZ
.L4894:
    CALL .L4449
    RET
.L4898:
    LD A,($DB77)
    AND $03
    CP $03
    JR Z,.L4867
    LD HL,$DB77
    INC (HL)
    LD A,($DB77)
    CALL $3374
    JR C,.L4898
    JR .L48B4
    DB $C9
.L48B0:
    CALL .L4449
    RET
.L48B4:
    LD A,$0A
    LD ($D9ED),A
    LD HL,$D9EF
    DEC (HL)
    RET
.L48BE:
    CALL $16A3
    LD A,($DD69)
    OR A
    JR NZ,.L48D7
    LD A,($DB77)
    BIT 2,A
    JR Z,.L48D4
    LD C,$04
    JR .L48D8
.L48D2:
    SCF
    RET
.L48D4:
    LD C,A
    JR .L48D8
.L48D7:
    LD C,A
.L48D8:
    LD A,C
    CALL $3374
    JR NC,.L48E8
    INC C
    LD A,C
    AND $03
    CP $02
    JR Z,.L48D2
    JR .L48D8
.L48E8:
    LD A,C
    BIT 2,A
    JR Z,.L48F5
    LD A,C
    LD ($DD69),A
    LD HL,$DD69
    INC (HL)
.L48F5:
    LD A,C
    LD HL,$DD2C
    ADD A,A
    ADD A,C
    ADD A,A
    ADD A,C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $03
    OR A
    JR Z,.L4915
    CP $01
    JR Z,.L4919
    CP $02
    JR Z,.L491D
    LD A,$FF
    JR .L491F
.L4915:
    LD A,$40
    JR .L491F
.L4919:
    LD A,$80
    JR .L491F
.L491D:
    LD A,$C0
.L491F:
    LD HL,$C899
    CP (HL)
    LD A,C
    LD ($DB89),A
    JR NC,.L494D
    LD A,C
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    AND $03
    JR NZ,.L494D
    PUSH BC
    SET 0,(HL)
    CALL .L7FB1
    LD A,$CE
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    POP BC
    LD HL,$5004
    RST $10  ; -> bank80/fn4
.L494D:
    LD A,($DB89)
    CP $04
    RET
.L4953:
    CALL .L4449
    LD A,$00
    LD ($D9ED),A
    RET
.L495C:
    XOR A
    LD ($D9ED),A
    LD A,$01
    LD ($D9EE),A
    RET
.L4966:
    LD HL,$5301
    RST $10  ; -> bank83/fn1
    RET
.L496B:
    LD A,($D9EE)
    RST $00
    DW .L5039                           ; state 0
    DW .L506C                           ; state 1
    DW .L5130                           ; state 2
    DW .L50E5                           ; state 3
.L4977:
    RET
.L4978:
    CP $C2
    RET C
    CP $C7
    JR C,.L4981
.L497F:
    SCF
    RET
.L4981:
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    LD A,(HL+)
    AND $CC
    JR NZ,.L49A0
    INC HL
    INC HL
    LD A,(HL+)
    AND $3F
    JR NZ,.L49A0
    LD A,(HL+)
    AND $0C
    JR NZ,.L49A0
    LD A,(HL)
    AND $C0
    JR Z,.L497F
.L49A0:
    LD HL,$DB89
    INC (HL)
    LD A,(HL)
    CALL $3374
    JR NC,.L4981
    LD A,(HL)
    AND $03
    CP $02
    JR C,.L49A0
    XOR A
    RET
    DB $7E,$E6,$0C,$28,$14,$FE,$04,$28,$0C,$FE,$08,$28,$04,$06,$60,$18
    DB $0A,$06,$A0,$18,$06,$06,$E0,$18,$02,$06,$FF,$FA,$99,$C8,$B8,$28
    DB $1C,$38,$1A,$7E,$E6,$F3,$47,$7E,$E6,$0C,$3D,$C5,$F5,$C1,$CB,$69
    DB $C1,$20,$04,$E6,$0C,$18,$01,$AF,$B0,$77,$3E,$0F,$C9,$7E,$E6,$73
    DB $77,$FA,$88,$DB,$EA,$89,$DB,$21,$04,$50,$D7,$3E,$DB,$C9,$FA,$89
    DB $DB,$21,$07,$DB,$CD,$3B,$33,$7E,$E6,$C0,$28,$0F,$FA,$8A,$DB,$FE
    DB $80,$28,$3B,$FE,$83,$28,$37,$FE,$A5,$28,$33,$2B,$7E,$E6,$0C,$28
    DB $2D,$FA,$8A,$DB,$FE,$3A,$38,$26,$FE,$29,$38,$24,$FE,$44,$38,$1E
    DB $FE,$5A,$38,$1C,$FE,$5B,$28,$18,$FE,$67,$38,$12,$FE,$7E,$38,$10
    DB $FE,$B0,$38,$0A,$FE,$D5,$38,$08,$28,$04,$FE,$DA,$38,$02,$37,$C9
    DB $3E,$C1,$F5,$3E,$06,$EA,$ED,$D9,$FA,$89,$DB,$21,$80,$C1,$EA,$50
    DB $DB,$CD,$D6,$7E,$F1,$EA,$23,$C8,$3E,$00,$EA,$22,$C8,$21,$00,$4C
    DB $D7,$37,$3F,$C9,$FA,$89,$DB,$21,$07,$DB,$CD,$3B,$33,$7E,$E6,$C0
    DB $C8,$3E,$BA,$CD,$55,$4A,$37,$C9
Bank82_fn1:
    LD BC,$0300
.L4A8E:
    LD A,C
    CALL $3374
    JR C,.L4A9F
    LD A,C
    LD HL,$DB02
    CALL $333B
    BIT 6,(HL)
    JR Z,.L4ACC
.L4A9F:
    INC C
    DEC B
    JR NZ,.L4A8E
    LD A,$0E
    LD ($D9EC),A
    LD A,($C86C)
    OR A
    JR Z,.L4AB9
    LD HL,$500A
    RST $10  ; -> bank80/fn10
    LD A,$01
    LD ($DB55),A
    JR .L4B06
.L4AB9:
    LD DE,$CA42
    LD HL,$C180
    CALL $106C
    LD HL,$00EB
    LD A,$01
    LD ($DB55),A
    JR .L4AFA
.L4ACC:
    LD BC,$0304
.L4ACF:
    LD A,C
    CALL $3374
    JR C,.L4AE6
    LD A,($C86C)
    OR A
    JR Z,.L4B3E
    LD A,C
    LD HL,$DB02
    CALL $333B
    BIT 6,(HL)
    JR Z,.L4B3E
.L4AE6:
    INC C
    DEC B
    JR NZ,.L4ACF
    LD A,$00
    LD ($DB55),A
    LD A,$00
    LD ($DB4E),A
    LD HL,$5009
    RST $10  ; -> bank80/fn9
    JR .L4B06
.L4AFA:
    LD A,H
    LD ($C822),A
    LD A,L
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
.L4B06:
    LD C,$69
    LD A,($C863)
    BIT 1,A
    LD A,($DB55)
    JR Z,.L4B17
    XOR $01
    LD ($DB55),A
.L4B17:
    OR A
    JR Z,.L4B21
    LD A,$FF
    LD ($DB73),A
    LD C,$4F
.L4B21:
    PUSH BC
    LD A,$02
    CALL $1EB4
    POP BC
    LD A,C
    CALL $1EFF
    LD A,$00
    LD ($DB4E),A
    LD A,$0A
    LD ($D9EC),A
    SCF
    LD A,($DB55)
    LD ($DD6B),A
    RET
.L4B3E:
    LD A,$FF
    LD ($DD6B),A
    XOR A
    RET
.L4B45:
    LD BC,$0300
    CALL .L4B6B
    JR NC,.L4B58
    INC C
    CALL .L4B6B
    JR NC,.L4B58
    INC C
    CALL .L4B6B
    RET C
.L4B58:
    LD BC,$0304
    CALL .L4B6B
    JR NC,.L4B6A
    INC C
    CALL .L4B6B
    JR NC,.L4B6A
    INC C
    CALL .L4B6B
.L4B6A:
    RET
.L4B6B:
    LD A,($C86C)
    OR A
    JR NZ,.L4B7A
    LD A,C
    CP $04
    JR C,.L4B7A
    CALL $3374
    RET
.L4B7A:
    LD A,C
    CALL $3374
    RET C
    LD A,C
    LD HL,$DB02
    CALL $333B
    BIT 6,(HL)
    RET Z
    SCF
    RET
.L4B8B:
    CALL .L4D5A
    RET C
    LD A,($DB88)
    CALL $3374
    JP C,.L4D3F
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD HL,$5504
    RST $10  ; -> bank85/fn4
    LD HL,$D9EE
    INC (HL)
    RET
.L4BA5:
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    SRL B
    RR C
    SRL B
    RR C
    LD A,C
    LD ($DB5A),A
    LD A,B
    LD ($DB5B),A
    LD A,B
    OR C
    JR NZ,.L4BD2
    INC BC
    LD A,C
    LD ($DB5A),A
    LD A,B
    LD ($DB5B),A
.L4BD2:
    LD A,($DB88)
    LD HL,$DBA3
    CALL .L7E46
    LD D,H
    LD E,L
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    CALL $3314
    LD H,D
    LD L,E
    JR C,.L4BF1
    JR Z,.L4BF1
    LD A,(HL)
    SUB C
    LD (HL+),A
    LD A,(HL)
    SBC A,B
    LD (HL),A
    JR .L4C03
.L4BF1:
    XOR A
    LD (HL-),A
    LD (HL),A
    LD A,$FF
    LD ($D9EF),A
    LD A,$FF
    LD ($D9F0),A
    LD A,$02
    LD ($D9EE),A
.L4C03:
    LD HL,$C190
    LD A,($DB5A)
    LD C,A
    LD A,($DB5B)
    LD B,A
    CALL $0E68
    LD A,$82
    LD ($DB55),A
    CALL .L538E
    CP $04
    JR C,.L4C21
    LD HL,$DB55
    INC (HL)
.L4C21:
    CALL .L4C2B
    CALL Z,.L4C38
    CALL .L4CB7
    RET
.L4C2B:
    LD A,($DB88)
    AND $04
    LD B,A
    LD A,($DB89)
    AND $04
    CP B
    RET
.L4C38:
    LD A,($DB55)
    XOR $01
    LD ($DB55),A
    RET
.L4C41:
    LD A,($DB55)
    CP $85
    RET Z
    CP $E7
    JR Z,.L4C4F
    LD A,$E7
    JR .L4C51
.L4C4F:
    LD A,$EA
.L4C51:
    LD ($DB55),A
    RET
.L4C55:
    CALL .L4D5A
    RET C
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD HL,$5504
    RST $10  ; -> bank85/fn4
    LD HL,$D9EE
    INC (HL)
    RET
.L4C66:
    LD A,($DB88)
    LD HL,$DBA3
    CALL .L7E46
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    DEC BC
    LD A,B
    OR C
    JR Z,.L4C83
    LD A,$03
    LD ($D9EE),A
    LD A,$00
    LD (HL-),A
    LD (HL),$01
    JR .L4CA8
.L4C83:
    XOR A
    LD (HL-),A
    LD (HL),A
    LD A,$FF
    LD ($D9EF),A
    LD A,$03
    LD ($D9F0),A
    LD A,$02
    LD ($D9EE),A
    LD A,$EA
    LD ($DB55),A
    CALL .L538E
    CP $04
    JR NC,.L4CAD
    LD A,$E7
    LD ($DB55),A
    JR .L4CAD
.L4CA8:
    LD A,$85
    LD ($DB55),A
.L4CAD:
    CALL .L4C2B
    CALL Z,.L4C41
    CALL .L4CB7
    RET
.L4CB7:
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L7ED6
    LD A,$00
    LD ($C822),A
    LD A,($DB55)
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$5006
    RST $10  ; -> bank80/fn6
    RET
.L4CE3:
    LD HL,$D9EE
    INC (HL)
    LD A,($D9EF)
    CP $FF
    JR Z,.L4CF1
    LD ($D9ED),A
.L4CF1:
    LD A,($D9F0)
    CP $FF
    JR Z,.L4CFB
    LD ($D9EE),A
.L4CFB:
    XOR A
    LD ($D9EF),A
    LD ($D9F0),A
    CALL Bank82_fn2
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L7ED6
    LD A,$00
    LD ($C822),A
    CALL .L538E
    CP $04
    JR NC,.L4D29
    LD A,$E7
    JR .L4D2B
.L4D29:
    LD A,$EA
.L4D2B:
    LD ($DB55),A
    CALL .L4C2B
    CALL Z,.L4C41
    LD A,($DB55)
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4D3F:
    CALL .L4293
    JP NZ,.L4FAF
.L4D45:
    LD HL,$D9ED
    INC (HL)
    LD A,$00
    LD ($D9EE),A
    JP .L431A
.L4D51:
    LD HL,$D9EE
    INC (HL)
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4D5A:
    LD A,($DB88)
    CALL $3374
    RET NC
    LD HL,$D9ED
    INC (HL)
    SCF
    RET
.L4D67:
    CALL .L4D5A
    RET C
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    LD HL,$5504
    RST $10  ; -> bank85/fn4
    LD HL,$D9EE
    INC (HL)
    RET
.L4D78:
    LD HL,$D9EE
    INC (HL)
    LD HL,$D9EE
    INC (HL)
    LD A,($DB88)
    LD HL,$DBA3
    CALL .L7E46
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    PUSH HL
    CALL .L7D45
    INC HL
    LD A,L
    LD ($DB5A),A
    LD A,H
    LD ($DB5B),A
    POP BC
    LD A,C
    SUB L
    LD C,A
    LD A,B
    SBC A,H
    LD B,A
    JR C,.L4DA8
    OR C
    JR Z,.L4DA8
    JR .L4DAB
.L4DA8:
    LD BC,$0000
.L4DAB:
    POP HL
    LD A,C
    LD (HL+),A
    LD (HL),B
    OR C
    JR NZ,.L4DC5
    LD HL,$D9EE
    DEC (HL)
    LD A,$04
    LD ($D9EF),A
    LD A,$FF
    LD ($D9F0),A
    LD A,$02
    LD ($D9EE),A
.L4DC5:
    CALL .L4C03
    RET
    DB $FA,$69,$DD,$FE,$01,$20,$06,$3E,$01,$EA,$ED,$D9,$C9,$21,$EE,$D9
    DB $34,$C9
Bank82_fn2:
    LD A,($DB88)
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$01
    LD A,($DB89)
    PUSH AF
    LD A,($DB88)
    LD ($DB89),A
    CALL .L4605
    POP AF
    LD ($DB89),A
    LD A,($DB88)
    CP $04
    JR C,.L4E0B
    CP $07
    JR Z,.L4E0B
    LD A,($DB88)
    LD ($DD61),A
.L4E0B:
    RET
.L4E0C:
    LD A,($DB88)
    LD HL,$DB03
    CALL $333B
    BIT 4,(HL)
    JR NZ,.L4E1D
    LD HL,$D9EE
    INC (HL)
.L4E1D:
    LD HL,$D9EE
    INC (HL)
    RET
.L4E22:
    LD A,($DB88)
    LD ($DB89),A
    CALL .L72FD
    RET
.L4E2C:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR Z,.L4E3E
    JR NC,.L4E3E
    CALL .L5897
    RET
.L4E3E:
    LD HL,$D9EE
    INC (HL)
    RET
.L4E43:
    LD HL,$D9EE
    INC (HL)
    CALL .L7FB1
    LD A,$9E
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L4E58:
    LD HL,$5004
    RST $10  ; -> bank80/fn4
    LD HL,$DB89
    INC (HL)
    LD A,(HL)
    LD B,A
    AND $03
    CP $03
    JR Z,.L4E73
    LD A,B
    CALL $3374
    JR Z,.L4E58
    XOR A
    LD ($D9EE),A
    RET
.L4E73:
    LD HL,$D9EE
    INC (HL)
    RET
.L4E78:
    LD A,($DB88)
    LD HL,$DCEC
    CALL .L7E46
    PUSH HL
    LD A,($C899)
    AND $03
    LD HL,$4EC2
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    POP HL
    LD (HL+),A
    LD C,A
    PUSH HL
    LD A,($DB88)
    AND $04
    XOR $04
    LD B,A
    LD A,C
    CP $3A
    JR NZ,.L4EB9
    LD A,($C899)
    AND $03
    ADD A,B
.L4EA8:
    LD B,A
    CALL $3374
    JR NC,.L4EB9
    LD A,B
    AND $03
    JR NZ,.L4EB6
    LD B,A
    OR $03
.L4EB6:
    DEC A
    JR .L4EA8
.L4EB9:
    POP HL
    LD A,B
    LD (HL),A
    LD A,$00
    LD ($D9ED),A
    RET
    DB $3A,$5E,$62,$80,$FF,$F5,$C5,$D5,$E5,$FA,$88,$DB,$21,$05,$DB,$CD
    DB $3B,$33,$7E,$E6,$C0,$77,$E1,$D1,$C1,$F1,$C9
.L4EDD:
    LD A,($DB8A)
    CP $32
    JR Z,.L4EE7
    CP $66
    RET NZ
.L4EE7:
    LD A,($DB88)
    LD HL,$DBC3
    CALL .L7E46
    XOR A
    LD (HL+),A
    LD (HL),A
    RET
.L4EF4:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L4F33
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    LD A,L
    LD ($DB61),A
    LD A,H
    LD ($DB62),A
    LD A,(HL)
    AND $03
    JR NZ,.L4F33
    CALL .L7957
    JR NC,.L4F33
    LD A,($DB61)
    LD L,A
    LD A,($DB62)
    LD H,A
    SET 0,(HL)
    LD A,$CE
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    RET
.L4F33:
    LD HL,$D9EE
    INC (HL)
    RET
.L4F38:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L4F75
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    BIT 7,(HL)
    JR NZ,.L4F75
    CALL .L702E
    JR NC,.L4F75
    CALL .L5601
    LD C,$CC
    CALL .L538E
    CP $04
    JR NC,.L4F63
    INC C
.L4F63:
    LD A,C
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD A,$04
    LD ($D9ED),A
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    RET
.L4F75:
    LD HL,$D9EE
    INC (HL)
    RET
.L4F7A:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L4FAA
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    BIT 6,(HL)
    JR NZ,.L4FAA
    PUSH HL
    CALL .L7943
    POP HL
    JR NC,.L4FAA
    SET 6,(HL)
    LD A,$CF
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$5F06
    RST $10  ; -> bank95/fn6
    RET
.L4FAA:
    LD HL,$D9EE
    INC (HL)
    RET
.L4FAF:
    LD A,($DD6E)
    OR A
    JP NZ,.L424D
    LD A,$13
    LD ($D9ED),A
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD B,A
    CALL $3345
    JP C,.L4D45
    LD A,($DB89)
    LD ($DB50),A
    CALL .L7ED6
    CALL .L68F8
    LD B,$00
    LD A,($DB89)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 3,(HL)
    JR Z,.L4FF5
    LD HL,$C899
    RES 0,(HL)
    LD B,$01
.L4FF5:
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L7ED1
    LD A,H
    OR L
    OR A
    JR NZ,.L500A
    LD A,$01
    LD ($C899),A
.L500A:
    LD A,($C899)
    AND $01
    ADD A,$D5
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    BIT 0,B
    CALL NZ,.L5055
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,($C899)
    AND $01
    LD ($D9EE),A
    LD A,($C899)
    AND $01
    RET Z
    LD A,($D9EE)
    ADD A,$01
    LD ($D9EE),A
    RET
.L5039:
    LD HL,$D9EE
    INC (HL)
    CALL .L505B
    LD A,($DB89)
    CALL $3374
    RET C
    LD HL,$5F04
    RST $10  ; -> bank95/fn4
    LD HL,$5500
    RST $10  ; -> bank85/fn0
    LD A,$80
    LD ($DB54),A
    RET
.L5055:
    LD A,$6A
    LD ($C823),A
    RET
.L505B:
    LD A,($DB88)
    LD L,A
    LD A,($DB89)
    LD H,A
    LD A,L
    LD ($DB89),A
    LD A,H
    LD ($DB88),A
    RET
.L506C:
    LD HL,$D9EE
    INC (HL)
    LD A,($DB89)
    CALL $3374
    JR C,.L505B
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    CALL .L7ED1
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    LD A,H
    OR L
    JR Z,.L50E1
    CALL .L6481
    LD C,$82
    CALL .L538E
    BIT 2,A
    JR NZ,.L509D
    LD C,$83
.L509D:
    LD A,C
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$01
    LD ($DA82),A
    LD A,$00
    LD ($DA83),A
    CALL .L505B
    LD HL,$DBA3
    CALL .L7E46
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    LD A,E
    SUB C
    LD E,A
    LD A,D
    SBC A,B
    LD D,A
    LD (HL),D
    PUSH AF
    DEC HL
    POP BC
    LD (HL),E
    LD A,D
    OR E
    JR Z,.L50D9
    PUSH BC
    POP AF
    RET NC
.L50D9:
    XOR A
    LD (HL+),A
    LD (HL),A
    LD HL,$D9EE
    INC (HL)
    RET
.L50E1:
    CALL .L64E2
    RET
.L50E5:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB88)
    LD ($DB50),A
    CALL .L7ED6
    LD A,$00
    LD ($C822),A
    LD B,$E3
    LD A,($DB88)
    RRCA
    RRCA
    AND $01
    ADD A,B
    LD ($C823),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD HL,$D9EE
    DEC (HL)
    LD A,($DB88)
    LD ($DB4C),A
    LD HL,$5103
    RST $10  ; -> bank81/fn3
    LD A,($DB89)
    PUSH AF
    LD A,($DB88)
    LD ($DB89),A
    LD HL,$5801
    RST $10  ; -> bank88/fn1
    POP AF
    LD ($DB89),A
    RET
.L5130:
    LD A,$05
    LD ($D9ED),A
    XOR A
    LD ($D9EE),A
    RET
.L513A:
    LD HL,$5701
    RST $10  ; -> bank87/fn1
    RET
.L513F:
    LD A,($DD6D)
    CP $02
    JR NZ,.L518B
    LD A,($DB89)
    RRCA
    RRCA
    AND $01
    LD HL,$DB00
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    BIT 5,(HL)
    JR Z,.L518B
    LD A,($DB89)
    LD E,A
    AND $04
    LD C,A
    CP $04
    JR C,.L516A
    LD A,($DB75)
    JR .L516D
.L516A:
    LD A,($DB74)
.L516D:
    LD B,A
.L516E:
    LD A,C
    CP E
    JR Z,.L5174
    JR NC,.L517A
.L5174:
    INC C
    DEC B
    JR NZ,.L516E
    JR .L518B
.L517A:
    LD A,C
    CALL $3374
    JR NC,.L5186
    INC C
    DEC B
    JR NZ,.L517A
    JR .L518B
.L5186:
    XOR A
    LD ($DD6D),A
    RET
.L518B:
    LD HL,$4C03
    RST $10  ; -> bank76/fn3
    RET
.L5190:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    RET
.L519A:
    LD A,($DB8A)
    CP $7F
    JR NZ,.L51A3
.L51A1:
    XOR A
    RET
.L51A3:
    LD A,($DD6E)
    OR A
    JR NZ,.L51A1
    LD A,($DD6C)
    OR A
    JR Z,.L51BC
    CP $08
    JR Z,.L51A1
    CP $20
    JR NZ,.L51A1
    CALL Bank82_fn7
    JR .L51A1
.L51BC:
    LD A,($DB88)
    LD HL,$DB06
    CALL $333B
    LD A,(HL)
    AND $0C
    CP $0C
    RET Z
    LD A,($DCFC)
    BIT 4,A
    JR Z,.L51A1
    LD A,($DB89)
    LD HL,$DB08
    CALL $333B
    BIT 3,(HL)
    JR Z,.L51A1
    LD A,($DB89)
    CALL $3345
    JR C,.L51A1
    LD A,($DCFF)
    BIT 2,A
    JR Z,.L5207
    LD A,$D3
    CALL .L5237
    LD A,$08
    LD ($DD6C),A
    LD A,$08
    LD ($DB4C),A
    LD HL,$5309
    RST $10  ; -> bank83/fn9
    XOR A
    LD ($C1C9),A
    SCF
    RET
.L5207:
    LD A,$D4
    CALL .L5237
    XOR A
    RET
    DB $FA,$89,$DB,$21,$03,$DB,$CD,$3B,$33,$FA,$FD,$DC,$CB,$77,$20,$09
    DB $CB,$6F,$20,$0F,$CB,$67,$20,$0E,$C9,$CB,$46,$20,$DC,$FA,$00,$DB
    DB $CB,$5F,$C9,$CB,$76,$C9,$CB,$7E,$C9
.L5237:
    PUSH AF
    CALL .L7FB1
    POP AF
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L5248:
    LD A,($DD6E)
    OR A
    RET Z
    CP $01
    JR Z,.L5259
    LD A,($DD6D)
    CP $02
    JR Z,.L526A
    RET
.L5259:
    CALL .L526A
    LD HL,$DB08
    CALL $333B
    RES 4,(HL)
    INC HL
    LD A,(HL)
    AND $0F
    LD (HL),A
    RET
.L526A:
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    LD A,(HL)
    LD ($DB89),A
    RET
.L5278:
    LD A,$BB
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    LD A,$01
    LD ($DB8A),A
    LD A,$FF
    LD ($DB77),A
    LD A,$FF
    LD ($DB78),A
    LD HL,$5406
    RST $10  ; -> bank84/fn6
    CALL .L4449
    RET
.L529C:
    LD HL,$5700
    RST $10  ; -> bank87/fn0
    RET
.L52A1:
    LD HL,$580C
    RST $10  ; -> bank88/fn12
    RET
.L52A6:
    LD HL,$510F
    RST $10  ; -> bank81/fn15
    RET
.L52AB:
    LD A,($C825)
    OR A
    RET NZ
    CALL .L44D1
    RET
Bank82_fn7:
    LD A,($DD6C)
    OR A
    JP Z,.L538C
    LD HL,$C1C0
    LD A,(HL+)
    LD ($DB88),A
    LD A,(HL+)
    LD ($DB89),A
    LD A,(HL+)
    LD ($DD69),A
    LD A,($DB88)
    LD DE,$DCEC
    ADD A,A
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
    LD A,($DB89)
    LD DE,$DCEC
    ADD A,A
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
    LD A,($DB89)
    LD DE,$DD13
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(HL)
    LD (DE),A
    LD A,($DD6C)
    CP $40
    JP Z,.L538C
    CP $01
    JR Z,.L5361
    CP $02
    JR Z,.L5318
    CP $04
    CALL Z,.L5375
.L5311:
    LD A,$00
    LD ($DD6C),A
    XOR A
    RET
.L5318:
    LD A,($DB89)
    RRCA
    RRCA
    AND $01
    LD HL,$DB4A
    ADD A,L
    LD L,A
    LD A,(HL)
    RRCA
    RRCA
    AND $03
    LD L,A
    LD A,($DB89)
    AND $04
    OR L
    LD ($DB4C),A
    CALL $3345
    JR C,.L5346
    LD A,($DB4C)
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    AND $C0
    JR Z,.L5311
.L5346:
    LD A,($DB89)
    OR $03
    LD ($DB89),A
    LD A,($DB88)
    LD HL,$DCED
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    OR $03
    LD (HL),A
    JR .L538C
.L5361:
    LD A,$D9
    LD ($C823),A
    LD A,$00
    LD ($C822),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    XOR A
    LD ($DD6D),A
    JR .L5311
.L5375:
    LD A,($DD6D)
    CP $07
    RET NZ
    LD A,$DE
    LD ($C823),A
    XOR A
    LD ($C822),A
    LD ($DD6D),A
    LD HL,$4C00
    RST $10  ; -> bank76/fn0
    RET
.L538C:
    SCF
    RET
.L538E:
    LD A,($C863)
    BIT 1,A
    LD A,($DB89)
    RET Z
    LD A,($DB88)
    RET
.L539B:
    LD A,($DB88)
    AND $04
    XOR $04
    LD C,A
    LD B,$03
.L53A5:
    LD A,C
    CALL $3374
    RET NC
    INC C
    DEC B
    JR NZ,.L53A5
    SCF
    RET
    DB $6C,$55,$6C,$55,$6C,$55,$73,$55,$73,$55,$73,$55,$7A,$55,$7A,$55
    DB $7A,$55,$81,$55,$81,$55,$81,$55,$88,$55,$88,$55,$88,$55,$8F,$55
    DB $8F,$55,$8F,$55,$96,$55,$96,$55,$CA,$55,$D4,$55,$D4,$55,$1B,$56
    DB $49,$56,$77,$56,$A7,$56,$CF,$56,$E9,$56,$E9,$56,$0C,$57,$0C,$57
    DB $24,$57,$24,$57,$47,$57,$47,$57,$5F,$57,$9A,$57,$B4,$57,$D3,$57
    DB $D3,$57,$0B,$58,$1E,$58,$63,$58,$63,$58,$63,$58,$63,$58,$63,$58
    DB $97,$58,$97,$58,$1D,$59,$2E,$59,$46,$59,$77,$59,$9D,$59,$C4,$59
    DB $C4,$59,$B5,$59,$C4,$59,$CE,$59,$EB,$59,$F2,$59,$1B,$5A,$22,$5A
    DB $22,$5A,$5D,$5A,$6E,$5A,$AE,$5A,$BF,$5A,$C9,$5A,$D3,$5A,$DD,$5A
    DB $E7,$5A,$F1,$5A,$FB,$5A,$05,$5B,$0F,$5B,$19,$5B,$23,$5B,$2D,$5B
    DB $37,$5B,$37,$5B,$AB,$5B,$AB,$5B,$27,$5C,$36,$5C,$CE,$59,$53,$5C
    DB $B7,$5C,$B7,$5C,$8F,$55,$CA,$5C,$D1,$5C,$D1,$5C,$D1,$5C,$D1,$5C
    DB $DB,$5C,$DB,$5C,$DB,$5C,$DB,$5C,$8F,$55,$E5,$5C,$EC,$5C,$C4,$59
    DB $C4,$59,$C4,$59,$D4,$55,$F3,$5C,$1A,$5D,$1A,$5D,$77,$56,$71,$5D
    DB $9F,$5D,$96,$55,$C1,$5D,$C1,$5D,$F6,$5D,$1A,$5E,$A7,$56,$42,$5E
    DB $64,$5E,$86,$5E,$86,$5E,$D3,$5E,$D3,$5E,$07,$5F,$C4,$59,$31,$5F
    DB $40,$5F,$4A,$5F,$55,$5F,$40,$5F,$6F,$5F,$6F,$5F,$6F,$5F,$6F,$5F
    DB $D0,$5F,$D0,$5F,$DA,$5F,$DA,$5F,$11,$60,$20,$60,$20,$60,$44,$60
    DB $20,$60,$7B,$60,$A9,$60,$D7,$60,$63,$58,$31,$61,$88,$61,$C4,$59
    DB $A9,$61,$29,$62,$43,$62,$5D,$62,$82,$62,$82,$62,$77,$62,$86,$62
    DB $86,$62,$D9,$61,$98,$62,$CB,$62,$98,$62,$40,$5F,$D4,$62,$F3,$62
    DB $1E,$63,$82,$62,$AD,$61,$40,$63,$6B,$63,$97,$58,$9B,$63,$BE,$63
    DB $C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59
    DB $C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59
    DB $C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59
    DB $C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59
    DB $C4,$59,$C4,$59,$C4,$59,$C4,$59,$C4,$59,$AD,$61,$B4,$61,$BE,$61
    DB $C8,$61,$D2,$61,$77,$56,$D9,$61,$18,$58,$0C,$62,$CD,$9E,$6F,$CD
    DB $86,$68,$C9,$CD,$AC,$6F,$CD,$86,$68,$C9,$CD,$BA,$6F,$CD,$86,$68
    DB $C9,$CD,$C6,$6F,$CD,$86,$68,$C9,$CD,$E2,$6F,$CD,$86,$68,$C9,$CD
    DB $D4,$6F,$CD,$86,$68,$C9,$AF,$EA,$F0,$D9,$CD,$F0,$6F,$30,$25,$FA
    DB $89,$DB,$21,$1B,$DD,$85,$6F,$3E,$00,$8C,$67,$36,$01,$21,$E8,$B8
    DB $CD,$4E,$68,$E5,$FA,$89,$DB,$21,$A3,$DB,$CD,$46,$7E,$3E,$00,$22
    DB $36,$00,$E1,$C9,$3E,$B8,$CD,$FC,$67,$C9,$3E,$03,$EA,$ED,$D9,$AF
    DB $EA,$EE,$D9,$C9,$21,$80,$C1,$7D,$EA,$4E,$DB,$7C,$EA,$4F,$DB,$FA
    DB $89,$DB,$EA,$50,$DB,$CD,$D6,$7E,$FA,$89,$DB,$21,$02,$DB,$CD,$3B
    DB $33,$7E,$E6,$8C,$20,$1F,$CD,$2E,$70,$30,$14,$21,$CC,$BC,$CD,$71
    DB $68
.L5601:
    LD A,($DB89)
    LD HL,$DB02
    CALL $333B
    LD A,(HL)
    OR $8C
    LD (HL),A
    RET
    DB $3E,$BC,$CD,$FC,$67,$C9,$3E,$BD,$CD,$14,$68,$C9,$FA,$89,$DB,$21
    DB $03,$DB,$CD,$3B,$33,$CB,$46,$20,$17,$CD,$5B,$70,$30,$16,$FA,$89
    DB $DB,$21,$03,$DB,$CD,$3B,$33,$CB,$C6,$21,$88,$B8,$CD,$71,$68,$C9
    DB $CD,$2C,$68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$FA,$89,$DB,$21,$03,$DB
    DB $CD,$3B,$33,$CB,$4E,$20,$17,$CD,$79,$70,$30,$16,$FA,$89,$DB,$21
    DB $03,$DB,$CD,$3B,$33,$CB,$CE,$21,$98,$B8,$CD,$32,$68,$C9,$CD,$2C
    DB $68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$FA,$89,$DB,$21,$02,$DB,$CD,$3B
    DB $33,$CB,$66,$28,$06,$3E,$BE,$CD,$14,$68,$C9,$CD,$A4,$70,$30,$12
    DB $FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$CB,$E6,$21,$8E,$B8,$CD,$4E
    DB $68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$FA,$89,$DB,$21,$C3,$DB,$CD,$46
    DB $7E,$2A,$B6,$28,$15,$CD,$C4,$70,$30,$0A,$CD,$E7,$70,$21,$8A,$B8
    DB $CD,$4E,$68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$3E,$BB,$CD,$FC,$67,$C9
    DB $FA,$88,$DB,$21,$04,$DB,$CD,$3B,$33,$CB,$46,$20,$09,$CB,$C6,$21
    DB $00,$8C,$CD,$40,$68,$C9,$CD,$2C,$68,$C9,$CD,$6B,$71,$30,$18,$CD
    DB $9B,$71,$30,$0D,$FA,$89,$DB,$CD,$16,$67,$21,$86,$B8,$CD,$4E,$68
    DB $C9,$3E,$BB,$CD,$14,$68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$CD,$DD,$71
    DB $30,$0D,$21,$92,$92,$CD,$32,$68,$FA,$89,$DB,$CD,$0B,$67,$C9,$3E
    DB $BB,$CD,$14,$68,$C9,$CD,$33,$72,$30,$18,$CD,$53,$72,$30,$0D,$FA
    DB $89,$DB,$CD,$16,$67,$21,$95,$B8,$CD,$4E,$68,$C9,$3E,$BB,$CD,$14
    DB $68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$CD,$A7,$72,$30,$0D,$21,$97,$97
    DB $CD,$32,$68,$FA,$89,$DB,$CD,$0B,$67,$C9,$3E,$BB,$CD,$14,$68,$C9
    DB $FA,$89,$DB,$E6,$04,$4F,$06,$04,$16,$00,$79,$21,$04,$DB,$CD,$3B
    DB $33,$79,$CD,$74,$33,$38,$1C,$CB,$56,$20,$03,$14,$CB,$D6,$0C,$05
    DB $20,$E8,$7A,$B7,$28,$11,$21,$03,$58,$D7,$FA,$72,$DD,$C6,$09,$CD
    DB $20,$68,$C9,$CB,$96,$18,$E7,$CD,$2C,$68,$C9,$FA,$89,$DB,$21,$03
    DB $DB,$CD,$3B,$33,$CB,$56,$20,$09,$CB,$D6,$21,$90,$90,$CD,$5C,$68
    DB $C9,$CD,$2C,$68,$C9,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$79,$CD,$74
    DB $33,$38,$09,$79,$21,$05,$DB,$CD,$3B,$33,$CB,$F6,$0C,$05,$20,$ED
    DB $CD,$2C,$68,$C9,$FA,$88,$DB,$21,$04,$DB,$CD,$3B,$33,$FA,$8A,$DB
    DB $FE,$28,$28,$11,$CB,$6E,$20,$1E,$7E,$E6,$DD,$F6,$20,$77,$21,$99
    DB $99,$CD,$5C,$68,$C9,$CB,$4E,$20,$0D,$7E,$E6,$DD,$F6,$02,$77,$21
    DB $9A,$9A,$CD,$32,$68,$C9,$3E,$BB,$CD,$14,$68,$C9,$FA,$88,$DB,$CD
    DB $21,$67,$21,$A0,$A0,$CD,$5C,$68,$C9,$FA,$88,$DB,$EA,$89,$DB,$FA
    DB $6C,$C8,$B7,$20,$17,$FA,$89,$DB,$CB,$57,$28,$10,$21,$07,$DB,$CD
    DB $3B,$33,$E5,$E1,$06,$01,$FA,$89,$DB,$4F,$18,$0E,$06,$04,$FA,$89
    DB $DB,$E6,$04,$4F,$21,$07,$DB,$CD,$3B,$33,$79,$CD,$74,$33,$38,$04
    DB $7E,$F6,$C0,$77,$3E,$08,$85,$6F,$3E,$00,$8C,$67,$0C,$05,$20,$EA
    DB $CD,$A5,$68,$C9,$FA,$89,$DB,$CD,$74,$33,$30,$06,$3E,$BB,$CD,$FC
    DB $67,$C9,$FA,$89,$DB,$21,$A3,$DB,$CD,$46,$7E,$2A,$46,$4F,$3E,$0F
    DB $85,$6F,$3E,$00,$8C,$67,$2A,$66,$6F,$CD,$14,$33,$28,$DE,$CD,$11
    DB $74,$21,$84,$BB,$CD,$97,$68,$C9
.L5897:
    LD A,($DB89)
    CALL $3374
    JR NC,.L590C
    JR Z,.L5919
    LD A,($DB8A)
    CP $30
    JR NZ,.L58D9
    CALL .L68F8
    LD A,($C899)
    CP $80
    JR NC,.L5906
    JR .L58D9
.L58B4:
    LD A,($DB88)
    AND $04
    LD C,A
    OR $03
    LD B,A
.L58BD:
    LD A,C
    CALL $3374
    JR Z,.L58C5
    JR C,.L58CC
.L58C5:
    INC A
    LD C,A
    CP B
    JR C,.L58BD
    JR .L5913
.L58CC:
    LD ($DB89),A
    LD A,($DB88)
    LD HL,$DCED
    CALL .L7E46
    LD (HL),C
.L58D9:
    LD A,($DB89)
    LD B,A
    LD HL,$DBB3
    CALL .L7E46
    LD A,(HL+)
    LD D,(HL)
    LD E,A
    LD A,($DB8A)
    CP $30
    JR NZ,.L58F1
    SRL D
    RR E
.L58F1:
    LD A,B
    LD HL,$DBA3
    CALL .L7E46
    LD A,E
    LD (HL+),A
    LD (HL),D
    LD A,B
    CALL .L657C
    LD HL,$9E9E
    CALL .L685C
    RET
.L5906:
    LD A,$C0
    CALL .L67FC
    RET
.L590C:
    LD A,($DB8A)
    CP $30
    JR NZ,.L58B4
.L5913:
    LD A,$BB
    CALL .L67FC
    RET
.L5919:
    CALL .L682C
    RET
    DB $3E,$04,$EA,$ED,$D9,$AF,$EA,$EE,$D9,$EA,$72,$DD,$AF,$EA,$EF,$D9
    DB $C9,$CD,$3D,$65,$E6,$03,$28,$0B,$7E,$E6,$FC,$77,$21,$9C,$9C,$CD
    DB $5C,$68,$C9,$3E,$BB,$CD,$FC,$67,$C9,$CD,$3D,$65,$E6,$CC,$28,$24
    DB $E5,$CB,$76,$28,$05,$21,$9D,$9D,$18,$03,$21,$DB,$DB,$CD,$5C,$68
    DB $E1,$7E,$E6,$33,$77,$FA,$89,$DB,$21,$13,$DD,$85,$6F,$3E,$00,$8C
    DB $67,$36,$03,$C9,$3E,$BB,$CD,$FC,$67,$C9,$CD,$3D,$65,$E6,$10,$28
    DB $19,$7E,$E6,$EF,$77,$FA,$89,$DB,$21,$13,$DD,$85,$6F,$3E,$00,$8C
    DB $67,$36,$03,$21,$DC,$DC,$CD,$5C,$68,$C9,$3E,$BB,$CD,$FC,$67,$C9
    DB $CD,$3D,$65,$E6,$20,$28,$0B,$7E,$E6,$DF,$77,$21,$9F,$9F,$CD,$5C
    DB $68,$C9,$3E,$BB,$CD,$FC,$67,$C9,$21,$03,$53,$D7,$3E,$00,$EA,$6B
    DB $DD,$3E,$01,$EA,$ED,$D9,$C9,$CD,$39,$65,$21,$82,$B6,$CD,$89,$68
    DB $C9,$CD,$39,$65,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$07,$7D,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$A8
    DB $75,$CD,$86,$68,$C9,$FA,$88,$DB,$21,$08,$DB,$CD,$3B,$33,$CB,$D6
    DB $CD,$39,$65,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CB,$25,$CB,$14,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$C6
    DB $75,$CD,$86,$68,$C9,$FA,$89,$DB,$CD,$74,$33,$38,$29,$FA,$8A,$DB
    DB $FE,$3F,$28,$10,$FA,$89,$DB,$CD,$45,$33,$38,$08,$06,$A0,$FA,$99
    DB $C8,$B8,$38,$16,$FA,$88,$DB,$21,$04,$DB,$CD,$3B,$33,$CB,$FE,$21
    DB $82,$B6,$CD,$89,$68,$C9,$CD,$2C,$68,$C9,$3E,$78,$CD,$FC,$67,$C9
    DB $FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$F6,$03,$77,$CD,$2C,$68
    DB $C9,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$E6,$0C,$20,$11,$7E
    DB $F6,$0C,$77,$CD,$2C,$68,$AF,$EA,$EE,$D9,$3E,$06,$EA,$ED,$D9,$C9
    DB $7E,$E6,$F3,$77,$CD,$39,$65,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD
    DB $07,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$21,$82,$B6,$CD,$89,$68
    DB $C9,$FA,$88,$DB,$21,$06,$DB,$CD,$3B,$33,$7E,$F6,$30,$77,$CD,$2C
    DB $68,$C9,$CD,$26,$76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$37,$76,$21
    DB $82,$B6,$CD,$89,$68,$C9,$CD,$48,$76,$21,$82,$B6,$CD,$89,$68,$C9
    DB $CD,$59,$76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$6A,$76,$21,$82,$B6
    DB $CD,$89,$68,$C9,$CD,$9F,$76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$AD
    DB $76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$BB,$76,$21,$82,$B6,$CD,$89
    DB $68,$C9,$CD,$E5,$76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$F3,$76,$21
    DB $82,$B6,$CD,$89,$68,$C9,$CD,$01,$77,$21,$82,$B6,$CD,$89,$68,$C9
    DB $CD,$0F,$77,$21,$82,$B6,$CD,$89,$68,$C9,$FA,$8A,$DB,$FE,$51,$28
    DB $0D,$FA,$89,$DB,$CD,$74,$33,$DC,$A6,$5B,$16,$00,$18,$0F,$FA,$88
    DB $DB,$21,$ED,$DC,$CD,$46,$7E,$7E,$EA,$89,$DB,$16,$01,$FA,$88,$DB
    DB $21,$E3,$DB,$CD,$46,$7E,$7D,$EA,$63,$DB,$7C,$EA,$64,$DB,$2A,$66
    DB $6F,$E5,$7A,$B7,$20,$05,$CD,$54,$7D,$18,$09,$CD,$D1,$7E,$44,$4D
    DB $CD,$BC,$7E,$09,$FA,$63,$DB,$4F,$FA,$64,$DB,$47,$7D,$02,$03,$7C
    DB $02,$CD,$39,$65,$E1,$FA,$63,$DB,$4F,$FA,$64,$DB,$47,$7D,$02,$03
    DB $7C,$02,$21,$82,$B6,$CD,$89,$68,$C9,$21,$0A,$58,$D7,$C9,$FA,$69
    DB $DD,$FE,$01,$20,$58,$CD,$F8,$68,$FA,$99,$C8,$E6,$01,$28,$3C,$3E
    DB $03,$EA,$EF,$D9,$3E,$0F,$EA,$69,$DD,$AF,$EA,$EE,$D9,$EA,$22,$C8
    DB $3E,$A1,$EA,$23,$C8,$21,$00,$4C,$D7,$FA,$88,$DB,$21,$08,$DB,$CD
    DB $3B,$33,$CB,$C6,$FA,$6C,$C8,$B7,$C0,$FA,$88,$DB,$FE,$04,$D8,$21
    DB $69,$DD,$34,$FA,$8A,$DB,$FE,$52,$C8,$34,$C9,$3E,$FF,$EA,$69,$DD
    DB $AF,$EA,$56,$DB,$EA,$57,$DB,$3E,$C2,$CD,$FC,$67,$C9,$FA,$88,$DB
    DB $21,$ED,$DC,$CD,$46,$7E,$7E,$EA,$89,$DB,$CD,$74,$33,$DA,$97,$64
    DB $CD,$6A,$77,$21,$82,$B6,$CD,$89,$68,$C9,$FA,$88,$DB,$21,$06,$DB
    DB $CD,$3B,$33,$CB,$FE,$CD,$2C,$68,$C9,$CD,$39,$65,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$CD,$45,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$21
    DB $82,$B6,$CD,$89,$68,$C9,$FA,$69,$DD,$FE,$05,$30,$59,$FA,$89,$DB
    DB $CD,$74,$33,$38,$32,$CD,$39,$65,$FA,$56,$DB,$6F,$FA,$57,$DB,$67
    DB $FA,$69,$DD,$FE,$01,$28,$09,$FE,$02,$28,$0A,$CD,$6F,$7D,$18,$08
    DB $CD,$45,$7D,$18,$03,$CD,$60,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB
    DB $21,$82,$B6,$CD,$89,$68,$C9,$FA,$89,$DB,$E6,$04,$F6,$02,$47,$FA
    DB $89,$DB,$B8,$28,$11,$3C,$EA,$89,$DB,$FA,$88,$DB,$21,$ED,$DC,$CD
    DB $46,$7E,$FA,$89,$DB,$77,$CD,$2C,$68,$C9,$FA,$8A,$DB,$FE,$59,$28
    DB $05,$CD,$A8,$77,$18,$03,$CD,$1F,$78,$CD,$86,$68,$C9,$CD,$94,$78
    DB $CD,$86,$68,$C9,$CD,$A2,$78,$CD,$D8,$68,$CD,$86,$68,$C9,$CD,$B0
    DB $78,$CD,$D8,$68,$CD,$86,$68,$C9,$CD,$BE,$78,$CD,$86,$68,$C9,$CD
    DB $CC,$78,$CD,$86,$68,$C9,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$CB
    DB $76,$20,$16,$E5,$CD,$43,$79,$E1,$38,$06,$3E,$C3,$CD,$08,$68,$C9
    DB $CB,$F6,$21,$CF,$CF,$CD,$5C,$68,$C9,$CD,$2C,$68,$C9,$FA,$89,$DB
    DB $21,$02,$DB,$CD,$3B,$33,$FA,$8A,$DB,$FE,$6D,$28,$0C,$3E,$CE,$EA
    DB $4C,$DB,$7E,$E6,$03,$20,$39,$18,$09,$3E,$D0,$EA,$4C,$DB,$CB,$4E
    DB $20,$2E,$CD,$57,$79,$38,$06,$3E,$C3,$CD,$08,$68,$C9,$FA,$89,$DB
    DB $21,$02,$DB,$CD,$3B,$33,$FA,$8A,$DB,$FE,$6D,$28,$06,$CB,$C6,$CB
    DB $8E,$18,$04,$CB,$CE,$CB,$86,$FA,$4C,$DB,$67,$6F,$CD,$5C,$68,$C9
    DB $CD,$2C,$68,$C9,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$CB,$6E,$20
    DB $1D,$CD,$63,$79,$38,$06,$3E,$B8,$CD,$08,$68,$C9,$FA,$89,$DB,$21
    DB $02,$DB,$CD,$3B,$33,$CB,$EE,$21,$D1,$D1,$CD,$5C,$68,$C9,$CD,$2C
    DB $68,$C9,$CD,$C1,$67,$CB,$6E,$20,$11,$CD,$71,$79,$30,$10,$CD,$C1
    DB $67,$CB,$EE,$21,$A7,$A7,$CD,$32,$68,$C9,$CD,$2C,$68,$C9,$3E,$B8
    DB $CD,$08,$68,$C9,$FA,$89,$DB,$21,$07,$DB,$CD,$3B,$33,$7E,$E6,$03
    DB $20,$23,$CD,$79,$70,$30,$18,$FA,$89,$DB,$21,$07,$DB,$CD,$3B,$33
    DB $CB,$CE,$CB,$C6,$FA,$8A,$DB,$C6,$30,$67,$6F,$CD,$32,$68,$C9,$3E
    DB $B8,$CD,$08,$68,$C9,$CD,$2C,$68,$C9,$CD,$C1,$67,$CB,$7E,$20,$11
    DB $CD,$F0,$6F,$30,$12,$CD,$C1,$67,$CB,$FE,$21,$A4,$A4,$CD,$32,$68
    DB $C9,$3E,$BB,$CD,$14,$68,$C9,$3E,$B8,$CD,$08,$68,$C9,$FA,$89,$DB
    DB $21,$C3,$DB,$CD,$46,$7E,$2A,$B6,$28,$15,$CD,$C4,$70,$30,$0A,$CD
    DB $19,$71,$21,$A5,$A5,$CD,$32,$68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$3E
    DB $BB,$CD,$FC,$67,$C9,$CD,$F8,$68,$FA,$88,$DB,$21,$07,$DB,$CD,$3B
    DB $33,$7E,$E6,$0C,$20,$0D,$FA,$99,$C8,$E6,$04,$C6,$04,$47,$7E,$E6
    DB $F3,$B0,$77,$CD,$2C,$68,$C9,$CD,$C1,$67,$CB,$4E,$20,$17,$CD,$71
    DB $79,$30,$0C,$CD,$C1,$67,$CB,$CE,$21,$A6,$A6,$CD,$32,$68,$C9,$3E
    DB $C8,$CD,$FC,$67,$C9,$CD,$2C,$68,$C9,$CD,$C1,$67,$CB,$5E,$20,$42
    DB $FA,$8A,$DB,$FE,$7A,$28,$05,$CD,$71,$79,$18,$03,$CD,$6B,$71,$30
    DB $2B,$CD,$C1,$67,$CB,$DE,$FA,$8A,$DB,$FE,$79,$28,$14,$FA,$89,$DB
    DB $21,$F3,$DB,$CD,$46,$7E,$3E,$01,$22,$36,$00,$FA,$89,$DB,$CD,$16
    DB $67,$FA,$8A,$DB,$C6,$2F,$67,$6F,$CD,$5C,$68,$C9,$3E,$CA,$CD,$08
    DB $68,$C9,$CD,$2C,$68,$C9,$CD,$C1,$67,$CB,$56,$20,$11,$CD,$8D,$79
    DB $30,$10,$CD,$C1,$67,$CB,$D6,$21,$AB,$AB,$CD,$5C,$68,$C9,$CD,$2C
    DB $68,$C9,$FA,$89,$DB,$21,$8B,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$66
    DB $3E,$C9,$28,$02,$3E,$C1,$CD,$FC,$67,$C9,$FA,$89,$DB,$CD,$74,$33
    DB $38,$18,$CD,$C1,$67,$CB,$66,$20,$11,$CD,$71,$79,$30,$10,$CD,$C1
    DB $67,$CB,$E6,$21,$AA,$AA,$CD,$5C,$68,$C9,$CD,$2C,$68,$C9,$3E,$CA
    DB $CD,$08,$68,$C9,$FA,$88,$DB,$21,$08,$DB,$CD,$3B,$33,$CB,$DE,$CD
    DB $2C,$68,$C9,$3E,$03,$EA,$ED,$D9,$AF,$EA,$EE,$D9,$C9,$21,$0A,$53
    DB $D7,$21,$AE,$AE,$CD,$32,$68,$C9,$CD,$F0,$6F,$30,$0F,$CD,$A0,$79
    DB $30,$0A,$AF,$EA,$EE,$D9,$3E,$03,$EA,$ED,$D9,$C9,$3E,$B8,$CD,$FC
    DB $67,$C9,$CD,$F8,$68,$FA,$88,$DB,$0F,$0F,$E6,$01,$21,$00,$DB,$85
    DB $6F,$3E,$00,$8C,$67,$CB,$56,$20,$3E,$3E,$C0,$47,$FA,$99,$C8,$B8
    DB $30,$3B,$CB,$D6,$FA,$8A,$DB,$CD,$D6,$79,$FA,$4C,$DB,$21,$1B,$DD
    DB $85,$6F,$3E,$00,$8C,$67,$36,$00,$FA,$4C,$DB,$21,$3C,$DC,$85,$6F
    DB $3E,$00,$8C,$67,$FA,$8A,$DB,$C6,$54,$77,$FA,$4C,$DB,$EA,$89,$DB
    DB $21,$AF,$AF,$CD,$32,$68,$C9,$3E,$BB,$CD,$14,$68,$C9,$3E,$CB,$CD
    DB $FC,$67,$C9,$3E,$03,$EA,$ED,$D9,$AF,$EA,$EE,$D9,$C9,$FA,$89,$DB
    DB $21,$04,$DB,$CD,$3B,$33,$CB,$F6,$FA,$8A,$DB,$FE,$8A,$28,$21,$FA
    DB $89,$DB,$E6,$03,$FE,$02,$28,$06,$21,$89,$DB,$34,$18,$DF,$FA,$89
    DB $DB,$1F,$1F,$E6,$01,$21,$00,$DB,$85,$6F,$3E,$00,$8C,$67,$CB,$EE
    DB $CD,$2C,$68,$C9,$FA,$88,$DB,$21,$08,$DB,$CD,$3B,$33,$CB,$EE,$CD
    DB $2C,$68,$C9,$FA,$88,$DB,$21,$09,$DB,$CD,$3B,$33,$FA,$8A,$DB,$FE
    DB $90,$28,$0A,$D6,$8C,$47,$7E,$E6,$F0,$B0,$77,$18,$06,$7E,$E6,$F0
    DB $F6,$04,$77,$CD,$2C,$68,$C9,$FA,$88,$DB,$FE,$04,$38,$05,$21,$01
    DB $DB,$18,$03,$21,$00,$DB,$CB,$76,$20,$20,$CB,$F6,$3E,$4A,$85,$6F
    DB $3E,$00,$8C,$67,$FA,$88,$DB,$E6,$03,$17,$17,$47,$7E,$B0,$77,$FA
    DB $88,$DB,$21,$08,$DB,$CD,$3B,$33,$CB,$CE,$CD,$2C,$68,$C9,$FA,$89
    DB $DB,$21,$03,$DB,$CD,$3B,$33,$CB,$76,$20,$1D,$CD,$20,$7A,$30,$12
    DB $FA,$89,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$F6,$21,$B0,$B0,$CD,$71
    DB $68,$C9,$3E,$B8,$CD,$FC,$67,$C9,$CD,$2C,$68,$C9,$FA,$89,$DB,$21
    DB $03,$DB,$CD,$3B,$33,$CB,$7E,$20,$17,$CD,$2C,$7A,$30,$16,$FA,$89
    DB $DB,$21,$03,$DB,$CD,$3B,$33,$CB,$FE,$21,$B2,$B2,$CD,$71,$68,$C9
    DB $CD,$2C,$68,$C9,$3E,$C9,$CD,$08,$68,$C9,$FA,$88,$DB,$21,$B3,$DB
    DB $CD,$46,$7E,$2A,$46,$4F,$79,$EA,$5A,$DB,$78,$EA,$5B,$DB,$FA,$88
    DB $DB,$21,$A3,$DB,$CD,$46,$7E,$7D,$EA,$5C,$DB,$7C,$EA,$5D,$DB,$2A
    DB $66,$6F,$CD,$14,$33,$28,$27,$01,$F4,$01,$09,$FA,$5A,$DB,$4F,$FA
    DB $5B,$DB,$47,$CD,$14,$33,$38,$02,$60,$69,$FA,$5C,$DB,$4F,$FA,$5D
    DB $DB,$47,$7D,$02,$03,$7C,$02,$21,$84,$84,$CD,$32,$68,$C9,$3E,$BB
    DB $CD,$FC,$67,$C9,$FA,$88,$DB,$21,$07,$DB,$CD,$3B,$33,$7E,$E6,$10
    DB $20,$0A,$7E,$E6,$CF,$F6,$20,$77,$CD,$2C,$68,$C9,$7E,$E6,$CF,$77
    DB $CD,$F8,$68,$FA,$99,$C8,$FE,$80,$38,$2B,$FA,$88,$DB,$E6,$04,$21
    DB $1B,$DD,$85,$6F,$3E,$00,$8C,$67,$06,$03,$2A,$FE,$01,$28,$05,$05
    DB $20,$F8,$18,$11,$3E,$04,$EA,$ED,$D9,$EA,$72,$DD,$AF,$EA,$EE,$D9
    DB $AF,$EA,$EF,$D9,$C9,$3E,$CB,$CD,$FC,$67,$C9,$CD,$F8,$68,$FA,$99
    DB $C8,$FE,$7F,$38,$06,$3E,$BB,$CD,$FC,$67,$C9,$3E,$04,$EA,$ED,$D9
    DB $EA,$72,$DD,$AF,$EA,$EE,$D9,$AF,$EA,$EF,$D9,$C9,$CD,$2C,$68,$C9
    DB $21,$91,$91,$CD,$5C,$68,$C9,$CD,$92,$76,$21,$82,$B6,$CD,$89,$68
    DB $C9,$CD,$D7,$76,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$C9,$76,$21,$82
    DB $B6,$CD,$89,$68,$C9,$CD,$3A,$7A,$CD,$86,$68,$C9,$FA,$88,$DB,$21
    DB $1B,$DD,$85,$6F,$3E,$00,$8C,$67,$36,$FF,$FA,$88,$DB,$FE,$04,$38
    DB $15,$E6,$03,$21,$33,$DC,$47,$87,$80,$85,$6F,$3E,$00,$8C,$67,$AF
    DB $22,$22,$77,$CD,$05,$46,$3E,$01,$EA,$ED,$D9,$CD,$2C,$68,$C9,$CD
    DB $39,$65,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$D1,$7E,$7D,$EA,$56
    DB $DB,$7C,$EA,$57,$DB,$21,$82,$CA,$CD,$89,$68,$C9,$CD,$F8,$68,$FA
    DB $99,$C8,$FE,$40,$38,$0A,$CD,$39,$65,$21,$82,$B6,$CD,$89,$68,$C9
    DB $3E,$B6,$CD,$FC,$67,$C9,$CD,$F8,$68,$FA,$99,$C8,$FE,$C0,$38,$0A
    DB $CD,$39,$65,$21,$82,$B6,$CD,$89,$68,$C9,$3E,$B6,$CD,$FC,$67,$C9
    DB $FA,$88,$DB,$EA,$89,$DB,$21,$ED,$DC,$CD,$46,$7E,$FA,$88,$DB,$77
    DB $CD,$39,$65,$21,$82,$B6,$CD,$89,$68,$C9,$FA,$88,$DB,$21,$05,$DB
    DB $CD,$3B,$33,$CB,$D6,$CD,$2C,$68,$C9,$FA,$88,$DB,$21,$02,$DB,$CD
    DB $3B,$33,$CB,$F6,$21,$00,$CF,$CD,$40,$68,$C9,$FA,$89,$DB,$21,$A3
    DB $DB,$CD,$46,$7E,$AF,$22,$77,$FA,$88,$DB,$F5,$FA,$89,$DB,$EA,$88
    DB $DB,$CD,$D9,$61,$F1,$EA,$88,$DB,$3E,$01,$EA,$ED,$D9,$21,$E9,$E9
    DB $FA,$8A,$DB,$FE,$A4,$28,$03,$21,$29,$29,$CD,$5C,$68,$C9,$3E,$2F
    DB $EA,$8A,$DB,$CD,$63,$58,$C9,$FA,$88,$DB,$E6,$04,$4F,$06,$03,$79
    DB $CD,$74,$33,$38,$09,$79,$21,$03,$DB,$CD,$3B,$33,$CB,$DE,$0C,$05
    DB $20,$ED,$CD,$2C,$68,$C9,$FA,$89,$DB,$4F,$CD,$74,$33,$38,$1E,$79
    DB $21,$02,$DB,$CD,$3B,$33,$CB,$7E,$20,$0D,$7E,$E6,$73,$F6,$8C,$77
    DB $21,$CC,$CC,$CD,$71,$68,$C9,$3E,$BD,$CD,$FC,$67,$C9,$CD,$2C,$68
    DB $C9,$FA,$89,$DB,$4F,$CD,$74,$33,$38,$15,$79,$21,$C3,$DB,$CD,$46
    DB $7E,$2A,$B6,$28,$0A,$AF,$32,$77,$21,$72,$72,$CD,$5C,$68,$C9,$CD
    DB $2C,$68,$C9,$FA,$88,$DB,$21,$ED,$DC,$CD,$46,$7E,$7E,$EA,$89,$DB
    DB $CD,$74,$33,$38,$15,$CD,$48,$7A,$FA,$88,$DB,$21,$08,$DB,$CD,$3B
    DB $33,$CB,$C6,$21,$82,$B6,$CD,$89,$68,$C9,$CD,$2C,$68,$C9,$CD,$C1
    DB $67,$CB,$46,$20,$09,$CB,$C6,$21,$B5,$B5,$CD,$71,$68,$C9,$CD,$2C
    DB $68,$C9,$FA,$89,$DB,$21,$1B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E,$FE
    DB $01,$20,$07,$21,$9E,$9E,$CD,$32,$68,$C9,$CD,$2C,$68,$C9,$FA,$89
    DB $DB,$CD,$B0,$33,$E5,$FA,$89,$DB,$21,$C3,$DB,$CD,$46,$7E,$C1,$2A
    DB $BE,$28,$0A,$78,$32,$71,$21,$76,$76,$CD,$5C,$68,$C9,$CD,$2C,$68
    DB $C9,$FA,$69,$DD,$4F,$3D,$FE,$08,$30,$3E,$FA,$89,$DB,$CD,$74,$33
    DB $38,$3A,$FA,$89,$DB,$21,$A3,$DB,$CD,$46,$7E,$2A,$56,$5F,$FE,$01
    DB $20,$04,$7A,$B7,$28,$10,$1B,$7B,$EA,$56,$DB,$7A,$EA,$57,$DB,$21
    DB $85,$85,$CD,$97,$68,$C9,$21,$01,$00,$7D,$EA,$56,$DB,$7C,$EA,$57
    DB $DB,$21,$82,$82,$CD,$97,$68,$C9,$CD,$2C,$68,$C9,$79,$E6,$03,$47
    DB $79,$FE,$04,$38,$08,$FA,$88,$DB,$E6,$04,$B0,$18,$08,$FA,$88,$DB
    DB $E6,$04,$EE,$04,$B0,$47,$FA,$88,$DB,$21,$ED,$DC,$CD,$46,$7E,$70
    DB $78,$EA,$89,$DB,$AF,$EA,$EE,$D9,$C9,$3E,$00,$EA,$56,$DB,$3E,$00
    DB $EA,$57,$DB,$CD,$81,$64,$FA,$55,$DB,$47,$FA,$54,$DB,$B7,$28,$07
    DB $FA,$88,$DB,$CB,$3F,$CB,$3F,$80,$6F,$26,$00,$7C,$EA,$22,$C8,$7D
    DB $EA,$23,$C8,$21,$04,$5F,$D7,$C9,$3E,$82,$EA,$55,$DB,$EA,$54,$DB
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$7D,$B4,$20,$04,$CD,$E2,$64,$C9
    DB $CD,$40,$64,$C9
.L6481:
    CALL .L7FB1
    CALL .L6488
    RET
.L6488:
    LD HL,$C190
    LD A,($DB56)
    LD C,A
    LD A,($DB57)
    LD B,A
    CALL $0E68
    RET
    DB $3E,$05,$EA,$51,$DB,$3E,$02,$EA,$6B,$DD,$C9,$21,$80,$C1,$FA,$89
    DB $DB,$EA,$50,$DB,$CD,$D6,$7E,$3E,$00,$EA,$22,$C8,$3E,$B8,$EA,$23
    DB $C8,$3E,$00,$EA,$6B,$DD,$3E,$04,$EA,$EF,$D9,$3E,$6F,$CD,$FF,$1E
    DB $C9,$21,$80,$C1,$FA,$89,$DB,$EA,$50,$DB,$CD,$D6,$7E,$21,$78,$00
    DB $CD,$FC,$64,$C9,$21,$BB,$00,$CD,$FC,$64,$C9
.L64E2:
    LD HL,$C180
    LD A,($DB89)
    LD ($DB50),A
    CALL .L7ED6
    CALL .L538E
    SRL A
    SRL A
    XOR $01
    ADD A,$B6
    LD L,A
    LD H,$00
    LD A,H
    LD ($C822),A
    LD A,L
    LD ($C823),A
    LD A,$00
    LD ($DD6B),A
    LD HL,$D9EF
    INC (HL)
    LD A,$6F
    CALL $1EFF
    RET
    DB $21,$80,$C1,$FA,$89,$DB,$EA,$50,$DB,$CD,$D6,$7E,$FA,$55,$DB,$EA
    DB $23,$C8,$3E,$00,$EA,$22,$C8,$3E,$02,$EA,$6B,$DD,$21,$EF,$D9,$34
    DB $3E,$6F,$CD,$FF,$1E,$C9,$CD,$6B,$74,$C9,$3E,$00,$EA,$56,$DB,$3E
    DB $00,$EA,$57,$DB,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$7E,$C9,$CD
    DB $F8,$68,$37,$3F,$FA,$88,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$4E,$C8
    DB $FA,$99,$C8,$FE,$A0,$C9,$FA,$89,$DB,$21,$07,$DB,$CD,$3B,$33,$7E
    DB $E6,$0C,$C8,$FA,$99,$C8,$FE,$80,$C9
.L657C:
    PUSH HL
    PUSH BC
    LD B,A
    LD HL,$DD1B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD (HL),$00
    LD A,B
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
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD C,(HL)
    CALL .L65B2
    POP BC
    POP HL
    RET
    DB $FA,$4C,$DB,$CD,$7C,$65,$C9
.L65B2:
    CALL .L65F6
    LD A,($C863)
    BIT 1,A
    LD A,B
    JR Z,.L65C3
    CP $03
    JR NC,.L65F5
    JR .L65CD
.L65C3:
    CP $04
    JR C,.L65F5
    CP $07
    JR Z,.L65F5
    SUB $04
.L65CD:
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
.L65F5:
    RET
.L65F6:
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
.L660F:
    PUSH HL
    LD ($DD72),A
    LD HL,$5704
    RST $10  ; -> bank87/fn4
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    LD HL,$03E7
    CALL $3314
    JR NC,.L662A
    LD BC,$03E7
.L662A:
    POP HL
    RET
.L662C:
    PUSH HL
    LD ($DD72),A
    LD HL,$5705
    RST $10  ; -> bank87/fn5
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    POP HL
    RET
.L663E:
    PUSH HL
    LD ($DD72),A
    LD HL,$5706
    RST $10  ; -> bank87/fn6
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    POP HL
    RET
.L6650:
    PUSH HL
    LD ($DD72),A
    LD HL,$5707
    RST $10  ; -> bank87/fn7
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    POP HL
    RET
Bank82_fn4:
    LD A,($DD72)
.L6665:
    PUSH HL
    LD ($DD72),A
    LD HL,$5708
    RST $10  ; -> bank87/fn8
    LD A,($DD72)
    LD C,A
    LD A,($DD73)
    LD B,A
    POP HL
    RET
.L6677:
    LD B,A
    CP $03
    JR C,.L66AC
    AND $03
    CP $03
    JR Z,.L66B4
    LD A,($C86C)
    OR A
    LD A,B
    JR NZ,.L66AC
    AND $03
    LD HL,$DA03
    CALL .L7E3F
.L6691:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD A,($DA18)
    LD ($DA31),A
    LD HL,$0301
    RST $10  ; -> bank3/fn1
    LD HL,$DA42
    JR .L66C3
.L66AC:
    LD HL,$CB29
    CALL $25F8
    JR .L66C3
.L66B4:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L6691
.L66C3:
    RET
.L66C4:
    LD B,A
    CP $03
    JR C,.L66F1
    AND $03
    CP $03
    JR Z,.L66FB
    LD A,($C86C)
    OR A
    LD A,B
    JR NZ,.L66F1
    SUB $04
    LD HL,$DA03
    CALL .L7E3F
.L66DE:
    LD A,L
    LD ($DA12),A
    LD A,H
    LD ($DA13),A
    LD HL,$1401
    RST $10  ; -> bank20/fn1
    LD HL,$DA2D
    LD B,$04
    JR .L670A
.L66F1:
    LD HL,$CAEA
    CALL $25F8
    LD B,$08
    JR .L670A
.L66FB:
    LD A,B
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD L,(HL)
    LD H,$01
    JR .L66DE
.L670A:
    RET
    DB $E5,$21,$08,$DB,$CD,$3B,$33,$CB,$F6,$E1,$C9,$E5,$21,$08,$DB,$CD
    DB $3B,$33,$CB,$FE,$E1,$C9,$E5,$21,$08,$DB,$CD,$3B,$33,$7E,$F6,$C0
    DB $77,$E1,$C9
Bank82_fn3:
    LD A,($DB8A)
    CP $3A
    JR C,.L677B
    CP $7E
    JR Z,.L677B
    CP $40
    JR C,.L675B
    JR Z,.L675F
    CP $50
    JR C,.L6763
    CP $55
    JR C,.L6767
    CP $58
    JR C,.L676B
    CP $67
    JR C,.L676F
    CP $D6
    JR C,.L6773
    CP $DD
    JR C,.L6777
    LD A,$1B
    JR .L677D
.L675B:
    SUB $3A
    JR .L677D
.L675F:
    LD A,$05
    JR .L677D
.L6763:
    SUB $3E
    JR .L677D
.L6767:
    LD A,$11
    JR .L677D
.L676B:
    SUB $42
    JR .L677D
.L676F:
    LD A,$14
    JR .L677D
.L6773:
    SUB $51
    JR .L677D
.L6777:
    SUB $BD
    JR .L677D
.L677B:
    LD A,$00
.L677D:
    LD C,A
    LD B,$00
    LD HL,$6788
    ADD HL,BC
    ADD HL,BC
    JP $0008
    DB $6B,$74,$6B,$74,$A8,$75,$6B,$74,$C6,$75,$6B,$74,$26,$76,$37,$76
    DB $48,$76,$59,$76,$6A,$76,$9F,$76,$AD,$76,$BB,$76,$E5,$76,$F3,$76
    DB $01,$77,$6B,$74,$6B,$74,$6B,$74,$A8,$77,$6B,$74,$6B,$74,$6B,$74
    DB $92,$76,$D7,$76,$C9,$76,$6B,$74,$C9,$FA,$89,$DB,$21,$05,$DB,$CD
    DB $3B,$33,$C9,$FA,$88,$DB,$21,$0B,$DD,$85,$6F,$3E,$00,$8C,$67,$7E
    DB $B7,$C8,$FA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA,$4D,$DB,$3E,$02,$EA
    DB $4E,$DB,$21,$00,$54,$D7,$FA,$4C,$DB,$E6,$02,$C0,$21,$08,$58,$D7
    DB $3E,$01,$B7,$C9
.L67FC:
    LD ($DD70),A
    LD ($DD71),A
    LD A,$80
    LD ($DD6F),A
    RET
    DB $EA,$70,$DD,$EA,$71,$DD,$3E,$88,$EA,$6F,$DD,$C9,$EA,$70,$DD,$EA
    DB $71,$DD,$3E,$84,$EA,$6F,$DD,$C9,$EA,$70,$DD,$EA,$71,$DD,$3E,$93
    DB $EA,$6F,$DD,$C9
.L682C:
    LD A,$40
    LD ($DD6F),A
    RET
    DB $3E,$90,$EA,$6F,$DD,$7D,$EA,$70,$DD,$7C,$EA,$71,$DD,$C9,$3E,$D0
    DB $EA,$6F,$DD,$7D,$EA,$70,$DD,$7C,$EA,$71,$DD,$C9,$3E,$98,$EA,$6F
    DB $DD,$7D,$EA,$70,$DD,$7C,$EA,$71,$DD,$C9
.L685C:
    LD A,$90
    LD ($DD6F),A
    LD A,L
    LD ($DD70),A
    LD A,H
    LD ($DD71),A
    XOR A
    LD ($DB56),A
    LD ($DB57),A
    RET
    DB $3E,$98,$EA,$6F,$DD,$7D,$EA,$70,$DD,$7C,$EA,$71,$DD,$AF,$EA,$56
    DB $DB,$EA,$57,$DB,$C9,$21,$82,$B8,$3E,$A8,$EA,$6F,$DD,$7D,$EA,$70
    DB $DD,$7C,$EA,$71,$DD,$C9,$3E,$A0,$EA,$6F,$DD,$7D,$EA,$70,$DD,$7C
    DB $EA,$71,$DD,$C9,$FA,$88,$DB,$FE,$04,$30,$05,$01,$00,$03,$18,$09
    DB $FA,$6C,$C8,$B7,$28,$1A,$01,$04,$03,$16,$00,$79,$CD,$74,$33,$38
    DB $01,$14,$0C,$05,$20,$F5,$7A,$FE,$01,$28,$05,$21,$93,$93,$18,$03
    DB $21,$94,$94,$CD,$32,$68,$C9,$FA,$89,$DB,$21,$04,$DB,$CD,$3B,$33
    DB $CB,$56,$C8,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$D1,$7E,$7D,$EA
    DB $56,$DB,$7C,$EA,$57,$DB,$C9
.L68F8:
    LD A,($C86C)
    OR A
    JR NZ,.L6902
    CALL $16A3
    RET
.L6902:
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
.L6928:
    LD A,$00
    LD ($DB4D),A
    LD A,($DB77)
    LD ($DB89),A
    LD A,($DB78)
    LD ($DB4C),A
    SUB $B0
    LD HL,$6960
    CALL .L7E3F
    LD A,($DB78)
    CP $BB
    LD A,($DB89)
    JR Z,.L6950
    CALL $3374
    JR C,.L6954
.L6950:
    CALL .L695F
    RET
.L6954:
    LD A,$00
    LD ($C822),A
    LD A,$BF
    LD ($C823),A
    RET
.L695F:
    JP HL
    DB $11,$6A,$11,$6A,$11,$6A,$11,$6A,$19,$6B,$19,$6B,$EC,$6B,$11,$6C
    DB $36,$6C,$5B,$6C,$7D,$6C,$A2,$6C,$10,$6A,$10,$6A,$10,$6A,$10,$6A
    DB $10,$6A,$10,$6A,$DF,$6C,$DF,$6C,$DF,$6C,$57,$6D,$DF,$6C,$A2,$6D
    DB $BA,$6D,$D2,$6D,$09,$6E,$21,$6E,$10,$6A,$10,$6A,$10,$6A,$10,$6A
    DB $10,$6A,$10,$6A,$10,$6A,$10,$6A,$39,$6E,$FA,$78,$DB,$FE,$B3,$28
    DB $04,$AF,$EA,$8A,$DB,$3E,$BB,$EA,$55,$DB,$3E,$00,$EA,$22,$C8,$FA
    DB $55,$DB,$EA,$23,$C8,$3E,$00,$EA,$6B,$DD,$C9,$3E,$01,$EA,$8A,$DB
    DB $FA,$89,$DB,$21,$04,$50,$D7,$CD,$B1,$7F,$11,$42,$CA,$21,$A0,$C1
    DB $CD,$6C,$10,$FA,$78,$DB,$FE,$C2,$38,$0F,$FE,$C7,$30,$0B,$21,$09
    DB $58,$D7,$3E,$01,$EA,$22,$C8,$18,$0B,$FA,$55,$DB,$EA,$23,$C8,$3E
    DB $00,$EA,$22,$C8,$FA,$78,$DB,$EA,$8A,$DB,$3E,$01,$EA,$6B,$DD,$C9
    DB $C9,$FA,$78,$DB,$FE,$B3,$20,$55,$21,$69,$DD,$34,$FA,$69,$DD,$FE
    DB $01,$20,$1F,$FA,$89,$DB,$E6,$04,$4F,$06,$03,$79,$CD,$74,$33,$38
    DB $06,$79,$CD,$7D,$7D,$20,$0B,$0C,$05,$20,$F0,$AF,$EA,$8A,$DB,$C3
    DB $B5,$69,$FA,$89,$DB,$CD,$7D,$7D,$CA,$AA,$69,$FA,$89,$DB,$21,$A3
    DB $DB,$CD,$46,$7E,$2A,$46,$4F,$FA,$89,$DB,$CD,$A9,$33,$91,$6F,$7C
    DB $98,$67,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB,$C3,$D2,$6A,$FA,$89,$DB
    DB $CD,$7D,$7D,$CA,$AA,$69,$FA,$89,$DB,$FE,$04,$38,$07,$3E,$0F,$EA
    DB $4E,$DB,$18,$05,$3E,$0B,$EA,$4E,$DB,$21,$01,$54,$D7,$FA,$4C,$DB
    DB $6F,$FA,$4D,$DB,$67,$CD,$2A,$7B,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB
    DB $E5,$FA,$89,$DB,$CD,$B7,$33,$C1,$09,$E5,$FA,$89,$DB,$CD,$A9,$33
    DB $C1,$CD,$14,$33,$30,$1C,$79,$95,$4F,$78,$9C,$47,$FA,$5A,$DB,$6F
    DB $FA,$5B,$DB,$67,$7D,$91,$6F,$7C,$98,$67,$7D,$EA,$5A,$DB,$7C,$EA
    DB $5B,$DB,$FA,$89,$DB,$21,$A3,$DB,$CD,$46,$7E,$E5,$2A,$66,$6F,$FA
    DB $5A,$DB,$4F,$FA,$5B,$DB,$47,$09,$44,$4D,$E1,$79,$22,$70,$FA,$5A
    DB $DB,$6F,$FA,$5B,$DB,$67,$FA,$89,$DB,$CB,$57,$28,$08,$44,$4D,$CD
    DB $C0,$7E,$CD,$70,$6F,$3E,$84,$EA,$55,$DB,$CD,$CB,$69,$CD,$63,$6F
    DB $21,$06,$5F,$D7,$AF,$EA,$6B,$DD,$C9,$FA,$78,$DB,$FE,$B5,$20,$2B
    DB $FA,$89,$DB,$CD,$8F,$7D,$CA,$AA,$69,$FA,$89,$DB,$21,$C3,$DB,$CD
    DB $46,$7E,$2A,$46,$4F,$FA,$89,$DB,$CD,$B0,$33,$91,$6F,$7C,$98,$67
    DB $7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB,$C3,$B0,$6B,$FA,$89,$DB,$CD,$8F
    DB $7D,$CA,$AA,$69,$FA,$89,$DB,$FE,$04,$38,$07,$3E,$10,$EA,$4E,$DB
    DB $18,$05,$3E,$0B,$EA,$4E,$DB,$21,$01,$54,$D7,$FA,$4C,$DB,$6F,$FA
    DB $4D,$DB,$67,$CD,$2A,$7B,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB,$E5,$FA
    DB $89,$DB,$CD,$BE,$33,$C1,$09,$E5,$FA,$89,$DB,$CD,$B0,$33,$C1,$CD
    DB $14,$33,$30,$1C,$79,$95,$4F,$78,$9C,$47,$FA,$5A,$DB,$6F,$FA,$5B
    DB $DB,$67,$7D,$91,$6F,$7C,$98,$67,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB
    DB $FA,$89,$DB,$21,$C3,$DB,$CD,$46,$7E,$E5,$2A,$66,$6F,$FA,$5A,$DB
    DB $4F,$FA,$5B,$DB,$47,$09,$44,$4D,$E1,$79,$22,$70,$FA,$5A,$DB,$6F
    DB $FA,$5B,$DB,$67,$FA,$89,$DB,$CB,$57,$28,$05,$44,$4D,$CD,$70,$6F
    DB $3E,$76,$EA,$55,$DB,$CD,$CB,$69,$CD,$63,$6F,$C9,$3E,$9C,$EA,$55
    DB $DB,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$03,$20,$04,$CD
    DB $58,$6F,$C9,$7E,$E6,$FC,$77,$CD,$49,$6F,$CD,$CB,$69,$CD,$63,$6F
    DB $C9,$3E,$9D,$EA,$55,$DB,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$7E
    DB $E6,$40,$20,$04,$CD,$58,$6F,$C9,$CD,$99,$7E,$7E,$E6,$BF,$77,$CD
    DB $CB,$69,$CD,$63,$6F,$C9,$3E,$DC,$EA,$55,$DB,$FA,$89,$DB,$21,$02
    DB $DB,$CD,$3B,$33,$7E,$E6,$10,$20,$04,$CD,$58,$6F,$C9,$CD,$99,$7E
    DB $7E,$E6,$EF,$77,$CD,$CB,$69,$CD,$63,$6F,$C9,$3E,$9F,$EA,$55,$DB
    DB $FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$20,$20,$04,$CD,$58
    DB $6F,$C9,$7E,$E6,$DF,$77,$CD,$CB,$69,$CD,$63,$6F,$C9,$3E,$DB,$EA
    DB $55,$DB,$FA,$89,$DB,$21,$02,$DB,$CD,$3B,$33,$7E,$E6,$8C,$20,$04
    DB $CD,$58,$6F,$C9,$CD,$99,$7E,$7E,$E6,$73,$77,$CD,$CB,$69,$CD,$63
    DB $6F,$C9,$FA,$77,$DB,$CD,$74,$33,$30,$31,$28,$2F,$FA,$77,$DB,$EA
    DB $4C,$DB,$21,$0A,$51,$D7,$FA,$77,$DB,$47,$CD,$7C,$65,$78,$21,$A3
    DB $DB,$CD,$46,$7E,$54,$5D,$78,$21,$B3,$DB,$CD,$46,$7E,$2A,$12,$13
    DB $7E,$12,$3E,$9E,$EA,$55,$DB,$CD,$CB,$69,$C9,$CD,$58,$6F,$C9,$3E
    DB $01,$EA,$8A,$DB,$FA,$77,$DB,$FE,$04,$38,$38,$D6,$04,$21,$83,$DB
    DB $E5,$2A,$66,$6F,$E5,$3E,$0F,$EA,$4E,$DB,$21,$01,$54,$D7,$FA,$99
    DB $C8,$6F,$FA,$9A,$C8,$67,$FA,$4C,$DB,$4F,$FA,$4D,$DB,$47,$E1,$09
    DB $01,$40,$06,$CD,$14,$33,$44,$4D,$38,$03,$01,$40,$06,$E1,$79,$22
    DB $70,$18,$2C,$21,$23,$DC,$CD,$46,$7E,$E5,$2A,$66,$6F,$E5,$3E,$0B
    DB $EA,$4E,$DB,$21,$01,$54,$D7,$E1,$FA,$4C,$DB,$4F,$FA,$4D,$DB,$47
    DB $7D,$91,$4F,$7C,$98,$47,$30,$03,$01,$00,$00,$E1,$79,$22,$70,$CD
    DB $CB,$69,$AF,$EA,$33,$DA,$C9,$3E,$01,$EA,$8A,$DB,$FA,$77,$DB,$FE
    DB $04,$38,$1C,$D6,$04,$21,$83,$DB,$E5,$2A,$66,$6F,$01,$05,$00,$09
    DB $01,$00,$04,$CD,$14,$33,$44,$4D,$38,$1C,$01,$00,$04,$18,$17,$21
    DB $23,$DC,$CD,$46,$7E,$E5,$2A,$66,$D6,$05,$6F,$7C,$DE,$00,$67,$44
    DB $4D,$30,$03,$01,$00,$00,$E1,$79,$22,$70,$CD,$CB,$69,$AF,$EA,$33
    DB $DA,$C9,$FA,$89,$DB,$CD,$74,$33,$D8,$CD,$51,$6E,$CD,$4E,$7B,$CB
    DB $37,$E6,$03,$CD,$E4,$7A,$CD,$73,$6E,$C9,$FA,$89,$DB,$CD,$74,$33
    DB $D8,$CD,$51,$6E,$CD,$4E,$7B,$07,$07,$E6,$03,$CD,$E4,$7A,$CD,$73
    DB $6E,$C9,$FA,$89,$DB,$CD,$74,$33,$D8,$FA,$89,$DB,$21,$03,$DB,$CD
    DB $3B,$33,$CB,$46,$C0,$CD,$5B,$70,$30,$17,$3E,$01,$EA,$8A,$DB,$FA
    DB $77,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$C6,$3E,$88,$EA,$55,$DB,$18
    DB $04,$CD,$3D,$6F,$C9,$CD,$CB,$69,$C9,$FA,$89,$DB,$CD,$74,$33,$D8
    DB $CD,$51,$6E,$CD,$49,$7B,$0F,$0F,$E6,$03,$CD,$E4,$7A,$CD,$73,$6E
    DB $C9,$FA,$89,$DB,$CD,$74,$33,$D8,$CD,$51,$6E,$CD,$5D,$7B,$0F,$0F
    DB $E6,$03,$CD,$E4,$7A,$CD,$73,$6E,$C9,$FA,$89,$DB,$CD,$74,$33,$D8
    DB $CD,$51,$6E,$CD,$49,$7B,$CB,$37,$E6,$03,$CD,$E4,$7A,$CD,$73,$6E
    DB $C9,$3E,$0B,$EA,$4E,$DB,$21,$01,$54,$D7,$3E,$82,$EA,$55,$DB,$3E
    DB $00,$EA,$54,$DB,$FA,$4C,$DB,$6F,$FA,$4D,$DB,$67,$CD,$2A,$7B,$21
    DB $00,$00,$C9,$FA,$56,$DB,$5F,$FA,$57,$DB,$57,$7B,$B2,$28,$12,$CD
    DB $95,$6E,$38,$0D,$CD,$C5,$6E,$21,$04,$5F,$D7,$21,$02,$55,$D7,$18
    DB $03,$CD,$37,$6F,$C9,$FA,$89,$DB,$21,$09,$DB,$CD,$3B,$33,$7E,$E6
    DB $03,$28,$20,$62,$6B,$CB,$4F,$20,$05,$CD,$D1,$7E,$18,$05,$3E,$0A
    DB $CD,$DC,$21,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$54,$5D,$7C,$B5,$20
    DB $02,$37,$C9,$AF,$C9,$3E,$01,$EA,$8A,$DB,$FA,$89,$DB,$21,$A3,$DB
    DB $CD,$46,$7E,$7D,$EA,$61,$DB,$7C,$EA,$62,$DB,$2A,$66,$93,$4F,$7C
    DB $9A,$47,$7B,$EA,$5A,$DB,$7A,$EA,$5B,$DB,$30,$24,$FA,$61,$DB,$6F
    DB $FA,$62,$DB,$67,$2A,$56,$5F,$7B,$EA,$5A,$DB,$7A,$EA,$5B,$DB,$01
    DB $00,$00,$FA,$89,$DB,$21,$1B,$DD,$85,$6F,$3E,$00,$8C,$67,$CB,$C6
    DB $C5,$FA,$5A,$DB,$4F,$FA,$5B,$DB,$47,$CD,$C0,$7E,$CD,$82,$6F,$C1
    DB $FA,$61,$DB,$6F,$FA,$62,$DB,$67,$79,$22,$70,$3E,$82,$EA,$55,$DB
    DB $CD,$88,$64,$CD,$CB,$69,$C9,$01,$02,$00,$CD,$82,$6F,$3E,$B8,$EA
    DB $55,$DB,$CD,$B1,$7F,$CD,$BA,$69,$C9,$FA,$89,$DB,$CB,$57,$28,$07
    DB $01,$64,$00,$CD,$70,$6F,$C9,$C9,$FA,$89,$DB,$CB,$57,$28,$00,$CD
    DB $AA,$69,$C9,$FA,$89,$DB,$FE,$04,$30,$05,$3E,$70,$CD,$FF,$1E,$C9
    DB $FA,$83,$DB,$6F,$FA,$84,$DB,$67,$09,$7D,$EA,$83,$DB,$7C,$EA,$84
    DB $DB,$C9,$FA,$83,$DB,$6F,$FA,$84,$DB,$67,$7D,$91,$6F,$7C,$98,$67
    DB $30,$03,$21,$00,$00,$7D,$EA,$83,$DB,$7C,$EA,$84,$DB,$C9,$CD,$64
    DB $7A,$CD,$49,$7B,$CB,$37,$E6,$03,$CD,$E4,$7A,$C9,$CD,$64,$7A,$CD
    DB $49,$7B,$0F,$0F,$E6,$03,$CD,$E4,$7A,$C9,$CD,$64,$7A,$CD,$49,$7B
    DB $E6,$03,$CD,$E4,$7A,$C9,$CD,$64,$7A,$CD,$4E,$7B,$07,$07,$E6,$03
    DB $CD,$E4,$7A,$C9,$CD,$64,$7A,$CD,$4E,$7B,$CB,$37,$E6,$03,$CD,$E4
    DB $7A,$C9,$CD,$64,$7A,$CD,$4E,$7B,$0F,$0F,$E6,$03,$CD,$E4,$7A,$C9
    DB $CD,$AF,$7E,$CA,$AC,$7E,$21,$00,$00,$7D,$EA,$56,$DB,$7C,$EA,$57
    DB $DB,$CD,$94,$7A,$CD,$53,$7B,$CB,$37,$E6,$03,$EA,$4E,$DB,$FA,$8A
    DB $DB,$FE,$72,$38,$0B,$FE,$82,$28,$0E,$FA,$4E,$DB,$CD,$9E,$7A,$C9
    DB $FA,$4E,$DB,$CD,$D7,$7A,$C9,$FA,$4E,$DB,$CD,$C1,$7A,$C9
.L702E:
    LD HL,$0000
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    CALL .L7A64
    CALL .L7B53
    RLCA
    RLCA
    AND $03
    LD ($DB4E),A
    CALL .L7E6A
    JR Z,.L704D
    SCF
    RET
.L704D:
    LD A,($DB8A)
    CP $15
    LD A,($DB4E)
    JP Z,.L7A9E
    JP .L7AD7
    DB $21,$00,$00,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$CD,$94,$7A,$CD,$53
    DB $7B,$E6,$03,$CD,$6A,$7E,$28,$02,$37,$C9,$CD,$9E,$7A,$C9,$21,$00
    DB $00,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$CD,$94,$7A,$CD,$4E,$7B,$E6
    DB $03,$CD,$6A,$7E,$28,$02,$37,$C9,$47,$FA,$8A,$DB,$FE,$72,$78,$28
    DB $04,$CD,$9E,$7A,$C9,$CD,$D7,$7A,$C9,$21,$00,$00,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$CD,$94,$7A,$CD,$58,$7B,$07,$07,$E6,$03,$CD,$6A
    DB $7E,$28,$02,$37,$C9,$CD,$D7,$7A,$C9,$21,$00,$00,$7D,$EA,$5A,$DB
    DB $7C,$EA,$5B,$DB,$CD,$94,$7A,$CD,$53,$7B,$0F,$0F,$E6,$03,$EA,$4E
    DB $DB,$CD,$6A,$7E,$28,$02,$37,$C9,$CD,$9E,$7A,$C9,$CD,$19,$71,$FA
    DB $88,$DB,$21,$C3,$DB,$CD,$46,$7E,$E5,$2A,$66,$6F,$09,$44,$4D,$E1
    DB $79,$22,$70,$FA,$88,$DB,$CD,$8F,$7D,$30,$12,$FA,$88,$DB,$01,$D4
    DB $DB,$87,$81,$4F,$3E,$00,$88,$47,$0A,$32,$0B,$0A,$77,$C9,$FA,$89
    DB $DB,$21,$C3,$DB,$CD,$46,$7E,$E5,$2A,$66,$6F,$B4,$28,$2F,$FA,$88
    DB $DB,$11,$9B,$DB,$83,$5F,$3E,$00,$8A,$57,$1A,$CB,$3F,$CB,$3F,$C6
    DB $05,$4F,$06,$00,$CD,$14,$33,$30,$02,$44,$4D,$79,$EA,$56,$DB,$78
    DB $EA,$57,$DB,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$18,$0B,$01,$00,$00
    DB $79,$EA,$56,$DB,$78,$EA,$57,$DB,$E1,$7E,$91,$22,$7E,$98,$77,$C9
    DB $21,$00,$00,$7D,$EA,$5A,$DB,$7C,$EA,$5B,$DB,$CD,$94,$7A,$CD,$58
    DB $7B,$CB,$37,$E6,$03,$EA,$4E,$DB,$CD,$6A,$7E,$28,$02,$37,$C9,$47
    DB $FA,$8A,$DB,$FE,$7A,$78,$28,$04,$CD,$9E,$7A,$C9,$CD,$D7,$7A,$C9
    DB $FA,$89,$DB,$CD,$A2,$33,$44,$4D,$21,$01,$00,$CD,$14,$33,$38,$02
    DB $AF,$C9,$FA,$89,$DB,$CD,$50,$66,$CD,$C0,$7E,$FA,$89,$DB,$21,$F3
    DB $DB,$CD,$46,$7E,$E5,$2A,$66,$B4,$E1,$28,$15,$79,$EA,$56,$DB,$78
    DB $EA,$57,$DB,$7E,$91,$22,$7E,$98,$77,$30,$03,$AF,$32,$77,$37,$C9
    DB $AF,$C9,$FA,$89,$DB,$CD,$A1,$7D,$30,$4C,$28,$4A,$FA,$89,$DB,$CD
    DB $50,$66,$CD,$C0,$7E,$79,$EA,$56,$DB,$78,$EA,$57,$DB,$FA,$89,$DB
    DB $21,$F3,$DB,$CD,$46,$7E,$7E,$81,$22,$7E,$88,$77,$FA,$89,$DB,$E5
    DB $CD,$A1,$7D,$E1,$38,$1E,$3A,$5E,$57,$79,$22,$70,$7B,$91,$5F,$7A
    DB $98,$57,$FA,$56,$DB,$93,$5F,$FA,$57,$DB,$9A,$57,$7B,$EA,$56,$DB
    DB $7A,$EA,$57,$DB,$37,$C9,$AF,$C9,$21,$00,$00,$7D,$EA,$5A,$DB,$7C
    DB $EA,$5B,$DB,$CD,$94,$7A,$CD,$58,$7B,$0F,$0F,$E6,$03,$CD,$6A,$7E
    DB $28,$02,$37,$C9,$CD,$9E,$7A,$C9,$FA,$89,$DB,$CD,$65,$66,$CD,$C0
    DB $7E,$FA,$89,$DB,$21,$03,$DC,$CD,$46,$7E,$E5,$16,$00,$2A,$66,$6F
    DB $CD,$14,$33,$20,$02,$16,$01,$C5,$01,$02,$00,$CD,$14,$33,$C1,$E1
    DB $38,$28,$79,$92,$4F,$78,$DE,$00,$47,$79,$EA,$56,$DB,$78,$EA,$57
    DB $DB,$7E,$5F,$91,$22,$7E,$57,$98,$77,$30,$0D,$AF,$32,$36,$01,$1B
    DB $7B,$EA,$56,$DB,$7A,$EA,$57,$DB,$37,$C9,$AF,$C9,$FA,$89,$DB,$CD
    DB $D7,$7D,$30,$4C,$FA,$89,$DB,$CD,$65,$66,$CD,$C0,$7E,$79,$EA,$56
    DB $DB,$78,$EA,$57,$DB,$FA,$89,$DB,$21,$03,$DC,$CD,$46,$7E,$7E,$81
    DB $22,$7E,$88,$77,$FA,$89,$DB,$E5,$CD,$D7,$7D,$E1,$38,$20,$2B,$2A
    DB $91,$5F,$7E,$98,$57,$78,$32,$71,$FA,$56,$DB,$4F,$FA,$57,$DB,$47
    DB $79,$93,$5F,$78,$9A,$57,$7B,$EA,$56,$DB,$7A,$EA,$57,$DB,$37,$C9
    DB $AF,$C9
.L72FD:
    LD A,($DB88)
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
    CALL .L660F
    LD A,($DB88)
    LD HL,$DBA3
    CALL .L7E46
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    CALL $3314
    POP HL
    JR C,.L7329
    LD A,C
    LD (HL+),A
    LD (HL),B
.L7329:
    LD A,($DB88)
    LD HL,$DBB3
    CALL .L7E46
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB89)
    CALL .L662C
    LD A,($DB88)
    LD HL,$DBC3
    CALL .L7E46
    PUSH HL
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    CALL $3314
    POP HL
    JR C,.L7351
    LD A,C
    LD (HL+),A
    LD (HL),B
.L7351:
    LD A,($DB88)
    LD HL,$DBD3
    CALL .L7E46
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB88)
    LD HL,$DBE3
    CALL .L7E46
    LD A,($DB89)
    CALL .L663E
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB88)
    LD HL,$DBF3
    CALL .L7E46
    LD A,($DB89)
    CALL .L6650
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB88)
    LD HL,$DC03
    CALL .L7E46
    LD A,($DB89)
    CALL .L6665
    LD A,C
    LD (HL+),A
    LD (HL),B
    LD A,($DB89)
    CALL .L6677
    LD A,($DB88)
    LD DE,$DD28
    LD B,A
    ADD A,A
    ADD A,B
    ADD A,A
    ADD A,B
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    CALL .L7E03
    LD A,($DB89)
    CALL .L66C4
    LD A,($DB88)
    LD DE,$DC64
    SWAP A
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD C,$00
.L73C3:
    LD A,(HL)
    LD ($DB4C),A
    CP $FF
    JR Z,.L73F7
    LD A,$00
    LD ($DB4D),A
    LD A,$01
    LD ($DB4E),A
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    LD HL,$5400
    RST $10  ; -> bank84/fn0
    POP HL
    POP DE
    POP BC
    POP AF
    LD A,($DB4C)
    SWAP A
    AND $0F
    LD A,A
    LD (DE),A
    INC DE
    LD A,(HL+)
    LD (DE),A
    INC DE
    INC C
    DEC B
    JR NZ,.L73C3
    LD A,C
    CP $08
    JR Z,.L7405
.L73F7:
    LD A,$00
    LD (DE),A
    INC DE
    LD A,$FF
    LD (DE),A
    INC DE
    INC C
    LD A,C
    CP $08
    JR NZ,.L73F7
.L7405:
    CALL .L7E5D
    LD C,(HL)
    LD A,($DB88)
    LD B,A
    CALL .L65B2
    RET
    DB $FA,$8A,$DB,$FE,$2D,$28,$19,$FE,$2F,$28,$15,$FE,$32,$28,$11,$FE
    DB $96,$28,$0D,$CD,$64,$7A,$FA,$56,$DB,$5F,$FA,$57,$DB,$57,$18,$14
    DB $FA,$89,$DB,$21,$B3,$DB,$CD,$46,$7E,$2A,$56,$5F,$7B,$EA,$56,$DB
    DB $7A,$EA,$57,$DB,$FA,$89,$DB,$21,$A3,$DB,$CD,$46,$7E,$E5,$2A,$66
    DB $6F,$7D,$83,$4F,$7C,$8A,$47,$FA,$89,$DB,$CD,$A9,$33,$CD,$14,$33
    DB $30,$02,$44,$4D,$E1,$79,$22,$70,$37,$C9
Bank82_fn5:
    CALL .L68F8
    LD A,($DB89)
    LD HL,$DBF3
    CALL .L7E46
    LD A,(HL+)
    LD B,(HL)
    LD C,A
    CALL .L7EC0
    LD A,($DB88)
    CALL $339B
    CALL $3314
    JR Z,.L74A6
    JR C,.L74A6
    LD A,L
    SUB C
    LD E,A
    LD A,H
    SBC A,B
    LD D,A
    SRL D
    RR E
    PUSH HL
    PUSH BC
    LD B,D
    LD C,E
    CALL .L7EC5
    CALL $3314
    POP BC
    POP HL
    JR Z,.L74B1
    JR NC,.L74B1
    JR .L74CC
.L74A6:
    LD A,($C899)
    AND $01
    LD E,A
    LD D,$00
    JP .L7517
.L74B1:
    CALL .L7EC5
    LD A,H
    OR L
    JR Z,.L74A6
    LD B,H
    LD C,L
    PUSH HL
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    CALL $331A
    POP HL
    LD D,B
    LD E,C
    JP .L7517
.L74CC:
    PUSH DE
    LD H,D
    LD L,E
    CALL .L7EC9
    POP DE
    LD A,H
    OR L
    JR Z,.L7507
    PUSH HL
    LD A,($C899)
    LD L,A
    LD A,($C89A)
    LD H,A
    POP BC
    LD A,C
    INC A
    PUSH DE
    CALL $21DC
    POP DE
    LD C,A
    LD B,$00
    CALL .L7EC0
    LD A,($C89A)
    AND $0F
    OR A
    JR Z,.L7507
    BIT 3,A
    JR NZ,.L7502
    LD A,E
    SUB C
    LD E,A
    LD A,D
    SBC A,B
    LD D,A
    JR .L7507
.L7502:
    LD H,B
    LD L,C
    ADD HL,DE
    LD D,H
    LD E,L
.L7507:
    LD A,($C899)
    AND $03
    OR A
    JR Z,.L7517
    BIT 0,A
    JR Z,.L7516
    INC DE
    JR .L7517
.L7516:
    DEC DE
.L7517:
    LD A,E
    LD ($DB56),A
    LD A,D
    LD ($DB57),A
    CALL .L7580
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,H
    OR L
    RET NZ
    LD B,A
    LD A,($C89A)
    AND $01
    LD C,A
    LD A,C
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    RET
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$FA,$88,$DB,$E6,$03,$FE,$03,$C8
    DB $B7,$C8,$18,$48
.L7551:
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,($DB89)
    AND $03
    CP $03
    RET Z
    OR A
    RET Z
    JR .L7599
    DB $FA,$6C,$C8,$B7,$20,$D2,$FA,$88,$DB,$FE,$03,$D0,$B7,$C8,$FA,$56
    DB $DB,$6F,$FA,$57,$DB,$67,$FA,$88,$DB,$18,$19
.L7580:
    LD A,($C86C)
    OR A
    JR NZ,.L7551
    LD A,($DB89)
    CP $03
    RET NC
    OR A
    RET Z
    LD A,($DB56)
    LD L,A
    LD A,($DB57)
    LD H,A
    LD A,($DB89)
.L7599:
    CP $02
    RET NZ
    CALL .L7D45
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    RET
    DB $FA,$89,$DB,$CD,$B7,$33,$CD,$45,$7D,$23,$7D,$EA,$56,$DB,$7C,$EA
    DB $57,$DB,$CD,$94,$7A,$CD,$58,$7B,$E6,$03,$CD,$E4,$7A,$C9,$CD,$94
    DB $7A,$CD,$58,$7B,$E6,$03,$CD,$C1,$7A,$30,$46,$FA,$88,$DB,$CD,$B7
    DB $33,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$2A,$66,$6F,$7C,$B7,$20,$05
    DB $7D,$FE,$01,$28,$22,$FA,$73,$DB,$B7,$20,$09,$FA,$89,$DB,$CD,$B7
    DB $33,$2B,$18,$0C,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$2B,$CD,$D1,$7E
    DB $7C,$B5,$20,$03,$21,$01,$00,$37,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB
    DB $C9,$21,$00,$00,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$AF,$C9,$CD,$6B
    DB $74,$CD,$94,$7A,$CD,$49,$7B,$CB,$37,$E6,$03,$CD,$10,$7B,$C9,$CD
    DB $6B,$74,$CD,$94,$7A,$CD,$4E,$7B,$CB,$37,$E6,$03,$CD,$10,$7B,$C9
    DB $CD,$6B,$74,$CD,$94,$7A,$CD,$4E,$7B,$07,$07,$E6,$03,$CD,$10,$7B
    DB $C9,$CD,$6B,$74,$CD,$94,$7A,$CD,$4E,$7B,$0F,$0F,$E6,$03,$CD,$10
    DB $7B,$C9,$CD,$6B,$74,$FA,$89,$DB,$21,$8B,$DB,$85,$6F,$3E,$00,$8C
    DB $67,$CB,$46,$28,$14,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$07,$7D
    DB $23,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$CD,$6B,$74,$CD,$4E,$7E
    DB $B7,$20,$03,$CD,$F3,$7C,$C9,$CD,$6B,$74,$CD,$4E,$7E,$FE,$01,$20
    DB $03,$CD,$F3,$7C,$C9,$CD,$6B,$74,$CD,$4E,$7E,$FE,$02,$20,$03,$CD
    DB $F3,$7C,$C9,$CD,$6B,$74,$CD,$4E,$7E,$FE,$03,$20,$03,$CD,$F3,$7C
    DB $C9,$CD,$6B,$74,$CD,$4E,$7E,$FE,$04,$20,$03,$CD,$F3,$7C,$C9,$CD
    DB $6B,$74,$CD,$4E,$7E,$FE,$05,$20,$03,$CD,$F3,$7C,$C9,$CD,$6B,$74
    DB $CD,$4E,$7E,$FE,$06,$20,$03,$CD,$F3,$7C,$C9,$CD,$6B,$74,$CD,$4E
    DB $7E,$FE,$07,$20,$03,$CD,$F3,$7C,$C9,$CD,$6B,$74,$CD,$4E,$7E,$FE
    DB $08,$20,$03,$CD,$F3,$7C,$C9,$FA,$8A,$DB,$EA,$4C,$DB,$3E,$00,$EA
    DB $4D,$DB,$FA,$6C,$C8,$B7,$20,$0E,$FA,$88,$DB,$FE,$04,$38,$07,$3E
    DB $0F,$EA,$4E,$DB,$18,$05,$3E,$0B,$EA,$4E,$DB,$21,$01,$54,$D7,$FA
    DB $4C,$DB,$6F,$FA,$4D,$DB,$67,$CD,$2A,$7B,$CD,$4E,$7E,$FE,$07,$20
    DB $13,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$0E,$7D,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$CD,$94,$7A,$CD,$4E,$7B,$07,$07,$E6,$03,$CD,$FA
    DB $7A,$C9,$FA,$88,$DB,$21,$9B,$DB,$85,$6F,$3E,$00,$8C,$67,$6E,$26
    DB $00,$FA,$6C,$C8,$B7,$20,$12,$FA,$88,$DB,$FE,$04,$38,$0B,$7D,$CB
    DB $3F,$85,$6F,$7C,$CE,$00,$67,$18,$01,$29,$7D,$EA,$56,$DB,$7C,$EA
    DB $57,$DB,$CD,$94,$7A,$CD,$67,$7B,$CB,$37,$E6,$03,$CD,$E4,$7A,$C9
    DB $FA,$88,$DB,$21,$9B,$DB,$85,$6F,$3E,$00,$8C,$67,$6E,$26,$00,$44
    DB $4D,$FA,$6C,$C8,$B7,$20,$0C,$FA,$88,$DB,$FE,$04,$38,$05,$CD,$C0
    DB $7E,$18,$05,$09,$09,$01,$0A,$00,$09,$01,$B4,$00,$CD,$14,$33,$38
    DB $03,$21,$B4,$00,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$CD,$76,$7D,$44
    DB $4D,$CD,$F8,$68,$FA,$99,$C8,$6F,$FA,$9A,$C8,$67,$CD,$1A,$33,$FA
    DB $56,$DB,$6F,$FA,$57,$DB,$67,$CB,$28,$CB,$19,$30,$08,$7D,$91,$4F
    DB $7C,$98,$47,$18,$03,$09,$44,$4D,$79,$EA,$56,$DB,$78,$EA,$57,$DB
    DB $CD,$94,$7A,$CD,$C9,$6F,$C9,$FA,$88,$DB,$21,$9B,$DB,$85,$6F,$3E
    DB $00,$8C,$67,$6E,$26,$00,$FA,$6C,$C8,$B7,$20,$0B,$FE,$04,$38,$07
    DB $44,$4D,$CD,$C0,$7E,$18,$04,$29,$01,$1E,$00,$09,$01,$96,$00,$CD
    DB $14,$33,$38,$03,$21,$96,$00,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$3E
    DB $05,$CD,$DC,$21,$44,$4D,$CD,$F8,$68,$FA,$99,$C8,$6F,$FA,$9A,$C8
    DB $67,$CD,$1A,$33,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CB,$28,$CB,$19
    DB $38,$03,$09,$18,$08,$7D,$91,$6F,$7C,$98,$67,$38,$08,$7D,$EA,$56
    DB $DB,$7C,$EA,$57,$DB,$CD,$94,$7A,$CD,$C9,$6F,$C9,$CD,$64,$7A,$CD
    DB $67,$7B,$CB,$37,$E6,$03,$CD,$FA,$7A,$C9,$CD,$64,$7A,$CD,$5D,$7B
    DB $CB,$37,$E6,$03,$CD,$FA,$7A,$C9,$CD,$64,$7A,$CD,$5D,$7B,$0F,$0F
    DB $E6,$03,$CD,$FA,$7A,$C9,$CD,$64,$7A,$CD,$49,$7B,$CB,$37,$E6,$03
    DB $CD,$FA,$7A,$C9,$FA,$88,$DB,$5F,$CD,$BE,$33,$29,$7D,$EA,$56,$DB
    DB $7C,$EA,$57,$DB,$7B,$21,$9B,$DB,$85,$6F,$3E,$00,$8C,$67,$6E,$26
    DB $00,$29,$FA,$56,$DB,$4F,$FA,$57,$DB,$47,$09,$7D,$EA,$56,$DB,$7C
    DB $EA,$57,$DB,$CD,$6F,$7D,$CD,$CD,$7E,$7D,$B4,$28,$30,$44,$4D,$CD
    DB $F8,$68,$FA,$99,$C8,$6F,$FA,$9A,$C8,$67,$CD,$1A,$33,$FA,$56,$DB
    DB $6F,$FA,$57,$DB,$67,$FA,$99,$C8,$E6,$01,$28,$08,$7D,$91,$6F,$7C
    DB $98,$67,$18,$01,$09,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$CD,$94,$7A
    DB $CD,$5D,$7B,$07,$07,$E6,$03,$CD,$FA,$7A,$C9
.L7943:
    CALL .L7EAF
    JP Z,.L7EAC
    CALL .L7A94
    CALL .L7B62
    RLCA
    RLCA
    AND $03
    CALL .L7AD7
    RET
.L7957:
    CALL .L7A94
    CALL .L7B5D
    AND $03
    CALL .L7AD7
    RET
    DB $CD,$94,$7A,$CD,$62,$7B,$CB,$37,$E6,$03,$CD,$D7,$7A,$C9,$CD,$94
    DB $7A,$CD,$62,$7B,$0F,$0F,$E6,$03,$47,$FA,$8A,$DB,$FE,$7C,$78,$30
    DB $05,$CD,$9E,$7A,$18,$03,$CD,$D7,$7A,$C9,$FA,$89,$DB,$21,$8B,$DB
    DB $85,$6F,$3E,$00,$8C,$67,$CB,$66,$C0,$CD,$71,$79,$C9,$FA,$89,$DB
    DB $21,$F3,$DB,$87,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F,$0B,$78,$B1
    DB $20,$1F,$3E,$0F,$85,$6F,$3E,$00,$8C,$67,$2A,$46,$4F,$0B,$78,$B1
    DB $20,$0F,$FA,$89,$DB,$21,$03,$DB,$CD,$3B,$33,$CB,$4E,$28,$02,$AF
    DB $C9,$37,$C9,$FA,$8A,$DB,$FE,$84,$28,$0E,$FE,$85,$28,$10,$FE,$86
    DB $28,$12,$21,$08,$51,$D7,$18,$10,$21,$05,$51,$D7,$18,$0A,$21,$06
    DB $51,$D7,$18,$04,$21,$07,$51,$D7,$FA,$88,$DB,$E6,$04,$F6,$03,$21
    DB $02,$DB,$CD,$3B,$33,$AF,$22,$22,$22,$22,$22,$22,$22,$77,$C9
.L7A12:
    LD HL,$5109
    RST $10  ; -> bank81/fn9
    LD C,$C9
    LD A,($DB88)
    LD B,A
    CALL .L65B2
    RET
    DB $CD,$94,$7A,$CD,$62,$7B,$E6,$03,$CD,$9E,$7A,$C9,$CD,$94,$7A,$CD
    DB $67,$7B,$07,$07,$E6,$03,$CD,$9E,$7A,$C9,$CD,$64,$7A,$CD,$67,$7B
    DB $0F,$0F,$E6,$03,$CD,$E4,$7A,$C9,$FA,$88,$DB,$21,$E3,$DB,$CD,$46
    DB $7E,$E5,$2A,$46,$4F,$C5,$3E,$01,$32,$36,$90,$CD,$39,$65,$C1,$E1
    DB $79,$22,$70,$C9
.L7A64:
    LD A,($DB8A)
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,($C86C)
    OR A
    JR NZ,.L7A80
    LD A,($DB88)
    BIT 2,A
    JR Z,.L7A80
    LD A,$0F
    JR .L7A82
.L7A80:
    LD A,$0B
.L7A82:
    LD ($DB4E),A
    LD HL,$5401
    RST $10  ; -> bank84/fn1
    LD A,($DB4C)
    LD L,A
    LD A,($DB4D)
    LD H,A
    CALL .L7B2A
.L7A94:
    LD A,($DB89)
    LD HL,$DB05
    CALL $333B
    RET
.L7A9E:
    BIT 6,(HL)
    JR Z,.L7AA7
    CALL .L7B9D
    JR .L7AB3
.L7AA7:
    BIT 7,(HL)
    JR Z,.L7AB0
    CALL .L7B90
    JR .L7AB3
.L7AB0:
    CALL .L7B7A
.L7AB3:
    RET
    DB $CB,$76,$28,$05,$CD,$7A,$7B,$18,$03,$CD,$90,$7B,$C9,$CB,$76,$28
    DB $05,$CD,$B3,$7B,$18,$0C,$CB,$7E,$28,$05,$CD,$90,$7B,$18,$03,$CD
    DB $9D,$7B,$C9
.L7AD7:
    BIT 7,(HL)
    JR Z,.L7AE0
    CALL .L7B7A
    JR .L7AE3
.L7AE0:
    CALL .L7BB3
.L7AE3:
    RET
    DB $CB,$76,$28,$05,$CD,$DD,$7B,$18,$0C,$CB,$7E,$28,$05,$CD,$F0,$7B
    DB $18,$03,$CD,$CA,$7B,$C9,$CB,$76,$28,$05,$CD,$07,$7C,$18,$0C,$CB
    DB $7E,$28,$05,$CD,$F0,$7B,$18,$03,$CD,$DD,$7B,$C9,$CB,$76,$28,$05
    DB $CD,$CA,$7B,$18,$03,$CD,$F0,$7B,$C9,$CB,$7E,$28,$05,$CD,$CA,$7B
    DB $18,$03,$CD,$F0,$7B,$C9
.L7B2A:
    LD A,($DB4E)
    OR A
    JR Z,.L7B40
    INC A
    LD C,A
    LD A,($C899)
.L7B35:
    CP C
    JR C,.L7B3C
    SUB C
    JR NC,.L7B35
    LD A,C
.L7B3C:
    LD C,A
    LD B,$00
    ADD HL,BC
.L7B40:
    LD A,L
    LD ($DB56),A
    LD A,H
    LD ($DB57),A
    RET
    DB $11,$28,$DD,$18,$1C,$11,$29,$DD,$18,$17
.L7B53:
    LD DE,$DD2A
    JR .L7B6A
    DB $11,$2B,$DD,$18,$0D
.L7B5D:
    LD DE,$DD2C
    JR .L7B6A
.L7B62:
    LD DE,$DD2D
    JR .L7B6A
    DB $11,$2E,$DD
.L7B6A:
    LD A,($DB89)
    LD B,A
    ADD A,A
    ADD A,B
    ADD A,A
    ADD A,B
    ADD A,E
    LD E,A
    LD A,$00
    ADC A,D
    LD D,A
    LD A,(DE)
    RET
.L7B7A:
    AND A
    JR NZ,.L7B7F
    SCF
    RET
.L7B7F:
    CP $01
    JR NZ,.L7B86
    JP .L7C1E
.L7B86:
    CP $02
    JR NZ,.L7B8D
    JP .L7C30
.L7B8D:
    SCF
    CCF
    RET
.L7B90:
    CP $02
    JR NC,.L7B95
    RET
.L7B95:
    JR NZ,.L7B9A
    JP .L7C27
.L7B9A:
    SCF
    CCF
    RET
.L7B9D:
    AND A
    JR NZ,.L7BA2
    SCF
    RET
.L7BA2:
    CP $01
    JR NZ,.L7BA9
    JP .L7C27
.L7BA9:
    CP $02
    JR NZ,.L7BB0
    JP .L7C39
.L7BB0:
    SCF
    CCF
    RET
.L7BB3:
    AND A
    JR NZ,.L7BB9
    JP .L7C27
.L7BB9:
    CP $01
    JR NZ,.L7BC0
    JP .L7C30
.L7BC0:
    CP $02
    JR NZ,.L7BC7
    JP .L7C42
.L7BC7:
    SCF
    CCF
    RET
    DB $A7,$C8,$FE,$01,$20,$03,$C3,$73,$7C,$FE,$02,$20,$03,$C3,$9B,$7C
    DB $C3,$EB,$7C,$A7,$C8,$FE,$01,$20,$03,$C3,$87,$7C,$FE,$02,$20,$03
    DB $C3,$AF,$7C,$C3,$EB,$7C,$A7,$20,$03,$C3,$4B,$7C,$FE,$01,$20,$03
    DB $C3,$5F,$7C,$FE,$02,$20,$03,$C3,$87,$7C,$C3,$C3,$7C,$A7,$20,$03
    DB $C3,$87,$7C,$FE,$01,$20,$03,$C3,$9B,$7C,$FE,$02,$20,$03,$C3,$D7
    DB $7C,$C3,$EB,$7C
.L7C1E:
    CALL .L68F8
    LD A,($C899)
    CP $D8
    RET
.L7C27:
    CALL .L68F8
    LD A,($C899)
    CP $BF
    RET
.L7C30:
    CALL .L68F8
    LD A,($C899)
    CP $7F
    RET
.L7C39:
    CALL .L68F8
    LD A,($C899)
    CP $66
    RET
.L7C42:
    CALL .L68F8
    LD A,($C899)
    CP $3F
    RET
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$0E,$7D,$7D,$EA,$56,$DB,$7C
    DB $EA,$57,$DB,$C9,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$19,$7D,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$FA,$56,$DB,$6F,$FA,$57,$DB,$67
    DB $CD,$36,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$CD,$54,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9
    DB $FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$D1,$7E,$7D,$EA,$56,$DB,$7C
    DB $EA,$57,$DB,$C9,$FA,$56,$DB,$6F,$FA,$57,$DB,$67,$CD,$6F,$7D,$7D
    DB $EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$FA,$56,$DB,$6F,$FA,$57,$DB,$67
    DB $CD,$76,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$FA,$56,$DB,$6F
    DB $FA,$57,$DB,$67,$CD,$CD,$7E,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9
    DB $AF,$EA,$56,$DB,$EA,$57,$DB,$C9,$FA,$56,$DB,$6F,$FA,$57,$DB,$67
    DB $CD,$07,$7D,$7D,$EA,$56,$DB,$7C,$EA,$57,$DB,$C9,$44,$4D,$CD,$D1
    DB $7E,$09,$C9,$44,$4D,$CD,$BC,$7E,$09,$CD,$BC,$7E,$09,$C9,$44,$4D
    DB $CD,$B8,$7E,$09,$CD,$BC,$7E,$09,$C9,$CD,$D1,$7E,$44,$4D,$CD,$C0
    DB $7E,$09,$CD,$C0,$7E,$09,$CD,$BC,$7E,$09,$C9,$D5,$44,$4D,$3E,$55
    DB $CD,$B5,$21,$3E,$64,$CD,$ED,$21,$D1,$C9
.L7D45:
    PUSH DE
    LD B,H
    LD C,L
    LD A,$08
    CALL $21B5
    LD A,$0A
    CALL $21ED
    POP DE
    RET
    DB $C5,$CD,$D1,$7E,$44,$4D,$CD,$C0,$7E,$09,$C1,$C9,$D5,$44,$4D,$3E
    DB $06,$CD,$B5,$21,$3E,$0A,$CD,$ED,$21,$D1,$C9,$CD,$45,$7D,$CD,$D1
    DB $7E,$C9,$CD,$60,$7D,$CD,$D1,$7E,$C9,$E5,$C5,$47,$CD,$B7,$33,$E5
    DB $78,$CD,$A9,$33,$C1,$CD,$14,$33,$C1,$E1,$C9,$E5,$C5,$47,$CD,$BE
    DB $33,$E5,$78,$CD,$B0,$33,$C1,$CD,$14,$33,$C1,$E1,$C9,$EA,$4C,$DB
    DB $CD,$A2,$33,$01,$E7,$03,$CD,$14,$33,$30,$24,$E5,$FA,$4C,$DB,$CD
    DB $50,$66,$FA,$6C,$C8,$B7,$20,$07,$FA,$4C,$DB,$FE,$04,$30,$04,$CB
    DB $21,$CB,$10,$CB,$21,$CB,$10,$E1,$CD,$14,$33,$30,$02,$37,$C9,$28
    DB $FC,$AF,$C9,$EA,$4C,$DB,$21,$03,$DC,$CD,$3F,$7E,$01,$FF,$01,$CD
    DB $14,$33,$28,$19,$30,$17,$E5,$FA,$4C,$DB,$CD,$65,$66,$FA,$4C,$DB
    DB $EA,$74,$DD,$CD,$83,$7E,$E1,$CD,$14,$33,$30,$01,$C9,$AF,$C9
.L7E03:
    LD A,L
    LD ($DB4C),A
    LD A,H
    LD ($DB4D),A
    LD A,E
    LD ($DB4E),A
    LD A,D
    LD ($DB4F),A
    LD HL,$5101
    RST $10  ; -> bank81/fn1
    RET
Bank82_fn6:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    LD A,($DB4C)
    LD HL,$7E31
    CALL .L7E46
    CALL $0008
    LD ($DB4C),A
    POP HL
    POP DE
    POP BC
    POP AF
    RET
    DB $E9,$49,$7B,$4E,$7B,$53,$7B,$58,$7B,$5D,$7B,$62,$7B,$67,$7B
.L7E3F:
    CALL .L7E46
    LD A,(HL+)
    LD H,(HL)
    LD L,A
    RET
.L7E46:
    ADD A,A
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    RET
    DB $CD,$5D,$7E,$7E,$EA,$31,$DA,$21,$01,$03,$D7,$FA,$33,$DA,$C9
.L7E5D:
    LD A,($DB89)
    LD HL,$DC3C
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    RET
.L7E6A:
    CP $03
    RET Z
    PUSH BC
    PUSH HL
    LD B,A
    LD A,($DB88)
    LD HL,$DB42
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    AND $04
    LD A,B
    POP HL
    POP BC
    RET
    DB $FA,$6C,$C8,$B7,$20,$07,$FA,$74,$DD,$FE,$04,$30,$04,$CB,$21,$CB
    DB $10,$CB,$21,$CB,$10,$C9,$E5,$F5,$FA,$89,$DB,$21,$13,$DD,$85,$6F
    DB $3E,$00,$8C,$67,$36,$03,$F1,$E1,$C9
.L7EAC:
    SCF
    CCF
    RET
.L7EAF:
    LD HL,$5310
    RST $10  ; -> bank83/fn16
    LD A,($DB4C)
    OR A
    RET
    DB $CB,$38,$CB,$19,$CB,$38,$CB,$19
.L7EC0:
    SRL B
    RR C
    RET
.L7EC5:
    SRL H
    RR L
.L7EC9:
    SRL H
    RR L
    SRL H
    RR L
.L7ED1:
    SRL H
    RR L
    RET
.L7ED6:
    CP $03
    JR NC,.L7EF4
.L7EDA:
    PUSH HL
    LD HL,$CAC2
    CALL $25F8
    LD E,L
    LD D,H
    POP HL
    PUSH HL
    CALL $106C
    POP HL
.L7EE9:
    LD A,(HL)
    CP $F0
    RET Z
    INC HL
    JR .L7EE9
.L7EF0:
    LD A,B
    POP BC
    JR .L7EDA
.L7EF4:
    PUSH BC
    LD B,A
    AND $03
    CP $03
    LD A,B
    POP BC
    JR Z,.L7F1D
    PUSH BC
    LD B,A
    LD A,($C86C)
    OR A
    JR NZ,.L7EF0
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
    JR NZ,.L7F1A
    LD A,B
.L7F1A:
    POP BC
    JR NZ,.L7F45
.L7F1D:
    PUSH AF
    CALL .L7F27
    POP AF
    LD HL,$5104
    RST $10  ; -> bank81/fn4
    RET
.L7F27:
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
.L7F45:
    CALL .L7EDA
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
    JR Z,.L7F71
    CP $02
    JR Z,.L7F7B
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F97
    INC HL
    CP (HL)
    JR Z,.L7F97
    JR .L7FA6
.L7F71:
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F9C
    LD A,(HL+)
    CP (HL)
    JR Z,.L7F97
    JR .L7FA6
.L7F7B:
    LD D,$00
    INC HL
    INC HL
    LD A,(HL-)
    DEC HL
    CP (HL)
    JR NZ,.L7F85
    INC D
.L7F85:
    INC HL
    CP (HL)
    JR NZ,.L7F8A
    INC D
.L7F8A:
    LD A,D
    OR A
    JR Z,.L7FA6
    CP $01
    JR Z,.L7F9C
    POP HL
    LD A,$0C
    JR .L7F9F
.L7F97:
    POP HL
    LD A,$0A
    JR .L7F9F
.L7F9C:
    POP HL
    LD A,$0B
.L7F9F:
    LD ($DB4D),A
    LD (HL+),A
    LD (HL),$F0
    RET
.L7FA6:
    POP HL
    XOR A
    LD ($DB4D),A
    RET
    DB $21,$A0,$C1,$18,$03
.L7FB1:
    LD HL,$C180
    LD A,L
    LD ($DB4E),A
    LD A,H
    LD ($DB4F),A
    LD A,($DB89)
    LD ($DB50),A
    CALL .L7ED6
    RET
