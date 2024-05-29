#include <stdint.h>
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <svdpi.h>

extern "C" uint fmadd_s(uint a, uint b, uint c)
{
    float fa = *(float *)&a, fb = *(float *)&b, fc = *(float *)&c;
    float fres = fa * fb + fc;
    return *(uint *)&fres;
}

extern "C" uint fmsub_s(uint a, uint b, uint c)
{
    float fa = *(float *)&a, fb = *(float *)&b, fc = *(float *)&c;
    float fres = fa * fb - fc;
    return *(uint *)&fres;
}

extern "C" uint fnmsub_s(uint a, uint b, uint c)
{
    float fa = *(float *)&a, fb = *(float *)&b, fc = *(float *)&c;
    float fres = -(fa * fb) + fc;
    return *(uint *)&fres;
}

extern "C" uint fnmadd_s(uint a, uint b, uint c)
{
    float fa = *(float *)&a, fb = *(float *)&b, fc = *(float *)&c;
    float fres = -(fa * fb) - fc;
    return *(uint *)&fres;
}

extern "C" uint fadd_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = fa + fb;
    return *(uint *)&fres;
}

extern "C" uint fsub_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = fa - fb;
    return *(uint *)&fres;
}

extern "C" uint fmul_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = fa * fb;
    return *(uint *)&fres;
}

extern "C" uint fdiv_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = fa / fb;
    return *(uint *)&fres;
}

extern "C" uint fsqrt_s(uint a)
{
    float fa = *(float *)&a;
    float fres = sqrt(fa);
    return *(uint *)&fres;
}

extern "C" uint fsgnj_s(uint a, uint b)
{
    return (a & 0x7fffffff) | (b & 0x80000000);
}

extern "C" uint fsgnjn_s(uint a, uint b)
{
    return (a & 0x7fffffff) | (~b & 0x80000000);
}

extern "C" uint fsgnjx_s(uint a, uint b)
{
    return (a & 0x7fffffff) ^ (b & 0x80000000);
}

extern "C" uint fmin_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = (fa < fb) ? fa : fb;
    return *(uint *)&fres;
}

extern "C" uint fmax_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    float fres = (fa > fb) ? fa : fb;
    return *(uint *)&fres;
}

extern "C" uint fcvt_w_s(uint a)
{
    printf("fcvt.w.s not implemented\n");
    return 0;
}

extern "C" uint fcvt_wu_s(uint a)
{
    printf("fcvt.wu.s not implemented\n");
    return 0;
}

// extern "C" uint fmv_x_w(uint a)
// {
//     return a;
// }

extern "C" uint feq_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    return fa == fb;
}

extern "C" uint flt_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    return fa < fb;
}

extern "C" uint fle_s(uint a, uint b)
{
    float fa = *(float *)&a, fb = *(float *)&b;
    return fa <= fb;
}

extern "C" uint fclass_s(uint a)
{
    printf("fclass.s not implemented\n");
    return 0;
}

extern "C" uint fcvt_s_w(uint a)
{
    printf("fcvt.s.w not implemented\n");
    return 0;
}

extern "C" uint fcvt_s_wu(uint a)
{
    printf("fcvt.s.wu not implemented\n");
    return 0;
}
// extern "C" uint fmv_w_x(uint a)
// {
//     return a;
// }

extern "C" void smmmp(
    uint a00, uint a01, uint a02, uint a03,
    uint a10, uint a11, uint a12, uint a13,
    uint a20, uint a21, uint a22, uint a23,
    uint a30, uint a31, uint a32, uint a33,
    uint b00, uint b01, uint b02, uint b03,
    uint b10, uint b11, uint b12, uint b13,
    uint b20, uint b21, uint b22, uint b23,
    uint b30, uint b31, uint b32, uint b33,
    uint *res00, uint *res01, uint *res02, uint *res03,
    uint *res10, uint *res11, uint *res12, uint *res13,
    uint *res20, uint *res21, uint *res22, uint *res23,
    uint *res30, uint *res31, uint *res32, uint *res33)
{
    float ma[4][4] = {
        {*(float *)&a00, *(float *)&a01, *(float *)&a02, *(float *)&a03}, //
        {*(float *)&a10, *(float *)&a11, *(float *)&a12, *(float *)&a13}, //
        {*(float *)&a20, *(float *)&a21, *(float *)&a22, *(float *)&a23}, //
        {*(float *)&a30, *(float *)&a31, *(float *)&a32, *(float *)&a33}  //
    },
          mb[4][4] = {
              {*(float *)&b00, *(float *)&b01, *(float *)&b02, *(float *)&b03}, //
              {*(float *)&b10, *(float *)&b11, *(float *)&b12, *(float *)&b13}, //
              {*(float *)&b20, *(float *)&b21, *(float *)&b22, *(float *)&b23}, //
              {*(float *)&b30, *(float *)&b31, *(float *)&b32, *(float *)&b33}  //
          },
          mres[4][4];
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            mres[i][j] = 0;
            for (int k = 0; k < 4; k++)
            {
                mres[i][j] += ma[i][k] * mb[k][j];
            }
        }
    }
    *res00 = *(uint *)&mres[0][0];
    *res01 = *(uint *)&mres[0][1];
    *res02 = *(uint *)&mres[0][2];
    *res03 = *(uint *)&mres[0][3];
    *res10 = *(uint *)&mres[1][0];
    *res11 = *(uint *)&mres[1][1];
    *res12 = *(uint *)&mres[1][2];
    *res13 = *(uint *)&mres[1][3];
    *res20 = *(uint *)&mres[2][0];
    *res21 = *(uint *)&mres[2][1];
    *res22 = *(uint *)&mres[2][2];
    *res23 = *(uint *)&mres[2][3];
    *res30 = *(uint *)&mres[3][0];
    *res31 = *(uint *)&mres[3][1];
    *res32 = *(uint *)&mres[3][2];
    *res33 = *(uint *)&mres[3][3];
}

