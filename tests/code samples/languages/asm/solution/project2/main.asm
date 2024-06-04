section .data
    extern hello

section .text
    extern print_hello

global _start

_start:
    ; Call the print_hello function
    call print_hello

    ; Exit the program
    mov eax, 60                 ; Syscall number for exit
    xor edi, edi                ; Exit status 0
    syscall

