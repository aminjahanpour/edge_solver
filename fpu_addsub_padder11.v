

module padder11(A, B, Cin, S, Cout);
  parameter N = 11;
  input [N-1:0] A, B;
  input Cin;
  output [N-1:0] S;
  output Cout;

  // P[i] is an alias for Pi:i, likewise G[i] is an alias for Gi:i
  wire [N-2:-1] P, G;

  assign P = {A[N-2:0] | B[N-2:0], 1'b0};
  assign G = {A[N-2:0] & B[N-2:0], Cin};

  Sum s0(G[-1], A[0], B[0], S[0]);

  wire \G0:-1 ;

  Gij \0:-1 (P[0], G[0], G[-1], \G0:-1 );

  Sum s1(\G0:-1 , A[1], B[1], S[1]);

  wire \G1:-1 ;

  Gij \1:-1 (P[1], G[1], \G0:-1 , \G1:-1 );

  Sum s2(\G1:-1 , A[2], B[2], S[2]);

  wire \P2:1 , \G2:1 ;

  PijGij \2:1 (P[2], P[1], G[2], G[1], \P2:1 , \G2:1 );

  wire \G2:-1 ;

  Gij \2:-1 (\P2:1 , \G2:1 , \G0:-1 , \G2:-1 );

  Sum s3(\G2:-1 , A[3], B[3], S[3]);

  wire \G3:-1 ;

  Gij \3:-1 (P[3], G[3], \G2:-1 , \G3:-1 );

  Sum s4(\G3:-1 , A[4], B[4], S[4]);

  wire \P4:3 , \G4:3 ;

  PijGij \4:3 (P[4], P[3], G[4], G[3], \P4:3 , \G4:3 );

  wire \G4:-1 ;

  Gij \4:-1 (\P4:3 , \G4:3 , \G2:-1 , \G4:-1 );

  Sum s5(\G4:-1 , A[5], B[5], S[5]);

  wire \P5:3 , \G5:3 ;

  PijGij \5:3 (P[5], \P4:3 , G[5], \G4:3 , \P5:3 , \G5:3 );

  wire \G5:-1 ;

  Gij \5:-1 (\P5:3 , \G5:3 , \G2:-1 , \G5:-1 );

  Sum s6(\G5:-1 , A[6], B[6], S[6]);

  wire \P6:5 , \G6:5 ;

  PijGij \6:5 (P[6], P[5], G[6], G[5], \P6:5 , \G6:5 );

  wire \P6:3 , \G6:3 ;

  PijGij \6:3 (\P6:5 , \P4:3 , \G6:5 , \G4:3 , \P6:3 , \G6:3 );

  wire \G6:-1 ;

  Gij \6:-1 (\P6:3 , \G6:3 , \G2:-1 , \G6:-1 );

  Sum s7(\G6:-1 , A[7], B[7], S[7]);

  wire \G7:-1 ;

  Gij \7:-1 (P[7], G[7], \G6:-1 , \G7:-1 );

  Sum s8(\G7:-1 , A[8], B[8], S[8]);

  wire \P8:7 , \G8:7 ;

  PijGij \8:7 (P[8], P[7], G[8], G[7], \P8:7 , \G8:7 );

  wire \G8:-1 ;

  Gij \8:-1 (\P8:7 , \G8:7 , \G6:-1 , \G8:-1 );

  Sum s9(\G8:-1 , A[9], B[9], S[9]);

  wire \P9:7 , \G9:7 ;

  PijGij \9:7 (P[9], \P8:7 , G[9], \G8:7 , \P9:7 , \G9:7 );

  wire \G9:-1 ;

  Gij \9:-1 (\P9:7 , \G9:7 , \G6:-1 , \G9:-1 );

  Sum s10(\G9:-1 , A[10], B[10], S[10]);

  assign Cout = (\G9:-1 & A[10]) | (\G9:-1 & B[10]) | (A[10] & B[10]);

endmodule
