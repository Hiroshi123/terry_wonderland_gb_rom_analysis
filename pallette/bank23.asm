; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 23  (Map tile loader + CGB palette manager)
; ============================================================================
;
; Called from: bank11/fn3 (map section loader), bank6/fn6 (overworld frame
;   handler), and palette animation callers throughout overworld state.
;
; Bank 23 memory map:
;   File offset $5C000-$5FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 23 ($17)
;
; TWO COUPLED SYSTEMS live here:
;
; [1] MAP TILE LOADER  (fn0, fn1, fn9)
;   Resolves area → scroll → zone → tile-data via a 3-level ROM pointer chain,
;   then writes raw tile bytes into WRAM:
;     fn0 → $C500  (wall-collision / tile attribute buffer, via Sub_46A1)
;     fn1 → $C200  (secondary tile buffer, via ROM0 $18A2 decompressor)
;   Sub-area path: branches on wSubAreaFlag; uses $5215/$5415 tables.
;   fn9 is a shared post-load tail that initialises all 7 BG palette entry
;   slots to a ROM default (from $5655) so fn3 can animate before fn6 has
;   loaded area-specific colors.
;
; [2] CGB PALETTE MANAGER  (fn2–fn8, fn10–fn13)
;   Two 64-byte WRAM palette shadow buffers:
;     $C797–$C7D6   wBGPalBuf   (8 palettes × 4 colors × 2 bytes, BGR555)
;     $C7D7–$C816   wOBJPalBuf  (same layout)
;
;   Frame update (called every VBlank):
;     fn3  — streams BG palette bytes to rBCPD ($FF69) and OBJ bytes to
;             rOCPD ($FF6B) using $C89B/$C89C scroll counters and the
;             $440C sub-step offset table [2, 4, 0, 6].  Skips if counter
;             unchanged since last frame.
;     fn5  — drives palette fade: each frame steps $C856 (brightness 0–$1F)
;             by 5, then calls Sub_44D8 (fade-in: clamp each RGB component
;             to $C856) or Sub_45BB (fade-out: darken).
;
;   Load / transition (called on area entry or explicit palette change):
;     fn2  — loads default OBJ palette (64 bytes from ROM $5615 → $C7D7)
;     fn4  — initialises $C850 fade state; if fade-out writes all-white to
;             hardware first; calls ROM0 $1FA4 to trigger the fade sequence
;     fn6  — loads 8-byte BG palette slot for current scroll sector
;             (ROM $62FD + wScrollIdx×8 → wBGPalBuf[wTileType]), then
;             calls fn9 and falls through into fn7
;     fn7  — writes a 6×6 tile grid (tile ID = wTileType) to VRAM
;             $9800/$9BFF; computes VRAM address from hScrollY/hScrollX and
;             $C820/$C821 offsets; switches to VRAM bank 1 for attributes
;     fn8  — full flush: $C797→rBCPD (64 bytes), $C7D7→rOCPD (64 bytes)
;     fn10 — clears the $9800 VRAM tilemap (256 entries via ROM0 $1E8C)
;     fn11 — loads 64-byte BG palette from ROM $69BD[wScrollIdx × 64]
;     fn12 — loads  8-byte OBJ palette from ROM $6AFD[wScrollIdx × 8]
;     fn13 — loads  8-byte OBJ palette from ROM $6B0D[wScrollIdx × 8]
;
; Every exported function checks $C81D (wMapEnable) at entry; RET Z if 0.
;
; Function table at $4001 (bank-number self-id byte at $4000 = $17):
;   fn0:  $401D  map tile loader → $C500
;   fn1:  $409E  secondary tile loader → $C200
;   fn2:  $41C0  OBJ palette init from $5615
;   fn3:  $4272  per-frame BG+OBJ palette scroll
;   fn4:  $4410  palette fade initializer
;   fn5:  $4478  per-frame palette brightness fade
;   fn6:  $41D0  scroll-sector palette load + VRAM tile write
;   fn7:  $41F2  VRAM 6×6 tile grid writer
;   fn8:  $46DD  full BG+OBJ palette hardware flush
;   fn9:  $4102  post-load palette pointer init (shared tail of fn0/fn1)
;   fn10: $4192  clear $9800 VRAM tilemap
;   fn11: $4712  BG palette load from ROM $69BD table
;   fn12: $4733  OBJ palette load from ROM $6AFD table
;   fn13: $4751  OBJ palette load from ROM $6B0D table
;
; Cross-bank calls from this bank:
;   ROM0 $18A2  — tile decompressor / raw copier into $C200
;   ROM0 $1E79  — VBlank-safe gate (poll for mode 1/0 before VRAM access)
;   ROM0 $1E80  — single VRAM tile write (A = tile ID)
;   ROM0 $1E8C  — VRAM fill helper
;   ROM0 $1FA4  — palette fade trigger (starts fade animation)

; ============================================================================
; WRAM VARIABLES
; ============================================================================
; $C81D  wMapEnable        — global enable flag; RET Z if 0 (every fn checks)
; $C81E  wScrollIdx        — current scroll sector index (fn6, fn11–fn13)
; $C81F  wTileType         — tile ID for VRAM write (fn7) / palette slot (fn6)
; $C820  wScrollXOff       — X position offset for fn7 (bits[4:0]=col advance)
; $C821  wScrollYOff       — Y position offset for fn7 (in row units, × $20)
;
; Palette shadow buffers:
; $C797–$C7D6  wBGPalBuf   — 8 BG palettes, each 8 bytes (4 × BGR555 colors)
; $C7D7–$C816  wOBJPalBuf  — 8 OBJ palettes, same layout
; $C7CF–$C7D6  — palette slot 7 within wBGPalBuf; fn9 reads $C7D1/$C7D2 (the
;                [+2..+3] word = default color B) and $C7D5/$C7D6 (the
;                [+6..+7] word = default color D), replicates to all 7 slots
;
; Palette fade state:
; $C850  wPalFadeCtrl      — bit7: direction (0=fade-in, 1=fade-out);
;                             bits[5:0]: speed code (÷4 = frames per step)
; $C856  wPalBrightness    — current brightness (0 = black, $1F = full)
; $C857  wPalFrameRate     — reload value for $C858
; $C858  wPalFrameCtr      — per-frame countdown; step only when it reaches 0
;
; Palette scroll counters:
; $C89B  wBGPalScrollCtr   — changed externally to trigger BG palette update
; $C89C  wOBJPalScrollCtr  — changed externally to trigger OBJ palette update
; $C89E  wBGPalScrollLast  — last value of $C89B seen by fn3; skip if equal
; $C89F  wOBJPalScrollLast — last value of $C89C seen by fn3; skip if equal
;
; Area / scroll state (read, not written here):
; $C925  wScrollCount      — current scroll zone index within area
; $C93F  wSubAreaTypeFlag  — 0/$01 = use $5215; $02 = use $5415
; $C940  wSubAreaScrollIdxArr — scroll index array (1 byte per wScrollCount)
; $C968  wAreaID           — current area number
; $C969  wSubAreaFlag      — non-zero = sub-area pointer chain

; ============================================================================
; HRAM REGISTERS
; ============================================================================
; $FFB7  hScrollX          — camera X pixel position
; $FFBB  hScrollY          — camera Y pixel position
; $FF4F  rVBK              — VRAM bank select (1 = bank 1 for tile attributes)
; $FF68  rBCPS             — BG Color Palette Spec ($80 = auto-increment idx 0)
; $FF69  rBCPD             — BG Color Palette Data
; $FF6A  rOCPS             — OBJ Color Palette Spec
; $FF6B  rOCPD             — OBJ Color Palette Data

