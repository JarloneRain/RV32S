using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace Ass;

static class TypeTable
{
    public enum InstTypeEnum { D, U, I, O, E, S, R, B, J, R4, P_WORD, Y }

    public static readonly Dictionary<uint, InstTypeEnum> InstType = new()
    {
        #region I
        [0b0110111] = InstTypeEnum.U,
        [0b0010111] = InstTypeEnum.U,
        [0b1101111] = InstTypeEnum.J,
        [0b1100111] = InstTypeEnum.O,//jalr
        [0b1100011] = InstTypeEnum.B,
        [0b0000011] = InstTypeEnum.O,//l(w,h,b,hu,bu)
        [0b0100011] = InstTypeEnum.S,
        [0b0010011] = InstTypeEnum.I,
        [0b0110011] = InstTypeEnum.R,
        [0b0001111] = InstTypeEnum.I,
        [0b1110011] = InstTypeEnum.E,
        #endregion
        #region F
        [0b0000111] = InstTypeEnum.O,   //flw
        [0b0100111] = InstTypeEnum.S,
        [0b1000011] = InstTypeEnum.R4,
        [0b1000111] = InstTypeEnum.R4,
        [0b1001011] = InstTypeEnum.R4,
        [0b1001111] = InstTypeEnum.R4,
        [0b1010011] = InstTypeEnum.R,
        #endregion
        #region S
        [0b1010111] = InstTypeEnum.Y,
        [0b1011011] = InstTypeEnum.R,
        [0b1011111] = InstTypeEnum.R4,
        [0b1111011] = InstTypeEnum.O,   //sml(d)
        [0b1111111] = InstTypeEnum.S,
        #endregion
    };

}

static class InstTable
{
    public static readonly Dictionary<string, uint> InstCode = new()
    {
        [".word"] = 0u,
        #region I
        ["add"] = 0b00000000000000000000000000110011,
        ["and"] = 0b00000000000000000111000000110011,
        ["auipc"] = 0b00000000000000000000000000010111,
        ["addi"] = 0b00000000000000000000000000010011,
        ["andi"] = 0b00000000000000000111000000010011,

        ["beq"] = 0b00000000000000000000000001100011,
        ["bne"] = 0b00000000000000000001000001100011,
        ["blt"] = 0b00000000000000000100000001100011,
        ["bge"] = 0b00000000000000000101000001100011,
        ["bltu"] = 0b00000000000000000110000001100011,
        ["bgeu"] = 0b00000000000000000111000001100011,

        ["ebreak"] = 0b00000000000100000000000001110011,
        ["ecall"] = 0b00000000000000000000000001110011,
        ["fence"] = 0b00000000000000000000000000001111,

        ["jal"] = 0b00000000000000000000000001101111,
        ["jalr"] = 0b00000000000000000000000001100111,

        ["lb"] = 0b00000000000000000000000000000011,
        ["lh"] = 0b00000000000000000001000000000011,
        ["lbu"] = 0b00000000000000000100000000000011,
        ["lhu"] = 0b00000000000000000101000000000011,
        ["lw"] = 0b00000000000000000010000000000011,

        ["lui"] = 0b00000000000000000000000000110111,

        ["ori"] = 0b00000000000000000110000000010011,
        ["or"] = 0b00000000000000000110000000110011,

        ["sb"] = 0b00000000000000000000000000100011,
        ["sh"] = 0b00000000000000000001000000100011,
        ["sw"] = 0b00000000000000000010000000100011,

        ["slli"] = 0b00000000000000000001000000010011,
        ["srli"] = 0b00000000000000000101000000010011,
        ["srai"] = 0b01000000000000000101000000010011,

        ["slti"] = 0b00000000000000000010000000010011,
        ["sltiu"] = 0b00000000000000000011000000010011,

        ["sll"] = 0b00000000000000000001000000110011,
        ["slt"] = 0b00000000000000000010000000110011,
        ["sltu"] = 0b00000000000000000011000000110011,
        ["srl"] = 0b00000000000000000101000000110011,
        ["sra"] = 0b01000000000000000101000000110011,
        ["sub"] = 0b01000000000000000000000000110011,
        ["xor"] = 0b00000000000000000100000000110011,

        ["xori"] = 0b00000000000000000100000000010011,
        #endregion

        #region F
        ["flw"] = 0b00000000000000000010000000000111,
        ["fsw"] = 0b00000000000000000010000000100111,
        ["fmadd.s"] = 0b00000000000000000000000001000011,
        ["fmsub.s"] = 0b00000000000000000000000001000111,
        ["fnmsub.s"] = 0b00000000000000000000000001001011,
        ["fnmadd.s"] = 0b00000000000000000000000001001111,
        ["fadd.s"] = 0b00000000000000000000000001010011,
        ["fsub.s"] = 0b00001000000000000000000001010011,
        ["fmul.s"] = 0b00010000000000000000000001010011,
        ["fdiv.s"] = 0b00011000000000000000000001010011,
        ["fsqrt.s"] = 0b01011000000000000000000001010011,
        ["fsgnj.s"] = 0b00100000000000000000000001010011,
        ["fsgnjn.s"] = 0b00100000000000000001000001010011,
        ["fsgnjx.s"] = 0b00100000000000000010000001010011,
        ["fmin.s"] = 0b00101000000000000000000001010011,
        ["fmax.s"] = 0b00101000000000000001000001010011,
        ["fcvt.w.s"] = 0b11000000000000000000000001010011,
        ["fcvt.wu.s"] = 0b11000000000100000000000001010011,
        ["fmv.x.w"] = 0b11100000000000000000000001010011,
        ["feq.s"] = 0b10100000000000000010000001010011,
        ["flt.s"] = 0b10100000000000000001000001010011,
        ["fle.s"] = 0b10100000000000000000000001010011,
        ["fclass.s"] = 0b11100000000000000001000001010011,
        ["fcvt.s.w"] = 0b11010000000000000000000001010011,
        ["fcvt.s.wu"] = 0b11010000000100000000000001010011,
        ["fmv.w.x"] = 0b11110000000000000000000001010011,
        #endregion
        #region S
        ["smmv.f.e"] = 0b00000000000000000000000001010111,
        ["smmv.e.f"] = 0b00000010000000000000000001010111,
        ["smtsr"] = 0b00000100000000000000000001010111,
        ["smtsr"] = 0b00000110000000000000000001010111,
        ["smtmr"] = 0b00001000000000000000000001010111,
        ["smtmc"] = 0b00001010000000000000000001010111,
        ["smtar"] = 0b00001100000000000000000001010111,
        ["smtac"] = 0b00001110000000000000000001010111,
        ["smtt"] = 0b00000000000000000010000001011011,
        ["smgen"] = 0b00000000000000000000000001011011,
        ["smgend"] = 0b00000000000000000001000001011011,
        ["sml"] = 0b00000000000000000000000001111011,
        ["smld"] = 0b00000000000000000001000001111011,
        ["sms"] = 0b00000000000000000000000001111111,
        ["smsd"] = 0b00000000000000000001000001111111,
        ["smtr"] = 0b00000100000000000000000001011011,
        ["smdet"] = 0b00000110000000000000000001011011,
        ["smadd"] = 0b00001000000000000000000001011011,
        ["smsub"] = 0b00001010000000000000000001011011,
        ["smmul"] = 0b00001100000000000000000001011011,
        ["smdiv"] = 0b00001110000000000000000001011011,
        ["smmmp"] = 0b00010000000000000000000001011011,
        ["smma"] = 0b00000000000000000000000001011111,
        #endregion
    };
}

