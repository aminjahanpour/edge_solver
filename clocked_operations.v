module clocked_operations #(
    parameter register_width = 0
)(
		input                                           clk,        
		input                                           go,
        input       [8 - 1 : 0]                         operation_id,
        input       [register_width - 1 : 0]            input_var_0,
        input       [register_width - 1 : 0]            input_var_1,
        input       [register_width - 1 : 0]            input_var_2,
        output reg  [register_width - 1 : 0]            results,
        output reg                                      finished
   	);


// localparam q_full = 128;
// localparam q_half = 64;

// localparam sf    = 2.0**-64.0;  
// localparam sf_dv = 2.0**-16.0;  
// localparam sf_f  = 2.0**-16.0;




// always @(posedge go) begin

//     finished = 0;

//     $display("CLOCKED OPERATIONS:   operation_id:%d(%b)\ninput_var_0:%f(%b)\ninput_var_1:%f(%b)",
//     operation_id, operation_id, sf*input_var_0_fixed_point, input_var_0, sf*input_var_1_fixed_point, input_var_1);

//     case (operation_id)
//         0   :           begin
//             $display("setting and launching A0");
//             // setting and launching A0
//             counter_A0 = 0;
//             lagger_A0 = 0;
//             ans_A0 = 0;

//             A0_calculate_gcd_flag = 1;
//         end

//         1   :           begin
//             $display("setting and launching A1");
//             // setting and launching A1
//             counter_A1 = 0;
//             lagger_A1 = 0;
//             ans_A1 = input_var_0;
//             $display("input_var_0: %d, %b", ans_A1,ans_A1);

//             A1_calculate_fact_flag = 1;
//         end
//     endcase
// end




// wire signed       [q_full - 1 : 0]          input_var_0_fixed_point = toolkit.float_sp_to_fixed_point(input_var_0);
// wire signed       [q_full - 1 : 0]          input_var_1_fixed_point = toolkit.float_sp_to_fixed_point(input_var_1);

// wire signed       [32 - 1 : 0]          mult_ret = toolkit.fixed_point_to_float_sp(toolkit.mult(input_var_0_fixed_point, input_var_1_fixed_point));



// // A0

// // flag
// reg                                                     A0_calculate_gcd_flag   = 0;


// // loop reset
// reg                 [q_full - 1 : 0]                    counter_A0;
// reg                 [q_full - 1 : 0]                    lagger_A0;

// // A0 variables
// reg                 [register_width - 1 : 0]            ans_A0;

// //A0_calculate_gcd_flag
// always @(negedge clk) begin
// if (A0_calculate_gcd_flag == 1) begin
//     lagger_A0 = lagger_A0 + 1;

//     if (lagger_A0 == 1) begin
//         ans_A0 = ans_A0 + input_var_0;
//     end else if (lagger_A0 == 2) begin

//         $display("A0: counter_A0:%d, ans:%b(%d)", counter_A0, ans_A0, ans_A0);

//     end else if (lagger_A0 == 3) begin

//         if (counter_A0 < 10- 1) begin
//             counter_A0 = counter_A0 + 1;

//         end else begin

//             results = mult_ret;

//             finished = 1;
            
//             A0_calculate_gcd_flag = 0;
            
        
//         end

//         lagger_A0 = 0;
    
//     end 
// end
// end


























// // A1

// // flag
// reg                                                     A1_calculate_fact_flag   = 0;


// // loop reset
// reg                 [q_full - 1 : 0]                    counter_A1;
// reg                 [q_full - 1 : 0]                    lagger_A1;

// // A1 variables
// reg                 [register_width - 1 : 0]            ans_A1;

// //A1_calculate_fact_flag
// always @(negedge clk) begin
// if (A1_calculate_fact_flag == 1) begin
//     lagger_A1 = lagger_A1 + 1;

//     if (lagger_A1 == 1) begin
//         ans_A1 = ans_A1 * 2;
//     end else if (lagger_A1 == 2) begin

//         $display("A1: ans:%b(%d)", ans_A1, ans_A1);

//     end else if (lagger_A1 == 3) begin

//         if (counter_A1 < 5 - 1) begin
//             counter_A1 = counter_A1 + 1;

//         end else begin

//             results = ans_A1;

//             finished = 1;
            
//             A1_calculate_fact_flag = 0;
            
        
//         end

//         lagger_A1 = 0;
    
//     end 
// end
// end



endmodule

