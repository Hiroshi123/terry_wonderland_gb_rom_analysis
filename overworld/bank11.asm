; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 11  (Map-scroll and monster-confirm handler)
; ============================================================================
;
; Called from: bank6 $611D/$6186 via LD HL,$0B04; RST $10; bank6 $631A via LD HL,$0B03
;
; Bank 11 memory map:
;   File offset $2C000-$2FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 11
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; Function table at $2C001 (bank 11 $4001):
;   fn0: $4015
;   fn1: $4088
;   fn2: $40CE
;   fn3: $4213 ← entry
;   fn4: $4332 ← entry
;   fn5: $43A4
;   fn6: $451D
;   fn7: $470F
;   fn8: $4239
;   fn9: $4488
;   fn10: $6CFA
;
; Cross-bank calls from this bank:
;   bank23/fn0 (HL=$1700) → see bank23.asm
;   bank23/fn1 (HL=$1701) → see bank23.asm
;   bank22/fn9 (HL=$1609) → see bank22.asm
;   bank1/fn9 (HL=$0109) → see bank1.asm
;   bank22/fn8 (HL=$1608) → see bank22.asm
;
; ROM0 calls from this bank:
;   $18A2 (ROM0)
;   $21CA (ROM0)
;   $2A21 (ROM0)
;   $1A5B (ROM0)
;   $1EFF (ROM0)
;
; AREA DIRECTORY (Bank11_AreaDir $4B43, indexed by wAreaID $C968 x2):
;   MEASURED 104 entries (areas $00-$67), NOT 64 — the table spans $4B43-$4C12
;   (208 bytes) and the first descriptor $4C13 immediately follows. 91 distinct
;   descriptors; $4C13 is the shared default (9 slots). 104 reconciles with the
;   ROM0 $2AAC main tileset records (112): the wAreaID space is ~104, not 64.
;   Full 104-entry table dumped byte-exact below (Bank11_AreaDir).
;
; ============================================================================

SECTION "Bank 11 Functions", ROMX[$4000], BANK[11]

; ============================================================================
; TILESET vs TILEMAP  — the two halves of a room's graphics, loaded separately
; ============================================================================
; A room = a TILESET (the tile shapes) + a TILEMAP (which shape goes in each
; cell). They live in different banks, load via different routines, and land in
; different memory. Do not confuse them:
;
;   +---------------+------------------------------+------------------------------+
;   |               | TILESET                      | TILEMAP                      |
;   +---------------+------------------------------+------------------------------+
;   | what it is    | 128 tile SHAPES (pixel data) | tile-NUMBER layout (0-127)   |
;   | loaded by     | Fn0 ($4015)                  | Fn2 ($40CE) [Fn3->$C500 too] |
;   | resolver      | ROM0 TilesetDirectory $2AAC  | Fn8 ($4239):                 |
;   |               |   indexed by wAreaID*8       |   AreaDir[$C968][room $C925] |
;   | selected by   | AREA  (wAreaID $C968)        | AREA + ROOM (wAreaID+$C925)  |
;   | decompressor  | SafeTileLoad $194A           | TileLoad $18A2               |
;   | destination   | VRAM $9000-$97FF (direct)    | WRAM $C300 -> paint to $9800 |
;   | stages        | 1  (ROM -> VRAM)             | 2  (ROM -> WRAM -> VRAM)      |
;   | reloads on    | AREA change                  | ROOM change (+ scroll)       |
;   +---------------+------------------------------+------------------------------+
;
; So all rooms of one area SHARE the tileset at $9000 (Fn0, per-area); only the
; tilemap differs per room (Fn2 decompresses it to $C300, then paints the tile
; numbers + the $C200 CGB attribute layer into the $9800 BG map). The paired
; attribute layer ($C200) is sourced by bank23 ($5215) and painted by Fn2.
; See Fn0 (tileset) and Fn2 (tilemap) below; Fn8 is the tilemap {bank,block}
; resolver, Fn3 the $C500 scroll double-buffer.
; ============================================================================

; ------------------------------------------------------------
; Bank11_Fn0  ($4015) — ENTER AREA: load its tileset into VRAM (+ sub-area setup)
; ------------------------------------------------------------
; The area-load entry point (scene entry: bank1 State1_EngineSetup via
; Scene_DisplayReinit; also from Fn2 at $1700). Loads the TILESET half of a map
; (the TILEMAP is loaded by Bank11_Fn8 $4239 -> $C300); per-area {block,bank}
; come from the ROM0 TilesetDirectory $2AAC/$2E2C indexed by wAreaID*8. Sub-area
; / world state is delegated to bank22 (fn5 before, fn6 after). Walkthrough is
; inline below.
; ------------------------------------------------------------
Bank11_Fn0:
; --- step 1 ($4015): commit a queued area change ---
; if $C96C != 0 (pending-warp flag) apply the queued destination: $C96D -> wAreaID
; $C968, $C96E -> sub-area flag $C969 (a gate/warp pre-stored it in $C96C/D/E).
    LD A,($C96C)                ; $4015  [FA 6C C9]
    OR A                        ; $4018  [B7]
    JR Z,$4027                  ; $4019  [28 0C]
    LD A,($C96D)                ; $401B  [FA 6D C9]
    LD ($C968),A                ; $401E  [EA 68 C9]
    LD A,($C96E)                ; $4021  [FA 6E C9]
    LD ($C969),A                ; $4024  [EA 69 C9]
; --- step 2 ($4027): sub-area/world entry setup, delegated to bank22/fn5 ---
; No-op in a main area ($C969==0: fn5 RETs immediately). In a sub-area it advances
; the sub-area step counter $C939 and loads the WORLD DESCRIPTOR $C935-$C93C from
; $70A6. Must run before step 3 (reads $C969) and step 7's fn6 (uses the descriptor).
    LD HL,$1605                 ; $4027  [21 05 16]  ; -> bank22/fn5
    RST $10                     ; $402A  [D7]
; --- step 3 ($402B): pick + index the ROM0 TilesetDirectory ---
; DE = $2AAC (main) or $2E2C (sub-area if $C969!=0); HL = DE + wAreaID*8 -> 8-byte
; record; record[0]=tileset block, record[1]=bank.
    LD DE,$2AAC                 ; $402B  [11 AC 2A]  ; DE = TilesetDirectory MAIN (ROM0 $2AAC)
    LD A,($C969)                ; $402E  [FA 69 C9]
    OR A                        ; $4031  [B7]
    JR Z,$4037                  ; $4032  [28 03]
    LD DE,$2E2C                 ; $4034  [11 2C 2E]  ; DE = TilesetDirectory SUB ($2E2C) if wAreaSub!=0
    LD A,($C968)                ; $4037  [FA 68 C9]  ; A = wAreaID
    LD L,A                      ; $403A  [6F]
    LD H,$00                    ; $403B  [26 00]
    ADD HL,HL                   ; $403D  [29]
    ADD HL,HL                   ; $403E  [29]
    ADD HL,HL                   ; $403F  [29]
    ADD HL,DE                   ; $4040  [19]  ; HL = table + wAreaID*8  (8-byte record)
    LD E,(HL)                   ; $4041  [5E]  ; E = record[0] = tileset BLOCK
    INC HL                      ; $4042  [23]
    LD D,(HL)                   ; $4043  [56]  ; D = record[1] = tileset BANK
    INC HL                      ; $4044  [23]
    PUSH HL                     ; $4045  [E5]
; --- step 4 ($4046): decompress the tileset to VRAM $9000 ---
    LD HL,$9000                 ; $4046  [21 00 90]  ; dest = VRAM $9000
    CALL $194A                  ; $4049  [CD 4A 19]  ; decompress tileset -> VRAM (SafeTileLoad)
; --- step 5 ($404C-$4075): SKIPPED by fn0 (see below) ---
; $404F LD A,$08 forces the $4051 JR NZ to always jump to $4076, so this block --
; a shared font/UI tile load (block $1D bank $29 -> VRAM $8800) plus a $D951==7
; special case -- is entered only by the Fn1 variant / other callers, not fn0.
    LD A,($C968)                ; $404C  [FA 68 C9]
    LD A,$08                    ; $404F  [3E 08]  ; A=$08 (nonzero) ...
    JR NZ,$4076                 ; $4051  [20 23]  ; ... so this is ALWAYS taken -> skip $4053-$4075
    LD DE,$291D                 ; $4053  [11 1D 29]  ; shared tiles block $1D bank $29
    LD HL,$8800                 ; $4056  [21 00 88]
    CALL $194A                  ; $4059  [CD 4A 19]  ; -> VRAM $8800
    XOR A                       ; $405C  [AF]
    LD ($C8A6),A                ; $405D  [EA A6 C8]
    LD ($C8A7),A                ; $4060  [EA A7 C8]
    JR $4076                    ; $4063  [18 11]
    LD A,($D951)                ; $4065  [FA 51 D9]
    CP $07                      ; $4068  [FE 07]
    JR NZ,$4076                 ; $406A  [20 0A]
    XOR A                       ; $406C  [AF]
    LD HL,$C0D8                 ; $406D  [21 D8 C0]
    LD BC,$0028                 ; $4070  [01 28 00]
    CALL $169A                  ; $4073  [CD 9A 16]
; --- step 6 ($4076-$4082): copy record[2..5] -> HRAM $9D-$A0 (load/scroll params) ---
    POP HL                      ; $4076  [E1]
    LD A,(HL+)                  ; $4077  [2A]  ; record[2] -> HRAM $9D
    LDH ($9D),A                 ; $4078  [E0 9D]
    LD A,(HL+)                  ; $407A  [2A]  ; record[3] -> $9E
    LDH ($9E),A                 ; $407B  [E0 9E]
    LD A,(HL+)                  ; $407D  [2A]  ; record[4] -> $9F
    LDH ($9F),A                 ; $407E  [E0 9F]
    LD A,(HL)                   ; $4080  [7E]  ; record[5] -> $A0
    LDH ($A0),A                 ; $4081  [E0 A0]
; --- step 7 ($4083): build the 4x4 room-layout grid $C940, delegated to bank22/fn6 ---
    LD HL,$1606                 ; $4083  [21 06 16]  ; -> bank22/fn6
    RST $10                     ; $4086  [D7]
    RET                         ; $4087  [C9]

; ------------------------------------------------------------
; Bank11_Fn1  ($4088) — same tileset load, without the fn0 entry/bank wrap
; ------------------------------------------------------------
Bank11_Fn1:
    LD DE,$2AAC                 ; $4088  [11 AC 2A]  ; DE = TilesetDirectory MAIN (ROM0 $2AAC)
    LD A,($C969)                ; $408B  [FA 69 C9]
    OR A                        ; $408E  [B7]
    JR Z,$4094                  ; $408F  [28 03]
    LD DE,$2E2C                 ; $4091  [11 2C 2E]  ; DE = SUB ($2E2C) if wAreaSub!=0
    LD A,($C968)                ; $4094  [FA 68 C9]
    LD L,A                      ; $4097  [6F]
    LD H,$00                    ; $4098  [26 00]
    ADD HL,HL                   ; $409A  [29]
    ADD HL,HL                   ; $409B  [29]
    ADD HL,HL                   ; $409C  [29]
    ADD HL,DE                   ; $409D  [19]
    LD E,(HL)                   ; $409E  [5E]
    INC HL                      ; $409F  [23]
    LD D,(HL)                   ; $40A0  [56]  ; D = tileset BANK
    INC HL                      ; $40A1  [23]
    PUSH HL                     ; $40A2  [E5]
    LD HL,$9000                 ; $40A3  [21 00 90]
    CALL $194A                  ; $40A6  [CD 4A 19]  ; decompress tileset -> VRAM $9000
    LD A,($C968)                ; $40A9  [FA 68 C9]
    LD A,$08                    ; $40AC  [3E 08]
    JR NZ,$40C0                 ; $40AE  [20 10]
    LD DE,$291D                 ; $40B0  [11 1D 29]
    LD HL,$8800                 ; $40B3  [21 00 88]
    CALL $194A                  ; $40B6  [CD 4A 19]
    XOR A                       ; $40B9  [AF]
    LD ($C8A6),A                ; $40BA  [EA A6 C8]
    LD ($C8A7),A                ; $40BD  [EA A7 C8]
    POP HL                      ; $40C0  [E1]
    LD A,(HL+)                  ; $40C1  [2A]
    LDH ($9D),A                 ; $40C2  [E0 9D]
    LD A,(HL+)                  ; $40C4  [2A]
    LDH ($9E),A                 ; $40C5  [E0 9E]
    LD A,(HL+)                  ; $40C7  [2A]
    LDH ($9F),A                 ; $40C8  [E0 9F]
    LD A,(HL)                   ; $40CA  [7E]
    LDH ($A0),A                 ; $40CB  [E0 A0]
    RET                         ; $40CD  [C9]



; ============================================================================
; INTERIOR / ROOM MAP LOAD PIPELINE   (how a room's tiles get on screen)
; ============================================================================
; Two coordinated WRAM layers make up what you see (both decompressed by the
; ROM0 LZ loader $18A2 from a {bank,block} the game resolves per room):
;   $C300 = 8-bit TILE-NUMBER map (32 wide; row stride $20). Each byte indexes
;           the loaded VRAM tileset (0-127). Painted to BG map $9800 by the
;           bank12-15 movement engine (fn1). ← the visual layout.
;   $C200 = 4-bit CGB ATTRIBUTE map (palette/bank/flip), painted to VRAM bank1
;           by fn2. (NOTE: earlier notes called $C300 the "collision" map —
;           it is the tile-number/visual map. $5215-in-bank23 loads $C200.)
; The {bank,block} for the $C300 layer is resolved by Bank11_Fn8 ($4239).
; NOTE the tile-number blocks and the tile GRAPHICS blocks can live in the SAME
; graphics bank: e.g. bank48 ($30) holds both graphics blocks (0,1,2,..) AND
; 32x16 tile-number map blocks ($10,$11,$12,..). bank48 = the INTERIOR/building
; tileset (walls, floors, furniture) — used by bank11 areas 18-30; area 24 =
; likely the MAIN CASTLE (loads the most: blocks $10/$11/$12). See Bank11_Fn8.
;
; ------------------------------------------------------------
; Bank11_Fn2  ($40CE) — FULL-SCREEN ROOM REPAINT (camera + tilemap + CGB attrs)
; ------------------------------------------------------------
; Recomputes camera pixel position from the scroll shadow ($FF92/93 = X,
; $FF95/96 = Y) via ROM0 $21DC/$21B5, storing hCamX ($FFB7/8), hCamY ($FFBB/C)
; and room index $C925. Unless $C8EB bit1/3 are set it reloads the tileset
; (bank23/fn0, HL=$1700); unless $C8EA bit7 it resolves the tile-number map
; {bank,block} (Fn8 $4239), decompresses it to $C300 ($18A2), stamps the 2x2
; door/stair overlay (Sub_4309) and calls bank23/fn1 (HL=$1701). It then blits
; the whole screen into BG map $9800: if $C81D (CGB) the $C200 4-bit ATTRIBUTE
; layer into VRAM bank 1 (LDH $4F=1, 10x10 metatiles), then the $C300 TILE-
; NUMBER layer (20x16). Finally marks $C950[$C925]=1 (this room painted).
; CALLED BY bank1 State1_EngineSetup (HL=$0B02) to draw the initial screen.
; ------------------------------------------------------------
Bank11_Fn2:                                 ; $40CE
    LDH A,($95)                ; $40CE  [F0 95]  ; A = hSCY lo (16-bit scroll-Y)
    LD L,A                     ; $40D0  [6F]  ; L = SCY lo
    LDH A,($96)                ; $40D1  [F0 96]  ; A = hSCY hi
    LD H,A                     ; $40D3  [67]  ; HL = scroll-Y (pixels)
    LD A,$80                   ; $40D4  [3E 80]  ; A=$80 (screen height param)
    CALL $21DC                 ; $40D6  [CD DC 21]  ; ROM0 $21DC: HL/param -> L = row (Y/tile)
    LD A,L                     ; $40D9  [7D]  ; A = row
    ADD A,A                    ; $40DA  [87]  ; row*2
    ADD A,A                    ; $40DB  [87]  ; row*4
    LD ($C925),A               ; $40DC  [EA 25 C9]  ; wScrollCount = row*4
    LD A,$80                   ; $40DF  [3E 80]  ; A=$80
    LD C,L                     ; $40E1  [4D]  ; C=L
    LD B,H                     ; $40E2  [44]  ; B=H
    CALL $21B5                 ; $40E3  [CD B5 21]  ; ROM0 $21B5: -> HL = tile-aligned camera Y
    LD A,L                     ; $40E6  [7D]  ; A = camY lo
    LDH ($BB),A                ; $40E7  [E0 BB]  ; hCamY lo ($FFBB)
    LD A,H                     ; $40E9  [7C]  ; A = camY hi
    LDH ($BC),A                ; $40EA  [E0 BC]  ; hCamY hi ($FFBC)
    LDH A,($92)                ; $40EC  [F0 92]  ; A = hSCX lo
    LD L,A                     ; $40EE  [6F]  ; L
    LDH A,($93)                ; $40EF  [F0 93]  ; A = hSCX hi
    LD H,A                     ; $40F1  [67]  ; HL = scroll-X
    LD A,$A0                   ; $40F2  [3E A0]  ; A=$A0 (screen width param)
    CALL $21DC                 ; $40F4  [CD DC 21]  ; ROM0 $21DC: -> L = col (X/tile)
    LD A,($C925)               ; $40F7  [FA 25 C9]  ; A = wScrollCount (row*4)
    ADD A,L                    ; $40FA  [85]  ; + col
    LD ($C925),A               ; $40FB  [EA 25 C9]  ; wScrollCount = row*4 + col (this room's index)
    LD A,$A0                   ; $40FE  [3E A0]  ; A=$A0
    LD C,L                     ; $4100  [4D]  ; C=L
    LD B,H                     ; $4101  [44]  ; B=H
    CALL $21B5                 ; $4102  [CD B5 21]  ; ROM0 $21B5: -> HL = tile-aligned camera X
    LD A,L                     ; $4105  [7D]  ; A = camX lo
    LDH ($B7),A                ; $4106  [E0 B7]  ; hCamX lo ($FFB7)
    LD A,H                     ; $4108  [7C]  ; A = camX hi
    LDH ($B8),A                ; $4109  [E0 B8]  ; hCamX hi ($FFB8)
    LD A,($C8EB)               ; $410B  [FA EB C8]  ; A = $C8EB busy/skip flags
    BIT 1,A                    ; $410E  [CB 4F]  ; test bit1
    JR NZ,$4134                ; $4110  [20 22]  ; bit1 set -> skip tile(map) reload, go paint
    BIT 3,A                    ; $4112  [CB 5F]  ; test bit3
    JR NZ,$4134                ; $4114  [20 1E]  ; bit3 set -> skip tilemap reload
    LD HL,$1700                ; $4116  [21 00 17]  ; HL=$1700
    RST $10                    ; $4119  [D7]  ; -> bank23/fn0 (attr/tileset engine)
    LD A,($C8EA)               ; $411A  [FA EA C8]  ; A = $C8EA guard
    BIT 7,A                    ; $411D  [CB 7F]  ; test bit7
    JR NZ,$4134                ; $411F  [20 13]  ; bit7 set -> skip tilemap reload
    CALL $4239                 ; $4121  [CD 39 42]  ; fn8: resolve this room's tilemap {bank,block}
    LD HL,$C300                ; $4124  [21 00 C3]  ; dest = WRAM $C300 (tile-number buffer)
    CALL $18A2                 ; $4127  [CD A2 18]  ; ROM0 $18A2 TileLoad: LZ-decompress tilemap -> $C300
    LD DE,$C300                ; $412A  [11 00 C3]  ; DE = $C300
    CALL $4309                 ; $412D  [CD 09 43]  ; Sub_4309: stamp 2x2 door/stair overlay into buffer
    LD HL,$1701                ; $4130  [21 01 17]  ; HL=$1701
    RST $10                    ; $4133  [D7]  ; -> bank23/fn1
    LD A,($C81D)               ; $4134  [FA 1D C8]  ; A = $C81D (CGB attribute-paint enable)
    OR A                       ; $4137  [B7]  ; set flags
    JR Z,$41B3                 ; $4138  [28 79]  ; if 0 (DMG) -> skip attr paint ($41B3)
    DI                         ; $413A  [F3]  ; disable IRQ for VRAM access
    CALL $1E79                 ; $413B  [CD 79 1E]  ; ROM0 $1E79: VRAM access setup
    LD A,$01                   ; $413E  [3E 01]  ; A=1
    LDH ($4F),A                ; $4140  [E0 4F]  ; VBK=1: select VRAM bank 1 (CGB attribute map)
    EI                         ; $4142  [FB]  ; re-enable IRQ
    LDH A,($BB)                ; $4143  [F0 BB]  ; A = camY
    AND $F8                    ; $4145  [E6 F8]  ; snap to 8px tile
    LD L,A                     ; $4147  [6F]  ; L
    XOR A                      ; $4148  [AF]  ; A=0
    SLA L                      ; $4149  [CB 25]  ; L<<1 -> carry
    RLA                        ; $414B  [17]  ; rotate into A
    SLA L                      ; $414C  [CB 25]  ; L<<1
    RLA                        ; $414E  [17]  ; rotate
    LD H,$98                   ; $414F  [26 98]  ; H=$98 (BG map base $9800)
    ADD A,H                    ; $4151  [84]  ; + row hi
    LD H,A                     ; $4152  [67]  ; H
    LDH A,($B7)                ; $4153  [F0 B7]  ; A = camX
    RRCA                       ; $4155  [0F]  ; X/8 ...
    RRCA                       ; $4156  [0F]  ; ...
    RRCA                       ; $4157  [0F]  ; ...
    AND $1F                    ; $4158  [E6 1F]  ; col (0-31)
    ADD A,L                    ; $415A  [85]  ; + row offset
    LD L,A                     ; $415B  [6F]  ; L
    LD A,$00                   ; $415C  [3E 00]  ; A=0
    ADC A,H                    ; $415E  [8C]  ; H + carry
    LD H,A                     ; $415F  [67]  ; H -> HL = $9800 dest addr
    LD DE,$C200                ; $4160  [11 00 C2]  ; DE = $C200 (4-bit CGB attribute buffer)
    LD C,$10                   ; $4163  [0E 10]  ; C = 16 columns
    LD B,$0A                   ; $4165  [06 0A]  ; B = 10 metatile rows
    PUSH HL                    ; $4167  [E5]  ; save VRAM ptr
    LD A,(DE)                  ; $4168  [1A]  ; A = attr byte (2 cells packed)
    SWAP A                     ; $4169  [CB 37]  ; swap nibbles
    AND $0F                    ; $416B  [E6 0F]  ; high nibble = this cell's attr
    CALL $1E80                 ; $416D  [CD 80 1E]  ; ROM0 $1E80: write attr to VRAM+advance
    LD A,L                     ; $4170  [7D]  ; A = ptr lo
    AND $E0                    ; $4171  [E6 E0]  ; col part
    PUSH AF                    ; $4173  [F5]  ; save
    LD A,L                     ; $4174  [7D]  ; A = ptr lo
    INC A                      ; $4175  [3C]  ; ++
    AND $1F                    ; $4176  [E6 1F]  ; wrap col (mod 32)
    LD L,A                     ; $4178  [6F]  ; L
    POP AF                     ; $4179  [F1]  ; restore row part
    OR L                       ; $417A  [B5]  ; OR
    LD L,A                     ; $417B  [6F]  ; L
    LD A,(DE)                  ; $417C  [1A]  ; A = attr byte again
    AND $0F                    ; $417D  [E6 0F]  ; low nibble = next cell's attr
    CALL $1E80                 ; $417F  [CD 80 1E]  ; write to VRAM
    LD A,L                     ; $4182  [7D]  ; A=ptr
    AND $E0                    ; $4183  [E6 E0]  ; col part
    PUSH AF                    ; $4185  [F5]  ; save
    LD A,L                     ; $4186  [7D]  ; ptr
    INC A                      ; $4187  [3C]  ; ++
    AND $1F                    ; $4188  [E6 1F]  ; wrap col
    LD L,A                     ; $418A  [6F]  ; L
    POP AF                     ; $418B  [F1]  ; restore
    OR L                       ; $418C  [B5]  ; OR
    LD L,A                     ; $418D  [6F]  ; L
    INC DE                     ; $418E  [13]  ; next source byte
    DEC B                      ; $418F  [05]  ; dec col counter
    JR NZ,$4168                ; $4190  [20 D6]  ; loop 16 cols ($4168)
    POP HL                     ; $4192  [E1]  ; restore VRAM row ptr
    LD A,E                     ; $4193  [7B]  ; A=E
    ADD A,$06                  ; $4194  [C6 06]  ; advance source +6 (row stride)
    LD E,A                     ; $4196  [5F]  ; E
    LD A,D                     ; $4197  [7A]  ; A=D
    ADC A,$00                  ; $4198  [CE 00]  ; +carry
    LD D,A                     ; $419A  [57]  ; D
    PUSH BC                    ; $419B  [C5]  ; save col count
    LD BC,$0020                ; $419C  [01 20 00]  ; BC=$20 (next BG map row)
    ADD HL,BC                  ; $419F  [09]  ; HL+=32
    LD A,H                     ; $41A0  [7C]  ; H
    AND $03                    ; $41A1  [E6 03]  ; keep in $98-9B
    OR $98                     ; $41A3  [F6 98]  ; wrap
    LD H,A                     ; $41A5  [67]  ; H
    POP BC                     ; $41A6  [C1]  ; restore
    DEC C                      ; $41A7  [0D]  ; dec row counter
    JR NZ,$4165                ; $41A8  [20 BB]  ; loop 10 rows ($4165)
    DI                         ; $41AA  [F3]  ; disable IRQ
    CALL $1E79                 ; $41AB  [CD 79 1E]  ; ROM0 $1E79
    LD A,$00                   ; $41AE  [3E 00]  ; A=0
    LDH ($4F),A                ; $41B0  [E0 4F]  ; VBK=0: back to VRAM bank 0 (tiles)
    EI                         ; $41B2  [FB]  ; re-enable IRQ
    LDH A,($BB)                ; $41B3  [F0 BB]  ; A = camY (recompute $9800 dest for tile-number paint)
    AND $F8                    ; $41B5  [E6 F8]  ; snap 8px
    LD L,A                     ; $41B7  [6F]  ; L
    XOR A                      ; $41B8  [AF]  ; A=0
    SLA L                      ; $41B9  [CB 25]  ; L<<1
    RLA                        ; $41BB  [17]  ; rot
    SLA L                      ; $41BC  [CB 25]  ; L<<1
    RLA                        ; $41BE  [17]  ; rot
    LD H,$98                   ; $41BF  [26 98]  ; H=$98
    ADD A,H                    ; $41C1  [84]  ; +row
    LD H,A                     ; $41C2  [67]  ; H
    LDH A,($B7)                ; $41C3  [F0 B7]  ; A = camX
    RRCA                       ; $41C5  [0F]  ; /8
    RRCA                       ; $41C6  [0F]
    RRCA                       ; $41C7  [0F]
    AND $1F                    ; $41C8  [E6 1F]  ; col
    ADD A,L                    ; $41CA  [85]  ; +row
    LD L,A                     ; $41CB  [6F]  ; L
    LD A,$00                   ; $41CC  [3E 00]  ; A=0
    ADC A,H                    ; $41CE  [8C]  ; +carry
    LD H,A                     ; $41CF  [67]  ; H = $9800 dest
    LD DE,$C300                ; $41D0  [11 00 C3]  ; DE = $C300 (tile-number buffer)
    LD C,$10                   ; $41D3  [0E 10]  ; C = 16 columns
    LD B,$14                   ; $41D5  [06 14]  ; B = 20 rows
    PUSH HL                    ; $41D7  [E5]  ; save VRAM ptr
    LD A,(DE)                  ; $41D8  [1A]  ; A = tile number
    CALL $1E80                 ; $41D9  [CD 80 1E]  ; ROM0 $1E80: write tile# to VRAM+advance
    LD A,L                     ; $41DC  [7D]  ; A=ptr
    AND $E0                    ; $41DD  [E6 E0]  ; col part
    PUSH AF                    ; $41DF  [F5]  ; save
    LD A,L                     ; $41E0  [7D]  ; ptr
    INC A                      ; $41E1  [3C]  ; ++
    AND $1F                    ; $41E2  [E6 1F]  ; wrap col
    LD L,A                     ; $41E4  [6F]  ; L
    POP AF                     ; $41E5  [F1]  ; restore
    OR L                       ; $41E6  [B5]  ; OR
    LD L,A                     ; $41E7  [6F]  ; L
    INC DE                     ; $41E8  [13]  ; next source byte
    DEC B                      ; $41E9  [05]  ; dec col
    JR NZ,$41D8                ; $41EA  [20 EC]  ; loop 16 cols ($41D8)
    POP HL                     ; $41EC  [E1]  ; restore VRAM ptr
    LD A,E                     ; $41ED  [7B]  ; A=E
    ADD A,$0C                  ; $41EE  [C6 0C]  ; advance source +$0C (row stride)
    LD E,A                     ; $41F0  [5F]  ; E
    LD A,D                     ; $41F1  [7A]  ; A=D
    ADC A,$00                  ; $41F2  [CE 00]  ; +carry
    LD D,A                     ; $41F4  [57]  ; D
    PUSH BC                    ; $41F5  [C5]  ; save row count
    LD BC,$0020                ; $41F6  [01 20 00]  ; BC=$20
    ADD HL,BC                  ; $41F9  [09]  ; HL+=32 (next BG row)
    LD A,H                     ; $41FA  [7C]  ; H
    AND $03                    ; $41FB  [E6 03]  ; keep $98-9B
    OR $98                     ; $41FD  [F6 98]  ; wrap
    LD H,A                     ; $41FF  [67]  ; H
    POP BC                     ; $4200  [C1]  ; restore
    DEC C                      ; $4201  [0D]  ; dec row
    JR NZ,$41D5                ; $4202  [20 D1]  ; loop 20 rows ($41D5)
    LD A,($C925)               ; $4204  [FA 25 C9]  ; A = wScrollCount
    LD HL,$C950                ; $4207  [21 50 C9]  ; HL=$C950 (per-room 'painted' flags)
    ADD A,L                    ; $420A  [85]  ; + index
    LD L,A                     ; $420B  [6F]  ; L
    LD A,$00                   ; $420C  [3E 00]  ; A=0
    ADC A,H                    ; $420E  [8C]  ; +carry
    LD H,A                     ; $420F  [67]  ; H
    LD (HL),$01                ; $4210  [36 01]  ; mark $C950[$C925] = 1 (this room painted)
    RET                        ; $4212  [C9]  ; return

; Two callers build the two buffers via the SAME resolver+patch:
;   Bank11_Fn3        ($4213): CALL $4239; decompress -> $C500; CALL $4309
;   (fn2 body, $4116):         CALL $4239; decompress -> $C300; CALL $4309
; ($C300 = the live/current buffer; $C500 = the second buffer, used while
;  scrolling to a neighbouring room — exact double-buffer role TBD.)
; ------------------------------------------------------------
; Bank11_Fn3  ($4213) — build the $C500 tile-number buffer for the current room
; ------------------------------------------------------------

Bank11_Fn3:
    LD HL,$1700                         ; $4213  [21 00 17]
    RST $10                             ; $4216  [D7]        ; → bank23/fn0 (load $C200 attrs)
    CALL $4239                          ; $4217  [CD 39 42]  ; → Fn8: DE = {bank,block} of tile-number map
    LD HL,$C500                         ; $421A  [21 00 C5]
    CALL $18A2                          ; $421D  [CD A2 18]  ; → ROM0 LZ: decompress block → $C500
    LD DE,$C500                         ; $4220  [11 00 C5]
    CALL $4309                          ; $4223  [CD 09 43]  ; → Sub_4309: patch 2x2 door/stair tiles
    LD HL,$1701                         ; $4226  [21 01 17]
    RST $10                             ; $4229  [D7]        ; → bank23/fn1
    LD A,($C925)                        ; $422A  [FA 25 C9]  ; wScrollCount (room 0-15)
    LD HL,$C950                         ; $422D  [21 50 C9]
    ADD A,L                             ; $4230  [85]
    LD L,A                              ; $4231  [6F]
    LD A,$00                            ; $4232  [3E 00]
    ADC A,H                             ; $4234  [8C]
    LD H,A                              ; $4235  [67]
    LD (HL),$01                         ; $4236  [36 01]     ; mark this room's buffer = loaded
    RET                                 ; $4238  [C9]


; ------------------------------------------------------------
; Bank11_Fn8  ($4239) — resolve {bank,block} of the room's TILE-NUMBER map
; ------------------------------------------------------------
; Returns DE = {E=block, D=bank} for the compressed tile-number map (the block
; the callers decompress to $C300 / $C500). Walks the area-descriptor chain:
;   HL = Bank11_AreaDir ($4B43)[wAreaID $C968 *2]   → area descriptor base
;   HL = [base + wScrollCount $C925 *2]             → this room's sub-descriptor
;   DE = [HL]; HL+=2                                → VARIANT-SELECTOR pointer
;   A  = [DE]                                       → variant (usually WRAM,
;         e.g. $D95F/$D960 — RUNTIME room state; 0 = default)
;   HL += A*6 ; DE = [HL]                           → {block, bank}
; If wAreaSub $C969 != 0 it defers to bank22/fn9 instead (connected-map mode).
; WORKED EXAMPLE (static, variant 0): area 24 (CASTLE), room 0 → bank48 blk $10;
;   room 4 → bank48 blk $11. (bank48 = interior tileset; see pipeline doc above.)
; ------------------------------------------------------------
Bank11_Fn8:
    LD A,($C969)                        ; $4239  [FA 69 C9]  ; wAreaSub
    OR A                                ; $423C  [B7]
    JR Z,$4244                          ; $423D  [28 05]     ; sub==0 → static resolve below
    LD HL,$1609                         ; $423F  [21 09 16]
    RST $10                             ; $4242  [D7]        ; → bank22/fn9 (connected-map mode)
    RET                                 ; $4243  [C9]
    LD HL,$4B43                         ; $4244  [21 43 4B]  ; Bank11_AreaDir
    LD A,($C968)                        ; $4247  [FA 68 C9]  ; wAreaID
    ADD A,A                             ; $424A  [87]
    ADD A,L                             ; $424B  [85]
    LD L,A                              ; $424C  [6F]
    LD A,$00                            ; $424D  [3E 00]
    ADC A,H                             ; $424F  [8C]
    LD H,A                              ; $4250  [67]
    LD A,(HL+)                          ; $4251  [2A]
    LD H,(HL)                           ; $4252  [66]        ; HL = area descriptor base
    LD L,A                              ; $4253  [6F]
    LD A,($C925)                        ; $4254  [FA 25 C9]  ; wScrollCount (room 0-15)
    ADD A,A                             ; $4257  [87]
    ADD A,L                             ; $4258  [85]
    LD L,A                              ; $4259  [6F]
    LD A,$00                            ; $425A  [3E 00]
    ADC A,H                             ; $425C  [8C]
    LD H,A                              ; $425D  [67]
    LD A,(HL+)                          ; $425E  [2A]
    LD H,(HL)                           ; $425F  [66]        ; HL = room sub-descriptor
    LD L,A                              ; $4260  [6F]
    LD E,(HL)                           ; $4261  [5E]
    INC HL                              ; $4262  [23]
    LD D,(HL)                           ; $4263  [56]        ; DE = variant-selector ptr (WRAM)
    INC HL                              ; $4264  [23]
    LD A,(DE)                           ; $4265  [1A]        ; A = variant (runtime; 0 default)
    LD E,A                              ; $4266  [5F]
    ADD A,A                             ; $4267  [87]
    ADD A,E                             ; $4268  [83]        ; A = 3*variant
    ADD A,A                             ; $4269  [87]        ; A = 6*variant
    ADD A,L                             ; $426A  [85]
    LD L,A                              ; $426B  [6F]
    LD A,$00                            ; $426C  [3E 00]
    ADC A,H                             ; $426E  [8C]
    LD H,A                              ; $426F  [67]        ; HL = record + 6*variant
    LD E,(HL)                           ; $4270  [5E]        ; E = block
    INC HL                              ; $4271  [23]
    LD D,(HL)                           ; $4272  [56]        ; D = bank  → DE = {bank,block}
    RET                                 ; $4273  [C9]


; ------------------------------------------------------------
; Bank11_Sub_4274  ($4274) — resolve THIS room's compact OBJECT-LIST pointer -> HL
; ------------------------------------------------------------
; The list resolver that fn4's Sub_433F (both phases) and fn7 call. It walks the
; SAME 3-level chain as Fn8 (AreaDir[wAreaID] -> roomArray[wScrollCount] -> the
; room sub-descriptor -> active variant record, variant = *selector, record size
; 6 bytes), but where Fn8 reads the record's FIRST word (tile-number {block,bank}
; for $C300), this reads the record's obj-list word at +$04 (it does INC HL twice
; to skip block,bank). So HL returns the room's compact object source list -- the
; obj= address the descriptors point at (5-byte records; Sub_477E expands them).
; FALLBACK ($42AC, wAreaSub $C969 != 0 / connected-map): if wNeighbour $C926==$FF
; return a fixed default list ($4308); else index ptr table $42C8 by $C92B.
; ------------------------------------------------------------
Bank11_Sub_4274:
    LD A,($C969)                        ; $4274  [FA 69 C9]  ; wAreaSub ($C969)
    OR A                                ; $4277  [B7]  ; sub-area mode?
    JR NZ,$42AC                         ; $4278  [20 32]  ; sub != 0 -> fallback table ($42AC)
    LD HL,$4B43                         ; $427A  [21 43 4B]  ; HL = Bank11_AreaDir
    LD A,($C968)                        ; $427D  [FA 68 C9]  ; wAreaID
    ADD A,A                             ; $4280  [87]  ; x2 (word index)
    ADD A,L                             ; $4281  [85]
    LD L,A                              ; $4282  [6F]
    LD A,$00                            ; $4283  [3E 00]
    ADC A,H                             ; $4285  [8C]
    LD H,A                              ; $4286  [67]  ; HL = &AreaDir[wAreaID]
    LD A,(HL+)                          ; $4287  [2A]  ; read descriptor ptr ...
    LD H,(HL)                           ; $4288  [66]  ; HL = area descriptor base
    LD L,A                              ; $4289  [6F]
    LD A,($C925)                        ; $428A  [FA 25 C9]  ; wScrollCount (room)
    ADD A,A                             ; $428D  [87]  ; x2
    ADD A,L                             ; $428E  [85]
    LD L,A                              ; $428F  [6F]
    LD A,$00                            ; $4290  [3E 00]
    ADC A,H                             ; $4292  [8C]
    LD H,A                              ; $4293  [67]  ; HL = &roomArray[room]
    LD A,(HL+)                          ; $4294  [2A]  ; read room ptr ...
    LD H,(HL)                           ; $4295  [66]  ; HL = room sub-descriptor
    LD L,A                              ; $4296  [6F]
    LD E,(HL)                           ; $4297  [5E]  ; DE = variant-selector ptr (lo) ...
    INC HL                              ; $4298  [23]
    LD D,(HL)                           ; $4299  [56]  ; (hi)
    INC HL                              ; $429A  [23]  ; HL -> first variant record
    LD A,(DE)                           ; $429B  [1A]  ; A = *selector = active variant index
    LD E,A                              ; $429C  [5F]  ; E = variant
    ADD A,A                             ; $429D  [87]  ; x2
    ADD A,E                             ; $429E  [83]  ; +E = x3
    ADD A,A                             ; $429F  [87]  ; x6 (6 bytes/variant)
    ADD A,L                             ; $42A0  [85]  ; + record base
    LD L,A                              ; $42A1  [6F]
    LD A,$00                            ; $42A2  [3E 00]
    ADC A,H                             ; $42A4  [8C]
    LD H,A                              ; $42A5  [67]  ; HL = &variant[active]
    INC HL                              ; $42A6  [23]  ; skip block,bank (+2) ...
    INC HL                              ; $42A7  [23]  ; (Fn8 stops at +0 for tilemap {block,bank}; we want the obj list)
    LD A,(HL+)                          ; $42A8  [2A]  ; read obj-list ptr ...
    LD H,(HL)                           ; $42A9  [66]  ; HL = object-list base (the obj= address)
    LD L,A                              ; $42AA  [6F]
    RET                                 ; $42AB  [C9]  ; return HL = compact object list for this room+variant
    LD A,($C926)                        ; $42AC  [FA 26 C9]  ; --- fallback (sub-area): wNeighbour $C926 ---
    CP $FF                              ; $42AF  [FE FF]  ; $FF = none
    JR NZ,$42B7                         ; $42B1  [20 04]  ; have neighbour -> ptr table
    LD HL,$4308                         ; $42B3  [21 08 43]  ; HL = fixed default list $4308
    RET                                 ; $42B6  [C9]  ; return
    LD HL,$42C8                         ; $42B7  [21 C8 42]  ; HL = ptr table $42C8 ...
    LD A,($C92B)                        ; $42BA  [FA 2B C9]  ; index = $C92B
    ADD A,A                             ; $42BD  [87]  ; x2
    ADD A,L                             ; $42BE  [85]
    LD L,A                              ; $42BF  [6F]
    LD A,$00                            ; $42C0  [3E 00]
    ADC A,H                             ; $42C2  [8C]
    LD H,A                              ; $42C3  [67]  ; HL = &table[$C92B]
    LD A,(HL+)                          ; $42C4  [2A]  ; read ptr ...
    LD H,(HL)                           ; $42C5  [66]  ; HL = object list
    LD L,A                              ; $42C6  [6F]
    RET                                 ; $42C7  [C9]  ; return


; ------------------------------------------------------------
; Bank11_Sub_4309  ($4309) — stamp a 2x2 door/stair overlay into the map buffer
; ------------------------------------------------------------
; Small patch, NOT a general arranger. Only in connected-map mode (wAreaSub
; $C969 != 0) and only for the room whose wScrollCount matches $C960. Writes a
; 2x2 tile block (tiles $3C,$3D top row; $3E,$3F bottom row) at offset
; ($C963:$C962) within the buffer DE. The `ADD A,$1F` step to reach the bottom
; row = advance +$20 across one INC — i.e. the buffer ROW STRIDE is $20 (32),
; confirming the tile-number map is 32 tiles wide.
; ------------------------------------------------------------
Bank11_Sub_4309:
    LD A,($C969)                        ; $4309  [FA 69 C9]  ; wAreaSub
    OR A                                ; $430C  [B7]
    RET Z                               ; $430D  [C8]        ; not connected-map mode → nothing
    LD HL,$C960                         ; $430E  [21 60 C9]
    LD A,($C925)                        ; $4311  [FA 25 C9]  ; wScrollCount
    CP (HL)                             ; $4314  [BE]
    RET NZ                              ; $4315  [C0]        ; only patch the matching room
    LD A,($C962)                        ; $4316  [FA 62 C9]
    LD L,A                              ; $4319  [6F]
    LD A,($C963)                        ; $431A  [FA 63 C9]
    LD H,A                              ; $431D  [67]
    ADD HL,DE                           ; $431E  [19]        ; HL = buffer + ($C963:$C962)
    LD A,$3C                            ; $431F  [3E 3C]
    LD (HL+),A                          ; $4321  [22]        ; top-left  = $3C
    INC A                               ; $4322  [3C]
    LD (HL),A                           ; $4323  [77]        ; top-right = $3D
    LD A,L                              ; $4324  [7D]
    ADD A,$1F                           ; $4325  [C6 1F]     ; +$1F after the INC = +$20 = next row (32-wide)
    LD L,A                              ; $4327  [6F]
    LD A,H                              ; $4328  [7C]
    ADC A,$00                           ; $4329  [CE 00]
    LD H,A                              ; $432B  [67]
    LD A,$3E                            ; $432C  [3E 3E]
    LD (HL+),A                          ; $432E  [22]        ; bottom-left  = $3E
    INC A                               ; $432F  [3C]
    LD (HL),A                           ; $4330  [77]        ; bottom-right = $3F
    RET                                 ; $4331  [C9]


; ============================================================================
; MAP OBJECT / NPC TABLE  ($D7D2)  — the per-scene NPC/object data
; ============================================================================
; $D7D2 is a WRAM table (NOT static ROM): an array of 32-byte ($20) records,
; $FF byte0 = end of list. It is BUILT on map entry by Bank11_Sub_477E, which
; EXPANDS a compact per-room source list in ROM (adding the zone origin from
; ROM0 table $31B6 to each object's X/Y).
;
; WHERE the source list lives: it is per-room and reached via the area
; descriptor chain — Bank11_Sub_4274 returns HL = word at [room_subdesc+4]
; (see AreaDir doc). So there is NO single flat table; each room points at its
; own compact list. (Statically, 88 rooms have a non-empty list, variant 0.)
;
; COMPACT SOURCE RECORD = 5 bytes, list $FF-terminated (byte0 == $FF = end):
;   [0] type/facing : low nibble = OBJECT TYPE (0-15, RST$00-dispatched by
;                     bank6/fn3 $4028 -> 16 handlers); high nibble = facing/dir,
;                     (>>4)&3 -> WRAM+$06. If bit7 set = HEADER record (5 bytes,
;                     produces no WRAM entry; skipped by the loader).
;   [1] sprite id   : which graphic (-> WRAM+$01/+$11; mapped by Sub_4839,
;                     values $E0-$E3/$F0+ are special sprite classes)
;   [2] x           : tile X, added to zone base_X from $31B6 (-> WRAM+$02)
;   [3] y           : tile Y, added to zone base_Y from $31B6 (-> WRAM+$03)
;   [4] event id    : EVENT/MESSAGE id this object runs (-> WRAM+$04)
;
; RESULTING WRAM 32-byte record (key fields the loader writes):
;   +$00 type  +$01 sprite id  +$02 tileX  +$03 tileY  +$04 event id
;   +$06 (type>>4)&3   +$11 sprite id copy   +$16 = Sub_4839(sprite id)
;   +$18/$19 pixel X (tileX*16+8, split hi/lo)   +$1A/$1B pixel Y
; (Talking to an NPC: bank6 finds you tile-aligned & facing it, calls
;  Bank11_Fn4 -> Sub_433F to find the object at that tile and return its +$04
;  event id via $FFD5.)
; ============================================================================



; ------------------------------------------------------------
; Bank11_Fn4  ($4332)  — "which object/NPC/door is the player facing?"
; ------------------------------------------------------------
; The interaction resolver: when the player presses A, this finds what they are
; facing and returns its event/message id in A (also stored to $FFD5); $FFD6 =
; the matched record index (or $FF if the hit came from the phase-2 door scan).
; Called from bank6 ($611D/$6186). It just seeds the scan (index 0, HL=$D7D2)
; and delegates to Sub_433F. Result feeds the bank6 -> bank4/fn5 dialogue chain.
; ------------------------------------------------------------
Bank11_Fn4:                                 ; $4332
    LD A,$00                                ; $4332  [3E 00]  ; record index = 0
    LDH ($D6),A                             ; $4334  [E0 D6]  ; $FFD6 = current record index
    LD HL,$D7D2                             ; $4336  [21 D2 D7]  ; HL = wObjectTable ($D7D2) base
    CALL $433F                              ; $4339  [CD 3F 43]  ; scan the table for the object the player faces
    LDH ($D5),A                             ; $433C  [E0 D5]  ; $FFD5 = matched object's +$04 = event/message id
    RET                                     ; $433E  [C9]  ; return (id in A / $FFD5)


; ------------------------------------------------------------
; Bank11_Sub_433F  ($433F)  — two-phase "what am I facing?" scanner
; ------------------------------------------------------------
; PHASE 1 ($433F-$4364): walk the EXPANDED object table $D7D2 in $20-byte
;   records. Per record: byte0 $FF = end-of-table; bit6 set = non-interactable
;   (skip); otherwise Sub_43E5 tests whether the player faces this object's cell.
;   On a hit -> return A = record[+4] (event/message id). $FFD6 tracks the index.
; PHASE 2 ($4366-$43A3): reached when phase 1 found no drawn object. Sets
;   $FFD6=$FF, re-resolves the room's COMPACT source list via Sub_4274, and walks
;   it in 5-byte records looking for a DOOR/WARP: a header record (byte0 bit7)
;   of class $80 whose cell the player is on (Sub_4452) and whose low nibble ==
;   the player's facing direction ($FF8E, or $0F = any). Hit -> A = record[+4];
;   otherwise A = $FF (nothing faced). So one call resolves NPCs first, then
;   directional doors/warps.
; ------------------------------------------------------------
Bank11_Sub_433F:
    LD A,(HL)                       ; $433F  [7E]  ; A = record[0] (type/facing byte)
    CP $FF                          ; $4340  [FE FF]  ; $FF = end of object table?
    JR Z,$4366                      ; $4342  [28 22]  ; end -> phase 2 (no drawn object matched) at $4366
    BIT 6,A                         ; $4344  [CB 77]  ; bit6 = non-interactable -> skip
    JR NZ,$4357                     ; $4346  [20 0F]  ; skip -> next record
    CALL $43E5                      ; $4348  [CD E5 43]  ; Sub_43E5: is the player standing/facing THIS object's cell?
    JR NZ,$4357                     ; $434B  [20 0A]  ; no match -> next record
    LD A,L                          ; $434D  [7D]  ; MATCH: HL += 4 ...
    ADD A,$04                       ; $434E  [C6 04]
    LD L,A                          ; $4350  [6F]
    LD A,H                          ; $4351  [7C]
    ADC A,$00                       ; $4352  [CE 00]
    LD H,A                          ; $4354  [67]  ; HL -> record[+4]
    LD A,(HL)                       ; $4355  [7E]  ; A = record[+4] = event/message id
    RET                             ; $4356  [C9]  ; return it
    LD A,L                          ; $4357  [7D]  ; --- next record: HL += $20 (record stride) ---
    ADD A,$20                       ; $4358  [C6 20]
    LD L,A                          ; $435A  [6F]
    LD A,H                          ; $435B  [7C]
    ADC A,$00                       ; $435C  [CE 00]
    LD H,A                          ; $435E  [67]
    LDH A,($D6)                     ; $435F  [F0 D6]  ; A = $FFD6 record index
    INC A                           ; $4361  [3C]  ; index++
    LDH ($D6),A                     ; $4362  [E0 D6]  ; store
    JR $433F                        ; $4364  [18 D9]  ; loop to next record
    LD A,$FF                        ; $4366  [3E FF]  ; phase 2: sentinel
    LDH ($D6),A                     ; $4368  [E0 D6]  ; $FFD6 = $FF (mark: no expanded-table match)
    CALL $4274                      ; $436A  [CD 74 42]  ; Sub_4274: resolve THIS room's compact object list -> HL
    LD A,(HL)                       ; $436D  [7E]  ; A = src record[0]
    CP $FF                          ; $436E  [FE FF]  ; end of list?
    RET Z                           ; $4370  [C8]  ; yes -> return (A=$FF, none faced)
    BIT 7,A                         ; $4371  [CB 7F]  ; bit7 = header/special record?
    JR Z,$43A1                      ; $4373  [28 2C]  ; not a header -> give up ($43A1 returns $FF)
    AND $F0                         ; $4375  [E6 F0]  ; isolate hi nibble
    CP $80                          ; $4377  [FE 80]  ; class $80 = door/warp?
    JR NZ,$4397                     ; $4379  [20 1C]  ; no -> next record (+5)
    CALL $4452                      ; $437B  [CD 52 44]  ; Sub_4452: is the player on this record's cell?
    JR NZ,$4397                     ; $437E  [20 17]  ; no -> next
    LD A,(HL)                       ; $4380  [7E]  ; record[0] again
    AND $0F                         ; $4381  [E6 0F]  ; low nibble = required facing direction
    CP $0F                          ; $4383  [FE 0F]  ; $0F = any direction
    JR Z,$438D                      ; $4385  [28 06]  ; any -> accept
    LD B,A                          ; $4387  [47]  ; B = required dir
    LDH A,($8E)                     ; $4388  [F0 8E]  ; A = $FF8E player facing (hScrollDir)
    CP B                            ; $438A  [B8]  ; facing matches required?
    JR NZ,$4397                     ; $438B  [20 0A]  ; no -> next record
    LD A,L                          ; $438D  [7D]  ; ACCEPT: HL += 4 ...
    ADD A,$04                       ; $438E  [C6 04]
    LD L,A                          ; $4390  [6F]
    LD A,H                          ; $4391  [7C]
    ADC A,$00                       ; $4392  [CE 00]
    LD H,A                          ; $4394  [67]  ; HL -> record[+4]
    LD A,(HL)                       ; $4395  [7E]  ; A = record[+4] = event/message id
    RET                             ; $4396  [C9]  ; return it
    LD A,L                          ; $4397  [7D]  ; --- next record: HL += 5 (compact stride) ---
    ADD A,$05                       ; $4398  [C6 05]
    LD L,A                          ; $439A  [6F]
    LD A,H                          ; $439B  [7C]
    ADC A,$00                       ; $439C  [CE 00]
    LD H,A                          ; $439E  [67]
    JR $436D                        ; $439F  [18 CC]  ; loop
    LD A,$FF                        ; $43A1  [3E FF]  ; not found -> A = $FF
    RET                             ; $43A3  [C9]  ; return

; ------------------------------------------------------------
; Bank11_Fn5  ($43A4) — query the tile/object TYPE the player faces
; ------------------------------------------------------------
; Returns the type byte in hFFD5 (default $FF). Early-outs to $FF if joypad
; bit6 ($FF90) or $D8D7 are nonzero. The helper at $43B8 walks the room object
; list (via Sub_4274): 5-byte records; a bit7 record whose hi-nibble is $90 is
; matched via Sub_4452 and returns record[+4]; otherwise steps +5; $FF ends -> $FF.
; ------------------------------------------------------------
Bank11_Fn5:                                 ; $43A4
    LD A,$FF                   ; $43A4  [3E FF]
    LDH ($D5),A                ; $43A6  [E0 D5]
    LDH A,($90)                ; $43A8  [F0 90]
    BIT 6,A                    ; $43AA  [CB 77]
    RET NZ                     ; $43AC  [C0]
    LD A,($D8D7)               ; $43AD  [FA D7 D8]
    OR A                       ; $43B0  [B7]
    RET NZ                     ; $43B1  [C0]
    CALL $43B8                 ; $43B2  [CD B8 43]
    LDH ($D5),A                ; $43B5  [E0 D5]
    RET                        ; $43B7  [C9]
    CALL $4274                 ; $43B8  [CD 74 42]
    LD A,(HL)                  ; $43BB  [7E]
    CP $FF                     ; $43BC  [FE FF]
    RET Z                      ; $43BE  [C8]
    BIT 7,A                    ; $43BF  [CB 7F]
    JR Z,$43E2                 ; $43C1  [28 1F]
    AND $F0                    ; $43C3  [E6 F0]
    CP $90                     ; $43C5  [FE 90]
    JR NZ,$43D8                ; $43C7  [20 0F]
    CALL $4452                 ; $43C9  [CD 52 44]
    JR NZ,$43D8                ; $43CC  [20 0A]
    LD A,L                     ; $43CE  [7D]
    ADD A,$04                  ; $43CF  [C6 04]
    LD L,A                     ; $43D1  [6F]
    LD A,H                     ; $43D2  [7C]
    ADC A,$00                  ; $43D3  [CE 00]
    LD H,A                     ; $43D5  [67]
    LD A,(HL)                  ; $43D6  [7E]
    RET                        ; $43D7  [C9]
    LD A,L                     ; $43D8  [7D]
    ADD A,$05                  ; $43D9  [C6 05]
    LD L,A                     ; $43DB  [6F]
    LD A,H                     ; $43DC  [7C]
    ADC A,$00                  ; $43DD  [CE 00]
    LD H,A                     ; $43DF  [67]
    JR $43BB                   ; $43E0  [18 D9]
    LD A,$FF                   ; $43E2  [3E FF]
    RET                        ; $43E4  [C9]

; ------------------------------------------------------------
; Bank11_Sub_43E5  ($43E5)  — object PIXEL bounding-box match (phase-1 predicate)
; ------------------------------------------------------------
; The predicate Sub_433F phase 1 uses on each EXPANDED $D7D2 record (HL). Tests
; whether the player's target position overlaps the object within one 16px tile:
;   - record[+5] bit0 set => inactive/hidden -> NO MATCH.
;   - dX = player target X ($FFDB/$FFDC, 16-bit pixel) - object X (record+$18/$19);
;     take |dX|; require < $10 (16 px). Same for dY vs object Y (record+$1A/$1B)
;     against player target Y ($FFDD/$FFDE).
; RETURN (shared exit $4447/$444C): A=0, Z = MATCH; A=1, NZ = no match. Preserves
; HL/BC/DE. ($4447-$4451 is the shared match/no-match tail, reused by Sub_4452.)
; ------------------------------------------------------------
Bank11_Sub_43E5:
    PUSH HL                         ; $43E5  [E5]  ; save regs
    PUSH BC                         ; $43E6  [C5]
    PUSH DE                         ; $43E7  [D5]
    LD A,L                          ; $43E8  [7D]  ; HL += 5 -> record[+5] ...
    ADD A,$05                       ; $43E9  [C6 05]
    LD L,A                          ; $43EB  [6F]
    LD A,H                          ; $43EC  [7C]
    ADC A,$00                       ; $43ED  [CE 00]
    LD H,A                          ; $43EF  [67]
    BIT 0,(HL)                      ; $43F0  [CB 46]  ; record[+5] bit0 = inactive/hidden flag
    JR NZ,$444C                     ; $43F2  [20 58]  ; set -> NO MATCH
    LD A,L                          ; $43F4  [7D]  ; HL += $13 -> record[+$18] (object pixel X, 16-bit) ...
    ADD A,$13                       ; $43F5  [C6 13]
    LD L,A                          ; $43F7  [6F]
    LD A,H                          ; $43F8  [7C]
    ADC A,$00                       ; $43F9  [CE 00]
    LD H,A                          ; $43FB  [67]
    LDH A,($DB)                     ; $43FC  [F0 DB]  ; A = player target X lo ($FFDB)
    SUB (HL)                        ; $43FE  [96]  ; - object X lo
    INC HL                          ; $43FF  [23]  ; HL -> +$19
    LD C,A                          ; $4400  [4F]  ; C = dX lo
    LDH A,($DC)                     ; $4401  [F0 DC]  ; A = player target X hi ($FFDC)
    SBC A,(HL)                      ; $4403  [9E]  ; - object X hi (with borrow)
    INC HL                          ; $4404  [23]  ; HL -> +$1A (obj Y lo)
    LD B,A                          ; $4405  [47]  ; B = dX hi
    JR NZ,$440F                     ; $4406  [20 07]  ; dX hi != 0 -> negative, take abs at $440F
    LD A,C                          ; $4408  [79]  ; dX positive
    CP $10                          ; $4409  [FE 10]  ; |dX| >= 16 (one metatile)?
    JR NC,$444C                     ; $440B  [30 3F]  ; outside 16px -> NO MATCH
    JR $4422                        ; $440D  [18 13]  ; within X -> test Y
    LD A,C                          ; $440F  [79]  ; --- negate dX (two's complement) = |dX| ---
    CPL                             ; $4410  [2F]
    ADD A,$01                       ; $4411  [C6 01]
    LD C,A                          ; $4413  [4F]
    LD A,B                          ; $4414  [78]
    CPL                             ; $4415  [2F]
    ADC A,$00                       ; $4416  [CE 00]
    LD B,A                          ; $4418  [47]
    LD A,B                          ; $4419  [78]  ; abs dX hi
    OR A                            ; $441A  [B7]  ; nonzero -> far outside
    JR NZ,$444C                     ; $441B  [20 2F]  ; NO MATCH
    LD A,C                          ; $441D  [79]
    CP $10                          ; $441E  [FE 10]  ; |dX| >= 16?
    JR NC,$444C                     ; $4420  [30 2A]  ; NO MATCH
    LDH A,($DD)                     ; $4422  [F0 DD]  ; A = player target Y lo ($FFDD)
    SUB (HL)                        ; $4424  [96]  ; - object Y lo
    INC HL                          ; $4425  [23]  ; HL -> +$1B
    LD C,A                          ; $4426  [4F]  ; C = dY lo
    LDH A,($DE)                     ; $4427  [F0 DE]  ; A = player target Y hi ($FFDE)
    SBC A,(HL)                      ; $4429  [9E]  ; - object Y hi
    LD B,A                          ; $442A  [47]  ; B = dY hi
    JR NZ,$4434                     ; $442B  [20 07]  ; negative -> abs at $4434
    LD A,C                          ; $442D  [79]  ; dY positive
    CP $10                          ; $442E  [FE 10]  ; |dY| >= 16?
    JR NC,$444C                     ; $4430  [30 1A]  ; NO MATCH
    JR $4447                        ; $4432  [18 13]  ; within X and Y -> MATCH
    LD A,C                          ; $4434  [79]  ; --- negate dY = |dY| ---
    CPL                             ; $4435  [2F]
    ADD A,$01                       ; $4436  [C6 01]
    LD C,A                          ; $4438  [4F]
    LD A,B                          ; $4439  [78]
    CPL                             ; $443A  [2F]
    ADC A,$00                       ; $443B  [CE 00]
    LD B,A                          ; $443D  [47]
    LD A,B                          ; $443E  [78]  ; abs dY hi
    OR A                            ; $443F  [B7]  ; nonzero -> far outside
    JR NZ,$444C                     ; $4440  [20 0A]  ; NO MATCH
    LD A,C                          ; $4442  [79]
    CP $10                          ; $4443  [FE 10]  ; |dY| >= 16?
    JR NC,$444C                     ; $4445  [30 05]  ; NO MATCH
    XOR A                           ; $4447  [AF]  ; MATCH: A=0 (Z set)
    POP DE                          ; $4448  [D1]  ; restore regs
    POP BC                          ; $4449  [C1]
    POP HL                          ; $444A  [E1]
    RET                             ; $444B  [C9]  ; return (Z=match)
    XOR A                           ; $444C  [AF]  ; NO MATCH: A=1 ...
    INC A                           ; $444D  [3C]  ; (NZ set)
    POP DE                          ; $444E  [D1]  ; restore regs
    POP BC                          ; $444F  [C1]
    POP HL                          ; $4450  [E1]
    RET                             ; $4451  [C9]  ; return (NZ=no match)


; ------------------------------------------------------------
; Bank11_Sub_4452  ($4452)  — object CELL (grid coord) match (phase-2 predicate)
; ------------------------------------------------------------
; The predicate Sub_433F phase 2 uses on each COMPACT source record (HL). Unlike
; Sub_43E5 (pixel box), this compares GRID CELLS: it converts the player's pixel
; position to a metatile (pixel/16), then takes it modulo the zone size via ROM0
; $21CA (divide, remainder in A) to get the ZONE-RELATIVE column/row, and matches
; against the record's stored tile X/Y:
;   - column = (player X /16) mod 10  == record+2   (zone is 10 tiles wide)
;   - row    = (player Y /16) mod 8   == record+3   (zone is 8 tiles tall)
; RETURN via the shared tail: MATCH -> $4447 (A=0, Z); mismatch -> $444C (A=1,NZ).
; Preserves HL/BC/DE. Used to detect the door/warp cell the player stands on.
; ------------------------------------------------------------
Bank11_Sub_4452:
    PUSH HL                         ; $4452  [E5]  ; save regs
    PUSH BC                         ; $4453  [C5]
    PUSH DE                         ; $4454  [D5]
    INC HL                          ; $4455  [23]  ; HL -> record+2 (tile X field) ...
    INC HL                          ; $4456  [23]
    LDH A,($DB)                     ; $4457  [F0 DB]  ; A = player X lo (pixel, $FFDB)
    SWAP A                          ; $4459  [CB 37]  ; --- metatile X = pixelX / 16 ---
    AND $0F                         ; $445B  [E6 0F]
    LD B,A                          ; $445D  [47]  ; low nibble
    LDH A,($DC)                     ; $445E  [F0 DC]  ; A = player X hi
    SWAP A                          ; $4460  [CB 37]
    AND $F0                         ; $4462  [E6 F0]  ; hi nibble
    OR B                            ; $4464  [B0]  ; combine
    LD B,A                          ; $4465  [47]  ; B = player metatile X
    LD A,$0A                        ; $4466  [3E 0A]  ; divisor = 10 (zone width)
    CALL $21CA                      ; $4468  [CD CA 21]  ; ROM0 $21CA divide: A = B mod 10 = zone-relative COLUMN
    CP (HL)                         ; $446B  [BE]  ; == record's X cell?
    JR NZ,$444C                     ; $446C  [20 DE]  ; no -> NO MATCH
    INC HL                          ; $446E  [23]  ; HL -> record+3 (tile Y)
    LDH A,($DD)                     ; $446F  [F0 DD]  ; A = player Y lo ($FFDD)
    SWAP A                          ; $4471  [CB 37]  ; --- metatile Y = pixelY / 16 ---
    AND $0F                         ; $4473  [E6 0F]
    LD B,A                          ; $4475  [47]
    LDH A,($DE)                     ; $4476  [F0 DE]  ; A = player Y hi
    SWAP A                          ; $4478  [CB 37]
    AND $F0                         ; $447A  [E6 F0]
    OR B                            ; $447C  [B0]
    LD B,A                          ; $447D  [47]  ; B = player metatile Y
    LD A,$08                        ; $447E  [3E 08]  ; divisor = 8 (zone height)
    CALL $21CA                      ; $4480  [CD CA 21]  ; ROM0 $21CA divide: A = B mod 8 = zone-relative ROW
    CP (HL)                         ; $4483  [BE]  ; == record's Y cell?
    JR NZ,$444C                     ; $4484  [20 C6]  ; no -> NO MATCH
    JR $4447                        ; $4486  [18 BF]  ; both match -> MATCH ($4447)

; ------------------------------------------------------------
; ------------------------------------------------------------
; Bank11_Fn9  ($4488)   Zone Border Event Scanner
; ------------------------------------------------------------
; Called after each completed player step while in an overworld zone.
; Scans the event list for the current area/zone looking for a trigger
; at a BORDER tile (edge column X=0 or X=9, edge row Y=0 or Y=7).
; Border triggers represent zone-exit doorways — when the player walks
; off the edge of the 10×8 navigable grid.
;
; Counterpart: Bank11_Fn6 handles interior triggers (non-border tiles).
; Both functions use the same event list; the filter in each determines
; which entries it considers.
;
; Event list entry format (7 bytes):
;   [0]   X  — relative tile column in zone (0–9, or border sentinel)
;   [1]   Y  — relative tile row in zone (0–7, or border sentinel)
;   [2]   dest_area    → wNextAreaID ($C96D)
;   [3]   dest_sub     → wNextAreaSub ($C96E); 0=normal area, $80=sub-area exit
;   [4]   dest_scroll  — lo nibble = dest zone scroll_count for spawn coords
;                        bit7 = extra Y offset flag
;   [5]   spawn_X offset within destination zone
;   [6]   spawn_Y offset within destination zone
;   [$FF] end-of-list sentinel
;
; Table chain:
;   $4B43[wAreaID×2]              → scroll_count_table_ptr
;   scroll_count_table_ptr[wScrollCount×2] → sptr (zone entry)
;   sptr[0:1]                     → DE = WRAM ptr to current zone_type
;   sptr+2 + *(DE)×6 + 4         → HL = event_list_ptr
;
; Zone base coords:
;   $31B6[wScrollCount×2] → (base_X, base_Y) in world tile coords
;   Position check: tileX($FF97) - base_X == entry[X]
;                   tileY($FF98) - base_Y == entry[Y]
;
; World layout (confirmed by $31B6):
;   40 tile cols × 32 tile rows = 4×4 arrangement of 10×8 zones
;   scroll_count = row*4 + col  (row/col in zone grid)
; ------------------------------------------------------------
Bank11_Fn9:
    LD A,($C850)                    ; $4488  [FA 50 C8]  ; wAnimActive
    OR A                            ; $448B  [B7]
    RET NZ                          ; $448C  [C0]  ; abort if animation running
    LD A,($C88E)                    ; $448D  [FA 8E C8]  ; wSceneState
    OR A                            ; $4490  [B7]
    RET NZ                          ; $4491  [C0]  ; abort if scene in transition
    LD A,($C88F)                    ; $4492  [FA 8F C8]  ; wInitFlag
    OR A                            ; $4495  [B7]
    RET NZ                          ; $4496  [C0]  ; abort if init in progress
    LD A,($C8EB)                    ; $4497  [FA EB C8]  ; wStateFlags
    BIT 0,A                         ; $449A  [CB 47]
    RET NZ                          ; $449C  [C0]  ; abort if state-flag bit0 set
    LDH A,($FF90)                   ; $449D  [F0 90]  ; hScrollFlags
    BIT 0,A                         ; $449F  [CB 47]
    RET NZ                          ; $44A1  [C0]  ; abort if player is mid-scroll (bit0=scrolling)
    LD A,($C969)                    ; $44A2  [FA 69 C9]  ; wAreaSub
    OR A                            ; $44A5  [B7]
    RET NZ                          ; $44A6  [C0]  ; abort if inside a sub-area (handled by fn6 path)
; --- Event table lookup (shared with Fn6/Fn8) ---
; HL = $4B43 + wAreaID*2 → read 16-bit ptr → scroll_count_table
    LD HL,$4B43                     ; $44A7  [21 43 4B]
    LD A,($C968)                    ; $44AA  [FA 68 C9]  ; wAreaID
    ADD A,A                         ; $44AD  [87]  ; ×2 (2 bytes per entry)
    ADD A,L                         ; $44AE  [85]
    LD L,A                          ; $44AF  [6F]
    LD A,$00                        ; $44B0  [3E 00]
    ADC A,H                         ; $44B2  [8C]
    LD H,A                          ; $44B3  [67]
    LD A,(HL+)                      ; $44B4  [2A]
    LD H,(HL)                       ; $44B5  [66]
    LD L,A                          ; $44B6  [6F]  ; HL = scroll_count_table_ptr
; HL = scroll_count_table + wScrollCount*2 → read 16-bit ptr → sptr
    LD A,($C925)                    ; $44B7  [FA 25 C9]  ; wScrollCount
    ADD A,A                         ; $44BA  [87]  ; ×2
    ADD A,L                         ; $44BB  [85]
    LD L,A                          ; $44BC  [6F]
    LD A,$00                        ; $44BD  [3E 00]
    ADC A,H                         ; $44BF  [8C]
    LD H,A                          ; $44C0  [67]
    LD A,(HL+)                      ; $44C1  [2A]
    LD H,(HL)                       ; $44C2  [66]
    LD L,A                          ; $44C3  [6F]  ; HL = sptr (zone entry block)
; DE = sptr[0:1] = WRAM ptr to runtime zone_type index
    LD E,(HL)                       ; $44C4  [5E]
    INC HL                          ; $44C5  [23]
    LD D,(HL)                       ; $44C6  [56]
    INC HL                          ; $44C7  [23]  ; HL = sptr+2
; A = *DE = zone_type; HL = sptr+2 + zone_type*6 + 4 → event_list_ptr
    LD A,(DE)                       ; $44C8  [1A]  ; A = current zone_type (runtime WRAM value)
    LD E,A                          ; $44C9  [5F]
    ADD A,A                         ; $44CA  [87]  ; A×2
    ADD A,E                         ; $44CB  [83]  ; A×3
    ADD A,A                         ; $44CC  [87]  ; A×6
    ADD A,L                         ; $44CD  [85]
    LD L,A                          ; $44CE  [6F]
    LD A,$00                        ; $44CF  [3E 00]
    ADC A,H                         ; $44D1  [8C]
    LD H,A                          ; $44D2  [67]  ; HL = sptr+2 + zone_type*6
    INC HL                          ; $44D3  [23]
    INC HL                          ; $44D4  [23]
    INC HL                          ; $44D5  [23]
    INC HL                          ; $44D6  [23]  ; +4 (skip 4 header bytes within 6-byte type entry)
    LD A,(HL+)                      ; $44D7  [2A]
    LD H,(HL)                       ; $44D8  [66]
    LD L,A                          ; $44D9  [6F]  ; HL = event_list_ptr
; DE = $31B6 + wScrollCount*2 → (base_X, base_Y) for current zone origin
    LD BC,$31B6                     ; $44DA  [01 B6 31]
    LD A,($C925)                    ; $44DD  [FA 25 C9]  ; wScrollCount
    ADD A,A                         ; $44E0  [87]  ; ×2
    ADD A,C                         ; $44E1  [81]
    LD C,A                          ; $44E2  [4F]
    LD A,$00                        ; $44E3  [3E 00]
    ADC A,B                         ; $44E5  [88]
    LD B,A                          ; $44E6  [47]  ; BC = $31B6 + scrollCount*2
    LD A,(BC)                       ; $44E7  [0A]
    LD E,A                          ; $44E8  [5F]  ; E = base_X (tile column of zone origin)
    INC BC                          ; $44E9  [03]
    LD A,(BC)                       ; $44EA  [0A]
    LD D,A                          ; $44EB  [57]  ; D = base_Y (tile row of zone origin)
; --- Fn9 border-event scan loop ---
; Filter: only attempt position check if entry[X]=0/9 OR entry[Y]=0/7
; (these are the border columns/rows of the 10×8 navigable grid)
Bank11_Fn9_Loop:
    LD A,(HL)                       ; $44EC  [7E]  ; entry[X]
    CP $FF                          ; $44ED  [FE FF]
    RET Z                           ; $44EF  [C8]  ; end-of-list → no event, return
    LD A,(HL)                       ; $44F0  [7E]  ; entry[X]
    OR A                            ; $44F1  [B7]
    JR Z,Bank11_Fn9_PosCheck        ; $44F2  [28 10]  ; X=0 (left edge) → check position
    CP $09                          ; $44F4  [FE 09]
    JR Z,Bank11_Fn9_PosCheck        ; $44F6  [28 0C]  ; X=9 (right edge) → check position
    INC HL                          ; $44F8  [23]  ; peek entry[Y]
    LD A,(HL)                       ; $44F9  [7E]
    DEC HL                          ; $44FA  [2B]
    OR A                            ; $44FB  [B7]
    JR Z,Bank11_Fn9_PosCheck        ; $44FC  [28 06]  ; Y=0 (top edge) → check position
    CP $07                          ; $44FE  [FE 07]
    JR Z,Bank11_Fn9_PosCheck        ; $4500  [28 02]  ; Y=7 (bottom edge) → check position
    JR Bank11_Fn9_Next              ; $4502  [18 0F]  ; non-border entry → skip
Bank11_Fn9_PosCheck:
    LDH A,($FF97)                   ; $4504  [F0 97]  ; tileX (current player tile column)
    SUB E                           ; $4506  [93]  ; relative to zone origin
    CP (HL)                         ; $4507  [BE]  ; == entry[X]?
    JR NZ,Bank11_Fn9_Next           ; $4508  [20 09]
    INC HL                          ; $450A  [23]
    LDH A,($FF98)                   ; $450B  [F0 98]  ; tileY
    SUB D                           ; $450D  [92]  ; relative to zone origin
    CP (HL)                         ; $450E  [BE]  ; == entry[Y]?
    DEC HL                          ; $450F  [2B]
    JP Z,Bank11_EventMatch          ; $4510  [CA A8 45]  ; both match → trigger event
Bank11_Fn9_Next:
    LD A,L                          ; $4513  [7D]
    ADD A,$07                       ; $4514  [C6 07]  ; advance HL by 7 (entry size)
    LD L,A                          ; $4516  [6F]
    LD A,H                          ; $4517  [7C]
    ADC A,$00                       ; $4518  [CE 00]
    LD H,A                          ; $451A  [67]
    JR Bank11_Fn9_Loop              ; $451B  [18 CF]

; ------------------------------------------------------------
; Bank11_Fn6  ($451D)   Interior Event Scanner
; ------------------------------------------------------------
; Same structure as Fn9 but handles NON-border entries:
; only fires for event positions where X≠0,9 AND Y≠0,7.
; These include interior doorways, stairs, dungeon entrances.
;
; Additional path at $46A7: when wAreaSub≠0 (inside a sub-area),
; checks if player is at the sub-area exit zone (scroll_count matches
; wScrollEdgeCount and hZoneResult>>2==$0F for open space).
; ------------------------------------------------------------
Bank11_Fn6:
    LD A,($C8EB)                    ; $451D  [FA EB C8]  ; wStateFlags
    BIT 0,A                         ; $4520  [CB 47]
    JP NZ,Bank11_AreaRouting        ; $4522  [C2 74 46]  ; busy → go to routing
    LDH A,($FF90)                   ; $4525  [F0 90]  ; hScrollFlags
    BIT 0,A                         ; $4527  [CB 47]
    JP NZ,Bank11_AreaRouting        ; $4529  [C2 74 46]  ; mid-scroll → routing
    LD A,($C969)                    ; $452C  [FA 69 C9]  ; wAreaSub
    OR A                            ; $452F  [B7]
    JP NZ,Bank11_SubAreaExit        ; $4530  [C2 A7 46]  ; in sub-area → sub-area exit check
; --- Event table lookup (same as Fn9) ---
    LD HL,$4B43                     ; $4533  [21 43 4B]
    LD A,($C968)                    ; $4536  [FA 68 C9]  ; wAreaID
    ADD A,A                         ; $4539  [87]
    ADD A,L                         ; $453A  [85]
    LD L,A                          ; $453B  [6F]
    LD A,$00                        ; $453C  [3E 00]
    ADC A,H                         ; $453E  [8C]
    LD H,A                          ; $453F  [67]
    LD A,(HL+)                      ; $4540  [2A]
    LD H,(HL)                       ; $4541  [66]
    LD L,A                          ; $4542  [6F]
    LD A,($C925)                    ; $4543  [FA 25 C9]  ; wScrollCount
    ADD A,A                         ; $4546  [87]
    ADD A,L                         ; $4547  [85]
    LD L,A                          ; $4548  [6F]
    LD A,$00                        ; $4549  [3E 00]
    ADC A,H                         ; $454B  [8C]
    LD H,A                          ; $454C  [67]
    LD A,(HL+)                      ; $454D  [2A]
    LD H,(HL)                       ; $454E  [66]
    LD L,A                          ; $454F  [6F]  ; HL = sptr
    LD E,(HL)                       ; $4550  [5E]
    INC HL                          ; $4551  [23]
    LD D,(HL)                       ; $4552  [56]
    INC HL                          ; $4553  [23]
    LD A,(DE)                       ; $4554  [1A]  ; zone_type (runtime)
    LD E,A                          ; $4555  [5F]
    ADD A,A                         ; $4556  [87]
    ADD A,E                         ; $4557  [83]
    ADD A,A                         ; $4558  [87]  ; A×6
    ADD A,L                         ; $4559  [85]
    LD L,A                          ; $455A  [6F]
    LD A,$00                        ; $455B  [3E 00]
    ADC A,H                         ; $455D  [8C]
    LD H,A                          ; $455E  [67]
    INC HL                          ; $455F  [23]
    INC HL                          ; $4560  [23]
    INC HL                          ; $4561  [23]
    INC HL                          ; $4562  [23]
    LD A,(HL+)                      ; $4563  [2A]
    LD H,(HL)                       ; $4564  [66]
    LD L,A                          ; $4565  [6F]  ; HL = event_list_ptr
    LD BC,$31B6                     ; $4566  [01 B6 31]
    LD A,($C925)                    ; $4569  [FA 25 C9]  ; wScrollCount
    ADD A,A                         ; $456C  [87]
    ADD A,C                         ; $456D  [81]
    LD C,A                          ; $456E  [4F]
    LD A,$00                        ; $456F  [3E 00]
    ADC A,B                         ; $4571  [88]
    LD B,A                          ; $4572  [47]
    LD A,(BC)                       ; $4573  [0A]
    LD E,A                          ; $4574  [5F]  ; E = base_X
    INC BC                          ; $4575  [03]
    LD A,(BC)                       ; $4576  [0A]
    LD D,A                          ; $4577  [57]  ; D = base_Y
; --- Fn6 interior-event scan loop ---
; Filter: skip entries where X=0/9 (border columns) or X matches but Y=0/7 (border rows)
; Only fires for interior positions
Bank11_Fn6_Loop:
    LD A,(HL)                       ; $4578  [7E]  ; entry[X]
    CP $FF                          ; $4579  [FE FF]
    JP Z,Bank11_AreaRouting         ; $457B  [CA 74 46]  ; end-of-list → routing
    LD A,(HL)                       ; $457E  [7E]
    OR A                            ; $457F  [B7]
    JR Z,Bank11_Fn6_Next            ; $4580  [28 1C]  ; X=0 → border, skip
    CP $09                          ; $4582  [FE 09]
    JR Z,Bank11_Fn6_Next            ; $4584  [28 18]  ; X=9 → border, skip
    LDH A,($FF97)                   ; $4586  [F0 97]  ; tileX
    SUB E                           ; $4588  [93]  ; relative to zone origin
    CP (HL)                         ; $4589  [BE]  ; == entry[X]?
    JR NZ,Bank11_Fn6_Next           ; $458A  [20 12]
    INC HL                          ; $458C  [23]  ; peek entry[Y]
    LD A,(HL)                       ; $458D  [7E]
    DEC HL                          ; $458E  [2B]
    OR A                            ; $458F  [B7]
    JR Z,Bank11_Fn6_Next            ; $4590  [28 0C]  ; Y=0 → border row, skip
    CP $07                          ; $4592  [FE 07]
    JR Z,Bank11_Fn6_Next            ; $4594  [28 08]  ; Y=7 → border row, skip
    INC HL                          ; $4596  [23]  ; move HL to entry[Y]
    LDH A,($FF98)                   ; $4597  [F0 98]  ; tileY
    SUB D                           ; $4599  [92]  ; relative to zone origin
    CP (HL)                         ; $459A  [BE]  ; == entry[Y]?
    DEC HL                          ; $459B  [2B]
    JR Z,Bank11_EventMatch          ; $459C  [28 0A]  ; match → trigger event
Bank11_Fn6_Next:
    LD A,L                          ; $459E  [7D]
    ADD A,$07                       ; $459F  [C6 07]  ; advance HL by 7 (entry size)
    LD L,A                          ; $45A1  [6F]
    LD A,H                          ; $45A2  [7C]
    ADC A,$00                       ; $45A3  [CE 00]
    LD H,A                          ; $45A5  [67]
    JR Bank11_Fn6_Loop              ; $45A6  [18 D0]

; ------------------------------------------------------------
; Bank11_EventMatch  ($45A8)   Shared event trigger handler
; ------------------------------------------------------------
; Called when Fn9 or Fn6 finds a matching event entry.
; HL points to entry[0] (X byte) of the matched 7-byte entry.
; DE = (base_X, base_Y) from $31B6 for current scroll_count.
;
; Decodes destination area + spawn position, sets event-active flag,
; then calls $2A21 to check accessibility and bank1/fn9 to execute
; the area transition (or plays a blocked animation if inaccessible).
; ------------------------------------------------------------
Bank11_EventMatch:
    INC HL                          ; $45A8  [23]
    INC HL                          ; $45A9  [23]  ; skip X, Y → point to entry[2]
    LD A,(HL+)                      ; $45AA  [2A]
    LD ($C96D),A                    ; $45AB  [EA 6D C9]  ; wNextAreaID   = entry[2] (dest area lo)
    LD A,(HL+)                      ; $45AE  [2A]
    LD ($C96E),A                    ; $45AF  [EA 6E C9]  ; wNextAreaSub  = entry[3] (dest sub / $80=sub-exit)
; Compute dest spawn X:
;   entry[4] lo nibble = dest scroll_count → index into $31B6 for dest zone base_X
;   spawn_X = $31B6[dest_sc].base_X + entry[5]  (16-pixel packed coord)
    LD DE,$31B6                     ; $45B2  [11 B6 31]
    LD A,(HL+)                      ; $45B5  [2A]  ; A = entry[4]
    PUSH AF                         ; $45B6  [F5]  ; save (bit7 = flip-Y flag)
    AND $0F                         ; $45B7  [E6 0F]  ; extract dest scroll_count
    ADD A,A                         ; $45B9  [87]  ; ×2
    ADD A,E                         ; $45BA  [83]
    LD E,A                          ; $45BB  [5F]
    LD A,$00                        ; $45BC  [3E 00]
    ADC A,D                         ; $45BE  [8A]
    LD D,A                          ; $45BF  [57]  ; DE = $31B6 + dest_sc*2
    LD A,(DE)                       ; $45C0  [1A]  ; dest base_X
    ADD A,(HL)                      ; $45C1  [86]  ; + entry[5] spawn_X offset
    INC DE                          ; $45C2  [13]
    INC HL                          ; $45C3  [23]
    SWAP A                          ; $45C4  [CB 37]  ; swap nibbles (pack into scroll coord format)
    LD B,A                          ; $45C6  [47]
    AND $F0                         ; $45C7  [E6 F0]
    LD C,A                          ; $45C9  [4F]  ; C = hi-part (X in screen units lo)
    LD A,B                          ; $45CA  [78]
    AND $0F                         ; $45CB  [E6 0F]
    LD B,A                          ; $45CD  [47]  ; B = lo-part
    LD A,C                          ; $45CE  [79]
    ADD A,$08                       ; $45CF  [C6 08]  ; +8 (half-tile offset for 16px step alignment)
    LD C,A                          ; $45D1  [4F]
    LD A,B                          ; $45D2  [78]
    ADC A,$00                       ; $45D3  [CE 00]
    LD B,A                          ; $45D5  [47]
    LD A,C                          ; $45D6  [79]
    LD ($C96F),A                    ; $45D7  [EA 6F C9]  ; wSpawnX lo
    LD A,B                          ; $45DA  [78]
    LD ($C970),A                    ; $45DB  [EA 70 C9]  ; wSpawnX hi
; Compute dest spawn Y:
;   spawn_Y = $31B6[dest_sc].base_Y + entry[6]
    LD A,(DE)                       ; $45DE  [1A]  ; dest base_Y
    ADD A,(HL)                      ; $45DF  [86]  ; + entry[6] spawn_Y offset
    INC DE                          ; $45E0  [13]
    INC HL                          ; $45E1  [23]
    SWAP A                          ; $45E2  [CB 37]
    LD B,A                          ; $45E4  [47]
    AND $F0                         ; $45E5  [E6 F0]
    LD C,A                          ; $45E7  [4F]
    LD A,B                          ; $45E8  [78]
    AND $0F                         ; $45E9  [E6 0F]
    LD B,A                          ; $45EB  [47]
    LD A,C                          ; $45EC  [79]
    ADD A,$08                       ; $45ED  [C6 08]
    LD C,A                          ; $45EF  [4F]
    LD A,B                          ; $45F0  [78]
    ADC A,$00                       ; $45F1  [CE 00]
    LD B,A                          ; $45F3  [47]
    POP AF                          ; $45F4  [F1]  ; restore entry[4]
    BIT 7,A                         ; $45F5  [CB 7F]  ; bit7 = extra Y offset flag
    JR Z,Bank11_SpawnNoFlip         ; $45F7  [28 08]
    LD A,C                          ; $45F9  [79]
    ADD A,$08                       ; $45FA  [C6 08]  ; additional +8 Y offset
    LD C,A                          ; $45FC  [4F]
    LD A,B                          ; $45FD  [78]
    ADC A,$00                       ; $45FE  [CE 00]
    LD B,A                          ; $4600  [47]
Bank11_SpawnNoFlip:
    LD A,C                          ; $4601  [79]
    LD ($C971),A                    ; $4602  [EA 71 C9]  ; wSpawnY lo
    LD A,B                          ; $4605  [78]
    LD ($C972),A                    ; $4606  [EA 72 C9]  ; wSpawnY hi
    LD A,$01                        ; $4609  [3E 01]
    LD ($C96C),A                    ; $460B  [EA 6C C9]  ; wEventActive = 1 (trigger armed)
; Check if this is a normal area transition or sub-area flag
    LD A,($C96E)                    ; $460E  [FA 6E C9]  ; wNextAreaSub
    OR A                            ; $4611  [B7]
    JR NZ,Bank11_AreaRouting        ; $4612  [20 57]  ; sub-area exit ($80) → skip area check
; Special case: area $10 at scroll scroll-Y=$68 is a known boundary
    LD A,($C969)                    ; $4614  [FA 69 C9]  ; wAreaSub (current)
    OR A                            ; $4617  [B7]
    JR NZ,Bank11_CheckAccess        ; $4618  [20 0D]
    LD A,($C968)                    ; $461A  [FA 68 C9]  ; wAreaID
    CP $10                          ; $461D  [FE 10]
    JR NZ,Bank11_CheckAccess        ; $461F  [20 06]
    LDH A,($FF95)                   ; $4621  [F0 95]  ; hScrollY_lo
    CP $68                          ; $4623  [FE 68]
    JR Z,Bank11_DoTransition        ; $4625  [28 05]
Bank11_CheckAccess:
    CALL $2A21                      ; $4627  [CD 21 2A]  ; ROM0 $2A21: check if dest area accessible
    JR Z,Bank11_Blocked             ; $462A  [28 2F]  ; Z=not accessible → play blocked anim
Bank11_DoTransition:
    LD A,($C968)                    ; $462C  [FA 68 C9]  ; save current area
    LD L,A                          ; $462F  [6F]
    LD A,($C969)                    ; $4630  [FA 69 C9]
    LD H,A                          ; $4633  [67]
    PUSH HL                         ; $4634  [E5]  ; push current (wAreaID, wAreaSub)
    LD A,($C96D)                    ; $4635  [FA 6D C9]
    LD L,A                          ; $4638  [6F]
    LD A,($C96E)                    ; $4639  [FA 6E C9]
    LD H,A                          ; $463C  [67]
    LD A,L                          ; $463D  [7D]
    LD ($C968),A                    ; $463E  [EA 68 C9]  ; wAreaID = dest
    LD A,H                          ; $4641  [7C]
    LD ($C969),A                    ; $4642  [EA 69 C9]  ; wAreaSub = dest
    CALL $2A21                      ; $4645  [CD 21 2A]  ; check dest area accessible
    POP HL                          ; $4648  [E1]
    PUSH AF                         ; $4649  [F5]
    LD A,L                          ; $464A  [7D]
    LD ($C968),A                    ; $464B  [EA 68 C9]  ; restore current area
    LD A,H                          ; $464E  [7C]
    LD ($C969),A                    ; $464F  [EA 69 C9]
    POP AF                          ; $4652  [F1]
    JR NZ,Bank11_Blocked            ; $4653  [20 06]
    LD HL,$0109                     ; $4655  [21 09 01]
    RST $10                         ; $4658  [D7]  ; → bank1/fn9  (execute area transition)
    JR Bank11_AreaRouting           ; $4659  [18 10]
Bank11_Blocked:
    LD A,$03                        ; $465B  [3E 03]
    CALL $1A5B                      ; $465D  [CD 5B 1A]  ; → ROM0 $1A5B (play blocked sound)
    LD HL,$C88F                     ; $4660  [21 8F C8]
    INC (HL)                        ; $4663  [34]  ; wInitFlag++
    LD A,$51                        ; $4664  [3E 51]
    CALL $1EFF                      ; $4666  [CD FF 1E]  ; → ROM0 $1EFF (play blocked animation)
    JR Bank11_AreaRouting           ; $4669  [18 09]

; ------------------------------------------------------------
; Bank11_AreaRouting  ($4674)
; ------------------------------------------------------------
; After an event (or when no event matched), routes special areas
; to bank22/fn8 for additional processing.
; Special area IDs: $53, $54–$59, $61–$64 (indoor/dungeon areas).
; ------------------------------------------------------------
Bank11_AreaRouting:
    LD HL,$C8EB                     ; $466B  [21 EB C8]
    SET 5,(HL)                      ; $466E  [CB EE]  ; wStateFlags |= bit5
    XOR A                           ; $4670  [AF]
    LD ($C905),A                    ; $4671  [EA 05 C9]  ; wScrollPhase = 0
    LD A,($C968)                    ; $4674  [FA 68 C9]  ; wAreaID
    LD A,($C968)                    ; $4677  [FA 68 C9]  ; wAreaID  (redundant load)
    CP $53                          ; $467A  [FE 53]
    JR Z,Bank11_RouteBank22         ; $467C  [28 57]
    CP $61                          ; $467E  [FE 61]
    JR Z,Bank11_RouteBank22         ; $4680  [28 53]
    CP $62                          ; $4682  [FE 62]
    JR Z,Bank11_RouteBank22         ; $4684  [28 4F]
    CP $63                          ; $4686  [FE 63]
    JR Z,Bank11_RouteBank22         ; $4688  [28 4B]
    CP $64                          ; $468A  [FE 64]
    JR Z,Bank11_RouteBank22         ; $468C  [28 47]
    CP $54                          ; $468E  [FE 54]
    JR Z,Bank11_RouteBank22         ; $4690  [28 43]
    CP $55                          ; $4692  [FE 55]
    JR Z,Bank11_RouteBank22         ; $4694  [28 3F]
    CP $56                          ; $4696  [FE 56]
    JR Z,Bank11_RouteBank22         ; $4698  [28 3B]
    CP $57                          ; $469A  [FE 57]
    JR Z,Bank11_RouteBank22         ; $469C  [28 37]
    CP $58                          ; $469E  [FE 58]
    JR Z,Bank11_RouteBank22         ; $46A0  [28 33]
    CP $59                          ; $46A2  [FE 59]
    JR Z,Bank11_RouteBank22         ; $46A4  [28 2F]
    RET                             ; $46A6  [C9]

; ------------------------------------------------------------
; Bank11_SubAreaExit  ($46A7)
; ------------------------------------------------------------
; Handles sub-area exit: when wAreaSub≠0 and player reaches the
; exit zone (scroll_count == wScrollEdgeCount at $C960) on a
; fully passable tile (hZoneID>>2 == $0F).
; Sets up exit transition to dest (area=0, sub=$80) and calls
; Bank11_Sub_46DA to finalize sub-area state, then bank22/fn8.
; ------------------------------------------------------------
Bank11_SubAreaExit:
    LD HL,$C960                     ; $46A7  [21 60 C9]  ; wScrollEdgeCount
    LD A,($C925)                    ; $46AA  [FA 25 C9]  ; wScrollCount
    CP (HL)                         ; $46AD  [BE]  ; at the exit scroll boundary?
    JR NZ,Bank11_RouteBank22        ; $46AE  [20 25]
    LDH A,($FFAA)                   ; $46B0  [F0 AA]  ; hZoneID
    SRL A                           ; $46B2  [CB 3F]
    SRL A                           ; $46B4  [CB 3F]  ; >>2
    CP $0F                          ; $46B6  [FE 0F]
    JR NZ,Bank11_RouteBank22        ; $46B8  [20 1B]  ; not fully open → route to bank22
    LD A,$01                        ; $46BA  [3E 01]
    LD ($C96C),A                    ; $46BC  [EA 6C C9]  ; wEventActive = 1
    LD A,$00                        ; $46BF  [3E 00]
    LD ($C96D),A                    ; $46C1  [EA 6D C9]  ; wNextAreaID = 0
    LD A,$80                        ; $46C4  [3E 80]
    LD ($C96E),A                    ; $46C6  [EA 6E C9]  ; wNextAreaSub = $80 (sub-area exit flag)
    CALL Bank11_Sub_46DA            ; $46C9  [CD DA 46]  ; finalize sub-area state
    LD HL,$C8EB                     ; $46CC  [21 EB C8]
    SET 5,(HL)                      ; $46CF  [CB EE]  ; wStateFlags |= bit5
    XOR A                           ; $46D1  [AF]
    LD ($C905),A                    ; $46D2  [EA 05 C9]  ; wScrollPhase = 0
Bank11_RouteBank22:
    LD HL,$1608                     ; $46D5  [21 08 16]
    RST $10                         ; $46D8  [D7]  ; → bank22/fn8
    RET                             ; $46D9  [C9]

; ------------------------------------------------------------
; Bank11_Sub_46DA  ($46DA)   Sub-area monster count check
; ------------------------------------------------------------
; Counts active monsters in sub-area. Writes result to wMonSlotCount
; ($C92D): 5 if all 16 slots occupied, 6 if exactly 2 occupied.
; Called before sub-area exit to update the party-slot state.
; ------------------------------------------------------------
Bank11_Sub_46DA:
    LD A,($C969)                    ; $46DA  [FA 69 C9]  ; wAreaSub
    OR A                            ; $46DD  [B7]
    RET Z                           ; $46DE  [C8]  ; not in sub-area → nothing to do
    LD HL,$C940                     ; $46DF  [21 40 C9]  ; monster slot presence table
    LD DE,$C950                     ; $46E2  [11 50 C9]  ; monster slot active flags
    LD B,$10                        ; $46E5  [06 10]  ; 16 slots
    LD C,$00                        ; $46E7  [0E 00]  ; C = active count
Bank11_Sub46DA_Loop:
    LD A,(HL)                       ; $46E9  [7E]
    AND $F0                         ; $46EA  [E6 F0]
    CP $F0                          ; $46EC  [FE F0]
    JR Z,Bank11_Sub46DA_Skip        ; $46EE  [28 04]  ; slot marker $Fx = empty
    LD A,(DE)                       ; $46F0  [1A]
    OR A                            ; $46F1  [B7]
    RET Z                           ; $46F2  [C8]  ; slot not active → return (0 active)
    INC C                           ; $46F3  [0C]  ; count active slot
Bank11_Sub46DA_Skip:
    INC HL                          ; $46F4  [23]
    INC DE                          ; $46F5  [13]
    DEC B                           ; $46F6  [05]
    JR NZ,Bank11_Sub46DA_Loop       ; $46F7  [20 F0]
    LD A,C                          ; $46F9  [79]  ; total active count
    CP $10                          ; $46FA  [FE 10]  ; = 16 (all slots)
    JR Z,Bank11_Sub46DA_Full        ; $46FC  [28 05]
    CP $02                          ; $46FE  [FE 02]  ; = 2
    JR Z,Bank11_Sub46DA_Two         ; $4700  [28 07]
    RET                             ; $4702  [C9]
Bank11_Sub46DA_Full:
    LD A,$05                        ; $4703  [3E 05]
    LD ($C92D),A                    ; $4705  [EA 2D C9]  ; wMonSlotCount = 5
    RET                             ; $4708  [C9]
Bank11_Sub46DA_Two:
    LD A,$06                        ; $4709  [3E 06]
    LD ($C92D),A                    ; $470B  [EA 2D C9]  ; wMonSlotCount = 6
    RET                             ; $470E  [C9]

; ------------------------------------------------------------
; Bank11_Fn7  ($470F) — (RE)BUILD the room's NPC/object table at $D7D2
; ------------------------------------------------------------
; WHAT IT DOES: repopulates the live object table $D7D2 (the expanded 32-byte
; records that Fn4/collision/rendering read) for the room you are entering.
; Called by bank1 State1_EngineSetup (HL=$0B07) right after Fn2 paints the room,
; so the NPCs match the freshly-drawn map.
;
; FLOW:
;   * $C8EA bit7 set  -> objects owned by another handler this frame: just call
;     bank6/fn4 (HL=$0604) and return, leaving $D7D2 alone.
;   * otherwise -> wipe $D7D2 (ROM0 memfill $169A), clear the 6 door slots
;     (Sub_482B), stamp $D7D2[0]=$FF (empty terminator), then resolve THIS room's
;     compact object list with Sub_4274 ($C925 -> HL) and expand it via Sub_477E:
;       - MAIN AREA ($C969==0), or SUB-AREA with no connected neighbour
;         ($C926==$FF): tail-JR into Sub_477E ($477E) -> expand the current
;         room's list into $D7D2 and return.
;       - SUB-AREA with a connected neighbour: temporarily swap $C925<->$C926 so
;         the Sub_477E pass runs with the room index = the neighbour (Sub_477E
;         reads $C925 at $479F for the objects' world-base coords), swap back,
;         then copy the neighbour's link/warp refs $C927/8 -> $D7EA/B and
;         $C929/A -> $D7EC/D. This is the "connected-map" path for the gate
;         worlds, so objects/links line up across a seamless room boundary.
;
; NOTE: $477E (Sub_477E) is a SEPARATE routine reached by the JR/CALL above; Fn7
; itself ends at the RET at $477D (it does NOT fall through).
; Related: Sub_4274 (list resolver $4274) · Sub_477E (list->records $477E) ·
; Sub_482B (door-slot clear) · Fn4 (which object the player faces).
; ------------------------------------------------------------
Bank11_Fn7:                                 ; $470F
    LD A,($C8EA)               ; $470F  [FA EA C8]  ; A = $C8EA init/guard flags
    BIT 7,A                    ; $4712  [CB 7F]  ; bit7 = 'objects already handled elsewhere'
    JR Z,$471B                 ; $4714  [28 05]  ; clear -> (re)build the table below
    LD HL,$0604                ; $4716  [21 04 06]  ; else: HL=$0604 ...
    RST $10                    ; $4719  [D7]  ; -> bank6/fn4 (alternate object setup)
    RET                        ; $471A  [C9]  ; and return (table left to bank6)
    LD HL,$D7D2                ; $471B  [21 D2 D7]  ; --- clear the object table $D7D2 ---
    LD BC,$0101                ; $471E  [01 01 01]  ; BC = memfill params
    LD A,$00                   ; $4721  [3E 00]  ; fill value = $00
    CALL $169A                 ; $4723  [CD 9A 16]  ; ROM0 $169A memfill: zero the $D7D2 record area
    CALL $482B                 ; $4726  [CD 2B 48]  ; Sub_482B: clear the 6 door slots ($D7BE, $FF/$00 x6)
    LD A,$FF                   ; $4729  [3E FF]  ; A = $FF
    LD ($D7D2),A               ; $472B  [EA D2 D7]  ; $D7D2[0] = $FF = empty-list terminator (if no objects get written)
    CALL $4274                 ; $472E  [CD 74 42]  ; Sub_4274: resolve THIS room's ($C925) compact object list -> HL
    LD A,($C969)               ; $4731  [FA 69 C9]  ; A = $C969 wSubAreaFlag
    OR A                       ; $4734  [B7]  ; main area?
    JR Z,$477E                 ; $4735  [28 47]  ; MAIN AREA -> tail-call Sub_477E: expand current room's list -> $D7D2, return
    LD A,($C926)               ; $4737  [FA 26 C9]  ; A = $C926 adjacent/neighbour room index
    CP $FF                     ; $473A  [FE FF]  ; $FF = no connected neighbour
    JR Z,$477E                 ; $473C  [28 40]  ; NO NEIGHBOUR -> tail-call Sub_477E (expand current room only), return
    LD A,($C925)               ; $473E  [FA 25 C9]  ; --- sub-area WITH a connected neighbour: run the expand with room = neighbour ---
    LD B,A                     ; $4741  [47]  ; B = current room
    LD A,($C926)               ; $4742  [FA 26 C9]  ; A = neighbour room
    LD ($C925),A               ; $4745  [EA 25 C9]  ; $C925 = neighbour
    LD A,B                     ; $4748  [78]
    LD ($C926),A               ; $4749  [EA 26 C9]  ; $C926 = old current  (swap $C925<->$C926)
    CALL $477E                 ; $474C  [CD 7E 47]  ; Sub_477E: expand -> $D7D2 with $C925 now = neighbour (Sub_477E reads $C925 for world-base coords)
    LD A,($C925)               ; $474F  [FA 25 C9]  ; --- swap $C925<->$C926 back ---
    LD B,A                     ; $4752  [47]
    LD A,($C926)               ; $4753  [FA 26 C9]
    LD ($C925),A               ; $4756  [EA 25 C9]  ; restore $C925 = current room
    LD A,B                     ; $4759  [78]
    LD ($C926),A               ; $475A  [EA 26 C9]  ; restore $C926 = neighbour
    LD A,($C927)               ; $475D  [FA 27 C9]  ; --- record the neighbour's link/warp refs into the table ---
    LD L,A                     ; $4760  [6F]
    LD A,($C928)               ; $4761  [FA 28 C9]
    LD H,A                     ; $4764  [67]  ; HL = $C927:$C928
    LD A,L                     ; $4765  [7D]
    LD ($D7EA),A               ; $4766  [EA EA D7]  ; $D7EA = $C927 (neighbour link, lo)
    LD A,H                     ; $4769  [7C]
    LD ($D7EB),A               ; $476A  [EA EB D7]  ; $D7EB = $C928 (neighbour link, hi)
    LD A,($C929)               ; $476D  [FA 29 C9]
    LD L,A                     ; $4770  [6F]
    LD A,($C92A)               ; $4771  [FA 2A C9]
    LD H,A                     ; $4774  [67]  ; HL = $C929:$C92A
    LD A,L                     ; $4775  [7D]
    LD ($D7EC),A               ; $4776  [EA EC D7]  ; $D7EC = $C929 (neighbour link 2, lo)
    LD A,H                     ; $4779  [7C]
    LD ($D7ED),A               ; $477A  [EA ED D7]  ; $D7ED = $C92A (neighbour link 2, hi)
    RET                        ; $477D  [C9]  ; return (Sub_477E at $477E is a SEPARATE routine, reached by the JR/CALL above)

; ------------------------------------------------------------
; Bank11_Sub_477E  ($477E) — expand compact source list (HL) -> $D7D2 records
; ------------------------------------------------------------
; HL = compact source list (from Sub_4274). Walks 5-byte source records; byte0
; $FF ends; byte0 bit7 = HEADER (skip 5 bytes, emit nothing). Each NORMAL record
; expands to a 32-byte WRAM object record at DE (starting $D7D2, DE += $20 each).
;
; COMPACT SOURCE record (5 bytes): [0]=type/facing  [1]=sprite  [2]=+x  [3]=+y
;   [4]=event/message id.  (+x,+y are zone-relative metatile offsets.)
;
; EXPANDED $D7D2 record (32 bytes) — fields this routine writes (rest = 0):
;   +$00 type/facing (src[0])          +$11 sprite id (copy of +$01)
;   +$01 sprite id (src[1])            +$16 sprite CLASS (Sub_4839 of sprite id)
;   +$02 tile X = base_X + src[2]      +$18/$19 pixel X = tileX*16 + 8 (16-bit)
;   +$03 tile Y = base_Y + src[3]      +$1A/$1B pixel Y = tileY*16 + 8 (16-bit)
;   +$04 event/message id (src[4])
;   +$06 facing dir = (type>>4)&3
;   base_X/base_Y = zone origin from ROM0 $31B6[wScrollCount $C925 *2].
; These are the fields the scanners read: Sub_433F +$04 (event id); Sub_43E5
; +$05 bit0 (active) and +$18..+$1B (pixel box); rendering uses +$01/+$18/+$1A.
; $FFD5:$FFD6 hold the current dest record base during the per-record copy.
; ------------------------------------------------------------
Bank11_Sub_477E:
    LD DE,$D7D2                     ; $477E  [11 D2 D7]  ; dest = object table base
    LD A,E                          ; $4781  [7B]        ; --- per-record: save dest in $D5/$D6 ---
    LDH ($D5),A                     ; $4782  [E0 D5]
    LD A,D                          ; $4784  [7A]
    LDH ($D6),A                     ; $4785  [E0 D6]
    LD A,(HL+)                      ; $4787  [2A]        ; src[0] = type/facing
    LD (DE),A                       ; $4788  [12]        ; WRAM+$00 = type
    CP $FF                          ; $4789  [FE FF]
    RET Z                           ; $478B  [C8]        ; $FF = end of list
    BIT 7,A                         ; $478C  [CB 7F]
    JR Z,$479A                      ; $478E  [28 0A]     ; bit7 clear → normal object
    LD A,L                          ; $4790  [7D]        ; --- header record: skip 5 bytes ---
    ADD A,$04                       ; $4791  [C6 04]
    LD L,A                          ; $4793  [6F]
    LD A,H                          ; $4794  [7C]
    ADC A,$00                       ; $4795  [CE 00]
    LD H,A                          ; $4797  [67]
    JR $4781                        ; $4798  [18 E7]     ; (dest NOT advanced)
    LDH ($D7),A                     ; $479A  [E0 D7]     ; save type
    LD BC,$31B6                     ; $479C  [01 B6 31]  ; ROM0 zone-origin table
    LD A,($C925)                    ; $479F  [FA 25 C9]  ; wScrollCount
    ADD A,A                         ; $47A2  [87]
    ADD A,C                         ; $47A3  [81]
    LD C,A                          ; $47A4  [4F]
    LD A,$00                        ; $47A5  [3E 00]
    ADC A,B                         ; $47A7  [88]
    LD B,A                          ; $47A8  [47]        ; BC = $31B6 + wScrollCount*2
    PUSH DE                         ; $47A9  [D5]        ; save record base
    INC DE                          ; $47AA  [13]
    LD A,(HL+)                      ; $47AB  [2A]        ; src[1] = sprite id
    LD (DE),A                       ; $47AC  [12]        ; WRAM+$01
    INC DE                          ; $47AD  [13]
    LD A,(BC)                       ; $47AE  [0A]        ; base_X
    ADD A,(HL)                      ; $47AF  [86]        ; + src[2]
    LD (DE),A                       ; $47B0  [12]        ; WRAM+$02 = tile X
    INC HL                          ; $47B1  [23]
    INC DE                          ; $47B2  [13]
    INC BC                          ; $47B3  [03]
    LD A,(BC)                       ; $47B4  [0A]        ; base_Y
    ADD A,(HL)                      ; $47B5  [86]        ; + src[3]
    LD (DE),A                       ; $47B6  [12]        ; WRAM+$03 = tile Y
    INC HL                          ; $47B7  [23]
    INC DE                          ; $47B8  [13]
    LD A,(HL+)                      ; $47B9  [2A]        ; src[4] = event id
    LD (DE),A                       ; $47BA  [12]        ; WRAM+$04
    INC DE                          ; $47BB  [13]
    INC DE                          ; $47BC  [13]
    LDH A,($D7)                     ; $47BD  [F0 D7]     ; type
    SWAP A                          ; $47BF  [CB 37]
    AND $03                         ; $47C1  [E6 03]     ; (type>>4)&3
    LD (DE),A                       ; $47C3  [12]        ; WRAM+$06
    PUSH HL                         ; $47C4  [E5]        ; save src ptr (+5 = next record)
    LDH A,($D5)                     ; $47C5  [F0 D5]     ; --- WRAM+$11 = copy of sprite id ---
    LD E,A                          ; $47C7  [5F]
    LDH A,($D6)                     ; $47C8  [F0 D6]
    LD D,A                          ; $47CA  [57]
    LD A,E                          ; $47CB  [7B]
    ADD A,$11                       ; $47CC  [C6 11]
    LD E,A                          ; $47CE  [5F]
    LD A,D                          ; $47CF  [7A]
    ADC A,$00                       ; $47D0  [CE 00]
    LD D,A                          ; $47D2  [57]
    LDH A,($D5)                     ; $47D3  [F0 D5]
    LD L,A                          ; $47D5  [6F]
    LDH A,($D6)                     ; $47D6  [F0 D6]
    LD H,A                          ; $47D8  [67]        ; HL = record base
    INC HL                          ; $47D9  [23]
    LD A,(HL+)                      ; $47DA  [2A]        ; A = WRAM+$01 (sprite id); HL=base+2
    LD (DE),A                       ; $47DB  [12]        ; WRAM+$11 = sprite id
    PUSH HL                         ; $47DC  [E5]        ; save base+2 (points at tile X)
    CALL $4839                      ; $47DD  [CD 39 48]  ; Sub_4839: map sprite id → class
    POP HL                          ; $47E0  [E1]        ; HL = base+2
    PUSH AF                         ; $47E1  [F5]
    LDH A,($D5)                     ; $47E2  [F0 D5]     ; --- WRAM+$16 = Sub_4839 result ---
    LD E,A                          ; $47E4  [5F]
    LDH A,($D6)                     ; $47E5  [F0 D6]
    LD D,A                          ; $47E7  [57]
    LD A,E                          ; $47E8  [7B]
    ADD A,$16                       ; $47E9  [C6 16]
    LD E,A                          ; $47EB  [5F]
    LD A,D                          ; $47EC  [7A]
    ADC A,$00                       ; $47ED  [CE 00]
    LD D,A                          ; $47EF  [57]
    POP AF                          ; $47F0  [F1]
    LD (DE),A                       ; $47F1  [12]        ; WRAM+$16
    LDH A,($D5)                     ; $47F2  [F0 D5]     ; --- WRAM+$18/$19 = pixel X from tileX ---
    LD E,A                          ; $47F4  [5F]
    LDH A,($D6)                     ; $47F5  [F0 D6]
    LD D,A                          ; $47F7  [57]
    LD A,E                          ; $47F8  [7B]
    ADD A,$18                       ; $47F9  [C6 18]
    LD E,A                          ; $47FB  [5F]
    LD A,D                          ; $47FC  [7A]
    ADC A,$00                       ; $47FD  [CE 00]
    LD D,A                          ; $47FF  [57]
    LD A,(HL+)                      ; $4800  [2A]        ; tile X (WRAM+$02); HL→+3
    SWAP A                          ; $4801  [CB 37]
    LD C,A                          ; $4803  [4F]
    AND $F0                         ; $4804  [E6 F0]
    OR $08                          ; $4806  [F6 08]     ; +8 = tile center
    LD (DE),A                       ; $4808  [12]        ; WRAM+$18 (pixel X lo)
    INC DE                          ; $4809  [13]
    LD A,C                          ; $480A  [79]
    AND $0F                         ; $480B  [E6 0F]
    LD (DE),A                       ; $480D  [12]        ; WRAM+$19 (pixel X hi)
    INC DE                          ; $480E  [13]
    LD A,(HL)                       ; $480F  [7E]        ; tile Y (WRAM+$03)
    SWAP A                          ; $4810  [CB 37]
    LD C,A                          ; $4812  [4F]
    AND $F0                         ; $4813  [E6 F0]
    OR $08                          ; $4815  [F6 08]
    LD (DE),A                       ; $4817  [12]        ; WRAM+$1A (pixel Y lo)
    INC DE                          ; $4818  [13]
    LD A,C                          ; $4819  [79]
    AND $0F                         ; $481A  [E6 0F]
    LD (DE),A                       ; $481C  [12]        ; WRAM+$1B (pixel Y hi)
    INC DE                          ; $481D  [13]
    POP HL                          ; $481E  [E1]        ; HL = next source record (+5)
    POP DE                          ; $481F  [D1]        ; DE = record base
    LD A,E                          ; $4820  [7B]
    ADD A,$20                       ; $4821  [C6 20]     ; DE += $20 (next 32-byte WRAM record)
    LD E,A                          ; $4823  [5F]
    LD A,D                          ; $4824  [7A]
    ADC A,$00                       ; $4825  [CE 00]
    LD D,A                          ; $4827  [57]
    JP $4781                        ; $4828  [C3 81 47]  ; next record

; Bank11_Sub_482B ($482B): clear 6 door-slots at $D7BE ($FF,$00 x6). Sub_4839
; ($4839): map sprite id → sprite class ($E0/$E1/$E2/$E3 → $00/$20/$30/$40;
; $F0+ → indexed via $D7CA; else pass-through). Called during the expansion.

; ============================================================================
; Bank11_AreaDir  ($4B43)  — per-area DIRECTORY (104 entries), indexed by wAreaID
; ($C968). Each entry -> that area's descriptor. Two uses of the same chain:
;   (1) Fn9 chain: $4B43[area] -> scroll_count_table[wScrollCount $C925] -> zone
;       entry -> DE=WRAM zone_type ($D92A) -> event_list_ptr.
;   (2) Fn8 ($4239): same walk -> {bank,block} of the compressed TILE-NUMBER map,
;       decompressed to $C300 ($4127) / $C500 (Fn3). ($C300 = 8-bit tile-number
;       /visual map painted to $9800; $C200 = 4-bit CGB attribute map — see the
;       pipeline doc up top. NOT a "collision" map.) The exact {bank,block} is
;       RUNTIME-resolved via a variant selector in WRAM ($D95F..), not a static
;       flat table. World = 4x4 zones of 10x8; wScrollCount = row*4+col.
; Each area descriptor is a bytecode chain of: tile-load records + a WARP/DOOR
; table (walked by Fn6/$4579: matches player X/Y from $FF97/$FF98, teleports).
; Many areas alias $4C13 (shared/default, 9 slots). 91 distinct blocks of 104
; ($4C13-$7CE7). MEASURED: table spans $4B43-$4C12 (208 B = 104 entries); the
; first descriptor $4C13 immediately follows. (Earlier "64 entries" was wrong —
; it only counted areas $00-$3F; areas $40-$67 are real, below.)
;
; INTERIOR TILESET = bank48 ($30) (walls/floors/furniture; holds BOTH graphics
; blocks 0,1,2.. AND 32x16 tile-number map blocks $10,$11,$12..). Areas whose
; descriptor loads bank48 (their bank48 tile-number blocks in []):
;   a18[$08,$09] a19[$0B] a22[$0D,$0E] a23[$05,$06] a24[$10,$11,$12] a25[$14]
;   a26[$16] a27[$18]+bank$2E,$39 a28[$1A] a29[$1C] a30[$1E].
;   area 24 loads the most (3 blocks) = likely the MAIN CASTLE.
; To NAME the castle for certain: cross-ref these areas' event cells -> message
; ids -> text (throne/king lines). Byte-exact table below.
; ============================================================================
SECTION "Bank 11 Area Directory", ROMX[$4B43], BANK[11]
Bank11_AreaDir:                            ; $4B43  (104 areas, $00-$67)
    dw $4C13,$4E23,$505D,$52F2,$55AE,$583A,$599E,$5A2B   ; areas $00-$07
    dw $5C86,$5D45,$5E6A,$4C13,$5E94,$5EC0,$4C13,$5F4A   ; areas $08-$0F
    dw $5F71,$4C13,$5FE0,$6082,$4C13,$4C13,$613E,$5F71   ; areas $10-$17
    dw $61FD,$62C0,$62E7,$6318,$6363,$63CA,$63FB,$643D   ; areas $18-$1F
    dw $4C13,$4C13,$4C13,$64A9,$64E0,$653E,$659C,$65FA   ; areas $20-$27
    dw $665D,$66BB,$6719,$6777,$67AE,$680C,$686A,$68CF   ; areas $28-$2F
    dw $6AB4,$6AD9,$6B17,$6B46,$6B6B,$6BC7,$6C00,$6C89   ; areas $30-$37
    dw $6D1C,$6DFF,$6E38,$6F43,$6F68,$6FE8,$7028,$7057   ; areas $38-$3F
    dw $707C,$70E9,$7147,$74E0,$7523,$7566,$75CE,$75FD   ; areas $40-$47
    dw $7648,$7677,$76A6,$76D5,$7704,$7733,$7762,$77AE   ; areas $48-$4F
    dw $77E2,$77FF,$781C,$7850,$790D,$797D,$79ED,$7A5D   ; areas $50-$57
    dw $7ACD,$7B3D,$7BAD,$7BDE,$7C0F,$7C4A,$7CE7,$77E2   ; areas $58-$5F
    dw $7149,$7852,$7854,$7856,$7858,$7149,$7149,$7149   ; areas $60-$67


; ============================================================================
; Bank11_Area0  ($4C13)  — AREA 0 descriptor (AreaDir[0]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($4C13-$4C94, 130 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 0 Descriptor", ROMX[$4C13], BANK[11]
Bank11_Area0:                              ; $4C13
    dw $4C23,$4C3D,$FFFF,$FFFF   ; rooms 0-3
    dw $FFFF,$4C75,$FFFF,$FFFF   ; rooms 4-7
Bank11_Area0_Room0:                       ; $4C23
    dw $D92A                            ; variant selector
    db $01,$2A,$95,$4C,$FC,$4D  ; v0: bank$2A blk$01 obj=$4C95 oth=$4DFC
    db $02,$2A,$95,$4C,$FC,$4D  ; v1: bank$2A blk$02 obj=$4C95 oth=$4DFC
    db $03,$2A,$95,$4C,$FC,$4D  ; v2: bank$2A blk$03 obj=$4C95 oth=$4DFC
    db $04,$2A,$95,$4C,$FC,$4D  ; v3: bank$2A blk$04 obj=$4C95 oth=$4DFC
Bank11_Area0_Room1:                       ; $4C3D
    dw $D92B                            ; variant selector
    db $05,$2A,$CD,$4C,$FE,$4D  ; v0: bank$2A blk$05 obj=$4CCD oth=$4DFE
    db $06,$2A,$EC,$4C,$FE,$4D  ; v1: bank$2A blk$06 obj=$4CEC oth=$4DFE
    db $06,$2A,$01,$4D,$FE,$4D  ; v2: bank$2A blk$06 obj=$4D01 oth=$4DFE
    db $06,$2A,$1B,$4D,$FE,$4D  ; v3: bank$2A blk$06 obj=$4D1B oth=$4DFE
    db $06,$2A,$2B,$4D,$FE,$4D  ; v4: bank$2A blk$06 obj=$4D2B oth=$4DFE
    db $06,$2A,$54,$4D,$FE,$4D  ; v5: bank$2A blk$06 obj=$4D54 oth=$4DFE
    db $06,$2A,$88,$4D,$FE,$4D  ; v6: bank$2A blk$06 obj=$4D88 oth=$4DFE
    db $05,$2A,$64,$4D,$FD,$4D  ; v7: bank$2A blk$05 obj=$4D64 oth=$4DFD
    db $06,$2A,$88,$4D,$FE,$4D  ; v8: bank$2A blk$06 obj=$4D88 oth=$4DFE
Bank11_Area0_Room5:                       ; $4C75
    dw $D92C                            ; variant selector
    db $07,$2A,$A2,$4D,$06,$4E  ; v0: bank$2A blk$07 obj=$4DA2 oth=$4E06
    db $07,$2A,$BC,$4D,$06,$4E  ; v1: bank$2A blk$07 obj=$4DBC oth=$4E06
    db $07,$2A,$CC,$4D,$06,$4E  ; v2: bank$2A blk$07 obj=$4DCC oth=$4E06
    db $07,$2A,$DC,$4D,$06,$4E  ; v3: bank$2A blk$07 obj=$4DDC oth=$4E06
    db $07,$2A,$EC,$4D,$06,$4E  ; v4: bank$2A blk$07 obj=$4DEC oth=$4E06

; ============================================================================
; Bank11_Area0_ObjLists  ($4C95)  — object/NPC source lists for AREA 0's rooms
; ============================================================================
; The compact 5-byte records [type/facing, sprite, +x, +y, event] that AREA 0's
; descriptor variant records point at (Sub_4274 -> here). Expanded to $D7D2 by
; Sub_477E on map entry (adds zone base $31B6 to x,y). $FF byte0 = end of list;
; bit7-set byte0 = header record (no drawn NPC). Placed in address order right
; after Bank11_Area0 ($4C13-$4C94), before Bank11_Area1 ($4E23). Byte-exact.
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 0 Object Lists", ROMX[$4C95], BANK[11]
Bank11_Area0_Obj_4C95:              ; $4C95  (room 0 objlist)
    db $8F,$FF,$01,$01,$01   ; $4C95 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $4C9A HEADER(bit7)
    db $8F,$FF,$03,$02,$03   ; $4C9F HEADER(bit7)
    db $8F,$FF,$04,$02,$04   ; $4CA4 HEADER(bit7)
    db $8F,$FF,$02,$07,$05   ; $4CA9 HEADER(bit7)
    db $8F,$FF,$03,$07,$06   ; $4CAE HEADER(bit7)
    db $8F,$FF,$04,$07,$07   ; $4CB3 HEADER(bit7)
    db $8F,$FF,$05,$07,$08   ; $4CB8 HEADER(bit7)
    db $8F,$FF,$06,$07,$13   ; $4CBD HEADER(bit7)
    db $01,$10,$05,$02,$09   ; $4CC2 type1 face0 spr$10 (+5,+2) ev$09
    db $00,$10,$07,$04,$0A   ; $4CC7 type0 face0 spr$10 (+7,+4) ev$0A
    db $FF                          ; $4CCC end
Bank11_Area0_Obj_4CCD:              ; $4CCD  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4CCD type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4CD2 type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4CD7 type0 face3 spr$11 (+3,+5) ev$0E
    db $60,$00,$06,$08,$0F   ; $4CDC type0 face6 spr$00 (+6,+8) ev$0F
    db $00,$0D,$04,$03,$0B   ; $4CE1 type0 face0 spr$0D (+4,+3) ev$0B
    db $60,$37,$05,$08,$FF   ; $4CE6 type0 face6 spr$37 (+5,+8) ev$FF
    db $FF                          ; $4CEB end
Bank11_Area0_Obj_4CEC:              ; $4CEC  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4CEC type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4CF1 type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4CF6 type0 face3 spr$11 (+3,+5) ev$0E
    db $20,$00,$06,$06,$0F   ; $4CFB type0 face2 spr$00 (+6,+6) ev$0F
    db $FF                          ; $4D00 end
Bank11_Area0_Obj_4D01:              ; $4D01  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D01 type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4D06 type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4D0B type0 face3 spr$11 (+3,+5) ev$0E
    db $20,$00,$06,$06,$0F   ; $4D10 type0 face2 spr$00 (+6,+6) ev$0F
    db $00,$0D,$04,$03,$0B   ; $4D15 type0 face0 spr$0D (+4,+3) ev$0B
    db $FF                          ; $4D1A end
Bank11_Area0_Obj_4D1B:              ; $4D1B  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D1B type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4D20 type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4D25 type0 face3 spr$11 (+3,+5) ev$0E
    db $FF                          ; $4D2A end
Bank11_Area0_Obj_4D2B:              ; $4D2B  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D2B type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4D30 type0 face0 spr$10 (+7,+2) ev$0D
    db $20,$11,$04,$06,$0E   ; $4D35 type0 face2 spr$11 (+4,+6) ev$0E
    db $60,$00,$06,$06,$FF   ; $4D3A type0 face6 spr$00 (+6,+6) ev$FF
    db $00,$0D,$04,$03,$0B   ; $4D3F type0 face0 spr$0D (+4,+3) ev$0B
    db $60,$00,$06,$06,$FF   ; $4D44 type0 face6 spr$00 (+6,+6) ev$FF
    db $40,$E0,$04,$05,$FF   ; $4D49 type0 face4 spr$E0 (+4,+5) ev$FF
    db $40,$52,$04,$06,$FF   ; $4D4E type0 face4 spr$52 (+4,+6) ev$FF
    db $FF                          ; $4D53 end
Bank11_Area0_Obj_4D54:              ; $4D54  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D54 type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$08,$02,$0D   ; $4D59 type0 face0 spr$10 (+8,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4D5E type0 face3 spr$11 (+3,+5) ev$0E
    db $FF                          ; $4D63 end
Bank11_Area0_Obj_4D64:              ; $4D64  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D64 type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4D69 type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4D6E type0 face3 spr$11 (+3,+5) ev$0E
    db $60,$00,$06,$06,$FF   ; $4D73 type0 face6 spr$00 (+6,+6) ev$FF
    db $00,$0D,$04,$03,$FF   ; $4D78 type0 face0 spr$0D (+4,+3) ev$FF
    db $60,$38,$05,$08,$FF   ; $4D7D type0 face6 spr$38 (+5,+8) ev$FF
    db $40,$10,$08,$02,$0D   ; $4D82 type0 face4 spr$10 (+8,+2) ev$0D
    db $FF                          ; $4D87 end
Bank11_Area0_Obj_4D88:              ; $4D88  (room 1 objlist)
    db $00,$10,$02,$02,$0C   ; $4D88 type0 face0 spr$10 (+2,+2) ev$0C
    db $00,$10,$07,$02,$0D   ; $4D8D type0 face0 spr$10 (+7,+2) ev$0D
    db $30,$11,$03,$05,$0E   ; $4D92 type0 face3 spr$11 (+3,+5) ev$0E
    db $60,$00,$06,$06,$0F   ; $4D97 type0 face6 spr$00 (+6,+6) ev$0F
    db $40,$10,$08,$02,$0D   ; $4D9C type0 face4 spr$10 (+8,+2) ev$0D
    db $FF                          ; $4DA1 end
Bank11_Area0_Obj_4DA2:              ; $4DA2  (room 5 objlist)
    db $30,$0B,$02,$05,$10   ; $4DA2 type0 face3 spr$0B (+2,+5) ev$10
    db $10,$0B,$07,$05,$11   ; $4DA7 type0 face1 spr$0B (+7,+5) ev$11
    db $10,$0B,$06,$03,$12   ; $4DAC type0 face1 spr$0B (+6,+3) ev$12
    db $00,$11,$04,$04,$FF   ; $4DB1 type0 face0 spr$11 (+4,+4) ev$FF
    db $60,$E0,$04,$07,$FF   ; $4DB6 type0 face6 spr$E0 (+4,+7) ev$FF
    db $FF                          ; $4DBB end
Bank11_Area0_Obj_4DBC:              ; $4DBC  (room 5 objlist)
    db $30,$0B,$02,$05,$10   ; $4DBC type0 face3 spr$0B (+2,+5) ev$10
    db $10,$0B,$07,$05,$11   ; $4DC1 type0 face1 spr$0B (+7,+5) ev$11
    db $10,$0B,$06,$03,$12   ; $4DC6 type0 face1 spr$0B (+6,+3) ev$12
    db $FF                          ; $4DCB end
Bank11_Area0_Obj_4DCC:              ; $4DCC  (room 5 objlist)
    db $30,$0B,$02,$05,$10   ; $4DCC type0 face3 spr$0B (+2,+5) ev$10
    db $10,$0B,$08,$05,$11   ; $4DD1 type0 face1 spr$0B (+8,+5) ev$11
    db $10,$0B,$06,$03,$12   ; $4DD6 type0 face1 spr$0B (+6,+3) ev$12
    db $FF                          ; $4DDB end
Bank11_Area0_Obj_4DDC:              ; $4DDC  (room 5 objlist)
    db $30,$0B,$01,$04,$10   ; $4DDC type0 face3 spr$0B (+1,+4) ev$10
    db $10,$0B,$07,$05,$11   ; $4DE1 type0 face1 spr$0B (+7,+5) ev$11
    db $10,$0B,$06,$03,$12   ; $4DE6 type0 face1 spr$0B (+6,+3) ev$12
    db $FF                          ; $4DEB end
Bank11_Area0_Obj_4DEC:              ; $4DEC  (room 5 objlist)
    db $30,$0B,$01,$04,$10   ; $4DEC type0 face3 spr$0B (+1,+4) ev$10
    db $10,$0B,$08,$05,$11   ; $4DF1 type0 face1 spr$0B (+8,+5) ev$11
    db $10,$0B,$06,$03,$12   ; $4DF6 type0 face1 spr$0B (+6,+3) ev$12
    db $FF                          ; $4DFB end
    db $FF,$FF,$07,$01,$0A,$00,$00,$07   ; $4DFC
    db $07,$FF,$02,$05,$03,$00,$01,$02   ; $4E04
    db $05,$07,$05,$04,$00,$05,$07,$05   ; $4E0C
    db $04,$07,$01,$00,$80,$04,$04,$05   ; $4E14
    db $07,$01,$00,$80,$05,$04,$FF   ; $4E1C


; ----------------------------------------------------------------------------
; EXAMPLE object lists (compact ROM source, decoded). These live in bank11 ROM,
; reached via the room's descriptor (Sub_4274). Format per record:
;   type/facing, sprite id, +x, +y, event id     ($FF byte0 = end)
; ----------------------------------------------------------------------------
; area 0, room 1  @ $4CCD  (6 objects) — starting-town NPCs:
;   db $00,$10,$02,$02,$0C    ; NPC sprite$10 at (+2,+2)  event $0C
;   db $00,$10,$07,$02,$0D    ; NPC sprite$10 at (+7,+2)  event $0D
;   db $30,$11,$03,$05,$0E    ; face3 sprite$11 at (+3,+5) event $0E
;   db $60,$00,$06,$08,$0F    ; face6 sprite$00 at (+6,+8) event $0F
;   db $00,$0D,$04,$03,$0B    ; NPC sprite$0D at (+4,+3)  event $0B
;   db $60,$37,$05,$08,$FF    ; face6 sprite$37 at (+5,+8) event $FF
;   db $FF                    ; end
; area 0, room 5  @ $4DA2  (5 objects):
;   db $30,$0B,$02,$05,$10  db $10,$0B,$07,$05,$11  db $10,$0B,$06,$03,$12
;   db $00,$11,$04,$04,$FF  db $60,$E0,$04,$07,$FF  db $FF   ; $E0 = special sprite class
; ----------------------------------------------------------------------------

; ============================================================================
; Bank11_Area1  ($4E23)  — AREA 1 descriptor (AreaDir[1]).
; 16-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($4E23-$4ED6, 180 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 1 Descriptor", ROMX[$4E23], BANK[11]
Bank11_Area1:                              ; $4E23
    dw $4E43,$4E63,$FFFF,$FFFF   ; rooms 0-3
    dw $4E6B,$4E85,$FFFF,$FFFF   ; rooms 4-7
    dw $4E8D,$4EA1,$FFFF,$FFFF   ; rooms 8-11
    dw $4EA9,$4EC3,$FFFF,$FFFF   ; rooms 12-15
Bank11_Area1_Room0:                       ; $4E43
    dw $D92D                            ; variant selector
    db $09,$2A,$D7,$4E,$BE,$4F  ; v0: bank$2A blk$09 obj=$4ED7 oth=$4FBE
    db $09,$2A,$E2,$4E,$BF,$4F  ; v1: bank$2A blk$09 obj=$4EE2 oth=$4FBF
    db $09,$2A,$ED,$4E,$BF,$4F  ; v2: bank$2A blk$09 obj=$4EED oth=$4FBF
    db $09,$2A,$F8,$4E,$BF,$4F  ; v3: bank$2A blk$09 obj=$4EF8 oth=$4FBF
    db $09,$2A,$FE,$4E,$BE,$4F  ; v4: bank$2A blk$09 obj=$4EFE oth=$4FBE
Bank11_Area1_Room1:                       ; $4E63
    dw $D92E                            ; variant selector
    db $0A,$2A,$09,$4F,$CE,$4F  ; v0: bank$2A blk$0A obj=$4F09 oth=$4FCE
Bank11_Area1_Room4:                       ; $4E6B
    dw $D92F                            ; variant selector
    db $0B,$2A,$0F,$4F,$D6,$4F  ; v0: bank$2A blk$0B obj=$4F0F oth=$4FD6
    db $0B,$2A,$1F,$4F,$D6,$4F  ; v1: bank$2A blk$0B obj=$4F1F oth=$4FD6
    db $0B,$2A,$34,$4F,$D6,$4F  ; v2: bank$2A blk$0B obj=$4F34 oth=$4FD6
    db $0B,$2A,$3F,$4F,$D6,$4F  ; v3: bank$2A blk$0B obj=$4F3F oth=$4FD6
Bank11_Area1_Room5:                       ; $4E85
    dw $D930                            ; variant selector
    db $0C,$2A,$4F,$4F,$E5,$4F  ; v0: bank$2A blk$0C obj=$4F4F oth=$4FE5
Bank11_Area1_Room8:                       ; $4E8D
    dw $D931                            ; variant selector
    db $0D,$2A,$5A,$4F,$E6,$4F  ; v0: bank$2A blk$0D obj=$4F5A oth=$4FE6
    db $0D,$2A,$6F,$4F,$E6,$4F  ; v1: bank$2A blk$0D obj=$4F6F oth=$4FE6
    db $0D,$2A,$84,$4F,$E6,$4F  ; v2: bank$2A blk$0D obj=$4F84 oth=$4FE6
Bank11_Area1_Room9:                       ; $4EA1
    dw $D932                            ; variant selector
    db $0E,$2A,$94,$4F,$F5,$4F  ; v0: bank$2A blk$0E obj=$4F94 oth=$4FF5
Bank11_Area1_Room12:                       ; $4EA9
    dw $D933                            ; variant selector
    db $0F,$2A,$9F,$4F,$04,$50  ; v0: bank$2A blk$0F obj=$4F9F oth=$5004
    db $0F,$2A,$A5,$4F,$04,$50  ; v1: bank$2A blk$0F obj=$4FA5 oth=$5004
    db $10,$2A,$B0,$4F,$1A,$50  ; v2: bank$2A blk$10 obj=$4FB0 oth=$501A
    db $10,$2A,$9F,$4F,$1A,$50  ; v3: bank$2A blk$10 obj=$4F9F oth=$501A
Bank11_Area1_Room13:                       ; $4EC3
    dw $D934                            ; variant selector
    db $11,$2A,$BB,$4F,$30,$50  ; v0: bank$2A blk$11 obj=$4FBB oth=$5030
    db $12,$2A,$BC,$4F,$38,$50  ; v1: bank$2A blk$12 obj=$4FBC oth=$5038
    db $13,$2A,$BD,$4F,$47,$50  ; v2: bank$2A blk$13 obj=$4FBD oth=$5047

; ============================================================================
; Bank11_Area2  ($505D)  — AREA 2 descriptor (AreaDir[2]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($505D-$5102, 166 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 2 Descriptor", ROMX[$505D], BANK[11]
Bank11_Area2:                              ; $505D
    dw $506D,$507B,$508F,$FFFF   ; rooms 0-3
    dw $50A3,$50B7,$50CB,$FFFF   ; rooms 4-7
Bank11_Area2_Room0:                       ; $506D
    dw $D935                            ; variant selector
    db $15,$2A,$03,$51,$C3,$52  ; v0: bank$2A blk$15 obj=$5103 oth=$52C3
    db $15,$2A,$1D,$51,$C3,$52  ; v1: bank$2A blk$15 obj=$511D oth=$52C3
Bank11_Area2_Room1:                       ; $507B
    dw $D936                            ; variant selector
    db $16,$2A,$3C,$51,$CB,$52  ; v0: bank$2A blk$16 obj=$513C oth=$52CB
    db $16,$2A,$4C,$51,$CB,$52  ; v1: bank$2A blk$16 obj=$514C oth=$52CB
    db $16,$2A,$61,$51,$CB,$52  ; v2: bank$2A blk$16 obj=$5161 oth=$52CB
Bank11_Area2_Room2:                       ; $508F
    dw $D937                            ; variant selector
    db $17,$2A,$76,$51,$CC,$52  ; v0: bank$2A blk$17 obj=$5176 oth=$52CC
    db $18,$2A,$7C,$51,$CD,$52  ; v1: bank$2A blk$18 obj=$517C oth=$52CD
    db $18,$2A,$8C,$51,$CD,$52  ; v2: bank$2A blk$18 obj=$518C oth=$52CD
Bank11_Area2_Room4:                       ; $50A3
    dw $D938                            ; variant selector
    db $19,$2A,$A1,$51,$CE,$52  ; v0: bank$2A blk$19 obj=$51A1 oth=$52CE
    db $1A,$2A,$AC,$51,$CF,$52  ; v1: bank$2A blk$1A obj=$51AC oth=$52CF
    db $19,$2A,$B7,$51,$CE,$52  ; v2: bank$2A blk$19 obj=$51B7 oth=$52CE
Bank11_Area2_Room5:                       ; $50B7
    dw $D939                            ; variant selector
    db $1B,$2A,$C2,$51,$D0,$52  ; v0: bank$2A blk$1B obj=$51C2 oth=$52D0
    db $1C,$2A,$C8,$51,$D1,$52  ; v1: bank$2A blk$1C obj=$51C8 oth=$52D1
    db $1C,$2A,$DD,$51,$D1,$52  ; v2: bank$2A blk$1C obj=$51DD oth=$52D1
Bank11_Area2_Room6:                       ; $50CB
    dw $D93A                            ; variant selector
    db $1D,$2A,$F7,$51,$D2,$52  ; v0: bank$2A blk$1D obj=$51F7 oth=$52D2
    db $1E,$2A,$11,$52,$D3,$52  ; v1: bank$2A blk$1E obj=$5211 oth=$52D3
    db $1E,$2A,$2B,$52,$D3,$52  ; v2: bank$2A blk$1E obj=$522B oth=$52D3
    db $1F,$2A,$40,$52,$DB,$52  ; v3: bank$2A blk$1F obj=$5240 oth=$52DB
    db $1F,$2A,$5A,$52,$DB,$52  ; v4: bank$2A blk$1F obj=$525A oth=$52DB
    db $20,$2A,$6F,$52,$E3,$52  ; v5: bank$2A blk$20 obj=$526F oth=$52E3
    db $20,$2A,$89,$52,$E3,$52  ; v6: bank$2A blk$20 obj=$5289 oth=$52E3
    db $20,$2A,$9E,$52,$E3,$52  ; v7: bank$2A blk$20 obj=$529E oth=$52E3
    db $20,$2A,$B3,$52,$E3,$52  ; v8: bank$2A blk$20 obj=$52B3 oth=$52E3

; ============================================================================
; Bank11_Area3  ($52F2)  — AREA 3 descriptor (AreaDir[3]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($52F2-$5369, 120 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 3 Descriptor", ROMX[$52F2], BANK[11]
Bank11_Area3:                              ; $52F2
    dw $5302,$531C,$FFFF,$FFFF   ; rooms 0-3
    dw $533C,$535C,$FFFF,$FFFF   ; rooms 4-7
Bank11_Area3_Room0:                       ; $5302
    dw $D93B                            ; variant selector
    db $22,$2A,$6A,$53,$88,$54  ; v0: bank$2A blk$22 obj=$536A oth=$5488
    db $23,$2A,$84,$53,$90,$54  ; v1: bank$2A blk$23 obj=$5384 oth=$5490
    db $24,$2A,$99,$53,$9F,$54  ; v2: bank$2A blk$24 obj=$5399 oth=$549F
    db $25,$2A,$A4,$53,$BC,$54  ; v3: bank$2A blk$25 obj=$53A4 oth=$54BC
Bank11_Area3_Room1:                       ; $531C
    dw $D93C                            ; variant selector
    db $26,$2A,$AA,$53,$E0,$54  ; v0: bank$2A blk$26 obj=$53AA oth=$54E0
    db $27,$2A,$CE,$53,$E8,$54  ; v1: bank$2A blk$27 obj=$53CE oth=$54E8
    db $27,$2A,$E8,$53,$E8,$54  ; v2: bank$2A blk$27 obj=$53E8 oth=$54E8
    db $28,$2A,$F8,$53,$FE,$54  ; v3: bank$2A blk$28 obj=$53F8 oth=$54FE
    db $29,$2A,$03,$54,$1B,$55  ; v4: bank$2A blk$29 obj=$5403 oth=$551B
Bank11_Area3_Room4:                       ; $533C
    dw $D93D                            ; variant selector
    db $2A,$2A,$09,$54,$3F,$55  ; v0: bank$2A blk$2A obj=$5409 oth=$553F
    db $2B,$2A,$28,$54,$47,$55  ; v1: bank$2A blk$2B obj=$5428 oth=$5547
    db $2C,$2A,$42,$54,$56,$55  ; v2: bank$2A blk$2C obj=$5442 oth=$5556
    db $2D,$2A,$57,$54,$6C,$55  ; v3: bank$2A blk$2D obj=$5457 oth=$556C
    db $2D,$2A,$62,$54,$6C,$55  ; v4: bank$2A blk$2D obj=$5462 oth=$556C
Bank11_Area3_Room5:                       ; $535C
    dw $D93E                            ; variant selector
    db $2E,$2A,$68,$54,$90,$55  ; v0: bank$2A blk$2E obj=$5468 oth=$5590
    db $00,$29,$82,$54,$91,$55  ; v1: bank$29 blk$00 obj=$5482 oth=$5591

; ============================================================================
; Bank11_Area4  ($55AE)  — AREA 4 descriptor (AreaDir[4]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($55AE-$5653, 166 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 4 Descriptor", ROMX[$55AE], BANK[11]
Bank11_Area4:                              ; $55AE
    dw $55BE,$55D8,$55EC,$FFFF   ; rooms 0-3
    dw $560C,$5626,$563A,$FFFF   ; rooms 4-7
Bank11_Area4_Room0:                       ; $55BE
    dw $D93F                            ; variant selector
    db $02,$29,$54,$56,$1E,$58  ; v0: bank$29 blk$02 obj=$5654 oth=$581E
    db $02,$29,$55,$56,$1E,$58  ; v1: bank$29 blk$02 obj=$5655 oth=$581E
    db $02,$29,$6A,$56,$1E,$58  ; v2: bank$29 blk$02 obj=$566A oth=$581E
    db $02,$29,$7F,$56,$1E,$58  ; v3: bank$29 blk$02 obj=$567F oth=$581E
Bank11_Area4_Room1:                       ; $55D8
    dw $D940                            ; variant selector
    db $03,$29,$8F,$56,$1F,$58  ; v0: bank$29 blk$03 obj=$568F oth=$581F
    db $03,$29,$9F,$56,$1F,$58  ; v1: bank$29 blk$03 obj=$569F oth=$581F
    db $03,$29,$B4,$56,$1F,$58  ; v2: bank$29 blk$03 obj=$56B4 oth=$581F
Bank11_Area4_Room2:                       ; $55EC
    dw $D941                            ; variant selector
    db $04,$29,$D3,$56,$20,$58  ; v0: bank$29 blk$04 obj=$56D3 oth=$5820
    db $04,$29,$E8,$56,$20,$58  ; v1: bank$29 blk$04 obj=$56E8 oth=$5820
    db $05,$29,$02,$57,$21,$58  ; v2: bank$29 blk$05 obj=$5702 oth=$5821
    db $05,$29,$26,$57,$21,$58  ; v3: bank$29 blk$05 obj=$5726 oth=$5821
    db $05,$29,$45,$57,$21,$58  ; v4: bank$29 blk$05 obj=$5745 oth=$5821
Bank11_Area4_Room4:                       ; $560C
    dw $D942                            ; variant selector
    db $06,$29,$6E,$57,$29,$58  ; v0: bank$29 blk$06 obj=$576E oth=$5829
    db $06,$29,$7E,$57,$29,$58  ; v1: bank$29 blk$06 obj=$577E oth=$5829
    db $06,$29,$8E,$57,$29,$58  ; v2: bank$29 blk$06 obj=$578E oth=$5829
    db $06,$29,$9E,$57,$29,$58  ; v3: bank$29 blk$06 obj=$579E oth=$5829
Bank11_Area4_Room5:                       ; $5626
    dw $D943                            ; variant selector
    db $07,$29,$B3,$57,$31,$58  ; v0: bank$29 blk$07 obj=$57B3 oth=$5831
    db $07,$29,$C3,$57,$31,$58  ; v1: bank$29 blk$07 obj=$57C3 oth=$5831
    db $07,$29,$D3,$57,$31,$58  ; v2: bank$29 blk$07 obj=$57D3 oth=$5831
Bank11_Area4_Room6:                       ; $563A
    dw $D944                            ; variant selector
    db $08,$29,$ED,$57,$39,$58  ; v0: bank$29 blk$08 obj=$57ED oth=$5839
    db $08,$29,$EE,$57,$39,$58  ; v1: bank$29 blk$08 obj=$57EE oth=$5839
    db $08,$29,$F4,$57,$39,$58  ; v2: bank$29 blk$08 obj=$57F4 oth=$5839
    db $08,$29,$FF,$57,$39,$58  ; v3: bank$29 blk$08 obj=$57FF oth=$5839

; ============================================================================
; Bank11_Area5  ($583A)  — AREA 5 descriptor (AreaDir[5]).
; 3-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($583A-$5875, 60 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 5 Descriptor", ROMX[$583A], BANK[11]
Bank11_Area5:                              ; $583A
    dw $5840,$584E,$585C   ; rooms 0-2
Bank11_Area5_Room0:                       ; $5840
    dw $D945                            ; variant selector
    db $0A,$29,$76,$58,$69,$59  ; v0: bank$29 blk$0A obj=$5876 oth=$5969
    db $0B,$29,$86,$58,$78,$59  ; v1: bank$29 blk$0B obj=$5886 oth=$5978
Bank11_Area5_Room1:                       ; $584E
    dw $D946                            ; variant selector
    db $0C,$29,$AA,$58,$87,$59  ; v0: bank$29 blk$0C obj=$58AA oth=$5987
    db $0C,$29,$BF,$58,$87,$59  ; v1: bank$29 blk$0C obj=$58BF oth=$5987
Bank11_Area5_Room2:                       ; $585C
    dw $D947                            ; variant selector
    db $0D,$29,$E3,$58,$96,$59  ; v0: bank$29 blk$0D obj=$58E3 oth=$5996
    db $0D,$29,$07,$59,$96,$59  ; v1: bank$29 blk$0D obj=$5907 oth=$5996
    db $0D,$29,$26,$59,$96,$59  ; v2: bank$29 blk$0D obj=$5926 oth=$5996
    db $0D,$29,$4A,$59,$96,$59  ; v3: bank$29 blk$0D obj=$594A oth=$5996

; ============================================================================
; Bank11_Area6  ($599E)  — AREA 6 descriptor (AreaDir[6]).
; 4-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($599E-$59BD, 32 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 6 Descriptor", ROMX[$599E], BANK[11]
Bank11_Area6:                              ; $599E
    dw $59A6,$59AE,$59B6,$FFFF   ; rooms 0-3
Bank11_Area6_Room0:                       ; $59A6
    dw $D948                            ; variant selector
    db $0F,$29,$BE,$59,$0C,$5A  ; v0: bank$29 blk$0F obj=$59BE oth=$5A0C
Bank11_Area6_Room1:                       ; $59AE
    dw $D949                            ; variant selector
    db $10,$29,$D8,$59,$14,$5A  ; v0: bank$29 blk$10 obj=$59D8 oth=$5A14
Bank11_Area6_Room2:                       ; $59B6
    dw $D94A                            ; variant selector
    db $11,$29,$01,$5A,$23,$5A  ; v0: bank$29 blk$11 obj=$5A01 oth=$5A23

; ============================================================================
; Bank11_Area7  ($5A2B)  — AREA 7 descriptor (AreaDir[7]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5A2B-$5A9A, 112 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 7 Descriptor", ROMX[$5A2B], BANK[11]
Bank11_Area7:                              ; $5A2B
    dw $5A3B,$5A43,$5A75,$FFFF   ; rooms 0-3
    dw $5A7D,$5A8B,$5A93,$FFFF   ; rooms 4-7
Bank11_Area7_Room0:                       ; $5A3B
    dw $D94B                            ; variant selector
    db $13,$29,$9B,$5A,$29,$5C  ; v0: bank$29 blk$13 obj=$5A9B oth=$5C29
Bank11_Area7_Room1:                       ; $5A43
    dw $D94C                            ; variant selector
    db $14,$29,$B5,$5A,$31,$5C  ; v0: bank$29 blk$14 obj=$5AB5 oth=$5C31
    db $15,$29,$B5,$5A,$32,$5C  ; v1: bank$29 blk$15 obj=$5AB5 oth=$5C32
    db $16,$29,$D4,$5A,$3A,$5C  ; v2: bank$29 blk$16 obj=$5AD4 oth=$5C3A
    db $16,$29,$F8,$5A,$3A,$5C  ; v3: bank$29 blk$16 obj=$5AF8 oth=$5C3A
    db $17,$29,$17,$5B,$49,$5C  ; v4: bank$29 blk$17 obj=$5B17 oth=$5C49
    db $17,$29,$40,$5B,$49,$5C  ; v5: bank$29 blk$17 obj=$5B40 oth=$5C49
    db $17,$29,$64,$5B,$49,$5C  ; v6: bank$29 blk$17 obj=$5B64 oth=$5C49
    db $17,$29,$88,$5B,$49,$5C  ; v7: bank$29 blk$17 obj=$5B88 oth=$5C49
Bank11_Area7_Room2:                       ; $5A75
    dw $D94D                            ; variant selector
    db $18,$29,$A7,$5B,$5F,$5C  ; v0: bank$29 blk$18 obj=$5BA7 oth=$5C5F
Bank11_Area7_Room4:                       ; $5A7D
    dw $D94E                            ; variant selector
    db $19,$29,$C1,$5B,$67,$5C  ; v0: bank$29 blk$19 obj=$5BC1 oth=$5C67
    db $19,$29,$D1,$5B,$67,$5C  ; v1: bank$29 blk$19 obj=$5BD1 oth=$5C67
Bank11_Area7_Room5:                       ; $5A8B
    dw $D94F                            ; variant selector
    db $1A,$29,$E1,$5B,$6F,$5C  ; v0: bank$29 blk$1A obj=$5BE1 oth=$5C6F
Bank11_Area7_Room6:                       ; $5A93
    dw $D950                            ; variant selector
    db $1B,$29,$F1,$5B,$7E,$5C  ; v0: bank$29 blk$1B obj=$5BF1 oth=$5C7E

; ============================================================================
; Bank11_Area8  ($5C86)  — AREA 8 descriptor (AreaDir[8]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5C86-$5CBF, 58 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 8 Descriptor", ROMX[$5C86], BANK[11]
Bank11_Area8:                              ; $5C86
    dw $5C88   ; rooms 0-0
Bank11_Area8_Room0:                       ; $5C88
    dw $D951                            ; variant selector
    db $1E,$29,$C0,$5C,$FF,$FF  ; v0: bank$29 blk$1E obj=$5CC0 oth=$FFFF
    db $1E,$29,$D0,$5C,$FF,$FF  ; v1: bank$29 blk$1E obj=$5CD0 oth=$FFFF
    db $1E,$29,$E0,$5C,$FF,$FF  ; v2: bank$29 blk$1E obj=$5CE0 oth=$FFFF
    db $1E,$29,$E0,$5C,$FF,$FF  ; v3: bank$29 blk$1E obj=$5CE0 oth=$FFFF
    db $1E,$29,$F0,$5C,$FF,$FF  ; v4: bank$29 blk$1E obj=$5CF0 oth=$FFFF
    db $1E,$29,$00,$5D,$FF,$FF  ; v5: bank$29 blk$1E obj=$5D00 oth=$FFFF
    db $1E,$29,$10,$5D,$FF,$FF  ; v6: bank$29 blk$1E obj=$5D10 oth=$FFFF
    db $1E,$29,$1B,$5D,$FF,$FF  ; v7: bank$29 blk$1E obj=$5D1B oth=$FFFF
    db $1E,$29,$30,$5D,$FF,$FF  ; v8: bank$29 blk$1E obj=$5D30 oth=$FFFF

; ============================================================================
; Bank11_Area9  ($5D45)  — AREA 9 descriptor (AreaDir[9]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5D45-$5D8A, 70 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 9 Descriptor", ROMX[$5D45], BANK[11]
Bank11_Area9:                              ; $5D45
    dw $FFFF,$5D55,$FFFF,$FFFF   ; rooms 0-3
    dw $5D69,$5D7D,$FFFF,$FFFF   ; rooms 4-7
Bank11_Area9_Room1:                       ; $5D55
    dw $D952                            ; variant selector
    db $20,$29,$8B,$5D,$5F,$5E  ; v0: bank$29 blk$20 obj=$5D8B oth=$5E5F
    db $20,$29,$BE,$5D,$5F,$5E  ; v1: bank$29 blk$20 obj=$5DBE oth=$5E5F
    db $20,$29,$F6,$5D,$5F,$5E  ; v2: bank$29 blk$20 obj=$5DF6 oth=$5E5F
Bank11_Area9_Room4:                       ; $5D69
    dw $D953                            ; variant selector
    db $21,$29,$29,$5E,$60,$5E  ; v0: bank$29 blk$21 obj=$5E29 oth=$5E60
    db $21,$29,$2F,$5E,$60,$5E  ; v1: bank$29 blk$21 obj=$5E2F oth=$5E60
    db $21,$29,$29,$5E,$68,$5E  ; v2: bank$29 blk$21 obj=$5E29 oth=$5E68
Bank11_Area9_Room5:                       ; $5D7D
    dw $D954                            ; variant selector
    db $22,$29,$30,$5E,$69,$5E  ; v0: bank$29 blk$22 obj=$5E30 oth=$5E69
    db $22,$29,$4A,$5E,$69,$5E  ; v1: bank$29 blk$22 obj=$5E4A oth=$5E69

; ============================================================================
; Bank11_Area10  ($5E6A)  — AREA 10 descriptor (AreaDir[10]).
; 4-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5E6A-$5E81, 24 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 10 Descriptor", ROMX[$5E6A], BANK[11]
Bank11_Area10:                              ; $5E6A
    dw $5E72,$5E7A,$FFFF,$FFFF   ; rooms 0-3
Bank11_Area10_Room0:                       ; $5E72
    dw $D955                            ; variant selector
    db $24,$29,$82,$5E,$84,$5E  ; v0: bank$29 blk$24 obj=$5E82 oth=$5E84
Bank11_Area10_Room1:                       ; $5E7A
    dw $D956                            ; variant selector
    db $25,$29,$83,$5E,$8C,$5E  ; v0: bank$29 blk$25 obj=$5E83 oth=$5E8C

; ============================================================================
; Bank11_Area12  ($5E94)  — AREA 12 descriptor (AreaDir[12]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5E94-$5E9D, 10 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 12 Descriptor", ROMX[$5E94], BANK[11]
Bank11_Area12:                              ; $5E94
    dw $5E96   ; rooms 0-0
Bank11_Area12_Room0:                       ; $5E96
    dw $D957                            ; variant selector
    db $27,$29,$9E,$5E,$B8,$5E  ; v0: bank$29 blk$27 obj=$5E9E oth=$5EB8

; ============================================================================
; Bank11_Area13  ($5EC0)  — AREA 13 descriptor (AreaDir[13]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5EC0-$5ECF, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 13 Descriptor", ROMX[$5EC0], BANK[11]
Bank11_Area13:                              ; $5EC0
    dw $5EC2   ; rooms 0-0
Bank11_Area13_Room0:                       ; $5EC2
    dw $D958                            ; variant selector
    db $01,$30,$D0,$5E,$3B,$5F  ; v0: bank$30 blk$01 obj=$5ED0 oth=$5F3B
    db $01,$30,$08,$5F,$3B,$5F  ; v1: bank$30 blk$01 obj=$5F08 oth=$5F3B

; ============================================================================
; Bank11_Area15  ($5F4A)  — AREA 15 descriptor (AreaDir[15]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5F4A-$5F53, 10 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 15 Descriptor", ROMX[$5F4A], BANK[11]
Bank11_Area15:                              ; $5F4A
    dw $5F4C   ; rooms 0-0
Bank11_Area15_Room0:                       ; $5F4C
    dw $D959                            ; variant selector
    db $03,$30,$54,$5F,$69,$5F  ; v0: bank$30 blk$03 obj=$5F54 oth=$5F69

; ============================================================================
; Bank11_Area16  ($5F71)  — AREA 16 descriptor (AreaDir[16]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5F71-$5F80, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 16 Descriptor", ROMX[$5F71], BANK[11]
Bank11_Area16:                              ; $5F71
    dw $5F73   ; rooms 0-0
Bank11_Area16_Room0:                       ; $5F73
    dw $D95A                            ; variant selector
    db $05,$30,$81,$5F,$C9,$5F  ; v0: bank$30 blk$05 obj=$5F81 oth=$5FC9
    db $06,$30,$A5,$5F,$D1,$5F  ; v1: bank$30 blk$06 obj=$5FA5 oth=$5FD1

; ============================================================================
; Bank11_Area18  ($5FE0)  — AREA 18 descriptor (AreaDir[18]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($5FE0-$6005, 38 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 18 Descriptor", ROMX[$5FE0], BANK[11]
Bank11_Area18:                              ; $5FE0
    dw $5FF0,$FFFF,$FFFF,$FFFF   ; rooms 0-3
    dw $5FF8,$FFFF,$FFFF,$FFFF   ; rooms 4-7
Bank11_Area18_Room0:                       ; $5FF0
    dw $D95B                            ; variant selector
    db $08,$30,$06,$60,$72,$60  ; v0: bank$30 blk$08 obj=$6006 oth=$6072
Bank11_Area18_Room4:                       ; $5FF8
    dw $D95C                            ; variant selector
    db $09,$30,$48,$60,$73,$60  ; v0: bank$30 blk$09 obj=$6048 oth=$6073
    db $09,$30,$62,$60,$73,$60  ; v1: bank$30 blk$09 obj=$6062 oth=$6073

; ============================================================================
; Bank11_Area19  ($6082)  — AREA 19 descriptor (AreaDir[19]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6082-$6091, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 19 Descriptor", ROMX[$6082], BANK[11]
Bank11_Area19:                              ; $6082
    dw $6084   ; rooms 0-0
Bank11_Area19_Room0:                       ; $6084
    dw $D95D                            ; variant selector
    db $0B,$30,$92,$60,$2F,$61  ; v0: bank$30 blk$0B obj=$6092 oth=$612F
    db $0B,$30,$E3,$60,$2F,$61  ; v1: bank$30 blk$0B obj=$60E3 oth=$612F

; ============================================================================
; Bank11_Area22  ($613E)  — AREA 22 descriptor (AreaDir[22]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($613E-$6165, 40 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 22 Descriptor", ROMX[$613E], BANK[11]
Bank11_Area22:                              ; $613E
    dw $6140   ; rooms 0-0
Bank11_Area22_Room0:                       ; $6140
    dw $D95E                            ; variant selector
    db $0D,$30,$66,$61,$D0,$61  ; v0: bank$30 blk$0D obj=$6166 oth=$61D0
    db $0E,$30,$76,$61,$D8,$61  ; v1: bank$30 blk$0E obj=$6176 oth=$61D8
    db $0E,$30,$8B,$61,$D8,$61  ; v2: bank$30 blk$0E obj=$618B oth=$61D8
    db $0D,$30,$9B,$61,$EE,$61  ; v3: bank$30 blk$0D obj=$619B oth=$61EE
    db $0E,$30,$AB,$61,$D8,$61  ; v4: bank$30 blk$0E obj=$61AB oth=$61D8
    db $0E,$30,$C0,$61,$D8,$61  ; v5: bank$30 blk$0E obj=$61C0 oth=$61D8

; ============================================================================
; Bank11_Area24  ($61FD)  — AREA 24 descriptor (AreaDir[24]).
; 8-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($61FD-$6228, 44 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 24 Descriptor", ROMX[$61FD], BANK[11]
Bank11_Area24:                              ; $61FD
    dw $620D,$FFFF,$FFFF,$FFFF   ; rooms 0-3
    dw $6215,$FFFF,$FFFF,$FFFF   ; rooms 4-7
Bank11_Area24_Room0:                       ; $620D
    dw $D95F                            ; variant selector
    db $10,$30,$29,$62,$AF,$62  ; v0: bank$30 blk$10 obj=$6229 oth=$62AF
Bank11_Area24_Room4:                       ; $6215
    dw $D960                            ; variant selector
    db $11,$30,$2A,$62,$B7,$62  ; v0: bank$30 blk$11 obj=$622A oth=$62B7
    db $12,$30,$62,$62,$B8,$62  ; v1: bank$30 blk$12 obj=$6262 oth=$62B8
    db $12,$30,$8B,$62,$B8,$62  ; v2: bank$30 blk$12 obj=$628B oth=$62B8

; ============================================================================
; Bank11_Area25  ($62C0)  — AREA 25 descriptor (AreaDir[25]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($62C0-$62C9, 10 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 25 Descriptor", ROMX[$62C0], BANK[11]
Bank11_Area25:                              ; $62C0
    dw $62C2   ; rooms 0-0
Bank11_Area25_Room0:                       ; $62C2
    dw $D961                            ; variant selector
    db $14,$30,$CA,$62,$DF,$62  ; v0: bank$30 blk$14 obj=$62CA oth=$62DF

; ============================================================================
; Bank11_Area26  ($62E7)  — AREA 26 descriptor (AreaDir[26]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($62E7-$62F0, 10 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 26 Descriptor", ROMX[$62E7], BANK[11]
Bank11_Area26:                              ; $62E7
    dw $62E9   ; rooms 0-0
Bank11_Area26_Room0:                       ; $62E9
    dw $D962                            ; variant selector
    db $16,$30,$F1,$62,$10,$63  ; v0: bank$30 blk$16 obj=$62F1 oth=$6310

; ============================================================================
; Bank11_Area27  ($6318)  — AREA 27 descriptor (AreaDir[27]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6318-$632D, 22 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 27 Descriptor", ROMX[$6318], BANK[11]
Bank11_Area27:                              ; $6318
    dw $631A   ; rooms 0-0
Bank11_Area27_Room0:                       ; $631A
    dw $D963                            ; variant selector
    db $18,$30,$2E,$63,$54,$63  ; v0: bank$30 blk$18 obj=$632E oth=$6354
    db $18,$30,$39,$63,$54,$63  ; v1: bank$30 blk$18 obj=$6339 oth=$6354
    db $18,$30,$44,$63,$54,$63  ; v2: bank$30 blk$18 obj=$6344 oth=$6354

; ============================================================================
; Bank11_Area28  ($6363)  — AREA 28 descriptor (AreaDir[28]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6363-$6372, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 28 Descriptor", ROMX[$6363], BANK[11]
Bank11_Area28:                              ; $6363
    dw $6365   ; rooms 0-0
Bank11_Area28_Room0:                       ; $6365
    dw $D964                            ; variant selector
    db $1A,$30,$73,$63,$BB,$63  ; v0: bank$30 blk$1A obj=$6373 oth=$63BB
    db $1A,$30,$97,$63,$BB,$63  ; v1: bank$30 blk$1A obj=$6397 oth=$63BB

; ============================================================================
; Bank11_Area29  ($63CA)  — AREA 29 descriptor (AreaDir[29]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($63CA-$63D3, 10 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 29 Descriptor", ROMX[$63CA], BANK[11]
Bank11_Area29:                              ; $63CA
    dw $63CC   ; rooms 0-0
Bank11_Area29_Room0:                       ; $63CC
    dw $D965                            ; variant selector
    db $1C,$30,$D4,$63,$F3,$63  ; v0: bank$30 blk$1C obj=$63D4 oth=$63F3

; ============================================================================
; Bank11_Area30  ($63FB)  — AREA 30 descriptor (AreaDir[30]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($63FB-$640A, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 30 Descriptor", ROMX[$63FB], BANK[11]
Bank11_Area30:                              ; $63FB
    dw $63FD   ; rooms 0-0
Bank11_Area30_Room0:                       ; $63FD
    dw $D966                            ; variant selector
    db $1E,$30,$0B,$64,$35,$64  ; v0: bank$30 blk$1E obj=$640B oth=$6435
    db $1E,$30,$20,$64,$35,$64  ; v1: bank$30 blk$1E obj=$6420 oth=$6435

; ============================================================================
; Bank11_Area31  ($643D)  — AREA 31 descriptor (AreaDir[31]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($643D-$6452, 22 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 31 Descriptor", ROMX[$643D], BANK[11]
Bank11_Area31:                              ; $643D
    dw $643F   ; rooms 0-0
Bank11_Area31_Room0:                       ; $643F
    dw $D967                            ; variant selector
    db $01,$2D,$53,$64,$A1,$64  ; v0: bank$2D blk$01 obj=$6453 oth=$64A1
    db $01,$2D,$6D,$64,$A1,$64  ; v1: bank$2D blk$01 obj=$646D oth=$64A1
    db $01,$2D,$87,$64,$A1,$64  ; v2: bank$2D blk$01 obj=$6487 oth=$64A1

; ============================================================================
; Bank11_Area35  ($64A9)  — AREA 35 descriptor (AreaDir[35]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($64A9-$64B8, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 35 Descriptor", ROMX[$64A9], BANK[11]
Bank11_Area35:                              ; $64A9
    dw $64AB   ; rooms 0-0
Bank11_Area35_Room0:                       ; $64AB
    dw $D968                            ; variant selector
    db $03,$2D,$B9,$64,$CA,$64  ; v0: bank$2D blk$03 obj=$64B9 oth=$64CA
    db $03,$2D,$C4,$64,$CA,$64  ; v1: bank$2D blk$03 obj=$64C4 oth=$64CA

; ============================================================================
; Bank11_Area36  ($64E0)  — AREA 36 descriptor (AreaDir[36]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($64E0-$64FB, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 36 Descriptor", ROMX[$64E0], BANK[11]
Bank11_Area36:                              ; $64E0
    dw $64E2   ; rooms 0-0
Bank11_Area36_Room0:                       ; $64E2
    dw $D969                            ; variant selector
    db $05,$2D,$FC,$64,$28,$65  ; v0: bank$2D blk$05 obj=$64FC oth=$6528
    db $05,$2D,$0C,$65,$28,$65  ; v1: bank$2D blk$05 obj=$650C oth=$6528
    db $05,$2D,$17,$65,$28,$65  ; v2: bank$2D blk$05 obj=$6517 oth=$6528
    db $05,$2D,$22,$65,$28,$65  ; v3: bank$2D blk$05 obj=$6522 oth=$6528

; ============================================================================
; Bank11_Area37  ($653E)  — AREA 37 descriptor (AreaDir[37]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($653E-$6559, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 37 Descriptor", ROMX[$653E], BANK[11]
Bank11_Area37:                              ; $653E
    dw $6540   ; rooms 0-0
Bank11_Area37_Room0:                       ; $6540
    dw $D96A                            ; variant selector
    db $07,$2D,$5A,$65,$86,$65  ; v0: bank$2D blk$07 obj=$655A oth=$6586
    db $07,$2D,$6A,$65,$86,$65  ; v1: bank$2D blk$07 obj=$656A oth=$6586
    db $07,$2D,$75,$65,$86,$65  ; v2: bank$2D blk$07 obj=$6575 oth=$6586
    db $07,$2D,$80,$65,$86,$65  ; v3: bank$2D blk$07 obj=$6580 oth=$6586

; ============================================================================
; Bank11_Area38  ($659C)  — AREA 38 descriptor (AreaDir[38]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($659C-$65B7, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 38 Descriptor", ROMX[$659C], BANK[11]
Bank11_Area38:                              ; $659C
    dw $659E   ; rooms 0-0
Bank11_Area38_Room0:                       ; $659E
    dw $D96B                            ; variant selector
    db $09,$2D,$B8,$65,$E4,$65  ; v0: bank$2D blk$09 obj=$65B8 oth=$65E4
    db $09,$2D,$C8,$65,$E4,$65  ; v1: bank$2D blk$09 obj=$65C8 oth=$65E4
    db $09,$2D,$D3,$65,$E4,$65  ; v2: bank$2D blk$09 obj=$65D3 oth=$65E4
    db $09,$2D,$DE,$65,$E4,$65  ; v3: bank$2D blk$09 obj=$65DE oth=$65E4

; ============================================================================
; Bank11_Area39  ($65FA)  — AREA 39 descriptor (AreaDir[39]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($65FA-$660F, 22 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 39 Descriptor", ROMX[$65FA], BANK[11]
Bank11_Area39:                              ; $65FA
    dw $65FC   ; rooms 0-0
Bank11_Area39_Room0:                       ; $65FC
    dw $D96C                            ; variant selector
    db $0B,$2D,$10,$66,$40,$66  ; v0: bank$2D blk$0B obj=$6610 oth=$6640
    db $0B,$2D,$25,$66,$40,$66  ; v1: bank$2D blk$0B obj=$6625 oth=$6640
    db $0B,$2D,$35,$66,$40,$66  ; v2: bank$2D blk$0B obj=$6635 oth=$6640

; ============================================================================
; Bank11_Area40  ($665D)  — AREA 40 descriptor (AreaDir[40]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($665D-$6678, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 40 Descriptor", ROMX[$665D], BANK[11]
Bank11_Area40:                              ; $665D
    dw $665F   ; rooms 0-0
Bank11_Area40_Room0:                       ; $665F
    dw $D96D                            ; variant selector
    db $0D,$2D,$79,$66,$A5,$66  ; v0: bank$2D blk$0D obj=$6679 oth=$66A5
    db $0D,$2D,$89,$66,$A5,$66  ; v1: bank$2D blk$0D obj=$6689 oth=$66A5
    db $0D,$2D,$94,$66,$A5,$66  ; v2: bank$2D blk$0D obj=$6694 oth=$66A5
    db $0D,$2D,$9F,$66,$A5,$66  ; v3: bank$2D blk$0D obj=$669F oth=$66A5

; ============================================================================
; Bank11_Area41  ($66BB)  — AREA 41 descriptor (AreaDir[41]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($66BB-$66D6, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 41 Descriptor", ROMX[$66BB], BANK[11]
Bank11_Area41:                              ; $66BB
    dw $66BD   ; rooms 0-0
Bank11_Area41_Room0:                       ; $66BD
    dw $D96E                            ; variant selector
    db $0F,$2D,$D7,$66,$03,$67  ; v0: bank$2D blk$0F obj=$66D7 oth=$6703
    db $0F,$2D,$E7,$66,$03,$67  ; v1: bank$2D blk$0F obj=$66E7 oth=$6703
    db $0F,$2D,$F2,$66,$03,$67  ; v2: bank$2D blk$0F obj=$66F2 oth=$6703
    db $0F,$2D,$FD,$66,$03,$67  ; v3: bank$2D blk$0F obj=$66FD oth=$6703

; ============================================================================
; Bank11_Area42  ($6719)  — AREA 42 descriptor (AreaDir[42]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6719-$6734, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 42 Descriptor", ROMX[$6719], BANK[11]
Bank11_Area42:                              ; $6719
    dw $671B   ; rooms 0-0
Bank11_Area42_Room0:                       ; $671B
    dw $D96F                            ; variant selector
    db $11,$2D,$35,$67,$61,$67  ; v0: bank$2D blk$11 obj=$6735 oth=$6761
    db $11,$2D,$45,$67,$61,$67  ; v1: bank$2D blk$11 obj=$6745 oth=$6761
    db $11,$2D,$50,$67,$61,$67  ; v2: bank$2D blk$11 obj=$6750 oth=$6761
    db $11,$2D,$5B,$67,$61,$67  ; v3: bank$2D blk$11 obj=$675B oth=$6761

; ============================================================================
; Bank11_Area43  ($6777)  — AREA 43 descriptor (AreaDir[43]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6777-$6786, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 43 Descriptor", ROMX[$6777], BANK[11]
Bank11_Area43:                              ; $6777
    dw $6779   ; rooms 0-0
Bank11_Area43_Room0:                       ; $6779
    dw $D970                            ; variant selector
    db $13,$2D,$87,$67,$98,$67  ; v0: bank$2D blk$13 obj=$6787 oth=$6798
    db $13,$2D,$92,$67,$98,$67  ; v1: bank$2D blk$13 obj=$6792 oth=$6798

; ============================================================================
; Bank11_Area44  ($67AE)  — AREA 44 descriptor (AreaDir[44]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($67AE-$67C9, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 44 Descriptor", ROMX[$67AE], BANK[11]
Bank11_Area44:                              ; $67AE
    dw $67B0   ; rooms 0-0
Bank11_Area44_Room0:                       ; $67B0
    dw $D971                            ; variant selector
    db $15,$2D,$CA,$67,$F6,$67  ; v0: bank$2D blk$15 obj=$67CA oth=$67F6
    db $15,$2D,$DA,$67,$F6,$67  ; v1: bank$2D blk$15 obj=$67DA oth=$67F6
    db $15,$2D,$E5,$67,$F6,$67  ; v2: bank$2D blk$15 obj=$67E5 oth=$67F6
    db $15,$2D,$F0,$67,$F6,$67  ; v3: bank$2D blk$15 obj=$67F0 oth=$67F6

; ============================================================================
; Bank11_Area45  ($680C)  — AREA 45 descriptor (AreaDir[45]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($680C-$6827, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 45 Descriptor", ROMX[$680C], BANK[11]
Bank11_Area45:                              ; $680C
    dw $680E   ; rooms 0-0
Bank11_Area45_Room0:                       ; $680E
    dw $D972                            ; variant selector
    db $17,$2D,$28,$68,$54,$68  ; v0: bank$2D blk$17 obj=$6828 oth=$6854
    db $17,$2D,$38,$68,$54,$68  ; v1: bank$2D blk$17 obj=$6838 oth=$6854
    db $17,$2D,$43,$68,$54,$68  ; v2: bank$2D blk$17 obj=$6843 oth=$6854
    db $17,$2D,$4E,$68,$54,$68  ; v3: bank$2D blk$17 obj=$684E oth=$6854

; ============================================================================
; Bank11_Area46  ($686A)  — AREA 46 descriptor (AreaDir[46]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($686A-$6885, 28 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 46 Descriptor", ROMX[$686A], BANK[11]
Bank11_Area46:                              ; $686A
    dw $686C   ; rooms 0-0
Bank11_Area46_Room0:                       ; $686C
    dw $D973                            ; variant selector
    db $19,$2D,$86,$68,$B2,$68  ; v0: bank$2D blk$19 obj=$6886 oth=$68B2
    db $19,$2D,$96,$68,$B2,$68  ; v1: bank$2D blk$19 obj=$6896 oth=$68B2
    db $19,$2D,$A1,$68,$B2,$68  ; v2: bank$2D blk$19 obj=$68A1 oth=$68B2
    db $19,$2D,$AC,$68,$B2,$68  ; v3: bank$2D blk$19 obj=$68AC oth=$68B2

; ============================================================================
; Bank11_Area47  ($68CF)  — AREA 47 descriptor (AreaDir[47]).
; 6-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($68CF-$6914, 70 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 47 Descriptor", ROMX[$68CF], BANK[11]
Bank11_Area47:                              ; $68CF
    dw $FFFF,$FFFF,$FFFF,$FFFF   ; rooms 0-3
    dw $68DB,$6907   ; rooms 4-5
Bank11_Area47_Room4:                       ; $68DB
    dw $D974                            ; variant selector
    db $1B,$2D,$15,$69,$B2,$6A  ; v0: bank$2D blk$1B obj=$6915 oth=$6AB2
    db $1B,$2D,$48,$69,$B2,$6A  ; v1: bank$2D blk$1B obj=$6948 oth=$6AB2
    db $1B,$2D,$6C,$69,$B2,$6A  ; v2: bank$2D blk$1B obj=$696C oth=$6AB2
    db $1B,$2D,$A9,$69,$B2,$6A  ; v3: bank$2D blk$1B obj=$69A9 oth=$6AB2
    db $1B,$2D,$E6,$69,$B2,$6A  ; v4: bank$2D blk$1B obj=$69E6 oth=$6AB2
    db $1B,$2D,$2D,$6A,$B2,$6A  ; v5: bank$2D blk$1B obj=$6A2D oth=$6AB2
    db $1B,$2D,$6C,$69,$B2,$6A  ; v6: bank$2D blk$1B obj=$696C oth=$6AB2
Bank11_Area47_Room5:                       ; $6907
    dw $D975                            ; variant selector
    db $1C,$2D,$6A,$6A,$B3,$6A  ; v0: bank$2D blk$1C obj=$6A6A oth=$6AB3
    db $1C,$2D,$93,$6A,$B3,$6A  ; v1: bank$2D blk$1C obj=$6A93 oth=$6AB3

; ============================================================================
; Bank11_Area48  ($6AB4)  — AREA 48 descriptor (AreaDir[48]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6AB4-$6AC3, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 48 Descriptor", ROMX[$6AB4], BANK[11]
Bank11_Area48:                              ; $6AB4
    dw $6AB6   ; rooms 0-0
Bank11_Area48_Room0:                       ; $6AB6
    dw $D976                            ; variant selector
    db $0D,$26,$C4,$6A,$D0,$6A  ; v0: bank$26 blk$0D obj=$6AC4 oth=$6AD0
    db $0E,$26,$CF,$6A,$D1,$6A  ; v1: bank$26 blk$0E obj=$6ACF oth=$6AD1

; ============================================================================
; Bank11_Area49  ($6AD9)  — AREA 49 descriptor (AreaDir[49]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6AD9-$6AE8, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 49 Descriptor", ROMX[$6AD9], BANK[11]
Bank11_Area49:                              ; $6AD9
    dw $6ADB   ; rooms 0-0
Bank11_Area49_Room0:                       ; $6ADB
    dw $D977                            ; variant selector
    db $10,$26,$E9,$6A,$0E,$6B  ; v0: bank$26 blk$10 obj=$6AE9 oth=$6B0E
    db $11,$26,$08,$6B,$0F,$6B  ; v1: bank$26 blk$11 obj=$6B08 oth=$6B0F

; ============================================================================
; Bank11_Area50  ($6B17)  — AREA 50 descriptor (AreaDir[50]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6B17-$6B26, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 50 Descriptor", ROMX[$6B17], BANK[11]
Bank11_Area50:                              ; $6B17
    dw $6B19   ; rooms 0-0
Bank11_Area50_Room0:                       ; $6B19
    dw $D978                            ; variant selector
    db $16,$24,$27,$6B,$3D,$6B  ; v0: bank$24 blk$16 obj=$6B27 oth=$6B3D
    db $17,$24,$3C,$6B,$3E,$6B  ; v1: bank$24 blk$17 obj=$6B3C oth=$6B3E

; ============================================================================
; Bank11_Area51  ($6B46)  — AREA 51 descriptor (AreaDir[51]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6B46-$6B55, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 51 Descriptor", ROMX[$6B46], BANK[11]
Bank11_Area51:                              ; $6B46
    dw $6B48   ; rooms 0-0
Bank11_Area51_Room0:                       ; $6B48
    dw $D979                            ; variant selector
    db $13,$26,$56,$6B,$62,$6B  ; v0: bank$26 blk$13 obj=$6B56 oth=$6B62
    db $14,$26,$61,$6B,$63,$6B  ; v1: bank$26 blk$14 obj=$6B61 oth=$6B63

; ============================================================================
; Bank11_Area52  ($6B6B)  — AREA 52 descriptor (AreaDir[52]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6B6B-$6B7A, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 52 Descriptor", ROMX[$6B6B], BANK[11]
Bank11_Area52:                              ; $6B6B
    dw $6B6D   ; rooms 0-0
Bank11_Area52_Room0:                       ; $6B6D
    dw $D97A                            ; variant selector
    db $16,$26,$7B,$6B,$BE,$6B  ; v0: bank$26 blk$16 obj=$6B7B oth=$6BBE
    db $17,$26,$B8,$6B,$BF,$6B  ; v1: bank$26 blk$17 obj=$6BB8 oth=$6BBF

; ============================================================================
; Bank11_Area53  ($6BC7)  — AREA 53 descriptor (AreaDir[53]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6BC7-$6BD6, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 53 Descriptor", ROMX[$6BC7], BANK[11]
Bank11_Area53:                              ; $6BC7
    dw $6BC9   ; rooms 0-0
Bank11_Area53_Room0:                       ; $6BC9
    dw $D97B                            ; variant selector
    db $19,$26,$D7,$6B,$F7,$6B  ; v0: bank$26 blk$19 obj=$6BD7 oth=$6BF7
    db $1A,$26,$EC,$6B,$F8,$6B  ; v1: bank$26 blk$1A obj=$6BEC oth=$6BF8

; ============================================================================
; Bank11_Area54  ($6C00)  — AREA 54 descriptor (AreaDir[54]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6C00-$6C0F, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 54 Descriptor", ROMX[$6C00], BANK[11]
Bank11_Area54:                              ; $6C00
    dw $6C02   ; rooms 0-0
Bank11_Area54_Room0:                       ; $6C02
    dw $D97C                            ; variant selector
    db $1C,$26,$10,$6C,$80,$6C  ; v0: bank$26 blk$1C obj=$6C10 oth=$6C80
    db $1D,$26,$57,$6C,$81,$6C  ; v1: bank$26 blk$1D obj=$6C57 oth=$6C81

; ============================================================================
; Bank11_Area55  ($6C89)  — AREA 55 descriptor (AreaDir[55]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6C89-$6C98, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 55 Descriptor", ROMX[$6C89], BANK[11]
Bank11_Area55:                              ; $6C89
    dw $6C8B   ; rooms 0-0
Bank11_Area55_Room0:                       ; $6C8B
    dw $D97D                            ; variant selector
    db $1B,$25,$99,$6C,$13,$6D  ; v0: bank$25 blk$1B obj=$6C99 oth=$6D13
    db $1C,$25,$E0,$6C,$14,$6D  ; v1: bank$25 blk$1C obj=$6CE0 oth=$6D14

; ============================================================================
; Bank11_Area56  ($6D1C)  — AREA 56 descriptor (AreaDir[56]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6D1C-$6D2B, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 56 Descriptor", ROMX[$6D1C], BANK[11]
Bank11_Area56:                              ; $6D1C
    dw $6D1E   ; rooms 0-0
Bank11_Area56_Room0:                       ; $6D1E
    dw $D97E                            ; variant selector
    db $01,$25,$2C,$6D,$F6,$6D  ; v0: bank$25 blk$01 obj=$6D2C oth=$6DF6
    db $02,$25,$9B,$6D,$F7,$6D  ; v1: bank$25 blk$02 obj=$6D9B oth=$6DF7

; ============================================================================
; Bank11_Area57  ($6DFF)  — AREA 57 descriptor (AreaDir[57]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6DFF-$6E0E, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 57 Descriptor", ROMX[$6DFF], BANK[11]
Bank11_Area57:                              ; $6DFF
    dw $6E01   ; rooms 0-0
Bank11_Area57_Room0:                       ; $6E01
    dw $D97F                            ; variant selector
    db $04,$23,$0F,$6E,$2F,$6E  ; v0: bank$23 blk$04 obj=$6E0F oth=$6E2F
    db $05,$23,$29,$6E,$30,$6E  ; v1: bank$23 blk$05 obj=$6E29 oth=$6E30

; ============================================================================
; Bank11_Area58  ($6E38)  — AREA 58 descriptor (AreaDir[58]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6E38-$6E47, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 58 Descriptor", ROMX[$6E38], BANK[11]
Bank11_Area58:                              ; $6E38
    dw $6E3A   ; rooms 0-0
Bank11_Area58_Room0:                       ; $6E3A
    dw $D980                            ; variant selector
    db $04,$25,$48,$6E,$3A,$6F  ; v0: bank$25 blk$04 obj=$6E48 oth=$6F3A
    db $05,$25,$D5,$6E,$3B,$6F  ; v1: bank$25 blk$05 obj=$6ED5 oth=$6F3B

; ============================================================================
; Bank11_Area59  ($6F43)  — AREA 59 descriptor (AreaDir[59]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6F43-$6F52, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 59 Descriptor", ROMX[$6F43], BANK[11]
Bank11_Area59:                              ; $6F43
    dw $6F45   ; rooms 0-0
Bank11_Area59_Room0:                       ; $6F45
    dw $D981                            ; variant selector
    db $07,$24,$53,$6F,$5F,$6F  ; v0: bank$24 blk$07 obj=$6F53 oth=$6F5F
    db $08,$24,$5E,$6F,$60,$6F  ; v1: bank$24 blk$08 obj=$6F5E oth=$6F60

; ============================================================================
; Bank11_Area60  ($6F68)  — AREA 60 descriptor (AreaDir[60]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6F68-$6F7D, 22 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 60 Descriptor", ROMX[$6F68], BANK[11]
Bank11_Area60:                              ; $6F68
    dw $6F6A   ; rooms 0-0
Bank11_Area60_Room0:                       ; $6F6A
    dw $D982                            ; variant selector
    db $07,$23,$7E,$6F,$DF,$6F  ; v0: bank$23 blk$07 obj=$6F7E oth=$6FDF
    db $09,$23,$7E,$6F,$E0,$6F  ; v1: bank$23 blk$09 obj=$6F7E oth=$6FE0
    db $08,$23,$BB,$6F,$E0,$6F  ; v2: bank$23 blk$08 obj=$6FBB oth=$6FE0

; ============================================================================
; Bank11_Area61  ($6FE8)  — AREA 61 descriptor (AreaDir[61]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($6FE8-$6FF7, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 61 Descriptor", ROMX[$6FE8], BANK[11]
Bank11_Area61:                              ; $6FE8
    dw $6FEA   ; rooms 0-0
Bank11_Area61_Room0:                       ; $6FEA
    dw $D983                            ; variant selector
    db $07,$25,$F8,$6F,$27,$70  ; v0: bank$25 blk$07 obj=$6FF8 oth=$7027
    db $07,$25,$1C,$70,$27,$70  ; v1: bank$25 blk$07 obj=$701C oth=$7027

; ============================================================================
; Bank11_Area62  ($7028)  — AREA 62 descriptor (AreaDir[62]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($7028-$7037, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 62 Descriptor", ROMX[$7028], BANK[11]
Bank11_Area62:                              ; $7028
    dw $702A   ; rooms 0-0
Bank11_Area62_Room0:                       ; $702A
    dw $D984                            ; variant selector
    db $09,$25,$38,$70,$4E,$70  ; v0: bank$25 blk$09 obj=$7038 oth=$704E
    db $0A,$25,$4D,$70,$4F,$70  ; v1: bank$25 blk$0A obj=$704D oth=$704F

; ============================================================================
; Bank11_Area63  ($7057)  — AREA 63 descriptor (AreaDir[63]).
; 1-word room array + per-room {sel + N*(db block,bank; dw objlist,other)}.
; Byte-exact ($7057-$7066, 16 bytes).
; ----------------------------------------------------------------------------
SECTION "Bank 11 Area 63 Descriptor", ROMX[$7057], BANK[11]
Bank11_Area63:                              ; $7057
    dw $7059   ; rooms 0-0
Bank11_Area63_Room0:                       ; $7059
    dw $D985                            ; variant selector
    db $01,$24,$67,$70,$73,$70  ; v0: bank$24 blk$01 obj=$7067 oth=$7073
    db $02,$24,$72,$70,$74,$70  ; v1: bank$24 blk$02 obj=$7072 oth=$7074

; ============================================================================
; Bank11_Area63_ObjLists  ($7067)  — AREA 63 object/NPC source lists
; Compact 5-byte records the Area63 descriptor points at (obj=$7067/oth=$7073).
; Same format as Area0_ObjLists. Byte-exact ($7067-$707B).
; ============================================================================
SECTION "Bank 11 Area 63 Object Lists", ROMX[$7067], BANK[11]
Bank11_Area63_Obj_7067:          ; $7067  (object list)
    db $00,$2B,$01,$05,$01   ; $7067 type0 face0 spr$2B (+1,+5) ev$01
    db $50,$21,$0A,$00,$FF   ; $706C type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $7071 end
Bank11_Area63_Obj_7072:          ; $7072  (object list)
    db $FF   ; $7072 end
Bank11_Area63_Obj_7073:          ; $7073  (object list)
    db $FF   ; $7073 end
Bank11_Area63_Obj_7074:          ; $7074  (object list)
    db $01,$05,$00,$00,$01   ; $7074 type1 face0 spr$05 (+0,+0) ev$01
    db $04,$05,$FF   ; $7079 (tail)

; ============================================================================
; AREA 64-103 DESCRIPTORS  ($707C-$7D26)
; ----------------------------------------------------------------------------
; AreaDir points here for areas 64-103 ($40-$67 hex). Decoded like Area0-63:
; dw room-array; per-room {dw sel; N*(db block,bank; dw obj,oth)}; then object
; lists as 5-byte records (type/face,spr,+x,+y,event; $FF end; bit7=HEADER).
; A few non-standard descriptors are shown as raw db. DECIMAL area index.
; ============================================================================
SECTION "Bank 11 Area 64-103 Descriptors", ROMX[$707C], BANK[11]
Bank11_Area64:              ; $707C  AreaDir[64]=area $40
    dw $707E   ; rooms 0-0
Bank11_Area64_Room0:        ; $707E  room(s) 0: sel + 1 variant(s)
    dw $D986   ; variant selector (WRAM)
    db $16,$25,$86,$70,$BE,$70  ; v0: bank$25 blk$16 obj=$7086 oth=$70BE
Bank11_Area64_ObjLists:     ; $7086-$70E8  compact 5-byte object records + "other" data
Bank11_Area64_Obj_7086:          ; $7086  (object list)
    db $90,$FF,$01,$01,$06   ; $7086 HEADER(bit7)
    db $90,$FF,$02,$01,$06   ; $708B HEADER(bit7)
    db $90,$FF,$04,$01,$07   ; $7090 HEADER(bit7)
    db $90,$FF,$05,$01,$07   ; $7095 HEADER(bit7)
    db $90,$FF,$07,$01,$08   ; $709A HEADER(bit7)
    db $90,$FF,$08,$01,$08   ; $709F HEADER(bit7)
    db $8F,$FF,$03,$03,$01   ; $70A4 HEADER(bit7)
    db $8F,$FF,$06,$03,$02   ; $70A9 HEADER(bit7)
    db $00,$05,$02,$02,$03   ; $70AE type0 face0 spr$05 (+2,+2) ev$03
    db $00,$05,$05,$02,$04   ; $70B3 type0 face0 spr$05 (+5,+2) ev$04
    db $00,$05,$08,$02,$05   ; $70B8 type0 face0 spr$05 (+8,+2) ev$05
    db $FF   ; $70BD end
Bank11_Area64_Obj_70BE:          ; $70BE  (object list)
    db $01,$01,$41,$00,$00   ; $70BE type1 face0 spr$01 (+65,+0) ev$00
    db $01,$06,$02,$01,$41   ; $70C3 type1 face0 spr$06 (+2,+1) ev$41
    db $00,$00,$02,$06,$04   ; $70C8 type0 face0 spr$00 (+2,+6) ev$04
    db $01,$41,$00,$00,$04   ; $70CD type1 face0 spr$41 (+0,+0) ev$04
    db $06,$05,$01,$41,$00   ; $70D2 type6 face0 spr$05 (+1,+65) ev$00
    db $00,$05,$06,$07,$01   ; $70D7 type0 face0 spr$05 (+6,+7) ev$01
    db $41,$00,$00,$07,$06   ; $70DC type1 face4 spr$00 (+0,+7) ev$06
    db $08,$01,$41,$00,$00   ; $70E1 type8 face0 spr$01 (+65,+0) ev$00
    db $08,$06,$FF   ; $70E6 (tail)

Bank11_Area65:              ; $70E9  AreaDir[65]=area $41
    dw $70EB   ; rooms 0-0
Bank11_Area65_Room0:        ; $70EB  room(s) 0: sel + 4 variant(s)
    dw $D987   ; variant selector (WRAM)
    db $18,$25,$05,$71,$30,$71  ; v0: bank$25 blk$18 obj=$7105 oth=$7130
    db $18,$25,$10,$71,$30,$71  ; v1: bank$25 blk$18 obj=$7110 oth=$7130
    db $18,$25,$25,$71,$30,$71  ; v2: bank$25 blk$18 obj=$7125 oth=$7130
    db $19,$25,$42,$4B,$31,$71  ; v3: bank$25 blk$19 obj=$4B42 oth=$7131
Bank11_Area65_ObjLists:     ; $7105-$7146  compact 5-byte object records + "other" data
Bank11_Area65_Obj_7105:          ; $7105  (object list)
    db $00,$1C,$01,$04,$01   ; $7105 type0 face0 spr$1C (+1,+4) ev$01
    db $50,$21,$0A,$00,$FF   ; $710A type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $710F end
Bank11_Area65_Obj_7110:          ; $7110  (object list)
    db $00,$22,$04,$03,$02   ; $7110 type0 face0 spr$22 (+4,+3) ev$02
    db $50,$21,$0A,$00,$FF   ; $7115 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$FF,$04,$03,$02   ; $711A type0 face0 spr$FF (+4,+3) ev$02
    db $00,$FF,$05,$03,$02   ; $711F type0 face0 spr$FF (+5,+3) ev$02
    db $FF   ; $7124 end
Bank11_Area65_Obj_7125:          ; $7125  (object list)
    db $00,$3E,$07,$04,$03   ; $7125 type0 face0 spr$3E (+7,+4) ev$03
    db $50,$21,$0A,$00,$FF   ; $712A type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $712F end
Bank11_Area65_Obj_7130:          ; $7130  (object list)
    db $FF   ; $7130 end
Bank11_Area65_Obj_7131:          ; $7131  (object list)
    db $01,$02,$00,$00,$01   ; $7131 type1 face0 spr$02 (+0,+0) ev$01
    db $04,$05,$04,$02,$00   ; $7136 type4 face0 spr$05 (+4,+2) ev$00
    db $00,$01,$04,$05,$07   ; $713B type0 face0 spr$01 (+4,+5) ev$07
    db $02,$00,$00,$01,$04   ; $7140 type2 face0 spr$00 (+0,+1) ev$04
    db $05,$FF   ; $7145 (tail)

Bank11_Area66:              ; $7147  AreaDir[66]=area $42 (2-byte stub -> $714B)
    dw $714B

Bank11_Area96:              ; $7149  AreaDir[96]=area $60  (also areas 101, 102, 103 = $65, $66, $67)
    dw $7189,$D988,$2413,$7197,$73C3,$2413,$71C5,$7383   ; rooms 0-7
    dw $2413,$71F3,$7383,$2413,$7221,$7403,$2413,$724F   ; rooms 8-15
    dw $7383,$2413,$727D,$7443,$2413,$72AB,$7383,$2413   ; rooms 16-23
    dw $72D9,$7383,$2413,$7307,$7383,$2413,$7335,$7483   ; rooms 24-31
Bank11_Area96_Room0:        ; $7189  room(s) 0: sel + 2 variant(s)
    dw $D989   ; variant selector (WRAM)
    db $14,$24,$63,$73,$C3,$74  ; v0: bank$24 blk$14 obj=$7363 oth=$74C3
    db $14,$24,$78,$73,$C3,$74  ; v1: bank$24 blk$14 obj=$7378 oth=$74C3
Bank11_Area96_Room3:        ; $7197  room(s) 3: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$01,$90,$FF,$07,$07  ; v1: bank$01 blk$07 obj=$FF90 oth=$0707
    db $01,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$01 obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$04,$90,$FF  ; v4: bank$02 blk$FF obj=$0400 oth=$FF90
    db $07,$00,$04,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$9004 oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $71C3 (extra)
Bank11_Area96_Room6:        ; $71C5  room(s) 6: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$02,$90,$FF,$07,$07  ; v1: bank$02 blk$07 obj=$FF90 oth=$0707
    db $02,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$02 obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $71F1 (extra)
Bank11_Area96_Room9:        ; $71F3  room(s) 9: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$03,$90,$FF,$07,$07  ; v1: bank$03 blk$07 obj=$FF90 oth=$0707
    db $03,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$03 obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $721F (extra)
Bank11_Area96_Room12:       ; $7221  room(s) 12: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$0F,$90,$FF,$07,$07  ; v1: bank$0F blk$07 obj=$FF90 oth=$0707
    db $0F,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$0F obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$03,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$9003
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $724D (extra)
Bank11_Area96_Room15:       ; $724F  room(s) 15: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$0F,$90,$FF,$07,$07  ; v1: bank$0F blk$07 obj=$FF90 oth=$0707
    db $0F,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$0F obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$05,$90,$FF  ; v4: bank$02 blk$FF obj=$0500 oth=$FF90
    db $07,$00,$05,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$9005 oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $727B (extra)
Bank11_Area96_Room18:       ; $727D  room(s) 18: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$0F,$90,$FF,$07,$07  ; v1: bank$0F blk$07 obj=$FF90 oth=$0707
    db $0F,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$0F obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$06,$90,$FF  ; v4: bank$02 blk$FF obj=$0600 oth=$FF90
    db $07,$00,$06,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$9006 oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $05,$FF   ; $72A9 (extra)
Bank11_Area96_Room21:       ; $72AB  room(s) 21: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$0F,$90,$FF,$07,$07  ; v1: bank$0F blk$07 obj=$FF90 oth=$0707
    db $0F,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$0F obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$07,$90,$FF,$00,$05  ; v6: bank$07 blk$02 obj=$FF90 oth=$0500
    db $07,$FF   ; $72D7 (extra)
Bank11_Area96_Room24:       ; $72D9  room(s) 24: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$08,$90,$FF,$07,$07  ; v1: bank$08 blk$07 obj=$FF90 oth=$0707
    db $08,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$08 obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $7305 (extra)
Bank11_Area96_Room27:       ; $7307  room(s) 27: sel + 7 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$09,$90,$FF,$07,$07  ; v1: bank$09 blk$07 obj=$FF90 oth=$0707
    db $09,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$09 obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$0F,$90,$FF,$00,$05  ; v6: bank$0F blk$02 obj=$FF90 oth=$0500
    db $0F,$FF   ; $7333 (extra)
Bank11_Area96_Room30:       ; $7335  room(s) 30: sel + 12 variant(s)
    dw $FF90   ; variant selector (WRAM)
    db $04,$04,$0F,$90,$FF,$02  ; v0: bank$04 blk$04 obj=$900F oth=$02FF
    db $07,$0F,$90,$FF,$07,$07  ; v1: bank$0F blk$07 obj=$FF90 oth=$0707
    db $0F,$90,$FF,$09,$02,$0F  ; v2: bank$90 blk$0F obj=$09FF oth=$0F02
    db $90,$FF,$09,$05,$0F,$90  ; v3: bank$FF blk$90 obj=$0509 oth=$900F
    db $FF,$02,$00,$0F,$90,$FF  ; v4: bank$02 blk$FF obj=$0F00 oth=$FF90
    db $07,$00,$0F,$90,$FF,$00  ; v5: bank$00 blk$07 obj=$900F oth=$00FF
    db $02,$09,$90,$FF,$00,$05  ; v6: bank$09 blk$02 obj=$FF90 oth=$0500
    db $0F,$FF,$8F,$FF,$03,$02  ; v7: bank$FF blk$0F obj=$FF8F oth=$0203
    db $10,$8F,$FF,$03,$05,$12  ; v8: bank$8F blk$10 obj=$03FF oth=$1205
    db $00,$1A,$06,$02,$11,$70  ; v9: bank$1A blk$00 obj=$0206 oth=$7011
    db $21,$00,$01,$FF,$FF,$8F  ; v10: bank$00 blk$21 obj=$FF01 oth=$8FFF
    db $FF,$03,$02,$10,$8F,$FF  ; v11: bank$03 blk$FF obj=$1002 oth=$FF8F
    db $03,$05,$12,$FF   ; $737F (extra)
Bank11_Area96_Room7:        ; $7383  room(s) 7,10,16,22,25,28: sel + 10 variant(s)
    dw $0505   ; variant selector (WRAM)
    db $00,$00,$01,$04,$05,$02  ; v0: bank$00 blk$00 obj=$0401 oth=$0205
    db $00,$42,$00,$00,$02,$07  ; v1: bank$42 blk$00 obj=$0000 oth=$0702
    db $07,$00,$42,$00,$00,$07  ; v2: bank$00 blk$07 obj=$0042 oth=$0700
    db $07,$00,$02,$42,$00,$00  ; v3: bank$00 blk$07 obj=$4202 oth=$0000
    db $09,$02,$00,$05,$42,$00  ; v4: bank$02 blk$09 obj=$0500 oth=$0042
    db $00,$09,$05,$02,$07,$42  ; v5: bank$09 blk$00 obj=$0205 oth=$4207
    db $00,$00,$02,$00,$07,$07  ; v6: bank$00 blk$00 obj=$0002 oth=$0707
    db $42,$00,$00,$07,$00,$09  ; v7: bank$00 blk$42 obj=$0700 oth=$0900
    db $02,$42,$00,$00,$00,$02  ; v8: bank$42 blk$02 obj=$0000 oth=$0200
    db $09,$05,$42,$00,$00,$00  ; v9: bank$05 blk$09 obj=$0042 oth=$0000
    db $05,$FF   ; $73C1 (extra)
Bank11_Area96_Room4:        ; $73C3  room(s) 4: sel + 10 variant(s)
    dw $0505   ; variant selector (WRAM)
    db $00,$00,$01,$04,$05,$02  ; v0: bank$00 blk$00 obj=$0401 oth=$0205
    db $00,$42,$00,$00,$02,$07  ; v1: bank$42 blk$00 obj=$0000 oth=$0702
    db $07,$00,$42,$00,$00,$07  ; v2: bank$00 blk$07 obj=$0042 oth=$0700
    db $07,$00,$02,$42,$00,$00  ; v3: bank$00 blk$07 obj=$4202 oth=$0000
    db $09,$02,$00,$05,$42,$00  ; v4: bank$02 blk$09 obj=$0500 oth=$0042
    db $00,$09,$05,$02,$07,$42  ; v5: bank$09 blk$00 obj=$0205 oth=$4207
    db $00,$00,$02,$00,$07,$07  ; v6: bank$00 blk$00 obj=$0002 oth=$0707
    db $42,$00,$00,$07,$00,$09  ; v7: bank$00 blk$42 obj=$0700 oth=$0900
    db $02,$60,$00,$00,$00,$02  ; v8: bank$60 blk$02 obj=$0000 oth=$0200
    db $09,$05,$42,$00,$00,$00  ; v9: bank$05 blk$09 obj=$0042 oth=$0000
    db $05,$FF   ; $7401 (extra)
Bank11_Area96_Room13:       ; $7403  room(s) 13: sel + 10 variant(s)
    dw $0505   ; variant selector (WRAM)
    db $00,$00,$01,$04,$05,$02  ; v0: bank$00 blk$00 obj=$0401 oth=$0205
    db $00,$42,$00,$00,$02,$07  ; v1: bank$42 blk$00 obj=$0000 oth=$0702
    db $07,$00,$42,$00,$00,$07  ; v2: bank$00 blk$07 obj=$0042 oth=$0700
    db $07,$00,$02,$42,$00,$00  ; v3: bank$00 blk$07 obj=$4202 oth=$0000
    db $09,$02,$00,$05,$42,$00  ; v4: bank$02 blk$09 obj=$0500 oth=$0042
    db $00,$09,$05,$02,$07,$42  ; v5: bank$09 blk$00 obj=$0205 oth=$4207
    db $00,$00,$02,$00,$07,$07  ; v6: bank$00 blk$00 obj=$0002 oth=$0707
    db $42,$00,$00,$07,$00,$09  ; v7: bank$00 blk$42 obj=$0700 oth=$0900
    db $02,$42,$00,$00,$00,$02  ; v8: bank$42 blk$02 obj=$0000 oth=$0200
    db $09,$05,$60,$00,$00,$00  ; v9: bank$05 blk$09 obj=$0060 oth=$0000
    db $05,$FF   ; $7441 (extra)
Bank11_Area96_Room19:       ; $7443  room(s) 19: sel + 10 variant(s)
    dw $0505   ; variant selector (WRAM)
    db $00,$00,$01,$04,$05,$02  ; v0: bank$00 blk$00 obj=$0401 oth=$0205
    db $00,$42,$00,$00,$02,$07  ; v1: bank$42 blk$00 obj=$0000 oth=$0702
    db $07,$00,$42,$00,$00,$07  ; v2: bank$00 blk$07 obj=$0042 oth=$0700
    db $07,$00,$02,$42,$00,$00  ; v3: bank$00 blk$07 obj=$4202 oth=$0000
    db $09,$02,$00,$05,$60,$00  ; v4: bank$02 blk$09 obj=$0500 oth=$0060
    db $00,$09,$05,$02,$07,$42  ; v5: bank$09 blk$00 obj=$0205 oth=$4207
    db $00,$00,$02,$00,$07,$07  ; v6: bank$00 blk$00 obj=$0002 oth=$0707
    db $42,$00,$00,$07,$00,$09  ; v7: bank$00 blk$42 obj=$0700 oth=$0900
    db $02,$42,$00,$00,$00,$02  ; v8: bank$42 blk$02 obj=$0000 oth=$0200
    db $09,$05,$42,$00,$00,$00  ; v9: bank$05 blk$09 obj=$0042 oth=$0000
    db $05,$FF   ; $7481 (extra)
Bank11_Area96_Room31:       ; $7483  room(s) 31: sel + 0 variant(s)
    dw $0505   ; variant selector (WRAM)
Bank11_Area96_ObjLists:     ; $7485-$74DF  compact 5-byte object records + "other" data
Bank11_Area96_Obj_7485:          ; $7485  (object list)
    db $00,$00,$01,$04,$05   ; $7485 type0 face0 spr$00 (+1,+4) ev$05
    db $02,$00,$42,$00,$00   ; $748A type2 face0 spr$00 (+66,+0) ev$00
    db $02,$07,$07,$00,$42   ; $748F type2 face0 spr$07 (+7,+0) ev$42
    db $00,$00,$07,$07,$00   ; $7494 type0 face0 spr$00 (+7,+7) ev$00
    db $02,$60,$00,$00,$09   ; $7499 type2 face0 spr$60 (+0,+0) ev$09
    db $02,$00,$05,$42,$00   ; $749E type2 face0 spr$00 (+5,+66) ev$00
    db $00,$09,$05,$02,$07   ; $74A3 type0 face0 spr$09 (+5,+2) ev$07
    db $42,$00,$00,$02,$00   ; $74A8 type2 face4 spr$00 (+0,+2) ev$00
    db $07,$07,$42,$00,$00   ; $74AD type7 face0 spr$07 (+66,+0) ev$00
    db $07,$00,$09,$02,$42   ; $74B2 type7 face0 spr$00 (+9,+2) ev$42
    db $00,$00,$00,$02,$09   ; $74B7 type0 face0 spr$00 (+0,+2) ev$09
    db $05,$42,$00,$00,$00   ; $74BC type5 face0 spr$42 (+0,+0) ev$00
    db $05,$FF,$00,$02,$42   ; $74C1 type5 face0 spr$FF (+0,+2) ev$42
    db $00,$00,$09,$02,$00   ; $74C6 type0 face0 spr$00 (+9,+2) ev$00
    db $05,$42,$00,$00,$09   ; $74CB type5 face0 spr$42 (+0,+0) ev$09
    db $05,$09,$02,$42,$00   ; $74D0 type5 face0 spr$09 (+2,+66) ev$00
    db $00,$00,$02,$09,$05   ; $74D5 type0 face0 spr$00 (+2,+9) ev$05
    db $42,$00,$00,$00,$05   ; $74DA type2 face4 spr$00 (+0,+0) ev$05
    db $FF   ; $74DF end

Bank11_Area67:              ; $74E0  AreaDir[67]=area $43
    dw $74E2   ; rooms 0-0
Bank11_Area67_Room0:        ; $74E2  room(s) 0: sel + 2 variant(s)
    dw $D98A   ; variant selector (WRAM)
    db $10,$24,$F0,$74,$1A,$75  ; v0: bank$24 blk$10 obj=$74F0 oth=$751A
    db $11,$24,$0F,$75,$1B,$75  ; v1: bank$24 blk$11 obj=$750F oth=$751B
Bank11_Area67_ObjLists:     ; $74F0-$7522  compact 5-byte object records + "other" data
Bank11_Area67_Obj_74F0:          ; $74F0  (object list)
    db $82,$FF,$07,$05,$01   ; $74F0 HEADER(bit7)
    db $82,$FF,$08,$05,$01   ; $74F5 HEADER(bit7)
    db $50,$21,$0A,$01,$FF   ; $74FA type0 face5 spr$21 (+10,+1) ev$FF
    db $06,$27,$04,$02,$02   ; $74FF type6 face0 spr$27 (+4,+2) ev$02
    db $00,$FF,$04,$02,$02   ; $7504 type0 face0 spr$FF (+4,+2) ev$02
    db $00,$FF,$05,$02,$02   ; $7509 type0 face0 spr$FF (+5,+2) ev$02
    db $FF   ; $750E end
Bank11_Area67_Obj_750F:          ; $750F  (object list)
    db $82,$FF,$07,$05,$01   ; $750F HEADER(bit7)
    db $82,$FF,$08,$05,$01   ; $7514 HEADER(bit7)
    db $FF   ; $7519 end
Bank11_Area67_Obj_751A:          ; $751A  (object list)
    db $FF   ; $751A end
Bank11_Area67_Obj_751B:          ; $751B  (object list)
    db $02,$05,$00,$00,$01   ; $751B type2 face0 spr$05 (+0,+0) ev$01
    db $04,$05,$FF   ; $7520 (tail)

Bank11_Area68:              ; $7523  AreaDir[68]=area $44
    dw $7525   ; rooms 0-0
Bank11_Area68_Room0:        ; $7525  room(s) 0: sel + 2 variant(s)
    dw $D98B   ; variant selector (WRAM)
    db $19,$24,$33,$75,$5D,$75  ; v0: bank$24 blk$19 obj=$7533 oth=$755D
    db $1A,$24,$5C,$75,$5E,$75  ; v1: bank$24 blk$1A obj=$755C oth=$755E
Bank11_Area68_ObjLists:     ; $7533-$7565  compact 5-byte object records + "other" data
Bank11_Area68_Obj_7533:          ; $7533  (object list)
    db $60,$15,$00,$07,$02   ; $7533 type0 face6 spr$15 (+0,+7) ev$02
    db $50,$21,$0A,$01,$FF   ; $7538 type0 face5 spr$21 (+10,+1) ev$FF
    db $00,$24,$05,$02,$01   ; $753D type0 face0 spr$24 (+5,+2) ev$01
    db $60,$E0,$05,$03,$FF   ; $7542 type0 face6 spr$E0 (+5,+3) ev$FF
    db $60,$E1,$05,$04,$FF   ; $7547 type0 face6 spr$E1 (+5,+4) ev$FF
    db $60,$E2,$05,$04,$FF   ; $754C type0 face6 spr$E2 (+5,+4) ev$FF
    db $60,$E3,$05,$04,$FF   ; $7551 type0 face6 spr$E3 (+5,+4) ev$FF
    db $00,$FF,$06,$02,$01   ; $7556 type0 face0 spr$FF (+6,+2) ev$01
    db $FF   ; $755B end
Bank11_Area68_Obj_755C:          ; $755C  (object list)
    db $FF   ; $755C end
Bank11_Area68_Obj_755D:          ; $755D  (object list)
    db $FF   ; $755D end
Bank11_Area68_Obj_755E:          ; $755E  (object list)
    db $06,$01,$00,$00,$01   ; $755E type6 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $7563 (tail)

Bank11_Area69:              ; $7566  AreaDir[69]=area $45
    dw $7568   ; rooms 0-0
Bank11_Area69_Room0:        ; $7568  room(s) 0: sel + 3 variant(s)
    dw $D98C   ; variant selector (WRAM)
    db $0A,$24,$7C,$75,$C5,$75  ; v0: bank$24 blk$0A obj=$757C oth=$75C5
    db $0B,$24,$C4,$75,$C6,$75  ; v1: bank$24 blk$0B obj=$75C4 oth=$75C6
    db $0A,$24,$A0,$75,$C5,$75  ; v2: bank$24 blk$0A obj=$75A0 oth=$75C5
Bank11_Area69_ObjLists:     ; $757C-$75CD  compact 5-byte object records + "other" data
Bank11_Area69_Obj_757C:          ; $757C  (object list)
    db $20,$E0,$04,$07,$FF   ; $757C type0 face2 spr$E0 (+4,+7) ev$FF
    db $40,$2B,$04,$06,$FF   ; $7581 type0 face4 spr$2B (+4,+6) ev$FF
    db $40,$2B,$05,$06,$FF   ; $7586 type0 face4 spr$2B (+5,+6) ev$FF
    db $40,$15,$04,$06,$FF   ; $758B type0 face4 spr$15 (+4,+6) ev$FF
    db $40,$39,$04,$00,$FF   ; $7590 type0 face4 spr$39 (+4,+0) ev$FF
    db $50,$21,$0A,$01,$FF   ; $7595 type0 face5 spr$21 (+10,+1) ev$FF
    db $00,$29,$04,$05,$FF   ; $759A type0 face0 spr$29 (+4,+5) ev$FF
    db $FF   ; $759F end
Bank11_Area69_Obj_75A0:          ; $75A0  (object list)
    db $20,$E0,$04,$07,$FF   ; $75A0 type0 face2 spr$E0 (+4,+7) ev$FF
    db $40,$2B,$04,$06,$FF   ; $75A5 type0 face4 spr$2B (+4,+6) ev$FF
    db $40,$2B,$05,$06,$FF   ; $75AA type0 face4 spr$2B (+5,+6) ev$FF
    db $20,$15,$03,$04,$FF   ; $75AF type0 face2 spr$15 (+3,+4) ev$FF
    db $40,$39,$04,$00,$FF   ; $75B4 type0 face4 spr$39 (+4,+0) ev$FF
    db $50,$21,$0A,$01,$FF   ; $75B9 type0 face5 spr$21 (+10,+1) ev$FF
    db $00,$29,$04,$05,$FF   ; $75BE type0 face0 spr$29 (+4,+5) ev$FF
    db $FF   ; $75C3 end
Bank11_Area69_Obj_75C4:          ; $75C4  (object list)
    db $FF   ; $75C4 end
Bank11_Area69_Obj_75C5:          ; $75C5  (object list)
    db $FF   ; $75C5 end
Bank11_Area69_Obj_75C6:          ; $75C6  (object list)
    db $05,$05,$00,$00,$01   ; $75C6 type5 face0 spr$05 (+0,+0) ev$01
    db $04,$05,$FF   ; $75CB (tail)

Bank11_Area70:              ; $75CE  AreaDir[70]=area $46
    dw $75D0   ; rooms 0-0
Bank11_Area70_Room0:        ; $75D0  room(s) 0: sel + 2 variant(s)
    dw $D98D   ; variant selector (WRAM)
    db $01,$23,$DE,$75,$F4,$75  ; v0: bank$23 blk$01 obj=$75DE oth=$75F4
    db $02,$23,$F3,$75,$F5,$75  ; v1: bank$23 blk$02 obj=$75F3 oth=$75F5
Bank11_Area70_ObjLists:     ; $75DE-$75FC  compact 5-byte object records + "other" data
Bank11_Area70_Obj_75DE:          ; $75DE  (object list)
    db $50,$21,$0A,$00,$FF   ; $75DE type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$2D,$04,$03,$01   ; $75E3 type0 face0 spr$2D (+4,+3) ev$01
    db $00,$FF,$04,$03,$01   ; $75E8 type0 face0 spr$FF (+4,+3) ev$01
    db $00,$FF,$05,$03,$01   ; $75ED type0 face0 spr$FF (+5,+3) ev$01
    db $FF   ; $75F2 end
Bank11_Area70_Obj_75F3:          ; $75F3  (object list)
    db $FF   ; $75F3 end
Bank11_Area70_Obj_75F4:          ; $75F4  (object list)
    db $FF   ; $75F4 end
Bank11_Area70_Obj_75F5:          ; $75F5  (object list)
    db $02,$04,$00,$00,$01   ; $75F5 type2 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $75FA (tail)

Bank11_Area71:              ; $75FD  AreaDir[71]=area $47
    dw $75FF   ; rooms 0-0
Bank11_Area71_Room0:        ; $75FF  room(s) 0: sel + 3 variant(s)
    dw $D98E   ; variant selector (WRAM)
    db $1C,$24,$13,$76,$3E,$76  ; v0: bank$24 blk$1C obj=$7613 oth=$763E
    db $1C,$24,$28,$76,$3F,$76  ; v1: bank$24 blk$1C obj=$7628 oth=$763F
    db $1D,$24,$3D,$76,$40,$76  ; v2: bank$24 blk$1D obj=$763D oth=$7640
Bank11_Area71_ObjLists:     ; $7613-$7647  compact 5-byte object records + "other" data
Bank11_Area71_Obj_7613:          ; $7613  (object list)
    db $50,$21,$0A,$00,$FF   ; $7613 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$2E,$04,$03,$01   ; $7618 type0 face0 spr$2E (+4,+3) ev$01
    db $00,$FF,$05,$03,$01   ; $761D type0 face0 spr$FF (+5,+3) ev$01
    db $00,$FF,$04,$03,$01   ; $7622 type0 face0 spr$FF (+4,+3) ev$01
    db $FF   ; $7627 end
Bank11_Area71_Obj_7628:          ; $7628  (object list)
    db $50,$21,$0A,$00,$FF   ; $7628 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$2F,$04,$03,$02   ; $762D type0 face0 spr$2F (+4,+3) ev$02
    db $00,$FF,$05,$03,$02   ; $7632 type0 face0 spr$FF (+5,+3) ev$02
    db $00,$FF,$04,$03,$02   ; $7637 type0 face0 spr$FF (+4,+3) ev$02
    db $FF   ; $763C end
Bank11_Area71_Obj_763D:          ; $763D  (object list)
    db $FF   ; $763D end
Bank11_Area71_Obj_763E:          ; $763E  (object list)
    db $FF   ; $763E end
Bank11_Area71_Obj_763F:          ; $763F  (object list)
    db $FF   ; $763F end
Bank11_Area71_Obj_7640:          ; $7640  (object list)
    db $03,$04,$00,$00,$01   ; $7640 type3 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $7645 (tail)

Bank11_Area72:              ; $7648  AreaDir[72]=area $48
    dw $764A   ; rooms 0-0
Bank11_Area72_Room0:        ; $764A  room(s) 0: sel + 2 variant(s)
    dw $D98F   ; variant selector (WRAM)
    db $0D,$24,$58,$76,$6E,$76  ; v0: bank$24 blk$0D obj=$7658 oth=$766E
    db $0E,$24,$6D,$76,$6F,$76  ; v1: bank$24 blk$0E obj=$766D oth=$766F
Bank11_Area72_ObjLists:     ; $7658-$7676  compact 5-byte object records + "other" data
Bank11_Area72_Obj_7658:          ; $7658  (object list)
    db $50,$21,$0A,$00,$FF   ; $7658 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$30,$04,$01,$01   ; $765D type0 face0 spr$30 (+4,+1) ev$01
    db $00,$FF,$04,$01,$01   ; $7662 type0 face0 spr$FF (+4,+1) ev$01
    db $00,$FF,$05,$01,$01   ; $7667 type0 face0 spr$FF (+5,+1) ev$01
    db $FF   ; $766C end
Bank11_Area72_Obj_766D:          ; $766D  (object list)
    db $FF   ; $766D end
Bank11_Area72_Obj_766E:          ; $766E  (object list)
    db $FF   ; $766E end
Bank11_Area72_Obj_766F:          ; $766F  (object list)
    db $04,$01,$00,$00,$01   ; $766F type4 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $7674 (tail)

Bank11_Area73:              ; $7677  AreaDir[73]=area $49
    dw $7679   ; rooms 0-0
Bank11_Area73_Room0:        ; $7679  room(s) 0: sel + 2 variant(s)
    dw $D990   ; variant selector (WRAM)
    db $0C,$25,$87,$76,$9D,$76  ; v0: bank$25 blk$0C obj=$7687 oth=$769D
    db $0D,$25,$9C,$76,$9E,$76  ; v1: bank$25 blk$0D obj=$769C oth=$769E
Bank11_Area73_ObjLists:     ; $7687-$76A5  compact 5-byte object records + "other" data
Bank11_Area73_Obj_7687:          ; $7687  (object list)
    db $50,$21,$0A,$00,$FF   ; $7687 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$31,$04,$02,$01   ; $768C type0 face0 spr$31 (+4,+2) ev$01
    db $00,$FF,$04,$02,$01   ; $7691 type0 face0 spr$FF (+4,+2) ev$01
    db $00,$FF,$05,$02,$01   ; $7696 type0 face0 spr$FF (+5,+2) ev$01
    db $FF   ; $769B end
Bank11_Area73_Obj_769C:          ; $769C  (object list)
    db $FF   ; $769C end
Bank11_Area73_Obj_769D:          ; $769D  (object list)
    db $FF   ; $769D end
Bank11_Area73_Obj_769E:          ; $769E  (object list)
    db $02,$04,$00,$00,$01   ; $769E type2 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $76A3 (tail)

Bank11_Area74:              ; $76A6  AreaDir[74]=area $4A
    dw $76A8   ; rooms 0-0
Bank11_Area74_Room0:        ; $76A8  room(s) 0: sel + 2 variant(s)
    dw $D991   ; variant selector (WRAM)
    db $0B,$23,$B6,$76,$CC,$76  ; v0: bank$23 blk$0B obj=$76B6 oth=$76CC
    db $0C,$23,$CB,$76,$CD,$76  ; v1: bank$23 blk$0C obj=$76CB oth=$76CD
Bank11_Area74_ObjLists:     ; $76B6-$76D4  compact 5-byte object records + "other" data
Bank11_Area74_Obj_76B6:          ; $76B6  (object list)
    db $50,$21,$0A,$00,$FF   ; $76B6 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$32,$04,$01,$01   ; $76BB type0 face0 spr$32 (+4,+1) ev$01
    db $00,$FF,$04,$01,$01   ; $76C0 type0 face0 spr$FF (+4,+1) ev$01
    db $00,$FF,$05,$01,$01   ; $76C5 type0 face0 spr$FF (+5,+1) ev$01
    db $FF   ; $76CA end
Bank11_Area74_Obj_76CB:          ; $76CB  (object list)
    db $FF   ; $76CB end
Bank11_Area74_Obj_76CC:          ; $76CC  (object list)
    db $FF   ; $76CC end
Bank11_Area74_Obj_76CD:          ; $76CD  (object list)
    db $05,$03,$00,$00,$01   ; $76CD type5 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $76D2 (tail)

Bank11_Area75:              ; $76D5  AreaDir[75]=area $4B
    dw $76D7   ; rooms 0-0
Bank11_Area75_Room0:        ; $76D7  room(s) 0: sel + 2 variant(s)
    dw $D992   ; variant selector (WRAM)
    db $0E,$23,$E5,$76,$FB,$76  ; v0: bank$23 blk$0E obj=$76E5 oth=$76FB
    db $0F,$23,$FA,$76,$FC,$76  ; v1: bank$23 blk$0F obj=$76FA oth=$76FC
Bank11_Area75_ObjLists:     ; $76E5-$7703  compact 5-byte object records + "other" data
Bank11_Area75_Obj_76E5:          ; $76E5  (object list)
    db $50,$21,$0A,$00,$FF   ; $76E5 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$33,$04,$01,$01   ; $76EA type0 face0 spr$33 (+4,+1) ev$01
    db $00,$FF,$04,$01,$01   ; $76EF type0 face0 spr$FF (+4,+1) ev$01
    db $00,$FF,$05,$01,$01   ; $76F4 type0 face0 spr$FF (+5,+1) ev$01
    db $FF   ; $76F9 end
Bank11_Area75_Obj_76FA:          ; $76FA  (object list)
    db $FF   ; $76FA end
Bank11_Area75_Obj_76FB:          ; $76FB  (object list)
    db $FF   ; $76FB end
Bank11_Area75_Obj_76FC:          ; $76FC  (object list)
    db $04,$03,$00,$00,$01   ; $76FC type4 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $7701 (tail)

Bank11_Area76:              ; $7704  AreaDir[76]=area $4C
    dw $7706   ; rooms 0-0
Bank11_Area76_Room0:        ; $7706  room(s) 0: sel + 2 variant(s)
    dw $D993   ; variant selector (WRAM)
    db $11,$23,$14,$77,$2A,$77  ; v0: bank$23 blk$11 obj=$7714 oth=$772A
    db $12,$23,$29,$77,$2B,$77  ; v1: bank$23 blk$12 obj=$7729 oth=$772B
Bank11_Area76_ObjLists:     ; $7714-$7732  compact 5-byte object records + "other" data
Bank11_Area76_Obj_7714:          ; $7714  (object list)
    db $50,$21,$0A,$02,$FF   ; $7714 type0 face5 spr$21 (+10,+2) ev$FF
    db $00,$34,$04,$02,$01   ; $7719 type0 face0 spr$34 (+4,+2) ev$01
    db $00,$FF,$04,$03,$01   ; $771E type0 face0 spr$FF (+4,+3) ev$01
    db $00,$FF,$05,$03,$01   ; $7723 type0 face0 spr$FF (+5,+3) ev$01
    db $FF   ; $7728 end
Bank11_Area76_Obj_7729:          ; $7729  (object list)
    db $FF   ; $7729 end
Bank11_Area76_Obj_772A:          ; $772A  (object list)
    db $FF   ; $772A end
Bank11_Area76_Obj_772B:          ; $772B  (object list)
    db $04,$04,$00,$00,$01   ; $772B type4 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $7730 (tail)

Bank11_Area77:              ; $7733  AreaDir[77]=area $4D
    dw $7735   ; rooms 0-0
Bank11_Area77_Room0:        ; $7735  room(s) 0: sel + 2 variant(s)
    dw $D994   ; variant selector (WRAM)
    db $0F,$25,$43,$77,$59,$77  ; v0: bank$25 blk$0F obj=$7743 oth=$7759
    db $10,$25,$58,$77,$5A,$77  ; v1: bank$25 blk$10 obj=$7758 oth=$775A
Bank11_Area77_ObjLists:     ; $7743-$7761  compact 5-byte object records + "other" data
Bank11_Area77_Obj_7743:          ; $7743  (object list)
    db $50,$21,$0A,$00,$FF   ; $7743 type0 face5 spr$21 (+10,+0) ev$FF
    db $00,$35,$04,$01,$01   ; $7748 type0 face0 spr$35 (+4,+1) ev$01
    db $00,$FF,$04,$01,$01   ; $774D type0 face0 spr$FF (+4,+1) ev$01
    db $00,$FF,$05,$01,$01   ; $7752 type0 face0 spr$FF (+5,+1) ev$01
    db $FF   ; $7757 end
Bank11_Area77_Obj_7758:          ; $7758  (object list)
    db $FF   ; $7758 end
Bank11_Area77_Obj_7759:          ; $7759  (object list)
    db $FF   ; $7759 end
Bank11_Area77_Obj_775A:          ; $775A  (object list)
    db $03,$03,$00,$00,$01   ; $775A type3 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $775F (tail)

Bank11_Area78:              ; $7762  AreaDir[78]=area $4E
    dw $7772,$FFFF,$FFFF,$FFFF,$7780,$FFFF,$FFFF,$FFFF   ; rooms 0-7
Bank11_Area78_Room0:        ; $7772  room(s) 0: sel + 2 variant(s)
    dw $D995   ; variant selector (WRAM)
    db $12,$25,$88,$77,$A4,$77  ; v0: bank$25 blk$12 obj=$7788 oth=$77A4
    db $13,$25,$A2,$77,$A5,$77  ; v1: bank$25 blk$13 obj=$77A2 oth=$77A5
Bank11_Area78_Room4:        ; $7780  room(s) 4: sel + 1 variant(s)
    dw $D996   ; variant selector (WRAM)
    db $14,$25,$A3,$77,$AD,$77  ; v0: bank$25 blk$14 obj=$77A3 oth=$77AD
Bank11_Area78_ObjLists:     ; $7788-$77AD  compact 5-byte object records + "other" data
Bank11_Area78_Obj_7788:          ; $7788  (object list)
    db $50,$21,$0A,$01,$FF   ; $7788 type0 face5 spr$21 (+10,+1) ev$FF
    db $0A,$36,$04,$02,$01   ; $778D type10 face0 spr$36 (+4,+2) ev$01
    db $00,$FF,$03,$03,$01   ; $7792 type0 face0 spr$FF (+3,+3) ev$01
    db $00,$FF,$04,$03,$01   ; $7797 type0 face0 spr$FF (+4,+3) ev$01
    db $00,$FF,$05,$03,$01   ; $779C type0 face0 spr$FF (+5,+3) ev$01
    db $FF   ; $77A1 end
Bank11_Area78_Obj_77A2:          ; $77A2  (object list)
    db $FF   ; $77A2 end
Bank11_Area78_Obj_77A3:          ; $77A3  (object list)
    db $FF   ; $77A3 end
Bank11_Area78_Obj_77A4:          ; $77A4  (object list)
    db $FF   ; $77A4 end
Bank11_Area78_Obj_77A5:          ; $77A5  (object list)
    db $04,$04,$00,$00,$01   ; $77A5 type4 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF,$FF   ; $77AA (tail)

Bank11_Area79:              ; $77AE  AreaDir[79]=area $4F
    dw $77B0   ; rooms 0-0
Bank11_Area79_Room0:        ; $77B0  room(s) 0: sel + 2 variant(s)
    dw $D997   ; variant selector (WRAM)
    db $04,$24,$BE,$77,$D9,$77  ; v0: bank$24 blk$04 obj=$77BE oth=$77D9
    db $05,$24,$D8,$77,$DA,$77  ; v1: bank$24 blk$05 obj=$77D8 oth=$77DA
Bank11_Area79_ObjLists:     ; $77BE-$77E1  compact 5-byte object records + "other" data
Bank11_Area79_Obj_77BE:          ; $77BE  (object list)
    db $90,$FF,$04,$04,$01   ; $77BE HEADER(bit7)
    db $90,$FF,$05,$04,$01   ; $77C3 HEADER(bit7)
    db $40,$37,$04,$03,$02   ; $77C8 type0 face4 spr$37 (+4,+3) ev$02
    db $40,$FF,$04,$03,$02   ; $77CD type0 face4 spr$FF (+4,+3) ev$02
    db $40,$FF,$05,$03,$02   ; $77D2 type0 face4 spr$FF (+5,+3) ev$02
    db $FF   ; $77D7 end
Bank11_Area79_Obj_77D8:          ; $77D8  (object list)
    db $FF   ; $77D8 end
Bank11_Area79_Obj_77D9:          ; $77D9  (object list)
    db $FF   ; $77D9 end
Bank11_Area79_Obj_77DA:          ; $77DA  (object list)
    db $03,$05,$00,$00,$01   ; $77DA type3 face0 spr$05 (+0,+0) ev$01
    db $04,$05,$FF   ; $77DF (tail)

Bank11_Area80:              ; $77E2  AreaDir[80]=area $50  (also areas 95 = $5F)
    dw $77E4   ; rooms 0-0
Bank11_Area80_Room0:        ; $77E4  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $01,$26,$EC,$77,$F7,$77  ; v0: bank$26 blk$01 obj=$77EC oth=$77F7
Bank11_Area80_ObjLists:     ; $77EC-$77FE  compact 5-byte object records + "other" data
Bank11_Area80_Obj_77EC:          ; $77EC  (object list)
    db $8F,$FF,$04,$03,$01   ; $77EC HEADER(bit7)
    db $00,$06,$04,$02,$01   ; $77F1 type0 face0 spr$06 (+4,+2) ev$01
    db $FF   ; $77F6 end
Bank11_Area80_Obj_77F7:          ; $77F7  (object list)
    db $01,$06,$00,$80,$00   ; $77F7 type1 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF   ; $77FC (tail)

Bank11_Area81:              ; $77FF  AreaDir[81]=area $51
    dw $7801   ; rooms 0-0
Bank11_Area81_Room0:        ; $7801  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $03,$26,$09,$78,$14,$78  ; v0: bank$26 blk$03 obj=$7809 oth=$7814
Bank11_Area81_ObjLists:     ; $7809-$781B  compact 5-byte object records + "other" data
Bank11_Area81_Obj_7809:          ; $7809  (object list)
    db $82,$FF,$04,$03,$02   ; $7809 HEADER(bit7)
    db $00,$11,$04,$02,$01   ; $780E type0 face0 spr$11 (+4,+2) ev$01
    db $FF   ; $7813 end
Bank11_Area81_Obj_7814:          ; $7814  (object list)
    db $08,$02,$00,$80,$00   ; $7814 type8 face0 spr$02 (+0,+128) ev$00
    db $00,$00,$FF   ; $7819 (tail)

Bank11_Area82:              ; $781C  AreaDir[82]=area $52
    dw $781E   ; rooms 0-0
Bank11_Area82_Room0:        ; $781E  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $05,$26,$26,$78,$4F,$78  ; v0: bank$26 blk$05 obj=$7826 oth=$784F
Bank11_Area82_ObjLists:     ; $7826-$784F  compact 5-byte object records + "other" data
Bank11_Area82_Obj_7826:          ; $7826  (object list)
    db $00,$0B,$04,$03,$FF   ; $7826 type0 face0 spr$0B (+4,+3) ev$FF
    db $00,$F0,$03,$03,$FF   ; $782B type0 face0 spr$F0 (+3,+3) ev$FF
    db $00,$F1,$05,$03,$FF   ; $7830 type0 face0 spr$F1 (+5,+3) ev$FF
    db $00,$F2,$06,$03,$FF   ; $7835 type0 face0 spr$F2 (+6,+3) ev$FF
    db $20,$E1,$05,$05,$FF   ; $783A type0 face2 spr$E1 (+5,+5) ev$FF
    db $20,$E2,$03,$05,$FF   ; $783F type0 face2 spr$E2 (+3,+5) ev$FF
    db $20,$E3,$06,$05,$FF   ; $7844 type0 face2 spr$E3 (+6,+5) ev$FF
    db $20,$E0,$04,$05,$FF   ; $7849 type0 face2 spr$E0 (+4,+5) ev$FF
    db $FF   ; $784E end
Bank11_Area82_Obj_784F:          ; $784F  (object list)
    db $FF   ; $784F end

Bank11_Area83:              ; $7850  AreaDir[83]=area $53 (2-byte stub -> $785A)
    dw $785A

Bank11_Area97:              ; $7852  AreaDir[97]=area $61 (2-byte stub -> $7862)
    dw $7862

Bank11_Area98:              ; $7854  AreaDir[98]=area $62 (2-byte stub -> $786A)
    dw $786A

Bank11_Area99:              ; $7856  AreaDir[99]=area $63 (2-byte stub -> $7872)
    dw $7872

Bank11_Area100:             ; $7858-$790C  AreaDir[100]=area $64  (non-standard descriptor -> raw db)
    db $7A,$78,$98,$D9,$19,$23,$82,$78   ; $7858
    db $83,$78,$98,$D9,$1A,$23,$82,$78   ; $7860
    db $A0,$78,$98,$D9,$1B,$23,$82,$78   ; $7868
    db $BD,$78,$98,$D9,$1C,$23,$82,$78   ; $7870
    db $D3,$78,$98,$D9,$1D,$23,$82,$78   ; $7878
    db $FE,$78,$FF,$00,$03,$62,$00,$00   ; $7880
    db $09,$03,$01,$00,$61,$00,$00,$01   ; $7888
    db $07,$08,$00,$63,$00,$00,$08,$07   ; $7890
    db $09,$03,$61,$00,$00,$00,$03,$FF   ; $7898
    db $01,$07,$53,$00,$00,$01,$00,$08   ; $78A0
    db $07,$53,$00,$00,$08,$00,$00,$03   ; $78A8
    db $53,$00,$00,$09,$03,$01,$00,$62   ; $78B0
    db $00,$00,$01,$07,$FF,$01,$07,$61   ; $78B8
    db $00,$00,$01,$00,$08,$00,$61,$00   ; $78C0
    db $00,$08,$07,$09,$03,$53,$00,$00   ; $78C8
    db $00,$03,$FF,$08,$07,$62,$00,$00   ; $78D0
    db $08,$00,$09,$05,$63,$00,$00,$00   ; $78D8
    db $05,$01,$00,$63,$00,$00,$01,$07   ; $78E0
    db $04,$00,$64,$00,$00,$04,$07,$00   ; $78E8
    db $05,$63,$00,$00,$09,$05,$01,$07   ; $78F0
    db $63,$00,$00,$01,$00,$FF,$04,$07   ; $78F8
    db $63,$00,$00,$04,$00,$04,$04,$00   ; $7900
    db $80,$00,$00,$00,$FF   ; $7908

Bank11_Area84:              ; $790D  AreaDir[84]=area $54
    dw $7925,$792D,$7935,$FFFF,$793D,$7945,$794D,$FFFF   ; rooms 0-7
    dw $7955,$795D,$7965,$FFFF   ; rooms 8-11
Bank11_Area84_Room0:        ; $7925  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $01,$37,$42,$4B,$6D,$79  ; v0: bank$37 blk$01 obj=$4B42 oth=$796D
Bank11_Area84_Room1:        ; $792D  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $02,$37,$42,$4B,$6E,$79  ; v0: bank$37 blk$02 obj=$4B42 oth=$796E
Bank11_Area84_Room2:        ; $7935  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $03,$37,$42,$4B,$6F,$79  ; v0: bank$37 blk$03 obj=$4B42 oth=$796F
Bank11_Area84_Room4:        ; $793D  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $04,$37,$42,$4B,$70,$79  ; v0: bank$37 blk$04 obj=$4B42 oth=$7970
Bank11_Area84_Room5:        ; $7945  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $05,$37,$42,$4B,$71,$79  ; v0: bank$37 blk$05 obj=$4B42 oth=$7971
Bank11_Area84_Room6:        ; $794D  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $06,$37,$42,$4B,$72,$79  ; v0: bank$37 blk$06 obj=$4B42 oth=$7972
Bank11_Area84_Room8:        ; $7955  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $07,$37,$42,$4B,$73,$79  ; v0: bank$37 blk$07 obj=$4B42 oth=$7973
Bank11_Area84_Room9:        ; $795D  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $08,$37,$42,$4B,$74,$79  ; v0: bank$37 blk$08 obj=$4B42 oth=$7974
Bank11_Area84_Room10:       ; $7965  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $09,$37,$42,$4B,$75,$79  ; v0: bank$37 blk$09 obj=$4B42 oth=$7975
Bank11_Area84_ObjLists:     ; $796D-$797C  compact 5-byte object records + "other" data
Bank11_Area84_Obj_796D:          ; $796D  (object list)
    db $FF   ; $796D end
Bank11_Area84_Obj_796E:          ; $796E  (object list)
    db $FF   ; $796E end
Bank11_Area84_Obj_796F:          ; $796F  (object list)
    db $FF   ; $796F end
Bank11_Area84_Obj_7970:          ; $7970  (object list)
    db $FF   ; $7970 end
Bank11_Area84_Obj_7971:          ; $7971  (object list)
    db $FF   ; $7971 end
Bank11_Area84_Obj_7972:          ; $7972  (object list)
    db $FF   ; $7972 end
Bank11_Area84_Obj_7973:          ; $7973  (object list)
    db $FF   ; $7973 end
Bank11_Area84_Obj_7974:          ; $7974  (object list)
    db $FF   ; $7974 end
Bank11_Area84_Obj_7975:          ; $7975  (object list)
    db $08,$02,$00,$80,$00   ; $7975 type8 face0 spr$02 (+0,+128) ev$00
    db $00,$00,$FF   ; $797A (tail)

Bank11_Area85:              ; $797D  AreaDir[85]=area $55
    dw $7995,$799D,$79A5,$FFFF,$79AD,$79B5,$79BD,$FFFF   ; rooms 0-7
    dw $79C5,$79CD,$79D5,$FFFF   ; rooms 8-11
Bank11_Area85_Room0:        ; $7995  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0B,$37,$42,$4B,$DD,$79  ; v0: bank$37 blk$0B obj=$4B42 oth=$79DD
Bank11_Area85_Room1:        ; $799D  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0C,$37,$42,$4B,$DE,$79  ; v0: bank$37 blk$0C obj=$4B42 oth=$79DE
Bank11_Area85_Room2:        ; $79A5  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0D,$37,$42,$4B,$DF,$79  ; v0: bank$37 blk$0D obj=$4B42 oth=$79DF
Bank11_Area85_Room4:        ; $79AD  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0E,$37,$42,$4B,$E0,$79  ; v0: bank$37 blk$0E obj=$4B42 oth=$79E0
Bank11_Area85_Room5:        ; $79B5  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0F,$37,$42,$4B,$E1,$79  ; v0: bank$37 blk$0F obj=$4B42 oth=$79E1
Bank11_Area85_Room6:        ; $79BD  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $10,$37,$42,$4B,$E2,$79  ; v0: bank$37 blk$10 obj=$4B42 oth=$79E2
Bank11_Area85_Room8:        ; $79C5  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $11,$37,$42,$4B,$E3,$79  ; v0: bank$37 blk$11 obj=$4B42 oth=$79E3
Bank11_Area85_Room9:        ; $79CD  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $12,$37,$42,$4B,$EB,$79  ; v0: bank$37 blk$12 obj=$4B42 oth=$79EB
Bank11_Area85_Room10:       ; $79D5  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $13,$37,$42,$4B,$EC,$79  ; v0: bank$37 blk$13 obj=$4B42 oth=$79EC
Bank11_Area85_ObjLists:     ; $79DD-$79EC  compact 5-byte object records + "other" data
Bank11_Area85_Obj_79DD:          ; $79DD  (object list)
    db $FF   ; $79DD end
Bank11_Area85_Obj_79DE:          ; $79DE  (object list)
    db $FF   ; $79DE end
Bank11_Area85_Obj_79DF:          ; $79DF  (object list)
    db $FF   ; $79DF end
Bank11_Area85_Obj_79E0:          ; $79E0  (object list)
    db $FF   ; $79E0 end
Bank11_Area85_Obj_79E1:          ; $79E1  (object list)
    db $FF   ; $79E1 end
Bank11_Area85_Obj_79E2:          ; $79E2  (object list)
    db $FF   ; $79E2 end
Bank11_Area85_Obj_79E3:          ; $79E3  (object list)
    db $06,$06,$00,$80,$00   ; $79E3 type6 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF,$FF,$FF   ; $79E8 type0 face0 spr$00 (+255,+255) ev$FF

Bank11_Area86:              ; $79ED  AreaDir[86]=area $56
    dw $7A05,$7A0D,$7A15,$FFFF,$7A1D,$7A25,$7A2D,$FFFF   ; rooms 0-7
    dw $7A35,$7A3D,$7A45,$FFFF   ; rooms 8-11
Bank11_Area86_Room0:        ; $7A05  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $15,$37,$42,$4B,$4D,$7A  ; v0: bank$37 blk$15 obj=$4B42 oth=$7A4D
Bank11_Area86_Room1:        ; $7A0D  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $16,$37,$42,$4B,$4E,$7A  ; v0: bank$37 blk$16 obj=$4B42 oth=$7A4E
Bank11_Area86_Room2:        ; $7A15  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $17,$37,$42,$4B,$4F,$7A  ; v0: bank$37 blk$17 obj=$4B42 oth=$7A4F
Bank11_Area86_Room4:        ; $7A1D  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $18,$37,$42,$4B,$57,$7A  ; v0: bank$37 blk$18 obj=$4B42 oth=$7A57
Bank11_Area86_Room5:        ; $7A25  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $19,$37,$42,$4B,$58,$7A  ; v0: bank$37 blk$19 obj=$4B42 oth=$7A58
Bank11_Area86_Room6:        ; $7A2D  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $1A,$37,$42,$4B,$59,$7A  ; v0: bank$37 blk$1A obj=$4B42 oth=$7A59
Bank11_Area86_Room8:        ; $7A35  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $1B,$37,$42,$4B,$5A,$7A  ; v0: bank$37 blk$1B obj=$4B42 oth=$7A5A
Bank11_Area86_Room9:        ; $7A3D  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $1C,$37,$42,$4B,$5B,$7A  ; v0: bank$37 blk$1C obj=$4B42 oth=$7A5B
Bank11_Area86_Room10:       ; $7A45  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $1D,$37,$42,$4B,$5C,$7A  ; v0: bank$37 blk$1D obj=$4B42 oth=$7A5C
Bank11_Area86_ObjLists:     ; $7A4D-$7A5C  compact 5-byte object records + "other" data
Bank11_Area86_Obj_7A4D:          ; $7A4D  (object list)
    db $FF   ; $7A4D end
Bank11_Area86_Obj_7A4E:          ; $7A4E  (object list)
    db $FF   ; $7A4E end
Bank11_Area86_Obj_7A4F:          ; $7A4F  (object list)
    db $03,$03,$00,$80,$00   ; $7A4F type3 face0 spr$03 (+0,+128) ev$00
    db $00,$00,$FF,$FF,$FF   ; $7A54 type0 face0 spr$00 (+255,+255) ev$FF
    db $FF   ; $7A59 end
Bank11_Area86_Obj_7A5A:          ; $7A5A  (object list)
    db $FF   ; $7A5A end
Bank11_Area86_Obj_7A5B:          ; $7A5B  (object list)
    db $FF   ; $7A5B end
Bank11_Area86_Obj_7A5C:          ; $7A5C  (object list)
    db $FF   ; $7A5C end

Bank11_Area87:              ; $7A5D  AreaDir[87]=area $57
    dw $7A75,$7A7D,$7A85,$FFFF,$7A8D,$7A95,$7A9D,$FFFF   ; rooms 0-7
    dw $7AA5,$7AAD,$7AB5,$FFFF   ; rooms 8-11
Bank11_Area87_Room0:        ; $7A75  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $1F,$37,$42,$4B,$BD,$7A  ; v0: bank$37 blk$1F obj=$4B42 oth=$7ABD
Bank11_Area87_Room1:        ; $7A7D  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $20,$37,$42,$4B,$BE,$7A  ; v0: bank$37 blk$20 obj=$4B42 oth=$7ABE
Bank11_Area87_Room2:        ; $7A85  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $21,$37,$42,$4B,$BF,$7A  ; v0: bank$37 blk$21 obj=$4B42 oth=$7ABF
Bank11_Area87_Room4:        ; $7A8D  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $22,$37,$42,$4B,$C0,$7A  ; v0: bank$37 blk$22 obj=$4B42 oth=$7AC0
Bank11_Area87_Room5:        ; $7A95  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $23,$37,$42,$4B,$C1,$7A  ; v0: bank$37 blk$23 obj=$4B42 oth=$7AC1
Bank11_Area87_Room6:        ; $7A9D  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $24,$37,$42,$4B,$C2,$7A  ; v0: bank$37 blk$24 obj=$4B42 oth=$7AC2
Bank11_Area87_Room8:        ; $7AA5  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $25,$37,$42,$4B,$C3,$7A  ; v0: bank$37 blk$25 obj=$4B42 oth=$7AC3
Bank11_Area87_Room9:        ; $7AAD  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $26,$37,$42,$4B,$CB,$7A  ; v0: bank$37 blk$26 obj=$4B42 oth=$7ACB
Bank11_Area87_Room10:       ; $7AB5  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $27,$37,$42,$4B,$CC,$7A  ; v0: bank$37 blk$27 obj=$4B42 oth=$7ACC
Bank11_Area87_ObjLists:     ; $7ABD-$7ACC  compact 5-byte object records + "other" data
Bank11_Area87_Obj_7ABD:          ; $7ABD  (object list)
    db $FF   ; $7ABD end
Bank11_Area87_Obj_7ABE:          ; $7ABE  (object list)
    db $FF   ; $7ABE end
Bank11_Area87_Obj_7ABF:          ; $7ABF  (object list)
    db $FF   ; $7ABF end
Bank11_Area87_Obj_7AC0:          ; $7AC0  (object list)
    db $FF   ; $7AC0 end
Bank11_Area87_Obj_7AC1:          ; $7AC1  (object list)
    db $FF   ; $7AC1 end
Bank11_Area87_Obj_7AC2:          ; $7AC2  (object list)
    db $FF   ; $7AC2 end
Bank11_Area87_Obj_7AC3:          ; $7AC3  (object list)
    db $01,$06,$00,$80,$00   ; $7AC3 type1 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF,$FF,$FF   ; $7AC8 type0 face0 spr$00 (+255,+255) ev$FF

Bank11_Area88:              ; $7ACD  AreaDir[88]=area $58
    dw $7AE5,$7AED,$7AF5,$FFFF,$7AFD,$7B05,$7B0D,$FFFF   ; rooms 0-7
    dw $7B15,$7B1D,$7B25,$FFFF   ; rooms 8-11
Bank11_Area88_Room0:        ; $7AE5  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $29,$37,$42,$4B,$2D,$7B  ; v0: bank$37 blk$29 obj=$4B42 oth=$7B2D
Bank11_Area88_Room1:        ; $7AED  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2A,$37,$42,$4B,$2E,$7B  ; v0: bank$37 blk$2A obj=$4B42 oth=$7B2E
Bank11_Area88_Room2:        ; $7AF5  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2B,$37,$42,$4B,$2F,$7B  ; v0: bank$37 blk$2B obj=$4B42 oth=$7B2F
Bank11_Area88_Room4:        ; $7AFD  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2C,$37,$42,$4B,$30,$7B  ; v0: bank$37 blk$2C obj=$4B42 oth=$7B30
Bank11_Area88_Room5:        ; $7B05  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2D,$37,$42,$4B,$31,$7B  ; v0: bank$37 blk$2D obj=$4B42 oth=$7B31
Bank11_Area88_Room6:        ; $7B0D  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2E,$37,$42,$4B,$32,$7B  ; v0: bank$37 blk$2E obj=$4B42 oth=$7B32
Bank11_Area88_Room8:        ; $7B15  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $2F,$37,$42,$4B,$33,$7B  ; v0: bank$37 blk$2F obj=$4B42 oth=$7B33
Bank11_Area88_Room9:        ; $7B1D  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $30,$37,$42,$4B,$34,$7B  ; v0: bank$37 blk$30 obj=$4B42 oth=$7B34
Bank11_Area88_Room10:       ; $7B25  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $31,$37,$42,$4B,$3C,$7B  ; v0: bank$37 blk$31 obj=$4B42 oth=$7B3C
Bank11_Area88_ObjLists:     ; $7B2D-$7B3C  compact 5-byte object records + "other" data
Bank11_Area88_Obj_7B2D:          ; $7B2D  (object list)
    db $FF   ; $7B2D end
Bank11_Area88_Obj_7B2E:          ; $7B2E  (object list)
    db $FF   ; $7B2E end
Bank11_Area88_Obj_7B2F:          ; $7B2F  (object list)
    db $FF   ; $7B2F end
Bank11_Area88_Obj_7B30:          ; $7B30  (object list)
    db $FF   ; $7B30 end
Bank11_Area88_Obj_7B31:          ; $7B31  (object list)
    db $FF   ; $7B31 end
Bank11_Area88_Obj_7B32:          ; $7B32  (object list)
    db $FF   ; $7B32 end
Bank11_Area88_Obj_7B33:          ; $7B33  (object list)
    db $FF   ; $7B33 end
Bank11_Area88_Obj_7B34:          ; $7B34  (object list)
    db $03,$06,$00,$80,$00   ; $7B34 type3 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF,$FF   ; $7B39 (tail)

Bank11_Area89:              ; $7B3D  AreaDir[89]=area $59
    dw $7B55,$7B5D,$7B65,$FFFF,$7B6D,$7B75,$7B7D,$FFFF   ; rooms 0-7
    dw $7B85,$7B8D,$7B95,$FFFF   ; rooms 8-11
Bank11_Area89_Room0:        ; $7B55  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $33,$37,$42,$4B,$9D,$7B  ; v0: bank$37 blk$33 obj=$4B42 oth=$7B9D
Bank11_Area89_Room1:        ; $7B5D  room(s) 1: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $34,$37,$42,$4B,$9E,$7B  ; v0: bank$37 blk$34 obj=$4B42 oth=$7B9E
Bank11_Area89_Room2:        ; $7B65  room(s) 2: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $35,$37,$42,$4B,$9F,$7B  ; v0: bank$37 blk$35 obj=$4B42 oth=$7B9F
Bank11_Area89_Room4:        ; $7B6D  room(s) 4: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $36,$37,$42,$4B,$A0,$7B  ; v0: bank$37 blk$36 obj=$4B42 oth=$7BA0
Bank11_Area89_Room5:        ; $7B75  room(s) 5: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $37,$37,$42,$4B,$A1,$7B  ; v0: bank$37 blk$37 obj=$4B42 oth=$7BA1
Bank11_Area89_Room6:        ; $7B7D  room(s) 6: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $38,$37,$42,$4B,$A2,$7B  ; v0: bank$37 blk$38 obj=$4B42 oth=$7BA2
Bank11_Area89_Room8:        ; $7B85  room(s) 8: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $39,$37,$42,$4B,$A3,$7B  ; v0: bank$37 blk$39 obj=$4B42 oth=$7BA3
Bank11_Area89_Room9:        ; $7B8D  room(s) 9: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $3A,$37,$42,$4B,$A4,$7B  ; v0: bank$37 blk$3A obj=$4B42 oth=$7BA4
Bank11_Area89_Room10:       ; $7B95  room(s) 10: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $3B,$37,$42,$4B,$A5,$7B  ; v0: bank$37 blk$3B obj=$4B42 oth=$7BA5
Bank11_Area89_ObjLists:     ; $7B9D-$7BAC  compact 5-byte object records + "other" data
Bank11_Area89_Obj_7B9D:          ; $7B9D  (object list)
    db $FF   ; $7B9D end
Bank11_Area89_Obj_7B9E:          ; $7B9E  (object list)
    db $FF   ; $7B9E end
Bank11_Area89_Obj_7B9F:          ; $7B9F  (object list)
    db $FF   ; $7B9F end
Bank11_Area89_Obj_7BA0:          ; $7BA0  (object list)
    db $FF   ; $7BA0 end
Bank11_Area89_Obj_7BA1:          ; $7BA1  (object list)
    db $FF   ; $7BA1 end
Bank11_Area89_Obj_7BA2:          ; $7BA2  (object list)
    db $FF   ; $7BA2 end
Bank11_Area89_Obj_7BA3:          ; $7BA3  (object list)
    db $FF   ; $7BA3 end
Bank11_Area89_Obj_7BA4:          ; $7BA4  (object list)
    db $FF   ; $7BA4 end
Bank11_Area89_Obj_7BA5:          ; $7BA5  (object list)
    db $08,$06,$00,$80,$00   ; $7BA5 type8 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF   ; $7BAA (tail)

Bank11_Area90:              ; $7BAD  AreaDir[90]=area $5A
    dw $7BAF   ; rooms 0-0
Bank11_Area90_Room0:        ; $7BAF  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $07,$26,$B7,$7B,$D6,$7B  ; v0: bank$26 blk$07 obj=$7BB7 oth=$7BD6
Bank11_Area90_ObjLists:     ; $7BB7-$7BDD  compact 5-byte object records + "other" data
Bank11_Area90_Obj_7BB7:          ; $7BB7  (object list)
    db $8F,$FF,$01,$02,$01   ; $7BB7 HEADER(bit7)
    db $8F,$FF,$08,$02,$02   ; $7BBC HEADER(bit7)
    db $8F,$FF,$03,$03,$03   ; $7BC1 HEADER(bit7)
    db $8F,$FF,$06,$03,$04   ; $7BC6 HEADER(bit7)
    db $8F,$FF,$02,$05,$05   ; $7BCB HEADER(bit7)
    db $8F,$FF,$07,$05,$06   ; $7BD0 HEADER(bit7)
    db $FF   ; $7BD5 end
Bank11_Area90_Obj_7BD6:          ; $7BD6  (object list)
    db $05,$06,$00,$80,$00   ; $7BD6 type5 face0 spr$06 (+0,+128) ev$00
    db $00,$00,$FF   ; $7BDB (tail)

Bank11_Area91:              ; $7BDE  AreaDir[91]=area $5B
    dw $7BE0   ; rooms 0-0
Bank11_Area91_Room0:        ; $7BE0  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $09,$26,$E8,$7B,$07,$7C  ; v0: bank$26 blk$09 obj=$7BE8 oth=$7C07
Bank11_Area91_ObjLists:     ; $7BE8-$7C0E  compact 5-byte object records + "other" data
Bank11_Area91_Obj_7BE8:          ; $7BE8  (object list)
    db $8F,$FF,$03,$03,$01   ; $7BE8 HEADER(bit7)
    db $8F,$FF,$06,$03,$02   ; $7BED HEADER(bit7)
    db $8F,$FF,$03,$04,$03   ; $7BF2 HEADER(bit7)
    db $8F,$FF,$06,$04,$04   ; $7BF7 HEADER(bit7)
    db $8F,$FF,$03,$05,$05   ; $7BFC HEADER(bit7)
    db $8F,$FF,$06,$05,$06   ; $7C01 HEADER(bit7)
    db $FF   ; $7C06 end
Bank11_Area91_Obj_7C07:          ; $7C07  (object list)
    db $05,$02,$00,$80,$00   ; $7C07 type5 face0 spr$02 (+0,+128) ev$00
    db $00,$00,$FF   ; $7C0C (tail)

Bank11_Area92:              ; $7C0F  AreaDir[92]=area $5C
    dw $7C11   ; rooms 0-0
Bank11_Area92_Room0:        ; $7C11  room(s) 0: sel + 1 variant(s)
    dw $D998   ; variant selector (WRAM)
    db $0B,$26,$19,$7C,$42,$7C  ; v0: bank$26 blk$0B obj=$7C19 oth=$7C42
Bank11_Area92_ObjLists:     ; $7C19-$7C49  compact 5-byte object records + "other" data
Bank11_Area92_Obj_7C19:          ; $7C19  (object list)
    db $8F,$FF,$03,$02,$01   ; $7C19 HEADER(bit7)
    db $8F,$FF,$04,$02,$02   ; $7C1E HEADER(bit7)
    db $8F,$FF,$05,$02,$03   ; $7C23 HEADER(bit7)
    db $8F,$FF,$06,$02,$04   ; $7C28 HEADER(bit7)
    db $8F,$FF,$03,$06,$05   ; $7C2D HEADER(bit7)
    db $8F,$FF,$04,$06,$06   ; $7C32 HEADER(bit7)
    db $8F,$FF,$05,$06,$07   ; $7C37 HEADER(bit7)
    db $8F,$FF,$06,$06,$08   ; $7C3C HEADER(bit7)
    db $FF   ; $7C41 end
Bank11_Area92_Obj_7C42:          ; $7C42  (object list)
    db $03,$04,$00,$80,$00   ; $7C42 type3 face0 spr$04 (+0,+128) ev$00
    db $00,$00,$FF   ; $7C47 (tail)

Bank11_Area93:              ; $7C4A  AreaDir[93]=area $5D
    dw $7C4C   ; rooms 0-0
Bank11_Area93_Room0:        ; $7C4C  room(s) 0: sel + 5 variant(s)
    dw $D999   ; variant selector (WRAM)
    db $14,$23,$6C,$7C,$FF,$FF  ; v0: bank$23 blk$14 obj=$7C6C oth=$FFFF
    db $15,$23,$6C,$7C,$FF,$FF  ; v1: bank$23 blk$15 obj=$7C6C oth=$FFFF
    db $15,$23,$95,$7C,$FF,$FF  ; v2: bank$23 blk$15 obj=$7C95 oth=$FFFF
    db $15,$23,$BE,$7C,$FF,$FF  ; v3: bank$23 blk$15 obj=$7CBE oth=$FFFF
    db $15,$23,$6C,$7C,$FF,$FF  ; v4: bank$23 blk$15 obj=$7C6C oth=$FFFF
Bank11_Area93_ObjLists:     ; $7C6C-$7CE6  compact 5-byte object records + "other" data
Bank11_Area93_Obj_7C6C:          ; $7C6C  (object list)
    db $10,$F0,$04,$09,$FF   ; $7C6C type0 face1 spr$F0 (+4,+9) ev$FF
    db $10,$F1,$04,$0A,$FF   ; $7C71 type0 face1 spr$F1 (+4,+10) ev$FF
    db $10,$F3,$04,$0B,$FF   ; $7C76 type0 face1 spr$F3 (+4,+11) ev$FF
    db $10,$F2,$04,$0C,$FF   ; $7C7B type0 face1 spr$F2 (+4,+12) ev$FF
    db $10,$E0,$07,$05,$FF   ; $7C80 type0 face1 spr$E0 (+7,+5) ev$FF
    db $10,$E1,$06,$05,$FF   ; $7C85 type0 face1 spr$E1 (+6,+5) ev$FF
    db $10,$E2,$06,$04,$FF   ; $7C8A type0 face1 spr$E2 (+6,+4) ev$FF
    db $10,$E3,$06,$06,$FF   ; $7C8F type0 face1 spr$E3 (+6,+6) ev$FF
    db $FF   ; $7C94 end
Bank11_Area93_Obj_7C95:          ; $7C95  (object list)
    db $40,$F0,$04,$05,$FF   ; $7C95 type0 face4 spr$F0 (+4,+5) ev$FF
    db $70,$F3,$03,$04,$FF   ; $7C9A type0 face7 spr$F3 (+3,+4) ev$FF
    db $70,$F1,$03,$05,$FF   ; $7C9F type0 face7 spr$F1 (+3,+5) ev$FF
    db $70,$F2,$03,$06,$FF   ; $7CA4 type0 face7 spr$F2 (+3,+6) ev$FF
    db $10,$E1,$06,$05,$FF   ; $7CA9 type0 face1 spr$E1 (+6,+5) ev$FF
    db $10,$E2,$06,$04,$FF   ; $7CAE type0 face1 spr$E2 (+6,+4) ev$FF
    db $10,$E3,$06,$06,$FF   ; $7CB3 type0 face1 spr$E3 (+6,+6) ev$FF
    db $40,$52,$04,$05,$FF   ; $7CB8 type0 face4 spr$52 (+4,+5) ev$FF
    db $FF   ; $7CBD end
Bank11_Area93_Obj_7CBE:          ; $7CBE  (object list)
    db $30,$F0,$02,$05,$FF   ; $7CBE type0 face3 spr$F0 (+2,+5) ev$FF
    db $30,$F3,$03,$04,$FF   ; $7CC3 type0 face3 spr$F3 (+3,+4) ev$FF
    db $30,$F1,$03,$05,$FF   ; $7CC8 type0 face3 spr$F1 (+3,+5) ev$FF
    db $30,$F2,$03,$06,$FF   ; $7CCD type0 face3 spr$F2 (+3,+6) ev$FF
    db $10,$E1,$06,$05,$FF   ; $7CD2 type0 face1 spr$E1 (+6,+5) ev$FF
    db $10,$E2,$06,$04,$FF   ; $7CD7 type0 face1 spr$E2 (+6,+4) ev$FF
    db $50,$39,$0A,$01,$FF   ; $7CDC type0 face5 spr$39 (+10,+1) ev$FF
    db $10,$E3,$06,$06,$FF   ; $7CE1 type0 face1 spr$E3 (+6,+6) ev$FF
    db $FF   ; $7CE6 end

Bank11_Area94:              ; $7CE7  AreaDir[94]=area $5E
    dw $7CE9   ; rooms 0-0
Bank11_Area94_Room0:        ; $7CE9  room(s) 0: sel + 4 variant(s)
    dw $D99A   ; variant selector (WRAM)
    db $17,$23,$03,$7D,$FF,$FF  ; v0: bank$23 blk$17 obj=$7D03 oth=$FFFF
    db $17,$23,$13,$7D,$FF,$FF  ; v1: bank$23 blk$17 obj=$7D13 oth=$FFFF
    db $17,$23,$1E,$7D,$FF,$FF  ; v2: bank$23 blk$17 obj=$7D1E oth=$FFFF
    db $17,$23,$42,$4B,$FF,$FF  ; v3: bank$23 blk$17 obj=$4B42 oth=$FFFF
Bank11_Area94_ObjLists:     ; $7D03-$7D26  compact 5-byte object records + "other" data
Bank11_Area94_Obj_7D03:          ; $7D03  (object list)
    db $10,$E0,$07,$05,$FF   ; $7D03 type0 face1 spr$E0 (+7,+5) ev$FF
    db $40,$57,$04,$00,$FF   ; $7D08 type0 face4 spr$57 (+4,+0) ev$FF
    db $40,$52,$04,$05,$FF   ; $7D0D type0 face4 spr$52 (+4,+5) ev$FF
    db $FF   ; $7D12 end
Bank11_Area94_Obj_7D13:          ; $7D13  (object list)
    db $70,$08,$00,$04,$FF   ; $7D13 type0 face7 spr$08 (+0,+4) ev$FF
    db $40,$55,$05,$04,$FF   ; $7D18 type0 face4 spr$55 (+5,+4) ev$FF
    db $FF   ; $7D1D end
Bank11_Area94_Obj_7D1E:          ; $7D1E  (object list)
    db $20,$E0,$05,$05,$FF   ; $7D1E type0 face2 spr$E0 (+5,+5) ev$FF
    db $50,$21,$09,$05   ; $7D23 (tail)

    ds $02D9, $FF                   ; $7D27-$7FFF padding

; ============================================================================
; PREVIOUSLY-UNDUMPED OBJECT LISTS (areas 0-63)
; ----------------------------------------------------------------------------
; Each area descriptor's variant records point at obj=/oth= addresses; these
; objlist regions (between the last room entry and the next descriptor) were
; not emitted. Dumped here as 5-byte object records (type/face,spr,+x,+y,event;
; $FF end; bit7=HEADER), one SECTION per region. Byte-exact.
; ============================================================================

SECTION "Bank 11 Area 1 ObjList $4ED7", ROMX[$4ED7], BANK[11]
Bank11_Area1_Obj_4ED7:          ; $4ED7  (object list)
    db $20,$08,$02,$06,$FF   ; $4ED7 type0 face2 spr$08 (+2,+6) ev$FF
    db $10,$05,$06,$05,$02   ; $4EDC type0 face1 spr$05 (+6,+5) ev$02
    db $FF   ; $4EE1 end
Bank11_Area1_Obj_4EE2:          ; $4EE2  (object list)
    db $00,$08,$02,$06,$01   ; $4EE2 type0 face0 spr$08 (+2,+6) ev$01
    db $00,$05,$06,$05,$02   ; $4EE7 type0 face0 spr$05 (+6,+5) ev$02
    db $FF   ; $4EEC end
Bank11_Area1_Obj_4EED:          ; $4EED  (object list)
    db $90,$FF,$06,$06,$12   ; $4EED HEADER(bit7)
    db $00,$05,$06,$05,$02   ; $4EF2 type0 face0 spr$05 (+6,+5) ev$02
    db $FF   ; $4EF7 end
Bank11_Area1_Obj_4EF8:          ; $4EF8  (object list)
    db $90,$FF,$06,$06,$12   ; $4EF8 HEADER(bit7)
    db $FF   ; $4EFD end
Bank11_Area1_Obj_4EFE:          ; $4EFE  (object list)
    db $90,$FF,$06,$06,$12   ; $4EFE HEADER(bit7)
    db $20,$08,$02,$06,$FF   ; $4F03 type0 face2 spr$08 (+2,+6) ev$FF
    db $FF   ; $4F08 end
Bank11_Area1_Obj_4F09:          ; $4F09  (object list)
    db $30,$03,$05,$02,$03   ; $4F09 type0 face3 spr$03 (+5,+2) ev$03
    db $FF   ; $4F0E end
Bank11_Area1_Obj_4F0F:          ; $4F0F  (object list)
    db $20,$08,$02,$06,$FF   ; $4F0F type0 face2 spr$08 (+2,+6) ev$FF
    db $00,$03,$07,$03,$04   ; $4F14 type0 face0 spr$03 (+7,+3) ev$04
    db $40,$0B,$04,$03,$FF   ; $4F19 type0 face4 spr$0B (+4,+3) ev$FF
    db $FF   ; $4F1E end
Bank11_Area1_Obj_4F1F:          ; $4F1F  (object list)
    db $90,$FF,$06,$06,$13   ; $4F1F HEADER(bit7)
    db $00,$03,$07,$03,$04   ; $4F24 type0 face0 spr$03 (+7,+3) ev$04
    db $00,$05,$06,$05,$05   ; $4F29 type0 face0 spr$05 (+6,+5) ev$05
    db $00,$08,$02,$06,$06   ; $4F2E type0 face0 spr$08 (+2,+6) ev$06
    db $FF   ; $4F33 end
Bank11_Area1_Obj_4F34:          ; $4F34  (object list)
    db $90,$FF,$06,$06,$13   ; $4F34 HEADER(bit7)
    db $00,$03,$07,$03,$04   ; $4F39 type0 face0 spr$03 (+7,+3) ev$04
    db $FF   ; $4F3E end
Bank11_Area1_Obj_4F3F:          ; $4F3F  (object list)
    db $90,$FF,$06,$06,$13   ; $4F3F HEADER(bit7)
    db $00,$03,$07,$03,$04   ; $4F44 type0 face0 spr$03 (+7,+3) ev$04
    db $00,$0B,$03,$05,$07   ; $4F49 type0 face0 spr$0B (+3,+5) ev$07
    db $FF   ; $4F4E end
Bank11_Area1_Obj_4F4F:          ; $4F4F  (object list)
    db $00,$0B,$03,$02,$08   ; $4F4F type0 face0 spr$0B (+3,+2) ev$08
    db $30,$0F,$06,$01,$09   ; $4F54 type0 face3 spr$0F (+6,+1) ev$09
    db $FF   ; $4F59 end
Bank11_Area1_Obj_4F5A:          ; $4F5A  (object list)
    db $90,$FF,$06,$07,$14   ; $4F5A HEADER(bit7)
    db $20,$08,$02,$06,$FF   ; $4F5F type0 face2 spr$08 (+2,+6) ev$FF
    db $17,$01,$03,$06,$0A   ; $4F64 type7 face1 spr$01 (+3,+6) ev$0A
    db $00,$09,$08,$03,$0B   ; $4F69 type0 face0 spr$09 (+8,+3) ev$0B
    db $FF   ; $4F6E end
Bank11_Area1_Obj_4F6F:          ; $4F6F  (object list)
    db $90,$FF,$06,$07,$14   ; $4F6F HEADER(bit7)
    db $00,$09,$08,$03,$0B   ; $4F74 type0 face0 spr$09 (+8,+3) ev$0B
    db $07,$01,$02,$07,$0A   ; $4F79 type7 face0 spr$01 (+2,+7) ev$0A
    db $00,$05,$06,$06,$0C   ; $4F7E type0 face0 spr$05 (+6,+6) ev$0C
    db $FF   ; $4F83 end
Bank11_Area1_Obj_4F84:          ; $4F84  (object list)
    db $90,$FF,$06,$07,$14   ; $4F84 HEADER(bit7)
    db $00,$09,$08,$03,$0B   ; $4F89 type0 face0 spr$09 (+8,+3) ev$0B
    db $10,$04,$03,$06,$0D   ; $4F8E type0 face1 spr$04 (+3,+6) ev$0D
    db $FF   ; $4F93 end
Bank11_Area1_Obj_4F94:          ; $4F94  (object list)
    db $00,$02,$04,$02,$0E   ; $4F94 type0 face0 spr$02 (+4,+2) ev$0E
    db $10,$00,$07,$04,$0F   ; $4F99 type0 face1 spr$00 (+7,+4) ev$0F
    db $FF   ; $4F9E end
Bank11_Area1_Obj_4F9F:          ; $4F9F  (object list)
    db $20,$08,$04,$05,$FF   ; $4F9F type0 face2 spr$08 (+4,+5) ev$FF
    db $FF   ; $4FA4 end
Bank11_Area1_Obj_4FA5:          ; $4FA5  (object list)
    db $07,$01,$01,$06,$10   ; $4FA5 type7 face0 spr$01 (+1,+6) ev$10
    db $00,$05,$07,$05,$11   ; $4FAA type0 face0 spr$05 (+7,+5) ev$11
    db $FF   ; $4FAF end
Bank11_Area1_Obj_4FB0:          ; $4FB0  (object list)
    db $07,$01,$01,$06,$10   ; $4FB0 type7 face0 spr$01 (+1,+6) ev$10
    db $00,$05,$07,$05,$11   ; $4FB5 type0 face0 spr$05 (+7,+5) ev$11
    db $FF   ; $4FBA end
Bank11_Area1_Obj_4FBB:          ; $4FBB  (object list)
    db $FF   ; $4FBB end
Bank11_Area1_Obj_4FBC:          ; $4FBC  (object list)
    db $FF   ; $4FBC end
Bank11_Area1_Obj_4FBD:          ; $4FBD  (object list)
    db $FF   ; $4FBD end
Bank11_Area1_Obj_4FBE:          ; $4FBE  (object list)
    db $FF   ; $4FBE end
Bank11_Area1_Obj_4FBF:          ; $4FBF  (object list)
    db $04,$04,$00,$00,$05   ; $4FBF type4 face0 spr$04 (+0,+0) ev$05
    db $04,$07,$05,$04,$00   ; $4FC4 type4 face0 spr$07 (+5,+4) ev$00
    db $00,$05,$05,$07,$FF   ; $4FC9 type0 face0 spr$05 (+5,+7) ev$FF
    db $03,$02,$16,$00,$00   ; $4FCE type3 face0 spr$02 (+22,+0) ev$00
    db $03,$07,$FF,$04,$03   ; $4FD3 type3 face0 spr$07 (+255,+4) ev$03
    db $06,$00,$01,$04,$07   ; $4FD8 type6 face0 spr$00 (+1,+4) ev$07
    db $05,$03,$06,$00,$01   ; $4FDD type5 face0 spr$03 (+6,+0) ev$01
    db $05,$07,$FF,$FF,$05   ; $4FE2 type5 face0 spr$07 (+255,+255) ev$05
    db $03,$12,$00,$04,$05   ; $4FE7 type3 face0 spr$12 (+0,+4) ev$05
    db $07,$04,$05,$18,$00   ; $4FEC type7 face0 spr$04 (+5,+24) ev$00
    db $00,$04,$00,$FF,$05   ; $4FF1 type0 face0 spr$04 (+0,+255) ev$05
    db $01,$0F,$00,$00,$05   ; $4FF6 type1 face0 spr$0F (+0,+0) ev$05
    db $07,$09,$03,$02,$00   ; $4FFB type7 face0 spr$09 (+3,+2) ev$00
    db $00,$00,$03,$FF,$04   ; $5000 type0 face0 spr$00 (+3,+255) ev$04
    db $06,$09,$00,$04,$04   ; $5005 type6 face0 spr$09 (+0,+4) ev$04
    db $06,$05,$01,$0D,$00   ; $500A type6 face0 spr$05 (+1,+13) ev$00
    db $00,$05,$07,$04,$04   ; $500F type0 face0 spr$05 (+7,+4) ev$04
    db $10,$00,$00,$04,$07   ; $5014 type0 face1 spr$00 (+0,+4) ev$07
    db $FF   ; $5019 end
Bank11_Area1_Obj_501A:          ; $501A  (object list)
    db $04,$06,$09,$00,$04   ; $501A type4 face0 spr$06 (+9,+0) ev$04
    db $04,$06,$05,$01,$0D   ; $501F type4 face0 spr$06 (+5,+1) ev$0D
    db $00,$00,$05,$07,$04   ; $5024 type0 face0 spr$00 (+5,+7) ev$04
    db $04,$10,$00,$00,$04   ; $5029 type4 face0 spr$10 (+0,+0) ev$04
    db $07,$FF,$02,$01,$0C   ; $502E type7 face0 spr$FF (+2,+1) ev$0C
    db $00,$00,$02,$07,$FF   ; $5033 type0 face0 spr$00 (+2,+7) ev$FF
    db $02,$01,$0C,$00,$00   ; $5038 type2 face0 spr$01 (+12,+0) ev$00
    db $02,$07,$01,$04,$19   ; $503D type2 face0 spr$07 (+1,+4) ev$19
    db $00,$00,$01,$07,$FF   ; $5042 type0 face0 spr$00 (+1,+7) ev$FF
    db $02,$01,$0C,$00,$00   ; $5047 type2 face0 spr$01 (+12,+0) ev$00
    db $02,$07,$01,$04,$19   ; $504C type2 face0 spr$07 (+1,+4) ev$19
    db $00,$00,$01,$07,$04   ; $5051 type0 face0 spr$00 (+1,+7) ev$04
    db $06,$1A,$00,$00,$04   ; $5056 type6 face0 spr$1A (+0,+0) ev$04
    db $07,$FF   ; $505B (tail)

SECTION "Bank 11 Area 2 ObjList $5103", ROMX[$5103], BANK[11]
Bank11_Area2_Obj_5103:          ; $5103  (object list)
    db $8F,$FF,$06,$02,$01   ; $5103 HEADER(bit7)
    db $8F,$FF,$08,$02,$02   ; $5108 HEADER(bit7)
    db $8F,$FF,$08,$01,$03   ; $510D HEADER(bit7)
    db $00,$06,$07,$02,$04   ; $5112 type0 face0 spr$06 (+7,+2) ev$04
    db $00,$03,$03,$04,$05   ; $5117 type0 face0 spr$03 (+3,+4) ev$05
    db $FF   ; $511C end
Bank11_Area2_Obj_511D:          ; $511D  (object list)
    db $8F,$FF,$06,$02,$01   ; $511D HEADER(bit7)
    db $8F,$FF,$08,$02,$02   ; $5122 HEADER(bit7)
    db $8F,$FF,$08,$01,$03   ; $5127 HEADER(bit7)
    db $00,$06,$07,$02,$04   ; $512C type0 face0 spr$06 (+7,+2) ev$04
    db $00,$03,$03,$04,$05   ; $5131 type0 face0 spr$03 (+3,+4) ev$05
    db $30,$04,$04,$05,$06   ; $5136 type0 face3 spr$04 (+4,+5) ev$06
    db $FF   ; $513B end
Bank11_Area2_Obj_513C:          ; $513C  (object list)
    db $00,$04,$04,$04,$07   ; $513C type0 face0 spr$04 (+4,+4) ev$07
    db $20,$04,$04,$05,$08   ; $5141 type0 face2 spr$04 (+4,+5) ev$08
    db $50,$39,$0A,$04,$FF   ; $5146 type0 face5 spr$39 (+10,+4) ev$FF
    db $FF   ; $514B end
Bank11_Area2_Obj_514C:          ; $514C  (object list)
    db $00,$04,$04,$04,$07   ; $514C type0 face0 spr$04 (+4,+4) ev$07
    db $20,$04,$04,$05,$08   ; $5151 type0 face2 spr$04 (+4,+5) ev$08
    db $50,$39,$0A,$04,$FF   ; $5156 type0 face5 spr$39 (+10,+4) ev$FF
    db $00,$00,$03,$02,$09   ; $515B type0 face0 spr$00 (+3,+2) ev$09
    db $FF   ; $5160 end
Bank11_Area2_Obj_5161:          ; $5161  (object list)
    db $00,$04,$04,$04,$07   ; $5161 type0 face0 spr$04 (+4,+4) ev$07
    db $20,$04,$04,$05,$08   ; $5166 type0 face2 spr$04 (+4,+5) ev$08
    db $50,$39,$0A,$04,$FF   ; $516B type0 face5 spr$39 (+10,+4) ev$FF
    db $02,$00,$04,$02,$09   ; $5170 type2 face0 spr$00 (+4,+2) ev$09
    db $FF   ; $5175 end
Bank11_Area2_Obj_5176:          ; $5176  (object list)
    db $30,$0F,$01,$04,$0A   ; $5176 type0 face3 spr$0F (+1,+4) ev$0A
    db $FF   ; $517B end
Bank11_Area2_Obj_517C:          ; $517C  (object list)
    db $8F,$FF,$06,$03,$0B   ; $517C HEADER(bit7)
    db $32,$0F,$02,$04,$0A   ; $5181 type2 face3 spr$0F (+2,+4) ev$0A
    db $10,$06,$07,$03,$0C   ; $5186 type0 face1 spr$06 (+7,+3) ev$0C
    db $FF   ; $518B end
Bank11_Area2_Obj_518C:          ; $518C  (object list)
    db $8F,$FF,$06,$03,$0B   ; $518C HEADER(bit7)
    db $32,$0F,$02,$04,$0A   ; $5191 type2 face3 spr$0F (+2,+4) ev$0A
    db $10,$06,$07,$03,$0C   ; $5196 type0 face1 spr$06 (+7,+3) ev$0C
    db $00,$12,$04,$06,$0D   ; $519B type0 face0 spr$12 (+4,+6) ev$0D
    db $FF   ; $51A0 end
Bank11_Area2_Obj_51A1:          ; $51A1  (object list)
    db $30,$06,$03,$03,$0E   ; $51A1 type0 face3 spr$06 (+3,+3) ev$0E
    db $00,$0A,$08,$01,$0F   ; $51A6 type0 face0 spr$0A (+8,+1) ev$0F
    db $FF   ; $51AB end
Bank11_Area2_Obj_51AC:          ; $51AC  (object list)
    db $30,$06,$03,$03,$0E   ; $51AC type0 face3 spr$06 (+3,+3) ev$0E
    db $00,$0A,$08,$01,$0F   ; $51B1 type0 face0 spr$0A (+8,+1) ev$0F
    db $FF   ; $51B6 end
Bank11_Area2_Obj_51B7:          ; $51B7  (object list)
    db $30,$06,$03,$03,$0E   ; $51B7 type0 face3 spr$06 (+3,+3) ev$0E
    db $00,$0A,$08,$01,$0F   ; $51BC type0 face0 spr$0A (+8,+1) ev$0F
    db $FF   ; $51C1 end
Bank11_Area2_Obj_51C2:          ; $51C2  (object list)
    db $10,$05,$08,$02,$10   ; $51C2 type0 face1 spr$05 (+8,+2) ev$10
    db $FF   ; $51C7 end
Bank11_Area2_Obj_51C8:          ; $51C8  (object list)
    db $8F,$FF,$04,$03,$11   ; $51C8 HEADER(bit7)
    db $8F,$FF,$06,$03,$12   ; $51CD HEADER(bit7)
    db $20,$06,$05,$03,$13   ; $51D2 type0 face2 spr$06 (+5,+3) ev$13
    db $10,$05,$08,$02,$10   ; $51D7 type0 face1 spr$05 (+8,+2) ev$10
    db $FF   ; $51DC end
Bank11_Area2_Obj_51DD:          ; $51DD  (object list)
    db $8F,$FF,$04,$03,$11   ; $51DD HEADER(bit7)
    db $8F,$FF,$06,$03,$12   ; $51E2 HEADER(bit7)
    db $20,$06,$05,$03,$13   ; $51E7 type0 face2 spr$06 (+5,+3) ev$13
    db $10,$05,$08,$02,$10   ; $51EC type0 face1 spr$05 (+8,+2) ev$10
    db $00,$03,$02,$01,$14   ; $51F1 type0 face0 spr$03 (+2,+1) ev$14
    db $FF   ; $51F6 end
Bank11_Area2_Obj_51F7:          ; $51F7  (object list)
    db $8F,$FF,$03,$01,$15   ; $51F7 HEADER(bit7)
    db $17,$0A,$04,$01,$16   ; $51FC type7 face1 spr$0A (+4,+1) ev$16
    db $27,$0A,$03,$02,$17   ; $5201 type7 face2 spr$0A (+3,+2) ev$17
    db $00,$07,$04,$03,$18   ; $5206 type0 face0 spr$07 (+4,+3) ev$18
    db $00,$4D,$07,$04,$FF   ; $520B type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $5210 end
Bank11_Area2_Obj_5211:          ; $5211  (object list)
    db $17,$0A,$04,$01,$16   ; $5211 type7 face1 spr$0A (+4,+1) ev$16
    db $27,$0A,$03,$02,$17   ; $5216 type7 face2 spr$0A (+3,+2) ev$17
    db $00,$07,$04,$03,$18   ; $521B type0 face0 spr$07 (+4,+3) ev$18
    db $00,$4D,$03,$01,$FF   ; $5220 type0 face0 spr$4D (+3,+1) ev$FF
    db $00,$4D,$07,$04,$FF   ; $5225 type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $522A end
Bank11_Area2_Obj_522B:          ; $522B  (object list)
    db $17,$0A,$04,$01,$16   ; $522B type7 face1 spr$0A (+4,+1) ev$16
    db $27,$0A,$03,$02,$17   ; $5230 type7 face2 spr$0A (+3,+2) ev$17
    db $00,$07,$04,$03,$18   ; $5235 type0 face0 spr$07 (+4,+3) ev$18
    db $00,$4D,$07,$04,$FF   ; $523A type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $523F end
Bank11_Area2_Obj_5240:          ; $5240  (object list)
    db $8F,$FF,$07,$04,$15   ; $5240 HEADER(bit7)
    db $07,$0A,$07,$03,$16   ; $5245 type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $524A type7 face3 spr$0A (+6,+4) ev$17
    db $00,$07,$04,$02,$18   ; $524F type0 face0 spr$07 (+4,+2) ev$18
    db $00,$4D,$03,$01,$FF   ; $5254 type0 face0 spr$4D (+3,+1) ev$FF
    db $FF   ; $5259 end
Bank11_Area2_Obj_525A:          ; $525A  (object list)
    db $8F,$FF,$07,$04,$15   ; $525A HEADER(bit7)
    db $07,$0A,$07,$03,$16   ; $525F type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $5264 type7 face3 spr$0A (+6,+4) ev$17
    db $00,$07,$04,$02,$18   ; $5269 type0 face0 spr$07 (+4,+2) ev$18
    db $FF   ; $526E end
Bank11_Area2_Obj_526F:          ; $526F  (object list)
    db $07,$0A,$07,$03,$16   ; $526F type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $5274 type7 face3 spr$0A (+6,+4) ev$17
    db $20,$07,$04,$02,$18   ; $5279 type0 face2 spr$07 (+4,+2) ev$18
    db $00,$4D,$03,$01,$FF   ; $527E type0 face0 spr$4D (+3,+1) ev$FF
    db $00,$4D,$07,$04,$FF   ; $5283 type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $5288 end
Bank11_Area2_Obj_5289:          ; $5289  (object list)
    db $07,$0A,$07,$03,$16   ; $5289 type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $528E type7 face3 spr$0A (+6,+4) ev$17
    db $20,$07,$04,$02,$18   ; $5293 type0 face2 spr$07 (+4,+2) ev$18
    db $00,$4D,$07,$04,$FF   ; $5298 type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $529D end
Bank11_Area2_Obj_529E:          ; $529E  (object list)
    db $07,$0A,$07,$03,$16   ; $529E type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $52A3 type7 face3 spr$0A (+6,+4) ev$17
    db $20,$07,$04,$02,$18   ; $52A8 type0 face2 spr$07 (+4,+2) ev$18
    db $00,$4D,$03,$01,$FF   ; $52AD type0 face0 spr$4D (+3,+1) ev$FF
    db $FF   ; $52B2 end
Bank11_Area2_Obj_52B3:          ; $52B3  (object list)
    db $07,$0A,$07,$03,$16   ; $52B3 type7 face0 spr$0A (+7,+3) ev$16
    db $37,$0A,$06,$04,$17   ; $52B8 type7 face3 spr$0A (+6,+4) ev$17
    db $20,$07,$04,$02,$18   ; $52BD type0 face2 spr$07 (+4,+2) ev$18
    db $FF   ; $52C2 end
Bank11_Area2_Obj_52C3:          ; $52C3  (object list)
    db $00,$03,$01,$00,$09   ; $52C3 type0 face0 spr$03 (+1,+0) ev$09
    db $09,$03,$FF,$FF,$FF   ; $52C8 type9 face0 spr$03 (+255,+255) ev$FF
    db $FF   ; $52CD end
Bank11_Area2_Obj_52CE:          ; $52CE  (object list)
    db $FF   ; $52CE end
Bank11_Area2_Obj_52CF:          ; $52CF  (object list)
    db $FF   ; $52CF end
Bank11_Area2_Obj_52D0:          ; $52D0  (object list)
    db $FF   ; $52D0 end
Bank11_Area2_Obj_52D1:          ; $52D1  (object list)
    db $FF   ; $52D1 end
Bank11_Area2_Obj_52D2:          ; $52D2  (object list)
    db $FF   ; $52D2 end
Bank11_Area2_Obj_52D3:          ; $52D3  (object list)
    db $03,$01,$05,$01,$00   ; $52D3 type3 face0 spr$01 (+5,+1) ev$00
    db $00,$00,$FF,$03,$01   ; $52D8 type0 face0 spr$00 (+255,+3) ev$01
    db $05,$01,$00,$00,$00   ; $52DD type5 face0 spr$01 (+0,+0) ev$00
    db $FF   ; $52E2 end
Bank11_Area2_Obj_52E3:          ; $52E3  (object list)
    db $03,$01,$05,$01,$00   ; $52E3 type3 face0 spr$01 (+5,+1) ev$00
    db $00,$00,$07,$04,$1C   ; $52E8 type0 face0 spr$00 (+7,+4) ev$1C
    db $01,$00,$00,$00,$FF   ; $52ED type1 face0 spr$00 (+0,+0) ev$FF

SECTION "Bank 11 Area 3 ObjList $536A", ROMX[$536A], BANK[11]
Bank11_Area3_Obj_536A:          ; $536A  (object list)
    db $8F,$FF,$04,$01,$01   ; $536A HEADER(bit7)
    db $8F,$FF,$05,$01,$01   ; $536F HEADER(bit7)
    db $8F,$FF,$02,$02,$02   ; $5374 HEADER(bit7)
    db $8F,$FF,$07,$02,$03   ; $5379 HEADER(bit7)
    db $20,$0B,$03,$05,$04   ; $537E type0 face2 spr$0B (+3,+5) ev$04
    db $FF   ; $5383 end
Bank11_Area3_Obj_5384:          ; $5384  (object list)
    db $8F,$FF,$04,$01,$01   ; $5384 HEADER(bit7)
    db $8F,$FF,$05,$01,$01   ; $5389 HEADER(bit7)
    db $8F,$FF,$02,$02,$02   ; $538E HEADER(bit7)
    db $20,$0B,$03,$05,$04   ; $5393 type0 face2 spr$0B (+3,+5) ev$04
    db $FF   ; $5398 end
Bank11_Area3_Obj_5399:          ; $5399  (object list)
    db $8F,$FF,$02,$02,$02   ; $5399 HEADER(bit7)
    db $20,$0B,$03,$05,$04   ; $539E type0 face2 spr$0B (+3,+5) ev$04
    db $FF   ; $53A3 end
Bank11_Area3_Obj_53A4:          ; $53A4  (object list)
    db $20,$0B,$03,$05,$04   ; $53A4 type0 face2 spr$0B (+3,+5) ev$04
    db $FF   ; $53A9 end
Bank11_Area3_Obj_53AA:          ; $53AA  (object list)
    db $8F,$FF,$04,$01,$05   ; $53AA HEADER(bit7)
    db $8F,$FF,$05,$01,$05   ; $53AF HEADER(bit7)
    db $8F,$FF,$02,$02,$06   ; $53B4 HEADER(bit7)
    db $8F,$FF,$07,$02,$07   ; $53B9 HEADER(bit7)
    db $30,$0B,$00,$04,$08   ; $53BE type0 face3 spr$0B (+0,+4) ev$08
    db $30,$0B,$00,$05,$09   ; $53C3 type0 face3 spr$0B (+0,+5) ev$09
    db $20,$0B,$04,$06,$0A   ; $53C8 type0 face2 spr$0B (+4,+6) ev$0A
    db $FF   ; $53CD end
Bank11_Area3_Obj_53CE:          ; $53CE  (object list)
    db $8F,$FF,$02,$02,$06   ; $53CE HEADER(bit7)
    db $8F,$FF,$07,$02,$07   ; $53D3 HEADER(bit7)
    db $30,$0B,$00,$04,$08   ; $53D8 type0 face3 spr$0B (+0,+4) ev$08
    db $30,$0B,$00,$05,$09   ; $53DD type0 face3 spr$0B (+0,+5) ev$09
    db $20,$0B,$04,$06,$0A   ; $53E2 type0 face2 spr$0B (+4,+6) ev$0A
    db $FF   ; $53E7 end
Bank11_Area3_Obj_53E8:          ; $53E8  (object list)
    db $8F,$FF,$02,$02,$06   ; $53E8 HEADER(bit7)
    db $8F,$FF,$07,$02,$07   ; $53ED HEADER(bit7)
    db $22,$0B,$05,$05,$0A   ; $53F2 type2 face2 spr$0B (+5,+5) ev$0A
    db $FF   ; $53F7 end
Bank11_Area3_Obj_53F8:          ; $53F8  (object list)
    db $8F,$FF,$07,$02,$07   ; $53F8 HEADER(bit7)
    db $22,$0B,$05,$05,$0A   ; $53FD type2 face2 spr$0B (+5,+5) ev$0A
    db $FF   ; $5402 end
Bank11_Area3_Obj_5403:          ; $5403  (object list)
    db $22,$0B,$05,$05,$0A   ; $5403 type2 face2 spr$0B (+5,+5) ev$0A
    db $FF   ; $5408 end
Bank11_Area3_Obj_5409:          ; $5409  (object list)
    db $8F,$FF,$04,$01,$0B   ; $5409 HEADER(bit7)
    db $8F,$FF,$05,$01,$0B   ; $540E HEADER(bit7)
    db $8F,$FF,$02,$02,$0C   ; $5413 HEADER(bit7)
    db $8F,$FF,$07,$02,$0D   ; $5418 HEADER(bit7)
    db $10,$0B,$09,$04,$0E   ; $541D type0 face1 spr$0B (+9,+4) ev$0E
    db $10,$0B,$09,$05,$0F   ; $5422 type0 face1 spr$0B (+9,+5) ev$0F
    db $FF   ; $5427 end
Bank11_Area3_Obj_5428:          ; $5428  (object list)
    db $8F,$FF,$04,$01,$0B   ; $5428 HEADER(bit7)
    db $8F,$FF,$05,$01,$0B   ; $542D HEADER(bit7)
    db $8F,$FF,$02,$02,$0C   ; $5432 HEADER(bit7)
    db $10,$0B,$09,$04,$0E   ; $5437 type0 face1 spr$0B (+9,+4) ev$0E
    db $10,$0B,$09,$05,$0F   ; $543C type0 face1 spr$0B (+9,+5) ev$0F
    db $FF   ; $5441 end
Bank11_Area3_Obj_5442:          ; $5442  (object list)
    db $8F,$FF,$04,$01,$0B   ; $5442 HEADER(bit7)
    db $8F,$FF,$05,$01,$0B   ; $5447 HEADER(bit7)
    db $10,$0B,$09,$04,$0E   ; $544C type0 face1 spr$0B (+9,+4) ev$0E
    db $10,$0B,$09,$05,$0F   ; $5451 type0 face1 spr$0B (+9,+5) ev$0F
    db $FF   ; $5456 end
Bank11_Area3_Obj_5457:          ; $5457  (object list)
    db $10,$0B,$09,$04,$0E   ; $5457 type0 face1 spr$0B (+9,+4) ev$0E
    db $10,$0B,$09,$05,$0F   ; $545C type0 face1 spr$0B (+9,+5) ev$0F
    db $FF   ; $5461 end
Bank11_Area3_Obj_5462:          ; $5462  (object list)
    db $00,$0B,$03,$04,$0E   ; $5462 type0 face0 spr$0B (+3,+4) ev$0E
    db $FF   ; $5467 end
Bank11_Area3_Obj_5468:          ; $5468  (object list)
    db $8F,$FF,$04,$01,$10   ; $5468 HEADER(bit7)
    db $8F,$FF,$05,$01,$10   ; $546D HEADER(bit7)
    db $8F,$FF,$02,$02,$11   ; $5472 HEADER(bit7)
    db $8F,$FF,$07,$02,$12   ; $5477 HEADER(bit7)
    db $20,$0B,$04,$06,$13   ; $547C type0 face2 spr$0B (+4,+6) ev$13
    db $FF   ; $5481 end
Bank11_Area3_Obj_5482:          ; $5482  (object list)
    db $20,$0B,$04,$06,$13   ; $5482 type0 face2 spr$0B (+4,+6) ev$13
    db $FF   ; $5487 end
Bank11_Area3_Obj_5488:          ; $5488  (object list)
    db $07,$05,$03,$00,$04   ; $5488 type7 face0 spr$05 (+3,+0) ev$04
    db $07,$05,$FF,$07,$05   ; $548D type7 face0 spr$05 (+255,+7) ev$05
    db $03,$00,$04,$07,$05   ; $5492 type3 face0 spr$00 (+4,+7) ev$05
    db $07,$02,$26,$00,$00   ; $5497 type7 face0 spr$02 (+38,+0) ev$00
    db $08,$07,$FF,$07,$05   ; $549C type8 face0 spr$07 (+255,+7) ev$05
    db $03,$00,$04,$07,$05   ; $54A1 type3 face0 spr$00 (+4,+7) ev$05
    db $07,$02,$26,$00,$00   ; $54A6 type7 face0 spr$02 (+38,+0) ev$00
    db $08,$07,$04,$01,$27   ; $54AB type8 face0 spr$07 (+4,+1) ev$27
    db $00,$00,$04,$07,$05   ; $54B0 type0 face0 spr$00 (+4,+7) ev$05
    db $01,$27,$00,$00,$05   ; $54B5 type1 face0 spr$27 (+0,+0) ev$05
    db $07,$FF,$07,$05,$03   ; $54BA type7 face0 spr$FF (+7,+5) ev$03
    db $00,$04,$07,$05,$07   ; $54BF type0 face0 spr$04 (+7,+5) ev$07
    db $02,$26,$00,$00,$08   ; $54C4 type2 face0 spr$26 (+0,+0) ev$08
    db $07,$04,$01,$27,$00   ; $54C9 type7 face0 spr$04 (+1,+39) ev$00
    db $00,$04,$07,$05,$01   ; $54CE type0 face0 spr$04 (+7,+5) ev$01
    db $27,$00,$00,$05,$07   ; $54D3 type7 face2 spr$00 (+0,+5) ev$07
    db $02,$02,$28,$00,$00   ; $54D8 type2 face0 spr$02 (+40,+0) ev$00
    db $04,$07,$FF,$02,$05   ; $54DD type4 face0 spr$07 (+255,+2) ev$05
    db $00,$00,$05,$02,$05   ; $54E2 type0 face0 spr$00 (+5,+2) ev$05
    db $FF   ; $54E7 end
Bank11_Area3_Obj_54E8:          ; $54E8  (object list)
    db $02,$05,$00,$00,$05   ; $54E8 type2 face0 spr$05 (+0,+0) ev$05
    db $02,$05,$04,$01,$23   ; $54ED type2 face0 spr$05 (+4,+1) ev$23
    db $00,$00,$07,$07,$05   ; $54F2 type0 face0 spr$00 (+7,+7) ev$05
    db $01,$23,$00,$00,$08   ; $54F7 type1 face0 spr$23 (+0,+0) ev$08
    db $07,$FF,$02,$05,$00   ; $54FC type7 face0 spr$FF (+2,+5) ev$00
    db $00,$05,$02,$05,$04   ; $5501 type0 face0 spr$05 (+2,+5) ev$04
    db $01,$23,$00,$00,$07   ; $5506 type1 face0 spr$23 (+0,+0) ev$07
    db $07,$05,$01,$23,$00   ; $550B type7 face0 spr$05 (+1,+35) ev$00
    db $00,$08,$07,$02,$02   ; $5510 type0 face0 spr$08 (+7,+2) ev$02
    db $24,$00,$00,$06,$07   ; $5515 type4 face2 spr$00 (+0,+6) ev$07
    db $FF   ; $551A end
Bank11_Area3_Obj_551B:          ; $551B  (object list)
    db $02,$05,$00,$00,$05   ; $551B type2 face0 spr$05 (+0,+0) ev$05
    db $02,$05,$04,$01,$23   ; $5520 type2 face0 spr$05 (+4,+1) ev$23
    db $00,$00,$07,$07,$05   ; $5525 type0 face0 spr$00 (+7,+7) ev$05
    db $01,$23,$00,$00,$08   ; $552A type1 face0 spr$23 (+0,+0) ev$08
    db $07,$02,$02,$24,$00   ; $552F type7 face0 spr$02 (+2,+36) ev$00
    db $00,$06,$07,$07,$02   ; $5534 type0 face0 spr$06 (+7,+7) ev$02
    db $25,$00,$00,$01,$07   ; $5539 type5 face2 spr$00 (+0,+1) ev$07
    db $FF   ; $553E end
Bank11_Area3_Obj_553F:          ; $553F  (object list)
    db $07,$05,$03,$00,$00   ; $553F type7 face0 spr$05 (+3,+0) ev$00
    db $07,$05,$FF,$07,$05   ; $5544 type7 face0 spr$05 (+255,+7) ev$05
    db $03,$00,$00,$07,$05   ; $5549 type3 face0 spr$00 (+0,+7) ev$05
    db $07,$02,$29,$00,$00   ; $554E type7 face0 spr$02 (+41,+0) ev$00
    db $04,$07,$FF,$07,$05   ; $5553 type4 face0 spr$07 (+255,+7) ev$05
    db $03,$00,$00,$07,$05   ; $5558 type3 face0 spr$00 (+0,+7) ev$05
    db $07,$02,$29,$00,$00   ; $555D type7 face0 spr$02 (+41,+0) ev$00
    db $04,$07,$02,$02,$2A   ; $5562 type4 face0 spr$07 (+2,+2) ev$2A
    db $00,$00,$04,$07,$FF   ; $5567 type0 face0 spr$00 (+4,+7) ev$FF
    db $07,$05,$03,$00,$00   ; $556C type7 face0 spr$05 (+3,+0) ev$00
    db $07,$05,$07,$02,$29   ; $5571 type7 face0 spr$05 (+7,+2) ev$29
    db $00,$00,$04,$07,$02   ; $5576 type0 face0 spr$00 (+4,+7) ev$02
    db $02,$2A,$00,$00,$04   ; $557B type2 face0 spr$2A (+0,+0) ev$04
    db $07,$04,$01,$2B,$00   ; $5580 type7 face0 spr$04 (+1,+43) ev$00
    db $00,$07,$07,$05,$01   ; $5585 type0 face0 spr$07 (+7,+5) ev$01
    db $2B,$00,$00,$08,$07   ; $558A type11 face2 spr$00 (+0,+8) ev$07
    db $FF   ; $558F end
Bank11_Area3_Obj_5590:          ; $5590  (object list)
    db $FF   ; $5590 end
Bank11_Area3_Obj_5591:          ; $5591  (object list)
    db $02,$02,$2C,$00,$00   ; $5591 type2 face0 spr$02 (+44,+0) ev$00
    db $08,$07,$07,$02,$2D   ; $5596 type8 face0 spr$07 (+7,+2) ev$2D
    db $00,$00,$02,$07,$04   ; $559B type0 face0 spr$00 (+2,+7) ev$04
    db $01,$2E,$00,$00,$06   ; $55A0 type1 face0 spr$2E (+0,+0) ev$06
    db $07,$05,$01,$2E,$00   ; $55A5 type7 face0 spr$05 (+1,+46) ev$00
    db $00,$07,$07,$FF   ; $55AA (tail)

SECTION "Bank 11 Area 4 ObjList $5654", ROMX[$5654], BANK[11]
Bank11_Area4_Obj_5654:          ; $5654  (object list)
    db $FF   ; $5654 end
Bank11_Area4_Obj_5655:          ; $5655  (object list)
    db $90,$FF,$06,$05,$02   ; $5655 HEADER(bit7)
    db $02,$18,$04,$01,$FF   ; $565A type2 face0 spr$18 (+4,+1) ev$FF
    db $10,$20,$04,$06,$01   ; $565F type0 face1 spr$20 (+4,+6) ev$01
    db $40,$53,$06,$01,$FF   ; $5664 type0 face4 spr$53 (+6,+1) ev$FF
    db $FF   ; $5669 end
Bank11_Area4_Obj_566A:          ; $566A  (object list)
    db $90,$FF,$06,$05,$02   ; $566A HEADER(bit7)
    db $02,$1B,$04,$01,$FF   ; $566F type2 face0 spr$1B (+4,+1) ev$FF
    db $00,$2C,$04,$06,$03   ; $5674 type0 face0 spr$2C (+4,+6) ev$03
    db $40,$53,$06,$01,$FF   ; $5679 type0 face4 spr$53 (+6,+1) ev$FF
    db $FF   ; $567E end
Bank11_Area4_Obj_567F:          ; $567F  (object list)
    db $02,$1B,$04,$01,$FF   ; $567F type2 face0 spr$1B (+4,+1) ev$FF
    db $30,$0C,$04,$06,$04   ; $5684 type0 face3 spr$0C (+4,+6) ev$04
    db $30,$02,$06,$05,$05   ; $5689 type0 face3 spr$02 (+6,+5) ev$05
    db $FF   ; $568E end
Bank11_Area4_Obj_568F:          ; $568F  (object list)
    db $90,$FF,$05,$02,$06   ; $568F HEADER(bit7)
    db $8F,$FF,$04,$01,$07   ; $5694 HEADER(bit7)
    db $00,$19,$06,$02,$08   ; $5699 type0 face0 spr$19 (+6,+2) ev$08
    db $FF   ; $569E end
Bank11_Area4_Obj_569F:          ; $569F  (object list)
    db $90,$FF,$05,$02,$06   ; $569F HEADER(bit7)
    db $8F,$FF,$04,$01,$07   ; $56A4 HEADER(bit7)
    db $00,$19,$06,$02,$08   ; $56A9 type0 face0 spr$19 (+6,+2) ev$08
    db $00,$19,$03,$04,$09   ; $56AE type0 face0 spr$19 (+3,+4) ev$09
    db $FF   ; $56B3 end
Bank11_Area4_Obj_56B4:          ; $56B4  (object list)
    db $00,$0D,$05,$02,$0A   ; $56B4 type0 face0 spr$0D (+5,+2) ev$0A
    db $00,$0E,$04,$02,$0B   ; $56B9 type0 face0 spr$0E (+4,+2) ev$0B
    db $00,$10,$02,$03,$0C   ; $56BE type0 face0 spr$10 (+2,+3) ev$0C
    db $00,$10,$01,$04,$0D   ; $56C3 type0 face0 spr$10 (+1,+4) ev$0D
    db $00,$10,$07,$03,$0E   ; $56C8 type0 face0 spr$10 (+7,+3) ev$0E
    db $00,$10,$08,$04,$0F   ; $56CD type0 face0 spr$10 (+8,+4) ev$0F
    db $FF   ; $56D2 end
Bank11_Area4_Obj_56D3:          ; $56D3  (object list)
    db $8F,$FF,$04,$05,$10   ; $56D3 HEADER(bit7)
    db $26,$1D,$05,$06,$11   ; $56D8 type6 face2 spr$1D (+5,+6) ev$11
    db $06,$1C,$05,$03,$12   ; $56DD type6 face0 spr$1C (+5,+3) ev$12
    db $00,$4D,$08,$02,$FF   ; $56E2 type0 face0 spr$4D (+8,+2) ev$FF
    db $FF   ; $56E7 end
Bank11_Area4_Obj_56E8:          ; $56E8  (object list)
    db $90,$FF,$05,$05,$29   ; $56E8 HEADER(bit7)
    db $8F,$FF,$04,$05,$10   ; $56ED HEADER(bit7)
    db $37,$1D,$01,$04,$11   ; $56F2 type7 face3 spr$1D (+1,+4) ev$11
    db $06,$1C,$05,$03,$12   ; $56F7 type6 face0 spr$1C (+5,+3) ev$12
    db $00,$4D,$08,$02,$FF   ; $56FC type0 face0 spr$4D (+8,+2) ev$FF
    db $FF   ; $5701 end
Bank11_Area4_Obj_5702:          ; $5702  (object list)
    db $90,$FF,$05,$04,$29   ; $5702 HEADER(bit7)
    db $90,$FF,$05,$05,$29   ; $5707 HEADER(bit7)
    db $90,$FF,$07,$04,$2A   ; $570C HEADER(bit7)
    db $90,$FF,$07,$05,$2A   ; $5711 HEADER(bit7)
    db $37,$1D,$04,$02,$11   ; $5716 type7 face3 spr$1D (+4,+2) ev$11
    db $16,$1C,$05,$02,$12   ; $571B type6 face1 spr$1C (+5,+2) ev$12
    db $00,$4D,$08,$02,$FF   ; $5720 type0 face0 spr$4D (+8,+2) ev$FF
    db $FF   ; $5725 end
Bank11_Area4_Obj_5726:          ; $5726  (object list)
    db $90,$FF,$05,$04,$29   ; $5726 HEADER(bit7)
    db $90,$FF,$05,$05,$29   ; $572B HEADER(bit7)
    db $90,$FF,$07,$04,$2A   ; $5730 HEADER(bit7)
    db $90,$FF,$07,$05,$2A   ; $5735 HEADER(bit7)
    db $37,$1D,$04,$02,$11   ; $573A type7 face3 spr$1D (+4,+2) ev$11
    db $16,$1C,$05,$02,$12   ; $573F type6 face1 spr$1C (+5,+2) ev$12
    db $FF   ; $5744 end
Bank11_Area4_Obj_5745:          ; $5745  (object list)
    db $90,$FF,$05,$04,$29   ; $5745 HEADER(bit7)
    db $90,$FF,$05,$05,$29   ; $574A HEADER(bit7)
    db $90,$FF,$07,$04,$2A   ; $574F HEADER(bit7)
    db $90,$FF,$07,$05,$2A   ; $5754 HEADER(bit7)
    db $36,$1D,$04,$02,$11   ; $5759 type6 face3 spr$1D (+4,+2) ev$11
    db $16,$1C,$05,$02,$12   ; $575E type6 face1 spr$1C (+5,+2) ev$12
    db $10,$08,$04,$05,$13   ; $5763 type0 face1 spr$08 (+4,+5) ev$13
    db $10,$0F,$05,$06,$14   ; $5768 type0 face1 spr$0F (+5,+6) ev$14
    db $FF   ; $576D end
Bank11_Area4_Obj_576E:          ; $576E  (object list)
    db $8F,$FF,$02,$01,$15   ; $576E HEADER(bit7)
    db $17,$05,$02,$02,$16   ; $5773 type7 face1 spr$05 (+2,+2) ev$16
    db $00,$3F,$06,$04,$17   ; $5778 type0 face0 spr$3F (+6,+4) ev$17
    db $FF   ; $577D end
Bank11_Area4_Obj_577E:          ; $577E  (object list)
    db $8F,$FF,$02,$01,$15   ; $577E HEADER(bit7)
    db $17,$05,$02,$02,$16   ; $5783 type7 face1 spr$05 (+2,+2) ev$16
    db $00,$3F,$05,$04,$17   ; $5788 type0 face0 spr$3F (+5,+4) ev$17
    db $FF   ; $578D end
Bank11_Area4_Obj_578E:          ; $578E  (object list)
    db $8F,$FF,$02,$01,$15   ; $578E HEADER(bit7)
    db $17,$05,$02,$02,$16   ; $5793 type7 face1 spr$05 (+2,+2) ev$16
    db $00,$1A,$05,$04,$18   ; $5798 type0 face0 spr$1A (+5,+4) ev$18
    db $FF   ; $579D end
Bank11_Area4_Obj_579E:          ; $579E  (object list)
    db $8F,$FF,$02,$01,$15   ; $579E HEADER(bit7)
    db $17,$05,$02,$02,$16   ; $57A3 type7 face1 spr$05 (+2,+2) ev$16
    db $00,$1A,$06,$04,$18   ; $57A8 type0 face0 spr$1A (+6,+4) ev$18
    db $03,$00,$06,$01,$19   ; $57AD type3 face0 spr$00 (+6,+1) ev$19
    db $FF   ; $57B2 end
Bank11_Area4_Obj_57B3:          ; $57B3  (object list)
    db $00,$00,$05,$03,$1A   ; $57B3 type0 face0 spr$00 (+5,+3) ev$1A
    db $00,$3A,$05,$02,$1B   ; $57B8 type0 face0 spr$3A (+5,+2) ev$1B
    db $30,$44,$04,$06,$1C   ; $57BD type0 face3 spr$44 (+4,+6) ev$1C
    db $FF   ; $57C2 end
Bank11_Area4_Obj_57C3:          ; $57C3  (object list)
    db $00,$00,$05,$03,$1A   ; $57C3 type0 face0 spr$00 (+5,+3) ev$1A
    db $00,$3A,$05,$02,$1B   ; $57C8 type0 face0 spr$3A (+5,+2) ev$1B
    db $30,$45,$04,$06,$1D   ; $57CD type0 face3 spr$45 (+4,+6) ev$1D
    db $FF   ; $57D2 end
Bank11_Area4_Obj_57D3:          ; $57D3  (object list)
    db $00,$00,$05,$03,$1A   ; $57D3 type0 face0 spr$00 (+5,+3) ev$1A
    db $00,$3A,$05,$02,$1B   ; $57D8 type0 face0 spr$3A (+5,+2) ev$1B
    db $32,$01,$04,$05,$1E   ; $57DD type2 face3 spr$01 (+4,+5) ev$1E
    db $00,$11,$07,$05,$1F   ; $57E2 type0 face0 spr$11 (+7,+5) ev$1F
    db $33,$0B,$02,$02,$20   ; $57E7 type3 face3 spr$0B (+2,+2) ev$20
    db $FF   ; $57EC end
Bank11_Area4_Obj_57ED:          ; $57ED  (object list)
    db $FF   ; $57ED end
Bank11_Area4_Obj_57EE:          ; $57EE  (object list)
    db $00,$46,$03,$03,$21   ; $57EE type0 face0 spr$46 (+3,+3) ev$21
    db $FF   ; $57F3 end
Bank11_Area4_Obj_57F4:          ; $57F4  (object list)
    db $02,$47,$02,$01,$22   ; $57F4 type2 face0 spr$47 (+2,+1) ev$22
    db $00,$48,$03,$03,$23   ; $57F9 type0 face0 spr$48 (+3,+3) ev$23
    db $FF   ; $57FE end
Bank11_Area4_Obj_57FF:          ; $57FF  (object list)
    db $10,$12,$05,$01,$24   ; $57FF type0 face1 spr$12 (+5,+1) ev$24
    db $10,$12,$05,$02,$25   ; $5804 type0 face1 spr$12 (+5,+2) ev$25
    db $10,$12,$05,$03,$26   ; $5809 type0 face1 spr$12 (+5,+3) ev$26
    db $01,$04,$01,$02,$27   ; $580E type1 face0 spr$04 (+1,+2) ev$27
    db $00,$0F,$02,$05,$28   ; $5813 type0 face0 spr$0F (+2,+5) ev$28
    db $40,$54,$05,$00,$FF   ; $5818 type0 face4 spr$54 (+5,+0) ev$FF
    db $FF   ; $581D end
Bank11_Area4_Obj_581E:          ; $581E  (object list)
    db $FF   ; $581E end
Bank11_Area4_Obj_581F:          ; $581F  (object list)
    db $FF   ; $581F end
Bank11_Area4_Obj_5820:          ; $5820  (object list)
    db $FF   ; $5820 end
Bank11_Area4_Obj_5821:          ; $5821  (object list)
    db $08,$02,$0B,$01,$00   ; $5821 type8 face0 spr$02 (+11,+1) ev$00
    db $00,$00,$FF,$06,$04   ; $5826 type0 face0 spr$00 (+255,+6) ev$04
    db $05,$00,$02,$06,$04   ; $582B type5 face0 spr$00 (+2,+6) ev$04
    db $FF   ; $5830 end
Bank11_Area4_Obj_5831:          ; $5831  (object list)
    db $07,$05,$00,$00,$05   ; $5831 type7 face0 spr$05 (+0,+0) ev$05
    db $07,$05,$FF,$FF   ; $5836 (tail)

SECTION "Bank 11 Area 5 ObjList $5876", ROMX[$5876], BANK[11]
Bank11_Area5_Obj_5876:          ; $5876  (object list)
    db $01,$3B,$02,$02,$01   ; $5876 type1 face0 spr$3B (+2,+2) ev$01
    db $36,$3A,$04,$06,$02   ; $587B type6 face3 spr$3A (+4,+6) ev$02
    db $00,$3A,$05,$06,$03   ; $5880 type0 face0 spr$3A (+5,+6) ev$03
    db $FF   ; $5885 end
Bank11_Area5_Obj_5886:          ; $5886  (object list)
    db $8F,$FF,$04,$03,$04   ; $5886 HEADER(bit7)
    db $8F,$FF,$05,$03,$04   ; $588B HEADER(bit7)
    db $8F,$FF,$04,$04,$04   ; $5890 HEADER(bit7)
    db $8F,$FF,$05,$04,$04   ; $5895 HEADER(bit7)
    db $01,$1B,$02,$02,$05   ; $589A type1 face0 spr$1B (+2,+2) ev$05
    db $06,$2A,$04,$06,$06   ; $589F type6 face0 spr$2A (+4,+6) ev$06
    db $00,$16,$05,$06,$07   ; $58A4 type0 face0 spr$16 (+5,+6) ev$07
    db $FF   ; $58A9 end
Bank11_Area5_Obj_58AA:          ; $58AA  (object list)
    db $8F,$FF,$04,$02,$FF   ; $58AA HEADER(bit7)
    db $8F,$FF,$05,$02,$FF   ; $58AF HEADER(bit7)
    db $8F,$FF,$04,$03,$08   ; $58B4 HEADER(bit7)
    db $8F,$FF,$05,$03,$08   ; $58B9 HEADER(bit7)
    db $FF   ; $58BE end
Bank11_Area5_Obj_58BF:          ; $58BF  (object list)
    db $8F,$FF,$04,$02,$FF   ; $58BF HEADER(bit7)
    db $8F,$FF,$05,$02,$FF   ; $58C4 HEADER(bit7)
    db $8F,$FF,$04,$03,$08   ; $58C9 HEADER(bit7)
    db $8F,$FF,$05,$03,$08   ; $58CE HEADER(bit7)
    db $00,$49,$01,$01,$09   ; $58D3 type0 face0 spr$49 (+1,+1) ev$09
    db $10,$4A,$08,$03,$0A   ; $58D8 type0 face1 spr$4A (+8,+3) ev$0A
    db $20,$4B,$03,$06,$0B   ; $58DD type0 face2 spr$4B (+3,+6) ev$0B
    db $FF   ; $58E2 end
Bank11_Area5_Obj_58E3:          ; $58E3  (object list)
    db $8F,$FF,$04,$03,$0C   ; $58E3 HEADER(bit7)
    db $8F,$FF,$05,$03,$0D   ; $58E8 HEADER(bit7)
    db $8F,$FF,$07,$00,$0E   ; $58ED HEADER(bit7)
    db $8F,$FF,$08,$00,$0F   ; $58F2 HEADER(bit7)
    db $06,$25,$02,$01,$11   ; $58F7 type6 face0 spr$25 (+2,+1) ev$11
    db $00,$3E,$08,$02,$12   ; $58FC type0 face0 spr$3E (+8,+2) ev$12
    db $37,$21,$03,$03,$10   ; $5901 type7 face3 spr$21 (+3,+3) ev$10
    db $FF   ; $5906 end
Bank11_Area5_Obj_5907:          ; $5907  (object list)
    db $8F,$FF,$04,$03,$0C   ; $5907 HEADER(bit7)
    db $8F,$FF,$05,$03,$0D   ; $590C HEADER(bit7)
    db $8F,$FF,$07,$00,$0E   ; $5911 HEADER(bit7)
    db $8F,$FF,$08,$00,$0F   ; $5916 HEADER(bit7)
    db $06,$25,$02,$01,$11   ; $591B type6 face0 spr$25 (+2,+1) ev$11
    db $00,$3E,$08,$02,$12   ; $5920 type0 face0 spr$3E (+8,+2) ev$12
    db $FF   ; $5925 end
Bank11_Area5_Obj_5926:          ; $5926  (object list)
    db $8F,$FF,$04,$03,$0C   ; $5926 HEADER(bit7)
    db $8F,$FF,$05,$03,$0D   ; $592B HEADER(bit7)
    db $8F,$FF,$07,$00,$0E   ; $5930 HEADER(bit7)
    db $8F,$FF,$08,$00,$0F   ; $5935 HEADER(bit7)
    db $06,$25,$02,$01,$11   ; $593A type6 face0 spr$25 (+2,+1) ev$11
    db $00,$3D,$08,$02,$14   ; $593F type0 face0 spr$3D (+8,+2) ev$14
    db $37,$39,$03,$03,$13   ; $5944 type7 face3 spr$39 (+3,+3) ev$13
    db $FF   ; $5949 end
Bank11_Area5_Obj_594A:          ; $594A  (object list)
    db $8F,$FF,$04,$03,$0C   ; $594A HEADER(bit7)
    db $8F,$FF,$05,$03,$0D   ; $594F HEADER(bit7)
    db $8F,$FF,$07,$00,$0E   ; $5954 HEADER(bit7)
    db $8F,$FF,$08,$00,$0F   ; $5959 HEADER(bit7)
    db $06,$25,$02,$01,$11   ; $595E type6 face0 spr$25 (+2,+1) ev$11
    db $00,$3D,$08,$02,$14   ; $5963 type0 face0 spr$3D (+8,+2) ev$14
    db $FF   ; $5968 end
Bank11_Area5_Obj_5969:          ; $5969  (object list)
    db $04,$00,$1B,$00,$00   ; $5969 type4 face0 spr$00 (+27,+0) ev$00
    db $04,$07,$05,$00,$1B   ; $596E type4 face0 spr$07 (+5,+0) ev$1B
    db $00,$00,$05,$07,$FF   ; $5973 type0 face0 spr$00 (+5,+7) ev$FF
    db $04,$00,$1B,$00,$00   ; $5978 type4 face0 spr$00 (+27,+0) ev$00
    db $04,$07,$05,$00,$1B   ; $597D type4 face0 spr$07 (+5,+0) ev$1B
    db $00,$00,$05,$07,$FF   ; $5982 type0 face0 spr$00 (+5,+7) ev$FF
    db $04,$00,$1C,$00,$00   ; $5987 type4 face0 spr$00 (+28,+0) ev$00
    db $04,$07,$05,$00,$1C   ; $598C type4 face0 spr$07 (+5,+0) ev$1C
    db $00,$00,$05,$07,$FF   ; $5991 type0 face0 spr$00 (+5,+7) ev$FF
    db $06,$04,$04,$00,$04   ; $5996 type6 face0 spr$04 (+4,+0) ev$04
    db $06,$04,$FF   ; $599B (tail)

SECTION "Bank 11 Area 6 ObjList $59BE", ROMX[$59BE], BANK[11]
Bank11_Area6_Obj_59BE:          ; $59BE  (object list)
    db $90,$FF,$05,$04,$01   ; $59BE HEADER(bit7)
    db $50,$E0,$05,$04,$FF   ; $59C3 type0 face5 spr$E0 (+5,+4) ev$FF
    db $70,$E1,$03,$05,$02   ; $59C8 type0 face7 spr$E1 (+3,+5) ev$02
    db $40,$E2,$02,$04,$03   ; $59CD type0 face4 spr$E2 (+2,+4) ev$03
    db $50,$E3,$03,$03,$04   ; $59D2 type0 face5 spr$E3 (+3,+3) ev$04
    db $FF   ; $59D7 end
Bank11_Area6_Obj_59D8:          ; $59D8  (object list)
    db $8F,$FF,$04,$02,$05   ; $59D8 HEADER(bit7)
    db $8F,$FF,$05,$02,$05   ; $59DD HEADER(bit7)
    db $8F,$FF,$03,$04,$06   ; $59E2 HEADER(bit7)
    db $8F,$FF,$06,$06,$07   ; $59E7 HEADER(bit7)
    db $37,$12,$02,$04,$08   ; $59EC type7 face3 spr$12 (+2,+4) ev$08
    db $17,$12,$07,$06,$09   ; $59F1 type7 face1 spr$12 (+7,+6) ev$09
    db $60,$11,$04,$08,$0E   ; $59F6 type0 face6 spr$11 (+4,+8) ev$0E
    db $40,$54,$06,$05,$FF   ; $59FB type0 face4 spr$54 (+6,+5) ev$FF
    db $FF   ; $5A00 end
Bank11_Area6_Obj_5A01:          ; $5A01  (object list)
    db $82,$FF,$06,$05,$0A   ; $5A01 HEADER(bit7)
    db $00,$0B,$06,$04,$0B   ; $5A06 type0 face0 spr$0B (+6,+4) ev$0B
    db $FF   ; $5A0B end
Bank11_Area6_Obj_5A0C:          ; $5A0C  (object list)
    db $05,$00,$07,$00,$04   ; $5A0C type5 face0 spr$00 (+7,+0) ev$04
    db $05,$07,$FF,$04,$07   ; $5A11 type5 face0 spr$07 (+255,+4) ev$07
    db $01,$00,$84,$04,$03   ; $5A16 type1 face0 spr$00 (+132,+4) ev$03
    db $05,$07,$01,$00,$84   ; $5A1B type5 face0 spr$07 (+1,+0) ev$84
    db $05,$03,$FF,$04,$00   ; $5A20 type5 face0 spr$03 (+255,+4) ev$00
    db $07,$00,$06,$04,$07   ; $5A25 type7 face0 spr$00 (+6,+4) ev$07
    db $FF   ; $5A2A end

SECTION "Bank 11 Area 7 ObjList $5A9B", ROMX[$5A9B], BANK[11]
Bank11_Area7_Obj_5A9B:          ; $5A9B  (object list)
    db $82,$FF,$03,$04,$01   ; $5A9B HEADER(bit7)
    db $00,$41,$08,$03,$02   ; $5AA0 type0 face0 spr$41 (+8,+3) ev$02
    db $40,$52,$03,$04,$FF   ; $5AA5 type0 face4 spr$52 (+3,+4) ev$FF
    db $40,$E0,$03,$04,$FF   ; $5AAA type0 face4 spr$E0 (+3,+4) ev$FF
    db $00,$11,$04,$02,$1A   ; $5AAF type0 face0 spr$11 (+4,+2) ev$1A
    db $FF   ; $5AB4 end
Bank11_Area7_Obj_5AB5:          ; $5AB5  (object list)
    db $90,$FF,$03,$05,$03   ; $5AB5 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5ABA HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5ABF HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5AC4 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5AC9 type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5ACE type0 face0 spr$08 (+7,+5) ev$08
    db $FF   ; $5AD3 end
Bank11_Area7_Obj_5AD4:          ; $5AD4  (object list)
    db $90,$FF,$03,$05,$03   ; $5AD4 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5AD9 HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5ADE HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5AE3 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5AE8 type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5AED type0 face0 spr$08 (+7,+5) ev$08
    db $00,$4D,$02,$04,$FF   ; $5AF2 type0 face0 spr$4D (+2,+4) ev$FF
    db $FF   ; $5AF7 end
Bank11_Area7_Obj_5AF8:          ; $5AF8  (object list)
    db $90,$FF,$03,$05,$03   ; $5AF8 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5AFD HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5B02 HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5B07 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5B0C type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5B11 type0 face0 spr$08 (+7,+5) ev$08
    db $FF   ; $5B16 end
Bank11_Area7_Obj_5B17:          ; $5B17  (object list)
    db $90,$FF,$03,$05,$03   ; $5B17 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5B1C HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5B21 HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5B26 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5B2B type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5B30 type0 face0 spr$08 (+7,+5) ev$08
    db $00,$4D,$02,$04,$FF   ; $5B35 type0 face0 spr$4D (+2,+4) ev$FF
    db $00,$4D,$06,$04,$FF   ; $5B3A type0 face0 spr$4D (+6,+4) ev$FF
    db $FF   ; $5B3F end
Bank11_Area7_Obj_5B40:          ; $5B40  (object list)
    db $90,$FF,$03,$05,$03   ; $5B40 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5B45 HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5B4A HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5B4F type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5B54 type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5B59 type0 face0 spr$08 (+7,+5) ev$08
    db $00,$4D,$06,$04,$FF   ; $5B5E type0 face0 spr$4D (+6,+4) ev$FF
    db $FF   ; $5B63 end
Bank11_Area7_Obj_5B64:          ; $5B64  (object list)
    db $90,$FF,$03,$05,$03   ; $5B64 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5B69 HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5B6E HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5B73 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5B78 type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5B7D type0 face0 spr$08 (+7,+5) ev$08
    db $00,$4D,$02,$04,$FF   ; $5B82 type0 face0 spr$4D (+2,+4) ev$FF
    db $FF   ; $5B87 end
Bank11_Area7_Obj_5B88:          ; $5B88  (object list)
    db $90,$FF,$03,$05,$03   ; $5B88 HEADER(bit7)
    db $90,$FF,$04,$05,$04   ; $5B8D HEADER(bit7)
    db $90,$FF,$05,$05,$05   ; $5B92 HEADER(bit7)
    db $06,$1F,$04,$02,$06   ; $5B97 type6 face0 spr$1F (+4,+2) ev$06
    db $00,$08,$03,$06,$07   ; $5B9C type0 face0 spr$08 (+3,+6) ev$07
    db $00,$08,$07,$05,$08   ; $5BA1 type0 face0 spr$08 (+7,+5) ev$08
    db $FF   ; $5BA6 end
Bank11_Area7_Obj_5BA7:          ; $5BA7  (object list)
    db $8F,$FF,$01,$02,$09   ; $5BA7 HEADER(bit7)
    db $8F,$FF,$02,$02,$0A   ; $5BAC HEADER(bit7)
    db $00,$04,$03,$04,$0B   ; $5BB1 type0 face0 spr$04 (+3,+4) ev$0B
    db $00,$0B,$06,$02,$0C   ; $5BB6 type0 face0 spr$0B (+6,+2) ev$0C
    db $17,$0A,$08,$05,$0D   ; $5BBB type7 face1 spr$0A (+8,+5) ev$0D
    db $FF   ; $5BC0 end
Bank11_Area7_Obj_5BC1:          ; $5BC1  (object list)
    db $07,$09,$02,$01,$0E   ; $5BC1 type7 face0 spr$09 (+2,+1) ev$0E
    db $04,$42,$08,$05,$0F   ; $5BC6 type4 face0 spr$42 (+8,+5) ev$0F
    db $30,$0A,$01,$06,$10   ; $5BCB type0 face3 spr$0A (+1,+6) ev$10
    db $FF   ; $5BD0 end
Bank11_Area7_Obj_5BD1:          ; $5BD1  (object list)
    db $04,$09,$08,$05,$0E   ; $5BD1 type4 face0 spr$09 (+8,+5) ev$0E
    db $06,$42,$02,$01,$0F   ; $5BD6 type6 face0 spr$42 (+2,+1) ev$0F
    db $30,$0A,$01,$06,$10   ; $5BDB type0 face3 spr$0A (+1,+6) ev$10
    db $FF   ; $5BE0 end
Bank11_Area7_Obj_5BE1:          ; $5BE1  (object list)
    db $00,$0B,$05,$01,$11   ; $5BE1 type0 face0 spr$0B (+5,+1) ev$11
    db $20,$0F,$05,$02,$12   ; $5BE6 type0 face2 spr$0F (+5,+2) ev$12
    db $22,$17,$04,$05,$FF   ; $5BEB type2 face2 spr$17 (+4,+5) ev$FF
    db $FF   ; $5BF0 end
Bank11_Area7_Obj_5BF1:          ; $5BF1  (object list)
    db $8F,$FF,$08,$03,$13   ; $5BF1 HEADER(bit7)
    db $8F,$FF,$07,$04,$14   ; $5BF6 HEADER(bit7)
    db $8F,$FF,$06,$05,$15   ; $5BFB HEADER(bit7)
    db $8F,$FF,$06,$06,$16   ; $5C00 HEADER(bit7)
    db $06,$0A,$03,$02,$17   ; $5C05 type6 face0 spr$0A (+3,+2) ev$17
    db $26,$20,$03,$03,$18   ; $5C0A type6 face2 spr$20 (+3,+3) ev$18
    db $30,$0B,$02,$06,$19   ; $5C0F type0 face3 spr$0B (+2,+6) ev$19
    db $40,$E0,$05,$00,$FF   ; $5C14 type0 face4 spr$E0 (+5,+0) ev$FF
    db $40,$E1,$05,$00,$FF   ; $5C19 type0 face4 spr$E1 (+5,+0) ev$FF
    db $40,$E2,$05,$00,$FF   ; $5C1E type0 face4 spr$E2 (+5,+0) ev$FF
    db $40,$E3,$05,$00,$FF   ; $5C23 type0 face4 spr$E3 (+5,+0) ev$FF
    db $FF   ; $5C28 end
Bank11_Area7_Obj_5C29:          ; $5C29  (object list)
    db $05,$01,$1D,$00,$00   ; $5C29 type5 face0 spr$01 (+29,+0) ev$00
    db $05,$07,$FF,$FF,$05   ; $5C2E type5 face0 spr$07 (+255,+255) ev$05
    db $02,$1F,$00,$00,$05   ; $5C33 type2 face0 spr$1F (+0,+0) ev$05
    db $02,$FF,$05,$02,$1F   ; $5C38 type2 face0 spr$FF (+5,+2) ev$1F
    db $00,$00,$05,$02,$02   ; $5C3D type0 face0 spr$00 (+5,+2) ev$02
    db $04,$0E,$01,$00,$00   ; $5C42 type4 face0 spr$0E (+1,+0) ev$00
    db $00,$FF,$05,$02,$1F   ; $5C47 type0 face0 spr$FF (+5,+2) ev$1F
    db $00,$00,$05,$02,$02   ; $5C4C type0 face0 spr$00 (+5,+2) ev$02
    db $04,$0E,$01,$00,$00   ; $5C51 type4 face0 spr$0E (+1,+0) ev$00
    db $00,$06,$04,$1D,$01   ; $5C56 type0 face0 spr$06 (+4,+29) ev$01
    db $00,$00,$00,$FF,$05   ; $5C5B type0 face0 spr$00 (+0,+255) ev$05
    db $01,$1E,$00,$00,$05   ; $5C60 type1 face0 spr$1E (+0,+0) ev$05
    db $07,$FF,$05,$07,$06   ; $5C65 type7 face0 spr$FF (+5,+7) ev$06
    db $00,$00,$05,$00,$FF   ; $5C6A type0 face0 spr$00 (+5,+0) ev$FF
    db $04,$07,$06,$00,$01   ; $5C6F type4 face0 spr$07 (+6,+0) ev$01
    db $04,$03,$05,$07,$06   ; $5C74 type4 face0 spr$03 (+5,+7) ev$06
    db $00,$01,$05,$03,$FF   ; $5C79 type0 face0 spr$01 (+5,+3) ev$FF
    db $04,$07,$06,$00,$02   ; $5C7E type4 face0 spr$07 (+6,+0) ev$02
    db $04,$00,$FF   ; $5C83 (tail)

SECTION "Bank 11 Area 8 ObjList $5CC0", ROMX[$5CC0], BANK[11]
Bank11_Area8_Obj_5CC0:          ; $5CC0  (object list)
    db $20,$08,$05,$08,$FF   ; $5CC0 type0 face2 spr$08 (+5,+8) ev$FF
    db $40,$F0,$05,$04,$FF   ; $5CC5 type0 face4 spr$F0 (+5,+4) ev$FF
    db $40,$F1,$05,$04,$FF   ; $5CCA type0 face4 spr$F1 (+5,+4) ev$FF
    db $FF   ; $5CCF end
Bank11_Area8_Obj_5CD0:          ; $5CD0  (object list)
    db $20,$08,$05,$08,$FF   ; $5CD0 type0 face2 spr$08 (+5,+8) ev$FF
    db $00,$55,$05,$04,$FF   ; $5CD5 type0 face0 spr$55 (+5,+4) ev$FF
    db $00,$55,$05,$04,$FF   ; $5CDA type0 face0 spr$55 (+5,+4) ev$FF
    db $FF   ; $5CDF end
Bank11_Area8_Obj_5CE0:          ; $5CE0  (object list)
    db $20,$08,$05,$08,$FF   ; $5CE0 type0 face2 spr$08 (+5,+8) ev$FF
    db $40,$F0,$05,$04,$FF   ; $5CE5 type0 face4 spr$F0 (+5,+4) ev$FF
    db $40,$55,$05,$04,$FF   ; $5CEA type0 face4 spr$55 (+5,+4) ev$FF
    db $FF   ; $5CEF end
Bank11_Area8_Obj_5CF0:          ; $5CF0  (object list)
    db $20,$08,$05,$08,$FF   ; $5CF0 type0 face2 spr$08 (+5,+8) ev$FF
    db $40,$F0,$05,$04,$FF   ; $5CF5 type0 face4 spr$F0 (+5,+4) ev$FF
    db $40,$F1,$05,$04,$FF   ; $5CFA type0 face4 spr$F1 (+5,+4) ev$FF
    db $FF   ; $5CFF end
Bank11_Area8_Obj_5D00:          ; $5D00  (object list)
    db $20,$08,$05,$08,$FF   ; $5D00 type0 face2 spr$08 (+5,+8) ev$FF
    db $00,$55,$05,$04,$FF   ; $5D05 type0 face0 spr$55 (+5,+4) ev$FF
    db $00,$55,$05,$04,$FF   ; $5D0A type0 face0 spr$55 (+5,+4) ev$FF
    db $FF   ; $5D0F end
Bank11_Area8_Obj_5D10:          ; $5D10  (object list)
    db $60,$08,$05,$08,$FF   ; $5D10 type0 face6 spr$08 (+5,+8) ev$FF
    db $20,$5E,$05,$04,$FF   ; $5D15 type0 face2 spr$5E (+5,+4) ev$FF
    db $FF   ; $5D1A end
Bank11_Area8_Obj_5D1B:          ; $5D1B  (object list)
    db $60,$08,$05,$08,$FF   ; $5D1B type0 face6 spr$08 (+5,+8) ev$FF
    db $70,$21,$00,$04,$FF   ; $5D20 type0 face7 spr$21 (+0,+4) ev$FF
    db $40,$55,$05,$04,$FF   ; $5D25 type0 face4 spr$55 (+5,+4) ev$FF
    db $20,$5E,$05,$07,$FF   ; $5D2A type0 face2 spr$5E (+5,+7) ev$FF
    db $FF   ; $5D2F end
Bank11_Area8_Obj_5D30:          ; $5D30  (object list)
    db $20,$08,$05,$07,$FF   ; $5D30 type0 face2 spr$08 (+5,+7) ev$FF
    db $40,$21,$05,$04,$FF   ; $5D35 type0 face4 spr$21 (+5,+4) ev$FF
    db $40,$55,$05,$04,$FF   ; $5D3A type0 face4 spr$55 (+5,+4) ev$FF
    db $20,$5E,$05,$06,$FF   ; $5D3F type0 face2 spr$5E (+5,+6) ev$FF
    db $FF   ; $5D44 end

SECTION "Bank 11 Area 9 ObjList $5D8B", ROMX[$5D8B], BANK[11]
Bank11_Area9_Obj_5D8B:          ; $5D8B  (object list)
    db $8F,$FF,$05,$00,$01   ; $5D8B HEADER(bit7)
    db $8F,$FF,$07,$00,$02   ; $5D90 HEADER(bit7)
    db $8F,$FF,$08,$00,$03   ; $5D95 HEADER(bit7)
    db $00,$26,$02,$01,$04   ; $5D9A type0 face0 spr$26 (+2,+1) ev$04
    db $00,$08,$05,$01,$05   ; $5D9F type0 face0 spr$08 (+5,+1) ev$05
    db $00,$0F,$06,$04,$06   ; $5DA4 type0 face0 spr$0F (+6,+4) ev$06
    db $40,$E0,$05,$00,$FF   ; $5DA9 type0 face4 spr$E0 (+5,+0) ev$FF
    db $40,$E1,$05,$00,$FF   ; $5DAE type0 face4 spr$E1 (+5,+0) ev$FF
    db $40,$E2,$05,$00,$FF   ; $5DB3 type0 face4 spr$E2 (+5,+0) ev$FF
    db $40,$E3,$05,$00,$FF   ; $5DB8 type0 face4 spr$E3 (+5,+0) ev$FF
    db $FF   ; $5DBD end
Bank11_Area9_Obj_5DBE:          ; $5DBE  (object list)
    db $8F,$FF,$05,$00,$01   ; $5DBE HEADER(bit7)
    db $8F,$FF,$07,$00,$02   ; $5DC3 HEADER(bit7)
    db $8F,$FF,$08,$00,$03   ; $5DC8 HEADER(bit7)
    db $81,$FF,$05,$03,$07   ; $5DCD HEADER(bit7)
    db $00,$26,$02,$01,$04   ; $5DD2 type0 face0 spr$26 (+2,+1) ev$04
    db $00,$08,$04,$03,$05   ; $5DD7 type0 face0 spr$08 (+4,+3) ev$05
    db $00,$0F,$06,$04,$06   ; $5DDC type0 face0 spr$0F (+6,+4) ev$06
    db $40,$E0,$07,$00,$FF   ; $5DE1 type0 face4 spr$E0 (+7,+0) ev$FF
    db $40,$E1,$07,$00,$FF   ; $5DE6 type0 face4 spr$E1 (+7,+0) ev$FF
    db $40,$E2,$07,$00,$FF   ; $5DEB type0 face4 spr$E2 (+7,+0) ev$FF
    db $40,$E3,$07,$00,$FF   ; $5DF0 type0 face4 spr$E3 (+7,+0) ev$FF
    db $FF   ; $5DF5 end
Bank11_Area9_Obj_5DF6:          ; $5DF6  (object list)
    db $8F,$FF,$05,$00,$01   ; $5DF6 HEADER(bit7)
    db $8F,$FF,$07,$00,$02   ; $5DFB HEADER(bit7)
    db $8F,$FF,$08,$00,$03   ; $5E00 HEADER(bit7)
    db $40,$26,$02,$02,$04   ; $5E05 type0 face4 spr$26 (+2,+2) ev$04
    db $30,$08,$06,$05,$FF   ; $5E0A type0 face3 spr$08 (+6,+5) ev$FF
    db $40,$E0,$02,$00,$FF   ; $5E0F type0 face4 spr$E0 (+2,+0) ev$FF
    db $40,$E0,$07,$00,$FF   ; $5E14 type0 face4 spr$E0 (+7,+0) ev$FF
    db $40,$E1,$07,$00,$FF   ; $5E19 type0 face4 spr$E1 (+7,+0) ev$FF
    db $40,$E2,$07,$00,$FF   ; $5E1E type0 face4 spr$E2 (+7,+0) ev$FF
    db $40,$E3,$07,$00,$FF   ; $5E23 type0 face4 spr$E3 (+7,+0) ev$FF
    db $FF   ; $5E28 end
Bank11_Area9_Obj_5E29:          ; $5E29  (object list)
    db $10,$08,$08,$06,$FF   ; $5E29 type0 face1 spr$08 (+8,+6) ev$FF
    db $FF   ; $5E2E end
Bank11_Area9_Obj_5E2F:          ; $5E2F  (object list)
    db $FF   ; $5E2F end
Bank11_Area9_Obj_5E30:          ; $5E30  (object list)
    db $90,$FF,$08,$01,$0B   ; $5E30 HEADER(bit7)
    db $00,$07,$03,$02,$08   ; $5E35 type0 face0 spr$07 (+3,+2) ev$08
    db $00,$0B,$02,$04,$09   ; $5E3A type0 face0 spr$0B (+2,+4) ev$09
    db $00,$11,$07,$05,$0A   ; $5E3F type0 face0 spr$11 (+7,+5) ev$0A
    db $00,$08,$04,$01,$FF   ; $5E44 type0 face0 spr$08 (+4,+1) ev$FF
    db $FF   ; $5E49 end
Bank11_Area9_Obj_5E4A:          ; $5E4A  (object list)
    db $90,$FF,$08,$01,$0B   ; $5E4A HEADER(bit7)
    db $00,$07,$03,$02,$08   ; $5E4F type0 face0 spr$07 (+3,+2) ev$08
    db $00,$0B,$02,$04,$09   ; $5E54 type0 face0 spr$0B (+2,+4) ev$09
    db $00,$11,$07,$05,$0A   ; $5E59 type0 face0 spr$11 (+7,+5) ev$0A
    db $FF   ; $5E5E end
Bank11_Area9_Obj_5E5F:          ; $5E5F  (object list)
    db $FF   ; $5E5F end
Bank11_Area9_Obj_5E60:          ; $5E60  (object list)
    db $04,$06,$01,$00,$0C   ; $5E60 type4 face0 spr$06 (+1,+0) ev$0C
    db $04,$06,$FF,$FF,$FF   ; $5E65 type4 face0 spr$06 (+255,+255) ev$FF

SECTION "Bank 11 Area 10 ObjList $5E82", ROMX[$5E82], BANK[11]
Bank11_Area10_Obj_5E82:          ; $5E82  (object list)
    db $FF   ; $5E82 end
Bank11_Area10_Obj_5E83:          ; $5E83  (object list)
    db $FF   ; $5E83 end
Bank11_Area10_Obj_5E84:          ; $5E84  (object list)
    db $07,$07,$00,$00,$81   ; $5E84 type7 face0 spr$07 (+0,+0) ev$81
    db $07,$01,$FF,$03,$07   ; $5E89 type7 face0 spr$01 (+255,+3) ev$07
    db $16,$00,$80,$03,$01   ; $5E8E type6 face1 spr$00 (+128,+3) ev$01
    db $FF   ; $5E93 end

SECTION "Bank 11 Area 12 ObjList $5E9E", ROMX[$5E9E], BANK[11]
Bank11_Area12_Obj_5E9E:          ; $5E9E  (object list)
    db $8F,$FF,$01,$01,$01   ; $5E9E HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $5EA3 HEADER(bit7)
    db $8F,$FF,$03,$01,$03   ; $5EA8 HEADER(bit7)
    db $82,$FF,$02,$04,$04   ; $5EAD HEADER(bit7)
    db $00,$0F,$02,$03,$05   ; $5EB2 type0 face0 spr$0F (+2,+3) ev$05
    db $FF   ; $5EB7 end
Bank11_Area12_Obj_5EB8:          ; $5EB8  (object list)
    db $02,$07,$01,$00,$8D   ; $5EB8 type2 face0 spr$07 (+1,+0) ev$8D
    db $02,$01,$FF   ; $5EBD (tail)

SECTION "Bank 11 Area 13 ObjList $5ED0", ROMX[$5ED0], BANK[11]
Bank11_Area13_Obj_5ED0:          ; $5ED0  (object list)
    db $90,$FF,$06,$04,$08   ; $5ED0 HEADER(bit7)
    db $90,$FF,$07,$05,$08   ; $5ED5 HEADER(bit7)
    db $90,$FF,$08,$05,$09   ; $5EDA HEADER(bit7)
    db $8F,$FF,$02,$01,$01   ; $5EDF HEADER(bit7)
    db $8F,$FF,$03,$01,$02   ; $5EE4 HEADER(bit7)
    db $8F,$FF,$01,$05,$03   ; $5EE9 HEADER(bit7)
    db $8F,$FF,$01,$06,$04   ; $5EEE HEADER(bit7)
    db $00,$05,$03,$05,$05   ; $5EF3 type0 face0 spr$05 (+3,+5) ev$05
    db $00,$04,$06,$03,$06   ; $5EF8 type0 face0 spr$04 (+6,+3) ev$06
    db $00,$08,$08,$04,$07   ; $5EFD type0 face0 spr$08 (+8,+4) ev$07
    db $00,$4D,$08,$02,$FF   ; $5F02 type0 face0 spr$4D (+8,+2) ev$FF
    db $FF   ; $5F07 end
Bank11_Area13_Obj_5F08:          ; $5F08  (object list)
    db $90,$FF,$06,$04,$08   ; $5F08 HEADER(bit7)
    db $90,$FF,$07,$05,$08   ; $5F0D HEADER(bit7)
    db $90,$FF,$08,$05,$09   ; $5F12 HEADER(bit7)
    db $8F,$FF,$02,$01,$01   ; $5F17 HEADER(bit7)
    db $8F,$FF,$03,$01,$02   ; $5F1C HEADER(bit7)
    db $8F,$FF,$01,$05,$03   ; $5F21 HEADER(bit7)
    db $8F,$FF,$01,$06,$04   ; $5F26 HEADER(bit7)
    db $00,$05,$03,$05,$05   ; $5F2B type0 face0 spr$05 (+3,+5) ev$05
    db $00,$04,$06,$03,$06   ; $5F30 type0 face0 spr$04 (+6,+3) ev$06
    db $00,$08,$08,$04,$07   ; $5F35 type0 face0 spr$08 (+8,+4) ev$07
    db $FF   ; $5F3A end
Bank11_Area13_Obj_5F3B:          ; $5F3B  (object list)
    db $05,$07,$01,$00,$8C   ; $5F3B type5 face0 spr$07 (+1,+0) ev$8C
    db $05,$01,$08,$02,$1E   ; $5F40 type5 face0 spr$01 (+8,+2) ev$1E
    db $01,$00,$00,$00,$FF   ; $5F45 type1 face0 spr$00 (+0,+0) ev$FF

SECTION "Bank 11 Area 15 ObjList $5F54", ROMX[$5F54], BANK[11]
Bank11_Area15_Obj_5F54:          ; $5F54  (object list)
    db $8F,$FF,$05,$03,$01   ; $5F54 HEADER(bit7)
    db $8F,$FF,$03,$05,$02   ; $5F59 HEADER(bit7)
    db $00,$09,$05,$02,$01   ; $5F5E type0 face0 spr$09 (+5,+2) ev$01
    db $30,$02,$02,$05,$02   ; $5F63 type0 face3 spr$02 (+2,+5) ev$02
    db $FF   ; $5F68 end
Bank11_Area15_Obj_5F69:          ; $5F69  (object list)
    db $05,$07,$01,$00,$89   ; $5F69 type5 face0 spr$07 (+1,+0) ev$89
    db $05,$01,$FF   ; $5F6E (tail)

SECTION "Bank 11 Area 16 ObjList $5F81", ROMX[$5F81], BANK[11]
Bank11_Area16_Obj_5F81:          ; $5F81  (object list)
    db $8F,$FF,$02,$01,$01   ; $5F81 HEADER(bit7)
    db $8F,$FF,$03,$01,$02   ; $5F86 HEADER(bit7)
    db $8F,$FF,$04,$01,$03   ; $5F8B HEADER(bit7)
    db $82,$FF,$05,$04,$04   ; $5F90 HEADER(bit7)
    db $20,$03,$05,$03,$05   ; $5F95 type0 face2 spr$03 (+5,+3) ev$05
    db $00,$0A,$04,$06,$06   ; $5F9A type0 face0 spr$0A (+4,+6) ev$06
    db $50,$21,$0A,$00,$FF   ; $5F9F type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $5FA4 end
Bank11_Area16_Obj_5FA5:          ; $5FA5  (object list)
    db $90,$FF,$07,$06,$07   ; $5FA5 HEADER(bit7)
    db $90,$FF,$08,$05,$07   ; $5FAA HEADER(bit7)
    db $8F,$FF,$02,$01,$01   ; $5FAF HEADER(bit7)
    db $8F,$FF,$03,$01,$02   ; $5FB4 HEADER(bit7)
    db $8F,$FF,$04,$01,$03   ; $5FB9 HEADER(bit7)
    db $82,$FF,$05,$04,$04   ; $5FBE HEADER(bit7)
    db $00,$0A,$04,$06,$06   ; $5FC3 type0 face0 spr$0A (+4,+6) ev$06
    db $FF   ; $5FC8 end
Bank11_Area16_Obj_5FC9:          ; $5FC9  (object list)
    db $04,$07,$01,$00,$8C   ; $5FC9 type4 face0 spr$07 (+1,+0) ev$8C
    db $04,$04,$FF,$04,$07   ; $5FCE type4 face0 spr$04 (+255,+4) ev$07
    db $01,$00,$8C,$04,$04   ; $5FD3 type1 face0 spr$00 (+140,+4) ev$04
    db $08,$06,$00,$00,$01   ; $5FD8 type8 face0 spr$06 (+0,+0) ev$01
    db $04,$05,$FF   ; $5FDD (tail)

SECTION "Bank 11 Area 18 ObjList $6006", ROMX[$6006], BANK[11]
Bank11_Area18_Obj_6006:          ; $6006  (object list)
    db $8F,$FF,$01,$01,$01   ; $6006 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $600B HEADER(bit7)
    db $8F,$FF,$03,$01,$03   ; $6010 HEADER(bit7)
    db $8F,$FF,$04,$01,$04   ; $6015 HEADER(bit7)
    db $8F,$FF,$07,$01,$05   ; $601A HEADER(bit7)
    db $8F,$FF,$08,$01,$06   ; $601F HEADER(bit7)
    db $8F,$FF,$02,$04,$07   ; $6024 HEADER(bit7)
    db $8F,$FF,$03,$04,$08   ; $6029 HEADER(bit7)
    db $8F,$FF,$04,$04,$09   ; $602E HEADER(bit7)
    db $8F,$FF,$06,$04,$0A   ; $6033 HEADER(bit7)
    db $8F,$FF,$07,$04,$0B   ; $6038 HEADER(bit7)
    db $8F,$FF,$06,$01,$0C   ; $603D HEADER(bit7)
    db $10,$02,$02,$06,$0D   ; $6042 type0 face1 spr$02 (+2,+6) ev$0D
    db $FF   ; $6047 end
Bank11_Area18_Obj_6048:          ; $6048  (object list)
    db $82,$FF,$04,$03,$0E   ; $6048 HEADER(bit7)
    db $00,$02,$04,$02,$0F   ; $604D type0 face0 spr$02 (+4,+2) ev$0F
    db $00,$03,$06,$03,$11   ; $6052 type0 face0 spr$03 (+6,+3) ev$11
    db $30,$03,$01,$06,$10   ; $6057 type0 face3 spr$03 (+1,+6) ev$10
    db $40,$54,$06,$02,$FF   ; $605C type0 face4 spr$54 (+6,+2) ev$FF
    db $FF   ; $6061 end
Bank11_Area18_Obj_6062:          ; $6062  (object list)
    db $82,$FF,$04,$03,$0E   ; $6062 HEADER(bit7)
    db $00,$02,$04,$02,$0F   ; $6067 type0 face0 spr$02 (+4,+2) ev$0F
    db $30,$03,$01,$06,$10   ; $606C type0 face3 spr$03 (+1,+6) ev$10
    db $FF   ; $6071 end
Bank11_Area18_Obj_6072:          ; $6072  (object list)
    db $FF   ; $6072 end
Bank11_Area18_Obj_6073:          ; $6073  (object list)
    db $05,$07,$01,$00,$88   ; $6073 type5 face0 spr$07 (+1,+0) ev$88
    db $05,$03,$06,$01,$13   ; $6078 type5 face0 spr$03 (+6,+1) ev$13
    db $00,$00,$06,$07,$FF   ; $607D type0 face0 spr$00 (+6,+7) ev$FF

SECTION "Bank 11 Area 19 ObjList $6092", ROMX[$6092], BANK[11]
Bank11_Area19_Obj_6092:          ; $6092  (object list)
    db $8F,$FF,$01,$01,$01   ; $6092 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $6097 HEADER(bit7)
    db $8F,$FF,$03,$01,$03   ; $609C HEADER(bit7)
    db $8F,$FF,$04,$01,$04   ; $60A1 HEADER(bit7)
    db $8F,$FF,$05,$01,$05   ; $60A6 HEADER(bit7)
    db $8F,$FF,$06,$01,$06   ; $60AB HEADER(bit7)
    db $8F,$FF,$07,$01,$07   ; $60B0 HEADER(bit7)
    db $8F,$FF,$08,$01,$08   ; $60B5 HEADER(bit7)
    db $8F,$FF,$01,$04,$09   ; $60BA HEADER(bit7)
    db $8F,$FF,$02,$04,$0A   ; $60BF HEADER(bit7)
    db $8F,$FF,$03,$04,$0B   ; $60C4 HEADER(bit7)
    db $8F,$FF,$04,$04,$0C   ; $60C9 HEADER(bit7)
    db $8F,$FF,$07,$04,$0D   ; $60CE HEADER(bit7)
    db $8F,$FF,$08,$04,$0E   ; $60D3 HEADER(bit7)
    db $10,$03,$06,$04,$0F   ; $60D8 type0 face1 spr$03 (+6,+4) ev$0F
    db $00,$4D,$01,$06,$FF   ; $60DD type0 face0 spr$4D (+1,+6) ev$FF
    db $FF   ; $60E2 end
Bank11_Area19_Obj_60E3:          ; $60E3  (object list)
    db $8F,$FF,$01,$01,$01   ; $60E3 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $60E8 HEADER(bit7)
    db $8F,$FF,$03,$01,$03   ; $60ED HEADER(bit7)
    db $8F,$FF,$04,$01,$04   ; $60F2 HEADER(bit7)
    db $8F,$FF,$05,$01,$05   ; $60F7 HEADER(bit7)
    db $8F,$FF,$06,$01,$06   ; $60FC HEADER(bit7)
    db $8F,$FF,$07,$01,$07   ; $6101 HEADER(bit7)
    db $8F,$FF,$08,$01,$08   ; $6106 HEADER(bit7)
    db $8F,$FF,$01,$04,$09   ; $610B HEADER(bit7)
    db $8F,$FF,$02,$04,$0A   ; $6110 HEADER(bit7)
    db $8F,$FF,$03,$04,$0B   ; $6115 HEADER(bit7)
    db $8F,$FF,$04,$04,$0C   ; $611A HEADER(bit7)
    db $8F,$FF,$07,$04,$0D   ; $611F HEADER(bit7)
    db $8F,$FF,$08,$04,$0E   ; $6124 HEADER(bit7)
    db $10,$03,$06,$04,$0F   ; $6129 type0 face1 spr$03 (+6,+4) ev$0F
    db $FF   ; $612E end
Bank11_Area19_Obj_612F:          ; $612F  (object list)
    db $06,$07,$12,$00,$84   ; $612F type6 face0 spr$07 (+18,+0) ev$84
    db $06,$01,$01,$06,$14   ; $6134 type6 face0 spr$01 (+1,+6) ev$14
    db $01,$00,$00,$00,$FF   ; $6139 type1 face0 spr$00 (+0,+0) ev$FF

SECTION "Bank 11 Area 22 ObjList $6166", ROMX[$6166], BANK[11]
Bank11_Area22_Obj_6166:          ; $6166  (object list)
    db $82,$FF,$02,$04,$01   ; $6166 HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $616B type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$03,$02,$03   ; $6170 type0 face0 spr$4C (+3,+2) ev$03
    db $FF   ; $6175 end
Bank11_Area22_Obj_6176:          ; $6176  (object list)
    db $82,$FF,$02,$04,$01   ; $6176 HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $617B type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$03,$02,$03   ; $6180 type0 face0 spr$4C (+3,+2) ev$03
    db $00,$4D,$01,$06,$FF   ; $6185 type0 face0 spr$4D (+1,+6) ev$FF
    db $FF   ; $618A end
Bank11_Area22_Obj_618B:          ; $618B  (object list)
    db $82,$FF,$02,$04,$01   ; $618B HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $6190 type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$03,$02,$03   ; $6195 type0 face0 spr$4C (+3,+2) ev$03
    db $FF   ; $619A end
Bank11_Area22_Obj_619B:          ; $619B  (object list)
    db $82,$FF,$02,$04,$01   ; $619B HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $61A0 type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$01,$02,$03   ; $61A5 type0 face0 spr$4C (+1,+2) ev$03
    db $FF   ; $61AA end
Bank11_Area22_Obj_61AB:          ; $61AB  (object list)
    db $82,$FF,$02,$04,$01   ; $61AB HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $61B0 type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$01,$02,$03   ; $61B5 type0 face0 spr$4C (+1,+2) ev$03
    db $00,$4D,$01,$06,$FF   ; $61BA type0 face0 spr$4D (+1,+6) ev$FF
    db $FF   ; $61BF end
Bank11_Area22_Obj_61C0:          ; $61C0  (object list)
    db $82,$FF,$02,$04,$01   ; $61C0 HEADER(bit7)
    db $00,$13,$02,$03,$02   ; $61C5 type0 face0 spr$13 (+2,+3) ev$02
    db $00,$4C,$01,$02,$03   ; $61CA type0 face0 spr$4C (+1,+2) ev$03
    db $FF   ; $61CF end
Bank11_Area22_Obj_61D0:          ; $61D0  (object list)
    db $03,$07,$01,$00,$81   ; $61D0 type3 face0 spr$07 (+1,+0) ev$81
    db $03,$02,$FF,$03,$07   ; $61D5 type3 face0 spr$02 (+255,+3) ev$07
    db $01,$00,$81,$03,$02   ; $61DA type1 face0 spr$00 (+129,+3) ev$02
    db $03,$01,$0A,$00,$01   ; $61DF type3 face0 spr$01 (+10,+0) ev$01
    db $03,$07,$01,$06,$11   ; $61E4 type3 face0 spr$07 (+1,+6) ev$11
    db $01,$00,$00,$00,$FF   ; $61E9 type1 face0 spr$00 (+0,+0) ev$FF
    db $03,$07,$01,$00,$81   ; $61EE type3 face0 spr$07 (+1,+0) ev$81
    db $03,$02,$03,$01,$0A   ; $61F3 type3 face0 spr$02 (+3,+1) ev$0A
    db $00,$01,$03,$07,$FF   ; $61F8 type0 face0 spr$01 (+3,+7) ev$FF

SECTION "Bank 11 Area 24 ObjList $6229", ROMX[$6229], BANK[11]
Bank11_Area24_Obj_6229:          ; $6229  (object list)
    db $FF   ; $6229 end
Bank11_Area24_Obj_622A:          ; $622A  (object list)
    db $8F,$FF,$01,$01,$01   ; $622A HEADER(bit7)
    db $8F,$FF,$07,$01,$02   ; $622F HEADER(bit7)
    db $8F,$FF,$08,$01,$03   ; $6234 HEADER(bit7)
    db $8F,$FF,$02,$05,$04   ; $6239 HEADER(bit7)
    db $8F,$FF,$03,$05,$04   ; $623E HEADER(bit7)
    db $8F,$FF,$02,$06,$04   ; $6243 HEADER(bit7)
    db $8F,$FF,$03,$06,$04   ; $6248 HEADER(bit7)
    db $8F,$FF,$01,$06,$05   ; $624D HEADER(bit7)
    db $82,$FF,$06,$04,$06   ; $6252 HEADER(bit7)
    db $07,$43,$06,$03,$07   ; $6257 type7 face0 spr$43 (+6,+3) ev$07
    db $02,$07,$06,$05,$08   ; $625C type2 face0 spr$07 (+6,+5) ev$08
    db $FF   ; $6261 end
Bank11_Area24_Obj_6262:          ; $6262  (object list)
    db $8F,$FF,$01,$01,$01   ; $6262 HEADER(bit7)
    db $8F,$FF,$07,$01,$02   ; $6267 HEADER(bit7)
    db $8F,$FF,$08,$01,$03   ; $626C HEADER(bit7)
    db $8F,$FF,$01,$06,$05   ; $6271 HEADER(bit7)
    db $82,$FF,$06,$04,$06   ; $6276 HEADER(bit7)
    db $07,$43,$06,$03,$07   ; $627B type7 face0 spr$43 (+6,+3) ev$07
    db $02,$07,$06,$05,$08   ; $6280 type2 face0 spr$07 (+6,+5) ev$08
    db $00,$4D,$02,$06,$FF   ; $6285 type0 face0 spr$4D (+2,+6) ev$FF
    db $FF   ; $628A end
Bank11_Area24_Obj_628B:          ; $628B  (object list)
    db $8F,$FF,$01,$01,$01   ; $628B HEADER(bit7)
    db $8F,$FF,$07,$01,$02   ; $6290 HEADER(bit7)
    db $8F,$FF,$08,$01,$03   ; $6295 HEADER(bit7)
    db $8F,$FF,$01,$06,$05   ; $629A HEADER(bit7)
    db $82,$FF,$06,$04,$06   ; $629F HEADER(bit7)
    db $07,$43,$06,$03,$07   ; $62A4 type7 face0 spr$43 (+6,+3) ev$07
    db $02,$07,$06,$05,$08   ; $62A9 type2 face0 spr$07 (+6,+5) ev$08
    db $FF   ; $62AE end
Bank11_Area24_Obj_62AF:          ; $62AF  (object list)
    db $04,$00,$01,$00,$08   ; $62AF type4 face0 spr$00 (+1,+0) ev$08
    db $04,$05,$FF,$FF,$02   ; $62B4 type4 face0 spr$05 (+255,+255) ev$02
    db $06,$08,$01,$00,$00   ; $62B9 type6 face0 spr$08 (+1,+0) ev$00
    db $00,$FF   ; $62BE (tail)

SECTION "Bank 11 Area 25 ObjList $62CA", ROMX[$62CA], BANK[11]
Bank11_Area25_Obj_62CA:          ; $62CA  (object list)
    db $90,$FF,$01,$04,$02   ; $62CA HEADER(bit7)
    db $90,$FF,$02,$04,$03   ; $62CF HEADER(bit7)
    db $90,$FF,$03,$04,$04   ; $62D4 HEADER(bit7)
    db $06,$1F,$02,$02,$01   ; $62D9 type6 face0 spr$1F (+2,+2) ev$01
    db $FF   ; $62DE end
Bank11_Area25_Obj_62DF:          ; $62DF  (object list)
    db $01,$07,$01,$00,$8D   ; $62DF type1 face0 spr$07 (+1,+0) ev$8D
    db $01,$04,$FF   ; $62E4 (tail)

SECTION "Bank 11 Area 26 ObjList $62F1", ROMX[$62F1], BANK[11]
Bank11_Area26_Obj_62F1:          ; $62F1  (object list)
    db $90,$FF,$03,$04,$04   ; $62F1 HEADER(bit7)
    db $90,$FF,$04,$04,$05   ; $62F6 HEADER(bit7)
    db $90,$FF,$05,$04,$06   ; $62FB HEADER(bit7)
    db $06,$1F,$04,$02,$01   ; $6300 type6 face0 spr$1F (+4,+2) ev$01
    db $00,$11,$05,$05,$02   ; $6305 type0 face0 spr$11 (+5,+5) ev$02
    db $08,$3B,$02,$06,$03   ; $630A type8 face0 spr$3B (+2,+6) ev$03
    db $FF   ; $630F end
Bank11_Area26_Obj_6310:          ; $6310  (object list)
    db $04,$07,$01,$00,$8D   ; $6310 type4 face0 spr$07 (+1,+0) ev$8D
    db $04,$06,$FF   ; $6315 (tail)

SECTION "Bank 11 Area 27 ObjList $632E", ROMX[$632E], BANK[11]
Bank11_Area27_Obj_632E:          ; $632E  (object list)
    db $00,$22,$04,$02,$01   ; $632E type0 face0 spr$22 (+4,+2) ev$01
    db $00,$FF,$05,$02,$01   ; $6333 type0 face0 spr$FF (+5,+2) ev$01
    db $FF   ; $6338 end
Bank11_Area27_Obj_6339:          ; $6339  (object list)
    db $00,$24,$04,$02,$02   ; $6339 type0 face0 spr$24 (+4,+2) ev$02
    db $00,$FF,$05,$02,$02   ; $633E type0 face0 spr$FF (+5,+2) ev$02
    db $FF   ; $6343 end
Bank11_Area27_Obj_6344:          ; $6344  (object list)
    db $00,$3B,$03,$03,$03   ; $6344 type0 face0 spr$3B (+3,+3) ev$03
    db $00,$24,$04,$02,$02   ; $6349 type0 face0 spr$24 (+4,+2) ev$02
    db $00,$FF,$05,$02,$02   ; $634E type0 face0 spr$FF (+5,+2) ev$02
    db $FF   ; $6353 end
Bank11_Area27_Obj_6354:          ; $6354  (object list)
    db $04,$07,$05,$00,$80   ; $6354 type4 face0 spr$07 (+5,+0) ev$80
    db $04,$00,$05,$07,$05   ; $6359 type4 face0 spr$00 (+5,+7) ev$05
    db $00,$80,$05,$00,$FF   ; $635E type0 face0 spr$80 (+5,+0) ev$FF

SECTION "Bank 11 Area 28 ObjList $6373", ROMX[$6373], BANK[11]
Bank11_Area28_Obj_6373:          ; $6373  (object list)
    db $8F,$FF,$04,$02,$01   ; $6373 HEADER(bit7)
    db $8F,$FF,$05,$02,$01   ; $6378 HEADER(bit7)
    db $8F,$FF,$01,$04,$02   ; $637D HEADER(bit7)
    db $8F,$FF,$08,$04,$03   ; $6382 HEADER(bit7)
    db $40,$41,$04,$02,$01   ; $6387 type0 face4 spr$41 (+4,+2) ev$01
    db $40,$41,$05,$02,$01   ; $638C type0 face4 spr$41 (+5,+2) ev$01
    db $02,$40,$03,$05,$04   ; $6391 type2 face0 spr$40 (+3,+5) ev$04
    db $FF   ; $6396 end
Bank11_Area28_Obj_6397:          ; $6397  (object list)
    db $8F,$FF,$04,$02,$05   ; $6397 HEADER(bit7)
    db $8F,$FF,$05,$02,$05   ; $639C HEADER(bit7)
    db $8F,$FF,$01,$04,$02   ; $63A1 HEADER(bit7)
    db $8F,$FF,$08,$04,$03   ; $63A6 HEADER(bit7)
    db $40,$2B,$04,$02,$05   ; $63AB type0 face4 spr$2B (+4,+2) ev$05
    db $40,$2B,$05,$02,$05   ; $63B0 type0 face4 spr$2B (+5,+2) ev$05
    db $02,$1E,$03,$05,$06   ; $63B5 type2 face0 spr$1E (+3,+5) ev$06
    db $FF   ; $63BA end
Bank11_Area28_Obj_63BB:          ; $63BB  (object list)
    db $04,$07,$05,$00,$81   ; $63BB type4 face0 spr$07 (+5,+0) ev$81
    db $04,$00,$05,$07,$05   ; $63C0 type4 face0 spr$00 (+5,+7) ev$05
    db $00,$81,$05,$00,$FF   ; $63C5 type0 face0 spr$81 (+5,+0) ev$FF

SECTION "Bank 11 Area 29 ObjList $63D4", ROMX[$63D4], BANK[11]
Bank11_Area29_Obj_63D4:          ; $63D4  (object list)
    db $8F,$FF,$04,$01,$01   ; $63D4 HEADER(bit7)
    db $8F,$FF,$06,$01,$02   ; $63D9 HEADER(bit7)
    db $8F,$FF,$05,$03,$03   ; $63DE HEADER(bit7)
    db $07,$11,$05,$02,$04   ; $63E3 type7 face0 spr$11 (+5,+2) ev$04
    db $27,$00,$03,$05,$05   ; $63E8 type7 face2 spr$00 (+3,+5) ev$05
    db $20,$02,$08,$06,$06   ; $63ED type0 face2 spr$02 (+8,+6) ev$06
    db $FF   ; $63F2 end
Bank11_Area29_Obj_63F3:          ; $63F3  (object list)
    db $05,$07,$07,$00,$80   ; $63F3 type5 face0 spr$07 (+7,+0) ev$80
    db $05,$01,$FF   ; $63F8 (tail)

SECTION "Bank 11 Area 30 ObjList $640B", ROMX[$640B], BANK[11]
Bank11_Area30_Obj_640B:          ; $640B  (object list)
    db $8F,$FF,$05,$03,$01   ; $640B HEADER(bit7)
    db $00,$05,$05,$02,$01   ; $6410 type0 face0 spr$05 (+5,+2) ev$01
    db $37,$0F,$02,$03,$02   ; $6415 type7 face3 spr$0F (+2,+3) ev$02
    db $20,$0B,$06,$04,$03   ; $641A type0 face2 spr$0B (+6,+4) ev$03
    db $FF   ; $641F end
Bank11_Area30_Obj_6420:          ; $6420  (object list)
    db $8F,$FF,$05,$03,$01   ; $6420 HEADER(bit7)
    db $00,$05,$05,$02,$01   ; $6425 type0 face0 spr$05 (+5,+2) ev$01
    db $37,$0F,$02,$03,$02   ; $642A type7 face3 spr$0F (+2,+3) ev$02
    db $20,$0C,$06,$04,$04   ; $642F type0 face2 spr$0C (+6,+4) ev$04
    db $FF   ; $6434 end
Bank11_Area30_Obj_6435:          ; $6435  (object list)
    db $05,$07,$07,$00,$82   ; $6435 type5 face0 spr$07 (+7,+0) ev$82
    db $05,$01,$FF   ; $643A (tail)

SECTION "Bank 11 Area 31 ObjList $6453", ROMX[$6453], BANK[11]
Bank11_Area31_Obj_6453:          ; $6453  (object list)
    db $8F,$FF,$02,$06,$01   ; $6453 HEADER(bit7)
    db $00,$0E,$05,$06,$02   ; $6458 type0 face0 spr$0E (+5,+6) ev$02
    db $00,$11,$07,$03,$03   ; $645D type0 face0 spr$11 (+7,+3) ev$03
    db $00,$02,$04,$04,$04   ; $6462 type0 face0 spr$02 (+4,+4) ev$04
    db $81,$FF,$05,$04,$07   ; $6467 HEADER(bit7)
    db $FF   ; $646C end
Bank11_Area31_Obj_646D:          ; $646D  (object list)
    db $8F,$FF,$02,$06,$01   ; $646D HEADER(bit7)
    db $00,$0E,$05,$06,$02   ; $6472 type0 face0 spr$0E (+5,+6) ev$02
    db $00,$11,$07,$03,$03   ; $6477 type0 face0 spr$11 (+7,+3) ev$03
    db $00,$13,$04,$04,$05   ; $647C type0 face0 spr$13 (+4,+4) ev$05
    db $81,$FF,$05,$04,$08   ; $6481 HEADER(bit7)
    db $FF   ; $6486 end
Bank11_Area31_Obj_6487:          ; $6487  (object list)
    db $8F,$FF,$02,$06,$01   ; $6487 HEADER(bit7)
    db $00,$0E,$05,$06,$02   ; $648C type0 face0 spr$0E (+5,+6) ev$02
    db $00,$11,$07,$03,$03   ; $6491 type0 face0 spr$11 (+7,+3) ev$03
    db $00,$14,$04,$04,$06   ; $6496 type0 face0 spr$14 (+4,+4) ev$06
    db $81,$FF,$05,$04,$09   ; $649B HEADER(bit7)
    db $FF   ; $64A0 end
Bank11_Area31_Obj_64A1:          ; $64A1  (object list)
    db $05,$02,$07,$00,$01   ; $64A1 type5 face0 spr$02 (+7,+0) ev$01
    db $05,$02,$FF   ; $64A6 (tail)

SECTION "Bank 11 Area 35 ObjList $64B9", ROMX[$64B9], BANK[11]
Bank11_Area35_Obj_64B9:          ; $64B9  (object list)
    db $00,$0B,$08,$05,$01   ; $64B9 type0 face0 spr$0B (+8,+5) ev$01
    db $00,$4D,$08,$02,$FF   ; $64BE type0 face0 spr$4D (+8,+2) ev$FF
    db $FF   ; $64C3 end
Bank11_Area35_Obj_64C4:          ; $64C4  (object list)
    db $00,$0B,$08,$05,$01   ; $64C4 type0 face0 spr$0B (+8,+5) ev$01
    db $FF   ; $64C9 end
Bank11_Area35_Obj_64CA:          ; $64CA  (object list)
    db $07,$07,$03,$00,$81   ; $64CA type7 face0 spr$07 (+3,+0) ev$81
    db $04,$01,$08,$07,$03   ; $64CF type4 face0 spr$01 (+8,+7) ev$03
    db $00,$81,$05,$01,$08   ; $64D4 type0 face0 spr$81 (+5,+1) ev$08
    db $02,$00,$01,$00,$00   ; $64D9 type2 face0 spr$00 (+1,+0) ev$00
    db $00,$FF   ; $64DE (tail)

SECTION "Bank 11 Area 36 ObjList $64FC", ROMX[$64FC], BANK[11]
Bank11_Area36_Obj_64FC:          ; $64FC  (object list)
    db $10,$0B,$07,$05,$01   ; $64FC type0 face1 spr$0B (+7,+5) ev$01
    db $00,$4D,$02,$02,$FF   ; $6501 type0 face0 spr$4D (+2,+2) ev$FF
    db $00,$4D,$02,$06,$FF   ; $6506 type0 face0 spr$4D (+2,+6) ev$FF
    db $FF   ; $650B end
Bank11_Area36_Obj_650C:          ; $650C  (object list)
    db $10,$0B,$07,$05,$01   ; $650C type0 face1 spr$0B (+7,+5) ev$01
    db $00,$4D,$02,$06,$FF   ; $6511 type0 face0 spr$4D (+2,+6) ev$FF
    db $FF   ; $6516 end
Bank11_Area36_Obj_6517:          ; $6517  (object list)
    db $10,$0B,$07,$05,$01   ; $6517 type0 face1 spr$0B (+7,+5) ev$01
    db $00,$4D,$02,$02,$FF   ; $651C type0 face0 spr$4D (+2,+2) ev$FF
    db $FF   ; $6521 end
Bank11_Area36_Obj_6522:          ; $6522  (object list)
    db $10,$0B,$07,$05,$01   ; $6522 type0 face1 spr$0B (+7,+5) ev$01
    db $FF   ; $6527 end
Bank11_Area36_Obj_6528:          ; $6528  (object list)
    db $06,$07,$03,$00,$81   ; $6528 type6 face0 spr$07 (+3,+0) ev$81
    db $02,$02,$02,$02,$01   ; $652D type2 face0 spr$02 (+2,+2) ev$01
    db $01,$00,$00,$00,$02   ; $6532 type1 face0 spr$00 (+0,+0) ev$02
    db $06,$02,$01,$00,$00   ; $6537 type6 face0 spr$02 (+1,+0) ev$00
    db $00,$FF   ; $653C (tail)

SECTION "Bank 11 Area 37 ObjList $655A", ROMX[$655A], BANK[11]
Bank11_Area37_Obj_655A:          ; $655A  (object list)
    db $00,$0B,$06,$03,$01   ; $655A type0 face0 spr$0B (+6,+3) ev$01
    db $00,$4D,$05,$01,$FF   ; $655F type0 face0 spr$4D (+5,+1) ev$FF
    db $00,$4D,$07,$01,$FF   ; $6564 type0 face0 spr$4D (+7,+1) ev$FF
    db $FF   ; $6569 end
Bank11_Area37_Obj_656A:          ; $656A  (object list)
    db $00,$0B,$06,$03,$01   ; $656A type0 face0 spr$0B (+6,+3) ev$01
    db $00,$4D,$07,$01,$FF   ; $656F type0 face0 spr$4D (+7,+1) ev$FF
    db $FF   ; $6574 end
Bank11_Area37_Obj_6575:          ; $6575  (object list)
    db $00,$0B,$06,$03,$01   ; $6575 type0 face0 spr$0B (+6,+3) ev$01
    db $00,$4D,$05,$01,$FF   ; $657A type0 face0 spr$4D (+5,+1) ev$FF
    db $FF   ; $657F end
Bank11_Area37_Obj_6580:          ; $6580  (object list)
    db $00,$0B,$06,$03,$01   ; $6580 type0 face0 spr$0B (+6,+3) ev$01
    db $FF   ; $6585 end
Bank11_Area37_Obj_6586:          ; $6586  (object list)
    db $01,$07,$03,$00,$81   ; $6586 type1 face0 spr$07 (+3,+0) ev$81
    db $07,$02,$05,$01,$03   ; $658B type7 face0 spr$02 (+5,+1) ev$03
    db $01,$00,$00,$00,$07   ; $6590 type1 face0 spr$00 (+0,+0) ev$07
    db $01,$04,$01,$00,$00   ; $6595 type1 face0 spr$04 (+1,+0) ev$00
    db $00,$FF   ; $659A (tail)

SECTION "Bank 11 Area 38 ObjList $65B8", ROMX[$65B8], BANK[11]
Bank11_Area38_Obj_65B8:          ; $65B8  (object list)
    db $00,$0B,$08,$05,$01   ; $65B8 type0 face0 spr$0B (+8,+5) ev$01
    db $00,$4D,$03,$03,$FF   ; $65BD type0 face0 spr$4D (+3,+3) ev$FF
    db $00,$4D,$06,$03,$FF   ; $65C2 type0 face0 spr$4D (+6,+3) ev$FF
    db $FF   ; $65C7 end
Bank11_Area38_Obj_65C8:          ; $65C8  (object list)
    db $00,$0B,$08,$05,$01   ; $65C8 type0 face0 spr$0B (+8,+5) ev$01
    db $00,$4D,$06,$03,$FF   ; $65CD type0 face0 spr$4D (+6,+3) ev$FF
    db $FF   ; $65D2 end
Bank11_Area38_Obj_65D3:          ; $65D3  (object list)
    db $00,$0B,$08,$05,$01   ; $65D3 type0 face0 spr$0B (+8,+5) ev$01
    db $00,$4D,$03,$03,$FF   ; $65D8 type0 face0 spr$4D (+3,+3) ev$FF
    db $FF   ; $65DD end
Bank11_Area38_Obj_65DE:          ; $65DE  (object list)
    db $00,$0B,$08,$05,$01   ; $65DE type0 face0 spr$0B (+8,+5) ev$01
    db $FF   ; $65E3 end
Bank11_Area38_Obj_65E4:          ; $65E4  (object list)
    db $08,$07,$03,$00,$80   ; $65E4 type8 face0 spr$07 (+3,+0) ev$80
    db $07,$02,$03,$03,$06   ; $65E9 type7 face0 spr$02 (+3,+3) ev$06
    db $01,$00,$00,$00,$06   ; $65EE type1 face0 spr$00 (+0,+0) ev$06
    db $03,$07,$01,$00,$00   ; $65F3 type3 face0 spr$07 (+1,+0) ev$00
    db $00,$FF   ; $65F8 (tail)

SECTION "Bank 11 Area 39 ObjList $6610", ROMX[$6610], BANK[11]
Bank11_Area39_Obj_6610:          ; $6610  (object list)
    db $01,$0B,$02,$04,$01   ; $6610 type1 face0 spr$0B (+2,+4) ev$01
    db $01,$0B,$08,$05,$02   ; $6615 type1 face0 spr$0B (+8,+5) ev$02
    db $00,$4D,$02,$03,$FF   ; $661A type0 face0 spr$4D (+2,+3) ev$FF
    db $00,$4D,$07,$03,$FF   ; $661F type0 face0 spr$4D (+7,+3) ev$FF
    db $FF   ; $6624 end
Bank11_Area39_Obj_6625:          ; $6625  (object list)
    db $20,$0B,$01,$06,$01   ; $6625 type0 face2 spr$0B (+1,+6) ev$01
    db $10,$0B,$08,$05,$02   ; $662A type0 face1 spr$0B (+8,+5) ev$02
    db $00,$4D,$02,$03,$FF   ; $662F type0 face0 spr$4D (+2,+3) ev$FF
    db $FF   ; $6634 end
Bank11_Area39_Obj_6635:          ; $6635  (object list)
    db $20,$0B,$01,$06,$01   ; $6635 type0 face2 spr$0B (+1,+6) ev$01
    db $10,$0B,$08,$05,$02   ; $663A type0 face1 spr$0B (+8,+5) ev$02
    db $FF   ; $663F end
Bank11_Area39_Obj_6640:          ; $6640  (object list)
    db $04,$07,$03,$00,$80   ; $6640 type4 face0 spr$07 (+3,+0) ev$80
    db $04,$01,$05,$07,$03   ; $6645 type4 face0 spr$01 (+5,+7) ev$03
    db $00,$80,$05,$01,$02   ; $664A type0 face0 spr$80 (+5,+1) ev$02
    db $03,$09,$01,$00,$00   ; $664F type3 face0 spr$09 (+1,+0) ev$00
    db $00,$07,$03,$0A,$01   ; $6654 type0 face0 spr$07 (+3,+10) ev$01
    db $00,$00,$00,$FF   ; $6659 (tail)

SECTION "Bank 11 Area 40 ObjList $6679", ROMX[$6679], BANK[11]
Bank11_Area40_Obj_6679:          ; $6679  (object list)
    db $10,$0B,$06,$06,$01   ; $6679 type0 face1 spr$0B (+6,+6) ev$01
    db $00,$4D,$03,$02,$FF   ; $667E type0 face0 spr$4D (+3,+2) ev$FF
    db $00,$4D,$05,$02,$FF   ; $6683 type0 face0 spr$4D (+5,+2) ev$FF
    db $FF   ; $6688 end
Bank11_Area40_Obj_6689:          ; $6689  (object list)
    db $10,$0B,$06,$06,$01   ; $6689 type0 face1 spr$0B (+6,+6) ev$01
    db $00,$4D,$03,$02,$FF   ; $668E type0 face0 spr$4D (+3,+2) ev$FF
    db $FF   ; $6693 end
Bank11_Area40_Obj_6694:          ; $6694  (object list)
    db $10,$0B,$06,$06,$01   ; $6694 type0 face1 spr$0B (+6,+6) ev$01
    db $00,$4D,$05,$02,$FF   ; $6699 type0 face0 spr$4D (+5,+2) ev$FF
    db $FF   ; $669E end
Bank11_Area40_Obj_669F:          ; $669F  (object list)
    db $10,$0B,$06,$06,$01   ; $669F type0 face1 spr$0B (+6,+6) ev$01
    db $FF   ; $66A4 end
Bank11_Area40_Obj_66A5:          ; $66A5  (object list)
    db $04,$07,$03,$00,$80   ; $66A5 type4 face0 spr$07 (+3,+0) ev$80
    db $02,$02,$03,$02,$0C   ; $66AA type2 face0 spr$02 (+3,+2) ev$0C
    db $01,$00,$00,$00,$05   ; $66AF type1 face0 spr$00 (+0,+0) ev$05
    db $02,$0D,$01,$00,$00   ; $66B4 type2 face0 spr$0D (+1,+0) ev$00
    db $00,$FF   ; $66B9 (tail)

SECTION "Bank 11 Area 41 ObjList $66D7", ROMX[$66D7], BANK[11]
Bank11_Area41_Obj_66D7:          ; $66D7  (object list)
    db $10,$0B,$07,$06,$01   ; $66D7 type0 face1 spr$0B (+7,+6) ev$01
    db $00,$4D,$03,$02,$FF   ; $66DC type0 face0 spr$4D (+3,+2) ev$FF
    db $00,$4D,$06,$02,$FF   ; $66E1 type0 face0 spr$4D (+6,+2) ev$FF
    db $FF   ; $66E6 end
Bank11_Area41_Obj_66E7:          ; $66E7  (object list)
    db $10,$0B,$07,$06,$01   ; $66E7 type0 face1 spr$0B (+7,+6) ev$01
    db $00,$4D,$06,$02,$FF   ; $66EC type0 face0 spr$4D (+6,+2) ev$FF
    db $FF   ; $66F1 end
Bank11_Area41_Obj_66F2:          ; $66F2  (object list)
    db $10,$0B,$07,$06,$01   ; $66F2 type0 face1 spr$0B (+7,+6) ev$01
    db $00,$4D,$03,$02,$FF   ; $66F7 type0 face0 spr$4D (+3,+2) ev$FF
    db $FF   ; $66FC end
Bank11_Area41_Obj_66FD:          ; $66FD  (object list)
    db $10,$0B,$07,$06,$01   ; $66FD type0 face1 spr$0B (+7,+6) ev$01
    db $FF   ; $6702 end
Bank11_Area41_Obj_6703:          ; $6703  (object list)
    db $04,$07,$03,$00,$84   ; $6703 type4 face0 spr$07 (+3,+0) ev$84
    db $07,$02,$03,$02,$0F   ; $6708 type7 face0 spr$02 (+3,+2) ev$0F
    db $01,$00,$00,$00,$06   ; $670D type1 face0 spr$00 (+0,+0) ev$06
    db $02,$10,$01,$00,$00   ; $6712 type2 face0 spr$10 (+1,+0) ev$00
    db $00,$FF   ; $6717 (tail)

SECTION "Bank 11 Area 42 ObjList $6735", ROMX[$6735], BANK[11]
Bank11_Area42_Obj_6735:          ; $6735  (object list)
    db $00,$0B,$05,$02,$01   ; $6735 type0 face0 spr$0B (+5,+2) ev$01
    db $00,$4D,$02,$04,$FF   ; $673A type0 face0 spr$4D (+2,+4) ev$FF
    db $00,$4D,$07,$04,$FF   ; $673F type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $6744 end
Bank11_Area42_Obj_6745:          ; $6745  (object list)
    db $00,$0B,$05,$02,$01   ; $6745 type0 face0 spr$0B (+5,+2) ev$01
    db $00,$4D,$07,$04,$FF   ; $674A type0 face0 spr$4D (+7,+4) ev$FF
    db $FF   ; $674F end
Bank11_Area42_Obj_6750:          ; $6750  (object list)
    db $00,$0B,$05,$02,$01   ; $6750 type0 face0 spr$0B (+5,+2) ev$01
    db $00,$4D,$02,$04,$FF   ; $6755 type0 face0 spr$4D (+2,+4) ev$FF
    db $FF   ; $675A end
Bank11_Area42_Obj_675B:          ; $675B  (object list)
    db $00,$0B,$05,$02,$01   ; $675B type0 face0 spr$0B (+5,+2) ev$01
    db $FF   ; $6760 end
Bank11_Area42_Obj_6761:          ; $6761  (object list)
    db $04,$07,$03,$00,$84   ; $6761 type4 face0 spr$07 (+3,+0) ev$84
    db $02,$02,$02,$04,$12   ; $6766 type2 face0 spr$02 (+2,+4) ev$12
    db $01,$00,$00,$00,$07   ; $676B type1 face0 spr$00 (+0,+0) ev$07
    db $04,$13,$01,$00,$00   ; $6770 type4 face0 spr$13 (+1,+0) ev$00
    db $00,$FF   ; $6775 (tail)

SECTION "Bank 11 Area 43 ObjList $6787", ROMX[$6787], BANK[11]
Bank11_Area43_Obj_6787:          ; $6787  (object list)
    db $30,$0B,$01,$06,$01   ; $6787 type0 face3 spr$0B (+1,+6) ev$01
    db $00,$4D,$03,$02,$FF   ; $678C type0 face0 spr$4D (+3,+2) ev$FF
    db $FF   ; $6791 end
Bank11_Area43_Obj_6792:          ; $6792  (object list)
    db $30,$0B,$01,$06,$01   ; $6792 type0 face3 spr$0B (+1,+6) ev$01
    db $FF   ; $6797 end
Bank11_Area43_Obj_6798:          ; $6798  (object list)
    db $07,$07,$03,$00,$84   ; $6798 type7 face0 spr$07 (+3,+0) ev$84
    db $04,$01,$08,$07,$03   ; $679D type4 face0 spr$01 (+8,+7) ev$03
    db $00,$84,$05,$01,$03   ; $67A2 type0 face0 spr$84 (+5,+1) ev$03
    db $02,$15,$01,$00,$00   ; $67A7 type2 face0 spr$15 (+1,+0) ev$00
    db $00,$FF   ; $67AC (tail)

SECTION "Bank 11 Area 44 ObjList $67CA", ROMX[$67CA], BANK[11]
Bank11_Area44_Obj_67CA:          ; $67CA  (object list)
    db $30,$0B,$01,$06,$01   ; $67CA type0 face3 spr$0B (+1,+6) ev$01
    db $00,$4D,$01,$03,$FF   ; $67CF type0 face0 spr$4D (+1,+3) ev$FF
    db $00,$4D,$03,$03,$FF   ; $67D4 type0 face0 spr$4D (+3,+3) ev$FF
    db $FF   ; $67D9 end
Bank11_Area44_Obj_67DA:          ; $67DA  (object list)
    db $30,$0B,$01,$06,$01   ; $67DA type0 face3 spr$0B (+1,+6) ev$01
    db $00,$4D,$03,$03,$FF   ; $67DF type0 face0 spr$4D (+3,+3) ev$FF
    db $FF   ; $67E4 end
Bank11_Area44_Obj_67E5:          ; $67E5  (object list)
    db $30,$0B,$01,$06,$01   ; $67E5 type0 face3 spr$0B (+1,+6) ev$01
    db $00,$4D,$01,$03,$FF   ; $67EA type0 face0 spr$4D (+1,+3) ev$FF
    db $FF   ; $67EF end
Bank11_Area44_Obj_67F0:          ; $67F0  (object list)
    db $30,$0B,$01,$06,$01   ; $67F0 type0 face3 spr$0B (+1,+6) ev$01
    db $FF   ; $67F5 end
Bank11_Area44_Obj_67F6:          ; $67F6  (object list)
    db $08,$07,$03,$00,$85   ; $67F6 type8 face0 spr$07 (+3,+0) ev$85
    db $02,$02,$01,$03,$16   ; $67FB type2 face0 spr$02 (+1,+3) ev$16
    db $01,$00,$00,$00,$03   ; $6800 type1 face0 spr$00 (+0,+0) ev$03
    db $03,$17,$01,$00,$00   ; $6805 type3 face0 spr$17 (+1,+0) ev$00
    db $00,$FF   ; $680A (tail)

SECTION "Bank 11 Area 45 ObjList $6828", ROMX[$6828], BANK[11]
Bank11_Area45_Obj_6828:          ; $6828  (object list)
    db $00,$0B,$02,$02,$01   ; $6828 type0 face0 spr$0B (+2,+2) ev$01
    db $00,$4D,$06,$02,$FF   ; $682D type0 face0 spr$4D (+6,+2) ev$FF
    db $00,$4D,$06,$04,$FF   ; $6832 type0 face0 spr$4D (+6,+4) ev$FF
    db $FF   ; $6837 end
Bank11_Area45_Obj_6838:          ; $6838  (object list)
    db $00,$0B,$02,$02,$01   ; $6838 type0 face0 spr$0B (+2,+2) ev$01
    db $00,$4D,$06,$04,$FF   ; $683D type0 face0 spr$4D (+6,+4) ev$FF
    db $FF   ; $6842 end
Bank11_Area45_Obj_6843:          ; $6843  (object list)
    db $00,$0B,$02,$02,$01   ; $6843 type0 face0 spr$0B (+2,+2) ev$01
    db $00,$4D,$06,$02,$FF   ; $6848 type0 face0 spr$4D (+6,+2) ev$FF
    db $FF   ; $684D end
Bank11_Area45_Obj_684E:          ; $684E  (object list)
    db $00,$0B,$02,$02,$01   ; $684E type0 face0 spr$0B (+2,+2) ev$01
    db $FF   ; $6853 end
Bank11_Area45_Obj_6854:          ; $6854  (object list)
    db $02,$07,$03,$00,$85   ; $6854 type2 face0 spr$07 (+3,+0) ev$85
    db $07,$02,$06,$02,$18   ; $6859 type7 face0 spr$02 (+6,+2) ev$18
    db $01,$00,$00,$00,$06   ; $685E type1 face0 spr$00 (+0,+0) ev$06
    db $04,$19,$01,$00,$00   ; $6863 type4 face0 spr$19 (+1,+0) ev$00
    db $00,$FF   ; $6868 (tail)

SECTION "Bank 11 Area 46 ObjList $6886", ROMX[$6886], BANK[11]
Bank11_Area46_Obj_6886:          ; $6886  (object list)
    db $00,$0B,$03,$04,$01   ; $6886 type0 face0 spr$0B (+3,+4) ev$01
    db $00,$4D,$02,$02,$FF   ; $688B type0 face0 spr$4D (+2,+2) ev$FF
    db $00,$4D,$04,$02,$FF   ; $6890 type0 face0 spr$4D (+4,+2) ev$FF
    db $FF   ; $6895 end
Bank11_Area46_Obj_6896:          ; $6896  (object list)
    db $00,$0B,$03,$04,$01   ; $6896 type0 face0 spr$0B (+3,+4) ev$01
    db $00,$4D,$04,$02,$FF   ; $689B type0 face0 spr$4D (+4,+2) ev$FF
    db $FF   ; $68A0 end
Bank11_Area46_Obj_68A1:          ; $68A1  (object list)
    db $00,$0B,$03,$04,$01   ; $68A1 type0 face0 spr$0B (+3,+4) ev$01
    db $00,$4D,$02,$02,$FF   ; $68A6 type0 face0 spr$4D (+2,+2) ev$FF
    db $FF   ; $68AB end
Bank11_Area46_Obj_68AC:          ; $68AC  (object list)
    db $00,$0B,$03,$04,$01   ; $68AC type0 face0 spr$0B (+3,+4) ev$01
    db $FF   ; $68B1 end
Bank11_Area46_Obj_68B2:          ; $68B2  (object list)
    db $06,$07,$03,$00,$85   ; $68B2 type6 face0 spr$07 (+3,+0) ev$85
    db $04,$01,$07,$07,$03   ; $68B7 type4 face0 spr$01 (+7,+7) ev$03
    db $00,$85,$05,$01,$02   ; $68BC type0 face0 spr$85 (+5,+1) ev$02
    db $02,$1A,$01,$00,$00   ; $68C1 type2 face0 spr$1A (+1,+0) ev$00
    db $00,$04,$02,$1B,$01   ; $68C6 type0 face0 spr$04 (+2,+27) ev$01
    db $00,$00,$00,$FF   ; $68CB (tail)

SECTION "Bank 11 Area 47 ObjList $6915", ROMX[$6915], BANK[11]
Bank11_Area47_Obj_6915:          ; $6915  (object list)
    db $8F,$FF,$01,$01,$01   ; $6915 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $691A HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $691F HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $6924 HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $6929 HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $692E HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $6933 HEADER(bit7)
    db $50,$14,$05,$03,$07   ; $6938 type0 face5 spr$14 (+5,+3) ev$07
    db $00,$51,$06,$04,$07   ; $693D type0 face0 spr$51 (+6,+4) ev$07
    db $40,$50,$03,$04,$FF   ; $6942 type0 face4 spr$50 (+3,+4) ev$FF
    db $FF   ; $6947 end
Bank11_Area47_Obj_6948:          ; $6948  (object list)
    db $8F,$FF,$01,$01,$01   ; $6948 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $694D HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $6952 HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $6957 HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $695C HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $6961 HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $6966 HEADER(bit7)
    db $FF   ; $696B end
Bank11_Area47_Obj_696C:          ; $696C  (object list)
    db $8F,$FF,$01,$01,$01   ; $696C HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $6971 HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $6976 HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $697B HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $6980 HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $6985 HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $698A HEADER(bit7)
    db $50,$14,$07,$04,$07   ; $698F type0 face5 spr$14 (+7,+4) ev$07
    db $50,$21,$0B,$00,$FF   ; $6994 type0 face5 spr$21 (+11,+0) ev$FF
    db $00,$51,$06,$04,$07   ; $6999 type0 face0 spr$51 (+6,+4) ev$07
    db $40,$5F,$05,$03,$FF   ; $699E type0 face4 spr$5F (+5,+3) ev$FF
    db $40,$50,$03,$04,$FF   ; $69A3 type0 face4 spr$50 (+3,+4) ev$FF
    db $FF   ; $69A8 end
Bank11_Area47_Obj_69A9:          ; $69A9  (object list)
    db $8F,$FF,$01,$01,$01   ; $69A9 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $69AE HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $69B3 HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $69B8 HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $69BD HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $69C2 HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $69C7 HEADER(bit7)
    db $50,$14,$07,$04,$07   ; $69CC type0 face5 spr$14 (+7,+4) ev$07
    db $50,$21,$0B,$00,$FF   ; $69D1 type0 face5 spr$21 (+11,+0) ev$FF
    db $00,$51,$06,$04,$07   ; $69D6 type0 face0 spr$51 (+6,+4) ev$07
    db $40,$5F,$05,$03,$FF   ; $69DB type0 face4 spr$5F (+5,+3) ev$FF
    db $40,$50,$03,$04,$FF   ; $69E0 type0 face4 spr$50 (+3,+4) ev$FF
    db $FF   ; $69E5 end
Bank11_Area47_Obj_69E6:          ; $69E6  (object list)
    db $90,$FF,$02,$03,$0D   ; $69E6 HEADER(bit7)
    db $90,$FF,$04,$03,$0E   ; $69EB HEADER(bit7)
    db $8F,$FF,$01,$01,$01   ; $69F0 HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $69F5 HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $69FA HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $69FF HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $6A04 HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $6A09 HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $6A0E HEADER(bit7)
    db $10,$14,$07,$04,$07   ; $6A13 type0 face1 spr$14 (+7,+4) ev$07
    db $40,$21,$0B,$04,$FF   ; $6A18 type0 face4 spr$21 (+11,+4) ev$FF
    db $70,$14,$07,$04,$07   ; $6A1D type0 face7 spr$14 (+7,+4) ev$07
    db $40,$5F,$05,$03,$FF   ; $6A22 type0 face4 spr$5F (+5,+3) ev$FF
    db $40,$50,$03,$04,$FF   ; $6A27 type0 face4 spr$50 (+3,+4) ev$FF
    db $FF   ; $6A2C end
Bank11_Area47_Obj_6A2D:          ; $6A2D  (object list)
    db $8F,$FF,$01,$01,$01   ; $6A2D HEADER(bit7)
    db $8F,$FF,$02,$01,$02   ; $6A32 HEADER(bit7)
    db $8F,$FF,$07,$01,$03   ; $6A37 HEADER(bit7)
    db $8F,$FF,$08,$01,$04   ; $6A3C HEADER(bit7)
    db $8F,$FF,$05,$04,$05   ; $6A41 HEADER(bit7)
    db $8F,$FF,$04,$01,$06   ; $6A46 HEADER(bit7)
    db $8F,$FF,$05,$01,$06   ; $6A4B HEADER(bit7)
    db $50,$14,$06,$04,$06   ; $6A50 type0 face5 spr$14 (+6,+4) ev$06
    db $50,$21,$0B,$00,$FF   ; $6A55 type0 face5 spr$21 (+11,+0) ev$FF
    db $00,$51,$06,$04,$06   ; $6A5A type0 face0 spr$51 (+6,+4) ev$06
    db $00,$5F,$04,$05,$FF   ; $6A5F type0 face0 spr$5F (+4,+5) ev$FF
    db $00,$50,$03,$04,$FF   ; $6A64 type0 face0 spr$50 (+3,+4) ev$FF
    db $FF   ; $6A69 end
Bank11_Area47_Obj_6A6A:          ; $6A6A  (object list)
    db $8F,$FF,$01,$01,$08   ; $6A6A HEADER(bit7)
    db $8F,$FF,$02,$01,$09   ; $6A6F HEADER(bit7)
    db $8F,$FF,$08,$01,$0A   ; $6A74 HEADER(bit7)
    db $8F,$FF,$08,$05,$0B   ; $6A79 HEADER(bit7)
    db $8F,$FF,$05,$01,$0C   ; $6A7E HEADER(bit7)
    db $40,$21,$08,$01,$FF   ; $6A83 type0 face4 spr$21 (+8,+1) ev$FF
    db $40,$39,$08,$01,$FF   ; $6A88 type0 face4 spr$39 (+8,+1) ev$FF
    db $50,$14,$00,$04,$07   ; $6A8D type0 face5 spr$14 (+0,+4) ev$07
    db $FF   ; $6A92 end
Bank11_Area47_Obj_6A93:          ; $6A93  (object list)
    db $8F,$FF,$01,$01,$08   ; $6A93 HEADER(bit7)
    db $8F,$FF,$02,$01,$09   ; $6A98 HEADER(bit7)
    db $8F,$FF,$08,$01,$0A   ; $6A9D HEADER(bit7)
    db $8F,$FF,$08,$05,$0B   ; $6AA2 HEADER(bit7)
    db $8F,$FF,$05,$01,$0C   ; $6AA7 HEADER(bit7)
    db $40,$21,$08,$02,$FF   ; $6AAC type0 face4 spr$21 (+8,+2) ev$FF
    db $FF   ; $6AB1 end
Bank11_Area47_Obj_6AB2:          ; $6AB2  (object list)
    db $FF   ; $6AB2 end
Bank11_Area47_Obj_6AB3:          ; $6AB3  (object list)
    db $FF   ; $6AB3 end

SECTION "Bank 11 Area 48 ObjList $6AC4", ROMX[$6AC4], BANK[11]
Bank11_Area48_Obj_6AC4:          ; $6AC4  (object list)
    db $00,$16,$01,$02,$01   ; $6AC4 type0 face0 spr$16 (+1,+2) ev$01
    db $50,$21,$0A,$00,$FF   ; $6AC9 type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6ACE end
Bank11_Area48_Obj_6ACF:          ; $6ACF  (object list)
    db $FF   ; $6ACF end
Bank11_Area48_Obj_6AD0:          ; $6AD0  (object list)
    db $FF   ; $6AD0 end
Bank11_Area48_Obj_6AD1:          ; $6AD1  (object list)
    db $01,$02,$00,$00,$01   ; $6AD1 type1 face0 spr$02 (+0,+0) ev$01
    db $04,$05,$FF   ; $6AD6 (tail)

SECTION "Bank 11 Area 49 ObjList $6AE9", ROMX[$6AE9], BANK[11]
Bank11_Area49_Obj_6AE9:          ; $6AE9  (object list)
    db $8F,$FF,$04,$01,$02   ; $6AE9 HEADER(bit7)
    db $8F,$FF,$05,$01,$02   ; $6AEE HEADER(bit7)
    db $8F,$FF,$04,$02,$02   ; $6AF3 HEADER(bit7)
    db $8F,$FF,$05,$02,$02   ; $6AF8 HEADER(bit7)
    db $00,$0E,$08,$03,$01   ; $6AFD type0 face0 spr$0E (+8,+3) ev$01
    db $70,$21,$00,$00,$FF   ; $6B02 type0 face7 spr$21 (+0,+0) ev$FF
    db $FF   ; $6B07 end
Bank11_Area49_Obj_6B08:          ; $6B08  (object list)
    db $00,$0E,$08,$03,$01   ; $6B08 type0 face0 spr$0E (+8,+3) ev$01
    db $FF   ; $6B0D end
Bank11_Area49_Obj_6B0E:          ; $6B0E  (object list)
    db $FF   ; $6B0E end
Bank11_Area49_Obj_6B0F:          ; $6B0F  (object list)
    db $04,$01,$00,$00,$01   ; $6B0F type4 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $6B14 (tail)

SECTION "Bank 11 Area 50 ObjList $6B27", ROMX[$6B27], BANK[11]
Bank11_Area50_Obj_6B27:          ; $6B27  (object list)
    db $90,$FF,$05,$04,$02   ; $6B27 HEADER(bit7)
    db $00,$20,$04,$04,$01   ; $6B2C type0 face0 spr$20 (+4,+4) ev$01
    db $40,$39,$08,$00,$FF   ; $6B31 type0 face4 spr$39 (+8,+0) ev$FF
    db $50,$21,$0A,$01,$FF   ; $6B36 type0 face5 spr$21 (+10,+1) ev$FF
    db $FF   ; $6B3B end
Bank11_Area50_Obj_6B3C:          ; $6B3C  (object list)
    db $FF   ; $6B3C end
Bank11_Area50_Obj_6B3D:          ; $6B3D  (object list)
    db $FF   ; $6B3D end
Bank11_Area50_Obj_6B3E:          ; $6B3E  (object list)
    db $05,$04,$00,$00,$01   ; $6B3E type5 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $6B43 (tail)

SECTION "Bank 11 Area 51 ObjList $6B56", ROMX[$6B56], BANK[11]
Bank11_Area51_Obj_6B56:          ; $6B56  (object list)
    db $00,$3C,$04,$04,$01   ; $6B56 type0 face0 spr$3C (+4,+4) ev$01
    db $50,$21,$0A,$00,$FF   ; $6B5B type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6B60 end
Bank11_Area51_Obj_6B61:          ; $6B61  (object list)
    db $FF   ; $6B61 end
Bank11_Area51_Obj_6B62:          ; $6B62  (object list)
    db $FF   ; $6B62 end
Bank11_Area51_Obj_6B63:          ; $6B63  (object list)
    db $01,$04,$00,$00,$01   ; $6B63 type1 face0 spr$04 (+0,+0) ev$01
    db $04,$05,$FF   ; $6B68 (tail)

SECTION "Bank 11 Area 52 ObjList $6B7B", ROMX[$6B7B], BANK[11]
Bank11_Area52_Obj_6B7B:          ; $6B7B  (object list)
    db $90,$FF,$07,$01,$07   ; $6B7B HEADER(bit7)
    db $90,$FF,$04,$04,$08   ; $6B80 HEADER(bit7)
    db $90,$FF,$05,$05,$09   ; $6B85 HEADER(bit7)
    db $90,$FF,$01,$03,$0A   ; $6B8A HEADER(bit7)
    db $8F,$FF,$00,$06,$01   ; $6B8F HEADER(bit7)
    db $8F,$FF,$04,$01,$02   ; $6B94 HEADER(bit7)
    db $8F,$FF,$05,$01,$02   ; $6B99 HEADER(bit7)
    db $06,$25,$01,$02,$03   ; $6B9E type6 face0 spr$25 (+1,+2) ev$03
    db $06,$25,$08,$00,$04   ; $6BA3 type6 face0 spr$25 (+8,+0) ev$04
    db $06,$25,$05,$03,$05   ; $6BA8 type6 face0 spr$25 (+5,+3) ev$05
    db $06,$25,$06,$06,$06   ; $6BAD type6 face0 spr$25 (+6,+6) ev$06
    db $50,$21,$0A,$00,$FF   ; $6BB2 type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6BB7 end
Bank11_Area52_Obj_6BB8:          ; $6BB8  (object list)
    db $8F,$FF,$00,$06,$01   ; $6BB8 HEADER(bit7)
    db $FF   ; $6BBD end
Bank11_Area52_Obj_6BBE:          ; $6BBE  (object list)
    db $FF   ; $6BBE end
Bank11_Area52_Obj_6BBF:          ; $6BBF  (object list)
    db $05,$01,$00,$00,$01   ; $6BBF type5 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $6BC4 (tail)

SECTION "Bank 11 Area 53 ObjList $6BD7", ROMX[$6BD7], BANK[11]
Bank11_Area53_Obj_6BD7:          ; $6BD7  (object list)
    db $8F,$FF,$06,$06,$01   ; $6BD7 HEADER(bit7)
    db $82,$FF,$05,$00,$02   ; $6BDC HEADER(bit7)
    db $10,$1D,$07,$03,$03   ; $6BE1 type0 face1 spr$1D (+7,+3) ev$03
    db $50,$21,$0A,$00,$FF   ; $6BE6 type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6BEB end
Bank11_Area53_Obj_6BEC:          ; $6BEC  (object list)
    db $8F,$FF,$06,$06,$01   ; $6BEC HEADER(bit7)
    db $82,$FF,$05,$00,$02   ; $6BF1 HEADER(bit7)
    db $FF   ; $6BF6 end
Bank11_Area53_Obj_6BF7:          ; $6BF7  (object list)
    db $FF   ; $6BF7 end
Bank11_Area53_Obj_6BF8:          ; $6BF8  (object list)
    db $07,$03,$00,$00,$01   ; $6BF8 type7 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $6BFD (tail)

SECTION "Bank 11 Area 54 ObjList $6C10", ROMX[$6C10], BANK[11]
Bank11_Area54_Obj_6C10:          ; $6C10  (object list)
    db $82,$FF,$06,$02,$01   ; $6C10 HEADER(bit7)
    db $80,$FF,$06,$02,$01   ; $6C15 HEADER(bit7)
    db $82,$FF,$08,$02,$02   ; $6C1A HEADER(bit7)
    db $80,$FF,$08,$02,$02   ; $6C1F HEADER(bit7)
    db $82,$FF,$06,$04,$03   ; $6C24 HEADER(bit7)
    db $80,$FF,$06,$04,$03   ; $6C29 HEADER(bit7)
    db $82,$FF,$08,$04,$04   ; $6C2E HEADER(bit7)
    db $80,$FF,$08,$04,$04   ; $6C33 HEADER(bit7)
    db $8F,$FF,$04,$06,$07   ; $6C38 HEADER(bit7)
    db $00,$12,$03,$01,$05   ; $6C3D type0 face0 spr$12 (+3,+1) ev$05
    db $00,$12,$03,$02,$06   ; $6C42 type0 face0 spr$12 (+3,+2) ev$06
    db $30,$02,$03,$06,$07   ; $6C47 type0 face3 spr$02 (+3,+6) ev$07
    db $20,$17,$08,$05,$08   ; $6C4C type0 face2 spr$17 (+8,+5) ev$08
    db $70,$21,$00,$02,$FF   ; $6C51 type0 face7 spr$21 (+0,+2) ev$FF
    db $FF   ; $6C56 end
Bank11_Area54_Obj_6C57:          ; $6C57  (object list)
    db $8F,$FF,$06,$02,$01   ; $6C57 HEADER(bit7)
    db $8F,$FF,$08,$02,$02   ; $6C5C HEADER(bit7)
    db $8F,$FF,$06,$04,$03   ; $6C61 HEADER(bit7)
    db $8F,$FF,$08,$04,$04   ; $6C66 HEADER(bit7)
    db $8F,$FF,$04,$06,$07   ; $6C6B HEADER(bit7)
    db $00,$12,$03,$01,$05   ; $6C70 type0 face0 spr$12 (+3,+1) ev$05
    db $00,$12,$03,$02,$06   ; $6C75 type0 face0 spr$12 (+3,+2) ev$06
    db $30,$02,$03,$06,$07   ; $6C7A type0 face3 spr$02 (+3,+6) ev$07
    db $FF   ; $6C7F end
Bank11_Area54_Obj_6C80:          ; $6C80  (object list)
    db $FF   ; $6C80 end
Bank11_Area54_Obj_6C81:          ; $6C81  (object list)
    db $08,$06,$00,$00,$01   ; $6C81 type8 face0 spr$06 (+0,+0) ev$01
    db $04,$05,$FF   ; $6C86 (tail)

SECTION "Bank 11 Area 55 ObjList $6C99", ROMX[$6C99], BANK[11]
Bank11_Area55_Obj_6C99:          ; $6C99  (object list)
    db $90,$FF,$04,$04,$03   ; $6C99 HEADER(bit7)
    db $90,$FF,$03,$05,$03   ; $6C9E HEADER(bit7)
    db $90,$FF,$03,$06,$03   ; $6CA3 HEADER(bit7)
    db $90,$FF,$06,$04,$04   ; $6CA8 HEADER(bit7)
    db $90,$FF,$06,$05,$04   ; $6CAD HEADER(bit7)
    db $90,$FF,$05,$06,$04   ; $6CB2 HEADER(bit7)
    db $90,$FF,$05,$03,$02   ; $6CB7 HEADER(bit7)
    db $40,$E0,$05,$00,$FF   ; $6CBC type0 face4 spr$E0 (+5,+0) ev$FF
    db $40,$E1,$05,$00,$FF   ; $6CC1 type0 face4 spr$E1 (+5,+0) ev$FF
    db $40,$E2,$05,$00,$FF   ; $6CC6 type0 face4 spr$E2 (+5,+0) ev$FF
    db $40,$E3,$05,$00,$FF   ; $6CCB type0 face4 spr$E3 (+5,+0) ev$FF
    db $00,$19,$04,$01,$01   ; $6CD0 type0 face0 spr$19 (+4,+1) ev$01
    db $60,$15,$04,$08,$FF   ; $6CD5 type0 face6 spr$15 (+4,+8) ev$FF
    db $50,$21,$0A,$01,$FF   ; $6CDA type0 face5 spr$21 (+10,+1) ev$FF
    db $FF   ; $6CDF end
Bank11_Area55_Obj_6CE0:          ; $6CE0  (object list)
    db $90,$FF,$04,$04,$03   ; $6CE0 HEADER(bit7)
    db $90,$FF,$03,$05,$03   ; $6CE5 HEADER(bit7)
    db $90,$FF,$03,$06,$03   ; $6CEA HEADER(bit7)
    db $90,$FF,$06,$04,$04   ; $6CEF HEADER(bit7)
    db $90,$FF,$06,$05,$04   ; $6CF4 HEADER(bit7)
    db $90,$FF,$05,$06,$04   ; $6CF9 HEADER(bit7)
    db $40,$E0,$05,$00,$FF   ; $6CFE type0 face4 spr$E0 (+5,+0) ev$FF
    db $40,$E1,$05,$00,$FF   ; $6D03 type0 face4 spr$E1 (+5,+0) ev$FF
    db $40,$E2,$05,$00,$FF   ; $6D08 type0 face4 spr$E2 (+5,+0) ev$FF
    db $40,$E3,$05,$00,$FF   ; $6D0D type0 face4 spr$E3 (+5,+0) ev$FF
    db $FF   ; $6D12 end
Bank11_Area55_Obj_6D13:          ; $6D13  (object list)
    db $FF   ; $6D13 end
Bank11_Area55_Obj_6D14:          ; $6D14  (object list)
    db $04,$01,$00,$00,$01   ; $6D14 type4 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $6D19 (tail)

SECTION "Bank 11 Area 56 ObjList $6D2C", ROMX[$6D2C], BANK[11]
Bank11_Area56_Obj_6D2C:          ; $6D2C  (object list)
    db $90,$FF,$04,$00,$02   ; $6D2C HEADER(bit7)
    db $90,$FF,$05,$00,$03   ; $6D31 HEADER(bit7)
    db $90,$FF,$06,$00,$04   ; $6D36 HEADER(bit7)
    db $90,$FF,$01,$01,$05   ; $6D3B HEADER(bit7)
    db $90,$FF,$05,$02,$06   ; $6D40 HEADER(bit7)
    db $90,$FF,$08,$02,$07   ; $6D45 HEADER(bit7)
    db $90,$FF,$02,$04,$08   ; $6D4A HEADER(bit7)
    db $90,$FF,$03,$04,$09   ; $6D4F HEADER(bit7)
    db $90,$FF,$04,$04,$0A   ; $6D54 HEADER(bit7)
    db $90,$FF,$07,$04,$0B   ; $6D59 HEADER(bit7)
    db $90,$FF,$08,$04,$0C   ; $6D5E HEADER(bit7)
    db $90,$FF,$07,$05,$0D   ; $6D63 HEADER(bit7)
    db $90,$FF,$01,$06,$0E   ; $6D68 HEADER(bit7)
    db $90,$FF,$05,$06,$0F   ; $6D6D HEADER(bit7)
    db $90,$FF,$06,$02,$10   ; $6D72 HEADER(bit7)
    db $40,$E0,$08,$00,$FF   ; $6D77 type0 face4 spr$E0 (+8,+0) ev$FF
    db $40,$E1,$08,$00,$FF   ; $6D7C type0 face4 spr$E1 (+8,+0) ev$FF
    db $40,$E2,$08,$00,$FF   ; $6D81 type0 face4 spr$E2 (+8,+0) ev$FF
    db $40,$E3,$08,$00,$FF   ; $6D86 type0 face4 spr$E3 (+8,+0) ev$FF
    db $40,$39,$02,$00,$FF   ; $6D8B type0 face4 spr$39 (+2,+0) ev$FF
    db $00,$1E,$08,$05,$01   ; $6D90 type0 face0 spr$1E (+8,+5) ev$01
    db $70,$21,$00,$00,$FF   ; $6D95 type0 face7 spr$21 (+0,+0) ev$FF
    db $FF   ; $6D9A end
Bank11_Area56_Obj_6D9B:          ; $6D9B  (object list)
    db $90,$FF,$04,$00,$02   ; $6D9B HEADER(bit7)
    db $90,$FF,$05,$00,$03   ; $6DA0 HEADER(bit7)
    db $90,$FF,$06,$00,$04   ; $6DA5 HEADER(bit7)
    db $90,$FF,$01,$01,$05   ; $6DAA HEADER(bit7)
    db $90,$FF,$05,$02,$06   ; $6DAF HEADER(bit7)
    db $90,$FF,$08,$02,$07   ; $6DB4 HEADER(bit7)
    db $90,$FF,$02,$04,$08   ; $6DB9 HEADER(bit7)
    db $90,$FF,$03,$04,$09   ; $6DBE HEADER(bit7)
    db $90,$FF,$04,$04,$0A   ; $6DC3 HEADER(bit7)
    db $90,$FF,$07,$04,$0B   ; $6DC8 HEADER(bit7)
    db $90,$FF,$08,$04,$0C   ; $6DCD HEADER(bit7)
    db $90,$FF,$07,$05,$0D   ; $6DD2 HEADER(bit7)
    db $90,$FF,$01,$06,$0E   ; $6DD7 HEADER(bit7)
    db $90,$FF,$05,$06,$0F   ; $6DDC HEADER(bit7)
    db $40,$E0,$08,$00,$FF   ; $6DE1 type0 face4 spr$E0 (+8,+0) ev$FF
    db $40,$E1,$08,$00,$FF   ; $6DE6 type0 face4 spr$E1 (+8,+0) ev$FF
    db $40,$E2,$08,$00,$FF   ; $6DEB type0 face4 spr$E2 (+8,+0) ev$FF
    db $40,$E3,$08,$00,$FF   ; $6DF0 type0 face4 spr$E3 (+8,+0) ev$FF
    db $FF   ; $6DF5 end
Bank11_Area56_Obj_6DF6:          ; $6DF6  (object list)
    db $FF   ; $6DF6 end
Bank11_Area56_Obj_6DF7:          ; $6DF7  (object list)
    db $08,$05,$00,$00,$01   ; $6DF7 type8 face0 spr$05 (+0,+0) ev$01
    db $04,$05,$FF   ; $6DFC (tail)

SECTION "Bank 11 Area 57 ObjList $6E0F", ROMX[$6E0F], BANK[11]
Bank11_Area57_Obj_6E0F:          ; $6E0F  (object list)
    db $90,$FF,$06,$06,$04   ; $6E0F HEADER(bit7)
    db $8F,$FF,$08,$06,$01   ; $6E14 HEADER(bit7)
    db $8F,$FF,$07,$04,$02   ; $6E19 HEADER(bit7)
    db $00,$2C,$01,$01,$03   ; $6E1E type0 face0 spr$2C (+1,+1) ev$03
    db $50,$21,$0A,$00,$FF   ; $6E23 type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6E28 end
Bank11_Area57_Obj_6E29:          ; $6E29  (object list)
    db $8F,$FF,$07,$04,$02   ; $6E29 HEADER(bit7)
    db $FF   ; $6E2E end
Bank11_Area57_Obj_6E2F:          ; $6E2F  (object list)
    db $FF   ; $6E2F end
Bank11_Area57_Obj_6E30:          ; $6E30  (object list)
    db $07,$06,$00,$00,$01   ; $6E30 type7 face0 spr$06 (+0,+0) ev$01
    db $04,$05,$FF   ; $6E35 (tail)

SECTION "Bank 11 Area 58 ObjList $6E48", ROMX[$6E48], BANK[11]
Bank11_Area58_Obj_6E48:          ; $6E48  (object list)
    db $90,$FF,$02,$02,$02   ; $6E48 HEADER(bit7)
    db $90,$FF,$02,$03,$02   ; $6E4D HEADER(bit7)
    db $90,$FF,$02,$05,$02   ; $6E52 HEADER(bit7)
    db $90,$FF,$02,$06,$02   ; $6E57 HEADER(bit7)
    db $90,$FF,$04,$02,$02   ; $6E5C HEADER(bit7)
    db $90,$FF,$04,$04,$02   ; $6E61 HEADER(bit7)
    db $90,$FF,$04,$06,$02   ; $6E66 HEADER(bit7)
    db $90,$FF,$06,$02,$02   ; $6E6B HEADER(bit7)
    db $90,$FF,$06,$03,$02   ; $6E70 HEADER(bit7)
    db $90,$FF,$06,$05,$02   ; $6E75 HEADER(bit7)
    db $90,$FF,$06,$06,$02   ; $6E7A HEADER(bit7)
    db $90,$FF,$08,$02,$02   ; $6E7F HEADER(bit7)
    db $90,$FF,$08,$03,$02   ; $6E84 HEADER(bit7)
    db $90,$FF,$08,$04,$02   ; $6E89 HEADER(bit7)
    db $90,$FF,$08,$05,$02   ; $6E8E HEADER(bit7)
    db $90,$FF,$08,$06,$02   ; $6E93 HEADER(bit7)
    db $90,$FF,$01,$05,$03   ; $6E98 HEADER(bit7)
    db $90,$FF,$02,$04,$04   ; $6E9D HEADER(bit7)
    db $90,$FF,$05,$03,$05   ; $6EA2 HEADER(bit7)
    db $90,$FF,$05,$04,$06   ; $6EA7 HEADER(bit7)
    db $90,$FF,$07,$03,$07   ; $6EAC HEADER(bit7)
    db $90,$FF,$07,$05,$08   ; $6EB1 HEADER(bit7)
    db $40,$E0,$01,$00,$FF   ; $6EB6 type0 face4 spr$E0 (+1,+0) ev$FF
    db $40,$E1,$01,$00,$FF   ; $6EBB type0 face4 spr$E1 (+1,+0) ev$FF
    db $40,$E2,$01,$00,$FF   ; $6EC0 type0 face4 spr$E2 (+1,+0) ev$FF
    db $40,$E3,$01,$00,$FF   ; $6EC5 type0 face4 spr$E3 (+1,+0) ev$FF
    db $00,$18,$01,$01,$01   ; $6ECA type0 face0 spr$18 (+1,+1) ev$01
    db $50,$21,$0A,$00,$FF   ; $6ECF type0 face5 spr$21 (+10,+0) ev$FF
    db $FF   ; $6ED4 end
Bank11_Area58_Obj_6ED5:          ; $6ED5  (object list)
    db $90,$FF,$02,$02,$02   ; $6ED5 HEADER(bit7)
    db $90,$FF,$02,$03,$02   ; $6EDA HEADER(bit7)
    db $90,$FF,$02,$05,$02   ; $6EDF HEADER(bit7)
    db $90,$FF,$02,$06,$02   ; $6EE4 HEADER(bit7)
    db $90,$FF,$04,$02,$02   ; $6EE9 HEADER(bit7)
    db $90,$FF,$04,$04,$02   ; $6EEE HEADER(bit7)
    db $90,$FF,$04,$06,$02   ; $6EF3 HEADER(bit7)
    db $90,$FF,$06,$02,$02   ; $6EF8 HEADER(bit7)
    db $90,$FF,$06,$03,$02   ; $6EFD HEADER(bit7)
    db $90,$FF,$06,$05,$02   ; $6F02 HEADER(bit7)
    db $90,$FF,$06,$06,$02   ; $6F07 HEADER(bit7)
    db $90,$FF,$08,$02,$02   ; $6F0C HEADER(bit7)
    db $90,$FF,$08,$03,$02   ; $6F11 HEADER(bit7)
    db $90,$FF,$08,$04,$02   ; $6F16 HEADER(bit7)
    db $90,$FF,$08,$05,$02   ; $6F1B HEADER(bit7)
    db $90,$FF,$08,$06,$02   ; $6F20 HEADER(bit7)
    db $40,$E0,$01,$00,$FF   ; $6F25 type0 face4 spr$E0 (+1,+0) ev$FF
    db $40,$E1,$01,$00,$FF   ; $6F2A type0 face4 spr$E1 (+1,+0) ev$FF
    db $40,$E2,$01,$00,$FF   ; $6F2F type0 face4 spr$E2 (+1,+0) ev$FF
    db $40,$E3,$01,$00,$FF   ; $6F34 type0 face4 spr$E3 (+1,+0) ev$FF
    db $FF   ; $6F39 end
Bank11_Area58_Obj_6F3A:          ; $6F3A  (object list)
    db $FF   ; $6F3A end
Bank11_Area58_Obj_6F3B:          ; $6F3B  (object list)
    db $01,$01,$00,$00,$01   ; $6F3B type1 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $6F40 (tail)

SECTION "Bank 11 Area 59 ObjList $6F53", ROMX[$6F53], BANK[11]
Bank11_Area59_Obj_6F53:          ; $6F53  (object list)
    db $05,$1B,$03,$04,$01   ; $6F53 type5 face0 spr$1B (+3,+4) ev$01
    db $50,$21,$0A,$01,$FF   ; $6F58 type0 face5 spr$21 (+10,+1) ev$FF
    db $FF   ; $6F5D end
Bank11_Area59_Obj_6F5E:          ; $6F5E  (object list)
    db $FF   ; $6F5E end
Bank11_Area59_Obj_6F5F:          ; $6F5F  (object list)
    db $FF   ; $6F5F end
Bank11_Area59_Obj_6F60:          ; $6F60  (object list)
    db $05,$03,$00,$00,$01   ; $6F60 type5 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $6F65 (tail)

SECTION "Bank 11 Area 60 ObjList $6F7E", ROMX[$6F7E], BANK[11]
Bank11_Area60_Obj_6F7E:          ; $6F7E  (object list)
    db $8F,$FF,$04,$02,$01   ; $6F7E HEADER(bit7)
    db $8F,$FF,$02,$03,$02   ; $6F83 HEADER(bit7)
    db $8F,$FF,$01,$04,$03   ; $6F88 HEADER(bit7)
    db $8F,$FF,$08,$04,$04   ; $6F8D HEADER(bit7)
    db $8F,$FF,$06,$05,$05   ; $6F92 HEADER(bit7)
    db $8F,$FF,$03,$03,$06   ; $6F97 HEADER(bit7)
    db $8F,$FF,$07,$04,$07   ; $6F9C HEADER(bit7)
    db $60,$15,$02,$06,$FF   ; $6FA1 type0 face6 spr$15 (+2,+6) ev$FF
    db $70,$21,$00,$00,$FF   ; $6FA6 type0 face7 spr$21 (+0,+0) ev$FF
    db $00,$23,$05,$01,$08   ; $6FAB type0 face0 spr$23 (+5,+1) ev$08
    db $00,$FF,$05,$01,$08   ; $6FB0 type0 face0 spr$FF (+5,+1) ev$08
    db $00,$FF,$06,$01,$08   ; $6FB5 type0 face0 spr$FF (+6,+1) ev$08
    db $FF   ; $6FBA end
Bank11_Area60_Obj_6FBB:          ; $6FBB  (object list)
    db $8F,$FF,$04,$02,$01   ; $6FBB HEADER(bit7)
    db $8F,$FF,$02,$03,$02   ; $6FC0 HEADER(bit7)
    db $8F,$FF,$01,$04,$03   ; $6FC5 HEADER(bit7)
    db $8F,$FF,$08,$04,$04   ; $6FCA HEADER(bit7)
    db $8F,$FF,$06,$05,$05   ; $6FCF HEADER(bit7)
    db $8F,$FF,$03,$03,$06   ; $6FD4 HEADER(bit7)
    db $8F,$FF,$07,$04,$07   ; $6FD9 HEADER(bit7)
    db $FF   ; $6FDE end
Bank11_Area60_Obj_6FDF:          ; $6FDF  (object list)
    db $FF   ; $6FDF end
Bank11_Area60_Obj_6FE0:          ; $6FE0  (object list)
    db $06,$01,$00,$00,$01   ; $6FE0 type6 face0 spr$01 (+0,+0) ev$01
    db $04,$05,$FF   ; $6FE5 (tail)

SECTION "Bank 11 Area 61 ObjList $6FF8", ROMX[$6FF8], BANK[11]
Bank11_Area61_Obj_6FF8:          ; $6FF8  (object list)
    db $90,$FF,$04,$04,$01   ; $6FF8 HEADER(bit7)
    db $90,$FF,$05,$04,$02   ; $6FFD HEADER(bit7)
    db $40,$E1,$04,$04,$FF   ; $7002 type0 face4 spr$E1 (+4,+4) ev$FF
    db $40,$5F,$04,$02,$FF   ; $7007 type0 face4 spr$5F (+4,+2) ev$FF
    db $40,$05,$04,$02,$FF   ; $700C type0 face4 spr$05 (+4,+2) ev$FF
    db $40,$39,$00,$00,$FF   ; $7011 type0 face4 spr$39 (+0,+0) ev$FF
    db $60,$E0,$05,$04,$FF   ; $7016 type0 face6 spr$E0 (+5,+4) ev$FF
    db $FF   ; $701B end
Bank11_Area61_Obj_701C:          ; $701C  (object list)
    db $90,$FF,$04,$04,$03   ; $701C HEADER(bit7)
    db $90,$FF,$05,$04,$03   ; $7021 HEADER(bit7)
    db $FF   ; $7026 end
Bank11_Area61_Obj_7027:          ; $7027  (object list)
    db $FF   ; $7027 end

SECTION "Bank 11 Area 62 ObjList $7038", ROMX[$7038], BANK[11]
Bank11_Area62_Obj_7038:          ; $7038  (object list)
    db $50,$21,$0A,$01,$FF   ; $7038 type0 face5 spr$21 (+10,+1) ev$FF
    db $00,$28,$04,$05,$01   ; $703D type0 face0 spr$28 (+4,+5) ev$01
    db $00,$FF,$04,$04,$01   ; $7042 type0 face0 spr$FF (+4,+4) ev$01
    db $00,$FF,$05,$04,$01   ; $7047 type0 face0 spr$FF (+5,+4) ev$01
    db $FF   ; $704C end
Bank11_Area62_Obj_704D:          ; $704D  (object list)
    db $FF   ; $704D end
Bank11_Area62_Obj_704E:          ; $704E  (object list)
    db $FF   ; $704E end
Bank11_Area62_Obj_704F:          ; $704F  (object list)
    db $01,$03,$00,$00,$01   ; $704F type1 face0 spr$03 (+0,+0) ev$01
    db $04,$05,$FF   ; $7054 (tail)
