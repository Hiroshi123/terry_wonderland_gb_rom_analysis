# Decode + comment bank64 (== bank65 mirror): the master NAME/LABEL/MESSAGE table.
# Code+index tables ($4000-$4C57) kept as INCBIN; the $F0-delimited kana stream
# ($4C58-$78E5) is decoded one entry per db line with the kana in the comment and
# semantic group headers. Byte-exact.
rom=open('terry.gbc','rb').read(); BASE=0x100000  # bank64 file offset
def by(a): return rom[BASE+(a-0x4000)]
m={}
for i,c in enumerate('あいうえおかきくけこさしすせそたちつってとなにぬねのはひふへほまみむめもやゃゆゅよょらりるれろわをん'): m[0x24+i]=c
for i,c in enumerate('アァィイゥウェエォオカキクケコサシスセソタチツッテトナニヌネノハヒフヘホマミムメモヤ'): m[0x56+i]=c
for i,c in enumerate('ユヨャュョラリルレロワヲン゛゜'): m[0x80+i]=c
m[0x9C]='ー'; m[0x90]='　'
def txt(bs): return ''.join(m[b] if b in m else '{%02X}'%b for b in bs)

# group headers keyed by entry START address
GROUPS={
0x4C59:('NAMES / LABELS','place & room names (しろ, とびらのま...), NPC/character names,'
                          ' item names, and some inline battle/menu message templates'),
0x59E6:('MONSTER NAMES','first the 9 FAMILY names (スライム/ドラゴン/けもの/とり/しょくぶつ/'
                        'むし/あくま/ゾンビ/ぶっしつ), then every species'),
0x6113:('SPELL NAMES (magic)','メラ/メラミ/メラゾーマ, ギラ系, イオ系, バギ系, ヒャド系,'
                              ' デイン系, ホイミ/ベホマ/ザオリク, パルプンテ ...'),
0x6261:('SKILL NAMES (physical / special)','つうじょうこうげき, たいあたり, 〜ぎり,'
                        ' れんぞくこうげき, グランドクロス, ふしぎなおどり ...'),
0x66C4:('ITEM / MISC NAMES + breeding name fragments',''),
0x6C12:('EFFECT / STAT-CHANGE DESCRIPTIONS','item & spell effect text with insert codes'),
0x7005:('BATTLE / RESULT MESSAGES + STATS-SCREEN TEMPLATES','exp/level-up messages;'
                        ' $71BF/$7245 = the monster STATUS screen layout (さいだいHP/こうげ'
                        'きりょく/しゅびりょく/すばやさ/かしこさ/レベル), used by bank7'),
}

O=[]
O.append('; ==========================================================================')
O.append('; Bank 64 ($40) — MASTER NAME / LABEL / MESSAGE TEXT TABLE  (mirror of bank65)')
O.append('; ==========================================================================')
O.append('; Byte-for-byte identical to bank65 (self-ID $4000=$41). Same kana codec as the')
O.append('; other text banks (identity-mapped; see memory text-codec). A TWO-LEVEL pointer')
O.append('; index ($401E, 24 sections) resolves into the $F0-delimited kana stream below.')
O.append(';')
O.append('; THIS bank stores the game NAMES the UI/battle code looks up (bank7 info screen,')
O.append('; bank84 spell mechanics, etc. only reference these by index):')
O.append(';   $4C58  NAMES/LABELS (places, NPCs, items, misc messages)')
O.append(';   $59E6  MONSTER NAMES (9 families, then species)')
O.append(';   $6113  SPELL NAMES (magic)')
O.append(';   $6272  SKILL NAMES (physical / special moves)')
O.append(';   $66C4  ITEM / MISC names + breeding name fragments')
O.append(';   $6C12  EFFECT / stat-change descriptions')
O.append(';   $7005  BATTLE / result messages + the STATUS-screen template ($71BF/$7245)')
O.append(';   $78E6  $FF padding to end')
O.append('; ==========================================================================')
O.append('')
O.append('SECTION "Bank 64", ROMX[$4000], BANK[64]')
O.append('')
O.append('; --- $4000-$4C57 : self-ID + fn stubs + two-level pointer index ---')
O.append(';   (identical to bank65; pointer-table detail annotated there) ---')
O.append('    INCBIN "terry.gbc", $100000, $0C58   ; $4000-$4C57')
O.append('')
O.append('; --- $4C58-$78E5 : the $F0-delimited kana NAME/LABEL/MESSAGE stream ---')
O.append('Bank64_NameStream:')
a=0x4C58
cur=[]; start=a
def flush(start,cur,out):
    bs=cur+[0xF0]
    dbs=','.join('$%02X'%b for b in bs)
    out.append('    db %-52s ; $%04X %s'%(dbs,start,txt(cur)))
while a<0x78E5:
    if a in GROUPS and (a==start):
        nm,desc=GROUPS[a]
        O.append('; ======== %s ========'%nm)
        if desc:
            # wrap desc simply
            O.append(';   %s'%desc)
    b=by(a)
    if b==0xF0:
        flush(start,cur,O); cur=[]; start=a+1
    else:
        cur.append(b)
    a+=1
if cur: flush(start,cur,O)
O.append('')
O.append('; --- $78E5-$7FFF : $FF padding ---')
O.append('    INCBIN "terry.gbc", $%06X, $%03X   ; $78E5-$7FFF ($FF pad)'%(BASE+(0x78E5-0x4000), 0x8000-0x78E5))
open('text/bank64.asm','w').write('\n'.join(O)+'\n')
print('wrote text/bank64.asm,',len(O),'lines')
