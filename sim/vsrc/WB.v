`include "define.v"

module WB_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output reg ready,
    input ME_valid
);
    always @(*) begin
        ready <= 1;
    end
endmodule

module Gpr (
    input clk,
    input rst,

    // 三个din接访存阶段的对应寄存器

    input [1:0] rd_group,
    input [4:0] rd_index,
    input [31:0] din_R,
    input [31:0] din_F,
    input [31:0] din_M[0:3][0:3],

    // 下面这三组接口直接接到EX

    input  [ 1:0] rs1_group,
    input  [ 4:0] rs1_index,
    output [31:0] dout_R_rs1,
    output [31:0] dout_F_rs1,
    output [31:0] dout_M_rs1[0:3][0:3],

    input  [ 1:0] rs2_group,
    input  [ 4:0] rs2_index,
    output [31:0] dout_R_rs2,
    output [31:0] dout_F_rs2,
    output [31:0] dout_M_rs2[0:3][0:3],

    input  [ 1:0] rs3_group,
    input  [ 4:0] rs3_index,
    output [31:0] dout_R_rs3,
    output [31:0] dout_F_rs3,
    output [31:0] dout_M_rs3[0:3][0:3]
);
    integer i, j, k;
    reg [31:0] R[0:31];
    reg [31:0] F[0:31];
    reg [31:0] M[0:31] [0:3][0:3];

    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1) begin
                R[k] <= 0;
                F[k] <= 0;
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        M[k][i][j] <= 0;
                    end
                end
            end
        end else begin
            case (rd_group)
                `REG_GROUP_R: begin
                    if (rd_index != `zero5) begin
                        R[rd_index] <= din_R;
                    end
                end
                `REG_GROUP_F: F[rd_index] <= din_F;
                `REG_GROUP_M: begin
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            M[rd_index] <= din_M[i][j];
                        end
                    end
                end
            endcase
        end
    end
endmodule

module PC (
    input clk,
    input rst,
    // 这不是通信协议
    input ready,
    input AR_ready,
    input IF_ready,
    output valid,
    input pc_opt,
    input [31:0] npc,
    output reg [31:0] pc
);
    assign valid = IF_ready;
    always @(posedge clk) begin
        if (rst) begin
            pc <= `PC_BASE;
        end else begin
            if (pc_opt) begin
                pc <= npc;
            end else if (AR_ready & valid) begin
                pc <= pc + 4;
            end
        end
    end

endmodule
