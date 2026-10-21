; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 19  (Overworld tile-scroll animation driver)
; ============================================================================
;
; Called from: bank6/fn6 at $6069 via LD HL,$1303; RST $10
;   Condition: wStateFlags bit6 set (active tile-scroll animation)
;
; Bank 19 memory map:
;   File offset $4C000-$4FFFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 19
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; Function table at $4C001 (bank 19 $4001):
;   fn0: $4009
;   fn1: $4050
;   fn2: $40AE
;   fn3: $7366 ← overworld scroll animation driver (called by bank6/fn6)
;
; Purpose:
;   Drives the tile-based scroll animation when the overworld map is
;   scrolling (player step or area transition in progress).
;   fn3 is the main per-frame entry: reads wScrollPhase ($C905) and
;   dispatches via RST $00 through a 4-phase (or more) animation cycle.
;
;   Selects animation parameters based on area: if wAreaID >= $30 then
;   B = $4D (sub-area scroll params), else B = $4B (main-area params).
;   Calls ROM0 $1EB4 (scroll animation step with B as parameter).
;   Zeroes out $C905 + 8 bytes (resets phase variables) and updates
;   hScrollX ($FFB7) and hScrollY ($FFBB) via Sub_774F.
;   Also clears $C8DA + 8 bytes after scroll completes.
;
; Key WRAM variables:
;   $C905  wScrollPhase   — scroll animation phase counter (RST $00 dispatch)
;   $C8DA               — scroll state array (cleared post-animation)
;   $C968  wAreaID        — area number (selects animation parameter set)
;   $C969  wSubAreaFlag   — non-zero = sub-area scroll behavior

SECTION "Bank 19 Functions", ROMX[$4000], BANK[19]


; ------------------------------------------------------------
; Bank19_Fn3  ($7366)  — Overworld tile-scroll animation driver
; ------------------------------------------------------------
; Per-frame scroll animation handler.  Dispatches on wScrollPhase ($C905)
; via RST $00 for multi-phase scroll animation.
; Phase dispatch table at $736A (4 entries):
;   Phase 0: init scroll ($4B0 or $4D params based on area)
;   Phase 1: mid-scroll update (hScrollX/hScrollY via Sub_774F)
;   Phase 2: finalize scroll
;   Phase 3: cleanup (zero C905+8, zero C8DA+8)
Bank19_Fn3:                         ; $7366
    LD A,($C905)                    ; wScrollPhase
    RST $00                         ; dispatch on scroll phase
    ; jump table at $736A:
    ;   $736A: phase 0 handler ptr
    ;   $736C: phase 1 handler ptr
    ;   $736E: phase 2 handler ptr
    ;   $7370: phase 3 handler ptr
    ; --- post-dispatch common code ($7372) ---
    LD B,$4B                        ; default scroll param (main areas)
    LD A,($C969)                    ; wSubAreaFlag
    OR A
    JR NZ,$7381
    LD A,($C968)                    ; wAreaID
    CP $30
    JR C,$7381
    LD B,$4D                        ; sub-area scroll param (area >= $30)
    LD A,B
    CALL $1EB4                      ; ROM0 scroll animation step
    XOR A
    LD HL,$C905
    LD BC,$0008
    CALL $169A                      ; zero 8 bytes at $C905 (reset phase vars)
    LD HL,$FFB7                     ; hScrollX
    CALL $774F                      ; update scroll X
    LD HL,$FFBB                     ; hScrollY
    CALL $774F                      ; update scroll Y
    LD HL,$C8DA
    LD BC,$0008
    LD A,$00
    CALL $169A                      ; clear scroll state array
    RET
