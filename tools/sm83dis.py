# Minimal, complete SM83 (LR35902) linear-sweep disassembler.
# Emits project-style lines: "    MNEMONIC              ; $ADDR  [HEX]".
# Operands are literal $hex (matches existing bank stubs; byte-faithful).

R=['B','C','D','E','H','L','(HL)','A']
def build_main():
    T={}
    def s(op,mn,ln): T[op]=(mn,ln)
    s(0x00,'NOP',1); s(0x01,'LD BC,${d16}',3); s(0x02,'LD (BC),A',1); s(0x03,'INC BC',1)
    s(0x04,'INC B',1); s(0x05,'DEC B',1); s(0x06,'LD B,${d8}',2); s(0x07,'RLCA',1)
    s(0x08,'LD (${a16}),SP',3); s(0x09,'ADD HL,BC',1); s(0x0A,'LD A,(BC)',1); s(0x0B,'DEC BC',1)
    s(0x0C,'INC C',1); s(0x0D,'DEC C',1); s(0x0E,'LD C,${d8}',2); s(0x0F,'RRCA',1)
    s(0x10,'STOP',2); s(0x11,'LD DE,${d16}',3); s(0x12,'LD (DE),A',1); s(0x13,'INC DE',1)
    s(0x14,'INC D',1); s(0x15,'DEC D',1); s(0x16,'LD D,${d8}',2); s(0x17,'RLA',1)
    s(0x18,'JR ${r8}',2); s(0x19,'ADD HL,DE',1); s(0x1A,'LD A,(DE)',1); s(0x1B,'DEC DE',1)
    s(0x1C,'INC E',1); s(0x1D,'DEC E',1); s(0x1E,'LD E,${d8}',2); s(0x1F,'RRA',1)
    s(0x20,'JR NZ,${r8}',2); s(0x21,'LD HL,${d16}',3); s(0x22,'LD (HL+),A',1); s(0x23,'INC HL',1)
    s(0x24,'INC H',1); s(0x25,'DEC H',1); s(0x26,'LD H,${d8}',2); s(0x27,'DAA',1)
    s(0x28,'JR Z,${r8}',2); s(0x29,'ADD HL,HL',1); s(0x2A,'LD A,(HL+)',1); s(0x2B,'DEC HL',1)
    s(0x2C,'INC L',1); s(0x2D,'DEC L',1); s(0x2E,'LD L,${d8}',2); s(0x2F,'CPL',1)
    s(0x30,'JR NC,${r8}',2); s(0x31,'LD SP,${d16}',3); s(0x32,'LD (HL-),A',1); s(0x33,'INC SP',1)
    s(0x34,'INC (HL)',1); s(0x35,'DEC (HL)',1); s(0x36,'LD (HL),${d8}',2); s(0x37,'SCF',1)
    s(0x38,'JR C,${r8}',2); s(0x39,'ADD HL,SP',1); s(0x3A,'LD A,(HL-)',1); s(0x3B,'DEC SP',1)
    s(0x3C,'INC A',1); s(0x3D,'DEC A',1); s(0x3E,'LD A,${d8}',2); s(0x3F,'CCF',1)
    for op in range(0x40,0x80):
        if op==0x76: s(op,'HALT',1); continue
        s(op,'LD %s,%s'%(R[(op>>3)&7],R[op&7]),1)
    alu=['ADD A,','ADC A,','SUB ','SBC A,','AND ','XOR ','OR ','CP ']
    for op in range(0x80,0xC0):
        s(op,alu[(op>>3)&7]+R[op&7],1)
    s(0xC0,'RET NZ',1); s(0xC1,'POP BC',1); s(0xC2,'JP NZ,${a16}',3); s(0xC3,'JP ${a16}',3)
    s(0xC4,'CALL NZ,${a16}',3); s(0xC5,'PUSH BC',1); s(0xC6,'ADD A,${d8}',2); s(0xC7,'RST $00',1)
    s(0xC8,'RET Z',1); s(0xC9,'RET',1); s(0xCA,'JP Z,${a16}',3); s(0xCC,'CALL Z,${a16}',3)
    s(0xCD,'CALL ${a16}',3); s(0xCE,'ADC A,${d8}',2); s(0xCF,'RST $08',1)
    s(0xD0,'RET NC',1); s(0xD1,'POP DE',1); s(0xD2,'JP NC,${a16}',3); s(0xD4,'CALL NC,${a16}',3)
    s(0xD5,'PUSH DE',1); s(0xD6,'SUB ${d8}',2); s(0xD7,'RST $10',1); s(0xD8,'RET C',1)
    s(0xD9,'RETI',1); s(0xDA,'JP C,${a16}',3); s(0xDC,'CALL C,${a16}',3); s(0xDE,'SBC A,${d8}',2)
    s(0xDF,'RST $18',1)
    s(0xE0,'LDH (${a8}),A',2); s(0xE1,'POP HL',1); s(0xE2,'LD (C),A',1); s(0xE5,'PUSH HL',1)
    s(0xE6,'AND ${d8}',2); s(0xE7,'RST $20',1); s(0xE8,'ADD SP,${r8s}',2); s(0xE9,'JP (HL)',1)
    s(0xEA,'LD (${a16}),A',3); s(0xEE,'XOR ${d8}',2); s(0xEF,'RST $28',1)
    s(0xF0,'LDH A,(${a8})',2); s(0xF1,'POP AF',1); s(0xF2,'LD A,(C)',1); s(0xF3,'DI',1)
    s(0xF5,'PUSH AF',1); s(0xF6,'OR ${d8}',2); s(0xF7,'RST $30',1); s(0xF8,'LD HL,SP+${r8s}',2)
    s(0xF9,'LD SP,HL',1); s(0xFA,'LD A,(${a16})',3); s(0xFB,'EI',1); s(0xFE,'CP ${d8}',2); s(0xFF,'RST $38',1)
    return T
