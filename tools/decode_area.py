# Decode a bank11 area descriptor [P,END) into Area0-63 form, emitting CONTIGUOUSLY
# (room-array dw -> per-room {dw sel; N*(db block,bank; dw obj,oth)} -> objlists db)
# so the bytes tile [P,END) with no gaps/overlaps (byte-exact).
rom=open('terry.gbc','rb').read(); B=11*0x4000
def by(a): return rom[B+(a-0x4000)]
def w(a): o=B+(a-0x4000); return rom[o]|(rom[o+1]<<8)
def _lbl(s): return s+' '*max(1,28-len(s))

def decode(P, END, aidx, aliases):
    out=[]; A=out.append
    alias='' if not aliases else '  (also areas %s = %s)'%(', '.join('%d'%a for a in aliases),
                                                            ', '.join('$%02X'%a for a in aliases))
    if END-P==2:
        A('%s; $%04X  AreaDir[%d]=area $%02X%s (2-byte stub -> $%04X)'%(_lbl('Bank11_Area%d:'%aidx),P,aidx,aidx,alias,w(P)))
        A('    dw $%04X'%w(P)); return out
    # room array: dw until addr reaches first real room-entry ptr
    minr=END; a=P; arr=[]
    while a<minr:
        v=w(a); arr.append(v)
        if P<v<END: minr=min(minr,v)
        a+=2
    first_room=minr
    real=sorted({v for v in arr if v!=0xFFFF and P<v<END})
    idxof={}
    for i,v in enumerate(arr):
        if v!=0xFFFF: idxof.setdefault(v,[]).append(i)
    A('%s; $%04X  AreaDir[%d]=area $%02X%s'%(_lbl('Bank11_Area%d:'%aidx),P,aidx,aidx,alias))
    for k in range(0,len(arr),8):
        g=arr[k:k+8]; A('    dw %s   ; rooms %d-%d'%(','.join('$%04X'%v for v in g),k,k+len(g)-1))
    # room entries, contiguous; non-last bounded by next room ptr, last by bank-heuristic
    for j,s in enumerate(real):
        nxt = real[j+1] if j+1<len(real) else None
        c=s+2
        if nxt is not None:
            nvar=(nxt-s-2)//6
            vs=[(c+6*i) for i in range(nvar)]
            vend=s+2+nvar*6            # variants end (remainder < nxt emitted below)
        else:
            vs=[]
            while c+6<=END and 0x23<=by(c+1)<=0x3F:  # variant bank byte in graphics range
                vs.append(c); c+=6
            vend=c
        idxs=idxof.get(s,[])
        il=','.join(str(x) for x in idxs) if idxs else '?'
        A('%s; $%04X  room(s) %s: sel + %d variant(s)'%(_lbl('Bank11_Area%d_Room%s:'%(aidx,idxs[0] if idxs else 'X')),s,il,len(vs)))
        A('    dw $%04X   ; variant selector (WRAM)'%w(s))
        for vi,vc in enumerate(vs):
            blk,bank=by(vc),by(vc+1); obj=w(vc+2); oth=w(vc+4)
            A('    db $%02X,$%02X,$%02X,$%02X,$%02X,$%02X  ; v%d: bank$%02X blk$%02X obj=$%04X oth=$%04X'%(
                blk,bank,obj&0xff,obj>>8,oth&0xff,oth>>8,vi,bank,blk,obj,oth))
        # remainder bytes between the last variant and the next room (non-last rooms)
        if nxt is not None and vend<nxt:
            x=vend
            while x<nxt:
                n=min(8,nxt-x); A('    db %s   ; $%04X (extra)'%(','.join('$%02X'%by(x+k) for k in range(n)),x)); x+=n
    objstart=vend  # end of last room's variants
    if objstart<END:
        A('%s; $%04X-$%04X  compact 5-byte object records + "other" data'%(_lbl('Bank11_Area%d_ObjLists:'%aidx),objstart,END-1))
        out.extend(decode_objlist(objstart,END,aidx))
    return out

def decode_objlist(lo, hi, aidx):
    # Emit the compact object source lists as Area0-63 does: 5-byte records
    #   [type/face, sprite, +x, +y, event]; byte0 bit7 = HEADER (no NPC);
    #   $FF byte0 = single-byte end-of-list. A new Bank11_AreaN_Obj_XXXX label
    #   starts at lo and after each $FF terminator. Byte-exact.
    out=[]; A=out.append; a=lo; need_label=True
    while a<hi:
        if need_label:
            A('Bank11_Area%d_Obj_%04X:%s; $%04X  (object list)'%(aidx,a,' '*max(1,10),a)); need_label=False
        b0=by(a)
        if b0==0xFF:
            A('    db $FF   ; $%04X end'%a); a+=1; need_label=True; continue
        if a+5<=hi:
            t,spr,x,y,ev=by(a),by(a+1),by(a+2),by(a+3),by(a+4)
            if b0&0x80:
                A('    db $%02X,$%02X,$%02X,$%02X,$%02X   ; $%04X HEADER(bit7)'%(t,spr,x,y,ev,a))
            else:
                A('    db $%02X,$%02X,$%02X,$%02X,$%02X   ; $%04X type%d face%d spr$%02X (+%d,+%d) ev$%02X'%(
                    t,spr,x,y,ev,a, t&0x0F, t>>4, spr, x, y, ev))
            a+=5
        else:
            n=hi-a; A('    db %s   ; $%04X (tail)'%(','.join('$%02X'%by(a+k) for k in range(n)),a)); a+=n
    return out
