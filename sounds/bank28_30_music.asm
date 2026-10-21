; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Banks 28, 29, 30  (Music / sound score data)
; ============================================================================
;
; File offsets:
;   Bank 28: $70000-$73FFF  (self-ID byte $4000 = $1C = 28)
;   Bank 29: $74000-$77FFF  (self-ID byte $4000 = $1D = 29)
;   Bank 30: $78000-$7BFFF  (self-ID byte $4000 = $1E = 30)
;
; These three banks contain MUSIC SCORE DATA for the sound engine.
; They are data-only banks (no executable code).  The sound driver
; (ROM0 functions $0568/$05A7/$05BA and their callees) reads this data
; when playing background music.
;
; STRUCTURE: MUSIC TRACK TABLE + CHANNEL SEQUENCE DATA
;
; Each bank begins with a flat table of 4-byte records:
;   {phase_offset_lo, phase_offset_hi, channel_data_ptr_lo, channel_data_ptr_hi}
;
; - phase_offset (16-bit LE): start offset within the channel sequence
;     (used to phase-shift voices for round/canon effects).
;     Repeating set: $0000, $0034, $014E, $0268, $0382 (each 282 apart).
; - channel_data_ptr (16-bit LE): ROM address within this bank of the
;     channel sequence stream.
;
; Multiple records can share the same channel_data_ptr but have different
; phase offsets — this implements multi-voice canon (each voice plays the
; same melody but starts at a different point, like a round).
;
; CHANNEL SEQUENCE FORMAT:
; The data at each channel_data_ptr is a stream of bytes interpreted by
; the sound engine.  Observed byte patterns:
;
;   Header: 4 bytes (song/channel metadata — count, channel ID, etc.)
;   Then a sequence of:
;     0x00-0x3F: note data, possibly {pitch, duration} pairs
;     0xA0 xx:   attribute command — instrument, volume, or envelope set
;     0xC0 xx:   loop-end marker (xx = loop count; $FF = infinite, $FE = 254)
;     0xC1 xx:   call sub-pattern (xx = pattern index or relative offset)
;     0xFF:      end-of-track marker (usually followed by 0x00)
;
; Pitch values observed: $20-$35 (corresponding to GBC note frequencies).
; Duration values: $04, $06, $08, $0A, $0C, $12, $18, $24 (frame counts).
;
; BANK 28 DATA  ($70000)
; =======================
; Self-ID: $1C
; Track table begins at $4001.
; Channel sequence data begins at $4085.
;
; Track table sample (4-byte records, $4001+):
;   $0000, $4085   ← voice 0: phase offset 0, data @ $4085
;   $011A, $4085   ← voice 1: phase offset $011A, same data (canon)
;   $0034, $4085   ← voice 2: phase offset $0034
;   $014E, $4085   ← voice 3: phase offset $014E
;   $0268, $4085   ← voice 4: phase offset $0268
;   $0382, $4085   ← voice 5: phase offset $0382
;   $0034, $408A   ← next track: new data block @ $408A
;   $014E, $42FB   ← ...
;   $0268, $458A
;   ...
;
; Data at $4085 (channel sequence stream):
;   00 00 00 00 FF  ← 4-byte header + $FF (end/reset?)
;   04 00 0C 00     ← header continuation
;   C1 35           ← call sub-pattern $35
;   2A 12           ← note $2A (A4?), duration $12
;   2A 06           ← note $2A, duration $06
;   C1 5F           ← call sub-pattern $5F
;   29 18           ← note $29, duration $18
;   30 18           ← note $30, duration $18
;   35 18           ← note $35, duration $18
;   C0 FF           ← loop-end: loop forever
;   35 18           ← (loop body continues)
;   C1 60           ← call sub-pattern $60
;   35 18           ← note $35
;   C0 FE           ← loop-end: loop 254 times
;   ...
;   A0 07           ← attribute command (instrument/volume = 7)
;   ...
;
; BANK 29 DATA  ($74000)
; =======================
; Self-ID: $1D
; Contains a larger set of tracks with varied channel_data_ptrs,
; suggesting this bank holds different songs (field, dungeon, boss BGM).
;
; Track table sample:
;   $0034, $4059   ← track 0, voice 0: data @ $4059
;   $014E, $43AE   ← track 0, voice 1: data @ $43AE
;   $0268, $476B   ← track 0, voice 2
;   $0034, $4C59   ← track 1, voice 0: data @ $4C59
;   $014E, $4E30   ← track 1, voice 1
;   $0268, $5009   ← track 1, voice 2
;   $0034, $524D   ← track 2, voice 0
;   $014E, $54CE   ← track 2, voice 1
;   $0268, $57C7   ← track 2, voice 2
;   $0382, $5A78   ← track 2, voice 3
;   $0034, $5ADF   ← track 3, voice 0
;   ...
; Phase offsets {$0034, $014E, $0268, $0382} cycle through voices.
; Each track group has a fixed number of voices (2-4 depending on song).
;
; BANK 30 DATA  ($78000)
; =======================
; Self-ID: $1E
; Shorter tracks with simpler channel data (likely sound effects or
; shorter jingles: victory fanfare, level-up, item get, etc.).
;
; Track table sample:
;   $0034, $41AD   ← data @ $41AD
;   $014E, $4212   ← data @ $4212
;   $0268, $425F
;   $0034, $4282
;   $014E, $42A3
;   $0034, $42C4
;   $014E, $43E1
;   $0268, $44B4
;   $0000, $4583   ← phase 0 (non-round, single-voice track)
;   $011A, $45A4
;   ...
;
; Data at $41AD (bank 30):
;   04 00 0F 00     ← 4-byte header
;   C1 2F           ← call sub-pattern $2F
;   24 0A           ← note $24 (C4), duration 10
;   A0 06           ← attribute command (param 6)
;   24 04           ← note $24, duration 4
;   A0 0F           ← attribute command (param $0F)
;   24 04           ← note $24, duration 4
;   24 08           ← note $24, duration 8
;   25 08           ← note $25, duration 8
;   25 08           ← ...
;   24 08
;   22 08
;   22 08
;   24 06           ← note $24, duration 6
;   14 06 15 06 17 06 19 06 1B 06  ← rising scale passage

