# monsters/ — monster data & management banks

The three banks covering monster species, management, and display.

| bank | role |
|---|---|
| **bank3** | **Monster Species Database** — 221 records × $2B bytes at `$4461` (family, maxLevel, expType, gender/flight/metal, 3 native skills, 6 stats, spell/status/breath resistances, rank). The per-species template. |
| **bank22** | **Monster storage + breeding** — team/box slot manager (`$CAC1`, 20 slots); the breeding system: `Bank22_SpecialBreed $4974` (canonical per-child recipes), `Bank22_BreedTable $4B30` (825 general recipes {p1,p2,req+,child,bonus+}), `Bank22_Fn3_BreedDriver $45A3` + `Bank22_BreedMatch $46C6`. |
| **bank7** | **Monster info screen** — 3-tab viewer (Stats / Skills / Profile) at VRAM `$8500/$8600/$8700`; composes the monster picture from the sprite table `Bank7_SpriteTable $6CC2` -> banks `$38-$3A`. |

## Cross-references
- Species ids index bank3's DB; sprite graphics = `../tiles` (banks 35-63);
  battle uses = `../battle`; breeding formula memory = `breeding-table`.

## Dual-purpose notes (banks aren't 100% monster-only)
- **bank3** also holds the LINK-CABLE trade/exchange handler (fn2-fn8, `$6980`+)
  — monster trading, but it's where the serial-swap logic lives.
- **bank22** also has an AREA SCROLL boundary handler (fn8/fn9, `$6F05`/`$7033`)
  for the overworld — unrelated to monsters, but shares the bank.
