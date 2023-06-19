module bite_operations #(
    parameter register_width = 0,
    parameter max_time = 0
)(
		input                                           clk_bite,        
		input                                           go,
        input       [register_width - 1 : 0]            instr,
        input       [register_width - 1 : 0]            input_var_0,
        input       [register_width - 1 : 0]            input_var_1,
        output reg  [register_width - 1 : 0]            results,
        output reg                                      finished,
        output reg                                      time_violation
   	);






// function codes
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];


wire signed       [q_full - 1 : 0]          input_var_0_fixed_point = toolkit.float_sp_to_fixed_point_64_64(input_var_0);
wire signed       [q_full - 1 : 0]          input_var_1_fixed_point = toolkit.float_sp_to_fixed_point_64_64(input_var_1);
reg signed        [32 - 1 : 0]              mult_ret;







reg                                                 handle_incoming_ask_flag;
reg                                                 handle_incoming_tell_flag;



// dispatcher
always @(posedge go) begin

    finished = 0;

    // input_var_0_fixed_point = toolkit.float_sp_to_fixed_point_64_64(input_var_0);


    if (verbose) $display("BITE OPERATIONS:   funct3:%b\ninput_var_0:%f(%d)(%b)\ninput_var_1:%f(%d)(%b)",
    funct3, sf*input_var_0_fixed_point, input_var_0,input_var_0, sf*input_var_1_fixed_point, input_var_1, input_var_1);


    if ($time > max_time) begin

            time_violation = 1;

    end

    case (funct3)
        3'b000   :           begin
            if (verbose) $display("----> bite:RST operation instructed");
            
            reset = 1;

        end

        3'b001   :           begin
            if (verbose) $display("----> bite:ASK operation instructed");


            handle_incoming_ask_flag = 1;
        end


        3'b010   :           begin
            if (verbose) $display("----> bite:TELL operation instructed");

            handle_incoming_tell_flag = 1;
        end



    endcase
end




















// 10_C_manager
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------


// procedural parameters

reg         [address_len - 1 : 0]       iteration;

reg                                     started_by_reset;


reg         [address_len - 1 : 0]       index_of_worst;


reg                                     sol_ready_flag;
reg                                     f_ready_flag;


reg                                                     reset;




always @(posedge reset) begin

    if (verbose) $display("----> bite:resetting");

    num_dec = input_var_0_fixed_point >> q_half;
    budget  = input_var_1_fixed_point >> q_half;

    if (verbose) $display("----> bite:budget:%d", budget);
    if (verbose) $display("----> bite:num_dec:%d", num_dec);

    // $finish();
    reset = 0;
    time_violation = 0;

    iteration                   = 0;
    sol_ready_flag              = 0;
    f_ready_flag                = 0;
    index_of_worst              = 0;
    
    ParamCntr                   = 0;
    RandSwitch                  = 0;
    RaiseFlags                  = 0;
    ci                          = 0;


    // initializing f_best
    f_best                      = 4'b1010 << q_half;

    // initializing CentParams
    for (i = 0; i < dv_per_solution; i = i + 1) begin
        CentParams[i]   = 0;
        MinParams[i]    = 0;
        rp0[i]          = 0;
        rp1[i]          = 0;
        rp2[i]          = 0;
        OrigParams[i]   = 0;
        MaxParams[i]    = 0;
        x_new_full_q[i] = 0;
    end

    $display("archive size:%d", archive_size);

    si      =0;
    si2     =0;
    si3     =0;
    si4     =0;
    a       =0;
    b       =0;

    imask   =0;
    imask2  =0;
    mask_shift=0;
    v0      =0;
    v1      =0;
    v2      =0;

    m1      =0;
    m2      =0;



    if (verbose) $display("main_memory_depth:%d", main_memory_depth);




    // test_retry_random = 1;
    // $display(dv_to_real(16'b1100101100000110));



    // for (i = 0; i < 10 ; i =i+1) begin
    //     // $display("%f", 0.5 + (2.0**-32.0) *  $random);
    //     $display("%b", real_dec_to_16bit(uniform_random_value(dummy)));
    //     // $display("%b", $random);
    // end

    // U10_output_file_main_mem =                                $fopen("./dumps/U10_output_file_main_mem.txt", "w");

    // N0_output_file_random_values =                            $fopen("./dumps/N0_output_file_random_values.txt", "w");

    // V1_output_file_evaluations =                              $fopen("./dumps/V1_output_file_evaluations.txt", "w");



    $display("\n\n reset at %d", $time);





    // reset the mutation parameters
    lagger_C2_bite = 0;
    C2_reset_mutation_parameters_flag = 1;



    $fdisplay(V1_output_file_evaluations,"%d", num_dec);

    // $finish();
end




always @(posedge f_ready_flag) begin
    if (verbose) $display("----> bite:f_ready_flag was set");

    sol_ready_flag = 0;
    f_ready_flag   = 0;


    if (verbose) $display("\n MANAGER: got new f,  ----------- iteration:%d,      time:%d", iteration, $time);


    if (iteration <= archive_size ) begin

        if (verbose) $display("MAANGER: initializing.. iteration: %d", iteration);


        // settings and launching D0
        lagger_D0_bite  = 0;
        D0_initialize_archive_flag = 1;

    end else begin


        if (verbose) $display("MAANGER: updadating.. iteration: %d", iteration);


        // setting and launching F1
        lagger_F1_bite = 0;
        counter_F1_bite = 0;
        F1_update_archive_flag = 1;



    end


end




always @(posedge sol_ready_flag) begin

    /*
    nothing to do
    return a dummy value
    just return the control to the core
    */


    if (verbose) $display("----> bite:sol_ready_flag was set");

    sol_ready_flag = 0;

    results = 32'hbf9d70a4;
    // mult_ret = toolkit.fixed_point_to_float_sp(toolkit.toolkit.mult(input_var_0_fixed_point, input_var_1_fixed_point));

    // results = mult_ret;


    f_ready_flag = 0;


    finished = 1;


    if (verbose) $display("----> bite:finished, iteration: %d", iteration);

end



always @(posedge handle_incoming_ask_flag) begin

    if (verbose) $display("----> bite:setting handle_incoming_ask_flag");

    handle_incoming_ask_flag = 0;

    results = toolkit.fixed_point_to_float_sp(sol_most_recent[input_var_0_fixed_point >> q_half] << (q_half - 16));
    
    if (verbose) $display("----> bite:ASK results: %f", $bitstoreal(toolkit.display_float(results)) );
    


    finished = 1;

    if (verbose) $display("----> bite:finished, iteration: %d", iteration);


end



always @(posedge handle_incoming_tell_flag) begin
    if (verbose) $display("----> bite:handle_incoming_tell_flag");

    handle_incoming_tell_flag = 0;

    f_ready_flag = 0;
    sol_ready_flag = 0;


    f_bitstream = toolkit.q_full_to_16q16(input_var_0_fixed_point);

    // $fdisplay(V1_output_file_evaluations, "%f", 2.0**-16.0 * f_bitstream);

    $fdisplay(V1_output_file_evaluations, "%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f",
    sf_dv * sol_most_recent[0],
    sf_dv * sol_most_recent[1],
    sf_dv * sol_most_recent[2],
    sf_dv * sol_most_recent[3],
    sf_dv * sol_most_recent[4],
    sf_dv * sol_most_recent[5],
    sf_dv * sol_most_recent[6],
    sf_dv * sol_most_recent[7],
    sf_dv * sol_most_recent[8],
    sf_dv * sol_most_recent[9],
    sf_dv * sol_most_recent[10],
    sf_dv * sol_most_recent[11],
    sf_dv * sol_most_recent[12],
    sf_dv * sol_most_recent[13],
    sf_dv * sol_most_recent[14],
    sf_dv * sol_most_recent[15],
    2.0**-16.0 * f_bitstream);




    if (verbose) $display("----> bite:f_bitstream: %f", 2.0**-16.0 * f_bitstream);



    f_ready_flag = 1;

    
end








// C2

// flag
reg                                                     C2_reset_mutation_parameters_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_C2_bite;

// C2 variables


//C2_reset_mutation_parameters_flag
always @(negedge clk_bite) begin
if (C2_reset_mutation_parameters_flag == 1) begin
    lagger_C2_bite = lagger_C2_bite + 1;

    if (lagger_C2_bite == 1) begin
        if (verbose) $display("C2: generating new random solution");
        

        C2_reset_mutation_parameters_flag = 0;
        // setting and launching Randomizer
        counter_N1_bite = 0;
        lagger_N1_bite  = 0;
        caller_to_randomizer_is = caller_to_randomizer_is_C2;
        N1_get_new_random_values_flag = 1;


    end else if (lagger_C2_bite == 2) begin
        
        case (num_dec)
            1   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0001001110110001001110110001001110110001001110110001010000000000;  //0.07692307692307693
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0001010101010101010101010101010101010101010101010101010100000000;  //0.08333333333333333
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000010000000000000000000000000000000000;  //9.313225746154785e-10
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000010_0000000000000000000000000000000000000000000000000000000000000000;  //2.0
                      end
            2   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0001000100010001000100010001000100010001000100010001000100000000;  //0.06666666666666667
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0001001001001001001001001001001001001001001001001001001000000000;  //0.07142857142857142
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000100000000000000000000000000000000000;  //1.862645149230957e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000001_0000000000000000000000000000000000000000000000000000000000000000;  //1.0
                      end
            3   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000111100001111000011110000111100001111000011110000111100000000;  //0.058823529411764705
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0001000000000000000000000000000000000000000000000000000000000000;  //0.0625
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000110000000000000000000000000000000000;  //2.7939677238464355e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_1010101010101010101010101010101010101010101010101010100000000000;  //0.6666666666666666
                      end
            4   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000110101111001010000110101111001010000110101111001010000000000;  //0.05263157894736842
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000111000111000111000111000111000111000111000111000111000000000;  //0.05555555555555555
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000001000000000000000000000000000000000000;  //3.725290298461914e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_1000000000000000000000000000000000000000000000000000000000000000;  //0.5
                      end
            5   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000110000110000110000110000110000110000110000110000110000000000;  //0.047619047619047616
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000110011001100110011001100110011001100110011001100110100000000;  //0.05
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000001010000000000000000000000000000000000;  //4.6566128730773926e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0110011001100110011001100110011001100110011001100110100000000000;  //0.4
                      end
            6   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000101100100001011001000010110010000101100100001011001000000000;  //0.043478260869565216
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000101110100010111010001011101000101110100010111010001100000000;  //0.045454545454545456
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000001100000000000000000000000000000000000;  //5.587935447692871e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0101010101010101010101010101010101010101010101010101010000000000;  //0.3333333333333333
                      end
            7   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000101000111101011100001010001111010111000010100011110110000000;  //0.04
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000101010101010101010101010101010101010101010101010101010000000;  //0.041666666666666664
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000001110000000000000000000000000000000000;  //6.51925802230835e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0100100100100100100100100100100100100100100100100100100000000000;  //0.2857142857142857
                      end
            8   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100101111011010000100101111011010000100101111011010000000000;  //0.037037037037037035
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100111011000100111011000100111011000100111011000101000000000;  //0.038461538461538464
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000010000000000000000000000000000000000000;  //7.450580596923828e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0100000000000000000000000000000000000000000000000000000000000000;  //0.25
                      end
            9   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100011010011110111001011000010001101001111011100101100000000;  //0.034482758620689655
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100100100100100100100100100100100100100100100100100100000000;  //0.03571428571428571
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000010010000000000000000000000000000000000;  //8.381903171539307e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0011100011100011100011100011100011100011100011100011100000000000;  //0.2222222222222222
                      end
            10   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100001000010000100001000010000100001000010000100001000000000;  //0.03225806451612903
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100010001000100010001000100010001000100010001000100010000000;  //0.03333333333333333
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000010100000000000000000000000000000000000;  //9.313225746154785e-09
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0011001100110011001100110011001100110011001100110011010000000000;  //0.2
                      end
            11   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011111000001111100000111110000011111000001111100001000000000;  //0.030303030303030304
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000100000000000000000000000000000000000000000000000000000000000;  //0.03125
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000010110000000000000000000000000000000000;  //1.0244548320770264e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010111010001011101000101110100010111010001011101000110000000000;  //0.18181818181818182
                      end
            12   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011101010000011101010000011101010000011101010000011101000000;  //0.02857142857142857
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011110000111100001111000011110000111100001111000011110000000;  //0.029411764705882353
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000011000000000000000000000000000000000000;  //1.1175870895385742e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010101010101010101010101010101010101010101010101010101000000000;  //0.16666666666666666
                      end
            13   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011011101011001111100100010100110000011011101011010000000000;  //0.02702702702702703
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011100011100011100011100011100011100011100011100011100000000;  //0.027777777777777776
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000011010000000000000000000000000000000000;  //1.210719347000122e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010011101100010011101100010011101100010011101100010100000000000;  //0.15384615384615385
                      end
            14   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011010010000011010010000011010010000011010010000011010000000;  //0.02564102564102564
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011010111100101000011010111100101000011010111100101000000000;  //0.02631578947368421
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000011100000000000000000000000000000000000;  //1.30385160446167e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010010010010010010010010010010010010010010010010010010000000000;  //0.14285714285714285
                      end
            15   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011001100110011001100110011001100110011001100110011010000000;  //0.025
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011010010000011010010000011010010000011010010000011010000000;  //0.02564102564102564
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000011110000000000000000000000000000000000;  //1.3969838619232178e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010001000100010001000100010001000100010001000100010001000000000;  //0.13333333333333333
                      end
            16   :   begin
                      PopSizeI       = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011000011000011000011000011000011000011000011000011000000000;  //0.023809523809523808
                      inv_N_1        = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000011000111110011100000110001111100111000001100011111010000000;  //0.024390243902439025
                      ParamCountRnd  = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000100000000000000000000000000000000000000;  //1.4901161193847656e-08
                      AllpProbDamp   = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0010000000000000000000000000000000000000000000000000000000000000;  //0.125
                      end
        endcase

    end else if (lagger_C2_bite == 3) begin

        N                          = archive_size << q_half;
        PopSize1                   = (archive_size - 1) << (q_half);

        RandCntr = mp[0];
        RandCntr2 = mp[1];
        AllpCntr = mp[2];
        CentCntr = mp[3];
        ParamCntr = toolkit.mult(mp[4] , num_dec << q_half);
        RandSwitch = 0;
        RaiseFlags = 0;


    end else if (lagger_C2_bite == 4) begin
        if (verbose) $display("num_dec: %d", num_dec);
        if (verbose) $display("PopSizeI: %f", sf * PopSizeI);
        if (verbose) $display("inv_N_1: %f", sf * inv_N_1);
        if (verbose) $display("ParamCountRnd: %f", sf * ParamCountRnd);
        if (verbose) $display("AllpProbDamp: %f", sf * AllpProbDamp);

        if (verbose) $display("RandCntr: %f", sf * RandCntr);
        if (verbose) $display("RandCntr2: %f", sf * RandCntr2);
        if (verbose) $display("AllpCntr: %f", sf * AllpCntr);
        if (verbose) $display("CentCntr: %f", sf * CentCntr);
        if (verbose) $display("ParamCntr: %d", ParamCntr);
        if (verbose) $display("RandSwitch: %d", RandSwitch);


    end else if (lagger_C2_bite == 5) begin

        C2_reset_mutation_parameters_flag = 0;
            
            

        // start initializing the archive
        started_by_reset = 1;
        f_ready_flag = 1;



        lagger_C2_bite = 0;
    
    end 
