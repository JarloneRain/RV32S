using System.Numerics;

namespace RV32Semu;

static class Utils
{
    public static void ToDo(string me = "me") => throw new Exception($"Please implent {me}!");
    // public static uint Bits(this uint value, int hi, int lo) => (value >> lo) & ((1u << (hi - lo + 1)) - 1);
    // public static uint Bits(this float value, int hi, int lo) => value.Float2Bin().Bits(hi, lo);
    public static uint Bits<T>(this T value, int hi, int lo) where T : unmanaged
    {
        unsafe
        {
            uint u = *(uint*)&value;
            return (u >> lo) & ((1u << (hi - lo + 1)) - 1);
        }
    }

    public static uint Bit<T>(this T value, int b) where T : unmanaged
    {
        unsafe
        {
            uint u = *(uint*)&value;
            return u & (uint)(1 << b);
        }
    }
    public static int SignExt(this uint x, int len)
    {
        if ((x & (1u << (len - 1))) != 0)
        {
            x |= uint.MaxValue << len;
        }
        else
        {
            x &= (1u << len) - 1;
        }
        return (int)x;
    }

    public static T Bin2<T>(this uint x) where T : unmanaged
    {
        unsafe
        {
            return *(T*)&x;
        }
    }
    public static uint Float2Bin(this float x)
    {
        unsafe
        {
            return *(uint*)&x;
        }
    }
}