section .data
    counter_limit dd 20000
    fun_filename db 'counter_fun.txt', 0
    rec_filename db 'counter_rec.txt', 0
    newline db 10, 0
    number_buffer times 12 db 0

section .bss
    file_descriptor resd 1

section .text
    global _start

_start:
    call test_function_counter
    call test_recursive_counter
    
    mov eax, 1
    mov ebx, 0
    int 0x80

test_function_counter:
    push ebp
    mov ebp, esp
    
    mov eax, 5
    mov ebx, fun_filename
    mov ecx, 0x401
    mov edx, 0
    int 0x80
    mov [file_descriptor], eax
    
    push dword [counter_limit]
    call count
    add esp, 4
    
    call int_to_string
    
    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, number_buffer
    mov edx, 10
    int 0x80
    
    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80
    
    pop ebp
    ret

test_recursive_counter:
    push ebp
    mov ebp, esp
    
    mov eax, 5
    mov ebx, rec_filename
    mov ecx, 0x401
    mov edx, 0
    int 0x80
    mov [file_descriptor], eax
    
    push dword [counter_limit]
    call count_recursive
    add esp, 4
    
    call int_to_string
    
    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, number_buffer
    mov edx, 10
    int 0x80
    
    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80
    
    pop ebp
    ret

count:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov ecx, [ebp + 8]
    mov ebx, 0
    
count_loop:
    inc ebx
    cmp ebx, ecx
    jle count_loop
    
    mov eax, ecx
    
    pop ecx
    pop ebx
    pop ebp
    ret

count_recursive:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    
    cmp eax, 1
    jle recursive_base_case
    
    dec eax
    push eax
    call count_recursive
    add esp, 4
    
    mov eax, [ebp + 8]
    jmp recursive_end
    
recursive_base_case:
    mov eax, [ebp + 8]
    
recursive_end:
    pop ebp
    ret

int_to_string:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push edi
    
    mov edi, number_buffer + 10
    mov byte [edi], 0
    dec edi
    
    mov ebx, 10
    
convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    
    test eax, eax
    jnz convert_loop
    
    inc edi
    mov ecx, number_buffer
    
copy_loop:
    mov al, [edi]
    mov [ecx], al
    inc edi
    inc ecx
    test al, al
    jnz copy_loop
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret