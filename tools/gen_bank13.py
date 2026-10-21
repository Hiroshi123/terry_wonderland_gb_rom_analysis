import re,os
rom=open('terry.gbc','rb').read(); B=0x34000
def w(a): o=B+(a-0x4000); return rom[o]|(rom[o+1]<<8)

# ---- text routing + JP extraction ----
counts=[(66,226),(67,182),(68,172),(69,188),(70,200),(71,172),(72,158),(73,206),(74,331),(75,168),(78,175)]
bases=[]; g=0
for b,c in counts: bases.append((g,b,c)); g+=c
END=g
def route(m):
    for base,b,c in bases:
        if base<=m<base+c: return (b,m-base)
    return None
_cache={}
def jp(bank,local):
    if bank not in _cache:
        fn=f"text/bank{bank}.asm"
        _cache[bank]=open(fn,encoding='utf-8').read().split('\n') if os.path.exists(fn) else None
    lines=_cache[bank]
    if lines is None: return None
    hdr=re.compile(r'^; Message #%d '%local)
    for i,ln in enumerate(lines):
        if hdr.match(ln):
            out=[]
            for j in range(i+1,i+14):
                m=re.match(r'^;(   .*)$',lines[j])
                if m: out.append(m.group(1).strip())
                else: break
            return ' '.join(out)
    return None
def msgcmt(v):
    r=route(v)
    if not r: return "message id (unrouted)"
    b,l=r; t=jp(b,l)
    if t is None: return f"msg -> bank{b} #{l}"
    if len(t)>60: t=t[:60]+"…"
    return f"msg -> bank{b} #{l}: {t}"

# ---- grid layout ----
L1=[(t,w(0x41BA+2*t)) for t in range(0x20)]
real=[(t,p) for t,p in L1 if p!=0x7C3E]
sr=sorted(real,key=lambda x:x[1]); end=0x8000
while rom[B+end-0x4000-1]==0xFF: end-=1
bnd={}
for i,(t,p) in enumerate(sr): bnd[t]=(p, sr[i+1][1] if i+1<len(sr) else end)
def nsec(t):
    s,n=bnd[t]; a=s; ft=None
    while a<n:
        v=w(a)
        if ft is not None and a>=ft: break
        if s<v<n and (ft is None or v<ft): ft=v
        a+=2
        if ft is not None and a>=ft: break
    return (ft-s)//2 if ft else (n-s)//2

# ---- inline decoder for a byte range [lo,hi) : emit annotated dw lines ----
def decode_range(lo,hi):
    outl=[]; a=lo
    while a<hi:
        v=w(a); hi8=v>>8; c=""
        if v==0xFFFF: c="end / walkable"
        elif hi8==0xFF:
            op=v&0xff
            if op==0x01:
                fl=w(a+2); pt=w(a+4)
                outl.append(f"    dw $FF01,${fl:04X},${pt:04X}   ; ${a:04X}  IF flag ${fl:X} SET -> branch $${pt:04X} (else next)")
                a+=6; continue
            elif op==0x15:
                ad=w(a+2); cv=w(a+4); pt=w(a+6)
                outl.append(f"    dw $FF15,${ad:04X},${cv:04X},${pt:04X} ; ${a:04X}  IF (${ad:04X})==${cv:X} -> $${pt:04X}  (Yes/No answer $C83C)")
                a+=8; continue
            else:
                c=f"behavior/opcode ${op:02X}"
        else:
            c=msgcmt(v)
        outl.append(f"    dw ${v:04X}                    ; ${a:04X}  {c}")
        a+=2
    return outl

# worked-example ranges (start,end,title) — clean FF01/FF15/plain grids
EXAMPLES={
 0x09:[(0x6004,0x6016,"WORKED EXAMPLE: 'monster grandpa breeding book' (a §$6004) — a Yes/No book"),
       (0x6016,0x60A0,"WORKED EXAMPLE: breeding library books/NPCs (a §$6016) — flag-gated + Yes/No pages")],
 0x0D:[(0x62A8,0x6340,"WORKED EXAMPLE: 'growth diary' bookshelf (a §$62A8) — multi-page book chained by 〔はい/いいえ〕")],
}

# ---- code region from bank12 ----
b12lines=open('overworld/bank12.asm').read().split('\n')
code=[ln.replace('Bank12_','Bank13_') for ln in b12lines[75:417]]