extern "C" void smma(
    uint a00, uint a01, uint a02, uint a03,
    uint a10, uint a11, uint a12, uint a13,
    uint a20, uint a21, uint a22, uint a23,
    uint a30, uint a31, uint a32, uint a33,
    uint b00, uint b01, uint b02, uint b03,
    uint b10, uint b11, uint b12, uint b13,
    uint b20, uint b21, uint b22, uint b23,
    uint b30, uint b31, uint b32, uint b33,
    uint c00, uint c01, uint c02, uint c03,
    uint c10, uint c11, uint c12, uint c13,
    uint c20, uint c21, uint c22, uint c23,
    uint c30, uint c31, uint c32, uint c33,
    uint *res00, uint *res01, uint *res02, uint *res03,
    uint *res10, uint *res11, uint *res12, uint *res13,
    uint *res20, uint *res21, uint *res22, uint *res23,
    uint *res30, uint *res31, uint *res32, uint *res33)
{
    float ma[4][4] = {
        {*(float *)&a00, *(float *)&a01, *(float *)&a02, *(float *)&a03}, //
        {*(float *)&a10, *(float *)&a11, *(float *)&a12, *(float *)&a13}, //
        {*(float *)&a20, *(float *)&a21, *(float *)&a22, *(float *)&a23}, //
        {*(float *)&a30, *(float *)&a31, *(float *)&a32, *(float *)&a33}  //
    },
          mb[4][4] = {
              {*(float *)&b00, *(float *)&b01, *(float *)&b02, *(float *)&b03}, //
              {*(float *)&b10, *(float *)&b11, *(float *)&b12, *(float *)&b13}, //
              {*(float *)&b20, *(float *)&b21, *(float *)&b22, *(float *)&b23}, //
              {*(float *)&b30, *(float *)&b31, *(float *)&b32, *(float *)&b33}  //
          },
          mc[4][4] = {
              {*(float *)&c00, *(float *)&c01, *(float *)&c02, *(float *)&c03}, //
              {*(float *)&c10, *(float *)&c11, *(float *)&c12, *(float *)&c13}, //
              {*(float *)&c20, *(float *)&c21, *(float *)&c22, *(float *)&c23}, //
              {*(float *)&c30, *(float *)&c31, *(float *)&c32, *(float *)&c33}  //
          },
          mres[4][4];
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            mres[i][j] = 0;
            for (int k = 0; k < 4; k++)
            {
                mres[i][j] += ma[i][k] * mb[k][j];
            }
            mres[i][j] += mc[i][j];
        }
    }
    *res00 = *(uint *)&mres[0][0];
    *res01 = *(uint *)&mres[0][1];
    *res02 = *(uint *)&mres[0][2];
    *res03 = *(uint *)&mres[0][3];
    *res10 = *(uint *)&mres[1][0];
    *res11 = *(uint *)&mres[1][1];
    *res12 = *(uint *)&mres[1][2];
    *res13 = *(uint *)&mres[1][3];
    *res20 = *(uint *)&mres[2][0];
    *res21 = *(uint *)&mres[2][1];
    *res22 = *(uint *)&mres[2][2];
    *res23 = *(uint *)&mres[2][3];
    *res30 = *(uint *)&mres[3][0];
    *res31 = *(uint *)&mres[3][1];
    *res32 = *(uint *)&mres[3][2];
    *res33 = *(uint *)&mres[3][3];
}