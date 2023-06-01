
module bench_tb();
	reg clk;
	reg resetn = 0; 
	wire [5 - 1 : 0] exception_code;

	parameter DURATION = 30_000_000;

	always #1 clk = ~clk;

	



	localparam q_full = 128;
	localparam q_half = 64;

	localparam sf    = 2.0**-64.0;  
	localparam sf_dv = 2.0**-16.0;  
	localparam sf_f  = 2.0**-16.0;














	// localparam register_width     	= 32;

	// // wire 			[register_width - 1	:	0] 	fpuIn1 = 32'hc1194040; // -9.57818603516
	// // wire 			[register_width - 1	:	0] 	fpuIn2 = 32'h41994000; // 19.1562
	// // wire 			[register_width - 1	:	0] 	fpuIn3 = 32'h41994000; // 19.1562

	// wire 			[register_width - 1	:	0] 	fpuIn1 = 32'h41994000; // 19.1562
	// wire 			[register_width - 1	:	0] 	fpuIn2 = 32'hc1200000; // -10
	// wire 			[register_width - 1	:	0] 	fpuIn3 = 32'h40600000; // 3.5


	// wire 			[register_width - 1 :	0] 	fpuOut;

	// reg				[register_width - 1 : 0] 	rs1 = 32'h414a3d71; // 12.64
	// reg				[5 - 1 : 0]					rs1Id = 1;
	// reg				[5 - 1 : 0]					rdId = 0;


	// reg [32 - 1 : 0] instr ;
	// // reg [32 - 1 : 0] instr = 32'b0001000_00000_00000_001_00000_1010011;


	// // wire [32 - 1 : 0] instr = {7'b0001000, rs2Id, rs1Id, 3'b001, rdId, 7'b1010011};
    // // wire [6:0] funct7 = 7'b0000000;  wire [2:0] funct3 = 3'b001; //add
    // // wire [6:0] funct7 = 7'b0000100;  wire [2:0] funct3 = 3'b001; //sub
    // // wire [6:0] funct7 = 7'b1110000;  wire [2:0] funct3 = 3'b000; // FMV.X.W
    // // wire [6:0] funct7 = 7'b1110000;  wire [2:0] funct3 = 3'b001; // class
    // // wire [6:0] funct7 = 7'b1111000;  wire [2:0] funct3 = 3'b000; // FMV.W.X
    // // wire [6:0] funct7 = 7'b1101000;  wire [2:0] funct3 = 3'b000; // FCVT.S.W
    // // wire [6:0] funct7 = 7'b1101000;  wire [2:0] funct3 = 3'b000; // FCVT.S.WU
    // // wire [6:0] funct7 = 7'b1100000;  wire [2:0] funct3 = 3'b000; // FCVT.W.S


	// // wire [32 - 1 : 0] instr = {7'b0000000, rs2Id, rs1Id, 3'b000, rdId, 7'b1000011}; // FMADD.S
	// // wire [32 - 1 : 0] instr = {7'b0000000, rs2Id, rs1Id, 3'b000, rdId, 7'b1000111}; // FMSUBD.S
	// // wire [32 - 1 : 0] instr = {7'b0000000, rs2Id, rs1Id, 3'b000, rdId, 7'b1001011}; // FNMSUB.S
	// // wire [32 - 1 : 0] instr = {7'b0000000, rs2Id, rs1Id, 3'b000, rdId, 7'b1001111}; // FNMADDB.S




	// FPU  #(
	// 	.register_width(register_width)
	// 	) fpu_instance (
	// 		.enable(1'b1),
	// 		.fpuIn1(fpuIn1),
	// 		.fpuIn2(fpuIn2),
	// 		.fpuIn3(fpuIn3),
	// 		.instr(instr),
	// 		.rs1(rs1),
	// 		.fpuOut(fpuOut)
	// 	);
 

	// initial begin
	// 	#1;
	// 	instr = 32'b0000000_00000_00000_001_00000_1010011; // add
	// 	// instr = 32'b1100000_00000_00000_000_00000_1010011; // FCVT.W.S
	// 	// instr = 32'b0010100_00000_00000_001_00000_1010011; // FCVT.MIN
	// 	instr = 32'b0001100_00000_00000_001_00000_1010011; // div


	// end

























// localparam f_bitstream_len 	= 32;


//     function signed [f_bitstream_len - 1 : 0] q_full_to_16q16;
//         input   signed [q_full - 1 : 0] q_full_fixed_point_64_64;

//         begin
//             q_full_to_16q16 = q_full_fixed_point_64_64[q_half + 16  - 1 : q_half - 16];
//         end

//     endfunction




// 	// testing
//     reg signed [q_full - 1 : 0]  MantSizeSh2 =   'sb0000000000000000000000000000000000000000000000000000000001010011_1111111011100011010000101000010100001010110000000000000000000000;   //  83.99565521

	
// 	initial begin
// 		#1
// 		$display("%b",toolkit.fixed_point_to_float_sp(0<<q_full));
// 		// $display("%b_%b %d", MantSizeSh2[128-1:64], MantSizeSh2[64-1:0], sf*MantSizeSh2);
// 		// $display("`\t\t\t\t\t        %b", q_full_to_16q16(MantSizeSh2), 2.0**-16.0 * q_full_to_16q16(MantSizeSh2));

// 		// $display("ans:---> %f", sf * toolkit.float_sp_to_fixed_point(32'b00111101110011001100110011001101));
// 		// $display("%f", sf * toolkit.float_sp_to_fixed_point(32'hc143c0c2));

// 		// $display("%b", toolkit.fixed_point_to_float_sp(MantSizeSh2));


// 		// $display("%x", toolkit.fixed_point_to_float_sp(toolkit.float_sp_to_fixed_point(32'hc143c0c2)));
// 		// $display("%x", toolkit.fixed_point_to_float_sp(toolkit.float_sp_to_fixed_point(32'h42a7fdc6)));
// 		// $display("%x", toolkit.fixed_point_to_float_sp(toolkit.float_sp_to_fixed_point(32'hd2a5ddc6)));
		
// 		$finish();
// 	end










	SOC uut(
		.clk(clk),
		.resetn(resetn),
		.exception_code(exception_code)
		
		
	);


	initial begin
		$display("\n\n\n");
		clk = 0;
		resetn= 0;
		#1;
		resetn = 1;
	end




	initial begin

		#(DURATION);
		$display("\n\n---------------------------------\nEnd of simulation at:%d", $time);
		$finish;

	end
endmodule