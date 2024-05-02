start:
        auipc   sp,0
        addi    sp, sp, 1024
        addi    sp, sp, 1024
        jal     ra,main 
        ebreak
loop:
        jal     zero,loop

check:
        beq     a0, zero, .L1
        jalr    zero,0(ra)      #ret
.L1:    
        ecall

main:
        addi    sp,sp,-4
        sw      ra,0(sp)
        auipc   s0,0
        
        addi    s0, zero, 128     #s0=2(*16*4)
        # for
        addi    s1,zero,0       # i=0
.Lfori1beg:    
        beq     s0,s1,.Lfori1end # i<2
        # for
        addi    s2,zero,0       # j=0
.Lforj1beg:
        beq     s0,s2,.Lforj1end # j<2
        # ms1=a[i,0]
        auipc   t0,0
        addi    t0, t0, 16
        add     t0,t0,s1        
        add     t0,t0,s1        # t0+=2*i
        sml     ms1, .m8x8a(t0) # ms1=m8x8a[t0]
        # ms2=b[0,j]
        auipc   t0,0
        addi    t0, t0, 12
        add     t0,t0,s2        # t0+=j
        sml     ms2, .m8x8b(t0) # ms2=m8x8b[t0]
        smmmp   ms0,ms1,ms2     # ms0=ms1 x ms2
        # ms1=a[i,1]
        auipc   t0,0
        addi    t0, t0, 20
        add     t0,t0,s1        
        add     t0,t0,s1        # t0+=2*i
        addi    t0,t0,64        # t0+=1
        sml     ms1, .m8x8a(t0) # ms1=m8x8a[t0]
        # ms2=b[1,j]
        auipc   t0,0
        addi    t0, t0, 16
        addi    t0,t0,128       # t0+=2
        add     t0,t0,s2        # t0+=j
        sml     ms2, .m8x8b(t0) # ms1=m8x8a[t0]
        smma    ms0,ms1,ms2,ms0 # ms0+=ms1 x ms2

        auipc   t0,0
        addi    t0,t0,20
        add     t0,t0,s1
        add     t0,t0,s1        # t0+=2*i
        add     t0,t0,s2        # t0+=j
        sms     ms0, .m8x8c(t0) # m8x8c[t0]=ms0

        addi    s2,s2,64        # j++
        jal     zero,.Lforj1beg
.Lforj1end:
        addi    s1,s1,64        # i++
        jal     zero,.Lfori1beg
.Lfori1end:

        auipc   t0,0
        addi    t0, t0, 8
        flw     fs1,.n1en2(t0)  # fs1=n1en5(-1e-5)
        auipc   t0,0
        addi    t0, t0, 8
        flw     fs2,.p1en2(t0)  # fs2=p1en2(+1e-5)

        addi    s0,zero,32       # 8(*4)
        # for
        addi    s1,zero,0       # i=0
.Lfori2beg:    
        beq     s0,s1,.Lfori2end # i<2
        # for
        addi    s2,zero,0       # j=0
.Lforj2beg:
        beq     s0,s2,.Lforj2end # j<2
        
        auipc   t0,0
        addi    t0, t0, 20
        slli    t1, s1, 3       # t1=8*i
        add     t0,t0,t1        # t0+=8*i
        add     t0,t0,s2        # t0+=j
        flw     ft1, .m8x8c(t0) # ft0=m8x8c[t0] V

        auipc   t0,0
        addi    t0, t0, 20
        slli    t1, s1, 3       # t1=8*i
        add     t0,t0,t1        # t0+=8*i
        add     t0,t0,s2        # t0+=j
        flw     ft2,.m8x8d(t0)  # ft1=m8x8d[t0] T

        fsub.s  ft0, ft2, ft1   # ft0=ft2-ft1 E=T-V
        # e=-0.005<=T&&T<=+0.005?E:E/T
        fle.s   t1,fs1,ft2      # t1=fs1<=ft2  -0.005<T
        fle.s   t2,ft2,fs2      # t2=ft2<=fs2  T<+0.005
        and     t0,t1,t2        # a0=t1&t2
        beq     t0,zero,.LTnz   # if a0==0 goto LTinnpe
        jal     zero,.LTez      # goto LTez
.LTnz:
        fdiv.s  ft0, ft0, ft2   # ft0=ft0/ft2 relative error
.LTez:
        fle.s   t3,fs1,ft0      # t3=fs1<ft0  -0.005<e
        fle.s   t4,ft0,fs2      # t4=ft0<fs2  e<0.005
        and     a0,t3,t4        # a0=t3&t4
        jal     ra,check        # check(a0)

        addi    s2,s2,4         # j++
        jal     zero,.Lforj2beg
.Lforj2end:
        addi    s1,s1,4         # i++
        jal     zero,.Lfori2beg
