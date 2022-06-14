.3ds
.arm

.create outfile,0

; Offset to jzState where exception address is stored
o_excaddr equ 8 << 2

.align 4
jz_hdr: ; in-header offset table

.word jz_stub - jz_hdr
.word jz_user_handler - jz_hdr
.word jz_ehandler - jz_hdr

.word jz_test - jz_hdr

.align 4

.function jz_stub ; r0 = jzState*, r1 = JPC, r2 = handler, r3 = userdata
    ; Save AAPCS regs
    PUSH {r4 - r12, LR}
    
    MOV r9, r0  ; Save state ptr to reg
    MOV LR, r1  ; Set JPC
    MOV r10, r2 ; Save handler ptr
    MOV r11, r3 ; Save userdata ptr
    
    LDMIA r9, {r0 - r7} ; Load Jazelle state from jzState
    MOV r8, #0 ; Debug const ptr???
    
    ADD r12, PC, (fail_bxj - . - 8) ; Set "fallback" Jazelle handler to fail
    .dcd 0xE12FFF20 + 12; BXJ r12
    
  fail_bxj:
    MVN r0, #0 ; Unable to enter Jazelle state for some reason (-1)
    
  skip_bxj:
    ; it's the handler's job to store the regs in r9
    ;STMIA r9, {r0 - r7}
    
    ; Load AAPCS regs
    POP {r4 - r12, PC}
.endfunc


.function jz_user_handler
    STMIA r9, {r0 - r7} ; Save Jazelle state (faster to save r0-r3 than to skip saving them unnecessarily)
    
    PUSH {r8 - r12, LR} ; AAPCS Thumb save
    ; AAPCS saves rest in callee
    
    MOV r0, r9  ; jzState
    MOV r1, LR  ; JPC
    MOV r2, r11 ; userdata
    MOV r3, r12 ; JumpID (corrupted by Jazelle)
    BLX r10
    
    ; APPCS restores rest in callee
    POP {r8 - r12, LR} ; AAPCS Thumb restore
    
    CMP r0, #0 ; Check valid return ptr
    
    MOVNE LR, r0 ; Set JPC to valid ptr
    LDMNEIA r9, {r0 - r7} ; LDMIANE, restore Jazelle state if valid ptr
    SUBNE r12, PC, (. - fail_bxj + 8)
    .dcd 0x112FFF20 + 12 ; BXJNE r12
    
    B skip_bxj ; Return from Jazelle state back to C on invalid ptr
.endfunc

.function jz_ehandler
    STMIA r9, {r0 - r7}     ; Save Jazelle state back to jzState
    STR LR, [r9, o_excaddr] ; Store error address
    ADD r0, r12, #1         ; Set exception code from JumpID (corrupted by Jazelle)
    B skip_bxj              ; Return from Jazelle back to C
.endfunc

jz_test:
    
    .byte 0x12, 2          ; 00: ldc #2
    .byte 0x3C             ; 02: istore_1
    .byte 0x1B             ; 03: iload_1
    .byte 0x99, 0x00, 0x09 ; 04: ifeq 0D (+9h)
    .byte 0x84, 0x01, 0xFF ; 07: iinc #1, -1
    .byte 0xA7, 0xFF, 0xF9 ; 0A: goto 03 (-7h)
    .byte 0xB1             ; 0D: return

.close
