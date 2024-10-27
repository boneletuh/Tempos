bits 32

extern _start


; pass the information about the screen to the kernel

mov eax, DWORD [VBE_ModeInfoBlock_pointer + VesaModeInfoBlock.LFBAddress]
mov DWORD [bl_vbe_addr], eax

mov ax, WORD [VBE_ModeInfoBlock_pointer + VesaModeInfoBlock.Width]
mov WORD [bl_vbe_width], ax

mov ax, WORD [VBE_ModeInfoBlock_pointer + VesaModeInfoBlock.Height]
mov WORD [bl_vbe_height], ax

mov al, BYTE [VBE_ModeInfoBlock_pointer + VesaModeInfoBlock.BitsPerPixel]
mov BYTE [bl_vbe_bpp], al


; execute the kernel

call _start
; FIX: panic
jmp $ ; if the control is returned do an infinite loop. (it shouldnt happen)



global bl_vbe_addr, bl_vbe_width, bl_vbe_height, bl_vbe_bpp
bl_vbe_addr: dd 0
bl_vbe_width: dw 0
bl_vbe_height: dw 0
bl_vbe_bpp: db 0

%include "bootloader/VBE_structures.asm"
