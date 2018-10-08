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
    #a1 = Puntero a Der, ultimo, PDER (**DER)
    #a2 = Puntero a Izq, primero, PIZQ (**IZQ)
    #t0 = PPIVOT (**PIVOT)
    #t1 = PI (**i)
    #t2 = PJ (**j)
    #t3 = Puntero: Primer valor para comparar
    #t4 = Puntero: Segundo valor para comparar
    #t5 comparaciones
    #t6 temp y comparar
    #t7 temp y comparar
    #t8 atoi
    #t9 atoi
    #v0 return atoi
    #v1 en atoi vuelve a primer numero o segundo
    #v2 while_i / while_j

    addiu a2, zero, 1
    sw a2, NUM_CALLER(sp) #Guardo los parametros en el ABA del caller// num == 0 -> string
    sw a1, DER_CALLER(sp) #a1 = Puntero a String Der, ultimo string 
    sw a0, IZQ_CALLER(sp) #a0 = Puntero a String Izq, primer string

if_izq_der: #if(first<last)
    subu t5, a1, a0 #PDER - PIZQ
    blez t5, return #branch if PDER - PIZQ <= 0 //=> if PDER <= PIZQ
    lw t0, 0(a0) #t0 = PPIVOT = PIZQ
    lw t1, 0(a0) #t1 = PI = PIZQ // PI es el puntero al String I
    lw t2, 0(a1) #t2 = PJ = PDER // PJ es el puntero al String J
while: #while(PI < PJ)
    subu t5, t2, t1 #PJ - PI
    blez t5, end_while #branch if PJ - PI <= 0 //=> if PJ <= PI
while_i: #while(I <= PIVOT and PI < PDER)
    addi t3, t0, 0 #t3 = PI (**i)
    addi t4, t1, 0 #t4 = PPIVOT (**PIVOT)
    addiu v2, zero, 0 #v2 = 0 volver a n_compare_while_i
    j compare # PIVOT - I
n_compare_while_i:
    bltz t5, while_j #branch if PIVOT - I < 0 //=> if PIVOT < I
    subu t5, a1, t1 #PDER - PI
    blez t5, while_j #branch if PDER - PI <= 0 //=> if PDER <= PI
    addiu t1, t1, 4 #i++ // PI + 4
    j while_i

while_j: #while(J > PIVOT)
    addi t3, t0, 0 #t3 = PPIVOT
    addi t4, t2, 0 #t4 = PJ
    addiu v2, zero, 1 #v2 = 1 volver a n_compare_while_j
    j compare # J - PIVOT
n_compare_while_j:
    blez t5, if_i_j #branch if J - PIVOT <= 0 //=> if J <= PIVOT
    subu t2, t2, 4 #j-- // PJ - 4
    j while_j

if_i_j: #if(i<j) 
    subu t5, t2, t1 #PJ(**j) - PI(**i)
    blez t5, while #branch if PJ - PI <= 0 //=> if PJ <= PI
    lw t6, 0(t1) #t = *i // t6 = *i
    lw t7, 0(t2) #t7 = *j
    sw t7, 0(t1) # *i = *j
    sw t6, 0(t2) # *j = *i
    j if_izq_der

end_while:
    lw t7, 0(t0) #t7 = *PIVOT
    lw t6, 0(t2) #t6 = *j
    sw t6, 0(t0) #*PIVOT = *j
    sw t7, 0(t2) #*j = *PIVOT
    sw t2, LTA_PJ(sp) #Guardo PJ en LTA para que lo use la segunda func recur
                #a0 = PI
    subu a1, t2, 4 #PJ -= 4 // PDER = PJ - 4
    jal mips_qsort #quicksort(num,PJ - 4,PI)
    lw a1, DER_CALLER(sp) #a1 = PDER
    lw t2, LTA_PJ(sp) #Busco PJ en LTA
    addiu a0, t2, 4 #PJ += 4 // PDER = PJ + 4
    jal mips_qsort #quicksort(num,PDER,PJ + 4)
    j return


compare:
    beqz a0, string_compare
    j number_compare
end_compare:
    beqz v2, n_compare_while_i
    j n_compare_while_j


string_compare: #t4 < t3 => t5 = -1 
    lw t9, 0(t3) #t9 = Puntero al primer valor a comparar (*i)
    lw t8, 0(t4) #t8 = Puntero al segundo valor a comparar (*i)
while_string_compare:
    lbu t7, 0(t9) #t7 = letra de t3
    lbu t6, 0(t8) #t6 = letra de t4  
    beqz t7, second_is_less #letra del segundo es zero entonces es menor
    beqz t6, first_is_less #letra del primero es zero entonces es menor
    subu t5, t6, t7 #resta segunda letra - primera letra   
    addiu t7, t7, 4
    addiu t6, t6, 4
    beqz t5, while_string_compare
    bgtz t5, first_is_less
    j second_is_less
first_is_less:
    addiu t5, zero, 1
    j end_compare
second_is_less:
    addi t5, zero, -1
    j end_compare


number_compare:
    addiu v1, zero, 0
    lw t8, 0(t3) #t8 = Puntero al primer valor a comparar (*i)
    j atoi
first_compare:
    addiu t6, v0, 0 #numero de t3
    lw t8, 0(t4) #t8 = Puntero al segundo valor a comparar (*i)
    addiu v1, zero, 1
    j atoi
second_comapre:
    addi t7, v0, 0 #numero de t4
    subu t5, t7, t6 #numero de t4 - numero de t3
    j end_compare


atoi: #
    li t5, 0 #t5 = 0 // t5 = num
while_atoi:
    lbu t9, 0(t8) #t9 = Primer numero
    beqz t9, end_atoi
    mult t5, t5, 10 #t5 = t5 * 10
    subi t9, t9, 48 #t3 = t3 - 48
    addu t5, t5, t9
    addiu t8, t8, 4
    j while_atoi_i
end_atoi:
    addiu v0, t5, 0
    beqz v1, first_compare
    j second_comapre


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

list: .byte 0, 3 #5, 2, 1, 0, 4, 3 esto iba con:  addiu t0, t1, 5
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
