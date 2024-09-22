; using 32-bit protected mode
bits 32

; defining constants
; this is were VGA text memory starts
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 00001111b

; print a string in 32bit protected mode at the top of the screen
; Params:
;  ebx - the adress of the string
print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY
.print_string_pm_loop:
	mov al, [ebx]
	mov ah, WHITE_ON_BLACK
	; check for null symbol at the end of the string
	cmp al, 0
	je .print_string_pm_end
	; store character and attribute in video memory
	mov [edx], ax
	inc ebx ; next char
	add edx, 2 ; next video memory position

	jmp .print_string_pm_loop
.print_string_pm_end:
	popa
	ret
