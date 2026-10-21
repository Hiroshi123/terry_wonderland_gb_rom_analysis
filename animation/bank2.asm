; ============================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Bank 2 — Battle sprite / animation orchestration engine
; ============================================================
;
; Bank 2 ($8000-$BFFF in ROM, mapped to $4000-$7FFF in CPU).
; Dispatch table at $4001: 6 entries (fn0-fn5).
;   fn0=$400D  fn1=$4E9F  fn2=$512C
;   fn3=$5FD6  fn4=$6A78  fn5=$6B0A
;
; Called from:
;   bank95 fn3 → RST$10 bank2 fn4 (per-frame sprite tick)
;   bank95 fn0/fn1 → RST$10 bank2 fn1 (scene init)
;
; RST $00  — indexed jump: A = case index, table follows inline.
; RST $10  — banked call: bank=(HL>>8), fn=(HL&$FF) from preceding LD HL.
;

; Key WRAM / HRAM variables used in this bank:
;
;   Event queue (fn0, fn5):
;     $D7B4/$D7B5  evt_ptr       pointer to 6-byte event-queue entry
;
;   Object state machine (fn2, fn3, fn4):
;     $C0FC  obj_state_lo   state index (0-15) OR sprite-ptr lo byte
;     $C0FD  obj_state_hi   sub-counter        OR sprite-ptr hi byte
;     $C0D8  obj_phase      sub-state/phase within current object step
;     $C0D9  obj_init_y     initial Y ($80) set on state transition
;     $C0DA-$C0DF           misc object state variables
;     $C0E0  obj_pos_x      sprite X position ($50=80px)
;     $C0E1  obj_pos_y      sprite Y position ($30=48px)
;     $C0E2-$C0E5           scroll/position accumulators
;     $D9CB  flag_D9CB      cleared on certain state advances
;
;   Scene (shared with bank95):
;     $C88B  scene_mode     outer scene branch (0-3)
;     $C817/$C818            cleared at scene init
;
;   HRAM sprite init block (written before spawn, read by VBlank handler):
;     $FFBB  spr_wait       wait counter (DEC'd per frame; 0 → advance state)
;     $FFC3  spr_x          sprite X position
;     $FFC4  spr_x_hi       always 0
;     $FFC5  spr_y          sprite Y position
;     $FFC6  spr_y_hi       always 0
;     $FFC7  spr_tile       tile index / audio sequence track select
;     $FFC8  spr_note       current note/param value (updated by fn4)
;     $FFC9  spr_attr       OAM attribute byte
;     $FFCA  spr_pad        padding / always 0
;     $FFD3  spr_unk_D3     cleared each fn4 tick
;
; ============================================================

SECTION "Bank 2", ROMX[$4000], BANK[2]
; Dispatch table at $4001:
; fn0=$400D  fn1=$4E9F  fn2=$512C  fn3=$5FD6  fn4=$6A78  fn5=$6B0A


; ──────────────────────────────────────────────────────────────────
; Bank2_Fn0  ($400D)
; ──────────────────────────────────────────────────────────────────
; Event-sequence step processor.
; Pointer $D7B4/$D7B5 → 6-byte event-queue entry:
;   [0]   status: 0=free/active, 1=completed
;   [1]   3-level table index A (→ $40E3)
;   [2]   3-level table index B
;   [3]   3-level table index C
;   [4]   payload lo   (result of table lookup, or accumulated)
;   [5]   payload hi
; On each call: checks [0] (active), reads table at $40E3[A][B][C]→(lo,hi).
;   • lo=$FF → end of sequence: mark entry done ([0]=1)
;   • lo=$FE → dispatch on hi (5 cases): e.g. case 0→no-op, cases 1-3→loop,
;              case 4→INC [3]
;   • lo=$FD → PlaySFX(hi)
;   • lo<$F8 → store as payload at [4],[5]
; Also decrements [5] (countdown); when 0 advance [4], then re-check entry.
; Table $40E3: 16-entry level-1 ptr table → level-2 table → level-3 leaf.
; Leaf entries: 2-byte pairs (lo,hi) = sequence commands.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn0:
    LD A,($D7B4)                                     ; $400D  [FA B4 D7]  ; evt_ptr_lo
    LD L,A                                           ; $4010  [6F]
    LD A,($D7B5)                                     ; $4011  [FA B5 D7]  ; evt_ptr_hi
    LD H,A                                           ; $4014  [67]
    LD A,(HL)                                        ; $4015  [7E]
    OR A                                             ; $4016  [B7]
    JR Z,$401E                                       ; $4017  [28 05]
    CALL $4028                                       ; $4019  [CD 28 40]
    JR $4027                                         ; $401C  [18 09]
Loc_401E:
    INC (HL)                                         ; $401E  [34]
    INC HL                                           ; $401F  [23]
    INC HL                                           ; $4020  [23]
    INC HL                                           ; $4021  [23]
    LD (HL),$00                                      ; $4022  [36 00]
    CALL $404E                                       ; $4024  [CD 4E 40]
Loc_4027:
    RET                                              ; $4027  [C9]
Loc_4028:
    LD A,($D7B4)                                     ; $4028  [FA B4 D7]  ; evt_ptr_lo
    ADD A,$05                                        ; $402B  [C6 05]
    LD L,A                                           ; $402D  [6F]
    LD A,($D7B5)                                     ; $402E  [FA B5 D7]  ; evt_ptr_hi
    ADC A,$00                                        ; $4031  [CE 00]
    LD H,A                                           ; $4033  [67]
    LD A,(HL)                                        ; $4034  [7E]
    CP $FF                                           ; $4035  [FE FF]
    DB $C8                                           ; $4037  [C8]
    OR A                                             ; $4038  [B7]
    JR Z,$4041                                       ; $4039  [28 06]
    DEC A                                            ; $403B  [3D]
    LD (HL-),A                                       ; $403C  [32]
    LD A,(HL)                                        ; $403D  [7E]
    CP $FF                                           ; $403E  [FE FF]
    RET                                              ; $4040  [C9]
Loc_4041:
    LD A,($D7B4)                                     ; $4041  [FA B4 D7]  ; evt_ptr_lo
    ADD A,$03                                        ; $4044  [C6 03]
    LD L,A                                           ; $4046  [6F]
    LD A,($D7B5)                                     ; $4047  [FA B5 D7]  ; evt_ptr_hi
    ADC A,$00                                        ; $404A  [CE 00]
    LD H,A                                           ; $404C  [67]
    INC (HL)                                         ; $404D  [34]
Loc_404E:
    CALL $40B3                                       ; $404E  [CD B3 40]
    LD A,B                                           ; $4051  [78]
    AND C                                            ; $4052  [A1]
    CP $FF                                           ; $4053  [FE FF]
    JR NZ,$4062                                      ; $4055  [20 0B]
    LD A,($D7B4)                                     ; $4057  [FA B4 D7]  ; evt_ptr_lo
    LD L,A                                           ; $405A  [6F]
    LD A,($D7B5)                                     ; $405B  [FA B5 D7]  ; evt_ptr_hi
    LD H,A                                           ; $405E  [67]
    LD (HL),$00                                      ; $405F  [36 00]
    RET                                              ; $4061  [C9]
Loc_4062:
    LD A,C                                           ; $4062  [79]
    CP $FF                                           ; $4063  [FE FF]
    JR NZ,$4067                                      ; $4065  [20 00]
Loc_4067:
    LD A,C                                           ; $4067  [79]
    CP $F8                                           ; $4068  [FE F8]
    JR C,$4086                                       ; $406A  [38 1A]
    CP $FE                                           ; $406C  [FE FE]
    JR NZ,$407C                                      ; $406E  [20 0C]
    LD A,B                                           ; $4070  [78]
    RST $00                                          ; $4071  [C7 96 40 9C 40 9C 40 9C 40 9F 40]  ; switch(A)→[$4096 $409C $409C $409C $409F] tbl=[C7 96 40 9C 40 9C 40 9C 40 9F 40]
Loc_407C:
    CP $FD                                           ; $407C  [FE FD]
    JR NZ,$4086                                      ; $407E  [20 06]
    LD A,B                                           ; $4080  [78]
    CALL $1EFF                                       ; $4081  [CD FF 1E]  ; PlaySFX
    JR $4041                                         ; $4084  [18 BB]
Loc_4086:
    LD A,($D7B4)                                     ; $4086  [FA B4 D7]  ; evt_ptr_lo
    ADD A,$04                                        ; $4089  [C6 04]
    LD L,A                                           ; $408B  [6F]
    LD A,($D7B5)                                     ; $408C  [FA B5 D7]  ; evt_ptr_hi
    ADC A,$00                                        ; $408F  [CE 00]
    LD H,A                                           ; $4091  [67]
    LD A,C                                           ; $4092  [79]
    LD (HL+),A                                       ; $4093  [22]
    LD (HL),B                                        ; $4094  [70]
    RET                                              ; $4095  [C9]
Loc_4096:
    LD BC,$FFFF                                      ; $4096  [01 FF FF]
    JP $4086                                         ; $4099  [C3 86 40]
Loc_409C:
    JP $4041                                         ; $409C  [C3 41 40]
Loc_409F:
    LD A,($D7B4)                                     ; $409F  [FA B4 D7]  ; evt_ptr_lo
    ADD A,$03                                        ; $40A2  [C6 03]
    LD L,A                                           ; $40A4  [6F]
    LD A,($D7B5)                                     ; $40A5  [FA B5 D7]  ; evt_ptr_hi
    ADC A,$00                                        ; $40A8  [CE 00]
    LD H,A                                           ; $40AA  [67]
    LD A,$01                                         ; $40AB  [3E 01]
    LD (HL+),A                                       ; $40AD  [22]
    INC HL                                           ; $40AE  [23]
    INC (HL)                                         ; $40AF  [34]
    JP $4095                                         ; $40B0  [C3 95 40]
Loc_40B3:
    LD A,($D7B4)                                     ; $40B3  [FA B4 D7]  ; evt_ptr_lo
    LD C,A                                           ; $40B6  [4F]
    LD A,($D7B5)                                     ; $40B7  [FA B5 D7]  ; evt_ptr_hi
    LD B,A                                           ; $40BA  [47]
    INC BC                                           ; $40BB  [03]
    LD A,(BC)                                        ; $40BC  [0A]
    ADD A,A                                          ; $40BD  [87]
    LD HL,$40E3                                      ; $40BE  [21 E3 40]
    ADD A,L                                          ; $40C1  [85]
    LD L,A                                           ; $40C2  [6F]
    LD A,$00                                         ; $40C3  [3E 00]
    ADC A,H                                          ; $40C5  [8C]
    LD H,A                                           ; $40C6  [67]
    LD A,(HL+)                                       ; $40C7  [2A]
    LD H,(HL)                                        ; $40C8  [66]
    LD L,A                                           ; $40C9  [6F]
    INC BC                                           ; $40CA  [03]
    LD A,(BC)                                        ; $40CB  [0A]
    ADD A,A                                          ; $40CC  [87]
    ADD A,L                                          ; $40CD  [85]
    LD L,A                                           ; $40CE  [6F]
    LD A,$00                                         ; $40CF  [3E 00]
    ADC A,H                                          ; $40D1  [8C]
    LD H,A                                           ; $40D2  [67]
    LD A,(HL+)                                       ; $40D3  [2A]
    LD H,(HL)                                        ; $40D4  [66]
    LD L,A                                           ; $40D5  [6F]
    INC BC                                           ; $40D6  [03]
    LD A,(BC)                                        ; $40D7  [0A]
    ADD A,A                                          ; $40D8  [87]
    ADD A,L                                          ; $40D9  [85]
    LD L,A                                           ; $40DA  [6F]
    LD A,$00                                         ; $40DB  [3E 00]
    ADC A,H                                          ; $40DD  [8C]
    LD H,A                                           ; $40DE  [67]
    LD A,(HL+)                                       ; $40DF  [2A]
    LD B,(HL)                                        ; $40E0  [46]
    LD C,A                                           ; $40E1  [4F]
    RET                                              ; $40E2  [C9]

; ──────────────────────────────────────────────────────────────────
; Bank2_Fn1  ($4E9F)
; ──────────────────────────────────────────────────────────────────
; Scene initialization — parallel to bank95_Fn0 but for a different scene set.
; Calls SceneInit ($1637), clears $C817/$C818, sets GBC palette $02.
; Dispatches on scene_mode ($C88B), 4 cases ($4EBF, $4F85, $5012, $509F):
;   case 0 ($4EBF): load primary battle tilesets from $5B17 table entries
;                    into $9000/$8600/$8640/$8670/$8800/$8A00/$8B00/$8C00;
;                    build tilemap; init sprite blocks; set scene_next.
;   case 1 ($4F85): alternate tileset path (smaller set).
;   case 2 ($5012): third variant.
;   case 3 ($509F): fourth variant.
; All paths: RST $10 → bank8 fn1 (palette/DMA setup), then SceneMgr_Tick.
; 
; HRAM sprite init block ($FFC3-$FFCA) written per sprite before spawn:
;   $FFC3=X, $FFC4=0, $FFC5=Y, $FFC6=0,
;   $FFC7=tile/track, $FFC8=param, $FFC9=attr, $FFCA=0
; Sprite spawner called via RST $10 → bank5 fn0 or bank4 fn2.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn1:
    CALL $1637                                       ; $4E9F  [CD 37 16]  ; SceneInit
    LD HL,$C817                                      ; $4EA2  [21 17 C8]
    LD (HL),$00                                      ; $4EA5  [36 00]
    INC HL                                           ; $4EA7  [23]
    LD (HL),$00                                      ; $4EA8  [36 00]
    LD HL,$0801                                      ; $4EAA  [21 01 08]
    RST $10                                          ; $4EAD  [D7]  ; banked call → bank8 fn1
    LD A,$02                                         ; $4EAE  [3E 02]
    CALL $1EB4                                       ; $4EB0  [CD B4 1E]  ; SetBGPalette
    LD A,($C88B)                                     ; $4EB3  [FA 8B C8]  ; scene_mode
    RST $00                                          ; $4EB6  [C7 BF 4E 85 4F 12 50 9F 50]  ; switch(A)→[$4EBF $4F85 $5012 $509F] tbl=[C7 BF 4E 85 4F 12 50 9F 50]
Loc_4EBF:
    LD A,$FC                                         ; $4EBF  [3E FC]
    CALL $1A5B                                       ; $4EC1  [CD 5B 1A]  ; TileLoad_Setup
    LD DE,$5B17                                      ; $4EC4  [11 17 5B]
    LD HL,$9000                                      ; $4EC7  [21 00 90]
    CALL $18A2                                       ; $4ECA  [CD A2 18]  ; TileLoad
    LD DE,$5B18                                      ; $4ECD  [11 18 5B]
    LD HL,$8600                                      ; $4ED0  [21 00 86]
    CALL $18A2                                       ; $4ED3  [CD A2 18]  ; TileLoad
    LD DE,$5B19                                      ; $4ED6  [11 19 5B]
    LD HL,$8640                                      ; $4ED9  [21 40 86]
    CALL $18A2                                       ; $4EDC  [CD A2 18]  ; TileLoad
    LD DE,$5B1A                                      ; $4EDF  [11 1A 5B]
    LD HL,$8670                                      ; $4EE2  [21 70 86]
    CALL $18A2                                       ; $4EE5  [CD A2 18]  ; TileLoad
    LD DE,$2F00                                      ; $4EE8  [11 00 2F]
    LD HL,$8800                                      ; $4EEB  [21 00 88]
    CALL $18A2                                       ; $4EEE  [CD A2 18]  ; TileLoad
    LD DE,$310D                                      ; $4EF1  [11 0D 31]
    LD HL,$8A00                                      ; $4EF4  [21 00 8A]
    CALL $18A2                                       ; $4EF7  [CD A2 18]  ; TileLoad
    LD DE,$310E                                      ; $4EFA  [11 0E 31]
    LD HL,$8B00                                      ; $4EFD  [21 00 8B]
    CALL $18A2                                       ; $4F00  [CD A2 18]  ; TileLoad
    LD DE,$3110                                      ; $4F03  [11 10 31]
    LD HL,$8C00                                      ; $4F06  [21 00 8C]
    CALL $18A2                                       ; $4F09  [CD A2 18]  ; TileLoad
    LD DE,$6DF0                                      ; $4F0C  [11 F0 6D]
    LD HL,$9800                                      ; $4F0F  [21 00 98]
    CALL $5C6D                                       ; $4F12  [CD 6D 5C]  ; BuildTilemap
    LD DE,$7092                                      ; $4F15  [11 92 70]
    LD HL,$9C00                                      ; $4F18  [21 00 9C]
    CALL $5C6D                                       ; $4F1B  [CD 6D 5C]  ; BuildTilemap
    XOR A                                            ; $4F1E  [AF]
    LD HL,$C0D8                                      ; $4F1F  [21 D8 C0]
    LD BC,$0028                                      ; $4F22  [01 28 00]
    CALL $169A                                       ; $4F25  [CD 9A 16]  ; memset_HL_BC_A
    LD A,$02                                         ; $4F28  [3E 02]
    LD ($C81E),A                                     ; $4F2A  [EA 1E C8]
    LD HL,$170B                                      ; $4F2D  [21 0B 17]
    RST $10                                          ; $4F30  [D7]  ; banked call → bank23 fn11
    LD HL,$1702                                      ; $4F31  [21 02 17]
    RST $10                                          ; $4F34  [D7]  ; banked call → bank23 fn2
    LD A,$01                                         ; $4F35  [3E 01]
    LDH ($FF4F),A                                    ; $4F37  [E0 4F]  ; rVBK
    LD DE,$3F04                                      ; $4F39  [11 04 3F]
    LD HL,$9800                                      ; $4F3C  [21 00 98]
    LD A,($C81D)                                     ; $4F3F  [FA 1D C8]
    OR A                                             ; $4F42  [B7]
    CALL NZ,$18A2                                    ; $4F43  [C4 A2 18]  ; TileLoad
    LD DE,$3F04                                      ; $4F46  [11 04 3F]
    LD HL,$9C00                                      ; $4F49  [21 00 9C]
    LD A,($C81D)                                     ; $4F4C  [FA 1D C8]
    OR A                                             ; $4F4F  [B7]
    CALL NZ,$18A2                                    ; $4F50  [C4 A2 18]  ; TileLoad
    LD A,$00                                         ; $4F53  [3E 00]
    LDH ($FF4F),A                                    ; $4F55  [E0 4F]  ; rVBK
    LD A,$00                                         ; $4F57  [3E 00]
    LDH ($FFB7),A                                    ; $4F59  [E0 B7]  ; rSFX_CH
    LD A,$70                                         ; $4F5B  [3E 70]
    LDH ($FFBB),A                                    ; $4F5D  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $4F5F  [3E 00]
    LDH ($FFB5),A                                    ; $4F61  [E0 B5]
    LD A,$00                                         ; $4F63  [3E 00]
    LDH ($FFB6),A                                    ; $4F65  [E0 B6]
    XOR A                                            ; $4F67  [AF]
    LD ($C8A4),A                                     ; $4F68  [EA A4 C8]
    LD ($C8A5),A                                     ; $4F6B  [EA A5 C8]
    XOR A                                            ; $4F6E  [AF]
    LD ($C892),A                                     ; $4F6F  [EA 92 C8]
    LD A,$03                                         ; $4F72  [3E 03]
    LD ($C8A1),A                                     ; $4F74  [EA A1 C8]
    CALL $1602                                       ; $4F77  [CD 02 16]
    CALL $17EA                                       ; $4F7A  [CD EA 17]
    CALL $FF80                                       ; $4F7D  [CD 80 FF]
    LD A,$01                                         ; $4F80  [3E 01]
    JP $159E                                         ; $4F82  [C3 9E 15]
Loc_4F85:
    LD A,$FC                                         ; $4F85  [3E FC]
    CALL $1A5B                                       ; $4F87  [CD 5B 1A]  ; TileLoad_Setup
    LD DE,$5B1B                                      ; $4F8A  [11 1B 5B]
    LD HL,$9000                                      ; $4F8D  [21 00 90]
    CALL $18A2                                       ; $4F90  [CD A2 18]  ; TileLoad
    LD DE,$5B1C                                      ; $4F93  [11 1C 5B]
    LD HL,$8800                                      ; $4F96  [21 00 88]
    CALL $18A2                                       ; $4F99  [CD A2 18]  ; TileLoad
    LD DE,$FF00                                      ; $4F9C  [11 00 FF]
    LD HL,$8FF0                                      ; $4F9F  [21 F0 8F]
    LD BC,$0008                                      ; $4FA2  [01 08 00]
    CALL $6A5B                                       ; $4FA5  [CD 5B 6A]
    LD DE,$720E                                      ; $4FA8  [11 0E 72]
    LD HL,$9800                                      ; $4FAB  [21 00 98]
    CALL $5C6D                                       ; $4FAE  [CD 6D 5C]  ; BuildTilemap
    LD A,$FF                                         ; $4FB1  [3E FF]
    LD HL,$9C00                                      ; $4FB3  [21 00 9C]
    LD BC,$0040                                      ; $4FB6  [01 40 00]
    CALL $169A                                       ; $4FB9  [CD 9A 16]  ; memset_HL_BC_A
    XOR A                                            ; $4FBC  [AF]
    LD HL,$C0D8                                      ; $4FBD  [21 D8 C0]
    LD BC,$0028                                      ; $4FC0  [01 28 00]
    CALL $169A                                       ; $4FC3  [CD 9A 16]  ; memset_HL_BC_A
    LD A,$03                                         ; $4FC6  [3E 03]
    LD ($C81E),A                                     ; $4FC8  [EA 1E C8]
    LD HL,$170B                                      ; $4FCB  [21 0B 17]
    RST $10                                          ; $4FCE  [D7]  ; banked call → bank23 fn11
    LD DE,$3F06                                      ; $4FCF  [11 06 3F]
    LD A,$01                                         ; $4FD2  [3E 01]
    LDH ($FF4F),A                                    ; $4FD4  [E0 4F]  ; rVBK
    LD HL,$9800                                      ; $4FD6  [21 00 98]
    LD A,($C81D)                                     ; $4FD9  [FA 1D C8]
    OR A                                             ; $4FDC  [B7]
    CALL NZ,$18A2                                    ; $4FDD  [C4 A2 18]  ; TileLoad
    LD A,$00                                         ; $4FE0  [3E 00]
    LDH ($FF4F),A                                    ; $4FE2  [E0 4F]  ; rVBK
    XOR A                                            ; $4FE4  [AF]
    LD ($C8A4),A                                     ; $4FE5  [EA A4 C8]
    LD ($C8A5),A                                     ; $4FE8  [EA A5 C8]
    LD A,$00                                         ; $4FEB  [3E 00]
    LDH ($FFB7),A                                    ; $4FED  [E0 B7]  ; rSFX_CH
    LD A,$70                                         ; $4FEF  [3E 70]
    LDH ($FFBB),A                                    ; $4FF1  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $4FF3  [3E 00]
    LDH ($FFB5),A                                    ; $4FF5  [E0 B5]
    LD A,$00                                         ; $4FF7  [3E 00]
    LDH ($FFB6),A                                    ; $4FF9  [E0 B6]
    LD A,$03                                         ; $4FFB  [3E 03]
    LD ($C8A1),A                                     ; $4FFD  [EA A1 C8]
    CALL $1602                                       ; $5000  [CD 02 16]
    CALL $17EA                                       ; $5003  [CD EA 17]
    CALL $FF80                                       ; $5006  [CD 80 FF]
    XOR A                                            ; $5009  [AF]
    LD ($C892),A                                     ; $500A  [EA 92 C8]
    LD A,$01                                         ; $500D  [3E 01]
    JP $159E                                         ; $500F  [C3 9E 15]
Loc_5012:
    LD A,$FC                                         ; $5012  [3E FC]
    CALL $1A5B                                       ; $5014  [CD 5B 1A]  ; TileLoad_Setup
    LD DE,$5B1B                                      ; $5017  [11 1B 5B]
    LD HL,$9000                                      ; $501A  [21 00 90]
    CALL $18A2                                       ; $501D  [CD A2 18]  ; TileLoad
    LD DE,$5B1C                                      ; $5020  [11 1C 5B]
    LD HL,$8800                                      ; $5023  [21 00 88]
    CALL $18A2                                       ; $5026  [CD A2 18]  ; TileLoad
    LD DE,$FF00                                      ; $5029  [11 00 FF]
    LD HL,$8FF0                                      ; $502C  [21 F0 8F]
    LD BC,$0008                                      ; $502F  [01 08 00]
    CALL $6A5B                                       ; $5032  [CD 5B 6A]
    LD DE,$720E                                      ; $5035  [11 0E 72]
    LD HL,$9800                                      ; $5038  [21 00 98]
    CALL $5C6D                                       ; $503B  [CD 6D 5C]  ; BuildTilemap
    LD A,$FF                                         ; $503E  [3E FF]
    LD HL,$9C00                                      ; $5040  [21 00 9C]
    LD BC,$0040                                      ; $5043  [01 40 00]
    CALL $169A                                       ; $5046  [CD 9A 16]  ; memset_HL_BC_A
    XOR A                                            ; $5049  [AF]
    LD HL,$C0D8                                      ; $504A  [21 D8 C0]
    LD BC,$0028                                      ; $504D  [01 28 00]
    CALL $169A                                       ; $5050  [CD 9A 16]  ; memset_HL_BC_A
    LD A,$03                                         ; $5053  [3E 03]
    LD ($C81E),A                                     ; $5055  [EA 1E C8]
    LD HL,$170B                                      ; $5058  [21 0B 17]
    RST $10                                          ; $505B  [D7]  ; banked call → bank23 fn11
    LD DE,$3F06                                      ; $505C  [11 06 3F]
    LD A,$01                                         ; $505F  [3E 01]
    LDH ($FF4F),A                                    ; $5061  [E0 4F]  ; rVBK
    LD HL,$9800                                      ; $5063  [21 00 98]
    LD A,($C81D)                                     ; $5066  [FA 1D C8]
    OR A                                             ; $5069  [B7]
    CALL NZ,$18A2                                    ; $506A  [C4 A2 18]  ; TileLoad
    LD A,$00                                         ; $506D  [3E 00]
    LDH ($FF4F),A                                    ; $506F  [E0 4F]  ; rVBK
    XOR A                                            ; $5071  [AF]
    LD ($C8A4),A                                     ; $5072  [EA A4 C8]
    LD ($C8A5),A                                     ; $5075  [EA A5 C8]
    LD A,$00                                         ; $5078  [3E 00]
    LDH ($FFB7),A                                    ; $507A  [E0 B7]  ; rSFX_CH
    LD A,$70                                         ; $507C  [3E 70]
    LDH ($FFBB),A                                    ; $507E  [E0 BB]  ; spr_wait
    LD A,$07                                         ; $5080  [3E 07]
    LDH ($FFB5),A                                    ; $5082  [E0 B5]
    LD A,$80                                         ; $5084  [3E 80]
    LDH ($FFB6),A                                    ; $5086  [E0 B6]
    LD A,$03                                         ; $5088  [3E 03]
    LD ($C8A1),A                                     ; $508A  [EA A1 C8]
    CALL $1602                                       ; $508D  [CD 02 16]
    CALL $17EA                                       ; $5090  [CD EA 17]
    CALL $FF80                                       ; $5093  [CD 80 FF]
    XOR A                                            ; $5096  [AF]
    LD ($C892),A                                     ; $5097  [EA 92 C8]
    LD A,$01                                         ; $509A  [3E 01]
    JP $159E                                         ; $509C  [C3 9E 15]
Loc_509F:
    LD A,$FC                                         ; $509F  [3E FC]
    CALL $1A5B                                       ; $50A1  [CD 5B 1A]  ; TileLoad_Setup
    LD DE,$5B1D                                      ; $50A4  [11 1D 5B]
    LD HL,$9000                                      ; $50A7  [21 00 90]
    CALL $18A2                                       ; $50AA  [CD A2 18]  ; TileLoad
    LD DE,$5B1E                                      ; $50AD  [11 1E 5B]
    LD HL,$8800                                      ; $50B0  [21 00 88]
    CALL $18A2                                       ; $50B3  [CD A2 18]  ; TileLoad
    LD DE,$FF00                                      ; $50B6  [11 00 FF]
    LD HL,$8FF0                                      ; $50B9  [21 F0 8F]
    LD BC,$0008                                      ; $50BC  [01 08 00]
    CALL $6A5B                                       ; $50BF  [CD 5B 6A]
    LD DE,$74B0                                      ; $50C2  [11 B0 74]
    LD HL,$9800                                      ; $50C5  [21 00 98]
    CALL $5C6D                                       ; $50C8  [CD 6D 5C]  ; BuildTilemap
    LD A,$FF                                         ; $50CB  [3E FF]
    LD HL,$9C00                                      ; $50CD  [21 00 9C]
    LD BC,$0040                                      ; $50D0  [01 40 00]
    CALL $169A                                       ; $50D3  [CD 9A 16]  ; memset_HL_BC_A
    XOR A                                            ; $50D6  [AF]
    LD HL,$C0D8                                      ; $50D7  [21 D8 C0]
    LD BC,$0028                                      ; $50DA  [01 28 00]
    CALL $169A                                       ; $50DD  [CD 9A 16]  ; memset_HL_BC_A
    LD A,$04                                         ; $50E0  [3E 04]
    LD ($C81E),A                                     ; $50E2  [EA 1E C8]
    LD HL,$170B                                      ; $50E5  [21 0B 17]
    RST $10                                          ; $50E8  [D7]  ; banked call → bank23 fn11
    LD DE,$3F07                                      ; $50E9  [11 07 3F]
    LD A,$01                                         ; $50EC  [3E 01]
    LDH ($FF4F),A                                    ; $50EE  [E0 4F]  ; rVBK
    LD HL,$9800                                      ; $50F0  [21 00 98]
    LD A,($C81D)                                     ; $50F3  [FA 1D C8]
    OR A                                             ; $50F6  [B7]
    CALL NZ,$18A2                                    ; $50F7  [C4 A2 18]  ; TileLoad
    LD A,$00                                         ; $50FA  [3E 00]
    LDH ($FF4F),A                                    ; $50FC  [E0 4F]  ; rVBK
    XOR A                                            ; $50FE  [AF]
    LD ($C8A4),A                                     ; $50FF  [EA A4 C8]
    LD ($C8A5),A                                     ; $5102  [EA A5 C8]
    LD A,$00                                         ; $5105  [3E 00]
    LDH ($FFB7),A                                    ; $5107  [E0 B7]  ; rSFX_CH
    LD A,$70                                         ; $5109  [3E 70]
    LDH ($FFBB),A                                    ; $510B  [E0 BB]  ; spr_wait
    LD A,$07                                         ; $510D  [3E 07]
    LDH ($FFB5),A                                    ; $510F  [E0 B5]
    LD A,$80                                         ; $5111  [3E 80]
    LDH ($FFB6),A                                    ; $5113  [E0 B6]
    LD A,$03                                         ; $5115  [3E 03]
    LD ($C8A1),A                                     ; $5117  [EA A1 C8]
    CALL $1602                                       ; $511A  [CD 02 16]
    CALL $17EA                                       ; $511D  [CD EA 17]
    CALL $FF80                                       ; $5120  [CD 80 FF]
    XOR A                                            ; $5123  [AF]
    LD ($C892),A                                     ; $5124  [EA 92 C8]
    LD A,$01                                         ; $5127  [3E 01]
    JP $159E                                         ; $5129  [C3 9E 15]

; ──────────────────────────────────────────────────────────────────
; Bank2_Fn2  ($512C)
; ──────────────────────────────────────────────────────────────────
; Per-frame object update dispatcher.
; Outer dispatch on scene_mode ($C88B), 4 cases.
;   case 0 ($5138): calls helper $5CA2, $517E, then
;                    inner RST $00 on obj_state_lo ($C0FC), 16 cases:
;     states 0,2,4,6,8,10 ($5C48/$5C58/$5C48/$5C38/$5C38/$5C28): shared stubs
;     state  1 ($5224): wait $C0FD<3, then DEC spr_wait ($FFBB); when 0,
;                        INC obj_state_lo, reset $C0D8-$C0E5 vars
;     state  3 ($528A): clear audio channels ($FFB7/$FFBB), begin scroll phase
;     states 5,7,9,11,13,15: additional animation phases
;   cases 1,2,3 ($5D06,$5E98,$5F70): alternate scene-mode animation sets.
; 
; obj_state_lo ($C0FC) acts as a state index (0-15); when used as ptr-lo
;   (paired with obj_state_hi/$C0FD) it points to a sprite descriptor block.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn2:
    LD A,($C88B)                                     ; $512C  [FA 8B C8]  ; scene_mode
    RST $00                                          ; $512F  [C7 38 51 06 5D 98 5E 70 5F]  ; switch(A)→[$5138 $5D06 $5E98 $5F70] tbl=[C7 38 51 06 5D 98 5E 70 5F]
Loc_5138:
    CALL $5CA2                                       ; $5138  [CD A2 5C]  ; Fn_5CA2
    CALL $517E                                       ; $513B  [CD 7E 51]
    LD A,($C0FC)                                     ; $513E  [FA FC C0]  ; obj_state_lo
    RST $00                                          ; $5141  [C7 48 5C 24 52 58 5C 8A 52 48 5C 31 53 38 5C D8 53 38 5C 7F 54 28 5C 26 55 D8 55 8B 56 32 57 1F 58]  ; switch(A)→[$5C48 $5224 $5C58 $528A $5C48 $5331 $5C38 $53D8 $5C38 $547F $5C28 $5526 $55D8 $568B $5732 $581F] tbl=[C7 48 5C 24 52 58 5C 8A 52 48 5C 31 53 38 5C D8 53 38 5C 7F 54 28 5C 26 55 D8 55 8B 56 32 57 1F 58]
    RRCA                                             ; $5162  [0F]
    LD E,C                                           ; $5163  [59]
    LD HL,SP+$5B                                     ; $5164  [F8 5B]
    OR (HL)                                          ; $5166  [B6]
    LD E,C                                           ; $5167  [59]
    LD ($5D5C),SP                                    ; $5168  [08 5C 5D]
    LD E,D                                           ; $516B  [5A]
    JR $51CA                                         ; $516C  [18 5C]
Loc_517E:
    LD A,($C0FC)                                     ; $517E  [FA FC C0]  ; obj_state_lo
    CP $00                                           ; $5181  [FE 00]
    JR Z,$5188                                       ; $5183  [28 03]
    CP $01                                           ; $5185  [FE 01]
    RET NZ                                           ; $5187  [C0]
Loc_5188:
    LD HL,$FFC3                                      ; $5188  [21 C3 FF]
    LD A,$48                                         ; $518B  [3E 48]
    LD (HL+),A                                       ; $518D  [22]
    LD A,$00                                         ; $518E  [3E 00]
    LD (HL+),A                                       ; $5190  [22]
    LD A,$F0                                         ; $5191  [3E F0]
    LD (HL+),A                                       ; $5193  [22]
    LD A,$00                                         ; $5194  [3E 00]
    LD (HL+),A                                       ; $5196  [22]
    LD A,$0E                                         ; $5197  [3E 0E]
    LD (HL+),A                                       ; $5199  [22]
    LD A,$04                                         ; $519A  [3E 04]
    LD (HL+),A                                       ; $519C  [22]
    LD A,$B0                                         ; $519D  [3E B0]
    LD (HL+),A                                       ; $519F  [22]
    LD A,$00                                         ; $51A0  [3E 00]
    LD (HL),A                                        ; $51A2  [77]
    LD HL,$0500                                      ; $51A3  [21 00 05]
    RST $10                                          ; $51A6  [D7]  ; banked call → bank5 fn0
    LD HL,$FFC3                                      ; $51A7  [21 C3 FF]
    LD A,$58                                         ; $51AA  [3E 58]
    LD (HL+),A                                       ; $51AC  [22]
    LD A,$00                                         ; $51AD  [3E 00]
    LD (HL+),A                                       ; $51AF  [22]
    LD A,$F0                                         ; $51B0  [3E F0]
    LD (HL+),A                                       ; $51B2  [22]
    LD A,$00                                         ; $51B3  [3E 00]
    LD (HL+),A                                       ; $51B5  [22]
    LD A,$0D                                         ; $51B6  [3E 0D]
    LD (HL+),A                                       ; $51B8  [22]
    LD A,$04                                         ; $51B9  [3E 04]
    LD (HL+),A                                       ; $51BB  [22]
    LD A,$A0                                         ; $51BC  [3E A0]
    LD (HL+),A                                       ; $51BE  [22]
    LD A,$00                                         ; $51BF  [3E 00]
    LD (HL),A                                        ; $51C1  [77]
    LD HL,$0500                                      ; $51C2  [21 00 05]
    RST $10                                          ; $51C5  [D7]  ; banked call → bank5 fn0
    LD HL,$FFC3                                      ; $51C6  [21 C3 FF]
    LD A,$68                                         ; $51C9  [3E 68]
Loc_51CA:
    LD L,B                                           ; $51CA  [68]
    LD (HL+),A                                       ; $51CB  [22]
    LD A,$00                                         ; $51CC  [3E 00]
    LD (HL+),A                                       ; $51CE  [22]
    LD A,$F0                                         ; $51CF  [3E F0]
    LD (HL+),A                                       ; $51D1  [22]
    LD A,$00                                         ; $51D2  [3E 00]
    LD (HL+),A                                       ; $51D4  [22]
    LD A,$00                                         ; $51D5  [3E 00]
    LD (HL+),A                                       ; $51D7  [22]
    LD A,$04                                         ; $51D8  [3E 04]
    LD (HL+),A                                       ; $51DA  [22]
    LD A,$80                                         ; $51DB  [3E 80]
    LD (HL+),A                                       ; $51DD  [22]
    LD A,$00                                         ; $51DE  [3E 00]
    LD (HL),A                                        ; $51E0  [77]
    LD HL,$0402                                      ; $51E1  [21 02 04]
    RST $10                                          ; $51E4  [D7]  ; banked call → bank4 fn2
    LD HL,$FFC3                                      ; $51E5  [21 C3 FF]
    LD A,$28                                         ; $51E8  [3E 28]
    LD (HL+),A                                       ; $51EA  [22]
    LD A,$00                                         ; $51EB  [3E 00]
    LD (HL+),A                                       ; $51ED  [22]
    LD A,$00                                         ; $51EE  [3E 00]
    LD (HL+),A                                       ; $51F0  [22]
    LD A,$01                                         ; $51F1  [3E 01]
    LD (HL+),A                                       ; $51F3  [22]
    LD A,$10                                         ; $51F4  [3E 10]
    LD (HL+),A                                       ; $51F6  [22]
    LD A,$04                                         ; $51F7  [3E 04]
    LD (HL+),A                                       ; $51F9  [22]
    LD A,$C0                                         ; $51FA  [3E C0]
    LD (HL+),A                                       ; $51FC  [22]
    LD A,$00                                         ; $51FD  [3E 00]
    LD (HL),A                                        ; $51FF  [77]
    LD HL,$0500                                      ; $5200  [21 00 05]
    RST $10                                          ; $5203  [D7]  ; banked call → bank5 fn0
    LD HL,$FFC3                                      ; $5204  [21 C3 FF]
    LD A,$78                                         ; $5207  [3E 78]
    LD (HL+),A                                       ; $5209  [22]
    LD A,$00                                         ; $520A  [3E 00]
    LD (HL+),A                                       ; $520C  [22]
    LD A,$00                                         ; $520D  [3E 00]
    LD (HL+),A                                       ; $520F  [22]
    LD A,$01                                         ; $5210  [3E 01]
    LD (HL+),A                                       ; $5212  [22]
    LD A,$10                                         ; $5213  [3E 10]
    LD (HL+),A                                       ; $5215  [22]
    LD A,$04                                         ; $5216  [3E 04]
    LD (HL+),A                                       ; $5218  [22]
    LD A,$C0                                         ; $5219  [3E C0]
    LD (HL+),A                                       ; $521B  [22]
    LD A,$00                                         ; $521C  [3E 00]
    LD (HL),A                                        ; $521E  [77]
    LD HL,$0500                                      ; $521F  [21 00 05]
    RST $10                                          ; $5222  [D7]  ; banked call → bank5 fn0
    RET                                              ; $5223  [C9]
Loc_5224:
    LD HL,$C0FD                                      ; $5224  [21 FD C0]
    INC (HL)                                         ; $5227  [34]
    LD A,($C0FD)                                     ; $5228  [FA FD C0]  ; obj_state_hi
    CP $03                                           ; $522B  [FE 03]
    RET C                                            ; $522D  [D8]
    XOR A                                            ; $522E  [AF]
    LD ($C0FD),A                                     ; $522F  [EA FD C0]  ; obj_state_hi
    LD HL,$FFBB                                      ; $5232  [21 BB FF]
    DEC (HL)                                         ; $5235  [35]
    LDH A,($FFBB)                                    ; $5236  [F0 BB]  ; spr_wait
    OR A                                             ; $5238  [B7]
    RET NZ                                           ; $5239  [C0]
    LD HL,$C0FC                                      ; $523A  [21 FC C0]
    INC (HL)                                         ; $523D  [34]
    LD A,$00                                         ; $523E  [3E 00]
    LD ($C0D8),A                                     ; $5240  [EA D8 C0]  ; obj_phase
    LD A,$80                                         ; $5243  [3E 80]
    LD ($C0D9),A                                     ; $5245  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $5248  [3E 00]
    LD ($C0DA),A                                     ; $524A  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $524D  [3E 00]
    LD ($C0DB),A                                     ; $524F  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $5252  [3E 00]
    LD ($C0DC),A                                     ; $5254  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $5257  [3E 02]
    LD ($C0DD),A                                     ; $5259  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $525C  [3E 00]
    LD ($C0DE),A                                     ; $525E  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $5261  [3E 01]
    LD ($C0DF),A                                     ; $5263  [EA DF C0]  ; obj_unk_DF
    LD A,$50                                         ; $5266  [3E 50]
    LD ($C0E0),A                                     ; $5268  [EA E0 C0]  ; obj_pos_x
    LD A,$30                                         ; $526B  [3E 30]
    LD ($C0E1),A                                     ; $526D  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $5270  [3E 00]
    LD ($C0E2),A                                     ; $5272  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $5275  [3E 00]
    LD ($C0E3),A                                     ; $5277  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $527A  [3E 04]
    LD ($C0E4),A                                     ; $527C  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $527F  [3E 00]
    LD ($C0E5),A                                     ; $5281  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $5284  [3E 00]
    LD ($C0FD),A                                     ; $5286  [EA FD C0]  ; obj_state_hi
    RET                                              ; $5289  [C9]
Loc_528A:
    LD A,$00                                         ; $528A  [3E 00]
    LDH ($FFB7),A                                    ; $528C  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $528E  [3E 00]
    LDH ($FFBB),A                                    ; $5290  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $5292  [3E 00]
    LDH ($FFC7),A                                    ; $5294  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $5296  [3E 60]
    LDH ($FFC9),A                                    ; $5298  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $529A  [3E 02]
    LDH ($FFCA),A                                    ; $529C  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $529E  [21 D8 C0]
    CALL $6A80                                       ; $52A1  [CD 80 6A]
    LD HL,$C0D9                                      ; $52A4  [21 D9 C0]
    DEC (HL)                                         ; $52A7  [35]
    LD HL,$C0DA                                      ; $52A8  [21 DA C0]
    INC (HL)                                         ; $52AB  [34]
    LD A,($C0D9)                                     ; $52AC  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $52AF  [FE E0]
    CALL Z,$6A37                                     ; $52B1  [CC 37 6A]
    LD A,$01                                         ; $52B4  [3E 01]
    LDH ($FFC7),A                                    ; $52B6  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $52B8  [3E 64]
    LDH ($FFC9),A                                    ; $52BA  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $52BC  [3E 02]
    LDH ($FFCA),A                                    ; $52BE  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $52C0  [21 DF C0]
    CALL $6A80                                       ; $52C3  [CD 80 6A]
    LD A,($C0D9)                                     ; $52C6  [FA D9 C0]  ; obj_init_y
    CP $40                                           ; $52C9  [FE 40]
    JR NZ,$52D7                                      ; $52CB  [20 0A]
    LD A,$00                                         ; $52CD  [3E 00]
    LD ($C0DF),A                                     ; $52CF  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $52D2  [3E 5D]
    CALL $1EFF                                       ; $52D4  [CD FF 1E]  ; PlaySFX
Loc_52D7:
    LD A,($C0D8)                                     ; $52D7  [FA D8 C0]  ; obj_phase
    OR A                                             ; $52DA  [B7]
    DB $C8                                           ; $52DB  [C8]
    LD A,($C0DF)                                     ; $52DC  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $52DF  [B7]
    DB $C8                                           ; $52E0  [C8]
    LD HL,$C0FC                                      ; $52E1  [21 FC C0]
    INC (HL)                                         ; $52E4  [34]
    LD A,$00                                         ; $52E5  [3E 00]
    LD ($C0D8),A                                     ; $52E7  [EA D8 C0]  ; obj_phase
    LD A,$40                                         ; $52EA  [3E 40]
    LD ($C0D9),A                                     ; $52EC  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $52EF  [3E 00]
    LD ($C0DA),A                                     ; $52F1  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $52F4  [3E 00]
    LD ($C0DB),A                                     ; $52F6  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $52F9  [3E 00]
    LD ($C0DC),A                                     ; $52FB  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $52FE  [3E 02]
    LD ($C0DD),A                                     ; $5300  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $5303  [3E 00]
    LD ($C0DE),A                                     ; $5305  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $5308  [3E 01]
    LD ($C0DF),A                                     ; $530A  [EA DF C0]  ; obj_unk_DF
    LD A,$20                                         ; $530D  [3E 20]
    LD ($C0E0),A                                     ; $530F  [EA E0 C0]  ; obj_pos_x
    LD A,$20                                         ; $5312  [3E 20]
    LD ($C0E1),A                                     ; $5314  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $5317  [3E 00]
    LD ($C0E2),A                                     ; $5319  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $531C  [3E 00]
    LD ($C0E3),A                                     ; $531E  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $5321  [3E 04]
    LD ($C0E4),A                                     ; $5323  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $5326  [3E 00]
    LD ($C0E5),A                                     ; $5328  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $532B  [3E 00]
    LD ($C0FD),A                                     ; $532D  [EA FD C0]  ; obj_state_hi
    RET                                              ; $5330  [C9]
Loc_5331:
    LD A,$00                                         ; $5331  [3E 00]
    LDH ($FFB7),A                                    ; $5333  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $5335  [3E 00]
    LDH ($FFBB),A                                    ; $5337  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $5339  [3E 00]
    LDH ($FFC7),A                                    ; $533B  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $533D  [3E 60]
    LDH ($FFC9),A                                    ; $533F  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5341  [3E 02]
    LDH ($FFCA),A                                    ; $5343  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $5345  [21 D8 C0]
    CALL $6A80                                       ; $5348  [CD 80 6A]
    LD HL,$C0D9                                      ; $534B  [21 D9 C0]
    DEC (HL)                                         ; $534E  [35]
    LD HL,$C0DA                                      ; $534F  [21 DA C0]
    INC (HL)                                         ; $5352  [34]
    LD A,($C0D9)                                     ; $5353  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $5356  [FE E0]
    CALL Z,$6A37                                     ; $5358  [CC 37 6A]
    LD A,$01                                         ; $535B  [3E 01]
    LDH ($FFC7),A                                    ; $535D  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $535F  [3E 64]
    LDH ($FFC9),A                                    ; $5361  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5363  [3E 02]
    LDH ($FFCA),A                                    ; $5365  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $5367  [21 DF C0]
    CALL $6A80                                       ; $536A  [CD 80 6A]
    LD A,($C0D9)                                     ; $536D  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $5370  [FE 10]
    JR NZ,$537E                                      ; $5372  [20 0A]
    LD A,$00                                         ; $5374  [3E 00]
    LD ($C0DF),A                                     ; $5376  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $5379  [3E 5D]
    CALL $1EFF                                       ; $537B  [CD FF 1E]  ; PlaySFX
Loc_537E:
    LD A,($C0D8)                                     ; $537E  [FA D8 C0]  ; obj_phase
    OR A                                             ; $5381  [B7]
    DB $C8                                           ; $5382  [C8]
    LD A,($C0DF)                                     ; $5383  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $5386  [B7]
    DB $C8                                           ; $5387  [C8]
    LD HL,$C0FC                                      ; $5388  [21 FC C0]
    INC (HL)                                         ; $538B  [34]
    LD A,$00                                         ; $538C  [3E 00]
    LD ($C0D8),A                                     ; $538E  [EA D8 C0]  ; obj_phase
    LD A,$A0                                         ; $5391  [3E A0]
    LD ($C0D9),A                                     ; $5393  [EA D9 C0]  ; obj_init_y
    LD A,$30                                         ; $5396  [3E 30]
    LD ($C0DA),A                                     ; $5398  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $539B  [3E 00]
    LD ($C0DB),A                                     ; $539D  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $53A0  [3E 00]
    LD ($C0DC),A                                     ; $53A2  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $53A5  [3E 02]
    LD ($C0DD),A                                     ; $53A7  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $53AA  [3E 00]
    LD ($C0DE),A                                     ; $53AC  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $53AF  [3E 01]
    LD ($C0DF),A                                     ; $53B1  [EA DF C0]  ; obj_unk_DF
    LD A,$80                                         ; $53B4  [3E 80]
    LD ($C0E0),A                                     ; $53B6  [EA E0 C0]  ; obj_pos_x
    LD A,$50                                         ; $53B9  [3E 50]
    LD ($C0E1),A                                     ; $53BB  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $53BE  [3E 00]
    LD ($C0E2),A                                     ; $53C0  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $53C3  [3E 00]
    LD ($C0E3),A                                     ; $53C5  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $53C8  [3E 04]
    LD ($C0E4),A                                     ; $53CA  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $53CD  [3E 00]
    LD ($C0E5),A                                     ; $53CF  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $53D2  [3E 00]
    LD ($C0FD),A                                     ; $53D4  [EA FD C0]  ; obj_state_hi
    RET                                              ; $53D7  [C9]
Loc_53D8:
    LD A,$00                                         ; $53D8  [3E 00]
    LDH ($FFB7),A                                    ; $53DA  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $53DC  [3E 00]
    LDH ($FFBB),A                                    ; $53DE  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $53E0  [3E 00]
    LDH ($FFC7),A                                    ; $53E2  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $53E4  [3E 60]
    LDH ($FFC9),A                                    ; $53E6  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $53E8  [3E 02]
    LDH ($FFCA),A                                    ; $53EA  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $53EC  [21 D8 C0]
    CALL $6A80                                       ; $53EF  [CD 80 6A]
    LD HL,$C0D9                                      ; $53F2  [21 D9 C0]
    DEC (HL)                                         ; $53F5  [35]
    LD HL,$C0DA                                      ; $53F6  [21 DA C0]
    INC (HL)                                         ; $53F9  [34]
    LD A,($C0D9)                                     ; $53FA  [FA D9 C0]  ; obj_init_y
    CP $28                                           ; $53FD  [FE 28]
    CALL Z,$6A37                                     ; $53FF  [CC 37 6A]
    LD A,$01                                         ; $5402  [3E 01]
    LDH ($FFC7),A                                    ; $5404  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5406  [3E 64]
    LDH ($FFC9),A                                    ; $5408  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $540A  [3E 02]
    LDH ($FFCA),A                                    ; $540C  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $540E  [21 DF C0]
    CALL $6A80                                       ; $5411  [CD 80 6A]
    LD A,($C0D9)                                     ; $5414  [FA D9 C0]  ; obj_init_y
    CP $70                                           ; $5417  [FE 70]
    JR NZ,$5425                                      ; $5419  [20 0A]
    LD A,$00                                         ; $541B  [3E 00]
    LD ($C0DF),A                                     ; $541D  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $5420  [3E 5D]
    CALL $1EFF                                       ; $5422  [CD FF 1E]  ; PlaySFX
Loc_5425:
    LD A,($C0D8)                                     ; $5425  [FA D8 C0]  ; obj_phase
    OR A                                             ; $5428  [B7]
    DB $C8                                           ; $5429  [C8]
    LD A,($C0DF)                                     ; $542A  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $542D  [B7]
    DB $C8                                           ; $542E  [C8]
    LD HL,$C0FC                                      ; $542F  [21 FC C0]
    INC (HL)                                         ; $5432  [34]
    LD A,$00                                         ; $5433  [3E 00]
    LD ($C0D8),A                                     ; $5435  [EA D8 C0]  ; obj_phase
    LD A,$80                                         ; $5438  [3E 80]
    LD ($C0D9),A                                     ; $543A  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $543D  [3E 00]
    LD ($C0DA),A                                     ; $543F  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $5442  [3E 00]
    LD ($C0DB),A                                     ; $5444  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $5447  [3E 00]
    LD ($C0DC),A                                     ; $5449  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $544C  [3E 02]
    LD ($C0DD),A                                     ; $544E  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $5451  [3E 00]
    LD ($C0DE),A                                     ; $5453  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $5456  [3E 01]
    LD ($C0DF),A                                     ; $5458  [EA DF C0]  ; obj_unk_DF
    LD A,$70                                         ; $545B  [3E 70]
    LD ($C0E0),A                                     ; $545D  [EA E0 C0]  ; obj_pos_x
    LD A,$10                                         ; $5460  [3E 10]
    LD ($C0E1),A                                     ; $5462  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $5465  [3E 00]
    LD ($C0E2),A                                     ; $5467  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $546A  [3E 00]
    LD ($C0E3),A                                     ; $546C  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $546F  [3E 04]
    LD ($C0E4),A                                     ; $5471  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $5474  [3E 00]
    LD ($C0E5),A                                     ; $5476  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $5479  [3E 00]
    LD ($C0FD),A                                     ; $547B  [EA FD C0]  ; obj_state_hi
    RET                                              ; $547E  [C9]
Loc_547F:
    LD A,$00                                         ; $547F  [3E 00]
    LDH ($FFB7),A                                    ; $5481  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $5483  [3E 00]
    LDH ($FFBB),A                                    ; $5485  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $5487  [3E 00]
    LDH ($FFC7),A                                    ; $5489  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $548B  [3E 60]
    LDH ($FFC9),A                                    ; $548D  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $548F  [3E 02]
    LDH ($FFCA),A                                    ; $5491  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $5493  [21 D8 C0]
    CALL $6A80                                       ; $5496  [CD 80 6A]
    LD HL,$C0D9                                      ; $5499  [21 D9 C0]
    DEC (HL)                                         ; $549C  [35]
    LD HL,$C0DA                                      ; $549D  [21 DA C0]
    INC (HL)                                         ; $54A0  [34]
    LD A,($C0D9)                                     ; $54A1  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $54A4  [FE E0]
    CALL Z,$6A37                                     ; $54A6  [CC 37 6A]
    LD A,$01                                         ; $54A9  [3E 01]
    LDH ($FFC7),A                                    ; $54AB  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $54AD  [3E 64]
    LDH ($FFC9),A                                    ; $54AF  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $54B1  [3E 02]
    LDH ($FFCA),A                                    ; $54B3  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $54B5  [21 DF C0]
    CALL $6A80                                       ; $54B8  [CD 80 6A]
    LD A,($C0D9)                                     ; $54BB  [FA D9 C0]  ; obj_init_y
    CP $60                                           ; $54BE  [FE 60]
    JR NZ,$54CC                                      ; $54C0  [20 0A]
    LD A,$00                                         ; $54C2  [3E 00]
    LD ($C0DF),A                                     ; $54C4  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $54C7  [3E 5D]
    CALL $1EFF                                       ; $54C9  [CD FF 1E]  ; PlaySFX
Loc_54CC:
    LD A,($C0D8)                                     ; $54CC  [FA D8 C0]  ; obj_phase
    OR A                                             ; $54CF  [B7]
    DB $C8                                           ; $54D0  [C8]
    LD A,($C0DF)                                     ; $54D1  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $54D4  [B7]
    DB $C8                                           ; $54D5  [C8]
    LD HL,$C0FC                                      ; $54D6  [21 FC C0]
    INC (HL)                                         ; $54D9  [34]
    LD A,$00                                         ; $54DA  [3E 00]
    LD ($C0D8),A                                     ; $54DC  [EA D8 C0]  ; obj_phase
    LD A,$40                                         ; $54DF  [3E 40]
    LD ($C0D9),A                                     ; $54E1  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $54E4  [3E 00]
    LD ($C0DA),A                                     ; $54E6  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $54E9  [3E 00]
    LD ($C0DB),A                                     ; $54EB  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $54EE  [3E 00]
    LD ($C0DC),A                                     ; $54F0  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $54F3  [3E 02]
    LD ($C0DD),A                                     ; $54F5  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $54F8  [3E 00]
    LD ($C0DE),A                                     ; $54FA  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $54FD  [3E 01]
    LD ($C0DF),A                                     ; $54FF  [EA DF C0]  ; obj_unk_DF
    LD A,$20                                         ; $5502  [3E 20]
    LD ($C0E0),A                                     ; $5504  [EA E0 C0]  ; obj_pos_x
    LD A,$20                                         ; $5507  [3E 20]
    LD ($C0E1),A                                     ; $5509  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $550C  [3E 00]
    LD ($C0E2),A                                     ; $550E  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $5511  [3E 00]
    LD ($C0E3),A                                     ; $5513  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $5516  [3E 04]
    LD ($C0E4),A                                     ; $5518  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $551B  [3E 00]
    LD ($C0E5),A                                     ; $551D  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $5520  [3E 00]
    LD ($C0FD),A                                     ; $5522  [EA FD C0]  ; obj_state_hi
    RET                                              ; $5525  [C9]
Loc_5526:
    LD A,$00                                         ; $5526  [3E 00]
    LDH ($FFB7),A                                    ; $5528  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $552A  [3E 00]
    LDH ($FFBB),A                                    ; $552C  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $552E  [3E 00]
    LDH ($FFC7),A                                    ; $5530  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $5532  [3E 60]
    LDH ($FFC9),A                                    ; $5534  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5536  [3E 02]
    LDH ($FFCA),A                                    ; $5538  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $553A  [21 D8 C0]
    CALL $6A80                                       ; $553D  [CD 80 6A]
    LD HL,$C0D9                                      ; $5540  [21 D9 C0]
    DEC (HL)                                         ; $5543  [35]
    LD HL,$C0DA                                      ; $5544  [21 DA C0]
    INC (HL)                                         ; $5547  [34]
    LD A,($C0D9)                                     ; $5548  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $554B  [FE E0]
    CALL Z,$6A37                                     ; $554D  [CC 37 6A]
    LD A,$01                                         ; $5550  [3E 01]
    LDH ($FFC7),A                                    ; $5552  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5554  [3E 64]
    LDH ($FFC9),A                                    ; $5556  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5558  [3E 02]
    LDH ($FFCA),A                                    ; $555A  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $555C  [21 DF C0]
    CALL $6A80                                       ; $555F  [CD 80 6A]
    LD A,($C0D9)                                     ; $5562  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $5565  [FE 10]
    JR NZ,$5573                                      ; $5567  [20 0A]
    LD A,$00                                         ; $5569  [3E 00]
    LD ($C0DF),A                                     ; $556B  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $556E  [3E 5D]
    CALL $1EFF                                       ; $5570  [CD FF 1E]  ; PlaySFX
Loc_5573:
    LD A,($C0D9)                                     ; $5573  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $5576  [B7]
    JR NZ,$557E                                      ; $5577  [20 05]
    LD A,$01                                         ; $5579  [3E 01]
    LD ($C0D8),A                                     ; $557B  [EA D8 C0]  ; obj_phase
Loc_557E:
    LD A,($C0D8)                                     ; $557E  [FA D8 C0]  ; obj_phase
    OR A                                             ; $5581  [B7]
    DB $C8                                           ; $5582  [C8]
    LD A,($C0DF)                                     ; $5583  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $5586  [B7]
    DB $C8                                           ; $5587  [C8]
    LD HL,$C0FC                                      ; $5588  [21 FC C0]
    INC (HL)                                         ; $558B  [34]
    LD A,$00                                         ; $558C  [3E 00]
    LD ($C0D8),A                                     ; $558E  [EA D8 C0]  ; obj_phase
    LD A,$A0                                         ; $5591  [3E A0]
    LD ($C0D9),A                                     ; $5593  [EA D9 C0]  ; obj_init_y
    LD A,$30                                         ; $5596  [3E 30]
    LD ($C0DA),A                                     ; $5598  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $559B  [3E 00]
    LD ($C0DB),A                                     ; $559D  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $55A0  [3E 00]
    LD ($C0DC),A                                     ; $55A2  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $55A5  [3E 02]
    LD ($C0DD),A                                     ; $55A7  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $55AA  [3E 00]
    LD ($C0DE),A                                     ; $55AC  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $55AF  [3E 01]
    LD ($C0DF),A                                     ; $55B1  [EA DF C0]  ; obj_unk_DF
    LD A,$80                                         ; $55B4  [3E 80]
    LD ($C0E0),A                                     ; $55B6  [EA E0 C0]  ; obj_pos_x
    LD A,$50                                         ; $55B9  [3E 50]
    LD ($C0E1),A                                     ; $55BB  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $55BE  [3E 00]
    LD ($C0E2),A                                     ; $55C0  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $55C3  [3E 00]
    LD ($C0E3),A                                     ; $55C5  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $55C8  [3E 04]
    LD ($C0E4),A                                     ; $55CA  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $55CD  [3E 00]
    LD ($C0E5),A                                     ; $55CF  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $55D2  [3E 00]
    LD ($C0FD),A                                     ; $55D4  [EA FD C0]  ; obj_state_hi
    RET                                              ; $55D7  [C9]
Loc_55D8:
    LD A,$00                                         ; $55D8  [3E 00]
    LDH ($FFB7),A                                    ; $55DA  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $55DC  [3E 00]
    LDH ($FFBB),A                                    ; $55DE  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $55E0  [3E 00]
    LDH ($FFC7),A                                    ; $55E2  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $55E4  [3E 60]
    LDH ($FFC9),A                                    ; $55E6  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $55E8  [3E 02]
    LDH ($FFCA),A                                    ; $55EA  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $55EC  [21 D8 C0]
    CALL $6A80                                       ; $55EF  [CD 80 6A]
    LD HL,$C0D9                                      ; $55F2  [21 D9 C0]
    DEC (HL)                                         ; $55F5  [35]
    LD HL,$C0DA                                      ; $55F6  [21 DA C0]
    INC (HL)                                         ; $55F9  [34]
    LD A,($C0D9)                                     ; $55FA  [FA D9 C0]  ; obj_init_y
    CP $28                                           ; $55FD  [FE 28]
    CALL Z,$6A37                                     ; $55FF  [CC 37 6A]
    LD A,$01                                         ; $5602  [3E 01]
    LDH ($FFC7),A                                    ; $5604  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5606  [3E 64]
    LDH ($FFC9),A                                    ; $5608  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $560A  [3E 02]
    LDH ($FFCA),A                                    ; $560C  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $560E  [21 DF C0]
    CALL $6A80                                       ; $5611  [CD 80 6A]
    LD A,($C0D9)                                     ; $5614  [FA D9 C0]  ; obj_init_y
    CP $70                                           ; $5617  [FE 70]
    JR NZ,$5625                                      ; $5619  [20 0A]
    LD A,$00                                         ; $561B  [3E 00]
    LD ($C0DF),A                                     ; $561D  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $5620  [3E 5D]
    CALL $1EFF                                       ; $5622  [CD FF 1E]  ; PlaySFX
Loc_5625:
    LD A,($C0D9)                                     ; $5625  [FA D9 C0]  ; obj_init_y
    CP $38                                           ; $5628  [FE 38]
    JR NZ,$5631                                      ; $562A  [20 05]
    LD A,$01                                         ; $562C  [3E 01]
    LD ($C0D8),A                                     ; $562E  [EA D8 C0]  ; obj_phase
Loc_5631:
    LD A,($C0D8)                                     ; $5631  [FA D8 C0]  ; obj_phase
    OR A                                             ; $5634  [B7]
    DB $C8                                           ; $5635  [C8]
    LD A,($C0DF)                                     ; $5636  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $5639  [B7]
    DB $C8                                           ; $563A  [C8]
    LD HL,$C0FC                                      ; $563B  [21 FC C0]
    INC (HL)                                         ; $563E  [34]
    LD A,$00                                         ; $563F  [3E 00]
    LD ($C0D8),A                                     ; $5641  [EA D8 C0]  ; obj_phase
    LD A,$40                                         ; $5644  [3E 40]
    LD ($C0D9),A                                     ; $5646  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $5649  [3E 00]
    LD ($C0DA),A                                     ; $564B  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $564E  [3E 00]
    LD ($C0DB),A                                     ; $5650  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $5653  [3E 00]
    LD ($C0DC),A                                     ; $5655  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $5658  [3E 02]
    LD ($C0DD),A                                     ; $565A  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $565D  [3E 00]
    LD ($C0DE),A                                     ; $565F  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $5662  [3E 01]
    LD ($C0DF),A                                     ; $5664  [EA DF C0]  ; obj_unk_DF
    LD A,$20                                         ; $5667  [3E 20]
    LD ($C0E0),A                                     ; $5669  [EA E0 C0]  ; obj_pos_x
    LD A,$20                                         ; $566C  [3E 20]
    LD ($C0E1),A                                     ; $566E  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $5671  [3E 00]
    LD ($C0E2),A                                     ; $5673  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $5676  [3E 00]
    LD ($C0E3),A                                     ; $5678  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $567B  [3E 04]
    LD ($C0E4),A                                     ; $567D  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $5680  [3E 00]
    LD ($C0E5),A                                     ; $5682  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $5685  [3E 00]
    LD ($C0FD),A                                     ; $5687  [EA FD C0]  ; obj_state_hi
    RET                                              ; $568A  [C9]
Loc_568B:
    LD A,$00                                         ; $568B  [3E 00]
    LDH ($FFB7),A                                    ; $568D  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $568F  [3E 00]
    LDH ($FFBB),A                                    ; $5691  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $5693  [3E 00]
    LDH ($FFC7),A                                    ; $5695  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $5697  [3E 60]
    LDH ($FFC9),A                                    ; $5699  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $569B  [3E 02]
    LDH ($FFCA),A                                    ; $569D  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $569F  [21 D8 C0]
    CALL $6A80                                       ; $56A2  [CD 80 6A]
    LD HL,$C0D9                                      ; $56A5  [21 D9 C0]
    DEC (HL)                                         ; $56A8  [35]
    LD HL,$C0DA                                      ; $56A9  [21 DA C0]
    INC (HL)                                         ; $56AC  [34]
    LD A,($C0D9)                                     ; $56AD  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $56B0  [FE E0]
    CALL Z,$6A37                                     ; $56B2  [CC 37 6A]
    LD A,$01                                         ; $56B5  [3E 01]
    LDH ($FFC7),A                                    ; $56B7  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $56B9  [3E 64]
    LDH ($FFC9),A                                    ; $56BB  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $56BD  [3E 02]
    LDH ($FFCA),A                                    ; $56BF  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $56C1  [21 DF C0]
    CALL $6A80                                       ; $56C4  [CD 80 6A]
    LD A,($C0D9)                                     ; $56C7  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $56CA  [FE 10]
    JR NZ,$56D8                                      ; $56CC  [20 0A]
    LD A,$00                                         ; $56CE  [3E 00]
    LD ($C0DF),A                                     ; $56D0  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $56D3  [3E 5D]
    CALL $1EFF                                       ; $56D5  [CD FF 1E]  ; PlaySFX
Loc_56D8:
    LD A,($C0D8)                                     ; $56D8  [FA D8 C0]  ; obj_phase
    OR A                                             ; $56DB  [B7]
    DB $C8                                           ; $56DC  [C8]
    LD A,($C0DF)                                     ; $56DD  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $56E0  [B7]
    DB $C8                                           ; $56E1  [C8]
    LD HL,$C0FC                                      ; $56E2  [21 FC C0]
    INC (HL)                                         ; $56E5  [34]
    LD A,$00                                         ; $56E6  [3E 00]
    LD ($C0D8),A                                     ; $56E8  [EA D8 C0]  ; obj_phase
    LD A,$80                                         ; $56EB  [3E 80]
    LD ($C0D9),A                                     ; $56ED  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $56F0  [3E 00]
    LD ($C0DA),A                                     ; $56F2  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $56F5  [3E 00]
    LD ($C0DB),A                                     ; $56F7  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $56FA  [3E 00]
    LD ($C0DC),A                                     ; $56FC  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $56FF  [3E 02]
    LD ($C0DD),A                                     ; $5701  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $5704  [3E 00]
    LD ($C0DE),A                                     ; $5706  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $5709  [3E 01]
    LD ($C0DF),A                                     ; $570B  [EA DF C0]  ; obj_unk_DF
    LD A,$30                                         ; $570E  [3E 30]
    LD ($C0E0),A                                     ; $5710  [EA E0 C0]  ; obj_pos_x
    LD A,$50                                         ; $5713  [3E 50]
    LD ($C0E1),A                                     ; $5715  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $5718  [3E 00]
    LD ($C0E2),A                                     ; $571A  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $571D  [3E 00]
    LD ($C0E3),A                                     ; $571F  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $5722  [3E 04]
    LD ($C0E4),A                                     ; $5724  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $5727  [3E 00]
    LD ($C0E5),A                                     ; $5729  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $572C  [3E 00]
    LD ($C0FD),A                                     ; $572E  [EA FD C0]  ; obj_state_hi
    RET                                              ; $5731  [C9]
Loc_5732:
    LD A,$00                                         ; $5732  [3E 00]
    LDH ($FFB7),A                                    ; $5734  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $5736  [3E 00]
    LDH ($FFBB),A                                    ; $5738  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $573A  [3E 00]
    LDH ($FFC7),A                                    ; $573C  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $573E  [3E 60]
    LDH ($FFC9),A                                    ; $5740  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5742  [3E 02]
    LDH ($FFCA),A                                    ; $5744  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $5746  [21 D8 C0]
    CALL $6A80                                       ; $5749  [CD 80 6A]
    LD HL,$C0D9                                      ; $574C  [21 D9 C0]
    DEC (HL)                                         ; $574F  [35]
    LD HL,$C0DA                                      ; $5750  [21 DA C0]
    INC (HL)                                         ; $5753  [34]
    LD A,($C0D9)                                     ; $5754  [FA D9 C0]  ; obj_init_y
    CP $E0                                           ; $5757  [FE E0]
    CALL Z,$6A37                                     ; $5759  [CC 37 6A]
    LD A,$01                                         ; $575C  [3E 01]
    LDH ($FFC7),A                                    ; $575E  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5760  [3E 64]
    LDH ($FFC9),A                                    ; $5762  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5764  [3E 02]
    LDH ($FFCA),A                                    ; $5766  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $5768  [21 DF C0]
    CALL $6A80                                       ; $576B  [CD 80 6A]
    LD A,($C0D9)                                     ; $576E  [FA D9 C0]  ; obj_init_y
    CP $20                                           ; $5771  [FE 20]
    JR NZ,$577F                                      ; $5773  [20 0A]
    LD A,$00                                         ; $5775  [3E 00]
    LD ($C0DF),A                                     ; $5777  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $577A  [3E 5D]
    CALL $1EFF                                       ; $577C  [CD FF 1E]  ; PlaySFX
Loc_577F:
    LD A,($C0D8)                                     ; $577F  [FA D8 C0]  ; obj_phase
    OR A                                             ; $5782  [B7]
    DB $C8                                           ; $5783  [C8]
    LD A,($C0DF)                                     ; $5784  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $5787  [B7]
    DB $C8                                           ; $5788  [C8]
    LD HL,$C0FC                                      ; $5789  [21 FC C0]
    INC (HL)                                         ; $578C  [34]
    LD A,$00                                         ; $578D  [3E 00]
    LD ($C0D8),A                                     ; $578F  [EA D8 C0]  ; obj_phase
    LD A,$A0                                         ; $5792  [3E A0]
    LD ($C0D9),A                                     ; $5794  [EA D9 C0]  ; obj_init_y
    LD A,$30                                         ; $5797  [3E 30]
    LD ($C0DA),A                                     ; $5799  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $579C  [3E 00]
    LD ($C0DB),A                                     ; $579E  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $57A1  [3E 00]
    LD ($C0DC),A                                     ; $57A3  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $57A6  [3E 02]
    LD ($C0DD),A                                     ; $57A8  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $57AB  [3E 00]
    LD ($C0DE),A                                     ; $57AD  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $57B0  [3E 01]
    LD ($C0DF),A                                     ; $57B2  [EA DF C0]  ; obj_unk_DF
    LD A,$80                                         ; $57B5  [3E 80]
    LD ($C0E0),A                                     ; $57B7  [EA E0 C0]  ; obj_pos_x
    LD A,$50                                         ; $57BA  [3E 50]
    LD ($C0E1),A                                     ; $57BC  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $57BF  [3E 00]
    LD ($C0E2),A                                     ; $57C1  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $57C4  [3E 00]
    LD ($C0E3),A                                     ; $57C6  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $57C9  [3E 04]
    LD ($C0E4),A                                     ; $57CB  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $57CE  [3E 00]
    LD ($C0E5),A                                     ; $57D0  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $57D3  [3E 00]
    LD ($C0E6),A                                     ; $57D5  [EA E6 C0]
    LD A,$40                                         ; $57D8  [3E 40]
    LD ($C0E7),A                                     ; $57DA  [EA E7 C0]
    LD A,$00                                         ; $57DD  [3E 00]
    LD ($C0E8),A                                     ; $57DF  [EA E8 C0]
    LD A,$00                                         ; $57E2  [3E 00]
    LD ($C0E9),A                                     ; $57E4  [EA E9 C0]
    LD A,$00                                         ; $57E7  [3E 00]
    LD ($C0EA),A                                     ; $57E9  [EA EA C0]  ; obj_unk_EA
    LD A,$02                                         ; $57EC  [3E 02]
    LD ($C0EB),A                                     ; $57EE  [EA EB C0]
    LD A,$00                                         ; $57F1  [3E 00]
    LD ($C0EC),A                                     ; $57F3  [EA EC C0]
    LD A,$01                                         ; $57F6  [3E 01]
    LD ($C0ED),A                                     ; $57F8  [EA ED C0]
    LD A,$20                                         ; $57FB  [3E 20]
    LD ($C0EE),A                                     ; $57FD  [EA EE C0]
    LD A,$20                                         ; $5800  [3E 20]
    LD ($C0EF),A                                     ; $5802  [EA EF C0]
    LD A,$00                                         ; $5805  [3E 00]
    LD ($C0F0),A                                     ; $5807  [EA F0 C0]  ; obj_unk_F0
    LD A,$00                                         ; $580A  [3E 00]
    LD ($C0F1),A                                     ; $580C  [EA F1 C0]
    LD A,$04                                         ; $580F  [3E 04]
    LD ($C0F2),A                                     ; $5811  [EA F2 C0]
    LD A,$00                                         ; $5814  [3E 00]
    LD ($C0F3),A                                     ; $5816  [EA F3 C0]
    LD A,$00                                         ; $5819  [3E 00]
    LD ($C0FD),A                                     ; $581B  [EA FD C0]  ; obj_state_hi
    RET                                              ; $581E  [C9]
Loc_581F:
    LD A,$00                                         ; $581F  [3E 00]
    LDH ($FFB7),A                                    ; $5821  [E0 B7]  ; rSFX_CH
    LD A,$00                                         ; $5823  [3E 00]
    LDH ($FFBB),A                                    ; $5825  [E0 BB]  ; spr_wait
    LD A,$00                                         ; $5827  [3E 00]
    LDH ($FFC7),A                                    ; $5829  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $582B  [3E 60]
    LDH ($FFC9),A                                    ; $582D  [E0 C9]  ; spr_attr
    LD A,($C0E7)                                     ; $582F  [FA E7 C0]
    CP $E0                                           ; $5832  [FE E0]
    JR NZ,$583F                                      ; $5834  [20 09]
    LD A,$01                                         ; $5836  [3E 01]
    LD ($C0E6),A                                     ; $5838  [EA E6 C0]
    LD A,$02                                         ; $583B  [3E 02]
    LDH ($FFCA),A                                    ; $583D  [E0 CA]  ; spr_pad
Loc_583F:
    LD HL,$C0E6                                      ; $583F  [21 E6 C0]
    CALL $6A80                                       ; $5842  [CD 80 6A]
    LD HL,$C0E7                                      ; $5845  [21 E7 C0]
    DEC (HL)                                         ; $5848  [35]
    LD HL,$C0E8                                      ; $5849  [21 E8 C0]
    INC (HL)                                         ; $584C  [34]
    LD A,$01                                         ; $584D  [3E 01]
    LDH ($FFC7),A                                    ; $584F  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5851  [3E 64]
    LDH ($FFC9),A                                    ; $5853  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5855  [3E 02]
    LDH ($FFCA),A                                    ; $5857  [E0 CA]  ; spr_pad
    LD HL,$C0ED                                      ; $5859  [21 ED C0]
    CALL $6A80                                       ; $585C  [CD 80 6A]
    LD A,($C0E7)                                     ; $585F  [FA E7 C0]
    CP $10                                           ; $5862  [FE 10]
    JR NZ,$586B                                      ; $5864  [20 05]
    LD A,$00                                         ; $5866  [3E 00]
    LD ($C0ED),A                                     ; $5868  [EA ED C0]
Loc_586B:
    LD A,$00                                         ; $586B  [3E 00]
    LDH ($FFC7),A                                    ; $586D  [E0 C7]  ; spr_tile
    LD A,$60                                         ; $586F  [3E 60]
    LDH ($FFC9),A                                    ; $5871  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5873  [3E 02]
    LDH ($FFCA),A                                    ; $5875  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $5877  [21 D8 C0]
    CALL $6A80                                       ; $587A  [CD 80 6A]
    LD HL,$C0D9                                      ; $587D  [21 D9 C0]
    DEC (HL)                                         ; $5880  [35]
    LD HL,$C0DA                                      ; $5881  [21 DA C0]
    INC (HL)                                         ; $5884  [34]
    LD A,($C0D9)                                     ; $5885  [FA D9 C0]  ; obj_init_y
    CP $28                                           ; $5888  [FE 28]
    CALL Z,$6A37                                     ; $588A  [CC 37 6A]
    LD A,$01                                         ; $588D  [3E 01]
    LDH ($FFC7),A                                    ; $588F  [E0 C7]  ; spr_tile
    LD A,$64                                         ; $5891  [3E 64]
    LDH ($FFC9),A                                    ; $5893  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $5895  [3E 02]
    LDH ($FFCA),A                                    ; $5897  [E0 CA]  ; spr_pad
    LD HL,$C0DF                                      ; $5899  [21 DF C0]
    CALL $6A80                                       ; $589C  [CD 80 6A]
    LD A,($C0D9)                                     ; $589F  [FA D9 C0]  ; obj_init_y
    CP $70                                           ; $58A2  [FE 70]
    JR NZ,$58B0                                      ; $58A4  [20 0A]
    LD A,$00                                         ; $58A6  [3E 00]
    LD ($C0DF),A                                     ; $58A8  [EA DF C0]  ; obj_unk_DF
    LD A,$5D                                         ; $58AB  [3E 5D]
    CALL $1EFF                                       ; $58AD  [CD FF 1E]  ; PlaySFX
Loc_58B0:
    LD A,($C0D8)                                     ; $58B0  [FA D8 C0]  ; obj_phase
    OR A                                             ; $58B3  [B7]
    DB $C8                                           ; $58B4  [C8]
    LD A,($C0DF)                                     ; $58B5  [FA DF C0]  ; obj_unk_DF
    OR A                                             ; $58B8  [B7]
    DB $C8                                           ; $58B9  [C8]
    LD A,($C0E6)                                     ; $58BA  [FA E6 C0]
    OR A                                             ; $58BD  [B7]
    DB $C8                                           ; $58BE  [C8]
    LD HL,$C0FC                                      ; $58BF  [21 FC C0]
    INC (HL)                                         ; $58C2  [34]
    LD A,$00                                         ; $58C3  [3E 00]
    LD ($C0D8),A                                     ; $58C5  [EA D8 C0]  ; obj_phase
    LD A,$80                                         ; $58C8  [3E 80]
    LD ($C0D9),A                                     ; $58CA  [EA D9 C0]  ; obj_init_y
    LD A,$00                                         ; $58CD  [3E 00]
    LD ($C0DA),A                                     ; $58CF  [EA DA C0]  ; obj_unk_DA
    LD A,$00                                         ; $58D2  [3E 00]
    LD ($C0DB),A                                     ; $58D4  [EA DB C0]  ; obj_unk_DB
    LD A,$00                                         ; $58D7  [3E 00]
    LD ($C0DC),A                                     ; $58D9  [EA DC C0]  ; obj_unk_DC
    LD A,$02                                         ; $58DC  [3E 02]
    LD ($C0DD),A                                     ; $58DE  [EA DD C0]  ; obj_speed_x
    LD A,$00                                         ; $58E1  [3E 00]
    LD ($C0DE),A                                     ; $58E3  [EA DE C0]  ; obj_unk_DE
    LD A,$01                                         ; $58E6  [3E 01]
    LD ($C0DF),A                                     ; $58E8  [EA DF C0]  ; obj_unk_DF
    LD A,$50                                         ; $58EB  [3E 50]
    LD ($C0E0),A                                     ; $58ED  [EA E0 C0]  ; obj_pos_x
    LD A,$30                                         ; $58F0  [3E 30]
    LD ($C0E1),A                                     ; $58F2  [EA E1 C0]  ; obj_pos_y
    LD A,$00                                         ; $58F5  [3E 00]
    LD ($C0E2),A                                     ; $58F7  [EA E2 C0]  ; obj_unk_E2
    LD A,$00                                         ; $58FA  [3E 00]
    LD ($C0E3),A                                     ; $58FC  [EA E3 C0]  ; obj_unk_E3
    LD A,$04                                         ; $58FF  [3E 04]
    LD ($C0E4),A                                     ; $5901  [EA E4 C0]  ; obj_timer
    LD A,$00                                         ; $5904  [3E 00]
    LD ($C0E5),A                                     ; $5906  [EA E5 C0]  ; obj_unk_E5
    LD A,$00                                         ; $5909  [3E 00]
    LD ($C0FD),A                                     ; $590B  [EA FD C0]  ; obj_state_hi
    RET                                              ; $590E  [C9]
Loc_5C28:
    LD A,($C0FD)                                     ; $5C28  [FA FD C0]  ; obj_state_hi
    CP $3C                                           ; $5C2B  [FE 3C]
    JR C,$5C68                                       ; $5C2D  [38 39]
    XOR A                                            ; $5C2F  [AF]
    LD ($C0FD),A                                     ; $5C30  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5C33  [21 FC C0]
    INC (HL)                                         ; $5C36  [34]
    RET                                              ; $5C37  [C9]
Loc_5C38:
    LD A,($C0FD)                                     ; $5C38  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $5C3B  [FE 78]
    JR C,$5C68                                       ; $5C3D  [38 29]
    XOR A                                            ; $5C3F  [AF]
    LD ($C0FD),A                                     ; $5C40  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5C43  [21 FC C0]
    INC (HL)                                         ; $5C46  [34]
    RET                                              ; $5C47  [C9]
Loc_5C48:
    LD A,($C0FD)                                     ; $5C48  [FA FD C0]  ; obj_state_hi
    CP $B4                                           ; $5C4B  [FE B4]
    JR C,$5C68                                       ; $5C4D  [38 19]
    XOR A                                            ; $5C4F  [AF]
    LD ($C0FD),A                                     ; $5C50  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5C53  [21 FC C0]
    INC (HL)                                         ; $5C56  [34]
    RET                                              ; $5C57  [C9]
Loc_5C58:
    LD A,($C0FD)                                     ; $5C58  [FA FD C0]  ; obj_state_hi
    CP $F0                                           ; $5C5B  [FE F0]
    JR C,$5C68                                       ; $5C5D  [38 09]
    XOR A                                            ; $5C5F  [AF]
    LD ($C0FD),A                                     ; $5C60  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5C63  [21 FC C0]
    INC (HL)                                         ; $5C66  [34]
    RET                                              ; $5C67  [C9]
Loc_5C68:
    LD HL,$C0FD                                      ; $5C68  [21 FD C0]
    INC (HL)                                         ; $5C6B  [34]
    RET                                              ; $5C6C  [C9]
Loc_5C6D:
    LD A,(DE)                                        ; $5C6D  [1A]
    INC DE                                           ; $5C6E  [13]
    LD C,A                                           ; $5C6F  [4F]
    LD A,(DE)                                        ; $5C70  [1A]
    INC DE                                           ; $5C71  [13]
    LD B,A                                           ; $5C72  [47]
    ADD HL,BC                                        ; $5C73  [09]
    LD A,L                                           ; $5C74  [7D]
    LD ($C0FE),A                                     ; $5C75  [EA FE C0]  ; obj_ptr_lo
    LD A,H                                           ; $5C78  [7C]
    LD ($C0FF),A                                     ; $5C79  [EA FF C0]  ; obj_ptr_hi
    LD A,(DE)                                        ; $5C7C  [1A]
    INC DE                                           ; $5C7D  [13]
    CP $D8                                           ; $5C7E  [FE D8]
    JR Z,$5C88                                       ; $5C80  [28 06]
    CP $D9                                           ; $5C82  [FE D9]
    DB $C8                                           ; $5C84  [C8]
    LD (HL+),A                                       ; $5C85  [22]
    JR $5C7C                                         ; $5C86  [18 F4]
Loc_5C88:
    LD A,($C0FE)                                     ; $5C88  [FA FE C0]  ; obj_ptr_lo
    LD L,A                                           ; $5C8B  [6F]
    LD A,($C0FF)                                     ; $5C8C  [FA FF C0]  ; obj_ptr_hi
    LD H,A                                           ; $5C8F  [67]
    LD A,L                                           ; $5C90  [7D]
    ADD A,$20                                        ; $5C91  [C6 20]
    LD L,A                                           ; $5C93  [6F]
    LD A,H                                           ; $5C94  [7C]
    ADC A,$00                                        ; $5C95  [CE 00]
    LD H,A                                           ; $5C97  [67]
    LD A,L                                           ; $5C98  [7D]
    LD ($C0FE),A                                     ; $5C99  [EA FE C0]  ; obj_ptr_lo
    LD A,H                                           ; $5C9C  [7C]
    LD ($C0FF),A                                     ; $5C9D  [EA FF C0]  ; obj_ptr_hi
    JR $5C7C                                         ; $5CA0  [18 DA]
Loc_5CA2:
    LD HL,$C0FB                                      ; $5CA2  [21 FB C0]
    INC (HL)                                         ; $5CA5  [34]
    LD A,($C0FB)                                     ; $5CA6  [FA FB C0]
    CP $18                                           ; $5CA9  [FE 18]
    RET NZ                                           ; $5CAB  [C0]
    XOR A                                            ; $5CAC  [AF]
    LD ($C0FB),A                                     ; $5CAD  [EA FB C0]
    LD HL,$C0FA                                      ; $5CB0  [21 FA C0]
    INC (HL)                                         ; $5CB3  [34]
    LD A,($C0FA)                                     ; $5CB4  [FA FA C0]
    CP $05                                           ; $5CB7  [FE 05]
    JR NZ,$5CBF                                      ; $5CB9  [20 04]
    XOR A                                            ; $5CBB  [AF]
    LD ($C0FA),A                                     ; $5CBC  [EA FA C0]
Loc_5CBF:
    LD HL,$5CFC                                      ; $5CBF  [21 FC 5C]
    LD A,($C0FA)                                     ; $5CC2  [FA FA C0]
    CALL $6AFF                                       ; $5CC5  [CD FF 6A]
    LD E,L                                           ; $5CC8  [5D]
    LD D,H                                           ; $5CC9  [54]
    LD A,$10                                         ; $5CCA  [3E 10]
    ADD A,E                                          ; $5CCC  [83]
    LD E,A                                           ; $5CCD  [5F]
    LD A,$00                                         ; $5CCE  [3E 00]
    ADC A,D                                          ; $5CD0  [8A]
    LD D,A                                           ; $5CD1  [57]
    LD B,$10                                         ; $5CD2  [06 10]
    DI                                               ; $5CD4  [F3]
    CALL $1E79                                       ; $5CD5  [CD 79 1E]
    LD A,(DE)                                        ; $5CD8  [1A]
    EI                                               ; $5CD9  [FB]
    LD ($C0F9),A                                     ; $5CDA  [EA F9 C0]
    DI                                               ; $5CDD  [F3]
    CALL $1E79                                       ; $5CDE  [CD 79 1E]
    LD A,(HL)                                        ; $5CE1  [7E]
    EI                                               ; $5CE2  [FB]
    PUSH AF                                          ; $5CE3  [F5]
    DI                                               ; $5CE4  [F3]
    CALL $1E79                                       ; $5CE5  [CD 79 1E]
    POP AF                                           ; $5CE8  [F1]
    LD (DE),A                                        ; $5CE9  [12]
    EI                                               ; $5CEA  [FB]
    LD A,($C0F9)                                     ; $5CEB  [FA F9 C0]
    PUSH AF                                          ; $5CEE  [F5]
    DI                                               ; $5CEF  [F3]
    CALL $1E79                                       ; $5CF0  [CD 79 1E]
    POP AF                                           ; $5CF3  [F1]
    LD (HL),A                                        ; $5CF4  [77]
    EI                                               ; $5CF5  [FB]
    INC DE                                           ; $5CF6  [13]
    INC HL                                           ; $5CF7  [23]
    DEC B                                            ; $5CF8  [05]
    JR NZ,$5CD4                                      ; $5CF9  [20 D9]
    RET                                              ; $5CFB  [C9]
Loc_5D06:
    CALL $5DF7                                       ; $5D06  [CD F7 5D]
    LD A,($C0FC)                                     ; $5D09  [FA FC C0]  ; obj_state_lo
    RST $00                                          ; $5D0C  [C7 17 5D 36 5D 4B 5D 69 5D 7E 5D]  ; switch(A)→[$5D17 $5D36 $5D4B $5D69 $5D7E] tbl=[C7 17 5D 36 5D 4B 5D 69 5D 7E 5D]
Loc_5D17:
    LD HL,$C0FD                                      ; $5D17  [21 FD C0]
    INC (HL)                                         ; $5D1A  [34]
    LD A,($C0FD)                                     ; $5D1B  [FA FD C0]  ; obj_state_hi
    CP $05                                           ; $5D1E  [FE 05]
    RET C                                            ; $5D20  [D8]
    XOR A                                            ; $5D21  [AF]
    LD ($C0FD),A                                     ; $5D22  [EA FD C0]  ; obj_state_hi
    LD HL,$FFBB                                      ; $5D25  [21 BB FF]
    DEC (HL)                                         ; $5D28  [35]
    LDH A,($FFBB)                                    ; $5D29  [F0 BB]  ; spr_wait
    OR A                                             ; $5D2B  [B7]
    RET NZ                                           ; $5D2C  [C0]
    XOR A                                            ; $5D2D  [AF]
    LD ($C0FD),A                                     ; $5D2E  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5D31  [21 FC C0]
    INC (HL)                                         ; $5D34  [34]
    RET                                              ; $5D35  [C9]
Loc_5D36:
    LD A,($C0FD)                                     ; $5D36  [FA FD C0]  ; obj_state_hi
    CP $B4                                           ; $5D39  [FE B4]
    JR NC,$5D42                                      ; $5D3B  [30 05]
    LD HL,$C0FD                                      ; $5D3D  [21 FD C0]
    INC (HL)                                         ; $5D40  [34]
    RET                                              ; $5D41  [C9]
Loc_5D42:
    XOR A                                            ; $5D42  [AF]
    LD ($C0FD),A                                     ; $5D43  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5D46  [21 FC C0]
    INC (HL)                                         ; $5D49  [34]
    RET                                              ; $5D4A  [C9]
Loc_5D4B:
    LD A,($C0FD)                                     ; $5D4B  [FA FD C0]  ; obj_state_hi
    OR A                                             ; $5D4E  [B7]
    JR Z,$5D5F                                       ; $5D4F  [28 0E]
    LD A,($C850)                                     ; $5D51  [FA 50 C8]  ; pause_flag
    OR A                                             ; $5D54  [B7]
    RET NZ                                           ; $5D55  [C0]
    LD HL,$C0FC                                      ; $5D56  [21 FC C0]
    INC (HL)                                         ; $5D59  [34]
    XOR A                                            ; $5D5A  [AF]
    LD ($C0FD),A                                     ; $5D5B  [EA FD C0]  ; obj_state_hi
    RET                                              ; $5D5E  [C9]
Loc_5D5F:
    LD HL,$C0FD                                      ; $5D5F  [21 FD C0]
    INC (HL)                                         ; $5D62  [34]
    LD A,$04                                         ; $5D63  [3E 04]
    CALL $1A5B                                       ; $5D65  [CD 5B 1A]  ; TileLoad_Setup
    RET                                              ; $5D68  [C9]
Loc_5D69:
    LD A,($C0FD)                                     ; $5D69  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $5D6C  [FE 78]
    JR NC,$5D75                                      ; $5D6E  [30 05]
    LD HL,$C0FD                                      ; $5D70  [21 FD C0]
    INC (HL)                                         ; $5D73  [34]
    RET                                              ; $5D74  [C9]
Loc_5D75:
    XOR A                                            ; $5D75  [AF]
    LD ($C0FD),A                                     ; $5D76  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5D79  [21 FC C0]
    INC (HL)                                         ; $5D7C  [34]
    RET                                              ; $5D7D  [C9]
Loc_5D7E:
    LD A,$01                                         ; $5D7E  [3E 01]
    LD ($C88A),A                                     ; $5D80  [EA 8A C8]
    LD A,$00                                         ; $5D83  [3E 00]
    LD ($C88B),A                                     ; $5D85  [EA 8B C8]  ; scene_mode
    LD A,$00                                         ; $5D88  [3E 00]
    LD ($C88C),A                                     ; $5D8A  [EA 8C C8]  ; battle_step
    LD A,$00                                         ; $5D8D  [3E 00]
    LD ($C88D),A                                     ; $5D8F  [EA 8D C8]  ; substep
    LD HL,$0004                                      ; $5D92  [21 04 00]
    LD A,L                                           ; $5D95  [7D]
    LD ($C96D),A                                     ; $5D96  [EA 6D C9]
    LD A,H                                           ; $5D99  [7C]
    LD ($C96E),A                                     ; $5D9A  [EA 6E C9]
    LD HL,$00F8                                      ; $5D9D  [21 F8 00]
    LD A,L                                           ; $5DA0  [7D]
    LD ($C96F),A                                     ; $5DA1  [EA 6F C9]
    LD A,H                                           ; $5DA4  [7C]
    LD ($C970),A                                     ; $5DA5  [EA 70 C9]
    LD HL,$0038                                      ; $5DA8  [21 38 00]
    LD A,L                                           ; $5DAB  [7D]
    LD ($C971),A                                     ; $5DAC  [EA 71 C9]
    LD A,H                                           ; $5DAF  [7C]
    LD ($C972),A                                     ; $5DB0  [EA 72 C9]
    LD A,$01                                         ; $5DB3  [3E 01]
    LD ($C96C),A                                     ; $5DB5  [EA 6C C9]
    XOR A                                            ; $5DB8  [AF]
    LDH ($FF90),A                                    ; $5DB9  [E0 90]
    XOR A                                            ; $5DBB  [AF]
    LD ($D8D7),A                                     ; $5DBC  [EA D7 D8]
    LD HL,$C8EB                                      ; $5DBF  [21 EB C8]
    RES 0,(HL)                                       ; $5DC2  [CB 86]
    LD HL,$CAB9                                      ; $5DC4  [21 B9 CA]
    LD A,($CA8D)                                     ; $5DC7  [FA 8D CA]
    LD (HL+),A                                       ; $5DCA  [22]
    LD A,($CA8E)                                     ; $5DCB  [FA 8E CA]
    LD (HL+),A                                       ; $5DCE  [22]
    LD A,($CA8F)                                     ; $5DCF  [FA 8F CA]
    LD (HL+),A                                       ; $5DD2  [22]
    LD A,($CA90)                                     ; $5DD3  [FA 90 CA]
    LD (HL+),A                                       ; $5DD6  [22]
    LD A,($CA91)                                     ; $5DD7  [FA 91 CA]
    LD (HL+),A                                       ; $5DDA  [22]
    LD A,($CA92)                                     ; $5DDB  [FA 92 CA]
    LD (HL+),A                                       ; $5DDE  [22]
    LD A,($CA93)                                     ; $5DDF  [FA 93 CA]
    LD (HL+),A                                       ; $5DE2  [22]
    XOR A                                            ; $5DE3  [AF]
    LD ($CA8D),A                                     ; $5DE4  [EA 8D CA]
    LD A,$FF                                         ; $5DE7  [3E FF]
    LD ($CA8E),A                                     ; $5DE9  [EA 8E CA]
    LD ($CA8F),A                                     ; $5DEC  [EA 8F CA]
    LD ($CA90),A                                     ; $5DEF  [EA 90 CA]
    LD HL,$C88E                                      ; $5DF2  [21 8E C8]
    INC (HL)                                         ; $5DF5  [34]
    RET                                              ; $5DF6  [C9]
Loc_5DF7:
    LD HL,$C0F9                                      ; $5DF7  [21 F9 C0]
    INC (HL)                                         ; $5DFA  [34]
    LD A,($C0F9)                                     ; $5DFB  [FA F9 C0]
    CP $19                                           ; $5DFE  [FE 19]
    JR Z,$5E45                                       ; $5E00  [28 43]
    CP $32                                           ; $5E02  [FE 32]
    RET NZ                                           ; $5E04  [C0]
    XOR A                                            ; $5E05  [AF]
    LD ($C0F9),A                                     ; $5E06  [EA F9 C0]
    XOR A                                            ; $5E09  [AF]
    LD ($C0FA),A                                     ; $5E0A  [EA FA C0]
    LD A,($C0FA)                                     ; $5E0D  [FA FA C0]
    LD HL,$5E8C                                      ; $5E10  [21 8C 5E]
    CALL $6AFF                                       ; $5E13  [CD FF 6A]
    LD E,L                                           ; $5E16  [5D]
    LD D,H                                           ; $5E17  [54]
    LD A,$10                                         ; $5E18  [3E 10]
    ADD A,E                                          ; $5E1A  [83]
    LD E,A                                           ; $5E1B  [5F]
    LD A,$00                                         ; $5E1C  [3E 00]
    ADC A,D                                          ; $5E1E  [8A]
    LD D,A                                           ; $5E1F  [57]
    LD B,$10                                         ; $5E20  [06 10]
    DI                                               ; $5E22  [F3]
    CALL $1E79                                       ; $5E23  [CD 79 1E]
    LD A,(DE)                                        ; $5E26  [1A]
    LD ($C0FB),A                                     ; $5E27  [EA FB C0]
    CALL $1E79                                       ; $5E2A  [CD 79 1E]
    LD A,(HL)                                        ; $5E2D  [7E]
    LD (DE),A                                        ; $5E2E  [12]
    LD A,($C0FB)                                     ; $5E2F  [FA FB C0]
    LD (HL),A                                        ; $5E32  [77]
    EI                                               ; $5E33  [FB]
    INC DE                                           ; $5E34  [13]
    INC HL                                           ; $5E35  [23]
    DEC B                                            ; $5E36  [05]
    JR NZ,$5E22                                      ; $5E37  [20 E9]
    LD HL,$C0FA                                      ; $5E39  [21 FA C0]
    INC (HL)                                         ; $5E3C  [34]
    LD A,($C0FA)                                     ; $5E3D  [FA FA C0]
    CP $02                                           ; $5E40  [FE 02]
    JR NZ,$5E0D                                      ; $5E42  [20 C9]
    RET                                              ; $5E44  [C9]
Loc_5E45:
    XOR A                                            ; $5E45  [AF]
    LD ($C0FA),A                                     ; $5E46  [EA FA C0]
    LD A,($C0FA)                                     ; $5E49  [FA FA C0]
    LD HL,$5E90                                      ; $5E4C  [21 90 5E]
    CALL $6AFF                                       ; $5E4F  [CD FF 6A]
    LD E,L                                           ; $5E52  [5D]
    LD D,H                                           ; $5E53  [54]
    LD A,$20                                         ; $5E54  [3E 20]
    ADD A,E                                          ; $5E56  [83]
    LD E,A                                           ; $5E57  [5F]
    LD A,$00                                         ; $5E58  [3E 00]
    ADC A,D                                          ; $5E5A  [8A]
    LD D,A                                           ; $5E5B  [57]
    LD B,$20                                         ; $5E5C  [06 20]
    DI                                               ; $5E5E  [F3]
    CALL $1E79                                       ; $5E5F  [CD 79 1E]
    LD A,(DE)                                        ; $5E62  [1A]
    LD ($C0FB),A                                     ; $5E63  [EA FB C0]
    EI                                               ; $5E66  [FB]
    DI                                               ; $5E67  [F3]
    CALL $1E79                                       ; $5E68  [CD 79 1E]
    LD A,(HL)                                        ; $5E6B  [7E]
    LD (DE),A                                        ; $5E6C  [12]
    EI                                               ; $5E6D  [FB]
    DI                                               ; $5E6E  [F3]
    CALL $1E79                                       ; $5E6F  [CD 79 1E]
    LD A,($C0FB)                                     ; $5E72  [FA FB C0]
    LD (HL),A                                        ; $5E75  [77]
    EI                                               ; $5E76  [FB]
    INC DE                                           ; $5E77  [13]
    INC HL                                           ; $5E78  [23]
    DEC B                                            ; $5E79  [05]
    JR NZ,$5E5E                                      ; $5E7A  [20 E2]
    LD HL,$C0FA                                      ; $5E7C  [21 FA C0]
    INC (HL)                                         ; $5E7F  [34]
    LD HL,$C0FA                                      ; $5E80  [21 FA C0]
    INC (HL)                                         ; $5E83  [34]
    LD A,($C0FA)                                     ; $5E84  [FA FA C0]
    CP $04                                           ; $5E87  [FE 04]
    JR NZ,$5E49                                      ; $5E89  [20 BE]
    RET                                              ; $5E8B  [C9]
Loc_5E98:
    CALL $5DF7                                       ; $5E98  [CD F7 5D]
    LD A,($C0FC)                                     ; $5E9B  [FA FC C0]  ; obj_state_lo
    RST $00                                          ; $5E9E  [C7 A9 5E C9 5E E7 5E 24 5F 3D 5F]  ; switch(A)→[$5EA9 $5EC9 $5EE7 $5F24 $5F3D] tbl=[C7 A9 5E C9 5E E7 5E 24 5F 3D 5F]
Loc_5EA9:
    LD HL,$C0FD                                      ; $5EA9  [21 FD C0]
    INC (HL)                                         ; $5EAC  [34]
    LD A,($C0FD)                                     ; $5EAD  [FA FD C0]  ; obj_state_hi
    CP $04                                           ; $5EB0  [FE 04]
    RET C                                            ; $5EB2  [D8]
    XOR A                                            ; $5EB3  [AF]
    LD ($C0FD),A                                     ; $5EB4  [EA FD C0]  ; obj_state_hi
    LD HL,$FFBB                                      ; $5EB7  [21 BB FF]
    DEC (HL)                                         ; $5EBA  [35]
    LDH A,($FFBB)                                    ; $5EBB  [F0 BB]  ; spr_wait
    CP $08                                           ; $5EBD  [FE 08]
    RET NZ                                           ; $5EBF  [C0]
    XOR A                                            ; $5EC0  [AF]
    LD ($C0FD),A                                     ; $5EC1  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5EC4  [21 FC C0]
    INC (HL)                                         ; $5EC7  [34]
    RET                                              ; $5EC8  [C9]
Loc_5EC9:
    LD A,($C0FD)                                     ; $5EC9  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $5ECC  [FE 78]
    JR NC,$5ED5                                      ; $5ECE  [30 05]
    LD HL,$C0FD                                      ; $5ED0  [21 FD C0]
    INC (HL)                                         ; $5ED3  [34]
    RET                                              ; $5ED4  [C9]
Loc_5ED5:
    XOR A                                            ; $5ED5  [AF]
    LD ($C0D8),A                                     ; $5ED6  [EA D8 C0]  ; obj_phase
    XOR A                                            ; $5ED9  [AF]
    LD ($C0FD),A                                     ; $5EDA  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5EDD  [21 FC C0]
    INC (HL)                                         ; $5EE0  [34]
    LD A,$68                                         ; $5EE1  [3E 68]
    CALL $1EFF                                       ; $5EE3  [CD FF 1E]  ; PlaySFX
    RET                                              ; $5EE6  [C9]
Loc_5EE7:
    LD A,($C0FD)                                     ; $5EE7  [FA FD C0]  ; obj_state_hi
    CP $F0                                           ; $5EEA  [FE F0]
    JR NC,$5F19                                      ; $5EEC  [30 2B]
    LD HL,$C0FD                                      ; $5EEE  [21 FD C0]
    INC (HL)                                         ; $5EF1  [34]
    LD A,($C0FD)                                     ; $5EF2  [FA FD C0]  ; obj_state_hi
    AND $03                                          ; $5EF5  [E6 03]
    CP $03                                           ; $5EF7  [FE 03]
    RET NZ                                           ; $5EF9  [C0]
    LD HL,$C0D8                                      ; $5EFA  [21 D8 C0]
    INC (HL)                                         ; $5EFD  [34]
    LD A,($C0D8)                                     ; $5EFE  [FA D8 C0]  ; obj_phase
    CP $02                                           ; $5F01  [FE 02]
    JR NZ,$5F09                                      ; $5F03  [20 04]
    XOR A                                            ; $5F05  [AF]
    LD ($C0D8),A                                     ; $5F06  [EA D8 C0]  ; obj_phase
Loc_5F09:
    LD A,($C0D8)                                     ; $5F09  [FA D8 C0]  ; obj_phase
    LD HL,$5F22                                      ; $5F0C  [21 22 5F]
    ADD A,L                                          ; $5F0F  [85]
    LD L,A                                           ; $5F10  [6F]
    LD A,$00                                         ; $5F11  [3E 00]
    ADC A,H                                          ; $5F13  [8C]
    LD H,A                                           ; $5F14  [67]
    LD A,(HL)                                        ; $5F15  [7E]
    LDH ($FFBB),A                                    ; $5F16  [E0 BB]  ; spr_wait
    RET                                              ; $5F18  [C9]
Loc_5F19:
    XOR A                                            ; $5F19  [AF]
    LD ($C0FD),A                                     ; $5F1A  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5F1D  [21 FC C0]
    INC (HL)                                         ; $5F20  [34]
    RET                                              ; $5F21  [C9]
Loc_5F24:
    LD A,($C0FD)                                     ; $5F24  [FA FD C0]  ; obj_state_hi
    CP $3C                                           ; $5F27  [FE 3C]
    JR NC,$5F30                                      ; $5F29  [30 05]
    LD HL,$C0FD                                      ; $5F2B  [21 FD C0]
    INC (HL)                                         ; $5F2E  [34]
    RET                                              ; $5F2F  [C9]
Loc_5F30:
    XOR A                                            ; $5F30  [AF]
    LD ($C0D8),A                                     ; $5F31  [EA D8 C0]  ; obj_phase
    XOR A                                            ; $5F34  [AF]
    LD ($C0FD),A                                     ; $5F35  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $5F38  [21 FC C0]
    INC (HL)                                         ; $5F3B  [34]
    RET                                              ; $5F3C  [C9]
Loc_5F3D:
    LD A,($C0FD)                                     ; $5F3D  [FA FD C0]  ; obj_state_hi
    OR A                                             ; $5F40  [B7]
    JR Z,$5F66                                       ; $5F41  [28 23]
    LD A,($C850)                                     ; $5F43  [FA 50 C8]  ; pause_flag
    OR A                                             ; $5F46  [B7]
    RET NZ                                           ; $5F47  [C0]
    LD A,$01                                         ; $5F48  [3E 01]
    LD ($C88A),A                                     ; $5F4A  [EA 8A C8]
    LD A,$00                                         ; $5F4D  [3E 00]
    LD ($C88B),A                                     ; $5F4F  [EA 8B C8]  ; scene_mode
    LD A,$00                                         ; $5F52  [3E 00]
    LD ($C88C),A                                     ; $5F54  [EA 8C C8]  ; battle_step
    LD A,$00                                         ; $5F57  [3E 00]
    LD ($C88D),A                                     ; $5F59  [EA 8D C8]  ; substep
    LD HL,$C8EA                                      ; $5F5C  [21 EA C8]
    SET 7,(HL)                                       ; $5F5F  [CB FE]
    LD HL,$C88E                                      ; $5F61  [21 8E C8]
    INC (HL)                                         ; $5F64  [34]
    RET                                              ; $5F65  [C9]
Loc_5F66:
    LD HL,$C0FD                                      ; $5F66  [21 FD C0]
    INC (HL)                                         ; $5F69  [34]
    LD A,$04                                         ; $5F6A  [3E 04]
    CALL $1A5B                                       ; $5F6C  [CD 5B 1A]  ; TileLoad_Setup
    RET                                              ; $5F6F  [C9]
Loc_5F70:
    LD A,($C0FC)                                     ; $5F70  [FA FC C0]  ; obj_state_lo
    RST $00                                          ; $5F73  [C7 A9 5E C9 5E E7 5E 24 5F 7E 5F]  ; switch(A)→[$5EA9 $5EC9 $5EE7 $5F24 $5F7E] tbl=[C7 A9 5E C9 5E E7 5E 24 5F 7E 5F]
Loc_5F7E:
    LD A,($C0FD)                                     ; $5F7E  [FA FD C0]  ; obj_state_hi
    OR A                                             ; $5F81  [B7]
    JR Z,$5F66                                       ; $5F82  [28 E2]
    LD A,($C850)                                     ; $5F84  [FA 50 C8]  ; pause_flag
    OR A                                             ; $5F87  [B7]
    RET NZ                                           ; $5F88  [C0]
    LD A,$01                                         ; $5F89  [3E 01]
    LD ($C88A),A                                     ; $5F8B  [EA 8A C8]
    LD A,$00                                         ; $5F8E  [3E 00]
    LD ($C88B),A                                     ; $5F90  [EA 8B C8]  ; scene_mode
    LD A,$00                                         ; $5F93  [3E 00]
    LD ($C88C),A                                     ; $5F95  [EA 8C C8]  ; battle_step
    LD A,$00                                         ; $5F98  [3E 00]
    LD ($C88D),A                                     ; $5F9A  [EA 8D C8]  ; substep
    LD HL,$C8EA                                      ; $5F9D  [21 EA C8]
    SET 7,(HL)                                       ; $5FA0  [CB FE]
    LD HL,$C88E                                      ; $5FA2  [21 8E C8]
    INC (HL)                                         ; $5FA5  [34]
    RET                                              ; $5FA6  [C9]
Loc_5FA7:
    LD DE,$5B18                                      ; $5FA7  [11 18 5B]
    LD HL,$8700                                      ; $5FAA  [21 00 87]
    CALL $194A                                       ; $5FAD  [CD 4A 19]  ; SafeTileLoad
    LD DE,$5B19                                      ; $5FB0  [11 19 5B]
    LD HL,$8740                                      ; $5FB3  [21 40 87]
    CALL $194A                                       ; $5FB6  [CD 4A 19]  ; SafeTileLoad
    XOR A                                            ; $5FB9  [AF]
    LD HL,$C0D8                                      ; $5FBA  [21 D8 C0]
    LD BC,$0028                                      ; $5FBD  [01 28 00]
    CALL $169A                                       ; $5FC0  [CD 9A 16]  ; memset_HL_BC_A
    CALL $6A37                                       ; $5FC3  [CD 37 6A]
    CALL $6A3D                                       ; $5FC6  [CD 3D 6A]
    CALL $6A43                                       ; $5FC9  [CD 43 6A]
    CALL $6A49                                       ; $5FCC  [CD 49 6A]
    CALL $6A4F                                       ; $5FCF  [CD 4F 6A]
    CALL $6A55                                       ; $5FD2  [CD 55 6A]
    RET                                              ; $5FD5  [C9]

; ──────────────────────────────────────────────────────────────────
; Bank2_Fn3  ($5FD6)
; ──────────────────────────────────────────────────────────────────
; Per-frame object update — 15-state machine dispatched on obj_state_lo ($C0FC).
; States 0-14 control scroll / position animation:
;   state 0 ($5FF8): tick $C0FD counter to $F0; when full, check $C0D8
;                     and either advance $C0D8 or reset+INC $C0FC.
;   state 1 ($602E): tick $C0FD to $78 then INC $C0FC.
;   states 2-14: further position/scroll steps, CALL Fn_5FA7 at boundaries.
; Clears flag_D9CB ($D9CB) on certain state transitions.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn3:
    LD A,($C0FC)                                     ; $5FD6  [FA FC C0]  ; obj_state_lo
    RST $00                                          ; $5FD9  [C7 F8 5F 2E 60 4D 60 A9 60 05 61 6A 61 3B 62 8C 64 9F 64 CC 64 0D 65 AB 66 EC 67 1F 68 86 68]  ; switch(A)→[$5FF8 $602E $604D $60A9 $6105 $616A $623B $648C $649F $64CC $650D $66AB $67EC $681F $6886] tbl=[C7 F8 5F 2E 60 4D 60 A9 60 05 61 6A 61 3B 62 8C 64 9F 64 CC 64 0D 65 AB 66 EC 67 1F 68 86 68]
Loc_5FF8:
    LD A,($C0FD)                                     ; $5FF8  [FA FD C0]  ; obj_state_hi
    LD B,A                                           ; $5FFB  [47]
    LD A,($C0D8)                                     ; $5FFC  [FA D8 C0]  ; obj_phase
    OR B                                             ; $5FFF  [B0]
    CALL Z,$5FA7                                     ; $6000  [CC A7 5F]  ; Fn_5FA7
    LD HL,$C0FD                                      ; $6003  [21 FD C0]
    INC (HL)                                         ; $6006  [34]
    LD A,($C0FD)                                     ; $6007  [FA FD C0]  ; obj_state_hi
    CP $F0                                           ; $600A  [FE F0]
    RET C                                            ; $600C  [D8]
    XOR A                                            ; $600D  [AF]
    LD ($C0FD),A                                     ; $600E  [EA FD C0]  ; obj_state_hi
    LD A,($C0D8)                                     ; $6011  [FA D8 C0]  ; obj_phase
    CP $01                                           ; $6014  [FE 01]
    JR NZ,$601D                                      ; $6016  [20 05]
    LD HL,$C0D8                                      ; $6018  [21 D8 C0]
    INC (HL)                                         ; $601B  [34]
    RET                                              ; $601C  [C9]
Loc_601D:
    XOR A                                            ; $601D  [AF]
    LD ($C0FD),A                                     ; $601E  [EA FD C0]  ; obj_state_hi
    XOR A                                            ; $6021  [AF]
    LD ($C0D8),A                                     ; $6022  [EA D8 C0]  ; obj_phase
    XOR A                                            ; $6025  [AF]
    LD ($D9CB),A                                     ; $6026  [EA CB D9]  ; flag_D9CB
    LD HL,$C0FC                                      ; $6029  [21 FC C0]
    INC (HL)                                         ; $602C  [34]
    RET                                              ; $602D  [C9]
Loc_602E:
    LD HL,$C0FD                                      ; $602E  [21 FD C0]
    INC (HL)                                         ; $6031  [34]
    LD A,($C0FD)                                     ; $6032  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $6035  [FE 78]
    RET C                                            ; $6037  [D8]
    XOR A                                            ; $6038  [AF]
    LD ($C0FD),A                                     ; $6039  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $603C  [21 FC C0]
    INC (HL)                                         ; $603F  [34]
    LD HL,$C0D8                                      ; $6040  [21 D8 C0]
    CALL $68A1                                       ; $6043  [CD A1 68]
    LD HL,$C0DE                                      ; $6046  [21 DE C0]
    CALL $68EB                                       ; $6049  [CD EB 68]
    RET                                              ; $604C  [C9]
Loc_604D:
    LD A,$00                                         ; $604D  [3E 00]
    LDH ($FFC7),A                                    ; $604F  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6051  [3E 70]
    LDH ($FFC9),A                                    ; $6053  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6055  [3E 02]
    LDH ($FFCA),A                                    ; $6057  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $6059  [21 D8 C0]
    CALL $6A80                                       ; $605C  [CD 80 6A]
    LD A,($C0D9)                                     ; $605F  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $6062  [D6 02]
    LD ($C0D9),A                                     ; $6064  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $6067  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $606A  [C6 02]
    LD ($C0DA),A                                     ; $606C  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $606F  [FA D9 C0]  ; obj_init_y
    CP $60                                           ; $6072  [FE 60]
    CALL Z,$6A19                                     ; $6074  [CC 19 6A]
    LD A,($C0D9)                                     ; $6077  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $607A  [B7]
    CALL Z,$6A37                                     ; $607B  [CC 37 6A]
    LD A,$01                                         ; $607E  [3E 01]
    LDH ($FFC7),A                                    ; $6080  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $6082  [3E 74]
    LDH ($FFC9),A                                    ; $6084  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6086  [3E 02]
    LDH ($FFCA),A                                    ; $6088  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $608A  [21 DE C0]
    CALL $6A80                                       ; $608D  [CD 80 6A]
    LD HL,$C0FD                                      ; $6090  [21 FD C0]
    INC (HL)                                         ; $6093  [34]
    LD A,($C0FD)                                     ; $6094  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $6097  [FE 78]
    RET C                                            ; $6099  [D8]
    XOR A                                            ; $609A  [AF]
    LD ($C0FD),A                                     ; $609B  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $609E  [21 FC C0]
    INC (HL)                                         ; $60A1  [34]
    LD HL,$C0D8                                      ; $60A2  [21 D8 C0]
    CALL $6937                                       ; $60A5  [CD 37 69]
    RET                                              ; $60A8  [C9]
Loc_60A9:
    LD A,$00                                         ; $60A9  [3E 00]
    LDH ($FFC7),A                                    ; $60AB  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $60AD  [3E 70]
    LDH ($FFC9),A                                    ; $60AF  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $60B1  [3E 02]
    LDH ($FFCA),A                                    ; $60B3  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $60B5  [21 D8 C0]
    CALL $6A80                                       ; $60B8  [CD 80 6A]
    LD A,($C0D9)                                     ; $60BB  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $60BE  [D6 02]
    LD ($C0D9),A                                     ; $60C0  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $60C3  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $60C6  [C6 02]
    LD ($C0DA),A                                     ; $60C8  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $60CB  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $60CE  [FE 10]
    CALL Z,$6A19                                     ; $60D0  [CC 19 6A]
    LD A,($C0D9)                                     ; $60D3  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $60D6  [B7]
    CALL Z,$6A37                                     ; $60D7  [CC 37 6A]
    LD A,$01                                         ; $60DA  [3E 01]
    LDH ($FFC7),A                                    ; $60DC  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $60DE  [3E 74]
    LDH ($FFC9),A                                    ; $60E0  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $60E2  [3E 02]
    LDH ($FFCA),A                                    ; $60E4  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $60E6  [21 DE C0]
    CALL $6A80                                       ; $60E9  [CD 80 6A]
    LD HL,$C0FD                                      ; $60EC  [21 FD C0]
    INC (HL)                                         ; $60EF  [34]
    LD A,($C0FD)                                     ; $60F0  [FA FD C0]  ; obj_state_hi
    CP $78                                           ; $60F3  [FE 78]
    RET C                                            ; $60F5  [D8]
    XOR A                                            ; $60F6  [AF]
    LD ($C0FD),A                                     ; $60F7  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $60FA  [21 FC C0]
    INC (HL)                                         ; $60FD  [34]
    LD HL,$C0D8                                      ; $60FE  [21 D8 C0]
    CALL $6981                                       ; $6101  [CD 81 69]
    RET                                              ; $6104  [C9]
Loc_6105:
    LD A,$00                                         ; $6105  [3E 00]
    LDH ($FFC7),A                                    ; $6107  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6109  [3E 70]
    LDH ($FFC9),A                                    ; $610B  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $610D  [3E 02]
    LDH ($FFCA),A                                    ; $610F  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $6111  [21 D8 C0]
    CALL $6A80                                       ; $6114  [CD 80 6A]
    LD A,($C0D9)                                     ; $6117  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $611A  [D6 02]
    LD ($C0D9),A                                     ; $611C  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $611F  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $6122  [C6 02]
    LD ($C0DA),A                                     ; $6124  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $6127  [FA D9 C0]  ; obj_init_y
    CP $70                                           ; $612A  [FE 70]
    CALL Z,$6A19                                     ; $612C  [CC 19 6A]
    LD A,($C0D9)                                     ; $612F  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $6132  [B7]
    CALL Z,$6A37                                     ; $6133  [CC 37 6A]
    LD A,$01                                         ; $6136  [3E 01]
    LDH ($FFC7),A                                    ; $6138  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $613A  [3E 74]
    LDH ($FFC9),A                                    ; $613C  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $613E  [3E 02]
    LDH ($FFCA),A                                    ; $6140  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $6142  [21 DE C0]
    CALL $6A80                                       ; $6145  [CD 80 6A]
    LD HL,$C0FD                                      ; $6148  [21 FD C0]
    INC (HL)                                         ; $614B  [34]
    LD A,($C0FD)                                     ; $614C  [FA FD C0]  ; obj_state_hi
    CP $3C                                           ; $614F  [FE 3C]
    RET C                                            ; $6151  [D8]
    XOR A                                            ; $6152  [AF]
    LD ($C0FD),A                                     ; $6153  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $6156  [21 FC C0]
    INC (HL)                                         ; $6159  [34]
    LD HL,$C0D8                                      ; $615A  [21 D8 C0]
    CALL $6937                                       ; $615D  [CD 37 69]
    LD HL,$C0E4                                      ; $6160  [21 E4 C0]
    CALL $6981                                       ; $6163  [CD 81 69]
    CALL $6A43                                       ; $6166  [CD 43 6A]
    RET                                              ; $6169  [C9]
Loc_616A:
    LD A,$00                                         ; $616A  [3E 00]
    LDH ($FFC7),A                                    ; $616C  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $616E  [3E 70]
    LDH ($FFC9),A                                    ; $6170  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6172  [3E 02]
    LDH ($FFCA),A                                    ; $6174  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $6176  [21 D8 C0]
    CALL $6A80                                       ; $6179  [CD 80 6A]
    LD A,($C0D9)                                     ; $617C  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $617F  [D6 02]
    LD ($C0D9),A                                     ; $6181  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $6184  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $6187  [C6 02]
    LD ($C0DA),A                                     ; $6189  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $618C  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $618F  [FE 10]
    CALL Z,$6A19                                     ; $6191  [CC 19 6A]
    LD A,($C0D9)                                     ; $6194  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $6197  [B7]
    CALL Z,$6A37                                     ; $6198  [CC 37 6A]
    LD A,$01                                         ; $619B  [3E 01]
    LDH ($FFC7),A                                    ; $619D  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $619F  [3E 74]
    LDH ($FFC9),A                                    ; $61A1  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $61A3  [3E 02]
    LDH ($FFCA),A                                    ; $61A5  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $61A7  [21 DE C0]
    CALL $6A80                                       ; $61AA  [CD 80 6A]
    LD A,($C0FD)                                     ; $61AD  [FA FD C0]  ; obj_state_hi
    CP $10                                           ; $61B0  [FE 10]
    JR C,$61FC                                       ; $61B2  [38 48]
    JR NZ,$61B9                                      ; $61B4  [20 03]
    CALL $6A1F                                       ; $61B6  [CD 1F 6A]
Loc_61B9:
    LD A,$00                                         ; $61B9  [3E 00]
    LDH ($FFC7),A                                    ; $61BB  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $61BD  [3E 70]
    LDH ($FFC9),A                                    ; $61BF  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $61C1  [3E 02]
    LDH ($FFCA),A                                    ; $61C3  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $61C5  [21 E4 C0]
    CALL $6A80                                       ; $61C8  [CD 80 6A]
    LD A,($C0E5)                                     ; $61CB  [FA E5 C0]  ; obj_unk_E5
    SUB $02                                          ; $61CE  [D6 02]
    LD ($C0E5),A                                     ; $61D0  [EA E5 C0]  ; obj_unk_E5
    LD A,($C0E6)                                     ; $61D3  [FA E6 C0]
    ADD A,$02                                        ; $61D6  [C6 02]
    LD ($C0E6),A                                     ; $61D8  [EA E6 C0]
    LD A,($C0E5)                                     ; $61DB  [FA E5 C0]  ; obj_unk_E5
    CP $70                                           ; $61DE  [FE 70]
    CALL Z,$6A25                                     ; $61E0  [CC 25 6A]
    LD A,($C0E5)                                     ; $61E3  [FA E5 C0]  ; obj_unk_E5
    OR A                                             ; $61E6  [B7]
    CALL Z,$6A43                                     ; $61E7  [CC 43 6A]
    LD A,$01                                         ; $61EA  [3E 01]
    LDH ($FFC7),A                                    ; $61EC  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $61EE  [3E 74]
    LDH ($FFC9),A                                    ; $61F0  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $61F2  [3E 02]
    LDH ($FFCA),A                                    ; $61F4  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $61F6  [21 EA C0]
    CALL $6A80                                       ; $61F9  [CD 80 6A]
Loc_61FC:
    LD HL,$C0FD                                      ; $61FC  [21 FD C0]
    INC (HL)                                         ; $61FF  [34]
    LD A,($C0FD)                                     ; $6200  [FA FD C0]  ; obj_state_hi
    CP $C8                                           ; $6203  [FE C8]
    RET C                                            ; $6205  [D8]
    XOR A                                            ; $6206  [AF]
    LD ($C0FD),A                                     ; $6207  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $620A  [21 FC C0]
    INC (HL)                                         ; $620D  [34]
    LD HL,$C0D8                                      ; $620E  [21 D8 C0]
    CALL $6937                                       ; $6211  [CD 37 69]
    LD HL,$C0E4                                      ; $6214  [21 E4 C0]
    CALL $68A1                                       ; $6217  [CD A1 68]
    LD HL,$C0EA                                      ; $621A  [21 EA C0]
    CALL $68EB                                       ; $621D  [CD EB 68]
    LD HL,$C0F0                                      ; $6220  [21 F0 C0]
    CALL $6981                                       ; $6223  [CD 81 69]
    CALL $6A43                                       ; $6226  [CD 43 6A]
    CALL $6A4F                                       ; $6229  [CD 4F 6A]
    CALL $6A13                                       ; $622C  [CD 13 6A]
    LD HL,$D9CB                                      ; $622F  [21 CB D9]
    INC (HL)                                         ; $6232  [34]
    XOR A                                            ; $6233  [AF]
    LD ($C8A6),A                                     ; $6234  [EA A6 C8]
    LD ($C8A7),A                                     ; $6237  [EA A7 C8]
    RET                                              ; $623A  [C9]
Loc_623B:
    LD A,($C0FD)                                     ; $623B  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $623E  [FE 40]
    LD HL,$C0D8                                      ; $6240  [21 D8 C0]
    CALL Z,$6937                                     ; $6243  [CC 37 69]
    LD A,($C0FD)                                     ; $6246  [FA FD C0]  ; obj_state_hi
    CP $60                                           ; $6249  [FE 60]
    LD HL,$C0E4                                      ; $624B  [21 E4 C0]
    CALL Z,$6981                                     ; $624E  [CC 81 69]
    LD A,($C0FD)                                     ; $6251  [FA FD C0]  ; obj_state_hi
    CP $70                                           ; $6254  [FE 70]
    LD HL,$C0F0                                      ; $6256  [21 F0 C0]
    CALL Z,$68A1                                     ; $6259  [CC A1 68]
    LD A,($C0FD)                                     ; $625C  [FA FD C0]  ; obj_state_hi
    CP $70                                           ; $625F  [FE 70]
    LD HL,$C0F6                                      ; $6261  [21 F6 C0]
    CALL Z,$6911                                     ; $6264  [CC 11 69]
    LD A,($C0FD)                                     ; $6267  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $626A  [FE 40]
    CALL Z,$6A37                                     ; $626C  [CC 37 6A]
    LD A,($C0FD)                                     ; $626F  [FA FD C0]  ; obj_state_hi
    CP $60                                           ; $6272  [FE 60]
    CALL Z,$6A43                                     ; $6274  [CC 43 6A]
    LD A,($C0FD)                                     ; $6277  [FA FD C0]  ; obj_state_hi
    CP $70                                           ; $627A  [FE 70]
    CALL Z,$6A4F                                     ; $627C  [CC 4F 6A]
    LD A,($C0FD)                                     ; $627F  [FA FD C0]  ; obj_state_hi
    CP $10                                           ; $6282  [FE 10]
    CALL Z,$6A1F                                     ; $6284  [CC 1F 6A]
    LD A,($C0FD)                                     ; $6287  [FA FD C0]  ; obj_state_hi
    CP $20                                           ; $628A  [FE 20]
    CALL Z,$6A2B                                     ; $628C  [CC 2B 6A]
    LD A,($C0FD)                                     ; $628F  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $6292  [FE 40]
    CALL Z,$6A13                                     ; $6294  [CC 13 6A]
    LD A,($C0FD)                                     ; $6297  [FA FD C0]  ; obj_state_hi
    CP $60                                           ; $629A  [FE 60]
    CALL Z,$6A1F                                     ; $629C  [CC 1F 6A]
    LD A,($C0FD)                                     ; $629F  [FA FD C0]  ; obj_state_hi
    CP $70                                           ; $62A2  [FE 70]
    CALL Z,$6A2B                                     ; $62A4  [CC 2B 6A]
    LD A,($C0FD)                                     ; $62A7  [FA FD C0]  ; obj_state_hi
    CP $80                                           ; $62AA  [FE 80]
    JP NC,$63EB                                      ; $62AC  [D2 EB 63]
    CP $70                                           ; $62AF  [FE 70]
    JP NC,$63A0                                      ; $62B1  [D2 A0 63]
    CP $60                                           ; $62B4  [FE 60]
    JP NC,$6354                                      ; $62B6  [D2 54 63]
    CP $40                                           ; $62B9  [FE 40]
    JP NC,$6309                                      ; $62BB  [D2 09 63]
    LD A,$00                                         ; $62BE  [3E 00]
    LDH ($FFC7),A                                    ; $62C0  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $62C2  [3E 70]
    LDH ($FFC9),A                                    ; $62C4  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $62C6  [3E 02]
    LDH ($FFCA),A                                    ; $62C8  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $62CA  [21 D8 C0]
    CALL $6A80                                       ; $62CD  [CD 80 6A]
    LD A,($C0D9)                                     ; $62D0  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $62D3  [D6 02]
    LD ($C0D9),A                                     ; $62D5  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $62D8  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $62DB  [C6 02]
    LD ($C0DA),A                                     ; $62DD  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $62E0  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $62E3  [FE 10]
    CALL Z,$6A19                                     ; $62E5  [CC 19 6A]
    LD A,($C0D9)                                     ; $62E8  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $62EB  [B7]
    CALL Z,$6A37                                     ; $62EC  [CC 37 6A]
    LD A,$01                                         ; $62EF  [3E 01]
    LDH ($FFC7),A                                    ; $62F1  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $62F3  [3E 74]
    LDH ($FFC9),A                                    ; $62F5  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $62F7  [3E 02]
    LDH ($FFCA),A                                    ; $62F9  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $62FB  [21 DE C0]
    CALL $6A80                                       ; $62FE  [CD 80 6A]
    LD A,($C0FD)                                     ; $6301  [FA FD C0]  ; obj_state_hi
    CP $10                                           ; $6304  [FE 10]
    JP C,$6479                                       ; $6306  [DA 79 64]
Loc_6309:
    LD A,$00                                         ; $6309  [3E 00]
    LDH ($FFC7),A                                    ; $630B  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $630D  [3E 70]
    LDH ($FFC9),A                                    ; $630F  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6311  [3E 02]
    LDH ($FFCA),A                                    ; $6313  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $6315  [21 E4 C0]
    CALL $6A80                                       ; $6318  [CD 80 6A]
    LD A,($C0E5)                                     ; $631B  [FA E5 C0]  ; obj_unk_E5
    SUB $02                                          ; $631E  [D6 02]
    LD ($C0E5),A                                     ; $6320  [EA E5 C0]  ; obj_unk_E5
    LD A,($C0E6)                                     ; $6323  [FA E6 C0]
    ADD A,$02                                        ; $6326  [C6 02]
    LD ($C0E6),A                                     ; $6328  [EA E6 C0]
    LD A,($C0E5)                                     ; $632B  [FA E5 C0]  ; obj_unk_E5
    CP $60                                           ; $632E  [FE 60]
    CALL Z,$6A25                                     ; $6330  [CC 25 6A]
    LD A,($C0E5)                                     ; $6333  [FA E5 C0]  ; obj_unk_E5
    OR A                                             ; $6336  [B7]
    CALL Z,$6A43                                     ; $6337  [CC 43 6A]
    LD A,$01                                         ; $633A  [3E 01]
    LDH ($FFC7),A                                    ; $633C  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $633E  [3E 74]
    LDH ($FFC9),A                                    ; $6340  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6342  [3E 02]
    LDH ($FFCA),A                                    ; $6344  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $6346  [21 EA C0]
    CALL $6A80                                       ; $6349  [CD 80 6A]
    LD A,($C0FD)                                     ; $634C  [FA FD C0]  ; obj_state_hi
    CP $20                                           ; $634F  [FE 20]
    JP C,$6479                                       ; $6351  [DA 79 64]
Loc_6354:
    LD A,$00                                         ; $6354  [3E 00]
    LDH ($FFC7),A                                    ; $6356  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6358  [3E 70]
    LDH ($FFC9),A                                    ; $635A  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $635C  [3E 02]
    LDH ($FFCA),A                                    ; $635E  [E0 CA]  ; spr_pad
    LD HL,$C0F0                                      ; $6360  [21 F0 C0]
    CALL $6A80                                       ; $6363  [CD 80 6A]
    LD A,($C0F1)                                     ; $6366  [FA F1 C0]
    SUB $02                                          ; $6369  [D6 02]
    LD ($C0F1),A                                     ; $636B  [EA F1 C0]
    LD A,($C0F2)                                     ; $636E  [FA F2 C0]
    ADD A,$02                                        ; $6371  [C6 02]
    LD ($C0F2),A                                     ; $6373  [EA F2 C0]
    LD A,($C0F1)                                     ; $6376  [FA F1 C0]
    CP $70                                           ; $6379  [FE 70]
    CALL Z,$6A31                                     ; $637B  [CC 31 6A]
    LD A,($C0F1)                                     ; $637E  [FA F1 C0]
    CP $30                                           ; $6381  [FE 30]
    CALL Z,$6A4F                                     ; $6383  [CC 4F 6A]
    LD A,$01                                         ; $6386  [3E 01]
    LDH ($FFC7),A                                    ; $6388  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $638A  [3E 74]
    LDH ($FFC9),A                                    ; $638C  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $638E  [3E 02]
    LDH ($FFCA),A                                    ; $6390  [E0 CA]  ; spr_pad
    LD HL,$C0F6                                      ; $6392  [21 F6 C0]
    CALL $6A80                                       ; $6395  [CD 80 6A]
    LD A,($C0FD)                                     ; $6398  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $639B  [FE 30]
    JP C,$6479                                       ; $639D  [DA 79 64]
Loc_63A0:
    LD A,$00                                         ; $63A0  [3E 00]
    LDH ($FFC7),A                                    ; $63A2  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $63A4  [3E 70]
    LDH ($FFC9),A                                    ; $63A6  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $63A8  [3E 02]
    LDH ($FFCA),A                                    ; $63AA  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $63AC  [21 D8 C0]
    CALL $6A80                                       ; $63AF  [CD 80 6A]
    LD A,($C0D9)                                     ; $63B2  [FA D9 C0]  ; obj_init_y
    SUB $02                                          ; $63B5  [D6 02]
    LD ($C0D9),A                                     ; $63B7  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $63BA  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $63BD  [C6 02]
    LD ($C0DA),A                                     ; $63BF  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $63C2  [FA D9 C0]  ; obj_init_y
    CP $10                                           ; $63C5  [FE 10]
    CALL Z,$6A19                                     ; $63C7  [CC 19 6A]
    LD A,($C0D9)                                     ; $63CA  [FA D9 C0]  ; obj_init_y
    OR A                                             ; $63CD  [B7]
    CALL Z,$6A37                                     ; $63CE  [CC 37 6A]
    LD A,$01                                         ; $63D1  [3E 01]
    LDH ($FFC7),A                                    ; $63D3  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $63D5  [3E 74]
    LDH ($FFC9),A                                    ; $63D7  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $63D9  [3E 02]
    LDH ($FFCA),A                                    ; $63DB  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $63DD  [21 DE C0]
    CALL $6A80                                       ; $63E0  [CD 80 6A]
    LD A,($C0FD)                                     ; $63E3  [FA FD C0]  ; obj_state_hi
    CP $50                                           ; $63E6  [FE 50]
    JP C,$6479                                       ; $63E8  [DA 79 64]
Loc_63EB:
    LD A,$00                                         ; $63EB  [3E 00]
    LDH ($FFC7),A                                    ; $63ED  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $63EF  [3E 70]
    LDH ($FFC9),A                                    ; $63F1  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $63F3  [3E 02]
    LDH ($FFCA),A                                    ; $63F5  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $63F7  [21 E4 C0]
    CALL $6A80                                       ; $63FA  [CD 80 6A]
    LD A,($C0E5)                                     ; $63FD  [FA E5 C0]  ; obj_unk_E5
    SUB $02                                          ; $6400  [D6 02]
    LD ($C0E5),A                                     ; $6402  [EA E5 C0]  ; obj_unk_E5
    LD A,($C0E6)                                     ; $6405  [FA E6 C0]
    ADD A,$02                                        ; $6408  [C6 02]
    LD ($C0E6),A                                     ; $640A  [EA E6 C0]
    LD A,($C0E5)                                     ; $640D  [FA E5 C0]  ; obj_unk_E5
    CP $70                                           ; $6410  [FE 70]
    CALL Z,$6A25                                     ; $6412  [CC 25 6A]
    LD A,($C0E5)                                     ; $6415  [FA E5 C0]  ; obj_unk_E5
    CP $30                                           ; $6418  [FE 30]
    CALL Z,$6A43                                     ; $641A  [CC 43 6A]
    LD A,$01                                         ; $641D  [3E 01]
    LDH ($FFC7),A                                    ; $641F  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $6421  [3E 74]
    LDH ($FFC9),A                                    ; $6423  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6425  [3E 02]
    LDH ($FFCA),A                                    ; $6427  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $6429  [21 EA C0]
    CALL $6A80                                       ; $642C  [CD 80 6A]
    LD A,($C0FD)                                     ; $642F  [FA FD C0]  ; obj_state_hi
    CP $60                                           ; $6432  [FE 60]
    JR C,$6479                                       ; $6434  [38 43]
    LD A,$00                                         ; $6436  [3E 00]
    LDH ($FFC7),A                                    ; $6438  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $643A  [3E 70]
    LDH ($FFC9),A                                    ; $643C  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $643E  [3E 02]
    LDH ($FFCA),A                                    ; $6440  [E0 CA]  ; spr_pad
    LD HL,$C0F0                                      ; $6442  [21 F0 C0]
    CALL $6A80                                       ; $6445  [CD 80 6A]
    LD A,($C0F1)                                     ; $6448  [FA F1 C0]
    SUB $02                                          ; $644B  [D6 02]
    LD ($C0F1),A                                     ; $644D  [EA F1 C0]
    LD A,($C0F2)                                     ; $6450  [FA F2 C0]
    ADD A,$02                                        ; $6453  [C6 02]
    LD ($C0F2),A                                     ; $6455  [EA F2 C0]
    LD A,($C0E5)                                     ; $6458  [FA E5 C0]  ; obj_unk_E5
    CP $20                                           ; $645B  [FE 20]
    CALL Z,$6A31                                     ; $645D  [CC 31 6A]
    LD A,($C0F1)                                     ; $6460  [FA F1 C0]
    OR A                                             ; $6463  [B7]
    CALL Z,$6A4F                                     ; $6464  [CC 4F 6A]
    LD A,$01                                         ; $6467  [3E 01]
    LDH ($FFC7),A                                    ; $6469  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $646B  [3E 74]
    LDH ($FFC9),A                                    ; $646D  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $646F  [3E 02]
    LDH ($FFCA),A                                    ; $6471  [E0 CA]  ; spr_pad
    LD HL,$C0F6                                      ; $6473  [21 F6 C0]
    CALL $6A80                                       ; $6476  [CD 80 6A]
Loc_6479:
    LD HL,$C0FD                                      ; $6479  [21 FD C0]
    INC (HL)                                         ; $647C  [34]
    LD A,($C0FD)                                     ; $647D  [FA FD C0]  ; obj_state_hi
    CP $B4                                           ; $6480  [FE B4]
    RET C                                            ; $6482  [D8]
    XOR A                                            ; $6483  [AF]
    LD ($C0FD),A                                     ; $6484  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $6487  [21 FC C0]
    INC (HL)                                         ; $648A  [34]
    RET                                              ; $648B  [C9]
Loc_648C:
    LD HL,$C0FD                                      ; $648C  [21 FD C0]
    INC (HL)                                         ; $648F  [34]
    LD A,($C0FD)                                     ; $6490  [FA FD C0]  ; obj_state_hi
    CP $AA                                           ; $6493  [FE AA]
    RET C                                            ; $6495  [D8]
    XOR A                                            ; $6496  [AF]
    LD ($C0FD),A                                     ; $6497  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $649A  [21 FC C0]
    INC (HL)                                         ; $649D  [34]
    RET                                              ; $649E  [C9]
Loc_649F:
    LD A,($C8A6)                                     ; $649F  [FA A6 C8]
    LD L,A                                           ; $64A2  [6F]
    LD A,($C8A7)                                     ; $64A3  [FA A7 C8]
    LD H,A                                           ; $64A6  [67]
    LD C,L                                           ; $64A7  [4D]
    LD B,H                                           ; $64A8  [44]
    ADD HL,HL                                        ; $64A9  [29]
    ADD HL,BC                                        ; $64AA  [09]
    SRL H                                            ; $64AB  [CB 3C]
    RR L                                             ; $64AD  [CB 1D]
    SRL H                                            ; $64AF  [CB 3C]
    RR L                                             ; $64B1  [CB 1D]
    SRL H                                            ; $64B3  [CB 3C]
    RR L                                             ; $64B5  [CB 1D]
    SRL H                                            ; $64B7  [CB 3C]
    RR L                                             ; $64B9  [CB 1D]
    SRL H                                            ; $64BB  [CB 3C]
    RR L                                             ; $64BD  [CB 1D]
    LD A,L                                           ; $64BF  [7D]
    AND $1F                                          ; $64C0  [E6 1F]
    RET NZ                                           ; $64C2  [C0]
    XOR A                                            ; $64C3  [AF]
    LD ($C0FD),A                                     ; $64C4  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $64C7  [21 FC C0]
    INC (HL)                                         ; $64CA  [34]
    RET                                              ; $64CB  [C9]
Loc_64CC:
    LD A,($C8A6)                                     ; $64CC  [FA A6 C8]
    LD L,A                                           ; $64CF  [6F]
    LD A,($C8A7)                                     ; $64D0  [FA A7 C8]
    LD H,A                                           ; $64D3  [67]
    LD C,L                                           ; $64D4  [4D]
    LD B,H                                           ; $64D5  [44]
    ADD HL,HL                                        ; $64D6  [29]
    ADD HL,BC                                        ; $64D7  [09]
    SRL H                                            ; $64D8  [CB 3C]
    RR L                                             ; $64DA  [CB 1D]
    SRL H                                            ; $64DC  [CB 3C]
    RR L                                             ; $64DE  [CB 1D]
    SRL H                                            ; $64E0  [CB 3C]
    RR L                                             ; $64E2  [CB 1D]
    SRL H                                            ; $64E4  [CB 3C]
    RR L                                             ; $64E6  [CB 1D]
    SRL H                                            ; $64E8  [CB 3C]
    RR L                                             ; $64EA  [CB 1D]
    LD A,L                                           ; $64EC  [7D]
    AND $1F                                          ; $64ED  [E6 1F]
    CP $0F                                           ; $64EF  [FE 0F]
    RET NZ                                           ; $64F1  [C0]
    XOR A                                            ; $64F2  [AF]
    LD ($C0FD),A                                     ; $64F3  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $64F6  [21 FC C0]
    INC (HL)                                         ; $64F9  [34]
    LD HL,$C0D8                                      ; $64FA  [21 D8 C0]
    CALL $695C                                       ; $64FD  [CD 5C 69]
    LD HL,$C0E4                                      ; $6500  [21 E4 C0]
    CALL $6937                                       ; $6503  [CD 37 69]
    CALL $6A43                                       ; $6506  [CD 43 6A]
    CALL $6A13                                       ; $6509  [CD 13 6A]
    RET                                              ; $650C  [C9]
Loc_650D:
    LD A,($C0FD)                                     ; $650D  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $6510  [FE 30]
    LD HL,$C0D8                                      ; $6512  [21 D8 C0]
    CALL Z,$68C6                                     ; $6515  [CC C6 68]
    LD A,($C0FD)                                     ; $6518  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $651B  [FE 40]
    LD HL,$C0E4                                      ; $651D  [21 E4 C0]
    CALL Z,$68A1                                     ; $6520  [CC A1 68]
    LD A,($C0FD)                                     ; $6523  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $6526  [FE 30]
    CALL Z,$6A37                                     ; $6528  [CC 37 6A]
    LD A,($C0FD)                                     ; $652B  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $652E  [FE 40]
    CALL Z,$6A43                                     ; $6530  [CC 43 6A]
    LD A,($C0FD)                                     ; $6533  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $6536  [FE 30]
    LD HL,$C0DE                                      ; $6538  [21 DE C0]
    CALL Z,$6924                                     ; $653B  [CC 24 69]
    LD A,($C0FD)                                     ; $653E  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $6541  [FE 40]
    LD HL,$C0EA                                      ; $6543  [21 EA C0]
    CALL Z,$6911                                     ; $6546  [CC 11 69]
    LD A,($C0FD)                                     ; $6549  [FA FD C0]  ; obj_state_hi
    CP $10                                           ; $654C  [FE 10]
    CALL Z,$6A1F                                     ; $654E  [CC 1F 6A]
    LD A,($C0FD)                                     ; $6551  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $6554  [FE 30]
    CALL Z,$6A13                                     ; $6556  [CC 13 6A]
    LD A,($C0FD)                                     ; $6559  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $655C  [FE 40]
    CALL Z,$6A1F                                     ; $655E  [CC 1F 6A]
    LD A,($C0FD)                                     ; $6561  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $6564  [FE 40]
    JP NC,$6604                                      ; $6566  [D2 04 66]
    CP $30                                           ; $6569  [FE 30]
    JR NC,$65B9                                      ; $656B  [30 4C]
    LD A,$00                                         ; $656D  [3E 00]
    LDH ($FFC7),A                                    ; $656F  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6571  [3E 70]
    LDH ($FFC9),A                                    ; $6573  [E0 C9]  ; spr_attr
    LD A,$22                                         ; $6575  [3E 22]
    LDH ($FFCA),A                                    ; $6577  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $6579  [21 D8 C0]
    CALL $6A80                                       ; $657C  [CD 80 6A]
    LD A,($C0D9)                                     ; $657F  [FA D9 C0]  ; obj_init_y
    ADD A,$02                                        ; $6582  [C6 02]
    LD ($C0D9),A                                     ; $6584  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $6587  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $658A  [C6 02]
    LD ($C0DA),A                                     ; $658C  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $658F  [FA D9 C0]  ; obj_init_y
    CP $90                                           ; $6592  [FE 90]
    CALL Z,$6A19                                     ; $6594  [CC 19 6A]
    LD A,($C0D9)                                     ; $6597  [FA D9 C0]  ; obj_init_y
    CP $B0                                           ; $659A  [FE B0]
    CALL Z,$6A37                                     ; $659C  [CC 37 6A]
    LD A,$01                                         ; $659F  [3E 01]
    LDH ($FFC7),A                                    ; $65A1  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $65A3  [3E 74]
    LDH ($FFC9),A                                    ; $65A5  [E0 C9]  ; spr_attr
    LD A,$22                                         ; $65A7  [3E 22]
    LDH ($FFCA),A                                    ; $65A9  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $65AB  [21 DE C0]
    CALL $6A80                                       ; $65AE  [CD 80 6A]
    LD A,($C0FD)                                     ; $65B1  [FA FD C0]  ; obj_state_hi
    CP $10                                           ; $65B4  [FE 10]
    JP C,$6692                                       ; $65B6  [DA 92 66]
Loc_65B9:
    LD A,$00                                         ; $65B9  [3E 00]
    LDH ($FFC7),A                                    ; $65BB  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $65BD  [3E 70]
    LDH ($FFC9),A                                    ; $65BF  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $65C1  [3E 02]
    LDH ($FFCA),A                                    ; $65C3  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $65C5  [21 E4 C0]
    CALL $6A80                                       ; $65C8  [CD 80 6A]
    LD A,($C0E5)                                     ; $65CB  [FA E5 C0]  ; obj_unk_E5
    SUB $02                                          ; $65CE  [D6 02]
    LD ($C0E5),A                                     ; $65D0  [EA E5 C0]  ; obj_unk_E5
    LD A,($C0E6)                                     ; $65D3  [FA E6 C0]
    ADD A,$02                                        ; $65D6  [C6 02]
    LD ($C0E6),A                                     ; $65D8  [EA E6 C0]
    LD A,($C0E5)                                     ; $65DB  [FA E5 C0]  ; obj_unk_E5
    CP $10                                           ; $65DE  [FE 10]
    CALL Z,$6A25                                     ; $65E0  [CC 25 6A]
    LD A,($C0E5)                                     ; $65E3  [FA E5 C0]  ; obj_unk_E5
    OR A                                             ; $65E6  [B7]
    CALL Z,$6A43                                     ; $65E7  [CC 43 6A]
    LD A,$01                                         ; $65EA  [3E 01]
    LDH ($FFC7),A                                    ; $65EC  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $65EE  [3E 74]
    LDH ($FFC9),A                                    ; $65F0  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $65F2  [3E 02]
    LDH ($FFCA),A                                    ; $65F4  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $65F6  [21 EA C0]
    CALL $6A80                                       ; $65F9  [CD 80 6A]
    LD A,($C0FD)                                     ; $65FC  [FA FD C0]  ; obj_state_hi
    CP $30                                           ; $65FF  [FE 30]
    JP C,$6692                                       ; $6601  [DA 92 66]
Loc_6604:
    LD A,$00                                         ; $6604  [3E 00]
    LDH ($FFC7),A                                    ; $6606  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6608  [3E 70]
    LDH ($FFC9),A                                    ; $660A  [E0 C9]  ; spr_attr
    LD A,$22                                         ; $660C  [3E 22]
    LDH ($FFCA),A                                    ; $660E  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $6610  [21 D8 C0]
    CALL $6A80                                       ; $6613  [CD 80 6A]
    LD A,($C0D9)                                     ; $6616  [FA D9 C0]  ; obj_init_y
    ADD A,$02                                        ; $6619  [C6 02]
    LD ($C0D9),A                                     ; $661B  [EA D9 C0]  ; obj_init_y
    LD A,($C0DA)                                     ; $661E  [FA DA C0]  ; obj_unk_DA
    ADD A,$02                                        ; $6621  [C6 02]
    LD ($C0DA),A                                     ; $6623  [EA DA C0]  ; obj_unk_DA
    LD A,($C0D9)                                     ; $6626  [FA D9 C0]  ; obj_init_y
    CP $80                                           ; $6629  [FE 80]
    CALL Z,$6A19                                     ; $662B  [CC 19 6A]
    LD A,($C0D9)                                     ; $662E  [FA D9 C0]  ; obj_init_y
    CP $B0                                           ; $6631  [FE B0]
    CALL Z,$6A37                                     ; $6633  [CC 37 6A]
    LD A,$01                                         ; $6636  [3E 01]
    LDH ($FFC7),A                                    ; $6638  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $663A  [3E 74]
    LDH ($FFC9),A                                    ; $663C  [E0 C9]  ; spr_attr
    LD A,$22                                         ; $663E  [3E 22]
    LDH ($FFCA),A                                    ; $6640  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $6642  [21 DE C0]
    CALL $6A80                                       ; $6645  [CD 80 6A]
    LD A,($C0FD)                                     ; $6648  [FA FD C0]  ; obj_state_hi
    CP $40                                           ; $664B  [FE 40]
    JR C,$6692                                       ; $664D  [38 43]
    LD A,$00                                         ; $664F  [3E 00]
    LDH ($FFC7),A                                    ; $6651  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6653  [3E 70]
    LDH ($FFC9),A                                    ; $6655  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6657  [3E 02]
    LDH ($FFCA),A                                    ; $6659  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $665B  [21 E4 C0]
    CALL $6A80                                       ; $665E  [CD 80 6A]
    LD A,($C0E5)                                     ; $6661  [FA E5 C0]  ; obj_unk_E5
    SUB $02                                          ; $6664  [D6 02]
    LD ($C0E5),A                                     ; $6666  [EA E5 C0]  ; obj_unk_E5
    LD A,($C0E6)                                     ; $6669  [FA E6 C0]
    ADD A,$02                                        ; $666C  [C6 02]
    LD ($C0E6),A                                     ; $666E  [EA E6 C0]
    LD A,($C0E5)                                     ; $6671  [FA E5 C0]  ; obj_unk_E5
    CP $20                                           ; $6674  [FE 20]
    CALL Z,$6A25                                     ; $6676  [CC 25 6A]
    LD A,($C0E5)                                     ; $6679  [FA E5 C0]  ; obj_unk_E5
    OR A                                             ; $667C  [B7]
    CALL Z,$6A43                                     ; $667D  [CC 43 6A]
    LD A,$01                                         ; $6680  [3E 01]
    LDH ($FFC7),A                                    ; $6682  [E0 C7]  ; spr_tile
    LD A,$74                                         ; $6684  [3E 74]
    LDH ($FFC9),A                                    ; $6686  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6688  [3E 02]
    LDH ($FFCA),A                                    ; $668A  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $668C  [21 EA C0]
    CALL $6A80                                       ; $668F  [CD 80 6A]
Loc_6692:
    LD HL,$C0FD                                      ; $6692  [21 FD C0]
    INC (HL)                                         ; $6695  [34]
    LD A,($C0FD)                                     ; $6696  [FA FD C0]  ; obj_state_hi
    CP $B4                                           ; $6699  [FE B4]
    RET C                                            ; $669B  [D8]
    XOR A                                            ; $669C  [AF]
    LD ($C0FD),A                                     ; $669D  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $66A0  [21 FC C0]
    INC (HL)                                         ; $66A3  [34]
    LD HL,$C0D8                                      ; $66A4  [21 D8 C0]
    CALL $69A6                                       ; $66A7  [CD A6 69]
    RET                                              ; $66AA  [C9]
Loc_66AB:
    LD A,($C0DE)                                     ; $66AB  [FA DE C0]  ; obj_unk_DE
    OR A                                             ; $66AE  [B7]
    JR NZ,$66DF                                      ; $66AF  [20 2E]
    LD A,$05                                         ; $66B1  [3E 05]
    LDH ($FFC7),A                                    ; $66B3  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $66B5  [3E 70]
    LDH ($FFC9),A                                    ; $66B7  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $66B9  [3E 02]
    LDH ($FFCA),A                                    ; $66BB  [E0 CA]  ; spr_pad
    LD HL,$C0DE                                      ; $66BD  [21 DE C0]
    CALL $6A80                                       ; $66C0  [CD 80 6A]
    LD A,($C0E0)                                     ; $66C3  [FA E0 C0]  ; obj_pos_x
    SUB $02                                          ; $66C6  [D6 02]
    LD ($C0E0),A                                     ; $66C8  [EA E0 C0]  ; obj_pos_x
    LD A,($C0FD)                                     ; $66CB  [FA FD C0]  ; obj_state_hi
    CP $14                                           ; $66CE  [FE 14]
    JR NZ,$66D5                                      ; $66D0  [20 03]
    CALL $6A31                                       ; $66D2  [CD 31 6A]
Loc_66D5:
    LD A,($C0E0)                                     ; $66D5  [FA E0 C0]  ; obj_pos_x
    CP $F0                                           ; $66D8  [FE F0]
    JR C,$66DF                                       ; $66DA  [38 03]
    CALL $6A3D                                       ; $66DC  [CD 3D 6A]
Loc_66DF:
    LD A,($C0F6)                                     ; $66DF  [FA F6 C0]  ; obj_unk_F6
    OR A                                             ; $66E2  [B7]
    JR NZ,$6713                                      ; $66E3  [20 2E]
    LD A,$05                                         ; $66E5  [3E 05]
    LDH ($FFC7),A                                    ; $66E7  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $66E9  [3E 70]
    LDH ($FFC9),A                                    ; $66EB  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $66ED  [3E 02]
    LDH ($FFCA),A                                    ; $66EF  [E0 CA]  ; spr_pad
    LD HL,$C0F6                                      ; $66F1  [21 F6 C0]
    CALL $6A80                                       ; $66F4  [CD 80 6A]
    LD A,($C0F8)                                     ; $66F7  [FA F8 C0]
    SUB $02                                          ; $66FA  [D6 02]
    LD ($C0F8),A                                     ; $66FC  [EA F8 C0]
    LD A,($C0FD)                                     ; $66FF  [FA FD C0]  ; obj_state_hi
    CP $28                                           ; $6702  [FE 28]
    JR NZ,$6709                                      ; $6704  [20 03]
    CALL $6A25                                       ; $6706  [CD 25 6A]
Loc_6709:
    LD A,($C0F8)                                     ; $6709  [FA F8 C0]
    CP $F0                                           ; $670C  [FE F0]
    JR C,$6713                                       ; $670E  [38 03]
    CALL $6A55                                       ; $6710  [CD 55 6A]
Loc_6713:
    LD A,($C0EA)                                     ; $6713  [FA EA C0]  ; obj_unk_EA
    OR A                                             ; $6716  [B7]
    JR NZ,$6747                                      ; $6717  [20 2E]
    LD A,$05                                         ; $6719  [3E 05]
    LDH ($FFC7),A                                    ; $671B  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $671D  [3E 70]
    LDH ($FFC9),A                                    ; $671F  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6721  [3E 02]
    LDH ($FFCA),A                                    ; $6723  [E0 CA]  ; spr_pad
    LD HL,$C0EA                                      ; $6725  [21 EA C0]
    CALL $6A80                                       ; $6728  [CD 80 6A]
    LD A,($C0EC)                                     ; $672B  [FA EC C0]
    SUB $02                                          ; $672E  [D6 02]
    LD ($C0EC),A                                     ; $6730  [EA EC C0]
    LD A,($C0FD)                                     ; $6733  [FA FD C0]  ; obj_state_hi
    CP $3C                                           ; $6736  [FE 3C]
    JR NZ,$673D                                      ; $6738  [20 03]
    CALL $6A1F                                       ; $673A  [CD 1F 6A]
Loc_673D:
    LD A,($C0EC)                                     ; $673D  [FA EC C0]
    CP $F0                                           ; $6740  [FE F0]
    JR C,$6747                                       ; $6742  [38 03]
    CALL $6A49                                       ; $6744  [CD 49 6A]
Loc_6747:
    LD A,($C0E4)                                     ; $6747  [FA E4 C0]  ; obj_timer
    OR A                                             ; $674A  [B7]
    JR NZ,$677B                                      ; $674B  [20 2E]
    LD A,$05                                         ; $674D  [3E 05]
    LDH ($FFC7),A                                    ; $674F  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6751  [3E 70]
    LDH ($FFC9),A                                    ; $6753  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6755  [3E 02]
    LDH ($FFCA),A                                    ; $6757  [E0 CA]  ; spr_pad
    LD HL,$C0E4                                      ; $6759  [21 E4 C0]
    CALL $6A80                                       ; $675C  [CD 80 6A]
    LD A,($C0E6)                                     ; $675F  [FA E6 C0]
    SUB $02                                          ; $6762  [D6 02]
    LD ($C0E6),A                                     ; $6764  [EA E6 C0]
    LD A,($C0FD)                                     ; $6767  [FA FD C0]  ; obj_state_hi
    CP $50                                           ; $676A  [FE 50]
    JR NZ,$6771                                      ; $676C  [20 03]
    CALL $6A2B                                       ; $676E  [CD 2B 6A]
Loc_6771:
    LD A,($C0E6)                                     ; $6771  [FA E6 C0]
    CP $F0                                           ; $6774  [FE F0]
    JR C,$677B                                       ; $6776  [38 03]
    CALL $6A43                                       ; $6778  [CD 43 6A]
Loc_677B:
    LD A,($C0F0)                                     ; $677B  [FA F0 C0]  ; obj_unk_F0
    OR A                                             ; $677E  [B7]
    JR NZ,$67AF                                      ; $677F  [20 2E]
    LD A,$05                                         ; $6781  [3E 05]
    LDH ($FFC7),A                                    ; $6783  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $6785  [3E 70]
    LDH ($FFC9),A                                    ; $6787  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $6789  [3E 02]
    LDH ($FFCA),A                                    ; $678B  [E0 CA]  ; spr_pad
    LD HL,$C0F0                                      ; $678D  [21 F0 C0]
    CALL $6A80                                       ; $6790  [CD 80 6A]
    LD A,($C0F2)                                     ; $6793  [FA F2 C0]
    SUB $02                                          ; $6796  [D6 02]
    LD ($C0F2),A                                     ; $6798  [EA F2 C0]
    LD A,($C0FD)                                     ; $679B  [FA FD C0]  ; obj_state_hi
    CP $64                                           ; $679E  [FE 64]
    JR NZ,$67A5                                      ; $67A0  [20 03]
    CALL $6A13                                       ; $67A2  [CD 13 6A]
Loc_67A5:
    LD A,($C0F2)                                     ; $67A5  [FA F2 C0]
    CP $F0                                           ; $67A8  [FE F0]
    JR C,$67AF                                       ; $67AA  [38 03]
    CALL $6A4F                                       ; $67AC  [CD 4F 6A]
Loc_67AF:
    LD A,($C0D8)                                     ; $67AF  [FA D8 C0]  ; obj_phase
    OR A                                             ; $67B2  [B7]
    JR NZ,$67D9                                      ; $67B3  [20 24]
    LD A,$05                                         ; $67B5  [3E 05]
    LDH ($FFC7),A                                    ; $67B7  [E0 C7]  ; spr_tile
    LD A,$70                                         ; $67B9  [3E 70]
    LDH ($FFC9),A                                    ; $67BB  [E0 C9]  ; spr_attr
    LD A,$02                                         ; $67BD  [3E 02]
    LDH ($FFCA),A                                    ; $67BF  [E0 CA]  ; spr_pad
    LD HL,$C0D8                                      ; $67C1  [21 D8 C0]
    CALL $6A80                                       ; $67C4  [CD 80 6A]
    LD A,($C0DA)                                     ; $67C7  [FA DA C0]  ; obj_unk_DA
    SUB $02                                          ; $67CA  [D6 02]
    LD ($C0DA),A                                     ; $67CC  [EA DA C0]  ; obj_unk_DA
    LD A,($C0DA)                                     ; $67CF  [FA DA C0]  ; obj_unk_DA
    CP $F0                                           ; $67D2  [FE F0]
    JR C,$67D9                                       ; $67D4  [38 03]
    CALL $6A37                                       ; $67D6  [CD 37 6A]
Loc_67D9:
    LD HL,$C0FD                                      ; $67D9  [21 FD C0]
    INC (HL)                                         ; $67DC  [34]
    LD A,($C0FD)                                     ; $67DD  [FA FD C0]  ; obj_state_hi
    CP $B4                                           ; $67E0  [FE B4]
    RET C                                            ; $67E2  [D8]
    XOR A                                            ; $67E3  [AF]
    LD ($C0FD),A                                     ; $67E4  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $67E7  [21 FC C0]
    INC (HL)                                         ; $67EA  [34]
    RET                                              ; $67EB  [C9]
Loc_67EC:
    LD A,($C8A6)                                     ; $67EC  [FA A6 C8]
    LD L,A                                           ; $67EF  [6F]
    LD A,($C8A7)                                     ; $67F0  [FA A7 C8]
    LD H,A                                           ; $67F3  [67]
    LD C,L                                           ; $67F4  [4D]
    LD B,H                                           ; $67F5  [44]
    ADD HL,HL                                        ; $67F6  [29]
    ADD HL,BC                                        ; $67F7  [09]
    SRL H                                            ; $67F8  [CB 3C]
    RR L                                             ; $67FA  [CB 1D]
    SRL H                                            ; $67FC  [CB 3C]
    RR L                                             ; $67FE  [CB 1D]
    SRL H                                            ; $6800  [CB 3C]
    RR L                                             ; $6802  [CB 1D]
    SRL H                                            ; $6804  [CB 3C]
    RR L                                             ; $6806  [CB 1D]
    SRL H                                            ; $6808  [CB 3C]
    RR L                                             ; $680A  [CB 1D]
    LD A,L                                           ; $680C  [7D]
    AND $1F                                          ; $680D  [E6 1F]
    CP $10                                           ; $680F  [FE 10]
    RET NZ                                           ; $6811  [C0]
    XOR A                                            ; $6812  [AF]
    LD ($C0FD),A                                     ; $6813  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $6816  [21 FC C0]
    INC (HL)                                         ; $6819  [34]
    LD HL,$D9CB                                      ; $681A  [21 CB D9]
    INC (HL)                                         ; $681D  [34]
    RET                                              ; $681E  [C9]
Loc_681F:
    LD HL,$C0FD                                      ; $681F  [21 FD C0]
    INC (HL)                                         ; $6822  [34]
    LD A,$00                                         ; $6823  [3E 00]
    LD ($C89B),A                                     ; $6825  [EA 9B C8]
    LD A,$FF                                         ; $6828  [3E FF]
    LD ($C89C),A                                     ; $682A  [EA 9C C8]
    LD A,($C0FD)                                     ; $682D  [FA FD C0]  ; obj_state_hi
    CP $06                                           ; $6830  [FE 06]
    RET C                                            ; $6832  [D8]
    LD A,$C1                                         ; $6833  [3E C1]
    LD ($C89B),A                                     ; $6835  [EA 9B C8]
    LD A,$D2                                         ; $6838  [3E D2]
    LD ($C89C),A                                     ; $683A  [EA 9C C8]
    LD A,($C0FD)                                     ; $683D  [FA FD C0]  ; obj_state_hi
    CP $0C                                           ; $6840  [FE 0C]
    RET C                                            ; $6842  [D8]
    LD A,$00                                         ; $6843  [3E 00]
    LD ($C89B),A                                     ; $6845  [EA 9B C8]
    LD A,$FF                                         ; $6848  [3E FF]
    LD ($C89C),A                                     ; $684A  [EA 9C C8]
    LD A,($C0FD)                                     ; $684D  [FA FD C0]  ; obj_state_hi
    CP $12                                           ; $6850  [FE 12]
    RET C                                            ; $6852  [D8]
    LD A,$C1                                         ; $6853  [3E C1]
    LD ($C89B),A                                     ; $6855  [EA 9B C8]
    LD A,$D2                                         ; $6858  [3E D2]
    LD ($C89C),A                                     ; $685A  [EA 9C C8]
    LD A,($C0FD)                                     ; $685D  [FA FD C0]  ; obj_state_hi
    CP $18                                           ; $6860  [FE 18]
    RET C                                            ; $6862  [D8]
    LD A,$00                                         ; $6863  [3E 00]
    LD ($C89B),A                                     ; $6865  [EA 9B C8]
    LD A,$FF                                         ; $6868  [3E FF]
    LD ($C89C),A                                     ; $686A  [EA 9C C8]
    LD A,($C0FD)                                     ; $686D  [FA FD C0]  ; obj_state_hi
    CP $1E                                           ; $6870  [FE 1E]
    RET C                                            ; $6872  [D8]
    LD A,$C1                                         ; $6873  [3E C1]
    LD ($C89B),A                                     ; $6875  [EA 9B C8]
    LD A,$D2                                         ; $6878  [3E D2]
    LD ($C89C),A                                     ; $687A  [EA 9C C8]
    XOR A                                            ; $687D  [AF]
    LD ($C0FD),A                                     ; $687E  [EA FD C0]  ; obj_state_hi
    LD HL,$C0FC                                      ; $6881  [21 FC C0]
    INC (HL)                                         ; $6884  [34]
    RET                                              ; $6885  [C9]
Loc_6886:
    XOR A                                            ; $6886  [AF]
    LD ($C0FC),A                                     ; $6887  [EA FC C0]  ; obj_state_lo
    XOR A                                            ; $688A  [AF]
    LD ($C0D8),A                                     ; $688B  [EA D8 C0]  ; obj_phase
    LD A,$03                                         ; $688E  [3E 03]
    CALL $1A5B                                       ; $6890  [CD 5B 1A]  ; TileLoad_Setup
    LD HL,$C88F                                      ; $6893  [21 8F C8]
    INC (HL)                                         ; $6896  [34]
    XOR A                                            ; $6897  [AF]
    LD ($D9CB),A                                     ; $6898  [EA CB D9]  ; flag_D9CB
    LD A,$08                                         ; $689B  [3E 08]
    LD ($D951),A                                     ; $689D  [EA 51 D9]
    RET                                              ; $68A0  [C9]
Loc_68A1:
    LD A,$00                                         ; $68A1  [3E 00]
    LD (HL+),A                                       ; $68A3  [22]
    LD A,$80                                         ; $68A4  [3E 80]
    LD (HL+),A                                       ; $68A6  [22]
    LD A,$00                                         ; $68A7  [3E 00]
    LD (HL+),A                                       ; $68A9  [22]
    LD A,$00                                         ; $68AA  [3E 00]
    LD (HL+),A                                       ; $68AC  [22]
    LD A,$00                                         ; $68AD  [3E 00]
    LD (HL+),A                                       ; $68AF  [22]
    LD A,$02                                         ; $68B0  [3E 02]
    LD (HL+),A                                       ; $68B2  [22]
    LD A,$01                                         ; $68B3  [3E 01]
    LD (HL+),A                                       ; $68B5  [22]
    LD A,$50                                         ; $68B6  [3E 50]
    LD (HL+),A                                       ; $68B8  [22]
    LD A,$30                                         ; $68B9  [3E 30]
    LD (HL+),A                                       ; $68BB  [22]
    LD A,$00                                         ; $68BC  [3E 00]
    LD (HL+),A                                       ; $68BE  [22]
    LD A,$00                                         ; $68BF  [3E 00]
    LD (HL+),A                                       ; $68C1  [22]
    LD A,$02                                         ; $68C2  [3E 02]
    LD (HL+),A                                       ; $68C4  [22]
    RET                                              ; $68C5  [C9]
Loc_68C6:
    LD A,$00                                         ; $68C6  [3E 00]
    LD (HL+),A                                       ; $68C8  [22]
    LD A,$20                                         ; $68C9  [3E 20]
    LD (HL+),A                                       ; $68CB  [22]
    LD A,$00                                         ; $68CC  [3E 00]
    LD (HL+),A                                       ; $68CE  [22]
    LD A,$00                                         ; $68CF  [3E 00]
    LD (HL+),A                                       ; $68D1  [22]
    LD A,$00                                         ; $68D2  [3E 00]
    LD (HL+),A                                       ; $68D4  [22]
    LD A,$02                                         ; $68D5  [3E 02]
    LD (HL+),A                                       ; $68D7  [22]
    LD A,$01                                         ; $68D8  [3E 01]
    LD (HL+),A                                       ; $68DA  [22]
    LD A,$50                                         ; $68DB  [3E 50]
    LD (HL+),A                                       ; $68DD  [22]
    LD A,$30                                         ; $68DE  [3E 30]
    LD (HL+),A                                       ; $68E0  [22]
    LD A,$00                                         ; $68E1  [3E 00]
    LD (HL+),A                                       ; $68E3  [22]
    LD A,$00                                         ; $68E4  [3E 00]
    LD (HL+),A                                       ; $68E6  [22]
    LD A,$02                                         ; $68E7  [3E 02]
    LD (HL+),A                                       ; $68E9  [22]
    RET                                              ; $68EA  [C9]
Loc_68EB:
    LD A,$01                                         ; $68EB  [3E 01]
    LD (HL+),A                                       ; $68ED  [22]
    LD A,$70                                         ; $68EE  [3E 70]
    LD (HL+),A                                       ; $68F0  [22]
    LD A,$10                                         ; $68F1  [3E 10]
    LD (HL+),A                                       ; $68F3  [22]
    LD A,$00                                         ; $68F4  [3E 00]
    LD (HL+),A                                       ; $68F6  [22]
    LD A,$00                                         ; $68F7  [3E 00]
    LD (HL+),A                                       ; $68F9  [22]
    LD A,$02                                         ; $68FA  [3E 02]
    LD (HL+),A                                       ; $68FC  [22]
    RET                                              ; $68FD  [C9]
Loc_6911:
    LD A,$01                                         ; $6911  [3E 01]
    LD (HL+),A                                       ; $6913  [22]
    LD A,$30                                         ; $6914  [3E 30]
    LD (HL+),A                                       ; $6916  [22]
    LD A,$50                                         ; $6917  [3E 50]
    LD (HL+),A                                       ; $6919  [22]
    LD A,$00                                         ; $691A  [3E 00]
    LD (HL+),A                                       ; $691C  [22]
    LD A,$00                                         ; $691D  [3E 00]
    LD (HL+),A                                       ; $691F  [22]
    LD A,$02                                         ; $6920  [3E 02]
    LD (HL+),A                                       ; $6922  [22]
    RET                                              ; $6923  [C9]
Loc_6924:
    LD A,$01                                         ; $6924  [3E 01]
    LD (HL+),A                                       ; $6926  [22]
    LD A,$70                                         ; $6927  [3E 70]
    LD (HL+),A                                       ; $6929  [22]
    LD A,$50                                         ; $692A  [3E 50]
    LD (HL+),A                                       ; $692C  [22]
    LD A,$00                                         ; $692D  [3E 00]
    LD (HL+),A                                       ; $692F  [22]
    LD A,$00                                         ; $6930  [3E 00]
    LD (HL+),A                                       ; $6932  [22]
    LD A,$02                                         ; $6933  [3E 02]
    LD (HL+),A                                       ; $6935  [22]
    RET                                              ; $6936  [C9]
Loc_6937:
    LD A,$00                                         ; $6937  [3E 00]
    LD (HL+),A                                       ; $6939  [22]
    LD A,$40                                         ; $693A  [3E 40]
    LD (HL+),A                                       ; $693C  [22]
    LD A,$00                                         ; $693D  [3E 00]
    LD (HL+),A                                       ; $693F  [22]
    LD A,$00                                         ; $6940  [3E 00]
    LD (HL+),A                                       ; $6942  [22]
    LD A,$00                                         ; $6943  [3E 00]
    LD (HL+),A                                       ; $6945  [22]
    LD A,$02                                         ; $6946  [3E 02]
    LD (HL+),A                                       ; $6948  [22]
    LD A,$01                                         ; $6949  [3E 01]
    LD (HL+),A                                       ; $694B  [22]
    LD A,$20                                         ; $694C  [3E 20]
    LD (HL+),A                                       ; $694E  [22]
    LD A,$20                                         ; $694F  [3E 20]
    LD (HL+),A                                       ; $6951  [22]
    LD A,$00                                         ; $6952  [3E 00]
    LD (HL+),A                                       ; $6954  [22]
    LD A,$00                                         ; $6955  [3E 00]
    LD (HL+),A                                       ; $6957  [22]
    LD A,$02                                         ; $6958  [3E 02]
    LD (HL+),A                                       ; $695A  [22]
    RET                                              ; $695B  [C9]
Loc_695C:
    LD A,$00                                         ; $695C  [3E 00]
    LD (HL+),A                                       ; $695E  [22]
    LD A,$60                                         ; $695F  [3E 60]
    LD (HL+),A                                       ; $6961  [22]
    LD A,$00                                         ; $6962  [3E 00]
    LD (HL+),A                                       ; $6964  [22]
    LD A,$00                                         ; $6965  [3E 00]
    LD (HL+),A                                       ; $6967  [22]
    LD A,$00                                         ; $6968  [3E 00]
    LD (HL+),A                                       ; $696A  [22]
    LD A,$02                                         ; $696B  [3E 02]
    LD (HL+),A                                       ; $696D  [22]
    LD A,$01                                         ; $696E  [3E 01]
    LD (HL+),A                                       ; $6970  [22]
    LD A,$80                                         ; $6971  [3E 80]
    LD (HL+),A                                       ; $6973  [22]
    LD A,$20                                         ; $6974  [3E 20]
    LD (HL+),A                                       ; $6976  [22]
    LD A,$00                                         ; $6977  [3E 00]
    LD (HL+),A                                       ; $6979  [22]
    LD A,$00                                         ; $697A  [3E 00]
    LD (HL+),A                                       ; $697C  [22]
    LD A,$02                                         ; $697D  [3E 02]
    LD (HL+),A                                       ; $697F  [22]
    RET                                              ; $6980  [C9]
Loc_6981:
    LD A,$00                                         ; $6981  [3E 00]
    LD (HL+),A                                       ; $6983  [22]
    LD A,$A0                                         ; $6984  [3E A0]
    LD (HL+),A                                       ; $6986  [22]
    LD A,$30                                         ; $6987  [3E 30]
    LD (HL+),A                                       ; $6989  [22]
    LD A,$00                                         ; $698A  [3E 00]
    LD (HL+),A                                       ; $698C  [22]
    LD A,$00                                         ; $698D  [3E 00]
    LD (HL+),A                                       ; $698F  [22]
    LD A,$02                                         ; $6990  [3E 02]
    LD (HL+),A                                       ; $6992  [22]
    LD A,$01                                         ; $6993  [3E 01]
    LD (HL+),A                                       ; $6995  [22]
    LD A,$80                                         ; $6996  [3E 80]
    LD (HL+),A                                       ; $6998  [22]
    LD A,$50                                         ; $6999  [3E 50]
    LD (HL+),A                                       ; $699B  [22]
    LD A,$00                                         ; $699C  [3E 00]
    LD (HL+),A                                       ; $699E  [22]
    LD A,$00                                         ; $699F  [3E 00]
    LD (HL+),A                                       ; $69A1  [22]
    LD A,$02                                         ; $69A2  [3E 02]
    LD (HL+),A                                       ; $69A4  [22]
    RET                                              ; $69A5  [C9]
Loc_69A6:
    LD A,$01                                         ; $69A6  [3E 01]
    LD (HL+),A                                       ; $69A8  [22]
    LD A,$08                                         ; $69A9  [3E 08]
    LD (HL+),A                                       ; $69AB  [22]
    LD A,$90                                         ; $69AC  [3E 90]
    LD (HL+),A                                       ; $69AE  [22]
    LD A,$01                                         ; $69AF  [3E 01]
    LD (HL+),A                                       ; $69B1  [22]
    LD A,$00                                         ; $69B2  [3E 00]
    LD (HL+),A                                       ; $69B4  [22]
    LD A,$02                                         ; $69B5  [3E 02]
    LD (HL+),A                                       ; $69B7  [22]
    LD A,$00                                         ; $69B8  [3E 00]
    LD (HL+),A                                       ; $69BA  [22]
    LD A,$18                                         ; $69BB  [3E 18]
    LD (HL+),A                                       ; $69BD  [22]
    LD A,$90                                         ; $69BE  [3E 90]
    LD (HL+),A                                       ; $69C0  [22]
    LD A,$01                                         ; $69C1  [3E 01]
    LD (HL+),A                                       ; $69C3  [22]
    LD A,$00                                         ; $69C4  [3E 00]
    LD (HL+),A                                       ; $69C6  [22]
    LD A,$02                                         ; $69C7  [3E 02]
    LD (HL+),A                                       ; $69C9  [22]
    LD A,$01                                         ; $69CA  [3E 01]
    LD (HL+),A                                       ; $69CC  [22]
    LD A,$28                                         ; $69CD  [3E 28]
    LD (HL+),A                                       ; $69CF  [22]
    LD A,$90                                         ; $69D0  [3E 90]
    LD (HL+),A                                       ; $69D2  [22]
    LD A,$01                                         ; $69D3  [3E 01]
    LD (HL+),A                                       ; $69D5  [22]
    LD A,$00                                         ; $69D6  [3E 00]
    LD (HL+),A                                       ; $69D8  [22]
    LD A,$02                                         ; $69D9  [3E 02]
    LD (HL+),A                                       ; $69DB  [22]
    LD A,$01                                         ; $69DC  [3E 01]
    LD (HL+),A                                       ; $69DE  [22]
    LD A,$78                                         ; $69DF  [3E 78]
    LD (HL+),A                                       ; $69E1  [22]
    LD A,$90                                         ; $69E2  [3E 90]
    LD (HL+),A                                       ; $69E4  [22]
    LD A,$01                                         ; $69E5  [3E 01]
    LD (HL+),A                                       ; $69E7  [22]
    LD A,$00                                         ; $69E8  [3E 00]
    LD (HL+),A                                       ; $69EA  [22]
    LD A,$02                                         ; $69EB  [3E 02]
    LD (HL+),A                                       ; $69ED  [22]
    LD A,$01                                         ; $69EE  [3E 01]
    LD (HL+),A                                       ; $69F0  [22]
    LD A,$88                                         ; $69F1  [3E 88]
    LD (HL+),A                                       ; $69F3  [22]
    LD A,$90                                         ; $69F4  [3E 90]
    LD (HL+),A                                       ; $69F6  [22]
    LD A,$01                                         ; $69F7  [3E 01]
    LD (HL+),A                                       ; $69F9  [22]
    LD A,$00                                         ; $69FA  [3E 00]
    LD (HL+),A                                       ; $69FC  [22]
    LD A,$02                                         ; $69FD  [3E 02]
    LD (HL+),A                                       ; $69FF  [22]
    LD A,$01                                         ; $6A00  [3E 01]
    LD (HL+),A                                       ; $6A02  [22]
    LD A,$98                                         ; $6A03  [3E 98]
    LD (HL+),A                                       ; $6A05  [22]
    LD A,$90                                         ; $6A06  [3E 90]
    LD (HL+),A                                       ; $6A08  [22]
    LD A,$01                                         ; $6A09  [3E 01]
    LD (HL+),A                                       ; $6A0B  [22]
    LD A,$00                                         ; $6A0C  [3E 00]
    LD (HL+),A                                       ; $6A0E  [22]
    LD A,$02                                         ; $6A0F  [3E 02]
    LD (HL+),A                                       ; $6A11  [22]
    RET                                              ; $6A12  [C9]
Loc_6A13:
    LD A,$00                                         ; $6A13  [3E 00]
    LD ($C0D8),A                                     ; $6A15  [EA D8 C0]  ; obj_phase
    RET                                              ; $6A18  [C9]
Loc_6A19:
    LD A,$00                                         ; $6A19  [3E 00]
    LD ($C0DE),A                                     ; $6A1B  [EA DE C0]  ; obj_unk_DE
    RET                                              ; $6A1E  [C9]
Loc_6A1F:
    LD A,$00                                         ; $6A1F  [3E 00]
    LD ($C0E4),A                                     ; $6A21  [EA E4 C0]  ; obj_timer
    RET                                              ; $6A24  [C9]
Loc_6A25:
    LD A,$00                                         ; $6A25  [3E 00]
    LD ($C0EA),A                                     ; $6A27  [EA EA C0]  ; obj_unk_EA
    RET                                              ; $6A2A  [C9]
Loc_6A2B:
    LD A,$00                                         ; $6A2B  [3E 00]
    LD ($C0F0),A                                     ; $6A2D  [EA F0 C0]  ; obj_unk_F0
    RET                                              ; $6A30  [C9]
Loc_6A31:
    LD A,$00                                         ; $6A31  [3E 00]
    LD ($C0F6),A                                     ; $6A33  [EA F6 C0]  ; obj_unk_F6
    RET                                              ; $6A36  [C9]
Loc_6A37:
    LD A,$01                                         ; $6A37  [3E 01]
    LD ($C0D8),A                                     ; $6A39  [EA D8 C0]  ; obj_phase
    RET                                              ; $6A3C  [C9]
Loc_6A3D:
    LD A,$01                                         ; $6A3D  [3E 01]
    LD ($C0DE),A                                     ; $6A3F  [EA DE C0]  ; obj_unk_DE
    RET                                              ; $6A42  [C9]
Loc_6A43:
    LD A,$01                                         ; $6A43  [3E 01]
    LD ($C0E4),A                                     ; $6A45  [EA E4 C0]  ; obj_timer
    RET                                              ; $6A48  [C9]
Loc_6A49:
    LD A,$01                                         ; $6A49  [3E 01]
    LD ($C0EA),A                                     ; $6A4B  [EA EA C0]  ; obj_unk_EA
    RET                                              ; $6A4E  [C9]
Loc_6A4F:
    LD A,$01                                         ; $6A4F  [3E 01]
    LD ($C0F0),A                                     ; $6A51  [EA F0 C0]  ; obj_unk_F0
    RET                                              ; $6A54  [C9]
Loc_6A55:
    LD A,$01                                         ; $6A55  [3E 01]
    LD ($C0F6),A                                     ; $6A57  [EA F6 C0]  ; obj_unk_F6
    RET                                              ; $6A5A  [C9]
Loc_6A5B:
    LD A,D                                           ; $6A5B  [7A]
    LD (HL+),A                                       ; $6A5C  [22]
    LD A,E                                           ; $6A5D  [7B]
    LD (HL+),A                                       ; $6A5E  [22]
    DEC BC                                           ; $6A5F  [0B]
    LD A,B                                           ; $6A60  [78]
    OR C                                             ; $6A61  [B1]
    JR NZ,$6A5B                                      ; $6A62  [20 F7]
    RET                                              ; $6A64  [C9]
Loc_6A65:
    LD DE,$6A6C                                      ; $6A65  [11 6C 6A]
    CALL $1164                                       ; $6A68  [CD 64 11]  ; AudioFreqCalc
    RET                                              ; $6A6B  [C9]

; ──────────────────────────────────────────────────────────────────
; Bank2_Fn4  ($6A78)
; ──────────────────────────────────────────────────────────────────
; Per-sprite animation tick — called every frame for one active sprite.
; Reads sprite descriptor ptr from obj_state_lo/$C0FC + obj_state_hi/$C0FD.
; Sprite descriptor block (6 bytes at ptr):
;   [0] status: 0=active (continue), 1=completed (RET immediately)
;   [1] channel / X   → written to spr_x ($FFC3)
;   [2] Y param       → written to spr_y ($FFC5)
;   [3] note value    → written to spr_note ($FFC8); updated each step
;   [4] sequence position index (advanced each tick)
;   [5] duration countdown (decremented each tick; on 0 → advance [4])
; Clears spr_x_hi/$FFC4, spr_y_hi/$FFC6, spr_unk_D3/$FFD3 each tick.
; After writing params: calls $6A65→AudioFreqCalc with DE=$6A6C (freq table).
; Note sequence: table at $4E17 indexed by spr_tile/$FFC7 → ptr to sequence.
;   Each sequence entry is 2 bytes: (note_val, duration).
;   $FF at note_val → sequence end: set ptr[0]=1 (completed).
;   $FE at note_val → loop: reset position to entry 0.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn4:
    LD A,($C0FC)                                     ; $6A78  [FA FC C0]  ; obj_state_lo
    LD L,A                                           ; $6A7B  [6F]
    LD A,($C0FD)                                     ; $6A7C  [FA FD C0]  ; obj_state_hi
    LD H,A                                           ; $6A7F  [67]
    LD A,L                                           ; $6A80  [7D]
    LD ($C0FE),A                                     ; $6A81  [EA FE C0]  ; obj_ptr_lo
    LD A,H                                           ; $6A84  [7C]
    LD ($C0FF),A                                     ; $6A85  [EA FF C0]  ; obj_ptr_hi
    LD A,(HL+)                                       ; $6A88  [2A]
    OR A                                             ; $6A89  [B7]
    RET NZ                                           ; $6A8A  [C0]
    XOR A                                            ; $6A8B  [AF]
    LDH ($FFC4),A                                    ; $6A8C  [E0 C4]  ; spr_x_hi
    LDH ($FFC6),A                                    ; $6A8E  [E0 C6]  ; spr_y_hi
    LDH ($FFD3),A                                    ; $6A90  [E0 D3]  ; spr_unk_D3
    LD A,(HL+)                                       ; $6A92  [2A]
    LDH ($FFC3),A                                    ; $6A93  [E0 C3]  ; spr_x
    LD A,(HL+)                                       ; $6A95  [2A]
    LDH ($FFC5),A                                    ; $6A96  [E0 C5]  ; spr_y
    LD A,(HL+)                                       ; $6A98  [2A]
    LDH ($FFC8),A                                    ; $6A99  [E0 C8]  ; spr_note
    CALL $6A65                                       ; $6A9B  [CD 65 6A]
    LD A,($C0FE)                                     ; $6A9E  [FA FE C0]  ; obj_ptr_lo
    LD L,A                                           ; $6AA1  [6F]
    LD A,($C0FF)                                     ; $6AA2  [FA FF C0]  ; obj_ptr_hi
    LD H,A                                           ; $6AA5  [67]
    LD A,$05                                         ; $6AA6  [3E 05]
    ADD A,L                                          ; $6AA8  [85]
    LD L,A                                           ; $6AA9  [6F]
    LD A,$00                                         ; $6AAA  [3E 00]
    ADC A,H                                          ; $6AAC  [8C]
    LD H,A                                           ; $6AAD  [67]
    LD E,L                                           ; $6AAE  [5D]
    LD D,H                                           ; $6AAF  [54]
    LD A,(DE)                                        ; $6AB0  [1A]
    DEC A                                            ; $6AB1  [3D]
    LD (DE),A                                        ; $6AB2  [12]
    OR A                                             ; $6AB3  [B7]
    RET NZ                                           ; $6AB4  [C0]
    DEC DE                                           ; $6AB5  [1B]
    LD A,(DE)                                        ; $6AB6  [1A]
    INC A                                            ; $6AB7  [3C]
    LD (DE),A                                        ; $6AB8  [12]
    LD HL,$4E17                                      ; $6AB9  [21 17 4E]
    LDH A,($FFC7)                                    ; $6ABC  [F0 C7]  ; spr_tile
    CALL $6AFF                                       ; $6ABE  [CD FF 6A]
    LD A,(DE)                                        ; $6AC1  [1A]
    DEC DE                                           ; $6AC2  [1B]
    ADD A,A                                          ; $6AC3  [87]
    ADD A,L                                          ; $6AC4  [85]
    LD L,A                                           ; $6AC5  [6F]
    LD A,$00                                         ; $6AC6  [3E 00]
    ADC A,H                                          ; $6AC8  [8C]
    LD H,A                                           ; $6AC9  [67]
    LD A,(HL)                                        ; $6ACA  [7E]
    CP $FF                                           ; $6ACB  [FE FF]
    JR Z,$6ADA                                       ; $6ACD  [28 0B]
    CP $FE                                           ; $6ACF  [FE FE]
    JR Z,$6AE6                                       ; $6AD1  [28 13]
    LD A,(HL+)                                       ; $6AD3  [2A]
    LD (DE),A                                        ; $6AD4  [12]
    INC DE                                           ; $6AD5  [13]
    INC DE                                           ; $6AD6  [13]
    LD A,(HL)                                        ; $6AD7  [7E]
    LD (DE),A                                        ; $6AD8  [12]
    RET                                              ; $6AD9  [C9]
Loc_6ADA:
    LD A,($C0FE)                                     ; $6ADA  [FA FE C0]  ; obj_ptr_lo
    LD L,A                                           ; $6ADD  [6F]
    LD A,($C0FF)                                     ; $6ADE  [FA FF C0]  ; obj_ptr_hi
    LD H,A                                           ; $6AE1  [67]
    LD A,$01                                         ; $6AE2  [3E 01]
    LD (HL),A                                        ; $6AE4  [77]
    RET                                              ; $6AE5  [C9]
Loc_6AE6:
    LD HL,$4E17                                      ; $6AE6  [21 17 4E]
    LDH A,($FFC7)                                    ; $6AE9  [F0 C7]  ; spr_tile
    CALL $6AFF                                       ; $6AEB  [CD FF 6A]
    XOR A                                            ; $6AEE  [AF]
    ADD A,A                                          ; $6AEF  [87]
    ADD A,L                                          ; $6AF0  [85]
    LD L,A                                           ; $6AF1  [6F]
    LD A,$00                                         ; $6AF2  [3E 00]
    ADC A,H                                          ; $6AF4  [8C]
    LD H,A                                           ; $6AF5  [67]
    LD A,(HL+)                                       ; $6AF6  [2A]
    LD (DE),A                                        ; $6AF7  [12]
    INC DE                                           ; $6AF8  [13]
    XOR A                                            ; $6AF9  [AF]
    LD (DE),A                                        ; $6AFA  [12]
    INC DE                                           ; $6AFB  [13]
    LD A,(HL)                                        ; $6AFC  [7E]
    LD (DE),A                                        ; $6AFD  [12]
    RET                                              ; $6AFE  [C9]
Loc_6AFF:
    ADD A,A                                          ; $6AFF  [87]
    ADD A,L                                          ; $6B00  [85]
    LD L,A                                           ; $6B01  [6F]
    LD A,$00                                         ; $6B02  [3E 00]
    ADC A,H                                          ; $6B04  [8C]
    LD H,A                                           ; $6B05  [67]
    LD A,(HL+)                                       ; $6B06  [2A]
    LD H,(HL)                                        ; $6B07  [66]
    LD L,A                                           ; $6B08  [6F]
    RET                                              ; $6B09  [C9]

; ──────────────────────────────────────────────────────────────────
; Bank2_Fn5  ($6B0A)
; ──────────────────────────────────────────────────────────────────
; Single note lookup — reads event ptr from $D7B4/$D7B5.
; Does 3-level table walk at $40E3 using ptr[0], ptr[1], ptr[2] as indices.
; Writes result lo-byte to spr_note ($FFC8).
; Used to initialize or update one audio/sprite parameter without a full tick.
; ──────────────────────────────────────────────────────────────────
Bank2_Fn5:
    LD A,($D7B4)                                     ; $6B0A  [FA B4 D7]  ; evt_ptr_lo
    LD C,A                                           ; $6B0D  [4F]
    LD A,($D7B5)                                     ; $6B0E  [FA B5 D7]  ; evt_ptr_hi
    LD B,A                                           ; $6B11  [47]
    LD HL,$40E3                                      ; $6B12  [21 E3 40]
    LD A,(BC)                                        ; $6B15  [0A]
    ADD A,A                                          ; $6B16  [87]
    ADD A,L                                          ; $6B17  [85]
    LD L,A                                           ; $6B18  [6F]
    LD A,$00                                         ; $6B19  [3E 00]
    ADC A,H                                          ; $6B1B  [8C]
    LD H,A                                           ; $6B1C  [67]
    LD A,(HL+)                                       ; $6B1D  [2A]
    LD H,(HL)                                        ; $6B1E  [66]
    LD L,A                                           ; $6B1F  [6F]
    INC BC                                           ; $6B20  [03]
    LD A,(BC)                                        ; $6B21  [0A]
    ADD A,A                                          ; $6B22  [87]
    ADD A,L                                          ; $6B23  [85]
    LD L,A                                           ; $6B24  [6F]
    LD A,$00                                         ; $6B25  [3E 00]
    ADC A,H                                          ; $6B27  [8C]
    LD H,A                                           ; $6B28  [67]
    LD A,(HL+)                                       ; $6B29  [2A]
    LD H,(HL)                                        ; $6B2A  [66]
    LD L,A                                           ; $6B2B  [6F]
    INC BC                                           ; $6B2C  [03]
    LD A,(BC)                                        ; $6B2D  [0A]
    ADD A,A                                          ; $6B2E  [87]
    ADD A,L                                          ; $6B2F  [85]
    LD L,A                                           ; $6B30  [6F]
    LD A,$00                                         ; $6B31  [3E 00]
    ADC A,H                                          ; $6B33  [8C]
    LD H,A                                           ; $6B34  [67]
    LD A,(HL)                                        ; $6B35  [7E]
    LDH ($FFC8),A                                    ; $6B36  [E0 C8]  ; spr_note
    RET                                              ; $6B38  [C9]
