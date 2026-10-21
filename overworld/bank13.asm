; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 13  (Tile movement engine, area types $06-$1F)
; ============================================================================
;
; File offset $34000-$37FFF (16 KB); mapped at $4000-$7FFF when bank reg = 13.
;
; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.
; Function table at $4001:  fn0 $4007 · fn1 $402F · fn2 $4110.
;   fn0 = READ map cell at coord (collision / event / NPC-text query)
;   fn1 = PAINT cell tile indices into $9800 BG map (scroll-fill)
;   fn2 = PAINT cell CGB attributes into VRAM bank 1 (VBK)
;
; SHARED ENGINE: code $4007-$41B9 is BYTE-FOR-BYTE identical to bank12/14/15
; (only the self-id byte at $4000 differs: $0D here). Full annotation below;
; see overworld/bank12.asm for the same routines under area type 0.
;
; DATA (this bank) = 26 area types ($06-$1F). bank4/Sub_71EF ($71EF) routes
; wAreaType ($D8D3) $06-$1F here (LD HL,$0D00; RST $10). The $41BA L1 table is
; indexed by the FULL wAreaType: rows $00-$05 alias placeholder grid $7C3E
; (owned by bank12); rows $06-$1F are real.
;
; TEXT REFERENCES: a cell value with high byte != $FF is a GLOBAL MESSAGE ID,
; routed by ROM0 MsgBankRouter ($0EC5) to dialogue banks 66-78 (local msg =
; global_id - bank_base; bank66 base $0000, 67 $00E2, 68 $0198, 69 $0244,
; 70 $0300, 71 $03C8, 72 $0474, 73 $0512, 74 $05E0, 75 $072B, 78 $07D3).
; bank13 grids reference 815 distinct message ids ($0000-$0881) across ALL of
; banks 66-75/78 -- this is the monster-BREEDING-RANCH / library interior set
; (egg appraiser, はいごう tutorial books, growth diaries, tutorial NPCs).
; See the WORKED EXAMPLES inline below (area types $09 and $0D) for decoded
; grids showing the flag-branch VM + Yes/No book pages + routed Japanese text.
; ============================================================================

SECTION "Bank 13 Functions", ROMX[$4000], BANK[13]

    db $0D                        ; $4000  self-id byte (bank number)
    dw $4007, $402F, $4110        ; $4001  function pointer table (fn0/fn1/fn2)

; ------------------------------------------------------------
; Bank13_Fn0/Fn1/Fn2 — shared map engine (identical to bank12 code)
; ------------------------------------------------------------
Bank13_Fn0:                                 ; $4007
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
; Bank13_Fn1  ($402F)  — paint a cell's TILE INDICES into the BG tilemap
; ------------------------------------------------------------
; VRAM bank 0 ($9800 map). Walks the cell's tile stream via Sub_40E7, then the
; blit loop at $407B writes tile bytes with LD (HL+),A, wrapping every 32 cols
; (AND $1F) and stepping to the next map row on the $D8 marker (+$20); $D9 ends.
; This is the metatile -> screen tilemap expansion for one scrolled-in column.
; ------------------------------------------------------------
Bank13_Fn1:                                 ; $402F
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
Bank13_Fn1_Blit:                            ; $407B
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
Bank13_Fn1_Emit:                            ; $40A9
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
Bank13_Sub_40DA:                            ; $40DA  — advance L by one column, wrap within 32
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
; Bank13_Sub_40E7  — walk a cell's TILE stream into a WRAM $C300 buffer
; ------------------------------------------------------------
; Reads cell ptr from (BC): a 16-bit index, +$C300 base -> WRAM tile-list
; source. Copies the tile bytes with LD (HL+),A until $D9; $D8 = next-row (+$20).
; Fills the shadow the blit loop then pushes to VRAM.
; ------------------------------------------------------------
Bank13_Sub_40E7:                            ; $40E7
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
; Bank13_Fn2  ($4110)  — paint a cell's CGB ATTRIBUTES into VRAM bank 1
; ------------------------------------------------------------
; Same prologue as fn1 (byte-identical), so it targets the SAME BG-map cell.
; Difference: it builds the per-tile CGB attribute bytes (palette/priority/
; bank/flip) via Sub_4171/Sub_4195 (source base $C200, packed as nibbles), then
; the tail flips VRAM bank via VBK ($FF4F=1), reuses the fn1 blit loop ($4075)
; to write into the attribute map, and restores VBK 0. Only runs when the
; CGB-attribute-dirty flag $C81D is set. fn1 = tiles, fn2 = colour attributes.
; ------------------------------------------------------------
Bank13_Fn2:                                 ; $4110
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
; Bank13_Sub_4171  — walk a cell's ATTRIBUTE stream into the $C200 nibble buf
; ------------------------------------------------------------
; Like Sub_40E7 but each cell entry updates a packed 4-bit attribute via
; Sub_4195: address >>1 selects a byte in the $C200 table, carry (odd/even)
; selects high vs low nibble, and the new value is merged in. $D8=next row,
; $D9=end. This produces the compact per-tile CGB attributes fn2 then blits.
; ------------------------------------------------------------
Bank13_Sub_4171:                            ; $4171
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
Bank13_Sub_4195:                            ; $4195  — merge attr value A into $C200[HL/2] nibble
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


