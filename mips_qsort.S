#include <mips/regdef.h>
#include <sys/syscall.h>

#define ASCII_0 48

#define STACK_SZ 32
#define NUM 0
#define DER 4
#define IZQ 8
#define GP 16
#define FP 20
#define RA 24
#define NUM_CALLER STACK_SZ 
#define DER_CALLER (STACK_SZ + 4)
#define IZQ_CALLER (STACK_SZ + 8)

    .text
    .abicalls
    .globl mips_qsort
    .ent mips_qsort


qsort:
    
    #creo StackFrame

    #       | padding |
    #       |   ra    |
    #       |   fp    |
    #       |   gp    |
    #       | padding |
    #       |   izq   |
    #       |   der   |
    #       |   num   |

    subu sp, sp, STACK_SZ
    
    sw $fp, FP(sp) 
    sw gp, GP(sp)  
    
    #move $fp, sp 

    sw a0, NUM_CALLER(sp)
    sw a1, DER_CALLER(sp)
    sw a2, IZQ_CALLER(sp) 
    
    # Seed
    l.s $f0, SEED_REAL_PARAM(a0) 
    s.s $f0, SEED_REAL($fp) 

    l.s $f0, SEED_IM_PARAM(a0) 
    s.s $f0, SEED_IM($fp)

    # Variables locales
    li t0, 0       
    sw t0, C($fp)   
    sw t0, X($fp) 
    sw t0, Y($fp)  
    sw t0, SI($fp) 
    sw t0, SR($fp) 
    sw t0, ZI($fp) 
    sw t0, ZR($fp) 
    
    # Buffer Len
    li t0, 0
    sw t0, BUFFER_LEN($fp)

    # Fin StackFrame

io_error:
    li v0, SYS_write
    li a0, 2
    la a1, error_msg
    li a2, 11
    syscall

    li v0, -1     # return value -1
    j return

success:
    li v0, 0      # return value 0

return:
    ###############################################################
    # Pop stack frame
    lw $fp, FP(sp) # loads mem(sp + FP) on $fp
    lw gp, GP(sp)  # loads mem(sp + GP) on gp
    addiu sp, sp, STACK_SZ  # pop stack pointer up
    ###############################################################

    jr ra
    
    .end qsort

    .data
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
