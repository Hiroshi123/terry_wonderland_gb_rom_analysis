; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 84 ($54)  — SPELL / SKILL bank  (data + code)
; ==========================================================================
;
; File offset $150000-$153FFF (16 KB), mapped at $4000-$7FFF when MBC=84.
;
; MIXED BANK: the front (~28%) is per-spell DATA (damage/heal amounts, MP
; cost, element, animation); the rest (~71%, from $5249) is the CODE that
; reads and applies spells (the fn0 accessor + fn1..fn8). Every skill/spell
; a monster can use has one record in the data section here.
;
; *** THIS is the bank that stores each SKILL/SPELL's ATTACK (damage/heal)
; value.*** A monster's NATIVE skills are just 3 spell ids in its species
; record (bank3 $4461+id*$2B, bytes +$06..$08); those ids index HERE (record
; = $41CF + spellid*$13) to get the actual damage/heal/MP. So: bank3 = which
; skills a monster has; bank84 = what each skill does.
;
; Layout of the bank:
;   $4001-$4012  function table (fn0..fn8, 2 bytes each)        [code ptrs]
;   $4013-$41CE  SPELL POINTER TABLE — 2-byte LE ptr per spell  [DATA, 444 B]
;                id, pointing at that spell's record.
;   $41CF-$5248  SPELL RECORDS — 222 records × $13 (19) bytes    [DATA, 4218 B]
;                contiguous (record[id] = $41CF + id*$13; the pointer table
;                just lists these addresses in order).
;   $5249-$7FFF  CODE — fn0 (the record accessor) + fn1..fn8    [CODE, ~11.4 KB]
;
; ACCESSOR — bank84 fn0 ($5249), called via  LD HL,$5400 ; RST $10 :
;   input : $DB4C/$DB4D = spell id (16-bit),  $DB4E = field BYTE offset
;   does  : HL = pointerTable[id]  (= record address)
;           HL += $DB4E ;  return the 16-bit LE value there in $DB4C/$DB4D
;   Callers that want a 1-byte field (e.g. MP cost) use only the low byte.
;   e.g. bank80 $5BAD sets $DB4E=$04 → returns MP cost (byte 4) for the
;   MP-affordability check.
;
; RECORD FORMAT  (19 bytes; add id*$13 to $41CF):
;   +$00  byte  spell FAMILY / group id (0,0,0,1,1,1,2,2,2,… — tiers of a
;               family are consecutive, e.g. tier1/tier2/tier3)
;   +$01  byte  $13 (constant — record length marker)
;   +$02  byte  type ($11/$12/… )
;   +$03  byte  animation / target-shape id
;   +$04  byte  MP COST                      [confirmed: field $04, low byte]
;   +$05  byte  element / category (tracks the family id)
;   +$06..$0A   animation / sound params (mostly constant: 04 41 07 17 02)
;   +$0B  word  PRIMARY power (16-bit LE) — the headline DAMAGE/HEAL, read by
;               fn3/fn4 when $DB88 bit2 is clear. Scales strongly with tier.
;   +$0D  word  primary variance / min component (small, paired with +$0B)
;   +$0F  word  SECONDARY power — read by fn3/fn4 when $DB88 bit2 is set.
;               Consistently LOWER than +$0B (e.g. 180 vs 100, 70 vs 30),
;               i.e. the reduced "hits-all-enemies" figure vs the single-
;               target +$0B. [single-vs-group split inferred from the values]
;   +$11  word  secondary variance / min component (small, paired with +$0F)
;   (Attack spells → damage; heal spells → HP restored. High bytes +$0C/+$10
;    are usually 0 since powers are <256; +$0E and +$12 are 0 in EVERY record.)
;
; Examples (id : +$04 MP, then the four power words +$0B/+$0D/+$0F/+$11):
;   id 0  $41CF : MP  2 | 12   3   7   5      (family 0, tier 1)
;   id 1  $41E2 : MP  4 | 70  20  30  12      (family 0, tier 2)
;   id 2  $41F5 : MP 10 | 180 20 100  20      (family 0, tier 3 — big damage)
;   id 5  $422E : MP 10 | 88  24  60  20      (family 1, tier 3)
;   id 8  $4267 : MP 15 | 130 20  95  20      (family 2, tier 3)
;   The +$0B value clearly grows with the spell tier → it is the spell's
;   headline damage/heal power.
;
; So: the DAMAGE/HEAL record of each spell lives in THIS bank (bank84 $54),
; in the 19-byte record at $41CF + id*$13, fields +$0B..+$12.
; ==========================================================================

