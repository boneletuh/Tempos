bits 32

global waste_time
; makes a loop that 'waits'
waste_time:
	push eax
	mov eax, 1000*1000*100
.waste_time_loop:
	cmp eax, 0
	je .waste_time_end
	dec eax
	jmp .waste_time_loop
.waste_time_end:
	pop eax
	ret

%if 1
global memory_copy
; copies 'n' bytes from source to destination
; Params:
;  esi - the source pointer
;  edi - the destination pointer
;  eax - the number of bytes to copy
memory_copy:
	; temporal registers
	push ebx
	push dx
	; index to the bytes
	mov ebx, 0
.memory_copy_loop:
	; if the index is equal to the size end the function
	cmp ebx, eax
	jae .memory_copy_end

	; copy 1 byte each iteration
	mov dl, BYTE [esi + ebx]
	mov BYTE [edi + ebx], dl

	; next iteration
	inc ebx
	jmp .memory_copy_loop
.memory_copy_end:
	pop dx
	pop ebx
	ret

; both versions take the same amount of space
; this version is faster i think idrk
%else
global memory_copy
; copies 'n' bytes from source to destination
; Params:
;  esi - the source pointer
;  edi - the destination pointer
;  eax - the number of bytes to copy
memory_copy:
	; temporal registers
	push ebx
	push dx
	; if the number of bytes to copy is 0 then skip the loop
	cmp eax, 0
	je .memory_copy_end
	; index to the bytes
	mov ebx, 0
.memory_copy_loop:
	; copy 1 byte each iteration
	mov dl, BYTE [esi + ebx]
	mov BYTE [edi + ebx], dl

	; next iteration if the index is less than the size to copy
	inc ebx
	cmp ebx, eax
	jb .memory_copy_loop
.memory_copy_end:
	pop dx
	pop ebx
	ret
%endif

global int_to_hex
; converts the number to a string in hexadecimal
; Params:
;  eax - the number to covert
;  edi - where the number will be written
hex_vals: db "0123456789ABCDEF"
; TODO: implement a reversed version
int_to_hex:
	push eax
	push ebx
	push ecx
	push edx
	; index to the result string
	mov ecx, 0
.int_to_hex_loop:
	; get the first 4 bits of the number
	mov ebx, eax
	and ebx, 1111b
	; get the equivalent hex digit of the number just gotten
	lea edx, [hex_vals + ebx]
	mov dl, BYTE [edx]
	; write it to the result string
	mov BYTE [edi + ecx], dl

	inc ecx
	shr eax, 4
	cmp eax, 0
	jnz .int_to_hex_loop

	; write a null symbol at the end of the result string
	mov BYTE [edi + ecx], 0

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

%if 1
global memory_set
; writes a value to a pointer 'n' times
; Params:
;  edi - the pointer where the value will be written
;  eax - the amount of times the value will be written
;  dl - the byte to copy
memory_set:
	push ebx

	; this is the offset from the pointer
	mov ebx, 0
.memory_set_loop:
	; end the loop if the offset is not below the 'n'
	cmp ebx, eax
	jae .memory_set_end

	; write the byte to the pointer with offset
	mov BYTE [edi + ebx], dl

	; repeat the loop
	inc ebx
	jmp .memory_set_loop
.memory_set_end:
	pop ebx
	ret
%else
global memory_set
; writes a value to a pointer 'n' times
; Params:
;  edi - the pointer where the value will be written
;  eax - the amount of times the value will be written
;  dl - the byte to copy
memory_set:
	push ebx

	; end the function if there is 0 bytes 
	cmp eax, 0
	je .memory_set_end
	; this is the offset from the pointer
	mov ebx, 0
.memory_set_loop:
	; write the byte to the pointer with offset
	mov BYTE [edi + ebx], dl

	; repeat the loop
	inc ebx

	; repeat the loop while the offset is below the 'n'
	cmp ebx, eax
	jb .memory_set_loop
.memory_set_end:
	pop ebx
	ret
%endif

global strcmp
; TODO; rewrite this monstrousity
; if the 2 string are not equal returns 0
; Params:
;  edi - pointer to string1
;  esi - pointer to string2
; Output:
;  al - the result
strcmp:
	push edi
	push esi

.strcmp_loop:
	mov al, BYTE [edi]
	sub al, BYTE [esi]
	cmp al, 0
	jne .strcmp_notequ

	mov al, BYTE [edi]
	cmp al, 0
	jne .strcmp_continue

	mov al, BYTE [esi]
	cmp al, 0
	je .strcmp_equ
.strcmp_continue:

	inc edi
	inc esi
	jmp .strcmp_loop
.strcmp_equ:
	mov al, 1
	jmp .strcmp_end
.strcmp_notequ:
	mov al, 0
.strcmp_end:
	pop esi
	pop edi
	ret
