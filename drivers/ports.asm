bits 32

global port_byte_in
; get a byte from a port
; Params:
;  dx  - the port to get the byte
; Output:
;  al - the byte obtained
port_byte_in:
	in al, dx
	ret

global port_byte_out
; sends a byte to a port
; Params:
; al - value to be copied
; dx - port to paste the value
port_byte_out:
	out dx, al
	ret

global port_word_in
; get 2 bytes from a port
; Params:
;  dx  - the port to get the bytes
; Output:
;  ax - the bytes obtained
port_word_in:
	in ax, dx
	ret

global port_word_out
; sends 2 bytes to a port
; Params:
;  ax - value to be copied
;  dx - port to paste the value
port_word_out:
	out dx, ax
	ret
