; TODO: optimize the calling arguments of the functions and the `pushad` and `popad`
bits 32


extern font
extern char_width, char_height

extern bl_vbe_width, bl_vbe_height, bl_vbe_bpp, bl_vbe_addr
extern vbe_screen_sz

extern memory_set, memory_copy

; offset in the screen after of the last character printed 
cursor: dd 0


global VBE_roll_screen_up
; rolls the screen up by one pixel
; TODO: optimize this loop (a lot)
VBE_roll_screen_up:
	pushad
	; number of rows a character takes: (char_height+padding) * bl_vbe_width * bl_vbe_bpp/8
	mov ebx, (16 + 4)*800*3 ; FIX:
	; the index for the loop
	mov edx, 16 + 4 ; skip the character line
.VBE_roll_screen_up_loop:
	cmp dx, WORD [bl_vbe_height]
	jae .VBE_roll_screen_up_end

	; copy a line to the previous line to 'roll' it up
	; line to copy
	lea eax, [edx*3] ; FIX: get the value from bl_vbe_bpp
	push edx
	movzx edx, WORD [bl_vbe_width]
	mul edx
	pop edx

	add eax, DWORD [bl_vbe_addr]
	mov esi, eax
	; line to be copied to
	mov edi, eax
	sub edi, ebx
	
	; the number of bytes to copy
	mov eax, 800*3 ; FIX: bl_vbe_width * bl_vbe_bpp/8
	call memory_copy

	; next iteration
	inc edx
	jmp .VBE_roll_screen_up_loop	
.VBE_roll_screen_up_end:
	; set the bottom line of the screen to black
	mov eax, ebx ; FIX: bl_vbe_width * bl_vbe_bpp/8
	mov edi, DWORD [bl_vbe_addr]
	;add edi, 800*(600-1)*3  ; FIX: bl_vbe_width*(bl_vbe_height -1)*bl_vbe_bpp/8
	add edi, 800*(600-(16+4))*3  ; FIX: bl_vbe_width*(bl_vbe_height - (char_height+padding))*bl_vbe_bpp/8
	mov dl, 0 ; color black
	call memory_set

	popad
	ret


; prints a new line / line feed
; Input:
;  ebx - offset in the screen where the new line will be printed
VBE_print_new_line:
	pushad

	; screen_width * Bpp * (char_height + padding)
	mov edi, 800 * 3 * (16 + 4) ; FIX: get this parameters the right way
	mov eax, DWORD [cursor]
	mov edx, 0
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

	; value to add to start printing in the next line
	movzx ecx, WORD [bl_vbe_width]
	lea ecx, [ecx*3] ; FIX: get the value from bl_vbe_bpp
	mov esi, char_width
	lea esi, [esi*3] ; FIX: get the value from bl_vbe_bpp
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

	; save the offset
	;lea ebx, [ebx + (char_width+2) * 3]
	mov ecx, char_width + 2 ; add 2 spacing between symbols
	lea ecx, [ecx*3] ; FIX: get the value from bl_vbe_bpp
	add DWORD [cursor], ecx

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
	mov ebx, 800*3 ; FIX: screen_width * bytes_per_pixel
	div ebx
	sub DWORD [cursor], edx
	; set the cursor one character-line up
	sub DWORD [cursor], 800*(16+4)*3 ; FIX: screen_width*(char_height+padding)*bytes_per_pixel

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
