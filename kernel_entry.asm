bits 32

; define calling point. Must have same name as the function in the file it was compiled from
extern _start

; before executing the rest of the kernel save the registers with the information gotten from the bootloader

; save the vbe information gotten from the bootloader
struc VesaModeInfoBlock				;	VesaModeInfoBlock_size = 256 bytes
	.ModeAttributes		resw 1
	.FirstWindowAttributes	resb 1
	.SecondWindowAttributes	resb 1
	.WindowGranularity	resw 1		;	in KB
	.WindowSize		resw 1			;	in KB
	.FirstWindowSegment	resw 1		;	0 if not supported
	.SecondWindowSegment	resw 1	;	0 if not supported
	.WindowFunctionPtr	resd 1
	.BytesPerScanLine	resw 1
 
	;	Added in Revision 1.2
	.Width			resw 1			;	in pixels(graphics)/columns(text)
	.Height			resw 1			;	in pixels(graphics)/columns(text)
	.CharWidth		resb 1			;	in pixels
	.CharHeight		resb 1			;	in pixels
	.PlanesCount		resb 1
	.BitsPerPixel		resb 1
	.BanksCount		resb 1
	.MemoryModel		resb 1		;	http://www.ctyme.com/intr/rb-0274.htm#Table82
	.BankSize		resb 1			;	in KB
	.ImagePagesCount	resb 1		;	count - 1
	.Reserved1		resb 1			;	equals 0 in Revision 1.0-2.0, 1 in 3.0
 
	.RedMaskSize		resb 1
	.RedFieldPosition	resb 1
	.GreenMaskSize		resb 1
	.GreenFieldPosition	resb 1
	.BlueMaskSize		resb 1
	.BlueFieldPosition	resb 1
	.ReservedMaskSize	resb 1
	.ReservedMaskPosition	resb 1
	.DirectColorModeInfo	resb 1
 
	;	Added in Revision 2.0
	.LFBAddress		resd 1
	.OffscreenMemoryOffset	resd 1
	.OffscreenMemorySize	resw 1	;	in KB
	.Reserved2		resb 206		;	available in revision 3.0
endstruc

vbe_struct_addr equ 0x500 ; the place where the vbe info was stored in the bootloader

mov ax, WORD [vbe_struct_addr + VesaModeInfoBlock.Width]
mov WORD [bl_vbe_width], ax

mov ax, WORD [vbe_struct_addr + VesaModeInfoBlock.Height]
mov WORD [bl_vbe_height], ax

mov al, BYTE [vbe_struct_addr + VesaModeInfoBlock.BitsPerPixel]
mov BYTE [bl_vbe_bpp], al

mov eax, DWORD [vbe_struct_addr + VesaModeInfoBlock.LFBAddress]
mov DWORD [bl_vbe_addr], eax

; calls the kernel entry function. The linker will know where it is placed in memory
call _start

; this should never be executed, as the kernel main should not return/end
jmp $


; the structures that stores the information gotten from the bootloader
; the attributes of the screen gotten in the bootloader using the VESA BIOS Extension
global bl_vbe_width, bl_vbe_height, bl_vbe_addr, bl_vbe_bpp
bl_vbe_width: dw 0
bl_vbe_height: dw 0
bl_vbe_bpp: db 0
bl_vbe_addr: dd 0