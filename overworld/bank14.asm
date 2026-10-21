; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 14  (Tile movement engine, area types $20-$3F)
; ============================================================================
;
; File offset $38000-$3BFFF (16 KB); mapped $4000-$7FFF when bank reg = 14.
;
; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.
; Function table at $4001:  fn0 $4007 · fn1 $402F · fn2 $4110.
;   fn0 = READ map cell at coord (collision / event / NPC-text query)
;   fn1 = PAINT cell tile indices into $9800 BG map (scroll-fill)
;   fn2 = PAINT cell CGB attributes into VRAM bank 1 (VBK)
;
; SHARED ENGINE: code $4007-$41B9 is BYTE-FOR-BYTE identical to bank12/13/15
; (only the self-id byte at $4000 differs: $0E here). Full annotation below;
; see overworld/bank12.asm for the same routines under area type 0.
;
; DATA (this bank) = 32 area types ($20-$3F). bank4/Sub_71EF ($71EF) routes those
; wAreaType ($D8D3) values here (LD HL,$0E00; RST $10). The $41BA L1 table is
; indexed by the FULL wAreaType: out-of-range rows alias placeholder grid
; $6AE2; the 32 real rows are $20-$3F.
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

SECTION "Bank 14 Functions", ROMX[$4000], BANK[14]

    db $0E                        ; $4000  self-id byte (bank number)
    dw $4007, $402F, $4110        ; $4001  function pointer table (fn0/fn1/fn2)

; ------------------------------------------------------------
; Bank14_Fn0/Fn1/Fn2 — shared map engine (identical to bank12 code)
; ------------------------------------------------------------
Bank14_Fn0:                                 ; $4007
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
; Bank14_Fn1  ($402F)  — paint a cell's TILE INDICES into the BG tilemap
; ------------------------------------------------------------
; VRAM bank 0 ($9800 map). Walks the cell's tile stream via Sub_40E7, then the
; blit loop at $407B writes tile bytes with LD (HL+),A, wrapping every 32 cols
; (AND $1F) and stepping to the next map row on the $D8 marker (+$20); $D9 ends.
; This is the metatile -> screen tilemap expansion for one scrolled-in column.
; ------------------------------------------------------------
Bank14_Fn1:                                 ; $402F
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
Bank14_Fn1_Blit:                            ; $407B
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
Bank14_Fn1_Emit:                            ; $40A9
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
Bank14_Sub_40DA:                            ; $40DA  — advance L by one column, wrap within 32
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
; Bank14_Sub_40E7  — walk a cell's TILE stream into a WRAM $C300 buffer
; ------------------------------------------------------------
; Reads cell ptr from (BC): a 16-bit index, +$C300 base -> WRAM tile-list
; source. Copies the tile bytes with LD (HL+),A until $D9; $D8 = next-row (+$20).
; Fills the shadow the blit loop then pushes to VRAM.
; ------------------------------------------------------------
Bank14_Sub_40E7:                            ; $40E7
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
; Bank14_Fn2  ($4110)  — paint a cell's CGB ATTRIBUTES into VRAM bank 1
; ------------------------------------------------------------
; Same prologue as fn1 (byte-identical), so it targets the SAME BG-map cell.
; Difference: it builds the per-tile CGB attribute bytes (palette/priority/
; bank/flip) via Sub_4171/Sub_4195 (source base $C200, packed as nibbles), then
; the tail flips VRAM bank via VBK ($FF4F=1), reuses the fn1 blit loop ($4075)
; to write into the attribute map, and restores VBK 0. Only runs when the
; CGB-attribute-dirty flag $C81D is set. fn1 = tiles, fn2 = colour attributes.
; ------------------------------------------------------------
Bank14_Fn2:                                 ; $4110
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
; Bank14_Sub_4171  — walk a cell's ATTRIBUTE stream into the $C200 nibble buf
; ------------------------------------------------------------
; Like Sub_40E7 but each cell entry updates a packed 4-bit attribute via
; Sub_4195: address >>1 selects a byte in the $C200 table, carry (odd/even)
; selects high vs low nibble, and the new value is merged in. $D8=next row,
; $D9=end. This produces the compact per-tile CGB attributes fn2 then blits.
; ------------------------------------------------------------
Bank14_Sub_4171:                            ; $4171
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
Bank14_Sub_4195:                            ; $4195  — merge attr value A into $C200[HL/2] nibble
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


SECTION "Bank 14 Map Data", ROMX[$41BA], BANK[14]
; ============================================================================
; MAP DATA — 3-level table: L1 wAreaType -> L2 section -> cell grid[coord].
; ============================================================================
Bank14_AreaTypeTable:                       ; $41BA  (L1: wAreaType -> section table, 64 rows)
    dw $6AE2,$6AE2,$6AE2,$6AE2,$6AE2,$6AE2        ; areaType $00-$05
    dw $6AE2,$6AE2,$6AE2,$6AE2,$6AE2,$6AE2        ; areaType $06-$0B
    dw $6AE2,$6AE2,$6AE2,$6AE2,$6AE2,$6AE2        ; areaType $0C-$11
    dw $6AE2,$6AE2,$6AE2,$6AE2,$6AE2,$6AE2        ; areaType $12-$17
    dw $6AE2,$6AE2,$6AE2,$6AE2,$6AE2,$6AE2        ; areaType $18-$1D
    dw $6AE2,$6AE2,$423A,$423E,$4242,$4246        ; areaType $1E-$23
    dw $425A,$4264,$426E,$4278,$42B0,$42BA        ; areaType $24-$29
    dw $42C4,$42CE,$42FA,$4304,$430E,$4318        ; areaType $2A-$2F
    dw $4E48,$4F16,$507E,$524E,$5344,$54B6        ; areaType $30-$35
    dw $55B6,$5752,$5A4E,$5E26,$5F4A,$6148        ; areaType $36-$3B
    dw $6236,$6664,$68F2,$69E6                    ; areaType $3C-$3F
                                             ;   (out-of-range rows = $6AE2 placeholder)

Bank14_Area20_Sections:                     ; $423A  areaType $20  (1 section)
    dw $423C   ; section $00+
Bank14_Area20_Grids:                        ; $423C-$423E  (2 bytes)
    INCBIN "terry.gbc", $03823C, $0002

Bank14_Area21_Sections:                     ; $423E  areaType $21  (1 section)
    dw $4240   ; section $00+
Bank14_Area21_Grids:                        ; $4240-$4242  (2 bytes)
    INCBIN "terry.gbc", $038240, $0002

Bank14_Area22_Sections:                     ; $4242  areaType $22  (1 section)
    dw $4244   ; section $00+
Bank14_Area22_Grids:                        ; $4244-$4246  (2 bytes)
    INCBIN "terry.gbc", $038244, $0002

Bank14_Area23_Sections:                     ; $4246  areaType $23  (2 sections)
    dw $424A,$424C   ; section $00+
Bank14_Area23_Grids:                        ; $424A-$425A  (16 bytes)
    INCBIN "terry.gbc", $03824A, $0010
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0057 -> bank66 #87 : 「ここは　たびだちのへやです。 たびだちのとびらは　こちらです。 「ホィミンは　ここのとびらに にげこみ…
;     $011F -> bank67 #61 : 「ここは　たびだちのへやです。 「このおくにある　たびのとびらが たびだちのとびらです。

Bank14_Area24_Sections:                     ; $425A  areaType $24  (2 sections)
    dw $425E,$4260   ; section $00+
Bank14_Area24_Grids:                        ; $425E-$4264  (6 bytes)
    INCBIN "terry.gbc", $03825E, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $01A1 -> bank68 #9 : 「ここは まちびととまもりのへやです。 「うえが　まちびとのとびら。 したが　まもりのとびらです。

Bank14_Area25_Sections:                     ; $4264  areaType $25  (2 sections)
    dw $4268,$426A   ; section $00+
Bank14_Area25_Grids:                        ; $4268-$426E  (6 bytes)
    INCBIN "terry.gbc", $038268, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $01E1 -> bank68 #73 : 「ここは おもいでととまどいのへやだ。 「みぎが　とまどいの　とびら ひだりが　おもいでの　とびらだ。