; ----------------------------------------------------------------------------
; First 10 spell records decoded ($41CF, 19 bytes each).
; Layout: fam / t1 t2 / anim / MP / elem / anim-params(5) /
;   PRIMARY power(+$0B) + var(+$0D) / SECONDARY power(+$0F) + var(+$11)
; (families of 3 = spell tiers: recs 0-2 family0, 3-5 family1, 6-8 family2)
; ----------------------------------------------------------------------------
SpellDB:                                    ; $41CF  (record = $41CF + id*$13)
.spell00:                                  ; $41CF  spell id 0 (family 0)
    DB $00,$13,$11                         ; +$00 family=0, +$01 type1=$13, +$02 type2=$11
    DB $14                                 ; +$03 anim/target-shape
    DB $02                                 ; +$04 MP cost = 2
    DB $01                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $000C,$0003                         ; +$0B PRIMARY power=12, +$0D var=3
    DW $0007,$0005                         ; +$0F SECONDARY power=7, +$11 var=5

.spell01:                                  ; $41E2  spell id 1 (family 0)
    DB $00,$13,$11                         ; +$00 family=0, +$01 type1=$13, +$02 type2=$11
    DB $14                                 ; +$03 anim/target-shape
    DB $04                                 ; +$04 MP cost = 4
    DB $01                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0046,$0014                         ; +$0B PRIMARY power=70, +$0D var=20
    DW $001E,$000C                         ; +$0F SECONDARY power=30, +$11 var=12

.spell02:                                  ; $41F5  spell id 2 (family 0)
    DB $00,$13,$11                         ; +$00 family=0, +$01 type1=$13, +$02 type2=$11
    DB $14                                 ; +$03 anim/target-shape
    DB $0A                                 ; +$04 MP cost = 10
    DB $01                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $00B4,$0014                         ; +$0B PRIMARY power=180, +$0D var=20
    DW $0064,$0014                         ; +$0F SECONDARY power=100, +$11 var=20

.spell03:                                  ; $4208  spell id 3 (family 1)
    DB $01,$13,$12                         ; +$00 family=1, +$01 type1=$13, +$02 type2=$12
    DB $0A                                 ; +$03 anim/target-shape
    DB $04                                 ; +$04 MP cost = 4
    DB $02                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0010,$0008                         ; +$0B PRIMARY power=16, +$0D var=8
    DW $000A,$0008                         ; +$0F SECONDARY power=10, +$11 var=8

.spell04:                                  ; $421B  spell id 4 (family 1)
    DB $01,$13,$12                         ; +$00 family=1, +$01 type1=$13, +$02 type2=$12
    DB $0C                                 ; +$03 anim/target-shape
    DB $06                                 ; +$04 MP cost = 6
    DB $02                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $001E,$000C                         ; +$0B PRIMARY power=30, +$0D var=12
    DW $0016,$000C                         ; +$0F SECONDARY power=22, +$11 var=12

.spell05:                                  ; $422E  spell id 5 (family 1)
    DB $01,$13,$12                         ; +$00 family=1, +$01 type1=$13, +$02 type2=$12
    DB $0E                                 ; +$03 anim/target-shape
    DB $0A                                 ; +$04 MP cost = 10
    DB $02                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0058,$0018                         ; +$0B PRIMARY power=88, +$0D var=24
    DW $003C,$0014                         ; +$0F SECONDARY power=60, +$11 var=20

.spell06:                                  ; $4241  spell id 6 (family 2)
    DB $02,$13,$12                         ; +$00 family=2, +$01 type1=$13, +$02 type2=$12
    DB $0B                                 ; +$03 anim/target-shape
    DB $05                                 ; +$04 MP cost = 5
    DB $03                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0014,$000A                         ; +$0B PRIMARY power=20, +$0D var=10
    DW $000F,$0005                         ; +$0F SECONDARY power=15, +$11 var=5

