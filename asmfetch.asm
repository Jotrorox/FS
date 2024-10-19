section .data
    ; ANSI escape codes
    esc db 0x1B, '[', 0
    reset db 0x1B, '[0m', 0
    bold db 0x1B, '[1m', 0
    red db 0x1B, '[31m', 0
    green db 0x1B, '[32m', 0
    yellow db 0x1B, '[33m', 0
    blue db 0x1B, '[34m', 0
    magenta db 0x1B, '[35m', 0
    cyan db 0x1B, '[36m', 0
    white db 0x1B, '[37m', 0

    ; ASCII art with text
    ascii_art:
        db "           " 10
        db "    .--.   ", 10
        db "   |o_o |  ", 0x1B, '[1m', "                 ASMFetch", 0x1B, '[0m', 10
        db "   |:_/ |  ", 10
        db "  //   \ \ ", 0x1B, '[32m', "  A simple fetch program written in asm", 0x1B, '[0m', 10
        db " (|     | )", 0x1B, '[33m', "               - by Jotrorox", 0x1B, '[0m', 10
        db "/'\_   _/`\", 10
        db "\___)=(___/", 10
        db "           ", 10, 0
    ascii_art_len equ $ - ascii_art

    ; Messages
    username_msg db 0x1B, '[34m', "Username: ", 0x1B, '[0m', 0
    username_msg_len equ $ - username_msg

    hostname_msg db 0x1B, '[34m', "Hostname: ", 0x1B, '[0m', 0
    hostname_msg_len equ $ - hostname_msg

    newline db 10
    separator db 0x1B, '[34m', "-----------------", 0x1B, '[0m', 10
    separator_len equ $ - separator

    ; Commands
    whoami_cmd db "/usr/bin/whoami", 0
    hostname_cmd db "/bin/hostname", 0

section .bss
    buffer resb 4096
    cpu_buffer resb 1024
    hostname resb 64

section .text
    global _start

_start:
    ; Print ASCII art
    mov rdi, ascii_art
    mov rsi, ascii_art_len
    call print_string

    ; Print separator
    mov rdi, separator
    mov rsi, separator_len
    call print_string

    ; Print username
    mov rdi, username_msg
    mov rsi, username_msg_len
    call print_string

    mov rdi, whoami_cmd
    call execute_command

    ; Print hostname
    mov rdi, hostname_msg
    mov rsi, hostname_msg_len
    call print_string

    mov rdi, hostname_cmd
    call execute_command

    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; Function to print a string
print_string:
    ; rdi = string address
    ; rsi = string length
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 1          ; sys_write
    mov rdx, rsi        ; length
    mov rsi, rdi        ; string address
    mov rdi, 1          ; stdout
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; Function to execute a command
execute_command:
    ; rdi = command address
    push rax
    push rsi
    push rdx
    
    mov rax, 57         ; sys_fork
    syscall
    
    cmp rax, 0
    jz .child_process   ; If we're the child process
    
    ; Parent process waits for child
    push rdi
    mov rdi, rax        ; PID to wait for
    mov rax, 61         ; sys_wait4
    syscall
    pop rdi
    
    pop rdx
    pop rsi
    pop rax
    ret

.child_process:
    mov rax, 59         ; sys_execve
    ; rdi already contains command address
    xor rsi, rsi        ; no arguments
    xor rdx, rdx        ; no environment variables
    syscall
    
    ; Exit child (only reaches here if execve fails)
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; error status
    syscall