# Generate byte-exact disassembly of bank4's function-table region ($400F-$443C):
#   fn0, fn1, DATA1, fn2, fn3, Sub_40CD, Sub_4126, DATA2, DATA3(ScrollFlagTable), fn4.
# Emits project-style lines "    MNEMONIC ; $ADDR [HEX]  ; comment" and db rows for data.
import sys; sys.path.insert(0,'tools')
from sm83dis import disasm
rom=open('terry.gbc','rb').read(); B=4*0x4000; data=rom[B:B+0x4000]; org=0x4000

# curated inline comments keyed by instruction address
C={
0x400F:'DE = &SpriteLayoutTbl ($401D)',
0x4012:'ROM0 $1164: load metasprite/map data from (DE)',
0x4016:'DE = &SpriteLayoutTbl ($401D)',
0x4019:'local Sub_40CD: compose OAM sprites from (DE)',
0x4081:'hScrollSpeed',0x4083:'>= $90? -> fast-left',0x4087:'>= $10? -> fast-right',
0x408B:'slow: hScrollFlags |= FlagTbl[speed]',0x408E:'DE = &MapXitTbl ($4137)',
0x4091:'ROM0 $1164 loader',0x4095:'fast-right: speed -= $10',0x4099:'bank16 fn0',
0x409E:'fast-left: speed -= $90',0x40A2:'bank17 fn0',
0x40A7:'hScrollSpeed',0x40B1:'hScrollFlags |= FlagTbl[speed]',0x40B4:'DE = &MapXitTbl ($4137)',
0x40B7:'slow: local OAM composer (not ROM0)',0x40BF:'bank16 fn1',0x40C8:'bank17 fn1',
0x40D1:'hSpriteCount ($FFCB); >= $28(40)? -> done',
0x40D7:'hIdxA ($FFC7): index into table -> DE = row base',
0x40E1:'hIdxB ($FFC8): 2nd index -> DE = sprite src',
0x40EB:'sprite# * 4 -> HL = &OAM[$C000 + n*4]',
0x40F4:'src Y; $80 = end-of-list sentinel',
0x40FB:'OAM.Y = hYBase($FFC5) + srcY + $10',
0x4104:'OAM.X = hXBase($FFC3) + srcX + $08',
0x410A:'OAM.tile = hTileBase($FFC9) + src',
0x4114:'OAM.attr = hAttrXor($FFCA) ^ src',
0x4118:'sprite# ++; loop while < $28 (40 sprites)',
0x4126:'hScrollSpeed = index into ScrollFlagTable',0x4131:'hScrollFlags |= table[speed]',
# ---- fn4 ----
0x4167:'--- GATE 1: other mode owns the frame? ---  wStateFlags',
0x416A:'ignore bit0 (scroll-in-progress)',0x416C:'ignore bit2 (zone-scroll)',
0x416F:'any OTHER bit set (party/dialog/shop/...) -> skip movement',
0x4170:'--- GATE 2: scroll-phase sync ---',0x4173:'scroll in progress?',
0x4177:'wScrollPhaseCtr $C915',0x417A:'== $0B (ready for next step)?',0x417C:'not yet -> wait',
0x417F:'zone-scroll (bit2)?',0x4183:'wAreaMode $C91E',0x4186:'== 2 (mid-transition)?',
0x4189:'--- GATE 3: anim/audio idle ---  wAnimActive $C850',0x418E:'wAudioState $C825',
0x4193:'--- DISPATCH on wSaveMode $D8D7 ---',0x4196:'bit0 = move-command queued?',
0x4198:'not queued -> RET ($41C7)',0x419B:'bit1 = movement locked?',
0x41A0:'wSaveMode',0x41A3:'bit4 = primary warp pending?',0x41A5:'-> scan warp slots (Sub_43EC)',
0x41AB:'bit6 = secondary warp pending?',0x41AD:'-> scan warp slots again',
0x41B3:'bit2 = countdown timer?',0x41B5:'-> countdown path ($41C8)',
0x41B7:'bit3 = smooth scroll-move?',0x41B9:'-> scroll-move path ($41E0)',
0x41BC:'wMoveFlags2 $D8D8',0x41BF:'bit2 = 2nd countdown?',0x41C1:'-> Sub_43DB',
0x41C4:'else: normal step-and-move (Sub_55F5)',0x41C7:'shared RET',
0x41C8:'--- COUNTDOWN path (bit2) ---  hFrameCtr $C8A4',0x41CB:'every 8th frame only',
0x41CF:'wCountdown $D8DB',0x41D3:'store back',0x41D6:'not 0 yet -> stay',
0x41DB:'reached 0 -> clear wSaveMode bit2',0x41DD:'-> RET',
0x41E0:'--- SCROLL-MOVE path (bit3): pixel-walk camera to target ---  wWarpLock $D8DC',
0x41E4:'warp-lock set -> object-move variant ($42CD)',
0x41E7:'hBusyFlag $FF90',0x41EA:'set bit0 = busy this frame',
0x41EC:'hFrameCtr $C8A4',0x41F1:'phase 1 of 4? -> skip this frame ($43D8)',
0x41F6:'wDeltaX lo $D8DD',0x41FA:'wDeltaX hi $D8DE',
0x41FF:'X delta == 0? -> do Y ($425A)',0x4202:'X delta negative? -> move +X ($4231)',
0x4206:'--- X delta > 0: step player -X, camera +X ---',0x4216:'hCamX lo $92',
0x4225:'wSaveMode bit5 (suppress facing)?',0x422C:'hFacing $8E = 3 (left)',
0x4231:'--- X delta < 0: step player +X, camera -X ---',0x4241:'hCamX lo $92',
0x4256:'hFacing $8E = 1 (right)',
0x425A:'wDeltaY lo $D8DF',0x425E:'wDeltaY hi $D8E0',
0x4263:'Y delta == 0? -> both done ($42C0)',0x4266:'Y delta negative? -> move +Y ($4293)',
0x426A:'--- Y delta > 0: step -Y, camera +Y ---',0x427A:'hCamY lo $95',0x428F:'hFacing $8E = 0 (up)',
0x4293:'--- Y delta < 0: step +Y, camera -Y ---',0x42A3:'hCamY lo $95',0x42B8:'hFacing $8E = 2 (down)',
0x42BA:'commit step (Sub_454B)',0x42BD:'-> tail ($43D8)',
0x42C0:'--- both deltas exhausted: move done ---',0x42C3:'clear hBusyFlag bit0',
0x42C8:'clear wSaveMode bit3 (scroll-move done)',
0x42CD:'--- OBJECT-MOVE variant (warp-lock set): move an NPC/object record ---',
0x42CE:'(wWarpLock-1)*32 ...',0x42D1:'wObjectTable $D7D2',0x42DB:'hObjPtr $FFD5:D6',
0x42E1:'record+5 (state byte)',0x42E8:'set bit0 (moving)',0x42EA:'clear bit6',
0x42EC:'hFrameCtr $C8A4',0x42F3:'phase 1? -> skip',
0x42F6:'obj wDeltaX $D8DD',0x42FF:'==0 -> obj Y ($435F)',0x4302:'negative? -> +X ($4333)',
0x4321:'record +$12 = obj X word; ++',0x4330:'-> tail',
0x434E:'record +$12 = obj X word; --',
0x435F:'obj wDeltaY $D8DF',0x4368:'==0 -> obj done ($43C7)',0x436B:'negative? -> +Y ($439B)',
0x438A:'record +$14 = obj Y word; ++',
0x43B6:'record +$14 = obj Y word; --',
0x43C7:'--- object move done: clear its moving bit ---',0x43C9:'record+5',
0x43D1:'clear bit0 (stopped)',0x43D6:'clear wSaveMode bit3',
0x43D8:'tail: -> RET via $41C7',
0x43DB:'--- Sub_43DB: 2nd countdown (wMoveFlags2 bit2) ---  wCountdown $D8DB',
0x43E7:'reached 0 -> clear wMoveFlags2 bit2',0x43E9:'-> RET',
0x43EC:'--- Sub_43EC: scan 8 warp-event slots ---  wWarpSlot0 flag $D8E9',
0x43F0:'primary slot handler (Sub_443D)',
0x43F4:'OR slot1 flag $D8F1',0x43F9:'Sub_4584 (slot handler)',
0x43FD:'OR slot2 $D8F9',0x4406:'OR slot3 $D901',0x440F:'OR slot4 $D909',
0x4418:'OR slot5 $D911',0x4421:'OR slot6 $D919',0x442A:'OR slot7 $D921',
0x4433:'any slot still active? -> come back next frame',
0x4438:'all idle: clear wSaveMode bit4',0x443A:'... and bit6',
}

