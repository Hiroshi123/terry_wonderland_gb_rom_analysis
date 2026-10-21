; ============================================================================
; Bank 18 ($12) — BATTLE-EFFECT ANIMATOR (bank9 BattleAnim delegate)
; ============================================================================
;   File offset $48000-$4BFFF (16 KB), mapped $4000-$7FFF.
;
; ONLY fn0 ($4003) is a real entry, and its ONLY caller is bank9 (battle) at
; $402E (BattleAnim_BnkCallB, for $C8EF phases 3/8/9/10). So this bank is a
; battle-scene effect animator, NOT an overworld area controller.
;   (The old "fn1 $EFFA / fn2 $C7C8 / fn3-fn7" table entries were a MISREAD:
;    $EFFA/$C7C8 are just fn0 code bytes, and the "fn3-fn7" slots are actually
;    fn0 RST$00 STATE table entries at $4007 — bank18 exposes only fn0.)
;
; fn0: LD A,($C8EF); RST$00 -> 16-entry state table at $4007. Active states:
;   3  -> $4455  scroll sub-machine on $C905 (wScrollPhase)  [see below]
;   8  -> $6079  battle-scroll phase A      (not yet disassembled)
;   9  -> $6851  battle-scroll phase B      (not yet disassembled)
;   10 -> $6B0D  transition / connect       (not yet disassembled)
;   all others -> $4027 (RET).
;
; $C905 = wScrollPhase. State 3 ($4455) runs the SAME scroll/BG-build engine
; as bank19 fn3 and bank25 phase0: Sub_4028 tile-aligns hScrollX/Y ($FFB7/$FFBB),
; builds a $9800 BG row (via $C909/$C90A), and SafeTileLoads a tileset. Its 6
; scroll phases dispatch through the $4459 table (phase0 $4463 = init/build).
;
; Bytes $4003-$4062 (control core) + the $4455 dispatcher are byte-exact below;
; the phase handlers ($4463+, $6079/$6851/$6B0D) and lower message routines are
; only partially covered. wram: $C8EF wAnimPhase, $C905 wScrollPhase,
; $C8DA scroll-state array, $C909/$C90A BG row ptr, $FFB7/$FFBB hScrollX/Y.
; ============================================================================
SECTION "Bank18 Core", ROMX[$4003], BANK[18]
Bank18_Fn0:                         ; $4003  (battle-anim phase dispatcher)
    LD A,($C8EF)               ; $4003 [FA EF C8]  ; wAnimPhase (bank9 BattleAnim outer state $C8EF)
    RST $00                    ; $4006 [C7]  ; dispatch on phase via the 16-entry table below
    ; RST$00 state table (16 entries, indexed by $C8EF):
    dw $4027   ; $4007  state 0 (RET stub $4027)
    dw $4027   ; $4009  state 1 (RET stub $4027)
    dw $4027   ; $400B  state 2 (RET stub $4027)
    dw $4455   ; $400D  state 3 -> $4455 scroll driver
    dw $4027   ; $400F  state 4 (RET stub $4027)
    dw $4027   ; $4011  state 5 (RET stub $4027)
    dw $4027   ; $4013  state 6 (RET stub $4027)
    dw $4027   ; $4015  state 7 (RET stub $4027)
    dw $6079   ; $4017  state 8 -> $6079 scroll A
    dw $6851   ; $4019  state 9 -> $6851 scroll B
    dw $6B0D   ; $401B  state 10 -> $6B0D connect
    dw $4027   ; $401D  state 11 (RET stub $4027)
    dw $4027   ; $401F  state 12 (RET stub $4027)
    dw $4027   ; $4021  state 13 (RET stub $4027)
    dw $4027   ; $4023  state 14 (RET stub $4027)
    dw $4027   ; $4025  state 15 (RET stub $4027)
Bank18_RetStub:                     ; $4027
    RET                        ; $4027 [C9]  ; shared RET stub (inactive phases)
Bank18_ScrollStep:                  ; $4028
    LD A,(HL)                  ; $4028 [7E]  ; --- Sub_4028: advance a 16-bit scroll value +4, then snap to 8px ---
    ADD A,$04                  ; $4029 [C6 04]  ; += 4
    LD (HL+),A                 ; $402B [22]
    LD A,(HL)                  ; $402C [7E]
    ADC A,$00                  ; $402D [CE 00]
    LD (HL-),A                 ; $402F [32]
    LD A,(HL)                  ; $4030 [7E]
    AND $F8                    ; $4031 [E6 F8]  ; clear low 3 bits (tile-align)
    LD (HL),A                  ; $4033 [77]
    RET                        ; $4034 [C9]
