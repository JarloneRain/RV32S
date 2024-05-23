`include "define.v"

module WB_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output ready,
    input ME_valid
);
    assign ready = 1;
    always @(posedge clk) valid <= ready & ME_valid;
endmodule

module GprMux (
    input ME_valid,
    input [6:0] opcode,
    input [6:0] funct7,
    input [2:0] funct3,
    input [2:0] funct3Y,
    input [1:0] funct2R4,
    //
    input [31:0] ALU_OUT2_res_R,
    input [31:0] ALU_OUT2_res_F,
    input [511:0] ALU_OUT2_res_M,
    //
    input DC_R_valid,
    input [31:0] DC_data_R,
    input DC_F_valid,
    input [31:0] DC_data_F,
    input DC_M_valid,
    input [511:0] DC_data_M,
    //
    output reg we,
    output reg [31:0] R,
    output reg [31:0] F,
    output reg [511:0] M
);
    always @(*) begin
        case (opcode)
            // lui auipc jal jalr
            7'b0110111, 7'b0010111, 7'b1101111, 7'b1100111: begin
                we = ME_valid;
                R  = ALU_OUT2_res_R;
                F  = 0;
                M  = 0;
            end
            // branch
            7'b1100011: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end

            // load
            7'b0000011: begin
                we = ME_valid & DC_R_valid;
                R  = DC_data_R;
                F  = 0;
                M  = 0;
            end
            // store
            7'b0100011: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end
            // type I,type R
            7'b0010011, 7'b0110011: begin
                we = ME_valid;
                R  = ALU_OUT2_res_R;
                F  = 0;
                M  = 0;
            end
            // fence 
            7'b0001111: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end
            // ecall ebreak csrxxx
            7'b1110011: begin
                we = ME_valid;
                // no csr
                R  = 0;
                F  = 0;
                M  = 0;
            end
            // flw
            7'b0000111: begin
                we = ME_valid & DC_F_valid;
                R  = 0;
                F  = DC_data_F;
                M  = 0;
            end
            // fsw
            7'b0100111: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end
            // type R4 type R
            7'b1000011, 7'b1010011: begin
                we = ME_valid;
                R  = 0;
                F  = ALU_OUT2_res_F;
                M  = 0;
            end
            // type Y
            7'b1010111: begin
                we = ME_valid;
                R  = 0;
                case (funct3Y)
                    // smmv.f.e
                    3'b000: begin
                        F = ALU_OUT2_res_F;
                        M = 0;
                    end
                    default: begin
                        F = 0;
                        M = ALU_OUT2_res_M;
                    end
                endcase
            end
            // sml(d)
            7'b1111011: begin
                we = ME_valid & DC_M_valid;
                R  = 0;
                F  = 0;
                M  = DC_data_M;
            end
            // sms(d)
            7'b1111111: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end
            // matrix gen and cal
            7'b1011011: begin
                we = ME_valid;
                R  = 0;
                F  = 0;
                M  = ALU_OUT2_res_M;
            end
            default: begin
                we = 0;
                R  = 0;
                F  = 0;
                M  = 0;
            end
        endcase
    end
endmodule

module Gpr (
    input clk,
    input rst,

    input we,

    // 三个din接访存阶段的对应寄存器

    input [1:0] rd_group,
    input [4:0] rd_index,

    input [ 31:0] din_R,
    input [ 31:0] din_F,
    input [511:0] din_M,

    // 下面这三组端口接到Srcs里，先把值取出来暂存

    input  [  1:0] rs1_group,
    input  [  4:0] rs1_index,
    output [ 31:0] dout_R_rs1,
    output [ 31:0] dout_F_rs1,
    output [511:0] dout_M_rs1,

    input  [  1:0] rs2_group,
    input  [  4:0] rs2_index,
    output [ 31:0] dout_R_rs2,
    output [ 31:0] dout_F_rs2,
    output [511:0] dout_M_rs2,

    input  [  1:0] rs3_group,
    input  [  4:0] rs3_index,
    output [ 31:0] dout_R_rs3,
    output [ 31:0] dout_F_rs3,
    output [511:0] dout_M_rs3
);
    integer i, j, k;
    reg [ 31:0] R[0:31];
    reg [ 31:0] F[0:31];
    reg [511:0] M[0:31];

    assign dout_R_rs1 = rs1_group == `REG_GROUP_R ? R[rs1_index] : 0;
    assign dout_F_rs1 = rs1_group == `REG_GROUP_F ? F[rs1_index] : 0;
    assign dout_M_rs1 = rs1_group == `REG_GROUP_M ? M[rs1_index] : 0;
    assign dout_R_rs2 = rs2_group == `REG_GROUP_R ? R[rs2_index] : 0;
    assign dout_F_rs2 = rs2_group == `REG_GROUP_F ? F[rs2_index] : 0;
    assign dout_M_rs2 = rs2_group == `REG_GROUP_M ? M[rs2_index] : 0;
    assign dout_R_rs3 = rs3_group == `REG_GROUP_R ? R[rs3_index] : 0;
    assign dout_F_rs3 = rs3_group == `REG_GROUP_F ? F[rs3_index] : 0;
    assign dout_M_rs3 = rs3_group == `REG_GROUP_M ? M[rs3_index] : 0;

    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1) begin
                R[k] <= 0;
                F[k] <= 0;
                M[k] <= 0;
            end
        end else if (we) begin
            case (rd_group)
                `REG_GROUP_R: begin
                    if (rd_index != `zero5) begin
                        R[rd_index] <= din_R;
                        $display("R[%d]<=%h", rd_index, din_R);
                    end
                end
                `REG_GROUP_F: F[rd_index] <= din_F;
                `REG_GROUP_M: M[rd_index] <= din_M;
                `REG_GROUP_INVALID:  /*do nothing*/;
            endcase
        end
    end
endmodule

module PC (
    input clk,
    input rst,
    // 这不是通信协议
    input ME_valid,
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
            if (pc_opt & ME_valid) begin
                pc <= npc;
            end else if (AR_ready & valid) begin
                pc <= pc + 4;
            end
        end
    end

endmodule
