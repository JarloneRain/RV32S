namespace RV32Semu;

class CpuWithTracer(Decoder decoder, Gpr gpr, Memory memory, Tracer tracer) : Cpu(decoder, gpr, memory)
{
    readonly Tracer tracer = tracer;

    protected override void ExecOnce()
    {
        tracer.T++;
        tracer.InstTrace(pc);
        base.ExecOnce();
        tracer.FuncTrace(decoder.Snpc, decoder.Dnpc);
    }
}


class MemoryWithTracer(Tracer tracer) : Memory()
{
    readonly Tracer tracer = tracer;

    public override uint this[uint addr, int bytes]
    {
        get
        {
            uint value;
            try
            {
                value = base[addr, bytes];
                tracer.MemReadTrace(addr, bytes, value);
                return value;
            }
            catch (Exception)
            {
                throw;
            }
        }
        set
        {
            try
            {
                base[addr, bytes] = value;
                tracer.MemWriteTrace(addr, bytes, value);
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
