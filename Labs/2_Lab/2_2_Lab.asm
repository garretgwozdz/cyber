;Lab2_2.asm-Indirect Addressing Practice
;Garret M. Gwozdz

SECTION .data
    msg  db 'Hello!', 10, 0, 0

SECTION .text
    global _start
_start:
    mov RAX, $
    mov RAX, [rel $]
    mov RCX, $
    mov RAX, msg
    mov RAX, [rel msg]
    mov RCX, msg
    mov R9, msg
    mov R10, [rel msg]
