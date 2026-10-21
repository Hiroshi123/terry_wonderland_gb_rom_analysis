; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 102  (Data bank 102 (no RST$10 dispatch table))
; ==========================================================================
;
; Bank 102 memory map:
;   File offset $198000-$19BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 102
; ==========================================================================

SECTION "Bank 102", ROMX[$4000], BANK[102]

; --- Data bank: hex dump of first 128 bytes ---
; $4000: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4010: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4020: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4030: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4040: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4050: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4060: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4070: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
;
; Pattern: mostly $FF — uninitialized / padding bank
