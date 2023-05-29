struct riscv_opcode
{

 /* The name of the instruction. */
 const char *name;



 /* The requirement of xlen for the instruction, 0 if no requirement. */
 unsigned xlen_requirement;
 


 /* Class to which this instruction belongs. Used to decide whether or
 not this instruction is legal in the current -march context. */
 enum riscv_insn_class insn_class;
 


 /* A string describing the arguments for this instruction. */
 const char *args;
 
 
 /* The basic opcode for the instruction. When assembling, this
 opcode is modified by the arguments to produce the actual opcode
 that is used. If pinfo is INSN_MACRO, then this is 0. */
 insn_t match;


 /* If pinfo is not INSN_MACRO, then this is a bit mask for the
 relevant portions of the opcode when disassembling. If the
 actual opcode anded with the match field equals the opcode field,
 then we have found the correct instruction. If pinfo is
 INSN_MACRO, then this field is the macro identifier. */
 insn_t mask;
 
 
 /* A function to determine if a word corresponds to this instruction.
 Usually, this computes ((word & mask) == match). */
 int (*match_func) (const struct riscv_opcode *op, insn_t word);
 
 
 /* For a macro, this is INSN_MACRO. Otherwise, it is a collection
 of bits describing the instruction, notably any relevant hazard
 information. */
 unsigned long pinfo;
};







#include <stdint.h>
#define FACT_DIGITS 10000
int main(void)
{
uint32_t num1 = 2321, num2 = 1771731, gcd = 0;
uint32_t fact_test_val = 10;
uint32_t fact_result_ptr; 
uint8_t fact_result[FACT_DIGITS];
fact_result_ptr = (uint32_t)fact_result;
asm volatile("gcd %0, %1,%2\n":"=r"(gcd):"r"(num1),"r"(num2):);
//suppose we want to compute the factorial of 125 so immediate=250
asm volatile("fact %0, %1\n":"=r"(fact_result_ptr):"i"(250):); 
return 0;
}