# Rendered tile images (terry.gbc)

PNG tilesheets decoded from the real tile-data banks via
`../tools/rendertiles.py`. **Files are named by DECIMAL bank number to match the
`.asm` files** (e.g. `bank46_all.png` = `bank46.asm` = hex `$2E`).

## How a tile-data bank is identified (important)

The `self-ID byte + $4001 pointer table` layout is shared by BOTH tile-data
banks AND code banks (a code bank's `$4001` is its RST-`$10` function table), so
shape alone does NOT prove tile data. The reliable test: **a real tile block's
header `count` is a multiple of 16** (tiles are 16 bytes). Run:

```
python3 ../tools/rendertiles.py --detect
```

Verified tile-data banks: **decimal 35-63 (`$23`-`$3F`) and 90-91 (`$5A`-`$5B`)**.

> WARNING: some `.asm` files in the 35-63 range are MIS-DISASSEMBLED as code
> (e.g. `bank37.asm` says "Code bank 37", but bank 37 / `$25` is actually
> compressed map/dungeon TILE data — its "function table" is the tile-block
> pointer table). Trust `--detect` and the render, not those headers.

## Tile-data banks

| file | dec | hex | notes |
|------|----:|-----|-------|
| bank35_all.png | 35 | $23 | map/overworld tileset |
| bank36_all.png | 36 | $24 | map/overworld tileset |
| bank37_all.png | 37 | $25 | map/dungeon tileset (bank37.asm mislabels this as code) |
| bank38_all.png | 38 | $26 | map/overworld tileset |
| bank39_all.png | 39 | $27 | map / large set |
| bank40_all.png | 40 | $28 | tileset |
| bank41_all.png | 41 | $29 | tileset |
| bank42_all.png | 42 | $2A | tileset |
| bank43_all.png | 43 | $2B | large tileset |
| bank44_all.png | 44 | $2C | tileset |
| bank45_all.png | 45 | $2D | tileset |
| bank46_all.png | 46 | $2E | UI/menu fonts, kana, HP/MP/G/LV, icons, DQ logo |
| bank46_block0.png | 46 | $2E | font/icon block close-up |
| bank47_all.png | 47 | $2F | monster/battle sprites (slime family) |
| bank48_all.png | 48 | $30 | floor/map tiles |
| bank49_all.png | 49 | $31 | tiles/sprites |
| bank50_all.png | 50 | $32 | tiles/sprites |
| bank51_all.png | 51 | $33 | tiles/sprites |
| bank52_all.png | 52 | $34 | tiles/sprites |
| bank53_all.png | 53 | $35 | tiles/sprites |
| bank54_all.png | 54 | $36 | tiles/sprites |
| bank55_all.png | 55 | $37 | tiles/sprites |
| bank56_all.png | 56 | $38 | monster info-screen sprites |
| bank56_all_dmg.png | 56 | $38 | same, DMG-green palette demo |
| bank57_all.png | 57 | $39 | monster info-screen sprites |
| bank58_all.png | 58 | $3A | monster info-screen sprites |
| bank59_all.png | 59 | $3B | graphics |
| bank60_all.png | 60 | $3C | graphics (239 blocks) |
| bank61_all.png | 61 | $3D | graphics (196 blocks) |
| bank62_all.png | 62 | $3E | graphics |
| bank63_all.png | 63 | $3F | battle UI tiles + some tilemap blocks |
| bank90_all.png | 90 | $5A | graphics |
| bank91_all.png | 91 | $5B | battle-scene tile graphics |

## NOT tile banks (excluded)
- Bank 23 ($17, `bank23.asm`): CODE (map tile loader). Its `$4001` is a
  function table.
- Banks 92-95 ($5C-$5F): CODE (attack-animation). `--detect` reports them as
  `code` (headers fail the ×16 test).
- Bank 18 ($12): VRAM pattern-fill via `$0D7C`/`$08B9`, no block table.

## Regenerate (input DECIMAL or 0xHEX; output is decimal-named)
```
python3 ../tools/rendertiles.py 48                 # bank 48 ($30) -> bank48_all.png
python3 ../tools/rendertiles.py 0x30               # same, hex input
python3 ../tools/rendertiles.py 46 0 --ascii       # one block + ASCII
python3 ../tools/rendertiles.py 56 --palette dmg   # colorized
python3 ../tools/rendertiles.py --detect           # list real tile banks
```
Palette: `gray` (default = raw 2bpp indices), `dmg` (GB green), or custom
`RRGGBB,RRGGBB,RRGGBB,RRGGBB`. Real CGB palettes not yet extracted.

## Decoder accuracy
Faithful port of ROM routine `$18B4-$1949`, verified byte-for-byte against an
opcode-level interpreter over all blocks.
