; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 94  (Battle sub bank 94)
; ==========================================================================
;
; Bank 94 memory map:
;   File offset $178000-$17BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 94
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10
;
; Function table at $178001 (bank 94 $4001):
;   fn0: $4005
;   fn1: $40CB
; ==========================================================================

SECTION "Bank 94", ROMX[$4000], BANK[94]

; ────────────────────────────────────────────────────────────
; Bank94_Fn0  ($4005)
; ────────────────────────────────────────────────────────────
Bank94_Fn0:
    LD A,($DD60)                            ; $4005  [FA 60 DD]
    OR A                                    ; $4008  [B7]
    RET Z                                   ; $4009  [C8]
    LD DE,$4071                             ; $400A  [11 71 40]
    CALL $413A                              ; $400D  [CD 3A 41]
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
; Bank94_Fn1  ($40CB)
; ────────────────────────────────────────────────────────────
Bank94_Fn1:
    LD A,$01                                ; $40CB  [3E 01]
    LD ($DD62),A                            ; $40CD  [EA 62 DD]
    LD A,($DD68)                            ; $40D0  [FA 68 DD]
    OR A                                    ; $40D3  [B7]
    JR Z,$40E8                              ; $40D4  [28 12]
    LD A,($DB54)                            ; $40D6  [FA 54 DB]
    CP $07                                  ; $40D9  [FE 07]
    JR NC,$4123                             ; $40DB  [30 46]
    ADD A,A                                 ; $40DD  [87]
    LD HL,$412C                             ; $40DE  [21 2C 41]
    ADD A,L                                 ; $40E1  [85]
    LD L,A                                  ; $40E2  [6F]
    LD A,$00                                ; $40E3  [3E 00]
    ADC A,H                                 ; $40E5  [8C]
    LD H,A                                  ; $40E6  [67]
    LD A,(HL)                               ; $40E7  [7E]
    LD HL,$FFC3                             ; $40E8  [21 C3 FF]
    LD A,A                                  ; $40EB  [7F]
    LD (HL+),A                              ; $40EC  [22]
    LD A,$00                                ; $40ED  [3E 00]
    LD (HL+),A                              ; $40EF  [22]
    LD A,$60                                ; $40F0  [3E 60]
    LD (HL+),A                              ; $40F2  [22]
    LD A,$00                                ; $40F3  [3E 00]
    LD (HL+),A                              ; $40F5  [22]
    LD A,($DAA4)                            ; $40F6  [FA A4 DA]
    LD (HL+),A                              ; $40F9  [22]
    LD A,$00                                ; $40FA  [3E 00]
    LD (HL+),A                              ; $40FC  [22]
    LD A,$00                                ; $40FD  [3E 00]
    LD (HL+),A                              ; $40FF  [22]
    LD A,$00                                ; $4100  [3E 00]
    LD (HL+),A                              ; $4102  [22]
    LD A,$01                                ; $4103  [3E 01]
    LD ($DD60),A                            ; $4105  [EA 60 DD]
    LD HL,$DD63                             ; $4108  [21 63 DD]
    LD A,L                                  ; $410B  [7D]
    LD ($D7B4),A                            ; $410C  [EA B4 D7]
    LD A,H                                  ; $410F  [7C]
    LD ($D7B5),A                            ; $4110  [EA B5 D7]
    LD HL,$0205                             ; $4113  [21 05 02]
    RST $10                                 ; $4116  [D7]
    LD HL,$DD62                             ; $4117  [21 62 DD]
    LD A,L                                  ; $411A  [7D]
    LD ($D7B4),A                            ; $411B  [EA B4 D7]
    LD A,H                                  ; $411E  [7C]
    LD ($D7B5),A                            ; $411F  [EA B5 D7]
    RET                                     ; $4122  [C9]