.spell07:                                  ; $4254  spell id 7 (family 2)
    DB $02,$13,$12                         ; +$00 family=2, +$01 type1=$13, +$02 type2=$12
    DB $0D                                 ; +$03 anim/target-shape
    DB $08                                 ; +$04 MP cost = 8
    DB $03                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0034,$0010                         ; +$0B PRIMARY power=52, +$0D var=16
    DW $0023,$000A                         ; +$0F SECONDARY power=35, +$11 var=10

.spell08:                                  ; $4267  spell id 8 (family 2)
    DB $02,$13,$12                         ; +$00 family=2, +$01 type1=$13, +$02 type2=$12
    DB $10                                 ; +$03 anim/target-shape
    DB $0F                                 ; +$04 MP cost = 15
    DB $03                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0082,$0014                         ; +$0B PRIMARY power=130, +$0D var=20
    DW $005F,$0014                         ; +$0F SECONDARY power=95, +$11 var=20

.spell09:                                  ; $427A  spell id 9 (family 3)
    DB $03,$13,$12                         ; +$00 family=3, +$01 type1=$13, +$02 type2=$12
    DB $0A                                 ; +$03 anim/target-shape
    DB $02                                 ; +$04 MP cost = 2
    DB $04                                 ; +$05 element/category
    DB $04,$41,$07,$17,$02                     ; +$06 anim/sound params
    DW $0008,$0010                         ; +$0B PRIMARY power=8, +$0D var=16
    DW $0006,$000C                         ; +$0F SECONDARY power=6, +$11 var=12


SECTION "Bank84_ID", ROMX[$4000], BANK[84]
    DB $54

SECTION "Bank84_FnTable", ROMX[$4001], BANK[84]
    DW $5249    ; fn0 — spell-record accessor (id + field → 16-bit value)
    DW $526E    ; fn1
    DW $5298    ; fn2
    DW $52C7    ; fn3
    DW $5313    ; fn4
    DW $535F    ; fn5
    DW $53AC    ; fn6
    DW $55BB    ; fn7
    DW $5405    ; fn8

; NOTE: $4013-$41CE is the 222-entry spell pointer table; $41CF-$5248 the
; 222 spell records (19 bytes each). Not re-listed byte-by-byte here — see
; the RECORD FORMAT above; record[id] = $41CF + id*$13.


; ==========================================================================
; CODE — spell accessor & handler functions (fn0..fn8)
; ==========================================================================
; Roles:
;   fn0/fn1  read a field out of a spell record (the low-level accessors)
;   fn2      load a spell's metadata (type/element/animation)
;   fn3/fn4  compute a spell's DAMAGE/HEAL amount from its power field
;   fn5      spell-id remap / property lookup
;   fn6      pick a skill from the acting monster's skill list
;   fn7      process the queued battle message/action
;   fn8      drive the spell sub-screen (6-state machine)
; --------------------------------------------------------------------------

SECTION "Bank84_Code", ROMX[$5249], BANK[84]

; --------------------------------------------------------------------------
; fn0 — SpellField_GetWord:  return the 16-bit field at record[id] + offset.
;   in : $DB4C/$DB4D = spell id,  $DB4E = byte offset into the 19-byte record
;   out: $DB4C/$DB4D = the 16-bit LE value there
;   (callers that want a byte field, e.g. MP cost, use only the low byte.)
; --------------------------------------------------------------------------
Bank84_fn0:                              ; $5249
    LD A,($DB4C)                         ; C = id low
    LD C,A
    LD A,($DB4D)                         ; B = id high
    LD B,A
    LD HL,$4013                          ; spell pointer table base
    ADD HL,BC
    ADD HL,BC                            ; HL = &ptrTable[id]  (id*2)
    LDI A,(HL)                           ; \ HL = ptrTable[id] = record address
    LD H,(HL)                            ; /
    LD L,A
    LD A,($DB4E)                         ; add field byte-offset
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A                               ; HL = &record[offset]
    LDI A,(HL)                           ; \ BC = 16-bit field value
    LD B,(HL)                            ; /
    LD C,A
    LD A,C
    LD ($DB4C),A                         ; \ return in $DB4C/$DB4D
    LD A,B
    LD ($DB4D),A                         ; /
    RET

