
module cvtsw_round #(

	parameter INTn = 0,
	parameter NEXP = 0,
	parameter NSIG = 0,
	parameter LAST_RA = 0


) (
  input negIn,
  input [NEXP-1:0] expIn,
  input [INTn-1:0] sigIn,
  input [LAST_RA:0] ra,
  output [NEXP-1:0] expOut,
  output [NSIG:0] sigOut

);

  localparam roundTiesToEven     = 0;
localparam roundTowardZero     = 1;
localparam roundTowardPositive = 2;
localparam roundTowardNegative = 3;
localparam roundTiesToAway     = 4;




  wire Cout;
  wire [NSIG:0] aSig, rSig, tSig;
  wire [NEXP-1:0] rExp;
  
  // Flags used in determination of whether we should be rounding:
  wire lastKeptBitIsOdd, decidingBitIsOne, remainingBitsAreNonzero;
  
  // Is the last bit to be saved a `1', that is, is it odd?
  assign lastKeptBitIsOdd        =  sigIn[INTn-NSIG-1];
  
  // Is the first bit to be truncated a `1'?
  // Then we use the last bit being kept to break the tie
  // in choosing to round, or use the rest of the truncated
  // bits.
  assign decidingBitIsOne        =  sigIn[INTn-NSIG-2];
  
  // Are the bits beyond the first bit to be truncated all zero?
  // If not, we don't have a tie situation.
  assign remainingBitsAreNonzero = |sigIn[INTn-NSIG-3:0];
                
  // This flag holds the boolean value of whether or not we need to round this
  // significand. It's used as the carry-in bit for the instantiation of
  // padder24() below.
  wire roundBit;
  
  // Determine whether or not we round this significand.
  assign roundBit = (ra[roundTiesToEven] & // First rounding case
                     decidingBitIsOne & (lastKeptBitIsOdd | remainingBitsAreNonzero)) |
                    (ra[roundTowardPositive] & // Second rounding case
                     ~negIn & (decidingBitIsOne | remainingBitsAreNonzero)) |
                    (ra[roundTowardNegative] & // Third rounding case
                     negIn & (decidingBitIsOne | remainingBitsAreNonzero));
                    // When ra[roundTowardZero] is true we don't round, we
                    // truncate.

  // Round NSIG+1 most significant bits of the significand.
  assign tSig = sigIn[INTn-1:INTn-NSIG-1];
  
  // Compute the rounded significand.
  padder24 U0(tSig, {NSIG+1{1'b0}}, roundBit, aSig, Cout);
  // If there was a carry-out then the carry-out is the new most significant
  // bit set to 1 (one).
  assign rSig = Cout ? {Cout, aSig[NSIG:1]} : aSig;
  
  // If when we rounded sigIn there was a carry-out we need to adjust the exponent
  // to re-normalize the result.
  assign rExp = expIn + Cout; // We're adding either 1 or 0 to expIn.
  
  // Return final exponent and significand values.
  assign {expOut, sigOut} = {rExp, rSig};

  endmodule