Bank14_Area26_Sections:                     ; $426E  areaType $26  (2 sections)
    dw $4272,$4274   ; section $00+
Bank14_Area26_Grids:                        ; $4272-$4278  (6 bytes)
    INCBIN "terry.gbc", $038272, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $026E -> bank69 #42 : 「ここは やすらぎとゆうきのへやだ。 「みぎが　ゆうきの　とびら ひだりが　やすらぎの　とびらだ。

Bank14_Area27_Sections:                     ; $4278  areaType $27  (3 sections)
    dw $427E,$4280,$4298   ; section $00+
Bank14_Area27_Grids:                        ; $427E-$42B0  (50 bytes)
    INCBIN "terry.gbc", $03827E, $0032
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $029C -> bank69 #88 : 「〈テリー〉さんっ　ここが ちからといかりのへやです！ 「みぎにある　いかりのとびらの ようすが　おかし…
;     $032E -> bank70 #46 : 「〈テリー〉さん！ おかげさまで　すくわれました。 「ここは ちからといかりのへやです。 「みぎが　いか…
;     $082A -> bank78 #87 : 「おうひさまは　キラーェィプを ごらんになりたい　ごようす。 「キラーェィプの　ちが　さらに こくなると…
;     $029D -> bank69 #89 : 「いかりのとびらに まものが　あふれかえっています！ 「なんとかしないと　こちらの せかいも　たいへんな…
;     $032F -> bank70 #47 : 「ありがとう　ございました！ 〈テリー〉さん！ 「これで　ほかの　マスターたちも あんしんして　ぼうけん…
;     $082B -> bank78 #88 : 「おうひさまは　ホーンビートルを ごらんになりたい　ごようす。 「ホーンビートルは　がんせき おとしを　…

Bank14_Area28_Sections:                     ; $42B0  areaType $28  (2 sections)
    dw $42B4,$42B6   ; section $00+
Bank14_Area28_Grids:                        ; $42B4-$42BA  (6 bytes)
    INCBIN "terry.gbc", $0382B4, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $035D -> bank70 #93 : 「ここは よろこびとちえのとびらです。 「みぎが　ちえのとびらで ひだりが　よろこびのとびらです。

Bank14_Area29_Sections:                     ; $42BA  areaType $29  (2 sections)
    dw $42BE,$42C0   ; section $00+
Bank14_Area29_Grids:                        ; $42BE-$42C4  (6 bytes)
    INCBIN "terry.gbc", $0382BE, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $03DD -> bank71 #21 : 「ここは しあわせとさそいのへやです。 「みぎが　さそいのとびら。 ひだりが　しあわせのとびらです。

Bank14_Area2A_Sections:                     ; $42C4  areaType $2A  (2 sections)
    dw $42C8,$42CA   ; section $00+
Bank14_Area2A_Grids:                        ; $42C8-$42CE  (6 bytes)
    INCBIN "terry.gbc", $0382C8, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0408 -> bank71 #64 : 「ここは まよいとさばきのへやです。 「みぎが　さばきのとびらで ひだりが　まよいのとびらです。

Bank14_Area2B_Sections:                     ; $42CE  areaType $2B  (2 sections)
    dw $42D2,$42D4   ; section $00+
Bank14_Area2B_Grids:                        ; $42D2-$42FA  (40 bytes)
    INCBIN "terry.gbc", $0382D2, $0028
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $046A -> bank71 #162 : 「ここは　かがみのへやです、。 お　おきをつけください、、。 「じつは、　いや　やっぱり やめようかな。…
;     $046B -> bank71 #163 : 「じつは、　かがみのとびらにゆき かえれたものが　いないのです！ 「せいかくにいえば　もどってこれた も…
;     $046C -> bank71 #164 : 「そ　それが　いいとおもいます。 おひきとめして　すいません、。
;     $04DE -> bank72 #106 : 「かがみのとびらに　はいって ちゃんと　もどってこれたのは、 「〈テリー〉さん！ あなたが　はじめてです…
;     $082C -> bank78 #89 : 「おうひさまは　しにがみを ごらんになりたい　ごようす。 「しにがみは　どく　マヒ　のろいに ひじょうに…

Bank14_Area2C_Sections:                     ; $42FA  areaType $2C  (2 sections)
    dw $42FE,$4300   ; section $00+
Bank14_Area2C_Grids:                        ; $42FE-$4304  (6 bytes)
    INCBIN "terry.gbc", $0382FE, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $082D -> bank78 #90 : 「おうひさまは　ひくいどりを ごらんになりたい　ごようす。 「ひくいどりは　ある　まものと はいごうする…

Bank14_Area2D_Sections:                     ; $4304  areaType $2D  (2 sections)
    dw $4308,$430A   ; section $00+
Bank14_Area2D_Grids:                        ; $4308-$430E  (6 bytes)
    INCBIN "terry.gbc", $038308, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $082E -> bank78 #91 : 「こちらに　おわすのが タィジャこく　おうひさまです。 「そして　おうひさまに　まねかれた メダルおじさ…

Bank14_Area2E_Sections:                     ; $430E  areaType $2E  (2 sections)
    dw $4312,$4314   ; section $00+
Bank14_Area2E_Grids:                        ; $4312-$4318  (6 bytes)
    INCBIN "terry.gbc", $038312, $0006
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $082F -> bank78 #92 : ミレーヨ「けいとうが　？？？？の まものは　もう　つかまえた？ ミレーヨ「はいごうすると　かたちの かわ…

Bank14_Area2F_Sections:                     ; $4318  areaType $2F  (15 sections)
    dw $4336,$4BB8,$4BBC,$4BC0,$4BC4,$4BC8,$4BCC,$4BD0   ; section $00+
    dw $4BF2,$4C00,$4C04,$4D50,$4D54,$4D58,$4E0C   ; section $08+
