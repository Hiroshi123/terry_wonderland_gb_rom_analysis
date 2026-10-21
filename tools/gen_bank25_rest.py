# Byte-exact disassembly of the REST of bank25 fn0:
#   phase2 ($4074), phase3 ($4249), $4269 helper, clear-BG $4426, phase4 ($4443),
#   VRAM helpers $4458/$4467, and the $4500/$4520 cell-graphic pointer tables.
import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=25*0x4000; data=rom[B:B+0x4000]; org=0x4000

C={
0x4074:'sub-area? ($C969) — main area skips markers, jumps to $413E',
0x407B:'scan $CA51[20] for entry $26 (the "current zone" marker id)',
0x408A:'found -> compute player icon (helper $4269) + build its OAM sprite',
0x40A8:'position icon from sub-area coords $C964-$C967 vs scroll',
0x40E4:'emit sprite (bank4 fn1)',0x40E8:'build the frame/border sprite ($4B, $A9)',
0x4103:'emit (bank4 fn1)',0x4107:'if $C950[$C960]!=0 draw the "goal" marker ($AC) via $4221',
0x413E:'draw the fixed cursor sprite (tile $08) — the highlight box',
0x4160:'X coordinate digits: $C939 -> decimal via $247C, draw 2 digit sprites',
0x41B8:'Y coordinate digits: $C93A -> decimal via $247C, draw 2 digit sprites',
0x4213:'--- INPUT WAIT: read joypad $C846, mask out Start (bit3) ---',
0x4216:'AND $F7 (ignore Start)',0x4218:'nothing pressed -> stay in phase 2',
0x421A:'any other button -> advance to phase 3 (dismiss)',0x4220:'RET',
0x4221:'helper: (DE,BC)>>2 each, store to $FFC3.. as a sprite pos (tile $AC)',
0x4249:'--- phase 3: TEARDOWN pt1 ---',0x4249+0:'clear the mini-map BG ($4426)',
0x424C:'restore saved scroll: hFFBF/C0 -> hScrollX, hFFC1/C2 -> hScrollY',
0x4264:'advance to phase 4',
0x4269:'helper (phase2): pixel distance camera($95/96,$92/93) vs $C964-$C967',
0x42B9:'-> B = marker anim/frame based on distance',
0x4426:'--- clear mini-map BG: fill $9800-$9BFF with blank tile $E0 ---',
0x4443:'--- phase 4: EXIT ---',0x4445:'hFFB6 = $FF',0x4447:'bank11 fn2 (repaint CGB attrs)',
0x444B:'ROM0 $29C0',0x444E:'clear $C8EB bit3 = leave mini-map mode',0x4453:'reset phase',
0x4458:'VRAM col-advance: L=(L&$E0)|((L+1)&$1F) (wrap within 32-tile row)',
0x4467:'VRAM row base: HL = $C909/$C90A + HL, wrapped into $9800-$9BFF',
}
L={0x4074:'Bank25_Fn0_Phase2:                  ; $4074  (display markers + input wait)',
   0x4221:'Bank25_P2_GoalMarker:               ; $4221',
   0x4249:'Bank25_Fn0_Phase3:                  ; $4249  (teardown: clear BG, restore scroll)',
   0x4269:'Bank25_P2_IconDist:                 ; $4269  (marker distance helper)',
   0x4426:'Bank25_ClearMiniMapBG:              ; $4426',
   0x4443:'Bank25_Fn0_Phase4:                  ; $4443  (exit: repaint field, RES bit3)',
   0x4458:'Bank25_VramColAdv:                  ; $4458',
   0x4467:'Bank25_VramRowBase:                 ; $4467'}

def emit(lo,hi,out):
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

O=['']
O.append('; ============================================================================')
O.append('; Bank25 fn0 PHASES 2-4 + helpers ($4074-$447A) — completes fn0.')
O.append(';   phase 2 $4074 : draw player/zone markers + coordinate digits, then WAIT for')
O.append(';                   a button (any but Start) before dismissing -> phase 3.')
O.append(';   phase 3 $4249 : teardown pt1 — clear BG, restore the saved field scroll.')
O.append(';   phase 4 $4443 : exit — repaint field attrs (bank11 fn2), RES $C8EB bit3.')
O.append('; ============================================================================')
O.append('SECTION "Bank25_Phase234", ROMX[$4074], BANK[25]')
emit(0x4074,0x4364,O)
O.append('')
O.append('SECTION "Bank25_ClearAndExit", ROMX[$4426], BANK[25]')
emit(0x4426,0x447B,O)
O.append('')
O.append('; ----------------------------------------------------------------------------')
O.append('; CellGfxPtr tables ($4500 / $4520) — 16 words each, indexed by the cell STATE')
O.append(';   byte hi-nibble (see draw-cell $4492). Each points at a tile-source block in')
O.append(';   bank25 ROM ($4540+); the STATE picks WHICH graphic, MiniMapCellPos the WHERE.')
O.append(';   $4520 is the alt set used when $C93F==2. DATA.')
O.append('; ----------------------------------------------------------------------------')
O.append('SECTION "Bank25_CellGfxPtr", ROMX[$4500], BANK[25]')
O.append('Bank25_CellGfxPtr:                  ; $4500')
words(0x4500,0x4520,O)
O.append('Bank25_CellGfxPtr_Alt:              ; $4520')
words(0x4520,0x4540,O)

open('/tmp/bank25_rest.asm','w').write('\n'.join(O)+'\n')
print('lines:',len(O)); print('\n'.join(O[:14]))
