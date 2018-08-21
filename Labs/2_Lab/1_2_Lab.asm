;Lab2_1.asm-Indirect Addressing Practice
;Garret M. Gwozdz

SECTION .data
    msg  db 'Hello World!', 10, 0, 0

SECTION .text
    global _start
_start:
    mov RAX, $
    mov RBX, [$]
    lea RCX, $

    mov RAX, msg
    mov RBX, [msg]
    mov RCX, msg

    mov R9, msg
    mov R10, [msg]
