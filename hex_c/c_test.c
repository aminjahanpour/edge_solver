#include <math.h>

int main()
{
    // dummy is needed for PAR commands
    // they don't effect your results
    float dummy[2] = {3.0F, 100.0F};

    float a = 123.345F;
    float b = 0.2F;

    float c = a/b;

    asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(c),"f"(dummy[1]):);

    return 0;
}
