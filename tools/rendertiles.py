#!/usr/bin/env python3
# Decompress + render terry.gbc tile blocks (TileLoad $18A2 / SafeTileLoad $194A
# LZ format).  See rom0_vblank_callees.asm : TileLoad for the format doc.
#
# Usage:
#   rendertiles.py <bank> [block] [--rom PATH] [--scale N] [--per N] [--ascii]
#                                  [--palette NAME|hex,hex,hex,hex]
#     <bank>   ROM bank holding the tiles, hex ($2E) or decimal (46)
#     [block]  block index; omit to render EVERY block in the bank
#     --palette  gray (default) | dmg | custom "RRGGBB,RRGGBB,RRGGBB,RRGGBB"
#   Examples:
#     rendertiles.py 0x2E 0                 # one block -> PNG + ASCII
#     rendertiles.py 46                      # whole bank -> one stacked PNG
#     rendertiles.py 0x5B 0 --scale 8
#     rendertiles.py 0x38 --palette dmg      # colorized monster sprites
#
# Output PNG: bank<BB>_block<NN>.png  or  bank<BB>_all.png
# NOTE: only banks loaded by TileLoad $18A2 / SafeTileLoad $194A use this LZ
# format (e.g. $2E,$2F,$3F,$5B and monster-sprite banks $38-$3A). Banks loaded
# by other routines (e.g. the $0D7C/$08B9 VRAM pattern-fill) do NOT apply.
import sys, zlib, struct, argparse

def load(path): return open(path, "rb").read()

def decompress(data, bank, blk, base=0x8000):
    """Decode block `blk` of `bank`. Faithful port of the ROM0 loader
    TileLoad_Inner ($18B4-$1949): LZ where the dictionary is the VRAM output
    buffer. The back-reference wrap subtracts $10 from the address HIGH byte
    (=-$1000) with base/end bounds checks and a zero-fill below base -- NOT a
    naive offset wrap. `base` is the VRAM dest (its low byte affects wrapping;
    real loads are usually $xx00-aligned, so $8000 matches)."""
    bf = bank * 0x4000
    tp = bf + 1 + blk * 2
    ptr = data[tp] | (data[tp + 1] << 8)          # $40xx address in-bank
    off = bf + (ptr - 0x4000)
    count = data[off] | (data[off + 1] << 8)
    esc = data[off + 2]
    p = off + 3
    end = (base + count) & 0xFFFF
    bH, bL = base >> 8, base & 0xFF
    eH, eL = end >> 8, end & 0xFF
    V = {}
    hl = base; bc = count
    while bc > 0:
        a = data[p]; p += 1
        if a != esc:                              # literal
            V[hl] = a; hl = (hl + 1) & 0xFFFF; bc -= 1; continue
        rs = data[p]; p += 1; pd = data[p]; p += 1
        rc = (pd & 0x0F) + 4
        if rc == 0x13:
            rc = (data[p] + 0x13) & 0xFF; p += 1
        col = pd >> 4; saved = p
        src = (base + (col << 8) + rs) & 0xFFFF    # abs source addr
        while True:
            dH = (src >> 8) & 0xFF; eLo = src & 0xFF; zero = False
            while True:                            # range check ($18FE-$1928)
                if eH == dH:      adv = (eL <= eLo)   # end_lo==lo or end_lo<lo
                elif eH < dH:     adv = True
                else:             adv = False
                if not adv: break
                dH = (dH - 0x10) & 0xFF            # advance_row: hi -= $10
                if bH == dH:
                    if bL <= eLo: break            # base_lo<=lo -> write
                    dH = (dH + 0x10) & 0xFF; zero = True; break
                elif bH > dH:
                    dH = (dH + 0x10) & 0xFF; zero = True; break
                else: break                        # base_hi<hi -> write
            src = ((dH << 8) | eLo) & 0xFFFF
            V[hl] = 0 if zero else V.get(src, 0)
            hl = (hl + 1) & 0xFFFF; src = (src + 1) & 0xFFFF; bc -= 1
            if bc == 0: break
            rc -= 1
            if rc != 0: continue                   # next byte, same run
            p = saved; break                       # run done -> resume stream
    return bytearray(V.get((base + i) & 0xFFFF, 0) for i in range(count))

def num_blocks(data, bank):
    """Heuristic: pointer table runs until the first block address."""
    bf = bank * 0x4000
    first = data[bf + 1] | (data[bf + 2] << 8)
    return (first - 0x4001) // 2

def tile_pixels(buf, t):
    rows = []
    for r in range(8):
        lo = buf[t*16 + r*2]; hi = buf[t*16 + r*2 + 1]
        rows.append([((hi >> (7-x)) & 1) << 1 | ((lo >> (7-x)) & 1) for x in range(8)])
    return rows

def write_png(path, img, W, H):
    # img: list of rows, each row = list of (r,g,b) tuples -> RGB PNG (type 2)
    raw = bytearray()
    for row in img:
        raw.append(0)
        for px in row:
            raw.extend(px)
    def chunk(t, d):
        c = t + d
        return struct.pack(">I", len(d)) + c + struct.pack(">I", zlib.crc32(c) & 0xffffffff)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    open(path, "wb").write(png)

