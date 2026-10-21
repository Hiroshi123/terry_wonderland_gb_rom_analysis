; ============================================================
; bank8.asm  —  ROM Bank 8  ($20000-$23FFF)
; SGB initialization packets + GBC palette and VRAM setup
;
; This bank serves three roles during state-0 initialization:
;   1. fn0: sends SGB command packets to the SGB SNES chip via
;      joypad P1 serial bit-banging (16 bytes/packet, LSB first).
;   2. fn1/fn2: initializes GBC hardware palettes by copying
;      palette color records into WRAM for the VBlank writer.
;   3. Data: 21 SGB command packet records, 256 × 8-byte GBC
;      RGB555 palette records, and 13 KB of raw VRAM tile/map data
;      (uploaded to GBC VRAM via GDMA for SGB CHR_TRN / PCT_TRN).
;
; RST $10 dispatch index:
;   fn0 → $4015  Fn0_SgbPacketSender         [CODE]
;   fn1 → $41E3  Fn1_GbcPaletteInit           [CODE]
;   fn2 → $422C  Fn2_PaletteRecordCopy        [CODE]
;   fn3 → $447E  wPaletteColorTable base      [DATA addr]
;   fn4 → $449E  wPaletteColorTable record 4  [DATA addr]
;   fn5 → $44A5  DUNGEON backdrop pt1  (SceneCategory 0, asset $10)  [DATA addr]
;   fn6 → $54A5  DUNGEON backdrop pt2  (cat 0, asset $11)            [DATA addr]
;   fn7 → $64A5  DUNGEON backdrop overlay (cat 0, asset $0F, LZ)     [DATA addr]
;   fn8 → $68DD  category-1 backdrop  (cat 1, asset $10)             [DATA addr]
;   fn9 → $78DD  category-1 backdrop  (cat 1, asset $0F, LZ)         [DATA addr]
;
; Note: fn3-fn9 addresses are never jumped to as code; callers
; read their addresses from this dispatch table as data pointers.
; ============================================================

; ----- Bank ID byte -----
    $4000  DB  $08  ; MBC1 bank register shadow = 8

; ----- RST $10 dispatch table ($4001-$4014, 10 entries × 2 bytes LE) -----
; RST $10 handler (ROM0:$0010) computes HL = $4001 + fn_index*2,
; reads 2-byte LE function address, then JP HL (via RST $08).
    $4001  DW  $4015  ; fn0 → $4015  (Fn0_SgbPacketSender)
    $4003  DW  $41E3  ; fn1 → $41E3  (Fn1_GbcPaletteInit)
    $4005  DW  $422C  ; fn2 → $422C  (Fn2_PaletteRecordCopy)
    $4007  DW  $447E  ; fn3 → $447E  (Fn3_PaletteRecordBase)
    $4009  DW  $449E  ; fn4 → $449E  (Fn4_PaletteRecord4)
    ; Entries 5-9 are NOT functions — they are the source pointers for the
    ; SCENE-BACKGROUND tilesets that SceneCategoryLoad (ROM0 $2058) loads via
    ; Fn_1511/Fn_14B8 (block index E selects the entry: DE=$08nn -> $4001+nn*2).
    $400B  DW  $44A5  ; blk5 → $44A5  DUNGEON bg (cat0 asset $10, raw 4KB→VRAM $8800)
    $400D  DW  $54A5  ; blk6 → $54A5  DUNGEON bg (cat0 asset $11, raw 4KB)
    $400F  DW  $64A5  ; blk7 → $64A5  DUNGEON bg (cat0 asset $0F, LZ overlay)
    $4011  DW  $68DD  ; blk8 → $68DD  cat1 bg (asset $10, raw 4KB)
    $4013  DW  $78DD  ; blk9 → $78DD  cat1 bg (asset $0F, LZ)

; ============================================================
; Fn0_SgbPacketSender  ($4015-$4068)
; Called via:  LD HL,$0800 ; RST $10  from any bank
;
; Sends one SGB command packet via joypad P1 serial bit-bang.
; The game is also SGB-compatible (ROM header flag $03 at $0146).
;
; Entry state:
;   wCurrentAssetIndex ($C774):
;     $FF → HL = wAssetSlot ($C777) directly (caller manages ptr).
;     0-20 → look up wAssetPtrTable[$4069 + index*2].
;
; SGB joypad packet protocol:
;   Each packet = 128 bits = 16 bytes, sent LSB-first per byte.
;   Bit value 1 → select D-Pad row ($10), bit 0 → Button row ($20).
;   After each bit: strobe by writing $30 (deselect all).
;   First byte of each record: (sgb_cmd << 3) | packet_count.
; ============================================================

Fn0_SgbPacketSender:
  ; Guard: skip if initialization not complete
    $4015  FA 1C C8      LD A,($C81C)  ; wInitDone
    $4018  B7            OR A
    $4019  C8            RET Z

  ; If wCurrentAssetIndex == $FF, caller provided pointer in wAssetSlot
    $401A  FA 74 C7      LD A,($C774)  ; wCurrentAssetIndex
    $401D  FE FF         CP $FF
    $401F  20 05         JR NZ,$4026
  ; wCurrentAssetIndex == $FF: use wAssetSlot as HL (caller-managed ptr)
    $4021  21 77 C7      LD HL,$C777  ; wAssetSlot
    $4024  18 0D         JR $4033

  ; Normal path: HL = *wAssetPtrTable[wCurrentAssetIndex]
.IndexedLookup:
    $4026  6F            LD L,A
    $4027  26 00         LD H,$00
    $4029  29            ADD HL,HL
    $402A  11 69 40      LD DE,$4069
    $402D  19            ADD HL,DE
    $402E  5E            LD E,(HL)
    $402F  23            INC HL
    $4030  56            LD D,(HL)
    $4031  D5            PUSH DE
    $4032  E1            POP HL

  ; Read control byte: bits[2:0] = packet count (1-7)
.ReadControlByte:
    $4033  7E            LD A,(HL)
    $4034  E6 07         AND $07
    $4036  C8            RET Z
    $4037  47            LD B,A
    $4038  0E 00         LD C,$00

  ; Outer loop: send one 16-byte packet per iteration
.NextPacket:
    $403A  C5            PUSH BC
  ; Assert SGB start pulse: write $00 then $30 to P1 ($FF00)
    $403B  3E 00         LD A,$00
    $403D  E2            LD ($FF00+C),A
    $403E  3E 30         LD A,$30
    $4040  E2            LD ($FF00+C),A
    $4041  06 10         LD B,$10

  ; Inner byte loop: read next byte, send all 8 bits LSB-first
.NextByte:
    $4043  1E 08         LD E,$08
.NextBit:
    $4045  2A            LD A,(HL+)
    $4046  57            LD D,A
  ; Encode bit: 1 → select D-Pad ($10), 0 → select Buttons ($20)
    $4047  CB 42         BIT 0,D
    $4049  3E 10         LD A,$10
    $404B  20 02         JR NZ,$404F
    $404D  3E 20         LD A,$20
.WriteBit:
    $404F  E2            LD ($FF00+C),A
    $4050  3E 30         LD A,$30
    $4052  E2            LD ($FF00+C),A
    $4053  CB 1A         RR D
    $4055  1D            DEC E
    $4056  20 EF         JR NZ,$4047
    $4058  05            DEC B
    $4059  20 E8         JR NZ,$4043

  ; End-of-packet deselect strobe
    $405B  3E 20         LD A,$20
    $405D  E2            LD ($FF00+C),A
    $405E  3E 30         LD A,$30
    $4060  E2            LD ($FF00+C),A

  ; If more packets: wait one frame then send next
    $4061  C1            POP BC
    $4062  05            DEC B
    $4063  C8            RET Z
    $4064  CD E6 13      CALL $13E6
    $4067  18 D1         JR $403A

; ============================================================
; wAssetPtrTable  ($4069-$4092, 21 entries × 2 bytes LE)
; Each entry = 16-bit pointer to an SGB packet record below.
; Index selected by wCurrentAssetIndex ($C774).
; Records are stored contiguously from $4093 in address order,
; which differs from index order (see asset index comments).
; ============================================================

wAssetPtrTable:
    $4069  DW  $4113  ; [ 0] → $4113: SGB ATTR_SET (cmd=$17) × 1 pkt
    $406B  DW  $4123  ; [ 1] → $4123: SGB ATTR_SET (cmd=$17) × 1 pkt
    $406D  DW  $4093  ; [ 2] → $4093: SGB ICON_EN (cmd=$0F) × 1 pkt
    $406F  DW  $40A3  ; [ 3] → $40A3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $4071  DW  $40B3  ; [ 4] → $40B3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $4073  DW  $40C3  ; [ 5] → $40C3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $4075  DW  $40D3  ; [ 6] → $40D3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $4077  DW  $40E3  ; [ 7] → $40E3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $4079  DW  $40F3  ; [ 8] → $40F3: SGB ICON_EN (cmd=$0F) × 1 pkt
    $407B  DW  $4103  ; [ 9] → $4103: SGB ICON_EN (cmd=$0F) × 1 pkt
    $407D  DW  $4133  ; [10] → $4133: SGB DATA_TRN (cmd=$11) × 1 pkt
    $407F  DW  $4143  ; [11] → $4143: SGB DATA_TRN (cmd=$11) × 1 pkt
    $4081  DW  $4153  ; [12] → $4153: SGB PAL_SET (cmd=$0B) × 1 pkt
    $4083  DW  $4163  ; [13] → $4163: SGB PCT_TRN (cmd=$15) × 1 pkt
    $4085  DW  $4173  ; [14] → $4173: SGB SOU_TRN (cmd=$0A) × 1 pkt
    $4087  DW  $4183  ; [15] → $4183: SGB CHR_TRN (cmd=$14) × 1 pkt
    $4089  DW  $4193  ; [16] → $4193: SGB JUMP (cmd=$13) × 1 pkt
    $408B  DW  $41A3  ; [17] → $41A3: SGB JUMP (cmd=$13) × 1 pkt
    $408D  DW  $41B3  ; [18] → $41B3: SGB OBJ_TRN (cmd=$19) × 1 pkt
    $408F  DW  $41C3  ; [19] → $41C3: SGB TEST_EN (cmd=$0E) × 1 pkt
    $4091  DW  $41D3  ; [20] → $41D3: SGB ATTR_SET (cmd=$17) × 1 pkt

; ============================================================
; SGB Packet Records  ($4093-$41E2)
; Laid out by address (not by asset index).
; Each record: (sgb_cmd<<3)|pkt_count, then 15 payload bytes,
;   repeated for each additional packet.
; SGB commands: see Game Boy Programming Manual §5.
; ============================================================

; -- Asset[ 2] @ $4093: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset02:
    $4093  DB  79 5D 08 00 0B 8C D0 F4 60 00 00 00 00 00 00 00

; -- Asset[ 3] @ $40A3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset03:
    $40A3  DB  79 52 08 00 0B A9 E7 9F 01 C0 7E E8 E8 E8 E8 E0

; -- Asset[ 4] @ $40B3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset04:
    $40B3  DB  79 47 08 00 0B C4 D0 16 A5 CB C9 05 D0 10 A2 28

; -- Asset[ 5] @ $40C3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset05:
    $40C3  DB  79 3C 08 00 0B F0 12 A5 C9 C9 C8 D0 1C A5 CA C9

; -- Asset[ 6] @ $40D3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset06:
    $40D3  DB  79 31 08 00 0B 0C A5 CA C9 7E D0 06 A5 CB C9 7E

; -- Asset[ 7] @ $40E3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset07:
    $40E3  DB  79 26 08 00 0B 39 CD 48 0C D0 34 A5 C9 C9 80 D0

; -- Asset[ 8] @ $40F3: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset08:
    $40F3  DB  79 1B 08 00 0B EA EA EA EA EA A9 01 CD 4F 0C D0

; -- Asset[ 9] @ $4103: SGB ICON_EN (cmd=$0F), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset09:
    $4103  DB  79 10 08 00 0B 4C 20 08 EA EA EA EA EA 60 EA EA

; -- Asset[ 0] @ $4113: SGB ATTR_SET (cmd=$17), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset00:
    $4113  DB  B9 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[ 1] @ $4123: SGB ATTR_SET (cmd=$17), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset01:
    $4123  DB  B9 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[10] @ $4133: SGB DATA_TRN (cmd=$11), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset10:
    $4133  DB  89 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[11] @ $4143: SGB DATA_TRN (cmd=$11), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset11:
    $4143  DB  89 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[12] @ $4153: SGB PAL_SET (cmd=$0B), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset12:
    $4153  DB  59 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[13] @ $4163: SGB PCT_TRN (cmd=$15), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset13:
    $4163  DB  A9 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[14] @ $4173: SGB SOU_TRN (cmd=$0A), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset14:
    $4173  DB  51 00 00 01 00 02 00 03 00 C0 00 00 00 00 00 00

; -- Asset[15] @ $4183: SGB CHR_TRN (cmd=$14), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset15:
    $4183  DB  A1 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[16] @ $4193: SGB JUMP (cmd=$13), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset16:
    $4193  DB  99 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[17] @ $41A3: SGB JUMP (cmd=$13), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset17:
    $41A3  DB  99 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[18] @ $41B3: SGB OBJ_TRN (cmd=$19), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset18:
    $41B3  DB  C9 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[19] @ $41C3: SGB TEST_EN (cmd=$0E), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset19:
    $41C3  DB  71 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; -- Asset[20] @ $41D3: SGB ATTR_SET (cmd=$17), 1 pkt × 16 bytes = 16 bytes --
wSgbAsset20:
    $41D3  DB  B9 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; ============================================================
; Fn1_GbcPaletteInit  ($41E3-$422B)
; Called via:  LD HL,$0801 ; RST $10  from any bank
;
; Looks up the current palette-set index $C817 (wUnknown_C817 — NOT wScrollPhase;
; that is $C905, a different 0-4 FSM) in the PaletteIndexTable ($427E) to find 4
; palette record indices (8 bytes total), copies them to both wAssetBuf ($C778)
; and wPaletteBuf ($C85B), then calls Fn2_PaletteRecordCopy to expand those indices
; into GBC RGB555 color data at wPalDst0-wPalDst3 ($C7D7-$C7EF).
; Finishes by sending SGB ATTR_SET packet (asset slot $0800).
; ($C817 is set by bank1 $431D = ROM0[$2EAC], default 0.)
; ============================================================

Fn1_GbcPaletteInit:
  ; Guard: skip if not initialized
    $41E3  FA 1C C8      LD A,($C81C)  ; wInitDone
    $41E6  B7            OR A
    $41E7  C8            RET Z

  ; $158F: ROM0 helper that resets GBC palette hardware state
    $41E8  CD 8F 15      CALL $158F

  ; wAssetSlot = $51 (constant used by RST $10 at end of fn)
    $41EB  3E 51         LD A,$51
    $41ED  EA 77 C7      LD ($C777),A  ; wAssetSlot

  ; Compute: HL = PaletteIndexTable[$427E] + $C817 * 8
    $41F0  FA 17 C8      LD A,($C817)  ; palette-set index (wUnknown_C817, NOT wScrollPhase=$C905)
    $41F3  6F            LD L,A
    $41F4  26 00         LD H,$00
    $41F6  29            ADD HL,HL
    $41F7  29            ADD HL,HL
    $41F8  29            ADD HL,HL
    $41F9  11 7E 42      LD DE,$427E
    $41FC  19            ADD HL,DE

  ; Copy 8 bytes from table entry to both wAssetBuf and wPaletteBuf
    $41FD  11 78 C7      LD DE,$C778  ; wAssetBuf
    $4200  01 5B C8      LD BC,$C85B  ; wPaletteBuf
    $4203  3E 08         LD A,$08
    $4205  EA A0 C0      LD ($C0A0),A  ; wBattleCmd
