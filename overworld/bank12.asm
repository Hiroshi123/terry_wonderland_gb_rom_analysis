; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 12  (World-map tile movement engine (area type 0))
; ============================================================================
;
; Called from: bank4/$71F9 via LD HL,$0C00; RST $10
;
; Bank 12 memory map:
;   File offset $30000-$33FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 12
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; Function table at $30001 (bank 12 $4001):
;   fn0: $4007 ← entry — READ the map cell at a coordinate (collision/event)
;   fn1: $402F        — PAINT the cell's tile indices into the $9800 BG map
;   fn2: $4110        — PAINT the cell's CGB attributes into VRAM bank 1 (VBK)
;
; fn0 vs fn1/fn2: fn0 is the query used by bank4 (what's in front of the
; player). fn1/fn2 are the scroll-fill painters: as the camera moves, they
; expand the just-scrolled-in map cell into VRAM — fn1 the tile numbers
; (VRAM bank 0), fn2 the per-tile colour/priority attributes (VRAM bank 1).
;
; ============================================================================

SECTION "Bank 12 Functions", ROMX[$4000], BANK[12]

; ============================================================================
; MAP DATA TABLE  ($41BA)  — 3-level indexed cell-grid table
; ============================================================================
; All overworld map data (banks 12-15 share this engine) hangs off ONE table
; rooted at $41BA, indexed by the same vars Bank12_Fn0 uses:
;
;   $41BA[wAreaType $D8D3]        L1: area-type  → section-table pointer
;     └─ sectionTable[$D8D4]      L2: section    → cell-grid pointer
;          └─ cellGrid[$D8D6:$D8D5]  L3: coord    → 16-bit CELL VALUE
;
; Sub_71EF ($71EF, bank4) routes wAreaType to the owning bank's fn0:
;   $00-$05 → bank12 · $06-$1F → bank13 · $20-$3F → bank14 · $40+ → bank15.
; Each bank's $41BA is indexed by the FULL wAreaType; entries outside its range
; alias a placeholder table (bank13→$7C3E, bank14→$6AE2, bank15→$6F74), so only
; the owned rows are real.
;
;   bank | $41BA rows (area types)        | cell grids
;   -----+-------------------------------+-----------
;   12   | 6   ($00-$05, all real)        | 150
;   13   | 32  ($06-$1F real, 0-5 alias)  | 184
;   14   | 64  ($20-$3F real)             | 164
;   15   | 113 ($40+ real)                | 438     TOTAL 936 cell grids
;
; L1 (bank12) @$41BA: dw $41C6,$55FB,$5E1D,$6633,$687F,$71CF   (area types 0-5)
; L2 example (area type 0) @$41C6: 20 cell-grid ptrs ($41EE,$50ED,$50FF,...)
;    $D8D4 (section) selects the map/room within an area type.
; L3 cell grid: flat array of 16-bit cells (no header); first grid $41EE
;    (opening house) = 1919 cells. Cell VALUE:
;      $FFFF        = walkable
;      $FFxx        = warp / movement type (low byte -> RST $00 in bank4)
;      $00xx-$09xx  = GLOBAL MESSAGE ID (sign/NPC/event text; routed by $0EC5).
;    e.g. house grid cell $0020 -> bank66 msg 32 (the King), $0005 -> the diary.
; ============================================================================


