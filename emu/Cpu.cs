using System.Runtime.InteropServices;
using System.Runtime.Intrinsics.Arm;
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using static RV32Semu.Utils;

namespace RV32Semu;

class Ebreak : Exception { }


class Cpu
{
    const uint PC_DEFAULT = 0x80000000;
    internal Decoder decoder;
    internal Gpr gpr;
    internal Memory memory;
    internal InstExcuter excuter;
    protected uint pc;
    public Cpu(Decoder decoder, Gpr gpr, Memory memory)
    {
        this.decoder = decoder;
        this.gpr = gpr;
        this.memory = memory;
        excuter = new InstExcuter(this);
    }
    public void Init(string path)
    {
        pc = PC_DEFAULT;

        memory.Init(path);
    }

    protected virtual void ExecOnce()
    {
        uint inst = memory[pc, 4];

        decoder.Inst = inst;
        decoder.PC = pc;
        decoder.Dnpc = pc + 4;

        excuter.Execute(inst);

        gpr.X[0] = 0;
        pc = decoder.Dnpc;
    }

    public void Exec(int t)
    {
        for (int i = 0; i < t; i++)
        {
            ExecOnce();
        }

    }

    public void PrintGpr()
    {
        Console.ForegroundColor = ConsoleColor.DarkMagenta;
        Console.WriteLine($"pc   :{pc:X8} {pc}");
        foreach (var reg in Enum.GetValues<Gpr.REG_ENUM_X>())
        {
            Console.WriteLine($"{reg,-5}:{gpr.X[(int)reg]:X8} {gpr.X[(int)reg]}");
        }
        foreach (var reg in Enum.GetValues<Gpr.REG_ENUM_F>())
        {
            Console.WriteLine($"{reg,-5}:{gpr.F[(int)reg]}");
        }
        Console.ResetColor();
    }
}

class Decoder
{
    public uint PC { get; set; }
    public uint Inst { get; set; }
    public uint Dnpc { get; set; }
    public uint Snpc => PC + 4;
    public uint Rd => Inst.Bits(11, 7);
    public uint Rs1 => Inst.Bits(19, 15);
    public uint Rs2 => Inst.Bits(24, 20);
    public int ImmI => Inst.Bits(31, 20).SignExt(12);
    public int ImmU => Inst.Bits(31, 12).SignExt(20) << 12;
    public int ImmS => ((Inst.Bits(31, 25) << 5) | Inst.Bits(11, 7)).SignExt(12);
    public int ImmJ => ((Inst.Bits(31, 31) << 20) | (Inst.Bits(19, 12) << 12)
                    | (Inst.Bits(20, 20) << 11) | (Inst.Bits(30, 21) << 1)).SignExt(21);
    public int ImmB => ((Inst.Bits(31, 31) << 12) | (Inst.Bits(7, 7) << 11)
                    | (Inst.Bits(30, 25) << 5) | (Inst.Bits(11, 8) << 1)).SignExt(13);
    public uint Rm => Inst.Bits(14, 12);
    public uint Rs3 => Inst.Bits(31, 27);

    public uint I => Inst.Bits(31, 30);
    public uint J => Inst.Bits(29, 28);

}

