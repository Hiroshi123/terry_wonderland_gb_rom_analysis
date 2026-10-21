; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 25  (Overworld mini-map / SELECT mode)
; ============================================================================
;
; Called from: bank6/fn6 at $6060 via LD HL,$1900; RST $10
;   Condition: wStateFlags bit3 set (SELECT pressed; area $50-$5C only)
;
; Bank 25 memory map:
;   File offset $64000-$67FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 25
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; Function table at $64001 (bank 25 $4001):
;   fn0: $4003 ← SELECT mode (mini-map display / area navigation)
;
; Purpose:
;   Handles the SELECT button overworld mini-map mode.  Only reachable
;   for areas $50–$5C (the main overworld zones); other areas are filtered
;   by bank6/fn6 before the banked call.
;
;   fn0 reads wScrollPhase ($C905) and dispatches via RST $00 to one of 5
;   phases (0 init, 1 paint-grid, 2 markers, 3 navigate, 4 exit).
;   Phase 1 paints a 4x4 grid of 16 zone cells: for each cell it reads a
;   screen position from MiniMapCellPos ($4054) and a per-cell state, then
;   calls draw-cell ($4492).
;
;   Cell state: main area ($C969==0) uses $F0; in a sub-area it reads the
;   per-cell arrays $C950 (wSubAreaScrollIdxArr) and $C940 to mark which
;   zones are visited/accessible.
;
;   Scroll position saved/restored by bank6/Sub_62A0 (8-byte swap between
;   $C905-$C90C and $C876-$C87D) before and after this bank is active.
;
; Key WRAM variables:
;   $C905  wScrollPhase   — mini-map animation / navigation phase
;   $C950               — sub-area scroll index array
;   $C968  wAreaID        — current area (must be $50-$5C to enter)
;   $C969  wSubAreaFlag   — selects main or sub-area scroll data

SECTION "Bank 25 Functions", ROMX[$4000], BANK[25]



; ------------------------------------------------------------
; Bank25_Fn0  ($4003)  — SELECT-button overworld MINI-MAP (4x4 zone grid).
; Reached from bank6 fn6 when $C8EB bit3 is set (SELECT on a warp area $50-$5C).
; Shows the current world/dungeon as a 4x4 grid of zone cells and lets you
; navigate between them. Scroll state saved/restored around it by bank6 Sub_62A0.
; ------------------------------------------------------------
Bank25_Fn0:                         ; $4003
    LD A,($C905)               ; $4003 [FA 05 C9]  ; wScrollPhase (mini-map state 0-4)
    RST $00                    ; $4006 [C7]  ; dispatch via phase table below
    ; phase dispatch table (5 entries, indexed by wScrollPhase $C905):
    ;   0 init · 1 paint-grid · 2 markers+WAIT · 3 teardown · 4 exit
    dw $4364,$4011,$4074,$4249,$4443   ; $4007 [64 43 11 40 74 40 49 42 43 44]
    ;   phase0 $4364 init · phase1 $4011 paint grid · phase2 $4074 markers+input-wait
    ;   · phase3 $4249 teardown (clear BG, restore scroll) · phase4 $4443 exit
Bank25_Fn0_Phase1:  ; $4011  (paint 4x4 zone grid)
    LD B,$10                   ; $4011 [06 10]  ; phase 1: paint the 4x4 zone grid. B=16 cells
    LD C,$00                   ; $4013 [0E 00]  ; C = cell index 0-15
.cellLoop:
    PUSH BC                    ; $4015 [C5]  ; --- per-cell loop ---
    LD HL,$4054                ; $4016 [21 54 40]  ; HL = &MiniMapCellPos[C]
    LD A,C                     ; $4019 [79]
    ADD A,A                    ; $401A [87]
    ADD A,L                    ; $401B [85]
    LD L,A                     ; $401C [6F]
    LD A,$00                   ; $401D [3E 00]
    ADC A,H                    ; $401F [8C]
    LD H,A                     ; $4020 [67]
    LD A,(HL+)                 ; $4021 [2A]  ; HL = cell screen-pos word (LE)
    LD H,(HL)                  ; $4022 [66]
    LD L,A                     ; $4023 [6F]
    LD A,($C969)               ; $4024 [FA 69 C9]  ; wSubAreaFlag
    OR A                       ; $4027 [B7]
    LD A,$F0                   ; $4028 [3E F0]  ; default cell state = $F0 (main-area)
    JR Z,$4047                 ; $402A [28 1B]  ; main area -> draw with $F0
    LD DE,$C950                ; $402C [11 50 C9]  ; DE = &wSubAreaScrollIdxArr[C] ($C950)
    LD A,C                     ; $402F [79]
    ADD A,E                    ; $4030 [83]
    LD E,A                     ; $4031 [5F]
    LD A,$00                   ; $4032 [3E 00]
    ADC A,D                    ; $4034 [8A]
    LD D,A                     ; $4035 [57]
    LD A,(DE)                  ; $4036 [1A]  ; idx==0 -> still $F0
    OR A                       ; $4037 [B7]
    LD A,$F0                   ; $4038 [3E F0]
    JR Z,$4047                 ; $403A [28 0B]
    LD DE,$C940                ; $403C [11 40 C9]  ; DE = &$C940[C] (per-cell visited/state)
    LD A,C                     ; $403F [79]
    ADD A,E                    ; $4040 [83]
    LD E,A                     ; $4041 [5F]
    LD A,$00                   ; $4042 [3E 00]
    ADC A,D                    ; $4044 [8A]
    LD D,A                     ; $4045 [57]
    LD A,(DE)                  ; $4046 [1A]  ; A = cell state byte
    CALL $4492                 ; $4047 [CD 92 44]  ; draw this cell (HL=pos, A=state, C=index)
    POP BC                     ; $404A [C1]
    INC C                      ; $404B [0C]  ; next cell
    DEC B                      ; $404C [05]
    JR NZ,$4015                ; $404D [20 C6]
    LD HL,$C905                ; $404F [21 05 C9]  ; all 16 drawn -> advance to phase 2
    INC (HL)                   ; $4052 [34]  ; wScrollPhase++
    RET                        ; $4053 [C9]
; ----------------------------------------------------------------------------
; MiniMapCellPos ($4054) — 16 screen-position words for the 4x4 zone grid,
;   indexed by cell 0-15. High nibble of a byte = row, low nibble = column;
;   $4492 turns one into a VRAM address. DATA. ($4064+ is a parallel variant.)
; ----------------------------------------------------------------------------
Bank25_MiniMapCellPos:
    dw $0000,$0005,$000A,$000F,$0080,$0085,$008A,$008F   ; $4054 [00 00 05 00 0A 00 0F 00 80 00 85 00 8A 00 8F 00]
    dw $0100,$0105,$010A,$010F,$0180,$0185,$018A,$018F   ; $4064 [00 01 05 01 0A 01 0F 01 80 01 85 01 8A 01 8F 01]

; ----------------------------------------------------------------------------
; STRUCTURE OF fn0 (phases run in sequence as wScrollPhase $C905 counts up):
;   phase 0  $4364  INIT    — zero scroll, load tileset, clear BG, cursor from camera.
;   phase 1  $4011  PAINT   — draw the 4x4 zone grid: 16 cells from MiniMapCellPos
;                             ($4054), each via draw-cell $4492.
;   phase 2  $4074  DISPLAY — draw player/zone markers + coordinate digits, then WAIT
;                             on the joypad ($4213, any button but Start) to dismiss.
;   phase 3  $4249  TEARDOWN— clear the BG ($4426) and restore the saved field scroll.
;   phase 4  $4443  EXIT    — repaint field attrs (bank11 fn2), RES $C8EB bit3, done.
; KEY HELPERS:
;   $4492 draw one cell (STATE picks the graphic via CellGfxPtr $4500/$4520; pos word
;         picks WHERE) · $447B run · $44CB row · $44F5 tile · $4458/$4467 VRAM ptr math
;   $4426 clear BG · $4269 marker-distance · $4221 goal-marker sprite.
; STATUS: bank25 is now COMPLETE and byte-exact end to end ($4003-$5BE7): fn0
;   code+tables ($4003-$453F) plus the mini-map tilemap data ($4540-$5BE7, the
;   cell-graphic layouts pointed at by CellGfxPtr, emitted as labeled db blocks).
; ----------------------------------------------------------------------------



