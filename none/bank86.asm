; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 86  (Battle phase bank 86 (Antbear battle))
; ==========================================================================
;
; Bank 86 memory map:
;   File offset $158000-$15BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 86
; ==========================================================================

SECTION "Bank 86", ROMX[$4000], BANK[86]

; --- Data bank: hex dump of first 128 bytes ---
; $4000: 56 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4010: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4020: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4030: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4040: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4050: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4060: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
; $4070: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
;
; Pattern: mostly $FF — uninitialized / padding bank
