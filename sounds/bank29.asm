; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 29  (Music engine bank 29)
; ==========================================================================
;
; Bank 29 memory map:
;   File offset $74000-$77FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 29
; ==========================================================================

SECTION "Bank 29", ROMX[$4000], BANK[29]

; --- Data bank: hex dump of first 128 bytes ---
; $4000: 1D 34 00 59 40 4E 01 AE 43 68 02 6B 47 34 00 59
; $4010: 4C 4E 01 30 4E 68 02 09 50 34 00 4D 52 4E 01 CE
; $4020: 54 68 02 C7 57 82 03 78 5A 34 00 DF 5A 4E 01 0C
; $4030: 5F 68 02 A9 62 34 00 E9 65 4E 01 B6 66 68 02 79
; $4040: 67 34 00 A0 68 4E 01 C9 6A 68 02 D8 6C 34 00 E6
; $4050: 6E 4E 01 85 71 68 02 3E 75 08 01 07 00 FD FE A0
; $4060: 09 A3 02 C4 20 24 03 27 03 BF FC 06 00 25 03 22
; $4070: 03 B3 FC 0A 00 25 03 29 03 BB FC 0E 00 A0 08 20
;
; Pattern: mixed data (zeros=23 FFs=0 ascii=105/256)
