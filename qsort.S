#include <mips/regdef.h>
#include <sys/syscall.h>

#define ASCII_0 48

#define BUFFER_SIZE 8192

#define STACK_SZ BUFFER_SIZE+56

#define A0 BUFFER_SIZE+56
#define FP BUFFER_SIZE+52
#define GP BUFFER_SIZE+48
#define SEED_IM BUFFER_SIZE+44
#define SEED_REAL BUFFER_SIZE+40
#define C BUFFER_SIZE+36
#define Y BUFFER_SIZE+32
#define X BUFFER_SIZE+28
#define SI BUFFER_SIZE+24
#define SR BUFFER_SIZE+20
#define ZI BUFFER_SIZE+16
#define ZR BUFFER_SIZE+12
#define CI BUFFER_SIZE+8
#define CR BUFFER_SIZE+4
#define BUFFER_LEN BUFFER_SIZE
#define BUFF 0

#define UPPER_LEFT_R_PARAM 0
#define UPPER_LEFT_I_PARAM 4
#define LOWER_RIGHT_R_PARAM 8
#define LOWER_RIGHT_I_PARAM 12
#define STEP_REAL_PARAM 16
#define STEP_IM_PARAM 20
#define SEED_REAL_PARAM 24
#define SEED_IM_PARAM 28
#define X_RES_PARAM 32
#define Y_RES_PARAM 36
#define SHADES_PARAM 40
#define FD_PARAM 44

    .text
    .abicalls
    .globl mips32_plot
    .ent mips32_plot


mips32_plot:
    
    #creo StackFrame

    #       |   a0    |
    #       |   fp    |
    #       |   gp    |
    #       |variables|
    #       |   ...   |
    #       |   ...   |
    #       |   ...   |
    #       | buff_len|
    #       | buffer  |

    subu sp, sp, STACK_SZ
    
    sw $fp, FP(sp) 
    sw gp, GP(sp)  
    
    move $fp, sp 

    sw a0, A0($fp) 
    
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

#--------------------------------------------------------------------------------
    # Inicio insercion del header en el buffer
    
    addiu t0, $fp, BUFF  # buff_addr on t0
    lw t1, BUFFER_LEN($fp)   # buff_len on t1

p2:
    li t2, 0            # i = 0
p2_loop:
    li t3, 3
    bge t2, t3, x_res   # terminar si i >= 3 
    la t3, header
    addu t3, t3, t2
    lb t3, 0(t3)        # header[i]
    addu t4, t0, t1
    sb t3, 0(t4)        # guardo header[i] en buff[buff_len]
    addiu t1, t1, 1     # buff_len++
    addiu t2, t2, 1     # i++
    j p2_loop

# X_res en buffer
x_res:
    lw t2, X_RES_PARAM(a0)      # guardo parms->x_res en t2
    move t7, t2                 
    li t3, 10
    li t4, -1                   # t4 = x_res_len
x_res_len:
    div t7, t3                  # x_res /= 10
    addi t4, t4, 1              # x_res_len++
    bne t7, zero, x_res_len     # hasta no llegar al ultimo digito, loop
    add t1, t1, t4              # empiezo desde el final
x_res_loop:
    div  t2, t3                 # x_res /= 10
    mflo t2
    mfhi t5                     # obtengo el resto en t5
    addi t5, t5, ASCII_0        # lo convierto a ASCII
    addu t6, t0, t1             # guardo el indice actual del buff en t6
    sb   t5, 0(t6)              # guardo x_res[i] en buff[buff_len]
    sub t1, t1, 1               # siguiente indice 
    bne  t2, zero, x_res_loop   
    add t1, t1, t4              # apunto el buffer al final
    addi t1, t1, 2              # hago lugar para el \n

    # Agrego \n
    la t2, line_break           
    lb t2, 0(t2)                
    addu t3, t0, t1
    sb t2, 0(t3)                
    addiu t1, t1, 1             

# Y_res en buffer
y_res:
    lw t2, Y_RES_PARAM(a0)
    move t7, t2             
    li t3, 10
    li t4, -1               
y_res_len:
    div t7, t3              
    addi t4, t4, 1          
    bne t7, zero, y_res_len 
    add t1, t1, t4          
