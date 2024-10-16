section .data
    logo db "ASMFetch", 0xA, 0xA, 0     ; ASCII logo text
    divider db "--------------------", 0xA, 0 ; Divider line

section .bss
    fd resb 4                ; File descriptor for opened files
    buf resb 1024            ; Buffer for storing file contents (1KB)

section .text
    global _start

_start:
    ; === Display ASCII Art and Divider ===
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, logo             ; ASCII logo text
    mov edx, 11               ; Length of "ASMFetch" + newline
    int 0x80

    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, divider          ; Divider line
    mov edx, 22               ; Length of divider + newline
    int 0x80

    ; Exit Program
    mov eax, 1                ; sys_exit
    xor ebx, ebx              ; Exit status 0
    int 0x80

