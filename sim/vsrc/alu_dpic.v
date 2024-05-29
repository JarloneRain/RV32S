import "DPI-C" function int fmadd_s(input int a,input int b,input int c);
import "DPI-C" function int fmsub_s(input int a,input int b,input int c);
import "DPI-C" function int fnmsub_s(input int a,input int b,input int c);
import "DPI-C" function int fnmadd_s(input int a,input int b,input int c);
import "DPI-C" function int fadd_s(input int a, input int b);
import "DPI-C" function int fsub_s(input int a, input int b);
import "DPI-C" function int fmul_s(input int a, input int b);
import "DPI-C" function int fdiv_s(input int a, input int b);
import "DPI-C" function int fsqrt_s(input int a);
import "DPI-C" function int fsgnj_s(input int a, input int b);
import "DPI-C" function int fsgnjn_s(input int a, input int b);
import "DPI-C" function int fsgnjx_s(input int a, input int b);
import "DPI-C" function int fmin_s(input int a, input int b);
import "DPI-C" function int fmax_s(input int a, input int b);
import "DPI-C" function int fcvt_w_s(input int a);
import "DPI-C" function int fcvt_wu_s(input int a);
// import "DPI-C" function int fmv_x_w(input int a);
import "DPI-C" function int feq_s(input int a, input int b);
import "DPI-C" function int flt_s(input int a, input int b);
import "DPI-C" function int fle_s(input int a, input int b);
import "DPI-C" function int fclass_s(input int a);
import "DPI-C" function int fcvt_s_w(input int a);
import "DPI-C" function int fcvt_s_wu(input int a);
// import "DPI-C" function int fmv_w_x(input int a);
//import "DPI-C" function void smmmp(input[511:0] a, input[511:0] b, output[511:0] res);
import "DPI-C" function void smmmp(
    input int a00,input int a01,input int a02,input int a03,
    input int a10,input int a11,input int a12,input int a13,
    input int a20,input int a21,input int a22,input int a23,
    input int a30,input int a31,input int a32,input int a33,
    input int b00,input int b01,input int b02,input int b03,
    input int b10,input int b11,input int b12,input int b13,
    input int b20,input int b21,input int b22,input int b23,
    input int b30,input int b31,input int b32,input int b33,
    output int res00,output int res01,output int res02,output int res03,
    output int res10,output int res11,output int res12,output int res13,
    output int res20,output int res21,output int res22,output int res23,
    output int res30,output int res31,output int res32,output int res33);
//import "DPI-C" function void smma(input[511:0] a, input[511:0] b, input[511:0] c, output[511:0] res);
import "DPI-C" function void smma(
    input int a00,input int a01,input int a02,input int a03,
    input int a10,input int a11,input int a12,input int a13,
    input int a20,input int a21,input int a22,input int a23,
    input int a30,input int a31,input int a32,input int a33,
    input int b00,input int b01,input int b02,input int b03,
    input int b10,input int b11,input int b12,input int b13,
    input int b20,input int b21,input int b22,input int b23,
    input int b30,input int b31,input int b32,input int b33,
    input int c00,input int c01,input int c02,input int c03,
    input int c10,input int c11,input int c12,input int c13,
    input int c20,input int c21,input int c22,input int c23,
    input int c30,input int c31,input int c32,input int c33,
    output int res00,output int res01,output int res02,output int res03,
    output int res10,output int res11,output int res12,output int res13,
    output int res20,output int res21,output int res22,output int res23,
    output int res30,output int res31,output int res32,output int res33);