SHADE = [' ', '░', '▒', '█']
PALETTES = {
    "gray": [(240,240,240),(160,160,160),(80,80,80),(0,0,0)],
    "dmg":  [(224,248,208),(136,192,112),(52,104,86),(8,24,32)],   # GB green
}
def parse_palette(s):
    if s in PALETTES: return PALETTES[s]
    parts = s.split(",")
    if len(parts) == 4:
        return [tuple(int(p[i:i+2],16) for i in (0,2,4)) for p in parts]
    raise SystemExit(f"bad --palette: {s}")

def blit(img, buf, x0, y0, per, scale, pal):
    for t in range(len(buf)//16):
        tx, ty = t % per, t // per
        px0 = x0 + tx*8*scale; py0 = y0 + ty*8*scale
        for r, prow in enumerate(tile_pixels(buf, t)):
            for c, v in enumerate(prow):
                col = pal[v]
                for dy in range(scale):
                    row = img[py0 + r*scale + dy]
                    for dx in range(scale):
                        row[px0 + c*scale + dx] = col

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bank", nargs="?"); ap.add_argument("block", nargs="?")
    ap.add_argument("--detect", action="store_true",
                    help="scan all banks and report which are real tile-data banks")
    ap.add_argument("--rom", default="terry.gbc")
    ap.add_argument("--scale", type=int, default=6)
    ap.add_argument("--per", type=int, default=16)
    ap.add_argument("--ascii", action="store_true")
    ap.add_argument("--palette", default="gray")
    a = ap.parse_args()
    data = load(a.rom)

    if a.detect:
        # A real tile-data bank has a $4001 block table where EVERY block header
        # count is a multiple of 16 (tiles=16 bytes). Code banks share the
        # self-ID+$4001 shape (RST-$10 function table) but fail this test.
        print(" dec  hex  blocks  count%16   verdict")
        for bk in range(len(data)//0x4000):
            bf = bk*0x4000
            if data[bf] != (bk & 0xFF): continue
            first = data[bf+1] | (data[bf+2] << 8)
            if not (0x4001 < first < 0x8000): continue
            nb = (first-0x4001)//2
            if nb < 2: continue
            good = tot = 0
            for i in range(nb):
                p = data[bf+1+i*2] | (data[bf+2+i*2] << 8)
                if not (0x4000 <= p < 0x8000): continue
                off = bf+(p-0x4000)
                if off+3 > len(data): continue
                cnt = data[off] | (data[off+1] << 8); tot += 1
                if cnt % 16 == 0 and 0 < cnt <= 0x1800: good += 1
            frac = good/tot if tot else 0
            v = "TILE DATA" if frac > 0.8 else ("code" if frac < 0.3 else "mixed?")
            print(f" {bk:3d}  ${bk:02X}   {nb:4d}    {frac*100:5.1f}%   {v}")
        return

    if a.bank is None:
        ap.error("bank required (or use --detect)")
    bank = int(a.bank, 0)
    per, scale = a.per, a.scale
    pal = parse_palette(a.palette)
    bg = (210,210,210)

    if a.block is not None:                       # single block
        blk = int(a.block, 0)
        buf = decompress(data, bank, blk)
        nt = len(buf)//16
        rows = (nt + per - 1)//per
        W, H = per*8*scale, rows*8*scale
        img = [[bg]*W for _ in range(H)]
        blit(img, buf, 0, 0, per, scale, pal)
        out = f"bank{bank}_block{blk}.png"          # DECIMAL bank# (matches .asm)
        write_png(out, img, W, H)
        print(f"{out}: bank {bank} (=${bank:02X}) block {blk}, {nt} tiles ({W}x{H})")
        if a.ascii:
            for t in range(nt):
                print(f"tile {t}:")
                for prow in tile_pixels(buf, t):
                    print("  " + "".join(SHADE[p]*2 for p in prow))
        return

    # whole bank: stack every block
    nb = num_blocks(data, bank)
    sheets = []
    for blk in range(nb):
        try:
            buf = decompress(data, bank, blk)
        except Exception:
            continue
        nt = len(buf)//16
        if nt == 0: continue
        rows = (nt + per - 1)//per
        sheets.append((blk, buf, rows))
    gap = 4
    W = per*8*scale
    H = sum(r*8*scale + gap for _, _, r in sheets) + gap
    img = [[bg]*W for _ in range(H)]
    y = gap
    for blk, buf, rows in sheets:
        blit(img, buf, 0, y, per, scale, pal)
        y += rows*8*scale + gap
    out = f"bank{bank}_all.png"                     # DECIMAL bank# (matches .asm)
    write_png(out, img, W, H)
    print(f"{out}: bank {bank} (=${bank:02X}), {len(sheets)} blocks ({W}x{H})")

if __name__ == "__main__":
    main()
