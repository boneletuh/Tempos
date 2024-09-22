; the screen character dimensions
MAX_ROWS equ 25
MAX_COLS equ 80
SCREEN_SIZE equ MAX_ROWS*MAX_COLS

; ptr to VGA characters
global VIDEO_MEM
VIDEO_MEM equ 0xb8000

; some colors for characters
global WHITE_ON_BLACK
WHITE_ON_BLACK equ 0b00001111
global RED_ON_WHITE
RED_ON_WHITE equ 0b11110100

; screen I/O ports
global REG_SCREEN_CNTRL
REG_SCREEN_CNTRL equ 0x3d4
global REG_SCREEN_DATA
REG_SCREEN_DATA equ 0x3d5

; get symbols from utils
extern memory_copy

global clear_screen
; 'cleans' all the characters in the screen
clear_screen:
	push eax
	push ebx
	; the index to character in screen
	mov eax, 0
.clear_screen_loop:
	; if the index is greater or equal to SCREEN_SIZE end the loop
	cmp eax, SCREEN_SIZE
	jge .clear_screen_end
	; address to the VGA characters
	lea ebx, [eax*2 + VIDEO_MEM]
	; write an space to 'clean' the place
	mov BYTE [ebx], ' '
	mov BYTE [ebx+1], WHITE_ON_BLACK
	; increment the index to go to the next symbol
	; repeat the loop
	inc eax
	jmp .clear_screen_loop
.clear_screen_end:
	; set the cursor to the beginning of the screen
	mov bx, 0
	call set_cursor_offset
	pop ebx
	pop eax
	ret

; set the position of the cursor to a new value
; Params:
;  bx - the new offset of the cursor 
set_cursor_offset:
	push ax

	shr bx, 1

	mov al, 14
	mov dx, REG_SCREEN_CNTRL
	out dx, al

	mov al, bh
	mov dx, REG_SCREEN_DATA
	out dx, al

	mov al, 15
	mov dx, REG_SCREEN_CNTRL
	out dx, al

	mov al, bl
	mov dx, REG_SCREEN_DATA
	out dx, al

	shl bx, 1

	pop ax
	ret

; get offset from column and row
; Params:
;  ebx - the column
;  ecx - the row
; Output:
;  eax - the offset
get_offset:
	; calculate the offset
	mov eax, ecx
	push ecx
	push edx
	mov ecx, MAX_COLS
	mul ecx
	pop edx
	pop ecx
	add eax, ebx

	shl eax, 1

	ret


; get the row from the offset
; Params:
;  ebx - the offset
; Output:
;  eax - the row
get_offset_row:
	mov eax, ebx
	push ebx
	push edx

	mov edx, 0
	mov ebx, 2*MAX_COLS
	div ebx

	pop edx
	pop ebx
	ret

%if 0
; get the column from the offset
; Params:
;  ebx - the offset
; Output:
;  eax - the column
get_offset_col:
	; FIX: all this function
	push ebx

	call get_offset_row
	mov ebx, 2*MAX_COLS
	mul ebx
	mov ebx, eax
	mov eax, [esp]
	sub eax, ebx
	shr eax, 1

	pop ebx
	ret
%endif

; get the offset of the cursor
; Output:
;  ax -  the offset 
get_cursor_offset:
	push dx
	
	mov al, 14
	mov dx, REG_SCREEN_CNTRL
	out dx, al

	mov dx, REG_SCREEN_DATA
	in al, dx
	mov ah, al

	mov al, 15
	mov dx, REG_SCREEN_CNTRL
	out dx, al

	mov dx, REG_SCREEN_DATA
	in al, dx

	add ax, ax

	pop dx
	ret

global kprint_backspace
; delete the last character printed
kprint_backspace:
	push ax
	push bx
	push edx

	; get the place of the last printed symbol
	call get_cursor_offset
	sub ax, 2
	movzx edx, ax
	; clean it
	mov al, ' '
	mov ah, WHITE_ON_BLACK
	call print_char
	mov bx, dx
	sub bx, 2
	call set_cursor_offset

	pop edx
	pop bx
	pop ax
	ret

global roll_screen_up
; rolls up the characters in the screen by 1 row
roll_screen_up:
	pushad
	; the index for the loop
	mov edx, 1
.roll_screen_up_loop:
	; loop while the idx is less than MAX_ROWS
	cmp edx, MAX_ROWS
	jge .roll_screen_up_end ; FIX: jge is probably wrong, maybe jae

	; copy a line to the previous line to 'roll' it up
	; line to copy
	mov ebx, 0
	mov ecx, edx
	call get_offset
	add eax, VIDEO_MEM
	mov esi, eax
	; line to be copied to
	sub eax, MAX_COLS*2
	mov edi, eax
	
	; the number of bytes to copy
	mov eax, MAX_COLS*2

	call memory_copy

	; next iteration
	inc edx
	jmp .roll_screen_up_loop	
.roll_screen_up_end:
	; empty the last row
	mov eax, 0
.roll_screen_last_row_loop:
	cmp eax, MAX_COLS*2
	je .roll_screen_last_row_end

	; clean the spot
	mov BYTE [VIDEO_MEM + MAX_COLS*(MAX_ROWS - 1)*2 + eax*2], ' '
	mov BYTE [VIDEO_MEM + MAX_COLS*(MAX_ROWS - 1)*2 + eax*2 +1], WHITE_ON_BLACK

	inc eax
	jmp .roll_screen_last_row_loop
.roll_screen_last_row_end:
	
	popad
	ret


global kprint
; prints a string in the place where the cursor is
; Params:
;  edi - pointer to string
kprint:
	push edx
	push edi
	push ax
	; print at the current offset
	call get_cursor_offset
	movzx edx, ax
	; preset the color of the symbol
	mov ah, WHITE_ON_BLACK	
.kprint_loop:
	mov al, BYTE [edi]
	; check for null symbol
	cmp al, 0
	je .kprint_end

	; print the symbol
	call print_char

	; next iteration
	inc edi
	jmp .kprint_loop
.kprint_end:
	; update to new offset
	push bx
	mov bx, dx
	call set_cursor_offset
	pop bx

	pop ax
	pop edi
	pop edx
	ret

; print a symbol in the screen
; Params:
;  al - the character
;  ah - the color
;  edx - the offset
; Output:
;  edx - the new offset of the cursor
print_char:
	; if the character is a new line skip it
	cmp al, 10
	je .print_char_nl_lbl

	; print the symbol
	;mov BYTE [edx+VIDEO_MEM], al
	;mov BYTE [edx+VIDEO_MEM+1], ah
	; this way is more efficient and equivalent because of x86 endianness
	mov WORD [edx+VIDEO_MEM], ax

	; increment the offset to next symbol
	add edx, 2
	; skip printing a new line
	jmp .print_char_end_nl


.print_char_nl_lbl:
	push ebx
	push eax
	push ecx
	; set the cursor to the beginning of a new line
	mov ebx, edx
	call get_offset_row

	mov ebx, 0
	inc eax
	mov ecx, eax
	call get_offset
	mov edx, eax

	pop ecx
	pop eax
	pop ebx
.print_char_end_nl:
	; if the offset hasnt reached the end of the screen skip rolling the window
	cmp edx, SCREEN_SIZE*2
	jb .print_char_end_rlu

	; roll the screen
	call roll_screen_up

	mov bx, 0
	call set_cursor_offset

	; move the cursor 1 column up
	sub edx, MAX_COLS*2
.print_char_end_rlu:
	ret
