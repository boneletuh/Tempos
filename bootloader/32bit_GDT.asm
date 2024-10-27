GDT_beginning:
	dq 0x00				; null descriptor

GDT_code:
    dw 0xffff			; limit: maximum addressable memory
    dw 0x0000			; base: address where the segment begins
    db 0x00				; base
    db 0b1_00_1_1_0_1_0	; access byte: ring 0, code segment, readable
	db 0b1100_1111		; flags: 4KB granularity, 32bit PM. + limit
	db 0x00				; base

GDT_data:
	dw 0xffff			; limit: maximum addressable memory
	dw 0x0000			; base: address where the segment begins
	db 0x00				; base
	db 0b1_00_1_0_0_1_0	; access byte: data segment, writtable
	db 0b1100_1111		; flags: 4KB granularity, 32bit PM. + limit
	db 0x00 			; base

GDT_end:


GDT_descriptor:
	dw GDT_end - GDT_beginning - 1
	dd GDT_beginning

CODE_SEGMENT equ GDT_code - GDT_beginning
DATA_SEGMENT equ GDT_data - GDT_beginning
