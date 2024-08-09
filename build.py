import os, time
t = time.time()

def szbl(file_path):
	with open(file_path, "rb") as file:
		bs = file.read()
		i = 510 -1
		while bs[i] == 0:
			i -= 1
		size = i
	return size, 510-size
# a shorthand
def cmd(command):
    i = time.time()
    '''mode = 'c'
    if os.system(f'cmd /{mode} "{command}"') != 0 and mode == 'c':
        #os.system(f'cmd /k "{command}"')
        os.system(f'cmd /k')
        raise Exception(f'Error in command: {command}')'''
    if os.system(f'{command}') != 0:
        exit(1)
    print(f'{time.time() - i:.3f}s', command)

bootloader = 'bootloader/bootloader'
kernel_entry = 'bootloader/kernel_entry'

driver_ports = 'drivers/ports'
driver_screen = 'drivers/screen'
driver_keyboard = 'drivers/keyboard'
driver_VBE_init = 'drivers/VBE_graphics/init_VBE'
driver_VBE_print = 'drivers/VBE_graphics/print_VBE'
driver_VBE_font = 'drivers/VBE_graphics/font'

kernel = 'kernel/kernel'
utils = 'kernel/utils'
kalloc = 'kernel/kalloc'
constants = 'kernel/constants'

cpu_idt = 'cpu/idt'
cpu_interrupt = 'cpu/interrupt'
cpu_isr = 'cpu/isr'
cpu_timer = 'cpu/timer'

output = 'tempos.iso'

# compile bootloader
cmd(f'nasm {bootloader}.asm -fbin -o {bootloader}.bin')
print(szbl(f'{bootloader}.bin'))
# compile drivers
cmd(f'nasm -Wa {driver_ports}.asm -felf -o {driver_ports}.o')
cmd(f'nasm -Wa {driver_screen}.asm -felf -o {driver_screen}.o')
cmd(f'nasm -Wa {driver_keyboard}.asm -felf -o {driver_keyboard}.o')
cmd(f'nasm -Wa {driver_VBE_init}.asm -felf -o {driver_VBE_init}.o')
cmd(f'nasm -Wa {driver_VBE_print}.asm -felf -o {driver_VBE_print}.o')
cmd(f'nasm -Wa {driver_VBE_font}.asm -felf -o {driver_VBE_font}.o')

# compile kernel
cmd(f'nasm {kernel}.asm -felf -o {kernel}.o')
cmd(f'nasm {utils}.asm -felf -o {utils}.o')
cmd(f'nasm {kalloc}.asm -felf -o {kalloc}.o')
cmd(f'nasm {constants}.asm -felf -o {constants}.o')

# compile cpu
cmd(f'nasm {cpu_idt}.asm -felf -o {cpu_idt}.o')
cmd(f'nasm {cpu_interrupt}.asm -felf -o {cpu_interrupt}.o')
cmd(f'nasm {cpu_isr}.asm -felf -o {cpu_isr}.o')
cmd(f'nasm {cpu_timer}.asm -felf -o {cpu_timer}.o')

# compile kernel_entry
cmd(f'nasm {kernel_entry}.asm -felf -o {kernel_entry}.o')
# link kernel_entry, kernel and everything else together
#cmd(f'ld -T NUL -o {kernel}.tmp -Ttext 0x1000 {kernel_entry}.o {kernel}.o {utils}.o {kalloc}.o  {constants}.o {driver_ports}.o {driver_screen}.o {driver_keyboard}.o {driver_VBE_init}.o {driver_VBE_print}.o {driver_VBE_font}.o {cpu_idt}.o {cpu_interrupt}.o {cpu_isr}.o {cpu_timer}.o')
cmd(f'ld -flto -Oz -s -m elf_i386 -o {kernel}.tmp -Ttext 0x1000 {kernel_entry}.o {kernel}.o {utils}.o {kalloc}.o  {constants}.o {driver_ports}.o {driver_screen}.o {driver_keyboard}.o {driver_VBE_init}.o {driver_VBE_print}.o {driver_VBE_font}.o {cpu_idt}.o {cpu_interrupt}.o {cpu_isr}.o {cpu_timer}.o')
cmd(f'objcopy -O binary -j .text {kernel}.tmp {kernel}.bin')

# join bootloader and kernel into the output file
#cmd(f'copy /b {bootloader}.bin+{kernel}.bin {output}')
cmd(f'cat {bootloader}.bin {kernel}.bin > {output}')

# create the virtual machine in qemu
#cmd(f'qemu-system-x86_64 -fda {output}')
cmd(f'qemu-system-x86_64 -drive file={output},format=raw,index=0,if=floppy')

# clean up intermediate files
# in bootloader/
cmd(f'rm {bootloader}.bin')
cmd(f'rm {kernel_entry}.o')
# in kernel/
cmd(f'rm {kernel}.o')
cmd(f'rm {kernel}.tmp')
cmd(f'rm {kernel}.bin')
cmd(f'rm {utils}.o')
cmd(f'rm {kalloc}.o')
cmd(f'rm {constants}.o')
# in drivers/
cmd(f'rm {driver_ports}.o')
cmd(f'rm {driver_screen}.o')
cmd(f'rm {driver_keyboard}.o')
cmd(f'rm {driver_VBE_init}.o')
cmd(f'rm {driver_VBE_print}.o')
cmd(f'rm {driver_VBE_font}.o')
# in cpu/
cmd(f'rm {cpu_idt}.o')
cmd(f'rm {cpu_interrupt}.o')
cmd(f'rm {cpu_isr}.o')
cmd(f'rm {cpu_timer}.o')
'''cmd(f'del {bootloader}.bin')
cmd(f'del {kernel_entry}.o')
# in kernel/
cmd(f'del {kernel}.o')
cmd(f'del {kernel}.tmp')
cmd(f'del {kernel}.bin')
cmd(f'del {utils}.o')
cmd(f'del {kalloc}.o')
cmd(f'del {constants}.o')
# in drivers/
cmd(f'del {driver_ports}.o')
cmd(f'del {driver_screen}.o')
cmd(f'del {driver_keyboard}.o')
cmd(f'del {driver_VBE_init}.o')
cmd(f'del {driver_VBE_print}.o')
cmd(f'del {driver_VBE_font}.o')
# in cpu/
cmd(f'del {cpu_idt}.o')
cmd(f'del {cpu_interrupt}.o')
cmd(f'del {cpu_isr}.o')
cmd(f'del {cpu_timer}.o')'''

print(time.time() - t)