Bank18_VramColAdv:                  ; $4035
    PUSH AF                    ; $4035 [F5]  ; --- Sub_4035: VRAM col advance: L=(L&$E0)|((L+1)&$1F) (wrap in 32-tile row) ---
    LD A,L                     ; $4036 [7D]
    AND $E0                    ; $4037 [E6 E0]
    PUSH AF                    ; $4039 [F5]
    LD A,L                     ; $403A [7D]
    INC A                      ; $403B [3C]
    AND $1F                    ; $403C [E6 1F]
    LD L,A                     ; $403E [6F]
    POP AF                     ; $403F [F1]
    OR L                       ; $4040 [B5]
    LD L,A                     ; $4041 [6F]
    POP AF                     ; $4042 [F1]
    RET                        ; $4043 [C9]
Bank18_VramRowBase:                 ; $4044
    LD A,($C909)               ; $4044 [FA 09 C9]  ; --- Sub_4044: VRAM row base = $C909/$C90A + HL, wrapped into $9800-$9BFF ---
    ADD A,L                    ; $4047 [85]
    LD L,A                     ; $4048 [6F]
    LD A,($C90A)               ; $4049 [FA 0A C9]
    ADC A,H                    ; $404C [8C]
    AND $03                    ; $404D [E6 03]
    LD H,A                     ; $404F [67]
    LD A,($C90A)               ; $4050 [FA 0A C9]
    AND $FC                    ; $4053 [E6 FC]
    OR H                       ; $4055 [B4]
    LD H,A                     ; $4056 [67]
    RET                        ; $4057 [C9]
Bank18_BufBase:                     ; $4058
    LD A,L                     ; $4058 [7D]  ; --- Sub_4058: HL += $C500 (WRAM staging-buffer base) ---
    ADD A,$00                  ; $4059 [C6 00]
    LD L,A                     ; $405B [6F]
    LD A,H                     ; $405C [7C]
    ADC A,$C5                  ; $405D [CE C5]
    LD H,A                     ; $405F [67]
    RET                        ; $4060 [C9]

; ----- state-3 handler: scroll sub-machine keyed on $C905 (wScrollPhase) -----
Bank18_Phase3_ScrollDriver:         ; $4455  ($C8EF state 3)
    LD A,($C905)               ; $4455 [FA 05 C9]  ; wScrollPhase — nested scroll sub-machine (battle-anim phase 3)
    RST $00                    ; $4458 [C7]  ; dispatch on wScrollPhase via the table below
    ; $4459 scroll-phase table (phase 0 builds the scene; 3/4 finalize):
    dw $4463   ; $4459  scrollphase 0
    dw $44DC   ; $445B  scrollphase 1
    dw $4507   ; $445D  scrollphase 2
    dw $4563   ; $445F  scrollphase 3
    dw $4573   ; $4461  scrollphase 4
    ; phase-0 handler $4463 (init/build) and phases 1-4 not disassembled here.


; ============================================================================
; MESSAGE DISPLAY — three CALL $0EC5 (MsgBankRouter, ROM0) sites
; ============================================================================
; MsgBankRouter (ROM0 $0EC5) takes HL = a 16-bit GLOBAL message id, splits it by
; high/low byte, re-bases it to a bank-local index ($C822/$C823 = wMsgIndex),
; and RST $10s into the owning text bank's fn0 (banks 66-75/78) to print.
; ------------------------------------------------------------
; Bank18_ShowMsg  ($441F)  — dynamic event message (identical to bank10 $441F)
; ------------------------------------------------------------
Bank18_ShowMsg:
    LD A,($C8F0)
    ADD A,L
    LD L,A                              ; + wMsgId lo
    LD A,($C8F1)
    ADC A,H
    LD H,A                              ; HL = base + $C8F1:$C8F0 = global msg id
    CALL $0EC5                          ; MsgBankRouter → route to text bank + print
    RET

; --- $460F: area-init routine — hard-coded bank74 flavor text (excerpt) -------
;   (pre-sets $C822/$C823=$0233 for the CALL $411A window setup, then routes $06E1)
Bank18_Sub_460F:
    LD A,$02
    LD ($C822),A                        ; wMsgIndex hi (for $411A)
    LD A,$33
    LD ($C823),A                        ; wMsgIndex lo (for $411A)
    LD HL,$8AA0
    LD DE,$0601
    CALL $411A                          ; window/text setup
    LD HL,$06E1                         ; global id $06E1 → bank74 local ~481
    CALL $0EC5                          ; MsgBankRouter  (NOTE: 481 is past bank74's
                                        ;   480-entry table — an edge / likely-unused id)
    ; ... (continues)

