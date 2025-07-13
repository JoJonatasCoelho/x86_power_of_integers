; --------------------------------pow----------------------------------
; This program calculates the power of a integer base raised to an integer exponent.
; it can be positive or negative.
; It reads the base and exponent from the user, calculates the result,
; and prints the result to the console.
; It is written in x86-64 assembly language for Linux.
; --------------------------------===----------------------------------

segment .data
    LF equ 0xa ; Line fit
 ;   SYS_CALL equ 0x80 ; Make a syscall
    NULL equ 0x0 ; End string
    SYS_EXIT equ 0x1 ; Syscall to finish the process
    SYS_WRITE equ 0x1 ; Write
    SYS_READ equ 0x0 ; Read
    RET_EXIT equ 0x0 ; Return value of the process
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
    base resb 0x10
    expo resb 0x10 ; 16 bytes for base and exponent
    res resb 0x20 ; 32 bytes for result

section .text
    global _start

_start:
    mov RSI, MSG_BASE
    mov RDX, LEN_BASE
    call _print

    mov RSI, base
    call _read_line

    mov RAX, 0x3C
    xor RDI, RDI
    syscall

; ---------------------
; Function: _print
; print a message to console
; Input: RSI = pointer, RDX = len
; ---------------------
_print:
    mov RAX, SYS_WRITE
    mov RDI, STD_OUT
    syscall
    ret

; ---------------------
; Function: _read_line
; read a line from input
; Input: RSI = pointer
; ---------------------
_read_line:
    mov RAX, SYS_READ
    mov RDI, STD_IN
    mov RDX, 0x10 ; 16 bytes
    syscall

    mov byte [RSI + RAX - 1], NULL
    ret

; ---------------------
; Function: _atoi
; Convert ASCII string to integer
; Input: RSI = pointer to string
; Output: RAX = integer value
; ---------------------
_atoi:
    xor RAX, RAX ; Clear RAX for result
    xor RCX, RCX ; Clear RCX for digit count
.next_digit:
    movzx RDX, byte [RSI + RCX] ; Load next byte
    cmp RDX, NULL ; Check for end of string
    je .done
    sub RDX, '0' ; Convert ASCII to integer
    cmp RDX, 0x9 ; Check if digit is valid
    jae .done ; If not a digit, stop
    imul RAX, RAX, 0xA ; Shift left by one decimal place
    add RAX, RDX ; Add the digit to the result
    inc RCX ; Move to next character
    jmp .next_digit
.done:
    ret