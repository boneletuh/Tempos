bits 16
switch_to_32bit_PM:
	; disable interrupts
    cli
	; load the GDT
    lgdt [GDT_descriptor]
	; enable PM
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	; far jump to code segment descriptor in the GDT
	; to load CS with proper 32bit PM descriptor
	jmp CODE_SEGMENT:init_PM

bits 32
init_PM:
	; set up the data segment registers
	mov ax, DATA_SEGMENT
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	; set up the new stack frame
	mov ebp, 0x9000
	mov esp, ebp

	jmp execute_kernel