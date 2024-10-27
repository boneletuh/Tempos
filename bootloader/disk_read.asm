bits 16
org 0x7C00

; Params:
;  es:bx - address where the readed values will be stored
;  dl - boot drive numbers
;  al - number of sectors to read
disk_load:
    mov cl, 0x02 ; the sector where to start reading from, 0x01 is the boot sector
    mov ch, 0x00 ; cylinder number
    mov dh, 0x00 ; head number
    mov ah, 02h
    int 13h
    ret