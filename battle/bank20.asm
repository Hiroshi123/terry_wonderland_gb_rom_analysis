; ============================================================================
; Dragon Quest Monsters: Terry's Wonderland (GBC)
; ROM Analysis - Bank 20  (Battle monster management / monster-compare)
; ============================================================================
;
; Bank 20 memory map:
;   File offset $50000-$53FFF (16 KB)
;   Mapped at $4000-$7FFF when MBC bank register = 20
;
; RST $10 banked-call convention:
;   LD HL,(bank<<8)|fn_idx; RST $10  → calls fn in target bank
;
; SYSTEM: BATTLE MONSTER MANAGEMENT
;   Manages monster data for the current battle / encounter.
;   fn3 zeroes and FF-fills a monster record slot in the $CAC1 array
;   (identical pattern to bank22/fn0, same $95-byte stride).
;   fn4 ($7BAC) is the monster-species-specific battle action handler:
;   reads $DA5E (monster species ID), compares against known IDs, and
;   branches to species-specific battle behavior subroutines.
;
; Relationship to bank22.asm:
;   bank22/fn0: STORAGE slot finder (finds free slot, fills it from ROM template)
;   bank20/fn3: BATTLE slot initializer (clears slot $DA14 for a battle monster)
;   Both use $CAC1 array, $0095 stride, Sub_260A (slot-ptr calculator).
;
; Function table at $50001 (bank 20 $4001):
;   fn0:  $400F  ← monster data init via $4849 (DA18 buffer)
;   fn1:  $4016  ← same as fn0 (alias or minor variant)
;   fn2:  $40B4  ← secondary init
;   fn3:  $401D  ← battle slot init (zero + FF-fill at slot $DA14)
;   fn4:  $7BAC  ← monster-species battle action router
;   fn5:  $7D12  ← battle action sub
;   fn6:  $4869  ← battle action helper
;   fn7:  $1811  ← ROM0-range helper (called directly, not via RST $10?)
;   fn8:  $CDDA  ← RAM-resident function
;   fn9:  $4849  ← Sub_4849: indexed slot copy (used by fn0/fn1)
;
; Key WRAM variables:
;   $CAC1        wMonsterArray     — monster record array (20 × $95 bytes)
;   $CAD6        wMonsterStat1     — monster stat region 1 (within slot)
;   $CAEA        wMonsterStat2     — 8-byte stat block (FF-filled = unset)
;   $CAF2        wMonsterStat3     — $19-byte stat block (FF-filled = unset)
;   $DA14        wBattleSlot       — active battle monster slot index
;   $DA18        wBattleMonBuf     — battle monster data buffer
;   $DA5E        wMonsterSpecies   — monster species ID (fn4 dispatch)

SECTION "Bank20 Functions", ROMX[$4000], BANK[20]


; ============================================================================
; Bank20_Fn0  ($400F)  — Monster data init (DA18 buffer)
; ============================================================================
; Calls Sub_4849 with DE = $DA18 (battle monster data buffer).
; Sub_4849 performs an indexed copy into the monster slot.
Bank20_Fn0:                                 ; $400F
    LD DE,$DA18                            ; battle monster data buffer
    CALL $4849                             ; Sub_4849: indexed slot init
    RET

Bank20_Fn1:                                 ; $4016  (same pattern as fn0)
    LD DE,$DA18
    CALL $4849
    RET


; ============================================================================
; Bank20_Fn3  ($401D)  — Battle slot initializer
; ============================================================================
; Zeroes and FF-fills the monster record at slot $DA14 in the $CAC1 array.
; Same pattern as bank22/fn0 but for the battle monster (not storage find):
;   HL = $CAC1, A = $DA14, CALL Sub_260A → HL = &$CAC1[$DA14 × $95]
;   BC = $0095, XOR A, CALL $169A → zero $95 bytes
;   HL = $CAD6[slot] → $FF fill 2 bytes (stat markers)
;   HL = $CAEA[slot] → BC = $0008, A = $FF, CALL $169A → fill 8 bytes
;   HL = $CAF2[slot] → BC = $0019, A = $FF, CALL $169A → fill $19 bytes
;   ... continues with further field initialization
Bank20_Fn3:                                 ; $401D
    LD HL,$CAC1                            ; monster record array base
    LD A,($DA14)                           ; battle slot index
    CALL $260A                             ; Sub_260A: HL = HL + A × $95
    LD BC,$0095
    XOR A
    CALL $169A                             ; ROM0 memset: zero $95 bytes
    LD HL,$CAD6                            ; stat region 1
    LD A,($DA14)
    CALL $260A
    LD A,$FF
    LD (HL+),A
    LD (HL+),A                             ; mark 2 stat bytes as $FF (unset)
    LD HL,$CAEA                            ; stat region 2
    LD A,($DA14)
    CALL $260A
    LD BC,$0008
    LD A,$FF
    CALL $169A                             ; fill 8 bytes with $FF
    LD HL,$CAF2                            ; stat region 3
    LD A,($DA14)
    CALL $260A
    ; ... BC = $0019, A = $FF, CALL $169A → fill $19 bytes


; ============================================================================
; Bank20_Fn4  ($7BAC)  — Monster-species battle action router
; ============================================================================
; Reads $DA5E (wMonsterSpecies — current monster's species ID).
;   If == $FF → RET Z (no monster / empty slot)
; Compares ID against known species IDs and jumps to species handler:
;   $2B, $2C, $2D → $7BF4 (Slime-family: basic attack)
;   $2E, $2F     → $7C1B (Healer-type: heal/buff behavior)
;   $30, $31     → $7C9B (Golem-type: heavy attack)
;   $33          → $7CAD (special type)
;   $36          → $7BDA (another type)
;   ... continues for all monster species IDs
; Unknown species → default battle action.
;
; Species IDs $2B-$36 correspond to monster families encountered in
; the early game areas (Slimes, Skeletons, Golems, etc.).
Bank20_Fn4:                                 ; $7BAC
    LD A,($DA5E)                           ; wMonsterSpecies
    CP $FF
    RET Z                                  ; no monster → skip
    CP $2B
    JP Z,$7BF4                             ; Slime-type attack
    CP $2C
    JP Z,$7BF4
    CP $2D
    JP Z,$7BF4
    CP $2E
    JP Z,$7C1B                             ; Healer-type action
    CP $2F
    JP Z,$7C1B
    CP $30
    JP Z,$7C9B                             ; Golem-type attack
    CP $31
    JP Z,$7C9B
    CP $33
    JP Z,$7CAD                             ; special action
    ; ... continues for additional species


; ============================================================================
; Bank20_Sub_4849  ($4849)  — Indexed slot copy
; ============================================================================
; Copies data from DE (source buffer, e.g. $DA18) into the active
; monster slot in $CAC1.  Uses $DA14 as slot index, Sub_260A for ptr math.


; ============================================================================
; ROM DATA
; ============================================================================
; $260A  Sub_260A: HL = HL + A × $95 (monster slot pointer calculator)
;                  (bank20's local copy, same formula as bank22/Sub_41B1)
; $169A  ROM0 memset
;
; Monster array layout ($CAC1):
;   Slot 0: $CAC1..$CAC1+$94 (base + $00-$94)
;     $CAC1+$00: species byte (0 = free, 1+ = active)
;     $CAC1+$15: stat region 1 ($CAD6 relative)
;     $CAC1+$29: 8-byte stat block ($CAEA relative)
;     $CAC1+$31: $19-byte stat block ($CAF2 relative)
;   Slot N: $CAC1 + N × $95
