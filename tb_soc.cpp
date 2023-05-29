
#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vrnd.h"
// #include "Vrnd___024unit.h"

#define MAX_SIM_TIME 100

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;




void dut_reset (Vrnd *dut, vluint64_t &sim_time){
    

    if(sim_time == 3){
        dut->initial_value = 10;
    }
    else if (sim_time > 10){
        dut->go = 1;
    }
}



int main(int argc, char** argv, char** env) {
    
    // instantiate the converted module
    Vrnd *dut = new Vrnd;

    // set up the waveform dumping
    // Verilated::traceEverOn(true);
    // VerilatedVcdC *m_trace = new VerilatedVcdC;
    // dut->trace(m_trace, 5);
    // m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);

        printf("clk\n");
        dut->clk ^= 1;            // Invert clock
        dut->eval();              // Evrndate dut on the current edge

        std::cout << "OUTOUT: " << dut->random_value << std::endl;

        // verification
        // if (dut->clk == 1){
        //     posedge_cnt++;
        //     if (posedge_cnt == 5){
        //         dut->in_valid = 1;       // assert in_valid on 5th cc
        //     }
        //     if (posedge_cnt == 7){
        //         if (dut->out_valid != 1) // check in_valid on 7th cc
        //             std::cout << "ERROR!" << std::endl;
        //     }
        // }


        // m_trace->dump(sim_time);  // Dump to waveform.vcd
        sim_time++;               // Advance simulation time

    }

    // m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