; ============================================================================
; Bank25 fn0 PHASE 0 ($4364) — INIT the mini-map.
;   Resets scroll, loads the mini-map tileset (bank$28/$2E) into VRAM, then
;   converts the player camera position into the on-map cursor, and steps to
;   phase 1. (Only fn0 phase 0 + the cell-draw helpers are disassembled here;
;   phases 2 $4074 / 3 $4249 / 4 $4443 and the $4500/$4520 tables are still TBD.)
; ============================================================================
SECTION "Bank25_Phase0", ROMX[$4364], BANK[25]
Bank25_Fn0_Phase0:
    XOR A                      ; $4364 [AF]  ; --- phase 0: INIT the mini-map ---
    LDH ($B7),A                ; $4365 [E0 B7]  ; hScrollX = 0
    LDH ($B8),A                ; $4367 [E0 B8]
    XOR A                      ; $4369 [AF]
    LDH ($BB),A                ; $436A [E0 BB]  ; hScrollY = 0
    LDH ($BC),A                ; $436C [E0 BC]
    LD HL,$FFB7                ; $436E [21 B7 FF]
    CALL $4357                 ; $4371 [CD 57 43]  ; scroll-setup helper (X)
    LD HL,$FFBB                ; $4374 [21 BB FF]
    CALL $4357                 ; $4377 [CD 57 43]  ; scroll-setup helper (Y)
    LD HL,$C8DA                ; $437A [21 DA C8]  ; clear $C8DA..$C8E1 (8 bytes)
    LD BC,$0008                ; $437D [01 08 00]
    LD A,$00                   ; $4380 [3E 00]
    CALL $169A                 ; $4382 [CD 9A 16]
    LDH A,($BB)                ; $4385 [F0 BB]  ; --- BG map row addr ($9800) from scroll -> $C909/$C90A ---
    LD L,A                     ; $4387 [6F]
    LD H,$00                   ; $4388 [26 00]
    ADD HL,HL                  ; $438A [29]
    ADD HL,HL                  ; $438B [29]
    LDH A,($B7)                ; $438C [F0 B7]
    RRCA                       ; $438E [0F]
    RRCA                       ; $438F [0F]
    RRCA                       ; $4390 [0F]
    ADD A,L                    ; $4391 [85]
    LD L,A                     ; $4392 [6F]
    LD A,H                     ; $4393 [7C]
    ADC A,$98                  ; $4394 [CE 98]
    LD H,A                     ; $4396 [67]
    LD A,H                     ; $4397 [7C]
    AND $03                    ; $4398 [E6 03]
    OR $98                     ; $439A [F6 98]
    LD H,A                     ; $439C [67]
    LD A,L                     ; $439D [7D]
    LD ($C909),A               ; $439E [EA 09 C9]
    LD A,H                     ; $43A1 [7C]
    LD ($C90A),A               ; $43A2 [EA 0A C9]
    LD DE,$281C                ; $43A5 [11 1C 28]  ; load mini-map tileset (SafeTileLoad D=bank,E=blk,HL=VRAM):
    LD HL,$8800                ; $43A8 [21 00 88]  ; bank$28 blk$1C -> $8800
    CALL $194A                 ; $43AB [CD 4A 19]
    LD DE,$281F                ; $43AE [11 1F 28]
    LD HL,$8900                ; $43B1 [21 00 89]  ; bank$28 blk$1F -> $8900
    CALL $194A                 ; $43B4 [CD 4A 19]
    LD DE,$281D                ; $43B7 [11 1D 28]
    LD HL,$8A90                ; $43BA [21 90 8A]  ; bank$28 blk$1D -> $8A90
    CALL $194A                 ; $43BD [CD 4A 19]
    LD DE,$281E                ; $43C0 [11 1E 28]
    LD HL,$8AC0                ; $43C3 [21 C0 8A]  ; bank$28 blk$1E -> $8AC0
    CALL $194A                 ; $43C6 [CD 4A 19]
    LD DE,$2E23                ; $43C9 [11 23 2E]
    LD HL,$8B00                ; $43CC [21 00 8B]  ; bank$2E blk$23 -> $8B00
    CALL $194A                 ; $43CF [CD 4A 19]
    LDH A,($92)                ; $43D2 [F0 92]  ; --- compute cursor from camera X (hFF92/93): (camX-8)/4 - $50 ---
    LD L,A                     ; $43D4 [6F]
    LDH A,($93)                ; $43D5 [F0 93]
    LD H,A                     ; $43D7 [67]
    LD A,L                     ; $43D8 [7D]
    SUB $08                    ; $43D9 [D6 08]
    LD L,A                     ; $43DB [6F]
    LD A,H                     ; $43DC [7C]
    SBC A,$00                  ; $43DD [DE 00]
    LD H,A                     ; $43DF [67]
    SRL H                      ; $43E0 [CB 3C]
    RR L                       ; $43E2 [CB 1D]
    SRL H                      ; $43E4 [CB 3C]
    RR L                       ; $43E6 [CB 1D]
    LD A,L                     ; $43E8 [7D]
    SUB $50                    ; $43E9 [D6 50]
    LD L,A                     ; $43EB [6F]
    LD A,H                     ; $43EC [7C]
    SBC A,$00                  ; $43ED [DE 00]
    LD H,A                     ; $43EF [67]
    LD A,L                     ; $43F0 [7D]
    LDH ($B7),A                ; $43F1 [E0 B7]  ; -> hScrollX (cursor X)
    LD A,H                     ; $43F3 [7C]
    LDH ($B8),A                ; $43F4 [E0 B8]
    LDH A,($95)                ; $43F6 [F0 95]  ; --- cursor from camera Y (hFF95/96): (camY-9)/4 - $40 ---
    LD L,A                     ; $43F8 [6F]
    LDH A,($96)                ; $43F9 [F0 96]
    LD H,A                     ; $43FB [67]
    LD A,L                     ; $43FC [7D]
    SUB $09                    ; $43FD [D6 09]
    LD L,A                     ; $43FF [6F]
    LD A,H                     ; $4400 [7C]
    SBC A,$00                  ; $4401 [DE 00]
    LD H,A                     ; $4403 [67]
    SRL H                      ; $4404 [CB 3C]
    RR L                       ; $4406 [CB 1D]
    SRL H                      ; $4408 [CB 3C]
    RR L                       ; $440A [CB 1D]
    LD A,L                     ; $440C [7D]
    SUB $40                    ; $440D [D6 40]
    LD L,A                     ; $440F [6F]
    LD A,H                     ; $4410 [7C]
    SBC A,$00                  ; $4411 [DE 00]
    LD H,A                     ; $4413 [67]
    LD A,L                     ; $4414 [7D]
    LDH ($BB),A                ; $4415 [E0 BB]  ; -> hScrollY (cursor Y)
    LD A,H                     ; $4417 [7C]
    LDH ($BC),A                ; $4418 [E0 BC]
    CALL $4426                 ; $441A [CD 26 44]  ; draw cursor / refresh
    LD HL,$170A                ; $441D [21 0A 17]  ; bankcall -> bank23 fn10
    RST $10                    ; $4420 [D7]
    LD HL,$C905                ; $4421 [21 05 C9]  ; advance to phase 1
    INC (HL)                   ; $4424 [34]  ; wScrollPhase++
    RET                        ; $4425 [C9]

; ============================================================================
; CELL-DRAW HELPERS ($447B-$44FF) — used by phase 1 to paint each zone cell.
;   $4492 draws one 5-wide box: state byte -> base VRAM (row-base table $4500),
;   MiniMapCellPos word -> in-grid offset, then 4 rows x5 tiles.
;   NOTE: the exact split of "position" between the state byte and the pos word
;   is only partially traced — treat the per-field roles as best-effort.
; ============================================================================
SECTION "Bank25_CellDraw", ROMX[$447B], BANK[25]
Bank25_DrawRun:                     ; $447B
    PUSH BC                    ; $447B [C5]  ; draw a horizontal tile RUN along the current row (HL=pos offset)
    LD B,L                     ; $447C [45]
    LD A,L                     ; $447D [7D]
    AND $E0                    ; $447E [E6 E0]
    LD L,A                     ; $4480 [6F]
    CALL $4467                 ; $4481 [CD 67 44]  ; set VRAM col base
    LD A,B                     ; $4484 [78]
    AND $1F                    ; $4485 [E6 1F]
    JR Z,$4490                 ; $4487 [28 07]
    LD B,A                     ; $4489 [47]
    CALL $4458                 ; $448A [CD 58 44]  ; advance one tile ($4458), B times
    DEC B                      ; $448D [05]
    JR NZ,$448A                ; $448E [20 FA]
    POP BC                     ; $4490 [C1]
    RET                        ; $4491 [C9]
Bank25_DrawCell:                    ; $4492
    PUSH HL                    ; $4492 [E5]  ; draw ONE mini-map cell. IN: HL=MiniMapCellPos word, A=cell state, C=index
    PUSH AF                    ; $4493 [F5]
    SWAP A                     ; $4494 [CB 37]  ; state hi-nibble -> index row-base table
    AND $0F                    ; $4496 [E6 0F]
    LD L,A                     ; $4498 [6F]
    LD H,$00                   ; $4499 [26 00]
    LD DE,$4500                ; $449B [11 00 45]  ; row-base table $4500 (or $4520 if $C93F==2)
    LD A,($C93F)               ; $449E [FA 3F C9]
    CP $02                     ; $44A1 [FE 02]
    JR NZ,$44A8                ; $44A3 [20 03]
    LD DE,$4520                ; $44A5 [11 20 45]
    ADD HL,HL                  ; $44A8 [29]
    ADD HL,DE                  ; $44A9 [19]
    LD E,(HL)                  ; $44AA [5E]  ; DE = base VRAM addr for this cell
    INC HL                     ; $44AB [23]
    LD D,(HL)                  ; $44AC [56]
    POP AF                     ; $44AD [F1]
    AND $0F                    ; $44AE [E6 0F]  ; state lo-nibble * $14 (col shift; 0 for the $F0 default)
    LD C,$14                   ; $44B0 [0E 14]
    CALL $218D                 ; $44B2 [CD 8D 21]
    ADD HL,DE                  ; $44B5 [19]  ; DE = base + col shift
    LD E,L                     ; $44B6 [5D]
    LD D,H                     ; $44B7 [54]
    POP HL                     ; $44B8 [E1]  ; HL = the cell pos offset again
    CALL $447B                 ; $44B9 [CD 7B 44]  ; lay the cell header row
    LD A,L                     ; $44BC [7D]
    LDH ($D5),A                ; $44BD [E0 D5]  ; stash row ptr in $FFD5/D6
    LD A,H                     ; $44BF [7C]
    LDH ($D6),A                ; $44C0 [E0 D6]
    CALL $44CB                 ; $44C2 [CD CB 44]  ; paint 3 body rows (then falls into $44CB once = 4 rows total)
    CALL $44CB                 ; $44C5 [CD CB 44]
    CALL $44CB                 ; $44C8 [CD CB 44]
Bank25_DrawCellRow:                 ; $44CB  (5 tiles + advance row)
    CALL $44F5                 ; $44CB [CD F5 44]  ; paint ONE row: 5 tiles then advance to next VRAM row
    CALL $44F5                 ; $44CE [CD F5 44]
    CALL $44F5                 ; $44D1 [CD F5 44]
    CALL $44F5                 ; $44D4 [CD F5 44]
    CALL $44F5                 ; $44D7 [CD F5 44]
    LDH A,($D5)                ; $44DA [F0 D5]
    LD L,A                     ; $44DC [6F]
    LDH A,($D6)                ; $44DD [F0 D6]
    LD H,A                     ; $44DF [67]
    LD A,L                     ; $44E0 [7D]  ; row ptr += $20, wrap into $9800-$9BFF
    ADD A,$20                  ; $44E1 [C6 20]
    LD L,A                     ; $44E3 [6F]
    LD A,H                     ; $44E4 [7C]
    ADC A,$00                  ; $44E5 [CE 00]
    LD H,A                     ; $44E7 [67]
    LD A,H                     ; $44E8 [7C]
    AND $03                    ; $44E9 [E6 03]
    OR $98                     ; $44EB [F6 98]
    LD H,A                     ; $44ED [67]
    LD A,L                     ; $44EE [7D]
    LDH ($D5),A                ; $44EF [E0 D5]  ; save row ptr
    LD A,H                     ; $44F1 [7C]
    LDH ($D6),A                ; $44F2 [E0 D6]
    RET                        ; $44F4 [C9]
Bank25_DrawTile:                    ; $44F5
    LD A,(DE)                  ; $44F5 [1A]  ; paint ONE tile: src|$80 -> VRAM (ROM0 $1E80), advance col ($4458)
    OR $80                     ; $44F6 [F6 80]
    INC DE                     ; $44F8 [13]
    CALL $1E80                 ; $44F9 [CD 80 1E]
    CALL $4458                 ; $44FC [CD 58 44]
    RET                        ; $44FF [C9]


