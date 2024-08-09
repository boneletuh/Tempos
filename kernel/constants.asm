bits 32
; this file contains some constant values, strings or arrays that are communly used everywhere
; a programm sould never assumme the value of this variables as they could be changed by any function, unless the variable is specified as 'constant'
; it sould also serve as a short documentation of what this value actually do
global new_line
; constant
new_line: db 10, 0

global num_str
; used to store a number as a string when it will be immediately used
num_str: times 20 db 0