SHELL=/bin/sh


# 32 old way  -march=rv32i -mabi=ilp32
# default:

# 	riscv64-unknown-elf-gcc -I. -O0 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c $(foo).c

# 	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   putchar.s -o putchar.o
# 	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax wait.S -o wait.o 
# 	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax start.s -o start.o 

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c print.c

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c memcpy.c

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c errno.c

# 	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   perf.S -o perf.o

# 	# original
# 	# riscv64-unknown-elf-ld -T bram.ld -m elf32lriscv -nostdlib $(foo).o putchar.o wait.o memcpy.o errno.o perf.o /opt/riscv/lib/gcc/riscv64-unknown-elf/12.2.0/libgcc.a -o $(foo).bram.elf
	
# 	# removing perf
# 	riscv64-unknown-elf-ld -T bram.ld -m elf32lriscv -nostdlib $(foo).o putchar.o wait.o memcpy.o errno.o /opt/riscv/lib/gcc/riscv64-unknown-elf/12.2.0/libgcc.a -o $(foo).bram.elf

# 	# ./firmware_words $(foo).bram.elf -ram 3144 -max_addr 3144 -out ../program.hex
# 	# ./firmware_words $(foo).bram.elf -ram 3144 -max_addr 3144 -out $(foo).bram.hex
# 	riscv64-unknown-elf-objcopy --verilog-data-width 4 -O verilog $(foo).bram.elf ../program.hex
	
	
	
	
# 	riscv64-unknown-elf-objdump -d -M no-aliases $(foo).bram.elf



# 64  -march=rv64i -mabi=lp64
# the linker for 64 works only without perf. 
# the firmware_words can not extract hex from the elf. probably only works with 32.
# default:

# 	riscv64-unknown-elf-gcc -I. -O0 -fno-pic -march=rv64i -mabi=lp64 -fno-stack-protector -w -Wl,--no-relax  -c $(foo).c

# 	riscv64-unknown-elf-as -march=rv64i -mabi=lp64   putchar.s -o putchar.o
# 	riscv64-unknown-elf-as -march=rv64i -mabi=lp64 -mno-relax wait.S -o wait.o 
# 	riscv64-unknown-elf-as -march=rv64i -mabi=lp64 -mno-relax start.s -o start.o 

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv64i -mabi=lp64 -fno-stack-protector -w -Wl,--no-relax  -c print.c

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv64i -mabi=lp64 -fno-stack-protector -w -Wl,--no-relax  -c memcpy.c

# 	riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv64i -mabi=lp64 -fno-stack-protector -w -Wl,--no-relax  -c errno.c

# 	# riscv64-unknown-elf-as -march=rv64i -mabi=lp64   perf.S -o perf.o

# 	# original
# 	# riscv64-unknown-elf-ld -T bram.ld -m elf64lriscv -nostdlib $(foo).o putchar.o wait.o memcpy.o errno.o perf.o /opt/riscv/lib/gcc/riscv64-unknown-elf/12.2.0/libgcc.a -o $(foo).bram.elf
	
	
# 	# remove perf
# 	riscv64-unknown-elf-ld -T bram.ld -m elf64lriscv -nostdlib $(foo).o putchar.o wait.o memcpy.o errno.o /opt/riscv/lib/gcc/riscv64-unknown-elf/12.2.0/libgcc.a -o $(foo).bram.elf




# 	riscv64-unknown-elf-objcopy --verilog-data-width 4 -O verilog $(foo).bram.elf ../program.hex
	
# 	riscv64-unknown-elf-objdump -d -M no-aliases $(foo).bram.elf

march := rv32if
mabi := ilp32f
build := riscv_rv32if_ilp32f_new_instructions_v3
# ./configure --prefix=/opt/riscv_rv64if_lp64f -with-arch=rv64if --with-abi=lp64f
# ./configure --prefix=/opt/riscv_multilib --enable-multilib
# ./configure --prefix=/opt/riscv_rv32if_ilp32f -with-arch=rv32if --with-abi=ilp32f

# ./configure --prefix=/opt/riscv_rv32if_ilp32f_new_instructions_v1 -with-arch=rv32if --with-abi=ilp32f 
# ./configure --prefix=/opt/riscv_rv32if_ilp32f_new_instructions_v3 -with-arch=rv32if --with-abi=ilp32f 


riscv:
	
	# @gcc -Wall $(foo).c -o $(foo) -lm


	riscv32-unknown-elf-as -march=$(march) -mabi=$(mabi) -mno-relax start.s -o start.o 
	riscv32-unknown-elf-gcc -I. -O2 -fno-pic -march=$(march) -mabi=$(mabi) -fno-stack-protector -w -Wl,--no-relax  -c errno.c




	# using gcc
	# @riscv32-unknown-elf-gcc -std=c++14 -O0 -fno-pic -march=$(march) -mabi=$(mabi) -fno-stack-protector -w -Wl,--no-relax -c $(foo).c -lstdc++ -lm
	# @riscv32-unknown-elf-ld -T bram.ld -m elf32lriscv -nostdlib $(foo).o -o $(foo).bram.elf



	# using g++
	riscv32-unknown-elf-g++ -std=c++14 -march=$(march) -mabi=$(mabi) -T bram.ld  -nostdlib errno.o /opt/$(build)/lib/gcc/riscv32-unknown-elf/12.2.0/libgcc.a $(foo).c -o $(foo).bram.elf -lm





	riscv32-unknown-elf-objcopy --verilog-data-width 4 -O verilog $(foo).bram.elf ../program.hex
	riscv32-unknown-elf-objdump -d -M no-aliases $(foo).bram.elf
	# @riscv32-unknown-elf-objdump --disassemble=main -M no-aliases $(foo).bram.elf



gcc:
	g++ -Wall -Wdouble-promotion $(foo).c -o $(foo) -lm
	./$(foo)