SECTION "Bank 13 Map Data", ROMX[$41BA], BANK[13]
; ============================================================================
; MAP DATA — 3-level table: L1 wAreaType -> L2 section -> cell grid[coord].
;   Cell: $FFFF walk · $FFxx behavior (lo -> bank4 TileBehaviorTable $5620)
;   · $00xx-$08xx GLOBAL MESSAGE ID (routed by ROM0 $0EC5, see header).
;   $FF01 <flag> <ptr>       : IF event-flag SET -> branch to <ptr> else next
;   $FF15 <addr> <val> <ptr> : IF WRAM[addr]==val -> <ptr> (Yes/No via $C83C)
; ============================================================================
Bank13_AreaTypeTable:                       ; $41BA  (L1: wAreaType -> section table)
    dw $7C3E,$7C3E,$7C3E,$7C3E,$7C3E,$7C3E        ; areaType $00-$05
    dw $41FA,$4D22,$56DA,$5D12,$61E8,$6204        ; areaType $06-$0B
    dw $6208,$6270,$6454,$6458,$64B6,$6634        ; areaType $0C-$11
    dw $6638,$6830,$6898,$689C,$68A0,$6960        ; areaType $12-$17
    dw $6964,$6B0E,$6C76,$6E36,$6F40,$70B8        ; areaType $18-$1D
    dw $726A,$746C                                ; areaType $1E-$1F
                                             ;   ($00-$05 = $7C3E placeholder alias)

Bank13_Area06_Sections:                     ; $41FA  (12 sections)
    dw $4212,$4704,$4792,$4798,$479E,$47A4,$47AA,$497C   ; section $00+
    dw $4AF2,$4B00,$4B0E,$4B12   ; section $08+
Bank13_Area06_Grids:                        ; $4212-$4D22  (2832 bytes)
    INCBIN "terry.gbc", $034212, $0B10

Bank13_Area07_Sections:                     ; $4D22  (27 sections)
    dw $4D58,$4E14,$4F08,$4F2A,$5044,$5098,$50EC,$5124   ; section $00+
    dw $5190,$51D6,$51E8,$51EC,$520E,$5240,$5272,$529E   ; section $08+
    dw $52CA,$53D2,$5488,$553E,$5542,$5562,$5566,$556A   ; section $10+
    dw $55D4,$5646,$56B8   ; section $18+
Bank13_Area07_Grids:                        ; $4D58-$56DA  (2434 bytes)
    INCBIN "terry.gbc", $034D58, $0982

