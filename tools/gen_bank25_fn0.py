# Byte-exact disassembly of bank25 fn0 control core ($4003-$4073):
#   entry + phase dispatch table + phase-1 (16-cell 4x4 grid paint) + cell table.
import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=25*0x4000; data=rom[B:B+0x4000]; org=0x4000

C={
0x4003:'wScrollPhase (mini-map state 0-4)',0x4006:'dispatch via phase table below',
0x4011:'phase 1: paint the 4x4 zone grid. B=16 cells',0x4013:'C = cell index 0-15',
0x4015:'--- per-cell loop ---',0x4016:'HL = &MiniMapCellPos[C]',
0x4021:'HL = cell screen-pos word (LE)',0x4024:'wSubAreaFlag',
0x4028:'default cell state = $F0 (main-area)',0x402A:'main area -> draw with $F0',
0x402C:'DE = &wSubAreaScrollIdxArr[C] ($C950)',0x4036:'idx==0 -> still $F0',
0x403C:'DE = &$C940[C] (per-cell visited/state)',0x4046:'A = cell state byte',
0x4047:'draw this cell (HL=pos, A=state, C=index)',0x404B:'next cell',
0x404F:'all 16 drawn -> advance to phase 2',0x4052:'wScrollPhase++',
}
L={0x4011:'Bank25_Fn0_Phase1:  ; $4011  (paint 4x4 zone grid)',
   0x4015:'.cellLoop:'}

def code(lo,hi,out):
    for a,n,mn in disasm(data,org,lo,hi):
        if a in L: out.append(L[a])
        hx=' '.join('%02X'%data[a-org+k] for k in range(n))
        s='    %-26s ; $%04X [%s]'%(mn,a,hx)
        if a in C: s+='  ; '+C[a]
        out.append(s)

def words(lo,hi,out,perrow=8):
    a=lo
    while a<hi:
        n=min(perrow,(hi-a)//2)
        vals=[data[a-org+2*i]|(data[a-org+2*i+1]<<8) for i in range(n)]
        hexb=' '.join('%02X %02X'%(v&0xff,v>>8) for v in vals)
        out.append('    dw %s   ; $%04X [%s]'%(','.join('$%04X'%v for v in vals),a,hexb))
        a+=2*n

O=[]
O.append('Bank25_Fn0:                         ; $4003')
code(0x4003,0x4007,O)
O.append('    ; phase dispatch table (5 entries, indexed by wScrollPhase $C905):')
O.append('    ;   0 init · 1 paint-grid · 2 place-markers · 3 navigate · 4 exit')
words(0x4007,0x4011,O,5)
O.append('    ;   phase0 $4364 (init: zero scroll, build map) · phase2 $4074')
O.append('    ;   (place cursor/markers) · phase3 $4249 (navigate) · phase4 $4443 (exit)')
code(0x4011,0x4054,O)
O.append('; ----------------------------------------------------------------------------')
O.append('; MiniMapCellPos ($4054) — 16 screen-position words for the 4x4 zone grid,')
O.append(';   indexed by cell 0-15. High nibble of a byte = row, low nibble = column;')
O.append(';   $4492 turns one into a VRAM address. DATA. ($4064+ is a parallel variant.)')
O.append('; ----------------------------------------------------------------------------')
O.append('Bank25_MiniMapCellPos:')
words(0x4054,0x4074,O,8)

open('/tmp/bank25_fn0.asm','w').write('\n'.join(O)+'\n')
print('\n'.join(O))