.CopyPalIdx:
    $4208  2A            LD A,(HL+)
    $4209  12            LD (DE),A
    $420A  02            LD (BC),A
    $420B  13            INC DE
    $420C  03            INC BC
    $420D  FA A0 C0      LD A,($C0A0)  ; wBattleCmd
    $4210  3D            DEC A
    $4211  EA A0 C0      LD ($C0A0),A  ; wBattleCmd
    $4214  20 F2         JR NZ,$4208

  ; Append flag byte: $C818 | $80 → wAssetBuf[8]
    $4216  FA 18 C8      LD A,($C818)  ; $C818 (2nd byte of wUnknown_C817; NOT a scroll var)
    $4219  F6 80         OR $80
    $421B  12            LD (DE),A

  ; Expand palette indices → RGB555 color data (fills $C7D7-$C7EF)
    $421C  CD 2C 42      CALL $422C

  ; Mark asset as done, then send SGB ATTR_SET packet
    $421F  3E FF         LD A,$FF
    $4221  EA 74 C7      LD ($C774),A  ; wCurrentAssetIndex
  ; RST $10: bank=$08, fn=0 → Fn0_SgbPacketSender (sends ATTR_SET)
    $4224  21 00 08      LD HL,$0800
    $4227  D7            RST $10
    $4228  CD E6 13      CALL $13E6
    $422B  C9            RET

