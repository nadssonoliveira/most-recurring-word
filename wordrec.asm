extern printf
extern fgets
extern stdin

section .data
    msg_inp: db "Digite algo: ",0
    best_word: db "A palavra mais frequente eh: %s (count: %d)", 10,0

    tam equ 32
section .bss
    buffer: resb 256
    best: resb tam

section .text
    global main

prompt:
        ; Print input message
    mov rdi, msg_inp
    xor rax, rax
    call printf
    ret


read_input:
    ; Lê a entrada do usuário
    mov rdi, buffer
    mov rsi, 256
    mov rdx, [stdin]
    call fgets
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    call prompt ; chama a função para exibir o prompt
    call read_input ; Chama a função para ler a entrada



    ; usando RBX, R8 e R9 para maior segurança
    mov rbx, 0     ; Maior contagem
    mov r8, buffer ; Inicio da frase
    mov r9, buffer ; Melhor palavra

main_token_loop:
    cmp byte [r8], ' ' ; verifica espaço
    je skip
    cmp byte [r8], 10  ; verifica fim da linha 
    je done 
    cmp byte [r8], 0   ; verifica fim da string 
    je done

    ; Inicio da palavra
    mov r10, r8  ; ponteiro para o início da palavra
    xor rax, rax ; cont = 0

    mov r11, buffer

inner_loop:

    cmp byte [r11], ' '
    je inner_skip
    cmp byte [r11], 10
    je inner_end
    cmp byte [r11], 0
    je inner_end

    mov rsi, r10 ; palavra atual
    mov rdi, r11 ; palavra a comparar

compare:
    mov dl, [rsi]
    mov cl, [rdi]

    cmp dl, cl
    jne not_equal

    cmp dl, ' '
    je equal
    cmp dl, 10
    je equal
    cmp dl, 0
    je equal

    inc rsi
    inc rdi
    jmp compare

equal:
    inc rax ; incrementa contador

not_equal:
    ; pula para a próxima palavra
    cmp byte [r11], ' '
    je inner_skip
    cmp byte [r11], 10
    je inner_skip
    cmp byte [r11], 0
    je inner_skip

    inc r11
    jmp not_equal

inner_skip
    inc r11
    jmp inner_loop
inner_end:
    ; comparando contador atual com o maior
    cmp rax, rbx 
    jle count   ; se rax < rbx, pula

    mov rbx, rax ; atualiza maior contagem
    mov r9, r10  ; salva melhor palavra

count:
    ; Avança r8 até a próxima palavra
    cmp byte [r8], ' '
    je skip
    cmp byte [r8], 10
    je skip
    cmp byte [r8], 0
    je skip

    inc r8
    jmp count

skip:
    inc r8
    jmp main_token_loop
done:
    mov rsi, r9
    mov rdi, best

copy_word:
    mov al, [rsi]
    cmp al, ' '
    je done_copy
    cmp al, 10
    je done_copy
    cmp al, 0
    je done_copy

    mov [rdi], al
    inc rsi
    inc rdi
    jmp copy_word
done_copy:

    mov rdi, best_word
    mov rsi, best
    mov rdx, rbx
    xor rax, rax
    call printf

    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret
