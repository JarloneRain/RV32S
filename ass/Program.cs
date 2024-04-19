using static Convert;

var src = @"/home/looooong/RV32S/tests";

Console.WriteLine(args[0]);
//var assember = new Ass.Assember();
var bin = Ass.Assember.Assemble(File.ReadAllLines($"{src}/{args[0]}.s"));



File.WriteAllBytes($"{src}/{args[0]}.bin", bin.ToBytes());

static class Convert
{
    public static byte[] ToBytes(this uint[] src)
    {
        byte[] bytes = new byte[4 * src.Length];
        for (int i = 0; i < src.Length; i++)
        {
            bytes[4 * i + 0] = (byte)((src[i] >> 0) & 0xFF);
            bytes[4 * i + 1] = (byte)((src[i] >> 8) & 0xFF);
            bytes[4 * i + 2] = (byte)((src[i] >> 16) & 0xFF);
            bytes[4 * i + 3] = (byte)((src[i] >> 24) & 0xFF);
        }
        return bytes;
    }
}
