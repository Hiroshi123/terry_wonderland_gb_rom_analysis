; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 15  (Tile movement engine, area types $40+)
; ============================================================================
;
; File offset $3C000-$3FFFF (16 KB); mapped $4000-$7FFF when bank reg = 15.
;
; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.
; Function table at $4001:  fn0 $4007 · fn1 $402F · fn2 $4110.
;   fn0 = READ map cell at coord (collision / event / NPC-text query)
;   fn1 = PAINT cell tile indices into $9800 BG map (scroll-fill)
;   fn2 = PAINT cell CGB attributes into VRAM bank 1 (VBK)
;
; SHARED ENGINE: code $4007-$41B9 is BYTE-FOR-BYTE identical to bank12/13/15
; (only the self-id byte at $4000 differs: $0F here). Full annotation below;
; see overworld/bank12.asm for the same routines under area type 0.
;
; DATA (this bank) = 48 area types ($40-$70). bank4/Sub_71EF ($71EF) routes those
; wAreaType ($D8D3) values here (LD HL,$0F00; RST $10). The $41BA L1 table is
; indexed by the FULL wAreaType: out-of-range rows alias placeholder grid
; $6F74; the 48 real rows are $40-$70.
;
; TEXT REFERENCES: a cell value with high byte != $FF is a GLOBAL MESSAGE ID,
; routed by ROM0 MsgBankRouter ($0EC5) to dialogue banks 66-78 (local msg =
; global_id - bank_base; bank66 base $0000, 67 $00E2, 68 $0198, 69 $0244,
; 70 $0300, 71 $03C8, 72 $0474, 73 $0512, 74 $05E0, 75 $072B, 78 $07D3).
; $FFxx cells = behavior opcodes (lo -> bank4 TileBehaviorTable $5620):
;   $FF01 <flag> <ptr>       : IF event-flag SET -> branch to <ptr> else next
;   $FF15 <addr> <val> <ptr> : IF WRAM[addr]==val -> <ptr> (Yes/No via $C83C)
; See overworld/bank13.asm for decoded worked examples of these grids.
; ============================================================================

SECTION "Bank 15 Functions", ROMX[$4000], BANK[15]

    db $0F                        ; $4000  self-id byte (bank number)
    dw $4007, $402F, $4110        ; $4001  function pointer table (fn0/fn1/fn2)

