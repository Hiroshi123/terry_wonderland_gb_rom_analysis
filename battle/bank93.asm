; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 93  (Battle sub bank 93)
; ==========================================================================
;
; Bank 93 memory map:
;   File offset $174000-$177FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 93
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10
;
; Function table at $174001 (bank 93 $4001):
;   fn0: $4005
;   fn1: $40B3
; ==========================================================================

SECTION "Bank 93", ROMX[$4000], BANK[93]

; ────────────────────────────────────────────────────────────
; Bank93_Fn0  ($4005)
; ────────────────────────────────────────────────────────────
Bank93_Fn0:
    LD A,($DD60)                            ; $4005  [FA 60 DD]
    OR A                                    ; $4008  [B7]
    RET Z                                   ; $4009  [C8]
    LD DE,$4071                             ; $400A  [11 71 40]
    CALL $4122                              ; $400D  [CD 22 41]
    LD A,($DD68)                            ; $4010  [FA 68 DD]
    OR A                                    ; $4013  [B7]
    JR Z,$4021                              ; $4014  [28 0B]
    LD A,($DAA4)                            ; $4016  [FA A4 DA]
    CP $03                                  ; $4019  [FE 03]
    JR Z,$4021                              ; $401B  [28 04]
    CP $04                                  ; $401D  [FE 04]
    JR NZ,$4031                             ; $401F  [20 10]
    LD HL,$FFC3                             ; $4021  [21 C3 FF]
    INC (HL)                                ; $4024  [34]
    LD HL,$FFC3                             ; $4025  [21 C3 FF]
    INC (HL)                                ; $4028  [34]
    LD HL,$FFC3                             ; $4029  [21 C3 FF]
    INC (HL)                                ; $402C  [34]
    LD HL,$FFC3                             ; $402D  [21 C3 FF]
    INC (HL)                                ; $4030  [34]
    LD A,($DD66)                            ; $4031  [FA 66 DD]
    LDH ($C8),A                             ; $4034  [E0 C8]
    LD A,($DD62)                            ; $4036  [FA 62 DD]
    OR A                                    ; $4039  [B7]
    JR NZ,$4041                             ; $403A  [20 05]
    LD A,$00                                ; $403C  [3E 00]
    LD ($DD60),A                            ; $403E  [EA 60 DD]
    LD A,($DD68)                            ; $4041  [FA 68 DD]
    OR A                                    ; $4044  [B7]
    RET NZ                                  ; $4045  [C0]
    LD A,($DAA4)                            ; $4046  [FA A4 DA]
    CP $03                                  ; $4049  [FE 03]
    JR Z,$4051                              ; $404B  [28 04]
    CP $04                                  ; $404D  [FE 04]
    JR NZ,$4061                             ; $404F  [20 10]
    LDH A,($C3)                             ; $4051  [F0 C3]
    CP $D0                                  ; $4053  [FE D0]
    RET C                                   ; $4055  [D8]
    LD A,$04                                ; $4056  [3E 04]
    LD ($DD65),A                            ; $4058  [EA 65 DD]
    LD A,$01                                ; $405B  [3E 01]
    LD ($DD68),A                            ; $405D  [EA 68 DD]
    RET                                     ; $4060  [C9]

; ────────────────────────────────────────────────────────────
; Bank93_Fn1  ($40B3)
; ────────────────────────────────────────────────────────────
Bank93_Fn1:
    LD A,$01                                ; $40B3  [3E 01]
    LD ($DD62),A                            ; $40B5  [EA 62 DD]
    LD A,($DD68)                            ; $40B8  [FA 68 DD]
    OR A                                    ; $40BB  [B7]
    JR Z,$40D0                              ; $40BC  [28 12]
    LD A,($DB54)                            ; $40BE  [FA 54 DB]
    CP $07                                  ; $40C1  [FE 07]
    JR NC,$410B                             ; $40C3  [30 46]
    ADD A,A                                 ; $40C5  [87]
    LD HL,$4114                             ; $40C6  [21 14 41]
    ADD A,L                                 ; $40C9  [85]
    LD L,A                                  ; $40CA  [6F]
    LD A,$00                                ; $40CB  [3E 00]
    ADC A,H                                 ; $40CD  [8C]
    LD H,A                                  ; $40CE  [67]
    LD A,(HL)                               ; $40CF  [7E]
    LD HL,$FFC3                             ; $40D0  [21 C3 FF]
    LD A,A                                  ; $40D3  [7F]
    LD (HL+),A                              ; $40D4  [22]
    LD A,$00                                ; $40D5  [3E 00]
    LD (HL+),A                              ; $40D7  [22]
    LD A,$60                                ; $40D8  [3E 60]
    LD (HL+),A                              ; $40DA  [22]
    LD A,$00                                ; $40DB  [3E 00]
    LD (HL+),A                              ; $40DD  [22]
    LD A,($DAA4)                            ; $40DE  [FA A4 DA]
    LD (HL+),A                              ; $40E1  [22]
    LD A,$00                                ; $40E2  [3E 00]
    LD (HL+),A                              ; $40E4  [22]
    LD A,$00                                ; $40E5  [3E 00]
    LD (HL+),A                              ; $40E7  [22]
    LD A,$00                                ; $40E8  [3E 00]
    LD (HL+),A                              ; $40EA  [22]
    LD A,$01                                ; $40EB  [3E 01]
    LD ($DD60),A                            ; $40ED  [EA 60 DD]
    LD HL,$DD63                             ; $40F0  [21 63 DD]
    LD A,L                                  ; $40F3  [7D]
    LD ($D7B4),A                            ; $40F4  [EA B4 D7]
    LD A,H                                  ; $40F7  [7C]
    LD ($D7B5),A                            ; $40F8  [EA B5 D7]
    LD HL,$0205                             ; $40FB  [21 05 02]
    RST $10                                 ; $40FE  [D7]
    LD HL,$DD62                             ; $40FF  [21 62 DD]
    LD A,L                                  ; $4102  [7D]
    LD ($D7B4),A                            ; $4103  [EA B4 D7]
    LD A,H                                  ; $4106  [7C]
    LD ($D7B5),A                            ; $4107  [EA B5 D7]
    RET                                     ; $410A  [C9]

