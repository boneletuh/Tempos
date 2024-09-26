bits 32

; address to the first chunk of free memory
pages_begin_addr: dd 0x10000
; the size in bytes of a page
page_size equ 0x1000

; FIX: allow to allocat more than one page at a time
; FIX: be able to free a page
; FIX: reuse the pages that are freed
global mmap
; returns an aligned pointer to page of 4096B
; Output:
;  edi - physical address of the page 
mmap:
	; get the free page
	mov edi, DWORD [pages_begin_addr]
	; increment the pointer to another free page
	add DWORD [pages_begin_addr], page_size
	ret
