module division #(

    parameter                                               width                           = 0,  // width of numbers in bits

    parameter                                               floating_bits                   = 0   // fractional bits (for fixed point)

    ) (

    input                                                   clk,
    input                                                   start,          // start signal
    output     reg                                          busy,           // calculation in progress
    output     reg                                          valid,          // quotient and remainder are valid
    output     reg                                          dbz,            // divide by zero flag
    output     reg                                          ovf,            // overflow flag (fixed-point)
    input           signed  [width - 1 : 0]                 x,              // dividend
    input           signed  [width - 1 : 0]                 y,              // divisor
    output     reg  signed  [width - 1 : 0]                 q,              // quotient
    output     reg          [width - 1 : 0]                 r               // remainder

    );

    reg                                                     division_verbose = 1;


    reg                     [width - 1 : 0]                 x_cast;
    reg                     [width - 1 : 0]                 y_cast;
    reg                                                     negative_value;
    reg                                                     finished_dividing;

    // avoid negative vector width when fractional bits are not used
    localparam                                              floating_bits_w                 = (floating_bits) ? floating_bits : 1;
    localparam                                              ITER                            = width + floating_bits;  // iterations are dividend width + fractional bits



    reg                     [width - 1 : 0]                 y1;             // copy of divisor
    reg                     [width - 1 : 0]                 q1;             // intermediate quotient
    reg                     [width - 1 : 0]                 q1_next;        // intermediate quotient
    reg                     [width : 0]                     ac;             // accumulator (1 bit wider)
    reg                     [width : 0]                     ac_next;        // accumulator (1 bit wider)
    reg                     [$clog2(ITER) - 1 : 0]          i;              // iteration counter

    reg                     initialized;


    reg                     division_stepper;

    always @(posedge start) begin
        if (division_verbose) $display("division module: division started for %f / %f",
        $bitstoreal(toolkit.display_float(toolkit.fixed_point_to_float_sp(x))),
        $bitstoreal(toolkit.display_float(toolkit.fixed_point_to_float_sp(y))),
        );

        busy = 1;

        initialized = 0;

        finished_dividing = 0;

        division_stepper = 1;

    end
        



    always @(posedge clk) begin
        
        if ((initialized == 0) && (busy == 1)) begin
            


            y1 = 0;
            q1 = 0;
            q1_next = 0;
            ac = 0;
            ac_next = 0;
            i = 0;

            x_cast = 0;
            y_cast = 0;

            valid = 0;
            dbz = 0;
            ovf = 0;
            q= 0;
            r = 0;



            if (y == 0) begin  // catch divide by zero
                if (division_verbose) $display("division module: y=0 !");

                dbz = 1;
                busy = 0;

            end else if (x == y) begin
                if (division_verbose) $display("division module: x = y !");

                q = 1 << floating_bits;
                r = 0;
                valid = 1;
                busy = 0;

            end else if (x == 0) begin
                if (division_verbose) $display("division module: x = 0 !");

                q = 0;
                r = y;
                valid = 1;
                busy = 0;


            end else begin

                if ((x < 0) && (y < 0)) begin
                    x_cast = -x;
                    y_cast = -y;
                    negative_value = 0;

                end else if ((x < 0) && (y > 0)) begin
                    x_cast = -x;
                    y_cast = y;
                    negative_value = 1;
                    
                end else if ((x > 0) && (y < 0)) begin
                    x_cast = x;
                    y_cast = -y;
                    negative_value = 1;
                    
                end else if ((x > 0) && (y > 0)) begin

                    x_cast = x;
                    y_cast = y;
                    negative_value = 0;
                    
                end

                dbz = 0;
                y1 = y_cast;
                {ac, q1} = {{width{1'b0}}, x_cast, 1'b0};
            
                // $display("\ninitialting:  ac: %b   q1: %b",ac, q1);

            end


            initialized = 1;

            // $display("initialized= %d", initialized);
            // $display("busy=%d", busy);
            // $display("\ndivision started for %b / %b", x_cast,y_cast);
            // $display("\n ac: %b   q1: %b",ac, q1);

        end 
        
    end



    always @(posedge clk or negedge clk) begin

        if ((busy) && (initialized)) begin



            if (division_stepper == 0) begin






                if (i == ITER-1) begin  // done
                    // $display("done");

                    valid = 1;
                    q = q1_next;
                    r = ac_next[width:1];  // undo final shift
                    finished_dividing = 1;
                    // $display("%d, %d, %d, %b", i, ITER, busy,q1_next, ac_next);

                end else if (i == width-1 && q1_next[width - 1 : width - floating_bits_w]) begin // overflow?
                    $display("ovf");

                    ovf = 1;
                    q = 0;
                    r = 0;
                    finished_dividing = 1;

                end else begin  // next iteration

                    i = i + 1;
                    ac = ac_next;
                    q1 = q1_next;
                        

                    // $display("%d, %d, %d, %b, %b", i, ITER, busy,ac_next, q1_next);
                end


                if (finished_dividing == 1) begin
                    // $display("finished_dividing");
                    if (negative_value == 1) begin
                        q = -q;
                        busy = 0;

                    end else begin
                        busy = 0;
                        
                    end

                    finished_dividing = 0;

                end 














            end else begin

                // you need to make sure this segment runs first

                // $display("ac:%b, {1'b0,y1}:%b, y1:%b", ac, {1'b0,y1}, y1);

                if (ac >= {1'b0,y1}) begin

                    ac_next = ac - y1;

                    {ac_next, q1_next} = {ac_next[width-1:0], q1, 1'b1};

                end else begin

                    {ac_next, q1_next} = {ac, q1} << 1;

                end



                // $display("%b,%b,%b,%b", ac_next, q1_next,ac,q1);
            end















            division_stepper = ~division_stepper;













        end





    end





endmodule