SECTION "Bank28_MusicData", ROMX[$4000], BANK[$1C]

Bank28_SelfID:                              ; $4000
    DB $1C                                 ; bank self-ID = 28

Bank28_TrackTable:                          ; $4001
    ; 4-byte records: {phase_offset_16, channel_data_ptr_16}
    ; Voice groups for each song (multiple voices share same data_ptr):
    DW $0000, $4085                        ; song A, voice 0 (no phase shift)
    DW $011A, $4085                        ; song A, voice 1 (canon +$011A)
    DW $0034, $4085                        ; song A, voice 2
    DW $014E, $4085                        ; song A, voice 3
    DW $0268, $4085                        ; song A, voice 4
    DW $0382, $4085                        ; song A, voice 5
    DW $0034, $408A                        ; song B, voice 0 → $408A
    DW $014E, $42FB                        ; song B, voice 1 → $42FB
    DW $0268, $458A                        ; song B, voice 2 → $458A
    DW $0034, $4813                        ; song C, voice 0 → $4813
    DW $014E, $4AF3                        ; song C, voice 1 → $4AF3
    ; ... (continues through $7FFF)

Bank28_ChannelData_A:                       ; $4085
    ; Song A channel sequence (shared by all 6 voices, different phase offsets)
    DB $00,$00,$00,$00,$FF                 ; header
    DB $04,$00,$0C,$00                     ; header cont.
    DB $C1,$35                             ; call sub-pattern $35
    DB $2A,$12                             ; note A4, dur 18
    DB $2A,$06                             ; note A4, dur 6
    DB $C1,$5F                             ; call sub-pattern $5F
    DB $29,$18                             ; note G#4, dur 24
    DB $30,$18                             ; note F4, dur 24
    DB $35,$18                             ; note B4, dur 24
    DB $35,$18
    DB $C0,$FF                             ; loop forever
    ; ... (sequence data continues)


SECTION "Bank29_MusicData", ROMX[$4000], BANK[$1D]

Bank29_SelfID:                              ; $4000
    DB $1D                                 ; bank self-ID = 29

Bank29_TrackTable:                          ; $4001
    ; Field / dungeon BGM tracks (each with 2-4 canon voices)
    DW $0034, $4059                        ; song 0, v0 → $4059
    DW $014E, $43AE                        ; song 0, v1 → $43AE
    DW $0268, $476B                        ; song 0, v2 → $476B
    DW $0034, $4C59                        ; song 1, v0 → $4C59
    DW $014E, $4E30                        ; song 1, v1 → $4E30
    DW $0268, $5009                        ; song 1, v2 → $5009
    DW $0034, $524D                        ; song 2, v0
    DW $014E, $54CE                        ; song 2, v1
    DW $0268, $57C7                        ; song 2, v2
    DW $0382, $5A78                        ; song 2, v3 (4-voice round)
    ; ... (continues)


SECTION "Bank30_MusicData", ROMX[$4000], BANK[$1E]

Bank30_SelfID:                              ; $4000
    DB $1E                                 ; bank self-ID = 30

Bank30_TrackTable:                          ; $4001
    ; Jingle / fanfare tracks (shorter, fewer voices)
    DW $0034, $41AD                        ; jingle A → $41AD
    DW $014E, $4212                        ; jingle A, v1 → $4212
    DW $0268, $425F                        ; jingle A, v2 → $425F
    DW $0034, $4282                        ; jingle B → $4282
    DW $014E, $42A3                        ; jingle B, v1 → $42A3
    DW $0034, $42C4                        ; jingle C → $42C4
    DW $014E, $43E1                        ; jingle C, v1 → $43E1
    DW $0268, $44B4                        ; jingle C, v2 → $44B4
    DW $0000, $4583                        ; jingle D (single voice) → $4583
    DW $011A, $45A4                        ; jingle D, v1
    ; ...

Bank30_ChannelData_A:                       ; $41AD
    ; Jingle A (likely: level-up or item-get fanfare)
    DB $04,$00,$0F,$00                     ; header
    DB $C1,$2F                             ; call sub-pattern $2F
    DB $24,$0A                             ; note C4, dur 10
    DB $A0,$06                             ; attribute: param 6
    DB $24,$04                             ; note C4, dur 4
    DB $A0,$0F                             ; attribute: param $0F
    DB $24,$04                             ; note C4, dur 4
    DB $24,$08,$25,$08,$25,$08,$25,$08     ; C-C#-C#-C# repeated
    DB $24,$08,$24,$08,$22,$08,$22,$08     ; C-C-Bb-Bb
    DB $24,$06                             ; note C4, dur 6
    DB $14,$06,$15,$06,$17,$06,$19,$06,$1B,$06  ; rising scale G3-A-B-C-D
    ; ... (continues to $FF end marker)