Bank13_Area08_Sections:                     ; $56DA  (1 section)
    dw $56DC   ; section $00+
Bank13_Area08_Grids:                        ; $56DC-$5D12  (1590 bytes)
    INCBIN "terry.gbc", $0356DC, $0636

Bank13_Area09_Sections:                     ; $5D12  (12 sections)
    dw $5D2A,$6000,$6004,$6016,$60A0,$60C6,$6152,$60C2   ; section $00+
    dw $6174,$6182,$61B2,$61D4   ; section $08+
Bank13_Area09_Grids_5D2A:                   ; $5D2A-$6004
    INCBIN "terry.gbc", $035D2A, $02DA
; ---------------------------------------------------------------------------
; WORKED EXAMPLE: 'monster grandpa breeding book' (a §$6004) — a Yes/No book
; ---------------------------------------------------------------------------
Bank13_Area09_Ex_6004:
    dw $01C1                    ; $6004  msg -> bank68 #41: 〈テリー〉は　ほんだなを　しらべた。 「モンスターじいさん　さく はいごう　とは、 ほんをよみますか？ 〔はい/いいえ〕
    dw $FF15,$C83C,$0001,$6012 ; $6006  IF ($C83C)==$1 -> $$6012  (Yes/No answer $C83C)
    dw $01C2                    ; $600E  msg -> bank68 #42: 「はいごうとは　まものと　まものを けっこんさせることじゃ。 「はいごうを　おこなうと　おやの まものは　どこかへ　さっ…
    dw $FFFF                    ; $6010  end / walkable
    dw $0026                    ; $6012  msg -> bank66 #38: 〈テリー〉は　ほんを ほんだなに　もどした。
    dw $FFFF                    ; $6014  end / walkable
