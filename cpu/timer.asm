bits 32

extern int_to_hex
extern register_interrupt_handler
extern IRQ0, IRQ1, IRQ2, IRQ3, IRQ4, IRQ5, IRQ6, IRQ7, IRQ8, IRQ9, IRQ10, IRQ11, IRQ12, IRQ13, IRQ14, IRQ15

global tick
; it will be incremented when the clock ticks
tick: dd 0

global timer_callback
; increase by one the value of the clock (duh)
timer_callback:
	inc DWORD [tick]
	ret

global init_timer
; Params:
;  ecx - ticking frequency
init_timer:
	push eax
	push ebx
	push ecx
	push edx

	mov al, IRQ0
	mov ebx, timer_callback
	call register_interrupt_handler

	mov eax, 1193180
	mov edx, 0
	div ecx
	mov ecx, eax

	mov al, 0x36
	out 0x43, al

	mov al, cl
	out 0x40, al

	mov al, ch
	out 0x40, al

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
