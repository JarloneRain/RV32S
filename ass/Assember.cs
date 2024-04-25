using System.Reflection.Emit;
using System.Text.RegularExpressions;

namespace Ass;

class Encode
{
    public uint Inst { get; set; }
    public uint Rd { set => Inst |= (value & 0x1F) << 7; }
    public uint Rs1 { set => Inst |= (value & 0x1F) << 15; }
    public uint Rs2 { set => Inst |= (value & 0x1F) << 20; }
    public uint Rs3 { set => Inst |= (value & 0x1F) << 27; }
    public int ImmI { set => Inst |= (uint)(value << 20); }
    public int ImmU { set => Inst |= (uint)(value & 0xFFFFF) << 12; }
    public int ImmS
    {
        set
        {
            Inst |= (uint)((value >> 5) & 0x7F) << 25;  // 高位部分
            Inst |= (uint)(value & 0x1F) << 7;         // 低位部分
        }
    }
    public int ImmB
    {
        set
        {
            Inst |= (uint)((value >> 12) & 0x1) << 31; // 最高位
            Inst |= (uint)((value >> 5) & 0x3F) << 25;  // 第二部分
            Inst |= (uint)((value >> 1) & 0xF) << 8;  // 第三部分
            Inst |= (uint)((value >> 11) & 0x1) << 7;   // 最低位
        }
    }
    public int ImmJ
    {
        set
        {
            Inst |= (uint)((value >> 20) & 0x1) << 31; // 最高位
            Inst |= (uint)((value >> 1) & 0x3FF) << 21; // 中间部分
            Inst |= (uint)((value >> 11) & 0x1) << 20; // 最低位之前的部分
            Inst |= (uint)((value >> 12) & 0xFF) << 12; // 最低位
        }
    }
    public uint I { set => Inst |= (value & 0x3) << 30; }
    public uint J { set => Inst |= (value & 0x3) << 28; }
}

class InstInfo
{
    public const uint PC_BASE = 0x80000000;
    public uint Index { get; set; } = 0u;
    public uint Code { get; set; } = 0u;
    public string Cmd { get; set; } = "";
    public string Args { get; set; } = "";
    public uint PC => PC_BASE + 4 * Index;
}

partial class Assember
{
    public const uint PC_BASE = 0x80000000;
    readonly Dictionary<string, uint> lableIndex = [];
    readonly List<InstInfo> instList = [];