; ============================================================================
; ROM DATA TABLES  (in this bank)
; ============================================================================
; $440C  (4 bytes) Palette sub-step offset table: [$02, $04, $00, $06]
;        Sub_42AC and Sub_4376 extract 4 × 2-bit fields from the scroll
;        counter and use each to select one of these byte offsets into the
;        8-byte palette record (0=color0, 2=color1, 4=color2, 6=color3).
;
; $476F  Area pointer table
;        16-bit ptrs indexed by wAreaID × 2 → P1 (area section table).
;        P1[wScrollCount × 2] → P2 (zone descriptor table).
;        P2 → zone_index; P2[zone_index × 4] → (tile_data_ptr, dest_ptr).
;
; $51F5  Sub-area name / tile ptr table (indexed by wAreaID × 2)
;        Used by the fn0 and fn1 sub-area paths as the destination pointer.
;
; $5215  Sub-area type A tile data table
; $5415  Sub-area type B tile data table (selected when wSubAreaTypeFlag == $02)
;        Each table: 2-byte ptrs to tile data, indexed by the sub-area scroll
;        index read from wSubAreaScrollIdxArr[wScrollCount].
;        RESOLVED: each 2-byte entry = {block, bank} and the bank is always
;        bank61 ($3D). $5215 has 256 slots -> 196 DISTINCT bank61 blocks (many
;        slots alias); the table continues into bank62 ($3E) beyond slot 256.
;        Each block LZ-decompresses (ROM0 $18A2) to $C200 = the 4-bit CGB
;        ATTRIBUTE (palette/bank/flip) map — NOT the tile numbers. The paired
;        8-bit TILE-NUMBER map is the $C300 layer, resolved separately by
;        bank11 $4239 (see overworld/bank11.asm). So $C200 (this) + $C300
;        together = one rendered screen. Decode: rendertiles.decompress(
;        data,61,block,base=0xC200), 256B = 16x16 cells (low nibble = region id).
;
; $5615  Default OBJ palette data (64 raw bytes loaded by fn2 → $C7D7)
;
; $5655  Default BG palette init record (14 bytes; fn9 uses first 8)
;        Byte layout of first 8 bytes (copied to $C7CF):
;          [0..1] $0139 — unknown header / index
;          [2..3] $6BFF — default color B (replicated to all 7 BG slots +2/+3)
;          [4..5] $033F — flags / other data
;          [6..7] $0000 — default color D (replicated to all 7 BG slots +6/+7)
;
; $62FD  Scroll-sector BG palette table (8 bytes per sector)
;        fn6 loads entry [wScrollIdx] into wBGPalBuf[wTileType × 8].
;
; $69BD  Full BG palette ROM table (64 bytes per entry)
;        fn11 loads entry [wScrollIdx] (64 bytes) into all of wBGPalBuf.
;
; $6AFD  OBJ palette table A (8 bytes per entry)
;        fn12 loads entry [wScrollIdx] into wOBJPalBuf slot 0.
;
; $6B0D  OBJ palette table B (8 bytes per entry)
;        fn13 loads entry [wScrollIdx] into wOBJPalBuf slot 0.

; ============================================================================
; Bank23_Fn0  ($401D)  — Main area tile loader → $C500
; ============================================================================
; Loads tile attribute data for the current area/scroll zone into $C500.
;
; Main area path (wSubAreaFlag == 0):
;   Level 1: HL = $476F + wAreaID × 2; P1 = (HL)
;   Level 2: HL = P1 + wScrollCount × 2; P2 = (HL)
;   Level 3: DE = (P2) → zone_index; (P2 + zone_index×4) → tile_data_ptr
;   dest_ptr = (P2 + zone_index×4 + 2)
;   Calls Sub_46A1(HL=tile_data_ptr, C=0, B=4) → 32 bytes → $C500.
;
; Sub-area path (wSubAreaFlag != 0):
;   Select table: wSubAreaTypeFlag==$02 → $5415, else → $5215.
;   idx = wSubAreaScrollIdxArr[wScrollCount]
;   DE = table[idx × 2]          (tile data ptr)
;   HL = $51F5[wAreaID × 2]      (dest ptr)
;   Calls Sub_46A1(HL=dest, C=0, B=4) → 32 bytes → $C500.
;
; Both paths fall into fn9 on exit.
Bank23_Fn0:                                 ; $401D
    LD A,($C81D)               ; $401D  [FA 1D C8]  wMapEnable
    OR A                       ; $4020  [B7]
    RET Z                      ; $4021  [C8]
    LD A,($C969)               ; $4022  [FA 69 C9]  wSubAreaFlag
    OR A                       ; $4025  [B7]
    JP NZ,Bank23_Fn0_SubArea   ; $4026  [C2 64 40]  $4064
    ; --- main area path ---
    LD HL,$476F                ; $4029  [21 6F 47]  area pointer table
    LD A,($C968)               ; $402C  [FA 68 C9]  wAreaID
    ADD A,A                    ; $402F  [87]  × 2
    ADD A,L                    ; $4030  [85]
    LD L,A                     ; $4031  [6F]
    LD A,$00                   ; $4032  [3E 00]
    ADC A,H                    ; $4034  [8C]
    LD H,A                     ; $4035  [67]  HL = &$476F[wAreaID]
    LD A,(HL+)                 ; $4036  [2A]
    LD H,(HL)                  ; $4037  [66]
    LD L,A                     ; $4038  [6F]  P1 = $476F[wAreaID] (area section table ptr)
    LD A,($C925)               ; $4039  [FA 25 C9]  wScrollCount
    ADD A,A                    ; $403C  [87]  × 2
    ADD A,L                    ; $403D  [85]
    LD L,A                     ; $403E  [6F]
    LD A,$00                   ; $403F  [3E 00]
    ADC A,H                    ; $4041  [8C]
    LD H,A                     ; $4042  [67]  HL = P1 + wScrollCount × 2
    LD A,(HL+)                 ; $4043  [2A]
    LD H,(HL)                  ; $4044  [66]
    LD L,A                     ; $4045  [6F]  P2 = P1[wScrollCount] (zone descriptor table)
    LD E,(HL)                  ; $4046  [5E]
    INC HL                     ; $4047  [23]
    LD D,(HL)                  ; $4048  [56]
    INC HL                     ; $4049  [23]  DE = zone descriptor ptr (read from P2[0..1])
    LD A,(DE)                  ; $404A  [1A]  A = zone_index
    ADD A,A                    ; $404B  [87]
    ADD A,A                    ; $404C  [87]  × 4
    ADD A,L                    ; $404D  [85]
    LD L,A                     ; $404E  [6F]
    LD A,$00                   ; $404F  [3E 00]
    ADC A,H                    ; $4051  [8C]
    LD H,A                     ; $4052  [67]  HL = P2 + zone_index × 4
    LD E,(HL)                  ; $4053  [5E]
    INC HL                     ; $4054  [23]
    LD D,(HL)                  ; $4055  [56]
    INC HL                     ; $4056  [23]  DE = tile data ROM ptr
    LD A,(HL+)                 ; $4057  [2A]
    LD H,(HL)                  ; $4058  [66]
    LD L,A                     ; $4059  [6F]  HL = destination (tile buffer base in WRAM)
    LD C,$00                   ; $405A  [0E 00]
    LD B,$04                   ; $405C  [06 04]  copy 4 × 8 = 32 bytes
    CALL $46A1                 ; $405E  [CD A1 46]  Sub_46A1 → $C500
    JP $4102                   ; $4061  [C3 02 41]  → Bank23_Fn9

Bank23_Fn0_SubArea:                        ; $4064
    LD DE,$5215                ; $4064  [11 15 52]  sub-area type A table
    LD A,($C93F)               ; $4067  [FA 3F C9]  wSubAreaTypeFlag
    CP $02                     ; $406A  [FE 02]
    JR NZ,$4071                ; $406C  [20 03]
    LD DE,$5415                ; $406E  [11 15 54]  sub-area type B table
    ; fall through at $4071
    LD A,($C925)               ; $4071  [FA 25 C9]  wScrollCount
    LD HL,$C940                ; $4074  [21 40 C9]  wSubAreaScrollIdxArr
    ADD A,L                    ; $4077  [85]
    LD L,A                     ; $4078  [6F]
    LD A,$00                   ; $4079  [3E 00]
    ADC A,H                    ; $407B  [8C]
    LD H,A                     ; $407C  [67]  HL = &wSubAreaScrollIdxArr[wScrollCount]
    LD L,(HL)                  ; $407D  [6E]  idx = wSubAreaScrollIdxArr[wScrollCount]
    LD H,$00                   ; $407E  [26 00]
    ADD HL,HL                  ; $4080  [29]  idx × 2
    ADD HL,DE                  ; $4081  [19]  HL = table + idx × 2
    LD A,(HL+)                 ; $4082  [2A]
    LD D,(HL)                  ; $4083  [56]
    LD E,A                     ; $4084  [5F]  DE = sub-area tile data ptr (from table)
    LD HL,$51F5                ; $4085  [21 F5 51]  sub-area dest ptr table (by wAreaID)
    LD A,($C968)               ; $4088  [FA 68 C9]  wAreaID
    ADD A,A                    ; $408B  [87]
    ADD A,L                    ; $408C  [85]
    LD L,A                     ; $408D  [6F]
    LD A,$00                   ; $408E  [3E 00]
    ADC A,H                    ; $4090  [8C]
    LD H,A                     ; $4091  [67]
    LD A,(HL+)                 ; $4092  [2A]
    LD H,(HL)                  ; $4093  [66]
    LD L,A                     ; $4094  [6F]  HL = $51F5[wAreaID] (dest ptr)
    LD C,$00                   ; $4095  [0E 00]
    LD B,$04                   ; $4097  [06 04]  32 bytes
    CALL $46A1                 ; $4099  [CD A1 46]  Sub_46A1 → $C500
    JR $4102                   ; $409C  [18 64]  → Bank23_Fn9