y_res_loop:
    div  t2, t3             
    mflo t2
    mfhi t5                 
    addi t5, t5, ASCII_0    
    addu t6, t0, t1          
    sb   t5, 0(t6)          
    sub t1, t1, 1            
    bne  t2, zero, y_res_loop   
    add t1, t1, t4          
    addi t1, t1, 2          

    la t2, line_break   
    lb t2, 0(t2)      
    addu t3, t0, t1
    sb t2, 0(t3)      
    addiu t1, t1, 1     

# shades en buffer
shades:
    lw t2, SHADES_PARAM(a0)
    move t7, t2             
    li t3, 10
    li t4, -1               
shades_len:
    div t7, t3              
    addi t4, t4, 1          
    bne t7, zero, shades_len  
    add t1, t1, t4          
loop_shades:
    div  t2, t3             
    mflo t2
    mfhi t5                 
    addi t5, t5, ASCII_0    
    addu t6, t0, t1          
    sb   t5, 0(t6)          
    sub t1, t1, 1            
    bne t2, zero, loop_shades 
    add t1, t1, t4          
    addi t1, t1, 2          

    la t2, line_break   
    lb t2, 0(t2)      
    addu t3, t0, t1
    sb t2, 0(t3)      
    addiu t1, t1, 1     
    

    sw t1, BUFFER_LEN($fp)
 
# Fin header 
#----------------------------------------------------------
    

# Barrida del plano complejo entre (ULr,ULi) y (LRr,LRi)
# Usamos el punto (cr,ci) para iterar



    li t4, 0            # y = 0 en t4
    sw t4, Y($fp)

    lw t0, A0($fp) 
    l.s $f0, UPPER_LEFT_I_PARAM(t0)  # ci = parms->UL_im
    s.s $f0, CI($fp)

UL_im_loop:
    lw t4, Y($fp)  # y on t4

    lw t0, A0($fp) # parms on t0
    lw t6, Y_RES_PARAM(t0)  # parms->y_res on t6

    bge t4, t6, flush_end # if (y < parms->y_res) continue

    li t7, 0      # x = 0 on t7
    sw t7, X($fp)  # store x on mem($fp + X)

    l.s $f0, UPPER_LEFT_R_PARAM(t0)  # cr = parms->UL_re
    s.s $f0, CR($fp)

UL_re_loop:
    lw t7, X($fp)  # x on t7
    
    lw t0, A0($fp) # parms on t0   
    lw t6, X_RES_PARAM(t0)  # parms->x_res on t6
    bge t7, t6, UL_im_icr # if (x < parms->x_res) continue


    l.s $f0, CI($fp) # ci on f0
    mov.s $f2, $f0    # zi = ci 
    s.s $f2, ZI($fp)

    l.s $f1, CR($fp) # cr on f1 
    mov.s $f3, $f1    # zr = cr
    s.s $f3, ZR($fp)

    ###############################################################
    # Determinamos el nivel de brillo asociado al punto
    # (cr, ci), usando la fórmula compleja recurrente 
    # f = f^3 + c.

    li t9, 0              # c = 0 on t9
    sw t9, C($fp)
shades_loop:
    lw t0, A0($fp) # parms on t0
    lw t6, SHADES_PARAM(t0) # parms->shades on t6

    lw t9, C($fp)
    beq t9, t6, update_buffer # if (c < parms->shades) continue

    mul.s $f4, $f2, $f2   # zi * zi 
    mul.s $f5, $f3, $f3   # zr * zr

    add.s $f6, $f4, $f5   # absz =  zr**2 + zi**2
    li.s $f7, -4
    add.s $f6, $f6, $f7   # absz - 4 on t8 
    li.s $f8, 0
    c.le.s $f8, $f6
    bc1t update_buffer
    
    #### Save zr zi in stack
    s.s $f3, ZR($fp)
    s.s $f2, ZI($fp)
    ####
    
    # sr = zr*zr - zi*zi + cpr
    sub.s $f2, $f5, $f4   # zr**2 - zi**2 on t4
    l.s $f3, SEED_REAL($fp) 
    add.s $f2, $f2, $f3         # (zr**2 - zi**2) + cpr
    s.s $f2, SR($fp) # save sr in stack
    
    #### Restore zr zi
    l.s $f3, ZR($fp)
    l.s $f2, ZI($fp)
    ####
    
    # si = 2 * zr * zi + cpi
    mul.s $f4, $f2, $f3   # (zr * zi)
    li.s $f5, 2
    mul.s $f4, $f4, $f5
    l.s $f5, SEED_IM($fp)
    add.s $f4, $f4, $f5         # (2*zr*zi) + cpi
    s.s $f4, SI($fp) # save si in stack

    l.s $f3, SR($fp) # zr = sr
    l.s $f2, SI($fp) # zi = si

    addi t9, t9, 1        # ++c
    sw t9, C($fp)  # save c in stack
    j shades_loop

    ###############################################################

