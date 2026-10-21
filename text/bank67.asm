; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 67  (DIALOGUE / MESSAGE TEXT — battle-arena NPCs)
; ==========================================================================
;
; Flat sentence bank (like bank66). Kana dialogue for the かくとうじょう
; (battle arena / tournament): the arena hostess, class-clear lines, the
; King's messenger わたほ゛う, a monster scholar, etc. Codec: memory text-codec.
;
;   File offset $10C000-$10FFFF  |  self-ID $4000 = $43
;   $401C : word -> $4020  (message-pointer table)
;   $4020 : 182 little-endian string pointers -> kana messages ($418C..)
; Function table $4001: fn0 $4007 (window), fn1 $400E (copy), fn2 $4015 (print)
; All 182 messages decoded below, ASCENDING ADDRESS order, byte-exact.
; ==========================================================================

SECTION "Bank 67", ROMX[$4000], BANK[67]

    db $43                          ; $4000  self-ID
    dw $4007,$400E,$4015          ; $4001  fn table
    db $11,$1C,$40,$CD,$68,$05,$C9 ; $4007  Fn0: LD DE,$401C/CALL $0568/RET
    db $11,$1C,$40,$CD,$A7,$05,$C9 ; $400E  Fn1: LD DE,$401C/CALL $05A7/RET
    db $CD,$07,$40,$CD,$BA,$05,$C9 ; $4015  Fn2: CALL $4007/CALL $05BA/RET

Bank67_MsgDir:                             ; $401C
    dw $4020                         ; header word -> table
    db $5C,$40   ; $401E pre-table bytes
Bank67_MsgTable:                           ; $4020  (182 string pointers)
    dw $418C,$42EF,$436C,$438A,$43CF,$43F7,$4532,$456F
    dw $4595,$45B6,$45CD,$45F1,$4688,$469B,$46E3,$46F5
    dw $4714,$4727,$47BA,$47D4,$47F8,$482F,$4886,$4898
    dw $48E7,$48FD,$4959,$49C0,$49E0,$4A0C,$4AB4,$4B06
    dw $4B71,$4BB4,$4C05,$4C2B,$4C54,$4C6A,$4C91,$4D7E
    dw $4DA5,$4DCD,$4DF9,$4E0F,$4E19,$4E41,$4EBD,$4F84
    dw $4FA9,$5022,$50B4,$51AB,$51F0,$5213,$5318,$535F
    dw $5403,$545E,$54B2,$552C,$55AB,$5664,$56A8,$5732
    dw $5742,$5787,$57AB,$57F4,$586C,$58B2,$58C4,$590B
    dw $5925,$596B,$598F,$59B9,$5A04,$5A25,$5A77,$5A8E
    dw $5AA5,$5ABC,$5AFD,$5B14,$5B2B,$5B42,$5B86,$5B9D
    dw $5BE2,$5C0A,$5C3D,$5C6B,$5CD4,$5D1F,$5D4A,$5DBE
    dw $5DCE,$5E10,$5E1D,$5EB5,$5EE0,$5F03,$5F4A,$5FC3
    dw $6013,$6052,$6128,$61CA,$623C,$62CD,$62E5,$6355
    dw $63C5,$63E9,$642F,$6451,$6467,$64BC,$6501,$653D
    dw $6590,$65A9,$65CD,$65ED,$6616,$6653,$66F7,$676D
    dw $6793,$67BD,$67FB,$6823,$6850,$6897,$68BF,$68E9
    dw $6908,$6920,$6932,$698B,$69A1,$69BD,$69E4,$69F6
    dw $6A15,$6A40,$6A94,$6ABA,$6B7A,$6B91,$6C00,$6CA7
    dw $6D24,$6D95,$6DD5,$6E7E,$6ECC,$6FA2,$6FB8,$6FDE
    dw $708D,$7133,$715D,$71FA,$720C,$721E,$7273,$72E0
    dw $7384,$73D7,$7430,$7488,$74E5,$7539,$7590,$75E4
    dw $7638,$7692,$76CE,$7762,$77AF,$7836

; ══════════════════════════════════════════════════════════════════════════
; DECODED MESSAGES (all 182) — ADDRESS-ORDERED
; ══════════════════════════════════════════════════════════════════════════

; --------------------------------------------------------------------------
; Message #0 ($418C)
;   「ようきたの[93]。
;   ここは　かくとうじょうじゃ。
;   「ん　わしか？　わしは
;   ここの　めいぶつ　おんな、
;   「バニーガールじゃなくて
;   ババーガールじゃよ　わはは。
;   「あんた　ゆうしょうしたいのか？
;   ほう！　ねえさんと　であうため？
;   「ならば　ここで　かちぬき　くにの
;   だいひょうに　ならねばならん。
;   「かくとうじょうには　「クラス[97]
;   というものがあっての[93]。
;   「よわいじゅんに　[10]　[0F]　[0E]　[0D]の
;   クラスがあるんじゃ。
;   「もっと　うえのクラスもあるが
;   あんたには　まだまだじゃ。
;   「どうじゃ　たたかってみるか？
;   [10]クラスなら　ただじゃぞ。
; --------------------------------------------------------------------------
Bank67_Msg0:                               ; $418C  (file $10C18C)
    db $EA                         ; $418C  ▶ new page
    db $9F                         ; $418D  box tag
    db $96                         ; $418E  end name/box tag
    db $4C,$26,$2A,$33,$3D         ; $418F  ようきたの
    db $93                         ; $4194  small kana
    db $8F                         ; $4195  。
    db $EF,$EE                     ; $4196  newline
    db $90,$90                     ; $4198  　　(indent)
    db $2D,$2D,$3E                 ; $419A  ここは
    db $90                         ; $419D  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$2F,$8D,$49; $419E  かくとうし゛ょうし゛ゃ = かくとうじょうじゃ
    db $8F                         ; $41A9  。
    db $FA                         ; $41AA  wait-for-button
    db $F7                         ; $41AB  clear page
    db $EF,$EE                     ; $41AC  newline
    db $9F                         ; $41AE  box tag
    db $96                         ; $41AF  end name/box tag
    db $55                         ; $41B0  ん
    db $90                         ; $41B1  　(space)
    db $53,$2F,$29                 ; $41B2  わしか
    db $98                         ; $41B5  ？
    db $90                         ; $41B6  　(space)
    db $53,$2F,$3E                 ; $41B7  わしは
    db $EF,$EE                     ; $41BA  newline
    db $90,$90                     ; $41BC  　　(indent)
    db $2D,$2D,$3D                 ; $41BE  ここの
    db $90                         ; $41C1  　(space)
    db $46,$25,$40,$8D,$35         ; $41C2  めいふ゛つ = めいぶつ
    db $90                         ; $41C7  　(space)
    db $28,$55,$39                 ; $41C8  おんな
    db $A4                         ; $41CB  、
    db $FA                         ; $41CC  wait-for-button
    db $F7                         ; $41CD  clear page
    db $EF,$EE                     ; $41CE  newline
    db $9F                         ; $41D0  box tag
    db $96                         ; $41D1  end name/box tag
    db $75,$8D,$71,$9C,$60,$8D,$9C,$87,$2F,$8D,$49,$39,$2B,$37; $41D2  ハ゛ニーカ゛ールし゛ゃなくて = バニーガールじゃなくて
    db $EF,$EE                     ; $41E0  newline
    db $90,$90                     ; $41E2  　　(indent)
    db $75,$8D,$75,$8D,$9C,$60,$8D,$9C,$87,$2F,$8D,$49,$4C; $41E4  ハ゛ハ゛ーカ゛ールし゛ゃよ = ババーガールじゃよ
    db $90                         ; $41F1  　(space)
    db $53,$3E,$3E                 ; $41F2  わはは
    db $8F                         ; $41F5  。
    db $FA                         ; $41F6  wait-for-button
    db $F7                         ; $41F7  clear page
    db $EF,$EE                     ; $41F8  newline
    db $9F                         ; $41FA  box tag
    db $96                         ; $41FB  end name/box tag
    db $24,$55,$33                 ; $41FC  あんた
    db $90                         ; $41FF  　(space)
    db $4A,$26,$2F,$4D,$26,$2F,$33,$25,$3D,$29; $4200  ゆうしょうしたいのか
    db $98                         ; $420A  ？
    db $EF,$EE                     ; $420B  newline
    db $90,$90                     ; $420D  　　(indent)
    db $42,$26                     ; $420F  ほう
    db $99                         ; $4211  ！
    db $90                         ; $4212  　(space)
    db $3C,$27,$2E,$55,$38         ; $4213  ねえさんと
    db $90                         ; $4218  　(space)
    db $37,$8D,$24,$26,$33,$46     ; $4219  て゛あうため = であうため
    db $98                         ; $421F  ？
    db $FA                         ; $4220  wait-for-button
    db $F7                         ; $4221  clear page
    db $EF,$EE                     ; $4222  newline
    db $9F                         ; $4224  box tag
    db $96                         ; $4225  end name/box tag
    db $39,$4E,$3E,$8D             ; $4226  ならは゛ = ならば
    db $90                         ; $422A  　(space)
    db $2D,$2D,$37,$8D             ; $422B  ここて゛ = ここで
    db $90                         ; $422F  　(space)
    db $29,$34,$3B,$2A             ; $4230  かちぬき
    db $90                         ; $4234  　(space)
    db $2B,$3A,$3D                 ; $4235  くにの
    db $EF,$EE                     ; $4238  newline
    db $90,$90                     ; $423A  　　(indent)
    db $33,$8D,$25,$3F,$4D,$26,$3A ; $423C  た゛いひょうに = だいひょうに
    db $90                         ; $4243  　(space)
    db $39,$4E,$3C,$3E,$8D,$39,$4E,$55; $4244  ならねは゛ならん = ならねばならん
    db $8F                         ; $424C  。
    db $FA                         ; $424D  wait-for-button
    db $F7                         ; $424E  clear page
    db $EF,$EE                     ; $424F  newline
    db $9F                         ; $4251  box tag
    db $96                         ; $4252  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A,$3E; $4253  かくとうし゛ょうには = かくとうじょうには
    db $90                         ; $425D  　(space)
    db $96                         ; $425E  end name/box tag
    db $62,$85,$67                 ; $425F  クラス
    db $97                         ; $4262  ctrl $97
    db $EF,$EE                     ; $4263  newline
    db $90,$90                     ; $4265  　　(indent)
    db $38,$25,$26,$47,$3D,$29,$8D,$24,$36,$37,$3D; $4267  というものか゛あっての = というものがあっての
    db $93                         ; $4272  small kana
    db $8F                         ; $4273  。
    db $FA                         ; $4274  wait-for-button
    db $F7                         ; $4275  clear page
    db $EF,$EE                     ; $4276  newline
    db $9F                         ; $4278  box tag
    db $96                         ; $4279  end name/box tag
    db $4C,$53,$25,$2F,$8D,$4B,$55,$3A; $427A  よわいし゛ゅんに = よわいじゅんに
    db $90                         ; $4282  　(space)
    db $10                         ; $4283  ctrl $10
    db $90                         ; $4284  　(space)
    db $0F                         ; $4285  ctrl $0F
    db $90                         ; $4286  　(space)
    db $0E                         ; $4287  ctrl $0E
    db $90                         ; $4288  　(space)
    db $0D                         ; $4289  ctrl $0D
    db $3D                         ; $428A  の
    db $EF,$EE                     ; $428B  newline
    db $90,$90                     ; $428D  　　(indent)
    db $62,$85,$67,$29,$8D,$24,$50,$55,$2F,$8D,$49; $428F  クラスか゛あるんし゛ゃ = クラスがあるんじゃ
    db $8F                         ; $429A  。
    db $FA                         ; $429B  wait-for-button
    db $F7                         ; $429C  clear page
    db $EF,$EE                     ; $429D  newline
    db $9F                         ; $429F  box tag
    db $96                         ; $42A0  end name/box tag
    db $47,$36,$38                 ; $42A1  もっと
    db $90                         ; $42A4  　(space)
    db $26,$27,$3D,$62,$85,$67,$47,$24,$50,$29,$8D; $42A5  うえのクラスもあるか゛ = うえのクラスもあるが
    db $EF,$EE                     ; $42B0  newline
    db $90,$90                     ; $42B2  　　(indent)
    db $24,$55,$33,$3A,$3E         ; $42B4  あんたには
    db $90                         ; $42B9  　(space)
    db $43,$33,$8D,$43,$33,$8D,$2F,$8D,$49; $42BA  また゛また゛し゛ゃ = まだまだじゃ
    db $8F                         ; $42C3  。
    db $FA                         ; $42C4  wait-for-button
    db $F7                         ; $42C5  clear page
    db $EF,$EE                     ; $42C6  newline
    db $9F                         ; $42C8  box tag
    db $96                         ; $42C9  end name/box tag
    db $38,$8D,$26,$2F,$8D,$49     ; $42CA  と゛うし゛ゃ = どうじゃ
    db $90                         ; $42D0  　(space)
    db $33,$33,$29,$36,$37,$44,$50,$29; $42D1  たたかってみるか
    db $98                         ; $42D9  ？
    db $EF,$EE                     ; $42DA  newline
    db $90,$90                     ; $42DC  　　(indent)
    db $10                         ; $42DE  ctrl $10
    db $62,$85,$67,$39,$4E         ; $42DF  クラスなら
    db $90                         ; $42E4  　(space)
    db $33,$33,$8D,$2F,$8D,$49,$32,$8D; $42E5  たた゛し゛ゃそ゛ = ただじゃぞ
    db $8F                         ; $42ED  。
    db $F0                         ; $42EE  end of message


; --------------------------------------------------------------------------
; Message #1 ($42EF)
;   「ざんねんじゃったが　まだまだ
;   しゅぎょうが　たりんのう。
;   「かくとうじょうには　あんたの
;   せんぱいが　たくさんおるから、
;   「どうすれば　つよくなれるか
;   おしえてもらう　ことじゃな。
; --------------------------------------------------------------------------
Bank67_Msg1:                               ; $42EF  (file $10C2EF)
    db $EA                         ; $42EF  ▶ new page
    db $9F                         ; $42F0  box tag
    db $96                         ; $42F1  end name/box tag
    db $2E,$8D,$55,$3C,$55,$2F,$8D,$49,$36,$33,$29,$8D; $42F2  さ゛んねんし゛ゃったか゛ = ざんねんじゃったが
    db $90                         ; $42FE  　(space)
    db $43,$33,$8D,$43,$33,$8D     ; $42FF  また゛また゛ = まだまだ
    db $EF,$EE                     ; $4305  newline
    db $90,$90                     ; $4307  　　(indent)
    db $2F,$4B,$2A,$8D,$4D,$26,$29,$8D; $4309  しゅき゛ょうか゛ = しゅぎょうが
    db $90                         ; $4311  　(space)
    db $33,$4F,$55,$3D,$26         ; $4312  たりんのう
    db $8F                         ; $4317  。
    db $FA                         ; $4318  wait-for-button
    db $F7                         ; $4319  clear page
    db $EF,$EE                     ; $431A  newline
    db $9F                         ; $431C  box tag
    db $96                         ; $431D  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A,$3E; $431E  かくとうし゛ょうには = かくとうじょうには
    db $90                         ; $4328  　(space)
    db $24,$55,$33,$3D             ; $4329  あんたの
    db $EF,$EE                     ; $432D  newline
    db $90,$90                     ; $432F  　　(indent)
    db $31,$55,$3E,$8E,$25,$29,$8D ; $4331  せんは゜いか゛ = せんぱいが
    db $90                         ; $4338  　(space)
    db $33,$2B,$2E,$55,$28,$50,$29,$4E; $4339  たくさんおるから
    db $A4                         ; $4341  、
    db $FA                         ; $4342  wait-for-button
    db $F7                         ; $4343  clear page
    db $EF,$EE                     ; $4344  newline
    db $9F                         ; $4346  box tag
    db $96                         ; $4347  end name/box tag
    db $38,$8D,$26,$30,$51,$3E,$8D ; $4348  と゛うすれは゛ = どうすれば
    db $90                         ; $434F  　(space)
    db $35,$4C,$2B,$39,$51,$50,$29 ; $4350  つよくなれるか
    db $EF,$EE                     ; $4357  newline
    db $90,$90                     ; $4359  　　(indent)
    db $28,$2F,$27,$37,$47,$4E,$26 ; $435B  おしえてもらう
    db $90                         ; $4362  　(space)
    db $2D,$38,$2F,$8D,$49,$39     ; $4363  ことし゛ゃな = ことじゃな
    db $8F                         ; $4369  。
    db $F7                         ; $436A  clear page
    db $F0                         ; $436B  end of message


; --------------------------------------------------------------------------
; Message #2 ($436C)
;   「よくやったのー！
;   [10]クラス　かちぬきじゃ！
; --------------------------------------------------------------------------
Bank67_Msg2:                               ; $436C  (file $10C36C)
    db $EA                         ; $436C  ▶ new page
    db $9F                         ; $436D  box tag
    db $96                         ; $436E  end name/box tag
    db $4C,$2B,$48,$36,$33,$3D,$9C ; $436F  よくやったのー
    db $99                         ; $4376  ！
    db $EF,$EE                     ; $4377  newline
    db $90,$90                     ; $4379  　　(indent)
    db $10                         ; $437B  ctrl $10
    db $62,$85,$67                 ; $437C  クラス
    db $90                         ; $437F  　(space)
    db $29,$34,$3B,$2A,$2F,$8D,$49 ; $4380  かちぬきし゛ゃ = かちぬきじゃ
    db $99                         ; $4387  ！
    db $F7                         ; $4388  clear page
    db $F0                         ; $4389  end of message


; --------------------------------------------------------------------------
; Message #3 ($438A)
;   「おお！　〈テリー〉どの。
;   [10]クラスかちぬき　おめでとう！
;   「おうさまが　およびなのだ。
;   ついてきてほしい！
; --------------------------------------------------------------------------
Bank67_Msg3:                               ; $438A  (file $10C38A)
    db $EA                         ; $438A  ▶ new page
    db $9F                         ; $438B  box tag
    db $96                         ; $438C  end name/box tag
    db $28,$28                     ; $438D  おお
    db $99                         ; $438F  ！
    db $90                         ; $4390  　(space)
    db $F6                         ; $4391  «insert hero name»
    db $38,$8D,$3D                 ; $4392  と゛の = どの
    db $8F                         ; $4395  。
    db $EF,$EE                     ; $4396  newline
    db $90,$90                     ; $4398  　　(indent)
    db $10                         ; $439A  ctrl $10
    db $62,$85,$67,$29,$34,$3B,$2A ; $439B  クラスかちぬき
    db $90                         ; $43A2  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $43A3  おめて゛とう = おめでとう
    db $99                         ; $43A9  ！
    db $FA                         ; $43AA  wait-for-button
    db $F7                         ; $43AB  clear page
    db $EF,$EE                     ; $43AC  newline
    db $9F                         ; $43AE  box tag
    db $96                         ; $43AF  end name/box tag
    db $28,$26,$2E,$43,$29,$8D     ; $43B0  おうさまか゛ = おうさまが
    db $90                         ; $43B6  　(space)
    db $28,$4C,$3F,$8D,$39,$3D,$33,$8D; $43B7  およひ゛なのた゛ = およびなのだ
    db $8F                         ; $43BF  。
    db $EF,$EE                     ; $43C0  newline
    db $90,$90                     ; $43C2  　　(indent)
    db $35,$25,$37,$2A,$37,$42,$2F,$25; $43C4  ついてきてほしい
    db $99                         ; $43CC  ！
    db $F7                         ; $43CD  clear page
    db $F0                         ; $43CE  end of message


; --------------------------------------------------------------------------
; Message #4 ($43CF)
;   「かくとうじょうへ　ようこそ！
;   しあいのせつめいを　ききますか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg4:                               ; $43CF  (file $10C3CF)
    db $EB                         ; $43CF  ▶ new page
    db $9F                         ; $43D0  box tag
    db $96                         ; $43D1  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$41; $43D2  かくとうし゛ょうへ = かくとうじょうへ
    db $90                         ; $43DB  　(space)
    db $4C,$26,$2D,$32             ; $43DC  ようこそ
    db $99                         ; $43E0  ！
    db $EF,$EE                     ; $43E1  newline
    db $90,$90                     ; $43E3  　　(indent)
    db $2F,$24,$25,$3D,$31,$35,$46,$25,$54; $43E5  しあいのせつめいを
    db $90                         ; $43EE  　(space)
    db $2A,$2A,$43,$30,$29         ; $43EF  ききますか
    db $98                         ; $43F4  ？
    db $FF                         ; $43F5  はい/いいえ
    db $F0                         ; $43F6  end of message


; --------------------------------------------------------------------------
; Message #5 ($43F7)
;   「しあいは　つよいじゅんに
;   [1C]から[10]クラスまで　あります。
;   「[01]つのクラスにつき　[03]にんの
;   マスターが　あいてです。
;   「[03]にんめの　マスターをたおせば
;   あなたのクラスが　あがります。
;   「[1C]クラスをかちぬけば　たいかいに
;   でるしかくが　えられますよ。
;   「なお　しあいでは　まものに
;   めいれいは　だせません。
;   「また　どうぐを　つかうことも
;   ゆるされません。
;   「にげるを　えらぶと　しあいを
;   ほうきしたと　みなされます。
;   「さんかもうしこみは　むかいの
;   うけつけで　おこなってください。
; --------------------------------------------------------------------------
Bank67_Msg5:                               ; $43F7  (file $10C3F7)
    db $EB                         ; $43F7  ▶ new page
    db $9F                         ; $43F8  box tag
    db $96                         ; $43F9  end name/box tag
    db $2F,$24,$25,$3E             ; $43FA  しあいは
    db $90                         ; $43FE  　(space)
    db $35,$4C,$25,$2F,$8D,$4B,$55,$3A; $43FF  つよいし゛ゅんに = つよいじゅんに
    db $EF,$EE                     ; $4407  newline
    db $90,$90                     ; $4409  　　(indent)
    db $1C                         ; $440B  ctrl $1C
    db $29,$4E                     ; $440C  から
    db $10                         ; $440E  ctrl $10
    db $62,$85,$67,$43,$37,$8D     ; $440F  クラスまて゛ = クラスまで
    db $90                         ; $4415  　(space)
    db $24,$4F,$43,$30             ; $4416  あります
    db $8F                         ; $441A  。
    db $FA                         ; $441B  wait-for-button
    db $F7                         ; $441C  clear page
    db $EF,$EE                     ; $441D  newline
    db $9F                         ; $441F  box tag
    db $96                         ; $4420  end name/box tag
    db $01                         ; $4421  ctrl $01
    db $35,$3D,$62,$85,$67,$3A,$35,$2A; $4422  つのクラスにつき
    db $90                         ; $442A  　(space)
    db $03                         ; $442B  ctrl $03
    db $3A,$55,$3D                 ; $442C  にんの
    db $EF,$EE                     ; $442F  newline
    db $90,$90                     ; $4431  　　(indent)
    db $7A,$67,$6A,$9C,$29,$8D     ; $4433  マスターか゛ = マスターが
    db $90                         ; $4439  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $443A  あいてて゛す = あいてです
    db $8F                         ; $4440  。
    db $FA                         ; $4441  wait-for-button
    db $F7                         ; $4442  clear page
    db $EF,$EE                     ; $4443  newline
    db $9F                         ; $4445  box tag
    db $96                         ; $4446  end name/box tag
    db $03                         ; $4447  ctrl $03
    db $3A,$55,$46,$3D             ; $4448  にんめの
    db $90                         ; $444C  　(space)
    db $7A,$67,$6A,$9C,$54,$33,$28,$31,$3E,$8D; $444D  マスターをたおせは゛ = マスターをたおせば
    db $EF,$EE                     ; $4457  newline
    db $90,$90                     ; $4459  　　(indent)
    db $24,$39,$33,$3D,$62,$85,$67,$29,$8D; $445B  あなたのクラスか゛ = あなたのクラスが
    db $90                         ; $4464  　(space)
    db $24,$29,$8D,$4F,$43,$30     ; $4465  あか゛ります = あがります
    db $8F                         ; $446B  。
    db $FA                         ; $446C  wait-for-button
    db $F7                         ; $446D  clear page
    db $EF,$EE                     ; $446E  newline
    db $9F                         ; $4470  box tag
    db $96                         ; $4471  end name/box tag
    db $1C                         ; $4472  ctrl $1C
    db $62,$85,$67,$54,$29,$34,$3B,$2C,$3E,$8D; $4473  クラスをかちぬけは゛ = クラスをかちぬけば
    db $90                         ; $447D  　(space)
    db $33,$25,$29,$25,$3A         ; $447E  たいかいに
    db $EF,$EE                     ; $4483  newline
    db $90,$90                     ; $4485  　　(indent)
    db $37,$8D,$50,$2F,$29,$2B,$29,$8D; $4487  て゛るしかくか゛ = でるしかくが
    db $90                         ; $448F  　(space)
    db $27,$4E,$51,$43,$30,$4C     ; $4490  えられますよ
    db $8F                         ; $4496  。
    db $FA                         ; $4497  wait-for-button
    db $F7                         ; $4498  clear page
    db $EF,$EE                     ; $4499  newline
    db $9F                         ; $449B  box tag
    db $96                         ; $449C  end name/box tag
    db $39,$28                     ; $449D  なお
    db $90                         ; $449F  　(space)
    db $2F,$24,$25,$37,$8D,$3E     ; $44A0  しあいて゛は = しあいでは
    db $90                         ; $44A6  　(space)
    db $43,$47,$3D,$3A             ; $44A7  まものに
    db $EF,$EE                     ; $44AB  newline
    db $90,$90                     ; $44AD  　　(indent)
    db $46,$25,$51,$25,$3E         ; $44AF  めいれいは
    db $90                         ; $44B4  　(space)
    db $33,$8D,$31,$43,$31,$55     ; $44B5  た゛せません = だせません
    db $8F                         ; $44BB  。
    db $FA                         ; $44BC  wait-for-button
    db $F7                         ; $44BD  clear page
    db $EF,$EE                     ; $44BE  newline
    db $9F                         ; $44C0  box tag
    db $96                         ; $44C1  end name/box tag
    db $43,$33                     ; $44C2  また
    db $90                         ; $44C4  　(space)
    db $38,$8D,$26,$2B,$8D,$54     ; $44C5  と゛うく゛を = どうぐを
    db $90                         ; $44CB  　(space)
    db $35,$29,$26,$2D,$38,$47     ; $44CC  つかうことも
    db $EF,$EE                     ; $44D2  newline
    db $90,$90                     ; $44D4  　　(indent)
    db $4A,$50,$2E,$51,$43,$31,$55 ; $44D6  ゆるされません
    db $8F                         ; $44DD  。
    db $FA                         ; $44DE  wait-for-button
    db $F7                         ; $44DF  clear page
    db $EF,$EE                     ; $44E0  newline
    db $9F                         ; $44E2  box tag
    db $96                         ; $44E3  end name/box tag
    db $3A,$2C,$8D,$50,$54         ; $44E4  にけ゛るを = にげるを
    db $90                         ; $44E9  　(space)
    db $27,$4E,$40,$8D,$38         ; $44EA  えらふ゛と = えらぶと
    db $90                         ; $44EF  　(space)
    db $2F,$24,$25,$54             ; $44F0  しあいを
    db $EF,$EE                     ; $44F4  newline
    db $90,$90                     ; $44F6  　　(indent)
    db $42,$26,$2A,$2F,$33,$38     ; $44F8  ほうきしたと
    db $90                         ; $44FE  　(space)
    db $44,$39,$2E,$51,$43,$30     ; $44FF  みなされます
    db $8F                         ; $4505  。
    db $FA                         ; $4506  wait-for-button
    db $F7                         ; $4507  clear page
    db $EF,$EE                     ; $4508  newline
    db $9F                         ; $450A  box tag
    db $96                         ; $450B  end name/box tag
    db $2E,$55,$29,$47,$26,$2F,$2D,$44,$3E; $450C  さんかもうしこみは
    db $90                         ; $4515  　(space)
    db $45,$29,$25,$3D             ; $4516  むかいの
    db $EF,$EE                     ; $451A  newline
    db $90,$90                     ; $451C  　　(indent)
    db $26,$2C,$35,$2C,$37,$8D     ; $451E  うけつけて゛ = うけつけで
    db $90                         ; $4524  　(space)
    db $28,$2D,$39,$36,$37,$2B,$33,$8D,$2E,$25; $4525  おこなってくた゛さい = おこなってください
    db $8F                         ; $452F  。
    db $F7                         ; $4530  clear page
    db $F0                         ; $4531  end of message


; --------------------------------------------------------------------------
; Message #6 ($4532)
;   「[10]クラスの　さいしゅうせんは
;   マスターようせいじゅくの
;   「じゅくちょうが　あいてです。
; --------------------------------------------------------------------------
Bank67_Msg6:                               ; $4532  (file $10C532)
    db $EB                         ; $4532  ▶ new page
    db $9F                         ; $4533  box tag
    db $96                         ; $4534  end name/box tag
    db $10                         ; $4535  ctrl $10
    db $62,$85,$67,$3D             ; $4536  クラスの
    db $90                         ; $453A  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $453B  さいしゅうせんは
    db $EF,$EE                     ; $4543  newline
    db $90,$90                     ; $4545  　　(indent)
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25,$2F,$8D,$4B,$2B,$3D; $4547  マスターようせいし゛ゅくの = マスターようせいじゅくの
    db $FA                         ; $4554  wait-for-button
    db $F7                         ; $4555  clear page
    db $EF,$EE                     ; $4556  newline
    db $9F                         ; $4558  box tag
    db $96                         ; $4559  end name/box tag
    db $2F,$8D,$4B,$2B,$34,$4D,$26,$29,$8D; $455A  し゛ゅくちょうか゛ = じゅくちょうが
    db $90                         ; $4563  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $4564  あいてて゛す = あいてです
    db $8F                         ; $456A  。
    db $EF,$EE                     ; $456B  newline
    db $F7                         ; $456D  clear page
    db $F0                         ; $456E  end of message


; --------------------------------------------------------------------------
; Message #7 ($456F)
;   「ひゃ！　なんじゃ？　なんじゃ？
;   まえから　はなしかけい！
; --------------------------------------------------------------------------
Bank67_Msg7:                               ; $456F  (file $10C56F)
    db $EA                         ; $456F  ▶ new page
    db $9F                         ; $4570  box tag
    db $96                         ; $4571  end name/box tag
    db $3F,$49                     ; $4572  ひゃ
    db $99                         ; $4574  ！
    db $90                         ; $4575  　(space)
    db $39,$55,$2F,$8D,$49         ; $4576  なんし゛ゃ = なんじゃ
    db $98                         ; $457B  ？
    db $90                         ; $457C  　(space)
    db $39,$55,$2F,$8D,$49         ; $457D  なんし゛ゃ = なんじゃ
    db $98                         ; $4582  ？
    db $EF,$EE                     ; $4583  newline
    db $90,$90                     ; $4585  　　(indent)
    db $43,$27,$29,$4E             ; $4587  まえから
    db $90                         ; $458B  　(space)
    db $3E,$39,$2F,$29,$2C,$25     ; $458C  はなしかけい
    db $99                         ; $4592  ！
    db $F7                         ; $4593  clear page
    db $F0                         ; $4594  end of message


; --------------------------------------------------------------------------
; Message #8 ($4595)
;   「キユ！　いま　さわったでしょ！
;   ぷん　ぷん。
; --------------------------------------------------------------------------
Bank67_Msg8:                               ; $4595  (file $10C595)
    db $EB                         ; $4595  ▶ new page
    db $9F                         ; $4596  box tag
    db $96                         ; $4597  end name/box tag
    db $61,$80                     ; $4598  キユ
    db $99                         ; $459A  ！
    db $90                         ; $459B  　(space)
    db $25,$43                     ; $459C  いま
    db $90                         ; $459E  　(space)
    db $2E,$53,$36,$33,$37,$8D,$2F,$4D; $459F  さわったて゛しょ = さわったでしょ
    db $99                         ; $45A7  ！
    db $EF,$EE                     ; $45A8  newline
    db $90,$90                     ; $45AA  　　(indent)
    db $40,$8E,$55                 ; $45AC  ふ゜ん = ぷん
    db $90                         ; $45AF  　(space)
    db $40,$8E,$55                 ; $45B0  ふ゜ん = ぷん
    db $8F                         ; $45B3  。
    db $F7                         ; $45B4  clear page
    db $F0                         ; $45B5  end of message


; --------------------------------------------------------------------------
; Message #9 ($45B6)
;   どこからともなく　こえがきこえる。
; --------------------------------------------------------------------------
Bank67_Msg9:                               ; $45B6  (file $10C5B6)
    db $38,$8D,$2D,$29,$4E,$38,$47,$39,$2B; $45B6  と゛こからともなく = どこからともなく
    db $90                         ; $45BF  　(space)
    db $2D,$27,$29,$8D,$2A,$2D,$27,$50; $45C0  こえか゛きこえる = こえがきこえる
    db $8F                         ; $45C8  。
    db $EF,$EE                     ; $45C9  newline
    db $F7                         ; $45CB  clear page
    db $F0                         ; $45CC  end of message


; --------------------------------------------------------------------------
; Message #10 ($45CD)
;   「かくとう　もうしこまざるもの
;   たちいる　しかくなし！！
; --------------------------------------------------------------------------
Bank67_Msg10:                              ; $45CD  (file $10C5CD)
    db $EA                         ; $45CD  ▶ new page
    db $9F                         ; $45CE  box tag
    db $96                         ; $45CF  end name/box tag
    db $29,$2B,$38,$26             ; $45D0  かくとう
    db $90                         ; $45D4  　(space)
    db $47,$26,$2F,$2D,$43,$2E,$8D,$50,$47,$3D; $45D5  もうしこまさ゛るもの = もうしこまざるもの
    db $EF,$EE                     ; $45DF  newline
    db $90,$90                     ; $45E1  　　(indent)
    db $33,$34,$25,$50             ; $45E3  たちいる
    db $90                         ; $45E7  　(space)
    db $2F,$29,$2B,$39,$2F         ; $45E8  しかくなし
    db $99                         ; $45ED  ！
    db $99                         ; $45EE  ！
    db $F7                         ; $45EF  clear page
    db $F0                         ; $45F0  end of message


; --------------------------------------------------------------------------
; Message #11 ($45F1)
;   「ここ　こ　こんにちは！
;   テ　テテ、　テトともうします。
;   「もうすぐしあいが　はじまるので
;   きんちょうしています！
;   「き　きみも　しんまいの
;   モンスターマスターですね？
;   「おくに　いけば　ぼうけんの
;   やくにたつことが　きけますよ！
; --------------------------------------------------------------------------
Bank67_Msg11:                              ; $45F1  (file $10C5F1)
    db $EB                         ; $45F1  ▶ new page
    db $9F                         ; $45F2  box tag
    db $96                         ; $45F3  end name/box tag
    db $2D,$2D                     ; $45F4  ここ
    db $90                         ; $45F6  　(space)
    db $2D                         ; $45F7  こ
    db $90                         ; $45F8  　(space)
    db $2D,$55,$3A,$34,$3E         ; $45F9  こんにちは
    db $99                         ; $45FE  ！
    db $EF,$EE                     ; $45FF  newline
    db $90,$90                     ; $4601  　　(indent)
    db $6E                         ; $4603  テ
    db $90                         ; $4604  　(space)
    db $6E,$6E                     ; $4605  テテ
    db $A4                         ; $4607  、
    db $90                         ; $4608  　(space)
    db $6E,$6F,$38,$47,$26,$2F,$43,$30; $4609  テトともうします
    db $8F                         ; $4611  。
    db $FA                         ; $4612  wait-for-button
    db $F7                         ; $4613  clear page
    db $EF,$EE                     ; $4614  newline
    db $9F                         ; $4616  box tag
    db $96                         ; $4617  end name/box tag
    db $47,$26,$30,$2B,$8D,$2F,$24,$25,$29,$8D; $4618  もうすく゛しあいか゛ = もうすぐしあいが
    db $90                         ; $4622  　(space)
    db $3E,$2F,$8D,$43,$50,$3D,$37,$8D; $4623  はし゛まるのて゛ = はじまるので
    db $EF,$EE                     ; $462B  newline
    db $90,$90                     ; $462D  　　(indent)
    db $2A,$55,$34,$4D,$26,$2F,$37,$25,$43,$30; $462F  きんちょうしています
    db $99                         ; $4639  ！
    db $FA                         ; $463A  wait-for-button
    db $F7                         ; $463B  clear page
    db $EF,$EE                     ; $463C  newline
    db $9F                         ; $463E  box tag
    db $96                         ; $463F  end name/box tag
    db $2A                         ; $4640  き
    db $90                         ; $4641  　(space)
    db $2A,$44,$47                 ; $4642  きみも
    db $90                         ; $4645  　(space)
    db $2F,$55,$43,$25,$3D         ; $4646  しんまいの
    db $EF,$EE                     ; $464B  newline
    db $90,$90                     ; $464D  　　(indent)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$37,$8D,$30,$3C; $464F  モンスターマスターて゛すね = モンスターマスターですね
    db $98                         ; $465C  ？
    db $FA                         ; $465D  wait-for-button
    db $F7                         ; $465E  clear page
    db $EF,$EE                     ; $465F  newline
    db $9F                         ; $4661  box tag
    db $96                         ; $4662  end name/box tag
    db $28,$2B,$3A                 ; $4663  おくに
    db $90                         ; $4666  　(space)
    db $25,$2C,$3E,$8D             ; $4667  いけは゛ = いけば
    db $90                         ; $466B  　(space)
    db $42,$8D,$26,$2C,$55,$3D     ; $466C  ほ゛うけんの = ぼうけんの
    db $EF,$EE                     ; $4672  newline
    db $90,$90                     ; $4674  　　(indent)
    db $48,$2B,$3A,$33,$35,$2D,$38,$29,$8D; $4676  やくにたつことか゛ = やくにたつことが
    db $90                         ; $467F  　(space)
    db $2A,$2C,$43,$30,$4C         ; $4680  きけますよ
    db $99                         ; $4685  ！
    db $F7                         ; $4686  clear page
    db $F0                         ; $4687  end of message


; --------------------------------------------------------------------------
; Message #12 ($4688)
;   「ふがあ　ふがあ、、。
; --------------------------------------------------------------------------
Bank67_Msg12:                              ; $4688  (file $10C688)
    db $EA                         ; $4688  ▶ new page
    db $9F                         ; $4689  box tag
    db $96                         ; $468A  end name/box tag
    db $40,$29,$8D,$24             ; $468B  ふか゛あ = ふがあ
    db $90                         ; $468F  　(space)
    db $40,$29,$8D,$24             ; $4690  ふか゛あ = ふがあ
    db $A4                         ; $4694  、
    db $A4                         ; $4695  、
    db $8F                         ; $4696  。
    db $EF,$EE                     ; $4697  newline
    db $F7                         ; $4699  clear page
    db $F0                         ; $469A  end of message


; --------------------------------------------------------------------------
; Message #13 ($469B)
;   「このおくでは　こどもたちに
;   まもののことを　おしえている。
;   「そなたも　はなしを
;   きいてみると　いいだろう。
; --------------------------------------------------------------------------
Bank67_Msg13:                              ; $469B  (file $10C69B)
    db $EA                         ; $469B  ▶ new page
    db $9F                         ; $469C  box tag
    db $96                         ; $469D  end name/box tag
    db $2D,$3D,$28,$2B,$37,$8D,$3E ; $469E  このおくて゛は = このおくでは
    db $90                         ; $46A5  　(space)
    db $2D,$38,$8D,$47,$33,$34,$3A ; $46A6  こと゛もたちに = こどもたちに
    db $EF,$EE                     ; $46AD  newline
    db $90,$90                     ; $46AF  　　(indent)
    db $43,$47,$3D,$3D,$2D,$38,$54 ; $46B1  まもののことを
    db $90                         ; $46B8  　(space)
    db $28,$2F,$27,$37,$25,$50     ; $46B9  おしえている
    db $8F                         ; $46BF  。
    db $FA                         ; $46C0  wait-for-button
    db $F7                         ; $46C1  clear page
    db $EF,$EE                     ; $46C2  newline
    db $9F                         ; $46C4  box tag
    db $96                         ; $46C5  end name/box tag
    db $32,$39,$33,$47             ; $46C6  そなたも
    db $90                         ; $46CA  　(space)
    db $3E,$39,$2F,$54             ; $46CB  はなしを
    db $EF,$EE                     ; $46CF  newline
    db $90,$90                     ; $46D1  　　(indent)
    db $2A,$25,$37,$44,$50,$38     ; $46D3  きいてみると
    db $90                         ; $46D9  　(space)
    db $25,$25,$33,$8D,$52,$26     ; $46DA  いいた゛ろう = いいだろう
    db $8F                         ; $46E0  。
    db $F7                         ; $46E1  clear page
    db $F0                         ; $46E2  end of message


; --------------------------------------------------------------------------
; Message #14 ($46E3)
;   「コドラは　どこら？
; --------------------------------------------------------------------------
Bank67_Msg14:                              ; $46E3  (file $10C6E3)
    db $EA                         ; $46E3  ▶ new page
    db $9F                         ; $46E4  box tag
    db $96                         ; $46E5  end name/box tag
    db $64,$6F,$8D,$85,$3E         ; $46E6  コト゛ラは = コドラは
    db $90                         ; $46EB  　(space)
    db $38,$8D,$2D,$4E             ; $46EC  と゛こら = どこら
    db $98                         ; $46F0  ？
    db $EF,$EE                     ; $46F1  newline
    db $F7                         ; $46F3  clear page
    db $F0                         ; $46F4  end of message


; --------------------------------------------------------------------------
; Message #15 ($46F5)
;   「ォレと　ジユンケンで
;   しょうぶしねえか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg15:                              ; $46F5  (file $10C6F5)
    db $EB                         ; $46F5  ▶ new page
    db $9F                         ; $46F6  box tag
    db $96                         ; $46F7  end name/box tag
    db $5E,$88,$38                 ; $46F8  ォレと
    db $90                         ; $46FB  　(space)
    db $66,$8D,$80,$8C,$63,$8C,$37,$8D; $46FC  シ゛ユンケンて゛ = ジユンケンで
    db $EF,$EE                     ; $4704  newline
    db $90,$90                     ; $4706  　　(indent)
    db $2F,$4D,$26,$40,$8D,$2F,$3C,$27,$29; $4708  しょうふ゛しねえか = しょうぶしねえか
    db $98                         ; $4711  ？
    db $FF                         ; $4712  はい/いいえ
    db $F0                         ; $4713  end of message


; --------------------------------------------------------------------------
; Message #16 ($4714)
;   「なんだ　つまんねえな。
; --------------------------------------------------------------------------
Bank67_Msg16:                              ; $4714  (file $10C714)
    db $EB                         ; $4714  ▶ new page
    db $9F                         ; $4715  box tag
    db $96                         ; $4716  end name/box tag
    db $39,$55,$33,$8D             ; $4717  なんた゛ = なんだ
    db $90                         ; $471B  　(space)
    db $35,$43,$55,$3C,$27,$39     ; $471C  つまんねえな
    db $8F                         ; $4722  。
    db $EF,$EE                     ; $4723  newline
    db $F7                         ; $4725  clear page
    db $F0                         ; $4726  end of message


; --------------------------------------------------------------------------
; Message #17 ($4727)
;   「なにを　だすかは　したのパネルに
;   のれば　きめられるぞ。
;   「つづけて　しょうぶするときは
;   いちいち　ォレに　はなしかけず
;   「そのまま　つぎのパネルに
;   のればいいからな！
;   「よーし！　いくぞ！
;   ジユーン　ケーン、。
; --------------------------------------------------------------------------
Bank67_Msg17:                              ; $4727  (file $10C727)
    db $EB                         ; $4727  ▶ new page
    db $9F                         ; $4728  box tag
    db $96                         ; $4729  end name/box tag
    db $39,$3A,$54                 ; $472A  なにを
    db $90                         ; $472D  　(space)
    db $33,$8D,$30,$29,$3E         ; $472E  た゛すかは = だすかは
    db $90                         ; $4733  　(space)
    db $2F,$33,$3D,$75,$8E,$73,$87,$3A; $4734  したのハ゜ネルに = したのパネルに
    db $EF,$EE                     ; $473C  newline
    db $90,$90                     ; $473E  　　(indent)
    db $3D,$51,$3E,$8D             ; $4740  のれは゛ = のれば
    db $90                         ; $4744  　(space)
    db $2A,$46,$4E,$51,$50,$32,$8D ; $4745  きめられるそ゛ = きめられるぞ
    db $8F                         ; $474C  。
    db $FA                         ; $474D  wait-for-button
    db $F7                         ; $474E  clear page
    db $EF,$EE                     ; $474F  newline
    db $9F                         ; $4751  box tag
    db $96                         ; $4752  end name/box tag
    db $35,$35,$8D,$2C,$37         ; $4753  つつ゛けて = つづけて
    db $90                         ; $4758  　(space)
    db $2F,$4D,$26,$40,$8D,$30,$50,$38,$2A,$3E; $4759  しょうふ゛するときは = しょうぶするときは
    db $EF,$EE                     ; $4763  newline
    db $90,$90                     ; $4765  　　(indent)
    db $25,$34,$25,$34             ; $4767  いちいち
    db $90                         ; $476B  　(space)
    db $5E,$88,$3A                 ; $476C  ォレに
    db $90                         ; $476F  　(space)
    db $3E,$39,$2F,$29,$2C,$30,$8D ; $4770  はなしかけす゛ = はなしかけず
    db $FA                         ; $4777  wait-for-button
    db $F7                         ; $4778  clear page
    db $EF,$EE                     ; $4779  newline
    db $9F                         ; $477B  box tag
    db $96                         ; $477C  end name/box tag
    db $32,$3D,$43,$43             ; $477D  そのまま
    db $90                         ; $4781  　(space)
    db $35,$2A,$8D,$3D,$75,$8E,$73,$87,$3A; $4782  つき゛のハ゜ネルに = つぎのパネルに
    db $EF,$EE                     ; $478B  newline
    db $90,$90                     ; $478D  　　(indent)
    db $3D,$51,$3E,$8D,$25,$25,$29,$4E,$39; $478F  のれは゛いいからな = のればいいからな
    db $99                         ; $4798  ！
    db $FA                         ; $4799  wait-for-button
    db $F7                         ; $479A  clear page
    db $EF,$EE                     ; $479B  newline
    db $9F                         ; $479D  box tag
    db $96                         ; $479E  end name/box tag
    db $4C,$9C,$2F                 ; $479F  よーし
    db $99                         ; $47A2  ！
    db $90                         ; $47A3  　(space)
    db $25,$2B,$32,$8D             ; $47A4  いくそ゛ = いくぞ
    db $99                         ; $47A8  ！
    db $EF,$EE                     ; $47A9  newline
    db $90,$90                     ; $47AB  　　(indent)
    db $66,$8D,$80,$9C,$8C         ; $47AD  シ゛ユーン = ジユーン
    db $90                         ; $47B2  　(space)
    db $63,$9C,$8C                 ; $47B3  ケーン
    db $A4                         ; $47B6  、
    db $8F                         ; $47B7  。
    db $F7                         ; $47B8  clear page
    db $F0                         ; $47B9  end of message


; --------------------------------------------------------------------------
; Message #18 ($47BA)
;   「くっそーっ！！
;   もう　いっかいだ！
; --------------------------------------------------------------------------
Bank67_Msg18:                              ; $47BA  (file $10C7BA)
    db $EB                         ; $47BA  ▶ new page
    db $9F                         ; $47BB  box tag
    db $96                         ; $47BC  end name/box tag
    db $2B,$36,$32,$9C,$36         ; $47BD  くっそーっ
    db $99                         ; $47C2  ！
    db $99                         ; $47C3  ！
    db $EF,$EE                     ; $47C4  newline
    db $90,$90                     ; $47C6  　　(indent)
    db $47,$26                     ; $47C8  もう
    db $90                         ; $47CA  　(space)
    db $25,$36,$29,$25,$33,$8D     ; $47CB  いっかいた゛ = いっかいだ
    db $99                         ; $47D1  ！
    db $F7                         ; $47D2  clear page
    db $F0                         ; $47D3  end of message


; --------------------------------------------------------------------------
; Message #19 ($47D4)
;   「ォレの　かちだ！
;   いつでも　あいてになってやるぜ！
; --------------------------------------------------------------------------
Bank67_Msg19:                              ; $47D4  (file $10C7D4)
    db $EB                         ; $47D4  ▶ new page
    db $9F                         ; $47D5  box tag
    db $96                         ; $47D6  end name/box tag
    db $5E,$88,$3D                 ; $47D7  ォレの
    db $90                         ; $47DA  　(space)
    db $29,$34,$33,$8D             ; $47DB  かちた゛ = かちだ
    db $99                         ; $47DF  ！
    db $EF,$EE                     ; $47E0  newline
    db $90,$90                     ; $47E2  　　(indent)
    db $25,$35,$37,$8D,$47         ; $47E4  いつて゛も = いつでも
    db $90                         ; $47E9  　(space)
    db $24,$25,$37,$3A,$39,$36,$37,$48,$50,$31,$8D; $47EA  あいてになってやるせ゛ = あいてになってやるぜ
    db $99                         ; $47F5  ！
    db $F7                         ; $47F6  clear page
    db $F0                         ; $47F7  end of message


; --------------------------------------------------------------------------
; Message #20 ($47F8)
;   「あいこか、、。
;   こういうばあい、
;   「ォレのかちになるのだ！！
;   ハッハッハー！
; --------------------------------------------------------------------------
Bank67_Msg20:                              ; $47F8  (file $10C7F8)
    db $EB                         ; $47F8  ▶ new page
    db $9F                         ; $47F9  box tag
    db $96                         ; $47FA  end name/box tag
    db $24,$25,$2D,$29             ; $47FB  あいこか
    db $A4                         ; $47FF  、
    db $A4                         ; $4800  、
    db $8F                         ; $4801  。
    db $EF,$EE                     ; $4802  newline
    db $90,$90                     ; $4804  　　(indent)
    db $2D,$26,$25,$26,$3E,$8D,$24,$25; $4806  こういうは゛あい = こういうばあい
    db $A4                         ; $480E  、
    db $FA                         ; $480F  wait-for-button
    db $F7                         ; $4810  clear page
    db $EF,$EE                     ; $4811  newline
    db $9F                         ; $4813  box tag
    db $96                         ; $4814  end name/box tag
    db $5E,$88,$3D,$29,$34,$3A,$39,$50,$3D,$33,$8D; $4815  ォレのかちになるのた゛ = ォレのかちになるのだ
    db $99                         ; $4820  ！
    db $99                         ; $4821  ！
    db $EF,$EE                     ; $4822  newline
    db $90,$90                     ; $4824  　　(indent)
    db $75,$6D,$75,$6D,$75,$9C     ; $4826  ハッハッハー
    db $99                         ; $482C  ！
    db $F7                         ; $482D  clear page
    db $F0                         ; $482E  end of message


; --------------------------------------------------------------------------
; Message #21 ($482F)
;   「お　おまえ　つよいじゃねえか！！
;   「よし！　ほうびに　いいところに
;   あんないしてやるよ。
;   「そこのかいだんを　のぼってみな！
; --------------------------------------------------------------------------
Bank67_Msg21:                              ; $482F  (file $10C82F)
    db $EB                         ; $482F  ▶ new page
    db $9F                         ; $4830  box tag
    db $96                         ; $4831  end name/box tag
    db $28                         ; $4832  お
    db $90                         ; $4833  　(space)
    db $28,$43,$27                 ; $4834  おまえ
    db $90                         ; $4837  　(space)
    db $35,$4C,$25,$2F,$8D,$49,$3C,$27,$29; $4838  つよいし゛ゃねえか = つよいじゃねえか
    db $99                         ; $4841  ！
    db $99                         ; $4842  ！
    db $EF,$EE                     ; $4843  newline
    db $FA                         ; $4845  wait-for-button
    db $F7                         ; $4846  clear page
    db $EF,$EE                     ; $4847  newline
    db $F3                         ; $4849  open text box
    db $9F                         ; $484A  box tag
    db $96                         ; $484B  end name/box tag
    db $4C,$2F                     ; $484C  よし
    db $99                         ; $484E  ！
    db $90                         ; $484F  　(space)
    db $42,$26,$3F,$8D,$3A         ; $4850  ほうひ゛に = ほうびに
    db $90                         ; $4855  　(space)
    db $25,$25,$38,$2D,$52,$3A     ; $4856  いいところに
    db $EF,$EE                     ; $485C  newline
    db $90,$90                     ; $485E  　　(indent)
    db $24,$55,$39,$25,$2F,$37,$48,$50,$4C; $4860  あんないしてやるよ
    db $8F                         ; $4869  。
    db $FA                         ; $486A  wait-for-button
    db $F7                         ; $486B  clear page
    db $EF,$EE                     ; $486C  newline
    db $9F                         ; $486E  box tag
    db $96                         ; $486F  end name/box tag
    db $32,$2D,$3D,$29,$25,$33,$8D,$55,$54; $4870  そこのかいた゛んを = そこのかいだんを
    db $90                         ; $4879  　(space)
    db $3D,$42,$8D,$36,$37,$44,$39 ; $487A  のほ゛ってみな = のぼってみな
    db $99                         ; $4881  ！
    db $EF,$EE                     ; $4882  newline
    db $F7                         ; $4884  clear page
    db $F0                         ; $4885  end of message


; --------------------------------------------------------------------------
; Message #22 ($4886)
;   「おまえ　つよいな[91]、。
; --------------------------------------------------------------------------
Bank67_Msg22:                              ; $4886  (file $10C886)
    db $EB                         ; $4886  ▶ new page
    db $9F                         ; $4887  box tag
    db $96                         ; $4888  end name/box tag
    db $28,$43,$27                 ; $4889  おまえ
    db $90                         ; $488C  　(space)
    db $35,$4C,$25,$39             ; $488D  つよいな
    db $91                         ; $4891  ctrl $91
    db $A4                         ; $4892  、
    db $8F                         ; $4893  。
    db $EF,$EE                     ; $4894  newline
    db $F7                         ; $4896  clear page
    db $F0                         ; $4897  end of message


; --------------------------------------------------------------------------
; Message #23 ($4898)
;   「おぬし　おうさまの　おくがた
;   つまり　おうひさまじゃな、
;   「その　おうひさまが　どこに
;   おられるか　しりたくは　ないか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg23:                              ; $4898  (file $10C898)
    db $EA                         ; $4898  ▶ new page
    db $9F                         ; $4899  box tag
    db $96                         ; $489A  end name/box tag
    db $28,$3B,$2F                 ; $489B  おぬし
    db $90                         ; $489E  　(space)
    db $28,$26,$2E,$43,$3D         ; $489F  おうさまの
    db $90                         ; $48A4  　(space)
    db $28,$2B,$29,$8D,$33         ; $48A5  おくか゛た = おくがた
    db $EF,$EE                     ; $48AA  newline
    db $90,$90                     ; $48AC  　　(indent)
    db $35,$43,$4F                 ; $48AE  つまり
    db $90                         ; $48B1  　(space)
    db $28,$26,$3F,$2E,$43,$2F,$8D,$49,$39; $48B2  おうひさまし゛ゃな = おうひさまじゃな
    db $A4                         ; $48BB  、
    db $FA                         ; $48BC  wait-for-button
    db $F7                         ; $48BD  clear page
    db $EF,$EE                     ; $48BE  newline
    db $9F                         ; $48C0  box tag
    db $96                         ; $48C1  end name/box tag
    db $32,$3D                     ; $48C2  その
    db $90                         ; $48C4  　(space)
    db $28,$26,$3F,$2E,$43,$29,$8D ; $48C5  おうひさまか゛ = おうひさまが
    db $90                         ; $48CC  　(space)
    db $38,$8D,$2D,$3A             ; $48CD  と゛こに = どこに
    db $EF,$EE                     ; $48D1  newline
    db $90,$90                     ; $48D3  　　(indent)
    db $28,$4E,$51,$50,$29         ; $48D5  おられるか
    db $90                         ; $48DA  　(space)
    db $2F,$4F,$33,$2B,$3E         ; $48DB  しりたくは
    db $90                         ; $48E0  　(space)
    db $39,$25,$29                 ; $48E1  ないか
    db $98                         ; $48E4  ？
    db $FF                         ; $48E5  はい/いいえ
    db $F0                         ; $48E6  end of message


; --------------------------------------------------------------------------
; Message #24 ($48E7)
;   「ほんとうは　しりたいくせに、。
; --------------------------------------------------------------------------
Bank67_Msg24:                              ; $48E7  (file $10C8E7)
    db $EA                         ; $48E7  ▶ new page
    db $9F                         ; $48E8  box tag
    db $96                         ; $48E9  end name/box tag
    db $42,$55,$38,$26,$3E         ; $48EA  ほんとうは
    db $90                         ; $48EF  　(space)
    db $2F,$4F,$33,$25,$2B,$31,$3A ; $48F0  しりたいくせに
    db $A4                         ; $48F7  、
    db $8F                         ; $48F8  。
    db $EF,$EE                     ; $48F9  newline
    db $F7                         ; $48FB  clear page
    db $F0                         ; $48FC  end of message


; --------------------------------------------------------------------------
; Message #25 ($48FD)
;   「そこのマドハンドに　ジユンケンで
;   れんしょうすれば　あえるのじゃ！
;   「さかばにおる　よっぱらいにきけば
;   もっといいこと　しっとるかもな。
; --------------------------------------------------------------------------
Bank67_Msg25:                              ; $48FD  (file $10C8FD)
    db $EA                         ; $48FD  ▶ new page
    db $9F                         ; $48FE  box tag
    db $96                         ; $48FF  end name/box tag
    db $32,$2D,$3D,$7A,$6F,$8D,$75,$8C,$6F,$8D,$3A; $4900  そこのマト゛ハント゛に = そこのマドハンドに
    db $90                         ; $490B  　(space)
    db $66,$8D,$80,$8C,$63,$8C,$37,$8D; $490C  シ゛ユンケンて゛ = ジユンケンで
    db $EF,$EE                     ; $4914  newline
    db $90,$90                     ; $4916  　　(indent)
    db $51,$55,$2F,$4D,$26,$30,$51,$3E,$8D; $4918  れんしょうすれは゛ = れんしょうすれば
    db $90                         ; $4921  　(space)
    db $24,$27,$50,$3D,$2F,$8D,$49 ; $4922  あえるのし゛ゃ = あえるのじゃ
    db $99                         ; $4929  ！
    db $FA                         ; $492A  wait-for-button
    db $F7                         ; $492B  clear page
    db $EF,$EE                     ; $492C  newline
    db $9F                         ; $492E  box tag
    db $96                         ; $492F  end name/box tag
    db $2E,$29,$3E,$8D,$3A,$28,$50 ; $4930  さかは゛におる = さかばにおる
    db $90                         ; $4937  　(space)
    db $4C,$36,$3E,$8E,$4E,$25,$3A,$2A,$2C,$3E,$8D; $4938  よっは゜らいにきけは゛ = よっぱらいにきけば
    db $EF,$EE                     ; $4943  newline
    db $90,$90                     ; $4945  　　(indent)
    db $47,$36,$38,$25,$25,$2D,$38 ; $4947  もっといいこと
    db $90                         ; $494E  　(space)
    db $2F,$36,$38,$50,$29,$47,$39 ; $494F  しっとるかもな
    db $8F                         ; $4956  。
    db $F7                         ; $4957  clear page
    db $F0                         ; $4958  end of message


; --------------------------------------------------------------------------
; Message #26 ($4959)
;   「このぞうは　タィジャの
;   まもりがみさまの　ぞうなるぞう！
;   「ぼうけんに　でかけるまえには
;   ぼうけんのしょを　つけること。
;   「こりゃ　きほんじゃな。
; --------------------------------------------------------------------------
Bank67_Msg26:                              ; $4959  (file $10C959)
    db $EA                         ; $4959  ▶ new page
    db $9F                         ; $495A  box tag
    db $96                         ; $495B  end name/box tag
    db $2D,$3D,$32,$8D,$26,$3E     ; $495C  このそ゛うは = このぞうは
    db $90                         ; $4962  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $4963  タィシ゛ャの = タィジャの
    db $EF,$EE                     ; $4969  newline
    db $90,$90                     ; $496B  　　(indent)
    db $43,$47,$4F,$29,$8D,$44,$2E,$43,$3D; $496D  まもりか゛みさまの = まもりがみさまの
    db $90                         ; $4976  　(space)
    db $32,$8D,$26,$39,$50,$32,$8D,$26; $4977  そ゛うなるそ゛う = ぞうなるぞう
    db $99                         ; $497F  ！
    db $FA                         ; $4980  wait-for-button
    db $F7                         ; $4981  clear page
    db $EF,$EE                     ; $4982  newline
    db $9F                         ; $4984  box tag
    db $96                         ; $4985  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A     ; $4986  ほ゛うけんに = ぼうけんに
    db $90                         ; $498C  　(space)
    db $37,$8D,$29,$2C,$50,$43,$27,$3A,$3E; $498D  て゛かけるまえには = でかけるまえには
    db $EF,$EE                     ; $4996  newline
    db $90,$90                     ; $4998  　　(indent)
    db $42,$8D,$26,$2C,$55,$3D,$2F,$4D,$54; $499A  ほ゛うけんのしょを = ぼうけんのしょを
    db $90                         ; $49A3  　(space)
    db $35,$2C,$50,$2D,$38         ; $49A4  つけること
    db $8F                         ; $49A9  。
    db $FA                         ; $49AA  wait-for-button
    db $F7                         ; $49AB  clear page
    db $EF,$EE                     ; $49AC  newline
    db $9F                         ; $49AE  box tag
    db $96                         ; $49AF  end name/box tag
    db $2D,$4F,$49                 ; $49B0  こりゃ
    db $90                         ; $49B3  　(space)
    db $2A,$42,$55,$2F,$8D,$49,$39 ; $49B4  きほんし゛ゃな = きほんじゃな
    db $8F                         ; $49BB  。
    db $EF,$EE                     ; $49BC  newline
    db $F7                         ; $49BE  clear page
    db $F0                         ; $49BF  end of message


; --------------------------------------------------------------------------
; Message #27 ($49C0)
;   「いらっしゃい。　このおくは
;   さかばですのよ。
; --------------------------------------------------------------------------
Bank67_Msg27:                              ; $49C0  (file $10C9C0)
    db $EB                         ; $49C0  ▶ new page
    db $9F                         ; $49C1  box tag
    db $96                         ; $49C2  end name/box tag
    db $25,$4E,$36,$2F,$49,$25     ; $49C3  いらっしゃい
    db $8F                         ; $49C9  。
    db $90                         ; $49CA  　(space)
    db $2D,$3D,$28,$2B,$3E         ; $49CB  このおくは
    db $EF,$EE                     ; $49D0  newline
    db $90,$90                     ; $49D2  　　(indent)
    db $2E,$29,$3E,$8D,$37,$8D,$30,$3D,$4C; $49D4  さかは゛て゛すのよ = さかばですのよ
    db $8F                         ; $49DD  。
    db $F7                         ; $49DE  clear page
    db $F0                         ; $49DF  end of message


; --------------------------------------------------------------------------
; Message #28 ($49E0)
;   「さかばの　いりぐちにいるやつ！
;   あいつは　ォレのラィバルなんだ！
; --------------------------------------------------------------------------
Bank67_Msg28:                              ; $49E0  (file $10C9E0)
    db $EA                         ; $49E0  ▶ new page
    db $9F                         ; $49E1  box tag
    db $96                         ; $49E2  end name/box tag
    db $2E,$29,$3E,$8D,$3D         ; $49E3  さかは゛の = さかばの
    db $90                         ; $49E8  　(space)
    db $25,$4F,$2B,$8D,$34,$3A,$25,$50,$48,$35; $49E9  いりく゛ちにいるやつ = いりぐちにいるやつ
    db $99                         ; $49F3  ！
    db $EF,$EE                     ; $49F4  newline
    db $90,$90                     ; $49F6  　　(indent)
    db $24,$25,$35,$3E             ; $49F8  あいつは
    db $90                         ; $49FC  　(space)
    db $5E,$88,$3D,$85,$58,$75,$8D,$87,$39,$55,$33,$8D; $49FD  ォレのラィハ゛ルなんた゛ = ォレのラィバルなんだ
    db $99                         ; $4A09  ！
    db $F7                         ; $4A0A  clear page
    db $F0                         ; $4A0B  end of message


; --------------------------------------------------------------------------
; Message #29 ($4A0C)
;   「ォレのラィバルは　きっとどこかで
;   ォレを　みはっているはずだ、。
;   「おっと　おめえも　マスターか？
;   なら　ちゅうこくしといてやろう。
;   「たびのとびらの　むこうでは
;   よそのくにのマスターにきをつけろ
;   「おめえみたいな　よわいやつは
;   こてんぱんに　されちまうぞ！
; --------------------------------------------------------------------------
Bank67_Msg29:                              ; $4A0C  (file $10CA0C)
    db $EA                         ; $4A0C  ▶ new page
    db $9F                         ; $4A0D  box tag
    db $96                         ; $4A0E  end name/box tag
    db $5E,$88,$3D,$85,$58,$75,$8D,$87,$3E; $4A0F  ォレのラィハ゛ルは = ォレのラィバルは
    db $90                         ; $4A18  　(space)
    db $2A,$36,$38,$38,$8D,$2D,$29,$37,$8D; $4A19  きっとと゛こかて゛ = きっとどこかで
    db $EF,$EE                     ; $4A22  newline
    db $90,$90                     ; $4A24  　　(indent)
    db $5E,$88,$54                 ; $4A26  ォレを
    db $90                         ; $4A29  　(space)
    db $44,$3E,$36,$37,$25,$50,$3E,$30,$8D,$33,$8D; $4A2A  みはっているはす゛た゛ = みはっているはずだ
    db $A4                         ; $4A35  、
    db $8F                         ; $4A36  。
    db $FA                         ; $4A37  wait-for-button
    db $F7                         ; $4A38  clear page
    db $EF,$EE                     ; $4A39  newline
    db $9F                         ; $4A3B  box tag
    db $96                         ; $4A3C  end name/box tag
    db $28,$36,$38                 ; $4A3D  おっと
    db $90                         ; $4A40  　(space)
    db $28,$46,$27,$47             ; $4A41  おめえも
    db $90                         ; $4A45  　(space)
    db $7A,$67,$6A,$9C,$29         ; $4A46  マスターか
    db $98                         ; $4A4B  ？
    db $EF,$EE                     ; $4A4C  newline
    db $90,$90                     ; $4A4E  　　(indent)
    db $39,$4E                     ; $4A50  なら
    db $90                         ; $4A52  　(space)
    db $34,$4B,$26,$2D,$2B,$2F,$38,$25,$37,$48,$52,$26; $4A53  ちゅうこくしといてやろう
    db $8F                         ; $4A5F  。
    db $FA                         ; $4A60  wait-for-button
    db $F7                         ; $4A61  clear page
    db $EF,$EE                     ; $4A62  newline
    db $9F                         ; $4A64  box tag
    db $96                         ; $4A65  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D; $4A66  たひ゛のとひ゛らの = たびのとびらの
    db $90                         ; $4A6F  　(space)
    db $45,$2D,$26,$37,$8D,$3E     ; $4A70  むこうて゛は = むこうでは
    db $EF,$EE                     ; $4A76  newline
    db $90,$90                     ; $4A78  　　(indent)
    db $4C,$32,$3D,$2B,$3A,$3D,$7A,$67,$6A,$9C,$3A,$2A,$54,$35,$2C,$52; $4A7A  よそのくにのマスターにきをつけろ
    db $FA                         ; $4A8A  wait-for-button
    db $F7                         ; $4A8B  clear page
    db $EF,$EE                     ; $4A8C  newline
    db $9F                         ; $4A8E  box tag
    db $96                         ; $4A8F  end name/box tag
    db $28,$46,$27,$44,$33,$25,$39 ; $4A90  おめえみたいな
    db $90                         ; $4A97  　(space)
    db $4C,$53,$25,$48,$35,$3E     ; $4A98  よわいやつは
    db $EF,$EE                     ; $4A9E  newline
    db $90,$90                     ; $4AA0  　　(indent)
    db $2D,$37,$55,$3E,$8E,$55,$3A ; $4AA2  こてんは゜んに = こてんぱんに
    db $90                         ; $4AA9  　(space)
    db $2E,$51,$34,$43,$26,$32,$8D ; $4AAA  されちまうそ゛ = されちまうぞ
    db $99                         ; $4AB1  ！
    db $F7                         ; $4AB2  clear page
    db $F0                         ; $4AB3  end of message


; --------------------------------------------------------------------------
; Message #30 ($4AB4)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   なかには　おばさんの
;   てちょうが　はいっている。
;   「きょういくの　てびき[97]
;   よんでみますか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg30:                              ; $4AB4  (file $10CAB4)
    db $F6                         ; $4AB4  «insert hero name»
    db $3E                         ; $4AB5  は
    db $90                         ; $4AB6  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $4AB7  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $4ABE  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $4AC0  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $4AC8  。
    db $FA                         ; $4AC9  wait-for-button
    db $F7                         ; $4ACA  clear page
    db $EF,$EE                     ; $4ACB  newline
    db $39,$29,$3A,$3E             ; $4ACD  なかには
    db $90                         ; $4AD1  　(space)
    db $28,$3E,$8D,$2E,$55,$3D     ; $4AD2  おは゛さんの = おばさんの
    db $EF,$EE                     ; $4AD8  newline
    db $37,$34,$4D,$26,$29,$8D     ; $4ADA  てちょうか゛ = てちょうが
    db $90                         ; $4AE0  　(space)
    db $3E,$25,$36,$37,$25,$50     ; $4AE1  はいっている
    db $8F                         ; $4AE7  。
    db $FA                         ; $4AE8  wait-for-button
    db $F7                         ; $4AE9  clear page
    db $EF,$EE                     ; $4AEA  newline
    db $96                         ; $4AEC  end name/box tag
    db $2A,$4D,$26,$25,$2B,$3D     ; $4AED  きょういくの
    db $90                         ; $4AF3  　(space)
    db $37,$3F,$8D,$2A             ; $4AF4  てひ゛き = てびき
    db $97                         ; $4AF8  ctrl $97
    db $EF,$EE                     ; $4AF9  newline
    db $4C,$55,$37,$8D,$44,$43,$30,$29; $4AFB  よんて゛みますか = よんでみますか
    db $98                         ; $4B03  ？
    db $FF                         ; $4B04  はい/いいえ
    db $F0                         ; $4B05  end of message


; --------------------------------------------------------------------------
; Message #31 ($4B06)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   なかに　かみきれが　はいっていた。
;   かみきれには　なにか　かかれている。
;   「マドハンドに　[05]かいれんぞくで
;   かてば　いいことがあるよ。
; --------------------------------------------------------------------------
Bank67_Msg31:                              ; $4B06  (file $10CB06)
    db $F6                         ; $4B06  «insert hero name»
    db $3E                         ; $4B07  は
    db $90                         ; $4B08  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $4B09  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $4B10  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $4B12  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $4B1A  。
    db $FA                         ; $4B1B  wait-for-button
    db $F7                         ; $4B1C  clear page
    db $EF,$EE                     ; $4B1D  newline
    db $39,$29,$3A                 ; $4B1F  なかに
    db $90                         ; $4B22  　(space)
    db $29,$44,$2A,$51,$29,$8D     ; $4B23  かみきれか゛ = かみきれが
    db $90                         ; $4B29  　(space)
    db $3E,$25,$36,$37,$25,$33     ; $4B2A  はいっていた
    db $8F                         ; $4B30  。
    db $EF,$EE                     ; $4B31  newline
    db $29,$44,$2A,$51,$3A,$3E     ; $4B33  かみきれには
    db $90                         ; $4B39  　(space)
    db $39,$3A,$29                 ; $4B3A  なにか
    db $90                         ; $4B3D  　(space)
    db $29,$29,$51,$37,$25,$50     ; $4B3E  かかれている
    db $8F                         ; $4B44  。
    db $FA                         ; $4B45  wait-for-button
    db $F7                         ; $4B46  clear page
    db $EF,$EE                     ; $4B47  newline
    db $96                         ; $4B49  end name/box tag
    db $7A,$6F,$8D,$75,$8C,$6F,$8D,$3A; $4B4A  マト゛ハント゛に = マドハンドに
    db $90                         ; $4B52  　(space)
    db $05                         ; $4B53  ctrl $05
    db $29,$25,$51,$55,$32,$8D,$2B,$37,$8D; $4B54  かいれんそ゛くて゛ = かいれんぞくで
    db $EF,$EE                     ; $4B5D  newline
    db $90                         ; $4B5F  　(space)
    db $29,$37,$3E,$8D             ; $4B60  かては゛ = かてば
    db $90                         ; $4B64  　(space)
    db $25,$25,$2D,$38,$29,$8D,$24,$50,$4C; $4B65  いいことか゛あるよ = いいことがあるよ
    db $8F                         ; $4B6E  。
    db $F7                         ; $4B6F  clear page
    db $F0                         ; $4B70  end of message


; --------------------------------------------------------------------------
; Message #32 ($4B71)
;   「ふう、、。　なかなか
;   いうことを　きかんわい。
;   「まだまだ　かしこさが
;   たりないのかも　しれんな。
; --------------------------------------------------------------------------
Bank67_Msg32:                              ; $4B71  (file $10CB71)
    db $EA                         ; $4B71  ▶ new page
    db $9F                         ; $4B72  box tag
    db $96                         ; $4B73  end name/box tag
    db $40,$26                     ; $4B74  ふう
    db $A4                         ; $4B76  、
    db $A4                         ; $4B77  、
    db $8F                         ; $4B78  。
    db $90                         ; $4B79  　(space)
    db $39,$29,$39,$29             ; $4B7A  なかなか
    db $EF,$EE                     ; $4B7E  newline
    db $90,$90                     ; $4B80  　　(indent)
    db $25,$26,$2D,$38,$54         ; $4B82  いうことを
    db $90                         ; $4B87  　(space)
    db $2A,$29,$55,$53,$25         ; $4B88  きかんわい
    db $8F                         ; $4B8D  。
    db $FA                         ; $4B8E  wait-for-button
    db $F7                         ; $4B8F  clear page
    db $EF,$EE                     ; $4B90  newline
    db $9F                         ; $4B92  box tag
    db $96                         ; $4B93  end name/box tag
    db $43,$33,$8D,$43,$33,$8D     ; $4B94  また゛また゛ = まだまだ
    db $90                         ; $4B9A  　(space)
    db $29,$2F,$2D,$2E,$29,$8D     ; $4B9B  かしこさか゛ = かしこさが
    db $EF,$EE                     ; $4BA1  newline
    db $90,$90                     ; $4BA3  　　(indent)
    db $33,$4F,$39,$25,$3D,$29,$47 ; $4BA5  たりないのかも
    db $90                         ; $4BAC  　(space)
    db $2F,$51,$55,$39             ; $4BAD  しれんな
    db $8F                         ; $4BB1  。
    db $F7                         ; $4BB2  clear page
    db $F0                         ; $4BB3  end of message


; --------------------------------------------------------------------------
; Message #33 ($4BB4)
;   「えいほ　えいほ。
;   「あーあ　はらが　へったなあ、。
;   「こんなんじゃ　めいれいされても
;   はらがたつだけだぞ！
; --------------------------------------------------------------------------
Bank67_Msg33:                              ; $4BB4  (file $10CBB4)
    db $EA                         ; $4BB4  ▶ new page
    db $9F                         ; $4BB5  box tag
    db $96                         ; $4BB6  end name/box tag
    db $27,$25,$42                 ; $4BB7  えいほ
    db $90                         ; $4BBA  　(space)
    db $27,$25,$42                 ; $4BBB  えいほ
    db $8F                         ; $4BBE  。
    db $EF,$EE                     ; $4BBF  newline
    db $FA                         ; $4BC1  wait-for-button
    db $F7                         ; $4BC2  clear page
    db $EF,$EE                     ; $4BC3  newline
    db $F3                         ; $4BC5  open text box
    db $9F                         ; $4BC6  box tag
    db $96                         ; $4BC7  end name/box tag
    db $24,$9C,$24                 ; $4BC8  あーあ
    db $90                         ; $4BCB  　(space)
    db $3E,$4E,$29,$8D             ; $4BCC  はらか゛ = はらが
    db $90                         ; $4BD0  　(space)
    db $41,$36,$33,$39,$24         ; $4BD1  へったなあ
    db $A4                         ; $4BD6  、
    db $8F                         ; $4BD7  。
    db $EF,$EE                     ; $4BD8  newline
    db $FA                         ; $4BDA  wait-for-button
    db $F7                         ; $4BDB  clear page
    db $EF,$EE                     ; $4BDC  newline
    db $F3                         ; $4BDE  open text box
    db $9F                         ; $4BDF  box tag
    db $96                         ; $4BE0  end name/box tag
    db $2D,$55,$39,$55,$2F,$8D,$49 ; $4BE1  こんなんし゛ゃ = こんなんじゃ
    db $90                         ; $4BE8  　(space)
    db $46,$25,$51,$25,$2E,$51,$37,$47; $4BE9  めいれいされても
    db $EF,$EE                     ; $4BF1  newline
    db $90,$90                     ; $4BF3  　　(indent)
    db $3E,$4E,$29,$8D,$33,$35,$33,$8D,$2C,$33,$8D,$32,$8D; $4BF5  はらか゛たつた゛けた゛そ゛ = はらがたつだけだぞ
    db $99                         ; $4C02  ！
    db $F7                         ; $4C03  clear page
    db $F0                         ; $4C04  end of message


; --------------------------------------------------------------------------
; Message #34 ($4C05)
;   「へへっ！　にいちゃんよ[95]。
;   [10]クラスのあいてを　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg34:                              ; $4C05  (file $10CC05)
    db $EA                         ; $4C05  ▶ new page
    db $9F                         ; $4C06  box tag
    db $96                         ; $4C07  end name/box tag
    db $41,$41,$36                 ; $4C08  へへっ
    db $99                         ; $4C0B  ！
    db $90                         ; $4C0C  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $4C0D  にいちゃんよ
    db $95                         ; $4C13  ctrl $95
    db $8F                         ; $4C14  。
    db $EF,$EE                     ; $4C15  newline
    db $90,$90                     ; $4C17  　　(indent)
    db $10                         ; $4C19  ctrl $10
    db $62,$85,$67,$3D,$24,$25,$37,$54; $4C1A  クラスのあいてを
    db $90                         ; $4C22  　(space)
    db $2F,$4F,$33,$25,$29         ; $4C23  しりたいか
    db $98                         ; $4C28  ？
    db $FF                         ; $4C29  はい/いいえ
    db $F0                         ; $4C2A  end of message


; --------------------------------------------------------------------------
; Message #35 ($4C2B)
;   「[10]クラスの　さいしゅうせんは
;   じゅくちょうが　あいてだぜ。
; --------------------------------------------------------------------------
Bank67_Msg35:                              ; $4C2B  (file $10CC2B)
    db $EA                         ; $4C2B  ▶ new page
    db $9F                         ; $4C2C  box tag
    db $96                         ; $4C2D  end name/box tag
    db $10                         ; $4C2E  ctrl $10
    db $62,$85,$67,$3D             ; $4C2F  クラスの
    db $90                         ; $4C33  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $4C34  さいしゅうせんは
    db $EF,$EE                     ; $4C3C  newline
    db $90,$90                     ; $4C3E  　　(indent)
    db $2F,$8D,$4B,$2B,$34,$4D,$26,$29,$8D; $4C40  し゛ゅくちょうか゛ = じゅくちょうが
    db $90                         ; $4C49  　(space)
    db $24,$25,$37,$33,$8D,$31,$8D ; $4C4A  あいてた゛せ゛ = あいてだぜ
    db $8F                         ; $4C51  。
    db $F7                         ; $4C52  clear page
    db $F0                         ; $4C53  end of message


; --------------------------------------------------------------------------
; Message #36 ($4C54)
;   「まっ　それも　いいだろうよ。
; --------------------------------------------------------------------------
Bank67_Msg36:                              ; $4C54  (file $10CC54)
    db $EA                         ; $4C54  ▶ new page
    db $9F                         ; $4C55  box tag
    db $96                         ; $4C56  end name/box tag
    db $43,$36                     ; $4C57  まっ
    db $90                         ; $4C59  　(space)
    db $32,$51,$47                 ; $4C5A  それも
    db $90                         ; $4C5D  　(space)
    db $25,$25,$33,$8D,$52,$26,$4C ; $4C5E  いいた゛ろうよ = いいだろうよ
    db $8F                         ; $4C65  。
    db $EF,$EE                     ; $4C66  newline
    db $F7                         ; $4C68  clear page
    db $F0                         ; $4C69  end of message


; --------------------------------------------------------------------------
; Message #37 ($4C6A)
;   「まちびとのとびらの　わが
;   おもいでを　ききたくないか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg37:                              ; $4C6A  (file $10CC6A)
    db $EA                         ; $4C6A  ▶ new page
    db $9F                         ; $4C6B  box tag
    db $96                         ; $4C6C  end name/box tag
    db $43,$34,$3F,$8D,$38,$3D,$38,$3F,$8D,$4E,$3D; $4C6D  まちひ゛とのとひ゛らの = まちびとのとびらの
    db $90                         ; $4C78  　(space)
    db $53,$29,$8D                 ; $4C79  わか゛ = わが
    db $EF,$EE                     ; $4C7C  newline
    db $90,$90                     ; $4C7E  　　(indent)
    db $28,$47,$25,$37,$8D,$54     ; $4C80  おもいて゛を = おもいでを
    db $90                         ; $4C86  　(space)
    db $2A,$2A,$33,$2B,$39,$25,$29 ; $4C87  ききたくないか
    db $98                         ; $4C8E  ？
    db $FF                         ; $4C8F  はい/いいえ
    db $F0                         ; $4C90  end of message


; --------------------------------------------------------------------------
; Message #38 ($4C91)
;   「きりかぶおばけや　キリキリバッタ
;   アントベア　グレムリンがいたな。
;   「きりかぶおばけは　ラリホーを
;   となえてくるぞ。ねむらされるな！
;   「キリキリバッタが　ちからを
;   ためたときは　きをつけることだ！
;   「あそこのぬしは　ドラゴンだ。
;   「やつの　ひのいきは　ぜんいんに
;   おおきなダメージを　あたえるぞ！
;   「やくそうは　じゅうぶんに
;   もっていくことだ。
; --------------------------------------------------------------------------
Bank67_Msg38:                              ; $4C91  (file $10CC91)
    db $EA                         ; $4C91  ▶ new page
    db $9F                         ; $4C92  box tag
    db $96                         ; $4C93  end name/box tag
    db $2A,$4F,$29,$40,$8D,$28,$3E,$8D,$2C,$48; $4C94  きりかふ゛おは゛けや = きりかぶおばけや
    db $90                         ; $4C9E  　(space)
    db $61,$86,$61,$86,$75,$8D,$6D,$6A; $4C9F  キリキリハ゛ッタ = キリキリバッタ
    db $EF,$EE                     ; $4CA7  newline
    db $90,$90                     ; $4CA9  　　(indent)
    db $56,$8C,$6F,$78,$8D,$56     ; $4CAB  アントヘ゛ア = アントベア
    db $90                         ; $4CB1  　(space)
    db $62,$8D,$88,$7C,$86,$8C,$29,$8D,$25,$33,$39; $4CB2  ク゛レムリンか゛いたな = グレムリンがいたな
    db $8F                         ; $4CBD  。
    db $FA                         ; $4CBE  wait-for-button
    db $F7                         ; $4CBF  clear page
    db $EF,$EE                     ; $4CC0  newline
    db $9F                         ; $4CC2  box tag
    db $96                         ; $4CC3  end name/box tag
    db $2A,$4F,$29,$40,$8D,$28,$3E,$8D,$2C,$3E; $4CC4  きりかふ゛おは゛けは = きりかぶおばけは
    db $90                         ; $4CCE  　(space)
    db $85,$86,$79,$9C,$54         ; $4CCF  ラリホーを
    db $EF,$EE                     ; $4CD4  newline
    db $90,$90                     ; $4CD6  　　(indent)
    db $38,$39,$27,$37,$2B,$50,$32,$8D; $4CD8  となえてくるそ゛ = となえてくるぞ
    db $8F                         ; $4CE0  。
    db $3C,$45,$4E,$2E,$51,$50,$39 ; $4CE1  ねむらされるな
    db $99                         ; $4CE8  ！
    db $FA                         ; $4CE9  wait-for-button
    db $F7                         ; $4CEA  clear page
    db $EF,$EE                     ; $4CEB  newline
    db $9F                         ; $4CED  box tag
    db $96                         ; $4CEE  end name/box tag
    db $61,$86,$61,$86,$75,$8D,$6D,$6A,$29,$8D; $4CEF  キリキリハ゛ッタか゛ = キリキリバッタが
    db $90                         ; $4CF9  　(space)
    db $34,$29,$4E,$54             ; $4CFA  ちからを
    db $EF,$EE                     ; $4CFE  newline
    db $90,$90                     ; $4D00  　　(indent)
    db $33,$46,$33,$38,$2A,$3E     ; $4D02  ためたときは
    db $90                         ; $4D08  　(space)
    db $2A,$54,$35,$2C,$50,$2D,$38,$33,$8D; $4D09  きをつけることた゛ = きをつけることだ
    db $99                         ; $4D12  ！
    db $FA                         ; $4D13  wait-for-button
    db $F7                         ; $4D14  clear page
    db $EF,$EE                     ; $4D15  newline
    db $9F                         ; $4D17  box tag
    db $96                         ; $4D18  end name/box tag
    db $24,$32,$2D,$3D,$3B,$2F,$3E ; $4D19  あそこのぬしは
    db $90                         ; $4D20  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$33,$8D; $4D21  ト゛ラコ゛ンた゛ = ドラゴンだ
    db $8F                         ; $4D29  。
    db $EF,$EE                     ; $4D2A  newline
    db $FA                         ; $4D2C  wait-for-button
    db $F7                         ; $4D2D  clear page
    db $EF,$EE                     ; $4D2E  newline
    db $F3                         ; $4D30  open text box
    db $9F                         ; $4D31  box tag
    db $96                         ; $4D32  end name/box tag
    db $48,$35,$3D                 ; $4D33  やつの
    db $90                         ; $4D36  　(space)
    db $3F,$3D,$25,$2A,$3E         ; $4D37  ひのいきは
    db $90                         ; $4D3C  　(space)
    db $31,$8D,$55,$25,$55,$3A     ; $4D3D  せ゛んいんに = ぜんいんに
    db $EF,$EE                     ; $4D43  newline
    db $90,$90                     ; $4D45  　　(indent)
    db $28,$28,$2A,$39,$6A,$8D,$7D,$9C,$66,$8D,$54; $4D47  おおきなタ゛メーシ゛を = おおきなダメージを
    db $90                         ; $4D52  　(space)
    db $24,$33,$27,$50,$32,$8D     ; $4D53  あたえるそ゛ = あたえるぞ
    db $99                         ; $4D59  ！
    db $FA                         ; $4D5A  wait-for-button
    db $F7                         ; $4D5B  clear page
    db $EF,$EE                     ; $4D5C  newline
    db $9F                         ; $4D5E  box tag
    db $96                         ; $4D5F  end name/box tag
    db $48,$2B,$32,$26,$3E         ; $4D60  やくそうは
    db $90                         ; $4D65  　(space)
    db $2F,$8D,$4B,$26,$40,$8D,$55,$3A; $4D66  し゛ゅうふ゛んに = じゅうぶんに
    db $EF,$EE                     ; $4D6E  newline
    db $90,$90                     ; $4D70  　　(indent)
    db $47,$36,$37,$25,$2B,$2D,$38,$33,$8D; $4D72  もっていくことた゛ = もっていくことだ
    db $8F                         ; $4D7B  。
    db $F7                         ; $4D7C  clear page
    db $F0                         ; $4D7D  end of message


; --------------------------------------------------------------------------
; Message #39 ($4D7E)
;   「あの　たびのとびらも　いまでは
;   よき　おもいでだ、。
; --------------------------------------------------------------------------
Bank67_Msg39:                              ; $4D7E  (file $10CD7E)
    db $EA                         ; $4D7E  ▶ new page
    db $9F                         ; $4D7F  box tag
    db $96                         ; $4D80  end name/box tag
    db $24,$3D                     ; $4D81  あの
    db $90                         ; $4D83  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$47; $4D84  たひ゛のとひ゛らも = たびのとびらも
    db $90                         ; $4D8D  　(space)
    db $25,$43,$37,$8D,$3E         ; $4D8E  いまて゛は = いまでは
    db $EF,$EE                     ; $4D93  newline
    db $90,$90                     ; $4D95  　　(indent)
    db $4C,$2A                     ; $4D97  よき
    db $90                         ; $4D99  　(space)
    db $28,$47,$25,$37,$8D,$33,$8D ; $4D9A  おもいて゛た゛ = おもいでだ
    db $A4                         ; $4DA1  、
    db $8F                         ; $4DA2  。
    db $F7                         ; $4DA3  clear page
    db $F0                         ; $4DA4  end of message


; --------------------------------------------------------------------------
; Message #40 ($4DA5)
;   「まもりのとびらに　すんでいる
;   まもののことを　しりたいかい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg40:                              ; $4DA5  (file $10CDA5)
    db $EA                         ; $4DA5  ▶ new page
    db $9F                         ; $4DA6  box tag
    db $96                         ; $4DA7  end name/box tag
    db $43,$47,$4F,$3D,$38,$3F,$8D,$4E,$3A; $4DA8  まもりのとひ゛らに = まもりのとびらに
    db $90                         ; $4DB1  　(space)
    db $30,$55,$37,$8D,$25,$50     ; $4DB2  すんて゛いる = すんでいる
    db $EF,$EE                     ; $4DB8  newline
    db $90,$90                     ; $4DBA  　　(indent)
    db $43,$47,$3D,$3D,$2D,$38,$54 ; $4DBC  まもののことを
    db $90                         ; $4DC3  　(space)
    db $2F,$4F,$33,$25,$29,$25     ; $4DC4  しりたいかい
    db $98                         ; $4DCA  ？
    db $FF                         ; $4DCB  はい/いいえ
    db $F0                         ; $4DCC  end of message


; --------------------------------------------------------------------------
; Message #41 ($4DCD)
;   「これはラィスボール。　さあベベ。
;   いってごらんなさい。　せーの！
; --------------------------------------------------------------------------
Bank67_Msg41:                              ; $4DCD  (file $10CDCD)
    db $EA                         ; $4DCD  ▶ new page
    db $9F                         ; $4DCE  box tag
    db $96                         ; $4DCF  end name/box tag
    db $2D,$51,$3E,$85,$58,$67,$79,$8D,$9C,$87; $4DD0  これはラィスホ゛ール = これはラィスボール
    db $8F                         ; $4DDA  。
    db $90                         ; $4DDB  　(space)
    db $2E,$24,$78,$8D,$78,$8D     ; $4DDC  さあヘ゛ヘ゛ = さあベベ
    db $8F                         ; $4DE2  。
    db $EF,$EE                     ; $4DE3  newline
    db $90,$90                     ; $4DE5  　　(indent)
    db $25,$36,$37,$2D,$8D,$4E,$55,$39,$2E,$25; $4DE7  いってこ゛らんなさい = いってごらんなさい
    db $8F                         ; $4DF1  。
    db $90                         ; $4DF2  　(space)
    db $31,$9C,$3D                 ; $4DF3  せーの
    db $99                         ; $4DF6  ！
    db $F7                         ; $4DF7  clear page
    db $F0                         ; $4DF8  end of message


; --------------------------------------------------------------------------
; Message #42 ($4DF9)
;   べべ「フンガー　フンガー！
; --------------------------------------------------------------------------
Bank67_Msg42:                              ; $4DF9  (file $10CDF9)
    db $EA                         ; $4DF9  ▶ new page
    db $41,$8D,$41,$8D             ; $4DFA  へ゛へ゛ = べべ
    db $96                         ; $4DFE  end name/box tag
    db $77,$8C,$60,$8D,$9C         ; $4DFF  フンカ゛ー = フンガー
    db $90                         ; $4E04  　(space)
    db $77,$8C,$60,$8D,$9C         ; $4E05  フンカ゛ー = フンガー
    db $99                         ; $4E0A  ！
    db $EF,$EE                     ; $4E0B  newline
    db $F7                         ; $4E0D  clear page
    db $F0                         ; $4E0E  end of message


; --------------------------------------------------------------------------
; Message #43 ($4E0F)
;   「、、。
; --------------------------------------------------------------------------
Bank67_Msg43:                              ; $4E0F  (file $10CE0F)
    db $EA                         ; $4E0F  ▶ new page
    db $9F                         ; $4E10  box tag
    db $96                         ; $4E11  end name/box tag
    db $A4                         ; $4E12  、
    db $A4                         ; $4E13  、
    db $8F                         ; $4E14  。
    db $EF,$EE                     ; $4E15  newline
    db $F7                         ; $4E17  clear page
    db $F0                         ; $4E18  end of message


; --------------------------------------------------------------------------
; Message #44 ($4E19)
;   「ラィスボールって　なんじゃい！
;   おにぎりって　いわんか！！
; --------------------------------------------------------------------------
Bank67_Msg44:                              ; $4E19  (file $10CE19)
    db $EA                         ; $4E19  ▶ new page
    db $9F                         ; $4E1A  box tag
    db $96                         ; $4E1B  end name/box tag
    db $85,$58,$67,$79,$8D,$9C,$87,$36,$37; $4E1C  ラィスホ゛ールって = ラィスボールって
    db $90                         ; $4E25  　(space)
    db $39,$55,$2F,$8D,$49,$25     ; $4E26  なんし゛ゃい = なんじゃい
    db $99                         ; $4E2C  ！
    db $EF,$EE                     ; $4E2D  newline
    db $90,$90                     ; $4E2F  　　(indent)
    db $28,$3A,$2A,$8D,$4F,$36,$37 ; $4E31  おにき゛りって = おにぎりって
    db $90                         ; $4E38  　(space)
    db $25,$53,$55,$29             ; $4E39  いわんか
    db $99                         ; $4E3D  ！
    db $99                         ; $4E3E  ！
    db $F7                         ; $4E3F  clear page
    db $F0                         ; $4E40  end of message


; --------------------------------------------------------------------------
; Message #45 ($4E41)
;   「みんな　ゆうしょうを　めざして
;   ここ　かくとうじょうに　つどう。
;   「だが　しあいは　はんぱじゃなく
;   きびしい　たたかいだ。
;   「とちゅうで　ざせつするやつが
;   あとを　たたないのだ！
; --------------------------------------------------------------------------
Bank67_Msg45:                              ; $4E41  (file $10CE41)
    db $EA                         ; $4E41  ▶ new page
    db $9F                         ; $4E42  box tag
    db $96                         ; $4E43  end name/box tag
    db $44,$55,$39                 ; $4E44  みんな
    db $90                         ; $4E47  　(space)
    db $4A,$26,$2F,$4D,$26,$54     ; $4E48  ゆうしょうを
    db $90                         ; $4E4E  　(space)
    db $46,$2E,$8D,$2F,$37         ; $4E4F  めさ゛して = めざして
    db $EF,$EE                     ; $4E54  newline
    db $90,$90                     ; $4E56  　　(indent)
    db $2D,$2D                     ; $4E58  ここ
    db $90                         ; $4E5A  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A; $4E5B  かくとうし゛ょうに = かくとうじょうに
    db $90                         ; $4E64  　(space)
    db $35,$38,$8D,$26             ; $4E65  つと゛う = つどう
    db $8F                         ; $4E69  。
    db $FA                         ; $4E6A  wait-for-button
    db $F7                         ; $4E6B  clear page
    db $EF,$EE                     ; $4E6C  newline
    db $9F                         ; $4E6E  box tag
    db $96                         ; $4E6F  end name/box tag
    db $33,$8D,$29,$8D             ; $4E70  た゛か゛ = だが
    db $90                         ; $4E74  　(space)
    db $2F,$24,$25,$3E             ; $4E75  しあいは
    db $90                         ; $4E79  　(space)
    db $3E,$55,$3E,$8E,$2F,$8D,$49,$39,$2B; $4E7A  はんは゜し゛ゃなく = はんぱじゃなく
    db $EF,$EE                     ; $4E83  newline
    db $90,$90                     ; $4E85  　　(indent)
    db $2A,$3F,$8D,$2F,$25         ; $4E87  きひ゛しい = きびしい
    db $90                         ; $4E8C  　(space)
    db $33,$33,$29,$25,$33,$8D     ; $4E8D  たたかいた゛ = たたかいだ
    db $8F                         ; $4E93  。
    db $FA                         ; $4E94  wait-for-button
    db $F7                         ; $4E95  clear page
    db $EF,$EE                     ; $4E96  newline
    db $9F                         ; $4E98  box tag
    db $96                         ; $4E99  end name/box tag
    db $38,$34,$4B,$26,$37,$8D     ; $4E9A  とちゅうて゛ = とちゅうで
    db $90                         ; $4EA0  　(space)
    db $2E,$8D,$31,$35,$30,$50,$48,$35,$29,$8D; $4EA1  さ゛せつするやつか゛ = ざせつするやつが
    db $EF,$EE                     ; $4EAB  newline
    db $90,$90                     ; $4EAD  　　(indent)
    db $24,$38,$54                 ; $4EAF  あとを
    db $90                         ; $4EB2  　(space)
    db $33,$33,$39,$25,$3D,$33,$8D ; $4EB3  たたないのた゛ = たたないのだ
    db $99                         ; $4EBA  ！
    db $F7                         ; $4EBB  clear page
    db $F0                         ; $4EBC  end of message


; --------------------------------------------------------------------------
; Message #46 ($4EBD)
;   「おお　よくきたな　マス、ゴホン！
;   わしは　メダルおじさん。
;   「せかいじゅうに　ちらばる
;   ちいさなメダルを　あつめておる。
;   「どこかで　メダルを　みつけたら
;   わしにくれないか？
;   「あつめてきた　メダルのかずに
;   あわせて　ごほうびを　あげよう！
;   「きたいしておるぞ！
;   ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank67_Msg46:                              ; $4EBD  (file $10CEBD)
    db $EA                         ; $4EBD  ▶ new page
    db $9F                         ; $4EBE  box tag
    db $96                         ; $4EBF  end name/box tag
    db $28,$28                     ; $4EC0  おお
    db $90                         ; $4EC2  　(space)
    db $4C,$2B,$2A,$33,$39         ; $4EC3  よくきたな
    db $90                         ; $4EC8  　(space)
    db $7A,$67                     ; $4EC9  マス
    db $A4                         ; $4ECB  、
    db $64,$8D,$79,$8C             ; $4ECC  コ゛ホン = ゴホン
    db $99                         ; $4ED0  ！
    db $EF,$EE                     ; $4ED1  newline
    db $90,$90                     ; $4ED3  　　(indent)
    db $53,$2F,$3E                 ; $4ED5  わしは
    db $90                         ; $4ED8  　(space)
    db $7D,$6A,$8D,$87,$28,$2F,$8D,$2E,$55; $4ED9  メタ゛ルおし゛さん = メダルおじさん
    db $8F                         ; $4EE2  。
    db $FA                         ; $4EE3  wait-for-button
    db $F7                         ; $4EE4  clear page
    db $EF,$EE                     ; $4EE5  newline
    db $9F                         ; $4EE7  box tag
    db $96                         ; $4EE8  end name/box tag
    db $31,$29,$25,$2F,$8D,$4B,$26,$3A; $4EE9  せかいし゛ゅうに = せかいじゅうに
    db $90                         ; $4EF1  　(space)
    db $34,$4E,$3E,$8D,$50         ; $4EF2  ちらは゛る = ちらばる
    db $EF,$EE                     ; $4EF7  newline
    db $90,$90                     ; $4EF9  　　(indent)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $4EFB  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $4F04  　(space)
    db $24,$35,$46,$37,$28,$50     ; $4F05  あつめておる
    db $8F                         ; $4F0B  。
    db $FA                         ; $4F0C  wait-for-button
    db $F7                         ; $4F0D  clear page
    db $EF,$EE                     ; $4F0E  newline
    db $9F                         ; $4F10  box tag
    db $96                         ; $4F11  end name/box tag
    db $38,$8D,$2D,$29,$37,$8D     ; $4F12  と゛こかて゛ = どこかで
    db $90                         ; $4F18  　(space)
    db $7D,$6A,$8D,$87,$54         ; $4F19  メタ゛ルを = メダルを
    db $90                         ; $4F1E  　(space)
    db $44,$35,$2C,$33,$4E         ; $4F1F  みつけたら
    db $EF,$EE                     ; $4F24  newline
    db $90,$90                     ; $4F26  　　(indent)
    db $53,$2F,$3A,$2B,$51,$39,$25,$29; $4F28  わしにくれないか
    db $98                         ; $4F30  ？
    db $FA                         ; $4F31  wait-for-button
    db $F7                         ; $4F32  clear page
    db $EF,$EE                     ; $4F33  newline
    db $9F                         ; $4F35  box tag
    db $96                         ; $4F36  end name/box tag
    db $24,$35,$46,$37,$2A,$33     ; $4F37  あつめてきた
    db $90                         ; $4F3D  　(space)
    db $7D,$6A,$8D,$87,$3D,$29,$30,$8D,$3A; $4F3E  メタ゛ルのかす゛に = メダルのかずに
    db $EF,$EE                     ; $4F47  newline
    db $90,$90                     ; $4F49  　　(indent)
    db $24,$53,$31,$37             ; $4F4B  あわせて
    db $90                         ; $4F4F  　(space)
    db $2D,$8D,$42,$26,$3F,$8D,$54 ; $4F50  こ゛ほうひ゛を = ごほうびを
    db $90                         ; $4F57  　(space)
    db $24,$2C,$8D,$4C,$26         ; $4F58  あけ゛よう = あげよう
    db $99                         ; $4F5D  ！
    db $FA                         ; $4F5E  wait-for-button
    db $F7                         ; $4F5F  clear page
    db $EF,$EE                     ; $4F60  newline
    db $9F                         ; $4F62  box tag
    db $96                         ; $4F63  end name/box tag
    db $2A,$33,$25,$2F,$37,$28,$50,$32,$8D; $4F64  きたいしておるそ゛ = きたいしておるぞ
    db $99                         ; $4F6D  ！
    db $EF,$EE                     ; $4F6E  newline
    db $90,$90                     ; $4F70  　　(indent)
    db $58,$69                     ; $4F72  ィソ
    db $90                         ; $4F74  　(space)
    db $58,$69                     ; $4F75  ィソ
    db $A4                         ; $4F77  、
    db $90                         ; $4F78  　(space)
    db $58,$69                     ; $4F79  ィソ
    db $90                         ; $4F7B  　(space)
    db $58,$69                     ; $4F7C  ィソ
    db $A4                         ; $4F7E  、
    db $A4                         ; $4F7F  、
    db $8F                         ; $4F80  。
    db $FA                         ; $4F81  wait-for-button
    db $F7                         ; $4F82  clear page
    db $F0                         ; $4F83  end of message


; --------------------------------------------------------------------------
; Message #47 ($4F84)
;   「わしは　メダルをあつめておる
;   メダルおじさんじゃ。
; --------------------------------------------------------------------------
Bank67_Msg47:                              ; $4F84  (file $10CF84)
    db $EA                         ; $4F84  ▶ new page
    db $9F                         ; $4F85  box tag
    db $96                         ; $4F86  end name/box tag
    db $53,$2F,$3E                 ; $4F87  わしは
    db $90                         ; $4F8A  　(space)
    db $7D,$6A,$8D,$87,$54,$24,$35,$46,$37,$28,$50; $4F8B  メタ゛ルをあつめておる = メダルをあつめておる
    db $EF,$EE                     ; $4F96  newline
    db $90,$90                     ; $4F98  　　(indent)
    db $7D,$6A,$8D,$87,$28,$2F,$8D,$2E,$55,$2F,$8D,$49; $4F9A  メタ゛ルおし゛さんし゛ゃ = メダルおじさんじゃ
    db $8F                         ; $4FA6  。
    db $F7                         ; $4FA7  clear page
    db $F0                         ; $4FA8  end of message


; --------------------------------------------------------------------------
; Message #48 ($4FA9)
;   「おじさんも　ぼくも
;   メダルが　だいすきなのさ！
;   「メダルを　もってきてくれたら
;   おじさんが　ごほうびをくれるよ！
;   「たくさん　あつめてくれたら
;   ぼくも　なにか　あげようかな！
; --------------------------------------------------------------------------
Bank67_Msg48:                              ; $4FA9  (file $10CFA9)
    db $EB                         ; $4FA9  ▶ new page
    db $9F                         ; $4FAA  box tag
    db $96                         ; $4FAB  end name/box tag
    db $28,$2F,$8D,$2E,$55,$47     ; $4FAC  おし゛さんも = おじさんも
    db $90                         ; $4FB2  　(space)
    db $42,$8D,$2B,$47             ; $4FB3  ほ゛くも = ぼくも
    db $EF,$EE                     ; $4FB7  newline
    db $90,$90                     ; $4FB9  　　(indent)
    db $7D,$6A,$8D,$87,$29,$8D     ; $4FBB  メタ゛ルか゛ = メダルが
    db $90                         ; $4FC1  　(space)
    db $33,$8D,$25,$30,$2A,$39,$3D,$2E; $4FC2  た゛いすきなのさ = だいすきなのさ
    db $99                         ; $4FCA  ！
    db $FA                         ; $4FCB  wait-for-button
    db $F7                         ; $4FCC  clear page
    db $EF,$EE                     ; $4FCD  newline
    db $9F                         ; $4FCF  box tag
    db $96                         ; $4FD0  end name/box tag
    db $7D,$6A,$8D,$87,$54         ; $4FD1  メタ゛ルを = メダルを
    db $90                         ; $4FD6  　(space)
    db $47,$36,$37,$2A,$37,$2B,$51,$33,$4E; $4FD7  もってきてくれたら
    db $EF,$EE                     ; $4FE0  newline
    db $90,$90                     ; $4FE2  　　(indent)
    db $28,$2F,$8D,$2E,$55,$29,$8D ; $4FE4  おし゛さんか゛ = おじさんが
    db $90                         ; $4FEB  　(space)
    db $2D,$8D,$42,$26,$3F,$8D,$54,$2B,$51,$50,$4C; $4FEC  こ゛ほうひ゛をくれるよ = ごほうびをくれるよ
    db $99                         ; $4FF7  ！
    db $FA                         ; $4FF8  wait-for-button
    db $F7                         ; $4FF9  clear page
    db $EF,$EE                     ; $4FFA  newline
    db $9F                         ; $4FFC  box tag
    db $96                         ; $4FFD  end name/box tag
    db $33,$2B,$2E,$55             ; $4FFE  たくさん
    db $90                         ; $5002  　(space)
    db $24,$35,$46,$37,$2B,$51,$33,$4E; $5003  あつめてくれたら
    db $EF,$EE                     ; $500B  newline
    db $90,$90                     ; $500D  　　(indent)
    db $42,$8D,$2B,$47             ; $500F  ほ゛くも = ぼくも
    db $90                         ; $5013  　(space)
    db $39,$3A,$29                 ; $5014  なにか
    db $90                         ; $5017  　(space)
    db $24,$2C,$8D,$4C,$26,$29,$39 ; $5018  あけ゛ようかな = あげようかな
    db $99                         ; $501F  ！
    db $F7                         ; $5020  clear page
    db $F0                         ; $5021  end of message


; --------------------------------------------------------------------------
; Message #49 ($5022)
;   「マスターようせいじゅくへ
;   ようこそ！
;   「わたしは　ここの　じゅくちょう。
;   つよいマスターを　めざすものに、
;   「マスターとしての　こころえを
;   でんじゅしておる。
;   「きょうの　こうぎは　まものの
;   つかまえかただ。　きくかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg49:                              ; $5022  (file $10D022)
    db $EA                         ; $5022  ▶ new page
    db $9F                         ; $5023  box tag
    db $96                         ; $5024  end name/box tag
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25,$2F,$8D,$4B,$2B,$41; $5025  マスターようせいし゛ゅくへ = マスターようせいじゅくへ
    db $EF,$EE                     ; $5032  newline
    db $90,$90                     ; $5034  　　(indent)
    db $4C,$26,$2D,$32             ; $5036  ようこそ
    db $99                         ; $503A  ！
    db $FA                         ; $503B  wait-for-button
    db $F7                         ; $503C  clear page
    db $EF,$EE                     ; $503D  newline
    db $9F                         ; $503F  box tag
    db $96                         ; $5040  end name/box tag
    db $53,$33,$2F,$3E             ; $5041  わたしは
    db $90                         ; $5045  　(space)
    db $2D,$2D,$3D                 ; $5046  ここの
    db $90                         ; $5049  　(space)
    db $2F,$8D,$4B,$2B,$34,$4D,$26 ; $504A  し゛ゅくちょう = じゅくちょう
    db $8F                         ; $5051  。
    db $EF,$EE                     ; $5052  newline
    db $90,$90                     ; $5054  　　(indent)
    db $35,$4C,$25,$7A,$67,$6A,$9C,$54; $5056  つよいマスターを
    db $90                         ; $505E  　(space)
    db $46,$2E,$8D,$30,$47,$3D,$3A ; $505F  めさ゛すものに = めざすものに
    db $A4                         ; $5066  、
    db $FA                         ; $5067  wait-for-button
    db $F7                         ; $5068  clear page
    db $EF,$EE                     ; $5069  newline
    db $9F                         ; $506B  box tag
    db $96                         ; $506C  end name/box tag
    db $7A,$67,$6A,$9C,$38,$2F,$37,$3D; $506D  マスターとしての
    db $90                         ; $5075  　(space)
    db $2D,$2D,$52,$27,$54         ; $5076  こころえを
    db $EF,$EE                     ; $507B  newline
    db $90,$90                     ; $507D  　　(indent)
    db $37,$8D,$55,$2F,$8D,$4B,$2F,$37,$28,$50; $507F  て゛んし゛ゅしておる = でんじゅしておる
    db $8F                         ; $5089  。
    db $FA                         ; $508A  wait-for-button
    db $F7                         ; $508B  clear page
    db $EF,$EE                     ; $508C  newline
    db $9F                         ; $508E  box tag
    db $96                         ; $508F  end name/box tag
    db $2A,$4D,$26,$3D             ; $5090  きょうの
    db $90                         ; $5094  　(space)
    db $2D,$26,$2A,$8D,$3E         ; $5095  こうき゛は = こうぎは
    db $90                         ; $509A  　(space)
    db $43,$47,$3D,$3D             ; $509B  まものの
    db $EF,$EE                     ; $509F  newline
    db $90,$90                     ; $50A1  　　(indent)
    db $35,$29,$43,$27,$29,$33,$33,$8D; $50A3  つかまえかたた゛ = つかまえかただ
    db $8F                         ; $50AB  。
    db $90                         ; $50AC  　(space)
    db $2A,$2B,$29,$3C             ; $50AD  きくかね
    db $98                         ; $50B1  ？
    db $FF                         ; $50B2  はい/いいえ
    db $F0                         ; $50B3  end of message


; --------------------------------------------------------------------------
; Message #50 ($50B4)
;   「たおしたまものが　せんとうごに
;   なかまに　なることがあるが、
;   「にくを　あたえると　なかまになる
;   かくりつは　いっきに　あがる。
;   「あたえるにくは　ねだんが　たかい
;   もののほうが　いいぞ。
;   「ひとつで　だめなら
;   ふたつ　みっつと　あたえること。
;   「このとき　たいせつなのは　ほしい
;   まものは　さいごにたおすことだ。
;   「さいごにたおした　まもの
;   だけしか　なかまにならないのだ。
; --------------------------------------------------------------------------
Bank67_Msg50:                              ; $50B4  (file $10D0B4)
    db $EA                         ; $50B4  ▶ new page
    db $9F                         ; $50B5  box tag
    db $96                         ; $50B6  end name/box tag
    db $33,$28,$2F,$33,$43,$47,$3D,$29,$8D; $50B7  たおしたまものか゛ = たおしたまものが
    db $90                         ; $50C0  　(space)
    db $31,$55,$38,$26,$2D,$8D,$3A ; $50C1  せんとうこ゛に = せんとうごに
    db $EF,$EE                     ; $50C8  newline
    db $90,$90                     ; $50CA  　　(indent)
    db $39,$29,$43,$3A             ; $50CC  なかまに
    db $90                         ; $50D0  　(space)
    db $39,$50,$2D,$38,$29,$8D,$24,$50,$29,$8D; $50D1  なることか゛あるか゛ = なることがあるが
    db $A4                         ; $50DB  、
    db $FA                         ; $50DC  wait-for-button
    db $F7                         ; $50DD  clear page
    db $EF,$EE                     ; $50DE  newline
    db $9F                         ; $50E0  box tag
    db $96                         ; $50E1  end name/box tag
    db $3A,$2B,$54                 ; $50E2  にくを
    db $90                         ; $50E5  　(space)
    db $24,$33,$27,$50,$38         ; $50E6  あたえると
    db $90                         ; $50EB  　(space)
    db $39,$29,$43,$3A,$39,$50     ; $50EC  なかまになる
    db $EF,$EE                     ; $50F2  newline
    db $90,$90                     ; $50F4  　　(indent)
    db $29,$2B,$4F,$35,$3E         ; $50F6  かくりつは
    db $90                         ; $50FB  　(space)
    db $25,$36,$2A,$3A             ; $50FC  いっきに
    db $90                         ; $5100  　(space)
    db $24,$29,$8D,$50             ; $5101  あか゛る = あがる
    db $8F                         ; $5105  。
    db $FA                         ; $5106  wait-for-button
    db $F7                         ; $5107  clear page
    db $EF,$EE                     ; $5108  newline
    db $9F                         ; $510A  box tag
    db $96                         ; $510B  end name/box tag
    db $24,$33,$27,$50,$3A,$2B,$3E ; $510C  あたえるにくは
    db $90                         ; $5113  　(space)
    db $3C,$33,$8D,$55,$29,$8D     ; $5114  ねた゛んか゛ = ねだんが
    db $90                         ; $511A  　(space)
    db $33,$29,$25                 ; $511B  たかい
    db $EF,$EE                     ; $511E  newline
    db $90,$90                     ; $5120  　　(indent)
    db $47,$3D,$3D,$42,$26,$29,$8D ; $5122  もののほうか゛ = もののほうが
    db $90                         ; $5129  　(space)
    db $25,$25,$32,$8D             ; $512A  いいそ゛ = いいぞ
    db $8F                         ; $512E  。
    db $FA                         ; $512F  wait-for-button
    db $F7                         ; $5130  clear page
    db $EF,$EE                     ; $5131  newline
    db $9F                         ; $5133  box tag
    db $96                         ; $5134  end name/box tag
    db $3F,$38,$35,$37,$8D         ; $5135  ひとつて゛ = ひとつで
    db $90                         ; $513A  　(space)
    db $33,$8D,$46,$39,$4E         ; $513B  た゛めなら = だめなら
    db $EF,$EE                     ; $5140  newline
    db $90,$90                     ; $5142  　　(indent)
    db $40,$33,$35                 ; $5144  ふたつ
    db $90                         ; $5147  　(space)
    db $44,$36,$35,$38             ; $5148  みっつと
    db $90                         ; $514C  　(space)
    db $24,$33,$27,$50,$2D,$38     ; $514D  あたえること
    db $8F                         ; $5153  。
    db $FA                         ; $5154  wait-for-button
    db $F7                         ; $5155  clear page
    db $EF,$EE                     ; $5156  newline
    db $9F                         ; $5158  box tag
    db $96                         ; $5159  end name/box tag
    db $2D,$3D,$38,$2A             ; $515A  このとき
    db $90                         ; $515E  　(space)
    db $33,$25,$31,$35,$39,$3D,$3E ; $515F  たいせつなのは
    db $90                         ; $5166  　(space)
    db $42,$2F,$25                 ; $5167  ほしい
    db $EF,$EE                     ; $516A  newline
    db $90,$90                     ; $516C  　　(indent)
    db $43,$47,$3D,$3E             ; $516E  まものは
    db $90                         ; $5172  　(space)
    db $2E,$25,$2D,$8D,$3A,$33,$28,$30,$2D,$38,$33,$8D; $5173  さいこ゛にたおすことた゛ = さいごにたおすことだ
    db $8F                         ; $517F  。
    db $FA                         ; $5180  wait-for-button
    db $F7                         ; $5181  clear page
    db $EF,$EE                     ; $5182  newline
    db $9F                         ; $5184  box tag
    db $96                         ; $5185  end name/box tag
    db $2E,$25,$2D,$8D,$3A,$33,$28,$2F,$33; $5186  さいこ゛にたおした = さいごにたおした
    db $90                         ; $518F  　(space)
    db $43,$47,$3D                 ; $5190  まもの
    db $EF,$EE                     ; $5193  newline
    db $90,$90                     ; $5195  　　(indent)
    db $33,$8D,$2C,$2F,$29         ; $5197  た゛けしか = だけしか
    db $90                         ; $519C  　(space)
    db $39,$29,$43,$3A,$39,$4E,$39,$25,$3D,$33,$8D; $519D  なかまにならないのた゛ = なかまにならないのだ
    db $8F                         ; $51A8  。
    db $F7                         ; $51A9  clear page
    db $F0                         ; $51AA  end of message


; --------------------------------------------------------------------------
; Message #51 ($51AB)
;   「キメラのつばさはね　いつも
;   もっていったほうが　いいよ。
;   「じゅくちょうに　おそわったんだ。
;   へへ。
; --------------------------------------------------------------------------
Bank67_Msg51:                              ; $51AB  (file $10D1AB)
    db $EB                         ; $51AB  ▶ new page
    db $9F                         ; $51AC  box tag
    db $96                         ; $51AD  end name/box tag
    db $61,$7D,$85,$3D,$35,$3E,$8D,$2E,$3E,$3C; $51AE  キメラのつは゛さはね = キメラのつばさはね
    db $90                         ; $51B8  　(space)
    db $25,$35,$47                 ; $51B9  いつも
    db $EF,$EE                     ; $51BC  newline
    db $90,$90                     ; $51BE  　　(indent)
    db $47,$36,$37,$25,$36,$33,$42,$26,$29,$8D; $51C0  もっていったほうか゛ = もっていったほうが
    db $90                         ; $51CA  　(space)
    db $25,$25,$4C                 ; $51CB  いいよ
    db $8F                         ; $51CE  。
    db $FA                         ; $51CF  wait-for-button
    db $F7                         ; $51D0  clear page
    db $EF,$EE                     ; $51D1  newline
    db $9F                         ; $51D3  box tag
    db $96                         ; $51D4  end name/box tag
    db $2F,$8D,$4B,$2B,$34,$4D,$26,$3A; $51D5  し゛ゅくちょうに = じゅくちょうに
    db $90                         ; $51DD  　(space)
    db $28,$32,$53,$36,$33,$55,$33,$8D; $51DE  おそわったんた゛ = おそわったんだ
    db $8F                         ; $51E6  。
    db $EF,$EE                     ; $51E7  newline
    db $90,$90                     ; $51E9  　　(indent)
    db $41,$41                     ; $51EB  へへ
    db $8F                         ; $51ED  。
    db $F7                         ; $51EE  clear page
    db $F0                         ; $51EF  end of message


; --------------------------------------------------------------------------
; Message #52 ($51F0)
;   「ここは　モンスターマスターの
;   ようせいじゅくだよ。
; --------------------------------------------------------------------------
Bank67_Msg52:                              ; $51F0  (file $10D1F0)
    db $EA                         ; $51F0  ▶ new page
    db $9F                         ; $51F1  box tag
    db $96                         ; $51F2  end name/box tag
    db $2D,$2D,$3E                 ; $51F3  ここは
    db $90                         ; $51F6  　(space)
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$3D; $51F7  モンスターマスターの
    db $EF,$EE                     ; $5201  newline
    db $90,$90                     ; $5203  　　(indent)
    db $4C,$26,$31,$25,$2F,$8D,$4B,$2B,$33,$8D,$4C; $5205  ようせいし゛ゅくた゛よ = ようせいじゅくだよ
    db $8F                         ; $5210  。
    db $F7                         ; $5211  clear page
    db $F0                         ; $5212  end of message


; --------------------------------------------------------------------------
; Message #53 ($5213)
;   〈テリー〉は　こくばんに　かかれた
;   もじを　よんだ。
;   「モンスターマスターの　こころえ、
;   「まものは　たたかいのなかで
;   さまざまなことを　まなんでゆく。
;   「はじめは　とんでもない　こうどうや
;   いみのない　ことを　するだろう。
;   「だが　まものたちを　あたたかいめで
;   みまもってやることが　たいせつ。
;   「せいちょうし　「かしこさ[97]が
;   たかくなってゆけば、
;   「やがて　マスターよりも　てきかくな
;   こうどうを　とれるようになるのだ！
; --------------------------------------------------------------------------
Bank67_Msg53:                              ; $5213  (file $10D213)
    db $F6                         ; $5213  «insert hero name»
    db $3E                         ; $5214  は
    db $90                         ; $5215  　(space)
    db $2D,$2B,$3E,$8D,$55,$3A     ; $5216  こくは゛んに = こくばんに
    db $90                         ; $521C  　(space)
    db $29,$29,$51,$33             ; $521D  かかれた
    db $EF,$EE                     ; $5221  newline
    db $47,$2F,$8D,$54             ; $5223  もし゛を = もじを
    db $90                         ; $5227  　(space)
    db $4C,$55,$33,$8D             ; $5228  よんた゛ = よんだ
    db $8F                         ; $522C  。
    db $FA                         ; $522D  wait-for-button
    db $F7                         ; $522E  clear page
    db $EF,$EE                     ; $522F  newline
    db $96                         ; $5231  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$7A,$67,$6A,$9C,$3D; $5232  モンスターマスターの
    db $90                         ; $523C  　(space)
    db $2D,$2D,$52,$27             ; $523D  こころえ
    db $A4                         ; $5241  、
    db $EF,$EE                     ; $5242  newline
    db $FA                         ; $5244  wait-for-button
    db $F7                         ; $5245  clear page
    db $EF,$EE                     ; $5246  newline
    db $F3                         ; $5248  open text box
    db $96                         ; $5249  end name/box tag
    db $43,$47,$3D,$3E             ; $524A  まものは
    db $90                         ; $524E  　(space)
    db $33,$33,$29,$25,$3D,$39,$29,$37,$8D; $524F  たたかいのなかて゛ = たたかいのなかで
    db $EF,$EE                     ; $5258  newline
    db $90                         ; $525A  　(space)
    db $2E,$43,$2E,$8D,$43,$39,$2D,$38,$54; $525B  さまさ゛まなことを = さまざまなことを
    db $90                         ; $5264  　(space)
    db $43,$39,$55,$37,$8D,$4A,$2B ; $5265  まなんて゛ゆく = まなんでゆく
    db $8F                         ; $526C  。
    db $FA                         ; $526D  wait-for-button
    db $F7                         ; $526E  clear page
    db $EF,$EE                     ; $526F  newline
    db $96                         ; $5271  end name/box tag
    db $3E,$2F,$8D,$46,$3E         ; $5272  はし゛めは = はじめは
    db $90                         ; $5277  　(space)
    db $38,$55,$37,$8D,$47,$39,$25 ; $5278  とんて゛もない = とんでもない
    db $90                         ; $527F  　(space)
    db $2D,$26,$38,$8D,$26,$48     ; $5280  こうと゛うや = こうどうや
    db $EF,$EE                     ; $5286  newline
    db $90                         ; $5288  　(space)
    db $25,$44,$3D,$39,$25         ; $5289  いみのない
    db $90                         ; $528E  　(space)
    db $2D,$38,$54                 ; $528F  ことを
    db $90                         ; $5292  　(space)
    db $30,$50,$33,$8D,$52,$26     ; $5293  するた゛ろう = するだろう
    db $8F                         ; $5299  。
    db $FA                         ; $529A  wait-for-button
    db $F7                         ; $529B  clear page
    db $EF,$EE                     ; $529C  newline
    db $96                         ; $529E  end name/box tag
    db $33,$8D,$29,$8D             ; $529F  た゛か゛ = だが
    db $90                         ; $52A3  　(space)
    db $43,$47,$3D,$33,$34,$54     ; $52A4  まものたちを
    db $90                         ; $52AA  　(space)
    db $24,$33,$33,$29,$25,$46,$37,$8D; $52AB  あたたかいめて゛ = あたたかいめで
    db $EF,$EE                     ; $52B3  newline
    db $90                         ; $52B5  　(space)
    db $44,$43,$47,$36,$37,$48,$50,$2D,$38,$29,$8D; $52B6  みまもってやることか゛ = みまもってやることが
    db $90                         ; $52C1  　(space)
    db $33,$25,$31,$35             ; $52C2  たいせつ
    db $8F                         ; $52C6  。
    db $FA                         ; $52C7  wait-for-button
    db $F7                         ; $52C8  clear page
    db $EF,$EE                     ; $52C9  newline
    db $96                         ; $52CB  end name/box tag
    db $31,$25,$34,$4D,$26,$2F     ; $52CC  せいちょうし
    db $90                         ; $52D2  　(space)
    db $96                         ; $52D3  end name/box tag
    db $29,$2F,$2D,$2E             ; $52D4  かしこさ
    db $97                         ; $52D8  ctrl $97
    db $29,$8D                     ; $52D9  か゛ = が
    db $EF,$EE                     ; $52DB  newline
    db $90                         ; $52DD  　(space)
    db $33,$29,$2B,$39,$36,$37,$4A,$2C,$3E,$8D; $52DE  たかくなってゆけは゛ = たかくなってゆけば
    db $A4                         ; $52E8  、
    db $FA                         ; $52E9  wait-for-button
    db $F7                         ; $52EA  clear page
    db $EF,$EE                     ; $52EB  newline
    db $96                         ; $52ED  end name/box tag
    db $48,$29,$8D,$37             ; $52EE  やか゛て = やがて
    db $90                         ; $52F2  　(space)
    db $7A,$67,$6A,$9C,$4C,$4F,$47 ; $52F3  マスターよりも
    db $90                         ; $52FA  　(space)
    db $37,$2A,$29,$2B,$39         ; $52FB  てきかくな
    db $EF,$EE                     ; $5300  newline
    db $90                         ; $5302  　(space)
    db $2D,$26,$38,$8D,$26,$54     ; $5303  こうと゛うを = こうどうを
    db $90                         ; $5309  　(space)
    db $38,$51,$50,$4C,$26,$3A,$39,$50,$3D,$33,$8D; $530A  とれるようになるのた゛ = とれるようになるのだ
    db $99                         ; $5315  ！
    db $F7                         ; $5316  clear page
    db $F0                         ; $5317  end of message


; --------------------------------------------------------------------------
; Message #54 ($5318)
;   〈テリー〉は　こくばんに　かかれた
;   もじを　よんだ。
;   「マスターは　いちにちにしてならず。
;   めざせ！　ほしふりのたいかい！！
; --------------------------------------------------------------------------
Bank67_Msg54:                              ; $5318  (file $10D318)
    db $F6                         ; $5318  «insert hero name»
    db $3E                         ; $5319  は
    db $90                         ; $531A  　(space)
    db $2D,$2B,$3E,$8D,$55,$3A     ; $531B  こくは゛んに = こくばんに
    db $90                         ; $5321  　(space)
    db $29,$29,$51,$33             ; $5322  かかれた
    db $EF,$EE                     ; $5326  newline
    db $47,$2F,$8D,$54             ; $5328  もし゛を = もじを
    db $90                         ; $532C  　(space)
    db $4C,$55,$33,$8D             ; $532D  よんた゛ = よんだ
    db $8F                         ; $5331  。
    db $FA                         ; $5332  wait-for-button
    db $F7                         ; $5333  clear page
    db $EF,$EE                     ; $5334  newline
    db $96                         ; $5336  end name/box tag
    db $7A,$67,$6A,$9C,$3E         ; $5337  マスターは
    db $90                         ; $533C  　(space)
    db $25,$34,$3A,$34,$3A,$2F,$37,$39,$4E,$30,$8D; $533D  いちにちにしてならす゛ = いちにちにしてならず
    db $8F                         ; $5348  。
    db $EF,$EE                     ; $5349  newline
    db $90                         ; $534B  　(space)
    db $46,$2E,$8D,$31             ; $534C  めさ゛せ = めざせ
    db $99                         ; $5350  ！
    db $90                         ; $5351  　(space)
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25; $5352  ほしふりのたいかい
    db $99                         ; $535B  ！
    db $99                         ; $535C  ！
    db $F7                         ; $535D  clear page
    db $F0                         ; $535E  end of message


; --------------------------------------------------------------------------
; Message #55 ($535F)
;   「ゆうしゅうな　マスターたちを
;   みていて　おもうのですが、
;   「つれあるいている　まものの
;   バランスが　とてもいいですな。
;   「かいふくを　うけもつ　まもの。
;   こうげきしゅたいの　まものと、
;   「パーテイーないでの　やくわり
;   ぶんたんが　よくできています。
; --------------------------------------------------------------------------
Bank67_Msg55:                              ; $535F  (file $10D35F)
    db $EA                         ; $535F  ▶ new page
    db $9F                         ; $5360  box tag
    db $96                         ; $5361  end name/box tag
    db $4A,$26,$2F,$4B,$26,$39     ; $5362  ゆうしゅうな
    db $90                         ; $5368  　(space)
    db $7A,$67,$6A,$9C,$33,$34,$54 ; $5369  マスターたちを
    db $EF,$EE                     ; $5370  newline
    db $90,$90                     ; $5372  　　(indent)
    db $44,$37,$25,$37             ; $5374  みていて
    db $90                         ; $5378  　(space)
    db $28,$47,$26,$3D,$37,$8D,$30,$29,$8D; $5379  おもうのて゛すか゛ = おもうのですが
    db $A4                         ; $5382  、
    db $FA                         ; $5383  wait-for-button
    db $F7                         ; $5384  clear page
    db $EF,$EE                     ; $5385  newline
    db $9F                         ; $5387  box tag
    db $96                         ; $5388  end name/box tag
    db $35,$51,$24,$50,$25,$37,$25,$50; $5389  つれあるいている
    db $90                         ; $5391  　(space)
    db $43,$47,$3D,$3D             ; $5392  まものの
    db $EF,$EE                     ; $5396  newline
    db $90,$90                     ; $5398  　　(indent)
    db $75,$8D,$85,$8C,$67,$29,$8D ; $539A  ハ゛ランスか゛ = バランスが
    db $90                         ; $53A1  　(space)
    db $38,$37,$47,$25,$25,$37,$8D,$30,$39; $53A2  とてもいいて゛すな = とてもいいですな
    db $8F                         ; $53AB  。
    db $FA                         ; $53AC  wait-for-button
    db $F7                         ; $53AD  clear page
    db $EF,$EE                     ; $53AE  newline
    db $9F                         ; $53B0  box tag
    db $96                         ; $53B1  end name/box tag
    db $29,$25,$40,$2B,$54         ; $53B2  かいふくを
    db $90                         ; $53B7  　(space)
    db $26,$2C,$47,$35             ; $53B8  うけもつ
    db $90                         ; $53BC  　(space)
    db $43,$47,$3D                 ; $53BD  まもの
    db $8F                         ; $53C0  。
    db $EF,$EE                     ; $53C1  newline
    db $90,$90                     ; $53C3  　　(indent)
    db $2D,$26,$2C,$8D,$2A,$2F,$4B,$33,$25,$3D; $53C5  こうけ゛きしゅたいの = こうげきしゅたいの
    db $90                         ; $53CF  　(space)
    db $43,$47,$3D,$38             ; $53D0  まものと
    db $A4                         ; $53D4  、
    db $FA                         ; $53D5  wait-for-button
    db $F7                         ; $53D6  clear page
    db $EF,$EE                     ; $53D7  newline
    db $9F                         ; $53D9  box tag
    db $96                         ; $53DA  end name/box tag
    db $75,$8E,$9C,$6E,$59,$9C,$39,$25,$37,$8D,$3D; $53DB  ハ゜ーテイーないて゛の = パーテイーないでの
    db $90                         ; $53E6  　(space)
    db $48,$2B,$53,$4F             ; $53E7  やくわり
    db $EF,$EE                     ; $53EB  newline
    db $90,$90                     ; $53ED  　　(indent)
    db $40,$8D,$55,$33,$55,$29,$8D ; $53EF  ふ゛んたんか゛ = ぶんたんが
    db $90                         ; $53F6  　(space)
    db $4C,$2B,$37,$8D,$2A,$37,$25,$43,$30; $53F7  よくて゛きています = よくできています
    db $8F                         ; $5400  。
    db $F7                         ; $5401  clear page
    db $F0                         ; $5402  end of message


; --------------------------------------------------------------------------
; Message #56 ($5403)
;   「ぐんたい　ばくだん　ぐんたい
;   バブル　ぐんたい、。　ヒック。
;   「う[92]ー。おうひさまに　あいて[94]。
;   ぐんたい　ばくだん　ぐんたい、。
; --------------------------------------------------------------------------
Bank67_Msg56:                              ; $5403  (file $10D403)
    db $EA                         ; $5403  ▶ new page
    db $9F                         ; $5404  box tag
    db $96                         ; $5405  end name/box tag
    db $2B,$8D,$55,$33,$25         ; $5406  く゛んたい = ぐんたい
    db $90                         ; $540B  　(space)
    db $3E,$8D,$2B,$33,$8D,$55     ; $540C  は゛くた゛ん = ばくだん
    db $90                         ; $5412  　(space)
    db $2B,$8D,$55,$33,$25         ; $5413  く゛んたい = ぐんたい
    db $EF,$EE                     ; $5418  newline
    db $90,$90                     ; $541A  　　(indent)
    db $75,$8D,$77,$8D,$87         ; $541C  ハ゛フ゛ル = バブル
    db $90                         ; $5421  　(space)
    db $2B,$8D,$55,$33,$25         ; $5422  く゛んたい = ぐんたい
    db $A4                         ; $5427  、
    db $8F                         ; $5428  。
    db $90                         ; $5429  　(space)
    db $76,$6D,$62                 ; $542A  ヒック
    db $8F                         ; $542D  。
    db $FA                         ; $542E  wait-for-button
    db $F7                         ; $542F  clear page
    db $EF,$EE                     ; $5430  newline
    db $9F                         ; $5432  box tag
    db $96                         ; $5433  end name/box tag
    db $26                         ; $5434  う
    db $92                         ; $5435  small kana
    db $9C                         ; $5436  ー
    db $8F                         ; $5437  。
    db $28,$26,$3F,$2E,$43,$3A     ; $5438  おうひさまに
    db $90                         ; $543E  　(space)
    db $24,$25,$37                 ; $543F  あいて
    db $94                         ; $5442  small kana
    db $8F                         ; $5443  。
    db $EF,$EE                     ; $5444  newline
    db $90,$90                     ; $5446  　　(indent)
    db $2B,$8D,$55,$33,$25         ; $5448  く゛んたい = ぐんたい
    db $90                         ; $544D  　(space)
    db $3E,$8D,$2B,$33,$8D,$55     ; $544E  は゛くた゛ん = ばくだん
    db $90                         ; $5454  　(space)
    db $2B,$8D,$55,$33,$25         ; $5455  く゛んたい = ぐんたい
    db $A4                         ; $545A  、
    db $8F                         ; $545B  。
    db $F7                         ; $545C  clear page
    db $F0                         ; $545D  end of message


; --------------------------------------------------------------------------
; Message #57 ($545E)
;   「なんじゃい　うけつけで
;   ふんぞりかえっとる　あのばばあ。
;   「としがいもなく　バニーガールの
;   かっこうなんか　しやがって！
; --------------------------------------------------------------------------
Bank67_Msg57:                              ; $545E  (file $10D45E)
    db $EA                         ; $545E  ▶ new page
    db $9F                         ; $545F  box tag
    db $96                         ; $5460  end name/box tag
    db $39,$55,$2F,$8D,$49,$25     ; $5461  なんし゛ゃい = なんじゃい
    db $90                         ; $5467  　(space)
    db $26,$2C,$35,$2C,$37,$8D     ; $5468  うけつけて゛ = うけつけで
    db $EF,$EE                     ; $546E  newline
    db $90,$90                     ; $5470  　　(indent)
    db $40,$55,$32,$8D,$4F,$29,$27,$36,$38,$50; $5472  ふんそ゛りかえっとる = ふんぞりかえっとる
    db $90                         ; $547C  　(space)
    db $24,$3D,$3E,$8D,$3E,$8D,$24 ; $547D  あのは゛は゛あ = あのばばあ
    db $8F                         ; $5484  。
    db $FA                         ; $5485  wait-for-button
    db $F7                         ; $5486  clear page
    db $EF,$EE                     ; $5487  newline
    db $9F                         ; $5489  box tag
    db $96                         ; $548A  end name/box tag
    db $38,$2F,$29,$8D,$25,$47,$39,$2B; $548B  としか゛いもなく = としがいもなく
    db $90                         ; $5493  　(space)
    db $75,$8D,$71,$9C,$60,$8D,$9C,$87,$3D; $5494  ハ゛ニーカ゛ールの = バニーガールの
    db $EF,$EE                     ; $549D  newline
    db $90,$90                     ; $549F  　　(indent)
    db $29,$36,$2D,$26,$39,$55,$29 ; $54A1  かっこうなんか
    db $90                         ; $54A8  　(space)
    db $2F,$48,$29,$8D,$36,$37     ; $54A9  しやか゛って = しやがって
    db $99                         ; $54AF  ！
    db $F7                         ; $54B0  clear page
    db $F0                         ; $54B1  end of message


; --------------------------------------------------------------------------
; Message #58 ($54B2)
;   「わらわが　かくとうずきの
;   タィジャこく　おうひです。
;   「、そなたは　どうやら　ほしふりの
;   ほこらに　いまだいっておらぬな。
;   「でなおすがよい。　わらわは
;   よわきものに　きょうみはない。
; --------------------------------------------------------------------------
Bank67_Msg58:                              ; $54B2  (file $10D4B2)
    db $EB                         ; $54B2  ▶ new page
    db $9F                         ; $54B3  box tag
    db $96                         ; $54B4  end name/box tag
    db $53,$4E,$53,$29,$8D         ; $54B5  わらわか゛ = わらわが
    db $90                         ; $54BA  　(space)
    db $29,$2B,$38,$26,$30,$8D,$2A,$3D; $54BB  かくとうす゛きの = かくとうずきの
    db $EF,$EE                     ; $54C3  newline
    db $90,$90                     ; $54C5  　　(indent)
    db $6A,$58,$66,$8D,$82,$2D,$2B ; $54C7  タィシ゛ャこく = タィジャこく
    db $90                         ; $54CE  　(space)
    db $28,$26,$3F,$37,$8D,$30     ; $54CF  おうひて゛す = おうひです
    db $8F                         ; $54D5  。
    db $FA                         ; $54D6  wait-for-button
    db $F7                         ; $54D7  clear page
    db $EF,$EE                     ; $54D8  newline
    db $9F                         ; $54DA  box tag
    db $96                         ; $54DB  end name/box tag
    db $A4                         ; $54DC  、
    db $32,$39,$33,$3E             ; $54DD  そなたは
    db $90                         ; $54E1  　(space)
    db $38,$8D,$26,$48,$4E         ; $54E2  と゛うやら = どうやら
    db $90                         ; $54E7  　(space)
    db $42,$2F,$40,$4F,$3D         ; $54E8  ほしふりの
    db $EF,$EE                     ; $54ED  newline
    db $90,$90                     ; $54EF  　　(indent)
    db $42,$2D,$4E,$3A             ; $54F1  ほこらに
    db $90                         ; $54F5  　(space)
    db $25,$43,$33,$8D,$25,$36,$37,$28,$4E,$3B,$39; $54F6  いまた゛いっておらぬな = いまだいっておらぬな
    db $8F                         ; $5501  。
    db $FA                         ; $5502  wait-for-button
    db $F7                         ; $5503  clear page
    db $EF,$EE                     ; $5504  newline
    db $9F                         ; $5506  box tag
    db $96                         ; $5507  end name/box tag
    db $37,$8D,$39,$28,$30,$29,$8D,$4C,$25; $5508  て゛なおすか゛よい = でなおすがよい
    db $8F                         ; $5511  。
    db $90                         ; $5512  　(space)
    db $53,$4E,$53,$3E             ; $5513  わらわは
    db $EF,$EE                     ; $5517  newline
    db $90,$90                     ; $5519  　　(indent)
    db $4C,$53,$2A,$47,$3D,$3A     ; $551B  よわきものに
    db $90                         ; $5521  　(space)
    db $2A,$4D,$26,$44,$3E,$39,$25 ; $5522  きょうみはない
    db $8F                         ; $5529  。
    db $F7                         ; $552A  clear page
    db $F0                         ; $552B  end of message


; --------------------------------------------------------------------------
; Message #59 ($552C)
;   「ここに　おわすのが　タィジャの
;   くにの　おうひさまです。
;   「そして　おうひさまに　まねかれた
;   きゃくじん　ミッキーさまです。
;   「モンスターじいさんと　あったのち
;   ふたたび　ここにおこしください。
; --------------------------------------------------------------------------
Bank67_Msg59:                              ; $552C  (file $10D52C)
    db $EA                         ; $552C  ▶ new page
    db $9F                         ; $552D  box tag
    db $96                         ; $552E  end name/box tag
    db $2D,$2D,$3A                 ; $552F  ここに
    db $90                         ; $5532  　(space)
    db $28,$53,$30,$3D,$29,$8D     ; $5533  おわすのか゛ = おわすのが
    db $90                         ; $5539  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $553A  タィシ゛ャの = タィジャの
    db $EF,$EE                     ; $5540  newline
    db $90,$90                     ; $5542  　　(indent)
    db $2B,$3A,$3D                 ; $5544  くにの
    db $90                         ; $5547  　(space)
    db $28,$26,$3F,$2E,$43,$37,$8D,$30; $5548  おうひさまて゛す = おうひさまです
    db $8F                         ; $5550  。
    db $FA                         ; $5551  wait-for-button
    db $F7                         ; $5552  clear page
    db $EF,$EE                     ; $5553  newline
    db $9F                         ; $5555  box tag
    db $96                         ; $5556  end name/box tag
    db $32,$2F,$37                 ; $5557  そして
    db $90                         ; $555A  　(space)
    db $28,$26,$3F,$2E,$43,$3A     ; $555B  おうひさまに
    db $90                         ; $5561  　(space)
    db $43,$3C,$29,$51,$33         ; $5562  まねかれた
    db $EF,$EE                     ; $5567  newline
    db $90,$90                     ; $5569  　　(indent)
    db $2A,$49,$2B,$2F,$8D,$55     ; $556B  きゃくし゛ん = きゃくじん
    db $90                         ; $5571  　(space)
    db $7B,$6D,$61,$9C,$2E,$43,$37,$8D,$30; $5572  ミッキーさまて゛す = ミッキーさまです
    db $8F                         ; $557B  。
    db $FA                         ; $557C  wait-for-button
    db $F7                         ; $557D  clear page
    db $EF,$EE                     ; $557E  newline
    db $9F                         ; $5580  box tag
    db $96                         ; $5581  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55,$38; $5582  モンスターし゛いさんと = モンスターじいさんと
    db $90                         ; $558D  　(space)
    db $24,$36,$33,$3D,$34         ; $558E  あったのち
    db $EF,$EE                     ; $5593  newline
    db $90,$90                     ; $5595  　　(indent)
    db $40,$33,$33,$3F,$8D         ; $5597  ふたたひ゛ = ふたたび
    db $90                         ; $559C  　(space)
    db $2D,$2D,$3A,$28,$2D,$2F,$2B,$33,$8D,$2E,$25; $559D  ここにおこしくた゛さい = ここにおこしください
    db $8F                         ; $55A8  。
    db $F7                         ; $55A9  clear page
    db $F0                         ; $55AA  end of message


; --------------------------------------------------------------------------
; Message #60 ($55AB)
;   「ぼくは　ミッキー。
;   きみは　だれだい？
;   「まったく　ファンが　うるさくて
;   こまっているんだよ。
;   「きみは　まだ　しんまいだね。
;   「もうすこし　さきのクラスを
;   クリアしない　ことには、
;   「ほしふりのほこらを
;   みることも　できないだろう。
;   「まっ　がんばることだね。
; --------------------------------------------------------------------------
Bank67_Msg60:                              ; $55AB  (file $10D5AB)
    db $EA                         ; $55AB  ▶ new page
    db $9F                         ; $55AC  box tag
    db $96                         ; $55AD  end name/box tag
    db $42,$8D,$2B,$3E             ; $55AE  ほ゛くは = ぼくは
    db $90                         ; $55B2  　(space)
    db $7B,$6D,$61,$9C             ; $55B3  ミッキー
    db $8F                         ; $55B7  。
    db $EF,$EE                     ; $55B8  newline
    db $90,$90                     ; $55BA  　　(indent)
    db $2A,$44,$3E                 ; $55BC  きみは
    db $90                         ; $55BF  　(space)
    db $33,$8D,$51,$33,$8D,$25     ; $55C0  た゛れた゛い = だれだい
    db $98                         ; $55C6  ？
    db $FA                         ; $55C7  wait-for-button
    db $F7                         ; $55C8  clear page
    db $EF,$EE                     ; $55C9  newline
    db $9F                         ; $55CB  box tag
    db $96                         ; $55CC  end name/box tag
    db $43,$36,$33,$2B             ; $55CD  まったく
    db $90                         ; $55D1  　(space)
    db $77,$57,$8C,$29,$8D         ; $55D2  ファンか゛ = ファンが
    db $90                         ; $55D7  　(space)
    db $26,$50,$2E,$2B,$37         ; $55D8  うるさくて
    db $EF,$EE                     ; $55DD  newline
    db $90,$90                     ; $55DF  　　(indent)
    db $2D,$43,$36,$37,$25,$50,$55,$33,$8D,$4C; $55E1  こまっているんた゛よ = こまっているんだよ
    db $8F                         ; $55EB  。
    db $FA                         ; $55EC  wait-for-button
    db $F7                         ; $55ED  clear page
    db $EF,$EE                     ; $55EE  newline
    db $9F                         ; $55F0  box tag
    db $96                         ; $55F1  end name/box tag
    db $2A,$44,$3E                 ; $55F2  きみは
    db $90                         ; $55F5  　(space)
    db $43,$33,$8D                 ; $55F6  また゛ = まだ
    db $90                         ; $55F9  　(space)
    db $2F,$55,$43,$25,$33,$8D,$3C ; $55FA  しんまいた゛ね = しんまいだね
    db $8F                         ; $5601  。
    db $EF,$EE                     ; $5602  newline
    db $FA                         ; $5604  wait-for-button
    db $F7                         ; $5605  clear page
    db $EF,$EE                     ; $5606  newline
    db $F3                         ; $5608  open text box
    db $9F                         ; $5609  box tag
    db $96                         ; $560A  end name/box tag
    db $47,$26,$30,$2D,$2F         ; $560B  もうすこし
    db $90                         ; $5610  　(space)
    db $2E,$2A,$3D,$62,$85,$67,$54 ; $5611  さきのクラスを
    db $EF,$EE                     ; $5618  newline
    db $90,$90                     ; $561A  　　(indent)
    db $62,$86,$56,$2F,$39,$25     ; $561C  クリアしない
    db $90                         ; $5622  　(space)
    db $2D,$38,$3A,$3E             ; $5623  ことには
    db $A4                         ; $5627  、
    db $FA                         ; $5628  wait-for-button
    db $F7                         ; $5629  clear page
    db $EF,$EE                     ; $562A  newline
    db $9F                         ; $562C  box tag
    db $96                         ; $562D  end name/box tag
    db $42,$2F,$40,$4F,$3D,$42,$2D,$4E,$54; $562E  ほしふりのほこらを
    db $EF,$EE                     ; $5637  newline
    db $90,$90                     ; $5639  　　(indent)
    db $44,$50,$2D,$38,$47         ; $563B  みることも
    db $90                         ; $5640  　(space)
    db $37,$8D,$2A,$39,$25,$33,$8D,$52,$26; $5641  て゛きないた゛ろう = できないだろう
    db $8F                         ; $564A  。
    db $FA                         ; $564B  wait-for-button
    db $F7                         ; $564C  clear page
    db $EF,$EE                     ; $564D  newline
    db $9F                         ; $564F  box tag
    db $96                         ; $5650  end name/box tag
    db $43,$36                     ; $5651  まっ
    db $90                         ; $5653  　(space)
    db $29,$8D,$55,$3E,$8D,$50,$2D,$38,$33,$8D,$3C; $5654  か゛んは゛ることた゛ね = がんばることだね
    db $8F                         ; $565F  。
    db $EF,$EE                     ; $5660  newline
    db $F7                         ; $5662  clear page
    db $F0                         ; $5663  end of message


; --------------------------------------------------------------------------
; Message #61 ($5664)
;   「ここは　たびだちのへやです。
;   「このおくにある　たびのとびらが
;   たびだちのとびらです。
; --------------------------------------------------------------------------
Bank67_Msg61:                              ; $5664  (file $10D664)
    db $EA                         ; $5664  ▶ new page
    db $9F                         ; $5665  box tag
    db $96                         ; $5666  end name/box tag
    db $2D,$2D,$3E                 ; $5667  ここは
    db $90                         ; $566A  　(space)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$41,$48,$37,$8D,$30; $566B  たひ゛た゛ちのへやて゛す = たびだちのへやです
    db $8F                         ; $5677  。
    db $EF,$EE                     ; $5678  newline
    db $FA                         ; $567A  wait-for-button
    db $F7                         ; $567B  clear page
    db $EF,$EE                     ; $567C  newline
    db $F3                         ; $567E  open text box
    db $9F                         ; $567F  box tag
    db $96                         ; $5680  end name/box tag
    db $2D,$3D,$28,$2B,$3A,$24,$50 ; $5681  このおくにある
    db $90                         ; $5688  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $5689  たひ゛のとひ゛らか゛ = たびのとびらが
    db $EF,$EE                     ; $5693  newline
    db $90,$90                     ; $5695  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$38,$3F,$8D,$4E,$37,$8D,$30; $5697  たひ゛た゛ちのとひ゛らて゛す = たびだちのとびらです
    db $8F                         ; $56A5  。
    db $F7                         ; $56A6  clear page
    db $F0                         ; $56A7  end of message


; --------------------------------------------------------------------------
; Message #62 ($56A8)
;   「ごらいじょうの　みなさん！
;   かくとうじょうへ　ようこそ！！
;   「あらたな　ちょうせんしゃが
;   あらわれました！
;   「そのなは　〈テリー〉！　みなさん
;   おうえんを　おねがいします！
;   「では　だい[01]しあいを
;   かいしします。
; --------------------------------------------------------------------------
Bank67_Msg62:                              ; $56A8  (file $10D6A8)
    db $EB                         ; $56A8  ▶ new page
    db $9F                         ; $56A9  box tag
    db $96                         ; $56AA  end name/box tag
    db $2D,$8D,$4E,$25,$2F,$8D,$4D,$26,$3D; $56AB  こ゛らいし゛ょうの = ごらいじょうの
    db $90                         ; $56B4  　(space)
    db $44,$39,$2E,$55             ; $56B5  みなさん
    db $99                         ; $56B9  ！
    db $EF,$EE                     ; $56BA  newline
    db $90,$90                     ; $56BC  　　(indent)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$41; $56BE  かくとうし゛ょうへ = かくとうじょうへ
    db $90                         ; $56C7  　(space)
    db $4C,$26,$2D,$32             ; $56C8  ようこそ
    db $99                         ; $56CC  ！
    db $99                         ; $56CD  ！
    db $FA                         ; $56CE  wait-for-button
    db $F7                         ; $56CF  clear page
    db $EF,$EE                     ; $56D0  newline
    db $9F                         ; $56D2  box tag
    db $96                         ; $56D3  end name/box tag
    db $24,$4E,$33,$39             ; $56D4  あらたな
    db $90                         ; $56D8  　(space)
    db $34,$4D,$26,$31,$55,$2F,$49,$29,$8D; $56D9  ちょうせんしゃか゛ = ちょうせんしゃが
    db $EF,$EE                     ; $56E2  newline
    db $90,$90                     ; $56E4  　　(indent)
    db $24,$4E,$53,$51,$43,$2F,$33 ; $56E6  あらわれました
    db $99                         ; $56ED  ！
    db $FA                         ; $56EE  wait-for-button
    db $F7                         ; $56EF  clear page
    db $EF,$EE                     ; $56F0  newline
    db $9F                         ; $56F2  box tag
    db $96                         ; $56F3  end name/box tag
    db $32,$3D,$39,$3E             ; $56F4  そのなは
    db $90                         ; $56F8  　(space)
    db $F6                         ; $56F9  «insert hero name»
    db $99                         ; $56FA  ！
    db $90                         ; $56FB  　(space)
    db $44,$39,$2E,$55             ; $56FC  みなさん
    db $EF,$EE                     ; $5700  newline
    db $90,$90                     ; $5702  　　(indent)
    db $28,$26,$27,$55,$54         ; $5704  おうえんを
    db $90                         ; $5709  　(space)
    db $28,$3C,$29,$8D,$25,$2F,$43,$30; $570A  おねか゛いします = おねがいします
    db $99                         ; $5712  ！
    db $FA                         ; $5713  wait-for-button
    db $F7                         ; $5714  clear page
    db $EF,$EE                     ; $5715  newline
    db $9F                         ; $5717  box tag
    db $96                         ; $5718  end name/box tag
    db $37,$8D,$3E                 ; $5719  て゛は = では
    db $90                         ; $571C  　(space)
    db $33,$8D,$25                 ; $571D  た゛い = だい
    db $01                         ; $5720  ctrl $01
    db $2F,$24,$25,$54             ; $5721  しあいを
    db $EF,$EE                     ; $5725  newline
    db $90,$90                     ; $5727  　　(indent)
    db $29,$25,$2F,$2F,$43,$30     ; $5729  かいしします
    db $8F                         ; $572F  。
    db $F7                         ; $5730  clear page
    db $F0                         ; $5731  end of message


; --------------------------------------------------------------------------
; Message #63 ($5732)
;   「しあい　かいし！！
; --------------------------------------------------------------------------
Bank67_Msg63:                              ; $5732  (file $10D732)
    db $EB                         ; $5732  ▶ new page
    db $9F                         ; $5733  box tag
    db $96                         ; $5734  end name/box tag
    db $2F,$24,$25                 ; $5735  しあい
    db $90                         ; $5738  　(space)
    db $29,$25,$2F                 ; $5739  かいし
    db $99                         ; $573C  ！
    db $99                         ; $573D  ！
    db $EF,$EE                     ; $573E  newline
    db $F7                         ; $5740  clear page
    db $F0                         ; $5741  end of message


; --------------------------------------------------------------------------
; Message #64 ($5742)
;   「だい[01]しあいは　ちょうせんしゃの
;   しょうりです！
;   「では　つづいて　だい[02]しあいを
;   かいしします。
; --------------------------------------------------------------------------
Bank67_Msg64:                              ; $5742  (file $10D742)
    db $EB                         ; $5742  ▶ new page
    db $9F                         ; $5743  box tag
    db $96                         ; $5744  end name/box tag
    db $33,$8D,$25                 ; $5745  た゛い = だい
    db $01                         ; $5748  ctrl $01
    db $2F,$24,$25,$3E             ; $5749  しあいは
    db $90                         ; $574D  　(space)
    db $34,$4D,$26,$31,$55,$2F,$49,$3D; $574E  ちょうせんしゃの
    db $EF,$EE                     ; $5756  newline
    db $90,$90                     ; $5758  　　(indent)
    db $2F,$4D,$26,$4F,$37,$8D,$30 ; $575A  しょうりて゛す = しょうりです
    db $99                         ; $5761  ！
    db $FA                         ; $5762  wait-for-button
    db $F7                         ; $5763  clear page
    db $EF,$EE                     ; $5764  newline
    db $9F                         ; $5766  box tag
    db $96                         ; $5767  end name/box tag
    db $37,$8D,$3E                 ; $5768  て゛は = では
    db $90                         ; $576B  　(space)
    db $35,$35,$8D,$25,$37         ; $576C  つつ゛いて = つづいて
    db $90                         ; $5771  　(space)
    db $33,$8D,$25                 ; $5772  た゛い = だい
    db $02                         ; $5775  ctrl $02
    db $2F,$24,$25,$54             ; $5776  しあいを
    db $EF,$EE                     ; $577A  newline
    db $90,$90                     ; $577C  　　(indent)
    db $29,$25,$2F,$2F,$43,$30     ; $577E  かいしします
    db $8F                         ; $5784  。
    db $F7                         ; $5785  clear page
    db $F0                         ; $5786  end of message


; --------------------------------------------------------------------------
; Message #65 ($5787)
;   わたほ゛う「がんばっているな！
;   それじゃ　かえろうか！
; --------------------------------------------------------------------------
Bank67_Msg65:                              ; $5787  (file $10D787)
    db $EB                         ; $5787  ▶ new page
    db $53,$33,$42,$8D,$26         ; $5788  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $578D  end name/box tag
    db $29,$8D,$55,$3E,$8D,$36,$37,$25,$50,$39; $578E  か゛んは゛っているな = がんばっているな
    db $99                         ; $5798  ！
    db $EF,$EE                     ; $5799  newline
    db $90,$90                     ; $579B  　　(indent)
    db $32,$51,$2F,$8D,$49         ; $579D  それし゛ゃ = それじゃ
    db $90                         ; $57A2  　(space)
    db $29,$27,$52,$26,$29         ; $57A3  かえろうか
    db $99                         ; $57A8  ！
    db $F7                         ; $57A9  clear page
    db $F0                         ; $57AA  end of message


; --------------------------------------------------------------------------
; Message #66 ($57AB)
;   「だい[02]しあいも　ちょうせんしゃの
;   しょうりです！
;   「では　つづいて　だい[03]しあいを
;   かいし　しましょう。
; --------------------------------------------------------------------------
Bank67_Msg66:                              ; $57AB  (file $10D7AB)
    db $EB                         ; $57AB  ▶ new page
    db $9F                         ; $57AC  box tag
    db $96                         ; $57AD  end name/box tag
    db $33,$8D,$25                 ; $57AE  た゛い = だい
    db $02                         ; $57B1  ctrl $02
    db $2F,$24,$25,$47             ; $57B2  しあいも
    db $90                         ; $57B6  　(space)
    db $34,$4D,$26,$31,$55,$2F,$49,$3D; $57B7  ちょうせんしゃの
    db $EF,$EE                     ; $57BF  newline
    db $90,$90                     ; $57C1  　　(indent)
    db $2F,$4D,$26,$4F,$37,$8D,$30 ; $57C3  しょうりて゛す = しょうりです
    db $99                         ; $57CA  ！
    db $FA                         ; $57CB  wait-for-button
    db $F7                         ; $57CC  clear page
    db $EF,$EE                     ; $57CD  newline
    db $9F                         ; $57CF  box tag
    db $96                         ; $57D0  end name/box tag
    db $37,$8D,$3E                 ; $57D1  て゛は = では
    db $90                         ; $57D4  　(space)
    db $35,$35,$8D,$25,$37         ; $57D5  つつ゛いて = つづいて
    db $90                         ; $57DA  　(space)
    db $33,$8D,$25                 ; $57DB  た゛い = だい
    db $03                         ; $57DE  ctrl $03
    db $2F,$24,$25,$54             ; $57DF  しあいを
    db $EF,$EE                     ; $57E3  newline
    db $90,$90                     ; $57E5  　　(indent)
    db $29,$25,$2F                 ; $57E7  かいし
    db $90                         ; $57EA  　(space)
    db $2F,$43,$2F,$4D,$26         ; $57EB  しましょう
    db $8F                         ; $57F0  。
    db $FA                         ; $57F1  wait-for-button
    db $F7                         ; $57F2  clear page
    db $F0                         ; $57F3  end of message


; --------------------------------------------------------------------------
; Message #67 ($57F4)
;   「わたしこそは　マスターようせい
;   じゅくの　じゅくちょうである！
;   「わたしに　かつことができれば
;   [10]クラスは　きみのものだ！
;   「さあ！　きみの　じつりょくのほど
;   みせてもらおう！！
; --------------------------------------------------------------------------
Bank67_Msg67:                              ; $57F4  (file $10D7F4)
    db $EA                         ; $57F4  ▶ new page
    db $9F                         ; $57F5  box tag
    db $96                         ; $57F6  end name/box tag
    db $53,$33,$2F,$2D,$32,$3E     ; $57F7  わたしこそは
    db $90                         ; $57FD  　(space)
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25; $57FE  マスターようせい
    db $EF,$EE                     ; $5806  newline
    db $90,$90                     ; $5808  　　(indent)
    db $2F,$8D,$4B,$2B,$3D         ; $580A  し゛ゅくの = じゅくの
    db $90                         ; $580F  　(space)
    db $2F,$8D,$4B,$2B,$34,$4D,$26,$37,$8D,$24,$50; $5810  し゛ゅくちょうて゛ある = じゅくちょうである
    db $99                         ; $581B  ！
    db $FA                         ; $581C  wait-for-button
    db $F7                         ; $581D  clear page
    db $EF,$EE                     ; $581E  newline
    db $9F                         ; $5820  box tag
    db $96                         ; $5821  end name/box tag
    db $53,$33,$2F,$3A             ; $5822  わたしに
    db $90                         ; $5826  　(space)
    db $29,$35,$2D,$38,$29,$8D,$37,$8D,$2A,$51,$3E,$8D; $5827  かつことか゛て゛きれは゛ = かつことができれば
    db $EF,$EE                     ; $5833  newline
    db $90,$90                     ; $5835  　　(indent)
    db $10                         ; $5837  ctrl $10
    db $62,$85,$67,$3E             ; $5838  クラスは
    db $90                         ; $583C  　(space)
    db $2A,$44,$3D,$47,$3D,$33,$8D ; $583D  きみのものた゛ = きみのものだ
    db $99                         ; $5844  ！
    db $FA                         ; $5845  wait-for-button
    db $F7                         ; $5846  clear page
    db $EF,$EE                     ; $5847  newline
    db $9F                         ; $5849  box tag
    db $96                         ; $584A  end name/box tag
    db $2E,$24                     ; $584B  さあ
    db $99                         ; $584D  ！
    db $90                         ; $584E  　(space)
    db $2A,$44,$3D                 ; $584F  きみの
    db $90                         ; $5852  　(space)
    db $2F,$8D,$35,$4F,$4D,$2B,$3D,$42,$38,$8D; $5853  し゛つりょくのほと゛ = じつりょくのほど
    db $EF,$EE                     ; $585D  newline
    db $90,$90                     ; $585F  　　(indent)
    db $44,$31,$37,$47,$4E,$28,$26 ; $5861  みせてもらおう
    db $99                         ; $5868  ！
    db $99                         ; $5869  ！
    db $F7                         ; $586A  clear page
    db $F0                         ; $586B  end of message


; --------------------------------------------------------------------------
; Message #68 ($586C)
;   「おめでとう！　あらたなゆうしゃの
;   たんじょうだ！！
;   「マスター〈テリー〉に　どうぞ
;   あたたかい　はくしゅを！
; --------------------------------------------------------------------------
Bank67_Msg68:                              ; $586C  (file $10D86C)
    db $EB                         ; $586C  ▶ new page
    db $9F                         ; $586D  box tag
    db $96                         ; $586E  end name/box tag
    db $28,$46,$37,$8D,$38,$26     ; $586F  おめて゛とう = おめでとう
    db $99                         ; $5875  ！
    db $90                         ; $5876  　(space)
    db $24,$4E,$33,$39,$4A,$26,$2F,$49,$3D; $5877  あらたなゆうしゃの
    db $EF,$EE                     ; $5880  newline
    db $90,$90                     ; $5882  　　(indent)
    db $33,$55,$2F,$8D,$4D,$26,$33,$8D; $5884  たんし゛ょうた゛ = たんじょうだ
    db $99                         ; $588C  ！
    db $99                         ; $588D  ！
    db $FA                         ; $588E  wait-for-button
    db $F7                         ; $588F  clear page
    db $EF,$EE                     ; $5890  newline
    db $9F                         ; $5892  box tag
    db $96                         ; $5893  end name/box tag
    db $7A,$67,$6A,$9C             ; $5894  マスター
    db $F6                         ; $5898  «insert hero name»
    db $3A                         ; $5899  に
    db $90                         ; $589A  　(space)
    db $38,$8D,$26,$32,$8D         ; $589B  と゛うそ゛ = どうぞ
    db $EF,$EE                     ; $58A0  newline
    db $90,$90                     ; $58A2  　　(indent)
    db $24,$33,$33,$29,$25         ; $58A4  あたたかい
    db $90                         ; $58A9  　(space)
    db $3E,$2B,$2F,$4B,$54         ; $58AA  はくしゅを
    db $99                         ; $58AF  ！
    db $F7                         ; $58B0  clear page
    db $F0                         ; $58B1  end of message


; --------------------------------------------------------------------------
; Message #69 ($58B2)
;   〈テリー〉は　やくそうを
;   てにいれた。
; --------------------------------------------------------------------------
Bank67_Msg69:                              ; $58B2  (file $10D8B2)
    db $F6                         ; $58B2  «insert hero name»
    db $3E                         ; $58B3  は
    db $90                         ; $58B4  　(space)
    db $48,$2B,$32,$26,$54         ; $58B5  やくそうを
    db $EF,$EE                     ; $58BA  newline
    db $37,$3A,$25,$51,$33         ; $58BC  てにいれた
    db $8F                         ; $58C1  。
    db $F7                         ; $58C2  clear page
    db $F0                         ; $58C3  end of message


; --------------------------------------------------------------------------
; Message #70 ($58C4)
;   〈テリー〉は　やくそうを
;   みつけた。
;   しかし　もちものが　いっぱいだ。
;   〈テリー〉は　やくそうを
;   たからばこに　もどした。
; --------------------------------------------------------------------------
Bank67_Msg70:                              ; $58C4  (file $10D8C4)
    db $F6                         ; $58C4  «insert hero name»
    db $3E                         ; $58C5  は
    db $90                         ; $58C6  　(space)
    db $48,$2B,$32,$26,$54         ; $58C7  やくそうを
    db $EF,$EE                     ; $58CC  newline
    db $44,$35,$2C,$33             ; $58CE  みつけた
    db $8F                         ; $58D2  。
    db $FA                         ; $58D3  wait-for-button
    db $F7                         ; $58D4  clear page
    db $EF,$EE                     ; $58D5  newline
    db $2F,$29,$2F                 ; $58D7  しかし
    db $90                         ; $58DA  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $58DB  もちものか゛ = もちものが
    db $90                         ; $58E1  　(space)
    db $25,$36,$3E,$8E,$25,$33,$8D ; $58E2  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $58E9  。
    db $EF,$EE                     ; $58EA  newline
    db $FA                         ; $58EC  wait-for-button
    db $F7                         ; $58ED  clear page
    db $EF,$EE                     ; $58EE  newline
    db $F3                         ; $58F0  open text box
    db $F6                         ; $58F1  «insert hero name»
    db $3E                         ; $58F2  は
    db $90                         ; $58F3  　(space)
    db $48,$2B,$32,$26,$54         ; $58F4  やくそうを
    db $EF,$EE                     ; $58F9  newline
    db $33,$29,$4E,$3E,$8D,$2D,$3A ; $58FB  たからは゛こに = たからばこに
    db $90                         ; $5902  　(space)
    db $47,$38,$8D,$2F,$33         ; $5903  もと゛した = もどした
    db $8F                         ; $5908  。
    db $F7                         ; $5909  clear page
    db $F0                         ; $590A  end of message


; --------------------------------------------------------------------------
; Message #71 ($590B)
;   〈テリー〉は　なんと
;   ちいさなメダルを　てにいれた！
; --------------------------------------------------------------------------
Bank67_Msg71:                              ; $590B  (file $10D90B)
    db $F6                         ; $590B  «insert hero name»
    db $3E                         ; $590C  は
    db $90                         ; $590D  　(space)
    db $39,$55,$38                 ; $590E  なんと
    db $EF,$EE                     ; $5911  newline
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5913  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $591C  　(space)
    db $37,$3A,$25,$51,$33         ; $591D  てにいれた
    db $99                         ; $5922  ！
    db $F7                         ; $5923  clear page
    db $F0                         ; $5924  end of message


; --------------------------------------------------------------------------
; Message #72 ($5925)
;   なんと　ちいさなメダルを　みつけた！
;   しかし　もちものが　いっぱいだ。
;   〈テリー〉は　ちいさなメダルを
;   ツボにもどした。
; --------------------------------------------------------------------------
Bank67_Msg72:                              ; $5925  (file $10D925)
    db $39,$55,$38                 ; $5925  なんと
    db $90                         ; $5928  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5929  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $5932  　(space)
    db $44,$35,$2C,$33             ; $5933  みつけた
    db $99                         ; $5937  ！
    db $EF,$EE                     ; $5938  newline
    db $2F,$29,$2F                 ; $593A  しかし
    db $90                         ; $593D  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $593E  もちものか゛ = もちものが
    db $90                         ; $5944  　(space)
    db $25,$36,$3E,$8E,$25,$33,$8D ; $5945  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $594C  。
    db $FA                         ; $594D  wait-for-button
    db $F7                         ; $594E  clear page
    db $EF,$EE                     ; $594F  newline
    db $F6                         ; $5951  «insert hero name»
    db $3E                         ; $5952  は
    db $90                         ; $5953  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5954  ちいさなメタ゛ルを = ちいさなメダルを
    db $EF,$EE                     ; $595D  newline
    db $6C,$79,$8D,$3A,$47,$38,$8D,$2F,$33; $595F  ツホ゛にもと゛した = ツボにもどした
    db $8F                         ; $5968  。
    db $F7                         ; $5969  clear page
    db $F0                         ; $596A  end of message


; --------------------------------------------------------------------------
; Message #73 ($596B)
;   「あ[9D]　きみきみ。　ちいさな
;   メダルは　もっているかね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg73:                              ; $596B  (file $10D96B)
    db $EA                         ; $596B  ▶ new page
    db $9F                         ; $596C  box tag
    db $96                         ; $596D  end name/box tag
    db $24                         ; $596E  あ
    db $9D                         ; $596F  ctrl $9D
    db $90                         ; $5970  　(space)
    db $2A,$44,$2A,$44             ; $5971  きみきみ
    db $8F                         ; $5975  。
    db $90                         ; $5976  　(space)
    db $34,$25,$2E,$39             ; $5977  ちいさな
    db $EF,$EE                     ; $597B  newline
    db $90,$90                     ; $597D  　　(indent)
    db $7D,$6A,$8D,$87,$3E         ; $597F  メタ゛ルは = メダルは
    db $90                         ; $5984  　(space)
    db $47,$36,$37,$25,$50,$29,$3C ; $5985  もっているかね
    db $98                         ; $598C  ？
    db $FF                         ; $598D  はい/いいえ
    db $F0                         ; $598E  end of message


; --------------------------------------------------------------------------
; Message #74 ($598F)
;   「もっていない？　いかんな[91]。
;   どこかに　おちているはずだぞ！
; --------------------------------------------------------------------------
Bank67_Msg74:                              ; $598F  (file $10D98F)
    db $EA                         ; $598F  ▶ new page
    db $9F                         ; $5990  box tag
    db $96                         ; $5991  end name/box tag
    db $47,$36,$37,$25,$39,$25     ; $5992  もっていない
    db $98                         ; $5998  ？
    db $90                         ; $5999  　(space)
    db $25,$29,$55,$39             ; $599A  いかんな
    db $91                         ; $599E  ctrl $91
    db $8F                         ; $599F  。
    db $EF,$EE                     ; $59A0  newline
    db $90,$90                     ; $59A2  　　(indent)
    db $38,$8D,$2D,$29,$3A         ; $59A4  と゛こかに = どこかに
    db $90                         ; $59A9  　(space)
    db $28,$34,$37,$25,$50,$3E,$30,$8D,$33,$8D,$32,$8D; $59AA  おちているはす゛た゛そ゛ = おちているはずだぞ
    db $99                         ; $59B6  ！
    db $F7                         ; $59B7  clear page
    db $F0                         ; $59B8  end of message


; --------------------------------------------------------------------------
; Message #75 ($59B9)
;   「お[95]　そうか！　では　このうえの
;   へやに　いくのだ。
;   「ちいさなメダルを　もっていれば
;   かんげいされるぞ！！
; --------------------------------------------------------------------------
Bank67_Msg75:                              ; $59B9  (file $10D9B9)
    db $EA                         ; $59B9  ▶ new page
    db $9F                         ; $59BA  box tag
    db $96                         ; $59BB  end name/box tag
    db $28                         ; $59BC  お
    db $95                         ; $59BD  ctrl $95
    db $90                         ; $59BE  　(space)
    db $32,$26,$29                 ; $59BF  そうか
    db $99                         ; $59C2  ！
    db $90                         ; $59C3  　(space)
    db $37,$8D,$3E                 ; $59C4  て゛は = では
    db $90                         ; $59C7  　(space)
    db $2D,$3D,$26,$27,$3D         ; $59C8  このうえの
    db $EF,$EE                     ; $59CD  newline
    db $90,$90                     ; $59CF  　　(indent)
    db $41,$48,$3A                 ; $59D1  へやに
    db $90                         ; $59D4  　(space)
    db $25,$2B,$3D,$33,$8D         ; $59D5  いくのた゛ = いくのだ
    db $8F                         ; $59DA  。
    db $FA                         ; $59DB  wait-for-button
    db $F7                         ; $59DC  clear page
    db $EF,$EE                     ; $59DD  newline
    db $9F                         ; $59DF  box tag
    db $96                         ; $59E0  end name/box tag
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $59E1  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $59EA  　(space)
    db $47,$36,$37,$25,$51,$3E,$8D ; $59EB  もっていれは゛ = もっていれば
    db $EF,$EE                     ; $59F2  newline
    db $90,$90                     ; $59F4  　　(indent)
    db $29,$55,$2C,$8D,$25,$2E,$51,$50,$32,$8D; $59F6  かんけ゛いされるそ゛ = かんげいされるぞ
    db $99                         ; $5A00  ！
    db $99                         ; $5A01  ！
    db $F7                         ; $5A02  clear page
    db $F0                         ; $5A03  end of message


; --------------------------------------------------------------------------
; Message #76 ($5A04)
;   「そうか。　では　このうえの
;   へやに　いくといい。
; --------------------------------------------------------------------------
Bank67_Msg76:                              ; $5A04  (file $10DA04)
    db $EA                         ; $5A04  ▶ new page
    db $9F                         ; $5A05  box tag
    db $96                         ; $5A06  end name/box tag
    db $32,$26,$29                 ; $5A07  そうか
    db $8F                         ; $5A0A  。
    db $90                         ; $5A0B  　(space)
    db $37,$8D,$3E                 ; $5A0C  て゛は = では
    db $90                         ; $5A0F  　(space)
    db $2D,$3D,$26,$27,$3D         ; $5A10  このうえの
    db $EF,$EE                     ; $5A15  newline
    db $90,$90                     ; $5A17  　　(indent)
    db $41,$48,$3A                 ; $5A19  へやに
    db $90                         ; $5A1C  　(space)
    db $25,$2B,$38,$25,$25         ; $5A1D  いくといい
    db $8F                         ; $5A22  。
    db $F7                         ; $5A23  clear page
    db $F0                         ; $5A24  end of message


; --------------------------------------------------------------------------
; Message #77 ($5A25)
;   「ずーっと　したのほうに　だいちが
;   ぼやけて　みえます、、。
;   「タィジャは　おおきな　きのなかの
;   ちいさな　くになのです、。
; --------------------------------------------------------------------------
Bank67_Msg77:                              ; $5A25  (file $10DA25)
    db $EB                         ; $5A25  ▶ new page
    db $9F                         ; $5A26  box tag
    db $96                         ; $5A27  end name/box tag
    db $30,$8D,$9C,$36,$38         ; $5A28  す゛ーっと = ずーっと
    db $90                         ; $5A2D  　(space)
    db $2F,$33,$3D,$42,$26,$3A     ; $5A2E  したのほうに
    db $90                         ; $5A34  　(space)
    db $33,$8D,$25,$34,$29,$8D     ; $5A35  た゛いちか゛ = だいちが
    db $EF,$EE                     ; $5A3B  newline
    db $90,$90                     ; $5A3D  　　(indent)
    db $42,$8D,$48,$2C,$37         ; $5A3F  ほ゛やけて = ぼやけて
    db $90                         ; $5A44  　(space)
    db $44,$27,$43,$30             ; $5A45  みえます
    db $A4                         ; $5A49  、
    db $A4                         ; $5A4A  、
    db $8F                         ; $5A4B  。
    db $FA                         ; $5A4C  wait-for-button
    db $F7                         ; $5A4D  clear page
    db $EF,$EE                     ; $5A4E  newline
    db $9F                         ; $5A50  box tag
    db $96                         ; $5A51  end name/box tag
    db $6A,$58,$66,$8D,$82,$3E     ; $5A52  タィシ゛ャは = タィジャは
    db $90                         ; $5A58  　(space)
    db $28,$28,$2A,$39             ; $5A59  おおきな
    db $90                         ; $5A5D  　(space)
    db $2A,$3D,$39,$29,$3D         ; $5A5E  きのなかの
    db $EF,$EE                     ; $5A63  newline
    db $90,$90                     ; $5A65  　　(indent)
    db $34,$25,$2E,$39             ; $5A67  ちいさな
    db $90                         ; $5A6B  　(space)
    db $2B,$3A,$39,$3D,$37,$8D,$30 ; $5A6C  くになのて゛す = くになのです
    db $A4                         ; $5A73  、
    db $8F                         ; $5A74  。
    db $F7                         ; $5A75  clear page
    db $F0                         ; $5A76  end of message


; --------------------------------------------------------------------------
; Message #78 ($5A77)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg78:                              ; $5A77  (file $10DA77)
    db $38,$3F,$8D,$4E,$3E         ; $5A77  とひ゛らは = とびらは
    db $90                         ; $5A7C  　(space)
    db $28,$47,$2B                 ; $5A7D  おもく
    db $90                         ; $5A80  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5A81  とさ゛されている = とざされている
    db $8F                         ; $5A89  。
    db $EF,$EE                     ; $5A8A  newline
    db $F7                         ; $5A8C  clear page
    db $F0                         ; $5A8D  end of message


; --------------------------------------------------------------------------
; Message #79 ($5A8E)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg79:                              ; $5A8E  (file $10DA8E)
    db $38,$3F,$8D,$4E,$3E         ; $5A8E  とひ゛らは = とびらは
    db $90                         ; $5A93  　(space)
    db $28,$47,$2B                 ; $5A94  おもく
    db $90                         ; $5A97  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5A98  とさ゛されている = とざされている
    db $8F                         ; $5AA0  。
    db $EF,$EE                     ; $5AA1  newline
    db $F7                         ; $5AA3  clear page
    db $F0                         ; $5AA4  end of message


; --------------------------------------------------------------------------
; Message #80 ($5AA5)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg80:                              ; $5AA5  (file $10DAA5)
    db $38,$3F,$8D,$4E,$3E         ; $5AA5  とひ゛らは = とびらは
    db $90                         ; $5AAA  　(space)
    db $28,$47,$2B                 ; $5AAB  おもく
    db $90                         ; $5AAE  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5AAF  とさ゛されている = とざされている
    db $8F                         ; $5AB7  。
    db $EF,$EE                     ; $5AB8  newline
    db $F7                         ; $5ABA  clear page
    db $F0                         ; $5ABB  end of message


; --------------------------------------------------------------------------
; Message #81 ($5ABC)
;   とびらは　おもく　とざされている。
;   とびらには　もじが　きざまれている。
;   「ちからと　いかりの　へや
; --------------------------------------------------------------------------
Bank67_Msg81:                              ; $5ABC  (file $10DABC)
    db $38,$3F,$8D,$4E,$3E         ; $5ABC  とひ゛らは = とびらは
    db $90                         ; $5AC1  　(space)
    db $28,$47,$2B                 ; $5AC2  おもく
    db $90                         ; $5AC5  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5AC6  とさ゛されている = とざされている
    db $8F                         ; $5ACE  。
    db $EF,$EE                     ; $5ACF  newline
    db $FA                         ; $5AD1  wait-for-button
    db $F7                         ; $5AD2  clear page
    db $EF,$EE                     ; $5AD3  newline
    db $F3                         ; $5AD5  open text box
    db $38,$3F,$8D,$4E,$3A,$3E     ; $5AD6  とひ゛らには = とびらには
    db $90                         ; $5ADC  　(space)
    db $47,$2F,$8D,$29,$8D         ; $5ADD  もし゛か゛ = もじが
    db $90                         ; $5AE2  　(space)
    db $2A,$2E,$8D,$43,$51,$37,$25,$50; $5AE3  きさ゛まれている = きざまれている
    db $8F                         ; $5AEB  。
    db $EF,$EE                     ; $5AEC  newline
    db $96                         ; $5AEE  end name/box tag
    db $34,$29,$4E,$38             ; $5AEF  ちからと
    db $90                         ; $5AF3  　(space)
    db $25,$29,$4F,$3D             ; $5AF4  いかりの
    db $90                         ; $5AF8  　(space)
    db $41,$48                     ; $5AF9  へや
    db $F7                         ; $5AFB  clear page
    db $F0                         ; $5AFC  end of message


; --------------------------------------------------------------------------
; Message #82 ($5AFD)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg82:                              ; $5AFD  (file $10DAFD)
    db $38,$3F,$8D,$4E,$3E         ; $5AFD  とひ゛らは = とびらは
    db $90                         ; $5B02  　(space)
    db $28,$47,$2B                 ; $5B03  おもく
    db $90                         ; $5B06  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5B07  とさ゛されている = とざされている
    db $8F                         ; $5B0F  。
    db $EF,$EE                     ; $5B10  newline
    db $F7                         ; $5B12  clear page
    db $F0                         ; $5B13  end of message


; --------------------------------------------------------------------------
; Message #83 ($5B14)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg83:                              ; $5B14  (file $10DB14)
    db $38,$3F,$8D,$4E,$3E         ; $5B14  とひ゛らは = とびらは
    db $90                         ; $5B19  　(space)
    db $28,$47,$2B                 ; $5B1A  おもく
    db $90                         ; $5B1D  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5B1E  とさ゛されている = とざされている
    db $8F                         ; $5B26  。
    db $EF,$EE                     ; $5B27  newline
    db $F7                         ; $5B29  clear page
    db $F0                         ; $5B2A  end of message


; --------------------------------------------------------------------------
; Message #84 ($5B2B)
;   とびらは　おもく　とざされている。
; --------------------------------------------------------------------------
Bank67_Msg84:                              ; $5B2B  (file $10DB2B)
    db $38,$3F,$8D,$4E,$3E         ; $5B2B  とひ゛らは = とびらは
    db $90                         ; $5B30  　(space)
    db $28,$47,$2B                 ; $5B31  おもく
    db $90                         ; $5B34  　(space)
    db $38,$2E,$8D,$2E,$51,$37,$25,$50; $5B35  とさ゛されている = とざされている
    db $8F                         ; $5B3D  。
    db $EF,$EE                     ; $5B3E  newline
    db $F7                         ; $5B40  clear page
    db $F0                         ; $5B41  end of message


; --------------------------------------------------------------------------
; Message #85 ($5B42)
;   〈テリー〉は　タルのなかを
;   のぞきこんだ。
;   タルには　もじが　きざまれている。
;   「ワルぼう　さんじょう
; --------------------------------------------------------------------------
Bank67_Msg85:                              ; $5B42  (file $10DB42)
    db $F6                         ; $5B42  «insert hero name»
    db $3E                         ; $5B43  は
    db $90                         ; $5B44  　(space)
    db $6A,$87,$3D,$39,$29,$54     ; $5B45  タルのなかを
    db $EF,$EE                     ; $5B4B  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $5B4D  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $5B55  。
    db $FA                         ; $5B56  wait-for-button
    db $F7                         ; $5B57  clear page
    db $EF,$EE                     ; $5B58  newline
    db $6A,$87,$3A,$3E             ; $5B5A  タルには
    db $90                         ; $5B5E  　(space)
    db $47,$2F,$8D,$29,$8D         ; $5B5F  もし゛か゛ = もじが
    db $90                         ; $5B64  　(space)
    db $2A,$2E,$8D,$43,$51,$37,$25,$50; $5B65  きさ゛まれている = きざまれている
    db $8F                         ; $5B6D  。
    db $EF,$EE                     ; $5B6E  newline
    db $FA                         ; $5B70  wait-for-button
    db $F7                         ; $5B71  clear page
    db $EF,$EE                     ; $5B72  newline
    db $F3                         ; $5B74  open text box
    db $96                         ; $5B75  end name/box tag
    db $8A,$87,$42,$8D,$26         ; $5B76  ワルほ゛う = ワルぼう
    db $90                         ; $5B7B  　(space)
    db $2E,$55,$2F,$8D,$4D,$26     ; $5B7C  さんし゛ょう = さんじょう
    db $EF,$EE                     ; $5B82  newline
    db $F7                         ; $5B84  clear page
    db $F0                         ; $5B85  end of message


; --------------------------------------------------------------------------
; Message #86 ($5B86)
;   〈テリー〉は　タルのなかを
;   のぞきこんだ。
; --------------------------------------------------------------------------
Bank67_Msg86:                              ; $5B86  (file $10DB86)
    db $F6                         ; $5B86  «insert hero name»
    db $3E                         ; $5B87  は
    db $90                         ; $5B88  　(space)
    db $6A,$87,$3D,$39,$29,$54     ; $5B89  タルのなかを
    db $EF,$EE                     ; $5B8F  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $5B91  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $5B99  。
    db $FA                         ; $5B9A  wait-for-button
    db $F7                         ; $5B9B  clear page
    db $F0                         ; $5B9C  end of message


; --------------------------------------------------------------------------
; Message #87 ($5B9D)
;   なんと　ちいさなメダルを　みつけた！
;   しかし　もちものが　いっぱいだ。
;   〈テリー〉は　ちいさなメダルを
;   タルにもどした。
; --------------------------------------------------------------------------
Bank67_Msg87:                              ; $5B9D  (file $10DB9D)
    db $39,$55,$38                 ; $5B9D  なんと
    db $90                         ; $5BA0  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5BA1  ちいさなメタ゛ルを = ちいさなメダルを
    db $90                         ; $5BAA  　(space)
    db $44,$35,$2C,$33             ; $5BAB  みつけた
    db $99                         ; $5BAF  ！
    db $EF,$EE                     ; $5BB0  newline
    db $2F,$29,$2F                 ; $5BB2  しかし
    db $90                         ; $5BB5  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $5BB6  もちものか゛ = もちものが
    db $90                         ; $5BBC  　(space)
    db $25,$36,$3E,$8E,$25,$33,$8D ; $5BBD  いっは゜いた゛ = いっぱいだ
    db $8F                         ; $5BC4  。
    db $FA                         ; $5BC5  wait-for-button
    db $F7                         ; $5BC6  clear page
    db $EF,$EE                     ; $5BC7  newline
    db $F6                         ; $5BC9  «insert hero name»
    db $3E                         ; $5BCA  は
    db $90                         ; $5BCB  　(space)
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$54; $5BCC  ちいさなメタ゛ルを = ちいさなメダルを
    db $EF,$EE                     ; $5BD5  newline
    db $6A,$87,$3A,$47,$38,$8D,$2F,$33; $5BD7  タルにもと゛した = タルにもどした
    db $8F                         ; $5BDF  。
    db $F7                         ; $5BE0  clear page
    db $F0                         ; $5BE1  end of message


; --------------------------------------------------------------------------
; Message #88 ($5BE2)
;   〈テリー〉は　タルのなかを
;   のぞきこんだ。
;   しかし　なにもなかった。
; --------------------------------------------------------------------------
Bank67_Msg88:                              ; $5BE2  (file $10DBE2)
    db $F6                         ; $5BE2  «insert hero name»
    db $3E                         ; $5BE3  は
    db $90                         ; $5BE4  　(space)
    db $6A,$87,$3D,$39,$29,$54     ; $5BE5  タルのなかを
    db $EF,$EE                     ; $5BEB  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $5BED  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $5BF5  。
    db $FA                         ; $5BF6  wait-for-button
    db $F7                         ; $5BF7  clear page
    db $EF,$EE                     ; $5BF8  newline
    db $2F,$29,$2F                 ; $5BFA  しかし
    db $90                         ; $5BFD  　(space)
    db $39,$3A,$47,$39,$29,$36,$33 ; $5BFE  なにもなかった
    db $8F                         ; $5C05  。
    db $EF,$EE                     ; $5C06  newline
    db $F7                         ; $5C08  clear page
    db $F0                         ; $5C09  end of message


; --------------------------------------------------------------------------
; Message #89 ($5C0A)
;   〈テリー〉は　タルのなかを
;   のぞきこんだ。
;   なかで　まものが　すやすやと
;   ねむっている。
; --------------------------------------------------------------------------
Bank67_Msg89:                              ; $5C0A  (file $10DC0A)
    db $F6                         ; $5C0A  «insert hero name»
    db $3E                         ; $5C0B  は
    db $90                         ; $5C0C  　(space)
    db $6A,$87,$3D,$39,$29,$54     ; $5C0D  タルのなかを
    db $EF,$EE                     ; $5C13  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $5C15  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $5C1D  。
    db $FA                         ; $5C1E  wait-for-button
    db $F7                         ; $5C1F  clear page
    db $EF,$EE                     ; $5C20  newline
    db $39,$29,$37,$8D             ; $5C22  なかて゛ = なかで
    db $90                         ; $5C26  　(space)
    db $43,$47,$3D,$29,$8D         ; $5C27  まものか゛ = まものが
    db $90                         ; $5C2C  　(space)
    db $30,$48,$30,$48,$38         ; $5C2D  すやすやと
    db $EF,$EE                     ; $5C32  newline
    db $3C,$45,$36,$37,$25,$50     ; $5C34  ねむっている
    db $8F                         ; $5C3A  。
    db $F7                         ; $5C3B  clear page
    db $F0                         ; $5C3C  end of message


; --------------------------------------------------------------------------
; Message #90 ($5C3D)
;   〈テリー〉は　たからばこを　しらべた！
;   しかし　なかは　からっぽだった。
; --------------------------------------------------------------------------
Bank67_Msg90:                              ; $5C3D  (file $10DC3D)
    db $F6                         ; $5C3D  «insert hero name»
    db $3E                         ; $5C3E  は
    db $90                         ; $5C3F  　(space)
    db $33,$29,$4E,$3E,$8D,$2D,$54 ; $5C40  たからは゛こを = たからばこを
    db $90                         ; $5C47  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5C48  しらへ゛た = しらべた
    db $99                         ; $5C4D  ！
    db $EF,$EE                     ; $5C4E  newline
    db $FA                         ; $5C50  wait-for-button
    db $F7                         ; $5C51  clear page
    db $EF,$EE                     ; $5C52  newline
    db $F3                         ; $5C54  open text box
    db $2F,$29,$2F                 ; $5C55  しかし
    db $90                         ; $5C58  　(space)
    db $39,$29,$3E                 ; $5C59  なかは
    db $90                         ; $5C5C  　(space)
    db $29,$4E,$36,$42,$8E,$33,$8D,$36,$33; $5C5D  からっほ゜た゛った = からっぽだった
    db $8F                         ; $5C66  。
    db $EF,$EE                     ; $5C67  newline
    db $F7                         ; $5C69  clear page
    db $F0                         ; $5C6A  end of message


; --------------------------------------------------------------------------
; Message #91 ($5C6B)
;   「おぬし。　たびのしおりを
;   つかっておるか？
;   「あれは　まったく　べんりな
;   しろものじゃわい。
;   「まえはバザーでも　うっておったが
;   いまは　どうかのう。
; --------------------------------------------------------------------------
Bank67_Msg91:                              ; $5C6B  (file $10DC6B)
    db $EA                         ; $5C6B  ▶ new page
    db $9F                         ; $5C6C  box tag
    db $96                         ; $5C6D  end name/box tag
    db $28,$3B,$2F                 ; $5C6E  おぬし
    db $8F                         ; $5C71  。
    db $90                         ; $5C72  　(space)
    db $33,$3F,$8D,$3D,$2F,$28,$4F,$54; $5C73  たひ゛のしおりを = たびのしおりを
    db $EF,$EE                     ; $5C7B  newline
    db $90,$90                     ; $5C7D  　　(indent)
    db $35,$29,$36,$37,$28,$50,$29 ; $5C7F  つかっておるか
    db $98                         ; $5C86  ？
    db $FA                         ; $5C87  wait-for-button
    db $F7                         ; $5C88  clear page
    db $EF,$EE                     ; $5C89  newline
    db $9F                         ; $5C8B  box tag
    db $96                         ; $5C8C  end name/box tag
    db $24,$51,$3E                 ; $5C8D  あれは
    db $90                         ; $5C90  　(space)
    db $43,$36,$33,$2B             ; $5C91  まったく
    db $90                         ; $5C95  　(space)
    db $41,$8D,$55,$4F,$39         ; $5C96  へ゛んりな = べんりな
    db $EF,$EE                     ; $5C9B  newline
    db $90,$90                     ; $5C9D  　　(indent)
    db $2F,$52,$47,$3D,$2F,$8D,$49,$53,$25; $5C9F  しろものし゛ゃわい = しろものじゃわい
    db $8F                         ; $5CA8  。
    db $FA                         ; $5CA9  wait-for-button
    db $F7                         ; $5CAA  clear page
    db $EF,$EE                     ; $5CAB  newline
    db $9F                         ; $5CAD  box tag
    db $96                         ; $5CAE  end name/box tag
    db $43,$27,$3E,$75,$8D,$65,$8D,$9C,$37,$8D,$47; $5CAF  まえはハ゛サ゛ーて゛も = まえはバザーでも
    db $90                         ; $5CBA  　(space)
    db $26,$36,$37,$28,$36,$33,$29,$8D; $5CBB  うっておったか゛ = うっておったが
    db $EF,$EE                     ; $5CC3  newline
    db $90,$90                     ; $5CC5  　　(indent)
    db $25,$43,$3E                 ; $5CC7  いまは
    db $90                         ; $5CCA  　(space)
    db $38,$8D,$26,$29,$3D,$26     ; $5CCB  と゛うかのう = どうかのう
    db $8F                         ; $5CD1  。
    db $F7                         ; $5CD2  clear page
    db $F0                         ; $5CD3  end of message


; --------------------------------------------------------------------------
; Message #92 ($5CD4)
;   「うい[9D]　ひっく。
;   「ことしは　だれが
;   ゆうしょうするのか、、
;   「よそくが　つかねえな。
;   ひっく、、。
; --------------------------------------------------------------------------
Bank67_Msg92:                              ; $5CD4  (file $10DCD4)
    db $EA                         ; $5CD4  ▶ new page
    db $9F                         ; $5CD5  box tag
    db $96                         ; $5CD6  end name/box tag
    db $26,$25                     ; $5CD7  うい
    db $9D                         ; $5CD9  ctrl $9D
    db $90                         ; $5CDA  　(space)
    db $3F,$36,$2B                 ; $5CDB  ひっく
    db $8F                         ; $5CDE  。
    db $EF,$EE                     ; $5CDF  newline
    db $FA                         ; $5CE1  wait-for-button
    db $F7                         ; $5CE2  clear page
    db $EF,$EE                     ; $5CE3  newline
    db $F3                         ; $5CE5  open text box
    db $9F                         ; $5CE6  box tag
    db $96                         ; $5CE7  end name/box tag
    db $2D,$38,$2F,$3E             ; $5CE8  ことしは
    db $90                         ; $5CEC  　(space)
    db $33,$8D,$51,$29,$8D         ; $5CED  た゛れか゛ = だれが
    db $EF,$EE                     ; $5CF2  newline
    db $90,$90                     ; $5CF4  　　(indent)
    db $4A,$26,$2F,$4D,$26,$30,$50,$3D,$29; $5CF6  ゆうしょうするのか
    db $A4                         ; $5CFF  、
    db $A4                         ; $5D00  、
    db $FA                         ; $5D01  wait-for-button
    db $F7                         ; $5D02  clear page
    db $EF,$EE                     ; $5D03  newline
    db $9F                         ; $5D05  box tag
    db $96                         ; $5D06  end name/box tag
    db $4C,$32,$2B,$29,$8D         ; $5D07  よそくか゛ = よそくが
    db $90                         ; $5D0C  　(space)
    db $35,$29,$3C,$27,$39         ; $5D0D  つかねえな
    db $8F                         ; $5D12  。
    db $EF,$EE                     ; $5D13  newline
    db $90,$90                     ; $5D15  　　(indent)
    db $3F,$36,$2B                 ; $5D17  ひっく
    db $A4                         ; $5D1A  、
    db $A4                         ; $5D1B  、
    db $8F                         ; $5D1C  。
    db $F7                         ; $5D1D  clear page
    db $F0                         ; $5D1E  end of message


; --------------------------------------------------------------------------
; Message #93 ($5D1F)
;   「なんべんいったら　わかるのさ？！
;   ぼくは　かえりたくないんだよ！
; --------------------------------------------------------------------------
Bank67_Msg93:                              ; $5D1F  (file $10DD1F)
    db $EB                         ; $5D1F  ▶ new page
    db $9F                         ; $5D20  box tag
    db $96                         ; $5D21  end name/box tag
    db $39,$55,$41,$8D,$55,$25,$36,$33,$4E; $5D22  なんへ゛んいったら = なんべんいったら
    db $90                         ; $5D2B  　(space)
    db $53,$29,$50,$3D,$2E         ; $5D2C  わかるのさ
    db $98                         ; $5D31  ？
    db $99                         ; $5D32  ！
    db $EF,$EE                     ; $5D33  newline
    db $90,$90                     ; $5D35  　　(indent)
    db $42,$8D,$2B,$3E             ; $5D37  ほ゛くは = ぼくは
    db $90                         ; $5D3B  　(space)
    db $29,$27,$4F,$33,$2B,$39,$25,$55,$33,$8D,$4C; $5D3C  かえりたくないんた゛よ = かえりたくないんだよ
    db $99                         ; $5D47  ！
    db $F7                         ; $5D48  clear page
    db $F0                         ; $5D49  end of message


; --------------------------------------------------------------------------
; Message #94 ($5D4A)
;   おう「おお　〈テリー〉よ！
;   あらたな　まものを　たおしたか！
;   おう「ふふ。　どうじゃった？？
;   おきにいりのこに　あえたかな？
;   おう「いや　いや。　なんでもない。
;   じゃがそなたも　すきものよのう！
; --------------------------------------------------------------------------
Bank67_Msg94:                              ; $5D4A  (file $10DD4A)
    db $EA                         ; $5D4A  ▶ new page
    db $28,$26                     ; $5D4B  おう  (speaker: おう)
    db $96                         ; $5D4D  end name/box tag
    db $28,$28                     ; $5D4E  おお
    db $90                         ; $5D50  　(space)
    db $F6                         ; $5D51  «insert hero name»
    db $4C                         ; $5D52  よ
    db $99                         ; $5D53  ！
    db $EF,$EE                     ; $5D54  newline
    db $90,$90                     ; $5D56  　　(indent)
    db $24,$4E,$33,$39             ; $5D58  あらたな
    db $90                         ; $5D5C  　(space)
    db $43,$47,$3D,$54             ; $5D5D  まものを
    db $90                         ; $5D61  　(space)
    db $33,$28,$2F,$33,$29         ; $5D62  たおしたか
    db $99                         ; $5D67  ！
    db $FA                         ; $5D68  wait-for-button
    db $F7                         ; $5D69  clear page
    db $EF,$EE                     ; $5D6A  newline
    db $28,$26                     ; $5D6C  おう  (speaker: おう)
    db $96                         ; $5D6E  end name/box tag
    db $40,$40                     ; $5D6F  ふふ
    db $8F                         ; $5D71  。
    db $90                         ; $5D72  　(space)
    db $38,$8D,$26,$2F,$8D,$49,$36,$33; $5D73  と゛うし゛ゃった = どうじゃった
    db $98                         ; $5D7B  ？
    db $98                         ; $5D7C  ？
    db $EF,$EE                     ; $5D7D  newline
    db $90,$90                     ; $5D7F  　　(indent)
    db $28,$2A,$3A,$25,$4F,$3D,$2D,$3A; $5D81  おきにいりのこに
    db $90                         ; $5D89  　(space)
    db $24,$27,$33,$29,$39         ; $5D8A  あえたかな
    db $98                         ; $5D8F  ？
    db $FA                         ; $5D90  wait-for-button
    db $F7                         ; $5D91  clear page
    db $EF,$EE                     ; $5D92  newline
    db $28,$26                     ; $5D94  おう  (speaker: おう)
    db $96                         ; $5D96  end name/box tag
    db $25,$48                     ; $5D97  いや
    db $90                         ; $5D99  　(space)
    db $25,$48                     ; $5D9A  いや
    db $8F                         ; $5D9C  。
    db $90                         ; $5D9D  　(space)
    db $39,$55,$37,$8D,$47,$39,$25 ; $5D9E  なんて゛もない = なんでもない
    db $8F                         ; $5DA5  。
    db $EF,$EE                     ; $5DA6  newline
    db $90,$90                     ; $5DA8  　　(indent)
    db $2F,$8D,$49,$29,$8D,$32,$39,$33,$47; $5DAA  し゛ゃか゛そなたも = じゃがそなたも
    db $90                         ; $5DB3  　(space)
    db $30,$2A,$47,$3D,$4C,$3D,$26 ; $5DB4  すきものよのう
    db $99                         ; $5DBB  ！
    db $F7                         ; $5DBC  clear page
    db $F0                         ; $5DBD  end of message


; --------------------------------------------------------------------------
; Message #95 ($5DBE)
;   「それ　いいすぎ。
; --------------------------------------------------------------------------
Bank67_Msg95:                              ; $5DBE  (file $10DDBE)
    db $EB                         ; $5DBE  ▶ new page
    db $9F                         ; $5DBF  box tag
    db $96                         ; $5DC0  end name/box tag
    db $32,$51                     ; $5DC1  それ
    db $90                         ; $5DC3  　(space)
    db $25,$25,$30,$2A,$8D         ; $5DC4  いいすき゛ = いいすぎ
    db $8F                         ; $5DC9  。
    db $EF,$EE                     ; $5DCA  newline
    db $F7                         ; $5DCC  clear page
    db $F0                         ; $5DCD  end of message


; --------------------------------------------------------------------------
; Message #96 ($5DCE)
;   おう「しょうじんするが　よいぞ！
;   わしは　これにて　しつれいする。
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank67_Msg96:                              ; $5DCE  (file $10DDCE)
    db $EA                         ; $5DCE  ▶ new page
    db $28,$26                     ; $5DCF  おう  (speaker: おう)
    db $96                         ; $5DD1  end name/box tag
    db $2F,$4D,$26,$2F,$8D,$55,$30,$50,$29,$8D; $5DD2  しょうし゛んするか゛ = しょうじんするが
    db $90                         ; $5DDC  　(space)
    db $4C,$25,$32,$8D             ; $5DDD  よいそ゛ = よいぞ
    db $99                         ; $5DE1  ！
    db $EF,$EE                     ; $5DE2  newline
    db $90,$90                     ; $5DE4  　　(indent)
    db $53,$2F,$3E                 ; $5DE6  わしは
    db $90                         ; $5DE9  　(space)
    db $2D,$51,$3A,$37             ; $5DEA  これにて
    db $90                         ; $5DEE  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $5DEF  しつれいする
    db $8F                         ; $5DF5  。
    db $FA                         ; $5DF6  wait-for-button
    db $F7                         ; $5DF7  clear page
    db $EF,$EE                     ; $5DF8  newline
    db $28,$26                     ; $5DFA  おう  (speaker: おう)
    db $96                         ; $5DFC  end name/box tag
    db $58,$69                     ; $5DFD  ィソ
    db $90                         ; $5DFF  　(space)
    db $58,$69                     ; $5E00  ィソ
    db $A4                         ; $5E02  、
    db $90                         ; $5E03  　(space)
    db $58,$69                     ; $5E04  ィソ
    db $90                         ; $5E06  　(space)
    db $58,$69                     ; $5E07  ィソ
    db $A4                         ; $5E09  、
    db $A4                         ; $5E0A  、
    db $8F                         ; $5E0B  。
    db $EF,$EE                     ; $5E0C  newline
    db $F7                         ; $5E0E  clear page
    db $F0                         ; $5E0F  end of message


; --------------------------------------------------------------------------
; Message #97 ($5E10)
;   なにもありません
; --------------------------------------------------------------------------
Bank67_Msg97:                              ; $5E10  (file $10DE10)
    db $EA                         ; $5E10  ▶ new page
    db $39,$3A,$47,$24,$4F,$43,$31,$55; $5E11  なにもありません
    db $EF,$EE                     ; $5E19  newline
    db $F7                         ; $5E1B  clear page
    db $F0                         ; $5E1C  end of message


; --------------------------------------------------------------------------
; Message #98 ($5E1D)
;   「ありがとう　〈テリー〉！　メダル
;   たくさん　もってきてくれたね！
;   「おれいに　たびのとびらを
;   ひらいて　あげるよ！
;   「おじさんが　どこかに
;   かくしたんだけど　どこだっけ？？
;   「みつかったら　よういしておくから
;   まった　きってねー！
; --------------------------------------------------------------------------
Bank67_Msg98:                              ; $5E1D  (file $10DE1D)
    db $EB                         ; $5E1D  ▶ new page
    db $9F                         ; $5E1E  box tag
    db $96                         ; $5E1F  end name/box tag
    db $24,$4F,$29,$8D,$38,$26     ; $5E20  ありか゛とう = ありがとう
    db $90                         ; $5E26  　(space)
    db $F6                         ; $5E27  «insert hero name»
    db $99                         ; $5E28  ！
    db $90                         ; $5E29  　(space)
    db $7D,$6A,$8D,$87             ; $5E2A  メタ゛ル = メダル
    db $EF,$EE                     ; $5E2E  newline
    db $90,$90                     ; $5E30  　　(indent)
    db $33,$2B,$2E,$55             ; $5E32  たくさん
    db $90                         ; $5E36  　(space)
    db $47,$36,$37,$2A,$37,$2B,$51,$33,$3C; $5E37  もってきてくれたね
    db $99                         ; $5E40  ！
    db $FA                         ; $5E41  wait-for-button
    db $F7                         ; $5E42  clear page
    db $EF,$EE                     ; $5E43  newline
    db $9F                         ; $5E45  box tag
    db $96                         ; $5E46  end name/box tag
    db $28,$51,$25,$3A             ; $5E47  おれいに
    db $90                         ; $5E4B  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$54; $5E4C  たひ゛のとひ゛らを = たびのとびらを
    db $EF,$EE                     ; $5E55  newline
    db $90,$90                     ; $5E57  　　(indent)
    db $3F,$4E,$25,$37             ; $5E59  ひらいて
    db $90                         ; $5E5D  　(space)
    db $24,$2C,$8D,$50,$4C         ; $5E5E  あけ゛るよ = あげるよ
    db $99                         ; $5E63  ！
    db $FA                         ; $5E64  wait-for-button
    db $F7                         ; $5E65  clear page
    db $EF,$EE                     ; $5E66  newline
    db $9F                         ; $5E68  box tag
    db $96                         ; $5E69  end name/box tag
    db $28,$2F,$8D,$2E,$55,$29,$8D ; $5E6A  おし゛さんか゛ = おじさんが
    db $90                         ; $5E71  　(space)
    db $38,$8D,$2D,$29,$3A         ; $5E72  と゛こかに = どこかに
    db $EF,$EE                     ; $5E77  newline
    db $90,$90                     ; $5E79  　　(indent)
    db $29,$2B,$2F,$33,$55,$33,$8D,$2C,$38,$8D; $5E7B  かくしたんた゛けと゛ = かくしたんだけど
    db $90                         ; $5E85  　(space)
    db $38,$8D,$2D,$33,$8D,$36,$2C ; $5E86  と゛こた゛っけ = どこだっけ
    db $98                         ; $5E8D  ？
    db $98                         ; $5E8E  ？
    db $FA                         ; $5E8F  wait-for-button
    db $F7                         ; $5E90  clear page
    db $EF,$EE                     ; $5E91  newline
    db $9F                         ; $5E93  box tag
    db $96                         ; $5E94  end name/box tag
    db $44,$35,$29,$36,$33,$4E     ; $5E95  みつかったら
    db $90                         ; $5E9B  　(space)
    db $4C,$26,$25,$2F,$37,$28,$2B,$29,$4E; $5E9C  よういしておくから
    db $EF,$EE                     ; $5EA5  newline
    db $90,$90                     ; $5EA7  　　(indent)
    db $43,$36,$33                 ; $5EA9  まった
    db $90                         ; $5EAC  　(space)
    db $2A,$36,$37,$3C,$9C         ; $5EAD  きってねー
    db $99                         ; $5EB2  ！
    db $F7                         ; $5EB3  clear page
    db $F0                         ; $5EB4  end of message


; --------------------------------------------------------------------------
; Message #99 ($5EB5)
;   「みつかったよ！　いちばんおくで
;   おおきなしれんが　まっているよ！
; --------------------------------------------------------------------------
Bank67_Msg99:                              ; $5EB5  (file $10DEB5)
    db $EB                         ; $5EB5  ▶ new page
    db $9F                         ; $5EB6  box tag
    db $96                         ; $5EB7  end name/box tag
    db $44,$35,$29,$36,$33,$4C     ; $5EB8  みつかったよ
    db $99                         ; $5EBE  ！
    db $90                         ; $5EBF  　(space)
    db $25,$34,$3E,$8D,$55,$28,$2B,$37,$8D; $5EC0  いちは゛んおくて゛ = いちばんおくで
    db $EF,$EE                     ; $5EC9  newline
    db $90,$90                     ; $5ECB  　　(indent)
    db $28,$28,$2A,$39,$2F,$51,$55,$29,$8D; $5ECD  おおきなしれんか゛ = おおきなしれんが
    db $90                         ; $5ED6  　(space)
    db $43,$36,$37,$25,$50,$4C     ; $5ED7  まっているよ
    db $99                         ; $5EDD  ！
    db $F7                         ; $5EDE  clear page
    db $F0                         ; $5EDF  end of message


; --------------------------------------------------------------------------
; Message #100 ($5EE0)
;   わたほ゛う「〈テリー〉！　やったな！
;   おしろに　もどしてやるよ！
; --------------------------------------------------------------------------
Bank67_Msg100:                             ; $5EE0  (file $10DEE0)
    db $EB                         ; $5EE0  ▶ new page
    db $53,$33,$42,$8D,$26         ; $5EE1  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5EE6  end name/box tag
    db $F6                         ; $5EE7  «insert hero name»
    db $99                         ; $5EE8  ！
    db $90                         ; $5EE9  　(space)
    db $48,$36,$33,$39             ; $5EEA  やったな
    db $99                         ; $5EEE  ！
    db $EF,$EE                     ; $5EEF  newline
    db $90,$90                     ; $5EF1  　　(indent)
    db $28,$2F,$52,$3A             ; $5EF3  おしろに
    db $90                         ; $5EF7  　(space)
    db $47,$38,$8D,$2F,$37,$48,$50,$4C; $5EF8  もと゛してやるよ = もどしてやるよ
    db $99                         ; $5F00  ！
    db $F7                         ; $5F01  clear page
    db $F0                         ; $5F02  end of message


; --------------------------------------------------------------------------
; Message #101 ($5F03)
;   おう「おお　〈テリー〉！
;   [10]クラスを　かちぬいたそうだな！
;   おう「あっぱれであるぞ！
;   そなたは　なかなか、、　やや！！
; --------------------------------------------------------------------------
Bank67_Msg101:                             ; $5F03  (file $10DF03)
    db $EA                         ; $5F03  ▶ new page
    db $28,$26                     ; $5F04  おう  (speaker: おう)
    db $96                         ; $5F06  end name/box tag
    db $28,$28                     ; $5F07  おお
    db $90                         ; $5F09  　(space)
    db $F6                         ; $5F0A  «insert hero name»
    db $99                         ; $5F0B  ！
    db $EF,$EE                     ; $5F0C  newline
    db $90,$90                     ; $5F0E  　　(indent)
    db $10                         ; $5F10  ctrl $10
    db $62,$85,$67,$54             ; $5F11  クラスを
    db $90                         ; $5F15  　(space)
    db $29,$34,$3B,$25,$33,$32,$26,$33,$8D,$39; $5F16  かちぬいたそうた゛な = かちぬいたそうだな
    db $99                         ; $5F20  ！
    db $FA                         ; $5F21  wait-for-button
    db $F7                         ; $5F22  clear page
    db $EF,$EE                     ; $5F23  newline
    db $28,$26                     ; $5F25  おう  (speaker: おう)
    db $96                         ; $5F27  end name/box tag
    db $24,$36,$3E,$8E,$51,$37,$8D,$24,$50,$32,$8D; $5F28  あっは゜れて゛あるそ゛ = あっぱれであるぞ
    db $99                         ; $5F33  ！
    db $EF,$EE                     ; $5F34  newline
    db $90,$90                     ; $5F36  　　(indent)
    db $32,$39,$33,$3E             ; $5F38  そなたは
    db $90                         ; $5F3C  　(space)
    db $39,$29,$39,$29             ; $5F3D  なかなか
    db $A4                         ; $5F41  、
    db $A4                         ; $5F42  、
    db $90                         ; $5F43  　(space)
    db $48,$48                     ; $5F44  やや
    db $99                         ; $5F46  ！
    db $99                         ; $5F47  ！
    db $F7                         ; $5F48  clear page
    db $F0                         ; $5F49  end of message


; --------------------------------------------------------------------------
; Message #102 ($5F4A)
;   「ごきげんいかがであるかな？
;   タィジャのこくおうよ。
;   「そういえば　こんかいは　こちらが
;   しゅさいこくであったな。
;   「しゅさいこくとして　はずかしく
;   ない　たたかいを　してほしい！
; --------------------------------------------------------------------------
Bank67_Msg102:                             ; $5F4A  (file $10DF4A)
    db $EA                         ; $5F4A  ▶ new page
    db $9F                         ; $5F4B  box tag
    db $96                         ; $5F4C  end name/box tag
    db $2D,$8D,$2A,$2C,$8D,$55,$25,$29,$29,$8D,$37,$8D,$24,$50,$29,$39; $5F4D  こ゛きけ゛んいかか゛て゛あるかな = ごきげんいかがであるかな
    db $98                         ; $5F5D  ？
    db $EF,$EE                     ; $5F5E  newline
    db $90,$90                     ; $5F60  　　(indent)
    db $6A,$58,$66,$8D,$82,$3D,$2D,$2B,$28,$26,$4C; $5F62  タィシ゛ャのこくおうよ = タィジャのこくおうよ
    db $8F                         ; $5F6D  。
    db $90                         ; $5F6E  　(space)
    db $FA                         ; $5F6F  wait-for-button
    db $F7                         ; $5F70  clear page
    db $EF,$EE                     ; $5F71  newline
    db $9F                         ; $5F73  box tag
    db $96                         ; $5F74  end name/box tag
    db $32,$26,$25,$27,$3E,$8D     ; $5F75  そういえは゛ = そういえば
    db $90                         ; $5F7B  　(space)
    db $2D,$55,$29,$25,$3E         ; $5F7C  こんかいは
    db $90                         ; $5F81  　(space)
    db $2D,$34,$4E,$29,$8D         ; $5F82  こちらか゛ = こちらが
    db $EF,$EE                     ; $5F87  newline
    db $90,$90                     ; $5F89  　　(indent)
    db $2F,$4B,$2E,$25,$2D,$2B,$37,$8D,$24,$36,$33,$39; $5F8B  しゅさいこくて゛あったな = しゅさいこくであったな
    db $8F                         ; $5F97  。
    db $FA                         ; $5F98  wait-for-button
    db $F7                         ; $5F99  clear page
    db $EF,$EE                     ; $5F9A  newline
    db $9F                         ; $5F9C  box tag
    db $96                         ; $5F9D  end name/box tag
    db $2F,$4B,$2E,$25,$2D,$2B,$38,$2F,$37; $5F9E  しゅさいこくとして
    db $90                         ; $5FA7  　(space)
    db $3E,$30,$8D,$29,$2F,$2B     ; $5FA8  はす゛かしく = はずかしく
    db $EF,$EE                     ; $5FAE  newline
    db $90,$90                     ; $5FB0  　　(indent)
    db $39,$25                     ; $5FB2  ない
    db $90                         ; $5FB4  　(space)
    db $33,$33,$29,$25,$54         ; $5FB5  たたかいを
    db $90                         ; $5FBA  　(space)
    db $2F,$37,$42,$2F,$25         ; $5FBB  してほしい
    db $99                         ; $5FC0  ！
    db $F7                         ; $5FC1  clear page
    db $F0                         ; $5FC2  end of message


; --------------------------------------------------------------------------
; Message #103 ($5FC3)
;   「おや？　こんなところに
;   こどもが　まぎれこんでおる。
;   「おうさまと　あそんでいたか？
;   わしは　マルタのくにの　おうだ。
; --------------------------------------------------------------------------
Bank67_Msg103:                             ; $5FC3  (file $10DFC3)
    db $EA                         ; $5FC3  ▶ new page
    db $9F                         ; $5FC4  box tag
    db $96                         ; $5FC5  end name/box tag
    db $28,$48                     ; $5FC6  おや
    db $98                         ; $5FC8  ？
    db $90                         ; $5FC9  　(space)
    db $2D,$55,$39,$38,$2D,$52,$3A ; $5FCA  こんなところに
    db $EF,$EE                     ; $5FD1  newline
    db $90,$90                     ; $5FD3  　　(indent)
    db $2D,$38,$8D,$47,$29,$8D     ; $5FD5  こと゛もか゛ = こどもが
    db $90                         ; $5FDB  　(space)
    db $43,$2A,$8D,$51,$2D,$55,$37,$8D,$28,$50; $5FDC  まき゛れこんて゛おる = まぎれこんでおる
    db $8F                         ; $5FE6  。
    db $FA                         ; $5FE7  wait-for-button
    db $F7                         ; $5FE8  clear page
    db $EF,$EE                     ; $5FE9  newline
    db $9F                         ; $5FEB  box tag
    db $96                         ; $5FEC  end name/box tag
    db $28,$26,$2E,$43,$38         ; $5FED  おうさまと
    db $90                         ; $5FF2  　(space)
    db $24,$32,$55,$37,$8D,$25,$33,$29; $5FF3  あそんて゛いたか = あそんでいたか
    db $98                         ; $5FFB  ？
    db $EF,$EE                     ; $5FFC  newline
    db $90,$90                     ; $5FFE  　　(indent)
    db $53,$2F,$3E                 ; $6000  わしは
    db $90                         ; $6003  　(space)
    db $7A,$87,$6A,$3D,$2B,$3A,$3D ; $6004  マルタのくにの
    db $90                         ; $600B  　(space)
    db $28,$26,$33,$8D             ; $600C  おうた゛ = おうだ
    db $8F                         ; $6010  。
    db $F7                         ; $6011  clear page
    db $F0                         ; $6012  end of message


; --------------------------------------------------------------------------
; Message #104 ($6013)
;   マルタおう「タィジャおうよ。
;   ほしふりのよるが　たのしみだな。
;   マルタおう「ハーッハッハッハッハ！
; --------------------------------------------------------------------------
Bank67_Msg104:                             ; $6013  (file $10E013)
    db $EA                         ; $6013  ▶ new page
    db $7A,$87,$6A,$28,$26         ; $6014  マルタおう
    db $96                         ; $6019  end name/box tag
    db $6A,$58,$66,$8D,$82,$28,$26,$4C; $601A  タィシ゛ャおうよ = タィジャおうよ
    db $8F                         ; $6022  。
    db $EF,$EE                     ; $6023  newline
    db $90,$90                     ; $6025  　　(indent)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$29,$8D; $6027  ほしふりのよるか゛ = ほしふりのよるが
    db $90                         ; $6030  　(space)
    db $33,$3D,$2F,$44,$33,$8D,$39 ; $6031  たのしみた゛な = たのしみだな
    db $8F                         ; $6038  。
    db $FA                         ; $6039  wait-for-button
    db $F7                         ; $603A  clear page
    db $EF,$EE                     ; $603B  newline
    db $7A,$87,$6A,$28,$26         ; $603D  マルタおう
    db $96                         ; $6042  end name/box tag
    db $75,$9C,$6D,$75,$6D,$75,$6D,$75,$6D,$75; $6043  ハーッハッハッハッハ
    db $99                         ; $604D  ！
    db $EF,$EE                     ; $604E  newline
    db $F7                         ; $6050  clear page
    db $F0                         ; $6051  end of message


; --------------------------------------------------------------------------
; Message #105 ($6052)
;   おう「うぬ！　マルタのおうめ。
;   いまにみておれ[94][94]！！
;   おう「〈テリー〉！　これからも
;   いっそう　しょうじんせよ！
;   おう「まちびととまもりのへやを
;   ほうびとして　かいほうしよう。
;   おう「よりつよい　まものがおるから
;   かならずや　やくにたつであろう。
;   おう「わしは　いそがしい　みぶんゆえ
;   これにて　しつれいする！
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank67_Msg105:                             ; $6052  (file $10E052)
    db $EA                         ; $6052  ▶ new page
    db $28,$26                     ; $6053  おう  (speaker: おう)
    db $96                         ; $6055  end name/box tag
    db $26,$3B                     ; $6056  うぬ
    db $99                         ; $6058  ！
    db $90                         ; $6059  　(space)
    db $7A,$87,$6A,$3D,$28,$26,$46 ; $605A  マルタのおうめ
    db $8F                         ; $6061  。
    db $EF,$EE                     ; $6062  newline
    db $90,$90                     ; $6064  　　(indent)
    db $25,$43,$3A,$44,$37,$28,$51 ; $6066  いまにみておれ
    db $94                         ; $606D  small kana
    db $94                         ; $606E  small kana
    db $99                         ; $606F  ！
    db $99                         ; $6070  ！
    db $FA                         ; $6071  wait-for-button
    db $F7                         ; $6072  clear page
    db $EF,$EE                     ; $6073  newline
    db $28,$26                     ; $6075  おう  (speaker: おう)
    db $96                         ; $6077  end name/box tag
    db $F6                         ; $6078  «insert hero name»
    db $99                         ; $6079  ！
    db $90                         ; $607A  　(space)
    db $2D,$51,$29,$4E,$47         ; $607B  これからも
    db $EF,$EE                     ; $6080  newline
    db $90,$90                     ; $6082  　　(indent)
    db $25,$36,$32,$26             ; $6084  いっそう
    db $90                         ; $6088  　(space)
    db $2F,$4D,$26,$2F,$8D,$55,$31,$4C; $6089  しょうし゛んせよ = しょうじんせよ
    db $99                         ; $6091  ！
    db $FA                         ; $6092  wait-for-button
    db $F7                         ; $6093  clear page
    db $EF,$EE                     ; $6094  newline
    db $28,$26                     ; $6096  おう  (speaker: おう)
    db $96                         ; $6098  end name/box tag
    db $43,$34,$3F,$8D,$38,$38,$43,$47,$4F,$3D,$41,$48,$54; $6099  まちひ゛ととまもりのへやを = まちびととまもりのへやを
    db $EF,$EE                     ; $60A6  newline
    db $90,$90                     ; $60A8  　　(indent)
    db $42,$26,$3F,$8D,$38,$2F,$37 ; $60AA  ほうひ゛として = ほうびとして
    db $90                         ; $60B1  　(space)
    db $29,$25,$42,$26,$2F,$4C,$26 ; $60B2  かいほうしよう
    db $8F                         ; $60B9  。
    db $FA                         ; $60BA  wait-for-button
    db $F7                         ; $60BB  clear page
    db $EF,$EE                     ; $60BC  newline
    db $28,$26                     ; $60BE  おう  (speaker: おう)
    db $96                         ; $60C0  end name/box tag
    db $4C,$4F,$35,$4C,$25         ; $60C1  よりつよい
    db $90                         ; $60C6  　(space)
    db $43,$47,$3D,$29,$8D,$28,$50,$29,$4E; $60C7  まものか゛おるから = まものがおるから
    db $EF,$EE                     ; $60D0  newline
    db $90,$90                     ; $60D2  　　(indent)
    db $29,$39,$4E,$30,$8D,$48     ; $60D4  かならす゛や = かならずや
    db $90                         ; $60DA  　(space)
    db $48,$2B,$3A,$33,$35,$37,$8D,$24,$52,$26; $60DB  やくにたつて゛あろう = やくにたつであろう
    db $8F                         ; $60E5  。
    db $FA                         ; $60E6  wait-for-button
    db $F7                         ; $60E7  clear page
    db $EF,$EE                     ; $60E8  newline
    db $28,$26                     ; $60EA  おう  (speaker: おう)
    db $96                         ; $60EC  end name/box tag
    db $53,$2F,$3E                 ; $60ED  わしは
    db $90                         ; $60F0  　(space)
    db $25,$32,$29,$8D,$2F,$25     ; $60F1  いそか゛しい = いそがしい
    db $90                         ; $60F7  　(space)
    db $44,$40,$8D,$55,$4A,$27     ; $60F8  みふ゛んゆえ = みぶんゆえ
    db $EF,$EE                     ; $60FE  newline
    db $90,$90                     ; $6100  　　(indent)
    db $2D,$51,$3A,$37             ; $6102  これにて
    db $90                         ; $6106  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $6107  しつれいする
    db $99                         ; $610D  ！
    db $FA                         ; $610E  wait-for-button
    db $F7                         ; $610F  clear page
    db $EF,$EE                     ; $6110  newline
    db $28,$26                     ; $6112  おう  (speaker: おう)
    db $96                         ; $6114  end name/box tag
    db $58,$69                     ; $6115  ィソ
    db $90                         ; $6117  　(space)
    db $58,$69                     ; $6118  ィソ
    db $A4                         ; $611A  、
    db $90                         ; $611B  　(space)
    db $58,$69                     ; $611C  ィソ
    db $90                         ; $611E  　(space)
    db $58,$69                     ; $611F  ィソ
    db $A4                         ; $6121  、
    db $A4                         ; $6122  、
    db $8F                         ; $6123  。
    db $EF,$EE                     ; $6124  newline
    db $F7                         ; $6126  clear page
    db $F0                         ; $6127  end of message


; --------------------------------------------------------------------------
; Message #106 ($6128)
;   「まちびととまもりのへやは
;   たびのとびらのまに　ある。
;   「こんごは　かくとうじょうで
;   ラィバルに　かってゆくのだ。
;   「かくとうじょうで　わがくにの
;   だいひょうと　みとめられれば、
;   「ほしふりのよるの　たいかいに
;   しゅつじょうできるのだ！
; --------------------------------------------------------------------------
Bank67_Msg106:                             ; $6128  (file $10E128)
    db $EA                         ; $6128  ▶ new page
    db $9F                         ; $6129  box tag
    db $96                         ; $612A  end name/box tag
    db $43,$34,$3F,$8D,$38,$38,$43,$47,$4F,$3D,$41,$48,$3E; $612B  まちひ゛ととまもりのへやは = まちびととまもりのへやは
    db $EF,$EE                     ; $6138  newline
    db $90,$90                     ; $613A  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$3A; $613C  たひ゛のとひ゛らのまに = たびのとびらのまに
    db $90                         ; $6147  　(space)
    db $24,$50                     ; $6148  ある
    db $8F                         ; $614A  。
    db $FA                         ; $614B  wait-for-button
    db $F7                         ; $614C  clear page
    db $EF,$EE                     ; $614D  newline
    db $9F                         ; $614F  box tag
    db $96                         ; $6150  end name/box tag
    db $2D,$55,$2D,$8D,$3E         ; $6151  こんこ゛は = こんごは
    db $90                         ; $6156  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D; $6157  かくとうし゛ょうて゛ = かくとうじょうで
    db $EF,$EE                     ; $6161  newline
    db $90,$90                     ; $6163  　　(indent)
    db $85,$58,$75,$8D,$87,$3A     ; $6165  ラィハ゛ルに = ラィバルに
    db $90                         ; $616B  　(space)
    db $29,$36,$37,$4A,$2B,$3D,$33,$8D; $616C  かってゆくのた゛ = かってゆくのだ
    db $8F                         ; $6174  。
    db $FA                         ; $6175  wait-for-button
    db $F7                         ; $6176  clear page
    db $EF,$EE                     ; $6177  newline
    db $9F                         ; $6179  box tag
    db $96                         ; $617A  end name/box tag
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D; $617B  かくとうし゛ょうて゛ = かくとうじょうで
    db $90                         ; $6185  　(space)
    db $53,$29,$8D,$2B,$3A,$3D     ; $6186  わか゛くにの = わがくにの
    db $EF,$EE                     ; $618C  newline
    db $90,$90                     ; $618E  　　(indent)
    db $33,$8D,$25,$3F,$4D,$26,$38 ; $6190  た゛いひょうと = だいひょうと
    db $90                         ; $6197  　(space)
    db $44,$38,$46,$4E,$51,$51,$3E,$8D; $6198  みとめられれは゛ = みとめられれば
    db $A4                         ; $61A0  、
    db $FA                         ; $61A1  wait-for-button
    db $F7                         ; $61A2  clear page
    db $EF,$EE                     ; $61A3  newline
    db $9F                         ; $61A5  box tag
    db $96                         ; $61A6  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3D; $61A7  ほしふりのよるの
    db $90                         ; $61AF  　(space)
    db $33,$25,$29,$25,$3A         ; $61B0  たいかいに
    db $EF,$EE                     ; $61B5  newline
    db $90,$90                     ; $61B7  　　(indent)
    db $2F,$4B,$35,$2F,$8D,$4D,$26,$37,$8D,$2A,$50,$3D,$33,$8D; $61B9  しゅつし゛ょうて゛きるのた゛ = しゅつじょうできるのだ
    db $99                         ; $61C7  ！
    db $F7                         ; $61C8  clear page
    db $F0                         ; $61C9  end of message


; --------------------------------------------------------------------------
; Message #107 ($61CA)
;   おう「おお　〈テリー〉よ！　ドラゴンを
;   たおしてまいったか！
;   おう「おぬし　みかけによらず
;   なかなか　やるではないか！
;   おう「たびのとびらには　まものが
;   [01][00][00]まんしゅるいほど　おる。
; --------------------------------------------------------------------------
Bank67_Msg107:                             ; $61CA  (file $10E1CA)
    db $EA                         ; $61CA  ▶ new page
    db $28,$26                     ; $61CB  おう  (speaker: おう)
    db $96                         ; $61CD  end name/box tag
    db $28,$28                     ; $61CE  おお
    db $90                         ; $61D0  　(space)
    db $F6                         ; $61D1  «insert hero name»
    db $4C                         ; $61D2  よ
    db $99                         ; $61D3  ！
    db $90                         ; $61D4  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$54 ; $61D5  ト゛ラコ゛ンを = ドラゴンを
    db $EF,$EE                     ; $61DC  newline
    db $90,$90                     ; $61DE  　　(indent)
    db $33,$28,$2F,$37,$43,$25,$36,$33,$29; $61E0  たおしてまいったか
    db $99                         ; $61E9  ！
    db $FA                         ; $61EA  wait-for-button
    db $F7                         ; $61EB  clear page
    db $EF,$EE                     ; $61EC  newline
    db $28,$26                     ; $61EE  おう  (speaker: おう)
    db $96                         ; $61F0  end name/box tag
    db $28,$3B,$2F                 ; $61F1  おぬし
    db $90                         ; $61F4  　(space)
    db $44,$29,$2C,$3A,$4C,$4E,$30,$8D; $61F5  みかけによらす゛ = みかけによらず
    db $EF,$EE                     ; $61FD  newline
    db $90,$90                     ; $61FF  　　(indent)
    db $39,$29,$39,$29             ; $6201  なかなか
    db $90                         ; $6205  　(space)
    db $48,$50,$37,$8D,$3E,$39,$25,$29; $6206  やるて゛はないか = やるではないか
    db $99                         ; $620E  ！
    db $FA                         ; $620F  wait-for-button
    db $F7                         ; $6210  clear page
    db $EF,$EE                     ; $6211  newline
    db $28,$26                     ; $6213  おう  (speaker: おう)
    db $96                         ; $6215  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A,$3E; $6216  たひ゛のとひ゛らには = たびのとびらには
    db $90                         ; $6220  　(space)
    db $43,$47,$3D,$29,$8D         ; $6221  まものか゛ = まものが
    db $EF,$EE                     ; $6226  newline
    db $90,$90                     ; $6228  　　(indent)
    db $01                         ; $622A  ctrl $01
    db $00                         ; $622B  ctrl $00
    db $00                         ; $622C  ctrl $00
    db $43,$55,$2F,$4B,$50,$25,$42,$38,$8D; $622D  まんしゅるいほと゛ = まんしゅるいほど
    db $90                         ; $6236  　(space)
    db $28,$50                     ; $6237  おる
    db $8F                         ; $6239  。
    db $F7                         ; $623A  clear page
    db $F0                         ; $623B  end of message


; --------------------------------------------------------------------------
; Message #108 ($623C)
;   おう「おお！　ちと　いいすぎたか。
;   、こんごも　たのむぞ　〈テリー〉！
;   おう「あずかりじょや　としょかんを
;   おおいに　かつようするがよい。
;   おう「、それでは　いそがしいので
;   わしは　しつれいする！
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank67_Msg108:                             ; $623C  (file $10E23C)
    db $EA                         ; $623C  ▶ new page
    db $28,$26                     ; $623D  おう  (speaker: おう)
    db $96                         ; $623F  end name/box tag
    db $28,$28                     ; $6240  おお
    db $99                         ; $6242  ！
    db $90                         ; $6243  　(space)
    db $34,$38                     ; $6244  ちと
    db $90                         ; $6246  　(space)
    db $25,$25,$30,$2A,$8D,$33,$29 ; $6247  いいすき゛たか = いいすぎたか
    db $8F                         ; $624E  。
    db $EF,$EE                     ; $624F  newline
    db $90,$90                     ; $6251  　　(indent)
    db $A4                         ; $6253  、
    db $2D,$55,$2D,$8D,$47         ; $6254  こんこ゛も = こんごも
    db $90                         ; $6259  　(space)
    db $33,$3D,$45,$32,$8D         ; $625A  たのむそ゛ = たのむぞ
    db $90                         ; $625F  　(space)
    db $F6                         ; $6260  «insert hero name»
    db $99                         ; $6261  ！
    db $FA                         ; $6262  wait-for-button
    db $F7                         ; $6263  clear page
    db $EF,$EE                     ; $6264  newline
    db $28,$26                     ; $6266  おう  (speaker: おう)
    db $96                         ; $6268  end name/box tag
    db $24,$30,$8D,$29,$4F,$2F,$8D,$4D,$48; $6269  あす゛かりし゛ょや = あずかりじょや
    db $90                         ; $6272  　(space)
    db $38,$2F,$4D,$29,$55,$54     ; $6273  としょかんを
    db $EF,$EE                     ; $6279  newline
    db $90,$90                     ; $627B  　　(indent)
    db $28,$28,$25,$3A             ; $627D  おおいに
    db $90                         ; $6281  　(space)
    db $29,$35,$4C,$26,$30,$50,$29,$8D,$4C,$25; $6282  かつようするか゛よい = かつようするがよい
    db $8F                         ; $628C  。
    db $FA                         ; $628D  wait-for-button
    db $F7                         ; $628E  clear page
    db $EF,$EE                     ; $628F  newline
    db $28,$26                     ; $6291  おう  (speaker: おう)
    db $96                         ; $6293  end name/box tag
    db $A4                         ; $6294  、
    db $32,$51,$37,$8D,$3E         ; $6295  それて゛は = それでは
    db $90                         ; $629A  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $629B  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $62A4  newline
    db $90,$90                     ; $62A6  　　(indent)
    db $53,$2F,$3E                 ; $62A8  わしは
    db $90                         ; $62AB  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $62AC  しつれいする
    db $99                         ; $62B2  ！
    db $FA                         ; $62B3  wait-for-button
    db $F7                         ; $62B4  clear page
    db $EF,$EE                     ; $62B5  newline
    db $28,$26                     ; $62B7  おう  (speaker: おう)
    db $96                         ; $62B9  end name/box tag
    db $58,$69                     ; $62BA  ィソ
    db $90                         ; $62BC  　(space)
    db $58,$69                     ; $62BD  ィソ
    db $A4                         ; $62BF  、
    db $90                         ; $62C0  　(space)
    db $58,$69                     ; $62C1  ィソ
    db $90                         ; $62C3  　(space)
    db $58,$69                     ; $62C4  ィソ
    db $A4                         ; $62C6  、
    db $A4                         ; $62C7  、
    db $8F                         ; $62C8  。
    db $EF,$EE                     ; $62C9  newline
    db $F7                         ; $62CB  clear page
    db $F0                         ; $62CC  end of message


; --------------------------------------------------------------------------
; Message #109 ($62CD)
;   〈テリー〉は　にっきを
;   ほんだなに　もどした。
; --------------------------------------------------------------------------
Bank67_Msg109:                             ; $62CD  (file $10E2CD)
    db $F6                         ; $62CD  «insert hero name»
    db $3E                         ; $62CE  は
    db $90                         ; $62CF  　(space)
    db $3A,$36,$2A,$54             ; $62D0  にっきを
    db $EF,$EE                     ; $62D4  newline
    db $42,$55,$33,$8D,$39,$3A     ; $62D6  ほんた゛なに = ほんだなに
    db $90                         ; $62DC  　(space)
    db $47,$38,$8D,$2F,$33         ; $62DD  もと゛した = もどした
    db $8F                         ; $62E2  。
    db $F7                         ; $62E3  clear page
    db $F0                         ; $62E4  end of message


; --------------------------------------------------------------------------
; Message #110 ($62E5)
;   おう「おお　〈テリー〉よ！
;   マネマネを　たおしたか！
;   おう「マネマネは　いろんなものの
;   まねをするのが　すきらしいな。
;   おう「だが　わしの　びだんしぶりは
;   だれにも　まねできまい！
; --------------------------------------------------------------------------
Bank67_Msg110:                             ; $62E5  (file $10E2E5)
    db $EA                         ; $62E5  ▶ new page
    db $28,$26                     ; $62E6  おう  (speaker: おう)
    db $96                         ; $62E8  end name/box tag
    db $28,$28                     ; $62E9  おお
    db $90                         ; $62EB  　(space)
    db $F6                         ; $62EC  «insert hero name»
    db $4C                         ; $62ED  よ
    db $99                         ; $62EE  ！
    db $EF,$EE                     ; $62EF  newline
    db $90,$90                     ; $62F1  　　(indent)
    db $7A,$73,$7A,$73,$54         ; $62F3  マネマネを
    db $90                         ; $62F8  　(space)
    db $33,$28,$2F,$33,$29         ; $62F9  たおしたか
    db $99                         ; $62FE  ！
    db $FA                         ; $62FF  wait-for-button
    db $F7                         ; $6300  clear page
    db $EF,$EE                     ; $6301  newline
    db $28,$26                     ; $6303  おう  (speaker: おう)
    db $96                         ; $6305  end name/box tag
    db $7A,$73,$7A,$73,$3E         ; $6306  マネマネは
    db $90                         ; $630B  　(space)
    db $25,$52,$55,$39,$47,$3D,$3D ; $630C  いろんなものの
    db $EF,$EE                     ; $6313  newline
    db $90,$90                     ; $6315  　　(indent)
    db $43,$3C,$54,$30,$50,$3D,$29,$8D; $6317  まねをするのか゛ = まねをするのが
    db $90                         ; $631F  　(space)
    db $30,$2A,$4E,$2F,$25,$39     ; $6320  すきらしいな
    db $8F                         ; $6326  。
    db $FA                         ; $6327  wait-for-button
    db $F7                         ; $6328  clear page
    db $EF,$EE                     ; $6329  newline
    db $28,$26                     ; $632B  おう  (speaker: おう)
    db $96                         ; $632D  end name/box tag
    db $33,$8D,$29,$8D             ; $632E  た゛か゛ = だが
    db $90                         ; $6332  　(space)
    db $53,$2F,$3D                 ; $6333  わしの
    db $90                         ; $6336  　(space)
    db $3F,$8D,$33,$8D,$55,$2F,$40,$8D,$4F,$3E; $6337  ひ゛た゛んしふ゛りは = びだんしぶりは
    db $EF,$EE                     ; $6341  newline
    db $90,$90                     ; $6343  　　(indent)
    db $33,$8D,$51,$3A,$47         ; $6345  た゛れにも = だれにも
    db $90                         ; $634A  　(space)
    db $43,$3C,$37,$8D,$2A,$43,$25 ; $634B  まねて゛きまい = まねできまい
    db $99                         ; $6352  ！
    db $F7                         ; $6353  clear page
    db $F0                         ; $6354  end of message


; --------------------------------------------------------------------------
; Message #111 ($6355)
;   おう「おお　〈テリー〉よ！　ゴーレムを
;   たおしてまいったか！
;   おう「その　ちいさなからだで
;   よく　たおしたものよっ！
;   おう「たびのとびらには　まものが
;   [01][00][00]まんしゅるいほど　おる。
; --------------------------------------------------------------------------
Bank67_Msg111:                             ; $6355  (file $10E355)
    db $EA                         ; $6355  ▶ new page
    db $28,$26                     ; $6356  おう  (speaker: おう)
    db $96                         ; $6358  end name/box tag
    db $28,$28                     ; $6359  おお
    db $90                         ; $635B  　(space)
    db $F6                         ; $635C  «insert hero name»
    db $4C                         ; $635D  よ
    db $99                         ; $635E  ！
    db $90                         ; $635F  　(space)
    db $64,$8D,$9C,$88,$7C,$54     ; $6360  コ゛ーレムを = ゴーレムを
    db $EF,$EE                     ; $6366  newline
    db $90,$90                     ; $6368  　　(indent)
    db $33,$28,$2F,$37,$43,$25,$36,$33,$29; $636A  たおしてまいったか
    db $99                         ; $6373  ！
    db $FA                         ; $6374  wait-for-button
    db $F7                         ; $6375  clear page
    db $EF,$EE                     ; $6376  newline
    db $28,$26                     ; $6378  おう  (speaker: おう)
    db $96                         ; $637A  end name/box tag
    db $32,$3D                     ; $637B  その
    db $90                         ; $637D  　(space)
    db $34,$25,$2E,$39,$29,$4E,$33,$8D,$37,$8D; $637E  ちいさなからた゛て゛ = ちいさなからだで
    db $EF,$EE                     ; $6388  newline
    db $90,$90                     ; $638A  　　(indent)
    db $4C,$2B                     ; $638C  よく
    db $90                         ; $638E  　(space)
    db $33,$28,$2F,$33,$47,$3D,$4C,$36; $638F  たおしたものよっ
    db $99                         ; $6397  ！
    db $FA                         ; $6398  wait-for-button
    db $F7                         ; $6399  clear page
    db $EF,$EE                     ; $639A  newline
    db $28,$26                     ; $639C  おう  (speaker: おう)
    db $96                         ; $639E  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A,$3E; $639F  たひ゛のとひ゛らには = たびのとびらには
    db $90                         ; $63A9  　(space)
    db $43,$47,$3D,$29,$8D         ; $63AA  まものか゛ = まものが
    db $EF,$EE                     ; $63AF  newline
    db $90,$90                     ; $63B1  　　(indent)
    db $01                         ; $63B3  ctrl $01
    db $00                         ; $63B4  ctrl $00
    db $00                         ; $63B5  ctrl $00
    db $43,$55,$2F,$4B,$50,$25,$42,$38,$8D; $63B6  まんしゅるいほと゛ = まんしゅるいほど
    db $90                         ; $63BF  　(space)
    db $28,$50                     ; $63C0  おる
    db $8F                         ; $63C2  。
    db $F7                         ; $63C3  clear page
    db $F0                         ; $63C4  end of message


; --------------------------------------------------------------------------
; Message #112 ($63C5)
;   「まちびとの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg112:                             ; $63C5  (file $10E3C5)
    db $EB                         ; $63C5  ▶ new page
    db $9F                         ; $63C6  box tag
    db $96                         ; $63C7  end name/box tag
    db $43,$34,$3F,$8D,$38,$3D     ; $63C8  まちひ゛との = まちびとの
    db $90                         ; $63CE  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $63CF  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $63D7  newline
    db $90,$90                     ; $63D9  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $63DB  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $63E6  ？
    db $FF                         ; $63E7  はい/いいえ
    db $F0                         ; $63E8  end of message


; --------------------------------------------------------------------------
; Message #113 ($63E9)
;   「ドラゴンは　おんなずき。
;   ひめさま　さらって　あとしらぬ。
;   「、、ふるい　いこくの
;   わらべうたです。
; --------------------------------------------------------------------------
Bank67_Msg113:                             ; $63E9  (file $10E3E9)
    db $EB                         ; $63E9  ▶ new page
    db $9F                         ; $63EA  box tag
    db $96                         ; $63EB  end name/box tag
    db $6F,$8D,$85,$64,$8D,$8C,$3E ; $63EC  ト゛ラコ゛ンは = ドラゴンは
    db $90                         ; $63F3  　(space)
    db $28,$55,$39,$30,$8D,$2A     ; $63F4  おんなす゛き = おんなずき
    db $8F                         ; $63FA  。
    db $EF,$EE                     ; $63FB  newline
    db $90,$90                     ; $63FD  　　(indent)
    db $3F,$46,$2E,$43             ; $63FF  ひめさま
    db $90                         ; $6403  　(space)
    db $2E,$4E,$36,$37             ; $6404  さらって
    db $90                         ; $6408  　(space)
    db $24,$38,$2F,$4E,$3B         ; $6409  あとしらぬ
    db $8F                         ; $640E  。
    db $FA                         ; $640F  wait-for-button
    db $F7                         ; $6410  clear page
    db $EF,$EE                     ; $6411  newline
    db $9F                         ; $6413  box tag
    db $96                         ; $6414  end name/box tag
    db $A4                         ; $6415  、
    db $A4                         ; $6416  、
    db $40,$50,$25                 ; $6417  ふるい
    db $90                         ; $641A  　(space)
    db $25,$2D,$2B,$3D             ; $641B  いこくの
    db $EF,$EE                     ; $641F  newline
    db $90,$90                     ; $6421  　　(indent)
    db $53,$4E,$41,$8D,$26,$33,$37,$8D,$30; $6423  わらへ゛うたて゛す = わらべうたです
    db $8F                         ; $642C  。
    db $F7                         ; $642D  clear page
    db $F0                         ; $642E  end of message


; --------------------------------------------------------------------------
; Message #114 ($642F)
;   「まもりの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg114:                             ; $642F  (file $10E42F)
    db $EB                         ; $642F  ▶ new page
    db $9F                         ; $6430  box tag
    db $96                         ; $6431  end name/box tag
    db $43,$47,$4F,$3D             ; $6432  まもりの
    db $90                         ; $6436  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $6437  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $643F  newline
    db $90,$90                     ; $6441  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $6443  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $644E  ？
    db $FF                         ; $644F  はい/いいえ
    db $F0                         ; $6450  end of message


; --------------------------------------------------------------------------
; Message #115 ($6451)
;   「そうですか。
;   、、、は[91]。
; --------------------------------------------------------------------------
Bank67_Msg115:                             ; $6451  (file $10E451)
    db $EB                         ; $6451  ▶ new page
    db $9F                         ; $6452  box tag
    db $96                         ; $6453  end name/box tag
    db $32,$26,$37,$8D,$30,$29     ; $6454  そうて゛すか = そうですか
    db $8F                         ; $645A  。
    db $EF,$EE                     ; $645B  newline
    db $90,$90                     ; $645D  　　(indent)
    db $A4                         ; $645F  、
    db $A4                         ; $6460  、
    db $A4                         ; $6461  、
    db $3E                         ; $6462  は
    db $91                         ; $6463  ctrl $91
    db $8F                         ; $6464  。
    db $F7                         ; $6465  clear page
    db $F0                         ; $6466  end of message


; --------------------------------------------------------------------------
; Message #116 ($6467)
;   「ふえのねで　ねむってしまった
;   いしのばんにんは　やまになった。
;   「、あるまちの　ふるくて　たかい
;   かべにしるされた　らくがきです。
; --------------------------------------------------------------------------
Bank67_Msg116:                             ; $6467  (file $10E467)
    db $EB                         ; $6467  ▶ new page
    db $9F                         ; $6468  box tag
    db $96                         ; $6469  end name/box tag
    db $40,$27,$3D,$3C,$37,$8D     ; $646A  ふえのねて゛ = ふえのねで
    db $90                         ; $6470  　(space)
    db $3C,$45,$36,$37,$2F,$43,$36,$33; $6471  ねむってしまった
    db $EF,$EE                     ; $6479  newline
    db $90,$90                     ; $647B  　　(indent)
    db $25,$2F,$3D,$3E,$8D,$55,$3A,$55,$3E; $647D  いしのは゛んにんは = いしのばんにんは
    db $90                         ; $6486  　(space)
    db $48,$43,$3A,$39,$36,$33     ; $6487  やまになった
    db $8F                         ; $648D  。
    db $FA                         ; $648E  wait-for-button
    db $F7                         ; $648F  clear page
    db $EF,$EE                     ; $6490  newline
    db $9F                         ; $6492  box tag
    db $96                         ; $6493  end name/box tag
    db $A4                         ; $6494  、
    db $24,$50,$43,$34,$3D         ; $6495  あるまちの
    db $90                         ; $649A  　(space)
    db $40,$50,$2B,$37             ; $649B  ふるくて
    db $90                         ; $649F  　(space)
    db $33,$29,$25                 ; $64A0  たかい
    db $EF,$EE                     ; $64A3  newline
    db $90,$90                     ; $64A5  　　(indent)
    db $29,$41,$8D,$3A,$2F,$50,$2E,$51,$33; $64A7  かへ゛にしるされた = かべにしるされた
    db $90                         ; $64B0  　(space)
    db $4E,$2B,$29,$8D,$2A,$37,$8D,$30; $64B1  らくか゛きて゛す = らくがきです
    db $8F                         ; $64B9  。
    db $F7                         ; $64BA  clear page
    db $F0                         ; $64BB  end of message


; --------------------------------------------------------------------------
; Message #117 ($64BC)
;   「なんだよ　てめーは！
;   え？　マスターなのか？
;   「よわそうな　やつだな。
;   ここからは　とおしてやらないっ！
; --------------------------------------------------------------------------
Bank67_Msg117:                             ; $64BC  (file $10E4BC)
    db $EB                         ; $64BC  ▶ new page
    db $9F                         ; $64BD  box tag
    db $96                         ; $64BE  end name/box tag
    db $39,$55,$33,$8D,$4C         ; $64BF  なんた゛よ = なんだよ
    db $90                         ; $64C4  　(space)
    db $37,$46,$9C,$3E             ; $64C5  てめーは
    db $99                         ; $64C9  ！
    db $EF,$EE                     ; $64CA  newline
    db $90,$90                     ; $64CC  　　(indent)
    db $27                         ; $64CE  え
    db $98                         ; $64CF  ？
    db $90                         ; $64D0  　(space)
    db $7A,$67,$6A,$9C,$39,$3D,$29 ; $64D1  マスターなのか
    db $98                         ; $64D8  ？
    db $FA                         ; $64D9  wait-for-button
    db $F7                         ; $64DA  clear page
    db $EF,$EE                     ; $64DB  newline
    db $9F                         ; $64DD  box tag
    db $96                         ; $64DE  end name/box tag
    db $4C,$53,$32,$26,$39         ; $64DF  よわそうな
    db $90                         ; $64E4  　(space)
    db $48,$35,$33,$8D,$39         ; $64E5  やつた゛な = やつだな
    db $8F                         ; $64EA  。
    db $EF,$EE                     ; $64EB  newline
    db $90,$90                     ; $64ED  　　(indent)
    db $2D,$2D,$29,$4E,$3E         ; $64EF  ここからは
    db $90                         ; $64F4  　(space)
    db $38,$28,$2F,$37,$48,$4E,$39,$25,$36; $64F5  とおしてやらないっ
    db $99                         ; $64FE  ！
    db $F7                         ; $64FF  clear page
    db $F0                         ; $6500  end of message


; --------------------------------------------------------------------------
; Message #118 ($6501)
;   「さあ　いちばんしたまで
;   あとひといきだ！
;   「したには　いったい
;   なにがあるのかな？
; --------------------------------------------------------------------------
Bank67_Msg118:                             ; $6501  (file $10E501)
    db $EA                         ; $6501  ▶ new page
    db $9F                         ; $6502  box tag
    db $96                         ; $6503  end name/box tag
    db $2E,$24                     ; $6504  さあ
    db $90                         ; $6506  　(space)
    db $25,$34,$3E,$8D,$55,$2F,$33,$43,$37,$8D; $6507  いちは゛んしたまて゛ = いちばんしたまで
    db $EF,$EE                     ; $6511  newline
    db $90,$90                     ; $6513  　　(indent)
    db $24,$38,$3F,$38,$25,$2A,$33,$8D; $6515  あとひといきた゛ = あとひといきだ
    db $99                         ; $651D  ！
    db $FA                         ; $651E  wait-for-button
    db $F7                         ; $651F  clear page
    db $EF,$EE                     ; $6520  newline
    db $9F                         ; $6522  box tag
    db $96                         ; $6523  end name/box tag
    db $2F,$33,$3A,$3E             ; $6524  したには
    db $90                         ; $6528  　(space)
    db $25,$36,$33,$25             ; $6529  いったい
    db $EF,$EE                     ; $652D  newline
    db $90,$90                     ; $652F  　　(indent)
    db $39,$3A,$29,$8D,$24,$50,$3D,$29,$39; $6531  なにか゛あるのかな = なにがあるのかな
    db $98                         ; $653A  ？
    db $F7                         ; $653B  clear page
    db $F0                         ; $653C  end of message


; --------------------------------------------------------------------------
; Message #119 ($653D)
;   「げんかいまで　せいちょうすると
;   つよさに　[AC]が　つくらしい、。
;   「としょかんで　かりたほんに
;   かかれてたが　なんのことだろ？
; --------------------------------------------------------------------------
Bank67_Msg119:                             ; $653D  (file $10E53D)
    db $EA                         ; $653D  ▶ new page
    db $9F                         ; $653E  box tag
    db $96                         ; $653F  end name/box tag
    db $2C,$8D,$55,$29,$25,$43,$37,$8D; $6540  け゛んかいまて゛ = げんかいまで
    db $90                         ; $6548  　(space)
    db $31,$25,$34,$4D,$26,$30,$50,$38; $6549  せいちょうすると
    db $EF,$EE                     ; $6551  newline
    db $90,$90                     ; $6553  　　(indent)
    db $35,$4C,$2E,$3A             ; $6555  つよさに
    db $90                         ; $6559  　(space)
    db $AC                         ; $655A  ctrl $AC
    db $29,$8D                     ; $655B  か゛ = が
    db $90                         ; $655D  　(space)
    db $35,$2B,$4E,$2F,$25         ; $655E  つくらしい
    db $A4                         ; $6563  、
    db $8F                         ; $6564  。
    db $FA                         ; $6565  wait-for-button
    db $F7                         ; $6566  clear page
    db $EF,$EE                     ; $6567  newline
    db $9F                         ; $6569  box tag
    db $96                         ; $656A  end name/box tag
    db $38,$2F,$4D,$29,$55,$37,$8D ; $656B  としょかんて゛ = としょかんで
    db $90                         ; $6572  　(space)
    db $29,$4F,$33,$42,$55,$3A     ; $6573  かりたほんに
    db $EF,$EE                     ; $6579  newline
    db $90,$90                     ; $657B  　　(indent)
    db $29,$29,$51,$37,$33,$29,$8D ; $657D  かかれてたか゛ = かかれてたが
    db $90                         ; $6584  　(space)
    db $39,$55,$3D,$2D,$38,$33,$8D,$52; $6585  なんのことた゛ろ = なんのことだろ
    db $98                         ; $658D  ？
    db $F7                         ; $658E  clear page
    db $F0                         ; $658F  end of message


; --------------------------------------------------------------------------
; Message #120 ($6590)
;   「このなかは　あずかりじょです。
; --------------------------------------------------------------------------
Bank67_Msg120:                             ; $6590  (file $10E590)
    db $EA                         ; $6590  ▶ new page
    db $9F                         ; $6591  box tag
    db $96                         ; $6592  end name/box tag
    db $2D,$3D,$39,$29,$3E         ; $6593  このなかは
    db $90                         ; $6598  　(space)
    db $24,$30,$8D,$29,$4F,$2F,$8D,$4D,$37,$8D,$30; $6599  あす゛かりし゛ょて゛す = あずかりじょです
    db $8F                         ; $65A4  。
    db $EF,$EE                     ; $65A5  newline
    db $F7                         ; $65A7  clear page
    db $F0                         ; $65A8  end of message


; --------------------------------------------------------------------------
; Message #121 ($65A9)
;   「みぎにいけば　バザーかいじょう
;   だよーー！！
; --------------------------------------------------------------------------
Bank67_Msg121:                             ; $65A9  (file $10E5A9)
    db $EB                         ; $65A9  ▶ new page
    db $9F                         ; $65AA  box tag
    db $96                         ; $65AB  end name/box tag
    db $44,$2A,$8D,$3A,$25,$2C,$3E,$8D; $65AC  みき゛にいけは゛ = みぎにいけば
    db $90                         ; $65B4  　(space)
    db $75,$8D,$65,$8D,$9C,$29,$25,$2F,$8D,$4D,$26; $65B5  ハ゛サ゛ーかいし゛ょう = バザーかいじょう
    db $EF,$EE                     ; $65C0  newline
    db $90,$90                     ; $65C2  　　(indent)
    db $33,$8D,$4C,$9C,$9C         ; $65C4  た゛よーー = だよーー
    db $99                         ; $65C9  ！
    db $99                         ; $65CA  ！
    db $F7                         ; $65CB  clear page
    db $F0                         ; $65CC  end of message


; --------------------------------------------------------------------------
; Message #122 ($65CD)
;   「こんにちは　バザーかいじょうへ
;   ようこそ！
; --------------------------------------------------------------------------
Bank67_Msg122:                             ; $65CD  (file $10E5CD)
    db $EB                         ; $65CD  ▶ new page
    db $9F                         ; $65CE  box tag
    db $96                         ; $65CF  end name/box tag
    db $2D,$55,$3A,$34,$3E         ; $65D0  こんにちは
    db $90                         ; $65D5  　(space)
    db $75,$8D,$65,$8D,$9C,$29,$25,$2F,$8D,$4D,$26,$41; $65D6  ハ゛サ゛ーかいし゛ょうへ = バザーかいじょうへ
    db $EF,$EE                     ; $65E2  newline
    db $90,$90                     ; $65E4  　　(indent)
    db $4C,$26,$2D,$32             ; $65E6  ようこそ
    db $99                         ; $65EA  ！
    db $F7                         ; $65EB  clear page
    db $F0                         ; $65EC  end of message


; --------------------------------------------------------------------------
; Message #123 ($65ED)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   しかし　なにもなかった。
; --------------------------------------------------------------------------
Bank67_Msg123:                             ; $65ED  (file $10E5ED)
    db $F6                         ; $65ED  «insert hero name»
    db $3E                         ; $65EE  は
    db $90                         ; $65EF  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $65F0  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $65F7  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $65F9  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $6601  。
    db $FA                         ; $6602  wait-for-button
    db $F7                         ; $6603  clear page
    db $EF,$EE                     ; $6604  newline
    db $2F,$29,$2F                 ; $6606  しかし
    db $90                         ; $6609  　(space)
    db $39,$3A,$47,$39,$29,$36,$33 ; $660A  なにもなかった
    db $8F                         ; $6611  。
    db $EF,$EE                     ; $6612  newline
    db $F7                         ; $6614  clear page
    db $F0                         ; $6615  end of message


; --------------------------------------------------------------------------
; Message #124 ($6616)
;   〈テリー〉は　ツボのなかを
;   のぞきこんだ。
;   なかには　どうぐやの　うりものが
;   いっぱい　つまっている。
; --------------------------------------------------------------------------
Bank67_Msg124:                             ; $6616  (file $10E616)
    db $F6                         ; $6616  «insert hero name»
    db $3E                         ; $6617  は
    db $90                         ; $6618  　(space)
    db $6C,$79,$8D,$3D,$39,$29,$54 ; $6619  ツホ゛のなかを = ツボのなかを
    db $EF,$EE                     ; $6620  newline
    db $3D,$32,$8D,$2A,$2D,$55,$33,$8D; $6622  のそ゛きこんた゛ = のぞきこんだ
    db $8F                         ; $662A  。
    db $FA                         ; $662B  wait-for-button
    db $F7                         ; $662C  clear page
    db $EF,$EE                     ; $662D  newline
    db $39,$29,$3A,$3E             ; $662F  なかには
    db $90                         ; $6633  　(space)
    db $38,$8D,$26,$2B,$8D,$48,$3D ; $6634  と゛うく゛やの = どうぐやの
    db $90                         ; $663B  　(space)
    db $26,$4F,$47,$3D,$29,$8D     ; $663C  うりものか゛ = うりものが
    db $EF,$EE                     ; $6642  newline
    db $25,$36,$3E,$8E,$25         ; $6644  いっは゜い = いっぱい
    db $90                         ; $6649  　(space)
    db $35,$43,$36,$37,$25,$50     ; $664A  つまっている
    db $8F                         ; $6650  。
    db $F7                         ; $6651  clear page
    db $F0                         ; $6652  end of message


; --------------------------------------------------------------------------
; Message #125 ($6653)
;   「うわさだと　ももんじゃのしっぽは
;   すごい　どうぐらしいわよ。
;   「たびのとびらで　あなのほうがくを
;   さししめして　くれるんですって！
;   「ぼうけんにでる　マスターは
;   みんな　もっていくそうよ。
;   「あなたも　ためしてみたら？
;   きっと　やくにたつわよ！
; --------------------------------------------------------------------------
Bank67_Msg125:                             ; $6653  (file $10E653)
    db $EB                         ; $6653  ▶ new page
    db $9F                         ; $6654  box tag
    db $96                         ; $6655  end name/box tag
    db $26,$53,$2E,$33,$8D,$38     ; $6656  うわさた゛と = うわさだと
    db $90                         ; $665C  　(space)
    db $47,$47,$55,$2F,$8D,$49,$3D,$2F,$36,$42,$8E,$3E; $665D  ももんし゛ゃのしっほ゜は = ももんじゃのしっぽは
    db $EF,$EE                     ; $6669  newline
    db $90,$90                     ; $666B  　　(indent)
    db $30,$2D,$8D,$25             ; $666D  すこ゛い = すごい
    db $90                         ; $6671  　(space)
    db $38,$8D,$26,$2B,$8D,$4E,$2F,$25,$53,$4C; $6672  と゛うく゛らしいわよ = どうぐらしいわよ
    db $8F                         ; $667C  。
    db $FA                         ; $667D  wait-for-button
    db $F7                         ; $667E  clear page
    db $EF,$EE                     ; $667F  newline
    db $9F                         ; $6681  box tag
    db $96                         ; $6682  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$37,$8D; $6683  たひ゛のとひ゛らて゛ = たびのとびらで
    db $90                         ; $668D  　(space)
    db $24,$39,$3D,$42,$26,$29,$8D,$2B,$54; $668E  あなのほうか゛くを = あなのほうがくを
    db $EF,$EE                     ; $6697  newline
    db $90,$90                     ; $6699  　　(indent)
    db $2E,$2F,$2F,$46,$2F,$37     ; $669B  さししめして
    db $90                         ; $66A1  　(space)
    db $2B,$51,$50,$55,$37,$8D,$30,$36,$37; $66A2  くれるんて゛すって = くれるんですって
    db $99                         ; $66AB  ！
    db $FA                         ; $66AC  wait-for-button
    db $F7                         ; $66AD  clear page
    db $EF,$EE                     ; $66AE  newline
    db $9F                         ; $66B0  box tag
    db $96                         ; $66B1  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A,$37,$8D,$50; $66B2  ほ゛うけんにて゛る = ぼうけんにでる
    db $90                         ; $66BB  　(space)
    db $7A,$67,$6A,$9C,$3E         ; $66BC  マスターは
    db $EF,$EE                     ; $66C1  newline
    db $90,$90                     ; $66C3  　　(indent)
    db $44,$55,$39                 ; $66C5  みんな
    db $90                         ; $66C8  　(space)
    db $47,$36,$37,$25,$2B,$32,$26,$4C; $66C9  もっていくそうよ
    db $8F                         ; $66D1  。
    db $FA                         ; $66D2  wait-for-button
    db $F7                         ; $66D3  clear page
    db $EF,$EE                     ; $66D4  newline
    db $9F                         ; $66D6  box tag
    db $96                         ; $66D7  end name/box tag
    db $24,$39,$33,$47             ; $66D8  あなたも
    db $90                         ; $66DC  　(space)
    db $33,$46,$2F,$37,$44,$33,$4E ; $66DD  ためしてみたら
    db $98                         ; $66E4  ？
    db $EF,$EE                     ; $66E5  newline
    db $90,$90                     ; $66E7  　　(indent)
    db $2A,$36,$38                 ; $66E9  きっと
    db $90                         ; $66EC  　(space)
    db $48,$2B,$3A,$33,$35,$53,$4C ; $66ED  やくにたつわよ
    db $99                         ; $66F4  ！
    db $F7                         ; $66F5  clear page
    db $F0                         ; $66F6  end of message


; --------------------------------------------------------------------------
; Message #126 ($66F7)
;   「いつも　このじきが　くると
;   たいかいのはなしで　もちきりよ。
;   「しかも　こんかいは　タィジャが
;   しゅさいこく！
;   「でも。　やっぱり　こんども
;   ゆうしょうは　むりでしょうね、。
; --------------------------------------------------------------------------
Bank67_Msg126:                             ; $66F7  (file $10E6F7)
    db $EB                         ; $66F7  ▶ new page
    db $9F                         ; $66F8  box tag
    db $96                         ; $66F9  end name/box tag
    db $25,$35,$47                 ; $66FA  いつも
    db $90                         ; $66FD  　(space)
    db $2D,$3D,$2F,$8D,$2A,$29,$8D ; $66FE  このし゛きか゛ = このじきが
    db $90                         ; $6705  　(space)
    db $2B,$50,$38                 ; $6706  くると
    db $EF,$EE                     ; $6709  newline
    db $90,$90                     ; $670B  　　(indent)
    db $33,$25,$29,$25,$3D,$3E,$39,$2F,$37,$8D; $670D  たいかいのはなして゛ = たいかいのはなしで
    db $90                         ; $6717  　(space)
    db $47,$34,$2A,$4F,$4C         ; $6718  もちきりよ
    db $8F                         ; $671D  。
    db $FA                         ; $671E  wait-for-button
    db $F7                         ; $671F  clear page
    db $EF,$EE                     ; $6720  newline
    db $9F                         ; $6722  box tag
    db $96                         ; $6723  end name/box tag
    db $2F,$29,$47                 ; $6724  しかも
    db $90                         ; $6727  　(space)
    db $2D,$55,$29,$25,$3E         ; $6728  こんかいは
    db $90                         ; $672D  　(space)
    db $6A,$58,$66,$8D,$82,$29,$8D ; $672E  タィシ゛ャか゛ = タィジャが
    db $EF,$EE                     ; $6735  newline
    db $90,$90                     ; $6737  　　(indent)
    db $2F,$4B,$2E,$25,$2D,$2B     ; $6739  しゅさいこく
    db $99                         ; $673F  ！
    db $FA                         ; $6740  wait-for-button
    db $F7                         ; $6741  clear page
    db $EF,$EE                     ; $6742  newline
    db $9F                         ; $6744  box tag
    db $96                         ; $6745  end name/box tag
    db $37,$8D,$47                 ; $6746  て゛も = でも
    db $8F                         ; $6749  。
    db $90                         ; $674A  　(space)
    db $48,$36,$3E,$8E,$4F         ; $674B  やっは゜り = やっぱり
    db $90                         ; $6750  　(space)
    db $2D,$55,$38,$8D,$47         ; $6751  こんと゛も = こんども
    db $EF,$EE                     ; $6756  newline
    db $90,$90                     ; $6758  　　(indent)
    db $4A,$26,$2F,$4D,$26,$3E     ; $675A  ゆうしょうは
    db $90                         ; $6760  　(space)
    db $45,$4F,$37,$8D,$2F,$4D,$26,$3C; $6761  むりて゛しょうね = むりでしょうね
    db $A4                         ; $6769  、
    db $8F                         ; $676A  。
    db $F7                         ; $676B  clear page
    db $F0                         ; $676C  end of message


; --------------------------------------------------------------------------
; Message #127 ($676D)
;   「まえの　ほしふりのよるには
;   ここにも　みせが　たってたよ。
; --------------------------------------------------------------------------
Bank67_Msg127:                             ; $676D  (file $10E76D)
    db $EB                         ; $676D  ▶ new page
    db $9F                         ; $676E  box tag
    db $96                         ; $676F  end name/box tag
    db $43,$27,$3D                 ; $6770  まえの
    db $90                         ; $6773  　(space)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A,$3E; $6774  ほしふりのよるには
    db $EF,$EE                     ; $677D  newline
    db $90,$90                     ; $677F  　　(indent)
    db $2D,$2D,$3A,$47             ; $6781  ここにも
    db $90                         ; $6785  　(space)
    db $44,$31,$29,$8D             ; $6786  みせか゛ = みせが
    db $90                         ; $678A  　(space)
    db $33,$36,$37,$33,$4C         ; $678B  たってたよ
    db $8F                         ; $6790  。
    db $F7                         ; $6791  clear page
    db $F0                         ; $6792  end of message


; --------------------------------------------------------------------------
; Message #128 ($6793)
;   「そこの　どうぐや　ひどいぜ。
;   なにも　うってくれないんだ。
; --------------------------------------------------------------------------
Bank67_Msg128:                             ; $6793  (file $10E793)
    db $EA                         ; $6793  ▶ new page
    db $9F                         ; $6794  box tag
    db $96                         ; $6795  end name/box tag
    db $32,$2D,$3D                 ; $6796  そこの
    db $90                         ; $6799  　(space)
    db $38,$8D,$26,$2B,$8D,$48     ; $679A  と゛うく゛や = どうぐや
    db $90                         ; $67A0  　(space)
    db $3F,$38,$8D,$25,$31,$8D     ; $67A1  ひと゛いせ゛ = ひどいぜ
    db $8F                         ; $67A7  。
    db $EF,$EE                     ; $67A8  newline
    db $90,$90                     ; $67AA  　　(indent)
    db $39,$3A,$47                 ; $67AC  なにも
    db $90                         ; $67AF  　(space)
    db $26,$36,$37,$2B,$51,$39,$25,$55,$33,$8D; $67B0  うってくれないんた゛ = うってくれないんだ
    db $8F                         ; $67BA  。
    db $F7                         ; $67BB  clear page
    db $F0                         ; $67BC  end of message


; --------------------------------------------------------------------------
; Message #129 ($67BD)
;   「きみ　マスター？
;   ただの　こどもだろ。
;   「きにいらないね[94]。
;   さあ　かえった　かえった！
; --------------------------------------------------------------------------
Bank67_Msg129:                             ; $67BD  (file $10E7BD)
    db $EA                         ; $67BD  ▶ new page
    db $9F                         ; $67BE  box tag
    db $96                         ; $67BF  end name/box tag
    db $2A,$44                     ; $67C0  きみ
    db $90                         ; $67C2  　(space)
    db $7A,$67,$6A,$9C             ; $67C3  マスター
    db $98                         ; $67C7  ？
    db $EF,$EE                     ; $67C8  newline
    db $90,$90                     ; $67CA  　　(indent)
    db $33,$33,$8D,$3D             ; $67CC  たた゛の = ただの
    db $90                         ; $67D0  　(space)
    db $2D,$38,$8D,$47,$33,$8D,$52 ; $67D1  こと゛もた゛ろ = こどもだろ
    db $8F                         ; $67D8  。
    db $FA                         ; $67D9  wait-for-button
    db $F7                         ; $67DA  clear page
    db $EF,$EE                     ; $67DB  newline
    db $9F                         ; $67DD  box tag
    db $96                         ; $67DE  end name/box tag
    db $2A,$3A,$25,$4E,$39,$25,$3C ; $67DF  きにいらないね
    db $94                         ; $67E6  small kana
    db $8F                         ; $67E7  。
    db $EF,$EE                     ; $67E8  newline
    db $90,$90                     ; $67EA  　　(indent)
    db $2E,$24                     ; $67EC  さあ
    db $90                         ; $67EE  　(space)
    db $29,$27,$36,$33             ; $67EF  かえった
    db $90                         ; $67F3  　(space)
    db $29,$27,$36,$33             ; $67F4  かえった
    db $99                         ; $67F8  ！
    db $F7                         ; $67F9  clear page
    db $F0                         ; $67FA  end of message


; --------------------------------------------------------------------------
; Message #130 ($67FB)
;   「おや？　どうぐをかう　おかねが
;   なくて　こまっていますね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg130:                             ; $67FB  (file $10E7FB)
    db $EA                         ; $67FB  ▶ new page
    db $9F                         ; $67FC  box tag
    db $96                         ; $67FD  end name/box tag
    db $28,$48                     ; $67FE  おや
    db $98                         ; $6800  ？
    db $90                         ; $6801  　(space)
    db $38,$8D,$26,$2B,$8D,$54,$29,$26; $6802  と゛うく゛をかう = どうぐをかう
    db $90                         ; $680A  　(space)
    db $28,$29,$3C,$29,$8D         ; $680B  おかねか゛ = おかねが
    db $EF,$EE                     ; $6810  newline
    db $90,$90                     ; $6812  　　(indent)
    db $39,$2B,$37                 ; $6814  なくて
    db $90                         ; $6817  　(space)
    db $2D,$43,$36,$37,$25,$43,$30,$3C; $6818  こまっていますね
    db $98                         ; $6820  ？
    db $FF                         ; $6821  はい/いいえ
    db $F0                         ; $6822  end of message


; --------------------------------------------------------------------------
; Message #131 ($6823)
;   〈テリー〉は　めのまえを　しらべた。
;   うまそうな　にくが　ならんでいる。
; --------------------------------------------------------------------------
Bank67_Msg131:                             ; $6823  (file $10E823)
    db $F6                         ; $6823  «insert hero name»
    db $3E                         ; $6824  は
    db $90                         ; $6825  　(space)
    db $46,$3D,$43,$27,$54         ; $6826  めのまえを
    db $90                         ; $682B  　(space)
    db $2F,$4E,$41,$8D,$33         ; $682C  しらへ゛た = しらべた
    db $8F                         ; $6831  。
    db $EF,$EE                     ; $6832  newline
    db $FA                         ; $6834  wait-for-button
    db $F7                         ; $6835  clear page
    db $EF,$EE                     ; $6836  newline
    db $F3                         ; $6838  open text box
    db $26,$43,$32,$26,$39         ; $6839  うまそうな
    db $90                         ; $683E  　(space)
    db $3A,$2B,$29,$8D             ; $683F  にくか゛ = にくが
    db $90                         ; $6843  　(space)
    db $39,$4E,$55,$37,$8D,$25,$50 ; $6844  ならんて゛いる = ならんでいる
    db $8F                         ; $684B  。
    db $EF,$EE                     ; $684C  newline
    db $F7                         ; $684E  clear page
    db $F0                         ; $684F  end of message


; --------------------------------------------------------------------------
; Message #132 ($6850)
;   「くっそー。　どうして　ひが
;   つかないんだろうか！
;   「にいちゃん！　ひをだす　まものを
;   もっていないか！？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg132:                             ; $6850  (file $10E850)
    db $EA                         ; $6850  ▶ new page
    db $9F                         ; $6851  box tag
    db $96                         ; $6852  end name/box tag
    db $2B,$36,$32,$9C             ; $6853  くっそー
    db $8F                         ; $6857  。
    db $90                         ; $6858  　(space)
    db $38,$8D,$26,$2F,$37         ; $6859  と゛うして = どうして
    db $90                         ; $685E  　(space)
    db $3F,$29,$8D                 ; $685F  ひか゛ = ひが
    db $EF,$EE                     ; $6862  newline
    db $90,$90                     ; $6864  　　(indent)
    db $35,$29,$39,$25,$55,$33,$8D,$52,$26,$29; $6866  つかないんた゛ろうか = つかないんだろうか
    db $99                         ; $6870  ！
    db $FA                         ; $6871  wait-for-button
    db $F7                         ; $6872  clear page
    db $EF,$EE                     ; $6873  newline
    db $9F                         ; $6875  box tag
    db $96                         ; $6876  end name/box tag
    db $3A,$25,$34,$49,$55         ; $6877  にいちゃん
    db $99                         ; $687C  ！
    db $90                         ; $687D  　(space)
    db $3F,$54,$33,$8D,$30         ; $687E  ひをた゛す = ひをだす
    db $90                         ; $6883  　(space)
    db $43,$47,$3D,$54             ; $6884  まものを
    db $EF,$EE                     ; $6888  newline
    db $90,$90                     ; $688A  　　(indent)
    db $47,$36,$37,$25,$39,$25,$29 ; $688C  もっていないか
    db $99                         ; $6893  ！
    db $98                         ; $6894  ？
    db $FF                         ; $6895  はい/いいえ
    db $F0                         ; $6896  end of message


; --------------------------------------------------------------------------
; Message #133 ($6897)
;   「おねがいだから　ひをだす
;   まもの　ゆずってほしいな[91]、。
; --------------------------------------------------------------------------
Bank67_Msg133:                             ; $6897  (file $10E897)
    db $EA                         ; $6897  ▶ new page
    db $9F                         ; $6898  box tag
    db $96                         ; $6899  end name/box tag
    db $28,$3C,$29,$8D,$25,$33,$8D,$29,$4E; $689A  おねか゛いた゛から = おねがいだから
    db $90                         ; $68A3  　(space)
    db $3F,$54,$33,$8D,$30         ; $68A4  ひをた゛す = ひをだす
    db $EF,$EE                     ; $68A9  newline
    db $90,$90                     ; $68AB  　　(indent)
    db $43,$47,$3D                 ; $68AD  まもの
    db $90                         ; $68B0  　(space)
    db $4A,$30,$8D,$36,$37,$42,$2F,$25,$39; $68B1  ゆす゛ってほしいな = ゆずってほしいな
    db $91                         ; $68BA  ctrl $91
    db $A4                         ; $68BB  、
    db $8F                         ; $68BC  。
    db $F7                         ; $68BD  clear page
    db $F0                         ; $68BE  end of message


; --------------------------------------------------------------------------
; Message #134 ($68BF)
;   「なんだ　もっていないじゃないか！
;   おねがいだから　たのむよ。
; --------------------------------------------------------------------------
Bank67_Msg134:                             ; $68BF  (file $10E8BF)
    db $EA                         ; $68BF  ▶ new page
    db $9F                         ; $68C0  box tag
    db $96                         ; $68C1  end name/box tag
    db $39,$55,$33,$8D             ; $68C2  なんた゛ = なんだ
    db $90                         ; $68C6  　(space)
    db $47,$36,$37,$25,$39,$25,$2F,$8D,$49,$39,$25,$29; $68C7  もっていないし゛ゃないか = もっていないじゃないか
    db $99                         ; $68D3  ！
    db $EF,$EE                     ; $68D4  newline
    db $90,$90                     ; $68D6  　　(indent)
    db $28,$3C,$29,$8D,$25,$33,$8D,$29,$4E; $68D8  おねか゛いた゛から = おねがいだから
    db $90                         ; $68E1  　(space)
    db $33,$3D,$45,$4C             ; $68E2  たのむよ
    db $8F                         ; $68E6  。
    db $F7                         ; $68E7  clear page
    db $F0                         ; $68E8  end of message


; --------------------------------------------------------------------------
; Message #135 ($68E9)
;   「おお！　もっているのか[91]！！
;   それじゃあ、
; --------------------------------------------------------------------------
Bank67_Msg135:                             ; $68E9  (file $10E8E9)
    db $EA                         ; $68E9  ▶ new page
    db $9F                         ; $68EA  box tag
    db $96                         ; $68EB  end name/box tag
    db $28,$28                     ; $68EC  おお
    db $99                         ; $68EE  ！
    db $90                         ; $68EF  　(space)
    db $47,$36,$37,$25,$50,$3D,$29 ; $68F0  もっているのか
    db $91                         ; $68F7  ctrl $91
    db $99                         ; $68F8  ！
    db $99                         ; $68F9  ！
    db $EF,$EE                     ; $68FA  newline
    db $90,$90                     ; $68FC  　　(indent)
    db $32,$51,$2F,$8D,$49,$24     ; $68FE  それし゛ゃあ = それじゃあ
    db $A4                         ; $6904  、
    db $FA                         ; $6905  wait-for-button
    db $F7                         ; $6906  clear page
    db $F0                         ; $6907  end of message


; --------------------------------------------------------------------------
; Message #136 ($6908)
;   「[F9][00]を　おれたちに
;   くれないか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg136:                             ; $6908  (file $10E908)
    db $EA                         ; $6908  ▶ new page
    db $9F                         ; $6909  box tag
    db $96                         ; $690A  end name/box tag
    db $F9                         ; $690B  ctrl $F9
    db $00                         ; $690C  ctrl $00
    db $54                         ; $690D  を
    db $90                         ; $690E  　(space)
    db $28,$51,$33,$34,$3A         ; $690F  おれたちに
    db $EF,$EE                     ; $6914  newline
    db $90,$90                     ; $6916  　　(indent)
    db $2B,$51,$39,$25,$29         ; $6918  くれないか
    db $98                         ; $691D  ？
    db $FF                         ; $691E  はい/いいえ
    db $F0                         ; $691F  end of message


; --------------------------------------------------------------------------
; Message #137 ($6920)
;   〈テリー〉は　[F9][00]を
;   さしだした！
; --------------------------------------------------------------------------
Bank67_Msg137:                             ; $6920  (file $10E920)
    db $F6                         ; $6920  «insert hero name»
    db $3E                         ; $6921  は
    db $90                         ; $6922  　(space)
    db $F9                         ; $6923  ctrl $F9
    db $00                         ; $6924  ctrl $00
    db $54                         ; $6925  を
    db $EF,$EE                     ; $6926  newline
    db $2E,$2F,$33,$8D,$2F,$33     ; $6928  さした゛した = さしだした
    db $99                         ; $692E  ！
    db $FA                         ; $692F  wait-for-button
    db $F7                         ; $6930  clear page
    db $F0                         ; $6931  end of message


; --------------------------------------------------------------------------
; Message #138 ($6932)
;   「びっくりしたなあ。
;   「こんなところに
;   こんなものが　あったなんて、、。
;   「まものを　くれた　おれいに
;   これを　つかっても　いいよ。
; --------------------------------------------------------------------------
Bank67_Msg138:                             ; $6932  (file $10E932)
    db $EA                         ; $6932  ▶ new page
    db $9F                         ; $6933  box tag
    db $96                         ; $6934  end name/box tag
    db $3F,$8D,$36,$2B,$4F,$2F,$33,$39,$24; $6935  ひ゛っくりしたなあ = びっくりしたなあ
    db $8F                         ; $693E  。
    db $EF,$EE                     ; $693F  newline
    db $FA                         ; $6941  wait-for-button
    db $F7                         ; $6942  clear page
    db $EF,$EE                     ; $6943  newline
    db $F3                         ; $6945  open text box
    db $9F                         ; $6946  box tag
    db $96                         ; $6947  end name/box tag
    db $2D,$55,$39,$38,$2D,$52,$3A ; $6948  こんなところに
    db $EF,$EE                     ; $694F  newline
    db $90,$90                     ; $6951  　　(indent)
    db $2D,$55,$39,$47,$3D,$29,$8D ; $6953  こんなものか゛ = こんなものが
    db $90                         ; $695A  　(space)
    db $24,$36,$33,$39,$55,$37     ; $695B  あったなんて
    db $A4                         ; $6961  、
    db $A4                         ; $6962  、
    db $8F                         ; $6963  。
    db $FA                         ; $6964  wait-for-button
    db $F7                         ; $6965  clear page
    db $EF,$EE                     ; $6966  newline
    db $9F                         ; $6968  box tag
    db $96                         ; $6969  end name/box tag
    db $43,$47,$3D,$54             ; $696A  まものを
    db $90                         ; $696E  　(space)
    db $2B,$51,$33                 ; $696F  くれた
    db $90                         ; $6972  　(space)
    db $28,$51,$25,$3A             ; $6973  おれいに
    db $EF,$EE                     ; $6977  newline
    db $90,$90                     ; $6979  　　(indent)
    db $2D,$51,$54                 ; $697B  これを
    db $90                         ; $697E  　(space)
    db $35,$29,$36,$37,$47         ; $697F  つかっても
    db $90                         ; $6984  　(space)
    db $25,$25,$4C                 ; $6985  いいよ
    db $8F                         ; $6988  。
    db $F7                         ; $6989  clear page
    db $F0                         ; $698A  end of message


; --------------------------------------------------------------------------
; Message #139 ($698B)
;   「そうか　ざんねんだな、、。
; --------------------------------------------------------------------------
Bank67_Msg139:                             ; $698B  (file $10E98B)
    db $EA                         ; $698B  ▶ new page
    db $9F                         ; $698C  box tag
    db $96                         ; $698D  end name/box tag
    db $32,$26,$29                 ; $698E  そうか
    db $90                         ; $6991  　(space)
    db $2E,$8D,$55,$3C,$55,$33,$8D,$39; $6992  さ゛んねんた゛な = ざんねんだな
    db $A4                         ; $699A  、
    db $A4                         ; $699B  、
    db $8F                         ; $699C  。
    db $EF,$EE                     ; $699D  newline
    db $F7                         ; $699F  clear page
    db $F0                         ; $69A0  end of message


; --------------------------------------------------------------------------
; Message #140 ($69A1)
;   「それじゃあ
;   [F9][00]を　もらってもいいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg140:                             ; $69A1  (file $10E9A1)
    db $EA                         ; $69A1  ▶ new page
    db $9F                         ; $69A2  box tag
    db $96                         ; $69A3  end name/box tag
    db $32,$51,$2F,$8D,$49,$24     ; $69A4  それし゛ゃあ = それじゃあ
    db $EF,$EE                     ; $69AA  newline
    db $90,$90                     ; $69AC  　　(indent)
    db $F9                         ; $69AE  ctrl $F9
    db $00                         ; $69AF  ctrl $00
    db $54                         ; $69B0  を
    db $90                         ; $69B1  　(space)
    db $47,$4E,$36,$37,$47,$25,$25,$29; $69B2  もらってもいいか
    db $98                         ; $69BA  ？
    db $FF                         ; $69BB  はい/いいえ
    db $F0                         ; $69BC  end of message


; --------------------------------------------------------------------------
; Message #141 ($69BD)
;   「この　たびのとびらは
;   どこに　つうじているんだろう？
; --------------------------------------------------------------------------
Bank67_Msg141:                             ; $69BD  (file $10E9BD)
    db $EA                         ; $69BD  ▶ new page
    db $9F                         ; $69BE  box tag
    db $96                         ; $69BF  end name/box tag
    db $2D,$3D                     ; $69C0  この
    db $90                         ; $69C2  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3E; $69C3  たひ゛のとひ゛らは = たびのとびらは
    db $EF,$EE                     ; $69CC  newline
    db $90,$90                     ; $69CE  　　(indent)
    db $38,$8D,$2D,$3A             ; $69D0  と゛こに = どこに
    db $90                         ; $69D4  　(space)
    db $35,$26,$2F,$8D,$37,$25,$50,$55,$33,$8D,$52,$26; $69D5  つうし゛ているんた゛ろう = つうじているんだろう
    db $98                         ; $69E1  ？
    db $F7                         ; $69E2  clear page
    db $F0                         ; $69E3  end of message


; --------------------------------------------------------------------------
; Message #142 ($69E4)
;   「うおお　はらへった！！
; --------------------------------------------------------------------------
Bank67_Msg142:                             ; $69E4  (file $10E9E4)
    db $EA                         ; $69E4  ▶ new page
    db $9F                         ; $69E5  box tag
    db $96                         ; $69E6  end name/box tag
    db $26,$28,$28                 ; $69E7  うおお
    db $90                         ; $69EA  　(space)
    db $3E,$4E,$41,$36,$33         ; $69EB  はらへった
    db $99                         ; $69F0  ！
    db $99                         ; $69F1  ！
    db $EF,$EE                     ; $69F2  newline
    db $F7                         ; $69F4  clear page
    db $F0                         ; $69F5  end of message


; --------------------------------------------------------------------------
; Message #143 ($69F6)
;   「うおお[95][95]！
;   これが　たびのとびらか！？
; --------------------------------------------------------------------------
Bank67_Msg143:                             ; $69F6  (file $10E9F6)
    db $EA                         ; $69F6  ▶ new page
    db $9F                         ; $69F7  box tag
    db $96                         ; $69F8  end name/box tag
    db $26,$28,$28                 ; $69F9  うおお
    db $95                         ; $69FC  ctrl $95
    db $95                         ; $69FD  ctrl $95
    db $99                         ; $69FE  ！
    db $EF,$EE                     ; $69FF  newline
    db $90,$90                     ; $6A01  　　(indent)
    db $2D,$51,$29,$8D             ; $6A03  これか゛ = これが
    db $90                         ; $6A07  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29; $6A08  たひ゛のとひ゛らか = たびのとびらか
    db $99                         ; $6A11  ！
    db $98                         ; $6A12  ？
    db $F7                         ; $6A13  clear page
    db $F0                         ; $6A14  end of message


; --------------------------------------------------------------------------
; Message #144 ($6A15)
;   「わしゃ　うらない　おばばじゃ。
;   そなたのみらいを　うらなおうか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg144:                             ; $6A15  (file $10EA15)
    db $EB                         ; $6A15  ▶ new page
    db $9F                         ; $6A16  box tag
    db $96                         ; $6A17  end name/box tag
    db $53,$2F,$49                 ; $6A18  わしゃ
    db $90                         ; $6A1B  　(space)
    db $26,$4E,$39,$25             ; $6A1C  うらない
    db $90                         ; $6A20  　(space)
    db $28,$3E,$8D,$3E,$8D,$2F,$8D,$49; $6A21  おは゛は゛し゛ゃ = おばばじゃ
    db $8F                         ; $6A29  。
    db $EF,$EE                     ; $6A2A  newline
    db $90,$90                     ; $6A2C  　　(indent)
    db $32,$39,$33,$3D,$44,$4E,$25,$54; $6A2E  そなたのみらいを
    db $90                         ; $6A36  　(space)
    db $26,$4E,$39,$28,$26,$29     ; $6A37  うらなおうか
    db $98                         ; $6A3D  ？
    db $FF                         ; $6A3E  はい/いいえ
    db $F0                         ; $6A3F  end of message


; --------------------------------------------------------------------------
; Message #145 ($6A40)
;   「フム、　そなたが　いまより
;   つよいものと　みとめられるとき、
;   「いじわるなおんなのこが　あらたな
;   みちを　ひらいてくれるだろう、。
; --------------------------------------------------------------------------
Bank67_Msg145:                             ; $6A40  (file $10EA40)
    db $EB                         ; $6A40  ▶ new page
    db $9F                         ; $6A41  box tag
    db $96                         ; $6A42  end name/box tag
    db $77,$7C                     ; $6A43  フム
    db $A4                         ; $6A45  、
    db $90                         ; $6A46  　(space)
    db $32,$39,$33,$29,$8D         ; $6A47  そなたか゛ = そなたが
    db $90                         ; $6A4C  　(space)
    db $25,$43,$4C,$4F             ; $6A4D  いまより
    db $EF,$EE                     ; $6A51  newline
    db $90,$90                     ; $6A53  　　(indent)
    db $35,$4C,$25,$47,$3D,$38     ; $6A55  つよいものと
    db $90                         ; $6A5B  　(space)
    db $44,$38,$46,$4E,$51,$50,$38,$2A; $6A5C  みとめられるとき
    db $A4                         ; $6A64  、
    db $FA                         ; $6A65  wait-for-button
    db $F7                         ; $6A66  clear page
    db $EF,$EE                     ; $6A67  newline
    db $9F                         ; $6A69  box tag
    db $96                         ; $6A6A  end name/box tag
    db $25,$2F,$8D,$53,$50,$39,$28,$55,$39,$3D,$2D,$29,$8D; $6A6B  いし゛わるなおんなのこか゛ = いじわるなおんなのこが
    db $90                         ; $6A78  　(space)
    db $24,$4E,$33,$39             ; $6A79  あらたな
    db $EF,$EE                     ; $6A7D  newline
    db $90,$90                     ; $6A7F  　　(indent)
    db $44,$34,$54                 ; $6A81  みちを
    db $90                         ; $6A84  　(space)
    db $3F,$4E,$25,$37,$2B,$51,$50,$33,$8D,$52,$26; $6A85  ひらいてくれるた゛ろう = ひらいてくれるだろう
    db $A4                         ; $6A90  、
    db $8F                         ; $6A91  。
    db $F7                         ; $6A92  clear page
    db $F0                         ; $6A93  end of message


; --------------------------------------------------------------------------
; Message #146 ($6A94)
;   「そうか。　おのれの　みちは
;   じぶんで　きりひらくか、。
; --------------------------------------------------------------------------
Bank67_Msg146:                             ; $6A94  (file $10EA94)
    db $EB                         ; $6A94  ▶ new page
    db $9F                         ; $6A95  box tag
    db $96                         ; $6A96  end name/box tag
    db $32,$26,$29                 ; $6A97  そうか
    db $8F                         ; $6A9A  。
    db $90                         ; $6A9B  　(space)
    db $28,$3D,$51,$3D             ; $6A9C  おのれの
    db $90                         ; $6AA0  　(space)
    db $44,$34,$3E                 ; $6AA1  みちは
    db $EF,$EE                     ; $6AA4  newline
    db $90,$90                     ; $6AA6  　　(indent)
    db $2F,$8D,$40,$8D,$55,$37,$8D ; $6AA8  し゛ふ゛んて゛ = じぶんで
    db $90                         ; $6AAF  　(space)
    db $2A,$4F,$3F,$4E,$2B,$29     ; $6AB0  きりひらくか
    db $A4                         ; $6AB6  、
    db $8F                         ; $6AB7  。
    db $F7                         ; $6AB8  clear page
    db $F0                         ; $6AB9  end of message


; --------------------------------------------------------------------------
; Message #147 ($6ABA)
;   「ここは　たびのとびらのまです。
;   「まちびととまもりのへやが
;   あらたに　ひらかれました！
;   「ホィミスラィムは　じゅもんで
;   なかまを　かいふくしてくれます。
;   「ぼうけんに　とてもやくだつから
;   てばなさないほうが　いいですよ。
;   「[16][19]は　あるけば　すこしずつ
;   かいふく　していきますからね！
; --------------------------------------------------------------------------
Bank67_Msg147:                             ; $6ABA  (file $10EABA)
    db $EA                         ; $6ABA  ▶ new page
    db $9F                         ; $6ABB  box tag
    db $96                         ; $6ABC  end name/box tag
    db $2D,$2D,$3E                 ; $6ABD  ここは
    db $90                         ; $6AC0  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$37,$8D,$30; $6AC1  たひ゛のとひ゛らのまて゛す = たびのとびらのまです
    db $8F                         ; $6ACE  。
    db $EF,$EE                     ; $6ACF  newline
    db $FA                         ; $6AD1  wait-for-button
    db $F7                         ; $6AD2  clear page
    db $EF,$EE                     ; $6AD3  newline
    db $F3                         ; $6AD5  open text box
    db $9F                         ; $6AD6  box tag
    db $96                         ; $6AD7  end name/box tag
    db $43,$34,$3F,$8D,$38,$38,$43,$47,$4F,$3D,$41,$48,$29,$8D; $6AD8  まちひ゛ととまもりのへやか゛ = まちびととまもりのへやが
    db $EF,$EE                     ; $6AE6  newline
    db $90,$90                     ; $6AE8  　　(indent)
    db $24,$4E,$33,$3A             ; $6AEA  あらたに
    db $90                         ; $6AEE  　(space)
    db $3F,$4E,$29,$51,$43,$2F,$33 ; $6AEF  ひらかれました
    db $99                         ; $6AF6  ！
    db $FA                         ; $6AF7  wait-for-button
    db $F7                         ; $6AF8  clear page
    db $EF,$EE                     ; $6AF9  newline
    db $9F                         ; $6AFB  box tag
    db $96                         ; $6AFC  end name/box tag
    db $79,$58,$7B,$67,$85,$58,$7C,$3E; $6AFD  ホィミスラィムは
    db $90                         ; $6B05  　(space)
    db $2F,$8D,$4B,$47,$55,$37,$8D ; $6B06  し゛ゅもんて゛ = じゅもんで
    db $EF,$EE                     ; $6B0D  newline
    db $90,$90                     ; $6B0F  　　(indent)
    db $39,$29,$43,$54             ; $6B11  なかまを
    db $90                         ; $6B15  　(space)
    db $29,$25,$40,$2B,$2F,$37,$2B,$51,$43,$30; $6B16  かいふくしてくれます
    db $8F                         ; $6B20  。
    db $FA                         ; $6B21  wait-for-button
    db $F7                         ; $6B22  clear page
    db $EF,$EE                     ; $6B23  newline
    db $9F                         ; $6B25  box tag
    db $96                         ; $6B26  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A     ; $6B27  ほ゛うけんに = ぼうけんに
    db $90                         ; $6B2D  　(space)
    db $38,$37,$47,$48,$2B,$33,$8D,$35,$29,$4E; $6B2E  とてもやくた゛つから = とてもやくだつから
    db $EF,$EE                     ; $6B38  newline
    db $90,$90                     ; $6B3A  　　(indent)
    db $37,$3E,$8D,$39,$2E,$39,$25,$42,$26,$29,$8D; $6B3C  ては゛なさないほうか゛ = てばなさないほうが
    db $90                         ; $6B47  　(space)
    db $25,$25,$37,$8D,$30,$4C     ; $6B48  いいて゛すよ = いいですよ
    db $8F                         ; $6B4E  。
    db $FA                         ; $6B4F  wait-for-button
    db $F7                         ; $6B50  clear page
    db $EF,$EE                     ; $6B51  newline
    db $9F                         ; $6B53  box tag
    db $96                         ; $6B54  end name/box tag
    db $16                         ; $6B55  ctrl $16
    db $19                         ; $6B56  ctrl $19
    db $3E                         ; $6B57  は
    db $90                         ; $6B58  　(space)
    db $24,$50,$2C,$3E,$8D         ; $6B59  あるけは゛ = あるけば
    db $90                         ; $6B5E  　(space)
    db $30,$2D,$2F,$30,$8D,$35     ; $6B5F  すこしす゛つ = すこしずつ
    db $EF,$EE                     ; $6B65  newline
    db $90,$90                     ; $6B67  　　(indent)
    db $29,$25,$40,$2B             ; $6B69  かいふく
    db $90                         ; $6B6D  　(space)
    db $2F,$37,$25,$2A,$43,$30,$29,$4E,$3C; $6B6E  していきますからね
    db $99                         ; $6B77  ！
    db $F7                         ; $6B78  clear page
    db $F0                         ; $6B79  end of message


; --------------------------------------------------------------------------
; Message #148 ($6B7A)
;   「ムムッ。こちらからも　いけぬか。
; --------------------------------------------------------------------------
Bank67_Msg148:                             ; $6B7A  (file $10EB7A)
    db $EA                         ; $6B7A  ▶ new page
    db $9F                         ; $6B7B  box tag
    db $96                         ; $6B7C  end name/box tag
    db $7C,$7C,$6D                 ; $6B7D  ムムッ
    db $8F                         ; $6B80  。
    db $2D,$34,$4E,$29,$4E,$47     ; $6B81  こちらからも
    db $90                         ; $6B87  　(space)
    db $25,$2C,$3B,$29             ; $6B88  いけぬか
    db $8F                         ; $6B8C  。
    db $EF,$EE                     ; $6B8D  newline
    db $F7                         ; $6B8F  clear page
    db $F0                         ; $6B90  end of message


; --------------------------------------------------------------------------
; Message #149 ($6B91)
;   「ここは　モンスター
;   ぼくじょうだよ。
;   「あくまのきしさん　あなを
;   とびこえようとしているけど、
;   「あのあなは　とびこえられないよ！
;   おちたら　どこに　でるのかな？
; --------------------------------------------------------------------------
Bank67_Msg149:                             ; $6B91  (file $10EB91)
    db $EB                         ; $6B91  ▶ new page
    db $9F                         ; $6B92  box tag
    db $96                         ; $6B93  end name/box tag
    db $2D,$2D,$3E                 ; $6B94  ここは
    db $90                         ; $6B97  　(space)
    db $7E,$8C,$67,$6A,$9C         ; $6B98  モンスター
    db $EF,$EE                     ; $6B9D  newline
    db $90,$90                     ; $6B9F  　　(indent)
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$33,$8D,$4C; $6BA1  ほ゛くし゛ょうた゛よ = ぼくじょうだよ
    db $8F                         ; $6BAB  。
    db $FA                         ; $6BAC  wait-for-button
    db $F7                         ; $6BAD  clear page
    db $EF,$EE                     ; $6BAE  newline
    db $9F                         ; $6BB0  box tag
    db $96                         ; $6BB1  end name/box tag
    db $24,$2B,$43,$3D,$2A,$2F,$2E,$55; $6BB2  あくまのきしさん
    db $90                         ; $6BBA  　(space)
    db $24,$39,$54                 ; $6BBB  あなを
    db $EF,$EE                     ; $6BBE  newline
    db $90,$90                     ; $6BC0  　　(indent)
    db $38,$3F,$8D,$2D,$27,$4C,$26,$38,$2F,$37,$25,$50,$2C,$38,$8D; $6BC2  とひ゛こえようとしているけと゛ = とびこえようとしているけど
    db $A4                         ; $6BD1  、
    db $FA                         ; $6BD2  wait-for-button
    db $F7                         ; $6BD3  clear page
    db $EF,$EE                     ; $6BD4  newline
    db $9F                         ; $6BD6  box tag
    db $96                         ; $6BD7  end name/box tag
    db $24,$3D,$24,$39,$3E         ; $6BD8  あのあなは
    db $90                         ; $6BDD  　(space)
    db $38,$3F,$8D,$2D,$27,$4E,$51,$39,$25,$4C; $6BDE  とひ゛こえられないよ = とびこえられないよ
    db $99                         ; $6BE8  ！
    db $EF,$EE                     ; $6BE9  newline
    db $90,$90                     ; $6BEB  　　(indent)
    db $28,$34,$33,$4E             ; $6BED  おちたら
    db $90                         ; $6BF1  　(space)
    db $38,$8D,$2D,$3A             ; $6BF2  と゛こに = どこに
    db $90                         ; $6BF6  　(space)
    db $37,$8D,$50,$3D,$29,$39     ; $6BF7  て゛るのかな = でるのかな
    db $98                         ; $6BFD  ？
    db $F7                         ; $6BFE  clear page
    db $F0                         ; $6BFF  end of message


; --------------------------------------------------------------------------
; Message #150 ($6C00)
;   「おお　〈テリー〉か。
;   まっておったぞい！
;   「これから　あんたは　くにの
;   だいひょうを　めざすんじゃ。
;   「だいひょうに　なるためには
;   クラスを　かちぬかねばならん。
;   「クラスをとびこえて　うけることも
;   ゆるされておるぞ！
;   「では　どのクラスを　うけるかの？
; --------------------------------------------------------------------------
Bank67_Msg150:                             ; $6C00  (file $10EC00)
    db $EA                         ; $6C00  ▶ new page
    db $9F                         ; $6C01  box tag
    db $96                         ; $6C02  end name/box tag
    db $28,$28                     ; $6C03  おお
    db $90                         ; $6C05  　(space)
    db $F6                         ; $6C06  «insert hero name»
    db $29                         ; $6C07  か
    db $8F                         ; $6C08  。
    db $EF,$EE                     ; $6C09  newline
    db $90,$90                     ; $6C0B  　　(indent)
    db $43,$36,$37,$28,$36,$33,$32,$8D,$25; $6C0D  まっておったそ゛い = まっておったぞい
    db $99                         ; $6C16  ！
    db $FA                         ; $6C17  wait-for-button
    db $F7                         ; $6C18  clear page
    db $EF,$EE                     ; $6C19  newline
    db $9F                         ; $6C1B  box tag
    db $96                         ; $6C1C  end name/box tag
    db $2D,$51,$29,$4E             ; $6C1D  これから
    db $90                         ; $6C21  　(space)
    db $24,$55,$33,$3E             ; $6C22  あんたは
    db $90                         ; $6C26  　(space)
    db $2B,$3A,$3D                 ; $6C27  くにの
    db $EF,$EE                     ; $6C2A  newline
    db $90,$90                     ; $6C2C  　　(indent)
    db $33,$8D,$25,$3F,$4D,$26,$54 ; $6C2E  た゛いひょうを = だいひょうを
    db $90                         ; $6C35  　(space)
    db $46,$2E,$8D,$30,$55,$2F,$8D,$49; $6C36  めさ゛すんし゛ゃ = めざすんじゃ
    db $8F                         ; $6C3E  。
    db $FA                         ; $6C3F  wait-for-button
    db $F7                         ; $6C40  clear page
    db $EF,$EE                     ; $6C41  newline
    db $9F                         ; $6C43  box tag
    db $96                         ; $6C44  end name/box tag
    db $33,$8D,$25,$3F,$4D,$26,$3A ; $6C45  た゛いひょうに = だいひょうに
    db $90                         ; $6C4C  　(space)
    db $39,$50,$33,$46,$3A,$3E     ; $6C4D  なるためには
    db $EF,$EE                     ; $6C53  newline
    db $90,$90                     ; $6C55  　　(indent)
    db $62,$85,$67,$54             ; $6C57  クラスを
    db $90                         ; $6C5B  　(space)
    db $29,$34,$3B,$29,$3C,$3E,$8D,$39,$4E,$55; $6C5C  かちぬかねは゛ならん = かちぬかねばならん
    db $8F                         ; $6C66  。
    db $FA                         ; $6C67  wait-for-button
    db $F7                         ; $6C68  clear page
    db $EF,$EE                     ; $6C69  newline
    db $9F                         ; $6C6B  box tag
    db $96                         ; $6C6C  end name/box tag
    db $62,$85,$67,$54,$38,$3F,$8D,$2D,$27,$37; $6C6D  クラスをとひ゛こえて = クラスをとびこえて
    db $90                         ; $6C77  　(space)
    db $26,$2C,$50,$2D,$38,$47     ; $6C78  うけることも
    db $EF,$EE                     ; $6C7E  newline
    db $90,$90                     ; $6C80  　　(indent)
    db $4A,$50,$2E,$51,$37,$28,$50,$32,$8D; $6C82  ゆるされておるそ゛ = ゆるされておるぞ
    db $99                         ; $6C8B  ！
    db $FA                         ; $6C8C  wait-for-button
    db $F7                         ; $6C8D  clear page
    db $EF,$EE                     ; $6C8E  newline
    db $9F                         ; $6C90  box tag
    db $96                         ; $6C91  end name/box tag
    db $37,$8D,$3E                 ; $6C92  て゛は = では
    db $90                         ; $6C95  　(space)
    db $38,$8D,$3D,$62,$85,$67,$54 ; $6C96  と゛のクラスを = どのクラスを
    db $90                         ; $6C9D  　(space)
    db $26,$2C,$50,$29,$3D         ; $6C9E  うけるかの
    db $98                         ; $6CA3  ？
    db $EF,$EE                     ; $6CA4  newline
    db $F0                         ; $6CA6  end of message


; --------------------------------------------------------------------------
; Message #151 ($6CA7)
;   「ざんねんじゃったが
;   つれているまものが　よわいの[93]。
;   「どこぞ　つよいまもののおる
;   たびのとびらに　いくことじゃ。
;   「そこで　もっとけいけんを　つむか
;   あらたに　つかまえてくるんじゃ！
; --------------------------------------------------------------------------
Bank67_Msg151:                             ; $6CA7  (file $10ECA7)
    db $EA                         ; $6CA7  ▶ new page
    db $9F                         ; $6CA8  box tag
    db $96                         ; $6CA9  end name/box tag
    db $2E,$8D,$55,$3C,$55,$2F,$8D,$49,$36,$33,$29,$8D; $6CAA  さ゛んねんし゛ゃったか゛ = ざんねんじゃったが
    db $EF,$EE                     ; $6CB6  newline
    db $90,$90                     ; $6CB8  　　(indent)
    db $35,$51,$37,$25,$50,$43,$47,$3D,$29,$8D; $6CBA  つれているまものか゛ = つれているまものが
    db $90                         ; $6CC4  　(space)
    db $4C,$53,$25,$3D             ; $6CC5  よわいの
    db $93                         ; $6CC9  small kana
    db $8F                         ; $6CCA  。
    db $FA                         ; $6CCB  wait-for-button
    db $F7                         ; $6CCC  clear page
    db $EF,$EE                     ; $6CCD  newline
    db $9F                         ; $6CCF  box tag
    db $96                         ; $6CD0  end name/box tag
    db $38,$8D,$2D,$32,$8D         ; $6CD1  と゛こそ゛ = どこぞ
    db $90                         ; $6CD6  　(space)
    db $35,$4C,$25,$43,$47,$3D,$3D,$28,$50; $6CD7  つよいまもののおる
    db $EF,$EE                     ; $6CE0  newline
    db $90,$90                     ; $6CE2  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A; $6CE4  たひ゛のとひ゛らに = たびのとびらに
    db $90                         ; $6CED  　(space)
    db $25,$2B,$2D,$38,$2F,$8D,$49 ; $6CEE  いくことし゛ゃ = いくことじゃ
    db $8F                         ; $6CF5  。
    db $FA                         ; $6CF6  wait-for-button
    db $F7                         ; $6CF7  clear page
    db $EF,$EE                     ; $6CF8  newline
    db $9F                         ; $6CFA  box tag
    db $96                         ; $6CFB  end name/box tag
    db $32,$2D,$37,$8D             ; $6CFC  そこて゛ = そこで
    db $90                         ; $6D00  　(space)
    db $47,$36,$38,$2C,$25,$2C,$55,$54; $6D01  もっとけいけんを
    db $90                         ; $6D09  　(space)
    db $35,$45,$29                 ; $6D0A  つむか
    db $EF,$EE                     ; $6D0D  newline
    db $90,$90                     ; $6D0F  　　(indent)
    db $24,$4E,$33,$3A             ; $6D11  あらたに
    db $90                         ; $6D15  　(space)
    db $35,$29,$43,$27,$37,$2B,$50,$55,$2F,$8D,$49; $6D16  つかまえてくるんし゛ゃ = つかまえてくるんじゃ
    db $99                         ; $6D21  ！
    db $F7                         ; $6D22  clear page
    db $F0                         ; $6D23  end of message


; --------------------------------------------------------------------------
; Message #152 ($6D24)
;   「ようやった！！
;   [0F]クラスかちぬきじゃぞ！
;   「おもいでととまどいのへやを
;   おうさまが　あけてくれたぞい！
;   「より　つよい　まもののおる
;   たびのとびらが　まっとるぞ！
; --------------------------------------------------------------------------
Bank67_Msg152:                             ; $6D24  (file $10ED24)
    db $EA                         ; $6D24  ▶ new page
    db $9F                         ; $6D25  box tag
    db $96                         ; $6D26  end name/box tag
    db $4C,$26,$48,$36,$33         ; $6D27  ようやった
    db $99                         ; $6D2C  ！
    db $99                         ; $6D2D  ！
    db $EF,$EE                     ; $6D2E  newline
    db $90,$90                     ; $6D30  　　(indent)
    db $0F                         ; $6D32  ctrl $0F
    db $62,$85,$67,$29,$34,$3B,$2A,$2F,$8D,$49,$32,$8D; $6D33  クラスかちぬきし゛ゃそ゛ = クラスかちぬきじゃぞ
    db $99                         ; $6D3F  ！
    db $FA                         ; $6D40  wait-for-button
    db $F7                         ; $6D41  clear page
    db $EF,$EE                     ; $6D42  newline
    db $9F                         ; $6D44  box tag
    db $96                         ; $6D45  end name/box tag
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$54; $6D46  おもいて゛ととまと゛いのへやを = おもいでととまどいのへやを
    db $EF,$EE                     ; $6D55  newline
    db $90,$90                     ; $6D57  　　(indent)
    db $28,$26,$2E,$43,$29,$8D     ; $6D59  おうさまか゛ = おうさまが
    db $90                         ; $6D5F  　(space)
    db $24,$2C,$37,$2B,$51,$33,$32,$8D,$25; $6D60  あけてくれたそ゛い = あけてくれたぞい
    db $99                         ; $6D69  ！
    db $FA                         ; $6D6A  wait-for-button
    db $F7                         ; $6D6B  clear page
    db $EF,$EE                     ; $6D6C  newline
    db $9F                         ; $6D6E  box tag
    db $96                         ; $6D6F  end name/box tag
    db $4C,$4F                     ; $6D70  より
    db $90                         ; $6D72  　(space)
    db $35,$4C,$25                 ; $6D73  つよい
    db $90                         ; $6D76  　(space)
    db $43,$47,$3D,$3D,$28,$50     ; $6D77  まもののおる
    db $EF,$EE                     ; $6D7D  newline
    db $90,$90                     ; $6D7F  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $6D81  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $6D8B  　(space)
    db $43,$36,$38,$50,$32,$8D     ; $6D8C  まっとるそ゛ = まっとるぞ
    db $99                         ; $6D92  ！
    db $F7                         ; $6D93  clear page
    db $F0                         ; $6D94  end of message


; --------------------------------------------------------------------------
; Message #153 ($6D95)
;   「[0F]クラスの　さいしゅうせんは
;   いどのそこで　くらしている
;   「あやしい　はかせが　あいてです。
; --------------------------------------------------------------------------
Bank67_Msg153:                             ; $6D95  (file $10ED95)
    db $EB                         ; $6D95  ▶ new page
    db $9F                         ; $6D96  box tag
    db $96                         ; $6D97  end name/box tag
    db $0F                         ; $6D98  ctrl $0F
    db $62,$85,$67,$3D             ; $6D99  クラスの
    db $90                         ; $6D9D  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $6D9E  さいしゅうせんは
    db $EF,$EE                     ; $6DA6  newline
    db $90,$90                     ; $6DA8  　　(indent)
    db $25,$38,$8D,$3D,$32,$2D,$37,$8D; $6DAA  いと゛のそこて゛ = いどのそこで
    db $90                         ; $6DB2  　(space)
    db $2B,$4E,$2F,$37,$25,$50     ; $6DB3  くらしている
    db $FA                         ; $6DB9  wait-for-button
    db $F7                         ; $6DBA  clear page
    db $EF,$EE                     ; $6DBB  newline
    db $9F                         ; $6DBD  box tag
    db $96                         ; $6DBE  end name/box tag
    db $24,$48,$2F,$25             ; $6DBF  あやしい
    db $90                         ; $6DC3  　(space)
    db $3E,$29,$31,$29,$8D         ; $6DC4  はかせか゛ = はかせが
    db $90                         ; $6DC9  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $6DCA  あいてて゛す = あいてです
    db $8F                         ; $6DD0  。
    db $EF,$EE                     ; $6DD1  newline
    db $F7                         ; $6DD3  clear page
    db $F0                         ; $6DD4  end of message


; --------------------------------------------------------------------------
; Message #154 ($6DD5)
;   「ぼ　ぼくのなまえは　テト。
;   じつは　[10]クラスかちぬきました！
;   「え？　〈テリー〉さんも　[10]クラス？
;   おたがい　がんばりましょうね！
;   「〈テリー〉さん。かくとうじょうでは
;   いいことが　いろいろきけますよ！
;   「まだ　いったことのない　たびの
;   とびらのじょうほうも　きけます！
; --------------------------------------------------------------------------
Bank67_Msg154:                             ; $6DD5  (file $10EDD5)
    db $EA                         ; $6DD5  ▶ new page
    db $9F                         ; $6DD6  box tag
    db $96                         ; $6DD7  end name/box tag
    db $42,$8D                     ; $6DD8  ほ゛ = ぼ
    db $90                         ; $6DDA  　(space)
    db $42,$8D,$2B,$3D,$39,$43,$27,$3E; $6DDB  ほ゛くのなまえは = ぼくのなまえは
    db $90                         ; $6DE3  　(space)
    db $6E,$6F                     ; $6DE4  テト
    db $8F                         ; $6DE6  。
    db $EF,$EE                     ; $6DE7  newline
    db $90,$90                     ; $6DE9  　　(indent)
    db $2F,$8D,$35,$3E             ; $6DEB  し゛つは = じつは
    db $90                         ; $6DEF  　(space)
    db $10                         ; $6DF0  ctrl $10
    db $62,$85,$67,$29,$34,$3B,$2A,$43,$2F,$33; $6DF1  クラスかちぬきました
    db $99                         ; $6DFB  ！
    db $FA                         ; $6DFC  wait-for-button
    db $F7                         ; $6DFD  clear page
    db $EF,$EE                     ; $6DFE  newline
    db $9F                         ; $6E00  box tag
    db $96                         ; $6E01  end name/box tag
    db $27                         ; $6E02  え
    db $98                         ; $6E03  ？
    db $90                         ; $6E04  　(space)
    db $F6                         ; $6E05  «insert hero name»
    db $2E,$55,$47                 ; $6E06  さんも
    db $90                         ; $6E09  　(space)
    db $10                         ; $6E0A  ctrl $10
    db $62,$85,$67                 ; $6E0B  クラス
    db $98                         ; $6E0E  ？
    db $EF,$EE                     ; $6E0F  newline
    db $90,$90                     ; $6E11  　　(indent)
    db $28,$33,$29,$8D,$25         ; $6E13  おたか゛い = おたがい
    db $90                         ; $6E18  　(space)
    db $29,$8D,$55,$3E,$8D,$4F,$43,$2F,$4D,$26,$3C; $6E19  か゛んは゛りましょうね = がんばりましょうね
    db $99                         ; $6E24  ！
    db $FA                         ; $6E25  wait-for-button
    db $F7                         ; $6E26  clear page
    db $EF,$EE                     ; $6E27  newline
    db $9F                         ; $6E29  box tag
    db $96                         ; $6E2A  end name/box tag
    db $F6                         ; $6E2B  «insert hero name»
    db $2E,$55                     ; $6E2C  さん
    db $8F                         ; $6E2E  。
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$37,$8D,$3E; $6E2F  かくとうし゛ょうて゛は = かくとうじょうでは
    db $EF,$EE                     ; $6E3A  newline
    db $90,$90                     ; $6E3C  　　(indent)
    db $25,$25,$2D,$38,$29,$8D     ; $6E3E  いいことか゛ = いいことが
    db $90                         ; $6E44  　(space)
    db $25,$52,$25,$52,$2A,$2C,$43,$30,$4C; $6E45  いろいろきけますよ
    db $99                         ; $6E4E  ！
    db $FA                         ; $6E4F  wait-for-button
    db $F7                         ; $6E50  clear page
    db $EF,$EE                     ; $6E51  newline
    db $9F                         ; $6E53  box tag
    db $96                         ; $6E54  end name/box tag
    db $43,$33,$8D                 ; $6E55  また゛ = まだ
    db $90                         ; $6E58  　(space)
    db $25,$36,$33,$2D,$38,$3D,$39,$25; $6E59  いったことのない
    db $90                         ; $6E61  　(space)
    db $33,$3F,$8D,$3D             ; $6E62  たひ゛の = たびの
    db $EF,$EE                     ; $6E66  newline
    db $90,$90                     ; $6E68  　　(indent)
    db $38,$3F,$8D,$4E,$3D,$2F,$8D,$4D,$26,$42,$26,$47; $6E6A  とひ゛らのし゛ょうほうも = とびらのじょうほうも
    db $90                         ; $6E76  　(space)
    db $2A,$2C,$43,$30             ; $6E77  きけます
    db $99                         ; $6E7B  ！
    db $F7                         ; $6E7C  clear page
    db $F0                         ; $6E7D  end of message


; --------------------------------------------------------------------------
; Message #155 ($6E7E)
;   「[0E]クラスですよ。
;   わたし　[0E]クラスなんですよ！！
;   「ハッハッハ！　しりませんでした？
;   わたしが　[0E]クラスだってこと！
; --------------------------------------------------------------------------
Bank67_Msg155:                             ; $6E7E  (file $10EE7E)
    db $EA                         ; $6E7E  ▶ new page
    db $9F                         ; $6E7F  box tag
    db $96                         ; $6E80  end name/box tag
    db $0E                         ; $6E81  ctrl $0E
    db $62,$85,$67,$37,$8D,$30,$4C ; $6E82  クラスて゛すよ = クラスですよ
    db $8F                         ; $6E89  。
    db $EF,$EE                     ; $6E8A  newline
    db $90,$90                     ; $6E8C  　　(indent)
    db $53,$33,$2F                 ; $6E8E  わたし
    db $90                         ; $6E91  　(space)
    db $0E                         ; $6E92  ctrl $0E
    db $62,$85,$67,$39,$55,$37,$8D,$30,$4C; $6E93  クラスなんて゛すよ = クラスなんですよ
    db $99                         ; $6E9C  ！
    db $99                         ; $6E9D  ！
    db $FA                         ; $6E9E  wait-for-button
    db $F7                         ; $6E9F  clear page
    db $EF,$EE                     ; $6EA0  newline
    db $9F                         ; $6EA2  box tag
    db $96                         ; $6EA3  end name/box tag
    db $75,$6D,$75,$6D,$75         ; $6EA4  ハッハッハ
    db $99                         ; $6EA9  ！
    db $90                         ; $6EAA  　(space)
    db $2F,$4F,$43,$31,$55,$37,$8D,$2F,$33; $6EAB  しりませんて゛した = しりませんでした
    db $98                         ; $6EB4  ？
    db $EF,$EE                     ; $6EB5  newline
    db $90,$90                     ; $6EB7  　　(indent)
    db $53,$33,$2F,$29,$8D         ; $6EB9  わたしか゛ = わたしが
    db $90                         ; $6EBE  　(space)
    db $0E                         ; $6EBF  ctrl $0E
    db $62,$85,$67,$33,$8D,$36,$37,$2D,$38; $6EC0  クラスた゛ってこと = クラスだってこと
    db $99                         ; $6EC9  ！
    db $F7                         ; $6ECA  clear page
    db $F0                         ; $6ECB  end of message


; --------------------------------------------------------------------------
; Message #156 ($6ECC)
;   「おとくな　とくぎと　まものの
;   はやおぼえ、ブツブツ、。
;   「キアリー　ドラキー　ヨニコーン
;   それから　ピクシー　はなまどう、
;   「キアリク　ネジまき　マッド
;   プラントに　スラィムつむり、
;   「キアラル　ネジまき　かりゅうそう
;   しりょうのきしに　ェビルワンド！
;   「ひかりのはどうは　ぜんぶなおす。
;   すごく　おとくなとくぎだよ！
; --------------------------------------------------------------------------
Bank67_Msg156:                             ; $6ECC  (file $10EECC)
    db $EA                         ; $6ECC  ▶ new page
    db $9F                         ; $6ECD  box tag
    db $96                         ; $6ECE  end name/box tag
    db $28,$38,$2B,$39             ; $6ECF  おとくな
    db $90                         ; $6ED3  　(space)
    db $38,$2B,$2A,$8D,$38         ; $6ED4  とくき゛と = とくぎと
    db $90                         ; $6ED9  　(space)
    db $43,$47,$3D,$3D             ; $6EDA  まものの
    db $EF,$EE                     ; $6EDE  newline
    db $90,$90                     ; $6EE0  　　(indent)
    db $3E,$48,$28,$42,$8D,$27     ; $6EE2  はやおほ゛え = はやおぼえ
    db $A4                         ; $6EE8  、
    db $77,$8D,$6C,$77,$8D,$6C     ; $6EE9  フ゛ツフ゛ツ = ブツブツ
    db $A4                         ; $6EEF  、
    db $8F                         ; $6EF0  。
    db $FA                         ; $6EF1  wait-for-button
    db $F7                         ; $6EF2  clear page
    db $EF,$EE                     ; $6EF3  newline
    db $9F                         ; $6EF5  box tag
    db $96                         ; $6EF6  end name/box tag
    db $61,$56,$86,$9C             ; $6EF7  キアリー
    db $90                         ; $6EFB  　(space)
    db $6F,$8D,$85,$61,$9C         ; $6EFC  ト゛ラキー = ドラキー
    db $90                         ; $6F01  　(space)
    db $81,$71,$64,$9C,$8C         ; $6F02  ヨニコーン
    db $EF,$EE                     ; $6F07  newline
    db $90,$90                     ; $6F09  　　(indent)
    db $32,$51,$29,$4E             ; $6F0B  それから
    db $90                         ; $6F0F  　(space)
    db $76,$8E,$62,$66,$9C         ; $6F10  ヒ゜クシー = ピクシー
    db $90                         ; $6F15  　(space)
    db $3E,$39,$43,$38,$8D,$26     ; $6F16  はなまと゛う = はなまどう
    db $A4                         ; $6F1C  、
    db $FA                         ; $6F1D  wait-for-button
    db $F7                         ; $6F1E  clear page
    db $EF,$EE                     ; $6F1F  newline
    db $9F                         ; $6F21  box tag
    db $96                         ; $6F22  end name/box tag
    db $61,$56,$86,$62             ; $6F23  キアリク
    db $90                         ; $6F27  　(space)
    db $73,$66,$8D,$43,$2A         ; $6F28  ネシ゛まき = ネジまき
    db $90                         ; $6F2D  　(space)
    db $7A,$6D,$6F,$8D             ; $6F2E  マット゛ = マッド
    db $EF,$EE                     ; $6F32  newline
    db $90,$90                     ; $6F34  　　(indent)
    db $77,$8E,$85,$8C,$6F,$3A     ; $6F36  フ゜ラントに = プラントに
    db $90                         ; $6F3C  　(space)
    db $67,$85,$58,$7C,$35,$45,$4F ; $6F3D  スラィムつむり
    db $A4                         ; $6F44  、
    db $FA                         ; $6F45  wait-for-button
    db $F7                         ; $6F46  clear page
    db $EF,$EE                     ; $6F47  newline
    db $9F                         ; $6F49  box tag
    db $96                         ; $6F4A  end name/box tag
    db $61,$56,$85,$87             ; $6F4B  キアラル
    db $90                         ; $6F4F  　(space)
    db $73,$66,$8D,$43,$2A         ; $6F50  ネシ゛まき = ネジまき
    db $90                         ; $6F55  　(space)
    db $29,$4F,$4B,$26,$32,$26     ; $6F56  かりゅうそう
    db $EF,$EE                     ; $6F5C  newline
    db $90,$90                     ; $6F5E  　　(indent)
    db $2F,$4F,$4D,$26,$3D,$2A,$2F,$3A; $6F60  しりょうのきしに
    db $90                         ; $6F68  　(space)
    db $5C,$76,$8D,$87,$8A,$8C,$6F,$8D; $6F69  ェヒ゛ルワント゛ = ェビルワンド
    db $99                         ; $6F71  ！
    db $FA                         ; $6F72  wait-for-button
    db $F7                         ; $6F73  clear page
    db $EF,$EE                     ; $6F74  newline
    db $9F                         ; $6F76  box tag
    db $96                         ; $6F77  end name/box tag
    db $3F,$29,$4F,$3D,$3E,$38,$8D,$26,$3E; $6F78  ひかりのはと゛うは = ひかりのはどうは
    db $90                         ; $6F81  　(space)
    db $31,$8D,$55,$40,$8D,$39,$28,$30; $6F82  せ゛んふ゛なおす = ぜんぶなおす
    db $8F                         ; $6F8A  。
    db $EF,$EE                     ; $6F8B  newline
    db $90,$90                     ; $6F8D  　　(indent)
    db $30,$2D,$8D,$2B             ; $6F8F  すこ゛く = すごく
    db $90                         ; $6F93  　(space)
    db $28,$38,$2B,$39,$38,$2B,$2A,$8D,$33,$8D,$4C; $6F94  おとくなとくき゛た゛よ = おとくなとくぎだよ
    db $99                         ; $6F9F  ！
    db $F7                         ; $6FA0  clear page
    db $F0                         ; $6FA1  end of message


; --------------------------------------------------------------------------
; Message #157 ($6FA2)
;   「おおめだまに　おおめだま。
; --------------------------------------------------------------------------
Bank67_Msg157:                             ; $6FA2  (file $10EFA2)
    db $EA                         ; $6FA2  ▶ new page
    db $9F                         ; $6FA3  box tag
    db $96                         ; $6FA4  end name/box tag
    db $28,$28,$46,$33,$8D,$43,$3A ; $6FA5  おおめた゛まに = おおめだまに
    db $90                         ; $6FAC  　(space)
    db $28,$28,$46,$33,$8D,$43     ; $6FAD  おおめた゛ま = おおめだま
    db $8F                         ; $6FB3  。
    db $EF,$EE                     ; $6FB4  newline
    db $F7                         ; $6FB6  clear page
    db $F0                         ; $6FB7  end of message


; --------------------------------------------------------------------------
; Message #158 ($6FB8)
;   「へへっ！　にいちゃんよ[95]。
;   [0F]クラスのあいてを　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg158:                             ; $6FB8  (file $10EFB8)
    db $EA                         ; $6FB8  ▶ new page
    db $9F                         ; $6FB9  box tag
    db $96                         ; $6FBA  end name/box tag
    db $41,$41,$36                 ; $6FBB  へへっ
    db $99                         ; $6FBE  ！
    db $90                         ; $6FBF  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $6FC0  にいちゃんよ
    db $95                         ; $6FC6  ctrl $95
    db $8F                         ; $6FC7  。
    db $EF,$EE                     ; $6FC8  newline
    db $90,$90                     ; $6FCA  　　(indent)
    db $0F                         ; $6FCC  ctrl $0F
    db $62,$85,$67,$3D,$24,$25,$37,$54; $6FCD  クラスのあいてを
    db $90                         ; $6FD5  　(space)
    db $2F,$4F,$33,$25,$29         ; $6FD6  しりたいか
    db $98                         ; $6FDB  ？
    db $FF                         ; $6FDC  はい/いいえ
    db $F0                         ; $6FDD  end of message


; --------------------------------------------------------------------------
; Message #159 ($6FDE)
;   「[0F]クラスの　さいしゅうせんは
;   いどの　はかせが　あいてだぜ。
;   「やつのまものは　アニマルゾンビ
;   デスフラッター　スカルガルーだ。
;   「デスフラッターが　たかく
;   とびあがったら　ようちゅういだ！
;   「アニマルゾンビは　ルカニで
;   しゅびりょくを　さげてくるぜ。
; --------------------------------------------------------------------------
Bank67_Msg159:                             ; $6FDE  (file $10EFDE)
    db $EA                         ; $6FDE  ▶ new page
    db $9F                         ; $6FDF  box tag
    db $96                         ; $6FE0  end name/box tag
    db $0F                         ; $6FE1  ctrl $0F
    db $62,$85,$67,$3D             ; $6FE2  クラスの
    db $90                         ; $6FE6  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $6FE7  さいしゅうせんは
    db $EF,$EE                     ; $6FEF  newline
    db $90,$90                     ; $6FF1  　　(indent)
    db $25,$38,$8D,$3D             ; $6FF3  いと゛の = いどの
    db $90                         ; $6FF7  　(space)
    db $3E,$29,$31,$29,$8D         ; $6FF8  はかせか゛ = はかせが
    db $90                         ; $6FFD  　(space)
    db $24,$25,$37,$33,$8D,$31,$8D ; $6FFE  あいてた゛せ゛ = あいてだぜ
    db $8F                         ; $7005  。
    db $FA                         ; $7006  wait-for-button
    db $F7                         ; $7007  clear page
    db $EF,$EE                     ; $7008  newline
    db $9F                         ; $700A  box tag
    db $96                         ; $700B  end name/box tag
    db $48,$35,$3D,$43,$47,$3D,$3E ; $700C  やつのまものは
    db $90                         ; $7013  　(space)
    db $56,$71,$7A,$87,$69,$8D,$8C,$76,$8D; $7014  アニマルソ゛ンヒ゛ = アニマルゾンビ
    db $EF,$EE                     ; $701D  newline
    db $90,$90                     ; $701F  　　(indent)
    db $6E,$8D,$67,$77,$85,$6D,$6A,$9C; $7021  テ゛スフラッター = デスフラッター
    db $90                         ; $7029  　(space)
    db $67,$60,$87,$60,$8D,$87,$9C,$33,$8D; $702A  スカルカ゛ルーた゛ = スカルガルーだ
    db $8F                         ; $7033  。
    db $FA                         ; $7034  wait-for-button
    db $F7                         ; $7035  clear page
    db $EF,$EE                     ; $7036  newline
    db $9F                         ; $7038  box tag
    db $96                         ; $7039  end name/box tag
    db $6E,$8D,$67,$77,$85,$6D,$6A,$9C,$29,$8D; $703A  テ゛スフラッターか゛ = デスフラッターが
    db $90                         ; $7044  　(space)
    db $33,$29,$2B                 ; $7045  たかく
    db $EF,$EE                     ; $7048  newline
    db $90,$90                     ; $704A  　　(indent)
    db $38,$3F,$8D,$24,$29,$8D,$36,$33,$4E; $704C  とひ゛あか゛ったら = とびあがったら
    db $90                         ; $7055  　(space)
    db $4C,$26,$34,$4B,$26,$25,$33,$8D; $7056  ようちゅういた゛ = ようちゅういだ
    db $99                         ; $705E  ！
    db $FA                         ; $705F  wait-for-button
    db $F7                         ; $7060  clear page
    db $EF,$EE                     ; $7061  newline
    db $9F                         ; $7063  box tag
    db $96                         ; $7064  end name/box tag
    db $56,$71,$7A,$87,$69,$8D,$8C,$76,$8D,$3E; $7065  アニマルソ゛ンヒ゛は = アニマルゾンビは
    db $90                         ; $706F  　(space)
    db $87,$60,$71,$37,$8D         ; $7070  ルカニて゛ = ルカニで
    db $EF,$EE                     ; $7075  newline
    db $90,$90                     ; $7077  　　(indent)
    db $2F,$4B,$3F,$8D,$4F,$4D,$2B,$54; $7079  しゅひ゛りょくを = しゅびりょくを
    db $90                         ; $7081  　(space)
    db $2E,$2C,$8D,$37,$2B,$50,$31,$8D; $7082  さけ゛てくるせ゛ = さげてくるぜ
    db $8F                         ; $708A  。
    db $F7                         ; $708B  clear page
    db $F0                         ; $708C  end of message


; --------------------------------------------------------------------------
; Message #160 ($708D)
;   「はじめまして。　わたしは
;   あずかりじょを　やっております。
;   「ぼうけんでみつけた　おかねや
;   どうぐを　おあずかりいたします。
;   「あずけたり　ひきだしたいときは
;   いつでも　おこしください。
;   「それでは　ほんじつは
;   どのような　ごようでしょうか？
; --------------------------------------------------------------------------
Bank67_Msg160:                             ; $708D  (file $10F08D)
    db $EA                         ; $708D  ▶ new page
    db $9F                         ; $708E  box tag
    db $96                         ; $708F  end name/box tag
    db $3E,$2F,$8D,$46,$43,$2F,$37 ; $7090  はし゛めまして = はじめまして
    db $8F                         ; $7097  。
    db $90                         ; $7098  　(space)
    db $53,$33,$2F,$3E             ; $7099  わたしは
    db $EF,$EE                     ; $709D  newline
    db $90,$90                     ; $709F  　　(indent)
    db $24,$30,$8D,$29,$4F,$2F,$8D,$4D,$54; $70A1  あす゛かりし゛ょを = あずかりじょを
    db $90                         ; $70AA  　(space)
    db $48,$36,$37,$28,$4F,$43,$30 ; $70AB  やっております
    db $8F                         ; $70B2  。
    db $FA                         ; $70B3  wait-for-button
    db $F7                         ; $70B4  clear page
    db $EF,$EE                     ; $70B5  newline
    db $9F                         ; $70B7  box tag
    db $96                         ; $70B8  end name/box tag
    db $42,$8D,$26,$2C,$55,$37,$8D,$44,$35,$2C,$33; $70B9  ほ゛うけんて゛みつけた = ぼうけんでみつけた
    db $90                         ; $70C4  　(space)
    db $28,$29,$3C,$48             ; $70C5  おかねや
    db $EF,$EE                     ; $70C9  newline
    db $90,$90                     ; $70CB  　　(indent)
    db $38,$8D,$26,$2B,$8D,$54     ; $70CD  と゛うく゛を = どうぐを
    db $90                         ; $70D3  　(space)
    db $28,$24,$30,$8D,$29,$4F,$25,$33,$2F,$43,$30; $70D4  おあす゛かりいたします = おあずかりいたします
    db $8F                         ; $70DF  。
    db $FA                         ; $70E0  wait-for-button
    db $F7                         ; $70E1  clear page
    db $EF,$EE                     ; $70E2  newline
    db $9F                         ; $70E4  box tag
    db $96                         ; $70E5  end name/box tag
    db $24,$30,$8D,$2C,$33,$4F     ; $70E6  あす゛けたり = あずけたり
    db $90                         ; $70EC  　(space)
    db $3F,$2A,$33,$8D,$2F,$33,$25,$38,$2A,$3E; $70ED  ひきた゛したいときは = ひきだしたいときは
    db $EF,$EE                     ; $70F7  newline
    db $90,$90                     ; $70F9  　　(indent)
    db $25,$35,$37,$8D,$47         ; $70FB  いつて゛も = いつでも
    db $90                         ; $7100  　(space)
    db $28,$2D,$2F,$2B,$33,$8D,$2E,$25; $7101  おこしくた゛さい = おこしください
    db $8F                         ; $7109  。
    db $FA                         ; $710A  wait-for-button
    db $F7                         ; $710B  clear page
    db $EF,$EE                     ; $710C  newline
    db $9F                         ; $710E  box tag
    db $96                         ; $710F  end name/box tag
    db $32,$51,$37,$8D,$3E         ; $7110  それて゛は = それでは
    db $90                         ; $7115  　(space)
    db $42,$55,$2F,$8D,$35,$3E     ; $7116  ほんし゛つは = ほんじつは
    db $EF,$EE                     ; $711C  newline
    db $90,$90                     ; $711E  　　(indent)
    db $38,$8D,$3D,$4C,$26,$39     ; $7120  と゛のような = どのような
    db $90                         ; $7126  　(space)
    db $2D,$8D,$4C,$26,$37,$8D,$2F,$4D,$26,$29; $7127  こ゛ようて゛しょうか = ごようでしょうか
    db $98                         ; $7131  ？
    db $F0                         ; $7132  end of message


; --------------------------------------------------------------------------
; Message #161 ($7133)
;   「ここは　あずかりじょです。
;   どのような　ごようでしょうか？
; --------------------------------------------------------------------------
Bank67_Msg161:                             ; $7133  (file $10F133)
    db $EA                         ; $7133  ▶ new page
    db $9F                         ; $7134  box tag
    db $96                         ; $7135  end name/box tag
    db $2D,$2D,$3E                 ; $7136  ここは
    db $90                         ; $7139  　(space)
    db $24,$30,$8D,$29,$4F,$2F,$8D,$4D,$37,$8D,$30; $713A  あす゛かりし゛ょて゛す = あずかりじょです
    db $8F                         ; $7145  。
    db $EF,$EE                     ; $7146  newline
    db $90,$90                     ; $7148  　　(indent)
    db $38,$8D,$3D,$4C,$26,$39     ; $714A  と゛のような = どのような
    db $90                         ; $7150  　(space)
    db $2D,$8D,$4C,$26,$37,$8D,$2F,$4D,$26,$29; $7151  こ゛ようて゛しょうか = ごようでしょうか
    db $98                         ; $715B  ？
    db $F0                         ; $715C  end of message


; --------------------------------------------------------------------------
; Message #162 ($715D)
;   「ぜんめつすると　もちものが
;   ほとんどなくなるうえに、
;   「おかねも　はんぶんに
;   なってしまいます。
;   「でも　とうあずかりじょに
;   あずけておけば　あんしんです。
;   「ばんぜんの　けいびで　あなたの
;   だいじなものを　おまもりします！
; --------------------------------------------------------------------------
Bank67_Msg162:                             ; $715D  (file $10F15D)
    db $EA                         ; $715D  ▶ new page
    db $9F                         ; $715E  box tag
    db $96                         ; $715F  end name/box tag
    db $31,$8D,$55,$46,$35,$30,$50,$38; $7160  せ゛んめつすると = ぜんめつすると
    db $90                         ; $7168  　(space)
    db $47,$34,$47,$3D,$29,$8D     ; $7169  もちものか゛ = もちものが
    db $EF,$EE                     ; $716F  newline
    db $90,$90                     ; $7171  　　(indent)
    db $42,$38,$55,$38,$8D,$39,$2B,$39,$50,$26,$27,$3A; $7173  ほとんと゛なくなるうえに = ほとんどなくなるうえに
    db $A4                         ; $717F  、
    db $FA                         ; $7180  wait-for-button
    db $F7                         ; $7181  clear page
    db $EF,$EE                     ; $7182  newline
    db $9F                         ; $7184  box tag
    db $96                         ; $7185  end name/box tag
    db $28,$29,$3C,$47             ; $7186  おかねも
    db $90                         ; $718A  　(space)
    db $3E,$55,$40,$8D,$55,$3A     ; $718B  はんふ゛んに = はんぶんに
    db $EF,$EE                     ; $7191  newline
    db $90,$90                     ; $7193  　　(indent)
    db $39,$36,$37,$2F,$43,$25,$43,$30; $7195  なってしまいます
    db $8F                         ; $719D  。
    db $FA                         ; $719E  wait-for-button
    db $F7                         ; $719F  clear page
    db $EF,$EE                     ; $71A0  newline
    db $9F                         ; $71A2  box tag
    db $96                         ; $71A3  end name/box tag
    db $37,$8D,$47                 ; $71A4  て゛も = でも
    db $90                         ; $71A7  　(space)
    db $38,$26,$24,$30,$8D,$29,$4F,$2F,$8D,$4D,$3A; $71A8  とうあす゛かりし゛ょに = とうあずかりじょに
    db $EF,$EE                     ; $71B3  newline
    db $90,$90                     ; $71B5  　　(indent)
    db $24,$30,$8D,$2C,$37,$28,$2C,$3E,$8D; $71B7  あす゛けておけは゛ = あずけておけば
    db $90                         ; $71C0  　(space)
    db $24,$55,$2F,$55,$37,$8D,$30 ; $71C1  あんしんて゛す = あんしんです
    db $8F                         ; $71C8  。
    db $FA                         ; $71C9  wait-for-button
    db $F7                         ; $71CA  clear page
    db $EF,$EE                     ; $71CB  newline
    db $9F                         ; $71CD  box tag
    db $96                         ; $71CE  end name/box tag
    db $3E,$8D,$55,$31,$8D,$55,$3D ; $71CF  は゛んせ゛んの = ばんぜんの
    db $90                         ; $71D6  　(space)
    db $2C,$25,$3F,$8D,$37,$8D     ; $71D7  けいひ゛て゛ = けいびで
    db $90                         ; $71DD  　(space)
    db $24,$39,$33,$3D             ; $71DE  あなたの
    db $EF,$EE                     ; $71E2  newline
    db $90,$90                     ; $71E4  　　(indent)
    db $33,$8D,$25,$2F,$8D,$39,$47,$3D,$54; $71E6  た゛いし゛なものを = だいじなものを
    db $90                         ; $71EF  　(space)
    db $28,$43,$47,$4F,$2F,$43,$30 ; $71F0  おまもりします
    db $99                         ; $71F7  ！
    db $F7                         ; $71F8  clear page
    db $F0                         ; $71F9  end of message


; --------------------------------------------------------------------------
; Message #163 ($71FA)
;   「きみは　しってるかい？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank67_Msg163:                             ; $71FA  (file $10F1FA)
    db $EA                         ; $71FA  ▶ new page
    db $9F                         ; $71FB  box tag
    db $96                         ; $71FC  end name/box tag
    db $2A,$44,$3E                 ; $71FD  きみは
    db $90                         ; $7200  　(space)
    db $2F,$36,$37,$50,$29,$25     ; $7201  しってるかい
    db $98                         ; $7207  ？
    db $EF,$EE                     ; $7208  newline
    db $FF                         ; $720A  はい/いいえ
    db $F0                         ; $720B  end of message


; --------------------------------------------------------------------------
; Message #164 ($720C)
;   「なんだ　つまらない。
; --------------------------------------------------------------------------
Bank67_Msg164:                             ; $720C  (file $10F20C)
    db $EA                         ; $720C  ▶ new page
    db $9F                         ; $720D  box tag
    db $96                         ; $720E  end name/box tag
    db $39,$55,$33,$8D             ; $720F  なんた゛ = なんだ
    db $90                         ; $7213  　(space)
    db $35,$43,$4E,$39,$25         ; $7214  つまらない
    db $8F                         ; $7219  。
    db $EF,$EE                     ; $721A  newline
    db $F7                         ; $721C  clear page
    db $F0                         ; $721D  end of message


; --------------------------------------------------------------------------
; Message #165 ($721E)
;   「つかまえた　まものを　けっこん
;   させる　ばしょがあるそうだよ。
;   「モンスターじいさん　というひとが
;   くわしいことを　しっているよ。
; --------------------------------------------------------------------------
Bank67_Msg165:                             ; $721E  (file $10F21E)
    db $EA                         ; $721E  ▶ new page
    db $9F                         ; $721F  box tag
    db $96                         ; $7220  end name/box tag
    db $35,$29,$43,$27,$33         ; $7221  つかまえた
    db $90                         ; $7226  　(space)
    db $43,$47,$3D,$54             ; $7227  まものを
    db $90                         ; $722B  　(space)
    db $2C,$36,$2D,$55             ; $722C  けっこん
    db $EF,$EE                     ; $7230  newline
    db $90,$90                     ; $7232  　　(indent)
    db $2E,$31,$50                 ; $7234  させる
    db $90                         ; $7237  　(space)
    db $3E,$8D,$2F,$4D,$29,$8D,$24,$50,$32,$26,$33,$8D,$4C; $7238  は゛しょか゛あるそうた゛よ = ばしょがあるそうだよ
    db $8F                         ; $7245  。
    db $FA                         ; $7246  wait-for-button
    db $F7                         ; $7247  clear page
    db $EF,$EE                     ; $7248  newline
    db $9F                         ; $724A  box tag
    db $96                         ; $724B  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $724C  モンスターし゛いさん = モンスターじいさん
    db $90                         ; $7256  　(space)
    db $38,$25,$26,$3F,$38,$29,$8D ; $7257  というひとか゛ = というひとが
    db $EF,$EE                     ; $725E  newline
    db $90,$90                     ; $7260  　　(indent)
    db $2B,$53,$2F,$25,$2D,$38,$54 ; $7262  くわしいことを
    db $90                         ; $7269  　(space)
    db $2F,$36,$37,$25,$50,$4C     ; $726A  しっているよ
    db $8F                         ; $7270  。
    db $F7                         ; $7271  clear page
    db $F0                         ; $7272  end of message


; --------------------------------------------------------------------------
; Message #166 ($7273)
;   〈テリー〉は　ほんだなを　しらべた。
;   「けいとうとは、
;   「まもののからだを　よくしらべると
;   [09]つの　しゅるいに　わけられる。
;   「この[09]つの　しゅるいのことを
;   けいとう　という。
; --------------------------------------------------------------------------
Bank67_Msg166:                             ; $7273  (file $10F273)
    db $F6                         ; $7273  «insert hero name»
    db $3E                         ; $7274  は
    db $90                         ; $7275  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $7276  ほんた゛なを = ほんだなを
    db $90                         ; $727C  　(space)
    db $2F,$4E,$41,$8D,$33         ; $727D  しらへ゛た = しらべた
    db $8F                         ; $7282  。
    db $EF,$EE                     ; $7283  newline
    db $FA                         ; $7285  wait-for-button
    db $F7                         ; $7286  clear page
    db $EF,$EE                     ; $7287  newline
    db $F3                         ; $7289  open text box
    db $96                         ; $728A  end name/box tag
    db $2C,$25,$38,$26,$38,$3E     ; $728B  けいとうとは
    db $A4                         ; $7291  、
    db $EF,$EE                     ; $7292  newline
    db $FA                         ; $7294  wait-for-button
    db $F7                         ; $7295  clear page
    db $EF,$EE                     ; $7296  newline
    db $F3                         ; $7298  open text box
    db $96                         ; $7299  end name/box tag
    db $43,$47,$3D,$3D,$29,$4E,$33,$8D,$54; $729A  まもののからた゛を = まもののからだを
    db $90                         ; $72A3  　(space)
    db $4C,$2B,$2F,$4E,$41,$8D,$50,$38; $72A4  よくしらへ゛ると = よくしらべると
    db $EF,$EE                     ; $72AC  newline
    db $90                         ; $72AE  　(space)
    db $09                         ; $72AF  ctrl $09
    db $35,$3D                     ; $72B0  つの
    db $90                         ; $72B2  　(space)
    db $2F,$4B,$50,$25,$3A         ; $72B3  しゅるいに
    db $90                         ; $72B8  　(space)
    db $53,$2C,$4E,$51,$50         ; $72B9  わけられる
    db $8F                         ; $72BE  。
    db $FA                         ; $72BF  wait-for-button
    db $F7                         ; $72C0  clear page
    db $EF,$EE                     ; $72C1  newline
    db $96                         ; $72C3  end name/box tag
    db $2D,$3D                     ; $72C4  この
    db $09                         ; $72C6  ctrl $09
    db $35,$3D                     ; $72C7  つの
    db $90                         ; $72C9  　(space)
    db $2F,$4B,$50,$25,$3D,$2D,$38,$54; $72CA  しゅるいのことを
    db $EF,$EE                     ; $72D2  newline
    db $90                         ; $72D4  　(space)
    db $2C,$25,$38,$26             ; $72D5  けいとう
    db $90                         ; $72D9  　(space)
    db $38,$25,$26                 ; $72DA  という
    db $8F                         ; $72DD  。
    db $F7                         ; $72DE  clear page
    db $F0                         ; $72DF  end of message


; --------------------------------------------------------------------------
; Message #167 ($72E0)
;   〈テリー〉は　ほんだなを　しらべた。
;   「まものの　[09]つのけいとうは
;   つぎの　とおりである。
;   「スラィムけい。
;   けものけい。
;   「むしけい。
;   しょくぶつけい。
;   「ぶっしつけい。
;   ゾンビけい。
;   「とりけい。
;   ドラゴンけい。
;   「あくまけい。
;   そして、、。
; --------------------------------------------------------------------------
Bank67_Msg167:                             ; $72E0  (file $10F2E0)
    db $F6                         ; $72E0  «insert hero name»
    db $3E                         ; $72E1  は
    db $90                         ; $72E2  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $72E3  ほんた゛なを = ほんだなを
    db $90                         ; $72E9  　(space)
    db $2F,$4E,$41,$8D,$33         ; $72EA  しらへ゛た = しらべた
    db $8F                         ; $72EF  。
    db $EF,$EE                     ; $72F0  newline
    db $FA                         ; $72F2  wait-for-button
    db $F7                         ; $72F3  clear page
    db $EF,$EE                     ; $72F4  newline
    db $F3                         ; $72F6  open text box
    db $96                         ; $72F7  end name/box tag
    db $43,$47,$3D,$3D             ; $72F8  まものの
    db $90                         ; $72FC  　(space)
    db $09                         ; $72FD  ctrl $09
    db $35,$3D,$2C,$25,$38,$26,$3E ; $72FE  つのけいとうは
    db $EF,$EE                     ; $7305  newline
    db $90                         ; $7307  　(space)
    db $35,$2A,$8D,$3D             ; $7308  つき゛の = つぎの
    db $90                         ; $730C  　(space)
    db $38,$28,$4F,$37,$8D,$24,$50 ; $730D  とおりて゛ある = とおりである
    db $8F                         ; $7314  。
    db $FA                         ; $7315  wait-for-button
    db $F7                         ; $7316  clear page
    db $EF,$EE                     ; $7317  newline
    db $96                         ; $7319  end name/box tag
    db $67,$85,$58,$7C,$2C,$25     ; $731A  スラィムけい
    db $8F                         ; $7320  。
    db $EF,$EE                     ; $7321  newline
    db $90                         ; $7323  　(space)
    db $2C,$47,$3D,$2C,$25         ; $7324  けものけい
    db $8F                         ; $7329  。
    db $FA                         ; $732A  wait-for-button
    db $F7                         ; $732B  clear page
    db $EF,$EE                     ; $732C  newline
    db $96                         ; $732E  end name/box tag
    db $45,$2F,$2C,$25             ; $732F  むしけい
    db $8F                         ; $7333  。
    db $EF,$EE                     ; $7334  newline
    db $90                         ; $7336  　(space)
    db $2F,$4D,$2B,$40,$8D,$35,$2C,$25; $7337  しょくふ゛つけい = しょくぶつけい
    db $8F                         ; $733F  。
    db $FA                         ; $7340  wait-for-button
    db $F7                         ; $7341  clear page
    db $EF,$EE                     ; $7342  newline
    db $96                         ; $7344  end name/box tag
    db $40,$8D,$36,$2F,$35,$2C,$25 ; $7345  ふ゛っしつけい = ぶっしつけい
    db $8F                         ; $734C  。
    db $EF,$EE                     ; $734D  newline
    db $90                         ; $734F  　(space)
    db $69,$8D,$8C,$76,$8D,$2C,$25 ; $7350  ソ゛ンヒ゛けい = ゾンビけい
    db $8F                         ; $7357  。
    db $FA                         ; $7358  wait-for-button
    db $F7                         ; $7359  clear page
    db $EF,$EE                     ; $735A  newline
    db $96                         ; $735C  end name/box tag
    db $38,$4F,$2C,$25             ; $735D  とりけい
    db $8F                         ; $7361  。
    db $EF,$EE                     ; $7362  newline
    db $90                         ; $7364  　(space)
    db $6F,$8D,$85,$64,$8D,$8C,$2C,$25; $7365  ト゛ラコ゛ンけい = ドラゴンけい
    db $8F                         ; $736D  。
    db $FA                         ; $736E  wait-for-button
    db $F7                         ; $736F  clear page
    db $EF,$EE                     ; $7370  newline
    db $96                         ; $7372  end name/box tag
    db $24,$2B,$43,$2C,$25         ; $7373  あくまけい
    db $8F                         ; $7378  。
    db $EF,$EE                     ; $7379  newline
    db $90                         ; $737B  　(space)
    db $32,$2F,$37                 ; $737C  そして
    db $A4                         ; $737F  、
    db $A4                         ; $7380  、
    db $8F                         ; $7381  。
    db $F7                         ; $7382  clear page
    db $F0                         ; $7383  end of message


; --------------------------------------------------------------------------
; Message #168 ($7384)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[01]せつ、
;   「きんぞくを　ねりあわせ　きたえると
;   さらに　かたくなる、。
; --------------------------------------------------------------------------
Bank67_Msg168:                             ; $7384  (file $10F384)
    db $F6                         ; $7384  «insert hero name»
    db $3E                         ; $7385  は
    db $90                         ; $7386  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $7387  ほんた゛なを = ほんだなを
    db $90                         ; $738D  　(space)
    db $2F,$4E,$41,$8D,$33         ; $738E  しらへ゛た = しらべた
    db $8F                         ; $7393  。
    db $EF,$EE                     ; $7394  newline
    db $FA                         ; $7396  wait-for-button
    db $F7                         ; $7397  clear page
    db $EF,$EE                     ; $7398  newline
    db $F3                         ; $739A  open text box
    db $96                         ; $739B  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $739C  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $73A5  、
    db $33,$8D,$25                 ; $73A6  た゛い = だい
    db $01                         ; $73A9  ctrl $01
    db $31,$35                     ; $73AA  せつ
    db $A4                         ; $73AC  、
    db $EF,$EE                     ; $73AD  newline
    db $FA                         ; $73AF  wait-for-button
    db $F7                         ; $73B0  clear page
    db $EF,$EE                     ; $73B1  newline
    db $F3                         ; $73B3  open text box
    db $96                         ; $73B4  end name/box tag
    db $2A,$55,$32,$8D,$2B,$54     ; $73B5  きんそ゛くを = きんぞくを
    db $90                         ; $73BB  　(space)
    db $3C,$4F,$24,$53,$31         ; $73BC  ねりあわせ
    db $90                         ; $73C1  　(space)
    db $2A,$33,$27,$50,$38         ; $73C2  きたえると
    db $EF,$EE                     ; $73C7  newline
    db $90                         ; $73C9  　(space)
    db $2E,$4E,$3A                 ; $73CA  さらに
    db $90                         ; $73CD  　(space)
    db $29,$33,$2B,$39,$50         ; $73CE  かたくなる
    db $A4                         ; $73D3  、
    db $8F                         ; $73D4  。
    db $F7                         ; $73D5  clear page
    db $F0                         ; $73D6  end of message


; --------------------------------------------------------------------------
; Message #169 ($73D7)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[02]せつ、
;   「けものの　もっともこい　ち　から
;   ひゃくじゅうのおうが　うまれる、。
; --------------------------------------------------------------------------
Bank67_Msg169:                             ; $73D7  (file $10F3D7)
    db $F6                         ; $73D7  «insert hero name»
    db $3E                         ; $73D8  は
    db $90                         ; $73D9  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $73DA  ほんた゛なを = ほんだなを
    db $90                         ; $73E0  　(space)
    db $2F,$4E,$41,$8D,$33         ; $73E1  しらへ゛た = しらべた
    db $8F                         ; $73E6  。
    db $EF,$EE                     ; $73E7  newline
    db $FA                         ; $73E9  wait-for-button
    db $F7                         ; $73EA  clear page
    db $EF,$EE                     ; $73EB  newline
    db $F3                         ; $73ED  open text box
    db $96                         ; $73EE  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $73EF  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $73F8  、
    db $33,$8D,$25                 ; $73F9  た゛い = だい
    db $02                         ; $73FC  ctrl $02
    db $31,$35                     ; $73FD  せつ
    db $A4                         ; $73FF  、
    db $EF,$EE                     ; $7400  newline
    db $FA                         ; $7402  wait-for-button
    db $F7                         ; $7403  clear page
    db $EF,$EE                     ; $7404  newline
    db $F3                         ; $7406  open text box
    db $96                         ; $7407  end name/box tag
    db $2C,$47,$3D,$3D             ; $7408  けものの
    db $90                         ; $740C  　(space)
    db $47,$36,$38,$47,$2D,$25     ; $740D  もっともこい
    db $90                         ; $7413  　(space)
    db $34                         ; $7414  ち
    db $90                         ; $7415  　(space)
    db $29,$4E                     ; $7416  から
    db $EF,$EE                     ; $7418  newline
    db $90                         ; $741A  　(space)
    db $3F,$49,$2B,$2F,$8D,$4B,$26,$3D,$28,$26,$29,$8D; $741B  ひゃくし゛ゅうのおうか゛ = ひゃくじゅうのおうが
    db $90                         ; $7427  　(space)
    db $26,$43,$51,$50             ; $7428  うまれる
    db $A4                         ; $742C  、
    db $8F                         ; $742D  。
    db $F7                         ; $742E  clear page
    db $F0                         ; $742F  end of message


; --------------------------------------------------------------------------
; Message #170 ($7430)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[03]せつ、
;   「ドラゴンの　ち　には　かみのごとき
;   ちからが　ねむっている、。
; --------------------------------------------------------------------------
Bank67_Msg170:                             ; $7430  (file $10F430)
    db $F6                         ; $7430  «insert hero name»
    db $3E                         ; $7431  は
    db $90                         ; $7432  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $7433  ほんた゛なを = ほんだなを
    db $90                         ; $7439  　(space)
    db $2F,$4E,$41,$8D,$33         ; $743A  しらへ゛た = しらべた
    db $8F                         ; $743F  。
    db $EF,$EE                     ; $7440  newline
    db $FA                         ; $7442  wait-for-button
    db $F7                         ; $7443  clear page
    db $EF,$EE                     ; $7444  newline
    db $F3                         ; $7446  open text box
    db $96                         ; $7447  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $7448  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $7451  、
    db $33,$8D,$25                 ; $7452  た゛い = だい
    db $03                         ; $7455  ctrl $03
    db $31,$35                     ; $7456  せつ
    db $A4                         ; $7458  、
    db $EF,$EE                     ; $7459  newline
    db $FA                         ; $745B  wait-for-button
    db $F7                         ; $745C  clear page
    db $EF,$EE                     ; $745D  newline
    db $F3                         ; $745F  open text box
    db $96                         ; $7460  end name/box tag
    db $6F,$8D,$85,$64,$8D,$8C,$3D ; $7461  ト゛ラコ゛ンの = ドラゴンの
    db $90                         ; $7468  　(space)
    db $34                         ; $7469  ち
    db $90                         ; $746A  　(space)
    db $3A,$3E                     ; $746B  には
    db $90                         ; $746D  　(space)
    db $29,$44,$3D,$2D,$8D,$38,$2A ; $746E  かみのこ゛とき = かみのごとき
    db $EF,$EE                     ; $7475  newline
    db $90                         ; $7477  　(space)
    db $34,$29,$4E,$29,$8D         ; $7478  ちからか゛ = ちからが
    db $90                         ; $747D  　(space)
    db $3C,$45,$36,$37,$25,$50     ; $747E  ねむっている
    db $A4                         ; $7484  、
    db $8F                         ; $7485  。
    db $F7                         ; $7486  clear page
    db $F0                         ; $7487  end of message


; --------------------------------------------------------------------------
; Message #171 ($7488)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[04]せつ、
;   「ひんしゅかいりょうで　うみだされた
;   うつくしいバラには　トゲがある、。
; --------------------------------------------------------------------------
Bank67_Msg171:                             ; $7488  (file $10F488)
    db $F6                         ; $7488  «insert hero name»
    db $3E                         ; $7489  は
    db $90                         ; $748A  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $748B  ほんた゛なを = ほんだなを
    db $90                         ; $7491  　(space)
    db $2F,$4E,$41,$8D,$33         ; $7492  しらへ゛た = しらべた
    db $8F                         ; $7497  。
    db $EF,$EE                     ; $7498  newline
    db $FA                         ; $749A  wait-for-button
    db $F7                         ; $749B  clear page
    db $EF,$EE                     ; $749C  newline
    db $F3                         ; $749E  open text box
    db $96                         ; $749F  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $74A0  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $74A9  、
    db $33,$8D,$25                 ; $74AA  た゛い = だい
    db $04                         ; $74AD  ctrl $04
    db $31,$35                     ; $74AE  せつ
    db $A4                         ; $74B0  、
    db $EF,$EE                     ; $74B1  newline
    db $FA                         ; $74B3  wait-for-button
    db $F7                         ; $74B4  clear page
    db $EF,$EE                     ; $74B5  newline
    db $F3                         ; $74B7  open text box
    db $96                         ; $74B8  end name/box tag
    db $3F,$55,$2F,$4B,$29,$25,$4F,$4D,$26,$37,$8D; $74B9  ひんしゅかいりょうて゛ = ひんしゅかいりょうで
    db $90                         ; $74C4  　(space)
    db $26,$44,$33,$8D,$2E,$51,$33 ; $74C5  うみた゛された = うみだされた
    db $EF,$EE                     ; $74CC  newline
    db $90                         ; $74CE  　(space)
    db $26,$35,$2B,$2F,$25,$75,$8D,$85,$3A,$3E; $74CF  うつくしいハ゛ラには = うつくしいバラには
    db $90                         ; $74D9  　(space)
    db $6F,$63,$8D,$29,$8D,$24,$50 ; $74DA  トケ゛か゛ある = トゲがある
    db $A4                         ; $74E1  、
    db $8F                         ; $74E2  。
    db $F7                         ; $74E3  clear page
    db $F0                         ; $74E4  end of message


; --------------------------------------------------------------------------
; Message #172 ($74E5)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[05]せつ、
;   「こおりを　ほのおが　とかし
;   おおきなにじが　できた、。
; --------------------------------------------------------------------------
Bank67_Msg172:                             ; $74E5  (file $10F4E5)
    db $F6                         ; $74E5  «insert hero name»
    db $3E                         ; $74E6  は
    db $90                         ; $74E7  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $74E8  ほんた゛なを = ほんだなを
    db $90                         ; $74EE  　(space)
    db $2F,$4E,$41,$8D,$33         ; $74EF  しらへ゛た = しらべた
    db $8F                         ; $74F4  。
    db $EF,$EE                     ; $74F5  newline
    db $FA                         ; $74F7  wait-for-button
    db $F7                         ; $74F8  clear page
    db $EF,$EE                     ; $74F9  newline
    db $F3                         ; $74FB  open text box
    db $96                         ; $74FC  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $74FD  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $7506  、
    db $33,$8D,$25                 ; $7507  た゛い = だい
    db $05                         ; $750A  ctrl $05
    db $31,$35                     ; $750B  せつ
    db $A4                         ; $750D  、
    db $EF,$EE                     ; $750E  newline
    db $FA                         ; $7510  wait-for-button
    db $F7                         ; $7511  clear page
    db $EF,$EE                     ; $7512  newline
    db $F3                         ; $7514  open text box
    db $96                         ; $7515  end name/box tag
    db $2D,$28,$4F,$54             ; $7516  こおりを
    db $90                         ; $751A  　(space)
    db $42,$3D,$28,$29,$8D         ; $751B  ほのおか゛ = ほのおが
    db $90                         ; $7520  　(space)
    db $38,$29,$2F                 ; $7521  とかし
    db $EF,$EE                     ; $7524  newline
    db $90                         ; $7526  　(space)
    db $28,$28,$2A,$39,$3A,$2F,$8D,$29,$8D; $7527  おおきなにし゛か゛ = おおきなにじが
    db $90                         ; $7530  　(space)
    db $37,$8D,$2A,$33             ; $7531  て゛きた = できた
    db $A4                         ; $7535  、
    db $8F                         ; $7536  。
    db $F7                         ; $7537  clear page
    db $F0                         ; $7538  end of message


; --------------------------------------------------------------------------
; Message #173 ($7539)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[06]せつ、
;   「おおくの　まよいし　たましいが
;   いだいなるおうを　うみだす、。
; --------------------------------------------------------------------------
Bank67_Msg173:                             ; $7539  (file $10F539)
    db $F6                         ; $7539  «insert hero name»
    db $3E                         ; $753A  は
    db $90                         ; $753B  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $753C  ほんた゛なを = ほんだなを
    db $90                         ; $7542  　(space)
    db $2F,$4E,$41,$8D,$33         ; $7543  しらへ゛た = しらべた
    db $8F                         ; $7548  。
    db $EF,$EE                     ; $7549  newline
    db $FA                         ; $754B  wait-for-button
    db $F7                         ; $754C  clear page
    db $EF,$EE                     ; $754D  newline
    db $F3                         ; $754F  open text box
    db $96                         ; $7550  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $7551  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $755A  、
    db $33,$8D,$25                 ; $755B  た゛い = だい
    db $06                         ; $755E  ctrl $06
    db $31,$35                     ; $755F  せつ
    db $A4                         ; $7561  、
    db $EF,$EE                     ; $7562  newline
    db $FA                         ; $7564  wait-for-button
    db $F7                         ; $7565  clear page
    db $EF,$EE                     ; $7566  newline
    db $F3                         ; $7568  open text box
    db $96                         ; $7569  end name/box tag
    db $28,$28,$2B,$3D             ; $756A  おおくの
    db $90                         ; $756E  　(space)
    db $43,$4C,$25,$2F             ; $756F  まよいし
    db $90                         ; $7573  　(space)
    db $33,$43,$2F,$25,$29,$8D     ; $7574  たましいか゛ = たましいが
    db $EF,$EE                     ; $757A  newline
    db $90                         ; $757C  　(space)
    db $25,$33,$8D,$25,$39,$50,$28,$26,$54; $757D  いた゛いなるおうを = いだいなるおうを
    db $90                         ; $7586  　(space)
    db $26,$44,$33,$8D,$30         ; $7587  うみた゛す = うみだす
    db $A4                         ; $758C  、
    db $8F                         ; $758D  。
    db $F7                         ; $758E  clear page
    db $F0                         ; $758F  end of message


; --------------------------------------------------------------------------
; Message #174 ($7590)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[07]せつ、
;   「いのちのほのおに　あつまった
;   むしたちは　かがやきをます、。
; --------------------------------------------------------------------------
Bank67_Msg174:                             ; $7590  (file $10F590)
    db $F6                         ; $7590  «insert hero name»
    db $3E                         ; $7591  は
    db $90                         ; $7592  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $7593  ほんた゛なを = ほんだなを
    db $90                         ; $7599  　(space)
    db $2F,$4E,$41,$8D,$33         ; $759A  しらへ゛た = しらべた
    db $8F                         ; $759F  。
    db $EF,$EE                     ; $75A0  newline
    db $FA                         ; $75A2  wait-for-button
    db $F7                         ; $75A3  clear page
    db $EF,$EE                     ; $75A4  newline
    db $F3                         ; $75A6  open text box
    db $96                         ; $75A7  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $75A8  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $75B1  、
    db $33,$8D,$25                 ; $75B2  た゛い = だい
    db $07                         ; $75B5  ctrl $07
    db $31,$35                     ; $75B6  せつ
    db $A4                         ; $75B8  、
    db $EF,$EE                     ; $75B9  newline
    db $FA                         ; $75BB  wait-for-button
    db $F7                         ; $75BC  clear page
    db $EF,$EE                     ; $75BD  newline
    db $F3                         ; $75BF  open text box
    db $96                         ; $75C0  end name/box tag
    db $25,$3D,$34,$3D,$42,$3D,$28,$3A; $75C1  いのちのほのおに
    db $90                         ; $75C9  　(space)
    db $24,$35,$43,$36,$33         ; $75CA  あつまった
    db $EF,$EE                     ; $75CF  newline
    db $90                         ; $75D1  　(space)
    db $45,$2F,$33,$34,$3E         ; $75D2  むしたちは
    db $90                         ; $75D7  　(space)
    db $29,$29,$8D,$48,$2A,$54,$43,$30; $75D8  かか゛やきをます = かがやきをます
    db $A4                         ; $75E0  、
    db $8F                         ; $75E1  。
    db $F7                         ; $75E2  clear page
    db $F0                         ; $75E3  end of message


; --------------------------------------------------------------------------
; Message #175 ($75E4)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[08]せつ、
;   「とくぎは　きたえれば　さらに
;   しんかする　ことがある、。
; --------------------------------------------------------------------------
Bank67_Msg175:                             ; $75E4  (file $10F5E4)
    db $F6                         ; $75E4  «insert hero name»
    db $3E                         ; $75E5  は
    db $90                         ; $75E6  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $75E7  ほんた゛なを = ほんだなを
    db $90                         ; $75ED  　(space)
    db $2F,$4E,$41,$8D,$33         ; $75EE  しらへ゛た = しらべた
    db $8F                         ; $75F3  。
    db $EF,$EE                     ; $75F4  newline
    db $FA                         ; $75F6  wait-for-button
    db $F7                         ; $75F7  clear page
    db $EF,$EE                     ; $75F8  newline
    db $F3                         ; $75FA  open text box
    db $96                         ; $75FB  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $75FC  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $7605  、
    db $33,$8D,$25                 ; $7606  た゛い = だい
    db $08                         ; $7609  ctrl $08
    db $31,$35                     ; $760A  せつ
    db $A4                         ; $760C  、
    db $EF,$EE                     ; $760D  newline
    db $FA                         ; $760F  wait-for-button
    db $F7                         ; $7610  clear page
    db $EF,$EE                     ; $7611  newline
    db $F3                         ; $7613  open text box
    db $96                         ; $7614  end name/box tag
    db $38,$2B,$2A,$8D,$3E         ; $7615  とくき゛は = とくぎは
    db $90                         ; $761A  　(space)
    db $2A,$33,$27,$51,$3E,$8D     ; $761B  きたえれは゛ = きたえれば
    db $90                         ; $7621  　(space)
    db $2E,$4E,$3A                 ; $7622  さらに
    db $EF,$EE                     ; $7625  newline
    db $90                         ; $7627  　(space)
    db $2F,$55,$29,$30,$50         ; $7628  しんかする
    db $90                         ; $762D  　(space)
    db $2D,$38,$29,$8D,$24,$50     ; $762E  ことか゛ある = ことがある
    db $A4                         ; $7634  、
    db $8F                         ; $7635  。
    db $F7                         ; $7636  clear page
    db $F0                         ; $7637  end of message


; --------------------------------------------------------------------------
; Message #176 ($7638)
;   〈テリー〉は　ほんだなを　しらべた。
;   「シォンよげんしょ、だい[09]せつ、
;   「しんのマスターと　みとめられしとき
;   まおうへとつづく　とびらはひらく。
; --------------------------------------------------------------------------
Bank67_Msg176:                             ; $7638  (file $10F638)
    db $F6                         ; $7638  «insert hero name»
    db $3E                         ; $7639  は
    db $90                         ; $763A  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $763B  ほんた゛なを = ほんだなを
    db $90                         ; $7641  　(space)
    db $2F,$4E,$41,$8D,$33         ; $7642  しらへ゛た = しらべた
    db $8F                         ; $7647  。
    db $EF,$EE                     ; $7648  newline
    db $FA                         ; $764A  wait-for-button
    db $F7                         ; $764B  clear page
    db $EF,$EE                     ; $764C  newline
    db $F3                         ; $764E  open text box
    db $96                         ; $764F  end name/box tag
    db $66,$5E,$8C,$4C,$2C,$8D,$55,$2F,$4D; $7650  シォンよけ゛んしょ = シォンよげんしょ
    db $A4                         ; $7659  、
    db $33,$8D,$25                 ; $765A  た゛い = だい
    db $09                         ; $765D  ctrl $09
    db $31,$35                     ; $765E  せつ
    db $A4                         ; $7660  、
    db $EF,$EE                     ; $7661  newline
    db $FA                         ; $7663  wait-for-button
    db $F7                         ; $7664  clear page
    db $EF,$EE                     ; $7665  newline
    db $F3                         ; $7667  open text box
    db $96                         ; $7668  end name/box tag
    db $2F,$55,$3D,$7A,$67,$6A,$9C,$38; $7669  しんのマスターと
    db $90                         ; $7671  　(space)
    db $44,$38,$46,$4E,$51,$2F,$38,$2A; $7672  みとめられしとき
    db $EF,$EE                     ; $767A  newline
    db $90                         ; $767C  　(space)
    db $43,$28,$26,$41,$38,$35,$35,$8D,$2B; $767D  まおうへとつつ゛く = まおうへとつづく
    db $90                         ; $7686  　(space)
    db $38,$3F,$8D,$4E,$3E,$3F,$4E,$2B; $7687  とひ゛らはひらく = とびらはひらく
    db $8F                         ; $768F  。
    db $F7                         ; $7690  clear page
    db $F0                         ; $7691  end of message


; --------------------------------------------------------------------------
; Message #177 ($7692)
;   〈テリー〉は　はりがみを　よんだ。
;   「ほんには　えらいひとの　ありがたい
;   ちしきが　つまっています。
; --------------------------------------------------------------------------
Bank67_Msg177:                             ; $7692  (file $10F692)
    db $F6                         ; $7692  «insert hero name»
    db $3E                         ; $7693  は
    db $90                         ; $7694  　(space)
    db $3E,$4F,$29,$8D,$44,$54     ; $7695  はりか゛みを = はりがみを
    db $90                         ; $769B  　(space)
    db $4C,$55,$33,$8D             ; $769C  よんた゛ = よんだ
    db $8F                         ; $76A0  。
    db $EF,$EE                     ; $76A1  newline
    db $FA                         ; $76A3  wait-for-button
    db $F7                         ; $76A4  clear page
    db $EF,$EE                     ; $76A5  newline
    db $F3                         ; $76A7  open text box
    db $96                         ; $76A8  end name/box tag
    db $42,$55,$3A,$3E             ; $76A9  ほんには
    db $90                         ; $76AD  　(space)
    db $27,$4E,$25,$3F,$38,$3D     ; $76AE  えらいひとの
    db $90                         ; $76B4  　(space)
    db $24,$4F,$29,$8D,$33,$25     ; $76B5  ありか゛たい = ありがたい
    db $EF,$EE                     ; $76BB  newline
    db $90                         ; $76BD  　(space)
    db $34,$2F,$2A,$29,$8D         ; $76BE  ちしきか゛ = ちしきが
    db $90                         ; $76C3  　(space)
    db $35,$43,$36,$37,$25,$43,$30 ; $76C4  つまっています
    db $8F                         ; $76CB  。
    db $F7                         ; $76CC  clear page
    db $F0                         ; $76CD  end of message


; --------------------------------------------------------------------------
; Message #178 ($76CE)
;   「やあ　よくきたね。
;   ここは　としょかんだよ。
;   「まもののことが　しりたいときは
;   わたしを　たずねておくれ。
;   「きみが　つかまえた　まものの
;   ことなら　おしえてあげるよ。
;   「きょうは　どのけいとうの
;   まもののことを　しらべたい？
; --------------------------------------------------------------------------
Bank67_Msg178:                             ; $76CE  (file $10F6CE)
    db $EA                         ; $76CE  ▶ new page
    db $9F                         ; $76CF  box tag
    db $96                         ; $76D0  end name/box tag
    db $48,$24                     ; $76D1  やあ
    db $90                         ; $76D3  　(space)
    db $4C,$2B,$2A,$33,$3C         ; $76D4  よくきたね
    db $8F                         ; $76D9  。
    db $EF,$EE                     ; $76DA  newline
    db $90,$90                     ; $76DC  　　(indent)
    db $2D,$2D,$3E                 ; $76DE  ここは
    db $90                         ; $76E1  　(space)
    db $38,$2F,$4D,$29,$55,$33,$8D,$4C; $76E2  としょかんた゛よ = としょかんだよ
    db $8F                         ; $76EA  。
    db $FA                         ; $76EB  wait-for-button
    db $F7                         ; $76EC  clear page
    db $EF,$EE                     ; $76ED  newline
    db $9F                         ; $76EF  box tag
    db $96                         ; $76F0  end name/box tag
    db $43,$47,$3D,$3D,$2D,$38,$29,$8D; $76F1  まもののことか゛ = まもののことが
    db $90                         ; $76F9  　(space)
    db $2F,$4F,$33,$25,$38,$2A,$3E ; $76FA  しりたいときは
    db $EF,$EE                     ; $7701  newline
    db $90,$90                     ; $7703  　　(indent)
    db $53,$33,$2F,$54             ; $7705  わたしを
    db $90                         ; $7709  　(space)
    db $33,$30,$8D,$3C,$37,$28,$2B,$51; $770A  たす゛ねておくれ = たずねておくれ
    db $8F                         ; $7712  。
    db $FA                         ; $7713  wait-for-button
    db $F7                         ; $7714  clear page
    db $EF,$EE                     ; $7715  newline
    db $9F                         ; $7717  box tag
    db $96                         ; $7718  end name/box tag
    db $2A,$44,$29,$8D             ; $7719  きみか゛ = きみが
    db $90                         ; $771D  　(space)
    db $35,$29,$43,$27,$33         ; $771E  つかまえた
    db $90                         ; $7723  　(space)
    db $43,$47,$3D,$3D             ; $7724  まものの
    db $EF,$EE                     ; $7728  newline
    db $90,$90                     ; $772A  　　(indent)
    db $2D,$38,$39,$4E             ; $772C  ことなら
    db $90                         ; $7730  　(space)
    db $28,$2F,$27,$37,$24,$2C,$8D,$50,$4C; $7731  おしえてあけ゛るよ = おしえてあげるよ
    db $8F                         ; $773A  。
    db $FA                         ; $773B  wait-for-button
    db $F7                         ; $773C  clear page
    db $EF,$EE                     ; $773D  newline
    db $9F                         ; $773F  box tag
    db $96                         ; $7740  end name/box tag
    db $2A,$4D,$26,$3E             ; $7741  きょうは
    db $90                         ; $7745  　(space)
    db $38,$8D,$3D,$2C,$25,$38,$26,$3D; $7746  と゛のけいとうの = どのけいとうの
    db $EF,$EE                     ; $774E  newline
    db $90,$90                     ; $7750  　　(indent)
    db $43,$47,$3D,$3D,$2D,$38,$54 ; $7752  まもののことを
    db $90                         ; $7759  　(space)
    db $2F,$4E,$41,$8D,$33,$25     ; $775A  しらへ゛たい = しらべたい
    db $98                         ; $7760  ？
    db $F0                         ; $7761  end of message


; --------------------------------------------------------------------------
; Message #179 ($7762)
;   「このおくには　たいせつな　ほんが
;   しまってあるの。
;   「まものを[01][00][00]しゅるい　なかまに
;   できたら　いれてあげようかな。
; --------------------------------------------------------------------------
Bank67_Msg179:                             ; $7762  (file $10F762)
    db $EB                         ; $7762  ▶ new page
    db $9F                         ; $7763  box tag
    db $96                         ; $7764  end name/box tag
    db $2D,$3D,$28,$2B,$3A,$3E     ; $7765  このおくには
    db $90                         ; $776B  　(space)
    db $33,$25,$31,$35,$39         ; $776C  たいせつな
    db $90                         ; $7771  　(space)
    db $42,$55,$29,$8D             ; $7772  ほんか゛ = ほんが
    db $EF,$EE                     ; $7776  newline
    db $90,$90                     ; $7778  　　(indent)
    db $2F,$43,$36,$37,$24,$50,$3D ; $777A  しまってあるの
    db $8F                         ; $7781  。
    db $FA                         ; $7782  wait-for-button
    db $F7                         ; $7783  clear page
    db $EF,$EE                     ; $7784  newline
    db $9F                         ; $7786  box tag
    db $96                         ; $7787  end name/box tag
    db $43,$47,$3D,$54             ; $7788  まものを
    db $01                         ; $778C  ctrl $01
    db $00                         ; $778D  ctrl $00
    db $00                         ; $778E  ctrl $00
    db $2F,$4B,$50,$25             ; $778F  しゅるい
    db $90                         ; $7793  　(space)
    db $39,$29,$43,$3A             ; $7794  なかまに
    db $EF,$EE                     ; $7798  newline
    db $90,$90                     ; $779A  　　(indent)
    db $37,$8D,$2A,$33,$4E         ; $779C  て゛きたら = できたら
    db $90                         ; $77A1  　(space)
    db $25,$51,$37,$24,$2C,$8D,$4C,$26,$29,$39; $77A2  いれてあけ゛ようかな = いれてあげようかな
    db $8F                         ; $77AC  。
    db $F7                         ; $77AD  clear page
    db $F0                         ; $77AE  end of message


; --------------------------------------------------------------------------
; Message #180 ($77AF)
;   「いらっしゃいませ。
;   ここは　どうぐやです。
;   「ぼうけんには　きけんが
;   つきものです。
;   「でかけるまえに　ひつようなものを
;   そろえたほうが　いいですよ！
;   「ほんじつは　どんな
;   ごようですか？
; --------------------------------------------------------------------------
Bank67_Msg180:                             ; $77AF  (file $10F7AF)
    db $EA                         ; $77AF  ▶ new page
    db $9F                         ; $77B0  box tag
    db $96                         ; $77B1  end name/box tag
    db $25,$4E,$36,$2F,$49,$25,$43,$31; $77B2  いらっしゃいませ
    db $8F                         ; $77BA  。
    db $EF,$EE                     ; $77BB  newline
    db $90,$90                     ; $77BD  　　(indent)
    db $2D,$2D,$3E                 ; $77BF  ここは
    db $90                         ; $77C2  　(space)
    db $38,$8D,$26,$2B,$8D,$48,$37,$8D,$30; $77C3  と゛うく゛やて゛す = どうぐやです
    db $8F                         ; $77CC  。
    db $FA                         ; $77CD  wait-for-button
    db $F7                         ; $77CE  clear page
    db $EF,$EE                     ; $77CF  newline
    db $9F                         ; $77D1  box tag
    db $96                         ; $77D2  end name/box tag
    db $42,$8D,$26,$2C,$55,$3A,$3E ; $77D3  ほ゛うけんには = ぼうけんには
    db $90                         ; $77DA  　(space)
    db $2A,$2C,$55,$29,$8D         ; $77DB  きけんか゛ = きけんが
    db $EF,$EE                     ; $77E0  newline
    db $90,$90                     ; $77E2  　　(indent)
    db $35,$2A,$47,$3D,$37,$8D,$30 ; $77E4  つきものて゛す = つきものです
    db $8F                         ; $77EB  。
    db $FA                         ; $77EC  wait-for-button
    db $F7                         ; $77ED  clear page
    db $EF,$EE                     ; $77EE  newline
    db $9F                         ; $77F0  box tag
    db $96                         ; $77F1  end name/box tag
    db $37,$8D,$29,$2C,$50,$43,$27,$3A; $77F2  て゛かけるまえに = でかけるまえに
    db $90                         ; $77FA  　(space)
    db $3F,$35,$4C,$26,$39,$47,$3D,$54; $77FB  ひつようなものを
    db $EF,$EE                     ; $7803  newline
    db $90,$90                     ; $7805  　　(indent)
    db $32,$52,$27,$33,$42,$26,$29,$8D; $7807  そろえたほうか゛ = そろえたほうが
    db $90                         ; $780F  　(space)
    db $25,$25,$37,$8D,$30,$4C     ; $7810  いいて゛すよ = いいですよ
    db $99                         ; $7816  ！
    db $FA                         ; $7817  wait-for-button
    db $F7                         ; $7818  clear page
    db $EF,$EE                     ; $7819  newline
    db $9F                         ; $781B  box tag
    db $96                         ; $781C  end name/box tag
    db $42,$55,$2F,$8D,$35,$3E     ; $781D  ほんし゛つは = ほんじつは
    db $90                         ; $7823  　(space)
    db $38,$8D,$55,$39             ; $7824  と゛んな = どんな
    db $EF,$EE                     ; $7828  newline
    db $90,$90                     ; $782A  　　(indent)
    db $2D,$8D,$4C,$26,$37,$8D,$30,$29; $782C  こ゛ようて゛すか = ごようですか
    db $98                         ; $7834  ？
    db $F0                         ; $7835  end of message


; --------------------------------------------------------------------------
; Message #181 ($7836)
;   「わたしは　まものの　けんきゅうを
;   している　てんさいがくしゃだ。
;   「しかも　いちりゅうの
;   マスターでもある。
;   「わたしは　けんきゅうちゅうだ。
;   じゃましないでくれたまえ！
; --------------------------------------------------------------------------
Bank67_Msg181:                             ; $7836  (file $10F836)
    db $EA                         ; $7836  ▶ new page
    db $9F                         ; $7837  box tag
    db $96                         ; $7838  end name/box tag
    db $53,$33,$2F,$3E             ; $7839  わたしは
    db $90                         ; $783D  　(space)
    db $43,$47,$3D,$3D             ; $783E  まものの
    db $90                         ; $7842  　(space)
    db $2C,$55,$2A,$4B,$26,$54     ; $7843  けんきゅうを
    db $EF,$EE                     ; $7849  newline
    db $90,$90                     ; $784B  　　(indent)
    db $2F,$37,$25,$50             ; $784D  している
    db $90                         ; $7851  　(space)
    db $37,$55,$2E,$25,$29,$8D,$2B,$2F,$49,$33,$8D; $7852  てんさいか゛くしゃた゛ = てんさいがくしゃだ
    db $8F                         ; $785D  。
    db $FA                         ; $785E  wait-for-button
    db $F7                         ; $785F  clear page
    db $EF,$EE                     ; $7860  newline
    db $9F                         ; $7862  box tag
    db $96                         ; $7863  end name/box tag
    db $2F,$29,$47                 ; $7864  しかも
    db $90                         ; $7867  　(space)
    db $25,$34,$4F,$4B,$26,$3D     ; $7868  いちりゅうの
    db $EF,$EE                     ; $786E  newline
    db $90,$90                     ; $7870  　　(indent)
    db $7A,$67,$6A,$9C,$37,$8D,$47,$24,$50; $7872  マスターて゛もある = マスターでもある
    db $8F                         ; $787B  。
    db $FA                         ; $787C  wait-for-button
    db $F7                         ; $787D  clear page
    db $EF,$EE                     ; $787E  newline
    db $9F                         ; $7880  box tag
    db $96                         ; $7881  end name/box tag
    db $53,$33,$2F,$3E             ; $7882  わたしは
    db $90                         ; $7886  　(space)
    db $2C,$55,$2A,$4B,$26,$34,$4B,$26,$33,$8D; $7887  けんきゅうちゅうた゛ = けんきゅうちゅうだ
    db $8F                         ; $7891  。
    db $EF,$EE                     ; $7892  newline
    db $90,$90                     ; $7894  　　(indent)
    db $2F,$8D,$49,$43,$2F,$39,$25,$37,$8D,$2B,$51,$33,$43,$27; $7896  し゛ゃましないて゛くれたまえ = じゃましないでくれたまえ
    db $99                         ; $78A4  ！
    db $F7                         ; $78A5  clear page
    db $F0                         ; $78A6  end of message

Bank67_Pad:                                ; $78A7
    ds $0759, $FF                   ; $FF padding to $8000