; ============================================================================
; Bank23_Fn1  ($409E)  — Secondary tile loader → $C200
; ============================================================================
; Identical 3-level pointer chain as fn0, but passes the resolved tile
; data pointer to ROM0 $18A2 (tile decompressor) with destination $C200.
; Sub-area path: same branch on wSubAreaTypeFlag, same $5215/$5415 tables.
Bank23_Fn1:                                 ; $409E
    LD A,($C969)               ; $409E  [FA 69 C9]  wSubAreaFlag
    OR A                       ; $40A1  [B7]         test main vs sub-area
    JP NZ,$40DA                ; $40A2  [C2 DA 40]  sub-area -> $40DA (mirrors fn0)
    ; --- main area path (same 3-level directory walk as fn0) ---
    LD HL,$476F                ; $40A5  [21 6F 47]  per-area directory base
    LD A,($C968)               ; $40A8  [FA 68 C9]  wAreaID
    ADD A,A                    ; $40AB  [87]         x2 (word index)
    ADD A,L                    ; $40AC  [85]
    LD L,A                     ; $40AD  [6F]
    LD A,$00                   ; $40AE  [3E 00]
    ADC A,H                    ; $40B0  [8C]
    LD H,A                     ; $40B1  [67]         HL = &$476F[wAreaID]
    LD A,(HL+)                 ; $40B2  [2A]
    LD H,(HL)                  ; $40B3  [66]
    LD L,A                     ; $40B4  [6F]         P1 = $476F[wAreaID] (area section table)
    LD A,($C925)               ; $40B5  [FA 25 C9]  wScrollCount (room)
    ADD A,A                    ; $40B8  [87]         x2
    ADD A,L                    ; $40B9  [85]
    LD L,A                     ; $40BA  [6F]
    LD A,$00                   ; $40BB  [3E 00]
    ADC A,H                    ; $40BD  [8C]
    LD H,A                     ; $40BE  [67]         HL = P1 + wScrollCount*2
    LD A,(HL+)                 ; $40BF  [2A]
    LD H,(HL)                  ; $40C0  [66]
    LD L,A                     ; $40C1  [6F]         P2 = P1[room] (zone descriptor table)
    LD E,(HL)                  ; $40C2  [5E]
    INC HL                     ; $40C3  [23]
    LD D,(HL)                  ; $40C4  [56]
    INC HL                     ; $40C5  [23]         DE = zone descriptor ptr (P2[0..1])
    LD A,(DE)                  ; $40C6  [1A]         A = zone_index
    ADD A,A                    ; $40C7  [87]
    ADD A,A                    ; $40C8  [87]         x4
    ADD A,L                    ; $40C9  [85]
    LD L,A                     ; $40CA  [6F]
    LD A,$00                   ; $40CB  [3E 00]
    ADC A,H                    ; $40CD  [8C]
    LD H,A                     ; $40CE  [67]         HL = P2 + zone_index*4
    LD E,(HL)                  ; $40CF  [5E]
    INC HL                     ; $40D0  [23]
    LD D,(HL)                  ; $40D1  [56]
    INC HL                     ; $40D2  [23]         DE = tile-data ROM ptr {bank,block}
    LD HL,$C200                ; $40D3  [21 00 C2]  dest = $C200 (4-bit CGB attribute/color buffer)
    CALL $18A2                 ; $40D6  [CD A2 18]  ROM0 TileLoad: LZ-decompress -> $C200
    RET                        ; $40D9  [C9]         (fn2 paints $C200 to VRAM $9800 VBK1)
    ; sub-area path at $40DA: mirrors fn0 sub-area, calls $18A2 → $C200

; ============================================================================
; Bank23_Fn9  ($4102)  — Post-load palette pointer init (fn0/fn1 shared tail)
; ============================================================================
; Called (or jumped to) by fn0 and fn1 after tile data is loaded.
; Step 1: copies 8 bytes from ROM $5655 into wBGPalBuf slot 7 ($C7CF).
; Step 2: reads $C7D1/$C7D2 (the [+2..+3] word = default color B) and
;         replicates it to the [+2..+3] position of all 7 active BG palette
;         entries ($C799/$C79A, $C7A1/$C7A2, ..., $C7C9/$C7CA).
; Step 3: reads $C7D5/$C7D6 (the [+6..+7] word = default color D) and
;         replicates to [+6..+7] of all 7 slots ($C79D, $C7A5, ..., $C7CD).
; This provides a ROM-default color for both "B" and "D" positions in every
; palette slot so that fn3 can animate immediately, before fn6 loads
; area-specific colors into individual slots.
Bank23_Fn9:                                 ; $4102
    LD A,($C81D)               ; $4102  [FA 1D C8]
    OR A                       ; $4105  [B7]
    RET Z                      ; $4106  [C8]
    LD HL,$5655                ; $4107  [21 55 56]  default palette init record
    LD C,$07                   ; $410A  [0E 07]  dest = palette slot 7 (offset 7×8=56)
    LD B,$01                   ; $410C  [06 01]  copy 1×8 = 8 bytes
    CALL $46A1                 ; $410E  [CD A1 46]  → $C7CF..$C7D6
    ; read default color B from $C7D1/$C7D2 (= $5655[2..3])
    LD A,($C7D1)               ; $4111  [FA D1 C7]
    LD L,A                     ; $4114  [6F]
    LD A,($C7D2)               ; $4115  [FA D2 C7]
    LD H,A                     ; $4118  [67]
    ; replicate to color B of 7 BG palette slots (stride 8 from $C799)
    LD A,L                     ; $4119  [7D]
    LD ($C799),A               ; $411A  [EA 99 C7]
    LD A,H                     ; $411D  [7C]
    LD ($C79A),A               ; $411E  [EA 9A C7]
    LD A,L                     ; $4121  [7D]
    LD ($C7A1),A               ; $4122  [EA A1 C7]
    LD A,H                     ; $4125  [7C]
    LD ($C7A2),A               ; $4126  [EA A2 C7]
    LD A,L                     ; $4129  [7D]
    LD ($C7A9),A               ; $412A  [EA A9 C7]
    LD A,H                     ; $412D  [7C]
    LD ($C7AA),A               ; $412E  [EA AA C7]
    LD A,L                     ; $4131  [7D]
    LD ($C7B1),A               ; $4132  [EA B1 C7]
    LD A,H                     ; $4135  [7C]
    LD ($C7B2),A               ; $4136  [EA B2 C7]
    LD A,L                     ; $4139  [7D]
    LD ($C7B9),A               ; $413A  [EA B9 C7]
    LD A,H                     ; $413D  [7C]
    LD ($C7BA),A               ; $413E  [EA BA C7]
    LD A,L                     ; $4141  [7D]
    LD ($C7C1),A               ; $4142  [EA C1 C7]
    LD A,H                     ; $4145  [7C]
    LD ($C7C2),A               ; $4146  [EA C2 C7]
    LD A,L                     ; $4149  [7D]
    LD ($C7C9),A               ; $414A  [EA C9 C7]
    LD A,H                     ; $414D  [7C]
    LD ($C7CA),A               ; $414E  [EA CA C7]
    ; read default color D from $C7D5/$C7D6 (= $5655[6..7])
    LD A,($C7D5)               ; $4151  [FA D5 C7]
    LD L,A                     ; $4154  [6F]
    LD A,($C7D6)               ; $4155  [FA D6 C7]
    LD H,A                     ; $4158  [67]
    ; replicate to color D of 7 BG palette slots (stride 8 from $C79D)
    LD A,L                     ; $4159  [7D]
    LD ($C79D),A               ; $415A  [EA 9D C7]
    LD A,H                     ; $415D  [7C]
    LD ($C79E),A               ; $415E  [EA 9E C7]
    LD A,L                     ; $4161  [7D]
    LD ($C7A5),A               ; $4162  [EA A5 C7]
    LD A,H                     ; $4165  [7C]
    LD ($C7A6),A               ; $4166  [EA A6 C7]
    ; ... continues for 7 total slots ($C7AD/$C7AE, $C7B5/$C7B6,
    ;     $C7BD/$C7BE, $C7C5/$C7C6, $C7CD/$C7CE)
    RET                        ; $4169  [7D]

