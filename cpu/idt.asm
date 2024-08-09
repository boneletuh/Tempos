bits 32
KERNEL_CS equ 0x08
IDT_ENTRIES equ 256

; define the array with the idt gates
idt: times IDT_ENTRIES dq 0 ; uses 'dq' because the size of idt_gate is 8 bytes
idt_reg: times 6 db 0 ; 6 is the size of idt_register in bytes

; FIX: implement this using "struct"
idt_gate_size equ 8 ; the size of the idt_gat in bytes
; idt_gate memory layout:
;  u16 lower bits of handler function address
;  u16 kernel segment selector
;  u8 always set to 0
;  u8  some flags
;   bit7: interrupt is present? (1 if it is 0 if not)
;   bit6-5: privilege level of caller (0 is high, 3 is low)
;   bit4: set to 0 for interupt gates
;   bit3-0: bits 1110  = decimal 14 = 32 bit interrupt address
;  u16 high bits of handler function address

global set_idt_gate
; Params:
;  eax - the index of the idt gate
;  ebx - the function handler address
set_idt_gate:
	push edi
	; the adrress of the idt gate to set
	lea edi, [idt + eax*idt_gate_size]

	mov WORD [edi + 0], bx
	mov WORD [edi + 2], KERNEL_CS
	mov BYTE [edi + 4], 0
	mov BYTE [edi + 5], 0b10001110 ; set the interrupt
	shr ebx, 16 ; get the high bits
	mov WORD [edi + 6], bx

	pop edi
	ret

; array of interrupt handlers
; idt_register memory layout:
;  u16 limit, offset of the last byte in the array
;  u32 base pointer to the array

global set_idt
; set up the idt
set_idt:
	mov WORD  [idt_reg + 0], IDT_ENTRIES * idt_gate_size - 1
	mov DWORD [idt_reg + 2], idt

	lidt [idt_reg]

	ret
