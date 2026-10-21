; ==========================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 69  (DIALOGUE / MESSAGE TEXT — flat sentence bank)
; ==========================================================================
;
; Kana dialogue/message strings (previously mislabeled sound). Same flat
; structure as bank66: fn0/1/2 -> $401C directory -> pointer table -> msgs.
; Codec + control codes: memory text-codec.  All messages decoded below,
; ASCENDING ADDRESS order, byte-exact (whole 16 KB reassembles to ROM).
;   e.g. msg #0: 「けんきゅうの　ためとはいえ、
;
;   File offset $114000-$117FFF  |  self-ID $4000 = $45
;   $401C word -> $401E   table $401E: 188 string pointers -> msgs ($4196..)
;   $7E12-$8000 : $FF padding
; Function table $4001: fn0 $4007 / fn1 $400E / fn2 $4015
; ==========================================================================

SECTION "Bank 69", ROMX[$4000], BANK[69]

    db $45                          ; $4000  self-ID
    dw $4007,$400E,$4015          ; $4001  fn table
    db $11,$1C,$40,$CD,$68,$05,$C9 ; $4007  Fn0: LD DE,$401C/CALL $0568/RET
    db $11,$1C,$40,$CD,$A7,$05,$C9 ; $400E  Fn1: LD DE,$401C/CALL $05A7/RET
    db $CD,$07,$40,$CD,$BA,$05,$C9 ; $4015  Fn2: CALL $4007/CALL $05BA/RET

Bank69_MsgDir:                             ; $401C
    dw $401E                         ; header word -> table
Bank69_MsgTable:                           ; $401E  (188 string pointers)
    dw $4196,$41E0,$42B4,$432D,$4383,$43A8,$43CA,$445A
    dw $44AA,$451F,$457A,$461F,$466E,$46EC,$46FF,$4744
    dw $4766,$477C,$47C3,$47CD,$4832,$4869,$48A4,$48C5
    dw $4944,$496E,$49EA,$4A0E,$4A36,$4A5C,$4AF0,$4B5A
    dw $4B74,$4B8F,$4BC1,$4BDB,$4BFF,$4C37,$4C75,$4CBE
    dw $4CDD,$4D01,$4D8F,$4DD8,$4E24,$4E8C,$4ED4,$505C
    dw $50EF,$5119,$51A2,$51FF,$5252,$5276,$52B2,$5322
    dw $5346,$53C5,$540A,$547A,$54E6,$5502,$5581,$55A6
    dw $55FB,$5691,$5727,$577A,$57CB,$581A,$586C,$5895
    dw $593C,$59FA,$5A20,$5A6D,$5AE8,$5B0A,$5B18,$5B22
    dw $5B68,$5B7B,$5B8F,$5B9E,$5BAE,$5C13,$5CB6,$5D04
    dw $5D52,$5D9C,$5DFF,$5E6D,$5EDB,$5EF1,$5F33,$5F5E
    dw $5F84,$5FD6,$6003,$6021,$609B,$6137,$618D,$6277
    dw $62CB,$631C,$6482,$64D3,$6548,$656A,$65B8,$65DA
    dw $6625,$664F,$66AA,$6713,$67D0,$6820,$6868,$68BD
    dw $6912,$695F,$69D3,$69FF,$6A21,$6A4D,$6A6F,$6A97
    dw $6AC4,$6B10,$6B2F,$6B55,$6B7D,$6BD2,$6BFD,$6D72
    dw $6D9C,$6DEB,$6E11,$6E3A,$6E66,$6EBD,$6EFC,$6F6E
    dw $6F90,$6FDD,$7020,$703D,$705D,$708B,$70B0,$7117
    dw $713E,$715D,$7187,$71A8,$71F8,$72D2,$7340,$747B
    dw $74B4,$7516,$7538,$7554,$7581,$75DA,$7634,$7659
    dw $76D5,$76E5,$770B,$77AB,$7899,$78C9,$78F2,$7918
    dw $79C7,$7A26,$7ACB,$7B58,$7B80,$7C29,$7C38,$7C5D
    dw $7CE7,$7D58,$7DB0,$7DE8

; ══════════════════════════════════════════════════════════════════════════
; DECODED MESSAGES (188 unique strings, 188 indices) — ADDRESS-ORDERED
; ══════════════════════════════════════════════════════════════════════════

; --------------------------------------------------------------------------
; Message #0 ($4196)
;   「けんきゅうの　ためとはいえ、
;   わしを　おれいに　あげるとは、！
;   「お[95]、　せんせい！
;   ひどいですじゃ[91]ああ！！
; --------------------------------------------------------------------------
Bank69_Msg0:                               ; $4196  (file $114196)
    db $EB                         ; $4196  ▶ new page
    db $9F                         ; $4197  box tag
    db $96                         ; $4198  end name/box tag
    db $2C,$55,$2A,$4B,$26,$3D     ; $4199  けんきゅうの
    db $90                         ; $419F  　(space)
    db $33,$46,$38,$3E,$25,$27     ; $41A0  ためとはいえ
    db $A4                         ; $41A6  、
    db $EF,$EE                     ; $41A7  newline
    db $90,$90                     ; $41A9  　　(indent)
    db $53,$2F,$54                 ; $41AB  わしを
    db $90                         ; $41AE  　(space)
    db $28,$51,$25,$3A             ; $41AF  おれいに
    db $90                         ; $41B3  　(space)
    db $24,$2C,$8D,$50,$38,$3E     ; $41B4  あけ゛るとは = あげるとは
    db $A4                         ; $41BA  、
    db $99                         ; $41BB  ！
    db $FA                         ; $41BC  wait-for-button
    db $F7                         ; $41BD  clear page
    db $EF,$EE                     ; $41BE  newline
    db $9F                         ; $41C0  box tag
    db $96                         ; $41C1  end name/box tag
    db $28                         ; $41C2  お
    db $95                         ; $41C3  ctrl $95
    db $A4                         ; $41C4  、
    db $90                         ; $41C5  　(space)
    db $31,$55,$31,$25             ; $41C6  せんせい
    db $99                         ; $41CA  ！
    db $EF,$EE                     ; $41CB  newline
    db $90,$90                     ; $41CD  　　(indent)
    db $3F,$38,$8D,$25,$37,$8D,$30,$2F,$8D,$49; $41CF  ひと゛いて゛すし゛ゃ = ひどいですじゃ
    db $91                         ; $41D9  ctrl $91
    db $24,$24                     ; $41DA  ああ
    db $99                         ; $41DC  ！
    db $99                         ; $41DD  ！
    db $F7                         ; $41DE  clear page
    db $F0                         ; $41DF  end of message


; --------------------------------------------------------------------------
; Message #1 ($41E0)
;   「ザォラルが　ザォリクになるように
;   とくぎは　せいちょうするのじゃ！
;   「しかし　せいちょうするには
;   じょうけんが　あるぞ。
;   「レベルや[16][19]　かしこさなどが
;   きまったかずを　こさねばならん。
;   「たとえば　ザォラルを　もっていて
;   レベルが[02]？　[16][19]が[01]？？、
;   「かしこさが　[01]？？を　こえると
;   ザォリクに　なるのだ！
; --------------------------------------------------------------------------
Bank69_Msg1:                               ; $41E0  (file $1141E0)
    db $EA                         ; $41E0  ▶ new page
    db $9F                         ; $41E1  box tag
    db $96                         ; $41E2  end name/box tag
    db $65,$8D,$5E,$85,$87,$29,$8D ; $41E3  サ゛ォラルか゛ = ザォラルが
    db $90                         ; $41EA  　(space)
    db $65,$8D,$5E,$86,$62,$3A,$39,$50,$4C,$26,$3A; $41EB  サ゛ォリクになるように = ザォリクになるように
    db $EF,$EE                     ; $41F6  newline
    db $90,$90                     ; $41F8  　　(indent)
    db $38,$2B,$2A,$8D,$3E         ; $41FA  とくき゛は = とくぎは
    db $90                         ; $41FF  　(space)
    db $31,$25,$34,$4D,$26,$30,$50,$3D,$2F,$8D,$49; $4200  せいちょうするのし゛ゃ = せいちょうするのじゃ
    db $99                         ; $420B  ！
    db $FA                         ; $420C  wait-for-button
    db $F7                         ; $420D  clear page
    db $EF,$EE                     ; $420E  newline
    db $9F                         ; $4210  box tag
    db $96                         ; $4211  end name/box tag
    db $2F,$29,$2F                 ; $4212  しかし
    db $90                         ; $4215  　(space)
    db $31,$25,$34,$4D,$26,$30,$50,$3A,$3E; $4216  せいちょうするには
    db $EF,$EE                     ; $421F  newline
    db $90,$90                     ; $4221  　　(indent)
    db $2F,$8D,$4D,$26,$2C,$55,$29,$8D; $4223  し゛ょうけんか゛ = じょうけんが
    db $90                         ; $422B  　(space)
    db $24,$50,$32,$8D             ; $422C  あるそ゛ = あるぞ
    db $8F                         ; $4230  。
    db $FA                         ; $4231  wait-for-button
    db $F7                         ; $4232  clear page
    db $EF,$EE                     ; $4233  newline
    db $9F                         ; $4235  box tag
    db $96                         ; $4236  end name/box tag
    db $88,$78,$8D,$87,$48         ; $4237  レヘ゛ルや = レベルや
    db $16                         ; $423C  ctrl $16
    db $19                         ; $423D  ctrl $19
    db $90                         ; $423E  　(space)
    db $29,$2F,$2D,$2E,$39,$38,$8D,$29,$8D; $423F  かしこさなと゛か゛ = かしこさなどが
    db $EF,$EE                     ; $4248  newline
    db $90,$90                     ; $424A  　　(indent)
    db $2A,$43,$36,$33,$29,$30,$8D,$54; $424C  きまったかす゛を = きまったかずを
    db $90                         ; $4254  　(space)
    db $2D,$2E,$3C,$3E,$8D,$39,$4E,$55; $4255  こさねは゛ならん = こさねばならん
    db $8F                         ; $425D  。
    db $FA                         ; $425E  wait-for-button
    db $F7                         ; $425F  clear page
    db $EF,$EE                     ; $4260  newline
    db $9F                         ; $4262  box tag
    db $96                         ; $4263  end name/box tag
    db $33,$38,$27,$3E,$8D         ; $4264  たとえは゛ = たとえば
    db $90                         ; $4269  　(space)
    db $65,$8D,$5E,$85,$87,$54     ; $426A  サ゛ォラルを = ザォラルを
    db $90                         ; $4270  　(space)
    db $47,$36,$37,$25,$37         ; $4271  もっていて
    db $EF,$EE                     ; $4276  newline
    db $90,$90                     ; $4278  　　(indent)
    db $88,$78,$8D,$87,$29,$8D     ; $427A  レヘ゛ルか゛ = レベルが
    db $02                         ; $4280  ctrl $02
    db $98                         ; $4281  ？
    db $90                         ; $4282  　(space)
    db $16                         ; $4283  ctrl $16
    db $19                         ; $4284  ctrl $19
    db $29,$8D                     ; $4285  か゛ = が
    db $01                         ; $4287  ctrl $01
    db $98                         ; $4288  ？
    db $98                         ; $4289  ？
    db $A4                         ; $428A  、
    db $FA                         ; $428B  wait-for-button
    db $F7                         ; $428C  clear page
    db $EF,$EE                     ; $428D  newline
    db $9F                         ; $428F  box tag
    db $96                         ; $4290  end name/box tag
    db $29,$2F,$2D,$2E,$29,$8D     ; $4291  かしこさか゛ = かしこさが
    db $90                         ; $4297  　(space)
    db $01                         ; $4298  ctrl $01
    db $98                         ; $4299  ？
    db $98                         ; $429A  ？
    db $54                         ; $429B  を
    db $90                         ; $429C  　(space)
    db $2D,$27,$50,$38             ; $429D  こえると
    db $EF,$EE                     ; $42A1  newline
    db $90,$90                     ; $42A3  　　(indent)
    db $65,$8D,$5E,$86,$62,$3A     ; $42A5  サ゛ォリクに = ザォリクに
    db $90                         ; $42AB  　(space)
    db $39,$50,$3D,$33,$8D         ; $42AC  なるのた゛ = なるのだ
    db $99                         ; $42B1  ！
    db $F7                         ; $42B2  clear page
    db $F0                         ; $42B3  end of message


; --------------------------------------------------------------------------
; Message #2 ($42B4)
;   「せいかくによって　まものたちの
;   たたかいかたは　ちがうんだ。
;   「せいかくによっては　あわない
;   さくせんを　むしすることも、。
;   「まもののせいかくを　かえたいとき
;   どうすればいいか　しりたい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg2:                               ; $42B4  (file $1142B4)
    db $EB                         ; $42B4  ▶ new page
    db $9F                         ; $42B5  box tag
    db $96                         ; $42B6  end name/box tag
    db $31,$25,$29,$2B,$3A,$4C,$36,$37; $42B7  せいかくによって
    db $90                         ; $42BF  　(space)
    db $43,$47,$3D,$33,$34,$3D     ; $42C0  まものたちの
    db $EF,$EE                     ; $42C6  newline
    db $90,$90                     ; $42C8  　　(indent)
    db $33,$33,$29,$25,$29,$33,$3E ; $42CA  たたかいかたは
    db $90                         ; $42D1  　(space)
    db $34,$29,$8D,$26,$55,$33,$8D ; $42D2  ちか゛うんた゛ = ちがうんだ
    db $8F                         ; $42D9  。
    db $FA                         ; $42DA  wait-for-button
    db $F7                         ; $42DB  clear page
    db $EF,$EE                     ; $42DC  newline
    db $9F                         ; $42DE  box tag
    db $96                         ; $42DF  end name/box tag
    db $31,$25,$29,$2B,$3A,$4C,$36,$37,$3E; $42E0  せいかくによっては
    db $90                         ; $42E9  　(space)
    db $24,$53,$39,$25             ; $42EA  あわない
    db $EF,$EE                     ; $42EE  newline
    db $90,$90                     ; $42F0  　　(indent)
    db $2E,$2B,$31,$55,$54         ; $42F2  さくせんを
    db $90                         ; $42F7  　(space)
    db $45,$2F,$30,$50,$2D,$38,$47 ; $42F8  むしすることも
    db $A4                         ; $42FF  、
    db $8F                         ; $4300  。
    db $FA                         ; $4301  wait-for-button
    db $F7                         ; $4302  clear page
    db $EF,$EE                     ; $4303  newline
    db $9F                         ; $4305  box tag
    db $96                         ; $4306  end name/box tag
    db $43,$47,$3D,$3D,$31,$25,$29,$2B,$54; $4307  まもののせいかくを
    db $90                         ; $4310  　(space)
    db $29,$27,$33,$25,$38,$2A     ; $4311  かえたいとき
    db $EF,$EE                     ; $4317  newline
    db $90,$90                     ; $4319  　　(indent)
    db $38,$8D,$26,$30,$51,$3E,$8D,$25,$25,$29; $431B  と゛うすれは゛いいか = どうすればいいか
    db $90                         ; $4325  　(space)
    db $2F,$4F,$33,$25             ; $4326  しりたい
    db $98                         ; $432A  ？
    db $FF                         ; $432B  はい/いいえ
    db $F0                         ; $432C  end of message


; --------------------------------------------------------------------------
; Message #3 ($432D)
;   「いうことを　きくまで　なんどでも
;   そのさくせんを　えらぶんだ。
;   「そのうち　まものも　せいかくが
;   かわって　いうことをきくんだ。
; --------------------------------------------------------------------------
Bank69_Msg3:                               ; $432D  (file $11432D)
    db $EB                         ; $432D  ▶ new page
    db $9F                         ; $432E  box tag
    db $96                         ; $432F  end name/box tag
    db $25,$26,$2D,$38,$54         ; $4330  いうことを
    db $90                         ; $4335  　(space)
    db $2A,$2B,$43,$37,$8D         ; $4336  きくまて゛ = きくまで
    db $90                         ; $433B  　(space)
    db $39,$55,$38,$8D,$37,$8D,$47 ; $433C  なんと゛て゛も = なんどでも
    db $EF,$EE                     ; $4343  newline
    db $90,$90                     ; $4345  　　(indent)
    db $32,$3D,$2E,$2B,$31,$55,$54 ; $4347  そのさくせんを
    db $90                         ; $434E  　(space)
    db $27,$4E,$40,$8D,$55,$33,$8D ; $434F  えらふ゛んた゛ = えらぶんだ
    db $8F                         ; $4356  。
    db $FA                         ; $4357  wait-for-button
    db $F7                         ; $4358  clear page
    db $EF,$EE                     ; $4359  newline
    db $9F                         ; $435B  box tag
    db $96                         ; $435C  end name/box tag
    db $32,$3D,$26,$34             ; $435D  そのうち
    db $90                         ; $4361  　(space)
    db $43,$47,$3D,$47             ; $4362  まものも
    db $90                         ; $4366  　(space)
    db $31,$25,$29,$2B,$29,$8D     ; $4367  せいかくか゛ = せいかくが
    db $EF,$EE                     ; $436D  newline
    db $90,$90                     ; $436F  　　(indent)
    db $29,$53,$36,$37             ; $4371  かわって
    db $90                         ; $4375  　(space)
    db $25,$26,$2D,$38,$54,$2A,$2B,$55,$33,$8D; $4376  いうことをきくんた゛ = いうことをきくんだ
    db $8F                         ; $4380  。
    db $F7                         ; $4381  clear page
    db $F0                         ; $4382  end of message


; --------------------------------------------------------------------------
; Message #4 ($4383)
;   「いいせいかくだと　とくなことが
;   あるんだけどな[91]！
; --------------------------------------------------------------------------
Bank69_Msg4:                               ; $4383  (file $114383)
    db $EB                         ; $4383  ▶ new page
    db $9F                         ; $4384  box tag
    db $96                         ; $4385  end name/box tag
    db $25,$25,$31,$25,$29,$2B,$33,$8D,$38; $4386  いいせいかくた゛と = いいせいかくだと
    db $90                         ; $438F  　(space)
    db $38,$2B,$39,$2D,$38,$29,$8D ; $4390  とくなことか゛ = とくなことが
    db $EF,$EE                     ; $4397  newline
    db $90,$90                     ; $4399  　　(indent)
    db $24,$50,$55,$33,$8D,$2C,$38,$8D,$39; $439B  あるんた゛けと゛な = あるんだけどな
    db $91                         ; $43A4  ctrl $91
    db $99                         ; $43A5  ！
    db $F7                         ; $43A6  clear page
    db $F0                         ; $43A7  end of message


; --------------------------------------------------------------------------
; Message #5 ($43A8)
;   「ハッ！　、、おれたちを
;   おこすのは　だれだ[91]？？
; --------------------------------------------------------------------------
Bank69_Msg5:                               ; $43A8  (file $1143A8)
    db $EA                         ; $43A8  ▶ new page
    db $9F                         ; $43A9  box tag
    db $96                         ; $43AA  end name/box tag
    db $75,$6D                     ; $43AB  ハッ
    db $99                         ; $43AD  ！
    db $90                         ; $43AE  　(space)
    db $A4                         ; $43AF  、
    db $A4                         ; $43B0  、
    db $28,$51,$33,$34,$54         ; $43B1  おれたちを
    db $EF,$EE                     ; $43B6  newline
    db $90,$90                     ; $43B8  　　(indent)
    db $28,$2D,$30,$3D,$3E         ; $43BA  おこすのは
    db $90                         ; $43BF  　(space)
    db $33,$8D,$51,$33,$8D         ; $43C0  た゛れた゛ = だれだ
    db $91                         ; $43C5  ctrl $91
    db $98                         ; $43C6  ？
    db $98                         ; $43C7  ？
    db $F7                         ; $43C8  clear page
    db $F0                         ; $43C9  end of message


; --------------------------------------------------------------------------
; Message #6 ($43CA)
;   「〈テリー〉さんが　ゆうしょう
;   してからというもの、
;   「おきゃくさんが　くるわ　くるわ！
;   もう　だいはんじょうなんですよ。
;   「これも　ひとえに　〈テリー〉さんが
;   ゆうしょうしてくれたからですよ！
;   「さあ　きょうは　なにを
;   なさいますか？
; --------------------------------------------------------------------------
Bank69_Msg6:                               ; $43CA  (file $1143CA)
    db $EA                         ; $43CA  ▶ new page
    db $9F                         ; $43CB  box tag
    db $96                         ; $43CC  end name/box tag
    db $F6                         ; $43CD  «insert hero name»
    db $2E,$55,$29,$8D             ; $43CE  さんか゛ = さんが
    db $90                         ; $43D2  　(space)
    db $4A,$26,$2F,$4D,$26         ; $43D3  ゆうしょう
    db $EF,$EE                     ; $43D8  newline
    db $90,$90                     ; $43DA  　　(indent)
    db $2F,$37,$29,$4E,$38,$25,$26,$47,$3D; $43DC  してからというもの
    db $A4                         ; $43E5  、
    db $FA                         ; $43E6  wait-for-button
    db $F7                         ; $43E7  clear page
    db $EF,$EE                     ; $43E8  newline
    db $9F                         ; $43EA  box tag
    db $96                         ; $43EB  end name/box tag
    db $28,$2A,$49,$2B,$2E,$55,$29,$8D; $43EC  おきゃくさんか゛ = おきゃくさんが
    db $90                         ; $43F4  　(space)
    db $2B,$50,$53                 ; $43F5  くるわ
    db $90                         ; $43F8  　(space)
    db $2B,$50,$53                 ; $43F9  くるわ
    db $99                         ; $43FC  ！
    db $EF,$EE                     ; $43FD  newline
    db $90,$90                     ; $43FF  　　(indent)
    db $47,$26                     ; $4401  もう
    db $90                         ; $4403  　(space)
    db $33,$8D,$25,$3E,$55,$2F,$8D,$4D,$26,$39,$55,$37,$8D,$30,$4C; $4404  た゛いはんし゛ょうなんて゛すよ = だいはんじょうなんですよ
    db $8F                         ; $4413  。
    db $FA                         ; $4414  wait-for-button
    db $F7                         ; $4415  clear page
    db $EF,$EE                     ; $4416  newline
    db $9F                         ; $4418  box tag
    db $96                         ; $4419  end name/box tag
    db $2D,$51,$47                 ; $441A  これも
    db $90                         ; $441D  　(space)
    db $3F,$38,$27,$3A             ; $441E  ひとえに
    db $90                         ; $4422  　(space)
    db $F6                         ; $4423  «insert hero name»
    db $2E,$55,$29,$8D             ; $4424  さんか゛ = さんが
    db $EF,$EE                     ; $4428  newline
    db $90,$90                     ; $442A  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$37,$2B,$51,$33,$29,$4E,$37,$8D,$30,$4C; $442C  ゆうしょうしてくれたからて゛すよ = ゆうしょうしてくれたからですよ
    db $99                         ; $443C  ！
    db $FA                         ; $443D  wait-for-button
    db $F7                         ; $443E  clear page
    db $EF,$EE                     ; $443F  newline
    db $9F                         ; $4441  box tag
    db $96                         ; $4442  end name/box tag
    db $2E,$24                     ; $4443  さあ
    db $90                         ; $4445  　(space)
    db $2A,$4D,$26,$3E             ; $4446  きょうは
    db $90                         ; $444A  　(space)
    db $39,$3A,$54                 ; $444B  なにを
    db $EF,$EE                     ; $444E  newline
    db $90,$90                     ; $4450  　　(indent)
    db $39,$2E,$25,$43,$30,$29     ; $4452  なさいますか
    db $98                         ; $4458  ？
    db $F0                         ; $4459  end of message


; --------------------------------------------------------------------------
; Message #7 ($445A)
;   〈テリー〉は　ろうそくを　しらべた。
;   ろうそくは　なんと
;   おばけキユンドルだった！
;   しかし　おばけキユンドルは
;   ねむっている、、。
; --------------------------------------------------------------------------
Bank69_Msg7:                               ; $445A  (file $11445A)
    db $F6                         ; $445A  «insert hero name»
    db $3E                         ; $445B  は
    db $90                         ; $445C  　(space)
    db $52,$26,$32,$2B,$54         ; $445D  ろうそくを
    db $90                         ; $4462  　(space)
    db $2F,$4E,$41,$8D,$33         ; $4463  しらへ゛た = しらべた
    db $8F                         ; $4468  。
    db $EF,$EE                     ; $4469  newline
    db $FA                         ; $446B  wait-for-button
    db $F7                         ; $446C  clear page
    db $EF,$EE                     ; $446D  newline
    db $F3                         ; $446F  open text box
    db $52,$26,$32,$2B,$3E         ; $4470  ろうそくは
    db $90                         ; $4475  　(space)
    db $39,$55,$38                 ; $4476  なんと
    db $EF,$EE                     ; $4479  newline
    db $28,$3E,$8D,$2C,$61,$80,$8C,$6F,$8D,$87,$33,$8D,$36,$33; $447B  おは゛けキユント゛ルた゛った = おばけキユンドルだった
    db $99                         ; $4489  ！
    db $FA                         ; $448A  wait-for-button
    db $F7                         ; $448B  clear page
    db $EF,$EE                     ; $448C  newline
    db $2F,$29,$2F                 ; $448E  しかし
    db $90                         ; $4491  　(space)
    db $28,$3E,$8D,$2C,$61,$80,$8C,$6F,$8D,$87,$3E; $4492  おは゛けキユント゛ルは = おばけキユンドルは
    db $EF,$EE                     ; $449D  newline
    db $3C,$45,$36,$37,$25,$50     ; $449F  ねむっている
    db $A4                         ; $44A5  、
    db $A4                         ; $44A6  、
    db $8F                         ; $44A7  。
    db $F7                         ; $44A8  clear page
    db $F0                         ; $44A9  end of message


; --------------------------------------------------------------------------
; Message #8 ($44AA)
;   「、あそこには　しょくぶつけいの
;   まものばかり　いるらしいな。
;   「じゃきょうの　しんかんが
;   あのとびらの　ぬしらしいぞ。
;   「あやつりのとびらのことも
;   きいているが　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg8:                               ; $44AA  (file $1144AA)
    db $EA                         ; $44AA  ▶ new page
    db $9F                         ; $44AB  box tag
    db $96                         ; $44AC  end name/box tag
    db $A4                         ; $44AD  、
    db $24,$32,$2D,$3A,$3E         ; $44AE  あそこには
    db $90                         ; $44B3  　(space)
    db $2F,$4D,$2B,$40,$8D,$35,$2C,$25,$3D; $44B4  しょくふ゛つけいの = しょくぶつけいの
    db $EF,$EE                     ; $44BD  newline
    db $90,$90                     ; $44BF  　　(indent)
    db $43,$47,$3D,$3E,$8D,$29,$4F ; $44C1  まものは゛かり = まものばかり
    db $90                         ; $44C8  　(space)
    db $25,$50,$4E,$2F,$25,$39     ; $44C9  いるらしいな
    db $8F                         ; $44CF  。
    db $FA                         ; $44D0  wait-for-button
    db $F7                         ; $44D1  clear page
    db $EF,$EE                     ; $44D2  newline
    db $9F                         ; $44D4  box tag
    db $96                         ; $44D5  end name/box tag
    db $2F,$8D,$49,$2A,$4D,$26,$3D ; $44D6  し゛ゃきょうの = じゃきょうの
    db $90                         ; $44DD  　(space)
    db $2F,$55,$29,$55,$29,$8D     ; $44DE  しんかんか゛ = しんかんが
    db $EF,$EE                     ; $44E4  newline
    db $90,$90                     ; $44E6  　　(indent)
    db $24,$3D,$38,$3F,$8D,$4E,$3D ; $44E8  あのとひ゛らの = あのとびらの
    db $90                         ; $44EF  　(space)
    db $3B,$2F,$4E,$2F,$25,$32,$8D ; $44F0  ぬしらしいそ゛ = ぬしらしいぞ
    db $8F                         ; $44F7  。
    db $FA                         ; $44F8  wait-for-button
    db $F7                         ; $44F9  clear page
    db $EF,$EE                     ; $44FA  newline
    db $9F                         ; $44FC  box tag
    db $96                         ; $44FD  end name/box tag
    db $24,$48,$35,$4F,$3D,$38,$3F,$8D,$4E,$3D,$2D,$38,$47; $44FE  あやつりのとひ゛らのことも = あやつりのとびらのことも
    db $EF,$EE                     ; $450B  newline
    db $90,$90                     ; $450D  　　(indent)
    db $2A,$25,$37,$25,$50,$29,$8D ; $450F  きいているか゛ = きいているが
    db $90                         ; $4516  　(space)
    db $2F,$4F,$33,$25,$29         ; $4517  しりたいか
    db $98                         ; $451C  ？
    db $FF                         ; $451D  はい/いいえ
    db $F0                         ; $451E  end of message


; --------------------------------------------------------------------------
; Message #9 ($451F)
;   「おかねが　あるなら
;   しもふりにく！
;   「もし　しもふりを
;   [04]かい　あたえられたなら、
;   「ほとんどの　まものは
;   なかまに　なるだろうな。
; --------------------------------------------------------------------------
Bank69_Msg9:                               ; $451F  (file $11451F)
    db $EA                         ; $451F  ▶ new page
    db $9F                         ; $4520  box tag
    db $96                         ; $4521  end name/box tag
    db $28,$29,$3C,$29,$8D         ; $4522  おかねか゛ = おかねが
    db $90                         ; $4527  　(space)
    db $24,$50,$39,$4E             ; $4528  あるなら
    db $EF,$EE                     ; $452C  newline
    db $90,$90                     ; $452E  　　(indent)
    db $2F,$47,$40,$4F,$3A,$2B     ; $4530  しもふりにく
    db $99                         ; $4536  ！
    db $FA                         ; $4537  wait-for-button
    db $F7                         ; $4538  clear page
    db $EF,$EE                     ; $4539  newline
    db $9F                         ; $453B  box tag
    db $96                         ; $453C  end name/box tag
    db $47,$2F                     ; $453D  もし
    db $90                         ; $453F  　(space)
    db $2F,$47,$40,$4F,$54         ; $4540  しもふりを
    db $EF,$EE                     ; $4545  newline
    db $90,$90                     ; $4547  　　(indent)
    db $04                         ; $4549  ctrl $04
    db $29,$25                     ; $454A  かい
    db $90                         ; $454C  　(space)
    db $24,$33,$27,$4E,$51,$33,$39,$4E; $454D  あたえられたなら
    db $A4                         ; $4555  、
    db $FA                         ; $4556  wait-for-button
    db $F7                         ; $4557  clear page
    db $EF,$EE                     ; $4558  newline
    db $9F                         ; $455A  box tag
    db $96                         ; $455B  end name/box tag
    db $42,$38,$55,$38,$8D,$3D     ; $455C  ほとんと゛の = ほとんどの
    db $90                         ; $4562  　(space)
    db $43,$47,$3D,$3E             ; $4563  まものは
    db $EF,$EE                     ; $4567  newline
    db $90,$90                     ; $4569  　　(indent)
    db $39,$29,$43,$3A             ; $456B  なかまに
    db $90                         ; $456F  　(space)
    db $39,$50,$33,$8D,$52,$26,$39 ; $4570  なるた゛ろうな = なるだろうな
    db $8F                         ; $4577  。
    db $F7                         ; $4578  clear page
    db $F0                         ; $4579  end of message


; --------------------------------------------------------------------------
; Message #10 ($457A)
;   「おみあいは　もうしこまれたら
;   はやめに　したほうがいいですよ。
;   「ひとのきもちは　かわりやすい
;   ものですからね[94]。
;   「なかなか　であえない　まものと
;   おみあいできる　チユンスですし。
;   「うわさでは　おみあいで　つくった
;   まもののほうが　つよいそうです。
; --------------------------------------------------------------------------
Bank69_Msg10:                              ; $457A  (file $11457A)
    db $EA                         ; $457A  ▶ new page
    db $9F                         ; $457B  box tag
    db $96                         ; $457C  end name/box tag
    db $28,$44,$24,$25,$3E         ; $457D  おみあいは
    db $90                         ; $4582  　(space)
    db $47,$26,$2F,$2D,$43,$51,$33,$4E; $4583  もうしこまれたら
    db $EF,$EE                     ; $458B  newline
    db $90,$90                     ; $458D  　　(indent)
    db $3E,$48,$46,$3A             ; $458F  はやめに
    db $90                         ; $4593  　(space)
    db $2F,$33,$42,$26,$29,$8D,$25,$25,$37,$8D,$30,$4C; $4594  したほうか゛いいて゛すよ = したほうがいいですよ
    db $8F                         ; $45A0  。
    db $FA                         ; $45A1  wait-for-button
    db $F7                         ; $45A2  clear page
    db $EF,$EE                     ; $45A3  newline
    db $9F                         ; $45A5  box tag
    db $96                         ; $45A6  end name/box tag
    db $3F,$38,$3D,$2A,$47,$34,$3E ; $45A7  ひとのきもちは
    db $90                         ; $45AE  　(space)
    db $29,$53,$4F,$48,$30,$25     ; $45AF  かわりやすい
    db $EF,$EE                     ; $45B5  newline
    db $90,$90                     ; $45B7  　　(indent)
    db $47,$3D,$37,$8D,$30,$29,$4E,$3C; $45B9  ものて゛すからね = ものですからね
    db $94                         ; $45C1  ctrl $94
    db $8F                         ; $45C2  。
    db $FA                         ; $45C3  wait-for-button
    db $F7                         ; $45C4  clear page
    db $EF,$EE                     ; $45C5  newline
    db $9F                         ; $45C7  box tag
    db $96                         ; $45C8  end name/box tag
    db $39,$29,$39,$29             ; $45C9  なかなか
    db $90                         ; $45CD  　(space)
    db $37,$8D,$24,$27,$39,$25     ; $45CE  て゛あえない = であえない
    db $90                         ; $45D4  　(space)
    db $43,$47,$3D,$38             ; $45D5  まものと
    db $EF,$EE                     ; $45D9  newline
    db $90,$90                     ; $45DB  　　(indent)
    db $28,$44,$24,$25,$37,$8D,$2A,$50; $45DD  おみあいて゛きる = おみあいできる
    db $90                         ; $45E5  　(space)
    db $6B,$80,$8C,$67,$37,$8D,$30,$2F; $45E6  チユンスて゛すし = チユンスですし
    db $8F                         ; $45EE  。
    db $FA                         ; $45EF  wait-for-button
    db $F7                         ; $45F0  clear page
    db $EF,$EE                     ; $45F1  newline
    db $9F                         ; $45F3  box tag
    db $96                         ; $45F4  end name/box tag
    db $26,$53,$2E,$37,$8D,$3E     ; $45F5  うわさて゛は = うわさでは
    db $90                         ; $45FB  　(space)
    db $28,$44,$24,$25,$37,$8D     ; $45FC  おみあいて゛ = おみあいで
    db $90                         ; $4602  　(space)
    db $35,$2B,$36,$33             ; $4603  つくった
    db $EF,$EE                     ; $4607  newline
    db $90,$90                     ; $4609  　　(indent)
    db $43,$47,$3D,$3D,$42,$26,$29,$8D; $460B  まもののほうか゛ = まもののほうが
    db $90                         ; $4613  　(space)
    db $35,$4C,$25,$32,$26,$37,$8D,$30; $4614  つよいそうて゛す = つよいそうです
    db $8F                         ; $461C  。
    db $F7                         ; $461D  clear page
    db $F0                         ; $461E  end of message


; --------------------------------------------------------------------------
; Message #11 ($461F)
;   「ヒック。　なあ　きょうだい。
;   おれと　おみあいしないか？
;   「いや　ちがった。　おれのもってる
;   キユットフラィと　みあいせんか？
; --------------------------------------------------------------------------
Bank69_Msg11:                              ; $461F  (file $11461F)
    db $EA                         ; $461F  ▶ new page
    db $9F                         ; $4620  box tag
    db $96                         ; $4621  end name/box tag
    db $76,$6D,$62                 ; $4622  ヒック
    db $8F                         ; $4625  。
    db $90                         ; $4626  　(space)
    db $39,$24                     ; $4627  なあ
    db $90                         ; $4629  　(space)
    db $2A,$4D,$26,$33,$8D,$25     ; $462A  きょうた゛い = きょうだい
    db $8F                         ; $4630  。
    db $EF,$EE                     ; $4631  newline
    db $90,$90                     ; $4633  　　(indent)
    db $28,$51,$38                 ; $4635  おれと
    db $90                         ; $4638  　(space)
    db $28,$44,$24,$25,$2F,$39,$25,$29; $4639  おみあいしないか
    db $98                         ; $4641  ？
    db $FA                         ; $4642  wait-for-button
    db $F7                         ; $4643  clear page
    db $EF,$EE                     ; $4644  newline
    db $9F                         ; $4646  box tag
    db $96                         ; $4647  end name/box tag
    db $25,$48                     ; $4648  いや
    db $90                         ; $464A  　(space)
    db $34,$29,$8D,$36,$33         ; $464B  ちか゛った = ちがった
    db $8F                         ; $4650  。
    db $90                         ; $4651  　(space)
    db $28,$51,$3D,$47,$36,$37,$50 ; $4652  おれのもってる
    db $EF,$EE                     ; $4659  newline
    db $90,$90                     ; $465B  　　(indent)
    db $61,$80,$6D,$6F,$77,$85,$58,$38; $465D  キユットフラィと
    db $90                         ; $4665  　(space)
    db $44,$24,$25,$31,$55,$29     ; $4666  みあいせんか
    db $98                         ; $466C  ？
    db $F0                         ; $466D  end of message


; --------------------------------------------------------------------------
; Message #12 ($466E)
;   「わたしには　わかるのです。
;   「やがて　ひとりの　わかものが
;   やってくるでしょう。
;   「しかし　それは
;   あなたでは　ありません。
;   「わたしの　なは　ローラ。
;   ありがとうございました。
; --------------------------------------------------------------------------
Bank69_Msg12:                              ; $466E  (file $11466E)
    db $EB                         ; $466E  ▶ new page
    db $9F                         ; $466F  box tag
    db $96                         ; $4670  end name/box tag
    db $53,$33,$2F,$3A,$3E         ; $4671  わたしには
    db $90                         ; $4676  　(space)
    db $53,$29,$50,$3D,$37,$8D,$30 ; $4677  わかるのて゛す = わかるのです
    db $8F                         ; $467E  。
    db $EF,$EE                     ; $467F  newline
    db $FA                         ; $4681  wait-for-button
    db $F7                         ; $4682  clear page
    db $EF,$EE                     ; $4683  newline
    db $F3                         ; $4685  open text box
    db $9F                         ; $4686  box tag
    db $96                         ; $4687  end name/box tag
    db $48,$29,$8D,$37             ; $4688  やか゛て = やがて
    db $90                         ; $468C  　(space)
    db $3F,$38,$4F,$3D             ; $468D  ひとりの
    db $90                         ; $4691  　(space)
    db $53,$29,$47,$3D,$29,$8D     ; $4692  わかものか゛ = わかものが
    db $EF,$EE                     ; $4698  newline
    db $90,$90                     ; $469A  　　(indent)
    db $48,$36,$37,$2B,$50,$37,$8D,$2F,$4D,$26; $469C  やってくるて゛しょう = やってくるでしょう
    db $8F                         ; $46A6  。
    db $FA                         ; $46A7  wait-for-button
    db $F7                         ; $46A8  clear page
    db $EF,$EE                     ; $46A9  newline
    db $9F                         ; $46AB  box tag
    db $96                         ; $46AC  end name/box tag
    db $2F,$29,$2F                 ; $46AD  しかし
    db $90                         ; $46B0  　(space)
    db $32,$51,$3E                 ; $46B1  それは
    db $EF,$EE                     ; $46B4  newline
    db $90,$90                     ; $46B6  　　(indent)
    db $24,$39,$33,$37,$8D,$3E     ; $46B8  あなたて゛は = あなたでは
    db $90                         ; $46BE  　(space)
    db $24,$4F,$43,$31,$55         ; $46BF  ありません
    db $8F                         ; $46C4  。
    db $FA                         ; $46C5  wait-for-button
    db $F7                         ; $46C6  clear page
    db $EF,$EE                     ; $46C7  newline
    db $9F                         ; $46C9  box tag
    db $96                         ; $46CA  end name/box tag
    db $53,$33,$2F,$3D             ; $46CB  わたしの
    db $90                         ; $46CF  　(space)
    db $39,$3E                     ; $46D0  なは
    db $90                         ; $46D2  　(space)
    db $89,$9C,$85                 ; $46D3  ローラ
    db $8F                         ; $46D6  。
    db $EF,$EE                     ; $46D7  newline
    db $90,$90                     ; $46D9  　　(indent)
    db $24,$4F,$29,$8D,$38,$26,$2D,$8D,$2E,$8D,$25,$43,$2F,$33; $46DB  ありか゛とうこ゛さ゛いました = ありがとうございました
    db $8F                         ; $46E9  。
    db $F7                         ; $46EA  clear page
    db $F0                         ; $46EB  end of message


; --------------------------------------------------------------------------
; Message #13 ($46EC)
;   「グオー　グオー、、。
; --------------------------------------------------------------------------
Bank69_Msg13:                              ; $46EC  (file $1146EC)
    db $EA                         ; $46EC  ▶ new page
    db $9F                         ; $46ED  box tag
    db $96                         ; $46EE  end name/box tag
    db $62,$8D,$5F,$9C             ; $46EF  ク゛オー = グオー
    db $90                         ; $46F3  　(space)
    db $62,$8D,$5F,$9C             ; $46F4  ク゛オー = グオー
    db $A4                         ; $46F8  、
    db $A4                         ; $46F9  、
    db $8F                         ; $46FA  。
    db $EF,$EE                     ; $46FB  newline
    db $F7                         ; $46FD  clear page
    db $F0                         ; $46FE  end of message


; --------------------------------------------------------------------------
; Message #14 ($46FF)
;   「グオー　グオー、、。
;   スー　パチン！
;   「ひ　さ　し　ぶ　り　だ　な
;   きゃ　く　じ　ん　は　！　！
; --------------------------------------------------------------------------
Bank69_Msg14:                              ; $46FF  (file $1146FF)
    db $EA                         ; $46FF  ▶ new page
    db $9F                         ; $4700  box tag
    db $96                         ; $4701  end name/box tag
    db $62,$8D,$5F,$9C             ; $4702  ク゛オー = グオー
    db $90                         ; $4706  　(space)
    db $62,$8D,$5F,$9C             ; $4707  ク゛オー = グオー
    db $A4                         ; $470B  、
    db $A4                         ; $470C  、
    db $8F                         ; $470D  。
    db $EF,$EE                     ; $470E  newline
    db $90,$90                     ; $4710  　　(indent)
    db $67,$9C                     ; $4712  スー
    db $90                         ; $4714  　(space)
    db $75,$8E,$6B,$8C             ; $4715  ハ゜チン = パチン
    db $99                         ; $4719  ！
    db $FA                         ; $471A  wait-for-button
    db $F7                         ; $471B  clear page
    db $EF,$EE                     ; $471C  newline
    db $9F                         ; $471E  box tag
    db $96                         ; $471F  end name/box tag
    db $3F                         ; $4720  ひ
    db $90                         ; $4721  　(space)
    db $2E                         ; $4722  さ
    db $90                         ; $4723  　(space)
    db $2F                         ; $4724  し
    db $90                         ; $4725  　(space)
    db $40,$8D                     ; $4726  ふ゛ = ぶ
    db $90                         ; $4728  　(space)
    db $4F                         ; $4729  り
    db $90                         ; $472A  　(space)
    db $33,$8D                     ; $472B  た゛ = だ
    db $90                         ; $472D  　(space)
    db $39                         ; $472E  な
    db $EF,$EE                     ; $472F  newline
    db $90,$90                     ; $4731  　　(indent)
    db $2A,$49                     ; $4733  きゃ
    db $90                         ; $4735  　(space)
    db $2B                         ; $4736  く
    db $90                         ; $4737  　(space)
    db $2F,$8D                     ; $4738  し゛ = じ
    db $90                         ; $473A  　(space)
    db $55                         ; $473B  ん
    db $90                         ; $473C  　(space)
    db $3E                         ; $473D  は
    db $90                         ; $473E  　(space)
    db $99                         ; $473F  ！
    db $90                         ; $4740  　(space)
    db $99                         ; $4741  ！
    db $F7                         ; $4742  clear page
    db $F0                         ; $4743  end of message


; --------------------------------------------------------------------------
; Message #15 ($4744)
;   「、・・・。　ま　た
;   あ　そ　び　に　き　た　か　！
; --------------------------------------------------------------------------
Bank69_Msg15:                              ; $4744  (file $114744)
    db $EA                         ; $4744  ▶ new page
    db $9F                         ; $4745  box tag
    db $96                         ; $4746  end name/box tag
    db $A4                         ; $4747  、
    db $23                         ; $4748  ・
    db $23                         ; $4749  ・
    db $23                         ; $474A  ・
    db $8F                         ; $474B  。
    db $90                         ; $474C  　(space)
    db $43                         ; $474D  ま
    db $90                         ; $474E  　(space)
    db $33                         ; $474F  た
    db $EF,$EE                     ; $4750  newline
    db $90,$90                     ; $4752  　　(indent)
    db $24                         ; $4754  あ
    db $90                         ; $4755  　(space)
    db $32                         ; $4756  そ
    db $90                         ; $4757  　(space)
    db $3F,$8D                     ; $4758  ひ゛ = び
    db $90                         ; $475A  　(space)
    db $3A                         ; $475B  に
    db $90                         ; $475C  　(space)
    db $2A                         ; $475D  き
    db $90                         ; $475E  　(space)
    db $33                         ; $475F  た
    db $90                         ; $4760  　(space)
    db $29                         ; $4761  か
    db $90                         ; $4762  　(space)
    db $99                         ; $4763  ！
    db $F7                         ; $4764  clear page
    db $F0                         ; $4765  end of message


; --------------------------------------------------------------------------
; Message #16 ($4766)
;   「お　ま　え　つ　よ　い　！　！
; --------------------------------------------------------------------------
Bank69_Msg16:                              ; $4766  (file $114766)
    db $EA                         ; $4766  ▶ new page
    db $9F                         ; $4767  box tag
    db $96                         ; $4768  end name/box tag
    db $28                         ; $4769  お
    db $90                         ; $476A  　(space)
    db $43                         ; $476B  ま
    db $90                         ; $476C  　(space)
    db $27                         ; $476D  え
    db $90                         ; $476E  　(space)
    db $35                         ; $476F  つ
    db $90                         ; $4770  　(space)
    db $4C                         ; $4771  よ
    db $90                         ; $4772  　(space)
    db $25                         ; $4773  い
    db $90                         ; $4774  　(space)
    db $99                         ; $4775  ！
    db $90                         ; $4776  　(space)
    db $99                         ; $4777  ！
    db $EF,$EE                     ; $4778  newline
    db $F7                         ; $477A  clear page
    db $F0                         ; $477B  end of message


; --------------------------------------------------------------------------
; Message #17 ($477C)
;   わたほ゛う「おひめさまを　もちあげられ
;   なかったんだな！
;   わたほ゛う「ざんねんだったな[91]！
;   さあ　かえろう！！
; --------------------------------------------------------------------------
Bank69_Msg17:                              ; $477C  (file $11477C)
    db $EB                         ; $477C  ▶ new page
    db $53,$33,$42,$8D,$26         ; $477D  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4782  end name/box tag
    db $28,$3F,$46,$2E,$43,$54     ; $4783  おひめさまを
    db $90                         ; $4789  　(space)
    db $47,$34,$24,$2C,$8D,$4E,$51 ; $478A  もちあけ゛られ = もちあげられ
    db $EF,$EE                     ; $4791  newline
    db $90,$90                     ; $4793  　　(indent)
    db $39,$29,$36,$33,$55,$33,$8D,$39; $4795  なかったんた゛な = なかったんだな
    db $99                         ; $479D  ！
    db $FA                         ; $479E  wait-for-button
    db $F7                         ; $479F  clear page
    db $EF,$EE                     ; $47A0  newline
    db $53,$33,$42,$8D,$26         ; $47A2  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $47A7  end name/box tag
    db $2E,$8D,$55,$3C,$55,$33,$8D,$36,$33,$39; $47A8  さ゛んねんた゛ったな = ざんねんだったな
    db $91                         ; $47B2  ctrl $91
    db $99                         ; $47B3  ！
    db $EF,$EE                     ; $47B4  newline
    db $90,$90                     ; $47B6  　　(indent)
    db $2E,$24                     ; $47B8  さあ
    db $90                         ; $47BA  　(space)
    db $29,$27,$52,$26             ; $47BB  かえろう
    db $99                         ; $47BF  ！
    db $99                         ; $47C0  ！
    db $F7                         ; $47C1  clear page
    db $F0                         ; $47C2  end of message


; --------------------------------------------------------------------------
; Message #18 ($47C3)
;   「、、。
; --------------------------------------------------------------------------
Bank69_Msg18:                              ; $47C3  (file $1147C3)
    db $EA                         ; $47C3  ▶ new page
    db $9F                         ; $47C4  box tag
    db $96                         ; $47C5  end name/box tag
    db $A4                         ; $47C6  、
    db $A4                         ; $47C7  、
    db $8F                         ; $47C8  。
    db $EF,$EE                     ; $47C9  newline
    db $F7                         ; $47CB  clear page
    db $F0                         ; $47CC  end of message


; --------------------------------------------------------------------------
; Message #19 ($47CD)
;   「ちょっと
;   まって　ほしいんだな。
;   「ここは　とおって
;   ほしくないんだな。
;   「なぜって　ぼくはゴーレムで　この
;   まちの　ようじんぼうなんだな！
; --------------------------------------------------------------------------
Bank69_Msg19:                              ; $47CD  (file $1147CD)
    db $EA                         ; $47CD  ▶ new page
    db $9F                         ; $47CE  box tag
    db $96                         ; $47CF  end name/box tag
    db $34,$4D,$36,$38             ; $47D0  ちょっと
    db $EF,$EE                     ; $47D4  newline
    db $90,$90                     ; $47D6  　　(indent)
    db $43,$36,$37                 ; $47D8  まって
    db $90                         ; $47DB  　(space)
    db $42,$2F,$25,$55,$33,$8D,$39 ; $47DC  ほしいんた゛な = ほしいんだな
    db $8F                         ; $47E3  。
    db $FA                         ; $47E4  wait-for-button
    db $F7                         ; $47E5  clear page
    db $EF,$EE                     ; $47E6  newline
    db $9F                         ; $47E8  box tag
    db $96                         ; $47E9  end name/box tag
    db $2D,$2D,$3E                 ; $47EA  ここは
    db $90                         ; $47ED  　(space)
    db $38,$28,$36,$37             ; $47EE  とおって
    db $EF,$EE                     ; $47F2  newline
    db $90,$90                     ; $47F4  　　(indent)
    db $42,$2F,$2B,$39,$25,$55,$33,$8D,$39; $47F6  ほしくないんた゛な = ほしくないんだな
    db $8F                         ; $47FF  。
    db $FA                         ; $4800  wait-for-button
    db $F7                         ; $4801  clear page
    db $EF,$EE                     ; $4802  newline
    db $9F                         ; $4804  box tag
    db $96                         ; $4805  end name/box tag
    db $39,$31,$8D,$36,$37         ; $4806  なせ゛って = なぜって
    db $90                         ; $480B  　(space)
    db $42,$8D,$2B,$3E,$64,$8D,$9C,$88,$7C,$37,$8D; $480C  ほ゛くはコ゛ーレムて゛ = ぼくはゴーレムで
    db $90                         ; $4817  　(space)
    db $2D,$3D                     ; $4818  この
    db $EF,$EE                     ; $481A  newline
    db $90,$90                     ; $481C  　　(indent)
    db $43,$34,$3D                 ; $481E  まちの
    db $90                         ; $4821  　(space)
    db $4C,$26,$2F,$8D,$55,$42,$8D,$26,$39,$55,$33,$8D,$39; $4822  ようし゛んほ゛うなんた゛な = ようじんぼうなんだな
    db $99                         ; $482F  ！
    db $F7                         ; $4830  clear page
    db $F0                         ; $4831  end of message


; --------------------------------------------------------------------------
; Message #20 ($4832)
;   「なんべん　いったら
;   わかるのかな。
;   「ここは　とおって
;   ほしくないんだな！！
; --------------------------------------------------------------------------
Bank69_Msg20:                              ; $4832  (file $114832)
    db $EA                         ; $4832  ▶ new page
    db $9F                         ; $4833  box tag
    db $96                         ; $4834  end name/box tag
    db $39,$55,$41,$8D,$55         ; $4835  なんへ゛ん = なんべん
    db $90                         ; $483A  　(space)
    db $25,$36,$33,$4E             ; $483B  いったら
    db $EF,$EE                     ; $483F  newline
    db $90,$90                     ; $4841  　　(indent)
    db $53,$29,$50,$3D,$29,$39     ; $4843  わかるのかな
    db $8F                         ; $4849  。
    db $FA                         ; $484A  wait-for-button
    db $F7                         ; $484B  clear page
    db $EF,$EE                     ; $484C  newline
    db $9F                         ; $484E  box tag
    db $96                         ; $484F  end name/box tag
    db $2D,$2D,$3E                 ; $4850  ここは
    db $90                         ; $4853  　(space)
    db $38,$28,$36,$37             ; $4854  とおって
    db $EF,$EE                     ; $4858  newline
    db $90,$90                     ; $485A  　　(indent)
    db $42,$2F,$2B,$39,$25,$55,$33,$8D,$39; $485C  ほしくないんた゛な = ほしくないんだな
    db $99                         ; $4865  ！
    db $99                         ; $4866  ！
    db $F7                         ; $4867  clear page
    db $F0                         ; $4868  end of message


; --------------------------------------------------------------------------
; Message #21 ($4869)
;   「おまえ　つよいんだな。
;   「でも　ぼくに　かっても
;   まちには　はいれないんだな、。
; --------------------------------------------------------------------------
Bank69_Msg21:                              ; $4869  (file $114869)
    db $EA                         ; $4869  ▶ new page
    db $9F                         ; $486A  box tag
    db $96                         ; $486B  end name/box tag
    db $28,$43,$27                 ; $486C  おまえ
    db $90                         ; $486F  　(space)
    db $35,$4C,$25,$55,$33,$8D,$39 ; $4870  つよいんた゛な = つよいんだな
    db $8F                         ; $4877  。
    db $EF,$EE                     ; $4878  newline
    db $FA                         ; $487A  wait-for-button
    db $F7                         ; $487B  clear page
    db $EF,$EE                     ; $487C  newline
    db $F3                         ; $487E  open text box
    db $9F                         ; $487F  box tag
    db $96                         ; $4880  end name/box tag
    db $37,$8D,$47                 ; $4881  て゛も = でも
    db $90                         ; $4884  　(space)
    db $42,$8D,$2B,$3A             ; $4885  ほ゛くに = ぼくに
    db $90                         ; $4889  　(space)
    db $29,$36,$37,$47             ; $488A  かっても
    db $EF,$EE                     ; $488E  newline
    db $90,$90                     ; $4890  　　(indent)
    db $43,$34,$3A,$3E             ; $4892  まちには
    db $90                         ; $4896  　(space)
    db $3E,$25,$51,$39,$25,$55,$33,$8D,$39; $4897  はいれないんた゛な = はいれないんだな
    db $A4                         ; $48A0  、
    db $8F                         ; $48A1  。
    db $F7                         ; $48A2  clear page
    db $F0                         ; $48A3  end of message


; --------------------------------------------------------------------------
; Message #22 ($48A4)
;   「おれの　かわいいキユットフラィと
;   みあいしようぜ！
; --------------------------------------------------------------------------
Bank69_Msg22:                              ; $48A4  (file $1148A4)
    db $EA                         ; $48A4  ▶ new page
    db $9F                         ; $48A5  box tag
    db $96                         ; $48A6  end name/box tag
    db $28,$51,$3D                 ; $48A7  おれの
    db $90                         ; $48AA  　(space)
    db $29,$53,$25,$25,$61,$80,$6D,$6F,$77,$85,$58,$38; $48AB  かわいいキユットフラィと
    db $EF,$EE                     ; $48B7  newline
    db $90,$90                     ; $48B9  　　(indent)
    db $44,$24,$25,$2F,$4C,$26,$31,$8D; $48BB  みあいしようせ゛ = みあいしようぜ
    db $99                         ; $48C3  ！
    db $F0                         ; $48C4  end of message


; --------------------------------------------------------------------------
; Message #23 ($48C5)
;   「これから　[0D]クラスをめざすのか？
;   なら　ミッキーには　きをつけな！
;   「いろんな　まものと　はいごうして
;   とくぎをいっぱい　おぼえるんだ！
;   「すげえまものが　きっとできるぜ。
;   がんばれよ！
; --------------------------------------------------------------------------
Bank69_Msg23:                              ; $48C5  (file $1148C5)
    db $EA                         ; $48C5  ▶ new page
    db $9F                         ; $48C6  box tag
    db $96                         ; $48C7  end name/box tag
    db $2D,$51,$29,$4E             ; $48C8  これから
    db $90                         ; $48CC  　(space)
    db $0D                         ; $48CD  ctrl $0D
    db $62,$85,$67,$54,$46,$2E,$8D,$30,$3D,$29; $48CE  クラスをめさ゛すのか = クラスをめざすのか
    db $98                         ; $48D8  ？
    db $EF,$EE                     ; $48D9  newline
    db $90,$90                     ; $48DB  　　(indent)
    db $39,$4E                     ; $48DD  なら
    db $90                         ; $48DF  　(space)
    db $7B,$6D,$61,$9C,$3A,$3E     ; $48E0  ミッキーには
    db $90                         ; $48E6  　(space)
    db $2A,$54,$35,$2C,$39         ; $48E7  きをつけな
    db $99                         ; $48EC  ！
    db $FA                         ; $48ED  wait-for-button
    db $F7                         ; $48EE  clear page
    db $EF,$EE                     ; $48EF  newline
    db $9F                         ; $48F1  box tag
    db $96                         ; $48F2  end name/box tag
    db $25,$52,$55,$39             ; $48F3  いろんな
    db $90                         ; $48F7  　(space)
    db $43,$47,$3D,$38             ; $48F8  まものと
    db $90                         ; $48FC  　(space)
    db $3E,$25,$2D,$8D,$26,$2F,$37 ; $48FD  はいこ゛うして = はいごうして
    db $EF,$EE                     ; $4904  newline
    db $90,$90                     ; $4906  　　(indent)
    db $38,$2B,$2A,$8D,$54,$25,$36,$3E,$8E,$25; $4908  とくき゛をいっは゜い = とくぎをいっぱい
    db $90                         ; $4912  　(space)
    db $28,$42,$8D,$27,$50,$55,$33,$8D; $4913  おほ゛えるんた゛ = おぼえるんだ
    db $99                         ; $491B  ！
    db $FA                         ; $491C  wait-for-button
    db $F7                         ; $491D  clear page
    db $EF,$EE                     ; $491E  newline
    db $9F                         ; $4920  box tag
    db $96                         ; $4921  end name/box tag
    db $30,$2C,$8D,$27,$43,$47,$3D,$29,$8D; $4922  すけ゛えまものか゛ = すげえまものが
    db $90                         ; $492B  　(space)
    db $2A,$36,$38,$37,$8D,$2A,$50,$31,$8D; $492C  きっとて゛きるせ゛ = きっとできるぜ
    db $8F                         ; $4935  。
    db $EF,$EE                     ; $4936  newline
    db $90,$90                     ; $4938  　　(indent)
    db $29,$8D,$55,$3E,$8D,$51,$4C ; $493A  か゛んは゛れよ = がんばれよ
    db $99                         ; $4941  ！
    db $F7                         ; $4942  clear page
    db $F0                         ; $4943  end of message


; --------------------------------------------------------------------------
; Message #24 ($4944)
;   「そこの　ぬしは　どのけいとうにも
;   ぞくさない　まものらしいぜ！
; --------------------------------------------------------------------------
Bank69_Msg24:                              ; $4944  (file $114944)
    db $EA                         ; $4944  ▶ new page
    db $9F                         ; $4945  box tag
    db $96                         ; $4946  end name/box tag
    db $32,$2D,$3D                 ; $4947  そこの
    db $90                         ; $494A  　(space)
    db $3B,$2F,$3E                 ; $494B  ぬしは
    db $90                         ; $494E  　(space)
    db $38,$8D,$3D,$2C,$25,$38,$26,$3A,$47; $494F  と゛のけいとうにも = どのけいとうにも
    db $EF,$EE                     ; $4958  newline
    db $90,$90                     ; $495A  　　(indent)
    db $32,$8D,$2B,$2E,$39,$25     ; $495C  そ゛くさない = ぞくさない
    db $90                         ; $4962  　(space)
    db $43,$47,$3D,$4E,$2F,$25,$31,$8D; $4963  まものらしいせ゛ = まものらしいぜ
    db $99                         ; $496B  ！
    db $F7                         ; $496C  clear page
    db $F0                         ; $496D  end of message


; --------------------------------------------------------------------------
; Message #25 ($496E)
;   「、あそこは　スラィムけいの
;   まものたちの　そうくつだそうだ。
;   「そこのぬしは　だいまおうさえも
;   おそれおののく　まものだそうだ。
;   「ねだやしのとびらのことも
;   きいているぞ。　ききたいかい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg25:                              ; $496E  (file $11496E)
    db $EA                         ; $496E  ▶ new page
    db $9F                         ; $496F  box tag
    db $96                         ; $4970  end name/box tag
    db $A4                         ; $4971  、
    db $24,$32,$2D,$3E             ; $4972  あそこは
    db $90                         ; $4976  　(space)
    db $67,$85,$58,$7C,$2C,$25,$3D ; $4977  スラィムけいの
    db $EF,$EE                     ; $497E  newline
    db $90,$90                     ; $4980  　　(indent)
    db $43,$47,$3D,$33,$34,$3D     ; $4982  まものたちの
    db $90                         ; $4988  　(space)
    db $32,$26,$2B,$35,$33,$8D,$32,$26,$33,$8D; $4989  そうくつた゛そうた゛ = そうくつだそうだ
    db $8F                         ; $4993  。
    db $FA                         ; $4994  wait-for-button
    db $F7                         ; $4995  clear page
    db $EF,$EE                     ; $4996  newline
    db $9F                         ; $4998  box tag
    db $96                         ; $4999  end name/box tag
    db $32,$2D,$3D,$3B,$2F,$3E     ; $499A  そこのぬしは
    db $90                         ; $49A0  　(space)
    db $33,$8D,$25,$43,$28,$26,$2E,$27,$47; $49A1  た゛いまおうさえも = だいまおうさえも
    db $EF,$EE                     ; $49AA  newline
    db $90,$90                     ; $49AC  　　(indent)
    db $28,$32,$51,$28,$3D,$3D,$2B ; $49AE  おそれおののく
    db $90                         ; $49B5  　(space)
    db $43,$47,$3D,$33,$8D,$32,$26,$33,$8D; $49B6  まものた゛そうた゛ = まものだそうだ
    db $8F                         ; $49BF  。
    db $FA                         ; $49C0  wait-for-button
    db $F7                         ; $49C1  clear page
    db $EF,$EE                     ; $49C2  newline
    db $9F                         ; $49C4  box tag
    db $96                         ; $49C5  end name/box tag
    db $3C,$33,$8D,$48,$2F,$3D,$38,$3F,$8D,$4E,$3D,$2D,$38,$47; $49C6  ねた゛やしのとひ゛らのことも = ねだやしのとびらのことも
    db $EF,$EE                     ; $49D4  newline
    db $90,$90                     ; $49D6  　　(indent)
    db $2A,$25,$37,$25,$50,$32,$8D ; $49D8  きいているそ゛ = きいているぞ
    db $8F                         ; $49DF  。
    db $90                         ; $49E0  　(space)
    db $2A,$2A,$33,$25,$29,$25     ; $49E1  ききたいかい
    db $98                         ; $49E7  ？
    db $FF                         ; $49E8  はい/いいえ
    db $F0                         ; $49E9  end of message


; --------------------------------------------------------------------------
; Message #26 ($49EA)
;   「ぼくは　ミッキー。
;   ファンがうるさくて　たいへんさ！
; --------------------------------------------------------------------------
Bank69_Msg26:                              ; $49EA  (file $1149EA)
    db $EA                         ; $49EA  ▶ new page
    db $9F                         ; $49EB  box tag
    db $96                         ; $49EC  end name/box tag
    db $42,$8D,$2B,$3E             ; $49ED  ほ゛くは = ぼくは
    db $90                         ; $49F1  　(space)
    db $7B,$6D,$61,$9C             ; $49F2  ミッキー
    db $8F                         ; $49F6  。
    db $EF,$EE                     ; $49F7  newline
    db $90,$90                     ; $49F9  　　(indent)
    db $77,$57,$8C,$29,$8D,$26,$50,$2E,$2B,$37; $49FB  ファンか゛うるさくて = ファンがうるさくて
    db $90                         ; $4A05  　(space)
    db $33,$25,$41,$55,$2E         ; $4A06  たいへんさ
    db $99                         ; $4A0B  ！
    db $F7                         ; $4A0C  clear page
    db $F0                         ; $4A0D  end of message


; --------------------------------------------------------------------------
; Message #27 ($4A0E)
;   「おうひさまが　ぼくを
;   わざわざ　まねいてくれたんだよ。
; --------------------------------------------------------------------------
Bank69_Msg27:                              ; $4A0E  (file $114A0E)
    db $EA                         ; $4A0E  ▶ new page
    db $9F                         ; $4A0F  box tag
    db $96                         ; $4A10  end name/box tag
    db $28,$26,$3F,$2E,$43,$29,$8D ; $4A11  おうひさまか゛ = おうひさまが
    db $90                         ; $4A18  　(space)
    db $42,$8D,$2B,$54             ; $4A19  ほ゛くを = ぼくを
    db $EF,$EE                     ; $4A1D  newline
    db $90,$90                     ; $4A1F  　　(indent)
    db $53,$2E,$8D,$53,$2E,$8D     ; $4A21  わさ゛わさ゛ = わざわざ
    db $90                         ; $4A27  　(space)
    db $43,$3C,$25,$37,$2B,$51,$33,$55,$33,$8D,$4C; $4A28  まねいてくれたんた゛よ = まねいてくれたんだよ
    db $8F                         ; $4A33  。
    db $F7                         ; $4A34  clear page
    db $F0                         ; $4A35  end of message


; --------------------------------------------------------------------------
; Message #28 ($4A36)
;   「きみも　ゆうめいになれば
;   こうして　まねいてもらえるのさ！
; --------------------------------------------------------------------------
Bank69_Msg28:                              ; $4A36  (file $114A36)
    db $EA                         ; $4A36  ▶ new page
    db $9F                         ; $4A37  box tag
    db $96                         ; $4A38  end name/box tag
    db $2A,$44,$47                 ; $4A39  きみも
    db $90                         ; $4A3C  　(space)
    db $4A,$26,$46,$25,$3A,$39,$51,$3E,$8D; $4A3D  ゆうめいになれは゛ = ゆうめいになれば
    db $EF,$EE                     ; $4A46  newline
    db $90,$90                     ; $4A48  　　(indent)
    db $2D,$26,$2F,$37             ; $4A4A  こうして
    db $90                         ; $4A4E  　(space)
    db $43,$3C,$25,$37,$47,$4E,$27,$50,$3D,$2E; $4A4F  まねいてもらえるのさ
    db $99                         ; $4A59  ！
    db $F7                         ; $4A5A  clear page
    db $F0                         ; $4A5B  end of message


; --------------------------------------------------------------------------
; Message #29 ($4A5C)
;   「、きみ！　えらく　ぼくに
;   はなしかけてくれるね。
;   「そのしつこさへの　おかえしに
;   おみあいを　させてあげよう。
;   「よわそうなのばかり
;   つれている　みたいだからね。
;   「ぼくのまものは　リザードマンだ。
;   さあ　おみあいしようか！
; --------------------------------------------------------------------------
Bank69_Msg29:                              ; $4A5C  (file $114A5C)
    db $EA                         ; $4A5C  ▶ new page
    db $9F                         ; $4A5D  box tag
    db $96                         ; $4A5E  end name/box tag
    db $A4                         ; $4A5F  、
    db $2A,$44                     ; $4A60  きみ
    db $99                         ; $4A62  ！
    db $90                         ; $4A63  　(space)
    db $27,$4E,$2B                 ; $4A64  えらく
    db $90                         ; $4A67  　(space)
    db $42,$8D,$2B,$3A             ; $4A68  ほ゛くに = ぼくに
    db $EF,$EE                     ; $4A6C  newline
    db $90,$90                     ; $4A6E  　　(indent)
    db $3E,$39,$2F,$29,$2C,$37,$2B,$51,$50,$3C; $4A70  はなしかけてくれるね
    db $8F                         ; $4A7A  。
    db $FA                         ; $4A7B  wait-for-button
    db $F7                         ; $4A7C  clear page
    db $EF,$EE                     ; $4A7D  newline
    db $9F                         ; $4A7F  box tag
    db $96                         ; $4A80  end name/box tag
    db $32,$3D,$2F,$35,$2D,$2E,$41,$3D; $4A81  そのしつこさへの
    db $90                         ; $4A89  　(space)
    db $28,$29,$27,$2F,$3A         ; $4A8A  おかえしに
    db $EF,$EE                     ; $4A8F  newline
    db $90,$90                     ; $4A91  　　(indent)
    db $28,$44,$24,$25,$54         ; $4A93  おみあいを
    db $90                         ; $4A98  　(space)
    db $2E,$31,$37,$24,$2C,$8D,$4C,$26; $4A99  させてあけ゛よう = させてあげよう
    db $8F                         ; $4AA1  。
    db $FA                         ; $4AA2  wait-for-button
    db $F7                         ; $4AA3  clear page
    db $EF,$EE                     ; $4AA4  newline
    db $9F                         ; $4AA6  box tag
    db $96                         ; $4AA7  end name/box tag
    db $4C,$53,$32,$26,$39,$3D,$3E,$8D,$29,$4F; $4AA8  よわそうなのは゛かり = よわそうなのばかり
    db $EF,$EE                     ; $4AB2  newline
    db $90,$90                     ; $4AB4  　　(indent)
    db $35,$51,$37,$25,$50         ; $4AB6  つれている
    db $90                         ; $4ABB  　(space)
    db $44,$33,$25,$33,$8D,$29,$4E,$3C; $4ABC  みたいた゛からね = みたいだからね
    db $8F                         ; $4AC4  。
    db $FA                         ; $4AC5  wait-for-button
    db $F7                         ; $4AC6  clear page
    db $EF,$EE                     ; $4AC7  newline
    db $9F                         ; $4AC9  box tag
    db $96                         ; $4ACA  end name/box tag
    db $42,$8D,$2B,$3D,$43,$47,$3D,$3E; $4ACB  ほ゛くのまものは = ぼくのまものは
    db $90                         ; $4AD3  　(space)
    db $86,$65,$8D,$9C,$6F,$8D,$7A,$8C,$33,$8D; $4AD4  リサ゛ート゛マンた゛ = リザードマンだ
    db $8F                         ; $4ADE  。
    db $EF,$EE                     ; $4ADF  newline
    db $90,$90                     ; $4AE1  　　(indent)
    db $2E,$24                     ; $4AE3  さあ
    db $90                         ; $4AE5  　(space)
    db $28,$44,$24,$25,$2F,$4C,$26,$29; $4AE6  おみあいしようか
    db $99                         ; $4AEE  ！
    db $F0                         ; $4AEF  end of message


; --------------------------------------------------------------------------
; Message #30 ($4AF0)
;   わたほ゛う「このまちは　ゴーレムが
;   みている　まぼろしのまちなんだ。
;   わたほ゛う「だから　なかに
;   はいることは　できないよ。
;   わたほ゛う「さあ　おしろに　もどろう！
; --------------------------------------------------------------------------
Bank69_Msg30:                              ; $4AF0  (file $114AF0)
    db $EB                         ; $4AF0  ▶ new page
    db $53,$33,$42,$8D,$26         ; $4AF1  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4AF6  end name/box tag
    db $2D,$3D,$43,$34,$3E         ; $4AF7  このまちは
    db $90                         ; $4AFC  　(space)
    db $64,$8D,$9C,$88,$7C,$29,$8D ; $4AFD  コ゛ーレムか゛ = ゴーレムが
    db $EF,$EE                     ; $4B04  newline
    db $90,$90                     ; $4B06  　　(indent)
    db $44,$37,$25,$50             ; $4B08  みている
    db $90                         ; $4B0C  　(space)
    db $43,$42,$8D,$52,$2F,$3D,$43,$34,$39,$55,$33,$8D; $4B0D  まほ゛ろしのまちなんた゛ = まぼろしのまちなんだ
    db $8F                         ; $4B19  。
    db $FA                         ; $4B1A  wait-for-button
    db $F7                         ; $4B1B  clear page
    db $EF,$EE                     ; $4B1C  newline
    db $53,$33,$42,$8D,$26         ; $4B1E  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4B23  end name/box tag
    db $33,$8D,$29,$4E             ; $4B24  た゛から = だから
    db $90                         ; $4B28  　(space)
    db $39,$29,$3A                 ; $4B29  なかに
    db $EF,$EE                     ; $4B2C  newline
    db $90,$90                     ; $4B2E  　　(indent)
    db $3E,$25,$50,$2D,$38,$3E     ; $4B30  はいることは
    db $90                         ; $4B36  　(space)
    db $37,$8D,$2A,$39,$25,$4C     ; $4B37  て゛きないよ = できないよ
    db $8F                         ; $4B3D  。
    db $FA                         ; $4B3E  wait-for-button
    db $F7                         ; $4B3F  clear page
    db $EF,$EE                     ; $4B40  newline
    db $53,$33,$42,$8D,$26         ; $4B42  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4B47  end name/box tag
    db $2E,$24                     ; $4B48  さあ
    db $90                         ; $4B4A  　(space)
    db $28,$2F,$52,$3A             ; $4B4B  おしろに
    db $90                         ; $4B4F  　(space)
    db $47,$38,$8D,$52,$26         ; $4B50  もと゛ろう = もどろう
    db $99                         ; $4B55  ！
    db $EF,$EE                     ; $4B56  newline
    db $F7                         ; $4B58  clear page
    db $F0                         ; $4B59  end of message


; --------------------------------------------------------------------------
; Message #31 ($4B5A)
;   「ガルルルルル、、
;   フーッ　フーッ！
; --------------------------------------------------------------------------
Bank69_Msg31:                              ; $4B5A  (file $114B5A)
    db $EA                         ; $4B5A  ▶ new page
    db $9F                         ; $4B5B  box tag
    db $96                         ; $4B5C  end name/box tag
    db $60,$8D,$87,$87,$87,$87,$87 ; $4B5D  カ゛ルルルルル = ガルルルルル
    db $A4                         ; $4B64  、
    db $A4                         ; $4B65  、
    db $EF,$EE                     ; $4B66  newline
    db $90,$90                     ; $4B68  　　(indent)
    db $77,$9C,$6D                 ; $4B6A  フーッ
    db $90                         ; $4B6D  　(space)
    db $77,$9C,$6D                 ; $4B6E  フーッ
    db $99                         ; $4B71  ！
    db $F7                         ; $4B72  clear page
    db $F0                         ; $4B73  end of message


; --------------------------------------------------------------------------
; Message #32 ($4B74)
;   「ゲラゲラ、、？
;   ゲルゲル、、？
; --------------------------------------------------------------------------
Bank69_Msg32:                              ; $4B74  (file $114B74)
    db $EA                         ; $4B74  ▶ new page
    db $9F                         ; $4B75  box tag
    db $96                         ; $4B76  end name/box tag
    db $63,$8D,$85,$63,$8D,$85     ; $4B77  ケ゛ラケ゛ラ = ゲラゲラ
    db $A4                         ; $4B7D  、
    db $A4                         ; $4B7E  、
    db $98                         ; $4B7F  ？
    db $EF,$EE                     ; $4B80  newline
    db $90,$90                     ; $4B82  　　(indent)
    db $63,$8D,$87,$63,$8D,$87     ; $4B84  ケ゛ルケ゛ル = ゲルゲル
    db $A4                         ; $4B8A  、
    db $A4                         ; $4B8B  、
    db $98                         ; $4B8C  ？
    db $F7                         ; $4B8D  clear page
    db $F0                         ; $4B8E  end of message


; --------------------------------------------------------------------------
; Message #33 ($4B8F)
;   「ガルルルルル、、
;   フーッ　フーッ！
;   「、、、、、、、、ゲレゲレ！！
; --------------------------------------------------------------------------
Bank69_Msg33:                              ; $4B8F  (file $114B8F)
    db $EA                         ; $4B8F  ▶ new page
    db $9F                         ; $4B90  box tag
    db $96                         ; $4B91  end name/box tag
    db $60,$8D,$87,$87,$87,$87,$87 ; $4B92  カ゛ルルルルル = ガルルルルル
    db $A4                         ; $4B99  、
    db $A4                         ; $4B9A  、
    db $EF,$EE                     ; $4B9B  newline
    db $90,$90                     ; $4B9D  　　(indent)
    db $77,$9C,$6D                 ; $4B9F  フーッ
    db $90                         ; $4BA2  　(space)
    db $77,$9C,$6D                 ; $4BA3  フーッ
    db $99                         ; $4BA6  ！
    db $FA                         ; $4BA7  wait-for-button
    db $F7                         ; $4BA8  clear page
    db $EF,$EE                     ; $4BA9  newline
    db $9F                         ; $4BAB  box tag
    db $96                         ; $4BAC  end name/box tag
    db $A4                         ; $4BAD  、
    db $A4                         ; $4BAE  、
    db $A4                         ; $4BAF  、
    db $A4                         ; $4BB0  、
    db $A4                         ; $4BB1  、
    db $A4                         ; $4BB2  、
    db $A4                         ; $4BB3  、
    db $A4                         ; $4BB4  、
    db $63,$8D,$88,$63,$8D,$88     ; $4BB5  ケ゛レケ゛レ = ゲレゲレ
    db $99                         ; $4BBB  ！
    db $99                         ; $4BBC  ！
    db $EF,$EE                     ; $4BBD  newline
    db $F7                         ; $4BBF  clear page
    db $F0                         ; $4BC0  end of message


; --------------------------------------------------------------------------
; Message #34 ($4BC1)
;   「ガルルルルル、、
;   ゲレゲレ！！
; --------------------------------------------------------------------------
Bank69_Msg34:                              ; $4BC1  (file $114BC1)
    db $EA                         ; $4BC1  ▶ new page
    db $9F                         ; $4BC2  box tag
    db $96                         ; $4BC3  end name/box tag
    db $60,$8D,$87,$87,$87,$87,$87 ; $4BC4  カ゛ルルルルル = ガルルルルル
    db $A4                         ; $4BCB  、
    db $A4                         ; $4BCC  、
    db $EF,$EE                     ; $4BCD  newline
    db $90,$90                     ; $4BCF  　　(indent)
    db $63,$8D,$88,$63,$8D,$88     ; $4BD1  ケ゛レケ゛レ = ゲレゲレ
    db $99                         ; $4BD7  ！
    db $99                         ; $4BD8  ！
    db $F7                         ; $4BD9  clear page
    db $F0                         ; $4BDA  end of message


; --------------------------------------------------------------------------
; Message #35 ($4BDB)
;   「〈テリー〉！
;   〈テリー〉！！
;   「みゃーお　ゴロゴロ、、。
; --------------------------------------------------------------------------
Bank69_Msg35:                              ; $4BDB  (file $114BDB)
    db $EA                         ; $4BDB  ▶ new page
    db $9F                         ; $4BDC  box tag
    db $96                         ; $4BDD  end name/box tag
    db $F6                         ; $4BDE  «insert hero name»
    db $99                         ; $4BDF  ！
    db $EF,$EE                     ; $4BE0  newline
    db $90,$90                     ; $4BE2  　　(indent)
    db $F6                         ; $4BE4  «insert hero name»
    db $99                         ; $4BE5  ！
    db $99                         ; $4BE6  ！
    db $FA                         ; $4BE7  wait-for-button
    db $F7                         ; $4BE8  clear page
    db $EF,$EE                     ; $4BE9  newline
    db $9F                         ; $4BEB  box tag
    db $96                         ; $4BEC  end name/box tag
    db $44,$49,$9C,$28             ; $4BED  みゃーお
    db $90                         ; $4BF1  　(space)
    db $64,$8D,$89,$64,$8D,$89     ; $4BF2  コ゛ロコ゛ロ = ゴロゴロ
    db $A4                         ; $4BF8  、
    db $A4                         ; $4BF9  、
    db $8F                         ; $4BFA  。
    db $EF,$EE                     ; $4BFB  newline
    db $F7                         ; $4BFD  clear page
    db $F0                         ; $4BFE  end of message


; --------------------------------------------------------------------------
; Message #36 ($4BFF)
;   わたほ゛う「キラーパンサーは
;   〈テリー〉に　なついたみたいだな！
;   わたほ゛う「さあ　かえろう！
; --------------------------------------------------------------------------
Bank69_Msg36:                              ; $4BFF  (file $114BFF)
    db $EB                         ; $4BFF  ▶ new page
    db $53,$33,$42,$8D,$26         ; $4C00  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4C05  end name/box tag
    db $61,$85,$9C,$75,$8E,$8C,$65,$9C,$3E; $4C06  キラーハ゜ンサーは = キラーパンサーは
    db $EF,$EE                     ; $4C0F  newline
    db $90,$90                     ; $4C11  　　(indent)
    db $F6                         ; $4C13  «insert hero name»
    db $3A                         ; $4C14  に
    db $90                         ; $4C15  　(space)
    db $39,$35,$25,$33,$44,$33,$25,$33,$8D,$39; $4C16  なついたみたいた゛な = なついたみたいだな
    db $99                         ; $4C20  ！
    db $FA                         ; $4C21  wait-for-button
    db $F7                         ; $4C22  clear page
    db $EF,$EE                     ; $4C23  newline
    db $53,$33,$42,$8D,$26         ; $4C25  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $4C2A  end name/box tag
    db $2E,$24                     ; $4C2B  さあ
    db $90                         ; $4C2D  　(space)
    db $29,$27,$52,$26             ; $4C2E  かえろう
    db $99                         ; $4C32  ！
    db $EF,$EE                     ; $4C33  newline
    db $F7                         ; $4C35  clear page
    db $F0                         ; $4C36  end of message


; --------------------------------------------------------------------------
; Message #37 ($4C37)
;   〈テリー〉は　たてふだを　よんだ。
;   「わかいうちは　あせっても　だめ！
;   とおまわりも　たまには　ひつよう！
; --------------------------------------------------------------------------
Bank69_Msg37:                              ; $4C37  (file $114C37)
    db $F6                         ; $4C37  «insert hero name»
    db $3E                         ; $4C38  は
    db $90                         ; $4C39  　(space)
    db $33,$37,$40,$33,$8D,$54     ; $4C3A  たてふた゛を = たてふだを
    db $90                         ; $4C40  　(space)
    db $4C,$55,$33,$8D             ; $4C41  よんた゛ = よんだ
    db $8F                         ; $4C45  。
    db $EF,$EE                     ; $4C46  newline
    db $FA                         ; $4C48  wait-for-button
    db $F7                         ; $4C49  clear page
    db $EF,$EE                     ; $4C4A  newline
    db $F3                         ; $4C4C  open text box
    db $96                         ; $4C4D  end name/box tag
    db $53,$29,$25,$26,$34,$3E     ; $4C4E  わかいうちは
    db $90                         ; $4C54  　(space)
    db $24,$31,$36,$37,$47         ; $4C55  あせっても
    db $90                         ; $4C5A  　(space)
    db $33,$8D,$46                 ; $4C5B  た゛め = だめ
    db $99                         ; $4C5E  ！
    db $EF,$EE                     ; $4C5F  newline
    db $90                         ; $4C61  　(space)
    db $38,$28,$43,$53,$4F,$47     ; $4C62  とおまわりも
    db $90                         ; $4C68  　(space)
    db $33,$43,$3A,$3E             ; $4C69  たまには
    db $90                         ; $4C6D  　(space)
    db $3F,$35,$4C,$26             ; $4C6E  ひつよう
    db $99                         ; $4C72  ！
    db $F7                         ; $4C73  clear page
    db $F0                         ; $4C74  end of message


; --------------------------------------------------------------------------
; Message #38 ($4C75)
;   「キーキキキッ！
;   よく　ここまで　これたのう！
;   「じゃが　ざんねんなことに
;   ここが　いきどまりなんじゃ！
; --------------------------------------------------------------------------
Bank69_Msg38:                              ; $4C75  (file $114C75)
    db $EA                         ; $4C75  ▶ new page
    db $9F                         ; $4C76  box tag
    db $96                         ; $4C77  end name/box tag
    db $61,$9C,$61,$61,$61,$6D     ; $4C78  キーキキキッ
    db $99                         ; $4C7E  ！
    db $EF,$EE                     ; $4C7F  newline
    db $90,$90                     ; $4C81  　　(indent)
    db $4C,$2B                     ; $4C83  よく
    db $90                         ; $4C85  　(space)
    db $2D,$2D,$43,$37,$8D         ; $4C86  ここまて゛ = ここまで
    db $90                         ; $4C8B  　(space)
    db $2D,$51,$33,$3D,$26         ; $4C8C  これたのう
    db $99                         ; $4C91  ！
    db $FA                         ; $4C92  wait-for-button
    db $F7                         ; $4C93  clear page
    db $EF,$EE                     ; $4C94  newline
    db $9F                         ; $4C96  box tag
    db $96                         ; $4C97  end name/box tag
    db $2F,$8D,$49,$29,$8D         ; $4C98  し゛ゃか゛ = じゃが
    db $90                         ; $4C9D  　(space)
    db $2E,$8D,$55,$3C,$55,$39,$2D,$38,$3A; $4C9E  さ゛んねんなことに = ざんねんなことに
    db $EF,$EE                     ; $4CA7  newline
    db $90,$90                     ; $4CA9  　　(indent)
    db $2D,$2D,$29,$8D             ; $4CAB  ここか゛ = ここが
    db $90                         ; $4CAF  　(space)
    db $25,$2A,$38,$8D,$43,$4F,$39,$55,$2F,$8D,$49; $4CB0  いきと゛まりなんし゛ゃ = いきどまりなんじゃ
    db $99                         ; $4CBB  ！
    db $F7                         ; $4CBC  clear page
    db $F0                         ; $4CBD  end of message


; --------------------------------------------------------------------------
; Message #39 ($4CBE)
;   「なんべん　たたかっても
;   おなじことよのう！
; --------------------------------------------------------------------------
Bank69_Msg39:                              ; $4CBE  (file $114CBE)
    db $EA                         ; $4CBE  ▶ new page
    db $9F                         ; $4CBF  box tag
    db $96                         ; $4CC0  end name/box tag
    db $39,$55,$41,$8D,$55         ; $4CC1  なんへ゛ん = なんべん
    db $90                         ; $4CC6  　(space)
    db $33,$33,$29,$36,$37,$47     ; $4CC7  たたかっても
    db $EF,$EE                     ; $4CCD  newline
    db $90,$90                     ; $4CCF  　　(indent)
    db $28,$39,$2F,$8D,$2D,$38,$4C,$3D,$26; $4CD1  おなし゛ことよのう = おなじことよのう
    db $99                         ; $4CDA  ！
    db $F7                         ; $4CDB  clear page
    db $F0                         ; $4CDC  end of message


; --------------------------------------------------------------------------
; Message #40 ($4CDD)
;   「ぼくの　リザードマンと
;   おみあい　させてほしいかい？
; --------------------------------------------------------------------------
Bank69_Msg40:                              ; $4CDD  (file $114CDD)
    db $EA                         ; $4CDD  ▶ new page
    db $9F                         ; $4CDE  box tag
    db $96                         ; $4CDF  end name/box tag
    db $42,$8D,$2B,$3D             ; $4CE0  ほ゛くの = ぼくの
    db $90                         ; $4CE4  　(space)
    db $86,$65,$8D,$9C,$6F,$8D,$7A,$8C,$38; $4CE5  リサ゛ート゛マンと = リザードマンと
    db $EF,$EE                     ; $4CEE  newline
    db $90,$90                     ; $4CF0  　　(indent)
    db $28,$44,$24,$25             ; $4CF2  おみあい
    db $90                         ; $4CF6  　(space)
    db $2E,$31,$37,$42,$2F,$25,$29,$25; $4CF7  させてほしいかい
    db $98                         ; $4CFF  ？
    db $F0                         ; $4D00  end of message


; --------------------------------------------------------------------------
; Message #41 ($4D01)
;   「じぶんいがいの　マスターのもつ
;   まものと　おみあいしたほうが、
;   「ひとりで　はいごうしているより
;   つよい　まものができるのさ！
;   「ぼくで　おやくに　たてるなら
;   いつでも　いっておくれ。
;   「ハハハハハハ、、。
; --------------------------------------------------------------------------
Bank69_Msg41:                              ; $4D01  (file $114D01)
    db $EA                         ; $4D01  ▶ new page
    db $9F                         ; $4D02  box tag
    db $96                         ; $4D03  end name/box tag
    db $2F,$8D,$40,$8D,$55,$25,$29,$8D,$25,$3D; $4D04  し゛ふ゛んいか゛いの = じぶんいがいの
    db $90                         ; $4D0E  　(space)
    db $7A,$67,$6A,$9C,$3D,$47,$35 ; $4D0F  マスターのもつ
    db $EF,$EE                     ; $4D16  newline
    db $90,$90                     ; $4D18  　　(indent)
    db $43,$47,$3D,$38             ; $4D1A  まものと
    db $90                         ; $4D1E  　(space)
    db $28,$44,$24,$25,$2F,$33,$42,$26,$29,$8D; $4D1F  おみあいしたほうか゛ = おみあいしたほうが
    db $A4                         ; $4D29  、
    db $FA                         ; $4D2A  wait-for-button
    db $F7                         ; $4D2B  clear page
    db $EF,$EE                     ; $4D2C  newline
    db $9F                         ; $4D2E  box tag
    db $96                         ; $4D2F  end name/box tag
    db $3F,$38,$4F,$37,$8D         ; $4D30  ひとりて゛ = ひとりで
    db $90                         ; $4D35  　(space)
    db $3E,$25,$2D,$8D,$26,$2F,$37,$25,$50,$4C,$4F; $4D36  はいこ゛うしているより = はいごうしているより
    db $EF,$EE                     ; $4D41  newline
    db $90,$90                     ; $4D43  　　(indent)
    db $35,$4C,$25                 ; $4D45  つよい
    db $90                         ; $4D48  　(space)
    db $43,$47,$3D,$29,$8D,$37,$8D,$2A,$50,$3D,$2E; $4D49  まものか゛て゛きるのさ = まものができるのさ
    db $99                         ; $4D54  ！
    db $FA                         ; $4D55  wait-for-button
    db $F7                         ; $4D56  clear page
    db $EF,$EE                     ; $4D57  newline
    db $9F                         ; $4D59  box tag
    db $96                         ; $4D5A  end name/box tag
    db $42,$8D,$2B,$37,$8D         ; $4D5B  ほ゛くて゛ = ぼくで
    db $90                         ; $4D60  　(space)
    db $28,$48,$2B,$3A             ; $4D61  おやくに
    db $90                         ; $4D65  　(space)
    db $33,$37,$50,$39,$4E         ; $4D66  たてるなら
    db $EF,$EE                     ; $4D6B  newline
    db $90,$90                     ; $4D6D  　　(indent)
    db $25,$35,$37,$8D,$47         ; $4D6F  いつて゛も = いつでも
    db $90                         ; $4D74  　(space)
    db $25,$36,$37,$28,$2B,$51     ; $4D75  いっておくれ
    db $8F                         ; $4D7B  。
    db $FA                         ; $4D7C  wait-for-button
    db $F7                         ; $4D7D  clear page
    db $EF,$EE                     ; $4D7E  newline
    db $9F                         ; $4D80  box tag
    db $96                         ; $4D81  end name/box tag
    db $75,$75,$75,$75,$75,$75     ; $4D82  ハハハハハハ
    db $A4                         ; $4D88  、
    db $A4                         ; $4D89  、
    db $8F                         ; $4D8A  。
    db $EF,$EE                     ; $4D8B  newline
    db $F7                         ; $4D8D  clear page
    db $F0                         ; $4D8E  end of message


; --------------------------------------------------------------------------
; Message #42 ($4D8F)
;   「ここは
;   やすらぎとゆうきのへやだ。
;   「みぎが　ゆうきの　とびら
;   ひだりが　やすらぎの　とびらだ。
; --------------------------------------------------------------------------
Bank69_Msg42:                              ; $4D8F  (file $114D8F)
    db $EA                         ; $4D8F  ▶ new page
    db $9F                         ; $4D90  box tag
    db $96                         ; $4D91  end name/box tag
    db $2D,$2D,$3E                 ; $4D92  ここは
    db $EF,$EE                     ; $4D95  newline
    db $90,$90                     ; $4D97  　　(indent)
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48,$33,$8D; $4D99  やすらき゛とゆうきのへやた゛ = やすらぎとゆうきのへやだ
    db $8F                         ; $4DA7  。
    db $FA                         ; $4DA8  wait-for-button
    db $F7                         ; $4DA9  clear page
    db $EF,$EE                     ; $4DAA  newline
    db $9F                         ; $4DAC  box tag
    db $96                         ; $4DAD  end name/box tag
    db $44,$2A,$8D,$29,$8D         ; $4DAE  みき゛か゛ = みぎが
    db $90                         ; $4DB3  　(space)
    db $4A,$26,$2A,$3D             ; $4DB4  ゆうきの
    db $90                         ; $4DB8  　(space)
    db $38,$3F,$8D,$4E             ; $4DB9  とひ゛ら = とびら
    db $EF,$EE                     ; $4DBD  newline
    db $90,$90                     ; $4DBF  　　(indent)
    db $3F,$33,$8D,$4F,$29,$8D     ; $4DC1  ひた゛りか゛ = ひだりが
    db $90                         ; $4DC7  　(space)
    db $48,$30,$4E,$2A,$8D,$3D     ; $4DC8  やすらき゛の = やすらぎの
    db $90                         ; $4DCE  　(space)
    db $38,$3F,$8D,$4E,$33,$8D     ; $4DCF  とひ゛らた゛ = とびらだ
    db $8F                         ; $4DD5  。
    db $F7                         ; $4DD6  clear page
    db $F0                         ; $4DD7  end of message


; --------------------------------------------------------------------------
; Message #43 ($4DD8)
;   「やあ！　きょうのあいては
;   きみかい？　だいじょうぶかな？
;   「そんな　まものじゃ
;   かてるわけないと　おもうけどね！
; --------------------------------------------------------------------------
Bank69_Msg43:                              ; $4DD8  (file $114DD8)
    db $EA                         ; $4DD8  ▶ new page
    db $9F                         ; $4DD9  box tag
    db $96                         ; $4DDA  end name/box tag
    db $48,$24                     ; $4DDB  やあ
    db $99                         ; $4DDD  ！
    db $90                         ; $4DDE  　(space)
    db $2A,$4D,$26,$3D,$24,$25,$37,$3E; $4DDF  きょうのあいては
    db $EF,$EE                     ; $4DE7  newline
    db $90,$90                     ; $4DE9  　　(indent)
    db $2A,$44,$29,$25             ; $4DEB  きみかい
    db $98                         ; $4DEF  ？
    db $90                         ; $4DF0  　(space)
    db $33,$8D,$25,$2F,$8D,$4D,$26,$40,$8D,$29,$39; $4DF1  た゛いし゛ょうふ゛かな = だいじょうぶかな
    db $98                         ; $4DFC  ？
    db $FA                         ; $4DFD  wait-for-button
    db $F7                         ; $4DFE  clear page
    db $EF,$EE                     ; $4DFF  newline
    db $9F                         ; $4E01  box tag
    db $96                         ; $4E02  end name/box tag
    db $32,$55,$39                 ; $4E03  そんな
    db $90                         ; $4E06  　(space)
    db $43,$47,$3D,$2F,$8D,$49     ; $4E07  まものし゛ゃ = まものじゃ
    db $EF,$EE                     ; $4E0D  newline
    db $90,$90                     ; $4E0F  　　(indent)
    db $29,$37,$50,$53,$2C,$39,$25,$38; $4E11  かてるわけないと
    db $90                         ; $4E19  　(space)
    db $28,$47,$26,$2C,$38,$8D,$3C ; $4E1A  おもうけと゛ね = おもうけどね
    db $99                         ; $4E21  ！
    db $F7                         ; $4E22  clear page
    db $F0                         ; $4E23  end of message


; --------------------------------------------------------------------------
; Message #44 ($4E24)
;   「やあ！　だれかと　おもえば
;   きみなのか[91]！
;   「ぼくとの　おみあいが
;   やくにたったみたいだね[94]！
;   「きみが　どれくらい
;   つよいのか　おしえてもらおうか！
; --------------------------------------------------------------------------
Bank69_Msg44:                              ; $4E24  (file $114E24)
    db $EA                         ; $4E24  ▶ new page
    db $9F                         ; $4E25  box tag
    db $96                         ; $4E26  end name/box tag
    db $48,$24                     ; $4E27  やあ
    db $99                         ; $4E29  ！
    db $90                         ; $4E2A  　(space)
    db $33,$8D,$51,$29,$38         ; $4E2B  た゛れかと = だれかと
    db $90                         ; $4E30  　(space)
    db $28,$47,$27,$3E,$8D         ; $4E31  おもえは゛ = おもえば
    db $EF,$EE                     ; $4E36  newline
    db $90,$90                     ; $4E38  　　(indent)
    db $2A,$44,$39,$3D,$29         ; $4E3A  きみなのか
    db $91                         ; $4E3F  ctrl $91
    db $99                         ; $4E40  ！
    db $FA                         ; $4E41  wait-for-button
    db $F7                         ; $4E42  clear page
    db $EF,$EE                     ; $4E43  newline
    db $9F                         ; $4E45  box tag
    db $96                         ; $4E46  end name/box tag
    db $42,$8D,$2B,$38,$3D         ; $4E47  ほ゛くとの = ぼくとの
    db $90                         ; $4E4C  　(space)
    db $28,$44,$24,$25,$29,$8D     ; $4E4D  おみあいか゛ = おみあいが
    db $EF,$EE                     ; $4E53  newline
    db $90,$90                     ; $4E55  　　(indent)
    db $48,$2B,$3A,$33,$36,$33,$44,$33,$25,$33,$8D,$3C; $4E57  やくにたったみたいた゛ね = やくにたったみたいだね
    db $94                         ; $4E63  ctrl $94
    db $99                         ; $4E64  ！
    db $FA                         ; $4E65  wait-for-button
    db $F7                         ; $4E66  clear page
    db $EF,$EE                     ; $4E67  newline
    db $9F                         ; $4E69  box tag
    db $96                         ; $4E6A  end name/box tag
    db $2A,$44,$29,$8D             ; $4E6B  きみか゛ = きみが
    db $90                         ; $4E6F  　(space)
    db $38,$8D,$51,$2B,$4E,$25     ; $4E70  と゛れくらい = どれくらい
    db $EF,$EE                     ; $4E76  newline
    db $90,$90                     ; $4E78  　　(indent)
    db $35,$4C,$25,$3D,$29         ; $4E7A  つよいのか
    db $90                         ; $4E7F  　(space)
    db $28,$2F,$27,$37,$47,$4E,$28,$26,$29; $4E80  おしえてもらおうか
    db $99                         ; $4E89  ！
    db $F7                         ; $4E8A  clear page
    db $F0                         ; $4E8B  end of message


; --------------------------------------------------------------------------
; Message #45 ($4E8C)
;   「また　きみか[91]。
;   なんべんたたかっても　おなじさ！
;   「ぼくは　つよくて
;   きみは　よわい。ただそれだけさ！
; --------------------------------------------------------------------------
Bank69_Msg45:                              ; $4E8C  (file $114E8C)
    db $EA                         ; $4E8C  ▶ new page
    db $9F                         ; $4E8D  box tag
    db $96                         ; $4E8E  end name/box tag
    db $43,$33                     ; $4E8F  また
    db $90                         ; $4E91  　(space)
    db $2A,$44,$29                 ; $4E92  きみか
    db $91                         ; $4E95  ctrl $91
    db $8F                         ; $4E96  。
    db $EF,$EE                     ; $4E97  newline
    db $90,$90                     ; $4E99  　　(indent)
    db $39,$55,$41,$8D,$55,$33,$33,$29,$36,$37,$47; $4E9B  なんへ゛んたたかっても = なんべんたたかっても
    db $90                         ; $4EA6  　(space)
    db $28,$39,$2F,$8D,$2E         ; $4EA7  おなし゛さ = おなじさ
    db $99                         ; $4EAC  ！
    db $FA                         ; $4EAD  wait-for-button
    db $F7                         ; $4EAE  clear page
    db $EF,$EE                     ; $4EAF  newline
    db $9F                         ; $4EB1  box tag
    db $96                         ; $4EB2  end name/box tag
    db $42,$8D,$2B,$3E             ; $4EB3  ほ゛くは = ぼくは
    db $90                         ; $4EB7  　(space)
    db $35,$4C,$2B,$37             ; $4EB8  つよくて
    db $EF,$EE                     ; $4EBC  newline
    db $90,$90                     ; $4EBE  　　(indent)
    db $2A,$44,$3E                 ; $4EC0  きみは
    db $90                         ; $4EC3  　(space)
    db $4C,$53,$25                 ; $4EC4  よわい
    db $8F                         ; $4EC7  。
    db $33,$33,$8D,$32,$51,$33,$8D,$2C,$2E; $4EC8  たた゛それた゛けさ = ただそれだけさ
    db $99                         ; $4ED1  ！
    db $F7                         ; $4ED2  clear page
    db $F0                         ; $4ED3  end of message


; --------------------------------------------------------------------------
; Message #46 ($4ED4)
;   おう「おお　〈テリー〉よ！
;   よくぞ　[0D]クラスを　かちぬいた！
;   おう「こんごは　[0C]クラスいじょうを
;   うけることを　ゆるそう！
;   おう「、、と　いいたいところなのだが
;   じつは　〈テリー〉よ。
;   おう「ちからといかりのへやの　たびの
;   とびらのようすが　おかしいのだ。
;   おう「おそろしい　かずの　まものが
;   しゅつげん　しておるらしい！！
;   おう「これは　しゅさいこくとして
;   みすごせぬ　もんだいだ。
;   おう「ただちに　ちからといかりの
;   へやに　おもむいてくれぬか？
;   おう「わしは　いそがしいので
;   これで　しつれいするが、
;   おう「この　いへんの　げんいんを
;   どうか　つきとめてほしい！
;   おう「よろしくたのんだぞ　〈テリー〉！
;   ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank69_Msg46:                              ; $4ED4  (file $114ED4)
    db $EA                         ; $4ED4  ▶ new page
    db $28,$26                     ; $4ED5  おう  (speaker: おう)
    db $96                         ; $4ED7  end name/box tag
    db $28,$28                     ; $4ED8  おお
    db $90                         ; $4EDA  　(space)
    db $F6                         ; $4EDB  «insert hero name»
    db $4C                         ; $4EDC  よ
    db $99                         ; $4EDD  ！
    db $EF,$EE                     ; $4EDE  newline
    db $90,$90                     ; $4EE0  　　(indent)
    db $4C,$2B,$32,$8D             ; $4EE2  よくそ゛ = よくぞ
    db $90                         ; $4EE6  　(space)
    db $0D                         ; $4EE7  ctrl $0D
    db $62,$85,$67,$54             ; $4EE8  クラスを
    db $90                         ; $4EEC  　(space)
    db $29,$34,$3B,$25,$33         ; $4EED  かちぬいた
    db $99                         ; $4EF2  ！
    db $FA                         ; $4EF3  wait-for-button
    db $F7                         ; $4EF4  clear page
    db $EF,$EE                     ; $4EF5  newline
    db $28,$26                     ; $4EF7  おう  (speaker: おう)
    db $96                         ; $4EF9  end name/box tag
    db $2D,$55,$2D,$8D,$3E         ; $4EFA  こんこ゛は = こんごは
    db $90                         ; $4EFF  　(space)
    db $0C                         ; $4F00  ctrl $0C
    db $62,$85,$67,$25,$2F,$8D,$4D,$26,$54; $4F01  クラスいし゛ょうを = クラスいじょうを
    db $EF,$EE                     ; $4F0A  newline
    db $90,$90                     ; $4F0C  　　(indent)
    db $26,$2C,$50,$2D,$38,$54     ; $4F0E  うけることを
    db $90                         ; $4F14  　(space)
    db $4A,$50,$32,$26             ; $4F15  ゆるそう
    db $99                         ; $4F19  ！
    db $FA                         ; $4F1A  wait-for-button
    db $F7                         ; $4F1B  clear page
    db $EF,$EE                     ; $4F1C  newline
    db $28,$26                     ; $4F1E  おう  (speaker: おう)
    db $96                         ; $4F20  end name/box tag
    db $A4                         ; $4F21  、
    db $A4                         ; $4F22  、
    db $38                         ; $4F23  と
    db $90                         ; $4F24  　(space)
    db $25,$25,$33,$25,$38,$2D,$52,$39,$3D,$33,$8D,$29,$8D; $4F25  いいたいところなのた゛か゛ = いいたいところなのだが
    db $EF,$EE                     ; $4F32  newline
    db $90,$90                     ; $4F34  　　(indent)
    db $2F,$8D,$35,$3E             ; $4F36  し゛つは = じつは
    db $90                         ; $4F3A  　(space)
    db $F6                         ; $4F3B  «insert hero name»
    db $4C                         ; $4F3C  よ
    db $8F                         ; $4F3D  。
    db $FA                         ; $4F3E  wait-for-button
    db $F7                         ; $4F3F  clear page
    db $EF,$EE                     ; $4F40  newline
    db $28,$26                     ; $4F42  おう  (speaker: おう)
    db $96                         ; $4F44  end name/box tag
    db $34,$29,$4E,$38,$25,$29,$4F,$3D,$41,$48,$3D; $4F45  ちからといかりのへやの
    db $90                         ; $4F50  　(space)
    db $33,$3F,$8D,$3D             ; $4F51  たひ゛の = たびの
    db $EF,$EE                     ; $4F55  newline
    db $90,$90                     ; $4F57  　　(indent)
    db $38,$3F,$8D,$4E,$3D,$4C,$26,$30,$29,$8D; $4F59  とひ゛らのようすか゛ = とびらのようすが
    db $90                         ; $4F63  　(space)
    db $28,$29,$2F,$25,$3D,$33,$8D ; $4F64  おかしいのた゛ = おかしいのだ
    db $8F                         ; $4F6B  。
    db $FA                         ; $4F6C  wait-for-button
    db $F7                         ; $4F6D  clear page
    db $EF,$EE                     ; $4F6E  newline
    db $28,$26                     ; $4F70  おう  (speaker: おう)
    db $96                         ; $4F72  end name/box tag
    db $28,$32,$52,$2F,$25         ; $4F73  おそろしい
    db $90                         ; $4F78  　(space)
    db $29,$30,$8D,$3D             ; $4F79  かす゛の = かずの
    db $90                         ; $4F7D  　(space)
    db $43,$47,$3D,$29,$8D         ; $4F7E  まものか゛ = まものが
    db $EF,$EE                     ; $4F83  newline
    db $90,$90                     ; $4F85  　　(indent)
    db $2F,$4B,$35,$2C,$8D,$55     ; $4F87  しゅつけ゛ん = しゅつげん
    db $90                         ; $4F8D  　(space)
    db $2F,$37,$28,$50,$4E,$2F,$25 ; $4F8E  しておるらしい
    db $99                         ; $4F95  ！
    db $99                         ; $4F96  ！
    db $FA                         ; $4F97  wait-for-button
    db $F7                         ; $4F98  clear page
    db $EF,$EE                     ; $4F99  newline
    db $28,$26                     ; $4F9B  おう  (speaker: おう)
    db $96                         ; $4F9D  end name/box tag
    db $2D,$51,$3E                 ; $4F9E  これは
    db $90                         ; $4FA1  　(space)
    db $2F,$4B,$2E,$25,$2D,$2B,$38,$2F,$37; $4FA2  しゅさいこくとして
    db $EF,$EE                     ; $4FAB  newline
    db $90,$90                     ; $4FAD  　　(indent)
    db $44,$30,$2D,$8D,$31,$3B     ; $4FAF  みすこ゛せぬ = みすごせぬ
    db $90                         ; $4FB5  　(space)
    db $47,$55,$33,$8D,$25,$33,$8D ; $4FB6  もんた゛いた゛ = もんだいだ
    db $8F                         ; $4FBD  。
    db $FA                         ; $4FBE  wait-for-button
    db $F7                         ; $4FBF  clear page
    db $EF,$EE                     ; $4FC0  newline
    db $28,$26                     ; $4FC2  おう  (speaker: おう)
    db $96                         ; $4FC4  end name/box tag
    db $33,$33,$8D,$34,$3A         ; $4FC5  たた゛ちに = ただちに
    db $90                         ; $4FCA  　(space)
    db $34,$29,$4E,$38,$25,$29,$4F,$3D; $4FCB  ちからといかりの
    db $EF,$EE                     ; $4FD3  newline
    db $90,$90                     ; $4FD5  　　(indent)
    db $41,$48,$3A                 ; $4FD7  へやに
    db $90                         ; $4FDA  　(space)
    db $28,$47,$45,$25,$37,$2B,$51,$3B,$29; $4FDB  おもむいてくれぬか
    db $98                         ; $4FE4  ？
    db $FA                         ; $4FE5  wait-for-button
    db $F7                         ; $4FE6  clear page
    db $EF,$EE                     ; $4FE7  newline
    db $28,$26                     ; $4FE9  おう  (speaker: おう)
    db $96                         ; $4FEB  end name/box tag
    db $53,$2F,$3E                 ; $4FEC  わしは
    db $90                         ; $4FEF  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $4FF0  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $4FF9  newline
    db $90,$90                     ; $4FFB  　　(indent)
    db $2D,$51,$37,$8D             ; $4FFD  これて゛ = これで
    db $90                         ; $5001  　(space)
    db $2F,$35,$51,$25,$30,$50,$29,$8D; $5002  しつれいするか゛ = しつれいするが
    db $A4                         ; $500A  、
    db $FA                         ; $500B  wait-for-button
    db $F7                         ; $500C  clear page
    db $EF,$EE                     ; $500D  newline
    db $28,$26                     ; $500F  おう  (speaker: おう)
    db $96                         ; $5011  end name/box tag
    db $2D,$3D                     ; $5012  この
    db $90                         ; $5014  　(space)
    db $25,$41,$55,$3D             ; $5015  いへんの
    db $90                         ; $5019  　(space)
    db $2C,$8D,$55,$25,$55,$54     ; $501A  け゛んいんを = げんいんを
    db $EF,$EE                     ; $5020  newline
    db $90,$90                     ; $5022  　　(indent)
    db $38,$8D,$26,$29             ; $5024  と゛うか = どうか
    db $90                         ; $5028  　(space)
    db $35,$2A,$38,$46,$37,$42,$2F,$25; $5029  つきとめてほしい
    db $99                         ; $5031  ！
    db $FA                         ; $5032  wait-for-button
    db $F7                         ; $5033  clear page
    db $EF,$EE                     ; $5034  newline
    db $28,$26                     ; $5036  おう  (speaker: おう)
    db $96                         ; $5038  end name/box tag
    db $4C,$52,$2F,$2B,$33,$3D,$55,$33,$8D,$32,$8D; $5039  よろしくたのんた゛そ゛ = よろしくたのんだぞ
    db $90                         ; $5044  　(space)
    db $F6                         ; $5045  «insert hero name»
    db $99                         ; $5046  ！
    db $EF,$EE                     ; $5047  newline
    db $90,$90                     ; $5049  　　(indent)
    db $58,$69                     ; $504B  ィソ
    db $90                         ; $504D  　(space)
    db $58,$69                     ; $504E  ィソ
    db $A4                         ; $5050  、
    db $90                         ; $5051  　(space)
    db $58,$69                     ; $5052  ィソ
    db $90                         ; $5054  　(space)
    db $58,$69                     ; $5055  ィソ
    db $A4                         ; $5057  、
    db $A4                         ; $5058  、
    db $8F                         ; $5059  。
    db $F7                         ; $505A  clear page
    db $F0                         ; $505B  end of message


; --------------------------------------------------------------------------
; Message #47 ($505C)
;   「いかりのとびらの　ようすが
;   おかしいのだ！
;   「おそろしい　かずの　まものが
;   しゅつげんしている　らしい。
;   「ただちに　この　いへんの
;   げんいんを　つきとめてくれ！
;   「いかりのとびらは
;   たびのとびらのまに　あるぞ！
; --------------------------------------------------------------------------
Bank69_Msg47:                              ; $505C  (file $11505C)
    db $EA                         ; $505C  ▶ new page
    db $9F                         ; $505D  box tag
    db $96                         ; $505E  end name/box tag
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3D; $505F  いかりのとひ゛らの = いかりのとびらの
    db $90                         ; $5068  　(space)
    db $4C,$26,$30,$29,$8D         ; $5069  ようすか゛ = ようすが
    db $EF,$EE                     ; $506E  newline
    db $90,$90                     ; $5070  　　(indent)
    db $28,$29,$2F,$25,$3D,$33,$8D ; $5072  おかしいのた゛ = おかしいのだ
    db $99                         ; $5079  ！
    db $FA                         ; $507A  wait-for-button
    db $F7                         ; $507B  clear page
    db $EF,$EE                     ; $507C  newline
    db $9F                         ; $507E  box tag
    db $96                         ; $507F  end name/box tag
    db $28,$32,$52,$2F,$25         ; $5080  おそろしい
    db $90                         ; $5085  　(space)
    db $29,$30,$8D,$3D             ; $5086  かす゛の = かずの
    db $90                         ; $508A  　(space)
    db $43,$47,$3D,$29,$8D         ; $508B  まものか゛ = まものが
    db $EF,$EE                     ; $5090  newline
    db $90,$90                     ; $5092  　　(indent)
    db $2F,$4B,$35,$2C,$8D,$55,$2F,$37,$25,$50; $5094  しゅつけ゛んしている = しゅつげんしている
    db $90                         ; $509E  　(space)
    db $4E,$2F,$25                 ; $509F  らしい
    db $8F                         ; $50A2  。
    db $FA                         ; $50A3  wait-for-button
    db $F7                         ; $50A4  clear page
    db $EF,$EE                     ; $50A5  newline
    db $9F                         ; $50A7  box tag
    db $96                         ; $50A8  end name/box tag
    db $33,$33,$8D,$34,$3A         ; $50A9  たた゛ちに = ただちに
    db $90                         ; $50AE  　(space)
    db $2D,$3D                     ; $50AF  この
    db $90                         ; $50B1  　(space)
    db $25,$41,$55,$3D             ; $50B2  いへんの
    db $EF,$EE                     ; $50B6  newline
    db $90,$90                     ; $50B8  　　(indent)
    db $2C,$8D,$55,$25,$55,$54     ; $50BA  け゛んいんを = げんいんを
    db $90                         ; $50C0  　(space)
    db $35,$2A,$38,$46,$37,$2B,$51 ; $50C1  つきとめてくれ
    db $99                         ; $50C8  ！
    db $FA                         ; $50C9  wait-for-button
    db $F7                         ; $50CA  clear page
    db $EF,$EE                     ; $50CB  newline
    db $9F                         ; $50CD  box tag
    db $96                         ; $50CE  end name/box tag
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3E; $50CF  いかりのとひ゛らは = いかりのとびらは
    db $EF,$EE                     ; $50D8  newline
    db $90,$90                     ; $50DA  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$3A; $50DC  たひ゛のとひ゛らのまに = たびのとびらのまに
    db $90                         ; $50E7  　(space)
    db $24,$50,$32,$8D             ; $50E8  あるそ゛ = あるぞ
    db $99                         ; $50EC  ！
    db $F7                         ; $50ED  clear page
    db $F0                         ; $50EE  end of message


; --------------------------------------------------------------------------
; Message #48 ($50EF)
;   「まものの　かずが　ふえている、。
;   どういうことでしょうか！？
; --------------------------------------------------------------------------
Bank69_Msg48:                              ; $50EF  (file $1150EF)
    db $EB                         ; $50EF  ▶ new page
    db $9F                         ; $50F0  box tag
    db $96                         ; $50F1  end name/box tag
    db $43,$47,$3D,$3D             ; $50F2  まものの
    db $90                         ; $50F6  　(space)
    db $29,$30,$8D,$29,$8D         ; $50F7  かす゛か゛ = かずが
    db $90                         ; $50FC  　(space)
    db $40,$27,$37,$25,$50         ; $50FD  ふえている
    db $A4                         ; $5102  、
    db $8F                         ; $5103  。
    db $EF,$EE                     ; $5104  newline
    db $90,$90                     ; $5106  　　(indent)
    db $38,$8D,$26,$25,$26,$2D,$38,$37,$8D,$2F,$4D,$26,$29; $5108  と゛ういうことて゛しょうか = どういうことでしょうか
    db $99                         ; $5115  ！
    db $98                         ; $5116  ？
    db $F7                         ; $5117  clear page
    db $F0                         ; $5118  end of message


; --------------------------------------------------------------------------
; Message #49 ($5119)
;   おう「〈テリー〉！　ほかの　たびの
;   とびらへゆくのも　よいが、
;   おう「はよう　いかりのとびらの
;   いへんを　おさめてきてくれ！！
;   おう「、といいつつ　わしは
;   いそがしいので　しつれいする。
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank69_Msg49:                              ; $5119  (file $115119)
    db $EA                         ; $5119  ▶ new page
    db $28,$26                     ; $511A  おう  (speaker: おう)
    db $96                         ; $511C  end name/box tag
    db $F6                         ; $511D  «insert hero name»
    db $99                         ; $511E  ！
    db $90                         ; $511F  　(space)
    db $42,$29,$3D                 ; $5120  ほかの
    db $90                         ; $5123  　(space)
    db $33,$3F,$8D,$3D             ; $5124  たひ゛の = たびの
    db $EF,$EE                     ; $5128  newline
    db $90,$90                     ; $512A  　　(indent)
    db $38,$3F,$8D,$4E,$41,$4A,$2B,$3D,$47; $512C  とひ゛らへゆくのも = とびらへゆくのも
    db $90                         ; $5135  　(space)
    db $4C,$25,$29,$8D             ; $5136  よいか゛ = よいが
    db $A4                         ; $513A  、
    db $FA                         ; $513B  wait-for-button
    db $F7                         ; $513C  clear page
    db $EF,$EE                     ; $513D  newline
    db $28,$26                     ; $513F  おう  (speaker: おう)
    db $96                         ; $5141  end name/box tag
    db $3E,$4C,$26                 ; $5142  はよう
    db $90                         ; $5145  　(space)
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3D; $5146  いかりのとひ゛らの = いかりのとびらの
    db $EF,$EE                     ; $514F  newline
    db $90,$90                     ; $5151  　　(indent)
    db $25,$41,$55,$54             ; $5153  いへんを
    db $90                         ; $5157  　(space)
    db $28,$2E,$46,$37,$2A,$37,$2B,$51; $5158  おさめてきてくれ
    db $99                         ; $5160  ！
    db $99                         ; $5161  ！
    db $FA                         ; $5162  wait-for-button
    db $F7                         ; $5163  clear page
    db $EF,$EE                     ; $5164  newline
    db $28,$26                     ; $5166  おう  (speaker: おう)
    db $96                         ; $5168  end name/box tag
    db $A4                         ; $5169  、
    db $38,$25,$25,$35,$35         ; $516A  といいつつ
    db $90                         ; $516F  　(space)
    db $53,$2F,$3E                 ; $5170  わしは
    db $EF,$EE                     ; $5173  newline
    db $90,$90                     ; $5175  　　(indent)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $5177  いそか゛しいのて゛ = いそがしいので
    db $90                         ; $5180  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $5181  しつれいする
    db $8F                         ; $5187  。
    db $FA                         ; $5188  wait-for-button
    db $F7                         ; $5189  clear page
    db $EF,$EE                     ; $518A  newline
    db $28,$26                     ; $518C  おう  (speaker: おう)
    db $96                         ; $518E  end name/box tag
    db $58,$69                     ; $518F  ィソ
    db $90                         ; $5191  　(space)
    db $58,$69                     ; $5192  ィソ
    db $A4                         ; $5194  、
    db $90                         ; $5195  　(space)
    db $58,$69                     ; $5196  ィソ
    db $90                         ; $5198  　(space)
    db $58,$69                     ; $5199  ィソ
    db $A4                         ; $519B  、
    db $A4                         ; $519C  、
    db $8F                         ; $519D  。
    db $EF,$EE                     ; $519E  newline
    db $F7                         ; $51A0  clear page
    db $F0                         ; $51A1  end of message


; --------------------------------------------------------------------------
; Message #50 ($51A2)
;   〈テリー〉は　ほんだなを　しらべた。
;   「まぼろしの　あのひとを　おって、。
;   、　、　、　、　、　、　、。
;   かんどうの　ものがたりだった！
; --------------------------------------------------------------------------
Bank69_Msg50:                              ; $51A2  (file $1151A2)
    db $F6                         ; $51A2  «insert hero name»
    db $3E                         ; $51A3  は
    db $90                         ; $51A4  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $51A5  ほんた゛なを = ほんだなを
    db $90                         ; $51AB  　(space)
    db $2F,$4E,$41,$8D,$33         ; $51AC  しらへ゛た = しらべた
    db $8F                         ; $51B1  。
    db $EF,$EE                     ; $51B2  newline
    db $FA                         ; $51B4  wait-for-button
    db $F7                         ; $51B5  clear page
    db $EF,$EE                     ; $51B6  newline
    db $F3                         ; $51B8  open text box
    db $96                         ; $51B9  end name/box tag
    db $43,$42,$8D,$52,$2F,$3D     ; $51BA  まほ゛ろしの = まぼろしの
    db $90                         ; $51C0  　(space)
    db $24,$3D,$3F,$38,$54         ; $51C1  あのひとを
    db $90                         ; $51C6  　(space)
    db $28,$36,$37                 ; $51C7  おって
    db $A4                         ; $51CA  、
    db $8F                         ; $51CB  。
    db $EF,$EE                     ; $51CC  newline
    db $FA                         ; $51CE  wait-for-button
    db $F7                         ; $51CF  clear page
    db $EF,$EE                     ; $51D0  newline
    db $F3                         ; $51D2  open text box
    db $90                         ; $51D3  　(space)
    db $A4                         ; $51D4  、
    db $90                         ; $51D5  　(space)
    db $A4                         ; $51D6  、
    db $90                         ; $51D7  　(space)
    db $A4                         ; $51D8  、
    db $90                         ; $51D9  　(space)
    db $A4                         ; $51DA  、
    db $90                         ; $51DB  　(space)
    db $A4                         ; $51DC  、
    db $90                         ; $51DD  　(space)
    db $A4                         ; $51DE  、
    db $90                         ; $51DF  　(space)
    db $A4                         ; $51E0  、
    db $8F                         ; $51E1  。
    db $EF,$EE                     ; $51E2  newline
    db $FA                         ; $51E4  wait-for-button
    db $F7                         ; $51E5  clear page
    db $EF,$EE                     ; $51E6  newline
    db $F3                         ; $51E8  open text box
    db $29,$55,$38,$8D,$26,$3D     ; $51E9  かんと゛うの = かんどうの
    db $90                         ; $51EF  　(space)
    db $47,$3D,$29,$8D,$33,$4F,$33,$8D,$36,$33; $51F0  ものか゛たりた゛った = ものがたりだった
    db $99                         ; $51FA  ！
    db $EF,$EE                     ; $51FB  newline
    db $F7                         ; $51FD  clear page
    db $F0                         ; $51FE  end of message


; --------------------------------------------------------------------------
; Message #51 ($51FF)
;   「ミッキーに　かったんだって？
;   おまえ　いいきに　なってるだろ！
;   「あんな　よわいやつに　かったって
;   じまんに　ならないんだよー！
; --------------------------------------------------------------------------
Bank69_Msg51:                              ; $51FF  (file $1151FF)
    db $EB                         ; $51FF  ▶ new page
    db $9F                         ; $5200  box tag
    db $96                         ; $5201  end name/box tag
    db $7B,$6D,$61,$9C,$3A         ; $5202  ミッキーに
    db $90                         ; $5207  　(space)
    db $29,$36,$33,$55,$33,$8D,$36,$37; $5208  かったんた゛って = かったんだって
    db $98                         ; $5210  ？
    db $EF,$EE                     ; $5211  newline
    db $90,$90                     ; $5213  　　(indent)
    db $28,$43,$27                 ; $5215  おまえ
    db $90                         ; $5218  　(space)
    db $25,$25,$2A,$3A             ; $5219  いいきに
    db $90                         ; $521D  　(space)
    db $39,$36,$37,$50,$33,$8D,$52 ; $521E  なってるた゛ろ = なってるだろ
    db $99                         ; $5225  ！
    db $FA                         ; $5226  wait-for-button
    db $F7                         ; $5227  clear page
    db $EF,$EE                     ; $5228  newline
    db $9F                         ; $522A  box tag
    db $96                         ; $522B  end name/box tag
    db $24,$55,$39                 ; $522C  あんな
    db $90                         ; $522F  　(space)
    db $4C,$53,$25,$48,$35,$3A     ; $5230  よわいやつに
    db $90                         ; $5236  　(space)
    db $29,$36,$33,$36,$37         ; $5237  かったって
    db $EF,$EE                     ; $523C  newline
    db $90,$90                     ; $523E  　　(indent)
    db $2F,$8D,$43,$55,$3A         ; $5240  し゛まんに = じまんに
    db $90                         ; $5245  　(space)
    db $39,$4E,$39,$25,$55,$33,$8D,$4C,$9C; $5246  ならないんた゛よー = ならないんだよー
    db $99                         ; $524F  ！
    db $F7                         ; $5250  clear page
    db $F0                         ; $5251  end of message


; --------------------------------------------------------------------------
; Message #52 ($5252)
;   「ちからといかりのへやは
;   まんなかです。　おいそぎを！
; --------------------------------------------------------------------------
Bank69_Msg52:                              ; $5252  (file $115252)
    db $EA                         ; $5252  ▶ new page
    db $9F                         ; $5253  box tag
    db $96                         ; $5254  end name/box tag
    db $34,$29,$4E,$38,$25,$29,$4F,$3D,$41,$48,$3E; $5255  ちからといかりのへやは
    db $EF,$EE                     ; $5260  newline
    db $90,$90                     ; $5262  　　(indent)
    db $43,$55,$39,$29,$37,$8D,$30 ; $5264  まんなかて゛す = まんなかです
    db $8F                         ; $526B  。
    db $90                         ; $526C  　(space)
    db $28,$25,$32,$2A,$8D,$54     ; $526D  おいそき゛を = おいそぎを
    db $99                         ; $5273  ！
    db $F7                         ; $5274  clear page
    db $F0                         ; $5275  end of message


; --------------------------------------------------------------------------
; Message #53 ($5276)
;   「ここは　たびのとびらのまですっ。
;   「ちからといかりのへやは
;   この　となりですぞ！
; --------------------------------------------------------------------------
Bank69_Msg53:                              ; $5276  (file $115276)
    db $EA                         ; $5276  ▶ new page
    db $9F                         ; $5277  box tag
    db $96                         ; $5278  end name/box tag
    db $2D,$2D,$3E                 ; $5279  ここは
    db $90                         ; $527C  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$37,$8D,$30,$36; $527D  たひ゛のとひ゛らのまて゛すっ = たびのとびらのまですっ
    db $8F                         ; $528B  。
    db $EF,$EE                     ; $528C  newline
    db $FA                         ; $528E  wait-for-button
    db $F7                         ; $528F  clear page
    db $EF,$EE                     ; $5290  newline
    db $F3                         ; $5292  open text box
    db $9F                         ; $5293  box tag
    db $96                         ; $5294  end name/box tag
    db $34,$29,$4E,$38,$25,$29,$4F,$3D,$41,$48,$3E; $5295  ちからといかりのへやは
    db $EF,$EE                     ; $52A0  newline
    db $90,$90                     ; $52A2  　　(indent)
    db $2D,$3D                     ; $52A4  この
    db $90                         ; $52A6  　(space)
    db $38,$39,$4F,$37,$8D,$30,$32,$8D; $52A7  となりて゛すそ゛ = となりですぞ
    db $99                         ; $52AF  ！
    db $F7                         ; $52B0  clear page
    db $F0                         ; $52B1  end of message


; --------------------------------------------------------------------------
; Message #54 ($52B2)
;   「バトルレックスさんって
;   まじんぎりを　つかうんだ。
;   「それから　メタルぎりも
;   つかえるんだよ！
;   「よく　おこりだす　まものだけど
;   いまも　おこっているのかな[91]、。
; --------------------------------------------------------------------------
Bank69_Msg54:                              ; $52B2  (file $1152B2)
    db $EB                         ; $52B2  ▶ new page
    db $9F                         ; $52B3  box tag
    db $96                         ; $52B4  end name/box tag
    db $75,$8D,$6F,$87,$88,$6D,$62,$67,$2E,$55,$36,$37; $52B5  ハ゛トルレックスさんって = バトルレックスさんって
    db $EF,$EE                     ; $52C1  newline
    db $90,$90                     ; $52C3  　　(indent)
    db $43,$2F,$8D,$55,$2A,$8D,$4F,$54; $52C5  まし゛んき゛りを = まじんぎりを
    db $90                         ; $52CD  　(space)
    db $35,$29,$26,$55,$33,$8D     ; $52CE  つかうんた゛ = つかうんだ
    db $8F                         ; $52D4  。
    db $FA                         ; $52D5  wait-for-button
    db $F7                         ; $52D6  clear page
    db $EF,$EE                     ; $52D7  newline
    db $9F                         ; $52D9  box tag
    db $96                         ; $52DA  end name/box tag
    db $32,$51,$29,$4E             ; $52DB  それから
    db $90                         ; $52DF  　(space)
    db $7D,$6A,$87,$2A,$8D,$4F,$47 ; $52E0  メタルき゛りも = メタルぎりも
    db $EF,$EE                     ; $52E7  newline
    db $90,$90                     ; $52E9  　　(indent)
    db $35,$29,$27,$50,$55,$33,$8D,$4C; $52EB  つかえるんた゛よ = つかえるんだよ
    db $99                         ; $52F3  ！
    db $FA                         ; $52F4  wait-for-button
    db $F7                         ; $52F5  clear page
    db $EF,$EE                     ; $52F6  newline
    db $9F                         ; $52F8  box tag
    db $96                         ; $52F9  end name/box tag
    db $4C,$2B                     ; $52FA  よく
    db $90                         ; $52FC  　(space)
    db $28,$2D,$4F,$33,$8D,$30     ; $52FD  おこりた゛す = おこりだす
    db $90                         ; $5303  　(space)
    db $43,$47,$3D,$33,$8D,$2C,$38,$8D; $5304  まものた゛けと゛ = まものだけど
    db $EF,$EE                     ; $530C  newline
    db $90,$90                     ; $530E  　　(indent)
    db $25,$43,$47                 ; $5310  いまも
    db $90                         ; $5313  　(space)
    db $28,$2D,$36,$37,$25,$50,$3D,$29,$39; $5314  おこっているのかな
    db $91                         ; $531D  ctrl $91
    db $A4                         ; $531E  、
    db $8F                         ; $531F  。
    db $F7                         ; $5320  clear page
    db $F0                         ; $5321  end of message


; --------------------------------------------------------------------------
; Message #55 ($5322)
;   「ちからのとびらには　ヘンな
;   せきぞうが　あるのよ！
; --------------------------------------------------------------------------
Bank69_Msg55:                              ; $5322  (file $115322)
    db $EB                         ; $5322  ▶ new page
    db $9F                         ; $5323  box tag
    db $96                         ; $5324  end name/box tag
    db $34,$29,$4E,$3D,$38,$3F,$8D,$4E,$3A,$3E; $5325  ちからのとひ゛らには = ちからのとびらには
    db $90                         ; $532F  　(space)
    db $78,$8C,$39                 ; $5330  ヘンな
    db $EF,$EE                     ; $5333  newline
    db $90,$90                     ; $5335  　　(indent)
    db $31,$2A,$32,$8D,$26,$29,$8D ; $5337  せきそ゛うか゛ = せきぞうが
    db $90                         ; $533E  　(space)
    db $24,$50,$3D,$4C             ; $533F  あるのよ
    db $99                         ; $5343  ！
    db $F7                         ; $5344  clear page
    db $F0                         ; $5345  end of message


; --------------------------------------------------------------------------
; Message #56 ($5346)
;   「たびのとびらのまの　ちからと
;   いかりのへやに　いくんじゃ！
;   「それまで　しあいは　うけさせん！
;   おうさまに　たのまれたんじゃろ？
;   「あんた　きたいされておるのう。
;   がんばって　それにこたえねば！
; --------------------------------------------------------------------------
Bank69_Msg56:                              ; $5346  (file $115346)
    db $EA                         ; $5346  ▶ new page
    db $9F                         ; $5347  box tag
    db $96                         ; $5348  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$3D; $5349  たひ゛のとひ゛らのまの = たびのとびらのまの
    db $90                         ; $5354  　(space)
    db $34,$29,$4E,$38             ; $5355  ちからと
    db $EF,$EE                     ; $5359  newline
    db $90,$90                     ; $535B  　　(indent)
    db $25,$29,$4F,$3D,$41,$48,$3A ; $535D  いかりのへやに
    db $90                         ; $5364  　(space)
    db $25,$2B,$55,$2F,$8D,$49     ; $5365  いくんし゛ゃ = いくんじゃ
    db $99                         ; $536B  ！
    db $FA                         ; $536C  wait-for-button
    db $F7                         ; $536D  clear page
    db $EF,$EE                     ; $536E  newline
    db $9F                         ; $5370  box tag
    db $96                         ; $5371  end name/box tag
    db $32,$51,$43,$37,$8D         ; $5372  それまて゛ = それまで
    db $90                         ; $5377  　(space)
    db $2F,$24,$25,$3E             ; $5378  しあいは
    db $90                         ; $537C  　(space)
    db $26,$2C,$2E,$31,$55         ; $537D  うけさせん
    db $99                         ; $5382  ！
    db $EF,$EE                     ; $5383  newline
    db $90,$90                     ; $5385  　　(indent)
    db $28,$26,$2E,$43,$3A         ; $5387  おうさまに
    db $90                         ; $538C  　(space)
    db $33,$3D,$43,$51,$33,$55,$2F,$8D,$49,$52; $538D  たのまれたんし゛ゃろ = たのまれたんじゃろ
    db $98                         ; $5397  ？
    db $FA                         ; $5398  wait-for-button
    db $F7                         ; $5399  clear page
    db $EF,$EE                     ; $539A  newline
    db $9F                         ; $539C  box tag
    db $96                         ; $539D  end name/box tag
    db $24,$55,$33                 ; $539E  あんた
    db $90                         ; $53A1  　(space)
    db $2A,$33,$25,$2E,$51,$37,$28,$50,$3D,$26; $53A2  きたいされておるのう
    db $8F                         ; $53AC  。
    db $EF,$EE                     ; $53AD  newline
    db $90,$90                     ; $53AF  　　(indent)
    db $29,$8D,$55,$3E,$8D,$36,$37 ; $53B1  か゛んは゛って = がんばって
    db $90                         ; $53B8  　(space)
    db $32,$51,$3A,$2D,$33,$27,$3C,$3E,$8D; $53B9  それにこたえねは゛ = それにこたえねば
    db $99                         ; $53C2  ！
    db $F7                         ; $53C3  clear page
    db $F0                         ; $53C4  end of message


; --------------------------------------------------------------------------
; Message #57 ($53C5)
;   「いかりのとびらの　いへんを
;   かいけつ　できるまでは、
;   「しあいの　もうしこみは
;   お[9B]あ[9B]ず[9B]け[9B]よ！
; --------------------------------------------------------------------------
Bank69_Msg57:                              ; $53C5  (file $1153C5)
    db $EB                         ; $53C5  ▶ new page
    db $9F                         ; $53C6  box tag
    db $96                         ; $53C7  end name/box tag
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3D; $53C8  いかりのとひ゛らの = いかりのとびらの
    db $90                         ; $53D1  　(space)
    db $25,$41,$55,$54             ; $53D2  いへんを
    db $EF,$EE                     ; $53D6  newline
    db $90,$90                     ; $53D8  　　(indent)
    db $29,$25,$2C,$35             ; $53DA  かいけつ
    db $90                         ; $53DE  　(space)
    db $37,$8D,$2A,$50,$43,$37,$8D,$3E; $53DF  て゛きるまて゛は = できるまでは
    db $A4                         ; $53E7  、
    db $FA                         ; $53E8  wait-for-button
    db $F7                         ; $53E9  clear page
    db $EF,$EE                     ; $53EA  newline
    db $9F                         ; $53EC  box tag
    db $96                         ; $53ED  end name/box tag
    db $2F,$24,$25,$3D             ; $53EE  しあいの
    db $90                         ; $53F2  　(space)
    db $47,$26,$2F,$2D,$44,$3E     ; $53F3  もうしこみは
    db $EF,$EE                     ; $53F9  newline
    db $90,$90                     ; $53FB  　　(indent)
    db $28                         ; $53FD  お
    db $9B                         ; $53FE  ctrl $9B
    db $24                         ; $53FF  あ
    db $9B                         ; $5400  ctrl $9B
    db $30,$8D                     ; $5401  す゛ = ず
    db $9B                         ; $5403  ctrl $9B
    db $2C                         ; $5404  け
    db $9B                         ; $5405  ctrl $9B
    db $4C                         ; $5406  よ
    db $99                         ; $5407  ！
    db $F7                         ; $5408  clear page
    db $F0                         ; $5409  end of message


; --------------------------------------------------------------------------
; Message #58 ($540A)
;   「ぼくじょうに　あずけていても
;   とくぎは　おぼえないんですね、。
;   「〈テリー〉くん！
;   [0D]クラスを　かちぬいたんだね！！
;   「こうしちゃ　いられない。
;   わたしも　がんばるぞ！
; --------------------------------------------------------------------------
Bank69_Msg58:                              ; $540A  (file $11540A)
    db $EA                         ; $540A  ▶ new page
    db $9F                         ; $540B  box tag
    db $96                         ; $540C  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3A; $540D  ほ゛くし゛ょうに = ぼくじょうに
    db $90                         ; $5415  　(space)
    db $24,$30,$8D,$2C,$37,$25,$37,$47; $5416  あす゛けていても = あずけていても
    db $EF,$EE                     ; $541E  newline
    db $90,$90                     ; $5420  　　(indent)
    db $38,$2B,$2A,$8D,$3E         ; $5422  とくき゛は = とくぎは
    db $90                         ; $5427  　(space)
    db $28,$42,$8D,$27,$39,$25,$55,$37,$8D,$30,$3C; $5428  おほ゛えないんて゛すね = おぼえないんですね
    db $A4                         ; $5433  、
    db $8F                         ; $5434  。
    db $FA                         ; $5435  wait-for-button
    db $F7                         ; $5436  clear page
    db $EF,$EE                     ; $5437  newline
    db $9F                         ; $5439  box tag
    db $96                         ; $543A  end name/box tag
    db $F6                         ; $543B  «insert hero name»
    db $2B,$55                     ; $543C  くん
    db $99                         ; $543E  ！
    db $EF,$EE                     ; $543F  newline
    db $90,$90                     ; $5441  　　(indent)
    db $0D                         ; $5443  ctrl $0D
    db $62,$85,$67,$54             ; $5444  クラスを
    db $90                         ; $5448  　(space)
    db $29,$34,$3B,$25,$33,$55,$33,$8D,$3C; $5449  かちぬいたんた゛ね = かちぬいたんだね
    db $99                         ; $5452  ！
    db $99                         ; $5453  ！
    db $FA                         ; $5454  wait-for-button
    db $F7                         ; $5455  clear page
    db $EF,$EE                     ; $5456  newline
    db $9F                         ; $5458  box tag
    db $96                         ; $5459  end name/box tag
    db $2D,$26,$2F,$34,$49         ; $545A  こうしちゃ
    db $90                         ; $545F  　(space)
    db $25,$4E,$51,$39,$25         ; $5460  いられない
    db $8F                         ; $5465  。
    db $EF,$EE                     ; $5466  newline
    db $90,$90                     ; $5468  　　(indent)
    db $53,$33,$2F,$47             ; $546A  わたしも
    db $90                         ; $546E  　(space)
    db $29,$8D,$55,$3E,$8D,$50,$32,$8D; $546F  か゛んは゛るそ゛ = がんばるぞ
    db $99                         ; $5477  ！
    db $F7                         ; $5478  clear page
    db $F0                         ; $5479  end of message


; --------------------------------------------------------------------------
; Message #59 ($547A)
;   「、あそこは　あくまけいのまものの
;   おうこくだそうだ。
;   「そこのぬしは　かつて
;   にんげんだったらしいぜ！
;   「ねむりのとびらのことも
;   きいているが　ききたいかい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg59:                              ; $547A  (file $11547A)
    db $EA                         ; $547A  ▶ new page
    db $9F                         ; $547B  box tag
    db $96                         ; $547C  end name/box tag
    db $A4                         ; $547D  、
    db $24,$32,$2D,$3E             ; $547E  あそこは
    db $90                         ; $5482  　(space)
    db $24,$2B,$43,$2C,$25,$3D,$43,$47,$3D,$3D; $5483  あくまけいのまものの
    db $EF,$EE                     ; $548D  newline
    db $90,$90                     ; $548F  　　(indent)
    db $28,$26,$2D,$2B,$33,$8D,$32,$26,$33,$8D; $5491  おうこくた゛そうた゛ = おうこくだそうだ
    db $8F                         ; $549B  。
    db $FA                         ; $549C  wait-for-button
    db $F7                         ; $549D  clear page
    db $EF,$EE                     ; $549E  newline
    db $9F                         ; $54A0  box tag
    db $96                         ; $54A1  end name/box tag
    db $32,$2D,$3D,$3B,$2F,$3E     ; $54A2  そこのぬしは
    db $90                         ; $54A8  　(space)
    db $29,$35,$37                 ; $54A9  かつて
    db $EF,$EE                     ; $54AC  newline
    db $90,$90                     ; $54AE  　　(indent)
    db $3A,$55,$2C,$8D,$55,$33,$8D,$36,$33,$4E,$2F,$25,$31,$8D; $54B0  にんけ゛んた゛ったらしいせ゛ = にんげんだったらしいぜ
    db $99                         ; $54BE  ！
    db $FA                         ; $54BF  wait-for-button
    db $F7                         ; $54C0  clear page
    db $EF,$EE                     ; $54C1  newline
    db $9F                         ; $54C3  box tag
    db $96                         ; $54C4  end name/box tag
    db $3C,$45,$4F,$3D,$38,$3F,$8D,$4E,$3D,$2D,$38,$47; $54C5  ねむりのとひ゛らのことも = ねむりのとびらのことも
    db $EF,$EE                     ; $54D1  newline
    db $90,$90                     ; $54D3  　　(indent)
    db $2A,$25,$37,$25,$50,$29,$8D ; $54D5  きいているか゛ = きいているが
    db $90                         ; $54DC  　(space)
    db $2A,$2A,$33,$25,$29,$25     ; $54DD  ききたいかい
    db $98                         ; $54E3  ？
    db $FF                         ; $54E4  はい/いいえ
    db $F0                         ; $54E5  end of message


; --------------------------------------------------------------------------
; Message #60 ($54E6)
;   「キラースコップ
;   コップを　きらーす。
; --------------------------------------------------------------------------
Bank69_Msg60:                              ; $54E6  (file $1154E6)
    db $EA                         ; $54E6  ▶ new page
    db $9F                         ; $54E7  box tag
    db $96                         ; $54E8  end name/box tag
    db $61,$85,$9C,$67,$64,$6D,$77,$8E; $54E9  キラースコッフ゜ = キラースコップ
    db $EF,$EE                     ; $54F1  newline
    db $90,$90                     ; $54F3  　　(indent)
    db $64,$6D,$77,$8E,$54         ; $54F5  コッフ゜を = コップを
    db $90                         ; $54FA  　(space)
    db $2A,$4E,$9C,$30             ; $54FB  きらーす
    db $8F                         ; $54FF  。
    db $F7                         ; $5500  clear page
    db $F0                         ; $5501  end of message


; --------------------------------------------------------------------------
; Message #61 ($5502)
;   「ミッキーに　かったのか！？
;   やりおるな！　おぬしっ！！
;   「じゃが　ここで　いいきになれば
;   おぬしも　ミッキーとおなじじゃ。
;   「やつが　いま　どんな　ようすだか
;   たずねてきては　どうじゃ？
; --------------------------------------------------------------------------
Bank69_Msg61:                              ; $5502  (file $115502)
    db $EA                         ; $5502  ▶ new page
    db $9F                         ; $5503  box tag
    db $96                         ; $5504  end name/box tag
    db $7B,$6D,$61,$9C,$3A         ; $5505  ミッキーに
    db $90                         ; $550A  　(space)
    db $29,$36,$33,$3D,$29         ; $550B  かったのか
    db $99                         ; $5510  ！
    db $98                         ; $5511  ？
    db $EF,$EE                     ; $5512  newline
    db $90,$90                     ; $5514  　　(indent)
    db $48,$4F,$28,$50,$39         ; $5516  やりおるな
    db $99                         ; $551B  ！
    db $90                         ; $551C  　(space)
    db $28,$3B,$2F,$36             ; $551D  おぬしっ
    db $99                         ; $5521  ！
    db $99                         ; $5522  ！
    db $FA                         ; $5523  wait-for-button
    db $F7                         ; $5524  clear page
    db $EF,$EE                     ; $5525  newline
    db $9F                         ; $5527  box tag
    db $96                         ; $5528  end name/box tag
    db $2F,$8D,$49,$29,$8D         ; $5529  し゛ゃか゛ = じゃが
    db $90                         ; $552E  　(space)
    db $2D,$2D,$37,$8D             ; $552F  ここて゛ = ここで
    db $90                         ; $5533  　(space)
    db $25,$25,$2A,$3A,$39,$51,$3E,$8D; $5534  いいきになれは゛ = いいきになれば
    db $EF,$EE                     ; $553C  newline
    db $90,$90                     ; $553E  　　(indent)
    db $28,$3B,$2F,$47             ; $5540  おぬしも
    db $90                         ; $5544  　(space)
    db $7B,$6D,$61,$9C,$38,$28,$39,$2F,$8D,$2F,$8D,$49; $5545  ミッキーとおなし゛し゛ゃ = ミッキーとおなじじゃ
    db $8F                         ; $5551  。
    db $FA                         ; $5552  wait-for-button
    db $F7                         ; $5553  clear page
    db $EF,$EE                     ; $5554  newline
    db $9F                         ; $5556  box tag
    db $96                         ; $5557  end name/box tag
    db $48,$35,$29,$8D             ; $5558  やつか゛ = やつが
    db $90                         ; $555C  　(space)
    db $25,$43                     ; $555D  いま
    db $90                         ; $555F  　(space)
    db $38,$8D,$55,$39             ; $5560  と゛んな = どんな
    db $90                         ; $5564  　(space)
    db $4C,$26,$30,$33,$8D,$29     ; $5565  ようすた゛か = ようすだか
    db $EF,$EE                     ; $556B  newline
    db $90,$90                     ; $556D  　　(indent)
    db $33,$30,$8D,$3C,$37,$2A,$37,$3E; $556F  たす゛ねてきては = たずねてきては
    db $90                         ; $5577  　(space)
    db $38,$8D,$26,$2F,$8D,$49     ; $5578  と゛うし゛ゃ = どうじゃ
    db $98                         ; $557E  ？
    db $F7                         ; $557F  clear page
    db $F0                         ; $5580  end of message


; --------------------------------------------------------------------------
; Message #62 ($5581)
;   「へへっ！　にいちゃんよ[95]。
;   しあい　させてもらえね[94]のか？
; --------------------------------------------------------------------------
Bank69_Msg62:                              ; $5581  (file $115581)
    db $EA                         ; $5581  ▶ new page
    db $9F                         ; $5582  box tag
    db $96                         ; $5583  end name/box tag
    db $41,$41,$36                 ; $5584  へへっ
    db $99                         ; $5587  ！
    db $90                         ; $5588  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $5589  にいちゃんよ
    db $95                         ; $558F  ctrl $95
    db $8F                         ; $5590  。
    db $EF,$EE                     ; $5591  newline
    db $90,$90                     ; $5593  　　(indent)
    db $2F,$24,$25                 ; $5595  しあい
    db $90                         ; $5598  　(space)
    db $2E,$31,$37,$47,$4E,$27,$3C ; $5599  させてもらえね
    db $94                         ; $55A0  ctrl $94
    db $3D,$29                     ; $55A1  のか
    db $98                         ; $55A3  ？
    db $F7                         ; $55A4  clear page
    db $F0                         ; $55A5  end of message


; --------------------------------------------------------------------------
; Message #63 ($55A6)
;   「、あそこは　ゾンビけいのまものが
;   うじゃうじゃ　いるそうだ！
;   「そこのぬしは　おおむかしから
;   ねむりつづけている　らしいぞ。
; --------------------------------------------------------------------------
Bank69_Msg63:                              ; $55A6  (file $1155A6)
    db $EA                         ; $55A6  ▶ new page
    db $9F                         ; $55A7  box tag
    db $96                         ; $55A8  end name/box tag
    db $A4                         ; $55A9  、
    db $24,$32,$2D,$3E             ; $55AA  あそこは
    db $90                         ; $55AE  　(space)
    db $69,$8D,$8C,$76,$8D,$2C,$25,$3D,$43,$47,$3D,$29,$8D; $55AF  ソ゛ンヒ゛けいのまものか゛ = ゾンビけいのまものが
    db $EF,$EE                     ; $55BC  newline
    db $90,$90                     ; $55BE  　　(indent)
    db $26,$2F,$8D,$49,$26,$2F,$8D,$49; $55C0  うし゛ゃうし゛ゃ = うじゃうじゃ
    db $90                         ; $55C8  　(space)
    db $25,$50,$32,$26,$33,$8D     ; $55C9  いるそうた゛ = いるそうだ
    db $99                         ; $55CF  ！
    db $FA                         ; $55D0  wait-for-button
    db $F7                         ; $55D1  clear page
    db $EF,$EE                     ; $55D2  newline
    db $9F                         ; $55D4  box tag
    db $96                         ; $55D5  end name/box tag
    db $32,$2D,$3D,$3B,$2F,$3E     ; $55D6  そこのぬしは
    db $90                         ; $55DC  　(space)
    db $28,$28,$45,$29,$2F,$29,$4E ; $55DD  おおむかしから
    db $EF,$EE                     ; $55E4  newline
    db $90,$90                     ; $55E6  　　(indent)
    db $3C,$45,$4F,$35,$35,$8D,$2C,$37,$25,$50; $55E8  ねむりつつ゛けている = ねむりつづけている
    db $90                         ; $55F2  　(space)
    db $4E,$2F,$25,$32,$8D         ; $55F3  らしいそ゛ = らしいぞ
    db $8F                         ; $55F8  。
    db $F7                         ; $55F9  clear page
    db $F0                         ; $55FA  end of message


; --------------------------------------------------------------------------
; Message #64 ($55FB)
;   「そうか。
;   ミッキーに　かったのか。
;   「だが　うえには　うえがいることを
;   わすれぬことだ。
;   「こんご　つかまえた　まものだけで
;   たたかうのは　つらくなるだろう。
;   「はいごうを　おおいに　やって
;   つよいまものを　つくるのだな。
; --------------------------------------------------------------------------
Bank69_Msg64:                              ; $55FB  (file $1155FB)
    db $EA                         ; $55FB  ▶ new page
    db $9F                         ; $55FC  box tag
    db $96                         ; $55FD  end name/box tag
    db $32,$26,$29                 ; $55FE  そうか
    db $8F                         ; $5601  。
    db $EF,$EE                     ; $5602  newline
    db $90,$90                     ; $5604  　　(indent)
    db $7B,$6D,$61,$9C,$3A         ; $5606  ミッキーに
    db $90                         ; $560B  　(space)
    db $29,$36,$33,$3D,$29         ; $560C  かったのか
    db $8F                         ; $5611  。
    db $FA                         ; $5612  wait-for-button
    db $F7                         ; $5613  clear page
    db $EF,$EE                     ; $5614  newline
    db $9F                         ; $5616  box tag
    db $96                         ; $5617  end name/box tag
    db $33,$8D,$29,$8D             ; $5618  た゛か゛ = だが
    db $90                         ; $561C  　(space)
    db $26,$27,$3A,$3E             ; $561D  うえには
    db $90                         ; $5621  　(space)
    db $26,$27,$29,$8D,$25,$50,$2D,$38,$54; $5622  うえか゛いることを = うえがいることを
    db $EF,$EE                     ; $562B  newline
    db $90,$90                     ; $562D  　　(indent)
    db $53,$30,$51,$3B,$2D,$38,$33,$8D; $562F  わすれぬことた゛ = わすれぬことだ
    db $8F                         ; $5637  。
    db $FA                         ; $5638  wait-for-button
    db $F7                         ; $5639  clear page
    db $EF,$EE                     ; $563A  newline
    db $9F                         ; $563C  box tag
    db $96                         ; $563D  end name/box tag
    db $2D,$55,$2D,$8D             ; $563E  こんこ゛ = こんご
    db $90                         ; $5642  　(space)
    db $35,$29,$43,$27,$33         ; $5643  つかまえた
    db $90                         ; $5648  　(space)
    db $43,$47,$3D,$33,$8D,$2C,$37,$8D; $5649  まものた゛けて゛ = まものだけで
    db $EF,$EE                     ; $5651  newline
    db $90,$90                     ; $5653  　　(indent)
    db $33,$33,$29,$26,$3D,$3E     ; $5655  たたかうのは
    db $90                         ; $565B  　(space)
    db $35,$4E,$2B,$39,$50,$33,$8D,$52,$26; $565C  つらくなるた゛ろう = つらくなるだろう
    db $8F                         ; $5665  。
    db $FA                         ; $5666  wait-for-button
    db $F7                         ; $5667  clear page
    db $EF,$EE                     ; $5668  newline
    db $9F                         ; $566A  box tag
    db $96                         ; $566B  end name/box tag
    db $3E,$25,$2D,$8D,$26,$54     ; $566C  はいこ゛うを = はいごうを
    db $90                         ; $5672  　(space)
    db $28,$28,$25,$3A             ; $5673  おおいに
    db $90                         ; $5677  　(space)
    db $48,$36,$37                 ; $5678  やって
    db $EF,$EE                     ; $567B  newline
    db $90,$90                     ; $567D  　　(indent)
    db $35,$4C,$25,$43,$47,$3D,$54 ; $567F  つよいまものを
    db $90                         ; $5686  　(space)
    db $35,$2B,$50,$3D,$33,$8D,$39 ; $5687  つくるのた゛な = つくるのだな
    db $8F                         ; $568E  。
    db $F7                         ; $568F  clear page
    db $F0                         ; $5690  end of message


; --------------------------------------------------------------------------
; Message #65 ($5691)
;   「〈テリー〉くん！　じっけんは
;   ごらんのとおり　しっぱいだよ！！
;   「おおがまが　こっぱみじんに
;   なくなっちまった。
;   「わるいが　ばあさんは
;   あきらめてくれないか。
;   「たびのとびらが　したにあったから
;   すきにつかってくれたまえ！
; --------------------------------------------------------------------------
Bank69_Msg65:                              ; $5691  (file $115691)
    db $EA                         ; $5691  ▶ new page
    db $9F                         ; $5692  box tag
    db $96                         ; $5693  end name/box tag
    db $F6                         ; $5694  «insert hero name»
    db $2B,$55                     ; $5695  くん
    db $99                         ; $5697  ！
    db $90                         ; $5698  　(space)
    db $2F,$8D,$36,$2C,$55,$3E     ; $5699  し゛っけんは = じっけんは
    db $EF,$EE                     ; $569F  newline
    db $90,$90                     ; $56A1  　　(indent)
    db $2D,$8D,$4E,$55,$3D,$38,$28,$4F; $56A3  こ゛らんのとおり = ごらんのとおり
    db $90                         ; $56AB  　(space)
    db $2F,$36,$3E,$8E,$25,$33,$8D,$4C; $56AC  しっは゜いた゛よ = しっぱいだよ
    db $99                         ; $56B4  ！
    db $99                         ; $56B5  ！
    db $FA                         ; $56B6  wait-for-button
    db $F7                         ; $56B7  clear page
    db $EF,$EE                     ; $56B8  newline
    db $9F                         ; $56BA  box tag
    db $96                         ; $56BB  end name/box tag
    db $28,$28,$29,$8D,$43,$29,$8D ; $56BC  おおか゛まか゛ = おおがまが
    db $90                         ; $56C3  　(space)
    db $2D,$36,$3E,$8E,$44,$2F,$8D,$55,$3A; $56C4  こっは゜みし゛んに = こっぱみじんに
    db $EF,$EE                     ; $56CD  newline
    db $90,$90                     ; $56CF  　　(indent)
    db $39,$2B,$39,$36,$34,$43,$36,$33; $56D1  なくなっちまった
    db $8F                         ; $56D9  。
    db $FA                         ; $56DA  wait-for-button
    db $F7                         ; $56DB  clear page
    db $EF,$EE                     ; $56DC  newline
    db $9F                         ; $56DE  box tag
    db $96                         ; $56DF  end name/box tag
    db $53,$50,$25,$29,$8D         ; $56E0  わるいか゛ = わるいが
    db $90                         ; $56E5  　(space)
    db $3E,$8D,$24,$2E,$55,$3E     ; $56E6  は゛あさんは = ばあさんは
    db $EF,$EE                     ; $56EC  newline
    db $90,$90                     ; $56EE  　　(indent)
    db $24,$2A,$4E,$46,$37,$2B,$51,$39,$25,$29; $56F0  あきらめてくれないか
    db $8F                         ; $56FA  。
    db $FA                         ; $56FB  wait-for-button
    db $F7                         ; $56FC  clear page
    db $EF,$EE                     ; $56FD  newline
    db $9F                         ; $56FF  box tag
    db $96                         ; $5700  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $5701  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $570B  　(space)
    db $2F,$33,$3A,$24,$36,$33,$29,$4E; $570C  したにあったから
    db $EF,$EE                     ; $5714  newline
    db $90,$90                     ; $5716  　　(indent)
    db $30,$2A,$3A,$35,$29,$36,$37,$2B,$51,$33,$43,$27; $5718  すきにつかってくれたまえ
    db $99                         ; $5724  ！
    db $F7                         ; $5725  clear page
    db $F0                         ; $5726  end of message


; --------------------------------------------------------------------------
; Message #66 ($5727)
;   「しっぱいした、。　わるいが
;   ばあさんは　あきらめてくれ。
;   「たびのとびらが　したにあったから
;   かわりに　すきにつかってくれ！
; --------------------------------------------------------------------------
Bank69_Msg66:                              ; $5727  (file $115727)
    db $EA                         ; $5727  ▶ new page
    db $9F                         ; $5728  box tag
    db $96                         ; $5729  end name/box tag
    db $2F,$36,$3E,$8E,$25,$2F,$33 ; $572A  しっは゜いした = しっぱいした
    db $A4                         ; $5731  、
    db $8F                         ; $5732  。
    db $90                         ; $5733  　(space)
    db $53,$50,$25,$29,$8D         ; $5734  わるいか゛ = わるいが
    db $EF,$EE                     ; $5739  newline
    db $90,$90                     ; $573B  　　(indent)
    db $3E,$8D,$24,$2E,$55,$3E     ; $573D  は゛あさんは = ばあさんは
    db $90                         ; $5743  　(space)
    db $24,$2A,$4E,$46,$37,$2B,$51 ; $5744  あきらめてくれ
    db $8F                         ; $574B  。
    db $FA                         ; $574C  wait-for-button
    db $F7                         ; $574D  clear page
    db $EF,$EE                     ; $574E  newline
    db $9F                         ; $5750  box tag
    db $96                         ; $5751  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $5752  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $575C  　(space)
    db $2F,$33,$3A,$24,$36,$33,$29,$4E; $575D  したにあったから
    db $EF,$EE                     ; $5765  newline
    db $90,$90                     ; $5767  　　(indent)
    db $29,$53,$4F,$3A             ; $5769  かわりに
    db $90                         ; $576D  　(space)
    db $30,$2A,$3A,$35,$29,$36,$37,$2B,$51; $576E  すきにつかってくれ
    db $99                         ; $5777  ！
    db $F7                         ; $5778  clear page
    db $F0                         ; $5779  end of message


; --------------------------------------------------------------------------
; Message #67 ($577A)
;   「わしを　おれいに　あげるなんぞと
;   もうした　ばつじゃい！
;   「ちと　かやくを　まぜすぎたかの。
;   フオッ　フオッ　フオ、、。
; --------------------------------------------------------------------------
Bank69_Msg67:                              ; $577A  (file $11577A)
    db $EB                         ; $577A  ▶ new page
    db $9F                         ; $577B  box tag
    db $96                         ; $577C  end name/box tag
    db $53,$2F,$54                 ; $577D  わしを
    db $90                         ; $5780  　(space)
    db $28,$51,$25,$3A             ; $5781  おれいに
    db $90                         ; $5785  　(space)
    db $24,$2C,$8D,$50,$39,$55,$32,$8D,$38; $5786  あけ゛るなんそ゛と = あげるなんぞと
    db $EF,$EE                     ; $578F  newline
    db $90,$90                     ; $5791  　　(indent)
    db $47,$26,$2F,$33             ; $5793  もうした
    db $90                         ; $5797  　(space)
    db $3E,$8D,$35,$2F,$8D,$49,$25 ; $5798  は゛つし゛ゃい = ばつじゃい
    db $99                         ; $579F  ！
    db $FA                         ; $57A0  wait-for-button
    db $F7                         ; $57A1  clear page
    db $EF,$EE                     ; $57A2  newline
    db $9F                         ; $57A4  box tag
    db $96                         ; $57A5  end name/box tag
    db $34,$38                     ; $57A6  ちと
    db $90                         ; $57A8  　(space)
    db $29,$48,$2B,$54             ; $57A9  かやくを
    db $90                         ; $57AD  　(space)
    db $43,$31,$8D,$30,$2A,$8D,$33,$29,$3D; $57AE  ませ゛すき゛たかの = まぜすぎたかの
    db $8F                         ; $57B7  。
    db $EF,$EE                     ; $57B8  newline
    db $90,$90                     ; $57BA  　　(indent)
    db $77,$5F,$6D                 ; $57BC  フオッ
    db $90                         ; $57BF  　(space)
    db $77,$5F,$6D                 ; $57C0  フオッ
    db $90                         ; $57C3  　(space)
    db $77,$5F                     ; $57C4  フオ
    db $A4                         ; $57C6  、
    db $A4                         ; $57C7  、
    db $8F                         ; $57C8  。
    db $F7                         ; $57C9  clear page
    db $F0                         ; $57CA  end of message


; --------------------------------------------------------------------------
; Message #68 ($57CB)
;   「マスターようせいじゅくへ
;   ようこそ！
;   「きょうのこうぎは
;   まものの　せいべつのかえかただ。
;   「ききたいかね？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg68:                              ; $57CB  (file $1157CB)
    db $EA                         ; $57CB  ▶ new page
    db $9F                         ; $57CC  box tag
    db $96                         ; $57CD  end name/box tag
    db $7A,$67,$6A,$9C,$4C,$26,$31,$25,$2F,$8D,$4B,$2B,$41; $57CE  マスターようせいし゛ゅくへ = マスターようせいじゅくへ
    db $EF,$EE                     ; $57DB  newline
    db $90,$90                     ; $57DD  　　(indent)
    db $4C,$26,$2D,$32             ; $57DF  ようこそ
    db $99                         ; $57E3  ！
    db $FA                         ; $57E4  wait-for-button
    db $F7                         ; $57E5  clear page
    db $EF,$EE                     ; $57E6  newline
    db $9F                         ; $57E8  box tag
    db $96                         ; $57E9  end name/box tag
    db $2A,$4D,$26,$3D,$2D,$26,$2A,$8D,$3E; $57EA  きょうのこうき゛は = きょうのこうぎは
    db $EF,$EE                     ; $57F3  newline
    db $90,$90                     ; $57F5  　　(indent)
    db $43,$47,$3D,$3D             ; $57F7  まものの
    db $90                         ; $57FB  　(space)
    db $31,$25,$41,$8D,$35,$3D,$29,$27,$29,$33,$33,$8D; $57FC  せいへ゛つのかえかたた゛ = せいべつのかえかただ
    db $8F                         ; $5808  。
    db $FA                         ; $5809  wait-for-button
    db $F7                         ; $580A  clear page
    db $EF,$EE                     ; $580B  newline
    db $9F                         ; $580D  box tag
    db $96                         ; $580E  end name/box tag
    db $2A,$2A,$33,$25,$29,$3C     ; $580F  ききたいかね
    db $98                         ; $5815  ？
    db $EF,$EE                     ; $5816  newline
    db $FF                         ; $5818  はい/いいえ
    db $F0                         ; $5819  end of message


; --------------------------------------------------------------------------
; Message #69 ($581A)
;   「、あそこには　とりけいのまものが
;   ひしめきあっているそうだ。
;   「だいまおうと　よばれる　まものが
;   あそこの　ぬしらしいが。
; --------------------------------------------------------------------------
Bank69_Msg69:                              ; $581A  (file $11581A)
    db $EA                         ; $581A  ▶ new page
    db $9F                         ; $581B  box tag
    db $96                         ; $581C  end name/box tag
    db $A4                         ; $581D  、
    db $24,$32,$2D,$3A,$3E         ; $581E  あそこには
    db $90                         ; $5823  　(space)
    db $38,$4F,$2C,$25,$3D,$43,$47,$3D,$29,$8D; $5824  とりけいのまものか゛ = とりけいのまものが
    db $EF,$EE                     ; $582E  newline
    db $90,$90                     ; $5830  　　(indent)
    db $3F,$2F,$46,$2A,$24,$36,$37,$25,$50,$32,$26,$33,$8D; $5832  ひしめきあっているそうた゛ = ひしめきあっているそうだ
    db $8F                         ; $583F  。
    db $FA                         ; $5840  wait-for-button
    db $F7                         ; $5841  clear page
    db $EF,$EE                     ; $5842  newline
    db $9F                         ; $5844  box tag
    db $96                         ; $5845  end name/box tag
    db $33,$8D,$25,$43,$28,$26,$38 ; $5846  た゛いまおうと = だいまおうと
    db $90                         ; $584D  　(space)
    db $4C,$3E,$8D,$51,$50         ; $584E  よは゛れる = よばれる
    db $90                         ; $5853  　(space)
    db $43,$47,$3D,$29,$8D         ; $5854  まものか゛ = まものが
    db $EF,$EE                     ; $5859  newline
    db $90,$90                     ; $585B  　　(indent)
    db $24,$32,$2D,$3D             ; $585D  あそこの
    db $90                         ; $5861  　(space)
    db $3B,$2F,$4E,$2F,$25,$29,$8D ; $5862  ぬしらしいか゛ = ぬしらしいが
    db $8F                         ; $5869  。
    db $F7                         ; $586A  clear page
    db $F0                         ; $586B  end of message


; --------------------------------------------------------------------------
; Message #70 ($586C)
;   [E9]カ〈テリー〉は　タンスの
;   なかを　しらべた。
;   しかし　なにもなかった。
; --------------------------------------------------------------------------
Bank69_Msg70:                              ; $586C  (file $11586C)
    db $E9                         ; $586C  ctrl $E9
    db $60                         ; $586D  カ
    db $F6                         ; $586E  «insert hero name»
    db $3E                         ; $586F  は
    db $90                         ; $5870  　(space)
    db $6A,$8C,$67,$3D             ; $5871  タンスの
    db $EF,$EE                     ; $5875  newline
    db $39,$29,$54                 ; $5877  なかを
    db $90                         ; $587A  　(space)
    db $2F,$4E,$41,$8D,$33         ; $587B  しらへ゛た = しらべた
    db $8F                         ; $5880  。
    db $FA                         ; $5881  wait-for-button
    db $F7                         ; $5882  clear page
    db $EF,$EE                     ; $5883  newline
    db $2F,$29,$2F                 ; $5885  しかし
    db $90                         ; $5888  　(space)
    db $39,$3A,$47,$39,$29,$36,$33 ; $5889  なにもなかった
    db $8F                         ; $5890  。
    db $EF,$EE                     ; $5891  newline
    db $F7                         ; $5893  clear page
    db $F0                         ; $5894  end of message


; --------------------------------------------------------------------------
; Message #71 ($5895)
;   「よく　ミッキーを　たおせたな！
;   おまえと　みあいできてよかった！
;   「そうだ。まものによって　よくきく
;   とくぎと　きかないものがあるぞ。
;   「たとえば　ゾンビけいは　ひの
;   とくぎによわい。
;   「しょくぶつけいは　どくやマヒに
;   つよい。　、そんなかんじでな。
; --------------------------------------------------------------------------
Bank69_Msg71:                              ; $5895  (file $115895)
    db $EA                         ; $5895  ▶ new page
    db $9F                         ; $5896  box tag
    db $96                         ; $5897  end name/box tag
    db $4C,$2B                     ; $5898  よく
    db $90                         ; $589A  　(space)
    db $7B,$6D,$61,$9C,$54         ; $589B  ミッキーを
    db $90                         ; $58A0  　(space)
    db $33,$28,$31,$33,$39         ; $58A1  たおせたな
    db $99                         ; $58A6  ！
    db $EF,$EE                     ; $58A7  newline
    db $90,$90                     ; $58A9  　　(indent)
    db $28,$43,$27,$38             ; $58AB  おまえと
    db $90                         ; $58AF  　(space)
    db $44,$24,$25,$37,$8D,$2A,$37,$4C,$29,$36,$33; $58B0  みあいて゛きてよかった = みあいできてよかった
    db $99                         ; $58BB  ！
    db $FA                         ; $58BC  wait-for-button
    db $F7                         ; $58BD  clear page
    db $EF,$EE                     ; $58BE  newline
    db $9F                         ; $58C0  box tag
    db $96                         ; $58C1  end name/box tag
    db $32,$26,$33,$8D             ; $58C2  そうた゛ = そうだ
    db $8F                         ; $58C6  。
    db $43,$47,$3D,$3A,$4C,$36,$37 ; $58C7  まものによって
    db $90                         ; $58CE  　(space)
    db $4C,$2B,$2A,$2B             ; $58CF  よくきく
    db $EF,$EE                     ; $58D3  newline
    db $90,$90                     ; $58D5  　　(indent)
    db $38,$2B,$2A,$8D,$38         ; $58D7  とくき゛と = とくぎと
    db $90                         ; $58DC  　(space)
    db $2A,$29,$39,$25,$47,$3D,$29,$8D,$24,$50,$32,$8D; $58DD  きかないものか゛あるそ゛ = きかないものがあるぞ
    db $8F                         ; $58E9  。
    db $FA                         ; $58EA  wait-for-button
    db $F7                         ; $58EB  clear page
    db $EF,$EE                     ; $58EC  newline
    db $9F                         ; $58EE  box tag
    db $96                         ; $58EF  end name/box tag
    db $33,$38,$27,$3E,$8D         ; $58F0  たとえは゛ = たとえば
    db $90                         ; $58F5  　(space)
    db $69,$8D,$8C,$76,$8D,$2C,$25,$3E; $58F6  ソ゛ンヒ゛けいは = ゾンビけいは
    db $90                         ; $58FE  　(space)
    db $3F,$3D                     ; $58FF  ひの
    db $EF,$EE                     ; $5901  newline
    db $90,$90                     ; $5903  　　(indent)
    db $38,$2B,$2A,$8D,$3A,$4C,$53,$25; $5905  とくき゛によわい = とくぎによわい
    db $8F                         ; $590D  。
    db $FA                         ; $590E  wait-for-button
    db $F7                         ; $590F  clear page
    db $EF,$EE                     ; $5910  newline
    db $9F                         ; $5912  box tag
    db $96                         ; $5913  end name/box tag
    db $2F,$4D,$2B,$40,$8D,$35,$2C,$25,$3E; $5914  しょくふ゛つけいは = しょくぶつけいは
    db $90                         ; $591D  　(space)
    db $38,$8D,$2B,$48,$7A,$76,$3A ; $591E  と゛くやマヒに = どくやマヒに
    db $EF,$EE                     ; $5925  newline
    db $90,$90                     ; $5927  　　(indent)
    db $35,$4C,$25                 ; $5929  つよい
    db $8F                         ; $592C  。
    db $90                         ; $592D  　(space)
    db $A4                         ; $592E  、
    db $32,$55,$39,$29,$55,$2F,$8D,$37,$8D,$39; $592F  そんなかんし゛て゛な = そんなかんじでな
    db $8F                         ; $5939  。
    db $F7                         ; $593A  clear page
    db $F0                         ; $593B  end of message


; --------------------------------------------------------------------------
; Message #72 ($593C)
;   「では　はいごうでしか　つくれない
;   まもののなまえを　あげていこう。
;   「マンドラゴラ　ワィトキング
;   にじくじゃく　ローズバトラー、
;   「キングレォ　さそりアーマー
;   コアトル　ゴールデンスラィム、
;   「ゴールデンゴーレム
;   そして　しんりゅうだ！
;   「きみは　なんびき　つくれたかな？
; --------------------------------------------------------------------------
Bank69_Msg72:                              ; $593C  (file $11593C)
    db $EA                         ; $593C  ▶ new page
    db $9F                         ; $593D  box tag
    db $96                         ; $593E  end name/box tag
    db $37,$8D,$3E                 ; $593F  て゛は = では
    db $90                         ; $5942  　(space)
    db $3E,$25,$2D,$8D,$26,$37,$8D,$2F,$29; $5943  はいこ゛うて゛しか = はいごうでしか
    db $90                         ; $594C  　(space)
    db $35,$2B,$51,$39,$25         ; $594D  つくれない
    db $EF,$EE                     ; $5952  newline
    db $90,$90                     ; $5954  　　(indent)
    db $43,$47,$3D,$3D,$39,$43,$27,$54; $5956  まもののなまえを
    db $90                         ; $595E  　(space)
    db $24,$2C,$8D,$37,$25,$2D,$26 ; $595F  あけ゛ていこう = あげていこう
    db $8F                         ; $5966  。
    db $FA                         ; $5967  wait-for-button
    db $F7                         ; $5968  clear page
    db $EF,$EE                     ; $5969  newline
    db $9F                         ; $596B  box tag
    db $96                         ; $596C  end name/box tag
    db $7A,$8C,$6F,$8D,$85,$64,$8D,$85; $596D  マント゛ラコ゛ラ = マンドラゴラ
    db $90                         ; $5975  　(space)
    db $8A,$58,$6F,$61,$8C,$62,$8D ; $5976  ワィトキンク゛ = ワィトキング
    db $EF,$EE                     ; $597D  newline
    db $90,$90                     ; $597F  　　(indent)
    db $3A,$2F,$8D,$2B,$2F,$8D,$49,$2B; $5981  にし゛くし゛ゃく = にじくじゃく
    db $90                         ; $5989  　(space)
    db $89,$9C,$67,$8D,$75,$8D,$6F,$85,$9C; $598A  ロース゛ハ゛トラー = ローズバトラー
    db $A4                         ; $5993  、
    db $FA                         ; $5994  wait-for-button
    db $F7                         ; $5995  clear page
    db $EF,$EE                     ; $5996  newline
    db $9F                         ; $5998  box tag
    db $96                         ; $5999  end name/box tag
    db $61,$8C,$62,$8D,$88,$5E     ; $599A  キンク゛レォ = キングレォ
    db $90                         ; $59A0  　(space)
    db $2E,$32,$4F,$56,$9C,$7A,$9C ; $59A1  さそりアーマー
    db $EF,$EE                     ; $59A8  newline
    db $90,$90                     ; $59AA  　　(indent)
    db $64,$56,$6F,$87             ; $59AC  コアトル
    db $90                         ; $59B0  　(space)
    db $64,$8D,$9C,$87,$6E,$8D,$8C,$67,$85,$58,$7C; $59B1  コ゛ールテ゛ンスラィム = ゴールデンスラィム
    db $A4                         ; $59BC  、
    db $FA                         ; $59BD  wait-for-button
    db $F7                         ; $59BE  clear page
    db $EF,$EE                     ; $59BF  newline
    db $9F                         ; $59C1  box tag
    db $96                         ; $59C2  end name/box tag
    db $64,$8D,$9C,$87,$6E,$8D,$8C,$64,$8D,$9C,$88,$7C; $59C3  コ゛ールテ゛ンコ゛ーレム = ゴールデンゴーレム
    db $EF,$EE                     ; $59CF  newline
    db $90,$90                     ; $59D1  　　(indent)
    db $32,$2F,$37                 ; $59D3  そして
    db $90                         ; $59D6  　(space)
    db $2F,$55,$4F,$4B,$26,$33,$8D ; $59D7  しんりゅうた゛ = しんりゅうだ
    db $99                         ; $59DE  ！
    db $FA                         ; $59DF  wait-for-button
    db $F7                         ; $59E0  clear page
    db $EF,$EE                     ; $59E1  newline
    db $9F                         ; $59E3  box tag
    db $96                         ; $59E4  end name/box tag
    db $2A,$44,$3E                 ; $59E5  きみは
    db $90                         ; $59E8  　(space)
    db $39,$55,$3F,$8D,$2A         ; $59E9  なんひ゛き = なんびき
    db $90                         ; $59EE  　(space)
    db $35,$2B,$51,$33,$29,$39     ; $59EF  つくれたかな
    db $98                         ; $59F5  ？
    db $EF,$EE                     ; $59F6  newline
    db $F7                         ; $59F8  clear page
    db $F0                         ; $59F9  end of message


; --------------------------------------------------------------------------
; Message #73 ($59FA)
;   「うむ。ゆうしょうしゃ〈テリー〉には
;   たしかに　ひつようないだろう。
; --------------------------------------------------------------------------
Bank69_Msg73:                              ; $59FA  (file $1159FA)
    db $EA                         ; $59FA  ▶ new page
    db $9F                         ; $59FB  box tag
    db $96                         ; $59FC  end name/box tag
    db $26,$45                     ; $59FD  うむ
    db $8F                         ; $59FF  。
    db $4A,$26,$2F,$4D,$26,$2F,$49 ; $5A00  ゆうしょうしゃ
    db $F6                         ; $5A07  «insert hero name»
    db $3A,$3E                     ; $5A08  には
    db $EF,$EE                     ; $5A0A  newline
    db $90,$90                     ; $5A0C  　　(indent)
    db $33,$2F,$29,$3A             ; $5A0E  たしかに
    db $90                         ; $5A12  　(space)
    db $3F,$35,$4C,$26,$39,$25,$33,$8D,$52,$26; $5A13  ひつようないた゛ろう = ひつようないだろう
    db $8F                         ; $5A1D  。
    db $F7                         ; $5A1E  clear page
    db $F0                         ; $5A1F  end of message


; --------------------------------------------------------------------------
; Message #74 ($5A20)
;   「ゆうしょう　おめでとう！
;   ぼくらのあこがれ　〈テリー〉さま！
;   「とくぎの　うけつぎかたを
;   ノートにとったんだ。　みたい？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg74:                              ; $5A20  (file $115A20)
    db $EB                         ; $5A20  ▶ new page
    db $9F                         ; $5A21  box tag
    db $96                         ; $5A22  end name/box tag
    db $4A,$26,$2F,$4D,$26         ; $5A23  ゆうしょう
    db $90                         ; $5A28  　(space)
    db $28,$46,$37,$8D,$38,$26     ; $5A29  おめて゛とう = おめでとう
    db $99                         ; $5A2F  ！
    db $EF,$EE                     ; $5A30  newline
    db $90,$90                     ; $5A32  　　(indent)
    db $42,$8D,$2B,$4E,$3D,$24,$2D,$29,$8D,$51; $5A34  ほ゛くらのあこか゛れ = ぼくらのあこがれ
    db $90                         ; $5A3E  　(space)
    db $F6                         ; $5A3F  «insert hero name»
    db $2E,$43                     ; $5A40  さま
    db $99                         ; $5A42  ！
    db $FA                         ; $5A43  wait-for-button
    db $F7                         ; $5A44  clear page
    db $EF,$EE                     ; $5A45  newline
    db $9F                         ; $5A47  box tag
    db $96                         ; $5A48  end name/box tag
    db $38,$2B,$2A,$8D,$3D         ; $5A49  とくき゛の = とくぎの
    db $90                         ; $5A4E  　(space)
    db $26,$2C,$35,$2A,$8D,$29,$33,$54; $5A4F  うけつき゛かたを = うけつぎかたを
    db $EF,$EE                     ; $5A57  newline
    db $90,$90                     ; $5A59  　　(indent)
    db $74,$9C,$6F,$3A,$38,$36,$33,$55,$33,$8D; $5A5B  ノートにとったんた゛ = ノートにとったんだ
    db $8F                         ; $5A65  。
    db $90                         ; $5A66  　(space)
    db $44,$33,$25                 ; $5A67  みたい
    db $98                         ; $5A6A  ？
    db $FF                         ; $5A6B  はい/いいえ
    db $F0                         ; $5A6C  end of message


; --------------------------------------------------------------------------
; Message #75 ($5A6D)
;   ミッキー「こういうときは　いさぎよく
;   まけを　みとめるべきだろうね、。
;   ミッキー「、きみとの　ゆうじょうの
;   しるしだ。　おみあいしよう！！
;   ミッキー「しりょうのきし　だけど
;   おみあいしてくれるね！？
; --------------------------------------------------------------------------
Bank69_Msg75:                              ; $5A6D  (file $115A6D)
    db $EA                         ; $5A6D  ▶ new page
    db $7B,$6D,$61,$9C             ; $5A6E  ミッキー
    db $96                         ; $5A72  end name/box tag
    db $2D,$26,$25,$26,$38,$2A,$3E ; $5A73  こういうときは
    db $90                         ; $5A7A  　(space)
    db $25,$2E,$2A,$8D,$4C,$2B     ; $5A7B  いさき゛よく = いさぎよく
    db $EF,$EE                     ; $5A81  newline
    db $90,$90                     ; $5A83  　　(indent)
    db $43,$2C,$54                 ; $5A85  まけを
    db $90                         ; $5A88  　(space)
    db $44,$38,$46,$50,$41,$8D,$2A,$33,$8D,$52,$26,$3C; $5A89  みとめるへ゛きた゛ろうね = みとめるべきだろうね
    db $A4                         ; $5A95  、
    db $8F                         ; $5A96  。
    db $FA                         ; $5A97  wait-for-button
    db $F7                         ; $5A98  clear page
    db $EF,$EE                     ; $5A99  newline
    db $7B,$6D,$61,$9C             ; $5A9B  ミッキー
    db $96                         ; $5A9F  end name/box tag
    db $A4                         ; $5AA0  、
    db $2A,$44,$38,$3D             ; $5AA1  きみとの
    db $90                         ; $5AA5  　(space)
    db $4A,$26,$2F,$8D,$4D,$26,$3D ; $5AA6  ゆうし゛ょうの = ゆうじょうの
    db $EF,$EE                     ; $5AAD  newline
    db $90,$90                     ; $5AAF  　　(indent)
    db $2F,$50,$2F,$33,$8D         ; $5AB1  しるした゛ = しるしだ
    db $8F                         ; $5AB6  。
    db $90                         ; $5AB7  　(space)
    db $28,$44,$24,$25,$2F,$4C,$26 ; $5AB8  おみあいしよう
    db $99                         ; $5ABF  ！
    db $99                         ; $5AC0  ！
    db $FA                         ; $5AC1  wait-for-button
    db $F7                         ; $5AC2  clear page
    db $EF,$EE                     ; $5AC3  newline
    db $7B,$6D,$61,$9C             ; $5AC5  ミッキー
    db $96                         ; $5AC9  end name/box tag
    db $2F,$4F,$4D,$26,$3D,$2A,$2F ; $5ACA  しりょうのきし
    db $90                         ; $5AD1  　(space)
    db $33,$8D,$2C,$38,$8D         ; $5AD2  た゛けと゛ = だけど
    db $EF,$EE                     ; $5AD7  newline
    db $90,$90                     ; $5AD9  　　(indent)
    db $28,$44,$24,$25,$2F,$37,$2B,$51,$50,$3C; $5ADB  おみあいしてくれるね
    db $99                         ; $5AE5  ！
    db $98                         ; $5AE6  ？
    db $F0                         ; $5AE7  end of message


; --------------------------------------------------------------------------
; Message #76 ($5AE8)
;   「ファッ　ファッ　ファッ。
;   わしを　たおしよったわい！
; --------------------------------------------------------------------------
Bank69_Msg76:                              ; $5AE8  (file $115AE8)
    db $EA                         ; $5AE8  ▶ new page
    db $9F                         ; $5AE9  box tag
    db $96                         ; $5AEA  end name/box tag
    db $77,$57,$6D                 ; $5AEB  ファッ
    db $90                         ; $5AEE  　(space)
    db $77,$57,$6D                 ; $5AEF  ファッ
    db $90                         ; $5AF2  　(space)
    db $77,$57,$6D                 ; $5AF3  ファッ
    db $8F                         ; $5AF6  。
    db $EF,$EE                     ; $5AF7  newline
    db $90,$90                     ; $5AF9  　　(indent)
    db $53,$2F,$54                 ; $5AFB  わしを
    db $90                         ; $5AFE  　(space)
    db $33,$28,$2F,$4C,$36,$33,$53,$25; $5AFF  たおしよったわい
    db $99                         ; $5B07  ！
    db $F7                         ; $5B08  clear page
    db $F0                         ; $5B09  end of message


; --------------------------------------------------------------------------
; Message #77 ($5B0A)
;   「キーキキキッ。
; --------------------------------------------------------------------------
Bank69_Msg77:                              ; $5B0A  (file $115B0A)
    db $EA                         ; $5B0A  ▶ new page
    db $9F                         ; $5B0B  box tag
    db $96                         ; $5B0C  end name/box tag
    db $61,$9C,$61,$61,$61,$6D     ; $5B0D  キーキキキッ
    db $8F                         ; $5B13  。
    db $EF,$EE                     ; $5B14  newline
    db $F7                         ; $5B16  clear page
    db $F0                         ; $5B17  end of message


; --------------------------------------------------------------------------
; Message #78 ($5B18)
;   「、、。
; --------------------------------------------------------------------------
Bank69_Msg78:                              ; $5B18  (file $115B18)
    db $EA                         ; $5B18  ▶ new page
    db $9F                         ; $5B19  box tag
    db $96                         ; $5B1A  end name/box tag
    db $A4                         ; $5B1B  、
    db $A4                         ; $5B1C  、
    db $8F                         ; $5B1D  。
    db $EF,$EE                     ; $5B1E  newline
    db $F7                         ; $5B20  clear page
    db $F0                         ; $5B21  end of message


; --------------------------------------------------------------------------
; Message #79 ($5B22)
;   わたほ゛う「もりの　めいろを
;   よく　かいけつ　したね。
;   わたほ゛う「たまには　とおまわり
;   するのも　いいもんだろ！
; --------------------------------------------------------------------------
Bank69_Msg79:                              ; $5B22  (file $115B22)
    db $EB                         ; $5B22  ▶ new page
    db $53,$33,$42,$8D,$26         ; $5B23  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5B28  end name/box tag
    db $47,$4F,$3D                 ; $5B29  もりの
    db $90                         ; $5B2C  　(space)
    db $46,$25,$52,$54             ; $5B2D  めいろを
    db $EF,$EE                     ; $5B31  newline
    db $90,$90                     ; $5B33  　　(indent)
    db $4C,$2B                     ; $5B35  よく
    db $90                         ; $5B37  　(space)
    db $29,$25,$2C,$35             ; $5B38  かいけつ
    db $90                         ; $5B3C  　(space)
    db $2F,$33,$3C                 ; $5B3D  したね
    db $8F                         ; $5B40  。
    db $FA                         ; $5B41  wait-for-button
    db $F7                         ; $5B42  clear page
    db $EF,$EE                     ; $5B43  newline
    db $53,$33,$42,$8D,$26         ; $5B45  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5B4A  end name/box tag
    db $33,$43,$3A,$3E             ; $5B4B  たまには
    db $90                         ; $5B4F  　(space)
    db $38,$28,$43,$53,$4F         ; $5B50  とおまわり
    db $EF,$EE                     ; $5B55  newline
    db $90,$90                     ; $5B57  　　(indent)
    db $30,$50,$3D,$47             ; $5B59  するのも
    db $90                         ; $5B5D  　(space)
    db $25,$25,$47,$55,$33,$8D,$52 ; $5B5E  いいもんた゛ろ = いいもんだろ
    db $99                         ; $5B65  ！
    db $F7                         ; $5B66  clear page
    db $F0                         ; $5B67  end of message


; --------------------------------------------------------------------------
; Message #80 ($5B68)
;   「いらっ、、、しゃい、、。
; --------------------------------------------------------------------------
Bank69_Msg80:                              ; $5B68  (file $115B68)
    db $EA                         ; $5B68  ▶ new page
    db $9F                         ; $5B69  box tag
    db $96                         ; $5B6A  end name/box tag
    db $25,$4E,$36                 ; $5B6B  いらっ
    db $A4                         ; $5B6E  、
    db $A4                         ; $5B6F  、
    db $A4                         ; $5B70  、
    db $2F,$49,$25                 ; $5B71  しゃい
    db $A4                         ; $5B74  、
    db $A4                         ; $5B75  、
    db $8F                         ; $5B76  。
    db $EF,$EE                     ; $5B77  newline
    db $F7                         ; $5B79  clear page
    db $F0                         ; $5B7A  end of message


; --------------------------------------------------------------------------
; Message #81 ($5B7B)
;   「また、、きて、くれよ、、。
; --------------------------------------------------------------------------
Bank69_Msg81:                              ; $5B7B  (file $115B7B)
    db $EA                         ; $5B7B  ▶ new page
    db $9F                         ; $5B7C  box tag
    db $96                         ; $5B7D  end name/box tag
    db $43,$33                     ; $5B7E  また
    db $A4                         ; $5B80  、
    db $A4                         ; $5B81  、
    db $2A,$37                     ; $5B82  きて
    db $A4                         ; $5B84  、
    db $2B,$51,$4C                 ; $5B85  くれよ
    db $A4                         ; $5B88  、
    db $A4                         ; $5B89  、
    db $8F                         ; $5B8A  。
    db $EF,$EE                     ; $5B8B  newline
    db $F7                         ; $5B8D  clear page
    db $F0                         ; $5B8E  end of message


; --------------------------------------------------------------------------
; Message #82 ($5B8F)
;   「、、、、、、、。
; --------------------------------------------------------------------------
Bank69_Msg82:                              ; $5B8F  (file $115B8F)
    db $EA                         ; $5B8F  ▶ new page
    db $9F                         ; $5B90  box tag
    db $96                         ; $5B91  end name/box tag
    db $A4                         ; $5B92  、
    db $A4                         ; $5B93  、
    db $A4                         ; $5B94  、
    db $A4                         ; $5B95  、
    db $A4                         ; $5B96  、
    db $A4                         ; $5B97  、
    db $A4                         ; $5B98  、
    db $8F                         ; $5B99  。
    db $EF,$EE                     ; $5B9A  newline
    db $F7                         ; $5B9C  clear page
    db $F0                         ; $5B9D  end of message


; --------------------------------------------------------------------------
; Message #83 ($5B9E)
;   「、、、、、　、、。
; --------------------------------------------------------------------------
Bank69_Msg83:                              ; $5B9E  (file $115B9E)
    db $EA                         ; $5B9E  ▶ new page
    db $9F                         ; $5B9F  box tag
    db $96                         ; $5BA0  end name/box tag
    db $A4                         ; $5BA1  、
    db $A4                         ; $5BA2  、
    db $A4                         ; $5BA3  、
    db $A4                         ; $5BA4  、
    db $A4                         ; $5BA5  、
    db $90                         ; $5BA6  　(space)
    db $A4                         ; $5BA7  、
    db $A4                         ; $5BA8  、
    db $8F                         ; $5BA9  。
    db $EF,$EE                     ; $5BAA  newline
    db $F7                         ; $5BAC  clear page
    db $F0                         ; $5BAD  end of message


; --------------------------------------------------------------------------
; Message #84 ($5BAE)
;   わたほ゛う「ここは　そのむかし
;   まものたちに　ほろぼされたんだ。
;   わたほ゛う「もう　ずいぶん
;   むかしの　はなしだけどね。
;   わたほ゛う「それじゃ　いこうか。
; --------------------------------------------------------------------------
Bank69_Msg84:                              ; $5BAE  (file $115BAE)
    db $EB                         ; $5BAE  ▶ new page
    db $53,$33,$42,$8D,$26         ; $5BAF  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5BB4  end name/box tag
    db $2D,$2D,$3E                 ; $5BB5  ここは
    db $90                         ; $5BB8  　(space)
    db $32,$3D,$45,$29,$2F         ; $5BB9  そのむかし
    db $EF,$EE                     ; $5BBE  newline
    db $90,$90                     ; $5BC0  　　(indent)
    db $43,$47,$3D,$33,$34,$3A     ; $5BC2  まものたちに
    db $90                         ; $5BC8  　(space)
    db $42,$52,$42,$8D,$2E,$51,$33,$55,$33,$8D; $5BC9  ほろほ゛されたんた゛ = ほろぼされたんだ
    db $8F                         ; $5BD3  。
    db $FA                         ; $5BD4  wait-for-button
    db $F7                         ; $5BD5  clear page
    db $EF,$EE                     ; $5BD6  newline
    db $53,$33,$42,$8D,$26         ; $5BD8  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5BDD  end name/box tag
    db $47,$26                     ; $5BDE  もう
    db $90                         ; $5BE0  　(space)
    db $30,$8D,$25,$40,$8D,$55     ; $5BE1  す゛いふ゛ん = ずいぶん
    db $EF,$EE                     ; $5BE7  newline
    db $90,$90                     ; $5BE9  　　(indent)
    db $45,$29,$2F,$3D             ; $5BEB  むかしの
    db $90                         ; $5BEF  　(space)
    db $3E,$39,$2F,$33,$8D,$2C,$38,$8D,$3C; $5BF0  はなした゛けと゛ね = はなしだけどね
    db $8F                         ; $5BF9  。
    db $FA                         ; $5BFA  wait-for-button
    db $F7                         ; $5BFB  clear page
    db $EF,$EE                     ; $5BFC  newline
    db $53,$33,$42,$8D,$26         ; $5BFE  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $5C03  end name/box tag
    db $32,$51,$2F,$8D,$49         ; $5C04  それし゛ゃ = それじゃ
    db $90                         ; $5C09  　(space)
    db $25,$2D,$26,$29             ; $5C0A  いこうか
    db $8F                         ; $5C0E  。
    db $EF,$EE                     ; $5C0F  newline
    db $F7                         ; $5C11  clear page
    db $F0                         ; $5C12  end of message


; --------------------------------------------------------------------------
; Message #85 ($5C13)
;   〈テリー〉は　スロットを　まわした！
;   カラカラとスロットは　まわっている。
;   、、　、、　、、　、、　、、　、、。
;   カシャーン　カシャーン　カシャーン！
;   スロットは　とまった。
;   スラィムが　[03]びき
;   こっちを　みている。
;   チユリーン！
;   〈テリー〉は　[05][00]まものゴールド
;   てにいれた！
; --------------------------------------------------------------------------
Bank69_Msg85:                              ; $5C13  (file $115C13)
    db $F6                         ; $5C13  «insert hero name»
    db $3E                         ; $5C14  は
    db $90                         ; $5C15  　(space)
    db $67,$89,$6D,$6F,$54         ; $5C16  スロットを
    db $90                         ; $5C1B  　(space)
    db $43,$53,$2F,$33             ; $5C1C  まわした
    db $99                         ; $5C20  ！
    db $EF,$EE                     ; $5C21  newline
    db $FA                         ; $5C23  wait-for-button
    db $F7                         ; $5C24  clear page
    db $EF,$EE                     ; $5C25  newline
    db $F3                         ; $5C27  open text box
    db $60,$85,$60,$85,$38,$67,$89,$6D,$6F,$3E; $5C28  カラカラとスロットは
    db $90                         ; $5C32  　(space)
    db $43,$53,$36,$37,$25,$50     ; $5C33  まわっている
    db $8F                         ; $5C39  。
    db $EF,$EE                     ; $5C3A  newline
    db $A4                         ; $5C3C  、
    db $A4                         ; $5C3D  、
    db $90                         ; $5C3E  　(space)
    db $A4                         ; $5C3F  、
    db $A4                         ; $5C40  、
    db $90                         ; $5C41  　(space)
    db $A4                         ; $5C42  、
    db $A4                         ; $5C43  、
    db $90                         ; $5C44  　(space)
    db $A4                         ; $5C45  、
    db $A4                         ; $5C46  、
    db $90                         ; $5C47  　(space)
    db $A4                         ; $5C48  、
    db $A4                         ; $5C49  、
    db $90                         ; $5C4A  　(space)
    db $A4                         ; $5C4B  、
    db $A4                         ; $5C4C  、
    db $8F                         ; $5C4D  。
    db $FA                         ; $5C4E  wait-for-button
    db $F7                         ; $5C4F  clear page
    db $EF,$EE                     ; $5C50  newline
    db $60,$66,$82,$9C,$8C         ; $5C52  カシャーン
    db $90                         ; $5C57  　(space)
    db $60,$66,$82,$9C,$8C         ; $5C58  カシャーン
    db $90                         ; $5C5D  　(space)
    db $60,$66,$82,$9C,$8C         ; $5C5E  カシャーン
    db $99                         ; $5C63  ！
    db $EF,$EE                     ; $5C64  newline
    db $67,$89,$6D,$6F,$3E         ; $5C66  スロットは
    db $90                         ; $5C6B  　(space)
    db $38,$43,$36,$33             ; $5C6C  とまった
    db $8F                         ; $5C70  。
    db $FA                         ; $5C71  wait-for-button
    db $F7                         ; $5C72  clear page
    db $EF,$EE                     ; $5C73  newline
    db $67,$85,$58,$7C,$29,$8D     ; $5C75  スラィムか゛ = スラィムが
    db $90                         ; $5C7B  　(space)
    db $03                         ; $5C7C  ctrl $03
    db $3F,$8D,$2A                 ; $5C7D  ひ゛き = びき
    db $90                         ; $5C80  　(space)
    db $EF,$EE                     ; $5C81  newline
    db $2D,$36,$34,$54             ; $5C83  こっちを
    db $90                         ; $5C87  　(space)
    db $44,$37,$25,$50             ; $5C88  みている
    db $8F                         ; $5C8C  。
    db $FA                         ; $5C8D  wait-for-button
    db $F7                         ; $5C8E  clear page
    db $EF,$EE                     ; $5C8F  newline
    db $6B,$80,$86,$9C,$8C         ; $5C91  チユリーン
    db $99                         ; $5C96  ！
    db $EF,$EE                     ; $5C97  newline
    db $FA                         ; $5C99  wait-for-button
    db $F7                         ; $5C9A  clear page
    db $EF,$EE                     ; $5C9B  newline
    db $F3                         ; $5C9D  open text box
    db $F6                         ; $5C9E  «insert hero name»
    db $3E                         ; $5C9F  は
    db $90                         ; $5CA0  　(space)
    db $05                         ; $5CA1  ctrl $05
    db $00                         ; $5CA2  ctrl $00
    db $43,$47,$3D,$64,$8D,$9C,$87,$6F,$8D; $5CA3  まものコ゛ールト゛ = まものゴールド
    db $EF,$EE                     ; $5CAC  newline
    db $37,$3A,$25,$51,$33         ; $5CAE  てにいれた
    db $99                         ; $5CB3  ！
    db $F7                         ; $5CB4  clear page
    db $F0                         ; $5CB5  end of message


; --------------------------------------------------------------------------
; Message #86 ($5CB6)
;   ミッキー「、きみとの　ゆうじょうの
;   しるしだ。　おみあいしよう！！
;   ミッキー「しりょうのきし　だけど
;   おみあいしてくれるね！？
; --------------------------------------------------------------------------
Bank69_Msg86:                              ; $5CB6  (file $115CB6)
    db $EA                         ; $5CB6  ▶ new page
    db $7B,$6D,$61,$9C             ; $5CB7  ミッキー
    db $96                         ; $5CBB  end name/box tag
    db $A4                         ; $5CBC  、
    db $2A,$44,$38,$3D             ; $5CBD  きみとの
    db $90                         ; $5CC1  　(space)
    db $4A,$26,$2F,$8D,$4D,$26,$3D ; $5CC2  ゆうし゛ょうの = ゆうじょうの
    db $EF,$EE                     ; $5CC9  newline
    db $90,$90                     ; $5CCB  　　(indent)
    db $2F,$50,$2F,$33,$8D         ; $5CCD  しるした゛ = しるしだ
    db $8F                         ; $5CD2  。
    db $90                         ; $5CD3  　(space)
    db $28,$44,$24,$25,$2F,$4C,$26 ; $5CD4  おみあいしよう
    db $99                         ; $5CDB  ！
    db $99                         ; $5CDC  ！
    db $FA                         ; $5CDD  wait-for-button
    db $F7                         ; $5CDE  clear page
    db $EF,$EE                     ; $5CDF  newline
    db $7B,$6D,$61,$9C             ; $5CE1  ミッキー
    db $96                         ; $5CE5  end name/box tag
    db $2F,$4F,$4D,$26,$3D,$2A,$2F ; $5CE6  しりょうのきし
    db $90                         ; $5CED  　(space)
    db $33,$8D,$2C,$38,$8D         ; $5CEE  た゛けと゛ = だけど
    db $EF,$EE                     ; $5CF3  newline
    db $90,$90                     ; $5CF5  　　(indent)
    db $28,$44,$24,$25,$2F,$37,$2B,$51,$50,$3C; $5CF7  おみあいしてくれるね
    db $99                         ; $5D01  ！
    db $98                         ; $5D02  ？
    db $F0                         ; $5D03  end of message


; --------------------------------------------------------------------------
; Message #87 ($5D04)
;   ミッキー「ぼくは　これから　たびに
;   でようと　おもうんだ。
;   ミッキー「〈テリー〉が　たいかいに
;   でられるよう　いのってるからね！
; --------------------------------------------------------------------------
Bank69_Msg87:                              ; $5D04  (file $115D04)
    db $EA                         ; $5D04  ▶ new page
    db $7B,$6D,$61,$9C             ; $5D05  ミッキー
    db $96                         ; $5D09  end name/box tag
    db $42,$8D,$2B,$3E             ; $5D0A  ほ゛くは = ぼくは
    db $90                         ; $5D0E  　(space)
    db $2D,$51,$29,$4E             ; $5D0F  これから
    db $90                         ; $5D13  　(space)
    db $33,$3F,$8D,$3A             ; $5D14  たひ゛に = たびに
    db $EF,$EE                     ; $5D18  newline
    db $90,$90                     ; $5D1A  　　(indent)
    db $37,$8D,$4C,$26,$38         ; $5D1C  て゛ようと = でようと
    db $90                         ; $5D21  　(space)
    db $28,$47,$26,$55,$33,$8D     ; $5D22  おもうんた゛ = おもうんだ
    db $8F                         ; $5D28  。
    db $FA                         ; $5D29  wait-for-button
    db $F7                         ; $5D2A  clear page
    db $EF,$EE                     ; $5D2B  newline
    db $7B,$6D,$61,$9C             ; $5D2D  ミッキー
    db $96                         ; $5D31  end name/box tag
    db $F6                         ; $5D32  «insert hero name»
    db $29,$8D                     ; $5D33  か゛ = が
    db $90                         ; $5D35  　(space)
    db $33,$25,$29,$25,$3A         ; $5D36  たいかいに
    db $EF,$EE                     ; $5D3B  newline
    db $90,$90                     ; $5D3D  　　(indent)
    db $37,$8D,$4E,$51,$50,$4C,$26 ; $5D3F  て゛られるよう = でられるよう
    db $90                         ; $5D46  　(space)
    db $25,$3D,$36,$37,$50,$29,$4E,$3C; $5D47  いのってるからね
    db $99                         ; $5D4F  ！
    db $F7                         ; $5D50  clear page
    db $F0                         ; $5D51  end of message


; --------------------------------------------------------------------------
; Message #88 ($5D52)
;   「〈テリー〉さんっ　ここが
;   ちからといかりのへやです！
;   「みぎにある　いかりのとびらの
;   ようすが　おかしいのです！！
; --------------------------------------------------------------------------
Bank69_Msg88:                              ; $5D52  (file $115D52)
    db $EA                         ; $5D52  ▶ new page
    db $9F                         ; $5D53  box tag
    db $96                         ; $5D54  end name/box tag
    db $F6                         ; $5D55  «insert hero name»
    db $2E,$55,$36                 ; $5D56  さんっ
    db $90                         ; $5D59  　(space)
    db $2D,$2D,$29,$8D             ; $5D5A  ここか゛ = ここが
    db $EF,$EE                     ; $5D5E  newline
    db $90,$90                     ; $5D60  　　(indent)
    db $34,$29,$4E,$38,$25,$29,$4F,$3D,$41,$48,$37,$8D,$30; $5D62  ちからといかりのへやて゛す = ちからといかりのへやです
    db $99                         ; $5D6F  ！
    db $FA                         ; $5D70  wait-for-button
    db $F7                         ; $5D71  clear page
    db $EF,$EE                     ; $5D72  newline
    db $9F                         ; $5D74  box tag
    db $96                         ; $5D75  end name/box tag
    db $44,$2A,$8D,$3A,$24,$50     ; $5D76  みき゛にある = みぎにある
    db $90                         ; $5D7C  　(space)
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3D; $5D7D  いかりのとひ゛らの = いかりのとびらの
    db $EF,$EE                     ; $5D86  newline
    db $90,$90                     ; $5D88  　　(indent)
    db $4C,$26,$30,$29,$8D         ; $5D8A  ようすか゛ = ようすが
    db $90                         ; $5D8F  　(space)
    db $28,$29,$2F,$25,$3D,$37,$8D,$30; $5D90  おかしいのて゛す = おかしいのです
    db $99                         ; $5D98  ！
    db $99                         ; $5D99  ！
    db $F7                         ; $5D9A  clear page
    db $F0                         ; $5D9B  end of message


; --------------------------------------------------------------------------
; Message #89 ($5D9C)
;   「いかりのとびらに
;   まものが　あふれかえっています！
;   「なんとかしないと　こちらの
;   せかいも　たいへんなことに、！
;   「〈テリー〉さん！
;   どうか　おたすけをっ！
; --------------------------------------------------------------------------
Bank69_Msg89:                              ; $5D9C  (file $115D9C)
    db $EA                         ; $5D9C  ▶ new page
    db $9F                         ; $5D9D  box tag
    db $96                         ; $5D9E  end name/box tag
    db $25,$29,$4F,$3D,$38,$3F,$8D,$4E,$3A; $5D9F  いかりのとひ゛らに = いかりのとびらに
    db $EF,$EE                     ; $5DA8  newline
    db $90,$90                     ; $5DAA  　　(indent)
    db $43,$47,$3D,$29,$8D         ; $5DAC  まものか゛ = まものが
    db $90                         ; $5DB1  　(space)
    db $24,$40,$51,$29,$27,$36,$37,$25,$43,$30; $5DB2  あふれかえっています
    db $99                         ; $5DBC  ！
    db $FA                         ; $5DBD  wait-for-button
    db $F7                         ; $5DBE  clear page
    db $EF,$EE                     ; $5DBF  newline
    db $9F                         ; $5DC1  box tag
    db $96                         ; $5DC2  end name/box tag
    db $39,$55,$38,$29,$2F,$39,$25,$38; $5DC3  なんとかしないと
    db $90                         ; $5DCB  　(space)
    db $2D,$34,$4E,$3D             ; $5DCC  こちらの
    db $EF,$EE                     ; $5DD0  newline
    db $90,$90                     ; $5DD2  　　(indent)
    db $31,$29,$25,$47             ; $5DD4  せかいも
    db $90                         ; $5DD8  　(space)
    db $33,$25,$41,$55,$39,$2D,$38,$3A; $5DD9  たいへんなことに
    db $A4                         ; $5DE1  、
    db $99                         ; $5DE2  ！
    db $FA                         ; $5DE3  wait-for-button
    db $F7                         ; $5DE4  clear page
    db $EF,$EE                     ; $5DE5  newline
    db $9F                         ; $5DE7  box tag
    db $96                         ; $5DE8  end name/box tag
    db $F6                         ; $5DE9  «insert hero name»
    db $2E,$55                     ; $5DEA  さん
    db $99                         ; $5DEC  ！
    db $EF,$EE                     ; $5DED  newline
    db $90,$90                     ; $5DEF  　　(indent)
    db $38,$8D,$26,$29             ; $5DF1  と゛うか = どうか
    db $90                         ; $5DF5  　(space)
    db $28,$33,$30,$2C,$54,$36     ; $5DF6  おたすけをっ
    db $99                         ; $5DFC  ！
    db $F7                         ; $5DFD  clear page
    db $F0                         ; $5DFE  end of message


; --------------------------------------------------------------------------
; Message #90 ($5DFF)
;   「このよで　わがしゅぞくが
;   もっとも　はんえいすること、。
;   「それが　わがのぞみ。
;   なにを　しにきたか　しらぬが、
;   「わが　いかりに　ふれるまえに
;   たちされ！！
; --------------------------------------------------------------------------
Bank69_Msg90:                              ; $5DFF  (file $115DFF)
    db $EA                         ; $5DFF  ▶ new page
    db $9F                         ; $5E00  box tag
    db $96                         ; $5E01  end name/box tag
    db $2D,$3D,$4C,$37,$8D         ; $5E02  このよて゛ = このよで
    db $90                         ; $5E07  　(space)
    db $53,$29,$8D,$2F,$4B,$32,$8D,$2B,$29,$8D; $5E08  わか゛しゅそ゛くか゛ = わがしゅぞくが
    db $EF,$EE                     ; $5E12  newline
    db $90,$90                     ; $5E14  　　(indent)
    db $47,$36,$38,$47             ; $5E16  もっとも
    db $90                         ; $5E1A  　(space)
    db $3E,$55,$27,$25,$30,$50,$2D,$38; $5E1B  はんえいすること
    db $A4                         ; $5E23  、
    db $8F                         ; $5E24  。
    db $FA                         ; $5E25  wait-for-button
    db $F7                         ; $5E26  clear page
    db $EF,$EE                     ; $5E27  newline
    db $9F                         ; $5E29  box tag
    db $96                         ; $5E2A  end name/box tag
    db $32,$51,$29,$8D             ; $5E2B  それか゛ = それが
    db $90                         ; $5E2F  　(space)
    db $53,$29,$8D,$3D,$32,$8D,$44 ; $5E30  わか゛のそ゛み = わがのぞみ
    db $8F                         ; $5E37  。
    db $EF,$EE                     ; $5E38  newline
    db $90,$90                     ; $5E3A  　　(indent)
    db $39,$3A,$54                 ; $5E3C  なにを
    db $90                         ; $5E3F  　(space)
    db $2F,$3A,$2A,$33,$29         ; $5E40  しにきたか
    db $90                         ; $5E45  　(space)
    db $2F,$4E,$3B,$29,$8D         ; $5E46  しらぬか゛ = しらぬが
    db $A4                         ; $5E4B  、
    db $FA                         ; $5E4C  wait-for-button
    db $F7                         ; $5E4D  clear page
    db $EF,$EE                     ; $5E4E  newline
    db $9F                         ; $5E50  box tag
    db $96                         ; $5E51  end name/box tag
    db $53,$29,$8D                 ; $5E52  わか゛ = わが
    db $90                         ; $5E55  　(space)
    db $25,$29,$4F,$3A             ; $5E56  いかりに
    db $90                         ; $5E5A  　(space)
    db $40,$51,$50,$43,$27,$3A     ; $5E5B  ふれるまえに
    db $EF,$EE                     ; $5E61  newline
    db $90,$90                     ; $5E63  　　(indent)
    db $33,$34,$2E,$51             ; $5E65  たちされ
    db $99                         ; $5E69  ！
    db $99                         ; $5E6A  ！
    db $F7                         ; $5E6B  clear page
    db $F0                         ; $5E6C  end of message


; --------------------------------------------------------------------------
; Message #91 ($5E6D)
;   「このよで　わがしゅぞくが
;   もっとも　はんえいすること、。
;   「それが　わがのぞみ。
;   きさま　わたしのタマゴを、、。
;   「わが　いかりに　ふれるまえに
;   たちされ！！
; --------------------------------------------------------------------------
Bank69_Msg91:                              ; $5E6D  (file $115E6D)
    db $EA                         ; $5E6D  ▶ new page
    db $9F                         ; $5E6E  box tag
    db $96                         ; $5E6F  end name/box tag
    db $2D,$3D,$4C,$37,$8D         ; $5E70  このよて゛ = このよで
    db $90                         ; $5E75  　(space)
    db $53,$29,$8D,$2F,$4B,$32,$8D,$2B,$29,$8D; $5E76  わか゛しゅそ゛くか゛ = わがしゅぞくが
    db $EF,$EE                     ; $5E80  newline
    db $90,$90                     ; $5E82  　　(indent)
    db $47,$36,$38,$47             ; $5E84  もっとも
    db $90                         ; $5E88  　(space)
    db $3E,$55,$27,$25,$30,$50,$2D,$38; $5E89  はんえいすること
    db $A4                         ; $5E91  、
    db $8F                         ; $5E92  。
    db $FA                         ; $5E93  wait-for-button
    db $F7                         ; $5E94  clear page
    db $EF,$EE                     ; $5E95  newline
    db $9F                         ; $5E97  box tag
    db $96                         ; $5E98  end name/box tag
    db $32,$51,$29,$8D             ; $5E99  それか゛ = それが
    db $90                         ; $5E9D  　(space)
    db $53,$29,$8D,$3D,$32,$8D,$44 ; $5E9E  わか゛のそ゛み = わがのぞみ
    db $8F                         ; $5EA5  。
    db $EF,$EE                     ; $5EA6  newline
    db $90,$90                     ; $5EA8  　　(indent)
    db $2A,$2E,$43                 ; $5EAA  きさま
    db $90                         ; $5EAD  　(space)
    db $53,$33,$2F,$3D,$6A,$7A,$64,$8D,$54; $5EAE  わたしのタマコ゛を = わたしのタマゴを
    db $A4                         ; $5EB7  、
    db $A4                         ; $5EB8  、
    db $8F                         ; $5EB9  。
    db $FA                         ; $5EBA  wait-for-button
    db $F7                         ; $5EBB  clear page
    db $EF,$EE                     ; $5EBC  newline
    db $9F                         ; $5EBE  box tag
    db $96                         ; $5EBF  end name/box tag
    db $53,$29,$8D                 ; $5EC0  わか゛ = わが
    db $90                         ; $5EC3  　(space)
    db $25,$29,$4F,$3A             ; $5EC4  いかりに
    db $90                         ; $5EC8  　(space)
    db $40,$51,$50,$43,$27,$3A     ; $5EC9  ふれるまえに
    db $EF,$EE                     ; $5ECF  newline
    db $90,$90                     ; $5ED1  　　(indent)
    db $33,$34,$2E,$51             ; $5ED3  たちされ
    db $99                         ; $5ED7  ！
    db $99                         ; $5ED8  ！
    db $F7                         ; $5ED9  clear page
    db $F0                         ; $5EDA  end of message


; --------------------------------------------------------------------------
; Message #92 ($5EDB)
;   「クソッ　ここにも　ないのか！！
; --------------------------------------------------------------------------
Bank69_Msg92:                              ; $5EDB  (file $115EDB)
    db $EA                         ; $5EDB  ▶ new page
    db $9F                         ; $5EDC  box tag
    db $96                         ; $5EDD  end name/box tag
    db $62,$69,$6D                 ; $5EDE  クソッ
    db $90                         ; $5EE1  　(space)
    db $2D,$2D,$3A,$47             ; $5EE2  ここにも
    db $90                         ; $5EE6  　(space)
    db $39,$25,$3D,$29             ; $5EE7  ないのか
    db $99                         ; $5EEB  ！
    db $99                         ; $5EEC  ！
    db $EF,$EE                     ; $5EED  newline
    db $F7                         ; $5EEF  clear page
    db $F0                         ; $5EF0  end of message


; --------------------------------------------------------------------------
; Message #93 ($5EF1)
;   「なんだ　おまえは？
;   、、まものつかいだな。
;   「フッ。　けんも　ろくに
;   あつかえない　こしぬけかっ！
; --------------------------------------------------------------------------
Bank69_Msg93:                              ; $5EF1  (file $115EF1)
    db $EA                         ; $5EF1  ▶ new page
    db $9F                         ; $5EF2  box tag
    db $96                         ; $5EF3  end name/box tag
    db $39,$55,$33,$8D             ; $5EF4  なんた゛ = なんだ
    db $90                         ; $5EF8  　(space)
    db $28,$43,$27,$3E             ; $5EF9  おまえは
    db $98                         ; $5EFD  ？
    db $EF,$EE                     ; $5EFE  newline
    db $90,$90                     ; $5F00  　　(indent)
    db $A4                         ; $5F02  、
    db $A4                         ; $5F03  、
    db $43,$47,$3D,$35,$29,$25,$33,$8D,$39; $5F04  まものつかいた゛な = まものつかいだな
    db $8F                         ; $5F0D  。
    db $FA                         ; $5F0E  wait-for-button
    db $F7                         ; $5F0F  clear page
    db $EF,$EE                     ; $5F10  newline
    db $9F                         ; $5F12  box tag
    db $96                         ; $5F13  end name/box tag
    db $77,$6D                     ; $5F14  フッ
    db $8F                         ; $5F16  。
    db $90                         ; $5F17  　(space)
    db $2C,$55,$47                 ; $5F18  けんも
    db $90                         ; $5F1B  　(space)
    db $52,$2B,$3A                 ; $5F1C  ろくに
    db $EF,$EE                     ; $5F1F  newline
    db $90,$90                     ; $5F21  　　(indent)
    db $24,$35,$29,$27,$39,$25     ; $5F23  あつかえない
    db $90                         ; $5F29  　(space)
    db $2D,$2F,$3B,$2C,$29,$36     ; $5F2A  こしぬけかっ
    db $99                         ; $5F30  ！
    db $F7                         ; $5F31  clear page
    db $F0                         ; $5F32  end of message


; --------------------------------------------------------------------------
; Message #94 ($5F33)
;   〈テリー〉は　タマゴを　しらべた。
;   なかから　まものが　あらわれた！
; --------------------------------------------------------------------------
Bank69_Msg94:                              ; $5F33  (file $115F33)
    db $F6                         ; $5F33  «insert hero name»
    db $3E                         ; $5F34  は
    db $90                         ; $5F35  　(space)
    db $6A,$7A,$64,$8D,$54         ; $5F36  タマコ゛を = タマゴを
    db $90                         ; $5F3B  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5F3C  しらへ゛た = しらべた
    db $8F                         ; $5F41  。
    db $EF,$EE                     ; $5F42  newline
    db $FA                         ; $5F44  wait-for-button
    db $F7                         ; $5F45  clear page
    db $EF,$EE                     ; $5F46  newline
    db $F3                         ; $5F48  open text box
    db $39,$29,$29,$4E             ; $5F49  なかから
    db $90                         ; $5F4D  　(space)
    db $43,$47,$3D,$29,$8D         ; $5F4E  まものか゛ = まものが
    db $90                         ; $5F53  　(space)
    db $24,$4E,$53,$51,$33         ; $5F54  あらわれた
    db $99                         ; $5F59  ！
    db $EF,$EE                     ; $5F5A  newline
    db $F7                         ; $5F5C  clear page
    db $F0                         ; $5F5D  end of message


; --------------------------------------------------------------------------
; Message #95 ($5F5E)
;   〈テリー〉は　タマゴを　しらべた。
;   タマゴは　われている。
; --------------------------------------------------------------------------
Bank69_Msg95:                              ; $5F5E  (file $115F5E)
    db $F6                         ; $5F5E  «insert hero name»
    db $3E                         ; $5F5F  は
    db $90                         ; $5F60  　(space)
    db $6A,$7A,$64,$8D,$54         ; $5F61  タマコ゛を = タマゴを
    db $90                         ; $5F66  　(space)
    db $2F,$4E,$41,$8D,$33         ; $5F67  しらへ゛た = しらべた
    db $8F                         ; $5F6C  。
    db $EF,$EE                     ; $5F6D  newline
    db $FA                         ; $5F6F  wait-for-button
    db $F7                         ; $5F70  clear page
    db $EF,$EE                     ; $5F71  newline
    db $F3                         ; $5F73  open text box
    db $6A,$7A,$64,$8D,$3E         ; $5F74  タマコ゛は = タマゴは
    db $90                         ; $5F79  　(space)
    db $53,$51,$37,$25,$50         ; $5F7A  われている
    db $8F                         ; $5F7F  。
    db $EF,$EE                     ; $5F80  newline
    db $F7                         ; $5F82  clear page
    db $F0                         ; $5F83  end of message


; --------------------------------------------------------------------------
; Message #96 ($5F84)
;   「ぬ[95][95]おお！！　だいじなタマゴを
;   すべて　わってしまうとは、、！！
;   「きさまの　なかまの　おこない
;   だんじてゆるさぬ！！！
; --------------------------------------------------------------------------
Bank69_Msg96:                              ; $5F84  (file $115F84)
    db $EA                         ; $5F84  ▶ new page
    db $9F                         ; $5F85  box tag
    db $96                         ; $5F86  end name/box tag
    db $3B                         ; $5F87  ぬ
    db $95                         ; $5F88  ctrl $95
    db $95                         ; $5F89  ctrl $95
    db $28,$28                     ; $5F8A  おお
    db $99                         ; $5F8C  ！
    db $99                         ; $5F8D  ！
    db $90                         ; $5F8E  　(space)
    db $33,$8D,$25,$2F,$8D,$39,$6A,$7A,$64,$8D,$54; $5F8F  た゛いし゛なタマコ゛を = だいじなタマゴを
    db $EF,$EE                     ; $5F9A  newline
    db $90,$90                     ; $5F9C  　　(indent)
    db $30,$41,$8D,$37             ; $5F9E  すへ゛て = すべて
    db $90                         ; $5FA2  　(space)
    db $53,$36,$37,$2F,$43,$26,$38,$3E; $5FA3  わってしまうとは
    db $A4                         ; $5FAB  、
    db $A4                         ; $5FAC  、
    db $99                         ; $5FAD  ！
    db $99                         ; $5FAE  ！
    db $FA                         ; $5FAF  wait-for-button
    db $F7                         ; $5FB0  clear page
    db $EF,$EE                     ; $5FB1  newline
    db $9F                         ; $5FB3  box tag
    db $96                         ; $5FB4  end name/box tag
    db $2A,$2E,$43,$3D             ; $5FB5  きさまの
    db $90                         ; $5FB9  　(space)
    db $39,$29,$43,$3D             ; $5FBA  なかまの
    db $90                         ; $5FBE  　(space)
    db $28,$2D,$39,$25             ; $5FBF  おこない
    db $EF,$EE                     ; $5FC3  newline
    db $90,$90                     ; $5FC5  　　(indent)
    db $33,$8D,$55,$2F,$8D,$37,$4A,$50,$2E,$3B; $5FC7  た゛んし゛てゆるさぬ = だんじてゆるさぬ
    db $99                         ; $5FD1  ！
    db $99                         ; $5FD2  ！
    db $99                         ; $5FD3  ！
    db $F7                         ; $5FD4  clear page
    db $F0                         ; $5FD5  end of message


; --------------------------------------------------------------------------
; Message #97 ($5FD6)
;   「また　おまえか！　わがこのうらみ
;   なんどでも　つぐなわせてやるわ！
; --------------------------------------------------------------------------
Bank69_Msg97:                              ; $5FD6  (file $115FD6)
    db $EA                         ; $5FD6  ▶ new page
    db $9F                         ; $5FD7  box tag
    db $96                         ; $5FD8  end name/box tag
    db $43,$33                     ; $5FD9  また
    db $90                         ; $5FDB  　(space)
    db $28,$43,$27,$29             ; $5FDC  おまえか
    db $99                         ; $5FE0  ！
    db $90                         ; $5FE1  　(space)
    db $53,$29,$8D,$2D,$3D,$26,$4E,$44; $5FE2  わか゛このうらみ = わがこのうらみ
    db $EF,$EE                     ; $5FEA  newline
    db $90,$90                     ; $5FEC  　　(indent)
    db $39,$55,$38,$8D,$37,$8D,$47 ; $5FEE  なんと゛て゛も = なんどでも
    db $90                         ; $5FF5  　(space)
    db $35,$2B,$8D,$39,$53,$31,$37,$48,$50,$53; $5FF6  つく゛なわせてやるわ = つぐなわせてやるわ
    db $99                         ; $6000  ！
    db $F7                         ; $6001  clear page
    db $F0                         ; $6002  end of message


; --------------------------------------------------------------------------
; Message #98 ($6003)
;   「あの　けんし、
;   おまえに　よく　にていた、。
; --------------------------------------------------------------------------
Bank69_Msg98:                              ; $6003  (file $116003)
    db $EA                         ; $6003  ▶ new page
    db $9F                         ; $6004  box tag
    db $96                         ; $6005  end name/box tag
    db $24,$3D                     ; $6006  あの
    db $90                         ; $6008  　(space)
    db $2C,$55,$2F                 ; $6009  けんし
    db $A4                         ; $600C  、
    db $EF,$EE                     ; $600D  newline
    db $90,$90                     ; $600F  　　(indent)
    db $28,$43,$27,$3A             ; $6011  おまえに
    db $90                         ; $6015  　(space)
    db $4C,$2B                     ; $6016  よく
    db $90                         ; $6018  　(space)
    db $3A,$37,$25,$33             ; $6019  にていた
    db $A4                         ; $601D  、
    db $8F                         ; $601E  。
    db $F7                         ; $601F  clear page
    db $F0                         ; $6020  end of message


; --------------------------------------------------------------------------
; Message #99 ($6021)
;   わたほ゛う「まもののかずが　ふえたのは
;   タマゴのせいだったんだね。
;   わたほ゛う「これで　おうさまの
;   たのみを　かいけつできたな！
;   わたほ゛う「さあ！　しろに　かえって
;   みんなに　ほうこくだ！！
; --------------------------------------------------------------------------
Bank69_Msg99:                              ; $6021  (file $116021)
    db $EB                         ; $6021  ▶ new page
    db $53,$33,$42,$8D,$26         ; $6022  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $6027  end name/box tag
    db $43,$47,$3D,$3D,$29,$30,$8D,$29,$8D; $6028  まもののかす゛か゛ = まもののかずが
    db $90                         ; $6031  　(space)
    db $40,$27,$33,$3D,$3E         ; $6032  ふえたのは
    db $EF,$EE                     ; $6037  newline
    db $90,$90                     ; $6039  　　(indent)
    db $6A,$7A,$64,$8D,$3D,$31,$25,$33,$8D,$36,$33,$55,$33,$8D,$3C; $603B  タマコ゛のせいた゛ったんた゛ね = タマゴのせいだったんだね
    db $8F                         ; $604A  。
    db $FA                         ; $604B  wait-for-button
    db $F7                         ; $604C  clear page
    db $EF,$EE                     ; $604D  newline
    db $53,$33,$42,$8D,$26         ; $604F  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $6054  end name/box tag
    db $2D,$51,$37,$8D             ; $6055  これて゛ = これで
    db $90                         ; $6059  　(space)
    db $28,$26,$2E,$43,$3D         ; $605A  おうさまの
    db $EF,$EE                     ; $605F  newline
    db $90,$90                     ; $6061  　　(indent)
    db $33,$3D,$44,$54             ; $6063  たのみを
    db $90                         ; $6067  　(space)
    db $29,$25,$2C,$35,$37,$8D,$2A,$33,$39; $6068  かいけつて゛きたな = かいけつできたな
    db $99                         ; $6071  ！
    db $FA                         ; $6072  wait-for-button
    db $F7                         ; $6073  clear page
    db $EF,$EE                     ; $6074  newline
    db $53,$33,$42,$8D,$26         ; $6076  わたほ゛う  (speaker: わたほ゛う)
    db $96                         ; $607B  end name/box tag
    db $2E,$24                     ; $607C  さあ
    db $99                         ; $607E  ！
    db $90                         ; $607F  　(space)
    db $2F,$52,$3A                 ; $6080  しろに
    db $90                         ; $6083  　(space)
    db $29,$27,$36,$37             ; $6084  かえって
    db $EF,$EE                     ; $6088  newline
    db $90,$90                     ; $608A  　　(indent)
    db $44,$55,$39,$3A             ; $608C  みんなに
    db $90                         ; $6090  　(space)
    db $42,$26,$2D,$2B,$33,$8D     ; $6091  ほうこくた゛ = ほうこくだ
    db $99                         ; $6097  ！
    db $99                         ; $6098  ！
    db $F7                         ; $6099  clear page
    db $F0                         ; $609A  end of message


; --------------------------------------------------------------------------
; Message #100 ($609B)
;   「はやく　わたしに　かてる
;   マスターに　なりなさい！
;   「、ぼうけんしていると　なぜか
;   しんぷさまに　よくあうわ。
;   「おちている　どうぐを　なるべく
;   ひろうように　しているからかな？
;   「、こんな　はなしでも　すこしは
;   さんこうに　なったかしら？
; --------------------------------------------------------------------------
Bank69_Msg100:                             ; $609B  (file $11609B)
    db $EB                         ; $609B  ▶ new page
    db $9F                         ; $609C  box tag
    db $96                         ; $609D  end name/box tag
    db $3E,$48,$2B                 ; $609E  はやく
    db $90                         ; $60A1  　(space)
    db $53,$33,$2F,$3A             ; $60A2  わたしに
    db $90                         ; $60A6  　(space)
    db $29,$37,$50                 ; $60A7  かてる
    db $EF,$EE                     ; $60AA  newline
    db $90,$90                     ; $60AC  　　(indent)
    db $7A,$67,$6A,$9C,$3A         ; $60AE  マスターに
    db $90                         ; $60B3  　(space)
    db $39,$4F,$39,$2E,$25         ; $60B4  なりなさい
    db $99                         ; $60B9  ！
    db $FA                         ; $60BA  wait-for-button
    db $F7                         ; $60BB  clear page
    db $EF,$EE                     ; $60BC  newline
    db $9F                         ; $60BE  box tag
    db $96                         ; $60BF  end name/box tag
    db $A4                         ; $60C0  、
    db $42,$8D,$26,$2C,$55,$2F,$37,$25,$50,$38; $60C1  ほ゛うけんしていると = ぼうけんしていると
    db $90                         ; $60CB  　(space)
    db $39,$31,$8D,$29             ; $60CC  なせ゛か = なぜか
    db $EF,$EE                     ; $60D0  newline
    db $90,$90                     ; $60D2  　　(indent)
    db $2F,$55,$40,$8E,$2E,$43,$3A ; $60D4  しんふ゜さまに = しんぷさまに
    db $90                         ; $60DB  　(space)
    db $4C,$2B,$24,$26,$53         ; $60DC  よくあうわ
    db $8F                         ; $60E1  。
    db $FA                         ; $60E2  wait-for-button
    db $F7                         ; $60E3  clear page
    db $EF,$EE                     ; $60E4  newline
    db $9F                         ; $60E6  box tag
    db $96                         ; $60E7  end name/box tag
    db $28,$34,$37,$25,$50         ; $60E8  おちている
    db $90                         ; $60ED  　(space)
    db $38,$8D,$26,$2B,$8D,$54     ; $60EE  と゛うく゛を = どうぐを
    db $90                         ; $60F4  　(space)
    db $39,$50,$41,$8D,$2B         ; $60F5  なるへ゛く = なるべく
    db $EF,$EE                     ; $60FA  newline
    db $90,$90                     ; $60FC  　　(indent)
    db $3F,$52,$26,$4C,$26,$3A     ; $60FE  ひろうように
    db $90                         ; $6104  　(space)
    db $2F,$37,$25,$50,$29,$4E,$29,$39; $6105  しているからかな
    db $98                         ; $610D  ？
    db $FA                         ; $610E  wait-for-button
    db $F7                         ; $610F  clear page
    db $EF,$EE                     ; $6110  newline
    db $9F                         ; $6112  box tag
    db $96                         ; $6113  end name/box tag
    db $A4                         ; $6114  、
    db $2D,$55,$39                 ; $6115  こんな
    db $90                         ; $6118  　(space)
    db $3E,$39,$2F,$37,$8D,$47     ; $6119  はなして゛も = はなしでも
    db $90                         ; $611F  　(space)
    db $30,$2D,$2F,$3E             ; $6120  すこしは
    db $EF,$EE                     ; $6124  newline
    db $90,$90                     ; $6126  　　(indent)
    db $2E,$55,$2D,$26,$3A         ; $6128  さんこうに
    db $90                         ; $612D  　(space)
    db $39,$36,$33,$29,$2F,$4E     ; $612E  なったかしら
    db $98                         ; $6134  ？
    db $F7                         ; $6135  clear page
    db $F0                         ; $6136  end of message


; --------------------------------------------------------------------------
; Message #101 ($6137)
;   おう「おお　〈テリー〉よ！！
;   よくぞ　かえった！
;   おう「そなたのはたらき　すでに
;   ききおよんでおる。　ごくろう！
;   おう「！！　、、、むむ！
; --------------------------------------------------------------------------
Bank69_Msg101:                             ; $6137  (file $116137)
    db $EA                         ; $6137  ▶ new page
    db $28,$26                     ; $6138  おう  (speaker: おう)
    db $96                         ; $613A  end name/box tag
    db $28,$28                     ; $613B  おお
    db $90                         ; $613D  　(space)
    db $F6                         ; $613E  «insert hero name»
    db $4C                         ; $613F  よ
    db $99                         ; $6140  ！
    db $99                         ; $6141  ！
    db $EF,$EE                     ; $6142  newline
    db $90,$90                     ; $6144  　　(indent)
    db $4C,$2B,$32,$8D             ; $6146  よくそ゛ = よくぞ
    db $90                         ; $614A  　(space)
    db $29,$27,$36,$33             ; $614B  かえった
    db $99                         ; $614F  ！
    db $FA                         ; $6150  wait-for-button
    db $F7                         ; $6151  clear page
    db $EF,$EE                     ; $6152  newline
    db $28,$26                     ; $6154  おう  (speaker: おう)
    db $96                         ; $6156  end name/box tag
    db $32,$39,$33,$3D,$3E,$33,$4E,$2A; $6157  そなたのはたらき
    db $90                         ; $615F  　(space)
    db $30,$37,$8D,$3A             ; $6160  すて゛に = すでに
    db $EF,$EE                     ; $6164  newline
    db $90,$90                     ; $6166  　　(indent)
    db $2A,$2A,$28,$4C,$55,$37,$8D,$28,$50; $6168  ききおよんて゛おる = ききおよんでおる
    db $8F                         ; $6171  。
    db $90                         ; $6172  　(space)
    db $2D,$8D,$2B,$52,$26         ; $6173  こ゛くろう = ごくろう
    db $99                         ; $6178  ！
    db $FA                         ; $6179  wait-for-button
    db $F7                         ; $617A  clear page
    db $EF,$EE                     ; $617B  newline
    db $28,$26                     ; $617D  おう  (speaker: おう)
    db $96                         ; $617F  end name/box tag
    db $99                         ; $6180  ！
    db $99                         ; $6181  ！
    db $90                         ; $6182  　(space)
    db $A4                         ; $6183  、
    db $A4                         ; $6184  、
    db $A4                         ; $6185  、
    db $45,$45                     ; $6186  むむ
    db $99                         ; $6188  ！
    db $EF,$EE                     ; $6189  newline
    db $F7                         ; $618B  clear page
    db $F0                         ; $618C  end of message


; --------------------------------------------------------------------------
; Message #102 ($618D)
;   「お[95]、　このくには　せいきに
;   みちておるのう、、。
;   「ほしふりのよるが　ちかいゆえ
;   みな　いきいきとしておる、、。
;   「、うらやましい　かぎりじゃのう。
;   わしのくには　かれておるゆえ、。
;   「しかし　かれてこそ　みえる
;   うつくしさも　あるというもの。
;   「よく　みれば　このくには
;   うかれすぎてるようにも　みえる。
;   「だれも　かれも　ちに　あしが
;   ついていないと　いうか、、
; --------------------------------------------------------------------------
Bank69_Msg102:                             ; $618D  (file $11618D)
    db $EA                         ; $618D  ▶ new page
    db $9F                         ; $618E  box tag
    db $96                         ; $618F  end name/box tag
    db $28                         ; $6190  お
    db $95                         ; $6191  ctrl $95
    db $A4                         ; $6192  、
    db $90                         ; $6193  　(space)
    db $2D,$3D,$2B,$3A,$3E         ; $6194  このくには
    db $90                         ; $6199  　(space)
    db $31,$25,$2A,$3A             ; $619A  せいきに
    db $EF,$EE                     ; $619E  newline
    db $90,$90                     ; $61A0  　　(indent)
    db $44,$34,$37,$28,$50,$3D,$26 ; $61A2  みちておるのう
    db $A4                         ; $61A9  、
    db $A4                         ; $61AA  、
    db $8F                         ; $61AB  。
    db $FA                         ; $61AC  wait-for-button
    db $F7                         ; $61AD  clear page
    db $EF,$EE                     ; $61AE  newline
    db $9F                         ; $61B0  box tag
    db $96                         ; $61B1  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$29,$8D; $61B2  ほしふりのよるか゛ = ほしふりのよるが
    db $90                         ; $61BB  　(space)
    db $34,$29,$25,$4A,$27         ; $61BC  ちかいゆえ
    db $EF,$EE                     ; $61C1  newline
    db $90,$90                     ; $61C3  　　(indent)
    db $44,$39                     ; $61C5  みな
    db $90                         ; $61C7  　(space)
    db $25,$2A,$25,$2A,$38,$2F,$37,$28,$50; $61C8  いきいきとしておる
    db $A4                         ; $61D1  、
    db $A4                         ; $61D2  、
    db $8F                         ; $61D3  。
    db $FA                         ; $61D4  wait-for-button
    db $F7                         ; $61D5  clear page
    db $EF,$EE                     ; $61D6  newline
    db $9F                         ; $61D8  box tag
    db $96                         ; $61D9  end name/box tag
    db $A4                         ; $61DA  、
    db $26,$4E,$48,$43,$2F,$25     ; $61DB  うらやましい
    db $90                         ; $61E1  　(space)
    db $29,$2A,$8D,$4F,$2F,$8D,$49,$3D,$26; $61E2  かき゛りし゛ゃのう = かぎりじゃのう
    db $8F                         ; $61EB  。
    db $EF,$EE                     ; $61EC  newline
    db $90,$90                     ; $61EE  　　(indent)
    db $53,$2F,$3D,$2B,$3A,$3E     ; $61F0  わしのくには
    db $90                         ; $61F6  　(space)
    db $29,$51,$37,$28,$50,$4A,$27 ; $61F7  かれておるゆえ
    db $A4                         ; $61FE  、
    db $8F                         ; $61FF  。
    db $FA                         ; $6200  wait-for-button
    db $F7                         ; $6201  clear page
    db $EF,$EE                     ; $6202  newline
    db $9F                         ; $6204  box tag
    db $96                         ; $6205  end name/box tag
    db $2F,$29,$2F                 ; $6206  しかし
    db $90                         ; $6209  　(space)
    db $29,$51,$37,$2D,$32         ; $620A  かれてこそ
    db $90                         ; $620F  　(space)
    db $44,$27,$50                 ; $6210  みえる
    db $EF,$EE                     ; $6213  newline
    db $90,$90                     ; $6215  　　(indent)
    db $26,$35,$2B,$2F,$2E,$47     ; $6217  うつくしさも
    db $90                         ; $621D  　(space)
    db $24,$50,$38,$25,$26,$47,$3D ; $621E  あるというもの
    db $8F                         ; $6225  。
    db $FA                         ; $6226  wait-for-button
    db $F7                         ; $6227  clear page
    db $EF,$EE                     ; $6228  newline
    db $9F                         ; $622A  box tag
    db $96                         ; $622B  end name/box tag
    db $4C,$2B                     ; $622C  よく
    db $90                         ; $622E  　(space)
    db $44,$51,$3E,$8D             ; $622F  みれは゛ = みれば
    db $90                         ; $6233  　(space)
    db $2D,$3D,$2B,$3A,$3E         ; $6234  このくには
    db $EF,$EE                     ; $6239  newline
    db $90,$90                     ; $623B  　　(indent)
    db $26,$29,$51,$30,$2A,$8D,$37,$50,$4C,$26,$3A,$47; $623D  うかれすき゛てるようにも = うかれすぎてるようにも
    db $90                         ; $6249  　(space)
    db $44,$27,$50                 ; $624A  みえる
    db $8F                         ; $624D  。
    db $FA                         ; $624E  wait-for-button
    db $F7                         ; $624F  clear page
    db $EF,$EE                     ; $6250  newline
    db $9F                         ; $6252  box tag
    db $96                         ; $6253  end name/box tag
    db $33,$8D,$51,$47             ; $6254  た゛れも = だれも
    db $90                         ; $6258  　(space)
    db $29,$51,$47                 ; $6259  かれも
    db $90                         ; $625C  　(space)
    db $34,$3A                     ; $625D  ちに
    db $90                         ; $625F  　(space)
    db $24,$2F,$29,$8D             ; $6260  あしか゛ = あしが
    db $EF,$EE                     ; $6264  newline
    db $90,$90                     ; $6266  　　(indent)
    db $35,$25,$37,$25,$39,$25,$38 ; $6268  ついていないと
    db $90                         ; $626F  　(space)
    db $25,$26,$29                 ; $6270  いうか
    db $A4                         ; $6273  、
    db $A4                         ; $6274  、
    db $F7                         ; $6275  clear page
    db $F0                         ; $6276  end of message


; --------------------------------------------------------------------------
; Message #103 ($6277)
;   「そなたは　とくに　うかれて
;   いるようじゃな。たびげいにんか？
;   「わしゃカレキのくにの　おうじゃ。
;   みなを　たのしませるのだぞ！
; --------------------------------------------------------------------------
Bank69_Msg103:                             ; $6277  (file $116277)
    db $EA                         ; $6277  ▶ new page
    db $9F                         ; $6278  box tag
    db $96                         ; $6279  end name/box tag
    db $32,$39,$33,$3E             ; $627A  そなたは
    db $90                         ; $627E  　(space)
    db $38,$2B,$3A                 ; $627F  とくに
    db $90                         ; $6282  　(space)
    db $26,$29,$51,$37             ; $6283  うかれて
    db $EF,$EE                     ; $6287  newline
    db $90,$90                     ; $6289  　　(indent)
    db $25,$50,$4C,$26,$2F,$8D,$49,$39; $628B  いるようし゛ゃな = いるようじゃな
    db $8F                         ; $6293  。
    db $33,$3F,$8D,$2C,$8D,$25,$3A,$55,$29; $6294  たひ゛け゛いにんか = たびげいにんか
    db $98                         ; $629D  ？
    db $FA                         ; $629E  wait-for-button
    db $F7                         ; $629F  clear page
    db $EF,$EE                     ; $62A0  newline
    db $9F                         ; $62A2  box tag
    db $96                         ; $62A3  end name/box tag
    db $53,$2F,$49,$60,$88,$61,$3D,$2B,$3A,$3D; $62A4  わしゃカレキのくにの
    db $90                         ; $62AE  　(space)
    db $28,$26,$2F,$8D,$49         ; $62AF  おうし゛ゃ = おうじゃ
    db $8F                         ; $62B4  。
    db $EF,$EE                     ; $62B5  newline
    db $90,$90                     ; $62B7  　　(indent)
    db $44,$39,$54                 ; $62B9  みなを
    db $90                         ; $62BC  　(space)
    db $33,$3D,$2F,$43,$31,$50,$3D,$33,$8D,$32,$8D; $62BD  たのしませるのた゛そ゛ = たのしませるのだぞ
    db $99                         ; $62C8  ！
    db $F7                         ; $62C9  clear page
    db $F0                         ; $62CA  end of message


; --------------------------------------------------------------------------
; Message #104 ($62CB)
;   カレキおう「、タィジャおうよ。
;   はよう　マスターを　みつけねば！
;   カレキおう「それとも　こんかいは
;   ださぬのかの？　フオッ、フオッ。
; --------------------------------------------------------------------------
Bank69_Msg104:                             ; $62CB  (file $1162CB)
    db $EA                         ; $62CB  ▶ new page
    db $60,$88,$61,$28,$26         ; $62CC  カレキおう
    db $96                         ; $62D1  end name/box tag
    db $A4                         ; $62D2  、
    db $6A,$58,$66,$8D,$82,$28,$26,$4C; $62D3  タィシ゛ャおうよ = タィジャおうよ
    db $8F                         ; $62DB  。
    db $EF,$EE                     ; $62DC  newline
    db $90,$90                     ; $62DE  　　(indent)
    db $3E,$4C,$26                 ; $62E0  はよう
    db $90                         ; $62E3  　(space)
    db $7A,$67,$6A,$9C,$54         ; $62E4  マスターを
    db $90                         ; $62E9  　(space)
    db $44,$35,$2C,$3C,$3E,$8D     ; $62EA  みつけねは゛ = みつけねば
    db $99                         ; $62F0  ！
    db $FA                         ; $62F1  wait-for-button
    db $F7                         ; $62F2  clear page
    db $EF,$EE                     ; $62F3  newline
    db $60,$88,$61,$28,$26         ; $62F5  カレキおう
    db $96                         ; $62FA  end name/box tag
    db $32,$51,$38,$47             ; $62FB  それとも
    db $90                         ; $62FF  　(space)
    db $2D,$55,$29,$25,$3E         ; $6300  こんかいは
    db $EF,$EE                     ; $6305  newline
    db $90,$90                     ; $6307  　　(indent)
    db $33,$8D,$2E,$3B,$3D,$29,$3D ; $6309  た゛さぬのかの = ださぬのかの
    db $98                         ; $6310  ？
    db $90                         ; $6311  　(space)
    db $77,$5F,$6D                 ; $6312  フオッ
    db $A4                         ; $6315  、
    db $77,$5F,$6D                 ; $6316  フオッ
    db $8F                         ; $6319  。
    db $F7                         ; $631A  clear page
    db $F0                         ; $631B  end of message


; --------------------------------------------------------------------------
; Message #105 ($631C)
;   おう「カレキめ　いまにみておれ。
;   こんかいこそは　かならず、！
;   おう「、、〈テリー〉よ。
;   とんだ　じゃまが　はいったな。
;   おう「じゃが　よくぞ
;   かえってきてくれた！
;   おう「たいりょうの　タマゴを
;   いっしゅんで　けしさったそうな。
;   おう「さすがは　〈テリー〉。
;   やることが　ごうかいじゃのう！
;   おう「さあ！　〈テリー〉よ。　こんごは
;   [0C]クラスいじょうをうけるがいい。
;   おう「[1C]クラスをかちぬけば　そなたは
;   わがくにの　だいひょうじゃ！
;   おう「きたいしておるぞ。
;   〈テリー〉！
;   おう「それでは　わしは　しごとが
;   あるので　これで　しつれいする。
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank69_Msg105:                             ; $631C  (file $11631C)
    db $EA                         ; $631C  ▶ new page
    db $28,$26                     ; $631D  おう  (speaker: おう)
    db $96                         ; $631F  end name/box tag
    db $60,$88,$61,$46             ; $6320  カレキめ
    db $90                         ; $6324  　(space)
    db $25,$43,$3A,$44,$37,$28,$51 ; $6325  いまにみておれ
    db $8F                         ; $632C  。
    db $EF,$EE                     ; $632D  newline
    db $90,$90                     ; $632F  　　(indent)
    db $2D,$55,$29,$25,$2D,$32,$3E ; $6331  こんかいこそは
    db $90                         ; $6338  　(space)
    db $29,$39,$4E,$30,$8D         ; $6339  かならす゛ = かならず
    db $A4                         ; $633E  、
    db $99                         ; $633F  ！
    db $FA                         ; $6340  wait-for-button
    db $F7                         ; $6341  clear page
    db $EF,$EE                     ; $6342  newline
    db $28,$26                     ; $6344  おう  (speaker: おう)
    db $96                         ; $6346  end name/box tag
    db $A4                         ; $6347  、
    db $A4                         ; $6348  、
    db $F6                         ; $6349  «insert hero name»
    db $4C                         ; $634A  よ
    db $8F                         ; $634B  。
    db $EF,$EE                     ; $634C  newline
    db $90,$90                     ; $634E  　　(indent)
    db $38,$55,$33,$8D             ; $6350  とんた゛ = とんだ
    db $90                         ; $6354  　(space)
    db $2F,$8D,$49,$43,$29,$8D     ; $6355  し゛ゃまか゛ = じゃまが
    db $90                         ; $635B  　(space)
    db $3E,$25,$36,$33,$39         ; $635C  はいったな
    db $8F                         ; $6361  。
    db $FA                         ; $6362  wait-for-button
    db $F7                         ; $6363  clear page
    db $EF,$EE                     ; $6364  newline
    db $28,$26                     ; $6366  おう  (speaker: おう)
    db $96                         ; $6368  end name/box tag
    db $2F,$8D,$49,$29,$8D         ; $6369  し゛ゃか゛ = じゃが
    db $90                         ; $636E  　(space)
    db $4C,$2B,$32,$8D             ; $636F  よくそ゛ = よくぞ
    db $EF,$EE                     ; $6373  newline
    db $90,$90                     ; $6375  　　(indent)
    db $29,$27,$36,$37,$2A,$37,$2B,$51,$33; $6377  かえってきてくれた
    db $99                         ; $6380  ！
    db $FA                         ; $6381  wait-for-button
    db $F7                         ; $6382  clear page
    db $EF,$EE                     ; $6383  newline
    db $28,$26                     ; $6385  おう  (speaker: おう)
    db $96                         ; $6387  end name/box tag
    db $33,$25,$4F,$4D,$26,$3D     ; $6388  たいりょうの
    db $90                         ; $638E  　(space)
    db $6A,$7A,$64,$8D,$54         ; $638F  タマコ゛を = タマゴを
    db $EF,$EE                     ; $6394  newline
    db $90,$90                     ; $6396  　　(indent)
    db $25,$36,$2F,$4B,$55,$37,$8D ; $6398  いっしゅんて゛ = いっしゅんで
    db $90                         ; $639F  　(space)
    db $2C,$2F,$2E,$36,$33,$32,$26,$39; $63A0  けしさったそうな
    db $8F                         ; $63A8  。
    db $FA                         ; $63A9  wait-for-button
    db $F7                         ; $63AA  clear page
    db $EF,$EE                     ; $63AB  newline
    db $28,$26                     ; $63AD  おう  (speaker: おう)
    db $96                         ; $63AF  end name/box tag
    db $2E,$30,$29,$8D,$3E         ; $63B0  さすか゛は = さすがは
    db $90                         ; $63B5  　(space)
    db $F6                         ; $63B6  «insert hero name»
    db $8F                         ; $63B7  。
    db $EF,$EE                     ; $63B8  newline
    db $90,$90                     ; $63BA  　　(indent)
    db $48,$50,$2D,$38,$29,$8D     ; $63BC  やることか゛ = やることが
    db $90                         ; $63C2  　(space)
    db $2D,$8D,$26,$29,$25,$2F,$8D,$49,$3D,$26; $63C3  こ゛うかいし゛ゃのう = ごうかいじゃのう
    db $99                         ; $63CD  ！
    db $FA                         ; $63CE  wait-for-button
    db $F7                         ; $63CF  clear page
    db $EF,$EE                     ; $63D0  newline
    db $28,$26                     ; $63D2  おう  (speaker: おう)
    db $96                         ; $63D4  end name/box tag
    db $2E,$24                     ; $63D5  さあ
    db $99                         ; $63D7  ！
    db $90                         ; $63D8  　(space)
    db $F6                         ; $63D9  «insert hero name»
    db $4C                         ; $63DA  よ
    db $8F                         ; $63DB  。
    db $90                         ; $63DC  　(space)
    db $2D,$55,$2D,$8D,$3E         ; $63DD  こんこ゛は = こんごは
    db $EF,$EE                     ; $63E2  newline
    db $90,$90                     ; $63E4  　　(indent)
    db $0C                         ; $63E6  ctrl $0C
    db $62,$85,$67,$25,$2F,$8D,$4D,$26,$54,$26,$2C,$50,$29,$8D,$25,$25; $63E7  クラスいし゛ょうをうけるか゛いい = クラスいじょうをうけるがいい
    db $8F                         ; $63F7  。
    db $FA                         ; $63F8  wait-for-button
    db $F7                         ; $63F9  clear page
    db $EF,$EE                     ; $63FA  newline
    db $28,$26                     ; $63FC  おう  (speaker: おう)
    db $96                         ; $63FE  end name/box tag
    db $1C                         ; $63FF  ctrl $1C
    db $62,$85,$67,$54,$29,$34,$3B,$2C,$3E,$8D; $6400  クラスをかちぬけは゛ = クラスをかちぬけば
    db $90                         ; $640A  　(space)
    db $32,$39,$33,$3E             ; $640B  そなたは
    db $EF,$EE                     ; $640F  newline
    db $90,$90                     ; $6411  　　(indent)
    db $53,$29,$8D,$2B,$3A,$3D     ; $6413  わか゛くにの = わがくにの
    db $90                         ; $6419  　(space)
    db $33,$8D,$25,$3F,$4D,$26,$2F,$8D,$49; $641A  た゛いひょうし゛ゃ = だいひょうじゃ
    db $99                         ; $6423  ！
    db $FA                         ; $6424  wait-for-button
    db $F7                         ; $6425  clear page
    db $EF,$EE                     ; $6426  newline
    db $28,$26                     ; $6428  おう  (speaker: おう)
    db $96                         ; $642A  end name/box tag
    db $2A,$33,$25,$2F,$37,$28,$50,$32,$8D; $642B  きたいしておるそ゛ = きたいしておるぞ
    db $8F                         ; $6434  。
    db $EF,$EE                     ; $6435  newline
    db $90,$90                     ; $6437  　　(indent)
    db $F6                         ; $6439  «insert hero name»
    db $99                         ; $643A  ！
    db $FA                         ; $643B  wait-for-button
    db $F7                         ; $643C  clear page
    db $EF,$EE                     ; $643D  newline
    db $28,$26                     ; $643F  おう  (speaker: おう)
    db $96                         ; $6441  end name/box tag
    db $32,$51,$37,$8D,$3E         ; $6442  それて゛は = それでは
    db $90                         ; $6447  　(space)
    db $53,$2F,$3E                 ; $6448  わしは
    db $90                         ; $644B  　(space)
    db $2F,$2D,$8D,$38,$29,$8D     ; $644C  しこ゛とか゛ = しごとが
    db $EF,$EE                     ; $6452  newline
    db $90,$90                     ; $6454  　　(indent)
    db $24,$50,$3D,$37,$8D         ; $6456  あるのて゛ = あるので
    db $90                         ; $645B  　(space)
    db $2D,$51,$37,$8D             ; $645C  これて゛ = これで
    db $90                         ; $6460  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $6461  しつれいする
    db $8F                         ; $6467  。
    db $FA                         ; $6468  wait-for-button
    db $F7                         ; $6469  clear page
    db $EF,$EE                     ; $646A  newline
    db $28,$26                     ; $646C  おう  (speaker: おう)
    db $96                         ; $646E  end name/box tag
    db $58,$69                     ; $646F  ィソ
    db $90                         ; $6471  　(space)
    db $58,$69                     ; $6472  ィソ
    db $A4                         ; $6474  、
    db $90                         ; $6475  　(space)
    db $58,$69                     ; $6476  ィソ
    db $90                         ; $6478  　(space)
    db $58,$69                     ; $6479  ィソ
    db $A4                         ; $647B  、
    db $A4                         ; $647C  、
    db $8F                         ; $647D  。
    db $EF,$EE                     ; $647E  newline
    db $F7                         ; $6480  clear page
    db $F0                         ; $6481  end of message


; --------------------------------------------------------------------------
; Message #106 ($6482)
;   「いまの　ゆれは　タィジャが
;   せいちょうしている　あかしです。
;   「あちこちで　ちけいが
;   へんかしている　ことでしょうぞ。
; --------------------------------------------------------------------------
Bank69_Msg106:                             ; $6482  (file $116482)
    db $EA                         ; $6482  ▶ new page
    db $9F                         ; $6483  box tag
    db $96                         ; $6484  end name/box tag
    db $25,$43,$3D                 ; $6485  いまの
    db $90                         ; $6488  　(space)
    db $4A,$51,$3E                 ; $6489  ゆれは
    db $90                         ; $648C  　(space)
    db $6A,$58,$66,$8D,$82,$29,$8D ; $648D  タィシ゛ャか゛ = タィジャが
    db $EF,$EE                     ; $6494  newline
    db $90,$90                     ; $6496  　　(indent)
    db $31,$25,$34,$4D,$26,$2F,$37,$25,$50; $6498  せいちょうしている
    db $90                         ; $64A1  　(space)
    db $24,$29,$2F,$37,$8D,$30     ; $64A2  あかして゛す = あかしです
    db $8F                         ; $64A8  。
    db $FA                         ; $64A9  wait-for-button
    db $F7                         ; $64AA  clear page
    db $EF,$EE                     ; $64AB  newline
    db $9F                         ; $64AD  box tag
    db $96                         ; $64AE  end name/box tag
    db $24,$34,$2D,$34,$37,$8D     ; $64AF  あちこちて゛ = あちこちで
    db $90                         ; $64B5  　(space)
    db $34,$2C,$25,$29,$8D         ; $64B6  ちけいか゛ = ちけいが
    db $EF,$EE                     ; $64BB  newline
    db $90,$90                     ; $64BD  　　(indent)
    db $41,$55,$29,$2F,$37,$25,$50 ; $64BF  へんかしている
    db $90                         ; $64C6  　(space)
    db $2D,$38,$37,$8D,$2F,$4D,$26,$32,$8D; $64C7  ことて゛しょうそ゛ = ことでしょうぞ
    db $8F                         ; $64D0  。
    db $F7                         ; $64D1  clear page
    db $F0                         ; $64D2  end of message


; --------------------------------------------------------------------------
; Message #107 ($64D3)
;   「タィジャの　しんどうにより
;   ちけいが　へんかしていますぞ。
;   「あたらしく　いけるようになった
;   ばしょも　あるはず！
;   「くにのものたちと　はなすことも
;   たまには　たいせつですな！
; --------------------------------------------------------------------------
Bank69_Msg107:                             ; $64D3  (file $1164D3)
    db $EA                         ; $64D3  ▶ new page
    db $9F                         ; $64D4  box tag
    db $96                         ; $64D5  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D     ; $64D6  タィシ゛ャの = タィジャの
    db $90                         ; $64DC  　(space)
    db $2F,$55,$38,$8D,$26,$3A,$4C,$4F; $64DD  しんと゛うにより = しんどうにより
    db $EF,$EE                     ; $64E5  newline
    db $90,$90                     ; $64E7  　　(indent)
    db $34,$2C,$25,$29,$8D         ; $64E9  ちけいか゛ = ちけいが
    db $90                         ; $64EE  　(space)
    db $41,$55,$29,$2F,$37,$25,$43,$30,$32,$8D; $64EF  へんかしていますそ゛ = へんかしていますぞ
    db $8F                         ; $64F9  。
    db $FA                         ; $64FA  wait-for-button
    db $F7                         ; $64FB  clear page
    db $EF,$EE                     ; $64FC  newline
    db $9F                         ; $64FE  box tag
    db $96                         ; $64FF  end name/box tag
    db $24,$33,$4E,$2F,$2B         ; $6500  あたらしく
    db $90                         ; $6505  　(space)
    db $25,$2C,$50,$4C,$26,$3A,$39,$36,$33; $6506  いけるようになった
    db $EF,$EE                     ; $650F  newline
    db $90,$90                     ; $6511  　　(indent)
    db $3E,$8D,$2F,$4D,$47         ; $6513  は゛しょも = ばしょも
    db $90                         ; $6518  　(space)
    db $24,$50,$3E,$30,$8D         ; $6519  あるはす゛ = あるはず
    db $99                         ; $651E  ！
    db $FA                         ; $651F  wait-for-button
    db $F7                         ; $6520  clear page
    db $EF,$EE                     ; $6521  newline
    db $9F                         ; $6523  box tag
    db $96                         ; $6524  end name/box tag
    db $2B,$3A,$3D,$47,$3D,$33,$34,$38; $6525  くにのものたちと
    db $90                         ; $652D  　(space)
    db $3E,$39,$30,$2D,$38,$47     ; $652E  はなすことも
    db $EF,$EE                     ; $6534  newline
    db $90,$90                     ; $6536  　　(indent)
    db $33,$43,$3A,$3E             ; $6538  たまには
    db $90                         ; $653C  　(space)
    db $33,$25,$31,$35,$37,$8D,$30,$39; $653D  たいせつて゛すな = たいせつですな
    db $99                         ; $6545  ！
    db $F7                         ; $6546  clear page
    db $F0                         ; $6547  end of message


; --------------------------------------------------------------------------
; Message #108 ($6548)
;   「いかりの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg108:                             ; $6548  (file $116548)
    db $EB                         ; $6548  ▶ new page
    db $9F                         ; $6549  box tag
    db $96                         ; $654A  end name/box tag
    db $25,$29,$4F,$3D             ; $654B  いかりの
    db $90                         ; $654F  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $6550  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $6558  newline
    db $90,$90                     ; $655A  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $655C  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $6567  ？
    db $FF                         ; $6568  はい/いいえ
    db $F0                         ; $6569  end of message


; --------------------------------------------------------------------------
; Message #109 ($656A)
;   「ゆうしゃは　むすうの　タマゴを
;   いっしゅんで　けしさった！
;   「、どうですか？　いまのは
;   〈テリー〉さんの　でんせつですよ！
; --------------------------------------------------------------------------
Bank69_Msg109:                             ; $656A  (file $11656A)
    db $EB                         ; $656A  ▶ new page
    db $9F                         ; $656B  box tag
    db $96                         ; $656C  end name/box tag
    db $4A,$26,$2F,$49,$3E         ; $656D  ゆうしゃは
    db $90                         ; $6572  　(space)
    db $45,$30,$26,$3D             ; $6573  むすうの
    db $90                         ; $6577  　(space)
    db $6A,$7A,$64,$8D,$54         ; $6578  タマコ゛を = タマゴを
    db $EF,$EE                     ; $657D  newline
    db $90,$90                     ; $657F  　　(indent)
    db $25,$36,$2F,$4B,$55,$37,$8D ; $6581  いっしゅんて゛ = いっしゅんで
    db $90                         ; $6588  　(space)
    db $2C,$2F,$2E,$36,$33         ; $6589  けしさった
    db $99                         ; $658E  ！
    db $FA                         ; $658F  wait-for-button
    db $F7                         ; $6590  clear page
    db $EF,$EE                     ; $6591  newline
    db $9F                         ; $6593  box tag
    db $96                         ; $6594  end name/box tag
    db $A4                         ; $6595  、
    db $38,$8D,$26,$37,$8D,$30,$29 ; $6596  と゛うて゛すか = どうですか
    db $98                         ; $659D  ？
    db $90                         ; $659E  　(space)
    db $25,$43,$3D,$3E             ; $659F  いまのは
    db $EF,$EE                     ; $65A3  newline
    db $90,$90                     ; $65A5  　　(indent)
    db $F6                         ; $65A7  «insert hero name»
    db $2E,$55,$3D                 ; $65A8  さんの
    db $90                         ; $65AB  　(space)
    db $37,$8D,$55,$31,$35,$37,$8D,$30,$4C; $65AC  て゛んせつて゛すよ = でんせつですよ
    db $99                         ; $65B5  ！
    db $F7                         ; $65B6  clear page
    db $F0                         ; $65B7  end of message


; --------------------------------------------------------------------------
; Message #110 ($65B8)
;   「ちからの　とびらのことは
;   ごぞんじですか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg110:                             ; $65B8  (file $1165B8)
    db $EB                         ; $65B8  ▶ new page
    db $9F                         ; $65B9  box tag
    db $96                         ; $65BA  end name/box tag
    db $34,$29,$4E,$3D             ; $65BB  ちからの
    db $90                         ; $65BF  　(space)
    db $38,$3F,$8D,$4E,$3D,$2D,$38,$3E; $65C0  とひ゛らのことは = とびらのことは
    db $EF,$EE                     ; $65C8  newline
    db $90,$90                     ; $65CA  　　(indent)
    db $2D,$8D,$32,$8D,$55,$2F,$8D,$37,$8D,$30,$29; $65CC  こ゛そ゛んし゛て゛すか = ごぞんじですか
    db $98                         ; $65D7  ？
    db $FF                         ; $65D8  はい/いいえ
    db $F0                         ; $65D9  end of message


; --------------------------------------------------------------------------
; Message #111 ($65DA)
;   「ふりかえると　、、、！
;   せきぞうが　うごいていた。
;   「あるぼうけんで　いきのびた
;   おとこの　ことばです。
; --------------------------------------------------------------------------
Bank69_Msg111:                             ; $65DA  (file $1165DA)
    db $EB                         ; $65DA  ▶ new page
    db $9F                         ; $65DB  box tag
    db $96                         ; $65DC  end name/box tag
    db $40,$4F,$29,$27,$50,$38     ; $65DD  ふりかえると
    db $90                         ; $65E3  　(space)
    db $A4                         ; $65E4  、
    db $A4                         ; $65E5  、
    db $A4                         ; $65E6  、
    db $99                         ; $65E7  ！
    db $EF,$EE                     ; $65E8  newline
    db $90,$90                     ; $65EA  　　(indent)
    db $31,$2A,$32,$8D,$26,$29,$8D ; $65EC  せきそ゛うか゛ = せきぞうが
    db $90                         ; $65F3  　(space)
    db $26,$2D,$8D,$25,$37,$25,$33 ; $65F4  うこ゛いていた = うごいていた
    db $8F                         ; $65FB  。
    db $FA                         ; $65FC  wait-for-button
    db $F7                         ; $65FD  clear page
    db $EF,$EE                     ; $65FE  newline
    db $9F                         ; $6600  box tag
    db $96                         ; $6601  end name/box tag
    db $24,$50,$42,$8D,$26,$2C,$55,$37,$8D; $6602  あるほ゛うけんて゛ = あるぼうけんで
    db $90                         ; $660B  　(space)
    db $25,$2A,$3D,$3F,$8D,$33     ; $660C  いきのひ゛た = いきのびた
    db $EF,$EE                     ; $6612  newline
    db $90,$90                     ; $6614  　　(indent)
    db $28,$38,$2D,$3D             ; $6616  おとこの
    db $90                         ; $661A  　(space)
    db $2D,$38,$3E,$8D,$37,$8D,$30 ; $661B  ことは゛て゛す = ことばです
    db $8F                         ; $6622  。
    db $F7                         ; $6623  clear page
    db $F0                         ; $6624  end of message


; --------------------------------------------------------------------------
; Message #112 ($6625)
;   「そうか。　ならば　いいんじゃ。
;   じかんをとらせて　すまんのう。
; --------------------------------------------------------------------------
Bank69_Msg112:                             ; $6625  (file $116625)
    db $EA                         ; $6625  ▶ new page
    db $9F                         ; $6626  box tag
    db $96                         ; $6627  end name/box tag
    db $32,$26,$29                 ; $6628  そうか
    db $8F                         ; $662B  。
    db $90                         ; $662C  　(space)
    db $39,$4E,$3E,$8D             ; $662D  ならは゛ = ならば
    db $90                         ; $6631  　(space)
    db $25,$25,$55,$2F,$8D,$49     ; $6632  いいんし゛ゃ = いいんじゃ
    db $8F                         ; $6638  。
    db $EF,$EE                     ; $6639  newline
    db $90,$90                     ; $663B  　　(indent)
    db $2F,$8D,$29,$55,$54,$38,$4E,$31,$37; $663D  し゛かんをとらせて = じかんをとらせて
    db $90                         ; $6646  　(space)
    db $30,$43,$55,$3D,$26         ; $6647  すまんのう
    db $8F                         ; $664C  。
    db $F7                         ; $664D  clear page
    db $F0                         ; $664E  end of message


; --------------------------------------------------------------------------
; Message #113 ($664F)
;   「うそは　ときに　ひとを
;   しあわせにし、
;   「やがて　ふこうにする、、。
;   「ある　まものに　だまされた
;   ある　おとこの　つぶやきです。
; --------------------------------------------------------------------------
Bank69_Msg113:                             ; $664F  (file $11664F)
    db $EB                         ; $664F  ▶ new page
    db $9F                         ; $6650  box tag
    db $96                         ; $6651  end name/box tag
    db $26,$32,$3E                 ; $6652  うそは
    db $90                         ; $6655  　(space)
    db $38,$2A,$3A                 ; $6656  ときに
    db $90                         ; $6659  　(space)
    db $3F,$38,$54                 ; $665A  ひとを
    db $EF,$EE                     ; $665D  newline
    db $90,$90                     ; $665F  　　(indent)
    db $2F,$24,$53,$31,$3A,$2F     ; $6661  しあわせにし
    db $A4                         ; $6667  、
    db $FA                         ; $6668  wait-for-button
    db $F7                         ; $6669  clear page
    db $EF,$EE                     ; $666A  newline
    db $9F                         ; $666C  box tag
    db $96                         ; $666D  end name/box tag
    db $48,$29,$8D,$37             ; $666E  やか゛て = やがて
    db $90                         ; $6672  　(space)
    db $40,$2D,$26,$3A,$30,$50     ; $6673  ふこうにする
    db $A4                         ; $6679  、
    db $A4                         ; $667A  、
    db $8F                         ; $667B  。
    db $EF,$EE                     ; $667C  newline
    db $FA                         ; $667E  wait-for-button
    db $F7                         ; $667F  clear page
    db $EF,$EE                     ; $6680  newline
    db $F3                         ; $6682  open text box
    db $9F                         ; $6683  box tag
    db $96                         ; $6684  end name/box tag
    db $24,$50                     ; $6685  ある
    db $90                         ; $6687  　(space)
    db $43,$47,$3D,$3A             ; $6688  まものに
    db $90                         ; $668C  　(space)
    db $33,$8D,$43,$2E,$51,$33     ; $668D  た゛まされた = だまされた
    db $EF,$EE                     ; $6693  newline
    db $90,$90                     ; $6695  　　(indent)
    db $24,$50                     ; $6697  ある
    db $90                         ; $6699  　(space)
    db $28,$38,$2D,$3D             ; $669A  おとこの
    db $90                         ; $669E  　(space)
    db $35,$40,$8D,$48,$2A,$37,$8D,$30; $669F  つふ゛やきて゛す = つぶやきです
    db $8F                         ; $66A7  。
    db $F7                         ; $66A8  clear page
    db $F0                         ; $66A9  end of message


; --------------------------------------------------------------------------
; Message #114 ($66AA)
;   おう「おお　〈テリー〉よ！
;   うごくせきぞうを　たおしたか！
;   おう「うごくせきぞうは　おともなく
;   うしろから　しのびよるときく。
;   おう「なんと　ひきょうな
;   まものなのじゃ！
; --------------------------------------------------------------------------
Bank69_Msg114:                             ; $66AA  (file $1166AA)
    db $EA                         ; $66AA  ▶ new page
    db $28,$26                     ; $66AB  おう  (speaker: おう)
    db $96                         ; $66AD  end name/box tag
    db $28,$28                     ; $66AE  おお
    db $90                         ; $66B0  　(space)
    db $F6                         ; $66B1  «insert hero name»
    db $4C                         ; $66B2  よ
    db $99                         ; $66B3  ！
    db $EF,$EE                     ; $66B4  newline
    db $90,$90                     ; $66B6  　　(indent)
    db $26,$2D,$8D,$2B,$31,$2A,$32,$8D,$26,$54; $66B8  うこ゛くせきそ゛うを = うごくせきぞうを
    db $90                         ; $66C2  　(space)
    db $33,$28,$2F,$33,$29         ; $66C3  たおしたか
    db $99                         ; $66C8  ！
    db $FA                         ; $66C9  wait-for-button
    db $F7                         ; $66CA  clear page
    db $EF,$EE                     ; $66CB  newline
    db $28,$26                     ; $66CD  おう  (speaker: おう)
    db $96                         ; $66CF  end name/box tag
    db $26,$2D,$8D,$2B,$31,$2A,$32,$8D,$26,$3E; $66D0  うこ゛くせきそ゛うは = うごくせきぞうは
    db $90                         ; $66DA  　(space)
    db $28,$38,$47,$39,$2B         ; $66DB  おともなく
    db $EF,$EE                     ; $66E0  newline
    db $90,$90                     ; $66E2  　　(indent)
    db $26,$2F,$52,$29,$4E         ; $66E4  うしろから
    db $90                         ; $66E9  　(space)
    db $2F,$3D,$3F,$8D,$4C,$50,$38,$2A,$2B; $66EA  しのひ゛よるときく = しのびよるときく
    db $8F                         ; $66F3  。
    db $FA                         ; $66F4  wait-for-button
    db $F7                         ; $66F5  clear page
    db $EF,$EE                     ; $66F6  newline
    db $28,$26                     ; $66F8  おう  (speaker: おう)
    db $96                         ; $66FA  end name/box tag
    db $39,$55,$38                 ; $66FB  なんと
    db $90                         ; $66FE  　(space)
    db $3F,$2A,$4D,$26,$39         ; $66FF  ひきょうな
    db $EF,$EE                     ; $6704  newline
    db $90,$90                     ; $6706  　　(indent)
    db $43,$47,$3D,$39,$3D,$2F,$8D,$49; $6708  まものなのし゛ゃ = まものなのじゃ
    db $99                         ; $6710  ！
    db $F7                         ; $6711  clear page
    db $F0                         ; $6712  end of message


; --------------------------------------------------------------------------
; Message #115 ($6713)
;   おう「そうじゃ　〈テリー〉よ。たまには
;   くにのものと　はなしておるか？
;   おう「まちには　メダルおじさんという
;   きのよいおとこが　おるそうな、。
;   おう「ちいさなメダルが　すきらしい
;   から　もっていってやるべきじゃ！
;   おう「それでは　いそがしいので
;   わしは　しつれいする！
;   おう「ィソ　ィソ、　ィソ　ィソ、、。
; --------------------------------------------------------------------------
Bank69_Msg115:                             ; $6713  (file $116713)
    db $EA                         ; $6713  ▶ new page
    db $28,$26                     ; $6714  おう  (speaker: おう)
    db $96                         ; $6716  end name/box tag
    db $32,$26,$2F,$8D,$49         ; $6717  そうし゛ゃ = そうじゃ
    db $90                         ; $671C  　(space)
    db $F6                         ; $671D  «insert hero name»
    db $4C                         ; $671E  よ
    db $8F                         ; $671F  。
    db $33,$43,$3A,$3E             ; $6720  たまには
    db $EF,$EE                     ; $6724  newline
    db $90,$90                     ; $6726  　　(indent)
    db $2B,$3A,$3D,$47,$3D,$38     ; $6728  くにのものと
    db $90                         ; $672E  　(space)
    db $3E,$39,$2F,$37,$28,$50,$29 ; $672F  はなしておるか
    db $98                         ; $6736  ？
    db $FA                         ; $6737  wait-for-button
    db $F7                         ; $6738  clear page
    db $EF,$EE                     ; $6739  newline
    db $28,$26                     ; $673B  おう  (speaker: おう)
    db $96                         ; $673D  end name/box tag
    db $43,$34,$3A,$3E             ; $673E  まちには
    db $90                         ; $6742  　(space)
    db $7D,$6A,$8D,$87,$28,$2F,$8D,$2E,$55,$38,$25,$26; $6743  メタ゛ルおし゛さんという = メダルおじさんという
    db $EF,$EE                     ; $674F  newline
    db $90,$90                     ; $6751  　　(indent)
    db $2A,$3D,$4C,$25,$28,$38,$2D,$29,$8D; $6753  きのよいおとこか゛ = きのよいおとこが
    db $90                         ; $675C  　(space)
    db $28,$50,$32,$26,$39         ; $675D  おるそうな
    db $A4                         ; $6762  、
    db $8F                         ; $6763  。
    db $FA                         ; $6764  wait-for-button
    db $F7                         ; $6765  clear page
    db $EF,$EE                     ; $6766  newline
    db $28,$26                     ; $6768  おう  (speaker: おう)
    db $96                         ; $676A  end name/box tag
    db $34,$25,$2E,$39,$7D,$6A,$8D,$87,$29,$8D; $676B  ちいさなメタ゛ルか゛ = ちいさなメダルが
    db $90                         ; $6775  　(space)
    db $30,$2A,$4E,$2F,$25         ; $6776  すきらしい
    db $EF,$EE                     ; $677B  newline
    db $90,$90                     ; $677D  　　(indent)
    db $29,$4E                     ; $677F  から
    db $90                         ; $6781  　(space)
    db $47,$36,$37,$25,$36,$37,$48,$50,$41,$8D,$2A,$2F,$8D,$49; $6782  もっていってやるへ゛きし゛ゃ = もっていってやるべきじゃ
    db $99                         ; $6790  ！
    db $FA                         ; $6791  wait-for-button
    db $F7                         ; $6792  clear page
    db $EF,$EE                     ; $6793  newline
    db $28,$26                     ; $6795  おう  (speaker: おう)
    db $96                         ; $6797  end name/box tag
    db $32,$51,$37,$8D,$3E         ; $6798  それて゛は = それでは
    db $90                         ; $679D  　(space)
    db $25,$32,$29,$8D,$2F,$25,$3D,$37,$8D; $679E  いそか゛しいのて゛ = いそがしいので
    db $EF,$EE                     ; $67A7  newline
    db $90,$90                     ; $67A9  　　(indent)
    db $53,$2F,$3E                 ; $67AB  わしは
    db $90                         ; $67AE  　(space)
    db $2F,$35,$51,$25,$30,$50     ; $67AF  しつれいする
    db $99                         ; $67B5  ！
    db $FA                         ; $67B6  wait-for-button
    db $F7                         ; $67B7  clear page
    db $EF,$EE                     ; $67B8  newline
    db $28,$26                     ; $67BA  おう  (speaker: おう)
    db $96                         ; $67BC  end name/box tag
    db $58,$69                     ; $67BD  ィソ
    db $90                         ; $67BF  　(space)
    db $58,$69                     ; $67C0  ィソ
    db $A4                         ; $67C2  、
    db $90                         ; $67C3  　(space)
    db $58,$69                     ; $67C4  ィソ
    db $90                         ; $67C6  　(space)
    db $58,$69                     ; $67C7  ィソ
    db $A4                         ; $67C9  、
    db $A4                         ; $67CA  、
    db $8F                         ; $67CB  。
    db $EF,$EE                     ; $67CC  newline
    db $F7                         ; $67CE  clear page
    db $F0                         ; $67CF  end of message


; --------------------------------------------------------------------------
; Message #116 ($67D0)
;   〈テリー〉は　ほんだなを　しらべた。
;   「マネー　ぞうしょく　じゅつ、
;   「ほんものの　おかねを　まねして
;   つくっては　いけません。
; --------------------------------------------------------------------------
Bank69_Msg116:                             ; $67D0  (file $1167D0)
    db $F6                         ; $67D0  «insert hero name»
    db $3E                         ; $67D1  は
    db $90                         ; $67D2  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $67D3  ほんた゛なを = ほんだなを
    db $90                         ; $67D9  　(space)
    db $2F,$4E,$41,$8D,$33         ; $67DA  しらへ゛た = しらべた
    db $8F                         ; $67DF  。
    db $EF,$EE                     ; $67E0  newline
    db $FA                         ; $67E2  wait-for-button
    db $F7                         ; $67E3  clear page
    db $EF,$EE                     ; $67E4  newline
    db $F3                         ; $67E6  open text box
    db $96                         ; $67E7  end name/box tag
    db $7A,$73,$9C                 ; $67E8  マネー
    db $90                         ; $67EB  　(space)
    db $32,$8D,$26,$2F,$4D,$2B     ; $67EC  そ゛うしょく = ぞうしょく
    db $90                         ; $67F2  　(space)
    db $2F,$8D,$4B,$35             ; $67F3  し゛ゅつ = じゅつ
    db $A4                         ; $67F7  、
    db $EF,$EE                     ; $67F8  newline
    db $FA                         ; $67FA  wait-for-button
    db $F7                         ; $67FB  clear page
    db $EF,$EE                     ; $67FC  newline
    db $F3                         ; $67FE  open text box
    db $96                         ; $67FF  end name/box tag
    db $42,$55,$47,$3D,$3D         ; $6800  ほんものの
    db $90                         ; $6805  　(space)
    db $28,$29,$3C,$54             ; $6806  おかねを
    db $90                         ; $680A  　(space)
    db $43,$3C,$2F,$37             ; $680B  まねして
    db $EF,$EE                     ; $680F  newline
    db $90                         ; $6811  　(space)
    db $35,$2B,$36,$37,$3E         ; $6812  つくっては
    db $90                         ; $6817  　(space)
    db $25,$2C,$43,$31,$55         ; $6818  いけません
    db $8F                         ; $681D  。
    db $F7                         ; $681E  clear page
    db $F0                         ; $681F  end of message


; --------------------------------------------------------------------------
; Message #117 ($6820)
;   「ここは　タィジャの　おしろです。
;   「さきほどの　じしんで　まちや
;   バザーに　へんかがありましたよ。
; --------------------------------------------------------------------------
Bank69_Msg117:                             ; $6820  (file $116820)
    db $EA                         ; $6820  ▶ new page
    db $9F                         ; $6821  box tag
    db $96                         ; $6822  end name/box tag
    db $2D,$2D,$3E                 ; $6823  ここは
    db $90                         ; $6826  　(space)
    db $6A,$58,$66,$8D,$82,$3D     ; $6827  タィシ゛ャの = タィジャの
    db $90                         ; $682D  　(space)
    db $28,$2F,$52,$37,$8D,$30     ; $682E  おしろて゛す = おしろです
    db $8F                         ; $6834  。
    db $EF,$EE                     ; $6835  newline
    db $FA                         ; $6837  wait-for-button
    db $F7                         ; $6838  clear page
    db $EF,$EE                     ; $6839  newline
    db $F3                         ; $683B  open text box
    db $9F                         ; $683C  box tag
    db $96                         ; $683D  end name/box tag
    db $2E,$2A,$42,$38,$8D,$3D     ; $683E  さきほと゛の = さきほどの
    db $90                         ; $6844  　(space)
    db $2F,$8D,$2F,$55,$37,$8D     ; $6845  し゛しんて゛ = じしんで
    db $90                         ; $684B  　(space)
    db $43,$34,$48                 ; $684C  まちや
    db $EF,$EE                     ; $684F  newline
    db $90,$90                     ; $6851  　　(indent)
    db $75,$8D,$65,$8D,$9C,$3A     ; $6853  ハ゛サ゛ーに = バザーに
    db $90                         ; $6859  　(space)
    db $41,$55,$29,$29,$8D,$24,$4F,$43,$2F,$33,$4C; $685A  へんかか゛ありましたよ = へんかがありましたよ
    db $8F                         ; $6865  。
    db $F7                         ; $6866  clear page
    db $F0                         ; $6867  end of message


; --------------------------------------------------------------------------
; Message #118 ($6868)
;   「ずーっとむかし　わたぼうの
;   ごせんぞさまが　わたしたちに、
;   「ほしふりのたいかいを　ひらくよう
;   たのんだのは　どうしてかしら？
; --------------------------------------------------------------------------
Bank69_Msg118:                             ; $6868  (file $116868)
    db $EB                         ; $6868  ▶ new page
    db $9F                         ; $6869  box tag
    db $96                         ; $686A  end name/box tag
    db $30,$8D,$9C,$36,$38,$45,$29,$2F; $686B  す゛ーっとむかし = ずーっとむかし
    db $90                         ; $6873  　(space)
    db $53,$33,$42,$8D,$26,$3D     ; $6874  わたほ゛うの = わたぼうの
    db $EF,$EE                     ; $687A  newline
    db $90,$90                     ; $687C  　　(indent)
    db $2D,$8D,$31,$55,$32,$8D,$2E,$43,$29,$8D; $687E  こ゛せんそ゛さまか゛ = ごせんぞさまが
    db $90                         ; $6888  　(space)
    db $53,$33,$2F,$33,$34,$3A     ; $6889  わたしたちに
    db $A4                         ; $688F  、
    db $FA                         ; $6890  wait-for-button
    db $F7                         ; $6891  clear page
    db $EF,$EE                     ; $6892  newline
    db $9F                         ; $6894  box tag
    db $96                         ; $6895  end name/box tag
    db $42,$2F,$40,$4F,$3D,$33,$25,$29,$25,$54; $6896  ほしふりのたいかいを
    db $90                         ; $68A0  　(space)
    db $3F,$4E,$2B,$4C,$26         ; $68A1  ひらくよう
    db $EF,$EE                     ; $68A6  newline
    db $90,$90                     ; $68A8  　　(indent)
    db $33,$3D,$55,$33,$8D,$3D,$3E ; $68AA  たのんた゛のは = たのんだのは
    db $90                         ; $68B1  　(space)
    db $38,$8D,$26,$2F,$37,$29,$2F,$4E; $68B2  と゛うしてかしら = どうしてかしら
    db $98                         ; $68BA  ？
    db $F7                         ; $68BB  clear page
    db $F0                         ; $68BC  end of message


; --------------------------------------------------------------------------
; Message #119 ($68BD)
;   「したで　とうせんぼ　していた
;   おんなのこ　よくみかけるな[91]、。
;   「きみの　しあいのときには　いつも
;   かくとうじょうに　いるようだよ。
; --------------------------------------------------------------------------
Bank69_Msg119:                             ; $68BD  (file $1168BD)
    db $EA                         ; $68BD  ▶ new page
    db $9F                         ; $68BE  box tag
    db $96                         ; $68BF  end name/box tag
    db $2F,$33,$37,$8D             ; $68C0  したて゛ = したで
    db $90                         ; $68C4  　(space)
    db $38,$26,$31,$55,$42,$8D     ; $68C5  とうせんほ゛ = とうせんぼ
    db $90                         ; $68CB  　(space)
    db $2F,$37,$25,$33             ; $68CC  していた
    db $EF,$EE                     ; $68D0  newline
    db $90,$90                     ; $68D2  　　(indent)
    db $28,$55,$39,$3D,$2D         ; $68D4  おんなのこ
    db $90                         ; $68D9  　(space)
    db $4C,$2B,$44,$29,$2C,$50,$39 ; $68DA  よくみかけるな
    db $91                         ; $68E1  ctrl $91
    db $A4                         ; $68E2  、
    db $8F                         ; $68E3  。
    db $FA                         ; $68E4  wait-for-button
    db $F7                         ; $68E5  clear page
    db $EF,$EE                     ; $68E6  newline
    db $9F                         ; $68E8  box tag
    db $96                         ; $68E9  end name/box tag
    db $2A,$44,$3D                 ; $68EA  きみの
    db $90                         ; $68ED  　(space)
    db $2F,$24,$25,$3D,$38,$2A,$3A,$3E; $68EE  しあいのときには
    db $90                         ; $68F6  　(space)
    db $25,$35,$47                 ; $68F7  いつも
    db $EF,$EE                     ; $68FA  newline
    db $90,$90                     ; $68FC  　　(indent)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A; $68FE  かくとうし゛ょうに = かくとうじょうに
    db $90                         ; $6907  　(space)
    db $25,$50,$4C,$26,$33,$8D,$4C ; $6908  いるようた゛よ = いるようだよ
    db $8F                         ; $690F  。
    db $F7                         ; $6910  clear page
    db $F0                         ; $6911  end of message


; --------------------------------------------------------------------------
; Message #120 ($6912)
;   「カレキのくに　というのは　もう
;   くにが　かれかかっています。
;   「タィジャも　かれゆく　ときが
;   くるのでしょうか、、。
; --------------------------------------------------------------------------
Bank69_Msg120:                             ; $6912  (file $116912)
    db $EB                         ; $6912  ▶ new page
    db $9F                         ; $6913  box tag
    db $96                         ; $6914  end name/box tag
    db $60,$88,$61,$3D,$2B,$3A     ; $6915  カレキのくに
    db $90                         ; $691B  　(space)
    db $38,$25,$26,$3D,$3E         ; $691C  というのは
    db $90                         ; $6921  　(space)
    db $47,$26                     ; $6922  もう
    db $EF,$EE                     ; $6924  newline
    db $90,$90                     ; $6926  　　(indent)
    db $2B,$3A,$29,$8D             ; $6928  くにか゛ = くにが
    db $90                         ; $692C  　(space)
    db $29,$51,$29,$29,$36,$37,$25,$43,$30; $692D  かれかかっています
    db $8F                         ; $6936  。
    db $FA                         ; $6937  wait-for-button
    db $F7                         ; $6938  clear page
    db $EF,$EE                     ; $6939  newline
    db $9F                         ; $693B  box tag
    db $96                         ; $693C  end name/box tag
    db $6A,$58,$66,$8D,$82,$47     ; $693D  タィシ゛ャも = タィジャも
    db $90                         ; $6943  　(space)
    db $29,$51,$4A,$2B             ; $6944  かれゆく
    db $90                         ; $6948  　(space)
    db $38,$2A,$29,$8D             ; $6949  ときか゛ = ときが
    db $EF,$EE                     ; $694D  newline
    db $90,$90                     ; $694F  　　(indent)
    db $2B,$50,$3D,$37,$8D,$2F,$4D,$26,$29; $6951  くるのて゛しょうか = くるのでしょうか
    db $A4                         ; $695A  、
    db $A4                         ; $695B  、
    db $8F                         ; $695C  。
    db $F7                         ; $695D  clear page
    db $F0                         ; $695E  end of message


; --------------------------------------------------------------------------
; Message #121 ($695F)
;   「こんかいこそは　たいかいで
;   ゆうしょうして　ほしいもんだね。
;   「ほしふりのよるには　ほしが
;   ねがいごとを　きいてくれるのさ。
;   「ゆうしょうすると　ねがいが
;   かなうそうだよ。
; --------------------------------------------------------------------------
Bank69_Msg121:                             ; $695F  (file $11695F)
    db $EB                         ; $695F  ▶ new page
    db $9F                         ; $6960  box tag
    db $96                         ; $6961  end name/box tag
    db $2D,$55,$29,$25,$2D,$32,$3E ; $6962  こんかいこそは
    db $90                         ; $6969  　(space)
    db $33,$25,$29,$25,$37,$8D     ; $696A  たいかいて゛ = たいかいで
    db $EF,$EE                     ; $6970  newline
    db $90,$90                     ; $6972  　　(indent)
    db $4A,$26,$2F,$4D,$26,$2F,$37 ; $6974  ゆうしょうして
    db $90                         ; $697B  　(space)
    db $42,$2F,$25,$47,$55,$33,$8D,$3C; $697C  ほしいもんた゛ね = ほしいもんだね
    db $8F                         ; $6984  。
    db $FA                         ; $6985  wait-for-button
    db $F7                         ; $6986  clear page
    db $EF,$EE                     ; $6987  newline
    db $9F                         ; $6989  box tag
    db $96                         ; $698A  end name/box tag
    db $42,$2F,$40,$4F,$3D,$4C,$50,$3A,$3E; $698B  ほしふりのよるには
    db $90                         ; $6994  　(space)
    db $42,$2F,$29,$8D             ; $6995  ほしか゛ = ほしが
    db $EF,$EE                     ; $6999  newline
    db $90,$90                     ; $699B  　　(indent)
    db $3C,$29,$8D,$25,$2D,$8D,$38,$54; $699D  ねか゛いこ゛とを = ねがいごとを
    db $90                         ; $69A5  　(space)
    db $2A,$25,$37,$2B,$51,$50,$3D,$2E; $69A6  きいてくれるのさ
    db $8F                         ; $69AE  。
    db $FA                         ; $69AF  wait-for-button
    db $F7                         ; $69B0  clear page
    db $EF,$EE                     ; $69B1  newline
    db $9F                         ; $69B3  box tag
    db $96                         ; $69B4  end name/box tag
    db $4A,$26,$2F,$4D,$26,$30,$50,$38; $69B5  ゆうしょうすると
    db $90                         ; $69BD  　(space)
    db $3C,$29,$8D,$25,$29,$8D     ; $69BE  ねか゛いか゛ = ねがいが
    db $EF,$EE                     ; $69C4  newline
    db $90,$90                     ; $69C6  　　(indent)
    db $29,$39,$26,$32,$26,$33,$8D,$4C; $69C8  かなうそうた゛よ = かなうそうだよ
    db $8F                         ; $69D0  。
    db $F7                         ; $69D1  clear page
    db $F0                         ; $69D2  end of message


; --------------------------------------------------------------------------
; Message #122 ($69D3)
;   「みぎにいくと　バザーだよー！
;   あたらしい　おみせができたよ！
; --------------------------------------------------------------------------
Bank69_Msg122:                             ; $69D3  (file $1169D3)
    db $EB                         ; $69D3  ▶ new page
    db $9F                         ; $69D4  box tag
    db $96                         ; $69D5  end name/box tag
    db $44,$2A,$8D,$3A,$25,$2B,$38 ; $69D6  みき゛にいくと = みぎにいくと
    db $90                         ; $69DD  　(space)
    db $75,$8D,$65,$8D,$9C,$33,$8D,$4C,$9C; $69DE  ハ゛サ゛ーた゛よー = バザーだよー
    db $99                         ; $69E7  ！
    db $EF,$EE                     ; $69E8  newline
    db $90,$90                     ; $69EA  　　(indent)
    db $24,$33,$4E,$2F,$25         ; $69EC  あたらしい
    db $90                         ; $69F1  　(space)
    db $28,$44,$31,$29,$8D,$37,$8D,$2A,$33,$4C; $69F2  おみせか゛て゛きたよ = おみせができたよ
    db $99                         ; $69FC  ！
    db $F7                         ; $69FD  clear page
    db $F0                         ; $69FE  end of message


; --------------------------------------------------------------------------
; Message #123 ($69FF)
;   「お　おまえ　じしんが　おこったの
;   しってるか？　〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg123:                             ; $69FF  (file $1169FF)
    db $EB                         ; $69FF  ▶ new page
    db $9F                         ; $6A00  box tag
    db $96                         ; $6A01  end name/box tag
    db $28                         ; $6A02  お
    db $90                         ; $6A03  　(space)
    db $28,$43,$27                 ; $6A04  おまえ
    db $90                         ; $6A07  　(space)
    db $2F,$8D,$2F,$55,$29,$8D     ; $6A08  し゛しんか゛ = じしんが
    db $90                         ; $6A0E  　(space)
    db $28,$2D,$36,$33,$3D         ; $6A0F  おこったの
    db $EF,$EE                     ; $6A14  newline
    db $90,$90                     ; $6A16  　　(indent)
    db $2F,$36,$37,$50,$29         ; $6A18  しってるか
    db $98                         ; $6A1D  ？
    db $90                         ; $6A1E  　(space)
    db $FF                         ; $6A1F  はい/いいえ
    db $F0                         ; $6A20  end of message


; --------------------------------------------------------------------------
; Message #124 ($6A21)
;   「だれが　あんな　でっかいじしんを
;   おこすんだよ！　てめえか！？
; --------------------------------------------------------------------------
Bank69_Msg124:                             ; $6A21  (file $116A21)
    db $EB                         ; $6A21  ▶ new page
    db $9F                         ; $6A22  box tag
    db $96                         ; $6A23  end name/box tag
    db $33,$8D,$51,$29,$8D         ; $6A24  た゛れか゛ = だれが
    db $90                         ; $6A29  　(space)
    db $24,$55,$39                 ; $6A2A  あんな
    db $90                         ; $6A2D  　(space)
    db $37,$8D,$36,$29,$25,$2F,$8D,$2F,$55,$54; $6A2E  て゛っかいし゛しんを = でっかいじしんを
    db $EF,$EE                     ; $6A38  newline
    db $90,$90                     ; $6A3A  　　(indent)
    db $28,$2D,$30,$55,$33,$8D,$4C ; $6A3C  おこすんた゛よ = おこすんだよ
    db $99                         ; $6A43  ！
    db $90                         ; $6A44  　(space)
    db $37,$46,$27,$29             ; $6A45  てめえか
    db $99                         ; $6A49  ！
    db $98                         ; $6A4A  ？
    db $F7                         ; $6A4B  clear page
    db $F0                         ; $6A4C  end of message


; --------------------------------------------------------------------------
; Message #125 ($6A4D)
;   「この　どんかん！
;   どこ　みて　あるいてんだよ！
; --------------------------------------------------------------------------
Bank69_Msg125:                             ; $6A4D  (file $116A4D)
    db $EB                         ; $6A4D  ▶ new page
    db $9F                         ; $6A4E  box tag
    db $96                         ; $6A4F  end name/box tag
    db $2D,$3D                     ; $6A50  この
    db $90                         ; $6A52  　(space)
    db $38,$8D,$55,$29,$55         ; $6A53  と゛んかん = どんかん
    db $99                         ; $6A58  ！
    db $EF,$EE                     ; $6A59  newline
    db $90,$90                     ; $6A5B  　　(indent)
    db $38,$8D,$2D                 ; $6A5D  と゛こ = どこ
    db $90                         ; $6A60  　(space)
    db $44,$37                     ; $6A61  みて
    db $90                         ; $6A63  　(space)
    db $24,$50,$25,$37,$55,$33,$8D,$4C; $6A64  あるいてんた゛よ = あるいてんだよ
    db $99                         ; $6A6C  ！
    db $F7                         ; $6A6D  clear page
    db $F0                         ; $6A6E  end of message


; --------------------------------------------------------------------------
; Message #126 ($6A6F)
;   「じしんが　おこったら　みぎに
;   いけるように　なりましたよ！
; --------------------------------------------------------------------------
Bank69_Msg126:                             ; $6A6F  (file $116A6F)
    db $EA                         ; $6A6F  ▶ new page
    db $9F                         ; $6A70  box tag
    db $96                         ; $6A71  end name/box tag
    db $2F,$8D,$2F,$55,$29,$8D     ; $6A72  し゛しんか゛ = じしんが
    db $90                         ; $6A78  　(space)
    db $28,$2D,$36,$33,$4E         ; $6A79  おこったら
    db $90                         ; $6A7E  　(space)
    db $44,$2A,$8D,$3A             ; $6A7F  みき゛に = みぎに
    db $EF,$EE                     ; $6A83  newline
    db $90,$90                     ; $6A85  　　(indent)
    db $25,$2C,$50,$4C,$26,$3A     ; $6A87  いけるように
    db $90                         ; $6A8D  　(space)
    db $39,$4F,$43,$2F,$33,$4C     ; $6A8E  なりましたよ
    db $99                         ; $6A94  ！
    db $F7                         ; $6A95  clear page
    db $F0                         ; $6A96  end of message


; --------------------------------------------------------------------------
; Message #127 ($6A97)
;   「ようこそ！　バザーかいじょうへ。
;   あたらしいおみせが　たちました！
; --------------------------------------------------------------------------
Bank69_Msg127:                             ; $6A97  (file $116A97)
    db $EB                         ; $6A97  ▶ new page
    db $9F                         ; $6A98  box tag
    db $96                         ; $6A99  end name/box tag
    db $4C,$26,$2D,$32             ; $6A9A  ようこそ
    db $99                         ; $6A9E  ！
    db $90                         ; $6A9F  　(space)
    db $75,$8D,$65,$8D,$9C,$29,$25,$2F,$8D,$4D,$26,$41; $6AA0  ハ゛サ゛ーかいし゛ょうへ = バザーかいじょうへ
    db $8F                         ; $6AAC  。
    db $EF,$EE                     ; $6AAD  newline
    db $90,$90                     ; $6AAF  　　(indent)
    db $24,$33,$4E,$2F,$25,$28,$44,$31,$29,$8D; $6AB1  あたらしいおみせか゛ = あたらしいおみせが
    db $90                         ; $6ABB  　(space)
    db $33,$34,$43,$2F,$33         ; $6ABC  たちました
    db $99                         ; $6AC1  ！
    db $F7                         ; $6AC2  clear page
    db $F0                         ; $6AC3  end of message


; --------------------------------------------------------------------------
; Message #128 ($6AC4)
;   「わたしは　おまつりずきなのよ。
;   たいかいが　たのしみだわ[91]！
;   「あたらしい　おみせは
;   みぎのほうに　でてたわよ！
; --------------------------------------------------------------------------
Bank69_Msg128:                             ; $6AC4  (file $116AC4)
    db $EB                         ; $6AC4  ▶ new page
    db $9F                         ; $6AC5  box tag
    db $96                         ; $6AC6  end name/box tag
    db $53,$33,$2F,$3E             ; $6AC7  わたしは
    db $90                         ; $6ACB  　(space)
    db $28,$43,$35,$4F,$30,$8D,$2A,$39,$3D,$4C; $6ACC  おまつりす゛きなのよ = おまつりずきなのよ
    db $8F                         ; $6AD6  。
    db $EF,$EE                     ; $6AD7  newline
    db $90,$90                     ; $6AD9  　　(indent)
    db $33,$25,$29,$25,$29,$8D     ; $6ADB  たいかいか゛ = たいかいが
    db $90                         ; $6AE1  　(space)
    db $33,$3D,$2F,$44,$33,$8D,$53 ; $6AE2  たのしみた゛わ = たのしみだわ
    db $91                         ; $6AE9  ctrl $91
    db $99                         ; $6AEA  ！
    db $FA                         ; $6AEB  wait-for-button
    db $F7                         ; $6AEC  clear page
    db $EF,$EE                     ; $6AED  newline
    db $9F                         ; $6AEF  box tag
    db $96                         ; $6AF0  end name/box tag
    db $24,$33,$4E,$2F,$25         ; $6AF1  あたらしい
    db $90                         ; $6AF6  　(space)
    db $28,$44,$31,$3E             ; $6AF7  おみせは
    db $EF,$EE                     ; $6AFB  newline
    db $90,$90                     ; $6AFD  　　(indent)
    db $44,$2A,$8D,$3D,$42,$26,$3A ; $6AFF  みき゛のほうに = みぎのほうに
    db $90                         ; $6B06  　(space)
    db $37,$8D,$37,$33,$53,$4C     ; $6B07  て゛てたわよ = でてたわよ
    db $99                         ; $6B0D  ！
    db $F7                         ; $6B0E  clear page
    db $F0                         ; $6B0F  end of message


; --------------------------------------------------------------------------
; Message #129 ($6B10)
;   「ねえ　おにいちゃんは
;   もんすたーますたーなの？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg129:                             ; $6B10  (file $116B10)
    db $EB                         ; $6B10  ▶ new page
    db $9F                         ; $6B11  box tag
    db $96                         ; $6B12  end name/box tag
    db $3C,$27                     ; $6B13  ねえ
    db $90                         ; $6B15  　(space)
    db $28,$3A,$25,$34,$49,$55,$3E ; $6B16  おにいちゃんは
    db $EF,$EE                     ; $6B1D  newline
    db $90,$90                     ; $6B1F  　　(indent)
    db $47,$55,$30,$33,$9C,$43,$30,$33,$9C,$39,$3D; $6B21  もんすたーますたーなの
    db $98                         ; $6B2C  ？
    db $FF                         ; $6B2D  はい/いいえ
    db $F0                         ; $6B2E  end of message


; --------------------------------------------------------------------------
; Message #130 ($6B2F)
;   「すごいや　すごいや！
;   ぼくも　ますたーに　なりたいよ！
; --------------------------------------------------------------------------
Bank69_Msg130:                             ; $6B2F  (file $116B2F)
    db $EB                         ; $6B2F  ▶ new page
    db $9F                         ; $6B30  box tag
    db $96                         ; $6B31  end name/box tag
    db $30,$2D,$8D,$25,$48         ; $6B32  すこ゛いや = すごいや
    db $90                         ; $6B37  　(space)
    db $30,$2D,$8D,$25,$48         ; $6B38  すこ゛いや = すごいや
    db $99                         ; $6B3D  ！
    db $EF,$EE                     ; $6B3E  newline
    db $90,$90                     ; $6B40  　　(indent)
    db $42,$8D,$2B,$47             ; $6B42  ほ゛くも = ぼくも
    db $90                         ; $6B46  　(space)
    db $43,$30,$33,$9C,$3A         ; $6B47  ますたーに
    db $90                         ; $6B4C  　(space)
    db $39,$4F,$33,$25,$4C         ; $6B4D  なりたいよ
    db $99                         ; $6B52  ！
    db $F7                         ; $6B53  clear page
    db $F0                         ; $6B54  end of message


; --------------------------------------------------------------------------
; Message #131 ($6B55)
;   「ますたーって　まものに　すかれる
;   ひとしか　なれないんだって。
; --------------------------------------------------------------------------
Bank69_Msg131:                             ; $6B55  (file $116B55)
    db $EB                         ; $6B55  ▶ new page
    db $9F                         ; $6B56  box tag
    db $96                         ; $6B57  end name/box tag
    db $43,$30,$33,$9C,$36,$37     ; $6B58  ますたーって
    db $90                         ; $6B5E  　(space)
    db $43,$47,$3D,$3A             ; $6B5F  まものに
    db $90                         ; $6B63  　(space)
    db $30,$29,$51,$50             ; $6B64  すかれる
    db $EF,$EE                     ; $6B68  newline
    db $90,$90                     ; $6B6A  　　(indent)
    db $3F,$38,$2F,$29             ; $6B6C  ひとしか
    db $90                         ; $6B70  　(space)
    db $39,$51,$39,$25,$55,$33,$8D,$36,$37; $6B71  なれないんた゛って = なれないんだって
    db $8F                         ; $6B7A  。
    db $F7                         ; $6B7B  clear page
    db $F0                         ; $6B7C  end of message


; --------------------------------------------------------------------------
; Message #132 ($6B7D)
;   「うっひゃー！　さっきのじしんで
;   バザーが　ひろくなったよ！
;   「おみせで　うっているものを
;   としょかんでしらべたんだ。きく？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg132:                             ; $6B7D  (file $116B7D)
    db $EA                         ; $6B7D  ▶ new page
    db $9F                         ; $6B7E  box tag
    db $96                         ; $6B7F  end name/box tag
    db $26,$36,$3F,$49,$9C         ; $6B80  うっひゃー
    db $99                         ; $6B85  ！
    db $90                         ; $6B86  　(space)
    db $2E,$36,$2A,$3D,$2F,$8D,$2F,$55,$37,$8D; $6B87  さっきのし゛しんて゛ = さっきのじしんで
    db $EF,$EE                     ; $6B91  newline
    db $90,$90                     ; $6B93  　　(indent)
    db $75,$8D,$65,$8D,$9C,$29,$8D ; $6B95  ハ゛サ゛ーか゛ = バザーが
    db $90                         ; $6B9C  　(space)
    db $3F,$52,$2B,$39,$36,$33,$4C ; $6B9D  ひろくなったよ
    db $99                         ; $6BA4  ！
    db $FA                         ; $6BA5  wait-for-button
    db $F7                         ; $6BA6  clear page
    db $EF,$EE                     ; $6BA7  newline
    db $9F                         ; $6BA9  box tag
    db $96                         ; $6BAA  end name/box tag
    db $28,$44,$31,$37,$8D         ; $6BAB  おみせて゛ = おみせで
    db $90                         ; $6BB0  　(space)
    db $26,$36,$37,$25,$50,$47,$3D,$54; $6BB1  うっているものを
    db $EF,$EE                     ; $6BB9  newline
    db $90,$90                     ; $6BBB  　　(indent)
    db $38,$2F,$4D,$29,$55,$37,$8D,$2F,$4E,$41,$8D,$33,$55,$33,$8D; $6BBD  としょかんて゛しらへ゛たんた゛ = としょかんでしらべたんだ
    db $8F                         ; $6BCC  。
    db $2A,$2B                     ; $6BCD  きく
    db $98                         ; $6BCF  ？
    db $FF                         ; $6BD0  はい/いいえ
    db $F0                         ; $6BD1  end of message


; --------------------------------------------------------------------------
; Message #133 ($6BD2)
;   「ここで　いいえと　こたえるとは！
;   あなた　じゅくれんしゃですな！
; --------------------------------------------------------------------------
Bank69_Msg133:                             ; $6BD2  (file $116BD2)
    db $EA                         ; $6BD2  ▶ new page
    db $9F                         ; $6BD3  box tag
    db $96                         ; $6BD4  end name/box tag
    db $2D,$2D,$37,$8D             ; $6BD5  ここて゛ = ここで
    db $90                         ; $6BD9  　(space)
    db $25,$25,$27,$38             ; $6BDA  いいえと
    db $90                         ; $6BDE  　(space)
    db $2D,$33,$27,$50,$38,$3E     ; $6BDF  こたえるとは
    db $99                         ; $6BE5  ！
    db $EF,$EE                     ; $6BE6  newline
    db $90,$90                     ; $6BE8  　　(indent)
    db $24,$39,$33                 ; $6BEA  あなた
    db $90                         ; $6BED  　(space)
    db $2F,$8D,$4B,$2B,$51,$55,$2F,$49,$37,$8D,$30,$39; $6BEE  し゛ゅくれんしゃて゛すな = じゅくれんしゃですな
    db $99                         ; $6BFA  ！
    db $F7                         ; $6BFB  clear page
    db $F0                         ; $6BFC  end of message


; --------------------------------------------------------------------------
; Message #134 ($6BFD)
;   「けんじゃのいしと　せかいじゅの
;   しずくは　[11][19]の　かいふくだよ。
;   「りょうほうとも　ぜんいんの[11][19]を
;   かいふくしてくれるんだ。
;   「けんじゃのいしは　なんべんか
;   つかえるけど　いつかこわれるよ。
;   「まほうのせいすいで　[16][19]を
;   かいふくできる。
;   「せかいじゅのはをつかえば　しんだ
;   なかまを　いきかえらせられる。
;   「ほねつきにくは　くんせいにくより
;   おいしい　おにくさ。
;   「まふうじのつえは　てきのまほうを
;   あやしいきりで　ふうじるんだ。
;   「レミラーマそうを　つかえば
;   まわりのちけいが　わかるよ。
;   「たびのしおりがあれば　ぼうけんの
;   しょを　どこでもつけられるんだ！
; --------------------------------------------------------------------------
Bank69_Msg134:                             ; $6BFD  (file $116BFD)
    db $EA                         ; $6BFD  ▶ new page
    db $9F                         ; $6BFE  box tag
    db $96                         ; $6BFF  end name/box tag
    db $2C,$55,$2F,$8D,$49,$3D,$25,$2F,$38; $6C00  けんし゛ゃのいしと = けんじゃのいしと
    db $90                         ; $6C09  　(space)
    db $31,$29,$25,$2F,$8D,$4B,$3D ; $6C0A  せかいし゛ゅの = せかいじゅの
    db $EF,$EE                     ; $6C11  newline
    db $90,$90                     ; $6C13  　　(indent)
    db $2F,$30,$8D,$2B,$3E         ; $6C15  しす゛くは = しずくは
    db $90                         ; $6C1A  　(space)
    db $11                         ; $6C1B  ctrl $11
    db $19                         ; $6C1C  ctrl $19
    db $3D                         ; $6C1D  の
    db $90                         ; $6C1E  　(space)
    db $29,$25,$40,$2B,$33,$8D,$4C ; $6C1F  かいふくた゛よ = かいふくだよ
    db $8F                         ; $6C26  。
    db $FA                         ; $6C27  wait-for-button
    db $F7                         ; $6C28  clear page
    db $EF,$EE                     ; $6C29  newline
    db $9F                         ; $6C2B  box tag
    db $96                         ; $6C2C  end name/box tag
    db $4F,$4D,$26,$42,$26,$38,$47 ; $6C2D  りょうほうとも
    db $90                         ; $6C34  　(space)
    db $31,$8D,$55,$25,$55,$3D     ; $6C35  せ゛んいんの = ぜんいんの
    db $11                         ; $6C3B  ctrl $11
    db $19                         ; $6C3C  ctrl $19
    db $54                         ; $6C3D  を
    db $EF,$EE                     ; $6C3E  newline
    db $90,$90                     ; $6C40  　　(indent)
    db $29,$25,$40,$2B,$2F,$37,$2B,$51,$50,$55,$33,$8D; $6C42  かいふくしてくれるんた゛ = かいふくしてくれるんだ
    db $8F                         ; $6C4E  。
    db $FA                         ; $6C4F  wait-for-button
    db $F7                         ; $6C50  clear page
    db $EF,$EE                     ; $6C51  newline
    db $9F                         ; $6C53  box tag
    db $96                         ; $6C54  end name/box tag
    db $2C,$55,$2F,$8D,$49,$3D,$25,$2F,$3E; $6C55  けんし゛ゃのいしは = けんじゃのいしは
    db $90                         ; $6C5E  　(space)
    db $39,$55,$41,$8D,$55,$29     ; $6C5F  なんへ゛んか = なんべんか
    db $EF,$EE                     ; $6C65  newline
    db $90,$90                     ; $6C67  　　(indent)
    db $35,$29,$27,$50,$2C,$38,$8D ; $6C69  つかえるけと゛ = つかえるけど
    db $90                         ; $6C70  　(space)
    db $25,$35,$29,$2D,$53,$51,$50,$4C; $6C71  いつかこわれるよ
    db $8F                         ; $6C79  。
    db $FA                         ; $6C7A  wait-for-button
    db $F7                         ; $6C7B  clear page
    db $EF,$EE                     ; $6C7C  newline
    db $9F                         ; $6C7E  box tag
    db $96                         ; $6C7F  end name/box tag
    db $43,$42,$26,$3D,$31,$25,$30,$25,$37,$8D; $6C80  まほうのせいすいて゛ = まほうのせいすいで
    db $90                         ; $6C8A  　(space)
    db $16                         ; $6C8B  ctrl $16
    db $19                         ; $6C8C  ctrl $19
    db $54                         ; $6C8D  を
    db $EF,$EE                     ; $6C8E  newline
    db $90,$90                     ; $6C90  　　(indent)
    db $29,$25,$40,$2B,$37,$8D,$2A,$50; $6C92  かいふくて゛きる = かいふくできる
    db $8F                         ; $6C9A  。
    db $FA                         ; $6C9B  wait-for-button
    db $F7                         ; $6C9C  clear page
    db $EF,$EE                     ; $6C9D  newline
    db $9F                         ; $6C9F  box tag
    db $96                         ; $6CA0  end name/box tag
    db $31,$29,$25,$2F,$8D,$4B,$3D,$3E,$54,$35,$29,$27,$3E,$8D; $6CA1  せかいし゛ゅのはをつかえは゛ = せかいじゅのはをつかえば
    db $90                         ; $6CAF  　(space)
    db $2F,$55,$33,$8D             ; $6CB0  しんた゛ = しんだ
    db $EF,$EE                     ; $6CB4  newline
    db $90,$90                     ; $6CB6  　　(indent)
    db $39,$29,$43,$54             ; $6CB8  なかまを
    db $90                         ; $6CBC  　(space)
    db $25,$2A,$29,$27,$4E,$31,$4E,$51,$50; $6CBD  いきかえらせられる
    db $8F                         ; $6CC6  。
    db $FA                         ; $6CC7  wait-for-button
    db $F7                         ; $6CC8  clear page
    db $EF,$EE                     ; $6CC9  newline
    db $9F                         ; $6CCB  box tag
    db $96                         ; $6CCC  end name/box tag
    db $42,$3C,$35,$2A,$3A,$2B,$3E ; $6CCD  ほねつきにくは
    db $90                         ; $6CD4  　(space)
    db $2B,$55,$31,$25,$3A,$2B,$4C,$4F; $6CD5  くんせいにくより
    db $EF,$EE                     ; $6CDD  newline
    db $90,$90                     ; $6CDF  　　(indent)
    db $28,$25,$2F,$25             ; $6CE1  おいしい
    db $90                         ; $6CE5  　(space)
    db $28,$3A,$2B,$2E             ; $6CE6  おにくさ
    db $8F                         ; $6CEA  。
    db $FA                         ; $6CEB  wait-for-button
    db $F7                         ; $6CEC  clear page
    db $EF,$EE                     ; $6CED  newline
    db $9F                         ; $6CEF  box tag
    db $96                         ; $6CF0  end name/box tag
    db $43,$40,$26,$2F,$8D,$3D,$35,$27,$3E; $6CF1  まふうし゛のつえは = まふうじのつえは
    db $90                         ; $6CFA  　(space)
    db $37,$2A,$3D,$43,$42,$26,$54 ; $6CFB  てきのまほうを
    db $EF,$EE                     ; $6D02  newline
    db $90,$90                     ; $6D04  　　(indent)
    db $24,$48,$2F,$25,$2A,$4F,$37,$8D; $6D06  あやしいきりて゛ = あやしいきりで
    db $90                         ; $6D0E  　(space)
    db $40,$26,$2F,$8D,$50,$55,$33,$8D; $6D0F  ふうし゛るんた゛ = ふうじるんだ
    db $8F                         ; $6D17  。
    db $FA                         ; $6D18  wait-for-button
    db $F7                         ; $6D19  clear page
    db $EF,$EE                     ; $6D1A  newline
    db $9F                         ; $6D1C  box tag
    db $96                         ; $6D1D  end name/box tag
    db $88,$7B,$85,$9C,$7A,$32,$26,$54; $6D1E  レミラーマそうを
    db $90                         ; $6D26  　(space)
    db $35,$29,$27,$3E,$8D         ; $6D27  つかえは゛ = つかえば
    db $EF,$EE                     ; $6D2C  newline
    db $90,$90                     ; $6D2E  　　(indent)
    db $43,$53,$4F,$3D,$34,$2C,$25,$29,$8D; $6D30  まわりのちけいか゛ = まわりのちけいが
    db $90                         ; $6D39  　(space)
    db $53,$29,$50,$4C             ; $6D3A  わかるよ
    db $8F                         ; $6D3E  。
    db $FA                         ; $6D3F  wait-for-button
    db $F7                         ; $6D40  clear page
    db $EF,$EE                     ; $6D41  newline
    db $9F                         ; $6D43  box tag
    db $96                         ; $6D44  end name/box tag
    db $33,$3F,$8D,$3D,$2F,$28,$4F,$29,$8D,$24,$51,$3E,$8D; $6D45  たひ゛のしおりか゛あれは゛ = たびのしおりがあれば
    db $90                         ; $6D52  　(space)
    db $42,$8D,$26,$2C,$55,$3D     ; $6D53  ほ゛うけんの = ぼうけんの
    db $EF,$EE                     ; $6D59  newline
    db $90,$90                     ; $6D5B  　　(indent)
    db $2F,$4D,$54                 ; $6D5D  しょを
    db $90                         ; $6D60  　(space)
    db $38,$8D,$2D,$37,$8D,$47,$35,$2C,$4E,$51,$50,$55,$33,$8D; $6D61  と゛こて゛もつけられるんた゛ = どこでもつけられるんだ
    db $99                         ; $6D6F  ！
    db $F7                         ; $6D70  clear page
    db $F0                         ; $6D71  end of message


; --------------------------------------------------------------------------
; Message #135 ($6D72)
;   「おみせで　うっているものを
;   としょかんでしらべたんだ。きく？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg135:                             ; $6D72  (file $116D72)
    db $EA                         ; $6D72  ▶ new page
    db $9F                         ; $6D73  box tag
    db $96                         ; $6D74  end name/box tag
    db $28,$44,$31,$37,$8D         ; $6D75  おみせて゛ = おみせで
    db $90                         ; $6D7A  　(space)
    db $26,$36,$37,$25,$50,$47,$3D,$54; $6D7B  うっているものを
    db $EF,$EE                     ; $6D83  newline
    db $90,$90                     ; $6D85  　　(indent)
    db $38,$2F,$4D,$29,$55,$37,$8D,$2F,$4E,$41,$8D,$33,$55,$33,$8D; $6D87  としょかんて゛しらへ゛たんた゛ = としょかんでしらべたんだ
    db $8F                         ; $6D96  。
    db $2A,$2B                     ; $6D97  きく
    db $98                         ; $6D99  ？
    db $FF                         ; $6D9A  はい/いいえ
    db $F0                         ; $6D9B  end of message


; --------------------------------------------------------------------------
; Message #136 ($6D9C)
;   「タィジャのしんどうが　おこった！
;   おかげで　みてのとおりだ！
;   「あのしょうにん　はぐれちまった！
;   ハーハッハッハ！
; --------------------------------------------------------------------------
Bank69_Msg136:                             ; $6D9C  (file $116D9C)
    db $EA                         ; $6D9C  ▶ new page
    db $9F                         ; $6D9D  box tag
    db $96                         ; $6D9E  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D,$2F,$55,$38,$8D,$26,$29,$8D; $6D9F  タィシ゛ャのしんと゛うか゛ = タィジャのしんどうが
    db $90                         ; $6DAC  　(space)
    db $28,$2D,$36,$33             ; $6DAD  おこった
    db $99                         ; $6DB1  ！
    db $EF,$EE                     ; $6DB2  newline
    db $90,$90                     ; $6DB4  　　(indent)
    db $28,$29,$2C,$8D,$37,$8D     ; $6DB6  おかけ゛て゛ = おかげで
    db $90                         ; $6DBC  　(space)
    db $44,$37,$3D,$38,$28,$4F,$33,$8D; $6DBD  みてのとおりた゛ = みてのとおりだ
    db $99                         ; $6DC5  ！
    db $FA                         ; $6DC6  wait-for-button
    db $F7                         ; $6DC7  clear page
    db $EF,$EE                     ; $6DC8  newline
    db $9F                         ; $6DCA  box tag
    db $96                         ; $6DCB  end name/box tag
    db $24,$3D,$2F,$4D,$26,$3A,$55 ; $6DCC  あのしょうにん
    db $90                         ; $6DD3  　(space)
    db $3E,$2B,$8D,$51,$34,$43,$36,$33; $6DD4  はく゛れちまった = はぐれちまった
    db $99                         ; $6DDC  ！
    db $EF,$EE                     ; $6DDD  newline
    db $90,$90                     ; $6DDF  　　(indent)
    db $75,$9C,$75,$6D,$75,$6D,$75 ; $6DE1  ハーハッハッハ
    db $99                         ; $6DE8  ！
    db $F7                         ; $6DE9  clear page
    db $F0                         ; $6DEA  end of message


; --------------------------------------------------------------------------
; Message #137 ($6DEB)
;   「このあたり　なにも　なくって
;   さびしいと　おもいませんか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg137:                             ; $6DEB  (file $116DEB)
    db $EA                         ; $6DEB  ▶ new page
    db $9F                         ; $6DEC  box tag
    db $96                         ; $6DED  end name/box tag
    db $2D,$3D,$24,$33,$4F         ; $6DEE  このあたり
    db $90                         ; $6DF3  　(space)
    db $39,$3A,$47                 ; $6DF4  なにも
    db $90                         ; $6DF7  　(space)
    db $39,$2B,$36,$37             ; $6DF8  なくって
    db $EF,$EE                     ; $6DFC  newline
    db $90,$90                     ; $6DFE  　　(indent)
    db $2E,$3F,$8D,$2F,$25,$38     ; $6E00  さひ゛しいと = さびしいと
    db $90                         ; $6E06  　(space)
    db $28,$47,$25,$43,$31,$55,$29 ; $6E07  おもいませんか
    db $98                         ; $6E0E  ？
    db $FF                         ; $6E0F  はい/いいえ
    db $F0                         ; $6E10  end of message


; --------------------------------------------------------------------------
; Message #138 ($6E11)
;   「おみせでも　たてば　にぎやかに
;   なるんでしょうがね、、。
; --------------------------------------------------------------------------
Bank69_Msg138:                             ; $6E11  (file $116E11)
    db $EA                         ; $6E11  ▶ new page
    db $9F                         ; $6E12  box tag
    db $96                         ; $6E13  end name/box tag
    db $28,$44,$31,$37,$8D,$47     ; $6E14  おみせて゛も = おみせでも
    db $90                         ; $6E1A  　(space)
    db $33,$37,$3E,$8D             ; $6E1B  たては゛ = たてば
    db $90                         ; $6E1F  　(space)
    db $3A,$2A,$8D,$48,$29,$3A     ; $6E20  にき゛やかに = にぎやかに
    db $EF,$EE                     ; $6E26  newline
    db $90,$90                     ; $6E28  　　(indent)
    db $39,$50,$55,$37,$8D,$2F,$4D,$26,$29,$8D,$3C; $6E2A  なるんて゛しょうか゛ね = なるんでしょうがね
    db $A4                         ; $6E35  、
    db $A4                         ; $6E36  、
    db $8F                         ; $6E37  。
    db $F7                         ; $6E38  clear page
    db $F0                         ; $6E39  end of message


; --------------------------------------------------------------------------
; Message #139 ($6E3A)
;   「そんなこと　いわないでくださいよ
;   ほしふりのよるも　ちかいんだし！
; --------------------------------------------------------------------------
Bank69_Msg139:                             ; $6E3A  (file $116E3A)
    db $EA                         ; $6E3A  ▶ new page
    db $9F                         ; $6E3B  box tag
    db $96                         ; $6E3C  end name/box tag
    db $32,$55,$39,$2D,$38         ; $6E3D  そんなこと
    db $90                         ; $6E42  　(space)
    db $25,$53,$39,$25,$37,$8D,$2B,$33,$8D,$2E,$25,$4C; $6E43  いわないて゛くた゛さいよ = いわないでくださいよ
    db $EF,$EE                     ; $6E4F  newline
    db $90,$90                     ; $6E51  　　(indent)
    db $42,$2F,$40,$4F,$3D,$4C,$50,$47; $6E53  ほしふりのよるも
    db $90                         ; $6E5B  　(space)
    db $34,$29,$25,$55,$33,$8D,$2F ; $6E5C  ちかいんた゛し = ちかいんだし
    db $99                         ; $6E63  ！
    db $F7                         ; $6E64  clear page
    db $F0                         ; $6E65  end of message


; --------------------------------------------------------------------------
; Message #140 ($6E66)
;   「フム、　このくにには　かくされた
;   とびらが　いくつかあるようじゃ。
;   「どこにあるかは　わからぬが、
;   そなたの　やくにたつようじゃな。
; --------------------------------------------------------------------------
Bank69_Msg140:                             ; $6E66  (file $116E66)
    db $EB                         ; $6E66  ▶ new page
    db $9F                         ; $6E67  box tag
    db $96                         ; $6E68  end name/box tag
    db $77,$7C                     ; $6E69  フム
    db $A4                         ; $6E6B  、
    db $90                         ; $6E6C  　(space)
    db $2D,$3D,$2B,$3A,$3A,$3E     ; $6E6D  このくにには
    db $90                         ; $6E73  　(space)
    db $29,$2B,$2E,$51,$33         ; $6E74  かくされた
    db $EF,$EE                     ; $6E79  newline
    db $90,$90                     ; $6E7B  　　(indent)
    db $38,$3F,$8D,$4E,$29,$8D     ; $6E7D  とひ゛らか゛ = とびらが
    db $90                         ; $6E83  　(space)
    db $25,$2B,$35,$29,$24,$50,$4C,$26,$2F,$8D,$49; $6E84  いくつかあるようし゛ゃ = いくつかあるようじゃ
    db $8F                         ; $6E8F  。
    db $FA                         ; $6E90  wait-for-button
    db $F7                         ; $6E91  clear page
    db $EF,$EE                     ; $6E92  newline
    db $9F                         ; $6E94  box tag
    db $96                         ; $6E95  end name/box tag
    db $38,$8D,$2D,$3A,$24,$50,$29,$3E; $6E96  と゛こにあるかは = どこにあるかは
    db $90                         ; $6E9E  　(space)
    db $53,$29,$4E,$3B,$29,$8D     ; $6E9F  わからぬか゛ = わからぬが
    db $A4                         ; $6EA5  、
    db $EF,$EE                     ; $6EA6  newline
    db $90,$90                     ; $6EA8  　　(indent)
    db $32,$39,$33,$3D             ; $6EAA  そなたの
    db $90                         ; $6EAE  　(space)
    db $48,$2B,$3A,$33,$35,$4C,$26,$2F,$8D,$49,$39; $6EAF  やくにたつようし゛ゃな = やくにたつようじゃな
    db $8F                         ; $6EBA  。
    db $F7                         ; $6EBB  clear page
    db $F0                         ; $6EBC  end of message


; --------------------------------------------------------------------------
; Message #141 ($6EBD)
;   「まんなかのへやが
;   ちからといかりのへやです。
;   「みぎが
;   やすらぎとゆうきのへやです。
; --------------------------------------------------------------------------
Bank69_Msg141:                             ; $6EBD  (file $116EBD)
    db $EA                         ; $6EBD  ▶ new page
    db $9F                         ; $6EBE  box tag
    db $96                         ; $6EBF  end name/box tag
    db $43,$55,$39,$29,$3D,$41,$48,$29,$8D; $6EC0  まんなかのへやか゛ = まんなかのへやが
    db $EF,$EE                     ; $6EC9  newline
    db $90,$90                     ; $6ECB  　　(indent)
    db $34,$29,$4E,$38,$25,$29,$4F,$3D,$41,$48,$37,$8D,$30; $6ECD  ちからといかりのへやて゛す = ちからといかりのへやです
    db $8F                         ; $6EDA  。
    db $FA                         ; $6EDB  wait-for-button
    db $F7                         ; $6EDC  clear page
    db $EF,$EE                     ; $6EDD  newline
    db $9F                         ; $6EDF  box tag
    db $96                         ; $6EE0  end name/box tag
    db $44,$2A,$8D,$29,$8D         ; $6EE1  みき゛か゛ = みぎが
    db $EF,$EE                     ; $6EE6  newline
    db $90,$90                     ; $6EE8  　　(indent)
    db $48,$30,$4E,$2A,$8D,$38,$4A,$26,$2A,$3D,$41,$48,$37,$8D,$30; $6EEA  やすらき゛とゆうきのへやて゛す = やすらぎとゆうきのへやです
    db $8F                         ; $6EF9  。
    db $F7                         ; $6EFA  clear page
    db $F0                         ; $6EFB  end of message


; --------------------------------------------------------------------------
; Message #142 ($6EFC)
;   「ここは　たびのとびらのまです。
;   「ひだりが
;   まちびととまもりのへや。
;   「まんなかが
;   たびだちのへや。
;   「みぎが
;   おもいでととまどいのへやです。
; --------------------------------------------------------------------------
Bank69_Msg142:                             ; $6EFC  (file $116EFC)
    db $EA                         ; $6EFC  ▶ new page
    db $9F                         ; $6EFD  box tag
    db $96                         ; $6EFE  end name/box tag
    db $2D,$2D,$3E                 ; $6EFF  ここは
    db $90                         ; $6F02  　(space)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D,$43,$37,$8D,$30; $6F03  たひ゛のとひ゛らのまて゛す = たびのとびらのまです
    db $8F                         ; $6F10  。
    db $EF,$EE                     ; $6F11  newline
    db $FA                         ; $6F13  wait-for-button
    db $F7                         ; $6F14  clear page
    db $EF,$EE                     ; $6F15  newline
    db $F3                         ; $6F17  open text box
    db $9F                         ; $6F18  box tag
    db $96                         ; $6F19  end name/box tag
    db $3F,$33,$8D,$4F,$29,$8D     ; $6F1A  ひた゛りか゛ = ひだりが
    db $EF,$EE                     ; $6F20  newline
    db $90,$90                     ; $6F22  　　(indent)
    db $43,$34,$3F,$8D,$38,$38,$43,$47,$4F,$3D,$41,$48; $6F24  まちひ゛ととまもりのへや = まちびととまもりのへや
    db $8F                         ; $6F30  。
    db $FA                         ; $6F31  wait-for-button
    db $F7                         ; $6F32  clear page
    db $EF,$EE                     ; $6F33  newline
    db $9F                         ; $6F35  box tag
    db $96                         ; $6F36  end name/box tag
    db $43,$55,$39,$29,$29,$8D     ; $6F37  まんなかか゛ = まんなかが
    db $EF,$EE                     ; $6F3D  newline
    db $90,$90                     ; $6F3F  　　(indent)
    db $33,$3F,$8D,$33,$8D,$34,$3D,$41,$48; $6F41  たひ゛た゛ちのへや = たびだちのへや
    db $8F                         ; $6F4A  。
    db $FA                         ; $6F4B  wait-for-button
    db $F7                         ; $6F4C  clear page
    db $EF,$EE                     ; $6F4D  newline
    db $9F                         ; $6F4F  box tag
    db $96                         ; $6F50  end name/box tag
    db $44,$2A,$8D,$29,$8D         ; $6F51  みき゛か゛ = みぎが
    db $EF,$EE                     ; $6F56  newline
    db $90,$90                     ; $6F58  　　(indent)
    db $28,$47,$25,$37,$8D,$38,$38,$43,$38,$8D,$25,$3D,$41,$48,$37,$8D,$30; $6F5A  おもいて゛ととまと゛いのへやて゛す = おもいでととまどいのへやです
    db $8F                         ; $6F6B  。
    db $F7                         ; $6F6C  clear page
    db $F0                         ; $6F6D  end of message


; --------------------------------------------------------------------------
; Message #143 ($6F6E)
;   ペチョ！
;   〈テリー〉に　あたったフンは
;   やわらかかった。
; --------------------------------------------------------------------------
Bank69_Msg143:                             ; $6F6E  (file $116F6E)
    db $78,$8E,$6B,$84             ; $6F6E  ヘ゜チョ = ペチョ
    db $99                         ; $6F72  ！
    db $EF,$EE                     ; $6F73  newline
    db $FA                         ; $6F75  wait-for-button
    db $F7                         ; $6F76  clear page
    db $EF,$EE                     ; $6F77  newline
    db $F3                         ; $6F79  open text box
    db $F6                         ; $6F7A  «insert hero name»
    db $3A                         ; $6F7B  に
    db $90                         ; $6F7C  　(space)
    db $24,$33,$36,$33,$77,$8C,$3E ; $6F7D  あたったフンは
    db $EF,$EE                     ; $6F84  newline
    db $48,$53,$4E,$29,$29,$36,$33 ; $6F86  やわらかかった
    db $8F                         ; $6F8D  。
    db $F7                         ; $6F8E  clear page
    db $F0                         ; $6F8F  end of message


; --------------------------------------------------------------------------
; Message #144 ($6F90)
;   「われわれ　まものは　どうやって
;   うまれてきたのだろうか？
;   「たまに　そんなことをかんがえると
;   よるも　ねむれなくなる。
; --------------------------------------------------------------------------
Bank69_Msg144:                             ; $6F90  (file $116F90)
    db $EA                         ; $6F90  ▶ new page
    db $9F                         ; $6F91  box tag
    db $96                         ; $6F92  end name/box tag
    db $53,$51,$53,$51             ; $6F93  われわれ
    db $90                         ; $6F97  　(space)
    db $43,$47,$3D,$3E             ; $6F98  まものは
    db $90                         ; $6F9C  　(space)
    db $38,$8D,$26,$48,$36,$37     ; $6F9D  と゛うやって = どうやって
    db $EF,$EE                     ; $6FA3  newline
    db $90,$90                     ; $6FA5  　　(indent)
    db $26,$43,$51,$37,$2A,$33,$3D,$33,$8D,$52,$26,$29; $6FA7  うまれてきたのた゛ろうか = うまれてきたのだろうか
    db $98                         ; $6FB3  ？
    db $FA                         ; $6FB4  wait-for-button
    db $F7                         ; $6FB5  clear page
    db $EF,$EE                     ; $6FB6  newline
    db $9F                         ; $6FB8  box tag
    db $96                         ; $6FB9  end name/box tag
    db $33,$43,$3A                 ; $6FBA  たまに
    db $90                         ; $6FBD  　(space)
    db $32,$55,$39,$2D,$38,$54,$29,$55,$29,$8D,$27,$50,$38; $6FBE  そんなことをかんか゛えると = そんなことをかんがえると
    db $EF,$EE                     ; $6FCB  newline
    db $90,$90                     ; $6FCD  　　(indent)
    db $4C,$50,$47                 ; $6FCF  よるも
    db $90                         ; $6FD2  　(space)
    db $3C,$45,$51,$39,$2B,$39,$50 ; $6FD3  ねむれなくなる
    db $8F                         ; $6FDA  。
    db $F7                         ; $6FDB  clear page
    db $F0                         ; $6FDC  end of message


; --------------------------------------------------------------------------
; Message #145 ($6FDD)
;   「おお　みてください！
;   がけが　つながりました！
;   「タィジャの　せいれいよ！
;   かんしゃしますっ！
; --------------------------------------------------------------------------
Bank69_Msg145:                             ; $6FDD  (file $116FDD)
    db $EA                         ; $6FDD  ▶ new page
    db $9F                         ; $6FDE  box tag
    db $96                         ; $6FDF  end name/box tag
    db $28,$28                     ; $6FE0  おお
    db $90                         ; $6FE2  　(space)
    db $44,$37,$2B,$33,$8D,$2E,$25 ; $6FE3  みてくた゛さい = みてください
    db $99                         ; $6FEA  ！
    db $EF,$EE                     ; $6FEB  newline
    db $90,$90                     ; $6FED  　　(indent)
    db $29,$8D,$2C,$29,$8D         ; $6FEF  か゛けか゛ = がけが
    db $90                         ; $6FF4  　(space)
    db $35,$39,$29,$8D,$4F,$43,$2F,$33; $6FF5  つなか゛りました = つながりました
    db $99                         ; $6FFD  ！
    db $FA                         ; $6FFE  wait-for-button
    db $F7                         ; $6FFF  clear page
    db $EF,$EE                     ; $7000  newline
    db $9F                         ; $7002  box tag
    db $96                         ; $7003  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D     ; $7004  タィシ゛ャの = タィジャの
    db $90                         ; $700A  　(space)
    db $31,$25,$51,$25,$4C         ; $700B  せいれいよ
    db $99                         ; $7010  ！
    db $EF,$EE                     ; $7011  newline
    db $90,$90                     ; $7013  　　(indent)
    db $29,$55,$2F,$49,$2F,$43,$30,$36; $7015  かんしゃしますっ
    db $99                         ; $701D  ！
    db $F7                         ; $701E  clear page
    db $F0                         ; $701F  end of message


; --------------------------------------------------------------------------
; Message #146 ($7020)
;   「おお　ダーリン！
;   チャパ　チャパ！！
; --------------------------------------------------------------------------
Bank69_Msg146:                             ; $7020  (file $117020)
    db $EB                         ; $7020  ▶ new page
    db $9F                         ; $7021  box tag
    db $96                         ; $7022  end name/box tag
    db $28,$28                     ; $7023  おお
    db $90                         ; $7025  　(space)
    db $6A,$8D,$9C,$86,$8C         ; $7026  タ゛ーリン = ダーリン
    db $99                         ; $702B  ！
    db $EF,$EE                     ; $702C  newline
    db $90,$90                     ; $702E  　　(indent)
    db $6B,$82,$75,$8E             ; $7030  チャハ゜ = チャパ
    db $90                         ; $7034  　(space)
    db $6B,$82,$75,$8E             ; $7035  チャハ゜ = チャパ
    db $99                         ; $7039  ！
    db $99                         ; $703A  ！
    db $F7                         ; $703B  clear page
    db $F0                         ; $703C  end of message


; --------------------------------------------------------------------------
; Message #147 ($703D)
;   「こんにちは　このしたは
;   ぼくしゃだ　メエ[9D]。
; --------------------------------------------------------------------------
Bank69_Msg147:                             ; $703D  (file $11703D)
    db $EA                         ; $703D  ▶ new page
    db $9F                         ; $703E  box tag
    db $96                         ; $703F  end name/box tag
    db $2D,$55,$3A,$34,$3E         ; $7040  こんにちは
    db $90                         ; $7045  　(space)
    db $2D,$3D,$2F,$33,$3E         ; $7046  このしたは
    db $EF,$EE                     ; $704B  newline
    db $90,$90                     ; $704D  　　(indent)
    db $42,$8D,$2B,$2F,$49,$33,$8D ; $704F  ほ゛くしゃた゛ = ぼくしゃだ
    db $90                         ; $7056  　(space)
    db $7D,$5D                     ; $7057  メエ
    db $9D                         ; $7059  ctrl $9D
    db $8F                         ; $705A  。
    db $F7                         ; $705B  clear page
    db $F0                         ; $705C  end of message


; --------------------------------------------------------------------------
; Message #148 ($705D)
;   「たいてい　ガラクタばっかりだけど
;   たまには　いいものが　つれるよ！
; --------------------------------------------------------------------------
Bank69_Msg148:                             ; $705D  (file $11705D)
    db $EA                         ; $705D  ▶ new page
    db $9F                         ; $705E  box tag
    db $96                         ; $705F  end name/box tag
    db $33,$25,$37,$25             ; $7060  たいてい
    db $90                         ; $7064  　(space)
    db $60,$8D,$85,$62,$6A,$3E,$8D,$36,$29,$4F,$33,$8D,$2C,$38,$8D; $7065  カ゛ラクタは゛っかりた゛けと゛ = ガラクタばっかりだけど
    db $EF,$EE                     ; $7074  newline
    db $90,$90                     ; $7076  　　(indent)
    db $33,$43,$3A,$3E             ; $7078  たまには
    db $90                         ; $707C  　(space)
    db $25,$25,$47,$3D,$29,$8D     ; $707D  いいものか゛ = いいものが
    db $90                         ; $7083  　(space)
    db $35,$51,$50,$4C             ; $7084  つれるよ
    db $99                         ; $7088  ！
    db $F7                         ; $7089  clear page
    db $F0                         ; $708A  end of message


; --------------------------------------------------------------------------
; Message #149 ($708B)
;   「なかまの　せいちょうのげんかいを
;   おしえてあげようか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg149:                             ; $708B  (file $11708B)
    db $EA                         ; $708B  ▶ new page
    db $9F                         ; $708C  box tag
    db $96                         ; $708D  end name/box tag
    db $39,$29,$43,$3D             ; $708E  なかまの
    db $90                         ; $7092  　(space)
    db $31,$25,$34,$4D,$26,$3D,$2C,$8D,$55,$29,$25,$54; $7093  せいちょうのけ゛んかいを = せいちょうのげんかいを
    db $EF,$EE                     ; $709F  newline
    db $90,$90                     ; $70A1  　　(indent)
    db $28,$2F,$27,$37,$24,$2C,$8D,$4C,$26,$29; $70A3  おしえてあけ゛ようか = おしえてあげようか
    db $98                         ; $70AD  ？
    db $FF                         ; $70AE  はい/いいえ
    db $F0                         ; $70AF  end of message


; --------------------------------------------------------------------------
; Message #150 ($70B0)
;   「わたしね　こうみえても
;   じゅみょう　ながいのよ。
;   「なまえのところに　[A2][05]が
;   ついてるからだって！
;   「でも　なんのことだか
;   さっぱり　わからないわ。
; --------------------------------------------------------------------------
Bank69_Msg150:                             ; $70B0  (file $1170B0)
    db $EB                         ; $70B0  ▶ new page
    db $9F                         ; $70B1  box tag
    db $96                         ; $70B2  end name/box tag
    db $53,$33,$2F,$3C             ; $70B3  わたしね
    db $90                         ; $70B7  　(space)
    db $2D,$26,$44,$27,$37,$47     ; $70B8  こうみえても
    db $EF,$EE                     ; $70BE  newline
    db $90,$90                     ; $70C0  　　(indent)
    db $2F,$8D,$4B,$44,$4D,$26     ; $70C2  し゛ゅみょう = じゅみょう
    db $90                         ; $70C8  　(space)
    db $39,$29,$8D,$25,$3D,$4C     ; $70C9  なか゛いのよ = ながいのよ
    db $8F                         ; $70CF  。
    db $FA                         ; $70D0  wait-for-button
    db $F7                         ; $70D1  clear page
    db $EF,$EE                     ; $70D2  newline
    db $9F                         ; $70D4  box tag
    db $96                         ; $70D5  end name/box tag
    db $39,$43,$27,$3D,$38,$2D,$52,$3A; $70D6  なまえのところに
    db $90                         ; $70DE  　(space)
    db $A2                         ; $70DF  ctrl $A2
    db $05                         ; $70E0  ctrl $05
    db $29,$8D                     ; $70E1  か゛ = が
    db $EF,$EE                     ; $70E3  newline
    db $90,$90                     ; $70E5  　　(indent)
    db $35,$25,$37,$50,$29,$4E,$33,$8D,$36,$37; $70E7  ついてるからた゛って = ついてるからだって
    db $99                         ; $70F1  ！
    db $FA                         ; $70F2  wait-for-button
    db $F7                         ; $70F3  clear page
    db $EF,$EE                     ; $70F4  newline
    db $9F                         ; $70F6  box tag
    db $96                         ; $70F7  end name/box tag
    db $37,$8D,$47                 ; $70F8  て゛も = でも
    db $90                         ; $70FB  　(space)
    db $39,$55,$3D,$2D,$38,$33,$8D,$29; $70FC  なんのことた゛か = なんのことだか
    db $EF,$EE                     ; $7104  newline
    db $90,$90                     ; $7106  　　(indent)
    db $2E,$36,$3E,$8E,$4F         ; $7108  さっは゜り = さっぱり
    db $90                         ; $710D  　(space)
    db $53,$29,$4E,$39,$25,$53     ; $710E  わからないわ
    db $8F                         ; $7114  。
    db $F7                         ; $7115  clear page
    db $F0                         ; $7116  end of message


; --------------------------------------------------------------------------
; Message #151 ($7117)
;   「やすらぎの　とびらが　おらっちの
;   こきょうなんだべ。
; --------------------------------------------------------------------------
Bank69_Msg151:                             ; $7117  (file $117117)
    db $EA                         ; $7117  ▶ new page
    db $9F                         ; $7118  box tag
    db $96                         ; $7119  end name/box tag
    db $48,$30,$4E,$2A,$8D,$3D     ; $711A  やすらき゛の = やすらぎの
    db $90                         ; $7120  　(space)
    db $38,$3F,$8D,$4E,$29,$8D     ; $7121  とひ゛らか゛ = とびらが
    db $90                         ; $7127  　(space)
    db $28,$4E,$36,$34,$3D         ; $7128  おらっちの
    db $EF,$EE                     ; $712D  newline
    db $90,$90                     ; $712F  　　(indent)
    db $2D,$2A,$4D,$26,$39,$55,$33,$8D,$41,$8D; $7131  こきょうなんた゛へ゛ = こきょうなんだべ
    db $8F                         ; $713B  。
    db $F7                         ; $713C  clear page
    db $F0                         ; $713D  end of message


; --------------------------------------------------------------------------
; Message #152 ($713E)
;   「ぼくじょうの　へんかを
;   みましたかいのう？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg152:                             ; $713E  (file $11713E)
    db $EA                         ; $713E  ▶ new page
    db $9F                         ; $713F  box tag
    db $96                         ; $7140  end name/box tag
    db $42,$8D,$2B,$2F,$8D,$4D,$26,$3D; $7141  ほ゛くし゛ょうの = ぼくじょうの
    db $90                         ; $7149  　(space)
    db $41,$55,$29,$54             ; $714A  へんかを
    db $EF,$EE                     ; $714E  newline
    db $90,$90                     ; $7150  　　(indent)
    db $44,$43,$2F,$33,$29,$25,$3D,$26; $7152  みましたかいのう
    db $98                         ; $715A  ？
    db $FF                         ; $715B  はい/いいえ
    db $F0                         ; $715C  end of message


; --------------------------------------------------------------------------
; Message #153 ($715D)
;   「あくまのきしどんが　やっと
;   リップスどんに　あえもうしたな。
; --------------------------------------------------------------------------
Bank69_Msg153:                             ; $715D  (file $11715D)
    db $EA                         ; $715D  ▶ new page
    db $9F                         ; $715E  box tag
    db $96                         ; $715F  end name/box tag
    db $24,$2B,$43,$3D,$2A,$2F,$38,$8D,$55,$29,$8D; $7160  あくまのきしと゛んか゛ = あくまのきしどんが
    db $90                         ; $716B  　(space)
    db $48,$36,$38                 ; $716C  やっと
    db $EF,$EE                     ; $716F  newline
    db $90,$90                     ; $7171  　　(indent)
    db $86,$6D,$77,$8E,$67,$38,$8D,$55,$3A; $7173  リッフ゜スと゛んに = リップスどんに
    db $90                         ; $717C  　(space)
    db $24,$27,$47,$26,$2F,$33,$39 ; $717D  あえもうしたな
    db $8F                         ; $7184  。
    db $F7                         ; $7185  clear page
    db $F0                         ; $7186  end of message


; --------------------------------------------------------------------------
; Message #154 ($7187)
;   「はよう　いきなされ。
;   いいものが　みれますぞ！
; --------------------------------------------------------------------------
Bank69_Msg154:                             ; $7187  (file $117187)
    db $EA                         ; $7187  ▶ new page
    db $9F                         ; $7188  box tag
    db $96                         ; $7189  end name/box tag
    db $3E,$4C,$26                 ; $718A  はよう
    db $90                         ; $718D  　(space)
    db $25,$2A,$39,$2E,$51         ; $718E  いきなされ
    db $8F                         ; $7193  。
    db $EF,$EE                     ; $7194  newline
    db $90,$90                     ; $7196  　　(indent)
    db $25,$25,$47,$3D,$29,$8D     ; $7198  いいものか゛ = いいものが
    db $90                         ; $719E  　(space)
    db $44,$51,$43,$30,$32,$8D     ; $719F  みれますそ゛ = みれますぞ
    db $99                         ; $71A5  ！
    db $F7                         ; $71A6  clear page
    db $F0                         ; $71A7  end of message


; --------------------------------------------------------------------------
; Message #155 ($71A8)
;   「マドハンドは　ジユンケンが
;   すきでしてのう。
;   「きょうだいが　あと　なんにんか
;   このくにに　いるらしいですじゃ。
; --------------------------------------------------------------------------
Bank69_Msg155:                             ; $71A8  (file $1171A8)
    db $EA                         ; $71A8  ▶ new page
    db $9F                         ; $71A9  box tag
    db $96                         ; $71AA  end name/box tag
    db $7A,$6F,$8D,$75,$8C,$6F,$8D,$3E; $71AB  マト゛ハント゛は = マドハンドは
    db $90                         ; $71B3  　(space)
    db $66,$8D,$80,$8C,$63,$8C,$29,$8D; $71B4  シ゛ユンケンか゛ = ジユンケンが
    db $EF,$EE                     ; $71BC  newline
    db $90,$90                     ; $71BE  　　(indent)
    db $30,$2A,$37,$8D,$2F,$37,$3D,$26; $71C0  すきて゛してのう = すきでしてのう
    db $8F                         ; $71C8  。
    db $FA                         ; $71C9  wait-for-button
    db $F7                         ; $71CA  clear page
    db $EF,$EE                     ; $71CB  newline
    db $9F                         ; $71CD  box tag
    db $96                         ; $71CE  end name/box tag
    db $2A,$4D,$26,$33,$8D,$25,$29,$8D; $71CF  きょうた゛いか゛ = きょうだいが
    db $90                         ; $71D7  　(space)
    db $24,$38                     ; $71D8  あと
    db $90                         ; $71DA  　(space)
    db $39,$55,$3A,$55,$29         ; $71DB  なんにんか
    db $EF,$EE                     ; $71E0  newline
    db $90,$90                     ; $71E2  　　(indent)
    db $2D,$3D,$2B,$3A,$3A         ; $71E4  このくにに
    db $90                         ; $71E9  　(space)
    db $25,$50,$4E,$2F,$25,$37,$8D,$30,$2F,$8D,$49; $71EA  いるらしいて゛すし゛ゃ = いるらしいですじゃ
    db $8F                         ; $71F5  。
    db $F7                         ; $71F6  clear page
    db $F0                         ; $71F7  end of message


; --------------------------------------------------------------------------
; Message #156 ($71F8)
;   「おお　〈テリー〉か。
;   まっておったぞい！
;   「[0C]クラスいじょうを　うけることを
;   おうさまが　ゆるされたぞい！
;   「タィジャの　だいひょうになるには
;   [1C]クラスを　かちぬくのじゃ！
;   「[1C]クラスを　かちぬいたものだけが
;   たいかいに　しゅつじょうできる！
;   「いきなり　[1C]クラスを　うけるのも
;   ゆるされておるぞ！
;   「では　どのクラスを　うけるかの？
; --------------------------------------------------------------------------
Bank69_Msg156:                             ; $71F8  (file $1171F8)
    db $EA                         ; $71F8  ▶ new page
    db $9F                         ; $71F9  box tag
    db $96                         ; $71FA  end name/box tag
    db $28,$28                     ; $71FB  おお
    db $90                         ; $71FD  　(space)
    db $F6                         ; $71FE  «insert hero name»
    db $29                         ; $71FF  か
    db $8F                         ; $7200  。
    db $EF,$EE                     ; $7201  newline
    db $90,$90                     ; $7203  　　(indent)
    db $43,$36,$37,$28,$36,$33,$32,$8D,$25; $7205  まっておったそ゛い = まっておったぞい
    db $99                         ; $720E  ！
    db $FA                         ; $720F  wait-for-button
    db $F7                         ; $7210  clear page
    db $EF,$EE                     ; $7211  newline
    db $9F                         ; $7213  box tag
    db $96                         ; $7214  end name/box tag
    db $0C                         ; $7215  ctrl $0C
    db $62,$85,$67,$25,$2F,$8D,$4D,$26,$54; $7216  クラスいし゛ょうを = クラスいじょうを
    db $90                         ; $721F  　(space)
    db $26,$2C,$50,$2D,$38,$54     ; $7220  うけることを
    db $EF,$EE                     ; $7226  newline
    db $90,$90                     ; $7228  　　(indent)
    db $28,$26,$2E,$43,$29,$8D     ; $722A  おうさまか゛ = おうさまが
    db $90                         ; $7230  　(space)
    db $4A,$50,$2E,$51,$33,$32,$8D,$25; $7231  ゆるされたそ゛い = ゆるされたぞい
    db $99                         ; $7239  ！
    db $FA                         ; $723A  wait-for-button
    db $F7                         ; $723B  clear page
    db $EF,$EE                     ; $723C  newline
    db $9F                         ; $723E  box tag
    db $96                         ; $723F  end name/box tag
    db $6A,$58,$66,$8D,$82,$3D     ; $7240  タィシ゛ャの = タィジャの
    db $90                         ; $7246  　(space)
    db $33,$8D,$25,$3F,$4D,$26,$3A,$39,$50,$3A,$3E; $7247  た゛いひょうになるには = だいひょうになるには
    db $EF,$EE                     ; $7252  newline
    db $90,$90                     ; $7254  　　(indent)
    db $1C                         ; $7256  ctrl $1C
    db $62,$85,$67,$54             ; $7257  クラスを
    db $90                         ; $725B  　(space)
    db $29,$34,$3B,$2B,$3D,$2F,$8D,$49; $725C  かちぬくのし゛ゃ = かちぬくのじゃ
    db $99                         ; $7264  ！
    db $FA                         ; $7265  wait-for-button
    db $F7                         ; $7266  clear page
    db $EF,$EE                     ; $7267  newline
    db $9F                         ; $7269  box tag
    db $96                         ; $726A  end name/box tag
    db $1C                         ; $726B  ctrl $1C
    db $62,$85,$67,$54             ; $726C  クラスを
    db $90                         ; $7270  　(space)
    db $29,$34,$3B,$25,$33,$47,$3D,$33,$8D,$2C,$29,$8D; $7271  かちぬいたものた゛けか゛ = かちぬいたものだけが
    db $EF,$EE                     ; $727D  newline
    db $90,$90                     ; $727F  　　(indent)
    db $33,$25,$29,$25,$3A         ; $7281  たいかいに
    db $90                         ; $7286  　(space)
    db $2F,$4B,$35,$2F,$8D,$4D,$26,$37,$8D,$2A,$50; $7287  しゅつし゛ょうて゛きる = しゅつじょうできる
    db $99                         ; $7292  ！
    db $FA                         ; $7293  wait-for-button
    db $F7                         ; $7294  clear page
    db $EF,$EE                     ; $7295  newline
    db $9F                         ; $7297  box tag
    db $96                         ; $7298  end name/box tag
    db $25,$2A,$39,$4F             ; $7299  いきなり
    db $90                         ; $729D  　(space)
    db $1C                         ; $729E  ctrl $1C
    db $62,$85,$67,$54             ; $729F  クラスを
    db $90                         ; $72A3  　(space)
    db $26,$2C,$50,$3D,$47         ; $72A4  うけるのも
    db $EF,$EE                     ; $72A9  newline
    db $90,$90                     ; $72AB  　　(indent)
    db $4A,$50,$2E,$51,$37,$28,$50,$32,$8D; $72AD  ゆるされておるそ゛ = ゆるされておるぞ
    db $99                         ; $72B6  ！
    db $FA                         ; $72B7  wait-for-button
    db $F7                         ; $72B8  clear page
    db $EF,$EE                     ; $72B9  newline
    db $9F                         ; $72BB  box tag
    db $96                         ; $72BC  end name/box tag
    db $37,$8D,$3E                 ; $72BD  て゛は = では
    db $90                         ; $72C0  　(space)
    db $38,$8D,$3D,$62,$85,$67,$54 ; $72C1  と゛のクラスを = どのクラスを
    db $90                         ; $72C8  　(space)
    db $26,$2C,$50,$29,$3D         ; $72C9  うけるかの
    db $98                         ; $72CE  ？
    db $EF,$EE                     ; $72CF  newline
    db $F0                         ; $72D1  end of message


; --------------------------------------------------------------------------
; Message #157 ($72D2)
;   「ようやった！
;   [0C]クラスかちぬきじゃぞ！！
;   「よろこびとちえのへやを
;   おうさまが　あけてくれたぞい！
;   「より　つよい　まもののおる
;   たびのとびらが　まっとるぞ！
; --------------------------------------------------------------------------
Bank69_Msg157:                             ; $72D2  (file $1172D2)
    db $EA                         ; $72D2  ▶ new page
    db $9F                         ; $72D3  box tag
    db $96                         ; $72D4  end name/box tag
    db $4C,$26,$48,$36,$33         ; $72D5  ようやった
    db $99                         ; $72DA  ！
    db $EF,$EE                     ; $72DB  newline
    db $90,$90                     ; $72DD  　　(indent)
    db $0C                         ; $72DF  ctrl $0C
    db $62,$85,$67,$29,$34,$3B,$2A,$2F,$8D,$49,$32,$8D; $72E0  クラスかちぬきし゛ゃそ゛ = クラスかちぬきじゃぞ
    db $99                         ; $72EC  ！
    db $99                         ; $72ED  ！
    db $FA                         ; $72EE  wait-for-button
    db $F7                         ; $72EF  clear page
    db $EF,$EE                     ; $72F0  newline
    db $9F                         ; $72F2  box tag
    db $96                         ; $72F3  end name/box tag
    db $4C,$52,$2D,$3F,$8D,$38,$34,$27,$3D,$41,$48,$54; $72F4  よろこひ゛とちえのへやを = よろこびとちえのへやを
    db $EF,$EE                     ; $7300  newline
    db $90,$90                     ; $7302  　　(indent)
    db $28,$26,$2E,$43,$29,$8D     ; $7304  おうさまか゛ = おうさまが
    db $90                         ; $730A  　(space)
    db $24,$2C,$37,$2B,$51,$33,$32,$8D,$25; $730B  あけてくれたそ゛い = あけてくれたぞい
    db $99                         ; $7314  ！
    db $FA                         ; $7315  wait-for-button
    db $F7                         ; $7316  clear page
    db $EF,$EE                     ; $7317  newline
    db $9F                         ; $7319  box tag
    db $96                         ; $731A  end name/box tag
    db $4C,$4F                     ; $731B  より
    db $90                         ; $731D  　(space)
    db $35,$4C,$25                 ; $731E  つよい
    db $90                         ; $7321  　(space)
    db $43,$47,$3D,$3D,$28,$50     ; $7322  まもののおる
    db $EF,$EE                     ; $7328  newline
    db $90,$90                     ; $732A  　　(indent)
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$29,$8D; $732C  たひ゛のとひ゛らか゛ = たびのとびらが
    db $90                         ; $7336  　(space)
    db $43,$36,$38,$50,$32,$8D     ; $7337  まっとるそ゛ = まっとるぞ
    db $99                         ; $733D  ！
    db $F7                         ; $733E  clear page
    db $F0                         ; $733F  end of message


; --------------------------------------------------------------------------
; Message #158 ($7340)
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
Bank69_Msg158:                             ; $7340  (file $117340)
    db $EB                         ; $7340  ▶ new page
    db $9F                         ; $7341  box tag
    db $96                         ; $7342  end name/box tag
    db $2F,$24,$25,$3E             ; $7343  しあいは
    db $90                         ; $7347  　(space)
    db $35,$4C,$25,$2F,$8D,$4B,$55,$3A; $7348  つよいし゛ゅんに = つよいじゅんに
    db $EF,$EE                     ; $7350  newline
    db $90,$90                     ; $7352  　　(indent)
    db $1C                         ; $7354  ctrl $1C
    db $29,$4E                     ; $7355  から
    db $10                         ; $7357  ctrl $10
    db $62,$85,$67,$43,$37,$8D     ; $7358  クラスまて゛ = クラスまで
    db $90                         ; $735E  　(space)
    db $24,$4F,$43,$30             ; $735F  あります
    db $8F                         ; $7363  。
    db $FA                         ; $7364  wait-for-button
    db $F7                         ; $7365  clear page
    db $EF,$EE                     ; $7366  newline
    db $9F                         ; $7368  box tag
    db $96                         ; $7369  end name/box tag
    db $01                         ; $736A  ctrl $01
    db $35,$3D,$62,$85,$67,$3A,$35,$2A; $736B  つのクラスにつき
    db $90                         ; $7373  　(space)
    db $03                         ; $7374  ctrl $03
    db $3A,$55,$3D                 ; $7375  にんの
    db $EF,$EE                     ; $7378  newline
    db $90,$90                     ; $737A  　　(indent)
    db $7A,$67,$6A,$9C,$29,$8D     ; $737C  マスターか゛ = マスターが
    db $90                         ; $7382  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $7383  あいてて゛す = あいてです
    db $8F                         ; $7389  。
    db $FA                         ; $738A  wait-for-button
    db $F7                         ; $738B  clear page
    db $EF,$EE                     ; $738C  newline
    db $9F                         ; $738E  box tag
    db $96                         ; $738F  end name/box tag
    db $03                         ; $7390  ctrl $03
    db $3A,$55,$46,$3D             ; $7391  にんめの
    db $90                         ; $7395  　(space)
    db $7A,$67,$6A,$9C,$54,$33,$28,$31,$3E,$8D; $7396  マスターをたおせは゛ = マスターをたおせば
    db $EF,$EE                     ; $73A0  newline
    db $90,$90                     ; $73A2  　　(indent)
    db $24,$39,$33,$3D,$62,$85,$67,$29,$8D; $73A4  あなたのクラスか゛ = あなたのクラスが
    db $90                         ; $73AD  　(space)
    db $24,$29,$8D,$4F,$43,$30     ; $73AE  あか゛ります = あがります
    db $8F                         ; $73B4  。
    db $FA                         ; $73B5  wait-for-button
    db $F7                         ; $73B6  clear page
    db $EF,$EE                     ; $73B7  newline
    db $9F                         ; $73B9  box tag
    db $96                         ; $73BA  end name/box tag
    db $1C                         ; $73BB  ctrl $1C
    db $62,$85,$67,$54,$29,$34,$3B,$2C,$3E,$8D; $73BC  クラスをかちぬけは゛ = クラスをかちぬけば
    db $90                         ; $73C6  　(space)
    db $33,$25,$29,$25,$3A         ; $73C7  たいかいに
    db $EF,$EE                     ; $73CC  newline
    db $90,$90                     ; $73CE  　　(indent)
    db $37,$8D,$50,$2F,$29,$2B,$29,$8D; $73D0  て゛るしかくか゛ = でるしかくが
    db $90                         ; $73D8  　(space)
    db $27,$4E,$51,$43,$30,$4C     ; $73D9  えられますよ
    db $8F                         ; $73DF  。
    db $FA                         ; $73E0  wait-for-button
    db $F7                         ; $73E1  clear page
    db $EF,$EE                     ; $73E2  newline
    db $9F                         ; $73E4  box tag
    db $96                         ; $73E5  end name/box tag
    db $39,$28                     ; $73E6  なお
    db $90                         ; $73E8  　(space)
    db $2F,$24,$25,$37,$8D,$3E     ; $73E9  しあいて゛は = しあいでは
    db $90                         ; $73EF  　(space)
    db $43,$47,$3D,$3A             ; $73F0  まものに
    db $EF,$EE                     ; $73F4  newline
    db $90,$90                     ; $73F6  　　(indent)
    db $46,$25,$51,$25,$3E         ; $73F8  めいれいは
    db $90                         ; $73FD  　(space)
    db $33,$8D,$31,$43,$31,$55     ; $73FE  た゛せません = だせません
    db $8F                         ; $7404  。
    db $FA                         ; $7405  wait-for-button
    db $F7                         ; $7406  clear page
    db $EF,$EE                     ; $7407  newline
    db $9F                         ; $7409  box tag
    db $96                         ; $740A  end name/box tag
    db $43,$33                     ; $740B  また
    db $90                         ; $740D  　(space)
    db $38,$8D,$26,$2B,$8D,$54     ; $740E  と゛うく゛を = どうぐを
    db $90                         ; $7414  　(space)
    db $35,$29,$26,$2D,$38,$47     ; $7415  つかうことも
    db $EF,$EE                     ; $741B  newline
    db $90,$90                     ; $741D  　　(indent)
    db $4A,$50,$2E,$51,$43,$31,$55 ; $741F  ゆるされません
    db $8F                         ; $7426  。
    db $FA                         ; $7427  wait-for-button
    db $F7                         ; $7428  clear page
    db $EF,$EE                     ; $7429  newline
    db $9F                         ; $742B  box tag
    db $96                         ; $742C  end name/box tag
    db $3A,$2C,$8D,$50,$54         ; $742D  にけ゛るを = にげるを
    db $90                         ; $7432  　(space)
    db $27,$4E,$40,$8D,$38         ; $7433  えらふ゛と = えらぶと
    db $90                         ; $7438  　(space)
    db $2F,$24,$25,$54             ; $7439  しあいを
    db $EF,$EE                     ; $743D  newline
    db $90,$90                     ; $743F  　　(indent)
    db $42,$26,$2A,$2F,$33,$38     ; $7441  ほうきしたと
    db $90                         ; $7447  　(space)
    db $44,$39,$2E,$51,$43,$30     ; $7448  みなされます
    db $8F                         ; $744E  。
    db $FA                         ; $744F  wait-for-button
    db $F7                         ; $7450  clear page
    db $EF,$EE                     ; $7451  newline
    db $9F                         ; $7453  box tag
    db $96                         ; $7454  end name/box tag
    db $2E,$55,$29,$47,$26,$2F,$2D,$44,$3E; $7455  さんかもうしこみは
    db $90                         ; $745E  　(space)
    db $45,$29,$25,$3D             ; $745F  むかいの
    db $EF,$EE                     ; $7463  newline
    db $90,$90                     ; $7465  　　(indent)
    db $26,$2C,$35,$2C,$37,$8D     ; $7467  うけつけて゛ = うけつけで
    db $90                         ; $746D  　(space)
    db $28,$2D,$39,$36,$37,$2B,$33,$8D,$2E,$25; $746E  おこなってくた゛さい = おこなってください
    db $8F                         ; $7478  。
    db $F7                         ; $7479  clear page
    db $F0                         ; $747A  end of message


; --------------------------------------------------------------------------
; Message #159 ($747B)
;   「[0C]クラスの　さいしゅうせんは
;   となりの　ひかえしつの、
;   「テトくんが　あいてです。
; --------------------------------------------------------------------------
Bank69_Msg159:                             ; $747B  (file $11747B)
    db $EB                         ; $747B  ▶ new page
    db $9F                         ; $747C  box tag
    db $96                         ; $747D  end name/box tag
    db $0C                         ; $747E  ctrl $0C
    db $62,$85,$67,$3D             ; $747F  クラスの
    db $90                         ; $7483  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $7484  さいしゅうせんは
    db $EF,$EE                     ; $748C  newline
    db $90,$90                     ; $748E  　　(indent)
    db $38,$39,$4F,$3D             ; $7490  となりの
    db $90                         ; $7494  　(space)
    db $3F,$29,$27,$2F,$35,$3D     ; $7495  ひかえしつの
    db $A4                         ; $749B  、
    db $FA                         ; $749C  wait-for-button
    db $F7                         ; $749D  clear page
    db $EF,$EE                     ; $749E  newline
    db $9F                         ; $74A0  box tag
    db $96                         ; $74A1  end name/box tag
    db $6E,$6F,$2B,$55,$29,$8D     ; $74A2  テトくんか゛ = テトくんが
    db $90                         ; $74A8  　(space)
    db $24,$25,$37,$37,$8D,$30     ; $74A9  あいてて゛す = あいてです
    db $8F                         ; $74AF  。
    db $EF,$EE                     ; $74B0  newline
    db $F7                         ; $74B2  clear page
    db $F0                         ; $74B3  end of message


; --------------------------------------------------------------------------
; Message #160 ($74B4)
;   「あっ！　〈テリー〉くん！
;   きいてください！
;   「〈テリー〉くんが　いないうちに
;   [0C]クラスに　なったんですよ！
;   「[0C]クラスのさいしゅうせん
;   よろしくおねがいします！
; --------------------------------------------------------------------------
Bank69_Msg160:                             ; $74B4  (file $1174B4)
    db $EA                         ; $74B4  ▶ new page
    db $9F                         ; $74B5  box tag
    db $96                         ; $74B6  end name/box tag
    db $24,$36                     ; $74B7  あっ
    db $99                         ; $74B9  ！
    db $90                         ; $74BA  　(space)
    db $F6                         ; $74BB  «insert hero name»
    db $2B,$55                     ; $74BC  くん
    db $99                         ; $74BE  ！
    db $EF,$EE                     ; $74BF  newline
    db $90,$90                     ; $74C1  　　(indent)
    db $2A,$25,$37,$2B,$33,$8D,$2E,$25; $74C3  きいてくた゛さい = きいてください
    db $99                         ; $74CB  ！
    db $FA                         ; $74CC  wait-for-button
    db $F7                         ; $74CD  clear page
    db $EF,$EE                     ; $74CE  newline
    db $9F                         ; $74D0  box tag
    db $96                         ; $74D1  end name/box tag
    db $F6                         ; $74D2  «insert hero name»
    db $2B,$55,$29,$8D             ; $74D3  くんか゛ = くんが
    db $90                         ; $74D7  　(space)
    db $25,$39,$25,$26,$34,$3A     ; $74D8  いないうちに
    db $EF,$EE                     ; $74DE  newline
    db $90,$90                     ; $74E0  　　(indent)
    db $0C                         ; $74E2  ctrl $0C
    db $62,$85,$67,$3A             ; $74E3  クラスに
    db $90                         ; $74E7  　(space)
    db $39,$36,$33,$55,$37,$8D,$30,$4C; $74E8  なったんて゛すよ = なったんですよ
    db $99                         ; $74F0  ！
    db $FA                         ; $74F1  wait-for-button
    db $F7                         ; $74F2  clear page
    db $EF,$EE                     ; $74F3  newline
    db $9F                         ; $74F5  box tag
    db $96                         ; $74F6  end name/box tag
    db $0C                         ; $74F7  ctrl $0C
    db $62,$85,$67,$3D,$2E,$25,$2F,$4B,$26,$31,$55; $74F8  クラスのさいしゅうせん
    db $EF,$EE                     ; $7503  newline
    db $90,$90                     ; $7505  　　(indent)
    db $4C,$52,$2F,$2B,$28,$3C,$29,$8D,$25,$2F,$43,$30; $7507  よろしくおねか゛いします = よろしくおねがいします
    db $99                         ; $7513  ！
    db $F7                         ; $7514  clear page
    db $F0                         ; $7515  end of message


; --------------------------------------------------------------------------
; Message #161 ($7516)
;   「[0C]クラスのさいしゅうせん
;   よろしくおねがいします！
; --------------------------------------------------------------------------
Bank69_Msg161:                             ; $7516  (file $117516)
    db $EA                         ; $7516  ▶ new page
    db $9F                         ; $7517  box tag
    db $96                         ; $7518  end name/box tag
    db $0C                         ; $7519  ctrl $0C
    db $62,$85,$67,$3D,$2E,$25,$2F,$4B,$26,$31,$55; $751A  クラスのさいしゅうせん
    db $EF,$EE                     ; $7525  newline
    db $90,$90                     ; $7527  　　(indent)
    db $4C,$52,$2F,$2B,$28,$3C,$29,$8D,$25,$2F,$43,$30; $7529  よろしくおねか゛いします = よろしくおねがいします
    db $99                         ; $7535  ！
    db $F7                         ; $7536  clear page
    db $F0                         ; $7537  end of message


; --------------------------------------------------------------------------
; Message #162 ($7538)
;   「〈テリー〉くん！
;   また　たたかってくださいね！
; --------------------------------------------------------------------------
Bank69_Msg162:                             ; $7538  (file $117538)
    db $EA                         ; $7538  ▶ new page
    db $9F                         ; $7539  box tag
    db $96                         ; $753A  end name/box tag
    db $F6                         ; $753B  «insert hero name»
    db $2B,$55                     ; $753C  くん
    db $99                         ; $753E  ！
    db $EF,$EE                     ; $753F  newline
    db $90,$90                     ; $7541  　　(indent)
    db $43,$33                     ; $7543  また
    db $90                         ; $7545  　(space)
    db $33,$33,$29,$36,$37,$2B,$33,$8D,$2E,$25,$3C; $7546  たたかってくた゛さいね = たたかってくださいね
    db $99                         ; $7551  ！
    db $F7                         ; $7552  clear page
    db $F0                         ; $7553  end of message


; --------------------------------------------------------------------------
; Message #163 ($7554)
;   「ォレのきょうだいは　げんきかな？
;   まちの　したのほうにいるんだぜ。
; --------------------------------------------------------------------------
Bank69_Msg163:                             ; $7554  (file $117554)
    db $EA                         ; $7554  ▶ new page
    db $9F                         ; $7555  box tag
    db $96                         ; $7556  end name/box tag
    db $5E,$88,$3D,$2A,$4D,$26,$33,$8D,$25,$3E; $7557  ォレのきょうた゛いは = ォレのきょうだいは
    db $90                         ; $7561  　(space)
    db $2C,$8D,$55,$2A,$29,$39     ; $7562  け゛んきかな = げんきかな
    db $98                         ; $7568  ？
    db $EF,$EE                     ; $7569  newline
    db $90,$90                     ; $756B  　　(indent)
    db $43,$34,$3D                 ; $756D  まちの
    db $90                         ; $7570  　(space)
    db $2F,$33,$3D,$42,$26,$3A,$25,$50,$55,$33,$8D,$31,$8D; $7571  したのほうにいるんた゛せ゛ = したのほうにいるんだぜ
    db $8F                         ; $757E  。
    db $F7                         ; $757F  clear page
    db $F0                         ; $7580  end of message


; --------------------------------------------------------------------------
; Message #164 ($7581)
;   「おぬし　しっておるかっ！？
;   「ももんじゃのしっぽは
;   せんとうちゅう　つかっても、
;   「とくべつな　こうかが
;   あるそうじゃぞ！
; --------------------------------------------------------------------------
Bank69_Msg164:                             ; $7581  (file $117581)
    db $EA                         ; $7581  ▶ new page
    db $9F                         ; $7582  box tag
    db $96                         ; $7583  end name/box tag
    db $28,$3B,$2F                 ; $7584  おぬし
    db $90                         ; $7587  　(space)
    db $2F,$36,$37,$28,$50,$29,$36 ; $7588  しっておるかっ
    db $99                         ; $758F  ！
    db $98                         ; $7590  ？
    db $EF,$EE                     ; $7591  newline
    db $FA                         ; $7593  wait-for-button
    db $F7                         ; $7594  clear page
    db $EF,$EE                     ; $7595  newline
    db $F3                         ; $7597  open text box
    db $9F                         ; $7598  box tag
    db $96                         ; $7599  end name/box tag
    db $47,$47,$55,$2F,$8D,$49,$3D,$2F,$36,$42,$8E,$3E; $759A  ももんし゛ゃのしっほ゜は = ももんじゃのしっぽは
    db $EF,$EE                     ; $75A6  newline
    db $90,$90                     ; $75A8  　　(indent)
    db $31,$55,$38,$26,$34,$4B,$26 ; $75AA  せんとうちゅう
    db $90                         ; $75B1  　(space)
    db $35,$29,$36,$37,$47         ; $75B2  つかっても
    db $A4                         ; $75B7  、
    db $FA                         ; $75B8  wait-for-button
    db $F7                         ; $75B9  clear page
    db $EF,$EE                     ; $75BA  newline
    db $9F                         ; $75BC  box tag
    db $96                         ; $75BD  end name/box tag
    db $38,$2B,$41,$8D,$35,$39     ; $75BE  とくへ゛つな = とくべつな
    db $90                         ; $75C4  　(space)
    db $2D,$26,$29,$29,$8D         ; $75C5  こうかか゛ = こうかが
    db $EF,$EE                     ; $75CA  newline
    db $90,$90                     ; $75CC  　　(indent)
    db $24,$50,$32,$26,$2F,$8D,$49,$32,$8D; $75CE  あるそうし゛ゃそ゛ = あるそうじゃぞ
    db $99                         ; $75D7  ！
    db $F7                         ; $75D8  clear page
    db $F0                         ; $75D9  end of message


; --------------------------------------------------------------------------
; Message #165 ($75DA)
;   「わしゃ　おかしなゆめをみたぞい。
;   このぞうが　うごきだすんじゃよ！
;   「いくら　わたぼうさまでも
;   ぞうが　うごくわけがないのう！
; --------------------------------------------------------------------------
Bank69_Msg165:                             ; $75DA  (file $1175DA)
    db $EA                         ; $75DA  ▶ new page
    db $9F                         ; $75DB  box tag
    db $96                         ; $75DC  end name/box tag
    db $53,$2F,$49                 ; $75DD  わしゃ
    db $90                         ; $75E0  　(space)
    db $28,$29,$2F,$39,$4A,$46,$54,$44,$33,$32,$8D,$25; $75E1  おかしなゆめをみたそ゛い = おかしなゆめをみたぞい
    db $8F                         ; $75ED  。
    db $EF,$EE                     ; $75EE  newline
    db $90,$90                     ; $75F0  　　(indent)
    db $2D,$3D,$32,$8D,$26,$29,$8D ; $75F2  このそ゛うか゛ = このぞうが
    db $90                         ; $75F9  　(space)
    db $26,$2D,$8D,$2A,$33,$8D,$30,$55,$2F,$8D,$49,$4C; $75FA  うこ゛きた゛すんし゛ゃよ = うごきだすんじゃよ
    db $99                         ; $7606  ！
    db $FA                         ; $7607  wait-for-button
    db $F7                         ; $7608  clear page
    db $EF,$EE                     ; $7609  newline
    db $9F                         ; $760B  box tag
    db $96                         ; $760C  end name/box tag
    db $25,$2B,$4E                 ; $760D  いくら
    db $90                         ; $7610  　(space)
    db $53,$33,$42,$8D,$26,$2E,$43,$37,$8D,$47; $7611  わたほ゛うさまて゛も = わたぼうさまでも
    db $EF,$EE                     ; $761B  newline
    db $90,$90                     ; $761D  　　(indent)
    db $32,$8D,$26,$29,$8D         ; $761F  そ゛うか゛ = ぞうが
    db $90                         ; $7624  　(space)
    db $26,$2D,$8D,$2B,$53,$2C,$29,$8D,$39,$25,$3D,$26; $7625  うこ゛くわけか゛ないのう = うごくわけがないのう
    db $99                         ; $7631  ！
    db $F7                         ; $7632  clear page
    db $F0                         ; $7633  end of message


; --------------------------------------------------------------------------
; Message #166 ($7634)
;   「おお！　きせきじゃ！！
;   ぞうが　うごいたぞう！！
; --------------------------------------------------------------------------
Bank69_Msg166:                             ; $7634  (file $117634)
    db $EA                         ; $7634  ▶ new page
    db $9F                         ; $7635  box tag
    db $96                         ; $7636  end name/box tag
    db $28,$28                     ; $7637  おお
    db $99                         ; $7639  ！
    db $90                         ; $763A  　(space)
    db $2A,$31,$2A,$2F,$8D,$49     ; $763B  きせきし゛ゃ = きせきじゃ
    db $99                         ; $7641  ！
    db $99                         ; $7642  ！
    db $EF,$EE                     ; $7643  newline
    db $90,$90                     ; $7645  　　(indent)
    db $32,$8D,$26,$29,$8D         ; $7647  そ゛うか゛ = ぞうが
    db $90                         ; $764C  　(space)
    db $26,$2D,$8D,$25,$33,$32,$8D,$26; $764D  うこ゛いたそ゛う = うごいたぞう
    db $99                         ; $7655  ！
    db $99                         ; $7656  ！
    db $F7                         ; $7657  clear page
    db $F0                         ; $7658  end of message


; --------------------------------------------------------------------------
; Message #167 ($7659)
;   「たびのとびらの　むこうでは
;   おみせも　あったでごんす。
;   「たしか　あの　なかでは
;   きろくも　できたような、、。
;   「よそみしておると　ばくだんいわが
;   さぼると　いかんので　これで。
; --------------------------------------------------------------------------
Bank69_Msg167:                             ; $7659  (file $117659)
    db $EA                         ; $7659  ▶ new page
    db $9F                         ; $765A  box tag
    db $96                         ; $765B  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3D; $765C  たひ゛のとひ゛らの = たびのとびらの
    db $90                         ; $7665  　(space)
    db $45,$2D,$26,$37,$8D,$3E     ; $7666  むこうて゛は = むこうでは
    db $EF,$EE                     ; $766C  newline
    db $90,$90                     ; $766E  　　(indent)
    db $28,$44,$31,$47             ; $7670  おみせも
    db $90                         ; $7674  　(space)
    db $24,$36,$33,$37,$8D,$2D,$8D,$55,$30; $7675  あったて゛こ゛んす = あったでごんす
    db $8F                         ; $767E  。
    db $FA                         ; $767F  wait-for-button
    db $F7                         ; $7680  clear page
    db $EF,$EE                     ; $7681  newline
    db $9F                         ; $7683  box tag
    db $96                         ; $7684  end name/box tag
    db $33,$2F,$29                 ; $7685  たしか
    db $90                         ; $7688  　(space)
    db $24,$3D                     ; $7689  あの
    db $90                         ; $768B  　(space)
    db $39,$29,$37,$8D,$3E         ; $768C  なかて゛は = なかでは
    db $EF,$EE                     ; $7691  newline
    db $90,$90                     ; $7693  　　(indent)
    db $2A,$52,$2B,$47             ; $7695  きろくも
    db $90                         ; $7699  　(space)
    db $37,$8D,$2A,$33,$4C,$26,$39 ; $769A  て゛きたような = できたような
    db $A4                         ; $76A1  、
    db $A4                         ; $76A2  、
    db $8F                         ; $76A3  。
    db $FA                         ; $76A4  wait-for-button
    db $F7                         ; $76A5  clear page
    db $EF,$EE                     ; $76A6  newline
    db $9F                         ; $76A8  box tag
    db $96                         ; $76A9  end name/box tag
    db $4C,$32,$44,$2F,$37,$28,$50,$38; $76AA  よそみしておると
    db $90                         ; $76B2  　(space)
    db $3E,$8D,$2B,$33,$8D,$55,$25,$53,$29,$8D; $76B3  は゛くた゛んいわか゛ = ばくだんいわが
    db $EF,$EE                     ; $76BD  newline
    db $90,$90                     ; $76BF  　　(indent)
    db $2E,$42,$8D,$50,$38         ; $76C1  さほ゛ると = さぼると
    db $90                         ; $76C6  　(space)
    db $25,$29,$55,$3D,$37,$8D     ; $76C7  いかんのて゛ = いかんので
    db $90                         ; $76CD  　(space)
    db $2D,$51,$37,$8D             ; $76CE  これて゛ = これで
    db $8F                         ; $76D2  。
    db $F7                         ; $76D3  clear page
    db $F0                         ; $76D4  end of message


; --------------------------------------------------------------------------
; Message #168 ($76D5)
;   「えいほ！　えいほ！
; --------------------------------------------------------------------------
Bank69_Msg168:                             ; $76D5  (file $1176D5)
    db $EA                         ; $76D5  ▶ new page
    db $9F                         ; $76D6  box tag
    db $96                         ; $76D7  end name/box tag
    db $27,$25,$42                 ; $76D8  えいほ
    db $99                         ; $76DB  ！
    db $90                         ; $76DC  　(space)
    db $27,$25,$42                 ; $76DD  えいほ
    db $99                         ; $76E0  ！
    db $EF,$EE                     ; $76E1  newline
    db $F7                         ; $76E3  clear page
    db $F0                         ; $76E4  end of message


; --------------------------------------------------------------------------
; Message #169 ($76E5)
;   「へへっ！　にいちゃんよ[95]。
;   [0C]クラスのあいてを　しりたいか？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg169:                             ; $76E5  (file $1176E5)
    db $EA                         ; $76E5  ▶ new page
    db $9F                         ; $76E6  box tag
    db $96                         ; $76E7  end name/box tag
    db $41,$41,$36                 ; $76E8  へへっ
    db $99                         ; $76EB  ！
    db $90                         ; $76EC  　(space)
    db $3A,$25,$34,$49,$55,$4C     ; $76ED  にいちゃんよ
    db $95                         ; $76F3  ctrl $95
    db $8F                         ; $76F4  。
    db $EF,$EE                     ; $76F5  newline
    db $90,$90                     ; $76F7  　　(indent)
    db $0C                         ; $76F9  ctrl $0C
    db $62,$85,$67,$3D,$24,$25,$37,$54; $76FA  クラスのあいてを
    db $90                         ; $7702  　(space)
    db $2F,$4F,$33,$25,$29         ; $7703  しりたいか
    db $98                         ; $7708  ？
    db $FF                         ; $7709  はい/いいえ
    db $F0                         ; $770A  end of message


; --------------------------------------------------------------------------
; Message #170 ($770B)
;   「[0C]クラスの　さいしゅうせんは
;   テトが　あいてだぞ。
;   「まものは　ストーンスラィムと
;   ボックススラィムが　[02]たいだ。
;   「やつらはもともと　しゅびりょくが
;   たかいうえ　スカラをとなえる。
;   「しゅびを　かためだすまえに
;   しとめないと　やばいぞ！
; --------------------------------------------------------------------------
Bank69_Msg170:                             ; $770B  (file $11770B)
    db $EA                         ; $770B  ▶ new page
    db $9F                         ; $770C  box tag
    db $96                         ; $770D  end name/box tag
    db $0C                         ; $770E  ctrl $0C
    db $62,$85,$67,$3D             ; $770F  クラスの
    db $90                         ; $7713  　(space)
    db $2E,$25,$2F,$4B,$26,$31,$55,$3E; $7714  さいしゅうせんは
    db $EF,$EE                     ; $771C  newline
    db $90,$90                     ; $771E  　　(indent)
    db $6E,$6F,$29,$8D             ; $7720  テトか゛ = テトが
    db $90                         ; $7724  　(space)
    db $24,$25,$37,$33,$8D,$32,$8D ; $7725  あいてた゛そ゛ = あいてだぞ
    db $8F                         ; $772C  。
    db $FA                         ; $772D  wait-for-button
    db $F7                         ; $772E  clear page
    db $EF,$EE                     ; $772F  newline
    db $9F                         ; $7731  box tag
    db $96                         ; $7732  end name/box tag
    db $43,$47,$3D,$3E             ; $7733  まものは
    db $90                         ; $7737  　(space)
    db $67,$6F,$9C,$8C,$67,$85,$58,$7C,$38; $7738  ストーンスラィムと
    db $EF,$EE                     ; $7741  newline
    db $90,$90                     ; $7743  　　(indent)
    db $79,$8D,$6D,$62,$67,$67,$85,$58,$7C,$29,$8D; $7745  ホ゛ックススラィムか゛ = ボックススラィムが
    db $90                         ; $7750  　(space)
    db $02                         ; $7751  ctrl $02
    db $33,$25,$33,$8D             ; $7752  たいた゛ = たいだ
    db $8F                         ; $7756  。
    db $FA                         ; $7757  wait-for-button
    db $F7                         ; $7758  clear page
    db $EF,$EE                     ; $7759  newline
    db $9F                         ; $775B  box tag
    db $96                         ; $775C  end name/box tag
    db $48,$35,$4E,$3E,$47,$38,$47,$38; $775D  やつらはもともと
    db $90                         ; $7765  　(space)
    db $2F,$4B,$3F,$8D,$4F,$4D,$2B,$29,$8D; $7766  しゅひ゛りょくか゛ = しゅびりょくが
    db $EF,$EE                     ; $776F  newline
    db $90,$90                     ; $7771  　　(indent)
    db $33,$29,$25,$26,$27         ; $7773  たかいうえ
    db $90                         ; $7778  　(space)
    db $67,$60,$85,$54,$38,$39,$27,$50; $7779  スカラをとなえる
    db $8F                         ; $7781  。
    db $FA                         ; $7782  wait-for-button
    db $F7                         ; $7783  clear page
    db $EF,$EE                     ; $7784  newline
    db $9F                         ; $7786  box tag
    db $96                         ; $7787  end name/box tag
    db $2F,$4B,$3F,$8D,$54         ; $7788  しゅひ゛を = しゅびを
    db $90                         ; $778D  　(space)
    db $29,$33,$46,$33,$8D,$30,$43,$27,$3A; $778E  かためた゛すまえに = かためだすまえに
    db $EF,$EE                     ; $7797  newline
    db $90,$90                     ; $7799  　　(indent)
    db $2F,$38,$46,$39,$25,$38     ; $779B  しとめないと
    db $90                         ; $77A1  　(space)
    db $48,$3E,$8D,$25,$32,$8D     ; $77A2  やは゛いそ゛ = やばいぞ
    db $99                         ; $77A8  ！
    db $F7                         ; $77A9  clear page
    db $F0                         ; $77AA  end of message


; --------------------------------------------------------------------------
; Message #171 ($77AB)
;   〈テリー〉は　ノートを　ひらいた。
;   「まものは　りょうしんの　もっている
;   とくぎなら　ぜんぶ　うけつぎます。
;   「そして　おじいさんと　おばあさんが
;   もっていた　とくぎも　おぼえます。
;   「でも　おじいさんたちの　とくぎは
;   ぜんぶ　おぼえるわけではないです。
;   「おじいさんたちの　とくぎのうち
;   りょうしんが　おぼえたとくぎしか、
;   「こどもは　うけつぐことが
;   できないのです。
; --------------------------------------------------------------------------
Bank69_Msg171:                             ; $77AB  (file $1177AB)
    db $F6                         ; $77AB  «insert hero name»
    db $3E                         ; $77AC  は
    db $90                         ; $77AD  　(space)
    db $74,$9C,$6F,$54             ; $77AE  ノートを
    db $90                         ; $77B2  　(space)
    db $3F,$4E,$25,$33             ; $77B3  ひらいた
    db $8F                         ; $77B7  。
    db $EF,$EE                     ; $77B8  newline
    db $FA                         ; $77BA  wait-for-button
    db $F7                         ; $77BB  clear page
    db $EF,$EE                     ; $77BC  newline
    db $F3                         ; $77BE  open text box
    db $96                         ; $77BF  end name/box tag
    db $43,$47,$3D,$3E             ; $77C0  まものは
    db $90                         ; $77C4  　(space)
    db $4F,$4D,$26,$2F,$55,$3D     ; $77C5  りょうしんの
    db $90                         ; $77CB  　(space)
    db $47,$36,$37,$25,$50         ; $77CC  もっている
    db $EF,$EE                     ; $77D1  newline
    db $90                         ; $77D3  　(space)
    db $38,$2B,$2A,$8D,$39,$4E     ; $77D4  とくき゛なら = とくぎなら
    db $90                         ; $77DA  　(space)
    db $31,$8D,$55,$40,$8D         ; $77DB  せ゛んふ゛ = ぜんぶ
    db $90                         ; $77E0  　(space)
    db $26,$2C,$35,$2A,$8D,$43,$30 ; $77E1  うけつき゛ます = うけつぎます
    db $8F                         ; $77E8  。
    db $FA                         ; $77E9  wait-for-button
    db $F7                         ; $77EA  clear page
    db $EF,$EE                     ; $77EB  newline
    db $96                         ; $77ED  end name/box tag
    db $32,$2F,$37                 ; $77EE  そして
    db $90                         ; $77F1  　(space)
    db $28,$2F,$8D,$25,$2E,$55,$38 ; $77F2  おし゛いさんと = おじいさんと
    db $90                         ; $77F9  　(space)
    db $28,$3E,$8D,$24,$2E,$55,$29,$8D; $77FA  おは゛あさんか゛ = おばあさんが
    db $EF,$EE                     ; $7802  newline
    db $90                         ; $7804  　(space)
    db $47,$36,$37,$25,$33         ; $7805  もっていた
    db $90                         ; $780A  　(space)
    db $38,$2B,$2A,$8D,$47         ; $780B  とくき゛も = とくぎも
    db $90                         ; $7810  　(space)
    db $28,$42,$8D,$27,$43,$30     ; $7811  おほ゛えます = おぼえます
    db $8F                         ; $7817  。
    db $FA                         ; $7818  wait-for-button
    db $F7                         ; $7819  clear page
    db $EF,$EE                     ; $781A  newline
    db $96                         ; $781C  end name/box tag
    db $37,$8D,$47                 ; $781D  て゛も = でも
    db $90                         ; $7820  　(space)
    db $28,$2F,$8D,$25,$2E,$55,$33,$34,$3D; $7821  おし゛いさんたちの = おじいさんたちの
    db $90                         ; $782A  　(space)
    db $38,$2B,$2A,$8D,$3E         ; $782B  とくき゛は = とくぎは
    db $EF,$EE                     ; $7830  newline
    db $90                         ; $7832  　(space)
    db $31,$8D,$55,$40,$8D         ; $7833  せ゛んふ゛ = ぜんぶ
    db $90                         ; $7838  　(space)
    db $28,$42,$8D,$27,$50,$53,$2C,$37,$8D,$3E,$39,$25,$37,$8D,$30; $7839  おほ゛えるわけて゛はないて゛す = おぼえるわけではないです
    db $8F                         ; $7848  。
    db $FA                         ; $7849  wait-for-button
    db $F7                         ; $784A  clear page
    db $EF,$EE                     ; $784B  newline
    db $96                         ; $784D  end name/box tag
    db $28,$2F,$8D,$25,$2E,$55,$33,$34,$3D; $784E  おし゛いさんたちの = おじいさんたちの
    db $90                         ; $7857  　(space)
    db $38,$2B,$2A,$8D,$3D,$26,$34 ; $7858  とくき゛のうち = とくぎのうち
    db $EF,$EE                     ; $785F  newline
    db $90                         ; $7861  　(space)
    db $4F,$4D,$26,$2F,$55,$29,$8D ; $7862  りょうしんか゛ = りょうしんが
    db $90                         ; $7869  　(space)
    db $28,$42,$8D,$27,$33,$38,$2B,$2A,$8D,$2F,$29; $786A  おほ゛えたとくき゛しか = おぼえたとくぎしか
    db $A4                         ; $7875  、
    db $FA                         ; $7876  wait-for-button
    db $F7                         ; $7877  clear page
    db $EF,$EE                     ; $7878  newline
    db $96                         ; $787A  end name/box tag
    db $2D,$38,$8D,$47,$3E         ; $787B  こと゛もは = こどもは
    db $90                         ; $7880  　(space)
    db $26,$2C,$35,$2B,$8D,$2D,$38,$29,$8D; $7881  うけつく゛ことか゛ = うけつぐことが
    db $EF,$EE                     ; $788A  newline
    db $90                         ; $788C  　(space)
    db $37,$8D,$2A,$39,$25,$3D,$37,$8D,$30; $788D  て゛きないのて゛す = できないのです
    db $8F                         ; $7896  。
    db $F7                         ; $7897  clear page
    db $F0                         ; $7898  end of message


; --------------------------------------------------------------------------
; Message #172 ($7899)
;   「まものの　せいべつの
;   かえかたも　ノートにうつしたよ。
;   「みたい？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg172:                             ; $7899  (file $117899)
    db $EB                         ; $7899  ▶ new page
    db $9F                         ; $789A  box tag
    db $96                         ; $789B  end name/box tag
    db $43,$47,$3D,$3D             ; $789C  まものの
    db $90                         ; $78A0  　(space)
    db $31,$25,$41,$8D,$35,$3D     ; $78A1  せいへ゛つの = せいべつの
    db $EF,$EE                     ; $78A7  newline
    db $90,$90                     ; $78A9  　　(indent)
    db $29,$27,$29,$33,$47         ; $78AB  かえかたも
    db $90                         ; $78B0  　(space)
    db $74,$9C,$6F,$3A,$26,$35,$2F,$33,$4C; $78B1  ノートにうつしたよ
    db $8F                         ; $78BA  。
    db $FA                         ; $78BB  wait-for-button
    db $F7                         ; $78BC  clear page
    db $EF,$EE                     ; $78BD  newline
    db $9F                         ; $78BF  box tag
    db $96                         ; $78C0  end name/box tag
    db $44,$33,$25                 ; $78C1  みたい
    db $98                         ; $78C4  ？
    db $EF,$EE                     ; $78C5  newline
    db $FF                         ; $78C7  はい/いいえ
    db $F0                         ; $78C8  end of message


; --------------------------------------------------------------------------
; Message #173 ($78C9)
;   「これはミソスープ。　ベベ！
;   いってごらんなさい！　せーの！
; --------------------------------------------------------------------------
Bank69_Msg173:                             ; $78C9  (file $1178C9)
    db $EA                         ; $78C9  ▶ new page
    db $9F                         ; $78CA  box tag
    db $96                         ; $78CB  end name/box tag
    db $2D,$51,$3E,$7B,$69,$67,$9C,$77,$8E; $78CC  これはミソスーフ゜ = これはミソスープ
    db $8F                         ; $78D5  。
    db $90                         ; $78D6  　(space)
    db $78,$8D,$78,$8D             ; $78D7  ヘ゛ヘ゛ = ベベ
    db $99                         ; $78DB  ！
    db $EF,$EE                     ; $78DC  newline
    db $90,$90                     ; $78DE  　　(indent)
    db $25,$36,$37,$2D,$8D,$4E,$55,$39,$2E,$25; $78E0  いってこ゛らんなさい = いってごらんなさい
    db $99                         ; $78EA  ！
    db $90                         ; $78EB  　(space)
    db $31,$9C,$3D                 ; $78EC  せーの
    db $99                         ; $78EF  ！
    db $F7                         ; $78F0  clear page
    db $F0                         ; $78F1  end of message


; --------------------------------------------------------------------------
; Message #174 ($78F2)
;   「ミソスープって　なんじゃい！
;   みそしるって　いわんか！！
; --------------------------------------------------------------------------
Bank69_Msg174:                             ; $78F2  (file $1178F2)
    db $EA                         ; $78F2  ▶ new page
    db $9F                         ; $78F3  box tag
    db $96                         ; $78F4  end name/box tag
    db $7B,$69,$67,$9C,$77,$8E,$36,$37; $78F5  ミソスーフ゜って = ミソスープって
    db $90                         ; $78FD  　(space)
    db $39,$55,$2F,$8D,$49,$25     ; $78FE  なんし゛ゃい = なんじゃい
    db $99                         ; $7904  ！
    db $EF,$EE                     ; $7905  newline
    db $90,$90                     ; $7907  　　(indent)
    db $44,$32,$2F,$50,$36,$37     ; $7909  みそしるって
    db $90                         ; $790F  　(space)
    db $25,$53,$55,$29             ; $7910  いわんか
    db $99                         ; $7914  ！
    db $99                         ; $7915  ！
    db $F7                         ; $7916  clear page
    db $F0                         ; $7917  end of message


; --------------------------------------------------------------------------
; Message #175 ($7918)
;   「みんな　ゆうしょうを　めざして
;   ここ　かくとうじょうに　つどう。
;   「かいふくけいの　まものなら
;   ヨニコーンが　いちばんだ。
;   「たびのとびらには　すんでいないが
;   たこくのマスターが　もっている。
;   「はいごうで　つくるには　スラィム
;   ファングが　ひつようだろう、。
; --------------------------------------------------------------------------
Bank69_Msg175:                             ; $7918  (file $117918)
    db $EA                         ; $7918  ▶ new page
    db $9F                         ; $7919  box tag
    db $96                         ; $791A  end name/box tag
    db $44,$55,$39                 ; $791B  みんな
    db $90                         ; $791E  　(space)
    db $4A,$26,$2F,$4D,$26,$54     ; $791F  ゆうしょうを
    db $90                         ; $7925  　(space)
    db $46,$2E,$8D,$2F,$37         ; $7926  めさ゛して = めざして
    db $EF,$EE                     ; $792B  newline
    db $90,$90                     ; $792D  　　(indent)
    db $2D,$2D                     ; $792F  ここ
    db $90                         ; $7931  　(space)
    db $29,$2B,$38,$26,$2F,$8D,$4D,$26,$3A; $7932  かくとうし゛ょうに = かくとうじょうに
    db $90                         ; $793B  　(space)
    db $35,$38,$8D,$26             ; $793C  つと゛う = つどう
    db $8F                         ; $7940  。
    db $FA                         ; $7941  wait-for-button
    db $F7                         ; $7942  clear page
    db $EF,$EE                     ; $7943  newline
    db $9F                         ; $7945  box tag
    db $96                         ; $7946  end name/box tag
    db $29,$25,$40,$2B,$2C,$25,$3D ; $7947  かいふくけいの
    db $90                         ; $794E  　(space)
    db $43,$47,$3D,$39,$4E         ; $794F  まものなら
    db $EF,$EE                     ; $7954  newline
    db $90,$90                     ; $7956  　　(indent)
    db $81,$71,$64,$9C,$8C,$29,$8D ; $7958  ヨニコーンか゛ = ヨニコーンが
    db $90                         ; $795F  　(space)
    db $25,$34,$3E,$8D,$55,$33,$8D ; $7960  いちは゛んた゛ = いちばんだ
    db $8F                         ; $7967  。
    db $FA                         ; $7968  wait-for-button
    db $F7                         ; $7969  clear page
    db $EF,$EE                     ; $796A  newline
    db $9F                         ; $796C  box tag
    db $96                         ; $796D  end name/box tag
    db $33,$3F,$8D,$3D,$38,$3F,$8D,$4E,$3A,$3E; $796E  たひ゛のとひ゛らには = たびのとびらには
    db $90                         ; $7978  　(space)
    db $30,$55,$37,$8D,$25,$39,$25,$29,$8D; $7979  すんて゛いないか゛ = すんでいないが
    db $EF,$EE                     ; $7982  newline
    db $90,$90                     ; $7984  　　(indent)
    db $33,$2D,$2B,$3D,$7A,$67,$6A,$9C,$29,$8D; $7986  たこくのマスターか゛ = たこくのマスターが
    db $90                         ; $7990  　(space)
    db $47,$36,$37,$25,$50         ; $7991  もっている
    db $8F                         ; $7996  。
    db $FA                         ; $7997  wait-for-button
    db $F7                         ; $7998  clear page
    db $EF,$EE                     ; $7999  newline
    db $9F                         ; $799B  box tag
    db $96                         ; $799C  end name/box tag
    db $3E,$25,$2D,$8D,$26,$37,$8D ; $799D  はいこ゛うて゛ = はいごうで
    db $90                         ; $79A4  　(space)
    db $35,$2B,$50,$3A,$3E         ; $79A5  つくるには
    db $90                         ; $79AA  　(space)
    db $67,$85,$58,$7C             ; $79AB  スラィム
    db $EF,$EE                     ; $79AF  newline
    db $90,$90                     ; $79B1  　　(indent)
    db $77,$57,$8C,$62,$8D,$29,$8D ; $79B3  ファンク゛か゛ = ファングが
    db $90                         ; $79BA  　(space)
    db $3F,$35,$4C,$26,$33,$8D,$52,$26; $79BB  ひつようた゛ろう = ひつようだろう
    db $A4                         ; $79C3  、
    db $8F                         ; $79C4  。
    db $F7                         ; $79C5  clear page
    db $F0                         ; $79C6  end of message


; --------------------------------------------------------------------------
; Message #176 ($79C7)
;   〈テリー〉は　ほんだなを　しらべた。
;   「きょうの　ひとこと、
;   「タマゴのあいだなら　せいべつは
;   かえられるのじゃ[91]！！
;   つづきを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg176:                             ; $79C7  (file $1179C7)
    db $F6                         ; $79C7  «insert hero name»
    db $3E                         ; $79C8  は
    db $90                         ; $79C9  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $79CA  ほんた゛なを = ほんだなを
    db $90                         ; $79D0  　(space)
    db $2F,$4E,$41,$8D,$33         ; $79D1  しらへ゛た = しらべた
    db $8F                         ; $79D6  。
    db $EF,$EE                     ; $79D7  newline
    db $FA                         ; $79D9  wait-for-button
    db $F7                         ; $79DA  clear page
    db $EF,$EE                     ; $79DB  newline
    db $F3                         ; $79DD  open text box
    db $96                         ; $79DE  end name/box tag
    db $2A,$4D,$26,$3D             ; $79DF  きょうの
    db $90                         ; $79E3  　(space)
    db $3F,$38,$2D,$38             ; $79E4  ひとこと
    db $A4                         ; $79E8  、
    db $EF,$EE                     ; $79E9  newline
    db $FA                         ; $79EB  wait-for-button
    db $F7                         ; $79EC  clear page
    db $EF,$EE                     ; $79ED  newline
    db $F3                         ; $79EF  open text box
    db $96                         ; $79F0  end name/box tag
    db $6A,$7A,$64,$8D,$3D,$24,$25,$33,$8D,$39,$4E; $79F1  タマコ゛のあいた゛なら = タマゴのあいだなら
    db $90                         ; $79FC  　(space)
    db $31,$25,$41,$8D,$35,$3E     ; $79FD  せいへ゛つは = せいべつは
    db $EF,$EE                     ; $7A03  newline
    db $90                         ; $7A05  　(space)
    db $29,$27,$4E,$51,$50,$3D,$2F,$8D,$49; $7A06  かえられるのし゛ゃ = かえられるのじゃ
    db $91                         ; $7A0F  ctrl $91
    db $99                         ; $7A10  ！
    db $99                         ; $7A11  ！
    db $FA                         ; $7A12  wait-for-button
    db $F7                         ; $7A13  clear page
    db $EF,$EE                     ; $7A14  newline
    db $35,$35,$8D,$2A,$54         ; $7A16  つつ゛きを = つづきを
    db $90                         ; $7A1B  　(space)
    db $4C,$44,$43,$30,$29         ; $7A1C  よみますか
    db $98                         ; $7A21  ？
    db $EF,$EE                     ; $7A22  newline
    db $FF                         ; $7A24  はい/いいえ
    db $F0                         ; $7A25  end of message


; --------------------------------------------------------------------------
; Message #177 ($7A26)
;   「モンスターにっき
;   さく　モンスターじいさん
;   「〈テリー〉という　しょうねんは
;   なかなか　みどころのあるやつじゃ。
;   「ろうやに　いれられそうになった
;   プリォを　たすけてやったそうじゃ！
;   「さすが　わたぼうに　つれてこられた
;   だけのことは　あるのう。
;   つづきを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg177:                             ; $7A26  (file $117A26)
    db $96                         ; $7A26  end name/box tag
    db $7E,$8C,$67,$6A,$9C,$3A,$36,$2A; $7A27  モンスターにっき
    db $EF,$EE                     ; $7A2F  newline
    db $90                         ; $7A31  　(space)
    db $2E,$2B                     ; $7A32  さく
    db $90                         ; $7A34  　(space)
    db $7E,$8C,$67,$6A,$9C,$2F,$8D,$25,$2E,$55; $7A35  モンスターし゛いさん = モンスターじいさん
    db $FA                         ; $7A3F  wait-for-button
    db $F7                         ; $7A40  clear page
    db $EF,$EE                     ; $7A41  newline
    db $96                         ; $7A43  end name/box tag
    db $F6                         ; $7A44  «insert hero name»
    db $38,$25,$26                 ; $7A45  という
    db $90                         ; $7A48  　(space)
    db $2F,$4D,$26,$3C,$55,$3E     ; $7A49  しょうねんは
    db $EF,$EE                     ; $7A4F  newline
    db $90                         ; $7A51  　(space)
    db $39,$29,$39,$29             ; $7A52  なかなか
    db $90                         ; $7A56  　(space)
    db $44,$38,$8D,$2D,$52,$3D,$24,$50,$48,$35,$2F,$8D,$49; $7A57  みと゛ころのあるやつし゛ゃ = みどころのあるやつじゃ
    db $8F                         ; $7A64  。
    db $FA                         ; $7A65  wait-for-button
    db $F7                         ; $7A66  clear page
    db $EF,$EE                     ; $7A67  newline
    db $96                         ; $7A69  end name/box tag
    db $52,$26,$48,$3A             ; $7A6A  ろうやに
    db $90                         ; $7A6E  　(space)
    db $25,$51,$4E,$51,$32,$26,$3A,$39,$36,$33; $7A6F  いれられそうになった
    db $EF,$EE                     ; $7A79  newline
    db $90                         ; $7A7B  　(space)
    db $77,$8E,$86,$5E,$54         ; $7A7C  フ゜リォを = プリォを
    db $90                         ; $7A81  　(space)
    db $33,$30,$2C,$37,$48,$36,$33,$32,$26,$2F,$8D,$49; $7A82  たすけてやったそうし゛ゃ = たすけてやったそうじゃ
    db $99                         ; $7A8E  ！
    db $FA                         ; $7A8F  wait-for-button
    db $F7                         ; $7A90  clear page
    db $EF,$EE                     ; $7A91  newline
    db $96                         ; $7A93  end name/box tag
    db $2E,$30,$29,$8D             ; $7A94  さすか゛ = さすが
    db $90                         ; $7A98  　(space)
    db $53,$33,$42,$8D,$26,$3A     ; $7A99  わたほ゛うに = わたぼうに
    db $90                         ; $7A9F  　(space)
    db $35,$51,$37,$2D,$4E,$51,$33 ; $7AA0  つれてこられた
    db $EF,$EE                     ; $7AA7  newline
    db $90                         ; $7AA9  　(space)
    db $33,$8D,$2C,$3D,$2D,$38,$3E ; $7AAA  た゛けのことは = だけのことは
    db $90                         ; $7AB1  　(space)
    db $24,$50,$3D,$26             ; $7AB2  あるのう
    db $8F                         ; $7AB6  。
    db $FA                         ; $7AB7  wait-for-button
    db $F7                         ; $7AB8  clear page
    db $EF,$EE                     ; $7AB9  newline
    db $35,$35,$8D,$2A,$54         ; $7ABB  つつ゛きを = つづきを
    db $90                         ; $7AC0  　(space)
    db $4C,$44,$43,$30,$29         ; $7AC1  よみますか
    db $98                         ; $7AC6  ？
    db $EF,$EE                     ; $7AC7  newline
    db $FF                         ; $7AC9  はい/いいえ
    db $F0                         ; $7ACA  end of message


; --------------------------------------------------------------------------
; Message #178 ($7ACB)
;   「〈テリー〉は　もう　[0D]クラスを
;   せいは　しよったわい！
;   「おうさまの　いらいも
;   なんなく　こなしたそうじゃ。
;   「バトルレックスの　タマゴを
;   いちげきで　けしさったそうだぞい！
;   「こんかいは　いいマスターを
;   わたぼうは　つれてきたのう。
; --------------------------------------------------------------------------
Bank69_Msg178:                             ; $7ACB  (file $117ACB)
    db $96                         ; $7ACB  end name/box tag
    db $F6                         ; $7ACC  «insert hero name»
    db $3E                         ; $7ACD  は
    db $90                         ; $7ACE  　(space)
    db $47,$26                     ; $7ACF  もう
    db $90                         ; $7AD1  　(space)
    db $0D                         ; $7AD2  ctrl $0D
    db $62,$85,$67,$54             ; $7AD3  クラスを
    db $EF,$EE                     ; $7AD7  newline
    db $90                         ; $7AD9  　(space)
    db $31,$25,$3E                 ; $7ADA  せいは
    db $90                         ; $7ADD  　(space)
    db $2F,$4C,$36,$33,$53,$25     ; $7ADE  しよったわい
    db $99                         ; $7AE4  ！
    db $FA                         ; $7AE5  wait-for-button
    db $F7                         ; $7AE6  clear page
    db $EF,$EE                     ; $7AE7  newline
    db $96                         ; $7AE9  end name/box tag
    db $28,$26,$2E,$43,$3D         ; $7AEA  おうさまの
    db $90                         ; $7AEF  　(space)
    db $25,$4E,$25,$47             ; $7AF0  いらいも
    db $EF,$EE                     ; $7AF4  newline
    db $90                         ; $7AF6  　(space)
    db $39,$55,$39,$2B             ; $7AF7  なんなく
    db $90                         ; $7AFB  　(space)
    db $2D,$39,$2F,$33,$32,$26,$2F,$8D,$49; $7AFC  こなしたそうし゛ゃ = こなしたそうじゃ
    db $8F                         ; $7B05  。
    db $FA                         ; $7B06  wait-for-button
    db $F7                         ; $7B07  clear page
    db $EF,$EE                     ; $7B08  newline
    db $96                         ; $7B0A  end name/box tag
    db $75,$8D,$6F,$87,$88,$6D,$62,$67,$3D; $7B0B  ハ゛トルレックスの = バトルレックスの
    db $90                         ; $7B14  　(space)
    db $6A,$7A,$64,$8D,$54         ; $7B15  タマコ゛を = タマゴを
    db $EF,$EE                     ; $7B1A  newline
    db $90                         ; $7B1C  　(space)
    db $25,$34,$2C,$8D,$2A,$37,$8D ; $7B1D  いちけ゛きて゛ = いちげきで
    db $90                         ; $7B24  　(space)
    db $2C,$2F,$2E,$36,$33,$32,$26,$33,$8D,$32,$8D,$25; $7B25  けしさったそうた゛そ゛い = けしさったそうだぞい
    db $99                         ; $7B31  ！
    db $FA                         ; $7B32  wait-for-button
    db $F7                         ; $7B33  clear page
    db $EF,$EE                     ; $7B34  newline
    db $96                         ; $7B36  end name/box tag
    db $2D,$55,$29,$25,$3E         ; $7B37  こんかいは
    db $90                         ; $7B3C  　(space)
    db $25,$25,$7A,$67,$6A,$9C,$54 ; $7B3D  いいマスターを
    db $EF,$EE                     ; $7B44  newline
    db $90                         ; $7B46  　(space)
    db $53,$33,$42,$8D,$26,$3E     ; $7B47  わたほ゛うは = わたぼうは
    db $90                         ; $7B4D  　(space)
    db $35,$51,$37,$2A,$33,$3D,$26 ; $7B4E  つれてきたのう
    db $8F                         ; $7B55  。
    db $F7                         ; $7B56  clear page
    db $F0                         ; $7B57  end of message


; --------------------------------------------------------------------------
; Message #179 ($7B58)
;   「うちのむすめは　タィジャいち
;   かわいい！　そうおもうだろう？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg179:                             ; $7B58  (file $117B58)
    db $EA                         ; $7B58  ▶ new page
    db $9F                         ; $7B59  box tag
    db $96                         ; $7B5A  end name/box tag
    db $26,$34,$3D,$45,$30,$46,$3E ; $7B5B  うちのむすめは
    db $90                         ; $7B62  　(space)
    db $6A,$58,$66,$8D,$82,$25,$34 ; $7B63  タィシ゛ャいち = タィジャいち
    db $EF,$EE                     ; $7B6A  newline
    db $90,$90                     ; $7B6C  　　(indent)
    db $29,$53,$25,$25             ; $7B6E  かわいい
    db $99                         ; $7B72  ！
    db $90                         ; $7B73  　(space)
    db $32,$26,$28,$47,$26,$33,$8D,$52,$26; $7B74  そうおもうた゛ろう = そうおもうだろう
    db $98                         ; $7B7D  ？
    db $FF                         ; $7B7E  はい/いいえ
    db $F0                         ; $7B7F  end of message


; --------------------------------------------------------------------------
; Message #180 ($7B80)
;   「きみは　なかなか　みどころある！
;   よし　いいこと　おしえちゃおう。
;   「いうことを　きかないこどもは
;   のびのびと　そだてることだ。
;   「あまり　こまかいことを　くどくど
;   いうと　いうことをきかなくなる。
;   「だからといって　まったく
;   ほったらかしも　いけないんだよ。
; --------------------------------------------------------------------------
Bank69_Msg180:                             ; $7B80  (file $117B80)
    db $EA                         ; $7B80  ▶ new page
    db $9F                         ; $7B81  box tag
    db $96                         ; $7B82  end name/box tag
    db $2A,$44,$3E                 ; $7B83  きみは
    db $90                         ; $7B86  　(space)
    db $39,$29,$39,$29             ; $7B87  なかなか
    db $90                         ; $7B8B  　(space)
    db $44,$38,$8D,$2D,$52,$24,$50 ; $7B8C  みと゛ころある = みどころある
    db $99                         ; $7B93  ！
    db $EF,$EE                     ; $7B94  newline
    db $90,$90                     ; $7B96  　　(indent)
    db $4C,$2F                     ; $7B98  よし
    db $90                         ; $7B9A  　(space)
    db $25,$25,$2D,$38             ; $7B9B  いいこと
    db $90                         ; $7B9F  　(space)
    db $28,$2F,$27,$34,$49,$28,$26 ; $7BA0  おしえちゃおう
    db $8F                         ; $7BA7  。
    db $FA                         ; $7BA8  wait-for-button
    db $F7                         ; $7BA9  clear page
    db $EF,$EE                     ; $7BAA  newline
    db $9F                         ; $7BAC  box tag
    db $96                         ; $7BAD  end name/box tag
    db $25,$26,$2D,$38,$54         ; $7BAE  いうことを
    db $90                         ; $7BB3  　(space)
    db $2A,$29,$39,$25,$2D,$38,$8D,$47,$3E; $7BB4  きかないこと゛もは = きかないこどもは
    db $EF,$EE                     ; $7BBD  newline
    db $90,$90                     ; $7BBF  　　(indent)
    db $3D,$3F,$8D,$3D,$3F,$8D,$38 ; $7BC1  のひ゛のひ゛と = のびのびと
    db $90                         ; $7BC8  　(space)
    db $32,$33,$8D,$37,$50,$2D,$38,$33,$8D; $7BC9  そた゛てることた゛ = そだてることだ
    db $8F                         ; $7BD2  。
    db $FA                         ; $7BD3  wait-for-button
    db $F7                         ; $7BD4  clear page
    db $EF,$EE                     ; $7BD5  newline
    db $9F                         ; $7BD7  box tag
    db $96                         ; $7BD8  end name/box tag
    db $24,$43,$4F                 ; $7BD9  あまり
    db $90                         ; $7BDC  　(space)
    db $2D,$43,$29,$25,$2D,$38,$54 ; $7BDD  こまかいことを
    db $90                         ; $7BE4  　(space)
    db $2B,$38,$8D,$2B,$38,$8D     ; $7BE5  くと゛くと゛ = くどくど
    db $EF,$EE                     ; $7BEB  newline
    db $90,$90                     ; $7BED  　　(indent)
    db $25,$26,$38                 ; $7BEF  いうと
    db $90                         ; $7BF2  　(space)
    db $25,$26,$2D,$38,$54,$2A,$29,$39,$2B,$39,$50; $7BF3  いうことをきかなくなる
    db $8F                         ; $7BFE  。
    db $FA                         ; $7BFF  wait-for-button
    db $F7                         ; $7C00  clear page
    db $EF,$EE                     ; $7C01  newline
    db $9F                         ; $7C03  box tag
    db $96                         ; $7C04  end name/box tag
    db $33,$8D,$29,$4E,$38,$25,$36,$37; $7C05  た゛からといって = だからといって
    db $90                         ; $7C0D  　(space)
    db $43,$36,$33,$2B             ; $7C0E  まったく
    db $EF,$EE                     ; $7C12  newline
    db $90,$90                     ; $7C14  　　(indent)
    db $42,$36,$33,$4E,$29,$2F,$47 ; $7C16  ほったらかしも
    db $90                         ; $7C1D  　(space)
    db $25,$2C,$39,$25,$55,$33,$8D,$4C; $7C1E  いけないんた゛よ = いけないんだよ
    db $8F                         ; $7C26  。
    db $F7                         ; $7C27  clear page
    db $F0                         ; $7C28  end of message


; --------------------------------------------------------------------------
; Message #181 ($7C29)
;   「かえってくれっ！
; --------------------------------------------------------------------------
Bank69_Msg181:                             ; $7C29  (file $117C29)
    db $EA                         ; $7C29  ▶ new page
    db $9F                         ; $7C2A  box tag
    db $96                         ; $7C2B  end name/box tag
    db $29,$27,$36,$37,$2B,$51,$36 ; $7C2C  かえってくれっ
    db $99                         ; $7C33  ！
    db $EF,$EE                     ; $7C34  newline
    db $F7                         ; $7C36  clear page
    db $F0                         ; $7C37  end of message


; --------------------------------------------------------------------------
; Message #182 ($7C38)
;   「うちの　おじいちゃんたら
;   ほんと　がんこなんだから。
; --------------------------------------------------------------------------
Bank69_Msg182:                             ; $7C38  (file $117C38)
    db $EB                         ; $7C38  ▶ new page
    db $9F                         ; $7C39  box tag
    db $96                         ; $7C3A  end name/box tag
    db $26,$34,$3D                 ; $7C3B  うちの
    db $90                         ; $7C3E  　(space)
    db $28,$2F,$8D,$25,$34,$49,$55,$33,$4E; $7C3F  おし゛いちゃんたら = おじいちゃんたら
    db $EF,$EE                     ; $7C48  newline
    db $90,$90                     ; $7C4A  　　(indent)
    db $42,$55,$38                 ; $7C4C  ほんと
    db $90                         ; $7C4F  　(space)
    db $29,$8D,$55,$2D,$39,$55,$33,$8D,$29,$4E; $7C50  か゛んこなんた゛から = がんこなんだから
    db $8F                         ; $7C5A  。
    db $F7                         ; $7C5B  clear page
    db $F0                         ; $7C5C  end of message


; --------------------------------------------------------------------------
; Message #183 ($7C5D)
;   〈テリー〉は　ほんだなを　しらべた。
;   「わがこの　せいちょう　にっき、
;   その[01]
;   「こどもが　うまれた。
;   おんなのこだった。
;   「かっ　かわいい！！　こどもは
;   おやに　にるものだな[91]！　つづく。
;   つづきを　よみますか？
;   〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg183:                             ; $7C5D  (file $117C5D)
    db $F6                         ; $7C5D  «insert hero name»
    db $3E                         ; $7C5E  は
    db $90                         ; $7C5F  　(space)
    db $42,$55,$33,$8D,$39,$54     ; $7C60  ほんた゛なを = ほんだなを
    db $90                         ; $7C66  　(space)
    db $2F,$4E,$41,$8D,$33         ; $7C67  しらへ゛た = しらべた
    db $8F                         ; $7C6C  。
    db $EF,$EE                     ; $7C6D  newline
    db $FA                         ; $7C6F  wait-for-button
    db $F7                         ; $7C70  clear page
    db $EF,$EE                     ; $7C71  newline
    db $F3                         ; $7C73  open text box
    db $96                         ; $7C74  end name/box tag
    db $53,$29,$8D,$2D,$3D         ; $7C75  わか゛この = わがこの
    db $90                         ; $7C7A  　(space)
    db $31,$25,$34,$4D,$26         ; $7C7B  せいちょう
    db $90                         ; $7C80  　(space)
    db $3A,$36,$2A                 ; $7C81  にっき
    db $A4                         ; $7C84  、
    db $EF,$EE                     ; $7C85  newline
    db $90                         ; $7C87  　(space)
    db $32,$3D                     ; $7C88  その
    db $01                         ; $7C8A  ctrl $01
    db $FA                         ; $7C8B  wait-for-button
    db $F7                         ; $7C8C  clear page
    db $EF,$EE                     ; $7C8D  newline
    db $96                         ; $7C8F  end name/box tag
    db $2D,$38,$8D,$47,$29,$8D     ; $7C90  こと゛もか゛ = こどもが
    db $90                         ; $7C96  　(space)
    db $26,$43,$51,$33             ; $7C97  うまれた
    db $8F                         ; $7C9B  。
    db $EF,$EE                     ; $7C9C  newline
    db $90                         ; $7C9E  　(space)
    db $28,$55,$39,$3D,$2D,$33,$8D,$36,$33; $7C9F  おんなのこた゛った = おんなのこだった
    db $8F                         ; $7CA8  。
    db $FA                         ; $7CA9  wait-for-button
    db $F7                         ; $7CAA  clear page
    db $EF,$EE                     ; $7CAB  newline
    db $96                         ; $7CAD  end name/box tag
    db $29,$36                     ; $7CAE  かっ
    db $90                         ; $7CB0  　(space)
    db $29,$53,$25,$25             ; $7CB1  かわいい
    db $99                         ; $7CB5  ！
    db $99                         ; $7CB6  ！
    db $90                         ; $7CB7  　(space)
    db $2D,$38,$8D,$47,$3E         ; $7CB8  こと゛もは = こどもは
    db $EF,$EE                     ; $7CBD  newline
    db $90                         ; $7CBF  　(space)
    db $28,$48,$3A                 ; $7CC0  おやに
    db $90                         ; $7CC3  　(space)
    db $3A,$50,$47,$3D,$33,$8D,$39 ; $7CC4  にるものた゛な = にるものだな
    db $91                         ; $7CCB  ctrl $91
    db $99                         ; $7CCC  ！
    db $90                         ; $7CCD  　(space)
    db $35,$35,$8D,$2B             ; $7CCE  つつ゛く = つづく
    db $8F                         ; $7CD2  。
    db $FA                         ; $7CD3  wait-for-button
    db $F7                         ; $7CD4  clear page
    db $EF,$EE                     ; $7CD5  newline
    db $35,$35,$8D,$2A,$54         ; $7CD7  つつ゛きを = つづきを
    db $90                         ; $7CDC  　(space)
    db $4C,$44,$43,$30,$29         ; $7CDD  よみますか
    db $98                         ; $7CE2  ？
    db $EF,$EE                     ; $7CE3  newline
    db $FF                         ; $7CE5  はい/いいえ
    db $F0                         ; $7CE6  end of message


; --------------------------------------------------------------------------
; Message #184 ($7CE7)
;   「わがこの　せいちょう　にっき、
;   その[02]
;   「わがこは　ことばを　おぼえた。
;   なかなか　せいちょうがはやい。
;   「せいちょうが　はやすぎて　すぐに
;   おばあさんに　なったらどうしよう。
; --------------------------------------------------------------------------
Bank69_Msg184:                             ; $7CE7  (file $117CE7)
    db $96                         ; $7CE7  end name/box tag
    db $53,$29,$8D,$2D,$3D         ; $7CE8  わか゛この = わがこの
    db $90                         ; $7CED  　(space)
    db $31,$25,$34,$4D,$26         ; $7CEE  せいちょう
    db $90                         ; $7CF3  　(space)
    db $3A,$36,$2A                 ; $7CF4  にっき
    db $A4                         ; $7CF7  、
    db $EF,$EE                     ; $7CF8  newline
    db $90                         ; $7CFA  　(space)
    db $32,$3D                     ; $7CFB  その
    db $02                         ; $7CFD  ctrl $02
    db $FA                         ; $7CFE  wait-for-button
    db $F7                         ; $7CFF  clear page
    db $EF,$EE                     ; $7D00  newline
    db $96                         ; $7D02  end name/box tag
    db $53,$29,$8D,$2D,$3E         ; $7D03  わか゛こは = わがこは
    db $90                         ; $7D08  　(space)
    db $2D,$38,$3E,$8D,$54         ; $7D09  ことは゛を = ことばを
    db $90                         ; $7D0E  　(space)
    db $28,$42,$8D,$27,$33         ; $7D0F  おほ゛えた = おぼえた
    db $8F                         ; $7D14  。
    db $EF,$EE                     ; $7D15  newline
    db $90                         ; $7D17  　(space)
    db $39,$29,$39,$29             ; $7D18  なかなか
    db $90                         ; $7D1C  　(space)
    db $31,$25,$34,$4D,$26,$29,$8D,$3E,$48,$25; $7D1D  せいちょうか゛はやい = せいちょうがはやい
    db $8F                         ; $7D27  。
    db $FA                         ; $7D28  wait-for-button
    db $F7                         ; $7D29  clear page
    db $EF,$EE                     ; $7D2A  newline
    db $96                         ; $7D2C  end name/box tag
    db $31,$25,$34,$4D,$26,$29,$8D ; $7D2D  せいちょうか゛ = せいちょうが
    db $90                         ; $7D34  　(space)
    db $3E,$48,$30,$2A,$8D,$37     ; $7D35  はやすき゛て = はやすぎて
    db $90                         ; $7D3B  　(space)
    db $30,$2B,$8D,$3A             ; $7D3C  すく゛に = すぐに
    db $EF,$EE                     ; $7D40  newline
    db $90                         ; $7D42  　(space)
    db $28,$3E,$8D,$24,$2E,$55,$3A ; $7D43  おは゛あさんに = おばあさんに
    db $90                         ; $7D4A  　(space)
    db $39,$36,$33,$4E,$38,$8D,$26,$2F,$4C,$26; $7D4B  なったらと゛うしよう = なったらどうしよう
    db $8F                         ; $7D55  。
    db $F7                         ; $7D56  clear page
    db $F0                         ; $7D57  end of message


; --------------------------------------------------------------------------
; Message #185 ($7D58)
;   「ハッ。　あなたは　どなた？
;   ここに　どうやって　はいったの？
;   「、、もしかして　わたしのびぼうに
;   めがくらんで　しのびこんだのね？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg185:                             ; $7D58  (file $117D58)
    db $EB                         ; $7D58  ▶ new page
    db $9F                         ; $7D59  box tag
    db $96                         ; $7D5A  end name/box tag
    db $75,$6D                     ; $7D5B  ハッ
    db $8F                         ; $7D5D  。
    db $90                         ; $7D5E  　(space)
    db $24,$39,$33,$3E             ; $7D5F  あなたは
    db $90                         ; $7D63  　(space)
    db $38,$8D,$39,$33             ; $7D64  と゛なた = どなた
    db $98                         ; $7D68  ？
    db $EF,$EE                     ; $7D69  newline
    db $90,$90                     ; $7D6B  　　(indent)
    db $2D,$2D,$3A                 ; $7D6D  ここに
    db $90                         ; $7D70  　(space)
    db $38,$8D,$26,$48,$36,$37     ; $7D71  と゛うやって = どうやって
    db $90                         ; $7D77  　(space)
    db $3E,$25,$36,$33,$3D         ; $7D78  はいったの
    db $98                         ; $7D7D  ？
    db $FA                         ; $7D7E  wait-for-button
    db $F7                         ; $7D7F  clear page
    db $EF,$EE                     ; $7D80  newline
    db $9F                         ; $7D82  box tag
    db $96                         ; $7D83  end name/box tag
    db $A4                         ; $7D84  、
    db $A4                         ; $7D85  、
    db $47,$2F,$29,$2F,$37         ; $7D86  もしかして
    db $90                         ; $7D8B  　(space)
    db $53,$33,$2F,$3D,$3F,$8D,$42,$8D,$26,$3A; $7D8C  わたしのひ゛ほ゛うに = わたしのびぼうに
    db $EF,$EE                     ; $7D96  newline
    db $90,$90                     ; $7D98  　　(indent)
    db $46,$29,$8D,$2B,$4E,$55,$37,$8D; $7D9A  めか゛くらんて゛ = めがくらんで
    db $90                         ; $7DA2  　(space)
    db $2F,$3D,$3F,$8D,$2D,$55,$33,$8D,$3D,$3C; $7DA3  しのひ゛こんた゛のね = しのびこんだのね
    db $98                         ; $7DAD  ？
    db $FF                         ; $7DAE  はい/いいえ
    db $F0                         ; $7DAF  end of message


; --------------------------------------------------------------------------
; Message #186 ($7DB0)
;   「いい　こころがけだわ。
;   「じょせいの　よろこばせかたを
;   しっているようね。
; --------------------------------------------------------------------------
Bank69_Msg186:                             ; $7DB0  (file $117DB0)
    db $EB                         ; $7DB0  ▶ new page
    db $9F                         ; $7DB1  box tag
    db $96                         ; $7DB2  end name/box tag
    db $25,$25                     ; $7DB3  いい
    db $90                         ; $7DB5  　(space)
    db $2D,$2D,$52,$29,$8D,$2C,$33,$8D,$53; $7DB6  こころか゛けた゛わ = こころがけだわ
    db $8F                         ; $7DBF  。
    db $EF,$EE                     ; $7DC0  newline
    db $FA                         ; $7DC2  wait-for-button
    db $F7                         ; $7DC3  clear page
    db $EF,$EE                     ; $7DC4  newline
    db $F3                         ; $7DC6  open text box
    db $9F                         ; $7DC7  box tag
    db $96                         ; $7DC8  end name/box tag
    db $2F,$8D,$4D,$31,$25,$3D     ; $7DC9  し゛ょせいの = じょせいの
    db $90                         ; $7DCF  　(space)
    db $4C,$52,$2D,$3E,$8D,$31,$29,$33,$54; $7DD0  よろこは゛せかたを = よろこばせかたを
    db $EF,$EE                     ; $7DD9  newline
    db $90,$90                     ; $7DDB  　　(indent)
    db $2F,$36,$37,$25,$50,$4C,$26,$3C; $7DDD  しっているようね
    db $8F                         ; $7DE5  。
    db $F7                         ; $7DE6  clear page
    db $F0                         ; $7DE7  end of message


; --------------------------------------------------------------------------
; Message #187 ($7DE8)
;   「それじゃあ　どろぼうをしに
;   ここに　しのびこんだのかしら？〔はい/いいえ〕
; --------------------------------------------------------------------------
Bank69_Msg187:                             ; $7DE8  (file $117DE8)
    db $EB                         ; $7DE8  ▶ new page
    db $9F                         ; $7DE9  box tag
    db $96                         ; $7DEA  end name/box tag
    db $32,$51,$2F,$8D,$49,$24     ; $7DEB  それし゛ゃあ = それじゃあ
    db $90                         ; $7DF1  　(space)
    db $38,$8D,$52,$42,$8D,$26,$54,$2F,$3A; $7DF2  と゛ろほ゛うをしに = どろぼうをしに
    db $EF,$EE                     ; $7DFB  newline
    db $90,$90                     ; $7DFD  　　(indent)
    db $2D,$2D,$3A                 ; $7DFF  ここに
    db $90                         ; $7E02  　(space)
    db $2F,$3D,$3F,$8D,$2D,$55,$33,$8D,$3D,$29,$2F,$4E; $7E03  しのひ゛こんた゛のかしら = しのびこんだのかしら
    db $98                         ; $7E0F  ？
    db $FF                         ; $7E10  はい/いいえ
    db $F0                         ; $7E11  end of message

Bank69_Pad:                                ; $7E12
    ds $01EE, $FF                   ; $FF padding to $8000