; ============================================================================
; Bank23_Fn10  ($4192)  — Clear VRAM tilemap $9800
; ============================================================================
; Enables VRAM bank 1 (rVBK=$01), then fills all 256 tilemap entries in
; $9800-$98FF with tile ID 7 using ROM0 $1E8C (VRAM fill helper, 4 entries
; per call).  Restores rVBK=$00 on exit.
Bank23_Fn10:                                ; $4192
    LD A,($C81D)               ; $4192  [FA 1D C8]
    OR A                       ; $4195  [B7]
    RET Z                      ; $4196  [C8]
    DI                         ; $4197  [F3]
    CALL $1E79                 ; $4198  [CD 79 1E]
    LD A,$01                   ; $419B  [3E 01]
    LDH ($4F),A                ; $419D  [E0 4F]  rVBK = 1 (VRAM bank 1 for attributes)
    EI                         ; $419F  [FB]
    LD B,$00                   ; $41A0  [06 00]  outer loop: 256 tiles / 4 per call = 64 iters
    LD HL,$9800                ; $41A2  [21 00 98]  VRAM tilemap base
    ; inner: fill 4 tiles per CALL $1E8C
    LD A,$07                   ; $41A5  [3E 07]
    CALL $1E8C                 ; $41A7  [CD 8C 1E]
    CALL $1E8C                 ; $41AA  [CD 8C 1E]
    CALL $1E8C                 ; $41AD  [CD 8C 1E]
    CALL $1E8C                 ; $41B0  [CD 8C 1E]
    DEC B                      ; $41B3  [05]
    JR NZ,$41A5                ; $41B4  [20 EF]
    DI                         ; $41B6  [F3]
    CALL $1E79                 ; $41B7  [CD 79 1E]
    LD A,$00                   ; $41BA  [3E 00]
    LDH ($4F),A                ; $41BC  [E0 4F]  rVBK = 0
    EI                         ; $41BE  [FB]
    RET                        ; $41BF  [C9]

; ============================================================================
; Bank23_Fn2  ($41C0)  — OBJ palette init from ROM $5615
; ============================================================================
; Loads the default OBJ palette (64 bytes from ROM $5615) into wOBJPalBuf
; ($C7D7) via Sub_46BF.
Bank23_Fn2:                                 ; $41C0
    LD A,($C81D)               ; $41C0  [FA 1D C8]
    OR A                       ; $41C3  [B7]
    RET Z                      ; $41C4  [C8]
    LD HL,$5615                ; $41C5  [21 15 56]  default OBJ palette (64 raw bytes)
    LD C,$00                   ; $41C8  [0E 00]  dest offset 0 in wOBJPalBuf
    LD B,$08                   ; $41CA  [06 08]  8×8 = 64 bytes
    CALL $46BF                 ; $41CC  [CD BF 46]  → $C7D7
    RET                        ; $41CF  [C9]

; ============================================================================
; Bank23_Fn6  ($41D0)  — Scroll-sector BG palette load + VRAM tile write
; ============================================================================
; 1. Loads 8 bytes from ROM $62FD + wScrollIdx×8 into wBGPalBuf at slot
;    wTileType (via Sub_46A1, C=wTileType, B=1).
; 2. Calls Bank23_Fn9 (re-init default pointers for remaining slots).
; 3. Falls through into Bank23_Fn7 (write tile grid to VRAM).
Bank23_Fn6:                                 ; $41D0
    LD A,($C81D)               ; $41D0  [FA 1D C8]
    OR A                       ; $41D3  [B7]
    RET Z                      ; $41D4  [C8]
    LD A,($C81E)               ; $41D5  [FA 1E C8]  wScrollIdx
    LD L,A                     ; $41D8  [6F]
    LD H,$00                   ; $41D9  [26 00]
    ADD HL,HL                  ; $41DB  [29]  × 2
    ADD HL,HL                  ; $41DC  [29]  × 4
    ADD HL,HL                  ; $41DD  [29]  × 8
    LD A,L                     ; $41DE  [7D]
    ADD A,$FD                  ; $41DF  [C6 FD]
    LD L,A                     ; $41E1  [6F]
    LD A,H                     ; $41E2  [7C]
    ADC A,$62                  ; $41E3  [CE 62]
    LD H,A                     ; $41E5  [67]  HL = $62FD + wScrollIdx × 8
    LD A,($C81F)               ; $41E6  [FA 1F C8]  wTileType = destination slot in wBGPalBuf
    LD C,A                     ; $41E9  [4F]
    LD B,$01                   ; $41EA  [06 01]  1×8 = 8 bytes
    CALL $46A1                 ; $41EC  [CD A1 46]  → wBGPalBuf[wTileType × 8]
    CALL $4102                 ; $41EF  [CD 02 41]  → Bank23_Fn9
    ; fall through into Bank23_Fn7

; ============================================================================
; Bank23_Fn7  ($41F2)  — VRAM 6×6 tile grid writer
; ============================================================================
; Writes a 6-column × 6-row grid of tile ID wTileType to VRAM tilemap
; $9800/$9BFF using VRAM bank 1 (tile attributes).
;
; VRAM address calculation:
;   hScrollY & $F8          → pixel row rounded to tile boundary
;   (hScrollY & $F8) × 4   → byte offset in tilemap (row × 32 bytes)
;   H = $98 + overflow bits → $9800 range
;   (hScrollX >> 3) & $1F  → tile column (0–31)
;   HL += (C821 & $E0)      → row-align offset from wScrollYOff
;   RES 2,H                 → keep within $9800–$9BFF (tilemap 0)
;   Pre-advance HL by (C820 & $1F) columns via Sub_4265
;
; For each of 6 rows × 6 columns:
;   CALL $1E80 (ROM0 VRAM tile write, A=tile ID)
;   CALL Sub_4265 (advance HL to next column, wrapping within row)
; After each row: HL += $20 (32 bytes = next row), H &= $03 | $98.
Bank23_Fn7:                                 ; $41F2
    LD A,($C81D)               ; $41F2  [FA 1D C8]
    OR A                       ; $41F5  [B7]
    RET Z                      ; $41F6  [C8]
    LDH A,($BB)                ; $41F7  [F0 BB]  hScrollY
    AND $F8                    ; $41F9  [E6 F8]  align to 8-pixel tile boundary
    LD L,A                     ; $41FB  [6F]
    XOR A                      ; $41FC  [AF]
    SLA L                      ; $41FD  [CB 25]
    RLA                        ; $41FF  [17]
    SLA L                      ; $4200  [CB 25]
    RLA                        ; $4202  [17]  HL = (hScrollY / 8) × 32 (tilemap row offset)
    LD H,$98                   ; $4203  [26 98]
    ADD A,H                    ; $4205  [84]
    LD H,A                     ; $4206  [67]  H = $98 + carry = $9800 range
    LDH A,($B7)                ; $4207  [F0 B7]  hScrollX
    RRCA                       ; $4209  [0F]
    RRCA                       ; $420A  [0F]
    RRCA                       ; $420B  [0F]
    AND $1F                    ; $420C  [E6 1F]  tile column = hScrollX / 8
    ADD A,L                    ; $420E  [85]
    LD L,A                     ; $420F  [6F]
    LD A,$00                   ; $4210  [3E 00]
    ADC A,H                    ; $4212  [8C]
    LD H,A                     ; $4213  [67]  HL = VRAM addr for (col, row)
    LD A,($C820)               ; $4214  [FA 20 C8]  wScrollXOff
    LD C,A                     ; $4217  [4F]
    LD A,($C821)               ; $4218  [FA 21 C8]  wScrollYOff
    LD B,A                     ; $421B  [47]
    LD A,C                     ; $421C  [79]
    AND $E0                    ; $421D  [E6 E0]  extract row-alignment bits
    LD C,A                     ; $421F  [4F]
    ADD HL,BC                  ; $4220  [09]  apply row offset
    RES 2,H                    ; $4221  [CB 94]  keep in $9800–$9BFF
    LD A,($C820)               ; $4223  [FA 20 C8]
    AND $1F                    ; $4226  [E6 1F]  column advance count
    LD B,A                     ; $4228  [47]
    ; pre-advance HL by B columns
    CALL $4265                 ; $4229  [CD 65 42]
    DEC B                      ; $422C  [05]
    JR NZ,$4229                ; $422D  [20 FA]
    ; enable VRAM bank 1 for tile attribute writes
    DI                         ; $422F  [F3]
    CALL $1E79                 ; $4230  [CD 79 1E]
    LD A,$01                   ; $4233  [3E 01]
    LDH ($4F),A                ; $4235  [E0 4F]  rVBK = 1
    EI                         ; $4237  [FB]
    LD C,$06                   ; $4238  [0E 06]  6 rows
    LD B,$06                   ; $423A  [06 06]  6 columns per row
    ; 6×6 write loop
    PUSH HL                    ; $423C  [E5]
    LD A,($C81F)               ; $423D  [FA 1F C8]  wTileType = tile ID
    CALL $1E80                 ; $4240  [CD 80 1E]  write tile to VRAM (HL)
    CALL $4265                 ; $4243  [CD 65 42]  advance HL to next column
    DEC B                      ; $4246  [05]
    JR NZ,$423D                ; $4247  [20 F4]  next column
    POP HL                     ; $4249  [E1]
    LD A,L                     ; $424A  [7D]
    ADD A,$20                  ; $424B  [C6 20]  next tilemap row (+32 bytes)
    LD L,A                     ; $424D  [6F]
    LD A,H                     ; $424E  [7C]
    ADC A,$00                  ; $424F  [CE 00]
    LD H,A                     ; $4251  [67]
    LD A,H                     ; $4252  [7C]
    AND $03                    ; $4253  [E6 03]
    OR $98                     ; $4255  [F6 98]
    LD H,A                     ; $4257  [67]  keep H in $9800–$9BFF range
    DEC C                      ; $4258  [0D]
    JR NZ,$423A                ; $4259  [20 DF]  next row
    ; restore VRAM bank 0
    DI                         ; $425B  [F3]
    CALL $1E79                 ; $425C  [CD 79 1E]
    LD A,$00                   ; $425F  [3E 00]
    LDH ($4F),A                ; $4261  [E0 4F]  rVBK = 0
    EI                         ; $4263  [FB]
    RET                        ; $4264  [C9]

