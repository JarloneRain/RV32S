`include "define.v"

module ID_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output ready,
    input IF_valid,
    input EX_ready,
    // 解决写后读冲突
    // 读寄存器
    input [1:0] rs1_group,
    input [4:0] rs1_index,
    input [1:0] rs2_group,
    input [4:0] rs2_index,
    input [1:0] rs3_group,
    input [4:0] rs3_index,
    // 写寄存器
    input [1:0] I2_rd_group,
    input [4:0] I2_rd_index,
    input [1:0] I3_rd_group,
    input [4:0] I3_rd_index
);
    wire rs1_conflict_I2 = (rs1_group != `REG_GROUP_INVALID) && (rs1_group != `REG_GROUP_R || rs1_index != `zero5) && (rs1_group == I2_rd_group && rs1_index == I2_rd_index);
    wire rs1_conflict_I3 = (rs1_group != `REG_GROUP_INVALID) && (rs1_group != `REG_GROUP_R || rs1_index != `zero5) && (rs1_group == I3_rd_group && rs1_index == I3_rd_index);
    wire rs2_conflict_I2 = (rs2_group != `REG_GROUP_INVALID) && (rs2_group != `REG_GROUP_R || rs2_index != `zero5) && (rs2_group == I2_rd_group && rs2_index == I2_rd_index);
    wire rs2_conflict_I3 = (rs2_group != `REG_GROUP_INVALID) && (rs2_group != `REG_GROUP_R || rs2_index != `zero5) && (rs2_group == I3_rd_group && rs2_index == I3_rd_index);
    wire rs3_conflict_I2 = (rs3_group != `REG_GROUP_INVALID) && (rs3_group != `REG_GROUP_R || rs3_index != `zero5) && (rs3_group == I2_rd_group && rs3_index == I2_rd_index);
    wire rs3_conflict_I3 = (rs3_group != `REG_GROUP_INVALID) && (rs3_group != `REG_GROUP_R || rs3_index != `zero5) && (rs3_group == I3_rd_group && rs3_index == I3_rd_index);

    wire conflict = rs1_conflict_I2 || rs1_conflict_I3 || rs2_conflict_I2 || rs2_conflict_I3 || rs3_conflict_I2 || rs3_conflict_I3;
    assign ready = (EX_ready | !valid) & !conflict;
    always @(posedge clk) valid <= !rst & ready & IF_valid;
endmodule

// 纯组合逻辑
module IDU (
    input [31:0] inst,
    // 指令字段
    output [6:0] opcode,
    output [6:0] funct7,
    output [2:0] funct3,
    output [2:0] funct3Y,
    output [1:0] funct2R4,
    // 寄存器相关字段
    output reg [1:0] rd_group,
    output reg [4:0] rd_index,
    output reg [1:0] rs1_group,
    output reg [4:0] rs1_index,
    output reg [1:0] rs2_group,
    output reg [4:0] rs2_index,
    output reg [1:0] rs3_group,
    output reg [4:0] rs3_index,
    // 不同类型的立即数
    output [31:0] immU,
    output [31:0] immJ,
    output [31:0] immB,
    output [31:0] immS,
    output [31:0] immI,
    // Y型指令的立即数
    output [1:0] matI,
    output [1:0] matJ,
    // 是否为pc操作
    output pc_opt
);
    // 指令字段
    assign opcode = inst[6:0];
    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign funct3Y = inst[27:25];
    assign funct2R4 = inst[26:25];
    // 不同的立即数
    assign immI = {{12{inst[31]}}, inst[31:20]};
    assign immU = {inst[31:12], 12'b0};
    assign immS = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    assign immJ = {{11{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    assign immB = {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    // Y型指令的立即数
    assign matI = inst[31:30];
    assign matJ = inst[29:28];

    assign pc_opt = 1'b0 |
        /*jal   */ (opcode == 7'b1101111) |
        /*jalr  */ (opcode == 7'b1100111) |
        /*branch*/ (opcode == 7'b1100011);

    always @(*) begin
        case (opcode)
            // RV32I
            7'b0110111, 7'b0010111:  //lui,auipc
            begin
                rd_group = `REG_GROUP_R;
                rd_index = inst[11:7];
            end
            7'b1101111,7'b0000011,7'b0010011:  //jal,load,imm
            begin
                rd_group = `REG_GROUP_R;
                rd_index = inst[11:7];
            end
            7'b1100111:  //jalr
            begin
                rd_group  = `REG_GROUP_R;
                rd_index  = inst[11:7];
                rs1_group = `REG_GROUP_R;
                rs1_index = inst[19:15];
            end
            7'b1100011:  //branch
            begin
                rs1_group = `REG_GROUP_R;
                rs1_index = inst[19:15];
                rs2_group = `REG_GROUP_R;
                rs2_index = inst[24:20];
            end
            7'b0100011:  //store
            begin
                rs1_group = `REG_GROUP_R;
                rs1_index = inst[19:15];
                rs2_group = `REG_GROUP_R;
                rs2_index = inst[24:20];
            end
            7'b0110011:  //R
            begin
                rd_group  = `REG_GROUP_R;
                rd_index  = inst[11:7];
                rs1_group = `REG_GROUP_R;
                rs1_index = inst[19:15];
                rs2_group = `REG_GROUP_R;
                rs2_index = inst[24:20];
            end
            default: begin
                rd_group  = `REG_GROUP_INVALID;
                rd_index  = `zero5;
                rs1_group = `REG_GROUP_INVALID;
                rs1_index = `zero5;
                rs2_group = `REG_GROUP_INVALID;
                rs2_index = `zero5;
                rs3_group = `REG_GROUP_INVALID;
                rs3_index = `zero5;
            end
        endcase
    end
endmodule

module Inst1 (
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
    input [1:0] _rs1_group,
    input [4:0] _rs1_index,
    input [1:0] _rs2_group,
    input [4:0] _rs2_index,
    input [1:0] _rs3_group,
    input [4:0] _rs3_index,
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
    output reg [1:0] rs1_group,
    output reg [4:0] rs1_index,
    output reg [1:0] rs2_group,
    output reg [4:0] rs2_index,
    output reg [1:0] rs3_group,
    output reg [4:0] rs3_index,
    // pc操作
    output reg pc_opt
);
    always @(posedge clk) begin
        if (ready) begin
            opcode    <= _opcode;
            funct7    <= _funct7;
            funct3    <= _funct3;
            funct3Y   <= _funct3Y;
            funct2R4  <= _funct2R4;
            //
            rd_group  <= _rd_group;
            rd_index  <= _rd_index;
            rs1_group <= _rs1_group;
            rs1_index <= _rs1_index;
            rs2_group <= _rs2_group;
            rs2_index <= _rs2_index;
            rs3_group <= _rs3_group;
            rs3_index <= _rs3_index;
            //
            pc_opt    <= _pc_opt;
        end
    end
endmodule

module Srcs (
    input clk,
    input ready,
    // 从IDU接受的数据
    input [31:0] _immU,
    input [31:0] _immJ,
    input [31:0] _immB,
    input [31:0] _immS,
    input [31:0] _immI,
    input [1:0] _matI,
    input [1:0] _matJ,
    // 发送给ALU的数据
    output reg [31:0] immU,
    output reg [31:0] immJ,
    output reg [31:0] immB,
    output reg [31:0] immS,
    output reg [31:0] immI,
    output reg [1:0] matI,
    output reg [1:0] matJ
);
    always @(posedge clk) begin
        if (rst) begin
            immU <= 0;
            immJ <= 0;
            immB <= 0;
            immS <= 0;
            immI <= 0;
            matI <= 0;
            matJ <= 0;
        end else if (ready) begin
            immU <= _immU;
            immJ <= _immJ;
            immB <= _immB;
            immS <= _immS;
            immI <= _immI;
            matI <= _matI;
            matJ <= _matJ;
        end
    end
endmodule

module PC2 (
    input clk,
    input rst,
    input ready,
    //
    input [31:0] PC1_pc,
    output reg [31:0] pc
);
    always @(posedge clk) begin
        if (!rst) begin
            pc <= 0;
        end else if (ready) begin
            pc <= PC1_pc;
        end
    end
endmodule
