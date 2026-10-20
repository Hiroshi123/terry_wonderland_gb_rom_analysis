# Dragon Quest Monsters: Terry's Wonderland — GBC Disassembly

A work-in-progress, richly-annotated disassembly of **Dragon Quest Monsters: Terry's
Wonderland** (ドラゴンクエストモンスターズ テリーのワンダーランド) for the Game Boy
Color — a 2&nbsp;MB, MBC5 cartridge.

The goal, in the spirit of [pokered](https://github.com/pret/pokered), is a
**byte-exact, human-readable** reconstruction: every byte of the ROM is accounted
for as code, data, or padding, with inline comments explaining what the hardware is
actually doing. This is a reverse-engineering / study project, not a ROM hack.

> **ROM not included.** `terry.gbc` (and `terry.sav`) are copyrighted and are
> **git-ignored**. Supply your own legally-obtained dump at the repo root; the
> `tools/` scripts read from it to regenerate and verify the `.asm` files. The ROM
> is treated as strictly read-only source data.

## What's here

The 128 ROM banks are disassembled and grouped by subsystem into directories, each
with its own `README.md` describing the banks it holds. Highlights:

| Area | Directory | What it covers |
|---|---|---|
| Boot / core engine | *(root)* | `main.asm`, `init.asm`, `bank0.asm`, the RST/VBlank/IRQ handlers (`rom0_vblank_callees.asm`, `rom0_misc.asm`), and the top-level **state machine** (`statemachine.asm`, `bank1.asm`) |
| WRAM / HRAM map | *(root)* | `wram.asm` — labelled RAM variable map |
| Overworld | `overworld/` | movement, map scrolling, per-area-type tile engines (banks 12–15 share one engine), warps, mini-map (banks 4, 6, 10–18, 25) |
| Battle | `battle/` | battle flow, rendering, and the large battle logic banks (9, 20, 80–94) |
| Monsters | `monsters/` | species stat database (bank 3), breeding chart (bank 22), party/status screen (bank 7) |
| Text / script | `text/` | all dialogue & message banks (64–78), uncompressed kana — see the codec notes below |
| Tile graphics | `tiles/` | map/sprite tilesets + the kana **font** (bank 46); banks 35–52 |
| Palettes / scene load | `pallette/` | GBC palette tables and scene-background loaders (banks 8, 23) |
| Audio | `sounds/`, `audio.asm` | BGM score data (banks 28–30) |
| Animation | `animation/` | sprite/tile-scroll animation drivers (banks 2, 5, 19) |
| Unused | `none/` | banks that are all `$FF` (unmapped ROM) |
| Tooling | `tools/` | Python disassemblers & table generators (below) |

`state_diagram.md` and `banks.md` sketch the high-level game-state flow and the
bank→subsystem mapping that drove the directory layout.

## A few things that were figured out the hard way

- **The "sound banks" are text.** Banks 64–78 were originally assumed to be an SFX
  driver; they are actually **uncompressed, identity-mapped kana text**. The
  routines they call (`$0568`/`$05A7`/`$05BA`) are the message/text engine, which
  emits glyph tiles straight to VRAM — there are no sound-register writes on that
  path. See `text/README.md` for the full character/control-code table.
- **bank 64/65** is the master **name/label table** (monster, spell, skill, item,
  and place names + the status-screen template), looked up by index from battle and
  menu code via `RST $10` banking. bank 64 is a byte-for-byte mirror of bank 65.
- **banks 12–15 are one byte-identical movement engine** selected per area type;
  only the trailing map data differs. Annotated once in `overworld/bank12.asm`.
- The monster **species database** lives in bank 3 (`$4461`, 221 records × 43 bytes)
  and the **breeding chart** in bank 22 (`$4B30`).

## Verification & tooling

Byte-exactness is the core discipline: a generated `.asm` file must reassemble to
exactly the original 16&nbsp;KB bank. The `tools/` directory holds the Python
helpers used to disassemble, decode data tables, render graphics, and regenerate
files from the ROM:

- `sm83dis.py` / `sm83rec.py` — SM83 (GBC CPU) disassembler / byte-reconstruction
  verifier.
- `gen_*.py` — per-bank generators that emit annotated `.asm` straight from ROM
  bytes (e.g. `gen_bank64.py` decodes the kana text stream, `gen_bank4_table.py`
  rebuilds a function table).
- `rendertiles.py`, `decode_area.py` — decompress and render tile/map graphics to
  PNG (sample output in `images/`, `maps_out/`, and the `*.png` at the repo root).

## Status

Ongoing. Large swathes — the text banks, the monster/graphics data banks, the
overworld movement engines, and much of the battle and state-machine code — are
decoded and annotated; other areas are still partially raw `INCBIN` with notes.
Analysis conclusions are marked as *proven* vs *inferred* in the source comments.

## Layout at a glance

```
.                      boot, core engine, state machine, RAM map
├── overworld/         movement, maps, warps, mini-map
├── battle/            battle flow, rendering, logic
├── monsters/          species DB, breeding, status screen
├── text/              dialogue & message banks (kana)
├── tiles/             tilesets + kana font
├── pallette/          palettes & scene-background loaders
├── sounds/            BGM score data
├── animation/         animation drivers
├── none/              unused ($FF) banks
├── tools/             Python disassemblers & generators
├── images/ maps_out/  rendered graphics output
└── terry.gbc          (git-ignored — supply your own)
```
