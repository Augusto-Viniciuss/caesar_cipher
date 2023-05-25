;Aluno: Augusto Vinicius Ferreira de Sales

extern printf, scanf
global main

section .bss
  ;Variavel para salvar o valor da opção selecionada no menu
  menu_option: resb 1
  ;Variavel para salver o valor da chave de criptografia ou decriptografia
  key: resb 5
  ;Variavel para armazenar o nome do arquivo de entrada
  input_filename: resb 20
  ;Variavel para armazenar o nome do arquivo de saida
  output_filename: resb 20
  ;Buffer para armazenar, manipular e depois salvar os dados lidos do arquivo de entrada
  buffer: resb 512
  ;Variavel para armazenar o apontador para o arquivo de entrada
  input_file_handle: resd 1
  ;Variavel para armazenar o apontador para o arquivo de saida
  output_file_handle: resd 1

section .data
  ;Variaveis destinadas a armazenar texto que serão impressos no terminal através do printf
  printf_menu_text: db 0AH, 09H, "Caesar Cipher", 0AH, 09H, "    Menu", 0AH, 0AH,  09H, "[1] Encrypt", 0AH, 09H, "[2] Decrypt", 0AH, 09H, "[0] Exit", 0AH, 0AH, 0H
  printf_invalid_opp_txt: db 09H, "Invalid option!", 0AH, 0H
  printf_in_filename_txt: db 09H, "Input filename:", 0AH, 0H
  printf_out_filename_txt: db 09H, "Output filename:", 0AH, 0H
  printf_key_txt: db 09H, "Key:", 0AH, 0H

  ;Variaveis destinadas a armazenar o especificador de formato para leituras no terminal utilizando scanf
  scanf_frt_read_int: db "%d", 0H
  scanf_frt_read_str: db "%s", 0H

section .text
;Exibe o texto de "Invalid option!" no terminal
_invalid_menu_option:
  push printf_invalid_opp_txt
  call printf
  add esp, 8

main:
  ;Exibição do texto do menu
  push printf_menu_text
  call printf
  add esp, 8

;Label responsável por ler a opção do menu
_read_option_menu:
  push menu_option
  push scanf_frt_read_int
  call scanf
  add esp, 12
  ;Verifica se o usuario selecionou a opção sair no programa ou se ele digitou uma opção invalida menor do que 0
  cmp BYTE[menu_option], 0
  jl _invalid_menu_option
  je _exit
  ;Verifica se o usuario selecionou uma opção invalida maior do que 2
  cmp BYTE[menu_option], 2
  jg _invalid_menu_option

_read_filenames_and_key:
  ;Leitura do nome do arquivo que contém a entrada de dados
  push printf_in_filename_txt
  call printf
  add esp, 8
  push input_filename
  push scanf_frt_read_str
  call scanf
  add esp, 12

  ;Leitura do nome do arquivo onde será salvo a saida do programa
  push printf_out_filename_txt
  call printf
  add esp, 8
  push output_filename
  push scanf_frt_read_str
  call scanf
  add esp, 12

  ;Leitura da chave para criptografia ou descriptografia
  push printf_key_txt
  call printf
  add esp, 8
  push key
  push scanf_frt_read_int
  call scanf
  add esp, 12
  
;Abertura do arquivo de entrada de dados
_open_input_file:
  mov eax, 5
  mov ebx, input_filename
  mov ecx, 0
  mov edx, 0o777
  int 80H
  mov [input_file_handle], eax

;Criação e abertura do arquivo de saida de dados
_create_and_open_output_file:
  mov eax, 8
  mov ebx, output_filename
  mov ecx, 0o777
  int 80H
  mov [output_file_handle], eax

;Leitura do arquivo de entrada de dados para salvar no buffer de 512 bytes
_read_input_file:
  mov eax, 3
  mov ebx, [input_file_handle]
  mov ecx, buffer
  mov edx, 512
  int 80H

  ;Se a quantidade de bytes lidos forem 0 é dado um jump para o label que irá conter a lógica para fechar o arquivo de saida pois isso significa que todo o conteudo do arquivo de entrada foi tratado
  cmp eax, 0
  je _close_files

  ;Coloca os parametros na pilha para depois dependendo da opção selecionada no menu chamar a função ou de encriptografar ou decriptografar
  push DWORD [key]
  push DWORD eax
  push DWORD buffer
  ;Verifica se foi selecionado a opção de encriptografar ou decriptografar
  cmp BYTE [menu_option], 1
  je _call_encrypt
  jne _call_decrypt

;Chama a função correta de encriptografar e logo depois da um jump para o laber que salva no arquivo de saida
_call_encrypt:
  call _encrypt_
  jmp _write_output_file

;Chama a função de decriptografar não precisa dar jump pois o próximo label já é o de salvar no arquivo de saida
_call_decrypt:
  call _decrypt_

;Escrita do conteudo do buffer no arquivo de saida do programa
_write_output_file:
  mov edx, eax
  mov eax, 4
  mov ebx, [output_file_handle]
  mov ecx, buffer
  int 80H
  jmp _read_input_file

;Fecha os arquivos de entrada e saida de dados
_close_files:
  mov eax, 6
  mov ebx, [input_file_handle]
  int 80H

  mov eax, 6
  mov ebx, [output_file_handle]
  int 80H
  
  ;Ao fechar os arquivos é dado um jump para o label main que faz com o que o programa volte ao primeiro estado que é a apresentação do menu principal e com isso o programa pode ser executado novamente após um execução
  jmp main

;Função de encriptografar
_encrypt_:
  push ebp
  mov ebp, esp
  sub esp, 8
  
  ;Armazena o valor da chave no registrador ebx
  mov ebx, DWORD [ebp+16]
  ;Zera o contador que será usado para percorrer o buffer
  xor ecx, ecx
  ;Armazena o endereço do buffer no registador edx
  mov edx, DWORD [ebp+8] 
  
  ;Loop para percorrer o buffer e incrementar o valor da chave em cada byte do buffer
  _loop_encrypt:
    add DWORD [edx + ecx], ebx
    inc ecx
    cmp ecx, DWORD [ebp+12]
    jl _loop_encrypt

  mov esp, ebp
  pop ebp
  ret 4

;Função de decriptografar
_decrypt_:
  push ebp
  mov ebp, esp
  sub esp, 8

  ;Armazena o valor da chave no registrador ebx
  mov ebx, DWORD [ebp+16]
  ;Zera o contador que será usado para percorrer o buffer
  xor ecx, ecx
  ;Armazena o endereço do buffer no registrador edx
  mov edx, DWORD[ebp+8]

  ;Loop para percorrer o buffer e decrementar o valor da chave em cada byte do buffer
  _loop_decrypt:
     sub DWORD [edx + ecx], ebx
     inc ecx
     cmp ecx, DWORD [ebp+12]
     jl _loop_decrypt

  mov esp, ebp
  pop ebp
  ret 4

;Encerra o programa
_exit:
  xor ebx, ebx
  mov eax, 1
  int 80H
