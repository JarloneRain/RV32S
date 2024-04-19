using System.Text.RegularExpressions;

namespace Ass;

class Encode
{
    public uint Inst { get; set; }
    public uint rd { set => Inst |= (value & 0x1F) << 7; }
    public uint rs1 { set => Inst |= (value & 0x1F) << 15; }
    public uint rs2 { set => Inst |= (value & 0x1F) << 20; }
    public uint rs3 { set => Inst |= (value & 0x1F) << 27; }
    public int immI { set => Inst |= (uint)(value << 20); }
    public int immU
    {
        set => Inst |= (uint)(value & 0xFFFFF) << 12;
    }
    public int immS
    {
        set
        {
            Inst |= (uint)((value >> 5) & 0x7F) << 25;  // 高位部分
            Inst |= (uint)(value & 0x1F) << 7;         // 低位部分
        }
    }
    public int immB
    {
        set
        {
            Inst |= (uint)((value >> 12) & 0x1) << 31; // 最高位
            Inst |= (uint)((value >> 5) & 0x3F) << 25;  // 第二部分
            Inst |= (uint)((value >> 1) & 0xF) << 8;  // 第三部分
            Inst |= (uint)((value >> 11) & 0x1) << 7;   // 最低位
        }
    }
    public int immJ
    {
        set
        {
            Inst |= (uint)((value >> 20) & 0x1) << 31; // 最高位
            Inst |= (uint)((value >> 1) & 0x3FF) << 21; // 中间部分
            Inst |= (uint)((value >> 11) & 0x1) << 20; // 最低位之前的部分
            Inst |= (uint)((value >> 12) & 0xFF) << 12; // 最低位
        }
    }

}

static class Assember
{
    public const uint PC_BASE = 0x80000000;
    static uint Args(TypeTable.InstTypeEnum instType, string args)
    {
        //Console.WriteLine($"\t{args}");
        Match match;
        Encode encode;
        switch (instType)
        {
            case TypeTable.InstTypeEnum.U:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    immU = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.I:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    immI = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.O:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*\(\s*(?<rs1>[A-Za-z0-9]+)\s*\)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    immI = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.E:
                match = Regex.Match(args, @"^$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    Inst = 0
                };
                break;

            case TypeTable.InstTypeEnum.S:
                match = Regex.Match(args, @"^\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*\(\s*(?<rs1>[A-Za-z0-9]+)\s*\)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    immS = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.R:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*(,\s*(?<rs2>[A-Za-z0-9]+))?\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    rs2 = RegTable.RegNo[match.Groups["rs2"].Value]
                };
                break;

            case TypeTable.InstTypeEnum.B:
                match = Regex.Match(args, @"^\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    immB = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.J:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<imm>[+-]?[0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    immJ = int.Parse(match.Groups["imm"].Value)
                };
                break;

            case TypeTable.InstTypeEnum.R4:
                match = Regex.Match(args, @"^\s*(?<rd>[A-Za-z0-9]+)\s*,\s*(?<rs1>[A-Za-z0-9]+)\s*,\s*(?<rs2>[A-Za-z0-9]+)\s*,\s*(?<rs3>[A-Za-z0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new()
                {
                    rd = RegTable.RegNo[match.Groups["rd"].Value],
                    rs1 = RegTable.RegNo[match.Groups["rs1"].Value],
                    rs2 = RegTable.RegNo[match.Groups["rs2"].Value],
                    rs3 = RegTable.RegNo[match.Groups["rs3"].Value]
                };
                break;

            case TypeTable.InstTypeEnum.P_WORD:
                match = Regex.Match(args, @"^\s*(?<num>[\+\-0-9]+)\s*$");
                if (!match.Success) goto INVALID_ARGUMENT_FORMAT;
                encode = new Encode()
                {
                    Inst = (uint)int.Parse(match.Groups["num"].Value)
                };
                break;

            default:
                throw new Exception("Without imperfection, you or I would not exist.\n\t- Stephen Hawking");
            INVALID_ARGUMENT_FORMAT: throw new Exception($"Invalid arguments format for type {instType}:{args}.");
        }
        return encode.Inst;
    }

    public static uint[] Assemble(string[] lines)
    {
        uint pc = 0;
        var lableRegex = new Regex(@"^(?<lable>[0-9A-Za-z\.]+):\s*$");
        var lablePc = new Dictionary<string, uint>();

        var instRegex = new Regex(@"^\s*(?<cmd>[1-9A-Za-z\.]+)(\s+(?<args>[\s,%\.A-Za-z0-9\+\-\(\)]+))?\s*(#.*)?$");
        var instList = new List<(uint PC, string Cmd, string Args)>();
        Console.WriteLine("L I");
        foreach (var line in lines)
        {
            var lableMatch = lableRegex.Match(line);
            var instMatch = instRegex.Match(line);

            if (lableMatch.Success)
            {
                //Console.WriteLine($"lable :{lableMatch.Groups["lable"].Value}");
                lablePc.Add(lableMatch.Groups["lable"].Value, pc);
            }
            if (instMatch.Success)
            {
                instList.Add((pc++, instMatch.Groups["cmd"].Value.ToLower(), instMatch.Groups["args"].Value));
            }
            Console.WriteLine($"{(lableMatch.Success ? 'V' : 'X')} {(instMatch.Success ? 'V' : 'X')} {line}");
        }


        uint[] insts = new uint[instList.Count];
        for (int i = 0; i < instList.Count; i++)
        {
            insts[i] = 0u;
            insts[i] |= InstTable.InstCode[instList[i].Cmd.ToLower()];
            insts[i] |= Args(instList[i].Cmd switch
            {
                ".word" => TypeTable.InstTypeEnum.P_WORD,
                _ => TypeTable.InstType[insts[i] & 0x7F]
            }, instList[i].Args.RepleceLable((uint)i, lablePc));
            Console.WriteLine($"{4 * i + PC_BASE:X8}:{insts[i]:X8}\t{instList[i].Cmd}\t{instList[i].Args}");
        }
        return insts;
    }

    public static string RepleceLable(this string args, uint curPC, Dictionary<string, uint> lablePC)
    {
        //Console.WriteLine($"\t{args}");
        foreach (var lable in lablePC)
        {
            //Console.WriteLine($"{lable.Key}\t:{lable.Value}");
            args = args.Replace($"%hi({lable.Key})", $"{(int)((PC_BASE + lable.Value * 4) & 0xFFFFF000)}");
            args = args.Replace($"%lo({lable.Key})", $"{(int)((PC_BASE + lable.Value * 4) & 0x00000FFF)}");
            args = args.Replace(lable.Key, $"{4 * (int)(lable.Value - curPC)}");
            //Console.WriteLine($"\t{args}");
        }
        //Console.WriteLine($"\t{args}");
        return args;
    }
}