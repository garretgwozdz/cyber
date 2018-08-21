SECTION .text
global _start
global callTest

_start:
    mov rax, rsp
    mov rbp, rsp
    push 0x01
    push 0x02
    push 0x03
    mov rcx, rsp
    mov rdx, rbp
    pop r8
    pop r9
    pop r10
    mov rsi, rsp
    mov rdi, rbp
    call callTest

callTest:
    push rbp
    mov rbp, rsp
    mov rax, rsp
    push rbp
    push 0x01
    push 0x02
    push 0x03
    mov rcx, rsp
    mov rdx, rbp
    pop r8
    pop r9
    pop r10
    mov rsi, rsp
    mov rdi, rbp
    leave
    ret
