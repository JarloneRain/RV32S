#include "VTop.h"
#include "tracer.h"
#include "utils.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define PRINT_LINE                \
    do                            \
    {                             \
        printf("%d\n", __LINE__); \
    } while (0)

#define MEMORY_SIZE 0x8000000
#define PC_DEFAULT_VALUE 0x80000000
#define MBASE 0x80000000

static int exit_code = 0;

extern "C" void bad_finish()
{
    printf("change exit code!\n");
    exit_code = 1;
}

Tracer tracer;
Logger logger;

class Memory_t
{
    uint8_t theMemory[MEMORY_SIZE];

public:
    uint32_t operator[](uint32_t addr)
    {
        if (MBASE <= addr && addr <= MBASE + MEMORY_SIZE)
            return *(uint32_t *)&theMemory[addr - MBASE];
        throw 0;
    }

    void Write(uint32_t addr, uint32_t data, uint32_t dsize0)
    {
        if (MBASE <= addr && addr <= MBASE + MEMORY_SIZE)
        {
            for (uint32_t i; i < (1 << dsize0); i++)
            {
                theMemory[addr + i - MBASE] = *(i + (uint8_t *)&data);
            }
            return;
        }
        throw 0;
    }

    void loadImg(const char *imgFilePath)
    {
        FILE *imgFile = fopen(imgFilePath, "rb");
        size_t n = 0;
        fseek(imgFile, 0, SEEK_END);
        n = ftell(imgFile);
        fseek(imgFile, 0, SEEK_SET);
        fread(&theMemory[PC_DEFAULT_VALUE - MBASE], 1, n, imgFile);
        fclose(imgFile);
    }
} Memory;

extern "C" void data_read(uint32_t addr, bool re, uint32_t *dout, bool *err)
{
    *err = false;
    // tracer.RmemTrace()
    try
    {
        if (re)
        {
            *dout = Memory[addr];
            tracer.RmemTrace(addr, *dout);
        }
        else
        {
            *dout == 0;
        }
    }
    catch (int)
    {
        *err = true;
    }
}

extern "C" void data_write(uint32_t addr, bool we, uint32_t din, uint32_t dsize0, bool *err)
{
    *err = false;
    try
    {
        if (we)
        {
            Memory.Write(addr, din, dsize0);
            tracer.WmemTrace(addr, din, 1 << dsize0);
        }
    }
    catch (int)
    {
        *err = true;
    }
}

extern "C" void inst_read(uint32_t pc, uint32_t *inst, bool *err)
{
    *err = false;
    try
    {
        *inst = Memory[pc];
    }
    catch (int)
    {
        *err = true;
    }
}

class Sim
{
public:
    VerilatedContext *ctx;
    VTop *top;
    VerilatedVcdC *tfp;

    Sim()
    {
        ctx = new VerilatedContext;
        ctx->traceEverOn(true);
        top = new VTop{ctx};
        tfp = new VerilatedVcdC;
        top->trace(tfp, 0);
        tfp->open("wave.vcd");
    }
    void Init()
    {
        ctx->timeInc(1);
        top->clk = 0;
        top->rst = 1;
        top->eval();
        tfp->dump(ctx->time());

        ctx->timeInc(1);
        top->clk = 1;
        top->eval();
        tfp->dump(ctx->time());

        ctx->timeInc(1);
        top->rst = 0;
        top->clk = 0;
        top->eval();
        tfp->dump(ctx->time());
    }
    bool Finish()
    {
        return ctx->gotFinish();
    }
    void Update()
    {
        ctx->timeInc(1);
        top->clk = !top->clk;
        tracer.Update(top->clk);
        top->eval();
        tfp->dump(ctx->time());
        // logger.YellowFont("%s %d",__FILE__, __LINE__);
        if (top->clk)
        {
            // tracer.InstTrace(
            //     top->rootp->ysyx_23060063_top__DOT__pc,
            //     top->rootp->ysyx_23060063_top__DOT__inst);
            // tracer.FuncTrace(
            //     top->rootp->ysyx_23060063_top__DOT__pc,
            //     top->rootp->ysyx_23060063_top__DOT__dnpc,
            //     // the snpc disappear
            //     top->rootp->ysyx_23060063_top__DOT__pc + 4);
        }
    }
    ~Sim()
    {
        top->final();
        tfp->close();
        delete top;
        delete ctx;
    }
};

int main(int argc, char **argv)
{
    // printf("IMG:%s\n", argv[1]);
    logger.Log<Logger::BLACK, Logger::WHITE>(argv[1]);
    // init_disasm("riscv32-pc-linux-gnu");
    Memory.loadImg(stringf("%s.bin", argv[1]).c_str());
    tracer.Init(stringf("%s.txt", argv[1]).c_str());
    Sim *sim = new Sim();
    for (sim->Init(); !sim->Finish(); sim->Update())
    {
        // logger.YellowFont("%d", __LINE__);
    }
    tracer.Log(-1);
    delete sim;
    return exit_code;
}


