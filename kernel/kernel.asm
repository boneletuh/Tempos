bits 32

; import symbols from other files
extern test_bl_struct ; TEST: DELETE
extern bl_vbe_width, bl_vbe_height, bl_vbe_addr, bl_vbe_bpp
extern clear_screen
extern kprint
extern isr_install
extern init_timer, init_keyboard, tick
extern keybuff, idxbuff
extern waste_time, memory_set, strcmp
extern mmap
extern int_to_hex
extern new_line, num_str
extern init_VBE
extern vbe_screen_sz
extern VBE_print_char, VBE_print, VBE_roll_screen_up


rand_colors:
	pushad
	; load the address of the screen, to write pixels
	mov eax, DWORD [bl_vbe_addr]
	; the amount of bytes to write to
	mov ebx, DWORD [vbe_screen_sz]
	; some random color to fill the screen with
	mov dl, 0x00
.aloop:
	mov BYTE [eax], dl
	inc eax

	; randomize 'dl'
	inc dl
	xor dl, al
	ror dl, 1

	dec ebx
	test ebx, ebx
	jnz .aloop

	popad
	ret

; initializes the IRQs
irq_install:
	sti
	; the timer
	mov ecx, 50
	call init_timer
	; the keyboard
	call init_keyboard

	ret

global _start
_start:
	call isr_install
	call irq_install

	mov edi, cmd_arrow
	call kprint


	call init_VBE
	call rand_colors


	mov edi, tst_str
	call VBE_print

	;mov edi, new_line
	;call VBE_print

	mov edi, tst_str2
	call VBE_print

	;mov edi, new_line
	;call VBE_print

	mov edi, tst_str3
	call VBE_print

	;mov edi, new_line
	;call VBE_print

	mov ebx, 5
.tst_loop:
	call waste_time

	mov eax, ebx
	and eax, 111b

	mov edi, num_str
	call int_to_hex
	call VBE_print

	dec ebx
	jnz .tst_loop


	mov edi, tst_str3
	call VBE_print

	mov edi, new_line
	call VBE_print


%if 0
	mov eax, DWORD [bl_vbe_addr]
	mov edi, num_str
	call int_to_hex
	call kprint
	mov edi, new_line
	call kprint

	movzx eax, WORD [bl_vbe_width]
	mov edi, num_str
	call int_to_hex
	call kprint
	mov edi, new_line
	call kprint

	movzx eax, WORD [bl_vbe_height]
	mov edi, num_str
	call int_to_hex
	call kprint
	mov edi, new_line
	call kprint

	movzx eax, BYTE [bl_vbe_bpp]
	mov edi, num_str
	call int_to_hex
	call kprint
	mov edi, new_line
	call kprint

	mov eax, DWORD [vbe_screen_sz]
	mov edi, num_str
	call int_to_hex
	call kprint
	mov edi, new_line
	call kprint
%endif

	hlt
	ret

global keyboard_cmd
keyboard_cmd:
	push edi
	push ax

	; print a new line to separate the command written from what the command does
	mov edi, new_line
	call VBE_print
	;call kprint

	; match command "PAGE"
	mov edi, page_cmd
	mov esi, keybuff
	call strcmp
	cmp al, 0
	je .keyboard_cmd_handler_time

	; print a free page
	call mmap
	mov eax, edi
	mov edi, num_str
	call int_to_hex
	call VBE_print
	;call kprint
	; end matching for more commands
	jmp .keyboard_cmd_handler_end

.keyboard_cmd_handler_time:
	; match command "TIME"
	mov edi, time_cmd
	mov esi, keybuff
	call strcmp
	cmp al, 0
	je .keyboard_cmd_handler_end

	; get the PIC timer count
	mov eax, DWORD [tick]
	mov edi, num_str
	call int_to_hex
	call VBE_print
	;call kprint
	; end matching for more commands
	jmp .keyboard_cmd_handler_end

.keyboard_cmd_handler_end:
	; clean the buffer from the last written command
	mov edi, 0
.keyboard_cmd_clean_loop:
	cmp BYTE [keybuff + edi], 0
	je .keyboard_cmd_clean_end

	mov BYTE [keybuff + edi], 0

	inc edi
	jmp .keyboard_cmd_clean_loop

.keyboard_cmd_clean_end:
	; update the index to point to the first slot
	mov WORD [idxbuff], 0
	; make it nicer
	mov edi, cmd_arrow
	call VBE_print
	;call kprint

	pop ax
	pop edi
	ret

cmd_arrow: db 10, "> ", 0
time_cmd: db "TIME", 0
page_cmd: db "PAGE", 0

tst_str: db "HOLA CARACOLA QUE TAL ESTAS YO ESTOY BIEN", 0
tst_str2: db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
tst_str3 : db "MONO", 0