; ---------------------------------------------------------------------------
; WORKED EXAMPLE: breeding library books/NPCs (a §$6016) — flag-gated + Yes/No pages
; ---------------------------------------------------------------------------
Bank13_Area09_Ex_6016:
    dw $FF01,$00F1,$6074   ; $6016  IF flag $F1 SET -> branch $$6074 (else next)
    dw $FF01,$0025,$6052   ; $601C  IF flag $25 SET -> branch $$6052 (else next)
    dw $FF01,$001D,$603A   ; $6022  IF flag $1D SET -> branch $$603A (else next)
    dw $01C3                    ; $6028  msg -> bank68 #43: 〈テリー〉は　ほんだなを　しらべた。 「きょうの　ひとこと、 「おやの　レベルが　たかいほど こどもの　のうりょくも　た…
    dw $FF15,$C83C,$0001,$6036 ; $602A  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $01C4                    ; $6032  msg -> bank68 #44: 「モンスターにっき さく　モンスターじいさん 「〈テリー〉という　しょうねんは なかなか　みどころのあるやつじゃ。 「ろ…
    dw $FFFF                    ; $6034  end / walkable
    dw $014F                    ; $6036  msg -> bank67 #109: 〈テリー〉は　にっきを ほんだなに　もどした。
    dw $FFFF                    ; $6038  end / walkable
    dw $02F4                    ; $603A  msg -> bank69 #176: 〈テリー〉は　ほんだなを　しらべた。 「きょうの　ひとこと、 「タマゴのあいだなら　せいべつは かえられるのじゃ[91]…
    dw $FF15,$C83C,$0001,$6036 ; $603C  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $02F5                    ; $6044  msg -> bank69 #177: 「モンスターにっき さく　モンスターじいさん 「〈テリー〉という　しょうねんは なかなか　みどころのあるやつじゃ。 「ろ…
    dw $FF15,$C83C,$0001,$6036 ; $6046  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $02F6                    ; $604E  msg -> bank69 #178: 「〈テリー〉は　もう　[0D]クラスを せいは　しよったわい！ 「おうさまの　いらいも なんなく　こなしたそうじゃ。 「…
    dw $FFFF                    ; $6050  end / walkable
    dw $04C0                    ; $6052  msg -> bank72 #76: 〈テリー〉は　ほんだなを　しらべた。 「きょうの　ひとこと、 「おなじ　しゅぞくを　はいごうして ちがう　まものが　うま…
    dw $FF15,$C83C,$0001,$6036 ; $6054  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $02F5                    ; $605C  msg -> bank69 #177: 「モンスターにっき さく　モンスターじいさん 「〈テリー〉という　しょうねんは なかなか　みどころのあるやつじゃ。 「ろ…
    dw $FF15,$C83C,$0001,$6036 ; $605E  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $04C1                    ; $6066  msg -> bank72 #77: 「〈テリー〉は　もう　[0D]クラスを せいは　しよったわい！ 「おうさまの　いらいも なんなく　こなしたそうじゃ。 「…
    dw $FF15,$C83C,$0001,$6036 ; $6068  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $04C2                    ; $6070  msg -> bank72 #78: 「〈テリー〉は　とうとう たいかいに　でることになったぞい！ 「たいしたやつじゃのう。　しかも わしの　わかいころに　に…
    dw $FFFF                    ; $6072  end / walkable
    dw $07F4                    ; $6074  msg -> bank78 #33: 〈テリー〉は　こくばんに　かかれた もじを　よんだ。 「まものには　ひにつよい こおりにつよい　など、 「それぞれ　とく…
    dw $FF15,$C83C,$0001,$6036 ; $6076  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $02F5                    ; $607E  msg -> bank69 #177: 「モンスターにっき さく　モンスターじいさん 「〈テリー〉という　しょうねんは なかなか　みどころのあるやつじゃ。 「ろ…
    dw $FF15,$C83C,$0001,$6036 ; $6080  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $04C1                    ; $6088  msg -> bank72 #77: 「〈テリー〉は　もう　[0D]クラスを せいは　しよったわい！ 「おうさまの　いらいも なんなく　こなしたそうじゃ。 「…
    dw $FF15,$C83C,$0001,$6036 ; $608A  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $07F5                    ; $6092  msg -> bank78 #34: 「つまり　メタルスラィムを おやにもつ　ドラゴンは、 「ふつうより　いろんなものに つよいということだな。 「そして　は…
    dw $FF15,$C83C,$0001,$6036 ; $6094  IF ($C83C)==$1 -> $$6036  (Yes/No answer $C83C)
    dw $07F6                    ; $609C  msg -> bank78 #35: 「おとくな　とくぎと　まものの はやおぼえ、ブツブツ、。 「キアリー　ドラキー キアリク　つむり、 「キアラル　ネジまき…
    dw $FFFF                    ; $609E  end / walkable
Bank13_Area09_Grids_60A0:                   ; $60A0-$61E8
    INCBIN "terry.gbc", $0360A0, $0148

Bank13_Area0A_Sections:                     ; $61E8  (1 section)
    dw $61EA   ; section $00+
Bank13_Area0A_Grids:                        ; $61EA-$6204  (26 bytes)
    INCBIN "terry.gbc", $0361EA, $001A

Bank13_Area0B_Sections:                     ; $6204  (1 section)
    dw $6206   ; section $00+
Bank13_Area0B_Grids:                        ; $6206-$6208  (2 bytes)
    INCBIN "terry.gbc", $036206, $0002

Bank13_Area0C_Sections:                     ; $6208  (6 sections)
    dw $6214,$6216,$621A,$621E,$6222,$6226   ; section $00+
Bank13_Area0C_Grids:                        ; $6214-$6270  (92 bytes)
    INCBIN "terry.gbc", $036214, $005C

Bank13_Area0D_Sections:                     ; $6270  (10 sections)
    dw $6284,$6286,$62A8,$6340,$6344,$6348,$63B2,$63DE   ; section $00+
    dw $642C,$6440   ; section $08+
