NASM_FLAGS = -Wa
bootloader = bootloader/bootloader
kernel_entry = bootloader/kernel_entry

driver_keyboard = drivers/keyboard
driver_VBE_init = drivers/VBE_graphics/init_VBE
driver_VBE_print = drivers/VBE_graphics/print_VBE
driver_VBE_font = drivers/VBE_graphics/font

kernel = kernel/kernel
utils = kernel/utils
kalloc = kernel/kalloc
constants = kernel/constants
shell = kernel/shell

cpu_idt = cpu/idt
cpu_interrupt = cpu/interrupt
cpu_isr = cpu/isr
cpu_timer = cpu/timer

output = tempos.img

all: run

run: compile execute clean

compile:
	# compile bootloader
	nasm ${NASM_FLAGS} ${bootloader}.asm -fbin -o ${bootloader}.bin

	# compile drivers
	nasm ${NASM_FLAGS} ${driver_keyboard}.asm -felf -o ${driver_keyboard}.o
	nasm ${NASM_FLAGS} ${driver_VBE_init}.asm -felf -o ${driver_VBE_init}.o
	nasm ${NASM_FLAGS} ${driver_VBE_print}.asm -felf -o ${driver_VBE_print}.o
	nasm ${NASM_FLAGS} ${driver_VBE_font}.asm -felf -o ${driver_VBE_font}.o

	# compile kernel
	nasm ${NASM_FLAGS} ${kernel}.asm -felf -o ${kernel}.o
	nasm ${NASM_FLAGS} ${utils}.asm -felf -o ${utils}.o
	nasm ${NASM_FLAGS} ${kalloc}.asm -felf -o ${kalloc}.o
	nasm ${NASM_FLAGS} ${constants}.asm -felf -o ${constants}.o
	nasm ${NASM_FLAGS} ${shell}.asm -felf -o ${shell}.o

	# compile cpu
	nasm ${NASM_FLAGS} ${cpu_idt}.asm -felf -o ${cpu_idt}.o
	nasm ${NASM_FLAGS} ${cpu_interrupt}.asm -felf -o ${cpu_interrupt}.o
	nasm ${NASM_FLAGS} ${cpu_isr}.asm -felf -o ${cpu_isr}.o
	nasm ${NASM_FLAGS} ${cpu_timer}.asm -felf -o ${cpu_timer}.o

	# compile kernel_entry
	nasm ${NASM_FLAGS} ${kernel_entry}.asm -felf -o ${kernel_entry}.o
	# link kernel_entry, kernel and everything else together
	#ld -T NUL -o ${kernel}.tmp -Ttext 0x1000 ${kernel_entry}.o ${kernel}.o ${utils}.o ${kalloc}.o ${constants}.o ${shell}.o ${driver_keyboard}.o ${driver_VBE_init}.o ${driver_VBE_print}.o ${driver_VBE_font}.o ${cpu_idt}.o ${cpu_interrupt}.o ${cpu_isr}.o ${cpu_timer}.o
	ld -m elf_i386 -o ${kernel}.tmp -Ttext 0x1000 ${kernel_entry}.o ${kernel}.o ${utils}.o ${kalloc}.o ${constants}.o ${shell}.o ${driver_keyboard}.o ${driver_VBE_init}.o ${driver_VBE_print}.o ${driver_VBE_font}.o ${cpu_idt}.o ${cpu_interrupt}.o ${cpu_isr}.o ${cpu_timer}.o
	objcopy -O binary -j .text ${kernel}.tmp ${kernel}.bin

	# join bootloader and kernel into the output file
	#copy /b ${bootloader}.bin+${kernel}.bin ${output}
	cat ${bootloader}.bin ${kernel}.bin > ${output}

execute:
	# create the virtual machine in qemu
	qemu-system-x86_64 -drive file=${output},format=raw,index=0,if=floppy



clean:
	# clean up intermediate files
	# in bootloader/
	rm ${bootloader}.bin
	rm ${kernel_entry}.o
	# in kernel/
	rm ${kernel}.o
	rm ${kernel}.tmp
	rm ${kernel}.bin
	rm ${utils}.o
	rm ${kalloc}.o
	rm ${constants}.o
	rm ${shell}.o
	# in drivers/
	rm ${driver_keyboard}.o
	rm ${driver_VBE_init}.o
	rm ${driver_VBE_print}.o
	rm ${driver_VBE_font}.o
	# in cpu/
	rm ${cpu_idt}.o
	rm ${cpu_interrupt}.o
	rm ${cpu_isr}.o
	rm ${cpu_timer}.o
