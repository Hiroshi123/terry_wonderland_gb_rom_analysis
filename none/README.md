# none/ — empty / unused ROM banks

These bank `.asm` files correspond to ROM banks that are **100% `$FF` filler**
(1–2 distinct byte values across the whole 16 KB) — i.e. **unused/blank**. They
contain no code and no data; the stub `.asm` files are kept only for
completeness. Detected via a per-bank fill test (most-common byte > 98.5%,
≤ 4 distinct values); every bank here was exactly 100% `$FF`.

Banks (decimal — hex):
- 26–27  ($1A–$1B)
- 31–34  ($1F–$22)
- 86     ($56)          — isolated blank between code banks 85 and 87
- 96–127 ($60–$7F)      — the entire unused upper block of the 2 MB ROM

Total: 39 banks. Nothing to analyze here.