; --- $5E54: after a $14-row table scan — show bank74 message #460 (excerpt) ---
Bank18_ShowStarMsg:
    LD HL,$06CC                         ; global id $06CC → bank74 #460
    CALL $0EC5                          ; MsgBankRouter → print
    ; 「そらが すみわたっているよ。ほしが きれいにしてくれたんだ！」
    ;  ("The sky is crystal clear — the stars made it beautiful!")


; ============================================================================
; Bank18 state-3 SCROLL SUB-MACHINE ($4463-$45AA) — dispatched by $4455 on
; $C905 (wScrollPhase). An interactive battle-scene prompt: build a backdrop,
; load tiles, WAIT for the player (A confirm / B|Start cancel), dispatch on the
; selection $C8DA, then finalize and clear $C8EB bit4 (leave the battle overlay).
; ============================================================================
SECTION "Bank18 Phase3 ScrollSM", ROMX[$4463], BANK[18]
Bank18_P3S0_Build:                  ; $4463  (scroll phase 0)
    LD HL,$FFB7                ; $4463 [21 B7 FF]  ; phase 0: BUILD backdrop
    CALL $4028                 ; $4466 [CD 28 40]  ; tile-align hScrollX
    LD HL,$FFBB                ; $4469 [21 BB FF]
    CALL $4028                 ; $446C [CD 28 40]  ; tile-align hScrollY
    LD HL,$C8DA                ; $446F [21 DA C8]  ; clear $C8DA (8)
    LD BC,$0008                ; $4472 [01 08 00]
    LD A,$00                   ; $4475 [3E 00]
    CALL $169A                 ; $4477 [CD 9A 16]
    LDH A,($BB)                ; $447A [F0 BB]
    LD L,A                     ; $447C [6F]
    LD H,$00                   ; $447D [26 00]
    ADD HL,HL                  ; $447F [29]
    ADD HL,HL                  ; $4480 [29]
    LDH A,($B7)                ; $4481 [F0 B7]
    RRCA                       ; $4483 [0F]
    RRCA                       ; $4484 [0F]
    RRCA                       ; $4485 [0F]
    ADD A,L                    ; $4486 [85]
    LD L,A                     ; $4487 [6F]
    LD A,H                     ; $4488 [7C]
    ADC A,$98                  ; $4489 [CE 98]
    LD H,A                     ; $448B [67]
    LD A,H                     ; $448C [7C]
    AND $03                    ; $448D [E6 03]
    OR $98                     ; $448F [F6 98]
    LD H,A                     ; $4491 [67]
    LD A,L                     ; $4492 [7D]
    LD ($C909),A               ; $4493 [EA 09 C9]  ; -> $C909/$C90A ($9800 BG row ptr)
    LD A,H                     ; $4496 [7C]
    LD ($C90A),A               ; $4497 [EA 0A C9]
    CALL $41EF                 ; $449A [CD EF 41]
    LD DE,$2E10                ; $449D [11 10 2E]
    LD HL,$8800                ; $44A0 [21 00 88]
    CALL $194A                 ; $44A3 [CD 4A 19]  ; SafeTileLoad bank$2E blk$10 -> VRAM $8800
    LD A,$02                   ; $44A6 [3E 02]
    LD ($C822),A               ; $44A8 [EA 22 C8]
    LD A,$44                   ; $44AB [3E 44]
    LD ($C823),A               ; $44AD [EA 23 C8]
    LD HL,$9600                ; $44B0 [21 00 96]
    LD DE,$0501                ; $44B3 [11 01 05]
    CALL $411A                 ; $44B6 [CD 1A 41]
    LD A,$02                   ; $44B9 [3E 02]
    LD ($C822),A               ; $44BB [EA 22 C8]
    LD A,$33                   ; $44BE [3E 33]
    LD ($C823),A               ; $44C0 [EA 23 C8]
    LD HL,$8AA0                ; $44C3 [21 A0 8A]
    LD DE,$0601                ; $44C6 [11 01 06]
    CALL $411A                 ; $44C9 [CD 1A 41]  ; window/text setup ($411A)
    CALL $4323                 ; $44CC [CD 23 43]
    LD A,$60                   ; $44CF [3E 60]
    LDH ($D4),A                ; $44D1 [E0 D4]
    LD HL,$0105                ; $44D3 [21 05 01]
    RST $10                    ; $44D6 [D7]  ; bankcall -> bank1 fn5
    LD HL,$C905                ; $44D7 [21 05 C9]
    INC (HL)                   ; $44DA [34]  ; -> phase 1
    RET                        ; $44DB [C9]