; ============================================================================
; Bank23_Sub_4265  — Tilemap column stepper
; ============================================================================
; Increments HL's column (bits[4:0] of L) within its current row
; (bits[7:5] of L preserved), wrapping from column $1F back to $00.
; Used by fn7 to advance through the 32-column tilemap without crossing rows.
Bank23_Sub_4265:                            ; $4265
    LD A,L                     ; $4265  [7D]
    AND $E0                    ; $4266  [E6 E0]  save row base bits[7:5]
    PUSH AF                    ; $4268  [F5]
    LD A,L                     ; $4269  [7D]
    INC A                      ; $426A  [3C]
    AND $1F                    ; $426B  [E6 1F]  column = (col + 1) & $1F
    LD L,A                     ; $426D  [6F]
    POP AF                     ; $426E  [F1]
    OR L                       ; $426F  [B5]  merge row base with new column
    LD L,A                     ; $4270  [6F]
    RET                        ; $4271  [C9]

; ============================================================================
; HOW PALETTE DATA REACHES THE PPU  (CGB palette-RAM write mechanism)
; ============================================================================
; The GBC's real palette memory (8 BG palettes + 8 OBJ palettes = 64 + 64
; bytes) lives INSIDE the PPU. It is NOT part of the CPU address space — you
; cannot LD it directly, and the PPU never reads ROM/WRAM for colors. The only
; way in is a two-register "porthole" per palette type:
;
;   rBCPS $FF68 / rOCPS $FF6A  — SPECIFICATION (index) register:
;       bit7 = auto-increment (advance index after each data write)
;       bits5-0 = index 0..63 into the PPU's internal palette RAM
;   rBCPD $FF69 / rOCPD $FF6B  — DATA register: the actual color byte goes here;
;       it lands at palette-RAM[index], then index auto-increments if bit7 set.
;
; Write protocol (used by fn3 and the full-flush fn8):
;   1. LD A,$80 ; LDH ($68),A   ; rBCPS = index 0 + auto-increment ON
;   2. stream the color bytes:  LD A,(HL+) ; LDH ($69),A   (repeat)
;      Each byte written to rBCPD fills palette-RAM 0,1,2,... automatically.
;      64 bytes = all 8 BG palettes (each = 4 colors x 2-byte RGB555, LE).
;
; DATA FLOW (source of the colors -> what the PPU actually sees):
;   [ROM]  bank8 wPaletteColorTable $447E   (256 archived RGB555 records)
;      | CPU: bank8 fn2 copies the selected records
;   [WRAM] shadow buffers wBGPalBuf $C797 / wOBJPalBuf $C7D7  (plain RAM copy)
;      | CPU: THIS bank (fn3 per-frame / fn8 full flush) streams via BCPS+BCPD
;   [PPU]  internal palette RAM  <-- the ONLY palette memory the PPU reads
;      | PPU, per pixel: tile 2bpp index (0..3) -> palette-RAM -> on-screen color
;
; The WRAM shadow exists because writing rBCPD is only safe during HBlank/VBlank
; (the PPU is otherwise reading palette RAM). Game code builds palettes freely in
; WRAM anytime; these routines do the timing-critical port writes in the safe
; window (each color write is preceded by CALL $1E79, the safe-window wait).
; Note: rBCPS holds a 0..63 INDEX, not a WRAM address; the only WRAM address in
; the loop is HL (=$C797/$C7D7), the source the CPU reads color bytes from.
; ============================================================================

; ============================================================================
; Bank23_Fn3  ($4272)  — Per-frame BG + OBJ palette scroll
; ============================================================================
; BG palette update:
;   If wBGPalScrollCtr ($C89B) == wBGPalScrollLast ($C89E) → skip, go to OBJ.
;   Otherwise: open rBCPS ($FF68=$80, auto-increment from index 0).
;   Call Sub_42AC 8 times with HL starting at $C797, advancing by 8 each call.
;   Save $C89E = $C89B.
;
; OBJ palette update ($4341):
;   If wOBJPalScrollCtr ($C89C) == wOBJPalScrollLast ($C89F) → JP $440B (RET).
;   Otherwise: open rOCPS ($FF6A=$80).
;   Call Sub_4376 8 times with HL starting at $C7D7.
;   Save $C89F = $C89C.  JP $440B (RET).
;
; Sub_42AC ($42AC) — one BG palette entry (8 bytes at HL → 4 colors to $FF69):
;   The scroll counter $C89B encodes 4 × 2-bit sub-step fields (bits[1:0],
;   bits[3:2], bits[5:4], bits[7:6]).  Each field selects one entry from the
;   $440C table [2,4,0,6], giving a byte offset into the current 8-byte palette
;   record.  For each of the 4 fields: PUSH HL, add offset, wait VBlank,
;   write 2 bytes (HL+, HL) to rBCPD ($FF69), POP HL.
;   On return: L += 8 (advance to next palette entry).
;
; Sub_4376 ($4376) — identical but reads $C89C, writes to rOCPD ($FF6B).
;
; The $440C offset table [2,4,0,6] maps counter bits to color slot:
;   bits[1:0]: offset 2 → color 1
;   bits[3:2]: offset 4 → color 2
;   bits[5:4]: offset 0 → color 0
;   bits[7:6]: offset 6 → color 3
; This reorders the 4 colors per palette entry during scroll animation,
; creating a cycling effect as the scroll counter increments each frame.
Bank23_Fn3:                                 ; $4272
    LD A,($C81D)               ; $4272  [FA 1D C8]
    OR A                       ; $4275  [B7]
    RET Z                      ; $4276  [C8]
    LD HL,$C89E                ; $4277  [21 9E C8]  last-seen BG scroll counter
    LD A,($C89B)               ; $427A  [FA 9B C8]  current BG scroll counter
    CP (HL)                    ; $427D  [BE]
    JP Z,$4341                 ; $427E  [CA 41 43]  unchanged → skip to OBJ path
    CALL $1E79                 ; $4281  [CD 79 1E]
    LD A,$80                   ; $4284  [3E 80]
    LDH ($68),A                ; $4286  [E0 68]  rBCPS = $80: point PPU palette-RAM at
                                            ;   index 0, auto-increment ON (I/O reg,
                                            ;   NOT wram; value is a 0-63 index)
    LD HL,$C797                ; $4288  [21 97 C7]  HL = WRAM src buffer (the only wram addr)
    CALL $42AC                 ; $428B  [CD AC 42]  write palette entry 0 (4 colors)
    CALL $42AC                 ; $428E  [CD AC 42]  entry 1
    CALL $42AC                 ; $4291  [CD AC 42]  entry 2
    CALL $42AC                 ; $4294  [CD AC 42]  entry 3
    CALL $42AC                 ; $4297  [CD AC 42]  entry 4
    CALL $42AC                 ; $429A  [CD AC 42]  entry 5
    CALL $42AC                 ; $429D  [CD AC 42]  entry 6
    CALL $42AC                 ; $42A0  [CD AC 42]  entry 7 (HL ends at $C7D7)
    LD A,($C89B)               ; $42A3  [FA 9B C8]
    LD ($C89E),A               ; $42A6  [EA 9E C8]  save BG counter as last-seen
    JP $4341                   ; $42A9  [C3 41 43]  → OBJ palette path

