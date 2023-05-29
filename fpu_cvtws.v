
module cvtws (

  
  input signed      [32-1:0] 			cvtws_in,
  output reg signed       [32 - 1:0] 		cvtws_out

  );

    reg		cvtws_verbose = 0;

    reg [8 - 1 : 0 ]    exponent;
    reg [23 - 1 : 0 ]    significand;

    integer i;


    always @(*) begin
        if (cvtws_verbose) $display("cvtws_in      :%b (%d)", cvtws_in, cvtws_in);

        exponent = cvtws_in[30 : 23] - 127;
        significand = cvtws_in[22: 0];

        if (cvtws_verbose) $display("exponent:%b (%d)", exponent, exponent);
        if (cvtws_verbose) $display("significand:%b (%d)", significand>>1, significand>>1);

        cvtws_out = 2 << (exponent - 1);


        for (i = 0; i < 23; i = i +1 ) begin
            if (significand[22 - i]) begin
                if (cvtws_verbose) $display("\ni:%d, significand[23 - i]:%b", i, significand[23 - i]);
                if (cvtws_verbose) $display("s:%d + s/2^(%d),  %f", cvtws_out, i+1,cvtws_out/(2 << (i + 1 - 1)));
                cvtws_out = cvtws_out + cvtws_out / (2 << (i + 1 - 1));
                if (cvtws_verbose) $display("s:%d", cvtws_out);

            end
        end

        if (cvtws_in[31]) begin
            cvtws_out = -cvtws_out;
            if (cvtws_verbose) $display("neg input");
        end



    end


endmodule
