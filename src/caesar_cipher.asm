extern printf, scanf
global main

section .bss
  menu_option: resb 1
  key: resb 5
  input_filename: resb 20
  output_filename: resb 20
  buffer: resb 512
  input_file_handle: resd 1
  output_file_handle: resd 1

section .data
  printf_menu_text: db 0AH, 09H, "Caesar Cipher", 0AH, 09H, "    Menu", 0AH, 0AH,  09H, "[1] Encrypt", 0AH, 09H, "[2] Decrypt", 0AH, 09H, "[0] Exit", 0AH, 0AH, 0H
  printf_invalid_opp_txt: db 09H, "Invalid option!", 0AH, 0H
  printf_in_filename_txt: db 09H, "Input filename:", 0AH, 0H
  printf_out_filename_txt: db 09H, "Output filename:", 0AH, 0H
  printf_key_txt: db 09H, "Key:", 0AH, 0H
  scanf_frt_read_int: db "%d", 0H
  scanf_frt_read_str: db "%s", 0H

section .text
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
  cmp BYTE[menu_option], 0
  jl _invalid_menu_option
  je _exit
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
  
;Label responsável por abrir o arquivo de entrada de dados
_open_input_file:
  mov eax, 5
  mov ebx, input_filename
  mov ecx, 0
  mov edx, 0o777
  int 80H
  mov [input_file_handle], eax

;Label responsável por criar e abrir o arquivo de saida de dados
_create_and_open_output_file:
  mov eax, 8
  mov ebx, output_filename
  mov ecx, 0o777
  int 80H
  mov [output_file_handle], eax

;Label responsável por ler do arquivo de entrada de dados e salvar no buffer
_read_input_file:
  mov eax, 3
  mov ebx, [input_file_handle]
  mov ecx, buffer
  mov edx, 512
  int 80H

  cmp eax, 0
  je _close_files

  push DWORD [key]
  push DWORD eax
  push DWORD buffer
  cmp BYTE [menu_option], 1
  je _call_encrypt
  jne _call_decrypt

_call_encrypt:
  call _encrypt_
  jmp _write_output_file

_call_decrypt:
  call _decrypt_

;Label responsável por escrever a saida do programa no arquivo de saida
_write_output_file:
  mov edx, eax
  mov eax, 4
  mov ebx, [output_file_handle]
  mov ecx, buffer
  int 80H
  jmp _read_input_file

_close_files:
  mov eax, 6
  mov ebx, [input_file_handle]
  int 80H

  mov eax, 6
  mov ebx, [output_file_handle]
  int 80H

  jmp main

_encrypt_:
  push ebp
  mov ebp, esp
  sub esp, 8
  
  mov ebx, DWORD [ebp+16]
  xor ecx, ecx
  mov edx, DWORD [ebp+8] 
  
  _loop_encrypt:
    add DWORD [edx + ecx], ebx
    inc ecx
    cmp ecx, DWORD [ebp+12]
    jl _loop_encrypt

  mov esp, ebp
  pop ebp
  ret 4

_decrypt_:
  push ebp
  mov ebp, esp
  sub esp, 8

  mov ebx, DWORD [ebp+16]
  xor ecx, ecx
  mov edx, DWORD[ebp+8]

  _loop_decrypt:
     sub DWORD [edx + ecx], ebx
     inc ecx
     cmp ecx, DWORD [ebp+12]
     jl _loop_decrypt

  mov esp, ebp
  pop ebp
  ret 4

_exit:
  xor ebx, ebx
  mov eax, 1
  int 80H