end
end













// 00_declarations
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------


    localparam   verbose             = 0;

//num_dec_def
    reg                 [address_len - 1 : 0]               num_dec             ;
    reg                 [address_len - 1 : 0]               budget              ;
    wire                [address_len - 1 : 0]               archive_size        = 10 + 2 * num_dec;


    reg         signed  [f_bitstream_len - 1   : 0]         f_bitstream;
    reg                 [sol_bitstream_len - 1 : 0]         sol_bitstream;


    reg                 [bits_per_dv - 1 : 0]               sol_most_recent  [dv_per_solution - 1 : 0];





    localparam q_full = 128;
    localparam q_half = 64;
    localparam q_quarter = 32;

    localparam sf    = 2.0**-64.0;  
    localparam sf_dv = 2.0**-16.0;  
    localparam sf_f  = 2.0**-16.0;  

    /*
        every solution has 16 dvs each take 16 bits
        our archive size is at max 41, so address length of 8 is more than enough
    */

    localparam address_len      =   10;



    localparam dv_per_solution  =   16;
    localparam bits_per_dv      =   16;

    localparam sol_bitstream_len 	= dv_per_solution * bits_per_dv;
    localparam bytes_per_solution = sol_bitstream_len / 8;

    localparam f_bitstream_len 	= 32;
    localparam bytes_per_f = f_bitstream_len / 8;




    /*
    `solution` array structure

    a solution contains 16 dvs.
    each dv occupies 16 bits (unsigned).
    
    archive includes 41 solutions in it.
    */

    reg         [bits_per_dv - 1 : 0]       x_new           [dv_per_solution - 1 : 0];
    reg         [bits_per_dv - 1 : 0]       worst_sol       [dv_per_solution - 1 : 0];
    reg         [bits_per_dv - 1 : 0]       x_best          [dv_per_solution - 1 : 0];




    /*
    f 
    an f is a fixed percision number of width `f_bitstream_len`
    */
    reg signed  [f_bitstream_len - 1 : 0]            f_new   ;
    reg signed  [f_bitstream_len - 1 : 0]            worst_f ;
    reg signed  [f_bitstream_len - 1 : 0]            f_best  ;




    integer i;
    integer j;

    integer                                                 U10_output_file_main_mem;
    integer                                                 N0_output_file_random_values;
    integer                                                 V1_output_file_evaluations;

    real dummy;





    


    reg signed    [q_full - 1 : 0]     inv_N_1;


    reg signed    [q_full - 1 : 0]     N;
    reg signed    [q_full - 1 : 0]     PopSize1;

    reg signed    [q_full - 1 : 0]     PopSizeI;













    localparam base_memory_address = 0;

    localparam bma_new_sol      = base_memory_address;

    localparam bma_new_f        = bma_new_sol + bytes_per_solution;

    localparam bma_sol_archive  = bma_new_f + bytes_per_f;

    wire [address_len - 1 : 0] bma_f_archive    = bma_sol_archive + archive_size * bytes_per_solution;

    // localparam main_memory_depth = base_memory_address + bytes_per_solution + bytes_per_f + archive_size * (bytes_per_solution + bytes_per_f);  
    localparam main_memory_depth = 10_000;

    

    // every dv takes two bytes. every f takes 4 bytes.

    reg                                             	main_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]			main_mem_read_addr      ;
    wire                [8 - 1 	 : 0]    				main_mem_read_data      ;
    reg                                             	main_mem_write_enable   ;
    reg                 [address_len - 1 : 0]			main_mem_write_addr     ;
    reg                 [8 - 1 	 : 0]    				main_mem_write_data     ;

    memory_list #(
        .mem_width(8),
        .address_len(address_len),
        .mem_depth(main_memory_depth)

    ) main_mem(
        .clk(clk_bite),
        .r_en(  main_mem_read_enable),
        .r_addr(main_mem_read_addr),
        .r_data(main_mem_read_data),
        .w_en(  main_mem_write_enable),
        .w_addr(main_mem_write_addr),
        .w_data(main_mem_write_data)
    );

    















// 12_D_initialization
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------



// D0

// flag
reg                                                     D0_initialize_archive_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_D0_bite;

// D0 variables
/*
store the newly arrived `f` in the archive only if this is not triggered by a reset.
*/

//D0_initialize_archive_flag
always @(negedge clk_bite) begin
if (D0_initialize_archive_flag == 1) begin
    lagger_D0_bite = lagger_D0_bite + 1;

    if (lagger_D0_bite == 1) begin
        if (started_by_reset) begin
            if (verbose) $display("D0: it was a reset. not storing f.");
            started_by_reset = 0;
        end else begin

            // store new `f` in archive
            address_to_write_f_value_on_U3 = bma_f_archive + bytes_per_f * (iteration - 1);
            f_value_to_write_on_memory_U3  = f_bitstream;

            D0_initialize_archive_flag = 0;
            // setting and launching U3
            counter_U3_bite = 0;
            lagger_U3_bite  = 0;
            caller_to_U3 = caller_to_U3_is_D0;
            U3_write_f_on_main_memory_flag = 1;

            if (verbose) $display("D0: storing f at %d", address_to_write_f_value_on_U3);

        end

    end else if (lagger_D0_bite == 2) begin
        if (verbose) $display("D0: generating new random solution");
        

        D0_initialize_archive_flag = 0;
        // setting and launching Randomizer
        counter_N1_bite = 0;
        lagger_N1_bite  = 0;
        caller_to_randomizer_is = caller_to_randomizer_is_D0;
        N1_get_new_random_values_flag = 1;

    end else if (lagger_D0_bite == 3) begin
        // random numbers are ready now

        for (i = 0; i < dv_per_solution; i = i + 1) begin
            x_new[i] = (mp[i] >> (q_half - bits_per_dv)) & ((2 << (bits_per_dv-1)) - 1);
        end



    end else if (lagger_D0_bite == 4) begin
        if (verbose) $display("D0: the new random solution: x_new[0]:%f (%b) x_new[1]:%f (%b)", sf_dv * x_new[0], x_new[0], sf_dv * x_new[1], x_new[1]);
        if (verbose) $display("D0: storing new random solution(as new solution) with U4..");


        // store new `sol` as new solution in buffer memory
        address_to_write_solution_value_on_U4 = bma_new_sol;

        for (i = 0; i < dv_per_solution; i = i + 1) begin
            solution_value_to_write_on_memory_U4[i] = x_new[i];
        end

        D0_initialize_archive_flag = 0;
        // setting and launching U4
        counter_U4_bite = 0;
        lagger_U4_bite  = 0;
        caller_to_U4 = caller_to_U4_is_D0;
        U4_write_solution_on_main_memory_flag = 1;
 

    end else if (lagger_D0_bite == 5) begin

        if (iteration < archive_size) begin

            if (verbose) $display("D0: storing new random solution in archive with U4..");
       
            // store new `sol` in archive
            address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * iteration;
            D0_initialize_archive_flag = 0;
            // setting and launching U4
            counter_U4_bite = 0;
            lagger_U4_bite  = 0;
            caller_to_U4 = caller_to_U4_is_D0;
            U4_write_solution_on_main_memory_flag = 1;
      
        end 
        

    end else if (lagger_D0_bite == 6) begin
        if (iteration < archive_size) begin
            if (verbose) $display("D0: finished storing new random solution.");
            if (verbose) $display("D0: updating CentParams..");


            D0_initialize_archive_flag = 0;
            // setting and launching D2
            lagger_D2_bite = 0;
            counter_D2_bite = 0;
            D2_update_cent_params_flag = 1;

        end



    end else if (lagger_D0_bite == 7) begin
        if (iteration < archive_size) begin

            if (verbose) $display("D0:         CentParams[0]: %f",  sf * CentParams[0]);

        end



    end else if (lagger_D0_bite == 8) begin
        /*
            updating index_of_worst:
                while we are initializing, we simply compare the new f with the worst known
                after than, if the new solution is not worse than the worst, we overwrite 
                the worst with the new solution. and then we sort the archive.
                then the index of the worst automatticallly becomes the last solution in the archive.

        */
        if (iteration < archive_size) begin
            // $display("D0: updating the index_of_worst.");

            if (iteration == 0) begin
                index_of_worst = 0;
            
            end else begin
                // $display("D0: reading the worst `f`.");

                address_to_read_f_value_from_U1 = bma_f_archive + index_of_worst * bytes_per_f;

                D0_initialize_archive_flag = 0;
                // setting and launching U1
                counter_U1_bite = 0;
                lagger_U1_bite  = 0;
                caller_to_U1 = caller_to_U1_is_D0;
                U1_read_f_on_main_memory_flag = 1;

            end

        end


    end else if (lagger_D0_bite == 9) begin
        // updating index_of_worst:
        if (iteration < archive_size) begin

            if (iteration > 0) begin

                // $display("D0:                   comparing f_bitstream: %f with f_value_read_from_memory_U1:%f", sf_f * f_bitstream, sf_f * f_value_read_from_memory_U1);

                if (f_bitstream > f_value_read_from_memory_U1) begin

                    index_of_worst = iteration - 1;
                    if (verbose) $display("D0:                   index_of_worst updated to: %d", index_of_worst);

                end

            end

        end


    end else if (lagger_D0_bite == 10) begin

        for (i = 0; i < dv_per_solution; i = i + 1) begin
            sol_most_recent[i] = x_new[i];
        end

    end else if (lagger_D0_bite == 11) begin


        if (verbose) $display("D0: incrementing iteration.");

        iteration = iteration + 1;


        D0_initialize_archive_flag = 0;

        sol_ready_flag = 1;




        lagger_D0_bite = 0;
    
    end 