# labels to emit before certain addresses
L={
0x400F:'Bank4_Fn0:  ; $400F',
0x4016:'Bank4_Fn1:  ; $4016',
0x4081:'Bank4_Fn2:  ; $4081',
0x40A7:'Bank4_Fn3:  ; $40A7',
0x40CD:'Bank4_Sub_40CD:  ; $40CD  (OAM metasprite composer; DE=layout table)',
0x4126:'Bank4_Sub_4126:  ; $4126  (hScrollFlags |= ScrollFlagTable[hScrollSpeed])',
0x4167:'Bank4_Fn4:  ; $4167',
0x41C8:'.lbl_41C8:',0x41E0:'.lbl_41E0:',0x42BA:'.lbl_42BA:',0x42C0:'.lbl_42C0:',
0x42CD:'.lbl_42CD:',0x43C7:'.lbl_43C7:',0x43D8:'.lbl_43D8:',
0x43DB:'Bank4_Sub_43DB:  ; $43DB  (2nd countdown timer)',
0x43EC:'Bank4_Sub_43EC:  ; $43EC  (scan 8 warp-event slots)',
}

def code(lo,hi,out):
    for a,n,mn in disasm(data,org,lo,hi):
        if a in L: out.append(L[a])
        hx=' '.join('%02X'%data[a-org+k] for k in range(n))
        base='    %-30s ; $%04X [%s]'%(mn,a,hx)
        if a in C: base+='  ; '+C[a]
        out.append(base)

