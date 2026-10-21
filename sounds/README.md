# sounds/ — sound data banks

- **BGM music scores — banks 28–30** (`bank28_30_music.asm` / `bank28.asm` /
  `bank29.asm` / `bank30.asm`, hex $1C–$1E): the actual songs. Data-only banks
  (no accessor code). Each starts with a `{phase_offset, channel_ptr}` table;
  multiple records can share one melody pointer with different phase offsets →
  multi-voice **canon/round**. The channel streams are `{pitch, duration}` note
  pairs (pitch ~$14–$2B, duration ~$04–$0F) plus `$A0` attribute / `$C0` loop /
  `$FF` end commands. (Observed melodic: rising scales `14 15 17 19 1B…`.)

> **CORRECTION (banks 64–78 moved out).** These banks were previously documented
> here as "SFX / sound driver". That was WRONG — they are **dialogue text** and
> `$0568`/`$05A7`/`$05BA` are the **message/text engine**, not a sound driver
> (they write glyph tiles to VRAM via `$1E80`, never `$FF10–$FF3F`; the "`$F0`
> stream terminator" is the text newline code). They now live in **`../text`**.
>
> Consequence: the **BGM playback engine attribution above is now unverified**
> — banks 28–30 are still melodic sound DATA, but which routine consumes them
> needs re-checking. The **real SFX/driver location is currently unknown** and
> needs a fresh search (look for actual `$FF10–$FF26` register writes).

## Cross-references
- Dialogue/battle text (the ex-"sound" banks 64–78): `../text`.
- Boot/title audio triggers: `../init` (bank21, State 0).
