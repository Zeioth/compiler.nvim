section .data
    hello db 'Hello, World!',0

section .text
    global print_hello

print_hello:
    ; Write the message to stdout
    mov eax, 1                  ; Syscall number for write
    mov edi, 1                  ; File descriptor 1: stdout
    mov rsi, hello              ; Address of the string
    mov edx, 13                 ; Length of the string
    syscall

    ret

