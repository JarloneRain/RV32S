namespace RV32Semu;

class Gpr
{
    public enum REG_ENUM_X
    {
        zero,
        ra, sp, gp, tp,
        t0, t1, t2,
        s0fp, s1,
        a0, a1, a2, a3, a4, a5, a6, a7,
        s2, s3, s4, s5, s6, s7, s8, s9, s10, s11,
        t3, t4, t5, t6
    }
    public enum REG_ENUM_F
    {
        ft0, ft1, ft2, ft3, ft4, ft5, ft6, ft7,
        fs0, fs1,
        fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7,
        fs2, fs3, fs4, fs5, fs6, fs7, fs8, fs9, fs10, fs11,
        ft8, ft9, ft10, ft11
    }

    public enum REG_ENUM_M
    {
        mt0, mt1, mt2, mt3, mt4, mt5, mt6, mt7,
        ms0, ms1,
        ma0, ma1, ma2, ma3, ma4, ma5, ma6, ma7,
        ms2, ms3, ms4, ms5, ms6, ms7, ms8, ms9, ms10, ms11,
        mt8, mt9, mt10, mt11
    }
    public readonly uint[] X = new uint[32];
    public readonly float[] F = new float[32];
    public readonly Matrix4x4[] M = [new(), new(),
        new(), new(), new(), new(), new(), new(), new(), new(), new(), new(),
        new(), new(), new(), new(), new(), new(), new(), new(), new(), new(),
        new(), new(), new(), new(), new(), new(), new(), new(), new(), new()];
    public uint Fcsr { get; set; }


    public void Print()
    {
        Console.ForegroundColor = ConsoleColor.DarkMagenta;
        foreach (var reg in Enum.GetValues<REG_ENUM_X>())
        {
            Console.WriteLine($"{reg,-5}:{X[(int)reg]:X8} {X[(int)reg]}");
        }
        foreach (var reg in Enum.GetValues<REG_ENUM_F>())
        {
            Console.WriteLine($"{reg,-5}:{F[(int)reg]}");
        }
        foreach (var reg in Enum.GetValues<REG_ENUM_M>())
        {
            Console.WriteLine($"{reg,-5}:{M[(int)reg].TabString("\t")}");
        }
        Console.ResetColor();
    }
}