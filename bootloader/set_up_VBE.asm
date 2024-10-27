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

mov ax, 4F01h ; VBE mode information function
mov di, VBE_ModeInfoBlock_pointer ; address where the info will be stored
.match_video_mode:
    mov cx, WORD [es:bx]

	; get the information about the desired video mode
	; di - address where the info will be stored
	; cx - video mode number
	; ax - 4F01h
	int 10h
	; FIX: panic if returned error code in ax is not 0x004f
	mov dx, WORD [VBE_ModeInfoBlock_pointer + VesaModeInfoBlock.ModeAttributes]
	and dx, 1<<7 ; check if the mode has a linear/flat frame buffer
	cmp dx, 0
	je .match_video_mode_keep_searching ; if it doesnt have linear buffer skip this mode

	cmp cx, 011Bh	; 1280×1024x24bpp
	je .match_video_mode_end

	cmp cx, 0118h	; 1024×768x24bpp
	je .match_video_mode_end

	cmp cx, 0115h	; 800×600x24bpp
	je .match_video_mode_end

	cmp cx, 0112h	; 640x480x24bpp
	je .match_video_mode_end

.match_video_mode_keep_searching:

    add bx, 2 ; each entry in the VideoModeList is 16 bit

    cmp cx, 0xffff
    jne .match_video_mode
; FIX: if no match was found: panic
mov dx, 0x0BAD
call print_hex
jmp $

.match_video_mode_end:

; get the information about the desired video mode
mov di, VBE_ModeInfoBlock_pointer ; address where the info will be stored
; cx - video mode number
mov ax, 4F01h ; VBE mode information function
int 10h
; FIX: panic if returned error code in ax is not 0x004f

; set the VBE video mode
; es:di is ignored because bx[11] is set to 0
mov bx, cx
or bx, 1<<14 ; use linear/flat frame buffer
mov ax, 4F02h ; set video mode
int 10h
