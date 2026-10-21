; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 5  (METASPRITE / OAM sprite composer + descriptor data)
; ============================================================================
;
; NOT just a stub: bank5 builds hardware sprites (OAM) from metasprite
; descriptor tables. Called from bank6 (overworld) via LD HL,$0500/$0501; RST $10.
;
; File offset $14000-$17FFF (16 KB), mapped at $4000-$7FFF when MBC bank = 5.
;
; Function table ($4001): fn0=$4005  fn1=$400F  fn2=$6ECD (-> descriptor DATA)
;
; fn1 ($400F) - the composer:
;   In (HRAM): $FFC7 object id, $FFC8 frame/pose id, $FFC3 base X, $FFC5 base Y,
;              $FFC9 tile base, $FFCA attr (XOR mask), $FFCB running OAM count.
;   Two-level lookup: ptrTable $407F[obj] -> subTable[frame] -> descriptor list.
;   Each descriptor entry = 4 bytes {Yoff, Xoff, tileOff, attr}; list ends at $80.
;   Writes an OAM entry to the $C000 shadow at $C000 + $FFCB*4:
;     Y = baseY+Yoff+$10,  X = baseX+Xoff+$08,  tile = tileBase+tileOff,
;     attr = $FFCA XOR attr.  Stops at 40 sprites ($28).
; Sub_406E ($406E): OR per-object attr bits (flag table $4152[obj]) into $FFCA.
;
; DATA (the bulk of the bank):
;   $407F  metasprite POINTER TABLE (~94 x 2-byte LE) -> per-object sub-tables
;   $4152  per-object attribute-flag table (1 byte/object)
;   $413F+, $6ECD+, ...  4-byte {Yoff,Xoff,tileOff,attr} descriptor lists ($80=end)
; ============================================================================

SECTION "Bank 5 Functions", ROMX[$4000], BANK[5]

