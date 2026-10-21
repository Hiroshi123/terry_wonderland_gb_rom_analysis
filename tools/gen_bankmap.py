import sys,re,os
rom=open('terry.gbc','rb').read()
BANKINFO={12:0x30000,13:0x34000,14:0x38000,15:0x3C000}
RANGE={14:("$20-$3F","area types $20-$3F"),15:("$40-$70","area types $40+")}

# ---- verified router (global msg id -> (text bank, local index)) ----
_C=[(66,226),(67,182),(68,172),(69,188),(70,200),(71,172),(72,158),(73,206),(74,331),(75,168),(78,175)]
_BASES=[]; _g=0
for _b,_c in _C: _BASES.append((_g,_b,_c)); _g+=_c
def route(m):
    for base,b,c in _BASES:
        if base<=m<base+c: return (b,m-base)
    return None
_TC={}
def jp(bank,local):
    if bank not in _TC:
        fn="text/bank%d.asm"%bank
        _TC[bank]=open(fn,encoding='utf-8').read().split('\n') if os.path.exists(fn) else None
    lines=_TC[bank]
    if lines is None: return None
    hdr=re.compile(r'^; Message #%d '%local)
    for i,ln in enumerate(lines):
        if hdr.match(ln):
            out=[]
            for j in range(i+1,i+14):
                mm=re.match(r'^;(   .*)$',lines[j])
                if mm: out.append(mm.group(1).strip())
                else: break
            return ' '.join(out)
    return None
def grid_textrefs(w,g0,n):
    """distinct message ids reached in grid [g0,n), in encounter order.
    Skips operands of known opcodes ($FF01/$FF15/$FF12/$FF00)."""
    OPLEN={0x01:2,0x15:3,0x12:2,0x00:2}
    a=g0; seen=[]; sset=set()
    while a<n:
        v=w(a); hi=v>>8
        if hi==0xFF:
            a+=2+OPLEN.get(v&0xff,0)*2
        else:
            if hi<=0x08 and route(v) is not None and v not in sset:
                sset.add(v); seen.append(v)
            a+=2
    return seen
def emit_textrefs(A,w,g0,n):
    refs=grid_textrefs(w,g0,n)
    if not refs: return
    A(';   text refs in this grid (message id -> text bank #local ; heuristic set):')
    for mid in refs:
        b,l=route(mid); t=jp(b,l) or "(text n/a)"
        if len(t)>52: t=t[:52]+"…"
        A(';     $%04X -> bank%d #%d : %s'%(mid,b,l,t))

