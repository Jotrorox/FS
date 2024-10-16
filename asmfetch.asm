; Simple system fetch utility
; Compile with: nasm -f elf64 sysfetch.asm
; Link with: ld sysfetch.o -o sysfetch
; Run with: ./sysfetch

section .data
    hostname_msg db "Hostname: ", 0
    kernel_msg db "Kernel: ", 0
    newline db 10, 0
    hostname_cmd db "/bin/hostname", 0
    uname_cmd db "/bin/uname", 0
    uname_arg db "-r", 0
    buffer times 1024 db 0

section .text
    global _start

_start:
    ; Print hostname message
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, hostname_msg
    mov rdx, 10         ; length
    syscall

    ; Get hostname using syscall
    mov rax, 1          ; sys_write
    mov rdi, buffer
    mov rsi, 64         ; max length
    mov rax, 65         ; sys_gethostname
    syscall

    ; Print hostname
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, buffer
    mov rdx, 64         ; length
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Print kernel message
    mov rax, 1
    mov rdi, 1
    mov rsi, kernel_msg
    mov rdx, 8
    syscall

    ; Fork process for uname
    mov rax, 57         ; sys_fork
    syscall

    cmp rax, 0
    je child
    jmp parent

child:
    ; Execute uname -r
    mov rax, 59         ; sys_execve
    mov rdi, uname_cmd
    push 0              ; NULL terminate argv[]
    push uname_arg
    push uname_cmd
    mov rsi, rsp        ; argv
    xor rdx, rdx        ; envp = NULL
    syscall
    
    ; Exit child
    mov rax, 60
    xor rdi, rdi
    syscall

parent:
    ; Wait for child
    mov rax, 61         ; sys_wait4
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Exit program
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status = 0
    syscall