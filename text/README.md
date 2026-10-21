# text/ — dialogue & message text banks

The game's script. These banks were **previously mislabeled "sound"** — they are
actually **uncompressed kana text data**. Each is 70–84% kana-range bytes that
decode to fluent Japanese (verified). The routines they call (`$0568`/`$05A7`/
`$05BA`) are the **message/text engine**, not the sound driver.

## The message engine (shared ROM0 routines)
Each bank's fn stubs hand a message directory pointer to:
- `$0568` — message setup: build window/VRAM copy pointers (`$C827→$C82B/$C82D`)
  via VRAM helpers `$08B9`/`$0D24`.
- `$05A7` — copy text bytes `(DE)→(HL)` into the message buffer `$C837/$C838`.
- `$05BA` → `$05C9`/`$05E0` — page-print loop: bank-switch to the text bank
  (`LD ($2100)/$4100`) and emit **glyph tiles to VRAM via `$1E80`**.

No `$FF10–$FF3F` (sound register) writes exist on this path. The `$F0` byte that
earlier looked like a "sound stream terminator" is the text **newline** code.

## Text encoding (see memory: text-codec)
One byte per character; **code = kana font tile index** (font blocks bank46 `$1E`
+ `$1F`). Hiragana `$24–$55`, katakana `$56–$8C`, dakuten `゛`=`$8D`, handakuten
`゜`=`$8E` (voiced = base+`$8D`, semi = base+`$8E`), long vowel `ー`=`$9C`.
Control/insert codes: `$90` space, `$8F` 。, `$A4` 、, `$F0/$EE` newline, `$EA/$EB`
new page, `$99` end, `$98` ？, `$FF` はい/いいえ, `$F6` insert hero name, etc.
Each string starts with a **speaker-name label** (e.g. `おう`=King, `フ゜リォ`).

## Banks
Overworld dialogue — directory word at `$401C` → pointer table → strings:

All banks below are **fully decoded and byte-exact** (each .asm reassembles to
its exact 16 KB). "strings" = string-pointer count (some banks reuse strings via
duplicate pointers, noted in-file as "shared by #a,#b").

| bank | strings | content | bank | strings | content |
|---|---|---|---|---|---|
| bank64 | =bank65 | mirror (self-ID $41) | bank72 | 158 | NPC dialogue |
| bank65 | 1244† | place/menu LABELS | bank73 | 206 | NPC (ミレーヨ…) |
| **bank66** | 226 | **annotated ref** (Prio arc) | bank74 | 480 | NPC (サンチ…) |
| bank67 | 182 | battle-arena NPCs | bank75 | 168 | NPC (わたぼう…) |
| bank68 | 172 | NPCs + library lore | bank77 | 727 | monster-family LABELS |
| bank69 | 188 | NPC dialogue | bank78 | 369 | NPC dialogue |
| bank70 | 200 | NPC dialogue | | | |
| bank71 | 172 | NPCs + library lore | | | |

- **bank66** carries the fully annotated engine + directory walkthrough — read it
  first. It has a FLAT directory (`$401C` word → 226 string pointers → sentences)
  and is fully decoded (all 226 messages, address-ordered, byte-exact).
- **bank77** is label-like (monster-family names スライム系/ドラゴン系… laid out
  in columns) but still uses the flat `$401C` pointer table, so it's decoded the
  same way as the sentence banks.
- **† bank64/65** are NOT flat sentence banks. They hold a **place-name / menu-
  LABEL table**: a TWO-LEVEL index (24 section pointers → per-section sub-tables)
  into a `$F0`-delimited kana word stream (`$4C58-$78E5`, 1244 labels, e.g.
  しろ/まち/たびのとびら/ぼくじょう/メルキドのまち). bank64 is a byte-for-byte
  mirror of bank65. bank65 is fully decoded + byte-exact in `bank65.asm`.
- The other overworld banks (67-75, 77-78) share bank66's flat fn0/fn1/fn2 →
  `$401C` layout; their headers point back to bank66.
- **bank76** = the **battle** message path (same engine, directory at `$403D`,
  gated on `$C823`/`$DD6D`+`$D7` battle-font offset). Unlike the flat overworld
  banks it is **MULTI-LEVEL** (header → main table → inline strings, plus level-2
  pointer tables → a second string block). Fully decoded + byte-exact: 332
  strings, e.g. `〈mon〉が あらわれた！`, `〈mon〉しかし 〈v〉は まだ こちらに きづ
  いていない！`. Battle control codes: `$ED`=monster-name, `$F9`=verb/aux insert,
  `$10`=rank, `$F1`=newline, `$FC`/`$EC`=grouping. Related battle-text pieces are
  in `../battle` and text banks 80-83.

**Every text bank in this directory is now decoded and byte-exact** (each .asm
reassembles to its exact 16 KB): bank64 (mirror stub), bank65 (label table),
bank66-78 (dialogue/label/battle). bank76 was the last and most complex.

## Notable content found
- bank66 `$41E2` = the game's opening line (mother calls Terry to bed).
- bank66 `$4C7F`/`$57C0` = NPC **プリォ** (monster-ranch keeper) + the King's
  summon scene (Hoimin escaped). See memory: npc-prio.

## Cross-references
- Character/control codec: memory `text-codec`; font tiles: `../tiles` (bank46).
- Overworld NPC → message-id path: `../overworld` (bank11 `$D7D2` object `+4`).
- Actual BGM/sound: `../sounds` (banks 28-30). The real SFX/driver location is
  now **unverified** (the old "64-78 = sound" claim was wrong).