; ------------------------------------------------------------
; Bank12_Fn0  ($4007)  — map-cell lookup at a coordinate (area type 0)
; ------------------------------------------------------------
; 3-level indexed fetch of the map cell the player is at/facing. bank4
; (player movement) calls this (LD HL,$0C00; RST $10) to read the tile in
; front of the player — for collision AND event/NPC triggers.
;   L1: $41BA[wAreaType $D8D3]      -> section table
;   L2: table[$D8D4 (section)]      -> cell grid
;   L3: grid[$D8D6:$D8D5 (coord)]   -> BC = 16-bit cell value; HL points to it
; The cell value encodes tile/collision (and links to the object/event at
; that spot; NPC placement itself is bank11's $D7D2 object table).
; ------------------------------------------------------------
Bank12_Fn0:                                 ; $4007
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
; Bank12_Fn1  ($402F)  — paint a cell's TILE INDICES into the BG tilemap
; ------------------------------------------------------------
; VRAM bank 0 ($9800 map). Walks the cell's tile stream via Sub_40E7, then the
; blit loop at $407B writes tile bytes with LD (HL+),A, wrapping every 32 cols
; (AND $1F) and stepping to the next map row on the $D8 marker (+$20); $D9 ends.
; This is the metatile -> screen tilemap expansion for one scrolled-in column.
; ------------------------------------------------------------
Bank12_Fn1:                                 ; $402F
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
Bank12_Fn1_Blit:                            ; $407B
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
Bank12_Fn1_Emit:                            ; $40A9
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
Bank12_Sub_40DA:                            ; $40DA  — advance L by one column, wrap within 32
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
; Bank12_Sub_40E7  — walk a cell's TILE stream into a WRAM $C300 buffer
; ------------------------------------------------------------
; Reads cell ptr from (BC): a 16-bit index, +$C300 base -> WRAM tile-list
; source. Copies the tile bytes with LD (HL+),A until $D9; $D8 = next-row (+$20).
; Fills the shadow the blit loop then pushes to VRAM.
; ------------------------------------------------------------
Bank12_Sub_40E7:                            ; $40E7
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
; Bank12_Fn2  ($4110)  — paint a cell's CGB ATTRIBUTES into VRAM bank 1
; ------------------------------------------------------------
; Same prologue as fn1 (byte-identical), so it targets the SAME BG-map cell.
; Difference: it builds the per-tile CGB attribute bytes (palette/priority/
; bank/flip) via Sub_4171/Sub_4195 (source base $C200, packed as nibbles), then
; the tail flips VRAM bank via VBK ($FF4F=1), reuses the fn1 blit loop ($4075)
; to write into the attribute map, and restores VBK 0. Only runs when the
; CGB-attribute-dirty flag $C81D is set. fn1 = tiles, fn2 = colour attributes.
; ------------------------------------------------------------
Bank12_Fn2:                                 ; $4110
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
; Bank12_Sub_4171  — walk a cell's ATTRIBUTE stream into the $C200 nibble buf
; ------------------------------------------------------------
; Like Sub_40E7 but each cell entry updates a packed 4-bit attribute via
; Sub_4195: address >>1 selects a byte in the $C200 table, carry (odd/even)
; selects high vs low nibble, and the new value is merged in. $D8=next row,
; $D9=end. This produces the compact per-tile CGB attributes fn2 then blits.
; ------------------------------------------------------------
Bank12_Sub_4171:                            ; $4171
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
Bank12_Sub_4195:                            ; $4195  — merge attr value A into $C200[HL/2] nibble
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


SECTION "Bank 12 Map Data", ROMX[$41BA], BANK[12]
; ============================================================================
; MAP DATA TABLE — see the structural notes at the top of this file.
;   L1 (area-type) -> L2 (section) -> cell grid[coord] = 16-bit value
;   Cell value: $FFFF walk · $FFxx warp-type (lo->TileBehaviorTable, bank4
;   $5620) · $00xx-$09xx GLOBAL MESSAGE ID (routed by ROM0 $0EC5).
;
; WHICH LINE IS SHOWN:
;   A section grid bundles several objects/events at different coords; the one
;   the player interacts with (its coord) decides the message. Behavior cells
;   ($FFxx) are pass-through commands run as the coord advances — e.g. the $2A
;   ($5FDB) / $2C ($6064) handlers just advance the coord and add-to / count the
;   20-slot party buffer at $CA51 (shared with the monster banks 3/7/22); they
;   are GENERIC, not line-selectors. Choosing between §5 and §6 is a higher-level
;   pick of which SECTION ($D8D4) is active, not a per-line flag inside one grid.
; ============================================================================
Map_AreaTypeTable:                          ; $41BA  (L1: wAreaType -> section table)
    dw $41C6,$55FB,$5E1D,$6633,$687F,$71CF   ; areaType 0..5

Map_Area0_Sections:                        ; $41C6  (20 sections)
    dw $41EE,$50ED,$50FF,$5111,$5191,$5211,$5223,$5235   ; section $00+
    dw $523D,$5247,$5277,$52D1,$52D5,$5301,$54DF,$556B   ; section $08+
    dw $556F,$5587,$55A9,$55E9   ; section $10+
Map_Area0_Grids:                           ; $41EE-$55FB  (area-type 0 cell grids)
    INCBIN "terry.gbc", $0301EE, $001023   ; sections 0-4 ($41EE-$5211)
; ----------------------------------------------------------------------------
; WORKED EXAMPLE — one small map with one NPC (area-type 0, SECTION 5)
;   Reached via $41BA[0]=$41C6 (section table) -> $41C6[5]=$5211 (this grid).
;   The player's coordinate ($D8D6:$D8D5) walks these 9 cells; each 16-bit word
;   IS a cell (little-endian: dw $VVVV emits [lo hi]).  Cell value meaning:
;     $FFFF = floor (walkable) · $FFxx = terrain/behavior (low byte ->
;     bank4 TileBehaviorTable $5620) · $00xx-$09xx = a character's MESSAGE ID
;     (routed by ROM0 $0EC5 to a text bank) · $41xx = link to another segment.
;   The NPC here is simply the message cell at coord 5.
; ----------------------------------------------------------------------------
; A section grid can hold SEVERAL objects/events at different tiles (see §6).
; Here coord 0/3/7 (bank75, byte-identical to §6) are the NOBLE COUPLE's lines,
; chosen by game state; coord 5 (bank66) is a separate event cell at another
; tile -- in §5 it's a quest line, in §6 it's a treasure chest.  The behavior
; cells + branch pointer form the mini state-machine that picks which line.
; (Message cell = $BBii: high byte $BB selects the text bank via ROM0 $0EC5,
;  the bank-LOCAL index is the LOW byte ii.  $00->bank66, $08->bank75, etc.)
Map_Area0_Sect5_Grid:                       ; $5211  = $41C6[5]  (9 cells)
    dw $083B   ; $5211 [3B 08]  coord 0: line -> bank75[$3B]: 「ゆうしょう おめでとう！…
               ;                          うちのむすめと けっこん…」 (after you WIN)
    dw $FF2C   ; $5213 [2C FF]  coord 1: terrain/behavior $2C (TileBehaviorTable $5620)
    dw $521F   ; $5215 [1F 52]  coord 2: branch pointer -> $521F (= coord 7 here)
    dw $083C   ; $5217 [3C 08]  coord 3: line -> bank75[$3C]: 「じょうだん じょうだん！…」
    dw $FF2A   ; $5219 [2A FF]  coord 4: terrain/behavior $2A
    dw $0017   ; $521B [17 00]  coord 5: line -> bank66[$17]:
               ;   「どうか おうさまの ねがいを きいてあげてください。」
               ;   ("Please -- listen to the King's wish.")  (during the main quest)
    dw $FFFF   ; $521D [FF FF]  coord 6: floor (walkable)
    dw $083D   ; $521F [3D 08]  coord 7: line -> bank75[$3D]: 「うちのひとったら…
               ;                          にっきまで つけてるんですよ！」 (the wife)
    dw $FFFF   ; $5221 [FF FF]  coord 8: floor (walkable)
; ----------------------------------------------------------------------------
; --- EXAMPLE 2: area-type 0, SECTION 6 ($41C6[6]=$5223) ---
; Adjacent to §5 and shares coord0/coord7 BYTE-FOR-BYTE = the same NOBLE COUPLE.
; Here coord 0/3/7 form a RELATED set (the couple + their daughter's diary), but
; coord 5 is an UNRELATED treasure-chest event at a different tile.  So a section
; can bundle several independent objects/events; only cells that decode to a
; shared theme belong to one object.  (msg $BBii: hi byte $BB=text bank via $0EC5,
; low byte ii = bank-local index.)
Map_Area0_Sect6_Grid:                       ; $5223  (9 cells)
    dw $083B   ; $5223 [3B 08]  coord 0: bank75[$3B] 「ゆうしょう おめでとう！…うちのむすめと…」 (couple)
    dw $FF2C   ; $5225 [2C FF]  coord 1: behavior $2C
    dw $5231   ; $5227 [31 52]  coord 2: branch pointer -> $5231 (= coord 7)
    dw $083E   ; $5229 [3E 08]  coord 3: bank75[$3E] 「わがこの せいちょうにっき、その…」 (couple: the diary)
    dw $FF2A   ; $522B [2A FF]  coord 4: behavior $2A
    dw $001D   ; $522D [1D 00]  coord 5: bank66[$1D] — SEPARATE treasure-chest event:
               ;   「テリーは やくそうを みつけた。しかし もちものが いっぱいだ。」
               ;   ("Terry found a herb -- but his bag is full.")  (NOT the couple)
    dw $FFFF   ; $522F [FF FF]  coord 6: floor (walkable)
    dw $083D   ; $5231 [3D 08]  coord 7: bank75[$3D] 「うちのひとったら…にっきまで つけてるんですよ！」 (couple: wife)
    dw $FFFF   ; $5233 [FF FF]  coord 8: floor (walkable)
    INCBIN "terry.gbc", $0031235, $0003C6  ; sections 7-19 ($5235-$55FB)

Map_Area1_Sections:                        ; $55FB  (21 sections)
    dw $5625,$591D,$592B,$592F,$5973,$598B,$598F,$5993   ; section $00+
    dw $59CD,$5A2B,$5A6B,$5A73,$5A8B,$5A8F,$5AD3,$5AEB   ; section $08+
    dw $5B2F,$5D9D,$5DCF,$5DF1,$5E07   ; section $10+
Map_Area1_Grids:                           ; $5625-$5E1D  (1020 cells)
    INCBIN "terry.gbc", $031625, $000446   ; sections 0-9 ($5625-$5A6B)
; --- EXAMPLE 3: area-type 1, SECTION 10 ($55FB[10]=$5A6B) — a tiny 4-cell map ---
Map_Area1_Sect10_Grid:                      ; $5A6B  (4 cells)
    dw $0157   ; $5A6B [57 01]  coord 0: message -> bank67
    dw $FF03   ; $5A6D [03 FF]  coord 1: behavior $03
    dw $0080   ; $5A6F [80 00]  coord 2: >>> NPC TEXT <<< -> bank66[128]:
               ;   「てきが どれほど つよくても わたしには かんけいない！
               ;     ただ しりょくをつくして たちむかう…」  (a fearless soldier)
    dw $FFFF   ; $5A71 [FF FF]  coord 3: floor (walkable)
    INCBIN "terry.gbc", $031A73, $0003AA   ; sections 11-20 ($5A73-$5E1D)

Map_Area2_Sections:                        ; $5E1D  (25 sections)
    dw $5E4F,$5E8F,$5EAF,$5EB3,$5EB7,$5EF5,$5F21,$5F43   ; section $00+
    dw $6093,$60BF,$6101,$6169,$616D,$6179,$61A3,$61D9   ; section $08+
    dw $6231,$62A3,$62A7,$62AB,$62B7,$62C5,$62D3,$6455   ; section $10+
    dw $657D   ; section $18+
Map_Area2_Grids:                           ; $5E4F-$6633  (1010 cells)
    INCBIN "terry.gbc", $031E4F, $00031E   ; sections 0-11 ($5E4F-$616D)
; --- EXAMPLE 4: area-type 2, SECTION 12 ($5E1D[12]=$616D) — the opening house ---
Map_Area2_Sect12_Grid:                      ; $616D  (6 cells)
    dw $0680   ; $616D [80 06]  coord 0: message -> bank74
    dw $FF04   ; $616F [04 FF]  coord 1: behavior $04
    dw $0000   ; $6171 [00 00]  coord 2: >>> NPC TEXT <<< -> bank66[0]:
               ;   「ミレーヨ｜テリー！ まちなさいって！ もう ねるじかんよ！」
               ;   (Terry's sister -- the game's opening line)
    dw $0680   ; $6173 [80 06]  coord 3: message -> bank74
    dw $0682   ; $6175 [82 06]  coord 4: message -> bank74
    dw $FFFF   ; $6177 [FF FF]  coord 5: floor (walkable)
    INCBIN "terry.gbc", $032179, $0004BA   ; sections 13-24 ($6179-$6633)

Map_Area3_Sections:                        ; $6633  (20 sections)
    dw $665B,$665D,$6661,$6665,$6669,$6771,$6773,$6777   ; section $00+
    dw $677B,$6789,$678D,$67EF,$67F3,$67F7,$67FB,$6835   ; section $08+
    dw $6867,$6869,$686B,$686D   ; section $10+
Map_Area3_Grids:                           ; $665B-$687F  (274 cells)
    INCBIN "terry.gbc", $03265B, $0224

Map_Area4_Sections:                        ; $687F  (43 sections)
    dw $68D5,$6ABB,$6AE1,$6BAB,$6BC3,$6BD1,$6BE3,$6C1F   ; section $00+
    dw $6C23,$6C4F,$6C71,$6C75,$6C87,$6C91,$6C9B,$6C9F   ; section $08+
    dw $6CA9,$6CAD,$6CE3,$6CE7,$6DA9,$6DAD,$6E0D,$6E43   ; section $10+
    dw $6E5B,$6E91,$6E95,$6F07,$6FFD,$701F,$7073,$7077   ; section $18+
    dw $707B,$707F,$708D,$70AF,$70D7,$7115,$7119,$712B   ; section $20+
    dw $712F,$7133,$7181   ; section $28+
Map_Area4_Grids:                           ; $68D5-$71CF  (1149 cells)
    INCBIN "terry.gbc", $0328D5, $08FA

Map_Area5_Sections:                        ; $71CF  (21 sections)
    dw $71F9,$71FB,$7213,$7217,$722F,$7257,$7283,$72A5   ; section $00+
    dw $72D1,$7331,$7359,$7383,$73AB,$73C3,$73DB,$73FB   ; section $08+
    dw $742B,$75BB,$75BF,$75D7,$7647   ; section $10+
Map_Area5_Grids:                           ; $71F9-$7675  (574 cells)
    INCBIN "terry.gbc", $0331F9, $047C

    ds $098B, $FF                   ; $7675 padding to $8000
