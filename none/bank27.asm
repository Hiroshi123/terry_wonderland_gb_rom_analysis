; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 27  (Data bank 27 (no RST$10 dispatch table))
; ==========================================================================
;
; Bank 27 memory map:
;   File offset $6C000-$6FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 27
; ==========================================================================

SECTION "Bank 27", ROMX[$4000], BANK[27]

; --- Data bank: hex dump of first 128 bytes ---
; $4000: 1B FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4010: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4020: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4030: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4040: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4050: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4060: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4070: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
;
; Pattern: mostly $FF — uninitialized / padding bank