Bank18_P3S1_Load:                   ; $44DC  (scroll phase 1)
    LD HL,$C905                ; $44DC [21 05 C9]  ; phase 1: LOAD more tiles -> phase 2
    INC (HL)                   ; $44DF [34]
    XOR A                      ; $44E0 [AF]
    LD ($C8EC),A               ; $44E1 [EA EC C8]  ; clear $C8EC
    CALL $41EF                 ; $44E4 [CD EF 41]
    CALL $44EE                 ; $44E7 [CD EE 44]  ; load two blocks ($70CE,$31D6) via $44EE
    CALL $40E5                 ; $44EA [CD E5 40]
    RET                        ; $44ED [C9]
Bank18_LoadTwoBlocks:               ; $44EE
    LD DE,$70CE                ; $44EE [11 CE 70]  ; helper: load 2 tile blocks via $40B4 + $4323, prep $4555 table
    CALL $40B4                 ; $44F1 [CD B4 40]
    LD DE,$31D6                ; $44F4 [11 D6 31]
    CALL $40B4                 ; $44F7 [CD B4 40]
    CALL $4323                 ; $44FA [CD 23 43]
    LD DE,$4555                ; $44FD [11 55 45]
    LD A,($C8DA)               ; $4500 [FA DA C8]
    CALL $43E2                 ; $4503 [CD E2 43]
    RET                        ; $4506 [C9]
Bank18_P3S2_Prompt:                 ; $4507  (scroll phase 2 = input wait)
    LD DE,$4555                ; $4507 [11 55 45]  ; phase 2: INTERACTIVE prompt (draw options, wait for input)
    LD HL,$C8DA                ; $450A [21 DA C8]
    LD B,$06                   ; $450D [06 06]
    CALL $42CA                 ; $450F [CD CA 42]
    LD A,($C846)               ; $4512 [FA 46 C8]  ; read joypad $C846
    AND $0A                    ; $4515 [E6 0A]  ; B/Start ($0A)? -> cancel: skip to phase 4
    JR Z,$4523                 ; $4517 [28 0A]
    LD HL,$C905                ; $4519 [21 05 C9]
    INC (HL)                   ; $451C [34]
    LD HL,$C905                ; $451D [21 05 C9]
    INC (HL)                   ; $4520 [34]
    JR $4554                   ; $4521 [18 31]
    LD A,($C846)               ; $4523 [FA 46 C8]
    BIT 0,A                    ; $4526 [CB 47]  ; A pressed? -> confirm
    JR Z,$4554                 ; $4528 [28 2A]
    LD A,$59                   ; $452A [3E 59]  ; SFX $59
    CALL $1EFF                 ; $452C [CD FF 1E]
    LD HL,$C905                ; $452F [21 05 C9]
    INC (HL)                   ; $4532 [34]  ; -> phase 3
    XOR A                      ; $4533 [AF]
    LD ($C906),A               ; $4534 [EA 06 C9]
    LD HL,$C8DA                ; $4537 [21 DA C8]
    SET 7,(HL)                 ; $453A [CB FE]  ; SET $C8DA bit7 (selection made); clear $C8DB(7)/$C8E2(8)
    LD HL,$C8DB                ; $453C [21 DB C8]
    LD BC,$0007                ; $453F [01 07 00]
    LD A,$00                   ; $4542 [3E 00]
    CALL $169A                 ; $4544 [CD 9A 16]
    LD HL,$C8E2                ; $4547 [21 E2 C8]
    LD BC,$0008                ; $454A [01 08 00]
    LD A,$00                   ; $454D [3E 00]
    CALL $169A                 ; $454F [CD 9A 16]
    JR $4554                   ; $4552 [18 00]
    RET                        ; $4554 [C9]  ; RET
Bank18_P3_OptTable:  ; $4555-$4562  7 option/msg-id words ($42CA index by $C8DA; $FFFF end)
    dw $0021   ; $4555
    dw $0061   ; $4557
    dw $00A1   ; $4559
    dw $00E1   ; $455B
    dw $0121   ; $455D
    dw $0161   ; $455F
    dw $FFFF   ; $4561
Bank18_P3S3_Dispatch:               ; $4563  (scroll phase 3)
    LD A,($C8DA)               ; $4563 [FA DA C8]  ; phase 3: dispatch on selection $C8DA
    RST $00                    ; $4566 [C7]