Bank14_Area2F_Grids:                        ; $4336-$4E48  (2834 bytes)
    INCBIN "terry.gbc", $038336, $0B12
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $00E9 -> bank67 #7 : 「ひゃ！　なんじゃ？　なんじゃ？ まえから　はなしかけい！
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $0068 -> bank66 #104 : 「まものにも　せいかくが あります。 「えらんだ　さくせんによって せいかくは　へんかするそうです。 「…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0511 -> bank72 #157 : ミレーヨ「ふわあ、、。 よく　ねていたみたいね、、。 ミレーヨ「あら？　テリー いつから　おきていたの？…
;     $0512 -> bank73 #0 : ミレーヨ「そうね。　ほんとうに たたかったような　きがするけど、 ミレーヨ「やっぱり　ゆめよ。 ゆめのな…
;     $00EB -> bank67 #9 : どこからともなく　こえがきこえる。
;     $0513 -> bank73 #1 : ミレーヨ「そうね。　ほんとうに たのしい　ゆめだったね！ ミレーヨ「さあ　テリー。　もうひと ねむりしま…
;     $00EC -> bank67 #10 : 「かくとう　もうしこまざるもの たちいる　しかくなし！！
;     $005F -> bank66 #95 : 「このかいだんを　のぼると モンスターぼくじょうです。
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $0100 -> bank67 #30 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかには　おばさんの てちょうが　はいっている。 「きょうい…
;     $0101 -> bank67 #31 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかに　かみきれが　はいっていた。 かみきれには　なにか　か…
;     $0518 -> bank73 #6 : わたほ゛う「その　おにく　くれよ。
;     $0102 -> bank67 #32 : 「ふう、、。　なかなか いうことを　きかんわい。 「まだまだ　かしこさが たりないのかも　しれんな。
;     $0519 -> bank73 #7 : わたほ゛う「おにく　くれたら なかまに　なってやるよ！！
;     $0400 -> bank71 #56 : 「がいこくにあらわれた　おそろしい マスターの　うわさですが、 「みたこともない　まものをあやつり すご…
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $00EE -> bank67 #12 : 「ふがあ　ふがあ、、。
;     $05B4 -> bank73 #162 : わたほ゛う「おはよう　〈テリー〉！ ぼうけんの　じかんだぞ！！ わたほ゛う「ぼくしゃで　まってるから す…
;     $0030 -> bank66 #48 : 「ぼくじょうの　プリォは ドジですが　とてもいいやつです。 EN: A townsperson: "Pr…
;     $00EF -> bank67 #13 : 「このおくでは　こどもたちに まもののことを　おしえている。 「そなたも　はなしを きいてみると　いいだ…
;     $0060 -> bank66 #96 : 「ここは　タィジャの　おしろです。 「したに　すすんで　そとにでれば タィジャのまち　ですよ。
;     $0054 -> bank66 #84 : 「たびのとびらには　あちこちに どうぐが　おちています。 「それらのどうぐを　うまくつかって ぼうけんし…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0016 -> bank66 #22 : 「おうさまは　こまっている。 どうか　ちからになってほしい。
;     $0098 -> bank66 #152 : 「いくぜ！　よういは　いいか！？ ただ　つきすすむのみ！！
;     $000C -> bank66 #12 : テリーは　ほんだなを　しらべた。 むずかしくて　よめない！
;     $0009 -> bank66 #9 : 「わた　わた。　ミレーヨは どこにいるのかな？　わた　わた。
;     $000A -> bank66 #10 : 「まものの　ことばが わかるんだな？ 「ミレーヨが　どこにいるか しらないか？ 「、さらわれた？！ そう…
;     $0201 -> bank68 #105 : 「なんて　いやな　やろうだ あの　しょうにん！ 「うりたくないなら　みせなんて たたんじまえ！
;     $00F0 -> bank67 #14 : 「コドラは　どこら？
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $0514 -> bank73 #2 : ミレーヨ「おやすみ　テリー！ たのしいゆめが　みれますように！
;     $0515 -> bank73 #3 : ミレーヨ「おやすみ　テリー！ ゆめのつづきは　ベッドでね！
;     $000B -> bank66 #11 : テリーは　ほんだなを　しらべた。 「まもの　だいずかん さくしゃ　、　、　ふめい　、　、。
;     $051A -> bank73 #8 : テリーは　ほんだなを　しらべた。 「まもの　だいずかん さくしゃ　、　、　〈テリー〉　、　！
;     $0300 -> bank70 #0 : 「まあ。ちっちゃな　どろぼうさん。 でも　もう　おねむのじかんよ。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0048 -> bank66 #72 : プリォ「おうさま　おゆるしくだせー！ ホィミンも　にげてしまっただ！ EN: Prio: "My Kin…
;     $051B -> bank73 #9 : [E9]カテリーは　タンスのなかを　しらべた。 とくに　なにも　みつからなかった。
;     $00EA -> bank67 #8 : 「キユ！　いま　さわったでしょ！ ぷん　ぷん。
;     $000E -> bank66 #14 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $000D -> bank66 #13 : テリーは　めのまえを　しらべた。 はしらどけいが　まよなかを つげている、、。
;     $0516 -> bank73 #4 : ミレーヨ「、、あら？　、テリー！
;     $0517 -> bank73 #5 : ミレーヨ「ポケット　ふくらんでるよ。 なにか　はいっているの？
;     $00ED -> bank67 #11 : 「ここ　こ　こんにちは！ テ　テテ、　テトともうします。 「もうすぐしあいが　はじまるので きんちょうし…
;     $0047 -> bank66 #71 : おう「プリォよ！　ひょっとして そなた　ホィミンもにがしたか！？ EN: King: "Prio! Do…

Bank14_Area30_Sections:                     ; $4E48  areaType $30  (2 sections)
    dw $4E4C,$4E5C   ; section $00+
Bank14_Area30_Grids:                        ; $4E4C-$4F16  (202 bytes)
    INCBIN "terry.gbc", $038E4C, $00CA
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $003D -> bank66 #61 : 「さあ　こい。とっちめてやるだ！ くんくん　くんくん　、、　！ 「なんだ　モンスターマスターか。 おらは…
;     $000B -> bank66 #11 : テリーは　ほんだなを　しらべた。 「まもの　だいずかん さくしゃ　、　、　ふめい　、　、。
;     $0059 -> bank66 #89 : 「つよいね[94]！ 〈テリー〉のこと　きにいったよ！！ EN: Hoimin warms to the…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0307 -> bank70 #7 : 「、、、そん、な、、。 おいらの　ベテイ、、。 「マネマネだったなんて、、。 ゥソだ[91]、、！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0146 -> bank67 #100 : わたほ゛う「〈テリー〉！　やったな！ おしろに　もどしてやるよ！
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $013F -> bank67 #93 : 「なんべんいったら　わかるのさ？！ ぼくは　かえりたくないんだよ！

Bank14_Area31_Sections:                     ; $4F16  areaType $31  (3 sections)
    dw $4F1C,$4F2C,$4FB6   ; section $00+
Bank14_Area31_Grids:                        ; $4F1C-$507E  (354 bytes)
    INCBIN "terry.gbc", $038F1C, $0162
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0220 -> bank68 #136 : 「ハッ。 おうじさま！ 「わたしを　たすけに きてくれたのですね？〔はい/いいえ〕
;     $0221 -> bank68 #137 : 「そうですか、、。
;     $00B3 -> bank66 #179 : 「だまらっしゃい！ 「いま　たたかいかたを あんしょう　しておるのだ、、。
;     $0222 -> bank68 #138 : 「おしろに、かえりたい、、。
;     $00B4 -> bank66 #180 : 「だれが　なんといおうと　たたかい つづけるのだ。　よいな！？
;     $0223 -> bank68 #139 : 「はあ、、。
;     $00B5 -> bank66 #181 : 「わたしの　どこが　おもいやりが ないって　いうんですか？！ 「、、すねてやる！！
;     $0224 -> bank68 #140 : 「おしろに　かえりたい、。
;     $0227 -> bank68 #143 : 「、、いいのです。　あなたは　まだ おちいさいのですもの。 「だから　もちあげられないのです。 「そ、そ…
;     $0228 -> bank68 #144 : 「そ、そうと　いってくださいまし！ 〔はい/いいえ〕
;     $0229 -> bank68 #145 : 「では　わたくしは　もうすこし おおきいかたを　おまちします。
;     $00B6 -> bank66 #182 : 「、、べつに ひねくれてなんか　ないやい！
;     $0250 -> bank69 #12 : 「わたしには　わかるのです。 「やがて　ひとりの　わかものが やってくるでしょう。 「しかし　それは あ…
;     $0225 -> bank68 #141 : 「まっ　うれしい！ 、、、ぽっ。 「どうぞ　わたしを　だきあげて おしろへ　つれていってください！
;     $0226 -> bank68 #142 : 〈テリー〉は　おひめさまを だきかかえようとした！ しかし　もちあげられなかった！
;     $00B2 -> bank66 #178 : 「てやんでい！ 「かいふくなんて　まどろっこしい！ べらんめえ！
;     $0251 -> bank69 #13 : 「グオー　グオー、、。
;     $0252 -> bank69 #14 : 「グオー　グオー、、。 スー　パチン！ 「ひ　さ　し　ぶ　り　だ　な きゃ　く　じ　ん　は　！　！
;     $00B7 -> bank66 #183 : 「どうして　わたしが　ひねくれて いるんですか！？ 「くそ[93]！　ひねくれてやる！
;     $001F -> bank66 #31 : 「ここは　タィジャのくにだよ！
;     $0254 -> bank69 #16 : 「お　ま　え　つ　よ　い　！　！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0255 -> bank69 #17 : わたほ゛う「おひめさまを　もちあげられ なかったんだな！ わたほ゛う「ざんねんだったな[91]！ さあ　…
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0011 -> bank66 #17 : 「おっ。　わたぼうが　あたらしい マスターを　つれてきたのかい？
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0253 -> bank69 #15 : 「、・・・。　ま　た あ　そ　び　に　き　た　か　！

Bank14_Area32_Sections:                     ; $507E  areaType $32  (3 sections)
    dw $5084,$5180,$5184   ; section $00+
