

module cvtsw #(

	parameter INTn = 0,
	parameter NEXP =  0,
	parameter NSIG = 0,

	parameter LAST_FLAG = 0,
	parameter BIAS = 0,
  parameter EMAX 					= 0,
	parameter EMIN 					= 0,

	parameter roundTiesToEven     	= 0,
	parameter roundTowardZero     	= 0,
	parameter roundTowardPositive 	= 0,
	parameter roundTowardNegative 	= 0,
	parameter roundTiesToAway     	= 0,
	parameter NRAS                	= 0,
								

	parameter LAST_RA =0

)(

  
  input signed      [INTn-1:0] 			w,
  output reg        [NEXP+NSIG:0] 		s,
  output 								inexact, // Signal exception conditions.
  output reg								overflow // Signal exception conditions.

  );

  
  localparam CLOG2_INTn = $clog2(INTn);
  
  reg [LAST_RA:0] ra  = 1;

  
  reg [INTn-1:0] sigIn;
  wire [INTn-1:0] mask;
  
  assign mask = {NEXP+NSIG+1{1'b1}};

  integer i;
  reg [NEXP-1:0] expIn;
  
  wire [NEXP-1:0] expOut;
  wire [NSIG:0] sigOut;


  wire rounding_inexact;


  always @(*)
    begin
      // Signed integers are stored in 2's complement form; floating
      // point numbers are stored in sign/magnitude form. If the
      // input value is negative compute its absolute value. We get
      // the correct result even though 2 ** (INTn-1) can't be
      // represented as a signed integer. Effectively, after we've
      // computed the absolute value we treat the INTn-bit result as
      // an unsigned number and this works.
      sigIn = w[INTn-1] ? (~w + 1) : w;
      
      if (sigIn == 0)
        begin
          s = {NEXP+NSIG+1{1'b0}};
        end
      else
        begin
          // Left shift the significand to get the most significant
          // 1 bit into bit position NSIG. Keep track of how many places
          // We needed to shift the significand value; we'll need this
          // information for calculating the final exponent value.
          expIn = 0;
          for (i = (1 << (CLOG2_INTn - 1)); i > 0; i = i >> 1)
            begin
              if ((sigIn & (mask << (INTn - i))) == 0)
                begin
                  sigIn = sigIn << i;
                  expIn = expIn | i;
                end
            end

          // The largest possible signed INTn-bit signed integer magnitude
          // is 2 ** (INTn-1) so we start with (INTn-1) as our largest
          // possible exponent. Each bit position we had to shift in order
          // to get the most significant one bit into position NSIG reduces
          // the exponent value. Don't forget we need to add the BIAS value
          // to get our final exponent value.
          expIn = (INTn-1) + BIAS - expIn; // Exponent w/bias.
          
          // See below for the instantiation of the round module which
          // does the actual rounding. The instantiation is placed at
          // the bottom because it can't be instantiated inside of an
          // `always' block.  The lines above us create its input. The
          // lines below use its output.
          
          // Did we round to +/- infinity?
          // This test isn't needed for this case. But it will be needed
          // for other integer to float conversions so we leave it here as
          // a reminder for when it is needed.
          overflow = &expOut;
          s[NEXP+NSIG:NSIG] = {w[INTn-1], expOut};
          s[NSIG-1:0] = overflow ? {NSIG{1'b0}} : sigOut;
        end
    end

    // If any of the bits removed by truncation are 1 then we produced
    // an inexact result.
    assign inexact = |sigIn[INTn-2-NSIG:0];
    
    



	cvtsw_round #(

	.INTn(INTn),
	.NEXP(NEXP),
	.NSIG(NSIG),
	.LAST_RA(LAST_RA)


	) xcxc (
	.negIn(w[INTn-1]),
	.expIn(expIn),
	.sigIn(sigIn),
	.ra(ra),
	.expOut(expOut),
	.sigOut(sigOut)
	);

  
  



endmodule
