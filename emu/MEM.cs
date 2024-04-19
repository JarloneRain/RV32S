namespace RV32Semu;

class Memory
{
    const uint MEMORY_SIZE = 1 * 1024 * 1024;//1MB
    const uint MEMORY_BASE = 0x80000000;
    byte[] memory = new byte[MEMORY_SIZE];
    Tracer tracer;
    public Memory(Tracer tracer)
    {
        this.tracer = tracer;
        //auipc
        memory[3] = 0x00; memory[2] = 0x00; memory[1] = 0x05; memory[0] = 0x37;
        //ebreak
        memory[6] = 0x00; memory[6] = 0x10; memory[5] = 0x00; memory[4] = 0x73;
    }

    public void Init(string path)
    {
        var bytes = File.ReadAllBytes(path);
        Buffer.BlockCopy(bytes, 0, memory, 0, bytes.Length);
    }

    public uint this[uint addr, int bytes]
    {
        get
        {
            if (MEMORY_BASE <= addr && addr < MEMORY_BASE + MEMORY_SIZE)
            {
                addr -= MEMORY_BASE;
                uint res = 0;
                for (int i = 0; i < bytes; i++)
                {
                    res += (uint)memory[addr + i] << (8 * i);
                }
                tracer.MemReadTrace(addr + MEMORY_BASE, bytes, res);
                return res;
            }
            throw new Exception($"Address 0x{addr:X8} is out of memory!");
        }
        set
        {
            if (MEMORY_BASE <= addr && addr < MEMORY_BASE + MEMORY_SIZE)
            {
                addr -= MEMORY_BASE;
                for (int i = 0; i < bytes; i++)
                {
                    memory[addr + i] = (byte)(value & 0xFF);
                    value >>= 8;
                }
                tracer.MemWriteTrace(addr + MEMORY_BASE, bytes, value);
                return;
            }
            throw new Exception($"Address 0x{addr:X8} is out of memory!");
        }
    }
}