bits 32

extern kprint
extern int_to_hex
extern num_str
extern new_line

; import the isr functions
extern isr0, isr1, isr2, isr3, isr4, isr5, isr6, isr7, isr8, isr9, isr10, isr11, isr12, isr13, isr14, isr15, isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23, isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31
extern irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7, irq8, irq9, irq10, irq11, irq12, irq13, irq14, irq15

extern set_idt_gate
extern set_idt


IRQ0: equ  32
IRQ1: equ  33
IRQ2: equ  34
IRQ3: equ  35
IRQ4: equ  36
IRQ5: equ  37
IRQ6: equ  38
IRQ7: equ  39
IRQ8: equ  40
IRQ9: equ  41
IRQ10: equ  42
IRQ11: equ  43
IRQ12: equ  44
IRQ13: equ  45
IRQ14: equ  46
IRQ15: equ  47
global IRQ0, IRQ1, IRQ2, IRQ3, IRQ4, IRQ5, IRQ6, IRQ7, IRQ8, IRQ9, IRQ10, IRQ11, IRQ12, IRQ13, IRQ14, IRQ15

; registers_type memory layout
;  u32 ds  Data segment
;  u32 edi, esi, ebp, esp, ebx, edx, ecx, eax  General registers pushed by pusha
;  u32 int_no, err_code  Interrupt number,  Error code (if there is)
;  u32 eip, cs, eflags, useresp, ss  Pushed by the processor automatically

interrupt_handlers: times 256 dd 0 ; array of 256 elements of 4 bytes each (the size of a ptr to registers type)
global registers_type
registers_type: dq 0, 0, 0, 0, 0, 0, 0, 0 ; for moving memory around with the array

global isr_install
; Changes all the registers
isr_install:
	mov eax, 0
	mov ebx, isr0
	call set_idt_gate

	mov eax, 1
	mov ebx, isr1
	call set_idt_gate

	mov eax, 2
	mov ebx, isr2
	call set_idt_gate

	mov eax, 3
	mov ebx, isr3
	call set_idt_gate

	mov eax, 4
	mov ebx, isr4
	call set_idt_gate

	mov eax, 5
	mov ebx, isr5
	call set_idt_gate

	mov eax, 6
	mov ebx, isr6
	call set_idt_gate

	mov eax, 7
	mov ebx, isr7
	call set_idt_gate

	mov eax, 8
	mov ebx, isr8
	call set_idt_gate

	mov eax, 9
	mov ebx, isr9
	call set_idt_gate

	mov eax, 10
	mov ebx, isr10
	call set_idt_gate

	mov eax, 11
	mov ebx, isr11
	call set_idt_gate

	mov eax, 12
	mov ebx, isr12
	call set_idt_gate

	mov eax, 13
	mov ebx, isr13
	call set_idt_gate

	mov eax, 14
	mov ebx, isr14
	call set_idt_gate

	mov eax, 15
	mov ebx, isr15
	call set_idt_gate

	mov eax, 16
	mov ebx, isr16
	call set_idt_gate

	mov eax, 17
	mov ebx, isr17
	call set_idt_gate

	mov eax, 18
	mov ebx, isr18
	call set_idt_gate

	mov eax, 19
	mov ebx, isr19
	call set_idt_gate

	mov eax, 20
	mov ebx, isr20
	call set_idt_gate

	mov eax, 21
	mov ebx, isr21
	call set_idt_gate

	mov eax, 22
	mov ebx, isr22
	call set_idt_gate

	mov eax, 23
	mov ebx, isr23
	call set_idt_gate

	mov eax, 24
	mov ebx, isr24
	call set_idt_gate

	mov eax, 25
	mov ebx, isr25
	call set_idt_gate

	mov eax, 26
	mov ebx, isr26
	call set_idt_gate

	mov eax, 27
	mov ebx, isr27
	call set_idt_gate

	mov eax, 28
	mov ebx, isr28
	call set_idt_gate

	mov eax, 29
	mov ebx, isr29
	call set_idt_gate

	mov eax, 30
	mov ebx, isr30
	call set_idt_gate

	mov eax, 31
	mov ebx, isr31
	call set_idt_gate

	; remap the PIC
	mov al, 0x11
	out 0x20, al

	mov al, 0x11
	out 0xA0, al

	mov al, 0x20
	out 0x21, al

	mov al, 0x28
	out 0xA1, al

	mov al, 0x04
	out 0x21, al

	mov al, 0x02
	out 0xA1, al

	mov al, 0x01
	out 0x21, al

	mov al, 0x01
	out 0xA1, al

	mov al, 0x00
	out 0x21, al

	mov al, 0x00
	out 0xA1, al

	; install the IRQs
	mov eax, 32
	mov ebx, irq0
	call set_idt_gate

	mov eax, 33
	mov ebx, irq1
	call set_idt_gate

	mov eax, 34
	mov ebx, irq2
	call set_idt_gate

	mov eax, 35
	mov ebx, irq3
	call set_idt_gate

	mov eax, 36
	mov ebx, irq4
	call set_idt_gate

	mov eax, 37
	mov ebx, irq5
	call set_idt_gate

	mov eax, 38
	mov ebx, irq6
	call set_idt_gate

	mov eax, 39
	mov ebx, irq7
	call set_idt_gate

	mov eax, 40
	mov ebx, irq8
	call set_idt_gate

	mov eax, 41
	mov ebx, irq9
	call set_idt_gate

	mov eax, 42
	mov ebx, irq10
	call set_idt_gate

	mov eax, 43
	mov ebx, irq11
	call set_idt_gate

	mov eax, 44
	mov ebx, irq12
	call set_idt_gate

	mov eax, 45
	mov ebx, irq13
	call set_idt_gate

	mov eax, 46
	mov ebx, irq14
	call set_idt_gate

	mov eax, 47
	mov ebx, irq15
	call set_idt_gate


	call set_idt

	ret

