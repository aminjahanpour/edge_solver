
module sp_mul #(
    parameter register_width	 = 0,
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
	input 			[register_width - 1 : 0] 		a,
	input 			[register_width - 1 : 0] 		b,
	output wire		[register_width - 1 : 0] 		p,
    output reg      [LAST_FLAG - 1 : 0]        pFlags
);





  wire signed [NEXP+1:0] aExp, bExp;

  reg signed [NEXP+1:0] pExp, t1Exp, t2Exp;
  
  wire [NSIG:0] aSig, bSig;
  
  reg [NSIG:0] pSig, tSig;

  reg [NEXP+NSIG:0] pTmp;

  wire [2*NSIG+1:0] rawSignificand;

  wire [LAST_FLAG-1:0] aFlags, bFlags;

  reg pSign;

  wire [register_width - 1 : 0] a_class, b_class;

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

  ) class_1(.f(a), .fExp(aExp), .fSig(aSig), .fFlags(aFlags), .class_val(a_class));




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

  ) class_2(.f(b), .fExp(bExp), .fSig(bSig), .fFlags(bFlags), .class_val(b_class));




  assign rawSignificand = aSig * bSig;

  always @(*)
  begin
    // IEEE 754-2019, section 6.3 requires that "[w]hen neither the
    // inputs nor result are NaN, the sign of a product ... is the
    // exclusive OR of the operands' signs".
    pSign = a[NEXP+NSIG] ^ b[NEXP+NSIG];
    pTmp = {pSign, {NEXP{1'b1}}, 1'b0, {NSIG-1{1'b1}}};  // Initialize p to be an sNaN.
    pFlags = 6'b000000;

    if ((aFlags[SNAN] | bFlags[SNAN]) == 1'b1)
      begin
        pTmp = aFlags[SNAN] == 1'b1 ? a : b;
        pFlags[SNAN] = 1;
      end
    else if ((aFlags[QNAN] | bFlags[QNAN]) == 1'b1)
      begin
        pTmp = aFlags[QNAN] == 1'b1 ? a : b;
        pFlags[QNAN] = 1;
      end
    else if ((aFlags[INFINITY] | bFlags[INFINITY]) == 1'b1)
      begin
        if ((aFlags[ZERO] | bFlags[ZERO]) == 1'b1)
          begin
            pTmp = {pSign, {NEXP{1'b1}}, 1'b1, {NSIG-1{1'b0}}}; // qNaN
            pFlags[QNAN] = 1;
          end
        else
          begin
            pTmp = {pSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
            pFlags[INFINITY] = 1;
          end
      end
    else if ((aFlags[ZERO] | bFlags[ZERO]) == 1'b1 ||
             (aFlags[SUBNORMAL] & bFlags[SUBNORMAL]) == 1'b1)
      begin
        pTmp = {pSign, {NEXP+NSIG{1'b0}}};
        pFlags[ZERO] = 1;
      end
    else // if (((aFlags[SUBNORMAL] | aFlags[NORMAL]) & (bFlags[SUBNORMAL] | bFlags[NORMAL])) == 1'b1)
      begin
        t1Exp = aExp + bExp;

        if (rawSignificand[2*NSIG+1] == 1'b1)
          begin
            tSig = rawSignificand[2*NSIG+1:NSIG+1];
            t2Exp = t1Exp + 1;
          end
        else
          begin
            tSig = rawSignificand[2*NSIG:NSIG];
            t2Exp = t1Exp;
          end

        if (t2Exp < (EMIN - NSIG))  // Too small to even be represented as
          begin                     // a subnormal; round down to zero.
            pTmp = {pSign, {NEXP+NSIG{1'b0}}};
            pFlags[ZERO] = 1;
          end
        else if (t2Exp < EMIN) // Subnormal
          begin
            pSig = tSig >> (EMIN - t2Exp);
            // Remember that we can only store NSIG bits
            pTmp = {pSign, {NEXP{1'b0}}, pSig[NSIG-1:0]};
            pFlags[SUBNORMAL] = 1;
          end
        else if (t2Exp > EMAX) // Infinity
          begin
            pTmp = {pSign, {NEXP{1'b1}}, {NSIG{1'b0}}};
            pFlags[INFINITY] = 1;
          end
        else // Normal
          begin
            pExp = t2Exp + BIAS;
            pSig = tSig;
            // Remember that for Normals we always assume the most
            // significant bit is 1 so we only store the least
            // significant NSIG bits in the significand.
            pTmp = {pSign, pExp[NEXP-1:0], pSig[NSIG-1:0]};
	    pFlags[NORMAL] = 1;
          end
      end //
  end

  assign p = pTmp;
endmodule