Bank14_Area32_Grids:                        ; $5084-$524E  (458 bytes)
    INCBIN "terry.gbc", $039084, $01CA
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0102 -> bank67 #32 : 「ふう、、。　なかなか いうことを　きかんわい。 「まだまだ　かしこさが たりないのかも　しれんな。
;     $0054 -> bank66 #84 : 「たびのとびらには　あちこちに どうぐが　おちています。 「それらのどうぐを　うまくつかって ぼうけんし…
;     $0305 -> bank70 #5 : 「またきたわね。 こらしめてあげる！！
;     $00B8 -> bank66 #184 : 「え？　これから　しあいだって？ うむ。　いきたくないな。 「は？　やっぱり　やめた？ では　しあいに　…
;     $0256 -> bank69 #18 : 「、、。
;     $0257 -> bank69 #19 : 「ちょっと まって　ほしいんだな。 「ここは　とおって ほしくないんだな。 「なぜって　ぼくはゴーレムで…
;     $00B9 -> bank66 #185 : 「てきには　こうげきしか したくないやい！
;     $0259 -> bank69 #21 : 「おまえ　つよいんだな。 「でも　ぼくに　かっても まちには　はいれないんだな、。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0262 -> bank69 #30 : わたほ゛う「このまちは　ゴーレムが みている　まぼろしのまちなんだ。 わたほ゛う「だから　なかに はいる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0012 -> bank66 #18 : 「そうじゃ。　これから　おうさまに あわせに　ゆくところじゃ。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0258 -> bank69 #20 : 「なんべん　いったら わかるのかな。 「ここは　とおって ほしくないんだな！！

Bank14_Area33_Sections:                     ; $524E  areaType $33  (2 sections)
    dw $5252,$5262   ; section $00+
Bank14_Area33_Grids:                        ; $5252-$5344  (242 bytes)
    INCBIN "terry.gbc", $039252, $00F2
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0263 -> bank69 #31 : 「ガルルルルル、、 フーッ　フーッ！
;     $00BA -> bank66 #186 : 「わるいが　こうげき　ちゅうしんで いかせてもらう！！
;     $0264 -> bank69 #32 : 「ゲラゲラ、、？ ゲルゲル、、？
;     $00BB -> bank66 #187 : 「わが　みちを　ゆく！
;     $0265 -> bank69 #33 : 「ガルルルルル、、 フーッ　フーッ！ 「、、、、、、、、ゲレゲレ！！
;     $00BC -> bank66 #188 : 「わたしに　さしず　するきか！？ なんと　あつかましいやつ、、。
;     $0033 -> bank66 #51 : 「どこかに　おにく おちてないかな？
;     $0267 -> bank69 #35 : 「〈テリー〉！ 〈テリー〉！！ 「みゃーお　ゴロゴロ、、。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0407 -> bank71 #63 : 「いのちのきのみじゃ。 だいじに　つかうがよいぞ。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0268 -> bank69 #36 : わたほ゛う「キラーパンサーは 〈テリー〉に　なついたみたいだな！ わたほ゛う「さあ　かえろう！
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0013 -> bank66 #19 : 「ほしふりのたいかいで ゆうしょうしてくれよ[95]！
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0266 -> bank69 #34 : 「ガルルルルル、、 ゲレゲレ！！

Bank14_Area34_Sections:                     ; $5344  areaType $34  (11 sections)
    dw $535A,$536A,$536E,$542A,$5442,$545A,$5472,$548A   ; section $00+
    dw $5492,$54A0,$54AE   ; section $08+
Bank14_Area34_Grids:                        ; $535A-$54B6  (348 bytes)
    INCBIN "terry.gbc", $03935A, $015C
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0269 -> bank69 #37 : 〈テリー〉は　たてふだを　よんだ。 「わかいうちは　あせっても　だめ！ とおまわりも　たまには　ひつよう…
;     $026A -> bank69 #38 : 「キーキキキッ！ よく　ここまで　これたのう！ 「じゃが　ざんねんなことに ここが　いきどまりなんじゃ！
;     $0117 -> bank67 #53 : 〈テリー〉は　こくばんに　かかれた もじを　よんだ。 「モンスターマスターの　こころえ、 「まものは　た…
;     $0035 -> bank66 #53 : 「だめです！　したに　おちたら いたいですよ！
;     $0290 -> bank69 #76 : 「ファッ　ファッ　ファッ。 わしを　たおしよったわい！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0205 -> bank68 #109 : コチンッ！ 〈テリー〉に　あたったフンは かたかった。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0293 -> bank69 #79 : わたほ゛う「もりの　めいろを よく　かいけつ　したね。 わたほ゛う「たまには　とおまわり するのも　いい…
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0014 -> bank66 #20 : 「さあ。　おうさまに　あいに ゆくのじゃ。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $026B -> bank69 #39 : 「なんべん　たたかっても おなじことよのう！
;     $0291 -> bank69 #77 : 「キーキキキッ。
;     $0155 -> bank67 #115 : 「そうですか。 、、、は[91]。
;     $00BD -> bank66 #189 : 「こまってる　まものを　みると ほっとけないんです！
;     $0292 -> bank69 #78 : 「、、。
;     $00BE -> bank66 #190 : 「いやー。　あまり　こうげきって すきじゃないんですよねー。
;     $00BF -> bank66 #191 : 「わたしは　みんなに　きもちよく たたかってもらえれば　いいです！
;     $00C0 -> bank66 #192 : 「きずつき　たおれそうなものを みると　いてもたってもおられぬ！
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0078 -> bank66 #120 : 「〈テリー〉よ！　わたしと　ともに せかいを　てにいれようぞ[95][95]！！
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0048 -> bank66 #72 : プリォ「おうさま　おゆるしくだせー！ ホィミンも　にげてしまっただ！ EN: Prio: "My Kin…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。

Bank14_Area35_Sections:                     ; $54B6  areaType $35  (4 sections)
    dw $54BE,$54CE,$54D2,$54D6   ; section $00+
Bank14_Area35_Grids:                        ; $54BE-$55B6  (248 bytes)
    INCBIN "terry.gbc", $0394BE, $00F8
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0294 -> bank69 #80 : 「いらっ、、、しゃい、、。
;     $0295 -> bank69 #81 : 「また、、きて、くれよ、、。
;     $0296 -> bank69 #82 : 「、、、、、、、。
;     $0037 -> bank66 #55 : 〈テリー〉は　たてふだを　よんだ。 「タィジャが　そだつとき おおきな　しんどうが　おこる。 「このあな…
;     $0297 -> bank69 #83 : 「、、、、、　、、。
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0204 -> bank68 #108 : 「、なんだ。　いないのか。 どうか　ォレに　よきょうを！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0298 -> bank69 #84 : わたほ゛う「ここは　そのむかし まものたちに　ほろぼされたんだ。 わたほ゛う「もう　ずいぶん むかしの　…
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0015 -> bank66 #21 : 「わたしは　このくにの　だいじん。 おまえが　あらたなマスターか？ 「おうさまが　おこまりなのだ。 どう…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…

Bank14_Area36_Sections:                     ; $55B6  areaType $36  (9 sections)
    dw $55C8,$55D8,$5602,$562C,$5648,$5664,$5668,$5676   ; section $00+
    dw $5684   ; section $08+
Bank14_Area36_Grids:                        ; $55C8-$5752  (394 bytes)
    INCBIN "terry.gbc", $0395C8, $018A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0299 -> bank69 #85 : 〈テリー〉は　スロットを　まわした！ カラカラとスロットは　まわっている。 、、　、、　、、　、、　、、…