; array containing pointers to messages of interrupts code
exception_messages: dd expt_msg0, expt_msg1, expt_msg2, expt_msg3, expt_msg4, expt_msg5, expt_msg6, expt_msg7, expt_msg8, expt_msg9, expt_msg10, expt_msg11, expt_msg12, expt_msg13, expt_msg14, expt_msg15, expt_msg16, expt_msg17, expt_msg18, expt_msg19, expt_msg20, expt_msg21, expt_msg22, expt_msg23, expt_msg24, expt_msg25, expt_msg26, expt_msg27, expt_msg28, expt_msg29, expt_msg30, expt_msg31

expt_msg0: db "Divsion by 0", 0
expt_msg1: db "Debug", 0
expt_msg2: db "Non Maskable Interrupt", 0
expt_msg3: db "Breakpoint", 0
expt_msg4: db "Into Detected Overflow", 0
expt_msg5: db "Out of Bunds", 0
expt_msg6: db "Invalid Opcode", 0
expt_msg7: db "No coprocessor", 0

expt_msg8: db "Double Fault", 0
expt_msg9: db "Coprocessor Segment Overrun", 0
expt_msg10: db "Bad TSS", 0
expt_msg11: db "Segment Not Present", 0
expt_msg12: db "Stack Fault", 0
expt_msg13: db "General Protection", 0
expt_msg14: db "Page Fault", 0
expt_msg15: db "Unkown Interrupt", 0

expt_msg16: db "Coprocessor Fault", 0
expt_msg17: db "Aligment Check", 0
expt_msg18: db "Machine Check", 0
expt_msg19: db "Reserved", 0
expt_msg20: db "Reserved", 0
expt_msg21: db "Reserved", 0
expt_msg22: db "Reserved", 0
expt_msg23: db "Reserved", 0

expt_msg24: db "Reserved", 0
expt_msg25: db "Reserved", 0
expt_msg26: db "Reserved", 0
expt_msg27: db "Reserved", 0
expt_msg28: db "Reserved", 0
expt_msg29: db "Reserved", 0
expt_msg30: db "Reserved", 0
expt_msg31: db "Reserved", 0

global isr_handler
; Params:
;  eax - the interrupt number code
isr_handler:
	push edi

	mov edi, receive_msg
	call kprint

	; print the interrupt code
	mov edi, num_str
	call int_to_hex
	call kprint

	mov edi, new_line
	call kprint

	; print the corresponding interrupt code message
	mov edi, [exception_messages + eax*4] ; get the string from the interrupt codes table
	call kprint

	mov edi, new_line
	call kprint

	pop edi

	ret

global register_interrupt_handler
; put a handler in the handler interrupt table in some index
; Params:
; al - interrupt index in table
; ebx - the handler function
register_interrupt_handler:
	push eax
	movzx eax, al
	mov DWORD [interrupt_handlers + eax*4], ebx
	pop eax
	ret

global irq_handler
; handle the irq
; Params:
;  ecx - address to registers_type
irq_handler:
	pushad
	; send an EOI to the PICs
	cmp DWORD [ecx + 36], 40
	jb .port_byte_if
	mov al, 0x20
	out 0xA0, al ; slave
.port_byte_if:
	mov al, 0x20
	out 0x20, al ; master

	; if the interrupt code is 0 handle it
	mov ecx, DWORD [ecx + 36]
	mov ecx, DWORD [interrupt_handlers + ecx*4]
	cmp ecx, 0
	je .handle_interrupt_if
	call ecx
.handle_interrupt_if:

	popad
	ret

receive_msg: db "received interrupt: ", 0