; ============================================================
; PALETTE PIPELINE — ROM -> WRAM HALF  (this bank; PPU half is in bank23)
; ============================================================
; This is the FIRST half of getting colors on a GBC screen. The PPU never reads
; this bank: wPaletteColorTable ($447E) is just an ARCHIVE of 256 RGB555 palette
; records sitting in ROM. To make any of them visible, colors must eventually
; land in the PPU's internal palette RAM (see bank23) — and the bridge is WRAM.
;
;   [ROM]  wPaletteColorTable $447E    256 records x 8 bytes (4 x RGB555, LE)
;      | fn2 (below): pick 4 records by index, copy 8 bytes each
;   [WRAM] shadow buffer wBGPalBuf $C7D7...   (a plain RAM copy; PPU can't see it)
;      | bank23 fn3/fn8: stream WRAM -> rBCPS/rBCPD ($FF68/$FF69) in VBlank
;   [PPU]  internal palette RAM  <-- the only palette memory the PPU reads
;
; Record addressing (fn2 .CopyRecord): a palette index N (0..255) becomes the
; ROM address of its record via  N*8 + $447E  (ADD HL,HL x3 = *8, then +$447E).
; So fn2 does NOT talk to hardware at all — it only fills the WRAM shadow. The
; actual write into the PPU (index-then-data through the $FF68/$FF69 ports) is
; done later by bank23; see "HOW PALETTE DATA REACHES THE PPU" there.
; ============================================================
; Fn2_PaletteRecordCopy  ($422C-$427D)
; Called via:  LD HL,$0802 ; RST $10, or directly by Fn1.
;
; Reads 4 palette record indices (16-bit LE) from wPaletteBuf:
;   wPaletteBuf[0:1] → wPalDst0 ($C7D7)  (BG palette slot 0)
;   wPaletteBuf[2:3] → wPalDst1 ($C7DF)  (BG palette slot 1)
;   wPaletteBuf[4:5] → wPalDst2 ($C7E7)  (BG palette slot 2)
;   wPaletteBuf[6:7] → wPalDst3 ($C7EF)  (BG palette slot 3)
; Each index is multiplied by 8 and added to wPaletteColorTable
; ($447E) to get an 8-byte GBC palette record (4 × RGB555 colors).
; ============================================================

Fn2_PaletteRecordCopy:
  ; Guard: skip if not initialized
    $422C  FA 1C C8      LD A,($C81C)  ; wInitDone
    $422F  B7            OR A
    $4230  C8            RET Z

  ; Slot 0: wPaletteBuf[0:1] → wPalDst0
    $4231  FA 5B C8      LD A,($C85B)  ; wPaletteBuf
    $4234  6F            LD L,A
    $4235  FA 5C C8      LD A,($C85C)  ; wPaletteBuf+1
    $4238  67            LD H,A
    $4239  11 D7 C7      LD DE,$C7D7  ; wPalDst0
    $423C  CD 6A 42      CALL $426A

  ; Slot 1: wPaletteBuf[2:3] → wPalDst1
    $423F  11 DF C7      LD DE,$C7DF  ; wPalDst1
    $4242  FA 5D C8      LD A,($C85D)  ; wPaletteBuf+2
    $4245  6F            LD L,A
    $4246  FA 5E C8      LD A,($C85E)  ; wPaletteBuf+3
    $4249  67            LD H,A
    $424A  CD 6A 42      CALL $426A

  ; Slot 2: wPaletteBuf[4:5] → wPalDst2
    $424D  11 E7 C7      LD DE,$C7E7  ; wPalDst2
    $4250  FA 5F C8      LD A,($C85F)  ; wPaletteBuf+4
    $4253  6F            LD L,A
    $4254  FA 60 C8      LD A,($C860)  ; wPaletteBuf+5
    $4257  67            LD H,A
    $4258  CD 6A 42      CALL $426A

  ; Slot 3: wPaletteBuf[6:7] → wPalDst3
    $425B  11 EF C7      LD DE,$C7EF  ; wPalDst3
    $425E  FA 61 C8      LD A,($C861)  ; wPaletteBuf+6
    $4261  6F            LD L,A
    $4262  FA 62 C8      LD A,($C862)  ; wPaletteBuf+7
    $4265  67            LD H,A
    $4266  CD 6A 42      CALL $426A
    $4269  C9            RET

  ; Helper .CopyRecord: copy 8-byte palette record ROM -> WRAM shadow
  ;   In:  HL = palette record index (0-255); becomes ROM addr N*8+$447E below
  ;        DE = WRAM shadow dest (wPalDstN, e.g. $C7D7) — plain RAM, NOT hardware
  ;   Out: 8 bytes copied: 4 × GBC RGB555 colors (little-endian), ROM(HL)->WRAM(DE)
  ;        HL, DE clobbered; BC used as counter
  ;   (No I/O ports touched here; bank23 later streams this WRAM copy to the PPU.)
.CopyRecord:
    $426A  29            ADD HL,HL
    $426B  29            ADD HL,HL
    $426C  29            ADD HL,HL
  ; Add $447E (wPaletteColorTable): L += $7E with carry into H += $44
    $426D  7D            LD A,L
    $426E  C6 7E         ADD A,$7E
    $4270  6F            LD L,A
    $4271  7C            LD A,H
    $4272  CE 44         ADC A,$44
    $4274  67            LD H,A
  ; Copy 8 bytes (= 4 RGB555 colors) from record to destination
    $4275  0E 08         LD C,$08
.CopyByte:
    $4277  2A            LD A,(HL+)
    $4278  12            LD (DE),A
    $4279  13            INC DE
    $427A  0D            DEC C
    $427B  20 FA         JR NZ,$4277
    $427D  C9            RET

; ============================================================
; PaletteIndexTable  ($427E-$447D) — palette-record index groups.
; Each entry = 4 × 16-bit LE palette-record indices. Fn1 reads:
;   base + $C817*8 → 8 bytes → wPaletteBuf.
; The index is $C817 (wUnknown_C817), NOT wScrollPhase ($C905, a 0-4 scroll FSM).
; The table is laid out as a full sequential 64-entry map (entry N → records
; 4N..4N+3), but $C817 defaults to 0 (bank1 $431D = ROM0[$2EAC]) and in practice
; only a LOW entry is used — so only the first few palette records are ever read
; here. Treat the 64-entry span as the table's physical extent, not its live range.
; ============================================================

PaletteIndexTable:
    $427E  DB  00 00 01 00 02 00 03 00  ; phase  0: pal records   0,  1,  2,  3
    $4286  DB  04 00 05 00 06 00 07 00  ; phase  1: pal records   4,  5,  6,  7
    $428E  DB  08 00 09 00 0A 00 0B 00  ; phase  2: pal records   8,  9, 10, 11
    $4296  DB  0C 00 0D 00 0E 00 0F 00  ; phase  3: pal records  12, 13, 14, 15
    $429E  DB  10 00 11 00 12 00 13 00  ; phase  4: pal records  16, 17, 18, 19
    $42A6  DB  14 00 15 00 16 00 17 00  ; phase  5: pal records  20, 21, 22, 23
    $42AE  DB  18 00 19 00 1A 00 1B 00  ; phase  6: pal records  24, 25, 26, 27
    $42B6  DB  1C 00 1D 00 1E 00 1F 00  ; phase  7: pal records  28, 29, 30, 31
    $42BE  DB  20 00 21 00 22 00 23 00  ; phase  8: pal records  32, 33, 34, 35
    $42C6  DB  24 00 25 00 26 00 27 00  ; phase  9: pal records  36, 37, 38, 39
    $42CE  DB  28 00 29 00 2A 00 2B 00  ; phase 10: pal records  40, 41, 42, 43
    $42D6  DB  2C 00 2D 00 2E 00 2F 00  ; phase 11: pal records  44, 45, 46, 47
    $42DE  DB  30 00 31 00 32 00 33 00  ; phase 12: pal records  48, 49, 50, 51
    $42E6  DB  34 00 35 00 36 00 37 00  ; phase 13: pal records  52, 53, 54, 55
    $42EE  DB  38 00 39 00 3A 00 3B 00  ; phase 14: pal records  56, 57, 58, 59
    $42F6  DB  3C 00 3D 00 3E 00 3F 00  ; phase 15: pal records  60, 61, 62, 63
    $42FE  DB  40 00 41 00 42 00 43 00  ; phase 16: pal records  64, 65, 66, 67
    $4306  DB  44 00 45 00 46 00 47 00  ; phase 17: pal records  68, 69, 70, 71
    $430E  DB  48 00 49 00 4A 00 4B 00  ; phase 18: pal records  72, 73, 74, 75
    $4316  DB  4C 00 4D 00 4E 00 4F 00  ; phase 19: pal records  76, 77, 78, 79
    $431E  DB  50 00 51 00 52 00 53 00  ; phase 20: pal records  80, 81, 82, 83
    $4326  DB  54 00 55 00 56 00 57 00  ; phase 21: pal records  84, 85, 86, 87
    $432E  DB  58 00 59 00 5A 00 5B 00  ; phase 22: pal records  88, 89, 90, 91
    $4336  DB  5C 00 5D 00 5E 00 5F 00  ; phase 23: pal records  92, 93, 94, 95
    $433E  DB  60 00 61 00 62 00 63 00  ; phase 24: pal records  96, 97, 98, 99
    $4346  DB  64 00 65 00 66 00 67 00  ; phase 25: pal records 100,101,102,103
    $434E  DB  68 00 69 00 6A 00 6B 00  ; phase 26: pal records 104,105,106,107
    $4356  DB  6C 00 6D 00 6E 00 6F 00  ; phase 27: pal records 108,109,110,111
    $435E  DB  70 00 71 00 72 00 73 00  ; phase 28: pal records 112,113,114,115
    $4366  DB  74 00 75 00 76 00 77 00  ; phase 29: pal records 116,117,118,119
    $436E  DB  78 00 79 00 7A 00 7B 00  ; phase 30: pal records 120,121,122,123
    $4376  DB  7C 00 7D 00 7E 00 7F 00  ; phase 31: pal records 124,125,126,127
    $437E  DB  80 00 81 00 82 00 83 00  ; phase 32: pal records 128,129,130,131
    $4386  DB  84 00 85 00 86 00 87 00  ; phase 33: pal records 132,133,134,135
    $438E  DB  88 00 89 00 8A 00 8B 00  ; phase 34: pal records 136,137,138,139
    $4396  DB  8C 00 8D 00 8E 00 8F 00  ; phase 35: pal records 140,141,142,143
    $439E  DB  90 00 91 00 92 00 93 00  ; phase 36: pal records 144,145,146,147
    $43A6  DB  94 00 95 00 96 00 97 00  ; phase 37: pal records 148,149,150,151
    $43AE  DB  98 00 99 00 9A 00 9B 00  ; phase 38: pal records 152,153,154,155
    $43B6  DB  9C 00 9D 00 9E 00 9F 00  ; phase 39: pal records 156,157,158,159
    $43BE  DB  A0 00 A1 00 A2 00 A3 00  ; phase 40: pal records 160,161,162,163
    $43C6  DB  A4 00 A5 00 A6 00 A7 00  ; phase 41: pal records 164,165,166,167
    $43CE  DB  A8 00 A9 00 AA 00 AB 00  ; phase 42: pal records 168,169,170,171
    $43D6  DB  AC 00 AD 00 AE 00 AF 00  ; phase 43: pal records 172,173,174,175
    $43DE  DB  B0 00 B1 00 B2 00 B3 00  ; phase 44: pal records 176,177,178,179
    $43E6  DB  B4 00 B5 00 B6 00 B7 00  ; phase 45: pal records 180,181,182,183
    $43EE  DB  B8 00 B9 00 BA 00 BB 00  ; phase 46: pal records 184,185,186,187
    $43F6  DB  BC 00 BD 00 BE 00 BF 00  ; phase 47: pal records 188,189,190,191
    $43FE  DB  C0 00 C1 00 C2 00 C3 00  ; phase 48: pal records 192,193,194,195
    $4406  DB  C4 00 C5 00 C6 00 C7 00  ; phase 49: pal records 196,197,198,199
    $440E  DB  C8 00 C9 00 CA 00 CB 00  ; phase 50: pal records 200,201,202,203
    $4416  DB  CC 00 CD 00 CE 00 CF 00  ; phase 51: pal records 204,205,206,207
    $441E  DB  D0 00 D1 00 D2 00 D3 00  ; phase 52: pal records 208,209,210,211
    $4426  DB  D4 00 D5 00 D6 00 D7 00  ; phase 53: pal records 212,213,214,215
    $442E  DB  D8 00 D9 00 DA 00 DB 00  ; phase 54: pal records 216,217,218,219
    $4436  DB  DC 00 DD 00 DE 00 DF 00  ; phase 55: pal records 220,221,222,223
    $443E  DB  E0 00 E1 00 E2 00 E3 00  ; phase 56: pal records 224,225,226,227
    $4446  DB  E4 00 E5 00 E6 00 E7 00  ; phase 57: pal records 228,229,230,231
    $444E  DB  E8 00 E9 00 EA 00 EB 00  ; phase 58: pal records 232,233,234,235
    $4456  DB  EC 00 ED 00 EE 00 EF 00  ; phase 59: pal records 236,237,238,239
    $445E  DB  F0 00 F1 00 F2 00 F3 00  ; phase 60: pal records 240,241,242,243
    $4466  DB  F4 00 F5 00 F6 00 F7 00  ; phase 61: pal records 244,245,246,247
    $446E  DB  F8 00 F9 00 FA 00 FB 00  ; phase 62: pal records 248,249,250,251
    $4476  DB  FC 00 FD 00 FE 00 FF 00  ; phase 63: pal records 252,253,254,255

; ============================================================
; wPaletteColorTable  ($447E-$44A4) — the SMALL GBC RGB555 palette table.
; fn2 reads record N as src=$447E+N*8. Only records 0-4 are real (the palette-
; index $C817 stays low; see PaletteIndexTable). Records 0-3 = the title/boot
; palette; record 4 is 7 bytes here because the next data (tile block 5) starts
; at $44A5, mid-record-4. THIS TABLE ENDS AT $44A4 — $44A5 begins other data.
; ============================================================
wPaletteColorTable:
    $447E  DB  DE 6F 1F 33 3C 12 00 00  ; [0] R30G30B27 R31G24B12 R28G17B04 R00G00B00
    $4486  DB  DE 6F 1F 33 3C 12 00 00  ; [1] R30G30B27 R31G24B12 R28G17B04 R00G00B00
    $448E  DB  DE 6F 1F 33 3C 12 00 00  ; [2] R30G30B27 R31G24B12 R28G17B04 R00G00B00
    $4496  DB  DE 6F 1F 33 3C 12 00 00  ; [3] R30G30B27 R31G24B12 R28G17B04 R00G00B00
    $449E  DB  5A 00 01 01 A0 FF 47  ; [4] (7 bytes; block 5 starts next at $44A5)

; ============================================================
; wVramTileData  ($44A5-$7FFF) — SCENE (cat0/cat1) TILE-DATA BLOCKS.
; Reached only as bank8 $4001 block indices 5-9 (loaded by SceneCategoryLoad
; via Fn_1511 raw / Fn_14B8 LZ into VRAM $8800). NOT palette data, NOT via
; TilesetDirectory. cat0 = DUNGEON file-select backdrop, cat1 = (unconfirmed).
;
; RENDER CHECK (viewing bytes as tiles): the LZ blocks (blk7/blk9) decode to real
; structured tiles; the RAW blocks (blk5/blk6/blk8) render as NOISE in GB 2bpp AND
; SNES 4bpp. And Fn_14B8 CLEARS $8800 before decoding the LZ block (loaded LAST),
; wiping the raw blocks' VRAM. So the LZ block is the graphics actually shown; the
; raw blocks look like SGB-transfer / palette side-effect data, NOT a plain bitmap.
; (So "raw block = 4KB backdrop tileset" is only half-right; treat with caution.)
; ============================================================
Bank8_VramBlk5_DungeonA:  ; $44A5-$54A4  cat0 asset $10 (raw 4KB; renders as noise)
    $44A5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $44B5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $44C5  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $44D5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $44E5  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $44F5  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4505  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4515  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4525  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4535  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4545  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4555  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $4565  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4575  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4585  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $4595  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $45A5  DB  00 00 0F 00 38 00 70 00 70 00 60 00 60 00 30 00
    $45B5  DB  FF FF F0 F0 C7 C1 8F 81 8F 83 9F 83 9F 83 CF C7
    $45C5  DB  07 00 07 00 03 00 01 00 01 00 00 00 00 00 40 00
    $45D5  DB  F8 F8 F8 F8 FC FC FE FE FE FE FF BF FF BF BF 8F
    $45E5  DB  00 00 00 00 00 00 19 00 25 00 24 00 18 00 00 00
    $45F5  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4605  DB  00 00 00 00 C0 00 20 00 24 04 C4 04 0C 0C 3C 0C
    $4615  DB  FF FF FF FF FF FF FF FF FB FF FB FF F3 FF F3 FF
    $4625  DB  00 BF 00 5F 00 1F 00 CF 00 E7 00 F3 00 F1 00 78
    $4635  DB  40 00 A0 00 E0 00 30 00 18 00 0C 00 0E 00 87 00
    $4645  DB  00 FF 00 E7 00 F1 00 FC 00 FF 00 FF 00 FF 00 3F
    $4655  DB  00 00 18 00 0E 00 03 00 00 00 00 00 00 00 C0 00
    $4665  DB  00 FF 00 FF 00 7F 00 3F 00 8F 00 E3 00 FC 00 FF
    $4675  DB  00 00 00 00 80 00 C0 00 70 00 1C 00 03 00 00 00
    $4685  DB  FF 7F FF 7F FF 7F FF 7F FF 7F FF 7F FF 7F FF 7F
    $4695  DB  FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F
    $46A5  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $46B5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $46C5  DB  3F 20 3F 20 3F 20 3F 20 3F 20 3F 20 3F 20 3F 20
    $46D5  DB  E0 DF E0 DF E0 DF E0 DF E0 DF E0 DF E0 DF E0 DF
    $46E5  DB  FF 40 FF 20 FF 10 FF 08 FF 04 FF 02 FF 01 FF 00
    $46F5  DB  C0 7F 60 3F 30 1F 18 0F 0C 07 06 03 03 01 01 00
    $4705  DB  FF 20 FF 08 FF 02 FF 00 FF 00 FF 00 FF 00 FF 00
    $4715  DB  E0 3F 38 0F 0E 03 03 00 00 00 00 00 00 00 00 00
    $4725  DB  FF 00 FF 00 FF 00 FF C0 FF 30 FF 0C FF 03 FF 00
    $4735  DB  00 FF 00 FF 00 FF C0 FF F0 3F 3C 0F 0F 03 03 00
    $4745  DB  00 00 00 00 80 00 70 00 3C 01 1E 01 1C 03 1C 02
    $4755  DB  FF FF FF FF 7F 7F 8F 8F C3 C2 E1 E0 E3 E0 E3 E0
    $4765  DB  00 07 00 1C 00 70 00 C0 00 80 00 00 00 00 00 00
    $4775  DB  FF F8 FF E1 FF 87 FF 0F FF 1F FF 1F FF 3F FF 7F
    $4785  DB  18 00 24 00 24 00 18 00 40 40 60 60 3C 3C 04 00
    $4795  DB  FF FF FF FF FF FF FF FF BF FF 9F FE C3 FC FB F8
    $47A5  DB  30 00 58 00 48 00 30 00 00 00 00 33 00 FC 00 1E
    $47B5  DB  CF C7 E7 E3 F7 F1 FF FF FF 18 FF 00 FF 00 FF 00
    $47C5  DB  60 00 30 00 3C 00 0E 00 0E 00 0F 80 07 C0 C7 00
    $47D5  DB  9F 83 CF C0 C3 C0 F1 F0 F1 F0 F0 10 F8 08 38 08
    $47E5  DB  60 60 3F 33 3F 3B 1F 1F 0F 0F 07 07 00 00 00 00
    $47F5  DB  9F FF CC FF C4 FF E0 FF F0 FF F8 FF FF FF FF FF
    $4805  DB  FC EC FC FC F8 F8 F8 F8 F0 F0 C0 C0 00 00 00 00
    $4815  DB  13 FF 03 FF 07 FF 07 FF 0F FF 3F FF FF FF FF FF
    $4825  DB  00 3C 00 0E 00 07 00 03 00 00 00 00 80 80 3C 3C
    $4835  DB  C3 00 F1 00 F8 00 FC 00 FF 00 FF 00 7F 00 C3 C0
    $4845  DB  00 07 00 00 00 00 00 E0 00 FE 00 7F 00 3F 00 07
    $4855  DB  F8 00 FF 00 FF 00 1F 00 01 00 80 00 C0 00 F8 00
    $4865  DB  00 F8 00 FE 00 3F 00 0F 00 07 00 83 00 E0 00 FD
    $4875  DB  07 00 01 00 C0 00 F0 00 F8 00 7C 00 1F 00 02 00
    $4885  DB  FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F FF 3F
    $4895  DB  FF 1F FF 1F FF 1F FF 1F FF 1F FF 1F FF 1F FF 1F
    $48A5  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $48B5  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $48C5  DB  00 00 00 7B 00 87 00 1F 00 3F 00 FF 00 F8 00 00
    $48D5  DB  FF FC FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 1F
    $48E5  DB  00 40 00 E0 00 F0 00 F0 00 E0 00 80 00 00 00 00
    $48F5  DB  FF 3F FF 0D FF 04 FF 06 FF 0E FF 1F FF 7F FF FF
    $4905  DB  00 00 00 00 F0 00 1C C0 02 30 00 1E 00 07 00 00
    $4915  DB  FF FF FF FF 0F 0F E3 03 FD 01 FF 00 FF C0 FF C0
    $4925  DB  CC 00 6C 00 28 00 38 00 18 00 18 00 38 80 30 80
    $4935  DB  33 30 93 90 D7 D0 C7 C1 E7 E1 E7 E1 C7 43 CF 03
    $4945  DB  00 00 00 00 00 00 00 00 00 00 C0 00 E0 00 C3 07
    $4955  DB  FF FF FF FF FF FF FF FF FF FF 3F 3F 1F 13 3F 00
    $4965  DB  81 80 80 80 60 60 38 38 0F 0F 03 03 00 00 00 00
    $4975  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4985  DB  04 00 00 00 02 00 21 00 B0 00 B8 00 9F 00 DF 00
    $4995  DB  FB F8 FF FC FD FC DE DE 4F 4F 47 47 60 60 20 20
    $49A5  DB  00 03 00 00 00 00 80 00 F6 00 4F 00 0F 00 81 00
    $49B5  DB  FF 00 FF 00 FF 00 7F 00 09 08 B0 B0 F0 F0 7E 7E
    $49C5  DB  62 00 32 80 14 40 18 00 0C 00 CC 00 EC 00 FC 00
    $49D5  DB  9D 05 CD 05 EB 03 E7 07 F3 03 33 03 13 03 03 03
    $49E5  DB  00 FF 00 FF 00 FF 00 FF 00 00 00 80 00 C0 00 FC
    $49F5  DB  00 00 00 00 00 00 00 00 FF 00 7F 00 3F 00 03 00
    $4A05  DB  00 00 00 00 30 00 48 00 48 00 30 00 00 00 00 00
    $4A15  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $4A25  DB  0F 0F 07 07 03 01 00 00 E0 E0 FF FF FF FF 3F 3F
    $4A35  DB  F0 F0 F8 F8 FC FC FF FF 1F 1F 00 00 00 00 C0 00
    $4A45  DB  00 01 E0 E0 F0 F0 FC FC 07 07 FF FF 83 83 FE FE
    $4A55  DB  FE 00 1F 00 0F 00 03 00 F8 F8 00 00 7C 00 01 00
    $4A65  DB  00 FF 00 3F 00 0F 00 00 FC FC C0 FF F0 FF 1C 1F
    $4A75  DB  00 00 C0 00 F0 00 FF 00 03 00 00 00 00 00 E0 00
    $4A85  DB  1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F
    $4A95  DB  FF 0F FF 0F FF 0F FF 0F FF 0F FF 0F FF 0F FF 0F
    $4AA5  DB  00 00 00 00 00 00 00 00 07 00 FF 00 FF 00 FE 00
    $4AB5  DB  FF FF FF FF FF FF FF FF F8 FF 00 FF 00 FF 01 FF
    $4AC5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4AD5  DB  FF FF FF FF FF E7 FF E3 FF E2 FF F1 FF F0 FF F0
    $4AE5  DB  00 00 00 00 00 00 00 00 00 00 00 00 80 80 00 00
    $4AF5  DB  FF 1F FF 1F FF 1F FF 0E FF 06 FF 02 7F 00 FF 00
    $4B05  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4B15  DB  FF 93 FF 93 FF 13 FF 1B FF 0B FF 0B FF 0B FF 06
    $4B25  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4B35  DB  FF FF FF EF FF EF FF 1F FF 1F FF 3F FF 3F FF 3F
    $4B45  DB  87 0F 87 3F 01 7F 00 7F 00 FF 00 FF 00 FF 00 FF
    $4B55  DB  7F 00 7F 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4B65  DB  40 00 C0 81 A7 C7 08 CF 07 D8 2F C0 01 C0 00 40
    $4B75  DB  BF 3F BF 3E DF 18 FF 10 FF 00 DF 00 FF 26 FF 3C
    $4B85  DB  02 01 70 F0 CF FF 01 FF 80 7F FC 03 FF 00 40 00
    $4B95  DB  FF 80 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $4BA5  DB  00 C0 98 78 0C 3C C4 DC FA F6 38 FE CC 3A FB 04
    $4BB5  DB  FF 3F FF 07 FF 03 FF 03 FF 01 FF 01 FF 01 FF 00
    $4BC5  DB  03 FF 01 9F 00 43 00 81 00 E8 00 60 00 B8 80 DC
    $4BD5  DB  00 00 60 00 BC 00 7E 00 17 00 9F 00 47 00 23 00
    $4BE5  DB  CF 00 9F 80 7F C0 3F F0 1F 78 0F 18 07 06 01 11
    $4BF5  DB  00 30 00 60 00 00 00 00 80 00 E0 00 F8 00 EE 00
    $4C05  DB  03 03 03 03 0E 0E F8 F8 00 00 00 00 00 00 00 00
    $4C15  DB  FC FF FC FF F1 FF 07 FF FF FF FF FF FF FF FF FF
    $4C25  DB  00 00 00 00 00 F0 00 FF 00 FF 00 FF 00 3F 00 C7
    $4C35  DB  FF 00 FF 00 0F 00 00 00 00 00 00 00 C0 00 38 00
    $4C45  DB  7F 7F 03 03 00 00 00 80 00 FF 00 FF 00 FF 00 FF
    $4C55  DB  80 00 FC 00 FF 00 7F 00 00 00 00 00 00 00 00 00
    $4C65  DB  F0 F0 FF FF 1E 1F 00 01 00 00 00 FC 00 FF 00 FF
    $4C75  DB  0F 00 00 00 E0 00 FE 00 FF 00 03 00 00 00 00 00
    $4C85  DB  0F 4F 0F 4F 0F 4F 0F 4F 0F 4F 0F 4F 0F 4F 0F 4F
    $4C95  DB  BF 87 BF 87 BF 87 BF 87 BF 87 BF 87 BF 87 BF 87
    $4CA5  DB  F8 00 F0 00 E1 00 E2 00 21 00 04 04 03 03 00 00
    $4CB5  DB  07 FF 0F FF 1F FF 1F FF DF FF FB FF FC FF FF FF
    $4CC5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4CD5  DB  FF F8 FF F8 FF FC FF FC FF FE FF FE FF FF FF FF
    $4CE5  DB  40 40 00 00 00 00 10 10 10 10 08 08 0C 0C 08 08
    $4CF5  DB  BF 01 FF 01 FF 83 EF 81 EF E1 F7 E1 F3 E0 F7 E0
    $4D05  DB  00 00 00 00 00 00 00 00 20 20 20 20 20 20 20 20
    $4D15  DB  FF 86 FF C6 FF C6 FF C6 DF C6 DF C6 DF C6 DF 46
    $4D25  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4D35  DB  FF 5F FF 37 FF 37 FF 37 FF 37 FF 3F FF 7B FF 7B
    $4D45  DB  00 F9 00 F0 00 F0 00 F0 00 F8 00 F0 08 C0 10 81
    $4D55  DB  FF 06 FF 0F FF 0F FF 0F FF 03 FF 07 F7 07 EE 0E
    $4D65  DB  00 00 03 00 00 20 00 20 07 40 08 C0 08 80 08 80
    $4D75  DB  FF 7C FC 7C DF 5F DF DF BF BF 3F 3F 7F 7F 7F 7F
    $4D85  DB  7F 00 80 00 00 00 00 00 0E 00 91 00 91 00 91 00
    $4D95  DB  80 00 7F 7F FF FF FF FF FF FF FF FF FF FF FF FF
    $4DA5  DB  BD 02 DF 00 73 00 1C 00 03 00 00 00 00 00 00 00
    $4DB5  DB  FF 00 3F 00 8F 80 E3 E0 FC FC FF FF FF FF FF FF
    $4DC5  DB  C0 E7 40 7B 60 7D 20 3E 30 3F 7C 1F 7E 07 FF 03
    $4DD5  DB  18 00 04 80 02 80 01 C0 00 C0 00 80 00 80 00 00
    $4DE5  DB  00 08 00 C1 00 F0 00 F8 00 1C 00 CF 00 F1 00 FE
    $4DF5  DB  F7 00 3E 00 0F 00 07 00 E3 00 30 00 0E 00 01 00
    $4E05  DB  00 88 00 F6 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $4E15  DB  77 00 09 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4E25  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 80 FF C0 FF E0
    $4E35  DB  F0 00 F0 00 E6 00 EC 00 F8 00 78 00 38 00 18 00
    $4E45  DB  FE 00 F0 00 E0 00 BF BF FF FF 1F 1F 00 00 00 00
    $4E55  DB  01 01 0F 0F 1F 1F 40 40 00 00 E0 00 FF 00 FF 00
    $4E65  DB  00 00 00 00 00 00 80 80 FF FF FF FF 07 07 00 00
    $4E75  DB  FF FF FF FF FF FF 7F 7F 00 00 00 00 F8 00 FF 00
    $4E85  DB  07 17 07 17 07 17 07 17 07 17 07 17 07 07 07 07
    $4E95  DB  EF E3 EF E3 EF E3 EF E3 EF E3 EF E3 FF F3 FF F3
    $4EA5  DB  00 00 00 00 04 00 7C 00 FE 00 BE 00 9F 00 07 00
    $4EB5  DB  FF FC FF F4 FB FE 83 FC 01 FE 41 FE 60 FF F8 FF
    $4EC5  DB  80 80 80 80 C0 C0 40 40 40 40 40 40 40 40 40 40
    $4ED5  DB  7F 1C 7F 0C 3F 0C BF 0E BF 07 BF 07 BF 03 BF 03
    $4EE5  DB  10 10 08 08 09 09 09 09 08 08 08 08 0C 0C 0C 0C
    $4EF5  DB  EF E8 F7 E0 F6 E0 F6 E0 F7 E1 F7 E1 F3 E0 F3 E0
    $4F05  DB  30 30 10 10 00 00 00 00 00 00 80 80 00 00 80 80
    $4F15  DB  CF 42 EF 23 FF 23 FF 23 FF 03 7F 03 FF 01 7F 00
    $4F25  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $4F35  DB  FF 79 FF 69 FF 21 FF 25 FF A6 FF A6 FF E6 FF E7
    $4F45  DB  00 01 00 0D 00 07 00 03 00 02 00 06 00 04 00 05
    $4F55  DB  FE 3E FE 02 FE 00 FE 38 FF 7C FB 78 FB 60 FA 28
    $4F65  DB  08 80 47 C0 60 60 78 70 7E 70 3F 33 3F 37 1F 1F
    $4F75  DB  7F 7F 3F 7F 9F FF 8F FF 8F FF CC FF C8 FF E0 FF
    $4F85  DB  91 00 0E 00 00 00 00 00 07 04 FF FC FF FE FF FE
    $4F95  DB  FF FF FF FF FF FF FF FF FB FF 03 FF 01 FF 01 FF
    $4FA5  DB  00 00 00 00 40 40 C0 C0 C0 C0 C0 C0 C0 C0 80 80
    $4FB5  DB  FF FF FF FF BF FF 3F FF 3F FF 3F FF 3F FF 7F FF
    $4FC5  DB  FF 01 FD 01 F5 01 D8 00 E8 00 FC 00 F0 00 81 00
    $4FD5  DB  02 00 04 02 04 0A 08 27 08 17 FC 03 F0 0F 80 7E
    $4FE5  DB  00 FF 80 FF C0 EB 00 FF 00 EF 00 04 00 E0 00 FE
    $4FF5  DB  00 00 00 00 14 00 00 00 10 00 FB 00 1F 00 01 00
    $5005  DB  C0 FF F0 7F F8 1F FE 07 FF 03 FF 01 FD 00 FB 00
    $5015  DB  00 00 80 00 A0 00 A0 00 C0 00 C0 00 82 02 84 04
    $5025  DB  3F F0 1F 1C 07 AE 01 D7 00 FF 00 FF 00 FF 00 FF
    $5035  DB  00 00 E0 00 50 00 28 00 00 00 00 00 00 00 00 00
    $5045  DB  FF 00 FF 00 FF 00 FF 83 FF FF 00 F0 00 FE 00 FF
    $5055  DB  00 00 00 00 00 00 00 00 00 00 0F 00 01 00 00 00
    $5065  DB  0B 00 1B 00 03 00 EF 00 CF 00 9E 00 7F 00 4B 00
    $5075  DB  08 F4 18 E4 00 FC 80 50 80 30 00 E1 03 80 43 B4
    $5085  DB  03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
    $5095  DB  FF FD FF FD FF FD FF FD FF FD FF FD FF FD FF FD
    $50A5  DB  01 00 00 00 10 00 A8 00 10 00 04 04 F8 F8 00 00
    $50B5  DB  FE FF FF FF FF FF FF FF FF FF FB FF 07 FF FF FF
    $50C5  DB  A0 A0 E0 60 50 10 50 10 60 20 40 00 E0 00 00 00
    $50D5  DB  5F 07 1F 87 AF C7 AF C3 9F C3 BF E1 1F E1 FF 01
    $50E5  DB  06 06 02 02 03 03 01 01 01 01 01 01 01 01 00 00
    $50F5  DB  F9 E1 FD F0 FC F0 FE F8 FE F8 FE F8 FE F8 FF FC
    $5105  DB  40 40 40 40 40 40 60 60 20 20 20 20 00 00 80 80
    $5115  DB  BF 00 BF 80 BF 80 9F 80 DF D0 DF 58 FF 58 7F 18
    $5125  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $5135  DB  FF E7 FF E3 FF F3 FF D3 FF FB FF F9 FF FD FF 7D
    $5145  DB  00 01 00 0F 00 0F 00 0C 00 08 00 00 00 00 00 00
    $5155  DB  FE 30 F0 10 F3 90 F7 80 F7 C1 FF C5 FF E4 FF E7
    $5165  DB  0F 0F 07 07 01 C1 00 40 00 3E 00 D8 00 F0 FC 00
    $5175  DB  F0 FF F8 FF FE 3F FF 3F E1 81 27 07 0F 0F FF 03
    $5185  DB  FF FF FE FE F0 F0 00 00 00 00 00 00 00 00 00 00
    $5195  DB  00 FF 01 FF 0F FF FF FF FF FF FF FF FF FF FF FF
    $51A5  DB  7E 30 7E 20 FC 40 F8 00 E0 00 80 00 00 00 00 00
    $51B5  DB  FE 81 7E 81 FC 03 F9 07 E7 1F FF 0F FF 03 FF 00
    $51C5  DB  11 00 21 00 E3 00 3F 00 FF 00 FF 00 FF 00 FE 00
    $51D5  DB  00 EE 00 DE 00 1C 00 C0 00 00 00 00 00 00 00 01
    $51E5  DB  FF 00 FF 00 FF 00 F7 00 DF 00 BF 00 7F 00 FF 00
    $51F5  DB  00 00 01 00 07 00 06 08 1C 20 39 40 71 80 C1 00
    $5205  DB  F0 00 F9 00 F1 00 80 00 48 00 B0 00 F0 00 F1 00
    $5215  DB  0F 0F 06 06 0E 0E 7F 7F B7 B7 4F 4F 0F 0F 0E 0E
    $5225  DB  00 FF 00 FF 00 FF 00 FF 00 FF C0 FF 60 EF C4 07
    $5235  DB  00 00 00 00 00 00 00 00 00 00 00 00 10 10 38 38
    $5245  DB  00 FF 00 FF 00 FF 00 BF 00 87 00 F9 00 FE 00 FF
    $5255  DB  00 00 00 00 00 00 40 00 78 00 06 00 01 00 00 00
    $5265  DB  87 00 8C 00 89 00 89 00 88 00 91 00 13 00 13 00
    $5275  DB  87 78 8C 73 88 76 88 76 88 77 90 6E 10 EC 10 EC
    $5285  DB  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
    $5295  DB  FF FE FF FE FF FE FF FE FF FE FF FE FF FE FF FE
    $52A5  DB  03 00 1F 01 3F 07 7F 0F FF 3F FF FE 3D 3C 13 00
    $52B5  DB  FF FC FF E0 FF C0 FF 80 FF 00 FE 00 FE C2 FC EC
    $52C5  DB  F8 00 F0 F0 E0 E0 FC C0 F8 80 F0 00 EC 00 FC 00
    $52D5  DB  FF 07 FF 0F FF 1F C3 03 87 07 0F 0F 1F 13 7B 03
    $52E5  DB  00 00 00 00 00 00 00 00 3C 00 7E 00 66 00 66 00
    $52F5  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $5305  DB  F0 00 C0 00 80 00 80 00 00 00 00 00 22 00 39 00
    $5315  DB  0F 0F 3F 3F 7F 7F 7F 7F FF 9F FF 87 DD C1 C6 C0
    $5325  DB  03 1C 07 38 0D 30 18 60 10 60 21 40 23 40 07 40
    $5335  DB  FC E0 F8 C0 F2 C2 E7 86 EF 88 DE 80 DC 80 F8 80
    $5345  DB  56 77 5B 7D 55 7B EB 71 D7 6F AF 1F FA 33 00 FF
    $5355  DB  AC 36 A4 75 AB 2B 14 11 2F 2F 5C 1B 05 21 00 00
    $5365  DB  00 FF F0 FF AE FF 1F 1F 38 FF FF FF 03 FF 00 FF
    $5375  DB  00 00 0F BF F1 FF E0 10 C7 EF 00 D8 FC FC 00 00
    $5385  DB  00 FF F0 FF AE FF 1F 1F 38 FF FF FF 03 FF 00 FF
    $5395  DB  00 00 0F 3F F1 FF E0 10 C7 EF 00 D8 FC FC 00 00
    $53A5  DB  00 FF FD FF 73 FF CF FC 33 3E CC CF F3 F3 00 FF
    $53B5  DB  00 00 03 1F 9C EF 78 BC DC 2E 37 8B 0C 60 00 00
    $53C5  DB  00 FF B7 FF BD FF E7 7F BB FF 7C FD EE E0 00 FF
    $53D5  DB  00 00 CF FF 72 FF 3F 7F 44 EC 83 D9 11 60 00 00
    $53E5  DB  00 FF 47 FF 87 87 3D FF D0 F8 7E FF E3 FF 00 FF
    $53F5  DB  00 00 F8 FF 7B 87 C6 FF 3F 78 81 83 1C 1E 00 00
    $5405  DB  00 FF FF FF B7 FF 27 01 D7 FF 1F CF FA F3 00 FF
    $5415  DB  00 00 00 00 DF EF D8 01 7F FF E4 CB 05 61 00 00
    $5425  DB  00 FF F0 FF AE FF 1F 1F 38 FF FF FF 03 FF 00 FF
    $5435  DB  00 00 0F 3F F1 FF E0 10 C7 EF 00 D8 FC FC 00 00
    $5445  DB  00 FF C5 FD 60 E7 0B 1F BC FF E1 E1 E2 FF 0A F5
    $5455  DB  00 00 3A 78 9F C7 FC 1E 63 FF DE E1 1F FF 00 00
    $5465  DB  01 FE 3C FF 81 9D FB FB 50 FF 9D BD 68 FB 0C E0
    $5475  DB  00 00 C3 F7 7E 1C 04 83 FF FF CA 98 F7 F3 13 00
    $5485  DB  00 FF 00 99 00 24 00 24 00 00 00 42 00 BD 00 C3
    $5495  DB  FF FF 99 99 24 24 24 24 00 00 42 42 BD BD C3 C3
Bank8_VramBlk6_DungeonB:  ; $54A5-$64A4  cat0 asset $11 (raw 4KB; renders as noise)
    $54A5  DB  0B 00 00 0E 3E 01 EF 10 80 71 00 90 30 00 30 00
    $54B5  DB  F4 E4 FF F1 FF C0 E1 00 8E 0E 6F 6F CF C7 CF C1
    $54C5  DB  FD 01 FF 03 1A E3 81 1E EE 01 1B 00 08 00 1E 00
    $54D5  DB  F3 02 C3 00 E7 04 FE 00 1F 00 E5 E4 FF C7 FF 81
    $54E5  DB  E3 FC 00 FF 1F E0 F2 00 0F 81 1E C2 7D 00 7C 00
    $54F5  DB  FE 02 FF 00 E0 00 0D 0C F1 70 E3 20 B2 80 F3 83
    $5505  DB  00 00 0C 00 3F 00 7F 00 00 00 00 00 7F 00 3F 00
    $5515  DB  FF FF F3 F3 C0 C0 80 80 FF FF FF FF FF 80 C7 C0
    $5525  DB  4F 00 5E 00 69 01 E1 01 F3 01 33 00 33 00 9B 00
    $5535  DB  B0 80 A1 81 97 86 1F 0E 0F 0C CF CC DE CC EC 64
    $5545  DB  3F 13 FF E3 F7 C9 E3 8D E3 0D EF 00 EF 00 CF 00
    $5555  DB  FF C0 EF 00 EF 00 DF 10 9F 10 13 10 11 10 31 30
    $5565  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $5575  DB  FF 03 FF 0F FF 1F FF 00 FF 00 FF 00 FF 00 FF 00
    $5585  DB  8F 00 0F 00 1E 00 00 00 30 30 E1 E1 0F 0F 3F 38
    $5595  DB  F0 F0 F0 F0 E1 E1 FF FF FF FF FF FE FF F0 FF C0
    $55A5  DB  03 FF 63 FF FB FF C9 FF E1 FF F1 FF E1 FF F0 FF
    $55B5  DB  FF 03 FF 03 FF 03 FF 01 FF 01 FF 01 FF 01 FF 00
    $55C5  DB  00 87 00 8F 00 CF 00 EF 00 00 00 00 00 00 0A 0A
    $55D5  DB  78 78 70 70 30 30 10 10 FF 00 FF 00 FF 00 F5 00
    $55E5  DB  FC FF F9 FF F5 FF ED FF DD FF DB FF BB FF 7B FF
    $55F5  DB  FF FC FF F9 FF F1 FF E1 FF C1 FF C3 FF 83 FF 03
    $5605  DB  06 02 2F 3F 15 1F EF EF FF FF FF FF F8 F8 00 00
    $5615  DB  FE 01 D6 01 EA 15 10 0F 00 00 00 00 07 00 FF 00
    $5625  DB  BF FF 7F FF 00 FF FF FF FF FF FF FF FF FF FE FF
    $5635  DB  FF 80 FF 00 FF 00 FF FF FF FF FF FF FF FF FF FE
    $5645  DB  FE FF FF FF 01 FF 80 FF 00 FF E0 FF FF FF 00 FF
    $5655  DB  FF 00 FF 00 FF 00 FF 80 FF 00 FF E0 FF FF FF 00
    $5665  DB  50 FE 10 FE 90 FC 38 FC 1C FC 1C FF 0C FF 06 FF
    $5675  DB  E1 41 E1 01 F3 03 F3 03 FB 03 F8 00 F8 00 FC 00
    $5685  DB  00 1F 00 1F 00 1F 00 1F 00 1F 00 1F 00 1F 00 0F
    $5695  DB  E0 E0 E0 E0 E0 E0 E0 E0 E0 E0 E0 E0 E0 E0 F0 F0
    $56A5  DB  30 00 18 00 0E 00 00 00 01 3E 06 78 3C C0 60 80
    $56B5  DB  CF C1 E7 E1 F1 F0 FF FF FE C0 F9 81 C3 03 9F 1F
    $56C5  DB  1E 00 1C 00 0C 00 00 00 00 00 00 00 00 00 00 00
    $56D5  DB  FF 81 FF 83 FF C3 FF E7 FF F7 FF FF FF FF FF FF
    $56E5  DB  7E 00 17 00 8F 00 87 00 42 00 08 00 04 00 03 00
    $56F5  DB  FD 01 FE 00 7E 00 7E 30 BF B1 F7 F1 FB F9 FC FC
    $5705  DB  1F 00 0F 00 07 00 03 00 00 00 00 00 00 00 1F 02
    $5715  DB  E1 E0 F0 F0 F8 F8 FC FC FF FF FF FF FF FF FF E0
    $5725  DB  DD 00 EF 00 E7 00 E7 00 7E 00 06 00 06 00 06 00
    $5735  DB  E6 22 36 10 18 18 18 18 83 81 FB F9 FB F9 F9 F9
    $5745  DB  C7 00 9B 00 3B 00 73 00 70 03 62 01 61 00 60 00
    $5755  DB  38 38 65 64 C5 C4 8C 8C 8F 8C 9F 9C 9F 9C 9F 9D
    $5765  DB  FF 3F FF 7F FF 3F FF 3F 7F 9F 0F F5 07 F9 8F 71
    $5775  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 7B 00
    $5785  DB  E0 E0 FF FF F8 F8 00 00 3F 3F FF FF FF FF FF FF
    $5795  DB  1F 00 00 00 07 00 FF 00 C0 00 00 00 00 00 00 00
    $57A5  DB  00 FF 80 FF E2 FF E6 FF EE FF DC FF 9C FF B9 FF
    $57B5  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $57C5  DB  00 F9 10 7A 08 3B 08 1D 04 0E 06 07 01 03 00 01
    $57D5  DB  06 00 05 80 04 C0 02 E0 01 F0 00 F8 00 FC 00 FE
    $57E5  DB  7B FF 77 FF F7 FF F7 FF F7 FF F7 FF F6 FF E4 FF
    $57F5  DB  FF 03 FF 07 FF 07 FF 07 FF 07 FF 07 FF 06 FF 04
    $5805  DB  EF FF DF FF DF FF DF FF 9F FF 9C FF 1D FF 39 FF
    $5815  DB  FF EF FF DF FF DF FF DF FF 9F FF 9C FF 1C FF 38
    $5825  DB  EF FF EF FF DF FF 9F FF 3F FF BF FF 3F FF 7F FF
    $5835  DB  FF EF FF EF FF DF FF 9F FF 3F FF 3F FF 3F FF 7F
    $5845  DB  7F FF BF FF DF FF CF FF F7 FF F9 FF FE FF FF FF
    $5855  DB  FF 00 FF 80 FF C0 FF C0 FF F0 FF F8 FF FE FF FF
    $5865  DB  E2 FF F8 FF FF FF FF FF FF FF 00 FF F0 FF F0 FF
    $5875  DB  FC 00 FE 00 FE 00 FE 00 FE 00 FF 00 FF F0 FF F0
    $5885  DB  00 8F 00 CF 00 E7 C0 37 C0 BF E0 9F F0 8F 78 C7
    $5895  DB  70 70 30 30 18 18 08 08 00 00 00 00 00 00 80 00
    $58A5  DB  F1 00 F1 40 F1 60 F3 20 FB 10 FB 10 FF 08 3D 00
    $58B5  DB  8E 0E 8E 4E 8E 6E DC 2C FC 04 FC 04 FC 00 FE C2
    $58C5  DB  00 00 00 00 00 00 0F 00 3F 00 7F 01 0F 02 1F 04
    $58D5  DB  FF FF FF FF FF FF F1 F0 C3 C0 87 80 FF F0 FF E0
    $58E5  DB  7D FE 7F EE 7D 6C 46 6D EE 6B 72 EB 4A EF 6A EF
    $58F5  DB  2A 3E 28 2C AE 28 B8 2C 38 08 0C 2A 3C 2E 34 2C
    $5905  DB  01 1E 00 01 00 10 00 17 00 78 00 F0 00 E0 80 00
    $5915  DB  E1 E0 FE E0 EF E0 E8 E8 87 84 0F 0E 1F 1F 7F 7F
    $5925  DB  E7 40 77 D0 3B 50 33 D0 13 00 03 00 03 00 0B 00
    $5935  DB  F9 18 79 08 B5 04 1D 04 ED 04 FD 04 FD 80 F5 F4
    $5945  DB  40 00 80 00 02 00 0F 01 3D 01 F4 04 80 00 80 00
    $5955  DB  BF B9 7F 71 FD C1 F1 80 C3 80 0F 08 7F 71 7F 73
    $5965  DB  FD 02 FC 03 FE 01 FF 00 FF 00 BF 00 0F 00 01 00
    $5975  DB  03 00 07 00 0F 00 83 00 03 00 40 40 F0 F0 FE FE
    $5985  DB  F7 1F DF 2F CE 3F 8E 7F CE 3F E8 1F F7 0F FF 1F
    $5995  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 3F 00 1F 00
    $59A5  DB  B9 FF 71 FF 71 FF 73 FF 63 FF 63 FF 42 FF E2 FF
    $59B5  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $59C5  DB  F0 F0 F2 F2 F1 F1 F1 F1 F0 F0 FA F0 F4 E0 FB C0
    $59D5  DB  01 FF 81 7F C0 3F C0 3F C0 3F C0 35 80 6B C0 04
    $59E5  DB  E8 FF C0 FF C0 FF 81 FF 82 FF 81 FF 07 FF 00 FF
    $59F5  DB  FF 08 FF 00 FF 00 FF 01 FF 02 FF 00 FF 00 FF 00
    $5A05  DB  72 FF 76 FF CD FF BB FF 7B FF E7 FF 0F FF 1E FF
    $5A15  DB  FF 70 FF 70 FF C1 FF 83 FF 03 FF 07 FF 0F FF 1E
    $5A25  DB  58 50 37 30 7F 63 F8 48 F0 F0 FE FE 00 00 00 00
    $5A35  DB  37 E7 38 C8 40 A0 47 00 0F 00 01 00 FF 00 FF 00
    $5A45  DB  00 80 00 80 00 C0 00 C0 00 E0 00 E0 00 F0 00 F0
    $5A55  DB  7F 7F 7F 7F 3F 3F 3F 3F 1F 1F 1F 1F 0F 0F 0F 0F
    $5A65  DB  25 00 27 00 CF 00 EF 00 E7 00 EF 00 C9 00 98 00
    $5A75  DB  DB DA DB D8 FF 30 FF 10 FF 18 F3 10 F7 36 E7 67
    $5A85  DB  40 C0 C0 00 E0 20 E0 20 F0 10 DF 3F FF 0F FF 0F
    $5A95  DB  80 3F C0 3F C0 1F DE 01 EF 00 20 C0 00 F0 00 F0
    $5AA5  DB  FE 00 FC 00 60 60 86 80 06 00 7F 10 FF 60 FF 80
    $5AB5  DB  7F 7F 1F 1F FF 03 F9 01 F9 01 90 00 63 00 80 00
    $5AC5  DB  3F 08 3F 10 3F 00 79 00 61 00 C0 06 C0 0C 00 1E
    $5AD5  DB  FF C0 FF C0 FE C0 FE 86 FE 9E 7F 38 BF 30 FF E1
    $5AE5  DB  72 77 66 F7 74 77 10 DB 18 5B 12 DB CA 5B AA 7F
    $5AF5  DB  AC 74 38 76 9A 72 6E 5A EE 5A 6C 58 74 58 54 74
    $5B05  DB  1F 1C 03 03 00 00 00 00 FF FF 3F 3F 03 03 00 00
    $5B15  DB  E2 81 FC 00 FF 00 FF 00 00 00 C0 00 FC 00 FF 00
    $5B25  DB  FF 00 FF F0 07 07 00 00 C0 C0 FE FE FF FF 0F 0F
    $5B35  DB  00 FF 00 0F F8 00 FF 00 3F 00 01 00 00 00 F0 00
    $5B45  DB  FF 00 FF 00 FF F0 0F 0F 00 00 00 00 FF FF FF FF
    $5B55  DB  00 FF 00 FF 00 0F F0 00 FF 00 FF 00 00 00 00 00
    $5B65  DB  FF 00 FF 00 FF 00 FF FF 00 00 00 00 FF FF FF FF
    $5B75  DB  00 FF 00 FF 00 FF 00 00 FF 00 FF 00 00 00 00 00
    $5B85  DB  3D 02 7B 04 9E 60 3F C0 FF 00 FF 00 F3 00 C1 00
    $5B95  DB  FC C0 FC 80 F9 01 E3 00 C1 00 12 00 6C 0C FE 3E
    $5BA5  DB  C0 FF A0 7F D8 3F E6 1F F9 07 F0 03 E2 01 80 00
    $5BB5  DB  00 00 80 00 C0 00 C0 00 80 00 0C 0C 1C 1C 7F 7F
    $5BC5  DB  00 FF 00 FF 00 FF 00 FF C0 FF 7F FF 00 FF 00 00
    $5BD5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF
    $5BE5  DB  00 FF 00 FF 00 FF 00 FF 00 FF E0 FF 1E FF 01 1F
    $5BF5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 E0 E0
    $5C05  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF FF FF
    $5C15  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $5C25  DB  FF 01 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $5C35  DB  00 00 00 00 00 00 0F 00 3C 00 7B 00 7F 00 FC 00
    $5C45  DB  FF FF FF 7F FF 0F FF 07 FF 00 FF 00 FF 00 FF 00
    $5C55  DB  00 00 00 00 F0 00 80 00 02 00 87 00 0C 00 18 00
    $5C65  DB  C0 C0 E0 E0 F0 F0 F8 F8 FE 7E FE 1E FF 0F FF 07
    $5C75  DB  3F 00 1F 00 0F 00 07 00 01 00 01 00 00 00 00 00
    $5C85  DB  03 00 02 00 00 00 18 18 30 30 38 38 00 00 00 00
    $5C95  DB  FC FC FD 00 FF E0 E7 04 CF 07 C7 03 FF 00 FF 3F
    $5CA5  DB  00 00 00 00 00 00 00 00 00 00 01 00 01 00 19 00
    $5CB5  DB  FF FF FF F8 FF E0 FF 81 FF 0F FE 1C FE F8 E6 E0
    $5CC5  DB  C0 00 E0 00 F0 00 F0 00 70 00 38 00 18 00 0C 00
    $5CD5  DB  3F 3F 1F 1B 0F 09 8F 08 8F 8C C7 44 E7 21 F3 11
    $5CE5  DB  65 FE 77 EE 7D 6C 46 6D EE 6B 72 EB 4A EF 6A EF
    $5CF5  DB  1A 3E 28 2C AE 28 B8 2C 38 08 0C 2A 3C 2E 34 2C
    $5D05  DB  72 77 66 F7 74 77 10 DB 18 5B 12 DB CA 5B AA 7F
    $5D15  DB  AC 74 38 76 9A 72 6E 5A EE 5A 6C 58 74 58 54 74
    $5D25  DB  65 FE 77 EE 7D 6C 46 6D EE 6B 72 EB 4A EF 6A EF
    $5D35  DB  1A 3E 28 2C AE 28 B8 2C 38 08 0C 2A 3C 2E 34 2C
    $5D45  DB  79 FE 73 EE 75 6C 46 6D CE 6B 72 EB 6A EF 6A EF
    $5D55  DB  2A 3A 28 28 AE 28 B8 2C 38 28 2C 2A 38 2A 38 28
    $5D65  DB  1F E0 83 7C F8 07 FF 00 FF 00 FC 00 F0 00 00 00
    $5D75  DB  FE 00 FF 00 FF 00 FE 00 FC 00 F3 03 0F 0F FF FF
    $5D85  DB  80 80 60 E0 10 F0 08 18 00 00 00 00 00 00 00 00
    $5D95  DB  7F FF 9F 7F EF 1F F7 EF FF FF FF FF FF FF FF FF
    $5DA5  DB  1E 00 3E 00 3E 00 3F 00 3F 00 26 00 04 00 00 00
    $5DB5  DB  EF E1 DF 81 FF 81 FC C0 F8 C0 F9 D9 FB FB FF FF
    $5DC5  DB  01 00 01 00 01 00 01 00 01 00 01 00 01 00 00 00
    $5DD5  DB  FE FE FE FE FE FE FE FE FE FE FE 3E FE 0E FF 00
    $5DE5  DB  07 07 07 07 07 07 07 07 07 07 07 07 07 07 07 07
    $5DF5  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $5E05  DB  00 FF 00 99 00 24 00 24 00 00 00 42 00 BD 00 C3
    $5E15  DB  FF FF 99 99 24 24 24 24 00 00 42 42 BD BD C3 C3
    $5E25  DB  14 00 F4 00 DC 00 DF 02 8F 06 1F 04 BF 0C 3F 08
    $5E35  DB  EB EB 2B 0B E3 23 E1 22 F3 74 FB E4 7F 40 FF C0
    $5E45  DB  30 30 0F 0F 00 00 00 00 00 00 00 00 00 00 FC 00
    $5E55  DB  10 EF 85 FA C0 FF F0 FF FF FF FF FF FF FF FF 03
    $5E65  DB  00 00 C0 C0 30 30 08 08 08 08 05 05 05 05 06 06
    $5E75  DB  7F FF FF 3F 3F CF 7F F7 F7 FF FA FF FA FF F9 FF
    $5E85  DB  60 60 60 60 60 60 C0 C0 C0 C0 80 80 00 00 00 00
    $5E95  DB  9F FF 9E FF 9C FF 31 FF 07 FF 3F FF 7F FF FF FF
    $5EA5  DB  62 00 82 00 04 00 04 00 38 00 C0 00 00 00 00 00
    $5EB5  DB  9D 81 7D 01 FB 03 FB 03 C7 07 3F 3F FF FF FF FF
    $5EC5  DB  00 00 88 70 C0 18 C0 2C D0 20 40 30 20 18 20 18
    $5ED5  DB  FF 0F 7F 07 3F 07 1F 03 0F 03 8F 83 C7 C1 C7 C1
    $5EE5  DB  41 06 4F 05 6F 02 6D 01 6C 00 6E 00 4E 00 4E 00
    $5EF5  DB  BF B8 B7 B0 93 90 92 93 93 93 91 91 B1 B1 B1 B1
    $5F05  DB  F7 FD F7 69 FF AF F3 F3 07 07 0F 0B 0F 07 1F 16
    $5F15  DB  9C 61 DD 20 FB 04 EF 1C FE F9 FE F1 FC F3 F8 E6
    $5F25  DB  DB DB DC DC D8 D8 D0 D0 80 80 00 00 00 00 80 00
    $5F35  DB  FB 24 BC 63 B9 67 37 EF 6F FF FF FF FB FF 77 7F
    $5F45  DB  E0 E0 00 00 0C 00 12 00 12 00 0C 00 40 40 40 40
    $5F55  DB  00 FF 7F FF FF FF FF FF FF FF FF FF FF FF FF FF
    $5F65  DB  72 F7 66 F7 74 F7 10 DB 98 5B 12 DF C8 5D 2A FF
    $5F75  DB  2C 74 38 76 1A 72 6E 5A 6E 5A 6C 5C 76 5C 54 74
    $5F85  DB  2C FF 58 DB 4A FB 3A 7F EA 7F A2 37 08 5B 2D 7E
    $5F95  DB  72 7A 76 52 54 52 D4 76 34 34 5C 16 F6 5A D2 5A
    $5FA5  DB  5B FE 7B EE 5D 68 66 6B CE 6B 72 EB 4A EF 62 EF
    $5FB5  DB  28 38 28 28 AA 28 B8 28 38 28 2C 2A 38 2A 38 28
    $5FC5  DB  00 FF 00 99 00 24 00 24 00 00 00 42 00 BD 00 C3
    $5FD5  DB  FF FF 99 99 24 24 24 24 00 00 42 42 BD BD C3 C3
    $5FE5  DB  00 00 00 00 0E 00 0E 00 07 00 47 00 A3 00 D1 00
    $5FF5  DB  81 FF 83 FF F1 F1 F1 F1 78 F8 38 B8 1C 5C 0E 2E
    $6005  DB  62 42 62 62 64 64 F4 F4 BD BC 9B 98 9B 98 9F 98
    $6015  DB  1D DF 1D FF 9B FF 0B FF 42 FE 44 FC 44 FC 40 F8
    $6025  DB  1E 08 0C 00 00 00 00 00 00 00 00 00 00 00 00 00
    $6035  DB  FF E1 FF 33 FF 1F FF 00 FF 10 FF FF FF 7F FF FF
    $6045  DB  FF 00 FF 3C 7E 02 3F 3D 80 00 F0 00 38 00 1C 00
    $6055  DB  FF 00 FF 00 FE 81 FE C1 7F 7F 0F 0F C7 C7 E3 E3
    $6065  DB  06 06 0C 0C 18 18 F0 F0 31 11 63 43 60 20 60 20
    $6075  DB  F9 FF 73 FF 60 FF 08 FF E9 DE BB DC D9 BF D3 BF
    $6085  DB  00 00 30 30 40 40 9C 80 3C 00 FC 00 30 00 00 00
    $6095  DB  FF FF 31 CF 4C BF 83 63 03 C3 03 03 CF CF FF FF
    $60A5  DB  58 FD 5A F9 76 FD 2E FD 6D FC 7F FE 17 FE 6B FE
    $60B5  DB  76 74 74 70 58 78 50 7C 32 74 30 7A 68 7E 44 6C
    $60C5  DB  04 18 10 0C 00 0C 01 0D 80 0D 00 05 00 06 00 06
    $60D5  DB  E3 E1 E3 E0 F3 F0 F2 F0 72 70 FA F8 F9 F9 F9 F9
    $60E5  DB  07 3B 01 7E BE 5F 7F BD BB 7D FF AE BD 3C C3 00
    $60F5  DB  F4 CB DF A0 FF 00 E1 1C E5 18 FE 00 3C 42 00 3C
    $6105  DB  3F 3E BF BC FF 7C 79 F8 79 F8 E3 60 E1 60 E1 60
    $6115  DB  D8 E6 58 E4 B0 4C 96 6E C6 3E CC 3C CE 3E CE 3E
    $6125  DB  C0 00 C0 00 C0 00 80 00 87 00 1F 07 3F 1F 3C 3C
    $6135  DB  37 3F 2F 3F 0F 3F 1F 7F 3F 78 38 E7 20 DF 03 FF
    $6145  DB  60 60 30 30 1F 1F 73 03 F8 00 FC 00 3E 00 3E 20
    $6155  DB  FF FF FF FF FF FF FF 8F FF 07 FF 03 FF C1 DF E1
    $6165  DB  00 00 00 00 00 00 60 00 90 00 90 00 60 00 00 00
    $6175  DB  00 FF C0 FF FC FF FF FF FF FF FF FF FF FF FF FF
    $6185  DB  03 02 07 04 0F 08 1F 11 1F 11 1F 03 3E 26 3E 26
    $6195  DB  0F FC 1F F8 3F F0 FF E0 FF E0 FF E0 FE C1 FE C1
    $61A5  DB  FC 7C F1 F1 F3 F2 EF E8 CF C0 FF E0 FF E0 FF C1
    $61B5  DB  E0 1F E1 1E 83 7C 87 78 0F F0 1F E0 3F C0 7F 80
    $61C5  DB  FF FF FF 83 FF 00 FF 00 FF 01 FF 03 FF 0F F0 30
    $61D5  DB  3F C0 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 0F
    $61E5  DB  7C 00 F8 80 F8 C0 1C 00 20 00 02 00 00 00 1F 00
    $61F5  DB  03 83 07 87 87 47 E3 E3 DF DF FD FD FF FF E0 E0
    $6205  DB  1E 18 1C 10 1C 10 1C 10 1C 10 1A 10 9A 10 98 10
    $6215  DB  C1 F9 C3 F3 83 F3 83 F3 83 F3 85 F5 05 75 07 77
    $6225  DB  80 00 08 00 08 00 09 00 0A 00 12 00 22 00 82 80
    $6235  DB  7F 7F FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $6245  DB  1C 00 06 00 86 00 46 00 43 00 43 00 47 00 8F 00
    $6255  DB  E3 E3 F9 F9 F9 F9 F9 F9 FC FC FC FC F8 F8 F0 F0
    $6265  DB  60 20 60 20 61 61 72 72 F4 74 F4 74 FC 3C E8 28
    $6275  DB  C3 BF C7 BF 8E FF 8D FF 01 7F 01 7F 03 3F 07 3F
    $6285  DB  EA 08 B1 30 65 64 48 48 8C 8C 85 84 87 06 93 03
    $6295  DB  03 1D 71 4E E1 9E D8 B7 F8 77 F8 7E BC 7A AE 6D
    $62A5  DB  72 EF 0A FF 44 FD 54 7D 6A FB 6A 7B F6 77 56 F7
    $62B5  DB  44 64 64 6C 3E 78 BA 7C 3C 50 94 3A 18 22 28 34
    $62C5  DB  00 00 0F 00 3F 00 7F 00 7E 00 7C 00 78 00 60 00
    $62D5  DB  FF FF FF F0 FC C0 F0 80 E1 81 C3 83 C7 87 DF 9F
    $62E5  DB  CF 01 CD 00 CF 00 63 00 67 04 77 05 06 02 06 02
    $62F5  DB  31 30 31 32 33 30 9B 9C 9F 98 87 88 FE 09 FE 01
    $6305  DB  CC 40 CC C0 CE C0 A7 A0 27 20 05 00 40 40 49 48
    $6315  DB  83 73 93 73 91 71 18 F8 18 F8 3A FA 3E FF 3E F6
    $6325  DB  7C 38 7D 78 FE 70 F6 70 E6 E0 F3 E0 FB E0 E0 E0
    $6335  DB  43 BB 02 FA 81 71 89 79 19 F9 0C EC 04 E4 1F FF
    $6345  DB  1E 10 8E 01 C7 00 63 00 33 00 01 00 01 00 00 00
    $6355  DB  EF F1 7F 70 3F 38 9F 9C CF CC FF FE FF FE FF FF
    $6365  DB  00 00 0C 0C 3C 3C F0 F0 00 00 00 00 00 00 20 00
    $6375  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF DF DF
    $6385  DB  3D 05 7D 4C 7B 48 7F 4C 7F 49 3F 2F 3C 2C 30 30
    $6395  DB  BC C3 FD 82 FB 84 FB 84 F7 88 FE C1 F3 CF EF DF
    $63A5  DB  FF 82 FF 17 FF 2F FE 3E FF FF FC 84 13 00 32 00
    $63B5  DB  FF 00 FF 00 FF 00 F8 07 80 7F 00 87 EC EC CD CD
    $63C5  DB  E0 E0 E0 E0 E0 E0 E0 E0 90 90 C0 C0 48 00 47 00
    $63D5  DB  FF 1F FF 1F DF 3F 1F FF 0F FF 07 FF B7 B7 BE B8
    $63E5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $63F5  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $6405  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $6415  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $6425  DB  C0 FF 3C 3F 03 03 00 03 00 00 00 00 00 00 00 00
    $6435  DB  00 00 C0 C0 FC FC FC FC FF FF FF FF FF FF FF FF
    $6445  DB  00 FF 00 FF 00 FF C0 FF 38 FF 05 1F 03 03 00 00
    $6455  DB  00 00 00 00 00 00 00 00 00 00 E0 E0 FC FC FF FF
    $6465  DB  00 00 00 FF 00 FF 00 FF 00 FF 00 0F 00 E0 00 BF
    $6475  DB  FF 00 00 00 00 00 00 00 00 00 F0 00 1F 00 40 00
    $6485  DB  C0 C0 E0 60 F0 70 FC 3C FC 1C CE 06 83 01 00 00
    $6495  DB  3F 00 1F 00 0F 00 03 00 03 00 31 30 7C 7C FF FF
Bank8_VramBlk7_DungeonLZ:  ; $64A5-$68DC  cat0 asset $0F (LZ; the REAL shown tiles)
    $64A5  DB  80 08 20 01 10 07 10 02 20 03 03 03 10 20 00 00
    $64B5  DB  01 10 02 10 04 20 0F 01 07 20 0F 01 01 20 0B 01
    $64C5  DB  99 14 39 14 3A 14 01 14 BC 14 BD 14 BE 14 4A D4
    $64D5  DB  0C 14 0D 14 0E 14 2A 14 20 22 00 04 10 06 10 05
    $64E5  DB  10 04 20 09 01 20 02 00 04 10 05 10 14 D0 13 D0
    $64F5  DB  20 10 00 20 42 00 05 20 0B 01 49 14 4A 14 3A 14
    $6505  DB  4C 14 01 14 01 14 FF 14 1C 14 1D 14 1E 14 2A 54
    $6515  DB  03 10 02 20 45 01 05 10 06 20 49 01 04 10 20 80
    $6525  DB  00 12 20 85 01 20 58 00 20 22 00 06 10 02 10 5E
    $6535  DB  14 59 14 49 14 4B 14 5C 14 5D 14 4D 14 4E 14 2C
    $6545  DB  14 2D 14 2E 14 2A 14 20 52 02 20 C4 02 04 20 53
    $6555  DB  01 06 20 0B 01 20 96 02 20 9A 04 02 10 6E 14 69
    $6565  DB  14 6A 14 5B 14 6C 14 6D 14 10 14 FE 14 3C 14 3D
    $6575  DB  14 3E 14 5A 14 20 80 06 75 98 76 98 77 98 78 98
    $6585  DB  79 98 7A 98 7B 98 7A 58 7A 20 0F 13 20 0C 10 7A
    $6595  DB  98 7B D8 7A D8 79 D8 78 D8 77 D8 76 D8 75 D8 BB
    $65A5  DB  14 10 20 37 11 FE 14 07 20 91 01 20 46 00 A2 18
    $65B5  DB  20 D8 FF 15 E0 18 B7 14 B8 14 B9 14 BA 14 BB 14
    $65C5  DB  20 5C 02 0F 10 05 10 E0 20 4B 1F 16 F0 18 6B 14
    $65D5  DB  FB 18 20 B8 12 20 0E 02 1F 10 05 10 F0 20 4B 1F
    $65E5  DB  16 D6 D8 20 B8 14 FB 18 FB 14 FB 14 07 10 2F 10
    $65F5  DB  05 10 B2 20 CB 1F 18 31 20 B7 15 FB 14 01 10 FB
    $6605  DB  14 3F 10 06 10 B2 98 20 D8 FF 15 B2 98 41 14 32
    $6615  DB  14 33 14 34 20 B7 10 20 7D 21 4F 10 06 10 D6 20
    $6625  DB  CB 1F 1A 42 14 43 14 44 20 B7 15 5F 10 06 10 D7
    $6635  DB  20 4B 1F 16 C2 98 FB 18 52 14 53 14 54 20 B7 15
    $6645  DB  6F 20 47 20 20 4B 1F 16 B2 98 FB 18 62 14 63 14
    $6655  DB  64 20 37 26 18 0F 10 C2 20 4B 1F 16 D7 98 30 10
    $6665  DB  50 14 51 20 B7 13 0A 10 0B 10 FB 18 11 14 D8 20
    $6675  DB  CB 1F 17 98 40 10 60 10 61 20 B7 13 1A 10 1B 10
    $6685  DB  FB 18 4F 20 09 2F 18 C5 20 B9 13 15 10 16 10 25
    $6695  DB  10 20 B8 12 CA 10 D7 58 20 4C 2F 17 21 10 22 10
    $66A5  DB  23 10 24 10 FB 14 35 10 36 10 37 10 38 10 5F 10
    $66B5  DB  B2 20 0B 4F 16 F0 98 72 10 72 50 71 50 70 50 C0
    $66C5  DB  10 45 10 46 10 47 10 48 10 6F 20 49 4F 18 E0 98
    $66D5  DB  B0 50 82 50 81 50 80 50 D0 10 55 10 56 10 57 10
    $66E5  DB  58 10 6F 20 89 1F 18 D6 18 73 50 92 50 91 50 90
    $66F5  DB  50 C1 10 65 10 66 10 67 10 20 00 20 20 CA 1F 17
    $6705  DB  D7 18 83 50 FB 14 08 10 09 10 D1 10 70 10 71 10
    $6715  DB  72 10 72 10 A1 20 49 1F 18 D8 98 93 50 17 10 18
    $6725  DB  10 19 10 E1 10 80 10 81 10 82 10 B0 10 B1 20 C9
    $6735  DB  2F 19 18 A3 50 27 10 28 10 29 10 F1 10 90 10 91
    $6745  DB  10 92 10 73 10 74 10 75 18 76 18 77 18 78 18 79
    $6755  DB  18 7A 18 7B 18 7A D8 7A 20 CF 53 20 CC 50 20 D4
    $6765  DB  54 20 D4 52 75 58 FB 14 CD 14 CE 14 CF 14 73 10
    $6775  DB  C6 10 C7 14 C8 14 83 10 84 10 85 20 CB 01 88 10
    $6785  DB  8A 10 06 10 06 10 8C 10 8D 10 8E 10 8F 10 8F 50
    $6795  DB  D2 14 D3 14 D4 14 D5 14 E6 14 E7 14 E8 14 E9 14
    $67A5  DB  A9 14 DB 14 FB 14 DD 14 DE 14 DF 14 83 10 FB 18
    $67B5  DB  2B 50 2B 10 93 10 94 10 95 10 96 10 04 10 98 10
    $67C5  DB  9A 10 9B 10 9C 10 06 10 9D 10 9E 10 9F 10 AD 90
    $67D5  DB  E2 14 E3 14 E4 14 E5 14 F6 14 F7 14 F8 14 F9 14
    $67E5  DB  FB 14 EB 14 EC 14 ED 14 EE 14 FB 14 93 10 FB 18
    $67F5  DB  3B 50 3B 10 A3 10 A4 10 A5 10 A6 10 A7 10 A8 10
    $6805  DB  AA 10 AB 20 13 61 20 14 60 AF 14 89 14 F2 14 F3
    $6815  DB  14 F4 14 F5 14 20 00 20 CC 14 AE 14 A0 14 EB 94
    $6825  DB  26 14 87 14 EF 14 DA 14 A3 20 01 43 5A 54 3E 14
    $6835  DB  97 54 97 14 B3 14 B4 14 B5 14 B6 20 D3 60 54 B5
    $6845  DB  54 B4 54 B3 54 97 14 8B 14 AC 14 3E 94 3E 94 86
    $6855  DB  14 BF 14 DC 20 A9 61 20 00 20 68 14 FB 14 EA 20
    $6865  DB  A9 60 20 F7 16 20 09 7F 4D 20 1F 7F 02 20 A0 FF
    $6875  DB  4D 20 E0 FF 0D FF 47 40 09 00 11 03 1A 2E 02 91
    $6885  DB  02 34 03 B9 03 FD 03 FF 2B FF 47 9D 0C 61 00 FF
    $6895  DB  7F 1F 03 9F 03 FF 47 C0 04 83 00 0C 01 A7 00 B1
    $68A5  DB  02 34 03 07 0E 40 09 FF 03 5A 03 86 01 20 18 81
    $68B5  DB  7C 9D 0C 20 20 80 25 00 0F 01 AA 00 B4 02 39 03
    $68C5  DB  09 0E 42 09 BF 03 5D 03 8A 20 37 81 F3 1D 98 12
    $68D5  DB  FF 47 00 7C 20 62 8F 09
Bank8_VramBlk8_Cat1A:  ; $68DD-$78DC  cat1 asset $10 (raw 4KB; renders as noise)
    $68DD  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $68ED  DB  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    $68FD  DB  7F FF 0C 83 10 8F 00 FF 0C F3 00 FB 00 FF 30 FF
    $690D  DB  7F 00 7F 00 7F 00 7F 00 7F 00 7F 00 7F 00 7F 00
    $691D  DB  FF FF 00 FF 40 3F 80 7F 70 FF 10 FF 00 FF 00 FF
    $692D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $693D  DB  FF FF 00 FF 00 FF 00 FF 28 D7 30 CF 80 7F 00 FF
    $694D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $695D  DB  FF FF 00 FF 70 FF 00 FF 82 01 02 01 04 FB 00 FF
    $696D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $697D  DB  86 01 C9 06 D7 0C F7 08 EC 13 F7 08 FF 00 FF 00
    $698D  DB  78 78 B5 B0 AB A0 97 80 CF C0 DF C0 DF C0 EF E0
    $699D  DB  00 00 00 00 40 00 40 00 40 00 40 00 40 00 C0 00
    $69AD  DB  FF FF FF FF BF BF BF BF BF BF BF BF BF BF 3F 3F
    $69BD  DB  0F 00 0F 00 07 00 07 00 07 00 03 00 03 00 03 00
    $69CD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $69DD  DB  FA 05 F4 0B FE 01 F8 07 F8 07 FA 05 F8 07 F8 07
    $69ED  DB  EF E0 2F 20 EF E0 F7 F0 97 90 E7 E0 F7 F0 F7 F0
    $69FD  DB  7F BF 67 E0 6F E0 59 C6 51 CE 77 E8 7F FF 00 FF
    $6A0D  DB  7F 00 1F 00 1F 00 3F 00 3F 00 1F 00 00 00 00 00
    $6A1D  DB  7F BF 78 DF 5C FF 7C FF 58 FF 78 FF 77 EB 00 FF
    $6A2D  DB  7F 00 3F 00 3F 00 3F 00 3F 00 3F 00 1C 00 00 00
    $6A3D  DB  FC FF 2A D3 1C E5 BA 43 DE 27 5A A3 FE FF 00 FF
    $6A4D  DB  FE 00 FC 00 FA 00 FC 00 F8 00 FC 00 00 00 00 00
    $6A5D  DB  F8 07 8C 03 90 0F 00 FF 0C F3 00 FB 00 FF 00 FF
    $6A6D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6A7D  DB  7F FF 00 FF 0F FF 00 FF 17 EF 13 EB 01 F9 31 C9
    $6A8D  DB  7F 00 7F 00 70 00 70 00 70 00 74 00 76 00 76 00
    $6A9D  DB  FF FF 08 F7 FF FF 00 FF 7F FF 00 FC 4C B6 32 6D
    $6AAD  DB  FF 00 FF 00 00 00 00 00 00 00 03 00 79 00 9E 00
    $6ABD  DB  EF FF 38 C7 FF FF 00 FF 83 FF 00 FE 44 BA 6C D6
    $6ACD  DB  FF 00 FF 00 00 00 00 00 38 00 7D 00 7D 00 39 00
    $6ADD  DB  00 FF 80 7F 01 FE 03 FC 00 FF 00 FF 80 7F 40 BF
    $6AED  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6AFD  DB  01 FE 00 FF 00 FF 00 FF 24 C3 01 80 7F FF 00 FF
    $6B0D  DB  7F 00 7F 00 7F 00 7F 00 7F 00 7F 00 00 00 00 00
    $6B1D  DB  71 8E 21 DE 07 F8 08 F7 00 FF 03 FD FF FF 00 FF
    $6B2D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 00 00 00 00
    $6B3D  DB  FC 03 F0 0F 01 FF 00 FF 80 FF C3 FC FF FF 00 FF
    $6B4D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 00 00 00 00
    $6B5D  DB  00 FF E0 FF A0 FF 00 FF 00 FF F3 00 FF FF 00 FF
    $6B6D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 00 00 00 00
    $6B7D  DB  50 80 50 80 60 80 60 80 40 80 40 80 28 C0 30 C0
    $6B8D  DB  AF 2F AF 2F 9F 1F 9F 1F BF 3F BF 3F D7 17 CF 0F
    $6B9D  DB  03 00 01 00 01 00 01 00 00 00 00 00 00 00 00 00
    $6BAD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $6BBD  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6BCD  DB  FF FF FF FF FC FC FF FF FF FF FF FF F9 F9 FF FF
    $6BDD  DB  F8 07 F8 07 F1 0E F7 08 F8 07 F1 0E E2 1D C4 3B
    $6BED  DB  87 80 F7 F0 EF E0 E8 E0 20 27 C0 CE C0 DD 80 BB
    $6BFD  DB  00 FF 0F F0 81 7E E0 1F 80 7F C0 3F 3F DF 40 BF
    $6C0D  DB  FF 00 FF 00 FF 00 FF 00 7F 00 3F 00 00 C0 00 80
    $6C1D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6C2D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6C3D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6C4D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6C5D  DB  FF 00 8F 70 9F 60 FF 00 FF 00 FB 04 FF 00 FF 00
    $6C6D  DB  FC 00 8F 00 9F 00 FF 00 FF 00 FB 00 FF 00 FF 00
    $6C7D  DB  70 88 30 C8 40 BF 0F FF 26 99 7F FF 80 7F 7F 80
    $6C8D  DB  77 00 77 00 70 00 7F 00 7F 00 00 00 00 00 00 00
    $6C9D  DB  00 3F 02 03 00 FF FF FF 6C 91 FF FF 00 FF FF 00
    $6CAD  DB  C0 00 FC 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $6CBD  DB  29 6D 03 3B 00 FF FF FF FF 00 FF FF 00 FF FF 00
    $6CCD  DB  92 00 C4 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $6CDD  DB  FF FF 10 CF 00 EF 00 EF 08 E7 03 F4 00 FB C0 3F
    $6CED  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FE 00
    $6CFD  DB  FF FF 00 FF 70 FF 00 FF 80 03 00 1C 03 E3 1C 9F
    $6D0D  DB  FF 00 FF 00 FF 00 FF 00 FC 00 E0 03 83 1C 1F 60
    $6D1D  DB  FF 7F 81 7E 80 03 80 7C 03 83 7C 7F 80 FF 7C FF
    $6D2D  DB  7F 00 7F 00 7C 00 00 03 03 7C 7F 80 FC 00 83 00
    $6D3D  DB  00 FF E0 FF 1F FF E0 FF 1F FF E0 FF 1F FF 00 30
    $6D4D  DB  FF 00 00 00 1F 00 FF 00 E0 00 00 00 00 00 CF 00
    $6D5D  DB  00 FF 0F FF F3 FC 8F 7F F0 FF 0F FF 20 F0 90 FD
    $6D6D  DB  F0 00 0F 00 FF 00 F0 00 00 00 00 00 6F 00 12 00
    $6D7D  DB  00 FF FF FF 0C F3 FF FF 00 FF CF F0 30 CF CF 3F
    $6D8D  DB  00 00 FF 00 FF 00 00 00 00 00 0F 00 30 00 C0 00
    $6D9D  DB  80 FF C0 BF C0 7F 40 FF 60 DF 60 BF 20 3F 30 EF
    $6DAD  DB  7F 00 7F 00 BF 00 BF 00 BF 00 DF 00 DF 00 1F 00
    $6DBD  DB  30 DF 10 FF 10 FF 18 F7 18 EF 08 FF 08 FC 04 FF
    $6DCD  DB  EF 00 EF 00 EF 00 EF 00 F7 00 F7 00 F3 00 F8 00
    $6DDD  DB  04 FF 06 FD 06 FB 02 FF 03 FE 03 FD 01 01 01 FF
    $6DED  DB  FB 00 FB 00 FD 00 FD 00 FD 00 FE 00 FE 00 00 00
    $6DFD  DB  80 FF C0 BF 40 7F 40 FF 40 FF 20 1F 20 3F 20 FF
    $6E0D  DB  7F 00 7F 00 BF 00 BF 00 BF 00 FF 00 DF 00 1F 00
    $6E1D  DB  10 1F 10 DF 11 F9 18 F7 18 EF 08 FF 0C FB 0C F7
    $6E2D  DB  EF 00 EF 00 EE 00 EF 00 F7 00 F7 00 F7 00 FB 00
    $6E3D  DB  80 BC 40 DF 20 EF 10 F7 08 FB 04 FD 02 FE 01 FF
    $6E4D  DB  7F 00 BF 00 DF 00 EF 00 F7 00 FB 00 FD 00 FE 00
    $6E5D  DB  80 FF C0 7F 60 BF 30 DF 18 EF 0C F7 02 03 01 FF
    $6E6D  DB  7F 00 BF 00 DF 00 EF 00 F7 00 FB 00 FD 00 00 00
    $6E7D  DB  E0 DF 78 B7 1E ED 07 FB 01 FE 00 FF 00 00 FF FF
    $6E8D  DB  3F 00 CF 00 F3 00 FC 00 FF 00 FF 00 FF 00 00 00
    $6E9D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6EAD  DB  01 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6EBD  DB  00 FF 00 FF 3F C0 03 FC 00 FF 03 FC 00 FF C0 3F
    $6ECD  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $6EDD  DB  39 FF 56 FF 6A FD 91 FF A2 FF 35 EF 4A FE D4 BC
    $6EED  DB  01 00 07 00 0F 00 1E 00 3C 00 38 00 71 00 E3 00
    $6EFD  DB  8C FF 33 FF CC FC 3C FC E2 FE 41 7F 00 7F 22 5D
    $6F0D  DB  F0 00 C0 00 03 00 03 00 01 00 9C 00 BE 00 BE 00
    $6F1D  DB  03 80 80 FF 50 6F 5F 60 E0 FF E8 F7 2F 30 90 9F
    $6F2D  DB  7F 00 00 00 9F 00 9F 00 00 00 0F 00 CF 00 60 00
    $6F3D  DB  10 EE 22 DD 44 BB 89 76 10 EF 25 DA C0 3F 02 FD
    $6F4D  DB  F1 00 3E 00 C7 00 F9 00 1C 00 E5 00 F9 00 02 00
    $6F5D  DB  65 7E 12 9F 88 6F 22 DD C5 3B 35 CB 45 BB 14 EB
    $6F6D  DB  8D 00 62 00 91 00 E2 00 F4 00 34 00 C4 00 74 00
    $6F7D  DB  BF 78 7F F0 9F E0 67 F8 39 FE 8E FF C1 7F F1 3F
    $6F8D  DB  87 00 0F 00 9F 00 E7 00 79 00 3E 00 89 00 C7 00
    $6F9D  DB  FF CF FF CF FF CF EF D7 CF B7 CF B6 8F 77 07 FB
    $6FAD  DB  CF DF CF CF CF CF D7 D7 B7 B7 B6 B7 77 77 FB FB
    $6FBD  DB  FF 00 FF 00 FF 00 FF 00 EF 10 83 7C 00 FF 00 FF
    $6FCD  DB  00 FE 01 FD 03 F3 0F EF 13 93 7C 7C FF FF FF FF
    $6FDD  DB  FF FF FF FF FF FF C7 FF E3 FF FB FF FF 00 7C 80
    $6FED  DB  FF FF FF FF FF FF FF FF FF FF FF FF FC 00 00 03
    $6FFD  DB  4F BF BF DF BF DF 97 EF CB F7 E9 F7 FF 00 00 00
    $700D  DB  FF BF FF DF FF DF FF EF FF F7 FF F7 00 00 00 FF
    $701D  DB  02 83 8E 79 86 79 8F 70 AC 70 88 70 FF 0F 1F E8
    $702D  DB  FE FE FE 78 FE 70 FC 60 F8 63 F0 67 EF 00 08 00
    $703D  DB  FF FE FF 00 E0 00 00 00 00 00 00 00 FF C0 C0 00
    $704D  DB  FE FE E0 00 00 1F 00 FF 00 FF 00 FF C0 00 00 3F
    $705D  DB  80 00 FF 01 03 00 00 00 00 00 00 00 E0 00 00 00
    $706D  DB  00 7F 01 00 00 FC 00 FF 00 FF 00 FF 00 1F 00 FF
    $707D  DB  00 00 FF FF FF 07 0F 00 07 07 03 03 01 01 03 03
    $708D  DB  00 FF FF 00 07 00 00 F0 07 F8 03 FC 01 FE 03 FC
    $709D  DB  00 C0 47 A7 43 A3 43 83 47 A6 47 86 6B 9C FF 00
    $70AD  DB  7F 3F 7F 1F 7F 3F 7F 3F 7E 3E 7E 3E 7E 1C 00 00
    $70BD  DB  38 80 C0 00 80 00 80 00 00 00 81 80 DF C0 FF 80
    $70CD  DB  C0 47 80 3F 00 7F 00 7F 00 FF 80 7E C1 21 9F 1F
    $70DD  DB  74 9C 2A FA E9 F9 10 FE E0 FF 00 3F 11 2E 1B 35
    $70ED  DB  E3 00 C5 00 06 00 01 00 0E 00 DF 00 DF 00 CE 00
    $70FD  DB  36 6B D5 F7 83 9F 7E FE 00 60 00 BF 53 ED 4C DB
    $710D  DB  9C 00 08 00 60 00 01 00 9F 00 40 00 1E 00 27 00
    $711D  DB  8A 8D 65 66 2E 6F 11 73 20 7D CD F7 56 FB AD 7A
    $712D  DB  73 00 99 00 90 00 8C 00 82 00 18 00 0C 00 87 00
    $713D  DB  00 FF C5 3A 2A D5 C0 FF 7C FF 00 FD 4C B6 32 ED
    $714D  DB  FB 00 C5 00 3A 00 03 00 00 00 02 00 79 00 1E 00
    $715D  DB  85 7B 14 EB 05 FB 22 DD 18 E7 E3 1F 04 FF DA FF
    $716D  DB  85 00 F4 00 04 00 E2 00 18 00 E3 00 04 00 18 00
    $717D  DB  68 9F 9C FF 41 FF 63 FE AF FC 57 F8 AB 7C CB 3E
    $718D  DB  69 00 9E 00 5C 00 61 00 A3 00 17 00 8B 00 C9 00
    $719D  DB  00 00 00 00 00 00 00 00 07 00 FB 04 FF 00 FF 00
    $71AD  DB  00 FF 00 FF 00 FF 00 FF 00 F8 03 07 FF FF FD FD
    $71BD  DB  00 00 00 00 00 00 00 00 FE 00 F9 06 FF 00 FF 00
    $71CD  DB  00 FF 00 FF 00 FF 00 FF 00 01 F8 FE FF FF FF FF
    $71DD  DB  0F 0F 0F 0F 07 07 07 07 0F 0F FF 1F 9F 63 F3 0C
    $71ED  DB  0F F0 0F F0 07 F8 07 F8 0F F0 1F 00 83 E0 F0 FC
    $71FD  DB  03 00 67 E0 4F C0 5F C0 7F C0 3F C0 3F C0 7E 81
    $720D  DB  FC FC FB 7B F7 77 E7 67 CF 4F DE 5E DC 1C 3C 3D
    $721D  DB  FF 00 FD 02 FF 00 FF 00 F7 00 F7 00 E3 00 F3 00
    $722D  DB  67 67 DD DF BB BB 33 33 6A 6A 4A 4A 5C 5C 4C 4C
    $723D  DB  FF 02 BF 46 7B 8A F2 01 F7 10 EF 00 5E 00 5B 02
    $724D  DB  F8 FA B0 F6 64 EE 6C 6D 4B 5B 56 56 A9 A9 A4 A6
    $725D  DB  FF 00 FD 02 FD 02 FF 00 7F 80 FF 40 FE 81 FF 00
    $726D  DB  FF FF FD FF 7C 7E 7E 7E 3E BE 1E 5E 0E 8F 47 47
    $727D  DB  F8 07 F8 07 F8 07 FA 05 FA 05 FD 82 FD 42 FD 42
    $728D  DB  F8 FF F8 FF F8 FF 78 7D 78 7D 3C BE 1C 5E 1C 5E
    $729D  DB  7F 80 7B 80 77 80 77 80 7F 80 67 80 E7 18 04 FB
    $72AD  DB  39 39 35 35 2B 2B 0B 0B 02 02 1A 1A 79 08 00 00
    $72BD  DB  D8 20 7C 80 5E A4 F6 02 62 80 E7 81 D8 00 48 80
    $72CD  DB  17 37 03 83 11 B5 29 23 9D 81 98 81 A7 27 37 37
    $72DD  DB  0A 1B 00 0E 00 FF FF FF F9 00 FF FF 00 FF FF 00
    $72ED  DB  E4 00 F1 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $72FD  DB  C0 CF C1 C1 00 FF FF FF FC 00 FF FF 00 FF FF 00
    $730D  DB  30 00 3E 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $731D  DB  30 FF BF FF 00 FF FF FF 36 89 FF FF 00 FF FF 00
    $732D  DB  00 00 00 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $733D  DB  40 FF 62 E3 00 FF FF FF FF 00 FF FF 00 FF FF 00
    $734D  DB  00 00 1C 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $735D  DB  27 FF D9 F9 00 FF FF FF F9 00 FF FF 00 FF FF 00
    $736D  DB  20 00 C6 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $737D  DB  30 CF CF F0 00 FF FF FF FC 00 FF FF 00 FF FF 00
    $738D  DB  30 00 0F 00 00 00 FF 00 FF 00 00 00 00 00 00 00
    $739D  DB  12 01 05 02 07 00 07 00 07 00 00 00 00 00 00 20
    $73AD  DB  EC ED F9 FB FB FB FB FB F8 F8 FF FF FF FF DF DF
    $73BD  DB  C7 00 8F 00 9C 00 98 00 E0 00 00 00 07 07 00 00
    $73CD  DB  BB 83 70 00 63 03 67 07 1F 1F FF FF F8 FF FF FF
    $73DD  DB  BE 21 9E 11 CF 08 07 04 07 06 07 07 87 87 07 07
    $73ED  DB  4E 6F 66 77 33 3B F9 FD F8 FE F8 FF 78 FF F8 FF
    $73FD  DB  03 00 07 C3 0F C6 0E C4 5E CC 1E CC 5E AC 1F EE
    $740D  DB  FC FC F8 78 F0 70 F1 71 E1 61 E1 61 E1 21 00 00
    $741D  DB  C0 40 90 00 1F 10 00 00 00 00 00 00 00 00 00 00
    $742D  DB  3F 7F 6F 6F E0 F0 FF FF FF FF FF FF FF FF FF FF
    $743D  DB  20 00 E0 A0 80 80 00 00 00 00 00 00 00 00 00 00
    $744D  DB  DF DF 1F BF 7F FF FF FF FF FF FF FF FF FF FF FF
    $745D  DB  06 06 01 01 00 00 00 00 00 00 00 00 00 00 00 00
    $746D  DB  F9 FF FE FF FF FF FF FF FF FF FF FF FF FF FF FF
    $747D  DB  03 03 83 83 03 03 03 03 07 07 07 07 0F 0F 1F 1F
    $748D  DB  FC FF 7C FF FC FF FC FF F8 FF F8 FF F0 FF E0 FF
    $749D  DB  1F CE 5F AF 5F AF 5F 8F 5F AF 4F 87 6F 96 0E F4
    $74AD  DB  60 20 60 00 60 20 60 20 60 20 70 30 70 10 00 01
    $74BD  DB  00 00 80 00 C0 80 F8 98 DF 8F 8F 03 13 0C 19 06
    $74CD  DB  FF FF 7F 7F 3F 3F 07 1F 00 2F 00 73 0C E0 06 E8
    $74DD  DB  00 00 00 00 00 00 0F 0F FF FF FF FF FF FF FF 1F
    $74ED  DB  FF FF FF FF FF FF F0 FF 00 FF 00 FF 00 FF 00 1F
    $74FD  DB  00 00 03 03 3F 3F FF FF FF FF FF FE FE FC FC F0
    $750D  DB  FF FF FC FF C0 FF 00 FF 00 FF 00 FE 00 FD 00 F3
    $751D  DB  7F 7E FF FD FF E1 FF 9B BF 37 7F 6F 7F 5F FF DF
    $752D  DB  80 FE 00 FC 00 E0 18 80 30 40 60 80 40 80 C0 00
    $753D  DB  06 00 04 E0 04 C0 09 C0 4B E2 0A E0 5C B0 0C F0
    $754D  DB  F8 F9 F8 7B F8 7B F0 76 F2 74 F0 75 F0 33 00 03
    $755D  DB  1D 02 1F 00 1F 00 3F 00 3F 10 3F 10 1F 08 0F 00
    $756D  DB  02 EC 00 EE 00 EF 00 CF 00 C7 00 C7 00 E3 00 F3
    $757D  DB  FF 01 FF 3E BD 7E 9A 7C C4 38 E8 10 F8 08 FC 04
    $758D  DB  00 01 00 00 00 00 00 01 00 83 00 C7 08 E7 04 F3
    $759D  DB  FC C8 F9 31 19 11 31 31 23 23 03 02 07 06 0F 0E
    $75AD  DB  08 C3 31 06 11 E6 31 CE 23 DC 02 FC 06 F8 0E F0
    $75BD  DB  FF BF F7 BF EE 7F C4 7F 80 7F 80 7F 80 7F C0 BF
    $75CD  DB  80 00 80 00 00 00 00 00 00 00 00 00 00 00 80 00
    $75DD  DB  08 C0 48 A0 50 A0 50 80 60 80 60 80 60 80 20 C0
    $75ED  DB  70 37 70 17 60 2F 60 2F 40 1F 40 1F 40 1F 00 1F
    $75FD  DB  03 00 01 00 01 00 00 00 00 00 00 00 00 00 10 10
    $760D  DB  00 FD 00 FE 00 FE 00 FF 00 FF 00 FF 00 FF 10 EF
    $761D  DB  FE 02 FF 01 FF 00 FF 00 FF 80 7D 42 7C 43 3E 21
    $762D  DB  02 F9 01 FC 00 FE 00 7F 80 3F 42 9D 43 9C 21 CE
    $763D  DB  0F 0D CF CD EF EF FF 7F FF 30 B9 46 16 E9 09 F6
    $764D  DB  0D F0 CD 30 EF 10 7F 00 30 80 46 81 E9 00 F0 00
    $765D  DB  C0 BF E1 DE FF E1 FF FF FF FE FF 1E DF 24 77 88
    $766D  DB  80 00 C0 00 E1 00 FF 00 FE 00 1E 00 25 C1 89 71
    $767D  DB  28 00 EE C8 DE CC DF CE EF E1 E2 E0 DE 32 16 E2
    $768D  DB  C0 D7 C8 D1 EC E1 EE E0 F1 F0 FD FC F3 30 03 08
    $769D  DB  1C 1C 1F 1F 0F 0F 87 07 FF 80 01 01 00 00 01 01
    $76AD  DB  1C E3 1F E0 0F F0 07 78 80 00 FF 00 FF 00 FF 00
    $76BD  DB  3E 31 BC BB FE F9 FF F8 FE F9 FD 02 3D 3A FF F8
    $76CD  DB  31 C6 BB 40 F9 00 F8 00 F9 00 02 01 FA 01 F8 03
    $76DD  DB  04 FB 1F E0 7E 81 FF 00 FF 00 FF 00 FF 00 FF 00
    $76ED  DB  F8 00 E0 00 81 1E 00 7F 00 FF 00 FF 00 FF 00 FF
    $76FD  DB  BD 42 DF 20 4F B0 27 D8 A3 5C B1 4E 90 6F D8 27
    $770D  DB  42 3C 20 1F B0 0F D8 07 5C 83 4E 81 6F 80 27 C0
    $771D  DB  17 C4 56 A4 56 A4 54 80 74 A0 54 80 64 80 24 C0
    $772D  DB  64 28 64 09 64 29 60 2B 60 2B 60 2B 40 1B 00 1B
    $773D  DB  F0 10 3F 20 0E 06 1E 06 1E 0E 1C 0C 1C 1C 18 18
    $774D  DB  1F 00 20 C0 06 F1 06 E1 0E E1 0C E3 1C E3 18 E7
    $775D  DB  1F 18 FF 00 2F 08 2F 08 2F 08 2F 08 2F 0C 37 04
    $776D  DB  F8 03 00 03 08 D3 08 D3 08 D3 08 D3 0C D1 04 C9
    $777D  DB  FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00
    $778D  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 FF
    $779D  DB  D8 27 D8 27 D8 27 D8 27 D8 27 D4 2B E2 1D E1 1E
    $77AD  DB  27 C0 27 C0 27 C0 27 C0 27 C0 2B C0 1D C0 1E C0
    $77BD  DB  20 C0 22 00 E2 C0 E4 C0 E4 C0 C4 80 C4 80 C4 00
    $77CD  DB  00 1F C0 DD C0 DD C0 DB C0 DB 80 BB 80 BB 80 3B
    $77DD  DB  18 18 18 18 10 10 00 00 00 00 00 00 00 00 00 00
    $77ED  DB  18 E7 18 E7 10 EF 00 FF 00 FF 00 FF 00 FF 00 FF
    $77FD  DB  17 04 17 04 17 04 17 04 16 05 17 06 17 06 17 07
    $780D  DB  04 E9 04 E9 04 E9 04 E9 05 E8 06 E8 06 E8 07 E8
    $781D  DB  FF 00 FF 00 FF 00 F0 0F C0 3F 00 FF 00 FF 80 7F
    $782D  DB  00 FF 00 FF 00 FF 0F F0 3F C0 FF 00 FF 00 7F 00
    $783D  DB  E0 1F A0 5F 10 EF 0C F3 03 FC 00 FF 00 FF 00 FF
    $784D  DB  1F C0 5F 80 EF 00 F3 00 FC 00 FF 00 FF 00 FF 00
    $785D  DB  4C 88 48 80 68 80 68 80 78 A0 4F 80 6C 9B 04 FB
    $786D  DB  08 33 00 37 40 17 40 17 60 27 70 30 78 1B 00 03
    $787D  DB  00 00 00 00 00 00 00 00 00 00 00 00 F8 00 07 F8
    $788D  DB  00 FF 00 FF 00 FF 00 FF 00 FF 00 FF 00 07 00 F8
    $789D  DB  07 07 03 03 03 03 03 03 03 03 03 03 03 03 FF 00
    $78AD  DB  07 F8 03 FC 03 FC 03 FC 03 FC 03 FC 03 FC 00 00
    $78BD  DB  C0 BF F0 8F FC B3 FF DC FF DD FF DF FF 1F 1F E0
    $78CD  DB  BF 00 8F 00 B3 00 DC 00 DD 00 DF 00 1F 00 00 E0
Bank8_VramBlk9_Cat1LZ:  ; $78DD-$7FFF  cat1 asset $0F (LZ; real tiles, + $FF pad)
    $78DD  DB  80 08 1B 13 54 D0 14 D1 14 D2 10 D3 10 D4 10 D5
    $78ED  DB  14 12 14 13 14 14 14 11 14 13 54 12 54 14 54 11
    $78FD  DB  14 14 54 13 14 12 54 11 1B 0D 0B 0B 50 0A 50 09
    $790D  DB  50 1B 12 00 12 14 01 14 D6 14 D7 14 D8 14 D9 14
    $791D  DB  D9 14 D8 54 DA 14 01 14 02 14 20 14 21 14 22 14
    $792D  DB  23 10 24 10 25 10 25 50 24 50 23 50 22 54 21 54
    $793D  DB  20 54 02 14 03 1B 4F 01 09 10 0A 10 0B 10 03 14
    $794D  DB  02 14 02 54 DB 14 DC 14 DD 1B 47 01 1B 48 00 DE
    $795D  DB  1B 3B 01 30 10 31 10 32 10 33 10 34 10 35 10 35
    $796D  DB  50 34 50 33 50 32 50 31 50 30 50 1B 0E 00 1B 24
    $797D  DB  00 1B 34 02 13 14 12 14 12 54 D9 14 9A 50 9A 10
    $798D  DB  1B 48 00 E0 10 E1 10 E2 10 0F 10 0E 50 40 10 41
    $799D  DB  10 42 10 43 10 44 10 45 10 45 50 44 50 43 50 42
    $79AD  DB  50 41 50 40 50 0E 10 0F 50 1B D0 00 0D 50 0D 10
    $79BD  DB  0F 50 0D 50 1B 50 00 9A 10 9A D0 9A 90 36 10 E4
    $79CD  DB  10 E5 10 1E 10 1F 50 1F 10 1E 50 50 10 51 10 52
    $79DD  DB  10 53 10 54 10 55 10 55 50 54 50 53 50 52 50 51
    $79ED  DB  50 50 50 1B 0C 14 1D 50 1D 10 1F 50 1D 50 1B 24
    $79FD  DB  00 9A 90 FD 10 37 10 98 10 E6 10 E7 10 FA 00 1B
    $7A0D  DB  4C 1F 13 FE 10 FF 10 FE 50 03 50 04 10 03 10 E8
    $7A1D  DB  10 A9 D0 A9 10 AA 10 EA 10 EB 1B 4B 1F 16 1B 74
    $7A2D  DB  02 13 50 14 10 13 10 EC 10 ED 10 EE 10 EF 10 F0
    $7A3D  DB  10 0B 1B 4B 1F 16 1B 34 02 02 50 01 10 02 10 F1
    $7A4D  DB  10 F2 10 F3 10 F4 10 F5 10 09 50 1B 8C 1F 1B 12
    $7A5D  DB  50 11 10 12 10 01 10 F6 10 03 10 1B 74 02 1B CC
    $7A6D  DB  1F 1B 1B 7A 12 11 10 F7 10 F8 10 1B 34 02 1B 8C
    $7A7D  DB  1F 1D 38 18 39 18 03 10 04 10 F9 1B 45 2F 20 3A
    $7A8D  DB  18 3B 18 3C 18 3D 18 12 50 14 50 FC 1B 85 2F 1E
    $7A9D  DB  3E 18 3F 18 46 18 47 18 48 18 1B FC 10 03 50 1B
    $7AAD  DB  46 2F 1D 49 18 4A 18 4B 18 4C 18 4D 18 1B 3C 20
    $7ABD  DB  13 1B 85 2F 1E 4E 18 4F 18 56 18 57 18 58 1B BF
    $7ACD  DB  21 01 1B 45 2F 1E 59 18 5A 18 5B 18 5C 18 5D 1B
    $7ADD  DB  FF 21 11 1B 85 2F 1E 5E 18 5F 18 60 18 61 18 62
    $7AED  DB  1B 3F 3F 24 63 18 64 18 65 18 66 18 67 1B 7F 3F
    $7AFD  DB  24 68 18 69 18 6A 18 6B 18 6C 1B BF 3F 24 6D 18
    $7B0D  DB  6E 18 6F 18 70 18 71 1B FF 33 AB 10 0A 50 B5 1B
    $7B1D  DB  8B 1F 18 72 18 73 18 74 18 75 18 76 1B 3F 33 AC
    $7B2D  DB  10 B3 10 B4 1B CB 1F 18 77 18 78 18 79 18 7A 18
    $7B3D  DB  7B 18 AD 10 AE 10 AF 10 B0 10 B1 10 B2 1B 8B 1F
    $7B4D  DB  18 7C 18 7D 18 7E 18 7F 18 80 18 B6 14 B7 10 B8
    $7B5D  DB  10 B9 10 BA 10 BB 10 BC 10 BD 14 BE 14 BF 14 10
    $7B6D  DB  14 10 54 10 94 26 54 13 54 12 1B 15 01 26 14 10
    $7B7D  DB  54 2F 94 10 14 2B 1B BB 01 13 54 2D 14 81 18 82
    $7B8D  DB  18 83 18 84 18 85 18 C0 14 C1 10 C2 10 C3 10 C4
    $7B9D  DB  10 C5 14 C6 14 C7 14 C8 14 C9 14 13 1B 15 00 14
    $7BAD  DB  27 54 99 14 10 14 2F 14 10 94 27 14 1B BA 01 14
    $7BBD  DB  13 54 2C 1B 1D 63 86 18 87 18 88 18 89 18 8A 18
    $7BCD  DB  CA 14 CB 10 CC 14 CD 10 CE 10 CF 10 C6 14 05 1B
    $7BDD  DB  1F 60 54 10 94 1B 1E 60 28 54 9B 14 9C 14 9D 14
    $7BED  DB  9E 14 28 14 0C 1B 1D 62 14 0C 94 2B 1B 25 61 8B
    $7BFD  DB  18 8C 18 8D 18 8E 18 8F 18 06 14 07 14 C6 1B 83
    $7C0D  DB  65 08 1B 65 61 0C 54 10 54 9F 14 A0 14 A1 14 A2
    $7C1D  DB  14 A2 14 A3 14 A4 14 29 1B 6B 61 2F D4 10 14 10
    $7C2D  DB  D4 2B 14 2F D4 90 18 91 18 92 18 93 18 94 18 15
    $7C3D  DB  14 16 1B 83 65 17 14 18 14 19 1B 13 61 13 14 A5
    $7C4D  DB  14 A6 1B 9D 61 9A 54 9A 14 A7 14 A8 1B 0F 01 1B
    $7C5D  DB  1E 00 1B D4 60 2C 14 1C 18 2E 18 95 18 96 18 97
    $7C6D  DB  18 FB 1B FF 6F 4D 1B 1F 7F 0C 1B A0 FF 4D 1B DF
    $7C7D  DB  FF 0E 38 00 00 65 00 4C 01 AE 05 12 0E 76 1A 1C
    $7C8D  DB  2F 0A 01 C6 14 28 3D AC 4D 8C 56 F1 6A 5C 01 C6
    $7C9D  DB  14 1B 00 82 A6 00 C7 00 0A 01 6F 05 78 12 1C 2F
    $7CAD  DB  1B 12 86 E7 01 CC 12 1B 00 82 C6 14 AC 4D 1B 2A
    $7CBD  DB  80 00 35 A0 45 7D 06 55 46 FB 29 BD 46 7C 6F 1B
    $7CCD  DB  0A 80 00 38 1F 00 1B 62 8F 09 FF FF FF FF FF FF
    $7CDD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7CED  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7CFD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D0D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D1D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D2D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D3D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D4D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D5D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D6D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D7D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D8D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7D9D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DAD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DBD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DCD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DDD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DED  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7DFD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E0D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E1D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E2D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E3D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E4D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E5D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E6D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E7D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E8D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7E9D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7EAD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7EBD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7ECD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7EDD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7EED  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7EFD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F0D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F1D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F2D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F3D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F4D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F5D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F6D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F7D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F8D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7F9D  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FAD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FBD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FCD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FDD  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FED  DB  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
    $7FFD  DB  FF FF FF

; end of bank 8
