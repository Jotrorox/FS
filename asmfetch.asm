; Enhanced system fetch utility with ASCII art and colors
; Compile with: nasm -f elf64 sysfetch.asm
; Link with: ld sysfetch.o -o sysfetch
; Run with: ./sysfetch

section .data
    ; ANSI color codes
    color_reset db 27, "[0m", 0
    color_blue db 27, "[34m", 0
    color_green db 27, "[32m", 0
    color_yellow db 27, "[33m", 0
    
    ; ASCII art (penguin)
    ascii_art db 27, "[33m",  "    .--.   ", 10
             db "   |o_o |  ", 10
             db "   |:_/ |  ", 10
             db "  //   \ \ ", 10
             db " (|     | )", 10
             db "/'\_   _/`\", 10
             db "\___)=(___/", 10, 27, "[0m", 0
             
    ; Messages
    title_fmt db 27, "[1;34m%s@%s", 27, "[0m", 10, 0
    separator db 27, "[34m", "-----------------", 27, "[0m", 10, 0
    hostname_fmt db 27, "[32mOS: ", 27, "[0m%s", 10, 0
    kernel_fmt db 27, "[32mKernel: ", 27, "[0m%s", 0
    cpu_msg db 27, "[32mCPU: ", 27, "[0m", 0
    mem_msg db 27, "[32mMemory: ", 27, "[0m", 0
    uptime_msg db 27, "[32mUptime: ", 27, "[0m", 0
    shell_msg db 27, "[32mShell: ", 27, "[0m", 0
    
    ; File paths
    cpuinfo_path db "/proc/cpuinfo", 0
    meminfo_path db "/proc/meminfo", 0
    uptime_path db "/proc/uptime", 0
    
    ; Buffers
    buffer times 4096 db 0
    hostname_buf times 64 db 0
    username_buf times 64 db 0
    
section .bss
    fd_out resq 1
    stat_buf resb 144
    
section .text
    global _start
    
_start:
    ; Print ASCII art
    mov rax, 1
    mov rdi, 1
    mov rsi, ascii_art
    mov rdx, 150
    syscall
    
    ; Get username (from env or getuid)
    mov rax, 102        ; sys_getuid
    syscall
    
    ; Get hostname
    mov rax, 65         ; sys_gethostname
    mov rdi, hostname_buf
    mov rsi, 64
    syscall
    
    ; Print title (username@hostname)
    mov rdi, title_fmt
    mov rsi, username_buf
    mov rdx, hostname_buf
    call printf
    
    ; Print separator
    mov rdi, separator
    call printf
    
    ; Read and print CPU info
    mov rdi, cpu_msg
    call printf
    
    ; Open /proc/cpuinfo
    mov rax, 2          ; sys_open
    mov rdi, cpuinfo_path
    xor rsi, rsi        ; O_RDONLY
    syscall
    
    ; Read CPU model name
    mov rdi, rax
    mov rsi, buffer
    mov rdx, 4096
    call read_until_newline
    
    ; Print CPU info
    mov rdi, buffer
    call printf
    mov rdi, 10
    call putchar
    
    ; Read and print memory info
    mov rdi, mem_msg
    call printf
    
    ; Open /proc/meminfo
    mov rax, 2
    mov rdi, meminfo_path
    xor rsi, rsi
    syscall
    
    ; Read memory info
    mov rdi, rax
    mov rsi, buffer
    mov rdx, 4096
    call read_until_newline
    
    ; Print memory info
    mov rdi, buffer
    call printf
    mov rdi, 10
    call putchar
    
    ; Get and print kernel version
    mov rdi, kernel_fmt
    call printf
    
    mov rax, 59         ; sys_uname
    mov rdi, buffer
    syscall
    
    mov rdi, buffer
    call printf
    mov rdi, 10
    call putchar
    
    ; Print shell info
    mov rdi, shell_msg
    call printf
    
    ; Get SHELL environment variable
    mov rax, 119        ; sys_getenv
    mov rdi, "SHELL"
    syscall
    
    mov rdi, rax
    call printf
    mov rdi, 10
    call putchar
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; Helper functions
read_until_newline:
    push rbp
    mov rbp, rsp
    
    ; Save registers
    push rbx
    push r12
    push r13
    
    mov rbx, rdi        ; fd
    mov r12, rsi        ; buffer
    mov r13, rdx        ; max length
    
    xor rcx, rcx        ; byte counter
    
.read_loop:
    mov rax, 0          ; sys_read
    mov rdi, rbx
    lea rsi, [r12 + rcx]
    mov rdx, 1
    syscall
    
    test rax, rax
    jle .done
    
    movzx eax, byte [r12 + rcx]
    inc rcx
    
    cmp al, 10          ; newline
    je .done
    
    cmp rcx, r13
    jl .read_loop
    
.done:
    mov byte [r12 + rcx], 0    ; null terminate
    
    ; Restore registers
    pop r13
    pop r12
    pop rbx
    
    mov rsp, rbp
    pop rbp
    ret

printf:
    ; Simple printf implementation
    push rbp
    mov rbp, rsp
    
    mov rax, 1          ; sys_write
    mov rsi, rdi        ; string
    mov rdi, 1          ; stdout
    
    ; Calculate string length
    push rsi
    xor rdx, rdx
.strlen_loop:
    cmp byte [rsi], 0
    je .strlen_done
    inc rsi
    inc rdx
    jmp .strlen_loop
.strlen_done:
    pop rsi
    
    syscall
    
    mov rsp, rbp
    pop rbp
    ret

putchar:
    push rbp
    mov rbp, rsp
    
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    
    mov rsp, rbp
    pop rbp
    ret