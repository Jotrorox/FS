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
    
    newline db 10
    separator db 0x1B, '[34m', "-----------------", 0x1B, '[0m', 10
    separator_len equ $ - separator

section .bss
    buffer resb 4096
    cpu_buffer resb 1024
    hostname resb 64

section .text
    global _start

_start:
    ; Print ASCII art
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, ascii_art
    mov rdx, ascii_art_len
    syscall

    ; Print separator
    mov rax, 1
    mov rdi, 1
    mov rsi, separator
    mov rdx, separator_len
    syscall

    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall