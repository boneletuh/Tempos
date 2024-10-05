; TODO: optimize the calling arguments of the functions and the `pushad` and `popad`
bits 32

extern font
extern char_width, char_height
extern char_width_w_padding, char_height_w_padding
extern vbe_char_line_bytes

extern bl_vbe_height, bl_vbe_addr
extern vbe_screen_sz, vbe_width_bytes
extern vbe_char_width_bytes
extern vbe_char_width_w_padding_bytes

extern memory_set, memory_copy

; offset in the screen after of the last character printed 
cursor: dd 0

global VBE_clear_screen
VBE_clear_screen:
	push eax
	push edi
	push dx

	mov eax, DWORD [vbe_screen_sz]
	mov edi, DWORD [bl_vbe_addr]
	mov dl, 0 ; black
	call memory_set

	mov DWORD [cursor], 0

	pop dx
	pop edi
	pop eax
	ret

global VBE_roll_screen_up
; rolls the screen up by one pixel
; TODO: optimize this loop
VBE_roll_screen_up:
	pushad
	mov ebx, DWORD [vbe_char_line_bytes]
	; the index for the loop
	mov edx, char_height_w_padding ; skip the character line
.VBE_roll_screen_up_loop:
	cmp dx, WORD [bl_vbe_height]
	jae .VBE_roll_screen_up_end

	; copy a line to the previous line to 'roll' it up
	; line to copy
	push edx
	movzx eax, WORD [vbe_width_bytes]
	mul edx
	pop edx

	add eax, DWORD [bl_vbe_addr]
	mov esi, eax
	; line to be copied to
	mov edi, eax
	sub edi, ebx
	
	; the number of bytes to copy
	movzx eax, WORD [vbe_width_bytes]
	call memory_copy

	; next iteration
	inc edx
	jmp .VBE_roll_screen_up_loop	
.VBE_roll_screen_up_end:
	; set the bottom line of the screen to black
	mov eax, ebx
	mov edi, DWORD [vbe_screen_sz]
	sub edi, DWORD [vbe_char_line_bytes]
	add edi, DWORD [bl_vbe_addr]
	mov dl, 0 ; color black
	call memory_set

	popad
	ret

global VBE_backspace
; deletes the last printed character
VBE_backspace:
	pushad

	mov ebx, DWORD [cursor]

	; point to the previous place to print
	movzx ecx, BYTE [vbe_char_width_w_padding_bytes]
	sub ebx, ecx

	; adjust for out of line offsets
	; 1# line_offset = offset % width_bytes
	; 2# char_beginning = line_offset - (line_offset % char_width_with_padding)
	; 3# line_beginning = offset - (offset % (width_bytes * char_height_with_padding))
	; 4# offset = line_beginning + char_beginning

	; 1#
	;  edi = line_offset
	movzx ecx, WORD [vbe_width_bytes]
	mov eax, ebx
	xor edx, edx
	div ecx
	mov edi, edx
	; 2#
	;  edi = char_beginning
	mov ecx, char_width_w_padding
	mov eax, edi
	xor edx, edx
	div ecx
	sub edi, edx
	; 3#
	;  eax = line_beginning
	mov eax, char_height_w_padding
	movzx edx, WORD [vbe_width_bytes]
	mul edx
	mov ecx, eax
	mov eax, ebx
	xor edx, edx	
	div ecx
	mov eax, ebx
	sub eax, edx
	; 4#
	add eax, edi
	mov DWORD [cursor], eax

	; fill the erased character with black
	mov edi, eax
	add edi, DWORD [bl_vbe_addr]

	movzx ebx, WORD [vbe_width_bytes]
	movzx eax, BYTE [vbe_char_width_w_padding_bytes]
	mov ecx, char_height_w_padding
	mov dl, 0
.VBE_backspace_clean_char:
	call memory_set

	add edi, ebx

	dec ecx
	cmp ecx, 0
	jne .VBE_backspace_clean_char

	popad
	ret

; prints a new line / line feed
; Input:
;  ebx - offset in the screen where the new line will be printed
VBE_print_new_line:
	pushad

	mov edi, DWORD [vbe_char_line_bytes]
	mov eax, DWORD [cursor]
	xor edx, edx
	div edi
	sub DWORD [cursor], edx

	add DWORD [cursor], edi

	popad
	ret


