# Edge Solver
This repo contains the Edge Solver source code running based on an RV32IF RISC-V computing core all written in Verilog.

[A live demo of this work is presented here.](https://parniatech.com/demo)




Steps to use this computing core on your Linux machine:

1. Write a C code of choice

2. Use the MAKE file to compile your code into assembly (see the workflow section in below)

3. Now you can use this computing core to execute the assembly instructions.

This RISC-V core executes the instructions under simulation. All simulations are performed by [APIO](https://apiodoc.readthedocs.io/en/stable/) which is an open source ecosystem for open FPGA boards.


As always, no licensing. Free to the public with no limitation :)



### Requirements:

You need to install `apio` for your python env.

    $ pip install apio
and then

    $ apio install --all

If you are new to `apio` here is [a good tutorial for it](https://www.youtube.com/watch?v=lLg1AgA2Xoo&list=PLEBQazB0HUyT1WmMONxRZn9NmQ_9CIKhb).

Next, you need to download [GNU GCC compiler for RISC-V](https://github.com/riscv-collab/riscv-gnu-toolchain) one your machine.

then you need to inject my custom instructions into the toolchain and finally build the toolchain following the instructions provided by toolchain github repo.

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

