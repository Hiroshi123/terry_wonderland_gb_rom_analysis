; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 79  (Battle sub (slime battle))
; ==========================================================================
;
; Bank 79 memory map:
;   File offset $13C000-$13FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 79
; ==========================================================================

SECTION "Bank 79", ROMX[$4000], BANK[79]

; --- Data bank: hex dump of first 128 bytes ---
; $4000: 4F FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4010: FF 00 FF 3C FF 42 FF 42 FF 42 FF 42 FF 42 FF 3C
; $4020: FF 00 FF 10 FF 30 FF 10 FF 10 FF 10 FF 10 FF 38
; $4030: FF 00 FF 3C FF 42 FF 44 FF 08 FF 10 FF 20 FF 7E
; $4040: FF 00 FF 7E FF 02 FF 04 FF 3C FF 02 FF 42 FF 3C
; $4050: FF 00 FF 04 FF 0C FF 14 FF 24 FF 44 FF 7E FF 04
; $4060: FF 00 FF 7E FF 40 FF 40 FF 7C FF 02 FF 42 FF 3C
; $4070: FF 00 FF 3C FF 40 FF 40 FF 7C FF 42 FF 42 FF 3C
;
; Pattern: mixed data (zeros=15 FFs=135 ascii=82/256)
