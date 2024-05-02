start:
        auipc   sp,0
        addi    sp, sp, 1024
        jal     ra,main 
        ebreak
loop:
        jal     zero,loop
main:
        jalr    zero,0(ra)