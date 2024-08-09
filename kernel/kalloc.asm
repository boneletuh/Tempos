bits 32

; address to the first chunk of free memory
mem_addr: dd 0x10000

global mmap
; returns a free aligned paget o 4096B bytes
; Output:
;  edi - physical address of the page 
mmap:
	; get the free page
	mov edi, DWORD [mem_addr]
	; increment the pointer to another free page
	add DWORD [mem_addr], 0x1000
	ret
