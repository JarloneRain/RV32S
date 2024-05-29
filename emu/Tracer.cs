using System.Text.RegularExpressions;

namespace RV32Semu;
class XTracer
{
    public string Inst { get; set; } = "";
    public string MemR { get; set; } = "";
    public string MemW { get; set; } = "";
    public string Func { get; set; } = "";

    public override string ToString()
    {
        return Inst + Func + MemR + MemW;
    }
}

struct FuncInfo
{
    public string Name { get; set; }
    public uint PC { get; set; }
}

struct InstInfo
{
    public uint Code { get; set; }
    public string Text { get; set; }
}

partial class Tracer
{
    public bool TracerOn { get; set; } = false;

    readonly Dictionary<uint, InstInfo> instInfos = [];

    readonly Dictionary<uint, XTracer> traces = new() { [0] = new XTracer() };

    readonly List<FuncInfo> funcInfos = [];
    readonly Stack<uint> callStack = new();
    public string TraceText
    {
        get
        {
            var res = "";
            foreach (var trace in traces)
                res += trace.Value.ToString();
            return res;
        }
    }
    uint t = 0;
    public uint T
    {
        get => t; set
        {
            if (!TracerOn) return;
            if (!traces.ContainsKey(value))
            {
                traces.Add(value, new XTracer());
            }
            t = value;
        }
    }

    [GeneratedRegex(@"(?<funcPC>[0-9A-Fa-f]+) <(?<funcName>\w+)>:")]
    private static partial Regex funcRegex();
    [GeneratedRegex(@"(?<instPC>[0-9A-Fa-f]+):\s*(?<instCode>[0-9A-Fa-f]+)\s+(?<instText>.*)")]
    private static partial Regex instRegex();

    public void Init(string path)
    {
        if (!TracerOn) return;
        var lines = File.ReadAllLines(path);
        foreach (var line in lines)
        {
            var funcMatch = funcRegex().Match(line);
            if (funcMatch.Success)
            {
                funcInfos.Add(new FuncInfo
                {
                    PC = Convert.ToUInt32(funcMatch.Groups["funcPC"].Value, 16),
                    Name = funcMatch.Groups["funcName"].Value
                });
            }
            var instMatch = instRegex().Match(line);
            if (instMatch.Success)
            {
                instInfos.Add(
                    Convert.ToUInt32(instMatch.Groups["instPC"].Value, 16),
                    new InstInfo
                    {
                        Code = Convert.ToUInt32(instMatch.Groups["instCode"].Value, 16),
                        Text = instMatch.Groups["instText"].Value
                    });
            }
        }
    }

    public void InstTrace(uint pc)
    {
        if (!TracerOn) return;
        traces[T].Inst += $"{pc:X8} : {instInfos[pc].Code:X8}\t{instInfos[pc].Text}\n";
    }

    public void MemReadTrace(uint addr, int bytes, uint value)
    {
        if (!TracerOn) return;
        traces[T].MemR += $"\t\tRead  {bytes} bytes from 0x{addr:X8} : 0x{value:X8} {(int)value,12} {value.WordTo<float>()}\n";
    }

    public void MemWriteTrace(uint addr, int bytes, uint value)
    {
        if (!TracerOn) return;
        traces[T].MemW += $"\t\tWrtie {bytes} bytes to   0x{addr:X8} : 0x{value:X8} {(int)value,12} {value.WordTo<float>()}\n";
    }

    public void FuncTrace(uint snpc, uint dnpc)
    {
        if (!TracerOn) return;
        if (callStack.TryPeek(out uint top) && top == dnpc)
        {
            callStack.Pop();
            traces[T].Func += $"\t{new string(' ', 2 * callStack.Count)}ret\n";
            return;
        }
        foreach (var funcInfo in funcInfos)
        {
            if (funcInfo.PC == dnpc)
            {
                traces[T].Func += $"\t{new string(' ', 2 * callStack.Count)}call [0x{dnpc:X8}]@{funcInfo.Name}\n";
                callStack.Push(snpc);
                return;
            }
        }
    }

    public void Print(uint n)
    {
        if (!TracerOn)
        {
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("Trecer is off.");
            Console.ResetColor();
            return;
        }
        Console.ForegroundColor = ConsoleColor.DarkYellow;
        uint m = T >= n ? T - n + 1 : 1;
        for (uint i = m; i <= T; i++)
        {
            Console.Write(traces[i]);
        }
        Console.WriteLine($"Recent {T - m + 1} trace of {T}.");
        Console.ResetColor();
    }


}