static class RegTable
{
    public static readonly Dictionary<string, uint> RegNo = new()
    {
        [""] = 0,
        #region  X
        ["zero"] = 0,
        ["ra"] = 1,
        ["sp"] = 2,
        ["gp"] = 3,
        ["tp"] = 4,
        ["t0"] = 5,
        ["t1"] = 6,
        ["t2"] = 7,
        ["s0"] = 8,
        ["fp"] = 8,
        ["s1"] = 9,
        ["a0"] = 10,
        ["a1"] = 11,
        ["a2"] = 12,
        ["a3"] = 13,
        ["a4"] = 14,
        ["a5"] = 15,
        ["a6"] = 16,
        ["a7"] = 17,
        ["s2"] = 18,
        ["s3"] = 19,
        ["s4"] = 20,
        ["s5"] = 21,
        ["s6"] = 22,
        ["s7"] = 23,
        ["s8"] = 24,
        ["s9"] = 25,
        ["s10"] = 26,
        ["s11"] = 27,
        ["t3"] = 28,
        ["t4"] = 29,
        ["t5"] = 30,
        ["t6"] = 31,
        #endregion
        #region F
        ["ft0"] = 0,
        ["ft1"] = 1,
        ["ft2"] = 2,
        ["ft3"] = 3,
        ["ft4"] = 4,
        ["ft5"] = 5,
        ["ft6"] = 6,
        ["ft7"] = 7,
        ["fs0"] = 8,
        ["fs1"] = 9,
        ["fa0"] = 10,
        ["fa1"] = 11,
        ["fa2"] = 12,
        ["fa3"] = 13,
        ["fa4"] = 14,
        ["fa5"] = 15,
        ["fa6"] = 16,
        ["fa7"] = 17,
        ["fs2"] = 18,
        ["fs3"] = 19,
        ["fs4"] = 20,
        ["fs5"] = 21,
        ["fs6"] = 22,
        ["fs7"] = 23,
        ["fs8"] = 24,
        ["fs9"] = 25,
        ["fs10"] = 26,
        ["fs11"] = 27,
        ["ft8"] = 28,
        ["ft9"] = 29,
        ["ft10"] = 30,
        ["ft11"] = 31,
        #endregion
        #region S
        ["mt0"] = 0,
        ["mt1"] = 1,
        ["mt2"] = 2,
        ["mt3"] = 3,
        ["mt4"] = 4,
        ["mt5"] = 5,
        ["mt6"] = 6,
        ["mt7"] = 7,
        ["ms0"] = 8,
        ["ms1"] = 9,
        ["ma0"] = 10,
        ["ma1"] = 11,
        ["ma2"] = 12,
        ["ma3"] = 13,
        ["ma4"] = 14,
        ["ma5"] = 15,
        ["ma6"] = 16,
        ["ma7"] = 17,
        ["ms2"] = 18,
        ["ms3"] = 19,
        ["ms4"] = 20,
        ["ms5"] = 21,
        ["ms6"] = 22,
        ["ms7"] = 23,
        ["ms8"] = 24,
        ["ms9"] = 25,
        ["ms10"] = 26,
        ["ms11"] = 27,
        ["mt8"] = 28,
        ["mt9"] = 29,
        ["mt10"] = 30,
        ["mt11"] = 31,
        #endregion
    };

}