end
end






















// D2

// flag
reg                                                     D2_update_cent_params_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D2_bite;
reg                 [q_full - 1 : 0]                    lagger_D2_bite;

// D2 variables


//D2_update_cent_params_flag
always @(negedge clk_bite) begin
if (D2_update_cent_params_flag == 1) begin
    lagger_D2_bite = lagger_D2_bite + 1;

    if (lagger_D2_bite == 1) begin
        

        // $display("%b, %b, %b",
        // CentParams[counter_D2_bite] ,
        // mp[counter_D2_bite],
        // toolkit.mult( mp[counter_D2_bite] , inv_archive_size_minus_one)
        // );

        CentParams[counter_D2_bite] = CentParams[counter_D2_bite] +  toolkit.mult( mp[counter_D2_bite] , inv_N_1) ;


    end else if (lagger_D2_bite == 2) begin

        if (counter_D2_bite < dv_per_solution - 1) begin
            counter_D2_bite = counter_D2_bite + 1;

        end else begin
            
            D2_update_cent_params_flag = 0;
            
            D0_initialize_archive_flag = 1;

        end

        lagger_D2_bite = 0;
    
    end 
end
end































// 14_F_update
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------



// F1

// flag
reg                                                     F1_update_archive_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F1_bite;
reg                 [q_full - 1 : 0]                    lagger_F1_bite;

// F1 variables


//F1_update_archive_flag
always @(negedge clk_bite) begin
if (F1_update_archive_flag == 1) begin
    lagger_F1_bite = lagger_F1_bite + 1;

    if (lagger_F1_bite == 1) begin
        // read the worst f 

        
        address_to_read_f_value_from_U1 = bma_f_archive + index_of_worst * bytes_per_f;

        F1_update_archive_flag = 0;
        // setting and launching U1
        counter_U1_bite = 0;
        lagger_U1_bite  = 0;
        caller_to_U1 = caller_to_U1_is_F1;
        U1_read_f_on_main_memory_flag = 1;
        

    end else if (lagger_F1_bite == 2) begin
        
        worst_f = f_value_read_from_memory_U1;


    end else if (lagger_F1_bite == 3) begin
        // read the worst solution

        address_to_read_solution_value_from_U0 = bma_sol_archive + index_of_worst * bytes_per_solution;


        F1_update_archive_flag = 0;
        // setting and launching U0
        counter_U0_bite = 0;
        lagger_U0_bite  = 0;
        caller_to_U0 = caller_to_U0_is_F1;
        U0_read_solution_on_main_memory_flag = 1;


    end else if (lagger_F1_bite == 4) begin

        for (i = 0; i < dv_per_solution ; i = i + 1) begin
            worst_sol[i] = solution_value_read_from_memory_U0[i];
        end


        if (verbose) $display("worst_idx: %d, worst_sol:%f, worst_f:%f", index_of_worst, sf_dv * worst_sol[0], sf_f * worst_f);



    end else if (lagger_F1_bite == 5) begin

        
        if (f_bitstream >= worst_f) begin
            
            if (RaiseFlags != 0) begin
                RandSwitch = 0;
            end else begin
                RandSwitch = RandSwitch | 1;
            end

        end else begin

            RandSwitch = RandSwitch | RaiseFlags;

        end

    end else if (lagger_F1_bite == 6) begin

        if (f_bitstream < worst_f) begin

            F1_update_archive_flag = 0;
            // setting and launching F2
            lagger_F2_bite  = 0;
            counter_F2_bite = 0;
            F2_update_CentParams_flag = 1;


        end

    end else if (lagger_F1_bite == 7) begin
        if (f_bitstream < worst_f) begin

            if (verbose) $display("F1:         CentParams[0]: %f",  sf * CentParams[0]);
        
        end



    end else if (lagger_F1_bite == 8) begin
        /*
        here we overwrite the worst solution with the new solution
        sol_mem[index_of_worst] = sol_bitstream;
        */

        if (f_bitstream < worst_f) begin
            if (verbose) $display("F1:         overwrite the worst solution");

            for (i = 0; i < dv_per_solution ; i = i + 1) begin
                solution_value_to_write_on_memory_U4[i] = sol_most_recent[i];
            end

            address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * index_of_worst;

            F1_update_archive_flag = 0;
            // setting and launching U4
            counter_U4_bite = 0;
            lagger_U4_bite  = 0;
            caller_to_U4 = caller_to_U4_is_F1;
            U4_write_solution_on_main_memory_flag = 1;
        
        end


    end else if (lagger_F1_bite == 9) begin
        /*
        here we overwrite the worst solution with the new solution
        f_mem[index_of_worst] = f_bitstream;

        */


        if (f_bitstream < worst_f) begin
            if (verbose) $display("F1:         overwrite the worst f");


            f_value_to_write_on_memory_U3 = f_bitstream;
            address_to_write_f_value_on_U3 = bma_f_archive + index_of_worst * bytes_per_f;

            F1_update_archive_flag = 0;
            // setting and launching U3
            counter_U3_bite = 0;
            lagger_U3_bite  = 0;
            caller_to_U3 = caller_to_U3_is_F1;
            U3_write_f_on_main_memory_flag = 1;
        
        end


    end else if (lagger_F1_bite == 10) begin
        // sort the archive only if the new f replaced the worst f
        // if the new f was rejected, then we do not need to sort the archive
        if (f_bitstream < worst_f) begin
            if (verbose) $display("F1:         starting the sorter..");


            // for (i = 0; i < archive_size ; i = i + 1) begin
            //     archive_arg_sort[i] = i;
            // end

            F1_update_archive_flag = 0;
            // setting and launching SORTER
            counter_H1          = 0;
            read_lagger_H1      = 0;
            write_lagger_H1     = 0;
            sorter_bump_flag_H1 = 0;
            sorter_stage_H1     = sorter_stage_looping_H1;

            H1_sort_archive_flag = 1;

        end


    end else if (lagger_F1_bite == 11) begin


        if (verbose) $display("F1: incrementing iteration.");

        iteration = iteration + 1;


    end else if (lagger_F1_bite == 12) begin
        if (verbose) $display("F1: starting mutation.");

        F1_update_archive_flag = 0;
        // setting and launching J1
        lagger_J1_bite = 0;
        J1_mutation_flag = 1;           

    end else if (lagger_F1_bite == 13) begin

        F1_update_archive_flag = 0;

        lagger_F1_bite = 0;
    
    end 
end
end





















// F2

// flag
reg                                                     F2_update_CentParams_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F2_bite;
reg                 [q_full - 1 : 0]                    lagger_F2_bite;

// F2 variables
reg                 [q_full - 1 : 0]                    CentParams_tmp;

//F2_update_CentParams_flag
always @(negedge clk_bite) begin
if (F2_update_CentParams_flag == 1) begin
    lagger_F2_bite = lagger_F2_bite + 1;


    if (lagger_F2_bite == 1) begin

        CentParams_tmp =                    sol_most_recent[counter_F2_bite] << (q_half - bits_per_dv);

        // $display("sol_most_recent:%b    CentParams_tmp:%b", sol_most_recent[counter_F2_bite], CentParams_tmp);

        CentParams_tmp = CentParams_tmp -   (worst_sol      [counter_F2_bite] << (q_half - bits_per_dv));
        
        // $display("worst_sol:%b    CentParams_tmp:%b", worst_sol[counter_F2_bite], CentParams_tmp);



        CentParams[counter_F2_bite] = CentParams[counter_F2_bite] +  toolkit.mult(CentParams_tmp , PopSizeI) ;
        if (verbose) $display("F2:                                                     PopSizeI:%f                  CentParams[counter_F2_bite]:%f", sf*PopSizeI, sf * CentParams[counter_F2_bite]);


    end else if (lagger_F2_bite == 2) begin

        if (counter_F2_bite < dv_per_solution - 1) begin
            counter_F2_bite = counter_F2_bite + 1;

        end else begin
            
            F2_update_CentParams_flag = 0;
            
            F1_update_archive_flag = 1;

        end

        lagger_F2_bite = 0;
    
    end 
end
end
























// 16_H_sorter
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------


localparam                                              sorter_verbose = 0;                                                     


// H1

// flag
reg                                                     H1_sort_archive_flag   = 0;


//loop reset to zero
reg                 [q_full - 1 : 0]                    counter_H1;
reg                 [q_full - 1 : 0]                    read_lagger_H1;
reg                 [q_full - 1 : 0]                    write_lagger_H1;
reg                                                     sorter_bump_flag_H1;
reg                                                     sorter_stage_H1; // reset to sorter_stage_looping_H1


// no reset needed

reg signed          [f_bitstream_len - 1 : 0]           sorter_f_v_1;
reg signed          [f_bitstream_len - 1 : 0]           sorter_f_v_2;


reg                 [bits_per_dv - 1 : 0]               sorter_sol_v_1      [dv_per_solution - 1 : 0];
reg                 [bits_per_dv - 1 : 0]               sorter_sol_v_2      [dv_per_solution - 1 : 0];


// Stages
localparam          sorter_stage_looping_H1         = 0;
localparam          sorter_stage_swapping_H1        = 1;



// reg                 [8 - 1 :  0]                        archive_arg_sort    [archive_size - 1   : 0];
// reg                 [8 - 1 :  0]                        archive_arg_sort_tmp;




