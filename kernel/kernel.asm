bits 32

; import symbols from other files
extern isr_install
extern init_timer, init_keyboard
extern init_VBE
extern init_shell
extern num_str, new_line
extern VBE_print, int_to_hex, int_to_dec

; initializes the IRQs
irq_install:
	sti
	; the timer
	mov ecx, 50
	call init_timer
	; the keyboard
	call init_keyboard

	ret

global _start
_start:

	call isr_install
	call irq_install

	call init_VBE
	call init_shell

	rdtsc
	mov DWORD [boot_time+0], edx
	mov DWORD [boot_time+4], eax


;	mov edi, num_str
;	mov BYTE [num_str+1], 0
;	mov al, 0
;.allchar:
;	mov BYTE [num_str], al
;	call VBE_print
;
;	inc al
;	jnz .allchar


	hlt
	ret

boot_time: dq 0