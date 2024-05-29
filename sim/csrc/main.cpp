#include "VTop.h"
#include "logger.h"
#include "utils.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "dpic.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

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

Logger logger;

class Memory_t
{
    uint8_t theMemory[MEMORY_SIZE];

public:
    uint32_t &operator[](uint32_t addr)
    {
        if (MBASE <= addr && addr <= MBASE + MEMORY_SIZE)
            return *(uint32_t *)&theMemory[addr - MBASE];
        throw stringf("Try access %u.", addr);
    }

    // void Write(uint32_t addr, uint32_t data, uint32_t dsize0)
    // {
    //     if (MBASE <= addr && addr <= MBASE + MEMORY_SIZE)
    //     {
    //         for (uint32_t i; i < (1 << dsize0); i++)
    //         {
    //             theMemory[addr + i - MBASE] = *(i + (uint8_t *)&data);
    //         }
    //         return;
    //     }
    //     throw stringf("Try write %u.",addr);
    // }

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

extern "C" int mem_read(uint32_t addr)
{
    return Memory[addr];
}

extern "C" bool mem_write(uint32_t addr, uint32_t data, bool wstrb0, bool wstrb1, bool wstrb2, bool wstrb3)
{
    uint32_t &word = Memory[addr];
    if (wstrb0)
        word = (word & 0xffffff00) | (data & 0x000000ff);
    if (wstrb1)
        word = (word & 0xffff00ff) | (data & 0x0000ff00);
    if (wstrb2)
        word = (word & 0xff00ffff) | (data & 0x00ff0000);
    if (wstrb3)
        word = (word & 0x00ffffff) | (data & 0xff000000);
    return true;
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
        top->trace(tfp, 2);
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
        top->eval();
        tfp->dump(ctx->time());
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
    // logger.Log<Logger::BLACK, Logger::WHITE>("bin:%s\ntxt:%s", argv[1], argv[2]);
    // init_disasm("riscv32-pc-linux-gnu");
    Memory.loadImg(argv[1]);
    // tracer.Init(stringf("%s.txt", argv[1]).c_str());
    Sim *sim = new Sim();
    try
    {
        int t = 100000;
        for (sim->Init(); !sim->Finish(); sim->Update())
        {
            t--;
            if (t == 0)
            {
                break;
            }
            // logger.YellowFont("%d", __LINE__);
        }
    }
    catch (std::string &e)
    {
        std::cout << e << std::endl;
    }

    delete sim;
    return exit_code;
}
