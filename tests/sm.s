start:
        auipc   sp,0
        addi    sp, sp, 1024
        addi    sp, sp, 1024
        jal     ra,main 
        ebreak
loop:
        jal     zero,loop

main:
        addi    sp,sp,-4
        sw      ra,0(sp)

        auipc   a5,0
        addi    a5,a5,8
        sml     ms1,.matrix(a5)
        addi    a5,a5,8
        sml     ms2,.matrix(a5)
        addi    a5,a5,8
        sml     ms3,.matrix(a5)

        smmmp   ms0,ms1,ms2
        auipc   a5,0
        addi    a5,a5,8
        sms     ms0,.matrix(a5)

        smma    ms0,ms1,ms2,ms3

        lw      ra,0(sp)
        addi    sp,sp,4
        jalr    zero,0(ra)

.matrix:
        .word   0
        .word   1065353216
        .word   1073741824
        .word   1077936128
        .word   1082130432
        .word   1084227584
        .word   1086324736
        .word   1088421888
        .word   1090519040
        .word   1091567616
        .word   1092616192
        .word   1093664768
        .word   1094713344
        .word   1095761920
        .word   1096810496
        .word   1097859072