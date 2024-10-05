import os, time

t = time.time()

def bootloader_size(file_path):
	with open(file_path, "rb") as file:
		bs = file.read()
		i = 510 -1
		while bs[i] == 0:
			i -= 1
		size = i
	return size, 510-size

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

if os.name not in ['nt', 'posix']:
    raise Exception("platform not suported")

sep = "\\" if os.name == 'nt' else "/"

bootloader = f'bootloader{sep}bootloader'
kernel_entry = f'bootloader{sep}kernel_entry'

driver_keyboard = f'drivers{sep}keyboard'
driver_VBE_init = f'drivers{sep}VBE_graphics{sep}init_VBE'
driver_VBE_print = f'drivers{sep}VBE_graphics{sep}print_VBE'
driver_VBE_font = f'drivers{sep}VBE_graphics{sep}font'

kernel = f'kernel{sep}kernel'
utils = f'kernel{sep}utils'
kalloc = f'kernel{sep}kalloc'
constants = f'kernel{sep}constants'
shell = f'kernel{sep}shell'

cpu_idt = f'cpu{sep}idt'
cpu_interrupt = f'cpu{sep}interrupt'
cpu_isr = f'cpu{sep}isr'
cpu_timer = f'cpu{sep}timer'

output = 'tempos.img'

# compile bootloader
cmd(f'nasm {bootloader}.asm -fbin -o {bootloader}.bin')
print(bootloader_size(f'{bootloader}.bin'))
# compile drivers
cmd(f'nasm -Wa {driver_keyboard}.asm -felf -o {driver_keyboard}.o')
cmd(f'nasm -Wa {driver_VBE_init}.asm -felf -o {driver_VBE_init}.o')
cmd(f'nasm -Wa {driver_VBE_print}.asm -felf -o {driver_VBE_print}.o')
cmd(f'nasm -Wa {driver_VBE_font}.asm -felf -o {driver_VBE_font}.o')

# compile kernel
cmd(f'nasm {kernel}.asm -felf -o {kernel}.o')
cmd(f'nasm {utils}.asm -felf -o {utils}.o')
cmd(f'nasm {kalloc}.asm -felf -o {kalloc}.o')
cmd(f'nasm {constants}.asm -felf -o {constants}.o')
cmd(f'nasm {shell}.asm -felf -o {shell}.o')

# compile cpu
cmd(f'nasm {cpu_idt}.asm -felf -o {cpu_idt}.o')
cmd(f'nasm {cpu_interrupt}.asm -felf -o {cpu_interrupt}.o')
cmd(f'nasm {cpu_isr}.asm -felf -o {cpu_isr}.o')
cmd(f'nasm {cpu_timer}.asm -felf -o {cpu_timer}.o')

# compile kernel_entry
cmd(f'nasm {kernel_entry}.asm -felf -o {kernel_entry}.o')
# link kernel_entry, kernel and everything else together
link_all_args = "-T NUL" if os.name == 'nt' else "-m elf_i386"
cmd(f'ld {link_all_args } -o {kernel}.tmp -Ttext 0x1000 {kernel_entry}.o {kernel}.o {utils}.o {kalloc}.o {constants}.o {shell}.o {driver_keyboard}.o {driver_VBE_init}.o {driver_VBE_print}.o {driver_VBE_font}.o {cpu_idt}.o {cpu_interrupt}.o {cpu_isr}.o {cpu_timer}.o')
cmd(f'objcopy -O binary -j .text {kernel}.tmp {kernel}.bin')

# join bootloader and kernel into the output file
if os.name == 'nt':
    cmd(f'copy /b {bootloader}.bin+{kernel}.bin {output}')
elif os.name == 'posix':
    cmd(f'cat {bootloader}.bin {kernel}.bin > {output}')

# create the virtual machine in qemu
#cmd(f'qemu-system-x86_64 -fda {output}')
cmd(f'qemu-system-i386 -drive file={output},format=raw,index=0,if=floppy')

delete = "del" if os.name == 'nt' else "rm"
# clean up intermediate files
# in bootloader
cmd(f'{delete} {bootloader}.bin')
cmd(f'{delete} {kernel_entry}.o')
# in kernel
cmd(f'{delete} {kernel}.o')
cmd(f'{delete} {kernel}.tmp')
cmd(f'{delete} {kernel}.bin')
cmd(f'{delete} {utils}.o')
cmd(f'{delete} {kalloc}.o')
cmd(f'{delete} {constants}.o')
cmd(f'{delete} {shell}.o')
# in drivers
cmd(f'{delete} {driver_keyboard}.o')
cmd(f'{delete} {driver_VBE_init}.o')
cmd(f'{delete} {driver_VBE_print}.o')
cmd(f'{delete} {driver_VBE_font}.o')
# in cpu
cmd(f'{delete} {cpu_idt}.o')
cmd(f'{delete} {cpu_interrupt}.o')
cmd(f'{delete} {cpu_isr}.o')
cmd(f'{delete} {cpu_timer}.o')

print(time.time() - t)
