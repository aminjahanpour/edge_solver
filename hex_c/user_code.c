#include <math.h>

float cost_function(float *x, int dim, float lb, float ub) {
    /*
    x:   decision variables array
    dim: number of decision variables
    lb:  lower band for the decision variables
    ub:  upper band for the decision variables
    */

    for (int i = 0; i < dim; i++)
    {
        x[i] = lb + x[i] * (ub - lb);
    }

    // RASTRIGIN function
    float ret = 10.0F * (float)dim;

    for (int i = 0; i < dim; i++)
    {
        ret = ret + x[i] * x[i] - 10.0F * cosf(2.0F * 3.1415F * x[i]);
    }

    return ret;
}


int main(void)

{

    int dim = 3;
    int budget = 150;

    // RASTRIGIN / DROP-WAVE functions bounds
    float lb = -5.12F;
    float ub = 5.12F;

    // decision variables array
    float x[dim];

    // dummy variables are needed for PAR commands
    // they don't effect your results
    float dummy[2] = {0.0F, 0.0F};

    // reseting the solver with `par_rst` custom instruction
    asm volatile ("par_rst %0, %1, %2\n":"=f"(dummy[0]):"f"((float)dim),"f"((float)budget):);

    int iteration_counter = 0;

    float best_f = 1000.0F;

    // printing some integers using `par_print_int` custom instruction
    asm volatile ("par_print_int %0, %1, %2\n":"=f"(dummy[0]):"f"((float)dim),"f"(dummy[1]):);
    asm volatile ("par_print_int %0, %1, %2\n":"=f"(dummy[0]):"f"((float)budget),"f"(dummy[1]):);


    // main loop
    while (iteration_counter < budget)
    {

        // asking the solver for the next suggestions using `par_ask`
        for (int i = 0; i < dim; i++)
        {
            float j = i;
            asm volatile ("par_ask %0, %1, %2\n":"=f"(x[i]):"f"(j),"f"(dummy[1]):);
        }

        // calcualting our cost function value for the values suggested by the solver
        float cost_function_value = cost_function(x, dim, lb, ub);

        // any improvements? save it then.
        if (cost_function_value < best_f) {
            best_f = cost_function_value;
        }

        // telling the solver about new cost function values using `par_tell`
        asm volatile ("par_tell %0, %1, %2\n":"=f"(dummy[0]):"f"(cost_function_value),"f"(dummy[1]):);

        iteration_counter = iteration_counter + 1;
    }


    // printing out the results
    asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(best_f),"f"(dummy[1]):);

    for (int i = 0; i < dim; i++)
    {
        asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(x[i]),"f"(dummy[1]):);
    }


}

