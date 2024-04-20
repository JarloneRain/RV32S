namespace RV32Semu;

class CpuWithTracer : Cpu
{
    Tracer tracer;
    public CpuWithTracer(Decoder decoder, Gpr gpr, Memory memory, Tracer tracer)
    : base(decoder, gpr,memory)
    {
        this.tracer = tracer;
    }
    protected override void ExecOnce()
    {
        tracer.InstTrace(pc);
        base.ExecOnce();
    }
}


class MemoryWithTracer : Memory
{
    Tracer tracer;

    public MemoryWithTracer(Tracer tracer)
    : base()
    {
        this.tracer = tracer;
    }

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
