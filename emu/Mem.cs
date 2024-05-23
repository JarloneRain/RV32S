namespace RV32Semu;

class Memory
{
    const uint MEMORY_SIZE = 1 * 1024 * 1024;//1MB
    const uint MEMORY_BASE = 0x80000000;
    byte[] memory = new byte[MEMORY_SIZE];
    bool IsAddrValid(uint addr) => MEMORY_BASE <= addr && addr < MEMORY_BASE + MEMORY_SIZE;


    public Memory()
    {
        //auipc
        memory[3] = 0x00; memory[2] = 0x00; memory[1] = 0x05; memory[0] = 0x37;
        //ebreak
        memory[7] = 0x00; memory[6] = 0x10; memory[5] = 0x00; memory[4] = 0x73;
    }

    public void Print(uint addr, uint words)
    {
        if (!IsAddrValid(addr)) throw new Exception($"Address 0x{addr:X8} is out of memory!");
        addr -= MEMORY_BASE;
        Console.ForegroundColor = ConsoleColor.DarkCyan;
        for (uint i = 0; i < words; i++)
        {
            // Span<byte> b = stackalloc byte[4];
            // uint word;
            // for (int j = 0; j < 4; j++)
            // {
            //     b[j] = memory[addr + 4 * i + j];
            //     word += (uint)b[j] << (8 * j);
            // }
            byte b0 = memory[addr + 4 * i],
                b1 = memory[addr + 4 * i + 1],
                b2 = memory[addr + 4 * i + 2],
                b3 = memory[addr + 4 * i + 3];
            uint word = (uint)(b0 + (b1 << 8) + (b2 << 16) + (b3 << 24));
            Console.WriteLine($"{MEMORY_BASE + addr + 4 * i:X8} : {b0:X2} {b1:X2} {b2:X2} {b3:X2} : {(int)word,12}\t{word.WordTo<float>()}");
        }
        Console.ResetColor();
    }
    public void Init(string path)
    {
        var bytes = File.ReadAllBytes(path);
        Buffer.BlockCopy(bytes, 0, memory, 0, bytes.Length);
    }

    public virtual uint this[uint addr, int bytes]
    {
        get
        {
            if (!IsAddrValid(addr)) throw new Exception($"Address 0x{addr:X8} is out of memory!");
            addr -= MEMORY_BASE;
            uint res = 0;
            for (int i = 0; i < bytes; i++)
            {
                res += (uint)memory[addr + i] << (8 * i);
            }
            return res;
        }
        set
        {
            if (!IsAddrValid(addr)) throw new Exception($"Address 0x{addr:X8} is out of memory!");
            addr -= MEMORY_BASE;
            for (int i = 0; i < bytes; i++)
            {
                memory[addr + i] = (byte)(value & 0xFF);
                value >>= 8;
            }
        }
    }
}