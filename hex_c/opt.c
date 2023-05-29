#include <math.h>

float cost_function(float *x, int dim, float lb, float ub) {

    for (int i = 0; i < dim; i++)
    {
        x[i] = lb + x[i] * (ub - lb);
    }

    // RASTRIGIN
    float ret = 10.0F * (float)dim;

    for (int i = 0; i < dim; i++)
    {
        ret = ret + x[i] * x[i] - 10.0F * cosf(2.0F * 3.1415F * x[i]);
    }


    // DROP-WAVE (dim=2 only)
    // float ret = - (1.0F + cos(12.0F * sqrt(x[0]*x[0] + x[1]*x[1]))) / (2.0F + 0.5F*(x[0]*x[0] + x[1]*x[1]));

    return ret;
}


float main_function()
{

    int dim = 3;
    int budget = 200;

    // RASTRIGIN / DROP-WAVE
    float lb = -5.12F;
    float ub = 5.12F;

    float x[dim];

    float dummy[2] = {0.0F, 0.0F};

    // reseting the solver
    asm volatile ("par_rst %0, %1, %2\n":"=f"(dummy[0]):"f"((float)dim),"f"((float)budget):);

    int iteration_counter = 0;

    float best_f = 1000.0F;

    asm volatile ("par_print_int %0, %1, %2\n":"=f"(dummy[0]):"f"((float)dim),"f"(dummy[1]):);
    asm volatile ("par_print_int %0, %1, %2\n":"=f"(dummy[0]):"f"((float)budget),"f"(dummy[1]):);


    // main loop
    while (iteration_counter < budget)
    {

        // asking the solver for the next suggestions
        for (int i = 0; i < dim; i++)
        {
            float j = i;
            asm volatile ("par_ask %0, %1, %2\n":"=f"(x[i]):"f"(j),"f"(dummy[1]):);
        }

        // calcualting our cost function value for the values suggested by the solver
        float cost_function_value = cost_function(x, dim, lb, ub);

        // any improvements?
        if (cost_function_value < best_f) {
            best_f = cost_function_value;
        }

        // telling the solver about new cost function values
        asm volatile ("par_tell %0, %1, %2\n":"=f"(dummy[0]):"f"(cost_function_value),"f"(dummy[1]):);

        iteration_counter = iteration_counter + 1;
    }
    

    // printing out the results


    asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(best_f),"f"(dummy[1]):);

    for (int i = 0; i < dim; i++)
    {
        asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(x[i]),"f"(dummy[1]):);

    }


    return best_f;
}

int main(void)
{
    float m = main_function();
    return 0;
}