Bank13_Area0D_Grids_6284:                   ; $6284-$62A8
    INCBIN "terry.gbc", $036284, $0024
; ---------------------------------------------------------------------------
; WORKED EXAMPLE: 'growth diary' bookshelf (a §$62A8) — multi-page book chained by 〔はい/いいえ〕
; ---------------------------------------------------------------------------
Bank13_Area0D_Ex_62A8:
    dw $FF01,$00F1,$630C   ; $62A8  IF flag $F1 SET -> branch $$630C (else next)
    dw $FF01,$0025,$62EA   ; $62AE  IF flag $25 SET -> branch $$62EA (else next)
    dw $FF01,$0035,$62D2   ; $62B4  IF flag $35 SET -> branch $$62D2 (else next)
    dw $FF01,$001D,$62C4   ; $62BA  IF flag $1D SET -> branch $$62C4 (else next)
    dw $01D4                    ; $62C0  msg -> bank68 #60: 〈テリー〉は　ほんだなを　しらべた。 「わがこの　せいちょう　にっき、 その[01] 「こどもが　うまれた。 おんなのこ…
    dw $FFFF                    ; $62C2  end / walkable
    dw $02FB                    ; $62C4  msg -> bank69 #183: 〈テリー〉は　ほんだなを　しらべた。 「わがこの　せいちょう　にっき、 その[01] 「こどもが　うまれた。 おんなのこ…
    dw $FF15,$C83C,$0001,$633C ; $62C6  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $02FC                    ; $62CE  msg -> bank69 #184: 「わがこの　せいちょう　にっき、 その[02] 「わがこは　ことばを　おぼえた。 なかなか　せいちょうがはやい。 「せい…
    dw $FFFF                    ; $62D0  end / walkable
    dw $02FB                    ; $62D2  msg -> bank69 #183: 〈テリー〉は　ほんだなを　しらべた。 「わがこの　せいちょう　にっき、 その[01] 「こどもが　うまれた。 おんなのこ…
    dw $FF15,$C83C,$0001,$633C ; $62D4  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $03B7                    ; $62DC  msg -> bank70 #183: 「わがこの　せいちょう　にっき、 その[02] 「わがこは　ことばを　おぼえた。 なかなか　せいちょうがはやい。 「せい…
    dw $FF15,$C83C,$0001,$633C ; $62DE  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $03B8                    ; $62E6  msg -> bank70 #184: 「わがこの　せいちょう　にっき、 その[03] 「ェサを　あたえて　きげんをとり ときには　きびしくめいれいする、？ 「…
    dw $FFFF                    ; $62E8  end / walkable
    dw $02FB                    ; $62EA  msg -> bank69 #183: 〈テリー〉は　ほんだなを　しらべた。 「わがこの　せいちょう　にっき、 その[01] 「こどもが　うまれた。 おんなのこ…
    dw $FF15,$C83C,$0001,$633C ; $62EC  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $03B7                    ; $62F4  msg -> bank70 #183: 「わがこの　せいちょう　にっき、 その[02] 「わがこは　ことばを　おぼえた。 なかなか　せいちょうがはやい。 「せい…
    dw $FF15,$C83C,$0001,$633C ; $62F6  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $04CA                    ; $62FE  msg -> bank72 #86: 「わがこの　せいちょう　にっき、 その[03] 「ェサを　あたえて　きげんをとり ときには　きびしくめいれいする、？ 「…
    dw $FF15,$C83C,$0001,$633C ; $6300  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $04CB                    ; $6308  msg -> bank72 #87: 「わがこの　せいちょう　にっき、 その[04] 「わたしは　とんでもないことを わすれていたようだ。 「あかちゃんに　な…
    dw $FFFF                    ; $630A  end / walkable
    dw $02FB                    ; $630C  msg -> bank69 #183: 〈テリー〉は　ほんだなを　しらべた。 「わがこの　せいちょう　にっき、 その[01] 「こどもが　うまれた。 おんなのこ…
    dw $FF15,$C83C,$0001,$633C ; $630E  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $03B7                    ; $6316  msg -> bank70 #183: 「わがこの　せいちょう　にっき、 その[02] 「わがこは　ことばを　おぼえた。 なかなか　せいちょうがはやい。 「せい…
    dw $FF15,$C83C,$0001,$633C ; $6318  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $04CA                    ; $6320  msg -> bank72 #86: 「わがこの　せいちょう　にっき、 その[03] 「ェサを　あたえて　きげんをとり ときには　きびしくめいれいする、？ 「…
    dw $FF15,$C83C,$0001,$633C ; $6322  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $07FE                    ; $632A  msg -> bank78 #43: 「とげぼうずや　キングコブラ ももんじゃ　スラィムナィト、 「はさみくわがた　ミストゥイング ダークアィなどが　すんでい…
    dw $FF15,$C83C,$0001,$633C ; $632C  IF ($C83C)==$1 -> $$633C  (Yes/No answer $C83C)
    dw $07FF                    ; $6334  msg -> bank78 #44: 「したのへやの　くさったしたいが ザォラルを　おぼえたがっている。 「だが　あのままではムリだろう。 それは　なぜか？！…
    dw $FF03                    ; $6336  behavior/opcode $03
    dw $0105                    ; $6338  msg -> bank67 #35: 「[10]クラスの　さいしゅうせんは じゅくちょうが　あいてだぜ。
    dw $FFFF                    ; $633A  end / walkable
    dw $014F                    ; $633C  msg -> bank67 #109: 〈テリー〉は　にっきを ほんだなに　もどした。
    dw $FFFF                    ; $633E  end / walkable
