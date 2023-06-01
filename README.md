# Edge Solver
This repo contains the Edge Solver source code running based on an RV32IF RISC-V computing core all written in Verilog.

The root folder contains ALU, FPU, register file, and memory file.

### Requirements:

You need to install `iverilog` on your machine.

    $ sudo apt-get install iverilog


### Workflow:

Folder [hex_c](./hex_c) contains the make file to build your C code and generate 
the hex instructions. The make file also stores these instructions in [program.hex](./program.hex).
This file in turn is fed to the [soc.v](./soc.v) which is the core to all other parts.

[soc_tb.v](soc_tb.v) is the test bench for the main module which is [soc.v](soc.v).

To run the SOC with the provided [program.hex](./program.hex), all you need to do is running `apio`.
I made a python file that does this plus some cleanings. So you just need to run [run.py](./run.py):

    $ python run.py


Folder [./dumps](./dumps) folder is where simulation outputs are dumped.


### Parts:

* #### SOC
This is the main module. It connects all the other parts together.
It is well commented, so you can figure things out by reading [soc.v](soc.v).

* #### ALU
This is the arithmetic logic unit that handles the integer instructions.
ALU comes in only one module which is [alu.v](alu.v).

* #### FPU
This is the floating-point unit which handles floating-point operations.
All the files starting with `fpu_` contribute to the FPU.
Note that `div` and `sqrt` are handles separately by [fpu_division](./fpu_division.v) and [fpu_sqrt](./fpu_sqrt.v), respectively.

* #### Register File
This would be [register_file.v](register_file.v).
Both ALU and FPU register modules are instantiated from this module.

* #### SOC Memory file
This would be [memory.v](memory_frame.v). 
Note that, as mentioned above, our memory is initially loaded with [program.hex](program.hex).

* #### Edge Solver Memory file
This would be [memory_frame.v](memory_frame.v). The solver uses this file for its own business.




### Credits:
* I started learning RISC-V by following this [awesome tutorial](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/README.md). You are highly recommended to first go through this tutorial before reading my codes.
* Next I added FPU commands following [this unbelivebly well-detailed work](https://www.youtube.com/watch?v=rYkVdJnVJFQ&list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs&index=1).
* And for general Verilog training I can not be anymore grateful to this [amazing website](https://projectf.io/).