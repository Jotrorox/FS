; Fixed system fetch utility with proper system info reading
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
    os_msg db "OS: Linux ", 0
    os_msg_len equ $ - os_msg
    
    kernel_msg db "Kernel: ", 0
    kernel_msg_len equ $ - kernel_msg
    
    cpu_msg db "CPU: ", 0
    cpu_msg_len equ $ - cpu_msg
    
    model_name db "model name", 0
    model_name_len equ $ - model_name
    
    newline db 10
    separator db "-----------------", 10
    separator_len equ $ - separator

    ; File paths
    cpuinfo_path db "/proc/cpuinfo", 0

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
    call get_string_length
    mov rdx, rax
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Print CPU message
    mov rax, 1
    mov rdi, 1
    mov rsi, cpu_msg
    mov rdx, cpu_msg_len
    syscall

    ; Get CPU info
    call get_cpu_info

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

; Function to get CPU info
get_cpu_info:
    ; Open /proc/cpuinfo
    mov rax, 2          ; sys_open
    mov rdi, cpuinfo_path
    mov rsi, 0          ; O_RDONLY
    mov rdx, 0
    syscall

    ; Check for error
    cmp rax, 0
    jl .error

    ; Save file descriptor
    mov r8, rax

    ; Read file content
    mov rax, 0          ; sys_read
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 4096
    syscall

    ; Close file
    push rax            ; save number of bytes read
    mov rax, 3          ; sys_close
    mov rdi, r8
    syscall
    pop rax

    ; Find CPU model name
    mov rdi, buffer     ; source buffer
    mov rsi, cpu_buffer ; destination buffer
    call find_cpu_model

    ; Print CPU model
    mov rax, 1
    mov rdi, 1
    mov rsi, cpu_buffer
    call get_string_length
    mov rdx, rax
    syscall

    ret

.error:
    ; Handle error (just return for now)
    ret

; Function to find CPU model name in buffer
find_cpu_model:
    push rbx
    mov rbx, rdi        ; save buffer address
    xor rcx, rcx        ; counter

.search_loop:
    ; Check for end of buffer
    cmp byte [rbx + rcx], 0
    je .not_found

    ; Check if current position matches "model name"
    mov rdi, rbx
    add rdi, rcx
    mov rsi, model_name
    mov rdx, model_name_len
    call compare_strings
    test rax, rax
    jz .found_model

    inc rcx
    jmp .search_loop

.found_model:
    ; Skip to ':'
    add rcx, model_name_len
.find_colon:
    cmp byte [rbx + rcx], ':'
    je .copy_value
    inc rcx
    jmp .find_colon

.copy_value:
    ; Skip ':' and spaces
    inc rcx
    cmp byte [rbx + rcx], ' '
    je .copy_value

    ; Copy value to cpu_buffer
    mov rdi, cpu_buffer
.copy_loop:
    mov al, [rbx + rcx]
    cmp al, 10          ; newline
    je .done
    mov [rdi], al
    inc rcx
    inc rdi
    jmp .copy_loop

.done:
    mov byte [rdi], 0   ; null terminate
    pop rbx
    ret

.not_found:
    mov byte [cpu_buffer], 0
    pop rbx
    ret

; Function to compare strings
compare_strings:
    push rcx
    push rsi
    push rdi
    mov rcx, rdx
    repe cmpsb
    setz al
    movzx rax, al
    pop rdi
    pop rsi
    pop rcx
    ret

; Function to get string length
get_string_length:
    push rcx
    push rdi
    mov rdi, rsi
    xor rcx, rcx
.loop:
    cmp byte [rdi], 0
    je .done
    inc rcx
    inc rdi
    jmp .loop
.done:
    mov rax, rcx
    pop rdi
    pop rcx
    ret