; ============================================================================
; Bank25 fn0 PHASES 2-4 + helpers ($4074-$447A) — completes fn0.
;   phase 2 $4074 : draw player/zone markers + coordinate digits, then WAIT for
;                   a button (any but Start) before dismissing -> phase 3.
;   phase 3 $4249 : teardown pt1 — clear BG, restore the saved field scroll.
;   phase 4 $4443 : exit — repaint field attrs (bank11 fn2), RES $C8EB bit3.
; ============================================================================
SECTION "Bank25_Phase234", ROMX[$4074], BANK[25]
Bank25_Fn0_Phase2:                  ; $4074  (display markers + input wait)
    LD A,($C969)               ; $4074 [FA 69 C9]  ; sub-area? ($C969) — main area skips markers, jumps to $413E
    OR A                       ; $4077 [B7]
    JP Z,$413E                 ; $4078 [CA 3E 41]
    LD HL,$CA51                ; $407B [21 51 CA]  ; scan $CA51[20] for entry $26 (the "current zone" marker id)
    LD B,$14                   ; $407E [06 14]
    LD A,(HL+)                 ; $4080 [2A]
    CP $26                     ; $4081 [FE 26]
    JR Z,$408A                 ; $4083 [28 05]
    DEC B                      ; $4085 [05]
    JR NZ,$4080                ; $4086 [20 F8]
    JR $40E8                   ; $4088 [18 5E]
    CALL $4269                 ; $408A [CD 69 42]  ; found -> compute player icon (helper $4269) + build its OAM sprite
    PUSH AF                    ; $408D [F5]
    LD HL,$FFC3                ; $408E [21 C3 FF]
    LD A,$88                   ; $4091 [3E 88]
    LD (HL+),A                 ; $4093 [22]
    LD A,$00                   ; $4094 [3E 00]
    LD (HL+),A                 ; $4096 [22]
    LD A,$08                   ; $4097 [3E 08]
    LD (HL+),A                 ; $4099 [22]
    LD A,$00                   ; $409A [3E 00]
    LD (HL+),A                 ; $409C [22]
    LD A,$02                   ; $409D [3E 02]
    LD (HL+),A                 ; $409F [22]
    LD A,$03                   ; $40A0 [3E 03]
    LD (HL+),A                 ; $40A2 [22]
    POP AF                     ; $40A3 [F1]
    LD (HL+),A                 ; $40A4 [22]
    LD A,$00                   ; $40A5 [3E 00]
    LD (HL+),A                 ; $40A7 [22]
    LD A,($C966)               ; $40A8 [FA 66 C9]  ; position icon from sub-area coords $C964-$C967 vs scroll
    LD L,A                     ; $40AB [6F]
    LD A,($C967)               ; $40AC [FA 67 C9]
    LD H,A                     ; $40AF [67]
    SRL H                      ; $40B0 [CB 3C]
    RR L                       ; $40B2 [CB 1D]
    SRL H                      ; $40B4 [CB 3C]
    RR L                       ; $40B6 [CB 1D]
    LDH A,($BB)                ; $40B8 [F0 BB]
    LD B,A                     ; $40BA [47]
    LD A,L                     ; $40BB [7D]
    SUB B                      ; $40BC [90]
    ADD A,$04                  ; $40BD [C6 04]
    CP $20                     ; $40BF [FE 20]
    JR NC,$40E4                ; $40C1 [30 21]
    LD A,($C964)               ; $40C3 [FA 64 C9]
    LD L,A                     ; $40C6 [6F]
    LD A,($C965)               ; $40C7 [FA 65 C9]
    LD H,A                     ; $40CA [67]
    SRL H                      ; $40CB [CB 3C]
    RR L                       ; $40CD [CB 1D]
    SRL H                      ; $40CF [CB 3C]
    RR L                       ; $40D1 [CB 1D]
    LDH A,($B7)                ; $40D3 [F0 B7]
    LD B,A                     ; $40D5 [47]
    LD A,L                     ; $40D6 [7D]
    SUB B                      ; $40D7 [90]
    SUB $84                    ; $40D8 [D6 84]
    JR C,$40E4                 ; $40DA [38 08]
    CP $20                     ; $40DC [FE 20]
    JR NC,$40E4                ; $40DE [30 04]
    LD A,$68                   ; $40E0 [3E 68]
    LDH ($C5),A                ; $40E2 [E0 C5]
    LD HL,$0401                ; $40E4 [21 01 04]  ; emit sprite (bank4 fn1)
    RST $10                    ; $40E7 [D7]
    LD HL,$FFC3                ; $40E8 [21 C3 FF]  ; build the frame/border sprite ($4B, $A9)
    LD A,$4B                   ; $40EB [3E 4B]
    LD (HL+),A                 ; $40ED [22]
    LD A,$00                   ; $40EE [3E 00]
    LD (HL+),A                 ; $40F0 [22]
    LD A,$3C                   ; $40F1 [3E 3C]
    LD (HL+),A                 ; $40F3 [22]
    LD A,$00                   ; $40F4 [3E 00]
    LD (HL+),A                 ; $40F6 [22]
    LD A,$02                   ; $40F7 [3E 02]
    LD (HL+),A                 ; $40F9 [22]
    LD A,$02                   ; $40FA [3E 02]
    LD (HL+),A                 ; $40FC [22]
    LD A,$A9                   ; $40FD [3E A9]
    LD (HL+),A                 ; $40FF [22]
    LD A,$00                   ; $4100 [3E 00]
    LD (HL+),A                 ; $4102 [22]
    LD HL,$0401                ; $4103 [21 01 04]  ; emit (bank4 fn1)
    RST $10                    ; $4106 [D7]
    LD A,($C960)               ; $4107 [FA 60 C9]  ; if $C950[$C960]!=0 draw the "goal" marker ($AC) via $4221
    LD HL,$C950                ; $410A [21 50 C9]
    ADD A,L                    ; $410D [85]
    LD L,A                     ; $410E [6F]
    LD A,$00                   ; $410F [3E 00]
    ADC A,H                    ; $4111 [8C]
    LD H,A                     ; $4112 [67]
    LD A,(HL)                  ; $4113 [7E]
    OR A                       ; $4114 [B7]
    JR Z,$413E                 ; $4115 [28 27]
    LD A,($C964)               ; $4117 [FA 64 C9]
    LD E,A                     ; $411A [5F]
    LD A,($C965)               ; $411B [FA 65 C9]
    LD D,A                     ; $411E [57]
    LD A,E                     ; $411F [7B]
    SUB $10                    ; $4120 [D6 10]
    LD E,A                     ; $4122 [5F]
    LD A,D                     ; $4123 [7A]
    SBC A,$00                  ; $4124 [DE 00]
    LD D,A                     ; $4126 [57]
    LD A,($C966)               ; $4127 [FA 66 C9]
    LD C,A                     ; $412A [4F]
    LD A,($C967)               ; $412B [FA 67 C9]
    LD B,A                     ; $412E [47]
    LD A,C                     ; $412F [79]
    SUB $10                    ; $4130 [D6 10]
    LD C,A                     ; $4132 [4F]
    LD A,B                     ; $4133 [78]
    SBC A,$00                  ; $4134 [DE 00]
    LD B,A                     ; $4136 [47]
    CALL $4221                 ; $4137 [CD 21 42]
    LD HL,$0400                ; $413A [21 00 04]
    RST $10                    ; $413D [D7]
    LD HL,$FFC3                ; $413E [21 C3 FF]  ; draw the fixed cursor sprite (tile $08) — the highlight box
    LD A,$08                   ; $4141 [3E 08]
    LD (HL+),A                 ; $4143 [22]
    LD A,$00                   ; $4144 [3E 00]
    LD (HL+),A                 ; $4146 [22]
    LD A,$08                   ; $4147 [3E 08]
    LD (HL+),A                 ; $4149 [22]
    LD A,$00                   ; $414A [3E 00]
    LD (HL+),A                 ; $414C [22]
    LD A,$02                   ; $414D [3E 02]
    LD (HL+),A                 ; $414F [22]
    LD A,$01                   ; $4150 [3E 01]
    LD (HL+),A                 ; $4152 [22]
    LD A,$00                   ; $4153 [3E 00]
    LD (HL+),A                 ; $4155 [22]
    LD A,$00                   ; $4156 [3E 00]
    LD (HL+),A                 ; $4158 [22]
    LD HL,$0401                ; $4159 [21 01 04]
    RST $10                    ; $415C [D7]
    LD HL,$C0A0                ; $415D [21 A0 C0]
    LD A,($C939)               ; $4160 [FA 39 C9]  ; X coordinate digits: $C939 -> decimal via $247C, draw 2 digit sprites
    LD C,A                     ; $4163 [4F]
    LD B,$00                   ; $4164 [06 00]
    INC BC                     ; $4166 [03]
    CALL $247C                 ; $4167 [CD 7C 24]
    LD A,($C0A0)               ; $416A [FA A0 C0]
    CP $F0                     ; $416D [FE F0]
    JR Z,$4193                 ; $416F [28 22]
    AND $0F                    ; $4171 [E6 0F]
    ADD A,A                    ; $4173 [87]
    PUSH AF                    ; $4174 [F5]
    LD HL,$FFC3                ; $4175 [21 C3 FF]
    LD A,$28                   ; $4178 [3E 28]
    LD (HL+),A                 ; $417A [22]
    LD A,$00                   ; $417B [3E 00]
    LD (HL+),A                 ; $417D [22]
    LD A,$08                   ; $417E [3E 08]
    LD (HL+),A                 ; $4180 [22]
    LD A,$00                   ; $4181 [3E 00]
    LD (HL+),A                 ; $4183 [22]
    LD A,$02                   ; $4184 [3E 02]
    LD (HL+),A                 ; $4186 [22]
    LD A,$00                   ; $4187 [3E 00]
    LD (HL+),A                 ; $4189 [22]
    POP AF                     ; $418A [F1]
    LD (HL+),A                 ; $418B [22]
    LD A,$00                   ; $418C [3E 00]
    LD (HL+),A                 ; $418E [22]
    LD HL,$0401                ; $418F [21 01 04]
    RST $10                    ; $4192 [D7]
    LD A,($C0A1)               ; $4193 [FA A1 C0]
    AND $0F                    ; $4196 [E6 0F]
    ADD A,A                    ; $4198 [87]
    PUSH AF                    ; $4199 [F5]
    LD HL,$FFC3                ; $419A [21 C3 FF]
    LD A,$30                   ; $419D [3E 30]
    LD (HL+),A                 ; $419F [22]
    LD A,$00                   ; $41A0 [3E 00]
    LD (HL+),A                 ; $41A2 [22]
    LD A,$08                   ; $41A3 [3E 08]
    LD (HL+),A                 ; $41A5 [22]
    LD A,$00                   ; $41A6 [3E 00]
    LD (HL+),A                 ; $41A8 [22]
    LD A,$02                   ; $41A9 [3E 02]
    LD (HL+),A                 ; $41AB [22]
    LD A,$00                   ; $41AC [3E 00]
    LD (HL+),A                 ; $41AE [22]
    POP AF                     ; $41AF [F1]
    LD (HL+),A                 ; $41B0 [22]
    LD A,$00                   ; $41B1 [3E 00]
    LD (HL+),A                 ; $41B3 [22]
    LD HL,$0401                ; $41B4 [21 01 04]
    RST $10                    ; $41B7 [D7]
    LD HL,$C0A0                ; $41B8 [21 A0 C0]  ; Y coordinate digits: $C93A -> decimal via $247C, draw 2 digit sprites
    LD A,($C93A)               ; $41BB [FA 3A C9]
    LD C,A                     ; $41BE [4F]
    LD B,$00                   ; $41BF [06 00]
    DEC BC                     ; $41C1 [0B]
    CALL $247C                 ; $41C2 [CD 7C 24]
    LD A,($C0A0)               ; $41C5 [FA A0 C0]
    CP $F0                     ; $41C8 [FE F0]
    JR Z,$41EE                 ; $41CA [28 22]
    AND $0F                    ; $41CC [E6 0F]
    ADD A,A                    ; $41CE [87]
    PUSH AF                    ; $41CF [F5]
    LD HL,$FFC3                ; $41D0 [21 C3 FF]
    LD A,$40                   ; $41D3 [3E 40]
    LD (HL+),A                 ; $41D5 [22]
    LD A,$00                   ; $41D6 [3E 00]
    LD (HL+),A                 ; $41D8 [22]
    LD A,$08                   ; $41D9 [3E 08]
    LD (HL+),A                 ; $41DB [22]
    LD A,$00                   ; $41DC [3E 00]
    LD (HL+),A                 ; $41DE [22]
    LD A,$02                   ; $41DF [3E 02]
    LD (HL+),A                 ; $41E1 [22]
    LD A,$00                   ; $41E2 [3E 00]
    LD (HL+),A                 ; $41E4 [22]
    POP AF                     ; $41E5 [F1]
    LD (HL+),A                 ; $41E6 [22]
    LD A,$00                   ; $41E7 [3E 00]
    LD (HL+),A                 ; $41E9 [22]
    LD HL,$0401                ; $41EA [21 01 04]
    RST $10                    ; $41ED [D7]
    LD A,($C0A1)               ; $41EE [FA A1 C0]
    AND $0F                    ; $41F1 [E6 0F]
    ADD A,A                    ; $41F3 [87]
    PUSH AF                    ; $41F4 [F5]
    LD HL,$FFC3                ; $41F5 [21 C3 FF]
    LD A,$48                   ; $41F8 [3E 48]
    LD (HL+),A                 ; $41FA [22]
    LD A,$00                   ; $41FB [3E 00]
    LD (HL+),A                 ; $41FD [22]
    LD A,$08                   ; $41FE [3E 08]
    LD (HL+),A                 ; $4200 [22]
    LD A,$00                   ; $4201 [3E 00]
    LD (HL+),A                 ; $4203 [22]
    LD A,$02                   ; $4204 [3E 02]
    LD (HL+),A                 ; $4206 [22]
    LD A,$00                   ; $4207 [3E 00]
    LD (HL+),A                 ; $4209 [22]
    POP AF                     ; $420A [F1]
    LD (HL+),A                 ; $420B [22]
    LD A,$00                   ; $420C [3E 00]
    LD (HL+),A                 ; $420E [22]
    LD HL,$0401                ; $420F [21 01 04]
    RST $10                    ; $4212 [D7]
    LD A,($C846)               ; $4213 [FA 46 C8]  ; --- INPUT WAIT: read joypad $C846, mask out Start (bit3) ---
    AND $F7                    ; $4216 [E6 F7]  ; AND $F7 (ignore Start)
    JR Z,$4220                 ; $4218 [28 06]  ; nothing pressed -> stay in phase 2
    LD HL,$C905                ; $421A [21 05 C9]  ; any other button -> advance to phase 3 (dismiss)
    INC (HL)                   ; $421D [34]
    JR $4220                   ; $421E [18 00]
    RET                        ; $4220 [C9]  ; RET