; --------------------------------------------------------------------------
; fn1 — SpellField_GetWordPlusByte:  like fn0, but ALSO returns the byte
;   immediately after the 16-bit field in $DB4E. Used where a field is a
;   value + a trailing modifier/variance byte (see fn3/fn4).
; --------------------------------------------------------------------------
Bank84_fn1:                              ; $526E
    LD A,($DB4C)
    LD C,A
    LD A,($DB4D)
    LD B,A
    LD HL,$4013
    ADD HL,BC
    ADD HL,BC
    LDI A,(HL)
    LD H,(HL)
    LD L,A
    LD A,($DB4E)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LDI A,(HL)                           ; BC = 16-bit field
    LD B,(HL)
    LD C,A
    INC HL
    LD A,(HL)                            ; A = next byte (trailing modifier)
    LD ($DB4E),A                         ; → $DB4E
    LD A,C
    LD ($DB4C),A
    LD A,B
    LD ($DB4D),A
    RET

; --------------------------------------------------------------------------
; fn2 — SpellMeta_Load:  copy the current spell's metadata into scratch.
;   spell id = $DB8A. Copies record byte +$02 (type) → $DCFC, and the three
;   bytes at +$05..+$07 (element/animation params) → $DCFD/$DCFE/$DCFF.
; --------------------------------------------------------------------------
Bank84_fn2:                              ; $5298
    LD A,($DB8A)                         ; current spell id
    LD C,A
    LD B,$00
    LD HL,$4013
    ADD HL,BC
    ADD HL,BC
    LDI A,(HL)                           ; HL = record address
    LD H,(HL)
    LD L,A
    LD A,$02                             ; + $02 (type byte)
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DCFC),A                         ; type → $DCFC
    LD A,$05                             ; step to record + $05
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LDI A,(HL)
    LD ($DCFD),A                         ; +$05 → $DCFD
    LDI A,(HL)
    LD ($DCFE),A                         ; +$06 → $DCFE
    LD A,(HL)
    LD ($DCFF),A                         ; +$07 → $DCFF
    RET

; --------------------------------------------------------------------------
; fn3 — SpellPower_Compute:  compute this spell's DAMAGE / HEAL amount.
;   spell id = $DB8A. Field offset is $0F if bit2 of $DB88 is set, else $0B
;   (the two power words in the record). fn1 reads that 16-bit power and its
;   trailing byte ($DB4E). Then, unless this monster's $DD0B flag == 2, the
;   trailing byte is ADDED to the power. Result → $DB56/$DB57 — the value
;   the HP apply-code (bank80 $4E82) subtracts from / adds to the target.
;   ⇒ record +$0B (or +$0F) = the spell's damage/heal power.
; --------------------------------------------------------------------------
Bank84_fn3:                              ; $52C7
    LD A,($DB8A)                         ; spell id → $DB4C/$DB4D
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,($DB88)
    BIT 2,A                              ; context bit selects power field
    JR Z,$52E0
    LD A,$0F                             ; power field +$0F
    LD ($DB4E),A
    JR $52E5
    LD A,$0B                             ; power field +$0B  ($52E0)
    LD ($DB4E),A
    CALL Bank84_fn1                      ; BC = power word, $DB4E = trailing byte
    LD A,($DB4C)
    LD C,A
    LD A,($DB4D)
    LD B,A
    LD A,($DB88)
    LD HL,$DD0B                          ; per-monster flag array
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02                               ; flag == 2 → skip the +variance
    JR Z,$530A
    LD A,($DB4E)                         ; add trailing modifier byte
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,C                               ; $530A: store result
    LD ($DB56),A                         ; \ damage/heal → $DB56/$DB57
    LD A,B
    LD ($DB57),A                         ; /
    RET

; --------------------------------------------------------------------------
; fn4 — SpellPower_Compute (variant):  same computation as fn3 (power field
;   +$0F/+$0B via fn1, conditional +modifier, → $DB56/$DB57). Second copy
;   used from a different point of the resolution flow.
; --------------------------------------------------------------------------
Bank84_fn4:                              ; $5313
    LD A,($DB8A)
    LD ($DB4C),A
    LD A,$00
    LD ($DB4D),A
    LD A,($DB88)
    BIT 2,A
    JR Z,$532C
    LD A,$0F
    LD ($DB4E),A
    JR $5331
    LD A,$0B                             ; $532C
    LD ($DB4E),A
    CALL Bank84_fn1                      ; $5331
    LD A,($DB4C)
    LD C,A
    LD A,($DB4D)
    LD B,A
    LD A,($DB88)
    LD HL,$DD0B
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    CP $02
    JR Z,$5356
    LD A,($DB4E)
    ADD A,C
    LD C,A
    LD A,$00
    ADC A,B
    LD B,A
    LD A,C                               ; $5356
    LD ($DB56),A
    LD A,B
    LD ($DB57),A
    RET

