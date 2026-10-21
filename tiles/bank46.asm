; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 46 ($2E)  — COMPRESSED TILE-GRAPHICS DATA
; ==========================================================================
;
; CORRECTION (was mislabeled "Audio data bank"): this bank is NOT audio.
; It is a COMPRESSED TILE-GRAPHICS data bank, loaded into VRAM by the ROM0
; tile decompressor TileLoad ($18A2) / SafeTileLoad ($194A).  The earlier
; "audio" reading mistook the `LD D,$2E / LD E,idx / CALL $18A2` convention
; for an audio dispatch — but $18A2 is the tile loader, and its callers pass
; VRAM destinations (HL = $8Dxx, $9000, $85xx, $8800, ...).  Decoding block 0
; yields valid 2bpp tiles (the tell-tale `XX FF` bitplane rows), confirming
; graphics, not sound.
;
; Access convention (see rom0_vblank_callees.asm : TileLoad):
;   ; caller sets D = $2E (bank 46), E = block index, HL = VRAM dest
;   LD D, $2E
;   LD E, <block_index>
;   LD HL, <vram_dest>
;   CALL $18A2   ; (or $194A for the HBlank-safe variant)
;
; $19FA (TileLoad_Setup) then:
;   1. Switch MBC1 to bank D ($2E = 46).
;   2. Look up block E in the pointer table at $4001 + E*2  → data pointer.
;   3. Read the 3-byte block header:
;        byte 0 (→ C)  : output byte count lo
;        byte 1 (→ B)  : output byte count hi   → BC = VRAM bytes (count/16 tiles)
;        byte 2        : escape byte (LZ back-ref marker, stored to $FFAB)
;   4. Decompress the token stream into VRAM at HL (LZ, dictionary = the
;      output buffer itself). See the full format doc at TileLoad in
;      rom0_vblank_callees.asm.
;
; Known callers (D=$2E; the low byte of the DE "source ID" = block index):
;   bank1 $430F : LD DE,$2E00           → block $00 to VRAM
;   bank9       : blocks $0E,$0F,$11,$1E,$1F,$20 and $15..$1C → $85xx/$86xx/$88xx
;   bank7       : blocks $0D,$15..$1C   → $9000 / $85xx..$86xx
;   bank1       : block $1D             → $8180
;   (the bank1 "$4Bxx SFX index" notes below were the audio misreading.)
;
; File offset: $B8000-$BBFFF  (16 KB), mapped at $4000-$7FFF when MBC=46 ($2E).
; Sibling tile/graphics banks: $2F, $3F, $5B (battle), $38-$3A (monster sprites).
; (NB: $12 is NOT a tile bank — "LD DE,$1202;CALL $0D7C" is a VRAM pattern-fill.)
; NOTE: block labels below still carry legacy audio-era names (Bank46_BGM_*,
; _Track*, _SFX_*); they are compressed TILE blocks. The DB bytes are correct.
; ==========================================================================

SECTION "Bank 46", ROMX[$4000], BANK[46]

; --------------------------------------------------------------------------
; Bank ID byte + tile-block pointer table
; Each DW is the ROM address of one compressed tile block (index = E arg to
; TileLoad).  These are TILE blocks, not audio; legacy labels kept for now.
; --------------------------------------------------------------------------
Bank46_ID:
    DB $2E  ; bank self-ID = $2E = 46
Bank46_TilePtrTable:
    DW $404D  ; block $00 → tiles @ $404D (count=$0300=48 tiles, escape=$01)
    DW $4213  ; fn 1 → Bank46_Track1 ($4213)
    DW $4235  ; fn 2 → Bank46_Track2 ($4235)
    DW $4252  ; fn 3 → Bank46_SFX_03 ($4252)
    DW $4265  ; fn 4 → Bank46_SFX_04 ($4265)
    DW $4278  ; fn 5 → Bank46_SFX_05 ($4278)
    DW $428B  ; fn 6 → Bank46_SFX_06 ($428B)
    DW $429E  ; fn 7 → Bank46_SFX_07 ($429E)
    DW $42B1  ; fn 8 → Bank46_SFX_08 ($42B1)
    DW $42C4  ; fn 9 → Bank46_SFX_09 ($42C4)
    DW $42D7  ; fn10 → Bank46_SFX_0A ($42D7)
    DW $42EA  ; fn11 → Bank46_SFX_0B ($42EA)
    DW $42FD  ; fn12 → Bank46_SFX_0C ($42FD)
    DW $4310  ; fn13 → Bank46_BGM_13 ($4310)
    DW $45BD  ; fn14 → Bank46_BGM_14 ($45BD)
    DW $4665  ; fn15 → Bank46_BGM_15 ($4665)
    DW $46C4  ; fn16 → Bank46_BGM_16 ($46C4)
    DW $483A  ; fn17 → Bank46_BGM_17 ($483A)
    DW $492D  ; fn18 → Bank46_BGM_18 ($492D)
    DW $4A68  ; fn19 → Bank46_BGM_19 ($4A68)
    DW $4B5B  ; fn20 → Bank46_BGM_20 ($4B5B)
    DW $4CE0  ; fn21 → Bank46_Track21 ($4CE0)
    DW $4D1B  ; fn22 → Bank46_Track22 ($4D1B)
    DW $4D5D  ; fn23 → Bank46_Track23 ($4D5D)
    DW $4D97  ; fn24 → Bank46_Track24 ($4D97)
    DW $4DC8  ; fn25 → Bank46_Track25 ($4DC8)
    DW $4E0A  ; fn26 → Bank46_Track26 ($4E0A)
    DW $4E44  ; fn27 → Bank46_Track27 ($4E44)
    DW $4E82  ; fn28 → Bank46_Track28 ($4E82)
    DW $4EB3  ; fn29 → Bank46_BGM_29 ($4EB3)
    DW $4F12  ; fn30 → Bank46_BGM_30 ($4F12)
    DW $5380  ; fn31 → Bank46_BGM_31 ($5380)
    DW $54C8  ; fn32 → Bank46_Track32 ($54C8)
    DW $54DB  ; fn33 → Bank46_BGM_33 ($54DB)
    DW $55BF  ; fn34 → Bank46_Track34 ($55BF)
    DW $55FB  ; fn35 → Bank46_BGM_35 ($55FB)
    DW $571E  ; fn36 → Bank46_Null_36 ($571E)
    DW $671E  ; fn37 → Bank46_Track37 ($671E)

; --------------------------------------------------------------------------
; Bank46_block00 — compressed TILE block (index $00)
; Decompresses to 768 VRAM bytes = 48 tiles (verified). First token is a
; back-ref into empty output -> 4 blank tiles, then literal/back-ref mix.
; Header: BC=output_count=$0300 (768d), escape=$01
; Size: 454 bytes  (block spans $404D..$4213)
; --------------------------------------------------------------------------
Bank46_block00:
    DB $00, $03  ; output_count = $0300 (768d = 48 tiles) [lo, hi]
    DB $01          ; escape byte (LZ back-ref marker, stored to $FFAB)
    ; token stream (451 bytes follow)
    DB $01,$FF,$FF,$2D,$FF,$00,$FF,$08,$FF,$BE,$FF,$84,$FF,$84,$FF,$9C  ; $4050
    DB $FF,$A6,$FF,$5A,$FF,$01,$3F,$00,$84,$FF,$82,$FF,$82,$FF,$A2,$FF  ; $4060
    DB $60,$FF,$20,$FF,$00,$FF,$30,$FF,$18,$FF,$64,$FF,$08,$FF,$30,$FF  ; $4070
    DB $48,$FF,$8E,$FF,$00,$FF,$1C,$FF,$22,$FF,$5D,$01,$76,$01,$22,$FF  ; $4080
    DB $1C,$FF,$00,$FF,$3E,$FF,$7F,$FF,$49,$FF,$49,$FF,$77,$FF,$3E,$FF  ; $4090
    DB $2A,$01,$70,$01,$36,$FF,$63,$FF,$77,$FF,$36,$FF,$3E,$FF,$3E,$01  ; $40A0
    DB $10,$0F,$20,$78,$FF,$84,$FF,$80,$FF,$9E,$FF,$84,$FF,$8C,$FF,$74  ; $40B0
    DB $FF,$00,$FF,$20,$01,$E2,$07,$3E,$FF,$00,$01,$56,$01,$01,$57,$00  ; $40C0
    DB $44,$FF,$28,$FF,$10,$01,$50,$01,$01,$01,$1A,$42,$01,$12,$11,$7E  ; $40D0
    DB $01,$12,$13,$01,$F1,$00,$C6,$FF,$AA,$FF,$92,$01,$F2,$03,$00,$FF  ; $40E0
    DB $7C,$01,$12,$11,$7C,$FF,$40,$01,$3A,$11,$00,$FF,$18,$FF,$18,$01  ; $40F0
    DB $50,$01,$01,$43,$14,$02,$FF,$04,$FF,$08,$FF,$10,$FF,$20,$FF,$40  ; $4100
    DB $FF,$80,$FF,$00,$FF,$10,$FF,$92,$FF,$54,$FF,$38,$FF,$54,$FF,$92  ; $4110
    DB $01,$FE,$01,$18,$FF,$1C,$FF,$FE,$FF,$FF,$FF,$FE,$FF,$1C,$01,$44  ; $4120
    DB $11,$70,$FF,$78,$FF,$7C,$FF,$7E,$FF,$7C,$FF,$78,$FF,$70,$01,$80  ; $4130
    DB $11,$48,$FF,$44,$FF,$42,$FF,$44,$FF,$48,$01,$8E,$11,$00,$FF,$FF  ; $4140
    DB $FF,$81,$FF,$81,$FF,$C3,$FF,$E7,$01,$44,$13,$01,$A3,$10,$FF,$01  ; $4150
    DB $00,$13,$60,$01,$C0,$11,$7F,$FF,$7F,$01,$C0,$13,$06,$01,$D0,$11  ; $4160
    DB $FE,$FF,$FE,$01,$D0,$13,$01,$01,$16,$01,$B7,$14,$01,$B7,$16,$01  ; $4170
    DB $01,$12,$3C,$01,$12,$13,$01,$13,$10,$3C,$01,$60,$11,$30,$FF,$10  ; $4180
    DB $01,$16,$23,$38,$01,$00,$23,$44,$01,$56,$13,$7E,$FF,$00,$FF,$7E  ; $4190
    DB $01,$52,$11,$3C,$FF,$02,$01,$0C,$23,$04,$FF,$0C,$FF,$14,$FF,$24  ; $41A0
    DB $FF,$44,$FF,$7E,$FF,$04,$01,$30,$21,$01,$3B,$10,$7C,$01,$3A,$25  ; $41B0
    DB $3C,$01,$54,$23,$01,$0B,$24,$01,$19,$12,$01,$55,$10,$01,$7B,$20  ; $41C0
    DB $01,$01,$24,$01,$83,$24,$01,$01,$24,$3E,$01,$52,$11,$01,$1F,$20  ; $41D0
    DB $1F,$FF,$3F,$FF,$70,$01,$C0,$13,$60,$FF,$00,$FF,$F8,$FF,$FC,$FF  ; $41E0
    DB $0E,$01,$D0,$13,$06,$01,$A8,$25,$70,$FF,$3F,$FF,$1F,$FF,$00,$01  ; $41F0
    DB $B8,$25,$0E,$FF,$FC,$FF,$F8,$01,$BE,$15,$01,$E1,$26,$01,$B9,$24  ; $4200
    DB $01,$B9,$23  ; $4210

; --------------------------------------------------------------------------
; Bank46_block01 — compressed TILE block (index $01)
; Decompresses to 64 VRAM bytes = 4 tiles.
; Header: BC=output_count=$0040 (64d), escape=$01
; Size: 34 bytes  (block spans $4213..$4235)
; --------------------------------------------------------------------------
Bank46_block01:
    DB $40, $00  ; output_count = $0040 (64d = 4 tiles) [lo, hi]
    DB $01          ; escape byte (LZ back-ref marker, stored to $FFAB)
    ; token stream (31 bytes follow)
    DB $DA,$DE,$DF,$E4,$F9,$F9,$E0,$DB,$01,$01,$02,$DC,$01,$01,$01,$01  ; $4216
    DB $F4,$F8,$E0,$E1,$E3,$F9,$F9,$F9,$E0,$01,$20,$09,$01,$A0,$F8  ; $4226

; --------------------------------------------------------------------------
; Bank46_fn2 — Track2
; audio sequence track 2 (short, 64-frame)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 29 bytes  ($7FFF limit: up to $4252)
; --------------------------------------------------------------------------
Bank46_Track2:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (26 bytes follow)
    DB $DA,$E2,$E3,$F9,$F9,$F9,$E0,$DB,$01,$01,$02,$DC,$01,$01,$01,$01  ; $4238
    DB $F4,$F8,$E0,$01,$20,$0F,$00,$01,$A0,$F8  ; $4248

; --------------------------------------------------------------------------
; Bank46_fn3 — SFX_03
; SFX slot 3; bank1 SFX table index $47 ($4BAC)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $4265)
; --------------------------------------------------------------------------
Bank46_SFX_03:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$10,$FF,$10,$EF,$38,$EF,$54,$FF,$AA,$AB,$D6,$83,$FE,$FF,$7C  ; $4255

; --------------------------------------------------------------------------
; Bank46_fn4 — SFX_04
; SFX slot 4; bank1 SFX table index $48 ($4BAE)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $4278)
; --------------------------------------------------------------------------
Bank46_SFX_04:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $F7,$0E,$FF,$0C,$FF,$1E,$F7,$EC,$FF,$FE,$FF,$AE,$FF,$1C,$EF,$70  ; $4268

; --------------------------------------------------------------------------
; Bank46_fn5 — SFX_05
; SFX slot 5; bank1 SFX table index $49 ($4BB0)
; Header: BC=frame_count=$0010 (16d), sentinel=$01
; Size: 19 bytes  ($7FFF limit: up to $428B)
; --------------------------------------------------------------------------
Bank46_SFX_05:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$00,$FF,$18,$FF,$DB,$FF,$C3,$FF,$3C,$FF,$7E,$FF,$7E,$FF,$3C  ; $427B

; --------------------------------------------------------------------------
; Bank46_fn6 — SFX_06
; SFX slot 6; bank1 SFX table index $4A ($4BB2)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $429E)
; --------------------------------------------------------------------------
Bank46_SFX_06:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$06,$FD,$0B,$FF,$16,$FD,$23,$E7,$56,$BB,$C6,$F3,$B0,$FF,$C0  ; $428E

; --------------------------------------------------------------------------
; Bank46_fn7 — SFX_07
; SFX slot 7; bank1 SFX table index $4B ($4BB4)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $42B1)
; --------------------------------------------------------------------------
Bank46_SFX_07:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$18,$E7,$24,$E7,$24,$C3,$42,$D3,$52,$F7,$76,$FF,$18,$DB,$18  ; $42A1

; --------------------------------------------------------------------------
; Bank46_fn8 — SFX_08
; SFX slot 8; bank1 SFX table index $4C ($4BB6)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $42C4)
; --------------------------------------------------------------------------
Bank46_SFX_08:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $BB,$82,$FF,$44,$FF,$28,$FF,$7C,$BB,$FE,$D7,$92,$FF,$FE,$FF,$7C  ; $42B4

; --------------------------------------------------------------------------
; Bank46_fn9 — SFX_09
; SFX slot 9; bank1 SFX table index $4D ($4BB8)
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $42D7)
; --------------------------------------------------------------------------
Bank46_SFX_09:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$18,$FF,$36,$EB,$2A,$F7,$15,$EB,$2B,$DF,$56,$BF,$A0,$FF,$C0  ; $42C7

; --------------------------------------------------------------------------
; Bank46_fn10 — SFX_0A
; SFX slot 10; bank1 SFX table index $4E ($4BBA)
; Header: BC=frame_count=$0010 (16d), sentinel=$01
; Size: 19 bytes  ($7FFF limit: up to $42EA)
; --------------------------------------------------------------------------
Bank46_SFX_0A:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$00,$FF,$7C,$FF,$FE,$FF,$92,$FF,$EE,$FF,$FE,$FF,$54,$FF,$38  ; $42DA

; --------------------------------------------------------------------------
; Bank46_fn11 — SFX_0B
; SFX slot 11; bank1 SFX table index $4F ($4BBC)
; Header: BC=frame_count=$0010 (16d), sentinel=$01
; Size: 19 bytes  ($7FFF limit: up to $42FD)
; --------------------------------------------------------------------------
Bank46_SFX_0B:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$00,$FF,$7C,$C7,$C6,$EF,$AA,$AB,$82,$D7,$D6,$AB,$AA,$FF,$7C  ; $42ED

