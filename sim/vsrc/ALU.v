// 纯组合逻辑，尽管会用reg
module ALU (
    // 指令中的操作码
    input [6:0] opcode,
    input [6:0] funct7,
    input [2:0] funct3,
    input [2:0] funct3Y,
    input [1:0] funct2R4,
    // 指令中的立即数
    input [31:0] immU,
    input [31:0] immJ,
    input [31:0] immB,
    input [31:0] immS,
    input [31:0] immI,
    input [1:0] matI,
    input [1:0] matJ,
    // 计算参数
    input [31:0] pc,
    input [31:0] src1R,
    input [31:0] src2R,
    input [31:0] src1F,
    input [31:0] src2F,
    input [31:0] src1M[0:31][0:3][0:3],
    input [31:0] src2M[0:31][0:3][0:3],
    // 计算结果
    output reg [31:0] npc,
    output reg [31:0] res_R,
    output reg [31:0] res_F,
    output reg [31:0] res_M[0:31][0:3][0:3]
);
    wire [31:0] snpc;
    assign snpc = pc + 4;
    always @(*) begin
        case (opcode)
            // RV32I
            7'b0110111: begin  // lui
                res_R = immU;
            end
            7'b0010111: begin  // auipc
                res_R = pc + immU;
            end
            7'b1101111: begin  // jal
                res_R = pc + 4;
            end
            7'b1100111: begin  // jalr
                res_R = pc + 4;
                npc   = pc + immJ;
            end
            7'b1100011: begin  // branch
                case (funct3)
                    3'b000: begin  // beq
                        npc = src1R == src2R ? pc + immB : snpc;
                    end
                    3'b001: begin  // bne
                        npc = src1R != src2R ? pc + immB : snpc;
                    end
                    3'b100: begin  // blt
                        npc = $signed(src1R) < $signed(src2R) ? pc + immB : snpc;
                    end
                    3'b101: begin  // bge
                        npc = $signed(src1R) >= $signed(src2R) ? pc + immB : snpc;
                    end
                    3'b110: begin  // bltu
                        npc = src1R < src2R ? pc + immB : snpc;
                    end
                    3'b111: begin  // bgeu
                        npc = src1R >= src2R ? pc + immB : snpc;
                    end
                endcase
            end
            7'b0000011: begin  // load
                res_R = src1R + immI;
            end
            7'b0100011: begin  // store
                res_R = src1R + immS;
            end
            7'b0010011: begin  // imm
                case (funct3)
                    3'b000: begin  // addi
                        res_R = src1R + immI;
                    end
                    3'b010: begin  // slti
                        res_R = $signed(src1R) < $signed(immI) ? 1 : 0;
                    end
                    3'b011: begin  // sltiu
                        res_R = src1R < immI ? 1 : 0;
                    end
                    3'b100: begin  // xori
                        res_R = src1R ^ immI;
                    end
                    3'b110: begin  // ori
                        res_R = src1R | immI;
                    end
                    3'b111: begin  // andi
                        res_R = src1R & immI;
                    end
                    3'b001: begin  // slli
                        res_R = src1R << immI[4:0];
                    end
                    3'b101: begin  // srli/srai
                        case (funct7[5])
                            1'b0: begin  // srli
                                res_R = src1R >> immI[4:0];
                            end
                            1'b1: begin  // srai
                                res_R = $signed(src1R) >>> immI[4:0];
                            end
                        endcase
                    end
                endcase
            end
            7'b0110011: begin  // reg
                case (funct3)
                    3'b000: begin  // add/sub
                        case (funct7)
                            7'b0000000: begin  // add
                                res_R = src1R + src2R;
                            end
                            7'b0100000: begin  // sub
                                res_R = src1R - src2R;
                            end
                        endcase
                    end
                    3'b001: begin  // sll
                        res_R = src1R << src2R[4:0];
                    end
                    3'b010: begin  // slt
                        res_R = $signed(src1R) < $signed(src2R) ? 1 : 0;
                    end
                    3'b011: begin  // sltu
                        res_R = src1R < src2R ? 1 : 0;
                    end
                    3'b100: begin  // xor
                        res_R = src1R ^ src2R;
                    end
                    3'b101: begin  // srl/sra
                        case (funct7[5])
                            1'b0: begin  // srl
                                res_R = src1R >> src2R[4:0];
                            end
                            1'b1: begin  // sra
                                res_R = $signed(src1R) >>> src2R[4:0];
                            end
                        endcase
                    end
                    3'b110: begin  // or
                        res_R = src1R | src2R;
                    end
                    3'b111: begin  // and
                        res_R = src1R & src2R;
                    end
                endcase
            end
            7'b0001111: begin  // fence
                // do nothing
            end
            7'b1110011: begin  // ecall/ebreak
                // do nothing
            end
            // RV32F
            7'b0000111: begin  // flw
                res_R = src1R + immI;
            end
            7'b0100111: begin  // fsw
                res_R = src1R + immS;
            end


        endcase
    end
endmodule