;     $00C1 -> bank66 #193 : 「とっ　とりあえず　かいふくすれば よっ　よろしいでしょうかっ！？
;     $0311 -> bank70 #17 : 〈テリー〉は　スロットを　まわした！ しかし　まわらない。 レバーが　ポキッと　おれてしまった。
;     $00C2 -> bank66 #194 : 「う[9D]ん。　なにをしたら　いちばん みなさんの　やくにたつべか？
;     $0312 -> bank70 #18 : スロットは　こわれている。
;     $0313 -> bank70 #19 : 、なかで　[03]びきのスラィムが スラスラと　ねむっている。
;     $0314 -> bank70 #20 : 〈テリー〉は　スロットを　まわした！ スロットはゴロゴロと　まわっている。 、、　、、　、、　、、　、、…
;     $00C3 -> bank66 #195 : 「ううう、、。 にげるべきか　いくべきか、、。 「それが　もんだいだ！
;     $0315 -> bank70 #21 : 〈テリー〉は　スロットを　まわした！ しかし　まわらない。 どうやら　さびついているようだ。
;     $00C4 -> bank66 #196 : 「さくせん？　〈テリー〉がきめろよ。 わたしに　き　きかないでくれっ。
;     $0316 -> bank70 #22 : スロットは　こわれている。
;     $0317 -> bank70 #23 : なかで　[03]びきの　メタルスラィムが なかよく　あせを　ながしあっている。
;     $0318 -> bank70 #24 : 〈テリー〉は　スロットを　まわした！ スロットはビャンビャンまわっている。 、、　、、　、、　、、　、、…
;     $00C5 -> bank66 #197 : 「こうげきした　つもりでも ぼうぎょ　しちゃうんですよ！
;     $0319 -> bank70 #25 : スロットは　めを　まわしている。
;     $0843 -> bank78 #112 : 「みなさん！ 〈テリー〉のしょうりです！！ 「こんかいは　〈テリー〉に ぐんばいが　あがりました！ 「ま…
;     $031A -> bank70 #26 : 〈テリー〉は　スロットを　まわした！ スロットは　おともなくまわっている。 、、　、、　、、　、、　、、…
;     $00C6 -> bank66 #198 : 「いくら　うっかりものでも みかたは　ちゃんと　たすけます！
;     $0322 -> bank70 #34 : スロットに　はりがみが　してある。 「うちどめ。
;     $0323 -> bank70 #35 : スロットに　はりがみがしてある。 「プロ　おことわり。
;     $0324 -> bank70 #36 : 「カジノへ　ようこそ！　ここの ゴールドは　まものせんようよ！
;     $0325 -> bank70 #37 : 「もうかりまっか？
;     $0326 -> bank70 #38 : 「べんきょうしまっせ。
;     $0327 -> bank70 #39 : 「あそこの　おきゃくさん たいど　わるいね！ 「なんとか　なんないですか？
;     $0328 -> bank70 #40 : 「ここは　ぼうりょく ついほうの　おみせです。
;     $0329 -> bank70 #41 : 「ゥ[9D]　ガルルルルル[9D]。 かからねえぞ！　このスロット！！
;     $032A -> bank70 #42 : 「ゥ[9D]　ギユルルルルル[9D]！　なんで おまえばっかり　もうけてるんだ！ 「その　まものゴールド…
;     $00C7 -> bank66 #199 : 「うっかりまもの　といえば あたしの　ことでさあ！
;     $004B -> bank66 #75 : プリォ「おうさま！　ホィミンは たびだちのとびらに　いっただ！ EN: Prio: "My King! …
;     $0346 -> bank70 #70 : 「きょうは　まったく ついてねえぜ！！ 「あんたには　ひつようないから まものゴールドは　もらっておく！…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0347 -> bank70 #71 : わたほ゛う「カジノは　たのしかったか？ おしろに　もどるよ。
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0016 -> bank66 #22 : 「おうさまは　こまっている。 どうか　ちからになってほしい。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $032B -> bank70 #43 : 「ぼっしゅうした　まものゴールドは かえさねえぞ！！

Bank14_Area37_Sections:                     ; $5752  areaType $37  (5 sections)
    dw $575C,$5818,$58DA,$59B2,$5A00   ; section $00+
Bank14_Area37_Grids:                        ; $575C-$5A4E  (754 bytes)
    INCBIN "terry.gbc", $03975C, $02F2
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0050 -> bank66 #80 : プリォ「〈テリー〉！　ごめんよ。 おらのために、、。 プリォ「そうだ。 いいこと　おしえるだ。 プリォ「…
;     $0060 -> bank66 #96 : 「ここは　タィジャの　おしろです。 「したに　すすんで　そとにでれば タィジャのまち　ですよ。
;     $0070 -> bank66 #112 : 「まものは　ぼうけんにつれていって もらえると　マスターになつくよ。 「ぎゃくに　あずけられっぱなしだと…
;     $03F6 -> bank71 #46 : 「ゆうきが　あれば　こえられる がけだって　あるんだよね！ 「キミに　ゆうきがあるか ためしてあげるよ！
;     $00C9 -> bank66 #201 : 「みなさんが　かいてきにたたかえる かんきょうを　ほしょうします！
;     $004D -> bank66 #77 : 「おうさまは　たいそう おいかりの　ごようす。 「どうか　たびだちのとびらに　いき ホィミンを　つれてき…
;     $051C -> bank73 #10 : 「ゆうきが　あれば　こえられる がけだって　あるんだね！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $0406 -> bank71 #62 : 「わたしの　うごくせきぞうは ぱふぱふが　つかえるのよ！ 「ぱふぱふって　おとこのまものも つかえるのよ…
;     $051D -> bank73 #11 : わたほ゛う「みえないゆかを　よく みやぶったな！　さあ　かえろう！
;     $0407 -> bank71 #63 : 「いのちのきのみじゃ。 だいじに　つかうがよいぞ。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0017 -> bank66 #23 : 「どうか　おうさまの　ねがいを きいてあげてください。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0467 -> bank71 #159 : 「また　きたね。 そのゆうきは　ほんものかな？
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0105 -> bank67 #35 : 「[10]クラスの　さいしゅうせんは じゅくちょうが　あいてだぜ。
;     $03F5 -> bank71 #45 : 「クソッ。　ここにも　なかったか。
;     $00C8 -> bank66 #200 : 「おや？　わたしの　なまえは なんだったっけか？？ 「うっかり　わすれてしまったよ。 ハッハッハ！
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $0037 -> bank66 #55 : 〈テリー〉は　たてふだを　よんだ。 「タィジャが　そだつとき おおきな　しんどうが　おこる。 「このあな…
;     $0078 -> bank66 #120 : 「〈テリー〉よ！　わたしと　ともに せかいを　てにいれようぞ[95][95]！！

Bank14_Area38_Sections:                     ; $5A4E  areaType $38  (17 sections)
    dw $5A70,$5B26,$5BDE,$5BE6,$5BEE,$5BF6,$5BFE,$5C06   ; section $00+
    dw $5C0E,$5C16,$5C1E,$5C26,$5C2E,$5C36,$5C3E,$5C46   ; section $08+
    dw $5D0C   ; section $10+
