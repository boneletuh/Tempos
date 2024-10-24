bits 16
org 0x7C00

KERNEL_OFFSET equ 0x1000

mov BYTE [BOOT_DRIVE], dl

mov bp, 0x9000
mov sp, bp


mov di, BOOT_INIT_STR
call putstr

; activate the A20 line
mov ax, 2401h
int 15h

; this file initializes the screen using VBE
%include "bootloader/set_up_VBE.asm"


call load_kernel
call switch_to_32bit_PM

jmp $

%include "bootloader/print_strings.asm"
%include "bootloader/disk_read.asm"
%include "bootloader/switch_to_32bit_PM.asm"
%include "bootloader/32bit_GDT.asm"
%include "bootloader/print_strings_32bit.asm"

bits 16
load_kernel:
	mov al, 40 ; REMEMBER: number of sectors to read
	mov dl, BYTE [BOOT_DRIVE]
	mov bx, KERNEL_OFFSET
	call disk_load

	mov di, KERNEL_LOADED_STR
	call putstr

	ret

bits 32
execute_kernel:
	call KERNEL_OFFSET
	jmp $


BOOT_DRIVE: db 0

BOOT_INIT_STR db "16bit RM began", 10, 13, 0
KERNEL_LOADED_STR db "kernel loaded", 10, 13, 0

; Funciones del bootloader
;X  activar la linea A20
;  iniciar las VBE
;  imprimir strings 32bit PM
;X cargar el kernel
;X  cargar el GDT de 32 bits
;X  cambiar a PM de 32 bits
;  ejecutar el kernel

times 510-($-$$) db 0
dw 0xAA55