; --- $4341: OBJ palette path (jumped from both BG-updated and BG-skip paths) ---
;   LD HL,$C89F
;   LD A,($C89C)    ; OBJ scroll counter
;   CP (HL)
;   JP Z,$440B      ; unchanged → RET
;   CALL $1E79
;   LD A,$80
;   LDH ($6A),A     ; rOCPS = $80
;   LD HL,$C7D7     ; OBJ palette buffer
;   CALL $4376 × 8
;   LD A,($C89C)
;   LD ($C89F),A    ; save OBJ counter
;   JP $440B        ; → RET

; --- Sub_42AC ($42AC): BG palette entry writer ---
; Writes 4 × 2-byte colors from wBGPalBuf entry at HL to rBCPD, then HL += 8.
Bank23_Sub_42AC:                            ; $42AC
    ; --- pass 1: bits[1:0] of $C89B → offset index 0 ---
    PUSH HL                    ; $42AC  [E5]
    LD A,($C89B)               ; $42AD  [FA 9B C8]
    AND $03                    ; $42B0  [E6 03]  bits[1:0]
    LD DE,$440C                ; $42B2  [11 0C 44]
    ADD A,E                    ; $42B5  [83]
    LD E,A                     ; $42B6  [5F]
    LD A,$00                   ; $42B7  [3E 00]
    ADC A,D                    ; $42B9  [8A]
    LD D,A                     ; $42BA  [57]
    LD A,(DE)                  ; $42BB  [1A]  offset ∈ {2,4,0,6}
    ADD A,L                    ; $42BC  [85]
    LD L,A                     ; $42BD  [6F]
    LD A,$00                   ; $42BE  [3E 00]
    ADC A,H                    ; $42C0  [8C]
    LD H,A                     ; $42C1  [67]  HL = entry base + offset
    CALL $1E79                 ; $42C2  [CD 79 1E]
    LD A,(HL+)                 ; $42C5  [2A]
    LDH ($69),A                ; $42C6  [E0 69]  rBCPD: color lo -> PPU palette RAM (idx++)
    LD A,(HL)                  ; $42C8  [7E]
    LDH ($69),A                ; $42C9  [E0 69]  rBCPD: color hi -> PPU palette RAM (idx++)
    POP HL                     ; $42CB  [E1]
    ; --- pass 2: bits[3:2] (SRL×2 AND $03) ---
    PUSH HL                    ; $42CC  [E5]
    LD A,($C89B)               ; $42CD  [FA 9B C8]
    SRL A                      ; $42D0  [CB 3F]
    SRL A                      ; $42D2  [CB 3F]
    AND $03                    ; $42D4  [E6 03]
    LD DE,$440C                ; $42D6  [11 0C 44]
    ADD A,E                    ; $42D9  [83]
    LD E,A                     ; $42DA  [5F]
    LD A,$00                   ; $42DB  [3E 00]
    ADC A,D                    ; $42DD  [8A]
    LD D,A                     ; $42DE  [57]
    LD A,(DE)                  ; $42DF  [1A]
    ADD A,L                    ; $42E0  [85]
    LD L,A                     ; $42E1  [6F]
    LD A,$00                   ; $42E2  [3E 00]
    ADC A,H                    ; $42E4  [8C]
    LD H,A                     ; $42E5  [67]
    CALL $1E79                 ; $42E6  [CD 79 1E]
    LD A,(HL+)                 ; $42E9  [2A]
    LDH ($69),A                ; $42EA  [E0 69]
    LD A,(HL)                  ; $42EC  [7E]
    LDH ($69),A                ; $42ED  [E0 69]
    POP HL                     ; $42EF  [E1]
    ; --- pass 3: bits[5:4] (SWAP AND $03) ---
    PUSH HL                    ; $42F0  [E5]
    LD A,($C89B)               ; $42F1  [FA 9B C8]
    SWAP A                     ; $42F4  [CB 37]
    AND $03                    ; $42F6  [E6 03]
    LD DE,$440C                ; $42F8  [11 0C 44]
    ADD A,E                    ; $42FB  [83]
    LD E,A                     ; $42FC  [5F]
    LD A,$00                   ; $42FD  [3E 00]
    ADC A,D                    ; $42FF  [8A]
    LD D,A                     ; $4300  [57]
    LD A,(DE)                  ; $4301  [1A]
    ADD A,L                    ; $4302  [85]
    LD L,A                     ; $4303  [6F]
    LD A,$00                   ; $4304  [3E 00]
    ADC A,H                    ; $4306  [8C]
    LD H,A                     ; $4307  [67]
    CALL $1E79                 ; $4308  [CD 79 1E]
    LD A,(HL+)                 ; $430B  [2A]
    LDH ($69),A                ; $430C  [E0 69]
    LD A,(HL)                  ; $430E  [7E]
    LDH ($69),A                ; $430F  [E0 69]
    POP HL                     ; $4311  [E1]
    ; --- pass 4: bits[7:6] (SWAP SRL×2 AND $03) ---
    PUSH HL                    ; $4312  [E5]
    LD A,($C89B)               ; $4313  [FA 9B C8]
    SWAP A                     ; $4316  [CB 37]
    SRL A                      ; $4318  [CB 3F]
    SRL A                      ; $431A  [CB 3F]
    AND $03                    ; $431C  [E6 03]
    LD DE,$440C                ; $431E  [11 0C 44]
    ADD A,E                    ; $4321  [83]
    LD E,A                     ; $4322  [5F]
    LD A,$00                   ; $4323  [3E 00]
    ADC A,D                    ; $4325  [8A]
    LD D,A                     ; $4326  [57]
    LD A,(DE)                  ; $4327  [1A]
    ADD A,L                    ; $4328  [85]
    LD L,A                     ; $4329  [6F]
    LD A,$00                   ; $432A  [3E 00]
    ADC A,H                    ; $432C  [8C]
    LD H,A                     ; $432D  [67]
    CALL $1E79                 ; $432E  [CD 79 1E]
    LD A,(HL+)                 ; $4331  [2A]
    LDH ($69),A                ; $4332  [E0 69]
    LD A,(HL)                  ; $4334  [7E]
    LDH ($69),A                ; $4335  [E0 69]
    POP HL                     ; $4337  [E1]
    ; --- advance to next palette entry ---
    LD A,L                     ; $4338  [7D]
    ADD A,$08                  ; $4339  [C6 08]
    LD L,A                     ; $433B  [6F]
    LD A,H                     ; $433C  [7C]
    ADC A,$00                  ; $433D  [CE 00]
    LD H,A                     ; $433F  [67]
    RET                        ; $4340  [C9]

; --- Sub_4376 ($4376): OBJ palette entry writer ---
; Identical to Sub_42AC but reads $C89C and writes to rOCPD ($FF6B).
; (code at $4376–$43FF, same 4-pass structure)