Bank13_Area0D_Grids_6340:                   ; $6340-$6454
    INCBIN "terry.gbc", $036340, $0114

Bank13_Area0E_Sections:                     ; $6454  (1 section)
    dw $6456   ; section $00+
Bank13_Area0E_Grids:                        ; $6456-$6458  (2 bytes)
    INCBIN "terry.gbc", $036456, $0002

Bank13_Area0F_Sections:                     ; $6458  (3 sections)
    dw $645E,$6460,$6482   ; section $00+
Bank13_Area0F_Grids:                        ; $645E-$64B6  (88 bytes)
    INCBIN "terry.gbc", $03645E, $0058

Bank13_Area10_Sections:                     ; $64B6  (8 sections)
    dw $64C6,$64D0,$64D4,$64D8,$64DC,$64E0,$65F2,$662C   ; section $00+
Bank13_Area10_Grids:                        ; $64C6-$6634  (366 bytes)
    INCBIN "terry.gbc", $0364C6, $016E

Bank13_Area11_Sections:                     ; $6634  (1 section)
    dw $6636   ; section $00+
Bank13_Area11_Grids:                        ; $6636-$6638  (2 bytes)
    INCBIN "terry.gbc", $036636, $0002

Bank13_Area12_Sections:                     ; $6638  (18 sections)
    dw $665C,$6676,$667A,$667E,$6682,$6686,$668A,$668E   ; section $00+
    dw $6692,$6696,$669A,$669E,$66A2,$66A6,$66EE,$66F2   ; section $08+
    dw $673C,$67DC   ; section $10+
Bank13_Area12_Grids:                        ; $665C-$6830  (468 bytes)
    INCBIN "terry.gbc", $03665C, $01D4

Bank13_Area13_Sections:                     ; $6830  (16 sections)
    dw $6850,$6852,$6856,$685A,$685E,$6862,$6866,$686A   ; section $00+
    dw $686E,$6872,$6876,$687A,$687E,$6882,$6886,$688A   ; section $08+
Bank13_Area13_Grids:                        ; $6850-$6898  (72 bytes)
    INCBIN "terry.gbc", $036850, $0048

Bank13_Area14_Sections:                     ; $6898  (1 section)
    dw $689A   ; section $00+
