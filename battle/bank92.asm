; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 92  (Monster management sub bank 92)
; ==========================================================================
;
; Bank 92 memory map:
;   File offset $170000-$173FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 92
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10
;
; Function table at $170001 (bank 92 $4001):
;   fn0: $4005
;   fn1: $408D
; ==========================================================================

SECTION "Bank 92", ROMX[$4000], BANK[92]

; ────────────────────────────────────────────────────────────
; Bank92_Fn0  ($4005)
; ────────────────────────────────────────────────────────────
Bank92_Fn0:
    LD A,($DD60)                            ; $4005  [FA 60 DD]
    OR A                                    ; $4008  [B7]
    RET Z                                   ; $4009  [C8]
    LD DE,$4071                             ; $400A  [11 71 40]
    CALL $40FC                              ; $400D  [CD FC 40]
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
; Bank92_Fn1  ($408D)
; ────────────────────────────────────────────────────────────
Bank92_Fn1:
    LD A,$01                                ; $408D  [3E 01]
    LD ($DD62),A                            ; $408F  [EA 62 DD]
    LD A,($DD68)                            ; $4092  [FA 68 DD]
    OR A                                    ; $4095  [B7]
    JR Z,$40AA                              ; $4096  [28 12]
    LD A,($DB54)                            ; $4098  [FA 54 DB]
    CP $07                                  ; $409B  [FE 07]
    JR NC,$40E5                             ; $409D  [30 46]
    ADD A,A                                 ; $409F  [87]
    LD HL,$40EE                             ; $40A0  [21 EE 40]
    ADD A,L                                 ; $40A3  [85]
    LD L,A                                  ; $40A4  [6F]
    LD A,$00                                ; $40A5  [3E 00]
    ADC A,H                                 ; $40A7  [8C]
    LD H,A                                  ; $40A8  [67]
    LD A,(HL)                               ; $40A9  [7E]
    LD HL,$FFC3                             ; $40AA  [21 C3 FF]
    LD A,A                                  ; $40AD  [7F]
    LD (HL+),A                              ; $40AE  [22]
    LD A,$00                                ; $40AF  [3E 00]
    LD (HL+),A                              ; $40B1  [22]
    LD A,$60                                ; $40B2  [3E 60]
    LD (HL+),A                              ; $40B4  [22]
    LD A,$00                                ; $40B5  [3E 00]
    LD (HL+),A                              ; $40B7  [22]
    LD A,($DAA4)                            ; $40B8  [FA A4 DA]
    LD (HL+),A                              ; $40BB  [22]
    LD A,$00                                ; $40BC  [3E 00]
    LD (HL+),A                              ; $40BE  [22]
    LD A,$00                                ; $40BF  [3E 00]
    LD (HL+),A                              ; $40C1  [22]
    LD A,$00                                ; $40C2  [3E 00]
    LD (HL+),A                              ; $40C4  [22]
    LD A,$01                                ; $40C5  [3E 01]
    LD ($DD60),A                            ; $40C7  [EA 60 DD]
    LD HL,$DD63                             ; $40CA  [21 63 DD]
    LD A,L                                  ; $40CD  [7D]
    LD ($D7B4),A                            ; $40CE  [EA B4 D7]
    LD A,H                                  ; $40D1  [7C]
    LD ($D7B5),A                            ; $40D2  [EA B5 D7]
    LD HL,$0205                             ; $40D5  [21 05 02]
    RST $10                                 ; $40D8  [D7]
    LD HL,$DD62                             ; $40D9  [21 62 DD]
    LD A,L                                  ; $40DC  [7D]
    LD ($D7B4),A                            ; $40DD  [EA B4 D7]
    LD A,H                                  ; $40E0  [7C]
    LD ($D7B5),A                            ; $40E1  [EA B5 D7]
    RET                                     ; $40E4  [C9]

