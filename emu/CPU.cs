using System.Runtime.InteropServices;
using System.Runtime.Intrinsics.Arm;
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using static RV32Semu.Utils;

namespace RV32Semu;

class Ebreak : Exception { }


class CPU
{
    const uint PC_DEFAULT = 0x80000000;
    internal Decoder decoder;
    internal GPR gpr;
    internal Memory memory;
    internal InstExcuter excuter;
    Tracer tracer;
    uint pc;
    uint inst;
    public CPU(Tracer tracer)
    {
        this.tracer = tracer;
        decoder = new Decoder();
        gpr = new GPR();
        memory = new Memory(tracer);
        excuter = new InstExcuter(this);
    }
    public void Init(string path)
    {
        pc = PC_DEFAULT;

        memory.Init(path);
    }

    public void Exec(int t)
    {
        for (int i = 0; i < t; i++)
        {
            tracer.T++;

            tracer.InstTrace(pc);

            inst = memory[pc, 4];

            PrintPcInst();

            decoder.Inst = inst;
            decoder.PC = pc;
            decoder.Dnpc = pc + 4;

            excuter.Execute(inst);

            tracer.FuncTrace(decoder.Snpc, decoder.Snpc);

            gpr.X[0] = 0;
            pc = decoder.Dnpc;
        }

    }

    public void PrintGpr()
    {
        Console.ForegroundColor = ConsoleColor.DarkMagenta;
        Console.WriteLine($"pc   :{pc:X8} {pc}");
        foreach (var reg in Enum.GetValues<GPR.REG_ENUM_X>())
        {
            Console.WriteLine($"{reg,-5}:{gpr.X[(int)reg]:X8} {gpr.X[(int)reg]}");
        }
        foreach (var reg in Enum.GetValues<GPR.REG_ENUM_F>())
        {
            Console.WriteLine($"{reg,-5}:{gpr.F[(int)reg]}");
        }
        Console.ResetColor();
    }
    public void PrintPcInst()
    {
        Console.ForegroundColor = ConsoleColor.Magenta;
        Console.WriteLine($"{pc:X8}:{inst:X8}");
        Console.ResetColor();
    }

}

class Decoder
{
    public uint PC { get; set; }
    public uint Inst { get; set; }
    public uint Dnpc { get; set; }
    public uint Snpc => PC + 4;
    public uint rd => Inst.Bits(11, 7);
    public uint rs1 => Inst.Bits(19, 15);
    public uint rs2 => Inst.Bits(24, 20);
    public int immI => Inst.Bits(31, 20).SignExt(12);
    public int immU => Inst.Bits(31, 12).SignExt(20) << 12;
    public int immS => ((Inst.Bits(31, 25) << 5) | Inst.Bits(11, 7)).SignExt(12);
    public int immJ => ((Inst.Bits(31, 31) << 20) | (Inst.Bits(19, 12) << 12)
                    | (Inst.Bits(20, 20) << 11) | (Inst.Bits(30, 21) << 1)).SignExt(21);
    public int immB => ((Inst.Bits(31, 31) << 12) | (Inst.Bits(7, 7) << 11)
                    | (Inst.Bits(30, 25) << 5) | (Inst.Bits(11, 8) << 1)).SignExt(13);
    public uint rm => Inst.Bits(14, 12);
    public uint rs3 => Inst.Bits(31, 27);
}

