`include "define.v"

module EX_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output ready,
    input ID_valid,
    input ME_ready
);
    assign ready = ME_ready | !valid;
    always @(posedge clk) begin
        valid <= !rst & ready & ID_valid;
    end
endmodule

module Inst2 (
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

endmodule

// ALU 的实现请参考 sim/vsrc/ALU.v

module ALU_OUT1 (
    input clk,
    input ready,
    // ALU 的计算结果
    input [31:0] _npc,
    input [31:0] _res_R,
    input [31:0] _res_F,
    input [31:0] _res_M[0:3][0:3],
    //
    // ALU 的计算结果
    output reg [31:0] npc,
    output reg [31:0] res_R,
    output reg [31:0] res_F,
    output reg [31:0] res_M[0:3][0:3]
);
    integer i, j;
    always @(posedge clk) begin
        if (ready) begin
            npc   <= _npc;
            res_R <= _res_R;
            res_F <= _res_F;
            for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                res_M[i][j] <= _res_M[i][j];
            end
        end
    end
endmodule