Bank14_Area38_Grids:                        ; $5A70-$5E26  (950 bytes)
    INCBIN "terry.gbc", $039A70, $03B6
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $0030 -> bank66 #48 : 「ぼくじょうの　プリォは ドジですが　とてもいいやつです。 EN: A townsperson: "Pr…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $051E -> bank73 #12 : 「うほっ。 うまそうな　にくがいる！
;     $00CA -> bank66 #202 : 「[01]クラスうえの　たたかいを したいならば、 「この　わたしを　つれていく べきですぞ！
;     $004F -> bank66 #79 : 「たびのとびらは　うずまきじょうの ふしぎな　くうかんのこと。 「なかにはいると　まかふしぎな いせかい…
;     $0520 -> bank73 #14 : 「うほっ。 にくくれりゃ　いうこときくきく！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0007 -> bank66 #7 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おんなものの　ふくが つまっている。
;     $0308 -> bank70 #8 : 「ベテイが　マネマネだった、。 ゥソだ[91]、、！！
;     $0521 -> bank73 #15 : わたほ゛う「おとしあな　たいへん だったようだね。　かえろうか！
;     $0407 -> bank71 #63 : 「いのちのきのみじゃ。 だいじに　つかうがよいぞ。
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $051F -> bank73 #13 : 「うほっ。 また　うまそうなにくが　きた！
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…
;     $0088 -> bank66 #136 : 「フハハハハ、！　わたしのかれいな こうげきを　みるがよい！！
;     $000A -> bank66 #10 : 「まものの　ことばが わかるんだな？ 「ミレーヨが　どこにいるか しらないか？ 「、さらわれた？！ そう…
;     $000C -> bank66 #12 : テリーは　ほんだなを　しらべた。 むずかしくて　よめない！
;     $0042 -> bank66 #66 : スラお「つよい　まものを そだててね。 EN: Sula-o: "Raise some strong m…
;     $008A -> bank66 #138 : 「そのうち[92]　なんとか[91] なるんじゃないですか[91]、、。
;     $0090 -> bank66 #144 : 「さあ　みなのもの。 わたしのまえに　ひざまずくのだ！ 「わたしより　つよいものなど このよに　おらん！…
;     $0104 -> bank67 #34 : 「へへっ！　にいちゃんよ[95]。 [10]クラスのあいてを　しりたいか？〔はい/いいえ〕
;     $0106 -> bank67 #36 : 「まっ　それも　いいだろうよ。
;     $0108 -> bank67 #38 : 「きりかぶおばけや　キリキリバッタ アントベア　グレムリンがいたな。 「きりかぶおばけは　ラリホーを と…
;     $010E -> bank67 #44 : 「ラィスボールって　なんじゃい！ おにぎりって　いわんか！！
;     $0110 -> bank67 #46 : 「おお　よくきたな　マス、ゴホン！ わしは　メダルおじさん。 「せかいじゅうに　ちらばる ちいさなメダル…
;     $014E -> bank67 #108 : おう「おお！　ちと　いいすぎたか。 、こんごも　たのむぞ　〈テリー〉！ おう「あずかりじょや　としょかん…
;     $0182 -> bank67 #160 : 「はじめまして。　わたしは あずかりじょを　やっております。 「ぼうけんでみつけた　おかねや どうぐを　…
;     $018A -> bank67 #168 : 〈テリー〉は　ほんだなを　しらべた。 「シォンよげんしょ、だい[01]せつ、 「きんぞくを　ねりあわせ　…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $00CB -> bank66 #203 : 「こうげきだけしか　のうのない やつと　いっしょにしないでくれ！

Bank14_Area39_Sections:                     ; $5E26  areaType $39  (5 sections)
    dw $5E30,$5E48,$5E4C,$5E50,$5F28   ; section $00+
Bank14_Area39_Grids:                        ; $5E30-$5F4A  (282 bytes)
    INCBIN "terry.gbc", $039E30, $011A
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0523 -> bank73 #17 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかには　すいこまれそうな まっくらやみが　ひろがっている。
;     $0522 -> bank73 #16 : 〈テリー〉は　たからばこを　しらべた！ たからばこは　なんと ミミックだった！！ しかし　ミミックは ゲ…
;     $0524 -> bank73 #18 : 「、、。
;     $0525 -> bank73 #19 : 「み[92]　た[91]　な[91]、、！！
;     $00CD -> bank66 #205 : 「ぽーっとしてれば　そのうち せんとうって　おわりますよねー。
;     $00CC -> bank66 #204 : 「ククッ。　このわたしの　どこに てぬかりが　あるだろうか！！
;     $0063 -> bank66 #99 : 「いやー。　とびおりるって きもちいいですね[94]！
;     $0527 -> bank73 #21 : 「ま[91]　け[94]　た[91]、、！！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0308 -> bank70 #8 : 「ベテイが　マネマネだった、。 ゥソだ[91]、、！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0528 -> bank73 #22 : わたほ゛う「よくやったな！　それじゃ か[91]　え[94]　ろ[95]　お[95]　か[91]　！
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0019 -> bank66 #25 : 「はやく　おうさまに あってくるんじゃ！
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0526 -> bank73 #20 : 「また　お[95]　ま[91]　え[94]　か[91]！！
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…

Bank14_Area3A_Sections:                     ; $5F4A  areaType $3A  (9 sections)
    dw $5F5C,$6018,$60CA,$6118,$6120,$6128,$6130,$6138   ; section $00+
    dw $6140   ; section $08+
Bank14_Area3A_Grids:                        ; $5F5C-$6148  (492 bytes)
    INCBIN "terry.gbc", $039F5C, $01EC
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0050 -> bank66 #80 : プリォ「〈テリー〉！　ごめんよ。 おらのために、、。 プリォ「そうだ。 いいこと　おしえるだ。 プリォ「…
;     $0060 -> bank66 #96 : 「ここは　タィジャの　おしろです。 「したに　すすんで　そとにでれば タィジャのまち　ですよ。
;     $0070 -> bank66 #112 : 「まものは　ぼうけんにつれていって もらえると　マスターになつくよ。 「ぎゃくに　あずけられっぱなしだと…
;     $0529 -> bank73 #23 : 「キイ　キイ。 あったりー！
;     $007D -> bank66 #125 : 「フッ、、。 「おのれの　じつりょくのみで しょうぶする！
;     $052A -> bank73 #24 : 「おんやま[91]　あんた つよいね[94]！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0105 -> bank67 #35 : 「[10]クラスの　さいしゅうせんは じゅくちょうが　あいてだぜ。
;     $052B -> bank73 #25 : わたほ゛う「よく　スカィドラゴンの うごきを　よめたね。 わたほ゛う「なかなか　あたま いいじゃないか。…
;     $0406 -> bank71 #62 : 「わたしの　うごくせきぞうは ぱふぱふが　つかえるのよ！ 「ぱふぱふって　おとこのまものも つかえるのよ…
;     $001A -> bank66 #26 : 「そうですか、、。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $003A -> bank66 #58 : 〈テリー〉は　ツボのなかを のぞきこんだ。
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $0078 -> bank66 #120 : 「〈テリー〉よ！　わたしと　ともに せかいを　てにいれようぞ[95][95]！！
;     $0038 -> bank66 #56 : 「プリォが　まものを にがしちまったんだぜ。 EN: Gossip: "Prio let the mon…

Bank14_Area3B_Sections:                     ; $6148  areaType $3B  (2 sections)
    dw $614C,$615C   ; section $00+
Bank14_Area3B_Grids:                        ; $614C-$6236  (234 bytes)
    INCBIN "terry.gbc", $03A14C, $00EA
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $052C -> bank73 #26 : 「どうだい　おれの　かれいな あしさばき？
;     $00CE -> bank66 #206 : 「わたしが　こうげきするころには いつも　せんとうは　おわってる。 「いったい　どうしてだろう、、？？
;     $052D -> bank73 #27 : 「どうだい　おれといっしょに おどらないか？
;     $00CF -> bank66 #207 : 「そのうち　かてますよね！
;     $007B -> bank66 #123 : 「ほかの　なかまの　こうげきを てつだうのは　どうもな[91]、。
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $052F -> bank73 #29 : 「おまえ　おどりうまいな！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0530 -> bank73 #30 : わたほ゛う「おどりは　たのしかったか？ そんじゃ　かえるよ！
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $001C -> bank66 #28 : 〈テリー〉は　やくそうを てにいれた。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $052E -> bank73 #28 : 「また　おれと　おどりにきたな！ さあ　いくぞ！

Bank14_Area3C_Sections:                     ; $6236  areaType $3C  (9 sections)
    dw $6248,$62FA,$6320,$6346,$636C,$6392,$63B8,$63DE   ; section $00+
    dw $6404   ; section $08+
