#include <stdint.h>
#define FACT_DIGITS 10000

int main(void)
{



    uint32_t num1 = 15;
    uint32_t num2 = 30;
    uint32_t ret = 0;

    asm volatile("rst %0, %1,%2\n":"=r"(ret):"r"(num1),"r"(num2):);

    return ret;
}


















// only ret

// int main() {



//     int num1 = 1321, num2 = 1771731, ret_ans = 0;

    
//     /*
//     we don't do this:
//     asm volatile("ret	a5,a5,a4\n");
    
//     instead we let the compiler figure the location of parameters
//     we should not worry about which register holds which parameter
//     it is the assembeler job to figure things out
//     we only provide the inputs to the instruction
//     */ 

//     asm volatile("ret %0, %1,%2\n":"=r"(ret_ans):"r"(num1),"r"(num2):);




//     return  2*ret_ans;
// }