def gen(bank):
    B=BANKINFO[bank]
    def w(a): o=B+(a-0x4000); return rom[o]|(rom[o+1]<<8)
    ph=w(0x41BA)
    # L1 count = until addr reaches first real section-table pointer
    t=0; minreal=0x8000
    while True:
        a=0x41BA+2*t; v=w(a)
        if a>=minreal: break
        if v!=ph and 0x41BA<v<0x8000: minreal=min(minreal,v)
        t+=1
    l1cnt=(minreal-0x41BA)//2
    L1=[(i,w(0x41BA+2*i)) for i in range(l1cnt)]
    real=[(i,p) for i,p in L1 if p!=ph]
    sr=sorted(real,key=lambda x:x[1])
    end=0x8000
    while rom[B+end-0x4000-1]==0xFF: end-=1
    bnd={}
    for k,(i,p) in enumerate(sr): bnd[i]=(p, sr[k+1][1] if k+1<len(sr) else end)
    def nsec(i):
        s,n=bnd[i]; a=s; ft=None
        while a<n:
            v=w(a)
            if ft is not None and a>=ft: break
            if s<v<n and (ft is None or v<ft): ft=v
            a+=2
            if ft is not None and a>=ft: break
        return (ft-s)//2 if ft else (n-s)//2

    o=[]; A=o.append
    fbase=B; rng,desc=RANGE[bank]
    A('; ============================================================================')
    A("; Dragon Quest Monsters: Terry's Wonderland (GBC)")
    A('; ROM Analysis - Bank %d  (Tile movement engine, %s)'%(bank,desc))
    A('; ============================================================================')
    A(';')
    A('; File offset $%05X-$%05X (16 KB); mapped $4000-$7FFF when bank reg = %d.'%(fbase,fbase+0x3FFF,bank))
    A(';')
    A('; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.')
    A('; Function table at $4001:  fn0 $4007 · fn1 $402F · fn2 $4110.')
    A(';   fn0 = READ map cell at coord (collision / event / NPC-text query)')
    A(';   fn1 = PAINT cell tile indices into $9800 BG map (scroll-fill)')
    A(';   fn2 = PAINT cell CGB attributes into VRAM bank 1 (VBK)')
    A(';')
    A('; SHARED ENGINE: code $4007-$41B9 is BYTE-FOR-BYTE identical to bank12/13/15')
    A('; (only the self-id byte at $4000 differs: $%02X here). Full annotation below;'%bank)
    A('; see overworld/bank12.asm for the same routines under area type 0.')
    A(';')
    A('; DATA (this bank) = %d area types (%s). bank4/Sub_71EF ($71EF) routes those'%(len(real),rng))
    A('; wAreaType ($D8D3) values here (LD HL,$%02X00; RST $10). The $41BA L1 table is'%bank)
    A('; indexed by the FULL wAreaType: out-of-range rows alias placeholder grid')
    A('; $%04X; the %d real rows are %s.'%(ph,len(real),rng))
    A(';')
    A('; TEXT REFERENCES: a cell value with high byte != $FF is a GLOBAL MESSAGE ID,')
    A('; routed by ROM0 MsgBankRouter ($0EC5) to dialogue banks 66-78 (local msg =')
    A('; global_id - bank_base; bank66 base $0000, 67 $00E2, 68 $0198, 69 $0244,')
    A('; 70 $0300, 71 $03C8, 72 $0474, 73 $0512, 74 $05E0, 75 $072B, 78 $07D3).')
    A('; $FFxx cells = behavior opcodes (lo -> bank4 TileBehaviorTable $5620):')
    A(';   $FF01 <flag> <ptr>       : IF event-flag SET -> branch to <ptr> else next')
    A(';   $FF15 <addr> <val> <ptr> : IF WRAM[addr]==val -> <ptr> (Yes/No via $C83C)')
    A('; See overworld/bank13.asm for decoded worked examples of these grids.')
    A('; ============================================================================')
    A('')
    A('SECTION "Bank %d Functions", ROMX[$4000], BANK[%d]'%(bank,bank))
    A('')
    A('    db $%02X                        ; $4000  self-id byte (bank number)'%bank)
    A('    dw $4007, $402F, $4110        ; $4001  function pointer table (fn0/fn1/fn2)')
    A('')
    A('; ------------------------------------------------------------')
    A('; Bank%d_Fn0/Fn1/Fn2 — shared map engine (identical to bank12 code)'%bank)
    A('; ------------------------------------------------------------')
    b12=open('overworld/bank12.asm').read().split('\n')
    o.extend(ln.replace('Bank12_','Bank%d_'%bank) for ln in b12[75:417])
    A('')
    A('')
    A('SECTION "Bank %d Map Data", ROMX[$41BA], BANK[%d]'%(bank,bank))
    A('; ============================================================================')
    A('; MAP DATA — 3-level table: L1 wAreaType -> L2 section -> cell grid[coord].')
    A('; ============================================================================')
    A('Bank%d_AreaTypeTable:                       ; $41BA  (L1: wAreaType -> section table, %d rows)'%(bank,l1cnt))
    for b0 in range(0,l1cnt,6):
        grp=[w(0x41BA+2*i) for i in range(b0,min(b0+6,l1cnt))]
        A('    dw %-42s ; areaType $%02X-$%02X'%(','.join('$%04X'%v for v in grp),b0,min(b0+5,l1cnt-1)))
    A('                                             ;   (out-of-range rows = $%04X placeholder)'%ph)
    A('')
    # group area types sharing a section-table pointer; emit each unique block
    # once in ascending address order (banks may alias several types to one table)
    from collections import defaultdict
    bytype=defaultdict(list)
    for i,p in real: bytype[p].append(i)
    uniq=sorted(bytype)
    ubnd={}
    for k,p in enumerate(uniq):
        ubnd[p]=(p, uniq[k+1] if k+1<len(uniq) else end)
    def unsec(p):
        s,n=ubnd[p]; a=s; ft=None
        while a<n:
            v=w(a)
            if ft is not None and a>=ft: break
            if s<v<n and (ft is None or v<ft): ft=v
            a+=2
            if ft is not None and a>=ft: break
        return (ft-s)//2 if ft else (n-s)//2
    for p in uniq:
        types=bytype[p]; i=types[0]
        s,n=ubnd[p]; ns=unsec(p); g0=s+ns*2
        alias=('  (also area types %s)'%', '.join('$%02X'%x for x in types[1:])) if len(types)>1 else ''
        A('Bank%d_Area%02X_Sections:                     ; $%04X  areaType $%02X%s  (%d section%s)'%(bank,i,s,i,alias,ns,'' if ns==1 else 's'))
        for k in range(0,ns,8):
            grp=[w(s+2*j) for j in range(k,min(k+8,ns))]
            A('    dw %s   ; section $%02X+'%(','.join('$%04X'%v for v in grp),k))
        glen=n-g0
        if glen>0:
            A('Bank%d_Area%02X_Grids:                        ; $%04X-$%04X  (%d bytes)'%(bank,i,g0,n,glen))
            A('    INCBIN "terry.gbc", $%06X, $%04X'%(fbase+(g0-0x4000),glen))
            emit_textrefs(A,w,g0,n)
        A('')
    A('    ds $%04X, $FF                   ; $%04X-$7FFF padding'%(0x8000-end,end))
    open('overworld/bank%d.asm'%bank,'w',encoding='utf-8').write('\n'.join(o)+'\n')
    print('bank%d.asm: %d lines, %d real area types, placeholder $%04X, data ends $%04X'%(bank,len(o),len(real),ph,end))

for bk in (14,15): gen(bk)