; --------------------------------------------------------------------------
; Bank46_fn12 — SFX_0C
; SFX slot 12; bank1 SFX table index $50 ($4BBE), also $43A7
; Header: BC=frame_count=$0010 (16d), sentinel=$00
; Size: 19 bytes  ($7FFF limit: up to $4310)
; --------------------------------------------------------------------------
Bank46_SFX_0C:
    DB $10, $00  ; frame_count = $0010 (16d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $BB,$7C,$7D,$C6,$FF,$BA,$7D,$F6,$BB,$6C,$D7,$38,$FF,$28,$D7,$38  ; $4300

; --------------------------------------------------------------------------
; Bank46_fn13 — BGM_13
; long BGM track (928 frames); bank46 BGM A
; Header: BC=frame_count=$03A0 (928d), sentinel=$01
; Size: 685 bytes  ($7FFF limit: up to $45BD)
; --------------------------------------------------------------------------
Bank46_BGM_13:
    DB $A0, $03  ; frame_count = $03A0 (928d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (682 bytes follow)
    DB $FF,$01,$FF,$F0,$3C,$FF,$C2,$FF,$02,$FF,$02,$FF,$04,$FF,$38,$FF  ; $4313
    DB $00,$FF,$20,$FF,$16,$FF,$18,$FF,$10,$FF,$78,$FF,$94,$FF,$62,$01  ; $4323
    DB $10,$01,$1E,$FF,$F8,$FF,$04,$FF,$0C,$FF,$40,$FF,$3C,$FF,$05,$FF  ; $4333
    DB $45,$FF,$44,$FF,$38,$FF,$60,$FF,$80,$FF,$82,$FF,$7C,$FF,$00,$01  ; $4343
    DB $0E,$01,$3C,$FF,$42,$01,$0A,$03,$05,$FF,$0D,$FF,$30,$FF,$60,$FF  ; $4353
    DB $C0,$FF,$20,$FF,$10,$FF,$08,$FF,$00,$FF,$40,$01,$34,$0B,$08,$01  ; $4363
    DB $54,$09,$05,$FF,$25,$FF,$F8,$FF,$12,$FF,$7C,$FF,$08,$FF,$80,$01  ; $4373
    DB $6E,$03,$4A,$FF,$FC,$FF,$48,$FF,$48,$FF,$42,$FF,$3C,$FF,$00,$FF  ; $4383
    DB $10,$FF,$10,$FF,$20,$FF,$30,$FF,$68,$FF,$4A,$FF,$8C,$01,$60,$01  ; $4393
    DB $01,$B3,$00,$44,$01,$B8,$01,$01,$0F,$00,$01,$71,$00,$4C,$FF,$5A  ; $43A3
    DB $FF,$6A,$FF,$4C,$FF,$10,$FF,$05,$FF,$15,$FF,$E4,$FF,$26,$01,$B8  ; $43B3
    DB $01,$48,$FF,$30,$01,$60,$01,$3C,$01,$5E,$01,$01,$3B,$02,$01,$D1  ; $43C3
    DB $00,$90,$FF,$BC,$FF,$88,$01,$F8,$01,$50,$FF,$00,$FF,$24,$01,$84  ; $43D3
    DB $0B,$20,$FF,$28,$FF,$F4,$FF,$2A,$FF,$4A,$FF,$88,$01,$DE,$01,$08  ; $43E3
    DB $FF,$FE,$FF,$18,$FF,$28,$FF,$28,$FF,$18,$FF,$30,$01,$F0,$07,$98  ; $43F3
    DB $FF,$AC,$FF,$54,$FF,$00,$FF,$30,$FF,$8C,$FF,$52,$FF,$E2,$FF,$24  ; $4403
    DB $01,$A2,$01,$01,$FF,$F0,$38,$FF,$54,$FF,$92,$FF,$92,$FF,$A2,$FF  ; $4413
    DB $64,$01,$10,$01,$20,$FF,$22,$01,$66,$11,$24,$01,$4E,$01,$05,$FF  ; $4423
    DB $20,$FF,$50,$FF,$88,$FF,$04,$FF,$02,$01,$00,$01,$50,$01,$82,$11  ; $4433
    DB $52,$FF,$52,$FF,$54,$FF,$98,$FF,$00,$FF,$7C,$FF,$10,$01,$92,$11  ; $4443
    DB $70,$FF,$98,$FF,$64,$01,$70,$11,$01,$25,$10,$01,$63,$10,$20,$FF  ; $4453
    DB $1C,$01,$A0,$01,$7E,$FF,$12,$FF,$22,$FF,$42,$FF,$14,$01,$5E,$01  ; $4463
    DB $20,$FF,$7C,$FF,$20,$FF,$5C,$FF,$62,$FF,$82,$01,$9E,$01,$24,$FF  ; $4473
    DB $FA,$FF,$22,$FF,$7C,$FF,$A2,$01,$5C,$13,$FE,$01,$0A,$01,$28,$01  ; $4483
    DB $5C,$01,$04,$FF,$00,$FF,$FC,$FF,$04,$FF,$08,$FF,$10,$FF,$28,$FF  ; $4493
    DB $44,$FF,$82,$FF,$00,$FF,$3E,$FF,$22,$FF,$62,$FF,$92,$FF,$0C,$FF  ; $44A3
    DB $08,$FF,$70,$01,$00,$01,$01,$FF,$F0,$FE,$01,$10,$25,$10,$01,$D4  ; $44B3
    DB $0B,$01,$11,$00,$1C,$FF,$10,$FF,$30,$FF,$58,$FF,$24,$01,$30,$01  ; $44C3
    DB $01,$B5,$08,$05,$FF,$4D,$FF,$F0,$FF,$46,$FF,$5A,$FF,$40,$FF,$90  ; $44D3
    DB $FF,$8E,$01,$10,$01,$F6,$FF,$2A,$FF,$32,$FF,$64,$FF,$A4,$FF,$22  ; $44E3
    DB $01,$60,$01,$8E,$FF,$90,$FF,$80,$FF,$80,$FF,$D0,$FF,$4E,$01,$14  ; $44F3
    DB $23,$01,$A7,$18,$01,$89,$00,$01,$47,$00,$9A,$FF,$24,$FF,$18,$FF  ; $4503
    DB $00,$01,$CC,$01,$26,$FF,$78,$01,$A2,$01,$0C,$01,$A0,$21,$E2,$FF  ; $4513
    DB $48,$FF,$44,$FF,$9C,$FF,$A4,$FF,$9A,$01,$A0,$01,$4C,$FF,$40,$FF  ; $4523
    DB $BC,$FF,$C2,$01,$CC,$11,$05,$FF,$5F,$FF,$84,$FF,$9E,$FF,$84,$FF  ; $4533
    DB $AC,$FF,$D6,$FF,$5A,$01,$A0,$01,$01,$F5,$0A,$01,$A1,$02,$01,$93  ; $4543
    DB $10,$10,$FF,$01,$EF,$FF,$01,$01,$79,$20,$80,$FF,$8A,$FF,$8A,$FF  ; $4553
    DB $84,$FF,$F4,$FF,$00,$FF,$E0,$01,$78,$21,$EA,$FF,$84,$FF,$84,$FF  ; $4563
    DB $EA,$01,$40,$11,$50,$FF,$48,$01,$78,$11,$01,$7B,$10,$01,$D1,$00  ; $4573
    DB $01,$B5,$12,$22,$FF,$44,$01,$8E,$11,$00,$FF,$C2,$FF,$32,$01,$0A  ; $4583
    DB $01,$01,$0D,$22,$01,$89,$00,$10,$01,$46,$03,$1C,$01,$50,$01,$01  ; $4593
    DB $95,$0A,$08,$FF,$88,$FF,$7C,$FF,$52,$FF,$B2,$FF,$A2,$01,$3E,$11  ; $45A3
    DB $01,$03,$10,$01,$D7,$10,$92,$01,$22,$00  ; $45B3

; --------------------------------------------------------------------------
; Bank46_fn14 — BGM_14
; long BGM track (768 frames); bank46 BGM B
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 168 bytes  ($7FFF limit: up to $4665)
; --------------------------------------------------------------------------
Bank46_BGM_14:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (165 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$BF,$0F,$4D,$01,$1F,$1F,$4D  ; $45C0
    DB $01,$7F,$1F,$4D,$01,$DF,$1F,$4D,$FF,$00,$FF,$20,$FF,$28,$FF,$F4  ; $45D0
    DB $FF,$2A,$FF,$4A,$FF,$88,$FF,$30,$FF,$00,$FF,$38,$FF,$00,$FF,$3C  ; $45E0
    DB $FF,$42,$FF,$02,$FF,$04,$01,$52,$21,$20,$FF,$48,$FF,$44,$FF,$64  ; $45F0
    DB $FF,$44,$FF,$08,$FF,$10,$FF,$00,$FF,$40,$FF,$8E,$FF,$90,$FF,$80  ; $4600
    DB $FF,$80,$FF,$D0,$FF,$4E,$FF,$00,$FF,$24,$FF,$F8,$FF,$12,$FF,$7C  ; $4610
    DB $FF,$08,$FF,$80,$FF,$7C,$FF,$00,$FF,$48,$FF,$F0,$FF,$46,$FF,$5A  ; $4620
    DB $FF,$40,$FF,$90,$FF,$8E,$FF,$00,$FF,$30,$FF,$8C,$FF,$52,$FF,$E2  ; $4630
    DB $FF,$24,$FF,$10,$01,$6E,$21,$08,$FF,$88,$FF,$7C,$FF,$52,$FF,$B2  ; $4640
    DB $FF,$A2,$FF,$54,$FF,$00,$01,$88,$21,$01,$57,$20,$9A,$FF,$24,$FF  ; $4650
    DB $18,$01,$E0,$1F,$1D  ; $4660

; --------------------------------------------------------------------------
; Bank46_fn15 — BGM_15
; long BGM track (768 frames); bank46 BGM C
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 95 bytes  ($7FFF limit: up to $46C4)
; --------------------------------------------------------------------------
Bank46_BGM_15:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (92 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$BF,$0F,$4D,$01,$1F,$1F,$4D  ; $4668
    DB $01,$7F,$1F,$4D,$01,$DF,$1F,$4D,$01,$3F,$2F,$4D,$01,$60,$2F,$0D  ; $4678
    DB $FF,$00,$FF,$24,$FF,$F8,$FF,$24,$FF,$7C,$FF,$AA,$FF,$B2,$FF,$54  ; $4688
    DB $FF,$05,$FF,$0D,$FF,$FE,$FF,$18,$FF,$28,$FF,$28,$FF,$18,$FF,$30  ; $4698
    DB $FF,$00,$FF,$20,$FF,$28,$FF,$F4,$FF,$2A,$FF,$4A,$FF,$88,$01,$DE  ; $46A8
    DB $23,$48,$FF,$44,$FF,$64,$FF,$44,$FF,$08,$FF,$10  ; $46B8

; --------------------------------------------------------------------------
; Bank46_fn16 — BGM_16
; long BGM track (768 frames); bank46 BGM D
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 374 bytes  ($7FFF limit: up to $483A)
; --------------------------------------------------------------------------
Bank46_BGM_16:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (371 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$A0,$0F,$2D,$FF,$00,$FF,$24  ; $46C7
    DB $FF,$F8,$FF,$24,$FF,$7C,$FF,$AA,$FF,$B2,$FF,$54,$FF,$05,$FF,$0D  ; $46D7
    DB $FF,$FE,$FF,$18,$FF,$28,$FF,$28,$FF,$18,$FF,$30,$FF,$00,$FF,$10  ; $46E7
    DB $FF,$90,$FF,$BC,$FF,$88,$01,$28,$11,$50,$FF,$00,$FF,$40,$FF,$8E  ; $46F7
    DB $FF,$90,$FF,$80,$FF,$80,$FF,$D0,$FF,$4E,$01,$00,$13,$12,$FF,$7C  ; $4707
    DB $FF,$08,$FF,$80,$FF,$7C,$FF,$00,$FF,$48,$FF,$F0,$FF,$46,$FF,$5A  ; $4717
    DB $FF,$40,$FF,$90,$FF,$8E,$FF,$00,$FF,$A0,$FF,$74,$FF,$22,$FF,$60  ; $4727
    DB $FF,$A2,$FF,$E2,$FF,$3C,$FF,$00,$FF,$20,$FF,$28,$FF,$F4,$FF,$2A  ; $4737
    DB $FF,$4A,$FF,$88,$01,$1E,$11,$20,$FF,$16,$FF,$18,$FF,$10,$FF,$78  ; $4747
    DB $FF,$94,$FF,$62,$FF,$00,$FF,$38,$FF,$00,$FF,$3C,$FF,$42,$FF,$02  ; $4757
    DB $FF,$04,$01,$92,$11,$08,$01,$14,$1B,$01,$03,$10,$22,$FF,$7C,$FF  ; $4767
    DB $92,$FF,$20,$FF,$1E,$FF,$00,$FF,$70,$FF,$10,$FF,$14,$FF,$7C,$FF  ; $4777
    DB $A6,$FF,$A4,$FF,$48,$FF,$00,$01,$48,$11,$01,$97,$10,$9A,$FF,$24  ; $4787
    DB $FF,$18,$01,$70,$11,$2C,$FF,$F2,$FF,$22,$FF,$62,$FF,$A2,$FF,$2C  ; $4797
    DB $01,$70,$11,$F6,$FF,$2A,$FF,$32,$FF,$64,$FF,$A4,$FF,$22,$FF,$05  ; $47A7
    DB $FF,$4D,$01,$54,$1B,$7C,$FF,$10,$01,$12,$21,$70,$FF,$98,$FF,$64  ; $47B7
    DB $01,$70,$11,$F8,$FF,$20,$FF,$FC,$FF,$20,$FF,$22,$FF,$1C,$FF,$01  ; $47C7
    DB $FF,$00,$38,$FF,$54,$FF,$92,$FF,$92,$FF,$A2,$01,$1E,$21,$3E,$01  ; $47D7
    DB $E8,$11,$92,$FF,$0C,$FF,$08,$FF,$70,$FF,$00,$FF,$FE,$01,$9A,$11  ; $47E7
    DB $28,$FF,$10,$FF,$08,$FF,$04,$FF,$05,$FF,$05,$FF,$7E,$FF,$02,$01  ; $47F7
    DB $66,$23,$7E,$FF,$00,$FF,$30,$FF,$8C,$FF,$52,$FF,$E2,$FF,$24,$FF  ; $4807
    DB $10,$FF,$10,$01,$A0,$11,$88,$FF,$7C,$FF,$52,$FF,$B2,$FF,$A2,$FF  ; $4817
    DB $54,$01,$20,$11,$10,$FF,$20,$FF,$30,$FF,$68,$FF,$4A,$FF,$8C,$01  ; $4827
    DB $A0,$0F,$4D  ; $4837

; --------------------------------------------------------------------------
; Bank46_fn17 — BGM_17
; long BGM track (768 frames); bank46 BGM E
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 243 bytes  ($7FFF limit: up to $492D)
; --------------------------------------------------------------------------
Bank46_BGM_17:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (240 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$A0,$0F,$2D,$FF,$00,$FF,$3E  ; $483D
    DB $FF,$22,$FF,$22,$FF,$42,$FF,$04,$FF,$08,$FF,$30,$FF,$00,$FF,$7C  ; $484D
    DB $FF,$00,$FF,$FE,$FF,$02,$FF,$02,$FF,$04,$FF,$78,$FF,$05,$FF,$4D  ; $485D
    DB $FF,$F0,$FF,$46,$FF,$5A,$FF,$40,$FF,$90,$FF,$8E,$FF,$00,$FF,$20  ; $486D
    DB $FF,$F6,$FF,$2A,$FF,$32,$FF,$64,$FF,$A4,$FF,$22,$FF,$00,$FF,$24  ; $487D
    DB $FF,$F8,$FF,$22,$FF,$7C,$FF,$92,$FF,$20,$FF,$1E,$FF,$01,$FF,$00  ; $488D
    DB $3C,$FF,$C2,$01,$18,$13,$38,$01,$30,$11,$16,$FF,$18,$FF,$10,$FF  ; $489D
    DB $78,$FF,$94,$FF,$62,$01,$30,$11,$1E,$FF,$F8,$FF,$04,$FF,$0C,$FF  ; $48AD
    DB $40,$FF,$3C,$FF,$00,$FF,$10,$FF,$90,$FF,$BC,$FF,$88,$01,$88,$11  ; $48BD
    DB $50,$01,$50,$11,$01,$FF,$00,$1C,$FF,$62,$FF,$02,$FF,$1C,$01,$50  ; $48CD
    DB $11,$FE,$FF,$18,$FF,$20,$01,$A8,$11,$01,$9F,$10,$01,$17,$10,$04  ; $48DD
    DB $FF,$28,$FF,$10,$FF,$08,$FF,$04,$FF,$00,$FF,$FC,$01,$0A,$11,$10  ; $48ED
    DB $FF,$28,$FF,$44,$FF,$82,$01,$00,$13,$62,$FF,$92,$FF,$0C,$FF,$08  ; $48FD
    DB $FF,$70,$01,$90,$15,$FE,$01,$90,$15,$80,$01,$F2,$11,$8A,$FF,$8A  ; $490D
    DB $FF,$84,$FF,$F4,$01,$A0,$0F,$4D,$01,$5F,$2F,$4D,$01,$BF,$2F,$2D  ; $491D

; --------------------------------------------------------------------------
; Bank46_fn18 — BGM_18
; long BGM track (768 frames); bank1 $43AC calls fn18
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 315 bytes  ($7FFF limit: up to $4A68)
; --------------------------------------------------------------------------
Bank46_BGM_18:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (312 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$40,$0F,$2D,$FF,$05,$FF,$45,$FF,$3C,$FF,$08  ; $4930
    DB $FF,$00,$FF,$80,$FF,$82,$FF,$7C,$FF,$00,$FF,$38,$FF,$00,$FF,$3C  ; $4940
    DB $FF,$42,$FF,$02,$FF,$04,$01,$B2,$01,$08,$FF,$FE,$FF,$18,$FF,$28  ; $4950
    DB $FF,$28,$FF,$18,$FF,$30,$FF,$00,$FF,$7C,$FF,$08,$01,$B6,$01,$9A  ; $4960
    DB $FF,$24,$FF,$18,$01,$D0,$03,$10,$FF,$54,$FF,$8A,$FF,$8A,$01,$CE  ; $4970
    DB $01,$20,$FF,$28,$FF,$F4,$FF,$2A,$FF,$4A,$FF,$88,$01,$CE,$01,$08  ; $4980
    DB $FF,$4A,$FF,$FC,$FF,$48,$FF,$48,$FF,$42,$FF,$3C,$FF,$00,$FF,$24  ; $4990
    DB $FF,$F8,$FF,$24,$FF,$7C,$FF,$AA,$FF,$B2,$FF,$54,$FF,$05,$FF,$4D  ; $49A0
    DB $FF,$F0,$FF,$46,$FF,$5A,$FF,$40,$FF,$90,$FF,$8E,$01,$F0,$01,$F6  ; $49B0
    DB $FF,$2A,$FF,$32,$FF,$64,$FF,$A4,$FF,$22,$01,$10,$13,$22,$FF,$7C  ; $49C0
    DB $FF,$92,$FF,$20,$FF,$1E,$FF,$00,$01,$B4,$01,$C2,$FF,$02,$01,$BA  ; $49D0
    DB $05,$20,$FF,$16,$FF,$18,$FF,$10,$FF,$78,$FF,$94,$FF,$62,$01,$F0  ; $49E0
    DB $01,$1E,$FF,$F8,$FF,$04,$FF,$0C,$FF,$40,$01,$0E,$11,$10,$FF,$90  ; $49F0
    DB $FF,$BC,$FF,$88,$01,$88,$11,$50,$01,$50,$11,$01,$51,$10,$1C,$FF  ; $4A00
    DB $62,$FF,$02,$FF,$1C,$01,$50,$11,$01,$C5,$00,$20,$01,$A8,$11,$01  ; $4A10
    DB $9F,$10,$FE,$01,$BA,$01,$28,$FF,$10,$FF,$08,$FF,$04,$FF,$00,$FF  ; $4A20
    DB $FC,$FF,$04,$01,$E4,$01,$28,$FF,$44,$FF,$82,$FF,$00,$FF,$3E,$FF  ; $4A30
    DB $22,$FF,$62,$FF,$92,$FF,$0C,$FF,$08,$FF,$70,$01,$90,$15,$FE,$01  ; $4A40
    DB $90,$15,$80,$01,$F2,$11,$01,$EB,$00,$84,$FF,$F4,$01,$40,$0F,$4D  ; $4A50
    DB $01,$5F,$2F,$4D,$01,$BF,$2F,$2D  ; $4A60

; --------------------------------------------------------------------------
; Bank46_fn19 — BGM_19
; long BGM track (768 frames); bank46 BGM G
; Header: BC=frame_count=$0300 (768d), sentinel=$01
; Size: 243 bytes  ($7FFF limit: up to $4B5B)
; --------------------------------------------------------------------------
Bank46_BGM_19:
    DB $00, $03  ; frame_count = $0300 (768d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (240 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$BF,$0F,$4D,$01,$1F,$1F,$4D  ; $4A6B
    DB $01,$7F,$1F,$4D,$01,$90,$1C,$FF,$00,$FF,$20,$FF,$48,$FF,$44,$FF  ; $4A7B
    DB $64,$FF,$44,$FF,$08,$FF,$10,$FF,$01,$EF,$12,$1C,$FF,$10,$FF,$30  ; $4A8B
    DB $FF,$58,$FF,$24,$FF,$00,$FF,$38,$FF,$00,$FF,$3C,$FF,$42,$FF,$02  ; $4A9B
    DB $FF,$04,$01,$12,$21,$10,$FF,$90,$FF,$BC,$FF,$88,$01,$28,$21,$50  ; $4AAB
    DB $01,$00,$21,$01,$EF,$10,$1C,$FF,$62,$FF,$02,$FF,$1C,$01,$F0,$11  ; $4ABB
    DB $28,$FF,$F4,$FF,$2A,$FF,$4A,$FF,$88,$FF,$30,$01,$20,$21,$10,$FF  ; $4ACB
    DB $20,$FF,$30,$FF,$68,$FF,$4A,$FF,$8C,$01,$00,$21,$FE,$FF,$18,$FF  ; $4ADB
    DB $20,$01,$68,$21,$01,$3F,$20,$08,$01,$64,$21,$28,$FF,$28,$FF,$18  ; $4AEB
    DB $01,$4E,$21,$7C,$FF,$08,$01,$16,$21,$9A,$FF,$24,$FF,$18,$FF,$00  ; $4AFB
    DB $FF,$40,$01,$92,$21,$44,$01,$98,$21,$01,$13,$20,$01,$71,$20,$4C  ; $4B0B
    DB $FF,$5A,$FF,$6A,$FF,$4C,$01,$FE,$11,$08,$FF,$30,$FF,$60,$FF,$C0  ; $4B1B
    DB $FF,$20,$FF,$10,$FF,$08,$01,$80,$23,$10,$FF,$54,$FF,$8A,$FF,$8A  ; $4B2B
    DB $01,$4E,$21,$30,$FF,$8C,$FF,$52,$FF,$E2,$FF,$24,$01,$52,$21,$01  ; $4B3B
    DB $71,$20,$88,$FF,$7C,$FF,$52,$FF,$B2,$FF,$A2,$FF,$54,$01,$90,$1C  ; $4B4B

; --------------------------------------------------------------------------
; Bank46_fn20 — BGM_20
; very long BGM track (2048 frames)
; Header: BC=frame_count=$0800 (2048d), sentinel=$02
; Size: 389 bytes  ($7FFF limit: up to $4CE0)
; --------------------------------------------------------------------------
Bank46_BGM_20:
    DB $00, $08  ; frame_count = $0800 (2048d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (386 bytes follow)
    DB $FF,$02,$FF,$FF,$00,$F3,$0B,$DB,$3C,$AF,$70,$57,$E8,$AF,$D0,$97  ; $4B5E
    DB $A8,$02,$00,$01,$FF,$02,$00,$0A,$BF,$80,$AF,$20,$8F,$2C,$86,$2F  ; $4B6E
    DB $85,$2D,$85,$2D,$2F,$50,$17,$A8,$02,$40,$08,$02,$3C,$00,$02,$50  ; $4B7E
    DB $08,$2F,$50,$07,$B7,$18,$58,$27,$A7,$58,$58,$BF,$BF,$C0,$C0,$02  ; $4B8E
    DB $24,$01,$FF,$00,$FF,$C0,$C0,$00,$0F,$FF,$FF,$00,$02,$23,$02,$02  ; $4B9E
    DB $00,$00,$02,$7C,$02,$00,$FF,$FF,$85,$2D,$85,$ED,$05,$ED,$05,$1D  ; $4BAE
    DB $05,$FD,$F9,$F9,$01,$01,$FE,$FF,$FF,$00,$C0,$00,$DF,$00,$BF,$00  ; $4BBE
    DB $DF,$00,$C0,$02,$FF,$F3,$02,$FE,$F4,$02,$FE,$F4,$03,$00,$FB,$00  ; $4BCE
    DB $FD,$00,$FB,$00,$03,$02,$FF,$F2,$1F,$FF,$10,$02,$D2,$0F,$02,$F0  ; $4BDE
    DB $02,$D2,$0F,$02,$1F,$02,$00,$00,$9F,$00,$00,$00,$9F,$02,$FF,$F9  ; $4BEE
    DB $02,$FE,$FA,$F3,$00,$01,$00,$F3,$02,$FF,$F7,$24,$00,$DB,$00,$A5  ; $4BFE
    DB $00,$DB,$00,$24,$00,$FF,$00,$BB,$00,$AB,$00,$D7,$00,$AB,$02,$41  ; $4C0E
    DB $13,$BB,$00,$DD,$00,$D5,$00,$EB,$00,$D5,$02,$51,$13,$DD,$02,$FF  ; $4C1E
    DB $F3,$11,$02,$FF,$F8,$24,$FF,$FA,$FF,$22,$FF,$7C,$FF,$A2,$FF,$A2  ; $4C2E
    DB $FF,$64,$FF,$05,$FF,$5F,$FF,$84,$FF,$9E,$FF,$84,$FF,$AC,$FF,$D6  ; $4C3E
    DB $FF,$5A,$FF,$00,$FF,$30,$FF,$18,$FF,$64,$FF,$08,$FF,$30,$FF,$48  ; $4C4E
    DB $FF,$8E,$FF,$00,$FF,$7C,$FF,$08,$FF,$3C,$FF,$42,$FF,$9A,$FF,$24  ; $4C5E
    DB $FF,$18,$FF,$00,$FF,$40,$FF,$44,$FF,$38,$FF,$60,$FF,$80,$FF,$82  ; $4C6E
    DB $FF,$7C,$FF,$00,$02,$98,$11,$60,$FF,$C0,$FF,$20,$FF,$10,$FF,$08  ; $4C7E
    DB $FF,$05,$FF,$25,$FF,$F8,$FF,$12,$02,$A2,$11,$80,$FF,$7C,$02,$A0  ; $4C8E
    DB $FF,$4D,$02,$3F,$2F,$4D,$02,$9F,$2F,$4D,$02,$FF,$2F,$4D,$02,$5F  ; $4C9E
    DB $3F,$4D,$02,$BF,$3F,$4D,$02,$1F,$4F,$4D,$02,$7F,$4F,$4D,$02,$DF  ; $4CAE
    DB $4F,$4D,$02,$3F,$5F,$4D,$02,$9F,$5F,$4D,$02,$FF,$5F,$4D,$02,$5F  ; $4CBE
    DB $6F,$4D,$02,$BF,$6F,$4D,$02,$1F,$7F,$4D,$02,$7F,$7F,$4D,$02,$DF  ; $4CCE
    DB $7F,$0D  ; $4CDE

; --------------------------------------------------------------------------
; Bank46_fn21 — Track21
; short audio sequence (64 frames)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 59 bytes  ($7FFF limit: up to $4D1B)
; --------------------------------------------------------------------------
Bank46_Track21:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (56 bytes follow)
    DB $01,$FF,$F0,$0E,$00,$0F,$04,$1F,$06,$19,$0F,$1A,$0D,$1E,$05,$01  ; $4CE3
    DB $FF,$F0,$7C,$00,$FC,$38,$CC,$F8,$2C,$D8,$5C,$B0,$18,$F0,$0C,$07  ; $4CF3
    DB $0E,$03,$1F,$05,$3F,$08,$3C,$10,$38,$01,$FF,$F1,$38,$E0,$DC,$30  ; $4D03
    DB $9C,$F8,$FC,$60,$F0,$01,$A0,$F3  ; $4D13

; --------------------------------------------------------------------------
; Bank46_fn22 — Track22
; short audio sequence, sentinel=$05
; Header: BC=frame_count=$0040 (64d), sentinel=$05
; Size: 66 bytes  ($7FFF limit: up to $4D5D)
; --------------------------------------------------------------------------
Bank46_Track22:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $05          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (63 bytes follow)
    DB $00,$00,$01,$00,$03,$00,$03,$01,$07,$01,$07,$02,$07,$01,$0F,$03  ; $4D1E
    DB $00,$00,$C0,$00,$E0,$80,$E0,$40,$F0,$C0,$B0,$60,$70,$C0,$F8,$60  ; $4D2E
    DB $1F,$04,$1F,$08,$1D,$0A,$1C,$0B,$1F,$04,$0F,$03,$07,$00,$00,$00  ; $4D3E
    DB $DC,$30,$EC,$18,$05,$32,$00,$DC,$30,$F8,$E0,$F0,$00,$00,$00  ; $4D4E

; --------------------------------------------------------------------------
; Bank46_fn23 — Track23
; short audio sequence (64 frames)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 58 bytes  ($7FFF limit: up to $4D97)
; --------------------------------------------------------------------------
Bank46_Track23:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (55 bytes follow)
    DB $01,$FF,$F6,$07,$00,$0F,$03,$7D,$06,$00,$00,$3C,$00,$7E,$18,$76  ; $4D60
    DB $2C,$E6,$3C,$FE,$58,$FC,$A0,$70,$C0,$FB,$3C,$DF,$60,$DE,$71,$BF  ; $4D70
    DB $69,$77,$3D,$79,$1F,$37,$0E,$0F,$00,$E0,$40,$60,$C0,$E0,$80,$C0  ; $4D80
    DB $00,$80,$01,$37,$01,$00,$00  ; $4D90

; --------------------------------------------------------------------------
; Bank46_fn24 — Track24
; short audio sequence (64 frames)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 49 bytes  ($7FFF limit: up to $4DC8)
; --------------------------------------------------------------------------
Bank46_Track24:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (46 bytes follow)
    DB $01,$FF,$F4,$07,$00,$0F,$03,$1C,$07,$3B,$0C,$01,$FF,$F4,$C0,$00  ; $4D9A
    DB $E0,$80,$70,$C0,$38,$E0,$34,$1B,$3A,$0D,$1C,$07,$0F,$03,$07,$01  ; $4DAA
    DB $FF,$F3,$58,$B0,$38,$E0,$70,$C0,$E0,$80,$C0,$01,$A0,$F3  ; $4DBA

; --------------------------------------------------------------------------
; Bank46_fn25 — Track25
; short audio sequence, sentinel=$02
; Header: BC=frame_count=$0040 (64d), sentinel=$02
; Size: 66 bytes  ($7FFF limit: up to $4E0A)
; --------------------------------------------------------------------------
Bank46_Track25:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (63 bytes follow)
    DB $02,$FF,$F0,$03,$00,$07,$01,$06,$03,$0E,$03,$3C,$07,$78,$1F,$1C  ; $4DCB
    DB $00,$3E,$08,$FF,$14,$FF,$D2,$3F,$EC,$1E,$F0,$0C,$F8,$0C,$F8,$60  ; $4DDB
    DB $3F,$60,$3F,$78,$1F,$FC,$37,$FC,$4F,$FF,$2B,$7F,$10,$38,$00,$0C  ; $4DEB
    DB $F8,$3C,$F0,$78,$C0,$E0,$80,$C0,$80,$C0,$00,$80,$00,$00,$00  ; $4DFB

; --------------------------------------------------------------------------
; Bank46_fn26 — Track26
; short audio sequence, sentinel=$02
; Header: BC=frame_count=$0040 (64d), sentinel=$02
; Size: 58 bytes  ($7FFF limit: up to $4E44)
; --------------------------------------------------------------------------
Bank46_Track26:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (55 bytes follow)
    DB $02,$FF,$F0,$01,$00,$03,$00,$03,$01,$03,$01,$03,$00,$07,$00,$00  ; $4E0D
    DB $00,$FC,$00,$FE,$78,$87,$FC,$23,$FE,$F3,$DE,$F3,$1E,$E3,$FE,$1F  ; $4E1D
    DB $03,$3C,$0F,$71,$1F,$67,$3E,$7F,$18,$3C,$02,$FF,$F1,$07,$FC,$7E  ; $4E2D
    DB $F8,$FC,$80,$C0,$02,$A0,$F5  ; $4E3D

; --------------------------------------------------------------------------
; Bank46_fn27 — Track27
; short audio sequence, sentinel=$02
; Header: BC=frame_count=$0040 (64d), sentinel=$02
; Size: 62 bytes  ($7FFF limit: up to $4E82)
; --------------------------------------------------------------------------
Bank46_Track27:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (59 bytes follow)
    DB $02,$FF,$F0,$03,$00,$07,$01,$0E,$03,$1F,$04,$1E,$09,$1E,$09,$78  ; $4E47
    DB $00,$D4,$38,$7C,$E8,$EA,$9C,$EE,$34,$BA,$CC,$74,$B8,$DC,$68,$1E  ; $4E57
    DB $09,$1C,$0B,$1C,$0B,$3D,$0B,$3A,$17,$3B,$16,$3F,$0C,$1E,$00,$DC  ; $4E67
    DB $B0,$F8,$60,$B0,$C0,$C0,$00,$80,$02,$A0,$F3  ; $4E77

; --------------------------------------------------------------------------
; Bank46_fn28 — Track28
; short audio sequence (64 frames)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 49 bytes  ($7FFF limit: up to $4EB3)
; --------------------------------------------------------------------------
Bank46_Track28:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (46 bytes follow)
    DB $01,$FF,$F4,$07,$00,$0F,$03,$1F,$04,$1C,$0B,$01,$FF,$F4,$E0,$00  ; $4E85
    DB $F0,$C0,$B8,$60,$58,$B0,$1D,$0A,$1C,$0B,$1F,$04,$0F,$03,$07,$01  ; $4E95
    DB $FF,$F3,$D8,$30,$D8,$30,$B8,$60,$F0,$C0,$E0,$01,$A0,$F3  ; $4EA5

; --------------------------------------------------------------------------
; Bank46_fn29 — BGM_29
; medium BGM track (128 frames); bank1 $4432 calls fn29
; Header: BC=frame_count=$0080 (128d), sentinel=$02
; Size: 95 bytes  ($7FFF limit: up to $4F12)
; --------------------------------------------------------------------------
Bank46_BGM_29:
    DB $80, $00  ; frame_count = $0080 (128d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (92 bytes follow)
    DB $00,$00,$FF,$FF,$D8,$A7,$DA,$A5,$D9,$A6,$FE,$81,$FD,$FE,$FB,$86  ; $4EB6
    DB $02,$00,$00,$1B,$E5,$5B,$A5,$9B,$65,$7F,$81,$BF,$7F,$DF,$61,$C6  ; $4EC6
    DB $B9,$CB,$B4,$F8,$87,$CC,$B3,$FF,$80,$FF,$FF,$02,$FE,$F0,$63,$9D  ; $4ED6
    DB $D3,$2D,$1F,$E1,$33,$CD,$FF,$01,$02,$2A,$02,$FF,$02,$01,$01,$FD  ; $4EE6
    DB $82,$FF,$FF,$BF,$FF,$BF,$FF,$FF,$80,$02,$40,$00,$1B,$E5,$BF,$41  ; $4EF6
    DB $FF,$FF,$FD,$FF,$FD,$FF,$FF,$01,$02,$20,$0F,$0D  ; $4F06

; --------------------------------------------------------------------------
; Bank46_fn30 — BGM_30
; very long BGM track (2048 frames)
; Header: BC=frame_count=$0800 (2048d), sentinel=$01
; Size: 1134 bytes  ($7FFF limit: up to $5380)
; --------------------------------------------------------------------------
Bank46_BGM_30:
    DB $00, $08  ; frame_count = $0800 (2048d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (1131 bytes follow)
    DB $01,$A0,$FF,$4D,$01,$5F,$0F,$4D,$01,$BF,$0F,$4D,$01,$1F,$1F,$4D  ; $4F15
    DB $01,$7F,$1F,$4D,$01,$DF,$1F,$4D,$FF,$00,$FF,$24,$FF,$F8,$FF,$24  ; $4F25
    DB $FF,$7C,$FF,$AA,$FF,$B2,$FF,$54,$FF,$01,$3F,$20,$84,$FF,$82,$FF  ; $4F35
    DB $82,$FF,$80,$FF,$40,$FF,$30,$FF,$00,$FF,$38,$FF,$00,$FF,$3C,$FF  ; $4F45
    DB $42,$FF,$02,$FF,$04,$01,$62,$21,$30,$FF,$18,$FF,$64,$FF,$08,$FF  ; $4F55
    DB $30,$FF,$48,$FF,$8E,$01,$40,$21,$FA,$FF,$22,$FF,$7C,$FF,$A2,$FF  ; $4F65
    DB $A2,$FF,$64,$FF,$00,$FF,$20,$FF,$28,$FF,$F4,$FF,$2A,$FF,$4A,$FF  ; $4F75
    DB $88,$01,$5E,$21,$01,$43,$20,$12,$FF,$7C,$FF,$08,$FF,$80,$FF,$7C  ; $4F85
    DB $FF,$00,$01,$78,$21,$60,$FF,$C0,$FF,$20,$FF,$10,$FF,$08,$FF,$00  ; $4F95
    DB $FF,$10,$FF,$90,$FF,$BC,$FF,$88,$01,$C8,$21,$50,$FF,$00,$FF,$40  ; $4FA5
    DB $FF,$3C,$01,$BE,$21,$80,$FF,$82,$01,$AE,$21,$20,$FF,$1E,$FF,$F8  ; $4FB5
    DB $FF,$04,$FF,$0C,$01,$D2,$21,$01,$D1,$20,$01,$F3,$20,$44,$01,$F8  ; $4FC5
    DB $21,$01,$63,$20,$08,$FF,$FE,$FF,$18,$FF,$28,$FF,$28,$FF,$18,$01  ; $4FD5
    DB $5E,$21,$08,$FF,$4A,$FF,$FC,$FF,$48,$FF,$48,$FF,$42,$01,$EE,$21  ; $4FE5
    DB $4C,$FF,$10,$FF,$26,$FF,$78,$FF,$10,$FF,$10,$FF,$0C,$FF,$00,$FF  ; $4FF5
    DB $48,$FF,$F0,$FF,$46,$FF,$5A,$FF,$40,$FF,$90,$01,$7E,$21,$20,$FF  ; $5005
    DB $7C,$FF,$20,$FF,$5C,$FF,$62,$FF,$82,$01,$EE,$21,$01,$65,$20,$C2  ; $5015
    DB $FF,$02,$01,$6A,$25,$01,$61,$32,$1C,$FF,$62,$FF,$02,$FF,$1C,$01  ; $5025
    DB $50,$21,$01,$05,$30,$20,$01,$78,$31,$01,$6F,$30,$01,$F7,$20,$38  ; $5035
    DB $FF,$60,$01,$DA,$25,$4C,$FF,$E2,$FF,$48,$FF,$44,$FF,$9C,$FF,$A4  ; $5045
    DB $FF,$9A,$01,$D0,$21,$8E,$FF,$90,$FF,$80,$FF,$80,$FF,$D0,$FF,$4E  ; $5055
    DB $01,$52,$21,$BC,$FF,$4A,$FF,$D2,$FF,$A6,$FF,$AA,$FF,$4C,$01,$90  ; $5065
    DB $21,$EC,$FF,$32,$FF,$62,$FF,$66,$FF,$AA,$FF,$AC,$01,$50,$21,$38  ; $5075
    DB $FF,$54,$FF,$92,$FF,$92,$01,$8C,$23,$01,$C3,$24,$98,$FF,$AC,$01  ; $5085
    DB $4E,$21,$10,$FF,$E4,$FF,$26,$01,$F8,$21,$48,$01,$5E,$21,$01,$A9  ; $5095
    DB $20,$10,$FF,$54,$FF,$8A,$FF,$8A,$01,$5E,$21,$30,$FF,$50,$FF,$48  ; $50A5
    DB $FF,$88,$FF,$04,$FF,$04,$FF,$02,$FF,$00,$FF,$5E,$FF,$84,$FF,$9E  ; $50B5
    DB $FF,$84,$FF,$AC,$FF,$D6,$FF,$5A,$01,$00,$41,$10,$01,$32,$41,$70  ; $50C5
    DB $FF,$98,$01,$8E,$21,$70,$FF,$10,$FF,$14,$FF,$7C,$FF,$A6,$FF,$A4  ; $50D5
    DB $FF,$48,$FF,$00,$FF,$A0,$FF,$74,$FF,$22,$FF,$60,$FF,$A2,$FF,$E2  ; $50E5
    DB $01,$EE,$21,$08,$FF,$88,$FF,$7C,$FF,$52,$FF,$B2,$FF,$A2,$01,$4E  ; $50F5
    DB $21,$20,$FF,$F8,$FF,$20,$FF,$FC,$FF,$20,$FF,$22,$01,$6E,$31,$30  ; $5105
    DB $FF,$8C,$FF,$52,$FF,$E2,$FF,$24,$01,$2A,$31,$01,$C1,$20,$08,$FF  ; $5115
    DB $5C,$FF,$22,$FF,$54,$01,$BC,$23,$08,$FF,$9C,$FF,$AA,$FF,$AA,$FF  ; $5125
    DB $DC,$FF,$48,$01,$8E,$41,$01,$B1,$20,$4C,$FF,$5A,$FF,$6A,$01,$22  ; $5135
    DB $31,$01,$91,$20,$16,$FF,$18,$FF,$10,$FF,$78,$FF,$94,$FF,$62,$01  ; $5145
    DB $50,$21,$01,$7D,$30,$10,$FF,$30,$FF,$58,$FF,$24,$01,$C0,$21,$4C  ; $5155
    DB $FF,$40,$FF,$BC,$FF,$C2,$01,$4C,$33,$20,$01,$96,$31,$64,$FF,$44  ; $5165
    DB $01,$04,$41,$01,$01,$42,$01,$67,$20,$9A,$FF,$24,$FF,$18,$01,$90  ; $5175
    DB $21,$F6,$FF,$2A,$FF,$32,$FF,$64,$FF,$A4,$FF,$22,$01,$00,$45,$01  ; $5185
    DB $67,$22,$01,$6F,$30,$20,$FF,$2C,$FF,$F2,$FF,$22,$FF,$62,$FF,$A2  ; $5195
    DB $FF,$2C,$01,$40,$23,$01,$87,$20,$92,$01,$E2,$21,$01,$C1,$20,$10  ; $51A5
    DB $FF,$20,$FF,$30,$FF,$68,$FF,$4A,$FF,$8C,$01,$72,$31,$02,$FF,$14  ; $51B5
    DB $01,$C6,$41,$10,$FF,$60,$01,$60,$33,$7C,$01,$66,$53,$20,$FF,$00  ; $51C5
    DB $01,$1A,$41,$08,$FF,$18,$FF,$68,$FF,$08,$01,$BE,$21,$01,$3F,$20  ; $51D5
    DB $01,$85,$50,$38,$01,$8C,$53,$10,$FF,$FE,$01,$56,$21,$01,$85,$50  ; $51E5
    DB $01,$5F,$20,$01,$3F,$20,$01,$35,$40,$44,$FF,$04,$01,$0E,$51,$01  ; $51F5
    DB $73,$30,$01,$2B,$30,$01,$2B,$30,$FE,$01,$60,$35,$3E,$01,$8C,$51  ; $5205
    DB $3E,$01,$00,$35,$01,$07,$30,$01,$17,$40,$01,$61,$32,$01,$05,$50  ; $5215
    DB $01,$E9,$52,$01,$C1,$20,$7E,$FF,$12,$FF,$22,$FF,$22,$FF,$44,$FF  ; $5225
    DB $98,$01,$D0,$21,$38,$FF,$E0,$FF,$1C,$FF,$F0,$FF,$08,$FF,$04,$01  ; $5235
    DB $D6,$51,$01,$09,$60,$42,$01,$AA,$55,$20,$FF,$3E,$01,$16,$41,$01  ; $5245
    DB $05,$40,$01,$7F,$50,$00,$FF,$7E,$01,$58,$31,$01,$59,$30,$7E,$01  ; $5255
    DB $40,$21,$FE,$FF,$24,$FF,$24,$01,$84,$51,$01,$8F,$40,$60,$FF,$12  ; $5265
    DB $FF,$C2,$FF,$22,$01,$84,$51,$70,$FF,$00,$FF,$FC,$01,$5A,$63,$28  ; $5275
    DB $FF,$44,$FF,$82,$01,$90,$21,$FE,$FF,$22,$FF,$24,$01,$78,$31,$01  ; $5285
    DB $4F,$50,$01,$57,$20,$42,$01,$BA,$51,$01,$FD,$42,$01,$23,$60,$62  ; $5295
    DB $FF,$92,$FF,$0C,$01,$6C,$63,$0C,$FF,$78,$01,$02,$31,$01,$8D,$50  ; $52A5
    DB $01,$5F,$20,$22,$FF,$92,$FF,$52,$01,$68,$23,$01,$BF,$52,$00,$FF  ; $52B5
    DB $2A,$FF,$2A,$01,$CA,$65,$01,$AF,$20,$01,$B9,$62,$01,$6D,$52,$01  ; $52C5
    DB $79,$30,$30,$FF,$28,$01,$88,$63,$01,$B1,$20,$01,$B7,$64,$01,$6D  ; $52D5
    DB $54,$01,$AF,$20,$01,$71,$32,$01,$41,$66,$34,$FF,$08,$FF,$14,$01  ; $52E5
    DB $CE,$41,$10,$01,$72,$61,$18,$FF,$34,$FF,$D2,$01,$8E,$41,$01,$1B  ; $52F5
    DB $40,$01,$85,$50,$01,$EB,$64,$01,$09,$30,$01,$09,$30,$01,$F9,$20  ; $5305
    DB $01,$7F,$60,$40,$FF,$46,$FF,$78,$01,$F2,$23,$01,$DF,$50,$01,$63  ; $5315
    DB $50,$01,$6B,$20,$01,$6B,$64,$01,$91,$20,$50,$01,$18,$41,$01,$1F  ; $5325
    DB $40,$01,$A1,$52,$01,$07,$40,$01,$99,$70,$92,$01,$60,$53,$04,$FF  ; $5335
    DB $28,$01,$BC,$21,$01,$1F,$60,$70,$FF,$0C,$FF,$60,$FF,$18,$FF,$C4  ; $5345
    DB $FF,$30,$FF,$0E,$01,$50,$55,$24,$FF,$44,$FF,$7A,$FF,$C2,$01,$80  ; $5355
    DB $53,$64,$01,$E6,$51,$24,$01,$CE,$71,$FE,$01,$78,$31,$01,$E3,$72  ; $5365
    DB $01,$4F,$50,$01,$83,$62,$14,$01,$BC,$21,$08  ; $5375

; --------------------------------------------------------------------------
; Bank46_fn31 — BGM_31
; medium BGM track (512 frames)
; Header: BC=frame_count=$0200 (512d), sentinel=$01
; Size: 328 bytes  ($7FFF limit: up to $54C8)
; --------------------------------------------------------------------------
Bank46_BGM_31:
    DB $00, $02  ; frame_count = $0200 (512d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (325 bytes follow)
    DB $FF,$01,$FF,$F2,$20,$FF,$7E,$FF,$14,$FF,$10,$FF,$08,$FF,$00,$FF  ; $5383
    DB $7C,$FF,$04,$01,$14,$03,$FF,$01,$00,$03,$00,$FF,$1C,$01,$14,$01  ; $5393
    DB $3E,$01,$00,$01,$FC,$01,$14,$01,$01,$33,$04,$01,$FF,$F2,$3C,$FF  ; $53A3
    DB $04,$01,$46,$03,$01,$11,$00,$00,$FF,$FE,$FF,$02,$FF,$02,$FF,$04  ; $53B3
    DB $FF,$78,$FF,$00,$FF,$44,$01,$62,$03,$04,$FF,$08,$FF,$30,$FF,$00  ; $53C3
    DB $FF,$50,$01,$72,$01,$52,$FF,$52,$FF,$54,$FF,$98,$01,$04,$01,$20  ; $53D3
    DB $FF,$22,$01,$86,$01,$24,$FF,$38,$01,$00,$01,$7E,$FF,$42,$01,$96  ; $53E3
    DB $01,$01,$95,$00,$01,$55,$00,$82,$FF,$82,$01,$5A,$01,$01,$6D,$02  ; $53F3
    DB $7E,$FF,$02,$01,$B2,$01,$01,$6B,$04,$00,$FF,$C2,$FF,$32,$01,$A8  ; $5403
    DB $03,$70,$FF,$05,$FF,$05,$01,$1E,$05,$01,$FF,$F0,$02,$FF,$05,$FF  ; $5413
    DB $02,$01,$D4,$06,$01,$F0,$FF,$00,$80,$01,$02,$11,$8A,$FF,$8A,$FF  ; $5423
    DB $84,$FF,$F4,$01,$00,$01,$28,$FF,$F0,$FF,$24,$FF,$78,$FF,$B4,$FF  ; $5433
    DB $D4,$01,$00,$03,$40,$FF,$88,$FF,$84,$FF,$A4,$FF,$40,$01,$00,$01  ; $5443
    DB $70,$01,$32,$11,$88,$01,$CC,$01,$01,$31,$14,$F8,$FF,$10,$FF,$64  ; $5453
    DB $FF,$9C,$01,$00,$01,$24,$FF,$F2,$FF,$22,$FF,$78,$FF,$A4,$FF,$68  ; $5463
    DB $01,$D0,$01,$3C,$FF,$C2,$01,$58,$03,$38,$FF,$05,$FF,$7D,$FF,$08  ; $5473
    DB $FF,$10,$FF,$54,$01,$08,$11,$30,$FF,$05,$FF,$45,$FF,$44,$FF,$38  ; $5483
    DB $FF,$60,$FF,$80,$FF,$82,$FF,$7C,$FF,$05,$FF,$25,$FF,$28,$FF,$F4  ; $5493
    DB $FF,$2A,$FF,$4A,$FF,$88,$01,$7E,$11,$4D,$FF,$F0,$FF,$46,$FF,$5A  ; $54A3
    DB $FF,$40,$FF,$90,$FF,$8E,$01,$F0,$FF,$04,$01,$55,$00,$01,$EB,$0F  ; $54B3
    DB $02,$01,$DF,$1F,$0D  ; $54C3

; --------------------------------------------------------------------------
; Bank46_fn32 — Track32
; short audio sequence (64 frames)
; Header: BC=frame_count=$0040 (64d), sentinel=$01
; Size: 19 bytes  ($7FFF limit: up to $54DB)
; --------------------------------------------------------------------------
Bank46_Track32:
    DB $40, $00  ; frame_count = $0040 (64d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (16 bytes follow)
    DB $FF,$00,$FF,$01,$02,$00,$01,$FF,$F0,$01,$07,$04,$01,$03,$0F,$1A  ; $54CB

; --------------------------------------------------------------------------
; Bank46_fn33 — BGM_33
; very long BGM track (2048 frames)
; Header: BC=frame_count=$0800 (2048d), sentinel=$02
; Size: 228 bytes  ($7FFF limit: up to $55BF)
; --------------------------------------------------------------------------
Bank46_BGM_33:
    DB $00, $08  ; frame_count = $0800 (2048d) [lo, hi]
    DB $02          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (225 bytes follow)
    DB $FF,$02,$00,$0E,$87,$FF,$BB,$FF,$BD,$02,$16,$01,$BB,$FF,$87,$FF  ; $54DE
    DB $FF,$FF,$83,$02,$16,$01,$83,$FF,$B7,$02,$14,$01,$FF,$FF,$EF,$FF  ; $54EE
    DB $D7,$FF,$D7,$FF,$BB,$FF,$83,$FF,$7D,$FF,$7D,$02,$10,$01,$7B,$FF  ; $54FE
    DB $7F,$FF,$61,$FF,$7B,$FF,$73,$FF,$8B,$FF,$FF,$FF,$C3,$02,$16,$03  ; $550E
    DB $02,$17,$00,$C3,$FF,$FF,$FF,$BD,$FF,$9D,$FF,$AD,$FF,$B5,$FF,$B9  ; $551E
    DB $02,$16,$01,$02,$41,$02,$02,$75,$00,$43,$FF,$39,$FF,$85,$02,$60  ; $552E
    DB $01,$02,$55,$0A,$83,$FF,$BF,$FF,$BF,$02,$92,$05,$02,$51,$02,$BF  ; $553E
    DB $FF,$C3,$FF,$FD,$02,$5C,$03,$01,$FF,$EF,$02,$B4,$07,$FF,$FF,$7D  ; $554E
    DB $FF,$39,$FF,$55,$FF,$6D,$02,$3C,$01,$02,$3F,$00,$02,$00,$00,$02  ; $555E
    DB $9F,$00,$02,$00,$01,$02,$A0,$FF,$4D,$02,$3F,$1F,$4D,$02,$9F,$1F  ; $556E
    DB $4D,$02,$FF,$1F,$4D,$02,$5F,$2F,$4D,$02,$BF,$2F,$4D,$02,$1F,$3F  ; $557E
    DB $4D,$02,$7F,$3F,$4D,$02,$DF,$3F,$4D,$02,$3F,$4F,$4D,$02,$9F,$4F  ; $558E
    DB $4D,$02,$FF,$4F,$4D,$02,$5F,$5F,$4D,$02,$BF,$5F,$4D,$02,$1F,$6F  ; $559E
    DB $4D,$02,$7F,$6F,$4D,$02,$DF,$6F,$4D,$02,$3F,$7F,$4D,$02,$9F,$7F  ; $55AE
    DB $4D  ; $55BE

; --------------------------------------------------------------------------
; Bank46_fn34 — Track34
; medium track (576 frames), sentinel=$0E
; Header: BC=frame_count=$0240 (576d), sentinel=$0E
; Size: 60 bytes  ($7FFF limit: up to $55FB)
; --------------------------------------------------------------------------
Bank46_Track34:
    DB $40, $02  ; frame_count = $0240 (576d) [lo, hi]
    DB $0E          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (57 bytes follow)
    DB $0E,$FF,$FF,$01,$FF,$0E,$14,$07,$0E,$00,$0F,$4D,$0E,$60,$0F,$4D  ; $55C2
    DB $0E,$FF,$F0,$01,$02,$03,$04,$05,$06,$00,$07,$08,$09,$0A,$0B,$0E  ; $55D2
    DB $70,$0F,$22,$0D,$0C,$05,$06,$0A,$0B,$09,$02,$0A,$0D,$0E,$6F,$0F  ; $55E2
    DB $4D,$0E,$6F,$1F,$4D,$0E,$CF,$1F,$3E  ; $55F2

; --------------------------------------------------------------------------
; Bank46_fn35 — BGM_35
; medium BGM track (512 frames)
; Header: BC=frame_count=$0200 (512d), sentinel=$01
; Size: 291 bytes  ($7FFF limit: up to $571E)
; --------------------------------------------------------------------------
Bank46_BGM_35:
    DB $00, $02  ; frame_count = $0200 (512d) [lo, hi]
    DB $01          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (288 bytes follow)
    DB $03,$00,$0F,$03,$1F,$0F,$3F,$1E,$7F,$3C,$7F,$38,$FF,$70,$FF,$7C  ; $55FE
    DB $C0,$00,$F0,$C0,$F8,$F0,$FC,$78,$FE,$3C,$FE,$1C,$FF,$0E,$FF,$3E  ; $560E
    DB $01,$00,$03,$1F,$7F,$3C,$7F,$3C,$FF,$7C,$01,$0E,$05,$F8,$FE,$3C  ; $561E
    DB $FE,$3C,$FF,$3E,$01,$1E,$07,$3D,$7F,$39,$FF,$70,$FF,$60,$01,$30  ; $562E
    DB $05,$FC,$FE,$FC,$FF,$0E,$FF,$0E,$01,$20,$05,$3F,$7F,$3F,$FF,$70  ; $563E
    DB $FF,$70,$01,$30,$05,$BC,$FE,$9C,$FF,$0E,$FF,$06,$01,$20,$05,$30  ; $564E
    DB $7F,$30,$01,$6C,$09,$3C,$FE,$7C,$FF,$7E,$01,$1E,$09,$3E,$FF,$7E  ; $565E
    DB $01,$2E,$07,$0C,$FE,$0C,$01,$5C,$0D,$76,$01,$6E,$07,$9C,$01,$BA  ; $566E
    DB $01,$1E,$01,$20,$05,$39,$01,$8A,$01,$78,$01,$50,$09,$6E,$FF,$0E  ; $567E
    DB $01,$2C,$00,$01,$28,$00,$3F,$1F,$1F,$0F,$0F,$03,$03,$00,$01,$3C  ; $568E
    DB $00,$01,$38,$00,$FC,$F8,$F8,$F0,$F0,$C0,$C0,$00,$FF,$7C,$FF,$70  ; $569E
    DB $7F,$38,$7F,$3C,$3F,$1E,$01,$0A,$15,$0E,$FE,$1C,$FE,$3C,$FC,$78  ; $56AE
    DB $01,$1A,$13,$60,$FF,$70,$7F,$39,$7F,$3D,$01,$08,$15,$0E,$FF,$0E  ; $56BE
    DB $01,$58,$00,$01,$18,$15,$70,$FF,$70,$01,$68,$00,$01,$08,$15,$06  ; $56CE
    DB $FF,$0E,$FE,$9C,$FE,$BC,$01,$58,$17,$76,$01,$64,$19,$1E,$FF,$0E  ; $56DE
    DB $FE,$0C,$FE,$9C,$01,$18,$15,$78,$FF,$70,$7F,$30,$7F,$39,$01,$48  ; $56EE
    DB $17,$6E,$01,$54,$1D,$30,$7F,$30,$01,$08,$17,$7E,$FE,$7C,$01,$16  ; $56FE
    DB $19,$7E,$7F,$3E,$01,$06,$17,$01,$51,$10,$0C,$FE,$0C,$01,$18,$14  ; $570E

; --------------------------------------------------------------------------
; Bank46_fn36 — Null_36
; null/empty track (BC=$0000, all zeros)
; Header: BC=frame_count=$0000 (0d), sentinel=$00
; Size: 4096 bytes  ($7FFF limit: up to $671E)
; --------------------------------------------------------------------------
Bank46_Null_36:
    DB $00, $00  ; frame_count = $0000 (0d) [lo, hi]
    DB $00          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (4093 bytes follow)
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; $5721
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$FF  ; $5731
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF  ; $5741
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$AA  ; $5751
    DB $55,$FF,$00,$AA,$55,$FF,$00,$AA,$55,$FF,$00,$AA,$55,$FF,$FF,$FF  ; $5761
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$AA,$AA  ; $5771
    DB $55,$55,$AA,$AA,$55,$55,$AA,$AA,$55,$55,$AA,$AA,$55,$FF,$FF,$FF  ; $5781
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$AA,$00  ; $5791
    DB $FF,$55,$AA,$00,$FF,$55,$AA,$00,$FF,$55,$AA,$00,$FF,$FF,$FF,$FF  ; $57A1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$00  ; $57B1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF  ; $57C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$55  ; $57D1
    DB $FF,$00,$FF,$55,$FF,$00,$FF,$55,$FF,$00,$FF,$55,$FF,$FF,$FF,$FF  ; $57E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$AA,$FF,$55  ; $57F1
    DB $FF,$AA,$FF,$55,$FF,$AA,$FF,$55,$FF,$AA,$FF,$55,$FF,$FF,$FF,$FF  ; $5801
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$AA,$FF,$FF  ; $5811
    DB $FF,$AA,$FF,$FF,$FF,$AA,$FF,$FF,$FF,$AA,$FF,$FF,$FF,$FF,$FF,$FF  ; $5821
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $5831
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $5841
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $5851
    DB $FF,$FF,$FF,$FF,$FF,$5A,$5F,$42,$5D,$32,$3D,$76,$29,$FF,$FF,$FF  ; $5861
    DB $FF,$FF,$FF,$FF,$FF,$FA,$FF,$A0,$FF,$C0,$FF,$80,$FF,$32,$3D,$32  ; $5871
    DB $3D,$76,$29,$32,$3D,$32,$3D,$76,$29,$32,$3D,$32,$3D,$C0,$FF,$C0  ; $5881
    DB $FF,$80,$FF,$C0,$FF,$C0,$FF,$80,$FF,$C0,$FF,$C0,$FF,$76,$29,$32  ; $5891
    DB $3D,$32,$3D,$76,$29,$36,$39,$39,$32,$51,$24,$45,$A2,$80,$FF,$C0  ; $58A1
    DB $FF,$C0,$FF,$80,$FF,$CC,$F3,$CF,$F0,$8F,$F0,$7F,$80,$00,$FF,$00  ; $58B1
    DB $FF,$07,$F8,$08,$F0,$09,$F0,$0E,$F0,$0F,$F0,$F1,$00,$FF,$FF,$FF  ; $58C1
    DB $FF,$FF,$F8,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$60,$FF,$00,$00,$FC,$06  ; $58D1
    DB $F8,$88,$70,$74,$00,$90,$00,$29,$01,$7F,$18,$41,$01,$FF,$FC,$FF  ; $58E1
    DB $E8,$FF,$70,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$04,$F2,$02  ; $58F1
    DB $10,$92,$00,$AC,$A0,$3C,$10,$F1,$11,$80,$00,$44,$54,$FF,$F0,$FF  ; $5901
    DB $10,$FF,$00,$5F,$00,$EF,$00,$EE,$1F,$FF,$3F,$AB,$7F,$FF,$00,$FF  ; $5911
    DB $00,$FF,$00,$FF,$00,$F8,$08,$EF,$2F,$C6,$46,$80,$00,$FF,$FF,$FF  ; $5921
    DB $FF,$FF,$FF,$FF,$FF,$F7,$FF,$D0,$FF,$B9,$FF,$FF,$FF,$FF,$00,$FF  ; $5931
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$02,$E0,$20,$FF,$FF,$FF  ; $5941
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$DF,$FF,$FF,$00,$FF  ; $5951
    DB $00,$FF,$00,$FF,$00,$C7,$44,$80,$80,$01,$01,$00,$E0,$FF,$FF,$FF  ; $5961
    DB $FF,$FF,$FF,$FF,$FF,$BB,$FF,$7F,$FF,$FE,$FF,$1F,$FF,$E0,$23,$80  ; $5971
    DB $81,$01,$01,$1F,$1F,$84,$87,$18,$1F,$80,$80,$C0,$F0,$DC,$FF,$7E  ; $5981
    DB $FF,$FE,$FF,$E0,$FF,$78,$FF,$E0,$FF,$7F,$FF,$0F,$FF,$C1,$41,$59  ; $5991
    DB $99,$30,$F0,$01,$F1,$0F,$CF,$00,$00,$82,$FE,$23,$3F,$BE,$FF,$66  ; $59A1
    DB $FF,$0F,$FF,$0E,$FF,$30,$FF,$FF,$FF,$01,$FF,$C0,$FF,$60,$60,$24  ; $59B1
    DB $3C,$83,$8F,$88,$8F,$F8,$FF,$40,$7F,$0E,$2F,$83,$83,$9F,$FF,$C3  ; $59C1
    DB $FF,$70,$FF,$70,$FF,$00,$FF,$80,$FF,$D0,$FF,$7C,$FF,$55,$AA,$AA  ; $59D1
    DB $55,$55,$AA,$AA,$55,$55,$AA,$AA,$55,$56,$AA,$A0,$60,$FF,$FF,$FF  ; $59E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$DF,$FF,$55,$AA,$AA  ; $59F1
    DB $55,$55,$AA,$AA,$55,$45,$C6,$80,$80,$01,$01,$00,$E0,$FF,$FF,$FF  ; $5A01
    DB $FF,$FF,$FF,$FF,$FF,$BB,$FF,$7F,$FF,$FE,$FF,$1F,$FF,$60,$A3,$80  ; $5A11
    DB $81,$01,$01,$1F,$1F,$84,$87,$18,$1F,$80,$80,$C0,$F0,$DC,$FF,$7E  ; $5A21
    DB $FF,$FE,$FF,$E0,$FF,$78,$FF,$E0,$FF,$7F,$FF,$0F,$FF,$41,$C1,$19  ; $5A31
    DB $D9,$30,$F0,$01,$F1,$0F,$CF,$00,$00,$82,$FE,$23,$3F,$BE,$FF,$66  ; $5A41
    DB $FF,$0F,$FF,$0E,$FF,$30,$FF,$FF,$FF,$01,$FF,$C0,$FF,$FF,$00,$FF  ; $5A51
    DB $00,$FF,$00,$FF,$00,$7F,$40,$0F,$08,$01,$01,$00,$00,$FF,$FF,$FF  ; $5A61
    DB $FF,$FF,$FF,$FF,$FF,$BF,$FF,$F7,$FF,$FE,$FF,$FF,$FF,$00,$FF,$00  ; $5A71
    DB $FF,$7E,$D1,$6B,$9E,$2E,$C0,$82,$00,$44,$14,$35,$30,$FF,$FF,$FF  ; $5A81
    DB $FF,$FF,$81,$FF,$80,$FF,$80,$FF,$00,$FF,$00,$FF,$00,$00,$FF,$07  ; $5A91
    DB $FF,$3F,$C0,$C5,$00,$40,$00,$7C,$00,$84,$80,$FF,$20,$FF,$F8,$FF  ; $5AA1
    DB $E0,$FF,$40,$FF,$00,$FF,$00,$FF,$00,$7F,$00,$DF,$00,$A8,$00,$81  ; $5AB1
    DB $01,$C7,$87,$F0,$50,$FC,$7C,$74,$04,$C0,$0A,$E4,$04,$FF,$00,$FE  ; $5AC1
    DB $00,$78,$03,$AF,$1F,$83,$20,$FB,$00,$F5,$00,$FB,$00,$3E,$02,$C0  ; $5AD1
    DB $40,$04,$34,$C0,$C0,$68,$28,$00,$00,$01,$07,$16,$17,$FD,$03,$BF  ; $5AE1
    DB $7F,$CB,$FC,$3F,$80,$F7,$00,$FF,$00,$F8,$00,$E8,$00,$01,$0F,$30  ; $5AF1
    DB $37,$8A,$FA,$12,$12,$04,$04,$86,$A7,$C8,$F9,$BC,$FF,$F0,$FF,$C8  ; $5B01
    DB $FF,$05,$F8,$ED,$00,$FB,$00,$58,$00,$06,$00,$00,$00,$FE,$02,$FC  ; $5B11
    DB $0C,$FC,$04,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FD,$FF,$F3  ; $5B21
    DB $FF,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$01,$00  ; $5B31
    DB $C7,$01,$7F,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$FF,$38  ; $5B41
    DB $FF,$80,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$80,$F0,$C6  ; $5B51
    DB $FE,$E3,$FF,$F0,$0F,$F8,$0F,$FF,$01,$FF,$00,$FF,$00,$0F,$FF,$01  ; $5B61
    DB $FF,$00,$FF,$F0,$FF,$F0,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$C6,$FE,$C3  ; $5B71
    DB $FF,$9C,$FF,$00,$FF,$18,$E7,$3E,$C1,$FF,$00,$FF,$00,$01,$FF,$00  ; $5B81
    DB $FF,$00,$FF,$00,$FF,$18,$FF,$3E,$FF,$FF,$FF,$FF,$FF,$61,$7F,$81  ; $5B91
    DB $FF,$1F,$FF,$FF,$FF,$0F,$FF,$08,$F7,$FE,$01,$FF,$00,$80,$FF,$00  ; $5BA1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$08,$FF,$FE,$FF,$FF,$FF,$C1,$C1,$E0  ; $5BB1
    DB $E0,$BF,$FF,$83,$FF,$00,$FF,$00,$FF,$00,$FF,$E0,$1F,$3E,$FF,$1F  ; $5BC1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$E0,$FF,$00,$01,$00  ; $5BD1
    DB $C7,$01,$7F,$00,$FF,$55,$AA,$00,$FF,$55,$AA,$00,$FF,$FE,$FF,$38  ; $5BE1
    DB $FF,$80,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$80,$F0,$C6  ; $5BF1
    DB $FE,$E3,$FF,$00,$FF,$58,$AF,$01,$FF,$55,$AA,$00,$FF,$0F,$FF,$01  ; $5C01
    DB $FF,$00,$FF,$F0,$FF,$F0,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$C6,$FE,$C3  ; $5C11
    DB $FF,$9C,$FF,$00,$FF,$10,$EF,$00,$FF,$55,$AA,$00,$FF,$01,$FF,$00  ; $5C21
    DB $FF,$00,$FF,$00,$FF,$18,$FF,$3E,$FF,$FF,$FF,$FF,$FF,$61,$7F,$81  ; $5C31
    DB $FF,$1F,$FF,$FF,$FF,$0F,$FF,$00,$FF,$54,$AB,$00,$FF,$80,$FF,$00  ; $5C41
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$08,$FF,$FE,$FF,$FF,$FF,$00,$FF,$00  ; $5C51
    DB $FF,$01,$E1,$04,$17,$30,$FF,$80,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF  ; $5C61
    DB $FF,$FE,$FF,$EB,$FF,$0F,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$B7,$4B,$7A  ; $5C71
    DB $1A,$54,$14,$91,$91,$A1,$01,$44,$00,$A8,$28,$91,$00,$FC,$00,$F5  ; $5C81
    DB $00,$EB,$00,$EE,$00,$FE,$00,$FF,$00,$D7,$00,$FF,$00,$31,$00,$44  ; $5C91
    DB $04,$04,$04,$00,$03,$80,$83,$18,$08,$47,$10,$80,$45,$FF,$00,$FB  ; $5CA1
    DB $00,$FB,$00,$FC,$00,$7C,$00,$F7,$00,$EF,$00,$BA,$00,$80,$06,$10  ; $5CB1
    DB $1A,$10,$FE,$64,$07,$18,$67,$1D,$7D,$84,$F4,$6C,$90,$F9,$00,$E5  ; $5CC1
    DB $00,$01,$00,$F8,$00,$98,$00,$82,$00,$0B,$00,$6F,$00,$23,$23,$8F  ; $5CD1
    DB $AF,$05,$C5,$22,$F2,$81,$C1,$00,$00,$12,$02,$F8,$1A,$DC,$00,$50  ; $5CE1
    DB $00,$3A,$00,$0D,$00,$3E,$00,$FF,$00,$FD,$00,$E5,$00,$37,$FF,$00  ; $5CF1
    DB $F3,$40,$66,$24,$3F,$20,$BF,$14,$BF,$44,$6F,$98,$FB,$00,$00,$0C  ; $5D01
    DB $00,$99,$00,$C0,$00,$40,$00,$40,$00,$90,$00,$04,$00,$FF,$00,$AA  ; $5D11
    DB $55,$FF,$00,$AA,$55,$F8,$08,$AF,$6F,$C6,$46,$80,$00,$FF,$FF,$FF  ; $5D21
    DB $FF,$FF,$FF,$FF,$FF,$F7,$FF,$D0,$FF,$B9,$FF,$FF,$FF,$FF,$55,$CE  ; $5D31
    DB $E5,$31,$97,$6C,$87,$94,$2A,$D1,$04,$42,$04,$34,$80,$FF,$55,$FF  ; $5D41
    DB $04,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$E6,$ED,$45  ; $5D51
    DB $D5,$F4,$28,$83,$39,$54,$0B,$A9,$10,$02,$11,$D7,$00,$FF,$E4,$FF  ; $5D61
    DB $44,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$4F,$D7  ; $5D71
    DB $36,$98,$23,$02,$34,$50,$0A,$1A,$01,$6C,$91,$24,$5B,$FF,$4F,$FF  ; $5D81
    DB $06,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$F6,$ED,$65  ; $5D91
    DB $DD,$75,$29,$C3,$39,$54,$8B,$D9,$60,$55,$60,$0B,$90,$FF,$E4,$FF  ; $5DA1
    DB $44,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$AA,$7B  ; $5DB1
    DB $A7,$8E,$EB,$36,$E1,$29,$54,$AB,$00,$62,$80,$94,$E9,$FF,$AA,$FF  ; $5DC1
    DB $20,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$48,$D8,$F9  ; $5DD1
    DB $80,$E6,$00,$79,$A0,$68,$00,$A7,$40,$E8,$00,$71,$80,$FF,$00,$FF  ; $5DE1
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$00,$49,$26  ; $5DF1
    DB $44,$F1,$01,$39,$80,$46,$30,$80,$00,$06,$20,$D1,$00,$FF,$00,$FF  ; $5E01
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$0B,$24,$86  ; $5E11
    DB $21,$59,$12,$15,$04,$57,$00,$05,$E2,$02,$00,$FF,$00,$FF,$00,$FF  ; $5E21
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$79,$49,$66  ; $5E31
    DB $45,$C1,$01,$39,$80,$46,$30,$80,$00,$06,$20,$D1,$00,$FF,$00,$FF  ; $5E41
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$71,$00,$1F  ; $5E51
    DB $00,$02,$02,$8C,$0C,$CB,$0B,$19,$19,$8A,$88,$00,$00,$FF,$00,$FF  ; $5E61
    DB $00,$FD,$00,$F3,$00,$F4,$00,$E6,$00,$77,$00,$FF,$00,$00,$00,$94  ; $5E71
    DB $94,$37,$27,$C0,$C0,$FE,$FE,$C7,$C7,$20,$20,$17,$00,$FF,$00,$6B  ; $5E81
    DB $F0,$D8,$E0,$3F,$00,$01,$00,$38,$00,$DF,$00,$FF,$00,$04,$04,$48  ; $5E91
    DB $48,$FC,$FC,$38,$38,$F8,$78,$B0,$B0,$FA,$FE,$E4,$26,$FB,$07,$B7  ; $5EA1
    DB $7F,$03,$CC,$C7,$00,$87,$00,$4F,$00,$01,$00,$D9,$00,$1D,$10,$B3  ; $5EB1
    DB $83,$2C,$0C,$02,$02,$03,$03,$68,$6B,$90,$BB,$9F,$9F,$EF,$F0,$7C  ; $5EC1
    DB $80,$F3,$00,$FD,$00,$FC,$00,$94,$00,$44,$00,$60,$00,$E4,$74,$F6  ; $5ED1
    DB $F7,$C6,$EF,$48,$CF,$4A,$FB,$37,$7F,$02,$FB,$B6,$B0,$8B,$00,$08  ; $5EE1
    DB $00,$10,$00,$30,$00,$04,$00,$80,$00,$04,$00,$4F,$00,$B0,$BE,$A4  ; $5EF1
    DB $E6,$21,$FD,$63,$F7,$2C,$FF,$5A,$FF,$1B,$FF,$E9,$F1,$41,$00,$19  ; $5F01
    DB $00,$02,$00,$08,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$56,$AA,$0C  ; $5F11
    DB $FC,$54,$AC,$00,$FF,$55,$AA,$00,$FF,$55,$AA,$00,$FF,$FD,$FF,$F3  ; $5F21
    DB $FF,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$D0,$00,$DC  ; $5F31
    DB $00,$33,$00,$2E,$00,$87,$04,$8E,$0E,$1F,$26,$0E,$F1,$FF,$00,$FF  ; $5F41
    DB $00,$FF,$00,$FF,$00,$FB,$00,$F1,$00,$C0,$39,$00,$FF,$F2,$02,$E4  ; $5F51
    DB $04,$13,$10,$56,$10,$B8,$10,$C8,$38,$30,$CE,$7F,$FF,$FD,$00,$FB  ; $5F61
    DB $00,$EF,$00,$EF,$00,$EF,$00,$87,$70,$00,$FF,$00,$FF,$9F,$03,$E5  ; $5F71
    DB $85,$FF,$00,$15,$00,$01,$00,$1F,$00,$3A,$40,$C0,$F0,$FC,$00,$7A  ; $5F81
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$1F,$E0,$0F,$F0,$02,$02,$6F  ; $5F91
    DB $0F,$1E,$1E,$E7,$E3,$FA,$72,$FE,$6E,$5C,$40,$27,$20,$FD,$00,$F0  ; $5FA1
    DB $00,$E1,$00,$1C,$00,$8D,$00,$91,$00,$BF,$00,$DF,$00,$35,$05,$13  ; $5FB1
    DB $03,$9B,$0B,$02,$02,$0D,$04,$80,$00,$03,$00,$20,$00,$FA,$00,$FC  ; $5FC1
    DB $00,$F4,$00,$FD,$00,$FB,$00,$FF,$00,$FF,$00,$FF,$00,$9F,$03,$F5  ; $5FD1
    DB $C5,$FF,$80,$35,$00,$61,$00,$7F,$04,$73,$13,$1B,$0B,$FC,$00,$3A  ; $5FE1
    DB $00,$7F,$00,$FF,$00,$FF,$00,$FB,$00,$EC,$00,$F4,$00,$3E,$3E,$61  ; $5FF1
    DB $61,$9F,$9F,$68,$68,$AE,$8E,$07,$07,$E3,$C3,$66,$06,$C1,$00,$9E  ; $6001
    DB $00,$60,$00,$97,$00,$71,$00,$F8,$00,$3C,$00,$F9,$00,$AF,$2F,$FB  ; $6011
    DB $FB,$39,$39,$C6,$06,$3F,$3D,$E7,$E6,$FF,$07,$F1,$E1,$D0,$00,$04  ; $6021
    DB $00,$C6,$00,$F9,$00,$C2,$00,$19,$00,$F8,$00,$1E,$00,$31,$01,$11  ; $6031
    DB $01,$9B,$09,$00,$00,$09,$00,$80,$00,$03,$00,$20,$00,$FE,$00,$FE  ; $6041
    DB $00,$F6,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$4C,$4C,$07  ; $6051
    DB $05,$07,$03,$37,$13,$7D,$61,$60,$40,$7A,$6A,$C0,$00,$B3,$00,$FA  ; $6061
    DB $00,$FC,$00,$EE,$00,$9E,$00,$BF,$00,$F5,$00,$FF,$00,$07,$05,$3E  ; $6071
    DB $16,$FC,$C8,$FD,$05,$70,$60,$2D,$28,$FC,$E4,$DF,$D4,$FA,$00,$FD  ; $6081
    DB $00,$77,$00,$FA,$00,$9F,$00,$FF,$00,$1B,$00,$2B,$00,$D0,$D0,$7B  ; $6091
    DB $7F,$27,$27,$75,$16,$FC,$23,$C4,$84,$01,$03,$24,$07,$2F,$00,$80  ; $60A1
    DB $00,$D8,$00,$E9,$00,$DC,$00,$7B,$00,$FC,$00,$F8,$00,$CE,$FE,$1A  ; $60B1
    DB $F8,$C5,$E0,$9F,$79,$06,$B8,$0D,$12,$A7,$93,$0F,$EC,$01,$00,$07  ; $60C1
    DB $00,$1F,$00,$86,$00,$47,$00,$ED,$00,$6C,$00,$13,$00,$FF,$C0,$66  ; $60D1
    DB $02,$F4,$04,$F3,$03,$CC,$05,$5B,$03,$7F,$29,$FF,$24,$3F,$00,$FD  ; $60E1
    DB $03,$FB,$07,$FC,$0F,$FB,$30,$FF,$00,$F6,$00,$DB,$00,$FB,$7B,$31  ; $60F1
    DB $39,$02,$8E,$21,$E5,$EC,$E6,$75,$03,$CD,$BE,$3F,$C6,$84,$1E,$C6  ; $6101
    DB $BF,$71,$FF,$1A,$E0,$19,$00,$FC,$00,$41,$00,$39,$00,$0B,$F7,$7F  ; $6111
    DB $7C,$7F,$3F,$7F,$7D,$9F,$93,$FC,$8F,$F3,$1E,$BF,$FC,$00,$FF,$00  ; $6121
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$DA,$2D,$2F  ; $6131
    DB $1F,$F3,$0F,$1D,$C3,$82,$E1,$C5,$B0,$F7,$E8,$E7,$78,$00,$FF,$00  ; $6141
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$F7,$FF,$B0  ; $6151
    DB $FE,$C0,$FF,$60,$FF,$9F,$6F,$E3,$1F,$FF,$FF,$FF,$FF,$00,$FF,$00  ; $6161
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$68,$F7,$FF  ; $6171
    DB $FF,$BE,$FF,$2F,$FF,$FB,$3C,$73,$CC,$F8,$77,$F8,$FF,$00,$FF,$00  ; $6181
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$33,$C0,$FF  ; $6191
    DB $C0,$FF,$FF,$FF,$E0,$F9,$07,$E7,$1F,$07,$FF,$7F,$9E,$0C,$F3,$00  ; $61A1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$70,$00,$5F  ; $61B1
    DB $40,$FA,$3D,$F5,$3F,$FF,$FF,$FF,$FF,$FE,$F9,$FF,$7C,$0F,$F0,$00  ; $61C1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$03,$01,$36  ; $61D1
    DB $00,$50,$04,$A0,$F0,$D8,$BC,$E8,$FF,$57,$F8,$9C,$E3,$FE,$00,$3F  ; $61E1
    DB $C0,$01,$FE,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$1F,$1F,$FF  ; $61F1
    DB $FF,$73,$03,$4F,$03,$33,$00,$FD,$00,$76,$80,$38,$C2,$E0,$00,$00  ; $6201
    DB $00,$FC,$00,$7C,$80,$1F,$E0,$00,$FE,$00,$EF,$00,$E7,$7C,$7C,$86  ; $6211
    DB $86,$F9,$F9,$16,$16,$75,$71,$E0,$60,$C7,$83,$66,$60,$83,$00,$79  ; $6221
    DB $00,$06,$00,$E9,$00,$8E,$00,$9F,$00,$7C,$00,$1F,$80,$76,$FF,$AB  ; $6231
    DB $AB,$C2,$CB,$0C,$CE,$7E,$FE,$00,$58,$88,$EE,$8C,$AE,$00,$00,$54  ; $6241
    DB $00,$34,$00,$31,$00,$01,$00,$A7,$00,$11,$00,$51,$00,$37,$17,$1C  ; $6251
    DB $1C,$55,$55,$AA,$AA,$F7,$F7,$BB,$FB,$0F,$FF,$A4,$FF,$E8,$00,$E3  ; $6261
    DB $00,$AA,$00,$55,$00,$08,$00,$04,$00,$00,$00,$00,$00,$F8,$F8,$67  ; $6271
    DB $67,$22,$20,$69,$69,$F2,$F2,$7F,$FF,$3B,$FF,$13,$FF,$07,$00,$98  ; $6281
    DB $00,$DF,$00,$96,$00,$0D,$00,$00,$00,$00,$00,$00,$00,$8C,$8F,$D7  ; $6291
    DB $D7,$DF,$DF,$7F,$7F,$FA,$FD,$F7,$FE,$F0,$F4,$79,$FA,$70,$00,$28  ; $62A1
    DB $00,$20,$00,$80,$00,$02,$00,$01,$00,$0B,$00,$05,$00,$7C,$E4,$7C  ; $62B1
    DB $74,$32,$C0,$4E,$C8,$01,$01,$17,$17,$49,$39,$03,$33,$1B,$00,$8B  ; $62C1
    DB $00,$3F,$00,$37,$00,$FE,$00,$E8,$00,$C6,$00,$CC,$00,$FB,$2C,$F8  ; $62D1
    DB $65,$40,$4E,$07,$07,$11,$13,$98,$9F,$EE,$EF,$FF,$FF,$FF,$00,$9E  ; $62E1
    DB $00,$B1,$00,$F8,$00,$EC,$00,$60,$00,$10,$00,$00,$00,$7B,$CB,$31  ; $62F1
    DB $33,$23,$23,$82,$E3,$0F,$3F,$C7,$FF,$02,$FF,$C0,$FF,$34,$00,$CC  ; $6301
    DB $00,$DC,$00,$1C,$00,$C0,$00,$00,$00,$00,$00,$00,$00,$0B,$F7,$7F  ; $6311
    DB $7C,$7F,$3F,$7F,$7D,$9F,$93,$FC,$8F,$F3,$1E,$BF,$FC,$00,$FF,$00  ; $6321
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$F7,$FF,$B0  ; $6331
    DB $FE,$C0,$FF,$60,$FF,$9F,$6F,$E3,$1F,$FF,$FF,$FF,$FF,$00,$FF,$00  ; $6341
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$0B,$F7,$7F  ; $6351
    DB $7C,$7F,$3F,$7F,$7D,$9F,$93,$FC,$8F,$F3,$1E,$BF,$FC,$00,$FF,$00  ; $6361
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$68,$F7,$FF  ; $6371
    DB $FF,$BE,$FF,$2F,$FF,$FB,$3C,$73,$CC,$F8,$77,$F8,$FF,$00,$FF,$00  ; $6381
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$7B,$EF  ; $6391
    DB $7F,$C4,$FE,$80,$D4,$D4,$F8,$F7,$F8,$DF,$F0,$07,$D0,$00,$FF,$00  ; $63A1
    DB $FF,$00,$FF,$00,$FF,$00,$FB,$00,$F8,$00,$F8,$00,$F8,$FF,$FE,$FE  ; $63B1
    DB $FF,$FC,$F8,$8F,$00,$8F,$00,$D3,$00,$F9,$00,$9F,$00,$00,$FF,$00  ; $63C1
    DB $FF,$00,$FF,$00,$7F,$00,$7F,$00,$2E,$00,$06,$00,$60,$FE,$01,$79  ; $63D1
    DB $0E,$9C,$00,$E0,$00,$00,$00,$11,$02,$71,$0E,$80,$1E,$00,$FF,$00  ; $63E1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$EE,$00,$8E,$00,$7F,$15,$FA,$8D  ; $63F1
    DB $7E,$86,$7C,$04,$D0,$C4,$F8,$6F,$F0,$0F,$F0,$17,$C0,$00,$FF,$00  ; $6401
    DB $FF,$00,$FF,$00,$FF,$00,$FB,$00,$F8,$00,$F8,$00,$F8,$53,$13,$44  ; $6411
    DB $35,$73,$0C,$F4,$03,$79,$02,$90,$6F,$40,$3F,$10,$0F,$2C,$80,$0A  ; $6421
    DB $80,$33,$80,$00,$08,$00,$86,$00,$FF,$00,$FF,$00,$FF,$7C,$7C,$86  ; $6431
    DB $86,$79,$F9,$14,$57,$10,$F7,$20,$9E,$13,$EF,$02,$F4,$83,$00,$79  ; $6441
    DB $00,$06,$00,$A8,$00,$08,$00,$01,$C0,$00,$E0,$03,$F8,$04,$FF,$C1  ; $6451
    DB $FF,$A3,$FF,$FE,$FE,$A8,$FC,$FD,$FD,$AB,$FF,$FE,$FF,$00,$00,$C1  ; $6461
    DB $C1,$B2,$B2,$FF,$FE,$F7,$F4,$FA,$F8,$F4,$F4,$F0,$F0,$01,$FF,$C1  ; $6471
    DB $FF,$60,$7F,$E0,$FF,$C0,$FF,$80,$FF,$F0,$FF,$00,$FF,$80,$80,$C0  ; $6481
    DB $C0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C2,$FD,$D8  ; $6491
    DB $E1,$08,$F7,$0F,$F0,$00,$FF,$00,$FD,$00,$FF,$08,$FF,$02,$00,$1E  ; $64A1
    DB $00,$08,$00,$0F,$00,$00,$00,$02,$00,$00,$00,$00,$00,$01,$CF,$81  ; $64B1
    DB $0B,$03,$7F,$12,$37,$00,$FF,$00,$BF,$00,$FF,$04,$FF,$30,$00,$F4  ; $64C1
    DB $00,$80,$00,$C8,$00,$00,$00,$40,$00,$00,$00,$00,$00,$11,$FF,$00  ; $64D1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$24,$FF,$00,$00,$00  ; $64E1
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$FF,$00  ; $64F1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$27,$F8,$07,$F8,$8D,$F0,$00,$00,$00  ; $6501
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$79,$BF,$FF  ; $6511
    DB $E0,$D1,$84,$0E,$00,$00,$00,$53,$00,$7F,$00,$7F,$00,$00,$FF,$00  ; $6521
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$AC,$00,$80,$00,$80,$A8,$D7,$7F  ; $6531
    DB $F0,$C2,$35,$3E,$00,$30,$00,$53,$00,$66,$00,$7F,$00,$00,$FF,$00  ; $6541
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$BC,$00,$99,$00,$80,$FF,$3F,$FF  ; $6551
    DB $FE,$10,$E4,$0F,$00,$3C,$00,$F1,$00,$79,$00,$3F,$00,$00,$FF,$00  ; $6561
    DB $FF,$00,$FF,$00,$F0,$00,$C3,$00,$0E,$00,$86,$00,$C3,$FF,$E0,$FF  ; $6571
    DB $00,$7B,$07,$3F,$FF,$77,$7F,$B3,$4F,$E0,$33,$FC,$40,$00,$FF,$00  ; $6581
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$1E,$60,$6F  ; $6591
    DB $60,$5F,$E0,$7F,$C0,$9F,$C0,$9F,$C0,$FF,$00,$7F,$00,$00,$F1,$00  ; $65A1
    DB $F0,$00,$E0,$00,$E0,$00,$E0,$00,$E0,$00,$80,$00,$80,$FF,$00,$7F  ; $65B1
    DB $00,$30,$07,$B0,$07,$D0,$06,$F1,$04,$F8,$01,$FC,$01,$00,$FE,$00  ; $65C1
    DB $FF,$00,$FF,$00,$7F,$00,$3F,$00,$0E,$00,$07,$00,$03,$23,$5C,$07  ; $65D1
    DB $F8,$0B,$D4,$43,$38,$47,$30,$07,$E0,$1F,$80,$3D,$C0,$00,$FF,$00  ; $65E1
    DB $FE,$00,$F4,$00,$BC,$00,$B8,$00,$F8,$00,$E0,$00,$C2,$FF,$00,$FF  ; $65F1
    DB $00,$FF,$00,$CF,$00,$EF,$00,$DF,$00,$7B,$00,$1F,$00,$00,$10,$00  ; $6601
    DB $00,$00,$10,$00,$30,$00,$10,$00,$20,$00,$84,$00,$E0,$E8,$07,$72  ; $6611
    DB $01,$41,$00,$07,$00,$FC,$00,$A0,$00,$C1,$00,$27,$00,$00,$3F,$00  ; $6621
    DB $8F,$00,$FF,$00,$FF,$00,$3F,$00,$7F,$00,$BF,$00,$DE,$03,$F7,$38  ; $6631
    DB $C7,$FC,$03,$1B,$04,$7E,$02,$F0,$00,$62,$98,$03,$FF,$00,$F8,$00  ; $6641
    DB $C0,$00,$E0,$00,$E0,$01,$C0,$0F,$00,$07,$00,$00,$00,$FC,$FF,$FE  ; $6651
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8,$F8,$F4  ; $6661
    DB $F4,$FE,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$21,$FF,$84  ; $6671
    DB $FF,$F2,$FF,$F9,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00  ; $6681
    DB $00,$40,$40,$B0,$B0,$E8,$E8,$FF,$FF,$FF,$FF,$FF,$FF,$06,$FF,$42  ; $6691
    DB $FF,$03,$FF,$E5,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00  ; $66A1
    DB $00,$00,$00,$00,$00,$D5,$D5,$FF,$FF,$FF,$FF,$FF,$FF,$09,$FF,$38  ; $66B1
    DB $FF,$E0,$FF,$05,$FF,$83,$FF,$E3,$FF,$7F,$FF,$FF,$FF,$00,$00,$00  ; $66C1
    DB $00,$00,$00,$01,$01,$00,$00,$81,$81,$63,$63,$FF,$FF,$BB,$FF,$5F  ; $66D1
    DB $FF,$FB,$FF,$FF,$FF,$A9,$FF,$C1,$FE,$87,$FE,$C1,$FE,$00,$00,$16  ; $66E1
    DB $16,$AB,$AB,$F4,$F4,$A8,$A8,$C0,$C0,$80,$80,$C0,$C0,$8F,$F0,$FF  ; $66F1
    DB $00,$BF,$00,$BF,$00,$BB,$00,$AD,$00,$9D,$00,$9D,$00,$00,$00,$00  ; $6701
    DB $00,$00,$40,$00,$40,$00,$44,$00,$52,$00,$62,$00,$62  ; $6711

; --------------------------------------------------------------------------
; Bank46_fn37 — Track37
; terminal track (BC=$00FF, sentinel=$FF; $FF-delimited pairs)
; Header: BC=frame_count=$00FF (255d), sentinel=$FF
; Size: 6370 bytes  ($7FFF limit: up to $8000)
; --------------------------------------------------------------------------
Bank46_Track37:
    DB $FF, $00  ; frame_count = $00FF (255d) [lo, hi]
    DB $FF          ; sentinel byte (loop terminator, stored to $FFAB)
    ; data (6367 bytes follow)
    DB $00,$FF,$00,$7F,$00,$EF,$00,$FF,$00,$FD,$00,$7F,$00,$00,$00,$00  ; $6721
    DB $00,$00,$00,$00,$80,$00,$10,$00,$00,$00,$02,$00,$80,$FF,$00,$CF  ; $6731
    DB $00,$CF,$00,$4F,$00,$C7,$00,$C3,$00,$C1,$00,$71,$00,$00,$00,$00  ; $6741
    DB $30,$00,$30,$00,$B0,$00,$38,$00,$3C,$00,$3E,$00,$8E,$3F,$00,$BF  ; $6751
    DB $00,$F1,$04,$83,$00,$81,$00,$F6,$00,$7B,$04,$23,$0C,$00,$CF,$00  ; $6761
    DB $4F,$00,$1F,$00,$7F,$00,$7F,$00,$0F,$00,$86,$00,$DC,$FF,$00,$3F  ; $6771
    DB $00,$F0,$04,$E0,$00,$E0,$01,$F0,$03,$73,$05,$FD,$01,$00,$FF,$00  ; $6781
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$8F,$00,$03,$FF,$00,$FF  ; $6791
    DB $00,$FF,$00,$CF,$00,$EF,$00,$DF,$00,$7B,$00,$1F,$00,$00,$10,$00  ; $67A1
    DB $00,$00,$10,$00,$30,$00,$10,$00,$20,$00,$84,$00,$E0,$FE,$01,$FE  ; $67B1
    DB $01,$F0,$07,$F0,$01,$E0,$00,$E1,$00,$D9,$00,$9D,$00,$00,$1F,$00  ; $67C1
    DB $1F,$00,$0F,$00,$0F,$00,$1F,$00,$1E,$00,$26,$00,$62,$3D,$80,$7F  ; $67D1
    DB $00,$7F,$00,$7F,$00,$76,$00,$77,$00,$F3,$00,$F4,$00,$00,$C2,$00  ; $67E1
    DB $80,$00,$80,$00,$80,$00,$89,$00,$88,$00,$0C,$00,$0F,$7E,$00,$4F  ; $67F1
    DB $20,$9F,$60,$BF,$40,$1F,$C0,$9F,$40,$FF,$00,$7F,$00,$00,$F1,$00  ; $6801
    DB $F0,$00,$E0,$00,$E0,$00,$E0,$00,$E0,$00,$80,$00,$80,$33,$00,$9E  ; $6811
    DB $01,$1C,$03,$38,$07,$70,$0F,$A0,$1F,$40,$3F,$C0,$7F,$00,$CC,$00  ; $6821
    DB $E0,$00,$E0,$00,$C0,$00,$C0,$00,$C0,$00,$80,$00,$00,$20,$FF,$05  ; $6831
    DB $BF,$14,$FE,$04,$5C,$14,$BD,$00,$7C,$12,$9A,$04,$14,$00,$00,$40  ; $6841
    DB $00,$01,$00,$A3,$00,$42,$00,$83,$00,$65,$00,$EB,$00,$BF,$BB,$DF  ; $6851
    DB $DF,$B9,$B9,$34,$04,$FC,$BC,$7F,$3F,$1E,$16,$FF,$FF,$44,$00,$20  ; $6861
    DB $00,$46,$00,$FB,$00,$43,$00,$C0,$00,$E9,$00,$00,$00,$20,$FF,$01  ; $6871
    DB $BF,$04,$FE,$04,$7C,$14,$FD,$00,$FC,$12,$DA,$04,$D4,$00,$00,$40  ; $6881
    DB $00,$01,$00,$83,$00,$02,$00,$03,$00,$25,$00,$2B,$00,$FF,$FF,$FF  ; $6891
    DB $FF,$FF,$FF,$FF,$FF,$EF,$F7,$EF,$F7,$EF,$F7,$EF,$F7,$FF,$FF,$FF  ; $68A1
    DB $FF,$FF,$FF,$FF,$FF,$C7,$FF,$C7,$FF,$C7,$FF,$C7,$FF,$DF,$00,$5F  ; $68B1
    DB $00,$5F,$00,$EF,$00,$EB,$00,$FE,$80,$D6,$80,$D5,$00,$00,$A0,$00  ; $68C1
    DB $A0,$00,$A0,$00,$10,$00,$14,$80,$95,$80,$A9,$00,$2A,$FF,$FE,$FF  ; $68D1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$EA,$FF,$F0,$FF,$F8,$F7,$F0,$FE,$FE,$FF  ; $68E1
    DB $FF,$FF,$FF,$FF,$FF,$EA,$EA,$F0,$F0,$F8,$F8,$F0,$F9,$D5,$00,$D6  ; $68F1
    DB $80,$FE,$00,$EB,$00,$EF,$00,$5F,$00,$5F,$00,$DF,$00,$00,$2A,$80  ; $6901
    DB $A9,$00,$15,$00,$14,$00,$10,$00,$A0,$00,$A0,$00,$A0,$FD,$00,$FF  ; $6911
    DB $00,$7C,$00,$68,$00,$48,$00,$59,$00,$79,$00,$1E,$00,$00,$03,$00  ; $6921
    DB $01,$00,$83,$00,$97,$00,$B7,$00,$A6,$00,$86,$00,$E1,$FD,$00,$FF  ; $6931
    DB $00,$7C,$00,$68,$00,$48,$00,$59,$00,$79,$00,$1E,$00,$00,$03,$00  ; $6941
    DB $01,$00,$83,$00,$97,$00,$B7,$00,$A6,$00,$86,$00,$E1,$77,$00,$0F  ; $6951
    DB $00,$5F,$00,$3F,$00,$7A,$00,$D5,$00,$FD,$00,$1C,$00,$00,$F8,$00  ; $6961
    DB $F0,$00,$E0,$00,$C0,$00,$85,$00,$2A,$00,$02,$00,$E3,$EF,$00,$DF  ; $6971
    DB $00,$96,$00,$06,$00,$06,$00,$55,$00,$7D,$00,$1C,$00,$00,$19,$00  ; $6981
    DB $39,$00,$79,$00,$F9,$00,$F9,$00,$AA,$00,$82,$00,$E3,$7F,$00,$1F  ; $6991
    DB $00,$54,$00,$04,$00,$04,$00,$55,$00,$79,$00,$1C,$00,$00,$F8,$00  ; $69A1
    DB $F8,$00,$FB,$00,$FB,$00,$FB,$00,$AA,$00,$86,$00,$E3,$BF,$00,$FF  ; $69B1
    DB $00,$F7,$00,$F5,$00,$7B,$00,$73,$00,$79,$00,$7C,$00,$00,$4C,$00  ; $69C1
    DB $0C,$00,$08,$00,$0A,$00,$84,$00,$8C,$00,$86,$00,$83,$FF,$00,$ED  ; $69D1
    DB $00,$EB,$00,$FE,$00,$DC,$00,$D1,$00,$7B,$00,$1F,$00,$00,$0E,$00  ; $69E1
    DB $1E,$00,$1C,$00,$19,$00,$33,$00,$2E,$00,$84,$00,$E0,$FF,$00,$FF  ; $69F1
    DB $00,$FE,$00,$FF,$03,$FA,$02,$FE,$06,$FC,$00,$E7,$20,$00,$00,$00  ; $6A01
    DB $00,$01,$00,$00,$00,$05,$00,$01,$00,$1F,$00,$1F,$00,$1E,$CE,$BF  ; $6A11
    DB $FF,$BD,$E1,$B8,$D8,$BE,$C2,$3F,$FF,$7C,$D8,$99,$09,$31,$00,$00  ; $6A21
    DB $00,$1E,$00,$27,$00,$3D,$00,$00,$00,$27,$00,$F6,$00,$B3,$11,$F5  ; $6A31
    DB $30,$FF,$00,$1D,$00,$E7,$00,$7F,$00,$32,$00,$10,$00,$EE,$00,$CF  ; $6A41
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$55,$DE  ; $6A51
    DB $E5,$71,$D7,$6C,$87,$94,$2A,$D5,$00,$40,$00,$26,$80,$FF,$55,$FF  ; $6A61
    DB $04,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$F8,$07,$E0,$1F,$6F,$B7,$A6  ; $6A71
    DB $BB,$AE,$94,$C3,$9C,$2A,$D1,$9F,$00,$A1,$00,$07,$00,$DF,$27,$DF  ; $6A81
    DB $22,$FF,$00,$FF,$00,$FF,$00,$F8,$00,$E0,$1E,$00,$F8,$FB,$FE,$EA  ; $6A91
    DB $7D,$28,$F5,$41,$2C,$0F,$40,$74,$00,$CD,$00,$1A,$00,$FF,$FA,$FF  ; $6AA1
    DB $60,$FF,$20,$FF,$00,$E0,$10,$40,$8B,$00,$37,$00,$ED,$FD,$6D,$CC  ; $6AB1
    DB $36,$3F,$80,$79,$08,$3F,$00,$7E,$00,$FF,$00,$FF,$00,$FF,$69,$FF  ; $6AC1
    DB $00,$E0,$00,$80,$0E,$00,$E1,$00,$8B,$00,$9A,$00,$14,$5F,$E0,$FE  ; $6AD1
    DB $00,$FC,$00,$FB,$00,$87,$00,$BF,$00,$F7,$00,$9F,$00,$E0,$43,$80  ; $6AE1
    DB $07,$00,$07,$00,$0C,$00,$F8,$00,$C1,$00,$08,$00,$62,$5F,$00,$5B  ; $6AF1
    DB $00,$DB,$00,$9B,$00,$BB,$00,$FF,$00,$F7,$00,$F7,$00,$00,$A0,$00  ; $6B01
    DB $A4,$00,$24,$00,$6C,$00,$CC,$00,$00,$00,$A8,$00,$28,$40,$40,$F6  ; $6B11
    DB $F0,$78,$78,$E7,$C7,$5F,$4E,$7F,$76,$3A,$02,$E4,$04,$BF,$00,$0F  ; $6B21
    DB $00,$87,$00,$38,$00,$B1,$00,$89,$00,$FD,$00,$FB,$00,$9F,$03,$F5  ; $6B31
    DB $C5,$FF,$80,$35,$00,$61,$00,$7F,$04,$73,$13,$1B,$0B,$FC,$00,$3A  ; $6B41
    DB $00,$7F,$00,$FF,$00,$FF,$00,$FB,$00,$EC,$00,$F4,$00,$BD,$B1,$98  ; $6B51
    DB $99,$D8,$99,$08,$09,$98,$18,$3C,$3D,$BC,$3F,$A9,$BF,$4E,$00,$66  ; $6B61
    DB $00,$66,$00,$F6,$00,$E7,$00,$C2,$00,$C0,$00,$40,$00,$8C,$8E,$42  ; $6B71
    DB $57,$68,$6B,$24,$FD,$36,$BF,$13,$DF,$33,$FF,$63,$FF,$71,$00,$A8  ; $6B81
    DB $00,$94,$00,$02,$00,$40,$00,$20,$00,$00,$00,$00,$00,$13,$07,$E3  ; $6B91
    DB $CF,$93,$9F,$32,$36,$90,$96,$19,$FF,$03,$FE,$00,$FF,$F8,$00,$30  ; $6BA1
    DB $00,$60,$00,$C9,$00,$69,$00,$00,$00,$01,$00,$00,$00,$F7,$F7,$D9  ; $6BB1
    DB $D9,$EB,$2B,$93,$93,$77,$77,$3F,$3D,$9E,$9F,$E1,$FE,$08,$00,$26  ; $6BC1
    DB $00,$D4,$00,$6C,$00,$88,$00,$C2,$00,$60,$00,$01,$00,$20,$FF,$01  ; $6BD1
    DB $BF,$04,$FE,$04,$7C,$14,$FD,$00,$FC,$12,$DA,$04,$D4,$00,$00,$40  ; $6BE1
    DB $00,$01,$00,$83,$00,$02,$00,$03,$00,$25,$00,$2B,$00,$FE,$7E,$8F  ; $6BF1
    DB $8C,$CF,$CC,$60,$40,$E4,$84,$8A,$02,$9D,$11,$A3,$21,$81,$00,$73  ; $6C01
    DB $00,$33,$00,$BF,$00,$7B,$00,$FD,$00,$EE,$00,$DE,$00,$B3,$11,$F5  ; $6C11
    DB $30,$FF,$00,$1D,$00,$E7,$00,$7F,$00,$32,$00,$10,$00,$EE,$00,$CF  ; $6C21
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$BA,$B2,$9A  ; $6C31
    DB $9A,$CB,$9A,$25,$3D,$F6,$36,$93,$12,$B4,$B7,$6D,$EF,$4D,$00,$65  ; $6C41
    DB $00,$65,$00,$C2,$00,$C9,$00,$ED,$00,$48,$00,$10,$00,$4F,$00,$3F  ; $6C51
    DB $4F,$1C,$BC,$09,$D8,$03,$C1,$0D,$00,$37,$0C,$E5,$0D,$C0,$3F,$80  ; $6C61
    DB $0F,$40,$1F,$20,$0F,$20,$1D,$80,$7F,$00,$F0,$12,$E0,$CE,$00,$38  ; $6C71
    DB $00,$FF,$60,$F1,$00,$83,$00,$0B,$00,$3F,$03,$CF,$86,$00,$31,$00  ; $6C81
    DB $DF,$00,$FB,$00,$EE,$00,$FC,$00,$F4,$00,$C3,$00,$3F,$79,$00,$F3  ; $6C91
    DB $01,$AF,$01,$7E,$00,$F7,$00,$E7,$00,$C3,$80,$87,$00,$00,$D6,$00  ; $6CA1
    DB $8D,$00,$57,$00,$87,$00,$08,$00,$78,$00,$FC,$00,$F8,$F7,$C0,$DE  ; $6CB1
    DB $00,$10,$00,$71,$00,$62,$00,$CE,$00,$1F,$00,$7F,$62,$00,$C8,$00  ; $6CC1
    DB $E1,$00,$EF,$00,$8E,$00,$9D,$00,$31,$00,$F3,$80,$07,$3F,$00,$7F  ; $6CD1
    DB $00,$7F,$00,$F6,$00,$F6,$00,$FF,$40,$DF,$00,$9B,$80,$00,$C4,$00  ; $6CE1
    DB $89,$00,$8B,$00,$1B,$00,$29,$00,$60,$00,$E0,$04,$E0,$F7,$00,$A7  ; $6CF1
    DB $00,$72,$00,$63,$01,$E4,$02,$E6,$03,$F4,$01,$CC,$05,$00,$88,$00  ; $6D01
    DB $DA,$00,$9F,$00,$BC,$01,$3C,$00,$38,$02,$08,$02,$30,$F3,$93,$B4  ; $6D11
    DB $B4,$92,$9A,$D9,$DD,$A8,$AE,$C8,$DF,$A3,$BF,$00,$FF,$6C,$00,$4B  ; $6D21
    DB $00,$65,$00,$22,$00,$51,$00,$20,$00,$40,$00,$00,$00,$61,$7B,$F8  ; $6D31
    DB $FF,$C8,$EF,$10,$3F,$81,$FD,$19,$F9,$02,$F2,$00,$C0,$84,$00,$00  ; $6D41
    DB $00,$10,$00,$C0,$00,$00,$02,$00,$06,$00,$0D,$00,$3F,$E1,$FF,$CC  ; $6D51
    DB $FE,$94,$F6,$94,$D4,$80,$C0,$00,$80,$09,$00,$22,$00,$00,$00,$00  ; $6D61
    DB $01,$00,$09,$00,$2B,$00,$3F,$00,$7F,$00,$FF,$00,$FF,$E3,$FF,$86  ; $6D71
    DB $FF,$82,$D3,$80,$80,$00,$00,$50,$04,$1F,$00,$7F,$00,$00,$00,$00  ; $6D81
    DB $00,$00,$2C,$00,$7F,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$76,$FF,$64  ; $6D91
    DB $FC,$1C,$80,$02,$00,$39,$00,$1C,$00,$3B,$04,$BF,$00,$00,$00,$00  ; $6DA1
    DB $03,$1C,$63,$09,$F6,$09,$F6,$00,$FF,$00,$FF,$00,$FF,$07,$B9,$2C  ; $6DB1
    DB $40,$49,$01,$AC,$00,$51,$00,$A9,$28,$44,$04,$96,$16,$06,$40,$3F  ; $6DC1
    DB $80,$FE,$00,$FF,$00,$FF,$00,$D7,$00,$FB,$00,$69,$80,$1E,$CE,$BF  ; $6DD1
    DB $FF,$BD,$E1,$B8,$D8,$BE,$C2,$3F,$FF,$7C,$D8,$99,$09,$31,$00,$00  ; $6DE1
    DB $00,$1E,$00,$27,$00,$3D,$00,$00,$00,$27,$00,$F6,$00,$BB,$2B,$6F  ; $6DF1
    DB $2F,$7E,$AE,$77,$F6,$D3,$B3,$8D,$B3,$CE,$1F,$28,$3F,$D4,$00,$D0  ; $6E01
    DB $00,$51,$00,$09,$00,$4C,$00,$4C,$00,$E0,$00,$C0,$00,$40,$40,$F6  ; $6E11
    DB $F0,$78,$78,$E7,$C7,$5F,$4E,$7F,$76,$3A,$02,$E4,$04,$BF,$00,$0F  ; $6E21
    DB $00,$87,$00,$38,$00,$B1,$00,$89,$00,$FD,$00,$FB,$00,$40,$40,$F6  ; $6E31
    DB $F0,$78,$78,$E7,$C7,$5F,$4E,$7F,$76,$3A,$02,$E4,$04,$BF,$00,$0F  ; $6E41
    DB $00,$87,$00,$38,$00,$B1,$00,$89,$00,$FD,$00,$FB,$00,$81,$4D,$10  ; $6E51
    DB $E9,$00,$5B,$80,$F7,$28,$FF,$10,$7E,$88,$EE,$34,$F7,$32,$80,$16  ; $6E61
    DB $00,$A4,$00,$08,$00,$00,$00,$81,$00,$11,$00,$08,$00,$34,$A4,$3D  ; $6E71
    DB $31,$D8,$DE,$57,$DF,$B4,$FE,$00,$7F,$A4,$FE,$12,$FE,$40,$0F,$C0  ; $6E81
    DB $06,$21,$00,$20,$00,$01,$00,$80,$00,$01,$00,$01,$00,$76,$15,$D2  ; $6E91
    DB $5F,$08,$7F,$AC,$FF,$22,$F7,$58,$FD,$0C,$EC,$8C,$AF,$0A,$80,$20  ; $6EA1
    DB $00,$80,$00,$00,$00,$08,$00,$02,$00,$13,$00,$50,$00,$7D,$F1,$97  ; $6EB1
    DB $F1,$08,$FB,$24,$FD,$32,$FF,$80,$EF,$C8,$FB,$E2,$F2,$00,$03,$0C  ; $6EC1
    DB $01,$04,$00,$02,$00,$00,$00,$10,$00,$04,$00,$0D,$00,$9F,$07,$B1  ; $6ED1
    DB $15,$FD,$5D,$02,$9E,$1B,$FF,$B2,$FF,$00,$FF,$18,$FD,$00,$E0,$0A  ; $6EE1
    DB $C0,$02,$00,$61,$00,$00,$00,$00,$00,$00,$00,$02,$00,$F0,$0B,$37  ; $6EF1
    DB $56,$F1,$FF,$48,$79,$44,$DE,$A4,$FD,$44,$F2,$02,$9E,$04,$20,$89  ; $6F01
    DB $00,$00,$00,$86,$00,$21,$00,$02,$00,$0D,$00,$61,$00,$B0,$FF,$2D  ; $6F11
    DB $FD,$23,$E1,$84,$84,$6B,$62,$B3,$33,$17,$14,$3C,$1C,$00,$00,$00  ; $6F21
    DB $02,$06,$18,$0B,$70,$9D,$00,$CC,$00,$EB,$00,$E3,$00,$14,$14,$66  ; $6F31
    DB $04,$4F,$0E,$EF,$0F,$89,$09,$7D,$75,$2F,$27,$AB,$2B,$08,$E3,$F8  ; $6F41
    DB $03,$F0,$01,$F0,$00,$F6,$00,$8A,$00,$D8,$00,$D4,$00,$3A,$00,$3C  ; $6F51
    DB $80,$27,$18,$EB,$09,$93,$03,$B2,$33,$31,$11,$91,$93,$00,$FF,$00  ; $6F61
    DB $FF,$00,$FF,$14,$E2,$7C,$80,$4C,$80,$EE,$00,$6C,$00,$FB,$04,$BC  ; $6F71
    DB $43,$FF,$00,$FE,$00,$FB,$01,$F7,$81,$79,$C0,$B0,$C0,$00,$FF,$00  ; $6F81
    DB $FF,$00,$FF,$05,$FA,$0E,$F0,$0E,$70,$0F,$30,$0F,$30,$FF,$00,$F7  ; $6F91
    DB $09,$FD,$01,$B4,$04,$FC,$BC,$FF,$BF,$DE,$D6,$FF,$FF,$00,$FF,$00  ; $6FA1
    DB $FE,$02,$FC,$7B,$80,$43,$00,$40,$00,$29,$00,$00,$00,$3D,$0D,$B5  ; $6FB1
    DB $25,$9B,$09,$40,$40,$39,$30,$90,$10,$0B,$08,$28,$08,$F2,$00,$5A  ; $6FC1
    DB $80,$F6,$00,$BF,$00,$CF,$00,$EF,$00,$F7,$00,$F7,$00,$0C,$8E,$02  ; $6FD1
    DB $17,$68,$6B,$24,$7D,$24,$3F,$08,$4F,$38,$7B,$30,$32,$71,$00,$E8  ; $6FE1
    DB $00,$94,$00,$82,$00,$C0,$00,$B0,$00,$84,$00,$CD,$00,$9F,$03,$F5  ; $6FF1
    DB $C5,$FF,$80,$35,$00,$61,$00,$7F,$04,$73,$13,$1B,$0B,$FC,$00,$3A  ; $7001
    DB $00,$7F,$00,$FF,$00,$FF,$00,$FB,$00,$EC,$00,$F4,$00,$BA,$B2,$9A  ; $7011
    DB $9A,$CB,$9A,$25,$3D,$F6,$36,$93,$12,$B4,$B7,$6D,$EF,$4D,$00,$65  ; $7021
    DB $00,$65,$00,$C2,$00,$C9,$00,$ED,$00,$48,$00,$10,$00,$40,$40,$F6  ; $7031
    DB $F0,$78,$78,$E7,$C7,$5F,$4E,$7F,$76,$3A,$02,$E4,$04,$BF,$00,$0F  ; $7041
    DB $00,$87,$00,$38,$00,$B1,$00,$89,$00,$FD,$00,$FB,$00,$20,$FF,$05  ; $7051
    DB $BF,$14,$FE,$04,$5C,$14,$BD,$00,$7C,$12,$9A,$04,$14,$00,$00,$40  ; $7061
    DB $00,$01,$00,$A3,$00,$42,$00,$83,$00,$65,$00,$EB,$00,$66,$FD,$CA  ; $7071
    DB $8B,$0A,$EB,$0E,$CF,$16,$97,$00,$DD,$8C,$EC,$88,$A9,$02,$00,$74  ; $7081
    DB $00,$14,$00,$30,$00,$68,$00,$22,$00,$13,$00,$56,$00,$7C,$FE,$56  ; $7091
    DB $47,$E8,$6B,$24,$7D,$26,$3F,$08,$5F,$20,$FF,$30,$FE,$01,$00,$B8  ; $70A1
    DB $00,$94,$00,$82,$00,$C0,$00,$A0,$00,$00,$00,$01,$00,$60,$F9,$81  ; $70B1
    DB $F5,$95,$F5,$10,$94,$18,$FD,$30,$F8,$00,$19,$F0,$F9,$06,$00,$0A  ; $70C1
    DB $00,$0A,$00,$6B,$00,$02,$00,$07,$00,$E6,$00,$06,$00,$82,$FF,$37  ; $70D1
    DB $FE,$49,$BF,$48,$79,$C4,$DE,$E4,$FD,$C6,$F2,$06,$9E,$00,$00,$01  ; $70E1
    DB $00,$40,$00,$86,$00,$21,$00,$02,$00,$0D,$00,$61,$00,$F2,$F3,$77  ; $70F1
    DB $76,$F9,$BF,$48,$79,$C4,$DE,$E4,$FD,$86,$B2,$06,$BF,$0C,$00,$89  ; $7101
    DB $00,$40,$00,$86,$00,$21,$00,$02,$00,$4D,$00,$40,$00,$13,$1F,$66  ; $7111
    DB $7F,$82,$D3,$84,$84,$22,$22,$D0,$C0,$DA,$98,$2F,$2F,$E0,$00,$80  ; $7121
    DB $00,$00,$2C,$00,$7B,$DD,$00,$3F,$00,$67,$00,$D0,$00,$C8,$F8,$66  ; $7131
    DB $FE,$41,$CB,$21,$21,$40,$40,$00,$00,$59,$19,$F4,$F4,$07,$00,$01  ; $7141
    DB $00,$00,$34,$00,$DE,$80,$3F,$F0,$0F,$E0,$06,$0B,$00,$72,$73,$FE  ; $7151
    DB $FF,$87,$87,$19,$19,$7F,$48,$FC,$FC,$3F,$1F,$99,$90,$8C,$00,$00  ; $7161
    DB $00,$78,$00,$E6,$00,$B7,$00,$03,$00,$E0,$00,$6F,$00,$34,$C0,$36  ; $7171
    DB $C0,$38,$E8,$BB,$E3,$5F,$66,$5F,$76,$1E,$32,$FE,$40,$0F,$30,$0F  ; $7181
    DB $30,$07,$10,$0C,$10,$81,$18,$81,$08,$C5,$08,$87,$38,$BF,$BB,$DF  ; $7191
    DB $DF,$B9,$B9,$34,$04,$FC,$BC,$7F,$3F,$1E,$16,$FF,$FF,$44,$00,$20  ; $71A1
    DB $00,$46,$00,$FB,$00,$43,$00,$C0,$00,$E9,$00,$00,$00,$BF,$BB,$DF  ; $71B1
    DB $DF,$B9,$B9,$34,$04,$FC,$BC,$7F,$3F,$1E,$16,$FF,$FF,$44,$00,$20  ; $71C1
    DB $00,$46,$00,$FB,$00,$43,$00,$C0,$00,$E9,$00,$00,$00,$BF,$BB,$DF  ; $71D1
    DB $DF,$B9,$B9,$34,$04,$FC,$BC,$7F,$3F,$1E,$16,$FF,$FF,$44,$00,$20  ; $71E1
    DB $00,$46,$00,$FB,$00,$43,$00,$C0,$00,$E9,$00,$00,$00,$61,$7B,$F8  ; $71F1
    DB $FF,$C8,$EF,$10,$3F,$81,$FD,$19,$F9,$02,$F2,$00,$C0,$84,$00,$00  ; $7201
    DB $00,$10,$00,$C0,$00,$00,$02,$00,$06,$00,$0D,$00,$3F,$E1,$FF,$CC  ; $7211
    DB $FE,$94,$F6,$94,$D4,$80,$C0,$00,$80,$7C,$00,$BF,$00,$00,$00,$00  ; $7221
    DB $01,$00,$09,$00,$2B,$00,$3F,$00,$7F,$00,$83,$3F,$7F,$E3,$FF,$86  ; $7231
    DB $FF,$82,$D3,$80,$80,$00,$00,$5F,$00,$BF,$00,$F3,$0C,$00,$00,$00  ; $7241
    DB $00,$00,$2C,$00,$7F,$00,$FF,$00,$E0,$3F,$7F,$FF,$FF,$76,$FF,$64  ; $7251
    DB $FC,$00,$80,$03,$00,$0D,$00,$DF,$00,$FC,$03,$00,$FF,$00,$00,$00  ; $7261
    DB $03,$00,$7F,$00,$FF,$00,$F2,$1F,$3F,$FF,$FF,$FF,$FF,$0C,$8E,$02  ; $7271
    DB $17,$68,$6B,$24,$7D,$24,$3F,$08,$4F,$38,$7B,$30,$32,$71,$00,$E8  ; $7281
    DB $00,$94,$00,$82,$00,$C0,$00,$B0,$00,$84,$00,$CD,$00,$02,$00,$1F  ; $7291
    DB $00,$75,$02,$BC,$03,$7C,$03,$FF,$00,$1E,$E1,$00,$FF,$00,$FD,$03  ; $72A1
    DB $FB,$07,$8F,$3F,$7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FB  ; $72B1
    DB $04,$F3,$0C,$F1,$0E,$30,$CF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF  ; $72C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF  ; $72D1
    DB $00,$FF,$00,$FF,$00,$FF,$00,$1E,$E1,$F8,$07,$03,$FC,$FF,$FF,$FF  ; $72E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$80,$7F,$80  ; $72F1
    DB $7F,$03,$FF,$1E,$FF,$FD,$FF,$DE,$FF,$6E,$FF,$F0,$FF,$FF,$FF,$FF  ; $7301
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$E1,$FF,$CC  ; $7311
    DB $FE,$94,$F6,$94,$D4,$80,$C0,$00,$80,$0F,$00,$3F,$00,$00,$00,$00  ; $7321
    DB $01,$00,$09,$00,$2B,$00,$3F,$00,$7F,$00,$F8,$07,$E7,$76,$FF,$64  ; $7331
    DB $FC,$00,$80,$00,$00,$3F,$00,$7F,$00,$FE,$01,$F8,$07,$00,$00,$00  ; $7341
    DB $03,$00,$7F,$00,$FF,$00,$E0,$1F,$9F,$7F,$7F,$FF,$FF,$00,$FF,$00  ; $7351
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$1F,$FF,$FF,$FF,$3E,$FF,$FF,$FF,$FF  ; $7361
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$00  ; $7371
    DB $FF,$00,$FF,$18,$FF,$FF,$FF,$FF,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF  ; $7381
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$10,$F7,$20  ; $7391
    DB $9E,$13,$EF,$02,$F4,$76,$FF,$AB,$AB,$C2,$CB,$0C,$CE,$08,$00,$01  ; $73A1
    DB $C0,$00,$E0,$03,$F8,$00,$00,$54,$00,$34,$00,$31,$00,$00,$FF,$00  ; $73B1
    DB $FF,$00,$FF,$00,$FF,$00,$FF,$14,$EB,$28,$C7,$10,$CF,$FF,$FF,$FF  ; $73C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EB,$FF,$D7,$FF,$EF,$FF,$00,$FF,$00  ; $73D1
    DB $FE,$00,$E3,$07,$F8,$01,$FE,$02,$FD,$00,$FF,$00,$FF,$FF,$FF,$FD  ; $73E1
    DB $FF,$FC,$FF,$E8,$FF,$FC,$FF,$F9,$FF,$FF,$FF,$FF,$FF,$20,$D9,$A3  ; $73F1
    DB $1C,$5F,$A0,$E1,$1E,$80,$7F,$00,$FF,$03,$FC,$01,$FE,$1E,$FF,$40  ; $7401
    DB $FF,$00,$FF,$1E,$FF,$78,$FF,$FF,$FF,$FC,$FF,$FE,$FF,$00,$7F,$00  ; $7411
    DB $EF,$C0,$3B,$78,$86,$2F,$D0,$61,$9E,$80,$7F,$00,$FF,$BF,$FF,$17  ; $7421
    DB $FF,$07,$FF,$01,$FF,$D0,$FF,$9E,$FF,$7F,$FF,$FF,$FF,$00,$FF,$00  ; $7431
    DB $FF,$00,$FF,$00,$01,$07,$98,$FC,$03,$00,$FF,$00,$FF,$FF,$FF,$FF  ; $7441
    DB $FF,$55,$FF,$FE,$FF,$60,$FF,$03,$FF,$FF,$FF,$FF,$FF,$00,$FF,$00  ; $7451
    DB $FF,$00,$0F,$78,$87,$8F,$70,$06,$F9,$03,$FC,$04,$FB,$FF,$FF,$AF  ; $7461
    DB $FF,$F5,$FF,$00,$FF,$70,$FF,$F9,$FF,$FC,$FF,$FB,$FF,$00,$FF,$45  ; $7471
    DB $C7,$11,$91,$3C,$BE,$14,$94,$5A,$DE,$05,$D7,$63,$E2,$00,$FF,$38  ; $7481
    DB $FF,$6E,$FF,$41,$FF,$6B,$FF,$21,$FF,$28,$FF,$1C,$FF,$01,$FF,$B6  ; $7491
    DB $FE,$48,$C8,$80,$80,$24,$24,$17,$17,$B9,$BF,$FF,$00,$00,$FF,$01  ; $74A1
    DB $FF,$37,$FF,$7F,$FF,$DB,$FF,$E8,$FF,$40,$FF,$00,$FF,$E0,$FF,$38  ; $74B1
    DB $3F,$26,$26,$20,$20,$C5,$C5,$96,$96,$FD,$FF,$FF,$00,$00,$FF,$C0  ; $74C1
    DB $FF,$D9,$FF,$DF,$FF,$3A,$FF,$69,$FF,$00,$FF,$00,$FF,$00,$FF,$E8  ; $74D1
    DB $FF,$14,$17,$01,$01,$30,$30,$C6,$C6,$84,$85,$FF,$00,$00,$FF,$00  ; $74E1
    DB $FF,$E8,$FF,$FE,$FF,$CF,$FF,$39,$FF,$7A,$FF,$00,$FF,$22,$E3,$59  ; $74F1
    DB $D9,$91,$91,$90,$98,$2C,$2C,$61,$61,$D9,$F9,$FF,$00,$1C,$FF,$26  ; $7501
    DB $FF,$6E,$FF,$67,$FF,$D3,$FF,$9E,$FF,$06,$FF,$00,$FF,$04,$FC,$10  ; $7511
    DB $F0,$98,$98,$02,$02,$4F,$4F,$10,$90,$E0,$E0,$FF,$00,$03,$FF,$0F  ; $7521
    DB $FF,$67,$FF,$FD,$FF,$B0,$FF,$6F,$FF,$1F,$FF,$00,$FF,$80,$FF,$24  ; $7531
    DB $3C,$51,$51,$DA,$DA,$0E,$0E,$1A,$1B,$C9,$F9,$FF,$00,$00,$FF,$C3  ; $7541
    DB $FF,$AE,$FF,$25,$FF,$F1,$FF,$E4,$FF,$06,$FF,$00,$FF,$53,$F2,$21  ; $7551
    DB $E0,$4B,$CA,$47,$C6,$23,$E2,$4D,$CE,$45,$C6,$87,$86,$0C,$FF,$1E  ; $7561
    DB $FF,$34,$FF,$38,$FF,$1C,$FF,$30,$FF,$38,$FF,$78,$FF,$8F,$8E,$8B  ; $7571
    DB $8A,$F3,$F2,$47,$C6,$43,$C2,$2F,$EE,$25,$E6,$0B,$CA,$70,$FF,$74  ; $7581
    DB $FF,$0C,$FF,$38,$FF,$3C,$FF,$10,$FF,$18,$FF,$34,$FF,$47,$C6,$45  ; $7591
    DB $C4,$49,$C8,$29,$E8,$41,$C0,$27,$E6,$05,$E4,$11,$F2,$38,$FF,$3A  ; $75A1
    DB $FF,$36,$FF,$16,$FF,$3E,$FF,$18,$FF,$1A,$FF,$0C,$FF,$33,$F2,$47  ; $75B1
    DB $C6,$8D,$8E,$73,$72,$4B,$5A,$09,$08,$81,$80,$67,$E6,$0C,$FF,$38  ; $75C1
    DB $FF,$70,$FF,$8C,$FF,$A4,$FF,$F6,$FF,$7E,$FF,$18,$FF,$23,$E6,$0B  ; $75D1
    DB $CA,$03,$C2,$65,$E4,$29,$A8,$89,$88,$19,$18,$09,$08,$18,$FF,$34  ; $75E1
    DB $FF,$3C,$FF,$1A,$FF,$56,$FF,$76,$FF,$E6,$FF,$F6,$FF,$93,$92,$33  ; $75F1
    DB $B2,$41,$C2,$35,$F6,$1F,$DE,$49,$C8,$1D,$9C,$23,$A6,$6C,$FF,$4C  ; $7601
    DB $FF,$3C,$FF,$08,$FF,$20,$FF,$36,$FF,$62,$FF,$58,$FF,$FF,$FF,$FF  ; $7611
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7621
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7631
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7641
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00  ; $7651
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; $7661
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$FF  ; $7671
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$00,$00,$00  ; $7681
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF  ; $7691
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76A1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76B1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76D1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $76F1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7701
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7711
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7721
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7731
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7741
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7751
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7761
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7771
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7781
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7791
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77A1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77B1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77D1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $77F1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7801
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7811
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7821
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7831
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7841
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7851
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7861
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7871
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7881
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7891
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78A1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78B1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78D1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $78F1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7901
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7911
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7921
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7931
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7941
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7951
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7961
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7971
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7981
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7991
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79A1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79B1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79C1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79D1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79E1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $79F1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7A91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AD1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7AF1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7B91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BD1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7BF1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7C91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CD1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7CF1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7D91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DD1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7DF1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7E91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7EA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7EB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7EC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7ED1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7EE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7EF1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F01
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F11
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F21
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F31
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F41
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F51
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F61
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F71
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F81
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7F91
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FA1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FB1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FC1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FD1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FE1
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; $7FF1

