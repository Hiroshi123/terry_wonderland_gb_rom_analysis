# Rewrite bank8 data area $447E-$7FFF: small palette table (records 0-4) then the
# SceneCategoryLoad tile-data blocks (blk5-blk9). Byte-exact from ROM.
rom=open('terry.gbc','rb').read(); B=8*0x4000
def by(a): return rom[B+(a-0x4000)]

def rgb(a):  # decode 4 RGB555 colors from an 8-byte record for the comment
    out=[]
    for i in range(4):
        v=by(a+i*2)|(by(a+i*2+1)<<8)
        out.append('R%02dG%02dB%02d'%(v&0x1F,(v>>5)&0x1F,(v>>10)&0x1F))
    return ' '.join(out)

O=[]
O.append('; ============================================================')
O.append('; wPaletteColorTable  ($447E-$44A4) — the SMALL GBC RGB555 palette table.')
O.append('; fn2 reads record N as src=$447E+N*8. Only records 0-4 are real (the palette-')
O.append('; index $C817 stays low; see PaletteIndexTable). Records 0-3 = the title/boot')
O.append('; palette; record 4 is 7 bytes here because the next data (tile block 5) starts')
O.append('; at $44A5, mid-record-4. THIS TABLE ENDS AT $44A4 — $44A5 begins other data.')
O.append('; ============================================================')
O.append('wPaletteColorTable:')
# records 0-3 (full 8 bytes), then record 4 partial ($449E-$44A4 = 7 bytes)
for rec in range(4):
    a=0x447E+rec*8
    O.append('    $%04X  DB  %s  ; [%d] %s'%(a,' '.join('%02X'%by(a+i) for i in range(8)),rec,rgb(a)))
a=0x449E
O.append('    $%04X  DB  %s  ; [4] (7 bytes; block 5 starts next at $44A5)'%(a,' '.join('%02X'%by(a+i) for i in range(7))))

O.append('')
O.append('; ============================================================')
O.append('; wVramTileData  ($44A5-$7FFF) — SCENE-BACKGROUND TILE-DATA BLOCKS.')
O.append('; Reached only as bank8 $4001 block indices 5-9 (loaded by SceneCategoryLoad')
O.append('; via Fn_1511 raw / Fn_14B8 LZ into VRAM $8800). NOT palette data, NOT via')
O.append('; TilesetDirectory. blk5/6 (cat0 DUNGEON) + blk7 overlay; blk8/9 (cat1). See')
O.append('; the $4001 table at the top of this bank.')
O.append('; ============================================================')

blocks=[('Bank8_VramBlk5_DungeonA',0x44A5,0x54A5,'cat0 DUNGEON backdrop pt1 (raw 4KB)'),
        ('Bank8_VramBlk6_DungeonB',0x54A5,0x64A5,'cat0 DUNGEON backdrop pt2 (raw 4KB)'),
        ('Bank8_VramBlk7_DungeonLZ',0x64A5,0x68DD,'cat0 DUNGEON overlay (LZ)'),
        ('Bank8_VramBlk8_Cat1A',0x68DD,0x78DD,'cat1 backdrop (raw 4KB)'),
        ('Bank8_VramBlk9_Cat1LZ',0x78DD,0x8000,'cat1 backdrop (LZ, + $FF pad to end)')]
for name,lo,hi,note in blocks:
    O.append('%s:  ; $%04X-$%04X  %s'%(name,lo,hi-1,note))
    a=lo
    while a<hi:
        n=min(16,hi-a)
        O.append('    $%04X  DB  %s'%(a,' '.join('%02X'%by(a+k) for k in range(n))))
        a+=n
O.append('')
O.append('; end of bank 8')

open('/tmp/bank8_data.asm','w').write('\n'.join(O)+'\n')
print('generated %d lines; covers $447E-$7FFF'%len(O))