Bank14_Area3C_Grids:                        ; $6248-$6664  (1052 bytes)
    INCBIN "terry.gbc", $03A248, $041C
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $006F -> bank66 #111 : 「おにくのしゅるい！　まもののェサ くんせいにく　ほねつきにく。 「いちばん　おいしくないのは まものの…
;     $0070 -> bank66 #112 : 「まものは　ぼうけんにつれていって もらえると　マスターになつくよ。 「ぎゃくに　あずけられっぱなしだと…
;     $0071 -> bank66 #113 : 「よっ！ プリォが　よろこんでたぜ。
;     $0072 -> bank66 #114 : プリォ「ありがとう　〈テリー〉！ おかげで　たすかっただ！ プリォ「おれいに　いいこと 〈テリー〉に　お…
;     $0073 -> bank66 #115 : 「ここは　モンスター ぼくじょうだよ。 「スカィドラゴンさんの　したに いくと　なにかおちてくるよ！
;     $0074 -> bank66 #116 : 「わしのように　としをとるとな レベルが　あがらなくなるんじゃ。 「せいちょうの　げんかいに きてしまっ…
;     $0075 -> bank66 #117 : 「わたしは　みんなをまもり　かつ こうげきを　ほじょし　でも、 「てきに　こうげきもする。 、、そんな　…
;     $0076 -> bank66 #118 : 「フンガー！ 「〈テリー〉さん！ ごあんしんを！！
;     $0088 -> bank66 #136 : 「フハハハハ、！　わたしのかれいな こうげきを　みるがよい！！
;     $00C4 -> bank66 #196 : 「さくせん？　〈テリー〉がきめろよ。 わたしに　き　きかないでくれっ。
;     $0102 -> bank67 #32 : 「ふう、、。　なかなか いうことを　きかんわい。 「まだまだ　かしこさが たりないのかも　しれんな。
;     $0110 -> bank67 #46 : 「おお　よくきたな　マス、ゴホン！ わしは　メダルおじさん。 「せかいじゅうに　ちらばる ちいさなメダル…
;     $014C -> bank67 #106 : 「まちびととまもりのへやは たびのとびらのまに　ある。 「こんごは　かくとうじょうで ラィバルに　かって…
;     $00C6 -> bank66 #198 : 「いくら　うっかりものでも みかたは　ちゃんと　たすけます！
;     $010E -> bank67 #44 : 「ラィスボールって　なんじゃい！ おにぎりって　いわんか！！
;     $0084 -> bank66 #132 : 「ひとりに　してくれないか、、。
;     $00C2 -> bank66 #194 : 「う[9D]ん。　なにをしたら　いちばん みなさんの　やくにたつべか？
;     $02A2 -> bank69 #94 : 〈テリー〉は　タマゴを　しらべた。 なかから　まものが　あらわれた！
;     $015D -> bank67 #123 : 〈テリー〉は　ツボのなかを のぞきこんだ。 しかし　なにもなかった。
;     $02A3 -> bank69 #95 : 〈テリー〉は　タマゴを　しらべた。 タマゴは　われている。
;     $029E -> bank69 #90 : 「このよで　わがしゅぞくが もっとも　はんえいすること、。 「それが　わがのぞみ。 なにを　しにきたか　…
;     $029F -> bank69 #91 : 「このよで　わがしゅぞくが もっとも　はんえいすること、。 「それが　わがのぞみ。 きさま　わたしのタマ…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0100 -> bank67 #30 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかには　おばさんの てちょうが　はいっている。 「きょうい…
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0030 -> bank66 #48 : 「ぼくじょうの　プリォは ドジですが　とてもいいやつです。 EN: A townsperson: "Pr…
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0101 -> bank67 #31 : 〈テリー〉は　ツボのなかを のぞきこんだ。 なかに　かみきれが　はいっていた。 かみきれには　なにか　か…
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0103 -> bank67 #33 : 「えいほ　えいほ。 「あーあ　はらが　へったなあ、。 「こんなんじゃ　めいれいされても はらがたつだけだ…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $02A0 -> bank69 #92 : 「クソッ　ここにも　ないのか！！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0064 -> bank66 #100 : 「おお　〈テリー〉か。 わしも　としじゃのう。 「かいだんを　おりるのも ひとくろうじゃい。 「、、かく…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $02A1 -> bank69 #93 : 「なんだ　おまえは？ 、、まものつかいだな。 「フッ。　けんも　ろくに あつかえない　こしぬけかっ！
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0077 -> bank66 #119 : 「フハハハハハ、、！！ 「ま[9B]か[9B]せ　なさい！
;     $02A4 -> bank69 #96 : 「ぬ[95][95]おお！！　だいじなタマゴを すべて　わってしまうとは、、！！ 「きさまの　なかまの　…
;     $0078 -> bank66 #120 : 「〈テリー〉よ！　わたしと　ともに せかいを　てにいれようぞ[95][95]！！
;     $0065 -> bank66 #101 : 「わたしも　ちいさなメダルを ひろったことが　あります。 「あれは　たびのとびらから ぼうけんに　でてい…
;     $02A6 -> bank69 #98 : 「あの　けんし、 おまえに　よく　にていた、。
;     $0204 -> bank68 #108 : 「、なんだ。　いないのか。 どうか　ォレに　よきょうを！！
;     $02A7 -> bank69 #99 : わたほ゛う「まもののかずが　ふえたのは タマゴのせいだったんだね。 わたほ゛う「これで　おうさまの たの…
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $001D -> bank66 #29 : 〈テリー〉は　やくそうを みつけた。 しかし　もちものが いっぱいだ。 〈テリー〉は　やくそうを たから…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $02A5 -> bank69 #97 : 「また　おまえか！　わがこのうらみ なんどでも　つぐなわせてやるわ！

Bank14_Area3D_Sections:                     ; $6664  areaType $3D  (4 sections)
    dw $666C,$66CC,$667C,$68D4   ; section $00+
Bank14_Area3D_Grids:                        ; $666C-$68F2  (646 bytes)
    INCBIN "terry.gbc", $03A66C, $0286
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0018 -> bank66 #24 : 「ここは　タィジャの　おしろです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0003 -> bank66 #3 : テリーは　めのまえを　しらべた。 ほのおから　うまれた　ひのこが パチパチと　はじけては　きえていく。
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $00A8 -> bank66 #168 : 「ひとつ　いいことをおしえよう。 おうごんのスラィムのでんせつだ。 「、あるひ　スラィムのおうさまが お…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0048 -> bank66 #72 : プリォ「おうさま　おゆるしくだせー！ ホィミンも　にげてしまっただ！ EN: Prio: "My Kin…
;     $0305 -> bank70 #5 : 「またきたわね。 こらしめてあげる！！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0010 -> bank66 #16 : 「このくには　おおきな　きのなかに つくられておるんじゃ。 「ここは　いちばんしたで おしろは　いちばん…
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0405 -> bank71 #61 : 「、、そう。 きが　かわったら　あいにきてね。
;     $0055 -> bank66 #85 : 「おうさまは　とても　ホィミンを かわいがっていました。 「なぜ　にげだしたり したのか、、。 「あちら…
;     $0040 -> bank66 #64 : 「ぼく　スラお。スラぼうじいさんの まご　なんだ。 スラお「ぼくじょうのこと　しりたい？ 〔はい/いいえ…
;     $0066 -> bank66 #102 : 「たびのとびらの　いちらんを ごらんになりますか？〔はい/いいえ〕
;     $0531 -> bank73 #31 : どこからともなく　こえが きこえてくる、、。
;     $0532 -> bank73 #32 : 「もしもし、、。 そこの　たびのおかた、、。 「わたしは　このいずみにすむ せいれいです。 「あなたの　…
;     $0533 -> bank73 #33 : 「それでは　すこし おまちになってください。
;     $0534 -> bank73 #34 : 「では　もとのせかいに かえして　さしあげましょうか？〔はい/いいえ〕
;     $0535 -> bank73 #35 : 「ほんとうは　まものが おちたのでしょう？ 「たすけてきて さしあげましょう。 「それでは　すこし おま…
;     $0802 -> bank78 #47 : 「まものの　せいべつの かえかたを　ノートにうつしたよ。 「みたい？ 〔はい/いいえ〕
;     $0536 -> bank73 #36 : 「いずみに　おちたのは この　おにく　ですか？〔はい/いいえ〕
;     $0537 -> bank73 #37 : 「、、あなたは ゥソつきですね。 「まものを　かえすから さっさと　たちさりなさい！
;     $0538 -> bank73 #38 : 「そうですか。　では　すこし まっていてください。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0080 -> bank66 #128 : 「てきが　どれほどつよくても わたしには　かんけいない！ 「ただ　しりょくをつくして たちむかうのみ！！
;     $0803 -> bank78 #48 : 〈テリー〉は　ノートを　ひらいた。 「けっとうにした　まものと　おなじ けいとうを　はいごうすると、 「…
;     $0539 -> bank73 #39 : 「では　いずみに　おちた　まものは この　おじさん　ですか？〔はい/いいえ〕
;     $053A -> bank73 #40 : 「、、あなたは ゥソつきですね。 「まものを　かえすから さっさと　たちさりなさい！
;     $053B -> bank73 #41 : 「そうですか。　では　すこし まっていてください。
;     $001A -> bank66 #26 : 「そうですか、、。
;     $0028 -> bank66 #40 : 「まものたちの　ことばを　りかいし あやつることができる　ひとびと。 「かんぜんに　まものと　わかりあえ…
;     $0801 -> bank78 #46 : 「かれのおやは　じいさんから うけついだ　とくぎのうち、 「ホィミしか　おぼえなかった。 ザォラルも　お…
;     $053C -> bank73 #42 : 「では　いずみに　おちた　まものは [F9][00]　ですね？〔はい/いいえ〕
;     $053D -> bank73 #43 : 「あなたは　よくわからない ひとですね、。 「おちた　まものは おかえしします。 「もとのせかいに おも…
;     $053E -> bank73 #44 : 「あなたは　しょうじきものです。 おちたまものを　おかえしします。 「それと　しょうじきに いってくれた…
;     $007F -> bank66 #127 : 「いのちしらずとは　いのちを だいじにせぬ　ことではない、。 「しのきょうふを　かんじぬほどに おのれに…
;     $001E -> bank66 #30 : 〈テリー〉は　たからばこを　あけた！
;     $053F -> bank73 #45 : 「おつかれさまです。もとのせかいに どうぞ　おもどりなさい、、。
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0540 -> bank73 #46 : 「おや？　またきましたね。 もとのせかいに　もどりますか？〔はい/いいえ〕
;     $0542 -> bank73 #48 : 「それでは　ごきげんよう、、。
;     $0541 -> bank73 #47 : 「どうぞ　ごゆっくり。

