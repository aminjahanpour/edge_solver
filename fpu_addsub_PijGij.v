

module Gij(\Pi:k , \Gi:k , \Gk-1:j , \Gi:j );
  input \Pi:k , \Gi:k , \Gk-1:j ;
  output \Gi:j ;

  assign \Gi:j = \Gi:k | (\Pi:k  & \Gk-1:j );
endmodule

module PijGij(\Pi:k , \Pk-1:j , \Gi:k , \Gk-1:j , \Pi:j , \Gi:j );
  input \Pi:k , \Pk-1:j , \Gi:k , \Gk-1:j ;
  output \Pi:j , \Gi:j ;

  assign \Pi:j = \Pi:k & \Pk-1:j ;
  assign \Gi:j = \Gi:k | (\Pi:k  & \Gk-1:j );
endmodule

module Sum(\Gi-1:-1 , Ai, Bi, Si);
  input \Gi-1:-1 , Ai, Bi;
  output Si;

  assign Si = \Gi-1:-1 ^ Ai ^ Bi;
endmodule

