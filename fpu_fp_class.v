module fp_class #(
    parameter 	register_width	 = 0,
	parameter   NEXP            = 0,
    parameter   NSIG            = 0,

    parameter   NORMAL      = 0,
    parameter   SUBNORMAL  = 0,
    parameter   ZERO        = 0,
    parameter   INFINITY    = 0,
    parameter   QNAN        = 0,
    parameter   SNAN        = 0,
    parameter   LAST_FLAG   = 0,

    parameter   BIAS        = 0,
    parameter   EMAX        = 0,
    parameter   EMIN        = 0

)(
	input 					[register_width - 1 : 0] 		f,
    output reg signed    	[NEXP + 1 : 0] 		        	fExp,
    output reg      		[NSIG     : 0] 		        	fSig,
	output wire				[LAST_FLAG - 1 : 0]				fFlags,
    output wire     		[register_width - 1 : 0] 		class_val

);


	localparam	clog2_NSIG 	= 	$clog2(NSIG + 1);



	wire   exp_ones   =  &f[NEXP + NSIG - 1 : NSIG];
	wire   exp_zeroes = ~|f[NEXP + NSIG - 1 : NSIG];
	wire   sig_zeroes = ~|f[NSIG - 1 : 0];

	wire is_snan    = exp_ones      & ~sig_zeroes & ~f[NSIG - 1];
	wire is_qnan    = exp_ones      &                f[NSIG - 1];

	wire   infinity   = exp_ones      &  sig_zeroes;
	wire   normal     = ~exp_ones     & ~exp_zeroes;
	wire   subnormal  = exp_zeroes    & ~sig_zeroes;
	wire   zero       = exp_zeroes    &  sig_zeroes;


	assign fFlags[SNAN] 		= is_snan;
	assign fFlags[QNAN] 		= is_qnan;
	assign fFlags[INFINITY] 	= infinity;
	assign fFlags[ZERO] 		= zero;
	assign fFlags[SUBNORMAL] 	= subnormal;
	assign fFlags[NORMAL]		= normal;


	wire is_neg_inf         =   infinity    &    f[NEXP + NSIG];
	wire is_neg_normal      =   normal      &    f[NEXP + NSIG];
	wire is_neg_subnormal   =   subnormal   &    f[NEXP + NSIG];
	wire is_neg_zero        =   zero        &    f[NEXP + NSIG];
	wire is_pos_zero        =   zero        &   ~f[NEXP + NSIG];
	wire is_pos_subnormal   =   subnormal   &   ~f[NEXP + NSIG];
	wire is_pos_normal      =   normal      &   ~f[NEXP + NSIG];
	wire is_pos_inf         =   infinity    &   ~f[NEXP + NSIG];



	reg			[NSIG + 1 - 1 : 	0]		mask = ~0;
	reg			[clog2_NSIG - 1 : 	0]		sa;

	integer i;


	assign class_val = {
				{22{1'b0}},
				{is_qnan},
				{is_snan},
				{is_pos_inf},
				{is_pos_normal},
				{is_pos_subnormal},
				{is_pos_zero},
				{is_neg_zero},
				{is_neg_subnormal},
				{is_neg_normal},
				{is_neg_inf}
			};


	always @(*) begin
		

		fExp = f[NEXP + NSIG - 1 : NSIG];
		fSig = f[NSIG - 1 : 0];

		sa = 0;

		if (fFlags[NORMAL]) begin
			{fExp, fSig} = {f[NEXP + NSIG - 1: NSIG] - BIAS, 1'b1, f[NSIG - 1: 0]};
		end else if (fFlags[NORMAL]) begin
			

			for (i = (1 << (clog2_NSIG - 1)); i > 0; i = i >> 1 ) begin
				
				if ((fSig & (mask << (NSIG + 1 - i))) == 0) begin
					fSig = fSig << i;
					sa = sa | i;
				end

			end

			fExp = EMIN - sa;

		end	

	end






endmodule