; ============================================================================
; Bank23_Fn4  ($4410)  — Palette fade initializer
; ============================================================================
; Reads wPalFadeCtrl ($C850) and sets up the fade state variables.
;
; bit7 of $C850 = 0 (fade-in):
;   wPalBrightness ($C856) = 0 (start at black)
;   wPalFrameRate / wPalFrameCtr ($C857/$C858) = $C850 >> 2 (step delay)
;   CALL $1FA4 (ROM0: triggers fade-in animation)
;
; bit7 of $C850 = 1 (fade-out):
;   Write 32 all-white entries ($FF, $7F = BGR555 white) to BG hardware
;   ($FF69) and OBJ hardware ($FF6B) — 16 color pairs per palette set.
;   wPalBrightness ($C856) = $20 (start at full bright)
;   wPalFrameRate / wPalFrameCtr = (~$C850) >> 2 (inverted speed)
;   CALL $1FA4
Bank23_Fn4:                                 ; $4410
    LD A,($C850)               ; $4410  [FA 50 C8]  wPalFadeCtrl
    LD B,A                     ; $4413  [47]
    BIT 7,B                    ; $4414  [CB 78]
    JR NZ,$442E                ; $4416  [20 16]  fade-out path
    ; fade-in path
    LD A,$00                   ; $4418  [3E 00]
    LD ($C856),A               ; $441A  [EA 56 C8]  wPalBrightness = 0 (start dark)
    LD A,($C850)               ; $441D  [FA 50 C8]
    SRL A                      ; $4420  [CB 3F]
    SRL A                      ; $4422  [CB 3F]
    LD ($C857),A               ; $4424  [EA 57 C8]  wPalFrameRate = speed
    LD ($C858),A               ; $4427  [EA 58 C8]  wPalFrameCtr = speed
    CALL $1FA4                 ; $442A  [CD A4 1F]
    RET                        ; $442D  [C9]
    ; fade-out path ($442E):
    ;   LD A,$20 → wPalBrightness = $20 (full bright)
    ;   CPL / SRL / SRL → inverted speed
    ;   Write $20 = 32 white color-pairs to rBCPD then rOCPD
    ;   CALL $1FA4
    RET                        ; $442E  [3E 20]

; ============================================================================
; Bank23_Fn5  ($4478)  — Per-frame palette brightness fade
; ============================================================================
; Called every frame while a palette fade is in progress.
; Uses $C856 (brightness 0–$1F), $C857 (step delay reload), $C858 (counter).
;
; bit7 of $C850 = 0 (fade-in, brightness increasing):
;   Decrement $C858; if nonzero → RET (wait for next frame).
;   $C856 += 5, clamp at $1F.
;   CALL $44D8 → writes brightness-clamped BG palette ($C797) to $FF69.
;   Reset $C858 = $C857.
;   If $C856 == $1F → fade complete: $C850 = 0, RET.
;
; bit7 = 1 (fade-out, brightness decreasing):
;   Decrement $C858; if nonzero → RET.
;   $C856 -= 5, clamp at 0.
;   CALL $45BB → writes darkened BG+OBJ palette to $FF68/$69 and $FF6A/$6B.
;   Reset $C858 = $C857.
;   If $C856 == 0 → fade complete: $C850 = 0, RET.
;
; Sub_44D8 / Sub_4552 / Sub_457F (fade-in palette write):
;   For each of 8 BG palette entries at $C797: reads BGR555 color (BC),
;   calls Sub_457F 3 times — each call clamps one 5-bit component to $C856
;   (min of actual component and $C856), then reassembles and writes to $FF69.
;
; Sub_45BB / Sub_4604 / Sub_4635 (fade-out palette write):
;   Same darkening algorithm but writes to both BG ($FF69) and OBJ ($FF6B)
;   from both $C797 and $C7D7.
Bank23_Fn5:                                 ; $4478
    LD A,($C850)               ; $4478  [FA 50 C8]
    BIT 7,A                    ; $447B  [CB 7F]
    JR NZ,$44AA                ; $447D  [20 2B]  fade-out path
    ; fade-in path
    LD A,($C858)               ; $447F  [FA 58 C8]  wPalFrameCtr
    OR A                       ; $4482  [B7]
    JR Z,$448A                 ; $4483  [28 05]  counter reached 0 → step
    DEC A                      ; $4485  [3D]
    LD ($C858),A               ; $4486  [EA 58 C8]  decrement and wait
    RET                        ; $4489  [C9]
    ; $448A: advance brightness step
    LD A,($C856)               ; $448A  [FA 56 C8]
    ADD A,$05                  ; $448D  [C6 05]
    CP $1F                     ; $448F  [FE 1F]
    JR C,$4495                 ; $4491  [38 02]
    LD A,$1F                   ; $4493  [3E 1F]  clamp at maximum
    LD ($C856),A               ; $4495  [EA 56 C8]
    CALL $44D8                 ; $4498  [CD D8 44]  write brightness-modulated BG palette
    LD A,($C857)               ; $449B  [FA 57 C8]
    LD ($C858),A               ; $449E  [EA 58 C8]  reload frame counter
    LD A,($C856)               ; $44A1  [FA 56 C8]
    CP $1F                     ; $44A4  [FE 1F]
    JP Z,$44D3                 ; $44A6  [CA D3 44]  brightness maxed → fade done
    RET                        ; $44A9  [C9]
    ; $44D3: $C850 = 0 (clear fade active), RET

; ============================================================================
; Bank23_Fn8  ($46DD)  — Full BG + OBJ palette hardware flush
; ============================================================================
; Copies wBGPalBuf ($C797, 64 bytes) verbatim to rBCPD ($FF69),
; then wOBJPalBuf ($C7D7, 64 bytes) to rOCPD ($FF6B).
; Waits for VBlank gate ($1E79) before each byte write.
Bank23_Fn8:                                 ; $46DD
    LD A,($C81D)               ; $46DD  [FA 1D C8]
    OR A                       ; $46E0  [B7]
    RET Z                      ; $46E1  [C8]
    DI                         ; $46E2  [F3]
    CALL $1E79                 ; $46E3  [CD 79 1E]
    LD A,$80                   ; $46E6  [3E 80]
    LDH ($68),A                ; $46E8  [E0 68]  rBCPS = $80 (auto-increment, index 0)
    EI                         ; $46EA  [FB]
    LD HL,$C797                ; $46EB  [21 97 C7]  BG palette buffer
    LD B,$40                   ; $46EE  [06 40]  64 bytes
    ; BG loop ($46F0): wait VBlank, write (HL+) → rBCPD, repeat
    DI                         ; $46F0  [F3]
    CALL $1E79                 ; $46F1  [CD 79 1E]
    LD A,(HL+)                 ; $46F4  [2A]
    LDH ($69),A                ; $46F5  [E0 69]  rBCPD
    EI                         ; $46F7  [FB]
    DEC B                      ; $46F8  [05]
    JR NZ,$46F0                ; $46F9  [20 F5]
    DI                         ; $46FB  [F3]
    CALL $1E79                 ; $46FC  [CD 79 1E]
    LD A,$80                   ; $46FF  [3E 80]
    LDH ($6A),A                ; $4701  [E0 6A]  rOCPS = $80
    EI                         ; $4703  [FB]
    LD B,$40                   ; $4704  [06 40]  64 bytes
    ; OBJ loop ($4706): wait VBlank, write (HL+) → rOCPD, repeat
    DI                         ; $4706  [F3]
    CALL $1E79                 ; $4707  [CD 79 1E]
    LD A,(HL+)                 ; $470A  [2A]
    LDH ($6B),A                ; $470B  [E0 6B]  rOCPD
    EI                         ; $470D  [FB]
    DEC B                      ; $470E  [05]
    JR NZ,$4706                ; $470F  [20 F5]
    RET                        ; $4711  [C9]

