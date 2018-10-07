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


mips_qsort:
    .set noreorder
    .cpload t9
    .set reorder
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
    
    sw ra, RA(sp)
    sw $fp, FP(sp) 
    sw gp, GP(sp)  
    # Fin StackFrame

    sw a0, NUM_CALLER(sp) #Guardo los parametros en el ABA del caller
    sw a1, DER_CALLER(sp)
    sw a2, IZQ_CALLER(sp)

    lw t0, 0(a1) #Cargo en t0 el puntero a DER
    lw t1, 0(a2) #Cargo en t1 el puntero a IZQ
if_izq_der: #if(first<last)
    subu t2, t0, t1 #PDER - PIZQ
    blez t2, success #branch if PDER - PIZQ <= 0 //=> if PDER <= PIZQ
    addiu t2, t1, 0 #t2 = PPIVOT = PIZQ
    addiu t3, t1, 0 #t3 = PI = PIZQ
    addiu t4, t0, 0 #t4 = PJ = PDER
while: #while(PI < PJ)
    subu t5, t4, t3 #PJ - PI
    blez t5, end_while #branch if PJ - PI <= 0 //=> if PJ <= PI
while_i: #while(I <= PIVOT and PI < PDER)
    lbu t6, 0(t3) #t6 = I
    lbu t7, 0(t2) #t7 = PIVOT
    subu t5, t7, t6 #PIVOT - I
    bltz t5, while_j #branch if PIVOT - I < 0 //=> if PIVOT < I
    subu t5, t0, t3 #PDER - PI
    blez t5, while_j #branch if PDER - PI <= 0 //=> if PDER <= PI
    addiu t3, t3, 4 #i++ // PI + 4
    j while_i

while_j: #while(J > PIVOT)
    lbu t6, 0(t4) #t6 = J
    subu t5, t6, t7 #J - PIVOT
    blez t5, if_i_j #branch if J - PIVOT <= 0 //=> if J <= PIVOT
    subu t4, t4, 4 #j-- // PJ - 4
    j while_j

if_i_j: #if(i<j)
    subu t5, t4, t3 #PJ - PI
    blez t5, while #branch if PJ - PI <= 0 //=> if PJ <= PI
    lbu t6, 0(t3) #t6 = temp = I
    lbu t7, 0(t4) #t7 = J
    sb t7, 0(t3) #list[I] = list[J]
    sb t6, 0(t4) #list[J] = list[I] 
    j if_izq_der

end_while:
    lb t7, 0(t2) #t7 = PIVOT
    lb t6, 0(t4) #t6 = J
    sb t6, 0(t2) #list[PIVOT] = list[J]
    sb t7, 0(t4) #list[J] = list[PIVOT]
    addi a0, zero, 0
                #a2 = PI
    subu a1, t4, 4 #PJ -= 4 // PDER = PJ - 4
    jal mips_qsort #quicksort(num,PJ-1,PI)
    addu a2, t4, 4 #PJ += 4 // PDER = PJ + 4
                #a1 = PDER
    jal mips_qsort #quicksort(num,PDER,PJ + 1)
    addi a0, zero, 0

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
    lw ra, RA(sp)
    lw $fp, FP(sp) # loads mem(sp + FP) on $fp
    lw gp, GP(sp)  # loads mem(sp + GP) on gp
    addiu sp, sp, STACK_SZ  # pop stack pointer up
    ###############################################################

    jr ra
    
    .end mips_qsort

    .data
list: .byte 5, 2, 1, 0, 4, 3
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
