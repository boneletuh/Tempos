bits 32

extern bl_vbe_addr, bl_vbe_width, bl_vbe_height, bl_vbe_bpp

extern tick

extern keybuff, idxbuff

extern strcmp, int_to_hex, int_to_dec

extern VBE_print, VBE_clear_screen

extern num_str, new_line

extern mmap

%define cpuid_leaf_value_processor_brand_string 80000004h

global init_shell
init_shell:
    push edi

    mov edi, cmd_arrow
	call VBE_print

    pop edi
    ret

; print the PIC timer
cmd_time:
	push edi
	push eax

	mov eax, DWORD [tick]
	mov edi, num_str
	call int_to_dec
	call VBE_print

	mov edi, new_line
	call VBE_print

	pop eax
	pop edi
	ret

; prints some parameters about the screen
cmd_vbeinfo:
	push edi
	push eax

	mov eax, DWORD [bl_vbe_addr]
	mov edi, num_str
	call int_to_hex
	call VBE_print
	mov edi, new_line
	call VBE_print

	movzx eax, WORD [bl_vbe_width]
	mov edi, num_str
	call int_to_dec
	call VBE_print
	mov edi, x_string
	call VBE_print

	movzx eax, WORD [bl_vbe_height]
	mov edi, num_str
	call int_to_dec
	call VBE_print
	mov edi, x_string
	call VBE_print

	movzx eax, BYTE [bl_vbe_bpp]
	mov edi, num_str
	call int_to_dec
	call VBE_print
	mov edi, new_line
	call VBE_print

	pop eax
	pop edi
	ret

cmd_cpuid:
	pushad

	; try to set the ID bit from the EFLAGS
	; if it can be set it means the cpuid is free to be used
	pushfd
	pop eax
	push eax
	xor eax, 0x00200000
	push eax
	popfd
	pop ebx

	cmp eax, ebx
	jne .cmd_cpuid_valid_instruction

	mov edi, cpuid_invalid_instruction
	call VBE_print
	jmp .cmd_cpuid_end

.cmd_cpuid_valid_instruction:

	mov eax, 0
	cpuid
	; print the biggest function allowed
	mov edi, num_str
	call int_to_hex
	call VBE_print
	mov edi, new_line
	call VBE_print
	; print the manufacter ID string
	mov DWORD [num_str+0], ebx
	mov DWORD [num_str+4], edx
	mov DWORD [num_str+8], ecx
	mov BYTE [num_str+13], 0
	mov edi, num_str
	call VBE_print
	mov edi, new_line
	call VBE_print

	; print the biggest extended function allowed
	mov eax, 80000000h
	cpuid
	mov edi, num_str
	call int_to_hex
	call VBE_print
	mov edi, new_line
	call VBE_print

	cmp	eax, cpuid_leaf_value_processor_brand_string
	jb .cmd_cpuid_end

	; print the processor brand string
	mov eax, 80000002H
	cpuid
	mov DWORD [num_str+00], eax
	mov DWORD [num_str+04], ebx
	mov DWORD [num_str+08], ecx
	mov DWORD [num_str+12], edx
	mov eax, 80000003H
	cpuid
	mov DWORD [num_str+16], eax
	mov DWORD [num_str+20], ebx
	mov DWORD [num_str+24], ecx
	mov DWORD [num_str+28], edx
	mov eax, 80000004H
	cpuid
	mov DWORD [num_str+32], eax
	mov DWORD [num_str+36], ebx
	mov DWORD [num_str+40], ecx
	mov DWORD [num_str+44], edx
	mov edi, num_str
	call VBE_print
	mov edi, new_line
	call VBE_print

.cmd_cpuid_end:
	popad
	ret

cmd_list:
	push edi
	push esi
	push eax

	mov esi, commands_string_array
	mov eax, commands_count
.cmd_list_loop:
	mov edi, DWORD [esi]
	call VBE_print
	mov edi, new_line
	call VBE_print

	add esi, command_entry_size

	dec eax
	jnz	.cmd_list_loop

	pop eax
	pop esi
	pop edi
	ret


command_entry_size equ 8
; has the commands supported by the shell
;  in a pair: command string and command function 
commands_string_array:
	dd time_cmd_string, cmd_time
	dd vbeinfo_cmd_string, cmd_vbeinfo
	dd cpuid_cmd_string, cmd_cpuid
	dd list_cmd_string, cmd_list
	dd clear_cmd_string, VBE_clear_screen
commands_count equ ($-commands_string_array)/command_entry_size

global keyboard_cmd
keyboard_cmd:
	push edi
	push esi
	push ebx
	push ax

	mov edi, new_line
	call VBE_print

	; searches a match comparing the keyboard buffer to the command strings
	mov esi, keybuff
	mov ebx, 0
.keyboard_cmd_loop:
	mov edi, DWORD [commands_string_array+ebx*command_entry_size]
	call strcmp
	cmp al, 0
	je .keyboard_cmd_didnt_match

	mov edi, DWORD [commands_string_array+ebx*command_entry_size+command_entry_size/2]
	call edi

	jmp .keyboard_cmd_end
.keyboard_cmd_didnt_match:
	add edi, command_entry_size
	inc ebx
	cmp ebx, commands_count
	jb .keyboard_cmd_loop

.keyboard_cmd_end:
	; clean the buffer from the last written command
	mov edi, 0
.keyboard_cmd_clean_loop:
	cmp BYTE [keybuff + edi], 0
	je .keyboard_cmd_clean_end

	mov BYTE [keybuff + edi], 0

	inc edi
	jmp .keyboard_cmd_clean_loop
.keyboard_cmd_clean_end:
	; update the index to point to the first character
	mov WORD [idxbuff], 0

	mov edi, cmd_arrow
	call VBE_print

	pop ax
	pop ebx
	pop esi
	pop edi
	ret


cmd_arrow: db "> ", 0
x_string: db "x", 0

time_cmd_string: db "TIME", 0
vbeinfo_cmd_string: db "VBEINFO", 0
cpuid_cmd_string: db "CPUID", 0
list_cmd_string: db "LIST", 0
clear_cmd_string: db "CLEAR", 0

cpuid_invalid_instruction: db "NOT ABLE TO USE THE CPUID INSTRUCTION", 10, 0