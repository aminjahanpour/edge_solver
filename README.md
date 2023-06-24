# Edge Solver
This repo contains the Edge Solver source code running based on an RV32IF RISC-V computing core all written in Verilog.

### Live Demo
[A live demo of this work is presented here.](https://parniatech.com/demo)
The demo runs on the cloud by a Flask API.



### Steps to use this computing core on your Linux machine:

1. Write a C code of choice

2. Use the MAKE file to compile your code into assembly (details in Workflow section in below)

3. Now you can use this computing core to execute the assembly instructions.

#### Notes:
- This RISC-V core executes the instructions under simulation.
- All simulations are performed by [APIO](https://apiodoc.readthedocs.io/en/stable/) which is an open source ecosystem for open FPGA boards.
- This computing core is not pipelined.

#### Licencing:
As always, no licensing. Free to the public with no limitation :)



### Requirements:

You need to install `apio` for your python env.

    $ pip install apio
and then

    $ apio install --all

If you are new to `apio` here is [a good tutorial for it](https://www.youtube.com/watch?v=lLg1AgA2Xoo&list=PLEBQazB0HUyT1WmMONxRZn9NmQ_9CIKhb).

Next, you need to download [GNU GCC compiler for RISC-V](https://github.com/riscv-collab/riscv-gnu-toolchain) one your machine.

then you need to inject my custom instructions into the toolchain and finally build the toolchain following the instructions provided by toolchain GitHub repo.


### Custom Instructions

I have created 5 new instructions to be added to existing RISC-V ones.
What they do and their usage is well explained [in here](https://parniatech.com/demo).
Here we go through how to add them to the GNU toolchain before building it.

First of all, here are a number of great tutorials that go through great details about hot to add custom instructions to the toolchain.
1. [Tutorial 1](https://hsandid.github.io/posts/risc-v-custom-instruction/)
2. [Tutorial 2](https://medium.com/@viveksgt/adding-custom-instructions-compilation-support-to-riscv-toolchain-78ce1b6efcf4)
3. [Tutorial 3](https://phdbreak99.github.io/riscv-training/16-demo.custom-inst/)

If you fully read the first tutorial, then you'd know what to do with my new instructions but I go through it anyway.

1. modifying **riscv-opc.c**
    
    add these lines to `/binutils/opcodes/riscv-opc.c` as new items under `const struct riscv_opcode riscv_opcodes[]`
    
* {"par_rst", 0, INSN_CLASS_F, "D,S,T", MATCH_PAR_RST, MASK_PAR_RST, match_opcode, 0},
* {"par_ask", 0, INSN_CLASS_F, "D,S,T", MATCH_PAR_ASK, MASK_PAR_ASK, match_opcode, 0},
* {"par_tell", 0, INSN_CLASS_F, "D,S,T", MATCH_PAR_TELL, MASK_PAR_TELL, match_opcode, 0},
* {"par_print_int", 0, INSN_CLASS_F, "D,S,T", MATCH_PAR_PRINT_INT, MASK_PAR_PRINT_INT, match_opcode, 0},
* {"par_print_float", 0, INSN_CLASS_F, "D,S,T", MATCH_PAR_PRINT_FLOAT, MASK_PAR_PRINT_FLOAT, match_opcode, 0},



2. modifying **riscv-opc.h**

    add these lines to `/binutils/include/opcode/riscv-opc.h` under the `define` section.

  
* #define MATCH_PAR_RST 0xb
* #define MASK_PAR_RST 0xfe00707f
* #define MATCH_PAR_ASK 0x100b
* #define MASK_PAR_ASK 0xfe00707f
* #define MATCH_PAR_TELL 0x200b
* #define MASK_PAR_TELL 0xfe00707f
* #define MATCH_PAR_PRINT_INT 0x2b
* #define MASK_PAR_PRINT_INT 0xfe00707f
* #define MATCH_PAR_PRINT_FLOAT 0x102b
* #define MASK_PAR_PRINT_FLOAT 0xfe00707f


add these lines to `/binutils/include/opcode/riscv-opc.h` under the `DECLARE` secion.


* DECLARE_INSN(par_rst, MATCH_PAR_RST, MASK_PAR_RST)
* DECLARE_INSN(par_ask, MATCH_PAR_ASK, MASK_PAR_ASK)
* DECLARE_INSN(par_tell, MATCH_PAR_TELL, MASK_PAR_TELL)
* DECLARE_INSN(par_print_int, MATCH_PAR_PRINT_INT, MASK_PAR_PRINT_INT)
* DECLARE_INSN(par_print_float, MATCH_PAR_PRINT_FLOAT, MASK_PAR_PRINT_FLOAT)


3. repeat step 2 for `/gdb/include/opcode/riscv-opc.h`.

Now you are ready to build the toolchain by following steps under [Installation (Newlib)](https://github.com/riscv-collab/riscv-gnu-toolchain).
Notes:
* Expect something around one hour for build time.
* Make sure you include the build folder in the path. You need to end up with something like this in your path: `/opt/riscv_toolchain/bin`


### Workflow:

Folder [hex_c](./hex_c) contains the make file to build your C code and generate 
the hex instructions.


This is how you can use the make file:

    $ make riscv foo=opt

where `opt` is the name of your C file. The make file builds and links your code with g++.
It allows you to include <code>math.h</code> file and use its functions. Then it generates the hex commands
and overwrites them into [program.hex](./program.hex) in the root folder. 
This file in turn is fed to the [soc.v](./soc.v) which is the core to all other parts.
Finally, it shows you the disassembly of your code.


To run the SOC with the new [program.hex](./program.hex), all you need to do is running `apio`.
I made a python file that does this plus some cleanings. So you just need to run [run.py](./run.py):

    $ python run.py





### Parts:

* #### [SOC](soc.v)
This is the main module. It connects all the other parts together.
It is well commented, so you can figure things out by reading it.

* #### [ALU](alu.v)
This is the arithmetic logic unit that handles the integer instructions.


* #### [FPU](fpu.v)
This is the floating-point unit which handles floating-point operations.
All the files starting with `fpu_` contribute to the FPU.
Note that `div` and `sqrt` are handles separately by [fpu_division](./fpu_division.v) and [fpu_sqrt](./fpu_sqrt.v), respectively.

* #### [Register File](register_file.v)
Both ALU and FPU register modules are instantiated from this module.

* #### [SOC Memory file](memory.v)
Note that, as mentioned above, our memory is initially loaded with [program.hex](program.hex).

* #### [Edge Solver Memory file](memory_frame.v)
The [Edge Solver](bite_operations.v) uses this file for its own business.


[soc_tb.v](soc_tb.v) is the test bench for the main module which is [soc.v](soc.v).

[./dumps](./dumps) folder is where simulation outputs are dumped.



### Credits:

* The solver used in the Edge Solver technology is based on [BITEOPT by Aleksey Vaneev](https://github.com/avaneev/biteopt).
This is an extremely fast converging single-objective solver which has won black-box competitions.

* I started learning RISC-V by following this [awesome tutorial](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/README.md). You are highly recommended to first go through this tutorial before reading my codes.
* Next I added FPU commands following [this unbelivebly well-detailed work](https://www.youtube.com/watch?v=rYkVdJnVJFQ&list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs&index=1).
* And for general Verilog training I am grateful to this [website](https://projectf.io/).

