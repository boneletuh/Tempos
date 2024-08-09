; bootloader offset
org 0x7C00

; kernel offset
KERNEL_OFFSET equ 0x1000

bits 16

; the BIOS sets up the boot driver in dl
mov [BOOT_DRIVE], dl
; set the stack
mov bp, 0x9000
mov sp, bp

mov bx, MSG_REAL_MODE
call putstr ; This will be written after the BIOS messages
call print_nl

; this file initializes the screen using VBE
%include "bootloader/init_VBE.asm"

call load_kernel ; load the kernel from disk
call switch_to_pm ; disable interrupts, loads GDT
jmp $ ; this will actually never be executed


%include "bootloader/print_strings.asm"
%include "bootloader/disk_read.asm"
%include "bootloader/32bit_gdt.asm"
%include "bootloader/print_string_32bit.asm"
%include "bootloader/switch_to_32bit.asm"

bits 16
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call putstr
	call print_nl

	mov bx, KERNEL_OFFSET
	mov dh, 40 ; REMEMBER: update this number if the os gets big, it is the number of sectors read (512 bytes)
	mov dl, [BOOT_DRIVE]
	call disk_load
	ret

bits 32
BEGIN_PM: ; after the switch we will get here
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; this will be written at the top left corner
    call KERNEL_OFFSET ; give control to kernel
    jmp $ ; stay here when kernel returns control (if ever)

; we store it in memory in case it gets overwritten
BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16bit RM", 0
MSG_PROT_MODE db "Loaded 32bit PM", 0
MSG_LOAD_KERNEL db "loading kernel", 0

times 510-($-$$) db 0
dw 0xAA55
