# tiles/ — tile-graphics data banks

These banks hold **LZ-compressed tile graphics** in the TileLoad format
(`$4001` = 2-byte-LE tile-block pointer table; each block = `[count.w][escape]
[stream]`, decoded by ROM0 `TileLoad $18A2`; see
`../rom0_vblank_callees.asm` and memory `tile-data-format`). Verified with
`../tools/rendertiles.py --detect` (every block-header count is a multiple of
16). Rendered PNGs are in `../images/bankNN_all.png`.

> Many of these files still carry MIS-LABELED original headers ("Code bank N",
> or game-system names like "Breeding"/"Ranch"/"Battle phase init"). A correction
> banner was prepended to those 27 files. They are all tile DATA — a game-system
> name at most hints at what the graphics DEPICT, not executable logic.

| dec | hex | contents (best-guess from render) |
|----:|-----|-----------------------------------|
| 35–45 | $23–$2D | map / overworld / dungeon tilesets |
| 46 | $2E | UI/menu fonts (kana), HP/MP/G/LV, icons, DQ logo, dialogue font (block $1E) |
| 47 | $2F | battle monster sprites (slime family) |
| 48 | $30 | floor / map tiles |
| 49–55 | $31–$37 | tiles / sprites (some depict breeding/ranch/battle screens) |
| 56–58 | $38–$3A | monster info-screen sprites (each block = one monster) |
| 59–63 | $3B–$3F | graphics / battle UI tiles (63 also has tilemap blocks) |
| 90–91 | $5A–$5B | battle-scene tile graphics |

Correctly-headed already (not re-banded): 46, 56, 57, 58.

## Render any of them
```
python3 ../tools/rendertiles.py 48            # bank 48 ($30) -> bank48_all.png
python3 ../tools/rendertiles.py 46 0 --ascii  # one block + ASCII
python3 ../tools/rendertiles.py 56 --palette dmg
python3 ../tools/rendertiles.py --detect      # list all tile-data banks
```
Note: `.asm`/PNG files use DECIMAL bank numbers (bank46 = $2E); analysis prose
often uses hex.
