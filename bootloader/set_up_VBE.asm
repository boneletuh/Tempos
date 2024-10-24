bits 16

%include "bootloader/VBE_structures.asm"


; get the list of available video modes
mov DWORD [VBE_VesaInfoBlock_pointer], 'VBE2'
mov di, VBE_VesaInfoBlock_pointer
mov ax, 4F00h
int 10h

; TODO: improve the video mode selecting
mov ax, WORD [VBE_VesaInfoBlock_pointer + VesaInfoBlock.VideoModesSegment]
mov es, ax
mov bx, WORD [VBE_VesaInfoBlock_pointer + VesaInfoBlock.VideoModesOffset]
.match_video_mode:
    mov dx, WORD [es:bx]

	cmp dx, 011Bh	; 1280×1024x24bpp
	je .match_video_mode_end

	cmp dx, 0118h	; 1024×768x24bpp
	je .match_video_mode_end

	cmp dx, 0115h	; 800×600x24bpp
	je .match_video_mode_end

	cmp dx, 0112h	; 640x480x24bpp
	je .match_video_mode_end

    add bx, 2 ; each entry in the VideoModeList is 16 bit

    cmp dx, 0xffff
    jne .match_video_mode
; if not match was found panic
; FIX: call panic
mov dx, 0x0BAD
call print_hex
jmp $
.match_video_mode_end:

; get the information about the desired video mode
mov di, VBE_ModeInfoBlock_pointer ; address where the info will be stored
mov cx, dx ; video mode number
mov ax, 4F01h ; VBE mode information
int 10h
; FIX: panic if returned error code in ax is not 0x004f

; set the VBE video mode
; es:di is ignored because bx[11] is set to 0
mov bx, dx
or bx, 0x4000 ; | (1 << 14) ; use linear/flat frame buffer
mov ax, 4F02h ; set video mode
int 10h