MAIN=build_main()
INVALID={0xD3,0xDB,0xDD,0xE3,0xE4,0xEB,0xEC,0xED,0xF4,0xFC,0xFD}
CBOPS=['RLC','RRC','RL','RR','SLA','SRA','SWAP','SRL']
def cb(b):
    hi=b>>6; idx=(b>>3)&7; r=R[b&7]
    if hi==0: return '%s %s'%(CBOPS[idx],r)
    if hi==1: return 'BIT %d,%s'%(idx,r)
    if hi==2: return 'RES %d,%s'%(idx,r)
    return 'SET %d,%s'%(idx,r)

def disasm(data, org, start, end):
    """data: full bank bytes (0x4000). yields (addr, nbytes, text). [start,end) mapped addrs."""
    a=start
    out=[]
    while a<end:
        off=a-org; op=data[off]
        if op==0xCB:
            b=data[off+1]; out.append((a,2,cb(b))); a+=2; continue
        if op in INVALID:
            out.append((a,1,'db $%02X'%op)); a+=1; continue
        mn,ln=MAIN[op]
        if a+ln>end:  # truncated tail -> emit as db
            out.append((a,1,'db $%02X'%op)); a+=1; continue
        if '{d8}' in mn:  mn=mn.replace('${d8}','$%02X'%data[off+1])
        if '{a8}' in mn:  mn=mn.replace('${a8}','$%02X'%data[off+1])  # LDH low byte (existing style)
        if '{d16}' in mn: mn=mn.replace('${d16}','$%04X'%(data[off+1]|(data[off+2]<<8)))
        if '{a16}' in mn: mn=mn.replace('${a16}','$%04X'%(data[off+1]|(data[off+2]<<8)))
        if '{r8}' in mn:
            rel=data[off+1]; rel=rel-256 if rel>127 else rel; tgt=(a+2+rel)&0xFFFF
            mn=mn.replace('${r8}','$%04X'%tgt)
        if '{r8s}' in mn:
            rel=data[off+1]; sr='+$%02X'%rel if rel<128 else '-$%02X'%(256-rel)
            mn=mn.replace('${r8s}',sr)
        out.append((a,ln,mn)); a+=ln
    return out

if __name__=='__main__':
    import sys
    rom=open('terry.gbc','rb').read()
    bank=int(sys.argv[1]); B=bank*0x4000; data=rom[B:B+0x4000]; org=0x4000
    # content end (strip trailing $FF)
    end=0x4000
    while end>0 and data[end-1]==0xFF: end-=1
    endaddr=0x4000+end
    ins=disasm(data,org,0x4005,endaddr)
    # coverage check
    cov=0
    for _,n,_ in ins: cov+=n
    assert 0x4005+cov==endaddr, (hex(0x4005+cov),hex(endaddr))
    print("bank%d: code $4005-$%04X (%d instrs, %d bytes), pad $%04X-$7FFF"%(bank,endaddr,len(ins),cov,endaddr))