Bank25_P2_GoalMarker:               ; $4221
    SRL D                      ; $4221 [CB 3A]  ; helper: (DE,BC)>>2 each, store to $FFC3.. as a sprite pos (tile $AC)
    RR E                       ; $4223 [CB 1B]
    SRL D                      ; $4225 [CB 3A]
    RR E                       ; $4227 [CB 1B]
    SRL B                      ; $4229 [CB 38]
    RR C                       ; $422B [CB 19]
    SRL B                      ; $422D [CB 38]
    RR C                       ; $422F [CB 19]
    LD HL,$FFC3                ; $4231 [21 C3 FF]
    LD A,E                     ; $4234 [7B]
    LD (HL+),A                 ; $4235 [22]
    LD A,D                     ; $4236 [7A]
    LD (HL+),A                 ; $4237 [22]
    LD A,C                     ; $4238 [79]
    LD (HL+),A                 ; $4239 [22]
    LD A,B                     ; $423A [78]
    LD (HL+),A                 ; $423B [22]
    LD A,$00                   ; $423C [3E 00]
    LD (HL+),A                 ; $423E [22]
    LD A,$00                   ; $423F [3E 00]
    LD (HL+),A                 ; $4241 [22]
    LD A,$AC                   ; $4242 [3E AC]
    LD (HL+),A                 ; $4244 [22]
    LD A,$00                   ; $4245 [3E 00]
    LD (HL+),A                 ; $4247 [22]
    RET                        ; $4248 [C9]
Bank25_Fn0_Phase3:                  ; $4249  (teardown: clear BG, restore scroll)
    CALL $4426                 ; $4249 [CD 26 44]  ; clear the mini-map BG ($4426)
    LDH A,($BF)                ; $424C [F0 BF]  ; restore saved scroll: hFFBF/C0 -> hScrollX, hFFC1/C2 -> hScrollY
    LD L,A                     ; $424E [6F]
    LDH A,($C0)                ; $424F [F0 C0]
    LD H,A                     ; $4251 [67]
    LD A,L                     ; $4252 [7D]
    LDH ($B7),A                ; $4253 [E0 B7]
    LD A,H                     ; $4255 [7C]
    LDH ($B8),A                ; $4256 [E0 B8]
    LDH A,($C1)                ; $4258 [F0 C1]
    LD L,A                     ; $425A [6F]
    LDH A,($C2)                ; $425B [F0 C2]
    LD H,A                     ; $425D [67]
    LD A,L                     ; $425E [7D]
    LDH ($BB),A                ; $425F [E0 BB]
    LD A,H                     ; $4261 [7C]
    LDH ($BC),A                ; $4262 [E0 BC]
    LD HL,$C905                ; $4264 [21 05 C9]  ; advance to phase 4
    INC (HL)                   ; $4267 [34]
    RET                        ; $4268 [C9]
Bank25_P2_IconDist:                 ; $4269  (marker distance helper)
    LDH A,($95)                ; $4269 [F0 95]  ; helper (phase2): pixel distance camera($95/96,$92/93) vs $C964-$C967
    LD L,A                     ; $426B [6F]
    LDH A,($96)                ; $426C [F0 96]
    LD H,A                     ; $426E [67]
    LD A,L                     ; $426F [7D]
    AND $F0                    ; $4270 [E6 F0]
    LD L,A                     ; $4272 [6F]
    LD A,($C966)               ; $4273 [FA 66 C9]
    LD E,A                     ; $4276 [5F]
    LD A,($C967)               ; $4277 [FA 67 C9]
    LD D,A                     ; $427A [57]
    LD A,E                     ; $427B [7B]
    AND $F0                    ; $427C [E6 F0]
    LD E,A                     ; $427E [5F]
    LD A,L                     ; $427F [7D]
    SUB E                      ; $4280 [93]
    LD L,A                     ; $4281 [6F]
    LD A,H                     ; $4282 [7C]
    SBC A,D                    ; $4283 [9A]
    LD H,A                     ; $4284 [67]
    JR NC,$4291                ; $4285 [30 0A]
    LD A,L                     ; $4287 [7D]
    CPL                        ; $4288 [2F]
    ADD A,$01                  ; $4289 [C6 01]
    LD L,A                     ; $428B [6F]
    LD A,H                     ; $428C [7C]
    CPL                        ; $428D [2F]
    ADC A,$00                  ; $428E [CE 00]
    LD H,A                     ; $4290 [67]
    LDH A,($92)                ; $4291 [F0 92]
    LD E,A                     ; $4293 [5F]
    LDH A,($93)                ; $4294 [F0 93]
    LD D,A                     ; $4296 [57]
    LD A,E                     ; $4297 [7B]
    AND $F0                    ; $4298 [E6 F0]
    LD E,A                     ; $429A [5F]
    LD A,($C964)               ; $429B [FA 64 C9]
    LD C,A                     ; $429E [4F]
    LD A,($C965)               ; $429F [FA 65 C9]
    LD B,A                     ; $42A2 [47]
    LD A,C                     ; $42A3 [79]
    AND $F0                    ; $42A4 [E6 F0]
    LD C,A                     ; $42A6 [4F]
    LD A,E                     ; $42A7 [7B]
    SUB C                      ; $42A8 [91]
    LD E,A                     ; $42A9 [5F]
    LD A,D                     ; $42AA [7A]
    SBC A,B                    ; $42AB [98]
    LD D,A                     ; $42AC [57]
    JR NC,$42B9                ; $42AD [30 0A]
    LD A,E                     ; $42AF [7B]
    CPL                        ; $42B0 [2F]
    ADD A,$01                  ; $42B1 [C6 01]
    LD E,A                     ; $42B3 [5F]
    LD A,D                     ; $42B4 [7A]
    CPL                        ; $42B5 [2F]
    ADC A,$00                  ; $42B6 [CE 00]
    LD D,A                     ; $42B8 [57]
    PUSH HL                    ; $42B9 [E5]  ; -> B = marker anim/frame based on distance
    PUSH DE                    ; $42BA [D5]
    LD A,H                     ; $42BB [7C]
    OR A                       ; $42BC [B7]
    JR NZ,$42DE                ; $42BD [20 1F]
    LD A,D                     ; $42BF [7A]
    OR A                       ; $42C0 [B7]
    JR NZ,$42DE                ; $42C1 [20 1B]
    LD A,L                     ; $42C3 [7D]
    CP $20                     ; $42C4 [FE 20]
    JR NZ,$42D1                ; $42C6 [20 09]
    LD A,E                     ; $42C8 [7B]
    CP $50                     ; $42C9 [FE 50]
    JR C,$42DE                 ; $42CB [38 11]
    LD B,$00                   ; $42CD [06 00]
    JR $42FE                   ; $42CF [18 2D]
    CP $10                     ; $42D1 [FE 10]
    JR NZ,$42DE                ; $42D3 [20 09]
    LD A,E                     ; $42D5 [7B]
    CP $30                     ; $42D6 [FE 30]
    JR C,$42DE                 ; $42D8 [38 04]
    LD B,$00                   ; $42DA [06 00]
    JR $42FE                   ; $42DC [18 20]
    LDH A,($95)                ; $42DE [F0 95]
    LD L,A                     ; $42E0 [6F]
    LDH A,($96)                ; $42E1 [F0 96]
    LD H,A                     ; $42E3 [67]
    LD A,($C966)               ; $42E4 [FA 66 C9]
    LD E,A                     ; $42E7 [5F]
    LD A,($C967)               ; $42E8 [FA 67 C9]
    LD D,A                     ; $42EB [57]
    LD A,L                     ; $42EC [7D]
    SUB E                      ; $42ED [93]
    LD L,A                     ; $42EE [6F]
    LD A,H                     ; $42EF [7C]
    SBC A,D                    ; $42F0 [9A]
    LD H,A                     ; $42F1 [67]
    LD B,$06                   ; $42F2 [06 06]
    JR C,$42FE                 ; $42F4 [38 08]
    LD A,H                     ; $42F6 [7C]
    OR L                       ; $42F7 [B5]
    LD B,$03                   ; $42F8 [06 03]
    JR NZ,$42FE                ; $42FA [20 02]
    LD B,$00                   ; $42FC [06 00]
    POP DE                     ; $42FE [D1]
    POP HL                     ; $42FF [E1]
    LD A,H                     ; $4300 [7C]
    OR A                       ; $4301 [B7]
    JR NZ,$4323                ; $4302 [20 1F]
    LD A,D                     ; $4304 [7A]
    OR A                       ; $4305 [B7]
    JR NZ,$4323                ; $4306 [20 1B]
    LD A,E                     ; $4308 [7B]
    CP $20                     ; $4309 [FE 20]
    JR NZ,$4316                ; $430B [20 09]
    LD A,L                     ; $430D [7D]
    CP $50                     ; $430E [FE 50]
    JR C,$4323                 ; $4310 [38 11]
    LD A,$00                   ; $4312 [3E 00]
    JR $4343                   ; $4314 [18 2D]
    CP $10                     ; $4316 [FE 10]
    JR NZ,$4323                ; $4318 [20 09]
    LD A,L                     ; $431A [7D]
    CP $30                     ; $431B [FE 30]
    JR C,$4323                 ; $431D [38 04]
    LD A,$00                   ; $431F [3E 00]
    JR $4343                   ; $4321 [18 20]
    LDH A,($92)                ; $4323 [F0 92]
    LD L,A                     ; $4325 [6F]
    LDH A,($93)                ; $4326 [F0 93]
    LD H,A                     ; $4328 [67]
    LD A,($C964)               ; $4329 [FA 64 C9]
    LD E,A                     ; $432C [5F]
    LD A,($C965)               ; $432D [FA 65 C9]
    LD D,A                     ; $4330 [57]
    LD A,L                     ; $4331 [7D]
    SUB E                      ; $4332 [93]
    LD L,A                     ; $4333 [6F]
    LD A,H                     ; $4334 [7C]
    SBC A,D                    ; $4335 [9A]
    LD H,A                     ; $4336 [67]
    LD A,$02                   ; $4337 [3E 02]
    JR C,$4343                 ; $4339 [38 08]
    LD A,H                     ; $433B [7C]
    OR L                       ; $433C [B5]
    LD A,$01                   ; $433D [3E 01]
    JR NZ,$4343                ; $433F [20 02]
    LD A,$00                   ; $4341 [3E 00]
    ADD A,B                    ; $4343 [80]
    LD HL,$434E                ; $4344 [21 4E 43]
    ADD A,L                    ; $4347 [85]
    LD L,A                     ; $4348 [6F]
    LD A,$00                   ; $4349 [3E 00]
    ADC A,H                    ; $434B [8C]
    LD H,A                     ; $434C [67]
    LD A,(HL)                  ; $434D [7E]
    RET                        ; $434E [C9]
    OR H                       ; $434F [B4]
    OR (HL)                    ; $4350 [B6]
    OR B                       ; $4351 [B0]
    CP B                       ; $4352 [B8]
    CP D                       ; $4353 [BA]
    OR D                       ; $4354 [B2]
    CP H                       ; $4355 [BC]
    CP (HL)                    ; $4356 [BE]
    LD A,(HL)                  ; $4357 [7E]
    ADD A,$04                  ; $4358 [C6 04]
    LD (HL+),A                 ; $435A [22]
    LD A,(HL)                  ; $435B [7E]
    ADC A,$00                  ; $435C [CE 00]
    LD (HL-),A                 ; $435E [32]
    LD A,(HL)                  ; $435F [7E]
    AND $F8                    ; $4360 [E6 F8]
    LD (HL),A                  ; $4362 [77]
    RET                        ; $4363 [C9]

