
module ALU #(
	parameter register_width = 0
) (

	input 			[register_width - 1 : 0] 		aluIn1,
	input 			[register_width - 1 : 0] 		aluIn2,

	input 			[register_width - 1 : 0] 		instr,
	input 			[3 - 1 : 0] 					funct3,
	input 			[7 - 1 : 0] 					funct7,


	input 	   		[5 - 1 :	0]					shift_amount,
	output reg 		[register_width - 1 : 0] 		aluOut
	);


	reg		verbose_alu = 0;


	/*
	aluIn1 = always   rs1
    aluIn2 = either   rs2   OR   Iimm



	funct3	operation
	3'b000	ADD or SUB
	3'b001	left shift
	3'b010	signed comparison (<)
	3'b011	unsigned comparison (<)
	3'b100	XOR
	3'b101	logical right shift or arithmetic right shift
	3'b110	OR
	3'b111	AND



	*/


	always @(*) begin
		// $display("`		'\t funct3:%b, funct7:%b, aluIn1:%b, aluIn2:%b", funct3, funct7, aluIn1, aluIn2);

		case(funct3)
			/*
			ADD rd,rs1,rs2
				funct7==7’b000_0000;


			SUB
				funct7==7’b010_0000,


			ADDI  rd,rs1,imm[11:0]
				funct7==7’b0000000;
				This instruction writes the result of rs1+rs2 into rd, ignoring overflow

			if its an ALUreg operation (Rtype), 
			then one makes the difference between ADD and SUB by testing bit 5 of funct7 (1 for SUB).
			 If it is an ALUimm operation (Itype), then it can be only ADD. In this context,
			  one just needs to test bit 5 of instr to distinguish between ALUreg (if it is 1)
			   and ALUimm (if it is 0).
			*/
			3'b000: begin
				if (verbose_alu) $display("'\t ADD/SUB");
					if (funct7[5] & instr[5]) begin
						if (verbose_alu) $display("'\t minus");

						aluOut = aluIn1 - aluIn2;
					end else begin
						if (verbose_alu) $display("'\t plus");
						aluOut = aluIn1 + aluIn2;
					end
			end






			/*
			logical left shift

			SLL   rd,rs1,rs2
				Funct7==7’b0000000,
				Shift rs1 logically to the left according to the number specified in the lower 5 bits of rs2, 
				fill in the lower bits with zeros, and write the result to rd

			SLLI rd,rs1,shift_amount[4:0]
			*/
			3'b001: begin
				
				if (verbose_alu) $display("'\t left shift");
				
				aluOut = aluIn1 << shift_amount;
			end





			/*
			signed comparison (<)

			Funct7==7’b0000000;

			SLT rd, rs1,rs2:
				rs1 and rs2 are compared with signed numbers,
				if rs1<rs2, rd is set to 1, otherwise it is set to 0

			SLTI  rd,rs1,imm[11:0]
			*/
			3'b010: begin
				
				if (verbose_alu) $display("'\t signed comparison (<)");

				aluOut = ($signed(aluIn1) < $signed(aluIn2));
			end




			/*
			unsigned comparison (<)
			Funct7==7’b0000000;

			SLTU  rd,rs1,rs2
				Use the unsigned number to compare rs1 and rs2,
				 if rs1<rs2, rd is set to 1, otherwise it is set to 0

			SLTIU rd,rs1,imm[11:0]  
			*/
			3'b011: begin
				
				if (verbose_alu) $display("'\t unsigned comparison (<)");

				aluOut = (aluIn1 < aluIn2);
			end




			/*
			XOR   rd,rs1,rs2
			XORI rd,rs1,imm[11:0]
			
			funct7==7’b0000000,
			*/
			3'b100: begin
				
				if (verbose_alu) $display("'\t XOR");

				aluOut = (aluIn1 ^ aluIn2);

			end



			/*
			logical or arithmetic right shift

			SRL rd, rs1,rs2
				Funct7==7’b0000000,
				Logical shift right

				rs1 is logically shifted to the right according to the specified number of low 5 bits
				 in rs2, and the high bits of rs1 are filled with zeros, 
				 and the result is written into rd

			SRA rd,rs1,rs2
				Funct7==7’b010_0000,
				Arithmetic shift right
				Arithmetic shift rs1 to the right according to the specified number
				 of low 5 bits in rs2, the high bit is determined by the original rs1[31],
				  and the result is written into rd. Note: When shifting,
				   only the value of RS1 is copied to the temporary variable for shifting,
				    and the original value remains constant.


			SRLI rd,rs1,shift_amount[4:0]
			
			SRAI rd,rs1,shift_amount[4:0]

			one makes the difference also by testing bit 5 of funct7, 
			1 for arithmetic shift (with sign expansion) and 0 for logical shift.
			*/
			3'b101: begin
				if (funct7[5]) begin
					if (verbose_alu) $display("'\t arithmetic right shift");

					aluOut = $signed(aluIn1) >>> shift_amount;

				end else begin
					if (verbose_alu) $display("'\t logical right shift");

					aluOut = aluIn1 >> shift_amount; 

				end
			end






			/*
			OR 

			funct7==7’b0000000,

			OR  rd, rs1,rs2

			ORI rd,rs1,imm[11:0]
			*/
			3'b110: begin
				
				if (verbose_alu) $display("'\t OR");

				aluOut = (aluIn1 | aluIn2);

			end






			/*
			AND
			funct7==7’b0000000；

			AND rd,rs1,rs2:

			ANDI rd,rs1,imm[11:0]
			*/
			3'b111: begin
				
				if (verbose_alu) $display("'\t AND");

				aluOut = (aluIn1 & aluIn2);	

			end
		endcase




	end



	
	


endmodule