    [GeneratedRegex(@"^(?<lable>[0-9A-Za-z\._]+):\s*$")]
    private static partial Regex lableRegex();
    [GeneratedRegex(@"^\s*(?<cmd>[1-9A-Za-z\.]+)(\s+(?<args>[\s,%\.A-Za-z0-9\+\-\(\)]+))?\s*(#.*)?$")]
    private static partial Regex instRegex();
    public Assember Assemble(string[] lines)
    {
        uint index = 0;
        foreach (var line in lines)
        {
            var lableMatch = lableRegex().Match(line);
            var instMatch = instRegex().Match(line);
            if (lableMatch.Success)
            {
                lableIndex.Add(lableMatch.Groups["lable"].Value.ToLower(), index);
            }
            if (instMatch.Success)
            {
                instList.Add(new InstInfo()
                {
                    Index = index++,
                    Code = 0,
                    Cmd = instMatch.Groups["cmd"].Value.ToLower(),
                    Args = instMatch.Groups["args"].Value.ToLower()
                });
            }
        }

        foreach (var inst in instList)
        {
            inst.Code |= InstTable.InstCode[inst.Cmd];
            inst.Code |= Args(inst.Cmd switch
            {
                ".word" => TypeTable.InstTypeEnum.P_WORD,
                _ => TypeTable.InstType[inst.Code & 0x7F]
            }, RepleceLable(inst.Args, inst.Index));
        }

        return this;
    }
    static partial class ArgsRegex
    {
        // rd, imm
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$")]
        public static partial Regex TypeU();
        // rd, rs1, imm
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$")]
        public static partial Regex TypeI();
        // rd, imm(rs1)
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*\(\s*(?<rs1>[A-Za-z0-9]+)\s*\)\s*$")]
        public static partial Regex TypeO();
        // empty
        [GeneratedRegex(@"^$")]
        public static partial Regex TypeE();
        // rs2, imm(rs1)
        [GeneratedRegex(@"^\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*\(\s*(?<rs1>[A-Za-z0-9]+)\s*\)\s*$")]
        public static partial Regex TypeS();
        // rd, rs1[, rs2]
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*(,\s*(?<rs2>[A-Za-z0-9]+))?\s*$")]
        public static partial Regex TypeR();
        // rs1, rs2, imm
        [GeneratedRegex(@"^\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$")]
        public static partial Regex TypeB();
        // rd, imm
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$")]
        public static partial Regex TypeJ();
        // rd, rs1, rs2, rs3
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<rs3>[A-Za-z0-9]+)\s*$")]
        public static partial Regex TypeR4();
        // num
        [GeneratedRegex(@"^\s*(?<num>[\+\-0-9]+)\s*$")]
        public static partial Regex TypeP_WORD();
        // rd, rs1[, rs2], i, j
        [GeneratedRegex(@"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)(\s*,\s*(?<rs2>[A-Za-z0-9]+))?\s*,\s*(?<i>[\-\+0-9]+)\s*,\s*(?<j>[\-\+0-9]+)\s*$")]
        public static partial Regex TypeY();
    }
    static uint Args(TypeTable.InstTypeEnum instType, string args)
    {
        Match match;
        Encode encode;
        switch (instType)
        {
            case TypeTable.InstTypeEnum.U:
                match = ArgsRegex.TypeU().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    ImmU = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.I:
                match = ArgsRegex.TypeI().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    ImmI = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.O:
                match = ArgsRegex.TypeO().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    ImmI = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.E:
                match = ArgsRegex.TypeE().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Inst = 0
                };
                break;

            case TypeTable.InstTypeEnum.S:
                match = ArgsRegex.TypeS().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    Rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    ImmS = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.R:
                match = ArgsRegex.TypeR().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    Rs2 = RegTable.RegNo[match.Groups["rs2"].Value]
                };
                break;

            case TypeTable.InstTypeEnum.B:
                match = ArgsRegex.TypeB().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    Rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    ImmB = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.J:
                match = ArgsRegex.TypeJ().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    ImmJ = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.R4:
                match = ArgsRegex.TypeR4().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    Rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    Rs3 = RegTable.RegNo[match.Groups["rs3"].Value]
                };
                break;

            case TypeTable.InstTypeEnum.P_WORD:
                match = ArgsRegex.TypeP_WORD().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new Encode()
                {
                    Inst = (uint)int.Parse(match.Groups["num"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.Y:
                match = ArgsRegex.TypeY().Match(args);
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new Encode()
                {
                    Rd = RegTable.RegNo[match.Groups["rd"].Value],
                    Rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    Rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    I = uint.Parse(match.Groups["i"].Value),
                    J = uint.Parse(match.Groups["j"].Value)
                };
                break;

            default:
                throw new Exception("Without imperfection, you or I would not exist.\n\t- Stephen Hawking");
            INVALID_ARGUMENT_FORMAT: throw new Exception($"Invalid arguments format for type {instType}:{args}.");
        }
        return encode.Inst;
    }

    public Assember WriteBin(string path)
    {
        byte[] bytes = new byte[4 * instList.Count];
        for (int i = 0; i < instList.Count; i++)
        {
            bytes[4 * i + 0] = (byte)((instList[i].Code >> 0) & 0xFF);
            bytes[4 * i + 1] = (byte)((instList[i].Code >> 8) & 0xFF);
            bytes[4 * i + 2] = (byte)((instList[i].Code >> 16) & 0xFF);
            bytes[4 * i + 3] = (byte)((instList[i].Code >> 24) & 0xFF);
        }
        File.WriteAllBytes(path, bytes);
        return this;
    }

    public Assember WriteText(string path)
    {
        List<string> texts = [];
        var funcList = lableIndex.Where(kv => kv.Key[0] != '.')
                                .Select(kv => new
                                {
                                    Name = kv.Key,
                                    Index = kv.Value
                                }).OrderBy(f => f.Index).ToList();

        int jndex = 0;
        for (uint i = 0; i < instList.Count; i++)
        {
            for (; jndex < funcList.Count && funcList[jndex].Index == i; jndex++)
            {
                texts.Add($"\n{PC_BASE + 4 * i:X8} <{funcList[jndex].Name}>:");
            }
            var inst = instList[(int)i];
            texts.Add($"{inst.PC:X8}:{inst.Code:X8}\t{inst.Cmd,-8}\t{inst.Args}");
        }
        File.WriteAllLines(path, texts);
        return this;
    }
    string RepleceLable(string args, uint index)
    {
        foreach (var lable in lableIndex)
        {
            args = args.Replace(lable.Key, $"{4 * (int)(lable.Value - index)}");
        }
        return args;
    }
}