SECTION "Bank25_ClearAndExit", ROMX[$4426], BANK[25]
Bank25_ClearMiniMapBG:              ; $4426
    LD HL,$9800                ; $4426 [21 00 98]  ; --- clear mini-map BG: fill $9800-$9BFF with blank tile $E0 ---
    LD B,$00                   ; $4429 [06 00]
    LD A,$E0                   ; $442B [3E E0]
    CALL $1E8C                 ; $442D [CD 8C 1E]
    LD A,$E0                   ; $4430 [3E E0]
    CALL $1E8C                 ; $4432 [CD 8C 1E]
    LD A,$E0                   ; $4435 [3E E0]
    CALL $1E8C                 ; $4437 [CD 8C 1E]
    LD A,$E0                   ; $443A [3E E0]
    CALL $1E8C                 ; $443C [CD 8C 1E]
    DEC B                      ; $443F [05]
    JR NZ,$442B                ; $4440 [20 E9]
    RET                        ; $4442 [C9]
Bank25_Fn0_Phase4:                  ; $4443  (exit: repaint field, RES bit3)
    LD A,$FF                   ; $4443 [3E FF]  ; --- phase 4: EXIT ---
    LDH ($B6),A                ; $4445 [E0 B6]  ; hFFB6 = $FF
    LD HL,$0B02                ; $4447 [21 02 0B]  ; bank11 fn2 (repaint CGB attrs)
    RST $10                    ; $444A [D7]
    CALL $29C0                 ; $444B [CD C0 29]  ; ROM0 $29C0
    LD HL,$C8EB                ; $444E [21 EB C8]  ; clear $C8EB bit3 = leave mini-map mode
    RES 3,(HL)                 ; $4451 [CB 9E]
    XOR A                      ; $4453 [AF]  ; reset phase
    LD ($C905),A               ; $4454 [EA 05 C9]
    RET                        ; $4457 [C9]
Bank25_VramColAdv:                  ; $4458
    PUSH AF                    ; $4458 [F5]  ; VRAM col-advance: L=(L&$E0)|((L+1)&$1F) (wrap within 32-tile row)
    LD A,L                     ; $4459 [7D]
    AND $E0                    ; $445A [E6 E0]
    PUSH AF                    ; $445C [F5]
    LD A,L                     ; $445D [7D]
    INC A                      ; $445E [3C]
    AND $1F                    ; $445F [E6 1F]
    LD L,A                     ; $4461 [6F]
    POP AF                     ; $4462 [F1]
    OR L                       ; $4463 [B5]
    LD L,A                     ; $4464 [6F]
    POP AF                     ; $4465 [F1]
    RET                        ; $4466 [C9]
Bank25_VramRowBase:                 ; $4467
    LD A,($C909)               ; $4467 [FA 09 C9]  ; VRAM row base: HL = $C909/$C90A + HL, wrapped into $9800-$9BFF
    ADD A,L                    ; $446A [85]
    LD L,A                     ; $446B [6F]
    LD A,($C90A)               ; $446C [FA 0A C9]
    ADC A,H                    ; $446F [8C]
    AND $03                    ; $4470 [E6 03]
    LD H,A                     ; $4472 [67]
    LD A,($C90A)               ; $4473 [FA 0A C9]
    AND $FC                    ; $4476 [E6 FC]
    OR H                       ; $4478 [B4]
    LD H,A                     ; $4479 [67]
    RET                        ; $447A [C9]

; ----------------------------------------------------------------------------
; CellGfxPtr tables ($4500 / $4520) — 16 words each, indexed by the cell STATE
;   byte hi-nibble (see draw-cell $4492). Each points at a tile-source block in
;   bank25 ROM ($4540+); the STATE picks WHICH graphic, MiniMapCellPos the WHERE.
;   $4520 is the alt set used when $C93F==2. DATA.
; ----------------------------------------------------------------------------
SECTION "Bank25_CellGfxPtr", ROMX[$4500], BANK[25]
Bank25_CellGfxPtr:                  ; $4500
    dw $4540,$4644,$4748,$484C,$4950,$4A54,$4B58,$4C5C   ; $4500 [40 45 44 46 48 47 4C 48 50 49 54 4A 58 4B 5C 4C]
    dw $4D60,$4E64,$4F68,$506C,$5170,$5274,$5378,$547C   ; $4510 [60 4D 64 4E 68 4F 6C 50 70 51 74 52 78 53 7C 54]
Bank25_CellGfxPtr_Alt:              ; $4520
    dw $5580,$5698,$5724,$57B0,$583C,$58C8,$5918,$597C   ; $4520 [80 55 98 56 24 57 B0 57 3C 58 C8 58 18 59 7C 59]
    dw $59E0,$5A44,$5AA8,$5AF8,$5B34,$5B70,$5BAC,$547C   ; $4530 [E0 59 44 5A A8 5A F8 5A 34 5B 70 5B AC 5B 7C 54]


; ============================================================================
; MINI-MAP TILEMAP DATA ($4540-$5BE7) — cell-graphic layouts (tile indices).
;   Referenced by CellGfxPtr ($4500, 16 "main" 13x20 layouts) and
;   CellGfxPtr_Alt ($4520, variable-height 20-wide layouts for sub-areas).
;   draw-cell $4492 copies a cell-sized window out of the selected layout to
;   VRAM, applying OR $80 per tile ($44F5). DATA, not code.
; ============================================================================
SECTION "Bank25_MiniMapTilemaps", ROMX[$4540], BANK[25]
Bank25_MMTilemap_00:  ; $4540-$4643  (13 rows x 20)
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$0D,$0A,$01,$01,$01,$0B,$00,$00,$01,$00,$00   ; $4540
    db $00,$00,$0B,$00,$00,$07,$0C,$08,$00,$04,$03,$02,$01,$0D,$0B,$00,$00,$01,$00,$00   ; $4554
    db $00,$00,$01,$00,$00,$07,$01,$01,$01,$07,$06,$06,$01,$06,$06,$00,$00,$01,$00,$00   ; $4568
    db $00,$00,$01,$00,$00,$07,$0B,$01,$04,$07,$06,$03,$01,$0C,$06,$00,$00,$01,$00,$00   ; $457C
    db $00,$00,$01,$00,$00,$0C,$0B,$06,$0A,$0D,$0A,$0D,$07,$0C,$0B,$00,$00,$01,$00,$00   ; $4590
    db $00,$00,$01,$00,$00,$0C,$0D,$01,$0C,$0D,$0A,$0B,$01,$0A,$0B,$00,$00,$01,$00,$00   ; $45A4
    db $00,$00,$0A,$00,$00,$05,$00,$09,$01,$0D,$0A,$00,$09,$01,$0B,$02,$06,$01,$03,$00   ; $45B8
    db $00,$00,$01,$00,$00,$05,$01,$06,$01,$04,$0A,$08,$00,$09,$0B,$00,$06,$01,$06,$00   ; $45CC
    db $00,$00,$0B,$00,$00,$0C,$0A,$0D,$07,$0D,$03,$00,$00,$00,$0B,$00,$00,$0C,$06,$03   ; $45E0
    db $00,$00,$0A,$00,$00,$05,$04,$0C,$00,$07,$06,$06,$08,$00,$0B,$00,$00,$01,$06,$03   ; $45F4
    db $00,$00,$0B,$00,$00,$0C,$01,$08,$00,$04,$06,$06,$0A,$01,$0B,$00,$00,$0C,$06,$03   ; $4608
    db $00,$00,$01,$00,$00,$0C,$01,$0B,$0A,$07,$0A,$01,$08,$00,$02,$02,$06,$0D,$00,$00   ; $461C
    db $00,$00,$01,$00,$00,$07,$07,$01,$07,$07,$06,$06,$01,$06,$06,$00,$00,$01,$00,$00   ; $4630
Bank25_MMTilemap_01:  ; $4644-$4747  (13 rows x 20)
    db $00,$00,$00,$00,$00,$07,$01,$01,$01,$07,$06,$01,$01,$01,$06,$00,$06,$01,$06,$00   ; $4644
    db $00,$00,$00,$00,$00,$0C,$06,$01,$06,$0D,$06,$00,$01,$00,$06,$00,$00,$01,$00,$00   ; $4658
    db $00,$00,$00,$00,$00,$0C,$06,$06,$01,$0D,$0A,$07,$05,$00,$0B,$00,$00,$01,$06,$03   ; $466C
    db $00,$00,$00,$00,$00,$0C,$01,$01,$00,$04,$0A,$01,$01,$00,$0B,$02,$06,$01,$06,$03   ; $4680
    db $00,$00,$00,$00,$00,$07,$07,$0C,$01,$0D,$03,$00,$00,$09,$06,$00,$00,$01,$06,$00   ; $4694
    db $00,$00,$00,$00,$00,$0C,$0A,$00,$00,$04,$06,$09,$07,$07,$0B,$00,$02,$01,$06,$03   ; $46A8
    db $00,$00,$00,$00,$00,$07,$00,$09,$06,$0D,$0A,$07,$0C,$00,$06,$02,$06,$01,$00,$00   ; $46BC
    db $00,$00,$00,$00,$00,$0C,$06,$06,$0A,$0D,$03,$00,$00,$09,$0B,$00,$00,$0C,$06,$03   ; $46D0
    db $00,$00,$00,$00,$00,$0C,$06,$01,$01,$0D,$03,$00,$0A,$01,$0B,$00,$00,$0C,$06,$03   ; $46E4
    db $00,$00,$00,$00,$00,$0C,$06,$06,$08,$04,$03,$04,$07,$08,$0B,$00,$02,$01,$06,$03   ; $46F8
    db $00,$00,$00,$00,$00,$0C,$0A,$00,$0B,$0D,$06,$09,$07,$08,$06,$00,$02,$01,$03,$00   ; $470C
    db $00,$00,$00,$00,$00,$0C,$0A,$01,$01,$0D,$06,$09,$01,$01,$0B,$00,$02,$01,$06,$03   ; $4720
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$07,$06,$06,$01,$06,$06,$00,$00,$01,$00,$00   ; $4734
Bank25_MMTilemap_02:  ; $4748-$484B  (13 rows x 20)
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$0D,$06,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $4748
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$0D,$0A,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $475C
    db $00,$00,$01,$00,$00,$05,$09,$06,$06,$0D,$0A,$0C,$00,$00,$06,$02,$06,$00,$00,$00   ; $4770
    db $00,$00,$01,$00,$00,$05,$00,$01,$00,$04,$06,$0A,$01,$0B,$06,$00,$02,$06,$03,$00   ; $4784
    db $00,$00,$01,$00,$00,$0C,$08,$06,$06,$0D,$0A,$08,$07,$05,$0B,$02,$06,$03,$06,$03   ; $4798
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$0D,$0A,$08,$00,$09,$0B,$02,$06,$06,$06,$03   ; $47AC
    db $00,$00,$01,$00,$00,$0C,$06,$06,$00,$04,$0A,$00,$00,$00,$0B,$02,$06,$06,$06,$03   ; $47C0
    db $00,$00,$01,$00,$00,$0C,$0B,$06,$0A,$0D,$03,$00,$00,$00,$02,$00,$00,$00,$00,$00   ; $47D4
    db $00,$00,$01,$00,$00,$0C,$0A,$01,$05,$04,$03,$00,$00,$08,$0B,$00,$00,$00,$06,$03   ; $47E8
    db $00,$00,$01,$00,$00,$07,$07,$0B,$00,$04,$0A,$01,$08,$00,$0B,$02,$06,$06,$06,$03   ; $47FC
    db $00,$00,$01,$00,$00,$05,$00,$09,$01,$0D,$0A,$01,$0C,$00,$02,$02,$06,$03,$00,$00   ; $4810
    db $00,$00,$01,$00,$00,$05,$01,$06,$01,$07,$06,$01,$07,$01,$02,$00,$06,$06,$06,$00   ; $4824
    db $00,$00,$01,$00,$00,$07,$07,$01,$07,$07,$06,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $4838
Bank25_MMTilemap_03:  ; $484C-$494F  (13 rows x 20)
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$01,$06,$03   ; $484C
    db $00,$00,$01,$00,$00,$00,$00,$01,$01,$0D,$00,$00,$01,$01,$0B,$00,$00,$01,$06,$03   ; $4860
    db $00,$00,$01,$00,$00,$09,$06,$06,$00,$04,$09,$07,$07,$0C,$06,$00,$00,$01,$00,$00   ; $4874
    db $00,$00,$01,$00,$00,$09,$06,$06,$06,$0D,$09,$05,$00,$00,$0B,$02,$03,$01,$06,$03   ; $4888
    db $00,$00,$01,$00,$00,$00,$00,$01,$07,$07,$00,$00,$01,$06,$06,$00,$00,$01,$00,$00   ; $489C
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$0D,$09,$08,$00,$09,$0B,$02,$06,$01,$06,$03   ; $48B0
    db $00,$00,$01,$00,$00,$04,$0C,$06,$06,$0D,$09,$01,$00,$00,$02,$02,$06,$0D,$00,$00   ; $48C4
    db $00,$00,$01,$00,$00,$09,$08,$09,$01,$0D,$09,$01,$0B,$03,$02,$02,$06,$0D,$00,$00   ; $48D8
    db $00,$00,$01,$00,$00,$00,$04,$08,$00,$04,$00,$09,$0B,$06,$06,$00,$00,$0D,$00,$00   ; $48EC
    db $00,$00,$01,$00,$00,$00,$00,$02,$0A,$0D,$00,$00,$00,$09,$0B,$00,$00,$0C,$06,$03   ; $4900
    db $00,$00,$01,$00,$00,$09,$06,$03,$04,$07,$09,$07,$07,$0C,$0B,$02,$06,$01,$06,$03   ; $4914
    db $00,$00,$01,$00,$00,$04,$01,$0B,$06,$0D,$09,$00,$0D,$07,$0B,$02,$06,$01,$06,$03   ; $4928
    db $00,$00,$01,$00,$00,$00,$00,$01,$07,$07,$00,$00,$01,$06,$06,$00,$00,$01,$00,$00   ; $493C
Bank25_MMTilemap_04:  ; $4950-$4A53  (13 rows x 20)
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $4950
    db $00,$00,$01,$00,$00,$0C,$01,$01,$00,$00,$0A,$01,$01,$00,$00,$02,$06,$01,$00,$00   ; $4964
    db $00,$00,$01,$00,$00,$07,$07,$01,$00,$00,$06,$06,$01,$00,$00,$00,$00,$01,$00,$00   ; $4978
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$08,$0A,$08,$00,$09,$08,$02,$06,$01,$06,$03   ; $498C
    db $00,$00,$01,$00,$00,$0C,$06,$06,$0A,$08,$06,$00,$00,$09,$08,$00,$00,$01,$06,$03   ; $49A0
    db $00,$00,$01,$00,$00,$07,$09,$01,$01,$08,$0A,$00,$00,$00,$08,$02,$06,$01,$06,$03   ; $49B4
    db $00,$00,$01,$00,$00,$0C,$01,$06,$0A,$05,$03,$00,$04,$0C,$08,$00,$00,$0C,$06,$03   ; $49C8
    db $00,$00,$01,$00,$00,$07,$01,$03,$00,$00,$06,$01,$05,$00,$00,$00,$00,$01,$00,$00   ; $49DC
    db $00,$00,$01,$00,$00,$07,$05,$02,$06,$08,$0A,$01,$07,$05,$08,$02,$06,$01,$06,$03   ; $49F0
    db $00,$00,$01,$00,$00,$0C,$0B,$03,$04,$05,$0A,$0D,$05,$0C,$03,$00,$02,$01,$03,$00   ; $4A04
    db $00,$00,$01,$00,$00,$0C,$06,$01,$06,$08,$0A,$07,$01,$07,$08,$02,$02,$01,$03,$03   ; $4A18
    db $00,$00,$01,$00,$00,$05,$00,$01,$00,$00,$06,$0D,$01,$00,$00,$00,$00,$01,$00,$00   ; $4A2C
    db $00,$00,$01,$00,$00,$07,$07,$01,$00,$00,$06,$06,$01,$00,$00,$00,$00,$01,$00,$00   ; $4A40
Bank25_MMTilemap_05:  ; $4A54-$4B57  (13 rows x 20)
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$07,$06,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $4A54
    db $00,$00,$00,$00,$00,$0C,$01,$01,$01,$0D,$0A,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $4A68
    db $00,$00,$00,$00,$00,$0C,$01,$08,$01,$0D,$06,$01,$08,$01,$0B,$00,$06,$06,$06,$03   ; $4A7C
    db $00,$00,$00,$00,$00,$07,$05,$00,$0B,$0D,$0A,$0D,$07,$08,$06,$02,$06,$06,$03,$00   ; $4A90
    db $00,$00,$00,$00,$00,$0C,$06,$06,$08,$07,$06,$04,$07,$08,$0B,$00,$02,$06,$06,$03   ; $4AA4
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$07,$0A,$00,$01,$00,$0B,$02,$06,$06,$06,$03   ; $4AB8
    db $00,$00,$00,$00,$00,$05,$00,$00,$09,$0D,$0A,$0D,$0C,$0B,$06,$00,$02,$03,$00,$00   ; $4ACC
    db $00,$00,$00,$00,$00,$05,$04,$07,$00,$04,$0A,$09,$09,$01,$0B,$02,$06,$00,$00,$00   ; $4AE0
    db $00,$00,$00,$00,$00,$07,$07,$07,$00,$04,$03,$09,$01,$01,$06,$00,$02,$06,$06,$00   ; $4AF4
    db $00,$00,$00,$00,$00,$0C,$06,$0A,$06,$0D,$03,$04,$0C,$05,$02,$00,$02,$06,$03,$00   ; $4B08
    db $00,$00,$00,$00,$00,$0C,$06,$0A,$08,$07,$0A,$05,$00,$08,$0B,$02,$06,$06,$06,$03   ; $4B1C
    db $00,$00,$00,$00,$00,$05,$00,$00,$09,$0D,$0A,$01,$0B,$06,$02,$02,$06,$03,$00,$00   ; $4B30
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$07,$06,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $4B44
Bank25_MMTilemap_06:  ; $4B58-$4C5B  (13 rows x 20)
    db $00,$00,$00,$00,$00,$00,$00,$07,$07,$07,$00,$00,$01,$06,$06,$00,$00,$01,$00,$00   ; $4B58
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$01,$06,$03   ; $4B6C
    db $00,$00,$00,$00,$00,$09,$01,$01,$07,$07,$09,$01,$01,$06,$06,$00,$00,$01,$00,$00   ; $4B80
    db $00,$00,$00,$00,$00,$09,$0B,$06,$06,$0D,$09,$08,$00,$00,$06,$02,$06,$01,$00,$00   ; $4B94
    db $00,$00,$00,$00,$00,$09,$06,$06,$03,$07,$09,$00,$07,$07,$0B,$02,$06,$01,$00,$00   ; $4BA8
    db $00,$00,$00,$00,$00,$09,$06,$06,$0A,$0D,$09,$07,$00,$09,$0B,$02,$06,$01,$06,$03   ; $4BBC
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$04,$0B,$00,$00,$0C,$06,$03   ; $4BD0
    db $00,$00,$00,$00,$00,$00,$00,$09,$01,$0D,$00,$09,$01,$01,$0B,$00,$02,$01,$03,$00   ; $4BE4
    db $00,$00,$00,$00,$00,$09,$01,$00,$00,$04,$09,$01,$00,$04,$0B,$02,$06,$01,$06,$03   ; $4BF8
    db $00,$00,$00,$00,$00,$09,$01,$01,$06,$0D,$09,$01,$0B,$00,$02,$02,$06,$0D,$00,$00   ; $4C0C
    db $00,$00,$00,$00,$00,$00,$00,$09,$01,$0D,$00,$00,$09,$00,$0B,$00,$00,$0C,$06,$03   ; $4C20
    db $00,$00,$00,$00,$00,$00,$00,$09,$01,$0D,$09,$01,$0B,$03,$02,$02,$06,$0D,$00,$00   ; $4C34
    db $00,$00,$00,$00,$00,$00,$00,$07,$07,$07,$00,$00,$01,$06,$06,$00,$00,$01,$00,$00   ; $4C48
