import sys
sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read()

HEADERS={
16:("Warp/door collision handler (bank4/fn2 path A)",
    ["; Called from: bank4/$409C via LD HL,$1000; RST $10.",
     "; fn0 $4005, fn1 $400F, fn2 $6ECD (per prior analysis).",]),
17:("Warp/door collision handler (bank4/fn2 path B)",
    ["; Shares its first ~$6B bytes of prologue with bank16, then diverges.",
     "; fn0 $4005, fn1 $400F.",]),
}
def gen(bank):
    B=bank*0x4000; data=rom[B:B+0x4000]; org=0x4000
    end=0x4000
    while end>0 and data[end-1]==0xFF: end-=1
    endaddr=0x4000+end
    ins=disasm(data,org,0x4005,endaddr)
    desc,extra=HEADERS[bank]
    o=[]; A=o.append
    A('; ============================================================================')
    A("; Dragon Quest Monsters: Terry's Wonderland (GBC)")
    A('; ROM Analysis - Bank %d  (%s)'%(bank,desc))
    A('; ============================================================================')
    A(';')
    A('; File offset $%05X-$%05X (16 KB); mapped $4000-$7FFF when bank reg = %d.'%(B,B+0x3FFF,bank))
    A(';')
    A('; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.')
    A('; Function pointer table at $4001 (2 entries): fn0=$4005, fn1=$400F.')
    for e in extra: A(e)
    A(';')
    A('; DISASSEMBLY METHOD: linear sweep from $4005. The raw bytes in each line')
    A('; comment [..] are authoritative and byte-exact vs terry.gbc; mnemonics')
    A('; describe them. NOTE embedded DATA / jump tables (if any) are decoded as')
    A('; spurious instructions by linear sweep -- trust the [hex] there, not the')
    A('; mnemonic. Operands are literal $hex: absolute addresses for JP/CALL/JR;')
    A('; LDH shows the low byte n (implied page $FF00+n).')
    A('; ============================================================================')
    A('')
    A('SECTION "Bank %d", ROMX[$4000], BANK[%d]'%(bank,bank))
    A('')
    A('    db $%02X                        ; $4000  self-id byte (bank number)'%data[0])
    fn0=data[1]|(data[2]<<8); fn1=data[3]|(data[4]<<8)
    A('    dw $%04X, $%04X               ; $4001  function pointer table (fn0, fn1)'%(fn0,fn1))
    A('')
    A('Bank%d_Fn0:                                 ; $4005'%bank)
    labels={0x4005:None,0x400F:'Bank%d_Fn1'%bank}
    for addr,ln,mn in ins:
        if addr==0x400F:
            A('')
            A('Bank%d_Fn1:                                 ; $400F'%bank)
        hexb=' '.join('%02X'%data[addr-org+k] for k in range(ln))
        A('    %-28s ; $%04X  [%s]'%(mn,addr,hexb))
    A('')
    padlen=0x8000-endaddr
    A('    ds $%04X, $FF                   ; $%04X-$7FFF padding'%(padlen,endaddr))
    txt='\n'.join(o)+'\n'
    open('overworld/bank%d.asm'%bank,'w').write(txt)

    # ---- independent byte-exact verification from the [hex] comments ----
    import re
    recon=bytearray()
    for ln in txt.split('\n'):
        m=re.search(r';\s+\$[0-9A-Fa-f]{4}\s+\[([0-9A-F ]+)\]\s*$',ln)
        if m: recon+=bytes(int(x,16) for x in m.group(1).split())
    # prepend header bytes (db + dw) that have no [hex]
    header=bytes([data[0],fn0&0xff,fn0>>8,fn1&0xff,fn1>>8])
    full=header+recon+b'\xff'*padlen
    truth=data
    ok = full==truth
    print('bank%d.asm: %d lines, code $4005-$%04X, %s'%(bank,len(o),endaddr,
          'BYTE-EXACT ✓' if ok else 'MISMATCH ✗ (%d)'%sum(1 for i in range(len(truth)) if i<len(full) and full[i]!=truth[i])))
for bk in (16,17): gen(bk)