class InstExcuter
{
    internal (string InstPattern, Action Act)[] execTable;
    public InstExcuter(CPU cpu)
    {

        GPR r = cpu.gpr;
        Memory m = cpu.memory;
        Decoder d = cpu.decoder;
        execTable =
        [
#region I
            // add    
            ("0000000..........000.....0110011",() => r.X[d.rd] = r.X[d.rs1] + r.X[d.rs2]),
            // and    
            ("0000000..........111.....0110011",() => r.X[d.rd] = r.X[d.rs1] & r.X[d.rs2]),
            // auipc  
            (".........................0010111",() => r.X[d.rd] = (uint)(d.PC + d.immU)),
            // addi   
            (".................000.....0010011",() => r.X[d.rd] = (uint)(r.X[d.rs1] + d.immI)),
            // andi   
            (".................111.....0010011",() => r.X[d.rd] = (uint)(r.X[d.rs1] & d.immI)),

            // beq    
            (".................000.....1100011",() => { if (r.X[d.rs1] == r.X[d.rs2]) d.Dnpc = (uint)(d.PC + d.immB); }),
            // bne    
            (".................001.....1100011",() => { if (r.X[d.rs1] != r.X[d.rs2]) d.Dnpc = (uint)(d.PC + d.immB); }),
            // blt    
            (".................100.....1100011",() => { if (((int)r.X[d.rs1]) < ((int)r.X[d.rs2])) d.Dnpc = (uint)(d.PC + d.immB); }),
            // bge    
            (".................101.....1100011",() => { if (((int)r.X[d.rs1]) >= ((int)r.X[d.rs2])) d.Dnpc = (uint)(d.PC + d.immB); }),
            // bltu   
            (".................110.....1100011",() => { if (r.X[d.rs1] < r.X[d.rs2]) d.Dnpc = (uint)(d.PC + d.immB); }),
            // bgeu   
            (".................111.....1100011",() => { if (r.X[d.rs1] >= r.X[d.rs2]) d.Dnpc = (uint)(d.PC + d.immB); }),

            // ebreak 
            ("00000000000100000000000001110011",() => throw new Ebreak()),
            // ecall  
            ("00000000000000000000000001110011",()=>ToDo("ecall")),
            // fence  
            ("0000.............000.....0001111",()=>ToDo("fence")),

            // jal    
            (".........................1101111",() => { r.X[d.rd] = d.Snpc; d.Dnpc = (uint)(d.PC + d.immJ); }),
            // jalr   
            (".................000.....1100111",() => { r.X[d.rd] = d.Snpc; d.Dnpc = (uint)(r.X[d.rs1] + d.immI); }),

            // lb     
            (".................000.....0000011",() => r.X[d.rd] = (uint)m[(uint)(r.X[d.rs1] + d.immI),1].SignExt(8)),
            // lh     
            (".................001.....0000011",() => r.X[d.rd] = (uint)m[(uint)(r.X[d.rs1] + d.immI),2].SignExt(16)),
            // lbu    
            (".................100.....0000011",() => r.X[d.rd] = m[(uint)(r.X[d.rs1] + d.immI),1]),
            // lhu    
            (".................101.....0000011",() => r.X[d.rd] = m[(uint)(r.X[d.rs1] + d.immI),2]),
            // lw     
            (".................010.....0000011",() => r.X[d.rd] = m[(uint)(r.X[d.rs1] + d.immI),4]),

            // lui    
            (".........................0110111",() => r.X[d.rd] = (uint)d.immU),

           
            // ori    
            (".................110.....0010011",() => r.X[d.rd] = r.X[d.rs1] | (uint)d.immI),
            // or     
            ("0000000..........110.....0110011",() => r.X[d.rd] = r.X[d.rs1] | r.X[d.rs2]),

            // sb     
            (".................000.....0100011",() => m[(uint)(r.X[d.rs1] + d.immS),1]=r.X[d.rs2]),
            // sh     
            (".................001.....0100011",() => m[(uint)(r.X[d.rs1] + d.immS),2]=r.X[d.rs2]),
            // sw     
            (".................010.....0100011",() => m[(uint)(r.X[d.rs1] + d.immS),4]=r.X[d.rs2]),

            // slli   
            ("0000000..........001.....0010011",() => r.X[d.rd] = r.X[d.rs1] << d.immI),
            // srli   
            ("0000000..........101.....0010011",() => r.X[d.rd] = r.X[d.rs1] >> d.immI),
            // srai   
            ("0100000..........101.....0010011",() => r.X[d.rd] = (uint)((int)r.X[d.rs1] >> (int)(d.immI & 0x1Fu))),

            // slti   
            (".................010.....0010011",() => r.X[d.rd] = ((int)r.X[d.rs1]) < d.immI ? 1u : 0u),
            // sltiu  
            (".................011.....0010011",() => r.X[d.rd] = r.X[d.rs1] < d.immI ? 1u : 0u),

            // sll    
            ("0000000..........001.....0110011",() => r.X[d.rd] = r.X[d.rs1] << (int)(r.X[d.rs2] & 0x1F)),
            // slt    
            ("0000000..........010.....0110011",() => r.X[d.rd] = ((int)r.X[d.rs1]) < ((int)r.X[d.rs2]) ? 1u : 0u),
            // sltu   
            ("0000000..........011.....0110011",() => r.X[d.rd] = (r.X[d.rs1] < r.X[d.rs2]) ? 1u : 0u),
            // srl    
            ("0000000..........101.....0110011",() => r.X[d.rd] = r.X[d.rs1] >> (int)(r.X[d.rs2] & 0x1F)),
            // sra    
            ("0100000..........101.....0110011",() => r.X[d.rd] = (uint)((int)r.X[d.rs1] >> (int)(r.X[d.rs2] & 0x1F))),
            // sub    
            ("0100000..........000.....0110011",() => r.X[d.rd] = r.X[d.rs1] - r.X[d.rs2]),
            // xor    
            ("0000000..........100.....0110011",() => r.X[d.rd] = r.X[d.rs1] ^ r.X[d.rs2]),

            // xori   
            (".................100.....0010011",() => r.X[d.rd] = r.X[d.rs1] ^ (uint)d.immI),
#endregion
#region M
            // div    
            ("0000001..........100.....0110011",() => r.X[d.rd] = (uint)((int)r.X[d.rs1] / (int)r.X[d.rs2])),
            // divu   
            ("0000001..........101.....0110011",() => r.X[d.rd] = r.X[d.rs1] / r.X[d.rs2]),
                        // rem    
            ("0000001..........110.....0110011",() => r.X[d.rd] = (uint)(((int)r.X[d.rs1]) % ((int)r.X[d.rs2]))),
            // remu   
            ("0000001..........111.....0110011",() => r.X[d.rd] = r.X[d.rs1] % r.X[d.rs2]),
             // mul    
            ("0000001..........000.....0110011",() => r.X[d.rd] = r.X[d.rs1] * r.X[d.rs2]),
            // mulh   
            ("0000001..........001.....0110011",() => r.X[d.rd] = (uint)(int)(((int)r.X[d.rs1] * (long)(int)r.X[d.rs2]) >> 32)),
            // mulhu  
            ("0000001..........011.....0110011",() => r.X[d.rd] = (uint)((r.X[d.rs1] * (ulong)r.X[d.rs2]) >> 32)),
#endregion
#region F
            
            //FLW
            (".................010.....0000111",()=>r.F[d.rd]= m[(uint)(r.X[d.rs1]+d.immI),4].Bin2<float>()),
            //FSW
            (".................010.....0100111",()=>m[(uint)(r.X[d.rs1]+d.immS),4]=r.F[d.rd].Float2Bin()),
            //FMADD.S
            (".....00..................1000011",()=>r.F[d.rd]=r.F[d.rs1]*r.F[d.rs2]+r.F[d.rs3]),
            //FMSUB.S
            (".....00..................1000111",()=>r.F[d.rd]=r.F[d.rs1]*r.F[d.rs2]-r.F[d.rs3]),
            //FNMSUB.S
            (".....00..................1001011",()=>r.F[d.rd]=-r.F[d.rs1]*r.F[d.rs2]+r.F[d.rs3]),
            //FNMADD.S
            (".....00..................1001111",()=>r.F[d.rd]=-r.F[d.rs1]*r.F[d.rs2]-r.F[d.rs3]),
            //FADD.S
            ("0000000..................1010011",()=>r.F[d.rd]=r.F[d.rs1]+r.F[d.rs2]),
            //FSUB.S
            ("0000100..................1010011",()=>r.F[d.rd]=r.F[d.rs1]-r.F[d.rs2]),
            //FMUL.S
            ("0001000..................1010011",()=>r.F[d.rd]=r.F[d.rs1]*r.F[d.rs2]),
            //FDIV.S
            ("0001100..................1010011",()=>r.F[d.rd]=r.F[d.rs1]/r.F[d.rs2]),
            //FSQRT.S
            ("010110000000.............1010011",()=>r.F[d.rd]=(float)Math.Sqrt(r.F[d.rs1])),
            //FSGNJ.S
            ("0010000..........000.....1010011",()=>r.F[d.rd]=(r.F[d.rs2].Bit(31)|r.F[d.rs1].Bits(30,0)).Bin2<float>()),
            //FSGNJN.S
            ("0010000..........001.....1010011",()=>r.F[d.rd]=(~r.F[d.rs2].Bit(31)|r.F[d.rs1].Float2Bin().Bits(30,0)).Bin2<float>()),
            //FSGNJX.S
            ("0010000..........010.....1010011",()=>r.F[d.rd]=(((r.F[d.rs2].Bit(31))^(r.F[d.rs2].Bit(31)))|r.F[d.rs1].Bits(30,0)).Bin2<float>()),
            //FMIN.S
            ("0010100..........000.....1010011",()=>r.F[d.rd]=Math.Min(r.F[d.rs1],r.F[d.rs2])),
            //FMAX.S
            ("0010100..........001.....1010011",()=>r.F[d.rd]=Math.Max(r.F[d.rs1],r.F[d.rs2])),
            //FCVT.W.S
            ("110000000000.............1010011",()=>r.X[d.rd]=(uint)(int)r.F[d.rs1]),
            //FCVT.WU.S
            ("110000000001.............1010011",()=>r.X[d.rd]=(uint)r.F[d.rs1]),
            //FMV.X.W
            ("111000000000.....000.....1010011",()=>r.X[d.rd]=r.F[d.rs1].Float2Bin()),
            //FEQ.S
            ("1010000..........010.....1010011",()=>r.X[d.rd]=r.F[d.rs1]==r.F[d.rs2]?1u:0u),
            //FLT.S
            ("1010000..........001.....1010011",()=>r.X[d.rd]=r.F[d.rs1]<r.F[d.rs2]?1u:0u),
            //FLE.S
            ("1010000..........000.....1010011",()=>r.X[d.rd]=r.F[d.rs1]<=r.F[d.rs2]?1u:0u),
            //FCLASS.S
            ("111000000000.....001.....1010011",()=>ToDo("fclass.s")),
            //FCVT.S.W
            ("110100000000.............1010011",()=>r.F[d.rd]=(int)r.X[d.rs1]),
            //FCVT.S.WU
            ("110100000001.............1010011",()=>r.F[d.rd]=r.X[d.rs1]),
            //FMV.W.X
            ("111100000000.....000.....1010011",()=>r.F[d.rd]=r.X[d.rs1].Bin2<float>()),
#endregion
            // inv    
            ("................................",() => throw new Exception($"Unknown instruction:{d.Inst:X8}"))
        ];
    }
    public void Execute(uint inst)
    {
        string instStr = Convert.ToString(inst, 2).PadLeft(32, '0');
        foreach (var executer in execTable)
        {
            if (Regex.IsMatch(instStr, executer.InstPattern))
            { executer.Act(); return; }
        }
    }
}
