
/*

memory is as array of bytes that contain both code and data.
it may contain:
  - program code
  - read only data
  - stack data
  - program heap data

  the Nuemann arch says that everythong goes into one memory.
  like here we have both instructions and data in the same memory.


this is our `program` that we want to run on our processor.

in a `program` we talk about addresses of the registers and what we plan to do
with the contents of those registers to achieve a goal.

-- everything happens in the registers and the alu in an ultrafast manner
*/

module memory
    #(
        parameter                                       mem_width                       = 0,
        parameter                                       mem_depth                       = 0,
        parameter                                       initial_file                    = ""

        )
    (
        input                                           clk     ,
        input       [mem_width - 1 : 0]                 w_data  ,
        input       [4 - 1 : 0]                         w_mask  ,
        input       [mem_width - 2 - 1 : 0]               w_addr  ,
        input       [mem_width - 1 : 0]               r_addr  ,
        input                                           w_en    ,
        input                                           r_en    ,

        output  reg [mem_width - 1 : 0]                 r_data
    );


    reg memory_verbose = 0;

    /*
    Note addresses are aligned on word boundaries for LW (multiple of 4 bytes) and halfword boundaries for LH,LHU (multiple of 2 bytes). 
    */

    reg signed      [mem_width - 1 : 0]              mem [mem_depth - 1 : 0];


    integer i;

    initial begin

        if (initial_file != 0) begin
            $display("\n\n____ Creating rom_async from init file '%s'.", initial_file);
            $readmemh(initial_file, mem, 0, mem_depth - 1);
        end

    end


    always @(posedge clk) begin

        if (w_en == 1) begin
            // mem[w_addr] <= w_data;

            if (memory_verbose) $display("MEMORY MODULE: -->     MEMORY WRITE: w_addr:%d, w_data: 0x %h, w_mask:%b", w_addr, w_data, w_mask);
            if(w_mask[0]) mem[w_addr][ 7:0 ] <= w_data[ 7:0 ];
            if(w_mask[1]) mem[w_addr][15:8 ] <= w_data[15:8 ];
            if(w_mask[2]) mem[w_addr][23:16] <= w_data[23:16];
            if(w_mask[3]) mem[w_addr][31:24] <= w_data[31:24];	

        end

        if (r_en == 1) begin
            r_data <= mem[r_addr];


            if(memory_verbose) begin
                for(i = 0; i < mem_depth; i = i + 1) begin
                $display("'\t\t\t\t\tmem[%d]: (%d) 0x %h", i, $signed(mem[i]), mem[i]);
                end
            end

        end
        


    end




endmodule