global VBE_print_char_from_font
; print a character from the font to the screen (only visible characters and spaces)
; Input:
;  al - the character to print
;  ebx - offset in the screen where the glyph will be printed
VBE_print_char_from_font:
	pushad

	push ebx

	; value to add to start printing in the next line
	movzx ecx, WORD [vbe_width_bytes]
	movzx esi, BYTE [vbe_char_width_bytes]
	sub ecx, esi

	; pointer to the bytes that the bits are taken off of the character of the font
	movzx eax, al
	mov esi, [eax*4 + font] ; get the character typography to print

	; the address where the glyph will be printed
	mov edi, DWORD [bl_vbe_addr]
	add edi, ebx

	mov ebx, char_height
.VBE_print_char_from_font_y:
	mov eax, char_width
	; get the bits from the row of the character
	mov dh, BYTE [esi]
.VBE_print_char_from_font_x:
	; if the bit in the font is set draw a white pixel, otherwise draw a black pixel
	; get the correponding bit of the character of the font
	mov dl, dh
	and dl, 0b10000000
	shr dl, 7
	; if the bit is 0 it sets dl to 0x00, if the bit is 1 it sets dl to 0xff
	neg dl
	; FIX: this assumes 3 Bpp (bytes per pixel)
	mov BYTE [edi], dl ; Blue
	mov BYTE [edi+1], dl ; Green
	mov BYTE [edi+2], dl ; Red
	; get the next pixel address
	add edi, 3 ; FIX: get the value from bl_vbe_bpp
	; get the next bit of the character
	shl dh, 1
	; loop around for the width
	dec eax
	jnz .VBE_print_char_from_font_x

	; point to the next row of bits to plot
	inc esi
	; continue plotting in the next row
	add edi, ecx

	; loop around for the height
	dec ebx
	jnz .VBE_print_char_from_font_y

	pop edi

	; point to the next place to print
	movzx ecx, BYTE [vbe_char_width_w_padding_bytes]
	add edi, ecx

	; update the offset to the next character position
	; adjust for out of line offsets
	; TODO: improve this, maybe usiing vbe_char_line_bytes
	; 1#  char_row_size = width_bytes * char_height_with_padding
	; 2#  line_beginning = offset - (offset % char_row_size)
	; 3#  if width * Bpp < offset - line_beginning:
	; 4#    offset = line_beginning + char_row_size
	
	; 1#
	; ecx = char_row_size
	mov ecx, DWORD [vbe_char_line_bytes]
	; 2#
	; ebx = line_beginning
	mov eax, edi
	mov edx, 0
	div ecx
	mov ebx, edi
	sub ebx, edx
	; 3#
	; edx = offset - line_beginning
	; eax = width_Bpp
	movzx eax, WORD [vbe_width_bytes]
	mov edx, edi
	sub edx, ebx
	; 4#
	add ebx, ecx
	cmp edx, eax
	cmovb ebx, edi
	mov edi, ebx

	; save the offset
	mov DWORD [cursor], edi

	popad
	ret


; prints a symbol to the screen
; Input:
;  al - the symbol to print
;  ebx - offset in the screen where the symbol will be printed
VBE_print_char:
	pushad

	cmp al, 10
	je .VBE_print_char_new_line

	call VBE_print_char_from_font
	jmp .VBE_print_char_end

.VBE_print_char_new_line:
	call VBE_print_new_line

.VBE_print_char_end:
	mov eax, DWORD [cursor]
	cmp eax, DWORD [vbe_screen_sz]
	jb .VBE_print_char_not_roll

	call VBE_roll_screen_up

	; set the cursor to the beginning of the line
	mov edx, 0
	mov eax, DWORD [cursor]
	movzx ebx, WORD [vbe_width_bytes]
	div ebx
	sub DWORD [cursor], edx
	; set the cursor one character-line up
	mov edx, DWORD [vbe_char_line_bytes]
	sub DWORD [cursor], edx

.VBE_print_char_not_roll:
	popad
	ret


global VBE_print
; prints a string to the screen
; Input:
;  edi - pointer to the string
VBE_print:
	pushad

.VBE_print_loop:
	; if the symbol is '\0' stop printing
	mov al, BYTE [edi]
	cmp al, 0
	je .VBE_print_end

	mov ebx, DWORD [cursor]
	call VBE_print_char

	; get the next symbol
	inc edi
	; repeat
	jmp .VBE_print_loop
.VBE_print_end:
	popad
	ret