class InstExcuter
{
    internal (string InstPattern, Action Act)[] execTable;
    public InstExcuter(Cpu cpu)
    {

        Gpr r = cpu.gpr;
        Memory m = cpu.memory;
        Decoder d = cpu.decoder;
        execTable =
        [
#region I
            // add    
            ("0000000..........000.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] + r.X[d.Rs2]),
            // and    
            ("0000000..........111.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] & r.X[d.Rs2]),
            // auipc  
            (".........................0010111",() => r.X[d.Rd] = (uint)(d.PC + d.ImmU)),
            // addi   
            (".................000.....0010011",() => r.X[d.Rd] = (uint)(r.X[d.Rs1] + d.ImmI)),
            // andi   
            (".................111.....0010011",() => r.X[d.Rd] = (uint)(r.X[d.Rs1] & d.ImmI)),

            // beq    
            (".................000.....1100011",() => { if (r.X[d.Rs1] == r.X[d.Rs2]) d.Dnpc = (uint)(d.PC + d.ImmB); }),
            // bne    
            (".................001.....1100011",() => { if (r.X[d.Rs1] != r.X[d.Rs2]) d.Dnpc = (uint)(d.PC + d.ImmB); }),
            // blt    
            (".................100.....1100011",() => { if (((int)r.X[d.Rs1]) < ((int)r.X[d.Rs2])) d.Dnpc = (uint)(d.PC + d.ImmB); }),
            // bge    
            (".................101.....1100011",() => { if (((int)r.X[d.Rs1]) >= ((int)r.X[d.Rs2])) d.Dnpc = (uint)(d.PC + d.ImmB); }),
            // bltu   
            (".................110.....1100011",() => { if (r.X[d.Rs1] < r.X[d.Rs2]) d.Dnpc = (uint)(d.PC + d.ImmB); }),
            // bgeu   
            (".................111.....1100011",() => { if (r.X[d.Rs1] >= r.X[d.Rs2]) d.Dnpc = (uint)(d.PC + d.ImmB); }),

            // ebreak 
            ("00000000000100000000000001110011",() => throw new Ebreak()),
            // ecall  
            ("00000000000000000000000001110011",()=>ToDo("ecall")),
            // fence  
            ("0000.............000.....0001111",()=>ToDo("fence")),

            // jal    
            (".........................1101111",() => { r.X[d.Rd] = d.Snpc; d.Dnpc = (uint)(d.PC + d.ImmJ); }),
            // jalr   
            (".................000.....1100111",() => { r.X[d.Rd] = d.Snpc; d.Dnpc = (uint)(r.X[d.Rs1] + d.ImmI); }),

            // lb     
            (".................000.....0000011",() => r.X[d.Rd] = (uint)m[(uint)(r.X[d.Rs1] + d.ImmI),1].SignExt(8)),
            // lh     
            (".................001.....0000011",() => r.X[d.Rd] = (uint)m[(uint)(r.X[d.Rs1] + d.ImmI),2].SignExt(16)),
            // lbu    
            (".................100.....0000011",() => r.X[d.Rd] = m[(uint)(r.X[d.Rs1] + d.ImmI),1]),
            // lhu    
            (".................101.....0000011",() => r.X[d.Rd] = m[(uint)(r.X[d.Rs1] + d.ImmI),2]),
            // lw     
            (".................010.....0000011",() => r.X[d.Rd] = m[(uint)(r.X[d.Rs1] + d.ImmI),4]),

            // lui    
            (".........................0110111",() => r.X[d.Rd] = (uint)d.ImmU),

           
            // ori    
            (".................110.....0010011",() => r.X[d.Rd] = r.X[d.Rs1] | (uint)d.ImmI),
            // or     
            ("0000000..........110.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] | r.X[d.Rs2]),

            // sb     
            (".................000.....0100011",() => m[(uint)(r.X[d.Rs1] + d.ImmS),1]=r.X[d.Rs2]),
            // sh     
            (".................001.....0100011",() => m[(uint)(r.X[d.Rs1] + d.ImmS),2]=r.X[d.Rs2]),
            // sw     
            (".................010.....0100011",() => m[(uint)(r.X[d.Rs1] + d.ImmS),4]=r.X[d.Rs2]),

            // slli   
            ("0000000..........001.....0010011",() => r.X[d.Rd] = r.X[d.Rs1] << d.ImmI),
            // srli   
            ("0000000..........101.....0010011",() => r.X[d.Rd] = r.X[d.Rs1] >> d.ImmI),
            // srai   
            ("0100000..........101.....0010011",() => r.X[d.Rd] = (uint)((int)r.X[d.Rs1] >> (int)(d.ImmI & 0x1Fu))),

            // slti   
            (".................010.....0010011",() => r.X[d.Rd] = ((int)r.X[d.Rs1]) < d.ImmI ? 1u : 0u),
            // sltiu  
            (".................011.....0010011",() => r.X[d.Rd] = r.X[d.Rs1] < d.ImmI ? 1u : 0u),

            // sll    
            ("0000000..........001.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] << (int)(r.X[d.Rs2] & 0x1F)),
            // slt    
            ("0000000..........010.....0110011",() => r.X[d.Rd] = ((int)r.X[d.Rs1]) < ((int)r.X[d.Rs2]) ? 1u : 0u),
            // sltu   
            ("0000000..........011.....0110011",() => r.X[d.Rd] = (r.X[d.Rs1] < r.X[d.Rs2]) ? 1u : 0u),
            // srl    
            ("0000000..........101.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] >> (int)(r.X[d.Rs2] & 0x1F)),
            // sra    
            ("0100000..........101.....0110011",() => r.X[d.Rd] = (uint)((int)r.X[d.Rs1] >> (int)(r.X[d.Rs2] & 0x1F))),
            // sub    
            ("0100000..........000.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] - r.X[d.Rs2]),
            // xor    
            ("0000000..........100.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] ^ r.X[d.Rs2]),

            // xori   
            (".................100.....0010011",() => r.X[d.Rd] = r.X[d.Rs1] ^ (uint)d.ImmI),
#endregion
#region M
            // div    
            ("0000001..........100.....0110011",() => r.X[d.Rd] = (uint)((int)r.X[d.Rs1] / (int)r.X[d.Rs2])),
            // divu   
            ("0000001..........101.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] / r.X[d.Rs2]),
                        // rem    
            ("0000001..........110.....0110011",() => r.X[d.Rd] = (uint)(((int)r.X[d.Rs1]) % ((int)r.X[d.Rs2]))),
            // remu   
            ("0000001..........111.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] % r.X[d.Rs2]),
             // mul    
            ("0000001..........000.....0110011",() => r.X[d.Rd] = r.X[d.Rs1] * r.X[d.Rs2]),
            // mulh   
            ("0000001..........001.....0110011",() => r.X[d.Rd] = (uint)(int)(((int)r.X[d.Rs1] * (long)(int)r.X[d.Rs2]) >> 32)),
            // mulhu  
            ("0000001..........011.....0110011",() => r.X[d.Rd] = (uint)((r.X[d.Rs1] * (ulong)r.X[d.Rs2]) >> 32)),
#endregion
#region F
            
            //FLW
            (".................010.....0000111",()=>r.F[d.Rd]= m[(uint)(r.X[d.Rs1]+d.ImmI),4].Bin2<float>()),
            //FSW
            (".................010.....0100111",()=>m[(uint)(r.X[d.Rs1]+d.ImmS),4]=r.F[d.Rd].Float2Bin()),
            //FMADD.S
            (".....00..................1000011",()=>r.F[d.Rd]=r.F[d.Rs1]*r.F[d.Rs2]+r.F[d.Rs3]),
            //FMSUB.S
            (".....00..................1000111",()=>r.F[d.Rd]=r.F[d.Rs1]*r.F[d.Rs2]-r.F[d.Rs3]),
            //FNMSUB.S
            (".....00..................1001011",()=>r.F[d.Rd]=-r.F[d.Rs1]*r.F[d.Rs2]+r.F[d.Rs3]),
            //FNMADD.S
            (".....00..................1001111",()=>r.F[d.Rd]=-r.F[d.Rs1]*r.F[d.Rs2]-r.F[d.Rs3]),
            //FADD.S
            ("0000000..................1010011",()=>r.F[d.Rd]=r.F[d.Rs1]+r.F[d.Rs2]),
            //FSUB.S
            ("0000100..................1010011",()=>r.F[d.Rd]=r.F[d.Rs1]-r.F[d.Rs2]),
            //FMUL.S
            ("0001000..................1010011",()=>r.F[d.Rd]=r.F[d.Rs1]*r.F[d.Rs2]),
            //FDIV.S
            ("0001100..................1010011",()=>r.F[d.Rd]=r.F[d.Rs1]/r.F[d.Rs2]),
            //FSQRT.S
            ("010110000000.............1010011",()=>r.F[d.Rd]=(float)Math.Sqrt(r.F[d.Rs1])),
            //FSGNJ.S
            ("0010000..........000.....1010011",()=>r.F[d.Rd]=(r.F[d.Rs2].Bit(31)|r.F[d.Rs1].Bits(30,0)).Bin2<float>()),
            //FSGNJN.S
            ("0010000..........001.....1010011",()=>r.F[d.Rd]=(~r.F[d.Rs2].Bit(31)|r.F[d.Rs1].Float2Bin().Bits(30,0)).Bin2<float>()),
            //FSGNJX.S
            ("0010000..........010.....1010011",()=>r.F[d.Rd]=(((r.F[d.Rs2].Bit(31))^(r.F[d.Rs2].Bit(31)))|r.F[d.Rs1].Bits(30,0)).Bin2<float>()),
            //FMIN.S
            ("0010100..........000.....1010011",()=>r.F[d.Rd]=Math.Min(r.F[d.Rs1],r.F[d.Rs2])),
            //FMAX.S
            ("0010100..........001.....1010011",()=>r.F[d.Rd]=Math.Max(r.F[d.Rs1],r.F[d.Rs2])),
            //FCVT.W.S
            ("110000000000.............1010011",()=>r.X[d.Rd]=(uint)(int)r.F[d.Rs1]),
            //FCVT.WU.S
            ("110000000001.............1010011",()=>r.X[d.Rd]=(uint)r.F[d.Rs1]),
            //FMV.X.W
            ("111000000000.....000.....1010011",()=>r.X[d.Rd]=r.F[d.Rs1].Float2Bin()),
            //FEQ.S
            ("1010000..........010.....1010011",()=>r.X[d.Rd]=r.F[d.Rs1]==r.F[d.Rs2]?1u:0u),
            //FLT.S
            ("1010000..........001.....1010011",()=>r.X[d.Rd]=r.F[d.Rs1]<r.F[d.Rs2]?1u:0u),
            //FLE.S
            ("1010000..........000.....1010011",()=>r.X[d.Rd]=r.F[d.Rs1]<=r.F[d.Rs2]?1u:0u),
            //FCLASS.S
            ("111000000000.....001.....1010011",()=>ToDo("fclass.s")),
            //FCVT.S.W
            ("110100000000.............1010011",()=>r.F[d.Rd]=(int)r.X[d.Rs1]),
            //FCVT.S.WU
            ("110100000001.............1010011",()=>r.F[d.Rd]=r.X[d.Rs1]),
            //FMV.W.X
            ("111100000000.....000.....1010011",()=>r.F[d.Rd]=r.X[d.Rs1].Bin2<float>()),
#endregion
#region S
            // smmv.f.e
            ("....000..........000.....1010111",()=>r.F[d.Rd]=r.M[d.Rs1][d.I,d.J]),
            // smmv.e.f
            ("....001..........000.....1010111",()=>r.M[d.Rd][d.I,d.J]=r.F[d.Rs2] ),
            //smtsr
            ("....000..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].SwapRow(d.I,d.J)),
            //smtsr
            ("....001..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].SwapCol(d.I,d.J)),
            //smtmr
            ("....010..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].MultiplyRow(r.F[d.Rs2],d.I)),
            //smtmc
            ("....011..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].MultiplyCol(r.F[d.Rs2],d.I)),
            //smtar
            ("....100..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].AdditionRow(r.F[d.Rs2],d.I,d.J))  ,
            //smtac
            ("....101..........001.....1010111",()=>r.M[d.Rd]=r.M[d.Rs1].AdditionCol(r.F[d.Rs2],d.I,d.J))  ,
            //smtt
            ("0000000..........001.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1].Transpose),
            //smgen
            ("0000000..........000.....1011011",()=>r.M[d.Rd]=new((i,j)=>r.F[d.Rd])),
            //smgend
            ("0000001..........000.....1011011",()=>r.M[d.Rd]=new((i,j)=>i==j?r.F[d.Rd]:0)),
            //sml
            (".................000.....1111011",()=>r.M[d.Rd]=new((i,j)=>m[(uint)(r.X[d.Rs1]+d.ImmI+4*((4*i)+j)),4].Bin2<float>())),
            //smld
            (".................001.....1111011",()=>r.M[d.Rd]=new((i,j)=>i==j?m[(uint)(r.X[d.Rs1]+d.ImmI+2*(i+j)),4].Bin2<float>():0)),
            //sms
            (".................000.....1111111",()=>r.M[d.Rs2].ForEach((i,j,mij)=>m[(uint)(r.X[d.Rs1]+d.ImmS+4*((4*i)+j)),4]=mij.Float2Bin())),
            //sms
            (".................001.....1111111",()=>r.M[d.Rs2].ForEach((i,j,mij)=>{if(i==j) m[(uint)(r.X[d.Rs1] + d.ImmS + 2*(i+j)), 4] = mij.Float2Bin(); })),
            //smtr
            ("0000010..........001.....1011011",()=>r.F[d.Rd]=r.M[d.Rs1].Trace),
            //smdet
            ("0000011..........001.....1011011",()=>r.F[d.Rd]=r.M[d.Rs1].Determinant),
            //smadd
            ("0000000..........010.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1]+r.M[d.Rs2]),
            //smsub
            ("0000001..........010.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1]-r.M[d.Rs2]),
            //smmul
            ("0000010..........010.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1]*r.M[d.Rs2]),
            //smdiv
            ("0000011..........010.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1]/r.M[d.Rs2]),
            //smmmp
            ("0000100..........010.....1011011",()=>r.M[d.Rd]=r.M[d.Rs1]%r.M[d.Rs2]),
            //smmadd
            (".....00..........000.....1011111",()=>r.M[d.Rd]=r.M[d.Rs1]%r.M[d.Rs2]+r.M[d.Rs3]),
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