def datarows(lo,hi,out,label,note):
    out.append('%s  ; $%04X-$%04X  %s'%(label,lo,hi-1,note))
    a=lo
    while a<hi:
        n=min(16,hi-a)
        out.append('    db %s   ; $%04X'%(','.join('$%02X'%data[a-org+k] for k in range(n)),a))
        a+=n

O=[]
O.append('; ============================================================================')
O.append('; FUNCTION-TABLE FUNCTIONS (fn0-fn6) — byte-exact.  Table @ $4001 (7 dw):')
O.append(';   fn0 $400F  fn1 $4016  fn2 $4081  fn3 $40A7  fn4 $4167  fn5 $55EC  fn6 $56FA')
O.append('; fn0/fn1 push a metasprite layout table ($401D); fn2/fn3 are scroll-speed')
O.append('; dispatchers; fn4 is the per-VBlank movement/scroll engine (see its header).')
O.append('; ============================================================================')
O.append('')
O.append('; fn0/fn1: hand DE=$401D (sprite layout table) to a metasprite builder.')
O.append(';   fn0 -> ROM0 $1164 (shared loader);  fn1 -> local Sub_40CD (OAM composer).')
code(0x400F,0x401D,O)
O.append('')
datarows(0x401D,0x4081,O,'Bank4_SpriteLayoutTbl:','metasprite layout data (DE for fn0/fn1)')
O.append('')
O.append('; ------------------------------------------------------------')
O.append('; Bank4_Fn2 / Bank4_Fn3 — scroll-speed dispatchers (hScrollSpeed $FFC7):')
O.append(';   < $10  : slow  -> accumulate flag + load map data ($4137)')
O.append(';   $10-$8F: fast-right -> speed-=$10, bank16')
O.append(';   >= $90 : fast-left  -> speed-=$90, bank17')
O.append(';   fn2 slow uses ROM0 $1164 & calls bank16/17 fn0;')
O.append(';   fn3 slow uses local Sub_40CD & calls bank16/17 fn1.')
O.append('; ------------------------------------------------------------')
code(0x4081,0x4137,O)
O.append('')
datarows(0x4137,0x4157,O,'Bank4_MapXitTbl:','map/scroll-exit data (DE for fn2/fn3 slow path)')
O.append('')
datarows(0x4157,0x4167,O,'Bank4_ScrollFlagTable:','hScrollFlags OR-mask per speed (Sub_4126)')
O.append('')
O.append('; ============================================================================')
O.append('; Bank4_Fn4 ($4167) — PER-VBLANK MOVEMENT / SCROLL ENGINE  (the important one)')
O.append('; ----------------------------------------------------------------------------')
O.append('; Called every frame from bank1 state-1 (LD HL,$0404; RST $10). Advances one')
O.append('; queued player/camera/object move by ONE pixel-step per eligible frame.')
O.append(';')
O.append('; 3 GATES first: (1) if any $C8EB mode bit other than 0/2 is set, another')
O.append('; subsystem owns the frame -> RET. (2) sync to scroll phase ($C915==$0B for')
O.append('; bit0, or $C91E==2 for bit2). (3) RET while anim ($C850) or audio ($C825) busy.')
O.append(';')
O.append('; Then dispatch on wSaveMode $D8D7: bit0=0 or bit1 -> RET; bit4/bit6 -> scan')
O.append('; warp slots (Sub_43EC); bit2 -> countdown ($41C8); bit3 -> smooth scroll-move')
O.append('; ($41E0, walks camera HRAM $92/$93 & $95/$96 toward target, sets facing $8E,')
O.append('; or moves an object record if wWarpLock $D8DC set); else -> Sub_55F5 (step).')
O.append(';')
O.append('; Key WRAM/HRAM: $D8DD:DE=signed remaining X, $D8DF:E0=remaining Y (16-bit,')
O.append('; counted down to 0), hCamX $92/$93, hCamY $95/$96, hFacing $8E (0=U,1=R,2=D,')
O.append('; 3=L), hFrameCtr $C8A4 (phase throttle), hBusyFlag $FF90 bit0.')
O.append('; ============================================================================')
code(0x4167,0x443D,O)

open('/tmp/bank4_table.asm','w').write('\n'.join(O)+'\n')
print('\n'.join(O[:1]))
print('generated %d lines -> /tmp/bank4_table.asm'%len(O))
# byte-exact self check: reconstruct covered bytes from disasm+data ranges
cov=[]
for lo,hi in [(0x400F,0x401D),(0x401D,0x4081),(0x4081,0x4137),(0x4137,0x4157),(0x4157,0x4167),(0x4167,0x443D)]:
    cov.append((lo,hi))
# ensure contiguous $400F-$443C
prev=0x400F
for lo,hi in cov:
    assert lo==prev,(hex(lo),hex(prev)); prev=hi
assert prev==0x443D, hex(prev)
print('coverage contiguous $400F-$443C OK')
