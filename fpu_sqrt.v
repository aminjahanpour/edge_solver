module sqrt #(
    parameter width =       128,                          // width of radicand
    parameter floating_bits =       64                          // fractional bits (for fixed point)
    ) (

    input                               clk,
    input                               start,             // start signal
    output reg                          busy,              // calculation in progress
    output reg                          valid,             // root and rem are valid
    input           [width - 1 : 0]     rad,                // radicand
    output reg      [width - 1 : 0]     root,               // root
    output reg      [width - 1 : 0]     rem                 // remainder
    );


    reg                                                     sqrt_verbose = 1;



    reg             [width - 1 : 0]     x,      x_next;     // radicand copy
    reg             [width - 1 : 0]     q,      q_next;     // intermediate root (quotient)
    reg             [width + 1 : 0]     ac,     ac_next;    // accumulator (2 bits wider)
    reg             [width + 1 : 0]     test_res;           // sign test result (2 bits wider)



    localparam iteration = (width+floating_bits) >> 1;  // iterations are half radicand+fbits width
    reg             [$clog2(iteration)-1:0]  i;            // iteration counter


    always @(posedge start) begin

        if (sqrt_verbose) $display("sqrt module: sqrt started for %f",
        $bitstoreal(toolkit.display_float(toolkit.fixed_point_to_float_sp(rad)))
        
        );


        busy <= 1;
        valid <= 0;
        i <= 0;
        q <= 0;
        {ac, x} <= {{width{1'b0}}, rad, 2'b0};
    end


    always @(*) begin
        test_res = ac - {q, 2'b01};
        if (test_res[width+1] == 0) begin  // test_res ≥0? (check MSB)
            {ac_next, x_next} = {test_res[width-1:0], x, 2'b0};
            q_next = {q[width-2:0], 1'b1};
        end else begin
            {ac_next, x_next} = {ac[width-1:0], x, 2'b0};
            q_next = q << 1;
        end
    end

    always @(posedge clk) begin
        if (busy) begin
            if (i == iteration-1) begin  // we're done
                busy <= 0;
                valid <= 1;
                root <= q_next;
                rem <= ac_next[width+1:2];  // undo final shift
            end else begin  // next iteration
                i <= i + 1;
                x <= x_next;
                ac <= ac_next;
                q <= q_next;
            end
        end
    end
endmodule