; ============================================================================
; Bank23_Sub_46A1  ($46A1)  — BG palette buffer writer
; ============================================================================
; Copies B×8 bytes from (HL) to wBGPalBuf ($C797) + C×8.
; Checks wMapEnable at entry (RET Z if 0).
; Used by fn0 (tile data → $C500 indirectly through later steps),
; fn6 (scroll sector palette → one BG slot), fn9 ($5655 → slot 7),
; and fn11 ($69BD table → full 64 bytes).
Bank23_Sub_46A1:                            ; $46A1
    LD A,($C81D)               ; $46A1  [FA 1D C8]
    OR A                       ; $46A4  [B7]
    RET Z                      ; $46A5  [C8]
    LD A,B                     ; $46A6  [78]
    ADD A,A                    ; $46A7  [87]
    ADD A,A                    ; $46A8  [87]
    ADD A,A                    ; $46A9  [87]  B × 8 = byte count
    LD B,A                     ; $46AA  [47]
    LD A,C                     ; $46AB  [79]
    ADD A,A                    ; $46AC  [87]
    ADD A,A                    ; $46AD  [87]
    ADD A,A                    ; $46AE  [87]  C × 8 = dest offset from $C797
    LD DE,$C797                ; $46AF  [11 97 C7]
    ADD A,E                    ; $46B2  [83]
    LD E,A                     ; $46B3  [5F]
    LD A,$00                   ; $46B4  [3E 00]
    ADC A,D                    ; $46B6  [8A]
    LD D,A                     ; $46B7  [57]  DE = $C797 + C×8
    ; copy loop
    LD A,(HL+)                 ; $46B8  [2A]
    LD (DE),A                  ; $46B9  [12]
    INC DE                     ; $46BA  [13]
    DEC B                      ; $46BB  [05]
    JR NZ,$46B8                ; $46BC  [20 FA]
    RET                        ; $46BE  [C9]

; ============================================================================
; Bank23_Sub_46BF  ($46BF)  — OBJ palette buffer writer
; ============================================================================
; Identical to Sub_46A1 but copies to wOBJPalBuf ($C7D7) + C×8.
; Used by fn2 ($5615 → full 64-byte OBJ palette),
; fn12 ($6AFD → OBJ slot 0), fn13 ($6B0D → OBJ slot 0).
Bank23_Sub_46BF:                            ; $46BF
    LD A,($C81D)               ; $46BF  [FA 1D C8]
    OR A                       ; $46C2  [B7]
    RET Z                      ; $46C3  [C8]
    LD A,B                     ; $46C4  [78]
    ADD A,A                    ; $46C5  [87]
    ADD A,A                    ; $46C6  [87]
    ADD A,A                    ; $46C7  [87]
    LD B,A                     ; $46C8  [47]
    LD A,C                     ; $46C9  [79]
    ADD A,A                    ; $46CA  [87]
    ADD A,A                    ; $46CB  [87]
    ADD A,A                    ; $46CC  [87]
    LD DE,$C7D7                ; $46CD  [11 D7 C7]  OBJ palette buffer (differs from Sub_46A1)
    ADD A,E                    ; $46D0  [83]
    LD E,A                     ; $46D1  [5F]
    LD A,$00                   ; $46D2  [3E 00]
    ADC A,D                    ; $46D4  [8A]
    LD D,A                     ; $46D5  [57]
    LD A,(HL+)                 ; $46D6  [2A]
    LD (DE),A                  ; $46D7  [12]
    INC DE                     ; $46D8  [13]
    DEC B                      ; $46D9  [05]
    JR NZ,$46D6                ; $46DA  [20 FA]
    RET                        ; $46DC  [C9]

; ============================================================================
; Bank23_Fn11  ($4712)  — Load full BG palette from ROM $69BD table
; ============================================================================
; Loads 64-byte BG palette set for wScrollIdx from ROM table $69BD
; into all of wBGPalBuf ($C797, 64 bytes via Sub_46A1, C=0, B=8).
Bank23_Fn11:                                ; $4712
    LD A,($C81D)               ; $4712  [FA 1D C8]
    OR A                       ; $4715  [B7]
    RET Z                      ; $4716  [C8]
    LD A,($C81E)               ; $4717  [FA 1E C8]  wScrollIdx
    LD L,A                     ; $471A  [6F]
    LD H,$00                   ; $471B  [26 00]
    ADD HL,HL                  ; $471D  [29]  × 2
    ADD HL,HL                  ; $471E  [29]  × 4
    ADD HL,HL                  ; $471F  [29]  × 8
    ADD HL,HL                  ; $4720  [29]  × 16
    ADD HL,HL                  ; $4721  [29]  × 32
    ADD HL,HL                  ; $4722  [29]  × 64
    LD A,L                     ; $4723  [7D]
    ADD A,$BD                  ; $4724  [C6 BD]
    LD L,A                     ; $4726  [6F]
    LD A,H                     ; $4727  [7C]
    ADC A,$69                  ; $4728  [CE 69]
    LD H,A                     ; $472A  [67]  HL = $69BD + wScrollIdx × 64
    LD C,$00                   ; $472B  [0E 00]
    LD B,$08                   ; $472D  [06 08]  8×8 = 64 bytes
    CALL $46A1                 ; $472F  [CD A1 46]  → wBGPalBuf
    RET                        ; $4732  [C9]

; ============================================================================
; Bank23_Fn12  ($4733)  — Load OBJ palette slot 0 from ROM $6AFD table
; ============================================================================
; Loads 8 bytes for wScrollIdx from ROM $6AFD into wOBJPalBuf slot 0
; (via Sub_46BF, C=0, B=1).
Bank23_Fn12:                                ; $4733
    LD A,($C81D)               ; $4733  [FA 1D C8]
    OR A                       ; $4736  [B7]
    RET Z                      ; $4737  [C8]
    LD A,($C81E)               ; $4738  [FA 1E C8]  wScrollIdx
    LD L,A                     ; $473B  [6F]
    LD H,$00                   ; $473C  [26 00]
    ADD HL,HL                  ; $473E  [29]  × 2
    ADD HL,HL                  ; $473F  [29]  × 4
    ADD HL,HL                  ; $4740  [29]  × 8
    LD A,L                     ; $4741  [7D]
    ADD A,$FD                  ; $4742  [C6 FD]
    LD L,A                     ; $4744  [6F]
    LD A,H                     ; $4745  [7C]
    ADC A,$6A                  ; $4746  [CE 6A]
    LD H,A                     ; $4748  [67]  HL = $6AFD + wScrollIdx × 8
    LD C,$00                   ; $4749  [0E 00]
    LD B,$01                   ; $474B  [06 01]  1×8 = 8 bytes
    CALL $46BF                 ; $474D  [CD BF 46]  → wOBJPalBuf slot 0
    RET                        ; $4750  [C9]

; ============================================================================
; Bank23_Fn13  ($4751)  — Load OBJ palette slot 0 from ROM $6B0D table
; ============================================================================
; Same as fn12 but uses ROM table $6B0D instead of $6AFD.
Bank23_Fn13:                                ; $4751
    LD A,($C81D)               ; $4751  [FA 1D C8]
    OR A                       ; $4754  [B7]
    RET Z                      ; $4755  [C8]
    LD A,($C81E)               ; $4756  [FA 1E C8]  wScrollIdx
    LD L,A                     ; $4759  [6F]
    LD H,$00                   ; $475A  [26 00]
    ADD HL,HL                  ; $475C  [29]  × 2
    ADD HL,HL                  ; $475D  [29]  × 4
    ADD HL,HL                  ; $475E  [29]  × 8
    LD A,L                     ; $475F  [7D]
    ADD A,$0D                  ; $4760  [C6 0D]
    LD L,A                     ; $4762  [6F]
    LD A,H                     ; $4763  [7C]
    ADC A,$6B                  ; $4764  [CE 6B]
    LD H,A                     ; $4766  [67]  HL = $6B0D + wScrollIdx × 8
    LD C,$00                   ; $4767  [0E 00]
    LD B,$01                   ; $4769  [06 01]
    CALL $46BF                 ; $476B  [CD BF 46]
    RET                        ; $476E  [C9]

; ============================================================================
; ROM DATA  ($476F onwards)
; ============================================================================
; $440C  4-byte palette sub-step offset table: DB $02,$04,$00,$06
; $476F  Area pointer table (wAreaID → area section table ptrs)
; $51F5  Sub-area name / tile dest ptr table (wAreaID → dest ptr)
; $5215  Sub-area type A tile data table
; $5415  Sub-area type B tile data table
; $5615  Default OBJ palette (64 raw bytes)
; $5655  Default BG palette init record (14 bytes; fn9 uses first 8)
; $62FD  Scroll sector BG palette (8 bytes × sectors)
; $69BD  Full BG palette table (64 bytes × entries)
; $6AFD  OBJ palette table A (8 bytes × entries)
; $6B0D  OBJ palette table B (8 bytes × entries)