// H1_sort_archive_flag
always @(negedge clk_bite) begin

    if (H1_sort_archive_flag == 1) begin



        if (sorter_stage_H1 == sorter_stage_looping_H1) begin
            read_lagger_H1 = read_lagger_H1 + 1;


















            // read first sol and f


            if (read_lagger_H1 == 1) begin
                // f_mem_read_addr     =   sorter_counter;    

                address_to_read_f_value_from_U1 = bma_f_archive + bytes_per_f * counter_H1;


                H1_sort_archive_flag = 0;
                // setting and launching U1
                counter_U1_bite = 0;
                lagger_U1_bite  = 0;
                caller_to_U1 = caller_to_U1_is_H1;
                U1_read_f_on_main_memory_flag = 1;
                
                if (sorter_verbose) $display("`         sorter: looping, reading f_1");

            end else if (read_lagger_H1 == 2) begin
                // sol_mem_read_addr   =   sorter_counter;    

                address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * counter_H1;

                H1_sort_archive_flag = 0;
                // setting and launching U0
                lagger_U0_bite  = 0;
                counter_U0_bite = 0;
                caller_to_U0 = caller_to_U0_is_H1;
                U0_read_solution_on_main_memory_flag = 1;

                if (sorter_verbose) $display("`         sorter: looping, reading sol_1");


            end else if (read_lagger_H1 == 3) begin
                sorter_f_v_1        =     f_value_read_from_memory_U1;


            end else if (read_lagger_H1 == 4) begin

                for (i = 0; i < dv_per_solution ; i = i + 1) begin
                    
                    sorter_sol_v_1[i] = solution_value_read_from_memory_U0[i];
                    
                end











            // read second sol and f


            end else if (read_lagger_H1 == 5) begin

                // f_mem_read_addr     =   sorter_counter + 1;    

                address_to_read_f_value_from_U1 = bma_f_archive + bytes_per_f * (counter_H1 + 1);


                H1_sort_archive_flag = 0;
                // setting and launching U1
                counter_U1_bite = 0;
                lagger_U1_bite  = 0;
                caller_to_U1 = caller_to_U1_is_H1;
                U1_read_f_on_main_memory_flag = 1;
                
                if (sorter_verbose) $display("`         sorter: looping, reading f_2");

            end else if (read_lagger_H1 == 6) begin
                // sol_mem_read_addr   =   sorter_counter + 1;    

                address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * (counter_H1 + 1);

                H1_sort_archive_flag = 0;
                // setting and launching U0
                lagger_U0_bite  = 0;
                counter_U0_bite = 0;
                caller_to_U0 = caller_to_U0_is_H1;
                U0_read_solution_on_main_memory_flag = 1;

                if (sorter_verbose) $display("`         sorter: looping, reading sol_2");


            end else if (read_lagger_H1 == 7) begin
                sorter_f_v_2        =     f_value_read_from_memory_U1;


            end else if (read_lagger_H1 == 8) begin

                for (i = 0; i < dv_per_solution ; i = i + 1) begin
                    
                    sorter_sol_v_2[i] = solution_value_read_from_memory_U0[i];
                    
                end




























                

            end else if (read_lagger_H1 == 9) begin
                /*
                    at this point we have both values
                    make the comparision
                    if nessacary, we swap the values
                */


                if (sorter_f_v_1 > sorter_f_v_2) begin
                    if (sorter_verbose) $display("`         sorter: bump");

                    sorter_bump_flag_H1 = 1;
                    sorter_stage_H1= sorter_stage_swapping_H1;
                end 
                
                read_lagger_H1 = 0;

                if (counter_H1 < archive_size - 2) begin
                    counter_H1 = counter_H1 + 1;

                end else begin

                    counter_H1 = 0;

                    if (sorter_bump_flag_H1 == 0) begin
                        H1_sort_archive_flag = 0;
                        if (verbose) $display("H1: SORTING FINISHED, time:%d", $time);

                        // going back to UPDATE
                        F1_update_archive_flag = 1;

                        
                        // $write("arg_sor = [");
                        // for (i = 0; i < archive_size ; i = i + 1) begin
                        //     $write("%d", archive_arg_sort[i]);
                        //     if (i < archive_size - 1) $write(", ");
                        // end
                        // $write("]");


                        // dumping the archive

                        // lagger_U10_bite = 0;
                        // counter_U10_bite = 0;
                        // U10_dump_main_memory_flag = 1;

                    end
                    sorter_bump_flag_H1 = 0;

                end

            end
























        end else if (sorter_stage_H1 == sorter_stage_swapping_H1) begin

            write_lagger_H1 = write_lagger_H1 + 1;











            if (write_lagger_H1 == 1) begin
                if (counter_H1 == 0) begin
                        // f_mem_write_addr    =   archive_size - 2;
                        address_to_write_f_value_on_U3  = bma_f_archive + bytes_per_f * (archive_size - 2);
                end else begin
                        // f_mem_write_addr    =   sorter_counter - 1;
                        address_to_write_f_value_on_U3  = bma_f_archive + bytes_per_f * (counter_H1 - 1);

                    
                end


            end else if (write_lagger_H1 == 2) begin
                if (counter_H1 == 0) begin
                        // sol_mem_write_addr  =   archive_size - 2;
                        address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * (archive_size - 2);

                end else begin
                        // sol_mem_write_addr  =   sorter_counter - 1;
                        address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * (counter_H1 - 1);
                end










            end else if (write_lagger_H1 == 3) begin
                // f_mem_write_data    = sorter_f_v_2;                
                f_value_to_write_on_memory_U3 = sorter_f_v_2;


                H1_sort_archive_flag = 0;
                // setting and launching U3
                lagger_U3_bite = 0;
                counter_U3_bite = 0;
                caller_to_U3 = caller_to_U3_is_H1;
                U3_write_f_on_main_memory_flag = 1;


            end else if (write_lagger_H1 == 4) begin
                // sol_mem_write_data  = sorter_sol_v_2;                

                for (i = 0; i < dv_per_solution ; i = i + 1) begin
                    solution_value_to_write_on_memory_U4[i] = sorter_sol_v_2[i];
                end

                H1_sort_archive_flag = 0;
                // setting and launching U4
                lagger_U4_bite = 0;
                counter_U4_bite = 0;
                caller_to_U4 = caller_to_U4_is_H1;
                U4_write_solution_on_main_memory_flag = 1;














            end else if (write_lagger_H1 == 5) begin
                if (counter_H1 == 0) begin
                        // f_mem_write_addr    =   archive_size - 1;
                        address_to_write_f_value_on_U3  = bma_f_archive + bytes_per_f * (archive_size - 1);
                end else begin
                        // f_mem_write_addr    =   sorter_counter;
                        address_to_write_f_value_on_U3  = bma_f_archive + bytes_per_f * (counter_H1);
                end


            end else if (write_lagger_H1 == 6) begin
                if (counter_H1 == 0) begin
                        // sol_mem_write_addr  =   archive_size - 1;
                        address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * (archive_size - 1);

                end else begin
                        // sol_mem_write_addr  =   sorter_counter;
                        address_to_write_solution_value_on_U4 = bma_sol_archive + bytes_per_solution * (counter_H1);
                end







            end else if (write_lagger_H1 == 7) begin
                // f_mem_write_data    = sorter_f_v_1;
                f_value_to_write_on_memory_U3 = sorter_f_v_1;


                H1_sort_archive_flag = 0;
                // setting and launching U3
                lagger_U3_bite = 0;
                counter_U3_bite = 0;
                caller_to_U3 = caller_to_U3_is_H1;
                U3_write_f_on_main_memory_flag = 1;


            end else if (write_lagger_H1 == 8) begin
                // sol_mem_write_data  = sorter_sol_v_1;

                for (i = 0; i < dv_per_solution ; i = i + 1) begin
                    solution_value_to_write_on_memory_U4[i] = sorter_sol_v_1[i];
                end

                H1_sort_archive_flag = 0;
                // setting and launching U4
                lagger_U4_bite = 0;
                counter_U4_bite = 0;
                caller_to_U4 = caller_to_U4_is_H1;
                U4_write_solution_on_main_memory_flag = 1;





            // end else if (write_lagger_H1 == 9) begin
            //     /*
            //         we are here because
            //             f[counter_H1] > f[counter_H1 + 1]
            //             their corresponding arg_values need to be swaped
            //     */


            //     archive_arg_sort_tmp = archive_arg_sort[counter_H1];
            //     archive_arg_sort[counter_H1] = archive_arg_sort[counter_H1 + 1];
            //     archive_arg_sort[counter_H1 + 1] = archive_arg_sort_tmp;






            end else if (write_lagger_H1 == 10) begin
                write_lagger_H1 = 0;
                sorter_stage_H1= sorter_stage_looping_H1;
            end

        end
    end

end






























// 18_J_mutation
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------



localparam      mutation_verbose = 0;

    // Constant values, hard coded
    reg signed [q_full - 1 : 0]  RandProb_1  =   128'sb0000000000000000000000000000000000000000000000000000000000000000_0110011010100010000111000100101000001101100101010100000000000000;   //  0.40091111
    reg signed [q_full - 1 : 0]  RandProb_2 =    128'sb0000000000000000000000000000000000000000000000000000000000000000_1111111011110001101100011101111010001001111000111001100000000000;   //  0.99587547
    reg signed [q_full - 1 : 0]  RandProb2_1 =   128'sb0000000000000000000000000000000000000000000000000000000000000000_0100010000101011000011010100100111101010100001001100010000000000;   //  0.26628192
    reg signed [q_full - 1 : 0]  RandProb2_2 =   128'sb0000000000000000000000000000000000000000000000000000000000000000_1000001000111010000010011110011100001001100011101111100000000000;   //  0.5086981
    reg signed [q_full - 1 : 0]  AllpProb_1 =    128'sb0000000000000000000000000000000000000000000000000000000000000000_1001010001001011100101000010100000010101100111011101000000000000;   //  0.57927824
    reg signed [q_full - 1 : 0]  AllpProb_2 =    128'sb0000000000000000000000000000000000000000000000000000000000000000_1111110110011111010100100110101100110001110100100011100000000000;   //  0.99071231
    reg signed [q_full - 1 : 0]  CentProb_1 =    128'sb0000000000000000000000000000000000000000000000000000000000000000_1111111011110001110000100010010010101000001010110000000000000000;   //  0.99587644
    reg signed [q_full - 1 : 0]  CentProb_2 =    128'sb0000000000000000000000000000000000000000000000000000000000000000_0010010100010011001000001100010000011010110011001000101000000000;   //  0.14482312
    reg signed [q_full - 1 : 0]  ScutProb =      128'sb0000000000000000000000000000000000000000000000000000000000000000_0000111101011100001010001111010111000010100011110101110000000000;   //  0.06
    reg signed [q_full - 1 : 0]  MantSizeSh =    128'sb0000000000000000000000000000000000000000000000000000000000100110_1010000001000001000010110110001100001010100100100000000000000000;   //  38.6259925
    reg signed [q_full - 1 : 0]  MantSizeSh2 =   128'sb0000000000000000000000000000000000000000000000000000000001010011_1111111011100011010000101000010100001010110000000000000000000000;   //  83.99565521
    reg signed [q_full - 1 : 0]  PopSizeBase =   128'sb0000000000000000000000000000000000000000000000000000000000001011_0000011010110000001010000010011001100100110000111000000000000000;   //  11.02612544
    reg signed [q_full - 1 : 0]  PopSizeMult =   128'sb0000000000000000000000000000000000000000000000000000000000000001_1110110111011000111111111000101100010000000100111111000000000000;   //  1.92909238

    reg signed [q_full - 1 : 0]  CentSpanRnd_0 = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000101000101000100100111111100110011100;   //  2.3652119375765323e-09
    reg signed [q_full - 1 : 0]  CentSpanRnd_1 = 128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000010001010111011110000001101011000011;   //  1.0108753107488155e-09



    // Dependent constants - values are initiated based on random numbers and the dimension but stay unchanged over the trial
    reg signed [q_full - 1 : 0]  ParamCountRnd;
    reg signed [q_full - 1 : 0]  AllpProbDamp;
    
    
    // Variables initiated randomly and then updated during optimization iterations 
    reg signed [q_full - 1 : 0]  RandCntr;
    reg signed [q_full - 1 : 0]  RandCntr2;
    reg signed [q_full - 1 : 0]  AllpCntr;
    reg signed [q_full - 1 : 0]  CentCntr;
    reg [8 - 1  : 0] ParamCntr       ;
    reg [8 - 1  : 0] RandSwitch      ;
    

    // Bitmask constants
    reg signed [q_full - 1 : 0]  MantSizeMask =  128'sb0000000000111111111111111111111111111111111111111111111111111111_0000000000000000000000000000000000000000000000000000000000000000;   // 18014398509481983
    reg signed [q_full - 1 : 0]  MantMult     =  128'sb0000000001000000000000000000000000000000000000000000000000000000_0000000000000000000000000000000000000000000000000000000000000000;   // 18014398509481984
    reg signed [q_full - 1 : 0]  MantMultI    =  128'sb0000000000000000000000000000000000000000000000000000000000000000_0000000000000000000000000000000000000000000000000000010000000000;   //  5.551115123125783e-17


    // Integer variables
    reg [8 - 1  : 0] RaiseFlags      ;
    reg [8 - 1  : 0] ci              ;



    reg signed    [q_full - 1 : 0]     neg_one      = -128'sb0000000000000000000000000000000000000000000000000000000000000001_0000000000000000000000000000000000000000000000000000000000000000;   //  -1
    reg signed    [q_full - 1 : 0]     two          =  128'sb0000000000000000000000000000000000000000000000000000000000000010_0000000000000000000000000000000000000000000000000000000000000000;   //  2
    reg signed    [q_full - 1 : 0]     point5       = 128'sb01 << (q_half-1);
    reg signed    [q_full - 1 : 0]     one          = 128'sb01 << (q_half);


    reg signed    [q_full - 1 : 0]     rnd_mult     = 128'sb0000000000000000000000000000000001000000000000000000000000000000_0000000000000000000000000000000000000000000000000000000000000000;   //  1073741824





    // Mutation variables
    // q_full Solutions
    reg signed [q_full - 1 : 0] CentParams      [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] MinParams       [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] rp0             [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] rp1             [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] rp2             [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] OrigParams      [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] MaxParams       [dv_per_solution - 1 : 0];
    reg signed [q_full - 1 : 0] x_new_full_q    [dv_per_solution - 1 : 0];


    // Integers
    reg [address_len - 1 : 0] si;
    reg [address_len - 1 : 0] si2;
    reg [address_len - 1 : 0] si3;
    reg [address_len - 1 : 0] si4;
    reg [address_len - 1 : 0] a;
    reg [address_len - 1 : 0] b;

    // Large Integers
    reg signed [q_full - 1 : 0] imask;
    reg signed [q_full - 1 : 0] imask2;
    reg signed [q_full - 1 : 0] mask_shift;
    reg signed [q_full - 1 : 0] v0;
    reg signed [q_full - 1 : 0] v1;
    reg signed [q_full - 1 : 0] v2;

    // Decimal
    reg signed [q_full - 1 : 0] m1;
    reg signed [q_full - 1 : 0] m2;

    

    // masks
    localparam  [q_full - 1 : 0]    q_full_integer_mask = ((2 << (q_half-1))-1) << q_half;


// J1

// flag
reg                                                     J1_mutation_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_J1_bite;

// J1 variables


