bits 32

extern VBE_print, VBE_backspace

extern register_interrupt_handler
extern IRQ1
extern kprint
extern kprint_backspace
extern keyboard_cmd

; FIX: use a pointer to a kernel allocate page
; buffer storing the text written
global keybuff
keybuff: times 256 db 0
; index to the last character in the buffer
global idxbuff
idxbuff: dw 0

global keyboard_callback
keyboard_callback:
	push dx

	in al, 0x60
	call print_letter

	pop dx
	ret

global init_keyboard
; set up the keyboard to be used
init_keyboard:
	push ax
	push ebx

	mov al, IRQ1
	mov ebx, keyboard_callback
	call register_interrupt_handler

	pop ebx
	pop ax
	ret

%define BACKSPACE_SC 0xe
%define NEWLINE_SC 0x1c
; prints a letter to the screen
; Input:
;  al - the scancode
print_letter:
	pushad
	; if the scancode is bigger than 57 dont do anything
	cmp al, 57
	ja .print_letter_end
	cmp al, BACKSPACE_SC
	je .print_letter_backspace
	cmp al, NEWLINE_SC
	je .print_letter_newline

	; make space for a new symbol
	; FIX: this will overflow if the user writtes more than 256 symbols
	; get the symbol from the scancode
	movzx eax, al
	mov al, BYTE [scancode_map + eax]
	; add the symbol to the buffer
	movzx edi, WORD [idxbuff]
	lea edi, [keybuff + edi]
	mov BYTE [edi], al
	; print the symbol
	call VBE_print
	;call kprint
	; update the index
	inc WORD [idxbuff]
	jmp .print_letter_end
.print_letter_backspace:
	; FIX: this will underflow if 'idxbuff' is 0
	; update the cursor and the index to the buffer
	dec WORD [idxbuff]
	call VBE_backspace
	;call kprint_backspace
	; clean the last symbol
	movzx edi, WORD [idxbuff]
	mov BYTE [keybuff + edi], 0
	jmp .print_letter_end
.print_letter_newline:
	call keyboard_cmd
.print_letter_end:
	popad
	ret

scancode_map: db "??1234567890-=??QWERTYUIOP[]??ASDFGHJKL;'`?\ZXCVBNM,./??? ", 0


%if 0
keys: dd error_k, esc_k, n1_k, n2_k, n3_k, n4_k, n5_k, n6_k, n7_k, n8_k, n9_k, n0_k, dash_k, plus_k, backspace_k, tab_k, q_k, w_k, e_k, r_k, t_k, y_k, u_k, i_k, o_k, p_k, open_sqr_bracket_k, close_sqr_bracket_k, enter_k, l_ctlr_k, a_k, s_k, d_k, f_k, g_k, h_k, j_k, k_k, l_k, semi_colon_k, apostrophe_k, backtick_k, l_shift_k, back_slash_k, z_k, x_k, c_k, v_k, b_k, n_k, m_k, comma_k, dot_k, slash_k, r_shift_k, keypad_k, l_alt_k, space_k

error_k: db "ERROR", 0
esc_k: db "ESC", 0
n1_k: db "1", 0
n2_k: db "2", 0
n3_k: db "3", 0
n4_k: db "4", 0
n5_k: db "5", 0
n6_k: db "6", 0
n7_k: db "7", 0
n8_k: db "8", 0
n9_k: db "9", 0
n0_k: db "0", 0
dash_k: db "-", 0
plus_k: db "+", 0
backspace_k: db "BACKSPACE", 0
tab_k: db "TAB", 0
q_k: db "Q", 0
w_k: db "W", 0
e_k: db "E", 0
r_k: db "R", 0
t_k: db "T", 0
y_k: db "Y", 0
u_k: db "U", 0
i_k: db "I", 0
o_k: db "O", 0
p_k: db "P", 0
open_sqr_bracket_k: db "[", 0
close_sqr_bracket_k: db "]", 0
enter_k: db "ENTER", 0
l_ctlr_k: db "LCTRL", 0
a_k: db "A", 0
s_k: db "S", 0
d_k: db "D", 0
f_k: db "F", 0
g_k: db "G", 0
h_k: db "H", 0
j_k: db "J", 0
k_k: db "K", 0
l_k: db "L", 0
semi_colon_k: db ";", 0
apostrophe_k: db "'", 0
backtick_k: db "`", 0
l_shift_k: db "LSHIFT", 0
back_slash_k: db 92, 0
z_k: db "Z", 0
x_k: db "X", 0
c_k: db "C", 0
v_k: db "V", 0
b_k: db "B", 0
n_k: db "N", 0
m_k: db "M", 0
comma_k: db ",", 0
dot_k: db ".", 0
slash_k: db "/", 0
r_shift_k: db "RSHIFT", 0
keypad_k: db "KEYPAD", 0
l_alt_k: db "LALT", 0
space_k: db "SPACE", 0
%endif