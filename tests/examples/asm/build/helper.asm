section .text
    global helper_function

helper_function:
    ; Print "This is a helper function."
    mov eax, 4
    mov ebx, 1
    mov ecx, helper_message
    mov edx, helper_message_len
    int 0x80

    ret

section .data
    helper_message db "This is a helper function.", 0x0A
    helper_message_len equ $ - helper_message