//J1_mutation_flag
always @(negedge clk_bite) begin
if (J1_mutation_flag == 1) begin
    lagger_J1_bite = lagger_J1_bite + 1;

    if (lagger_J1_bite == 1) begin
        if (verbose) $display("J1: generating new random numbers");
        

        J1_mutation_flag = 0;
        // setting and launching Randomizer
        counter_N1_bite = 0;
        lagger_N1_bite  = 0;
        caller_to_randomizer_is = caller_to_randomizer_is_J1;
        N1_get_new_random_values_flag = 1;

        

    end else if (lagger_J1_bite == 2) begin
        index_of_worst = archive_size - 1;
        



    end else if (lagger_J1_bite == 3) begin
        
        address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * mpi[0];

        J1_mutation_flag = 0;
        // setting and launching U0
        lagger_U0_bite  = 0;
        counter_U0_bite = 0;
        caller_to_U0 = caller_to_U0_is_J1;
        U0_read_solution_on_main_memory_flag = 1;


    end else if (lagger_J1_bite == 4) begin

        if(mutation_verbose ==2) $display("mutating-------------------------mpi[0]: %d", mpi[0]);

        for (i = 0; i < dv_per_solution ; i = i + 1 ) begin
            MinParams[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! MinParams is signed. mem read are not.
            if(mutation_verbose ==2) $display("mutating-------------------------MinParams[%d]: %f", i,  sf * MinParams[i]);

        end


    end else if (lagger_J1_bite == 5) begin

        // Which RandSwitch flags to raise on optimization improvement.
        RaiseFlags = 0;

        // RandCntr = RandCntr + RandProb[RandSwitch & 1];
        if ((RandSwitch & 1) == 0) begin 
            RandCntr = RandCntr + RandProb_1;
        end else if ((RandSwitch & 1) == 1) begin
            RandCntr = RandCntr + RandProb_2;
        end else begin
            $display("!!!!!!!!!! ERRORR 594");
        end

        if(mutation_verbose > 0) $display("mutating-figuring out the path, RandCntr=: %f", sf * RandCntr);

    end else if (lagger_J1_bite == 6) begin

        for (i = 0; i < dv_per_solution; i = i + 1) begin
            x_new_full_q[i] = 0;
        end

        // if(mutation_verbose ==2) $display("mutating-------------------------RandCntr=%d", sf * RandCntr);
        // if(mutation_verbose ==2) $display("mutating-------------------------RandCntr=%b",  RandCntr);
        // if(mutation_verbose ==2) $display("mutating-------------------------RandCntr=%b",  one);


    /*
        Mutation
    */
    end else if (lagger_J1_bite == 7) begin
        if (RandCntr >= one) begin

            if(mutation_verbose >0) $display("mutating--A----------------------RandCntr=%f >= one=%f", sf * RandCntr, sf*one);
            
            RaiseFlags = RaiseFlags | 1'b1;

            // RandCntr = RandCntr - one;

        end

    end else if (lagger_J1_bite == 8) begin
        if (RandCntr >= one) begin

                // RandCntr2 += RandProb2[(RandSwitch >> 1) & 1]

                if(mutation_verbose ==2) $display("mutating-------------------------RandSwitch=%d because (RandSwitch >> 1) & 1'b1=%d", RandSwitch, (RandSwitch >> 1) & 1'b1);

                if (((RandSwitch >> 1) & 1'b1) == 0) begin
                    RandCntr2 = RandCntr2 + RandProb2_1;

                end else if (((RandSwitch >> 1) & 1'b1) == 1) begin
                    RandCntr2 = RandCntr2 + RandProb2_2;

                end else begin
                    $display("!!!!!!!!! ERRORR 622");
                end

        end




    end else if (lagger_J1_bite == 9) begin
        if (RandCntr >= one) begin
                if (RandCntr2 >= one) begin

                    if(mutation_verbose >0) $display("mutating--A1---------------------RandCntr2=%f >= one=%f", sf * RandCntr2, sf*one);
                    /*
                        in A1, we use mp2_1
                        then we need one new mp per dv
                            if dv is one, we are going to only need
                                mp_2
                    */
                    if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d , RandCntr2=%f", RaiseFlags, sf*RandCntr2);

                    RaiseFlags = RaiseFlags | 2'd2;
                    // RandCntr2 = RandCntr2 - one;

                    if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d , RandCntr2=%f", RaiseFlags, sf*RandCntr2);


                    si = toolkit.mult(mp2[0] , N) >> q_half;
                    if(mutation_verbose ==2) $display("mutating-------------------------si=%d", si);

                    // memory read

                    address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * si;

                    J1_mutation_flag = 0;
                    // setting and launching U0
                    lagger_U0_bite  = 0;
                    counter_U0_bite = 0;
                    caller_to_U0 = caller_to_U0_is_J1;
                    U0_read_solution_on_main_memory_flag = 1;

                end
        end





    end else if (lagger_J1_bite == 10) begin
        if (RandCntr >= one) begin
            if (RandCntr2 >= one) begin


                // memory read
                for (i = 0; i < dv_per_solution; i = i + 1) begin
                    rp1[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
                end

                if(mutation_verbose ==2) $display("mutating-------------------------rp1[0]=%f , N =%f , si=%d", sf*rp1[0], sf*N, si);


                J1_mutation_flag = 0;
                // setting and launching J3
                lagger_J3_bite = 0;
                counter_J3_bite = 0;
                J3_path_A1_loop_flag = 1;


            end
        end



    end else if (lagger_J1_bite == 11) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin
                /*
                    in A2, we use mp_1 and mp2[0] for the first mask
                    then we need one new mp for the second mask
                */
                if(mutation_verbose >0) $display("mutating--A2---------------------RandCntr2=%f < one=%f", sf * RandCntr2, sf*one);


                for (i = 0; i < dv_per_solution; i = i + 1) begin
                    x_new_full_q[i] = MinParams[i];
                end


                if(mutation_verbose ==2) $display("mutating-------------------------RandSwitch=%d , RandSwitch >> 2=%d, (RandSwitch >> 2) & 1'b1=%d", RandSwitch, RandSwitch >> 2, (RandSwitch >> 2) & 1'b1);

                if(mutation_verbose ==2) $display("mutating-------------------------AllpCntr=%f", sf*AllpCntr);



            end
        end



    end else if (lagger_J1_bite == 12) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin

                    if (            ((RandSwitch >> 2) & 1'b1) == 0) begin
                        AllpCntr = AllpCntr + toolkit.mult(AllpProb_1 , AllpProbDamp);

                        if(mutation_verbose ==2) $display("mutating-------------------------AllpCntr=%f , AllpProb_1=%f", sf*AllpCntr, sf*AllpProb_1);

                    end else if (   ((RandSwitch >> 2) & 1'b1) == 1) begin
                        AllpCntr = AllpCntr + toolkit.mult(AllpProb_2 , AllpProbDamp);

                        if(mutation_verbose ==2) $display("mutating-------------------------AllpCntr=%f , AllpProb_2=%f", sf*AllpCntr, sf*AllpProb_2);

                    end else begin
                        if(mutation_verbose ==2) $display("!!!!!!!!! ERRORR 643");
                    end


            end
        end


    end else if (lagger_J1_bite == 13) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin

                if(mutation_verbose ==2) $display("mutating-------------------------ParamCntr=%d", ParamCntr);

                if (AllpCntr >= one) begin // 289
                    if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d", RaiseFlags);

                    RaiseFlags = RaiseFlags | 8'd4;
                    if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d", RaiseFlags);

                    AllpCntr = AllpCntr - one;
                    if(mutation_verbose ==2) $display("mutating-------------------------AllpCntr=%f", sf*AllpCntr);

                    a = 0;
                    b = num_dec - 1;

                end else begin
                    a = ParamCntr;
                    b = ParamCntr;

                    if (ParamCntr == 0) begin
                        ParamCntr = num_dec - 1'b1;
                    end else begin
                        ParamCntr = ParamCntr - 1'b1;
                    end
                    if(mutation_verbose ==2) $display("mutating-----------------------------------------------------------------------------------AllpCntr<1");

                end
                if(mutation_verbose ==2) $display("mutating-------------------------a=%d, b=%d", a,b);
                if(mutation_verbose ==2) $display("mutating-------------------------ParamCntr=%d", ParamCntr);



            end
        end

    end else if (lagger_J1_bite == 14) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin


                imask =  (MantSizeMask >> (toolkit.mult(mp4[0] , MantSizeSh ) >> q_half)& q_full_integer_mask) & q_full_integer_mask;

                imask2 = (MantSizeMask >> (toolkit.mult(mp2[1] , MantSizeSh2) >> q_half)& q_full_integer_mask) & q_full_integer_mask;

                if(mutation_verbose ==2) $display("mutating-------------------------imask =%f ",sf*imask);
                if(mutation_verbose ==2) $display("mutating-------------------------imask2=%f", sf*imask2);
                // if(mutation_verbose ==2) $display("mutating-------------------------mp2:%f, ", sf*mp2[1]);
                // if(mutation_verbose ==2) $display("mutating-------------------------toolkit.mult(mp2[1] , MantSizeSh2)=%b", toolkit.mult(mp2[1] , MantSizeSh2) );
                // if(mutation_verbose ==2) $display("mutating-------------------------toolkit.mult(mp2[1] , MantSizeSh2) >> q_half)=%d", toolkit.mult(mp2[1] , MantSizeSh2) >> q_half);
                // if(mutation_verbose ==2) $display("mutating-------------------------MantSizeMask=%b", MantSizeMask);
                // if(mutation_verbose ==2) $display("mutating-------------------------MantSizeMask >> (toolkit.mult(mp2[1] , MantSizeSh2) >> q_half)=%b", MantSizeMask >> (toolkit.mult(mp2[1] , MantSizeSh2) >> q_half));


                si = toolkit.mult(mp3[0] , N) >> q_half;

                if(mutation_verbose ==2) $display("mutating-------------------------si=%d", si);

                // memory read
                address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * si;

                J1_mutation_flag = 0;
                // setting and launching U0
                lagger_U0_bite  = 0;
                counter_U0_bite = 0;
                caller_to_U0 = caller_to_U0_is_J1;
                U0_read_solution_on_main_memory_flag = 1;



            end
        end




    end else if (lagger_J1_bite == 15) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin

                // memory read
                for (i = 0; i < dv_per_solution; i = i + 1) begin
                    rp0[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
                end
                if(mutation_verbose ==2) $display("mutating-------------------------rp0[0]=%f", sf*rp0[0]);

            end
        end



    end else if (lagger_J1_bite == 16) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin

                J1_mutation_flag = 0;
                // setting and launching J4
                lagger_J4_bite = 0;
                counter_J4_bite = a;
                J4_first_ab_loop_flag = 1;

            end
        end




    end else if (lagger_J1_bite == 17) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin

                // 324
                ci = (RandSwitch >> 3) & 1'b1;
                if(mutation_verbose ==2) $display("mutating-------------------------ci=%d  RandSwitch=%d", ci, RandSwitch);

                if(mutation_verbose ==2) $display("mutating-------------------------CentCntr=%f", sf * CentCntr);

                if (ci == 0) begin
                    CentCntr = CentCntr + CentProb_1;
                end else if (ci == 1) begin
                    CentCntr = CentCntr + CentProb_2;
                end else begin
                    $display("ERRORRRRRRRRRRRRRRRRRRr 733");
                end
                if(mutation_verbose ==2) $display("mutating-------------------------CentCntr=%f", sf * CentCntr);

            end
        end


    end else if (lagger_J1_bite == 18) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin
                if (CentCntr >= one) begin
                        if(mutation_verbose >0) $display("mutating--A2sub------------------CentCntr >= 1");
                        
                        if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d", RaiseFlags);
                        RaiseFlags = RaiseFlags | 4'd8;
                        if(mutation_verbose ==2) $display("mutating-------------------------RaiseFlags=%d", RaiseFlags);

                        // Random move around random previous solution vector.

                        if(mutation_verbose ==2) $display("mutating-------------------------tpdf[0]=%f", sf * toolkit.mult(rnd_mult, tpdf[0]));
                        if(mutation_verbose ==2) $display("mutating-------------------------tpdf[1]=%f", sf * toolkit.mult(rnd_mult, tpdf[1]));
                        if(mutation_verbose ==2) $display("mutating-------------------------CentSpanRnd_0=%f", sf * CentSpanRnd_0);
                        if(mutation_verbose ==2) $display("mutating-------------------------CentSpanRnd_1=%f", sf * CentSpanRnd_1);

                end
            end
        end



    end else if (lagger_J1_bite == 19) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin
                if (CentCntr >= one) begin

                        if (ci == 0) begin
                            m1 =  toolkit.mult(toolkit.mult(rnd_mult, tpdf[0]) , CentSpanRnd_0);
                            m2 =  toolkit.mult(toolkit.mult(rnd_mult, tpdf[1]) , CentSpanRnd_0);

                        end else if (ci == 1) begin
                            m1 =  toolkit.mult(toolkit.mult(rnd_mult, tpdf[0]) , CentSpanRnd_1);
                            m2 =  toolkit.mult(toolkit.mult(rnd_mult, tpdf[1]) , CentSpanRnd_1);

                        end else begin
                            $display("ERRORRRRRRRRRRRRRRRRRRr 761");
                        end

                        if(mutation_verbose ==2) $display("mutating-------------------------m1=%f", sf * m1);
                        if(mutation_verbose ==2) $display("mutating-------------------------m2=%f", sf * m2);



                        si = toolkit.mult(mp2[0] , N) >> q_half;
                        if(mutation_verbose ==2) $display("mutating-------------------------si=%d = int(mp2[0]=%f * N=%f)", si, sf * mp2[0], sf * N);



                        // memory read
                        address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * si;

                        J1_mutation_flag = 0;
                        // setting and launching U0
                        lagger_U0_bite  = 0;
                        counter_U0_bite = 0;
                        caller_to_U0 = caller_to_U0_is_J1;
                        U0_read_solution_on_main_memory_flag = 1;




                end
            end
        end


    end else if (lagger_J1_bite == 20) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin
                if (CentCntr >= one) begin

                // memory read
                for (i = 0; i < dv_per_solution; i = i + 1) begin
                    rp1[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
                end
                if(mutation_verbose ==2) $display("mutating-------------------------rp1[0]=%f", sf * rp1[0]);


                end
            end
        end


    end else if (lagger_J1_bite == 21) begin
        if (RandCntr >= one) begin
            if (RandCntr2 < one) begin
                if (CentCntr >= one) begin

                    CentCntr = CentCntr - one;
                    if(mutation_verbose ==2) $display("mutating-------------------------CentCntr=%f", sf * CentCntr);

                    if(mutation_verbose ==2) $display("mutating-------------------------looping a=%d to b+1=%d", a,b+1);

                    J1_mutation_flag = 0;
                    // setting and launching J5
                    lagger_J5_bite = 0;
                    counter_J5_bite = a;
                    J5_second_ab_loop_flag = 1;


                end
            end
        end


    end else if (lagger_J1_bite == 22) begin
        if (RandCntr < one) begin
            // 343
            if(mutation_verbose >0) $display("mutating--B----------------------RandCntr(=%f) < one(%f)", sf * RandCntr, sf * one);

            if(mutation_verbose ==2) $display("mutating-------------------------mpi=%d", mpi[0]);
            if(mutation_verbose ==2) $display("mutating-------------------------mp[0]=%f", sf*mp[0]);
            if(mutation_verbose ==2) $display("mutating-------------------------PopSize1=%f", sf*PopSize1);

            si = mpi[0] + toolkit.mult(mp[0], (PopSize1 - (mpi[0] << q_half) )) >> q_half ;

            if(mutation_verbose ==2) $display("mutating-------------------------si= %d", si);


            // memory read 1
            address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * si;

            J1_mutation_flag = 0;
            // setting and launching U0
            lagger_U0_bite  = 0;
            counter_U0_bite = 0;
            caller_to_U0 = caller_to_U0_is_J1;
            U0_read_solution_on_main_memory_flag = 1;



        end


    end else if (lagger_J1_bite == 23) begin
        if (RandCntr < one) begin
            // memory read 1
            for (i = 0; i < dv_per_solution; i = i + 1) begin
                OrigParams[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
            end
                
            if(mutation_verbose ==2) $display("mutating-------------------------OrigParams[0]= %f", sf*OrigParams[0]);

        end

    end else if (lagger_J1_bite == 24) begin
        if (RandCntr < one) begin

            if(mutation_verbose ==2) $display("mutating-------------------------((PopSize1 >> q_half) - mpi[0])=%d", ((PopSize1 >> q_half) - mpi[0]) );


            // memory read 2
            address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * (((PopSize1 >> q_half) - mpi[0]));

            J1_mutation_flag = 0;
            // setting and launching U0
            lagger_U0_bite  = 0;
            counter_U0_bite = 0;
            caller_to_U0 = caller_to_U0_is_J1;
            U0_read_solution_on_main_memory_flag = 1;



        end

    end else if (lagger_J1_bite == 25) begin
        if (RandCntr < one) begin
            // memory read 2
            for (i = 0; i < dv_per_solution; i = i + 1) begin
                MaxParams[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
            end
              
            if(mutation_verbose ==2) $display("mutating-------------------------MaxParams[0]= %f", sf*MaxParams[0]);

        end

    end else if (lagger_J1_bite == 26) begin
        if (RandCntr < one) begin
            si2 = toolkit.mult(mp2[1] , N) >> q_half;
            if(mutation_verbose ==2) $display("mutating-------------------------si2= %d", si2);


            // memory read 3
            address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * si2;

            J1_mutation_flag = 0;
            // setting and launching U0
            lagger_U0_bite  = 0;
            counter_U0_bite = 0;
            caller_to_U0 = caller_to_U0_is_J1;
            U0_read_solution_on_main_memory_flag = 1;


        end

    end else if (lagger_J1_bite == 27) begin
        if (RandCntr < one) begin

            // memory read 3
            for (i = 0; i < dv_per_solution; i = i + 1) begin
                rp1[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
            end
            if(mutation_verbose ==2) $display("mutating-------------------------rp1[0]= %f", sf*rp1[0]);
              

        end

    end else if (lagger_J1_bite == 28) begin
        if (RandCntr < one) begin
            
            // memory read 4
            address_to_read_solution_value_from_U0 = bma_sol_archive + bytes_per_solution * ((PopSize1 >> q_half) - si2);

            if(mutation_verbose ==2) $display("mutating-------------------------((PopSize1 >> q_half) - si2)= %d", ((PopSize1 >> q_half) - si2));



            J1_mutation_flag = 0;
            // setting and launching U0
            lagger_U0_bite  = 0;
            counter_U0_bite = 0;
            caller_to_U0 = caller_to_U0_is_J1;
            U0_read_solution_on_main_memory_flag = 1;

        end

    end else if (lagger_J1_bite == 29) begin
        if (RandCntr < one) begin

            // memory read 4
            for (i = 0; i < dv_per_solution; i = i + 1) begin
                rp2[i] = solution_value_read_from_memory_U0[i] << (q_half - bits_per_dv); // !! rp1 is signed. mem read are not. we should be ok unless the sign bit gets involved
            end
              
              
            if(mutation_verbose ==2) $display("mutating-------------------------rp2[0]= %f", sf*rp2[0]);

        end

    end else if (lagger_J1_bite == 30) begin
        if (RandCntr < one) begin

            // x_new_full_q = MinParams - toolkit.mult(((MaxParams - OrigParams) - (rp1 - rp2)), point5);
            for (i = 0; i < dv_per_solution; i = i + 1) begin
                x_new_full_q[i] = MinParams[i] - toolkit.mult(((MaxParams[i] - OrigParams[i]) - (rp1[i] - rp2[i])), point5);

                if(mutation_verbose ==2) $display("x_new_full_q[%d]=%f", i, sf*x_new_full_q[i]);

            end

            if(mutation_verbose ==2) $display("mutating finished----------------x_new_full_q[0]=%f", sf*x_new_full_q[0]);
            // if(mutation_verbose ==2) $display("mutating-------------------------mp[0]=%f, mp[1]=%f, mp[2]=%f", sf*mp[0], sf*mp[1], sf*mp[2]);

        end



    end else if (lagger_J1_bite == 31) begin

        if (RandCntr >= one) begin

            if (RandCntr2 >= one) begin
                RandCntr2 = RandCntr2 - one;
            end
        end



    end else if (lagger_J1_bite == 32) begin


        if (RandCntr >= one) begin

            RandCntr = RandCntr - one;

        end


    end else if (lagger_J1_bite == 33) begin
 
        J1_mutation_flag = 0;
            
            
        // setting and launching L1
        lagger_L1_bite = 0;
        counter_L1_bite = 0;
        L1_wrap_new_solution_flag = 1;


        lagger_J1_bite = 0;
    
    end 
end
end





























// J3

// flag
reg                                                     J3_path_A1_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_J3_bite;
reg                 [q_full - 1 : 0]                    lagger_J3_bite;

// J3 variables


//J3_path_A1_loop_flag
always @(negedge clk_bite) begin
if (J3_path_A1_loop_flag == 1) begin
    lagger_J3_bite = lagger_J3_bite + 1;

    if (lagger_J3_bite == 1) begin
        
        if(mutation_verbose ==2) $display("mutating-------------------------mp[%d]=%f", counter_J3_bite,  sf*mp[counter_J3_bite+1]);

    end else if (lagger_J3_bite == 2) begin

        if (mp[counter_J3_bite + 1] < point5) begin
            if(mutation_verbose ==2) $display("mutating-------------------------mp < point5");

            x_new_full_q[counter_J3_bite] = CentParams[counter_J3_bite];
            if(mutation_verbose ==2) $display("mutating-------------------------x_new_full_q[%d]=%f = CentParams[%d]=%f", counter_J3_bite,  sf*x_new_full_q[counter_J3_bite], counter_J3_bite, sf*CentParams[counter_J3_bite]);

        end else begin
            x_new_full_q[counter_J3_bite] = MinParams[counter_J3_bite] + (MinParams[counter_J3_bite] - rp1[counter_J3_bite]);
            if(mutation_verbose ==2) $display("mutating-------------------------mp >= point5");
            if(mutation_verbose ==2) $display("mutating-------------------------x_new_full_q[%d]=%f = MinParams[%d]=%f + (MinParams - rp1=%f) =%f", counter_J3_bite, sf*x_new_full_q[counter_J3_bite], counter_J3_bite, sf*MinParams[counter_J3_bite], sf*rp1[counter_J3_bite], sf*(MinParams[counter_J3_bite] + (MinParams[counter_J3_bite] - rp1[counter_J3_bite])));

        end

        if(mutation_verbose ==2) $display("mutating-------------------------x_new_full_q[%d]=%f", counter_J3_bite, sf * x_new_full_q[counter_J3_bite]);


    end else if (lagger_J3_bite == 3) begin

        if (counter_J3_bite < num_dec - 1) begin
            counter_J3_bite = counter_J3_bite + 1;

        end else begin
            
            J3_path_A1_loop_flag = 0;
            
            J1_mutation_flag = 1;
        end

        lagger_J3_bite = 0;
    
    end 
end
end










// J4

// flag
reg                                                     J4_first_ab_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_J4_bite;
reg                 [q_full - 1 : 0]                    lagger_J4_bite;

// J4 variables


//J4_first_ab_loop_flag
always @(negedge clk_bite) begin
if (J4_first_ab_loop_flag == 1) begin
    lagger_J4_bite = lagger_J4_bite + 1;

    if (lagger_J4_bite == 1) begin
        if(mutation_verbose ==2) $display("mutating-------------------------looping a=%d to b+1=%d", a,b+1);


    end else if (lagger_J4_bite == 2) begin
        


        v1 = toolkit.mult(x_new_full_q[counter_J4_bite] , MantMult) & q_full_integer_mask;

    end else if (lagger_J4_bite == 3) begin
        
        v2 = toolkit.mult(rp0         [counter_J4_bite] , MantMult) & q_full_integer_mask;


    end else if (lagger_J4_bite == 4) begin

        v0 = (((v1 ^ imask) + (v2 ^ imask2)) >> 1) & q_full_integer_mask;

    end else if (lagger_J4_bite == 5) begin

        if(mutation_verbose ==2) $display("mutating--------------------------------------------------x_new_full_q[%d]=%f", counter_J4_bite, sf*x_new_full_q[counter_J4_bite]);
        if(mutation_verbose ==2) $display("mutating--------------------------------------------------rp0         [%d]=%f", counter_J4_bite, sf*rp0[counter_J4_bite]);
        if(mutation_verbose ==2) $display("mutating--------------------------------------------------v1=%f", sf*v1);
        if(mutation_verbose ==2) $display("mutating--------------------------------------------------v2=%f", sf*v2);
        if(mutation_verbose ==2) $display("mutating--------------------------------------------------v0=%f", sf*v0);

        x_new_full_q[counter_J4_bite] = toolkit.mult(v0 , MantMultI);



        if(mutation_verbose ==2) $display("mutating--------------------------------------------------x_new_full_q[%d]=%f\n", counter_J4_bite, sf*x_new_full_q[counter_J4_bite]);

        

    end else if (lagger_J4_bite == 6) begin

        if (counter_J4_bite < b + 1 - 1) begin
            counter_J4_bite = counter_J4_bite + 1;

        end else begin
            
            J4_first_ab_loop_flag = 0;
            
            J1_mutation_flag = 1;

        end

        lagger_J4_bite = 1;
    
    end 
end
end











// J5

// flag
reg                                                     J5_second_ab_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_J5_bite;
reg                 [q_full - 1 : 0]                    lagger_J5_bite;

// J5 variables


//J5_second_ab_loop_flag
always @(negedge clk_bite) begin
if (J5_second_ab_loop_flag == 1) begin
    lagger_J5_bite = lagger_J5_bite + 1;

    if (lagger_J5_bite == 1) begin
        
        if(mutation_verbose ==2) $display("mutating-----------------------------------rp1[%d]=%f", counter_J5_bite, sf * rp1[counter_J5_bite]);
        if(mutation_verbose ==2) $display("mutating-----------------------------------| x_new_full_q[%d]= %f ", counter_J5_bite, sf * x_new_full_q[counter_J5_bite]);

        x_new_full_q[counter_J5_bite] = x_new_full_q[counter_J5_bite] - toolkit.mult(x_new_full_q[counter_J5_bite] - rp1[counter_J5_bite], m1);
       

    end else if (lagger_J5_bite == 2) begin

        if(mutation_verbose ==2) $display("mutating-----------------------------------|| x_new_full_q[%d]= %f ", counter_J5_bite, sf * x_new_full_q[counter_J5_bite]);

        x_new_full_q[counter_J5_bite] = x_new_full_q[counter_J5_bite] - toolkit.mult(x_new_full_q[counter_J5_bite] - rp1[counter_J5_bite], m2);
        if(mutation_verbose ==2) $display("mutating-----------------------------------||| x_new_full_q[%d]= %f ", counter_J5_bite, sf * x_new_full_q[counter_J5_bite]);
 

    end else if (lagger_J5_bite == 3) begin

        if (counter_J5_bite < b + 1 - 1) begin
            counter_J5_bite = counter_J5_bite + 1;

        end else begin
            
            J5_second_ab_loop_flag = 0;

            J1_mutation_flag = 1;


        end

        lagger_J5_bite = 0;
    
    end 
end
end






















// 20_L_wrapping
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
localparam                                              wrapping_verbose = 0;

// L1

// flag
reg                                                     L1_wrap_new_solution_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L1_bite;
reg                 [q_full - 1 : 0]                    lagger_L1_bite;

// L1 variables


//L1_wrap_new_solution_flag
always @(negedge clk_bite) begin
if (L1_wrap_new_solution_flag == 1) begin
    lagger_L1_bite = lagger_L1_bite + 1;

    if (lagger_L1_bite == 1) begin
        if(verbose ==2) $display("L1: generating new random numbers");
        

        L1_wrap_new_solution_flag = 0;
        // setting and launching Randomizer
        counter_N1_bite = 0;
        lagger_N1_bite  = 0;
        caller_to_randomizer_is = caller_to_randomizer_is_L1;
        N1_get_new_random_values_flag = 1;

        if(verbose ==2) $display("L1: Wrapping starts");


    end else if (lagger_L1_bite == 2) begin
        
        
        if(wrapping_verbose ==2) $display("\n\n wrapping-------------------------x_new_full_q[%d] = %f", counter_L1_bite, sf * x_new_full_q[counter_L1_bite]);

            
        if (x_new_full_q[counter_L1_bite] < 0) begin
            if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q[%d] < 0", counter_L1_bite);

            if (x_new_full_q[0] > neg_one) begin
                if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q > -1");

                x_new_full_q[counter_L1_bite] = toolkit.mult(mp[counter_L1_bite] , x_new_full_q[counter_L1_bite]);

                x_new_full_q[counter_L1_bite] = toolkit.mult(neg_one , x_new_full_q[counter_L1_bite]);

            end else begin
                if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q <= -1");
                x_new_full_q[counter_L1_bite] = mp[counter_L1_bite];
            end
        end else if (x_new_full_q[counter_L1_bite] > one) begin
            if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q > 1");

            if (x_new_full_q[counter_L1_bite] < two) begin
                if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q < 2");
                x_new_full_q[counter_L1_bite] = one - toolkit.mult(mp[counter_L1_bite] , x_new_full_q[counter_L1_bite] - one);

            end else begin
                if(wrapping_verbose ==2) $display("wrapping-------------------------x_new_full_q >= 2");

                x_new_full_q[counter_L1_bite] = mp[2];
            end
        end

    end else if (lagger_L1_bite == 3) begin

        if(wrapping_verbose >= 1) $display("`                       x_new_full_q[%d] = %f", counter_L1_bite, sf * x_new_full_q[counter_L1_bite]);


    end else if (lagger_L1_bite == 4) begin

        if (counter_L1_bite < dv_per_solution - 1) begin
            counter_L1_bite = counter_L1_bite + 1;

        end else begin
            
            L1_wrap_new_solution_flag = 0;

            lagger_L2_bite = 0;
            // setting and launching L2
            L2_write_new_solution_to_memory_flag = 1;
            
        end

        lagger_L1_bite = 1;
    
    end 
end
end














// L2

// flag
reg                                                     L2_write_new_solution_to_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_L2_bite;

// L2 variables


//L2_write_new_solution_to_memory_flag
always @(negedge clk_bite) begin
if (L2_write_new_solution_to_memory_flag == 1) begin
    lagger_L2_bite = lagger_L2_bite + 1;

    if (lagger_L2_bite == 1) begin
        
        for (i = 0; i < dv_per_solution; i = i + 1) begin
            solution_value_to_write_on_memory_U4[i] = x_new_full_q[i] >> (q_half - bits_per_dv) ;

            sol_most_recent[i] =  x_new_full_q[i] >> (q_half - bits_per_dv) ;

            
            // $display("L2: new solution[%d]=%b", i , solution_value_to_write_on_memory_U4[i]);

            // $display("L2: new solution[i]=%b");
            // $display("L2: new solution[i]=%f", dv_to_real(solution_value_to_write_on_memory_U4[i] ));

            // $display("L2: new solution[%d]: %f", i, dv_to_real(solution_value_to_write_on_memory_U4[i]));

        end



    end else if (lagger_L2_bite == 2) begin
        address_to_write_solution_value_on_U4 = bma_new_sol;
        L2_write_new_solution_to_memory_flag = 0;
        // setting and launching U4
        counter_U4_bite = 0;
        lagger_U4_bite  = 0;
        caller_to_U4 = caller_to_U4_is_L2;
        U4_write_solution_on_main_memory_flag = 1;
      

    end else if (lagger_L2_bite == 3) begin

        if (verbose) $display("L2: new solution stored in the memory.");
            
        L2_write_new_solution_to_memory_flag = 0;
        
        

        sol_ready_flag = 1;



        lagger_L2_bite = 0;
    
    end 
end
end


















// 30_N_random
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------




// random number generators

reg signed  [q_full - 1 : 0]           mp                [16 + 1 - 1 : 0];
reg signed  [q_full - 1 : 0]           mp2               [3 - 1 : 0];
reg signed  [q_full - 1 : 0]           mp3               [3 - 1 : 0];
reg signed  [q_full - 1 : 0]           mp4               [3 - 1 : 0];
reg         [address_len - 1 : 0]      mpi               [3 - 1 : 0];
reg signed  [q_full - 1 : 0]           tpdf              [2 - 1 : 0];




localparam random_generator_bits = 16;

wire                [random_generator_bits - 1 : 0]           live_random_value;
reg                 [random_generator_bits - 1 : 0]           static_random_value;

reg                 go_random = 0;

reg                 [2 * random_generator_bits - 1       :0]     randomizer_initial_value = 14546;


rnd my_rand_num_generator_1 (
        .clk(clk_bite),
        .go(go_random),
        .initial_value(randomizer_initial_value),
        .random_value(live_random_value)
    );




/*
this random generator stops the `rnd` module when not in use.
so it saves energy.
to avoid starting again from the same initial value,
it updates the inital value with two random values when the loop is over.


what is the right len for mpi?
answer: see where it is used. its width should not limit the operations it is involved with
*/





// N1

// flag
reg                                                     N1_get_new_random_values_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_N1_bite;
reg                 [q_full - 1 : 0]                    lagger_N1_bite;

// N1 variables
reg                 [5 - 1      : 0]                    caller_to_randomizer_is;
localparam          [5 - 1      : 0]                    caller_to_randomizer_is_D0  =   0;
localparam          [5 - 1      : 0]                    caller_to_randomizer_is_J1  =   1;
localparam          [5 - 1      : 0]                    caller_to_randomizer_is_L1  =   2;
localparam          [5 - 1      : 0]                    caller_to_randomizer_is_C2  =   3;


//N1_get_new_random_values_flag
always @(negedge clk_bite) begin
if (N1_get_new_random_values_flag == 1) begin
    lagger_N1_bite = lagger_N1_bite + 1;

    if (lagger_N1_bite == 1) begin
        // $display("N1: starting the randomizer..");

        

        // test_retry_random = 0;
        go_random = 1;

    end else if (lagger_N1_bite == 2) begin

        static_random_value = live_random_value;
        // static_random_value = real_dec_to_16bit(uniform_random_value(dummy));

        mp[counter_N1_bite] = static_random_value << (q_half - random_generator_bits);
    
        // $display("%f, mp[i]:%f, %b", sf_dv * random_value, sf * mp[counter_N1_bite], mp[counter_N1_bite]);

    end else if (lagger_N1_bite == 3) begin
        
        if (counter_N1_bite < 3) begin

            mp2[counter_N1_bite] = toolkit.mult(mp[counter_N1_bite] , mp[counter_N1_bite]);

        end

    end else if (lagger_N1_bite == 4) begin
        
        if (counter_N1_bite < 3) begin

            mp3[counter_N1_bite] = toolkit.mult(mp[counter_N1_bite] , mp2[counter_N1_bite]);

        end


    end else if (lagger_N1_bite == 5) begin
        
        if (counter_N1_bite < 3) begin

            mp4[counter_N1_bite] = toolkit.mult(mp2[counter_N1_bite] , mp2[counter_N1_bite]);


        end


    end else if (lagger_N1_bite == 6) begin
        
        if (counter_N1_bite < 3) begin

            mpi[counter_N1_bite] = toolkit.mult(mp3[counter_N1_bite] , 4 << q_half) >> q_half;


        end


    end else if (lagger_N1_bite == 7) begin
        if (counter_N1_bite < 2) begin

            tpdf[counter_N1_bite] = (live_random_value << (q_half - random_generator_bits)) - mp[counter_N1_bite];
            // tpdf[counter_N1_bite] = real_dec_to_16bit($random - $random);
            
            // $display("%f, mp[i]:%f, mp2[i]:%f, mp3[i]:%f, mp4[i]:%f, mpi[i]:%d, tpdf[i]:%f",
            //  sf_dv * static_random_value,
            //    sf * mp [counter_N1_bite],
            //    sf * mp2[counter_N1_bite],
            //    sf * mp3[counter_N1_bite],
            //    sf * mp4[counter_N1_bite],
            //         mpi[counter_N1_bite],
            //    sf * tpdf[counter_N1_bite]
               
            //    );

        end

    end else if (lagger_N1_bite == 8) begin

        if (counter_N1_bite < 16 + 1 - 1) begin
            counter_N1_bite = counter_N1_bite + 1;

        end else begin


            $fdisplay(N0_output_file_random_values, "%f", sf * tpdf [0]);

            // updating the random seed so that the randomizer does not repeat itself in the next run
            randomizer_initial_value = {static_random_value, live_random_value};
            

            N1_get_new_random_values_flag = 0;
            
            // turning off randmizer to spare energy
            go_random = 0;

            // go back to manager (for testeing only)
            // test_retry_random = 1;


            case (caller_to_randomizer_is)
                caller_to_randomizer_is_D0      :       D0_initialize_archive_flag = 1;
                caller_to_randomizer_is_J1      :       J1_mutation_flag = 1;
                caller_to_randomizer_is_L1      :       L1_wrap_new_solution_flag = 1;
                caller_to_randomizer_is_C2      :       C2_reset_mutation_parameters_flag = 1;
            endcase



        end

        lagger_N1_bite = 1;
    
    end 
end
end






// 39_U_memory_handler
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------



reg mem_verbose = 0;



// U0

// READ SOLUTION

// flag
reg                                                     U0_read_solution_on_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_U0_bite;
reg                 [q_full - 1 : 0]                    lagger_U0_bite;

// U0 variables
reg                 [bits_per_dv - 1 : 0]               solution_value_read_from_memory_U0      [dv_per_solution - 1 : 0];
reg                 [address_len - 1 : 0]               address_to_read_solution_value_from_U0;


reg                 [5 - 1 :       0]                   caller_to_U0;
localparam          [5 - 1 :       0]                   caller_to_U0_is_V1  = 0;
localparam          [5 - 1 :       0]                   caller_to_U0_is_F1  = 1;
localparam          [5 - 1 :       0]                   caller_to_U0_is_H1  = 2;
localparam          [5 - 1 :       0]                   caller_to_U0_is_J1  = 3;



//U0_read_solution_on_main_memory_flag
always @(negedge clk_bite) begin
if (U0_read_solution_on_main_memory_flag) begin
    lagger_U0_bite = lagger_U0_bite + 1;


    if (lagger_U0_bite == 1) begin
        main_mem_read_addr = address_to_read_solution_value_from_U0 + (2 * counter_U0_bite);

        solution_value_read_from_memory_U0[counter_U0_bite] = 0;

    end else if (lagger_U0_bite == 2) begin
        solution_value_read_from_memory_U0[counter_U0_bite] = solution_value_read_from_memory_U0[counter_U0_bite] | (main_mem_read_data << 8) ;

        if (mem_verbose) $display("`         U0: read      %b   from %d", main_mem_read_data, main_mem_read_addr);


    end else if (lagger_U0_bite == 3) begin
        main_mem_read_addr = address_to_read_solution_value_from_U0 + (2 * counter_U0_bite) + 1;
        
    end else if (lagger_U0_bite == 4) begin
        solution_value_read_from_memory_U0[counter_U0_bite] = solution_value_read_from_memory_U0[counter_U0_bite] | main_mem_read_data ;


        if (mem_verbose) $display("`         U0: read      %b   from %d", main_mem_read_data, main_mem_read_addr);



    end else if (lagger_U0_bite == 5) begin

        if (counter_U0_bite < dv_per_solution - 1) begin
            counter_U0_bite = counter_U0_bite + 1;

        end else begin
            
            U0_read_solution_on_main_memory_flag = 0;

            case (caller_to_U0)
                caller_to_U0_is_F1     :   F1_update_archive_flag = 1;
                caller_to_U0_is_H1     :   H1_sort_archive_flag = 1;
                caller_to_U0_is_J1     :   J1_mutation_flag = 1;
            endcase

        end

        lagger_U0_bite = 0;
    
    end 
end
end




















    
// U1

// READ F


// flag
reg                                                     U1_read_f_on_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_U1_bite;
reg                 [q_full - 1 : 0]                    lagger_U1_bite;

// U1 variables
reg     signed      [f_bitstream_len - 1 : 0]           f_value_read_from_memory_U1;
reg                 [address_len - 1 : 0]               address_to_read_f_value_from_U1;


reg                 [5 - 1 :       0]                   caller_to_U1;
localparam          [5 - 1 :       0]                   caller_to_U1_is_D0   = 0;
localparam          [5 - 1 :       0]                   caller_to_U1_is_F1   = 1;
localparam          [5 - 1 :       0]                   caller_to_U1_is_H1   = 2;



//U1_read_f_on_main_memory_flag
always @(negedge clk_bite) begin
if (U1_read_f_on_main_memory_flag) begin
    lagger_U1_bite = lagger_U1_bite + 1;


    if (lagger_U1_bite == 1) begin
        f_value_read_from_memory_U1 = 0;

    end else if (lagger_U1_bite == 2) begin

        main_mem_read_addr = address_to_read_f_value_from_U1 + counter_U1_bite;

    end else if (lagger_U1_bite == 3) begin
        f_value_read_from_memory_U1 = (f_value_read_from_memory_U1 << 8) | main_mem_read_data;


    end else if (lagger_U1_bite == 4) begin

        if (counter_U1_bite < bytes_per_f - 1) begin
            counter_U1_bite = counter_U1_bite + 1;

        end else begin
            
            U1_read_f_on_main_memory_flag = 0;


            case (caller_to_U1)
                caller_to_U1_is_D0      :   D0_initialize_archive_flag = 1;
                caller_to_U1_is_F1      :   F1_update_archive_flag     = 1;
                caller_to_U1_is_H1      :   H1_sort_archive_flag     = 1;
            endcase

        end

        lagger_U1_bite = 1;
    
    end 
end
end
















// U2

// WRITE SOLUTION BITSTREAM

// flag
reg                                                     U2_write_solution_on_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_U2_bite;
reg                 [q_full - 1 : 0]                    lagger_U2_bite;

// U2 variables
reg                 [sol_bitstream_len - 1 : 0]         solution_value_to_write_on_memory_U2;
reg                 [address_len - 1 : 0]               address_to_write_solution_value_on_U2;


reg                 [5 - 1 :       0]                   caller_to_U2;
localparam          [5 - 1 :       0]                   caller_to_U2_is_H1  = 0;




//U2_write_solution_on_main_memory_flag
always @(negedge clk_bite) begin
if (U2_write_solution_on_main_memory_flag) begin
    lagger_U2_bite = lagger_U2_bite + 1;

    if (lagger_U2_bite == 1) begin
        main_mem_write_addr = address_to_write_solution_value_on_U2 + counter_U2_bite;
        main_mem_write_data = (solution_value_to_write_on_memory_U2 >> ((bytes_per_solution - counter_U2_bite - 1) * 8)) & (8'b11111111);


    end else if (lagger_U2_bite == 2) begin
        main_mem_write_enable = 1;

    end else if (lagger_U2_bite == 3) begin
        main_mem_write_enable = 0;


    end else if (lagger_U2_bite == 4) begin

        if (counter_U2_bite < bytes_per_solution - 1) begin
            counter_U2_bite = counter_U2_bite + 1;

        end else begin

            U2_write_solution_on_main_memory_flag = 0;


            
            case (caller_to_U2)
                caller_to_U2_is_H1  :   H1_sort_archive_flag = 1;
            endcase
            
        end

        lagger_U2_bite = 0;
    
    end 
end
end













// U3

// WRITE F

// flag
reg                                                     U3_write_f_on_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_U3_bite;
reg                 [q_full - 1 : 0]                    lagger_U3_bite;

// U3 variables
reg  signed         [f_bitstream_len - 1 : 0]           f_value_to_write_on_memory_U3;
reg                 [address_len - 1 : 0]               address_to_write_f_value_on_U3;

reg                 [5 - 1 :       0]                   caller_to_U3;
localparam          [5 - 1 :       0]                   caller_to_U3_is_V1  = 0;
localparam          [5 - 1 :       0]                   caller_to_U3_is_D0  = 1;
localparam          [5 - 1 :       0]                   caller_to_U3_is_F1  = 2;
localparam          [5 - 1 :       0]                   caller_to_U3_is_H1  = 3;


//U3_write_f_on_main_memory_flag
always @(negedge clk_bite) begin
if (U3_write_f_on_main_memory_flag) begin
    lagger_U3_bite = lagger_U3_bite + 1;

    if (lagger_U3_bite == 1) begin
        main_mem_write_addr = address_to_write_f_value_on_U3 + counter_U3_bite;
        main_mem_write_data = (f_value_to_write_on_memory_U3 >> ((bytes_per_f - counter_U3_bite - 1) * 8)) & (8'b11111111);


        if (mem_verbose) $display("`         U3: writing   %b   at   %d", main_mem_write_data, main_mem_write_addr);

    end else if (lagger_U3_bite == 2) begin
        main_mem_write_enable = 1;

    end else if (lagger_U3_bite == 3) begin
        main_mem_write_enable = 0;
        

    end else if (lagger_U3_bite == 4) begin

        if (counter_U3_bite < bytes_per_f - 1) begin
            counter_U3_bite = counter_U3_bite + 1;

        end else begin

            U3_write_f_on_main_memory_flag = 0;

            
            case (caller_to_U3)
                caller_to_U3_is_D0  :   D0_initialize_archive_flag = 1;
                caller_to_U3_is_F1  :   F1_update_archive_flag = 1;
                caller_to_U3_is_H1  :   H1_sort_archive_flag = 1;
            endcase
            
                        



        end

        lagger_U3_bite = 0;
    
    end 
end
end





















































// U4

// WRITE SOLUTION ARRAY

// flag
reg                                                     U4_write_solution_on_main_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_U4_bite;
reg                 [q_full - 1 : 0]                    lagger_U4_bite;

// U4 variables
reg                 [bits_per_dv - 1 : 0]               solution_value_to_write_on_memory_U4  [dv_per_solution - 1 : 0];
reg                 [address_len - 1 : 0]               address_to_write_solution_value_on_U4;


reg                 [5 - 1 :       0]                   caller_to_U4;
localparam          [5 - 1 :       0]                   caller_to_U4_is_D0  = 0;
localparam          [5 - 1 :       0]                   caller_to_U4_is_F1  = 1;
localparam          [5 - 1 :       0]                   caller_to_U4_is_H1  = 2;
localparam          [5 - 1 :       0]                   caller_to_U4_is_L2  = 3;



//U4_write_solution_on_main_memory_flag
always @(negedge clk_bite) begin

if (U4_write_solution_on_main_memory_flag) begin
    lagger_U4_bite = lagger_U4_bite + 1;

    if (lagger_U4_bite == 1) begin
        // $display("U4: 1");
        main_mem_write_addr = address_to_write_solution_value_on_U4 + 2 * counter_U4_bite;

        main_mem_write_data = solution_value_to_write_on_memory_U4[counter_U4_bite] >> 8 & (8'b11111111);
        
        if (mem_verbose) $display("`         U4: writing   %b   at   %d", main_mem_write_data, main_mem_write_addr);

    end else if (lagger_U4_bite == 2) begin
        main_mem_write_enable = 1;

    end else if (lagger_U4_bite == 3) begin
        main_mem_write_enable = 0;


    end else if (lagger_U4_bite == 4) begin
        main_mem_write_addr = address_to_write_solution_value_on_U4 + (2 * counter_U4_bite) + 1;

        main_mem_write_data = solution_value_to_write_on_memory_U4[counter_U4_bite] & (8'b11111111);
        
        if (mem_verbose) $display("`         U4: writing   %b   at   %d", main_mem_write_data, main_mem_write_addr);
        

    end else if (lagger_U4_bite == 5) begin
        main_mem_write_enable = 1;

    end else if (lagger_U4_bite == 6) begin
        main_mem_write_enable = 0;





    end else if (lagger_U4_bite == 7) begin

        if (counter_U4_bite < dv_per_solution - 1) begin
            counter_U4_bite = counter_U4_bite + 1;

        end else begin

            U4_write_solution_on_main_memory_flag = 0;
            
            case (caller_to_U4)
                caller_to_U4_is_D0  :   D0_initialize_archive_flag = 1;
                caller_to_U4_is_F1  :   F1_update_archive_flag = 1;
                caller_to_U4_is_H1  :   H1_sort_archive_flag = 1;
                caller_to_U4_is_L2  :   L2_write_new_solution_to_memory_flag = 1;
            endcase
            
        end

        lagger_U4_bite = 0;
    
    end 
end
end






















































// // U10

// // flag
// reg                                                     U10_dump_main_memory_flag   = 0;


// // loop reset
// reg                 [q_full - 1 : 0]                    counter_U10_bite;
// reg                 [q_full - 1 : 0]                    lagger_U10_bite;

// // U10 variables


// //U10_dump_main_memory_flag
// always @(negedge clk_bite) begin
// if (U10_dump_main_memory_flag == 1) begin
//     lagger_U10_bite = lagger_U10_bite + 1;

//     if (lagger_U10_bite == 1) begin
//         main_mem_read_addr = counter_U10_bite;

//     end else if (lagger_U10_bite == 2) begin
//         $fdisplayb(U10_output_file_main_mem, main_mem_read_data);



//     end else if (lagger_U10_bite == 3) begin

//         if (counter_U10_bite < main_memory_depth - 1) begin
//             counter_U10_bite = counter_U10_bite + 1;

//         end else begin
            
//             U10_dump_main_memory_flag = 0;
            
            
//             $fclose(U10_output_file_main_mem);
            
//             $display("\nU10: finished dumping main_memory at %d\n", $time);





//             //setting and launching U11
//             //counter_U11_bite = 0;
//             //lagger_U11_bite = 0;
//             //next_flag_U11 = 1;



//         end

//         lagger_U10_bite = 0;
    
//     end 
// end
// end

















































endmodule

