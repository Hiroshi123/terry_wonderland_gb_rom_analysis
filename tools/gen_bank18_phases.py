import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=18*0x4000; data=rom[B:B+0x4000]; org=0x4000

C={
0x4463:'phase 0: BUILD backdrop',0x4466:'tile-align hScrollX',0x446C:'tile-align hScrollY',
0x446F:'clear $C8DA (8)',0x4493:'-> $C909/$C90A ($9800 BG row ptr)',
0x44A3:'SafeTileLoad bank$2E blk$10 -> VRAM $8800',
0x44C9:'window/text setup ($411A)',0x44D6:'bankcall -> bank1 fn5',0x44DA:'-> phase 1',
0x44DC:'phase 1: LOAD more tiles -> phase 2',0x44E1:'clear $C8EC',
0x44E7:'load two blocks ($70CE,$31D6) via $44EE',
0x44EE:'helper: load 2 tile blocks via $40B4 + $4323, prep $4555 table',
0x4507:'phase 2: INTERACTIVE prompt (draw options, wait for input)',
0x4512:'read joypad $C846',0x4515:'B/Start ($0A)? -> cancel: skip to phase 4',
0x4526:'A pressed? -> confirm',0x452A:'SFX $59',0x4532:'-> phase 3',
0x453A:'SET $C8DA bit7 (selection made); clear $C8DB(7)/$C8E2(8)',
0x4554:'RET',
0x4563:'phase 3: dispatch on selection $C8DA',
0x4573:'phase 4: FINALIZE + EXIT',0x4576:'reload block $31D6',
0x457F:'ROM0 $28E7',0x4588:'copy OAM stage $C13C->$C1C0 (20B)',0x4591:'$C150->$C1E0 (20B)',
0x459B:'RES $C8EB bit4 = leave battle-scene overlay',0x459E:'$C905 = 0',
0x45A2:'helper: copy 20 bytes (DE)->(HL)',
}
L={0x4463:'Bank18_P3S0_Build:                  ; $4463  (scroll phase 0)',
   0x44DC:'Bank18_P3S1_Load:                   ; $44DC  (scroll phase 1)',
   0x44EE:'Bank18_LoadTwoBlocks:               ; $44EE',
   0x4507:'Bank18_P3S2_Prompt:                 ; $4507  (scroll phase 2 = input wait)',
   0x4563:'Bank18_P3S3_Dispatch:               ; $4563  (scroll phase 3)',
   0x4573:'Bank18_P3S4_Finalize:               ; $4573  (scroll phase 4 = exit)',
   0x45A2:'Bank18_Copy20:                      ; $45A2'}

def code(lo,hi,out):
    for a,n,mn in disasm(data,org,lo,hi):
        if a in L: out.append(L[a])
        hx=' '.join('%02X'%data[a-org+k] for k in range(n))
        s='    %-26s ; $%04X [%s]'%(mn,a,hx)
        if a in C: s+='  ; '+C[a]
        out.append(s)

def words(lo,hi,out,label,note):
    out.append('%s  ; $%04X-$%04X  %s'%(label,lo,hi-1,note))
    a=lo
    while a<hi:
        v=data[a-org]|(data[a-org+1]<<8)
        out.append('    dw $%04X   ; $%04X'%(v,a)); a+=2

O=[]
O.append('')
O.append('; ============================================================================')
O.append('; Bank18 state-3 SCROLL SUB-MACHINE ($4463-$45AA) — dispatched by $4455 on')
O.append('; $C905 (wScrollPhase). An interactive battle-scene prompt: build a backdrop,')
O.append('; load tiles, WAIT for the player (A confirm / B|Start cancel), dispatch on the')
O.append('; selection $C8DA, then finalize and clear $C8EB bit4 (leave the battle overlay).')
O.append('; ============================================================================')
O.append('SECTION "Bank18 Phase3 ScrollSM", ROMX[$4463], BANK[18]')
code(0x4463,0x4555,O)
words(0x4555,0x4563,O,'Bank18_P3_OptTable:','7 option/msg-id words ($42CA index by $C8DA; $FFFF end)')
code(0x4563,0x4567,O)
words(0x4567,0x4573,O,'Bank18_P3S3_Table:','phase-3 handlers by selection $C8DA (last = phase4 $4573)')
code(0x4573,0x45AB,O)
open('/tmp/bank18_phases.asm','w').write('\n'.join(O)+'\n')
print('generated',len(O),'lines')
