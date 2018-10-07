#include <mips/regdef.h>
#include <sys/syscall.h>

#define ASCII_0 48

#define ABA_SZ 16
#define LTA_SZ 8
#define SRC_SZ 16
#define STACK_SZ (ABA_SZ + LTA_SZ + SRC_SZ)
#define NUM 0
#define DER 4
#define IZQ 8
#define LTA_PJ 16
#define GP 24
#define FP 28
#define RA 32
#define NUM_CALLER STACK_SZ 
#define DER_CALLER (STACK_SZ + 4)
#define IZQ_CALLER (STACK_SZ + 8)

    .text
    .align 2
    .abicalls
    .globl mips_qsort
    .ent mips_qsort




mips_qsort:
    #creo StackFrame
    #       | der caller | 44(sp)
    #       | num caller | 40(sp)
    #        ____________
    #       |   padding  | 36
    #       |     ra     | 32
    #       |     fp     | 28
    #       |     gp     | 24
    #       |   padding  | 20
    #       |   LTA PJ   | 16
    #       |   padding  | 12
    #       |     izq    | 8
    #       |     der    | 4(sp)
    #       |     num    | 0








    subu sp, sp, STACK_SZ
    
    sw ra, RA(sp)
    sw $fp, FP(sp) 
    sw gp, GP(sp)  
    # Fin StackFrame 
    #a1 = Puntero a Der, ultimo, PDER 
    #a2 = Puntero a Izq, primero, PIZQ
    #t0 = PPIVOT
    #t1 = PI
    #t2 = PJ
    #t3 = 
    #t4
    #t5 comparaciones
    #t6 temp
    #t7 temp

    sw a0, NUM_CALLER(sp) #Guardo los parametros en el ABA del caller
    sw a1, DER_CALLER(sp) #a1 = Puntero a Der ultimo 
    sw a2, IZQ_CALLER(sp) #a2 = Puntero a Izq primero

if_izq_der: #if(first<last)
    subu t5, a1, a2 #PDER - PIZQ
    blez t5, return #branch if PDER - PIZQ <= 0 //=> if PDER <= PIZQ
    lw t0, 0(a2) #t0 = PPIVOT = PIZQ
    lw t1, 0(a2) #t1 = PI = PIZQ
    lw t2, 0(a1) #t2 = PJ = PDER
while: #while(PI < PJ)
    subu t5, t2, t1 #PJ - PI
    blez t5, end_while #branch if PJ - PI <= 0 //=> if PJ <= PI
while_i: #while(I <= PIVOT and PI < PDER)
   lbu t6, 0(t3) #t6 = I
   lbu t7, 0(t2) #t7 = PIVOT
   subu t5, t7, t6 #PIVOT - I
#

#    j atoi_i
#atoi_i_r:
#    addiu t6, t5, 0 #t6 I en atoi
#    j atoi_p
#atoi_p_r:
#    addiu t7, t5, 0 #t7 PIVOT en atoi
    subu t5, t7, t6 #PIVOT - I
    bltz t5, while_j #branch if PIVOT - I < 0 //=> if PIVOT < I
    subu t5, a1, t1 #PDER - PI
    blez t5, while_j #branch if PDER - PI <= 0 //=> if PDER <= PI
    addiu t1, t1, 4 #i++ // PI + 4
    j while_i

while_j: #while(J > PIVOT)
    lbu t6, 0(t2) #t6 = J
    lbu t7, 0(t0) #t7 = PIVOT
    subu t5, t6, t7 #J - PIVOT
    blez t5, if_i_j #branch if J - PIVOT <= 0 //=> if J <= PIVOT
    subu t2, t2, 4 #j-- // PJ - 4
    j while_j

if_i_j: #if(i<j)
    subu t5, t2, t1 #PJ - PI
    blez t5, while #branch if PJ - PI <= 0 //=> if PJ <= PI
    lbu t6, 0(t1) #t6 = temp = I
    lbu t7, 0(t2) #t7 = J
    sb t7, 0(t1) #list[I] = list[J]
    sb t6, 0(t2) #list[J] = list[I] 
    j if_izq_der

end_while:
    lbu t7, 0(t0) #t7 = PIVOT
    lbu t6, 0(t2) #t6 = J
    sb t6, 0(t0) #list[PIVOT] = list[J]
    sb t7, 0(t2) #list[J] = list[PIVOT]
    sw t2, LTA_PJ(sp) #Guardo PJ en LTA para que lo use la segunda func recur
                #a2 = PI
    subu a1, t2, 4 #PJ -= 4 // PDER = PJ - 4
    jal mips_qsort #quicksort(num,PJ - 4,PI)
    lw a1, DER_CALLER(sp) #a1 = PDER
    lw t2, LTA_PJ(sp) #Busco PJ en LTA
    addiu a2, t2, 4 #PJ += 4 // PDER = PJ + 4
    jal mips_qsort #quicksort(num,PDER,PJ + 4)
    j return

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

atoi_i: #t1 = PI
    li t5, 0 #t5 = 0 // t5 = num
while_atoi_i:
    lbu t3, 0(t1) #t3 = PI[0] Primer numero de I
    beqz t1, atoi_i_r
    muli t5, t5, 10 #t5 = t5 * 10
    subi t3, t3, 48 #t3 = t3 - 48
    add t5, t5, t3
    add t1, t1, 4
    j while_atoi_i

atoi_p: #t0 = PPIVOT
    li t5, 0 #t5 = 0 // t5 = num
while_atoi_p:
    lbu t3, 0(t0) #t3 = PPIVOT[0] Primer numero de PIVOT
    beqz t0, atoi_p_r
    muli t5, t5, 10 #t5 = t5 * 10
    subi t3, t3, 48 #t3 = t3 - 48
    add t5, t5, t3
    add t0, t0, 1
    j while_atoi_p

    .end mips_qsort

    .data

list: .byte 0, 3 #5, 2, 1, 0, 4, 3 esto iba con:  addiu t0, t1, 5
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
