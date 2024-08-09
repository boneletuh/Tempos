bits 16

; TODO: clean everything up
; FIX: get the information of what screen modes are available, and if the mode is available in linear frame buffer (LBF).
;      this can be done using the VBE interrupts (int 10h ax=4F00h) and (int 10h ax=4F01h)
struc VesaInfoBlock				;	VesaInfoBlock_size = 512 bytes
	.Signature		resb 4		;	must be 'VESA'
	.Version		resw 1
	.OEMNamePtr		resd 1
	.Capabilities		resd 1
 
	.VideoModesOffset	resw 1
	.VideoModesSegment	resw 1
 
	.CountOf64KBlocks	resw 1
	.OEMSoftwareRevision	resw 1
	.OEMVendorNamePtr	resd 1
	.OEMProductNamePtr	resd 1
	.OEMProductRevisionPtr	resd 1
	.Reserved		resb 222
	.OEMData		resb 256
endstruc
struc VesaModeInfoBlock				;	VesaModeInfoBlock_size = 256 bytes
	.ModeAttributes		resw 1
	.FirstWindowAttributes	resb 1
	.SecondWindowAttributes	resb 1
	.WindowGranularity	resw 1		;	in KB
	.WindowSize		resw 1		;	in KB
	.FirstWindowSegment	resw 1		;	0 if not supported
	.SecondWindowSegment	resw 1		;	0 if not supported
	.WindowFunctionPtr	resd 1
	.BytesPerScanLine	resw 1
 
	;	Added in Revision 1.2
	.Width			resw 1		;	in pixels(graphics)/columns(text)
	.Height			resw 1		;	in pixels(graphics)/columns(text)
	.CharWidth		resb 1		;	in pixels
	.CharHeight		resb 1		;	in pixels
	.PlanesCount		resb 1
	.BitsPerPixel		resb 1
	.BanksCount		resb 1
	.MemoryModel		resb 1		;	http://www.ctyme.com/intr/rb-0274.htm#Table82
	.BankSize		resb 1		;	in KB
	.ImagePagesCount	resb 1		;	count - 1
	.Reserved1		resb 1		;	equals 0 in Revision 1.0-2.0, 1 in 3.0
 
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
	.OffscreenMemorySize	resw 1		;	in KB
	.Reserved2		resb 206	;	available in Revision 3.0, but useless for now
endstruc
; address with at least 512 bytes, that later the kernel entry will take the information from
VBE_info_addr equ 0x500

push ds
pop es
mov di, VBE_info_addr
; FIX: get the mode number using (int 10h, ax=0x4F00)
mov cx, 115h ; mode number: 800x600x24bpp
mov ax, 0x4F01
int 10h

mov dx, [di + VesaModeInfoBlock.Width]
call print_hex
call print_nl
mov dx, [di + VesaModeInfoBlock.Height]
call print_hex
call print_nl
movzx dx, BYTE [di + VesaModeInfoBlock.BitsPerPixel]
call print_hex
call print_nl

mov bx, 0x4000 | 115h ; FIX: get mode using vbe functions
mov ax, 0x4F02
int 10h



%if 0
mov DWORD [es:di], 'VBE2'
mov ax, 0x4F00
int 10h

mov bx, di
add bx, VesaInfoBlock.VideoModesOffset
mov bx, [bx]

mov cx, 24
tstloop:
 mov dx, [bx]
 call print_hex
 call print_nl
 add bx, 2

 dec cx
 jnz tstloop
tstend:
%endif

