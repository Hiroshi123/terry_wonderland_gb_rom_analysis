# battle/ — battle-specific banks

Banks whose primary role is the battle system (execution, menus, animation,
data). All decimal-numbered.

| bank | role |
|---|---|
| bank80 | battle orchestrator — fn2 action/scene dispatcher (top-level State 2) |
| bank81 | battle screen + turn execution (init, turn driver, action resolution) |
| bank82 | battle command / menu master dispatcher |
| bank83 | battle menu screen implementations (window/text render) |
| bank84 | SPELL / SKILL bank — spell/skill data + accessors (battle damage) |
| bank85 | battle phase (pre-battle, State 7) |
| bank87 | battle menu sub-screens / status detail |
| bank88 | battle menu input / monster stat computation |
| bank79 | battle sub (slime battle) |
| bank9  | BattleAnim — battle animation state machine (fn0 dispatch on $C8EF) |
| bank20 | battle monster management / monster-compare (bank80 calls its fn6) |
| bank92 | attack-animation sub (title says "monster management"; grouped w/ 93/94) |
| bank93 | battle sub — attack animation |
| bank94 | battle sub — attack animation |

## Deliberately NOT moved (kept in root — shared/borderline)
- **bank2** — sprite/animation engine: titled "Battle sprite / animation
  orchestration engine" but ALSO drives cutscene/overworld animation (script
  engine, event queue $D7B4). Shared, not battle-only.
- **bank95** — shared scene build + scroll engine used by BOTH the title/opening
  (bank21 State 0) and the battle intro. See memory `bank95-scene-engine`.
- **bank7** — 3-tab monster info screen; used in battle but also reachable from
  menus, so it spans contexts.

If any of these should be treated as battle-only, they can be moved too.

Related data banks NOT here: monster species DB = bank3 (root); tile/sprite
graphics = ../tiles; battle sound = ../sounds.
