#include <math.h>

int main()
{
    // dummy variables are needed for PAR commands
    // they don't effect your results
    float dummy[2];

    float pi = 3.1415F;
    float b = 0.2F;

    float c;

    // c = cos(2.0F * pi * 180.0F);
    c = pi/b;
//    c = sqrt(pi);
//    c = exp(pi);
//    c = log(pi);
//    c = pow(pi, 2.2F);
//    c = ceil(pi);
//    c = abs(pi);
//    c = floor(pi);
//    c = fmod(pi, b);

    asm volatile ("par_print_float %0, %1, %2\n":"=f"(dummy[0]):"f"(c),"f"(dummy[1]):);

    return 0;
}