update_buffer:
    lw t1, BUFFER_LEN($fp) # buff_len on t1
    
    # Hay lugar para 2 bytes en el buffer?
    li t4, BUFFER_SIZE
    subu t4, t4, t1       # BUFFER_SIZE - buff_len
    li t5, 4
    bge t4, t5, store_shade   # if (BUFFER_SIZE - buff_len >= 4) KB!! store
    
write_buffer:  
  li v0, SYS_write      # system call for write to file
  lw t0, A0($fp)
  lw t0, FD_PARAM(t0)
  lh a0, 14(t0) 
  addiu a1, $fp, BUFF  # address of buffer from which to write
  lw a2, BUFFER_LEN($fp) # buffer length
  syscall           # write to file
  bltz v0, io_error     # if v0 < 0, io error

  sw zero, BUFFER_LEN($fp) # reset buffer
  
store_shade:
    addiu t1, $fp, BUFF  # buff_addr on t1
    lw t2, BUFFER_LEN($fp) # buff_len on t2
    lw t3, C($fp)    # recover c from stack
    move t4, t3
    li t5, 10
    li t6, -1                   # t6 = shade_len
shade_len:
    div t4, t5                  # shade /= 10
    addi t6, t6, 1              # shade_len++
    bnez t4, shade_len          # if shade != 0, loop
    add t2, t2, t6              # start at the end
loop_shade:
    div t3, t5                  # shade /= 10
    mflo t3
    mfhi t7                     # get remainder
    addi t7, t7, ASCII_0    # ascii conversion
    addu t8, t1, t2             # t8 = buff_addr (t1) + buff_len (t2) 
    sb t7, 0(t8)                # store it
    sub t2, t2, 1               # adjust buf ptr
    bnez t3, loop_shade         # if c != 0, loop 
    add t2, t2, t6              # correct buf ptr so it point at shade end
    addi t2, t2, 2              # two more so \n doesnt overwrite last char
   
    la t3, line_break
    lb t3, 0(t3)
    addu t4, t1, t2
    sb t3, 0(t4)        # buff_addr[buff_len] = \n
    addiu t2, t2, 1       # buff_len++
    
    sw t2, BUFFER_LEN($fp) # update buff_len on stack

UL_re_icr:
    lw t7, X($fp)
    addi t7, t7, 1    # ++x
    sw t7, X($fp)  # store x on mem($fp + X)
    
    l.s $f1, CR($fp)
    l.s $f4, STEP_REAL_PARAM(t0) # parms->d_re on t6
    add.s $f1, $f1, $f4   # cr += parms->d_re
    s.s $f1, CR($fp) # store cr on mem($fp + CR)
    j UL_re_loop

UL_im_icr:
    lw t4, Y($fp)
    addi t4, t4, 1    # ++y
    sw t4, Y($fp)  # store y on mem($fp + Y)
    
    l.s $f4, STEP_IM_PARAM(t0) # parms->d_im on t6
    l.s $f0, CI($fp)
    sub.s $f0, $f0, $f4   # ci -= parms->d_im
    s.s $f0, CI($fp) # store ci on mem($fp + CI)
    j UL_im_loop

flush_end:
  li v0, SYS_write      # system call for write to file
  lw t0, A0($fp)
  lw t0, FD_PARAM(t0)
  lh a0, 14(t0)
  addiu a1, $fp, BUFF  # address of buffer from which to write
  lw a2, BUFFER_LEN($fp) # buffer length
  syscall           # write to file
  bltz v0, io_error     # if v0 < 0, io error
    j success

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
    move sp, $fp
    lw $fp, FP(sp) # loads mem(sp + FP) on $fp
    lw gp, GP(sp)  # loads mem(sp + GP) on gp
    addiu sp, sp, STACK_SZ  # pop stack pointer up
    ###############################################################

    jr ra
    
    .end mips32_plot

    .data
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