Bank13_Area14_Grids:                        ; $689A-$689C  (2 bytes)
    INCBIN "terry.gbc", $03689A, $0002

Bank13_Area15_Sections:                     ; $689C  (1 section)
    dw $689E   ; section $00+
Bank13_Area15_Grids:                        ; $689E-$68A0  (2 bytes)
    INCBIN "terry.gbc", $03689E, $0002

Bank13_Area16_Sections:                     ; $68A0  (4 sections)
    dw $68A8,$68AA,$68AE,$68DC   ; section $00+
Bank13_Area16_Grids:                        ; $68A8-$6960  (184 bytes)
    INCBIN "terry.gbc", $0368A8, $00B8

Bank13_Area17_Sections:                     ; $6960  (1 section)
    dw $6962   ; section $00+
Bank13_Area17_Grids:                        ; $6962-$6964  (2 bytes)
    INCBIN "terry.gbc", $036962, $0002

Bank13_Area18_Sections:                     ; $6964  (9 sections)
    dw $6976,$69C2,$69C6,$69CA,$69CE,$69D2,$69D6,$69DA   ; section $00+
    dw $6AD8   ; section $08+
Bank13_Area18_Grids:                        ; $6976-$6B0E  (408 bytes)
    INCBIN "terry.gbc", $036976, $0198

Bank13_Area19_Sections:                     ; $6B0E  (5 sections)
    dw $6B18,$6B1A,$6B4C,$6BD2,$6C24   ; section $00+
Bank13_Area19_Grids:                        ; $6B18-$6C76  (350 bytes)
    INCBIN "terry.gbc", $036B18, $015E

Bank13_Area1A_Sections:                     ; $6C76  (7 sections)
    dw $6C84,$6C86,$6CB8,$6CF8,$6CFC,$6D92,$6DE4   ; section $00+
Bank13_Area1A_Grids:                        ; $6C84-$6E36  (434 bytes)
    INCBIN "terry.gbc", $036C84, $01B2

Bank13_Area1B_Sections:                     ; $6E36  (4 sections)
    dw $6E3E,$6E40,$6E5C,$6EF6   ; section $00+
Bank13_Area1B_Grids:                        ; $6E3E-$6F40  (258 bytes)
    INCBIN "terry.gbc", $036E3E, $0102

Bank13_Area1C_Sections:                     ; $6F40  (7 sections)
    dw $6F4E,$6F50,$6FE2,$6FFA,$7012,$7024,$708C   ; section $00+
Bank13_Area1C_Grids:                        ; $6F4E-$70B8  (362 bytes)
    INCBIN "terry.gbc", $036F4E, $016A

Bank13_Area1D_Sections:                     ; $70B8  (7 sections)
    dw $70C6,$70C8,$70F6,$710E,$7112,$71BC,$7234   ; section $00+
Bank13_Area1D_Grids:                        ; $70C6-$726A  (420 bytes)
    INCBIN "terry.gbc", $0370C6, $01A4

Bank13_Area1E_Sections:                     ; $726A  (5 sections)
    dw $7274,$7290,$72DE,$7324,$738E   ; section $00+
Bank13_Area1E_Grids:                        ; $7274-$746C  (504 bytes)
    INCBIN "terry.gbc", $037274, $01F8

Bank13_Area1F_Sections:                     ; $746C  (10 sections)
    dw $7480,$749C,$74AA,$7994,$7A22,$7B10,$7BE4,$7A1E   ; section $00+
    dw $7B0C,$7BE0   ; section $08+
Bank13_Area1F_Grids:                        ; $7480-$7C40  (1984 bytes)
    INCBIN "terry.gbc", $037480, $07C0

; NOTE: the $7C3E placeholder grid (aliased by area types $00-$05) lies within
; the area-type $1F grid payload above.

    ds $03C0, $FF                   ; $7C40-$7FFF padding
