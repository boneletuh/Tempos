; load 'dh' sectors from drive 'dl' into ES:BX
; Params:
;  dh - number of sectors to load
;  dl - number of the drive to get the sectors from
; Output:
;  es:bx  - pointer to the data that was read
disk_load:
	pusha
	push dx

	mov ah, 0x02 ; read
	mov al, dh   ; number of sectors to read
	mov cl, 0x02 ; the sector where to start reading from, 0x1 is the boot sector
	mov ch, 0x00 ; cylinder
	; dl = drive number
	mov dh, 0x00 ; head number
	int 0x13
	jc disk_error

	pop dx
	; BIOS also sets 'al' to the # of sectors read, check if the reding was succesful
	cmp al, dh
	jne sectors_error
	popa
	ret


disk_error:
	mov bx, DISK_ERROR
	call putstr
	jmp $

sectors_error:
	mov bx, SECTORS_ERROR
	call putstr
	jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0
