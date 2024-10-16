; Fixed system fetch utility
; Compile with: nasm -f elf64 asmfetch.asm
; Link with: ld asmfetch.o -o asmfetch

section .data
    ; ASCII art
    ascii_art:
        db "    .--.   ", 10
        db "   |o_o |  ", 10
        db "   |:_/ |  ", 10
        db "  //   \ \ ", 10
        db " (|     | )", 10
        db "/'\_   _/`\", 10
        db "\___)=(___/", 10, 0
    ascii_art_len equ $ - ascii_art

    ; Messages
    os_msg db "OS: ", 0
    os_msg_len equ $ - os_msg
    
    kernel_msg db "Kernel: ", 0
    kernel_msg_len equ $ - kernel_msg
    
    cpu_msg db "CPU: ", 0
    cpu_msg_len equ $ - cpu_msg
    
    ram_msg db "RAM: ", 0
    ram_msg_len equ $ - ram_msg
    
    newline db 10, 0
    separator db "-----------------", 10, 0
    separator_len equ $ - separator

    ; File paths
    cpuinfo_path db "/proc/cpuinfo", 0
    meminfo_path db "/proc/meminfo", 0

section .bss
    hostname resb 64
    buffer resb 4096
    uname_buf resb 65

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

    ; Get hostname
    mov rax, 65         ; sys_gethostname
    mov rdi, hostname
    mov rsi, 64
    syscall

    ; Print OS message
    mov rax, 1
    mov rdi, 1
    mov rsi, os_msg
    mov rdx, os_msg_len
    syscall

    ; Print hostname
    mov rax, 1
    mov rdi, 1
    mov rsi, hostname
    mov rdx, 64
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Print CPU info message
    mov rax, 1
    mov rdi, 1
    mov rsi, cpu_msg
    mov rdx, cpu_msg_len
    syscall

    ; Open /proc/cpuinfo
    mov rax, 2          ; sys_open
    mov rdi, cpuinfo_path
    mov rsi, 0          ; O_RDONLY
    mov rdx, 0
    syscall

    ; Read CPU info
    mov rdi, rax        ; file descriptor
    mov rax, 0          ; sys_read
    mov rsi, buffer
    mov rdx, 4096
    syscall

    ; Close CPU info file
    mov rax, 3          ; sys_close
    syscall

    ; Find the model name line
    mov rsi, buffer
    mov rdi, buffer
    call find_model_name
    
    ; Print CPU model
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    call strlen
    mov rdx, rax
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; Find CPU model name in /proc/cpuinfo
find_model_name:
    mov rcx, 4096       ; maximum length to search
.loop:
    cmp byte [rsi], 0
    je .done
    
    ; Check if current line starts with "model name"
    cmp dword [rsi], 0x646F6D    ; "mod"
    jne .next_line
    
    cmp dword [rsi + 4], 0x6C65  ; "el "
    jne .next_line
    
    ; Found model name line, skip to ":"
.find_colon:
    inc rsi
    cmp byte [rsi], ':'
    jne .find_colon
    
    ; Skip ": " and copy the rest to buffer
    add rsi, 2
    mov rdi, buffer
.copy_model:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    cmp al, 10          ; newline
    je .terminate
    jmp .copy_model

.next_line:
    inc rsi
    dec rcx
    jnz .loop

.terminate:
    mov byte [rdi - 1], 0    ; null terminate
.done:
    ret

; Calculate string length
strlen:
    push rdi
    mov rdi, rsi
    xor rcx, rcx
    not rcx
    xor al, al
    cld
    repne scasb
    not rcx
    dec rcx
    mov rax, rcx
    pop rdi
    ret