Bank25_MMTilemap_07:  ; $4C5C-$4D5F  (13 rows x 20)
    db $00,$00,$00,$00,$00,$07,$07,$07,$00,$00,$06,$06,$01,$00,$00,$00,$00,$01,$00,$00   ; $4C5C
    db $00,$00,$00,$00,$00,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $4C70
    db $00,$00,$00,$00,$00,$0C,$06,$06,$06,$08,$06,$04,$07,$07,$08,$00,$02,$01,$00,$00   ; $4C84
    db $00,$00,$00,$00,$00,$0C,$06,$06,$0A,$08,$0A,$00,$00,$09,$08,$02,$06,$01,$02,$03   ; $4C98
    db $00,$00,$00,$00,$00,$07,$07,$01,$01,$08,$06,$06,$01,$01,$08,$00,$00,$01,$06,$03   ; $4CAC
    db $00,$00,$00,$00,$00,$0C,$0B,$01,$01,$08,$0A,$08,$01,$01,$08,$02,$03,$01,$06,$03   ; $4CC0
    db $00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$0A,$05,$00,$00,$00,$02,$06,$0D,$00,$00   ; $4CD4
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$05,$03,$00,$00,$09,$08,$00,$00,$0C,$06,$03   ; $4CE8
    db $00,$00,$00,$00,$00,$0C,$0B,$0A,$00,$00,$03,$00,$09,$00,$00,$00,$00,$0C,$00,$00   ; $4CFC
    db $00,$00,$00,$00,$00,$07,$0C,$06,$0A,$05,$0A,$00,$00,$0C,$08,$02,$06,$01,$03,$00   ; $4D10
    db $00,$00,$00,$00,$00,$05,$09,$01,$01,$08,$0A,$09,$01,$01,$08,$02,$06,$01,$06,$03   ; $4D24
    db $00,$00,$00,$00,$00,$0C,$0A,$09,$0A,$00,$0A,$09,$01,$09,$00,$02,$06,$01,$06,$00   ; $4D38
    db $00,$00,$00,$00,$00,$07,$07,$07,$00,$00,$06,$06,$01,$00,$00,$00,$00,$01,$00,$00   ; $4D4C
Bank25_MMTilemap_08:  ; $4D60-$4E63  (13 rows x 20)
    db $00,$00,$01,$00,$00,$00,$00,$01,$07,$07,$00,$00,$06,$06,$06,$00,$00,$00,$00,$00   ; $4D60
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $4D74
    db $00,$00,$01,$00,$00,$09,$0B,$06,$00,$04,$09,$08,$00,$09,$0B,$02,$06,$06,$06,$03   ; $4D88
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$04,$09,$01,$01,$06,$06,$02,$06,$06,$00,$00   ; $4D9C
    db $00,$00,$01,$00,$00,$09,$01,$0B,$06,$0D,$09,$08,$00,$07,$0B,$02,$06,$06,$06,$03   ; $4DB0
    db $00,$00,$01,$00,$00,$09,$08,$06,$06,$0D,$09,$00,$00,$00,$0B,$02,$06,$06,$06,$03   ; $4DC4
    db $00,$00,$01,$00,$00,$00,$00,$09,$0D,$04,$00,$00,$00,$06,$06,$00,$00,$00,$00,$00   ; $4DD8
    db $00,$00,$01,$00,$00,$00,$00,$06,$01,$0D,$00,$00,$00,$06,$06,$00,$00,$00,$00,$00   ; $4DEC
    db $00,$00,$01,$00,$00,$09,$01,$08,$00,$04,$09,$01,$01,$06,$06,$02,$06,$02,$00,$00   ; $4E00
    db $00,$00,$01,$00,$00,$04,$0B,$06,$0D,$04,$02,$0D,$00,$09,$0B,$00,$02,$06,$06,$03   ; $4E14
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$07,$09,$09,$09,$09,$02,$02,$02,$02,$02,$00   ; $4E28
    db $00,$00,$01,$00,$00,$00,$00,$09,$01,$0D,$04,$07,$09,$06,$06,$02,$06,$06,$00,$00   ; $4E3C
    db $00,$00,$01,$00,$00,$00,$00,$01,$07,$07,$00,$00,$06,$06,$06,$00,$00,$00,$00,$00   ; $4E50
Bank25_MMTilemap_09:  ; $4E64-$4F67  (13 rows x 20)
    db $00,$00,$01,$00,$00,$07,$07,$01,$00,$00,$06,$06,$06,$00,$00,$00,$00,$00,$00,$00   ; $4E64
    db $00,$00,$01,$00,$00,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $4E78
    db $00,$00,$01,$00,$00,$07,$00,$06,$0A,$08,$0A,$00,$00,$09,$08,$02,$06,$06,$06,$03   ; $4E8C
    db $00,$00,$01,$00,$00,$0C,$06,$0A,$01,$08,$0A,$00,$00,$00,$08,$02,$06,$06,$06,$03   ; $4EA0
    db $00,$00,$01,$00,$00,$05,$04,$01,$01,$08,$06,$01,$01,$01,$08,$00,$00,$06,$03,$00   ; $4EB4
    db $00,$00,$01,$00,$00,$0C,$06,$06,$01,$00,$06,$00,$00,$01,$05,$00,$00,$00,$06,$03   ; $4EC8
    db $00,$00,$01,$00,$00,$0C,$0B,$03,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $4EDC
    db $00,$00,$01,$00,$00,$05,$00,$09,$00,$00,$0A,$01,$09,$00,$00,$02,$06,$06,$00,$00   ; $4EF0
    db $00,$00,$01,$00,$00,$05,$00,$02,$0A,$08,$06,$0A,$07,$0C,$08,$00,$00,$00,$00,$00   ; $4F04
    db $00,$00,$01,$00,$00,$05,$00,$09,$01,$08,$0A,$01,$0B,$06,$03,$02,$06,$03,$00,$00   ; $4F18
    db $00,$00,$01,$00,$00,$05,$04,$08,$00,$00,$06,$06,$0D,$07,$05,$00,$00,$06,$06,$03   ; $4F2C
    db $00,$00,$01,$00,$00,$0C,$06,$0A,$00,$00,$0A,$07,$0C,$00,$00,$02,$06,$06,$00,$00   ; $4F40
    db $00,$00,$01,$00,$00,$07,$07,$01,$00,$00,$06,$06,$06,$00,$00,$00,$00,$00,$00,$00   ; $4F54
Bank25_MMTilemap_0A:  ; $4F68-$506B  (13 rows x 20)
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $4F68
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $4F7C
    db $00,$00,$01,$00,$00,$00,$01,$06,$00,$00,$00,$01,$00,$00,$00,$00,$06,$01,$00,$00   ; $4F90
    db $00,$00,$01,$00,$00,$09,$06,$06,$00,$00,$09,$00,$00,$00,$00,$02,$06,$01,$06,$00   ; $4FA4
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$01,$08,$00,$00,$01,$06,$03   ; $4FB8
    db $00,$00,$01,$00,$00,$09,$01,$01,$00,$00,$02,$06,$01,$01,$08,$00,$00,$01,$06,$03   ; $4FCC
    db $00,$00,$01,$00,$00,$09,$0B,$06,$0A,$08,$09,$08,$00,$09,$08,$02,$06,$01,$06,$03   ; $4FE0
    db $00,$00,$01,$00,$00,$00,$00,$09,$08,$00,$00,$09,$0B,$03,$00,$00,$02,$0D,$00,$00   ; $4FF4
    db $00,$00,$01,$00,$00,$00,$00,$02,$01,$08,$00,$00,$00,$01,$08,$00,$00,$0C,$06,$03   ; $5008
    db $00,$00,$01,$00,$00,$00,$00,$09,$0D,$00,$09,$0D,$00,$01,$08,$00,$06,$01,$06,$03   ; $501C
    db $00,$00,$01,$00,$00,$09,$06,$01,$06,$08,$09,$05,$01,$04,$08,$02,$03,$01,$02,$03   ; $5030
    db $00,$00,$01,$00,$00,$09,$01,$08,$00,$00,$00,$02,$0A,$01,$00,$00,$00,$0C,$03,$00   ; $5044
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $5058
Bank25_MMTilemap_0B:  ; $506C-$516F  (13 rows x 20)
    db $00,$00,$01,$00,$00,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $506C
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$06,$00,$00   ; $5080
    db $00,$00,$01,$00,$00,$09,$06,$06,$00,$00,$09,$07,$07,$07,$05,$02,$06,$06,$06,$03   ; $5094
    db $00,$00,$01,$00,$00,$00,$00,$06,$06,$08,$00,$00,$00,$00,$08,$00,$00,$00,$00,$03   ; $50A8
    db $00,$00,$01,$00,$00,$04,$07,$01,$01,$08,$09,$01,$0B,$06,$03,$00,$00,$00,$00,$00   ; $50BC
    db $00,$00,$01,$00,$00,$09,$01,$0B,$06,$08,$09,$00,$00,$00,$08,$02,$06,$06,$06,$03   ; $50D0
    db $00,$00,$01,$00,$00,$00,$01,$08,$00,$00,$00,$06,$03,$00,$00,$00,$00,$00,$00,$00   ; $50E4
    db $00,$00,$01,$00,$00,$00,$00,$09,$0D,$05,$09,$0D,$00,$01,$08,$00,$06,$06,$03,$00   ; $50F8
    db $00,$00,$01,$00,$00,$00,$04,$08,$00,$00,$04,$0C,$0D,$0C,$08,$02,$06,$00,$00,$00   ; $510C
    db $00,$00,$01,$00,$00,$00,$00,$09,$01,$00,$00,$09,$01,$06,$00,$00,$02,$06,$00,$00   ; $5120
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5134
    db $00,$00,$01,$00,$00,$09,$01,$08,$04,$08,$09,$03,$0A,$01,$08,$00,$00,$00,$06,$00   ; $5148
    db $00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$06,$00,$00   ; $515C
Bank25_MMTilemap_0C:  ; $5170-$5273  (13 rows x 20)
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5170
    db $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $5184
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$08,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $5198
    db $00,$00,$00,$00,$00,$09,$06,$06,$06,$08,$09,$00,$00,$04,$08,$02,$06,$01,$02,$03   ; $51AC
    db $00,$00,$00,$00,$00,$09,$01,$0B,$06,$08,$09,$00,$00,$07,$08,$02,$06,$01,$06,$03   ; $51C0
    db $00,$00,$00,$00,$00,$09,$01,$01,$00,$00,$00,$00,$09,$00,$00,$00,$00,$0C,$00,$00   ; $51D4
    db $00,$00,$00,$00,$00,$00,$01,$06,$06,$03,$09,$01,$05,$00,$00,$00,$02,$0D,$00,$00   ; $51E8
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $51FC
    db $00,$00,$00,$00,$00,$00,$00,$01,$08,$00,$00,$00,$0A,$01,$08,$00,$00,$0C,$06,$03   ; $5210
    db $00,$00,$00,$00,$00,$00,$00,$01,$06,$08,$00,$00,$00,$04,$08,$00,$00,$0C,$06,$00   ; $5224
    db $00,$00,$00,$00,$00,$00,$09,$01,$01,$00,$00,$02,$0A,$06,$00,$00,$00,$0C,$00,$00   ; $5238
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$08,$02,$08,$00,$09,$03,$00,$06,$01,$06,$00   ; $524C
    db $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00   ; $5260
