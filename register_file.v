/*
This is a memory. It contains the registers defined by the architecture.
Here we have 32 general porpuse risc-v registers x_0 to x_31
cpu register is a memory location that can be accesses exteremly fast
on fpga this memory is synthesized as BRAM.

once an instruction is run and finished, we may want to write something
(perhaps the results) back to a certain register.
which register is decided by the decoder.
also the decoder decides if we are going to write anything at all.
the decoder makes these decisions based on the instruction bitstream.

here we also have two ports for pulling out register arguments.

*/
module register_file #(
	parameter register_width = 0,
	parameter is_float = 0
) (

  	input 								clk,
	input 								resetn,
	input								isFloat,
	input   [register_width - 1 : 0]    register_to_write_data,      	// Data for write back register
	input   [5 - 1 : 0]     			register_to_write_addr,   	// Register number to write back to
	input                   			register_to_write_en,    		// Dont actually write back unless asserted
	input   [5 - 1 : 0]     			rs1_addr,    				// Register number for out1
	input   [5 - 1 : 0]     			rs2_addr,    				// Register number for out2
	input   [5 - 1 : 0]     			rs3_addr,    				// Register number for out2
	
	output  [register_width - 1 : 0]    rs1_value,
	output  [register_width - 1 : 0]    rs2_value,
	output  [register_width - 1 : 0]    rs3_value
);




	localparam registers_count = 32;


	reg	 [3-1 :0]	register_verbose = 0;
  
    reg[48 - 1 :1] reg_labels [registers_count - 1: 0];

	initial begin 
		reg_labels[0 ] = (is_float) ? "ft0"   : "zero";
		reg_labels[1 ] = (is_float) ? "ft1"   : "ra";
		reg_labels[2 ] = (is_float) ? "ft2"   : "sp";
		reg_labels[3 ] = (is_float) ? "ft3"   : "gp";
		reg_labels[4 ] = (is_float) ? "ft4"   : "tp";
		reg_labels[5 ] = (is_float) ? "ft5"   : "t0";
		reg_labels[6 ] = (is_float) ? "ft6"   : "t1";
		reg_labels[7 ] = (is_float) ? "ft7"   : "t2";
		reg_labels[8 ] = (is_float) ? "fs0"   : "s0/fp";
		reg_labels[9 ] = (is_float) ? "fs1"   : "s1";
		reg_labels[10] = (is_float) ? "fa0"   : "a0";
		reg_labels[11] = (is_float) ? "fa1"   : "a1";
		reg_labels[12] = (is_float) ? "fa2"   : "a2";
		reg_labels[13] = (is_float) ? "fa3"   : "a3";
		reg_labels[14] = (is_float) ? "fa4"   : "a4";
		reg_labels[15] = (is_float) ? "fa5"   : "a5";
		reg_labels[16] = (is_float) ? "fa6"   : "a6";
		reg_labels[17] = (is_float) ? "fa7"   : "a7";
		reg_labels[18] = (is_float) ? "fs2"   : "s2";
		reg_labels[19] = (is_float) ? "fs3"   : "s3";
		reg_labels[20] = (is_float) ? "fs4"   : "s4";
		reg_labels[21] = (is_float) ? "fs5"   : "s5";
		reg_labels[22] = (is_float) ? "fs6"   : "s6";
		reg_labels[23] = (is_float) ? "fs7"   : "s7";
		reg_labels[24] = (is_float) ? "fs8"   : "s8";
		reg_labels[25] = (is_float) ? "fs9"   : "s9";
		reg_labels[26] = (is_float) ? "fs10"  : "s10";
		reg_labels[27] = (is_float) ? "fs11"  : "s11";
		reg_labels[28] = (is_float) ? "ft8"   : "t3";
		reg_labels[29] = (is_float) ? "ft9"   : "t4";
		reg_labels[30] = (is_float) ? "ft10"  : "t5";
		reg_labels[31] = (is_float) ? "ft11"  : "t6";

	end






	reg [register_width - 1 : 0] 	regs	[registers_count - 1	:	0];



	integer i;


	always @(posedge resetn) begin

		for(i = 0; i < registers_count; i = i + 1) begin
			regs[i] = 0;
		end

	end



	// Actual register file storage
	always @(posedge clk) begin

		if ((register_to_write_en) && (register_to_write_addr > 0)) begin // Only write back when inEn is asserted, not all instructions write to the register file!
			regs[register_to_write_addr] = register_to_write_data;
		

			if (register_verbose == 1) $display("`			%s: storing %b at %d", (isFloat) ? "Float RF" : "RF", register_to_write_data, register_to_write_addr);
			

			for(i = 0; i < registers_count; i = i + 1) begin

				if (isFloat) begin
					if (register_verbose == 1) $display("'\t\tRF[%d] (%s):(%f)  (0x %h)  %b", i, reg_labels[i], $bitstoreal(toolkit.display_float(regs[i])), regs[i], regs[i]);
				end else begin
					if (register_verbose == 1) $display("'\t\tRF[%d] (%s):(%d)  (0x %h)  %b", i, reg_labels[i], $signed(regs[i]), regs[i], regs[i]);

				end

			end
			
		
		end
		



	end

	// Output registers
	assign rs1_value = regs[rs1_addr];
	assign rs2_value = regs[rs2_addr];
	assign rs3_value = regs[rs3_addr];

endmodule