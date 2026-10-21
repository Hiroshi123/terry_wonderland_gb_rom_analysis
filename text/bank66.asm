; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 66  (DIALOGUE / MESSAGE TEXT data — NOT sound)
; ==========================================================================
;
; CORRECTION: this bank was previously mislabeled "Sound driver bank 66".
; It is a DIALOGUE TEXT data bank. Proof:
;   - 78% of the bank is kana-range bytes that decode to fluent Japanese.
;   - The ROM0 routines it calls ($0568/$05A7/$05BA) are the MESSAGE/TEXT
;     engine (window setup + copy text bytes to buffer + page-print loop that
;     writes GLYPH tiles to VRAM via $1E80). They do NOT touch $FF10-$FF3F.
;   - The "$F0-terminated stream" seen earlier is the text NEWLINE code $F0.
; Text encoding = identity-mapped kana (see memory: text-codec). Voiced kana
; = base+$8D (゛), semi-voiced = base+$8E (゜), long vowel ー = $9C.
; Banks 64-75 and 77-78 are all dialogue text like this one.
;
; Bank 66 memory map:
;   File offset $108000-$10BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 66
;
; ── Text-engine call convention ──────────────────────────────
;   fn0/fn1/fn2 hand DE = $401C (this bank's message directory) to the shared
;   ROM0 message engine; the message index is selected via WRAM ($C824 = text
;   bank, plus the id set by the caller) and the engine banks itself back here.
;     $0568  message setup   — build window/VRAM copy ptrs ($C827->$C82B/$C82D),
;                              via VRAM helpers $08B9/$0D24
;     $05A7  copy text        — LD A,(DE)/LD (HL+),A into buffer $C837/$C838
;     $05BA  print loop       — set $C825 bit1, tick $05C9/$05E0: bank to text
;                              bank ($2100/$4100) and emit glyphs via $1E80
;
; ── Message directory + string data ──────────────────────────
;   $401C : word = $401E  (pointer to the string-pointer TABLE)
;   $401E : table of 226 little-endian string pointers ($41E2,$427C,$4291,...)
;   $41E2 : start of the kana-encoded message strings (up to ~$7DBA)
;   Each string begins with a SPEAKER-NAME label (e.g. おう=King, フ゜リォ).
;
;   Verified samples (decode via text-codec):
;     str#1 @$41E2  「ミレーヨ！ テリー！ まちなさいって！
;                     もう ねるじかんよ！…」   (game's opening — mother calls Terry)
;     @$4C7F+       NPC プリォ (monster-ranch keeper) opening scene
;     @$57C0+       King summons プリォ / ホイミン-escaped scene (see npc-prio)
;
; Function table at $108001 (bank 66 $4001):
;   fn0: $4007   set up message window (DE=$401C directory)
;   fn1: $400E   copy the message text into the window buffer
;   fn2: $4015   fn0 + run the page-print loop
; ==========================================================================

SECTION "Bank 66", ROMX[$4000], BANK[66]

    db $42                                   ; $4000  self-ID
    dw $4007,$400E,$4015                     ; $4001  fn table (fn0/fn1/fn2)

; ────────────────────────────────────────────────────────────
; Bank66_Fn0  ($4007) — set up the message window for this text bank
; ────────────────────────────────────────────────────────────
Bank66_Fn0:
    LD DE,$401C                             ; $4007  [11 1C 40]  ; DE = message directory ($401C -> table $401E)
    CALL $0568                              ; $400A  [CD 68 05]  ; ROM0 message-setup (window/VRAM ptrs)
    RET                                     ; $400D  [C9]

; ────────────────────────────────────────────────────────────
; Bank66_Fn1  ($400E) — copy the selected message text into the buffer
; ────────────────────────────────────────────────────────────
Bank66_Fn1:
    LD DE,$401C                             ; $400E  [11 1C 40]  ; DE = message directory
    CALL $05A7                              ; $4011  [CD A7 05]  ; ROM0 copy-text -> buffer $C837/$C838
    RET                                     ; $4014  [C9]

; ────────────────────────────────────────────────────────────
; Bank66_Fn2  ($4015) — set up + run the page-print loop
; ────────────────────────────────────────────────────────────
Bank66_Fn2:
    CALL $4007                              ; $4015  [CD 07 40]  ; Fn0: window setup
    CALL $05BA                              ; $4018  [CD BA 05]  ; ROM0 print loop (emits glyphs via $1E80)
    RET                                     ; $401B  [C9]

; ────────────────────────────────────────────────────────────
; Message directory + string data
; ────────────────────────────────────────────────────────────
Bank66_MsgDir:                             ; $401C
    dw Bank66_MsgTable                     ; $401C  [1E 40]      ; -> $401E (string-pointer table)
Bank66_MsgTable:                           ; $401E
    ; 226 little-endian pointers to the kana message strings (byte-exact):
    dw $41E2,$427C,$4291,$42D8,$4319,$4368,$43BA,$43F1
    dw $4428,$44C6,$44EC,$4612,$464D,$4677,$46AB,$46F2
    dw $479A,$47E7,$4810,$4838,$4858,$4875,$48CB,$48F1
    dw $4917,$4930,$494C,$495C,$4970,$4982,$49C7,$49DB
    dw $49F2,$4A33,$4CA0,$4CC9,$4CF0,$4D26,$4E10,$4E27
    dw $4E5E,$4F2D,$4F56,$4FA7,$4FF3,$513F,$5167,$5272
    dw $52DC,$5308,$5354,$53D2,$53EC,$5425,$5446,$549B
    dw $5516,$5538,$55A6,$55BE,$55EF,$5611,$568E,$56BA
    dw $5796,$57D5,$5929,$5943,$595C,$5979,$5A2D,$5A52
    dw $5A7A,$5AA6,$5AF1,$5B89,$5BB3,$5C8D,$5CEF,$5D16
    dw $5DB6,$5E1A,$5E41,$5E60,$5F58,$5FD2,$6039,$6064
    dw $60C9,$612C,$6148,$621A,$6245,$62FD,$6343,$6397
    dw $63BE,$6402,$641E,$645C,$647D,$64E4,$65D6,$65F9
    dw $66A3,$675C,$6779,$6792,$67C4,$6822,$688E,$68A8
    dw $6942,$69BF,$69DC,$6AB6,$6AFB,$6B4B,$6B9A,$6BBF
    dw $6BE3,$6C09,$6C27,$6C59,$6C81,$6CAA,$6CD8,$6D13
    dw $6D68,$6DAE,$6DC9,$6DEE,$6E18,$6E2E,$6E53,$6E72
    dw $6EAE,$6ED6,$6EF8,$6F1C,$6F44,$6F67,$6F8C,$6FC2
    dw $6FE5,$702C,$704A,$7067,$7089,$70AD,$70CB,$70E4
    dw $7118,$713E,$716A,$7195,$71BC,$7207,$7225,$7240
    dw $726C,$72C4,$72EF,$731A,$7336,$7380,$73AA,$73D4
    dw $73FF,$74A3,$74C1,$74DC,$74F6,$750C,$7535,$757B
    dw $75B8,$75DE,$75FA,$762B,$7660,$768A,$76C4,$76E1
    dw $7719,$7764,$7781,$77A6,$77B8,$77E0,$7802,$782A
    dw $7854,$787C,$78A7,$78D0,$7906,$792E,$7956,$797C
    dw $799E,$79DE,$7A07,$7A45,$7A6F,$7A98,$7AC0,$7B04
    dw $7B17,$7B3A,$7B62,$7B82,$7B9F,$7BC4,$7C0E,$7C31
    dw $7C48,$7C6F,$7C9A,$7CB6,$7CFF,$7D3E,$7D55,$7D7D
    dw $7D99,$7DBA
    ; ------------------------------------------------------------------------
    ; ALL 226 messages are decoded below, in strict ASCENDING ADDRESS order
    ; ($41E2 -> $7DBA). Every `db` line is byte-exact (verified to reassemble
    ; to ROM). Each block header shows the normalized kana reading; the db
    ; comments show raw kana with the voiced form after '=' (e.g. か゛ = が).
    ; Codec + control codes: memory text-codec. Speaker labels are tagged
    ; inline where a name precedes an $96 name-tag (ミレーヨ=sister, おう=King,
    ; プリォ=ranch keeper, スラお=tutorial slime). EN glosses are given for the
    ; opening-arc story beats; the rest carry the kana reading only.
    ; ------------------------------------------------------------------------


; ══════════════════════════════════════════════════════════════════════════
; DECODED MESSAGES (all 226) — ADDRESS-ORDERED
; ══════════════════════════════════════════════════════════════════════════

; --------------------------------------------------------------------------
; Message #0 ($41E2)
;   ミレーヨ「テリー！　まちなさいって！
;   もう　ねるじかんよ！
;   ミレーヨ「かあさんと　とうさんが
;   いってたこと　わすれたの？
;   ミレーヨ「よふかしすると　まものが
;   さらいにくるのよ！！
;   ミレーヨ「え？　まものに　あいたい？
;   ばかなこといわないで　ねなさい！
;   EN: The opening — Terry's sister Mirayo nags him to sleep or monsters will take him.
; --------------------------------------------------------------------------
Bank66_Msg0:                               ; $41E2  (file $1081E2)
    db $EB                         ; $41E2  ▶ new page
    db $7B,$88,$9C,$81             ; $41E3  ミレーヨ  (speaker: ミレーヨ)
    db $96                         ; $41E7  end name/box tag
    db $6E,$86,$9C                 ; $41E8  テリー
    db $99                         ; $41EB  ！
    db $90                         ; $41EC  　(space)
    db $43,$34,$39,$2E,$25,$36,$37 ; $41ED  まちなさいって
    db $99                         ; $41F4  ！
    db $EF,$EE                     ; $41F5  newline
    db $90,$90                     ; $41F7  　　(indent)
    db $47,$26                     ; $41F9  もう
    db $90                         ; $41FB  　(space)
    db $3C,$50,$2F,$8D,$29,$55,$4C ; $41FC  ねるし゛かんよ = ねるじかんよ
    db $99                         ; $4203  ！
    db $FA                         ; $4204  wait-for-button
    db $F7                         ; $4205  clear page
    db $EF,$EE                     ; $4206  newline
    db $7B,$88,$9C,$81             ; $4208  ミレーヨ  (speaker: ミレーヨ)
    db $96                         ; $420C  end name/box tag
    db $29,$24,$2E,$55,$38         ; $420D  かあさんと
    db $90                         ; $4212  　(space)
    db $38,$26,$2E,$55,$29,$8D     ; $4213  とうさんか゛ = とうさんが
    db $EF,$EE                     ; $4219  newline
    db $90,$90                     ; $421B  　　(indent)
    db $25,$36,$37,$33,$2D,$38     ; $421D  いってたこと
    db $90                         ; $4223  　(space)
    db $53,$30,$51,$33,$3D         ; $4224  わすれたの
    db $98                         ; $4229  ？
    db $FA                         ; $422A  wait-for-button
    db $F7                         ; $422B  clear page
    db $EF,$EE                     ; $422C  newline
    db $7B,$88,$9C,$81             ; $422E  ミレーヨ  (speaker: ミレーヨ)
    db $96                         ; $4232  end name/box tag
    db $4C,$40,$29,$2F,$30,$50,$38 ; $4233  よふかしすると
    db $90                         ; $423A  　(space)
    db $43,$47,$3D,$29,$8D         ; $423B  まものか゛ = まものが
    db $EF,$EE                     ; $4240  newline
    db $90,$90                     ; $4242  　　(indent)
    db $2E,$4E,$25,$3A,$2B,$50,$3D,$4C; $4244  さらいにくるのよ
    db $99                         ; $424C  ！
    db $99                         ; $424D  ！
    db $FA                         ; $424E  wait-for-button
    db $F7                         ; $424F  clear page
    db $EF,$EE                     ; $4250  newline
    db $7B,$88,$9C,$81             ; $4252  ミレーヨ  (speaker: ミレーヨ)
    db $96                         ; $4256  end name/box tag
    db $27                         ; $4257  え
    db $98                         ; $4258  ？
    db $90                         ; $4259  　(space)
    db $43,$47,$3D,$3A             ; $425A  まものに
    db $90                         ; $425E  　(space)
    db $24,$25,$33,$25             ; $425F  あいたい
    db $98                         ; $4263  ？
    db $EF,$EE                     ; $4264  newline
    db $90,$90                     ; $4266  　　(indent)
    db $3E,$8D,$29,$39,$2D,$38,$25,$53,$39,$25,$37,$8D; $4268  は゛かなこといわないて゛ = ばかなこといわないで
    db $90                         ; $4274  　(space)
    db $3C,$39,$2E,$25             ; $4275  ねなさい
    db $99                         ; $4279  ！
    db $F7                         ; $427A  clear page
    db $F0                         ; $427B  end of message


; --------------------------------------------------------------------------
; Message #1 ($427C)
;   ミレーヨ「　、　、　、　・・・。
; --------------------------------------------------------------------------
Bank66_Msg1:                               ; $427C  (file $10827C)
    db $EB                         ; $427C  ▶ new page
    db $7B,$88,$9C,$81             ; $427D  ミレーヨ  (speaker: ミレーヨ)
    db $96                         ; $4281  end name/box tag
    db $90                         ; $4282  　(space)
    db $A4                         ; $4283  、
    db $90                         ; $4284  　(space)
    db $A4                         ; $4285  、
    db $90                         ; $4286  　(space)
    db $A4                         ; $4287  、
    db $90                         ; $4288  　(space)
    db $23                         ; $4289  ・
    db $23                         ; $428A  ・
    db $23                         ; $428B  ・
    db $8F                         ; $428C  。
    db $EF,$EE                     ; $428D  newline
    db $F7                         ; $428F  clear page
    db $F0                         ; $4290  end of message


; --------------------------------------------------------------------------
; Message #2 ($4291)
;   テリーは　ぬいぐるみを　しらべた。
;   ちいさく　かわいい　もじで
;   なにか　かかれている。
;   「ミレーヨの　もの
;   EN: Narration: Terry examines the stuffed toy ("Property of Mirayo").
; --------------------------------------------------------------------------
Bank66_Msg2:                               ; $4291  (file $108291)
    db $6E,$86,$9C,$3E             ; $4291  テリーは
    db $90                         ; $4295  　(space)
    db $3B,$25,$2B,$8D,$50,$44,$54 ; $4296  ぬいく゛るみを = ぬいぐるみを
    db $90                         ; $429D  　(space)
    db $2F,$4E,$41,$8D,$33         ; $429E  しらへ゛た = しらべた
    db $8F                         ; $42A3  。
    db $EF,$EE                     ; $42A4  newline
    db $FA                         ; $42A6  wait-for-button
    db $F7                         ; $42A7  clear page
    db $EF,$EE                     ; $42A8  newline
    db $F3                         ; $42AA  open text box
    db $34,$25,$2E,$2B             ; $42AB  ちいさく
    db $90                         ; $42AF  　(space)
    db $29,$53,$25,$25             ; $42B0  かわいい
    db $90                         ; $42B4  　(space)
    db $47,$2F,$8D,$37,$8D         ; $42B5  もし゛て゛ = もじで
    db $EF,$EE                     ; $42BA  newline
    db $39,$3A,$29                 ; $42BC  なにか
    db $90                         ; $42BF  　(space)
    db $29,$29,$51,$37,$25,$50     ; $42C0  かかれている
    db $8F                         ; $42C6  。
    db $FA                         ; $42C7  wait-for-button
    db $F7                         ; $42C8  clear page
    db $EF,$EE                     ; $42C9  newline
    db $96                         ; $42CB  end name/box tag
    db $7B,$88,$9C,$81,$3D         ; $42CC  ミレーヨの
    db $90                         ; $42D1  　(space)
    db $47,$3D                     ; $42D2  もの
    db $EF,$EE                     ; $42D4  newline
    db $F7                         ; $42D6  clear page
    db $F0                         ; $42D7  end of message


; --------------------------------------------------------------------------
; Message #3 ($42D8)
;   テリーは　めのまえを　しらべた。
;   ほのおから　うまれた　ひのこが
;   パチパチと　はじけては　きえていく。
; --------------------------------------------------------------------------
Bank66_Msg3:                               ; $42D8  (file $1082D8)
    db $6E,$86,$9C,$3E             ; $42D8  テリーは
    db $90                         ; $42DC  　(space)
    db $46,$3D,$43,$27,$54         ; $42DD  めのまえを
    db $90                         ; $42E2  　(space)
    db $2F,$4E,$41,$8D,$33         ; $42E3  しらへ゛た = しらべた
    db $8F                         ; $42E8  。
    db $EF,$EE                     ; $42E9  newline
    db $FA                         ; $42EB  wait-for-button
    db $F7                         ; $42EC  clear page
    db $EF,$EE                     ; $42ED  newline
    db $F3                         ; $42EF  open text box
    db $42,$3D,$28,$29,$4E         ; $42F0  ほのおから
    db $90                         ; $42F5  　(space)
    db $26,$43,$51,$33             ; $42F6  うまれた
    db $90                         ; $42FA  　(space)
    db $3F,$3D,$2D,$29,$8D         ; $42FB  ひのこか゛ = ひのこが
    db $EF,$EE                     ; $4300  newline
    db $75,$8E,$6B,$75,$8E,$6B,$38 ; $4302  ハ゜チハ゜チと = パチパチと
    db $90                         ; $4309  　(space)
    db $3E,$2F,$8D,$2C,$37,$3E     ; $430A  はし゛けては = はじけては
    db $90                         ; $4310  　(space)
    db $2A,$27,$37,$25,$2B         ; $4311  きえていく
    db $8F                         ; $4316  。
    db $F7                         ; $4317  clear page
    db $F0                         ; $4318  end of message


; --------------------------------------------------------------------------
; Message #4 ($4319)
;   テリーは　ほんだなを　しらべた。
;   「どうわ
;   「あるむらに　ちいさな　おとこのこと
;   おんなのこが　すんでいました、、。
; --------------------------------------------------------------------------
Bank66_Msg4:                               ; $4319  (file $108319)
    db $6E,$86,$9C,$3E             ; $4319  テリーは
    db $90                         ; $431D  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $431E  ほんた゛なを = ほんだなを
    db $90                         ; $4324  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4325  しらへ゛た = しらべた
    db $8F                         ; $432A  。
    db $EF,$EE                     ; $432B  newline
    db $FA                         ; $432D  wait-for-button
    db $F7                         ; $432E  clear page
    db $EF,$EE                     ; $432F  newline
    db $F3                         ; $4331  open text box
    db $96                         ; $4332  end name/box tag
    db $38,$8D,$26,$53             ; $4333  と゛うわ = どうわ
    db $EF,$EE                     ; $4337  newline
    db $FA                         ; $4339  wait-for-button
    db $F7                         ; $433A  clear page
    db $EF,$EE                     ; $433B  newline
    db $F3                         ; $433D  open text box
    db $96                         ; $433E  end name/box tag
    db $24,$50,$45,$4E,$3A         ; $433F  あるむらに
    db $90                         ; $4344  　(space)
    db $34,$25,$2E,$39             ; $4345  ちいさな
    db $90                         ; $4349  　(space)
    db $28,$38,$2D,$3D,$2D,$38     ; $434A  おとこのこと
    db $EF,$EE                     ; $4350  newline
    db $90                         ; $4352  　(space)
    db $28,$55,$39,$3D,$2D,$29,$8D ; $4353  おんなのこか゛ = おんなのこが
    db $90                         ; $435A  　(space)
    db $30,$55,$37,$8D,$25,$43,$2F,$33; $435B  すんて゛いました = すんでいました
    db $A4                         ; $4363  、
    db $A4                         ; $4364  、
    db $8F                         ; $4365  。
    db $F7                         ; $4366  clear page
    db $F0                         ; $4367  end of message


; --------------------------------------------------------------------------
; Message #5 ($4368)
;   テリーは　ほんだなを　しらべた。
;   「ミレーヨのにっき、
;   「きょうは　るすばん。　おそろしい
;   まものが　でてきませんように。
; --------------------------------------------------------------------------
Bank66_Msg5:                               ; $4368  (file $108368)
    db $6E,$86,$9C,$3E             ; $4368  テリーは
    db $90                         ; $436C  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $436D  ほんた゛なを = ほんだなを
    db $90                         ; $4373  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4374  しらへ゛た = しらべた
    db $8F                         ; $4379  。
    db $EF,$EE                     ; $437A  newline
    db $FA                         ; $437C  wait-for-button
    db $F7                         ; $437D  clear page
    db $EF,$EE                     ; $437E  newline
    db $F3                         ; $4380  open text box
    db $96                         ; $4381  end name/box tag
    db $7B,$88,$9C,$81,$3D,$3A,$36,$2A; $4382  ミレーヨのにっき
    db $A4                         ; $438A  、
    db $EF,$EE                     ; $438B  newline
    db $FA                         ; $438D  wait-for-button
    db $F7                         ; $438E  clear page
    db $EF,$EE                     ; $438F  newline
    db $F3                         ; $4391  open text box
    db $96                         ; $4392  end name/box tag
    db $2A,$4D,$26,$3E             ; $4393  きょうは
    db $90                         ; $4397  　(space)
    db $50,$30,$3E,$8D,$55         ; $4398  るすは゛ん = るすばん
    db $8F                         ; $439D  。
    db $90                         ; $439E  　(space)
    db $28,$32,$52,$2F,$25         ; $439F  おそろしい
    db $EF,$EE                     ; $43A4  newline
    db $90                         ; $43A6  　(space)
    db $43,$47,$3D,$29,$8D         ; $43A7  まものか゛ = まものが
    db $90                         ; $43AC  　(space)
    db $37,$8D,$37,$2A,$43,$31,$55,$4C,$26,$3A; $43AD  て゛てきませんように = でてきませんように
    db $8F                         ; $43B7  。
    db $F7                         ; $43B8  clear page
    db $F0                         ; $43B9  end of message


; --------------------------------------------------------------------------
; Message #6 ($43BA)
;   [E9]カテリーは　タンスのなかを　しらべた。
;   ちいさな　おとこものの　ふくが
;   つまっている。
; --------------------------------------------------------------------------
Bank66_Msg6:                               ; $43BA  (file $1083BA)
    db $E9                         ; $43BA  ctrl $E9
    db $60,$6E,$86,$9C,$3E         ; $43BB  カテリーは
    db $90                         ; $43C0  　(space)
    db $6A,$8C,$67,$3D,$39,$29,$54 ; $43C1  タンスのなかを
    db $90                         ; $43C8  　(space)
    db $2F,$4E,$41,$8D,$33         ; $43C9  しらへ゛た = しらべた
    db $8F                         ; $43CE  。
    db $EF,$EE                     ; $43CF  newline
    db $FA                         ; $43D1  wait-for-button
    db $F7                         ; $43D2  clear page
    db $EF,$EE                     ; $43D3  newline
    db $F3                         ; $43D5  open text box
    db $34,$25,$2E,$39             ; $43D6  ちいさな
    db $90                         ; $43DA  　(space)
    db $28,$38,$2D,$47,$3D,$3D     ; $43DB  おとこものの
    db $90                         ; $43E1  　(space)
    db $40,$2B,$29,$8D             ; $43E2  ふくか゛ = ふくが
    db $EF,$EE                     ; $43E6  newline
    db $35,$43,$36,$37,$25,$50     ; $43E8  つまっている
    db $8F                         ; $43EE  。
    db $F7                         ; $43EF  clear page
    db $F0                         ; $43F0  end of message


; --------------------------------------------------------------------------
; Message #7 ($43F1)
;   [E9]カテリーは　タンスのなかを　しらべた。
;   ちいさな　おんなものの　ふくが
;   つまっている。
; --------------------------------------------------------------------------
Bank66_Msg7:                               ; $43F1  (file $1083F1)
    db $E9                         ; $43F1  ctrl $E9
    db $60,$6E,$86,$9C,$3E         ; $43F2  カテリーは
    db $90                         ; $43F7  　(space)
    db $6A,$8C,$67,$3D,$39,$29,$54 ; $43F8  タンスのなかを
    db $90                         ; $43FF  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4400  しらへ゛た = しらべた
    db $8F                         ; $4405  。
    db $EF,$EE                     ; $4406  newline
    db $FA                         ; $4408  wait-for-button
    db $F7                         ; $4409  clear page
    db $EF,$EE                     ; $440A  newline
    db $F3                         ; $440C  open text box
    db $34,$25,$2E,$39             ; $440D  ちいさな
    db $90                         ; $4411  　(space)
    db $28,$55,$39,$47,$3D,$3D     ; $4412  おんなものの
    db $90                         ; $4418  　(space)
    db $40,$2B,$29,$8D             ; $4419  ふくか゛ = ふくが
    db $EF,$EE                     ; $441D  newline
    db $35,$43,$36,$37,$25,$50     ; $441F  つまっている
    db $8F                         ; $4425  。
    db $F7                         ; $4426  clear page
    db $F0                         ; $4427  end of message


; --------------------------------------------------------------------------
; Message #8 ($4428)
;   「おまえ　ミレーヨかっ？
;   「、、いや　たしか　ミレーヨは
;   おんなのこ　だったはずだ。
;   「なに？　なまえは　テリー？
;   じゃあ　ようは　ねえな！
;   「ォレのなまえは　ワルぼう。
;   マルタのくにの　ワルぼうだ。
;   ワルぼう「おぼえて　おきな！！
; --------------------------------------------------------------------------
Bank66_Msg8:                               ; $4428  (file $108428)
    db $EA                         ; $4428  ▶ new page
    db $9F                         ; $4429  box tag
    db $96                         ; $442A  end name/box tag
    db $28,$43,$27                 ; $442B  おまえ
    db $90                         ; $442E  　(space)
    db $7B,$88,$9C,$81,$29,$36     ; $442F  ミレーヨかっ
    db $98                         ; $4435  ？
    db $EF,$EE                     ; $4436  newline
    db $FA                         ; $4438  wait-for-button
    db $F7                         ; $4439  clear page
    db $EF,$EE                     ; $443A  newline
    db $F3                         ; $443C  open text box
    db $9F                         ; $443D  box tag
    db $96                         ; $443E  end name/box tag
    db $A4                         ; $443F  、
    db $A4                         ; $4440  、
    db $25,$48                     ; $4441  いや
    db $90                         ; $4443  　(space)
    db $33,$2F,$29                 ; $4444  たしか
    db $90                         ; $4447  　(space)
    db $7B,$88,$9C,$81,$3E         ; $4448  ミレーヨは
    db $EF,$EE                     ; $444D  newline
    db $90,$90                     ; $444F  　　(indent)
    db $28,$55,$39,$3D,$2D         ; $4451  おんなのこ
    db $90                         ; $4456  　(space)
    db $33,$8D,$36,$33,$3E,$30,$8D,$33,$8D; $4457  た゛ったはす゛た゛ = だったはずだ
    db $8F                         ; $4460  。
    db $FA                         ; $4461  wait-for-button
    db $F7                         ; $4462  clear page
    db $EF,$EE                     ; $4463  newline
    db $9F                         ; $4465  box tag
    db $96                         ; $4466  end name/box tag
    db $39,$3A                     ; $4467  なに
    db $98                         ; $4469  ？
    db $90                         ; $446A  　(space)
    db $39,$43,$27,$3E             ; $446B  なまえは
    db $90                         ; $446F  　(space)
    db $6E,$86,$9C                 ; $4470  テリー
    db $98                         ; $4473  ？
    db $EF,$EE                     ; $4474  newline
    db $90,$90                     ; $4476  　　(indent)
    db $2F,$8D,$49,$24             ; $4478  し゛ゃあ = じゃあ
    db $90                         ; $447C  　(space)
    db $4C,$26,$3E                 ; $447D  ようは
    db $90                         ; $4480  　(space)
    db $3C,$27,$39                 ; $4481  ねえな
    db $99                         ; $4484  ！
    db $FA                         ; $4485  wait-for-button
    db $F7                         ; $4486  clear page
    db $EF,$EE                     ; $4487  newline
    db $9F                         ; $4489  box tag
    db $96                         ; $448A  end name/box tag
    db $5E,$88,$3D,$39,$43,$27,$3E ; $448B  ォレのなまえは
    db $90                         ; $4492  　(space)
    db $8A,$87,$42,$8D,$26         ; $4493  ワルほ゛う = ワルぼう
    db $8F                         ; $4498  。
    db $EF,$EE                     ; $4499  newline
    db $90,$90                     ; $449B  　　(indent)
    db $7A,$87,$6A,$3D,$2B,$3A,$3D ; $449D  マルタのくにの
    db $90                         ; $44A4  　(space)
    db $8A,$87,$42,$8D,$26,$33,$8D ; $44A5  ワルほ゛うた゛ = ワルぼうだ
    db $8F                         ; $44AC  。
    db $FA                         ; $44AD  wait-for-button
    db $F7                         ; $44AE  clear page
    db $EF,$EE                     ; $44AF  newline
    db $8A,$87,$42,$8D,$26         ; $44B1  ワルほ゛う = ワルぼう
    db $96                         ; $44B6  end name/box tag
    db $28,$42,$8D,$27,$37         ; $44B7  おほ゛えて = おぼえて
    db $90                         ; $44BC  　(space)
    db $28,$2A,$39                 ; $44BD  おきな
    db $99                         ; $44C0  ！
    db $99                         ; $44C1  ！
    db $EF,$EE                     ; $44C2  newline
    db $F7                         ; $44C4  clear page
    db $F0                         ; $44C5  end of message


; --------------------------------------------------------------------------
; Message #9 ($44C6)
;   「わた　わた。　ミレーヨは
;   どこにいるのかな？　わた　わた。
; --------------------------------------------------------------------------
Bank66_Msg9:                               ; $44C6  (file $1084C6)
    db $EB                         ; $44C6  ▶ new page
    db $9F                         ; $44C7  box tag
    db $96                         ; $44C8  end name/box tag
    db $53,$33                     ; $44C9  わた
    db $90                         ; $44CB  　(space)
    db $53,$33                     ; $44CC  わた
    db $8F                         ; $44CE  。
    db $90                         ; $44CF  　(space)
    db $7B,$88,$9C,$81,$3E         ; $44D0  ミレーヨは
    db $EF,$EE                     ; $44D5  newline
    db $90,$90                     ; $44D7  　　(indent)
    db $38,$8D,$2D,$3A,$25,$50,$3D,$29,$39; $44D9  と゛こにいるのかな = どこにいるのかな
    db $98                         ; $44E2  ？
    db $90                         ; $44E3  　(space)
    db $53,$33                     ; $44E4  わた
    db $90                         ; $44E6  　(space)
    db $53,$33                     ; $44E7  わた
    db $8F                         ; $44E9  。
    db $F7                         ; $44EA  clear page
    db $F0                         ; $44EB  end of message


; --------------------------------------------------------------------------
; Message #10 ($44EC)
;   「まものの　ことばが
;   わかるんだな？
;   「ミレーヨが　どこにいるか
;   しらないか？
;   「、さらわれた？！
;   そうか　おそかったか！
;   「ワルぼう？　ちがうよ。
;   ボクは　わたぼうだよ！
;   わたぼう「え？　ねえさんが　どこに
;   いったか　おしえてほしいって？
;   わたぼう「ん[9D]。じゃあついてきなよ。
;   たぶん　みつかると　おもうよ！
;   わたぼう「キミが　うでのいい
;   マスターだったら　いいな！
;   わたぼう「なんのことか　わからない？
;   フフッ。ついてくれば　わかるさ！
; --------------------------------------------------------------------------
Bank66_Msg10:                               ; $44EC  (file $1084EC)
    db $EB                         ; $44EC  ▶ new page
    db $9F                         ; $44ED  box tag
    db $96                         ; $44EE  end name/box tag
    db $43,$47,$3D,$3D             ; $44EF  まものの
    db $90                         ; $44F3  　(space)
    db $2D,$38,$3E,$8D,$29,$8D     ; $44F4  ことは゛か゛ = ことばが
    db $EF,$EE                     ; $44FA  newline
    db $90,$90                     ; $44FC  　　(indent)
    db $53,$29,$50,$55,$33,$8D,$39 ; $44FE  わかるんた゛な = わかるんだな
    db $98                         ; $4505  ？
    db $FA                         ; $4506  wait-for-button
    db $F7                         ; $4507  clear page
    db $EF,$EE                     ; $4508  newline
    db $9F                         ; $450A  box tag
    db $96                         ; $450B  end name/box tag
    db $7B,$88,$9C,$81,$29,$8D     ; $450C  ミレーヨか゛ = ミレーヨが
    db $90                         ; $4512  　(space)
    db $38,$8D,$2D,$3A,$25,$50,$29 ; $4513  と゛こにいるか = どこにいるか
    db $EF,$EE                     ; $451A  newline
    db $90,$90                     ; $451C  　　(indent)
    db $2F,$4E,$39,$25,$29         ; $451E  しらないか
    db $98                         ; $4523  ？
    db $FA                         ; $4524  wait-for-button
    db $F7                         ; $4525  clear page
    db $EF,$EE                     ; $4526  newline
    db $9F                         ; $4528  box tag
    db $96                         ; $4529  end name/box tag
    db $A4                         ; $452A  、
    db $2E,$4E,$53,$51,$33         ; $452B  さらわれた
    db $98                         ; $4530  ？
    db $99                         ; $4531  ！
    db $EF,$EE                     ; $4532  newline
    db $90,$90                     ; $4534  　　(indent)
    db $32,$26,$29                 ; $4536  そうか
    db $90                         ; $4539  　(space)
    db $28,$32,$29,$36,$33,$29     ; $453A  おそかったか
    db $99                         ; $4540  ！
    db $FA                         ; $4541  wait-for-button
    db $F7                         ; $4542  clear page
    db $EF,$EE                     ; $4543  newline
    db $9F                         ; $4545  box tag
    db $96                         ; $4546  end name/box tag
    db $8A,$87,$42,$8D,$26         ; $4547  ワルほ゛う = ワルぼう
    db $98                         ; $454C  ？
    db $90                         ; $454D  　(space)
    db $34,$29,$8D,$26,$4C         ; $454E  ちか゛うよ = ちがうよ
    db $8F                         ; $4553  。
    db $EF,$EE                     ; $4554  newline
    db $90,$90                     ; $4556  　　(indent)
    db $79,$8D,$62,$3E             ; $4558  ホ゛クは = ボクは
    db $90                         ; $455C  　(space)
    db $53,$33,$42,$8D,$26,$33,$8D,$4C; $455D  わたほ゛うた゛よ = わたぼうだよ
    db $99                         ; $4565  ！
    db $FA                         ; $4566  wait-for-button
    db $F7                         ; $4567  clear page
    db $EF,$EE                     ; $4568  newline
    db $53,$33,$42,$8D,$26         ; $456A  わたほ゛う = わたぼう
    db $96                         ; $456F  end name/box tag
    db $27                         ; $4570  え
    db $98                         ; $4571  ？
    db $90                         ; $4572  　(space)
    db $3C,$27,$2E,$55,$29,$8D     ; $4573  ねえさんか゛ = ねえさんが
    db $90                         ; $4579  　(space)
    db $38,$8D,$2D,$3A             ; $457A  と゛こに = どこに
    db $EF,$EE                     ; $457E  newline
    db $90,$90                     ; $4580  　　(indent)
    db $25,$36,$33,$29             ; $4582  いったか
    db $90                         ; $4586  　(space)
    db $28,$2F,$27,$37,$42,$2F,$25,$36,$37; $4587  おしえてほしいって
    db $98                         ; $4590  ？
    db $FA                         ; $4591  wait-for-button
    db $F7                         ; $4592  clear page
    db $EF,$EE                     ; $4593  newline
    db $53,$33,$42,$8D,$26         ; $4595  わたほ゛う = わたぼう
    db $96                         ; $459A  end name/box tag
    db $55                         ; $459B  ん
    db $9D                         ; $459C  ctrl $9D
    db $8F                         ; $459D  。
    db $2F,$8D,$49,$24,$35,$25,$37,$2A,$39,$4C; $459E  し゛ゃあついてきなよ = じゃあついてきなよ
    db $8F                         ; $45A8  。
    db $EF,$EE                     ; $45A9  newline
    db $90,$90                     ; $45AB  　　(indent)
    db $33,$40,$8D,$55             ; $45AD  たふ゛ん = たぶん
    db $90                         ; $45B1  　(space)
    db $44,$35,$29,$50,$38         ; $45B2  みつかると
    db $90                         ; $45B7  　(space)
    db $28,$47,$26,$4C             ; $45B8  おもうよ
    db $99                         ; $45BC  ！
    db $FA                         ; $45BD  wait-for-button
    db $F7                         ; $45BE  clear page
    db $EF,$EE                     ; $45BF  newline
    db $53,$33,$42,$8D,$26         ; $45C1  わたほ゛う = わたぼう
    db $96                         ; $45C6  end name/box tag
    db $61,$7B,$29,$8D             ; $45C7  キミか゛ = キミが
    db $90                         ; $45CB  　(space)
    db $26,$37,$8D,$3D,$25,$25     ; $45CC  うて゛のいい = うでのいい
    db $EF,$EE                     ; $45D2  newline
    db $90,$90                     ; $45D4  　　(indent)
    db $7A,$67,$6A,$9C,$33,$8D,$36,$33,$4E; $45D6  マスターた゛ったら = マスターだったら
    db $90                         ; $45DF  　(space)
    db $25,$25,$39                 ; $45E0  いいな
    db $99                         ; $45E3  ！
    db $FA                         ; $45E4  wait-for-button
    db $F7                         ; $45E5  clear page
    db $EF,$EE                     ; $45E6  newline
    db $53,$33,$42,$8D,$26         ; $45E8  わたほ゛う = わたぼう
    db $96                         ; $45ED  end name/box tag
    db $39,$55,$3D,$2D,$38,$29     ; $45EE  なんのことか
    db $90                         ; $45F4  　(space)
    db $53,$29,$4E,$39,$25         ; $45F5  わからない
    db $98                         ; $45FA  ？
    db $EF,$EE                     ; $45FB  newline
    db $90,$90                     ; $45FD  　　(indent)
    db $77,$77,$6D                 ; $45FF  フフッ
    db $8F                         ; $4602  。
    db $35,$25,$37,$2B,$51,$3E,$8D ; $4603  ついてくれは゛ = ついてくれば
    db $90                         ; $460A  　(space)
    db $53,$29,$50,$2E             ; $460B  わかるさ
    db $99                         ; $460F  ！
    db $F7                         ; $4610  clear page
    db $F0                         ; $4611  end of message


; --------------------------------------------------------------------------
; Message #11 ($4612)
;   テリーは　ほんだなを　しらべた。
;   「まもの　だいずかん
;   さくしゃ　、　、　ふめい　、　、。
; --------------------------------------------------------------------------
Bank66_Msg11:                               ; $4612  (file $108612)
    db $6E,$86,$9C,$3E             ; $4612  テリーは
    db $90                         ; $4616  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $4617  ほんた゛なを = ほんだなを
    db $90                         ; $461D  　(space)
    db $2F,$4E,$41,$8D,$33         ; $461E  しらへ゛た = しらべた
    db $8F                         ; $4623  。
    db $EF,$EE                     ; $4624  newline
    db $FA                         ; $4626  wait-for-button
    db $F7                         ; $4627  clear page
    db $EF,$EE                     ; $4628  newline
    db $F3                         ; $462A  open text box
    db $96                         ; $462B  end name/box tag
    db $43,$47,$3D                 ; $462C  まもの
    db $90                         ; $462F  　(space)
    db $33,$8D,$25,$30,$8D,$29,$55 ; $4630  た゛いす゛かん = だいずかん
    db $EF,$EE                     ; $4637  newline
    db $90                         ; $4639  　(space)
    db $2E,$2B,$2F,$49             ; $463A  さくしゃ
    db $90                         ; $463E  　(space)
    db $A4                         ; $463F  、
    db $90                         ; $4640  　(space)
    db $A4                         ; $4641  、
    db $90                         ; $4642  　(space)
    db $40,$46,$25                 ; $4643  ふめい
    db $90                         ; $4646  　(space)
    db $A4                         ; $4647  、
    db $90                         ; $4648  　(space)
    db $A4                         ; $4649  、
    db $8F                         ; $464A  。
    db $F7                         ; $464B  clear page
    db $F0                         ; $464C  end of message


; --------------------------------------------------------------------------
; Message #12 ($464D)
;   テリーは　ほんだなを　しらべた。
;   むずかしくて　よめない！
; --------------------------------------------------------------------------
Bank66_Msg12:                               ; $464D  (file $10864D)
    db $6E,$86,$9C,$3E             ; $464D  テリーは
    db $90                         ; $4651  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $4652  ほんた゛なを = ほんだなを
    db $90                         ; $4658  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4659  しらへ゛た = しらべた
    db $8F                         ; $465E  。
    db $EF,$EE                     ; $465F  newline
    db $FA                         ; $4661  wait-for-button
    db $F7                         ; $4662  clear page
    db $EF,$EE                     ; $4663  newline
    db $F3                         ; $4665  open text box
    db $45,$30,$8D,$29,$2F,$2B,$37 ; $4666  むす゛かしくて = むずかしくて
    db $90                         ; $466D  　(space)
    db $4C,$46,$39,$25             ; $466E  よめない
    db $99                         ; $4672  ！
    db $EF,$EE                     ; $4673  newline
    db $F7                         ; $4675  clear page
    db $F0                         ; $4676  end of message


; --------------------------------------------------------------------------
; Message #13 ($4677)
;   テリーは　めのまえを　しらべた。
;   はしらどけいが　まよなかを
;   つげている、、。
; --------------------------------------------------------------------------
Bank66_Msg13:                               ; $4677  (file $108677)
    db $6E,$86,$9C,$3E             ; $4677  テリーは
    db $90                         ; $467B  　(space)
    db $46,$3D,$43,$27,$54         ; $467C  めのまえを
    db $90                         ; $4681  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4682  しらへ゛た = しらべた
    db $8F                         ; $4687  。
    db $EF,$EE                     ; $4688  newline
    db $FA                         ; $468A  wait-for-button
    db $F7                         ; $468B  clear page
    db $EF,$EE                     ; $468C  newline
    db $F3                         ; $468E  open text box
    db $3E,$2F,$4E,$38,$8D,$2C,$25,$29,$8D; $468F  はしらと゛けいか゛ = はしらどけいが
    db $90                         ; $4698  　(space)
    db $43,$4C,$39,$29,$54         ; $4699  まよなかを
    db $EF,$EE                     ; $469E  newline
    db $35,$2C,$8D,$37,$25,$50     ; $46A0  つけ゛ている = つげている
    db $A4                         ; $46A6  、
    db $A4                         ; $46A7  、
    db $8F                         ; $46A8  。
    db $F7                         ; $46A9  clear page
    db $F0                         ; $46AA  end of message


; --------------------------------------------------------------------------
; Message #14 ($46AB)
;   テリーは　ぬいぐるみを　しらべた。
;   ちいさく　かわいい　もじで
;   なにか　かかれている。
;   「ミレーヨの　もの
; --------------------------------------------------------------------------
Bank66_Msg14:                               ; $46AB  (file $1086AB)
    db $6E,$86,$9C,$3E             ; $46AB  テリーは
    db $90                         ; $46AF  　(space)
    db $3B,$25,$2B,$8D,$50,$44,$54 ; $46B0  ぬいく゛るみを = ぬいぐるみを
    db $90                         ; $46B7  　(space)
    db $2F,$4E,$41,$8D,$33         ; $46B8  しらへ゛た = しらべた
    db $8F                         ; $46BD  。
    db $EF,$EE                     ; $46BE  newline
    db $FA                         ; $46C0  wait-for-button
    db $F7                         ; $46C1  clear page
    db $EF,$EE                     ; $46C2  newline
    db $F3                         ; $46C4  open text box
    db $34,$25,$2E,$2B             ; $46C5  ちいさく
    db $90                         ; $46C9  　(space)
    db $29,$53,$25,$25             ; $46CA  かわいい
    db $90                         ; $46CE  　(space)
    db $47,$2F,$8D,$37,$8D         ; $46CF  もし゛て゛ = もじで
    db $EF,$EE                     ; $46D4  newline
    db $39,$3A,$29                 ; $46D6  なにか
    db $90                         ; $46D9  　(space)
    db $29,$29,$51,$37,$25,$50     ; $46DA  かかれている
    db $8F                         ; $46E0  。
    db $FA                         ; $46E1  wait-for-button
    db $F7                         ; $46E2  clear page
    db $EF,$EE                     ; $46E3  newline
    db $96                         ; $46E5  end name/box tag
    db $7B,$88,$9C,$81,$3D         ; $46E6  ミレーヨの
    db $90                         ; $46EB  　(space)
    db $47,$3D                     ; $46EC  もの
    db $EF,$EE                     ; $46EE  newline
    db $F7                         ; $46F0  clear page
    db $F0                         ; $46F1  end of message


; --------------------------------------------------------------------------
; Message #15 ($46F2)
;   「おお　そなたは　マスターじゃろ？
;   ながたび　ごくろうだったのう。
;   「なに？　ここは　どこかとな？
;   ここは　タィジャのくにじゃよ。
;   「おぬしは　わたぼうに　つれられて
;   ここに　やってきたんじゃ。
;   「では　ゆこうか。　しろへゆき
;   おうさまに　あいさつせねば。
; --------------------------------------------------------------------------
Bank66_Msg15:                               ; $46F2  (file $1086F2)
    db $EA                         ; $46F2  ▶ new page
    db $9F                         ; $46F3  box tag
    db $96                         ; $46F4  end name/box tag
    db $28,$28                     ; $46F5  おお
    db $90                         ; $46F7  　(space)
    db $32,$39,$33,$3E             ; $46F8  そなたは
    db $90                         ; $46FC  　(space)
    db $7A,$67,$6A,$9C,$2F,$8D,$49,$52; $46FD  マスターし゛ゃろ = マスターじゃろ
    db $98                         ; $4705  ？
    db $EF,$EE                     ; $4706  newline
    db $90,$90                     ; $4708  　　(indent)
    db $39,$29,$8D,$33,$3F,$8D     ; $470A  なか゛たひ゛ = ながたび
    db $90                         ; $4710  　(space)
    db $2D,$8D,$2B,$52,$26,$33,$8D,$36,$33,$3D,$26; $4711  こ゛くろうた゛ったのう = ごくろうだったのう
    db $8F                         ; $471C  。
    db $FA                         ; $471D  wait-for-button
    db $F7                         ; $471E  clear page
    db $EF,$EE                     ; $471F  newline
    db $9F                         ; $4721  box tag
    db $96                         ; $4722  end name/box tag
    db $39,$3A                     ; $4723  なに
    db $98                         ; $4725  ？
    db $90                         ; $4726  　(space)
    db $2D,$2D,$3E                 ; $4727  ここは
    db $90                         ; $472A  　(space)
    db $38,$8D,$2D,$29,$38,$39     ; $472B  と゛こかとな = どこかとな
    db $98                         ; $4731  ？
    db $EF,$EE                     ; $4732  newline
    db $90,$90                     ; $4734  　　(indent)
    db $2D,$2D,$3E                 ; $4736  ここは
    db $90                         ; $4739  　(space)
    db $6A,$58,$66,$8D,$82,$3D,$2B,$3A,$2F,$8D,$49,$4C; $473A  タィシ゛ャのくにし゛ゃよ = タィジャのくにじゃよ
    db $8F                         ; $4746  。
    db $FA                         ; $4747  wait-for-button
    db $F7                         ; $4748  clear page
    db $EF,$EE                     ; $4749  newline
    db $9F                         ; $474B  box tag
    db $96                         ; $474C  end name/box tag
    db $28,$3B,$2F,$3E             ; $474D  おぬしは
    db $90                         ; $4751  　(space)
    db $53,$33,$42,$8D,$26,$3A     ; $4752  わたほ゛うに = わたぼうに
    db $90                         ; $4758  　(space)
    db $35,$51,$4E,$51,$37         ; $4759  つれられて
    db $EF,$EE                     ; $475E  newline
    db $90,$90                     ; $4760  　　(indent)
    db $2D,$2D,$3A                 ; $4762  ここに
    db $90                         ; $4765  　(space)
    db $48,$36,$37,$2A,$33,$55,$2F,$8D,$49; $4766  やってきたんし゛ゃ = やってきたんじゃ
    db $8F                         ; $476F  。
    db $FA                         ; $4770  wait-for-button
    db $F7                         ; $4771  clear page
    db $EF,$EE                     ; $4772  newline
    db $9F                         ; $4774  box tag
    db $96                         ; $4775  end name/box tag
    db $37,$8D,$3E                 ; $4776  て゛は = では
    db $90                         ; $4779  　(space)
    db $4A,$2D,$26,$29             ; $477A  ゆこうか
    db $8F                         ; $477E  。
    db $90                         ; $477F  　(space)
    db $2F,$52,$41,$4A,$2A         ; $4780  しろへゆき
    db $EF,$EE                     ; $4785  newline
    db $90,$90                     ; $4787  　　(indent)
    db $28,$26,$2E,$43,$3A         ; $4789  おうさまに
    db $90                         ; $478E  　(space)
    db $24,$25,$2E,$35,$31,$3C,$3E,$8D; $478F  あいさつせねは゛ = あいさつせねば
    db $8F                         ; $4797  。
    db $F7                         ; $4798  clear page
    db $F0                         ; $4799  end of message


; --------------------------------------------------------------------------
; Message #16 ($479A)
;   「このくには　おおきな　きのなかに
;   つくられておるんじゃ。
;   「ここは　いちばんしたで
;   おしろは　いちばん　うえじゃ。
; --------------------------------------------------------------------------
Bank66_Msg16:                               ; $479A  (file $10879A)
    db $EA                         ; $479A  ▶ new page
    db $9F                         ; $479B  box tag
    db $96                         ; $479C  end name/box tag
    db $2D,$3D,$2B,$3A,$3E         ; $479D  このくには
    db $90                         ; $47A2  　(space)
    db $28,$28,$2A,$39             ; $47A3  おおきな
    db $90                         ; $47A7  　(space)
    db $2A,$3D,$39,$29,$3A         ; $47A8  きのなかに
    db $EF,$EE                     ; $47AD  newline
    db $90,$90                     ; $47AF  　　(indent)
    db $35,$2B,$4E,$51,$37,$28,$50,$55,$2F,$8D,$49; $47B1  つくられておるんし゛ゃ = つくられておるんじゃ
    db $8F                         ; $47BC  。
    db $FA                         ; $47BD  wait-for-button
    db $F7                         ; $47BE  clear page
    db $EF,$EE                     ; $47BF  newline
    db $9F                         ; $47C1  box tag
    db $96                         ; $47C2  end name/box tag
    db $2D,$2D,$3E                 ; $47C3  ここは
    db $90                         ; $47C6  　(space)
    db $25,$34,$3E,$8D,$55,$2F,$33,$37,$8D; $47C7  いちは゛んしたて゛ = いちばんしたで
    db $EF,$EE                     ; $47D0  newline
    db $90,$90                     ; $47D2  　　(indent)
    db $28,$2F,$52,$3E             ; $47D4  おしろは
    db $90                         ; $47D8  　(space)
    db $25,$34,$3E,$8D,$55         ; $47D9  いちは゛ん = いちばん
    db $90                         ; $47DE  　(space)
    db $26,$27,$2F,$8D,$49         ; $47DF  うえし゛ゃ = うえじゃ
    db $8F                         ; $47E4  。
    db $F7                         ; $47E5  clear page
    db $F0                         ; $47E6  end of message


; --------------------------------------------------------------------------
; Message #17 ($47E7)
;   「おっ。　わたぼうが　あたらしい
;   マスターを　つれてきたのかい？
; --------------------------------------------------------------------------
Bank66_Msg17:                               ; $47E7  (file $1087E7)
    db $EA                         ; $47E7  ▶ new page
    db $9F                         ; $47E8  box tag
    db $96                         ; $47E9  end name/box tag
    db $28,$36                     ; $47EA  おっ
    db $8F                         ; $47EC  。
    db $90                         ; $47ED  　(space)
    db $53,$33,$42,$8D,$26,$29,$8D ; $47EE  わたほ゛うか゛ = わたぼうが
    db $90                         ; $47F5  　(space)
    db $24,$33,$4E,$2F,$25         ; $47F6  あたらしい
    db $EF,$EE                     ; $47FB  newline
    db $90,$90                     ; $47FD  　　(indent)
    db $7A,$67,$6A,$9C,$54         ; $47FF  マスターを
    db $90                         ; $4804  　(space)
    db $35,$51,$37,$2A,$33,$3D,$29,$25; $4805  つれてきたのかい
    db $98                         ; $480D  ？
    db $F7                         ; $480E  clear page
    db $F0                         ; $480F  end of message


; --------------------------------------------------------------------------
; Message #18 ($4810)
;   「そうじゃ。　これから　おうさまに
;   あわせに　ゆくところじゃ。
; --------------------------------------------------------------------------
Bank66_Msg18:                               ; $4810  (file $108810)
    db $EA                         ; $4810  ▶ new page
    db $9F                         ; $4811  box tag
    db $96                         ; $4812  end name/box tag
    db $32,$26,$2F,$8D,$49         ; $4813  そうし゛ゃ = そうじゃ
    db $8F                         ; $4818  。
    db $90                         ; $4819  　(space)
    db $2D,$51,$29,$4E             ; $481A  これから
    db $90                         ; $481E  　(space)
    db $28,$26,$2E,$43,$3A         ; $481F  おうさまに
    db $EF,$EE                     ; $4824  newline
    db $90,$90                     ; $4826  　　(indent)
    db $24,$53,$31,$3A             ; $4828  あわせに
    db $90                         ; $482C  　(space)
    db $4A,$2B,$38,$2D,$52,$2F,$8D,$49; $482D  ゆくところし゛ゃ = ゆくところじゃ
    db $8F                         ; $4835  。
    db $F7                         ; $4836  clear page
    db $F0                         ; $4837  end of message


; --------------------------------------------------------------------------
; Message #19 ($4838)
;   「ほしふりのたいかいで
;   ゆうしょうしてくれよ[95]！
; --------------------------------------------------------------------------
Bank66_Msg19:                               ; $4838  (file $108838)
    db $EA                         ; $4838  ▶ new page
    db $9F                         ; $4839  box tag
    db $96                         ; $483A  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$37,$8D; $483B  ほしふりのたいかいて゛ = ほしふりのたいかいで
    db $EF,$EE                     ; $4846  newline
    db $90,$90                     ; $4848  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$37,$2B,$51,$4C; $484A  ゆうしょうしてくれよ
    db $95                         ; $4854  ctrl $95
    db $99                         ; $4855  ！
    db $F7                         ; $4856  clear page
    db $F0                         ; $4857  end of message


; --------------------------------------------------------------------------
; Message #20 ($4858)
;   「さあ。　おうさまに　あいに
;   ゆくのじゃ。
; --------------------------------------------------------------------------
Bank66_Msg20:                               ; $4858  (file $108858)
    db $EA                         ; $4858  ▶ new page
    db $9F                         ; $4859  box tag
    db $96                         ; $485A  end name/box tag
    db $2E,$24                     ; $485B  さあ
    db $8F                         ; $485D  。
    db $90                         ; $485E  　(space)
    db $28,$26,$2E,$43,$3A         ; $485F  おうさまに
    db $90                         ; $4864  　(space)
    db $24,$25,$3A                 ; $4865  あいに
    db $EF,$EE                     ; $4868  newline
    db $90,$90                     ; $486A  　　(indent)
    db $4A,$2B,$3D,$2F,$8D,$49     ; $486C  ゆくのし゛ゃ = ゆくのじゃ
    db $8F                         ; $4872  。
    db $F7                         ; $4873  clear page
    db $F0                         ; $4874  end of message


; --------------------------------------------------------------------------
; Message #21 ($4875)
;   「わたしは　このくにの　だいじん。
;   おまえが　あらたなマスターか？
;   「おうさまが　おこまりなのだ。
;   どうか　たのみを　きいてほしい！
; --------------------------------------------------------------------------
Bank66_Msg21:                               ; $4875  (file $108875)
    db $EA                         ; $4875  ▶ new page
    db $9F                         ; $4876  box tag
    db $96                         ; $4877  end name/box tag
    db $53,$33,$2F,$3E             ; $4878  わたしは
    db $90                         ; $487C  　(space)
    db $2D,$3D,$2B,$3A,$3D         ; $487D  このくにの
    db $90                         ; $4882  　(space)
    db $33,$8D,$25,$2F,$8D,$55     ; $4883  た゛いし゛ん = だいじん
    db $8F                         ; $4889  。
    db $EF,$EE                     ; $488A  newline
    db $90,$90                     ; $488C  　　(indent)
    db $28,$43,$27,$29,$8D         ; $488E  おまえか゛ = おまえが
    db $90                         ; $4893  　(space)
    db $24,$4E,$33,$39,$7A,$67,$6A,$9C,$29; $4894  あらたなマスターか
    db $98                         ; $489D  ？
    db $FA                         ; $489E  wait-for-button
    db $F7                         ; $489F  clear page
    db $EF,$EE                     ; $48A0  newline
    db $9F                         ; $48A2  box tag
    db $96                         ; $48A3  end name/box tag
    db $28,$26,$2E,$43,$29,$8D     ; $48A4  おうさまか゛ = おうさまが
    db $90                         ; $48AA  　(space)
    db $28,$2D,$43,$4F,$39,$3D,$33,$8D; $48AB  おこまりなのた゛ = おこまりなのだ
    db $8F                         ; $48B3  。
    db $EF,$EE                     ; $48B4  newline
    db $90,$90                     ; $48B6  　　(indent)
    db $38,$8D,$26,$29             ; $48B8  と゛うか = どうか
    db $90                         ; $48BC  　(space)
    db $33,$3D,$44,$54             ; $48BD  たのみを
    db $90                         ; $48C1  　(space)
    db $2A,$25,$37,$42,$2F,$25     ; $48C2  きいてほしい
    db $99                         ; $48C8  ！
    db $F7                         ; $48C9  clear page
    db $F0                         ; $48CA  end of message


; --------------------------------------------------------------------------
; Message #22 ($48CB)
;   「おうさまは　こまっている。
;   どうか　ちからになってほしい。
; --------------------------------------------------------------------------
Bank66_Msg22:                               ; $48CB  (file $1088CB)
    db $EA                         ; $48CB  ▶ new page
    db $9F                         ; $48CC  box tag
    db $96                         ; $48CD  end name/box tag
    db $28,$26,$2E,$43,$3E         ; $48CE  おうさまは
    db $90                         ; $48D3  　(space)
    db $2D,$43,$36,$37,$25,$50     ; $48D4  こまっている
    db $8F                         ; $48DA  。
    db $EF,$EE                     ; $48DB  newline
    db $90,$90                     ; $48DD  　　(indent)
    db $38,$8D,$26,$29             ; $48DF  と゛うか = どうか
    db $90                         ; $48E3  　(space)
    db $34,$29,$4E,$3A,$39,$36,$37,$42,$2F,$25; $48E4  ちからになってほしい
    db $8F                         ; $48EE  。
    db $F7                         ; $48EF  clear page
    db $F0                         ; $48F0  end of message


; --------------------------------------------------------------------------
; Message #23 ($48F1)
;   「どうか　おうさまの　ねがいを
;   きいてあげてください。
; --------------------------------------------------------------------------
Bank66_Msg23:                               ; $48F1  (file $1088F1)
    db $EA                         ; $48F1  ▶ new page
    db $9F                         ; $48F2  box tag
    db $96                         ; $48F3  end name/box tag
    db $38,$8D,$26,$29             ; $48F4  と゛うか = どうか
    db $90                         ; $48F8  　(space)
    db $28,$26,$2E,$43,$3D         ; $48F9  おうさまの
    db $90                         ; $48FE  　(space)
    db $3C,$29,$8D,$25,$54         ; $48FF  ねか゛いを = ねがいを
    db $EF,$EE                     ; $4904  newline
    db $90,$90                     ; $4906  　　(indent)
    db $2A,$25,$37,$24,$2C,$8D,$37,$2B,$33,$8D,$2E,$25; $4908  きいてあけ゛てくた゛さい = きいてあげてください
    db $8F                         ; $4914  。
    db $F7                         ; $4915  clear page
    db $F0                         ; $4916  end of message


; --------------------------------------------------------------------------
; Message #24 ($4917)
;   「ここは　タィジャの　おしろです。
; --------------------------------------------------------------------------
Bank66_Msg24:                               ; $4917  (file $108917)
    db $EA                         ; $4917  ▶ new page
    db $9F                         ; $4918  box tag
    db $96                         ; $4919  end name/box tag
    db $2D,$2D,$3E                 ; $491A  ここは
    db $90                         ; $491D  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $491E  タィシ゛ャの = タィジャの
    db $90                         ; $4924  　(space)
    db $28,$2F,$52,$37,$8D,$30     ; $4925  おしろて゛す = おしろです
    db $8F                         ; $492B  。
    db $EF,$EE                     ; $492C  newline
    db $F7                         ; $492E  clear page
    db $F0                         ; $492F  end of message


; --------------------------------------------------------------------------
; Message #25 ($4930)
;   「はやく　おうさまに
;   あってくるんじゃ！
; --------------------------------------------------------------------------
Bank66_Msg25:                               ; $4930  (file $108930)
    db $EA                         ; $4930  ▶ new page
    db $9F                         ; $4931  box tag
    db $96                         ; $4932  end name/box tag
    db $3E,$48,$2B                 ; $4933  はやく
    db $90                         ; $4936  　(space)
    db $28,$26,$2E,$43,$3A         ; $4937  おうさまに
    db $EF,$EE                     ; $493C  newline
    db $90,$90                     ; $493E  　　(indent)
    db $24,$36,$37,$2B,$50,$55,$2F,$8D,$49; $4940  あってくるんし゛ゃ = あってくるんじゃ
    db $99                         ; $4949  ！
    db $F7                         ; $494A  clear page
    db $F0                         ; $494B  end of message


; --------------------------------------------------------------------------
; Message #26 ($494C)
;   「そうですか、、。
; --------------------------------------------------------------------------
Bank66_Msg26:                               ; $494C  (file $10894C)
    db $EB                         ; $494C  ▶ new page
    db $9F                         ; $494D  box tag
    db $96                         ; $494E  end name/box tag
    db $32,$26,$37,$8D,$30,$29     ; $494F  そうて゛すか = そうですか
    db $A4                         ; $4955  、
    db $A4                         ; $4956  、
    db $8F                         ; $4957  。
    db $EF,$EE                     ; $4958  newline
    db $F7                         ; $495A  clear page
    db $F0                         ; $495B  end of message


; --------------------------------------------------------------------------
; Message #27 ($495C)
;   〈テリー〉は　たからばこを　あけた！
; --------------------------------------------------------------------------
Bank66_Msg27:                               ; $495C  (file $10895C)
    db $F6                         ; $495C  «insert hero name» (テリー)
    db $3E                         ; $495D  は
    db $90                         ; $495E  　(space)
    db $33,$29,$4E,$3E,$8D,$2D,$54 ; $495F  たからは゛こを = たからばこを
    db $90                         ; $4966  　(space)
    db $24,$2C,$33                 ; $4967  あけた
    db $99                         ; $496A  ！
    db $EF,$EE                     ; $496B  newline
    db $FA                         ; $496D  wait-for-button
    db $F7                         ; $496E  clear page
    db $F0                         ; $496F  end of message


; --------------------------------------------------------------------------
; Message #28 ($4970)
;   〈テリー〉は　やくそうを
;   てにいれた。
; --------------------------------------------------------------------------
Bank66_Msg28:                               ; $4970  (file $108970)
    db $F6                         ; $4970  «insert hero name» (テリー)
    db $3E                         ; $4971  は
    db $90                         ; $4972  　(space)
    db $48,$2B,$32,$26,$54         ; $4973  やくそうを
    db $EF,$EE                     ; $4978  newline
    db $37,$3A,$25,$51,$33         ; $497A  てにいれた
    db $8F                         ; $497F  。
    db $F7                         ; $4980  clear page
    db $F0                         ; $4981  end of message


; --------------------------------------------------------------------------
; Message #29 ($4982)
;   〈テリー〉は　やくそうを
;   みつけた。
;   しかし　もちものが
;   いっぱいだ。
;   〈テリー〉は　やくそうを
;   たからばこに　もどした。
; --------------------------------------------------------------------------
Bank66_Msg29:                               ; $4982  (file $108982)
    db $F6                         ; $4982  «insert hero name» (テリー)
    db $3E                         ; $4983  は
    db $90                         ; $4984  　(space)
    db $48,$2B,$32,$26,$54         ; $4985  やくそうを
    db $EF,$EE                     ; $498A  newline
    db $44,$35,$2C,$33             ; $498C  みつけた
    db $8F                         ; $4990  。
    db $FA                         ; $4991  wait-for-button
    db $F7                         ; $4992  clear page
    db $EF,$EE                     ; $4993  newline
    db $2F,$29,$2F                 ; $4995  しかし
    db $90                         ; $4998  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $4999  もちものか゛ = もちものが
    db $EF,$EE                     ; $499F  newline
    db $25,$36,$3E,$8E,$25,$33,$8D ; $49A1  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $49A8  。
    db $FA                         ; $49A9  wait-for-button
    db $F7                         ; $49AA  clear page
    db $EF,$EE                     ; $49AB  newline
    db $F6                         ; $49AD  «insert hero name» (テリー)
    db $3E                         ; $49AE  は
    db $90                         ; $49AF  　(space)
    db $48,$2B,$32,$26,$54         ; $49B0  やくそうを
    db $EF,$EE                     ; $49B5  newline
    db $33,$29,$4E,$3E,$8D,$2D,$3A ; $49B7  たからは゛こに = たからばこに
    db $90                         ; $49BE  　(space)
    db $47,$38,$8D,$2F,$33         ; $49BF  もと゛した = もどした
    db $8F                         ; $49C4  。
    db $F7                         ; $49C5  clear page
    db $F0                         ; $49C6  end of message


; --------------------------------------------------------------------------
; Message #30 ($49C7)
;   〈テリー〉は　たからばこを　あけた！
; --------------------------------------------------------------------------
Bank66_Msg30:                               ; $49C7  (file $1089C7)
    db $F6                         ; $49C7  «insert hero name» (テリー)
    db $3E                         ; $49C8  は
    db $90                         ; $49C9  　(space)
    db $33,$29,$4E,$3E,$8D,$2D,$54 ; $49CA  たからは゛こを = たからばこを
    db $90                         ; $49D1  　(space)
    db $24,$2C,$33                 ; $49D2  あけた
    db $99                         ; $49D5  ！
    db $EF,$EE                     ; $49D6  newline
    db $FA                         ; $49D8  wait-for-button
    db $F7                         ; $49D9  clear page
    db $F0                         ; $49DA  end of message


; --------------------------------------------------------------------------
; Message #31 ($49DB)
;   「ここは　タィジャのくにだよ！
; --------------------------------------------------------------------------
Bank66_Msg31:                               ; $49DB  (file $1089DB)
    db $EA                         ; $49DB  ▶ new page
    db $9F                         ; $49DC  box tag
    db $96                         ; $49DD  end name/box tag
    db $2D,$2D,$3E                 ; $49DE  ここは
    db $90                         ; $49E1  　(space)
    db $6A,$58,$66,$8D,$82,$3D,$2B,$3A,$33,$8D,$4C; $49E2  タィシ゛ャのくにた゛よ = タィジャのくにだよ
    db $99                         ; $49ED  ！
    db $EF,$EE                     ; $49EE  newline
    db $F7                         ; $49F0  clear page
    db $F0                         ; $49F1  end of message


; --------------------------------------------------------------------------
; Message #32 ($49F2)
;   「よくきた！　あらたなマスターよ！
;   わしは　このくにの　おうじゃ。
;   おう「そなたの　なは　なんともうす？
;   EN: The King introduces himself and asks the hero's name.
; --------------------------------------------------------------------------
Bank66_Msg32:                               ; $49F2  (file $1089F2)
    db $EA                         ; $49F2  ▶ new page
    db $9F                         ; $49F3  box tag
    db $96                         ; $49F4  end name/box tag
    db $4C,$2B,$2A,$33             ; $49F5  よくきた
    db $99                         ; $49F9  ！
    db $90                         ; $49FA  　(space)
    db $24,$4E,$33,$39,$7A,$67,$6A,$9C,$4C; $49FB  あらたなマスターよ
    db $99                         ; $4A04  ！
    db $EF,$EE                     ; $4A05  newline
    db $90,$90                     ; $4A07  　　(indent)
    db $53,$2F,$3E                 ; $4A09  わしは
    db $90                         ; $4A0C  　(space)
    db $2D,$3D,$2B,$3A,$3D         ; $4A0D  このくにの
    db $90                         ; $4A12  　(space)
    db $28,$26,$2F,$8D,$49         ; $4A13  おうし゛ゃ = おうじゃ
    db $8F                         ; $4A18  。
    db $FA                         ; $4A19  wait-for-button
    db $F7                         ; $4A1A  clear page
    db $EF,$EE                     ; $4A1B  newline
    db $28,$26                     ; $4A1D  おう  (speaker: おう)
    db $96                         ; $4A1F  end name/box tag
    db $32,$39,$33,$3D             ; $4A20  そなたの
    db $90                         ; $4A24  　(space)
    db $39,$3E                     ; $4A25  なは
    db $90                         ; $4A27  　(space)
    db $39,$55,$38,$47,$26,$30     ; $4A28  なんともうす
    db $98                         ; $4A2E  ？
    db $EF,$EE                     ; $4A2F  newline
    db $F7                         ; $4A31  clear page
    db $F0                         ; $4A32  end of message


; --------------------------------------------------------------------------
; Message #33 ($4A33)
;   おう「〈テリー〉よっ！　さっそくだが
;   わしのねがいを　きいてくれ！
;   おう「ねがい　というのは
;   ほかでもない、
;   おう「ほしふりのよるの　たいかいに
;   でて　ゆうしょうしてほしいのだ！
;   おう「、なに？　それより　さらわれた
;   ねえさんを　さがしたいと？
;   おう「そなたは　わしの　たのみを
;   ききにまいったのでは　ないのか？
;   おう「、、うむ。
;   、、、むむむむむっ。
;   おう「、、、！　だが　さがすよりも
;   かんたんな　ほうほうが　あるぞ。
;   おう「この　ほしふりのたいかいで
;   ゆうしょうするのだ！
;   おう「いいつたえでは　ゆうしょう
;   したものは　ゆめがかなうという。
;   おう「そなたの　ねえさんにあいたい
;   という　ゆめも　かなうであろう！
;   おう「というのは　ちと　わしの
;   つごうも　はいっているがの。
;   おう「まあ　ねえさんを　さがしつつ
;   ゆうしょうも　めざすがよい！
;   おう「さあ。
;   そなたに　まものを　あたえよう。
;   おう「まものがおらんでは　マスターの
;   しごとは　つとまらんからな！
;   おう「うえのかいは　まものたちの
;   ぼくじょうに　なっておるゆえ、
;   おう「そこで　プリォともうすものに
;   まものを　もらってくるがよい。
; --------------------------------------------------------------------------
Bank66_Msg33:                               ; $4A33  (file $108A33)
    db $EA                         ; $4A33  ▶ new page
    db $28,$26                     ; $4A34  おう  (speaker: おう)
    db $96                         ; $4A36  end name/box tag
    db $F6                         ; $4A37  «insert hero name» (テリー)
    db $4C,$36                     ; $4A38  よっ
    db $99                         ; $4A3A  ！
    db $90                         ; $4A3B  　(space)
    db $2E,$36,$32,$2B,$33,$8D,$29,$8D; $4A3C  さっそくた゛か゛ = さっそくだが
    db $EF,$EE                     ; $4A44  newline
    db $90,$90                     ; $4A46  　　(indent)
    db $53,$2F,$3D,$3C,$29,$8D,$25,$54; $4A48  わしのねか゛いを = わしのねがいを
    db $90                         ; $4A50  　(space)
    db $2A,$25,$37,$2B,$51         ; $4A51  きいてくれ
    db $99                         ; $4A56  ！
    db $FA                         ; $4A57  wait-for-button
    db $F7                         ; $4A58  clear page
    db $EF,$EE                     ; $4A59  newline
    db $28,$26                     ; $4A5B  おう  (speaker: おう)
    db $96                         ; $4A5D  end name/box tag
    db $3C,$29,$8D,$25             ; $4A5E  ねか゛い = ねがい
    db $90                         ; $4A62  　(space)
    db $38,$25,$26,$3D,$3E         ; $4A63  というのは
    db $EF,$EE                     ; $4A68  newline
    db $90,$90                     ; $4A6A  　　(indent)
    db $42,$29,$37,$8D,$47,$39,$25 ; $4A6C  ほかて゛もない = ほかでもない
    db $A4                         ; $4A73  、
    db $FA                         ; $4A74  wait-for-button
    db $F7                         ; $4A75  clear page
    db $EF,$EE                     ; $4A76  newline
    db $28,$26                     ; $4A78  おう  (speaker: おう)
    db $96                         ; $4A7A  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3D; $4A7B  ほしふりのよるの
    db $90                         ; $4A83  　(space)
    db $33,$25,$29,$25,$3A         ; $4A84  たいかいに
    db $EF,$EE                     ; $4A89  newline
    db $90,$90                     ; $4A8B  　　(indent)
    db $37,$8D,$37                 ; $4A8D  て゛て = でて
    db $90                         ; $4A90  　(space)
    db $4A,$26,$2F,$4D,$26,$2F,$37,$42,$2F,$25,$3D,$33,$8D; $4A91  ゆうしょうしてほしいのた゛ = ゆうしょうしてほしいのだ
    db $99                         ; $4A9E  ！
    db $FA                         ; $4A9F  wait-for-button
    db $F7                         ; $4AA0  clear page
    db $EF,$EE                     ; $4AA1  newline
    db $28,$26                     ; $4AA3  おう  (speaker: おう)
    db $96                         ; $4AA5  end name/box tag
    db $A4                         ; $4AA6  、
    db $39,$3A                     ; $4AA7  なに
    db $98                         ; $4AA9  ？
    db $90                         ; $4AAA  　(space)
    db $32,$51,$4C,$4F             ; $4AAB  それより
    db $90                         ; $4AAF  　(space)
    db $2E,$4E,$53,$51,$33         ; $4AB0  さらわれた
    db $EF,$EE                     ; $4AB5  newline
    db $90,$90                     ; $4AB7  　　(indent)
    db $3C,$27,$2E,$55,$54         ; $4AB9  ねえさんを
    db $90                         ; $4ABE  　(space)
    db $2E,$29,$8D,$2F,$33,$25,$38 ; $4ABF  さか゛したいと = さがしたいと
    db $98                         ; $4AC6  ？
    db $FA                         ; $4AC7  wait-for-button
    db $F7                         ; $4AC8  clear page
    db $EF,$EE                     ; $4AC9  newline
    db $28,$26                     ; $4ACB  おう  (speaker: おう)
    db $96                         ; $4ACD  end name/box tag
    db $32,$39,$33,$3E             ; $4ACE  そなたは
    db $90                         ; $4AD2  　(space)
    db $53,$2F,$3D                 ; $4AD3  わしの
    db $90                         ; $4AD6  　(space)
    db $33,$3D,$44,$54             ; $4AD7  たのみを
    db $EF,$EE                     ; $4ADB  newline
    db $90,$90                     ; $4ADD  　　(indent)
    db $2A,$2A,$3A,$43,$25,$36,$33,$3D,$37,$8D,$3E; $4ADF  ききにまいったのて゛は = ききにまいったのでは
    db $90                         ; $4AEA  　(space)
    db $39,$25,$3D,$29             ; $4AEB  ないのか
    db $98                         ; $4AEF  ？
    db $FA                         ; $4AF0  wait-for-button
    db $F7                         ; $4AF1  clear page
    db $EF,$EE                     ; $4AF2  newline
    db $28,$26                     ; $4AF4  おう  (speaker: おう)
    db $96                         ; $4AF6  end name/box tag
    db $A4                         ; $4AF7  、
    db $A4                         ; $4AF8  、
    db $26,$45                     ; $4AF9  うむ
    db $8F                         ; $4AFB  。
    db $EF,$EE                     ; $4AFC  newline
    db $90,$90                     ; $4AFE  　　(indent)
    db $A4                         ; $4B00  、
    db $A4                         ; $4B01  、
    db $A4                         ; $4B02  、
    db $45,$45,$45,$45,$45,$36     ; $4B03  むむむむむっ
    db $8F                         ; $4B09  。
    db $FA                         ; $4B0A  wait-for-button
    db $F7                         ; $4B0B  clear page
    db $EF,$EE                     ; $4B0C  newline
    db $28,$26                     ; $4B0E  おう  (speaker: おう)
    db $96                         ; $4B10  end name/box tag
    db $A4                         ; $4B11  、
    db $A4                         ; $4B12  、
    db $A4                         ; $4B13  、
    db $99                         ; $4B14  ！
    db $90                         ; $4B15  　(space)
    db $33,$8D,$29,$8D             ; $4B16  た゛か゛ = だが
    db $90                         ; $4B1A  　(space)
    db $2E,$29,$8D,$30,$4C,$4F,$47 ; $4B1B  さか゛すよりも = さがすよりも
    db $EF,$EE                     ; $4B22  newline
    db $90,$90                     ; $4B24  　　(indent)
    db $29,$55,$33,$55,$39         ; $4B26  かんたんな
    db $90                         ; $4B2B  　(space)
    db $42,$26,$42,$26,$29,$8D     ; $4B2C  ほうほうか゛ = ほうほうが
    db $90                         ; $4B32  　(space)
    db $24,$50,$32,$8D             ; $4B33  あるそ゛ = あるぞ
    db $8F                         ; $4B37  。
    db $FA                         ; $4B38  wait-for-button
    db $F7                         ; $4B39  clear page
    db $EF,$EE                     ; $4B3A  newline
    db $28,$26                     ; $4B3C  おう  (speaker: おう)
    db $96                         ; $4B3E  end name/box tag
    db $2D,$3D                     ; $4B3F  この
    db $90                         ; $4B41  　(space)
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$37,$8D; $4B42  ほしふりのたいかいて゛ = ほしふりのたいかいで
    db $EF,$EE                     ; $4B4D  newline
    db $90,$90                     ; $4B4F  　　(indent)
    db $4A,$26,$2F,$4D,$26,$30,$50,$3D,$33,$8D; $4B51  ゆうしょうするのた゛ = ゆうしょうするのだ
    db $99                         ; $4B5B  ！
    db $FA                         ; $4B5C  wait-for-button
    db $F7                         ; $4B5D  clear page
    db $EF,$EE                     ; $4B5E  newline
    db $28,$26                     ; $4B60  おう  (speaker: おう)
    db $96                         ; $4B62  end name/box tag
    db $25,$25,$35,$33,$27,$37,$8D,$3E; $4B63  いいつたえて゛は = いいつたえでは
    db $90                         ; $4B6B  　(space)
    db $4A,$26,$2F,$4D,$26         ; $4B6C  ゆうしょう
    db $EF,$EE                     ; $4B71  newline
    db $90,$90                     ; $4B73  　　(indent)
    db $2F,$33,$47,$3D,$3E         ; $4B75  したものは
    db $90                         ; $4B7A  　(space)
    db $4A,$46,$29,$8D,$29,$39,$26,$38,$25,$26; $4B7B  ゆめか゛かなうという = ゆめがかなうという
    db $8F                         ; $4B85  。
    db $FA                         ; $4B86  wait-for-button
    db $F7                         ; $4B87  clear page
    db $EF,$EE                     ; $4B88  newline
    db $28,$26                     ; $4B8A  おう  (speaker: おう)
    db $96                         ; $4B8C  end name/box tag
    db $32,$39,$33,$3D             ; $4B8D  そなたの
    db $90                         ; $4B91  　(space)
    db $3C,$27,$2E,$55,$3A,$24,$25,$33,$25; $4B92  ねえさんにあいたい
    db $EF,$EE                     ; $4B9B  newline
    db $90,$90                     ; $4B9D  　　(indent)
    db $38,$25,$26                 ; $4B9F  という
    db $90                         ; $4BA2  　(space)
    db $4A,$46,$47                 ; $4BA3  ゆめも
    db $90                         ; $4BA6  　(space)
    db $29,$39,$26,$37,$8D,$24,$52,$26; $4BA7  かなうて゛あろう = かなうであろう
    db $99                         ; $4BAF  ！
    db $FA                         ; $4BB0  wait-for-button
    db $F7                         ; $4BB1  clear page
    db $EF,$EE                     ; $4BB2  newline
    db $28,$26                     ; $4BB4  おう  (speaker: おう)
    db $96                         ; $4BB6  end name/box tag
    db $38,$25,$26,$3D,$3E         ; $4BB7  というのは
    db $90                         ; $4BBC  　(space)
    db $34,$38                     ; $4BBD  ちと
    db $90                         ; $4BBF  　(space)
    db $53,$2F,$3D                 ; $4BC0  わしの
    db $EF,$EE                     ; $4BC3  newline
    db $90,$90                     ; $4BC5  　　(indent)
    db $35,$2D,$8D,$26,$47         ; $4BC7  つこ゛うも = つごうも
    db $90                         ; $4BCC  　(space)
    db $3E,$25,$36,$37,$25,$50,$29,$8D,$3D; $4BCD  はいっているか゛の = はいっているがの
    db $8F                         ; $4BD6  。
    db $FA                         ; $4BD7  wait-for-button
    db $F7                         ; $4BD8  clear page
    db $EF,$EE                     ; $4BD9  newline
    db $28,$26                     ; $4BDB  おう  (speaker: おう)
    db $96                         ; $4BDD  end name/box tag
    db $43,$24                     ; $4BDE  まあ
    db $90                         ; $4BE0  　(space)
    db $3C,$27,$2E,$55,$54         ; $4BE1  ねえさんを
    db $90                         ; $4BE6  　(space)
    db $2E,$29,$8D,$2F,$35,$35     ; $4BE7  さか゛しつつ = さがしつつ
    db $EF,$EE                     ; $4BED  newline
    db $90,$90                     ; $4BEF  　　(indent)
    db $4A,$26,$2F,$4D,$26,$47     ; $4BF1  ゆうしょうも
    db $90                         ; $4BF7  　(space)
    db $46,$2E,$8D,$30,$29,$8D,$4C,$25; $4BF8  めさ゛すか゛よい = めざすがよい
    db $99                         ; $4C00  ！
    db $FA                         ; $4C01  wait-for-button
    db $F7                         ; $4C02  clear page
    db $EF,$EE                     ; $4C03  newline
    db $28,$26                     ; $4C05  おう  (speaker: おう)
    db $96                         ; $4C07  end name/box tag
    db $2E,$24                     ; $4C08  さあ
    db $8F                         ; $4C0A  。
    db $EF,$EE                     ; $4C0B  newline
    db $90,$90                     ; $4C0D  　　(indent)
    db $32,$39,$33,$3A             ; $4C0F  そなたに
    db $90                         ; $4C13  　(space)
    db $43,$47,$3D,$54             ; $4C14  まものを
    db $90                         ; $4C18  　(space)
    db $24,$33,$27,$4C,$26         ; $4C19  あたえよう
    db $8F                         ; $4C1E  。
    db $FA                         ; $4C1F  wait-for-button
    db $F7                         ; $4C20  clear page
    db $EF,$EE                     ; $4C21  newline
    db $28,$26                     ; $4C23  おう  (speaker: おう)
    db $96                         ; $4C25  end name/box tag
    db $43,$47,$3D,$29,$8D,$28,$4E,$55,$37,$8D,$3E; $4C26  まものか゛おらんて゛は = まものがおらんでは
    db $90                         ; $4C31  　(space)
    db $7A,$67,$6A,$9C,$3D         ; $4C32  マスターの
    db $EF,$EE                     ; $4C37  newline
    db $90,$90                     ; $4C39  　　(indent)
    db $2F,$2D,$8D,$38,$3E         ; $4C3B  しこ゛とは = しごとは
    db $90                         ; $4C40  　(space)
    db $35,$38,$43,$4E,$55,$29,$4E,$39; $4C41  つとまらんからな
    db $99                         ; $4C49  ！
    db $FA                         ; $4C4A  wait-for-button
    db $F7                         ; $4C4B  clear page
    db $EF,$EE                     ; $4C4C  newline
    db $28,$26                     ; $4C4E  おう  (speaker: おう)
    db $96                         ; $4C50  end name/box tag
    db $26,$27,$3D,$29,$25,$3E     ; $4C51  うえのかいは
    db $90                         ; $4C57  　(space)
    db $43,$47,$3D,$33,$34,$3D     ; $4C58  まものたちの
    db $EF,$EE                     ; $4C5E  newline
    db $90,$90                     ; $4C60  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $4C62  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $4C6A  　(space)
    db $39,$36,$37,$28,$50,$4A,$27 ; $4C6B  なっておるゆえ
    db $A4                         ; $4C72  、
    db $FA                         ; $4C73  wait-for-button
    db $F7                         ; $4C74  clear page
    db $EF,$EE                     ; $4C75  newline
    db $28,$26                     ; $4C77  おう  (speaker: おう)
    db $96                         ; $4C79  end name/box tag
    db $32,$2D,$37,$8D             ; $4C7A  そこて゛ = そこで
    db $90                         ; $4C7E  　(space)
    db $77,$8E,$86,$5E,$38,$47,$26,$30,$47,$3D,$3A; $4C7F  フ゜リォともうすものに = プリォともうすものに
    db $EF,$EE                     ; $4C8A  newline
    db $90,$90                     ; $4C8C  　　(indent)
    db $43,$47,$3D,$54             ; $4C8E  まものを
    db $90                         ; $4C92  　(space)
    db $47,$4E,$36,$37,$2B,$50,$29,$8D,$4C,$25; $4C93  もらってくるか゛よい = もらってくるがよい
    db $8F                         ; $4C9D  。
    db $F7                         ; $4C9E  clear page
    db $F0                         ; $4C9F  end of message


; --------------------------------------------------------------------------
; Message #34 ($4CA0)
;   「ほしふりのたいかいに　かてば
;   みなも　よろこぶことでしょう。
; --------------------------------------------------------------------------
Bank66_Msg34:                               ; $4CA0  (file $108CA0)
    db $EB                         ; $4CA0  ▶ new page
    db $9F                         ; $4CA1  box tag
    db $96                         ; $4CA2  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$3A; $4CA3  ほしふりのたいかいに
    db $90                         ; $4CAD  　(space)
    db $29,$37,$3E,$8D             ; $4CAE  かては゛ = かてば
    db $EF,$EE                     ; $4CB2  newline
    db $90,$90                     ; $4CB4  　　(indent)
    db $44,$39,$47                 ; $4CB6  みなも
    db $90                         ; $4CB9  　(space)
    db $4C,$52,$2D,$40,$8D,$2D,$38,$37,$8D,$2F,$4D,$26; $4CBA  よろこふ゛ことて゛しょう = よろこぶことでしょう
    db $8F                         ; $4CC6  。
    db $F7                         ; $4CC7  clear page
    db $F0                         ; $4CC8  end of message


; --------------------------------------------------------------------------
; Message #35 ($4CC9)
;   「ゆうしょうできれば　きっと
;   ねえさんと　あえるだろうさ！
; --------------------------------------------------------------------------
Bank66_Msg35:                               ; $4CC9  (file $108CC9)
    db $EB                         ; $4CC9  ▶ new page
    db $9F                         ; $4CCA  box tag
    db $96                         ; $4CCB  end name/box tag
    db $4A,$26,$2F,$4D,$26,$37,$8D,$2A,$51,$3E,$8D; $4CCC  ゆうしょうて゛きれは゛ = ゆうしょうできれば
    db $90                         ; $4CD7  　(space)
    db $2A,$36,$38                 ; $4CD8  きっと
    db $EF,$EE                     ; $4CDB  newline
    db $90,$90                     ; $4CDD  　　(indent)
    db $3C,$27,$2E,$55,$38         ; $4CDF  ねえさんと
    db $90                         ; $4CE4  　(space)
    db $24,$27,$50,$33,$8D,$52,$26,$2E; $4CE5  あえるた゛ろうさ = あえるだろうさ
    db $99                         ; $4CED  ！
    db $F7                         ; $4CEE  clear page
    db $F0                         ; $4CEF  end of message


; --------------------------------------------------------------------------
; Message #36 ($4CF0)
;   〈テリー〉は　ほんだなを　しらべた。
;   「タィジャのくに、
;   ほんを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg36:                               ; $4CF0  (file $108CF0)
    db $F6                         ; $4CF0  «insert hero name» (テリー)
    db $3E                         ; $4CF1  は
    db $90                         ; $4CF2  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $4CF3  ほんた゛なを = ほんだなを
    db $90                         ; $4CF9  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4CFA  しらへ゛た = しらべた
    db $8F                         ; $4CFF  。
    db $EF,$EE                     ; $4D00  newline
    db $FA                         ; $4D02  wait-for-button
    db $F7                         ; $4D03  clear page
    db $EF,$EE                     ; $4D04  newline
    db $F3                         ; $4D06  open text box
    db $96                         ; $4D07  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D,$2B,$3A; $4D08  タィシ゛ャのくに = タィジャのくに
    db $A4                         ; $4D10  、
    db $EF,$EE                     ; $4D11  newline
    db $FA                         ; $4D13  wait-for-button
    db $F7                         ; $4D14  clear page
    db $EF,$EE                     ; $4D15  newline
    db $F3                         ; $4D17  open text box
    db $42,$55,$54                 ; $4D18  ほんを
    db $90                         ; $4D1B  　(space)
    db $4C,$44,$43,$30,$29         ; $4D1C  よみますか
    db $98                         ; $4D21  ？
    db $EF,$EE                     ; $4D22  newline
    db $FF                         ; $4D24  はい/いいえ
    db $F0                         ; $4D25  end of message


; --------------------------------------------------------------------------
; Message #37 ($4D26)
;   「おおきなきのなかに　つくられた
;   ちいさなくにである。
;   「ほかのくにも　おなじように
;   おおきなきのなかに　できている。
;   「すべてのくにには　たびのとびらと
;   よばれる　ものがあり、
;   「とびらを　ぬけると　まものの　すむ
;   いせかいに　はこばれる。
;   「ほしふりのよるが　ちかづくと
;   タィジャに　じしんが　おこる。
;   「これは　タィジャが　せいちょうを
;   おこなっている　あかしである。
; --------------------------------------------------------------------------
Bank66_Msg37:                               ; $4D26  (file $108D26)
    db $96                         ; $4D26  end name/box tag
    db $28,$28,$2A,$39,$2A,$3D,$39,$29,$3A; $4D27  おおきなきのなかに
    db $90                         ; $4D30  　(space)
    db $35,$2B,$4E,$51,$33         ; $4D31  つくられた
    db $EF,$EE                     ; $4D36  newline
    db $90                         ; $4D38  　(space)
    db $34,$25,$2E,$39,$2B,$3A,$37,$8D,$24,$50; $4D39  ちいさなくにて゛ある = ちいさなくにである
    db $8F                         ; $4D43  。
    db $FA                         ; $4D44  wait-for-button
    db $F7                         ; $4D45  clear page
    db $EF,$EE                     ; $4D46  newline
    db $96                         ; $4D48  end name/box tag
    db $42,$29,$3D,$2B,$3A,$47     ; $4D49  ほかのくにも
    db $90                         ; $4D4F  　(space)
    db $28,$39,$2F,$8D,$4C,$26,$3A ; $4D50  おなし゛ように = おなじように
    db $EF,$EE                     ; $4D57  newline
    db $90                         ; $4D59  　(space)
    db $28,$28,$2A,$39,$2A,$3D,$39,$29,$3A; $4D5A  おおきなきのなかに
    db $90                         ; $4D63  　(space)
    db $37,$8D,$2A,$37,$25,$50     ; $4D64  て゛きている = できている
    db $8F                         ; $4D6A  。
    db $FA                         ; $4D6B  wait-for-button
    db $F7                         ; $4D6C  clear page
    db $EF,$EE                     ; $4D6D  newline
    db $96                         ; $4D6F  end name/box tag
    db $30,$41,$8D,$37,$3D,$2B,$3A,$3A,$3E; $4D70  すへ゛てのくにには = すべてのくにには
    db $90                         ; $4D79  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$38; $4D7A  たひ゛のとひ゛らと = たびのとびらと
    db $EF,$EE                     ; $4D83  newline
    db $90                         ; $4D85  　(space)
    db $4C,$3E,$8D,$51,$50         ; $4D86  よは゛れる = よばれる
    db $90                         ; $4D8B  　(space)
    db $47,$3D,$29,$8D,$24,$4F     ; $4D8C  ものか゛あり = ものがあり
    db $A4                         ; $4D92  、
    db $FA                         ; $4D93  wait-for-button
    db $F7                         ; $4D94  clear page
    db $EF,$EE                     ; $4D95  newline
    db $96                         ; $4D97  end name/box tag
    db $38,$3F,$8D,$4E,$54         ; $4D98  とひ゛らを = とびらを
    db $90                         ; $4D9D  　(space)
    db $3B,$2C,$50,$38             ; $4D9E  ぬけると
    db $90                         ; $4DA2  　(space)
    db $43,$47,$3D,$3D             ; $4DA3  まものの
    db $90                         ; $4DA7  　(space)
    db $30,$45                     ; $4DA8  すむ
    db $EF,$EE                     ; $4DAA  newline
    db $90                         ; $4DAC  　(space)
    db $25,$31,$29,$25,$3A         ; $4DAD  いせかいに
    db $90                         ; $4DB2  　(space)
    db $3E,$2D,$3E,$8D,$51,$50     ; $4DB3  はこは゛れる = はこばれる
    db $8F                         ; $4DB9  。
    db $FA                         ; $4DBA  wait-for-button
    db $F7                         ; $4DBB  clear page
    db $EF,$EE                     ; $4DBC  newline
    db $96                         ; $4DBE  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$29,$8D; $4DBF  ほしふりのよるか゛ = ほしふりのよるが
    db $90                         ; $4DC8  　(space)
    db $34,$29,$35,$8D,$2B,$38     ; $4DC9  ちかつ゛くと = ちかづくと
    db $EF,$EE                     ; $4DCF  newline
    db $90                         ; $4DD1  　(space)
    db $6A,$58,$66,$8D,$82,$3A     ; $4DD2  タィシ゛ャに = タィジャに
    db $90                         ; $4DD8  　(space)
    db $2F,$8D,$2F,$55,$29,$8D     ; $4DD9  し゛しんか゛ = じしんが
    db $90                         ; $4DDF  　(space)
    db $28,$2D,$50                 ; $4DE0  おこる
    db $8F                         ; $4DE3  。
    db $FA                         ; $4DE4  wait-for-button
    db $F7                         ; $4DE5  clear page
    db $EF,$EE                     ; $4DE6  newline
    db $96                         ; $4DE8  end name/box tag
    db $2D,$51,$3E                 ; $4DE9  これは
    db $90                         ; $4DEC  　(space)
    db $6A,$58,$66,$8D,$82,$29,$8D ; $4DED  タィシ゛ャか゛ = タィジャが
    db $90                         ; $4DF4  　(space)
    db $31,$25,$34,$4D,$26,$54     ; $4DF5  せいちょうを
    db $EF,$EE                     ; $4DFB  newline
    db $90                         ; $4DFD  　(space)
    db $28,$2D,$39,$36,$37,$25,$50 ; $4DFE  おこなっている
    db $90                         ; $4E05  　(space)
    db $24,$29,$2F,$37,$8D,$24,$50 ; $4E06  あかして゛ある = あかしである
    db $8F                         ; $4E0D  。
    db $F7                         ; $4E0E  clear page
    db $F0                         ; $4E0F  end of message


; --------------------------------------------------------------------------
; Message #38 ($4E10)
;   〈テリー〉は　ほんを
;   ほんだなに　もどした。
; --------------------------------------------------------------------------
Bank66_Msg38:                               ; $4E10  (file $108E10)
    db $F6                         ; $4E10  «insert hero name» (テリー)
    db $3E                         ; $4E11  は
    db $90                         ; $4E12  　(space)
    db $42,$55,$54                 ; $4E13  ほんを
    db $EF,$EE                     ; $4E16  newline
    db $42,$55,$33,$8D,$39,$3A     ; $4E18  ほんた゛なに = ほんだなに
    db $90                         ; $4E1E  　(space)
    db $47,$38,$8D,$2F,$33         ; $4E1F  もと゛した = もどした
    db $8F                         ; $4E24  。
    db $F7                         ; $4E25  clear page
    db $F0                         ; $4E26  end of message


; --------------------------------------------------------------------------
; Message #39 ($4E27)
;   〈テリー〉は　ほんだなを　しらべた。
;   「モンスターマスター、
;   ほんを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg39:                               ; $4E27  (file $108E27)
    db $F6                         ; $4E27  «insert hero name» (テリー)
    db $3E                         ; $4E28  は
    db $90                         ; $4E29  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $4E2A  ほんた゛なを = ほんだなを
    db $90                         ; $4E30  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4E31  しらへ゛た = しらべた
    db $8F                         ; $4E36  。
    db $EF,$EE                     ; $4E37  newline
    db $FA                         ; $4E39  wait-for-button
    db $F7                         ; $4E3A  clear page
    db $EF,$EE                     ; $4E3B  newline
    db $F3                         ; $4E3D  open text box
    db $96                         ; $4E3E  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C; $4E3F  モンスターマスター
    db $A4                         ; $4E48  、
    db $EF,$EE                     ; $4E49  newline
    db $FA                         ; $4E4B  wait-for-button
    db $F7                         ; $4E4C  clear page
    db $EF,$EE                     ; $4E4D  newline
    db $F3                         ; $4E4F  open text box
    db $42,$55,$54                 ; $4E50  ほんを
    db $90                         ; $4E53  　(space)
    db $4C,$44,$43,$30,$29         ; $4E54  よみますか
    db $98                         ; $4E59  ？
    db $EF,$EE                     ; $4E5A  newline
    db $FF                         ; $4E5C  はい/いいえ
    db $F0                         ; $4E5D  end of message


; --------------------------------------------------------------------------
; Message #40 ($4E5E)
;   「まものたちの　ことばを　りかいし
;   あやつることができる　ひとびと。
;   「かんぜんに　まものと　わかりあえる
;   マスターは　あまりいない。
;   「ことばを　りかいできるだけでなく
;   まものに　すかれることがたいせつ。
;   「マスターは　このせかいに　もともと
;   すんでいたものと、
;   「タィジャのせいれい　わたぼうが
;   どこかから　つれてくるものがいる。
; --------------------------------------------------------------------------
Bank66_Msg40:                               ; $4E5E  (file $108E5E)
    db $96                         ; $4E5E  end name/box tag
    db $43,$47,$3D,$33,$34,$3D     ; $4E5F  まものたちの
    db $90                         ; $4E65  　(space)
    db $2D,$38,$3E,$8D,$54         ; $4E66  ことは゛を = ことばを
    db $90                         ; $4E6B  　(space)
    db $4F,$29,$25,$2F             ; $4E6C  りかいし
    db $EF,$EE                     ; $4E70  newline
    db $90                         ; $4E72  　(space)
    db $24,$48,$35,$50,$2D,$38,$29,$8D,$37,$8D,$2A,$50; $4E73  あやつることか゛て゛きる = あやつることができる
    db $90                         ; $4E7F  　(space)
    db $3F,$38,$3F,$8D,$38         ; $4E80  ひとひ゛と = ひとびと
    db $8F                         ; $4E85  。
    db $FA                         ; $4E86  wait-for-button
    db $F7                         ; $4E87  clear page
    db $EF,$EE                     ; $4E88  newline
    db $96                         ; $4E8A  end name/box tag
    db $29,$55,$31,$8D,$55,$3A     ; $4E8B  かんせ゛んに = かんぜんに
    db $90                         ; $4E91  　(space)
    db $43,$47,$3D,$38             ; $4E92  まものと
    db $90                         ; $4E96  　(space)
    db $53,$29,$4F,$24,$27,$50     ; $4E97  わかりあえる
    db $EF,$EE                     ; $4E9D  newline
    db $90                         ; $4E9F  　(space)
    db $7A,$67,$6A,$9C,$3E         ; $4EA0  マスターは
    db $90                         ; $4EA5  　(space)
    db $24,$43,$4F,$25,$39,$25     ; $4EA6  あまりいない
    db $8F                         ; $4EAC  。
    db $FA                         ; $4EAD  wait-for-button
    db $F7                         ; $4EAE  clear page
    db $EF,$EE                     ; $4EAF  newline
    db $96                         ; $4EB1  end name/box tag
    db $2D,$38,$3E,$8D,$54         ; $4EB2  ことは゛を = ことばを
    db $90                         ; $4EB7  　(space)
    db $4F,$29,$25,$37,$8D,$2A,$50,$33,$8D,$2C,$37,$8D,$39,$2B; $4EB8  りかいて゛きるた゛けて゛なく = りかいできるだけでなく
    db $EF,$EE                     ; $4EC6  newline
    db $90                         ; $4EC8  　(space)
    db $43,$47,$3D,$3A             ; $4EC9  まものに
    db $90                         ; $4ECD  　(space)
    db $30,$29,$51,$50,$2D,$38,$29,$8D,$33,$25,$31,$35; $4ECE  すかれることか゛たいせつ = すかれることがたいせつ
    db $8F                         ; $4EDA  。
    db $FA                         ; $4EDB  wait-for-button
    db $F7                         ; $4EDC  clear page
    db $EF,$EE                     ; $4EDD  newline
    db $96                         ; $4EDF  end name/box tag
    db $7A,$67,$6A,$9C,$3E         ; $4EE0  マスターは
    db $90                         ; $4EE5  　(space)
    db $2D,$3D,$31,$29,$25,$3A     ; $4EE6  このせかいに
    db $90                         ; $4EEC  　(space)
    db $47,$38,$47,$38             ; $4EED  もともと
    db $EF,$EE                     ; $4EF1  newline
    db $90                         ; $4EF3  　(space)
    db $30,$55,$37,$8D,$25,$33,$47,$3D,$38; $4EF4  すんて゛いたものと = すんでいたものと
    db $A4                         ; $4EFD  、
    db $FA                         ; $4EFE  wait-for-button
    db $F7                         ; $4EFF  clear page
    db $EF,$EE                     ; $4F00  newline
    db $96                         ; $4F02  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D,$31,$25,$51,$25; $4F03  タィシ゛ャのせいれい = タィジャのせいれい
    db $90                         ; $4F0D  　(space)
    db $53,$33,$42,$8D,$26,$29,$8D ; $4F0E  わたほ゛うか゛ = わたぼうが
    db $EF,$EE                     ; $4F15  newline
    db $90                         ; $4F17  　(space)
    db $38,$8D,$2D,$29,$29,$4E     ; $4F18  と゛こかから = どこかから
    db $90                         ; $4F1E  　(space)
    db $35,$51,$37,$2B,$50,$47,$3D,$29,$8D,$25,$50; $4F1F  つれてくるものか゛いる = つれてくるものがいる
    db $8F                         ; $4F2A  。
    db $F7                         ; $4F2B  clear page
    db $F0                         ; $4F2C  end of message


; --------------------------------------------------------------------------
; Message #41 ($4F2D)
;   「ぼくも　ますたーに　なりたいな。
;   どうすれば　なれるのかな？
; --------------------------------------------------------------------------
Bank66_Msg41:                               ; $4F2D  (file $108F2D)
    db $EB                         ; $4F2D  ▶ new page
    db $9F                         ; $4F2E  box tag
    db $96                         ; $4F2F  end name/box tag
    db $42,$8D,$2B,$47             ; $4F30  ほ゛くも = ぼくも
    db $90                         ; $4F34  　(space)
    db $43,$30,$33,$9C,$3A         ; $4F35  ますたーに
    db $90                         ; $4F3A  　(space)
    db $39,$4F,$33,$25,$39         ; $4F3B  なりたいな
    db $8F                         ; $4F40  。
    db $EF,$EE                     ; $4F41  newline
    db $90,$90                     ; $4F43  　　(indent)
    db $38,$8D,$26,$30,$51,$3E,$8D ; $4F45  と゛うすれは゛ = どうすれば
    db $90                         ; $4F4C  　(space)
    db $39,$51,$50,$3D,$29,$39     ; $4F4D  なれるのかな
    db $98                         ; $4F53  ？
    db $F7                         ; $4F54  clear page
    db $F0                         ; $4F55  end of message


; --------------------------------------------------------------------------
; Message #42 ($4F56)
;   おう「うえのかいは　まものたちの
;   ぼくじょうに　なっておる。
;   おう「そこで　プリォともうすものに
;   まものを　もらってくるがよい。
; --------------------------------------------------------------------------
Bank66_Msg42:                               ; $4F56  (file $108F56)
    db $EA                         ; $4F56  ▶ new page
    db $28,$26                     ; $4F57  おう  (speaker: おう)
    db $96                         ; $4F59  end name/box tag
    db $26,$27,$3D,$29,$25,$3E     ; $4F5A  うえのかいは
    db $90                         ; $4F60  　(space)
    db $43,$47,$3D,$33,$34,$3D     ; $4F61  まものたちの
    db $EF,$EE                     ; $4F67  newline
    db $90,$90                     ; $4F69  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $4F6B  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $4F73  　(space)
    db $39,$36,$37,$28,$50         ; $4F74  なっておる
    db $8F                         ; $4F79  。
    db $FA                         ; $4F7A  wait-for-button
    db $F7                         ; $4F7B  clear page
    db $EF,$EE                     ; $4F7C  newline
    db $28,$26                     ; $4F7E  おう  (speaker: おう)
    db $96                         ; $4F80  end name/box tag
    db $32,$2D,$37,$8D             ; $4F81  そこて゛ = そこで
    db $90                         ; $4F85  　(space)
    db $77,$8E,$86,$5E,$38,$47,$26,$30,$47,$3D,$3A; $4F86  フ゜リォともうすものに = プリォともうすものに
    db $EF,$EE                     ; $4F91  newline
    db $90,$90                     ; $4F93  　　(indent)
    db $43,$47,$3D,$54             ; $4F95  まものを
    db $90                         ; $4F99  　(space)
    db $47,$4E,$36,$37,$2B,$50,$29,$8D,$4C,$25; $4F9A  もらってくるか゛よい = もらってくるがよい
    db $8F                         ; $4FA4  。
    db $F7                         ; $4FA5  clear page
    db $F0                         ; $4FA6  end of message


; --------------------------------------------------------------------------
; Message #43 ($4FA7)
;   「ほしふりのたいかいで　このくには
;   まけつづけている。
;   「しかしこんかいは　しゅさいこく！
;   どうしても　かたねばっ。
; --------------------------------------------------------------------------
Bank66_Msg43:                               ; $4FA7  (file $108FA7)
    db $EA                         ; $4FA7  ▶ new page
    db $9F                         ; $4FA8  box tag
    db $96                         ; $4FA9  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$37,$8D; $4FAA  ほしふりのたいかいて゛ = ほしふりのたいかいで
    db $90                         ; $4FB5  　(space)
    db $2D,$3D,$2B,$3A,$3E         ; $4FB6  このくには
    db $EF,$EE                     ; $4FBB  newline
    db $90,$90                     ; $4FBD  　　(indent)
    db $43,$2C,$35,$35,$8D,$2C,$37,$25,$50; $4FBF  まけつつ゛けている = まけつづけている
    db $8F                         ; $4FC8  。
    db $FA                         ; $4FC9  wait-for-button
    db $F7                         ; $4FCA  clear page
    db $EF,$EE                     ; $4FCB  newline
    db $9F                         ; $4FCD  box tag
    db $96                         ; $4FCE  end name/box tag
    db $2F,$29,$2F,$2D,$55,$29,$25,$3E; $4FCF  しかしこんかいは
    db $90                         ; $4FD7  　(space)
    db $2F,$4B,$2E,$25,$2D,$2B     ; $4FD8  しゅさいこく
    db $99                         ; $4FDE  ！
    db $EF,$EE                     ; $4FDF  newline
    db $90,$90                     ; $4FE1  　　(indent)
    db $38,$8D,$26,$2F,$37,$47     ; $4FE3  と゛うしても = どうしても
    db $90                         ; $4FE9  　(space)
    db $29,$33,$3C,$3E,$8D,$36     ; $4FEA  かたねは゛っ = かたねばっ
    db $8F                         ; $4FF0  。
    db $F7                         ; $4FF1  clear page
    db $F0                         ; $4FF2  end of message


; --------------------------------------------------------------------------
; Message #44 ($4FF3)
;   「ほしふりのよるの　いいつたえを
;   かたりましょう。
;   「〈n〉たびの　まんげつののち
;   ほしふりのよるは　やってくる。
;   「いくひゃく　いくせんの
;   ほしたちが、
;   「てんを　おおわんばかりに
;   ふりそそぐ。
;   「いくひゃくまん　いくせんまんの
;   ほしたちが、
;   「だいちを　ひかりのかけらで
;   おおいつくす、、。
;   「ほしふりのよる。
;   「あまたの　いのちの　ふりそそぐ
;   よる、、。
;   「このよるを　いわい　せいだいな
;   うでくらべが　もよおされます。
;   「この　うでくらべが　ほしふりの
;   よるの　かくとうたいかいです。
; --------------------------------------------------------------------------
Bank66_Msg44:                               ; $4FF3  (file $108FF3)
    db $EB                         ; $4FF3  ▶ new page
    db $9F                         ; $4FF4  box tag
    db $96                         ; $4FF5  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3D; $4FF6  ほしふりのよるの
    db $90                         ; $4FFE  　(space)
    db $25,$25,$35,$33,$27,$54     ; $4FFF  いいつたえを
    db $EF,$EE                     ; $5005  newline
    db $90,$90                     ; $5007  　　(indent)
    db $29,$33,$4F,$43,$2F,$4D,$26 ; $5009  かたりましょう
    db $8F                         ; $5010  。
    db $FA                         ; $5011  wait-for-button
    db $F7                         ; $5012  clear page
    db $EF,$EE                     ; $5013  newline
    db $9F                         ; $5015  box tag
    db $96                         ; $5016  end name/box tag
    db $04,$07                     ; $5017  «insert number»
    db $33,$3F,$8D,$3D             ; $5019  たひ゛の = たびの
    db $90                         ; $501D  　(space)
    db $43,$55,$2C,$8D,$35,$3D,$3D,$34; $501E  まんけ゛つののち = まんげつののち
    db $EF,$EE                     ; $5026  newline
    db $90,$90                     ; $5028  　　(indent)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3E; $502A  ほしふりのよるは
    db $90                         ; $5032  　(space)
    db $48,$36,$37,$2B,$50         ; $5033  やってくる
    db $8F                         ; $5038  。
    db $FA                         ; $5039  wait-for-button
    db $F7                         ; $503A  clear page
    db $EF,$EE                     ; $503B  newline
    db $9F                         ; $503D  box tag
    db $96                         ; $503E  end name/box tag
    db $25,$2B,$3F,$49,$2B         ; $503F  いくひゃく
    db $90                         ; $5044  　(space)
    db $25,$2B,$31,$55,$3D         ; $5045  いくせんの
    db $EF,$EE                     ; $504A  newline
    db $90,$90                     ; $504C  　　(indent)
    db $42,$2F,$33,$34,$29,$8D     ; $504E  ほしたちか゛ = ほしたちが
    db $A4                         ; $5054  、
    db $FA                         ; $5055  wait-for-button
    db $F7                         ; $5056  clear page
    db $EF,$EE                     ; $5057  newline
    db $9F                         ; $5059  box tag
    db $96                         ; $505A  end name/box tag
    db $37,$55,$54                 ; $505B  てんを
    db $90                         ; $505E  　(space)
    db $28,$28,$53,$55,$3E,$8D,$29,$4F,$3A; $505F  おおわんは゛かりに = おおわんばかりに
    db $EF,$EE                     ; $5068  newline
    db $90,$90                     ; $506A  　　(indent)
    db $40,$4F,$32,$32,$2B,$8D     ; $506C  ふりそそく゛ = ふりそそぐ
    db $8F                         ; $5072  。
    db $FA                         ; $5073  wait-for-button
    db $F7                         ; $5074  clear page
    db $EF,$EE                     ; $5075  newline
    db $9F                         ; $5077  box tag
    db $96                         ; $5078  end name/box tag
    db $25,$2B,$3F,$49,$2B,$43,$55 ; $5079  いくひゃくまん
    db $90                         ; $5080  　(space)
    db $25,$2B,$31,$55,$43,$55,$3D ; $5081  いくせんまんの
    db $EF,$EE                     ; $5088  newline
    db $90,$90                     ; $508A  　　(indent)
    db $42,$2F,$33,$34,$29,$8D     ; $508C  ほしたちか゛ = ほしたちが
    db $A4                         ; $5092  、
    db $FA                         ; $5093  wait-for-button
    db $F7                         ; $5094  clear page
    db $EF,$EE                     ; $5095  newline
    db $9F                         ; $5097  box tag
    db $96                         ; $5098  end name/box tag
    db $33,$8D,$25,$34,$54         ; $5099  た゛いちを = だいちを
    db $90                         ; $509E  　(space)
    db $3F,$29,$4F,$3D,$29,$2C,$4E,$37,$8D; $509F  ひかりのかけらて゛ = ひかりのかけらで
    db $EF,$EE                     ; $50A8  newline
    db $90,$90                     ; $50AA  　　(indent)
    db $28,$28,$25,$35,$2B,$30     ; $50AC  おおいつくす
    db $A4                         ; $50B2  、
    db $A4                         ; $50B3  、
    db $8F                         ; $50B4  。
    db $FA                         ; $50B5  wait-for-button
    db $F7                         ; $50B6  clear page
    db $EF,$EE                     ; $50B7  newline
    db $9F                         ; $50B9  box tag
    db $96                         ; $50BA  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50 ; $50BB  ほしふりのよる
    db $8F                         ; $50C2  。
    db $EF,$EE                     ; $50C3  newline
    db $FA                         ; $50C5  wait-for-button
    db $F7                         ; $50C6  clear page
    db $EF,$EE                     ; $50C7  newline
    db $F3                         ; $50C9  open text box
    db $9F                         ; $50CA  box tag
    db $96                         ; $50CB  end name/box tag
    db $24,$43,$33,$3D             ; $50CC  あまたの
    db $90                         ; $50D0  　(space)
    db $25,$3D,$34,$3D             ; $50D1  いのちの
    db $90                         ; $50D5  　(space)
    db $40,$4F,$32,$32,$2B,$8D     ; $50D6  ふりそそく゛ = ふりそそぐ
    db $EF,$EE                     ; $50DC  newline
    db $90,$90                     ; $50DE  　　(indent)
    db $4C,$50                     ; $50E0  よる
    db $A4                         ; $50E2  、
    db $A4                         ; $50E3  、
    db $8F                         ; $50E4  。
    db $FA                         ; $50E5  wait-for-button
    db $F7                         ; $50E6  clear page
    db $EF,$EE                     ; $50E7  newline
    db $9F                         ; $50E9  box tag
    db $96                         ; $50EA  end name/box tag
    db $2D,$3D,$4C,$50,$54         ; $50EB  このよるを
    db $90                         ; $50F0  　(space)
    db $25,$53,$25                 ; $50F1  いわい
    db $90                         ; $50F4  　(space)
    db $31,$25,$33,$8D,$25,$39     ; $50F5  せいた゛いな = せいだいな
    db $EF,$EE                     ; $50FB  newline
    db $90,$90                     ; $50FD  　　(indent)
    db $26,$37,$8D,$2B,$4E,$41,$8D,$29,$8D; $50FF  うて゛くらへ゛か゛ = うでくらべが
    db $90                         ; $5108  　(space)
    db $47,$4C,$28,$2E,$51,$43,$30 ; $5109  もよおされます
    db $8F                         ; $5110  。
    db $FA                         ; $5111  wait-for-button
    db $F7                         ; $5112  clear page
    db $EF,$EE                     ; $5113  newline
    db $9F                         ; $5115  box tag
    db $96                         ; $5116  end name/box tag
    db $2D,$3D                     ; $5117  この
    db $90                         ; $5119  　(space)
    db $26,$37,$8D,$2B,$4E,$41,$8D,$29,$8D; $511A  うて゛くらへ゛か゛ = うでくらべが
    db $90                         ; $5123  　(space)
    db $42,$2F,$40,$4F,$3D         ; $5124  ほしふりの
    db $EF,$EE                     ; $5129  newline
    db $90,$90                     ; $512B  　　(indent)
    db $4C,$50,$3D                 ; $512D  よるの
    db $90                         ; $5130  　(space)
    db $29,$2B,$38,$26,$33,$25,$29,$25,$37,$8D,$30; $5131  かくとうたいかいて゛す = かくとうたいかいです
    db $8F                         ; $513C  。
    db $F7                         ; $513D  clear page
    db $F0                         ; $513E  end of message


; --------------------------------------------------------------------------
; Message #45 ($513F)
;   「もういちど　ほしふりのよるの
;   いいつたえを　かたりましょうか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg45:                               ; $513F  (file $10913F)
    db $EB                         ; $513F  ▶ new page
    db $9F                         ; $5140  box tag
    db $96                         ; $5141  end name/box tag
    db $47,$26,$25,$34,$38,$8D     ; $5142  もういちと゛ = もういちど
    db $90                         ; $5148  　(space)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3D; $5149  ほしふりのよるの
    db $EF,$EE                     ; $5151  newline
    db $90,$90                     ; $5153  　　(indent)
    db $25,$25,$35,$33,$27,$54     ; $5155  いいつたえを
    db $90                         ; $515B  　(space)
    db $29,$33,$4F,$43,$2F,$4D,$26,$29; $515C  かたりましょうか
    db $98                         ; $5164  ？
    db $FF                         ; $5165  はい/いいえ
    db $F0                         ; $5166  end of message


; --------------------------------------------------------------------------
; Message #46 ($5167)
;   「こころえました。
;   「ほしふりのよるは　〈n〉たびの
;   まんげつののち　やってきます。
;   「このよるには　それはもう
;   たくさんの　ほしたちが、
;   「つぎからつぎに　ふってきます。
;   「このほしのかがやきを　たとえて
;   いのちの　かがやきのようだと、
;   「いにしえの　しじんたちは
;   かたりました。
;   「このよるを　いわい　せいだいな
;   うでくらべが　ひらかれます。
;   「これが　ほしふりの　かくとう
;   たいかいです。
; --------------------------------------------------------------------------
Bank66_Msg46:                               ; $5167  (file $109167)
    db $EB                         ; $5167  ▶ new page
    db $9F                         ; $5168  box tag
    db $96                         ; $5169  end name/box tag
    db $2D,$2D,$52,$27,$43,$2F,$33 ; $516A  こころえました
    db $8F                         ; $5171  。
    db $EF,$EE                     ; $5172  newline
    db $FA                         ; $5174  wait-for-button
    db $F7                         ; $5175  clear page
    db $EF,$EE                     ; $5176  newline
    db $F3                         ; $5178  open text box
    db $9F                         ; $5179  box tag
    db $96                         ; $517A  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3E; $517B  ほしふりのよるは
    db $90                         ; $5183  　(space)
    db $04,$07                     ; $5184  «insert number»
    db $33,$3F,$8D,$3D             ; $5186  たひ゛の = たびの
    db $EF,$EE                     ; $518A  newline
    db $90,$90                     ; $518C  　　(indent)
    db $43,$55,$2C,$8D,$35,$3D,$3D,$34; $518E  まんけ゛つののち = まんげつののち
    db $90                         ; $5196  　(space)
    db $48,$36,$37,$2A,$43,$30     ; $5197  やってきます
    db $8F                         ; $519D  。
    db $FA                         ; $519E  wait-for-button
    db $F7                         ; $519F  clear page
    db $EF,$EE                     ; $51A0  newline
    db $9F                         ; $51A2  box tag
    db $96                         ; $51A3  end name/box tag
    db $2D,$3D,$4C,$50,$3A,$3E     ; $51A4  このよるには
    db $90                         ; $51AA  　(space)
    db $32,$51,$3E,$47,$26         ; $51AB  それはもう
    db $EF,$EE                     ; $51B0  newline
    db $90,$90                     ; $51B2  　　(indent)
    db $33,$2B,$2E,$55,$3D         ; $51B4  たくさんの
    db $90                         ; $51B9  　(space)
    db $42,$2F,$33,$34,$29,$8D     ; $51BA  ほしたちか゛ = ほしたちが
    db $A4                         ; $51C0  、
    db $FA                         ; $51C1  wait-for-button
    db $F7                         ; $51C2  clear page
    db $EF,$EE                     ; $51C3  newline
    db $9F                         ; $51C5  box tag
    db $96                         ; $51C6  end name/box tag
    db $35,$2A,$8D,$29,$4E,$35,$2A,$8D,$3A; $51C7  つき゛からつき゛に = つぎからつぎに
    db $90                         ; $51D0  　(space)
    db $40,$36,$37,$2A,$43,$30     ; $51D1  ふってきます
    db $8F                         ; $51D7  。
    db $EF,$EE                     ; $51D8  newline
    db $FA                         ; $51DA  wait-for-button
    db $F7                         ; $51DB  clear page
    db $EF,$EE                     ; $51DC  newline
    db $F3                         ; $51DE  open text box
    db $9F                         ; $51DF  box tag
    db $96                         ; $51E0  end name/box tag
    db $2D,$3D,$42,$2F,$3D,$29,$29,$8D,$48,$2A,$54; $51E1  このほしのかか゛やきを = このほしのかがやきを
    db $90                         ; $51EC  　(space)
    db $33,$38,$27,$37             ; $51ED  たとえて
    db $EF,$EE                     ; $51F1  newline
    db $90,$90                     ; $51F3  　　(indent)
    db $25,$3D,$34,$3D             ; $51F5  いのちの
    db $90                         ; $51F9  　(space)
    db $29,$29,$8D,$48,$2A,$3D,$4C,$26,$33,$8D,$38; $51FA  かか゛やきのようた゛と = かがやきのようだと
    db $A4                         ; $5205  、
    db $FA                         ; $5206  wait-for-button
    db $F7                         ; $5207  clear page
    db $EF,$EE                     ; $5208  newline
    db $9F                         ; $520A  box tag
    db $96                         ; $520B  end name/box tag
    db $25,$3A,$2F,$27,$3D         ; $520C  いにしえの
    db $90                         ; $5211  　(space)
    db $2F,$2F,$8D,$55,$33,$34,$3E ; $5212  しし゛んたちは = しじんたちは
    db $EF,$EE                     ; $5219  newline
    db $90,$90                     ; $521B  　　(indent)
    db $29,$33,$4F,$43,$2F,$33     ; $521D  かたりました
    db $8F                         ; $5223  。
    db $FA                         ; $5224  wait-for-button
    db $F7                         ; $5225  clear page
    db $EF,$EE                     ; $5226  newline
    db $9F                         ; $5228  box tag
    db $96                         ; $5229  end name/box tag
    db $2D,$3D,$4C,$50,$54         ; $522A  このよるを
    db $90                         ; $522F  　(space)
    db $25,$53,$25                 ; $5230  いわい
    db $90                         ; $5233  　(space)
    db $31,$25,$33,$8D,$25,$39     ; $5234  せいた゛いな = せいだいな
    db $EF,$EE                     ; $523A  newline
    db $90,$90                     ; $523C  　　(indent)
    db $26,$37,$8D,$2B,$4E,$41,$8D,$29,$8D; $523E  うて゛くらへ゛か゛ = うでくらべが
    db $90                         ; $5247  　(space)
    db $3F,$4E,$29,$51,$43,$30     ; $5248  ひらかれます
    db $8F                         ; $524E  。
    db $FA                         ; $524F  wait-for-button
    db $F7                         ; $5250  clear page
    db $EF,$EE                     ; $5251  newline
    db $9F                         ; $5253  box tag
    db $96                         ; $5254  end name/box tag
    db $2D,$51,$29,$8D             ; $5255  これか゛ = これが
    db $90                         ; $5259  　(space)
    db $42,$2F,$40,$4F,$3D         ; $525A  ほしふりの
    db $90                         ; $525F  　(space)
    db $29,$2B,$38,$26             ; $5260  かくとう
    db $EF,$EE                     ; $5264  newline
    db $90,$90                     ; $5266  　　(indent)
    db $33,$25,$29,$25,$37,$8D,$30 ; $5268  たいかいて゛す = たいかいです
    db $8F                         ; $526F  。
    db $F7                         ; $5270  clear page
    db $F0                         ; $5271  end of message


; --------------------------------------------------------------------------
; Message #47 ($5272)
;   「ほしふりのよるに　たいかいは
;   おこなわれる！
;   「くにの　だいひょうに　えらばれた
;   マスターたちが　たたかい、
;   「さいきょうのモンスター
;   マスターを　めざすのさ。
; --------------------------------------------------------------------------
Bank66_Msg47:                               ; $5272  (file $109272)
    db $EB                         ; $5272  ▶ new page
    db $9F                         ; $5273  box tag
    db $96                         ; $5274  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A; $5275  ほしふりのよるに
    db $90                         ; $527D  　(space)
    db $33,$25,$29,$25,$3E         ; $527E  たいかいは
    db $EF,$EE                     ; $5283  newline
    db $90,$90                     ; $5285  　　(indent)
    db $28,$2D,$39,$53,$51,$50     ; $5287  おこなわれる
    db $99                         ; $528D  ！
    db $FA                         ; $528E  wait-for-button
    db $F7                         ; $528F  clear page
    db $EF,$EE                     ; $5290  newline
    db $9F                         ; $5292  box tag
    db $96                         ; $5293  end name/box tag
    db $2B,$3A,$3D                 ; $5294  くにの
    db $90                         ; $5297  　(space)
    db $33,$8D,$25,$3F,$4D,$26,$3A ; $5298  た゛いひょうに = だいひょうに
    db $90                         ; $529F  　(space)
    db $27,$4E,$3E,$8D,$51,$33     ; $52A0  えらは゛れた = えらばれた
    db $EF,$EE                     ; $52A6  newline
    db $90,$90                     ; $52A8  　　(indent)
    db $7A,$67,$6A,$9C,$33,$34,$29,$8D; $52AA  マスターたちか゛ = マスターたちが
    db $90                         ; $52B2  　(space)
    db $33,$33,$29,$25             ; $52B3  たたかい
    db $A4                         ; $52B7  、
    db $FA                         ; $52B8  wait-for-button
    db $F7                         ; $52B9  clear page
    db $EF,$EE                     ; $52BA  newline
    db $9F                         ; $52BC  box tag
    db $96                         ; $52BD  end name/box tag
    db $2E,$25,$2A,$4D,$26,$3D,$7E,$8C,$67,$6A,$9C; $52BE  さいきょうのモンスター
    db $EF,$EE                     ; $52C9  newline
    db $90,$90                     ; $52CB  　　(indent)
    db $7A,$67,$6A,$9C,$54         ; $52CD  マスターを
    db $90                         ; $52D2  　(space)
    db $46,$2E,$8D,$30,$3D,$2E     ; $52D3  めさ゛すのさ = めざすのさ
    db $8F                         ; $52D9  。
    db $F7                         ; $52DA  clear page
    db $F0                         ; $52DB  end of message


; --------------------------------------------------------------------------
; Message #48 ($52DC)
;   「ぼくじょうの　プリォは
;   ドジですが　とてもいいやつです。
;   EN: A townsperson: "Prio at the ranch is a klutz but a good guy."
; --------------------------------------------------------------------------
Bank66_Msg48:                               ; $52DC  (file $1092DC)
    db $EA                         ; $52DC  ▶ new page
    db $9F                         ; $52DD  box tag
    db $96                         ; $52DE  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3D; $52DF  ほ゛くし゛ょうの = ぼくじょうの
    db $90                         ; $52E7  　(space)
    db $77,$8E,$86,$5E,$3E         ; $52E8  フ゜リォは = プリォは
    db $EF,$EE                     ; $52ED  newline
    db $90,$90                     ; $52EF  　　(indent)
    db $6F,$8D,$66,$8D,$37,$8D,$30,$29,$8D; $52F1  ト゛シ゛て゛すか゛ = ドジですが
    db $90                         ; $52FA  　(space)
    db $38,$37,$47,$25,$25,$48,$35,$37,$8D,$30; $52FB  とてもいいやつて゛す = とてもいいやつです
    db $8F                         ; $5305  。
    db $F7                         ; $5306  clear page
    db $F0                         ; $5307  end of message


; --------------------------------------------------------------------------
; Message #49 ($5308)
;   「うえに　あがれば
;   モンスターぼくじょうです。
;   「ぼくじょうにいる　プリォは
;   まものの　せわを　しています。
; --------------------------------------------------------------------------
Bank66_Msg49:                               ; $5308  (file $109308)
    db $EA                         ; $5308  ▶ new page
    db $9F                         ; $5309  box tag
    db $96                         ; $530A  end name/box tag
    db $26,$27,$3A                 ; $530B  うえに
    db $90                         ; $530E  　(space)
    db $24,$29,$8D,$51,$3E,$8D     ; $530F  あか゛れは゛ = あがれば
    db $EF,$EE                     ; $5315  newline
    db $90,$90                     ; $5317  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$42,$8D,$2B,$2F,$8D,$4D,$26,$37,$8D,$30; $5319  モンスターほ゛くし゛ょうて゛す = モンスターぼくじょうです
    db $8F                         ; $5328  。
    db $FA                         ; $5329  wait-for-button
    db $F7                         ; $532A  clear page
    db $EF,$EE                     ; $532B  newline
    db $9F                         ; $532D  box tag
    db $96                         ; $532E  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A,$25,$50; $532F  ほ゛くし゛ょうにいる = ぼくじょうにいる
    db $90                         ; $5339  　(space)
    db $77,$8E,$86,$5E,$3E         ; $533A  フ゜リォは = プリォは
    db $EF,$EE                     ; $533F  newline
    db $90,$90                     ; $5341  　　(indent)
    db $43,$47,$3D,$3D             ; $5343  まものの
    db $90                         ; $5347  　(space)
    db $31,$53,$54                 ; $5348  せわを
    db $90                         ; $534B  　(space)
    db $2F,$37,$25,$43,$30         ; $534C  しています
    db $8F                         ; $5351  。
    db $F7                         ; $5352  clear page
    db $F0                         ; $5353  end of message


; --------------------------------------------------------------------------
; Message #50 ($5354)
;   「わたぼうは　そしつあるマスターを
;   どこかから　つれてくるんじゃ。
;   「ほう！　さらわれた　ねえさんと
;   あうために　ゆうしょうを、。
;   「おぬしのねえさんは　このせかいの
;   どこかにきっと　いるじゃろうて！
; --------------------------------------------------------------------------
Bank66_Msg50:                               ; $5354  (file $109354)
    db $EA                         ; $5354  ▶ new page
    db $9F                         ; $5355  box tag
    db $96                         ; $5356  end name/box tag
    db $53,$33,$42,$8D,$26,$3E     ; $5357  わたほ゛うは = わたぼうは
    db $90                         ; $535D  　(space)
    db $32,$2F,$35,$24,$50,$7A,$67,$6A,$9C,$54; $535E  そしつあるマスターを
    db $EF,$EE                     ; $5368  newline
    db $90,$90                     ; $536A  　　(indent)
    db $38,$8D,$2D,$29,$29,$4E     ; $536C  と゛こかから = どこかから
    db $90                         ; $5372  　(space)
    db $35,$51,$37,$2B,$50,$55,$2F,$8D,$49; $5373  つれてくるんし゛ゃ = つれてくるんじゃ
    db $8F                         ; $537C  。
    db $FA                         ; $537D  wait-for-button
    db $F7                         ; $537E  clear page
    db $EF,$EE                     ; $537F  newline
    db $9F                         ; $5381  box tag
    db $96                         ; $5382  end name/box tag
    db $42,$26                     ; $5383  ほう
    db $99                         ; $5385  ！
    db $90                         ; $5386  　(space)
    db $2E,$4E,$53,$51,$33         ; $5387  さらわれた
    db $90                         ; $538C  　(space)
    db $3C,$27,$2E,$55,$38         ; $538D  ねえさんと
    db $EF,$EE                     ; $5392  newline
    db $90,$90                     ; $5394  　　(indent)
    db $24,$26,$33,$46,$3A         ; $5396  あうために
    db $90                         ; $539B  　(space)
    db $4A,$26,$2F,$4D,$26,$54     ; $539C  ゆうしょうを
    db $A4                         ; $53A2  、
    db $8F                         ; $53A3  。
    db $FA                         ; $53A4  wait-for-button
    db $F7                         ; $53A5  clear page
    db $EF,$EE                     ; $53A6  newline
    db $9F                         ; $53A8  box tag
    db $96                         ; $53A9  end name/box tag
    db $28,$3B,$2F,$3D,$3C,$27,$2E,$55,$3E; $53AA  おぬしのねえさんは
    db $90                         ; $53B3  　(space)
    db $2D,$3D,$31,$29,$25,$3D     ; $53B4  このせかいの
    db $EF,$EE                     ; $53BA  newline
    db $90,$90                     ; $53BC  　　(indent)
    db $38,$8D,$2D,$29,$3A,$2A,$36,$38; $53BE  と゛こかにきっと = どこかにきっと
    db $90                         ; $53C6  　(space)
    db $25,$50,$2F,$8D,$49,$52,$26,$37; $53C7  いるし゛ゃろうて = いるじゃろうて
    db $99                         ; $53CF  ！
    db $F7                         ; $53D0  clear page
    db $F0                         ; $53D1  end of message


; --------------------------------------------------------------------------
; Message #51 ($53D2)
;   「どこかに　おにく
;   おちてないかな？
; --------------------------------------------------------------------------
Bank66_Msg51:                               ; $53D2  (file $1093D2)
    db $EA                         ; $53D2  ▶ new page
    db $9F                         ; $53D3  box tag
    db $96                         ; $53D4  end name/box tag
    db $38,$8D,$2D,$29,$3A         ; $53D5  と゛こかに = どこかに
    db $90                         ; $53DA  　(space)
    db $28,$3A,$2B                 ; $53DB  おにく
    db $EF,$EE                     ; $53DE  newline
    db $90,$90                     ; $53E0  　　(indent)
    db $28,$34,$37,$39,$25,$29,$39 ; $53E2  おちてないかな
    db $98                         ; $53E9  ？
    db $F7                         ; $53EA  clear page
    db $F0                         ; $53EB  end of message


; --------------------------------------------------------------------------
; Message #52 ($53EC)
;   〈テリー〉は　たてふだを　よんだ。
;   「きけん　はやまるな。
;   そのゆうきで　がんばりましょう。
; --------------------------------------------------------------------------
Bank66_Msg52:                               ; $53EC  (file $1093EC)
    db $F6                         ; $53EC  «insert hero name» (テリー)
    db $3E                         ; $53ED  は
    db $90                         ; $53EE  　(space)
    db $33,$37,$40,$33,$8D,$54     ; $53EF  たてふた゛を = たてふだを
    db $90                         ; $53F5  　(space)
    db $4C,$55,$33,$8D             ; $53F6  よんた゛ = よんだ
    db $8F                         ; $53FA  。
    db $EF,$EE                     ; $53FB  newline
    db $FA                         ; $53FD  wait-for-button
    db $F7                         ; $53FE  clear page
    db $EF,$EE                     ; $53FF  newline
    db $F3                         ; $5401  open text box
    db $96                         ; $5402  end name/box tag
    db $2A,$2C,$55                 ; $5403  きけん
    db $90                         ; $5406  　(space)
    db $3E,$48,$43,$50,$39         ; $5407  はやまるな
    db $8F                         ; $540C  。
    db $EF,$EE                     ; $540D  newline
    db $90                         ; $540F  　(space)
    db $32,$3D,$4A,$26,$2A,$37,$8D ; $5410  そのゆうきて゛ = そのゆうきで
    db $90                         ; $5417  　(space)
    db $29,$8D,$55,$3E,$8D,$4F,$43,$2F,$4D,$26; $5418  か゛んは゛りましょう = がんばりましょう
    db $8F                         ; $5422  。
    db $F7                         ; $5423  clear page
    db $F0                         ; $5424  end of message


; --------------------------------------------------------------------------
; Message #53 ($5425)
;   「だめです！　したに　おちたら
;   いたいですよ！
; --------------------------------------------------------------------------
Bank66_Msg53:                               ; $5425  (file $109425)
    db $EA                         ; $5425  ▶ new page
    db $9F                         ; $5426  box tag
    db $96                         ; $5427  end name/box tag
    db $33,$8D,$46,$37,$8D,$30     ; $5428  た゛めて゛す = だめです
    db $99                         ; $542E  ！
    db $90                         ; $542F  　(space)
    db $2F,$33,$3A                 ; $5430  したに
    db $90                         ; $5433  　(space)
    db $28,$34,$33,$4E             ; $5434  おちたら
    db $EF,$EE                     ; $5438  newline
    db $90,$90                     ; $543A  　　(indent)
    db $25,$33,$25,$37,$8D,$30,$4C ; $543C  いたいて゛すよ = いたいですよ
    db $99                         ; $5443  ！
    db $F7                         ; $5444  clear page
    db $F0                         ; $5445  end of message


; --------------------------------------------------------------------------
; Message #54 ($5446)
;   「この　あなが　いまいましい！
;   「おお　わが　いとしのリップスよ！
;   「こんなに　ちかいのに
;   きみに　ふれられないとは、、。
; --------------------------------------------------------------------------
Bank66_Msg54:                               ; $5446  (file $109446)
    db $EA                         ; $5446  ▶ new page
    db $9F                         ; $5447  box tag
    db $96                         ; $5448  end name/box tag
    db $2D,$3D                     ; $5449  この
    db $90                         ; $544B  　(space)
    db $24,$39,$29,$8D             ; $544C  あなか゛ = あなが
    db $90                         ; $5450  　(space)
    db $25,$43,$25,$43,$2F,$25     ; $5451  いまいましい
    db $99                         ; $5457  ！
    db $EF,$EE                     ; $5458  newline
    db $FA                         ; $545A  wait-for-button
    db $F7                         ; $545B  clear page
    db $EF,$EE                     ; $545C  newline
    db $F3                         ; $545E  open text box
    db $9F                         ; $545F  box tag
    db $96                         ; $5460  end name/box tag
    db $28,$28                     ; $5461  おお
    db $90                         ; $5463  　(space)
    db $53,$29,$8D                 ; $5464  わか゛ = わが
    db $90                         ; $5467  　(space)
    db $25,$38,$2F,$3D,$86,$6D,$77,$8E,$67,$4C; $5468  いとしのリッフ゜スよ = いとしのリップスよ
    db $99                         ; $5472  ！
    db $EF,$EE                     ; $5473  newline
    db $FA                         ; $5475  wait-for-button
    db $F7                         ; $5476  clear page
    db $EF,$EE                     ; $5477  newline
    db $F3                         ; $5479  open text box
    db $9F                         ; $547A  box tag
    db $96                         ; $547B  end name/box tag
    db $2D,$55,$39,$3A             ; $547C  こんなに
    db $90                         ; $5480  　(space)
    db $34,$29,$25,$3D,$3A         ; $5481  ちかいのに
    db $EF,$EE                     ; $5486  newline
    db $90,$90                     ; $5488  　　(indent)
    db $2A,$44,$3A                 ; $548A  きみに
    db $90                         ; $548D  　(space)
    db $40,$51,$4E,$51,$39,$25,$38,$3E; $548E  ふれられないとは
    db $A4                         ; $5496  、
    db $A4                         ; $5497  、
    db $8F                         ; $5498  。
    db $F7                         ; $5499  clear page
    db $F0                         ; $549A  end of message


; --------------------------------------------------------------------------
; Message #55 ($549B)
;   〈テリー〉は　たてふだを　よんだ。
;   「タィジャが　そだつとき
;   おおきな　しんどうが　おこる。
;   「このあなは　タィジャの
;   せいちょうのあかし。
;   「いぜんの　しんどうで
;   あなが　あきましたとさ。
; --------------------------------------------------------------------------
Bank66_Msg55:                               ; $549B  (file $10949B)
    db $F6                         ; $549B  «insert hero name» (テリー)
    db $3E                         ; $549C  は
    db $90                         ; $549D  　(space)
    db $33,$37,$40,$33,$8D,$54     ; $549E  たてふた゛を = たてふだを
    db $90                         ; $54A4  　(space)
    db $4C,$55,$33,$8D             ; $54A5  よんた゛ = よんだ
    db $8F                         ; $54A9  。
    db $EF,$EE                     ; $54AA  newline
    db $FA                         ; $54AC  wait-for-button
    db $F7                         ; $54AD  clear page
    db $EF,$EE                     ; $54AE  newline
    db $F3                         ; $54B0  open text box
    db $96                         ; $54B1  end name/box tag
    db $6A,$58,$66,$8D,$82,$29,$8D ; $54B2  タィシ゛ャか゛ = タィジャが
    db $90                         ; $54B9  　(space)
    db $32,$33,$8D,$35,$38,$2A     ; $54BA  そた゛つとき = そだつとき
    db $EF,$EE                     ; $54C0  newline
    db $90                         ; $54C2  　(space)
    db $28,$28,$2A,$39             ; $54C3  おおきな
    db $90                         ; $54C7  　(space)
    db $2F,$55,$38,$8D,$26,$29,$8D ; $54C8  しんと゛うか゛ = しんどうが
    db $90                         ; $54CF  　(space)
    db $28,$2D,$50                 ; $54D0  おこる
    db $8F                         ; $54D3  。
    db $FA                         ; $54D4  wait-for-button
    db $F7                         ; $54D5  clear page
    db $EF,$EE                     ; $54D6  newline
    db $96                         ; $54D8  end name/box tag
    db $2D,$3D,$24,$39,$3E         ; $54D9  このあなは
    db $90                         ; $54DE  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $54DF  タィシ゛ャの = タィジャの
    db $EF,$EE                     ; $54E5  newline
    db $90                         ; $54E7  　(space)
    db $31,$25,$34,$4D,$26,$3D,$24,$29,$2F; $54E8  せいちょうのあかし
    db $8F                         ; $54F1  。
    db $FA                         ; $54F2  wait-for-button
    db $F7                         ; $54F3  clear page
    db $EF,$EE                     ; $54F4  newline
    db $96                         ; $54F6  end name/box tag
    db $25,$31,$8D,$55,$3D         ; $54F7  いせ゛んの = いぜんの
    db $90                         ; $54FC  　(space)
    db $2F,$55,$38,$8D,$26,$37,$8D ; $54FD  しんと゛うて゛ = しんどうで
    db $EF,$EE                     ; $5504  newline
    db $90                         ; $5506  　(space)
    db $24,$39,$29,$8D             ; $5507  あなか゛ = あなが
    db $90                         ; $550B  　(space)
    db $24,$2A,$43,$2F,$33,$38,$2E ; $550C  あきましたとさ
    db $8F                         ; $5513  。
    db $F7                         ; $5514  clear page
    db $F0                         ; $5515  end of message


; --------------------------------------------------------------------------
; Message #56 ($5516)
;   「プリォが　まものを
;   にがしちまったんだぜ。
;   EN: Gossip: "Prio let the monsters escape."
; --------------------------------------------------------------------------
Bank66_Msg56:                               ; $5516  (file $109516)
    db $EA                         ; $5516  ▶ new page
    db $9F                         ; $5517  box tag
    db $96                         ; $5518  end name/box tag
    db $77,$8E,$86,$5E,$29,$8D     ; $5519  フ゜リォか゛ = プリォが
    db $90                         ; $551F  　(space)
    db $43,$47,$3D,$54             ; $5520  まものを
    db $EF,$EE                     ; $5524  newline
    db $90,$90                     ; $5526  　　(indent)
    db $3A,$29,$8D,$2F,$34,$43,$36,$33,$55,$33,$8D,$31,$8D; $5528  にか゛しちまったんた゛せ゛ = にがしちまったんだぜ
    db $8F                         ; $5535  。
    db $F7                         ; $5536  clear page
    db $F0                         ; $5537  end of message


; --------------------------------------------------------------------------
; Message #57 ($5538)
;   「やあ！　モンスターマスターくん。
;   ここから　なにが　つれるかな？
;   「わしが　つったものを　そこの
;   ツボに　いれておくから、
;   「ときどき　のぞきにくると
;   いいだろう。
; --------------------------------------------------------------------------
Bank66_Msg57:                               ; $5538  (file $109538)
    db $EA                         ; $5538  ▶ new page
    db $9F                         ; $5539  box tag
    db $96                         ; $553A  end name/box tag
    db $48,$24                     ; $553B  やあ
    db $99                         ; $553D  ！
    db $90                         ; $553E  　(space)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$2B,$55; $553F  モンスターマスターくん
    db $8F                         ; $554A  。
    db $EF,$EE                     ; $554B  newline
    db $90,$90                     ; $554D  　　(indent)
    db $2D,$2D,$29,$4E             ; $554F  ここから
    db $90                         ; $5553  　(space)
    db $39,$3A,$29,$8D             ; $5554  なにか゛ = なにが
    db $90                         ; $5558  　(space)
    db $35,$51,$50,$29,$39         ; $5559  つれるかな
    db $98                         ; $555E  ？
    db $FA                         ; $555F  wait-for-button
    db $F7                         ; $5560  clear page
    db $EF,$EE                     ; $5561  newline
    db $9F                         ; $5563  box tag
    db $96                         ; $5564  end name/box tag
    db $53,$2F,$29,$8D             ; $5565  わしか゛ = わしが
    db $90                         ; $5569  　(space)
    db $35,$36,$33,$47,$3D,$54     ; $556A  つったものを
    db $90                         ; $5570  　(space)
    db $32,$2D,$3D                 ; $5571  そこの
    db $EF,$EE                     ; $5574  newline
    db $90,$90                     ; $5576  　　(indent)
    db $6C,$79,$8D,$3A             ; $5578  ツホ゛に = ツボに
    db $90                         ; $557C  　(space)
    db $25,$51,$37,$28,$2B,$29,$4E ; $557D  いれておくから
    db $A4                         ; $5584  、
    db $FA                         ; $5585  wait-for-button
    db $F7                         ; $5586  clear page
    db $EF,$EE                     ; $5587  newline
    db $9F                         ; $5589  box tag
    db $96                         ; $558A  end name/box tag
    db $38,$2A,$38,$8D,$2A         ; $558B  ときと゛き = ときどき
    db $90                         ; $5590  　(space)
    db $3D,$32,$8D,$2A,$3A,$2B,$50,$38; $5591  のそ゛きにくると = のぞきにくると
    db $EF,$EE                     ; $5599  newline
    db $90,$90                     ; $559B  　　(indent)
    db $25,$25,$33,$8D,$52,$26     ; $559D  いいた゛ろう = いいだろう
    db $8F                         ; $55A3  。
    db $F7                         ; $55A4  clear page
    db $F0                         ; $55A5  end of message


; --------------------------------------------------------------------------
; Message #58 ($55A6)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
; --------------------------------------------------------------------------
Bank66_Msg58:                               ; $55A6  (file $1095A6)
    db $F6                         ; $55A6  «insert hero name» (テリー)
    db $3E                         ; $55A7  は
    db $90                         ; $55A8  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $55A9  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $55B0  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $55B2  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $55BA  。
    db $FA                         ; $55BB  wait-for-button
    db $F7                         ; $55BC  clear page
    db $F0                         ; $55BD  end of message


; --------------------------------------------------------------------------
; Message #59 ($55BE)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   なかには　ガラクタが　つまっていた。
; --------------------------------------------------------------------------
Bank66_Msg59:                               ; $55BE  (file $1095BE)
    db $F6                         ; $55BE  «insert hero name» (テリー)
    db $3E                         ; $55BF  は
    db $90                         ; $55C0  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $55C1  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $55C8  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $55CA  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $55D2  。
    db $FA                         ; $55D3  wait-for-button
    db $F7                         ; $55D4  clear page
    db $EF,$EE                     ; $55D5  newline
    db $39,$29,$3A,$3E             ; $55D7  なかには
    db $90                         ; $55DB  　(space)
    db $60,$8D,$85,$62,$6A,$29,$8D ; $55DC  カ゛ラクタか゛ = ガラクタが
    db $90                         ; $55E3  　(space)
    db $35,$43,$36,$37,$25,$33     ; $55E4  つまっていた
    db $8F                         ; $55EA  。
    db $EF,$EE                     ; $55EB  newline
    db $F7                         ; $55ED  clear page
    db $F0                         ; $55EE  end of message


; --------------------------------------------------------------------------
; Message #60 ($55EF)
;   「なんだ　おまえ。　まものを
;   さらいに　きただか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg60:                               ; $55EF  (file $1095EF)
    db $EB                         ; $55EF  ▶ new page
    db $9F                         ; $55F0  box tag
    db $96                         ; $55F1  end name/box tag
    db $39,$55,$33,$8D             ; $55F2  なんた゛ = なんだ
    db $90                         ; $55F6  　(space)
    db $28,$43,$27                 ; $55F7  おまえ
    db $8F                         ; $55FA  。
    db $90                         ; $55FB  　(space)
    db $43,$47,$3D,$54             ; $55FC  まものを
    db $EF,$EE                     ; $5600  newline
    db $90,$90                     ; $5602  　　(indent)
    db $2E,$4E,$25,$3A             ; $5604  さらいに
    db $90                         ; $5608  　(space)
    db $2A,$33,$33,$8D,$29         ; $5609  きたた゛か = きただか
    db $98                         ; $560E  ？
    db $FF                         ; $560F  はい/いいえ
    db $F0                         ; $5610  end of message


; --------------------------------------------------------------------------
; Message #61 ($5611)
;   「さあ　こい。とっちめてやるだ！
;   くんくん　くんくん　、、　！
;   「なんだ　モンスターマスターか。
;   おらは　においで　わかるんだ。
;   「おまえ　いいにおい　しているな。
;   きっと　いいマスターになるぞ！
; --------------------------------------------------------------------------
Bank66_Msg61:                               ; $5611  (file $109611)
    db $EB                         ; $5611  ▶ new page
    db $9F                         ; $5612  box tag
    db $96                         ; $5613  end name/box tag
    db $2E,$24                     ; $5614  さあ
    db $90                         ; $5616  　(space)
    db $2D,$25                     ; $5617  こい
    db $8F                         ; $5619  。
    db $38,$36,$34,$46,$37,$48,$50,$33,$8D; $561A  とっちめてやるた゛ = とっちめてやるだ
    db $99                         ; $5623  ！
    db $EF,$EE                     ; $5624  newline
    db $90,$90                     ; $5626  　　(indent)
    db $2B,$55,$2B,$55             ; $5628  くんくん
    db $90                         ; $562C  　(space)
    db $2B,$55,$2B,$55             ; $562D  くんくん
    db $90                         ; $5631  　(space)
    db $A4                         ; $5632  、
    db $A4                         ; $5633  、
    db $90                         ; $5634  　(space)
    db $99                         ; $5635  ！
    db $FA                         ; $5636  wait-for-button
    db $F7                         ; $5637  clear page
    db $EF,$EE                     ; $5638  newline
    db $9F                         ; $563A  box tag
    db $96                         ; $563B  end name/box tag
    db $39,$55,$33,$8D             ; $563C  なんた゛ = なんだ
    db $90                         ; $5640  　(space)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$29; $5641  モンスターマスターか
    db $8F                         ; $564B  。
    db $EF,$EE                     ; $564C  newline
    db $90,$90                     ; $564E  　　(indent)
    db $28,$4E,$3E                 ; $5650  おらは
    db $90                         ; $5653  　(space)
    db $3A,$28,$25,$37,$8D         ; $5654  において゛ = においで
    db $90                         ; $5659  　(space)
    db $53,$29,$50,$55,$33,$8D     ; $565A  わかるんた゛ = わかるんだ
    db $8F                         ; $5660  。
    db $FA                         ; $5661  wait-for-button
    db $F7                         ; $5662  clear page
    db $EF,$EE                     ; $5663  newline
    db $9F                         ; $5665  box tag
    db $96                         ; $5666  end name/box tag
    db $28,$43,$27                 ; $5667  おまえ
    db $90                         ; $566A  　(space)
    db $25,$25,$3A,$28,$25         ; $566B  いいにおい
    db $90                         ; $5670  　(space)
    db $2F,$37,$25,$50,$39         ; $5671  しているな
    db $8F                         ; $5676  。
    db $EF,$EE                     ; $5677  newline
    db $90,$90                     ; $5679  　　(indent)
    db $2A,$36,$38                 ; $567B  きっと
    db $90                         ; $567E  　(space)
    db $25,$25,$7A,$67,$6A,$9C,$3A,$39,$50,$32,$8D; $567F  いいマスターになるそ゛ = いいマスターになるぞ
    db $99                         ; $568A  ！
    db $FA                         ; $568B  wait-for-button
    db $F7                         ; $568C  clear page
    db $F0                         ; $568D  end of message


; --------------------------------------------------------------------------
; Message #62 ($568E)
;   「そうか。　じゃあ　マスターだな。
;   まものを　もらいにきたんだな。
; --------------------------------------------------------------------------
Bank66_Msg62:                               ; $568E  (file $10968E)
    db $EB                         ; $568E  ▶ new page
    db $9F                         ; $568F  box tag
    db $96                         ; $5690  end name/box tag
    db $32,$26,$29                 ; $5691  そうか
    db $8F                         ; $5694  。
    db $90                         ; $5695  　(space)
    db $2F,$8D,$49,$24             ; $5696  し゛ゃあ = じゃあ
    db $90                         ; $569A  　(space)
    db $7A,$67,$6A,$9C,$33,$8D,$39 ; $569B  マスターた゛な = マスターだな
    db $8F                         ; $56A2  。
    db $EF,$EE                     ; $56A3  newline
    db $90,$90                     ; $56A5  　　(indent)
    db $43,$47,$3D,$54             ; $56A7  まものを
    db $90                         ; $56AB  　(space)
    db $47,$4E,$25,$3A,$2A,$33,$55,$33,$8D,$39; $56AC  もらいにきたんた゛な = もらいにきたんだな
    db $8F                         ; $56B6  。
    db $FA                         ; $56B7  wait-for-button
    db $F7                         ; $56B8  clear page
    db $F0                         ; $56B9  end of message


; --------------------------------------------------------------------------
; Message #63 ($56BA)
;   「おらは　この　ぼくじょうを
;   まかされている　プリォってんだ。
;   プリォ「おうさまから　きいてるだ。
;   さあ　まものを　つれていきな。
;   プリォ「といっても　いま　としとった
;   まもの　いっぴきしかいないだ、。
;   プリォ「せんだいこくおうが　だいじに
;   していた　スラぼうってまものだ。
;   プリォ「まものを　つれていくには
;   「むかえにきた[97]を　えらぶんだ。
; --------------------------------------------------------------------------
Bank66_Msg63:                               ; $56BA  (file $1096BA)
    db $EB                         ; $56BA  ▶ new page
    db $9F                         ; $56BB  box tag
    db $96                         ; $56BC  end name/box tag
    db $28,$4E,$3E                 ; $56BD  おらは
    db $90                         ; $56C0  　(space)
    db $2D,$3D                     ; $56C1  この
    db $90                         ; $56C3  　(space)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$54; $56C4  ほ゛くし゛ょうを = ぼくじょうを
    db $EF,$EE                     ; $56CC  newline
    db $90,$90                     ; $56CE  　　(indent)
    db $43,$29,$2E,$51,$37,$25,$50 ; $56D0  まかされている
    db $90                         ; $56D7  　(space)
    db $77,$8E,$86,$5E,$36,$37,$55,$33,$8D; $56D8  フ゜リォってんた゛ = プリォってんだ
    db $8F                         ; $56E1  。
    db $FA                         ; $56E2  wait-for-button
    db $F7                         ; $56E3  clear page
    db $EF,$EE                     ; $56E4  newline
    db $77,$8E,$86,$5E             ; $56E6  フ゜リォ  (speaker: プリォ)
    db $96                         ; $56EA  end name/box tag
    db $28,$26,$2E,$43,$29,$4E     ; $56EB  おうさまから
    db $90                         ; $56F1  　(space)
    db $2A,$25,$37,$50,$33,$8D     ; $56F2  きいてるた゛ = きいてるだ
    db $8F                         ; $56F8  。
    db $EF,$EE                     ; $56F9  newline
    db $90,$90                     ; $56FB  　　(indent)
    db $2E,$24                     ; $56FD  さあ
    db $90                         ; $56FF  　(space)
    db $43,$47,$3D,$54             ; $5700  まものを
    db $90                         ; $5704  　(space)
    db $35,$51,$37,$25,$2A,$39     ; $5705  つれていきな
    db $8F                         ; $570B  。
    db $FA                         ; $570C  wait-for-button
    db $F7                         ; $570D  clear page
    db $EF,$EE                     ; $570E  newline
    db $77,$8E,$86,$5E             ; $5710  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5714  end name/box tag
    db $38,$25,$36,$37,$47         ; $5715  といっても
    db $90                         ; $571A  　(space)
    db $25,$43                     ; $571B  いま
    db $90                         ; $571D  　(space)
    db $38,$2F,$38,$36,$33         ; $571E  としとった
    db $EF,$EE                     ; $5723  newline
    db $90,$90                     ; $5725  　　(indent)
    db $43,$47,$3D                 ; $5727  まもの
    db $90                         ; $572A  　(space)
    db $25,$36,$3F,$8E,$2A,$2F,$29,$25,$39,$25,$33,$8D; $572B  いっひ゜きしかいないた゛ = いっぴきしかいないだ
    db $A4                         ; $5737  、
    db $8F                         ; $5738  。
    db $FA                         ; $5739  wait-for-button
    db $F7                         ; $573A  clear page
    db $EF,$EE                     ; $573B  newline
    db $77,$8E,$86,$5E             ; $573D  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5741  end name/box tag
    db $31,$55,$33,$8D,$25,$2D,$2B,$28,$26,$29,$8D; $5742  せんた゛いこくおうか゛ = せんだいこくおうが
    db $90                         ; $574D  　(space)
    db $33,$8D,$25,$2F,$8D,$3A     ; $574E  た゛いし゛に = だいじに
    db $EF,$EE                     ; $5754  newline
    db $90,$90                     ; $5756  　　(indent)
    db $2F,$37,$25,$33             ; $5758  していた
    db $90                         ; $575C  　(space)
    db $67,$85,$42,$8D,$26,$36,$37,$43,$47,$3D,$33,$8D; $575D  スラほ゛うってまものた゛ = スラぼうってまものだ
    db $8F                         ; $5769  。
    db $FA                         ; $576A  wait-for-button
    db $F7                         ; $576B  clear page
    db $EF,$EE                     ; $576C  newline
    db $77,$8E,$86,$5E             ; $576E  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5772  end name/box tag
    db $43,$47,$3D,$54             ; $5773  まものを
    db $90                         ; $5777  　(space)
    db $35,$51,$37,$25,$2B,$3A,$3E ; $5778  つれていくには
    db $EF,$EE                     ; $577F  newline
    db $90,$90                     ; $5781  　　(indent)
    db $96                         ; $5783  end name/box tag
    db $45,$29,$27,$3A,$2A,$33     ; $5784  むかえにきた
    db $97                         ; $578A  ctrl $97
    db $54                         ; $578B  を
    db $90                         ; $578C  　(space)
    db $27,$4E,$40,$8D,$55,$33,$8D ; $578D  えらふ゛んた゛ = えらぶんだ
    db $8F                         ; $5794  。
    db $F0                         ; $5795  end of message


; --------------------------------------------------------------------------
; Message #64 ($5796)
;   「ぼく　スラお。スラぼうじいさんの
;   まご　なんだ。
;   スラお「ぼくじょうのこと　しりたい？
;   〔はい/いいえ〕
;   EN: Sula-o introduces himself (grandson of old Sula-bou).
; --------------------------------------------------------------------------
Bank66_Msg64:                               ; $5796  (file $109796)
    db $EB                         ; $5796  ▶ new page
    db $9F                         ; $5797  box tag
    db $96                         ; $5798  end name/box tag
    db $42,$8D,$2B                 ; $5799  ほ゛く = ぼく
    db $90                         ; $579C  　(space)
    db $67,$85,$28                 ; $579D  スラお
    db $8F                         ; $57A0  。
    db $67,$85,$42,$8D,$26,$2F,$8D,$25,$2E,$55,$3D; $57A1  スラほ゛うし゛いさんの = スラぼうじいさんの
    db $EF,$EE                     ; $57AC  newline
    db $90,$90                     ; $57AE  　　(indent)
    db $43,$2D,$8D                 ; $57B0  まこ゛ = まご
    db $90                         ; $57B3  　(space)
    db $39,$55,$33,$8D             ; $57B4  なんた゛ = なんだ
    db $8F                         ; $57B8  。
    db $FA                         ; $57B9  wait-for-button
    db $F7                         ; $57BA  clear page
    db $EF,$EE                     ; $57BB  newline
    db $67,$85,$28                 ; $57BD  スラお  (speaker: スラお)
    db $96                         ; $57C0  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3D,$2D,$38; $57C1  ほ゛くし゛ょうのこと = ぼくじょうのこと
    db $90                         ; $57CB  　(space)
    db $2F,$4F,$33,$25             ; $57CC  しりたい
    db $98                         ; $57D0  ？
    db $EF,$EE                     ; $57D1  newline
    db $FF                         ; $57D3  はい/いいえ
    db $F0                         ; $57D4  end of message


; --------------------------------------------------------------------------
; Message #65 ($57D5)
;   スラお「ここでは　まものとタマゴを
;   〈n〉ひきまで　あずけられるよ。
;   スラお「ぼくじょうに　あずけていても
;   けいけんちは　もらえるんだ。
;   スラお「でも　つれているときより
;   すこししか　もらえないからね。
;   スラお「まものが　いっぱいになったら
;   とうみんさせるといいよ。
;   スラお「とうみんは　いま　あずけてる
;   まものが　ふかいねむりについて、
;   スラお「ぼくじょうに　あたらしく
;   〈n〉ひきまで　あずけられるんだ。
;   スラお「それでも　いっぱいのときは
;   まものと　わかれるしかないよ。
;   スラお「タマゴは　つれてあるくことは
;   できないから　あずけてね！
;   EN: Sula-o's monster-storage tutorial (deposit/EXP/hibernation/eggs).
; --------------------------------------------------------------------------
Bank66_Msg65:                               ; $57D5  (file $1097D5)
    db $EB                         ; $57D5  ▶ new page
    db $67,$85,$28                 ; $57D6  スラお  (speaker: スラお)
    db $96                         ; $57D9  end name/box tag
    db $2D,$2D,$37,$8D,$3E         ; $57DA  ここて゛は = ここでは
    db $90                         ; $57DF  　(space)
    db $43,$47,$3D,$38,$6A,$7A,$64,$8D,$54; $57E0  まものとタマコ゛を = まものとタマゴを
    db $EF,$EE                     ; $57E9  newline
    db $90,$90                     ; $57EB  　　(indent)
    db $01,$09                     ; $57ED  «insert number»
    db $3F,$2A,$43,$37,$8D         ; $57EF  ひきまて゛ = ひきまで
    db $90                         ; $57F4  　(space)
    db $24,$30,$8D,$2C,$4E,$51,$50,$4C; $57F5  あす゛けられるよ = あずけられるよ
    db $8F                         ; $57FD  。
    db $FA                         ; $57FE  wait-for-button
    db $F7                         ; $57FF  clear page
    db $EF,$EE                     ; $5800  newline
    db $67,$85,$28                 ; $5802  スラお  (speaker: スラお)
    db $96                         ; $5805  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $5806  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $580E  　(space)
    db $24,$30,$8D,$2C,$37,$25,$37,$47; $580F  あす゛けていても = あずけていても
    db $EF,$EE                     ; $5817  newline
    db $90,$90                     ; $5819  　　(indent)
    db $2C,$25,$2C,$55,$34,$3E     ; $581B  けいけんちは
    db $90                         ; $5821  　(space)
    db $47,$4E,$27,$50,$55,$33,$8D ; $5822  もらえるんた゛ = もらえるんだ
    db $8F                         ; $5829  。
    db $FA                         ; $582A  wait-for-button
    db $F7                         ; $582B  clear page
    db $EF,$EE                     ; $582C  newline
    db $67,$85,$28                 ; $582E  スラお  (speaker: スラお)
    db $96                         ; $5831  end name/box tag
    db $37,$8D,$47                 ; $5832  て゛も = でも
    db $90                         ; $5835  　(space)
    db $35,$51,$37,$25,$50,$38,$2A,$4C,$4F; $5836  つれているときより
    db $EF,$EE                     ; $583F  newline
    db $90,$90                     ; $5841  　　(indent)
    db $30,$2D,$2F,$2F,$29         ; $5843  すこししか
    db $90                         ; $5848  　(space)
    db $47,$4E,$27,$39,$25,$29,$4E,$3C; $5849  もらえないからね
    db $8F                         ; $5851  。
    db $FA                         ; $5852  wait-for-button
    db $F7                         ; $5853  clear page
    db $EF,$EE                     ; $5854  newline
    db $67,$85,$28                 ; $5856  スラお  (speaker: スラお)
    db $96                         ; $5859  end name/box tag
    db $43,$47,$3D,$29,$8D         ; $585A  まものか゛ = まものが
    db $90                         ; $585F  　(space)
    db $25,$36,$3E,$8E,$25,$3A,$39,$36,$33,$4E; $5860  いっは゜いになったら = いっぱいになったら
    db $EF,$EE                     ; $586A  newline
    db $90,$90                     ; $586C  　　(indent)
    db $38,$26,$44,$55,$2E,$31,$50,$38,$25,$25,$4C; $586E  とうみんさせるといいよ
    db $8F                         ; $5879  。
    db $FA                         ; $587A  wait-for-button
    db $F7                         ; $587B  clear page
    db $EF,$EE                     ; $587C  newline
    db $67,$85,$28                 ; $587E  スラお  (speaker: スラお)
    db $96                         ; $5881  end name/box tag
    db $38,$26,$44,$55,$3E         ; $5882  とうみんは
    db $90                         ; $5887  　(space)
    db $25,$43                     ; $5888  いま
    db $90                         ; $588A  　(space)
    db $24,$30,$8D,$2C,$37,$50     ; $588B  あす゛けてる = あずけてる
    db $EF,$EE                     ; $5891  newline
    db $90,$90                     ; $5893  　　(indent)
    db $43,$47,$3D,$29,$8D         ; $5895  まものか゛ = まものが
    db $90                         ; $589A  　(space)
    db $40,$29,$25,$3C,$45,$4F,$3A,$35,$25,$37; $589B  ふかいねむりについて
    db $A4                         ; $58A5  、
    db $FA                         ; $58A6  wait-for-button
    db $F7                         ; $58A7  clear page
    db $EF,$EE                     ; $58A8  newline
    db $67,$85,$28                 ; $58AA  スラお  (speaker: スラお)
    db $96                         ; $58AD  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $58AE  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $58B6  　(space)
    db $24,$33,$4E,$2F,$2B         ; $58B7  あたらしく
    db $EF,$EE                     ; $58BC  newline
    db $90,$90                     ; $58BE  　　(indent)
    db $01,$09                     ; $58C0  «insert number»
    db $3F,$2A,$43,$37,$8D         ; $58C2  ひきまて゛ = ひきまで
    db $90                         ; $58C7  　(space)
    db $24,$30,$8D,$2C,$4E,$51,$50,$55,$33,$8D; $58C8  あす゛けられるんた゛ = あずけられるんだ
    db $8F                         ; $58D2  。
    db $FA                         ; $58D3  wait-for-button
    db $F7                         ; $58D4  clear page
    db $EF,$EE                     ; $58D5  newline
    db $67,$85,$28                 ; $58D7  スラお  (speaker: スラお)
    db $96                         ; $58DA  end name/box tag
    db $32,$51,$37,$8D,$47         ; $58DB  それて゛も = それでも
    db $90                         ; $58E0  　(space)
    db $25,$36,$3E,$8E,$25,$3D,$38,$2A,$3E; $58E1  いっは゜いのときは = いっぱいのときは
    db $EF,$EE                     ; $58EA  newline
    db $90,$90                     ; $58EC  　　(indent)
    db $43,$47,$3D,$38             ; $58EE  まものと
    db $90                         ; $58F2  　(space)
    db $53,$29,$51,$50,$2F,$29,$39,$25,$4C; $58F3  わかれるしかないよ
    db $8F                         ; $58FC  。
    db $FA                         ; $58FD  wait-for-button
    db $F7                         ; $58FE  clear page
    db $EF,$EE                     ; $58FF  newline
    db $67,$85,$28                 ; $5901  スラお  (speaker: スラお)
    db $96                         ; $5904  end name/box tag
    db $6A,$7A,$64,$8D,$3E         ; $5905  タマコ゛は = タマゴは
    db $90                         ; $590A  　(space)
    db $35,$51,$37,$24,$50,$2B,$2D,$38,$3E; $590B  つれてあるくことは
    db $EF,$EE                     ; $5914  newline
    db $90,$90                     ; $5916  　　(indent)
    db $37,$8D,$2A,$39,$25,$29,$4E ; $5918  て゛きないから = できないから
    db $90                         ; $591F  　(space)
    db $24,$30,$8D,$2C,$37,$3C     ; $5920  あす゛けてね = あずけてね
    db $99                         ; $5926  ！
    db $F7                         ; $5927  clear page
    db $F0                         ; $5928  end of message


; --------------------------------------------------------------------------
; Message #66 ($5929)
;   スラお「つよい　まものを
;   そだててね。
;   EN: Sula-o: "Raise some strong monsters!"
; --------------------------------------------------------------------------
Bank66_Msg66:                               ; $5929  (file $109929)
    db $EB                         ; $5929  ▶ new page
    db $67,$85,$28                 ; $592A  スラお  (speaker: スラお)
    db $96                         ; $592D  end name/box tag
    db $35,$4C,$25                 ; $592E  つよい
    db $90                         ; $5931  　(space)
    db $43,$47,$3D,$54             ; $5932  まものを
    db $EF,$EE                     ; $5936  newline
    db $90,$90                     ; $5938  　　(indent)
    db $32,$33,$8D,$37,$37,$3C     ; $593A  そた゛ててね = そだててね
    db $8F                         ; $5940  。
    db $F7                         ; $5941  clear page
    db $F0                         ; $5942  end of message


; --------------------------------------------------------------------------
; Message #67 ($5943)
;   スラお「ぼくじょうのこと　しりたい？
;   〔はい/いいえ〕
;   EN: Sula-o re-asks whether to explain the ranch.
; --------------------------------------------------------------------------
Bank66_Msg67:                               ; $5943  (file $109943)
    db $EB                         ; $5943  ▶ new page
    db $67,$85,$28                 ; $5944  スラお  (speaker: スラお)
    db $96                         ; $5947  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3D,$2D,$38; $5948  ほ゛くし゛ょうのこと = ぼくじょうのこと
    db $90                         ; $5952  　(space)
    db $2F,$4F,$33,$25             ; $5953  しりたい
    db $98                         ; $5957  ？
    db $EF,$EE                     ; $5958  newline
    db $FF                         ; $595A  はい/いいえ
    db $F0                         ; $595B  end of message


; --------------------------------------------------------------------------
; Message #68 ($595C)
;   「ここは　モンスター
;   ぼくじょうだよ。
; --------------------------------------------------------------------------
Bank66_Msg68:                               ; $595C  (file $10995C)
    db $EB                         ; $595C  ▶ new page
    db $9F                         ; $595D  box tag
    db $96                         ; $595E  end name/box tag
    db $2D,$2D,$3E                 ; $595F  ここは
    db $90                         ; $5962  　(space)
    db $7E,$8C,$67,$6A,$9C         ; $5963  モンスター
    db $EF,$EE                     ; $5968  newline
    db $90,$90                     ; $596A  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$33,$8D,$4C; $596C  ほ゛くし゛ょうた゛よ = ぼくじょうだよ
    db $8F                         ; $5976  。
    db $F7                         ; $5977  clear page
    db $F0                         ; $5978  end of message


; --------------------------------------------------------------------------
; Message #69 ($5979)
;   おう「ハッ　そのまものは　せんだい
;   こくおうの、、！
;   おう「〈テリー〉よ！　なぜ　その
;   まものを　もらってくるのじゃ！？
;   おう「え？　こいつしかいなかった？
;   なんと　プリォめ！
;   おう「ほかのまものを　にがして
;   しまいよったな！！
;   おう「プリォ！　プリォ！　だれか
;   プリォを　よんでまいれ！
; --------------------------------------------------------------------------
Bank66_Msg69:                               ; $5979  (file $109979)
    db $EA                         ; $5979  ▶ new page
    db $28,$26                     ; $597A  おう  (speaker: おう)
    db $96                         ; $597C  end name/box tag
    db $75,$6D                     ; $597D  ハッ
    db $90                         ; $597F  　(space)
    db $32,$3D,$43,$47,$3D,$3E     ; $5980  そのまものは
    db $90                         ; $5986  　(space)
    db $31,$55,$33,$8D,$25         ; $5987  せんた゛い = せんだい
    db $EF,$EE                     ; $598C  newline
    db $90,$90                     ; $598E  　　(indent)
    db $2D,$2B,$28,$26,$3D         ; $5990  こくおうの
    db $A4                         ; $5995  、
    db $A4                         ; $5996  、
    db $99                         ; $5997  ！
    db $FA                         ; $5998  wait-for-button
    db $F7                         ; $5999  clear page
    db $EF,$EE                     ; $599A  newline
    db $28,$26                     ; $599C  おう  (speaker: おう)
    db $96                         ; $599E  end name/box tag
    db $F6                         ; $599F  «insert hero name» (テリー)
    db $4C                         ; $59A0  よ
    db $99                         ; $59A1  ！
    db $90                         ; $59A2  　(space)
    db $39,$31,$8D                 ; $59A3  なせ゛ = なぜ
    db $90                         ; $59A6  　(space)
    db $32,$3D                     ; $59A7  その
    db $EF,$EE                     ; $59A9  newline
    db $90,$90                     ; $59AB  　　(indent)
    db $43,$47,$3D,$54             ; $59AD  まものを
    db $90                         ; $59B1  　(space)
    db $47,$4E,$36,$37,$2B,$50,$3D,$2F,$8D,$49; $59B2  もらってくるのし゛ゃ = もらってくるのじゃ
    db $99                         ; $59BC  ！
    db $98                         ; $59BD  ？
    db $FA                         ; $59BE  wait-for-button
    db $F7                         ; $59BF  clear page
    db $EF,$EE                     ; $59C0  newline
    db $28,$26                     ; $59C2  おう  (speaker: おう)
    db $96                         ; $59C4  end name/box tag
    db $27                         ; $59C5  え
    db $98                         ; $59C6  ？
    db $90                         ; $59C7  　(space)
    db $2D,$25,$35,$2F,$29,$25,$39,$29,$36,$33; $59C8  こいつしかいなかった
    db $98                         ; $59D2  ？
    db $EF,$EE                     ; $59D3  newline
    db $90,$90                     ; $59D5  　　(indent)
    db $39,$55,$38                 ; $59D7  なんと
    db $90                         ; $59DA  　(space)
    db $77,$8E,$86,$5E,$46         ; $59DB  フ゜リォめ = プリォめ
    db $99                         ; $59E0  ！
    db $FA                         ; $59E1  wait-for-button
    db $F7                         ; $59E2  clear page
    db $EF,$EE                     ; $59E3  newline
    db $28,$26                     ; $59E5  おう  (speaker: おう)
    db $96                         ; $59E7  end name/box tag
    db $42,$29,$3D,$43,$47,$3D,$54 ; $59E8  ほかのまものを
    db $90                         ; $59EF  　(space)
    db $3A,$29,$8D,$2F,$37         ; $59F0  にか゛して = にがして
    db $EF,$EE                     ; $59F5  newline
    db $90,$90                     ; $59F7  　　(indent)
    db $2F,$43,$25,$4C,$36,$33,$39 ; $59F9  しまいよったな
    db $99                         ; $5A00  ！
    db $99                         ; $5A01  ！
    db $FA                         ; $5A02  wait-for-button
    db $F7                         ; $5A03  clear page
    db $EF,$EE                     ; $5A04  newline
    db $28,$26                     ; $5A06  おう  (speaker: おう)
    db $96                         ; $5A08  end name/box tag
    db $77,$8E,$86,$5E             ; $5A09  フ゜リォ = プリォ
    db $99                         ; $5A0D  ！
    db $90                         ; $5A0E  　(space)
    db $77,$8E,$86,$5E             ; $5A0F  フ゜リォ = プリォ
    db $99                         ; $5A13  ！
    db $90                         ; $5A14  　(space)
    db $33,$8D,$51,$29             ; $5A15  た゛れか = だれか
    db $EF,$EE                     ; $5A19  newline
    db $90,$90                     ; $5A1B  　　(indent)
    db $77,$8E,$86,$5E,$54         ; $5A1D  フ゜リォを = プリォを
    db $90                         ; $5A22  　(space)
    db $4C,$55,$37,$8D,$43,$25,$51 ; $5A23  よんて゛まいれ = よんでまいれ
    db $99                         ; $5A2A  ！
    db $F7                         ; $5A2B  clear page
    db $F0                         ; $5A2C  end of message


; --------------------------------------------------------------------------
; Message #70 ($5A2D)
;   プリォ「ハハー！　おうさま！
;   どうか　おゆるしくだせー！
;   EN: Prio: "Haha! My King! Please forgive me!"
; --------------------------------------------------------------------------
Bank66_Msg70:                               ; $5A2D  (file $109A2D)
    db $EB                         ; $5A2D  ▶ new page
    db $77,$8E,$86,$5E             ; $5A2E  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5A32  end name/box tag
    db $75,$75,$9C                 ; $5A33  ハハー
    db $99                         ; $5A36  ！
    db $90                         ; $5A37  　(space)
    db $28,$26,$2E,$43             ; $5A38  おうさま
    db $99                         ; $5A3C  ！
    db $EF,$EE                     ; $5A3D  newline
    db $90,$90                     ; $5A3F  　　(indent)
    db $38,$8D,$26,$29             ; $5A41  と゛うか = どうか
    db $90                         ; $5A45  　(space)
    db $28,$4A,$50,$2F,$2B,$33,$8D,$31,$9C; $5A46  おゆるしくた゛せー = おゆるしくだせー
    db $99                         ; $5A4F  ！
    db $F7                         ; $5A50  clear page
    db $F0                         ; $5A51  end of message


; --------------------------------------------------------------------------
; Message #71 ($5A52)
;   おう「プリォよ！　ひょっとして
;   そなた　ホィミンもにがしたか！？
;   EN: King: "Prio! Don't tell me you let Hoimin escape too!?"
; --------------------------------------------------------------------------
Bank66_Msg71:                               ; $5A52  (file $109A52)
    db $EA                         ; $5A52  ▶ new page
    db $28,$26                     ; $5A53  おう  (speaker: おう)
    db $96                         ; $5A55  end name/box tag
    db $77,$8E,$86,$5E,$4C         ; $5A56  フ゜リォよ = プリォよ
    db $99                         ; $5A5B  ！
    db $90                         ; $5A5C  　(space)
    db $3F,$4D,$36,$38,$2F,$37     ; $5A5D  ひょっとして
    db $EF,$EE                     ; $5A63  newline
    db $90,$90                     ; $5A65  　　(indent)
    db $32,$39,$33                 ; $5A67  そなた
    db $90                         ; $5A6A  　(space)
    db $79,$58,$7B,$8C,$47,$3A,$29,$8D,$2F,$33,$29; $5A6B  ホィミンもにか゛したか = ホィミンもにがしたか
    db $99                         ; $5A76  ！
    db $98                         ; $5A77  ？
    db $F7                         ; $5A78  clear page
    db $F0                         ; $5A79  end of message


; --------------------------------------------------------------------------
; Message #72 ($5A7A)
;   プリォ「おうさま　おゆるしくだせー！
;   ホィミンも　にげてしまっただ！
;   EN: Prio: "My King, forgive me! Hoimin ran off too!"
; --------------------------------------------------------------------------
Bank66_Msg72:                               ; $5A7A  (file $109A7A)
    db $EB                         ; $5A7A  ▶ new page
    db $77,$8E,$86,$5E             ; $5A7B  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5A7F  end name/box tag
    db $28,$26,$2E,$43             ; $5A80  おうさま
    db $90                         ; $5A84  　(space)
    db $28,$4A,$50,$2F,$2B,$33,$8D,$31,$9C; $5A85  おゆるしくた゛せー = おゆるしくだせー
    db $99                         ; $5A8E  ！
    db $EF,$EE                     ; $5A8F  newline
    db $90,$90                     ; $5A91  　　(indent)
    db $79,$58,$7B,$8C,$47         ; $5A93  ホィミンも
    db $90                         ; $5A98  　(space)
    db $3A,$2C,$8D,$37,$2F,$43,$36,$33,$33,$8D; $5A99  にけ゛てしまったた゛ = にげてしまっただ
    db $99                         ; $5AA3  ！
    db $F7                         ; $5AA4  clear page
    db $F0                         ; $5AA5  end of message


; --------------------------------------------------------------------------
; Message #73 ($5AA6)
;   おう「ええ[92]！　そなた　わしの
;   かわいい　ホィミンを！！
;   おう「ゆるさぬ！　だれか　こやつを
;   ろうごくへ　とじこめよ！！
; --------------------------------------------------------------------------
Bank66_Msg73:                               ; $5AA6  (file $109AA6)
    db $EA                         ; $5AA6  ▶ new page
    db $28,$26                     ; $5AA7  おう  (speaker: おう)
    db $96                         ; $5AA9  end name/box tag
    db $27,$27                     ; $5AAA  ええ
    db $92                         ; $5AAC  ctrl $92
    db $99                         ; $5AAD  ！
    db $90                         ; $5AAE  　(space)
    db $32,$39,$33                 ; $5AAF  そなた
    db $90                         ; $5AB2  　(space)
    db $53,$2F,$3D                 ; $5AB3  わしの
    db $EF,$EE                     ; $5AB6  newline
    db $90,$90                     ; $5AB8  　　(indent)
    db $29,$53,$25,$25             ; $5ABA  かわいい
    db $90                         ; $5ABE  　(space)
    db $79,$58,$7B,$8C,$54         ; $5ABF  ホィミンを
    db $99                         ; $5AC4  ！
    db $99                         ; $5AC5  ！
    db $FA                         ; $5AC6  wait-for-button
    db $F7                         ; $5AC7  clear page
    db $EF,$EE                     ; $5AC8  newline
    db $28,$26                     ; $5ACA  おう  (speaker: おう)
    db $96                         ; $5ACC  end name/box tag
    db $4A,$50,$2E,$3B             ; $5ACD  ゆるさぬ
    db $99                         ; $5AD1  ！
    db $90                         ; $5AD2  　(space)
    db $33,$8D,$51,$29             ; $5AD3  た゛れか = だれか
    db $90                         ; $5AD7  　(space)
    db $2D,$48,$35,$54             ; $5AD8  こやつを
    db $EF,$EE                     ; $5ADC  newline
    db $90,$90                     ; $5ADE  　　(indent)
    db $52,$26,$2D,$8D,$2B,$41     ; $5AE0  ろうこ゛くへ = ろうごくへ
    db $90                         ; $5AE6  　(space)
    db $38,$2F,$8D,$2D,$46,$4C     ; $5AE7  とし゛こめよ = とじこめよ
    db $99                         ; $5AED  ！
    db $99                         ; $5AEE  ！
    db $F7                         ; $5AEF  clear page
    db $F0                         ; $5AF0  end of message


; --------------------------------------------------------------------------
; Message #74 ($5AF1)
;   おう「！　なんじゃ　〈テリー〉よ！？
;   なにか　いうことがあるのか！？
;   おう「なに？　ホィミンを　つかまえて
;   くるから　たすけてやってほしい？
;   おう「なんと　そなた　ホィミンを
;   つかまえてくる　というのだな？
;   おう「、おもしろい。　〈テリー〉よ！
;   やってみるがよい。
; --------------------------------------------------------------------------
Bank66_Msg74:                               ; $5AF1  (file $109AF1)
    db $EA                         ; $5AF1  ▶ new page
    db $28,$26                     ; $5AF2  おう  (speaker: おう)
    db $96                         ; $5AF4  end name/box tag
    db $99                         ; $5AF5  ！
    db $90                         ; $5AF6  　(space)
    db $39,$55,$2F,$8D,$49         ; $5AF7  なんし゛ゃ = なんじゃ
    db $90                         ; $5AFC  　(space)
    db $F6                         ; $5AFD  «insert hero name» (テリー)
    db $4C                         ; $5AFE  よ
    db $99                         ; $5AFF  ！
    db $98                         ; $5B00  ？
    db $EF,$EE                     ; $5B01  newline
    db $90,$90                     ; $5B03  　　(indent)
    db $39,$3A,$29                 ; $5B05  なにか
    db $90                         ; $5B08  　(space)
    db $25,$26,$2D,$38,$29,$8D,$24,$50,$3D,$29; $5B09  いうことか゛あるのか = いうことがあるのか
    db $99                         ; $5B13  ！
    db $98                         ; $5B14  ？
    db $FA                         ; $5B15  wait-for-button
    db $F7                         ; $5B16  clear page
    db $EF,$EE                     ; $5B17  newline
    db $28,$26                     ; $5B19  おう  (speaker: おう)
    db $96                         ; $5B1B  end name/box tag
    db $39,$3A                     ; $5B1C  なに
    db $98                         ; $5B1E  ？
    db $90                         ; $5B1F  　(space)
    db $79,$58,$7B,$8C,$54         ; $5B20  ホィミンを
    db $90                         ; $5B25  　(space)
    db $35,$29,$43,$27,$37         ; $5B26  つかまえて
    db $EF,$EE                     ; $5B2B  newline
    db $90,$90                     ; $5B2D  　　(indent)
    db $2B,$50,$29,$4E             ; $5B2F  くるから
    db $90                         ; $5B33  　(space)
    db $33,$30,$2C,$37,$48,$36,$37,$42,$2F,$25; $5B34  たすけてやってほしい
    db $98                         ; $5B3E  ？
    db $FA                         ; $5B3F  wait-for-button
    db $F7                         ; $5B40  clear page
    db $EF,$EE                     ; $5B41  newline
    db $28,$26                     ; $5B43  おう  (speaker: おう)
    db $96                         ; $5B45  end name/box tag
    db $39,$55,$38                 ; $5B46  なんと
    db $90                         ; $5B49  　(space)
    db $32,$39,$33                 ; $5B4A  そなた
    db $90                         ; $5B4D  　(space)
    db $79,$58,$7B,$8C,$54         ; $5B4E  ホィミンを
    db $EF,$EE                     ; $5B53  newline
    db $90,$90                     ; $5B55  　　(indent)
    db $35,$29,$43,$27,$37,$2B,$50 ; $5B57  つかまえてくる
    db $90                         ; $5B5E  　(space)
    db $38,$25,$26,$3D,$33,$8D,$39 ; $5B5F  というのた゛な = というのだな
    db $98                         ; $5B66  ？
    db $FA                         ; $5B67  wait-for-button
    db $F7                         ; $5B68  clear page
    db $EF,$EE                     ; $5B69  newline
    db $28,$26                     ; $5B6B  おう  (speaker: おう)
    db $96                         ; $5B6D  end name/box tag
    db $A4                         ; $5B6E  、
    db $28,$47,$2F,$52,$25         ; $5B6F  おもしろい
    db $8F                         ; $5B74  。
    db $90                         ; $5B75  　(space)
    db $F6                         ; $5B76  «insert hero name» (テリー)
    db $4C                         ; $5B77  よ
    db $99                         ; $5B78  ！
    db $EF,$EE                     ; $5B79  newline
    db $90,$90                     ; $5B7B  　　(indent)
    db $48,$36,$37,$44,$50,$29,$8D,$4C,$25; $5B7D  やってみるか゛よい = やってみるがよい
    db $8F                         ; $5B86  。
    db $F7                         ; $5B87  clear page
    db $F0                         ; $5B88  end of message


; --------------------------------------------------------------------------
; Message #75 ($5B89)
;   プリォ「おうさま！　ホィミンは
;   たびだちのとびらに　いっただ！
;   EN: Prio: "My King! Hoimin went into the Traveler's Gate!"
; --------------------------------------------------------------------------
Bank66_Msg75:                               ; $5B89  (file $109B89)
    db $EB                         ; $5B89  ▶ new page
    db $77,$8E,$86,$5E             ; $5B8A  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5B8E  end name/box tag
    db $28,$26,$2E,$43             ; $5B8F  おうさま
    db $99                         ; $5B93  ！
    db $90                         ; $5B94  　(space)
    db $79,$58,$7B,$8C,$3E         ; $5B95  ホィミンは
    db $EF,$EE                     ; $5B9A  newline
    db $90,$90                     ; $5B9C  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$38,$3F,$8D,$4E,$3A; $5B9E  たひ゛た゛ちのとひ゛らに = たびだちのとびらに
    db $90                         ; $5BAA  　(space)
    db $25,$36,$33,$33,$8D         ; $5BAB  いったた゛ = いっただ
    db $99                         ; $5BB0  ！
    db $F7                         ; $5BB1  clear page
    db $F0                         ; $5BB2  end of message


; --------------------------------------------------------------------------
; Message #76 ($5BB3)
;   おう「そうか。　では　〈テリー〉よ。
;   たびだちのとびらに　ゆくがよい！
;   おう「みごと　ホィミンを　つれて
;   かえれば　プリォは　ゆるそうぞ！
;   おう「となりのへやの　たからばこは
;   すきに　するがよかろう、。
;   おう「くわしいことは　だいじんに
;   きくのだ。
;   おう「わしは　いそがしいので
;   これで　しつれいする！
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank66_Msg76:                               ; $5BB3  (file $109BB3)
    db $EA                         ; $5BB3  ▶ new page
    db $28,$26                     ; $5BB4  おう  (speaker: おう)
    db $96                         ; $5BB6  end name/box tag
    db $32,$26,$29                 ; $5BB7  そうか
    db $8F                         ; $5BBA  。
    db $90                         ; $5BBB  　(space)
    db $37,$8D,$3E                 ; $5BBC  て゛は = では
    db $90                         ; $5BBF  　(space)
    db $F6                         ; $5BC0  «insert hero name» (テリー)
    db $4C                         ; $5BC1  よ
    db $8F                         ; $5BC2  。
    db $EF,$EE                     ; $5BC3  newline
    db $90,$90                     ; $5BC5  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$38,$3F,$8D,$4E,$3A; $5BC7  たひ゛た゛ちのとひ゛らに = たびだちのとびらに
    db $90                         ; $5BD3  　(space)
    db $4A,$2B,$29,$8D,$4C,$25     ; $5BD4  ゆくか゛よい = ゆくがよい
    db $99                         ; $5BDA  ！
    db $FA                         ; $5BDB  wait-for-button
    db $F7                         ; $5BDC  clear page
    db $EF,$EE                     ; $5BDD  newline
    db $28,$26                     ; $5BDF  おう  (speaker: おう)
    db $96                         ; $5BE1  end name/box tag
    db $44,$2D,$8D,$38             ; $5BE2  みこ゛と = みごと
    db $90                         ; $5BE6  　(space)
    db $79,$58,$7B,$8C,$54         ; $5BE7  ホィミンを
    db $90                         ; $5BEC  　(space)
    db $35,$51,$37                 ; $5BED  つれて
    db $EF,$EE                     ; $5BF0  newline
    db $90,$90                     ; $5BF2  　　(indent)
    db $29,$27,$51,$3E,$8D         ; $5BF4  かえれは゛ = かえれば
    db $90                         ; $5BF9  　(space)
    db $77,$8E,$86,$5E,$3E         ; $5BFA  フ゜リォは = プリォは
    db $90                         ; $5BFF  　(space)
    db $4A,$50,$32,$26,$32,$8D     ; $5C00  ゆるそうそ゛ = ゆるそうぞ
    db $99                         ; $5C06  ！
    db $FA                         ; $5C07  wait-for-button
    db $F7                         ; $5C08  clear page
    db $EF,$EE                     ; $5C09  newline
    db $28,$26                     ; $5C0B  おう  (speaker: おう)
    db $96                         ; $5C0D  end name/box tag
    db $38,$39,$4F,$3D,$41,$48,$3D ; $5C0E  となりのへやの
    db $90                         ; $5C15  　(space)
    db $33,$29,$4E,$3E,$8D,$2D,$3E ; $5C16  たからは゛こは = たからばこは
    db $EF,$EE                     ; $5C1D  newline
    db $90,$90                     ; $5C1F  　　(indent)
    db $30,$2A,$3A                 ; $5C21  すきに
    db $90                         ; $5C24  　(space)
    db $30,$50,$29,$8D,$4C,$29,$52,$26; $5C25  するか゛よかろう = するがよかろう
    db $A4                         ; $5C2D  、
    db $8F                         ; $5C2E  。
    db $FA                         ; $5C2F  wait-for-button
    db $F7                         ; $5C30  clear page
    db $EF,$EE                     ; $5C31  newline
    db $28,$26                     ; $5C33  おう  (speaker: おう)
    db $96                         ; $5C35  end name/box tag
    db $2B,$53,$2F,$25,$2D,$38,$3E ; $5C36  くわしいことは
    db $90                         ; $5C3D  　(space)
    db $33,$8D,$25,$2F,$8D,$55,$3A ; $5C3E  た゛いし゛んに = だいじんに
    db $EF,$EE                     ; $5C45  newline
    db $90,$90                     ; $5C47  　　(indent)
    db $2A,$2B,$3D,$33,$8D         ; $5C49  きくのた゛ = きくのだ
    db $8F                         ; $5C4E  。
    db $FA                         ; $5C4F  wait-for-button
    db $F7                         ; $5C50  clear page
    db $EF,$EE                     ; $5C51  newline
    db $28,$26                     ; $5C53  おう  (speaker: おう)
    db $96                         ; $5C55  end name/box tag
    db $53,$2F,$3E                 ; $5C56  わしは
    db $90                         ; $5C59  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $5C5A  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $5C63  newline
    db $90,$90                     ; $5C65  　　(indent)
    db $2D,$51,$37,$8D             ; $5C67  これて゛ = これで
    db $90                         ; $5C6B  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $5C6C  しつれいする
    db $99                         ; $5C72  ！
    db $FA                         ; $5C73  wait-for-button
    db $F7                         ; $5C74  clear page
    db $EF,$EE                     ; $5C75  newline
    db $28,$26                     ; $5C77  おう  (speaker: おう)
    db $96                         ; $5C79  end name/box tag
    db $58,$69                     ; $5C7A  ィソ
    db $90                         ; $5C7C  　(space)
    db $58,$69                     ; $5C7D  ィソ
    db $A4                         ; $5C7F  、
    db $90                         ; $5C80  　(space)
    db $58,$69                     ; $5C81  ィソ
    db $90                         ; $5C83  　(space)
    db $58,$69                     ; $5C84  ィソ
    db $A4                         ; $5C86  、
    db $A4                         ; $5C87  、
    db $8F                         ; $5C88  。
    db $EF,$EE                     ; $5C89  newline
    db $F7                         ; $5C8B  clear page
    db $F0                         ; $5C8C  end of message


; --------------------------------------------------------------------------
; Message #77 ($5C8D)
;   「おうさまは　たいそう
;   おいかりの　ごようす。
;   「どうか　たびだちのとびらに　いき
;   ホィミンを　つれてきてほしい！
;   「〈テリー〉。　よろしく　たのむぞ！
; --------------------------------------------------------------------------
Bank66_Msg77:                               ; $5C8D  (file $109C8D)
    db $EA                         ; $5C8D  ▶ new page
    db $9F                         ; $5C8E  box tag
    db $96                         ; $5C8F  end name/box tag
    db $28,$26,$2E,$43,$3E         ; $5C90  おうさまは
    db $90                         ; $5C95  　(space)
    db $33,$25,$32,$26             ; $5C96  たいそう
    db $EF,$EE                     ; $5C9A  newline
    db $90,$90                     ; $5C9C  　　(indent)
    db $28,$25,$29,$4F,$3D         ; $5C9E  おいかりの
    db $90                         ; $5CA3  　(space)
    db $2D,$8D,$4C,$26,$30         ; $5CA4  こ゛ようす = ごようす
    db $8F                         ; $5CA9  。
    db $FA                         ; $5CAA  wait-for-button
    db $F7                         ; $5CAB  clear page
    db $EF,$EE                     ; $5CAC  newline
    db $9F                         ; $5CAE  box tag
    db $96                         ; $5CAF  end name/box tag
    db $38,$8D,$26,$29             ; $5CB0  と゛うか = どうか
    db $90                         ; $5CB4  　(space)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$38,$3F,$8D,$4E,$3A; $5CB5  たひ゛た゛ちのとひ゛らに = たびだちのとびらに
    db $90                         ; $5CC1  　(space)
    db $25,$2A                     ; $5CC2  いき
    db $EF,$EE                     ; $5CC4  newline
    db $90,$90                     ; $5CC6  　　(indent)
    db $79,$58,$7B,$8C,$54         ; $5CC8  ホィミンを
    db $90                         ; $5CCD  　(space)
    db $35,$51,$37,$2A,$37,$42,$2F,$25; $5CCE  つれてきてほしい
    db $99                         ; $5CD6  ！
    db $FA                         ; $5CD7  wait-for-button
    db $F7                         ; $5CD8  clear page
    db $EF,$EE                     ; $5CD9  newline
    db $9F                         ; $5CDB  box tag
    db $96                         ; $5CDC  end name/box tag
    db $F6                         ; $5CDD  «insert hero name» (テリー)
    db $8F                         ; $5CDE  。
    db $90                         ; $5CDF  　(space)
    db $4C,$52,$2F,$2B             ; $5CE0  よろしく
    db $90                         ; $5CE4  　(space)
    db $33,$3D,$45,$32,$8D         ; $5CE5  たのむそ゛ = たのむぞ
    db $99                         ; $5CEA  ！
    db $EF,$EE                     ; $5CEB  newline
    db $F7                         ; $5CED  clear page
    db $F0                         ; $5CEE  end of message


; --------------------------------------------------------------------------
; Message #78 ($5CEF)
;   「おお　ゆうかんなる　マスター
;   〈テリー〉に　タィジャのごかごを！
; --------------------------------------------------------------------------
Bank66_Msg78:                               ; $5CEF  (file $109CEF)
    db $EA                         ; $5CEF  ▶ new page
    db $9F                         ; $5CF0  box tag
    db $96                         ; $5CF1  end name/box tag
    db $28,$28                     ; $5CF2  おお
    db $90                         ; $5CF4  　(space)
    db $4A,$26,$29,$55,$39,$50     ; $5CF5  ゆうかんなる
    db $90                         ; $5CFB  　(space)
    db $7A,$67,$6A,$9C             ; $5CFC  マスター
    db $EF,$EE                     ; $5D00  newline
    db $90,$90                     ; $5D02  　　(indent)
    db $F6                         ; $5D04  «insert hero name» (テリー)
    db $3A                         ; $5D05  に
    db $90                         ; $5D06  　(space)
    db $6A,$58,$66,$8D,$82,$3D,$2D,$8D,$29,$2D,$8D,$54; $5D07  タィシ゛ャのこ゛かこ゛を = タィジャのごかごを
    db $99                         ; $5D13  ！
    db $F7                         ; $5D14  clear page
    db $F0                         ; $5D15  end of message


; --------------------------------------------------------------------------
; Message #79 ($5D16)
;   「たびのとびらは　うずまきじょうの
;   ふしぎな　くうかんのこと。
;   「なかにはいると　まかふしぎな
;   いせかいへ　いけるんだ。
;   「こっちのせかいに　やせいの
;   まものは　すんでいない。
;   「まものは　みんな　たびのとびらの
;   むこうに　すんでいるんだ。
; --------------------------------------------------------------------------
Bank66_Msg79:                               ; $5D16  (file $109D16)
    db $EB                         ; $5D16  ▶ new page
    db $9F                         ; $5D17  box tag
    db $96                         ; $5D18  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3E; $5D19  たひ゛のとひ゛らは = たびのとびらは
    db $90                         ; $5D22  　(space)
    db $26,$30,$8D,$43,$2A,$2F,$8D,$4D,$26,$3D; $5D23  うす゛まきし゛ょうの = うずまきじょうの
    db $EF,$EE                     ; $5D2D  newline
    db $90,$90                     ; $5D2F  　　(indent)
    db $40,$2F,$2A,$8D,$39         ; $5D31  ふしき゛な = ふしぎな
    db $90                         ; $5D36  　(space)
    db $2B,$26,$29,$55,$3D,$2D,$38 ; $5D37  くうかんのこと
    db $8F                         ; $5D3E  。
    db $FA                         ; $5D3F  wait-for-button
    db $F7                         ; $5D40  clear page
    db $EF,$EE                     ; $5D41  newline
    db $9F                         ; $5D43  box tag
    db $96                         ; $5D44  end name/box tag
    db $39,$29,$3A,$3E,$25,$50,$38 ; $5D45  なかにはいると
    db $90                         ; $5D4C  　(space)
    db $43,$29,$40,$2F,$2A,$8D,$39 ; $5D4D  まかふしき゛な = まかふしぎな
    db $EF,$EE                     ; $5D54  newline
    db $90,$90                     ; $5D56  　　(indent)
    db $25,$31,$29,$25,$41         ; $5D58  いせかいへ
    db $90                         ; $5D5D  　(space)
    db $25,$2C,$50,$55,$33,$8D     ; $5D5E  いけるんた゛ = いけるんだ
    db $8F                         ; $5D64  。
    db $FA                         ; $5D65  wait-for-button
    db $F7                         ; $5D66  clear page
    db $EF,$EE                     ; $5D67  newline
    db $9F                         ; $5D69  box tag
    db $96                         ; $5D6A  end name/box tag
    db $2D,$36,$34,$3D,$31,$29,$25,$3A; $5D6B  こっちのせかいに
    db $90                         ; $5D73  　(space)
    db $48,$31,$25,$3D             ; $5D74  やせいの
    db $EF,$EE                     ; $5D78  newline
    db $90,$90                     ; $5D7A  　　(indent)
    db $43,$47,$3D,$3E             ; $5D7C  まものは
    db $90                         ; $5D80  　(space)
    db $30,$55,$37,$8D,$25,$39,$25 ; $5D81  すんて゛いない = すんでいない
    db $8F                         ; $5D88  。
    db $FA                         ; $5D89  wait-for-button
    db $F7                         ; $5D8A  clear page
    db $EF,$EE                     ; $5D8B  newline
    db $9F                         ; $5D8D  box tag
    db $96                         ; $5D8E  end name/box tag
    db $43,$47,$3D,$3E             ; $5D8F  まものは
    db $90                         ; $5D93  　(space)
    db $44,$55,$39                 ; $5D94  みんな
    db $90                         ; $5D97  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D; $5D98  たひ゛のとひ゛らの = たびのとびらの
    db $EF,$EE                     ; $5DA1  newline
    db $90,$90                     ; $5DA3  　　(indent)
    db $45,$2D,$26,$3A             ; $5DA5  むこうに
    db $90                         ; $5DA9  　(space)
    db $30,$55,$37,$8D,$25,$50,$55,$33,$8D; $5DAA  すんて゛いるんた゛ = すんでいるんだ
    db $8F                         ; $5DB3  。
    db $F7                         ; $5DB4  clear page
    db $F0                         ; $5DB5  end of message


; --------------------------------------------------------------------------
; Message #80 ($5DB6)
;   プリォ「〈テリー〉！　ごめんよ。
;   おらのために、、。
;   プリォ「そうだ。
;   いいこと　おしえるだ。
;   プリォ「さくせんで　ぼうけんの
;   きろくが　できるだよ！
;   EN: Prio's apology to the hero + a save/Tactics hint.
; --------------------------------------------------------------------------
Bank66_Msg80:                               ; $5DB6  (file $109DB6)
    db $EB                         ; $5DB6  ▶ new page
    db $77,$8E,$86,$5E             ; $5DB7  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5DBB  end name/box tag
    db $F6                         ; $5DBC  «insert hero name» (テリー)
    db $99                         ; $5DBD  ！
    db $90                         ; $5DBE  　(space)
    db $2D,$8D,$46,$55,$4C         ; $5DBF  こ゛めんよ = ごめんよ
    db $8F                         ; $5DC4  。
    db $EF,$EE                     ; $5DC5  newline
    db $90,$90                     ; $5DC7  　　(indent)
    db $28,$4E,$3D,$33,$46,$3A     ; $5DC9  おらのために
    db $A4                         ; $5DCF  、
    db $A4                         ; $5DD0  、
    db $8F                         ; $5DD1  。
    db $FA                         ; $5DD2  wait-for-button
    db $F7                         ; $5DD3  clear page
    db $EF,$EE                     ; $5DD4  newline
    db $77,$8E,$86,$5E             ; $5DD6  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5DDA  end name/box tag
    db $32,$26,$33,$8D             ; $5DDB  そうた゛ = そうだ
    db $8F                         ; $5DDF  。
    db $EF,$EE                     ; $5DE0  newline
    db $90,$90                     ; $5DE2  　　(indent)
    db $25,$25,$2D,$38             ; $5DE4  いいこと
    db $90                         ; $5DE8  　(space)
    db $28,$2F,$27,$50,$33,$8D     ; $5DE9  おしえるた゛ = おしえるだ
    db $8F                         ; $5DEF  。
    db $FA                         ; $5DF0  wait-for-button
    db $F7                         ; $5DF1  clear page
    db $EF,$EE                     ; $5DF2  newline
    db $77,$8E,$86,$5E             ; $5DF4  フ゜リォ  (speaker: プリォ)
    db $96                         ; $5DF8  end name/box tag
    db $2E,$2B,$31,$55,$37,$8D     ; $5DF9  さくせんて゛ = さくせんで
    db $90                         ; $5DFF  　(space)
    db $42,$8D,$26,$2C,$55,$3D     ; $5E00  ほ゛うけんの = ぼうけんの
    db $EF,$EE                     ; $5E06  newline
    db $90,$90                     ; $5E08  　　(indent)
    db $2A,$52,$2B,$29,$8D         ; $5E0A  きろくか゛ = きろくが
    db $90                         ; $5E0F  　(space)
    db $37,$8D,$2A,$50,$33,$8D,$4C ; $5E10  て゛きるた゛よ = できるだよ
    db $99                         ; $5E17  ！
    db $F7                         ; $5E18  clear page
    db $F0                         ; $5E19  end of message


; --------------------------------------------------------------------------
; Message #81 ($5E1A)
;   「このかいだんを　おりると
;   たびのとびらのまに　いけます。
;   EN: Signpost: how to reach the Traveler's Gate room.
; --------------------------------------------------------------------------
Bank66_Msg81:                               ; $5E1A  (file $109E1A)
    db $EA                         ; $5E1A  ▶ new page
    db $9F                         ; $5E1B  box tag
    db $96                         ; $5E1C  end name/box tag
    db $2D,$3D,$29,$25,$33,$8D,$55,$54; $5E1D  このかいた゛んを = このかいだんを
    db $90                         ; $5E25  　(space)
    db $28,$4F,$50,$38             ; $5E26  おりると
    db $EF,$EE                     ; $5E2A  newline
    db $90,$90                     ; $5E2C  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$3A; $5E2E  たひ゛のとひ゛らのまに = たびのとびらのまに
    db $90                         ; $5E39  　(space)
    db $25,$2C,$43,$30             ; $5E3A  いけます
    db $8F                         ; $5E3E  。
    db $F7                         ; $5E3F  clear page
    db $F0                         ; $5E40  end of message


; --------------------------------------------------------------------------
; Message #82 ($5E41)
;   「はやく　ホィミンを
;   つれもどしてください！
;   EN: "Hurry and bring Hoimin back!"
; --------------------------------------------------------------------------
Bank66_Msg82:                               ; $5E41  (file $109E41)
    db $EA                         ; $5E41  ▶ new page
    db $9F                         ; $5E42  box tag
    db $96                         ; $5E43  end name/box tag
    db $3E,$48,$2B                 ; $5E44  はやく
    db $90                         ; $5E47  　(space)
    db $79,$58,$7B,$8C,$54         ; $5E48  ホィミンを
    db $EF,$EE                     ; $5E4D  newline
    db $90,$90                     ; $5E4F  　　(indent)
    db $35,$51,$47,$38,$8D,$2F,$37,$2B,$33,$8D,$2E,$25; $5E51  つれもと゛してくた゛さい = つれもどしてください
    db $99                         ; $5E5D  ！
    db $F7                         ; $5E5E  clear page
    db $F0                         ; $5E5F  end of message


; --------------------------------------------------------------------------
; Message #83 ($5E60)
;   「たびのとびらに　はいれば
;   いせかいへと　とばされます。
;   「いせかいには
;   ふしぎな　あなが　あいており、
;   「あなに　はいると　そのせかいの
;   つぎのフロアに　ワープできます。
;   「さいごのフロアにいる　まものを
;   たおせば　もどってこられるはず！
;   「ぼうけんちゅう　じぶんが
;   あるいたマップを　みたければ、
;   「セレクトボタンを　おすのです。
;   これ　いせかいに　いるときだけ。
; --------------------------------------------------------------------------
Bank66_Msg83:                               ; $5E60  (file $109E60)
    db $EB                         ; $5E60  ▶ new page
    db $9F                         ; $5E61  box tag
    db $96                         ; $5E62  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A; $5E63  たひ゛のとひ゛らに = たびのとびらに
    db $90                         ; $5E6C  　(space)
    db $3E,$25,$51,$3E,$8D         ; $5E6D  はいれは゛ = はいれば
    db $EF,$EE                     ; $5E72  newline
    db $90,$90                     ; $5E74  　　(indent)
    db $25,$31,$29,$25,$41,$38     ; $5E76  いせかいへと
    db $90                         ; $5E7C  　(space)
    db $38,$3E,$8D,$2E,$51,$43,$30 ; $5E7D  とは゛されます = とばされます
    db $8F                         ; $5E84  。
    db $FA                         ; $5E85  wait-for-button
    db $F7                         ; $5E86  clear page
    db $EF,$EE                     ; $5E87  newline
    db $9F                         ; $5E89  box tag
    db $96                         ; $5E8A  end name/box tag
    db $25,$31,$29,$25,$3A,$3E     ; $5E8B  いせかいには
    db $EF,$EE                     ; $5E91  newline
    db $90,$90                     ; $5E93  　　(indent)
    db $40,$2F,$2A,$8D,$39         ; $5E95  ふしき゛な = ふしぎな
    db $90                         ; $5E9A  　(space)
    db $24,$39,$29,$8D             ; $5E9B  あなか゛ = あなが
    db $90                         ; $5E9F  　(space)
    db $24,$25,$37,$28,$4F         ; $5EA0  あいており
    db $A4                         ; $5EA5  、
    db $FA                         ; $5EA6  wait-for-button
    db $F7                         ; $5EA7  clear page
    db $EF,$EE                     ; $5EA8  newline
    db $9F                         ; $5EAA  box tag
    db $96                         ; $5EAB  end name/box tag
    db $24,$39,$3A                 ; $5EAC  あなに
    db $90                         ; $5EAF  　(space)
    db $3E,$25,$50,$38             ; $5EB0  はいると
    db $90                         ; $5EB4  　(space)
    db $32,$3D,$31,$29,$25,$3D     ; $5EB5  そのせかいの
    db $EF,$EE                     ; $5EBB  newline
    db $90,$90                     ; $5EBD  　　(indent)
    db $35,$2A,$8D,$3D,$77,$89,$56,$3A; $5EBF  つき゛のフロアに = つぎのフロアに
    db $90                         ; $5EC7  　(space)
    db $8A,$9C,$77,$8E,$37,$8D,$2A,$43,$30; $5EC8  ワーフ゜て゛きます = ワープできます
    db $8F                         ; $5ED1  。
    db $FA                         ; $5ED2  wait-for-button
    db $F7                         ; $5ED3  clear page
    db $EF,$EE                     ; $5ED4  newline
    db $9F                         ; $5ED6  box tag
    db $96                         ; $5ED7  end name/box tag
    db $2E,$25,$2D,$8D,$3D,$77,$89,$56,$3A,$25,$50; $5ED8  さいこ゛のフロアにいる = さいごのフロアにいる
    db $90                         ; $5EE3  　(space)
    db $43,$47,$3D,$54             ; $5EE4  まものを
    db $EF,$EE                     ; $5EE8  newline
    db $90,$90                     ; $5EEA  　　(indent)
    db $33,$28,$31,$3E,$8D         ; $5EEC  たおせは゛ = たおせば
    db $90                         ; $5EF1  　(space)
    db $47,$38,$8D,$36,$37,$2D,$4E,$51,$50,$3E,$30,$8D; $5EF2  もと゛ってこられるはす゛ = もどってこられるはず
    db $99                         ; $5EFE  ！
    db $FA                         ; $5EFF  wait-for-button
    db $F7                         ; $5F00  clear page
    db $EF,$EE                     ; $5F01  newline
    db $9F                         ; $5F03  box tag
    db $96                         ; $5F04  end name/box tag
    db $42,$8D,$26,$2C,$55,$34,$4B,$26; $5F05  ほ゛うけんちゅう = ぼうけんちゅう
    db $90                         ; $5F0D  　(space)
    db $2F,$8D,$40,$8D,$55,$29,$8D ; $5F0E  し゛ふ゛んか゛ = じぶんが
    db $EF,$EE                     ; $5F15  newline
    db $90,$90                     ; $5F17  　　(indent)
    db $24,$50,$25,$33,$7A,$6D,$77,$8E,$54; $5F19  あるいたマッフ゜を = あるいたマップを
    db $90                         ; $5F22  　(space)
    db $44,$33,$2C,$51,$3E,$8D     ; $5F23  みたけれは゛ = みたければ
    db $A4                         ; $5F29  、
    db $FA                         ; $5F2A  wait-for-button
    db $F7                         ; $5F2B  clear page
    db $EF,$EE                     ; $5F2C  newline
    db $9F                         ; $5F2E  box tag
    db $96                         ; $5F2F  end name/box tag
    db $68,$88,$62,$6F,$79,$8D,$6A,$8C,$54; $5F30  セレクトホ゛タンを = セレクトボタンを
    db $90                         ; $5F39  　(space)
    db $28,$30,$3D,$37,$8D,$30     ; $5F3A  おすのて゛す = おすのです
    db $8F                         ; $5F40  。
    db $EF,$EE                     ; $5F41  newline
    db $90,$90                     ; $5F43  　　(indent)
    db $2D,$51                     ; $5F45  これ
    db $90                         ; $5F47  　(space)
    db $25,$31,$29,$25,$3A         ; $5F48  いせかいに
    db $90                         ; $5F4D  　(space)
    db $25,$50,$38,$2A,$33,$8D,$2C ; $5F4E  いるときた゛け = いるときだけ
    db $8F                         ; $5F55  。
    db $F7                         ; $5F56  clear page
    db $F0                         ; $5F57  end of message


; --------------------------------------------------------------------------
; Message #84 ($5F58)
;   「たびのとびらには　あちこちに
;   どうぐが　おちています。
;   「それらのどうぐを　うまくつかって
;   ぼうけんしてください。
;   「さいだい　[02][00]こ　までしか
;   どうぐは　もてませんからね！
; --------------------------------------------------------------------------
Bank66_Msg84:                               ; $5F58  (file $109F58)
    db $EA                         ; $5F58  ▶ new page
    db $9F                         ; $5F59  box tag
    db $96                         ; $5F5A  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A,$3E; $5F5B  たひ゛のとひ゛らには = たびのとびらには
    db $90                         ; $5F65  　(space)
    db $24,$34,$2D,$34,$3A         ; $5F66  あちこちに
    db $EF,$EE                     ; $5F6B  newline
    db $90,$90                     ; $5F6D  　　(indent)
    db $38,$8D,$26,$2B,$8D,$29,$8D ; $5F6F  と゛うく゛か゛ = どうぐが
    db $90                         ; $5F76  　(space)
    db $28,$34,$37,$25,$43,$30     ; $5F77  おちています
    db $8F                         ; $5F7D  。
    db $FA                         ; $5F7E  wait-for-button
    db $F7                         ; $5F7F  clear page
    db $EF,$EE                     ; $5F80  newline
    db $9F                         ; $5F82  box tag
    db $96                         ; $5F83  end name/box tag
    db $32,$51,$4E,$3D,$38,$8D,$26,$2B,$8D,$54; $5F84  それらのと゛うく゛を = それらのどうぐを
    db $90                         ; $5F8E  　(space)
    db $26,$43,$2B,$35,$29,$36,$37 ; $5F8F  うまくつかって
    db $EF,$EE                     ; $5F96  newline
    db $90,$90                     ; $5F98  　　(indent)
    db $42,$8D,$26,$2C,$55,$2F,$37,$2B,$33,$8D,$2E,$25; $5F9A  ほ゛うけんしてくた゛さい = ぼうけんしてください
    db $8F                         ; $5FA6  。
    db $FA                         ; $5FA7  wait-for-button
    db $F7                         ; $5FA8  clear page
    db $EF,$EE                     ; $5FA9  newline
    db $9F                         ; $5FAB  box tag
    db $96                         ; $5FAC  end name/box tag
    db $2E,$25,$33,$8D,$25         ; $5FAD  さいた゛い = さいだい
    db $90                         ; $5FB2  　(space)
    db $02                         ; $5FB3  ctrl $02
    db $00                         ; $5FB4  ctrl $00
    db $2D                         ; $5FB5  こ
    db $90                         ; $5FB6  　(space)
    db $43,$37,$8D,$2F,$29         ; $5FB7  まて゛しか = までしか
    db $EF,$EE                     ; $5FBC  newline
    db $90,$90                     ; $5FBE  　　(indent)
    db $38,$8D,$26,$2B,$8D,$3E     ; $5FC0  と゛うく゛は = どうぐは
    db $90                         ; $5FC6  　(space)
    db $47,$37,$43,$31,$55,$29,$4E,$3C; $5FC7  もてませんからね
    db $99                         ; $5FCF  ！
    db $F7                         ; $5FD0  clear page
    db $F0                         ; $5FD1  end of message


; --------------------------------------------------------------------------
; Message #85 ($5FD2)
;   「おうさまは　とても　ホィミンを
;   かわいがっていました。
;   「なぜ　にげだしたり
;   したのか、、。
;   「あちらの　あいている　へやが
;   たびだちのへやです。
; --------------------------------------------------------------------------
Bank66_Msg85:                               ; $5FD2  (file $109FD2)
    db $EA                         ; $5FD2  ▶ new page
    db $9F                         ; $5FD3  box tag
    db $96                         ; $5FD4  end name/box tag
    db $28,$26,$2E,$43,$3E         ; $5FD5  おうさまは
    db $90                         ; $5FDA  　(space)
    db $38,$37,$47                 ; $5FDB  とても
    db $90                         ; $5FDE  　(space)
    db $79,$58,$7B,$8C,$54         ; $5FDF  ホィミンを
    db $EF,$EE                     ; $5FE4  newline
    db $90,$90                     ; $5FE6  　　(indent)
    db $29,$53,$25,$29,$8D,$36,$37,$25,$43,$2F,$33; $5FE8  かわいか゛っていました = かわいがっていました
    db $8F                         ; $5FF3  。
    db $FA                         ; $5FF4  wait-for-button
    db $F7                         ; $5FF5  clear page
    db $EF,$EE                     ; $5FF6  newline
    db $9F                         ; $5FF8  box tag
    db $96                         ; $5FF9  end name/box tag
    db $39,$31,$8D                 ; $5FFA  なせ゛ = なぜ
    db $90                         ; $5FFD  　(space)
    db $3A,$2C,$8D,$33,$8D,$2F,$33,$4F; $5FFE  にけ゛た゛したり = にげだしたり
    db $EF,$EE                     ; $6006  newline
    db $90,$90                     ; $6008  　　(indent)
    db $2F,$33,$3D,$29             ; $600A  したのか
    db $A4                         ; $600E  、
    db $A4                         ; $600F  、
    db $8F                         ; $6010  。
    db $FA                         ; $6011  wait-for-button
    db $F7                         ; $6012  clear page
    db $EF,$EE                     ; $6013  newline
    db $9F                         ; $6015  box tag
    db $96                         ; $6016  end name/box tag
    db $24,$34,$4E,$3D             ; $6017  あちらの
    db $90                         ; $601B  　(space)
    db $24,$25,$37,$25,$50         ; $601C  あいている
    db $90                         ; $6021  　(space)
    db $41,$48,$29,$8D             ; $6022  へやか゛ = へやが
    db $EF,$EE                     ; $6026  newline
    db $90,$90                     ; $6028  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$41,$48,$37,$8D,$30; $602A  たひ゛た゛ちのへやて゛す = たびだちのへやです
    db $8F                         ; $6036  。
    db $F7                         ; $6037  clear page
    db $F0                         ; $6038  end of message


; --------------------------------------------------------------------------
; Message #86 ($6039)
;   「ようこそ　ちいさなマスターさま！
;   ここは　たびのとびらのまです。
; --------------------------------------------------------------------------
Bank66_Msg86:                               ; $6039  (file $10A039)
    db $EA                         ; $6039  ▶ new page
    db $9F                         ; $603A  box tag
    db $96                         ; $603B  end name/box tag
    db $4C,$26,$2D,$32             ; $603C  ようこそ
    db $90                         ; $6040  　(space)
    db $34,$25,$2E,$39,$7A,$67,$6A,$9C,$2E,$43; $6041  ちいさなマスターさま
    db $99                         ; $604B  ！
    db $EF,$EE                     ; $604C  newline
    db $90,$90                     ; $604E  　　(indent)
    db $2D,$2D,$3E                 ; $6050  ここは
    db $90                         ; $6053  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$37,$8D,$30; $6054  たひ゛のとひ゛らのまて゛す = たびのとびらのまです
    db $8F                         ; $6061  。
    db $F7                         ; $6062  clear page
    db $F0                         ; $6063  end of message


; --------------------------------------------------------------------------
; Message #87 ($6064)
;   「ここは　たびだちのへやです。
;   たびだちのとびらは　こちらです。
;   「ホィミンは　ここのとびらに
;   にげこみました。
;   「〈テリー〉どの　たのみましたぞ！
; --------------------------------------------------------------------------
Bank66_Msg87:                               ; $6064  (file $10A064)
    db $EA                         ; $6064  ▶ new page
    db $9F                         ; $6065  box tag
    db $96                         ; $6066  end name/box tag
    db $2D,$2D,$3E                 ; $6067  ここは
    db $90                         ; $606A  　(space)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$41,$48,$37,$8D,$30; $606B  たひ゛た゛ちのへやて゛す = たびだちのへやです
    db $8F                         ; $6077  。
    db $EF,$EE                     ; $6078  newline
    db $90,$90                     ; $607A  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$38,$3F,$8D,$4E,$3E; $607C  たひ゛た゛ちのとひ゛らは = たびだちのとびらは
    db $90                         ; $6088  　(space)
    db $2D,$34,$4E,$37,$8D,$30     ; $6089  こちらて゛す = こちらです
    db $8F                         ; $608F  。
    db $FA                         ; $6090  wait-for-button
    db $F7                         ; $6091  clear page
    db $EF,$EE                     ; $6092  newline
    db $9F                         ; $6094  box tag
    db $96                         ; $6095  end name/box tag
    db $79,$58,$7B,$8C,$3E         ; $6096  ホィミンは
    db $90                         ; $609B  　(space)
    db $2D,$2D,$3D,$38,$3F,$8D,$4E,$3A; $609C  ここのとひ゛らに = ここのとびらに
    db $EF,$EE                     ; $60A4  newline
    db $90,$90                     ; $60A6  　　(indent)
    db $3A,$2C,$8D,$2D,$44,$43,$2F,$33; $60A8  にけ゛こみました = にげこみました
    db $8F                         ; $60B0  。
    db $FA                         ; $60B1  wait-for-button
    db $F7                         ; $60B2  clear page
    db $EF,$EE                     ; $60B3  newline
    db $9F                         ; $60B5  box tag
    db $96                         ; $60B6  end name/box tag
    db $F6                         ; $60B7  «insert hero name» (テリー)
    db $38,$8D,$3D                 ; $60B8  と゛の = どの
    db $90                         ; $60BB  　(space)
    db $33,$3D,$44,$43,$2F,$33,$32,$8D; $60BC  たのみましたそ゛ = たのみましたぞ
    db $99                         ; $60C4  ！
    db $EF,$EE                     ; $60C5  newline
    db $F7                         ; $60C7  clear page
    db $F0                         ; $60C8  end of message


; --------------------------------------------------------------------------
; Message #88 ($60C9)
;   「はじめまして。
;   ぼく　ホィミン！
;   「ぼくを　つかまえにきたんだろ？
;   でも　やだよ。
;   「ぼくじょうは　つまらないから
;   かえりたくないんだ！
;   EN: Hoimin introduces himself and refuses to return to the boring ranch.
; --------------------------------------------------------------------------
Bank66_Msg88:                               ; $60C9  (file $10A0C9)
    db $EB                         ; $60C9  ▶ new page
    db $9F                         ; $60CA  box tag
    db $96                         ; $60CB  end name/box tag
    db $3E,$2F,$8D,$46,$43,$2F,$37 ; $60CC  はし゛めまして = はじめまして
    db $8F                         ; $60D3  。
    db $EF,$EE                     ; $60D4  newline
    db $90,$90                     ; $60D6  　　(indent)
    db $42,$8D,$2B                 ; $60D8  ほ゛く = ぼく
    db $90                         ; $60DB  　(space)
    db $79,$58,$7B,$8C             ; $60DC  ホィミン
    db $99                         ; $60E0  ！
    db $FA                         ; $60E1  wait-for-button
    db $F7                         ; $60E2  clear page
    db $EF,$EE                     ; $60E3  newline
    db $9F                         ; $60E5  box tag
    db $96                         ; $60E6  end name/box tag
    db $42,$8D,$2B,$54             ; $60E7  ほ゛くを = ぼくを
    db $90                         ; $60EB  　(space)
    db $35,$29,$43,$27,$3A,$2A,$33,$55,$33,$8D,$52; $60EC  つかまえにきたんた゛ろ = つかまえにきたんだろ
    db $98                         ; $60F7  ？
    db $EF,$EE                     ; $60F8  newline
    db $90,$90                     ; $60FA  　　(indent)
    db $37,$8D,$47                 ; $60FC  て゛も = でも
    db $90                         ; $60FF  　(space)
    db $48,$33,$8D,$4C             ; $6100  やた゛よ = やだよ
    db $8F                         ; $6104  。
    db $FA                         ; $6105  wait-for-button
    db $F7                         ; $6106  clear page
    db $EF,$EE                     ; $6107  newline
    db $9F                         ; $6109  box tag
    db $96                         ; $610A  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3E; $610B  ほ゛くし゛ょうは = ぼくじょうは
    db $90                         ; $6113  　(space)
    db $35,$43,$4E,$39,$25,$29,$4E ; $6114  つまらないから
    db $EF,$EE                     ; $611B  newline
    db $90,$90                     ; $611D  　　(indent)
    db $29,$27,$4F,$33,$2B,$39,$25,$55,$33,$8D; $611F  かえりたくないんた゛ = かえりたくないんだ
    db $99                         ; $6129  ！
    db $F7                         ; $612A  clear page
    db $F0                         ; $612B  end of message


; --------------------------------------------------------------------------
; Message #89 ($612C)
;   「つよいね[94]！
;   〈テリー〉のこと　きにいったよ！！
;   EN: Hoimin warms to the hero.
; --------------------------------------------------------------------------
Bank66_Msg89:                               ; $612C  (file $10A12C)
    db $EB                         ; $612C  ▶ new page
    db $9F                         ; $612D  box tag
    db $96                         ; $612E  end name/box tag
    db $35,$4C,$25,$3C             ; $612F  つよいね
    db $94                         ; $6133  ctrl $94
    db $99                         ; $6134  ！
    db $EF,$EE                     ; $6135  newline
    db $90,$90                     ; $6137  　　(indent)
    db $F6                         ; $6139  «insert hero name» (テリー)
    db $3D,$2D,$38                 ; $613A  のこと
    db $90                         ; $613D  　(space)
    db $2A,$3A,$25,$36,$33,$4C     ; $613E  きにいったよ
    db $99                         ; $6144  ！
    db $99                         ; $6145  ！
    db $F7                         ; $6146  clear page
    db $F0                         ; $6147  end of message


; --------------------------------------------------------------------------
; Message #90 ($6148)
;   おう「〈テリー〉よ！　ホィミンを
;   つれてきて　くれたか！？
;   おう「なに？　ホィミンは　こちらに
;   かえりたくないと　もうした！？
;   おう「、、だが　そなたになら
;   ついていくと　いったのか！？
;   おう「ほう、、。
;   なるほどのう、、。
;   おう「ふむ！　まものに　すかれるとは
;   あっぱれじゃ！
;   おう「わしは　そなたが　きにいった！
;   プリォは　ゆるそうぞ！
;   EN: The King pardons Prio after Hoimin agrees to follow the hero.
; --------------------------------------------------------------------------
Bank66_Msg90:                               ; $6148  (file $10A148)
    db $EA                         ; $6148  ▶ new page
    db $28,$26                     ; $6149  おう  (speaker: おう)
    db $96                         ; $614B  end name/box tag
    db $F6                         ; $614C  «insert hero name» (テリー)
    db $4C                         ; $614D  よ
    db $99                         ; $614E  ！
    db $90                         ; $614F  　(space)
    db $79,$58,$7B,$8C,$54         ; $6150  ホィミンを
    db $EF,$EE                     ; $6155  newline
    db $90,$90                     ; $6157  　　(indent)
    db $35,$51,$37,$2A,$37         ; $6159  つれてきて
    db $90                         ; $615E  　(space)
    db $2B,$51,$33,$29             ; $615F  くれたか
    db $99                         ; $6163  ！
    db $98                         ; $6164  ？
    db $FA                         ; $6165  wait-for-button
    db $F7                         ; $6166  clear page
    db $EF,$EE                     ; $6167  newline
    db $28,$26                     ; $6169  おう  (speaker: おう)
    db $96                         ; $616B  end name/box tag
    db $39,$3A                     ; $616C  なに
    db $98                         ; $616E  ？
    db $90                         ; $616F  　(space)
    db $79,$58,$7B,$8C,$3E         ; $6170  ホィミンは
    db $90                         ; $6175  　(space)
    db $2D,$34,$4E,$3A             ; $6176  こちらに
    db $EF,$EE                     ; $617A  newline
    db $90,$90                     ; $617C  　　(indent)
    db $29,$27,$4F,$33,$2B,$39,$25,$38; $617E  かえりたくないと
    db $90                         ; $6186  　(space)
    db $47,$26,$2F,$33             ; $6187  もうした
    db $99                         ; $618B  ！
    db $98                         ; $618C  ？
    db $FA                         ; $618D  wait-for-button
    db $F7                         ; $618E  clear page
    db $EF,$EE                     ; $618F  newline
    db $28,$26                     ; $6191  おう  (speaker: おう)
    db $96                         ; $6193  end name/box tag
    db $A4                         ; $6194  、
    db $A4                         ; $6195  、
    db $33,$8D,$29,$8D             ; $6196  た゛か゛ = だが
    db $90                         ; $619A  　(space)
    db $32,$39,$33,$3A,$39,$4E     ; $619B  そなたになら
    db $EF,$EE                     ; $61A1  newline
    db $90,$90                     ; $61A3  　　(indent)
    db $35,$25,$37,$25,$2B,$38     ; $61A5  ついていくと
    db $90                         ; $61AB  　(space)
    db $25,$36,$33,$3D,$29         ; $61AC  いったのか
    db $99                         ; $61B1  ！
    db $98                         ; $61B2  ？
    db $FA                         ; $61B3  wait-for-button
    db $F7                         ; $61B4  clear page
    db $EF,$EE                     ; $61B5  newline
    db $28,$26                     ; $61B7  おう  (speaker: おう)
    db $96                         ; $61B9  end name/box tag
    db $42,$26                     ; $61BA  ほう
    db $A4                         ; $61BC  、
    db $A4                         ; $61BD  、
    db $8F                         ; $61BE  。
    db $EF,$EE                     ; $61BF  newline
    db $90,$90                     ; $61C1  　　(indent)
    db $39,$50,$42,$38,$8D,$3D,$26 ; $61C3  なるほと゛のう = なるほどのう
    db $A4                         ; $61CA  、
    db $A4                         ; $61CB  、
    db $8F                         ; $61CC  。
    db $FA                         ; $61CD  wait-for-button
    db $F7                         ; $61CE  clear page
    db $EF,$EE                     ; $61CF  newline
    db $28,$26                     ; $61D1  おう  (speaker: おう)
    db $96                         ; $61D3  end name/box tag
    db $40,$45                     ; $61D4  ふむ
    db $99                         ; $61D6  ！
    db $90                         ; $61D7  　(space)
    db $43,$47,$3D,$3A             ; $61D8  まものに
    db $90                         ; $61DC  　(space)
    db $30,$29,$51,$50,$38,$3E     ; $61DD  すかれるとは
    db $EF,$EE                     ; $61E3  newline
    db $90,$90                     ; $61E5  　　(indent)
    db $24,$36,$3E,$8E,$51,$2F,$8D,$49; $61E7  あっは゜れし゛ゃ = あっぱれじゃ
    db $99                         ; $61EF  ！
    db $FA                         ; $61F0  wait-for-button
    db $F7                         ; $61F1  clear page
    db $EF,$EE                     ; $61F2  newline
    db $28,$26                     ; $61F4  おう  (speaker: おう)
    db $96                         ; $61F6  end name/box tag
    db $53,$2F,$3E                 ; $61F7  わしは
    db $90                         ; $61FA  　(space)
    db $32,$39,$33,$29,$8D         ; $61FB  そなたか゛ = そなたが
    db $90                         ; $6200  　(space)
    db $2A,$3A,$25,$36,$33         ; $6201  きにいった
    db $99                         ; $6206  ！
    db $EF,$EE                     ; $6207  newline
    db $90,$90                     ; $6209  　　(indent)
    db $77,$8E,$86,$5E,$3E         ; $620B  フ゜リォは = プリォは
    db $90                         ; $6210  　(space)
    db $4A,$50,$32,$26,$32,$8D     ; $6211  ゆるそうそ゛ = ゆるそうぞ
    db $99                         ; $6217  ！
    db $F7                         ; $6218  clear page
    db $F0                         ; $6219  end of message


; --------------------------------------------------------------------------
; Message #91 ($621A)
;   プリォ「ありがとう〈テリー〉！　これで
;   ぼくじょうに　もどれるだ！！
;   EN: Prio thanks the hero — now he can return to the ranch.
; --------------------------------------------------------------------------
Bank66_Msg91:                               ; $621A  (file $10A21A)
    db $EB                         ; $621A  ▶ new page
    db $77,$8E,$86,$5E             ; $621B  フ゜リォ  (speaker: プリォ)
    db $96                         ; $621F  end name/box tag
    db $24,$4F,$29,$8D,$38,$26     ; $6220  ありか゛とう = ありがとう
    db $F6                         ; $6226  «insert hero name» (テリー)
    db $99                         ; $6227  ！
    db $90                         ; $6228  　(space)
    db $2D,$51,$37,$8D             ; $6229  これて゛ = これで
    db $EF,$EE                     ; $622D  newline
    db $90,$90                     ; $622F  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $6231  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $6239  　(space)
    db $47,$38,$8D,$51,$50,$33,$8D ; $623A  もと゛れるた゛ = もどれるだ
    db $99                         ; $6241  ！
    db $99                         ; $6242  ！
    db $F7                         ; $6243  clear page
    db $F0                         ; $6244  end of message


; --------------------------------------------------------------------------
; Message #92 ($6245)
;   おう「〈テリー〉よ。　これより
;   かくとうじょうに　むかうのだ。
;   おう「かくとうじょうには　そなたの
;   ラィバルたちが　まっておる。
;   おう「かれらに　かちぬいてゆけば
;   たいかいへ　でられるぞ！
;   おう「では　わしは　いそがしいので
;   これで　しつれいするのじゃ。
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank66_Msg92:                               ; $6245  (file $10A245)
    db $EA                         ; $6245  ▶ new page
    db $28,$26                     ; $6246  おう  (speaker: おう)
    db $96                         ; $6248  end name/box tag
    db $F6                         ; $6249  «insert hero name» (テリー)
    db $4C                         ; $624A  よ
    db $8F                         ; $624B  。
    db $90                         ; $624C  　(space)
    db $2D,$51,$4C,$4F             ; $624D  これより
    db $EF,$EE                     ; $6251  newline
    db $90,$90                     ; $6253  　　(indent)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A; $6255  かくとうし゛ょうに = かくとうじょうに
    db $90                         ; $625E  　(space)
    db $45,$29,$26,$3D,$33,$8D     ; $625F  むかうのた゛ = むかうのだ
    db $8F                         ; $6265  。
    db $FA                         ; $6266  wait-for-button
    db $F7                         ; $6267  clear page
    db $EF,$EE                     ; $6268  newline
    db $28,$26                     ; $626A  おう  (speaker: おう)
    db $96                         ; $626C  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A,$3E; $626D  かくとうし゛ょうには = かくとうじょうには
    db $90                         ; $6277  　(space)
    db $32,$39,$33,$3D             ; $6278  そなたの
    db $EF,$EE                     ; $627C  newline
    db $90,$90                     ; $627E  　　(indent)
    db $85,$58,$75,$8D,$87,$33,$34,$29,$8D; $6280  ラィハ゛ルたちか゛ = ラィバルたちが
    db $90                         ; $6289  　(space)
    db $43,$36,$37,$28,$50         ; $628A  まっておる
    db $8F                         ; $628F  。
    db $FA                         ; $6290  wait-for-button
    db $F7                         ; $6291  clear page
    db $EF,$EE                     ; $6292  newline
    db $28,$26                     ; $6294  おう  (speaker: おう)
    db $96                         ; $6296  end name/box tag
    db $29,$51,$4E,$3A             ; $6297  かれらに
    db $90                         ; $629B  　(space)
    db $29,$34,$3B,$25,$37,$4A,$2C,$3E,$8D; $629C  かちぬいてゆけは゛ = かちぬいてゆけば
    db $EF,$EE                     ; $62A5  newline
    db $90,$90                     ; $62A7  　　(indent)
    db $33,$25,$29,$25,$41         ; $62A9  たいかいへ
    db $90                         ; $62AE  　(space)
    db $37,$8D,$4E,$51,$50,$32,$8D ; $62AF  て゛られるそ゛ = でられるぞ
    db $99                         ; $62B6  ！
    db $FA                         ; $62B7  wait-for-button
    db $F7                         ; $62B8  clear page
    db $EF,$EE                     ; $62B9  newline
    db $28,$26                     ; $62BB  おう  (speaker: おう)
    db $96                         ; $62BD  end name/box tag
    db $37,$8D,$3E                 ; $62BE  て゛は = では
    db $90                         ; $62C1  　(space)
    db $53,$2F,$3E                 ; $62C2  わしは
    db $90                         ; $62C5  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $62C6  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $62CF  newline
    db $90,$90                     ; $62D1  　　(indent)
    db $2D,$51,$37,$8D             ; $62D3  これて゛ = これで
    db $90                         ; $62D7  　(space)
    db $2F,$35,$51,$25,$30,$50,$3D,$2F,$8D,$49; $62D8  しつれいするのし゛ゃ = しつれいするのじゃ
    db $8F                         ; $62E2  。
    db $FA                         ; $62E3  wait-for-button
    db $F7                         ; $62E4  clear page
    db $EF,$EE                     ; $62E5  newline
    db $28,$26                     ; $62E7  おう  (speaker: おう)
    db $96                         ; $62E9  end name/box tag
    db $58,$69                     ; $62EA  ィソ
    db $90                         ; $62EC  　(space)
    db $58,$69                     ; $62ED  ィソ
    db $A4                         ; $62EF  、
    db $90                         ; $62F0  　(space)
    db $58,$69                     ; $62F1  ィソ
    db $90                         ; $62F3  　(space)
    db $58,$69                     ; $62F4  ィソ
    db $A4                         ; $62F6  、
    db $A4                         ; $62F7  、
    db $8F                         ; $62F8  。
    db $EF,$EE                     ; $62F9  newline
    db $F7                         ; $62FB  clear page
    db $F0                         ; $62FC  end of message


; --------------------------------------------------------------------------
; Message #93 ($62FD)
;   スラお「〈テリー〉さん！
;   ゆうしょう　おめでとう！！
;   スラお「スラぼう　じいちゃんも
;   よろこんでる　はずだよ！！
; --------------------------------------------------------------------------
Bank66_Msg93:                               ; $62FD  (file $10A2FD)
    db $EA                         ; $62FD  ▶ new page
    db $67,$85,$28                 ; $62FE  スラお  (speaker: スラお)
    db $96                         ; $6301  end name/box tag
    db $F6                         ; $6302  «insert hero name» (テリー)
    db $2E,$55                     ; $6303  さん
    db $99                         ; $6305  ！
    db $EF,$EE                     ; $6306  newline
    db $90,$90                     ; $6308  　　(indent)
    db $4A,$26,$2F,$4D,$26         ; $630A  ゆうしょう
    db $90                         ; $630F  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $6310  おめて゛とう = おめでとう
    db $99                         ; $6316  ！
    db $99                         ; $6317  ！
    db $FA                         ; $6318  wait-for-button
    db $F7                         ; $6319  clear page
    db $EF,$EE                     ; $631A  newline
    db $67,$85,$28                 ; $631C  スラお  (speaker: スラお)
    db $96                         ; $631F  end name/box tag
    db $67,$85,$42,$8D,$26         ; $6320  スラほ゛う = スラぼう
    db $90                         ; $6325  　(space)
    db $2F,$8D,$25,$34,$49,$55,$47 ; $6326  し゛いちゃんも = じいちゃんも
    db $EF,$EE                     ; $632D  newline
    db $90,$90                     ; $632F  　　(indent)
    db $4C,$52,$2D,$55,$37,$8D,$50 ; $6331  よろこんて゛る = よろこんでる
    db $90                         ; $6338  　(space)
    db $3E,$30,$8D,$33,$8D,$4C     ; $6339  はす゛た゛よ = はずだよ
    db $99                         ; $633F  ！
    db $99                         ; $6340  ！
    db $F7                         ; $6341  clear page
    db $F0                         ; $6342  end of message


; --------------------------------------------------------------------------
; Message #94 ($6343)
;   「しろから　まっすぐそとにでて
;   したにゆくと　かくとうじょうだ。
;   「かくとうじょうで　かちぬけば
;   たいかいに　でられるぞ！
; --------------------------------------------------------------------------
Bank66_Msg94:                               ; $6343  (file $10A343)
    db $EA                         ; $6343  ▶ new page
    db $9F                         ; $6344  box tag
    db $96                         ; $6345  end name/box tag
    db $2F,$52,$29,$4E             ; $6346  しろから
    db $90                         ; $634A  　(space)
    db $43,$36,$30,$2B,$8D,$32,$38,$3A,$37,$8D,$37; $634B  まっすく゛そとにて゛て = まっすぐそとにでて
    db $EF,$EE                     ; $6356  newline
    db $90,$90                     ; $6358  　　(indent)
    db $2F,$33,$3A,$4A,$2B,$38     ; $635A  したにゆくと
    db $90                         ; $6360  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$33,$8D; $6361  かくとうし゛ょうた゛ = かくとうじょうだ
    db $8F                         ; $636B  。
    db $FA                         ; $636C  wait-for-button
    db $F7                         ; $636D  clear page
    db $EF,$EE                     ; $636E  newline
    db $9F                         ; $6370  box tag
    db $96                         ; $6371  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D; $6372  かくとうし゛ょうて゛ = かくとうじょうで
    db $90                         ; $637C  　(space)
    db $29,$34,$3B,$2C,$3E,$8D     ; $637D  かちぬけは゛ = かちぬけば
    db $EF,$EE                     ; $6383  newline
    db $90,$90                     ; $6385  　　(indent)
    db $33,$25,$29,$25,$3A         ; $6387  たいかいに
    db $90                         ; $638C  　(space)
    db $37,$8D,$4E,$51,$50,$32,$8D ; $638D  て゛られるそ゛ = でられるぞ
    db $99                         ; $6394  ！
    db $F7                         ; $6395  clear page
    db $F0                         ; $6396  end of message


; --------------------------------------------------------------------------
; Message #95 ($6397)
;   「このかいだんを　のぼると
;   モンスターぼくじょうです。
; --------------------------------------------------------------------------
Bank66_Msg95:                               ; $6397  (file $10A397)
    db $EA                         ; $6397  ▶ new page
    db $9F                         ; $6398  box tag
    db $96                         ; $6399  end name/box tag
    db $2D,$3D,$29,$25,$33,$8D,$55,$54; $639A  このかいた゛んを = このかいだんを
    db $90                         ; $63A2  　(space)
    db $3D,$42,$8D,$50,$38         ; $63A3  のほ゛ると = のぼると
    db $EF,$EE                     ; $63A8  newline
    db $90,$90                     ; $63AA  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$42,$8D,$2B,$2F,$8D,$4D,$26,$37,$8D,$30; $63AC  モンスターほ゛くし゛ょうて゛す = モンスターぼくじょうです
    db $8F                         ; $63BB  。
    db $F7                         ; $63BC  clear page
    db $F0                         ; $63BD  end of message


; --------------------------------------------------------------------------
; Message #96 ($63BE)
;   「ここは　タィジャの　おしろです。
;   「したに　すすんで　そとにでれば
;   タィジャのまち　ですよ。
; --------------------------------------------------------------------------
Bank66_Msg96:                               ; $63BE  (file $10A3BE)
    db $EA                         ; $63BE  ▶ new page
    db $9F                         ; $63BF  box tag
    db $96                         ; $63C0  end name/box tag
    db $2D,$2D,$3E                 ; $63C1  ここは
    db $90                         ; $63C4  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $63C5  タィシ゛ャの = タィジャの
    db $90                         ; $63CB  　(space)
    db $28,$2F,$52,$37,$8D,$30     ; $63CC  おしろて゛す = おしろです
    db $8F                         ; $63D2  。
    db $EF,$EE                     ; $63D3  newline
    db $FA                         ; $63D5  wait-for-button
    db $F7                         ; $63D6  clear page
    db $EF,$EE                     ; $63D7  newline
    db $F3                         ; $63D9  open text box
    db $9F                         ; $63DA  box tag
    db $96                         ; $63DB  end name/box tag
    db $2F,$33,$3A                 ; $63DC  したに
    db $90                         ; $63DF  　(space)
    db $30,$30,$55,$37,$8D         ; $63E0  すすんて゛ = すすんで
    db $90                         ; $63E5  　(space)
    db $32,$38,$3A,$37,$8D,$51,$3E,$8D; $63E6  そとにて゛れは゛ = そとにでれば
    db $EF,$EE                     ; $63EE  newline
    db $90,$90                     ; $63F0  　　(indent)
    db $6A,$58,$66,$8D,$82,$3D,$43,$34; $63F2  タィシ゛ャのまち = タィジャのまち
    db $90                         ; $63FA  　(space)
    db $37,$8D,$30,$4C             ; $63FB  て゛すよ = ですよ
    db $8F                         ; $63FF  。
    db $F7                         ; $6400  clear page
    db $F0                         ; $6401  end of message


; --------------------------------------------------------------------------
; Message #97 ($6402)
;   「よ[9D]し！
;   ここから　とびおりるぞ！！
; --------------------------------------------------------------------------
Bank66_Msg97:                               ; $6402  (file $10A402)
    db $EA                         ; $6402  ▶ new page
    db $9F                         ; $6403  box tag
    db $96                         ; $6404  end name/box tag
    db $4C                         ; $6405  よ
    db $9D                         ; $6406  ctrl $9D
    db $2F                         ; $6407  し
    db $99                         ; $6408  ！
    db $EF,$EE                     ; $6409  newline
    db $90,$90                     ; $640B  　　(indent)
    db $2D,$2D,$29,$4E             ; $640D  ここから
    db $90                         ; $6411  　(space)
    db $38,$3F,$8D,$28,$4F,$50,$32,$8D; $6412  とひ゛おりるそ゛ = とびおりるぞ
    db $99                         ; $641A  ！
    db $99                         ; $641B  ！
    db $F7                         ; $641C  clear page
    db $F0                         ; $641D  end of message


; --------------------------------------------------------------------------
; Message #98 ($641E)
;   「ここは　タィジャの　まちですわ。
;   「そちらの　あなのなかが
;   かくとうじょうですわよ。
; --------------------------------------------------------------------------
Bank66_Msg98:                               ; $641E  (file $10A41E)
    db $EB                         ; $641E  ▶ new page
    db $9F                         ; $641F  box tag
    db $96                         ; $6420  end name/box tag
    db $2D,$2D,$3E                 ; $6421  ここは
    db $90                         ; $6424  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $6425  タィシ゛ャの = タィジャの
    db $90                         ; $642B  　(space)
    db $43,$34,$37,$8D,$30,$53     ; $642C  まちて゛すわ = まちですわ
    db $8F                         ; $6432  。
    db $EF,$EE                     ; $6433  newline
    db $FA                         ; $6435  wait-for-button
    db $F7                         ; $6436  clear page
    db $EF,$EE                     ; $6437  newline
    db $F3                         ; $6439  open text box
    db $9F                         ; $643A  box tag
    db $96                         ; $643B  end name/box tag
    db $32,$34,$4E,$3D             ; $643C  そちらの
    db $90                         ; $6440  　(space)
    db $24,$39,$3D,$39,$29,$29,$8D ; $6441  あなのなかか゛ = あなのなかが
    db $EF,$EE                     ; $6448  newline
    db $90,$90                     ; $644A  　　(indent)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D,$30,$53,$4C; $644C  かくとうし゛ょうて゛すわよ = かくとうじょうですわよ
    db $8F                         ; $6459  。
    db $F7                         ; $645A  clear page
    db $F0                         ; $645B  end of message


; --------------------------------------------------------------------------
; Message #99 ($645C)
;   「いやー。　とびおりるって
;   きもちいいですね[94]！
; --------------------------------------------------------------------------
Bank66_Msg99:                               ; $645C  (file $10A45C)
    db $EA                         ; $645C  ▶ new page
    db $9F                         ; $645D  box tag
    db $96                         ; $645E  end name/box tag
    db $25,$48,$9C                 ; $645F  いやー
    db $8F                         ; $6462  。
    db $90                         ; $6463  　(space)
    db $38,$3F,$8D,$28,$4F,$50,$36,$37; $6464  とひ゛おりるって = とびおりるって
    db $EF,$EE                     ; $646C  newline
    db $90,$90                     ; $646E  　　(indent)
    db $2A,$47,$34,$25,$25,$37,$8D,$30,$3C; $6470  きもちいいて゛すね = きもちいいですね
    db $94                         ; $6479  ctrl $94
    db $99                         ; $647A  ！
    db $F7                         ; $647B  clear page
    db $F0                         ; $647C  end of message


; --------------------------------------------------------------------------
; Message #100 ($647D)
;   「おお　〈テリー〉か。
;   わしも　としじゃのう。
;   「かいだんを　おりるのも
;   ひとくろうじゃい。
;   「、、かくとうじょうに　いくのか？
;   そうか　がんばるんじゃぞ。
; --------------------------------------------------------------------------
Bank66_Msg100:                               ; $647D  (file $10A47D)
    db $EA                         ; $647D  ▶ new page
    db $9F                         ; $647E  box tag
    db $96                         ; $647F  end name/box tag
    db $28,$28                     ; $6480  おお
    db $90                         ; $6482  　(space)
    db $F6                         ; $6483  «insert hero name» (テリー)
    db $29                         ; $6484  か
    db $8F                         ; $6485  。
    db $EF,$EE                     ; $6486  newline
    db $90,$90                     ; $6488  　　(indent)
    db $53,$2F,$47                 ; $648A  わしも
    db $90                         ; $648D  　(space)
    db $38,$2F,$2F,$8D,$49,$3D,$26 ; $648E  としし゛ゃのう = としじゃのう
    db $8F                         ; $6495  。
    db $FA                         ; $6496  wait-for-button
    db $F7                         ; $6497  clear page
    db $EF,$EE                     ; $6498  newline
    db $9F                         ; $649A  box tag
    db $96                         ; $649B  end name/box tag
    db $29,$25,$33,$8D,$55,$54     ; $649C  かいた゛んを = かいだんを
    db $90                         ; $64A2  　(space)
    db $28,$4F,$50,$3D,$47         ; $64A3  おりるのも
    db $EF,$EE                     ; $64A8  newline
    db $90,$90                     ; $64AA  　　(indent)
    db $3F,$38,$2B,$52,$26,$2F,$8D,$49,$25; $64AC  ひとくろうし゛ゃい = ひとくろうじゃい
    db $8F                         ; $64B5  。
    db $FA                         ; $64B6  wait-for-button
    db $F7                         ; $64B7  clear page
    db $EF,$EE                     ; $64B8  newline
    db $9F                         ; $64BA  box tag
    db $96                         ; $64BB  end name/box tag
    db $A4                         ; $64BC  、
    db $A4                         ; $64BD  、
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A; $64BE  かくとうし゛ょうに = かくとうじょうに
    db $90                         ; $64C7  　(space)
    db $25,$2B,$3D,$29             ; $64C8  いくのか
    db $98                         ; $64CC  ？
    db $EF,$EE                     ; $64CD  newline
    db $90,$90                     ; $64CF  　　(indent)
    db $32,$26,$29                 ; $64D1  そうか
    db $90                         ; $64D4  　(space)
    db $29,$8D,$55,$3E,$8D,$50,$55,$2F,$8D,$49,$32,$8D; $64D5  か゛んは゛るんし゛ゃそ゛ = がんばるんじゃぞ
    db $8F                         ; $64E1  。
    db $F7                         ; $64E2  clear page
    db $F0                         ; $64E3  end of message


; --------------------------------------------------------------------------
; Message #101 ($64E4)
;   「わたしも　ちいさなメダルを
;   ひろったことが　あります。
;   「あれは　たびのとびらから
;   ぼうけんに　でていたころでした。
;   「あっ　そうだ！　ひとつ
;   いいことを　おしえましょう。
;   「たびのとびらの　むこうでは
;   ときどき　こべやも　あって、
;   「そのへやでは　ぼうけんのしょに
;   きろくできたような　きがします。
;   「むこうでは　そこでしか
;   きろくできなかったような、、。
; --------------------------------------------------------------------------
Bank66_Msg101:                               ; $64E4  (file $10A4E4)
    db $EB                         ; $64E4  ▶ new page
    db $9F                         ; $64E5  box tag
    db $96                         ; $64E6  end name/box tag
    db $53,$33,$2F,$47             ; $64E7  わたしも
    db $90                         ; $64EB  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $64EC  ちいさなメタ゛ルを = ちいさなメダルを
    db $EF,$EE                     ; $64F5  newline
    db $90,$90                     ; $64F7  　　(indent)
    db $3F,$52,$36,$33,$2D,$38,$29,$8D; $64F9  ひろったことか゛ = ひろったことが
    db $90                         ; $6501  　(space)
    db $24,$4F,$43,$30             ; $6502  あります
    db $8F                         ; $6506  。
    db $FA                         ; $6507  wait-for-button
    db $F7                         ; $6508  clear page
    db $EF,$EE                     ; $6509  newline
    db $9F                         ; $650B  box tag
    db $96                         ; $650C  end name/box tag
    db $24,$51,$3E                 ; $650D  あれは
    db $90                         ; $6510  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$4E; $6511  たひ゛のとひ゛らから = たびのとびらから
    db $EF,$EE                     ; $651B  newline
    db $90,$90                     ; $651D  　　(indent)
    db $42,$8D,$26,$2C,$55,$3A     ; $651F  ほ゛うけんに = ぼうけんに
    db $90                         ; $6525  　(space)
    db $37,$8D,$37,$25,$33,$2D,$52,$37,$8D,$2F,$33; $6526  て゛ていたころて゛した = でていたころでした
    db $8F                         ; $6531  。
    db $FA                         ; $6532  wait-for-button
    db $F7                         ; $6533  clear page
    db $EF,$EE                     ; $6534  newline
    db $9F                         ; $6536  box tag
    db $96                         ; $6537  end name/box tag
    db $24,$36                     ; $6538  あっ
    db $90                         ; $653A  　(space)
    db $32,$26,$33,$8D             ; $653B  そうた゛ = そうだ
    db $99                         ; $653F  ！
    db $90                         ; $6540  　(space)
    db $3F,$38,$35                 ; $6541  ひとつ
    db $EF,$EE                     ; $6544  newline
    db $90,$90                     ; $6546  　　(indent)
    db $25,$25,$2D,$38,$54         ; $6548  いいことを
    db $90                         ; $654D  　(space)
    db $28,$2F,$27,$43,$2F,$4D,$26 ; $654E  おしえましょう
    db $8F                         ; $6555  。
    db $FA                         ; $6556  wait-for-button
    db $F7                         ; $6557  clear page
    db $EF,$EE                     ; $6558  newline
    db $9F                         ; $655A  box tag
    db $96                         ; $655B  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D; $655C  たひ゛のとひ゛らの = たびのとびらの
    db $90                         ; $6565  　(space)
    db $45,$2D,$26,$37,$8D,$3E     ; $6566  むこうて゛は = むこうでは
    db $EF,$EE                     ; $656C  newline
    db $90,$90                     ; $656E  　　(indent)
    db $38,$2A,$38,$8D,$2A         ; $6570  ときと゛き = ときどき
    db $90                         ; $6575  　(space)
    db $2D,$41,$8D,$48,$47         ; $6576  こへ゛やも = こべやも
    db $90                         ; $657B  　(space)
    db $24,$36,$37                 ; $657C  あって
    db $A4                         ; $657F  、
    db $FA                         ; $6580  wait-for-button
    db $F7                         ; $6581  clear page
    db $EF,$EE                     ; $6582  newline
    db $9F                         ; $6584  box tag
    db $96                         ; $6585  end name/box tag
    db $32,$3D,$41,$48,$37,$8D,$3E ; $6586  そのへやて゛は = そのへやでは
    db $90                         ; $658D  　(space)
    db $42,$8D,$26,$2C,$55,$3D,$2F,$4D,$3A; $658E  ほ゛うけんのしょに = ぼうけんのしょに
    db $EF,$EE                     ; $6597  newline
    db $90,$90                     ; $6599  　　(indent)
    db $2A,$52,$2B,$37,$8D,$2A,$33,$4C,$26,$39; $659B  きろくて゛きたような = きろくできたような
    db $90                         ; $65A5  　(space)
    db $2A,$29,$8D,$2F,$43,$30     ; $65A6  きか゛します = きがします
    db $8F                         ; $65AC  。
    db $FA                         ; $65AD  wait-for-button
    db $F7                         ; $65AE  clear page
    db $EF,$EE                     ; $65AF  newline
    db $9F                         ; $65B1  box tag
    db $96                         ; $65B2  end name/box tag
    db $45,$2D,$26,$37,$8D,$3E     ; $65B3  むこうて゛は = むこうでは
    db $90                         ; $65B9  　(space)
    db $32,$2D,$37,$8D,$2F,$29     ; $65BA  そこて゛しか = そこでしか
    db $EF,$EE                     ; $65C0  newline
    db $90,$90                     ; $65C2  　　(indent)
    db $2A,$52,$2B,$37,$8D,$2A,$39,$29,$36,$33,$4C,$26,$39; $65C4  きろくて゛きなかったような = きろくできなかったような
    db $A4                         ; $65D1  、
    db $A4                         ; $65D2  、
    db $8F                         ; $65D3  。
    db $F7                         ; $65D4  clear page
    db $F0                         ; $65D5  end of message


; --------------------------------------------------------------------------
; Message #102 ($65D6)
;   「たびのとびらの　いちらんを
;   ごらんになりますか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg102:                               ; $65D6  (file $10A5D6)
    db $EA                         ; $65D6  ▶ new page
    db $9F                         ; $65D7  box tag
    db $96                         ; $65D8  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D; $65D9  たひ゛のとひ゛らの = たびのとびらの
    db $90                         ; $65E2  　(space)
    db $25,$34,$4E,$55,$54         ; $65E3  いちらんを
    db $EF,$EE                     ; $65E8  newline
    db $90,$90                     ; $65EA  　　(indent)
    db $2D,$8D,$4E,$55,$3A,$39,$4F,$43,$30,$29; $65EC  こ゛らんになりますか = ごらんになりますか
    db $98                         ; $65F6  ？
    db $FF                         ; $65F7  はい/いいえ
    db $F0                         ; $65F8  end of message


; --------------------------------------------------------------------------
; Message #103 ($65F9)
;   「とじたへやは　かくとうじょうで
;   かたなければ　はいれません。
;   「かつて　ほしふりのたいかいで
;   ゆうしょうした　マスターは、
;   「しあいで　かてないと　なんどでも
;   おなじ　たびのとびらにゆき、
;   「まものを　きたえたり　あたらしい
;   なかまを　ふやしていたそうです。
; --------------------------------------------------------------------------
Bank66_Msg103:                               ; $65F9  (file $10A5F9)
    db $EA                         ; $65F9  ▶ new page
    db $9F                         ; $65FA  box tag
    db $96                         ; $65FB  end name/box tag
    db $38,$2F,$8D,$33,$41,$48,$3E ; $65FC  とし゛たへやは = とじたへやは
    db $90                         ; $6603  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D; $6604  かくとうし゛ょうて゛ = かくとうじょうで
    db $EF,$EE                     ; $660E  newline
    db $90,$90                     ; $6610  　　(indent)
    db $29,$33,$39,$2C,$51,$3E,$8D ; $6612  かたなけれは゛ = かたなければ
    db $90                         ; $6619  　(space)
    db $3E,$25,$51,$43,$31,$55     ; $661A  はいれません
    db $8F                         ; $6620  。
    db $FA                         ; $6621  wait-for-button
    db $F7                         ; $6622  clear page
    db $EF,$EE                     ; $6623  newline
    db $9F                         ; $6625  box tag
    db $96                         ; $6626  end name/box tag
    db $29,$35,$37                 ; $6627  かつて
    db $90                         ; $662A  　(space)
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$37,$8D; $662B  ほしふりのたいかいて゛ = ほしふりのたいかいで
    db $EF,$EE                     ; $6636  newline
    db $90,$90                     ; $6638  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$33 ; $663A  ゆうしょうした
    db $90                         ; $6641  　(space)
    db $7A,$67,$6A,$9C,$3E         ; $6642  マスターは
    db $A4                         ; $6647  、
    db $FA                         ; $6648  wait-for-button
    db $F7                         ; $6649  clear page
    db $EF,$EE                     ; $664A  newline
    db $9F                         ; $664C  box tag
    db $96                         ; $664D  end name/box tag
    db $2F,$24,$25,$37,$8D         ; $664E  しあいて゛ = しあいで
    db $90                         ; $6653  　(space)
    db $29,$37,$39,$25,$38         ; $6654  かてないと
    db $90                         ; $6659  　(space)
    db $39,$55,$38,$8D,$37,$8D,$47 ; $665A  なんと゛て゛も = なんどでも
    db $EF,$EE                     ; $6661  newline
    db $90,$90                     ; $6663  　　(indent)
    db $28,$39,$2F,$8D             ; $6665  おなし゛ = おなじ
    db $90                         ; $6669  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A,$4A,$2A; $666A  たひ゛のとひ゛らにゆき = たびのとびらにゆき
    db $A4                         ; $6675  、
    db $FA                         ; $6676  wait-for-button
    db $F7                         ; $6677  clear page
    db $EF,$EE                     ; $6678  newline
    db $9F                         ; $667A  box tag
    db $96                         ; $667B  end name/box tag
    db $43,$47,$3D,$54             ; $667C  まものを
    db $90                         ; $6680  　(space)
    db $2A,$33,$27,$33,$4F         ; $6681  きたえたり
    db $90                         ; $6686  　(space)
    db $24,$33,$4E,$2F,$25         ; $6687  あたらしい
    db $EF,$EE                     ; $668C  newline
    db $90,$90                     ; $668E  　　(indent)
    db $39,$29,$43,$54             ; $6690  なかまを
    db $90                         ; $6694  　(space)
    db $40,$48,$2F,$37,$25,$33,$32,$26,$37,$8D,$30; $6695  ふやしていたそうて゛す = ふやしていたそうです
    db $8F                         ; $66A0  。
    db $F7                         ; $66A1  clear page
    db $F0                         ; $66A2  end of message


; --------------------------------------------------------------------------
; Message #104 ($66A3)
;   「まものにも　せいかくが
;   あります。
;   「えらんだ　さくせんによって
;   せいかくは　へんかするそうです。
;   「ガンガンいこうぜを　えらべば
;   ゆうかんな　まものに、
;   「いろいろやろうぜを　えらぶと
;   しりょぶかく、
;   「いのちをだいじにで　おもいやりが
;   ふかい　せいかくになります。
; --------------------------------------------------------------------------
Bank66_Msg104:                               ; $66A3  (file $10A6A3)
    db $EA                         ; $66A3  ▶ new page
    db $9F                         ; $66A4  box tag
    db $96                         ; $66A5  end name/box tag
    db $43,$47,$3D,$3A,$47         ; $66A6  まものにも
    db $90                         ; $66AB  　(space)
    db $31,$25,$29,$2B,$29,$8D     ; $66AC  せいかくか゛ = せいかくが
    db $EF,$EE                     ; $66B2  newline
    db $90,$90                     ; $66B4  　　(indent)
    db $24,$4F,$43,$30             ; $66B6  あります
    db $8F                         ; $66BA  。
    db $FA                         ; $66BB  wait-for-button
    db $F7                         ; $66BC  clear page
    db $EF,$EE                     ; $66BD  newline
    db $9F                         ; $66BF  box tag
    db $96                         ; $66C0  end name/box tag
    db $27,$4E,$55,$33,$8D         ; $66C1  えらんた゛ = えらんだ
    db $90                         ; $66C6  　(space)
    db $2E,$2B,$31,$55,$3A,$4C,$36,$37; $66C7  さくせんによって
    db $EF,$EE                     ; $66CF  newline
    db $90,$90                     ; $66D1  　　(indent)
    db $31,$25,$29,$2B,$3E         ; $66D3  せいかくは
    db $90                         ; $66D8  　(space)
    db $41,$55,$29,$30,$50,$32,$26,$37,$8D,$30; $66D9  へんかするそうて゛す = へんかするそうです
    db $8F                         ; $66E3  。
    db $FA                         ; $66E4  wait-for-button
    db $F7                         ; $66E5  clear page
    db $EF,$EE                     ; $66E6  newline
    db $9F                         ; $66E8  box tag
    db $96                         ; $66E9  end name/box tag
    db $60,$8D,$8C,$60,$8D,$8C,$25,$2D,$26,$31,$8D,$54; $66EA  カ゛ンカ゛ンいこうせ゛を = ガンガンいこうぜを
    db $90                         ; $66F6  　(space)
    db $27,$4E,$41,$8D,$3E,$8D     ; $66F7  えらへ゛は゛ = えらべば
    db $EF,$EE                     ; $66FD  newline
    db $90,$90                     ; $66FF  　　(indent)
    db $4A,$26,$29,$55,$39         ; $6701  ゆうかんな
    db $90                         ; $6706  　(space)
    db $43,$47,$3D,$3A             ; $6707  まものに
    db $A4                         ; $670B  、
    db $FA                         ; $670C  wait-for-button
    db $F7                         ; $670D  clear page
    db $EF,$EE                     ; $670E  newline
    db $9F                         ; $6710  box tag
    db $96                         ; $6711  end name/box tag
    db $25,$52,$25,$52,$48,$52,$26,$31,$8D,$54; $6712  いろいろやろうせ゛を = いろいろやろうぜを
    db $90                         ; $671C  　(space)
    db $27,$4E,$40,$8D,$38         ; $671D  えらふ゛と = えらぶと
    db $EF,$EE                     ; $6722  newline
    db $90,$90                     ; $6724  　　(indent)
    db $2F,$4F,$4D,$40,$8D,$29,$2B ; $6726  しりょふ゛かく = しりょぶかく
    db $A4                         ; $672D  、
    db $FA                         ; $672E  wait-for-button
    db $F7                         ; $672F  clear page
    db $EF,$EE                     ; $6730  newline
    db $9F                         ; $6732  box tag
    db $96                         ; $6733  end name/box tag
    db $25,$3D,$34,$54,$33,$8D,$25,$2F,$8D,$3A,$37,$8D; $6734  いのちをた゛いし゛にて゛ = いのちをだいじにで
    db $90                         ; $6740  　(space)
    db $28,$47,$25,$48,$4F,$29,$8D ; $6741  おもいやりか゛ = おもいやりが
    db $EF,$EE                     ; $6748  newline
    db $90,$90                     ; $674A  　　(indent)
    db $40,$29,$25                 ; $674C  ふかい
    db $90                         ; $674F  　(space)
    db $31,$25,$29,$2B,$3A,$39,$4F,$43,$30; $6750  せいかくになります
    db $8F                         ; $6759  。
    db $F7                         ; $675A  clear page
    db $F0                         ; $675B  end of message


; --------------------------------------------------------------------------
; Message #105 ($675C)
;   「マスターさんよ。
;   タマゴ　もっているか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank66_Msg105:                               ; $675C  (file $10A75C)
    db $EA                         ; $675C  ▶ new page
    db $9F                         ; $675D  box tag
    db $96                         ; $675E  end name/box tag
    db $7A,$67,$6A,$9C,$2E,$55,$4C ; $675F  マスターさんよ
    db $8F                         ; $6766  。
    db $EF,$EE                     ; $6767  newline
    db $90,$90                     ; $6769  　　(indent)
    db $6A,$7A,$64,$8D             ; $676B  タマコ゛ = タマゴ
    db $90                         ; $676F  　(space)
    db $47,$36,$37,$25,$50,$29     ; $6770  もっているか
    db $98                         ; $6776  ？
    db $FF                         ; $6777  はい/いいえ
    db $F0                         ; $6778  end of message


; --------------------------------------------------------------------------
; Message #106 ($6779)
;   ぺちゃ　、、。
;   フンが　〈テリー〉に　あたった。
; --------------------------------------------------------------------------
Bank66_Msg106:                               ; $6779  (file $10A779)
    db $41,$8E,$34,$49             ; $6779  へ゜ちゃ = ぺちゃ
    db $90                         ; $677D  　(space)
    db $A4                         ; $677E  、
    db $A4                         ; $677F  、
    db $8F                         ; $6780  。
    db $EF,$EE                     ; $6781  newline
    db $77,$8C,$29,$8D             ; $6783  フンか゛ = フンが
    db $90                         ; $6787  　(space)
    db $F6                         ; $6788  «insert hero name» (テリー)
    db $3A                         ; $6789  に
    db $90                         ; $678A  　(space)
    db $24,$33,$36,$33             ; $678B  あたった
    db $8F                         ; $678F  。
    db $F7                         ; $6790  clear page
    db $F0                         ; $6791  end of message


; --------------------------------------------------------------------------
; Message #107 ($6792)
;   スコーン！
;   〈テリー〉にあたったのは　なんと
;   スカィドラゴンの　タマゴだった！！
; --------------------------------------------------------------------------
Bank66_Msg107:                               ; $6792  (file $10A792)
    db $67,$64,$9C,$8C             ; $6792  スコーン
    db $99                         ; $6796  ！
    db $EF,$EE                     ; $6797  newline
    db $FA                         ; $6799  wait-for-button
    db $F7                         ; $679A  clear page
    db $EF,$EE                     ; $679B  newline
    db $F3                         ; $679D  open text box
    db $F6                         ; $679E  «insert hero name» (テリー)
    db $3A,$24,$33,$36,$33,$3D,$3E ; $679F  にあたったのは
    db $90                         ; $67A6  　(space)
    db $39,$55,$38                 ; $67A7  なんと
    db $EF,$EE                     ; $67AA  newline
    db $67,$60,$58,$6F,$8D,$85,$64,$8D,$8C,$3D; $67AC  スカィト゛ラコ゛ンの = スカィドラゴンの
    db $90                         ; $67B6  　(space)
    db $6A,$7A,$64,$8D,$33,$8D,$36,$33; $67B7  タマコ゛た゛った = タマゴだった
    db $99                         ; $67BF  ！
    db $99                         ; $67C0  ！
    db $FA                         ; $67C1  wait-for-button
    db $F7                         ; $67C2  clear page
    db $F0                         ; $67C3  end of message


; --------------------------------------------------------------------------
; Message #108 ($67C4)
;   〈テリー〉は　スカィドラゴンの
;   タマゴを　てにいれた！
;   しかし　タマゴを　つれては
;   あるけません。
;   タマゴは　ぼくじょうがかりの
;   プリォに　あずけられた！
; --------------------------------------------------------------------------
Bank66_Msg108:                               ; $67C4  (file $10A7C4)
    db $F6                         ; $67C4  «insert hero name» (テリー)
    db $3E                         ; $67C5  は
    db $90                         ; $67C6  　(space)
    db $67,$60,$58,$6F,$8D,$85,$64,$8D,$8C,$3D; $67C7  スカィト゛ラコ゛ンの = スカィドラゴンの
    db $EF,$EE                     ; $67D1  newline
    db $6A,$7A,$64,$8D,$54         ; $67D3  タマコ゛を = タマゴを
    db $90                         ; $67D8  　(space)
    db $37,$3A,$25,$51,$33         ; $67D9  てにいれた
    db $99                         ; $67DE  ！
    db $FA                         ; $67DF  wait-for-button
    db $F7                         ; $67E0  clear page
    db $EF,$EE                     ; $67E1  newline
    db $2F,$29,$2F                 ; $67E3  しかし
    db $90                         ; $67E6  　(space)
    db $6A,$7A,$64,$8D,$54         ; $67E7  タマコ゛を = タマゴを
    db $90                         ; $67EC  　(space)
    db $35,$51,$37,$3E             ; $67ED  つれては
    db $EF,$EE                     ; $67F1  newline
    db $24,$50,$2C,$43,$31,$55     ; $67F3  あるけません
    db $8F                         ; $67F9  。
    db $FA                         ; $67FA  wait-for-button
    db $F7                         ; $67FB  clear page
    db $EF,$EE                     ; $67FC  newline
    db $6A,$7A,$64,$8D,$3E         ; $67FE  タマコ゛は = タマゴは
    db $90                         ; $6803  　(space)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$29,$8D,$29,$4F,$3D; $6804  ほ゛くし゛ょうか゛かりの = ぼくじょうがかりの
    db $EF,$EE                     ; $6810  newline
    db $77,$8E,$86,$5E,$3A         ; $6812  フ゜リォに = プリォに
    db $90                         ; $6817  　(space)
    db $24,$30,$8D,$2C,$4E,$51,$33 ; $6818  あす゛けられた = あずけられた
    db $99                         ; $681F  ！
    db $F7                         ; $6820  clear page
    db $F0                         ; $6821  end of message


; --------------------------------------------------------------------------
; Message #109 ($6822)
;   しかし　なかまが　いっぱいで
;   タマゴは　てにはいらなかった！
;   タマゴは　つれてゆけないので
;   ぼくじょうに　ほかんされます。
;   なかまのかずに　よゆうを
;   つくってから　きましょう。
; --------------------------------------------------------------------------
Bank66_Msg109:                               ; $6822  (file $10A822)
    db $2F,$29,$2F                 ; $6822  しかし
    db $90                         ; $6825  　(space)
    db $39,$29,$43,$29,$8D         ; $6826  なかまか゛ = なかまが
    db $90                         ; $682B  　(space)
    db $25,$36,$3E,$8E,$25,$37,$8D ; $682C  いっは゜いて゛ = いっぱいで
    db $EF,$EE                     ; $6833  newline
    db $6A,$7A,$64,$8D,$3E         ; $6835  タマコ゛は = タマゴは
    db $90                         ; $683A  　(space)
    db $37,$3A,$3E,$25,$4E,$39,$29,$36,$33; $683B  てにはいらなかった
    db $99                         ; $6844  ！
    db $FA                         ; $6845  wait-for-button
    db $F7                         ; $6846  clear page
    db $EF,$EE                     ; $6847  newline
    db $6A,$7A,$64,$8D,$3E         ; $6849  タマコ゛は = タマゴは
    db $90                         ; $684E  　(space)
    db $35,$51,$37,$4A,$2C,$39,$25,$3D,$37,$8D; $684F  つれてゆけないのて゛ = つれてゆけないので
    db $EF,$EE                     ; $6859  newline
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $685B  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $6863  　(space)
    db $42,$29,$55,$2E,$51,$43,$30 ; $6864  ほかんされます
    db $8F                         ; $686B  。
    db $FA                         ; $686C  wait-for-button
    db $F7                         ; $686D  clear page
    db $EF,$EE                     ; $686E  newline
    db $39,$29,$43,$3D,$29,$30,$8D,$3A; $6870  なかまのかす゛に = なかまのかずに
    db $90                         ; $6878  　(space)
    db $4C,$4A,$26,$54             ; $6879  よゆうを
    db $EF,$EE                     ; $687D  newline
    db $35,$2B,$36,$37,$29,$4E     ; $687F  つくってから
    db $90                         ; $6885  　(space)
    db $2A,$43,$2F,$4D,$26         ; $6886  きましょう
    db $8F                         ; $688B  。
    db $F7                         ; $688C  clear page
    db $F0                         ; $688D  end of message


; --------------------------------------------------------------------------
; Message #110 ($688E)
;   ぐちょっ　、、。
;   フンが　〈テリー〉に　あたった。
; --------------------------------------------------------------------------
Bank66_Msg110:                               ; $688E  (file $10A88E)
    db $2B,$8D,$34,$4D,$36         ; $688E  く゛ちょっ = ぐちょっ
    db $90                         ; $6893  　(space)
    db $A4                         ; $6894  、
    db $A4                         ; $6895  、
    db $8F                         ; $6896  。
    db $EF,$EE                     ; $6897  newline
    db $77,$8C,$29,$8D             ; $6899  フンか゛ = フンが
    db $90                         ; $689D  　(space)
    db $F6                         ; $689E  «insert hero name» (テリー)
    db $3A                         ; $689F  に
    db $90                         ; $68A0  　(space)
    db $24,$33,$36,$33             ; $68A1  あたった
    db $8F                         ; $68A5  。
    db $F7                         ; $68A6  clear page
    db $F0                         ; $68A7  end of message


; --------------------------------------------------------------------------
; Message #111 ($68A8)
;   「おにくのしゅるい！　まもののェサ
;   くんせいにく　ほねつきにく。
;   「いちばん　おいしくないのは
;   まもののェサ！
;   「くんせいにくより　ほねつきにくの
;   ほうが　おいしいんだ。
;   「でも　いっちばん　おいしいのは
;   しもふりにく！　ほっぺがおちる！
; --------------------------------------------------------------------------
Bank66_Msg111:                               ; $68A8  (file $10A8A8)
    db $EA                         ; $68A8  ▶ new page
    db $9F                         ; $68A9  box tag
    db $96                         ; $68AA  end name/box tag
    db $28,$3A,$2B,$3D,$2F,$4B,$50,$25; $68AB  おにくのしゅるい
    db $99                         ; $68B3  ！
    db $90                         ; $68B4  　(space)
    db $43,$47,$3D,$3D,$5C,$65     ; $68B5  まもののェサ
    db $EF,$EE                     ; $68BB  newline
    db $90,$90                     ; $68BD  　　(indent)
    db $2B,$55,$31,$25,$3A,$2B     ; $68BF  くんせいにく
    db $90                         ; $68C5  　(space)
    db $42,$3C,$35,$2A,$3A,$2B     ; $68C6  ほねつきにく
    db $8F                         ; $68CC  。
    db $FA                         ; $68CD  wait-for-button
    db $F7                         ; $68CE  clear page
    db $EF,$EE                     ; $68CF  newline
    db $9F                         ; $68D1  box tag
    db $96                         ; $68D2  end name/box tag
    db $25,$34,$3E,$8D,$55         ; $68D3  いちは゛ん = いちばん
    db $90                         ; $68D8  　(space)
    db $28,$25,$2F,$2B,$39,$25,$3D,$3E; $68D9  おいしくないのは
    db $EF,$EE                     ; $68E1  newline
    db $90,$90                     ; $68E3  　　(indent)
    db $43,$47,$3D,$3D,$5C,$65     ; $68E5  まもののェサ
    db $99                         ; $68EB  ！
    db $FA                         ; $68EC  wait-for-button
    db $F7                         ; $68ED  clear page
    db $EF,$EE                     ; $68EE  newline
    db $9F                         ; $68F0  box tag
    db $96                         ; $68F1  end name/box tag
    db $2B,$55,$31,$25,$3A,$2B,$4C,$4F; $68F2  くんせいにくより
    db $90                         ; $68FA  　(space)
    db $42,$3C,$35,$2A,$3A,$2B,$3D ; $68FB  ほねつきにくの
    db $EF,$EE                     ; $6902  newline
    db $90,$90                     ; $6904  　　(indent)
    db $42,$26,$29,$8D             ; $6906  ほうか゛ = ほうが
    db $90                         ; $690A  　(space)
    db $28,$25,$2F,$25,$55,$33,$8D ; $690B  おいしいんた゛ = おいしいんだ
    db $8F                         ; $6912  。
    db $FA                         ; $6913  wait-for-button
    db $F7                         ; $6914  clear page
    db $EF,$EE                     ; $6915  newline
    db $9F                         ; $6917  box tag
    db $96                         ; $6918  end name/box tag
    db $37,$8D,$47                 ; $6919  て゛も = でも
    db $90                         ; $691C  　(space)
    db $25,$36,$34,$3E,$8D,$55     ; $691D  いっちは゛ん = いっちばん
    db $90                         ; $6923  　(space)
    db $28,$25,$2F,$25,$3D,$3E     ; $6924  おいしいのは
    db $EF,$EE                     ; $692A  newline
    db $90,$90                     ; $692C  　　(indent)
    db $2F,$47,$40,$4F,$3A,$2B     ; $692E  しもふりにく
    db $99                         ; $6934  ！
    db $90                         ; $6935  　(space)
    db $42,$36,$41,$8E,$29,$8D,$28,$34,$50; $6936  ほっへ゜か゛おちる = ほっぺがおちる
    db $99                         ; $693F  ！
    db $F7                         ; $6940  clear page
    db $F0                         ; $6941  end of message


; --------------------------------------------------------------------------
; Message #112 ($6942)
;   「まものは　ぼうけんにつれていって
;   もらえると　マスターになつくよ。
;   「ぎゃくに　あずけられっぱなしだと
;   いうことを　きかなくなるんだ。
;   「けど　おにくを　くれたら
;   とーっても　なついちゃうよ！
; --------------------------------------------------------------------------
Bank66_Msg112:                               ; $6942  (file $10A942)
    db $EA                         ; $6942  ▶ new page
    db $9F                         ; $6943  box tag
    db $96                         ; $6944  end name/box tag
    db $43,$47,$3D,$3E             ; $6945  まものは
    db $90                         ; $6949  　(space)
    db $42,$8D,$26,$2C,$55,$3A,$35,$51,$37,$25,$36,$37; $694A  ほ゛うけんにつれていって = ぼうけんにつれていって
    db $EF,$EE                     ; $6956  newline
    db $90,$90                     ; $6958  　　(indent)
    db $47,$4E,$27,$50,$38         ; $695A  もらえると
    db $90                         ; $695F  　(space)
    db $7A,$67,$6A,$9C,$3A,$39,$35,$2B,$4C; $6960  マスターになつくよ
    db $8F                         ; $6969  。
    db $FA                         ; $696A  wait-for-button
    db $F7                         ; $696B  clear page
    db $EF,$EE                     ; $696C  newline
    db $9F                         ; $696E  box tag
    db $96                         ; $696F  end name/box tag
    db $2A,$8D,$49,$2B,$3A         ; $6970  き゛ゃくに = ぎゃくに
    db $90                         ; $6975  　(space)
    db $24,$30,$8D,$2C,$4E,$51,$36,$3E,$8E,$39,$2F,$33,$8D,$38; $6976  あす゛けられっは゜なした゛と = あずけられっぱなしだと
    db $EF,$EE                     ; $6984  newline
    db $90,$90                     ; $6986  　　(indent)
    db $25,$26,$2D,$38,$54         ; $6988  いうことを
    db $90                         ; $698D  　(space)
    db $2A,$29,$39,$2B,$39,$50,$55,$33,$8D; $698E  きかなくなるんた゛ = きかなくなるんだ
    db $8F                         ; $6997  。
    db $FA                         ; $6998  wait-for-button
    db $F7                         ; $6999  clear page
    db $EF,$EE                     ; $699A  newline
    db $9F                         ; $699C  box tag
    db $96                         ; $699D  end name/box tag
    db $2C,$38,$8D                 ; $699E  けと゛ = けど
    db $90                         ; $69A1  　(space)
    db $28,$3A,$2B,$54             ; $69A2  おにくを
    db $90                         ; $69A6  　(space)
    db $2B,$51,$33,$4E             ; $69A7  くれたら
    db $EF,$EE                     ; $69AB  newline
    db $90,$90                     ; $69AD  　　(indent)
    db $38,$9C,$36,$37,$47         ; $69AF  とーっても
    db $90                         ; $69B4  　(space)
    db $39,$35,$25,$34,$49,$26,$4C ; $69B5  なついちゃうよ
    db $99                         ; $69BC  ！
    db $F7                         ; $69BD  clear page
    db $F0                         ; $69BE  end of message


; --------------------------------------------------------------------------
; Message #113 ($69BF)
;   「よっ！
;   プリォが　よろこんでたぜ。
; --------------------------------------------------------------------------
Bank66_Msg113:                               ; $69BF  (file $10A9BF)
    db $EA                         ; $69BF  ▶ new page
    db $9F                         ; $69C0  box tag
    db $96                         ; $69C1  end name/box tag
    db $4C,$36                     ; $69C2  よっ
    db $99                         ; $69C4  ！
    db $EF,$EE                     ; $69C5  newline
    db $90,$90                     ; $69C7  　　(indent)
    db $77,$8E,$86,$5E,$29,$8D     ; $69C9  フ゜リォか゛ = プリォが
    db $90                         ; $69CF  　(space)
    db $4C,$52,$2D,$55,$37,$8D,$33,$31,$8D; $69D0  よろこんて゛たせ゛ = よろこんでたぜ
    db $8F                         ; $69D9  。
    db $F7                         ; $69DA  clear page
    db $F0                         ; $69DB  end of message


; --------------------------------------------------------------------------
; Message #114 ($69DC)
;   プリォ「ありがとう　〈テリー〉！
;   おかげで　たすかっただ！
;   プリォ「おれいに　いいこと
;   〈テリー〉に　おしえるだ。
;   プリォ「ぼくじょうのうえに
;   スカィドラゴンが　とんでるから、
;   プリォ「そのしたで　まっていると
;   きっと　いいこと　おこるはずだ！
;   プリォ「これからは　どんどん
;   ぼくじょうを　つかってくれよ！
;   プリォ「さあ　なにするだ？
; --------------------------------------------------------------------------
Bank66_Msg114:                               ; $69DC  (file $10A9DC)
    db $EB                         ; $69DC  ▶ new page
    db $77,$8E,$86,$5E             ; $69DD  フ゜リォ  (speaker: プリォ)
    db $96                         ; $69E1  end name/box tag
    db $24,$4F,$29,$8D,$38,$26     ; $69E2  ありか゛とう = ありがとう
    db $90                         ; $69E8  　(space)
    db $F6                         ; $69E9  «insert hero name» (テリー)
    db $99                         ; $69EA  ！
    db $EF,$EE                     ; $69EB  newline
    db $90,$90                     ; $69ED  　　(indent)
    db $28,$29,$2C,$8D,$37,$8D     ; $69EF  おかけ゛て゛ = おかげで
    db $90                         ; $69F5  　(space)
    db $33,$30,$29,$36,$33,$33,$8D ; $69F6  たすかったた゛ = たすかっただ
    db $99                         ; $69FD  ！
    db $FA                         ; $69FE  wait-for-button
    db $F7                         ; $69FF  clear page
    db $EF,$EE                     ; $6A00  newline
    db $77,$8E,$86,$5E             ; $6A02  フ゜リォ  (speaker: プリォ)
    db $96                         ; $6A06  end name/box tag
    db $28,$51,$25,$3A             ; $6A07  おれいに
    db $90                         ; $6A0B  　(space)
    db $25,$25,$2D,$38             ; $6A0C  いいこと
    db $EF,$EE                     ; $6A10  newline
    db $90,$90                     ; $6A12  　　(indent)
    db $F6                         ; $6A14  «insert hero name» (テリー)
    db $3A                         ; $6A15  に
    db $90                         ; $6A16  　(space)
    db $28,$2F,$27,$50,$33,$8D     ; $6A17  おしえるた゛ = おしえるだ
    db $8F                         ; $6A1D  。
    db $FA                         ; $6A1E  wait-for-button
    db $F7                         ; $6A1F  clear page
    db $EF,$EE                     ; $6A20  newline
    db $77,$8E,$86,$5E             ; $6A22  フ゜リォ  (speaker: プリォ)
    db $96                         ; $6A26  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3D,$26,$27,$3A; $6A27  ほ゛くし゛ょうのうえに = ぼくじょうのうえに
    db $EF,$EE                     ; $6A32  newline
    db $90,$90                     ; $6A34  　　(indent)
    db $67,$60,$58,$6F,$8D,$85,$64,$8D,$8C,$29,$8D; $6A36  スカィト゛ラコ゛ンか゛ = スカィドラゴンが
    db $90                         ; $6A41  　(space)
    db $38,$55,$37,$8D,$50,$29,$4E ; $6A42  とんて゛るから = とんでるから
    db $A4                         ; $6A49  、
    db $FA                         ; $6A4A  wait-for-button
    db $F7                         ; $6A4B  clear page
    db $EF,$EE                     ; $6A4C  newline
    db $77,$8E,$86,$5E             ; $6A4E  フ゜リォ  (speaker: プリォ)
    db $96                         ; $6A52  end name/box tag
    db $32,$3D,$2F,$33,$37,$8D     ; $6A53  そのしたて゛ = そのしたで
    db $90                         ; $6A59  　(space)
    db $43,$36,$37,$25,$50,$38     ; $6A5A  まっていると
    db $EF,$EE                     ; $6A60  newline
    db $90,$90                     ; $6A62  　　(indent)
    db $2A,$36,$38                 ; $6A64  きっと
    db $90                         ; $6A67  　(space)
    db $25,$25,$2D,$38             ; $6A68  いいこと
    db $90                         ; $6A6C  　(space)
    db $28,$2D,$50,$3E,$30,$8D,$33,$8D; $6A6D  おこるはす゛た゛ = おこるはずだ
    db $99                         ; $6A75  ！
    db $FA                         ; $6A76  wait-for-button
    db $F7                         ; $6A77  clear page
    db $EF,$EE                     ; $6A78  newline
    db $77,$8E,$86,$5E             ; $6A7A  フ゜リォ  (speaker: プリォ)
    db $96                         ; $6A7E  end name/box tag
    db $2D,$51,$29,$4E,$3E         ; $6A7F  これからは
    db $90                         ; $6A84  　(space)
    db $38,$8D,$55,$38,$8D,$55     ; $6A85  と゛んと゛ん = どんどん
    db $EF,$EE                     ; $6A8B  newline
    db $90,$90                     ; $6A8D  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$54; $6A8F  ほ゛くし゛ょうを = ぼくじょうを
    db $90                         ; $6A97  　(space)
    db $35,$29,$36,$37,$2B,$51,$4C ; $6A98  つかってくれよ
    db $99                         ; $6A9F  ！
    db $FA                         ; $6AA0  wait-for-button
    db $F7                         ; $6AA1  clear page
    db $EF,$EE                     ; $6AA2  newline
    db $77,$8E,$86,$5E             ; $6AA4  フ゜リォ  (speaker: プリォ)
    db $96                         ; $6AA8  end name/box tag
    db $2E,$24                     ; $6AA9  さあ
    db $90                         ; $6AAB  　(space)
    db $39,$3A,$30,$50,$33,$8D     ; $6AAC  なにするた゛ = なにするだ
    db $98                         ; $6AB2  ？
    db $EF,$EE                     ; $6AB3  newline
    db $F0                         ; $6AB5  end of message


; --------------------------------------------------------------------------
; Message #115 ($6AB6)
;   「ここは　モンスター
;   ぼくじょうだよ。
;   「スカィドラゴンさんの　したに
;   いくと　なにかおちてくるよ！
; --------------------------------------------------------------------------
Bank66_Msg115:                               ; $6AB6  (file $10AAB6)
    db $EB                         ; $6AB6  ▶ new page
    db $9F                         ; $6AB7  box tag
    db $96                         ; $6AB8  end name/box tag
    db $2D,$2D,$3E                 ; $6AB9  ここは
    db $90                         ; $6ABC  　(space)
    db $7E,$8C,$67,$6A,$9C         ; $6ABD  モンスター
    db $EF,$EE                     ; $6AC2  newline
    db $90,$90                     ; $6AC4  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$33,$8D,$4C; $6AC6  ほ゛くし゛ょうた゛よ = ぼくじょうだよ
    db $8F                         ; $6AD0  。
    db $FA                         ; $6AD1  wait-for-button
    db $F7                         ; $6AD2  clear page
    db $EF,$EE                     ; $6AD3  newline
    db $9F                         ; $6AD5  box tag
    db $96                         ; $6AD6  end name/box tag
    db $67,$60,$58,$6F,$8D,$85,$64,$8D,$8C,$2E,$55,$3D; $6AD7  スカィト゛ラコ゛ンさんの = スカィドラゴンさんの
    db $90                         ; $6AE3  　(space)
    db $2F,$33,$3A                 ; $6AE4  したに
    db $EF,$EE                     ; $6AE7  newline
    db $90,$90                     ; $6AE9  　　(indent)
    db $25,$2B,$38                 ; $6AEB  いくと
    db $90                         ; $6AEE  　(space)
    db $39,$3A,$29,$28,$34,$37,$2B,$50,$4C; $6AEF  なにかおちてくるよ
    db $99                         ; $6AF8  ！
    db $F7                         ; $6AF9  clear page
    db $F0                         ; $6AFA  end of message


; --------------------------------------------------------------------------
; Message #116 ($6AFB)
;   「わしのように　としをとるとな
;   レベルが　あがらなくなるんじゃ。
;   「せいちょうの　げんかいに
;   きてしまったんじゃのう、！
; --------------------------------------------------------------------------
Bank66_Msg116:                               ; $6AFB  (file $10AAFB)
    db $EB                         ; $6AFB  ▶ new page
    db $9F                         ; $6AFC  box tag
    db $96                         ; $6AFD  end name/box tag
    db $53,$2F,$3D,$4C,$26,$3A     ; $6AFE  わしのように
    db $90                         ; $6B04  　(space)
    db $38,$2F,$54,$38,$50,$38,$39 ; $6B05  としをとるとな
    db $EF,$EE                     ; $6B0C  newline
    db $90,$90                     ; $6B0E  　　(indent)
    db $88,$78,$8D,$87,$29,$8D     ; $6B10  レヘ゛ルか゛ = レベルが
    db $90                         ; $6B16  　(space)
    db $24,$29,$8D,$4E,$39,$2B,$39,$50,$55,$2F,$8D,$49; $6B17  あか゛らなくなるんし゛ゃ = あがらなくなるんじゃ
    db $8F                         ; $6B23  。
    db $FA                         ; $6B24  wait-for-button
    db $F7                         ; $6B25  clear page
    db $EF,$EE                     ; $6B26  newline
    db $9F                         ; $6B28  box tag
    db $96                         ; $6B29  end name/box tag
    db $31,$25,$34,$4D,$26,$3D     ; $6B2A  せいちょうの
    db $90                         ; $6B30  　(space)
    db $2C,$8D,$55,$29,$25,$3A     ; $6B31  け゛んかいに = げんかいに
    db $EF,$EE                     ; $6B37  newline
    db $90,$90                     ; $6B39  　　(indent)
    db $2A,$37,$2F,$43,$36,$33,$55,$2F,$8D,$49,$3D,$26; $6B3B  きてしまったんし゛ゃのう = きてしまったんじゃのう
    db $A4                         ; $6B47  、
    db $99                         ; $6B48  ！
    db $F7                         ; $6B49  clear page
    db $F0                         ; $6B4A  end of message


; --------------------------------------------------------------------------
; Message #117 ($6B4B)
;   「わたしは　みんなをまもり　かつ
;   こうげきを　ほじょし　でも、
;   「てきに　こうげきもする。
;   、、そんな　まものになりたい。
; --------------------------------------------------------------------------
Bank66_Msg117:                               ; $6B4B  (file $10AB4B)
    db $EA                         ; $6B4B  ▶ new page
    db $9F                         ; $6B4C  box tag
    db $96                         ; $6B4D  end name/box tag
    db $53,$33,$2F,$3E             ; $6B4E  わたしは
    db $90                         ; $6B52  　(space)
    db $44,$55,$39,$54,$43,$47,$4F ; $6B53  みんなをまもり
    db $90                         ; $6B5A  　(space)
    db $29,$35                     ; $6B5B  かつ
    db $EF,$EE                     ; $6B5D  newline
    db $90,$90                     ; $6B5F  　　(indent)
    db $2D,$26,$2C,$8D,$2A,$54     ; $6B61  こうけ゛きを = こうげきを
    db $90                         ; $6B67  　(space)
    db $42,$2F,$8D,$4D,$2F         ; $6B68  ほし゛ょし = ほじょし
    db $90                         ; $6B6D  　(space)
    db $37,$8D,$47                 ; $6B6E  て゛も = でも
    db $A4                         ; $6B71  、
    db $FA                         ; $6B72  wait-for-button
    db $F7                         ; $6B73  clear page
    db $EF,$EE                     ; $6B74  newline
    db $9F                         ; $6B76  box tag
    db $96                         ; $6B77  end name/box tag
    db $37,$2A,$3A                 ; $6B78  てきに
    db $90                         ; $6B7B  　(space)
    db $2D,$26,$2C,$8D,$2A,$47,$30,$50; $6B7C  こうけ゛きもする = こうげきもする
    db $8F                         ; $6B84  。
    db $EF,$EE                     ; $6B85  newline
    db $90,$90                     ; $6B87  　　(indent)
    db $A4                         ; $6B89  、
    db $A4                         ; $6B8A  、
    db $32,$55,$39                 ; $6B8B  そんな
    db $90                         ; $6B8E  　(space)
    db $43,$47,$3D,$3A,$39,$4F,$33,$25; $6B8F  まものになりたい
    db $8F                         ; $6B97  。
    db $F7                         ; $6B98  clear page
    db $F0                         ; $6B99  end of message


; --------------------------------------------------------------------------
; Message #118 ($6B9A)
;   「フンガー！
;   「〈テリー〉さん！
;   ごあんしんを！！
; --------------------------------------------------------------------------
Bank66_Msg118:                               ; $6B9A  (file $10AB9A)
    db $EA                         ; $6B9A  ▶ new page
    db $9F                         ; $6B9B  box tag
    db $96                         ; $6B9C  end name/box tag
    db $77,$8C,$60,$8D,$9C         ; $6B9D  フンカ゛ー = フンガー
    db $99                         ; $6BA2  ！
    db $EF,$EE                     ; $6BA3  newline
    db $FA                         ; $6BA5  wait-for-button
    db $F7                         ; $6BA6  clear page
    db $EF,$EE                     ; $6BA7  newline
    db $F3                         ; $6BA9  open text box
    db $9F                         ; $6BAA  box tag
    db $96                         ; $6BAB  end name/box tag
    db $F6                         ; $6BAC  «insert hero name» (テリー)
    db $2E,$55                     ; $6BAD  さん
    db $99                         ; $6BAF  ！
    db $EF,$EE                     ; $6BB0  newline
    db $90,$90                     ; $6BB2  　　(indent)
    db $2D,$8D,$24,$55,$2F,$55,$54 ; $6BB4  こ゛あんしんを = ごあんしんを
    db $99                         ; $6BBB  ！
    db $99                         ; $6BBC  ！
    db $F7                         ; $6BBD  clear page
    db $F0                         ; $6BBE  end of message


; --------------------------------------------------------------------------
; Message #119 ($6BBF)
;   「フハハハハハ、、！！
;   「ま[9B]か[9B]せ　なさい！
; --------------------------------------------------------------------------
Bank66_Msg119:                               ; $6BBF  (file $10ABBF)
    db $EA                         ; $6BBF  ▶ new page
    db $9F                         ; $6BC0  box tag
    db $96                         ; $6BC1  end name/box tag
    db $77,$75,$75,$75,$75,$75     ; $6BC2  フハハハハハ
    db $A4                         ; $6BC8  、
    db $A4                         ; $6BC9  、
    db $99                         ; $6BCA  ！
    db $99                         ; $6BCB  ！
    db $EF,$EE                     ; $6BCC  newline
    db $FA                         ; $6BCE  wait-for-button
    db $F7                         ; $6BCF  clear page
    db $EF,$EE                     ; $6BD0  newline
    db $F3                         ; $6BD2  open text box
    db $9F                         ; $6BD3  box tag
    db $96                         ; $6BD4  end name/box tag
    db $43                         ; $6BD5  ま
    db $9B                         ; $6BD6  ctrl $9B
    db $29                         ; $6BD7  か
    db $9B                         ; $6BD8  ctrl $9B
    db $31                         ; $6BD9  せ
    db $90                         ; $6BDA  　(space)
    db $39,$2E,$25                 ; $6BDB  なさい
    db $99                         ; $6BDE  ！
    db $EF,$EE                     ; $6BDF  newline
    db $F7                         ; $6BE1  clear page
    db $F0                         ; $6BE2  end of message


; --------------------------------------------------------------------------
; Message #120 ($6BE3)
;   「〈テリー〉よ！　わたしと　ともに
;   せかいを　てにいれようぞ[95][95]！！
; --------------------------------------------------------------------------
Bank66_Msg120:                               ; $6BE3  (file $10ABE3)
    db $EA                         ; $6BE3  ▶ new page
    db $9F                         ; $6BE4  box tag
    db $96                         ; $6BE5  end name/box tag
    db $F6                         ; $6BE6  «insert hero name» (テリー)
    db $4C                         ; $6BE7  よ
    db $99                         ; $6BE8  ！
    db $90                         ; $6BE9  　(space)
    db $53,$33,$2F,$38             ; $6BEA  わたしと
    db $90                         ; $6BEE  　(space)
    db $38,$47,$3A                 ; $6BEF  ともに
    db $EF,$EE                     ; $6BF2  newline
    db $90,$90                     ; $6BF4  　　(indent)
    db $31,$29,$25,$54             ; $6BF6  せかいを
    db $90                         ; $6BFA  　(space)
    db $37,$3A,$25,$51,$4C,$26,$32,$8D; $6BFB  てにいれようそ゛ = てにいれようぞ
    db $95                         ; $6C03  ctrl $95
    db $95                         ; $6C04  ctrl $95
    db $99                         ; $6C05  ！
    db $99                         ; $6C06  ！
    db $F7                         ; $6C07  clear page
    db $F0                         ; $6C08  end of message


; --------------------------------------------------------------------------
; Message #121 ($6C09)
;   「こまけえ　ことなぞ
;   かんけいなしじゃあ！
; --------------------------------------------------------------------------
Bank66_Msg121:                               ; $6C09  (file $10AC09)
    db $EA                         ; $6C09  ▶ new page
    db $9F                         ; $6C0A  box tag
    db $96                         ; $6C0B  end name/box tag
    db $2D,$43,$2C,$27             ; $6C0C  こまけえ
    db $90                         ; $6C10  　(space)
    db $2D,$38,$39,$32,$8D         ; $6C11  ことなそ゛ = ことなぞ
    db $EF,$EE                     ; $6C16  newline
    db $90,$90                     ; $6C18  　　(indent)
    db $29,$55,$2C,$25,$39,$2F,$2F,$8D,$49,$24; $6C1A  かんけいなしし゛ゃあ = かんけいなしじゃあ
    db $99                         ; $6C24  ！
    db $F7                         ; $6C25  clear page
    db $F0                         ; $6C26  end of message


; --------------------------------------------------------------------------
; Message #122 ($6C27)
;   「おりゃあ！
;   「こざかしい　こざいくなど
;   めんどうじゃわ[9D]！！
; --------------------------------------------------------------------------
Bank66_Msg122:                               ; $6C27  (file $10AC27)
    db $EA                         ; $6C27  ▶ new page
    db $9F                         ; $6C28  box tag
    db $96                         ; $6C29  end name/box tag
    db $28,$4F,$49,$24             ; $6C2A  おりゃあ
    db $99                         ; $6C2E  ！
    db $EF,$EE                     ; $6C2F  newline
    db $FA                         ; $6C31  wait-for-button
    db $F7                         ; $6C32  clear page
    db $EF,$EE                     ; $6C33  newline
    db $F3                         ; $6C35  open text box
    db $9F                         ; $6C36  box tag
    db $96                         ; $6C37  end name/box tag
    db $2D,$2E,$8D,$29,$2F,$25     ; $6C38  こさ゛かしい = こざかしい
    db $90                         ; $6C3E  　(space)
    db $2D,$2E,$8D,$25,$2B,$39,$38,$8D; $6C3F  こさ゛いくなと゛ = こざいくなど
    db $EF,$EE                     ; $6C47  newline
    db $90,$90                     ; $6C49  　　(indent)
    db $46,$55,$38,$8D,$26,$2F,$8D,$49,$53; $6C4B  めんと゛うし゛ゃわ = めんどうじゃわ
    db $9D                         ; $6C54  ctrl $9D
    db $99                         ; $6C55  ！
    db $99                         ; $6C56  ！
    db $F7                         ; $6C57  clear page
    db $F0                         ; $6C58  end of message


; --------------------------------------------------------------------------
; Message #123 ($6C59)
;   「ほかの　なかまの　こうげきを
;   てつだうのは　どうもな[91]、。
; --------------------------------------------------------------------------
Bank66_Msg123:                               ; $6C59  (file $10AC59)
    db $EA                         ; $6C59  ▶ new page
    db $9F                         ; $6C5A  box tag
    db $96                         ; $6C5B  end name/box tag
    db $42,$29,$3D                 ; $6C5C  ほかの
    db $90                         ; $6C5F  　(space)
    db $39,$29,$43,$3D             ; $6C60  なかまの
    db $90                         ; $6C64  　(space)
    db $2D,$26,$2C,$8D,$2A,$54     ; $6C65  こうけ゛きを = こうげきを
    db $EF,$EE                     ; $6C6B  newline
    db $90,$90                     ; $6C6D  　　(indent)
    db $37,$35,$33,$8D,$26,$3D,$3E ; $6C6F  てつた゛うのは = てつだうのは
    db $90                         ; $6C76  　(space)
    db $38,$8D,$26,$47,$39         ; $6C77  と゛うもな = どうもな
    db $91                         ; $6C7C  ctrl $91
    db $A4                         ; $6C7D  、
    db $8F                         ; $6C7E  。
    db $F7                         ; $6C7F  clear page
    db $F0                         ; $6C80  end of message


; --------------------------------------------------------------------------
; Message #124 ($6C81)
;   「わたしが　きりこみたいちょうを
;   つとめよう。　みんなつづけ[92]！
; --------------------------------------------------------------------------
Bank66_Msg124:                               ; $6C81  (file $10AC81)
    db $EA                         ; $6C81  ▶ new page
    db $9F                         ; $6C82  box tag
    db $96                         ; $6C83  end name/box tag
    db $53,$33,$2F,$29,$8D         ; $6C84  わたしか゛ = わたしが
    db $90                         ; $6C89  　(space)
    db $2A,$4F,$2D,$44,$33,$25,$34,$4D,$26,$54; $6C8A  きりこみたいちょうを
    db $EF,$EE                     ; $6C94  newline
    db $90,$90                     ; $6C96  　　(indent)
    db $35,$38,$46,$4C,$26         ; $6C98  つとめよう
    db $8F                         ; $6C9D  。
    db $90                         ; $6C9E  　(space)
    db $44,$55,$39,$35,$35,$8D,$2C ; $6C9F  みんなつつ゛け = みんなつづけ
    db $92                         ; $6CA6  ctrl $92
    db $99                         ; $6CA7  ！
    db $F7                         ; $6CA8  clear page
    db $F0                         ; $6CA9  end of message


; --------------------------------------------------------------------------
; Message #125 ($6CAA)
;   「フッ、、。
;   「おのれの　じつりょくのみで
;   しょうぶする！
; --------------------------------------------------------------------------
Bank66_Msg125:                               ; $6CAA  (file $10ACAA)
    db $EA                         ; $6CAA  ▶ new page
    db $9F                         ; $6CAB  box tag
    db $96                         ; $6CAC  end name/box tag
    db $77,$6D                     ; $6CAD  フッ
    db $A4                         ; $6CAF  、
    db $A4                         ; $6CB0  、
    db $8F                         ; $6CB1  。
    db $EF,$EE                     ; $6CB2  newline
    db $FA                         ; $6CB4  wait-for-button
    db $F7                         ; $6CB5  clear page
    db $EF,$EE                     ; $6CB6  newline
    db $F3                         ; $6CB8  open text box
    db $9F                         ; $6CB9  box tag
    db $96                         ; $6CBA  end name/box tag
    db $28,$3D,$51,$3D             ; $6CBB  おのれの
    db $90                         ; $6CBF  　(space)
    db $2F,$8D,$35,$4F,$4D,$2B,$3D,$44,$37,$8D; $6CC0  し゛つりょくのみて゛ = じつりょくのみで
    db $EF,$EE                     ; $6CCA  newline
    db $90,$90                     ; $6CCC  　　(indent)
    db $2F,$4D,$26,$40,$8D,$30,$50 ; $6CCE  しょうふ゛する = しょうぶする
    db $99                         ; $6CD5  ！
    db $F7                         ; $6CD6  clear page
    db $F0                         ; $6CD7  end of message


; --------------------------------------------------------------------------
; Message #126 ($6CD8)
;   「しょうぶとは
;   ちからと　ちからのぶつかりあい。
;   「へたな　こわざは
;   ひつようない！
; --------------------------------------------------------------------------
Bank66_Msg126:                               ; $6CD8  (file $10ACD8)
    db $EA                         ; $6CD8  ▶ new page
    db $9F                         ; $6CD9  box tag
    db $96                         ; $6CDA  end name/box tag
    db $2F,$4D,$26,$40,$8D,$38,$3E ; $6CDB  しょうふ゛とは = しょうぶとは
    db $EF,$EE                     ; $6CE2  newline
    db $90,$90                     ; $6CE4  　　(indent)
    db $34,$29,$4E,$38             ; $6CE6  ちからと
    db $90                         ; $6CEA  　(space)
    db $34,$29,$4E,$3D,$40,$8D,$35,$29,$4F,$24,$25; $6CEB  ちからのふ゛つかりあい = ちからのぶつかりあい
    db $8F                         ; $6CF6  。
    db $FA                         ; $6CF7  wait-for-button
    db $F7                         ; $6CF8  clear page
    db $EF,$EE                     ; $6CF9  newline
    db $9F                         ; $6CFB  box tag
    db $96                         ; $6CFC  end name/box tag
    db $41,$33,$39                 ; $6CFD  へたな
    db $90                         ; $6D00  　(space)
    db $2D,$53,$2E,$8D,$3E         ; $6D01  こわさ゛は = こわざは
    db $EF,$EE                     ; $6D06  newline
    db $90,$90                     ; $6D08  　　(indent)
    db $3F,$35,$4C,$26,$39,$25     ; $6D0A  ひつようない
    db $99                         ; $6D10  ！
    db $F7                         ; $6D11  clear page
    db $F0                         ; $6D12  end of message


; --------------------------------------------------------------------------
; Message #127 ($6D13)
;   「いのちしらずとは　いのちを
;   だいじにせぬ　ことではない、。
;   「しのきょうふを　かんじぬほどに
;   おのれに　じしんのあることだ！
; --------------------------------------------------------------------------
Bank66_Msg127:                               ; $6D13  (file $10AD13)
    db $EA                         ; $6D13  ▶ new page
    db $9F                         ; $6D14  box tag
    db $96                         ; $6D15  end name/box tag
    db $25,$3D,$34,$2F,$4E,$30,$8D,$38,$3E; $6D16  いのちしらす゛とは = いのちしらずとは
    db $90                         ; $6D1F  　(space)
    db $25,$3D,$34,$54             ; $6D20  いのちを
    db $EF,$EE                     ; $6D24  newline
    db $90,$90                     ; $6D26  　　(indent)
    db $33,$8D,$25,$2F,$8D,$3A,$31,$3B; $6D28  た゛いし゛にせぬ = だいじにせぬ
    db $90                         ; $6D30  　(space)
    db $2D,$38,$37,$8D,$3E,$39,$25 ; $6D31  ことて゛はない = ことではない
    db $A4                         ; $6D38  、
    db $8F                         ; $6D39  。
    db $FA                         ; $6D3A  wait-for-button
    db $F7                         ; $6D3B  clear page
    db $EF,$EE                     ; $6D3C  newline
    db $9F                         ; $6D3E  box tag
    db $96                         ; $6D3F  end name/box tag
    db $2F,$3D,$2A,$4D,$26,$40,$54 ; $6D40  しのきょうふを
    db $90                         ; $6D47  　(space)
    db $29,$55,$2F,$8D,$3B,$42,$38,$8D,$3A; $6D48  かんし゛ぬほと゛に = かんじぬほどに
    db $EF,$EE                     ; $6D51  newline
    db $90,$90                     ; $6D53  　　(indent)
    db $28,$3D,$51,$3A             ; $6D55  おのれに
    db $90                         ; $6D59  　(space)
    db $2F,$8D,$2F,$55,$3D,$24,$50,$2D,$38,$33,$8D; $6D5A  し゛しんのあることた゛ = じしんのあることだ
    db $99                         ; $6D65  ！
    db $F7                         ; $6D66  clear page
    db $F0                         ; $6D67  end of message


; --------------------------------------------------------------------------
; Message #128 ($6D68)
;   「てきが　どれほどつよくても
;   わたしには　かんけいない！
;   「ただ　しりょくをつくして
;   たちむかうのみ！！
; --------------------------------------------------------------------------
Bank66_Msg128:                               ; $6D68  (file $10AD68)
    db $EA                         ; $6D68  ▶ new page
    db $9F                         ; $6D69  box tag
    db $96                         ; $6D6A  end name/box tag
    db $37,$2A,$29,$8D             ; $6D6B  てきか゛ = てきが
    db $90                         ; $6D6F  　(space)
    db $38,$8D,$51,$42,$38,$8D,$35,$4C,$2B,$37,$47; $6D70  と゛れほと゛つよくても = どれほどつよくても
    db $EF,$EE                     ; $6D7B  newline
    db $90,$90                     ; $6D7D  　　(indent)
    db $53,$33,$2F,$3A,$3E         ; $6D7F  わたしには
    db $90                         ; $6D84  　(space)
    db $29,$55,$2C,$25,$39,$25     ; $6D85  かんけいない
    db $99                         ; $6D8B  ！
    db $FA                         ; $6D8C  wait-for-button
    db $F7                         ; $6D8D  clear page
    db $EF,$EE                     ; $6D8E  newline
    db $9F                         ; $6D90  box tag
    db $96                         ; $6D91  end name/box tag
    db $33,$33,$8D                 ; $6D92  たた゛ = ただ
    db $90                         ; $6D95  　(space)
    db $2F,$4F,$4D,$2B,$54,$35,$2B,$2F,$37; $6D96  しりょくをつくして
    db $EF,$EE                     ; $6D9F  newline
    db $90,$90                     ; $6DA1  　　(indent)
    db $33,$34,$45,$29,$26,$3D,$44 ; $6DA3  たちむかうのみ
    db $99                         ; $6DAA  ！
    db $99                         ; $6DAB  ！
    db $F7                         ; $6DAC  clear page
    db $F0                         ; $6DAD  end of message


; --------------------------------------------------------------------------
; Message #129 ($6DAE)
;   「きみは　きみ。
;   わたしは　わたし、、。
; --------------------------------------------------------------------------
Bank66_Msg129:                               ; $6DAE  (file $10ADAE)
    db $EA                         ; $6DAE  ▶ new page
    db $9F                         ; $6DAF  box tag
    db $96                         ; $6DB0  end name/box tag
    db $2A,$44,$3E                 ; $6DB1  きみは
    db $90                         ; $6DB4  　(space)
    db $2A,$44                     ; $6DB5  きみ
    db $8F                         ; $6DB7  。
    db $EF,$EE                     ; $6DB8  newline
    db $90,$90                     ; $6DBA  　　(indent)
    db $53,$33,$2F,$3E             ; $6DBC  わたしは
    db $90                         ; $6DC0  　(space)
    db $53,$33,$2F                 ; $6DC1  わたし
    db $A4                         ; $6DC4  、
    db $A4                         ; $6DC5  、
    db $8F                         ; $6DC6  。
    db $F7                         ; $6DC7  clear page
    db $F0                         ; $6DC8  end of message


; --------------------------------------------------------------------------
; Message #130 ($6DC9)
;   「あまり　ベタベタして
;   たたかうのは　すきじゃないね！
; --------------------------------------------------------------------------
Bank66_Msg130:                               ; $6DC9  (file $10ADC9)
    db $EA                         ; $6DC9  ▶ new page
    db $9F                         ; $6DCA  box tag
    db $96                         ; $6DCB  end name/box tag
    db $24,$43,$4F                 ; $6DCC  あまり
    db $90                         ; $6DCF  　(space)
    db $78,$8D,$6A,$78,$8D,$6A,$2F,$37; $6DD0  ヘ゛タヘ゛タして = ベタベタして
    db $EF,$EE                     ; $6DD8  newline
    db $90,$90                     ; $6DDA  　　(indent)
    db $33,$33,$29,$26,$3D,$3E     ; $6DDC  たたかうのは
    db $90                         ; $6DE2  　(space)
    db $30,$2A,$2F,$8D,$49,$39,$25,$3C; $6DE3  すきし゛ゃないね = すきじゃないね
    db $99                         ; $6DEB  ！
    db $F7                         ; $6DEC  clear page
    db $F0                         ; $6DED  end of message


; --------------------------------------------------------------------------
; Message #131 ($6DEE)
;   「ワォ[9D]ン[9D]！
;   「いっぴき　おおかみの
;   あいさつだ。
; --------------------------------------------------------------------------
Bank66_Msg131:                               ; $6DEE  (file $10ADEE)
    db $EA                         ; $6DEE  ▶ new page
    db $9F                         ; $6DEF  box tag
    db $96                         ; $6DF0  end name/box tag
    db $8A,$5E                     ; $6DF1  ワォ
    db $9D                         ; $6DF3  ctrl $9D
    db $8C                         ; $6DF4  ン
    db $9D                         ; $6DF5  ctrl $9D
    db $99                         ; $6DF6  ！
    db $EF,$EE                     ; $6DF7  newline
    db $FA                         ; $6DF9  wait-for-button
    db $F7                         ; $6DFA  clear page
    db $EF,$EE                     ; $6DFB  newline
    db $F3                         ; $6DFD  open text box
    db $9F                         ; $6DFE  box tag
    db $96                         ; $6DFF  end name/box tag
    db $25,$36,$3F,$8E,$2A         ; $6E00  いっひ゜き = いっぴき
    db $90                         ; $6E05  　(space)
    db $28,$28,$29,$44,$3D         ; $6E06  おおかみの
    db $EF,$EE                     ; $6E0B  newline
    db $90,$90                     ; $6E0D  　　(indent)
    db $24,$25,$2E,$35,$33,$8D     ; $6E0F  あいさつた゛ = あいさつだ
    db $8F                         ; $6E15  。
    db $F7                         ; $6E16  clear page
    db $F0                         ; $6E17  end of message


; --------------------------------------------------------------------------
; Message #132 ($6E18)
;   「ひとりに　してくれないか、、。
; --------------------------------------------------------------------------
Bank66_Msg132:                               ; $6E18  (file $10AE18)
    db $EA                         ; $6E18  ▶ new page
    db $9F                         ; $6E19  box tag
    db $96                         ; $6E1A  end name/box tag
    db $3F,$38,$4F,$3A             ; $6E1B  ひとりに
    db $90                         ; $6E1F  　(space)
    db $2F,$37,$2B,$51,$39,$25,$29 ; $6E20  してくれないか
    db $A4                         ; $6E27  、
    db $A4                         ; $6E28  、
    db $8F                         ; $6E29  。
    db $EF,$EE                     ; $6E2A  newline
    db $F7                         ; $6E2C  clear page
    db $F0                         ; $6E2D  end of message


; --------------------------------------------------------------------------
; Message #133 ($6E2E)
;   「いいじゃないですか！
;   こうげきばっかりしても、、。
; --------------------------------------------------------------------------
Bank66_Msg133:                               ; $6E2E  (file $10AE2E)
    db $EB                         ; $6E2E  ▶ new page
    db $9F                         ; $6E2F  box tag
    db $96                         ; $6E30  end name/box tag
    db $25,$25,$2F,$8D,$49,$39,$25,$37,$8D,$30,$29; $6E31  いいし゛ゃないて゛すか = いいじゃないですか
    db $99                         ; $6E3C  ！
    db $EF,$EE                     ; $6E3D  newline
    db $90,$90                     ; $6E3F  　　(indent)
    db $2D,$26,$2C,$8D,$2A,$3E,$8D,$36,$29,$4F,$2F,$37,$47; $6E41  こうけ゛きは゛っかりしても = こうげきばっかりしても
    db $A4                         ; $6E4E  、
    db $A4                         ; $6E4F  、
    db $8F                         ; $6E50  。
    db $F7                         ; $6E51  clear page
    db $F0                         ; $6E52  end of message


; --------------------------------------------------------------------------
; Message #134 ($6E53)
;   「いちおう　わたし
;   かいふくとか　やりますって！
; --------------------------------------------------------------------------
Bank66_Msg134:                               ; $6E53  (file $10AE53)
    db $EB                         ; $6E53  ▶ new page
    db $9F                         ; $6E54  box tag
    db $96                         ; $6E55  end name/box tag
    db $25,$34,$28,$26             ; $6E56  いちおう
    db $90                         ; $6E5A  　(space)
    db $53,$33,$2F                 ; $6E5B  わたし
    db $EF,$EE                     ; $6E5E  newline
    db $90,$90                     ; $6E60  　　(indent)
    db $29,$25,$40,$2B,$38,$29     ; $6E62  かいふくとか
    db $90                         ; $6E68  　(space)
    db $48,$4F,$43,$30,$36,$37     ; $6E69  やりますって
    db $99                         ; $6E6F  ！
    db $F7                         ; $6E70  clear page
    db $F0                         ; $6E71  end of message


; --------------------------------------------------------------------------
; Message #135 ($6E72)
;   「みんな　わたしのことを
;   みえっぱりと　もうしますけど、
;   「そんなこと　ないですよねえ？
; --------------------------------------------------------------------------
Bank66_Msg135:                               ; $6E72  (file $10AE72)
    db $EB                         ; $6E72  ▶ new page
    db $9F                         ; $6E73  box tag
    db $96                         ; $6E74  end name/box tag
    db $44,$55,$39                 ; $6E75  みんな
    db $90                         ; $6E78  　(space)
    db $53,$33,$2F,$3D,$2D,$38,$54 ; $6E79  わたしのことを
    db $EF,$EE                     ; $6E80  newline
    db $90,$90                     ; $6E82  　　(indent)
    db $44,$27,$36,$3E,$8E,$4F,$38 ; $6E84  みえっは゜りと = みえっぱりと
    db $90                         ; $6E8B  　(space)
    db $47,$26,$2F,$43,$30,$2C,$38,$8D; $6E8C  もうしますけと゛ = もうしますけど
    db $A4                         ; $6E94  、
    db $FA                         ; $6E95  wait-for-button
    db $F7                         ; $6E96  clear page
    db $EF,$EE                     ; $6E97  newline
    db $9F                         ; $6E99  box tag
    db $96                         ; $6E9A  end name/box tag
    db $32,$55,$39,$2D,$38         ; $6E9B  そんなこと
    db $90                         ; $6EA0  　(space)
    db $39,$25,$37,$8D,$30,$4C,$3C,$27; $6EA1  ないて゛すよねえ = ないですよねえ
    db $98                         ; $6EA9  ？
    db $EF,$EE                     ; $6EAA  newline
    db $F7                         ; $6EAC  clear page
    db $F0                         ; $6EAD  end of message


; --------------------------------------------------------------------------
; Message #136 ($6EAE)
;   「フハハハハ、！　わたしのかれいな
;   こうげきを　みるがよい！！
; --------------------------------------------------------------------------
Bank66_Msg136:                               ; $6EAE  (file $10AEAE)
    db $EB                         ; $6EAE  ▶ new page
    db $9F                         ; $6EAF  box tag
    db $96                         ; $6EB0  end name/box tag
    db $77,$75,$75,$75,$75         ; $6EB1  フハハハハ
    db $A4                         ; $6EB6  、
    db $99                         ; $6EB7  ！
    db $90                         ; $6EB8  　(space)
    db $53,$33,$2F,$3D,$29,$51,$25,$39; $6EB9  わたしのかれいな
    db $EF,$EE                     ; $6EC1  newline
    db $90,$90                     ; $6EC3  　　(indent)
    db $2D,$26,$2C,$8D,$2A,$54     ; $6EC5  こうけ゛きを = こうげきを
    db $90                         ; $6ECB  　(space)
    db $44,$50,$29,$8D,$4C,$25     ; $6ECC  みるか゛よい = みるがよい
    db $99                         ; $6ED2  ！
    db $99                         ; $6ED3  ！
    db $F7                         ; $6ED4  clear page
    db $F0                         ; $6ED5  end of message


; --------------------------------------------------------------------------
; Message #137 ($6ED6)
;   「でへへへ、、。
;   きょうも　あしたも　はれですら。
; --------------------------------------------------------------------------
Bank66_Msg137:                               ; $6ED6  (file $10AED6)
    db $EB                         ; $6ED6  ▶ new page
    db $9F                         ; $6ED7  box tag
    db $96                         ; $6ED8  end name/box tag
    db $37,$8D,$41,$41,$41         ; $6ED9  て゛へへへ = でへへへ
    db $A4                         ; $6EDE  、
    db $A4                         ; $6EDF  、
    db $8F                         ; $6EE0  。
    db $EF,$EE                     ; $6EE1  newline
    db $90,$90                     ; $6EE3  　　(indent)
    db $2A,$4D,$26,$47             ; $6EE5  きょうも
    db $90                         ; $6EE9  　(space)
    db $24,$2F,$33,$47             ; $6EEA  あしたも
    db $90                         ; $6EEE  　(space)
    db $3E,$51,$37,$8D,$30,$4E     ; $6EEF  はれて゛すら = はれですら
    db $8F                         ; $6EF5  。
    db $F7                         ; $6EF6  clear page
    db $F0                         ; $6EF7  end of message


; --------------------------------------------------------------------------
; Message #138 ($6EF8)
;   「そのうち[92]　なんとか[91]
;   なるんじゃないですか[91]、、。
; --------------------------------------------------------------------------
Bank66_Msg138:                               ; $6EF8  (file $10AEF8)
    db $EB                         ; $6EF8  ▶ new page
    db $9F                         ; $6EF9  box tag
    db $96                         ; $6EFA  end name/box tag
    db $32,$3D,$26,$34             ; $6EFB  そのうち
    db $92                         ; $6EFF  ctrl $92
    db $90                         ; $6F00  　(space)
    db $39,$55,$38,$29             ; $6F01  なんとか
    db $91                         ; $6F05  ctrl $91
    db $EF,$EE                     ; $6F06  newline
    db $90,$90                     ; $6F08  　　(indent)
    db $39,$50,$55,$2F,$8D,$49,$39,$25,$37,$8D,$30,$29; $6F0A  なるんし゛ゃないて゛すか = なるんじゃないですか
    db $91                         ; $6F16  ctrl $91
    db $A4                         ; $6F17  、
    db $A4                         ; $6F18  、
    db $8F                         ; $6F19  。
    db $F7                         ; $6F1A  clear page
    db $F0                         ; $6F1B  end of message


; --------------------------------------------------------------------------
; Message #139 ($6F1C)
;   「てきとうに　こうげきしてりゃあ
;   まあ　なんとかなるでしょう。
; --------------------------------------------------------------------------
Bank66_Msg139:                               ; $6F1C  (file $10AF1C)
    db $EB                         ; $6F1C  ▶ new page
    db $9F                         ; $6F1D  box tag
    db $96                         ; $6F1E  end name/box tag
    db $37,$2A,$38,$26,$3A         ; $6F1F  てきとうに
    db $90                         ; $6F24  　(space)
    db $2D,$26,$2C,$8D,$2A,$2F,$37,$4F,$49,$24; $6F25  こうけ゛きしてりゃあ = こうげきしてりゃあ
    db $EF,$EE                     ; $6F2F  newline
    db $90,$90                     ; $6F31  　　(indent)
    db $43,$24                     ; $6F33  まあ
    db $90                         ; $6F35  　(space)
    db $39,$55,$38,$29,$39,$50,$37,$8D,$2F,$4D,$26; $6F36  なんとかなるて゛しょう = なんとかなるでしょう
    db $8F                         ; $6F41  。
    db $F7                         ; $6F42  clear page
    db $F0                         ; $6F43  end of message


; --------------------------------------------------------------------------
; Message #140 ($6F44)
;   「あんしんするのだ　〈テリー〉。
;   まけても　いいじゃないか。
; --------------------------------------------------------------------------
Bank66_Msg140:                               ; $6F44  (file $10AF44)
    db $EB                         ; $6F44  ▶ new page
    db $9F                         ; $6F45  box tag
    db $96                         ; $6F46  end name/box tag
    db $24,$55,$2F,$55,$30,$50,$3D,$33,$8D; $6F47  あんしんするのた゛ = あんしんするのだ
    db $90                         ; $6F50  　(space)
    db $F6                         ; $6F51  «insert hero name» (テリー)
    db $8F                         ; $6F52  。
    db $EF,$EE                     ; $6F53  newline
    db $90,$90                     ; $6F55  　　(indent)
    db $43,$2C,$37,$47             ; $6F57  まけても
    db $90                         ; $6F5B  　(space)
    db $25,$25,$2F,$8D,$49,$39,$25,$29; $6F5C  いいし゛ゃないか = いいじゃないか
    db $8F                         ; $6F64  。
    db $F7                         ; $6F65  clear page
    db $F0                         ; $6F66  end of message


; --------------------------------------------------------------------------
; Message #141 ($6F67)
;   「べつに　かいふくなんて
;   しなくても　かてちゃいますって！
; --------------------------------------------------------------------------
Bank66_Msg141:                               ; $6F67  (file $10AF67)
    db $EB                         ; $6F67  ▶ new page
    db $9F                         ; $6F68  box tag
    db $96                         ; $6F69  end name/box tag
    db $41,$8D,$35,$3A             ; $6F6A  へ゛つに = べつに
    db $90                         ; $6F6E  　(space)
    db $29,$25,$40,$2B,$39,$55,$37 ; $6F6F  かいふくなんて
    db $EF,$EE                     ; $6F76  newline
    db $90,$90                     ; $6F78  　　(indent)
    db $2F,$39,$2B,$37,$47         ; $6F7A  しなくても
    db $90                         ; $6F7F  　(space)
    db $29,$37,$34,$49,$25,$43,$30,$36,$37; $6F80  かてちゃいますって
    db $99                         ; $6F89  ！
    db $F7                         ; $6F8A  clear page
    db $F0                         ; $6F8B  end of message


; --------------------------------------------------------------------------
; Message #142 ($6F8C)
;   「フフフフ、、。
;   「わたしのごとき　つわものに
;   かいふくは　むよう　むよう！！
; --------------------------------------------------------------------------
Bank66_Msg142:                               ; $6F8C  (file $10AF8C)
    db $EB                         ; $6F8C  ▶ new page
    db $9F                         ; $6F8D  box tag
    db $96                         ; $6F8E  end name/box tag
    db $77,$77,$77,$77             ; $6F8F  フフフフ
    db $A4                         ; $6F93  、
    db $A4                         ; $6F94  、
    db $8F                         ; $6F95  。
    db $EF,$EE                     ; $6F96  newline
    db $FA                         ; $6F98  wait-for-button
    db $F7                         ; $6F99  clear page
    db $EF,$EE                     ; $6F9A  newline
    db $F3                         ; $6F9C  open text box
    db $9F                         ; $6F9D  box tag
    db $96                         ; $6F9E  end name/box tag
    db $53,$33,$2F,$3D,$2D,$8D,$38,$2A; $6F9F  わたしのこ゛とき = わたしのごとき
    db $90                         ; $6FA7  　(space)
    db $35,$53,$47,$3D,$3A         ; $6FA8  つわものに
    db $EF,$EE                     ; $6FAD  newline
    db $90,$90                     ; $6FAF  　　(indent)
    db $29,$25,$40,$2B,$3E         ; $6FB1  かいふくは
    db $90                         ; $6FB6  　(space)
    db $45,$4C,$26                 ; $6FB7  むよう
    db $90                         ; $6FBA  　(space)
    db $45,$4C,$26                 ; $6FBB  むよう
    db $99                         ; $6FBE  ！
    db $99                         ; $6FBF  ！
    db $F7                         ; $6FC0  clear page
    db $F0                         ; $6FC1  end of message


; --------------------------------------------------------------------------
; Message #143 ($6FC2)
;   「まけるきが　しません。
;   わたし　つよいんですから。
; --------------------------------------------------------------------------
Bank66_Msg143:                               ; $6FC2  (file $10AFC2)
    db $EB                         ; $6FC2  ▶ new page
    db $9F                         ; $6FC3  box tag
    db $96                         ; $6FC4  end name/box tag
    db $43,$2C,$50,$2A,$29,$8D     ; $6FC5  まけるきか゛ = まけるきが
    db $90                         ; $6FCB  　(space)
    db $2F,$43,$31,$55             ; $6FCC  しません
    db $8F                         ; $6FD0  。
    db $EF,$EE                     ; $6FD1  newline
    db $90,$90                     ; $6FD3  　　(indent)
    db $53,$33,$2F                 ; $6FD5  わたし
    db $90                         ; $6FD8  　(space)
    db $35,$4C,$25,$55,$37,$8D,$30,$29,$4E; $6FD9  つよいんて゛すから = つよいんですから
    db $8F                         ; $6FE2  。
    db $F7                         ; $6FE3  clear page
    db $F0                         ; $6FE4  end of message


; --------------------------------------------------------------------------
; Message #144 ($6FE5)
;   「さあ　みなのもの。
;   わたしのまえに　ひざまずくのだ！
;   「わたしより　つよいものなど
;   このよに　おらん！！
; --------------------------------------------------------------------------
Bank66_Msg144:                               ; $6FE5  (file $10AFE5)
    db $EB                         ; $6FE5  ▶ new page
    db $9F                         ; $6FE6  box tag
    db $96                         ; $6FE7  end name/box tag
    db $2E,$24                     ; $6FE8  さあ
    db $90                         ; $6FEA  　(space)
    db $44,$39,$3D,$47,$3D         ; $6FEB  みなのもの
    db $8F                         ; $6FF0  。
    db $EF,$EE                     ; $6FF1  newline
    db $90,$90                     ; $6FF3  　　(indent)
    db $53,$33,$2F,$3D,$43,$27,$3A ; $6FF5  わたしのまえに
    db $90                         ; $6FFC  　(space)
    db $3F,$2E,$8D,$43,$30,$8D,$2B,$3D,$33,$8D; $6FFD  ひさ゛ます゛くのた゛ = ひざまずくのだ
    db $99                         ; $7007  ！
    db $FA                         ; $7008  wait-for-button
    db $F7                         ; $7009  clear page
    db $EF,$EE                     ; $700A  newline
    db $9F                         ; $700C  box tag
    db $96                         ; $700D  end name/box tag
    db $53,$33,$2F,$4C,$4F         ; $700E  わたしより
    db $90                         ; $7013  　(space)
    db $35,$4C,$25,$47,$3D,$39,$38,$8D; $7014  つよいものなと゛ = つよいものなど
    db $EF,$EE                     ; $701C  newline
    db $90,$90                     ; $701E  　　(indent)
    db $2D,$3D,$4C,$3A             ; $7020  このよに
    db $90                         ; $7024  　(space)
    db $28,$4E,$55                 ; $7025  おらん
    db $99                         ; $7028  ！
    db $99                         ; $7029  ！
    db $F7                         ; $702A  clear page
    db $F0                         ; $702B  end of message


; --------------------------------------------------------------------------
; Message #145 ($702C)
;   「うるせえよ！
;   もんくあったら　かかってきな！
; --------------------------------------------------------------------------
Bank66_Msg145:                               ; $702C  (file $10B02C)
    db $EB                         ; $702C  ▶ new page
    db $9F                         ; $702D  box tag
    db $96                         ; $702E  end name/box tag
    db $26,$50,$31,$27,$4C         ; $702F  うるせえよ
    db $99                         ; $7034  ！
    db $EF,$EE                     ; $7035  newline
    db $90,$90                     ; $7037  　　(indent)
    db $47,$55,$2B,$24,$36,$33,$4E ; $7039  もんくあったら
    db $90                         ; $7040  　(space)
    db $29,$29,$36,$37,$2A,$39     ; $7041  かかってきな
    db $99                         ; $7047  ！
    db $F7                         ; $7048  clear page
    db $F0                         ; $7049  end of message


; --------------------------------------------------------------------------
; Message #146 ($704A)
;   「なんですか？
;   わたくしに　どうしろと？
; --------------------------------------------------------------------------
Bank66_Msg146:                               ; $704A  (file $10B04A)
    db $EB                         ; $704A  ▶ new page
    db $9F                         ; $704B  box tag
    db $96                         ; $704C  end name/box tag
    db $39,$55,$37,$8D,$30,$29     ; $704D  なんて゛すか = なんですか
    db $98                         ; $7053  ？
    db $EF,$EE                     ; $7054  newline
    db $90,$90                     ; $7056  　　(indent)
    db $53,$33,$2B,$2F,$3A         ; $7058  わたくしに
    db $90                         ; $705D  　(space)
    db $38,$8D,$26,$2F,$52,$38     ; $705E  と゛うしろと = どうしろと
    db $98                         ; $7064  ？
    db $F7                         ; $7065  clear page
    db $F0                         ; $7066  end of message


; --------------------------------------------------------------------------
; Message #147 ($7067)
;   「たたかってやっても　いいけど
;   かいふくは　しろよ。
; --------------------------------------------------------------------------
Bank66_Msg147:                               ; $7067  (file $10B067)
    db $EB                         ; $7067  ▶ new page
    db $9F                         ; $7068  box tag
    db $96                         ; $7069  end name/box tag
    db $33,$33,$29,$36,$37,$48,$36,$37,$47; $706A  たたかってやっても
    db $90                         ; $7073  　(space)
    db $25,$25,$2C,$38,$8D         ; $7074  いいけと゛ = いいけど
    db $EF,$EE                     ; $7079  newline
    db $90,$90                     ; $707B  　　(indent)
    db $29,$25,$40,$2B,$3E         ; $707D  かいふくは
    db $90                         ; $7082  　(space)
    db $2F,$52,$4C                 ; $7083  しろよ
    db $8F                         ; $7086  。
    db $F7                         ; $7087  clear page
    db $F0                         ; $7088  end of message


; --------------------------------------------------------------------------
; Message #148 ($7089)
;   「なんど　いったらわかるんだ？
;   はやく　たたかわせろ！
; --------------------------------------------------------------------------
Bank66_Msg148:                               ; $7089  (file $10B089)
    db $EB                         ; $7089  ▶ new page
    db $9F                         ; $708A  box tag
    db $96                         ; $708B  end name/box tag
    db $39,$55,$38,$8D             ; $708C  なんと゛ = なんど
    db $90                         ; $7090  　(space)
    db $25,$36,$33,$4E,$53,$29,$50,$55,$33,$8D; $7091  いったらわかるんた゛ = いったらわかるんだ
    db $98                         ; $709B  ？
    db $EF,$EE                     ; $709C  newline
    db $90,$90                     ; $709E  　　(indent)
    db $3E,$48,$2B                 ; $70A0  はやく
    db $90                         ; $70A3  　(space)
    db $33,$33,$29,$53,$31,$52     ; $70A4  たたかわせろ
    db $99                         ; $70AA  ！
    db $F7                         ; $70AB  clear page
    db $F0                         ; $70AC  end of message


; --------------------------------------------------------------------------
; Message #149 ($70AD)
;   「やるときめたら　どこまでも
;   やります！！
; --------------------------------------------------------------------------
Bank66_Msg149:                               ; $70AD  (file $10B0AD)
    db $EA                         ; $70AD  ▶ new page
    db $9F                         ; $70AE  box tag
    db $96                         ; $70AF  end name/box tag
    db $48,$50,$38,$2A,$46,$33,$4E ; $70B0  やるときめたら
    db $90                         ; $70B7  　(space)
    db $38,$8D,$2D,$43,$37,$8D,$47 ; $70B8  と゛こまて゛も = どこまでも
    db $EF,$EE                     ; $70BF  newline
    db $90,$90                     ; $70C1  　　(indent)
    db $48,$4F,$43,$30             ; $70C3  やります
    db $99                         ; $70C7  ！
    db $99                         ; $70C8  ！
    db $F7                         ; $70C9  clear page
    db $F0                         ; $70CA  end of message


; --------------------------------------------------------------------------
; Message #150 ($70CB)
;   「ガー！
;   はやく　たたかいたい！！
; --------------------------------------------------------------------------
Bank66_Msg150:                               ; $70CB  (file $10B0CB)
    db $EA                         ; $70CB  ▶ new page
    db $9F                         ; $70CC  box tag
    db $96                         ; $70CD  end name/box tag
    db $60,$8D,$9C                 ; $70CE  カ゛ー = ガー
    db $99                         ; $70D1  ！
    db $EF,$EE                     ; $70D2  newline
    db $90,$90                     ; $70D4  　　(indent)
    db $3E,$48,$2B                 ; $70D6  はやく
    db $90                         ; $70D9  　(space)
    db $33,$33,$29,$25,$33,$25     ; $70DA  たたかいたい
    db $99                         ; $70E0  ！
    db $99                         ; $70E1  ！
    db $F7                         ; $70E2  clear page
    db $F0                         ; $70E3  end of message


; --------------------------------------------------------------------------
; Message #151 ($70E4)
;   「う[95][95][95]おお！！
;   「わたしのなかに　ちからが
;   みなぎって　きました！！
; --------------------------------------------------------------------------
Bank66_Msg151:                               ; $70E4  (file $10B0E4)
    db $EA                         ; $70E4  ▶ new page
    db $9F                         ; $70E5  box tag
    db $96                         ; $70E6  end name/box tag
    db $26                         ; $70E7  う
    db $95                         ; $70E8  ctrl $95
    db $95                         ; $70E9  ctrl $95
    db $95                         ; $70EA  ctrl $95
    db $28,$28                     ; $70EB  おお
    db $99                         ; $70ED  ！
    db $99                         ; $70EE  ！
    db $EF,$EE                     ; $70EF  newline
    db $FA                         ; $70F1  wait-for-button
    db $F7                         ; $70F2  clear page
    db $EF,$EE                     ; $70F3  newline
    db $F3                         ; $70F5  open text box
    db $9F                         ; $70F6  box tag
    db $96                         ; $70F7  end name/box tag
    db $53,$33,$2F,$3D,$39,$29,$3A ; $70F8  わたしのなかに
    db $90                         ; $70FF  　(space)
    db $34,$29,$4E,$29,$8D         ; $7100  ちからか゛ = ちからが
    db $EF,$EE                     ; $7105  newline
    db $90,$90                     ; $7107  　　(indent)
    db $44,$39,$2A,$8D,$36,$37     ; $7109  みなき゛って = みなぎって
    db $90                         ; $710F  　(space)
    db $2A,$43,$2F,$33             ; $7110  きました
    db $99                         ; $7114  ！
    db $99                         ; $7115  ！
    db $F7                         ; $7116  clear page
    db $F0                         ; $7117  end of message


; --------------------------------------------------------------------------
; Message #152 ($7118)
;   「いくぜ！　よういは　いいか！？
;   ただ　つきすすむのみ！！
; --------------------------------------------------------------------------
Bank66_Msg152:                               ; $7118  (file $10B118)
    db $EA                         ; $7118  ▶ new page
    db $9F                         ; $7119  box tag
    db $96                         ; $711A  end name/box tag
    db $25,$2B,$31,$8D             ; $711B  いくせ゛ = いくぜ
    db $99                         ; $711F  ！
    db $90                         ; $7120  　(space)
    db $4C,$26,$25,$3E             ; $7121  よういは
    db $90                         ; $7125  　(space)
    db $25,$25,$29                 ; $7126  いいか
    db $99                         ; $7129  ！
    db $98                         ; $712A  ？
    db $EF,$EE                     ; $712B  newline
    db $90,$90                     ; $712D  　　(indent)
    db $33,$33,$8D                 ; $712F  たた゛ = ただ
    db $90                         ; $7132  　(space)
    db $35,$2A,$30,$30,$45,$3D,$44 ; $7133  つきすすむのみ
    db $99                         ; $713A  ！
    db $99                         ; $713B  ！
    db $F7                         ; $713C  clear page
    db $F0                         ; $713D  end of message


; --------------------------------------------------------------------------
; Message #153 ($713E)
;   「まず　じょうけんを　ゆうりにして
;   ことに　いどむべきでしょう。
; --------------------------------------------------------------------------
Bank66_Msg153:                               ; $713E  (file $10B13E)
    db $EA                         ; $713E  ▶ new page
    db $9F                         ; $713F  box tag
    db $96                         ; $7140  end name/box tag
    db $43,$30,$8D                 ; $7141  ます゛ = まず
    db $90                         ; $7144  　(space)
    db $2F,$8D,$4D,$26,$2C,$55,$54 ; $7145  し゛ょうけんを = じょうけんを
    db $90                         ; $714C  　(space)
    db $4A,$26,$4F,$3A,$2F,$37     ; $714D  ゆうりにして
    db $EF,$EE                     ; $7153  newline
    db $90,$90                     ; $7155  　　(indent)
    db $2D,$38,$3A                 ; $7157  ことに
    db $90                         ; $715A  　(space)
    db $25,$38,$8D,$45,$41,$8D,$2A,$37,$8D,$2F,$4D,$26; $715B  いと゛むへ゛きて゛しょう = いどむべきでしょう
    db $8F                         ; $7167  。
    db $F7                         ; $7168  clear page
    db $F0                         ; $7169  end of message


; --------------------------------------------------------------------------
; Message #154 ($716A)
;   「いしばしを　たたいてわたるのは
;   はずかしいことじゃ　ありません。
; --------------------------------------------------------------------------
Bank66_Msg154:                               ; $716A  (file $10B16A)
    db $EA                         ; $716A  ▶ new page
    db $9F                         ; $716B  box tag
    db $96                         ; $716C  end name/box tag
    db $25,$2F,$3E,$8D,$2F,$54     ; $716D  いしは゛しを = いしばしを
    db $90                         ; $7173  　(space)
    db $33,$33,$25,$37,$53,$33,$50,$3D,$3E; $7174  たたいてわたるのは
    db $EF,$EE                     ; $717D  newline
    db $90,$90                     ; $717F  　　(indent)
    db $3E,$30,$8D,$29,$2F,$25,$2D,$38,$2F,$8D,$49; $7181  はす゛かしいことし゛ゃ = はずかしいことじゃ
    db $90                         ; $718C  　(space)
    db $24,$4F,$43,$31,$55         ; $718D  ありません
    db $8F                         ; $7192  。
    db $F7                         ; $7193  clear page
    db $F0                         ; $7194  end of message


; --------------------------------------------------------------------------
; Message #155 ($7195)
;   「たたかいのきほんは　おのれの
;   じゃくてんを　しることです。
; --------------------------------------------------------------------------
Bank66_Msg155:                               ; $7195  (file $10B195)
    db $EA                         ; $7195  ▶ new page
    db $9F                         ; $7196  box tag
    db $96                         ; $7197  end name/box tag
    db $33,$33,$29,$25,$3D,$2A,$42,$55,$3E; $7198  たたかいのきほんは
    db $90                         ; $71A1  　(space)
    db $28,$3D,$51,$3D             ; $71A2  おのれの
    db $EF,$EE                     ; $71A6  newline
    db $90,$90                     ; $71A8  　　(indent)
    db $2F,$8D,$49,$2B,$37,$55,$54 ; $71AA  し゛ゃくてんを = じゃくてんを
    db $90                         ; $71B1  　(space)
    db $2F,$50,$2D,$38,$37,$8D,$30 ; $71B2  しることて゛す = しることです
    db $8F                         ; $71B9  。
    db $F7                         ; $71BA  clear page
    db $F0                         ; $71BB  end of message


; --------------------------------------------------------------------------
; Message #156 ($71BC)
;   「みたこともない　まものがいても
;   おどろかぬことだ。
;   「てきに　すきをみせれば
;   それで　すべては　おわりだ。
; --------------------------------------------------------------------------
Bank66_Msg156:                               ; $71BC  (file $10B1BC)
    db $EA                         ; $71BC  ▶ new page
    db $9F                         ; $71BD  box tag
    db $96                         ; $71BE  end name/box tag
    db $44,$33,$2D,$38,$47,$39,$25 ; $71BF  みたこともない
    db $90                         ; $71C6  　(space)
    db $43,$47,$3D,$29,$8D,$25,$37,$47; $71C7  まものか゛いても = まものがいても
    db $EF,$EE                     ; $71CF  newline
    db $90,$90                     ; $71D1  　　(indent)
    db $28,$38,$8D,$52,$29,$3B,$2D,$38,$33,$8D; $71D3  おと゛ろかぬことた゛ = おどろかぬことだ
    db $8F                         ; $71DD  。
    db $FA                         ; $71DE  wait-for-button
    db $F7                         ; $71DF  clear page
    db $EF,$EE                     ; $71E0  newline
    db $9F                         ; $71E2  box tag
    db $96                         ; $71E3  end name/box tag
    db $37,$2A,$3A                 ; $71E4  てきに
    db $90                         ; $71E7  　(space)
    db $30,$2A,$54,$44,$31,$51,$3E,$8D; $71E8  すきをみせれは゛ = すきをみせれば
    db $EF,$EE                     ; $71F0  newline
    db $90,$90                     ; $71F2  　　(indent)
    db $32,$51,$37,$8D             ; $71F4  それて゛ = それで
    db $90                         ; $71F8  　(space)
    db $30,$41,$8D,$37,$3E         ; $71F9  すへ゛ては = すべては
    db $90                         ; $71FE  　(space)
    db $28,$53,$4F,$33,$8D         ; $71FF  おわりた゛ = おわりだ
    db $8F                         ; $7204  。
    db $F7                         ; $7205  clear page
    db $F0                         ; $7206  end of message


; --------------------------------------------------------------------------
; Message #157 ($7207)
;   「ん[9D]。
;   なんでも　いいんじゃないっすか？
; --------------------------------------------------------------------------
Bank66_Msg157:                               ; $7207  (file $10B207)
    db $EB                         ; $7207  ▶ new page
    db $9F                         ; $7208  box tag
    db $96                         ; $7209  end name/box tag
    db $55                         ; $720A  ん
    db $9D                         ; $720B  ctrl $9D
    db $8F                         ; $720C  。
    db $EF,$EE                     ; $720D  newline
    db $90,$90                     ; $720F  　　(indent)
    db $39,$55,$37,$8D,$47         ; $7211  なんて゛も = なんでも
    db $90                         ; $7216  　(space)
    db $25,$25,$55,$2F,$8D,$49,$39,$25,$36,$30,$29; $7217  いいんし゛ゃないっすか = いいんじゃないっすか
    db $98                         ; $7222  ？
    db $F7                         ; $7223  clear page
    db $F0                         ; $7224  end of message


; --------------------------------------------------------------------------
; Message #158 ($7225)
;   「かぜのふくまま
;   きのむくままに、、。
; --------------------------------------------------------------------------
Bank66_Msg158:                               ; $7225  (file $10B225)
    db $EB                         ; $7225  ▶ new page
    db $9F                         ; $7226  box tag
    db $96                         ; $7227  end name/box tag
    db $29,$31,$8D,$3D,$40,$2B,$43,$43; $7228  かせ゛のふくまま = かぜのふくまま
    db $EF,$EE                     ; $7230  newline
    db $90,$90                     ; $7232  　　(indent)
    db $2A,$3D,$45,$2B,$43,$43,$3A ; $7234  きのむくままに
    db $A4                         ; $723B  、
    db $A4                         ; $723C  、
    db $8F                         ; $723D  。
    db $F7                         ; $723E  clear page
    db $F0                         ; $723F  end of message


; --------------------------------------------------------------------------
; Message #159 ($7240)
;   「まぐれでも　きまぐれでもいいから
;   かてりゃあ　いいんですよっ！
; --------------------------------------------------------------------------
Bank66_Msg159:                               ; $7240  (file $10B240)
    db $EB                         ; $7240  ▶ new page
    db $9F                         ; $7241  box tag
    db $96                         ; $7242  end name/box tag
    db $43,$2B,$8D,$51,$37,$8D,$47 ; $7243  まく゛れて゛も = まぐれでも
    db $90                         ; $724A  　(space)
    db $2A,$43,$2B,$8D,$51,$37,$8D,$47,$25,$25,$29,$4E; $724B  きまく゛れて゛もいいから = きまぐれでもいいから
    db $EF,$EE                     ; $7257  newline
    db $90,$90                     ; $7259  　　(indent)
    db $29,$37,$4F,$49,$24         ; $725B  かてりゃあ
    db $90                         ; $7260  　(space)
    db $25,$25,$55,$37,$8D,$30,$4C,$36; $7261  いいんて゛すよっ = いいんですよっ
    db $99                         ; $7269  ！
    db $F7                         ; $726A  clear page
    db $F0                         ; $726B  end of message


; --------------------------------------------------------------------------
; Message #160 ($726C)
;   「こんかいは　こうげきちゅうしん、
;   いや　かいふくを　たいせつに、。
;   「やはり　ほじょを　しゅたいに、。
;   ま[91]そのときの　きぶんしだいだ。
; --------------------------------------------------------------------------
Bank66_Msg160:                               ; $726C  (file $10B26C)
    db $EB                         ; $726C  ▶ new page
    db $9F                         ; $726D  box tag
    db $96                         ; $726E  end name/box tag
    db $2D,$55,$29,$25,$3E         ; $726F  こんかいは
    db $90                         ; $7274  　(space)
    db $2D,$26,$2C,$8D,$2A,$34,$4B,$26,$2F,$55; $7275  こうけ゛きちゅうしん = こうげきちゅうしん
    db $A4                         ; $727F  、
    db $EF,$EE                     ; $7280  newline
    db $90,$90                     ; $7282  　　(indent)
    db $25,$48                     ; $7284  いや
    db $90                         ; $7286  　(space)
    db $29,$25,$40,$2B,$54         ; $7287  かいふくを
    db $90                         ; $728C  　(space)
    db $33,$25,$31,$35,$3A         ; $728D  たいせつに
    db $A4                         ; $7292  、
    db $8F                         ; $7293  。
    db $FA                         ; $7294  wait-for-button
    db $F7                         ; $7295  clear page
    db $EF,$EE                     ; $7296  newline
    db $9F                         ; $7298  box tag
    db $96                         ; $7299  end name/box tag
    db $48,$3E,$4F                 ; $729A  やはり
    db $90                         ; $729D  　(space)
    db $42,$2F,$8D,$4D,$54         ; $729E  ほし゛ょを = ほじょを
    db $90                         ; $72A3  　(space)
    db $2F,$4B,$33,$25,$3A         ; $72A4  しゅたいに
    db $A4                         ; $72A9  、
    db $8F                         ; $72AA  。
    db $EF,$EE                     ; $72AB  newline
    db $90,$90                     ; $72AD  　　(indent)
    db $43                         ; $72AF  ま
    db $91                         ; $72B0  ctrl $91
    db $32,$3D,$38,$2A,$3D         ; $72B1  そのときの
    db $90                         ; $72B6  　(space)
    db $2A,$40,$8D,$55,$2F,$33,$8D,$25,$33,$8D; $72B7  きふ゛んした゛いた゛ = きぶんしだいだ
    db $8F                         ; $72C1  。
    db $F7                         ; $72C2  clear page
    db $F0                         ; $72C3  end of message


; --------------------------------------------------------------------------
; Message #161 ($72C4)
;   「わたしって　いつも　よけいなこと
;   ばかりしているのでしょうか、、？
; --------------------------------------------------------------------------
Bank66_Msg161:                               ; $72C4  (file $10B2C4)
    db $EB                         ; $72C4  ▶ new page
    db $9F                         ; $72C5  box tag
    db $96                         ; $72C6  end name/box tag
    db $53,$33,$2F,$36,$37         ; $72C7  わたしって
    db $90                         ; $72CC  　(space)
    db $25,$35,$47                 ; $72CD  いつも
    db $90                         ; $72D0  　(space)
    db $4C,$2C,$25,$39,$2D,$38     ; $72D1  よけいなこと
    db $EF,$EE                     ; $72D7  newline
    db $90,$90                     ; $72D9  　　(indent)
    db $3E,$8D,$29,$4F,$2F,$37,$25,$50,$3D,$37,$8D,$2F,$4D,$26,$29; $72DB  は゛かりしているのて゛しょうか = ばかりしているのでしょうか
    db $A4                         ; $72EA  、
    db $A4                         ; $72EB  、
    db $98                         ; $72EC  ？
    db $F7                         ; $72ED  clear page
    db $F0                         ; $72EE  end of message


; --------------------------------------------------------------------------
; Message #162 ($72EF)
;   「よこでたたかってる　かたのことが
;   どうも　きになっちゃって、、！
; --------------------------------------------------------------------------
Bank66_Msg162:                               ; $72EF  (file $10B2EF)
    db $EB                         ; $72EF  ▶ new page
    db $9F                         ; $72F0  box tag
    db $96                         ; $72F1  end name/box tag
    db $4C,$2D,$37,$8D,$33,$33,$29,$36,$37,$50; $72F2  よこて゛たたかってる = よこでたたかってる
    db $90                         ; $72FC  　(space)
    db $29,$33,$3D,$2D,$38,$29,$8D ; $72FD  かたのことか゛ = かたのことが
    db $EF,$EE                     ; $7304  newline
    db $90,$90                     ; $7306  　　(indent)
    db $38,$8D,$26,$47             ; $7308  と゛うも = どうも
    db $90                         ; $730C  　(space)
    db $2A,$3A,$39,$36,$34,$49,$36,$37; $730D  きになっちゃって
    db $A4                         ; $7315  、
    db $A4                         ; $7316  、
    db $99                         ; $7317  ！
    db $F7                         ; $7318  clear page
    db $F0                         ; $7319  end of message


; --------------------------------------------------------------------------
; Message #163 ($731A)
;   「あら　〈テリー〉さん。
;   かみが　はねてますよ！
; --------------------------------------------------------------------------
Bank66_Msg163:                               ; $731A  (file $10B31A)
    db $EB                         ; $731A  ▶ new page
    db $9F                         ; $731B  box tag
    db $96                         ; $731C  end name/box tag
    db $24,$4E                     ; $731D  あら
    db $90                         ; $731F  　(space)
    db $F6                         ; $7320  «insert hero name» (テリー)
    db $2E,$55                     ; $7321  さん
    db $8F                         ; $7323  。
    db $EF,$EE                     ; $7324  newline
    db $90,$90                     ; $7326  　　(indent)
    db $29,$44,$29,$8D             ; $7328  かみか゛ = かみが
    db $90                         ; $732C  　(space)
    db $3E,$3C,$37,$43,$30,$4C     ; $732D  はねてますよ
    db $99                         ; $7333  ！
    db $F7                         ; $7334  clear page
    db $F0                         ; $7335  end of message


; --------------------------------------------------------------------------
; Message #164 ($7336)
;   「もう　じゅんびは　いいのか？
;   わすれたことは　ないか？
;   「、、なんと！　わたしのことを
;   おせっかいと　もうすか！？
; --------------------------------------------------------------------------
Bank66_Msg164:                               ; $7336  (file $10B336)
    db $EB                         ; $7336  ▶ new page
    db $9F                         ; $7337  box tag
    db $96                         ; $7338  end name/box tag
    db $47,$26                     ; $7339  もう
    db $90                         ; $733B  　(space)
    db $2F,$8D,$4B,$55,$3F,$8D,$3E ; $733C  し゛ゅんひ゛は = じゅんびは
    db $90                         ; $7343  　(space)
    db $25,$25,$3D,$29             ; $7344  いいのか
    db $98                         ; $7348  ？
    db $EF,$EE                     ; $7349  newline
    db $90,$90                     ; $734B  　　(indent)
    db $53,$30,$51,$33,$2D,$38,$3E ; $734D  わすれたことは
    db $90                         ; $7354  　(space)
    db $39,$25,$29                 ; $7355  ないか
    db $98                         ; $7358  ？
    db $FA                         ; $7359  wait-for-button
    db $F7                         ; $735A  clear page
    db $EF,$EE                     ; $735B  newline
    db $9F                         ; $735D  box tag
    db $96                         ; $735E  end name/box tag
    db $A4                         ; $735F  、
    db $A4                         ; $7360  、
    db $39,$55,$38                 ; $7361  なんと
    db $99                         ; $7364  ！
    db $90                         ; $7365  　(space)
    db $53,$33,$2F,$3D,$2D,$38,$54 ; $7366  わたしのことを
    db $EF,$EE                     ; $736D  newline
    db $90,$90                     ; $736F  　　(indent)
    db $28,$31,$36,$29,$25,$38     ; $7371  おせっかいと
    db $90                         ; $7377  　(space)
    db $47,$26,$30,$29             ; $7378  もうすか
    db $99                         ; $737C  ！
    db $98                         ; $737D  ？
    db $F7                         ; $737E  clear page
    db $F0                         ; $737F  end of message


; --------------------------------------------------------------------------
; Message #165 ($7380)
;   「いかに　たたかえば　かてるか？
;   それをつねに　かんがえています。
; --------------------------------------------------------------------------
Bank66_Msg165:                               ; $7380  (file $10B380)
    db $EA                         ; $7380  ▶ new page
    db $9F                         ; $7381  box tag
    db $96                         ; $7382  end name/box tag
    db $25,$29,$3A                 ; $7383  いかに
    db $90                         ; $7386  　(space)
    db $33,$33,$29,$27,$3E,$8D     ; $7387  たたかえは゛ = たたかえば
    db $90                         ; $738D  　(space)
    db $29,$37,$50,$29             ; $738E  かてるか
    db $98                         ; $7392  ？
    db $EF,$EE                     ; $7393  newline
    db $90,$90                     ; $7395  　　(indent)
    db $32,$51,$54,$35,$3C,$3A     ; $7397  それをつねに
    db $90                         ; $739D  　(space)
    db $29,$55,$29,$8D,$27,$37,$25,$43,$30; $739E  かんか゛えています = かんがえています
    db $8F                         ; $73A7  。
    db $F7                         ; $73A8  clear page
    db $F0                         ; $73A9  end of message


; --------------------------------------------------------------------------
; Message #166 ($73AA)
;   「てきかくな　せんとうほじょは
;   むぼうなこうげきに　まさります。
; --------------------------------------------------------------------------
Bank66_Msg166:                               ; $73AA  (file $10B3AA)
    db $EA                         ; $73AA  ▶ new page
    db $9F                         ; $73AB  box tag
    db $96                         ; $73AC  end name/box tag
    db $37,$2A,$29,$2B,$39         ; $73AD  てきかくな
    db $90                         ; $73B2  　(space)
    db $31,$55,$38,$26,$42,$2F,$8D,$4D,$3E; $73B3  せんとうほし゛ょは = せんとうほじょは
    db $EF,$EE                     ; $73BC  newline
    db $90,$90                     ; $73BE  　　(indent)
    db $45,$42,$8D,$26,$39,$2D,$26,$2C,$8D,$2A,$3A; $73C0  むほ゛うなこうけ゛きに = むぼうなこうげきに
    db $90                         ; $73CB  　(space)
    db $43,$2E,$4F,$43,$30         ; $73CC  まさります
    db $8F                         ; $73D1  。
    db $F7                         ; $73D2  clear page
    db $F0                         ; $73D3  end of message


; --------------------------------------------------------------------------
; Message #167 ($73D4)
;   「だいじょうぶ。　わたくしが
;   みんなを　みちびいてゆきます、。
; --------------------------------------------------------------------------
Bank66_Msg167:                               ; $73D4  (file $10B3D4)
    db $EA                         ; $73D4  ▶ new page
    db $9F                         ; $73D5  box tag
    db $96                         ; $73D6  end name/box tag
    db $33,$8D,$25,$2F,$8D,$4D,$26,$40,$8D; $73D7  た゛いし゛ょうふ゛ = だいじょうぶ
    db $8F                         ; $73E0  。
    db $90                         ; $73E1  　(space)
    db $53,$33,$2B,$2F,$29,$8D     ; $73E2  わたくしか゛ = わたくしが
    db $EF,$EE                     ; $73E8  newline
    db $90,$90                     ; $73EA  　　(indent)
    db $44,$55,$39,$54             ; $73EC  みんなを
    db $90                         ; $73F0  　(space)
    db $44,$34,$3F,$8D,$25,$37,$4A,$2A,$43,$30; $73F1  みちひ゛いてゆきます = みちびいてゆきます
    db $A4                         ; $73FB  、
    db $8F                         ; $73FC  。
    db $F7                         ; $73FD  clear page
    db $F0                         ; $73FE  end of message


; --------------------------------------------------------------------------
; Message #168 ($73FF)
;   「ひとつ　いいことをおしえよう。
;   おうごんのスラィムのでんせつだ。
;   「、あるひ　スラィムのおうさまが
;   おうごんにひかる　まものをみた。
;   「おうさまは　ひとめぼれし
;   けっこんをもうしこんだ。
;   「やがて　おうごんにかがやく
;   スラィムが　うまれたという、。
; --------------------------------------------------------------------------
Bank66_Msg168:                               ; $73FF  (file $10B3FF)
    db $EA                         ; $73FF  ▶ new page
    db $9F                         ; $7400  box tag
    db $96                         ; $7401  end name/box tag
    db $3F,$38,$35                 ; $7402  ひとつ
    db $90                         ; $7405  　(space)
    db $25,$25,$2D,$38,$54,$28,$2F,$27,$4C,$26; $7406  いいことをおしえよう
    db $8F                         ; $7410  。
    db $EF,$EE                     ; $7411  newline
    db $90,$90                     ; $7413  　　(indent)
    db $28,$26,$2D,$8D,$55,$3D,$67,$85,$58,$7C,$3D,$37,$8D,$55,$31,$35,$33,$8D; $7415  おうこ゛んのスラィムのて゛んせつた゛ = おうごんのスラィムのでんせつだ
    db $8F                         ; $7427  。
    db $FA                         ; $7428  wait-for-button
    db $F7                         ; $7429  clear page
    db $EF,$EE                     ; $742A  newline
    db $9F                         ; $742C  box tag
    db $96                         ; $742D  end name/box tag
    db $A4                         ; $742E  、
    db $24,$50,$3F                 ; $742F  あるひ
    db $90                         ; $7432  　(space)
    db $67,$85,$58,$7C,$3D,$28,$26,$2E,$43,$29,$8D; $7433  スラィムのおうさまか゛ = スラィムのおうさまが
    db $EF,$EE                     ; $743E  newline
    db $90,$90                     ; $7440  　　(indent)
    db $28,$26,$2D,$8D,$55,$3A,$3F,$29,$50; $7442  おうこ゛んにひかる = おうごんにひかる
    db $90                         ; $744B  　(space)
    db $43,$47,$3D,$54,$44,$33     ; $744C  まものをみた
    db $8F                         ; $7452  。
    db $FA                         ; $7453  wait-for-button
    db $F7                         ; $7454  clear page
    db $EF,$EE                     ; $7455  newline
    db $9F                         ; $7457  box tag
    db $96                         ; $7458  end name/box tag
    db $28,$26,$2E,$43,$3E         ; $7459  おうさまは
    db $90                         ; $745E  　(space)
    db $3F,$38,$46,$42,$8D,$51,$2F ; $745F  ひとめほ゛れし = ひとめぼれし
    db $EF,$EE                     ; $7466  newline
    db $90,$90                     ; $7468  　　(indent)
    db $2C,$36,$2D,$55,$54,$47,$26,$2F,$2D,$55,$33,$8D; $746A  けっこんをもうしこんた゛ = けっこんをもうしこんだ
    db $8F                         ; $7476  。
    db $FA                         ; $7477  wait-for-button
    db $F7                         ; $7478  clear page
    db $EF,$EE                     ; $7479  newline
    db $9F                         ; $747B  box tag
    db $96                         ; $747C  end name/box tag
    db $48,$29,$8D,$37             ; $747D  やか゛て = やがて
    db $90                         ; $7481  　(space)
    db $28,$26,$2D,$8D,$55,$3A,$29,$29,$8D,$48,$2B; $7482  おうこ゛んにかか゛やく = おうごんにかがやく
    db $EF,$EE                     ; $748D  newline
    db $90,$90                     ; $748F  　　(indent)
    db $67,$85,$58,$7C,$29,$8D     ; $7491  スラィムか゛ = スラィムが
    db $90                         ; $7497  　(space)
    db $26,$43,$51,$33,$38,$25,$26 ; $7498  うまれたという
    db $A4                         ; $749F  、
    db $8F                         ; $74A0  。
    db $F7                         ; $74A1  clear page
    db $F0                         ; $74A2  end of message


; --------------------------------------------------------------------------
; Message #169 ($74A3)
;   「なにごとも　ほどほどが
;   いちばん！
; --------------------------------------------------------------------------
Bank66_Msg169:                               ; $74A3  (file $10B4A3)
    db $EB                         ; $74A3  ▶ new page
    db $9F                         ; $74A4  box tag
    db $96                         ; $74A5  end name/box tag
    db $39,$3A,$2D,$8D,$38,$47     ; $74A6  なにこ゛とも = なにごとも
    db $90                         ; $74AC  　(space)
    db $42,$38,$8D,$42,$38,$8D,$29,$8D; $74AD  ほと゛ほと゛か゛ = ほどほどが
    db $EF,$EE                     ; $74B5  newline
    db $90,$90                     ; $74B7  　　(indent)
    db $25,$34,$3E,$8D,$55         ; $74B9  いちは゛ん = いちばん
    db $99                         ; $74BE  ！
    db $F7                         ; $74BF  clear page
    db $F0                         ; $74C0  end of message


; --------------------------------------------------------------------------
; Message #170 ($74C1)
;   「フツーにしてれば
;   フツーにかてます！
; --------------------------------------------------------------------------
Bank66_Msg170:                               ; $74C1  (file $10B4C1)
    db $EB                         ; $74C1  ▶ new page
    db $9F                         ; $74C2  box tag
    db $96                         ; $74C3  end name/box tag
    db $77,$6C,$9C,$3A,$2F,$37,$51,$3E,$8D; $74C4  フツーにしてれは゛ = フツーにしてれば
    db $EF,$EE                     ; $74CD  newline
    db $90,$90                     ; $74CF  　　(indent)
    db $77,$6C,$9C,$3A,$29,$37,$43,$30; $74D1  フツーにかてます
    db $99                         ; $74D9  ！
    db $F7                         ; $74DA  clear page
    db $F0                         ; $74DB  end of message


; --------------------------------------------------------------------------
; Message #171 ($74DC)
;   「さあ！
;   がんばっていきましょー！
; --------------------------------------------------------------------------
Bank66_Msg171:                               ; $74DC  (file $10B4DC)
    db $EB                         ; $74DC  ▶ new page
    db $9F                         ; $74DD  box tag
    db $96                         ; $74DE  end name/box tag
    db $2E,$24                     ; $74DF  さあ
    db $99                         ; $74E1  ！
    db $EF,$EE                     ; $74E2  newline
    db $90,$90                     ; $74E4  　　(indent)
    db $29,$8D,$55,$3E,$8D,$36,$37,$25,$2A,$43,$2F,$4D,$9C; $74E6  か゛んは゛っていきましょー = がんばっていきましょー
    db $99                         ; $74F3  ！
    db $F7                         ; $74F4  clear page
    db $F0                         ; $74F5  end of message


; --------------------------------------------------------------------------
; Message #172 ($74F6)
;   「〈テリー〉！
;   これからも　よろしく！
; --------------------------------------------------------------------------
Bank66_Msg172:                               ; $74F6  (file $10B4F6)
    db $EB                         ; $74F6  ▶ new page
    db $9F                         ; $74F7  box tag
    db $96                         ; $74F8  end name/box tag
    db $F6                         ; $74F9  «insert hero name» (テリー)
    db $99                         ; $74FA  ！
    db $EF,$EE                     ; $74FB  newline
    db $90,$90                     ; $74FD  　　(indent)
    db $2D,$51,$29,$4E,$47         ; $74FF  これからも
    db $90                         ; $7504  　(space)
    db $4C,$52,$2F,$2B             ; $7505  よろしく
    db $99                         ; $7509  ！
    db $F7                         ; $750A  clear page
    db $F0                         ; $750B  end of message


; --------------------------------------------------------------------------
; Message #173 ($750C)
;   「あわわわわ！　いつも　きがつくと
;   せんとうが　おわっています。
; --------------------------------------------------------------------------
Bank66_Msg173:                               ; $750C  (file $10B50C)
    db $EB                         ; $750C  ▶ new page
    db $9F                         ; $750D  box tag
    db $96                         ; $750E  end name/box tag
    db $24,$53,$53,$53,$53         ; $750F  あわわわわ
    db $99                         ; $7514  ！
    db $90                         ; $7515  　(space)
    db $25,$35,$47                 ; $7516  いつも
    db $90                         ; $7519  　(space)
    db $2A,$29,$8D,$35,$2B,$38     ; $751A  きか゛つくと = きがつくと
    db $EF,$EE                     ; $7520  newline
    db $90,$90                     ; $7522  　　(indent)
    db $31,$55,$38,$26,$29,$8D     ; $7524  せんとうか゛ = せんとうが
    db $90                         ; $752A  　(space)
    db $28,$53,$36,$37,$25,$43,$30 ; $752B  おわっています
    db $8F                         ; $7532  。
    db $F7                         ; $7533  clear page
    db $F0                         ; $7534  end of message


; --------------------------------------------------------------------------
; Message #174 ($7535)
;   「ほんとはもっと　みなさんの
;   おやくにたつこと　したいんです！
;   「でも　いざとなると
;   あわてちゃって、、。
; --------------------------------------------------------------------------
Bank66_Msg174:                               ; $7535  (file $10B535)
    db $EB                         ; $7535  ▶ new page
    db $9F                         ; $7536  box tag
    db $96                         ; $7537  end name/box tag
    db $42,$55,$38,$3E,$47,$36,$38 ; $7538  ほんとはもっと
    db $90                         ; $753F  　(space)
    db $44,$39,$2E,$55,$3D         ; $7540  みなさんの
    db $EF,$EE                     ; $7545  newline
    db $90,$90                     ; $7547  　　(indent)
    db $28,$48,$2B,$3A,$33,$35,$2D,$38; $7549  おやくにたつこと
    db $90                         ; $7551  　(space)
    db $2F,$33,$25,$55,$37,$8D,$30 ; $7552  したいんて゛す = したいんです
    db $99                         ; $7559  ！
    db $FA                         ; $755A  wait-for-button
    db $F7                         ; $755B  clear page
    db $EF,$EE                     ; $755C  newline
    db $9F                         ; $755E  box tag
    db $96                         ; $755F  end name/box tag
    db $37,$8D,$47                 ; $7560  て゛も = でも
    db $90                         ; $7563  　(space)
    db $25,$2E,$8D,$38,$39,$50,$38 ; $7564  いさ゛となると = いざとなると
    db $EF,$EE                     ; $756B  newline
    db $90,$90                     ; $756D  　　(indent)
    db $24,$53,$37,$34,$49,$36,$37 ; $756F  あわてちゃって
    db $A4                         ; $7576  、
    db $A4                         ; $7577  、
    db $8F                         ; $7578  。
    db $F7                         ; $7579  clear page
    db $F0                         ; $757A  end of message


; --------------------------------------------------------------------------
; Message #175 ($757B)
;   「スーハー、、。
;   スーハー、、。
;   「おちついて　おちついて、、。
;   あわてない　あわてない、、。
; --------------------------------------------------------------------------
Bank66_Msg175:                               ; $757B  (file $10B57B)
    db $EB                         ; $757B  ▶ new page
    db $9F                         ; $757C  box tag
    db $96                         ; $757D  end name/box tag
    db $67,$9C,$75,$9C             ; $757E  スーハー
    db $A4                         ; $7582  、
    db $A4                         ; $7583  、
    db $8F                         ; $7584  。
    db $EF,$EE                     ; $7585  newline
    db $90,$90                     ; $7587  　　(indent)
    db $67,$9C,$75,$9C             ; $7589  スーハー
    db $A4                         ; $758D  、
    db $A4                         ; $758E  、
    db $8F                         ; $758F  。
    db $FA                         ; $7590  wait-for-button
    db $F7                         ; $7591  clear page
    db $EF,$EE                     ; $7592  newline
    db $9F                         ; $7594  box tag
    db $96                         ; $7595  end name/box tag
    db $28,$34,$35,$25,$37         ; $7596  おちついて
    db $90                         ; $759B  　(space)
    db $28,$34,$35,$25,$37         ; $759C  おちついて
    db $A4                         ; $75A1  、
    db $A4                         ; $75A2  、
    db $8F                         ; $75A3  。
    db $EF,$EE                     ; $75A4  newline
    db $90,$90                     ; $75A6  　　(indent)
    db $24,$53,$37,$39,$25         ; $75A8  あわてない
    db $90                         ; $75AD  　(space)
    db $24,$53,$37,$39,$25         ; $75AE  あわてない
    db $A4                         ; $75B3  、
    db $A4                         ; $75B4  、
    db $8F                         ; $75B5  。
    db $F7                         ; $75B6  clear page
    db $F0                         ; $75B7  end of message


; --------------------------------------------------------------------------
; Message #176 ($75B8)
;   「わたしが　あわてているって？
;   ななな　なにを　もうすか！？
; --------------------------------------------------------------------------
Bank66_Msg176:                               ; $75B8  (file $10B5B8)
    db $EB                         ; $75B8  ▶ new page
    db $9F                         ; $75B9  box tag
    db $96                         ; $75BA  end name/box tag
    db $53,$33,$2F,$29,$8D         ; $75BB  わたしか゛ = わたしが
    db $90                         ; $75C0  　(space)
    db $24,$53,$37,$37,$25,$50,$36,$37; $75C1  あわてているって
    db $98                         ; $75C9  ？
    db $EF,$EE                     ; $75CA  newline
    db $90,$90                     ; $75CC  　　(indent)
    db $39,$39,$39                 ; $75CE  ななな
    db $90                         ; $75D1  　(space)
    db $39,$3A,$54                 ; $75D2  なにを
    db $90                         ; $75D5  　(space)
    db $47,$26,$30,$29             ; $75D6  もうすか
    db $99                         ; $75DA  ！
    db $98                         ; $75DB  ？
    db $F7                         ; $75DC  clear page
    db $F0                         ; $75DD  end of message


; --------------------------------------------------------------------------
; Message #177 ($75DE)
;   「フンッ。
;   ホィミなしで　かってやらあ！
; --------------------------------------------------------------------------
Bank66_Msg177:                               ; $75DE  (file $10B5DE)
    db $EA                         ; $75DE  ▶ new page
    db $9F                         ; $75DF  box tag
    db $96                         ; $75E0  end name/box tag
    db $77,$8C,$6D                 ; $75E1  フンッ
    db $8F                         ; $75E4  。
    db $EF,$EE                     ; $75E5  newline
    db $90,$90                     ; $75E7  　　(indent)
    db $79,$58,$7B,$39,$2F,$37,$8D ; $75E9  ホィミなして゛ = ホィミなしで
    db $90                         ; $75F0  　(space)
    db $29,$36,$37,$48,$4E,$24     ; $75F1  かってやらあ
    db $99                         ; $75F7  ！
    db $F7                         ; $75F8  clear page
    db $F0                         ; $75F9  end of message


; --------------------------------------------------------------------------
; Message #178 ($75FA)
;   「てやんでい！
;   「かいふくなんて　まどろっこしい！
;   べらんめえ！
; --------------------------------------------------------------------------
Bank66_Msg178:                               ; $75FA  (file $10B5FA)
    db $EA                         ; $75FA  ▶ new page
    db $9F                         ; $75FB  box tag
    db $96                         ; $75FC  end name/box tag
    db $37,$48,$55,$37,$8D,$25     ; $75FD  てやんて゛い = てやんでい
    db $99                         ; $7603  ！
    db $EF,$EE                     ; $7604  newline
    db $FA                         ; $7606  wait-for-button
    db $F7                         ; $7607  clear page
    db $EF,$EE                     ; $7608  newline
    db $F3                         ; $760A  open text box
    db $9F                         ; $760B  box tag
    db $96                         ; $760C  end name/box tag
    db $29,$25,$40,$2B,$39,$55,$37 ; $760D  かいふくなんて
    db $90                         ; $7614  　(space)
    db $43,$38,$8D,$52,$36,$2D,$2F,$25; $7615  まと゛ろっこしい = まどろっこしい
    db $99                         ; $761D  ！
    db $EF,$EE                     ; $761E  newline
    db $90,$90                     ; $7620  　　(indent)
    db $41,$8D,$4E,$55,$46,$27     ; $7622  へ゛らんめえ = べらんめえ
    db $99                         ; $7628  ！
    db $F7                         ; $7629  clear page
    db $F0                         ; $762A  end of message


; --------------------------------------------------------------------------
; Message #179 ($762B)
;   「だまらっしゃい！
;   「いま　たたかいかたを
;   あんしょう　しておるのだ、、。
; --------------------------------------------------------------------------
Bank66_Msg179:                               ; $762B  (file $10B62B)
    db $EA                         ; $762B  ▶ new page
    db $9F                         ; $762C  box tag
    db $96                         ; $762D  end name/box tag
    db $33,$8D,$43,$4E,$36,$2F,$49,$25; $762E  た゛まらっしゃい = だまらっしゃい
    db $99                         ; $7636  ！
    db $EF,$EE                     ; $7637  newline
    db $FA                         ; $7639  wait-for-button
    db $F7                         ; $763A  clear page
    db $EF,$EE                     ; $763B  newline
    db $F3                         ; $763D  open text box
    db $9F                         ; $763E  box tag
    db $96                         ; $763F  end name/box tag
    db $25,$43                     ; $7640  いま
    db $90                         ; $7642  　(space)
    db $33,$33,$29,$25,$29,$33,$54 ; $7643  たたかいかたを
    db $EF,$EE                     ; $764A  newline
    db $90,$90                     ; $764C  　　(indent)
    db $24,$55,$2F,$4D,$26         ; $764E  あんしょう
    db $90                         ; $7653  　(space)
    db $2F,$37,$28,$50,$3D,$33,$8D ; $7654  しておるのた゛ = しておるのだ
    db $A4                         ; $765B  、
    db $A4                         ; $765C  、
    db $8F                         ; $765D  。
    db $F7                         ; $765E  clear page
    db $F0                         ; $765F  end of message


; --------------------------------------------------------------------------
; Message #180 ($7660)
;   「だれが　なんといおうと　たたかい
;   つづけるのだ。　よいな！？
; --------------------------------------------------------------------------
Bank66_Msg180:                               ; $7660  (file $10B660)
    db $EA                         ; $7660  ▶ new page
    db $9F                         ; $7661  box tag
    db $96                         ; $7662  end name/box tag
    db $33,$8D,$51,$29,$8D         ; $7663  た゛れか゛ = だれが
    db $90                         ; $7668  　(space)
    db $39,$55,$38,$25,$28,$26,$38 ; $7669  なんといおうと
    db $90                         ; $7670  　(space)
    db $33,$33,$29,$25             ; $7671  たたかい
    db $EF,$EE                     ; $7675  newline
    db $90,$90                     ; $7677  　　(indent)
    db $35,$35,$8D,$2C,$50,$3D,$33,$8D; $7679  つつ゛けるのた゛ = つづけるのだ
    db $8F                         ; $7681  。
    db $90                         ; $7682  　(space)
    db $4C,$25,$39                 ; $7683  よいな
    db $99                         ; $7686  ！
    db $98                         ; $7687  ？
    db $F7                         ; $7688  clear page
    db $F0                         ; $7689  end of message


; --------------------------------------------------------------------------
; Message #181 ($768A)
;   「わたしの　どこが　おもいやりが
;   ないって　いうんですか？！
;   「、、すねてやる！！
; --------------------------------------------------------------------------
Bank66_Msg181:                               ; $768A  (file $10B68A)
    db $EB                         ; $768A  ▶ new page
    db $9F                         ; $768B  box tag
    db $96                         ; $768C  end name/box tag
    db $53,$33,$2F,$3D             ; $768D  わたしの
    db $90                         ; $7691  　(space)
    db $38,$8D,$2D,$29,$8D         ; $7692  と゛こか゛ = どこが
    db $90                         ; $7697  　(space)
    db $28,$47,$25,$48,$4F,$29,$8D ; $7698  おもいやりか゛ = おもいやりが
    db $EF,$EE                     ; $769F  newline
    db $90,$90                     ; $76A1  　　(indent)
    db $39,$25,$36,$37             ; $76A3  ないって
    db $90                         ; $76A7  　(space)
    db $25,$26,$55,$37,$8D,$30,$29 ; $76A8  いうんて゛すか = いうんですか
    db $98                         ; $76AF  ？
    db $99                         ; $76B0  ！
    db $FA                         ; $76B1  wait-for-button
    db $F7                         ; $76B2  clear page
    db $EF,$EE                     ; $76B3  newline
    db $9F                         ; $76B5  box tag
    db $96                         ; $76B6  end name/box tag
    db $A4                         ; $76B7  、
    db $A4                         ; $76B8  、
    db $30,$3C,$37,$48,$50         ; $76B9  すねてやる
    db $99                         ; $76BE  ！
    db $99                         ; $76BF  ！
    db $EF,$EE                     ; $76C0  newline
    db $F7                         ; $76C2  clear page
    db $F0                         ; $76C3  end of message


; --------------------------------------------------------------------------
; Message #182 ($76C4)
;   「、、べつに
;   ひねくれてなんか　ないやい！
; --------------------------------------------------------------------------
Bank66_Msg182:                               ; $76C4  (file $10B6C4)
    db $EB                         ; $76C4  ▶ new page
    db $9F                         ; $76C5  box tag
    db $96                         ; $76C6  end name/box tag
    db $A4                         ; $76C7  、
    db $A4                         ; $76C8  、
    db $41,$8D,$35,$3A             ; $76C9  へ゛つに = べつに
    db $EF,$EE                     ; $76CD  newline
    db $90,$90                     ; $76CF  　　(indent)
    db $3F,$3C,$2B,$51,$37,$39,$55,$29; $76D1  ひねくれてなんか
    db $90                         ; $76D9  　(space)
    db $39,$25,$48,$25             ; $76DA  ないやい
    db $99                         ; $76DE  ！
    db $F7                         ; $76DF  clear page
    db $F0                         ; $76E0  end of message


; --------------------------------------------------------------------------
; Message #183 ($76E1)
;   「どうして　わたしが　ひねくれて
;   いるんですか！？
;   「くそ[93]！　ひねくれてやる！
; --------------------------------------------------------------------------
Bank66_Msg183:                               ; $76E1  (file $10B6E1)
    db $EB                         ; $76E1  ▶ new page
    db $9F                         ; $76E2  box tag
    db $96                         ; $76E3  end name/box tag
    db $38,$8D,$26,$2F,$37         ; $76E4  と゛うして = どうして
    db $90                         ; $76E9  　(space)
    db $53,$33,$2F,$29,$8D         ; $76EA  わたしか゛ = わたしが
    db $90                         ; $76EF  　(space)
    db $3F,$3C,$2B,$51,$37         ; $76F0  ひねくれて
    db $EF,$EE                     ; $76F5  newline
    db $90,$90                     ; $76F7  　　(indent)
    db $25,$50,$55,$37,$8D,$30,$29 ; $76F9  いるんて゛すか = いるんですか
    db $99                         ; $7700  ！
    db $98                         ; $7701  ？
    db $FA                         ; $7702  wait-for-button
    db $F7                         ; $7703  clear page
    db $EF,$EE                     ; $7704  newline
    db $9F                         ; $7706  box tag
    db $96                         ; $7707  end name/box tag
    db $2B,$32                     ; $7708  くそ
    db $93                         ; $770A  ctrl $93
    db $99                         ; $770B  ！
    db $90                         ; $770C  　(space)
    db $3F,$3C,$2B,$51,$37,$48,$50 ; $770D  ひねくれてやる
    db $99                         ; $7714  ！
    db $EF,$EE                     ; $7715  newline
    db $F7                         ; $7717  clear page
    db $F0                         ; $7718  end of message


; --------------------------------------------------------------------------
; Message #184 ($7719)
;   「え？　これから　しあいだって？
;   うむ。　いきたくないな。
;   「は？　やっぱり　やめた？
;   では　しあいに　いこうかな。
; --------------------------------------------------------------------------
Bank66_Msg184:                               ; $7719  (file $10B719)
    db $EB                         ; $7719  ▶ new page
    db $9F                         ; $771A  box tag
    db $96                         ; $771B  end name/box tag
    db $27                         ; $771C  え
    db $98                         ; $771D  ？
    db $90                         ; $771E  　(space)
    db $2D,$51,$29,$4E             ; $771F  これから
    db $90                         ; $7723  　(space)
    db $2F,$24,$25,$33,$8D,$36,$37 ; $7724  しあいた゛って = しあいだって
    db $98                         ; $772B  ？
    db $EF,$EE                     ; $772C  newline
    db $90,$90                     ; $772E  　　(indent)
    db $26,$45                     ; $7730  うむ
    db $8F                         ; $7732  。
    db $90                         ; $7733  　(space)
    db $25,$2A,$33,$2B,$39,$25,$39 ; $7734  いきたくないな
    db $8F                         ; $773B  。
    db $FA                         ; $773C  wait-for-button
    db $F7                         ; $773D  clear page
    db $EF,$EE                     ; $773E  newline
    db $9F                         ; $7740  box tag
    db $96                         ; $7741  end name/box tag
    db $3E                         ; $7742  は
    db $98                         ; $7743  ？
    db $90                         ; $7744  　(space)
    db $48,$36,$3E,$8E,$4F         ; $7745  やっは゜り = やっぱり
    db $90                         ; $774A  　(space)
    db $48,$46,$33                 ; $774B  やめた
    db $98                         ; $774E  ？
    db $EF,$EE                     ; $774F  newline
    db $90,$90                     ; $7751  　　(indent)
    db $37,$8D,$3E                 ; $7753  て゛は = では
    db $90                         ; $7756  　(space)
    db $2F,$24,$25,$3A             ; $7757  しあいに
    db $90                         ; $775B  　(space)
    db $25,$2D,$26,$29,$39         ; $775C  いこうかな
    db $8F                         ; $7761  。
    db $F7                         ; $7762  clear page
    db $F0                         ; $7763  end of message


; --------------------------------------------------------------------------
; Message #185 ($7764)
;   「てきには　こうげきしか
;   したくないやい！
; --------------------------------------------------------------------------
Bank66_Msg185:                               ; $7764  (file $10B764)
    db $EB                         ; $7764  ▶ new page
    db $9F                         ; $7765  box tag
    db $96                         ; $7766  end name/box tag
    db $37,$2A,$3A,$3E             ; $7767  てきには
    db $90                         ; $776B  　(space)
    db $2D,$26,$2C,$8D,$2A,$2F,$29 ; $776C  こうけ゛きしか = こうげきしか
    db $EF,$EE                     ; $7773  newline
    db $90,$90                     ; $7775  　　(indent)
    db $2F,$33,$2B,$39,$25,$48,$25 ; $7777  したくないやい
    db $99                         ; $777E  ！
    db $F7                         ; $777F  clear page
    db $F0                         ; $7780  end of message


; --------------------------------------------------------------------------
; Message #186 ($7781)
;   「わるいが　こうげき　ちゅうしんで
;   いかせてもらう！！
; --------------------------------------------------------------------------
Bank66_Msg186:                               ; $7781  (file $10B781)
    db $EB                         ; $7781  ▶ new page
    db $9F                         ; $7782  box tag
    db $96                         ; $7783  end name/box tag
    db $53,$50,$25,$29,$8D         ; $7784  わるいか゛ = わるいが
    db $90                         ; $7789  　(space)
    db $2D,$26,$2C,$8D,$2A         ; $778A  こうけ゛き = こうげき
    db $90                         ; $778F  　(space)
    db $34,$4B,$26,$2F,$55,$37,$8D ; $7790  ちゅうしんて゛ = ちゅうしんで
    db $EF,$EE                     ; $7797  newline
    db $90,$90                     ; $7799  　　(indent)
    db $25,$29,$31,$37,$47,$4E,$26 ; $779B  いかせてもらう
    db $99                         ; $77A2  ！
    db $99                         ; $77A3  ！
    db $F7                         ; $77A4  clear page
    db $F0                         ; $77A5  end of message


; --------------------------------------------------------------------------
; Message #187 ($77A6)
;   「わが　みちを　ゆく！
; --------------------------------------------------------------------------
Bank66_Msg187:                               ; $77A6  (file $10B7A6)
    db $EB                         ; $77A6  ▶ new page
    db $9F                         ; $77A7  box tag
    db $96                         ; $77A8  end name/box tag
    db $53,$29,$8D                 ; $77A9  わか゛ = わが
    db $90                         ; $77AC  　(space)
    db $44,$34,$54                 ; $77AD  みちを
    db $90                         ; $77B0  　(space)
    db $4A,$2B                     ; $77B1  ゆく
    db $99                         ; $77B3  ！
    db $EF,$EE                     ; $77B4  newline
    db $F7                         ; $77B6  clear page
    db $F0                         ; $77B7  end of message


; --------------------------------------------------------------------------
; Message #188 ($77B8)
;   「わたしに　さしず　するきか！？
;   なんと　あつかましいやつ、、。
; --------------------------------------------------------------------------
Bank66_Msg188:                               ; $77B8  (file $10B7B8)
    db $EB                         ; $77B8  ▶ new page
    db $9F                         ; $77B9  box tag
    db $96                         ; $77BA  end name/box tag
    db $53,$33,$2F,$3A             ; $77BB  わたしに
    db $90                         ; $77BF  　(space)
    db $2E,$2F,$30,$8D             ; $77C0  さしす゛ = さしず
    db $90                         ; $77C4  　(space)
    db $30,$50,$2A,$29             ; $77C5  するきか
    db $99                         ; $77C9  ！
    db $98                         ; $77CA  ？
    db $EF,$EE                     ; $77CB  newline
    db $90,$90                     ; $77CD  　　(indent)
    db $39,$55,$38                 ; $77CF  なんと
    db $90                         ; $77D2  　(space)
    db $24,$35,$29,$43,$2F,$25,$48,$35; $77D3  あつかましいやつ
    db $A4                         ; $77DB  、
    db $A4                         ; $77DC  、
    db $8F                         ; $77DD  。
    db $F7                         ; $77DE  clear page
    db $F0                         ; $77DF  end of message


; --------------------------------------------------------------------------
; Message #189 ($77E0)
;   「こまってる　まものを　みると
;   ほっとけないんです！
; --------------------------------------------------------------------------
Bank66_Msg189:                               ; $77E0  (file $10B7E0)
    db $EA                         ; $77E0  ▶ new page
    db $9F                         ; $77E1  box tag
    db $96                         ; $77E2  end name/box tag
    db $2D,$43,$36,$37,$50         ; $77E3  こまってる
    db $90                         ; $77E8  　(space)
    db $43,$47,$3D,$54             ; $77E9  まものを
    db $90                         ; $77ED  　(space)
    db $44,$50,$38                 ; $77EE  みると
    db $EF,$EE                     ; $77F1  newline
    db $90,$90                     ; $77F3  　　(indent)
    db $42,$36,$38,$2C,$39,$25,$55,$37,$8D,$30; $77F5  ほっとけないんて゛す = ほっとけないんです
    db $99                         ; $77FF  ！
    db $F7                         ; $7800  clear page
    db $F0                         ; $7801  end of message


; --------------------------------------------------------------------------
; Message #190 ($7802)
;   「いやー。　あまり　こうげきって
;   すきじゃないんですよねー。
; --------------------------------------------------------------------------
Bank66_Msg190:                               ; $7802  (file $10B802)
    db $EA                         ; $7802  ▶ new page
    db $9F                         ; $7803  box tag
    db $96                         ; $7804  end name/box tag
    db $25,$48,$9C                 ; $7805  いやー
    db $8F                         ; $7808  。
    db $90                         ; $7809  　(space)
    db $24,$43,$4F                 ; $780A  あまり
    db $90                         ; $780D  　(space)
    db $2D,$26,$2C,$8D,$2A,$36,$37 ; $780E  こうけ゛きって = こうげきって
    db $EF,$EE                     ; $7815  newline
    db $90,$90                     ; $7817  　　(indent)
    db $30,$2A,$2F,$8D,$49,$39,$25,$55,$37,$8D,$30,$4C,$3C,$9C; $7819  すきし゛ゃないんて゛すよねー = すきじゃないんですよねー
    db $8F                         ; $7827  。
    db $F7                         ; $7828  clear page
    db $F0                         ; $7829  end of message


; --------------------------------------------------------------------------
; Message #191 ($782A)
;   「わたしは　みんなに　きもちよく
;   たたかってもらえれば　いいです！
; --------------------------------------------------------------------------
Bank66_Msg191:                               ; $782A  (file $10B82A)
    db $EA                         ; $782A  ▶ new page
    db $9F                         ; $782B  box tag
    db $96                         ; $782C  end name/box tag
    db $53,$33,$2F,$3E             ; $782D  わたしは
    db $90                         ; $7831  　(space)
    db $44,$55,$39,$3A             ; $7832  みんなに
    db $90                         ; $7836  　(space)
    db $2A,$47,$34,$4C,$2B         ; $7837  きもちよく
    db $EF,$EE                     ; $783C  newline
    db $90,$90                     ; $783E  　　(indent)
    db $33,$33,$29,$36,$37,$47,$4E,$27,$51,$3E,$8D; $7840  たたかってもらえれは゛ = たたかってもらえれば
    db $90                         ; $784B  　(space)
    db $25,$25,$37,$8D,$30         ; $784C  いいて゛す = いいです
    db $99                         ; $7851  ！
    db $F7                         ; $7852  clear page
    db $F0                         ; $7853  end of message


; --------------------------------------------------------------------------
; Message #192 ($7854)
;   「きずつき　たおれそうなものを
;   みると　いてもたってもおられぬ！
; --------------------------------------------------------------------------
Bank66_Msg192:                               ; $7854  (file $10B854)
    db $EA                         ; $7854  ▶ new page
    db $9F                         ; $7855  box tag
    db $96                         ; $7856  end name/box tag
    db $2A,$30,$8D,$35,$2A         ; $7857  きす゛つき = きずつき
    db $90                         ; $785C  　(space)
    db $33,$28,$51,$32,$26,$39,$47,$3D,$54; $785D  たおれそうなものを
    db $EF,$EE                     ; $7866  newline
    db $90,$90                     ; $7868  　　(indent)
    db $44,$50,$38                 ; $786A  みると
    db $90                         ; $786D  　(space)
    db $25,$37,$47,$33,$36,$37,$47,$28,$4E,$51,$3B; $786E  いてもたってもおられぬ
    db $99                         ; $7879  ！
    db $F7                         ; $787A  clear page
    db $F0                         ; $787B  end of message


; --------------------------------------------------------------------------
; Message #193 ($787C)
;   「とっ　とりあえず　かいふくすれば
;   よっ　よろしいでしょうかっ！？
; --------------------------------------------------------------------------
Bank66_Msg193:                               ; $787C  (file $10B87C)
    db $EB                         ; $787C  ▶ new page
    db $9F                         ; $787D  box tag
    db $96                         ; $787E  end name/box tag
    db $38,$36                     ; $787F  とっ
    db $90                         ; $7881  　(space)
    db $38,$4F,$24,$27,$30,$8D     ; $7882  とりあえす゛ = とりあえず
    db $90                         ; $7888  　(space)
    db $29,$25,$40,$2B,$30,$51,$3E,$8D; $7889  かいふくすれは゛ = かいふくすれば
    db $EF,$EE                     ; $7891  newline
    db $90,$90                     ; $7893  　　(indent)
    db $4C,$36                     ; $7895  よっ
    db $90                         ; $7897  　(space)
    db $4C,$52,$2F,$25,$37,$8D,$2F,$4D,$26,$29,$36; $7898  よろしいて゛しょうかっ = よろしいでしょうかっ
    db $99                         ; $78A3  ！
    db $98                         ; $78A4  ？
    db $F7                         ; $78A5  clear page
    db $F0                         ; $78A6  end of message


; --------------------------------------------------------------------------
; Message #194 ($78A7)
;   「う[9D]ん。　なにをしたら　いちばん
;   みなさんの　やくにたつべか？
; --------------------------------------------------------------------------
Bank66_Msg194:                               ; $78A7  (file $10B8A7)
    db $EB                         ; $78A7  ▶ new page
    db $9F                         ; $78A8  box tag
    db $96                         ; $78A9  end name/box tag
    db $26                         ; $78AA  う
    db $9D                         ; $78AB  ctrl $9D
    db $55                         ; $78AC  ん
    db $8F                         ; $78AD  。
    db $90                         ; $78AE  　(space)
    db $39,$3A,$54,$2F,$33,$4E     ; $78AF  なにをしたら
    db $90                         ; $78B5  　(space)
    db $25,$34,$3E,$8D,$55         ; $78B6  いちは゛ん = いちばん
    db $EF,$EE                     ; $78BB  newline
    db $90,$90                     ; $78BD  　　(indent)
    db $44,$39,$2E,$55,$3D         ; $78BF  みなさんの
    db $90                         ; $78C4  　(space)
    db $48,$2B,$3A,$33,$35,$41,$8D,$29; $78C5  やくにたつへ゛か = やくにたつべか
    db $98                         ; $78CD  ？
    db $F7                         ; $78CE  clear page
    db $F0                         ; $78CF  end of message


; --------------------------------------------------------------------------
; Message #195 ($78D0)
;   「ううう、、。
;   にげるべきか　いくべきか、、。
;   「それが　もんだいだ！
; --------------------------------------------------------------------------
Bank66_Msg195:                               ; $78D0  (file $10B8D0)
    db $EB                         ; $78D0  ▶ new page
    db $9F                         ; $78D1  box tag
    db $96                         ; $78D2  end name/box tag
    db $26,$26,$26                 ; $78D3  ううう
    db $A4                         ; $78D6  、
    db $A4                         ; $78D7  、
    db $8F                         ; $78D8  。
    db $EF,$EE                     ; $78D9  newline
    db $90,$90                     ; $78DB  　　(indent)
    db $3A,$2C,$8D,$50,$41,$8D,$2A,$29; $78DD  にけ゛るへ゛きか = にげるべきか
    db $90                         ; $78E5  　(space)
    db $25,$2B,$41,$8D,$2A,$29     ; $78E6  いくへ゛きか = いくべきか
    db $A4                         ; $78EC  、
    db $A4                         ; $78ED  、
    db $8F                         ; $78EE  。
    db $FA                         ; $78EF  wait-for-button
    db $F7                         ; $78F0  clear page
    db $EF,$EE                     ; $78F1  newline
    db $9F                         ; $78F3  box tag
    db $96                         ; $78F4  end name/box tag
    db $32,$51,$29,$8D             ; $78F5  それか゛ = それが
    db $90                         ; $78F9  　(space)
    db $47,$55,$33,$8D,$25,$33,$8D ; $78FA  もんた゛いた゛ = もんだいだ
    db $99                         ; $7901  ！
    db $EF,$EE                     ; $7902  newline
    db $F7                         ; $7904  clear page
    db $F0                         ; $7905  end of message


; --------------------------------------------------------------------------
; Message #196 ($7906)
;   「さくせん？　〈テリー〉がきめろよ。
;   わたしに　き　きかないでくれっ。
; --------------------------------------------------------------------------
Bank66_Msg196:                               ; $7906  (file $10B906)
    db $EB                         ; $7906  ▶ new page
    db $9F                         ; $7907  box tag
    db $96                         ; $7908  end name/box tag
    db $2E,$2B,$31,$55             ; $7909  さくせん
    db $98                         ; $790D  ？
    db $90                         ; $790E  　(space)
    db $F6                         ; $790F  «insert hero name» (テリー)
    db $29,$8D,$2A,$46,$52,$4C     ; $7910  か゛きめろよ = がきめろよ
    db $8F                         ; $7916  。
    db $EF,$EE                     ; $7917  newline
    db $90,$90                     ; $7919  　　(indent)
    db $53,$33,$2F,$3A             ; $791B  わたしに
    db $90                         ; $791F  　(space)
    db $2A                         ; $7920  き
    db $90                         ; $7921  　(space)
    db $2A,$29,$39,$25,$37,$8D,$2B,$51,$36; $7922  きかないて゛くれっ = きかないでくれっ
    db $8F                         ; $792B  。
    db $F7                         ; $792C  clear page
    db $F0                         ; $792D  end of message


; --------------------------------------------------------------------------
; Message #197 ($792E)
;   「こうげきした　つもりでも
;   ぼうぎょ　しちゃうんですよ！
; --------------------------------------------------------------------------
Bank66_Msg197:                               ; $792E  (file $10B92E)
    db $EB                         ; $792E  ▶ new page
    db $9F                         ; $792F  box tag
    db $96                         ; $7930  end name/box tag
    db $2D,$26,$2C,$8D,$2A,$2F,$33 ; $7931  こうけ゛きした = こうげきした
    db $90                         ; $7938  　(space)
    db $35,$47,$4F,$37,$8D,$47     ; $7939  つもりて゛も = つもりでも
    db $EF,$EE                     ; $793F  newline
    db $90,$90                     ; $7941  　　(indent)
    db $42,$8D,$26,$2A,$8D,$4D     ; $7943  ほ゛うき゛ょ = ぼうぎょ
    db $90                         ; $7949  　(space)
    db $2F,$34,$49,$26,$55,$37,$8D,$30,$4C; $794A  しちゃうんて゛すよ = しちゃうんですよ
    db $99                         ; $7953  ！
    db $F7                         ; $7954  clear page
    db $F0                         ; $7955  end of message


; --------------------------------------------------------------------------
; Message #198 ($7956)
;   「いくら　うっかりものでも
;   みかたは　ちゃんと　たすけます！
; --------------------------------------------------------------------------
Bank66_Msg198:                               ; $7956  (file $10B956)
    db $EB                         ; $7956  ▶ new page
    db $9F                         ; $7957  box tag
    db $96                         ; $7958  end name/box tag
    db $25,$2B,$4E                 ; $7959  いくら
    db $90                         ; $795C  　(space)
    db $26,$36,$29,$4F,$47,$3D,$37,$8D,$47; $795D  うっかりものて゛も = うっかりものでも
    db $EF,$EE                     ; $7966  newline
    db $90,$90                     ; $7968  　　(indent)
    db $44,$29,$33,$3E             ; $796A  みかたは
    db $90                         ; $796E  　(space)
    db $34,$49,$55,$38             ; $796F  ちゃんと
    db $90                         ; $7973  　(space)
    db $33,$30,$2C,$43,$30         ; $7974  たすけます
    db $99                         ; $7979  ！
    db $F7                         ; $797A  clear page
    db $F0                         ; $797B  end of message


; --------------------------------------------------------------------------
; Message #199 ($797C)
;   「うっかりまもの　といえば
;   あたしの　ことでさあ！
; --------------------------------------------------------------------------
Bank66_Msg199:                               ; $797C  (file $10B97C)
    db $EB                         ; $797C  ▶ new page
    db $9F                         ; $797D  box tag
    db $96                         ; $797E  end name/box tag
    db $26,$36,$29,$4F,$43,$47,$3D ; $797F  うっかりまもの
    db $90                         ; $7986  　(space)
    db $38,$25,$27,$3E,$8D         ; $7987  といえは゛ = といえば
    db $EF,$EE                     ; $798C  newline
    db $90,$90                     ; $798E  　　(indent)
    db $24,$33,$2F,$3D             ; $7990  あたしの
    db $90                         ; $7994  　(space)
    db $2D,$38,$37,$8D,$2E,$24     ; $7995  ことて゛さあ = ことでさあ
    db $99                         ; $799B  ！
    db $F7                         ; $799C  clear page
    db $F0                         ; $799D  end of message


; --------------------------------------------------------------------------
; Message #200 ($799E)
;   「おや？　わたしの　なまえは
;   なんだったっけか？？
;   「うっかり　わすれてしまったよ。
;   ハッハッハ！
; --------------------------------------------------------------------------
Bank66_Msg200:                               ; $799E  (file $10B99E)
    db $EB                         ; $799E  ▶ new page
    db $9F                         ; $799F  box tag
    db $96                         ; $79A0  end name/box tag
    db $28,$48                     ; $79A1  おや
    db $98                         ; $79A3  ？
    db $90                         ; $79A4  　(space)
    db $53,$33,$2F,$3D             ; $79A5  わたしの
    db $90                         ; $79A9  　(space)
    db $39,$43,$27,$3E             ; $79AA  なまえは
    db $EF,$EE                     ; $79AE  newline
    db $90,$90                     ; $79B0  　　(indent)
    db $39,$55,$33,$8D,$36,$33,$36,$2C,$29; $79B2  なんた゛ったっけか = なんだったっけか
    db $98                         ; $79BB  ？
    db $98                         ; $79BC  ？
    db $FA                         ; $79BD  wait-for-button
    db $F7                         ; $79BE  clear page
    db $EF,$EE                     ; $79BF  newline
    db $9F                         ; $79C1  box tag
    db $96                         ; $79C2  end name/box tag
    db $26,$36,$29,$4F             ; $79C3  うっかり
    db $90                         ; $79C7  　(space)
    db $53,$30,$51,$37,$2F,$43,$36,$33,$4C; $79C8  わすれてしまったよ
    db $8F                         ; $79D1  。
    db $EF,$EE                     ; $79D2  newline
    db $90,$90                     ; $79D4  　　(indent)
    db $75,$6D,$75,$6D,$75         ; $79D6  ハッハッハ
    db $99                         ; $79DB  ！
    db $F7                         ; $79DC  clear page
    db $F0                         ; $79DD  end of message


; --------------------------------------------------------------------------
; Message #201 ($79DE)
;   「みなさんが　かいてきにたたかえる
;   かんきょうを　ほしょうします！
; --------------------------------------------------------------------------
Bank66_Msg201:                               ; $79DE  (file $10B9DE)
    db $EA                         ; $79DE  ▶ new page
    db $9F                         ; $79DF  box tag
    db $96                         ; $79E0  end name/box tag
    db $44,$39,$2E,$55,$29,$8D     ; $79E1  みなさんか゛ = みなさんが
    db $90                         ; $79E7  　(space)
    db $29,$25,$37,$2A,$3A,$33,$33,$29,$27,$50; $79E8  かいてきにたたかえる
    db $EF,$EE                     ; $79F2  newline
    db $90,$90                     ; $79F4  　　(indent)
    db $29,$55,$2A,$4D,$26,$54     ; $79F6  かんきょうを
    db $90                         ; $79FC  　(space)
    db $42,$2F,$4D,$26,$2F,$43,$30 ; $79FD  ほしょうします
    db $99                         ; $7A04  ！
    db $F7                         ; $7A05  clear page
    db $F0                         ; $7A06  end of message


; --------------------------------------------------------------------------
; Message #202 ($7A07)
;   「[01]クラスうえの　たたかいを
;   したいならば、
;   「この　わたしを　つれていく
;   べきですぞ！
; --------------------------------------------------------------------------
Bank66_Msg202:                               ; $7A07  (file $10BA07)
    db $EA                         ; $7A07  ▶ new page
    db $9F                         ; $7A08  box tag
    db $96                         ; $7A09  end name/box tag
    db $01                         ; $7A0A  ctrl $01
    db $62,$85,$67,$26,$27,$3D     ; $7A0B  クラスうえの
    db $90                         ; $7A11  　(space)
    db $33,$33,$29,$25,$54         ; $7A12  たたかいを
    db $EF,$EE                     ; $7A17  newline
    db $90,$90                     ; $7A19  　　(indent)
    db $2F,$33,$25,$39,$4E,$3E,$8D ; $7A1B  したいならは゛ = したいならば
    db $A4                         ; $7A22  、
    db $FA                         ; $7A23  wait-for-button
    db $F7                         ; $7A24  clear page
    db $EF,$EE                     ; $7A25  newline
    db $9F                         ; $7A27  box tag
    db $96                         ; $7A28  end name/box tag
    db $2D,$3D                     ; $7A29  この
    db $90                         ; $7A2B  　(space)
    db $53,$33,$2F,$54             ; $7A2C  わたしを
    db $90                         ; $7A30  　(space)
    db $35,$51,$37,$25,$2B         ; $7A31  つれていく
    db $EF,$EE                     ; $7A36  newline
    db $90,$90                     ; $7A38  　　(indent)
    db $41,$8D,$2A,$37,$8D,$30,$32,$8D; $7A3A  へ゛きて゛すそ゛ = べきですぞ
    db $99                         ; $7A42  ！
    db $F7                         ; $7A43  clear page
    db $F0                         ; $7A44  end of message


; --------------------------------------------------------------------------
; Message #203 ($7A45)
;   「こうげきだけしか　のうのない
;   やつと　いっしょにしないでくれ！
; --------------------------------------------------------------------------
Bank66_Msg203:                               ; $7A45  (file $10BA45)
    db $EA                         ; $7A45  ▶ new page
    db $9F                         ; $7A46  box tag
    db $96                         ; $7A47  end name/box tag
    db $2D,$26,$2C,$8D,$2A,$33,$8D,$2C,$2F,$29; $7A48  こうけ゛きた゛けしか = こうげきだけしか
    db $90                         ; $7A52  　(space)
    db $3D,$26,$3D,$39,$25         ; $7A53  のうのない
    db $EF,$EE                     ; $7A58  newline
    db $90,$90                     ; $7A5A  　　(indent)
    db $48,$35,$38                 ; $7A5C  やつと
    db $90                         ; $7A5F  　(space)
    db $25,$36,$2F,$4D,$3A,$2F,$39,$25,$37,$8D,$2B,$51; $7A60  いっしょにしないて゛くれ = いっしょにしないでくれ
    db $99                         ; $7A6C  ！
    db $F7                         ; $7A6D  clear page
    db $F0                         ; $7A6E  end of message


; --------------------------------------------------------------------------
; Message #204 ($7A6F)
;   「ククッ。　このわたしの　どこに
;   てぬかりが　あるだろうか！！
; --------------------------------------------------------------------------
Bank66_Msg204:                               ; $7A6F  (file $10BA6F)
    db $EA                         ; $7A6F  ▶ new page
    db $9F                         ; $7A70  box tag
    db $96                         ; $7A71  end name/box tag
    db $62,$62,$6D                 ; $7A72  ククッ
    db $8F                         ; $7A75  。
    db $90                         ; $7A76  　(space)
    db $2D,$3D,$53,$33,$2F,$3D     ; $7A77  このわたしの
    db $90                         ; $7A7D  　(space)
    db $38,$8D,$2D,$3A             ; $7A7E  と゛こに = どこに
    db $EF,$EE                     ; $7A82  newline
    db $90,$90                     ; $7A84  　　(indent)
    db $37,$3B,$29,$4F,$29,$8D     ; $7A86  てぬかりか゛ = てぬかりが
    db $90                         ; $7A8C  　(space)
    db $24,$50,$33,$8D,$52,$26,$29 ; $7A8D  あるた゛ろうか = あるだろうか
    db $99                         ; $7A94  ！
    db $99                         ; $7A95  ！
    db $F7                         ; $7A96  clear page
    db $F0                         ; $7A97  end of message


; --------------------------------------------------------------------------
; Message #205 ($7A98)
;   「ぽーっとしてれば　そのうち
;   せんとうって　おわりますよねー。
; --------------------------------------------------------------------------
Bank66_Msg205:                               ; $7A98  (file $10BA98)
    db $EB                         ; $7A98  ▶ new page
    db $9F                         ; $7A99  box tag
    db $96                         ; $7A9A  end name/box tag
    db $42,$8E,$9C,$36,$38,$2F,$37,$51,$3E,$8D; $7A9B  ほ゜ーっとしてれは゛ = ぽーっとしてれば
    db $90                         ; $7AA5  　(space)
    db $32,$3D,$26,$34             ; $7AA6  そのうち
    db $EF,$EE                     ; $7AAA  newline
    db $90,$90                     ; $7AAC  　　(indent)
    db $31,$55,$38,$26,$36,$37     ; $7AAE  せんとうって
    db $90                         ; $7AB4  　(space)
    db $28,$53,$4F,$43,$30,$4C,$3C,$9C; $7AB5  おわりますよねー
    db $8F                         ; $7ABD  。
    db $F7                         ; $7ABE  clear page
    db $F0                         ; $7ABF  end of message


; --------------------------------------------------------------------------
; Message #206 ($7AC0)
;   「わたしが　こうげきするころには
;   いつも　せんとうは　おわってる。
;   「いったい　どうしてだろう、、？？
; --------------------------------------------------------------------------
Bank66_Msg206:                               ; $7AC0  (file $10BAC0)
    db $EB                         ; $7AC0  ▶ new page
    db $9F                         ; $7AC1  box tag
    db $96                         ; $7AC2  end name/box tag
    db $53,$33,$2F,$29,$8D         ; $7AC3  わたしか゛ = わたしが
    db $90                         ; $7AC8  　(space)
    db $2D,$26,$2C,$8D,$2A,$30,$50,$2D,$52,$3A,$3E; $7AC9  こうけ゛きするころには = こうげきするころには
    db $EF,$EE                     ; $7AD4  newline
    db $90,$90                     ; $7AD6  　　(indent)
    db $25,$35,$47                 ; $7AD8  いつも
    db $90                         ; $7ADB  　(space)
    db $31,$55,$38,$26,$3E         ; $7ADC  せんとうは
    db $90                         ; $7AE1  　(space)
    db $28,$53,$36,$37,$50         ; $7AE2  おわってる
    db $8F                         ; $7AE7  。
    db $FA                         ; $7AE8  wait-for-button
    db $F7                         ; $7AE9  clear page
    db $EF,$EE                     ; $7AEA  newline
    db $9F                         ; $7AEC  box tag
    db $96                         ; $7AED  end name/box tag
    db $25,$36,$33,$25             ; $7AEE  いったい
    db $90                         ; $7AF2  　(space)
    db $38,$8D,$26,$2F,$37,$33,$8D,$52,$26; $7AF3  と゛うしてた゛ろう = どうしてだろう
    db $A4                         ; $7AFC  、
    db $A4                         ; $7AFD  、
    db $98                         ; $7AFE  ？
    db $98                         ; $7AFF  ？
    db $EF,$EE                     ; $7B00  newline
    db $F7                         ; $7B02  clear page
    db $F0                         ; $7B03  end of message


; --------------------------------------------------------------------------
; Message #207 ($7B04)
;   「そのうち　かてますよね！
; --------------------------------------------------------------------------
Bank66_Msg207:                               ; $7B04  (file $10BB04)
    db $EB                         ; $7B04  ▶ new page
    db $9F                         ; $7B05  box tag
    db $96                         ; $7B06  end name/box tag
    db $32,$3D,$26,$34             ; $7B07  そのうち
    db $90                         ; $7B0B  　(space)
    db $29,$37,$43,$30,$4C,$3C     ; $7B0C  かてますよね
    db $99                         ; $7B12  ！
    db $EF,$EE                     ; $7B13  newline
    db $F7                         ; $7B15  clear page
    db $F0                         ; $7B16  end of message


; --------------------------------------------------------------------------
; Message #208 ($7B17)
;   「あわてない　あわてない。
;   しょうりは　やがてくるさ！
; --------------------------------------------------------------------------
Bank66_Msg208:                               ; $7B17  (file $10BB17)
    db $EB                         ; $7B17  ▶ new page
    db $9F                         ; $7B18  box tag
    db $96                         ; $7B19  end name/box tag
    db $24,$53,$37,$39,$25         ; $7B1A  あわてない
    db $90                         ; $7B1F  　(space)
    db $24,$53,$37,$39,$25         ; $7B20  あわてない
    db $8F                         ; $7B25  。
    db $EF,$EE                     ; $7B26  newline
    db $90,$90                     ; $7B28  　　(indent)
    db $2F,$4D,$26,$4F,$3E         ; $7B2A  しょうりは
    db $90                         ; $7B2F  　(space)
    db $48,$29,$8D,$37,$2B,$50,$2E ; $7B30  やか゛てくるさ = やがてくるさ
    db $99                         ; $7B37  ！
    db $F7                         ; $7B38  clear page
    db $F0                         ; $7B39  end of message


; --------------------------------------------------------------------------
; Message #209 ($7B3A)
;   「え？　いいじゃないですか！
;   とりあえず　かいふくしましょ！
; --------------------------------------------------------------------------
Bank66_Msg209:                               ; $7B3A  (file $10BB3A)
    db $EB                         ; $7B3A  ▶ new page
    db $9F                         ; $7B3B  box tag
    db $96                         ; $7B3C  end name/box tag
    db $27                         ; $7B3D  え
    db $98                         ; $7B3E  ？
    db $90                         ; $7B3F  　(space)
    db $25,$25,$2F,$8D,$49,$39,$25,$37,$8D,$30,$29; $7B40  いいし゛ゃないて゛すか = いいじゃないですか
    db $99                         ; $7B4B  ！
    db $EF,$EE                     ; $7B4C  newline
    db $90,$90                     ; $7B4E  　　(indent)
    db $38,$4F,$24,$27,$30,$8D     ; $7B50  とりあえす゛ = とりあえず
    db $90                         ; $7B56  　(space)
    db $29,$25,$40,$2B,$2F,$43,$2F,$4D; $7B57  かいふくしましょ
    db $99                         ; $7B5F  ！
    db $F7                         ; $7B60  clear page
    db $F0                         ; $7B61  end of message


; --------------------------------------------------------------------------
; Message #210 ($7B62)
;   「いやいやいや。
;   まあ　おちゃでも　どうぞ。
; --------------------------------------------------------------------------
Bank66_Msg210:                               ; $7B62  (file $10BB62)
    db $EB                         ; $7B62  ▶ new page
    db $9F                         ; $7B63  box tag
    db $96                         ; $7B64  end name/box tag
    db $25,$48,$25,$48,$25,$48     ; $7B65  いやいやいや
    db $8F                         ; $7B6B  。
    db $EF,$EE                     ; $7B6C  newline
    db $90,$90                     ; $7B6E  　　(indent)
    db $43,$24                     ; $7B70  まあ
    db $90                         ; $7B72  　(space)
    db $28,$34,$49,$37,$8D,$47     ; $7B73  おちゃて゛も = おちゃでも
    db $90                         ; $7B79  　(space)
    db $38,$8D,$26,$32,$8D         ; $7B7A  と゛うそ゛ = どうぞ
    db $8F                         ; $7B7F  。
    db $F7                         ; $7B80  clear page
    db $F0                         ; $7B81  end of message


; --------------------------------------------------------------------------
; Message #211 ($7B82)
;   「〈テリー〉さん。
;   かたでも　おもみしましょうか？
; --------------------------------------------------------------------------
Bank66_Msg211:                               ; $7B82  (file $10BB82)
    db $EB                         ; $7B82  ▶ new page
    db $9F                         ; $7B83  box tag
    db $96                         ; $7B84  end name/box tag
    db $F6                         ; $7B85  «insert hero name» (テリー)
    db $2E,$55                     ; $7B86  さん
    db $8F                         ; $7B88  。
    db $EF,$EE                     ; $7B89  newline
    db $90,$90                     ; $7B8B  　　(indent)
    db $29,$33,$37,$8D,$47         ; $7B8D  かたて゛も = かたでも
    db $90                         ; $7B92  　(space)
    db $28,$47,$44,$2F,$43,$2F,$4D,$26,$29; $7B93  おもみしましょうか
    db $98                         ; $7B9C  ？
    db $F7                         ; $7B9D  clear page
    db $F0                         ; $7B9E  end of message


; --------------------------------------------------------------------------
; Message #212 ($7B9F)
;   「いつも　ごくろうさまだな。
;   たまには　ゆっくりしろよ！
; --------------------------------------------------------------------------
Bank66_Msg212:                               ; $7B9F  (file $10BB9F)
    db $EB                         ; $7B9F  ▶ new page
    db $9F                         ; $7BA0  box tag
    db $96                         ; $7BA1  end name/box tag
    db $25,$35,$47                 ; $7BA2  いつも
    db $90                         ; $7BA5  　(space)
    db $2D,$8D,$2B,$52,$26,$2E,$43,$33,$8D,$39; $7BA6  こ゛くろうさまた゛な = ごくろうさまだな
    db $8F                         ; $7BB0  。
    db $EF,$EE                     ; $7BB1  newline
    db $90,$90                     ; $7BB3  　　(indent)
    db $33,$43,$3A,$3E             ; $7BB5  たまには
    db $90                         ; $7BB9  　(space)
    db $4A,$36,$2B,$4F,$2F,$52,$4C ; $7BBA  ゆっくりしろよ
    db $99                         ; $7BC1  ！
    db $F7                         ; $7BC2  clear page
    db $F0                         ; $7BC3  end of message


; --------------------------------------------------------------------------
; Message #213 ($7BC4)
;   「まあ　あれだな。
;   せんとうとは　たてになるやつと、
;   「わたしのような　しゅうさいがいて
;   はじめてなりたつのだ。
; --------------------------------------------------------------------------
Bank66_Msg213:                               ; $7BC4  (file $10BBC4)
    db $EA                         ; $7BC4  ▶ new page
    db $9F                         ; $7BC5  box tag
    db $96                         ; $7BC6  end name/box tag
    db $43,$24                     ; $7BC7  まあ
    db $90                         ; $7BC9  　(space)
    db $24,$51,$33,$8D,$39         ; $7BCA  あれた゛な = あれだな
    db $8F                         ; $7BCF  。
    db $EF,$EE                     ; $7BD0  newline
    db $90,$90                     ; $7BD2  　　(indent)
    db $31,$55,$38,$26,$38,$3E     ; $7BD4  せんとうとは
    db $90                         ; $7BDA  　(space)
    db $33,$37,$3A,$39,$50,$48,$35,$38; $7BDB  たてになるやつと
    db $A4                         ; $7BE3  、
    db $FA                         ; $7BE4  wait-for-button
    db $F7                         ; $7BE5  clear page
    db $EF,$EE                     ; $7BE6  newline
    db $9F                         ; $7BE8  box tag
    db $96                         ; $7BE9  end name/box tag
    db $53,$33,$2F,$3D,$4C,$26,$39 ; $7BEA  わたしのような
    db $90                         ; $7BF1  　(space)
    db $2F,$4B,$26,$2E,$25,$29,$8D,$25,$37; $7BF2  しゅうさいか゛いて = しゅうさいがいて
    db $EF,$EE                     ; $7BFB  newline
    db $90,$90                     ; $7BFD  　　(indent)
    db $3E,$2F,$8D,$46,$37,$39,$4F,$33,$35,$3D,$33,$8D; $7BFF  はし゛めてなりたつのた゛ = はじめてなりたつのだ
    db $8F                         ; $7C0B  。
    db $F7                         ; $7C0C  clear page
    db $F0                         ; $7C0D  end of message


; --------------------------------------------------------------------------
; Message #214 ($7C0E)
;   「たいりょくのあるやつと
;   いっしょが　いいですな[91]。
; --------------------------------------------------------------------------
Bank66_Msg214:                               ; $7C0E  (file $10BC0E)
    db $EA                         ; $7C0E  ▶ new page
    db $9F                         ; $7C0F  box tag
    db $96                         ; $7C10  end name/box tag
    db $33,$25,$4F,$4D,$2B,$3D,$24,$50,$48,$35,$38; $7C11  たいりょくのあるやつと
    db $EF,$EE                     ; $7C1C  newline
    db $90,$90                     ; $7C1E  　　(indent)
    db $25,$36,$2F,$4D,$29,$8D     ; $7C20  いっしょか゛ = いっしょが
    db $90                         ; $7C26  　(space)
    db $25,$25,$37,$8D,$30,$39     ; $7C27  いいて゛すな = いいですな
    db $91                         ; $7C2D  ctrl $91
    db $8F                         ; $7C2E  。
    db $F7                         ; $7C2F  clear page
    db $F0                         ; $7C30  end of message


; --------------------------------------------------------------------------
; Message #215 ($7C31)
;   「ケケケ！
;   ばかは　はたらけ！
; --------------------------------------------------------------------------
Bank66_Msg215:                               ; $7C31  (file $10BC31)
    db $EA                         ; $7C31  ▶ new page
    db $9F                         ; $7C32  box tag
    db $96                         ; $7C33  end name/box tag
    db $63,$63,$63                 ; $7C34  ケケケ
    db $99                         ; $7C37  ！
    db $EF,$EE                     ; $7C38  newline
    db $90,$90                     ; $7C3A  　　(indent)
    db $3E,$8D,$29,$3E             ; $7C3C  は゛かは = ばかは
    db $90                         ; $7C40  　(space)
    db $3E,$33,$4E,$2C             ; $7C41  はたらけ
    db $99                         ; $7C45  ！
    db $F7                         ; $7C46  clear page
    db $F0                         ; $7C47  end of message


; --------------------------------------------------------------------------
; Message #216 ($7C48)
;   「わたしを　はたらかせるのか！？
;   しかも　ただばたらきとは！
; --------------------------------------------------------------------------
Bank66_Msg216:                               ; $7C48  (file $10BC48)
    db $EA                         ; $7C48  ▶ new page
    db $9F                         ; $7C49  box tag
    db $96                         ; $7C4A  end name/box tag
    db $53,$33,$2F,$54             ; $7C4B  わたしを
    db $90                         ; $7C4F  　(space)
    db $3E,$33,$4E,$29,$31,$50,$3D,$29; $7C50  はたらかせるのか
    db $99                         ; $7C58  ！
    db $98                         ; $7C59  ？
    db $EF,$EE                     ; $7C5A  newline
    db $90,$90                     ; $7C5C  　　(indent)
    db $2F,$29,$47                 ; $7C5E  しかも
    db $90                         ; $7C61  　(space)
    db $33,$33,$8D,$3E,$8D,$33,$4E,$2A,$38,$3E; $7C62  たた゛は゛たらきとは = ただばたらきとは
    db $99                         ; $7C6C  ！
    db $F7                         ; $7C6D  clear page
    db $F0                         ; $7C6E  end of message


; --------------------------------------------------------------------------
; Message #217 ($7C6F)
;   「み　みんなの　ほじょ　しとけば、
;   そのうち、せんとう　おわるよね？
; --------------------------------------------------------------------------
Bank66_Msg217:                               ; $7C6F  (file $10BC6F)
    db $EB                         ; $7C6F  ▶ new page
    db $9F                         ; $7C70  box tag
    db $96                         ; $7C71  end name/box tag
    db $44                         ; $7C72  み
    db $90                         ; $7C73  　(space)
    db $44,$55,$39,$3D             ; $7C74  みんなの
    db $90                         ; $7C78  　(space)
    db $42,$2F,$8D,$4D             ; $7C79  ほし゛ょ = ほじょ
    db $90                         ; $7C7D  　(space)
    db $2F,$38,$2C,$3E,$8D         ; $7C7E  しとけは゛ = しとけば
    db $A4                         ; $7C83  、
    db $EF,$EE                     ; $7C84  newline
    db $90,$90                     ; $7C86  　　(indent)
    db $32,$3D,$26,$34             ; $7C88  そのうち
    db $A4                         ; $7C8C  、
    db $31,$55,$38,$26             ; $7C8D  せんとう
    db $90                         ; $7C91  　(space)
    db $28,$53,$50,$4C,$3C         ; $7C92  おわるよね
    db $98                         ; $7C97  ？
    db $F7                         ; $7C98  clear page
    db $F0                         ; $7C99  end of message


; --------------------------------------------------------------------------
; Message #218 ($7C9A)
;   「ひっ。
;   「こっ　こわいよ[95]！
; --------------------------------------------------------------------------
Bank66_Msg218:                               ; $7C9A  (file $10BC9A)
    db $EB                         ; $7C9A  ▶ new page
    db $9F                         ; $7C9B  box tag
    db $96                         ; $7C9C  end name/box tag
    db $3F,$36                     ; $7C9D  ひっ
    db $8F                         ; $7C9F  。
    db $EF,$EE                     ; $7CA0  newline
    db $FA                         ; $7CA2  wait-for-button
    db $F7                         ; $7CA3  clear page
    db $EF,$EE                     ; $7CA4  newline
    db $F3                         ; $7CA6  open text box
    db $9F                         ; $7CA7  box tag
    db $96                         ; $7CA8  end name/box tag
    db $2D,$36                     ; $7CA9  こっ
    db $90                         ; $7CAB  　(space)
    db $2D,$53,$25,$4C             ; $7CAC  こわいよ
    db $95                         ; $7CB0  ctrl $95
    db $99                         ; $7CB1  ！
    db $EF,$EE                     ; $7CB2  newline
    db $F7                         ; $7CB4  clear page
    db $F0                         ; $7CB5  end of message


; --------------------------------------------------------------------------
; Message #219 ($7CB6)
;   「ガタガタガタ、、。
;   ブルブルブル、、。
;   「こわいんじゃないです！
;   さむくて　ふるえてるんですよ！！
; --------------------------------------------------------------------------
Bank66_Msg219:                               ; $7CB6  (file $10BCB6)
    db $EB                         ; $7CB6  ▶ new page
    db $9F                         ; $7CB7  box tag
    db $96                         ; $7CB8  end name/box tag
    db $60,$8D,$6A,$60,$8D,$6A,$60,$8D,$6A; $7CB9  カ゛タカ゛タカ゛タ = ガタガタガタ
    db $A4                         ; $7CC2  、
    db $A4                         ; $7CC3  、
    db $8F                         ; $7CC4  。
    db $EF,$EE                     ; $7CC5  newline
    db $90,$90                     ; $7CC7  　　(indent)
    db $77,$8D,$87,$77,$8D,$87,$77,$8D,$87; $7CC9  フ゛ルフ゛ルフ゛ル = ブルブルブル
    db $A4                         ; $7CD2  、
    db $A4                         ; $7CD3  、
    db $8F                         ; $7CD4  。
    db $FA                         ; $7CD5  wait-for-button
    db $F7                         ; $7CD6  clear page
    db $EF,$EE                     ; $7CD7  newline
    db $9F                         ; $7CD9  box tag
    db $96                         ; $7CDA  end name/box tag
    db $2D,$53,$25,$55,$2F,$8D,$49,$39,$25,$37,$8D,$30; $7CDB  こわいんし゛ゃないて゛す = こわいんじゃないです
    db $99                         ; $7CE7  ！
    db $EF,$EE                     ; $7CE8  newline
    db $90,$90                     ; $7CEA  　　(indent)
    db $2E,$45,$2B,$37             ; $7CEC  さむくて
    db $90                         ; $7CF0  　(space)
    db $40,$50,$27,$37,$50,$55,$37,$8D,$30,$4C; $7CF1  ふるえてるんて゛すよ = ふるえてるんですよ
    db $99                         ; $7CFB  ！
    db $99                         ; $7CFC  ！
    db $F7                         ; $7CFD  clear page
    db $F0                         ; $7CFE  end of message


; --------------------------------------------------------------------------
; Message #220 ($7CFF)
;   「うお[95]　いか[91]あん！！
;   なぜだ　なぜ　こんなきもちに！！
;   「こっ、、、　、、、こ、わ、、い。
; --------------------------------------------------------------------------
Bank66_Msg220:                               ; $7CFF  (file $10BCFF)
    db $EB                         ; $7CFF  ▶ new page
    db $9F                         ; $7D00  box tag
    db $96                         ; $7D01  end name/box tag
    db $26,$28                     ; $7D02  うお
    db $95                         ; $7D04  ctrl $95
    db $90                         ; $7D05  　(space)
    db $25,$29                     ; $7D06  いか
    db $91                         ; $7D08  ctrl $91
    db $24,$55                     ; $7D09  あん
    db $99                         ; $7D0B  ！
    db $99                         ; $7D0C  ！
    db $EF,$EE                     ; $7D0D  newline
    db $90,$90                     ; $7D0F  　　(indent)
    db $39,$31,$8D,$33,$8D         ; $7D11  なせ゛た゛ = なぜだ
    db $90                         ; $7D16  　(space)
    db $39,$31,$8D                 ; $7D17  なせ゛ = なぜ
    db $90                         ; $7D1A  　(space)
    db $2D,$55,$39,$2A,$47,$34,$3A ; $7D1B  こんなきもちに
    db $99                         ; $7D22  ！
    db $99                         ; $7D23  ！
    db $FA                         ; $7D24  wait-for-button
    db $F7                         ; $7D25  clear page
    db $EF,$EE                     ; $7D26  newline
    db $9F                         ; $7D28  box tag
    db $96                         ; $7D29  end name/box tag
    db $2D,$36                     ; $7D2A  こっ
    db $A4                         ; $7D2C  、
    db $A4                         ; $7D2D  、
    db $A4                         ; $7D2E  、
    db $90                         ; $7D2F  　(space)
    db $A4                         ; $7D30  、
    db $A4                         ; $7D31  、
    db $A4                         ; $7D32  、
    db $2D                         ; $7D33  こ
    db $A4                         ; $7D34  、
    db $53                         ; $7D35  わ
    db $A4                         ; $7D36  、
    db $A4                         ; $7D37  、
    db $25                         ; $7D38  い
    db $8F                         ; $7D39  。
    db $EF,$EE                     ; $7D3A  newline
    db $F7                         ; $7D3C  clear page
    db $F0                         ; $7D3D  end of message


; --------------------------------------------------------------------------
; Message #221 ($7D3E)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank66_Msg221:                               ; $7D3E  (file $10BD3E)
    db $38,$3F,$8D,$4E,$3E         ; $7D3E  とひ゛らは = とびらは
    db $90                         ; $7D43  　(space)
    db $28,$47,$2B                 ; $7D44  おもく
    db $90                         ; $7D47  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $7D48  とさ゛されている = とざされている
    db $8F                         ; $7D50  。
    db $EF,$EE                     ; $7D51  newline
    db $F7                         ; $7D53  clear page
    db $F0                         ; $7D54  end of message


; --------------------------------------------------------------------------
; Message #222 ($7D55)
;   「、、、　、、、。
;   、、、　、、、。
;   「・・・、、、。
; --------------------------------------------------------------------------
Bank66_Msg222:                               ; $7D55  (file $10BD55)
    db $EB                         ; $7D55  ▶ new page
    db $9F                         ; $7D56  box tag
    db $96                         ; $7D57  end name/box tag
    db $A4                         ; $7D58  、
    db $A4                         ; $7D59  、
    db $A4                         ; $7D5A  、
    db $90                         ; $7D5B  　(space)
    db $A4                         ; $7D5C  、
    db $A4                         ; $7D5D  、
    db $A4                         ; $7D5E  、
    db $8F                         ; $7D5F  。
    db $EF,$EE                     ; $7D60  newline
    db $90,$90                     ; $7D62  　　(indent)
    db $A4                         ; $7D64  、
    db $A4                         ; $7D65  、
    db $A4                         ; $7D66  、
    db $90                         ; $7D67  　(space)
    db $A4                         ; $7D68  、
    db $A4                         ; $7D69  、
    db $A4                         ; $7D6A  、
    db $8F                         ; $7D6B  。
    db $FA                         ; $7D6C  wait-for-button
    db $F7                         ; $7D6D  clear page
    db $EF,$EE                     ; $7D6E  newline
    db $9F                         ; $7D70  box tag
    db $96                         ; $7D71  end name/box tag
    db $23                         ; $7D72  ・
    db $23                         ; $7D73  ・
    db $23                         ; $7D74  ・
    db $A4                         ; $7D75  、
    db $A4                         ; $7D76  、
    db $A4                         ; $7D77  、
    db $8F                         ; $7D78  。
    db $EF,$EE                     ; $7D79  newline
    db $F7                         ; $7D7B  clear page
    db $F0                         ; $7D7C  end of message


; --------------------------------------------------------------------------
; Message #223 ($7D7D)
;   「あ[9D]　ねむたい。
;   はやく　かえろーよー！
; --------------------------------------------------------------------------
Bank66_Msg223:                               ; $7D7D  (file $10BD7D)
    db $EB                         ; $7D7D  ▶ new page
    db $9F                         ; $7D7E  box tag
    db $96                         ; $7D7F  end name/box tag
    db $24                         ; $7D80  あ
    db $9D                         ; $7D81  ctrl $9D
    db $90                         ; $7D82  　(space)
    db $3C,$45,$33,$25             ; $7D83  ねむたい
    db $8F                         ; $7D87  。
    db $EF,$EE                     ; $7D88  newline
    db $90,$90                     ; $7D8A  　　(indent)
    db $3E,$48,$2B                 ; $7D8C  はやく
    db $90                         ; $7D8F  　(space)
    db $29,$27,$52,$9C,$4C,$9C     ; $7D90  かえろーよー
    db $99                         ; $7D96  ！
    db $F7                         ; $7D97  clear page
    db $F0                         ; $7D98  end of message


; --------------------------------------------------------------------------
; Message #224 ($7D99)
;   「あくせくしても　あきまへん。
;   ゆっくり　しまひょ！
; --------------------------------------------------------------------------
Bank66_Msg224:                               ; $7D99  (file $10BD99)
    db $EB                         ; $7D99  ▶ new page
    db $9F                         ; $7D9A  box tag
    db $96                         ; $7D9B  end name/box tag
    db $24,$2B,$31,$2B,$2F,$37,$47 ; $7D9C  あくせくしても
    db $90                         ; $7DA3  　(space)
    db $24,$2A,$43,$41,$55         ; $7DA4  あきまへん
    db $8F                         ; $7DA9  。
    db $EF,$EE                     ; $7DAA  newline
    db $90,$90                     ; $7DAC  　　(indent)
    db $4A,$36,$2B,$4F             ; $7DAE  ゆっくり
    db $90                         ; $7DB2  　(space)
    db $2F,$43,$3F,$4D             ; $7DB3  しまひょ
    db $99                         ; $7DB7  ！
    db $F7                         ; $7DB8  clear page
    db $F0                         ; $7DB9  end of message


; --------------------------------------------------------------------------
; Message #225 ($7DBA)
;   「う[95]っ！！　はらがいたい、。
;   ちょっと　やすませてくれ、、！
;   「なんだ　そのめは？
;   けびょうだと　おもって
; --------------------------------------------------------------------------
Bank66_Msg225:                               ; $7DBA  (file $10BDBA)
    db $EB                         ; $7DBA  ▶ new page
    db $9F                         ; $7DBB  box tag
    db $96                         ; $7DBC  end name/box tag
    db $26                         ; $7DBD  う
    db $95                         ; $7DBE  ctrl $95
    db $36                         ; $7DBF  っ
    db $99                         ; $7DC0  ！
    db $99                         ; $7DC1  ！
    db $90                         ; $7DC2  　(space)
    db $3E,$4E,$29,$8D,$25,$33,$25 ; $7DC3  はらか゛いたい = はらがいたい
    db $A4                         ; $7DCA  、
    db $8F                         ; $7DCB  。
    db $EF,$EE                     ; $7DCC  newline
    db $90,$90                     ; $7DCE  　　(indent)
    db $34,$4D,$36,$38             ; $7DD0  ちょっと
    db $90                         ; $7DD4  　(space)
    db $48,$30,$43,$31,$37,$2B,$51 ; $7DD5  やすませてくれ
    db $A4                         ; $7DDC  、
    db $A4                         ; $7DDD  、
    db $99                         ; $7DDE  ！
    db $FA                         ; $7DDF  wait-for-button
    db $F7                         ; $7DE0  clear page
    db $EF,$EE                     ; $7DE1  newline
    db $9F                         ; $7DE3  box tag
    db $96                         ; $7DE4  end name/box tag
    db $39,$55,$33,$8D             ; $7DE5  なんた゛ = なんだ
    db $90                         ; $7DE9  　(space)
    db $32,$3D,$46,$3E             ; $7DEA  そのめは
    db $98                         ; $7DEE  ？
    db $EF,$EE                     ; $7DEF  newline
    db $90,$90                     ; $7DF1  　　(indent)
    db $2C,$3F,$8D,$4D,$26,$33,$8D,$38; $7DF3  けひ゛ょうた゛と = けびょうだと
    db $90                         ; $7DFB  　(space)
    db $28,$47,$36,$37             ; $7DFC  おもって
    db $28,$50,$39,$36             ; $7E00  おるなっ
    db $99                         ; $7E04  ！
    db $F7                         ; $7E05  clear page
    db $F0                         ; $7E06  end of message

Bank66_Pad:                                ; $7E07
    ds $01F9, $FF                   ; $FF padding to $8000
