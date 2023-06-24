
module SOC (
		input  								clk,        
		input  								resetn,
		output reg		[5 - 1 : 0]			exception_code
       
         
   	);

	reg soc_verbose = 0;


	localparam 								register_width     		= 32;       // because this is an RV32IF
	localparam 								main_memory_depth 		= 7860;     // this value times 32 gives the total memory in bits
	localparam 								registers_count 		= 32;       // again because this is an RV32

	reg					[24 - 1 : 0]  		instr_counter;						// this is just a counter to keep track of the instructions


	reg										exception;							// this flag is raised when any run-time exception occurs


	localparam								max_time 				= 10_000_000;		// this is the maximum time I allow the code to run on the web
																						// if you are running this on your own machine you can increase
																						// it as much as you want

	reg										time_violation;						// this is raised when a code violates the max_time in a demo

	wire 				[63:0] 				display_float_fpuOut = toolkit.display_float(fpuOut);	// used just to display a float number
	wire 				[63:0] 				display_float_rs1_f  = toolkit.display_float(rs1_f);	// used just to display a float number
	wire 				[63:0] 				display_float_rs2_f  = toolkit.display_float(rs2_f);	// used just to display a float number
	wire 				[63:0] 				display_float_rs3_f  = toolkit.display_float(rs3_f);	// used just to display a float number


    reg					[32 - 1 :1] 		reg_labels 		[registers_count - 1: 0];				// this is just for display the integer resisters by their official laber

	initial begin 
		reg_labels[0 ] ="zero";
		reg_labels[1 ] ="ra";
		reg_labels[2 ] ="sp";
		reg_labels[3 ] ="gp";
		reg_labels[4 ] ="tp";
		reg_labels[5 ] ="t0";
		reg_labels[6 ] ="t1";
		reg_labels[7 ] ="t2";
		reg_labels[8 ] ="s0/fp";
		reg_labels[9 ] ="s1";
		reg_labels[10]="a0";
		reg_labels[11]="a1";
		reg_labels[12]="a2";
		reg_labels[13]="a3";
		reg_labels[14]="a4";
		reg_labels[15]="a5";
		reg_labels[16]="a6";
		reg_labels[17]="a7";
		reg_labels[18]="s2";
		reg_labels[19]="s3";
		reg_labels[20]="s4";
		reg_labels[21]="s5";
		reg_labels[22]="s6";
		reg_labels[23]="s7";
		reg_labels[24]="s8";
		reg_labels[25]="s9";
		reg_labels[26]="s10";
		reg_labels[27]="s11";
		reg_labels[28]="t3";
		reg_labels[29]="t4";
		reg_labels[30]="t5";
		reg_labels[31]="t6";

	end





    reg					[32 - 1 :1] 		reg_labels_float [registers_count - 1: 0];				// this is just for display the float resisters by their official laber

	initial begin 

		reg_labels_float[0]="ft0";
		reg_labels_float[1]="ft1";
		reg_labels_float[2]="ft2";
		reg_labels_float[3]="ft3";
		reg_labels_float[4]="ft4";
		reg_labels_float[5]="ft5";
		reg_labels_float[6]="ft6";
		reg_labels_float[7]="ft7";
		reg_labels_float[8]="fs0";
		reg_labels_float[9]="fs1";
		reg_labels_float[10]="fa0";
		reg_labels_float[11]="fa1";
		reg_labels_float[12]="fa2";
		reg_labels_float[13]="fa3";
		reg_labels_float[14]="fa4";
		reg_labels_float[15]="fa5";
		reg_labels_float[16]="fa6";
		reg_labels_float[17]="fa7";
		reg_labels_float[18]="fs2";
		reg_labels_float[19]="fs3";
		reg_labels_float[20]="fs4";
		reg_labels_float[21]="fs5";
		reg_labels_float[22]="fs6";
		reg_labels_float[23]="fs7";
		reg_labels_float[24]="fs8";
		reg_labels_float[25]="fs9";
		reg_labels_float[26]="fs10";
		reg_labels_float[27]="fs11";
		reg_labels_float[28]="ft8";
		reg_labels_float[29]="ft9";
		reg_labels_float[30]="ft10";
		reg_labels_float[31]="ft11";

	end




	localparam 								exceptions_count 		= 10;
	reg					[256 - 1 :1] 		exception_labels [exceptions_count - 1: 0];				// these are our run-time exceptions
	initial begin 
		exception_labels[0] = "";
		exception_labels[1] = "division overflow";
		exception_labels[2] = "division by zero";
		exception_labels[3] = "division results not valid";
		exception_labels[4] = "sqrt result not valid";
		exception_labels[5] = "negative input to sqrt";
		exception_labels[6] = "";
		exception_labels[7] = "";
		exception_labels[8] = "";
		exception_labels[9] = "";
	end




	// REGISTER FILE

	/*
	same module is used for both intger and float register files.
	to distinguish, we use `.is_float` parameter
	*/

	
	wire  				[register_width - 1 : 0]    	rs1;
	wire  				[register_width - 1 : 0]    	rs2;
	wire  				[register_width - 1 : 0]    	rs3;
	wire  				[register_width - 1 : 0] 		writeBackData;
	reg        											writeBackEn;


	register_file  #(
			.register_width(register_width),
			.is_float(0)
			) register_file_instance (
				.clk(clk),
				.resetn(resetn),
				.isFloat(isFloatIO | isDIV | isSQRT),
				.register_to_write_data(writeBackData),
				.register_to_write_addr(rdId),
				.register_to_write_en(writeBackEn),
				.rs1_addr(rs1Id),
				.rs2_addr(rs2Id),
				.rs3_addr(rs3Id),
				.rs1_value(rs1),
				.rs2_value(rs2),
				.rs3_value(rs3)
			);






	// REGISTER FILE FLOAT
	
	wire  				[register_width - 1 : 0]    	rs1_f;
	wire  				[register_width - 1 : 0]    	rs2_f;
	wire  				[register_width - 1 : 0]    	rs3_f;
	wire  				[register_width - 1 : 0] 		writeBackData_f;
	reg        											writeBackEn_f;


	register_file  #(
			.register_width(register_width),
			.is_float(1)
	) register_file_floate_instance (
				.clk(clk),
				.resetn(resetn),
				.isFloat(isFloatIO | isDIV | isSQRT),
				.register_to_write_data(writeBackData_f),
				.register_to_write_addr(rdId),
				.register_to_write_en(writeBackEn_f),
				.rs1_addr(rs1Id),
				.rs2_addr(rs2Id),
				.rs3_addr(rs3Id),
				.rs1_value(rs1_f),
				.rs2_value(rs2_f),
				.rs3_value(rs3_f)
			);











	reg   				[register_width - 1   :  0]    		instr;					// this is the instruction that we read each time from the program.hex				



	// MEMORY
	/* 
		This is the memory module that contains both the program instructions and the ram 
		As you can see in below it is always initiated by the program.hex
		which in turn is generated from the elf file
		which in turn is generated by the liner and g++
	*/


	reg                                             		mem_read_enable    ;
	reg                 [register_width - 1 : 0]			mem_read_addr      ;
	wire  				[register_width - 1 : 0]  			mem_rdata;
	reg                                             		mem_write_enable   ;
	reg                 [register_width - 1 : 0]			mem_write_addr     ;
	wire                [register_width - 1 : 0]   			mem_wdata     		;

	memory #(
		.mem_width(register_width),
		.mem_depth(main_memory_depth),
		.initial_file("/home/amin/bucking_html/risc-v/program.hex")

	) main_mem(
		.clk(clk),
		.r_en(  mem_read_enable),
		.r_addr(mem_read_addr),
		.r_data(mem_rdata),
		.w_en(  mem_write_enable),
		.w_addr(loadstore_addr[register_width - 1 	: 	2]),
		.w_data(mem_wdata),
		.w_mask(STORE_wmask)
	);


	// what we are going to write on the memory depends on the instruction being integer or float
	assign mem_wdata = (isFloatIO) ? rs2_f : rs2;








	// this is the generic output file in which we print our output
	// because here we do not have access to printf or anything like that
	// so we have to print into file
	integer print_output_file;

















	// Decoder

    // The 10 RISC-V basic instructions
    wire isALUreg  =  ((instr[6:0] == 7'b0110011) || (instr[6:0] == 7'b0111011)); // rd <- rs1 OP rs2
    wire isALUimm  =  ((instr[6:0] == 7'b0010011) || (instr[6:0] == 7'b0010011) || (instr[6:0] == 7'b0011011)); // rd <- rs1 OP Iimm
    wire isBranch  =  ( instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
    wire isJALR    =  ( instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
    wire isJAL     =  ( instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
    wire isAUIPC   =  ( instr[6:0] == 7'b0010111); // rd <- PC + Uimm
    wire isLUI     =  ( instr[6:0] == 7'b0110111); // rd <- Uimm
    wire isLoad    =  ((instr[6:0] == 7'b0000011) || (instr[6:0] == 7'b0000111)); // rd <- mem[rs1+Iimm]
    wire isStore   =  ((instr[6:0] == 7'b0100011) || (instr[6:0] == 7'b0100111)); // mem[rs1+Simm] <- rs2
    wire isSYSTEM  =  ( instr[6:0] == 7'b1110011); // special


	// Floating point instructions
	wire isOpFp	   =  	(
						((instr[6:0] == 7'b1010011) && (instr[31:25] != 7'b0001100) && (instr[31:25] != 7'b0101100) ) +      // rd <- rs1 OP rs2
						(instr[6:0] == 7'b1000011) + // FMADD.S
						(instr[6:0] == 7'b1000111) + // FMSUB.S
						(instr[6:0] == 7'b1001011) + // FNMSUB.S
						(instr[6:0] == 7'b1001111)   // FNMADD.S
	) ;


	wire isFCVTS   =  isOpFp && (instr[31 : 25] == 7'b1101000);


	wire isFMVXW   =  isOpFp && (instr[31 : 25] == 7'b11_10_000); // reads float, writes to integer
	wire isFMVWX   =  isOpFp && (instr[31 : 25] == 7'b11_11_000); // reads integer, writes to float


	wire isFCVTWS  =  isOpFp && (instr[31 : 25] == 7'b11_00_000); // reads float, writes to integer



	wire isFloatComparison = isOpFp && (funct7 == 7'b1010000); // reads float, writes to integer


	wire isFloatIO   =  (		isOpFp 						|
								isPAR						|
							(instr[6:0] == 7'b0000111) 	| 	// FLW
						 	(instr[6:0] == 7'b0100111) 		//FSW
						);

	/*
		isPAR:
			These are the new instructions I introduced to work with Edge Solver

		isPRINT:
			These are two new instructions used to print integer or float values into `print_output_file` file
			which was declaired above
	*/
    wire isPAR     =  (instr[6:0] == 7'b0001011);
    wire isPRINT   =  (instr[6:0] == 7'b0101011);


	// see if we have a division or an sqrt. they have their own modules. not part of the main FPU.
	wire isDIV  = (instr[6:0] == 7'b1010011) && (funct7 == 7'b0001100);
	wire isSQRT = (instr[6:0] == 7'b1010011) && (funct7 == 7'b0101100);

    // The 5 immediate formats
    wire 			[31:0] 		Uimm	={    instr[31],   instr[30:12], {12{1'b0}}};
    wire 			[31:0] 		Iimm	={{21{instr[31]}}, instr[30:20]};
    wire 			[31:0] 		Simm	={{21{instr[31]}}, instr[30:25],instr[11:7]};
    wire 			[31:0] 		Bimm	={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
    wire 			[31:0] 		Jimm	={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};


    // Source and destination registers
    wire 			[5 - 1 : 0] rs1Id 	= (isSYSTEM) ? 15 : instr[19:15];
    wire 			[5 - 1 : 0] rs2Id 	= instr[24:20];
    wire 			[5 - 1 : 0] rs3Id 	= instr[31:27];
    wire 			[5 - 1 : 0] rdId  	= instr[11:7];

    // function codes
    wire 			[2:0] 		funct3 	= instr[14:12];
    wire 			[6:0] 		funct7 	= instr[31:25];





	// there are expections where a float intruction needs to write its results into the integer resigter file
	// here we flag that
	wire	float_operation_writing_to_integer_register = (isFloatComparison | isFMVXW | isFCVTWS);



















	// figuring out what needs to be loaded? a byte? half-word? or a full word?

	wire [31:0] loadstore_addr = rs1 + (isStore ? Simm : Iimm);

	wire [15:0] LOAD_halfword = loadstore_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];

	wire  [7:0] LOAD_byte = loadstore_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0];

	wire mem_byteAccess     = funct3[1:0] == 2'b00;
	wire mem_halfwordAccess = funct3[1:0] == 2'b01;

	wire LOAD_sign =
	!funct3[2] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]);

	wire [31:0] LOAD_data =
			mem_byteAccess ? {{24{LOAD_sign}},     LOAD_byte} :
		mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} :
							mem_rdata ;




	// saving from register to memory

	wire [3:0] STORE_wmask =
			mem_byteAccess      ?
					(loadstore_addr[1] ?
					(loadstore_addr[0] ? 4'b1000 : 4'b0100) :
					(loadstore_addr[0] ? 4'b0010 : 4'b0001)
						) :
			mem_halfwordAccess ?
					(loadstore_addr[1] ? 4'b1100 : 4'b0011) :
				4'b1111;








































	// ALU

	/*
	This ALU only works with integers so that is why its inputs are wired the way you see in below.
	*/


	wire 			[register_width - 1	:	0] 		aluIn1 = rs1;											// ALU input 1
	wire 			[register_width - 1	:	0] 		aluIn2 = (isALUreg) ? rs2 : Iimm;						// ALU input 2
	wire 			[register_width - 1 :	0] 		aluOut;													// ALU output
   	wire 			[5 - 1 :0] 						shift_amount = isALUreg ? rs2[4:0] : instr[24:20];


	ALU  #(
		.register_width(register_width)
		) alu_instance (
			.aluIn1(aluIn1),
			.aluIn2(aluIn2),
			.instr(instr),
			.funct3(funct3),
			.funct7(funct7),
			.shift_amount(shift_amount),
			.aluOut(aluOut)
		);



	reg												takeBranch;

	always @(*) begin

		case(funct3)
			3'b000: takeBranch = (rs1 == rs2);
			3'b001: takeBranch = (rs1 != rs2);
			3'b100: takeBranch = ($signed(rs1) < $signed(rs2));
			3'b101: takeBranch = ($signed(rs1) >= $signed(rs2));
			3'b110: takeBranch = (rs1 < rs2);
			3'b111: takeBranch = (rs1 >= rs2);
			default: takeBranch = 1'b0;
		endcase
		// $display("`		rs1:%b   takeBranch:%b",   rs1, takeBranch);

	end







	// FPU

	wire 			[register_width - 1	:	0] 	fpuIn1 = (isFCVTS | isFMVWX) ? rs1 : rs1_f;
	wire 			[register_width - 1	:	0] 	fpuIn2 = rs2_f;
	wire 			[register_width - 1	:	0] 	fpuIn3 = rs3_f;
	wire 			[register_width - 1 :	0] 	fpuOut;


	FPU  #(
		.register_width(register_width)
		) fpu_instance (
			.enable(isOpFp),
			.fpuIn1(fpuIn1),
			.fpuIn2(fpuIn2),
			.fpuIn3(fpuIn3),
			.instr(instr),
			.rs1(rs1),
			.fpuOut(fpuOut)
		);

















	// clocked instructions


	reg                                           	clocked_instructions_go;
	reg       	[8 - 1 : 0]                         clocked_instructions_operation_id;
	reg       	[register_width - 1 : 0]            clocked_instructions_input_var_0;
	reg       	[register_width - 1 : 0]            clocked_instructions_input_var_1;
	reg       	[register_width - 1 : 0]            clocked_instructions_input_var_2;
	wire  		[register_width - 1 : 0]            clocked_instructions_results;
	wire                                      		clocked_instructions_finished;


	clocked_operations #(
    .register_width(register_width)
	) clocked_operations_ins(
		.clk(clk),
		.go(clocked_instructions_go),
        .operation_id(clocked_instructions_operation_id),
		.input_var_0(clocked_instructions_input_var_0),
		.input_var_1(clocked_instructions_input_var_1),
		.input_var_2(clocked_instructions_input_var_2),
        .results(clocked_instructions_results),
        .finished(clocked_instructions_finished)
   	);




	// bite instructions


	reg                                           	bite_instructions_go;
	reg       	[register_width - 1 : 0]            bite_instructions_input_var_0;
	reg       	[register_width - 1 : 0]            bite_instructions_input_var_1;
	wire  		[register_width - 1 : 0]            bite_instructions_results;
	wire                                      		bite_instructions_finished;
	wire                                      		bite_time_violation;


	bite_operations #(
    .register_width(register_width),
	.max_time(max_time)
	) bite_operations_ins(
		.clk_bite(clk),
		.go(bite_instructions_go),
		.instr(instr),
		.input_var_0(bite_instructions_input_var_0),
		.input_var_1(bite_instructions_input_var_1),
        .results(bite_instructions_results),
        .finished(bite_instructions_finished),
		.time_violation(bite_time_violation)
   	);


























	// SOC

	reg										main_loop_flag;
	reg    [register_width - 1     :  0]    PC;
	reg   [register_width - 1     :  0]    nextPC;



	always @(posedge resetn) begin

		PC = 0;
		lagger = 0;



		writeBackEn = 0;
		writeBackEn_f = 0;

		instr_counter = 0;


    	print_output_file =      $fopen("./print_output_file.txt", "w");

		$display("start of log file");




		main_loop_flag = 1;



	end












	always @(posedge clocked_instructions_finished) begin

		clocked_instructions_go = 0;

		main_loop_flag = 1;

	end

	always @(posedge bite_instructions_finished) begin

		bite_instructions_go = 0;

		main_loop_flag = 1;

	end


	always @(posedge time_violation) begin
		$display("maximum simulation time reached. please reduce your code run time. sorry :(");
        $fdisplay(print_output_file,"maximum simulation time reached. please reduce your code run time. sorry :(");
        $finish();
	end


	always @(posedge bite_time_violation) begin
		time_violation = 1;
	end


	always @(posedge exception) begin
		$display("\n\n\n!!!!!!!!! EXCEPTION CODE: %d\n\n\n", exception_code);
		$display("exception: %s", exception_labels[exception_code]);

		$fdisplay(print_output_file,"runtime error occurred. error code: %d. description: %s", exception_code, exception_labels[exception_code]);
		$finish();
	end






	wire 	need_to_write_back_to_either_register_files = (
						(isALUreg ||
						isALUimm ||
						isJAL    ||
						isJALR   ||
						isLUI    ||
						isAUIPC	 ||
						isLoad   ||
						isOpFp	 ||
						isDIV	 ||
						isSQRT	 ||
						isPAR
						)
						);




	/*
		if we are jumping, write back value to register `ra` is PC + 4
		else, it is whatever value that ALU generates
	*/
   assign writeBackData = 	(isJAL || isJALR) ? (PC + 4) :
							(isLUI) ? Uimm :
							(isAUIPC) ? (PC + Uimm) :
							(isLoad) ? (LOAD_data):
							(isPAR) ? (bite_instructions_results):
							(isDIV) ? (toolkit.fixed_point_to_float_sp(division_q)):
							(isSQRT) ? (toolkit.fixed_point_to_float_sp(sqrt_root)):
							(
								(isOpFp) ? fpuOut : aluOut
								);

   assign writeBackData_f = writeBackData;






//    assign nextPC = 	(isBranch && takeBranch) ? 	PC  + Bimm :
//    	                isJAL                    ? 	PC  + Jimm :
// 	                isJALR                   ? 	rs1 + Iimm :
// 	                							PC	+	4;



	/*
	loading:
		    Lw          a7,         4(a1)

	I want to read somthing from memory (where instructions and data are stored)
	and store it is register a7.

	where in memory do I want to read from?

	I want to read from an address equal to whatever is
	stored in register a1, plus an offset value of 4.

	offset values need to be multiples of 4.



	Storing:
		    Lw          a7,         8(a1)

	I want to store the contents of resigter a4 into somethere in the memory.

	where in the memory?

	the address that is equal to the value stored in register a1 plus an offset value of 8.


	*/


   reg                 [8 - 1 : 0]                    lagger;




always @(negedge clk) begin
	if (main_loop_flag) begin

		lagger = lagger + 1;

		if (lagger == 1) begin

			if ($time > max_time) begin
				time_violation = 1;
			end



			// Note that our although our memory width is 32, the program addresses the memory per byte.
			// PC increases by 4 to respect and follow exactly this behaviour.
			// here we are reading a full word, so to build our mem_read_address we simply ignore the 2 LSB bits of PC.
			// this is not the case while loading and saving.

			mem_read_addr = PC[register_width - 1 	: 	2];
			mem_read_enable = 1;

		end else if (lagger == 2) begin
			instr = mem_rdata;



			mem_read_enable = 0;


			if (soc_verbose) $display("\n\n\n\n\n=========>(instr_counter:%d),  PC:%d(0x%h), instr:0x %h (%b) ", instr_counter, PC, PC, instr, instr, isOpFp, isFloatIO);

			instr_counter = instr_counter + 1;




		end else if (lagger == 3) begin

			if (soc_verbose) $display("=========>isOpFp:%b  isFloat:%b isDIV:%b isSQRT:%b", isOpFp, isFloatIO, isDIV, isSQRT);



			if (isLoad) begin

				if (soc_verbose) $display("%h: LOAD %s   %s,    %d(%s)                 loadstore_addr:%d", PC, (isFloatIO) ? "flw" : "lx", (isFloatIO) ? reg_labels_float[rdId] : reg_labels[rdId], $signed(Iimm), reg_labels[rs1Id], loadstore_addr);



				// if (soc_verbose) $display("LOAD loadstore_addr:%d = rs1:%d(%s) + Iimm:%d", loadstore_addr, rs1, reg_labels[rs1Id], Iimm);


				mem_read_addr = loadstore_addr[register_width - 1 	: 	2];
				mem_read_enable = 1;

				if (soc_verbose) $display("LOAD load addr %d from memory and save it to %d-th register (%s)", mem_read_addr, rdId, (isFloatIO) ? reg_labels_float[rdId] : reg_labels[rdId] );

			end else if (isStore) begin

				if (soc_verbose) $display("%h: STORE %s   mask:%b   %s,    %d(%s)                 loadstore_addr:%d",
				 PC, (isFloatIO) ? "fsw" : "sx", STORE_wmask, (isFloatIO) ? reg_labels_float[rs2Id] : reg_labels[rs2Id], $signed(Simm), reg_labels[rs1Id], loadstore_addr);


				// if (soc_verbose) $display("STORE loadstore_addr:%d = rs1:%d(%s) + Simm:%d", loadstore_addr, rs1, reg_labels[rs1Id], Simm);

				if (soc_verbose) $display("STORE store reg %s(0x %h) to memory at addr %d",
				 (isFloatIO) ? reg_labels_float[rs2Id] : reg_labels[rs2Id], (isFloatIO) ? rs2_f : rs2, loadstore_addr[register_width - 1 	: 	2] );

				// if (soc_verbose) $display("STORE STORE_wmask: %b", STORE_wmask);
				// $display("STORE mem_wdata: 0x %h", mem_wdata);

				mem_write_enable = 1;


			end





		end else if (lagger == 4) begin

			case (1'b1)
				isALUreg: begin
							// $display("ALUreg \trdId=%d \trs1Id=%d \trs2Id=%d \tfunct3=%b",rdId, rs1Id, rs2Id, funct3);
							// $display("aluOut:%d(@%d)   =   rs1:%d(@%d)   OP   rs2:%d(@%d), :", aluOut, rdId, rs1, rs1Id, rs2, rs2Id);

							if (soc_verbose) $display("%h: ALUreg  \t aluOut:%d(%s)   =   rs1:%d(%s)   OP   rs2:%d(%s), (funct3:%b)(funct7:%b)", PC,  $signed(aluOut), reg_labels[rdId], $signed(rs1), reg_labels[rs1Id], $signed(rs2), reg_labels[rs2Id], funct3, funct7);

							end
				isALUimm: begin

							if (soc_verbose) $display("%h: ALUimm  \t aluOut:%d(%s)   =   rs1:%d(%s)   OP   rs2:%d(@imm), (funct3:%b)(funct7:%b)", PC,  $signed(aluOut), reg_labels[rdId], $signed(rs1), reg_labels[rs1Id], $signed(Iimm), funct3, funct7);
							end
				isBranch: begin
							if (soc_verbose) $display("%h: BRANCH", PC);
							if (soc_verbose) $display("rs1:%d(@%d)   OP   rs2:%d(@%d), Bimm:%b", rs1, rs1Id, rs2, rs2Id, Bimm);
							end
				isJAL:    begin
					if (soc_verbose)  $display("JAL");
					end
				isJALR:   begin
					// $display("%h: JALR   %d(%s),  # %h(jumping %d)", PC, rs1 ,  reg_labels[rdId], rs1 + Iimm, rs1 + Iimm);
					// if (soc_verbose) $display("%h: JALR   %s, rs1:(%s) %d,  imm: %d, #    PC <= %d (0x %h)", PC, reg_labels[rdId], reg_labels[rs1Id], rs1 ,  Iimm, rs1 + Iimm, rs1 + Iimm);
					if (soc_verbose) $display("%h: JALR   %s, %d(%s)                         PC <= %d (0x %h)", PC, reg_labels[rdId], $signed(Iimm), reg_labels[rs1Id], rs1 + Iimm, rs1 + Iimm);
					end
				isAUIPC:  begin
							if (soc_verbose) $display("%h: AUIPC    %s  , 0x%h",  PC, reg_labels[rdId], Uimm >> 12);
							end
				isLUI:    begin
							if (soc_verbose) $display("%h: LUI    %s  , 0x%h", PC,  reg_labels[rdId], Uimm >> 12);
							end
				isLoad:   begin

							// $display("LOAD mem_rdata:%h(%b)", mem_rdata, mem_rdata);
							// $display("LOAD_halfword:%b, LOAD_byte:%b",LOAD_halfword, LOAD_byte);
							if (soc_verbose) $display("LOAD full word, mem_rdata: 0x %h", mem_rdata);
							if (soc_verbose) $display("LOAD mem_byteAccess:%b, mem_halfwordAccess:%b, LOAD_sign:%b, LOAD_data:0x %h (%b)", mem_byteAccess, mem_halfwordAccess, LOAD_sign, LOAD_data, LOAD_data);

					end
				isStore:  begin
					if (soc_verbose) $display("STORE");
					end
				isSYSTEM: begin
					$display("end of log file");

					$display("\n\n\n--------------------------> SYSTEM \n gracefull exit  0x00100073 at %d", $time);
					$display("________________________________________________________________________________________");
					$display("________________________________________________________________________________________");
					$display("________________________________________________________________________________________\n\n\n");
					$display("reg[fa0]: %f", $bitstoreal(display_float_rs1_f) );
					$finish;
					end




				isPAR: begin
					if (soc_verbose) $display("PAR");
						if (soc_verbose) $display("funct7:%b    rs2:%s(rs2Id:%d)=%d,            rs1:%s(rs1Id:%d):%d               funct3:%b               rd:%s(rdId:%d)",
						funct7, reg_labels[rs2Id],rs2Id,$signed(rs2), reg_labels[rs1Id],rs1Id,$signed(rs1),funct3, reg_labels[rdId], rdId );

				end






				isOpFp: begin
					if (soc_verbose) $display("Float Operation isOpFp:%b, isFloatIO:%b, isDIV:%b, isSQRT:%b", isOpFp, isFloatIO, isDIV, isSQRT);
					if (soc_verbose) $display("%h: OpFp  \t fpuOut:%f(%s)   =   rs1_f:%f(%s)   OP   rs2:%f(%s)     OP    rs3:%f(%s)",
					 PC,  $bitstoreal(display_float_fpuOut), reg_labels_float[rdId],
					 $bitstoreal(display_float_rs1_f), reg_labels_float[rs1Id],
					 $bitstoreal(display_float_rs2_f), reg_labels_float[rs2Id],
					 $bitstoreal(display_float_rs3_f), reg_labels_float[rs3Id]

					 );
				end


				isDIV: begin
					 	if (soc_verbose) $display("isDIV");

				end


				isSQRT: begin
					 	if (soc_verbose) $display("isSQRT");

				end

				isPRINT: begin
					 	if (soc_verbose) $display("isPRINT");
				end


				default: begin
					$display("\n\n!!!!!!!!!!!!!!!!!!!!!!!!!! unrecognized instruction\nisOpFp:%b\nisFloatIO:%b\n\n\n\n", isOpFp, isFloatIO);

					$finish;
					end
			endcase



		end else if (lagger == 5) begin
			if (isPAR) begin

				main_loop_flag = 0;
				// setting and launching clocked_instruction
				bite_instructions_input_var_0 = rs1_f; // this should be rs1_f!!
				bite_instructions_input_var_1 = rs2_f;
				bite_instructions_go = 1;


			end else if (isDIV) begin

				main_loop_flag = 0;
				// setting and launching division (clocked)
				division_x = toolkit.float_sp_to_fixed_point_64_64(rs1_f);
				division_y = toolkit.float_sp_to_fixed_point_64_64(rs2_f);
				division_start = 1;

			end else if (isSQRT) begin

				main_loop_flag = 0;
				// setting and launching division (clocked)

				sqrt_rad = toolkit.float_sp_to_fixed_point_64_64(rs1_f);
				if (sqrt_rad[q_full - 1]) begin

					exception_code = 5;
					exception = 1;
				end else begin
					sqrt_start = 1;
				end

			end else if (isPRINT) begin

				case (funct3)
					3'b000: begin
						$fdisplay(print_output_file,"%d", rs1);
						$display("%d", rs1);
						end
					3'b001: begin
						$fdisplay(print_output_file,"%f", $bitstoreal(display_float_rs1_f));
						$display("%f", $bitstoreal(display_float_rs1_f));
						end
				endcase
    			

			end



		end else if (lagger == 6) begin
			mem_read_enable = 0;
			mem_write_enable = 0;


			/*
			write back to register file is possible only now that the ALU/clocked_operations are finished
			we need to write back to register only for certain operations
			*/

			/*
			wether we write back to integer register file or float register file is also determined here

			*/
			writeBackEn = (float_operation_writing_to_integer_register) 
							| (need_to_write_back_to_either_register_files && (~(isFloatIO | isDIV | isSQRT)));

			writeBackEn_f = (
								(~float_operation_writing_to_integer_register) 
								& (need_to_write_back_to_either_register_files && isFloatIO)
							) + (isDIV | isSQRT);



			nextPC = 	(isBranch && takeBranch) ? 	PC  + Bimm :	       
								isJAL                    ? 	PC  + Jimm :
								isJALR                   ? 	rs1 + Iimm :
															PC	+	4;



		end else if (lagger == 7) begin
			writeBackEn = 0;
			writeBackEn_f = 0;

			if(!isSYSTEM) begin

				if (isJAL || isJALR ||isAUIPC || isBranch) begin
					
					if (soc_verbose) $display("next PC: %d, funct3:%b, isBranch:%b, takeBranch:%b, isJAL:%b, isJALR:%b (rs1:%d+Iimm:%d), instr:%h",
					nextPC ,  funct3, isBranch, takeBranch, isJAL, isJALR,rs1, Iimm, instr );

				end

				PC <= nextPC;
			end
			

			lagger = 0;

		end
	
	end 
end





























localparam q_full = 128;
localparam q_half = 64;
localparam sf = 2.0**-64.0;  // Q8.8 scaling factor is 2^-8



// Division
reg                                                     division_start;
wire                                                    division_busy;
wire                                                    division_valid;
wire                                                    division_dbz;
wire                                                    division_ovf;
reg                         [q_full - 1 : 0]            division_x;
reg                         [q_full - 1 : 0]            division_y;
wire                        [q_full - 1 : 0]            division_q;
wire                        [q_full - 1 : 0]            division_r;

division #(
    .width(q_full),
    .floating_bits(q_half)
    ) division_B4 (
        .clk(   clk),
        .start( division_start),
        .busy(  division_busy),
        .valid( division_valid),
        .dbz(   division_dbz),
        .ovf(   division_ovf),
        .x(     division_x),
        .y(     division_y),
        .q(     division_q),
        .r(     division_r)
    );



always @(negedge division_busy) begin

	division_start = 0;
    main_loop_flag = 1;

	if ((division_ovf == 1)) begin
		exception_code = 1;
		exception  = 1;
	end else if (division_dbz == 1) begin
		exception_code = 2;
		exception  = 1;
	end else if (division_valid == 0) begin
		exception_code = 3;
		exception  = 1;
	end 


end






// sqrt
reg                                     				sqrt_start;
wire                                     				sqrt_busy;
wire                                     				sqrt_valid;
reg                         [q_full - 1 : 0]            sqrt_rad;
wire                        [q_full - 1 : 0]            sqrt_root;
wire                        [q_full - 1 : 0]            sqrt_rem;



sqrt #(
    .width(q_full),
    .floating_bits(q_half)
) sqrt_ins (
        .clk(   clk),
        .start( sqrt_start),
        .busy(  sqrt_busy),
        .valid( sqrt_valid),
        .rad(   sqrt_rad),
        .root(  sqrt_root),
        .rem(   sqrt_rem)
    );




always @(negedge sqrt_busy) begin

	sqrt_start = 0;
	main_loop_flag = 1;


	if (~sqrt_valid) begin
		exception_code = 4;
		exception  = 1;
	end 



end








endmodule

