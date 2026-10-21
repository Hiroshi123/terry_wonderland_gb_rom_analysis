# pallette/ — palette-specific banks

The two banks that own the GBC palette system (the ROM→WRAM→PPU pipeline we
traced). Both are technically dual-purpose but palette work dominates.

## bank8 ($20000) — palette color pool + init (ROM→WRAM half)
- `wPaletteColorTable $447E`: the archive — **256 records × 8 bytes = 4 RGB555
  colors** each (little-endian, R=bits0-4, G=5-9, B=10-14).
- `wScrollPhaseTable $427E`: 64 phases × 4 palette-record indices.
- fn1 `$41E3` / fn2 `$422C`: pick records by index and copy them into the WRAM
  palette **shadow buffer** (`$C7D7…`). Touches no hardware.
- fn0 `$4015`: SGB command-packet sender (game is SGB-compatible too).
- (Also holds raw VRAM tile/map data for SGB transfers — the non-palette part.)

## bank23 ($5C000) — CGB palette manager (WRAM→PPU half)
- fn3 `$4272`: per-frame writer — sets `rBCPS $FF68 = $80` (index0+auto-inc) then
  streams the shadow buffer to `rBCPD $FF69` (and OBJ via `$FF6A/$FF6B`), with a
  scroll/rotation animation. fn8: full 64-byte flush. fn5: fade.
- Palette RAM lives INSIDE the PPU; `$FF68/$FF69` are the only way in.
- (Also the map **tile loader** fn0/fn1/fn9 — the non-palette part.)

## Pipeline (documented in both files)
```
[ROM]  bank8 wPaletteColorTable $447E   (256 RGB555 records)
   | bank8 fn2 copies chosen records
[WRAM] shadow $C797 (BG) / $C7D7 (OBJ)
   | bank23 fn3/fn8 stream via $FF68/$FF69 in VBlank
[PPU]  internal palette RAM -> per-pixel color
```

## NOT moved (not palette-specific)
- bank6: **zero** palette code.
- bank2 (3 hits), bank1/24/95: use palettes incidentally for their own scenes,
  but their primary role is elsewhere.
