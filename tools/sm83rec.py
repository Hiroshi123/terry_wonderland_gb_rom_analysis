# Recursive-descent SM83 disassembler: decodes only bytes reachable as code from
# an entry point (following JP/JR both edges, RST/CALL fall-through but NOT into
# the callee), so interspersed DATA is left as db. Byte-exact over [entry,maxend).
import sys; sys.path.insert(0,'tools')
from sm83dis import MAIN, INVALID, cb
def decode_one(data,org,a):
    off=a-org; op=data[off]
    if op==0xCB: return 2,cb(data[off+1])
    if op in INVALID: return 1,'db $%02X'%op
    mn,ln=MAIN[op]
    if '{d8}' in mn:  mn=mn.replace('${d8}','$%02X'%data[off+1])
    if '{a8}' in mn:  mn=mn.replace('${a8}','$%02X'%data[off+1])
    if '{d16}' in mn: mn=mn.replace('${d16}','$%04X'%(data[off+1]|(data[off+2]<<8)))
    if '{a16}' in mn: mn=mn.replace('${a16}','$%04X'%(data[off+1]|(data[off+2]<<8)))
    if '{r8}' in mn:
        rel=data[off+1]; rel=rel-256 if rel>127 else rel; mn=mn.replace('${r8}','$%04X'%((a+2+rel)&0xFFFF))
    if '{r8s}' in mn:
        rel=data[off+1]; mn=mn.replace('${r8s}', '+$%02X'%rel if rel<128 else '-$%02X'%(256-rel))
    return ln,mn
def succs(data,org,a,ln):
    """return (fallthrough_bool, [jump targets to follow])."""
    op=data[a-org]
    w=lambda:(data[a-org+1]|(data[a-org+2]<<8))
    jr=lambda:((a+2+(data[a-org+1]-256 if data[a-org+1]>127 else data[a-org+1]))&0xFFFF)
    if op==0xC3: return False,[w()]          # JP nn
    if op in (0xC2,0xCA,0xD2,0xDA): return True,[w()]   # JP cc,nn
    if op==0x18: return False,[jr()]         # JR nn
    if op in (0x20,0x28,0x30,0x38): return True,[jr()]  # JR cc
    if op in (0xC9,0xD9): return False,[]     # RET/RETI
    if op==0xE9: return False,[]              # JP (HL) indirect -> stop
    return True,[]                            # incl CALL/RST (fall through, don't follow callee)
def disasm_func(data,org,entry,lo=0x4000,hi=0x8000):
    seen={}; work=[entry]
    while work:
        a=work.pop()
        while lo<=a<hi and a not in seen:
            ln,mn=decode_one(data,org,a); seen[a]=(ln,mn)
            ft,tgts=succs(data,org,a,ln)
            for t in tgts:
                if lo<=t<hi and t not in seen: work.append(t)
            if not ft: break
            a+=ln
    if not seen: return entry,entry,[]
    maxend=max(a+l for a,(l,_) in seen.items())
    return entry,maxend,seen
def render(data,org,entry):
    e,end,seen=disasm_func(data,org,entry)
    lines=[]; a=e
    while a<end:
        if a in seen:
            ln,mn=seen[a]; hexb=' '.join('%02X'%data[a-org+k] for k in range(ln))
            lines.append('    %-26s ; $%04X  [%s]'%(mn,a,hexb)); a+=ln
        else:
            run=[]
            while a<end and a not in seen and len(run)<8:
                run.append(data[a-org]); a+=1
            lines.append('    db %-23s ; $%04X  (data)'%(','.join('$%02X'%b for b in run),a-len(run)))
    return end,lines