.Lfori2end:
        lw      ra,0(sp)
        addi    sp,sp,4
        jalr    zero,0(ra)      #ret
.n1en2:
        .word   -1146890486
.p1en2:
        .word   1000593162
.m8x8a:
.word   0
        .word   1065353216
        .word   1073741824
        .word   1077936128
        .word   1065353216
        .word   1073741824
        .word   1077936128
        .word   1082130432
        .word   1073741824
        .word   1077936128
        .word   1082130432
        .word   1084227584
        .word   1077936128
        .word   1082130432
        .word   1084227584
        .word   1086324736
        .word   1082130432
        .word   1084227584
        .word   1086324736
        .word   1088421888
        .word   1084227584
        .word   1086324736
        .word   1088421888
        .word   1090519040
        .word   1086324736
        .word   1088421888
        .word   1090519040
        .word   1091567616
        .word   1088421888
        .word   1090519040
        .word   1091567616
        .word   1092616192
        .word   1082130432
        .word   1084227584
        .word   1086324736
        .word   1088421888
        .word   1084227584
        .word   1086324736
        .word   1088421888
        .word   1090519040
        .word   1086324736
        .word   1088421888
        .word   1090519040
        .word   1091567616
        .word   1088421888
        .word   1090519040
        .word   1091567616
        .word   1092616192
        .word   1090519040
        .word   1091567616
        .word   1092616192
        .word   1093664768
        .word   1091567616
        .word   1092616192
        .word   1093664768
        .word   1094713344
        .word   1092616192
        .word   1093664768
        .word   1094713344
        .word   1095761920
        .word   1093664768
        .word   1094713344
        .word   1095761920
        .word   1096810496
.m8x8b:
        .word   0
        .word   -1082130432
        .word   -1073741824
        .word   -1069547520
        .word   1065353216
        .word   0
        .word   -1082130432
        .word   -1073741824
        .word   1073741824
        .word   1065353216
        .word   0
        .word   -1082130432
        .word   1077936128
        .word   1073741824
        .word   1065353216
        .word   0
        .word   -1065353216
        .word   -1063256064
        .word   -1061158912
        .word   -1059061760
        .word   -1069547520
        .word   -1065353216
        .word   -1063256064
        .word   -1061158912
        .word   -1073741824
        .word   -1069547520
        .word   -1065353216
        .word   -1063256064
        .word   -1082130432
        .word   -1073741824
        .word   -1069547520
        .word   -1065353216
        .word   1082130432
        .word   1077936128
        .word   1073741824
        .word   1065353216
        .word   1084227584
        .word   1082130432
        .word   1077936128
        .word   1073741824
        .word   1086324736
        .word   1084227584
        .word   1082130432
        .word   1077936128
        .word   1088421888
        .word   1086324736
        .word   1084227584
        .word   1082130432
        .word   0
        .word   -1082130432
        .word   -1073741824
        .word   -1069547520
        .word   1065353216
        .word   0
        .word   -1082130432
        .word   -1073741824
        .word   1073741824
        .word   1065353216
        .word   0
        .word   -1082130432
        .word   1077936128
        .word   1073741824
        .word   1065353216
        .word   0
.m8x8c:
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
        .word   0
.m8x8d:
        .word   1124859904
        .word   1121976320
        .word   1118306304
        .word   1113587712
        .word   1126694912
        .word   1124335616
        .word   1119879168
        .word   1114636288
        .word   1128529920
        .word   1125646336
        .word   1121452032
        .word   1115684864
        .word   1130364928
        .word   1126957056
        .word   1123024896
        .word   1116209152
        .word   1105199104
        .word   0
        .word   -1042284544
        .word   -1033895936
        .word   1103101952
        .word   -1052770304
        .word   -1035993088
        .word   -1029177344
        .word   1101004800
        .word   -1044381696
        .word   -1031274496
        .word   -1025507328
        .word   1098907648
        .word   -1039138816
        .word   -1028653056
        .word   -1022623744
        .word   1132199936
        .word   1128267776
        .word   1124335616
        .word   1116733440
        .word   1133248512
        .word   1129578496
        .word   1125122048
        .word   1117257728
        .word   1134166016
        .word   1130889216
        .word   1125908480
        .word   1117782016
        .word   1135083520
        .word   1132199936
        .word   1126694912
        .word   1118306304
        .word   1094713344
        .word   -1035993088
        .word   -1026031616
        .word   -1020788736
        .word   1090519040
        .word   -1032847360
        .word   -1023410176
        .word   -1018953728
        .word   1082130432
        .word   -1030750208
        .word   -1022099456
        .word   -1017118720
        .word   0
        .word   -1029177344
        .word   -1020788736
        .word   -1015283712