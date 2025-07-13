segment .data
    LF equ 0xa ; Line fit
 ;   SYS_CALL equ 0x80 ; Make a syscall
    NULL equ 0x0 ; End string
    SYS_EXIT equ 0x1 ; Syscall to finish the process
    SYS_WRITE equ 0x1 ; Write
    SYS_READ equ 0x3 ; Read
    RET_EXiT equ 0x0 ; Return value of the process
    STD_OUT equ 0x1 ; Standard output, console
    STD_IN equ 0x0 ; Standard input

section .data
    MSG_BASE db "Type the base: ", NULL
    LEN_BASE equ $ - MSG_BASE

    MSG_EXP db "Type the expoent: ", NULL
    LEN_EXP equ $ - MSG_EXP

    MSG_RES db "Result: ", NULL
    LEN_RES equ $ - MSG_RES

section .bss
    base resb 16
    expo resb 16
    res resb 32

section .text
    global _start

_start:
    mov RSI, MSG_BASE
    mov RDX, LEN_BASE
    call print

    mov RAX, 0x3C
    xor RDI, RDI
    syscall

; ---------------------
; Function: print
; print a message to console
; Input: RSI = pointer, RDX = len
; ---------------------
print:
    mov RAX, SYS_WRITE
    mov RDI, STD_OUT
    syscall
    ret

