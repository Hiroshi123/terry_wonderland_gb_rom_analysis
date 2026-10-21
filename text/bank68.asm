; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 68  (DIALOGUE / MESSAGE TEXT — overworld NPCs & library)
; ==========================================================================
;
; Flat sentence bank (like bank66). Kana dialogue: assorted overworld NPCs
; (a sorceress assistant おばば, the King, townsfolk) plus a lot of library /
; book examination text (ほんだなをしらべた). Codec: memory text-codec.
;
;   File offset $110000-$113FFF  |  self-ID $4000 = $44
;   $401C : word -> $4020  (message-pointer table)
;   $4020 : 172 little-endian string pointers -> kana messages ($4178..)
; Function table $4001: fn0 $4007 (window), fn1 $400E (copy), fn2 $4015 (print)
; All 172 messages decoded below, ASCENDING ADDRESS order, byte-exact.
; ==========================================================================

SECTION "Bank 68", ROMX[$4000], BANK[68]

    db $44                          ; $4000  self-ID
    dw $4007,$400E,$4015          ; $4001  fn table
    db $11,$1C,$40,$CD,$68,$05,$C9 ; $4007  Fn0: LD DE,$401C/CALL $0568/RET
    db $11,$1C,$40,$CD,$A7,$05,$C9 ; $400E  Fn1: LD DE,$401C/CALL $05A7/RET
    db $CD,$07,$40,$CD,$BA,$05,$C9 ; $4015  Fn2: CALL $4007/CALL $05BA/RET

Bank68_MsgDir:                             ; $401C
    dw $4020                         ; header word -> table
    db $F0,$40   ; $401E pre-table bytes
Bank68_MsgTable:                           ; $4020  (172 string pointers)
    dw $4178,$41C1,$42B1,$43AA,$444A,$4482,$44C0,$4526
    dw $4571,$4596,$45DD,$463E,$4675,$4708,$472C,$479D
    dw $47C1,$483B,$4860,$48C5,$4937,$49F3,$4A7A,$4AE9
    dw $4B39,$4BE5,$4C31,$4C7D,$4CC6,$4D87,$4DD8,$4E47
    dw $4EBD,$4EFB,$4F6A,$503D,$505A,$5080,$5133,$5260
    dw $5377,$5486,$54C8,$55B5,$5619,$56AC,$56FC,$577E
    dw $5828,$5954,$59E4,$5A8B,$5B42,$5B60,$5BB6,$5BDF
    dw $5C1C,$5C66,$5C7E,$5CC5,$5CE6,$5D5E,$5DB7,$5DF5
    dw $5E98,$5EED,$5F31,$5F56,$5F75,$601F,$60AA,$614D
    dw $6178,$61EC,$6239,$62A5,$62C8,$62DB,$62FF,$63B5
    dw $63DF,$640C,$64D8,$6518,$6580,$65A2,$65F1,$6615
    dw $666B,$66A3,$6721,$6836,$6869,$68DF,$69DE,$6A4E
    dw $6A96,$6AE2,$6B21,$6B5C,$6B77,$6B95,$6BDE,$6C05
    dw $6C5E,$6C81,$6CC0,$6D15,$6D3B,$6D61,$6D81,$6DAB
    dw $6DFF,$6E51,$6E99,$6EE2,$6F2F,$6F9A,$6FC4,$7025
    dw $704B,$706E,$710F,$7124,$7139,$7149,$7197,$71AE
    dw $7225,$729B,$72C8,$7332,$7363,$7381,$73C6,$7402
    dw $7496,$74C7,$74D7,$74EB,$74F7,$750A,$754F,$757E
    dw $75DA,$75F2,$7619,$7691,$76D1,$774D,$7762,$77E4
    dw $784C,$78DE,$7933,$798E,$7A6A,$7A99,$7ABF,$7B5C
    dw $7B88,$7BB1,$7C03,$7C4B,$7D23,$7D4C,$7D76,$7D96
    dw $7DAD,$7DFE,$7E1E,$7E3A

; ══════════════════════════════════════════════════════════════════════════
; DECODED MESSAGES (all 172) — ADDRESS-ORDERED
; ══════════════════════════════════════════════════════════════════════════

; --------------------------------------------------------------------------
; Message #0 ($4178)
;   「こんばんは。
;   いまは　ひるまじゃったかのう？
;   「わしは　せんせいのじょしゅの
;   おばばじゃ。　ヒーヒッヒ。
; --------------------------------------------------------------------------
Bank68_Msg0:                               ; $4178  (file $110178)
    db $EB                         ; $4178  ▶ new page
    db $9F                         ; $4179  box tag
    db $96                         ; $417A  end name/box tag
    db $2D,$55,$3E,$8D,$55,$3E     ; $417B  こんは゛んは = こんばんは
    db $8F                         ; $4181  。
    db $EF,$EE                     ; $4182  newline
    db $90,$90                     ; $4184  　　(indent)
    db $25,$43,$3E                 ; $4186  いまは
    db $90                         ; $4189  　(space)
    db $3F,$50,$43,$2F,$8D,$49,$36,$33,$29,$3D,$26; $418A  ひるまし゛ゃったかのう = ひるまじゃったかのう
    db $98                         ; $4195  ？
    db $FA                         ; $4196  wait-for-button
    db $F7                         ; $4197  clear page
    db $EF,$EE                     ; $4198  newline
    db $9F                         ; $419A  box tag
    db $96                         ; $419B  end name/box tag
    db $53,$2F,$3E                 ; $419C  わしは
    db $90                         ; $419F  　(space)
    db $31,$55,$31,$25,$3D,$2F,$8D,$4D,$2F,$4B,$3D; $41A0  せんせいのし゛ょしゅの = せんせいのじょしゅの
    db $EF,$EE                     ; $41AB  newline
    db $90,$90                     ; $41AD  　　(indent)
    db $28,$3E,$8D,$3E,$8D,$2F,$8D,$49; $41AF  おは゛は゛し゛ゃ = おばばじゃ
    db $8F                         ; $41B7  。
    db $90                         ; $41B8  　(space)
    db $76,$9C,$76,$6D,$76         ; $41B9  ヒーヒッヒ
    db $8F                         ; $41BE  。
    db $F7                         ; $41BF  clear page
    db $F0                         ; $41C0  end of message


; --------------------------------------------------------------------------
; Message #1 ($41C1)
;   〈テリー〉は　ほんだなを　しらべた。
;   「わが　まものの　けんきゅう、
;   「まものには　けいとうごとに
;   とくちょうが　あるのだ。
;   「たとえば　スラィムけいは
;   すばやさが　あがりやすい。
;   「また　ボミォスや　ルカニなどの
;   ほじょけいじゅもんに　つよい。
;   「あくまけいや　ドラゴンけいには
;   ひのまほうが　ききにくい、。
;   「これらの　とくちょうを　すべて
;   もつ　まものを　わたしは　ほしい！
; --------------------------------------------------------------------------
Bank68_Msg1:                               ; $41C1  (file $1101C1)
    db $F6                         ; $41C1  «insert hero name»
    db $3E                         ; $41C2  は
    db $90                         ; $41C3  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $41C4  ほんた゛なを = ほんだなを
    db $90                         ; $41CA  　(space)
    db $2F,$4E,$41,$8D,$33         ; $41CB  しらへ゛た = しらべた
    db $8F                         ; $41D0  。
    db $EF,$EE                     ; $41D1  newline
    db $FA                         ; $41D3  wait-for-button
    db $F7                         ; $41D4  clear page
    db $EF,$EE                     ; $41D5  newline
    db $F3                         ; $41D7  open text box
    db $96                         ; $41D8  end name/box tag
    db $53,$29,$8D                 ; $41D9  わか゛ = わが
    db $90                         ; $41DC  　(space)
    db $43,$47,$3D,$3D             ; $41DD  まものの
    db $90                         ; $41E1  　(space)
    db $2C,$55,$2A,$4B,$26         ; $41E2  けんきゅう
    db $A4                         ; $41E7  、
    db $EF,$EE                     ; $41E8  newline
    db $FA                         ; $41EA  wait-for-button
    db $F7                         ; $41EB  clear page
    db $EF,$EE                     ; $41EC  newline
    db $F3                         ; $41EE  open text box
    db $96                         ; $41EF  end name/box tag
    db $43,$47,$3D,$3A,$3E         ; $41F0  まものには
    db $90                         ; $41F5  　(space)
    db $2C,$25,$38,$26,$2D,$8D,$38,$3A; $41F6  けいとうこ゛とに = けいとうごとに
    db $EF,$EE                     ; $41FE  newline
    db $90                         ; $4200  　(space)
    db $38,$2B,$34,$4D,$26,$29,$8D ; $4201  とくちょうか゛ = とくちょうが
    db $90                         ; $4208  　(space)
    db $24,$50,$3D,$33,$8D         ; $4209  あるのた゛ = あるのだ
    db $8F                         ; $420E  。
    db $FA                         ; $420F  wait-for-button
    db $F7                         ; $4210  clear page
    db $EF,$EE                     ; $4211  newline
    db $96                         ; $4213  end name/box tag
    db $33,$38,$27,$3E,$8D         ; $4214  たとえは゛ = たとえば
    db $90                         ; $4219  　(space)
    db $67,$85,$58,$7C,$2C,$25,$3E ; $421A  スラィムけいは
    db $EF,$EE                     ; $4221  newline
    db $90                         ; $4223  　(space)
    db $30,$3E,$8D,$48,$2E,$29,$8D ; $4224  すは゛やさか゛ = すばやさが
    db $90                         ; $422B  　(space)
    db $24,$29,$8D,$4F,$48,$30,$25 ; $422C  あか゛りやすい = あがりやすい
    db $8F                         ; $4233  。
    db $FA                         ; $4234  wait-for-button
    db $F7                         ; $4235  clear page
    db $EF,$EE                     ; $4236  newline
    db $96                         ; $4238  end name/box tag
    db $43,$33                     ; $4239  また
    db $90                         ; $423B  　(space)
    db $79,$8D,$7B,$5E,$67,$48     ; $423C  ホ゛ミォスや = ボミォスや
    db $90                         ; $4242  　(space)
    db $87,$60,$71,$39,$38,$8D,$3D ; $4243  ルカニなと゛の = ルカニなどの
    db $EF,$EE                     ; $424A  newline
    db $90                         ; $424C  　(space)
    db $42,$2F,$8D,$4D,$2C,$25,$2F,$8D,$4B,$47,$55,$3A; $424D  ほし゛ょけいし゛ゅもんに = ほじょけいじゅもんに
    db $90                         ; $4259  　(space)
    db $35,$4C,$25                 ; $425A  つよい
    db $8F                         ; $425D  。
    db $FA                         ; $425E  wait-for-button
    db $F7                         ; $425F  clear page
    db $EF,$EE                     ; $4260  newline
    db $96                         ; $4262  end name/box tag
    db $24,$2B,$43,$2C,$25,$48     ; $4263  あくまけいや
    db $90                         ; $4269  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$2C,$25,$3A,$3E; $426A  ト゛ラコ゛ンけいには = ドラゴンけいには
    db $EF,$EE                     ; $4274  newline
    db $90                         ; $4276  　(space)
    db $3F,$3D,$43,$42,$26,$29,$8D ; $4277  ひのまほうか゛ = ひのまほうが
    db $90                         ; $427E  　(space)
    db $2A,$2A,$3A,$2B,$25         ; $427F  ききにくい
    db $A4                         ; $4284  、
    db $8F                         ; $4285  。
    db $FA                         ; $4286  wait-for-button
    db $F7                         ; $4287  clear page
    db $EF,$EE                     ; $4288  newline
    db $96                         ; $428A  end name/box tag
    db $2D,$51,$4E,$3D             ; $428B  これらの
    db $90                         ; $428F  　(space)
    db $38,$2B,$34,$4D,$26,$54     ; $4290  とくちょうを
    db $90                         ; $4296  　(space)
    db $30,$41,$8D,$37             ; $4297  すへ゛て = すべて
    db $EF,$EE                     ; $429B  newline
    db $90                         ; $429D  　(space)
    db $47,$35                     ; $429E  もつ
    db $90                         ; $42A0  　(space)
    db $43,$47,$3D,$54             ; $42A1  まものを
    db $90                         ; $42A5  　(space)
    db $53,$33,$2F,$3E             ; $42A6  わたしは
    db $90                         ; $42AA  　(space)
    db $42,$2F,$25                 ; $42AB  ほしい
    db $99                         ; $42AE  ！
    db $F7                         ; $42AF  clear page
    db $F0                         ; $42B0  end of message


; --------------------------------------------------------------------------
; Message #2 ($42B1)
;   〈テリー〉は　ほんだなを　しらべた。
;   「タィジャの　ひみつ、
;   「タィジャをはじめ　ほかのくにぐにも
;   おおきな　きのなかに　できている。
;   「きは　そだち　やがて　かれる。
;   くににも　じゅみょうが　あるのだ。
;   「カレキというくには　ほとんど
;   かれてしまっているという、、。
;   「だが　かれる　きがあれば
;   うまれてくる　きもある。
;   「なぜか　ほしふりのよるに　あらたな
;   きが　うまれることが　おおい、。
; --------------------------------------------------------------------------
Bank68_Msg2:                               ; $42B1  (file $1102B1)
    db $F6                         ; $42B1  «insert hero name»
    db $3E                         ; $42B2  は
    db $90                         ; $42B3  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $42B4  ほんた゛なを = ほんだなを
    db $90                         ; $42BA  　(space)
    db $2F,$4E,$41,$8D,$33         ; $42BB  しらへ゛た = しらべた
    db $8F                         ; $42C0  。
    db $EF,$EE                     ; $42C1  newline
    db $FA                         ; $42C3  wait-for-button
    db $F7                         ; $42C4  clear page
    db $EF,$EE                     ; $42C5  newline
    db $F3                         ; $42C7  open text box
    db $96                         ; $42C8  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D     ; $42C9  タィシ゛ャの = タィジャの
    db $90                         ; $42CF  　(space)
    db $3F,$44,$35                 ; $42D0  ひみつ
    db $A4                         ; $42D3  、
    db $EF,$EE                     ; $42D4  newline
    db $FA                         ; $42D6  wait-for-button
    db $F7                         ; $42D7  clear page
    db $EF,$EE                     ; $42D8  newline
    db $F3                         ; $42DA  open text box
    db $96                         ; $42DB  end name/box tag
    db $6A,$58,$66,$8D,$82,$54,$3E,$2F,$8D,$46; $42DC  タィシ゛ャをはし゛め = タィジャをはじめ
    db $90                         ; $42E6  　(space)
    db $42,$29,$3D,$2B,$3A,$2B,$8D,$3A,$47; $42E7  ほかのくにく゛にも = ほかのくにぐにも
    db $EF,$EE                     ; $42F0  newline
    db $90                         ; $42F2  　(space)
    db $28,$28,$2A,$39             ; $42F3  おおきな
    db $90                         ; $42F7  　(space)
    db $2A,$3D,$39,$29,$3A         ; $42F8  きのなかに
    db $90                         ; $42FD  　(space)
    db $37,$8D,$2A,$37,$25,$50     ; $42FE  て゛きている = できている
    db $8F                         ; $4304  。
    db $FA                         ; $4305  wait-for-button
    db $F7                         ; $4306  clear page
    db $EF,$EE                     ; $4307  newline
    db $96                         ; $4309  end name/box tag
    db $2A,$3E                     ; $430A  きは
    db $90                         ; $430C  　(space)
    db $32,$33,$8D,$34             ; $430D  そた゛ち = そだち
    db $90                         ; $4311  　(space)
    db $48,$29,$8D,$37             ; $4312  やか゛て = やがて
    db $90                         ; $4316  　(space)
    db $29,$51,$50                 ; $4317  かれる
    db $8F                         ; $431A  。
    db $EF,$EE                     ; $431B  newline
    db $90                         ; $431D  　(space)
    db $2B,$3A,$3A,$47             ; $431E  くににも
    db $90                         ; $4322  　(space)
    db $2F,$8D,$4B,$44,$4D,$26,$29,$8D; $4323  し゛ゅみょうか゛ = じゅみょうが
    db $90                         ; $432B  　(space)
    db $24,$50,$3D,$33,$8D         ; $432C  あるのた゛ = あるのだ
    db $8F                         ; $4331  。
    db $FA                         ; $4332  wait-for-button
    db $F7                         ; $4333  clear page
    db $EF,$EE                     ; $4334  newline
    db $96                         ; $4336  end name/box tag
    db $60,$88,$61,$38,$25,$26,$2B,$3A,$3E; $4337  カレキというくには
    db $90                         ; $4340  　(space)
    db $42,$38,$55,$38,$8D         ; $4341  ほとんと゛ = ほとんど
    db $EF,$EE                     ; $4346  newline
    db $90                         ; $4348  　(space)
    db $29,$51,$37,$2F,$43,$36,$37,$25,$50,$38,$25,$26; $4349  かれてしまっているという
    db $A4                         ; $4355  、
    db $A4                         ; $4356  、
    db $8F                         ; $4357  。
    db $FA                         ; $4358  wait-for-button
    db $F7                         ; $4359  clear page
    db $EF,$EE                     ; $435A  newline
    db $96                         ; $435C  end name/box tag
    db $33,$8D,$29,$8D             ; $435D  た゛か゛ = だが
    db $90                         ; $4361  　(space)
    db $29,$51,$50                 ; $4362  かれる
    db $90                         ; $4365  　(space)
    db $2A,$29,$8D,$24,$51,$3E,$8D ; $4366  きか゛あれは゛ = きがあれば
    db $EF,$EE                     ; $436D  newline
    db $90                         ; $436F  　(space)
    db $26,$43,$51,$37,$2B,$50     ; $4370  うまれてくる
    db $90                         ; $4376  　(space)
    db $2A,$47,$24,$50             ; $4377  きもある
    db $8F                         ; $437B  。
    db $FA                         ; $437C  wait-for-button
    db $F7                         ; $437D  clear page
    db $EF,$EE                     ; $437E  newline
    db $96                         ; $4380  end name/box tag
    db $39,$31,$8D,$29             ; $4381  なせ゛か = なぜか
    db $90                         ; $4385  　(space)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A; $4386  ほしふりのよるに
    db $90                         ; $438E  　(space)
    db $24,$4E,$33,$39             ; $438F  あらたな
    db $EF,$EE                     ; $4393  newline
    db $90                         ; $4395  　(space)
    db $2A,$29,$8D                 ; $4396  きか゛ = きが
    db $90                         ; $4399  　(space)
    db $26,$43,$51,$50,$2D,$38,$29,$8D; $439A  うまれることか゛ = うまれることが
    db $90                         ; $43A2  　(space)
    db $28,$28,$25                 ; $43A3  おおい
    db $A4                         ; $43A6  、
    db $8F                         ; $43A7  。
    db $F7                         ; $43A8  clear page
    db $F0                         ; $43A9  end of message


; --------------------------------------------------------------------------
; Message #3 ($43AA)
;   〈テリー〉は　ほんだなを　しらべた。
;   「モンスターじいさん、
;   「まものを　けっこんさせて　あらたな
;   しゅぞくをうみだせる　じいさん。
;   「いったい　どうやれば
;   そのようなことが　できるのか？
;   「ほしふりのほこらに　そのひみつは
;   かくされているはずだ、、！
; --------------------------------------------------------------------------
Bank68_Msg3:                               ; $43AA  (file $1103AA)
    db $F6                         ; $43AA  «insert hero name»
    db $3E                         ; $43AB  は
    db $90                         ; $43AC  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $43AD  ほんた゛なを = ほんだなを
    db $90                         ; $43B3  　(space)
    db $2F,$4E,$41,$8D,$33         ; $43B4  しらへ゛た = しらべた
    db $8F                         ; $43B9  。
    db $EF,$EE                     ; $43BA  newline
    db $FA                         ; $43BC  wait-for-button
    db $F7                         ; $43BD  clear page
    db $EF,$EE                     ; $43BE  newline
    db $F3                         ; $43C0  open text box
    db $96                         ; $43C1  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $43C2  モンスターし゛いさん = モンスターじいさん
    db $A4                         ; $43CC  、
    db $EF,$EE                     ; $43CD  newline
    db $FA                         ; $43CF  wait-for-button
    db $F7                         ; $43D0  clear page
    db $EF,$EE                     ; $43D1  newline
    db $F3                         ; $43D3  open text box
    db $96                         ; $43D4  end name/box tag
    db $43,$47,$3D,$54             ; $43D5  まものを
    db $90                         ; $43D9  　(space)
    db $2C,$36,$2D,$55,$2E,$31,$37 ; $43DA  けっこんさせて
    db $90                         ; $43E1  　(space)
    db $24,$4E,$33,$39             ; $43E2  あらたな
    db $EF,$EE                     ; $43E6  newline
    db $90                         ; $43E8  　(space)
    db $2F,$4B,$32,$8D,$2B,$54,$26,$44,$33,$8D,$31,$50; $43E9  しゅそ゛くをうみた゛せる = しゅぞくをうみだせる
    db $90                         ; $43F5  　(space)
    db $2F,$8D,$25,$2E,$55         ; $43F6  し゛いさん = じいさん
    db $8F                         ; $43FB  。
    db $FA                         ; $43FC  wait-for-button
    db $F7                         ; $43FD  clear page
    db $EF,$EE                     ; $43FE  newline
    db $96                         ; $4400  end name/box tag
    db $25,$36,$33,$25             ; $4401  いったい
    db $90                         ; $4405  　(space)
    db $38,$8D,$26,$48,$51,$3E,$8D ; $4406  と゛うやれは゛ = どうやれば
    db $EF,$EE                     ; $440D  newline
    db $90                         ; $440F  　(space)
    db $32,$3D,$4C,$26,$39,$2D,$38,$29,$8D; $4410  そのようなことか゛ = そのようなことが
    db $90                         ; $4419  　(space)
    db $37,$8D,$2A,$50,$3D,$29     ; $441A  て゛きるのか = できるのか
    db $98                         ; $4420  ？
    db $FA                         ; $4421  wait-for-button
    db $F7                         ; $4422  clear page
    db $EF,$EE                     ; $4423  newline
    db $96                         ; $4425  end name/box tag
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$3A; $4426  ほしふりのほこらに
    db $90                         ; $442F  　(space)
    db $32,$3D,$3F,$44,$35,$3E     ; $4430  そのひみつは
    db $EF,$EE                     ; $4436  newline
    db $90                         ; $4438  　(space)
    db $29,$2B,$2E,$51,$37,$25,$50,$3E,$30,$8D,$33,$8D; $4439  かくされているはす゛た゛ = かくされているはずだ
    db $A4                         ; $4445  、
    db $A4                         ; $4446  、
    db $99                         ; $4447  ！
    db $F7                         ; $4448  clear page
    db $F0                         ; $4449  end of message


; --------------------------------------------------------------------------
; Message #4 ($444A)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   しかし　それは　おばあさんの
;   いればいれ　だった！
; --------------------------------------------------------------------------
Bank68_Msg4:                               ; $444A  (file $11044A)
    db $F6                         ; $444A  «insert hero name»
    db $3E                         ; $444B  は
    db $90                         ; $444C  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $444D  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $4454  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $4456  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $445E  。
    db $FA                         ; $445F  wait-for-button
    db $F7                         ; $4460  clear page
    db $EF,$EE                     ; $4461  newline
    db $2F,$29,$2F                 ; $4463  しかし
    db $90                         ; $4466  　(space)
    db $32,$51,$3E                 ; $4467  それは
    db $90                         ; $446A  　(space)
    db $28,$3E,$8D,$24,$2E,$55,$3D ; $446B  おは゛あさんの = おばあさんの
    db $EF,$EE                     ; $4472  newline
    db $25,$51,$3E,$8D,$25,$51     ; $4474  いれは゛いれ = いればいれ
    db $90                         ; $447A  　(space)
    db $33,$8D,$36,$33             ; $447B  た゛った = だった
    db $99                         ; $447F  ！
    db $F7                         ; $4480  clear page
    db $F0                         ; $4481  end of message


; --------------------------------------------------------------------------
; Message #5 ($4482)
;   〈テリー〉は　おおガマのなかを
;   のぞきこんだ。
;   、ぐつぐつと　えたいのしれないものが
;   にえたぎっている！
; --------------------------------------------------------------------------
Bank68_Msg5:                               ; $4482  (file $110482)
    db $F6                         ; $4482  «insert hero name»
    db $3E                         ; $4483  は
    db $90                         ; $4484  　(space)
    db $28,$28,$60,$8D,$7A,$3D,$39,$29,$54; $4485  おおカ゛マのなかを = おおガマのなかを
    db $EF,$EE                     ; $448E  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $4490  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $4498  。
    db $FA                         ; $4499  wait-for-button
    db $F7                         ; $449A  clear page
    db $EF,$EE                     ; $449B  newline
    db $A4                         ; $449D  、
    db $2B,$8D,$35,$2B,$8D,$35,$38 ; $449E  く゛つく゛つと = ぐつぐつと
    db $90                         ; $44A5  　(space)
    db $27,$33,$25,$3D,$2F,$51,$39,$25,$47,$3D,$29,$8D; $44A6  えたいのしれないものか゛ = えたいのしれないものが
    db $EF,$EE                     ; $44B2  newline
    db $3A,$27,$33,$2A,$8D,$36,$37,$25,$50; $44B4  にえたき゛っている = にえたぎっている
    db $99                         ; $44BD  ！
    db $F7                         ; $44BE  clear page
    db $F0                         ; $44BF  end of message


; --------------------------------------------------------------------------
; Message #6 ($44C0)
;   「マスターようせいじゅくへ
;   ようこそ！
;   「〈テリー〉くん。　さきほどのしあい
;   みごとだったぞ！
;   「きょうの　こうぎは　まものの
;   つかまえかただ。　きくかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg6:                               ; $44C0  (file $1104C0)
    db $EA                         ; $44C0  ▶ new page
    db $9F                         ; $44C1  box tag
    db $96                         ; $44C2  end name/box tag
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25,$2F,$8D,$4B,$2B,$41; $44C3  マスターようせいし゛ゅくへ = マスターようせいじゅくへ
    db $EF,$EE                     ; $44D0  newline
    db $90,$90                     ; $44D2  　　(indent)
    db $4C,$26,$2D,$32             ; $44D4  ようこそ
    db $99                         ; $44D8  ！
    db $FA                         ; $44D9  wait-for-button
    db $F7                         ; $44DA  clear page
    db $EF,$EE                     ; $44DB  newline
    db $9F                         ; $44DD  box tag
    db $96                         ; $44DE  end name/box tag
    db $F6                         ; $44DF  «insert hero name»
    db $2B,$55                     ; $44E0  くん
    db $8F                         ; $44E2  。
    db $90                         ; $44E3  　(space)
    db $2E,$2A,$42,$38,$8D,$3D,$2F,$24,$25; $44E4  さきほと゛のしあい = さきほどのしあい
    db $EF,$EE                     ; $44ED  newline
    db $90,$90                     ; $44EF  　　(indent)
    db $44,$2D,$8D,$38,$33,$8D,$36,$33,$32,$8D; $44F1  みこ゛とた゛ったそ゛ = みごとだったぞ
    db $99                         ; $44FB  ！
    db $FA                         ; $44FC  wait-for-button
    db $F7                         ; $44FD  clear page
    db $EF,$EE                     ; $44FE  newline
    db $9F                         ; $4500  box tag
    db $96                         ; $4501  end name/box tag
    db $2A,$4D,$26,$3D             ; $4502  きょうの
    db $90                         ; $4506  　(space)
    db $2D,$26,$2A,$8D,$3E         ; $4507  こうき゛は = こうぎは
    db $90                         ; $450C  　(space)
    db $43,$47,$3D,$3D             ; $450D  まものの
    db $EF,$EE                     ; $4511  newline
    db $90,$90                     ; $4513  　　(indent)
    db $35,$29,$43,$27,$29,$33,$33,$8D; $4515  つかまえかたた゛ = つかまえかただ
    db $8F                         ; $451D  。
    db $90                         ; $451E  　(space)
    db $2A,$2B,$29,$3C             ; $451F  きくかね
    db $98                         ; $4523  ？
    db $FF                         ; $4524  はい/いいえ
    db $F0                         ; $4525  end of message


; --------------------------------------------------------------------------
; Message #7 ($4526)
;   「キメラのつばさはね　いつも
;   もっていったほうが　いいよ。
;   「そうすれば　とちゅうでも
;   もどって　これるからね。
; --------------------------------------------------------------------------
Bank68_Msg7:                               ; $4526  (file $110526)
    db $EB                         ; $4526  ▶ new page
    db $9F                         ; $4527  box tag
    db $96                         ; $4528  end name/box tag
    db $61,$7D,$85,$3D,$35,$3E,$8D,$2E,$3E,$3C; $4529  キメラのつは゛さはね = キメラのつばさはね
    db $90                         ; $4533  　(space)
    db $25,$35,$47                 ; $4534  いつも
    db $EF,$EE                     ; $4537  newline
    db $90,$90                     ; $4539  　　(indent)
    db $47,$36,$37,$25,$36,$33,$42,$26,$29,$8D; $453B  もっていったほうか゛ = もっていったほうが
    db $90                         ; $4545  　(space)
    db $25,$25,$4C                 ; $4546  いいよ
    db $8F                         ; $4549  。
    db $FA                         ; $454A  wait-for-button
    db $F7                         ; $454B  clear page
    db $EF,$EE                     ; $454C  newline
    db $9F                         ; $454E  box tag
    db $96                         ; $454F  end name/box tag
    db $32,$26,$30,$51,$3E,$8D     ; $4550  そうすれは゛ = そうすれば
    db $90                         ; $4556  　(space)
    db $38,$34,$4B,$26,$37,$8D,$47 ; $4557  とちゅうて゛も = とちゅうでも
    db $EF,$EE                     ; $455E  newline
    db $90,$90                     ; $4560  　　(indent)
    db $47,$38,$8D,$36,$37         ; $4562  もと゛って = もどって
    db $90                         ; $4567  　(space)
    db $2D,$51,$50,$29,$4E,$3C     ; $4568  これるからね
    db $8F                         ; $456E  。
    db $F7                         ; $456F  clear page
    db $F0                         ; $4570  end of message


; --------------------------------------------------------------------------
; Message #8 ($4571)
;   「きみは　つよいんだねえ。
;   せんせいに　かっちゃうなんて。
; --------------------------------------------------------------------------
Bank68_Msg8:                               ; $4571  (file $110571)
    db $EA                         ; $4571  ▶ new page
    db $9F                         ; $4572  box tag
    db $96                         ; $4573  end name/box tag
    db $2A,$44,$3E                 ; $4574  きみは
    db $90                         ; $4577  　(space)
    db $35,$4C,$25,$55,$33,$8D,$3C,$27; $4578  つよいんた゛ねえ = つよいんだねえ
    db $8F                         ; $4580  。
    db $EF,$EE                     ; $4581  newline
    db $90,$90                     ; $4583  　　(indent)
    db $31,$55,$31,$25,$3A         ; $4585  せんせいに
    db $90                         ; $458A  　(space)
    db $29,$36,$34,$49,$26,$39,$55,$37; $458B  かっちゃうなんて
    db $8F                         ; $4593  。
    db $F7                         ; $4594  clear page
    db $F0                         ; $4595  end of message


; --------------------------------------------------------------------------
; Message #9 ($4596)
;   「ここは
;   まちびととまもりのへやです。
;   「うえが　まちびとのとびら。
;   したが　まもりのとびらです。
; --------------------------------------------------------------------------
Bank68_Msg9:                               ; $4596  (file $110596)
    db $EA                         ; $4596  ▶ new page
    db $9F                         ; $4597  box tag
    db $96                         ; $4598  end name/box tag
    db $2D,$2D,$3E                 ; $4599  ここは
    db $EF,$EE                     ; $459C  newline
    db $90,$90                     ; $459E  　　(indent)
    db $43,$34,$3F,$8D,$38,$38,$43,$47,$4F,$3D,$41,$48,$37,$8D,$30; $45A0  まちひ゛ととまもりのへやて゛す = まちびととまもりのへやです
    db $8F                         ; $45AF  。
    db $FA                         ; $45B0  wait-for-button
    db $F7                         ; $45B1  clear page
    db $EF,$EE                     ; $45B2  newline
    db $9F                         ; $45B4  box tag
    db $96                         ; $45B5  end name/box tag
    db $26,$27,$29,$8D             ; $45B6  うえか゛ = うえが
    db $90                         ; $45BA  　(space)
    db $43,$34,$3F,$8D,$38,$3D,$38,$3F,$8D,$4E; $45BB  まちひ゛とのとひ゛ら = まちびとのとびら
    db $8F                         ; $45C5  。
    db $EF,$EE                     ; $45C6  newline
    db $90,$90                     ; $45C8  　　(indent)
    db $2F,$33,$29,$8D             ; $45CA  したか゛ = したが
    db $90                         ; $45CE  　(space)
    db $43,$47,$4F,$3D,$38,$3F,$8D,$4E,$37,$8D,$30; $45CF  まもりのとひ゛らて゛す = まもりのとびらです
    db $8F                         ; $45DA  。
    db $F7                         ; $45DB  clear page
    db $F0                         ; $45DC  end of message


; --------------------------------------------------------------------------
; Message #10 ($45DD)
;   「わたしは　いどのそこで
;   ひみつのけんきゅうを　しておる。
;   「しかも　ちょう　いちりゅうの
;   モンスターマスターなのだ。
;   「さあ　かかってきなさい！！
; --------------------------------------------------------------------------
Bank68_Msg10:                              ; $45DD  (file $1105DD)
    db $EA                         ; $45DD  ▶ new page
    db $9F                         ; $45DE  box tag
    db $96                         ; $45DF  end name/box tag
    db $53,$33,$2F,$3E             ; $45E0  わたしは
    db $90                         ; $45E4  　(space)
    db $25,$38,$8D,$3D,$32,$2D,$37,$8D; $45E5  いと゛のそこて゛ = いどのそこで
    db $EF,$EE                     ; $45ED  newline
    db $90,$90                     ; $45EF  　　(indent)
    db $3F,$44,$35,$3D,$2C,$55,$2A,$4B,$26,$54; $45F1  ひみつのけんきゅうを
    db $90                         ; $45FB  　(space)
    db $2F,$37,$28,$50             ; $45FC  しておる
    db $8F                         ; $4600  。
    db $FA                         ; $4601  wait-for-button
    db $F7                         ; $4602  clear page
    db $EF,$EE                     ; $4603  newline
    db $9F                         ; $4605  box tag
    db $96                         ; $4606  end name/box tag
    db $2F,$29,$47                 ; $4607  しかも
    db $90                         ; $460A  　(space)
    db $34,$4D,$26                 ; $460B  ちょう
    db $90                         ; $460E  　(space)
    db $25,$34,$4F,$4B,$26,$3D     ; $460F  いちりゅうの
    db $EF,$EE                     ; $4615  newline
    db $90,$90                     ; $4617  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$39,$3D,$33,$8D; $4619  モンスターマスターなのた゛ = モンスターマスターなのだ
    db $8F                         ; $4626  。
    db $FA                         ; $4627  wait-for-button
    db $F7                         ; $4628  clear page
    db $EF,$EE                     ; $4629  newline
    db $9F                         ; $462B  box tag
    db $96                         ; $462C  end name/box tag
    db $2E,$24                     ; $462D  さあ
    db $90                         ; $462F  　(space)
    db $29,$29,$36,$37,$2A,$39,$2E,$25; $4630  かかってきなさい
    db $99                         ; $4638  ！
    db $99                         ; $4639  ！
    db $EF,$EE                     ; $463A  newline
    db $F7                         ; $463C  clear page
    db $F0                         ; $463D  end of message


; --------------------------------------------------------------------------
; Message #11 ($463E)
;   「マスターとして　たたかうのも
;   けんきゅうの　ひとつ！
;   「さあ　かかってきなさい！！
; --------------------------------------------------------------------------
Bank68_Msg11:                              ; $463E  (file $11063E)
    db $EA                         ; $463E  ▶ new page
    db $9F                         ; $463F  box tag
    db $96                         ; $4640  end name/box tag
    db $7A,$67,$6A,$9C,$38,$2F,$37 ; $4641  マスターとして
    db $90                         ; $4648  　(space)
    db $33,$33,$29,$26,$3D,$47     ; $4649  たたかうのも
    db $EF,$EE                     ; $464F  newline
    db $90,$90                     ; $4651  　　(indent)
    db $2C,$55,$2A,$4B,$26,$3D     ; $4653  けんきゅうの
    db $90                         ; $4659  　(space)
    db $3F,$38,$35                 ; $465A  ひとつ
    db $99                         ; $465D  ！
    db $FA                         ; $465E  wait-for-button
    db $F7                         ; $465F  clear page
    db $EF,$EE                     ; $4660  newline
    db $9F                         ; $4662  box tag
    db $96                         ; $4663  end name/box tag
    db $2E,$24                     ; $4664  さあ
    db $90                         ; $4666  　(space)
    db $29,$29,$36,$37,$2A,$39,$2E,$25; $4667  かかってきなさい
    db $99                         ; $466F  ！
    db $99                         ; $4670  ！
    db $EF,$EE                     ; $4671  newline
    db $F7                         ; $4673  clear page
    db $F0                         ; $4674  end of message


; --------------------------------------------------------------------------
; Message #12 ($4675)
;   「[0F]クラスかちぬき　おめでとう。
;   「おもいでととまどいのへやが
;   ほうびとして　ひらかれたぞ！
;   「はいごうや　ふかを　おこなうには
;   ほしふりのほこらに　ゆくのだ。
;   「しろから　まちにでて
;   したに　おりていけば　あるぞ。
; --------------------------------------------------------------------------
Bank68_Msg12:                              ; $4675  (file $110675)
    db $EA                         ; $4675  ▶ new page
    db $9F                         ; $4676  box tag
    db $96                         ; $4677  end name/box tag
    db $0F                         ; $4678  ctrl $0F
    db $62,$85,$67,$29,$34,$3B,$2A ; $4679  クラスかちぬき
    db $90                         ; $4680  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $4681  おめて゛とう = おめでとう
    db $8F                         ; $4687  。
    db $EF,$EE                     ; $4688  newline
    db $FA                         ; $468A  wait-for-button
    db $F7                         ; $468B  clear page
    db $EF,$EE                     ; $468C  newline
    db $F3                         ; $468E  open text box
    db $9F                         ; $468F  box tag
    db $96                         ; $4690  end name/box tag
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$29,$8D; $4691  おもいて゛ととまと゛いのへやか゛ = おもいでととまどいのへやが
    db $EF,$EE                     ; $46A1  newline
    db $90,$90                     ; $46A3  　　(indent)
    db $42,$26,$3F,$8D,$38,$2F,$37 ; $46A5  ほうひ゛として = ほうびとして
    db $90                         ; $46AC  　(space)
    db $3F,$4E,$29,$51,$33,$32,$8D ; $46AD  ひらかれたそ゛ = ひらかれたぞ
    db $99                         ; $46B4  ！
    db $FA                         ; $46B5  wait-for-button
    db $F7                         ; $46B6  clear page
    db $EF,$EE                     ; $46B7  newline
    db $9F                         ; $46B9  box tag
    db $96                         ; $46BA  end name/box tag
    db $3E,$25,$2D,$8D,$26,$48     ; $46BB  はいこ゛うや = はいごうや
    db $90                         ; $46C1  　(space)
    db $40,$29,$54                 ; $46C2  ふかを
    db $90                         ; $46C5  　(space)
    db $28,$2D,$39,$26,$3A,$3E     ; $46C6  おこなうには
    db $EF,$EE                     ; $46CC  newline
    db $90,$90                     ; $46CE  　　(indent)
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$3A; $46D0  ほしふりのほこらに
    db $90                         ; $46D9  　(space)
    db $4A,$2B,$3D,$33,$8D         ; $46DA  ゆくのた゛ = ゆくのだ
    db $8F                         ; $46DF  。
    db $FA                         ; $46E0  wait-for-button
    db $F7                         ; $46E1  clear page
    db $EF,$EE                     ; $46E2  newline
    db $9F                         ; $46E4  box tag
    db $96                         ; $46E5  end name/box tag
    db $2F,$52,$29,$4E             ; $46E6  しろから
    db $90                         ; $46EA  　(space)
    db $43,$34,$3A,$37,$8D,$37     ; $46EB  まちにて゛て = まちにでて
    db $EF,$EE                     ; $46F1  newline
    db $90,$90                     ; $46F3  　　(indent)
    db $2F,$33,$3A                 ; $46F5  したに
    db $90                         ; $46F8  　(space)
    db $28,$4F,$37,$25,$2C,$3E,$8D ; $46F9  おりていけは゛ = おりていけば
    db $90                         ; $4700  　(space)
    db $24,$50,$32,$8D             ; $4701  あるそ゛ = あるぞ
    db $8F                         ; $4705  。
    db $F7                         ; $4706  clear page
    db $F0                         ; $4707  end of message


; --------------------------------------------------------------------------
; Message #13 ($4708)
;   「とまどいの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg13:                              ; $4708  (file $110708)
    db $EB                         ; $4708  ▶ new page
    db $9F                         ; $4709  box tag
    db $96                         ; $470A  end name/box tag
    db $38,$43,$38,$8D,$25,$3D     ; $470B  とまと゛いの = とまどいの
    db $90                         ; $4711  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $4712  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $471A  newline
    db $90,$90                     ; $471C  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $471E  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $4729  ？
    db $FF                         ; $472A  はい/いいえ
    db $F0                         ; $472B  end of message


; --------------------------------------------------------------------------
; Message #14 ($472C)
;   「わたしの　ながねんの
;   けんきゅうによれば、
;   「かおのついた　きのこや　いわや
;   じゅもくが　うまれることがある。
;   「、、しょだい　としょかん
;   かんちょうの　ろんぶんより。
; --------------------------------------------------------------------------
Bank68_Msg14:                              ; $472C  (file $11072C)
    db $EB                         ; $472C  ▶ new page
    db $9F                         ; $472D  box tag
    db $96                         ; $472E  end name/box tag
    db $53,$33,$2F,$3D             ; $472F  わたしの
    db $90                         ; $4733  　(space)
    db $39,$29,$8D,$3C,$55,$3D     ; $4734  なか゛ねんの = ながねんの
    db $EF,$EE                     ; $473A  newline
    db $90,$90                     ; $473C  　　(indent)
    db $2C,$55,$2A,$4B,$26,$3A,$4C,$51,$3E,$8D; $473E  けんきゅうによれは゛ = けんきゅうによれば
    db $A4                         ; $4748  、
    db $FA                         ; $4749  wait-for-button
    db $F7                         ; $474A  clear page
    db $EF,$EE                     ; $474B  newline
    db $9F                         ; $474D  box tag
    db $96                         ; $474E  end name/box tag
    db $29,$28,$3D,$35,$25,$33     ; $474F  かおのついた
    db $90                         ; $4755  　(space)
    db $2A,$3D,$2D,$48             ; $4756  きのこや
    db $90                         ; $475A  　(space)
    db $25,$53,$48                 ; $475B  いわや
    db $EF,$EE                     ; $475E  newline
    db $90,$90                     ; $4760  　　(indent)
    db $2F,$8D,$4B,$47,$2B,$29,$8D ; $4762  し゛ゅもくか゛ = じゅもくが
    db $90                         ; $4769  　(space)
    db $26,$43,$51,$50,$2D,$38,$29,$8D,$24,$50; $476A  うまれることか゛ある = うまれることがある
    db $8F                         ; $4774  。
    db $FA                         ; $4775  wait-for-button
    db $F7                         ; $4776  clear page
    db $EF,$EE                     ; $4777  newline
    db $9F                         ; $4779  box tag
    db $96                         ; $477A  end name/box tag
    db $A4                         ; $477B  、
    db $A4                         ; $477C  、
    db $2F,$4D,$33,$8D,$25         ; $477D  しょた゛い = しょだい
    db $90                         ; $4782  　(space)
    db $38,$2F,$4D,$29,$55         ; $4783  としょかん
    db $EF,$EE                     ; $4788  newline
    db $90,$90                     ; $478A  　　(indent)
    db $29,$55,$34,$4D,$26,$3D     ; $478C  かんちょうの
    db $90                         ; $4792  　(space)
    db $52,$55,$40,$8D,$55,$4C,$4F ; $4793  ろんふ゛んより = ろんぶんより
    db $8F                         ; $479A  。
    db $F7                         ; $479B  clear page
    db $F0                         ; $479C  end of message


; --------------------------------------------------------------------------
; Message #15 ($479D)
;   「おもいでの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg15:                              ; $479D  (file $11079D)
    db $EB                         ; $479D  ▶ new page
    db $9F                         ; $479E  box tag
    db $96                         ; $479F  end name/box tag
    db $28,$47,$25,$37,$8D,$3D     ; $47A0  おもいて゛の = おもいでの
    db $90                         ; $47A6  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $47A7  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $47AF  newline
    db $90,$90                     ; $47B1  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $47B3  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $47BE  ？
    db $FF                         ; $47BF  はい/いいえ
    db $F0                         ; $47C0  end of message


; --------------------------------------------------------------------------
; Message #16 ($47C1)
;   「どうくつの　おくふかく
;   いっぴきの　まものが　すむ。
;   「まものは　きみょうな　こえをだし
;   だれかを　よんでいるようだった。
;   「でんせつの　マスター　メリーの
;   ぼうけんの　きろくより。
; --------------------------------------------------------------------------
Bank68_Msg16:                              ; $47C1  (file $1107C1)
    db $EB                         ; $47C1  ▶ new page
    db $9F                         ; $47C2  box tag
    db $96                         ; $47C3  end name/box tag
    db $38,$8D,$26,$2B,$35,$3D     ; $47C4  と゛うくつの = どうくつの
    db $90                         ; $47CA  　(space)
    db $28,$2B,$40,$29,$2B         ; $47CB  おくふかく
    db $EF,$EE                     ; $47D0  newline
    db $90,$90                     ; $47D2  　　(indent)
    db $25,$36,$3F,$8E,$2A,$3D     ; $47D4  いっひ゜きの = いっぴきの
    db $90                         ; $47DA  　(space)
    db $43,$47,$3D,$29,$8D         ; $47DB  まものか゛ = まものが
    db $90                         ; $47E0  　(space)
    db $30,$45                     ; $47E1  すむ
    db $8F                         ; $47E3  。
    db $FA                         ; $47E4  wait-for-button
    db $F7                         ; $47E5  clear page
    db $EF,$EE                     ; $47E6  newline
    db $9F                         ; $47E8  box tag
    db $96                         ; $47E9  end name/box tag
    db $43,$47,$3D,$3E             ; $47EA  まものは
    db $90                         ; $47EE  　(space)
    db $2A,$44,$4D,$26,$39         ; $47EF  きみょうな
    db $90                         ; $47F4  　(space)
    db $2D,$27,$54,$33,$8D,$2F     ; $47F5  こえをた゛し = こえをだし
    db $EF,$EE                     ; $47FB  newline
    db $90,$90                     ; $47FD  　　(indent)
    db $33,$8D,$51,$29,$54         ; $47FF  た゛れかを = だれかを
    db $90                         ; $4804  　(space)
    db $4C,$55,$37,$8D,$25,$50,$4C,$26,$33,$8D,$36,$33; $4805  よんて゛いるようた゛った = よんでいるようだった
    db $8F                         ; $4811  。
    db $FA                         ; $4812  wait-for-button
    db $F7                         ; $4813  clear page
    db $EF,$EE                     ; $4814  newline
    db $9F                         ; $4816  box tag
    db $96                         ; $4817  end name/box tag
    db $37,$8D,$55,$31,$35,$3D     ; $4818  て゛んせつの = でんせつの
    db $90                         ; $481E  　(space)
    db $7A,$67,$6A,$9C             ; $481F  マスター
    db $90                         ; $4823  　(space)
    db $7D,$86,$9C,$3D             ; $4824  メリーの
    db $EF,$EE                     ; $4828  newline
    db $90,$90                     ; $482A  　　(indent)
    db $42,$8D,$26,$2C,$55,$3D     ; $482C  ほ゛うけんの = ぼうけんの
    db $90                         ; $4832  　(space)
    db $2A,$52,$2B,$4C,$4F         ; $4833  きろくより
    db $8F                         ; $4838  。
    db $F7                         ; $4839  clear page
    db $F0                         ; $483A  end of message


; --------------------------------------------------------------------------
; Message #17 ($483B)
;   「もっと　かたりたいのですが
;   ごめいわくでしょうか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg17:                              ; $483B  (file $11083B)
    db $EB                         ; $483B  ▶ new page
    db $9F                         ; $483C  box tag
    db $96                         ; $483D  end name/box tag
    db $47,$36,$38                 ; $483E  もっと
    db $90                         ; $4841  　(space)
    db $29,$33,$4F,$33,$25,$3D,$37,$8D,$30,$29,$8D; $4842  かたりたいのて゛すか゛ = かたりたいのですが
    db $EF,$EE                     ; $484D  newline
    db $90,$90                     ; $484F  　　(indent)
    db $2D,$8D,$46,$25,$53,$2B,$37,$8D,$2F,$4D,$26,$29; $4851  こ゛めいわくて゛しょうか = ごめいわくでしょうか
    db $98                         ; $485D  ？
    db $FF                         ; $485E  はい/いいえ
    db $F0                         ; $485F  end of message


; --------------------------------------------------------------------------
; Message #18 ($4860)
;   「その　あくまは
;   ほろびのまちに　すみついた。
;   「まるで　ほろびを　まもる
;   しゅごしゃのように、、。
;   「うしなわれた　まちの
;   さいごの　きろくです。
; --------------------------------------------------------------------------
Bank68_Msg18:                              ; $4860  (file $110860)
    db $EB                         ; $4860  ▶ new page
    db $9F                         ; $4861  box tag
    db $96                         ; $4862  end name/box tag
    db $32,$3D                     ; $4863  その
    db $90                         ; $4865  　(space)
    db $24,$2B,$43,$3E             ; $4866  あくまは
    db $EF,$EE                     ; $486A  newline
    db $90,$90                     ; $486C  　　(indent)
    db $42,$52,$3F,$8D,$3D,$43,$34,$3A; $486E  ほろひ゛のまちに = ほろびのまちに
    db $90                         ; $4876  　(space)
    db $30,$44,$35,$25,$33         ; $4877  すみついた
    db $8F                         ; $487C  。
    db $FA                         ; $487D  wait-for-button
    db $F7                         ; $487E  clear page
    db $EF,$EE                     ; $487F  newline
    db $9F                         ; $4881  box tag
    db $96                         ; $4882  end name/box tag
    db $43,$50,$37,$8D             ; $4883  まるて゛ = まるで
    db $90                         ; $4887  　(space)
    db $42,$52,$3F,$8D,$54         ; $4888  ほろひ゛を = ほろびを
    db $90                         ; $488D  　(space)
    db $43,$47,$50                 ; $488E  まもる
    db $EF,$EE                     ; $4891  newline
    db $90,$90                     ; $4893  　　(indent)
    db $2F,$4B,$2D,$8D,$2F,$49,$3D,$4C,$26,$3A; $4895  しゅこ゛しゃのように = しゅごしゃのように
    db $A4                         ; $489F  、
    db $A4                         ; $48A0  、
    db $8F                         ; $48A1  。
    db $FA                         ; $48A2  wait-for-button
    db $F7                         ; $48A3  clear page
    db $EF,$EE                     ; $48A4  newline
    db $9F                         ; $48A6  box tag
    db $96                         ; $48A7  end name/box tag
    db $26,$2F,$39,$53,$51,$33     ; $48A8  うしなわれた
    db $90                         ; $48AE  　(space)
    db $43,$34,$3D                 ; $48AF  まちの
    db $EF,$EE                     ; $48B2  newline
    db $90,$90                     ; $48B4  　　(indent)
    db $2E,$25,$2D,$8D,$3D         ; $48B6  さいこ゛の = さいごの
    db $90                         ; $48BB  　(space)
    db $2A,$52,$2B,$37,$8D,$30     ; $48BC  きろくて゛す = きろくです
    db $8F                         ; $48C2  。
    db $F7                         ; $48C3  clear page
    db $F0                         ; $48C4  end of message


; --------------------------------------------------------------------------
; Message #19 ($48C5)
;   おう「おお　〈テリー〉よ！
;   キラーパンサーを　たおしたか！
;   おう「キラーパンサーは　しっぷうの
;   ような　すばやさを　もつという。
;   おう「そなたの　すばやさは
;   たいふうなみ　なんじゃろうな！
; --------------------------------------------------------------------------
Bank68_Msg19:                              ; $48C5  (file $1108C5)
    db $EA                         ; $48C5  ▶ new page
    db $28,$26                     ; $48C6  おう  (speaker: おう)
    db $96                         ; $48C8  end name/box tag
    db $28,$28                     ; $48C9  おお
    db $90                         ; $48CB  　(space)
    db $F6                         ; $48CC  «insert hero name»
    db $4C                         ; $48CD  よ
    db $99                         ; $48CE  ！
    db $EF,$EE                     ; $48CF  newline
    db $90,$90                     ; $48D1  　　(indent)
    db $61,$85,$9C,$75,$8E,$8C,$65,$9C,$54; $48D3  キラーハ゜ンサーを = キラーパンサーを
    db $90                         ; $48DC  　(space)
    db $33,$28,$2F,$33,$29         ; $48DD  たおしたか
    db $99                         ; $48E2  ！
    db $FA                         ; $48E3  wait-for-button
    db $F7                         ; $48E4  clear page
    db $EF,$EE                     ; $48E5  newline
    db $28,$26                     ; $48E7  おう  (speaker: おう)
    db $96                         ; $48E9  end name/box tag
    db $61,$85,$9C,$75,$8E,$8C,$65,$9C,$3E; $48EA  キラーハ゜ンサーは = キラーパンサーは
    db $90                         ; $48F3  　(space)
    db $2F,$36,$40,$8E,$26,$3D     ; $48F4  しっふ゜うの = しっぷうの
    db $EF,$EE                     ; $48FA  newline
    db $90,$90                     ; $48FC  　　(indent)
    db $4C,$26,$39                 ; $48FE  ような
    db $90                         ; $4901  　(space)
    db $30,$3E,$8D,$48,$2E,$54     ; $4902  すは゛やさを = すばやさを
    db $90                         ; $4908  　(space)
    db $47,$35,$38,$25,$26         ; $4909  もつという
    db $8F                         ; $490E  。
    db $FA                         ; $490F  wait-for-button
    db $F7                         ; $4910  clear page
    db $EF,$EE                     ; $4911  newline
    db $28,$26                     ; $4913  おう  (speaker: おう)
    db $96                         ; $4915  end name/box tag
    db $32,$39,$33,$3D             ; $4916  そなたの
    db $90                         ; $491A  　(space)
    db $30,$3E,$8D,$48,$2E,$3E     ; $491B  すは゛やさは = すばやさは
    db $EF,$EE                     ; $4921  newline
    db $90,$90                     ; $4923  　　(indent)
    db $33,$25,$40,$26,$39,$44     ; $4925  たいふうなみ
    db $90                         ; $492B  　(space)
    db $39,$55,$2F,$8D,$49,$52,$26,$39; $492C  なんし゛ゃろうな = なんじゃろうな
    db $99                         ; $4934  ！
    db $F7                         ; $4935  clear page
    db $F0                         ; $4936  end of message


; --------------------------------------------------------------------------
; Message #20 ($4937)
;   おう「そうじゃ。　ほしふりのほこらで
;   はいごうは　おこなっておるか？
;   おう「はいごうを　せいするものは
;   たいかいを　せいするともうすぞ。
;   おう「はいごうを　かさねたほうが
;   つよいまものに　なるそうじゃ。
;   おう「それでは　いそがしいので
;   わしは　しつれいする！
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank68_Msg20:                              ; $4937  (file $110937)
    db $EA                         ; $4937  ▶ new page
    db $28,$26                     ; $4938  おう  (speaker: おう)
    db $96                         ; $493A  end name/box tag
    db $32,$26,$2F,$8D,$49         ; $493B  そうし゛ゃ = そうじゃ
    db $8F                         ; $4940  。
    db $90                         ; $4941  　(space)
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$37,$8D; $4942  ほしふりのほこらて゛ = ほしふりのほこらで
    db $EF,$EE                     ; $494C  newline
    db $90,$90                     ; $494E  　　(indent)
    db $3E,$25,$2D,$8D,$26,$3E     ; $4950  はいこ゛うは = はいごうは
    db $90                         ; $4956  　(space)
    db $28,$2D,$39,$36,$37,$28,$50,$29; $4957  おこなっておるか
    db $98                         ; $495F  ？
    db $FA                         ; $4960  wait-for-button
    db $F7                         ; $4961  clear page
    db $EF,$EE                     ; $4962  newline
    db $28,$26                     ; $4964  おう  (speaker: おう)
    db $96                         ; $4966  end name/box tag
    db $3E,$25,$2D,$8D,$26,$54     ; $4967  はいこ゛うを = はいごうを
    db $90                         ; $496D  　(space)
    db $31,$25,$30,$50,$47,$3D,$3E ; $496E  せいするものは
    db $EF,$EE                     ; $4975  newline
    db $90,$90                     ; $4977  　　(indent)
    db $33,$25,$29,$25,$54         ; $4979  たいかいを
    db $90                         ; $497E  　(space)
    db $31,$25,$30,$50,$38,$47,$26,$30,$32,$8D; $497F  せいするともうすそ゛ = せいするともうすぞ
    db $8F                         ; $4989  。
    db $FA                         ; $498A  wait-for-button
    db $F7                         ; $498B  clear page
    db $EF,$EE                     ; $498C  newline
    db $28,$26                     ; $498E  おう  (speaker: おう)
    db $96                         ; $4990  end name/box tag
    db $3E,$25,$2D,$8D,$26,$54     ; $4991  はいこ゛うを = はいごうを
    db $90                         ; $4997  　(space)
    db $29,$2E,$3C,$33,$42,$26,$29,$8D; $4998  かさねたほうか゛ = かさねたほうが
    db $EF,$EE                     ; $49A0  newline
    db $90,$90                     ; $49A2  　　(indent)
    db $35,$4C,$25,$43,$47,$3D,$3A ; $49A4  つよいまものに
    db $90                         ; $49AB  　(space)
    db $39,$50,$32,$26,$2F,$8D,$49 ; $49AC  なるそうし゛ゃ = なるそうじゃ
    db $8F                         ; $49B3  。
    db $FA                         ; $49B4  wait-for-button
    db $F7                         ; $49B5  clear page
    db $EF,$EE                     ; $49B6  newline
    db $28,$26                     ; $49B8  おう  (speaker: おう)
    db $96                         ; $49BA  end name/box tag
    db $32,$51,$37,$8D,$3E         ; $49BB  それて゛は = それでは
    db $90                         ; $49C0  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $49C1  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $49CA  newline
    db $90,$90                     ; $49CC  　　(indent)
    db $53,$2F,$3E                 ; $49CE  わしは
    db $90                         ; $49D1  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $49D2  しつれいする
    db $99                         ; $49D8  ！
    db $FA                         ; $49D9  wait-for-button
    db $F7                         ; $49DA  clear page
    db $EF,$EE                     ; $49DB  newline
    db $28,$26                     ; $49DD  おう  (speaker: おう)
    db $96                         ; $49DF  end name/box tag
    db $58,$69                     ; $49E0  ィソ
    db $90                         ; $49E2  　(space)
    db $58,$69                     ; $49E3  ィソ
    db $A4                         ; $49E5  、
    db $90                         ; $49E6  　(space)
    db $58,$69                     ; $49E7  ィソ
    db $90                         ; $49E9  　(space)
    db $58,$69                     ; $49EA  ィソ
    db $A4                         ; $49EC  、
    db $A4                         ; $49ED  、
    db $8F                         ; $49EE  。
    db $EF,$EE                     ; $49EF  newline
    db $F7                         ; $49F1  clear page
    db $F0                         ; $49F2  end of message


; --------------------------------------------------------------------------
; Message #21 ($49F3)
;   「ほしふりのたいかいは
;   くにたいこうで　おこなわれます。
;   「こんかいの　しゅつじょうこくは
;   タィボクのくに　カレキのくに、
;   「そして　マルタのくにです。
;   「これら　[03]ごくに　かてれば
;   ゆうしょうです！
; --------------------------------------------------------------------------
Bank68_Msg21:                              ; $49F3  (file $1109F3)
    db $EA                         ; $49F3  ▶ new page
    db $9F                         ; $49F4  box tag
    db $96                         ; $49F5  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$3E; $49F6  ほしふりのたいかいは
    db $EF,$EE                     ; $4A00  newline
    db $90,$90                     ; $4A02  　　(indent)
    db $2B,$3A,$33,$25,$2D,$26,$37,$8D; $4A04  くにたいこうて゛ = くにたいこうで
    db $90                         ; $4A0C  　(space)
    db $28,$2D,$39,$53,$51,$43,$30 ; $4A0D  おこなわれます
    db $8F                         ; $4A14  。
    db $FA                         ; $4A15  wait-for-button
    db $F7                         ; $4A16  clear page
    db $EF,$EE                     ; $4A17  newline
    db $9F                         ; $4A19  box tag
    db $96                         ; $4A1A  end name/box tag
    db $2D,$55,$29,$25,$3D         ; $4A1B  こんかいの
    db $90                         ; $4A20  　(space)
    db $2F,$4B,$35,$2F,$8D,$4D,$26,$2D,$2B,$3E; $4A21  しゅつし゛ょうこくは = しゅつじょうこくは
    db $EF,$EE                     ; $4A2B  newline
    db $90,$90                     ; $4A2D  　　(indent)
    db $6A,$58,$79,$8D,$62,$3D,$2B,$3A; $4A2F  タィホ゛クのくに = タィボクのくに
    db $90                         ; $4A37  　(space)
    db $60,$88,$61,$3D,$2B,$3A     ; $4A38  カレキのくに
    db $A4                         ; $4A3E  、
    db $FA                         ; $4A3F  wait-for-button
    db $F7                         ; $4A40  clear page
    db $EF,$EE                     ; $4A41  newline
    db $9F                         ; $4A43  box tag
    db $96                         ; $4A44  end name/box tag
    db $32,$2F,$37                 ; $4A45  そして
    db $90                         ; $4A48  　(space)
    db $7A,$87,$6A,$3D,$2B,$3A,$37,$8D,$30; $4A49  マルタのくにて゛す = マルタのくにです
    db $8F                         ; $4A52  。
    db $EF,$EE                     ; $4A53  newline
    db $FA                         ; $4A55  wait-for-button
    db $F7                         ; $4A56  clear page
    db $EF,$EE                     ; $4A57  newline
    db $F3                         ; $4A59  open text box
    db $9F                         ; $4A5A  box tag
    db $96                         ; $4A5B  end name/box tag
    db $2D,$51,$4E                 ; $4A5C  これら
    db $90                         ; $4A5F  　(space)
    db $03                         ; $4A60  ctrl $03
    db $2D,$8D,$2B,$3A             ; $4A61  こ゛くに = ごくに
    db $90                         ; $4A65  　(space)
    db $29,$37,$51,$3E,$8D         ; $4A66  かてれは゛ = かてれば
    db $EF,$EE                     ; $4A6B  newline
    db $90,$90                     ; $4A6D  　　(indent)
    db $4A,$26,$2F,$4D,$26,$37,$8D,$30; $4A6F  ゆうしょうて゛す = ゆうしょうです
    db $99                         ; $4A77  ！
    db $F7                         ; $4A78  clear page
    db $F0                         ; $4A79  end of message


; --------------------------------------------------------------------------
; Message #22 ($4A7A)
;   おう「おお　〈テリー〉よ！
;   じんめんじゅを　たおしたか！
;   おう「じんめんじゅは　のろいを
;   かけることが　できるそうだな。
;   おう「ひとつ　マルタの　おうを
;   のろってきては　くれぬか？
; --------------------------------------------------------------------------
Bank68_Msg22:                              ; $4A7A  (file $110A7A)
    db $EA                         ; $4A7A  ▶ new page
    db $28,$26                     ; $4A7B  おう  (speaker: おう)
    db $96                         ; $4A7D  end name/box tag
    db $28,$28                     ; $4A7E  おお
    db $90                         ; $4A80  　(space)
    db $F6                         ; $4A81  «insert hero name»
    db $4C                         ; $4A82  よ
    db $99                         ; $4A83  ！
    db $EF,$EE                     ; $4A84  newline
    db $90,$90                     ; $4A86  　　(indent)
    db $2F,$8D,$55,$46,$55,$2F,$8D,$4B,$54; $4A88  し゛んめんし゛ゅを = じんめんじゅを
    db $90                         ; $4A91  　(space)
    db $33,$28,$2F,$33,$29         ; $4A92  たおしたか
    db $99                         ; $4A97  ！
    db $FA                         ; $4A98  wait-for-button
    db $F7                         ; $4A99  clear page
    db $EF,$EE                     ; $4A9A  newline
    db $28,$26                     ; $4A9C  おう  (speaker: おう)
    db $96                         ; $4A9E  end name/box tag
    db $2F,$8D,$55,$46,$55,$2F,$8D,$4B,$3E; $4A9F  し゛んめんし゛ゅは = じんめんじゅは
    db $90                         ; $4AA8  　(space)
    db $3D,$52,$25,$54             ; $4AA9  のろいを
    db $EF,$EE                     ; $4AAD  newline
    db $90,$90                     ; $4AAF  　　(indent)
    db $29,$2C,$50,$2D,$38,$29,$8D ; $4AB1  かけることか゛ = かけることが
    db $90                         ; $4AB8  　(space)
    db $37,$8D,$2A,$50,$32,$26,$33,$8D,$39; $4AB9  て゛きるそうた゛な = できるそうだな
    db $8F                         ; $4AC2  。
    db $FA                         ; $4AC3  wait-for-button
    db $F7                         ; $4AC4  clear page
    db $EF,$EE                     ; $4AC5  newline
    db $28,$26                     ; $4AC7  おう  (speaker: おう)
    db $96                         ; $4AC9  end name/box tag
    db $3F,$38,$35                 ; $4ACA  ひとつ
    db $90                         ; $4ACD  　(space)
    db $7A,$87,$6A,$3D             ; $4ACE  マルタの
    db $90                         ; $4AD2  　(space)
    db $28,$26,$54                 ; $4AD3  おうを
    db $EF,$EE                     ; $4AD6  newline
    db $90,$90                     ; $4AD8  　　(indent)
    db $3D,$52,$36,$37,$2A,$37,$3E ; $4ADA  のろってきては
    db $90                         ; $4AE1  　(space)
    db $2B,$51,$3B,$29             ; $4AE2  くれぬか
    db $98                         ; $4AE6  ？
    db $F7                         ; $4AE7  clear page
    db $F0                         ; $4AE8  end of message


; --------------------------------------------------------------------------
; Message #23 ($4AE9)
;   「したで　とおせんぼしていた
;   おんなのこが　どいてくれたよ。
;   「そういえば　あのこ　きみの
;   しあいを　みにきていたな[91]、。
; --------------------------------------------------------------------------
Bank68_Msg23:                              ; $4AE9  (file $110AE9)
    db $EA                         ; $4AE9  ▶ new page
    db $9F                         ; $4AEA  box tag
    db $96                         ; $4AEB  end name/box tag
    db $2F,$33,$37,$8D             ; $4AEC  したて゛ = したで
    db $90                         ; $4AF0  　(space)
    db $38,$28,$31,$55,$42,$8D,$2F,$37,$25,$33; $4AF1  とおせんほ゛していた = とおせんぼしていた
    db $EF,$EE                     ; $4AFB  newline
    db $90,$90                     ; $4AFD  　　(indent)
    db $28,$55,$39,$3D,$2D,$29,$8D ; $4AFF  おんなのこか゛ = おんなのこが
    db $90                         ; $4B06  　(space)
    db $38,$8D,$25,$37,$2B,$51,$33,$4C; $4B07  と゛いてくれたよ = どいてくれたよ
    db $8F                         ; $4B0F  。
    db $FA                         ; $4B10  wait-for-button
    db $F7                         ; $4B11  clear page
    db $EF,$EE                     ; $4B12  newline
    db $9F                         ; $4B14  box tag
    db $96                         ; $4B15  end name/box tag
    db $32,$26,$25,$27,$3E,$8D     ; $4B16  そういえは゛ = そういえば
    db $90                         ; $4B1C  　(space)
    db $24,$3D,$2D                 ; $4B1D  あのこ
    db $90                         ; $4B20  　(space)
    db $2A,$44,$3D                 ; $4B21  きみの
    db $EF,$EE                     ; $4B24  newline
    db $90,$90                     ; $4B26  　　(indent)
    db $2F,$24,$25,$54             ; $4B28  しあいを
    db $90                         ; $4B2C  　(space)
    db $44,$3A,$2A,$37,$25,$33,$39 ; $4B2D  みにきていたな
    db $91                         ; $4B34  ctrl $91
    db $A4                         ; $4B35  、
    db $8F                         ; $4B36  。
    db $F7                         ; $4B37  clear page
    db $F0                         ; $4B38  end of message


; --------------------------------------------------------------------------
; Message #24 ($4B39)
;   「こんかいこそは　たいかいで
;   ゆうしょうして　ほしいもんだね。
;   「ほしふりのたいかいで　ゆうしょう
;   したら　ゆめがかなうそうだけど、
;   「タィジャが　ゆうしょうできたら
;   なにを　おねがいするのかね[94]。
;   「え？　モンスターじいさん？
;   あのじいさんなら　このしただよ。
; --------------------------------------------------------------------------
Bank68_Msg24:                              ; $4B39  (file $110B39)
    db $EB                         ; $4B39  ▶ new page
    db $9F                         ; $4B3A  box tag
    db $96                         ; $4B3B  end name/box tag
    db $2D,$55,$29,$25,$2D,$32,$3E ; $4B3C  こんかいこそは
    db $90                         ; $4B43  　(space)
    db $33,$25,$29,$25,$37,$8D     ; $4B44  たいかいて゛ = たいかいで
    db $EF,$EE                     ; $4B4A  newline
    db $90,$90                     ; $4B4C  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$37 ; $4B4E  ゆうしょうして
    db $90                         ; $4B55  　(space)
    db $42,$2F,$25,$47,$55,$33,$8D,$3C; $4B56  ほしいもんた゛ね = ほしいもんだね
    db $8F                         ; $4B5E  。
    db $FA                         ; $4B5F  wait-for-button
    db $F7                         ; $4B60  clear page
    db $EF,$EE                     ; $4B61  newline
    db $9F                         ; $4B63  box tag
    db $96                         ; $4B64  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$37,$8D; $4B65  ほしふりのたいかいて゛ = ほしふりのたいかいで
    db $90                         ; $4B70  　(space)
    db $4A,$26,$2F,$4D,$26         ; $4B71  ゆうしょう
    db $EF,$EE                     ; $4B76  newline
    db $90,$90                     ; $4B78  　　(indent)
    db $2F,$33,$4E                 ; $4B7A  したら
    db $90                         ; $4B7D  　(space)
    db $4A,$46,$29,$8D,$29,$39,$26,$32,$26,$33,$8D,$2C,$38,$8D; $4B7E  ゆめか゛かなうそうた゛けと゛ = ゆめがかなうそうだけど
    db $A4                         ; $4B8C  、
    db $FA                         ; $4B8D  wait-for-button
    db $F7                         ; $4B8E  clear page
    db $EF,$EE                     ; $4B8F  newline
    db $9F                         ; $4B91  box tag
    db $96                         ; $4B92  end name/box tag
    db $6A,$58,$66,$8D,$82,$29,$8D ; $4B93  タィシ゛ャか゛ = タィジャが
    db $90                         ; $4B9A  　(space)
    db $4A,$26,$2F,$4D,$26,$37,$8D,$2A,$33,$4E; $4B9B  ゆうしょうて゛きたら = ゆうしょうできたら
    db $EF,$EE                     ; $4BA5  newline
    db $90,$90                     ; $4BA7  　　(indent)
    db $39,$3A,$54                 ; $4BA9  なにを
    db $90                         ; $4BAC  　(space)
    db $28,$3C,$29,$8D,$25,$30,$50,$3D,$29,$3C; $4BAD  おねか゛いするのかね = おねがいするのかね
    db $94                         ; $4BB7  small kana
    db $8F                         ; $4BB8  。
    db $FA                         ; $4BB9  wait-for-button
    db $F7                         ; $4BBA  clear page
    db $EF,$EE                     ; $4BBB  newline
    db $9F                         ; $4BBD  box tag
    db $96                         ; $4BBE  end name/box tag
    db $27                         ; $4BBF  え
    db $98                         ; $4BC0  ？
    db $90                         ; $4BC1  　(space)
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $4BC2  モンスターし゛いさん = モンスターじいさん
    db $98                         ; $4BCC  ？
    db $EF,$EE                     ; $4BCD  newline
    db $90,$90                     ; $4BCF  　　(indent)
    db $24,$3D,$2F,$8D,$25,$2E,$55,$39,$4E; $4BD1  あのし゛いさんなら = あのじいさんなら
    db $90                         ; $4BDA  　(space)
    db $2D,$3D,$2F,$33,$33,$8D,$4C ; $4BDB  このしたた゛よ = このしただよ
    db $8F                         ; $4BE2  。
    db $F7                         ; $4BE3  clear page
    db $F0                         ; $4BE4  end of message


; --------------------------------------------------------------------------
; Message #25 ($4BE5)
;   「おまえ　けっこう　つよく
;   なったそうじゃんか。
;   「ゆうしょうなんか　むりだろうけど
;   まっ　せいぜいがんばりな！
; --------------------------------------------------------------------------
Bank68_Msg25:                              ; $4BE5  (file $110BE5)
    db $EB                         ; $4BE5  ▶ new page
    db $9F                         ; $4BE6  box tag
    db $96                         ; $4BE7  end name/box tag
    db $28,$43,$27                 ; $4BE8  おまえ
    db $90                         ; $4BEB  　(space)
    db $2C,$36,$2D,$26             ; $4BEC  けっこう
    db $90                         ; $4BF0  　(space)
    db $35,$4C,$2B                 ; $4BF1  つよく
    db $EF,$EE                     ; $4BF4  newline
    db $90,$90                     ; $4BF6  　　(indent)
    db $39,$36,$33,$32,$26,$2F,$8D,$49,$55,$29; $4BF8  なったそうし゛ゃんか = なったそうじゃんか
    db $8F                         ; $4C02  。
    db $FA                         ; $4C03  wait-for-button
    db $F7                         ; $4C04  clear page
    db $EF,$EE                     ; $4C05  newline
    db $9F                         ; $4C07  box tag
    db $96                         ; $4C08  end name/box tag
    db $4A,$26,$2F,$4D,$26,$39,$55,$29; $4C09  ゆうしょうなんか
    db $90                         ; $4C11  　(space)
    db $45,$4F,$33,$8D,$52,$26,$2C,$38,$8D; $4C12  むりた゛ろうけと゛ = むりだろうけど
    db $EF,$EE                     ; $4C1B  newline
    db $90,$90                     ; $4C1D  　　(indent)
    db $43,$36                     ; $4C1F  まっ
    db $90                         ; $4C21  　(space)
    db $31,$25,$31,$8D,$25,$29,$8D,$55,$3E,$8D,$4F,$39; $4C22  せいせ゛いか゛んは゛りな = せいぜいがんばりな
    db $99                         ; $4C2E  ！
    db $F7                         ; $4C2F  clear page
    db $F0                         ; $4C30  end of message


; --------------------------------------------------------------------------
; Message #26 ($4C31)
;   「ふ[9D]！　とうとう　したまで
;   やってこれたな[91]！
;   「そこの　くだりかいだんの　したは
;   ほしふりのほこらだそうだよ。
; --------------------------------------------------------------------------
Bank68_Msg26:                              ; $4C31  (file $110C31)
    db $EA                         ; $4C31  ▶ new page
    db $9F                         ; $4C32  box tag
    db $96                         ; $4C33  end name/box tag
    db $40                         ; $4C34  ふ
    db $9D                         ; $4C35  ctrl $9D
    db $99                         ; $4C36  ！
    db $90                         ; $4C37  　(space)
    db $38,$26,$38,$26             ; $4C38  とうとう
    db $90                         ; $4C3C  　(space)
    db $2F,$33,$43,$37,$8D         ; $4C3D  したまて゛ = したまで
    db $EF,$EE                     ; $4C42  newline
    db $90,$90                     ; $4C44  　　(indent)
    db $48,$36,$37,$2D,$51,$33,$39 ; $4C46  やってこれたな
    db $91                         ; $4C4D  ctrl $91
    db $99                         ; $4C4E  ！
    db $FA                         ; $4C4F  wait-for-button
    db $F7                         ; $4C50  clear page
    db $EF,$EE                     ; $4C51  newline
    db $9F                         ; $4C53  box tag
    db $96                         ; $4C54  end name/box tag
    db $32,$2D,$3D                 ; $4C55  そこの
    db $90                         ; $4C58  　(space)
    db $2B,$33,$8D,$4F,$29,$25,$33,$8D,$55,$3D; $4C59  くた゛りかいた゛んの = くだりかいだんの
    db $90                         ; $4C63  　(space)
    db $2F,$33,$3E                 ; $4C64  したは
    db $EF,$EE                     ; $4C67  newline
    db $90,$90                     ; $4C69  　　(indent)
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$33,$8D,$32,$26,$33,$8D,$4C; $4C6B  ほしふりのほこらた゛そうた゛よ = ほしふりのほこらだそうだよ
    db $8F                         ; $4C7A  。
    db $F7                         ; $4C7B  clear page
    db $F0                         ; $4C7C  end of message


; --------------------------------------------------------------------------
; Message #27 ($4C7D)
;   「ほしふりのほこらにおる
;   じいさんに　あうのじゃ！
;   「あえば　そなたの　みらいは
;   おおきく　かわるじゃろう！！
; --------------------------------------------------------------------------
Bank68_Msg27:                              ; $4C7D  (file $110C7D)
    db $EB                         ; $4C7D  ▶ new page
    db $9F                         ; $4C7E  box tag
    db $96                         ; $4C7F  end name/box tag
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$3A,$28,$50; $4C80  ほしふりのほこらにおる
    db $EF,$EE                     ; $4C8B  newline
    db $90,$90                     ; $4C8D  　　(indent)
    db $2F,$8D,$25,$2E,$55,$3A     ; $4C8F  し゛いさんに = じいさんに
    db $90                         ; $4C95  　(space)
    db $24,$26,$3D,$2F,$8D,$49     ; $4C96  あうのし゛ゃ = あうのじゃ
    db $99                         ; $4C9C  ！
    db $FA                         ; $4C9D  wait-for-button
    db $F7                         ; $4C9E  clear page
    db $EF,$EE                     ; $4C9F  newline
    db $9F                         ; $4CA1  box tag
    db $96                         ; $4CA2  end name/box tag
    db $24,$27,$3E,$8D             ; $4CA3  あえは゛ = あえば
    db $90                         ; $4CA7  　(space)
    db $32,$39,$33,$3D             ; $4CA8  そなたの
    db $90                         ; $4CAC  　(space)
    db $44,$4E,$25,$3E             ; $4CAD  みらいは
    db $EF,$EE                     ; $4CB1  newline
    db $90,$90                     ; $4CB3  　　(indent)
    db $28,$28,$2A,$2B             ; $4CB5  おおきく
    db $90                         ; $4CB9  　(space)
    db $29,$53,$50,$2F,$8D,$49,$52,$26; $4CBA  かわるし゛ゃろう = かわるじゃろう
    db $99                         ; $4CC2  ！
    db $99                         ; $4CC3  ！
    db $F7                         ; $4CC4  clear page
    db $F0                         ; $4CC5  end of message


; --------------------------------------------------------------------------
; Message #28 ($4CC6)
;   「ここは　たびのとびらのまです。
;   「おもいでととまどいのへやが
;   あらたに　ひらかれました！
;   「ホィミスラィムは　じゅもんで
;   なかまを　かいふくしてくれます。
;   「ぼうけんに　とてもやくだつから
;   てばなさないほうが　いいですよ。
;   「[16][19]は　あるけば　すこしずつ
;   かいふくしていきますからね！
; --------------------------------------------------------------------------
Bank68_Msg28:                              ; $4CC6  (file $110CC6)
    db $EA                         ; $4CC6  ▶ new page
    db $9F                         ; $4CC7  box tag
    db $96                         ; $4CC8  end name/box tag
    db $2D,$2D,$3E                 ; $4CC9  ここは
    db $90                         ; $4CCC  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$37,$8D,$30; $4CCD  たひ゛のとひ゛らのまて゛す = たびのとびらのまです
    db $8F                         ; $4CDA  。
    db $EF,$EE                     ; $4CDB  newline
    db $FA                         ; $4CDD  wait-for-button
    db $F7                         ; $4CDE  clear page
    db $EF,$EE                     ; $4CDF  newline
    db $F3                         ; $4CE1  open text box
    db $9F                         ; $4CE2  box tag
    db $96                         ; $4CE3  end name/box tag
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$29,$8D; $4CE4  おもいて゛ととまと゛いのへやか゛ = おもいでととまどいのへやが
    db $EF,$EE                     ; $4CF4  newline
    db $90,$90                     ; $4CF6  　　(indent)
    db $24,$4E,$33,$3A             ; $4CF8  あらたに
    db $90                         ; $4CFC  　(space)
    db $3F,$4E,$29,$51,$43,$2F,$33 ; $4CFD  ひらかれました
    db $99                         ; $4D04  ！
    db $FA                         ; $4D05  wait-for-button
    db $F7                         ; $4D06  clear page
    db $EF,$EE                     ; $4D07  newline
    db $9F                         ; $4D09  box tag
    db $96                         ; $4D0A  end name/box tag
    db $79,$58,$7B,$67,$85,$58,$7C,$3E; $4D0B  ホィミスラィムは
    db $90                         ; $4D13  　(space)
    db $2F,$8D,$4B,$47,$55,$37,$8D ; $4D14  し゛ゅもんて゛ = じゅもんで
    db $EF,$EE                     ; $4D1B  newline
    db $90,$90                     ; $4D1D  　　(indent)
    db $39,$29,$43,$54             ; $4D1F  なかまを
    db $90                         ; $4D23  　(space)
    db $29,$25,$40,$2B,$2F,$37,$2B,$51,$43,$30; $4D24  かいふくしてくれます
    db $8F                         ; $4D2E  。
    db $FA                         ; $4D2F  wait-for-button
    db $F7                         ; $4D30  clear page
    db $EF,$EE                     ; $4D31  newline
    db $9F                         ; $4D33  box tag
    db $96                         ; $4D34  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A     ; $4D35  ほ゛うけんに = ぼうけんに
    db $90                         ; $4D3B  　(space)
    db $38,$37,$47,$48,$2B,$33,$8D,$35,$29,$4E; $4D3C  とてもやくた゛つから = とてもやくだつから
    db $EF,$EE                     ; $4D46  newline
    db $90,$90                     ; $4D48  　　(indent)
    db $37,$3E,$8D,$39,$2E,$39,$25,$42,$26,$29,$8D; $4D4A  ては゛なさないほうか゛ = てばなさないほうが
    db $90                         ; $4D55  　(space)
    db $25,$25,$37,$8D,$30,$4C     ; $4D56  いいて゛すよ = いいですよ
    db $8F                         ; $4D5C  。
    db $FA                         ; $4D5D  wait-for-button
    db $F7                         ; $4D5E  clear page
    db $EF,$EE                     ; $4D5F  newline
    db $9F                         ; $4D61  box tag
    db $96                         ; $4D62  end name/box tag
    db $16                         ; $4D63  ctrl $16
    db $19                         ; $4D64  ctrl $19
    db $3E                         ; $4D65  は
    db $90                         ; $4D66  　(space)
    db $24,$50,$2C,$3E,$8D         ; $4D67  あるけは゛ = あるけば
    db $90                         ; $4D6C  　(space)
    db $30,$2D,$2F,$30,$8D,$35     ; $4D6D  すこしす゛つ = すこしずつ
    db $EF,$EE                     ; $4D73  newline
    db $90,$90                     ; $4D75  　　(indent)
    db $29,$25,$40,$2B,$2F,$37,$25,$2A,$43,$30,$29,$4E,$3C; $4D77  かいふくしていきますからね
    db $99                         ; $4D84  ！
    db $F7                         ; $4D85  clear page
    db $F0                         ; $4D86  end of message


; --------------------------------------------------------------------------
; Message #29 ($4D87)
;   「タマゴをまものに　かえるばしょ？
;   、、おおっ　おもいだした！
;   「ほ[9B]し[9B]ふ[9B]り[9B]の[9B]ほ[9B]こ[9B]ら！
;   ほしふりのほこらなのだ！！
; --------------------------------------------------------------------------
Bank68_Msg29:                              ; $4D87  (file $110D87)
    db $EA                         ; $4D87  ▶ new page
    db $9F                         ; $4D88  box tag
    db $96                         ; $4D89  end name/box tag
    db $6A,$7A,$64,$8D,$54,$43,$47,$3D,$3A; $4D8A  タマコ゛をまものに = タマゴをまものに
    db $90                         ; $4D93  　(space)
    db $29,$27,$50,$3E,$8D,$2F,$4D ; $4D94  かえるは゛しょ = かえるばしょ
    db $98                         ; $4D9B  ？
    db $EF,$EE                     ; $4D9C  newline
    db $90,$90                     ; $4D9E  　　(indent)
    db $A4                         ; $4DA0  、
    db $A4                         ; $4DA1  、
    db $28,$28,$36                 ; $4DA2  おおっ
    db $90                         ; $4DA5  　(space)
    db $28,$47,$25,$33,$8D,$2F,$33 ; $4DA6  おもいた゛した = おもいだした
    db $99                         ; $4DAD  ！
    db $FA                         ; $4DAE  wait-for-button
    db $F7                         ; $4DAF  clear page
    db $EF,$EE                     ; $4DB0  newline
    db $9F                         ; $4DB2  box tag
    db $96                         ; $4DB3  end name/box tag
    db $42                         ; $4DB4  ほ
    db $9B                         ; $4DB5  ctrl $9B
    db $2F                         ; $4DB6  し
    db $9B                         ; $4DB7  ctrl $9B
    db $40                         ; $4DB8  ふ
    db $9B                         ; $4DB9  ctrl $9B
    db $4F                         ; $4DBA  り
    db $9B                         ; $4DBB  ctrl $9B
    db $3D                         ; $4DBC  の
    db $9B                         ; $4DBD  ctrl $9B
    db $42                         ; $4DBE  ほ
    db $9B                         ; $4DBF  ctrl $9B
    db $2D                         ; $4DC0  こ
    db $9B                         ; $4DC1  ctrl $9B
    db $4E                         ; $4DC2  ら
    db $99                         ; $4DC3  ！
    db $EF,$EE                     ; $4DC4  newline
    db $90,$90                     ; $4DC6  　　(indent)
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$39,$3D,$33,$8D; $4DC8  ほしふりのほこらなのた゛ = ほしふりのほこらなのだ
    db $99                         ; $4DD4  ！
    db $99                         ; $4DD5  ！
    db $F7                         ; $4DD6  clear page
    db $F0                         ; $4DD7  end of message


; --------------------------------------------------------------------------
; Message #30 ($4DD8)
;   「ようやった！！
;   [0E]クラスかちぬきじゃぞ！
;   「やすらぎとゆうきのへやを
;   おうさまが　あけてくれたぞい！
;   「より　つよい　まもののおる
;   たびのとびらが　まっとるぞ！
; --------------------------------------------------------------------------
Bank68_Msg30:                              ; $4DD8  (file $110DD8)
    db $EA                         ; $4DD8  ▶ new page
    db $9F                         ; $4DD9  box tag
    db $96                         ; $4DDA  end name/box tag
    db $4C,$26,$48,$36,$33         ; $4DDB  ようやった
    db $99                         ; $4DE0  ！
    db $99                         ; $4DE1  ！
    db $EF,$EE                     ; $4DE2  newline
    db $90,$90                     ; $4DE4  　　(indent)
    db $0E                         ; $4DE6  ctrl $0E
    db $62,$85,$67,$29,$34,$3B,$2A,$2F,$8D,$49,$32,$8D; $4DE7  クラスかちぬきし゛ゃそ゛ = クラスかちぬきじゃぞ
    db $99                         ; $4DF3  ！
    db $FA                         ; $4DF4  wait-for-button
    db $F7                         ; $4DF5  clear page
    db $EF,$EE                     ; $4DF6  newline
    db $9F                         ; $4DF8  box tag
    db $96                         ; $4DF9  end name/box tag
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48,$54; $4DFA  やすらき゛とゆうきのへやを = やすらぎとゆうきのへやを
    db $EF,$EE                     ; $4E07  newline
    db $90,$90                     ; $4E09  　　(indent)
    db $28,$26,$2E,$43,$29,$8D     ; $4E0B  おうさまか゛ = おうさまが
    db $90                         ; $4E11  　(space)
    db $24,$2C,$37,$2B,$51,$33,$32,$8D,$25; $4E12  あけてくれたそ゛い = あけてくれたぞい
    db $99                         ; $4E1B  ！
    db $FA                         ; $4E1C  wait-for-button
    db $F7                         ; $4E1D  clear page
    db $EF,$EE                     ; $4E1E  newline
    db $9F                         ; $4E20  box tag
    db $96                         ; $4E21  end name/box tag
    db $4C,$4F                     ; $4E22  より
    db $90                         ; $4E24  　(space)
    db $35,$4C,$25                 ; $4E25  つよい
    db $90                         ; $4E28  　(space)
    db $43,$47,$3D,$3D,$28,$50     ; $4E29  まもののおる
    db $EF,$EE                     ; $4E2F  newline
    db $90,$90                     ; $4E31  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $4E33  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $4E3D  　(space)
    db $43,$36,$38,$50,$32,$8D     ; $4E3E  まっとるそ゛ = まっとるぞ
    db $99                         ; $4E44  ！
    db $F7                         ; $4E45  clear page
    db $F0                         ; $4E46  end of message


; --------------------------------------------------------------------------
; Message #31 ($4E47)
;   「ようやった！！
;   [0E]クラスかちぬきじゃぞ！
;   「やすらぎとゆうきのへや　それに
;   おもいでととまどいのへやを、
;   「おうさまが　あけてくれたぞい。
;   あらたな　とびらが　まっとるぞ！
; --------------------------------------------------------------------------
Bank68_Msg31:                              ; $4E47  (file $110E47)
    db $EA                         ; $4E47  ▶ new page
    db $9F                         ; $4E48  box tag
    db $96                         ; $4E49  end name/box tag
    db $4C,$26,$48,$36,$33         ; $4E4A  ようやった
    db $99                         ; $4E4F  ！
    db $99                         ; $4E50  ！
    db $EF,$EE                     ; $4E51  newline
    db $90,$90                     ; $4E53  　　(indent)
    db $0E                         ; $4E55  ctrl $0E
    db $62,$85,$67,$29,$34,$3B,$2A,$2F,$8D,$49,$32,$8D; $4E56  クラスかちぬきし゛ゃそ゛ = クラスかちぬきじゃぞ
    db $99                         ; $4E62  ！
    db $FA                         ; $4E63  wait-for-button
    db $F7                         ; $4E64  clear page
    db $EF,$EE                     ; $4E65  newline
    db $9F                         ; $4E67  box tag
    db $96                         ; $4E68  end name/box tag
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48; $4E69  やすらき゛とゆうきのへや = やすらぎとゆうきのへや
    db $90                         ; $4E75  　(space)
    db $32,$51,$3A                 ; $4E76  それに
    db $EF,$EE                     ; $4E79  newline
    db $90,$90                     ; $4E7B  　　(indent)
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$54; $4E7D  おもいて゛ととまと゛いのへやを = おもいでととまどいのへやを
    db $A4                         ; $4E8C  、
    db $FA                         ; $4E8D  wait-for-button
    db $F7                         ; $4E8E  clear page
    db $EF,$EE                     ; $4E8F  newline
    db $9F                         ; $4E91  box tag
    db $96                         ; $4E92  end name/box tag
    db $28,$26,$2E,$43,$29,$8D     ; $4E93  おうさまか゛ = おうさまが
    db $90                         ; $4E99  　(space)
    db $24,$2C,$37,$2B,$51,$33,$32,$8D,$25; $4E9A  あけてくれたそ゛い = あけてくれたぞい
    db $8F                         ; $4EA3  。
    db $EF,$EE                     ; $4EA4  newline
    db $90,$90                     ; $4EA6  　　(indent)
    db $24,$4E,$33,$39             ; $4EA8  あらたな
    db $90                         ; $4EAC  　(space)
    db $38,$3F,$8D,$4E,$29,$8D     ; $4EAD  とひ゛らか゛ = とびらが
    db $90                         ; $4EB3  　(space)
    db $43,$36,$38,$50,$32,$8D     ; $4EB4  まっとるそ゛ = まっとるぞ
    db $99                         ; $4EBA  ！
    db $F7                         ; $4EBB  clear page
    db $F0                         ; $4EBC  end of message


; --------------------------------------------------------------------------
; Message #32 ($4EBD)
;   「[0E]クラスの　さいしゅうせんは
;   となりの　ひかえしつにいる、
;   「マスター　テトが　あいてです。
; --------------------------------------------------------------------------
Bank68_Msg32:                              ; $4EBD  (file $110EBD)
    db $EB                         ; $4EBD  ▶ new page
    db $9F                         ; $4EBE  box tag
    db $96                         ; $4EBF  end name/box tag
    db $0E                         ; $4EC0  ctrl $0E
    db $62,$85,$67,$3D             ; $4EC1  クラスの
    db $90                         ; $4EC5  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $4EC6  さいしゅうせんは
    db $EF,$EE                     ; $4ECE  newline
    db $90,$90                     ; $4ED0  　　(indent)
    db $38,$39,$4F,$3D             ; $4ED2  となりの
    db $90                         ; $4ED6  　(space)
    db $3F,$29,$27,$2F,$35,$3A,$25,$50; $4ED7  ひかえしつにいる
    db $A4                         ; $4EDF  、
    db $FA                         ; $4EE0  wait-for-button
    db $F7                         ; $4EE1  clear page
    db $EF,$EE                     ; $4EE2  newline
    db $9F                         ; $4EE4  box tag
    db $96                         ; $4EE5  end name/box tag
    db $7A,$67,$6A,$9C             ; $4EE6  マスター
    db $90                         ; $4EEA  　(space)
    db $6E,$6F,$29,$8D             ; $4EEB  テトか゛ = テトが
    db $90                         ; $4EEF  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $4EF0  あいてて゛す = あいてです
    db $8F                         ; $4EF6  。
    db $EF,$EE                     ; $4EF7  newline
    db $F7                         ; $4EF9  clear page
    db $F0                         ; $4EFA  end of message


; --------------------------------------------------------------------------
; Message #33 ($4EFB)
;   「フッフッフ、。　[0E]クラスですよ。
;   [0E]クラスを　かちぬきました！！
;   「あれ？　あなたは　まだ
;   [0F]クラスですか？
;   「これからは　わたしのことを
;   マスター　テトとよんでほしい！
; --------------------------------------------------------------------------
Bank68_Msg33:                              ; $4EFB  (file $110EFB)
    db $EA                         ; $4EFB  ▶ new page
    db $9F                         ; $4EFC  box tag
    db $96                         ; $4EFD  end name/box tag
    db $77,$6D,$77,$6D,$77         ; $4EFE  フッフッフ
    db $A4                         ; $4F03  、
    db $8F                         ; $4F04  。
    db $90                         ; $4F05  　(space)
    db $0E                         ; $4F06  ctrl $0E
    db $62,$85,$67,$37,$8D,$30,$4C ; $4F07  クラスて゛すよ = クラスですよ
    db $8F                         ; $4F0E  。
    db $EF,$EE                     ; $4F0F  newline
    db $90,$90                     ; $4F11  　　(indent)
    db $0E                         ; $4F13  ctrl $0E
    db $62,$85,$67,$54             ; $4F14  クラスを
    db $90                         ; $4F18  　(space)
    db $29,$34,$3B,$2A,$43,$2F,$33 ; $4F19  かちぬきました
    db $99                         ; $4F20  ！
    db $99                         ; $4F21  ！
    db $FA                         ; $4F22  wait-for-button
    db $F7                         ; $4F23  clear page
    db $EF,$EE                     ; $4F24  newline
    db $9F                         ; $4F26  box tag
    db $96                         ; $4F27  end name/box tag
    db $24,$51                     ; $4F28  あれ
    db $98                         ; $4F2A  ？
    db $90                         ; $4F2B  　(space)
    db $24,$39,$33,$3E             ; $4F2C  あなたは
    db $90                         ; $4F30  　(space)
    db $43,$33,$8D                 ; $4F31  また゛ = まだ
    db $EF,$EE                     ; $4F34  newline
    db $90,$90                     ; $4F36  　　(indent)
    db $0F                         ; $4F38  ctrl $0F
    db $62,$85,$67,$37,$8D,$30,$29 ; $4F39  クラスて゛すか = クラスですか
    db $98                         ; $4F40  ？
    db $FA                         ; $4F41  wait-for-button
    db $F7                         ; $4F42  clear page
    db $EF,$EE                     ; $4F43  newline
    db $9F                         ; $4F45  box tag
    db $96                         ; $4F46  end name/box tag
    db $2D,$51,$29,$4E,$3E         ; $4F47  これからは
    db $90                         ; $4F4C  　(space)
    db $53,$33,$2F,$3D,$2D,$38,$54 ; $4F4D  わたしのことを
    db $EF,$EE                     ; $4F54  newline
    db $90,$90                     ; $4F56  　　(indent)
    db $7A,$67,$6A,$9C             ; $4F58  マスター
    db $90                         ; $4F5C  　(space)
    db $6E,$6F,$38,$4C,$55,$37,$8D,$42,$2F,$25; $4F5D  テトとよんて゛ほしい = テトとよんでほしい
    db $99                         ; $4F67  ！
    db $F7                         ; $4F68  clear page
    db $F0                         ; $4F69  end of message


; --------------------------------------------------------------------------
; Message #34 ($4F6A)
;   「あそこの　しんぷさまに
;   うたを　おしえてもらったよ。
;   「トラマナ　ミミック　ダーククラブ
;   ドロル　ふゆうじゅ　おおみみず、
;   「レミラーマは　あくまのカガミ
;   メーダ　ビーン　ェビルワンド！
;   「ザォラル　ォークにキングスラィム
;   ヨニコーンと　マッドロン、
;   「ベホマラーは　ホィミスラィム
;   ラィォネックに　しにがみきぞく！
; --------------------------------------------------------------------------
Bank68_Msg34:                              ; $4F6A  (file $110F6A)
    db $EA                         ; $4F6A  ▶ new page
    db $9F                         ; $4F6B  box tag
    db $96                         ; $4F6C  end name/box tag
    db $24,$32,$2D,$3D             ; $4F6D  あそこの
    db $90                         ; $4F71  　(space)
    db $2F,$55,$40,$8E,$2E,$43,$3A ; $4F72  しんふ゜さまに = しんぷさまに
    db $EF,$EE                     ; $4F79  newline
    db $90,$90                     ; $4F7B  　　(indent)
    db $26,$33,$54                 ; $4F7D  うたを
    db $90                         ; $4F80  　(space)
    db $28,$2F,$27,$37,$47,$4E,$36,$33,$4C; $4F81  おしえてもらったよ
    db $8F                         ; $4F8A  。
    db $FA                         ; $4F8B  wait-for-button
    db $F7                         ; $4F8C  clear page
    db $EF,$EE                     ; $4F8D  newline
    db $9F                         ; $4F8F  box tag
    db $96                         ; $4F90  end name/box tag
    db $6F,$85,$7A,$70             ; $4F91  トラマナ
    db $90                         ; $4F95  　(space)
    db $7B,$7B,$6D,$62             ; $4F96  ミミック
    db $90                         ; $4F9A  　(space)
    db $6A,$8D,$9C,$62,$62,$85,$77,$8D; $4F9B  タ゛ーククラフ゛ = ダーククラブ
    db $EF,$EE                     ; $4FA3  newline
    db $90,$90                     ; $4FA5  　　(indent)
    db $6F,$8D,$89,$87             ; $4FA7  ト゛ロル = ドロル
    db $90                         ; $4FAB  　(space)
    db $40,$4A,$26,$2F,$8D,$4B     ; $4FAC  ふゆうし゛ゅ = ふゆうじゅ
    db $90                         ; $4FB2  　(space)
    db $28,$28,$44,$44,$30,$8D     ; $4FB3  おおみみす゛ = おおみみず
    db $A4                         ; $4FB9  、
    db $FA                         ; $4FBA  wait-for-button
    db $F7                         ; $4FBB  clear page
    db $EF,$EE                     ; $4FBC  newline
    db $9F                         ; $4FBE  box tag
    db $96                         ; $4FBF  end name/box tag
    db $88,$7B,$85,$9C,$7A,$3E     ; $4FC0  レミラーマは
    db $90                         ; $4FC6  　(space)
    db $24,$2B,$43,$3D,$60,$60,$8D,$7B; $4FC7  あくまのカカ゛ミ = あくまのカガミ
    db $EF,$EE                     ; $4FCF  newline
    db $90,$90                     ; $4FD1  　　(indent)
    db $7D,$9C,$6A,$8D             ; $4FD3  メータ゛ = メーダ
    db $90                         ; $4FD7  　(space)
    db $76,$8D,$9C,$8C             ; $4FD8  ヒ゛ーン = ビーン
    db $90                         ; $4FDC  　(space)
    db $5C,$76,$8D,$87,$8A,$8C,$6F,$8D; $4FDD  ェヒ゛ルワント゛ = ェビルワンド
    db $99                         ; $4FE5  ！
    db $FA                         ; $4FE6  wait-for-button
    db $F7                         ; $4FE7  clear page
    db $EF,$EE                     ; $4FE8  newline
    db $9F                         ; $4FEA  box tag
    db $96                         ; $4FEB  end name/box tag
    db $65,$8D,$5E,$85,$87         ; $4FEC  サ゛ォラル = ザォラル
    db $90                         ; $4FF1  　(space)
    db $5E,$9C,$62,$3A,$61,$8C,$62,$8D,$67,$85,$58,$7C; $4FF2  ォークにキンク゛スラィム = ォークにキングスラィム
    db $EF,$EE                     ; $4FFE  newline
    db $90,$90                     ; $5000  　　(indent)
    db $81,$71,$64,$9C,$8C,$38     ; $5002  ヨニコーンと
    db $90                         ; $5008  　(space)
    db $7A,$6D,$6F,$8D,$89,$8C     ; $5009  マット゛ロン = マッドロン
    db $A4                         ; $500F  、
    db $FA                         ; $5010  wait-for-button
    db $F7                         ; $5011  clear page
    db $EF,$EE                     ; $5012  newline
    db $9F                         ; $5014  box tag
    db $96                         ; $5015  end name/box tag
    db $78,$8D,$79,$7A,$85,$9C,$3E ; $5016  ヘ゛ホマラーは = ベホマラーは
    db $90                         ; $501D  　(space)
    db $79,$58,$7B,$67,$85,$58,$7C ; $501E  ホィミスラィム
    db $EF,$EE                     ; $5025  newline
    db $90,$90                     ; $5027  　　(indent)
    db $85,$58,$5E,$73,$6D,$62,$3A ; $5029  ラィォネックに
    db $90                         ; $5030  　(space)
    db $2F,$3A,$29,$8D,$44,$2A,$32,$8D,$2B; $5031  しにか゛みきそ゛く = しにがみきぞく
    db $99                         ; $503A  ！
    db $F7                         ; $503B  clear page
    db $F0                         ; $503C  end of message


; --------------------------------------------------------------------------
; Message #35 ($503D)
;   「おおにわとりが
;   おおいに　わいとります。
; --------------------------------------------------------------------------
Bank68_Msg35:                              ; $503D  (file $11103D)
    db $EA                         ; $503D  ▶ new page
    db $9F                         ; $503E  box tag
    db $96                         ; $503F  end name/box tag
    db $28,$28,$3A,$53,$38,$4F,$29,$8D; $5040  おおにわとりか゛ = おおにわとりが
    db $EF,$EE                     ; $5048  newline
    db $90,$90                     ; $504A  　　(indent)
    db $28,$28,$25,$3A             ; $504C  おおいに
    db $90                         ; $5050  　(space)
    db $53,$25,$38,$4F,$43,$30     ; $5051  わいとります
    db $8F                         ; $5057  。
    db $F7                         ; $5058  clear page
    db $F0                         ; $5059  end of message


; --------------------------------------------------------------------------
; Message #36 ($505A)
;   「へへっ！　にいちゃんよ[95]。
;   [0E]クラスのあいてを　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg36:                              ; $505A  (file $11105A)
    db $EA                         ; $505A  ▶ new page
    db $9F                         ; $505B  box tag
    db $96                         ; $505C  end name/box tag
    db $41,$41,$36                 ; $505D  へへっ
    db $99                         ; $5060  ！
    db $90                         ; $5061  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $5062  にいちゃんよ
    db $95                         ; $5068  ctrl $95
    db $8F                         ; $5069  。
    db $EF,$EE                     ; $506A  newline
    db $90,$90                     ; $506C  　　(indent)
    db $0E                         ; $506E  ctrl $0E
    db $62,$85,$67,$3D,$24,$25,$37,$54; $506F  クラスのあいてを
    db $90                         ; $5077  　(space)
    db $2F,$4F,$33,$25,$29         ; $5078  しりたいか
    db $98                         ; $507D  ？
    db $FF                         ; $507E  はい/いいえ
    db $F0                         ; $507F  end of message


; --------------------------------------------------------------------------
; Message #37 ($5080)
;   「[0E]クラスの　さいしゅうせんは
;   ひかえしつの　テトがあいてだぜ。
;   「やつのまものは　よろいムカデと
;   スラィムつむりが　[02]たいだ。
;   「だい[01]しあいで　ポィズンリザード
;   というまものが　でてくるが、
;   「やつは　どくこうげきをしてくる。
;   キアリーがないと　つらいだろな！
; --------------------------------------------------------------------------
Bank68_Msg37:                              ; $5080  (file $111080)
    db $EA                         ; $5080  ▶ new page
    db $9F                         ; $5081  box tag
    db $96                         ; $5082  end name/box tag
    db $0E                         ; $5083  ctrl $0E
    db $62,$85,$67,$3D             ; $5084  クラスの
    db $90                         ; $5088  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $5089  さいしゅうせんは
    db $EF,$EE                     ; $5091  newline
    db $90,$90                     ; $5093  　　(indent)
    db $3F,$29,$27,$2F,$35,$3D     ; $5095  ひかえしつの
    db $90                         ; $509B  　(space)
    db $6E,$6F,$29,$8D,$24,$25,$37,$33,$8D,$31,$8D; $509C  テトか゛あいてた゛せ゛ = テトがあいてだぜ
    db $8F                         ; $50A7  。
    db $FA                         ; $50A8  wait-for-button
    db $F7                         ; $50A9  clear page
    db $EF,$EE                     ; $50AA  newline
    db $9F                         ; $50AC  box tag
    db $96                         ; $50AD  end name/box tag
    db $48,$35,$3D,$43,$47,$3D,$3E ; $50AE  やつのまものは
    db $90                         ; $50B5  　(space)
    db $4C,$52,$25,$7C,$60,$6E,$8D,$38; $50B6  よろいムカテ゛と = よろいムカデと
    db $EF,$EE                     ; $50BE  newline
    db $90,$90                     ; $50C0  　　(indent)
    db $67,$85,$58,$7C,$35,$45,$4F,$29,$8D; $50C2  スラィムつむりか゛ = スラィムつむりが
    db $90                         ; $50CB  　(space)
    db $02                         ; $50CC  ctrl $02
    db $33,$25,$33,$8D             ; $50CD  たいた゛ = たいだ
    db $8F                         ; $50D1  。
    db $FA                         ; $50D2  wait-for-button
    db $F7                         ; $50D3  clear page
    db $EF,$EE                     ; $50D4  newline
    db $9F                         ; $50D6  box tag
    db $96                         ; $50D7  end name/box tag
    db $33,$8D,$25                 ; $50D8  た゛い = だい
    db $01                         ; $50DB  ctrl $01
    db $2F,$24,$25,$37,$8D         ; $50DC  しあいて゛ = しあいで
    db $90                         ; $50E1  　(space)
    db $79,$8E,$58,$67,$8D,$8C,$86,$65,$8D,$9C,$6F,$8D; $50E2  ホ゜ィス゛ンリサ゛ート゛ = ポィズンリザード
    db $EF,$EE                     ; $50EE  newline
    db $90,$90                     ; $50F0  　　(indent)
    db $38,$25,$26,$43,$47,$3D,$29,$8D; $50F2  というまものか゛ = というまものが
    db $90                         ; $50FA  　(space)
    db $37,$8D,$37,$2B,$50,$29,$8D ; $50FB  て゛てくるか゛ = でてくるが
    db $A4                         ; $5102  、
    db $FA                         ; $5103  wait-for-button
    db $F7                         ; $5104  clear page
    db $EF,$EE                     ; $5105  newline
    db $9F                         ; $5107  box tag
    db $96                         ; $5108  end name/box tag
    db $48,$35,$3E                 ; $5109  やつは
    db $90                         ; $510C  　(space)
    db $38,$8D,$2B,$2D,$26,$2C,$8D,$2A,$54,$2F,$37,$2B,$50; $510D  と゛くこうけ゛きをしてくる = どくこうげきをしてくる
    db $8F                         ; $511A  。
    db $EF,$EE                     ; $511B  newline
    db $90,$90                     ; $511D  　　(indent)
    db $61,$56,$86,$9C,$29,$8D,$39,$25,$38; $511F  キアリーか゛ないと = キアリーがないと
    db $90                         ; $5128  　(space)
    db $35,$4E,$25,$33,$8D,$52,$39 ; $5129  つらいた゛ろな = つらいだろな
    db $99                         ; $5130  ！
    db $F7                         ; $5131  clear page
    db $F0                         ; $5132  end of message


; --------------------------------------------------------------------------
; Message #38 ($5133)
;   「おお　ひさしぶりじゃのう！
;   おぼえておるか？　わしのこと。
;   「おぬしが　タィジャに　きたとき
;   しろに　つれていったじじいじゃ。
;   「ひとは　わしのことを
;   モンスターじいさんと　よぶのう。
;   「ここは　ほしふりのほこら。
;   はいごうと　ふかの　ばしょ。
;   「はいごうは　まものと　まものを
;   けっこんさせることなんじゃ。
;   「けっこんさせると　タマゴが
;   うまれてくるぞい。
;   「ふか　というのは　そのタマゴを
;   まものに　かえることじゃな。
;   「きょうは　なんのようかいの？
; --------------------------------------------------------------------------
Bank68_Msg38:                              ; $5133  (file $111133)
    db $EA                         ; $5133  ▶ new page
    db $9F                         ; $5134  box tag
    db $96                         ; $5135  end name/box tag
    db $28,$28                     ; $5136  おお
    db $90                         ; $5138  　(space)
    db $3F,$2E,$2F,$40,$8D,$4F,$2F,$8D,$49,$3D,$26; $5139  ひさしふ゛りし゛ゃのう = ひさしぶりじゃのう
    db $99                         ; $5144  ！
    db $EF,$EE                     ; $5145  newline
    db $90,$90                     ; $5147  　　(indent)
    db $28,$42,$8D,$27,$37,$28,$50,$29; $5149  おほ゛えておるか = おぼえておるか
    db $98                         ; $5151  ？
    db $90                         ; $5152  　(space)
    db $53,$2F,$3D,$2D,$38         ; $5153  わしのこと
    db $8F                         ; $5158  。
    db $FA                         ; $5159  wait-for-button
    db $F7                         ; $515A  clear page
    db $EF,$EE                     ; $515B  newline
    db $9F                         ; $515D  box tag
    db $96                         ; $515E  end name/box tag
    db $28,$3B,$2F,$29,$8D         ; $515F  おぬしか゛ = おぬしが
    db $90                         ; $5164  　(space)
    db $6A,$58,$66,$8D,$82,$3A     ; $5165  タィシ゛ャに = タィジャに
    db $90                         ; $516B  　(space)
    db $2A,$33,$38,$2A             ; $516C  きたとき
    db $EF,$EE                     ; $5170  newline
    db $90,$90                     ; $5172  　　(indent)
    db $2F,$52,$3A                 ; $5174  しろに
    db $90                         ; $5177  　(space)
    db $35,$51,$37,$25,$36,$33,$2F,$8D,$2F,$8D,$25,$2F,$8D,$49; $5178  つれていったし゛し゛いし゛ゃ = つれていったじじいじゃ
    db $8F                         ; $5186  。
    db $FA                         ; $5187  wait-for-button
    db $F7                         ; $5188  clear page
    db $EF,$EE                     ; $5189  newline
    db $9F                         ; $518B  box tag
    db $96                         ; $518C  end name/box tag
    db $3F,$38,$3E                 ; $518D  ひとは
    db $90                         ; $5190  　(space)
    db $53,$2F,$3D,$2D,$38,$54     ; $5191  わしのことを
    db $EF,$EE                     ; $5197  newline
    db $90,$90                     ; $5199  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55,$38; $519B  モンスターし゛いさんと = モンスターじいさんと
    db $90                         ; $51A6  　(space)
    db $4C,$40,$8D,$3D,$26         ; $51A7  よふ゛のう = よぶのう
    db $8F                         ; $51AC  。
    db $FA                         ; $51AD  wait-for-button
    db $F7                         ; $51AE  clear page
    db $EF,$EE                     ; $51AF  newline
    db $9F                         ; $51B1  box tag
    db $96                         ; $51B2  end name/box tag
    db $2D,$2D,$3E                 ; $51B3  ここは
    db $90                         ; $51B6  　(space)
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E; $51B7  ほしふりのほこら
    db $8F                         ; $51BF  。
    db $EF,$EE                     ; $51C0  newline
    db $90,$90                     ; $51C2  　　(indent)
    db $3E,$25,$2D,$8D,$26,$38     ; $51C4  はいこ゛うと = はいごうと
    db $90                         ; $51CA  　(space)
    db $40,$29,$3D                 ; $51CB  ふかの
    db $90                         ; $51CE  　(space)
    db $3E,$8D,$2F,$4D             ; $51CF  は゛しょ = ばしょ
    db $8F                         ; $51D3  。
    db $FA                         ; $51D4  wait-for-button
    db $F7                         ; $51D5  clear page
    db $EF,$EE                     ; $51D6  newline
    db $9F                         ; $51D8  box tag
    db $96                         ; $51D9  end name/box tag
    db $3E,$25,$2D,$8D,$26,$3E     ; $51DA  はいこ゛うは = はいごうは
    db $90                         ; $51E0  　(space)
    db $43,$47,$3D,$38             ; $51E1  まものと
    db $90                         ; $51E5  　(space)
    db $43,$47,$3D,$54             ; $51E6  まものを
    db $EF,$EE                     ; $51EA  newline
    db $90,$90                     ; $51EC  　　(indent)
    db $2C,$36,$2D,$55,$2E,$31,$50,$2D,$38,$39,$55,$2F,$8D,$49; $51EE  けっこんさせることなんし゛ゃ = けっこんさせることなんじゃ
    db $8F                         ; $51FC  。
    db $FA                         ; $51FD  wait-for-button
    db $F7                         ; $51FE  clear page
    db $EF,$EE                     ; $51FF  newline
    db $9F                         ; $5201  box tag
    db $96                         ; $5202  end name/box tag
    db $2C,$36,$2D,$55,$2E,$31,$50,$38; $5203  けっこんさせると
    db $90                         ; $520B  　(space)
    db $6A,$7A,$64,$8D,$29,$8D     ; $520C  タマコ゛か゛ = タマゴが
    db $EF,$EE                     ; $5212  newline
    db $90,$90                     ; $5214  　　(indent)
    db $26,$43,$51,$37,$2B,$50,$32,$8D,$25; $5216  うまれてくるそ゛い = うまれてくるぞい
    db $8F                         ; $521F  。
    db $FA                         ; $5220  wait-for-button
    db $F7                         ; $5221  clear page
    db $EF,$EE                     ; $5222  newline
    db $9F                         ; $5224  box tag
    db $96                         ; $5225  end name/box tag
    db $40,$29                     ; $5226  ふか
    db $90                         ; $5228  　(space)
    db $38,$25,$26,$3D,$3E         ; $5229  というのは
    db $90                         ; $522E  　(space)
    db $32,$3D,$6A,$7A,$64,$8D,$54 ; $522F  そのタマコ゛を = そのタマゴを
    db $EF,$EE                     ; $5236  newline
    db $90,$90                     ; $5238  　　(indent)
    db $43,$47,$3D,$3A             ; $523A  まものに
    db $90                         ; $523E  　(space)
    db $29,$27,$50,$2D,$38,$2F,$8D,$49,$39; $523F  かえることし゛ゃな = かえることじゃな
    db $8F                         ; $5248  。
    db $FA                         ; $5249  wait-for-button
    db $F7                         ; $524A  clear page
    db $EF,$EE                     ; $524B  newline
    db $9F                         ; $524D  box tag
    db $96                         ; $524E  end name/box tag
    db $2A,$4D,$26,$3E             ; $524F  きょうは
    db $90                         ; $5253  　(space)
    db $39,$55,$3D,$4C,$26,$29,$25,$3D; $5254  なんのようかいの
    db $98                         ; $525C  ？
    db $EF,$EE                     ; $525D  newline
    db $F0                         ; $525F  end of message


; --------------------------------------------------------------------------
; Message #39 ($5260)
;   「ピチピチ！　いいこと　おしえて
;   あげる。　はいごうすると、
;   「けっとうに　えらんだ　まものの
;   けいとうが　うまれてくるのよ！
;   「けっとうと　けいとう、、
;   ちょっと　わかりにくいけど、
;   「つまり　スラィムけいの　まものを
;   つくりたかったら、
;   「けっとうに　スラィムけいを！
;   「ドラゴンけいの　まものを
;   つくりたかったら、
;   「けっとうに　ドラゴンけいを！
;   「こどもは　けっとうに　えらんだ
;   まもののほうに　にるってことね。
; --------------------------------------------------------------------------
Bank68_Msg39:                              ; $5260  (file $111260)
    db $EB                         ; $5260  ▶ new page
    db $9F                         ; $5261  box tag
    db $96                         ; $5262  end name/box tag
    db $76,$8E,$6B,$76,$8E,$6B     ; $5263  ヒ゜チヒ゜チ = ピチピチ
    db $99                         ; $5269  ！
    db $90                         ; $526A  　(space)
    db $25,$25,$2D,$38             ; $526B  いいこと
    db $90                         ; $526F  　(space)
    db $28,$2F,$27,$37             ; $5270  おしえて
    db $EF,$EE                     ; $5274  newline
    db $90,$90                     ; $5276  　　(indent)
    db $24,$2C,$8D,$50             ; $5278  あけ゛る = あげる
    db $8F                         ; $527C  。
    db $90                         ; $527D  　(space)
    db $3E,$25,$2D,$8D,$26,$30,$50,$38; $527E  はいこ゛うすると = はいごうすると
    db $A4                         ; $5286  、
    db $FA                         ; $5287  wait-for-button
    db $F7                         ; $5288  clear page
    db $EF,$EE                     ; $5289  newline
    db $9F                         ; $528B  box tag
    db $96                         ; $528C  end name/box tag
    db $2C,$36,$38,$26,$3A         ; $528D  けっとうに
    db $90                         ; $5292  　(space)
    db $27,$4E,$55,$33,$8D         ; $5293  えらんた゛ = えらんだ
    db $90                         ; $5298  　(space)
    db $43,$47,$3D,$3D             ; $5299  まものの
    db $EF,$EE                     ; $529D  newline
    db $90,$90                     ; $529F  　　(indent)
    db $2C,$25,$38,$26,$29,$8D     ; $52A1  けいとうか゛ = けいとうが
    db $90                         ; $52A7  　(space)
    db $26,$43,$51,$37,$2B,$50,$3D,$4C; $52A8  うまれてくるのよ
    db $99                         ; $52B0  ！
    db $FA                         ; $52B1  wait-for-button
    db $F7                         ; $52B2  clear page
    db $EF,$EE                     ; $52B3  newline
    db $9F                         ; $52B5  box tag
    db $96                         ; $52B6  end name/box tag
    db $2C,$36,$38,$26,$38         ; $52B7  けっとうと
    db $90                         ; $52BC  　(space)
    db $2C,$25,$38,$26             ; $52BD  けいとう
    db $A4                         ; $52C1  、
    db $A4                         ; $52C2  、
    db $EF,$EE                     ; $52C3  newline
    db $90,$90                     ; $52C5  　　(indent)
    db $34,$4D,$36,$38             ; $52C7  ちょっと
    db $90                         ; $52CB  　(space)
    db $53,$29,$4F,$3A,$2B,$25,$2C,$38,$8D; $52CC  わかりにくいけと゛ = わかりにくいけど
    db $A4                         ; $52D5  、
    db $FA                         ; $52D6  wait-for-button
    db $F7                         ; $52D7  clear page
    db $EF,$EE                     ; $52D8  newline
    db $9F                         ; $52DA  box tag
    db $96                         ; $52DB  end name/box tag
    db $35,$43,$4F                 ; $52DC  つまり
    db $90                         ; $52DF  　(space)
    db $67,$85,$58,$7C,$2C,$25,$3D ; $52E0  スラィムけいの
    db $90                         ; $52E7  　(space)
    db $43,$47,$3D,$54             ; $52E8  まものを
    db $EF,$EE                     ; $52EC  newline
    db $90,$90                     ; $52EE  　　(indent)
    db $35,$2B,$4F,$33,$29,$36,$33,$4E; $52F0  つくりたかったら
    db $A4                         ; $52F8  、
    db $FA                         ; $52F9  wait-for-button
    db $F7                         ; $52FA  clear page
    db $EF,$EE                     ; $52FB  newline
    db $9F                         ; $52FD  box tag
    db $96                         ; $52FE  end name/box tag
    db $2C,$36,$38,$26,$3A         ; $52FF  けっとうに
    db $90                         ; $5304  　(space)
    db $67,$85,$58,$7C,$2C,$25,$54 ; $5305  スラィムけいを
    db $99                         ; $530C  ！
    db $EF,$EE                     ; $530D  newline
    db $FA                         ; $530F  wait-for-button
    db $F7                         ; $5310  clear page
    db $EF,$EE                     ; $5311  newline
    db $F3                         ; $5313  open text box
    db $9F                         ; $5314  box tag
    db $96                         ; $5315  end name/box tag
    db $6F,$8D,$85,$64,$8D,$8C,$2C,$25,$3D; $5316  ト゛ラコ゛ンけいの = ドラゴンけいの
    db $90                         ; $531F  　(space)
    db $43,$47,$3D,$54             ; $5320  まものを
    db $EF,$EE                     ; $5324  newline
    db $90,$90                     ; $5326  　　(indent)
    db $35,$2B,$4F,$33,$29,$36,$33,$4E; $5328  つくりたかったら
    db $A4                         ; $5330  、
    db $FA                         ; $5331  wait-for-button
    db $F7                         ; $5332  clear page
    db $EF,$EE                     ; $5333  newline
    db $9F                         ; $5335  box tag
    db $96                         ; $5336  end name/box tag
    db $2C,$36,$38,$26,$3A         ; $5337  けっとうに
    db $90                         ; $533C  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$2C,$25,$54; $533D  ト゛ラコ゛ンけいを = ドラゴンけいを
    db $99                         ; $5346  ！
    db $EF,$EE                     ; $5347  newline
    db $FA                         ; $5349  wait-for-button
    db $F7                         ; $534A  clear page
    db $EF,$EE                     ; $534B  newline
    db $F3                         ; $534D  open text box
    db $9F                         ; $534E  box tag
    db $96                         ; $534F  end name/box tag
    db $2D,$38,$8D,$47,$3E         ; $5350  こと゛もは = こどもは
    db $90                         ; $5355  　(space)
    db $2C,$36,$38,$26,$3A         ; $5356  けっとうに
    db $90                         ; $535B  　(space)
    db $27,$4E,$55,$33,$8D         ; $535C  えらんた゛ = えらんだ
    db $EF,$EE                     ; $5361  newline
    db $90,$90                     ; $5363  　　(indent)
    db $43,$47,$3D,$3D,$42,$26,$3A ; $5365  まもののほうに
    db $90                         ; $536C  　(space)
    db $3A,$50,$36,$37,$2D,$38,$3C ; $536D  にるってことね
    db $8F                         ; $5374  。
    db $F7                         ; $5375  clear page
    db $F0                         ; $5376  end of message


; --------------------------------------------------------------------------
; Message #40 ($5377)
;   「はいごうしちゃうと　おやの
;   まものは　いなくなるんだよねー。
;   「でも　おやのもっていた　とくぎは
;   こどもに　うけつがれていくんだ。
;   「たとえば　ドラゴンをけっとうに
;   ホィミスラィムと　はいごうすると
;   「ホィミの　とくぎを　おぼえられる
;   ドラゴンキッズが　うまれる。
;   「そのドラゴンキッズを　そだてあげ
;   べつのまものとはいごうすると、。
;   「そうやって　どんどんはいごうして
;   つよいまものを　つくるわけさ！
; --------------------------------------------------------------------------
Bank68_Msg40:                              ; $5377  (file $111377)
    db $EB                         ; $5377  ▶ new page
    db $9F                         ; $5378  box tag
    db $96                         ; $5379  end name/box tag
    db $3E,$25,$2D,$8D,$26,$2F,$34,$49,$26,$38; $537A  はいこ゛うしちゃうと = はいごうしちゃうと
    db $90                         ; $5384  　(space)
    db $28,$48,$3D                 ; $5385  おやの
    db $EF,$EE                     ; $5388  newline
    db $90,$90                     ; $538A  　　(indent)
    db $43,$47,$3D,$3E             ; $538C  まものは
    db $90                         ; $5390  　(space)
    db $25,$39,$2B,$39,$50,$55,$33,$8D,$4C,$3C,$9C; $5391  いなくなるんた゛よねー = いなくなるんだよねー
    db $8F                         ; $539C  。
    db $FA                         ; $539D  wait-for-button
    db $F7                         ; $539E  clear page
    db $EF,$EE                     ; $539F  newline
    db $9F                         ; $53A1  box tag
    db $96                         ; $53A2  end name/box tag
    db $37,$8D,$47                 ; $53A3  て゛も = でも
    db $90                         ; $53A6  　(space)
    db $28,$48,$3D,$47,$36,$37,$25,$33; $53A7  おやのもっていた
    db $90                         ; $53AF  　(space)
    db $38,$2B,$2A,$8D,$3E         ; $53B0  とくき゛は = とくぎは
    db $EF,$EE                     ; $53B5  newline
    db $90,$90                     ; $53B7  　　(indent)
    db $2D,$38,$8D,$47,$3A         ; $53B9  こと゛もに = こどもに
    db $90                         ; $53BE  　(space)
    db $26,$2C,$35,$29,$8D,$51,$37,$25,$2B,$55,$33,$8D; $53BF  うけつか゛れていくんた゛ = うけつがれていくんだ
    db $8F                         ; $53CB  。
    db $FA                         ; $53CC  wait-for-button
    db $F7                         ; $53CD  clear page
    db $EF,$EE                     ; $53CE  newline
    db $9F                         ; $53D0  box tag
    db $96                         ; $53D1  end name/box tag
    db $33,$38,$27,$3E,$8D         ; $53D2  たとえは゛ = たとえば
    db $90                         ; $53D7  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$54,$2C,$36,$38,$26,$3A; $53D8  ト゛ラコ゛ンをけっとうに = ドラゴンをけっとうに
    db $EF,$EE                     ; $53E4  newline
    db $90,$90                     ; $53E6  　　(indent)
    db $79,$58,$7B,$67,$85,$58,$7C,$38; $53E8  ホィミスラィムと
    db $90                         ; $53F0  　(space)
    db $3E,$25,$2D,$8D,$26,$30,$50,$38; $53F1  はいこ゛うすると = はいごうすると
    db $FA                         ; $53F9  wait-for-button
    db $F7                         ; $53FA  clear page
    db $EF,$EE                     ; $53FB  newline
    db $9F                         ; $53FD  box tag
    db $96                         ; $53FE  end name/box tag
    db $79,$58,$7B,$3D             ; $53FF  ホィミの
    db $90                         ; $5403  　(space)
    db $38,$2B,$2A,$8D,$54         ; $5404  とくき゛を = とくぎを
    db $90                         ; $5409  　(space)
    db $28,$42,$8D,$27,$4E,$51,$50 ; $540A  おほ゛えられる = おぼえられる
    db $EF,$EE                     ; $5411  newline
    db $90,$90                     ; $5413  　　(indent)
    db $6F,$8D,$85,$64,$8D,$8C,$61,$6D,$67,$8D,$29,$8D; $5415  ト゛ラコ゛ンキッス゛か゛ = ドラゴンキッズが
    db $90                         ; $5421  　(space)
    db $26,$43,$51,$50             ; $5422  うまれる
    db $8F                         ; $5426  。
    db $FA                         ; $5427  wait-for-button
    db $F7                         ; $5428  clear page
    db $EF,$EE                     ; $5429  newline
    db $9F                         ; $542B  box tag
    db $96                         ; $542C  end name/box tag
    db $32,$3D,$6F,$8D,$85,$64,$8D,$8C,$61,$6D,$67,$8D,$54; $542D  そのト゛ラコ゛ンキッス゛を = そのドラゴンキッズを
    db $90                         ; $543A  　(space)
    db $32,$33,$8D,$37,$24,$2C,$8D ; $543B  そた゛てあけ゛ = そだてあげ
    db $EF,$EE                     ; $5442  newline
    db $90,$90                     ; $5444  　　(indent)
    db $41,$8D,$35,$3D,$43,$47,$3D,$38,$3E,$25,$2D,$8D,$26,$30,$50,$38; $5446  へ゛つのまものとはいこ゛うすると = べつのまものとはいごうすると
    db $A4                         ; $5456  、
    db $8F                         ; $5457  。
    db $FA                         ; $5458  wait-for-button
    db $F7                         ; $5459  clear page
    db $EF,$EE                     ; $545A  newline
    db $9F                         ; $545C  box tag
    db $96                         ; $545D  end name/box tag
    db $32,$26,$48,$36,$37         ; $545E  そうやって
    db $90                         ; $5463  　(space)
    db $38,$8D,$55,$38,$8D,$55,$3E,$25,$2D,$8D,$26,$2F,$37; $5464  と゛んと゛んはいこ゛うして = どんどんはいごうして
    db $EF,$EE                     ; $5471  newline
    db $90,$90                     ; $5473  　　(indent)
    db $35,$4C,$25,$43,$47,$3D,$54 ; $5475  つよいまものを
    db $90                         ; $547C  　(space)
    db $35,$2B,$50,$53,$2C,$2E     ; $547D  つくるわけさ
    db $99                         ; $5483  ！
    db $F7                         ; $5484  clear page
    db $F0                         ; $5485  end of message


; --------------------------------------------------------------------------
; Message #41 ($5486)
;   〈テリー〉は　ほんだなを　しらべた。
;   「モンスターじいさん　さく
;   はいごう　とは、
;   ほんをよみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg41:                              ; $5486  (file $111486)
    db $F6                         ; $5486  «insert hero name»
    db $3E                         ; $5487  は
    db $90                         ; $5488  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $5489  ほんた゛なを = ほんだなを
    db $90                         ; $548F  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5490  しらへ゛た = しらべた
    db $8F                         ; $5495  。
    db $EF,$EE                     ; $5496  newline
    db $FA                         ; $5498  wait-for-button
    db $F7                         ; $5499  clear page
    db $EF,$EE                     ; $549A  newline
    db $F3                         ; $549C  open text box
    db $96                         ; $549D  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $549E  モンスターし゛いさん = モンスターじいさん
    db $90                         ; $54A8  　(space)
    db $2E,$2B                     ; $54A9  さく
    db $EF,$EE                     ; $54AB  newline
    db $90                         ; $54AD  　(space)
    db $3E,$25,$2D,$8D,$26         ; $54AE  はいこ゛う = はいごう
    db $90                         ; $54B3  　(space)
    db $38,$3E                     ; $54B4  とは
    db $A4                         ; $54B6  、
    db $FA                         ; $54B7  wait-for-button
    db $F7                         ; $54B8  clear page
    db $EF,$EE                     ; $54B9  newline
    db $42,$55,$54,$4C,$44,$43,$30,$29; $54BB  ほんをよみますか
    db $98                         ; $54C3  ？
    db $EF,$EE                     ; $54C4  newline
    db $FF                         ; $54C6  はい/いいえ
    db $F0                         ; $54C7  end of message


; --------------------------------------------------------------------------
; Message #42 ($54C8)
;   「はいごうとは　まものと　まものを
;   けっこんさせることじゃ。
;   「はいごうを　おこなうと　おやの
;   まものは　どこかへ　さってしまう。
;   「おやの　のうりょくを　うけついだ
;   タマゴが　のこされるのじゃ。
;   「このとき　はいごうの　けっかが
;   ぼうけんのしょに　きろくされる。
;   「やりなおしが　できないんじゃ。
;   きを　つけるのだぞ。
;   「ふか　というのは　タマゴを
;   まものに　かえることじゃい。
; --------------------------------------------------------------------------
Bank68_Msg42:                              ; $54C8  (file $1114C8)
    db $96                         ; $54C8  end name/box tag
    db $3E,$25,$2D,$8D,$26,$38,$3E ; $54C9  はいこ゛うとは = はいごうとは
    db $90                         ; $54D0  　(space)
    db $43,$47,$3D,$38             ; $54D1  まものと
    db $90                         ; $54D5  　(space)
    db $43,$47,$3D,$54             ; $54D6  まものを
    db $EF,$EE                     ; $54DA  newline
    db $90                         ; $54DC  　(space)
    db $2C,$36,$2D,$55,$2E,$31,$50,$2D,$38,$2F,$8D,$49; $54DD  けっこんさせることし゛ゃ = けっこんさせることじゃ
    db $8F                         ; $54E9  。
    db $FA                         ; $54EA  wait-for-button
    db $F7                         ; $54EB  clear page
    db $EF,$EE                     ; $54EC  newline
    db $96                         ; $54EE  end name/box tag
    db $3E,$25,$2D,$8D,$26,$54     ; $54EF  はいこ゛うを = はいごうを
    db $90                         ; $54F5  　(space)
    db $28,$2D,$39,$26,$38         ; $54F6  おこなうと
    db $90                         ; $54FB  　(space)
    db $28,$48,$3D                 ; $54FC  おやの
    db $EF,$EE                     ; $54FF  newline
    db $90                         ; $5501  　(space)
    db $43,$47,$3D,$3E             ; $5502  まものは
    db $90                         ; $5506  　(space)
    db $38,$8D,$2D,$29,$41         ; $5507  と゛こかへ = どこかへ
    db $90                         ; $550C  　(space)
    db $2E,$36,$37,$2F,$43,$26     ; $550D  さってしまう
    db $8F                         ; $5513  。
    db $FA                         ; $5514  wait-for-button
    db $F7                         ; $5515  clear page
    db $EF,$EE                     ; $5516  newline
    db $96                         ; $5518  end name/box tag
    db $28,$48,$3D                 ; $5519  おやの
    db $90                         ; $551C  　(space)
    db $3D,$26,$4F,$4D,$2B,$54     ; $551D  のうりょくを
    db $90                         ; $5523  　(space)
    db $26,$2C,$35,$25,$33,$8D     ; $5524  うけついた゛ = うけついだ
    db $EF,$EE                     ; $552A  newline
    db $90                         ; $552C  　(space)
    db $6A,$7A,$64,$8D,$29,$8D     ; $552D  タマコ゛か゛ = タマゴが
    db $90                         ; $5533  　(space)
    db $3D,$2D,$2E,$51,$50,$3D,$2F,$8D,$49; $5534  のこされるのし゛ゃ = のこされるのじゃ
    db $8F                         ; $553D  。
    db $FA                         ; $553E  wait-for-button
    db $F7                         ; $553F  clear page
    db $EF,$EE                     ; $5540  newline
    db $96                         ; $5542  end name/box tag
    db $2D,$3D,$38,$2A             ; $5543  このとき
    db $90                         ; $5547  　(space)
    db $3E,$25,$2D,$8D,$26,$3D     ; $5548  はいこ゛うの = はいごうの
    db $90                         ; $554E  　(space)
    db $2C,$36,$29,$29,$8D         ; $554F  けっかか゛ = けっかが
    db $EF,$EE                     ; $5554  newline
    db $90                         ; $5556  　(space)
    db $42,$8D,$26,$2C,$55,$3D,$2F,$4D,$3A; $5557  ほ゛うけんのしょに = ぼうけんのしょに
    db $90                         ; $5560  　(space)
    db $2A,$52,$2B,$2E,$51,$50     ; $5561  きろくされる
    db $8F                         ; $5567  。
    db $FA                         ; $5568  wait-for-button
    db $F7                         ; $5569  clear page
    db $EF,$EE                     ; $556A  newline
    db $96                         ; $556C  end name/box tag
    db $48,$4F,$39,$28,$2F,$29,$8D ; $556D  やりなおしか゛ = やりなおしが
    db $90                         ; $5574  　(space)
    db $37,$8D,$2A,$39,$25,$55,$2F,$8D,$49; $5575  て゛きないんし゛ゃ = できないんじゃ
    db $8F                         ; $557E  。
    db $EF,$EE                     ; $557F  newline
    db $90                         ; $5581  　(space)
    db $2A,$54                     ; $5582  きを
    db $90                         ; $5584  　(space)
    db $35,$2C,$50,$3D,$33,$8D,$32,$8D; $5585  つけるのた゛そ゛ = つけるのだぞ
    db $8F                         ; $558D  。
    db $FA                         ; $558E  wait-for-button
    db $F7                         ; $558F  clear page
    db $EF,$EE                     ; $5590  newline
    db $96                         ; $5592  end name/box tag
    db $40,$29                     ; $5593  ふか
    db $90                         ; $5595  　(space)
    db $38,$25,$26,$3D,$3E         ; $5596  というのは
    db $90                         ; $559B  　(space)
    db $6A,$7A,$64,$8D,$54         ; $559C  タマコ゛を = タマゴを
    db $EF,$EE                     ; $55A1  newline
    db $90                         ; $55A3  　(space)
    db $43,$47,$3D,$3A             ; $55A4  まものに
    db $90                         ; $55A8  　(space)
    db $29,$27,$50,$2D,$38,$2F,$8D,$49,$25; $55A9  かえることし゛ゃい = かえることじゃい
    db $8F                         ; $55B2  。
    db $F7                         ; $55B3  clear page
    db $F0                         ; $55B4  end of message


; --------------------------------------------------------------------------
; Message #43 ($55B5)
;   〈テリー〉は　ほんだなを　しらべた。
;   「きょうの　ひとこと、
;   「おやの　レベルが　たかいほど
;   こどもの　のうりょくも　たかい！
;   つづきを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg43:                              ; $55B5  (file $1115B5)
    db $F6                         ; $55B5  «insert hero name»
    db $3E                         ; $55B6  は
    db $90                         ; $55B7  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $55B8  ほんた゛なを = ほんだなを
    db $90                         ; $55BE  　(space)
    db $2F,$4E,$41,$8D,$33         ; $55BF  しらへ゛た = しらべた
    db $8F                         ; $55C4  。
    db $EF,$EE                     ; $55C5  newline
    db $FA                         ; $55C7  wait-for-button
    db $F7                         ; $55C8  clear page
    db $EF,$EE                     ; $55C9  newline
    db $F3                         ; $55CB  open text box
    db $96                         ; $55CC  end name/box tag
    db $2A,$4D,$26,$3D             ; $55CD  きょうの
    db $90                         ; $55D1  　(space)
    db $3F,$38,$2D,$38             ; $55D2  ひとこと
    db $A4                         ; $55D6  、
    db $EF,$EE                     ; $55D7  newline
    db $90                         ; $55D9  　(space)
    db $FA                         ; $55DA  wait-for-button
    db $F7                         ; $55DB  clear page
    db $EF,$EE                     ; $55DC  newline
    db $F3                         ; $55DE  open text box
    db $96                         ; $55DF  end name/box tag
    db $28,$48,$3D                 ; $55E0  おやの
    db $90                         ; $55E3  　(space)
    db $88,$78,$8D,$87,$29,$8D     ; $55E4  レヘ゛ルか゛ = レベルが
    db $90                         ; $55EA  　(space)
    db $33,$29,$25,$42,$38,$8D     ; $55EB  たかいほと゛ = たかいほど
    db $EF,$EE                     ; $55F1  newline
    db $90                         ; $55F3  　(space)
    db $2D,$38,$8D,$47,$3D         ; $55F4  こと゛もの = こどもの
    db $90                         ; $55F9  　(space)
    db $3D,$26,$4F,$4D,$2B,$47     ; $55FA  のうりょくも
    db $90                         ; $5600  　(space)
    db $33,$29,$25                 ; $5601  たかい
    db $99                         ; $5604  ！
    db $FA                         ; $5605  wait-for-button
    db $F7                         ; $5606  clear page
    db $EF,$EE                     ; $5607  newline
    db $35,$35,$8D,$2A,$54         ; $5609  つつ゛きを = つづきを
    db $90                         ; $560E  　(space)
    db $4C,$44,$43,$30,$29         ; $560F  よみますか
    db $98                         ; $5614  ？
    db $EF,$EE                     ; $5615  newline
    db $FF                         ; $5617  はい/いいえ
    db $F0                         ; $5618  end of message


; --------------------------------------------------------------------------
; Message #44 ($5619)
;   「モンスターにっき
;   さく　モンスターじいさん
;   「〈テリー〉という　しょうねんは
;   なかなか　みどころのあるやつじゃ。
;   「ろうやに　いれられそうになった
;   プリォを　たすけてやったそうじゃ！
;   「さすが　わたぼうに　つれてこられた
;   だけのことは　あるのう。
; --------------------------------------------------------------------------
Bank68_Msg44:                              ; $5619  (file $111619)
    db $96                         ; $5619  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$3A,$36,$2A; $561A  モンスターにっき
    db $EF,$EE                     ; $5622  newline
    db $90                         ; $5624  　(space)
    db $2E,$2B                     ; $5625  さく
    db $90                         ; $5627  　(space)
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $5628  モンスターし゛いさん = モンスターじいさん
    db $FA                         ; $5632  wait-for-button
    db $F7                         ; $5633  clear page
    db $EF,$EE                     ; $5634  newline
    db $96                         ; $5636  end name/box tag
    db $F6                         ; $5637  «insert hero name»
    db $38,$25,$26                 ; $5638  という
    db $90                         ; $563B  　(space)
    db $2F,$4D,$26,$3C,$55,$3E     ; $563C  しょうねんは
    db $EF,$EE                     ; $5642  newline
    db $90                         ; $5644  　(space)
    db $39,$29,$39,$29             ; $5645  なかなか
    db $90                         ; $5649  　(space)
    db $44,$38,$8D,$2D,$52,$3D,$24,$50,$48,$35,$2F,$8D,$49; $564A  みと゛ころのあるやつし゛ゃ = みどころのあるやつじゃ
    db $8F                         ; $5657  。
    db $FA                         ; $5658  wait-for-button
    db $F7                         ; $5659  clear page
    db $EF,$EE                     ; $565A  newline
    db $96                         ; $565C  end name/box tag
    db $52,$26,$48,$3A             ; $565D  ろうやに
    db $90                         ; $5661  　(space)
    db $25,$51,$4E,$51,$32,$26,$3A,$39,$36,$33; $5662  いれられそうになった
    db $EF,$EE                     ; $566C  newline
    db $90                         ; $566E  　(space)
    db $77,$8E,$86,$5E,$54         ; $566F  フ゜リォを = プリォを
    db $90                         ; $5674  　(space)
    db $33,$30,$2C,$37,$48,$36,$33,$32,$26,$2F,$8D,$49; $5675  たすけてやったそうし゛ゃ = たすけてやったそうじゃ
    db $99                         ; $5681  ！
    db $FA                         ; $5682  wait-for-button
    db $F7                         ; $5683  clear page
    db $EF,$EE                     ; $5684  newline
    db $96                         ; $5686  end name/box tag
    db $2E,$30,$29,$8D             ; $5687  さすか゛ = さすが
    db $90                         ; $568B  　(space)
    db $53,$33,$42,$8D,$26,$3A     ; $568C  わたほ゛うに = わたぼうに
    db $90                         ; $5692  　(space)
    db $35,$51,$37,$2D,$4E,$51,$33 ; $5693  つれてこられた
    db $EF,$EE                     ; $569A  newline
    db $90                         ; $569C  　(space)
    db $33,$8D,$2C,$3D,$2D,$38,$3E ; $569D  た゛けのことは = だけのことは
    db $90                         ; $56A4  　(space)
    db $24,$50,$3D,$26             ; $56A5  あるのう
    db $8F                         ; $56A9  。
    db $F7                         ; $56AA  clear page
    db $F0                         ; $56AB  end of message


; --------------------------------------------------------------------------
; Message #45 ($56AC)
;   「モンスターじいさんは　このおくの
;   へやに　おられますじゃ。
;   「あそこの　ツタを　のぼれば
;   てっぺんまで　いけますのう！
; --------------------------------------------------------------------------
Bank68_Msg45:                              ; $56AC  (file $1116AC)
    db $EB                         ; $56AC  ▶ new page
    db $9F                         ; $56AD  box tag
    db $96                         ; $56AE  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55,$3E; $56AF  モンスターし゛いさんは = モンスターじいさんは
    db $90                         ; $56BA  　(space)
    db $2D,$3D,$28,$2B,$3D         ; $56BB  このおくの
    db $EF,$EE                     ; $56C0  newline
    db $90,$90                     ; $56C2  　　(indent)
    db $41,$48,$3A                 ; $56C4  へやに
    db $90                         ; $56C7  　(space)
    db $28,$4E,$51,$43,$30,$2F,$8D,$49; $56C8  おられますし゛ゃ = おられますじゃ
    db $8F                         ; $56D0  。
    db $FA                         ; $56D1  wait-for-button
    db $F7                         ; $56D2  clear page
    db $EF,$EE                     ; $56D3  newline
    db $9F                         ; $56D5  box tag
    db $96                         ; $56D6  end name/box tag
    db $24,$32,$2D,$3D             ; $56D7  あそこの
    db $90                         ; $56DB  　(space)
    db $6C,$6A,$54                 ; $56DC  ツタを
    db $90                         ; $56DF  　(space)
    db $3D,$42,$8D,$51,$3E,$8D     ; $56E0  のほ゛れは゛ = のぼれば
    db $EF,$EE                     ; $56E6  newline
    db $90,$90                     ; $56E8  　　(indent)
    db $37,$36,$41,$8E,$55,$43,$37,$8D; $56EA  てっへ゜んまて゛ = てっぺんまで
    db $90                         ; $56F2  　(space)
    db $25,$2C,$43,$30,$3D,$26     ; $56F3  いけますのう
    db $99                         ; $56F9  ！
    db $F7                         ; $56FA  clear page
    db $F0                         ; $56FB  end of message


; --------------------------------------------------------------------------
; Message #46 ($56FC)
;   「うまれたばかりの　まものは
;   レベルが　[01]になっちまう。
;   「つれている　まものが　ぜんいん
;   レベル[01]になったら　たいへんだ！
;   「ひとくみずつ　はいごうしたほうが
;   ぼうけんのきけんは　すくないぞ！
; --------------------------------------------------------------------------
Bank68_Msg46:                              ; $56FC  (file $1116FC)
    db $EA                         ; $56FC  ▶ new page
    db $9F                         ; $56FD  box tag
    db $96                         ; $56FE  end name/box tag
    db $26,$43,$51,$33,$3E,$8D,$29,$4F,$3D; $56FF  うまれたは゛かりの = うまれたばかりの
    db $90                         ; $5708  　(space)
    db $43,$47,$3D,$3E             ; $5709  まものは
    db $EF,$EE                     ; $570D  newline
    db $90,$90                     ; $570F  　　(indent)
    db $88,$78,$8D,$87,$29,$8D     ; $5711  レヘ゛ルか゛ = レベルが
    db $90                         ; $5717  　(space)
    db $01                         ; $5718  ctrl $01
    db $3A,$39,$36,$34,$43,$26     ; $5719  になっちまう
    db $8F                         ; $571F  。
    db $FA                         ; $5720  wait-for-button
    db $F7                         ; $5721  clear page
    db $EF,$EE                     ; $5722  newline
    db $9F                         ; $5724  box tag
    db $96                         ; $5725  end name/box tag
    db $35,$51,$37,$25,$50         ; $5726  つれている
    db $90                         ; $572B  　(space)
    db $43,$47,$3D,$29,$8D         ; $572C  まものか゛ = まものが
    db $90                         ; $5731  　(space)
    db $31,$8D,$55,$25,$55         ; $5732  せ゛んいん = ぜんいん
    db $EF,$EE                     ; $5737  newline
    db $90,$90                     ; $5739  　　(indent)
    db $88,$78,$8D,$87             ; $573B  レヘ゛ル = レベル
    db $01                         ; $573F  ctrl $01
    db $3A,$39,$36,$33,$4E         ; $5740  になったら
    db $90                         ; $5745  　(space)
    db $33,$25,$41,$55,$33,$8D     ; $5746  たいへんた゛ = たいへんだ
    db $99                         ; $574C  ！
    db $FA                         ; $574D  wait-for-button
    db $F7                         ; $574E  clear page
    db $EF,$EE                     ; $574F  newline
    db $9F                         ; $5751  box tag
    db $96                         ; $5752  end name/box tag
    db $3F,$38,$2B,$44,$30,$8D,$35 ; $5753  ひとくみす゛つ = ひとくみずつ
    db $90                         ; $575A  　(space)
    db $3E,$25,$2D,$8D,$26,$2F,$33,$42,$26,$29,$8D; $575B  はいこ゛うしたほうか゛ = はいごうしたほうが
    db $EF,$EE                     ; $5766  newline
    db $90,$90                     ; $5768  　　(indent)
    db $42,$8D,$26,$2C,$55,$3D,$2A,$2C,$55,$3E; $576A  ほ゛うけんのきけんは = ぼうけんのきけんは
    db $90                         ; $5774  　(space)
    db $30,$2B,$39,$25,$32,$8D     ; $5775  すくないそ゛ = すくないぞ
    db $99                         ; $577B  ！
    db $F7                         ; $577C  clear page
    db $F0                         ; $577D  end of message


; --------------------------------------------------------------------------
; Message #47 ($577E)
;   「はいごうは　ォスとメスを
;   うまく　そろえるのが　ひけつ。
;   「せいべつが　あわず　くやしい
;   おもいをすることもあるでしょう。
;   「しかし　タマゴかんていしという
;   ひとが　このくにのどこかにいて、
;   「タマゴに　しゅくふくをあたえて
;   せいべつをかえてくれるそうです！
; --------------------------------------------------------------------------
Bank68_Msg47:                              ; $577E  (file $11177E)
    db $EA                         ; $577E  ▶ new page
    db $9F                         ; $577F  box tag
    db $96                         ; $5780  end name/box tag
    db $3E,$25,$2D,$8D,$26,$3E     ; $5781  はいこ゛うは = はいごうは
    db $90                         ; $5787  　(space)
    db $5E,$67,$38,$7D,$67,$54     ; $5788  ォスとメスを
    db $EF,$EE                     ; $578E  newline
    db $90,$90                     ; $5790  　　(indent)
    db $26,$43,$2B                 ; $5792  うまく
    db $90                         ; $5795  　(space)
    db $32,$52,$27,$50,$3D,$29,$8D ; $5796  そろえるのか゛ = そろえるのが
    db $90                         ; $579D  　(space)
    db $3F,$2C,$35                 ; $579E  ひけつ
    db $8F                         ; $57A1  。
    db $FA                         ; $57A2  wait-for-button
    db $F7                         ; $57A3  clear page
    db $EF,$EE                     ; $57A4  newline
    db $9F                         ; $57A6  box tag
    db $96                         ; $57A7  end name/box tag
    db $31,$25,$41,$8D,$35,$29,$8D ; $57A8  せいへ゛つか゛ = せいべつが
    db $90                         ; $57AF  　(space)
    db $24,$53,$30,$8D             ; $57B0  あわす゛ = あわず
    db $90                         ; $57B4  　(space)
    db $2B,$48,$2F,$25             ; $57B5  くやしい
    db $EF,$EE                     ; $57B9  newline
    db $90,$90                     ; $57BB  　　(indent)
    db $28,$47,$25,$54,$30,$50,$2D,$38,$47,$24,$50,$37,$8D,$2F,$4D,$26; $57BD  おもいをすることもあるて゛しょう = おもいをすることもあるでしょう
    db $8F                         ; $57CD  。
    db $FA                         ; $57CE  wait-for-button
    db $F7                         ; $57CF  clear page
    db $EF,$EE                     ; $57D0  newline
    db $9F                         ; $57D2  box tag
    db $96                         ; $57D3  end name/box tag
    db $2F,$29,$2F                 ; $57D4  しかし
    db $90                         ; $57D7  　(space)
    db $6A,$7A,$64,$8D,$29,$55,$37,$25,$2F,$38,$25,$26; $57D8  タマコ゛かんていしという = タマゴかんていしという
    db $EF,$EE                     ; $57E4  newline
    db $90,$90                     ; $57E6  　　(indent)
    db $3F,$38,$29,$8D             ; $57E8  ひとか゛ = ひとが
    db $90                         ; $57EC  　(space)
    db $2D,$3D,$2B,$3A,$3D,$38,$8D,$2D,$29,$3A,$25,$37; $57ED  このくにのと゛こかにいて = このくにのどこかにいて
    db $A4                         ; $57F9  、
    db $FA                         ; $57FA  wait-for-button
    db $F7                         ; $57FB  clear page
    db $EF,$EE                     ; $57FC  newline
    db $9F                         ; $57FE  box tag
    db $96                         ; $57FF  end name/box tag
    db $6A,$7A,$64,$8D,$3A         ; $5800  タマコ゛に = タマゴに
    db $90                         ; $5805  　(space)
    db $2F,$4B,$2B,$40,$2B,$54,$24,$33,$27,$37; $5806  しゅくふくをあたえて
    db $EF,$EE                     ; $5810  newline
    db $90,$90                     ; $5812  　　(indent)
    db $31,$25,$41,$8D,$35,$54,$29,$27,$37,$2B,$51,$50,$32,$26,$37,$8D,$30; $5814  せいへ゛つをかえてくれるそうて゛す = せいべつをかえてくれるそうです
    db $99                         ; $5825  ！
    db $F7                         ; $5826  clear page
    db $F0                         ; $5827  end of message


; --------------------------------------------------------------------------
; Message #48 ($5828)
;   「あ[9D]ら　ま[9D]！　なんて　かわいい
;   ぼっちゃんだこと。
;   「おなまえ　なんていうの？
;   〈テリー〉、　〈テリー〉ちゃまね！
;   「あたしは　タマゴかんていし。
;   どうぞ　よ[9B]ろ[9B]し[9B]く！
;   「あたしの　うちでは　あなたの
;   タマゴを　「かんてい[97]して、
;   「どんな　こどもが　うまれそうかを
;   うまれるまえに　おしえちゃうの！
;   「もうひとつの　わたしのしごとは
;   「しゅくふく[97]よ。
;   「しゅくふくは　まもののせいべつを
;   かえちゃうことなの！
;   「わかったかしら？　それじゃあ
;   いまから　な[9B]に[9B]す[9B]る？
; --------------------------------------------------------------------------
Bank68_Msg48:                              ; $5828  (file $111828)
    db $EB                         ; $5828  ▶ new page
    db $9F                         ; $5829  box tag
    db $96                         ; $582A  end name/box tag
    db $24                         ; $582B  あ
    db $9D                         ; $582C  ctrl $9D
    db $4E                         ; $582D  ら
    db $90                         ; $582E  　(space)
    db $43                         ; $582F  ま
    db $9D                         ; $5830  ctrl $9D
    db $99                         ; $5831  ！
    db $90                         ; $5832  　(space)
    db $39,$55,$37                 ; $5833  なんて
    db $90                         ; $5836  　(space)
    db $29,$53,$25,$25             ; $5837  かわいい
    db $EF,$EE                     ; $583B  newline
    db $90,$90                     ; $583D  　　(indent)
    db $42,$8D,$36,$34,$49,$55,$33,$8D,$2D,$38; $583F  ほ゛っちゃんた゛こと = ぼっちゃんだこと
    db $8F                         ; $5849  。
    db $FA                         ; $584A  wait-for-button
    db $F7                         ; $584B  clear page
    db $EF,$EE                     ; $584C  newline
    db $9F                         ; $584E  box tag
    db $96                         ; $584F  end name/box tag
    db $28,$39,$43,$27             ; $5850  おなまえ
    db $90                         ; $5854  　(space)
    db $39,$55,$37,$25,$26,$3D     ; $5855  なんていうの
    db $98                         ; $585B  ？
    db $EF,$EE                     ; $585C  newline
    db $90,$90                     ; $585E  　　(indent)
    db $F6                         ; $5860  «insert hero name»
    db $A4                         ; $5861  、
    db $90                         ; $5862  　(space)
    db $F6                         ; $5863  «insert hero name»
    db $34,$49,$43,$3C             ; $5864  ちゃまね
    db $99                         ; $5868  ！
    db $FA                         ; $5869  wait-for-button
    db $F7                         ; $586A  clear page
    db $EF,$EE                     ; $586B  newline
    db $9F                         ; $586D  box tag
    db $96                         ; $586E  end name/box tag
    db $24,$33,$2F,$3E             ; $586F  あたしは
    db $90                         ; $5873  　(space)
    db $6A,$7A,$64,$8D,$29,$55,$37,$25,$2F; $5874  タマコ゛かんていし = タマゴかんていし
    db $8F                         ; $587D  。
    db $EF,$EE                     ; $587E  newline
    db $90,$90                     ; $5880  　　(indent)
    db $38,$8D,$26,$32,$8D         ; $5882  と゛うそ゛ = どうぞ
    db $90                         ; $5887  　(space)
    db $4C                         ; $5888  よ
    db $9B                         ; $5889  ctrl $9B
    db $52                         ; $588A  ろ
    db $9B                         ; $588B  ctrl $9B
    db $2F                         ; $588C  し
    db $9B                         ; $588D  ctrl $9B
    db $2B                         ; $588E  く
    db $99                         ; $588F  ！
    db $FA                         ; $5890  wait-for-button
    db $F7                         ; $5891  clear page
    db $EF,$EE                     ; $5892  newline
    db $9F                         ; $5894  box tag
    db $96                         ; $5895  end name/box tag
    db $24,$33,$2F,$3D             ; $5896  あたしの
    db $90                         ; $589A  　(space)
    db $26,$34,$37,$8D,$3E         ; $589B  うちて゛は = うちでは
    db $90                         ; $58A0  　(space)
    db $24,$39,$33,$3D             ; $58A1  あなたの
    db $EF,$EE                     ; $58A5  newline
    db $90,$90                     ; $58A7  　　(indent)
    db $6A,$7A,$64,$8D,$54         ; $58A9  タマコ゛を = タマゴを
    db $90                         ; $58AE  　(space)
    db $96                         ; $58AF  end name/box tag
    db $29,$55,$37,$25             ; $58B0  かんてい
    db $97                         ; $58B4  ctrl $97
    db $2F,$37                     ; $58B5  して
    db $A4                         ; $58B7  、
    db $FA                         ; $58B8  wait-for-button
    db $F7                         ; $58B9  clear page
    db $EF,$EE                     ; $58BA  newline
    db $9F                         ; $58BC  box tag
    db $96                         ; $58BD  end name/box tag
    db $38,$8D,$55,$39             ; $58BE  と゛んな = どんな
    db $90                         ; $58C2  　(space)
    db $2D,$38,$8D,$47,$29,$8D     ; $58C3  こと゛もか゛ = こどもが
    db $90                         ; $58C9  　(space)
    db $26,$43,$51,$32,$26,$29,$54 ; $58CA  うまれそうかを
    db $EF,$EE                     ; $58D1  newline
    db $90,$90                     ; $58D3  　　(indent)
    db $26,$43,$51,$50,$43,$27,$3A ; $58D5  うまれるまえに
    db $90                         ; $58DC  　(space)
    db $28,$2F,$27,$34,$49,$26,$3D ; $58DD  おしえちゃうの
    db $99                         ; $58E4  ！
    db $FA                         ; $58E5  wait-for-button
    db $F7                         ; $58E6  clear page
    db $EF,$EE                     ; $58E7  newline
    db $9F                         ; $58E9  box tag
    db $96                         ; $58EA  end name/box tag
    db $47,$26,$3F,$38,$35,$3D     ; $58EB  もうひとつの
    db $90                         ; $58F1  　(space)
    db $53,$33,$2F,$3D,$2F,$2D,$8D,$38,$3E; $58F2  わたしのしこ゛とは = わたしのしごとは
    db $EF,$EE                     ; $58FB  newline
    db $90,$90                     ; $58FD  　　(indent)
    db $96                         ; $58FF  end name/box tag
    db $2F,$4B,$2B,$40,$2B         ; $5900  しゅくふく
    db $97                         ; $5905  ctrl $97
    db $4C                         ; $5906  よ
    db $8F                         ; $5907  。
    db $FA                         ; $5908  wait-for-button
    db $F7                         ; $5909  clear page
    db $EF,$EE                     ; $590A  newline
    db $9F                         ; $590C  box tag
    db $96                         ; $590D  end name/box tag
    db $2F,$4B,$2B,$40,$2B,$3E     ; $590E  しゅくふくは
    db $90                         ; $5914  　(space)
    db $43,$47,$3D,$3D,$31,$25,$41,$8D,$35,$54; $5915  まもののせいへ゛つを = まもののせいべつを
    db $EF,$EE                     ; $591F  newline
    db $90,$90                     ; $5921  　　(indent)
    db $29,$27,$34,$49,$26,$2D,$38,$39,$3D; $5923  かえちゃうことなの
    db $99                         ; $592C  ！
    db $FA                         ; $592D  wait-for-button
    db $F7                         ; $592E  clear page
    db $EF,$EE                     ; $592F  newline
    db $9F                         ; $5931  box tag
    db $96                         ; $5932  end name/box tag
    db $53,$29,$36,$33,$29,$2F,$4E ; $5933  わかったかしら
    db $98                         ; $593A  ？
    db $90                         ; $593B  　(space)
    db $32,$51,$2F,$8D,$49,$24     ; $593C  それし゛ゃあ = それじゃあ
    db $EF,$EE                     ; $5942  newline
    db $90,$90                     ; $5944  　　(indent)
    db $25,$43,$29,$4E             ; $5946  いまから
    db $90                         ; $594A  　(space)
    db $39                         ; $594B  な
    db $9B                         ; $594C  ctrl $9B
    db $3A                         ; $594D  に
    db $9B                         ; $594E  ctrl $9B
    db $30                         ; $594F  す
    db $9B                         ; $5950  ctrl $9B
    db $50                         ; $5951  る
    db $98                         ; $5952  ？
    db $F0                         ; $5953  end of message


; --------------------------------------------------------------------------
; Message #49 ($5954)
;   〈テリー〉は　ほんだなを　しらべた。
;   「まものの　せいべつ、
;   「おとこのこ　ばっかり
;   うまれてくるしゅぞくとか、
;   「おんなのこ　ばっかり　うまれてくる
;   しゅぞくとかが　あるのよね[94]！
;   「だから　しゅくふくって
;   お[9B]と[9B]く[9B]よ！
; --------------------------------------------------------------------------
Bank68_Msg49:                              ; $5954  (file $111954)
    db $F6                         ; $5954  «insert hero name»
    db $3E                         ; $5955  は
    db $90                         ; $5956  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $5957  ほんた゛なを = ほんだなを
    db $90                         ; $595D  　(space)
    db $2F,$4E,$41,$8D,$33         ; $595E  しらへ゛た = しらべた
    db $8F                         ; $5963  。
    db $EF,$EE                     ; $5964  newline
    db $FA                         ; $5966  wait-for-button
    db $F7                         ; $5967  clear page
    db $EF,$EE                     ; $5968  newline
    db $F3                         ; $596A  open text box
    db $96                         ; $596B  end name/box tag
    db $43,$47,$3D,$3D             ; $596C  まものの
    db $90                         ; $5970  　(space)
    db $31,$25,$41,$8D,$35         ; $5971  せいへ゛つ = せいべつ
    db $A4                         ; $5976  、
    db $EF,$EE                     ; $5977  newline
    db $FA                         ; $5979  wait-for-button
    db $F7                         ; $597A  clear page
    db $EF,$EE                     ; $597B  newline
    db $F3                         ; $597D  open text box
    db $96                         ; $597E  end name/box tag
    db $28,$38,$2D,$3D,$2D         ; $597F  おとこのこ
    db $90                         ; $5984  　(space)
    db $3E,$8D,$36,$29,$4F         ; $5985  は゛っかり = ばっかり
    db $EF,$EE                     ; $598A  newline
    db $90                         ; $598C  　(space)
    db $26,$43,$51,$37,$2B,$50,$2F,$4B,$32,$8D,$2B,$38,$29; $598D  うまれてくるしゅそ゛くとか = うまれてくるしゅぞくとか
    db $A4                         ; $599A  、
    db $FA                         ; $599B  wait-for-button
    db $F7                         ; $599C  clear page
    db $EF,$EE                     ; $599D  newline
    db $96                         ; $599F  end name/box tag
    db $28,$55,$39,$3D,$2D         ; $59A0  おんなのこ
    db $90                         ; $59A5  　(space)
    db $3E,$8D,$36,$29,$4F         ; $59A6  は゛っかり = ばっかり
    db $90                         ; $59AB  　(space)
    db $26,$43,$51,$37,$2B,$50     ; $59AC  うまれてくる
    db $EF,$EE                     ; $59B2  newline
    db $90                         ; $59B4  　(space)
    db $2F,$4B,$32,$8D,$2B,$38,$29,$29,$8D; $59B5  しゅそ゛くとかか゛ = しゅぞくとかが
    db $90                         ; $59BE  　(space)
    db $24,$50,$3D,$4C,$3C         ; $59BF  あるのよね
    db $94                         ; $59C4  small kana
    db $99                         ; $59C5  ！
    db $FA                         ; $59C6  wait-for-button
    db $F7                         ; $59C7  clear page
    db $EF,$EE                     ; $59C8  newline
    db $96                         ; $59CA  end name/box tag
    db $33,$8D,$29,$4E             ; $59CB  た゛から = だから
    db $90                         ; $59CF  　(space)
    db $2F,$4B,$2B,$40,$2B,$36,$37 ; $59D0  しゅくふくって
    db $EF,$EE                     ; $59D7  newline
    db $90                         ; $59D9  　(space)
    db $28                         ; $59DA  お
    db $9B                         ; $59DB  ctrl $9B
    db $38                         ; $59DC  と
    db $9B                         ; $59DD  ctrl $9B
    db $2B                         ; $59DE  く
    db $9B                         ; $59DF  ctrl $9B
    db $4C                         ; $59E0  よ
    db $99                         ; $59E1  ！
    db $F7                         ; $59E2  clear page
    db $F0                         ; $59E3  end of message


; --------------------------------------------------------------------------
; Message #50 ($59E4)
;   〈テリー〉は　ほんだなを　しらべた。
;   「せいちょうの　げんかい、
;   「しゅぞくによって　せいちょうの
;   げんかいになるレベルは　ちがうの。
;   「でも　げんかいにくるのを
;   おくらせることも　できるわ。
;   「はいごうを　たくさん　くりかえした
;   まものほど　おそくなっていくのよ！
; --------------------------------------------------------------------------
Bank68_Msg50:                              ; $59E4  (file $1119E4)
    db $F6                         ; $59E4  «insert hero name»
    db $3E                         ; $59E5  は
    db $90                         ; $59E6  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $59E7  ほんた゛なを = ほんだなを
    db $90                         ; $59ED  　(space)
    db $2F,$4E,$41,$8D,$33         ; $59EE  しらへ゛た = しらべた
    db $8F                         ; $59F3  。
    db $EF,$EE                     ; $59F4  newline
    db $FA                         ; $59F6  wait-for-button
    db $F7                         ; $59F7  clear page
    db $EF,$EE                     ; $59F8  newline
    db $F3                         ; $59FA  open text box
    db $96                         ; $59FB  end name/box tag
    db $31,$25,$34,$4D,$26,$3D     ; $59FC  せいちょうの
    db $90                         ; $5A02  　(space)
    db $2C,$8D,$55,$29,$25         ; $5A03  け゛んかい = げんかい
    db $A4                         ; $5A08  、
    db $EF,$EE                     ; $5A09  newline
    db $FA                         ; $5A0B  wait-for-button
    db $F7                         ; $5A0C  clear page
    db $EF,$EE                     ; $5A0D  newline
    db $F3                         ; $5A0F  open text box
    db $96                         ; $5A10  end name/box tag
    db $2F,$4B,$32,$8D,$2B,$3A,$4C,$36,$37; $5A11  しゅそ゛くによって = しゅぞくによって
    db $90                         ; $5A1A  　(space)
    db $31,$25,$34,$4D,$26,$3D     ; $5A1B  せいちょうの
    db $EF,$EE                     ; $5A21  newline
    db $90                         ; $5A23  　(space)
    db $2C,$8D,$55,$29,$25,$3A,$39,$50,$88,$78,$8D,$87,$3E; $5A24  け゛んかいになるレヘ゛ルは = げんかいになるレベルは
    db $90                         ; $5A31  　(space)
    db $34,$29,$8D,$26,$3D         ; $5A32  ちか゛うの = ちがうの
    db $8F                         ; $5A37  。
    db $FA                         ; $5A38  wait-for-button
    db $F7                         ; $5A39  clear page
    db $EF,$EE                     ; $5A3A  newline
    db $96                         ; $5A3C  end name/box tag
    db $37,$8D,$47                 ; $5A3D  て゛も = でも
    db $90                         ; $5A40  　(space)
    db $2C,$8D,$55,$29,$25,$3A,$2B,$50,$3D,$54; $5A41  け゛んかいにくるのを = げんかいにくるのを
    db $EF,$EE                     ; $5A4B  newline
    db $90                         ; $5A4D  　(space)
    db $28,$2B,$4E,$31,$50,$2D,$38,$47; $5A4E  おくらせることも
    db $90                         ; $5A56  　(space)
    db $37,$8D,$2A,$50,$53         ; $5A57  て゛きるわ = できるわ
    db $8F                         ; $5A5C  。
    db $FA                         ; $5A5D  wait-for-button
    db $F7                         ; $5A5E  clear page
    db $EF,$EE                     ; $5A5F  newline
    db $96                         ; $5A61  end name/box tag
    db $3E,$25,$2D,$8D,$26,$54     ; $5A62  はいこ゛うを = はいごうを
    db $90                         ; $5A68  　(space)
    db $33,$2B,$2E,$55             ; $5A69  たくさん
    db $90                         ; $5A6D  　(space)
    db $2B,$4F,$29,$27,$2F,$33     ; $5A6E  くりかえした
    db $EF,$EE                     ; $5A74  newline
    db $90                         ; $5A76  　(space)
    db $43,$47,$3D,$42,$38,$8D     ; $5A77  まものほと゛ = まものほど
    db $90                         ; $5A7D  　(space)
    db $28,$32,$2B,$39,$36,$37,$25,$2B,$3D,$4C; $5A7E  おそくなっていくのよ
    db $99                         ; $5A88  ！
    db $F7                         ; $5A89  clear page
    db $F0                         ; $5A8A  end of message


; --------------------------------------------------------------------------
; Message #51 ($5A8B)
;   〈テリー〉は　ほんだなを　しらべた。
;   「まものの　おぼえる　とくぎ、
;   「おやが　おぼえている　とくぎを
;   こどもも　おぼえてくれるの。
;   「だから　おぼえさせたい
;   とくぎを　もつ　おやをえらんで、
;   「その　つよいほうを
;   けっとうに　こどもをつくる、。
;   「これが　はいごうの　ひけつね。
; --------------------------------------------------------------------------
Bank68_Msg51:                              ; $5A8B  (file $111A8B)
    db $F6                         ; $5A8B  «insert hero name»
    db $3E                         ; $5A8C  は
    db $90                         ; $5A8D  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $5A8E  ほんた゛なを = ほんだなを
    db $90                         ; $5A94  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5A95  しらへ゛た = しらべた
    db $8F                         ; $5A9A  。
    db $EF,$EE                     ; $5A9B  newline
    db $FA                         ; $5A9D  wait-for-button
    db $F7                         ; $5A9E  clear page
    db $EF,$EE                     ; $5A9F  newline
    db $F3                         ; $5AA1  open text box
    db $96                         ; $5AA2  end name/box tag
    db $43,$47,$3D,$3D             ; $5AA3  まものの
    db $90                         ; $5AA7  　(space)
    db $28,$42,$8D,$27,$50         ; $5AA8  おほ゛える = おぼえる
    db $90                         ; $5AAD  　(space)
    db $38,$2B,$2A,$8D             ; $5AAE  とくき゛ = とくぎ
    db $A4                         ; $5AB2  、
    db $EF,$EE                     ; $5AB3  newline
    db $FA                         ; $5AB5  wait-for-button
    db $F7                         ; $5AB6  clear page
    db $EF,$EE                     ; $5AB7  newline
    db $F3                         ; $5AB9  open text box
    db $96                         ; $5ABA  end name/box tag
    db $28,$48,$29,$8D             ; $5ABB  おやか゛ = おやが
    db $90                         ; $5ABF  　(space)
    db $28,$42,$8D,$27,$37,$25,$50 ; $5AC0  おほ゛えている = おぼえている
    db $90                         ; $5AC7  　(space)
    db $38,$2B,$2A,$8D,$54         ; $5AC8  とくき゛を = とくぎを
    db $EF,$EE                     ; $5ACD  newline
    db $90                         ; $5ACF  　(space)
    db $2D,$38,$8D,$47,$47         ; $5AD0  こと゛もも = こどもも
    db $90                         ; $5AD5  　(space)
    db $28,$42,$8D,$27,$37,$2B,$51,$50,$3D; $5AD6  おほ゛えてくれるの = おぼえてくれるの
    db $8F                         ; $5ADF  。
    db $FA                         ; $5AE0  wait-for-button
    db $F7                         ; $5AE1  clear page
    db $EF,$EE                     ; $5AE2  newline
    db $96                         ; $5AE4  end name/box tag
    db $33,$8D,$29,$4E             ; $5AE5  た゛から = だから
    db $90                         ; $5AE9  　(space)
    db $28,$42,$8D,$27,$2E,$31,$33,$25; $5AEA  おほ゛えさせたい = おぼえさせたい
    db $EF,$EE                     ; $5AF2  newline
    db $90                         ; $5AF4  　(space)
    db $38,$2B,$2A,$8D,$54         ; $5AF5  とくき゛を = とくぎを
    db $90                         ; $5AFA  　(space)
    db $47,$35                     ; $5AFB  もつ
    db $90                         ; $5AFD  　(space)
    db $28,$48,$54,$27,$4E,$55,$37,$8D; $5AFE  おやをえらんて゛ = おやをえらんで
    db $A4                         ; $5B06  、
    db $FA                         ; $5B07  wait-for-button
    db $F7                         ; $5B08  clear page
    db $EF,$EE                     ; $5B09  newline
    db $96                         ; $5B0B  end name/box tag
    db $32,$3D                     ; $5B0C  その
    db $90                         ; $5B0E  　(space)
    db $35,$4C,$25,$42,$26,$54     ; $5B0F  つよいほうを
    db $EF,$EE                     ; $5B15  newline
    db $90                         ; $5B17  　(space)
    db $2C,$36,$38,$26,$3A         ; $5B18  けっとうに
    db $90                         ; $5B1D  　(space)
    db $2D,$38,$8D,$47,$54,$35,$2B,$50; $5B1E  こと゛もをつくる = こどもをつくる
    db $A4                         ; $5B26  、
    db $8F                         ; $5B27  。
    db $FA                         ; $5B28  wait-for-button
    db $F7                         ; $5B29  clear page
    db $EF,$EE                     ; $5B2A  newline
    db $96                         ; $5B2C  end name/box tag
    db $2D,$51,$29,$8D             ; $5B2D  これか゛ = これが
    db $90                         ; $5B31  　(space)
    db $3E,$25,$2D,$8D,$26,$3D     ; $5B32  はいこ゛うの = はいごうの
    db $90                         ; $5B38  　(space)
    db $3F,$2C,$35,$3C             ; $5B39  ひけつね
    db $8F                         ; $5B3D  。
    db $EF,$EE                     ; $5B3E  newline
    db $F7                         ; $5B40  clear page
    db $F0                         ; $5B41  end of message


; --------------------------------------------------------------------------
; Message #52 ($5B42)
;   「きみ。　わたしの　むすめを
;   しっているかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg52:                              ; $5B42  (file $111B42)
    db $EA                         ; $5B42  ▶ new page
    db $9F                         ; $5B43  box tag
    db $96                         ; $5B44  end name/box tag
    db $2A,$44                     ; $5B45  きみ
    db $8F                         ; $5B47  。
    db $90                         ; $5B48  　(space)
    db $53,$33,$2F,$3D             ; $5B49  わたしの
    db $90                         ; $5B4D  　(space)
    db $45,$30,$46,$54             ; $5B4E  むすめを
    db $EF,$EE                     ; $5B52  newline
    db $90,$90                     ; $5B54  　　(indent)
    db $2F,$36,$37,$25,$50,$29,$3C ; $5B56  しっているかね
    db $98                         ; $5B5D  ？
    db $FF                         ; $5B5E  はい/いいえ
    db $F0                         ; $5B5F  end of message


; --------------------------------------------------------------------------
; Message #53 ($5B60)
;   「しらない！？　あんなにかわいくて
;   やさしくて　おしとやかなこを！？
;   「そとで　あそんでいるはずだ。
;   ちゃんとそのめで　みてきなさい。
; --------------------------------------------------------------------------
Bank68_Msg53:                              ; $5B60  (file $111B60)
    db $EA                         ; $5B60  ▶ new page
    db $9F                         ; $5B61  box tag
    db $96                         ; $5B62  end name/box tag
    db $2F,$4E,$39,$25             ; $5B63  しらない
    db $99                         ; $5B67  ！
    db $98                         ; $5B68  ？
    db $90                         ; $5B69  　(space)
    db $24,$55,$39,$3A,$29,$53,$25,$2B,$37; $5B6A  あんなにかわいくて
    db $EF,$EE                     ; $5B73  newline
    db $90,$90                     ; $5B75  　　(indent)
    db $48,$2E,$2F,$2B,$37         ; $5B77  やさしくて
    db $90                         ; $5B7C  　(space)
    db $28,$2F,$38,$48,$29,$39,$2D,$54; $5B7D  おしとやかなこを
    db $99                         ; $5B85  ！
    db $98                         ; $5B86  ？
    db $FA                         ; $5B87  wait-for-button
    db $F7                         ; $5B88  clear page
    db $EF,$EE                     ; $5B89  newline
    db $9F                         ; $5B8B  box tag
    db $96                         ; $5B8C  end name/box tag
    db $32,$38,$37,$8D             ; $5B8D  そとて゛ = そとで
    db $90                         ; $5B91  　(space)
    db $24,$32,$55,$37,$8D,$25,$50,$3E,$30,$8D,$33,$8D; $5B92  あそんて゛いるはす゛た゛ = あそんでいるはずだ
    db $8F                         ; $5B9E  。
    db $EF,$EE                     ; $5B9F  newline
    db $90,$90                     ; $5BA1  　　(indent)
    db $34,$49,$55,$38,$32,$3D,$46,$37,$8D; $5BA3  ちゃんとそのめて゛ = ちゃんとそのめで
    db $90                         ; $5BAC  　(space)
    db $44,$37,$2A,$39,$2E,$25     ; $5BAD  みてきなさい
    db $8F                         ; $5BB3  。
    db $F7                         ; $5BB4  clear page
    db $F0                         ; $5BB5  end of message


; --------------------------------------------------------------------------
; Message #54 ($5BB6)
;   「そうか。　かわいいだろう？
;   タィジャいち　おしとやかなんだ。
; --------------------------------------------------------------------------
Bank68_Msg54:                              ; $5BB6  (file $111BB6)
    db $EA                         ; $5BB6  ▶ new page
    db $9F                         ; $5BB7  box tag
    db $96                         ; $5BB8  end name/box tag
    db $32,$26,$29                 ; $5BB9  そうか
    db $8F                         ; $5BBC  。
    db $90                         ; $5BBD  　(space)
    db $29,$53,$25,$25,$33,$8D,$52,$26; $5BBE  かわいいた゛ろう = かわいいだろう
    db $98                         ; $5BC6  ？
    db $EF,$EE                     ; $5BC7  newline
    db $90,$90                     ; $5BC9  　　(indent)
    db $6A,$58,$66,$8D,$82,$25,$34 ; $5BCB  タィシ゛ャいち = タィジャいち
    db $90                         ; $5BD2  　(space)
    db $28,$2F,$38,$48,$29,$39,$55,$33,$8D; $5BD3  おしとやかなんた゛ = おしとやかなんだ
    db $8F                         ; $5BDC  。
    db $F7                         ; $5BDD  clear page
    db $F0                         ; $5BDE  end of message


; --------------------------------------------------------------------------
; Message #55 ($5BDF)
;   「おとなりのひとは　なにを
;   しているひとなの？！
;   「おとこなの？　おんななの？
;   それとも、、。
; --------------------------------------------------------------------------
Bank68_Msg55:                              ; $5BDF  (file $111BDF)
    db $EB                         ; $5BDF  ▶ new page
    db $9F                         ; $5BE0  box tag
    db $96                         ; $5BE1  end name/box tag
    db $28,$38,$39,$4F,$3D,$3F,$38,$3E; $5BE2  おとなりのひとは
    db $90                         ; $5BEA  　(space)
    db $39,$3A,$54                 ; $5BEB  なにを
    db $EF,$EE                     ; $5BEE  newline
    db $90,$90                     ; $5BF0  　　(indent)
    db $2F,$37,$25,$50,$3F,$38,$39,$3D; $5BF2  しているひとなの
    db $98                         ; $5BFA  ？
    db $99                         ; $5BFB  ！
    db $FA                         ; $5BFC  wait-for-button
    db $F7                         ; $5BFD  clear page
    db $EF,$EE                     ; $5BFE  newline
    db $9F                         ; $5C00  box tag
    db $96                         ; $5C01  end name/box tag
    db $28,$38,$2D,$39,$3D         ; $5C02  おとこなの
    db $98                         ; $5C07  ？
    db $90                         ; $5C08  　(space)
    db $28,$55,$39,$39,$3D         ; $5C09  おんななの
    db $98                         ; $5C0E  ？
    db $EF,$EE                     ; $5C0F  newline
    db $90,$90                     ; $5C11  　　(indent)
    db $32,$51,$38,$47             ; $5C13  それとも
    db $A4                         ; $5C17  、
    db $A4                         ; $5C18  、
    db $8F                         ; $5C19  。
    db $F7                         ; $5C1A  clear page
    db $F0                         ; $5C1B  end of message


; --------------------------------------------------------------------------
; Message #56 ($5C1C)
;   「ここにある　たびのとびらは
;   だれにも　わたさぬぞ！！
;   「この　がんこじいさんの
;   がんこさを　おもいしれ！
; --------------------------------------------------------------------------
Bank68_Msg56:                              ; $5C1C  (file $111C1C)
    db $EA                         ; $5C1C  ▶ new page
    db $9F                         ; $5C1D  box tag
    db $96                         ; $5C1E  end name/box tag
    db $2D,$2D,$3A,$24,$50         ; $5C1F  ここにある
    db $90                         ; $5C24  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3E; $5C25  たひ゛のとひ゛らは = たびのとびらは
    db $EF,$EE                     ; $5C2E  newline
    db $90,$90                     ; $5C30  　　(indent)
    db $33,$8D,$51,$3A,$47         ; $5C32  た゛れにも = だれにも
    db $90                         ; $5C37  　(space)
    db $53,$33,$2E,$3B,$32,$8D     ; $5C38  わたさぬそ゛ = わたさぬぞ
    db $99                         ; $5C3E  ！
    db $99                         ; $5C3F  ！
    db $FA                         ; $5C40  wait-for-button
    db $F7                         ; $5C41  clear page
    db $EF,$EE                     ; $5C42  newline
    db $9F                         ; $5C44  box tag
    db $96                         ; $5C45  end name/box tag
    db $2D,$3D                     ; $5C46  この
    db $90                         ; $5C48  　(space)
    db $29,$8D,$55,$2D,$2F,$8D,$25,$2E,$55,$3D; $5C49  か゛んこし゛いさんの = がんこじいさんの
    db $EF,$EE                     ; $5C53  newline
    db $90,$90                     ; $5C55  　　(indent)
    db $29,$8D,$55,$2D,$2E,$54     ; $5C57  か゛んこさを = がんこさを
    db $90                         ; $5C5D  　(space)
    db $28,$47,$25,$2F,$51         ; $5C5E  おもいしれ
    db $99                         ; $5C63  ！
    db $F7                         ; $5C64  clear page
    db $F0                         ; $5C65  end of message


; --------------------------------------------------------------------------
; Message #57 ($5C66)
;   [E9]カ〈テリー〉は　タンスの
;   なかを　しらべた。
; --------------------------------------------------------------------------
Bank68_Msg57:                              ; $5C66  (file $111C66)
    db $E9                         ; $5C66  ctrl $E9
    db $60                         ; $5C67  カ
    db $F6                         ; $5C68  «insert hero name»
    db $3E                         ; $5C69  は
    db $90                         ; $5C6A  　(space)
    db $6A,$8C,$67,$3D             ; $5C6B  タンスの
    db $EF,$EE                     ; $5C6F  newline
    db $39,$29,$54                 ; $5C71  なかを
    db $90                         ; $5C74  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5C75  しらへ゛た = しらべた
    db $8F                         ; $5C7A  。
    db $FA                         ; $5C7B  wait-for-button
    db $F7                         ; $5C7C  clear page
    db $F0                         ; $5C7D  end of message


; --------------------------------------------------------------------------
; Message #58 ($5C7E)
;   なんと　ちいさなメダルを　みつけた！
;   しかし　もちものが　いっぱいだ。
;   〈テリー〉は　ちいさなメダルを
;   タンスに　もどした。
; --------------------------------------------------------------------------
Bank68_Msg58:                              ; $5C7E  (file $111C7E)
    db $39,$55,$38                 ; $5C7E  なんと
    db $90                         ; $5C81  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5C82  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $5C8B  　(space)
    db $44,$35,$2C,$33             ; $5C8C  みつけた
    db $99                         ; $5C90  ！
    db $EF,$EE                     ; $5C91  newline
    db $2F,$29,$2F                 ; $5C93  しかし
    db $90                         ; $5C96  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $5C97  もちものか゛ = もちものが
    db $90                         ; $5C9D  　(space)
    db $25,$36,$3E,$8E,$25,$33,$8D ; $5C9E  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $5CA5  。
    db $FA                         ; $5CA6  wait-for-button
    db $F7                         ; $5CA7  clear page
    db $EF,$EE                     ; $5CA8  newline
    db $F6                         ; $5CAA  «insert hero name»
    db $3E                         ; $5CAB  は
    db $90                         ; $5CAC  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5CAD  ちいさなメタ゛ルを = ちいさなメダルを
    db $EF,$EE                     ; $5CB6  newline
    db $6A,$8C,$67,$3A             ; $5CB8  タンスに
    db $90                         ; $5CBC  　(space)
    db $47,$38,$8D,$2F,$33         ; $5CBD  もと゛した = もどした
    db $8F                         ; $5CC2  。
    db $F7                         ; $5CC3  clear page
    db $F0                         ; $5CC4  end of message


; --------------------------------------------------------------------------
; Message #59 ($5CC5)
;   タンスのなかは　おんなのこの
;   いしょうで　いっぱいだ。
; --------------------------------------------------------------------------
Bank68_Msg59:                              ; $5CC5  (file $111CC5)
    db $6A,$8C,$67,$3D,$39,$29,$3E ; $5CC5  タンスのなかは
    db $90                         ; $5CCC  　(space)
    db $28,$55,$39,$3D,$2D,$3D     ; $5CCD  おんなのこの
    db $EF,$EE                     ; $5CD3  newline
    db $25,$2F,$4D,$26,$37,$8D     ; $5CD5  いしょうて゛ = いしょうで
    db $90                         ; $5CDB  　(space)
    db $25,$36,$3E,$8E,$25,$33,$8D ; $5CDC  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $5CE3  。
    db $F7                         ; $5CE4  clear page
    db $F0                         ; $5CE5  end of message


; --------------------------------------------------------------------------
; Message #60 ($5CE6)
;   〈テリー〉は　ほんだなを　しらべた。
;   「わがこの　せいちょう　にっき、
;   その[01]
;   「こどもが　うまれた。
;   おんなのこだった。
;   「かっ　かわいい！！　こどもは
;   おやに　にるものだな[91]！　つづく。
; --------------------------------------------------------------------------
Bank68_Msg60:                              ; $5CE6  (file $111CE6)
    db $F6                         ; $5CE6  «insert hero name»
    db $3E                         ; $5CE7  は
    db $90                         ; $5CE8  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $5CE9  ほんた゛なを = ほんだなを
    db $90                         ; $5CEF  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5CF0  しらへ゛た = しらべた
    db $8F                         ; $5CF5  。
    db $EF,$EE                     ; $5CF6  newline
    db $FA                         ; $5CF8  wait-for-button
    db $F7                         ; $5CF9  clear page
    db $EF,$EE                     ; $5CFA  newline
    db $F3                         ; $5CFC  open text box
    db $96                         ; $5CFD  end name/box tag
    db $53,$29,$8D,$2D,$3D         ; $5CFE  わか゛この = わがこの
    db $90                         ; $5D03  　(space)
    db $31,$25,$34,$4D,$26         ; $5D04  せいちょう
    db $90                         ; $5D09  　(space)
    db $3A,$36,$2A                 ; $5D0A  にっき
    db $A4                         ; $5D0D  、
    db $EF,$EE                     ; $5D0E  newline
    db $90                         ; $5D10  　(space)
    db $32,$3D                     ; $5D11  その
    db $01                         ; $5D13  ctrl $01
    db $FA                         ; $5D14  wait-for-button
    db $F7                         ; $5D15  clear page
    db $EF,$EE                     ; $5D16  newline
    db $96                         ; $5D18  end name/box tag
    db $2D,$38,$8D,$47,$29,$8D     ; $5D19  こと゛もか゛ = こどもが
    db $90                         ; $5D1F  　(space)
    db $26,$43,$51,$33             ; $5D20  うまれた
    db $8F                         ; $5D24  。
    db $EF,$EE                     ; $5D25  newline
    db $90                         ; $5D27  　(space)
    db $28,$55,$39,$3D,$2D,$33,$8D,$36,$33; $5D28  おんなのこた゛った = おんなのこだった
    db $8F                         ; $5D31  。
    db $FA                         ; $5D32  wait-for-button
    db $F7                         ; $5D33  clear page
    db $EF,$EE                     ; $5D34  newline
    db $96                         ; $5D36  end name/box tag
    db $29,$36                     ; $5D37  かっ
    db $90                         ; $5D39  　(space)
    db $29,$53,$25,$25             ; $5D3A  かわいい
    db $99                         ; $5D3E  ！
    db $99                         ; $5D3F  ！
    db $90                         ; $5D40  　(space)
    db $2D,$38,$8D,$47,$3E         ; $5D41  こと゛もは = こどもは
    db $EF,$EE                     ; $5D46  newline
    db $90                         ; $5D48  　(space)
    db $28,$48,$3A                 ; $5D49  おやに
    db $90                         ; $5D4C  　(space)
    db $3A,$50,$47,$3D,$33,$8D,$39 ; $5D4D  にるものた゛な = にるものだな
    db $91                         ; $5D54  ctrl $91
    db $99                         ; $5D55  ！
    db $90                         ; $5D56  　(space)
    db $35,$35,$8D,$2B             ; $5D57  つつ゛く = つづく
    db $8F                         ; $5D5B  。
    db $F7                         ; $5D5C  clear page
    db $F0                         ; $5D5D  end of message


; --------------------------------------------------------------------------
; Message #61 ($5D5E)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   ちいさな　おとこのこが　こちらを
;   みかえしている！
;   しかしそれは　みずにうつった
;   〈テリー〉の　すがただった、、。
; --------------------------------------------------------------------------
Bank68_Msg61:                              ; $5D5E  (file $111D5E)
    db $F6                         ; $5D5E  «insert hero name»
    db $3E                         ; $5D5F  は
    db $90                         ; $5D60  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $5D61  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $5D68  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $5D6A  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $5D72  。
    db $FA                         ; $5D73  wait-for-button
    db $F7                         ; $5D74  clear page
    db $EF,$EE                     ; $5D75  newline
    db $34,$25,$2E,$39             ; $5D77  ちいさな
    db $90                         ; $5D7B  　(space)
    db $28,$38,$2D,$3D,$2D,$29,$8D ; $5D7C  おとこのこか゛ = おとこのこが
    db $90                         ; $5D83  　(space)
    db $2D,$34,$4E,$54             ; $5D84  こちらを
    db $EF,$EE                     ; $5D88  newline
    db $44,$29,$27,$2F,$37,$25,$50 ; $5D8A  みかえしている
    db $99                         ; $5D91  ！
    db $FA                         ; $5D92  wait-for-button
    db $F7                         ; $5D93  clear page
    db $EF,$EE                     ; $5D94  newline
    db $2F,$29,$2F,$32,$51,$3E     ; $5D96  しかしそれは
    db $90                         ; $5D9C  　(space)
    db $44,$30,$8D,$3A,$26,$35,$36,$33; $5D9D  みす゛にうつった = みずにうつった
    db $EF,$EE                     ; $5DA5  newline
    db $F6                         ; $5DA7  «insert hero name»
    db $3D                         ; $5DA8  の
    db $90                         ; $5DA9  　(space)
    db $30,$29,$8D,$33,$33,$8D,$36,$33; $5DAA  すか゛たた゛った = すがただった
    db $A4                         ; $5DB2  、
    db $A4                         ; $5DB3  、
    db $8F                         ; $5DB4  。
    db $F7                         ; $5DB5  clear page
    db $F0                         ; $5DB6  end of message


; --------------------------------------------------------------------------
; Message #62 ($5DB7)
;   「でていけ！　おいらの　べテイは
;   だれにも　わたさないぞ！
;   「ああ　おいらの　ベテイ！！
; --------------------------------------------------------------------------
Bank68_Msg62:                              ; $5DB7  (file $111DB7)
    db $EA                         ; $5DB7  ▶ new page
    db $9F                         ; $5DB8  box tag
    db $96                         ; $5DB9  end name/box tag
    db $37,$8D,$37,$25,$2C         ; $5DBA  て゛ていけ = でていけ
    db $99                         ; $5DBF  ！
    db $90                         ; $5DC0  　(space)
    db $28,$25,$4E,$3D             ; $5DC1  おいらの
    db $90                         ; $5DC5  　(space)
    db $41,$8D,$6E,$59,$3E         ; $5DC6  へ゛テイは = べテイは
    db $EF,$EE                     ; $5DCB  newline
    db $90,$90                     ; $5DCD  　　(indent)
    db $33,$8D,$51,$3A,$47         ; $5DCF  た゛れにも = だれにも
    db $90                         ; $5DD4  　(space)
    db $53,$33,$2E,$39,$25,$32,$8D ; $5DD5  わたさないそ゛ = わたさないぞ
    db $99                         ; $5DDC  ！
    db $FA                         ; $5DDD  wait-for-button
    db $F7                         ; $5DDE  clear page
    db $EF,$EE                     ; $5DDF  newline
    db $9F                         ; $5DE1  box tag
    db $96                         ; $5DE2  end name/box tag
    db $24,$24                     ; $5DE3  ああ
    db $90                         ; $5DE5  　(space)
    db $28,$25,$4E,$3D             ; $5DE6  おいらの
    db $90                         ; $5DEA  　(space)
    db $78,$8D,$6E,$59             ; $5DEB  ヘ゛テイ = ベテイ
    db $99                         ; $5DEF  ！
    db $99                         ; $5DF0  ！
    db $EF,$EE                     ; $5DF1  newline
    db $F7                         ; $5DF3  clear page
    db $F0                         ; $5DF4  end of message


; --------------------------------------------------------------------------
; Message #63 ($5DF5)
;   「ああ　きみか。　ひとは　みかけに
;   よらないな。　、つよかったよ！
;   「ところで　わたしは　まものの
;   けんきゅうを　しておる。
;   「それだけでなく　このタィジャに
;   ついても　けんきゅうしている。
;   「おもしろいはなしを　きかせるから
;   また　あそびに　きてくれたまえ。
; --------------------------------------------------------------------------
Bank68_Msg63:                              ; $5DF5  (file $111DF5)
    db $EA                         ; $5DF5  ▶ new page
    db $9F                         ; $5DF6  box tag
    db $96                         ; $5DF7  end name/box tag
    db $24,$24                     ; $5DF8  ああ
    db $90                         ; $5DFA  　(space)
    db $2A,$44,$29                 ; $5DFB  きみか
    db $8F                         ; $5DFE  。
    db $90                         ; $5DFF  　(space)
    db $3F,$38,$3E                 ; $5E00  ひとは
    db $90                         ; $5E03  　(space)
    db $44,$29,$2C,$3A             ; $5E04  みかけに
    db $EF,$EE                     ; $5E08  newline
    db $90,$90                     ; $5E0A  　　(indent)
    db $4C,$4E,$39,$25,$39         ; $5E0C  よらないな
    db $8F                         ; $5E11  。
    db $90                         ; $5E12  　(space)
    db $A4                         ; $5E13  、
    db $35,$4C,$29,$36,$33,$4C     ; $5E14  つよかったよ
    db $99                         ; $5E1A  ！
    db $FA                         ; $5E1B  wait-for-button
    db $F7                         ; $5E1C  clear page
    db $EF,$EE                     ; $5E1D  newline
    db $9F                         ; $5E1F  box tag
    db $96                         ; $5E20  end name/box tag
    db $38,$2D,$52,$37,$8D         ; $5E21  ところて゛ = ところで
    db $90                         ; $5E26  　(space)
    db $53,$33,$2F,$3E             ; $5E27  わたしは
    db $90                         ; $5E2B  　(space)
    db $43,$47,$3D,$3D             ; $5E2C  まものの
    db $EF,$EE                     ; $5E30  newline
    db $90,$90                     ; $5E32  　　(indent)
    db $2C,$55,$2A,$4B,$26,$54     ; $5E34  けんきゅうを
    db $90                         ; $5E3A  　(space)
    db $2F,$37,$28,$50             ; $5E3B  しておる
    db $8F                         ; $5E3F  。
    db $FA                         ; $5E40  wait-for-button
    db $F7                         ; $5E41  clear page
    db $EF,$EE                     ; $5E42  newline
    db $9F                         ; $5E44  box tag
    db $96                         ; $5E45  end name/box tag
    db $32,$51,$33,$8D,$2C,$37,$8D,$39,$2B; $5E46  それた゛けて゛なく = それだけでなく
    db $90                         ; $5E4F  　(space)
    db $2D,$3D,$6A,$58,$66,$8D,$82,$3A; $5E50  このタィシ゛ャに = このタィジャに
    db $EF,$EE                     ; $5E58  newline
    db $90,$90                     ; $5E5A  　　(indent)
    db $35,$25,$37,$47             ; $5E5C  ついても
    db $90                         ; $5E60  　(space)
    db $2C,$55,$2A,$4B,$26,$2F,$37,$25,$50; $5E61  けんきゅうしている
    db $8F                         ; $5E6A  。
    db $FA                         ; $5E6B  wait-for-button
    db $F7                         ; $5E6C  clear page
    db $EF,$EE                     ; $5E6D  newline
    db $9F                         ; $5E6F  box tag
    db $96                         ; $5E70  end name/box tag
    db $28,$47,$2F,$52,$25,$3E,$39,$2F,$54; $5E71  おもしろいはなしを
    db $90                         ; $5E7A  　(space)
    db $2A,$29,$31,$50,$29,$4E     ; $5E7B  きかせるから
    db $EF,$EE                     ; $5E81  newline
    db $90,$90                     ; $5E83  　　(indent)
    db $43,$33                     ; $5E85  また
    db $90                         ; $5E87  　(space)
    db $24,$32,$3F,$8D,$3A         ; $5E88  あそひ゛に = あそびに
    db $90                         ; $5E8D  　(space)
    db $2A,$37,$2B,$51,$33,$43,$27 ; $5E8E  きてくれたまえ
    db $8F                         ; $5E95  。
    db $F7                         ; $5E96  clear page
    db $F0                         ; $5E97  end of message


; --------------------------------------------------------------------------
; Message #64 ($5E98)
;   「うちのせんせいは　てんさいじゃ。
;   しかも　おとこまえときておる。
;   「ありがたい　はなしが　ききたくば
;   また　ここにくるがよいぞ！
; --------------------------------------------------------------------------
Bank68_Msg64:                              ; $5E98  (file $111E98)
    db $EB                         ; $5E98  ▶ new page
    db $9F                         ; $5E99  box tag
    db $96                         ; $5E9A  end name/box tag
    db $26,$34,$3D,$31,$55,$31,$25,$3E; $5E9B  うちのせんせいは
    db $90                         ; $5EA3  　(space)
    db $37,$55,$2E,$25,$2F,$8D,$49 ; $5EA4  てんさいし゛ゃ = てんさいじゃ
    db $8F                         ; $5EAB  。
    db $EF,$EE                     ; $5EAC  newline
    db $90,$90                     ; $5EAE  　　(indent)
    db $2F,$29,$47                 ; $5EB0  しかも
    db $90                         ; $5EB3  　(space)
    db $28,$38,$2D,$43,$27,$38,$2A,$37,$28,$50; $5EB4  おとこまえときておる
    db $8F                         ; $5EBE  。
    db $FA                         ; $5EBF  wait-for-button
    db $F7                         ; $5EC0  clear page
    db $EF,$EE                     ; $5EC1  newline
    db $9F                         ; $5EC3  box tag
    db $96                         ; $5EC4  end name/box tag
    db $24,$4F,$29,$8D,$33,$25     ; $5EC5  ありか゛たい = ありがたい
    db $90                         ; $5ECB  　(space)
    db $3E,$39,$2F,$29,$8D         ; $5ECC  はなしか゛ = はなしが
    db $90                         ; $5ED1  　(space)
    db $2A,$2A,$33,$2B,$3E,$8D     ; $5ED2  ききたくは゛ = ききたくば
    db $EF,$EE                     ; $5ED8  newline
    db $90,$90                     ; $5EDA  　　(indent)
    db $43,$33                     ; $5EDC  また
    db $90                         ; $5EDE  　(space)
    db $2D,$2D,$3A,$2B,$50,$29,$8D,$4C,$25,$32,$8D; $5EDF  ここにくるか゛よいそ゛ = ここにくるがよいぞ
    db $99                         ; $5EEA  ！
    db $F7                         ; $5EEB  clear page
    db $F0                         ; $5EEC  end of message


; --------------------------------------------------------------------------
; Message #65 ($5EED)
;   「マスターようせいじゅくへ
;   ようこそ！
;   「きょうの　こうぎは　まものの
;   とくちょうについて。　きくかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg65:                              ; $5EED  (file $111EED)
    db $EA                         ; $5EED  ▶ new page
    db $9F                         ; $5EEE  box tag
    db $96                         ; $5EEF  end name/box tag
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25,$2F,$8D,$4B,$2B,$41; $5EF0  マスターようせいし゛ゅくへ = マスターようせいじゅくへ
    db $EF,$EE                     ; $5EFD  newline
    db $90,$90                     ; $5EFF  　　(indent)
    db $4C,$26,$2D,$32             ; $5F01  ようこそ
    db $99                         ; $5F05  ！
    db $FA                         ; $5F06  wait-for-button
    db $F7                         ; $5F07  clear page
    db $EF,$EE                     ; $5F08  newline
    db $9F                         ; $5F0A  box tag
    db $96                         ; $5F0B  end name/box tag
    db $2A,$4D,$26,$3D             ; $5F0C  きょうの
    db $90                         ; $5F10  　(space)
    db $2D,$26,$2A,$8D,$3E         ; $5F11  こうき゛は = こうぎは
    db $90                         ; $5F16  　(space)
    db $43,$47,$3D,$3D             ; $5F17  まものの
    db $EF,$EE                     ; $5F1B  newline
    db $90,$90                     ; $5F1D  　　(indent)
    db $38,$2B,$34,$4D,$26,$3A,$35,$25,$37; $5F1F  とくちょうについて
    db $8F                         ; $5F28  。
    db $90                         ; $5F29  　(space)
    db $2A,$2B,$29,$3C             ; $5F2A  きくかね
    db $98                         ; $5F2E  ？
    db $FF                         ; $5F2F  はい/いいえ
    db $F0                         ; $5F30  end of message


; --------------------------------------------------------------------------
; Message #66 ($5F31)
;   「まものの　つかまえかたを
;   ノートに　うつしたよ。　みたい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg66:                              ; $5F31  (file $111F31)
    db $EB                         ; $5F31  ▶ new page
    db $9F                         ; $5F32  box tag
    db $96                         ; $5F33  end name/box tag
    db $43,$47,$3D,$3D             ; $5F34  まものの
    db $90                         ; $5F38  　(space)
    db $35,$29,$43,$27,$29,$33,$54 ; $5F39  つかまえかたを
    db $EF,$EE                     ; $5F40  newline
    db $90,$90                     ; $5F42  　　(indent)
    db $74,$9C,$6F,$3A             ; $5F44  ノートに
    db $90                         ; $5F48  　(space)
    db $26,$35,$2F,$33,$4C         ; $5F49  うつしたよ
    db $8F                         ; $5F4E  。
    db $90                         ; $5F4F  　(space)
    db $44,$33,$25                 ; $5F50  みたい
    db $98                         ; $5F53  ？
    db $FF                         ; $5F54  はい/いいえ
    db $F0                         ; $5F55  end of message


; --------------------------------------------------------------------------
; Message #67 ($5F56)
;   「みせて　ほしくなったら
;   いつでも　いってね！
; --------------------------------------------------------------------------
Bank68_Msg67:                              ; $5F56  (file $111F56)
    db $EB                         ; $5F56  ▶ new page
    db $9F                         ; $5F57  box tag
    db $96                         ; $5F58  end name/box tag
    db $44,$31,$37                 ; $5F59  みせて
    db $90                         ; $5F5C  　(space)
    db $42,$2F,$2B,$39,$36,$33,$4E ; $5F5D  ほしくなったら
    db $EF,$EE                     ; $5F64  newline
    db $90,$90                     ; $5F66  　　(indent)
    db $25,$35,$37,$8D,$47         ; $5F68  いつて゛も = いつでも
    db $90                         ; $5F6D  　(space)
    db $25,$36,$37,$3C             ; $5F6E  いってね
    db $99                         ; $5F72  ！
    db $F7                         ; $5F73  clear page
    db $F0                         ; $5F74  end of message


; --------------------------------------------------------------------------
; Message #68 ($5F75)
;   〈テリー〉は　ノートを　ひらいた。
;   「まものに　にくを　あげると
;   なかまに　なりやすくなります。
;   「あげる　にくは　ねだんが　たかい
;   ほうが　いいそうです。
;   「ひとつで　だめなら
;   ふたつ　みっつと　あげましょう。
;   「たいせつなこと。　ほしい　まものは
;   さいごに　たおしましょう！
; --------------------------------------------------------------------------
Bank68_Msg68:                              ; $5F75  (file $111F75)
    db $F6                         ; $5F75  «insert hero name»
    db $3E                         ; $5F76  は
    db $90                         ; $5F77  　(space)
    db $74,$9C,$6F,$54             ; $5F78  ノートを
    db $90                         ; $5F7C  　(space)
    db $3F,$4E,$25,$33             ; $5F7D  ひらいた
    db $8F                         ; $5F81  。
    db $EF,$EE                     ; $5F82  newline
    db $FA                         ; $5F84  wait-for-button
    db $F7                         ; $5F85  clear page
    db $EF,$EE                     ; $5F86  newline
    db $F3                         ; $5F88  open text box
    db $96                         ; $5F89  end name/box tag
    db $43,$47,$3D,$3A             ; $5F8A  まものに
    db $90                         ; $5F8E  　(space)
    db $3A,$2B,$54                 ; $5F8F  にくを
    db $90                         ; $5F92  　(space)
    db $24,$2C,$8D,$50,$38         ; $5F93  あけ゛ると = あげると
    db $EF,$EE                     ; $5F98  newline
    db $90                         ; $5F9A  　(space)
    db $39,$29,$43,$3A             ; $5F9B  なかまに
    db $90                         ; $5F9F  　(space)
    db $39,$4F,$48,$30,$2B,$39,$4F,$43,$30; $5FA0  なりやすくなります
    db $8F                         ; $5FA9  。
    db $FA                         ; $5FAA  wait-for-button
    db $F7                         ; $5FAB  clear page
    db $EF,$EE                     ; $5FAC  newline
    db $96                         ; $5FAE  end name/box tag
    db $24,$2C,$8D,$50             ; $5FAF  あけ゛る = あげる
    db $90                         ; $5FB3  　(space)
    db $3A,$2B,$3E                 ; $5FB4  にくは
    db $90                         ; $5FB7  　(space)
    db $3C,$33,$8D,$55,$29,$8D     ; $5FB8  ねた゛んか゛ = ねだんが
    db $90                         ; $5FBE  　(space)
    db $33,$29,$25                 ; $5FBF  たかい
    db $EF,$EE                     ; $5FC2  newline
    db $90                         ; $5FC4  　(space)
    db $42,$26,$29,$8D             ; $5FC5  ほうか゛ = ほうが
    db $90                         ; $5FC9  　(space)
    db $25,$25,$32,$26,$37,$8D,$30 ; $5FCA  いいそうて゛す = いいそうです
    db $8F                         ; $5FD1  。
    db $FA                         ; $5FD2  wait-for-button
    db $F7                         ; $5FD3  clear page
    db $EF,$EE                     ; $5FD4  newline
    db $96                         ; $5FD6  end name/box tag
    db $3F,$38,$35,$37,$8D         ; $5FD7  ひとつて゛ = ひとつで
    db $90                         ; $5FDC  　(space)
    db $33,$8D,$46,$39,$4E         ; $5FDD  た゛めなら = だめなら
    db $EF,$EE                     ; $5FE2  newline
    db $90                         ; $5FE4  　(space)
    db $40,$33,$35                 ; $5FE5  ふたつ
    db $90                         ; $5FE8  　(space)
    db $44,$36,$35,$38             ; $5FE9  みっつと
    db $90                         ; $5FED  　(space)
    db $24,$2C,$8D,$43,$2F,$4D,$26 ; $5FEE  あけ゛ましょう = あげましょう
    db $8F                         ; $5FF5  。
    db $FA                         ; $5FF6  wait-for-button
    db $F7                         ; $5FF7  clear page
    db $EF,$EE                     ; $5FF8  newline
    db $96                         ; $5FFA  end name/box tag
    db $33,$25,$31,$35,$39,$2D,$38 ; $5FFB  たいせつなこと
    db $8F                         ; $6002  。
    db $90                         ; $6003  　(space)
    db $42,$2F,$25                 ; $6004  ほしい
    db $90                         ; $6007  　(space)
    db $43,$47,$3D,$3E             ; $6008  まものは
    db $EF,$EE                     ; $600C  newline
    db $90                         ; $600E  　(space)
    db $2E,$25,$2D,$8D,$3A         ; $600F  さいこ゛に = さいごに
    db $90                         ; $6014  　(space)
    db $33,$28,$2F,$43,$2F,$4D,$26 ; $6015  たおしましょう
    db $99                         ; $601C  ！
    db $F7                         ; $601D  clear page
    db $F0                         ; $601E  end of message


; --------------------------------------------------------------------------
; Message #69 ($601F)
;   「たびのとびらのまの
;   おくふかくには、
;   「まものたちが　けいとうごとに
;   すんでいる　とびらがあるらしい。
;   「けいとうごとか、。
;   そこでなら、
;   「なかまに　しそこねた　まものを
;   みつけやすいかも　しれんな。
; --------------------------------------------------------------------------
Bank68_Msg69:                              ; $601F  (file $11201F)
    db $EA                         ; $601F  ▶ new page
    db $9F                         ; $6020  box tag
    db $96                         ; $6021  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$3D; $6022  たひ゛のとひ゛らのまの = たびのとびらのまの
    db $EF,$EE                     ; $602D  newline
    db $90,$90                     ; $602F  　　(indent)
    db $28,$2B,$40,$29,$2B,$3A,$3E ; $6031  おくふかくには
    db $A4                         ; $6038  、
    db $FA                         ; $6039  wait-for-button
    db $F7                         ; $603A  clear page
    db $EF,$EE                     ; $603B  newline
    db $9F                         ; $603D  box tag
    db $96                         ; $603E  end name/box tag
    db $43,$47,$3D,$33,$34,$29,$8D ; $603F  まものたちか゛ = まものたちが
    db $90                         ; $6046  　(space)
    db $2C,$25,$38,$26,$2D,$8D,$38,$3A; $6047  けいとうこ゛とに = けいとうごとに
    db $EF,$EE                     ; $604F  newline
    db $90,$90                     ; $6051  　　(indent)
    db $30,$55,$37,$8D,$25,$50     ; $6053  すんて゛いる = すんでいる
    db $90                         ; $6059  　(space)
    db $38,$3F,$8D,$4E,$29,$8D,$24,$50,$4E,$2F,$25; $605A  とひ゛らか゛あるらしい = とびらがあるらしい
    db $8F                         ; $6065  。
    db $FA                         ; $6066  wait-for-button
    db $F7                         ; $6067  clear page
    db $EF,$EE                     ; $6068  newline
    db $9F                         ; $606A  box tag
    db $96                         ; $606B  end name/box tag
    db $2C,$25,$38,$26,$2D,$8D,$38,$29; $606C  けいとうこ゛とか = けいとうごとか
    db $A4                         ; $6074  、
    db $8F                         ; $6075  。
    db $EF,$EE                     ; $6076  newline
    db $90,$90                     ; $6078  　　(indent)
    db $32,$2D,$37,$8D,$39,$4E     ; $607A  そこて゛なら = そこでなら
    db $A4                         ; $6080  、
    db $FA                         ; $6081  wait-for-button
    db $F7                         ; $6082  clear page
    db $EF,$EE                     ; $6083  newline
    db $9F                         ; $6085  box tag
    db $96                         ; $6086  end name/box tag
    db $39,$29,$43,$3A             ; $6087  なかまに
    db $90                         ; $608B  　(space)
    db $2F,$32,$2D,$3C,$33         ; $608C  しそこねた
    db $90                         ; $6091  　(space)
    db $43,$47,$3D,$54             ; $6092  まものを
    db $EF,$EE                     ; $6096  newline
    db $90,$90                     ; $6098  　　(indent)
    db $44,$35,$2C,$48,$30,$25,$29,$47; $609A  みつけやすいかも
    db $90                         ; $60A2  　(space)
    db $2F,$51,$55,$39             ; $60A3  しれんな
    db $8F                         ; $60A7  。
    db $F7                         ; $60A8  clear page
    db $F0                         ; $60A9  end of message


; --------------------------------------------------------------------------
; Message #70 ($60AA)
;   「よそのくにの　マスターにも
;   いろんな　せいかくのやつがいる。
;   「かつと　かいふくしてくれるやつ。
;   にくを　たんまり　くれるやつ。
;   「とおくに　とばしてくれるやつ。
;   のうりょくを　あげてくれるやつ。
;   「どうすれば　やつらに
;   あうことが　できるのだろうか？
; --------------------------------------------------------------------------
Bank68_Msg70:                              ; $60AA  (file $1120AA)
    db $EA                         ; $60AA  ▶ new page
    db $9F                         ; $60AB  box tag
    db $96                         ; $60AC  end name/box tag
    db $4C,$32,$3D,$2B,$3A,$3D     ; $60AD  よそのくにの
    db $90                         ; $60B3  　(space)
    db $7A,$67,$6A,$9C,$3A,$47     ; $60B4  マスターにも
    db $EF,$EE                     ; $60BA  newline
    db $90,$90                     ; $60BC  　　(indent)
    db $25,$52,$55,$39             ; $60BE  いろんな
    db $90                         ; $60C2  　(space)
    db $31,$25,$29,$2B,$3D,$48,$35,$29,$8D,$25,$50; $60C3  せいかくのやつか゛いる = せいかくのやつがいる
    db $8F                         ; $60CE  。
    db $FA                         ; $60CF  wait-for-button
    db $F7                         ; $60D0  clear page
    db $EF,$EE                     ; $60D1  newline
    db $9F                         ; $60D3  box tag
    db $96                         ; $60D4  end name/box tag
    db $29,$35,$38                 ; $60D5  かつと
    db $90                         ; $60D8  　(space)
    db $29,$25,$40,$2B,$2F,$37,$2B,$51,$50,$48,$35; $60D9  かいふくしてくれるやつ
    db $8F                         ; $60E4  。
    db $EF,$EE                     ; $60E5  newline
    db $90,$90                     ; $60E7  　　(indent)
    db $3A,$2B,$54                 ; $60E9  にくを
    db $90                         ; $60EC  　(space)
    db $33,$55,$43,$4F             ; $60ED  たんまり
    db $90                         ; $60F1  　(space)
    db $2B,$51,$50,$48,$35         ; $60F2  くれるやつ
    db $8F                         ; $60F7  。
    db $FA                         ; $60F8  wait-for-button
    db $F7                         ; $60F9  clear page
    db $EF,$EE                     ; $60FA  newline
    db $9F                         ; $60FC  box tag
    db $96                         ; $60FD  end name/box tag
    db $38,$28,$2B,$3A             ; $60FE  とおくに
    db $90                         ; $6102  　(space)
    db $38,$3E,$8D,$2F,$37,$2B,$51,$50,$48,$35; $6103  とは゛してくれるやつ = とばしてくれるやつ
    db $8F                         ; $610D  。
    db $EF,$EE                     ; $610E  newline
    db $90,$90                     ; $6110  　　(indent)
    db $3D,$26,$4F,$4D,$2B,$54     ; $6112  のうりょくを
    db $90                         ; $6118  　(space)
    db $24,$2C,$8D,$37,$2B,$51,$50,$48,$35; $6119  あけ゛てくれるやつ = あげてくれるやつ
    db $8F                         ; $6122  。
    db $FA                         ; $6123  wait-for-button
    db $F7                         ; $6124  clear page
    db $EF,$EE                     ; $6125  newline
    db $9F                         ; $6127  box tag
    db $96                         ; $6128  end name/box tag
    db $38,$8D,$26,$30,$51,$3E,$8D ; $6129  と゛うすれは゛ = どうすれば
    db $90                         ; $6130  　(space)
    db $48,$35,$4E,$3A             ; $6131  やつらに
    db $EF,$EE                     ; $6135  newline
    db $90,$90                     ; $6137  　　(indent)
    db $24,$26,$2D,$38,$29,$8D     ; $6139  あうことか゛ = あうことが
    db $90                         ; $613F  　(space)
    db $37,$8D,$2A,$50,$3D,$33,$8D,$52,$26,$29; $6140  て゛きるのた゛ろうか = できるのだろうか
    db $98                         ; $614A  ？
    db $F7                         ; $614B  clear page
    db $F0                         ; $614C  end of message


; --------------------------------------------------------------------------
; Message #71 ($614D)
;   「あのとびらには　どんなぬしが
;   まちかまえて　いるのだろうか、。
; --------------------------------------------------------------------------
Bank68_Msg71:                              ; $614D  (file $11214D)
    db $EA                         ; $614D  ▶ new page
    db $9F                         ; $614E  box tag
    db $96                         ; $614F  end name/box tag
    db $24,$3D,$38,$3F,$8D,$4E,$3A,$3E; $6150  あのとひ゛らには = あのとびらには
    db $90                         ; $6158  　(space)
    db $38,$8D,$55,$39,$3B,$2F,$29,$8D; $6159  と゛んなぬしか゛ = どんなぬしが
    db $EF,$EE                     ; $6161  newline
    db $90,$90                     ; $6163  　　(indent)
    db $43,$34,$29,$43,$27,$37     ; $6165  まちかまえて
    db $90                         ; $616B  　(space)
    db $25,$50,$3D,$33,$8D,$52,$26,$29; $616C  いるのた゛ろうか = いるのだろうか
    db $A4                         ; $6174  、
    db $8F                         ; $6175  。
    db $F7                         ; $6176  clear page
    db $F0                         ; $6177  end of message


; --------------------------------------------------------------------------
; Message #72 ($6178)
;   「、あそこには　むしけいのまものが
;   うようよと　すんでいるらしいな。
;   「りゅうの　おうさまが　あそこの
;   ぬしらしいぞ。
;   「はかいのとびらのことも　うわさに
;   きいたが　ききたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg72:                              ; $6178  (file $112178)
    db $EA                         ; $6178  ▶ new page
    db $9F                         ; $6179  box tag
    db $96                         ; $617A  end name/box tag
    db $A4                         ; $617B  、
    db $24,$32,$2D,$3A,$3E         ; $617C  あそこには
    db $90                         ; $6181  　(space)
    db $45,$2F,$2C,$25,$3D,$43,$47,$3D,$29,$8D; $6182  むしけいのまものか゛ = むしけいのまものが
    db $EF,$EE                     ; $618C  newline
    db $90,$90                     ; $618E  　　(indent)
    db $26,$4C,$26,$4C,$38         ; $6190  うようよと
    db $90                         ; $6195  　(space)
    db $30,$55,$37,$8D,$25,$50,$4E,$2F,$25,$39; $6196  すんて゛いるらしいな = すんでいるらしいな
    db $8F                         ; $61A0  。
    db $FA                         ; $61A1  wait-for-button
    db $F7                         ; $61A2  clear page
    db $EF,$EE                     ; $61A3  newline
    db $9F                         ; $61A5  box tag
    db $96                         ; $61A6  end name/box tag
    db $4F,$4B,$26,$3D             ; $61A7  りゅうの
    db $90                         ; $61AB  　(space)
    db $28,$26,$2E,$43,$29,$8D     ; $61AC  おうさまか゛ = おうさまが
    db $90                         ; $61B2  　(space)
    db $24,$32,$2D,$3D             ; $61B3  あそこの
    db $EF,$EE                     ; $61B7  newline
    db $90,$90                     ; $61B9  　　(indent)
    db $3B,$2F,$4E,$2F,$25,$32,$8D ; $61BB  ぬしらしいそ゛ = ぬしらしいぞ
    db $8F                         ; $61C2  。
    db $FA                         ; $61C3  wait-for-button
    db $F7                         ; $61C4  clear page
    db $EF,$EE                     ; $61C5  newline
    db $9F                         ; $61C7  box tag
    db $96                         ; $61C8  end name/box tag
    db $3E,$29,$25,$3D,$38,$3F,$8D,$4E,$3D,$2D,$38,$47; $61C9  はかいのとひ゛らのことも = はかいのとびらのことも
    db $90                         ; $61D5  　(space)
    db $26,$53,$2E,$3A             ; $61D6  うわさに
    db $EF,$EE                     ; $61DA  newline
    db $90,$90                     ; $61DC  　　(indent)
    db $2A,$25,$33,$29,$8D         ; $61DE  きいたか゛ = きいたが
    db $90                         ; $61E3  　(space)
    db $2A,$2A,$33,$25,$29         ; $61E4  ききたいか
    db $98                         ; $61E9  ？
    db $FF                         ; $61EA  はい/いいえ
    db $F0                         ; $61EB  end of message


; --------------------------------------------------------------------------
; Message #73 ($61EC)
;   「ここは
;   おもいでととまどいのへやだ。
;   「みぎが　とまどいの　とびら
;   ひだりが　おもいでの　とびらだ。
; --------------------------------------------------------------------------
Bank68_Msg73:                              ; $61EC  (file $1121EC)
    db $EA                         ; $61EC  ▶ new page
    db $9F                         ; $61ED  box tag
    db $96                         ; $61EE  end name/box tag
    db $2D,$2D,$3E                 ; $61EF  ここは
    db $EF,$EE                     ; $61F2  newline
    db $90,$90                     ; $61F4  　　(indent)
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$33,$8D; $61F6  おもいて゛ととまと゛いのへやた゛ = おもいでととまどいのへやだ
    db $8F                         ; $6206  。
    db $FA                         ; $6207  wait-for-button
    db $F7                         ; $6208  clear page
    db $EF,$EE                     ; $6209  newline
    db $9F                         ; $620B  box tag
    db $96                         ; $620C  end name/box tag
    db $44,$2A,$8D,$29,$8D         ; $620D  みき゛か゛ = みぎが
    db $90                         ; $6212  　(space)
    db $38,$43,$38,$8D,$25,$3D     ; $6213  とまと゛いの = とまどいの
    db $90                         ; $6219  　(space)
    db $38,$3F,$8D,$4E             ; $621A  とひ゛ら = とびら
    db $EF,$EE                     ; $621E  newline
    db $90,$90                     ; $6220  　　(indent)
    db $3F,$33,$8D,$4F,$29,$8D     ; $6222  ひた゛りか゛ = ひだりが
    db $90                         ; $6228  　(space)
    db $28,$47,$25,$37,$8D,$3D     ; $6229  おもいて゛の = おもいでの
    db $90                         ; $622F  　(space)
    db $38,$3F,$8D,$4E,$33,$8D     ; $6230  とひ゛らた゛ = とびらだ
    db $8F                         ; $6236  。
    db $F7                         ; $6237  clear page
    db $F0                         ; $6238  end of message


; --------------------------------------------------------------------------
; Message #74 ($6239)
;   「どうも　〈テリー〉くん。
;   よく　ここまで　これましたね。
;   「わたしは　マスター　テト！
;   きみに　わたしが　たおせるかな？
;   「はっはっはっは！
;   まけても　きにしちゃいけないよ！
; --------------------------------------------------------------------------
Bank68_Msg74:                              ; $6239  (file $112239)
    db $EA                         ; $6239  ▶ new page
    db $9F                         ; $623A  box tag
    db $96                         ; $623B  end name/box tag
    db $38,$8D,$26,$47             ; $623C  と゛うも = どうも
    db $90                         ; $6240  　(space)
    db $F6                         ; $6241  «insert hero name»
    db $2B,$55                     ; $6242  くん
    db $8F                         ; $6244  。
    db $EF,$EE                     ; $6245  newline
    db $90,$90                     ; $6247  　　(indent)
    db $4C,$2B                     ; $6249  よく
    db $90                         ; $624B  　(space)
    db $2D,$2D,$43,$37,$8D         ; $624C  ここまて゛ = ここまで
    db $90                         ; $6251  　(space)
    db $2D,$51,$43,$2F,$33,$3C     ; $6252  これましたね
    db $8F                         ; $6258  。
    db $FA                         ; $6259  wait-for-button
    db $F7                         ; $625A  clear page
    db $EF,$EE                     ; $625B  newline
    db $9F                         ; $625D  box tag
    db $96                         ; $625E  end name/box tag
    db $53,$33,$2F,$3E             ; $625F  わたしは
    db $90                         ; $6263  　(space)
    db $7A,$67,$6A,$9C             ; $6264  マスター
    db $90                         ; $6268  　(space)
    db $6E,$6F                     ; $6269  テト
    db $99                         ; $626B  ！
    db $EF,$EE                     ; $626C  newline
    db $90,$90                     ; $626E  　　(indent)
    db $2A,$44,$3A                 ; $6270  きみに
    db $90                         ; $6273  　(space)
    db $53,$33,$2F,$29,$8D         ; $6274  わたしか゛ = わたしが
    db $90                         ; $6279  　(space)
    db $33,$28,$31,$50,$29,$39     ; $627A  たおせるかな
    db $98                         ; $6280  ？
    db $FA                         ; $6281  wait-for-button
    db $F7                         ; $6282  clear page
    db $EF,$EE                     ; $6283  newline
    db $9F                         ; $6285  box tag
    db $96                         ; $6286  end name/box tag
    db $3E,$36,$3E,$36,$3E,$36,$3E ; $6287  はっはっはっは
    db $99                         ; $628E  ！
    db $EF,$EE                     ; $628F  newline
    db $90,$90                     ; $6291  　　(indent)
    db $43,$2C,$37,$47             ; $6293  まけても
    db $90                         ; $6297  　(space)
    db $2A,$3A,$2F,$34,$49,$25,$2C,$39,$25,$4C; $6298  きにしちゃいけないよ
    db $99                         ; $62A2  ！
    db $F7                         ; $62A3  clear page
    db $F0                         ; $62A4  end of message


; --------------------------------------------------------------------------
; Message #75 ($62A5)
;   「また　きましたね。　まけても
;   きにしないことですよ！
; --------------------------------------------------------------------------
Bank68_Msg75:                              ; $62A5  (file $1122A5)
    db $EA                         ; $62A5  ▶ new page
    db $9F                         ; $62A6  box tag
    db $96                         ; $62A7  end name/box tag
    db $43,$33                     ; $62A8  また
    db $90                         ; $62AA  　(space)
    db $2A,$43,$2F,$33,$3C         ; $62AB  きましたね
    db $8F                         ; $62B0  。
    db $90                         ; $62B1  　(space)
    db $43,$2C,$37,$47             ; $62B2  まけても
    db $EF,$EE                     ; $62B6  newline
    db $90,$90                     ; $62B8  　　(indent)
    db $2A,$3A,$2F,$39,$25,$2D,$38,$37,$8D,$30,$4C; $62BA  きにしないことて゛すよ = きにしないことですよ
    db $99                         ; $62C5  ！
    db $F7                         ; $62C6  clear page
    db $F0                         ; $62C7  end of message


; --------------------------------------------------------------------------
; Message #76 ($62C8)
;   「いいこと　おしえようか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg76:                              ; $62C8  (file $1122C8)
    db $EB                         ; $62C8  ▶ new page
    db $9F                         ; $62C9  box tag
    db $96                         ; $62CA  end name/box tag
    db $25,$25,$2D,$38             ; $62CB  いいこと
    db $90                         ; $62CF  　(space)
    db $28,$2F,$27,$4C,$26,$29     ; $62D0  おしえようか
    db $98                         ; $62D6  ？
    db $EF,$EE                     ; $62D7  newline
    db $FF                         ; $62D9  はい/いいえ
    db $F0                         ; $62DA  end of message


; --------------------------------------------------------------------------
; Message #77 ($62DB)
;   「こんかいは　しゅさいこくだから
;   ゆうしょうしてくれよ！
; --------------------------------------------------------------------------
Bank68_Msg77:                              ; $62DB  (file $1122DB)
    db $EB                         ; $62DB  ▶ new page
    db $9F                         ; $62DC  box tag
    db $96                         ; $62DD  end name/box tag
    db $2D,$55,$29,$25,$3E         ; $62DE  こんかいは
    db $90                         ; $62E3  　(space)
    db $2F,$4B,$2E,$25,$2D,$2B,$33,$8D,$29,$4E; $62E4  しゅさいこくた゛から = しゅさいこくだから
    db $EF,$EE                     ; $62EE  newline
    db $90,$90                     ; $62F0  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$37,$2B,$51,$4C; $62F2  ゆうしょうしてくれよ
    db $99                         ; $62FC  ！
    db $F7                         ; $62FD  clear page
    db $F0                         ; $62FE  end of message


; --------------------------------------------------------------------------
; Message #78 ($62FF)
;   「はいごうすると　けっとうにした
;   まものの　けいとうがうまれるぜ！
;   「たとえば　ドラゴンが　けっとうで
;   あいてが　スラィムのばあい、
;   「ドラゴンキッズが　うまれるんだ。
;   ややこしいけど　わかったかい？
;   「ただし！　なかには　そうじゃない
;   ばあいもあるから　きをつけなよ！
; --------------------------------------------------------------------------
Bank68_Msg78:                              ; $62FF  (file $1122FF)
    db $EB                         ; $62FF  ▶ new page
    db $9F                         ; $6300  box tag
    db $96                         ; $6301  end name/box tag
    db $3E,$25,$2D,$8D,$26,$30,$50,$38; $6302  はいこ゛うすると = はいごうすると
    db $90                         ; $630A  　(space)
    db $2C,$36,$38,$26,$3A,$2F,$33 ; $630B  けっとうにした
    db $EF,$EE                     ; $6312  newline
    db $90,$90                     ; $6314  　　(indent)
    db $43,$47,$3D,$3D             ; $6316  まものの
    db $90                         ; $631A  　(space)
    db $2C,$25,$38,$26,$29,$8D,$26,$43,$51,$50,$31,$8D; $631B  けいとうか゛うまれるせ゛ = けいとうがうまれるぜ
    db $99                         ; $6327  ！
    db $FA                         ; $6328  wait-for-button
    db $F7                         ; $6329  clear page
    db $EF,$EE                     ; $632A  newline
    db $9F                         ; $632C  box tag
    db $96                         ; $632D  end name/box tag
    db $33,$38,$27,$3E,$8D         ; $632E  たとえは゛ = たとえば
    db $90                         ; $6333  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$29,$8D; $6334  ト゛ラコ゛ンか゛ = ドラゴンが
    db $90                         ; $633C  　(space)
    db $2C,$36,$38,$26,$37,$8D     ; $633D  けっとうて゛ = けっとうで
    db $EF,$EE                     ; $6343  newline
    db $90,$90                     ; $6345  　　(indent)
    db $24,$25,$37,$29,$8D         ; $6347  あいてか゛ = あいてが
    db $90                         ; $634C  　(space)
    db $67,$85,$58,$7C,$3D,$3E,$8D,$24,$25; $634D  スラィムのは゛あい = スラィムのばあい
    db $A4                         ; $6356  、
    db $FA                         ; $6357  wait-for-button
    db $F7                         ; $6358  clear page
    db $EF,$EE                     ; $6359  newline
    db $9F                         ; $635B  box tag
    db $96                         ; $635C  end name/box tag
    db $6F,$8D,$85,$64,$8D,$8C,$61,$6D,$67,$8D,$29,$8D; $635D  ト゛ラコ゛ンキッス゛か゛ = ドラゴンキッズが
    db $90                         ; $6369  　(space)
    db $26,$43,$51,$50,$55,$33,$8D ; $636A  うまれるんた゛ = うまれるんだ
    db $8F                         ; $6371  。
    db $EF,$EE                     ; $6372  newline
    db $90,$90                     ; $6374  　　(indent)
    db $48,$48,$2D,$2F,$25,$2C,$38,$8D; $6376  ややこしいけと゛ = ややこしいけど
    db $90                         ; $637E  　(space)
    db $53,$29,$36,$33,$29,$25     ; $637F  わかったかい
    db $98                         ; $6385  ？
    db $FA                         ; $6386  wait-for-button
    db $F7                         ; $6387  clear page
    db $EF,$EE                     ; $6388  newline
    db $9F                         ; $638A  box tag
    db $96                         ; $638B  end name/box tag
    db $33,$33,$8D,$2F             ; $638C  たた゛し = ただし
    db $99                         ; $6390  ！
    db $90                         ; $6391  　(space)
    db $39,$29,$3A,$3E             ; $6392  なかには
    db $90                         ; $6396  　(space)
    db $32,$26,$2F,$8D,$49,$39,$25 ; $6397  そうし゛ゃない = そうじゃない
    db $EF,$EE                     ; $639E  newline
    db $90,$90                     ; $63A0  　　(indent)
    db $3E,$8D,$24,$25,$47,$24,$50,$29,$4E; $63A2  は゛あいもあるから = ばあいもあるから
    db $90                         ; $63AB  　(space)
    db $2A,$54,$35,$2C,$39,$4C     ; $63AC  きをつけなよ
    db $99                         ; $63B2  ！
    db $F7                         ; $63B3  clear page
    db $F0                         ; $63B4  end of message


; --------------------------------------------------------------------------
; Message #79 ($63B5)
;   「はいごうに　かんする　ことですが
;   おききに　なりたいですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg79:                              ; $63B5  (file $1123B5)
    db $EB                         ; $63B5  ▶ new page
    db $9F                         ; $63B6  box tag
    db $96                         ; $63B7  end name/box tag
    db $3E,$25,$2D,$8D,$26,$3A     ; $63B8  はいこ゛うに = はいごうに
    db $90                         ; $63BE  　(space)
    db $29,$55,$30,$50             ; $63BF  かんする
    db $90                         ; $63C3  　(space)
    db $2D,$38,$37,$8D,$30,$29,$8D ; $63C4  ことて゛すか゛ = ことですが
    db $EF,$EE                     ; $63CB  newline
    db $90,$90                     ; $63CD  　　(indent)
    db $28,$2A,$2A,$3A             ; $63CF  おききに
    db $90                         ; $63D3  　(space)
    db $39,$4F,$33,$25,$37,$8D,$30,$29; $63D4  なりたいて゛すか = なりたいですか
    db $98                         ; $63DC  ？
    db $FF                         ; $63DD  はい/いいえ
    db $F0                         ; $63DE  end of message


; --------------------------------------------------------------------------
; Message #80 ($63DF)
;   「かくとうじょうでの　しょうりが
;   たいかいにでるための　みちです。
; --------------------------------------------------------------------------
Bank68_Msg80:                              ; $63DF  (file $1123DF)
    db $EB                         ; $63DF  ▶ new page
    db $9F                         ; $63E0  box tag
    db $96                         ; $63E1  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D,$3D; $63E2  かくとうし゛ょうて゛の = かくとうじょうでの
    db $90                         ; $63ED  　(space)
    db $2F,$4D,$26,$4F,$29,$8D     ; $63EE  しょうりか゛ = しょうりが
    db $EF,$EE                     ; $63F4  newline
    db $90,$90                     ; $63F6  　　(indent)
    db $33,$25,$29,$25,$3A,$37,$8D,$50,$33,$46,$3D; $63F8  たいかいにて゛るための = たいかいにでるための
    db $90                         ; $6403  　(space)
    db $44,$34,$37,$8D,$30         ; $6404  みちて゛す = みちです
    db $8F                         ; $6409  。
    db $F7                         ; $640A  clear page
    db $F0                         ; $640B  end of message


; --------------------------------------------------------------------------
; Message #81 ($640C)
;   「おなじけいとうの　まものどうしを
;   はいごうさせると、
;   「うまれる　まものは　けっとうと
;   おなじ　まものに　なるそうです。
;   「スラィムと　ホィミスラィムを
;   はいごうした　ばあい、
;   「スラィムが　うまれてきますよ。
;   おわかり　いただけましたか？
;   「ただし　なにごとにも　れいがいは
;   つきものです。　おきをつけて、。
; --------------------------------------------------------------------------
Bank68_Msg81:                              ; $640C  (file $11240C)
    db $EB                         ; $640C  ▶ new page
    db $9F                         ; $640D  box tag
    db $96                         ; $640E  end name/box tag
    db $28,$39,$2F,$8D,$2C,$25,$38,$26,$3D; $640F  おなし゛けいとうの = おなじけいとうの
    db $90                         ; $6418  　(space)
    db $43,$47,$3D,$38,$8D,$26,$2F,$54; $6419  まものと゛うしを = まものどうしを
    db $EF,$EE                     ; $6421  newline
    db $90,$90                     ; $6423  　　(indent)
    db $3E,$25,$2D,$8D,$26,$2E,$31,$50,$38; $6425  はいこ゛うさせると = はいごうさせると
    db $A4                         ; $642E  、
    db $FA                         ; $642F  wait-for-button
    db $F7                         ; $6430  clear page
    db $EF,$EE                     ; $6431  newline
    db $9F                         ; $6433  box tag
    db $96                         ; $6434  end name/box tag
    db $26,$43,$51,$50             ; $6435  うまれる
    db $90                         ; $6439  　(space)
    db $43,$47,$3D,$3E             ; $643A  まものは
    db $90                         ; $643E  　(space)
    db $2C,$36,$38,$26,$38         ; $643F  けっとうと
    db $EF,$EE                     ; $6444  newline
    db $90,$90                     ; $6446  　　(indent)
    db $28,$39,$2F,$8D             ; $6448  おなし゛ = おなじ
    db $90                         ; $644C  　(space)
    db $43,$47,$3D,$3A             ; $644D  まものに
    db $90                         ; $6451  　(space)
    db $39,$50,$32,$26,$37,$8D,$30 ; $6452  なるそうて゛す = なるそうです
    db $8F                         ; $6459  。
    db $FA                         ; $645A  wait-for-button
    db $F7                         ; $645B  clear page
    db $EF,$EE                     ; $645C  newline
    db $9F                         ; $645E  box tag
    db $96                         ; $645F  end name/box tag
    db $67,$85,$58,$7C,$38         ; $6460  スラィムと
    db $90                         ; $6465  　(space)
    db $79,$58,$7B,$67,$85,$58,$7C,$54; $6466  ホィミスラィムを
    db $EF,$EE                     ; $646E  newline
    db $90,$90                     ; $6470  　　(indent)
    db $3E,$25,$2D,$8D,$26,$2F,$33 ; $6472  はいこ゛うした = はいごうした
    db $90                         ; $6479  　(space)
    db $3E,$8D,$24,$25             ; $647A  は゛あい = ばあい
    db $A4                         ; $647E  、
    db $FA                         ; $647F  wait-for-button
    db $F7                         ; $6480  clear page
    db $EF,$EE                     ; $6481  newline
    db $9F                         ; $6483  box tag
    db $96                         ; $6484  end name/box tag
    db $67,$85,$58,$7C,$29,$8D     ; $6485  スラィムか゛ = スラィムが
    db $90                         ; $648B  　(space)
    db $26,$43,$51,$37,$2A,$43,$30,$4C; $648C  うまれてきますよ
    db $8F                         ; $6494  。
    db $EF,$EE                     ; $6495  newline
    db $90,$90                     ; $6497  　　(indent)
    db $28,$53,$29,$4F             ; $6499  おわかり
    db $90                         ; $649D  　(space)
    db $25,$33,$33,$8D,$2C,$43,$2F,$33,$29; $649E  いたた゛けましたか = いただけましたか
    db $98                         ; $64A7  ？
    db $FA                         ; $64A8  wait-for-button
    db $F7                         ; $64A9  clear page
    db $EF,$EE                     ; $64AA  newline
    db $9F                         ; $64AC  box tag
    db $96                         ; $64AD  end name/box tag
    db $33,$33,$8D,$2F             ; $64AE  たた゛し = ただし
    db $90                         ; $64B2  　(space)
    db $39,$3A,$2D,$8D,$38,$3A,$47 ; $64B3  なにこ゛とにも = なにごとにも
    db $90                         ; $64BA  　(space)
    db $51,$25,$29,$8D,$25,$3E     ; $64BB  れいか゛いは = れいがいは
    db $EF,$EE                     ; $64C1  newline
    db $90,$90                     ; $64C3  　　(indent)
    db $35,$2A,$47,$3D,$37,$8D,$30 ; $64C5  つきものて゛す = つきものです
    db $8F                         ; $64CC  。
    db $90                         ; $64CD  　(space)
    db $28,$2A,$54,$35,$2C,$37     ; $64CE  おきをつけて
    db $A4                         ; $64D4  、
    db $8F                         ; $64D5  。
    db $F7                         ; $64D6  clear page
    db $F0                         ; $64D7  end of message


; --------------------------------------------------------------------------
; Message #82 ($64D8)
;   「[0E]クラスかちぬき　おめでとう。
;   「やすらぎとゆうきのへやが
;   ほうびとして　ひらかれたぞ！
; --------------------------------------------------------------------------
Bank68_Msg82:                              ; $64D8  (file $1124D8)
    db $EA                         ; $64D8  ▶ new page
    db $9F                         ; $64D9  box tag
    db $96                         ; $64DA  end name/box tag
    db $0E                         ; $64DB  ctrl $0E
    db $62,$85,$67,$29,$34,$3B,$2A ; $64DC  クラスかちぬき
    db $90                         ; $64E3  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $64E4  おめて゛とう = おめでとう
    db $8F                         ; $64EA  。
    db $EF,$EE                     ; $64EB  newline
    db $FA                         ; $64ED  wait-for-button
    db $F7                         ; $64EE  clear page
    db $EF,$EE                     ; $64EF  newline
    db $F3                         ; $64F1  open text box
    db $9F                         ; $64F2  box tag
    db $96                         ; $64F3  end name/box tag
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48,$29,$8D; $64F4  やすらき゛とゆうきのへやか゛ = やすらぎとゆうきのへやが
    db $EF,$EE                     ; $6502  newline
    db $90,$90                     ; $6504  　　(indent)
    db $42,$26,$3F,$8D,$38,$2F,$37 ; $6506  ほうひ゛として = ほうびとして
    db $90                         ; $650D  　(space)
    db $3F,$4E,$29,$51,$33,$32,$8D ; $650E  ひらかれたそ゛ = ひらかれたぞ
    db $99                         ; $6515  ！
    db $F7                         ; $6516  clear page
    db $F0                         ; $6517  end of message


; --------------------------------------------------------------------------
; Message #83 ($6518)
;   「〈テリー〉！
;   がんばっておるようだな。
;   「やすらぎとゆうきのへや　それに
;   おもいでととまどいのへやが、
;   「[0E]クラスかちぬきの　ほうびとして
;   ひらかれたぞ！
; --------------------------------------------------------------------------
Bank68_Msg83:                              ; $6518  (file $112518)
    db $EA                         ; $6518  ▶ new page
    db $9F                         ; $6519  box tag
    db $96                         ; $651A  end name/box tag
    db $F6                         ; $651B  «insert hero name»
    db $99                         ; $651C  ！
    db $EF,$EE                     ; $651D  newline
    db $90,$90                     ; $651F  　　(indent)
    db $29,$8D,$55,$3E,$8D,$36,$37,$28,$50,$4C,$26,$33,$8D,$39; $6521  か゛んは゛っておるようた゛な = がんばっておるようだな
    db $8F                         ; $652F  。
    db $FA                         ; $6530  wait-for-button
    db $F7                         ; $6531  clear page
    db $EF,$EE                     ; $6532  newline
    db $9F                         ; $6534  box tag
    db $96                         ; $6535  end name/box tag
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48; $6536  やすらき゛とゆうきのへや = やすらぎとゆうきのへや
    db $90                         ; $6542  　(space)
    db $32,$51,$3A                 ; $6543  それに
    db $EF,$EE                     ; $6546  newline
    db $90,$90                     ; $6548  　　(indent)
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$29,$8D; $654A  おもいて゛ととまと゛いのへやか゛ = おもいでととまどいのへやが
    db $A4                         ; $655A  、
    db $FA                         ; $655B  wait-for-button
    db $F7                         ; $655C  clear page
    db $EF,$EE                     ; $655D  newline
    db $9F                         ; $655F  box tag
    db $96                         ; $6560  end name/box tag
    db $0E                         ; $6561  ctrl $0E
    db $62,$85,$67,$29,$34,$3B,$2A,$3D; $6562  クラスかちぬきの
    db $90                         ; $656A  　(space)
    db $42,$26,$3F,$8D,$38,$2F,$37 ; $656B  ほうひ゛として = ほうびとして
    db $EF,$EE                     ; $6572  newline
    db $90,$90                     ; $6574  　　(indent)
    db $3F,$4E,$29,$51,$33,$32,$8D ; $6576  ひらかれたそ゛ = ひらかれたぞ
    db $99                         ; $657D  ！
    db $F7                         ; $657E  clear page
    db $F0                         ; $657F  end of message


; --------------------------------------------------------------------------
; Message #84 ($6580)
;   「ゆうきの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg84:                              ; $6580  (file $112580)
    db $EB                         ; $6580  ▶ new page
    db $9F                         ; $6581  box tag
    db $96                         ; $6582  end name/box tag
    db $4A,$26,$2A,$3D             ; $6583  ゆうきの
    db $90                         ; $6587  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $6588  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $6590  newline
    db $90,$90                     ; $6592  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $6594  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $659F  ？
    db $FF                         ; $65A0  はい/いいえ
    db $F0                         ; $65A1  end of message


; --------------------------------------------------------------------------
; Message #85 ($65A2)
;   「ぜつぼうは　きぼうの　いちぶ！
;   きぼうは　ぜつぼうのなかにある！
;   「あかるい　ぜつぼうの
;   のりこえかた　より。
; --------------------------------------------------------------------------
Bank68_Msg85:                              ; $65A2  (file $1125A2)
    db $EB                         ; $65A2  ▶ new page
    db $9F                         ; $65A3  box tag
    db $96                         ; $65A4  end name/box tag
    db $31,$8D,$35,$42,$8D,$26,$3E ; $65A5  せ゛つほ゛うは = ぜつぼうは
    db $90                         ; $65AC  　(space)
    db $2A,$42,$8D,$26,$3D         ; $65AD  きほ゛うの = きぼうの
    db $90                         ; $65B2  　(space)
    db $25,$34,$40,$8D             ; $65B3  いちふ゛ = いちぶ
    db $99                         ; $65B7  ！
    db $EF,$EE                     ; $65B8  newline
    db $90,$90                     ; $65BA  　　(indent)
    db $2A,$42,$8D,$26,$3E         ; $65BC  きほ゛うは = きぼうは
    db $90                         ; $65C1  　(space)
    db $31,$8D,$35,$42,$8D,$26,$3D,$39,$29,$3A,$24,$50; $65C2  せ゛つほ゛うのなかにある = ぜつぼうのなかにある
    db $99                         ; $65CE  ！
    db $FA                         ; $65CF  wait-for-button
    db $F7                         ; $65D0  clear page
    db $EF,$EE                     ; $65D1  newline
    db $9F                         ; $65D3  box tag
    db $96                         ; $65D4  end name/box tag
    db $24,$29,$50,$25             ; $65D5  あかるい
    db $90                         ; $65D9  　(space)
    db $31,$8D,$35,$42,$8D,$26,$3D ; $65DA  せ゛つほ゛うの = ぜつぼうの
    db $EF,$EE                     ; $65E1  newline
    db $90,$90                     ; $65E3  　　(indent)
    db $3D,$4F,$2D,$27,$29,$33     ; $65E5  のりこえかた
    db $90                         ; $65EB  　(space)
    db $4C,$4F                     ; $65EC  より
    db $8F                         ; $65EE  。
    db $F7                         ; $65EF  clear page
    db $F0                         ; $65F0  end of message


; --------------------------------------------------------------------------
; Message #86 ($65F1)
;   「やすらぎの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg86:                              ; $65F1  (file $1125F1)
    db $EB                         ; $65F1  ▶ new page
    db $9F                         ; $65F2  box tag
    db $96                         ; $65F3  end name/box tag
    db $48,$30,$4E,$2A,$8D,$3D     ; $65F4  やすらき゛の = やすらぎの
    db $90                         ; $65FA  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $65FB  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $6603  newline
    db $90,$90                     ; $6605  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $6607  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $6612  ？
    db $FF                         ; $6613  はい/いいえ
    db $F0                         ; $6614  end of message


; --------------------------------------------------------------------------
; Message #87 ($6615)
;   「くんし　あやうきに　ちかよらず。
;   「きけん！　もうかってないやつには
;   はなしかけるな！！
;   「マネー　ぞうしょくじゅつ　より。
; --------------------------------------------------------------------------
Bank68_Msg87:                              ; $6615  (file $112615)
    db $EB                         ; $6615  ▶ new page
    db $9F                         ; $6616  box tag
    db $96                         ; $6617  end name/box tag
    db $2B,$55,$2F                 ; $6618  くんし
    db $90                         ; $661B  　(space)
    db $24,$48,$26,$2A,$3A         ; $661C  あやうきに
    db $90                         ; $6621  　(space)
    db $34,$29,$4C,$4E,$30,$8D     ; $6622  ちかよらす゛ = ちかよらず
    db $8F                         ; $6628  。
    db $EF,$EE                     ; $6629  newline
    db $FA                         ; $662B  wait-for-button
    db $F7                         ; $662C  clear page
    db $EF,$EE                     ; $662D  newline
    db $F3                         ; $662F  open text box
    db $9F                         ; $6630  box tag
    db $96                         ; $6631  end name/box tag
    db $2A,$2C,$55                 ; $6632  きけん
    db $99                         ; $6635  ！
    db $90                         ; $6636  　(space)
    db $47,$26,$29,$36,$37,$39,$25,$48,$35,$3A,$3E; $6637  もうかってないやつには
    db $EF,$EE                     ; $6642  newline
    db $90,$90                     ; $6644  　　(indent)
    db $3E,$39,$2F,$29,$2C,$50,$39 ; $6646  はなしかけるな
    db $99                         ; $664D  ！
    db $99                         ; $664E  ！
    db $FA                         ; $664F  wait-for-button
    db $F7                         ; $6650  clear page
    db $EF,$EE                     ; $6651  newline
    db $9F                         ; $6653  box tag
    db $96                         ; $6654  end name/box tag
    db $7A,$73,$9C                 ; $6655  マネー
    db $90                         ; $6658  　(space)
    db $32,$8D,$26,$2F,$4D,$2B,$2F,$8D,$4B,$35; $6659  そ゛うしょくし゛ゅつ = ぞうしょくじゅつ
    db $90                         ; $6663  　(space)
    db $4C,$4F                     ; $6664  より
    db $8F                         ; $6666  。
    db $EF,$EE                     ; $6667  newline
    db $F7                         ; $6669  clear page
    db $F0                         ; $666A  end of message


; --------------------------------------------------------------------------
; Message #88 ($666B)
;   [E9]カ〈テリー〉は　タンスの
;   なかを　しらべた。
;   おんなものの　いしょうが
;   ぎっしりと　つまっている！
; --------------------------------------------------------------------------
Bank68_Msg88:                              ; $666B  (file $11266B)
    db $E9                         ; $666B  ctrl $E9
    db $60                         ; $666C  カ
    db $F6                         ; $666D  «insert hero name»
    db $3E                         ; $666E  は
    db $90                         ; $666F  　(space)
    db $6A,$8C,$67,$3D             ; $6670  タンスの
    db $EF,$EE                     ; $6674  newline
    db $39,$29,$54                 ; $6676  なかを
    db $90                         ; $6679  　(space)
    db $2F,$4E,$41,$8D,$33         ; $667A  しらへ゛た = しらべた
    db $8F                         ; $667F  。
    db $FA                         ; $6680  wait-for-button
    db $F7                         ; $6681  clear page
    db $EF,$EE                     ; $6682  newline
    db $28,$55,$39,$47,$3D,$3D     ; $6684  おんなものの
    db $90                         ; $668A  　(space)
    db $25,$2F,$4D,$26,$29,$8D     ; $668B  いしょうか゛ = いしょうが
    db $EF,$EE                     ; $6691  newline
    db $2A,$8D,$36,$2F,$4F,$38     ; $6693  き゛っしりと = ぎっしりと
    db $90                         ; $6699  　(space)
    db $35,$43,$36,$37,$25,$50     ; $669A  つまっている
    db $99                         ; $66A0  ！
    db $F7                         ; $66A1  clear page
    db $F0                         ; $66A2  end of message


; --------------------------------------------------------------------------
; Message #89 ($66A3)
;   「こうだいな　ちかめいきゅう。
;   「いっぽ　すすむごとに　おそう
;   おとしあなの　きょうふ、、。
;   「はたして　わたしは
;   たどりつけるのだろうか？
;   「めいさく　ロンダルキアへの
;   みち　より。
; --------------------------------------------------------------------------
Bank68_Msg89:                              ; $66A3  (file $1126A3)
    db $EB                         ; $66A3  ▶ new page
    db $9F                         ; $66A4  box tag
    db $96                         ; $66A5  end name/box tag
    db $2D,$26,$33,$8D,$25,$39     ; $66A6  こうた゛いな = こうだいな
    db $90                         ; $66AC  　(space)
    db $34,$29,$46,$25,$2A,$4B,$26 ; $66AD  ちかめいきゅう
    db $8F                         ; $66B4  。
    db $EF,$EE                     ; $66B5  newline
    db $FA                         ; $66B7  wait-for-button
    db $F7                         ; $66B8  clear page
    db $EF,$EE                     ; $66B9  newline
    db $F3                         ; $66BB  open text box
    db $9F                         ; $66BC  box tag
    db $96                         ; $66BD  end name/box tag
    db $25,$36,$42,$8E             ; $66BE  いっほ゜ = いっぽ
    db $90                         ; $66C2  　(space)
    db $30,$30,$45,$2D,$8D,$38,$3A ; $66C3  すすむこ゛とに = すすむごとに
    db $90                         ; $66CA  　(space)
    db $28,$32,$26                 ; $66CB  おそう
    db $EF,$EE                     ; $66CE  newline
    db $90,$90                     ; $66D0  　　(indent)
    db $28,$38,$2F,$24,$39,$3D     ; $66D2  おとしあなの
    db $90                         ; $66D8  　(space)
    db $2A,$4D,$26,$40             ; $66D9  きょうふ
    db $A4                         ; $66DD  、
    db $A4                         ; $66DE  、
    db $8F                         ; $66DF  。
    db $FA                         ; $66E0  wait-for-button
    db $F7                         ; $66E1  clear page
    db $EF,$EE                     ; $66E2  newline
    db $9F                         ; $66E4  box tag
    db $96                         ; $66E5  end name/box tag
    db $3E,$33,$2F,$37             ; $66E6  はたして
    db $90                         ; $66EA  　(space)
    db $53,$33,$2F,$3E             ; $66EB  わたしは
    db $EF,$EE                     ; $66EF  newline
    db $90,$90                     ; $66F1  　　(indent)
    db $33,$38,$8D,$4F,$35,$2C,$50,$3D,$33,$8D,$52,$26,$29; $66F3  たと゛りつけるのた゛ろうか = たどりつけるのだろうか
    db $98                         ; $6700  ？
    db $FA                         ; $6701  wait-for-button
    db $F7                         ; $6702  clear page
    db $EF,$EE                     ; $6703  newline
    db $9F                         ; $6705  box tag
    db $96                         ; $6706  end name/box tag
    db $46,$25,$2E,$2B             ; $6707  めいさく
    db $90                         ; $670B  　(space)
    db $89,$8C,$6A,$8D,$87,$61,$56,$41,$3D; $670C  ロンタ゛ルキアへの = ロンダルキアへの
    db $EF,$EE                     ; $6715  newline
    db $90,$90                     ; $6717  　　(indent)
    db $44,$34                     ; $6719  みち
    db $90                         ; $671B  　(space)
    db $4C,$4F                     ; $671C  より
    db $8F                         ; $671E  。
    db $F7                         ; $671F  clear page
    db $F0                         ; $6720  end of message


; --------------------------------------------------------------------------
; Message #90 ($6721)
;   おう「おお　〈テリー〉よ！
;   ビックアィを　たおしたか！
;   おう「なに？　ビックアィが
;   なかまに　ならなかった？
;   おう「そうか、。　そういうことも
;   あるだろう。
;   おう「そなたに　いいわすれたが
;   ボスには　にくなど　ふようだ。
;   おう「にくなど　つかわなくても
;   なかまになるものは　なる。
;   おう「ならないものは　ならない。
;   おう「このことを　しっておれば
;   にくのムダづかいも　なくなり
;   おう「[01][00][00]まんゴールドくらい
;   すぐに　たまるであろう！
; --------------------------------------------------------------------------
Bank68_Msg90:                              ; $6721  (file $112721)
    db $EA                         ; $6721  ▶ new page
    db $28,$26                     ; $6722  おう  (speaker: おう)
    db $96                         ; $6724  end name/box tag
    db $28,$28                     ; $6725  おお
    db $90                         ; $6727  　(space)
    db $F6                         ; $6728  «insert hero name»
    db $4C                         ; $6729  よ
    db $99                         ; $672A  ！
    db $EF,$EE                     ; $672B  newline
    db $90,$90                     ; $672D  　　(indent)
    db $76,$8D,$6D,$62,$56,$58,$54 ; $672F  ヒ゛ックアィを = ビックアィを
    db $90                         ; $6736  　(space)
    db $33,$28,$2F,$33,$29         ; $6737  たおしたか
    db $99                         ; $673C  ！
    db $FA                         ; $673D  wait-for-button
    db $F7                         ; $673E  clear page
    db $EF,$EE                     ; $673F  newline
    db $28,$26                     ; $6741  おう  (speaker: おう)
    db $96                         ; $6743  end name/box tag
    db $39,$3A                     ; $6744  なに
    db $98                         ; $6746  ？
    db $90                         ; $6747  　(space)
    db $76,$8D,$6D,$62,$56,$58,$29,$8D; $6748  ヒ゛ックアィか゛ = ビックアィが
    db $EF,$EE                     ; $6750  newline
    db $90,$90                     ; $6752  　　(indent)
    db $39,$29,$43,$3A             ; $6754  なかまに
    db $90                         ; $6758  　(space)
    db $39,$4E,$39,$29,$36,$33     ; $6759  ならなかった
    db $98                         ; $675F  ？
    db $FA                         ; $6760  wait-for-button
    db $F7                         ; $6761  clear page
    db $EF,$EE                     ; $6762  newline
    db $28,$26                     ; $6764  おう  (speaker: おう)
    db $96                         ; $6766  end name/box tag
    db $32,$26,$29                 ; $6767  そうか
    db $A4                         ; $676A  、
    db $8F                         ; $676B  。
    db $90                         ; $676C  　(space)
    db $32,$26,$25,$26,$2D,$38,$47 ; $676D  そういうことも
    db $EF,$EE                     ; $6774  newline
    db $90,$90                     ; $6776  　　(indent)
    db $24,$50,$33,$8D,$52,$26     ; $6778  あるた゛ろう = あるだろう
    db $8F                         ; $677E  。
    db $FA                         ; $677F  wait-for-button
    db $F7                         ; $6780  clear page
    db $EF,$EE                     ; $6781  newline
    db $28,$26                     ; $6783  おう  (speaker: おう)
    db $96                         ; $6785  end name/box tag
    db $32,$39,$33,$3A             ; $6786  そなたに
    db $90                         ; $678A  　(space)
    db $25,$25,$53,$30,$51,$33,$29,$8D; $678B  いいわすれたか゛ = いいわすれたが
    db $EF,$EE                     ; $6793  newline
    db $90,$90                     ; $6795  　　(indent)
    db $79,$8D,$67,$3A,$3E         ; $6797  ホ゛スには = ボスには
    db $90                         ; $679C  　(space)
    db $3A,$2B,$39,$38,$8D         ; $679D  にくなと゛ = にくなど
    db $90                         ; $67A2  　(space)
    db $40,$4C,$26,$33,$8D         ; $67A3  ふようた゛ = ふようだ
    db $8F                         ; $67A8  。
    db $FA                         ; $67A9  wait-for-button
    db $F7                         ; $67AA  clear page
    db $EF,$EE                     ; $67AB  newline
    db $28,$26                     ; $67AD  おう  (speaker: おう)
    db $96                         ; $67AF  end name/box tag
    db $3A,$2B,$39,$38,$8D         ; $67B0  にくなと゛ = にくなど
    db $90                         ; $67B5  　(space)
    db $35,$29,$53,$39,$2B,$37,$47 ; $67B6  つかわなくても
    db $EF,$EE                     ; $67BD  newline
    db $90,$90                     ; $67BF  　　(indent)
    db $39,$29,$43,$3A,$39,$50,$47,$3D,$3E; $67C1  なかまになるものは
    db $90                         ; $67CA  　(space)
    db $39,$50                     ; $67CB  なる
    db $8F                         ; $67CD  。
    db $FA                         ; $67CE  wait-for-button
    db $F7                         ; $67CF  clear page
    db $EF,$EE                     ; $67D0  newline
    db $28,$26                     ; $67D2  おう  (speaker: おう)
    db $96                         ; $67D4  end name/box tag
    db $39,$4E,$39,$25,$47,$3D,$3E ; $67D5  ならないものは
    db $90                         ; $67DC  　(space)
    db $39,$4E,$39,$25             ; $67DD  ならない
    db $8F                         ; $67E1  。
    db $EF,$EE                     ; $67E2  newline
    db $FA                         ; $67E4  wait-for-button
    db $F7                         ; $67E5  clear page
    db $EF,$EE                     ; $67E6  newline
    db $F3                         ; $67E8  open text box
    db $28,$26                     ; $67E9  おう
    db $96                         ; $67EB  end name/box tag
    db $2D,$3D,$2D,$38,$54         ; $67EC  このことを
    db $90                         ; $67F1  　(space)
    db $2F,$36,$37,$28,$51,$3E,$8D ; $67F2  しっておれは゛ = しっておれば
    db $EF,$EE                     ; $67F9  newline
    db $90,$90                     ; $67FB  　　(indent)
    db $3A,$2B,$3D,$7C,$6A,$8D,$35,$8D,$29,$25,$47; $67FD  にくのムタ゛つ゛かいも = にくのムダづかいも
    db $90                         ; $6808  　(space)
    db $39,$2B,$39,$4F             ; $6809  なくなり
    db $FA                         ; $680D  wait-for-button
    db $F7                         ; $680E  clear page
    db $EF,$EE                     ; $680F  newline
    db $28,$26                     ; $6811  おう  (speaker: おう)
    db $96                         ; $6813  end name/box tag
    db $01                         ; $6814  ctrl $01
    db $00                         ; $6815  ctrl $00
    db $00                         ; $6816  ctrl $00
    db $43,$55,$64,$8D,$9C,$87,$6F,$8D,$2B,$4E,$25; $6817  まんコ゛ールト゛くらい = まんゴールドくらい
    db $EF,$EE                     ; $6822  newline
    db $90,$90                     ; $6824  　　(indent)
    db $30,$2B,$8D,$3A             ; $6826  すく゛に = すぐに
    db $90                         ; $682A  　(space)
    db $33,$43,$50,$37,$8D,$24,$52,$26; $682B  たまるて゛あろう = たまるであろう
    db $99                         ; $6833  ！
    db $F7                         ; $6834  clear page
    db $F0                         ; $6835  end of message


; --------------------------------------------------------------------------
; Message #91 ($6836)
;   〈テリー〉は　ぬいぐるみを　しらべた。
;   どこかで　みたことのある
;   ぬいぐるみだ。
; --------------------------------------------------------------------------
Bank68_Msg91:                              ; $6836  (file $112836)
    db $F6                         ; $6836  «insert hero name»
    db $3E                         ; $6837  は
    db $90                         ; $6838  　(space)
    db $3B,$25,$2B,$8D,$50,$44,$54 ; $6839  ぬいく゛るみを = ぬいぐるみを
    db $90                         ; $6840  　(space)
    db $2F,$4E,$41,$8D,$33         ; $6841  しらへ゛た = しらべた
    db $8F                         ; $6846  。
    db $EF,$EE                     ; $6847  newline
    db $FA                         ; $6849  wait-for-button
    db $F7                         ; $684A  clear page
    db $EF,$EE                     ; $684B  newline
    db $F3                         ; $684D  open text box
    db $38,$8D,$2D,$29,$37,$8D     ; $684E  と゛こかて゛ = どこかで
    db $90                         ; $6854  　(space)
    db $44,$33,$2D,$38,$3D,$24,$50 ; $6855  みたことのある
    db $EF,$EE                     ; $685C  newline
    db $3B,$25,$2B,$8D,$50,$44,$33,$8D; $685E  ぬいく゛るみた゛ = ぬいぐるみだ
    db $8F                         ; $6866  。
    db $F7                         ; $6867  clear page
    db $F0                         ; $6868  end of message


; --------------------------------------------------------------------------
; Message #92 ($6869)
;   おう「おお　〈テリー〉よ！
;   スラィムファングを　たおしたか！
;   おう「ほう。　カジノに　いったのか。
;   そなたは　いくらもうけたのじゃ？
;   おう「まものゴールド？　そんなもの
;   ここでは　やくにたたん！！
; --------------------------------------------------------------------------
Bank68_Msg92:                              ; $6869  (file $112869)
    db $EA                         ; $6869  ▶ new page
    db $28,$26                     ; $686A  おう  (speaker: おう)
    db $96                         ; $686C  end name/box tag
    db $28,$28                     ; $686D  おお
    db $90                         ; $686F  　(space)
    db $F6                         ; $6870  «insert hero name»
    db $4C                         ; $6871  よ
    db $99                         ; $6872  ！
    db $EF,$EE                     ; $6873  newline
    db $90,$90                     ; $6875  　　(indent)
    db $67,$85,$58,$7C,$77,$57,$8C,$62,$8D,$54; $6877  スラィムファンク゛を = スラィムファングを
    db $90                         ; $6881  　(space)
    db $33,$28,$2F,$33,$29         ; $6882  たおしたか
    db $99                         ; $6887  ！
    db $FA                         ; $6888  wait-for-button
    db $F7                         ; $6889  clear page
    db $EF,$EE                     ; $688A  newline
    db $28,$26                     ; $688C  おう  (speaker: おう)
    db $96                         ; $688E  end name/box tag
    db $42,$26                     ; $688F  ほう
    db $8F                         ; $6891  。
    db $90                         ; $6892  　(space)
    db $60,$66,$8D,$74,$3A         ; $6893  カシ゛ノに = カジノに
    db $90                         ; $6898  　(space)
    db $25,$36,$33,$3D,$29         ; $6899  いったのか
    db $8F                         ; $689E  。
    db $EF,$EE                     ; $689F  newline
    db $90,$90                     ; $68A1  　　(indent)
    db $32,$39,$33,$3E             ; $68A3  そなたは
    db $90                         ; $68A7  　(space)
    db $25,$2B,$4E,$47,$26,$2C,$33,$3D,$2F,$8D,$49; $68A8  いくらもうけたのし゛ゃ = いくらもうけたのじゃ
    db $98                         ; $68B3  ？
    db $FA                         ; $68B4  wait-for-button
    db $F7                         ; $68B5  clear page
    db $EF,$EE                     ; $68B6  newline
    db $28,$26                     ; $68B8  おう  (speaker: おう)
    db $96                         ; $68BA  end name/box tag
    db $43,$47,$3D,$64,$8D,$9C,$87,$6F,$8D; $68BB  まものコ゛ールト゛ = まものゴールド
    db $98                         ; $68C4  ？
    db $90                         ; $68C5  　(space)
    db $32,$55,$39,$47,$3D         ; $68C6  そんなもの
    db $EF,$EE                     ; $68CB  newline
    db $90,$90                     ; $68CD  　　(indent)
    db $2D,$2D,$37,$8D,$3E         ; $68CF  ここて゛は = ここでは
    db $90                         ; $68D4  　(space)
    db $48,$2B,$3A,$33,$33,$55     ; $68D5  やくにたたん
    db $99                         ; $68DB  ！
    db $99                         ; $68DC  ！
    db $F7                         ; $68DD  clear page
    db $F0                         ; $68DE  end of message


; --------------------------------------------------------------------------
; Message #93 ($68DF)
;   「こっちに　やせいの　まものが
;   すんでいないのは　わけがあるよ。
;   「ずーっと　むかし　わたぼうの
;   ごせんぞさまが、
;   「にんげんに　わるさする　まものを
;   たびのとびらに　とじこめたんだ。
;   「そのかわり　ごせんぞさまは
;   あることを　われわれにめいじた。
;   「ほしふりのよるが　くるたびに
;   かくとうたいかいを　ひらくこと！
;   「ホントか　ゥソか　わからないけど
;   だから　たいかいは　あるんだよ。
; --------------------------------------------------------------------------
Bank68_Msg93:                              ; $68DF  (file $1128DF)
    db $EB                         ; $68DF  ▶ new page
    db $9F                         ; $68E0  box tag
    db $96                         ; $68E1  end name/box tag
    db $2D,$36,$34,$3A             ; $68E2  こっちに
    db $90                         ; $68E6  　(space)
    db $48,$31,$25,$3D             ; $68E7  やせいの
    db $90                         ; $68EB  　(space)
    db $43,$47,$3D,$29,$8D         ; $68EC  まものか゛ = まものが
    db $EF,$EE                     ; $68F1  newline
    db $90,$90                     ; $68F3  　　(indent)
    db $30,$55,$37,$8D,$25,$39,$25,$3D,$3E; $68F5  すんて゛いないのは = すんでいないのは
    db $90                         ; $68FE  　(space)
    db $53,$2C,$29,$8D,$24,$50,$4C ; $68FF  わけか゛あるよ = わけがあるよ
    db $8F                         ; $6906  。
    db $FA                         ; $6907  wait-for-button
    db $F7                         ; $6908  clear page
    db $EF,$EE                     ; $6909  newline
    db $9F                         ; $690B  box tag
    db $96                         ; $690C  end name/box tag
    db $30,$8D,$9C,$36,$38         ; $690D  す゛ーっと = ずーっと
    db $90                         ; $6912  　(space)
    db $45,$29,$2F                 ; $6913  むかし
    db $90                         ; $6916  　(space)
    db $53,$33,$42,$8D,$26,$3D     ; $6917  わたほ゛うの = わたぼうの
    db $EF,$EE                     ; $691D  newline
    db $90,$90                     ; $691F  　　(indent)
    db $2D,$8D,$31,$55,$32,$8D,$2E,$43,$29,$8D; $6921  こ゛せんそ゛さまか゛ = ごせんぞさまが
    db $A4                         ; $692B  、
    db $FA                         ; $692C  wait-for-button
    db $F7                         ; $692D  clear page
    db $EF,$EE                     ; $692E  newline
    db $9F                         ; $6930  box tag
    db $96                         ; $6931  end name/box tag
    db $3A,$55,$2C,$8D,$55,$3A     ; $6932  にんけ゛んに = にんげんに
    db $90                         ; $6938  　(space)
    db $53,$50,$2E,$30,$50         ; $6939  わるさする
    db $90                         ; $693E  　(space)
    db $43,$47,$3D,$54             ; $693F  まものを
    db $EF,$EE                     ; $6943  newline
    db $90,$90                     ; $6945  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A; $6947  たひ゛のとひ゛らに = たびのとびらに
    db $90                         ; $6950  　(space)
    db $38,$2F,$8D,$2D,$46,$33,$55,$33,$8D; $6951  とし゛こめたんた゛ = とじこめたんだ
    db $8F                         ; $695A  。
    db $FA                         ; $695B  wait-for-button
    db $F7                         ; $695C  clear page
    db $EF,$EE                     ; $695D  newline
    db $9F                         ; $695F  box tag
    db $96                         ; $6960  end name/box tag
    db $32,$3D,$29,$53,$4F         ; $6961  そのかわり
    db $90                         ; $6966  　(space)
    db $2D,$8D,$31,$55,$32,$8D,$2E,$43,$3E; $6967  こ゛せんそ゛さまは = ごせんぞさまは
    db $EF,$EE                     ; $6970  newline
    db $90,$90                     ; $6972  　　(indent)
    db $24,$50,$2D,$38,$54         ; $6974  あることを
    db $90                         ; $6979  　(space)
    db $53,$51,$53,$51,$3A,$46,$25,$2F,$8D,$33; $697A  われわれにめいし゛た = われわれにめいじた
    db $8F                         ; $6984  。
    db $FA                         ; $6985  wait-for-button
    db $F7                         ; $6986  clear page
    db $EF,$EE                     ; $6987  newline
    db $9F                         ; $6989  box tag
    db $96                         ; $698A  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$29,$8D; $698B  ほしふりのよるか゛ = ほしふりのよるが
    db $90                         ; $6994  　(space)
    db $2B,$50,$33,$3F,$8D,$3A     ; $6995  くるたひ゛に = くるたびに
    db $EF,$EE                     ; $699B  newline
    db $90,$90                     ; $699D  　　(indent)
    db $29,$2B,$38,$26,$33,$25,$29,$25,$54; $699F  かくとうたいかいを
    db $90                         ; $69A8  　(space)
    db $3F,$4E,$2B,$2D,$38         ; $69A9  ひらくこと
    db $99                         ; $69AE  ！
    db $FA                         ; $69AF  wait-for-button
    db $F7                         ; $69B0  clear page
    db $EF,$EE                     ; $69B1  newline
    db $9F                         ; $69B3  box tag
    db $96                         ; $69B4  end name/box tag
    db $79,$8C,$6F,$29             ; $69B5  ホントか
    db $90                         ; $69B9  　(space)
    db $5A,$69,$29                 ; $69BA  ゥソか
    db $90                         ; $69BD  　(space)
    db $53,$29,$4E,$39,$25,$2C,$38,$8D; $69BE  わからないけと゛ = わからないけど
    db $EF,$EE                     ; $69C6  newline
    db $90,$90                     ; $69C8  　　(indent)
    db $33,$8D,$29,$4E             ; $69CA  た゛から = だから
    db $90                         ; $69CE  　(space)
    db $33,$25,$29,$25,$3E         ; $69CF  たいかいは
    db $90                         ; $69D4  　(space)
    db $24,$50,$55,$33,$8D,$4C     ; $69D5  あるんた゛よ = あるんだよ
    db $8F                         ; $69DB  。
    db $F7                         ; $69DC  clear page
    db $F0                         ; $69DD  end of message


; --------------------------------------------------------------------------
; Message #94 ($69DE)
;   「ここは　タィジャの　おしろです。
;   「したに　すすんで　そとにでれば
;   タィジャのまち　ですよ。
;   「ほしふりのほこらは　まちにでて
;   ずっと　したまでいくとあります。
; --------------------------------------------------------------------------
Bank68_Msg94:                              ; $69DE  (file $1129DE)
    db $EA                         ; $69DE  ▶ new page
    db $9F                         ; $69DF  box tag
    db $96                         ; $69E0  end name/box tag
    db $2D,$2D,$3E                 ; $69E1  ここは
    db $90                         ; $69E4  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $69E5  タィシ゛ャの = タィジャの
    db $90                         ; $69EB  　(space)
    db $28,$2F,$52,$37,$8D,$30     ; $69EC  おしろて゛す = おしろです
    db $8F                         ; $69F2  。
    db $EF,$EE                     ; $69F3  newline
    db $FA                         ; $69F5  wait-for-button
    db $F7                         ; $69F6  clear page
    db $EF,$EE                     ; $69F7  newline
    db $F3                         ; $69F9  open text box
    db $9F                         ; $69FA  box tag
    db $96                         ; $69FB  end name/box tag
    db $2F,$33,$3A                 ; $69FC  したに
    db $90                         ; $69FF  　(space)
    db $30,$30,$55,$37,$8D         ; $6A00  すすんて゛ = すすんで
    db $90                         ; $6A05  　(space)
    db $32,$38,$3A,$37,$8D,$51,$3E,$8D; $6A06  そとにて゛れは゛ = そとにでれば
    db $EF,$EE                     ; $6A0E  newline
    db $90,$90                     ; $6A10  　　(indent)
    db $6A,$58,$66,$8D,$82,$3D,$43,$34; $6A12  タィシ゛ャのまち = タィジャのまち
    db $90                         ; $6A1A  　(space)
    db $37,$8D,$30,$4C             ; $6A1B  て゛すよ = ですよ
    db $8F                         ; $6A1F  。
    db $FA                         ; $6A20  wait-for-button
    db $F7                         ; $6A21  clear page
    db $EF,$EE                     ; $6A22  newline
    db $9F                         ; $6A24  box tag
    db $96                         ; $6A25  end name/box tag
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$3E; $6A26  ほしふりのほこらは
    db $90                         ; $6A2F  　(space)
    db $43,$34,$3A,$37,$8D,$37     ; $6A30  まちにて゛て = まちにでて
    db $EF,$EE                     ; $6A36  newline
    db $90,$90                     ; $6A38  　　(indent)
    db $30,$8D,$36,$38             ; $6A3A  す゛っと = ずっと
    db $90                         ; $6A3E  　(space)
    db $2F,$33,$43,$37,$8D,$25,$2B,$38,$24,$4F,$43,$30; $6A3F  したまて゛いくとあります = したまでいくとあります
    db $8F                         ; $6A4B  。
    db $F7                         ; $6A4C  clear page
    db $F0                         ; $6A4D  end of message


; --------------------------------------------------------------------------
; Message #95 ($6A4E)
;   「ほしふりのよるに　ほしたちに
;   ねがいごとを　すれば、
;   「そのねがいは　ききとどけられる
;   そうです、、。
; --------------------------------------------------------------------------
Bank68_Msg95:                              ; $6A4E  (file $112A4E)
    db $EB                         ; $6A4E  ▶ new page
    db $9F                         ; $6A4F  box tag
    db $96                         ; $6A50  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A; $6A51  ほしふりのよるに
    db $90                         ; $6A59  　(space)
    db $42,$2F,$33,$34,$3A         ; $6A5A  ほしたちに
    db $EF,$EE                     ; $6A5F  newline
    db $90,$90                     ; $6A61  　　(indent)
    db $3C,$29,$8D,$25,$2D,$8D,$38,$54; $6A63  ねか゛いこ゛とを = ねがいごとを
    db $90                         ; $6A6B  　(space)
    db $30,$51,$3E,$8D             ; $6A6C  すれは゛ = すれば
    db $A4                         ; $6A70  、
    db $FA                         ; $6A71  wait-for-button
    db $F7                         ; $6A72  clear page
    db $EF,$EE                     ; $6A73  newline
    db $9F                         ; $6A75  box tag
    db $96                         ; $6A76  end name/box tag
    db $32,$3D,$3C,$29,$8D,$25,$3E ; $6A77  そのねか゛いは = そのねがいは
    db $90                         ; $6A7E  　(space)
    db $2A,$2A,$38,$38,$8D,$2C,$4E,$51,$50; $6A7F  ききとと゛けられる = ききとどけられる
    db $EF,$EE                     ; $6A88  newline
    db $90,$90                     ; $6A8A  　　(indent)
    db $32,$26,$37,$8D,$30         ; $6A8C  そうて゛す = そうです
    db $A4                         ; $6A91  、
    db $A4                         ; $6A92  、
    db $8F                         ; $6A93  。
    db $F7                         ; $6A94  clear page
    db $F0                         ; $6A95  end of message


; --------------------------------------------------------------------------
; Message #96 ($6A96)
;   「タィジャに　いちばん　ちかいのは
;   マルタのくにです。
;   「つよいマスターが　あのくにには
;   たくさん　いるんですよ。
; --------------------------------------------------------------------------
Bank68_Msg96:                              ; $6A96  (file $112A96)
    db $EB                         ; $6A96  ▶ new page
    db $9F                         ; $6A97  box tag
    db $96                         ; $6A98  end name/box tag
    db $6A,$58,$66,$8D,$82,$3A     ; $6A99  タィシ゛ャに = タィジャに
    db $90                         ; $6A9F  　(space)
    db $25,$34,$3E,$8D,$55         ; $6AA0  いちは゛ん = いちばん
    db $90                         ; $6AA5  　(space)
    db $34,$29,$25,$3D,$3E         ; $6AA6  ちかいのは
    db $EF,$EE                     ; $6AAB  newline
    db $90,$90                     ; $6AAD  　　(indent)
    db $7A,$87,$6A,$3D,$2B,$3A,$37,$8D,$30; $6AAF  マルタのくにて゛す = マルタのくにです
    db $8F                         ; $6AB8  。
    db $FA                         ; $6AB9  wait-for-button
    db $F7                         ; $6ABA  clear page
    db $EF,$EE                     ; $6ABB  newline
    db $9F                         ; $6ABD  box tag
    db $96                         ; $6ABE  end name/box tag
    db $35,$4C,$25,$7A,$67,$6A,$9C,$29,$8D; $6ABF  つよいマスターか゛ = つよいマスターが
    db $90                         ; $6AC8  　(space)
    db $24,$3D,$2B,$3A,$3A,$3E     ; $6AC9  あのくにには
    db $EF,$EE                     ; $6ACF  newline
    db $90,$90                     ; $6AD1  　　(indent)
    db $33,$2B,$2E,$55             ; $6AD3  たくさん
    db $90                         ; $6AD7  　(space)
    db $25,$50,$55,$37,$8D,$30,$4C ; $6AD8  いるんて゛すよ = いるんですよ
    db $8F                         ; $6ADF  。
    db $F7                         ; $6AE0  clear page
    db $F0                         ; $6AE1  end of message


; --------------------------------------------------------------------------
; Message #97 ($6AE2)
;   「おまえ　いつまでたっても
;   よっわいな[91]！
;   「そんなんで　ほしふりのよるに
;   まにあうのかよ[95]？
; --------------------------------------------------------------------------
Bank68_Msg97:                              ; $6AE2  (file $112AE2)
    db $EB                         ; $6AE2  ▶ new page
    db $9F                         ; $6AE3  box tag
    db $96                         ; $6AE4  end name/box tag
    db $28,$43,$27                 ; $6AE5  おまえ
    db $90                         ; $6AE8  　(space)
    db $25,$35,$43,$37,$8D,$33,$36,$37,$47; $6AE9  いつまて゛たっても = いつまでたっても
    db $EF,$EE                     ; $6AF2  newline
    db $90,$90                     ; $6AF4  　　(indent)
    db $4C,$36,$53,$25,$39         ; $6AF6  よっわいな
    db $91                         ; $6AFB  ctrl $91
    db $99                         ; $6AFC  ！
    db $FA                         ; $6AFD  wait-for-button
    db $F7                         ; $6AFE  clear page
    db $EF,$EE                     ; $6AFF  newline
    db $9F                         ; $6B01  box tag
    db $96                         ; $6B02  end name/box tag
    db $32,$55,$39,$55,$37,$8D     ; $6B03  そんなんて゛ = そんなんで
    db $90                         ; $6B09  　(space)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A; $6B0A  ほしふりのよるに
    db $EF,$EE                     ; $6B12  newline
    db $90,$90                     ; $6B14  　　(indent)
    db $43,$3A,$24,$26,$3D,$29,$4C ; $6B16  まにあうのかよ
    db $95                         ; $6B1D  ctrl $95
    db $98                         ; $6B1E  ？
    db $F7                         ; $6B1F  clear page
    db $F0                         ; $6B20  end of message


; --------------------------------------------------------------------------
; Message #98 ($6B21)
;   「マルタのくにの　せいれいのなまえ
;   しってる？
;   「ワルぼう　っていう
;   なまえだそうよ。
; --------------------------------------------------------------------------
Bank68_Msg98:                              ; $6B21  (file $112B21)
    db $EB                         ; $6B21  ▶ new page
    db $9F                         ; $6B22  box tag
    db $96                         ; $6B23  end name/box tag
    db $7A,$87,$6A,$3D,$2B,$3A,$3D ; $6B24  マルタのくにの
    db $90                         ; $6B2B  　(space)
    db $31,$25,$51,$25,$3D,$39,$43,$27; $6B2C  せいれいのなまえ
    db $EF,$EE                     ; $6B34  newline
    db $90,$90                     ; $6B36  　　(indent)
    db $2F,$36,$37,$50             ; $6B38  しってる
    db $98                         ; $6B3C  ？
    db $FA                         ; $6B3D  wait-for-button
    db $F7                         ; $6B3E  clear page
    db $EF,$EE                     ; $6B3F  newline
    db $9F                         ; $6B41  box tag
    db $96                         ; $6B42  end name/box tag
    db $8A,$87,$42,$8D,$26         ; $6B43  ワルほ゛う = ワルぼう
    db $90                         ; $6B48  　(space)
    db $36,$37,$25,$26             ; $6B49  っていう
    db $EF,$EE                     ; $6B4D  newline
    db $90,$90                     ; $6B4F  　　(indent)
    db $39,$43,$27,$33,$8D,$32,$26,$4C; $6B51  なまえた゛そうよ = なまえだそうよ
    db $8F                         ; $6B59  。
    db $F7                         ; $6B5A  clear page
    db $F0                         ; $6B5B  end of message


; --------------------------------------------------------------------------
; Message #99 ($6B5C)
;   「ワルぼう？
;   ぷっ　へんな　なまえ！
; --------------------------------------------------------------------------
Bank68_Msg99:                              ; $6B5C  (file $112B5C)
    db $EB                         ; $6B5C  ▶ new page
    db $9F                         ; $6B5D  box tag
    db $96                         ; $6B5E  end name/box tag
    db $8A,$87,$42,$8D,$26         ; $6B5F  ワルほ゛う = ワルぼう
    db $98                         ; $6B64  ？
    db $EF,$EE                     ; $6B65  newline
    db $90,$90                     ; $6B67  　　(indent)
    db $40,$8E,$36                 ; $6B69  ふ゜っ = ぷっ
    db $90                         ; $6B6C  　(space)
    db $41,$55,$39                 ; $6B6D  へんな
    db $90                         ; $6B70  　(space)
    db $39,$43,$27                 ; $6B71  なまえ
    db $99                         ; $6B74  ！
    db $F7                         ; $6B75  clear page
    db $F0                         ; $6B76  end of message


; --------------------------------------------------------------------------
; Message #100 ($6B77)
;   「まっ！
;   おくさん　だいじょうぶかしら？
; --------------------------------------------------------------------------
Bank68_Msg100:                             ; $6B77  (file $112B77)
    db $EB                         ; $6B77  ▶ new page
    db $9F                         ; $6B78  box tag
    db $96                         ; $6B79  end name/box tag
    db $43,$36                     ; $6B7A  まっ
    db $99                         ; $6B7C  ！
    db $EF,$EE                     ; $6B7D  newline
    db $90,$90                     ; $6B7F  　　(indent)
    db $28,$2B,$2E,$55             ; $6B81  おくさん
    db $90                         ; $6B85  　(space)
    db $33,$8D,$25,$2F,$8D,$4D,$26,$40,$8D,$29,$2F,$4E; $6B86  た゛いし゛ょうふ゛かしら = だいじょうぶかしら
    db $98                         ; $6B92  ？
    db $F7                         ; $6B93  clear page
    db $F0                         ; $6B94  end of message


; --------------------------------------------------------------------------
; Message #101 ($6B95)
;   「マルタのくにの　せいれいは
;   ワルぼうっていう　なまえよ。
;   「このくにの　わたぼうとは
;   なかが　わるいらしいわ！
; --------------------------------------------------------------------------
Bank68_Msg101:                             ; $6B95  (file $112B95)
    db $EB                         ; $6B95  ▶ new page
    db $9F                         ; $6B96  box tag
    db $96                         ; $6B97  end name/box tag
    db $7A,$87,$6A,$3D,$2B,$3A,$3D ; $6B98  マルタのくにの
    db $90                         ; $6B9F  　(space)
    db $31,$25,$51,$25,$3E         ; $6BA0  せいれいは
    db $EF,$EE                     ; $6BA5  newline
    db $90,$90                     ; $6BA7  　　(indent)
    db $8A,$87,$42,$8D,$26,$36,$37,$25,$26; $6BA9  ワルほ゛うっていう = ワルぼうっていう
    db $90                         ; $6BB2  　(space)
    db $39,$43,$27,$4C             ; $6BB3  なまえよ
    db $8F                         ; $6BB7  。
    db $FA                         ; $6BB8  wait-for-button
    db $F7                         ; $6BB9  clear page
    db $EF,$EE                     ; $6BBA  newline
    db $9F                         ; $6BBC  box tag
    db $96                         ; $6BBD  end name/box tag
    db $2D,$3D,$2B,$3A,$3D         ; $6BBE  このくにの
    db $90                         ; $6BC3  　(space)
    db $53,$33,$42,$8D,$26,$38,$3E ; $6BC4  わたほ゛うとは = わたぼうとは
    db $EF,$EE                     ; $6BCB  newline
    db $90,$90                     ; $6BCD  　　(indent)
    db $39,$29,$29,$8D             ; $6BCF  なかか゛ = なかが
    db $90                         ; $6BD3  　(space)
    db $53,$50,$25,$4E,$2F,$25,$53 ; $6BD4  わるいらしいわ
    db $99                         ; $6BDB  ！
    db $F7                         ; $6BDC  clear page
    db $F0                         ; $6BDD  end of message


; --------------------------------------------------------------------------
; Message #102 ($6BDE)
;   「ワルぼう、、。　わすれられない
;   なまえになりそうだわ、、。
; --------------------------------------------------------------------------
Bank68_Msg102:                             ; $6BDE  (file $112BDE)
    db $EB                         ; $6BDE  ▶ new page
    db $9F                         ; $6BDF  box tag
    db $96                         ; $6BE0  end name/box tag
    db $8A,$87,$42,$8D,$26         ; $6BE1  ワルほ゛う = ワルぼう
    db $A4                         ; $6BE6  、
    db $A4                         ; $6BE7  、
    db $8F                         ; $6BE8  。
    db $90                         ; $6BE9  　(space)
    db $53,$30,$51,$4E,$51,$39,$25 ; $6BEA  わすれられない
    db $EF,$EE                     ; $6BF1  newline
    db $90,$90                     ; $6BF3  　　(indent)
    db $39,$43,$27,$3A,$39,$4F,$32,$26,$33,$8D,$53; $6BF5  なまえになりそうた゛わ = なまえになりそうだわ
    db $A4                         ; $6C00  、
    db $A4                         ; $6C01  、
    db $8F                         ; $6C02  。
    db $F7                         ; $6C03  clear page
    db $F0                         ; $6C04  end of message


; --------------------------------------------------------------------------
; Message #103 ($6C05)
;   「タィジャが　せいちょうするとき
;   おおきな　じしんがおこるんだ。
;   「バザーかいじょうが　ひろくなれば
;   おみせも　ふえるだろうな。
; --------------------------------------------------------------------------
Bank68_Msg103:                             ; $6C05  (file $112C05)
    db $EA                         ; $6C05  ▶ new page
    db $9F                         ; $6C06  box tag
    db $96                         ; $6C07  end name/box tag
    db $6A,$58,$66,$8D,$82,$29,$8D ; $6C08  タィシ゛ャか゛ = タィジャが
    db $90                         ; $6C0F  　(space)
    db $31,$25,$34,$4D,$26,$30,$50,$38,$2A; $6C10  せいちょうするとき
    db $EF,$EE                     ; $6C19  newline
    db $90,$90                     ; $6C1B  　　(indent)
    db $28,$28,$2A,$39             ; $6C1D  おおきな
    db $90                         ; $6C21  　(space)
    db $2F,$8D,$2F,$55,$29,$8D,$28,$2D,$50,$55,$33,$8D; $6C22  し゛しんか゛おこるんた゛ = じしんがおこるんだ
    db $8F                         ; $6C2E  。
    db $FA                         ; $6C2F  wait-for-button
    db $F7                         ; $6C30  clear page
    db $EF,$EE                     ; $6C31  newline
    db $9F                         ; $6C33  box tag
    db $96                         ; $6C34  end name/box tag
    db $75,$8D,$65,$8D,$9C,$29,$25,$2F,$8D,$4D,$26,$29,$8D; $6C35  ハ゛サ゛ーかいし゛ょうか゛ = バザーかいじょうが
    db $90                         ; $6C42  　(space)
    db $3F,$52,$2B,$39,$51,$3E,$8D ; $6C43  ひろくなれは゛ = ひろくなれば
    db $EF,$EE                     ; $6C4A  newline
    db $90,$90                     ; $6C4C  　　(indent)
    db $28,$44,$31,$47             ; $6C4E  おみせも
    db $90                         ; $6C52  　(space)
    db $40,$27,$50,$33,$8D,$52,$26,$39; $6C53  ふえるた゛ろうな = ふえるだろうな
    db $8F                         ; $6C5B  。
    db $F7                         ; $6C5C  clear page
    db $F0                         ; $6C5D  end of message


; --------------------------------------------------------------------------
; Message #104 ($6C5E)
;   「よるな　よるな！
;   びんぼうにんは　おことわりだ！
; --------------------------------------------------------------------------
Bank68_Msg104:                             ; $6C5E  (file $112C5E)
    db $EA                         ; $6C5E  ▶ new page
    db $9F                         ; $6C5F  box tag
    db $96                         ; $6C60  end name/box tag
    db $4C,$50,$39                 ; $6C61  よるな
    db $90                         ; $6C64  　(space)
    db $4C,$50,$39                 ; $6C65  よるな
    db $99                         ; $6C68  ！
    db $EF,$EE                     ; $6C69  newline
    db $90,$90                     ; $6C6B  　　(indent)
    db $3F,$8D,$55,$42,$8D,$26,$3A,$55,$3E; $6C6D  ひ゛んほ゛うにんは = びんぼうにんは
    db $90                         ; $6C76  　(space)
    db $28,$2D,$38,$53,$4F,$33,$8D ; $6C77  おことわりた゛ = おことわりだ
    db $99                         ; $6C7E  ！
    db $F7                         ; $6C7F  clear page
    db $F0                         ; $6C80  end of message


; --------------------------------------------------------------------------
; Message #105 ($6C81)
;   「なんて　いやな　やろうだ
;   あの　しょうにん！
;   「うりたくないなら　みせなんて
;   たたんじまえ！
; --------------------------------------------------------------------------
Bank68_Msg105:                             ; $6C81  (file $112C81)
    db $EA                         ; $6C81  ▶ new page
    db $9F                         ; $6C82  box tag
    db $96                         ; $6C83  end name/box tag
    db $39,$55,$37                 ; $6C84  なんて
    db $90                         ; $6C87  　(space)
    db $25,$48,$39                 ; $6C88  いやな
    db $90                         ; $6C8B  　(space)
    db $48,$52,$26,$33,$8D         ; $6C8C  やろうた゛ = やろうだ
    db $EF,$EE                     ; $6C91  newline
    db $90,$90                     ; $6C93  　　(indent)
    db $24,$3D                     ; $6C95  あの
    db $90                         ; $6C97  　(space)
    db $2F,$4D,$26,$3A,$55         ; $6C98  しょうにん
    db $99                         ; $6C9D  ！
    db $FA                         ; $6C9E  wait-for-button
    db $F7                         ; $6C9F  clear page
    db $EF,$EE                     ; $6CA0  newline
    db $9F                         ; $6CA2  box tag
    db $96                         ; $6CA3  end name/box tag
    db $26,$4F,$33,$2B,$39,$25,$39,$4E; $6CA4  うりたくないなら
    db $90                         ; $6CAC  　(space)
    db $44,$31,$39,$55,$37         ; $6CAD  みせなんて
    db $EF,$EE                     ; $6CB2  newline
    db $90,$90                     ; $6CB4  　　(indent)
    db $33,$33,$55,$2F,$8D,$43,$27 ; $6CB6  たたんし゛まえ = たたんじまえ
    db $99                         ; $6CBD  ！
    db $F7                         ; $6CBE  clear page
    db $F0                         ; $6CBF  end of message


; --------------------------------------------------------------------------
; Message #106 ($6CC0)
;   「お[95]！　みえるぞい！　そなたの
;   まえに　たちはだかる　まものが！
;   「そやつの　いかりに　ふれたとき
;   たたかいは　さけられぬじゃろう。
; --------------------------------------------------------------------------
Bank68_Msg106:                             ; $6CC0  (file $112CC0)
    db $EB                         ; $6CC0  ▶ new page
    db $9F                         ; $6CC1  box tag
    db $96                         ; $6CC2  end name/box tag
    db $28                         ; $6CC3  お
    db $95                         ; $6CC4  ctrl $95
    db $99                         ; $6CC5  ！
    db $90                         ; $6CC6  　(space)
    db $44,$27,$50,$32,$8D,$25     ; $6CC7  みえるそ゛い = みえるぞい
    db $99                         ; $6CCD  ！
    db $90                         ; $6CCE  　(space)
    db $32,$39,$33,$3D             ; $6CCF  そなたの
    db $EF,$EE                     ; $6CD3  newline
    db $90,$90                     ; $6CD5  　　(indent)
    db $43,$27,$3A                 ; $6CD7  まえに
    db $90                         ; $6CDA  　(space)
    db $33,$34,$3E,$33,$8D,$29,$50 ; $6CDB  たちはた゛かる = たちはだかる
    db $90                         ; $6CE2  　(space)
    db $43,$47,$3D,$29,$8D         ; $6CE3  まものか゛ = まものが
    db $99                         ; $6CE8  ！
    db $FA                         ; $6CE9  wait-for-button
    db $F7                         ; $6CEA  clear page
    db $EF,$EE                     ; $6CEB  newline
    db $9F                         ; $6CED  box tag
    db $96                         ; $6CEE  end name/box tag
    db $32,$48,$35,$3D             ; $6CEF  そやつの
    db $90                         ; $6CF3  　(space)
    db $25,$29,$4F,$3A             ; $6CF4  いかりに
    db $90                         ; $6CF8  　(space)
    db $40,$51,$33,$38,$2A         ; $6CF9  ふれたとき
    db $EF,$EE                     ; $6CFE  newline
    db $90,$90                     ; $6D00  　　(indent)
    db $33,$33,$29,$25,$3E         ; $6D02  たたかいは
    db $90                         ; $6D07  　(space)
    db $2E,$2C,$4E,$51,$3B,$2F,$8D,$49,$52,$26; $6D08  さけられぬし゛ゃろう = さけられぬじゃろう
    db $8F                         ; $6D12  。
    db $F7                         ; $6D13  clear page
    db $F0                         ; $6D14  end of message


; --------------------------------------------------------------------------
; Message #107 ($6D15)
;   「やすらぎとゆうきのへやが
;   あたらしく　ひらかれましたよ！
; --------------------------------------------------------------------------
Bank68_Msg107:                             ; $6D15  (file $112D15)
    db $EA                         ; $6D15  ▶ new page
    db $9F                         ; $6D16  box tag
    db $96                         ; $6D17  end name/box tag
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48,$29,$8D; $6D18  やすらき゛とゆうきのへやか゛ = やすらぎとゆうきのへやが
    db $EF,$EE                     ; $6D26  newline
    db $90,$90                     ; $6D28  　　(indent)
    db $24,$33,$4E,$2F,$2B         ; $6D2A  あたらしく
    db $90                         ; $6D2F  　(space)
    db $3F,$4E,$29,$51,$43,$2F,$33,$4C; $6D30  ひらかれましたよ
    db $99                         ; $6D38  ！
    db $F7                         ; $6D39  clear page
    db $F0                         ; $6D3A  end of message


; --------------------------------------------------------------------------
; Message #108 ($6D3B)
;   「、なんだ。　いないのか。
;   どうか　ォレに　よきょうを！！
; --------------------------------------------------------------------------
Bank68_Msg108:                             ; $6D3B  (file $112D3B)
    db $EA                         ; $6D3B  ▶ new page
    db $9F                         ; $6D3C  box tag
    db $96                         ; $6D3D  end name/box tag
    db $A4                         ; $6D3E  、
    db $39,$55,$33,$8D             ; $6D3F  なんた゛ = なんだ
    db $8F                         ; $6D43  。
    db $90                         ; $6D44  　(space)
    db $25,$39,$25,$3D,$29         ; $6D45  いないのか
    db $8F                         ; $6D4A  。
    db $EF,$EE                     ; $6D4B  newline
    db $90,$90                     ; $6D4D  　　(indent)
    db $38,$8D,$26,$29             ; $6D4F  と゛うか = どうか
    db $90                         ; $6D53  　(space)
    db $5E,$88,$3A                 ; $6D54  ォレに
    db $90                         ; $6D57  　(space)
    db $4C,$2A,$4D,$26,$54         ; $6D58  よきょうを
    db $99                         ; $6D5D  ！
    db $99                         ; $6D5E  ！
    db $F7                         ; $6D5F  clear page
    db $F0                         ; $6D60  end of message


; --------------------------------------------------------------------------
; Message #109 ($6D61)
;   コチンッ！
;   〈テリー〉に　あたったフンは
;   かたかった。
; --------------------------------------------------------------------------
Bank68_Msg109:                             ; $6D61  (file $112D61)
    db $64,$6B,$8C,$6D             ; $6D61  コチンッ
    db $99                         ; $6D65  ！
    db $EF,$EE                     ; $6D66  newline
    db $FA                         ; $6D68  wait-for-button
    db $F7                         ; $6D69  clear page
    db $EF,$EE                     ; $6D6A  newline
    db $F3                         ; $6D6C  open text box
    db $F6                         ; $6D6D  «insert hero name»
    db $3A                         ; $6D6E  に
    db $90                         ; $6D6F  　(space)
    db $24,$33,$36,$33,$77,$8C,$3E ; $6D70  あたったフンは
    db $EF,$EE                     ; $6D77  newline
    db $29,$33,$29,$36,$33         ; $6D79  かたかった
    db $8F                         ; $6D7E  。
    db $F7                         ; $6D7F  clear page
    db $F0                         ; $6D80  end of message


; --------------------------------------------------------------------------
; Message #110 ($6D81)
;   「タマゴを　もっていくと　かんてい
;   してくれる　ひとがいるのだ。
; --------------------------------------------------------------------------
Bank68_Msg110:                             ; $6D81  (file $112D81)
    db $EA                         ; $6D81  ▶ new page
    db $9F                         ; $6D82  box tag
    db $96                         ; $6D83  end name/box tag
    db $6A,$7A,$64,$8D,$54         ; $6D84  タマコ゛を = タマゴを
    db $90                         ; $6D89  　(space)
    db $47,$36,$37,$25,$2B,$38     ; $6D8A  もっていくと
    db $90                         ; $6D90  　(space)
    db $29,$55,$37,$25             ; $6D91  かんてい
    db $EF,$EE                     ; $6D95  newline
    db $90,$90                     ; $6D97  　　(indent)
    db $2F,$37,$2B,$51,$50         ; $6D99  してくれる
    db $90                         ; $6D9E  　(space)
    db $3F,$38,$29,$8D,$25,$50,$3D,$33,$8D; $6D9F  ひとか゛いるのた゛ = ひとがいるのだ
    db $8F                         ; $6DA8  。
    db $F7                         ; $6DA9  clear page
    db $F0                         ; $6DAA  end of message


; --------------------------------------------------------------------------
; Message #111 ($6DAB)
;   「くさったにくは　くさってる！
;   たべたら　どくになるんだ。
;   「でも　くさっても　にくは　にく！
;   たべれば　ちょっと　うれしいな。
; --------------------------------------------------------------------------
Bank68_Msg111:                             ; $6DAB  (file $112DAB)
    db $EA                         ; $6DAB  ▶ new page
    db $9F                         ; $6DAC  box tag
    db $96                         ; $6DAD  end name/box tag
    db $2B,$2E,$36,$33,$3A,$2B,$3E ; $6DAE  くさったにくは
    db $90                         ; $6DB5  　(space)
    db $2B,$2E,$36,$37,$50         ; $6DB6  くさってる
    db $99                         ; $6DBB  ！
    db $EF,$EE                     ; $6DBC  newline
    db $90,$90                     ; $6DBE  　　(indent)
    db $33,$41,$8D,$33,$4E         ; $6DC0  たへ゛たら = たべたら
    db $90                         ; $6DC5  　(space)
    db $38,$8D,$2B,$3A,$39,$50,$55,$33,$8D; $6DC6  と゛くになるんた゛ = どくになるんだ
    db $8F                         ; $6DCF  。
    db $FA                         ; $6DD0  wait-for-button
    db $F7                         ; $6DD1  clear page
    db $EF,$EE                     ; $6DD2  newline
    db $9F                         ; $6DD4  box tag
    db $96                         ; $6DD5  end name/box tag
    db $37,$8D,$47                 ; $6DD6  て゛も = でも
    db $90                         ; $6DD9  　(space)
    db $2B,$2E,$36,$37,$47         ; $6DDA  くさっても
    db $90                         ; $6DDF  　(space)
    db $3A,$2B,$3E                 ; $6DE0  にくは
    db $90                         ; $6DE3  　(space)
    db $3A,$2B                     ; $6DE4  にく
    db $99                         ; $6DE6  ！
    db $EF,$EE                     ; $6DE7  newline
    db $90,$90                     ; $6DE9  　　(indent)
    db $33,$41,$8D,$51,$3E,$8D     ; $6DEB  たへ゛れは゛ = たべれば
    db $90                         ; $6DF1  　(space)
    db $34,$4D,$36,$38             ; $6DF2  ちょっと
    db $90                         ; $6DF6  　(space)
    db $26,$51,$2F,$25,$39         ; $6DF7  うれしいな
    db $8F                         ; $6DFC  。
    db $F7                         ; $6DFD  clear page
    db $F0                         ; $6DFE  end of message


; --------------------------------------------------------------------------
; Message #112 ($6DFF)
;   「ぼくたちはね。　いやなめいれいを
;   されると　はんこうしちゃうんだ。
;   「じぶんの　せいかくに　あった
;   めいれいを　してほしいな。
; --------------------------------------------------------------------------
Bank68_Msg112:                             ; $6DFF  (file $112DFF)
    db $EA                         ; $6DFF  ▶ new page
    db $9F                         ; $6E00  box tag
    db $96                         ; $6E01  end name/box tag
    db $42,$8D,$2B,$33,$34,$3E,$3C ; $6E02  ほ゛くたちはね = ぼくたちはね
    db $8F                         ; $6E09  。
    db $90                         ; $6E0A  　(space)
    db $25,$48,$39,$46,$25,$51,$25,$54; $6E0B  いやなめいれいを
    db $EF,$EE                     ; $6E13  newline
    db $90,$90                     ; $6E15  　　(indent)
    db $2E,$51,$50,$38             ; $6E17  されると
    db $90                         ; $6E1B  　(space)
    db $3E,$55,$2D,$26,$2F,$34,$49,$26,$55,$33,$8D; $6E1C  はんこうしちゃうんた゛ = はんこうしちゃうんだ
    db $8F                         ; $6E27  。
    db $FA                         ; $6E28  wait-for-button
    db $F7                         ; $6E29  clear page
    db $EF,$EE                     ; $6E2A  newline
    db $9F                         ; $6E2C  box tag
    db $96                         ; $6E2D  end name/box tag
    db $2F,$8D,$40,$8D,$55,$3D     ; $6E2E  し゛ふ゛んの = じぶんの
    db $90                         ; $6E34  　(space)
    db $31,$25,$29,$2B,$3A         ; $6E35  せいかくに
    db $90                         ; $6E3A  　(space)
    db $24,$36,$33                 ; $6E3B  あった
    db $EF,$EE                     ; $6E3E  newline
    db $90,$90                     ; $6E40  　　(indent)
    db $46,$25,$51,$25,$54         ; $6E42  めいれいを
    db $90                         ; $6E47  　(space)
    db $2F,$37,$42,$2F,$25,$39     ; $6E48  してほしいな
    db $8F                         ; $6E4E  。
    db $F7                         ; $6E4F  clear page
    db $F0                         ; $6E50  end of message


; --------------------------------------------------------------------------
; Message #113 ($6E51)
;   「ゆうきがあれば　こえられる
;   がけもあるけど、
;   「ゆうきがあっても　こえられない
;   ものも　あるのですよ！
; --------------------------------------------------------------------------
Bank68_Msg113:                             ; $6E51  (file $112E51)
    db $EA                         ; $6E51  ▶ new page
    db $9F                         ; $6E52  box tag
    db $96                         ; $6E53  end name/box tag
    db $4A,$26,$2A,$29,$8D,$24,$51,$3E,$8D; $6E54  ゆうきか゛あれは゛ = ゆうきがあれば
    db $90                         ; $6E5D  　(space)
    db $2D,$27,$4E,$51,$50         ; $6E5E  こえられる
    db $EF,$EE                     ; $6E63  newline
    db $90,$90                     ; $6E65  　　(indent)
    db $29,$8D,$2C,$47,$24,$50,$2C,$38,$8D; $6E67  か゛けもあるけと゛ = がけもあるけど
    db $A4                         ; $6E70  、
    db $FA                         ; $6E71  wait-for-button
    db $F7                         ; $6E72  clear page
    db $EF,$EE                     ; $6E73  newline
    db $9F                         ; $6E75  box tag
    db $96                         ; $6E76  end name/box tag
    db $4A,$26,$2A,$29,$8D,$24,$36,$37,$47; $6E77  ゆうきか゛あっても = ゆうきがあっても
    db $90                         ; $6E80  　(space)
    db $2D,$27,$4E,$51,$39,$25     ; $6E81  こえられない
    db $EF,$EE                     ; $6E87  newline
    db $90,$90                     ; $6E89  　　(indent)
    db $47,$3D,$47                 ; $6E8B  ものも
    db $90                         ; $6E8E  　(space)
    db $24,$50,$3D,$37,$8D,$30,$4C ; $6E8F  あるのて゛すよ = あるのですよ
    db $99                         ; $6E96  ！
    db $F7                         ; $6E97  clear page
    db $F0                         ; $6E98  end of message


; --------------------------------------------------------------------------
; Message #114 ($6E99)
;   「よう！　このしたは
;   モンスターぼくしゃ　だぜ。
;   「いろんな　まものが　いるから
;   はなせば　たのしいかもな！
; --------------------------------------------------------------------------
Bank68_Msg114:                             ; $6E99  (file $112E99)
    db $EA                         ; $6E99  ▶ new page
    db $9F                         ; $6E9A  box tag
    db $96                         ; $6E9B  end name/box tag
    db $4C,$26                     ; $6E9C  よう
    db $99                         ; $6E9E  ！
    db $90                         ; $6E9F  　(space)
    db $2D,$3D,$2F,$33,$3E         ; $6EA0  このしたは
    db $EF,$EE                     ; $6EA5  newline
    db $90,$90                     ; $6EA7  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$42,$8D,$2B,$2F,$49; $6EA9  モンスターほ゛くしゃ = モンスターぼくしゃ
    db $90                         ; $6EB3  　(space)
    db $33,$8D,$31,$8D             ; $6EB4  た゛せ゛ = だぜ
    db $8F                         ; $6EB8  。
    db $FA                         ; $6EB9  wait-for-button
    db $F7                         ; $6EBA  clear page
    db $EF,$EE                     ; $6EBB  newline
    db $9F                         ; $6EBD  box tag
    db $96                         ; $6EBE  end name/box tag
    db $25,$52,$55,$39             ; $6EBF  いろんな
    db $90                         ; $6EC3  　(space)
    db $43,$47,$3D,$29,$8D         ; $6EC4  まものか゛ = まものが
    db $90                         ; $6EC9  　(space)
    db $25,$50,$29,$4E             ; $6ECA  いるから
    db $EF,$EE                     ; $6ECE  newline
    db $90,$90                     ; $6ED0  　　(indent)
    db $3E,$39,$31,$3E,$8D         ; $6ED2  はなせは゛ = はなせば
    db $90                         ; $6ED7  　(space)
    db $33,$3D,$2F,$25,$29,$47,$39 ; $6ED8  たのしいかもな
    db $99                         ; $6EDF  ！
    db $F7                         ; $6EE0  clear page
    db $F0                         ; $6EE1  end of message


; --------------------------------------------------------------------------
; Message #115 ($6EE2)
;   「やあ！　モンスターマスターくん。
;   ここは　よくつれるよ！
;   「、といっても　はっぱに
;   ひっかかった　ガラクタだけどね。
; --------------------------------------------------------------------------
Bank68_Msg115:                             ; $6EE2  (file $112EE2)
    db $EA                         ; $6EE2  ▶ new page
    db $9F                         ; $6EE3  box tag
    db $96                         ; $6EE4  end name/box tag
    db $48,$24                     ; $6EE5  やあ
    db $99                         ; $6EE7  ！
    db $90                         ; $6EE8  　(space)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$2B,$55; $6EE9  モンスターマスターくん
    db $8F                         ; $6EF4  。
    db $EF,$EE                     ; $6EF5  newline
    db $90,$90                     ; $6EF7  　　(indent)
    db $2D,$2D,$3E                 ; $6EF9  ここは
    db $90                         ; $6EFC  　(space)
    db $4C,$2B,$35,$51,$50,$4C     ; $6EFD  よくつれるよ
    db $99                         ; $6F03  ！
    db $FA                         ; $6F04  wait-for-button
    db $F7                         ; $6F05  clear page
    db $EF,$EE                     ; $6F06  newline
    db $9F                         ; $6F08  box tag
    db $96                         ; $6F09  end name/box tag
    db $A4                         ; $6F0A  、
    db $38,$25,$36,$37,$47         ; $6F0B  といっても
    db $90                         ; $6F10  　(space)
    db $3E,$36,$3E,$8E,$3A         ; $6F11  はっは゜に = はっぱに
    db $EF,$EE                     ; $6F16  newline
    db $90,$90                     ; $6F18  　　(indent)
    db $3F,$36,$29,$29,$36,$33     ; $6F1A  ひっかかった
    db $90                         ; $6F20  　(space)
    db $60,$8D,$85,$62,$6A,$33,$8D,$2C,$38,$8D,$3C; $6F21  カ゛ラクタた゛けと゛ね = ガラクタだけどね
    db $8F                         ; $6F2C  。
    db $F7                         ; $6F2D  clear page
    db $F0                         ; $6F2E  end of message


; --------------------------------------------------------------------------
; Message #116 ($6F2F)
;   「ここは　モンスター
;   ぼくじょうだよ。
;   「ひだりに　いくと　ぼくしゃへ
;   いける　かいだんが　あるよ。
;   「あずけられている　まものは
;   そこで　ねむるんだ！
; --------------------------------------------------------------------------
Bank68_Msg116:                             ; $6F2F  (file $112F2F)
    db $EB                         ; $6F2F  ▶ new page
    db $9F                         ; $6F30  box tag
    db $96                         ; $6F31  end name/box tag
    db $2D,$2D,$3E                 ; $6F32  ここは
    db $90                         ; $6F35  　(space)
    db $7E,$8C,$67,$6A,$9C         ; $6F36  モンスター
    db $EF,$EE                     ; $6F3B  newline
    db $90,$90                     ; $6F3D  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$33,$8D,$4C; $6F3F  ほ゛くし゛ょうた゛よ = ぼくじょうだよ
    db $8F                         ; $6F49  。
    db $FA                         ; $6F4A  wait-for-button
    db $F7                         ; $6F4B  clear page
    db $EF,$EE                     ; $6F4C  newline
    db $9F                         ; $6F4E  box tag
    db $96                         ; $6F4F  end name/box tag
    db $3F,$33,$8D,$4F,$3A         ; $6F50  ひた゛りに = ひだりに
    db $90                         ; $6F55  　(space)
    db $25,$2B,$38                 ; $6F56  いくと
    db $90                         ; $6F59  　(space)
    db $42,$8D,$2B,$2F,$49,$41     ; $6F5A  ほ゛くしゃへ = ぼくしゃへ
    db $EF,$EE                     ; $6F60  newline
    db $90,$90                     ; $6F62  　　(indent)
    db $25,$2C,$50                 ; $6F64  いける
    db $90                         ; $6F67  　(space)
    db $29,$25,$33,$8D,$55,$29,$8D ; $6F68  かいた゛んか゛ = かいだんが
    db $90                         ; $6F6F  　(space)
    db $24,$50,$4C                 ; $6F70  あるよ
    db $8F                         ; $6F73  。
    db $FA                         ; $6F74  wait-for-button
    db $F7                         ; $6F75  clear page
    db $EF,$EE                     ; $6F76  newline
    db $9F                         ; $6F78  box tag
    db $96                         ; $6F79  end name/box tag
    db $24,$30,$8D,$2C,$4E,$51,$37,$25,$50; $6F7A  あす゛けられている = あずけられている
    db $90                         ; $6F83  　(space)
    db $43,$47,$3D,$3E             ; $6F84  まものは
    db $EF,$EE                     ; $6F88  newline
    db $90,$90                     ; $6F8A  　　(indent)
    db $32,$2D,$37,$8D             ; $6F8C  そこて゛ = そこで
    db $90                         ; $6F90  　(space)
    db $3C,$45,$50,$55,$33,$8D     ; $6F91  ねむるんた゛ = ねむるんだ
    db $99                         ; $6F97  ！
    db $F7                         ; $6F98  clear page
    db $F0                         ; $6F99  end of message


; --------------------------------------------------------------------------
; Message #117 ($6F9A)
;   「このくにの　いたるところに
;   たびのとびらが　かくれているぞ。
; --------------------------------------------------------------------------
Bank68_Msg117:                             ; $6F9A  (file $112F9A)
    db $EB                         ; $6F9A  ▶ new page
    db $9F                         ; $6F9B  box tag
    db $96                         ; $6F9C  end name/box tag
    db $2D,$3D,$2B,$3A,$3D         ; $6F9D  このくにの
    db $90                         ; $6FA2  　(space)
    db $25,$33,$50,$38,$2D,$52,$3A ; $6FA3  いたるところに
    db $EF,$EE                     ; $6FAA  newline
    db $90,$90                     ; $6FAC  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $6FAE  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $6FB8  　(space)
    db $29,$2B,$51,$37,$25,$50,$32,$8D; $6FB9  かくれているそ゛ = かくれているぞ
    db $8F                         ; $6FC1  。
    db $F7                         ; $6FC2  clear page
    db $F0                         ; $6FC3  end of message


; --------------------------------------------------------------------------
; Message #118 ($6FC4)
;   「ねえ　マスターさん。
;   メタルぎりって　しってる？
;   「かたい　まものに
;   すっごく　きくらしいよ。
;   「アントベアさんが
;   おぼえられるんだって！
; --------------------------------------------------------------------------
Bank68_Msg118:                             ; $6FC4  (file $112FC4)
    db $EB                         ; $6FC4  ▶ new page
    db $9F                         ; $6FC5  box tag
    db $96                         ; $6FC6  end name/box tag
    db $3C,$27                     ; $6FC7  ねえ
    db $90                         ; $6FC9  　(space)
    db $7A,$67,$6A,$9C,$2E,$55     ; $6FCA  マスターさん
    db $8F                         ; $6FD0  。
    db $EF,$EE                     ; $6FD1  newline
    db $90,$90                     ; $6FD3  　　(indent)
    db $7D,$6A,$87,$2A,$8D,$4F,$36,$37; $6FD5  メタルき゛りって = メタルぎりって
    db $90                         ; $6FDD  　(space)
    db $2F,$36,$37,$50             ; $6FDE  しってる
    db $98                         ; $6FE2  ？
    db $FA                         ; $6FE3  wait-for-button
    db $F7                         ; $6FE4  clear page
    db $EF,$EE                     ; $6FE5  newline
    db $9F                         ; $6FE7  box tag
    db $96                         ; $6FE8  end name/box tag
    db $29,$33,$25                 ; $6FE9  かたい
    db $90                         ; $6FEC  　(space)
    db $43,$47,$3D,$3A             ; $6FED  まものに
    db $EF,$EE                     ; $6FF1  newline
    db $90,$90                     ; $6FF3  　　(indent)
    db $30,$36,$2D,$8D,$2B         ; $6FF5  すっこ゛く = すっごく
    db $90                         ; $6FFA  　(space)
    db $2A,$2B,$4E,$2F,$25,$4C     ; $6FFB  きくらしいよ
    db $8F                         ; $7001  。
    db $FA                         ; $7002  wait-for-button
    db $F7                         ; $7003  clear page
    db $EF,$EE                     ; $7004  newline
    db $9F                         ; $7006  box tag
    db $96                         ; $7007  end name/box tag
    db $56,$8C,$6F,$78,$8D,$56,$2E,$55,$29,$8D; $7008  アントヘ゛アさんか゛ = アントベアさんが
    db $EF,$EE                     ; $7012  newline
    db $90,$90                     ; $7014  　　(indent)
    db $28,$42,$8D,$27,$4E,$51,$50,$55,$33,$8D,$36,$37; $7016  おほ゛えられるんた゛って = おぼえられるんだって
    db $99                         ; $7022  ！
    db $F7                         ; $7023  clear page
    db $F0                         ; $7024  end of message


; --------------------------------------------------------------------------
; Message #119 ($7025)
;   「おねえちゃん　ねむいよー！
;   はやく　いっしょに　ねようよー！
; --------------------------------------------------------------------------
Bank68_Msg119:                             ; $7025  (file $113025)
    db $EB                         ; $7025  ▶ new page
    db $9F                         ; $7026  box tag
    db $96                         ; $7027  end name/box tag
    db $28,$3C,$27,$34,$49,$55     ; $7028  おねえちゃん
    db $90                         ; $702E  　(space)
    db $3C,$45,$25,$4C,$9C         ; $702F  ねむいよー
    db $99                         ; $7034  ！
    db $EF,$EE                     ; $7035  newline
    db $90,$90                     ; $7037  　　(indent)
    db $3E,$48,$2B                 ; $7039  はやく
    db $90                         ; $703C  　(space)
    db $25,$36,$2F,$4D,$3A         ; $703D  いっしょに
    db $90                         ; $7042  　(space)
    db $3C,$4C,$26,$4C,$9C         ; $7043  ねようよー
    db $99                         ; $7048  ！
    db $F7                         ; $7049  clear page
    db $F0                         ; $704A  end of message


; --------------------------------------------------------------------------
; Message #120 ($704B)
;   「ビックアィくんって　ヒユドが
;   とくいなのよね[94]！
; --------------------------------------------------------------------------
Bank68_Msg120:                             ; $704B  (file $11304B)
    db $EB                         ; $704B  ▶ new page
    db $9F                         ; $704C  box tag
    db $96                         ; $704D  end name/box tag
    db $76,$8D,$6D,$62,$56,$58,$2B,$55,$36,$37; $704E  ヒ゛ックアィくんって = ビックアィくんって
    db $90                         ; $7058  　(space)
    db $76,$80,$6F,$8D,$29,$8D     ; $7059  ヒユト゛か゛ = ヒユドが
    db $EF,$EE                     ; $705F  newline
    db $90,$90                     ; $7061  　　(indent)
    db $38,$2B,$25,$39,$3D,$4C,$3C ; $7063  とくいなのよね
    db $94                         ; $706A  small kana
    db $99                         ; $706B  ！
    db $F7                         ; $706C  clear page
    db $F0                         ; $706D  end of message


; --------------------------------------------------------------------------
; Message #121 ($706E)
;   「わしゃあ　ここに　くらして
;   ながいんですじゃあ。
;   「だから　いろんなことを
;   しっとりもうすぞ。　たとえば、
;   「おなじ　まものでも　なまえの
;   よこの[A2]のかずが　おおいほど、
;   「より　つよく　そだつとかのう。
;   これは　きほんで　ごわすぞ。
; --------------------------------------------------------------------------
Bank68_Msg121:                             ; $706E  (file $11306E)
    db $EA                         ; $706E  ▶ new page
    db $9F                         ; $706F  box tag
    db $96                         ; $7070  end name/box tag
    db $53,$2F,$49,$24             ; $7071  わしゃあ
    db $90                         ; $7075  　(space)
    db $2D,$2D,$3A                 ; $7076  ここに
    db $90                         ; $7079  　(space)
    db $2B,$4E,$2F,$37             ; $707A  くらして
    db $EF,$EE                     ; $707E  newline
    db $90,$90                     ; $7080  　　(indent)
    db $39,$29,$8D,$25,$55,$37,$8D,$30,$2F,$8D,$49,$24; $7082  なか゛いんて゛すし゛ゃあ = ながいんですじゃあ
    db $8F                         ; $708E  。
    db $FA                         ; $708F  wait-for-button
    db $F7                         ; $7090  clear page
    db $EF,$EE                     ; $7091  newline
    db $9F                         ; $7093  box tag
    db $96                         ; $7094  end name/box tag
    db $33,$8D,$29,$4E             ; $7095  た゛から = だから
    db $90                         ; $7099  　(space)
    db $25,$52,$55,$39,$2D,$38,$54 ; $709A  いろんなことを
    db $EF,$EE                     ; $70A1  newline
    db $90,$90                     ; $70A3  　　(indent)
    db $2F,$36,$38,$4F,$47,$26,$30,$32,$8D; $70A5  しっとりもうすそ゛ = しっとりもうすぞ
    db $8F                         ; $70AE  。
    db $90                         ; $70AF  　(space)
    db $33,$38,$27,$3E,$8D         ; $70B0  たとえは゛ = たとえば
    db $A4                         ; $70B5  、
    db $FA                         ; $70B6  wait-for-button
    db $F7                         ; $70B7  clear page
    db $EF,$EE                     ; $70B8  newline
    db $9F                         ; $70BA  box tag
    db $96                         ; $70BB  end name/box tag
    db $28,$39,$2F,$8D             ; $70BC  おなし゛ = おなじ
    db $90                         ; $70C0  　(space)
    db $43,$47,$3D,$37,$8D,$47     ; $70C1  まものて゛も = まものでも
    db $90                         ; $70C7  　(space)
    db $39,$43,$27,$3D             ; $70C8  なまえの
    db $EF,$EE                     ; $70CC  newline
    db $90,$90                     ; $70CE  　　(indent)
    db $4C,$2D,$3D                 ; $70D0  よこの
    db $A2                         ; $70D3  ctrl $A2
    db $3D,$29,$30,$8D,$29,$8D     ; $70D4  のかす゛か゛ = のかずが
    db $90                         ; $70DA  　(space)
    db $28,$28,$25,$42,$38,$8D     ; $70DB  おおいほと゛ = おおいほど
    db $A4                         ; $70E1  、
    db $FA                         ; $70E2  wait-for-button
    db $F7                         ; $70E3  clear page
    db $EF,$EE                     ; $70E4  newline
    db $9F                         ; $70E6  box tag
    db $96                         ; $70E7  end name/box tag
    db $4C,$4F                     ; $70E8  より
    db $90                         ; $70EA  　(space)
    db $35,$4C,$2B                 ; $70EB  つよく
    db $90                         ; $70EE  　(space)
    db $32,$33,$8D,$35,$38,$29,$3D,$26; $70EF  そた゛つとかのう = そだつとかのう
    db $8F                         ; $70F7  。
    db $EF,$EE                     ; $70F8  newline
    db $90,$90                     ; $70FA  　　(indent)
    db $2D,$51,$3E                 ; $70FC  これは
    db $90                         ; $70FF  　(space)
    db $2A,$42,$55,$37,$8D         ; $7100  きほんて゛ = きほんで
    db $90                         ; $7105  　(space)
    db $2D,$8D,$53,$30,$32,$8D     ; $7106  こ゛わすそ゛ = ごわすぞ
    db $8F                         ; $710C  。
    db $F7                         ; $710D  clear page
    db $F0                         ; $710E  end of message


; --------------------------------------------------------------------------
; Message #122 ($710F)
;   わたほ゛う「ムシユ　ムシユ、、。
; --------------------------------------------------------------------------
Bank68_Msg122:                             ; $710F  (file $11310F)
    db $EB                         ; $710F  ▶ new page
    db $53,$33,$42,$8D,$26         ; $7110  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $7115  end name/box tag
    db $7C,$66,$80                 ; $7116  ムシユ
    db $90                         ; $7119  　(space)
    db $7C,$66,$80                 ; $711A  ムシユ
    db $A4                         ; $711D  、
    db $A4                         ; $711E  、
    db $8F                         ; $711F  。
    db $EF,$EE                     ; $7120  newline
    db $F7                         ; $7122  clear page
    db $F0                         ; $7123  end of message


; --------------------------------------------------------------------------
; Message #123 ($7124)
;   わたほ゛う「ガリ　ガリ、、。
; --------------------------------------------------------------------------
Bank68_Msg123:                             ; $7124  (file $113124)
    db $EB                         ; $7124  ▶ new page
    db $53,$33,$42,$8D,$26         ; $7125  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $712A  end name/box tag
    db $60,$8D,$86                 ; $712B  カ゛リ = ガリ
    db $90                         ; $712E  　(space)
    db $60,$8D,$86                 ; $712F  カ゛リ = ガリ
    db $A4                         ; $7132  、
    db $A4                         ; $7133  、
    db $8F                         ; $7134  。
    db $EF,$EE                     ; $7135  newline
    db $F7                         ; $7137  clear page
    db $F0                         ; $7138  end of message


; --------------------------------------------------------------------------
; Message #124 ($7139)
;   わたほ゛う「たべる？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg124:                             ; $7139  (file $113139)
    db $EB                         ; $7139  ▶ new page
    db $53,$33,$42,$8D,$26         ; $713A  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $713F  end name/box tag
    db $33,$41,$8D,$50             ; $7140  たへ゛る = たべる
    db $98                         ; $7144  ？
    db $EF,$EE                     ; $7145  newline
    db $FF                         ; $7147  はい/いいえ
    db $F0                         ; $7148  end of message


; --------------------------------------------------------------------------
; Message #125 ($7149)
;   〈テリー〉は　わたぼうに
;   たべのこしを　もらった！
;   〈テリー〉は
;   よろこんで　にくを　たべはじめた！
;   〈テリー〉は
;   すこし　わたぼうに　なついた！
; --------------------------------------------------------------------------
Bank68_Msg125:                             ; $7149  (file $113149)
    db $F6                         ; $7149  «insert hero name»
    db $3E                         ; $714A  は
    db $90                         ; $714B  　(space)
    db $53,$33,$42,$8D,$26,$3A     ; $714C  わたほ゛うに = わたぼうに
    db $EF,$EE                     ; $7152  newline
    db $33,$41,$8D,$3D,$2D,$2F,$54 ; $7154  たへ゛のこしを = たべのこしを
    db $90                         ; $715B  　(space)
    db $47,$4E,$36,$33             ; $715C  もらった
    db $99                         ; $7160  ！
    db $FA                         ; $7161  wait-for-button
    db $F7                         ; $7162  clear page
    db $EF,$EE                     ; $7163  newline
    db $F6                         ; $7165  «insert hero name»
    db $3E                         ; $7166  は
    db $EF,$EE                     ; $7167  newline
    db $4C,$52,$2D,$55,$37,$8D     ; $7169  よろこんて゛ = よろこんで
    db $90                         ; $716F  　(space)
    db $3A,$2B,$54                 ; $7170  にくを
    db $90                         ; $7173  　(space)
    db $33,$41,$8D,$3E,$2F,$8D,$46,$33; $7174  たへ゛はし゛めた = たべはじめた
    db $99                         ; $717C  ！
    db $FA                         ; $717D  wait-for-button
    db $F7                         ; $717E  clear page
    db $EF,$EE                     ; $717F  newline
    db $F6                         ; $7181  «insert hero name»
    db $3E                         ; $7182  は
    db $EF,$EE                     ; $7183  newline
    db $30,$2D,$2F                 ; $7185  すこし
    db $90                         ; $7188  　(space)
    db $53,$33,$42,$8D,$26,$3A     ; $7189  わたほ゛うに = わたぼうに
    db $90                         ; $718F  　(space)
    db $39,$35,$25,$33             ; $7190  なついた
    db $99                         ; $7194  ！
    db $F7                         ; $7195  clear page
    db $F0                         ; $7196  end of message


; --------------------------------------------------------------------------
; Message #126 ($7197)
;   わたほ゛う「ゆうしょう　してくれよ！
; --------------------------------------------------------------------------
Bank68_Msg126:                             ; $7197  (file $113197)
    db $EB                         ; $7197  ▶ new page
    db $53,$33,$42,$8D,$26         ; $7198  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $719D  end name/box tag
    db $4A,$26,$2F,$4D,$26         ; $719E  ゆうしょう
    db $90                         ; $71A3  　(space)
    db $2F,$37,$2B,$51,$4C         ; $71A4  してくれよ
    db $99                         ; $71A9  ！
    db $EF,$EE                     ; $71AA  newline
    db $F7                         ; $71AC  clear page
    db $F0                         ; $71AD  end of message


; --------------------------------------------------------------------------
; Message #127 ($71AE)
;   「わたくしの　あまいいきにかかれば
;   どんなまものだって　ねむるわよ。
;   「とくに　ドラゴンけいや
;   けものけい　なんかの、
;   「たんじゅんそうな　まものなら
;   おもしろいように　きまっちゃう！
; --------------------------------------------------------------------------
Bank68_Msg127:                             ; $71AE  (file $1131AE)
    db $EB                         ; $71AE  ▶ new page
    db $9F                         ; $71AF  box tag
    db $96                         ; $71B0  end name/box tag
    db $53,$33,$2B,$2F,$3D         ; $71B1  わたくしの
    db $90                         ; $71B6  　(space)
    db $24,$43,$25,$25,$2A,$3A,$29,$29,$51,$3E,$8D; $71B7  あまいいきにかかれは゛ = あまいいきにかかれば
    db $EF,$EE                     ; $71C2  newline
    db $90,$90                     ; $71C4  　　(indent)
    db $38,$8D,$55,$39,$43,$47,$3D,$33,$8D,$36,$37; $71C6  と゛んなまものた゛って = どんなまものだって
    db $90                         ; $71D1  　(space)
    db $3C,$45,$50,$53,$4C         ; $71D2  ねむるわよ
    db $8F                         ; $71D7  。
    db $FA                         ; $71D8  wait-for-button
    db $F7                         ; $71D9  clear page
    db $EF,$EE                     ; $71DA  newline
    db $9F                         ; $71DC  box tag
    db $96                         ; $71DD  end name/box tag
    db $38,$2B,$3A                 ; $71DE  とくに
    db $90                         ; $71E1  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$2C,$25,$48; $71E2  ト゛ラコ゛ンけいや = ドラゴンけいや
    db $EF,$EE                     ; $71EB  newline
    db $90,$90                     ; $71ED  　　(indent)
    db $2C,$47,$3D,$2C,$25         ; $71EF  けものけい
    db $90                         ; $71F4  　(space)
    db $39,$55,$29,$3D             ; $71F5  なんかの
    db $A4                         ; $71F9  、
    db $FA                         ; $71FA  wait-for-button
    db $F7                         ; $71FB  clear page
    db $EF,$EE                     ; $71FC  newline
    db $9F                         ; $71FE  box tag
    db $96                         ; $71FF  end name/box tag
    db $33,$55,$2F,$8D,$4B,$55,$32,$26,$39; $7200  たんし゛ゅんそうな = たんじゅんそうな
    db $90                         ; $7209  　(space)
    db $43,$47,$3D,$39,$4E         ; $720A  まものなら
    db $EF,$EE                     ; $720F  newline
    db $90,$90                     ; $7211  　　(indent)
    db $28,$47,$2F,$52,$25,$4C,$26,$3A; $7213  おもしろいように
    db $90                         ; $721B  　(space)
    db $2A,$43,$36,$34,$49,$26     ; $721C  きまっちゃう
    db $99                         ; $7222  ！
    db $F7                         ; $7223  clear page
    db $F0                         ; $7224  end of message


; --------------------------------------------------------------------------
; Message #128 ($7225)
;   「・・・、　、。
;   ここは、　モンスターぼくしゃ、。
;   「ただいま　とうみんちゅう、・・。
;   けいけんちは　もらえない、・・。
;   「だれも　おこしてくれない、・・。
;   だれも、　、・・　、・・・。
; --------------------------------------------------------------------------
Bank68_Msg128:                             ; $7225  (file $113225)
    db $EA                         ; $7225  ▶ new page
    db $9F                         ; $7226  box tag
    db $96                         ; $7227  end name/box tag
    db $23                         ; $7228  ・
    db $23                         ; $7229  ・
    db $23                         ; $722A  ・
    db $A4                         ; $722B  、
    db $90                         ; $722C  　(space)
    db $A4                         ; $722D  、
    db $8F                         ; $722E  。
    db $EF,$EE                     ; $722F  newline
    db $90,$90                     ; $7231  　　(indent)
    db $2D,$2D,$3E                 ; $7233  ここは
    db $A4                         ; $7236  、
    db $90                         ; $7237  　(space)
    db $7E,$8C,$67,$6A,$9C,$42,$8D,$2B,$2F,$49; $7238  モンスターほ゛くしゃ = モンスターぼくしゃ
    db $A4                         ; $7242  、
    db $8F                         ; $7243  。
    db $FA                         ; $7244  wait-for-button
    db $F7                         ; $7245  clear page
    db $EF,$EE                     ; $7246  newline
    db $9F                         ; $7248  box tag
    db $96                         ; $7249  end name/box tag
    db $33,$33,$8D,$25,$43         ; $724A  たた゛いま = ただいま
    db $90                         ; $724F  　(space)
    db $38,$26,$44,$55,$34,$4B,$26 ; $7250  とうみんちゅう
    db $A4                         ; $7257  、
    db $23                         ; $7258  ・
    db $23                         ; $7259  ・
    db $8F                         ; $725A  。
    db $EF,$EE                     ; $725B  newline
    db $90,$90                     ; $725D  　　(indent)
    db $2C,$25,$2C,$55,$34,$3E     ; $725F  けいけんちは
    db $90                         ; $7265  　(space)
    db $47,$4E,$27,$39,$25         ; $7266  もらえない
    db $A4                         ; $726B  、
    db $23                         ; $726C  ・
    db $23                         ; $726D  ・
    db $8F                         ; $726E  。
    db $FA                         ; $726F  wait-for-button
    db $F7                         ; $7270  clear page
    db $EF,$EE                     ; $7271  newline
    db $9F                         ; $7273  box tag
    db $96                         ; $7274  end name/box tag
    db $33,$8D,$51,$47             ; $7275  た゛れも = だれも
    db $90                         ; $7279  　(space)
    db $28,$2D,$2F,$37,$2B,$51,$39,$25; $727A  おこしてくれない
    db $A4                         ; $7282  、
    db $23                         ; $7283  ・
    db $23                         ; $7284  ・
    db $8F                         ; $7285  。
    db $EF,$EE                     ; $7286  newline
    db $90,$90                     ; $7288  　　(indent)
    db $33,$8D,$51,$47             ; $728A  た゛れも = だれも
    db $A4                         ; $728E  、
    db $90                         ; $728F  　(space)
    db $A4                         ; $7290  、
    db $23                         ; $7291  ・
    db $23                         ; $7292  ・
    db $90                         ; $7293  　(space)
    db $A4                         ; $7294  、
    db $23                         ; $7295  ・
    db $23                         ; $7296  ・
    db $23                         ; $7297  ・
    db $8F                         ; $7298  。
    db $F7                         ; $7299  clear page
    db $F0                         ; $729A  end of message


; --------------------------------------------------------------------------
; Message #129 ($729B)
;   〈テリー〉は　めのまえを　しらべた。
;   おいしそうな　おにくが
;   おかれている。
; --------------------------------------------------------------------------
Bank68_Msg129:                             ; $729B  (file $11329B)
    db $F6                         ; $729B  «insert hero name»
    db $3E                         ; $729C  は
    db $90                         ; $729D  　(space)
    db $46,$3D,$43,$27,$54         ; $729E  めのまえを
    db $90                         ; $72A3  　(space)
    db $2F,$4E,$41,$8D,$33         ; $72A4  しらへ゛た = しらべた
    db $8F                         ; $72A9  。
    db $EF,$EE                     ; $72AA  newline
    db $FA                         ; $72AC  wait-for-button
    db $F7                         ; $72AD  clear page
    db $EF,$EE                     ; $72AE  newline
    db $F3                         ; $72B0  open text box
    db $28,$25,$2F,$32,$26,$39     ; $72B1  おいしそうな
    db $90                         ; $72B7  　(space)
    db $28,$3A,$2B,$29,$8D         ; $72B8  おにくか゛ = おにくが
    db $EF,$EE                     ; $72BD  newline
    db $28,$29,$51,$37,$25,$50     ; $72BF  おかれている
    db $8F                         ; $72C5  。
    db $F7                         ; $72C6  clear page
    db $F0                         ; $72C7  end of message


; --------------------------------------------------------------------------
; Message #130 ($72C8)
;   おう「おお　〈テリー〉よ！
;   あくまのきしを　たおしたか！
;   おう「よくぞ　あくまのきしのおる
;   たびのとびらを　みつけたのう！
;   おう「そなたの　ぬけめのなさは
;   あくまなみじゃのう！
; --------------------------------------------------------------------------
Bank68_Msg130:                             ; $72C8  (file $1132C8)
    db $EA                         ; $72C8  ▶ new page
    db $28,$26                     ; $72C9  おう  (speaker: おう)
    db $96                         ; $72CB  end name/box tag
    db $28,$28                     ; $72CC  おお
    db $90                         ; $72CE  　(space)
    db $F6                         ; $72CF  «insert hero name»
    db $4C                         ; $72D0  よ
    db $99                         ; $72D1  ！
    db $EF,$EE                     ; $72D2  newline
    db $90,$90                     ; $72D4  　　(indent)
    db $24,$2B,$43,$3D,$2A,$2F,$54 ; $72D6  あくまのきしを
    db $90                         ; $72DD  　(space)
    db $33,$28,$2F,$33,$29         ; $72DE  たおしたか
    db $99                         ; $72E3  ！
    db $FA                         ; $72E4  wait-for-button
    db $F7                         ; $72E5  clear page
    db $EF,$EE                     ; $72E6  newline
    db $28,$26                     ; $72E8  おう  (speaker: おう)
    db $96                         ; $72EA  end name/box tag
    db $4C,$2B,$32,$8D             ; $72EB  よくそ゛ = よくぞ
    db $90                         ; $72EF  　(space)
    db $24,$2B,$43,$3D,$2A,$2F,$3D,$28,$50; $72F0  あくまのきしのおる
    db $EF,$EE                     ; $72F9  newline
    db $90,$90                     ; $72FB  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$54; $72FD  たひ゛のとひ゛らを = たびのとびらを
    db $90                         ; $7306  　(space)
    db $44,$35,$2C,$33,$3D,$26     ; $7307  みつけたのう
    db $99                         ; $730D  ！
    db $FA                         ; $730E  wait-for-button
    db $F7                         ; $730F  clear page
    db $EF,$EE                     ; $7310  newline
    db $28,$26                     ; $7312  おう  (speaker: おう)
    db $96                         ; $7314  end name/box tag
    db $32,$39,$33,$3D             ; $7315  そなたの
    db $90                         ; $7319  　(space)
    db $3B,$2C,$46,$3D,$39,$2E,$3E ; $731A  ぬけめのなさは
    db $EF,$EE                     ; $7321  newline
    db $90,$90                     ; $7323  　　(indent)
    db $24,$2B,$43,$39,$44,$2F,$8D,$49,$3D,$26; $7325  あくまなみし゛ゃのう = あくまなみじゃのう
    db $99                         ; $732F  ！
    db $F7                         ; $7330  clear page
    db $F0                         ; $7331  end of message


; --------------------------------------------------------------------------
; Message #131 ($7332)
;   [E9]カ〈テリー〉は　タンスの
;   なかを　しらべた。
;   プ[9D]ンと　あまいいきの
;   かおりがした。
; --------------------------------------------------------------------------
Bank68_Msg131:                             ; $7332  (file $113332)
    db $E9                         ; $7332  ctrl $E9
    db $60                         ; $7333  カ
    db $F6                         ; $7334  «insert hero name»
    db $3E                         ; $7335  は
    db $90                         ; $7336  　(space)
    db $6A,$8C,$67,$3D             ; $7337  タンスの
    db $EF,$EE                     ; $733B  newline
    db $39,$29,$54                 ; $733D  なかを
    db $90                         ; $7340  　(space)
    db $2F,$4E,$41,$8D,$33         ; $7341  しらへ゛た = しらべた
    db $8F                         ; $7346  。
    db $FA                         ; $7347  wait-for-button
    db $F7                         ; $7348  clear page
    db $EF,$EE                     ; $7349  newline
    db $77,$8E                     ; $734B  フ゜ = プ
    db $9D                         ; $734D  ctrl $9D
    db $8C,$38                     ; $734E  ンと
    db $90                         ; $7350  　(space)
    db $24,$43,$25,$25,$2A,$3D     ; $7351  あまいいきの
    db $EF,$EE                     ; $7357  newline
    db $29,$28,$4F,$29,$8D,$2F,$33 ; $7359  かおりか゛した = かおりがした
    db $8F                         ; $7360  。
    db $F7                         ; $7361  clear page
    db $F0                         ; $7362  end of message


; --------------------------------------------------------------------------
; Message #132 ($7363)
;   「よくやったのー！
;   [0D]クラスかちぬきじゃ！！
; --------------------------------------------------------------------------
Bank68_Msg132:                             ; $7363  (file $113363)
    db $EA                         ; $7363  ▶ new page
    db $9F                         ; $7364  box tag
    db $96                         ; $7365  end name/box tag
    db $4C,$2B,$48,$36,$33,$3D,$9C ; $7366  よくやったのー
    db $99                         ; $736D  ！
    db $EF,$EE                     ; $736E  newline
    db $90,$90                     ; $7370  　　(indent)
    db $0D                         ; $7372  ctrl $0D
    db $62,$85,$67,$29,$34,$3B,$2A,$2F,$8D,$49; $7373  クラスかちぬきし゛ゃ = クラスかちぬきじゃ
    db $99                         ; $737D  ！
    db $99                         ; $737E  ！
    db $F7                         ; $737F  clear page
    db $F0                         ; $7380  end of message


; --------------------------------------------------------------------------
; Message #133 ($7381)
;   「おお！　〈テリー〉どの。
;   [0D]クラスかちぬき　おめでとう！
;   「おうさまが　およびなのだ。
;   ついてきてほしい！
; --------------------------------------------------------------------------
Bank68_Msg133:                             ; $7381  (file $113381)
    db $EA                         ; $7381  ▶ new page
    db $9F                         ; $7382  box tag
    db $96                         ; $7383  end name/box tag
    db $28,$28                     ; $7384  おお
    db $99                         ; $7386  ！
    db $90                         ; $7387  　(space)
    db $F6                         ; $7388  «insert hero name»
    db $38,$8D,$3D                 ; $7389  と゛の = どの
    db $8F                         ; $738C  。
    db $EF,$EE                     ; $738D  newline
    db $90,$90                     ; $738F  　　(indent)
    db $0D                         ; $7391  ctrl $0D
    db $62,$85,$67,$29,$34,$3B,$2A ; $7392  クラスかちぬき
    db $90                         ; $7399  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $739A  おめて゛とう = おめでとう
    db $99                         ; $73A0  ！
    db $FA                         ; $73A1  wait-for-button
    db $F7                         ; $73A2  clear page
    db $EF,$EE                     ; $73A3  newline
    db $9F                         ; $73A5  box tag
    db $96                         ; $73A6  end name/box tag
    db $28,$26,$2E,$43,$29,$8D     ; $73A7  おうさまか゛ = おうさまが
    db $90                         ; $73AD  　(space)
    db $28,$4C,$3F,$8D,$39,$3D,$33,$8D; $73AE  およひ゛なのた゛ = およびなのだ
    db $8F                         ; $73B6  。
    db $EF,$EE                     ; $73B7  newline
    db $90,$90                     ; $73B9  　　(indent)
    db $35,$25,$37,$2A,$37,$42,$2F,$25; $73BB  ついてきてほしい
    db $99                         ; $73C3  ！
    db $F7                         ; $73C4  clear page
    db $F0                         ; $73C5  end of message


; --------------------------------------------------------------------------
; Message #134 ($73C6)
;   「[0D]クラスの　さいしゅうせんは
;   おうひさまの　へやにいる、
;   「ミッキーさまが　あいてです！
; --------------------------------------------------------------------------
Bank68_Msg134:                             ; $73C6  (file $1133C6)
    db $EB                         ; $73C6  ▶ new page
    db $9F                         ; $73C7  box tag
    db $96                         ; $73C8  end name/box tag
    db $0D                         ; $73C9  ctrl $0D
    db $62,$85,$67,$3D             ; $73CA  クラスの
    db $90                         ; $73CE  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $73CF  さいしゅうせんは
    db $EF,$EE                     ; $73D7  newline
    db $90,$90                     ; $73D9  　　(indent)
    db $28,$26,$3F,$2E,$43,$3D     ; $73DB  おうひさまの
    db $90                         ; $73E1  　(space)
    db $41,$48,$3A,$25,$50         ; $73E2  へやにいる
    db $A4                         ; $73E7  、
    db $FA                         ; $73E8  wait-for-button
    db $F7                         ; $73E9  clear page
    db $EF,$EE                     ; $73EA  newline
    db $9F                         ; $73EC  box tag
    db $96                         ; $73ED  end name/box tag
    db $7B,$6D,$61,$9C,$2E,$43,$29,$8D; $73EE  ミッキーさまか゛ = ミッキーさまが
    db $90                         ; $73F6  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $73F7  あいてて゛す = あいてです
    db $99                         ; $73FD  ！
    db $EF,$EE                     ; $73FE  newline
    db $F7                         ; $7400  clear page
    db $F0                         ; $7401  end of message


; --------------------------------------------------------------------------
; Message #135 ($7402)
;   「あっ！　す、　すいません！！
;   えらそうなこといって！
;   「これからは　こころを　いれかえて
;   いちから　やりなおします！
;   「、、ところで　〈テリー〉くん！
;   まものとおみあいを　しませんか？
;   「ひょうがまじん　なんですが
;   おみあいしましょうよ！
; --------------------------------------------------------------------------
Bank68_Msg135:                             ; $7402  (file $113402)
    db $EA                         ; $7402  ▶ new page
    db $9F                         ; $7403  box tag
    db $96                         ; $7404  end name/box tag
    db $24,$36                     ; $7405  あっ
    db $99                         ; $7407  ！
    db $90                         ; $7408  　(space)
    db $30                         ; $7409  す
    db $A4                         ; $740A  、
    db $90                         ; $740B  　(space)
    db $30,$25,$43,$31,$55         ; $740C  すいません
    db $99                         ; $7411  ！
    db $99                         ; $7412  ！
    db $EF,$EE                     ; $7413  newline
    db $90,$90                     ; $7415  　　(indent)
    db $27,$4E,$32,$26,$39,$2D,$38,$25,$36,$37; $7417  えらそうなこといって
    db $99                         ; $7421  ！
    db $FA                         ; $7422  wait-for-button
    db $F7                         ; $7423  clear page
    db $EF,$EE                     ; $7424  newline
    db $9F                         ; $7426  box tag
    db $96                         ; $7427  end name/box tag
    db $2D,$51,$29,$4E,$3E         ; $7428  これからは
    db $90                         ; $742D  　(space)
    db $2D,$2D,$52,$54             ; $742E  こころを
    db $90                         ; $7432  　(space)
    db $25,$51,$29,$27,$37         ; $7433  いれかえて
    db $EF,$EE                     ; $7438  newline
    db $90,$90                     ; $743A  　　(indent)
    db $25,$34,$29,$4E             ; $743C  いちから
    db $90                         ; $7440  　(space)
    db $48,$4F,$39,$28,$2F,$43,$30 ; $7441  やりなおします
    db $99                         ; $7448  ！
    db $FA                         ; $7449  wait-for-button
    db $F7                         ; $744A  clear page
    db $EF,$EE                     ; $744B  newline
    db $9F                         ; $744D  box tag
    db $96                         ; $744E  end name/box tag
    db $A4                         ; $744F  、
    db $A4                         ; $7450  、
    db $38,$2D,$52,$37,$8D         ; $7451  ところて゛ = ところで
    db $90                         ; $7456  　(space)
    db $F6                         ; $7457  «insert hero name»
    db $2B,$55                     ; $7458  くん
    db $99                         ; $745A  ！
    db $EF,$EE                     ; $745B  newline
    db $90,$90                     ; $745D  　　(indent)
    db $43,$47,$3D,$38,$28,$44,$24,$25,$54; $745F  まものとおみあいを
    db $90                         ; $7468  　(space)
    db $2F,$43,$31,$55,$29         ; $7469  しませんか
    db $98                         ; $746E  ？
    db $FA                         ; $746F  wait-for-button
    db $F7                         ; $7470  clear page
    db $EF,$EE                     ; $7471  newline
    db $9F                         ; $7473  box tag
    db $96                         ; $7474  end name/box tag
    db $3F,$4D,$26,$29,$8D,$43,$2F,$8D,$55; $7475  ひょうか゛まし゛ん = ひょうがまじん
    db $90                         ; $747E  　(space)
    db $39,$55,$37,$8D,$30,$29,$8D ; $747F  なんて゛すか゛ = なんですが
    db $EF,$EE                     ; $7486  newline
    db $90,$90                     ; $7488  　　(indent)
    db $28,$44,$24,$25,$2F,$43,$2F,$4D,$26,$4C; $748A  おみあいしましょうよ
    db $99                         ; $7494  ！
    db $F0                         ; $7495  end of message


; --------------------------------------------------------------------------
; Message #136 ($7496)
;   「ハッ。
;   おうじさま！
;   「わたしを　たすけに
;   きてくれたのですね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg136:                             ; $7496  (file $113496)
    db $EB                         ; $7496  ▶ new page
    db $9F                         ; $7497  box tag
    db $96                         ; $7498  end name/box tag
    db $75,$6D                     ; $7499  ハッ
    db $8F                         ; $749B  。
    db $EF,$EE                     ; $749C  newline
    db $90,$90                     ; $749E  　　(indent)
    db $28,$26,$2F,$8D,$2E,$43     ; $74A0  おうし゛さま = おうじさま
    db $99                         ; $74A6  ！
    db $FA                         ; $74A7  wait-for-button
    db $F7                         ; $74A8  clear page
    db $EF,$EE                     ; $74A9  newline
    db $9F                         ; $74AB  box tag
    db $96                         ; $74AC  end name/box tag
    db $53,$33,$2F,$54             ; $74AD  わたしを
    db $90                         ; $74B1  　(space)
    db $33,$30,$2C,$3A             ; $74B2  たすけに
    db $EF,$EE                     ; $74B6  newline
    db $90,$90                     ; $74B8  　　(indent)
    db $2A,$37,$2B,$51,$33,$3D,$37,$8D,$30,$3C; $74BA  きてくれたのて゛すね = きてくれたのですね
    db $98                         ; $74C4  ？
    db $FF                         ; $74C5  はい/いいえ
    db $F0                         ; $74C6  end of message


; --------------------------------------------------------------------------
; Message #137 ($74C7)
;   「そうですか、、。
; --------------------------------------------------------------------------
Bank68_Msg137:                             ; $74C7  (file $1134C7)
    db $EB                         ; $74C7  ▶ new page
    db $9F                         ; $74C8  box tag
    db $96                         ; $74C9  end name/box tag
    db $32,$26,$37,$8D,$30,$29     ; $74CA  そうて゛すか = そうですか
    db $A4                         ; $74D0  、
    db $A4                         ; $74D1  、
    db $8F                         ; $74D2  。
    db $EF,$EE                     ; $74D3  newline
    db $F7                         ; $74D5  clear page
    db $F0                         ; $74D6  end of message


; --------------------------------------------------------------------------
; Message #138 ($74D7)
;   「おしろに、かえりたい、、。
; --------------------------------------------------------------------------
Bank68_Msg138:                             ; $74D7  (file $1134D7)
    db $EB                         ; $74D7  ▶ new page
    db $9F                         ; $74D8  box tag
    db $96                         ; $74D9  end name/box tag
    db $28,$2F,$52,$3A             ; $74DA  おしろに
    db $A4                         ; $74DE  、
    db $29,$27,$4F,$33,$25         ; $74DF  かえりたい
    db $A4                         ; $74E4  、
    db $A4                         ; $74E5  、
    db $8F                         ; $74E6  。
    db $EF,$EE                     ; $74E7  newline
    db $F7                         ; $74E9  clear page
    db $F0                         ; $74EA  end of message


; --------------------------------------------------------------------------
; Message #139 ($74EB)
;   「はあ、、。
; --------------------------------------------------------------------------
Bank68_Msg139:                             ; $74EB  (file $1134EB)
    db $EB                         ; $74EB  ▶ new page
    db $9F                         ; $74EC  box tag
    db $96                         ; $74ED  end name/box tag
    db $3E,$24                     ; $74EE  はあ
    db $A4                         ; $74F0  、
    db $A4                         ; $74F1  、
    db $8F                         ; $74F2  。
    db $EF,$EE                     ; $74F3  newline
    db $F7                         ; $74F5  clear page
    db $F0                         ; $74F6  end of message


; --------------------------------------------------------------------------
; Message #140 ($74F7)
;   「おしろに　かえりたい、。
; --------------------------------------------------------------------------
Bank68_Msg140:                             ; $74F7  (file $1134F7)
    db $EB                         ; $74F7  ▶ new page
    db $9F                         ; $74F8  box tag
    db $96                         ; $74F9  end name/box tag
    db $28,$2F,$52,$3A             ; $74FA  おしろに
    db $90                         ; $74FE  　(space)
    db $29,$27,$4F,$33,$25         ; $74FF  かえりたい
    db $A4                         ; $7504  、
    db $8F                         ; $7505  。
    db $EF,$EE                     ; $7506  newline
    db $F7                         ; $7508  clear page
    db $F0                         ; $7509  end of message


; --------------------------------------------------------------------------
; Message #141 ($750A)
;   「まっ　うれしい！
;   、、、ぽっ。
;   「どうぞ　わたしを　だきあげて
;   おしろへ　つれていってください！
; --------------------------------------------------------------------------
Bank68_Msg141:                             ; $750A  (file $11350A)
    db $EB                         ; $750A  ▶ new page
    db $9F                         ; $750B  box tag
    db $96                         ; $750C  end name/box tag
    db $43,$36                     ; $750D  まっ
    db $90                         ; $750F  　(space)
    db $26,$51,$2F,$25             ; $7510  うれしい
    db $99                         ; $7514  ！
    db $EF,$EE                     ; $7515  newline
    db $90,$90                     ; $7517  　　(indent)
    db $A4                         ; $7519  、
    db $A4                         ; $751A  、
    db $A4                         ; $751B  、
    db $42,$8E,$36                 ; $751C  ほ゜っ = ぽっ
    db $8F                         ; $751F  。
    db $FA                         ; $7520  wait-for-button
    db $F7                         ; $7521  clear page
    db $EF,$EE                     ; $7522  newline
    db $9F                         ; $7524  box tag
    db $96                         ; $7525  end name/box tag
    db $38,$8D,$26,$32,$8D         ; $7526  と゛うそ゛ = どうぞ
    db $90                         ; $752B  　(space)
    db $53,$33,$2F,$54             ; $752C  わたしを
    db $90                         ; $7530  　(space)
    db $33,$8D,$2A,$24,$2C,$8D,$37 ; $7531  た゛きあけ゛て = だきあげて
    db $EF,$EE                     ; $7538  newline
    db $90,$90                     ; $753A  　　(indent)
    db $28,$2F,$52,$41             ; $753C  おしろへ
    db $90                         ; $7540  　(space)
    db $35,$51,$37,$25,$36,$37,$2B,$33,$8D,$2E,$25; $7541  つれていってくた゛さい = つれていってください
    db $99                         ; $754C  ！
    db $F7                         ; $754D  clear page
    db $F0                         ; $754E  end of message


; --------------------------------------------------------------------------
; Message #142 ($754F)
;   〈テリー〉は　おひめさまを
;   だきかかえようとした！
;   しかし　もちあげられなかった！
; --------------------------------------------------------------------------
Bank68_Msg142:                             ; $754F  (file $11354F)
    db $F6                         ; $754F  «insert hero name»
    db $3E                         ; $7550  は
    db $90                         ; $7551  　(space)
    db $28,$3F,$46,$2E,$43,$54     ; $7552  おひめさまを
    db $EF,$EE                     ; $7558  newline
    db $33,$8D,$2A,$29,$29,$27,$4C,$26,$38,$2F,$33; $755A  た゛きかかえようとした = だきかかえようとした
    db $99                         ; $7565  ！
    db $FA                         ; $7566  wait-for-button
    db $F7                         ; $7567  clear page
    db $EF,$EE                     ; $7568  newline
    db $2F,$29,$2F                 ; $756A  しかし
    db $90                         ; $756D  　(space)
    db $47,$34,$24,$2C,$8D,$4E,$51,$39,$29,$36,$33; $756E  もちあけ゛られなかった = もちあげられなかった
    db $99                         ; $7579  ！
    db $EF,$EE                     ; $757A  newline
    db $F7                         ; $757C  clear page
    db $F0                         ; $757D  end of message


; --------------------------------------------------------------------------
; Message #143 ($757E)
;   「、、いいのです。　あなたは　まだ
;   おちいさいのですもの。
;   「だから　もちあげられないのです。
;   「そ、そうと　いってくださいまし！
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg143:                             ; $757E  (file $11357E)
    db $EB                         ; $757E  ▶ new page
    db $9F                         ; $757F  box tag
    db $96                         ; $7580  end name/box tag
    db $A4                         ; $7581  、
    db $A4                         ; $7582  、
    db $25,$25,$3D,$37,$8D,$30     ; $7583  いいのて゛す = いいのです
    db $8F                         ; $7589  。
    db $90                         ; $758A  　(space)
    db $24,$39,$33,$3E             ; $758B  あなたは
    db $90                         ; $758F  　(space)
    db $43,$33,$8D                 ; $7590  また゛ = まだ
    db $EF,$EE                     ; $7593  newline
    db $90,$90                     ; $7595  　　(indent)
    db $28,$34,$25,$2E,$25,$3D,$37,$8D,$30,$47,$3D; $7597  おちいさいのて゛すもの = おちいさいのですもの
    db $8F                         ; $75A2  。
    db $FA                         ; $75A3  wait-for-button
    db $F7                         ; $75A4  clear page
    db $EF,$EE                     ; $75A5  newline
    db $9F                         ; $75A7  box tag
    db $96                         ; $75A8  end name/box tag
    db $33,$8D,$29,$4E             ; $75A9  た゛から = だから
    db $90                         ; $75AD  　(space)
    db $47,$34,$24,$2C,$8D,$4E,$51,$39,$25,$3D,$37,$8D,$30; $75AE  もちあけ゛られないのて゛す = もちあげられないのです
    db $8F                         ; $75BB  。
    db $EF,$EE                     ; $75BC  newline
    db $FA                         ; $75BE  wait-for-button
    db $F7                         ; $75BF  clear page
    db $EF,$EE                     ; $75C0  newline
    db $F3                         ; $75C2  open text box
    db $9F                         ; $75C3  box tag
    db $96                         ; $75C4  end name/box tag
    db $32                         ; $75C5  そ
    db $A4                         ; $75C6  、
    db $32,$26,$38                 ; $75C7  そうと
    db $90                         ; $75CA  　(space)
    db $25,$36,$37,$2B,$33,$8D,$2E,$25,$43,$2F; $75CB  いってくた゛さいまし = いってくださいまし
    db $99                         ; $75D5  ！
    db $EF,$EE                     ; $75D6  newline
    db $FF                         ; $75D8  はい/いいえ
    db $F0                         ; $75D9  end of message


; --------------------------------------------------------------------------
; Message #144 ($75DA)
;   「そ、そうと　いってくださいまし！
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg144:                             ; $75DA  (file $1135DA)
    db $EB                         ; $75DA  ▶ new page
    db $9F                         ; $75DB  box tag
    db $96                         ; $75DC  end name/box tag
    db $32                         ; $75DD  そ
    db $A4                         ; $75DE  、
    db $32,$26,$38                 ; $75DF  そうと
    db $90                         ; $75E2  　(space)
    db $25,$36,$37,$2B,$33,$8D,$2E,$25,$43,$2F; $75E3  いってくた゛さいまし = いってくださいまし
    db $99                         ; $75ED  ！
    db $EF,$EE                     ; $75EE  newline
    db $FF                         ; $75F0  はい/いいえ
    db $F0                         ; $75F1  end of message


; --------------------------------------------------------------------------
; Message #145 ($75F2)
;   「では　わたくしは　もうすこし
;   おおきいかたを　おまちします。
; --------------------------------------------------------------------------
Bank68_Msg145:                             ; $75F2  (file $1135F2)
    db $EB                         ; $75F2  ▶ new page
    db $9F                         ; $75F3  box tag
    db $96                         ; $75F4  end name/box tag
    db $37,$8D,$3E                 ; $75F5  て゛は = では
    db $90                         ; $75F8  　(space)
    db $53,$33,$2B,$2F,$3E         ; $75F9  わたくしは
    db $90                         ; $75FE  　(space)
    db $47,$26,$30,$2D,$2F         ; $75FF  もうすこし
    db $EF,$EE                     ; $7604  newline
    db $90,$90                     ; $7606  　　(indent)
    db $28,$28,$2A,$25,$29,$33,$54 ; $7608  おおきいかたを
    db $90                         ; $760F  　(space)
    db $28,$43,$34,$2F,$43,$30     ; $7610  おまちします
    db $8F                         ; $7616  。
    db $F7                         ; $7617  clear page
    db $F0                         ; $7618  end of message


; --------------------------------------------------------------------------
; Message #146 ($7619)
;   「わたしの　ひょうがまじんと
;   おみあいを　しませんか？
;   「むりとは　おもいますが　ようがん
;   まじんとなら　さいこうなんです！
;   「どうです？　ひょうがまじんと
;   おみあいを　しますか？
; --------------------------------------------------------------------------
Bank68_Msg146:                             ; $7619  (file $113619)
    db $EA                         ; $7619  ▶ new page
    db $9F                         ; $761A  box tag
    db $96                         ; $761B  end name/box tag
    db $53,$33,$2F,$3D             ; $761C  わたしの
    db $90                         ; $7620  　(space)
    db $3F,$4D,$26,$29,$8D,$43,$2F,$8D,$55,$38; $7621  ひょうか゛まし゛んと = ひょうがまじんと
    db $EF,$EE                     ; $762B  newline
    db $90,$90                     ; $762D  　　(indent)
    db $28,$44,$24,$25,$54         ; $762F  おみあいを
    db $90                         ; $7634  　(space)
    db $2F,$43,$31,$55,$29         ; $7635  しませんか
    db $98                         ; $763A  ？
    db $FA                         ; $763B  wait-for-button
    db $F7                         ; $763C  clear page
    db $EF,$EE                     ; $763D  newline
    db $9F                         ; $763F  box tag
    db $96                         ; $7640  end name/box tag
    db $45,$4F,$38,$3E             ; $7641  むりとは
    db $90                         ; $7645  　(space)
    db $28,$47,$25,$43,$30,$29,$8D ; $7646  おもいますか゛ = おもいますが
    db $90                         ; $764D  　(space)
    db $4C,$26,$29,$8D,$55         ; $764E  ようか゛ん = ようがん
    db $EF,$EE                     ; $7653  newline
    db $90,$90                     ; $7655  　　(indent)
    db $43,$2F,$8D,$55,$38,$39,$4E ; $7657  まし゛んとなら = まじんとなら
    db $90                         ; $765E  　(space)
    db $2E,$25,$2D,$26,$39,$55,$37,$8D,$30; $765F  さいこうなんて゛す = さいこうなんです
    db $99                         ; $7668  ！
    db $FA                         ; $7669  wait-for-button
    db $F7                         ; $766A  clear page
    db $EF,$EE                     ; $766B  newline
    db $9F                         ; $766D  box tag
    db $96                         ; $766E  end name/box tag
    db $38,$8D,$26,$37,$8D,$30     ; $766F  と゛うて゛す = どうです
    db $98                         ; $7675  ？
    db $90                         ; $7676  　(space)
    db $3F,$4D,$26,$29,$8D,$43,$2F,$8D,$55,$38; $7677  ひょうか゛まし゛んと = ひょうがまじんと
    db $EF,$EE                     ; $7681  newline
    db $90,$90                     ; $7683  　　(indent)
    db $28,$44,$24,$25,$54         ; $7685  おみあいを
    db $90                         ; $768A  　(space)
    db $2F,$43,$30,$29             ; $768B  しますか
    db $98                         ; $768F  ？
    db $F0                         ; $7690  end of message


; --------------------------------------------------------------------------
; Message #147 ($7691)
;   「これからは　いいきにならずに
;   こつこつ　どりょくします！
;   「〈テリー〉くん。
;   これからも　よろしくね！
; --------------------------------------------------------------------------
Bank68_Msg147:                             ; $7691  (file $113691)
    db $EA                         ; $7691  ▶ new page
    db $9F                         ; $7692  box tag
    db $96                         ; $7693  end name/box tag
    db $2D,$51,$29,$4E,$3E         ; $7694  これからは
    db $90                         ; $7699  　(space)
    db $25,$25,$2A,$3A,$39,$4E,$30,$8D,$3A; $769A  いいきにならす゛に = いいきにならずに
    db $EF,$EE                     ; $76A3  newline
    db $90,$90                     ; $76A5  　　(indent)
    db $2D,$35,$2D,$35             ; $76A7  こつこつ
    db $90                         ; $76AB  　(space)
    db $38,$8D,$4F,$4D,$2B,$2F,$43,$30; $76AC  と゛りょくします = どりょくします
    db $99                         ; $76B4  ！
    db $FA                         ; $76B5  wait-for-button
    db $F7                         ; $76B6  clear page
    db $EF,$EE                     ; $76B7  newline
    db $9F                         ; $76B9  box tag
    db $96                         ; $76BA  end name/box tag
    db $F6                         ; $76BB  «insert hero name»
    db $2B,$55                     ; $76BC  くん
    db $8F                         ; $76BE  。
    db $EF,$EE                     ; $76BF  newline
    db $90,$90                     ; $76C1  　　(indent)
    db $2D,$51,$29,$4E,$47         ; $76C3  これからも
    db $90                         ; $76C8  　(space)
    db $4C,$52,$2F,$2B,$3C         ; $76C9  よろしくね
    db $99                         ; $76CE  ！
    db $F7                         ; $76CF  clear page
    db $F0                         ; $76D0  end of message


; --------------------------------------------------------------------------
; Message #148 ($76D1)
;   「おらたち　まものが　おぼえられる
;   とくぎは　[03]つあるんだ。
;   「だけど　[16][19]とか　レベルが
;   ひくいと　おぼえられないよ。
;   「なかなか　おぼえないときは
;   はいごうしたほうが　いいかな。
; --------------------------------------------------------------------------
Bank68_Msg148:                             ; $76D1  (file $1136D1)
    db $EA                         ; $76D1  ▶ new page
    db $9F                         ; $76D2  box tag
    db $96                         ; $76D3  end name/box tag
    db $28,$4E,$33,$34             ; $76D4  おらたち
    db $90                         ; $76D8  　(space)
    db $43,$47,$3D,$29,$8D         ; $76D9  まものか゛ = まものが
    db $90                         ; $76DE  　(space)
    db $28,$42,$8D,$27,$4E,$51,$50 ; $76DF  おほ゛えられる = おぼえられる
    db $EF,$EE                     ; $76E6  newline
    db $90,$90                     ; $76E8  　　(indent)
    db $38,$2B,$2A,$8D,$3E         ; $76EA  とくき゛は = とくぎは
    db $90                         ; $76EF  　(space)
    db $03                         ; $76F0  ctrl $03
    db $35,$24,$50,$55,$33,$8D     ; $76F1  つあるんた゛ = つあるんだ
    db $8F                         ; $76F7  。
    db $FA                         ; $76F8  wait-for-button
    db $F7                         ; $76F9  clear page
    db $EF,$EE                     ; $76FA  newline
    db $9F                         ; $76FC  box tag
    db $96                         ; $76FD  end name/box tag
    db $33,$8D,$2C,$38,$8D         ; $76FE  た゛けと゛ = だけど
    db $90                         ; $7703  　(space)
    db $16                         ; $7704  ctrl $16
    db $19                         ; $7705  ctrl $19
    db $38,$29                     ; $7706  とか
    db $90                         ; $7708  　(space)
    db $88,$78,$8D,$87,$29,$8D     ; $7709  レヘ゛ルか゛ = レベルが
    db $EF,$EE                     ; $770F  newline
    db $90,$90                     ; $7711  　　(indent)
    db $3F,$2B,$25,$38             ; $7713  ひくいと
    db $90                         ; $7717  　(space)
    db $28,$42,$8D,$27,$4E,$51,$39,$25,$4C; $7718  おほ゛えられないよ = おぼえられないよ
    db $8F                         ; $7721  。
    db $FA                         ; $7722  wait-for-button
    db $F7                         ; $7723  clear page
    db $EF,$EE                     ; $7724  newline
    db $9F                         ; $7726  box tag
    db $96                         ; $7727  end name/box tag
    db $39,$29,$39,$29             ; $7728  なかなか
    db $90                         ; $772C  　(space)
    db $28,$42,$8D,$27,$39,$25,$38,$2A,$3E; $772D  おほ゛えないときは = おぼえないときは
    db $EF,$EE                     ; $7736  newline
    db $90,$90                     ; $7738  　　(indent)
    db $3E,$25,$2D,$8D,$26,$2F,$33,$42,$26,$29,$8D; $773A  はいこ゛うしたほうか゛ = はいごうしたほうが
    db $90                         ; $7745  　(space)
    db $25,$25,$29,$39             ; $7746  いいかな
    db $8F                         ; $774A  。
    db $F7                         ; $774B  clear page
    db $F0                         ; $774C  end of message


; --------------------------------------------------------------------------
; Message #149 ($774D)
;   「メーダ！
;   だめーだ！
; --------------------------------------------------------------------------
Bank68_Msg149:                             ; $774D  (file $11374D)
    db $EA                         ; $774D  ▶ new page
    db $9F                         ; $774E  box tag
    db $96                         ; $774F  end name/box tag
    db $7D,$9C,$6A,$8D             ; $7750  メータ゛ = メーダ
    db $99                         ; $7754  ！
    db $EF,$EE                     ; $7755  newline
    db $90,$90                     ; $7757  　　(indent)
    db $33,$8D,$46,$9C,$33,$8D     ; $7759  た゛めーた゛ = だめーだ
    db $99                         ; $775F  ！
    db $F7                         ; $7760  clear page
    db $F0                         ; $7761  end of message


; --------------------------------------------------------------------------
; Message #150 ($7762)
;   「ミッキーは　せいかくは　ともかく
;   マスターのうでは　たしかだのう。
;   「そうじゃ！　あやつの　つれておる
;   リザードマンなんじゃが、
;   「ミッキーは　だれかと　おみあい
;   させたがっておる　ようじゃぞ。
; --------------------------------------------------------------------------
Bank68_Msg150:                             ; $7762  (file $113762)
    db $EA                         ; $7762  ▶ new page
    db $9F                         ; $7763  box tag
    db $96                         ; $7764  end name/box tag
    db $7B,$6D,$61,$9C,$3E         ; $7765  ミッキーは
    db $90                         ; $776A  　(space)
    db $31,$25,$29,$2B,$3E         ; $776B  せいかくは
    db $90                         ; $7770  　(space)
    db $38,$47,$29,$2B             ; $7771  ともかく
    db $EF,$EE                     ; $7775  newline
    db $90,$90                     ; $7777  　　(indent)
    db $7A,$67,$6A,$9C,$3D,$26,$37,$8D,$3E; $7779  マスターのうて゛は = マスターのうでは
    db $90                         ; $7782  　(space)
    db $33,$2F,$29,$33,$8D,$3D,$26 ; $7783  たしかた゛のう = たしかだのう
    db $8F                         ; $778A  。
    db $FA                         ; $778B  wait-for-button
    db $F7                         ; $778C  clear page
    db $EF,$EE                     ; $778D  newline
    db $9F                         ; $778F  box tag
    db $96                         ; $7790  end name/box tag
    db $32,$26,$2F,$8D,$49         ; $7791  そうし゛ゃ = そうじゃ
    db $99                         ; $7796  ！
    db $90                         ; $7797  　(space)
    db $24,$48,$35,$3D             ; $7798  あやつの
    db $90                         ; $779C  　(space)
    db $35,$51,$37,$28,$50         ; $779D  つれておる
    db $EF,$EE                     ; $77A2  newline
    db $90,$90                     ; $77A4  　　(indent)
    db $86,$65,$8D,$9C,$6F,$8D,$7A,$8C,$39,$55,$2F,$8D,$49,$29,$8D; $77A6  リサ゛ート゛マンなんし゛ゃか゛ = リザードマンなんじゃが
    db $A4                         ; $77B5  、
    db $FA                         ; $77B6  wait-for-button
    db $F7                         ; $77B7  clear page
    db $EF,$EE                     ; $77B8  newline
    db $9F                         ; $77BA  box tag
    db $96                         ; $77BB  end name/box tag
    db $7B,$6D,$61,$9C,$3E         ; $77BC  ミッキーは
    db $90                         ; $77C1  　(space)
    db $33,$8D,$51,$29,$38         ; $77C2  た゛れかと = だれかと
    db $90                         ; $77C7  　(space)
    db $28,$44,$24,$25             ; $77C8  おみあい
    db $EF,$EE                     ; $77CC  newline
    db $90,$90                     ; $77CE  　　(indent)
    db $2E,$31,$33,$29,$8D,$36,$37,$28,$50; $77D0  させたか゛っておる = させたがっておる
    db $90                         ; $77D9  　(space)
    db $4C,$26,$2F,$8D,$49,$32,$8D ; $77DA  ようし゛ゃそ゛ = ようじゃぞ
    db $8F                         ; $77E1  。
    db $F7                         ; $77E2  clear page
    db $F0                         ; $77E3  end of message


; --------------------------------------------------------------------------
; Message #151 ($77E4)
;   「このぞうは　タィジャの
;   まもりがみさまの　ぞうなるぞう！
;   「ぼうけんに　でかけるまえに
;   ぼうけんのしょは　つけておるか？
;   「これは　きほんじゃぞ！
; --------------------------------------------------------------------------
Bank68_Msg151:                             ; $77E4  (file $1137E4)
    db $EA                         ; $77E4  ▶ new page
    db $9F                         ; $77E5  box tag
    db $96                         ; $77E6  end name/box tag
    db $2D,$3D,$32,$8D,$26,$3E     ; $77E7  このそ゛うは = このぞうは
    db $90                         ; $77ED  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $77EE  タィシ゛ャの = タィジャの
    db $EF,$EE                     ; $77F4  newline
    db $90,$90                     ; $77F6  　　(indent)
    db $43,$47,$4F,$29,$8D,$44,$2E,$43,$3D; $77F8  まもりか゛みさまの = まもりがみさまの
    db $90                         ; $7801  　(space)
    db $32,$8D,$26,$39,$50,$32,$8D,$26; $7802  そ゛うなるそ゛う = ぞうなるぞう
    db $99                         ; $780A  ！
    db $FA                         ; $780B  wait-for-button
    db $F7                         ; $780C  clear page
    db $EF,$EE                     ; $780D  newline
    db $9F                         ; $780F  box tag
    db $96                         ; $7810  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A     ; $7811  ほ゛うけんに = ぼうけんに
    db $90                         ; $7817  　(space)
    db $37,$8D,$29,$2C,$50,$43,$27,$3A; $7818  て゛かけるまえに = でかけるまえに
    db $EF,$EE                     ; $7820  newline
    db $90,$90                     ; $7822  　　(indent)
    db $42,$8D,$26,$2C,$55,$3D,$2F,$4D,$3E; $7824  ほ゛うけんのしょは = ぼうけんのしょは
    db $90                         ; $782D  　(space)
    db $35,$2C,$37,$28,$50,$29     ; $782E  つけておるか
    db $98                         ; $7834  ？
    db $FA                         ; $7835  wait-for-button
    db $F7                         ; $7836  clear page
    db $EF,$EE                     ; $7837  newline
    db $9F                         ; $7839  box tag
    db $96                         ; $783A  end name/box tag
    db $2D,$51,$3E                 ; $783B  これは
    db $90                         ; $783E  　(space)
    db $2A,$42,$55,$2F,$8D,$49,$32,$8D; $783F  きほんし゛ゃそ゛ = きほんじゃぞ
    db $99                         ; $7847  ！
    db $EF,$EE                     ; $7848  newline
    db $F7                         ; $784A  clear page
    db $F0                         ; $784B  end of message


; --------------------------------------------------------------------------
; Message #152 ($784C)
;   「まものには　きょういくが
;   ひつようですわ！
;   「レベルが　ひくいあいだのほうが
;   せいかくは　かえやすいのよ。
;   「としをとると　せいかくは
;   なかなか　かわらなくなるの。
;   「そういうところは　まものも
;   にんげんと　おなじね。
; --------------------------------------------------------------------------
Bank68_Msg152:                             ; $784C  (file $11384C)
    db $EB                         ; $784C  ▶ new page
    db $9F                         ; $784D  box tag
    db $96                         ; $784E  end name/box tag
    db $43,$47,$3D,$3A,$3E         ; $784F  まものには
    db $90                         ; $7854  　(space)
    db $2A,$4D,$26,$25,$2B,$29,$8D ; $7855  きょういくか゛ = きょういくが
    db $EF,$EE                     ; $785C  newline
    db $90,$90                     ; $785E  　　(indent)
    db $3F,$35,$4C,$26,$37,$8D,$30,$53; $7860  ひつようて゛すわ = ひつようですわ
    db $99                         ; $7868  ！
    db $FA                         ; $7869  wait-for-button
    db $F7                         ; $786A  clear page
    db $EF,$EE                     ; $786B  newline
    db $9F                         ; $786D  box tag
    db $96                         ; $786E  end name/box tag
    db $88,$78,$8D,$87,$29,$8D     ; $786F  レヘ゛ルか゛ = レベルが
    db $90                         ; $7875  　(space)
    db $3F,$2B,$25,$24,$25,$33,$8D,$3D,$42,$26,$29,$8D; $7876  ひくいあいた゛のほうか゛ = ひくいあいだのほうが
    db $EF,$EE                     ; $7882  newline
    db $90,$90                     ; $7884  　　(indent)
    db $31,$25,$29,$2B,$3E         ; $7886  せいかくは
    db $90                         ; $788B  　(space)
    db $29,$27,$48,$30,$25,$3D,$4C ; $788C  かえやすいのよ
    db $8F                         ; $7893  。
    db $FA                         ; $7894  wait-for-button
    db $F7                         ; $7895  clear page
    db $EF,$EE                     ; $7896  newline
    db $9F                         ; $7898  box tag
    db $96                         ; $7899  end name/box tag
    db $38,$2F,$54,$38,$50,$38     ; $789A  としをとると
    db $90                         ; $78A0  　(space)
    db $31,$25,$29,$2B,$3E         ; $78A1  せいかくは
    db $EF,$EE                     ; $78A6  newline
    db $90,$90                     ; $78A8  　　(indent)
    db $39,$29,$39,$29             ; $78AA  なかなか
    db $90                         ; $78AE  　(space)
    db $29,$53,$4E,$39,$2B,$39,$50,$3D; $78AF  かわらなくなるの
    db $8F                         ; $78B7  。
    db $FA                         ; $78B8  wait-for-button
    db $F7                         ; $78B9  clear page
    db $EF,$EE                     ; $78BA  newline
    db $9F                         ; $78BC  box tag
    db $96                         ; $78BD  end name/box tag
    db $32,$26,$25,$26,$38,$2D,$52,$3E; $78BE  そういうところは
    db $90                         ; $78C6  　(space)
    db $43,$47,$3D,$47             ; $78C7  まものも
    db $EF,$EE                     ; $78CB  newline
    db $90,$90                     ; $78CD  　　(indent)
    db $3A,$55,$2C,$8D,$55,$38     ; $78CF  にんけ゛んと = にんげんと
    db $90                         ; $78D5  　(space)
    db $28,$39,$2F,$8D,$3C         ; $78D6  おなし゛ね = おなじね
    db $8F                         ; $78DB  。
    db $F7                         ; $78DC  clear page
    db $F0                         ; $78DD  end of message


; --------------------------------------------------------------------------
; Message #153 ($78DE)
;   「さかばの　いりぐちにいるやつ！
;   あいつは　ォレのラィバルなんだ！
;   「あいつは　カミナリのとくぎを
;   もつ　まものを　もってやがる！
; --------------------------------------------------------------------------
Bank68_Msg153:                             ; $78DE  (file $1138DE)
    db $EA                         ; $78DE  ▶ new page
    db $9F                         ; $78DF  box tag
    db $96                         ; $78E0  end name/box tag
    db $2E,$29,$3E,$8D,$3D         ; $78E1  さかは゛の = さかばの
    db $90                         ; $78E6  　(space)
    db $25,$4F,$2B,$8D,$34,$3A,$25,$50,$48,$35; $78E7  いりく゛ちにいるやつ = いりぐちにいるやつ
    db $99                         ; $78F1  ！
    db $EF,$EE                     ; $78F2  newline
    db $90,$90                     ; $78F4  　　(indent)
    db $24,$25,$35,$3E             ; $78F6  あいつは
    db $90                         ; $78FA  　(space)
    db $5E,$88,$3D,$85,$58,$75,$8D,$87,$39,$55,$33,$8D; $78FB  ォレのラィハ゛ルなんた゛ = ォレのラィバルなんだ
    db $99                         ; $7907  ！
    db $FA                         ; $7908  wait-for-button
    db $F7                         ; $7909  clear page
    db $EF,$EE                     ; $790A  newline
    db $9F                         ; $790C  box tag
    db $96                         ; $790D  end name/box tag
    db $24,$25,$35,$3E             ; $790E  あいつは
    db $90                         ; $7912  　(space)
    db $60,$7B,$70,$86,$3D,$38,$2B,$2A,$8D,$54; $7913  カミナリのとくき゛を = カミナリのとくぎを
    db $EF,$EE                     ; $791D  newline
    db $90,$90                     ; $791F  　　(indent)
    db $47,$35                     ; $7921  もつ
    db $90                         ; $7923  　(space)
    db $43,$47,$3D,$54             ; $7924  まものを
    db $90                         ; $7928  　(space)
    db $47,$36,$37,$48,$29,$8D,$50 ; $7929  もってやか゛る = もってやがる
    db $99                         ; $7930  ！
    db $F7                         ; $7931  clear page
    db $F0                         ; $7932  end of message


; --------------------------------------------------------------------------
; Message #154 ($7933)
;   「ォレのラィバルは　きっとどこかで
;   ォレを　みはっているはずだ、。
;   「しかし　ォレのボーンプリズナーが
;   いるかぎり　やつにはまけん！！
; --------------------------------------------------------------------------
Bank68_Msg154:                             ; $7933  (file $113933)
    db $EA                         ; $7933  ▶ new page
    db $9F                         ; $7934  box tag
    db $96                         ; $7935  end name/box tag
    db $5E,$88,$3D,$85,$58,$75,$8D,$87,$3E; $7936  ォレのラィハ゛ルは = ォレのラィバルは
    db $90                         ; $793F  　(space)
    db $2A,$36,$38,$38,$8D,$2D,$29,$37,$8D; $7940  きっとと゛こかて゛ = きっとどこかで
    db $EF,$EE                     ; $7949  newline
    db $90,$90                     ; $794B  　　(indent)
    db $5E,$88,$54                 ; $794D  ォレを
    db $90                         ; $7950  　(space)
    db $44,$3E,$36,$37,$25,$50,$3E,$30,$8D,$33,$8D; $7951  みはっているはす゛た゛ = みはっているはずだ
    db $A4                         ; $795C  、
    db $8F                         ; $795D  。
    db $FA                         ; $795E  wait-for-button
    db $F7                         ; $795F  clear page
    db $EF,$EE                     ; $7960  newline
    db $9F                         ; $7962  box tag
    db $96                         ; $7963  end name/box tag
    db $2F,$29,$2F                 ; $7964  しかし
    db $90                         ; $7967  　(space)
    db $5E,$88,$3D,$79,$8D,$9C,$8C,$77,$8E,$86,$67,$8D,$70,$9C,$29,$8D; $7968  ォレのホ゛ーンフ゜リス゛ナーか゛ = ォレのボーンプリズナーが
    db $EF,$EE                     ; $7978  newline
    db $90,$90                     ; $797A  　　(indent)
    db $25,$50,$29,$2A,$8D,$4F     ; $797C  いるかき゛り = いるかぎり
    db $90                         ; $7982  　(space)
    db $48,$35,$3A,$3E,$43,$2C,$55 ; $7983  やつにはまけん
    db $99                         ; $798A  ！
    db $99                         ; $798B  ！
    db $F7                         ; $798C  clear page
    db $F0                         ; $798D  end of message


; --------------------------------------------------------------------------
; Message #155 ($798E)
;   「ぼうけんに　ももんじゃのしっぽを
;   もっていくのは　とうぜんだが、
;   「さらに　レミラーマそうと
;   ルーラのつえが　あれば　いいぞ！
;   「レミラーマそうを　つかえば
;   ぜんたいの　ちずがみられる。
;   「ルーラのつえは　あなのばしょに
;   いっしゅんで　はこんでくれるぞ！
;   「よそみしておると　ばくだんいわが
;   さぼると　いかんので　これで。
; --------------------------------------------------------------------------
Bank68_Msg155:                             ; $798E  (file $11398E)
    db $EA                         ; $798E  ▶ new page
    db $9F                         ; $798F  box tag
    db $96                         ; $7990  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A     ; $7991  ほ゛うけんに = ぼうけんに
    db $90                         ; $7997  　(space)
    db $47,$47,$55,$2F,$8D,$49,$3D,$2F,$36,$42,$8E,$54; $7998  ももんし゛ゃのしっほ゜を = ももんじゃのしっぽを
    db $EF,$EE                     ; $79A4  newline
    db $90,$90                     ; $79A6  　　(indent)
    db $47,$36,$37,$25,$2B,$3D,$3E ; $79A8  もっていくのは
    db $90                         ; $79AF  　(space)
    db $38,$26,$31,$8D,$55,$33,$8D,$29,$8D; $79B0  とうせ゛んた゛か゛ = とうぜんだが
    db $A4                         ; $79B9  、
    db $FA                         ; $79BA  wait-for-button
    db $F7                         ; $79BB  clear page
    db $EF,$EE                     ; $79BC  newline
    db $9F                         ; $79BE  box tag
    db $96                         ; $79BF  end name/box tag
    db $2E,$4E,$3A                 ; $79C0  さらに
    db $90                         ; $79C3  　(space)
    db $88,$7B,$85,$9C,$7A,$32,$26,$38; $79C4  レミラーマそうと
    db $EF,$EE                     ; $79CC  newline
    db $90,$90                     ; $79CE  　　(indent)
    db $87,$9C,$85,$3D,$35,$27,$29,$8D; $79D0  ルーラのつえか゛ = ルーラのつえが
    db $90                         ; $79D8  　(space)
    db $24,$51,$3E,$8D             ; $79D9  あれは゛ = あれば
    db $90                         ; $79DD  　(space)
    db $25,$25,$32,$8D             ; $79DE  いいそ゛ = いいぞ
    db $99                         ; $79E2  ！
    db $FA                         ; $79E3  wait-for-button
    db $F7                         ; $79E4  clear page
    db $EF,$EE                     ; $79E5  newline
    db $9F                         ; $79E7  box tag
    db $96                         ; $79E8  end name/box tag
    db $88,$7B,$85,$9C,$7A,$32,$26,$54; $79E9  レミラーマそうを
    db $90                         ; $79F1  　(space)
    db $35,$29,$27,$3E,$8D         ; $79F2  つかえは゛ = つかえば
    db $EF,$EE                     ; $79F7  newline
    db $90,$90                     ; $79F9  　　(indent)
    db $31,$8D,$55,$33,$25,$3D     ; $79FB  せ゛んたいの = ぜんたいの
    db $90                         ; $7A01  　(space)
    db $34,$30,$8D,$29,$8D,$44,$4E,$51,$50; $7A02  ちす゛か゛みられる = ちずがみられる
    db $8F                         ; $7A0B  。
    db $FA                         ; $7A0C  wait-for-button
    db $F7                         ; $7A0D  clear page
    db $EF,$EE                     ; $7A0E  newline
    db $9F                         ; $7A10  box tag
    db $96                         ; $7A11  end name/box tag
    db $87,$9C,$85,$3D,$35,$27,$3E ; $7A12  ルーラのつえは
    db $90                         ; $7A19  　(space)
    db $24,$39,$3D,$3E,$8D,$2F,$4D,$3A; $7A1A  あなのは゛しょに = あなのばしょに
    db $EF,$EE                     ; $7A22  newline
    db $90,$90                     ; $7A24  　　(indent)
    db $25,$36,$2F,$4B,$55,$37,$8D ; $7A26  いっしゅんて゛ = いっしゅんで
    db $90                         ; $7A2D  　(space)
    db $3E,$2D,$55,$37,$8D,$2B,$51,$50,$32,$8D; $7A2E  はこんて゛くれるそ゛ = はこんでくれるぞ
    db $99                         ; $7A38  ！
    db $FA                         ; $7A39  wait-for-button
    db $F7                         ; $7A3A  clear page
    db $EF,$EE                     ; $7A3B  newline
    db $9F                         ; $7A3D  box tag
    db $96                         ; $7A3E  end name/box tag
    db $4C,$32,$44,$2F,$37,$28,$50,$38; $7A3F  よそみしておると
    db $90                         ; $7A47  　(space)
    db $3E,$8D,$2B,$33,$8D,$55,$25,$53,$29,$8D; $7A48  は゛くた゛んいわか゛ = ばくだんいわが
    db $EF,$EE                     ; $7A52  newline
    db $90,$90                     ; $7A54  　　(indent)
    db $2E,$42,$8D,$50,$38         ; $7A56  さほ゛ると = さぼると
    db $90                         ; $7A5B  　(space)
    db $25,$29,$55,$3D,$37,$8D     ; $7A5C  いかんのて゛ = いかんので
    db $90                         ; $7A62  　(space)
    db $2D,$51,$37,$8D             ; $7A63  これて゛ = これで
    db $8F                         ; $7A67  。
    db $F7                         ; $7A68  clear page
    db $F0                         ; $7A69  end of message


; --------------------------------------------------------------------------
; Message #156 ($7A6A)
;   「えいほ！　えいほ！
;   「いったい　いつまで
;   やらせるんじゃろ？
; --------------------------------------------------------------------------
Bank68_Msg156:                             ; $7A6A  (file $113A6A)
    db $EA                         ; $7A6A  ▶ new page
    db $9F                         ; $7A6B  box tag
    db $96                         ; $7A6C  end name/box tag
    db $27,$25,$42                 ; $7A6D  えいほ
    db $99                         ; $7A70  ！
    db $90                         ; $7A71  　(space)
    db $27,$25,$42                 ; $7A72  えいほ
    db $99                         ; $7A75  ！
    db $EF,$EE                     ; $7A76  newline
    db $FA                         ; $7A78  wait-for-button
    db $F7                         ; $7A79  clear page
    db $EF,$EE                     ; $7A7A  newline
    db $F3                         ; $7A7C  open text box
    db $9F                         ; $7A7D  box tag
    db $96                         ; $7A7E  end name/box tag
    db $25,$36,$33,$25             ; $7A7F  いったい
    db $90                         ; $7A83  　(space)
    db $25,$35,$43,$37,$8D         ; $7A84  いつまて゛ = いつまで
    db $EF,$EE                     ; $7A89  newline
    db $90,$90                     ; $7A8B  　　(indent)
    db $48,$4E,$31,$50,$55,$2F,$8D,$49,$52; $7A8D  やらせるんし゛ゃろ = やらせるんじゃろ
    db $98                         ; $7A96  ？
    db $F7                         ; $7A97  clear page
    db $F0                         ; $7A98  end of message


; --------------------------------------------------------------------------
; Message #157 ($7A99)
;   「へへっ！　にいちゃんよ[95]。
;   [0D]クラスのあいてを　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg157:                             ; $7A99  (file $113A99)
    db $EA                         ; $7A99  ▶ new page
    db $9F                         ; $7A9A  box tag
    db $96                         ; $7A9B  end name/box tag
    db $41,$41,$36                 ; $7A9C  へへっ
    db $99                         ; $7A9F  ！
    db $90                         ; $7AA0  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $7AA1  にいちゃんよ
    db $95                         ; $7AA7  ctrl $95
    db $8F                         ; $7AA8  。
    db $EF,$EE                     ; $7AA9  newline
    db $90,$90                     ; $7AAB  　　(indent)
    db $0D                         ; $7AAD  ctrl $0D
    db $62,$85,$67,$3D,$24,$25,$37,$54; $7AAE  クラスのあいてを
    db $90                         ; $7AB6  　(space)
    db $2F,$4F,$33,$25,$29         ; $7AB7  しりたいか
    db $98                         ; $7ABC  ？
    db $FF                         ; $7ABD  はい/いいえ
    db $F0                         ; $7ABE  end of message


; --------------------------------------------------------------------------
; Message #158 ($7ABF)
;   「[0D]クラスの　さいしゅうせんは
;   ミッキーが　あいてだぜ。
;   「やつのまものは　さまようよろいと
;   キラーパンサーが　[02]たいだ。
;   「キラーパンサーは　しっぷうづきを
;   くりだしてくる。
;   「たいりょくが　すくないと
;   あっというまに　やられるぞ！
; --------------------------------------------------------------------------
Bank68_Msg158:                             ; $7ABF  (file $113ABF)
    db $EA                         ; $7ABF  ▶ new page
    db $9F                         ; $7AC0  box tag
    db $96                         ; $7AC1  end name/box tag
    db $0D                         ; $7AC2  ctrl $0D
    db $62,$85,$67,$3D             ; $7AC3  クラスの
    db $90                         ; $7AC7  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $7AC8  さいしゅうせんは
    db $EF,$EE                     ; $7AD0  newline
    db $90,$90                     ; $7AD2  　　(indent)
    db $7B,$6D,$61,$9C,$29,$8D     ; $7AD4  ミッキーか゛ = ミッキーが
    db $90                         ; $7ADA  　(space)
    db $24,$25,$37,$33,$8D,$31,$8D ; $7ADB  あいてた゛せ゛ = あいてだぜ
    db $8F                         ; $7AE2  。
    db $FA                         ; $7AE3  wait-for-button
    db $F7                         ; $7AE4  clear page
    db $EF,$EE                     ; $7AE5  newline
    db $9F                         ; $7AE7  box tag
    db $96                         ; $7AE8  end name/box tag
    db $48,$35,$3D,$43,$47,$3D,$3E ; $7AE9  やつのまものは
    db $90                         ; $7AF0  　(space)
    db $2E,$43,$4C,$26,$4C,$52,$25,$38; $7AF1  さまようよろいと
    db $EF,$EE                     ; $7AF9  newline
    db $90,$90                     ; $7AFB  　　(indent)
    db $61,$85,$9C,$75,$8E,$8C,$65,$9C,$29,$8D; $7AFD  キラーハ゜ンサーか゛ = キラーパンサーが
    db $90                         ; $7B07  　(space)
    db $02                         ; $7B08  ctrl $02
    db $33,$25,$33,$8D             ; $7B09  たいた゛ = たいだ
    db $8F                         ; $7B0D  。
    db $FA                         ; $7B0E  wait-for-button
    db $F7                         ; $7B0F  clear page
    db $EF,$EE                     ; $7B10  newline
    db $9F                         ; $7B12  box tag
    db $96                         ; $7B13  end name/box tag
    db $61,$85,$9C,$75,$8E,$8C,$65,$9C,$3E; $7B14  キラーハ゜ンサーは = キラーパンサーは
    db $90                         ; $7B1D  　(space)
    db $2F,$36,$40,$8E,$26,$35,$8D,$2A,$54; $7B1E  しっふ゜うつ゛きを = しっぷうづきを
    db $EF,$EE                     ; $7B27  newline
    db $90,$90                     ; $7B29  　　(indent)
    db $2B,$4F,$33,$8D,$2F,$37,$2B,$50; $7B2B  くりた゛してくる = くりだしてくる
    db $8F                         ; $7B33  。
    db $FA                         ; $7B34  wait-for-button
    db $F7                         ; $7B35  clear page
    db $EF,$EE                     ; $7B36  newline
    db $9F                         ; $7B38  box tag
    db $96                         ; $7B39  end name/box tag
    db $33,$25,$4F,$4D,$2B,$29,$8D ; $7B3A  たいりょくか゛ = たいりょくが
    db $90                         ; $7B41  　(space)
    db $30,$2B,$39,$25,$38         ; $7B42  すくないと
    db $EF,$EE                     ; $7B47  newline
    db $90,$90                     ; $7B49  　　(indent)
    db $24,$36,$38,$25,$26,$43,$3A ; $7B4B  あっというまに
    db $90                         ; $7B52  　(space)
    db $48,$4E,$51,$50,$32,$8D     ; $7B53  やられるそ゛ = やられるぞ
    db $99                         ; $7B59  ！
    db $F7                         ; $7B5A  clear page
    db $F0                         ; $7B5B  end of message


; --------------------------------------------------------------------------
; Message #159 ($7B5C)
;   「これはチョップステイック。ベベ！
;   いってごらんなさい！　せーの！
; --------------------------------------------------------------------------
Bank68_Msg159:                             ; $7B5C  (file $113B5C)
    db $EA                         ; $7B5C  ▶ new page
    db $9F                         ; $7B5D  box tag
    db $96                         ; $7B5E  end name/box tag
    db $2D,$51,$3E,$6B,$84,$6D,$77,$8E,$67,$6E,$59,$6D,$62; $7B5F  これはチョッフ゜ステイック = これはチョップステイック
    db $8F                         ; $7B6C  。
    db $78,$8D,$78,$8D             ; $7B6D  ヘ゛ヘ゛ = ベベ
    db $99                         ; $7B71  ！
    db $EF,$EE                     ; $7B72  newline
    db $90,$90                     ; $7B74  　　(indent)
    db $25,$36,$37,$2D,$8D,$4E,$55,$39,$2E,$25; $7B76  いってこ゛らんなさい = いってごらんなさい
    db $99                         ; $7B80  ！
    db $90                         ; $7B81  　(space)
    db $31,$9C,$3D                 ; $7B82  せーの
    db $99                         ; $7B85  ！
    db $F7                         ; $7B86  clear page
    db $F0                         ; $7B87  end of message


; --------------------------------------------------------------------------
; Message #160 ($7B88)
;   「チョップステイックって　なんだ！
;   わりばしって　いわんか！！
; --------------------------------------------------------------------------
Bank68_Msg160:                             ; $7B88  (file $113B88)
    db $EA                         ; $7B88  ▶ new page
    db $9F                         ; $7B89  box tag
    db $96                         ; $7B8A  end name/box tag
    db $6B,$84,$6D,$77,$8E,$67,$6E,$59,$6D,$62,$36,$37; $7B8B  チョッフ゜ステイックって = チョップステイックって
    db $90                         ; $7B97  　(space)
    db $39,$55,$33,$8D             ; $7B98  なんた゛ = なんだ
    db $99                         ; $7B9C  ！
    db $EF,$EE                     ; $7B9D  newline
    db $90,$90                     ; $7B9F  　　(indent)
    db $53,$4F,$3E,$8D,$2F,$36,$37 ; $7BA1  わりは゛しって = わりばしって
    db $90                         ; $7BA8  　(space)
    db $25,$53,$55,$29             ; $7BA9  いわんか
    db $99                         ; $7BAD  ！
    db $99                         ; $7BAE  ！
    db $F7                         ; $7BAF  clear page
    db $F0                         ; $7BB0  end of message


; --------------------------------------------------------------------------
; Message #161 ($7BB1)
;   「モンスターじいさんは　どうやって
;   はいごうを　おこなうのだろう？
;   「へやのおくの　たちいりきんしの
;   ばしょが　あやしいな！
; --------------------------------------------------------------------------
Bank68_Msg161:                             ; $7BB1  (file $113BB1)
    db $EA                         ; $7BB1  ▶ new page
    db $9F                         ; $7BB2  box tag
    db $96                         ; $7BB3  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55,$3E; $7BB4  モンスターし゛いさんは = モンスターじいさんは
    db $90                         ; $7BBF  　(space)
    db $38,$8D,$26,$48,$36,$37     ; $7BC0  と゛うやって = どうやって
    db $EF,$EE                     ; $7BC6  newline
    db $90,$90                     ; $7BC8  　　(indent)
    db $3E,$25,$2D,$8D,$26,$54     ; $7BCA  はいこ゛うを = はいごうを
    db $90                         ; $7BD0  　(space)
    db $28,$2D,$39,$26,$3D,$33,$8D,$52,$26; $7BD1  おこなうのた゛ろう = おこなうのだろう
    db $98                         ; $7BDA  ？
    db $FA                         ; $7BDB  wait-for-button
    db $F7                         ; $7BDC  clear page
    db $EF,$EE                     ; $7BDD  newline
    db $9F                         ; $7BDF  box tag
    db $96                         ; $7BE0  end name/box tag
    db $41,$48,$3D,$28,$2B,$3D     ; $7BE1  へやのおくの
    db $90                         ; $7BE7  　(space)
    db $33,$34,$25,$4F,$2A,$55,$2F,$3D; $7BE8  たちいりきんしの
    db $EF,$EE                     ; $7BF0  newline
    db $90,$90                     ; $7BF2  　　(indent)
    db $3E,$8D,$2F,$4D,$29,$8D     ; $7BF4  は゛しょか゛ = ばしょが
    db $90                         ; $7BFA  　(space)
    db $24,$48,$2F,$25,$39         ; $7BFB  あやしいな
    db $99                         ; $7C00  ！
    db $F7                         ; $7C01  clear page
    db $F0                         ; $7C02  end of message


; --------------------------------------------------------------------------
; Message #162 ($7C03)
;   「おじさんは　いつも
;   ィソィソ　しているよ。
;   「ときどき　おくさんが　かえって
;   こないって　かなしむんだ、。
; --------------------------------------------------------------------------
Bank68_Msg162:                             ; $7C03  (file $113C03)
    db $EB                         ; $7C03  ▶ new page
    db $9F                         ; $7C04  box tag
    db $96                         ; $7C05  end name/box tag
    db $28,$2F,$8D,$2E,$55,$3E     ; $7C06  おし゛さんは = おじさんは
    db $90                         ; $7C0C  　(space)
    db $25,$35,$47                 ; $7C0D  いつも
    db $EF,$EE                     ; $7C10  newline
    db $90,$90                     ; $7C12  　　(indent)
    db $58,$69,$58,$69             ; $7C14  ィソィソ
    db $90                         ; $7C18  　(space)
    db $2F,$37,$25,$50,$4C         ; $7C19  しているよ
    db $8F                         ; $7C1E  。
    db $FA                         ; $7C1F  wait-for-button
    db $F7                         ; $7C20  clear page
    db $EF,$EE                     ; $7C21  newline
    db $9F                         ; $7C23  box tag
    db $96                         ; $7C24  end name/box tag
    db $38,$2A,$38,$8D,$2A         ; $7C25  ときと゛き = ときどき
    db $90                         ; $7C2A  　(space)
    db $28,$2B,$2E,$55,$29,$8D     ; $7C2B  おくさんか゛ = おくさんが
    db $90                         ; $7C31  　(space)
    db $29,$27,$36,$37             ; $7C32  かえって
    db $EF,$EE                     ; $7C36  newline
    db $90,$90                     ; $7C38  　　(indent)
    db $2D,$39,$25,$36,$37         ; $7C3A  こないって
    db $90                         ; $7C3F  　(space)
    db $29,$39,$2F,$45,$55,$33,$8D ; $7C40  かなしむんた゛ = かなしむんだ
    db $A4                         ; $7C47  、
    db $8F                         ; $7C48  。
    db $F7                         ; $7C49  clear page
    db $F0                         ; $7C4A  end of message


; --------------------------------------------------------------------------
; Message #163 ($7C4B)
;   「きみを　ゆうしゅうな　マスターと
;   みこんで　たのみたいことがある！
;   「じつは　まものを　よみがえらせる
;   けんきゅうをしているのだが、
;   「カミナリのとくぎをもつ　まものが
;   ひつようになったのだよ。
;   「どうだろう？　カミナリのとくぎを
;   もつまものを　ゆずってくれんか？
;   「もちろん　おれいは　しよう。
;   、、その　ばあさんを　あげよう！
; --------------------------------------------------------------------------
Bank68_Msg163:                             ; $7C4B  (file $113C4B)
    db $EA                         ; $7C4B  ▶ new page
    db $9F                         ; $7C4C  box tag
    db $96                         ; $7C4D  end name/box tag
    db $2A,$44,$54                 ; $7C4E  きみを
    db $90                         ; $7C51  　(space)
    db $4A,$26,$2F,$4B,$26,$39     ; $7C52  ゆうしゅうな
    db $90                         ; $7C58  　(space)
    db $7A,$67,$6A,$9C,$38         ; $7C59  マスターと
    db $EF,$EE                     ; $7C5E  newline
    db $90,$90                     ; $7C60  　　(indent)
    db $44,$2D,$55,$37,$8D         ; $7C62  みこんて゛ = みこんで
    db $90                         ; $7C67  　(space)
    db $33,$3D,$44,$33,$25,$2D,$38,$29,$8D,$24,$50; $7C68  たのみたいことか゛ある = たのみたいことがある
    db $99                         ; $7C73  ！
    db $FA                         ; $7C74  wait-for-button
    db $F7                         ; $7C75  clear page
    db $EF,$EE                     ; $7C76  newline
    db $9F                         ; $7C78  box tag
    db $96                         ; $7C79  end name/box tag
    db $2F,$8D,$35,$3E             ; $7C7A  し゛つは = じつは
    db $90                         ; $7C7E  　(space)
    db $43,$47,$3D,$54             ; $7C7F  まものを
    db $90                         ; $7C83  　(space)
    db $4C,$44,$29,$8D,$27,$4E,$31,$50; $7C84  よみか゛えらせる = よみがえらせる
    db $EF,$EE                     ; $7C8C  newline
    db $90,$90                     ; $7C8E  　　(indent)
    db $2C,$55,$2A,$4B,$26,$54,$2F,$37,$25,$50,$3D,$33,$8D,$29,$8D; $7C90  けんきゅうをしているのた゛か゛ = けんきゅうをしているのだが
    db $A4                         ; $7C9F  、
    db $FA                         ; $7CA0  wait-for-button
    db $F7                         ; $7CA1  clear page
    db $EF,$EE                     ; $7CA2  newline
    db $9F                         ; $7CA4  box tag
    db $96                         ; $7CA5  end name/box tag
    db $60,$7B,$70,$86,$3D,$38,$2B,$2A,$8D,$54,$47,$35; $7CA6  カミナリのとくき゛をもつ = カミナリのとくぎをもつ
    db $90                         ; $7CB2  　(space)
    db $43,$47,$3D,$29,$8D         ; $7CB3  まものか゛ = まものが
    db $EF,$EE                     ; $7CB8  newline
    db $90,$90                     ; $7CBA  　　(indent)
    db $3F,$35,$4C,$26,$3A,$39,$36,$33,$3D,$33,$8D,$4C; $7CBC  ひつようになったのた゛よ = ひつようになったのだよ
    db $8F                         ; $7CC8  。
    db $FA                         ; $7CC9  wait-for-button
    db $F7                         ; $7CCA  clear page
    db $EF,$EE                     ; $7CCB  newline
    db $9F                         ; $7CCD  box tag
    db $96                         ; $7CCE  end name/box tag
    db $38,$8D,$26,$33,$8D,$52,$26 ; $7CCF  と゛うた゛ろう = どうだろう
    db $98                         ; $7CD6  ？
    db $90                         ; $7CD7  　(space)
    db $60,$7B,$70,$86,$3D,$38,$2B,$2A,$8D,$54; $7CD8  カミナリのとくき゛を = カミナリのとくぎを
    db $EF,$EE                     ; $7CE2  newline
    db $90,$90                     ; $7CE4  　　(indent)
    db $47,$35,$43,$47,$3D,$54     ; $7CE6  もつまものを
    db $90                         ; $7CEC  　(space)
    db $4A,$30,$8D,$36,$37,$2B,$51,$55,$29; $7CED  ゆす゛ってくれんか = ゆずってくれんか
    db $98                         ; $7CF6  ？
    db $FA                         ; $7CF7  wait-for-button
    db $F7                         ; $7CF8  clear page
    db $EF,$EE                     ; $7CF9  newline
    db $9F                         ; $7CFB  box tag
    db $96                         ; $7CFC  end name/box tag
    db $47,$34,$52,$55             ; $7CFD  もちろん
    db $90                         ; $7D01  　(space)
    db $28,$51,$25,$3E             ; $7D02  おれいは
    db $90                         ; $7D06  　(space)
    db $2F,$4C,$26                 ; $7D07  しよう
    db $8F                         ; $7D0A  。
    db $EF,$EE                     ; $7D0B  newline
    db $90,$90                     ; $7D0D  　　(indent)
    db $A4                         ; $7D0F  、
    db $A4                         ; $7D10  、
    db $32,$3D                     ; $7D11  その
    db $90                         ; $7D13  　(space)
    db $3E,$8D,$24,$2E,$55,$54     ; $7D14  は゛あさんを = ばあさんを
    db $90                         ; $7D1A  　(space)
    db $24,$2C,$8D,$4C,$26         ; $7D1B  あけ゛よう = あげよう
    db $99                         ; $7D20  ！
    db $F7                         ; $7D21  clear page
    db $F0                         ; $7D22  end of message


; --------------------------------------------------------------------------
; Message #164 ($7D23)
;   「そうか。　カミナリのとくぎをもつ
;   まものを　みつけたら　たのむ！
; --------------------------------------------------------------------------
Bank68_Msg164:                             ; $7D23  (file $113D23)
    db $EA                         ; $7D23  ▶ new page
    db $9F                         ; $7D24  box tag
    db $96                         ; $7D25  end name/box tag
    db $32,$26,$29                 ; $7D26  そうか
    db $8F                         ; $7D29  。
    db $90                         ; $7D2A  　(space)
    db $60,$7B,$70,$86,$3D,$38,$2B,$2A,$8D,$54,$47,$35; $7D2B  カミナリのとくき゛をもつ = カミナリのとくぎをもつ
    db $EF,$EE                     ; $7D37  newline
    db $90,$90                     ; $7D39  　　(indent)
    db $43,$47,$3D,$54             ; $7D3B  まものを
    db $90                         ; $7D3F  　(space)
    db $44,$35,$2C,$33,$4E         ; $7D40  みつけたら
    db $90                         ; $7D45  　(space)
    db $33,$3D,$45                 ; $7D46  たのむ
    db $99                         ; $7D49  ！
    db $F7                         ; $7D4A  clear page
    db $F0                         ; $7D4B  end of message


; --------------------------------------------------------------------------
; Message #165 ($7D4C)
;   「なんだ　もっていないのか。
;   ばあさんをあげるから　たのむぞ！
; --------------------------------------------------------------------------
Bank68_Msg165:                             ; $7D4C  (file $113D4C)
    db $EA                         ; $7D4C  ▶ new page
    db $9F                         ; $7D4D  box tag
    db $96                         ; $7D4E  end name/box tag
    db $39,$55,$33,$8D             ; $7D4F  なんた゛ = なんだ
    db $90                         ; $7D53  　(space)
    db $47,$36,$37,$25,$39,$25,$3D,$29; $7D54  もっていないのか
    db $8F                         ; $7D5C  。
    db $EF,$EE                     ; $7D5D  newline
    db $90,$90                     ; $7D5F  　　(indent)
    db $3E,$8D,$24,$2E,$55,$54,$24,$2C,$8D,$50,$29,$4E; $7D61  は゛あさんをあけ゛るから = ばあさんをあげるから
    db $90                         ; $7D6D  　(space)
    db $33,$3D,$45,$32,$8D         ; $7D6E  たのむそ゛ = たのむぞ
    db $99                         ; $7D73  ！
    db $F7                         ; $7D74  clear page
    db $F0                         ; $7D75  end of message


; --------------------------------------------------------------------------
; Message #166 ($7D76)
;   「おお！　つれてきてくれたか！！
;   それでは、、
; --------------------------------------------------------------------------
Bank68_Msg166:                             ; $7D76  (file $113D76)
    db $EA                         ; $7D76  ▶ new page
    db $9F                         ; $7D77  box tag
    db $96                         ; $7D78  end name/box tag
    db $28,$28                     ; $7D79  おお
    db $99                         ; $7D7B  ！
    db $90                         ; $7D7C  　(space)
    db $35,$51,$37,$2A,$37,$2B,$51,$33,$29; $7D7D  つれてきてくれたか
    db $99                         ; $7D86  ！
    db $99                         ; $7D87  ！
    db $EF,$EE                     ; $7D88  newline
    db $90,$90                     ; $7D8A  　　(indent)
    db $32,$51,$37,$8D,$3E         ; $7D8C  それて゛は = それでは
    db $A4                         ; $7D91  、
    db $A4                         ; $7D92  、
    db $FA                         ; $7D93  wait-for-button
    db $F7                         ; $7D94  clear page
    db $F0                         ; $7D95  end of message


; --------------------------------------------------------------------------
; Message #167 ($7D96)
;   「[F9][00]を　もらっても
;   いいかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg167:                             ; $7D96  (file $113D96)
    db $EA                         ; $7D96  ▶ new page
    db $9F                         ; $7D97  box tag
    db $96                         ; $7D98  end name/box tag
    db $F9                         ; $7D99  ctrl $F9
    db $00                         ; $7D9A  ctrl $00
    db $54                         ; $7D9B  を
    db $90                         ; $7D9C  　(space)
    db $47,$4E,$36,$37,$47         ; $7D9D  もらっても
    db $EF,$EE                     ; $7DA2  newline
    db $90,$90                     ; $7DA4  　　(indent)
    db $25,$25,$29,$3C             ; $7DA6  いいかね
    db $98                         ; $7DAA  ？
    db $FF                         ; $7DAB  はい/いいえ
    db $F0                         ; $7DAC  end of message


; --------------------------------------------------------------------------
; Message #168 ($7DAD)
;   「これで　じっけんが　ためせる！
;   ありがとう！　〈テリー〉くん！！
;   「じっけんが　せいこうしたら
;   ばあさんは　つれていってくれ！
; --------------------------------------------------------------------------
Bank68_Msg168:                             ; $7DAD  (file $113DAD)
    db $EA                         ; $7DAD  ▶ new page
    db $9F                         ; $7DAE  box tag
    db $96                         ; $7DAF  end name/box tag
    db $2D,$51,$37,$8D             ; $7DB0  これて゛ = これで
    db $90                         ; $7DB4  　(space)
    db $2F,$8D,$36,$2C,$55,$29,$8D ; $7DB5  し゛っけんか゛ = じっけんが
    db $90                         ; $7DBC  　(space)
    db $33,$46,$31,$50             ; $7DBD  ためせる
    db $99                         ; $7DC1  ！
    db $EF,$EE                     ; $7DC2  newline
    db $90,$90                     ; $7DC4  　　(indent)
    db $24,$4F,$29,$8D,$38,$26     ; $7DC6  ありか゛とう = ありがとう
    db $99                         ; $7DCC  ！
    db $90                         ; $7DCD  　(space)
    db $F6                         ; $7DCE  «insert hero name»
    db $2B,$55                     ; $7DCF  くん
    db $99                         ; $7DD1  ！
    db $99                         ; $7DD2  ！
    db $FA                         ; $7DD3  wait-for-button
    db $F7                         ; $7DD4  clear page
    db $EF,$EE                     ; $7DD5  newline
    db $9F                         ; $7DD7  box tag
    db $96                         ; $7DD8  end name/box tag
    db $2F,$8D,$36,$2C,$55,$29,$8D ; $7DD9  し゛っけんか゛ = じっけんが
    db $90                         ; $7DE0  　(space)
    db $31,$25,$2D,$26,$2F,$33,$4E ; $7DE1  せいこうしたら
    db $EF,$EE                     ; $7DE8  newline
    db $90,$90                     ; $7DEA  　　(indent)
    db $3E,$8D,$24,$2E,$55,$3E     ; $7DEC  は゛あさんは = ばあさんは
    db $90                         ; $7DF2  　(space)
    db $35,$51,$37,$25,$36,$37,$2B,$51; $7DF3  つれていってくれ
    db $99                         ; $7DFB  ！
    db $F7                         ; $7DFC  clear page
    db $F0                         ; $7DFD  end of message


; --------------------------------------------------------------------------
; Message #169 ($7DFE)
;   「ざんねんだな、、。
;   つぎこそ　たのむぞ！
; --------------------------------------------------------------------------
Bank68_Msg169:                             ; $7DFE  (file $113DFE)
    db $EA                         ; $7DFE  ▶ new page
    db $9F                         ; $7DFF  box tag
    db $96                         ; $7E00  end name/box tag
    db $2E,$8D,$55,$3C,$55,$33,$8D,$39; $7E01  さ゛んねんた゛な = ざんねんだな
    db $A4                         ; $7E09  、
    db $A4                         ; $7E0A  、
    db $8F                         ; $7E0B  。
    db $EF,$EE                     ; $7E0C  newline
    db $90,$90                     ; $7E0E  　　(indent)
    db $35,$2A,$8D,$2D,$32         ; $7E10  つき゛こそ = つぎこそ
    db $90                         ; $7E15  　(space)
    db $33,$3D,$45,$32,$8D         ; $7E16  たのむそ゛ = たのむぞ
    db $99                         ; $7E1B  ！
    db $F7                         ; $7E1C  clear page
    db $F0                         ; $7E1D  end of message


; --------------------------------------------------------------------------
; Message #170 ($7E1E)
;   「それでは　[F9][00]を
;   もらってもいいかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg170:                             ; $7E1E  (file $113E1E)
    db $EA                         ; $7E1E  ▶ new page
    db $9F                         ; $7E1F  box tag
    db $96                         ; $7E20  end name/box tag
    db $32,$51,$37,$8D,$3E         ; $7E21  それて゛は = それでは
    db $90                         ; $7E26  　(space)
    db $F9                         ; $7E27  ctrl $F9
    db $00                         ; $7E28  ctrl $00
    db $54                         ; $7E29  を
    db $EF,$EE                     ; $7E2A  newline
    db $90,$90                     ; $7E2C  　　(indent)
    db $47,$4E,$36,$37,$47,$25,$25,$29,$3C; $7E2E  もらってもいいかね
    db $98                         ; $7E37  ？
    db $FF                         ; $7E38  はい/いいえ
    db $F0                         ; $7E39  end of message


; --------------------------------------------------------------------------
; Message #171 ($7E3A)
;   「カミナリのとくぎを　もつまものを
;   つれてきて　くれたかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank68_Msg171:                             ; $7E3A  (file $113E3A)
    db $EA                         ; $7E3A  ▶ new page
    db $9F                         ; $7E3B  box tag
    db $96                         ; $7E3C  end name/box tag
    db $60,$7B,$70,$86,$3D,$38,$2B,$2A,$8D,$54; $7E3D  カミナリのとくき゛を = カミナリのとくぎを
    db $90                         ; $7E47  　(space)
    db $47,$35,$43,$47,$3D,$54     ; $7E48  もつまものを
    db $EF,$EE                     ; $7E4E  newline
    db $90,$90                     ; $7E50  　　(indent)
    db $35,$51,$37,$2A,$37         ; $7E52  つれてきて
    db $90                         ; $7E57  　(space)
    db $2B,$51,$33,$29,$3C         ; $7E58  くれたかね
    db $98                         ; $7E5D  ？
    db $FF                         ; $7E5E  はい/いいえ
    db $F0                         ; $7E5F  end of message

Bank68_Pad:                                ; $7E60
    ds $01A0, $FF                   ; $FF padding to $8000
