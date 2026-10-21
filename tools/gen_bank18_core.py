import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=18*0x4000; data=rom[B:B+0x4000]; org=0x4000

C={
0x4003:'wAnimPhase (bank9 BattleAnim outer state $C8EF)',
0x4006:'dispatch on phase via the 16-entry table below',
0x4027:'shared RET stub (inactive phases)',
0x4028:'--- Sub_4028: advance a 16-bit scroll value +4, then snap to 8px ---',
0x4029:'+= 4',0x4031:'clear low 3 bits (tile-align)',
0x4035:'--- Sub_4035: VRAM col advance: L=(L&$E0)|((L+1)&$1F) (wrap in 32-tile row) ---',
0x4044:'--- Sub_4044: VRAM row base = $C909/$C90A + HL, wrapped into $9800-$9BFF ---',
0x4058:'--- Sub_4058: HL += $C500 (WRAM staging-buffer base) ---',
0x4455:'wScrollPhase — nested scroll sub-machine (battle-anim phase 3)',
0x4458:'dispatch on wScrollPhase via the table below',
}
L={0x4003:'Bank18_Fn0:                         ; $4003  (battle-anim phase dispatcher)',
   0x4027:'Bank18_RetStub:                     ; $4027',
   0x4028:'Bank18_ScrollStep:                  ; $4028',
   0x4035:'Bank18_VramColAdv:                  ; $4035',
   0x4044:'Bank18_VramRowBase:                 ; $4044',
   0x4058:'Bank18_BufBase:                     ; $4058',
   0x4455:'Bank18_Phase3_ScrollDriver:         ; $4455  ($C8EF state 3)'}

def code(lo,hi,out):
    for a,n,mn in disasm(data,org,lo,hi):
        if a in L: out.append(L[a])
        hx=' '.join('%02X'%data[a-org+k] for k in range(n))
        s='    %-26s ; $%04X [%s]'%(mn,a,hx)
        if a in C: s+='  ; '+C[a]
        out.append(s)

def words(lo,hi,out,names=None):
    a=lo; i=0
    while a<hi:
        v=data[a-org]|(data[a-org+1]<<8)
        cmt=names(i) if names else ''
        out.append('    dw $%04X   ; $%04X  %s'%(v,a,cmt)); a+=2; i+=1

O=[]
O.append('; ============================================================================')
O.append('; Bank 18 ($12) — BATTLE-EFFECT ANIMATOR (bank9 BattleAnim delegate)')
O.append('; ============================================================================')
O.append(';   File offset $48000-$4BFFF (16 KB), mapped $4000-$7FFF.')
O.append(';')
O.append('; ONLY fn0 ($4003) is a real entry, and its ONLY caller is bank9 (battle) at')
O.append('; $402E (BattleAnim_BnkCallB, for $C8EF phases 3/8/9/10). So this bank is a')
O.append('; battle-scene effect animator, NOT an overworld area controller.')
O.append(';   (The old "fn1 $EFFA / fn2 $C7C8 / fn3-fn7" table entries were a MISREAD:')
O.append(';    $EFFA/$C7C8 are just fn0 code bytes, and the "fn3-fn7" slots are actually')
O.append(';    fn0 RST$00 STATE table entries at $4007 — bank18 exposes only fn0.)')
O.append(';')
O.append('; fn0: LD A,($C8EF); RST$00 -> 16-entry state table at $4007. Active states:')
O.append(';   3  -> $4455  scroll sub-machine on $C905 (wScrollPhase)  [see below]')
O.append(';   8  -> $6079  battle-scroll phase A      (not yet disassembled)')
O.append(';   9  -> $6851  battle-scroll phase B      (not yet disassembled)')
O.append(';   10 -> $6B0D  transition / connect       (not yet disassembled)')
O.append(';   all others -> $4027 (RET).')
O.append(';')
O.append('; $C905 = wScrollPhase. State 3 ($4455) runs the SAME scroll/BG-build engine')
O.append('; as bank19 fn3 and bank25 phase0: Sub_4028 tile-aligns hScrollX/Y ($FFB7/$FFBB),')
O.append('; builds a $9800 BG row (via $C909/$C90A), and SafeTileLoads a tileset. Its 6')
O.append('; scroll phases dispatch through the $4459 table (phase0 $4463 = init/build).')
O.append(';')
O.append('; Bytes $4003-$4062 (control core) + the $4455 dispatcher are byte-exact below;')
O.append('; the phase handlers ($4463+, $6079/$6851/$6B0D) and lower message routines are')
O.append('; only partially covered. wram: $C8EF wAnimPhase, $C905 wScrollPhase,')
O.append('; $C8DA scroll-state array, $C909/$C90A BG row ptr, $FFB7/$FFBB hScrollX/Y.')
O.append('; ============================================================================')
O.append('SECTION "Bank18 Core", ROMX[$4003], BANK[18]')
code(0x4003,0x4007,O)
O.append('    ; RST$00 state table (16 entries, indexed by $C8EF):')
def stn(i):
    m={3:'-> $4455 scroll driver',8:'-> $6079 scroll A',9:'-> $6851 scroll B',10:'-> $6B0D connect'}
    return 'state %d %s'%(i,m.get(i,'(RET stub $4027)'))
words(0x4007,0x4027,O,stn)
code(0x4027,0x4061,O)
O.append('')
O.append('; ----- state-3 handler: scroll sub-machine keyed on $C905 (wScrollPhase) -----')
code(0x4455,0x4459,O)
O.append('    ; $4459 scroll-phase table (phase 0 builds the scene; 3/4 finalize):')
def spn(i):
    return 'scrollphase %d'%i
words(0x4459,0x4463,O,spn)
O.append('    ; phase-0 handler $4463 (init/build) and phases 1-4 not disassembled here.')
open('/tmp/bank18_core.asm','w').write('\n'.join(O)+'\n')
print('generated',len(O),'lines')