; ------------------------------------------------------------
; Bank15_Fn0/Fn1/Fn2 — shared map engine (identical to bank12 code)
; ------------------------------------------------------------
Bank15_Fn0:                                 ; $4007
    LD A,($D8D3)                  ; $4007  [FA D3 D8]  ; A = wAreaType ($D8D3)
    LD L,A                        ; $400A  [6F]
    LD H,$00                      ; $400B  [26 00]
    ADD HL,HL                     ; $400D  [29]  ; *2 (word index)
    LD DE,$41BA                   ; $400E  [11 BA 41]  ; DE = area-type map-data ptr table ($41BA)
    ADD HL,DE                     ; $4011  [19]  ; HL = &$41BA[areaType]
    LD E,(HL)                     ; $4012  [5E]  ; DE = table[areaType]  (level-1 ptr: this area's section table)
    INC HL                        ; $4013  [23]
    LD D,(HL)                     ; $4014  [56]
    LD A,($D8D4)                  ; $4015  [FA D4 D8]  ; A = $D8D4 (map section / sub-area index)
    LD L,A                        ; $4018  [6F]
    LD H,$00                      ; $4019  [26 00]
    ADD HL,HL                     ; $401B  [29]
    ADD HL,DE                     ; $401C  [19]  ; HL = &section_table[$D8D4]
    LD E,(HL)                     ; $401D  [5E]  ; DE = table[section]  (level-2 ptr: this section's cell grid)
    INC HL                        ; $401E  [23]
    LD D,(HL)                     ; $401F  [56]
    LD A,($D8D5)                  ; $4020  [FA D5 D8]  ; HL = $D8D6:$D8D5  (16-bit map COORDINATE)
    LD L,A                        ; $4023  [6F]
    LD A,($D8D6)                  ; $4024  [FA D6 D8]
    LD H,A                        ; $4027  [67]
    ADD HL,HL                     ; $4028  [29]  ; *2 (word cells)
    ADD HL,DE                     ; $4029  [19]  ; HL = &cellgrid[coord]
    LD C,(HL)                     ; $402A  [4E]  ; C = cell lo
    INC HL                        ; $402B  [23]
    LD B,(HL)                     ; $402C  [46]  ; B = cell hi
    DEC HL                        ; $402D  [2B]  ; HL -> the cell (BC = its 16-bit value)
    RET                           ; $402E  [C9]


; ============================================================================
; The two painters below share one prologue (VRAM address setup, $402F/$4110
; are byte-identical up to $405D). They are the SCROLL-FILL counterparts of
; fn0: as the world scrolls, fn0 READS a map cell; fn1/fn2 RENDER the cell's
; graphics into VRAM one column at a time.
;
; PROLOGUE — compute the destination BG-map address in VRAM ($9800 map):
;   $FFB7 = camera pixel X, $FFBB = camera pixel Y.
;   AND $F8 snaps each to an 8-px tile boundary.
;   HL = $9800 + (Y/8)*32 + (X/8)          (32x32 BG tilemap, H kept in $98-$9B)
;     ( Y already *8-aligned, so LD H,0 / ADD HL,HL x2 = Y*4 = (Y/8)*32;
;       X via RRCA x3 = X/8 added into the low byte )
;   -> saved to $D8E7:$D8E8 = "current VRAM write pointer".
; Then bump the map coord ($D8D6:$D8D5 += 1) and call fn0 ($4007) to fetch the
; NEXT cell (BC -> its cell value = pointer into the metatile/attr source).
; ------------------------------------------------------------
; Bank15_Fn1  ($402F)  — paint a cell's TILE INDICES into the BG tilemap
; ------------------------------------------------------------
; VRAM bank 0 ($9800 map). Walks the cell's tile stream via Sub_40E7, then the
; blit loop at $407B writes tile bytes with LD (HL+),A, wrapping every 32 cols
; (AND $1F) and stepping to the next map row on the $D8 marker (+$20); $D9 ends.
; This is the metatile -> screen tilemap expansion for one scrolled-in column.
; ------------------------------------------------------------
Bank15_Fn1:                                 ; $402F
    LD HL,$FFB7                   ; $402F  [21 B7 FF]  ; camera pixel X
    LD A,(HL)                     ; $4032  [7E]
    AND $F8                       ; $4033  [E6 F8]  ; snap X to tile (clear low 3 px)
    LD (HL),A                     ; $4035  [77]
    LD HL,$FFBB                   ; $4036  [21 BB FF]  ; camera pixel Y
    LD A,(HL)                     ; $4039  [7E]
    AND $F8                       ; $403A  [E6 F8]  ; snap Y to tile
    LD (HL),A                     ; $403C  [77]
    LDH A,($BB)                   ; $403D  [F0 BB]  ; --- build $9800 map address ---
    LD L,A                        ; $403F  [6F]
    LD H,$00                      ; $4040  [26 00]
    ADD HL,HL                     ; $4042  [29]  ; HL = Y*4 = (Y/8)*32  (row offset)
    ADD HL,HL                     ; $4043  [29]
    LDH A,($B7)                   ; $4044  [F0 B7]
    RRCA                          ; $4046  [0F]  ; X/8 (col), low 3 bits were 0
    RRCA                          ; $4047  [0F]
    RRCA                          ; $4048  [0F]
    ADD A,L                       ; $4049  [85]  ; + col
    LD L,A                        ; $404A  [6F]
    LD A,H                        ; $404B  [7C]
    ADC A,$98                     ; $404C  [CE 98]  ; base $9800
    LD H,A                        ; $404E  [67]
    LD A,H                        ; $404F  [7C]
    AND $03                       ; $4050  [E6 03]  ; keep H in $98-$9B (32-row wrap)
    OR $98                        ; $4052  [F6 98]
    LD H,A                        ; $4054  [67]
    LD A,L                        ; $4055  [7D]
    LD ($D8E7),A                  ; $4056  [EA E7 D8]  ; save VRAM write ptr lo
    LD A,H                        ; $4059  [7C]
    LD ($D8E8),A                  ; $405A  [EA E8 D8]  ; save VRAM write ptr hi
    LD A,($D8D5)                  ; $405D  [FA D5 D8]  ; map coord += 1 (advance to next cell)
    ADD A,$01                     ; $4060  [C6 01]
    LD ($D8D5),A                  ; $4062  [EA D5 D8]
    LD A,($D8D6)                  ; $4065  [FA D6 D8]
    ADC A,$00                     ; $4068  [CE 00]
    LD ($D8D6),A                  ; $406A  [EA D6 D8]
    CALL $4007                    ; $406D  [CD 07 40]  ; fn0: fetch that cell -> BC = cell value
    PUSH BC                       ; $4070  [C5]
    CALL $40E7                    ; $4071  [CD E7 40]  ; Sub_40E7: pre-walk the tile stream
    POP BC                        ; $4074  [C1]
    LD A,(BC)                     ; $4075  [0A]  ; ---- blit entry (also reused by fn2 tail) ----
    LD L,A                        ; $4076  [6F]  ; BC -> metatile tile-list; L = first tile
    INC BC                        ; $4077  [03]
    LD A,(BC)                     ; $4078  [0A]
    LD H,A                        ; $4079  [67]
    INC BC                        ; $407A  [03]
Bank15_Fn1_Blit:                            ; $407B
    PUSH BC                       ; $407B  [C5]
    LD B,L                        ; $407C  [45]
    LD A,L                        ; $407D  [7D]
    AND $E0                       ; $407E  [E6 E0]  ; row-part of the map offset (col bits cleared)
    LD L,A                        ; $4080  [6F]
    LD A,($D8E7)                  ; $4081  [FA E7 D8]  ; + current VRAM write ptr
    ADD A,L                       ; $4084  [85]
    LD L,A                        ; $4085  [6F]
    LD A,($D8E8)                  ; $4086  [FA E8 D8]
    ADC A,H                       ; $4089  [8C]
    AND $03                       ; $408A  [E6 03]  ; wrap H into $98-$9B
    LD H,A                        ; $408C  [67]
    LD A,($D8E8)                  ; $408D  [FA E8 D8]
    AND $FC                       ; $4090  [E6 FC]
    OR H                          ; $4092  [B4]
    LD H,A                        ; $4093  [67]
    LD A,B                        ; $4094  [78]
    AND $1F                       ; $4095  [E6 1F]  ; column within 32-wide map
    JR Z,$40A0                    ; $4097  [28 07]
    LD B,A                        ; $4099  [47]
    CALL $40DA                    ; $409A  [CD DA 40]  ; Sub_40DA: advance L one col (mod 32)
    DEC B                         ; $409D  [05]
    JR NZ,$409A                   ; $409E  [20 FA]
    LD A,L                        ; $40A0  [7D]  ; commit adjusted ptr back
    LD ($D8E7),A                  ; $40A1  [EA E7 D8]
    LD A,H                        ; $40A4  [7C]
    LD ($D8E8),A                  ; $40A5  [EA E8 D8]
    POP BC                        ; $40A8  [C1]
Bank15_Fn1_Emit:                            ; $40A9
    LD A,(BC)                     ; $40A9  [0A]  ; next byte of tile stream
    INC BC                        ; $40AA  [03]
    CP $D9                        ; $40AB  [FE D9]  ; $D9 = end of cell
    RET Z                         ; $40AD  [C8]
    CP $D8                        ; $40AE  [FE D8]  ; $D8 = next row (advance VRAM ptr +$20)
    JR NZ,$40D2                   ; $40B0  [20 20]
    LD A,($D8E7)                  ; $40B2  [FA E7 D8]  ; VRAM ptr += 32 (down one tilemap row)
    LD L,A                        ; $40B5  [6F]
    LD A,($D8E8)                  ; $40B6  [FA E8 D8]
    LD H,A                        ; $40B9  [67]
    LD A,L                        ; $40BA  [7D]
    ADD A,$20                     ; $40BB  [C6 20]
    LD L,A                        ; $40BD  [6F]
    LD A,H                        ; $40BE  [7C]
    ADC A,$00                     ; $40BF  [CE 00]
    LD H,A                        ; $40C1  [67]
    LD A,H                        ; $40C2  [7C]
    AND $03                       ; $40C3  [E6 03]  ; keep in $98-$9B
    OR $98                        ; $40C5  [F6 98]
    LD H,A                        ; $40C7  [67]
    LD A,L                        ; $40C8  [7D]
    LD ($D8E7),A                  ; $40C9  [EA E7 D8]
    LD A,H                        ; $40CC  [7C]
    LD ($D8E8),A                  ; $40CD  [EA E8 D8]
    JR $40A9                      ; $40D0  [18 D7]
    CALL $1E80                    ; $40D2  [CD 80 1E]  ; ROM0 helper: write tile A to VRAM (VBK-safe)
    CALL $40DA                    ; $40D5  [CD DA 40]  ; advance VRAM col ptr (mod 32)
    JR $40A9                      ; $40D8  [18 CF]
Bank15_Sub_40DA:                            ; $40DA  — advance L by one column, wrap within 32
    LD A,L                        ; $40DA  [7D]
    AND $E0                       ; $40DB  [E6 E0]  ; keep row bits
    PUSH AF                       ; $40DD  [F5]
    LD A,L                        ; $40DE  [7D]
    INC A                         ; $40DF  [3C]
    AND $1F                       ; $40E0  [E6 1F]  ; (col+1) mod 32
    LD L,A                        ; $40E2  [6F]
    POP AF                        ; $40E3  [F1]
    OR L                          ; $40E4  [B5]  ; recombine row|col
    LD L,A                        ; $40E5  [6F]
    RET                           ; $40E6  [C9]

; ------------------------------------------------------------
; Bank15_Sub_40E7  — walk a cell's TILE stream into a WRAM $C300 buffer
; ------------------------------------------------------------
; Reads cell ptr from (BC): a 16-bit index, +$C300 base -> WRAM tile-list
; source. Copies the tile bytes with LD (HL+),A until $D9; $D8 = next-row (+$20).
; Fills the shadow the blit loop then pushes to VRAM.
; ------------------------------------------------------------
Bank15_Sub_40E7:                            ; $40E7
    LD A,(BC)                     ; $40E7  [0A]
    LD L,A                        ; $40E8  [6F]
    INC BC                        ; $40E9  [03]
    LD A,(BC)                     ; $40EA  [0A]
    LD H,A                        ; $40EB  [67]
    INC BC                        ; $40EC  [03]
    LD A,L                        ; $40ED  [7D]
    ADD A,$00                     ; $40EE  [C6 00]
    LD L,A                        ; $40F0  [6F]
    LD A,H                        ; $40F1  [7C]
    ADC A,$C3                     ; $40F2  [CE C3]  ; base $C300 (WRAM tile-list source)
    LD H,A                        ; $40F4  [67]
    PUSH HL                       ; $40F5  [E5]
    LD A,(BC)                     ; $40F6  [0A]
    INC BC                        ; $40F7  [03]
    CP $D9                        ; $40F8  [FE D9]  ; end
    JR Z,$410E                    ; $40FA  [28 12]
    CP $D8                        ; $40FC  [FE D8]  ; next row
    JR NZ,$410B                   ; $40FE  [20 0B]
    POP HL                        ; $4100  [E1]
    LD A,L                        ; $4101  [7D]
    ADD A,$20                     ; $4102  [C6 20]  ; +32
    LD L,A                        ; $4104  [6F]
    LD A,H                        ; $4105  [7C]
    ADC A,$00                     ; $4106  [CE 00]
    LD H,A                        ; $4108  [67]
    JR $40F5                      ; $4109  [18 EA]
    LD (HL+),A                    ; $410B  [22]  ; store tile byte
    JR $40F6                      ; $410C  [18 E8]
    POP HL                        ; $410E  [E1]
    RET                           ; $410F  [C9]


; ------------------------------------------------------------
; Bank15_Fn2  ($4110)  — paint a cell's CGB ATTRIBUTES into VRAM bank 1
; ------------------------------------------------------------
; Same prologue as fn1 (byte-identical), so it targets the SAME BG-map cell.
; Difference: it builds the per-tile CGB attribute bytes (palette/priority/
; bank/flip) via Sub_4171/Sub_4195 (source base $C200, packed as nibbles), then
; the tail flips VRAM bank via VBK ($FF4F=1), reuses the fn1 blit loop ($4075)
; to write into the attribute map, and restores VBK 0. Only runs when the
; CGB-attribute-dirty flag $C81D is set. fn1 = tiles, fn2 = colour attributes.
; ------------------------------------------------------------
Bank15_Fn2:                                 ; $4110
    LD HL,$FFB7                   ; $4110  [21 B7 FF]  ; (prologue identical to fn1 — see $402F)
    LD A,(HL)                     ; $4113  [7E]
    AND $F8                       ; $4114  [E6 F8]
    LD (HL),A                     ; $4116  [77]
    LD HL,$FFBB                   ; $4117  [21 BB FF]
    LD A,(HL)                     ; $411A  [7E]
    AND $F8                       ; $411B  [E6 F8]
    LD (HL),A                     ; $411D  [77]
    LDH A,($BB)                   ; $411E  [F0 BB]
    LD L,A                        ; $4120  [6F]
    LD H,$00                      ; $4121  [26 00]
    ADD HL,HL                     ; $4123  [29]
    ADD HL,HL                     ; $4124  [29]
    LDH A,($B7)                   ; $4125  [F0 B7]
    RRCA                          ; $4127  [0F]
    RRCA                          ; $4128  [0F]
    RRCA                          ; $4129  [0F]
    ADD A,L                       ; $412A  [85]
    LD L,A                        ; $412B  [6F]
    LD A,H                        ; $412C  [7C]
    ADC A,$98                     ; $412D  [CE 98]
    LD H,A                        ; $412F  [67]
    LD A,H                        ; $4130  [7C]
    AND $03                       ; $4131  [E6 03]
    OR $98                        ; $4133  [F6 98]
    LD H,A                        ; $4135  [67]
    LD A,L                        ; $4136  [7D]
    LD ($D8E7),A                  ; $4137  [EA E7 D8]
    LD A,H                        ; $413A  [7C]
    LD ($D8E8),A                  ; $413B  [EA E8 D8]
    LD A,($D8D5)                  ; $413E  [FA D5 D8]  ; map coord += 1
    ADD A,$01                     ; $4141  [C6 01]
    LD ($D8D5),A                  ; $4143  [EA D5 D8]
    LD A,($D8D6)                  ; $4146  [FA D6 D8]
    ADC A,$00                     ; $4149  [CE 00]
    LD ($D8D6),A                  ; $414B  [EA D6 D8]
    CALL $4007                    ; $414E  [CD 07 40]  ; fn0: fetch the cell -> BC
    PUSH BC                       ; $4151  [C5]
    CALL $4171                    ; $4152  [CD 71 41]  ; Sub_4171: build attr nibbles into $C200 buf
    POP BC                        ; $4155  [C1]
    LD A,($C81D)                  ; $4156  [FA 1D C8]  ; CGB attribute-dirty flag
    OR A                          ; $4159  [B7]
    RET Z                         ; $415A  [C8]  ; nothing to redraw
    DI                            ; $415B  [F3]
    CALL $1E79                    ; $415C  [CD 79 1E]  ; ROM0: wait for VRAM-accessible window
    LD A,$01                      ; $415F  [3E 01]
    LDH ($4F),A                   ; $4161  [E0 4F]  ; VBK=1 -> CGB BG attribute map
    EI                            ; $4163  [FB]
    CALL $4075                    ; $4164  [CD 75 40]  ; reuse fn1 blit loop -> writes attr bytes
    DI                            ; $4167  [F3]
    CALL $1E79                    ; $4168  [CD 79 1E]
    LD A,$00                      ; $416B  [3E 00]
    LDH ($4F),A                   ; $416D  [E0 4F]  ; VBK=0 -> back to tile map
    EI                            ; $416F  [FB]
    RET                           ; $4170  [C9]

; ------------------------------------------------------------
; Bank15_Sub_4171  — walk a cell's ATTRIBUTE stream into the $C200 nibble buf
; ------------------------------------------------------------
; Like Sub_40E7 but each cell entry updates a packed 4-bit attribute via
; Sub_4195: address >>1 selects a byte in the $C200 table, carry (odd/even)
; selects high vs low nibble, and the new value is merged in. $D8=next row,
; $D9=end. This produces the compact per-tile CGB attributes fn2 then blits.
; ------------------------------------------------------------
Bank15_Sub_4171:                            ; $4171
    LD A,(BC)                     ; $4171  [0A]
    LD L,A                        ; $4172  [6F]
    INC BC                        ; $4173  [03]
    LD A,(BC)                     ; $4174  [0A]
    LD H,A                        ; $4175  [67]
    INC BC                        ; $4176  [03]
    PUSH HL                       ; $4177  [E5]
    LD A,(BC)                     ; $4178  [0A]
    INC BC                        ; $4179  [03]
    CP $D9                        ; $417A  [FE D9]  ; end
    JR Z,$4193                    ; $417C  [28 15]
    CP $D8                        ; $417E  [FE D8]  ; next row (+$20)
    JR NZ,$418D                   ; $4180  [20 0B]
    POP HL                        ; $4182  [E1]
    LD A,L                        ; $4183  [7D]
    ADD A,$20                     ; $4184  [C6 20]
    LD L,A                        ; $4186  [6F]
    LD A,H                        ; $4187  [7C]
    ADC A,$00                     ; $4188  [CE 00]
    LD H,A                        ; $418A  [67]
    JR $4177                      ; $418B  [18 EA]
    CALL $4195                    ; $418D  [CD 95 41]  ; merge one attr nibble
    INC HL                        ; $4190  [23]
    JR $4178                      ; $4191  [18 E5]
    POP HL                        ; $4193  [E1]
    RET                           ; $4194  [C9]
Bank15_Sub_4195:                            ; $4195  — merge attr value A into $C200[HL/2] nibble
    PUSH HL                       ; $4195  [E5]
    SRL H                         ; $4196  [CB 3C]  ; HL /= 2  (2 tiles per byte)
    RR L                          ; $4198  [CB 1D]
    PUSH AF                       ; $419A  [F5]
    LD A,L                        ; $419B  [7D]
    ADD A,$00                     ; $419C  [C6 00]
    LD L,A                        ; $419E  [6F]
    LD A,H                        ; $419F  [7C]
    ADC A,$C2                     ; $41A0  [CE C2]  ; base $C200 (attribute nibble buffer)
    LD H,A                        ; $41A2  [67]
    POP AF                        ; $41A3  [F1]
    JR C,$41B0                    ; $41A4  [38 0A]  ; odd address -> low nibble
    SWAP A                        ; $41A6  [CB 37]  ; even -> high nibble
    AND $F0                       ; $41A8  [E6 F0]
    LD D,A                        ; $41AA  [57]
    LD A,(HL)                     ; $41AB  [7E]
    AND $0F                       ; $41AC  [E6 0F]  ; keep other nibble
    JR $41B6                      ; $41AE  [18 06]
    AND $0F                       ; $41B0  [E6 0F]  ; low nibble path
    LD D,A                        ; $41B2  [57]
    LD A,(HL)                     ; $41B3  [7E]
    AND $F0                       ; $41B4  [E6 F0]
    OR D                          ; $41B6  [B2]
    LD (HL),A                     ; $41B7  [77]  ; write merged byte
    POP HL                        ; $41B8  [E1]
    RET                           ; $41B9  [C9]


SECTION "Bank 15 Map Data", ROMX[$41BA], BANK[15]
; ============================================================================
; MAP DATA — 3-level table: L1 wAreaType -> L2 section -> cell grid[coord].
; ============================================================================
Bank15_AreaTypeTable:                       ; $41BA  (L1: wAreaType -> section table, 113 rows)
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $00-$05
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $06-$0B
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $0C-$11
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $12-$17
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $18-$1D
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $1E-$23
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $24-$29
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $2A-$2F
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $30-$35
    dw $6F74,$6F74,$6F74,$6F74,$6F74,$6F74        ; areaType $36-$3B
    dw $6F74,$6F74,$6F74,$6F74,$429C,$431A        ; areaType $3C-$41
    dw $454E,$46CE,$47EE,$4B46,$5048,$5138        ; areaType $42-$47
    dw $52D6,$53AE,$5486,$557C,$5660,$5750        ; areaType $48-$4D
    dw $5846,$5912,$592C,$593E,$59BC,$5A6C        ; areaType $4E-$53
    dw $5A6E,$5A6E,$5A6E,$5A7C,$5A7C,$5A7C        ; areaType $54-$59
    dw $5A7E,$5CB6,$5EEE,$61E2,$6B94,$6F74        ; areaType $5A-$5F
    dw $454E,$5A6C,$5A6C,$5A6C,$5A6C,$454E        ; areaType $60-$65
    dw $454E,$454E,$454E,$454E,$454E,$454E        ; areaType $66-$6B
    dw $454E,$454E,$454E,$454E,$6C34              ; areaType $6C-$70
                                             ;   (out-of-range rows = $6F74 placeholder)

Bank15_Area40_Sections:                     ; $429C  areaType $40  (9 sections)
    dw $42AE,$42BE,$42C2,$42C6,$42D4,$42E2,$42F0,$42FE   ; section $00+
    dw $430C   ; section $08+
Bank15_Area40_Grids:                        ; $42AE-$431A  (108 bytes)
    INCBIN "terry.gbc", $03C2AE, $006C
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $054E -> bank73 #60 : 〈テリー〉は　はりがみを　よんだ。 「いちど　はいると　でられない。 こうかいなき　せんたくを。
;     $054F -> bank73 #61 : 〈テリー〉は　はりがみを　よんだ。 「もとむ！ あかるく　けんこうなかた。
;     $0550 -> bank73 #62 : 「ハーィー！　うちは　もう チャパ　チャパ　ですよ！
;     $0553 -> bank73 #65 : 「おや　おきゃくさん　すきだねー。 でも　もう　だれも　いませんよ。
;     $0551 -> bank73 #63 : 「しゃちょう！　プリンプリンで おうさまきぶん　ですよ！
;     $0554 -> bank73 #66 : 「しゃちょう！　おつよいですね！ でも　もう　だれもいませんです。
;     $0552 -> bank73 #64 : 「あまーい　かおりで ゆっくり　おくつろぎください。
;     $0555 -> bank73 #67 : 「いろんな　とくぎ　もってますね！ でも　もう　だれもいないんです！

Bank15_Area41_Sections:                     ; $431A  areaType $41  (4 sections)
    dw $4322,$4332,$43E6,$449A   ; section $00+
Bank15_Area41_Grids:                        ; $4322-$454E  (556 bytes)
    INCBIN "terry.gbc", $03C322, $022C
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0556 -> bank73 #68 : 「ん[9D]　チャパ　チャパ！ さあ　いくわよん！
;     $009C -> bank66 #156 : 「みたこともない　まものがいても おどろかぬことだ。 「てきに　すきをみせれば それで　すべては　おわり…
;     $0557 -> bank73 #69 : 「ワァォー！ あなた　なかなか　やるわねえ！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0208 -> bank68 #112 : 「ぼくたちはね。　いやなめいれいを されると　はんこうしちゃうんだ。 「じぶんの　せいかくに　あった め…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $055E -> bank73 #76 : わたほ゛う「おっつかれさーん！ たのしかったか？　かえるよー！
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0021 -> bank66 #33 : おう「〈テリー〉よっ！　さっそくだが わしのねがいを　きいてくれ！ おう「ねがい　というのは ほかでもな…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0559 -> bank73 #71 : 「さあ　わたしのむねで ゆっくり　おやすみ、、！
;     $0099 -> bank66 #153 : 「まず　じょうけんを　ゆうりにして ことに　いどむべきでしょう。
;     $055A -> bank73 #72 : 「まあ　よく　あばれたわね。 ほっほっほ、、。
;     $0105 -> bank67 #35 : 「[10]クラスの　さいしゅうせんは じゅくちょうが　あいてだぜ。
;     $055B -> bank73 #73 : わたほ゛う「おっつかれさーん！ たのしかったか？　かえるよー！
;     $055C -> bank73 #74 : 「あまいいきで　ねむらせて、、。 それから　あとは　ォッホッホー！
;     $009B -> bank66 #155 : 「たたかいのきほんは　おのれの じゃくてんを　しることです。
;     $055D -> bank73 #75 : 「あなた　つよいわ！ ああ　ゆめならさめないで、。
;     $0302 -> bank70 #2 : 「それじゃあ　あなた　わたしを つかまえにきた　マスターなの？〔はい/いいえ〕
;     $0558 -> bank73 #70 : わたほ゛う「おっつかれさーん！ たのしかったか？　かえるよー！

Bank15_Area42_Sections:                     ; $454E  areaType $42  (also area types $60, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F)  (19 sections)
    dw $4574,$4584,$458C,$4594,$459C,$45A4,$45AC,$45B4   ; section $00+
    dw $45BC,$45C4,$45CC,$45CC,$45CC,$45CC,$45CC,$45CC   ; section $08+
    dw $45D4,$45E6,$46AA   ; section $10+
Bank15_Area42_Grids:                        ; $4574-$46CE  (346 bytes)
    INCBIN "terry.gbc", $03C574, $015A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0561 -> bank73 #79 : 〈テリー〉は　たからばこを　しらべた。 たからばこは　なんと ミミックだった！ ミミックは　したを ヘラ…
;     $00D5 -> bank66 #213 : 「まあ　あれだな。 せんとうとは　たてになるやつと、 「わたしのような　しゅうさいがいて はじめてなりた…
;     $0562 -> bank73 #80 : ミミックは　したを ヘラヘラさせつづけている。
;     $0563 -> bank73 #81 : 「メエ[9D]　メエ[9D]。 よく　ここまで　これたな。 「その　どりょくは みとめてやろう。 「しか…
;     $00D6 -> bank66 #214 : 「たいりょくのあるやつと いっしょが　いいですな[91]。
;     $00AF -> bank66 #175 : 「スーハー、、。 スーハー、、。 「おちついて　おちついて、、。 あわてない　あわてない、、。
;     $0565 -> bank73 #83 : 「メエ[9D]　メエ[9D]。　こんなにつよい マスターが　いたとは　メエ[9D]！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0406 -> bank71 #62 : 「わたしの　うごくせきぞうは ぱふぱふが　つかえるのよ！ 「ぱふぱふって　おとこのまものも つかえるのよ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0566 -> bank73 #84 : わたほ゛う「あそこの　にんぎょう そっくりかな？　ェヘヘ、。 わたほ゛う「〈テリー〉　きこえているか？ …
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0022 -> bank66 #34 : 「ほしふりのたいかいに　かてば みなも　よろこぶことでしょう。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0564 -> bank73 #82 : 「メエ[9D]　メエ[9D]。 いきどまりへ　ようこそ　メエ[9D]！
;     $0842 -> bank78 #111 : 「うむ。 〈テリー〉よ。 「まけたとはいえ　わしは まだまだ　こたえとらんぞい！ 「おぬしと　たたかって…
;     $011B -> bank67 #57 : 「なんじゃい　うけつけで ふんぞりかえっとる　あのばばあ。 「としがいもなく　バニーガールの かっこうな…
;     $055F -> bank73 #77 : わたぼうは　へんじをしない。
;     $00D4 -> bank66 #212 : 「いつも　ごくろうさまだな。 たまには　ゆっくりしろよ！
;     $0560 -> bank73 #78 : わたぼうは わたぼうの　にんぎょうだった！

Bank15_Area43_Sections:                     ; $46CE  areaType $43  (3 sections)
    dw $46D4,$46E4,$46F6   ; section $00+
Bank15_Area43_Grids:                        ; $46D4-$47EE  (282 bytes)
    INCBIN "terry.gbc", $03C6D4, $011A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0571 -> bank73 #95 : 〈テリー〉は　ギロチンにふれた。 つめたい　やいばが　〈テリー〉の よこがおを　うつしだす。
;     $0572 -> bank73 #96 : 〈テリー〉は　ギロチンにふれた。 つめたい　やいばが　〈テリー〉の よこがおを　うつしだす。 ギロチンは…
;     $00D8 -> bank66 #216 : 「わたしを　はたらかせるのか！？ しかも　ただばたらきとは！
;     $0567 -> bank73 #85 : 「なんじは　まものを　こくしし なんども　ぜんめつさせたな？ 「まものを　ひどいめに　あわせた つみを　…
;     $0568 -> bank73 #86 : 「クッ。 くちで　いうても　わからぬか、。 「ならば　みをもって おもいしるがよい！！
;     $0569 -> bank73 #87 : 「つみを　みとめるのだな。 では　はんけつを　いいわたす。 「モンスターマスター　〈テリー〉は まもの　…
;     $056A -> bank73 #88 : 「クッ。 くちで　いうても　わからぬか、。 「ならば　みをもって おもいしるがよい！！
;     $056B -> bank73 #89 : 「では　これより　〈テリー〉の こうかいしけいを　しっこうする！ 「ざいにん　〈テリー〉。 ギロチンの　…
;     $00D7 -> bank66 #215 : 「ケケケ！ ばかは　はたらけ！
;     $056C -> bank73 #90 : 「なんじゃ？　しぬまえに　なにか いいのこしたことが　あるのか？〔はい/いいえ〕
;     $056E -> bank73 #92 : 「ならば　はよしね。
;     $056D -> bank73 #91 : 「え[94][94]い　しゃらくさい！ そんなに　ギロチンが　いやなら、 「わしが　このてで ほうむって…
;     $00B1 -> bank66 #177 : 「フンッ。 ホィミなしで　かってやらあ！
;     $056F -> bank73 #93 : 「なんじ　さらなる つみを　かさねるのか、、？
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0302 -> bank70 #2 : 「それじゃあ　あなた　わたしを つかまえにきた　マスターなの？〔はい/いいえ〕
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0570 -> bank73 #94 : わたほ゛う「〈テリー〉の　まものは 〈テリー〉のことを　しんじてるよ！ わたほ゛う「あんしんして　たたか…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0023 -> bank66 #35 : 「ゆうしょうできれば　きっと ねえさんと　あえるだろうさ！
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area44_Sections:                     ; $47EE  areaType $44  (3 sections)
    dw $47F4,$4804,$4B44   ; section $00+
Bank15_Area44_Grids:                        ; $47F4-$4B46  (850 bytes)
    INCBIN "terry.gbc", $03C7F4, $0352
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0573 -> bank73 #97 : 「ゥグウワァァ、ゴゴオ グウウァァアアア、、、、。 「グァゴゴゴゴゴゴ、、、、。
;     $00B3 -> bank66 #179 : 「だまらっしゃい！ 「いま　たたかいかたを あんしょう　しておるのだ、、。
;     $0576 -> bank73 #100 : 「ゥグァァアア、、。 「ゆるせぬ。　やはりゆるせぬ、。 、、まけたことが　ゆるせぬ！！ 「グオオォォ！！…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0103 -> bank67 #33 : 「えいほ　えいほ。 「あーあ　はらが　へったなあ、。 「こんなんじゃ　めいれいされても はらがたつだけだ…
;     $006C -> bank66 #108 : 〈テリー〉は　スカィドラゴンの タマゴを　てにいれた！ しかし　タマゴを　つれては あるけません。 タマ…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0403 -> bank71 #59 : 「それじゃあ　うごくせきぞうは ぼくじょうに　おくっておくわ。 「わたしの　うごくせきぞう。 たいせつに…
;     $006E -> bank66 #110 : ぐちょっ　、、。 フンが　〈テリー〉に　あたった。
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0501 -> bank72 #141 : 「キユッキユ　キユッキユ！
;     $000C -> bank66 #12 : テリーは　ほんだなを　しらべた。 むずかしくて　よめない！
;     $0068 -> bank66 #104 : 「まものにも　せいかくが あります。 「えらんだ　さくせんによって せいかくは　へんかするそうです。 「…
;     $0577 -> bank73 #101 : 「みるがいい、、この　けんを、、。 「やまたのおろちがもっていた くさなぎのつるぎ　だ。 「だがォレのさ…
;     $0578 -> bank73 #102 : 「じゃあな！　やまたのおろちは おとなしくなったはずだ。 「はやいとこ　けんぐらい つかえるように　なる…
;     $0579 -> bank73 #103 : 「なに？　さいきょうのけんを さがしている　りゆうだと？ 「ふっ。　そんなことをきいて どうするつもりだ…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $057A -> bank73 #104 : わたほ゛う「あ！　だれかに　たすけて もらったろう？　まっ　いいか。 わたほ゛う「さあ　かえろうか！
;     $0575 -> bank73 #99 : わたほ゛う「〈テリー〉！　かえろうか。
;     $0024 -> bank66 #36 : 〈テリー〉は　ほんだなを　しらべた。 「タィジャのくに、 ほんを　よみますか？ 〔はい/いいえ〕
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0574 -> bank73 #98 : 「ググググ　グオオ、、、。
;     $0203 -> bank68 #107 : 「やすらぎとゆうきのへやが あたらしく　ひらかれましたよ！

Bank15_Area45_Sections:                     ; $4B46  areaType $45  (2 sections)
    dw $4B4A,$5046   ; section $00+
Bank15_Area45_Grids:                        ; $4B4A-$5048  (1278 bytes)
    INCBIN "terry.gbc", $03CB4A, $04FE
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $046D -> bank71 #165 : 「はつに　おめにかかる。　わがなは デャラン。　ここの　あるじだ。 デャラン「ほほう、、。　よいめを し…
;     $00A9 -> bank66 #169 : 「なにごとも　ほどほどが いちばん！
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $006C -> bank66 #108 : 〈テリー〉は　スカィドラゴンの タマゴを　てにいれた！ しかし　タマゴを　つれては あるけません。 タマ…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $046E -> bank71 #166 : デャラン「さあ　ぞんぶんに たたかうがいい！
;     $046F -> bank71 #167 : デャラン「ほう。また　あらわれたか。 わがしもべと　たたかうがよいぞ。 デャラン「いでよ！　わがしもべよ…
;     $0470 -> bank71 #168 : デャラン「さあ　ぞんぶんに たたかうがいい！
;     $0156 -> bank67 #116 : 「ふえのねで　ねむってしまった いしのばんにんは　やまになった。 「、あるまちの　ふるくて　たかい かべ…
;     $0471 -> bank71 #169 : デャラン「フフハハハハ！ あっさりと　たおしおったな。 デャラン「よわきものと　たたかわせた ぶれい　ど…
;     $0804 -> bank78 #49 : 「まものの　つかまえかたも ノートに　うつしてるよ。　みる？〔はい/いいえ〕
;     $0472 -> bank71 #170 : デャラン「しょうかいしよう。　われに たましいを　ささげし、 デャラン「せかい　さいきょうの けんし　テ…
;     $00AA -> bank66 #170 : 「フツーにしてれば フツーにかてます！
;     $0157 -> bank67 #117 : 「なんだよ　てめーは！ え？　マスターなのか？ 「よわそうな　やつだな。 ここからは　とおしてやらないっ…
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…
;     $001A -> bank66 #26 : 「そうですか、、。
;     $0048 -> bank66 #72 : プリォ「おうさま　おゆるしくだせー！ ホィミンも　にげてしまっただ！ EN: Prio: "My Kin…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0475 -> bank72 #1 : デャラン「フフ　ハハハハ、、！ このおとこをも　まかしたか！！ デャラン「おまえが　きにいったぞ。 おお…
;     $0476 -> bank72 #2 : デャラン「ち、わき　にく、おどるとは このことだ。　さあ　たたかおう！ デャラン「ちを　したたらせ　にく…
;     $00AB -> bank66 #171 : 「さあ！ がんばっていきましょー！
;     $00C7 -> bank66 #199 : 「うっかりまもの　といえば あたしの　ことでさあ！
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $0479 -> bank72 #5 : デャラン「わたしは　まけたのか？ 、、そうか　まけたのだな。 デャラン「みごとであったぞ！ わたしの　か…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $047A -> bank72 #6 : テリー？「、おまえ、、つよいな、。 、、やつにも、かったんだな。 テリー？「ォレは、かてなかった。 、、…
;     $047B -> bank72 #7 : ほんとうの　なまえを テリー？に　おしえますか？〔はい/いいえ〕
;     $047D -> bank72 #9 : テリー？「いや。　やっぱりいい。 きかなくても　わかるんだ。
;     $047C -> bank72 #8 : テリー？「まあいい。　きかなくても ォレには　わかるんだ。
;     $047F -> bank72 #11 : テリー？「あ、、。　からだが かるくなってきた。 テリー？「そうか。　あさが、、。 そろそろ　おきるじか…
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $0480 -> bank72 #12 : テリー？「〈テリー〉よ。 ォレのようには　なるな。 テリー？「ちからに　みいられたものは いずれちからに…
;     $0481 -> bank72 #13 : テリー？「じゃあな。　〈テリー〉！ ォレは　いくよ。 テリー？「ちゅうこく、 もうひとつ　してもいいか？…
;     $0482 -> bank72 #14 : テリー？「なにが　あっても ねえさんを　たいせつにな！！！
;     $0483 -> bank72 #15 : テリー？「、、いやだろうが きいてもらうぜ。 テリー？「なにが　あっても ねえさんを　たいせつにな！！！
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0484 -> bank72 #16 : わたほ゛う「さあ　いこうか、！
;     $0406 -> bank71 #62 : 「わたしの　うごくせきぞうは ぱふぱふが　つかえるのよ！ 「ぱふぱふって　おとこのまものも つかえるのよ…
;     $0025 -> bank66 #37 : 「おおきなきのなかに　つくられた ちいさなくにである。 「ほかのくにも　おなじように おおきなきのなかに…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0473 -> bank71 #171 : デャラン「フフ　ハハハ、、！ また　あらわれたな！！ デャラン「そんなに　たたかいたいか！ ならば　たた…
;     $0474 -> bank72 #0 : デャラン「さあ　テリーよ。 おもうぞんぶん　たたかうがよい。 デャラン「おまえの　つよさを このものに　…
;     $0477 -> bank72 #3 : デャラン「どうかな？ すこしは　しょうじんしたか？ デャラン「おまえほどの　おとこなら いつでも　あいて…
;     $0478 -> bank72 #4 : デャラン「では　ゆくぞ！

Bank15_Area46_Sections:                     ; $5048  areaType $46  (2 sections)
    dw $504C,$505C   ; section $00+
Bank15_Area46_Grids:                        ; $504C-$5138  (236 bytes)
    INCBIN "terry.gbc", $03D04C, $00EC
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $057B -> bank73 #105 : 「よくぞきた　〈テリー〉よ！ 「わしが　おうのなかの　おう りゅうおう　である。 りゅうおう「わしは　ま…
;     $00D9 -> bank66 #217 : 「み　みんなの　ほじょ　しとけば、 そのうち、せんとう　おわるよね？
;     $057D -> bank73 #107 : りゅうおう「どうした？ わるいはなしでは　なかろう。 りゅうおう「せかいの　はんぶんを ほんとうに　いら…
;     $057E -> bank73 #108 : りゅうおう「では　どうしても このわたしを　たおすというか。 りゅうおう「おろかものめ！ おもいしるがよ…
;     $057F -> bank73 #109 : りゅうおう「しょうこりもなく また　きよったか！ りゅうおう「わしは　よわいものに きょうみは　ない！ …
;     $057C -> bank73 #106 : りゅうおう「よくぞいった！ ではそなたに、 りゅうおう「せかいの　はんぶん やみのせかいを　あたえよう！…
;     $00C9 -> bank66 #201 : 「みなさんが　かいてきにたたかえる かんきょうを　ほしょうします！
;     $0580 -> bank73 #110 : りゅうおう「わしを　たおすとは そなた　ただものでは　あるまい！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0581 -> bank73 #111 : わたほ゛う「いっちょ　あがりだな！ 〈テリー〉！　さあ　かえろうぜ！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0026 -> bank66 #38 : 〈テリー〉は　ほんを ほんだなに　もどした。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area47_Sections:                     ; $5138  areaType $47  (3 sections)
    dw $513E,$514E,$5212   ; section $00+
Bank15_Area47_Grids:                        ; $513E-$52D6  (408 bytes)
    INCBIN "terry.gbc", $03D13E, $0198
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0582 -> bank73 #112 : 「だれじゃ？ 「わたしの　ねむりを じゃまするものは？ 「、、、おろかものめ！ 「わたしを　だいしんかん…
;     $00DA -> bank66 #218 : 「ひっ。 「こっ　こわいよ[95]！
;     $0584 -> bank73 #114 : ハーゴン「では　おぼえておくがよい。 ハーゴン「わたしが　いだいなる かみのつかい　ハーゴンさまじゃ！
;     $0585 -> bank73 #115 : ハーゴン「また　きよったか！ ハーゴン「みのほどを　しらぬ ふとどき　ものめ！！ ハーゴン「むしけらのよ…
;     $0583 -> bank73 #113 : ハーゴン「ならば　ゆるせぬ！ ハーゴン「おのれの　あさはかさを おもいしるがよい！
;     $00CB -> bank66 #203 : 「こうげきだけしか　のうのない やつと　いっしょにしないでくれ！
;     $0586 -> bank73 #116 : ハーゴン「お　おのれ　くちおしや、。 ハーゴン「この　ハーゴンさまが おまえごときに　やられるとは。 ハ…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0587 -> bank73 #117 : わたほ゛う「おや？　まだ　まものの においがするな、、。 わたほ゛う「まあ　いいか！ さあ　かえろうぜ！…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0027 -> bank66 #39 : 〈テリー〉は　ほんだなを　しらべた。 「モンスターマスター、 ほんを　よみますか？ 〔はい/いいえ〕
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0588 -> bank73 #118 : 「、、、、わが、、な、は、、、 はかい、、の、、、か、み、、 「、シ、、ドー、、、、。 シドー「われの、…
;     $00DB -> bank66 #219 : 「ガタガタガタ、、。 ブルブルブル、、。 「こわいんじゃないです！ さむくて　ふるえてるんですよ！！
;     $0589 -> bank73 #119 : シドー「、、こ、、、わ、、す！！
;     $00CD -> bank66 #205 : 「ぽーっとしてれば　そのうち せんとうって　おわりますよねー。
;     $058A -> bank73 #120 : シドー「、、、、、、、、、、、、、、 、、、、、、、、、、、、、、、。
;     $058B -> bank73 #121 : わたほ゛う「やっぱり　まだ　まものが ここに　いたんだよな。 わたほ゛う「さあ！　かえろう！！
;     $0028 -> bank66 #40 : 「まものたちの　ことばを　りかいし あやつることができる　ひとびと。 「かんぜんに　まものと　わかりあえ…

Bank15_Area48_Sections:                     ; $52D6  areaType $48  (2 sections)
    dw $52DA,$52EA   ; section $00+
Bank15_Area48_Grids:                        ; $52DA-$53AE  (212 bytes)
    INCBIN "terry.gbc", $03D2DA, $00D4
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $058C -> bank73 #122 : 「ついに　ここまで　きたのか。 あわれなる　ものどもよ。 「この　だいまおう　バラモスさまに さからおう…
;     $00DC -> bank66 #220 : 「うお[95]　いか[91]あん！！ なぜだ　なぜ　こんなきもちに！！ 「こっ、、、　、、、こ、わ、、い…
;     $058D -> bank73 #123 : バラモス「おろかものめ！　まだ この　わたしに　さからうのか！ バラモス「みのほどを わきまえぬにも　ほ…
;     $00CF -> bank66 #207 : 「そのうち　かてますよね！
;     $058E -> bank73 #124 : バラモス「ぐうっ、、 お、おのれ、、、 バラモス「くちおしや、、。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0104 -> bank67 #34 : 「へへっ！　にいちゃんよ[95]。 [10]クラスのあいてを　しりたいか？〔はい/いいえ〕
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $058F -> bank73 #125 : わたほ゛う「すごいな　〈テリー〉。 さあ　かーえろ！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0029 -> bank66 #41 : 「ぼくも　ますたーに　なりたいな。 どうすれば　なれるのかな？
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area49_Sections:                     ; $53AE  areaType $49  (2 sections)
    dw $53B2,$53C2   ; section $00+
Bank15_Area49_Grids:                        ; $53B2-$5486  (212 bytes)
    INCBIN "terry.gbc", $03D3B2, $00D4
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0590 -> bank73 #126 : 「わが　いけにえの　さいだんに よくぞきた！ 「われこそは　すべてを ほろぼすもの　ゾーマなり！ ゾーマ…
;     $00DD -> bank66 #221 : とびらは　おもく　とざされている。
;     $0591 -> bank73 #127 : ゾーマ「ほほう　こりもせず また　やってきたようだな。 ゾーマ「なんど　たたかっても おなじこと。 ゾー…
;     $00D1 -> bank66 #209 : 「え？　いいじゃないですか！ とりあえず　かいふくしましょ！
;     $0592 -> bank73 #128 : ゾーマ「、、、そなたは なを　なんともうす、、？ ゾーマ「そうか　〈テリー〉ともうすか。 ゾーマ「〈テリ…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0204 -> bank68 #108 : 「、なんだ。　いないのか。 どうか　ォレに　よきょうを！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0593 -> bank73 #129 : わたほ゛う「つよい　まものは　いっぱい いるんだ！　さあ　かえるぞ！！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002A -> bank66 #42 : おう「うえのかいは　まものたちの ぼくじょうに　なっておる。 おう「そこで　プリォともうすものに まもの…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4A_Sections:                     ; $5486  areaType $4A  (2 sections)
    dw $548A,$549A   ; section $00+
Bank15_Area4A_Grids:                        ; $548A-$557C  (242 bytes)
    INCBIN "terry.gbc", $03D48A, $00F2
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0594 -> bank73 #130 : 「ぐはああああ、、！ なにものだ　おまえたちは？ 「わたしは　デスピサロ。 デスピサロ「まぞくの　おうと…
;     $00DE -> bank66 #222 : 「、、、　、、、。 、、、　、、、。 「・・・、、、。
;     $0596 -> bank73 #132 : デスピサロ「では　おしえてやろう！ があああ、、！ デスピサロ「おまえたち　にんげんと にんげんに　しっ…
;     $0597 -> bank73 #133 : デスピサロ「ぐはああああ、、！ デスピサロ「しにに　きたか？ 〔はい/いいえ〕
;     $0599 -> bank73 #135 : デスピサロ「ならば　なにを しにきたというのだ！ デスピサロ「おろかものが！！
;     $0595 -> bank73 #131 : デスピサロ「があああ、、！ ならば　わがまえに、 デスピサロ「あらわれたことを こころから　くいるがいい…
;     $0598 -> bank73 #134 : デスピサロ「ならば　しね！
;     $00D3 -> bank66 #211 : 「〈テリー〉さん。 かたでも　おもみしましょうか？
;     $059A -> bank73 #136 : デスピサロ「ぐはあああああ、、！ からだが　あつい、、。 デスピサロ「わたしは　やぶれたのか？ デスピサ…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0104 -> bank67 #34 : 「へへっ！　にいちゃんよ[95]。 [10]クラスのあいてを　しりたいか？〔はい/いいえ〕
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $059B -> bank73 #137 : わたほ゛う「ロザリーというのは デスピサロの　こいびとなんだ。 わたほ゛う「でも　にんげんたちに いじめ…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002B -> bank66 #43 : 「ほしふりのたいかいで　このくには まけつづけている。 「しかしこんかいは　しゅさいこく！ どうしても　…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4B_Sections:                     ; $557C  areaType $4B  (2 sections)
    dw $5580,$5590   ; section $00+
Bank15_Area4B_Grids:                        ; $5580-$5660  (224 bytes)
    INCBIN "terry.gbc", $03D580, $00E0
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $059C -> bank73 #138 : 「グゴゴゴゴ、、。 「だれだ？ わがねむりを　さますものは？ 「わがなは　ェスターク、、。 ェスターク「…
;     $00DF -> bank66 #223 : 「あ[9D]　ねむたい。 はやく　かえろーよー！
;     $059D -> bank73 #139 : ェスターク「ならば　たちさるがよい。 ェスターク「わたしは　いましばらく ねむることに　しよう、、。 ェ…
;     $059F -> bank73 #141 : ェスターク「グゴゴゴゴ、、、。 ェスターク「また　おまえか、、、。 ェスターク「わたしの　ねむりを さま…
;     $059E -> bank73 #140 : ェスターク「ならば　しかたないな。 ェスターク「わたしは　ほろぼされる わけには　いかぬ。 ェスターク「…
;     $00D5 -> bank66 #213 : 「まあ　あれだな。 せんとうとは　たてになるやつと、 「わたしのような　しゅうさいがいて はじめてなりた…
;     $05A0 -> bank73 #142 : ェスターク「グゴゴゴゴ、、、。 なんということだ、、。 ェスターク「わたしが　やられるとは。 このような…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0102 -> bank67 #32 : 「ふう、、。　なかなか いうことを　きかんわい。 「まだまだ　かしこさが たりないのかも　しれんな。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $05A1 -> bank73 #143 : わたほ゛う「たとえ　ここが ゆめのなかの　せかいだとしても、 わたほ゛う「〈テリー〉が　がんばってる こ…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002C -> bank66 #44 : 「ほしふりのよるの　いいつたえを かたりましょう。 「〈n〉たびの　まんげつののち ほしふりのよるは　や…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4C_Sections:                     ; $5660  areaType $4C  (2 sections)
    dw $5664,$5674   ; section $00+
Bank15_Area4C_Grids:                        ; $5664-$5750  (236 bytes)
    INCBIN "terry.gbc", $03D664, $00EC
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $05A2 -> bank73 #144 : 「ついに　ここまで　きたか。 「モンスターマスター　〈テリー〉と その　なかまたちよ！ 「わたしが　だれ…
;     $00E2 -> bank67 #0 : 「ようきたの[93]。 ここは　かくとうじょうじゃ。 「ん　わしか？　わしは ここの　めいぶつ　おんな、…
;     $05A4 -> bank73 #146 : 「しらぬというか！ この　たわけが！ 「まかいのおう　にして おうのなかの　おう、 「ミルドラースとは　…
;     $05A5 -> bank73 #147 : ミルドラース「ファ　ファ　ファ。 ミルドラース「モンスターマスター 〈テリー〉と　その　なかまたちよ。 …
;     $05A3 -> bank73 #145 : 「ファ　ファ　ファ！！ よい　こころがけじゃ。 「まかいのおう　にして おうのなかの　おう、 「ミルドラ…
;     $00D7 -> bank66 #215 : 「ケケケ！ ばかは　はたらけ！
;     $05A6 -> bank73 #148 : ミルドラース「なんと　このわたしが やぶれてしまうとは、、。 ミルドラース「こんなことが おこるわけがな…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0203 -> bank68 #107 : 「やすらぎとゆうきのへやが あたらしく　ひらかれましたよ！
;     $05A7 -> bank73 #149 : わたほ゛う「ほんとに　つよくなったな！ それじゃ　かえろうか！！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002D -> bank66 #45 : 「もういちど　ほしふりのよるの いいつたえを　かたりましょうか？〔はい/いいえ〕
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4D_Sections:                     ; $5750  areaType $4D  (2 sections)
    dw $5754,$5764   ; section $00+
Bank15_Area4D_Grids:                        ; $5754-$5846  (242 bytes)
    INCBIN "terry.gbc", $03D754, $00F2
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $05A8 -> bank73 #150 : 「ようこそ　ムシケラ　しょくん。 「わがなは　ムドー。 すでに　しっておろう。〔はい/いいえ〕
;     $00E0 -> bank66 #224 : 「あくせくしても　あきまへん。 ゆっくり　しまひょ！
;     $05A9 -> bank73 #151 : ムドー「ん？　わたしのなまえは すでに　しっておったな？〔はい/いいえ〕
;     $05AA -> bank73 #152 : ムドー「よろしい。 では　しょくん。 ムドー「はかのよういは　してきたか？ 〔はい/いいえ〕
;     $05AB -> bank73 #153 : ムドー「は？　しょくんの　ねむる かんおけのよういは　してきたか？〔はい/いいえ〕
;     $05AC -> bank73 #154 : ムドー「じつに　よろしい。 では　はじめようか。
;     $05AD -> bank73 #155 : ムドー「しつこい　ムシケラだ。 さっさと　くじょしてやろう。
;     $00D9 -> bank66 #217 : 「み　みんなの　ほじょ　しとけば、 そのうち、せんとう　おわるよね？
;     $05AE -> bank73 #156 : ムドー「ムシケラどもに　たおされた。 ということは、、？！ ムドー「わたしは　ムシケラよりも ちっぽけな…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0104 -> bank67 #34 : 「へへっ！　にいちゃんよ[95]。 [10]クラスのあいてを　しりたいか？〔はい/いいえ〕
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $05AF -> bank73 #157 : わたほ゛う「そんじゃあ　かえるか！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002E -> bank66 #46 : 「こころえました。 「ほしふりのよるは　〈n〉たびの まんげつののち　やってきます。 「このよるには　そ…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4E_Sections:                     ; $5846  areaType $4E  (2 sections)
    dw $584A,$585A   ; section $00+
Bank15_Area4E_Grids:                        ; $584A-$5912  (200 bytes)
    INCBIN "terry.gbc", $03D84A, $00C8
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $05B0 -> bank73 #158 : 「フオッ　フオッ　フオッ。 「だまって　あそばせておれば いいきに　なりおって、、。 「そろそろ　わしの…
;     $00E1 -> bank66 #225 : 「う[95]っ！！　はらがいたい、。 ちょっと　やすませてくれ、、！ 「なんだ　そのめは？ けびょうだと…
;     $05B1 -> bank73 #159 : デスタムーア「フオッ　フオッ、、。 また　やってきたようじゃの。 デスタムーア「あれほどまでに うちくだ…
;     $00DB -> bank66 #219 : 「ガタガタガタ、、。 ブルブルブル、、。 「こわいんじゃないです！ さむくて　ふるえてるんですよ！！
;     $05B2 -> bank73 #160 : デスタムーア「くっ、、。 まけたか、、。 デスタムーア「やはり　このすがたでは かてないということか、、…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $05B3 -> bank73 #161 : わたほ゛う「デスタムーアは　まおうの なかで　いちばんつよいんだ。 わたほ゛う「けど　ほんとうは　いまよ…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $002F -> bank66 #47 : 「ほしふりのよるに　たいかいは おこなわれる！ 「くにの　だいひょうに　えらばれた マスターたちが　たた…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank15_Area4F_Sections:                     ; $5912  areaType $4F  (3 sections)
    dw $5918,$5928,$592A   ; section $00+
Bank15_Area4F_Grids:                        ; $5918-$592C  (20 bytes)
    INCBIN "terry.gbc", $03D918, $0014
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…

Bank15_Area50_Sections:                     ; $592C  areaType $50  (2 sections)
    dw $5930,$5932   ; section $00+
Bank15_Area50_Grids:                        ; $5930-$593E  (14 bytes)
    INCBIN "terry.gbc", $03D930, $000E
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0680 -> bank74 #160 : (text n/a)
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0682 -> bank74 #162 : 「ありがとうございました。 また　おこしください！

Bank15_Area51_Sections:                     ; $593E  areaType $51  (3 sections)
    dw $5944,$594A,$5946   ; section $00+
Bank15_Area51_Grids:                        ; $5944-$59BC  (120 bytes)
    INCBIN "terry.gbc", $03D944, $0078
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0041 -> bank66 #65 : スラお「ここでは　まものとタマゴを 〈n〉ひきまで　あずけられるよ。 スラお「ぼくじょうに　あずけていて…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…

Bank15_Area52_Sections:                     ; $59BC  areaType $52  (1 section)
    dw $59BE   ; section $00+
Bank15_Area52_Grids:                        ; $59BE-$5A6C  (174 bytes)
    INCBIN "terry.gbc", $03D9BE, $00AE
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0052 -> bank66 #82 : 「はやく　ホィミンを つれもどしてください！ EN: "Hurry and bring Hoimin b…
;     $0068 -> bank66 #104 : 「まものにも　せいかくが あります。 「えらんだ　さくせんによって せいかくは　へんかするそうです。 「…

Bank15_Area53_Sections:                     ; $5A6C  areaType $53  (also area types $61, $62, $63, $64)  (1 section)
    dw $6F76   ; section $00+

Bank15_Area54_Sections:                     ; $5A6E  areaType $54  (also area types $55, $56)  (2 sections)
    dw $5A72,$5A74   ; section $00+
Bank15_Area54_Grids:                        ; $5A72-$5A7C  (10 bytes)
    INCBIN "terry.gbc", $03DA72, $000A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0600 -> bank74 #32 : 「おみあい　したくなったら わたしに　こえをかけてください！

Bank15_Area57_Sections:                     ; $5A7C  areaType $57  (also area types $58, $59)  (1 section)
    dw $6F76   ; section $00+

Bank15_Area5A_Sections:                     ; $5A7E  areaType $5A  (7 sections)
    dw $5A8C,$5A8E,$5AEA,$5B46,$5BA2,$5BFE,$5C5A   ; section $00+
Bank15_Area5A_Grids:                        ; $5A8C-$5CB6  (554 bytes)
    INCBIN "terry.gbc", $03DA8C, $022A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0053 -> bank66 #83 : 「たびのとびらに　はいれば いせかいへと　とばされます。 「いせかいには ふしぎな　あなが　あいており、…
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0082 -> bank66 #130 : 「あまり　ベタベタして たたかうのは　すきじゃないね！
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0090 -> bank66 #144 : 「さあ　みなのもの。 わたしのまえに　ひざまずくのだ！ 「わたしより　つよいものなど このよに　おらん！…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $00C6 -> bank66 #198 : 「いくら　うっかりものでも みかたは　ちゃんと　たすけます！
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $00CC -> bank66 #204 : 「ククッ。　このわたしの　どこに てぬかりが　あるだろうか！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0144 -> bank67 #98 : 「ありがとう　〈テリー〉！　メダル たくさん　もってきてくれたね！ 「おれいに　たびのとびらを ひらいて…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $014E -> bank67 #108 : おう「おお！　ちと　いいすぎたか。 、こんごも　たのむぞ　〈テリー〉！ おう「あずかりじょや　としょかん…

Bank15_Area5B_Sections:                     ; $5CB6  areaType $5B  (7 sections)
    dw $5CC4,$5CC6,$5D22,$5D7E,$5DDA,$5E36,$5E92   ; section $00+
Bank15_Area5B_Grids:                        ; $5CC4-$5EEE  (554 bytes)
    INCBIN "terry.gbc", $03DCC4, $022A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0053 -> bank66 #83 : 「たびのとびらに　はいれば いせかいへと　とばされます。 「いせかいには ふしぎな　あなが　あいており、…
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $00C6 -> bank66 #198 : 「いくら　うっかりものでも みかたは　ちゃんと　たすけます！
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $00CC -> bank66 #204 : 「ククッ。　このわたしの　どこに てぬかりが　あるだろうか！！
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0106 -> bank67 #36 : 「まっ　それも　いいだろうよ。
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $010C -> bank67 #42 : べべ「フンガー　フンガー！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0146 -> bank67 #100 : わたほ゛う「〈テリー〉！　やったな！ おしろに　もどしてやるよ！
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $014C -> bank67 #106 : 「まちびととまもりのへやは たびのとびらのまに　ある。 「こんごは　かくとうじょうで ラィバルに　かって…

Bank15_Area5C_Sections:                     ; $5EEE  areaType $5C  (9 sections)
    dw $5F00,$5F02,$5F5E,$5FBA,$6016,$6072,$60CE,$612A   ; section $00+
    dw $6186   ; section $08+
Bank15_Area5C_Grids:                        ; $5F00-$61E2  (738 bytes)
    INCBIN "terry.gbc", $03DF00, $02E2
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0053 -> bank66 #83 : 「たびのとびらに　はいれば いせかいへと　とばされます。 「いせかいには ふしぎな　あなが　あいており、…
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0086 -> bank66 #134 : 「いちおう　わたし かいふくとか　やりますって！
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0088 -> bank66 #136 : 「フハハハハ、！　わたしのかれいな こうげきを　みるがよい！！
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $008A -> bank66 #138 : 「そのうち[92]　なんとか[91] なるんじゃないですか[91]、、。
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $008C -> bank66 #140 : 「あんしんするのだ　〈テリー〉。 まけても　いいじゃないか。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0186 -> bank67 #164 : 「なんだ　つまらない。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0188 -> bank67 #166 : 〈テリー〉は　ほんだなを　しらべた。 「けいとうとは、 「まもののからだを　よくしらべると [09]つの…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $018A -> bank67 #168 : 〈テリー〉は　ほんだなを　しらべた。 「シォンよげんしょ、だい[01]せつ、 「きんぞくを　ねりあわせ　…
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $018C -> bank67 #170 : 〈テリー〉は　ほんだなを　しらべた。 「シォンよげんしょ、だい[03]せつ、 「ドラゴンの　ち　には　か…

Bank15_Area5D_Sections:                     ; $61E2  areaType $5D  (1 section)
    dw $61E4   ; section $00+
Bank15_Area5D_Grids:                        ; $61E4-$6B94  (2480 bytes)
    INCBIN "terry.gbc", $03E1E4, $09B0
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0037 -> bank66 #55 : 〈テリー〉は　たてふだを　よんだ。 「タィジャが　そだつとき おおきな　しんどうが　おこる。 「このあな…
;     $0126 -> bank67 #68 : 「おめでとう！　あらたなゆうしゃの たんじょうだ！！ 「マスター〈テリー〉に　どうぞ あたたかい　はくし…
;     $0061 -> bank66 #97 : 「よ[9D]し！ ここから　とびおりるぞ！！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0048 -> bank66 #72 : プリォ「おうさま　おゆるしくだせー！ ホィミンも　にげてしまっただ！ EN: Prio: "My Kin…
;     $003A -> bank66 #58 : 〈テリー〉は　ツボのなかを のぞきこんだ。
;     $0124 -> bank67 #66 : 「だい[02]しあいも　ちょうせんしゃの しょうりです！ 「では　つづいて　だい[03]しあいを かいし…
;     $085B -> bank78 #136 : (text n/a)
;     $085C -> bank78 #137 : (text n/a)
;     $085F -> bank78 #140 : (text n/a)
;     $085E -> bank78 #139 : (text n/a)
;     $0860 -> bank78 #141 : (text n/a)
;     $0861 -> bank78 #142 : (text n/a)
;     $0862 -> bank78 #143 : (text n/a)
;     $0122 -> bank67 #64 : 「だい[01]しあいは　ちょうせんしゃの しょうりです！ 「では　つづいて　だい[02]しあいを かいし…
;     $0120 -> bank67 #62 : 「ごらいじょうの　みなさん！ かくとうじょうへ　ようこそ！！ 「あらたな　ちょうせんしゃが あらわれまし…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0121 -> bank67 #63 : 「しあい　かいし！！
;     $0125 -> bank67 #67 : 「わたしこそは　マスターようせい じゅくの　じゅくちょうである！ 「わたしに　かつことができれば [10…
;     $01A2 -> bank68 #10 : 「わたしは　いどのそこで ひみつのけんきゅうを　しておる。 「しかも　ちょう　いちりゅうの モンスターマ…
;     $0044 -> bank66 #68 : 「ここは　モンスター ぼくじょうだよ。
;     $01A3 -> bank68 #11 : 「マスターとして　たたかうのも けんきゅうの　ひとつ！ 「さあ　かかってきなさい！！
;     $01E2 -> bank68 #74 : 「どうも　〈テリー〉くん。 よく　ここまで　これましたね。 「わたしは　マスター　テト！ きみに　わたし…
;     $01E3 -> bank68 #75 : 「また　きましたね。　まけても きにしないことですよ！
;     $026F -> bank69 #43 : 「やあ！　きょうのあいては きみかい？　だいじょうぶかな？ 「そんな　まものじゃ かてるわけないと　おも…
;     $0068 -> bank66 #104 : 「まものにも　せいかくが あります。 「えらんだ　さくせんによって せいかくは　へんかするそうです。 「…
;     $0270 -> bank69 #44 : 「やあ！　だれかと　おもえば きみなのか[91]！ 「ぼくとの　おみあいが やくにたったみたいだね[94…
;     $0271 -> bank69 #45 : 「また　きみか[91]。 なんべんたたかっても　おなじさ！ 「ぼくは　つよくて きみは　よわい。ただそれ…
;     $0330 -> bank70 #48 : 「〈テリー〉くん！ まっていました。 「きんちょうすると　いけないので さっそく　はじめましょう！
;     $0089 -> bank66 #137 : 「でへへへ、、。 きょうも　あしたも　はれですら。
;     $0331 -> bank70 #49 : 「ちょうしは　どうですか？ わたしは　ばんぜんですよ！ 「さあ　きんちょうするまえに はじめましょう！！
;     $035E -> bank70 #94 : 「ゥイ[9D]。　ヒック！ ここは　どこだ[91]？ 「なに？　かくとうじょう？ ここは　さかばじゃ　ね…
;     $035F -> bank70 #95 : 「ヒック。　また　おめえか[91]。 ちった[91]　つよくなったのか[91]？
;     $03DE -> bank71 #22 : 「ようこそ　[0A]クラスへ。 あなたがくるのを　まっていたわ！ 「さあ　〈テリー〉くん。 おてなみ　は…
;     $0094 -> bank66 #148 : 「なんど　いったらわかるんだ？ はやく　たたかわせろ！
;     $03DF -> bank71 #23 : 「こんどは　まんぞくいく　しあいが できそうかな　〈テリー〉くん？ 「いちどや　にどの　しっぱいで ぜっ…
;     $0409 -> bank71 #65 : 「しょうぶは　うんではないぞ。 じつりょくだけが　ぜったいじゃ！ 「たとえそなたが　メタルスラィムに よ…
;     $0099 -> bank66 #153 : 「まず　じょうけんを　ゆうりにして ことに　いどむべきでしょう。
;     $040A -> bank71 #66 : 「じつりょくを　みがけば うんも　ひらけてくるのじゃ！ 「たとえそなたが　はぐれメタルに よく　あう　ひ…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $04E9 -> bank72 #117 : ミレーヨ「〈テリー〉！　つよかったよ！
;     $003C -> bank66 #60 : 「なんだ　おまえ。　まものを さらいに　きただか？〔はい/いいえ〕
;     $0406 -> bank71 #62 : 「わたしの　うごくせきぞうは ぱふぱふが　つかえるのよ！ 「ぱふぱふって　おとこのまものも つかえるのよ…
;     $0407 -> bank71 #63 : 「いのちのきのみじゃ。 だいじに　つかうがよいぞ。
;     $006C -> bank66 #108 : 〈テリー〉は　スカィドラゴンの タマゴを　てにいれた！ しかし　タマゴを　つれては あるけません。 タマ…
;     $04EA -> bank72 #118 : ワルぼう「ミレーヨ！ おまえは　もう　ようなしだな！
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0065 -> bank66 #101 : 「わたしも　ちいさなメダルを ひろったことが　あります。 「あれは　たびのとびらから ぼうけんに　でてい…
;     $0057 -> bank66 #87 : 「ここは　たびだちのへやです。 たびだちのとびらは　こちらです。 「ホィミンは　ここのとびらに にげこみ…
;     $0400 -> bank71 #56 : 「がいこくにあらわれた　おそろしい マスターの　うわさですが、 「みたこともない　まものをあやつり すご…
;     $0100 -> bank67 #30 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかには　おばさんの てちょうが　はいっている。 「きょうい…
;     $00E4 -> bank67 #2 : 「よくやったのー！ [10]クラス　かちぬきじゃ！
;     $04E3 -> bank72 #111 : 「みなさん！　これより　さいごの しあいを　かいしいたしましょう。 「これまでの　しあいで　ぜんしょう …
;     $000C -> bank66 #12 : テリーは　ほんだなを　しらべた。 むずかしくて　よめない！
;     $04E4 -> bank72 #112 : 「けむくじゃら。　めが　[03]つある。 たおした　てきを　たべる、、。 「うわさが　うわさをよび　だれ…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $04E5 -> bank72 #113 : ミレーヨ「そ　そんな　まさか、、 〈テリー〉なの？　ど　どうして？ ミレーヨ「そう、。　あなたも わたし…
;     $0158 -> bank67 #118 : 「さあ　いちばんしたまで あとひといきだ！ 「したには　いったい なにがあるのかな？
;     $04E6 -> bank72 #114 : ミレーヨ「〈テリー〉　また　わたしに ちょうせん　するきなの？ ミレーヨ「さっすが　〈テリー〉！ まけず…
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…
;     $001A -> bank66 #26 : 「そうですか、、。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $04E1 -> bank72 #109 : 「かれいな　わざの　かずかずで われわれを　みりょうした、 「タィジャこく　だいひょうの しょうりです！…
;     $04DF -> bank72 #107 : 「みなさん！　ようこそ おあつまり　いただきました！ 「こよいは　みなさん　おまちかねの ほしふりのよる…
;     $04E0 -> bank72 #108 : 「タィボクのくに　だいひょうと タィジャのくに　だいひょうです。 「しあい　かいし！！
;     $04E2 -> bank72 #110 : 「カレキのくに　だいひょうと タィジャのくに　だいひょうです！ 「しあい　かいし！！
;     $084A -> bank78 #119 : (text n/a)
;     $0111 -> bank67 #47 : 「わしは　メダルをあつめておる メダルおじさんじゃ。
;     $0845 -> bank78 #114 : (text n/a)
;     $0848 -> bank78 #117 : (text n/a)
;     $0846 -> bank78 #115 : (text n/a)
;     $0847 -> bank78 #116 : (text n/a)
;     $0849 -> bank78 #118 : (text n/a)
;     $0110 -> bank67 #46 : 「おお　よくきたな　マス、ゴホン！ わしは　メダルおじさん。 「せかいじゅうに　ちらばる ちいさなメダル…

Bank15_Area5E_Sections:                     ; $6B94  areaType $5E  (1 section)
    dw $6B96   ; section $00+
Bank15_Area5E_Grids:                        ; $6B96-$6C34  (158 bytes)
    INCBIN "terry.gbc", $03EB96, $009E
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0030 -> bank66 #48 : 「ぼくじょうの　プリォは ドジですが　とてもいいやつです。 EN: A townsperson: "Pr…
;     $0028 -> bank66 #40 : 「まものたちの　ことばを　りかいし あやつることができる　ひとびと。 「かんぜんに　まものと　わかりあえ…
;     $009D -> bank66 #157 : 「ん[9D]。 なんでも　いいんじゃないっすか？
;     $002F -> bank66 #47 : 「ほしふりのよるに　たいかいは おこなわれる！ 「くにの　だいひょうに　えらばれた マスターたちが　たた…
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…
;     $00C8 -> bank66 #200 : 「おや？　わたしの　なまえは なんだったっけか？？ 「うっかり　わすれてしまったよ。 ハッハッハ！

Bank15_Area70_Sections:                     ; $6C34  areaType $70  (7 sections)
    dw $6C42,$6C44,$6D76,$6E56,$6ED4,$6EFA,$6F46   ; section $00+
Bank15_Area70_Grids:                        ; $6C42-$6F76  (820 bytes)
    INCBIN "terry.gbc", $03EC42, $0334
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $001D -> bank66 #29 : 〈テリー〉は　やくそうを みつけた。 しかし　もちものが いっぱいだ。 〈テリー〉は　やくそうを たから…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…

    ds $108A, $FF                   ; $6F76-$7FFF padding