Bank14_Area3E_Sections:                     ; $68F2  areaType $3E  (2 sections)
    dw $68F6,$6906   ; section $00+
Bank14_Area3E_Grids:                        ; $68F6-$69E6  (240 bytes)
    INCBIN "terry.gbc", $03A8F6, $00F0
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0543 -> bank73 #49 : 「しょくん！ いまこそ　われらが　たちあがり、 「あたらしき　じだいの　とびらを ひらくときでは　なかろ…
;     $00D0 -> bank66 #208 : 「あわてない　あわてない。 しょうりは　やがてくるさ！
;     $0544 -> bank73 #50 : 「しもふりにくを　まいにち たべられるせかい！ 「そんなせかいを　わたしは しょくんに　やくそくする！！…
;     $00D1 -> bank66 #209 : 「え？　いいじゃないですか！ とりあえず　かいふくしましょ！
;     $0545 -> bank73 #51 : 「ムムム！！！？？？ せなかが　なぜか　むずがゆい。 「しょくん！　しばし　せを　むける ぶれいを　おゆ…
;     $00D2 -> bank66 #210 : 「いやいやいや。 まあ　おちゃでも　どうぞ。
;     $0093 -> bank66 #147 : 「たたかってやっても　いいけど かいふくは　しろよ。
;     $0547 -> bank73 #53 : 「いちにち　[01]この しもふりにくを　ようきゅうする！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0304 -> bank70 #4 : 「キーッ！　はっきりしないひとね！ ィラィラする！！ 「こらしめて　あげるわ！！！
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $0844 -> bank78 #113 : 「えらく　ちいさいマスターだな。 だが　てかげんはしないぞ！
;     $0401 -> bank71 #57 : 「おさけ　やめようと　おもう。 ゥイー　ヒック、、。
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $001F -> bank66 #31 : 「ここは　タィジャのくにだよ！
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $0546 -> bank73 #52 : 「しもふりにくは　とっても おいしい！　だからこそ、、 「ムム！！？？　またもや せなかが　こそばゆい！…

Bank14_Area3F_Sections:                     ; $69E6  areaType $3F  (2 sections)
    dw $69EA,$69FA   ; section $00+
Bank14_Area3F_Grids:                        ; $69EA-$6AE4  (250 bytes)
    INCBIN "terry.gbc", $03A9EA, $00FA
;   text refs in this grid (message id -> text bank #local ; heuristic set):
;     $0000 -> bank66 #0 : ミレーヨ「テリー！　まちなさいって！ もう　ねるじかんよ！ ミレーヨ「かあさんと　とうさんが いってたこ…
;     $0548 -> bank73 #54 : 「ケーケケケ。 むら　もやすのは　たのしいな。 「おまえも　やるか？ 〔はい/いいえ〕
;     $0549 -> bank73 #55 : 「ケーケケケ。 もやせ　もやせ[94]！！ 「おまえも　はやく もやしてこいー！
;     $054A -> bank73 #56 : 「なんだ　おまえら おもしろくない　やつらめ！ 「なんなら　おまえらに ひを　つけてやろうか！？
;     $00D3 -> bank66 #211 : 「〈テリー〉さん。 かたでも　おもみしましょうか？
;     $0097 -> bank66 #151 : 「う[95][95][95]おお！！ 「わたしのなかに　ちからが みなぎって　きました！！
;     $0095 -> bank66 #149 : 「やるときめたら　どこまでも やります！！
;     $0098 -> bank66 #152 : 「いくぜ！　よういは　いいか！？ ただ　つきすすむのみ！！
;     $054C -> bank73 #58 : 「にるなり　もやすなり すきにしやがれ！　うぐ！
;     $0008 -> bank66 #8 : 「おまえ　ミレーヨかっ？ 「、、いや　たしか　ミレーヨは おんなのこ　だったはずだ。 「なに？　なまえは…
;     $0001 -> bank66 #1 : ミレーヨ「　、　、　、　・・・。
;     $0005 -> bank66 #5 : テリーは　ほんだなを　しらべた。 「ミレーヨのにっき、 「きょうは　るすばん。　おそろしい まものが　で…
;     $0002 -> bank66 #2 : テリーは　ぬいぐるみを　しらべた。 ちいさく　かわいい　もじで なにか　かかれている。 「ミレーヨの　も…
;     $0409 -> bank71 #65 : 「しょうぶは　うんではないぞ。 じつりょくだけが　ぜったいじゃ！ 「たとえそなたが　メタルスラィムに よ…
;     $0004 -> bank66 #4 : テリーは　ほんだなを　しらべた。 「どうわ 「あるむらに　ちいさな　おとこのこと おんなのこが　すんでい…
;     $054D -> bank73 #59 : わたほ゛う「あちちち。 ひは　けしておくよ。 わたほ゛う「さあ！　おしろに　もどって ゆっくり　やすんで…
;     $0402 -> bank71 #58 : 「、、まけたわ。　かんぱいよ！ あなたのつよさは　ほんものだわ！ 「あなたに　わたしの まものを　あげる…
;     $0006 -> bank66 #6 : [E9]カテリーは　タンスのなかを　しらべた。 ちいさな　おとこものの　ふくが つまっている。
;     $0020 -> bank66 #32 : 「よくきた！　あらたなマスターよ！ わしは　このくにの　おうじゃ。 おう「そなたの　なは　なんともうす？…
;     $00E8 -> bank67 #6 : 「[10]クラスの　さいしゅうせんは マスターようせいじゅくの 「じゅくちょうが　あいてです。
;     $0058 -> bank66 #88 : 「はじめまして。 ぼく　ホィミン！ 「ぼくを　つかまえにきたんだろ？ でも　やだよ。 「ぼくじょうは　つ…
;     $054B -> bank73 #57 : 「また　きやがったか！ てめえ　ほんとに　ひをつけるぞ！

    ds $151C, $FF                   ; $6AE4-$7FFF padding
