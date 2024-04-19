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

class Tracer
{
    public bool TracerOn { get; set; }
    public bool InstTracerOn { get; set; }
    public bool FuncTracerOn { get; set; }
    public bool MemRTracerOn { get; set; }
    public bool MemWTracerOn { get; set; }

    Dictionary<uint, InstInfo> instInfos = new();

    Dictionary<uint, XTracer> tracer = new Dictionary<uint, XTracer> { [0] = new XTracer() };

    List<FuncInfo> funcInfos = new();
    Stack<uint> callStack = new();

    uint t = 0;
    public uint T
    {
        get => t; set
        {
            if (!TracerOn) return;
            if (!tracer.ContainsKey(value))
            {
                tracer.Add(value, new XTracer());
            }
            t = value;
        }
    }

    public void Init(string path)
    {
        if (!TracerOn) return;
        var funcRegex = new Regex(@"(?<funcPC>[0-9A-Fa-f]+) <(?<funcName>\w+)>:");
        var instRegex = new Regex(@"(?<instPC>[0-9A-Fa-f]+):\s*(?<instCode>[0-9A-Fa-f]+)\s+(?<instText>.*)");
        var lines = File.ReadAllLines(path);
        foreach (var line in lines)
        {
            var funcMatch = funcRegex.Match(line);
            if (funcMatch.Success)
            {
                funcInfos.Add(new FuncInfo
                {
                    PC = Convert.ToUInt32(funcMatch.Groups["funcPC"].Value, 16),
                    Name = funcMatch.Groups["funcName"].Value
                });
            }
            var instMatch = instRegex.Match(line);
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
        tracer[T].Inst += $"{pc:X8} : {instInfos[pc].Text}\n";
    }

    public void MemReadTrace(uint addr, int bytes, uint value)
    {
        if (!TracerOn) return;
        tracer[T].MemR += $"\t\tRead  {bytes} bytes from 0x{addr:X8} : 0x{value:X8} {(int)value}\n";
    }

    public void MemWriteTrace(uint addr, int bytes, uint value)
    {
        if (!TracerOn) return;
        tracer[T].MemW += $"\t\tWrtie {bytes} bytes to   0x{addr:X8} : 0x{value:X8} {(int)value}\n";
    }

    public void FuncTrace(uint snpc, uint dnpc)
    {
        if (!TracerOn) return;
        if (callStack.TryPeek(out uint top) && top == dnpc)
        {
            callStack.Pop();
            tracer[T].Func += $"\t{new string(' ', 2 * callStack.Count)}ret\n";
            return;
        }
        foreach (var funcInfo in funcInfos)
        {
            if (funcInfo.PC == dnpc)
            {
                tracer[T].Func += $"\t{new string(' ', 2 * callStack.Count)}call [0x{dnpc:X8}]@{funcInfo.Name}\n";
                callStack.Push(snpc);
                return;
            }
        }
    }

    public void Print(uint n)
    {
        if (!TracerOn)
        {
            Console.WriteLine("Trecer is off.");
            return;
        }
        Console.ForegroundColor = ConsoleColor.DarkYellow;
        for (uint i = T >= n ? T - n + 1 : 1; i <= T; i++)
        {
            Console.Write(tracer[i]);
        }
        Console.ResetColor();
    }
}