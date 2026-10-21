; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 10  (Area/dungeon phase controller — set A)
; ============================================================================
;
; Bank 10 memory map:
;   File offset $28000-$2BFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 10
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; SYSTEM: AREA STATE CONTROLLER (dungeon / overworld phase set A)
;   fn0 reads $C8EF (area sub-phase counter) and dispatches via RST $00
;   through a 16-entry jump table at $4007.  Most states fall through to $4027
;   (RET), but states 5, 6, 7, and 11 jump to real handler code.
;
;   Compare bank18.asm which is the same system for a different phase set
;   (bank18 has handlers at states 3, 8, 9, 10).
;
;   $C8EF = wAreaPhase: incremented by game logic as the player moves
;   through an area or dungeon.  Different states represent: approach,
;   enter room, scroll, load tiles, exit.
;
;   fn1 ($EFFA) and fn2 ($C7C8) are RAM-resident functions — these point to
;   WRAM, meaning the code is loaded there at runtime (DMA or copy).
;
; Function table at $28001 (bank 10 $4001):
;   fn0:  $4003  ← area phase dispatcher (reads $C8EF, RST $00)
;   fn1:  $EFFA  ← RAM-resident function (dynamically loaded code)
;   fn2:  $C7C8  ← RAM-resident function (dynamically loaded code)
;   fn3:  $4027  ← stub (RET only)
;   fn4:  $4027  ← stub
;   fn5:  $4027  ← stub
;   fn6:  $4027  ← stub
;   fn7:  $4027  ← stub
;
; Key WRAM variables:
;   $C8EF  wAreaPhase  — area/dungeon sub-phase index (RST $00 dispatch)
;
; RST $00 dispatch table at $4007 (16 entries × 2 bytes):
;   state  0: $4027  (RET — idle)
;   state  1: $4027  (RET)
;   state  2: $4027  (RET)
;   state  3: $4027  (RET)
;   state  4: $4027  (RET)
;   state  5: $4455  ← area enter animation / tile load
;   state  6: $4BEB  ← room scroll handler
;   state  7: $6095  ← area exit / transition handler
;   state  8: $4027  (RET)
;   state  9: $4027  (RET)
;   state 10: $4027  (RET)
;   state 11: $6961  ← secondary area transition
;   state 12: $4027  (RET)
;   state 13: $4027  (RET)
;   state 14: $4027  (RET)
;   state 15: $4027  (RET)

SECTION "Bank10 Functions", ROMX[$4000], BANK[10]


; ============================================================================
; Bank10_Fn0  ($4003)  — Area phase dispatcher
; ============================================================================
; Reads $C8EF (wAreaPhase), dispatches via RST $00 to the handler for
; the current area phase.  Most phases are no-ops (RET at $4027).
; Active phases:
;   5 → $4455: area enter animation (tile/palette loading for new room)
;   6 → $4BEB: mid-scroll room update
;   7 → $6095: area exit / bank-switch to new area
;  11 → $6961: secondary area transition (sub-area crossings)
Bank10_Fn0:                                 ; $4003
    LD A,($C8EF)                           ; wAreaPhase
    RST $00                                ; dispatch on phase
    ; jump table at $4007 (16 entries)
    ; states not listed above → $4027 (RET)

Bank10_Stub4027:                            ; $4027
    RET


; ============================================================================
; Bank10_Sub_4028  ($4028)  — Tile value adjust helper
; ============================================================================
; Adds $04 to (HL), advances HL, then clears upper 3 bits of (HL):
;   LD A,(HL); ADD A,$04; LD (HL+),A  → write updated lo byte, inc HL
;   LD A,(HL); ADC A,$00; LD (HL-),A  → propagate carry to hi byte, back
;   LD A,(HL); AND $F8; LD (HL),A     → mask hi byte to $F8 aligned
;   RET
; Used to advance a 16-bit tile/VRAM address by 4, keeping it
; aligned to a tile boundary ($F8 = 1111_1000, clears low 3 bits).
Bank10_Sub_4028:                            ; $4028
    LD A,(HL)
    ADD A,$04
    LD (HL+),A                             ; add 4 to lo byte
    LD A,(HL)
    ADC A,$00                              ; carry into hi byte
    LD (HL-),A
    LD A,(HL)
    AND $F8                                ; align to tile boundary
    LD (HL),A
    RET


; ============================================================================
; Bank10_State5  ($4455)  — Area enter: tile / palette loader
; ============================================================================
; Handles the "entering a new room" phase:
;   loads tile data and palettes for the new area.
; (Detailed disassembly deferred — see state transition from wAreaPhase.)


; ============================================================================
; Bank10_State6  ($4BEB)  — Mid-scroll room update
; ============================================================================
; Drives the tile-scroll animation for room-to-room transitions.
; Similar to bank19/fn3 but for dungeon room scrolling.


; ============================================================================
; Bank10_State7  ($6095)  — Area exit / transition
; ============================================================================
; Handles the "leaving a room" phase:
;   saves scroll position, triggers bank switch to new area ID.


; ============================================================================
; Bank10_State11  ($6961)  — Secondary area transition
; ============================================================================
; Handles transitions across sub-area boundaries (e.g., staircase entry).


; ============================================================================
; ROM DATA
; ============================================================================
; $4007  RST $00 jump table (16 entries × 2 bytes)
;        Most entries = $4027 (RET); active at states 5/6/7/11.
;
; Note on RAM-resident fn1 ($EFFA) and fn2 ($C7C8):
;   These are dynamically-loaded routines copied into WRAM at runtime,
;   called via the normal RST $10 banked-call mechanism.
;   $EFFA is Echo RAM of $CFFA; $C7C8 is normal WRAM.
;   Content depends on which dynamic routine was last loaded.
;
; ============================================================================
; Bank10_ShowMsg  ($441F)  — display a dungeon/area event message
; ============================================================================
; HL (a base id) += wMsgId ($C8F1:$C8F0), giving the GLOBAL message id, then
; MsgBankRouter (ROM0 $0EC5) splits it by high/low byte, re-bases it to a
; bank-local index ($C822/$C823), and RST $10s into the owning text bank's fn0
; (banks 66-75/78). So $C8F0/$C8F1 (wMsgId) selects the event line.
; (bank18.asm has the identical function + two hard-coded bank74 ids.)
; ------------------------------------------------------------
Bank10_ShowMsg:
    LD A,($C8F0)
    ADD A,L
    LD L,A                              ; + wMsgId lo
    LD A,($C8F1)
    ADC A,H
    LD H,A                              ; HL = base + $C8F1:$C8F0 = global msg id
    CALL $0EC5                          ; MsgBankRouter (ROM0) → route to text bank + print
    RET