; --------------------------------------------------------------------------
; fn5 — SpellId_Remap:  id-based property lookup with special cases.
;   in : $DB4C = id.  ids >= $D5 are special (id $D5 → return $12; id > $D5
;   → return 0). Otherwise reads field +$0A of record[id] (via fn0); if that
;   field's low byte != 1, also reads field +$02 and returns its low byte in
;   $DB4D. Looks like "resolve a spell id to its real/target id".
; --------------------------------------------------------------------------
Bank84_fn5:                              ; $535F
    LD A,($DB4C)
    CP $D5
    JR Z,$539D                           ; id == $D5 → special
    JR NC,$53A6                           ; id >  $D5 → return 0
    LD A,$00
    LD ($DB4D),A
    LD A,$0A                             ; read field +$0A
    LD ($DB4E),A
    LD A,($DB4C)
    LD L,A
    LD A,($DB4D)
    LD H,A
    PUSH HL
    CALL Bank84_fn0
    POP HL
    LD A,($DB4C)
    CP $01                               ; field low byte == 1?
    JR Z,$53A6                           ; yes → return 0
    LD A,L
    LD ($DB4C),A
    LD A,H
    LD ($DB4D),A
    PUSH HL
    LD A,$02                             ; read field +$02
    LD ($DB4E),A
    CALL Bank84_fn0
    POP HL
    LD A,L
    LD ($DB4D),A
    RET
    LD ($DB4D),A                         ; $539D: id == $D5 special
    LD A,$12
    LD ($DB4C),A
    RET
    LD A,$00                             ; $53A6: return 0
    LD ($DB4C),A
    RET

; --------------------------------------------------------------------------
; fn6 — Skill_Select:  choose a skill from the acting monster's skill list.
;   Uses the skill-menu cursor ($C8DC hi, $C8DB lo) to index the 4-wide
;   skill list at $CA51, publishes the picked slot's species id to $DA5E and
;   the slot index to $DA5F, then calls bank3 fn2 ($0302) + bank3 fn8 ($0308)
;   to load that skill/monster's data. Sets $DB53 on the "can't (full/known)"
;   case ($DA5E == $FF or $DA65 == $64).
; --------------------------------------------------------------------------
Bank84_fn6:                              ; $53AC
    XOR A
    LD ($DB53),A
    LD A,($C8DC)                         ; skill-list cursor (row)
    ADD A,A
    ADD A,A                              ; row * 4
    LD B,A
    LD A,($C8DB)                         ; skill window sub-state (col), low 7 bits
    AND $7F
    ADD A,B
    LD ($DB4C),A                         ; = list index
    LD HL,$CA51                          ; skill/offer list base
    ADD A,L
    LD L,A
    LD A,$00
    ADC A,H
    LD H,A
    LD A,(HL)
    LD ($DA5E),A                         ; picked species/skill id → $DA5E
    LD HL,$0302
    RST $10                              ; bankcall → bank3 fn2
    LD A,($DB4C)
    LD ($DA5F),A                         ; slot index → $DA5F
    LD HL,$0308
    RST $10                              ; bankcall → bank3 fn8
    LD A,($DA5E)
    CP $FF
    JR NZ,$53F5
    LD A,($DA65)
    CP $64
    JR Z,$53F5
    LD A,$01
    LD ($DB53),A                         ; flag "not selectable"
    CALL $53F6
; (fn6 continues past $53F1 into helper $53F6; body omitted here)

; fn7 ($55BB) — Message_Process: services the queued battle message/action in
;   $DD61 (indexes $DB85 / $DC3C tables, calls $560E/$5655 + $5683), and
;   INCs the scene state $D9EC when the queue drains. [summary; not the
;   spell-data path]
;
; fn8 ($5405) — Spell sub-screen state machine (6 states on $D9EE, RST $00
;   table at $5409 → $5415/$5430/$5456/$54A7/$5508/$5577). Drives the
;   cast/animation screen: waits on the text box ($C825) and a $DA33 delay,
;   bankcalls bank76 fn0 ($4C00), advancing $D9EE each step. [UI, not data]
; ==========================================================================