; ------------------------------------------------------------
; Bank5_Fn0 ($4005) / Bank5_Fn1 ($400F) / Bank5_Sub_406E ($406E)
; ------------------------------------------------------------
Bank5_Code:                                 ; $4005
    CALL $406E                      ; $4005  [CD 6E 40]  ; fn0: set attr flags (Sub_406E) then load frame data via ROM0 $1164
    LD DE,$407F                     ; $4008  [11 7F 40]
    CALL $1164                      ; $400B  [CD 64 11]
    RET                             ; $400E  [C9]
    CALL $406E                      ; $400F  [CD 6E 40]  ; fn1: BUILD OAM SPRITES for object $FFC7 / frame $FFC8
    LD DE,$407F                     ; $4012  [11 7F 40]  ; DE = metasprite pointer-table base ($407F)
    PUSH AF                         ; $4015  [F5]
    PUSH BC                         ; $4016  [C5]
    PUSH DE                         ; $4017  [D5]
    PUSH HL                         ; $4018  [E5]
    LDH A,($CB)                     ; $4019  [F0 CB]  ; $FFCB = current OAM sprite count
    CP $28                          ; $401B  [FE 28]  ; stop at 40 sprites ($28)
    JR NC,$4069                     ; $401D  [30 4A]
    LDH A,($C7)                     ; $401F  [F0 C7]  ; A = object id $FFC7
    LD L,A                          ; $4021  [6F]
    LD H,$00                        ; $4022  [26 00]
    ADD HL,HL                       ; $4024  [29]  ; *2 (word index)
    ADD HL,DE                       ; $4025  [19]  ; + base -> ptr[obj]
    LD E,(HL)                       ; $4026  [5E]  ; DE = per-object descriptor sub-table
    INC HL                          ; $4027  [23]
    LD D,(HL)                       ; $4028  [56]
    LDH A,($C8)                     ; $4029  [F0 C8]  ; A = frame/pose id $FFC8
    LD L,A                          ; $402B  [6F]
    LD H,$00                        ; $402C  [26 00]
    ADD HL,HL                       ; $402E  [29]
    ADD HL,DE                       ; $402F  [19]  ; + sub-table -> ptr[frame]
    LD E,(HL)                       ; $4030  [5E]  ; DE = frame's Y,X,tile,attr descriptor list
    INC HL                          ; $4031  [23]
    LD D,(HL)                       ; $4032  [56]
    LDH A,($CB)                     ; $4033  [F0 CB]  ; sprite# ($FFCB) * 4
    SLA A                           ; $4035  [CB 27]
    SLA A                           ; $4037  [CB 27]
    LD L,A                          ; $4039  [6F]
    LD H,$C0                        ; $403A  [26 C0]  ; HL = $C000 + n*4  (OAM SHADOW entry)
    LD A,(DE)                       ; $403C  [1A]  ; read descriptor Y-offset
    INC DE                          ; $403D  [13]
    CP $80                          ; $403E  [FE 80]  ; $80 = end of descriptor
    JR Z,$4069                      ; $4040  [28 27]
    LD B,A                          ; $4042  [47]
    LDH A,($C5)                     ; $4043  [F0 C5]  ; OAM Y = baseY($FFC5)+Yoff+$10
    ADD A,B                         ; $4045  [80]
    ADD A,$10                       ; $4046  [C6 10]
    LD (HL+),A                      ; $4048  [22]  ; write OAM[+0] Y
    LD A,(DE)                       ; $4049  [1A]  ; read X-offset
    INC DE                          ; $404A  [13]
    LD B,A                          ; $404B  [47]
    LDH A,($C3)                     ; $404C  [F0 C3]  ; OAM X = baseX($FFC3)+Xoff+$08
    ADD A,B                         ; $404E  [80]
    ADD A,$08                       ; $404F  [C6 08]
    LD (HL+),A                      ; $4051  [22]  ; write OAM[+1] X
    LDH A,($C9)                     ; $4052  [F0 C9]  ; tile base $FFC9
    LD B,A                          ; $4054  [47]
    LD A,(DE)                       ; $4055  [1A]  ; read tile-offset
    INC DE                          ; $4056  [13]
    ADD A,B                         ; $4057  [80]
    LD (HL+),A                      ; $4058  [22]  ; write OAM[+2] tile=base+off
    LD A,(DE)                       ; $4059  [1A]  ; read attr
    INC DE                          ; $405A  [13]
    LD B,A                          ; $405B  [47]
    LDH A,($CA)                     ; $405C  [F0 CA]  ; attr = $FFCA XOR desc-attr
    XOR B                           ; $405E  [A8]
    LD (HL+),A                      ; $405F  [22]  ; write OAM[+3] attr
    LDH A,($CB)                     ; $4060  [F0 CB]  ; ++sprite count $FFCB
    INC A                           ; $4062  [3C]
    LDH ($CB),A                     ; $4063  [E0 CB]
    CP $28                          ; $4065  [FE 28]
    JR C,$403C                      ; $4067  [38 D3]  ; loop while < 40 sprites
    POP HL                          ; $4069  [E1]
    POP DE                          ; $406A  [D1]
    POP BC                          ; $406B  [C1]
    POP AF                          ; $406C  [F1]
    RET                             ; $406D  [C9]
    LDH A,($C7)                     ; $406E  [F0 C7]  ; Sub_406E: OR attr-flag table[$FFC7] into $FFCA
    LD HL,$4152                     ; $4070  [21 52 41]  ; HL = flag table $4152
    ADD A,L                         ; $4073  [85]
    LD L,A                          ; $4074  [6F]
    LD A,$00                        ; $4075  [3E 00]
    ADC A,H                         ; $4077  [8C]
    LD H,A                          ; $4078  [67]
    LDH A,($CA)                     ; $4079  [F0 CA]  ; $FFCA |= table[obj]
    OR (HL)                         ; $407B  [B6]
    LDH ($CA),A                     ; $407C  [E0 CA]
    RET                             ; $407E  [C9]

; ------------------------------------------------------------
; $407F  metasprite pointer table (~94 entries) + descriptor data + $4152 flags
;   (kept as raw ROM data; format documented in the header above)
; ------------------------------------------------------------
Bank5_MetaspritePtrs:                       ; $407F  DW per-object sub-table ptrs
Bank5_AttrFlagTable  EQU $4152              ; per-object attr-flag bytes
Bank5_Descriptors    EQU $413F              ; {Yoff,Xoff,tileOff,attr}.. ($80 = end)
