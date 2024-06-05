`include "define.v"

module ME_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output ready,
    input WB_ready,
    input EX_valid,
    input [5:0] Data_Cache_state
);

    assign ready = (WB_ready | !valid) & (Data_Cache_state == `STATE_FREE);
    always @(posedge clk)
        if (rst) valid <= 0;
        else valid <= ready ? EX_valid : valid;
endmodule


module Inst3 (
    input clk,
    input ready,
    // 指令字段
    input [6:0] _opcode,
    input [6:0] _funct7,
    input [2:0] _funct3,
    input [2:0] _funct3Y,
    input [1:0] _funct2R4,
    // 寄存器字段
    input [1:0] _rd_group,
    input [4:0] _rd_index,
    // pc操作
    input _pc_opt,
    // 功能码
    output reg [6:0] opcode,
    output reg [6:0] funct7,
    output reg [2:0] funct3,
    output reg [2:0] funct3Y,
    output reg [1:0] funct2R4,
    // 寄存器相关字段
    output reg [1:0] rd_group,
    output reg [4:0] rd_index,
    // pc操作
    output reg pc_opt
);
    always @(posedge clk) begin
        if (ready) begin
            opcode   <= _opcode;
            funct7   <= _funct7;
            funct3   <= _funct3;
            funct3Y  <= _funct3Y;
            funct2R4 <= _funct2R4;
            //
            rd_group <= _rd_group;
            rd_index <= _rd_index;
            //
            pc_opt   <= _pc_opt;
        end
    end
endmodule


module ALU_OUT2 (
    input clk,
    input ready,
    // ALU 的计算结果
    input [31:0] _npc,
    input [31:0] _res_R,
    input [31:0] _res_F,
    input [511:0] _res_M,
    // ALU 的计算结果
    output reg [31:0] npc,
    output reg [31:0] res_R,
    output reg [31:0] res_F,
    output reg [511:0] res_M
);
    always @(posedge clk) begin
        if (ready) begin
            npc   <= _npc;
            res_R <= _res_R;
            res_F <= _res_F;
            res_M <= _res_M;
        end
    end
endmodule


