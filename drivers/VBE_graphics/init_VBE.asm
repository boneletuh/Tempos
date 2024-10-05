bits 32

extern bl_vbe_addr
extern bl_vbe_width, bl_vbe_height, bl_vbe_bpp

extern char_width, char_height
extern char_width_w_padding, char_height_w_padding


global vbe_screen_sz
; the size of the screen in bytes
vbe_screen_sz: dd 0

global vbe_Bpp
; the size of the pixel in bytes
vbe_Bpp: db 0

global vbe_char_line_bytes
; the size a horizontal line filled with characters with their padding
; char_height_with_padding * screen_width_in_bytes
vbe_char_line_bytes: dd 0

global vbe_width_bytes
; the width of the screen in bytes
vbe_width_bytes: dw 0

global vbe_height_bytes
; the height of the screen in bytes
vbe_height_bytes: dw 0

global vbe_char_width_bytes
; the width of a character in bytes
vbe_char_width_bytes: db 0

global vbe_char_height_bytes
; the height of a character in bytes
vbe_char_height_bytes: db 0

global vbe_char_width_w_padding_bytes
; the width of a character with its horizontal padding in bytes
vbe_char_width_w_padding_bytes: db 0

global vbe_char_height_w_padding_bytes
; the height of a character with its vertical padding in bytes
vbe_char_height_w_padding_bytes: db 0


global init_VBE
; gets and stores parameters about VBE
init_VBE:
	pushad

	; store the Bytes per pixel
	mov al, BYTE [bl_vbe_bpp]
	shr al, 3
	mov BYTE [vbe_Bpp], al

	; store how many bytes the screen takes up
	; screen_size_bytes := width * height * Bpp
	movzx eax, WORD [bl_vbe_width]
	movzx ebx, WORD [bl_vbe_height]
	mul ebx ; pxls_count := width * height
	movzx ebx, BYTE [vbe_Bpp]
	mul ebx ; screen_size_bytes := pxls_count * BytesPerPixel
	mov DWORD [vbe_screen_sz], eax

	; store the width of the screen in bytes
	mov ax, WORD [bl_vbe_width]
	movzx bx, BYTE [vbe_Bpp]
	mul bx
	mov WORD [vbe_width_bytes], ax

	; store the height of the screen in bytes
	mov ax, WORD [bl_vbe_height]
	movzx bx, BYTE [vbe_Bpp]
	mul bx
	mov WORD [vbe_height_bytes], ax

	; store char_height_with_padding * screen_width_in_bytes
	mov eax, char_height_w_padding
	movzx ebx, WORD [vbe_width_bytes]
	mul ebx
	mov DWORD [vbe_char_line_bytes], eax

	; store the width of a character in bytes
	mov al, char_width
	mul BYTE [vbe_Bpp]
	mov BYTE [vbe_char_width_bytes], al

	; store the height of a character in bytes
	mov al, char_height
	mul BYTE [vbe_Bpp]
	mov BYTE [vbe_char_height_bytes], al

	; store the width of a character with its padding in bytes
	mov al, char_width_w_padding
	mul BYTE [vbe_Bpp]
	mov BYTE [vbe_char_width_w_padding_bytes], al

	; store the height of a character with its padding in bytes
	mov al, char_height_w_padding
	mul BYTE [vbe_Bpp]
	mov BYTE [vbe_char_height_w_padding_bytes], al

	call rand_colors

	popad
	ret

; a silly function to kind of see if the screen works properly
rand_colors:
	pushad
	; load the address of the screen, to write pixels
	mov eax, DWORD [bl_vbe_addr]
	; the amount of bytes to write to
	mov ebx, DWORD [vbe_screen_sz]
	; some random color to fill the screen with
	mov dl, 0x00
.aloop:
	mov BYTE [eax], dl
	inc eax

	; randomize 'dl'
	inc dl
	xor dl, al
	ror dl, 1

	dec ebx
	test ebx, ebx
	jnz .aloop

	popad
	ret
