

module padder24(A, B, Cin, S, Cout);
  parameter N = 24;
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

  wire \P10:9 , \G10:9 ;

  PijGij \10:9 (P[10], P[9], G[10], G[9], \P10:9 , \G10:9 );

  wire \P10:7 , \G10:7 ;

  PijGij \10:7 (\P10:9 , \P8:7 , \G10:9 , \G8:7 , \P10:7 , \G10:7 );

  wire \G10:-1 ;

  Gij \10:-1 (\P10:7 , \G10:7 , \G6:-1 , \G10:-1 );

  Sum s11(\G10:-1 , A[11], B[11], S[11]);

  wire \P11:7 , \G11:7 ;

  PijGij \11:7 (P[11], \P10:7 , G[11], \G10:7 , \P11:7 , \G11:7 );

  wire \G11:-1 ;

  Gij \11:-1 (\P11:7 , \G11:7 , \G6:-1 , \G11:-1 );

  Sum s12(\G11:-1 , A[12], B[12], S[12]);

  wire \P12:11 , \G12:11 ;

  PijGij \12:11 (P[12], P[11], G[12], G[11], \P12:11 , \G12:11 );

  wire \P12:7 , \G12:7 ;

  PijGij \12:7 (\P12:11 , \P10:7 , \G12:11 , \G10:7 , \P12:7 , \G12:7 );

  wire \G12:-1 ;

  Gij \12:-1 (\P12:7 , \G12:7 , \G6:-1 , \G12:-1 );

  Sum s13(\G12:-1 , A[13], B[13], S[13]);

  wire \P13:11 , \G13:11 ;

  PijGij \13:11 (P[13], \P12:11 , G[13], \G12:11 , \P13:11 , \G13:11 );

  wire \P13:7 , \G13:7 ;

  PijGij \13:7 (\P13:11 , \P10:7 , \G13:11 , \G10:7 , \P13:7 , \G13:7 );

  wire \G13:-1 ;

  Gij \13:-1 (\P13:7 , \G13:7 , \G6:-1 , \G13:-1 );

  Sum s14(\G13:-1 , A[14], B[14], S[14]);

  wire \P14:13 , \G14:13 ;

  PijGij \14:13 (P[14], P[13], G[14], G[13], \P14:13 , \G14:13 );

  wire \P14:11 , \G14:11 ;

  PijGij \14:11 (\P14:13 , \P12:11 , \G14:13 , \G12:11 , \P14:11 , \G14:11 );

  wire \P14:7 , \G14:7 ;

  PijGij \14:7 (\P14:11 , \P10:7 , \G14:11 , \G10:7 , \P14:7 , \G14:7 );

  wire \G14:-1 ;

  Gij \14:-1 (\P14:7 , \G14:7 , \G6:-1 , \G14:-1 );

  Sum s15(\G14:-1 , A[15], B[15], S[15]);

  wire \G15:-1 ;

  Gij \15:-1 (P[15], G[15], \G14:-1 , \G15:-1 );

  Sum s16(\G15:-1 , A[16], B[16], S[16]);

  wire \P16:15 , \G16:15 ;

  PijGij \16:15 (P[16], P[15], G[16], G[15], \P16:15 , \G16:15 );

  wire \G16:-1 ;

  Gij \16:-1 (\P16:15 , \G16:15 , \G14:-1 , \G16:-1 );

  Sum s17(\G16:-1 , A[17], B[17], S[17]);

  wire \P17:15 , \G17:15 ;

  PijGij \17:15 (P[17], \P16:15 , G[17], \G16:15 , \P17:15 , \G17:15 );

  wire \G17:-1 ;

  Gij \17:-1 (\P17:15 , \G17:15 , \G14:-1 , \G17:-1 );

  Sum s18(\G17:-1 , A[18], B[18], S[18]);

  wire \P18:17 , \G18:17 ;

  PijGij \18:17 (P[18], P[17], G[18], G[17], \P18:17 , \G18:17 );

  wire \P18:15 , \G18:15 ;

  PijGij \18:15 (\P18:17 , \P16:15 , \G18:17 , \G16:15 , \P18:15 , \G18:15 );

  wire \G18:-1 ;

  Gij \18:-1 (\P18:15 , \G18:15 , \G14:-1 , \G18:-1 );

  Sum s19(\G18:-1 , A[19], B[19], S[19]);

  wire \P19:15 , \G19:15 ;

  PijGij \19:15 (P[19], \P18:15 , G[19], \G18:15 , \P19:15 , \G19:15 );

  wire \G19:-1 ;

  Gij \19:-1 (\P19:15 , \G19:15 , \G14:-1 , \G19:-1 );

  Sum s20(\G19:-1 , A[20], B[20], S[20]);

  wire \P20:19 , \G20:19 ;

  PijGij \20:19 (P[20], P[19], G[20], G[19], \P20:19 , \G20:19 );

  wire \P20:15 , \G20:15 ;

  PijGij \20:15 (\P20:19 , \P18:15 , \G20:19 , \G18:15 , \P20:15 , \G20:15 );

  wire \G20:-1 ;

  Gij \20:-1 (\P20:15 , \G20:15 , \G14:-1 , \G20:-1 );

  Sum s21(\G20:-1 , A[21], B[21], S[21]);

  wire \P21:19 , \G21:19 ;

  PijGij \21:19 (P[21], \P20:19 , G[21], \G20:19 , \P21:19 , \G21:19 );

  wire \P21:15 , \G21:15 ;

  PijGij \21:15 (\P21:19 , \P18:15 , \G21:19 , \G18:15 , \P21:15 , \G21:15 );

  wire \G21:-1 ;

  Gij \21:-1 (\P21:15 , \G21:15 , \G14:-1 , \G21:-1 );

  Sum s22(\G21:-1 , A[22], B[22], S[22]);

  wire \P22:21 , \G22:21 ;

  PijGij \22:21 (P[22], P[21], G[22], G[21], \P22:21 , \G22:21 );

  wire \P22:19 , \G22:19 ;

  PijGij \22:19 (\P22:21 , \P20:19 , \G22:21 , \G20:19 , \P22:19 , \G22:19 );

  wire \P22:15 , \G22:15 ;

  PijGij \22:15 (\P22:19 , \P18:15 , \G22:19 , \G18:15 , \P22:15 , \G22:15 );

  wire \G22:-1 ;

  Gij \22:-1 (\P22:15 , \G22:15 , \G14:-1 , \G22:-1 );

  Sum s23(\G22:-1 , A[23], B[23], S[23]);

  assign Cout = (\G22:-1 & A[23]) | (\G22:-1 & B[23]) | (A[23] & B[23]);

endmodule
