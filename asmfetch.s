section .data
    version_file db "/proc/version", 0   ; Path to kernel version info
    cpuinfo_file db "/proc/cpuinfo", 0   ; Path to CPU info
    meminfo_file db "/proc/meminfo", 0   ; Path to memory info
    uptime_file db "/proc/uptime", 0     ; Path to uptime info
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

    ; === Fetch and Display Kernel Version ===
    ; call fetch_kernel_version

    ; === Fetch and Display CPU Info ===
    ; call fetch_cpu_info

    ; === Fetch and Display Memory Info ===
    ; call fetch_memory_info

    ; === Fetch and Display Uptime Info ===
    ; call fetch_uptime_info

    ; Exit Program
    mov eax, 1                ; sys_exit
    xor ebx, ebx              ; Exit status 0
    int 0x80

fetch_kernel_version:
    ; Open /proc/version
    mov eax, 5                ; sys_open
    mov ebx, version_file     ; File path
    mov ecx, 0                ; Flags: O_RDONLY
    int 0x80
    mov [fd], eax             ; Save file descriptor

    ; Read from file
    mov eax, 3                ; sys_read
    mov ebx, [fd]             ; File descriptor
    mov ecx, buf              ; Buffer to store data
    mov edx, 1024             ; Read up to 1KB
    int 0x80

    ; Write to stdout
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, buf              ; Buffer to print
    mov edx, eax              ; Use number of bytes read
    int 0x80

    ; Close file
    mov eax, 6                ; sys_close
    mov ebx, [fd]             ; File descriptor
    int 0x80
    ret

fetch_cpu_info:
    ; Open /proc/cpuinfo
    mov eax, 5                ; sys_open
    mov ebx, cpuinfo_file     ; File path
    mov ecx, 0                ; Flags: O_RDONLY
    int 0x80
    mov [fd], eax             ; Save file descriptor

    ; Read from file
    mov eax, 3                ; sys_read
    mov ebx, [fd]             ; File descriptor
    mov ecx, buf              ; Buffer to store data
    mov edx, 1024             ; Read up to 1KB
    int 0x80

    ; Write to stdout
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, buf              ; Buffer to print
    mov edx, eax              ; Use number of bytes read
    int 0x80

    ; Close file
    mov eax, 6                ; sys_close
    mov ebx, [fd]             ; File descriptor
    int 0x80
    ret

fetch_memory_info:
    ; Open /proc/meminfo
    mov eax, 5                ; sys_open
    mov ebx, meminfo_file     ; File path
    mov ecx, 0                ; Flags: O_RDONLY
    int 0x80
    mov [fd], eax             ; Save file descriptor

    ; Read from file
    mov eax, 3                ; sys_read
    mov ebx, [fd]             ; File descriptor
    mov ecx, buf              ; Buffer to store data
    mov edx, 1024             ; Read up to 1KB
    int 0x80

    ; Write to stdout
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, buf              ; Buffer to print
    mov edx, eax              ; Use number of bytes read
    int 0x80

    ; Close file
    mov eax, 6                ; sys_close
    mov ebx, [fd]             ; File descriptor
    int 0x80
    ret

fetch_uptime_info:
    ; Open /proc/uptime
    mov eax, 5                ; sys_open
    mov ebx, uptime_file      ; File path
    mov ecx, 0                ; Flags: O_RDONLY
    int 0x80
    mov [fd], eax             ; Save file descriptor

    ; Read from file
    mov eax, 3                ; sys_read
    mov ebx, [fd]             ; File descriptor
    mov ecx, buf              ; Buffer to store data
    mov edx, 1024             ; Read up to 1KB
    int 0x80

    ; Write to stdout
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, buf              ; Buffer to print
    mov edx, eax              ; Use number of bytes read
    int 0x80

    ; Close file
    mov eax, 6                ; sys_close
    mov ebx, [fd]             ; File descriptor
    int 0x80
    ret