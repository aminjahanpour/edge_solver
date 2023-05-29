
module FPU #(
	parameter register_width = 32
) (
	input 											enable,
	input 			[register_width - 1 : 0] 		fpuIn1,
	input 			[register_width - 1 : 0] 		fpuIn2,
	input 			[register_width - 1 : 0] 		fpuIn3,

	input			[register_width - 1 : 0]		instr,

	input 			[register_width - 1 : 0] 		rs1,


	output reg 		[register_width - 1 : 0] 		fpuOut
	);


	reg		verbose_fpu = 0;


	wire											fpuIn1_sign 	= fpuIn1[register_width - 1];
	wire											fpuIn2_sign 	= fpuIn2[register_width - 1];
	wire		[register_width - 1 : 0]			fpuIn1_mag 	    = {1'b0, fpuIn1[register_width - 2 : 0]};
	wire		[register_width - 1 : 0]			fpuIn2_mag 	    = {1'b0, fpuIn2[register_width - 2 : 0]};
	
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

	wire			[5 - 1 : 0]					rs2Id = instr[24:20];


	wire signed	[register_width - 1 : 0] 		signed_rs1 = $signed(rs1);


	localparam   NEXP            = 8;
	localparam   NSIG            = 23;

	localparam NORMAL            = 0;
	localparam SUBNORMAL         = 1;
	localparam ZERO              = 2;
	localparam INFINITY          = 3;
	localparam QNAN              = 4;
	localparam SNAN              = 5;
	localparam NTYPES            = 6;
	localparam LAST_FLAG         = 6;
	localparam LAST_RA         	 = 4;

	localparam BIAS = ((1 << (NEXP - 1)) - 1); // IEEE 754, section 3.3
	localparam EMAX = BIAS; // IEEE 754, section 3.3
	localparam EMIN = (1 - EMAX); // IEEE 754, section 3.3

	localparam roundTiesToEven     = 0;
	localparam roundTowardZero     = 1;
	localparam roundTowardPositive = 2;
	localparam roundTowardNegative = 3;
	localparam roundTiesToAway     = 4;
	localparam NRAS                = 5;
										
	localparam INVALID             = 0;
	localparam DIVIDEBYZERO        = 1;
	localparam OVERFLOW            = 2;
	localparam UNDERFLOW           = 3;
	localparam INEXACT             = 4;
	localparam NEXCEPTIONS     = INEXACT+1;








	/*
	fpuIn1 = always   rs1
    fpuIn2 = either   rs2   OR   constants

	*/


	reg			[register_width - 1 : 0] 		mul_a;
	reg			[register_width - 1 : 0] 		mul_b;

	wire		[register_width - 1 : 0] 		mul_out;
	wire        [LAST_FLAG - 1 : 0]        		mul_flags;

	sp_mul #(
			.register_width(register_width)		,

			.NEXP(NEXP)						,
			.NSIG(NSIG)						,
			.NORMAL(NORMAL)      		,
			.SUBNORMAL(SUBNORMAL)  	,
			.ZERO(ZERO)        		,
			.INFINITY(INFINITY)    	,
			.QNAN(QNAN)        	,
			.SNAN(SNAN)        	,
			.LAST_FLAG(LAST_FLAG)   	,
			.BIAS(BIAS)        	,
			.EMAX(EMAX)        		,
			.EMIN(EMIN)        		

			) sp_mul_inst(

			.a(mul_a),
			.b(mul_b),
			.p(mul_out),
			.pFlags(mul_flags)

	);




	reg			[register_width - 1 : 0] 		add_sub_a;
	reg			[register_width - 1 : 0] 		add_sub_b;


	wire		[register_width - 1 : 0] 		add_sub_out;
	reg 										subtract;
	reg 		[NRAS : 0] 						ra 			= 1 << roundTiesToEven;
	// reg 		[LAST_RA:0] 					raz 		= 1 << roundTowardZero;
	// reg 		[LAST_RA:0] 					rap 		= 1 << roundTowardPositive;
	// reg 		[LAST_RA:0] 					ran 		= 1 << roundTowardNegative;


	wire 		[NTYPES - 1 : 0] 				sFlags;
	wire 		[NEXCEPTIONS - 1 : 0] 			exception;
  

	fp_as #(
			.register_width(register_width),

			.NEXP(NEXP), 				
			.NSIG(NSIG), 					
			.NORMAL(NORMAL),    			
			.SUBNORMAL(SUBNORMAL), 			
			.ZERO(ZERO),      			
			.INFINITY(INFINITY),  			
			.QNAN(QNAN),      			
			.SNAN(SNAN),      			
			.NTYPES(NTYPES),
			.LAST_FLAG(LAST_FLAG),  			

			.BIAS(BIAS), 					
			.EMAX(EMAX), 					
			.EMIN(EMIN), 					

			.roundTiesToEven(roundTiesToEven),     	
			.roundTowardZero(roundTowardZero),     	
			.roundTowardPositive(roundTowardPositive), 	
			.roundTowardNegative(roundTowardNegative), 	
			.roundTiesToAway(roundTiesToAway),     	
			.NRAS(NRAS),                	
					
			.INVALID(INVALID),             	
			.DIVIDEBYZERO(DIVIDEBYZERO),        	
			.OVERFLOW(OVERFLOW),            	
			.UNDERFLOW(OVERFLOW),           	
			.INEXACT(INEXACT),             	
			.NEXCEPTIONS(NEXCEPTIONS)     		
		) U0(
			add_sub_a, add_sub_b, subtract, ra, add_sub_out, sFlags, exception
		);




  	wire signed 	[NEXP+1:0] 					dummy_Exp;
	wire 			[NSIG:0] 					dummy_Sig;
	wire 			[LAST_FLAG-1:0] 			dummy_Flags;
	wire 			[register_width - 1 : 0] 	out_class;

	fp_class #(
				.register_width(register_width)		,
				.NEXP(NEXP)						,
				.NSIG(NSIG)						,
				.NORMAL(NORMAL)      		,
				.SUBNORMAL(SUBNORMAL)  	,
				.ZERO(ZERO)        		,
				.INFINITY(INFINITY)    	,
				.QNAN(QNAN)        	    ,
				.SNAN(SNAN)        	    ,
				.LAST_FLAG(LAST_FLAG)   	,
				.BIAS(BIAS)        	    ,
				.EMAX(EMAX)        		,
				.EMIN(EMIN)        		

	) class_2(
		.f(		fpuIn1),
		.fExp(	dummy_Exp),
		.fSig(	dummy_Sig),
		.fFlags(dummy_Flags), 
		.class_val(	out_class)
);






	reg	signed	[register_width - 1 : 0]		cvtsw_in;
	wire		[register_width - 1 : 0]		cvtsw_out;
	wire										cvtsw_inexact;
	wire										cvtsw_overflow;



	cvtsw #(
		.INTn(register_width),
		.NEXP(NEXP),
		.NSIG(NSIG),
		.LAST_FLAG(LAST_FLAG),
		.BIAS(BIAS),
		.EMAX(EMAX), 					
		.EMIN(EMIN), 					

		.roundTiesToEven(roundTiesToEven),     	
		.roundTowardZero(roundTowardZero),     	
		.roundTowardPositive(roundTowardPositive), 	
		.roundTowardNegative(roundTowardNegative), 	
		.roundTiesToAway(roundTiesToAway),     	
		.NRAS(NRAS),                	
				

		.LAST_RA(LAST_RA)
	) inst1(.w(cvtsw_in), .s(cvtsw_out), .inexact(cvtsw_inexact), .overflow(cvtsw_overflow));
  







	reg	signed	[register_width - 1 : 0]		cvtws_in;
	wire signed		[register_width - 1 : 0]		cvtws_out;



	cvtws inst2(.cvtws_in(cvtws_in), .cvtws_out(cvtws_out));
  



































	always @(*) begin
		if (enable) begin

		if (verbose_fpu) $display("FPU is active: instr:%b\n`             funct7:%b, funct3:%b, rs2Id:%b, fpuIn1:%f, fpuIn2:%f", 
		instr, funct7, funct3, rs2Id, $bitstoreal(toolkit.display_float(fpuIn1)), $bitstoreal(toolkit.display_float(fpuIn2)));


			case (instr[7 - 1 : 0])

				7'b1010011: begin
							
					case(funct7)


						7'b1110000: begin

							case (funct3)


								3'b001:
									begin

										if (verbose_fpu) $display("FCLASS.S");

										if (verbose_fpu) $display("FPU: class: %b", out_class);

										fpuOut = out_class;
															
									end




								3'b000:
									begin
										
										if (verbose_fpu) $display("FPU: FMV.X.W");
							
										/*
										reads float, writes to integer

										Move the single-precision value in floating-point register rs1
										represented in IEEE 754-2008 encoding to the lower 32 bits of 
										integer register rd.
										*/
										if (verbose_fpu) $display("FPU: input: %d", rs1);

										fpuOut = fpuIn1;

										if (verbose_fpu) $display("FPU: input(fpuIn1): 0x%h, output rd_int: 0x%h", fpuIn1, fpuOut);


									end


								default: $display("\nFPU: ERROR\n");


							endcase

						end

























						7'b0001000: begin
							if (verbose_fpu) $display("FPU: FMUL.S");



					

							mul_a = fpuIn1;
							
							mul_b = fpuIn2;

							fpuOut = mul_out;


							if (verbose_fpu) $display("FPU: %f * %f = %f", 
							$bitstoreal(toolkit.display_float(fpuIn1)),
							$bitstoreal(toolkit.display_float(fpuIn2)),
							$bitstoreal(toolkit.display_float(fpuOut))
							);

							if (verbose_fpu) $display("FPU: mul_out: %h, %f", mul_out, $bitstoreal(toolkit.display_float(mul_out)));

							if (verbose_fpu) $display("FPU: mul_flags: %b", mul_flags);
							

						end








						7'b0000000: begin

							if (verbose_fpu) $display("FPU: FADD.S");


							subtract = 0;

							add_sub_a = fpuIn1;

							add_sub_b = fpuIn2;

							fpuOut = add_sub_out;



							if (verbose_fpu) $display("FPU: %f + %f = %f", 
							$bitstoreal(toolkit.display_float(fpuIn1)),
							$bitstoreal(toolkit.display_float(fpuIn2)),
							$bitstoreal(toolkit.display_float(fpuOut))
							);

							
							if (verbose_fpu) $display("FPU: add_sub_out: %h, %b, %f", add_sub_out, add_sub_out, $bitstoreal(toolkit.display_float(add_sub_out)));

							if (verbose_fpu) $display("FPU: sFlags: %b", sFlags);


						end






						7'b0000100: begin

							if (verbose_fpu) $display("FPU: FSUB.S");

							


							subtract = 1;

							add_sub_a = fpuIn1;

							add_sub_b = fpuIn2;

							fpuOut = add_sub_out;


							if (verbose_fpu) $display("FPU: %f - %f = %f", 
							$bitstoreal(toolkit.display_float(fpuIn1)),
							$bitstoreal(toolkit.display_float(fpuIn2)),
							$bitstoreal(toolkit.display_float(fpuOut))
							);

							
							if (verbose_fpu) $display("FPU: add_sub_out: %h, %b, %f", add_sub_out, add_sub_out, $bitstoreal(toolkit.display_float(add_sub_out)));

							if (verbose_fpu) $display("FPU: sFlags: %b", sFlags);

						end










































						7'b11_00_000: begin
							if (verbose_fpu) $write("FPU: FCVT");
							

							case (rs2Id)

								
								5'b00000: begin

									/*
									Convert a floating-point number in floating-point register rs1
									to a signed 32-bit in integer register rd.
									*/
									if (verbose_fpu) $display(".W.S");

									cvtws_in = fpuIn1;
									fpuOut = cvtws_out;

									if (verbose_fpu) $display("FPU: input: %f, output:%d", $bitstoreal(toolkit.display_float(fpuIn1)), $signed(fpuOut));


								end

								
								5'b00001: begin

									/*
									Convert a floating-point number in floating-point register rs1
									to a signed 32-bit in unsigned integer register rd.
									*/
									if (verbose_fpu) $display(".WU.S");


									$display("\n\nFPU: not implemented yet\n\n", rs1);$finish();



								end


								default: $display("\nFPU: ERROR\n");

							endcase

						end





						7'b11_01_000: begin
							if (verbose_fpu) $write("FPU: FCVT");
							

							case (rs2Id)

								
								5'b00000: begin

									/*
									Converts a 32-bit signed integer, in integer register rs1 
									into a floating-point number in floating-point register rd.
									*/
									if (verbose_fpu) $display(".S.W");

									cvtsw_in = signed_rs1;
									fpuOut = cvtsw_out;

									if (verbose_fpu) $display("FPU: input: %d, output:%f", signed_rs1, $bitstoreal(toolkit.display_float(fpuOut)));

								end

								
								5'b00001: begin

									/*
									Converts a 32-bit unsigned integer, in integer register rs1 
									into a floating-point number in floating-point register rd.
									*/
									if (verbose_fpu) $display(".S.WU");

									cvtsw_in = rs1;
									fpuOut = cvtsw_out;

									if (verbose_fpu) $display("FPU: input: %d, output:%f", rs1, $bitstoreal(toolkit.display_float(fpuOut)));



								end


								default: $display("\nFPU: ERROR\n");

							endcase

						end





















						7'b11_11_000: begin
							if (verbose_fpu) $display("FPU: FMV.W.X");
							
							/*
							reads integer, writes to float

							Move the single-precision value encoded in IEEE 754-2008 standard encoding
							from the lower 32 bits of integer register rs1 to the floating-point 
							register rd.

							
							*/

							fpuOut = rs1;

							if (verbose_fpu) $display("FPU: input(rs1): 0x%d, output(rd_float): 0x%d", rs1, fpuOut);

						end
































						7'b0010100: begin



							if (funct3 == 3'b000) begin // MIN
								if (verbose_fpu) $display("FPU: FMIN.S");
							end else begin
								if (verbose_fpu) $display("FPU: FMAX.S");
							end
							
							
							if ((fpuIn1_sign) && (~fpuIn2_sign)) begin
								if (funct3 == 3'b000) begin // MIN
									fpuOut = fpuIn1;
								end else begin
									fpuOut = fpuIn2;
								end

							end else if ((~fpuIn1_sign) && (fpuIn2_sign)) begin
								if (funct3 == 3'b000) begin // MIN
									fpuOut = fpuIn2;
								end else begin
									fpuOut = fpuIn1;
								end


							end else if ((fpuIn1_sign) && (fpuIn2_sign)) begin
								if (funct3 == 3'b000) begin // MIN
									fpuOut = (fpuIn1_mag > fpuIn2_mag) ? fpuIn1 : fpuIn2;
								end else begin
									fpuOut = (fpuIn1_mag > fpuIn2_mag) ? fpuIn2 : fpuIn1;
								end


							end else if ((~fpuIn1_sign) && (~fpuIn2_sign)) begin
								if (funct3 == 3'b000) begin // MIN
									fpuOut = (fpuIn1_mag < fpuIn2_mag) ? fpuIn1 : fpuIn2;
								end else begin
									fpuOut = (fpuIn1_mag < fpuIn2_mag) ? fpuIn2 : fpuIn1;
								end


							end

							if (verbose_fpu) $display("FPU: fpuOut: %f", $bitstoreal(toolkit.display_float(fpuOut)));



						end
























		

						7'b1010000: begin
							case (funct3)
								3'b010: begin
									if (verbose_fpu) $display("FPU: FEQ.S");
									/*
										Performs a quiet equal comparison between floating-point registers
										rs1 and rs2 and record the Boolean result in integer register rd.
										Only signaling NaN inputs cause an Invalid Operation exception.
										The result is 0 if either operand is NaN.
									*/

									fpuOut = (fpuIn1 == fpuIn2) ? 1 : 0;
									if (verbose_fpu) $display("fpuOut: %d", fpuOut);


								end
								3'b001: begin
									if (verbose_fpu) $display("FPU: FLT.S");
									/*
										Performs a quiet less comparison between floating-point registers
										rs1 and rs2 and record the Boolean result in integer register rd.
										Only signaling NaN inputs cause an Invalid Operation exception.
										The result is 0 if either operand is NaN.
									*/

									if ((fpuIn1_sign) && (~fpuIn2_sign)) begin
										fpuOut = 1;
									end else if ((~fpuIn1_sign) && (fpuIn2_sign)) begin
										fpuOut = 0;
									end else if ((fpuIn1_sign) && (fpuIn2_sign)) begin
										fpuOut = (fpuIn1_mag > fpuIn2_mag);
									end else if ((~fpuIn1_sign) && (~fpuIn2_sign)) begin
										fpuOut = (fpuIn1_mag < fpuIn2_mag);
									end

									if (verbose_fpu) $display("fpuOut: %d", fpuOut);


								end
								3'b000: begin
									if (verbose_fpu) $display("FPU: FLE.S");

									if ((fpuIn1_sign) && (~fpuIn2_sign)) begin
										fpuOut = 1;
									end else if ((~fpuIn1_sign) && (fpuIn2_sign)) begin
										fpuOut = 0;
									end else if ((fpuIn1_sign) && (fpuIn2_sign)) begin
										fpuOut = (fpuIn1_mag >= fpuIn2_mag);
									end else if ((~fpuIn1_sign) && (~fpuIn2_sign)) begin
										fpuOut = (fpuIn1_mag <= fpuIn2_mag);
									end

									if (verbose_fpu) $display("fpuOut: %d", fpuOut);

								end

								default: $display("\nFPU: ERROR\n");


							endcase
						end



































						7'b0010000: begin

							if (verbose_fpu) $write("FPU: FSGNJ");

							case (funct3)
								3'b000: begin
									/*

										fsgnj.s rd,rs1,rs2

										Produce a result that takes all bits except the sign bit from rs1.
										The result’s sign bit is rs2’s sign bit.

										f[rd] = {f[rs2][31], f[rs1][30:0]}
									*/
									if (verbose_fpu) $display(".S");

									fpuOut = {fpuIn2[31], fpuIn1[30 : 0]};

								end
								3'b001: begin
									/*

										fsgnjn.s rd,rs1,rs2

										Produce a result that takes all bits except the sign bit from rs1.
										The result’s sign bit is opposite of rs2’s sign bit.

										f[rd] = {~f[rs2][31], f[rs1][30:0]}

									*/
									if (verbose_fpu) $write("N.S");

									fpuOut = {~fpuIn2[31], fpuIn1[30 : 0]};
									

								end
								3'b010: begin
									/*

										fsgnjx.s rd,rs1,rs2

										Produce a result that takes all bits except the sign bit from rs1.
										The result’s sign bit is XOR of sign bit of rs1 and rs2.

										f[rd] = {f[rs1][31] ^ f[rs2][31], f[rs1][30:0]}
									*/

									if (verbose_fpu) $write("X.S");

									fpuOut = {fpuIn1[31] ^ fpuIn2[31], fpuIn1[30:0]};
									
								end

								default: $display("\nFPU: ERROR\n");

							endcase
						end



						7'b0101100: begin 
							
							/* 
							FSQRT.S
							*/

							$display("FSQRT.S");
							$display("FPU OPERATION NOT YET IMPLEMENTED\n");
							// $finish();

						end


						7'b0001100: begin 
							
							/* 
							FDIV.S
							*/

							$display("FPU: FDIV.S");
							$display("FPU OPERATION NOT YET IMPLEMENTED\n");
							// $finish();

						end


						default: begin

							$display("\nFPU: FPU activated for OpFo but the operation is not recognized\n");
							$finish();

						end
					endcase

				end


				7'b1000011: begin 
					/* FMADD.S 

					f[rd] = f[rs1]×f[rs2]+f[rs3]

					*/
					if (verbose_fpu) $display("FPU: FMADD.S");


					mul_a = fpuIn1;
					
					mul_b = fpuIn2;



					subtract = 0;

					add_sub_a = mul_out;

					add_sub_b = fpuIn3;

					fpuOut = add_sub_out;


					if (verbose_fpu) $display("FPU: %f * %f + %f = %f", 
					$bitstoreal(toolkit.display_float(fpuIn1)),
					$bitstoreal(toolkit.display_float(fpuIn2)),
					$bitstoreal(toolkit.display_float(fpuIn3)),
					$bitstoreal(toolkit.display_float(fpuOut))
					);




					
				end


				7'b1000111: begin 
					/* 
					FMSUB.S

					f[rd] = f[rs1]×f[rs2]-f[rs3]

					*/

					if (verbose_fpu) $display("FPU: FMSUB.S");



					mul_a = fpuIn1;
					
					mul_b = fpuIn2;



					subtract = 1;

					add_sub_a = mul_out;

					add_sub_b = fpuIn3;

					fpuOut = add_sub_out;


					if (verbose_fpu) $display("FPU: %f * %f - %f = %f", 
					$bitstoreal(toolkit.display_float(fpuIn1)),
					$bitstoreal(toolkit.display_float(fpuIn2)),
					$bitstoreal(toolkit.display_float(fpuIn3)),
					$bitstoreal(toolkit.display_float(fpuOut))
					);






				end


				7'b1001011: begin 
					/* FNMSUB.S 
					
					f[rd] = -f[rs1]×f[rs2]+f[rs3]

					*/
					if (verbose_fpu) $display("FPU: FNMSUB.S ");


					mul_a = {~fpuIn1[31], fpuIn1[30 : 0]};
					
					mul_b = fpuIn2;



					subtract = 0;

					add_sub_a = mul_out;

					add_sub_b = fpuIn3;

					fpuOut = add_sub_out;


					if (verbose_fpu) $display("FPU: -1 * %f * %f + %f = %f", 
					$bitstoreal(toolkit.display_float(fpuIn1)),
					$bitstoreal(toolkit.display_float(fpuIn2)),
					$bitstoreal(toolkit.display_float(fpuIn3)),
					$bitstoreal(toolkit.display_float(fpuOut))
					);

					

				end


				7'b1001111: begin 
					
					/* FNMADD.S

					f[rd] = -f[rs1]×f[rs2]-f[rs3]

					*/
					if (verbose_fpu) $display("FPU: FNMADD.S ");


					mul_a = {~fpuIn1[31], fpuIn1[30 : 0]};
					
					mul_b = fpuIn2;



					subtract = 1;

					add_sub_a = mul_out;

					add_sub_b = fpuIn3;

					fpuOut = add_sub_out;


					if (verbose_fpu) $display("FPU: -1 * %f * %f - %f = %f", 
					$bitstoreal(toolkit.display_float(fpuIn1)),
					$bitstoreal(toolkit.display_float(fpuIn2)),
					$bitstoreal(toolkit.display_float(fpuIn3)),
					$bitstoreal(toolkit.display_float(fpuOut))
					);




				end





			endcase



		end

	end



	
	


endmodule
