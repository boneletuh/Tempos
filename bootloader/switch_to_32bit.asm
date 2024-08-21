bits 16

switch_to_pm:
	cli ; disable interrupts
	lgdt [gdt_descriptor] ; load the GDT descriptor
	mov eax, cr0
	or eax, 0x1 ; set 32 bit mode bit in cr0
	mov cr0, eax
	jmp CODE_SEG:init_pm ; far jump by using a different segment

bits 32
; now we are using 32 bit instructions
init_pm:
	; update the segment registers
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; update the stack right at the top of the free space
	mov ebp, 0x90000
	mov esp, ebp

	call BEGIN_PM ; Begin executing useful code in protected mode