Bank18_P3S3_Table:  ; $4567-$4572  phase-3 handlers by selection $C8DA (last = phase4 $4573)
    dw $45AB   ; $4567
    dw $4C49   ; $4569
    dw $54C9   ; $456B
    dw $59DF   ; $456D
    dw $5E04   ; $456F
    dw $4573   ; $4571
Bank18_P3S4_Finalize:               ; $4573  (scroll phase 4 = exit)
    CALL $41EF                 ; $4573 [CD EF 41]  ; phase 4: FINALIZE + EXIT
    LD DE,$31D6                ; $4576 [11 D6 31]  ; reload block $31D6
    CALL $40B4                 ; $4579 [CD B4 40]
    CALL $40E5                 ; $457C [CD E5 40]
    CALL $28E7                 ; $457F [CD E7 28]  ; ROM0 $28E7
    LD HL,$C13C                ; $4582 [21 3C C1]
    LD DE,$C1C0                ; $4585 [11 C0 C1]
    CALL $45A2                 ; $4588 [CD A2 45]  ; copy OAM stage $C13C->$C1C0 (20B)
    LD HL,$C150                ; $458B [21 50 C1]
    LD DE,$C1E0                ; $458E [11 E0 C1]
    CALL $45A2                 ; $4591 [CD A2 45]  ; $C150->$C1E0 (20B)
    LD A,$80                   ; $4594 [3E 80]
    LDH ($D3),A                ; $4596 [E0 D3]
    LD HL,$C8EB                ; $4598 [21 EB C8]
    RES 4,(HL)                 ; $459B [CB A6]  ; RES $C8EB bit4 = leave battle-scene overlay
    XOR A                      ; $459D [AF]
    LD ($C905),A               ; $459E [EA 05 C9]  ; $C905 = 0
    RET                        ; $45A1 [C9]
Bank18_Copy20:                      ; $45A2
    LD B,$14                   ; $45A2 [06 14]  ; helper: copy 20 bytes (DE)->(HL)
    LD A,(DE)                  ; $45A4 [1A]
    LD (HL+),A                 ; $45A5 [22]
    INC DE                     ; $45A6 [13]
    DEC B                      ; $45A7 [05]
    JR NZ,$45A4                ; $45A8 [20 FA]
    RET                        ; $45AA [C9]


; ============================================================================
; Bank18 states 8/9/10 (//B0D) — each is its OWN $C905 (wScrollPhase)
; sub-machine (same LD A,($C905);RST$00 pattern as state 3), for later battle-
; scene phases. Entries + phase tables below are byte-exact; the individual phase
; HANDLER bodies are large and not yet disassembled (addresses listed).
; ============================================================================
SECTION "Bank18 State8", ROMX[$6079], BANK[18]
Bank18_State8:                          ; $6079  ($C8EF state; $C905 sub-machine)
    LD A,($C905)               ; $6079 [FA 05 C9]  ; wScrollPhase
    RST $00                    ; $607C [C7]  ; dispatch
    ; phase table (5 entries) — handler bodies TBD:
    dw $6087   ; $607D  phase 0
    dw $60E4   ; $607F  phase 1
    dw $60E9   ; $6081  phase 2
    dw $6108   ; $6083  phase 3
    dw $610B   ; $6085  phase 4
SECTION "Bank18 State9", ROMX[$6851], BANK[18]
Bank18_State9:                          ; $6851  ($C8EF state; $C905 sub-machine)
    LD A,($C905)               ; $6851 [FA 05 C9]  ; wScrollPhase
    RST $00                    ; $6854 [C7]  ; dispatch
    ; phase table (5 entries) — handler bodies TBD:
    dw $685F   ; $6855  phase 0
    dw $68AF   ; $6857  phase 1
    dw $68B4   ; $6859  phase 2
    dw $68D3   ; $685B  phase 3
    dw $68D5   ; $685D  phase 4
SECTION "Bank18 State10", ROMX[$6B0D], BANK[18]
Bank18_State10:                          ; $6B0D  ($C8EF state; $C905 sub-machine)
    LD A,($C905)               ; $6B0D [FA 05 C9]  ; wScrollPhase
    RST $00                    ; $6B10 [C7]  ; dispatch
    ; phase table (7 entries) — handler bodies TBD:
    dw $6B1D   ; $6B11  phase 0
    dw $6B8B   ; $6B13  phase 1
    dw $6BFD   ; $6B15  phase 2
    dw $6C9F   ; $6B17  phase 3
    dw $6CB9   ; $6B19  phase 4
    dw $6D29   ; $6B1B  phase 5
    dw $5121   ; $6B1D  phase 6
