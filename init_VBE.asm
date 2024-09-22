bits 32

extern bl_vbe_width, bl_vbe_height, bl_vbe_bpp

global vbe_screen_sz
; the size of the screen in bytes
vbe_screen_sz: dd 0

global init_VBE
; gets and stores parameters about VBE
init_VBE:
	push eax
	push ebx
	push edx

	; Store how many bytes the screen takes up
	; screen_size_bytes := width * height * (bpp / 8)
	mov edx, 0 ; FIX: unneeded instruction
	movzx eax, WORD [bl_vbe_width]
	movzx ebx, WORD [bl_vbe_height]
	mul ebx ; pxls_count := width * height
	mov edx, 0
	mov bl, BYTE [bl_vbe_bpp]
	shr bl, 3 ; BytesPerPixel := bpp / 8
	movzx ebx, bl
	mul ebx ; screen_size_bytes := pxls_count * BytesPerPixel
	mov DWORD [vbe_screen_sz], eax

	pop edx
	pop ebx
	pop eax
	ret