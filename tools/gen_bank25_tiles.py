# Emit bank25 mini-map TILEMAP data ($4540-$5BE7) as labeled db blocks.
# These are the cell-graphic tilemaps pointed at by CellGfxPtr ($4500) and
# CellGfxPtr_Alt ($4520). Every block is N rows x 20 columns (tile indices,
# +$80 applied when drawn by $44F5). 20 bytes/row = one tilemap row per line.
rom=open('terry.gbc','rb').read(); B=25*0x4000
def w(a): o=B+(a-0x4000); return rom[o]|(rom[o+1]<<8)
def by(a): return rom[B+(a-0x4000)]

main=[w(0x4500+2*i) for i in range(16)]          # $4540..$547C, +$104 each
altp=[w(0x4520+2*i) for i in range(16)]
alt=[p for p in altp if p!=0x547C]               # drop the reuse-of-main entry
alt=sorted(set(alt))                              # $5580..$5BAC

def block(lo,hi,label,out):
    out.append('%s  ; $%04X-$%04X  (%d rows x 20)'%(label,lo,hi-1,(hi-lo)//20))
    a=lo
    while a<hi:
        n=min(20,hi-a)
        out.append('    db %s   ; $%04X'%(','.join('$%02X'%by(a+k) for k in range(n)),a))
        a+=n

O=[]
O.append('')
O.append('; ============================================================================')
O.append('; MINI-MAP TILEMAP DATA ($4540-$5BE7) — cell-graphic layouts (tile indices).')
O.append(';   Referenced by CellGfxPtr ($4500, 16 "main" 13x20 layouts) and')
O.append(';   CellGfxPtr_Alt ($4520, variable-height 20-wide layouts for sub-areas).')
O.append(';   draw-cell $4492 copies a cell-sized window out of the selected layout to')
O.append(';   VRAM, applying OR $80 per tile ($44F5). DATA, not code.')
O.append('; ============================================================================')
O.append('SECTION "Bank25_MiniMapTilemaps", ROMX[$4540], BANK[25]')
# main: 16 blocks of 260 bytes ($4540, +$104)
for i,p in enumerate(main):
    hi=p+0x104
    block(p,hi,'Bank25_MMTilemap_%02X:'%i,O)
# alt blocks: from each start to the next (last -> $5BE8)
bounds=alt+[0x5BE8]
for i in range(len(alt)):
    block(bounds[i],bounds[i+1],'Bank25_MMTilemapAlt_%02X:'%i,O)

open('/tmp/bank25_tiles.asm','w').write('\n'.join(O)+'\n')
# sanity: coverage $4540-$5BE7 contiguous
covered=[]
for i,p in enumerate(main): covered.append((p,p+0x104))
bd=alt+[0x5BE8]
for i in range(len(alt)): covered.append((bd[i],bd[i+1]))
covered.sort()
prev=0x4540; okc=True
for lo,hi in covered:
    if lo!=prev: okc=False; print('GAP/OVERLAP at %04X (prev %04X)'%(lo,prev))
    prev=hi
print('contiguous $4540-$%04X:'%(prev-1), 'OK' if okc and prev==0x5BE8 else 'CHECK(prev=%04X)'%prev)
print('lines:',len(O))
