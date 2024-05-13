#ifndef __TRACER_H
#define __TRACER_H

#include "logger.h"
#include "utils.h"
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <elf.h>
#include <fstream>
#include <iostream>
#include <map>
#include <stack>
#include <string>
#include <vector>

using std::make_pair;

#define MAX_SHTAB_NUM 16

struct Decode {
    uint32_t pc;
    uint32_t snpc;
    uint32_t dnpc;
    uint32_t inst;
};

struct MemOpt {
    bool     isRead;
    size_t   wbytes;
    uint32_t pc;
    uint32_t addr;
    uint32_t data;
};

class Tracer {
public:
    enum TRACE_TYPE_ENUM {
        INST_TRACE = 1,
        FUNC_TRACE = 2,
        RMEM_TRACE = 4,
        WMEM_TRACE = 8
    };

private:
    Logger                                                    logger;
    size_t                                                    logCount;
    std::map<std::pair<size_t, TRACE_TYPE_ENUM>, std::string> logBuf;
    size_t                                                    T;

    const TRACE_TYPE_ENUM TRACE_TYPES[4] = {INST_TRACE, FUNC_TRACE, RMEM_TRACE, WMEM_TRACE};

    // ftrace
    std::stack<uint32_t> callStack;
    struct FuncInfo {
        uint32_t    addr;
        std::string name;
    };
    std::vector<FuncInfo> funcInfos;
    // itrace
    struct InstInfo {
        uint32_t    code;
        std::string dasm;
    };
    std::map<uint32_t, InstInfo> insts;

public:
    void Init(const char *txtPath) {
        using namespace std;
        fstream txtFile;
        txtFile.open(txtPath, ios::in);

        string line;

        for(size_t i = 0; i < 5; i++) {
            getline(txtFile, line);
        }
        while(!txtFile.eof()) {
            getline(txtFile, line);
            if(line == "") {
                uint32_t addr;
                char     buf[1024];
                FuncInfo fi;
                getline(txtFile, line);
                sscanf(line.c_str(), "%x <%s>:", &addr, buf);
                fi.addr = addr;
                fi.name = buf;
                funcInfos.emplace_back(fi);
                // logger.YellowFont(buf);
                // logger.YellowBack(fi.name.c_str());
                // printf("%s\n", fi.name.c_str());
            } else {
                uint32_t pc;
                uint32_t inst;
                char     buf[1024];
                InstInfo ii;
                sscanf(line.c_str(), "%x: %x %[^\n]", &pc, &inst, buf);
                ii.code   = inst;
                ii.dasm   = buf;
                insts[pc] = ii;
            }
        }
    }

    void Log(size_t count = 10, uint32_t select = INST_TRACE | FUNC_TRACE | RMEM_TRACE | WMEM_TRACE) {
#define LOG_IF(SELECT, COLOR...)                                       \
    do {                                                               \
        auto theKey = make_pair(t, SELECT);                            \
        if((select & SELECT) && logBuf.find(theKey) != logBuf.end()) { \
            logger.COLOR(logBuf[make_pair(t, SELECT)].c_str());        \
        }                                                              \
    } while(0)
        size_t s = T < count ? 0 : T - count;

        for(size_t t = s; t < T; t++) {
            LOG_IF(WMEM_TRACE, Log<Logger::GREEN, Logger::BLUE>);
            LOG_IF(INST_TRACE, RedBack);
            LOG_IF(FUNC_TRACE, GreenBack);
            LOG_IF(RMEM_TRACE, Log<Logger::RED, Logger::BLUE>);
        }
#undef LOG_IF
    }

    void Update(bool clk) {
        T += clk;
    }
    void InstTrace(uint32_t pc, uint32_t inst) {
        char buf[1024] = "";
        // disassemble(buf, 1024, pc, (uint8_t *)&inst, 4);
        logBuf[make_pair(T, INST_TRACE)] = stringf(
            "%08X : %02X %02X %02X %02X\t%s", pc,
            inst & 0xFF, (inst >> 8) & 0xFF,
            (inst >> 16) & 0xFF, (inst >> 24) & 0xFF,
            // disassemble(pc, (uint8_t *)&inst, 4).c_str());
            insts[pc].dasm.c_str());
    }

    void FuncTrace(uint32_t pc, uint32_t dnpc, uint32_t snpc) {
        //  return
        if(!callStack.empty() && dnpc == callStack.top()) {
            logBuf[make_pair(T, FUNC_TRACE)] = stringf(
                "          %*cret", 2 * callStack.size(), ' ');
            callStack.pop();
            return;
        }
        //  call
        for(auto funcInfo = funcInfos.begin(); funcInfo != funcInfos.end(); ++funcInfo) {
            if(dnpc == funcInfo->addr) {
                callStack.push(snpc);
                logBuf[make_pair(T, FUNC_TRACE)] = stringf(
                    "          %*ccall [%08X@<%s]", 2 * callStack.size(), ' ',
                    funcInfo->addr, funcInfo->name.c_str());

                return;
            }
        }
    }
    void RmemTrace(uint32_t addr, uint32_t data) {
        logBuf[make_pair(T, RMEM_TRACE)] = stringf(
            "        Read  %08X : 0x%08X %u",
            addr, data, data);
    }
    void WmemTrace(uint32_t addr, uint32_t data, uint32_t bytes) {
        logBuf[make_pair(T, WMEM_TRACE)] = stringf(
            "        Write %u bytes %08X : 0x%08X %u",
            bytes, addr, data, data);
    }
};

#endif