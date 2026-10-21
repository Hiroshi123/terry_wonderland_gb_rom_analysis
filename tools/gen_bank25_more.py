# Byte-exact disassembly of bank25 phase 0 ($4364-$4425) and the cell-draw
# helper family ($447B-$44FF), as SECTIONs to append to overworld/bank25.asm.
import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=25*0x4000; data=rom[B:B+0x4000]; org=0x4000

C={
# phase 0
0x4364:'--- phase 0: INIT the mini-map ---',0x4365:'hScrollX = 0',0x436A:'hScrollY = 0',
0x4371:'scroll-setup helper (X)',0x4377:'scroll-setup helper (Y)',
0x437A:'clear $C8DA..$C8E1 (8 bytes)',
0x4385:'--- BG map row addr ($9800) from scroll -> $C909/$C90A ---',
0x43A5:'load mini-map tileset (SafeTileLoad D=bank,E=blk,HL=VRAM):',
0x43A8:'bank$28 blk$1C -> $8800',0x43B1:'bank$28 blk$1F -> $8900',
0x43BA:'bank$28 blk$1D -> $8A90',0x43C3:'bank$28 blk$1E -> $8AC0',
0x43CC:'bank$2E blk$23 -> $8B00',
0x43D2:'--- compute cursor from camera X (hFF92/93): (camX-8)/4 - $50 ---',
0x43F1:'-> hScrollX (cursor X)',
0x43F6:'--- cursor from camera Y (hFF95/96): (camY-9)/4 - $40 ---',
0x4415:'-> hScrollY (cursor Y)',
0x441A:'draw cursor / refresh',0x441D:'bankcall -> bank23 fn10',
0x4421:'advance to phase 1',0x4424:'wScrollPhase++',
# cell helpers
0x447B:'draw a horizontal tile RUN along the current row (HL=pos offset)',
0x4481:'set VRAM col base',0x448A:'advance one tile ($4458), B times',
0x4492:'draw ONE mini-map cell. IN: HL=MiniMapCellPos word, A=cell state, C=index',
0x4494:'state hi-nibble -> index row-base table',
0x449B:'row-base table $4500 (or $4520 if $C93F==2)',
0x44AA:'DE = base VRAM addr for this cell',
0x44AE:'state lo-nibble * $14 (col shift; 0 for the $F0 default)',
0x44B5:'DE = base + col shift',0x44B8:'HL = the cell pos offset again',
0x44B9:'lay the cell header row',0x44BD:'stash row ptr in $FFD5/D6',
0x44C2:'paint 3 body rows (then falls into $44CB once = 4 rows total)',
0x44CB:'paint ONE row: 5 tiles then advance to next VRAM row',
0x44E0:'row ptr += $20, wrap into $9800-$9BFF',0x44EF:'save row ptr',
0x44F5:'paint ONE tile: src|$80 -> VRAM (ROM0 $1E80), advance col ($4458)',
}

def emit(lo,hi,out):
    for a,n,mn in disasm(data,org,lo,hi):
        hx=' '.join('%02X'%data[a-org+k] for k in range(n))
        s='    %-26s ; $%04X [%s]'%(mn,a,hx)
        if a in C: s+='  ; '+C[a]
        out.append(s)

O=[]
O.append('')
O.append('; ============================================================================')
O.append('; Bank25 fn0 PHASE 0 ($4364) — INIT the mini-map.')
O.append(';   Resets scroll, loads the mini-map tileset (bank$28/$2E) into VRAM, then')
O.append(';   converts the player camera position into the on-map cursor, and steps to')
O.append(';   phase 1. (Only fn0 phase 0 + the cell-draw helpers are disassembled here;')
O.append(';   phases 2 $4074 / 3 $4249 / 4 $4443 and the $4500/$4520 tables are still TBD.)')
O.append('; ============================================================================')
O.append('SECTION "Bank25_Phase0", ROMX[$4364], BANK[25]')
O.append('Bank25_Fn0_Phase0:')
emit(0x4364,0x4426,O)
O.append('')
O.append('; ============================================================================')
O.append('; CELL-DRAW HELPERS ($447B-$44FF) — used by phase 1 to paint each zone cell.')
O.append(';   $4492 draws one 5-wide box: state byte -> base VRAM (row-base table $4500),')
O.append(';   MiniMapCellPos word -> in-grid offset, then 4 rows x5 tiles.')
O.append(';   NOTE: the exact split of "position" between the state byte and the pos word')
O.append(';   is only partially traced — treat the per-field roles as best-effort.')
O.append('; ============================================================================')
O.append('SECTION "Bank25_CellDraw", ROMX[$447B], BANK[25]')
O.append('Bank25_DrawRun:                     ; $447B')
emit(0x447B,0x4492,O)
O.append('Bank25_DrawCell:                    ; $4492')
emit(0x4492,0x44CB,O)
O.append('Bank25_DrawCellRow:                 ; $44CB  (5 tiles + advance row)')
emit(0x44CB,0x44F5,O)
O.append('Bank25_DrawTile:                    ; $44F5')
emit(0x44F5,0x4500,O)

open('/tmp/bank25_more.asm','w').write('\n'.join(O)+'\n')
print('\n'.join(O))
