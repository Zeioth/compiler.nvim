section .text
    global _start

_start:
    ; Print "Hello, World!"
    mov eax, 4
    mov ebx, 1
    mov ecx, message
    mov edx, message_len
    int 0x80

    ; Call helper function
    call helper_function

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
    message db "Hello, World!", 0x0A
    message_len equ $ - message