out=[]; A=out.append
A('; ============================================================================')
A('; Dragon Quest Monsters: Terry\'s Wonderland (GBC)')
A('; ROM Analysis - Bank 13  (Tile movement engine, area types $06-$1F)')
A('; ============================================================================')
A(';')
A('; File offset $34000-$37FFF (16 KB); mapped at $4000-$7FFF when bank reg = 13.')
A(';')
A('; RST $10 banked-call convention: LD HL,(bank<<8)|fn_idx ; RST $10.')
A('; Function table at $4001:  fn0 $4007 · fn1 $402F · fn2 $4110.')
A(';   fn0 = READ map cell at coord (collision / event / NPC-text query)')
A(';   fn1 = PAINT cell tile indices into $9800 BG map (scroll-fill)')
A(';   fn2 = PAINT cell CGB attributes into VRAM bank 1 (VBK)')
A(';')
A('; SHARED ENGINE: code $4007-$41B9 is BYTE-FOR-BYTE identical to bank12/14/15')
A('; (only the self-id byte at $4000 differs: $0D here). Full annotation below;')
A('; see overworld/bank12.asm for the same routines under area type 0.')
A(';')
A('; DATA (this bank) = 26 area types ($06-$1F). bank4/Sub_71EF ($71EF) routes')
A('; wAreaType ($D8D3) $06-$1F here (LD HL,$0D00; RST $10). The $41BA L1 table is')
A('; indexed by the FULL wAreaType: rows $00-$05 alias placeholder grid $7C3E')
A('; (owned by bank12); rows $06-$1F are real.')
A(';')
A('; TEXT REFERENCES: a cell value with high byte != $FF is a GLOBAL MESSAGE ID,')
A('; routed by ROM0 MsgBankRouter ($0EC5) to dialogue banks 66-78 (local msg =')
A('; global_id - bank_base; bank66 base $0000, 67 $00E2, 68 $0198, 69 $0244,')
A('; 70 $0300, 71 $03C8, 72 $0474, 73 $0512, 74 $05E0, 75 $072B, 78 $07D3).')
A('; bank13 grids reference 815 distinct message ids ($0000-$0881) across ALL of')
A('; banks 66-75/78 -- this is the monster-BREEDING-RANCH / library interior set')
A('; (egg appraiser, はいごう tutorial books, growth diaries, tutorial NPCs).')
A('; See the WORKED EXAMPLES inline below (area types $09 and $0D) for decoded')
A('; grids showing the flag-branch VM + Yes/No book pages + routed Japanese text.')
A('; ============================================================================')
A('')
A('SECTION "Bank 13 Functions", ROMX[$4000], BANK[13]')
A('')
A('    db $0D                        ; $4000  self-id byte (bank number)')
A('    dw $4007, $402F, $4110        ; $4001  function pointer table (fn0/fn1/fn2)')
A('')
A('; ------------------------------------------------------------')
A('; Bank13_Fn0/Fn1/Fn2 — shared map engine (identical to bank12 code)')
A('; ------------------------------------------------------------')
out+=code
A('')
A('')
A('SECTION "Bank 13 Map Data", ROMX[$41BA], BANK[13]')
A('; ============================================================================')
A('; MAP DATA — 3-level table: L1 wAreaType -> L2 section -> cell grid[coord].')
A(';   Cell: $FFFF walk · $FFxx behavior (lo -> bank4 TileBehaviorTable $5620)')
A(';   · $00xx-$08xx GLOBAL MESSAGE ID (routed by ROM0 $0EC5, see header).')
A(';   $FF01 <flag> <ptr>       : IF event-flag SET -> branch to <ptr> else next')
A(';   $FF15 <addr> <val> <ptr> : IF WRAM[addr]==val -> <ptr> (Yes/No via $C83C)')
A('; ============================================================================')
A('Bank13_AreaTypeTable:                       ; $41BA  (L1: wAreaType -> section table)')
for base0 in range(0,0x20,6):
    grp=[w(0x41BA+2*t) for t in range(base0,min(base0+6,0x20))]
    txt=','.join('$%04X'%v for v in grp)
    A('    dw %-42s ; areaType $%02X-$%02X'%(txt,base0,min(base0+5,0x1F)))
A('                                             ;   ($00-$05 = $7C3E placeholder alias)')
A('')
for t,p in real:
    start,nxt=bnd[t]; ns=nsec(t); grid0=start+ns*2
    A('Bank13_Area%02X_Sections:                     ; $%04X  (%d section%s)'%(t,start,ns,'' if ns==1 else 's'))
    for i in range(0,ns,8):
        grp=[w(start+2*j) for j in range(i,min(i+8,ns))]
        A('    dw %s   ; section $%02X+'%(','.join('$%04X'%v for v in grp),i))
    # grid payload, splitting around worked examples
    exs=sorted(EXAMPLES.get(t,[]))
    cur=grid0
    if not exs:
        glen=nxt-grid0
        if glen>0:
            A('Bank13_Area%02X_Grids:                        ; $%04X-$%04X  (%d bytes)'%(t,grid0,nxt,glen))
            A('    INCBIN "terry.gbc", $%06X, $%04X'%(0x34000+(grid0-0x4000),glen))
    else:
        idx=0
        for lo,hi,title in exs:
            if cur<lo:
                A('Bank13_Area%02X_Grids_%04X:                   ; $%04X-$%04X'%(t,cur,cur,lo))
                A('    INCBIN "terry.gbc", $%06X, $%04X'%(0x34000+(cur-0x4000),lo-cur))
            A('; ---------------------------------------------------------------------------')
            A('; %s'%title)
            A('; ---------------------------------------------------------------------------')
            A('Bank13_Area%02X_Ex_%04X:'%(t,lo))
            out.extend(decode_range(lo,hi))
            cur=hi
        if cur<nxt:
            A('Bank13_Area%02X_Grids_%04X:                   ; $%04X-$%04X'%(t,cur,cur,nxt))
            A('    INCBIN "terry.gbc", $%06X, $%04X'%(0x34000+(cur-0x4000),nxt-cur))
    A('')
A('; NOTE: the $7C3E placeholder grid (aliased by area types $00-$05) lies within')
A('; the area-type $1F grid payload above.')
A('')
A('    ds $%04X, $FF                   ; $%04X-$7FFF padding'%(0x8000-end,end))
open('overworld/bank13.asm','w',encoding='utf-8').write('\n'.join(out)+'\n')
print("wrote bank13.asm:",len(out),"lines")
