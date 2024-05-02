start:
        auipc   sp,0
        addi    sp, sp, 1024
        jal     ra,main 
        ebreak
loop:
        jal     zero,loop
arra:
        .word   1065353216
        .word   1073741824
        .word   -1069547520
arrb:
        .word   1065353216
        .word   -1073741824
        .word   -1069547520
ans:
        .word   1073741824
        .word   0
        .word   -1061158912
check:
        beq     a0, zero, .L1
        jalr    zero,0(ra)      #ret
.L1:    
        ecall
fadd:
        fadd.s  fa0,fa1,fa2
        jalr    a0, 0(ra)
main:
        addi    sp,sp,-4
        sw      ra, 0(sp)
        auipc   a5,0
        addi    a5,a5,8
        flw     fs0,.LC0(a5)    # fs0=-1e-5
        auipc   a5,0
        addi    a5,a5,8
        flw     fs1,.LC1(a5)    # fs1=1e-5
        addi    s0,zero,0       # i=0
        addi    s1,zero,12      
.L3:
        beq     s0,s1,.L2       # if(i==3) goto .L2
        auipc   a5,0
        addi    a5,a5,12
        add     a5,a5,s0
        flw     fa1,arra(a5)    # fa1=arra[i]
        auipc   a5,0
        addi    a5,a5,12
        add     a5,a5,s0
        flw     fa2,arrb(a5)    # fa2=arrb[i]
        jal     ra,fadd         # fa0=fadd(fa1,fa2)
        auipc   a5,0
        addi    a5,a5,12
        add     a5,a5,s0
        flw     fa3,ans(a5)     # fa3=arrb[i]
        fsub.s  fa0,fa0,fa3     # fa0-=fa3
        flt.s   t0,fs0,fa0      # t0=fs0<fa0
        flt.s   t1,fa0,fs1      # t1=fa0<fs1
        and     a0,t0,t1
        jal     ra,check        # check(t1&&t2)
        addi    s0,s0,4         # i++
        jal     zero,.L3        # goto .L3
.L2:    
        lw      ra,0(sp)
        addi    sp,sp,4
        jalr    zero,0(ra)
.LC0:
        .word   -1222130260
.LC1:
        .word   925353388