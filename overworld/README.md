# overworld/ — overworld exploration banks

The map/exploration system: player movement, map scrolling, area-type movement
engines, and warp/door handling. Driven from State 1 (bank1) each frame.

| bank | role |
|---|---|
| bank4  | player movement / D-pad handler / warp detection (dispatcher; fn4 = per-frame mover) |
| bank6  | overworld frame handler (large; per-frame world update) |
| bank10 | area/dungeon phase controller — set A |
| bank18 | area/dungeon phase controller — set B |
| bank11 | map-scroll and monster-confirm handler |
| bank12 | world-map tile movement engine (area type 0) |
| bank13 | dungeon tile movement engine (area type 1) |
| bank14 | town tile movement engine (area type 2) |
| bank15 | special tile movement engine (area type 3) |
| bank16 | warp/door collision stub (bank4 path A) |
| bank17 | warp/door collision stub (bank4 path B) |
| bank25 | overworld mini-map / SELECT mode |

bank4 selects the area-type engine (12–15) via `wAreaType $D8D3` and the warp
stubs (16/17); bank6 runs the per-frame world update.

**banks 12–15 share ONE engine.** Their code (`$4000-$41B9`: fn0 map-cell
lookup, fn1 tile painter, fn2 CGB-attribute painter) is byte-identical — only
the self-id at `$4000` and the map DATA past `$41BA` differ. bank12 (world) has
4 distinct map sections; 13/14/15 each carry a single area's data. The full
annotated disassembly lives in **bank12.asm**; 13/14/15 just cross-reference it.
- fn0 = READ the cell in front of the player (bank4 collision/event query)
- fn1 = PAINT scrolled-in tile indices into `$9800` (VRAM bank 0)
- fn2 = PAINT scrolled-in CGB attributes into VRAM bank 1 (via VBK `$FF4F`)

## Related, kept elsewhere
- bank1 (root): State 1 = the main-world *state controller*, but also file-select
  / monster-book — mixed, so kept in root.
- bank24 (root): scene init / hub-world setup (hub is one specific area).
- bank19 (../animation): overworld tile-scroll *animation* driver — grouped with
  animation. Move it here if you'd rather keep all overworld code together.
- Map tile graphics = ../tiles; tile loader/palette = ../pallette (bank23).
