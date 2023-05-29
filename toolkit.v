module toolkit();



localparam q_full = 128;
localparam q_half = 64;

localparam sf    = 2.0**-64.0;  
localparam sf_dv = 2.0**-16.0;  
localparam sf_f  = 2.0**-16.0;

localparam f_bitstream_len 	= 32;


    function signed [q_full - 1 : 0] mult;
        input signed [q_full - 1 : 0] mult_first;
        input signed [q_full - 1 : 0] mult_second;
        reg signed  [2 * q_full - 1 : 0] mult_buf;
        begin
                mult_buf = mult_first * mult_second;
                mult = mult_buf[3 * q_half - 1 : q_half];
        end
    endfunction





    function  [64 - 1 : 0] display_float;
        input    [32 - 1 : 0] x;
        begin
			display_float = {x[31], x[30], {3{~x[30]}}, x[29:23], x[22:0], {29{1'b0}}};
        end;
    endfunction




    function signed [f_bitstream_len - 1 : 0] q_full_to_16q16;
        input   signed  [q_full - 1 : 0] fixed_point;
        reg             [q_full - 1 : 0] fixed_point_abs;

        reg                                 sign_v;
        

        begin

            if (fixed_point < 0) begin
                sign_v = 1;
                fixed_point_abs = -fixed_point;
            end else begin
                sign_v = 0;
                fixed_point_abs = fixed_point;

            end



            q_full_to_16q16 = fixed_point_abs[q_half + 16  - 1 : q_half - 16];

            if (sign_v) begin
                q_full_to_16q16 = -q_full_to_16q16;
            end

        end

    endfunction



    function signed [q_full - 1 : 0] float_sp_to_fixed_point_64_64;
        
            input          [32 - 1 : 0]        float_sp; 
               
            reg            [8 - 1 : 0]         exponent;
            reg            [23 - 1 : 0 ]       significand;
            reg            [q_full - 1 : 0]    test_L;
            reg            [q_full - 1 : 0]    test_frac;
            reg            [q_full - 1 : 0]    answer_mag;

        begin

            // $display("float_sp_to_fixed_point_64_64: float_sp:%b", float_sp);

             exponent    = float_sp[30 : 23];
            // $display("float_sp_to_fixed_point_64_64: exponent:%b(%d)", exponent, exponent);

             significand = float_sp[22: 0];
            // $display("float_sp_to_fixed_point_64_64: significand:%b", significand);


            if (exponent < 127) begin
                test_L = 1 << ( q_half - (127 - exponent) );
                
            end else begin
                test_L      = (1 << (exponent - 127)) << q_half;
                
            end

            // $display("float_sp_to_fixed_point_64_64: test_L:%b", test_L);


             test_frac   = (significand << (q_half - 23));
            // $display("float_sp_to_fixed_point_64_64: test_frac:%b", test_frac);

             answer_mag  = test_L + mult(test_L, test_frac);
            // $display("float_sp_to_fixed_point_64_64: answer_mag:%b", answer_mag);


            float_sp_to_fixed_point_64_64      = (float_sp[31]) ? -answer_mag : answer_mag;
            // $display("float_sp_to_fixed_point_64_64: float_sp_to_fixed_point_64_64:%b", float_sp_to_fixed_point_64_64);

        end

        
    endfunction























    function signed [32 - 1 : 0] fixed_point_to_float_sp;
        
        input signed      [q_full - 1 : 0]        fixed_point;
        reg      [q_full - 1 : 0]        fixed_point_abs;

        reg            [8 - 1 : 0]         exponent;
        reg            [23 - 1 : 0 ]       significand;
        
        reg                                 have_found;
        reg         [32 - 1     : 0]        first_1_pos;

        reg         [q_full - 1     : 0]        significand_mask;

        reg                                 sign_v;

        integer i;

        begin
            if (fixed_point == 0) begin
                fixed_point_to_float_sp = 0;
                
            end else begin
                // $display("`\n\t\tfixed_point_to_float_sp fun: %b_%b",
                // fixed_point[q_full - 1 : q_half],
                // fixed_point[q_half - 1 : 0]
                // );
                
                if (fixed_point < 0) begin
                    sign_v = 1;
                    fixed_point_abs = -fixed_point;
                end else begin
                    sign_v = 0;
                    fixed_point_abs = fixed_point;

                end


                have_found = 0;

                for (i = q_full - 2; i > 0; i = i - 1) begin
                    if ((fixed_point_abs[i] == 1) && (~have_found)) begin
                        have_found = 1;
                        first_1_pos = i - q_half;
                    end
                end


                // $display("`\t\tfixed_point_to_float_sp fun: first_1_pos: %d", first_1_pos + q_half);


                exponent = first_1_pos + 127;
                // $display("`\t\tfixed_point_to_float_sp fun: exponent: %b(%d)", exponent, exponent);



                significand = fixed_point_abs >> (first_1_pos + q_half - 23);
                // $display("`\t\tfixed_point_to_float_sp fun: significand: %b(%d)", significand, significand);

                fixed_point_to_float_sp = 0;

                fixed_point_to_float_sp = {(sign_v)? 1'b1 : 1'b0, exponent, significand};

                // $display("`\t\tfixed_point_to_float_sp fun: fixed_point_to_float_sp: %f", $bitstoreal(display_float(fixed_point_to_float_sp)));
            end
        end


    endfunction






endmodule