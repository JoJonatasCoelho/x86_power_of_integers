; --------------------------------pow----------------------------------
; This program calculates the power of a integer base raised to an integer exponent.
; it can be positive or negative.
; It reads the base and exponent from the user, calculates the result,
; and prints the result to the console.
; It is written in x86-64 assembly language for Linux.
; --------------------------------===----------------------------------

segment .data
    LF equ 0xa ; Line fit
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

    FRAC db "1/", NULL
    LEN_FRAC equ $ - FRAC

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
    call _atoi
    mov R12, RAX ; Store base in R12

    mov RSI, MSG_EXP
    mov RDX, LEN_EXP
    call _print

    mov RSI, expo
    call _read_line
    call _atoi
    mov R13, RAX ; Store exponent in R13

    call _pow ; Store result in RAX
    mov R14, RAX
    mov R10, R15

    mov RSI, MSG_RES
    mov RDX, LEN_RES
    call _print

    cmp R10, 0x1 ; Check if exponent is negative
    je .negative_exponent

    mov RAX, R14 ; Move result to RAX for conversion
    mov RSI, res ; Prepare to write result
    call _itoa ; Convert result to string
    jmp .print_result

.negative_exponent:
    mov RSI, FRAC
    mov RDX, LEN_FRAC
    call _print ; Print "1/"

    mov RAX, R14 ; Move result to RAX for conversion
    mov RSI, res ; Prepare to write result
    call _itoa ; Convert result to string
    jmp .print_result

.print_result:
    mov RDX, 0x20 ; Get length of result string
    call _print ; Print the result
    jmp .exit ; Exit the program

.exit:
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
    xor R14, R14 ; Clear R14 for negative flag

.next_digit:
    cmp byte [RSI + RCX], '-'
    jne .digit_loop
    mov R14, 0x1
    inc RCX

.digit_loop:
    movzx RDX, byte [RSI + RCX]
    cmp RDX, NULL
    je .done
    sub RDX, '0'
    cmp RDX, 9
    ja .done
    imul RAX, RAX, 10
    add RAX, RDX
    inc RCX
    jmp .digit_loop

.done:
    cmp R14, 0 ; Check if negative flag is set
    jne .apply_negative
    ret

.apply_negative:
    neg RAX ; Negate the result if negative flag is set
    ret


; ---------------------
; Function: _pow
; Calculate base raised to the exponent
; Input: R12 = base, R13 = exponent
; Output: RAX = result
; ---------------------
_pow:
    mov RAX, 1 ; Initialize result to 1
    xor R15, R15 ; Clear R15 for negative exponent flag
    ; mov R11, R13 ; Copy exponent to R11 for manipulation
    test R13, R13 ; Check if exponent is zero
    jz .done ; If exponent is zero, return 1
    mov RCX, R13
    cmp RCX, 0x0 ; Check if exponent is negative
    jg .loop ; Jump to loop for exponentiation
    neg RCX ; Make exponent positive
    mov R15, 1 ; Set flag for negative exponent

.loop:
    imul RAX, R12 ; Multiply result by base
    dec RCX ; Decrement control variable
    jnz .loop ; Repeat until exponent is zero

    ; cmp R12, 0x0
    ; jge .done

    ; test R11, 0x1
    ; jz .done ; If exponent is even, we are done
    ; neg RAX ; If exponent is odd and base is negative, negate the result

.done:
    ret


; ---------------------
; Function: _itoa
; Convert integer to ASCII string
; Input: RAX = integer value, RSI = pointer to buffer
; Output: A string in the buffer pointed to by RSI
; ---------------------
_itoa:
    mov RDI, RSI ; Copy buffer pointer to RDI (will be our write pointer)
    mov RBX, 10  ; Divisor to extract digits
    xor RCX, RCX ; RCX will be our digit counter

    ; Handle the special case of the number being zero
    cmp RAX, 0
    jne .check_negative
    mov byte [RDI], '0' ; Write '0' to the buffer
    inc RDI
    mov byte [RDI], NULL ; Null-terminate the string
    ret

.check_negative:
    ; Check if the number is negative
    test RAX, RAX
    jns .division_loop ; If not negative, jump to the division loop

    ; If it's negative:
    mov byte [RDI], '-' ; Place the minus sign in the buffer
    inc RDI             ; Advance the write pointer
    neg RAX             ; Make the number in RAX positive for division

.division_loop:
    xor RDX, RDX  ; Zero out RDX, essential for the 64-bit DIV instruction
    div RBX       ; Divide RDX:RAX by RBX (10). Quotient in RAX, remainder in RDX.
    push RDX      ; Push the remainder (the digit) onto the stack
    inc RCX       ; Increment the digit counter
    test RAX, RAX ; Check if the quotient (RAX) is zero
    jnz .division_loop ; If not zero, continue the loop

.write_loop:
    ; Now, pop the digits and write them to the buffer in the correct order
    cmp RCX, 0
    je .done ; If the counter is zero, we are done

    pop RDX       ; Pop the digit from the stack
    add DL, '0'   ; Convert the digit (0-9) to its ASCII character ('0'-'9')
    mov [RDI], DL ; Write the character to the buffer
    inc RDI       ; Advance the write pointer
    dec RCX       ; Decrement the digit counter
    jmp .write_loop

.done:
    mov byte [RDI], NULL ; Add the null terminator to the end of the string
    ret
