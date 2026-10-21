# animation/ — animation-specific banks

Banks whose primary role is driving on-screen animation (general, not battle-only).

| bank | role |
|---|---|
| **bank2** ($8000) | sprite / animation orchestration engine — object FSM (`$C0FC`), event queue (`$D7B4`), consumes queued anim jobs under DI when `$DD62` set; also processes cutscene scripts. The core sprite-animation engine, used by battle AND overworld/cutscenes. |
| **bank5** ($14000) | metasprite / OAM sprite composer — builds hardware sprites in the `$C000` OAM shadow from `{Yoff,Xoff,tileOff,attr}` descriptor lists (fn1 `$400F`); pointer table `$407F`, attr-flag table `$4152`. Called from bank6 (overworld). |
| **bank19** ($4C000) | overworld tile-scroll animation driver (animated map tiles). |

## Related animation banks kept elsewhere (not moved)
- **battle/** already holds the battle animation code: **bank9** (BattleAnim
  state machine), **bank92/93/94** (attack animation). Left there because they
  are battle-specific.
- **bank95** (root): "SHARED SCENE BUILD + SCROLL-ANIMATION ENGINE" — does the
  scroll animation (fn3) for the title/battle scenes, but its main job is scene
  BUILD + top-level states 4/5 (transition/dungeon). Kept in root as a scene/
  state engine; move it here if you'd rather group it as animation.

## Note
bank2 is titled "Battle sprite / animation…" but it also drives cutscene/overworld
animation, so it's a general animation engine (not battle-only) — hence here
rather than in battle/.