Bank25_MMTilemap_0D:  ; $5274-$5377  (13 rows x 20)
    db $00,$00,$00,$00,$00,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5274
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$05,$06,$06,$06,$06,$03,$00,$00,$00,$00,$00   ; $5288
    db $00,$00,$00,$00,$00,$07,$01,$06,$06,$08,$03,$00,$00,$00,$08,$00,$06,$06,$06,$03   ; $529C
    db $00,$00,$00,$00,$00,$05,$00,$09,$06,$08,$06,$0A,$01,$00,$08,$00,$02,$06,$06,$03   ; $52B0
    db $00,$00,$00,$00,$00,$07,$07,$0C,$01,$08,$06,$06,$01,$01,$08,$00,$00,$06,$03,$00   ; $52C4
    db $00,$00,$00,$00,$00,$05,$09,$01,$06,$08,$06,$01,$08,$04,$08,$00,$02,$06,$06,$03   ; $52D8
    db $00,$00,$00,$00,$00,$05,$00,$04,$01,$08,$0A,$0D,$01,$06,$03,$00,$06,$00,$00,$00   ; $52EC
    db $00,$00,$00,$00,$00,$07,$07,$00,$00,$00,$06,$06,$00,$00,$00,$00,$00,$00,$00,$00   ; $5300
    db $00,$00,$00,$00,$00,$05,$00,$01,$01,$08,$0A,$01,$08,$00,$00,$02,$06,$03,$00,$00   ; $5314
    db $00,$00,$00,$00,$00,$0C,$06,$06,$0A,$08,$0A,$07,$05,$00,$00,$00,$06,$06,$06,$03   ; $5328
    db $00,$00,$00,$00,$00,$07,$01,$0D,$00,$00,$03,$01,$01,$00,$00,$00,$02,$03,$00,$00   ; $533C
    db $00,$00,$00,$00,$00,$05,$09,$01,$01,$00,$0A,$09,$02,$06,$00,$02,$06,$00,$00,$00   ; $5350
    db $00,$00,$00,$00,$00,$07,$07,$07,$07,$05,$06,$06,$06,$06,$03,$00,$00,$00,$00,$00   ; $5364
Bank25_MMTilemap_0E:  ; $5378-$547B  (13 rows x 20)
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $5378
    db $00,$00,$00,$00,$00,$04,$07,$07,$07,$07,$02,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $538C
    db $00,$00,$00,$00,$00,$09,$01,$07,$07,$07,$09,$01,$06,$06,$06,$02,$06,$00,$00,$00   ; $53A0
    db $00,$00,$00,$00,$00,$09,$06,$0A,$08,$04,$09,$00,$00,$00,$0B,$02,$06,$06,$06,$03   ; $53B4
    db $00,$00,$00,$00,$00,$00,$09,$01,$01,$07,$04,$0C,$09,$0B,$06,$02,$06,$06,$03,$00   ; $53C8
    db $00,$00,$00,$00,$00,$09,$01,$09,$01,$0D,$02,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $53DC
    db $00,$00,$00,$00,$00,$00,$01,$08,$00,$04,$00,$06,$01,$0C,$0B,$00,$00,$00,$06,$00   ; $53F0
    db $00,$00,$00,$00,$00,$00,$00,$00,$07,$07,$00,$00,$00,$06,$06,$00,$00,$00,$00,$00   ; $5404
    db $00,$00,$00,$00,$00,$00,$04,$0C,$01,$0D,$00,$09,$01,$00,$02,$00,$00,$00,$00,$00   ; $5418
    db $00,$00,$00,$00,$00,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $542C
    db $00,$00,$00,$00,$00,$09,$0B,$01,$04,$07,$09,$08,$01,$09,$06,$00,$00,$06,$06,$00   ; $5440
    db $00,$00,$00,$00,$00,$00,$0C,$01,$0D,$07,$00,$0A,$01,$0B,$02,$00,$00,$06,$00,$00   ; $5454
    db $00,$00,$00,$00,$00,$04,$07,$07,$07,$07,$02,$06,$06,$06,$06,$00,$00,$00,$00,$00   ; $5468
Bank25_MMTilemap_0F:  ; $547C-$557F  (13 rows x 20)
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $547C
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5490
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $54A4
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $54B8
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $54CC
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $54E0
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $54F4
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5508
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $551C
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5530
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5544
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $5558
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; $556C
Bank25_MMTilemapAlt_00:  ; $5580-$5697  (14 rows x 20)
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; $5580
    db $0C,$01,$01,$01,$0D,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0A,$01,$01,$01,$0B   ; $5594
    db $07,$07,$01,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; $55A8
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$01,$01,$01,$01,$08   ; $55BC
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$01,$06,$06   ; $55D0
    db $09,$01,$01,$01,$01,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $55E4
    db $0C,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; $55F8
    db $01,$01,$01,$01,$0D,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; $560C
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0B   ; $5620
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0A,$01,$01,$01,$01   ; $5634
    db $04,$07,$01,$07,$07,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $5648
    db $07,$07,$01,$07,$05,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$01,$01,$01,$01,$08   ; $565C
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$06,$06,$01,$06,$03   ; $5670
    db $09,$01,$01,$01,$01,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$02,$06,$01,$06,$06   ; $5684
Bank25_MMTilemapAlt_01:  ; $5698-$5723  (7 rows x 20)
    db $07,$07,$07,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01   ; $5698
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$01,$01,$01,$01,$08   ; $56AC
    db $07,$07,$07,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$01,$06,$06   ; $56C0
    db $04,$07,$07,$07,$07,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $56D4
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$0A,$01,$01,$01,$08   ; $56E8
    db $04,$07,$07,$07,$07,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$09,$01,$01,$01,$0B   ; $56FC
    db $07,$07,$07,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0A,$01,$01,$01,$0B   ; $5710
Bank25_MMTilemapAlt_02:  ; $5724-$57AF  (7 rows x 20)
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$06,$06,$06   ; $5724
    db $07,$07,$01,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$06,$06,$06   ; $5738
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$06,$06,$06,$06,$03   ; $574C
    db $09,$01,$01,$01,$01,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $5760
    db $0C,$01,$01,$01,$08,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$06,$06,$06,$06,$03   ; $5774
    db $09,$01,$01,$01,$0D,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $5788
    db $0C,$01,$01,$01,$0D,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$06,$06,$06   ; $579C
Bank25_MMTilemapAlt_03:  ; $57B0-$583B  (7 rows x 20)
    db $09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $57B0
    db $04,$07,$01,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $57C4
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$09,$01,$01,$01,$08   ; $57D8
    db $09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$01,$06,$06   ; $57EC
    db $04,$07,$01,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$0B   ; $5800
    db $09,$01,$01,$01,$0D,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$01,$06,$06   ; $5814
    db $09,$01,$01,$01,$0D,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$0B   ; $5828
Bank25_MMTilemapAlt_04:  ; $583C-$58C7  (7 rows x 20)
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08   ; $583C
    db $07,$07,$01,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08   ; $5850
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$01,$06,$03   ; $5864
    db $09,$01,$01,$01,$08,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$09,$01,$01,$01,$08   ; $5878
    db $07,$07,$01,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$0A,$01,$01,$01,$08   ; $588C
    db $0C,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$01,$06,$03   ; $58A0
    db $0C,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$0A,$01,$01,$01,$08   ; $58B4
Bank25_MMTilemapAlt_05:  ; $58C8-$5917  (4 rows x 20)
    db $07,$07,$07,$07,$07,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$06,$06,$06   ; $58C8
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$0D,$01,$01,$01,$01,$0B,$06,$06,$06,$06,$03   ; $58DC
    db $04,$07,$07,$07,$07,$0C,$01,$01,$01,$01,$0A,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $58F0
    db $04,$07,$07,$07,$05,$0C,$01,$01,$01,$0D,$0A,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $5904
Bank25_MMTilemapAlt_06:  ; $5918-$597B  (5 rows x 20)
    db $04,$07,$07,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01   ; $5918
    db $04,$07,$07,$07,$05,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$09,$01,$01,$01,$08   ; $592C
    db $04,$07,$07,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$01,$06,$06   ; $5940
    db $04,$07,$07,$07,$05,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$01,$06,$03   ; $5954
    db $04,$07,$07,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$0B   ; $5968
Bank25_MMTilemapAlt_07:  ; $597C-$59DF  (5 rows x 20)
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08   ; $597C
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$01,$06,$03   ; $5990
    db $04,$07,$07,$07,$05,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$09,$01,$01,$01,$08   ; $59A4
    db $04,$07,$07,$07,$05,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $59B8
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$0A,$01,$01,$01,$08   ; $59CC
Bank25_MMTilemapAlt_08:  ; $59E0-$5A43  (5 rows x 20)
    db $09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $59E0
    db $04,$07,$01,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $59F4
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $5A08
    db $04,$07,$01,$07,$05,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $5A1C
    db $09,$01,$01,$01,$0D,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $5A30
Bank25_MMTilemapAlt_09:  ; $5A44-$5AA7  (5 rows x 20)
    db $01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$06,$06,$03   ; $5A44
    db $07,$07,$01,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$06,$06,$03   ; $5A58
    db $09,$01,$01,$01,$08,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5A6C
    db $04,$07,$01,$07,$05,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5A80
    db $0C,$01,$01,$01,$08,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$06,$06,$03   ; $5A94
Bank25_MMTilemapAlt_0A:  ; $5AA8-$5AF7  (4 rows x 20)
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08   ; $5AA8
    db $04,$07,$01,$07,$05,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08   ; $5ABC
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5AD0
    db $04,$07,$01,$07,$05,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5AE4
Bank25_MMTilemapAlt_0B:  ; $5AF8-$5B33  (3 rows x 20)
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5AF8
    db $04,$07,$01,$07,$05,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5B0C
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5B20
Bank25_MMTilemapAlt_0C:  ; $5B34-$5B6F  (3 rows x 20)
    db $04,$07,$07,$07,$05,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08   ; $5B34
    db $04,$07,$07,$07,$05,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5B48
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5B5C
Bank25_MMTilemapAlt_0D:  ; $5B70-$5BAB  (3 rows x 20)
    db $07,$07,$07,$07,$05,$01,$01,$01,$01,$08,$01,$01,$01,$01,$08,$06,$06,$06,$06,$03   ; $5B70
    db $04,$07,$07,$07,$05,$0C,$01,$01,$01,$08,$0A,$01,$01,$01,$08,$02,$06,$06,$06,$03   ; $5B84
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5B98
Bank25_MMTilemapAlt_0E:  ; $5BAC-$5BE7  (3 rows x 20)
    db $04,$07,$07,$07,$07,$09,$01,$01,$01,$01,$09,$01,$01,$01,$01,$02,$06,$06,$06,$06   ; $5BAC
    db $04,$07,$07,$07,$05,$09,$01,$01,$01,$0D,$09,$01,$01,$01,$0B,$02,$06,$06,$06,$03   ; $5BC0
    db $09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$09,$01,$01,$01,$08,$02,$06,$01,$06,$03   ; $5BD4
