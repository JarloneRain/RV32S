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
    input [31:0] snpc,
    input [31:0] src1R,
    input [31:0] src2R,
    input [31:0] src3R,
    input [31:0] src1F,
    input [31:0] src2F,
    input [31:0] src3F,
    input [511:0] src1M,
    input [511:0] src2M,
    input [511:0] src3M,
    // 计算结果
    output reg [31:0] npc,
    output reg [31:0] res_R,
    output reg [31:0] res_F,
    output reg [511:0] res_M
);
    wire [31:0] pc = snpc - 4;
    wire [ 7:0] funct7byte = {1'b0, funct7};

    import "DPI-C" function int fR(
        input byte funct7,
        input int  a,
        input int  b
    );

    always @(*) begin
        case (opcode)
            // RV32I
            7'b0110111: begin  // lui
                npc   = snpc;
                res_R = immU;
                res_F = 0;
                res_M = 0;
            end
            7'b0010111: begin  // auipc
                npc   = snpc;
                res_R = pc + immU;
                res_F = 0;
                res_M = 0;
            end
            7'b1101111: begin  // jal
                npc   = pc + immJ;
                res_R = snpc;
                res_F = 0;
                res_M = 0;
            end
            7'b1100111: begin  // jalr
                npc   = immI + src1R;
                res_R = snpc;
                res_F = 0;
                res_M = 0;
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
                    default:  /*do nothing*/;
                endcase
                res_R = 0;
                res_F = 0;
                res_M = 0;
            end
            7'b0000011: begin  // load
                npc   = snpc;
                res_R = src1R + immI;
                res_F = 0;
                res_M = 0;
            end
            7'b0100011: begin  // store
                npc   = snpc;
                res_R = src1R + immS;
                res_F = 0;
                res_M = 0;
            end
            7'b0010011: begin  // imm
                npc = snpc;
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
                        case (funct7)
                            // srli
                            7'b0000000: res_R = src1R >> immI[4:0];
                            // srai
                            7'b0100000: res_R = $signed(src1R) >>> immI[4:0];
                            default: res_R = 0;
                        endcase
                    end
                endcase
                res_F = 0;
                res_M = 0;
            end
            7'b0110011: begin  // reg
                npc = snpc;
                case (funct3)
                    3'b000: begin  // add/sub
                        case (funct7)
                            // add
                            7'b0000000: res_R = src1R + src2R;
                            // sub
                            7'b0100000: res_R = src1R - src2R;
                            default: res_R = 0;
                        endcase
                    end
                    // sll
                    3'b001:  res_R = src1R << src2R[4:0];
                    // slt
                    3'b010:  res_R = $signed(src1R) < $signed(src2R) ? 1 : 0;
                    // sltu
                    3'b011:  res_R = src1R < src2R ? 1 : 0;
                    // xor
                    3'b100:  res_R = src1R ^ src2R;
                    // srl/sra
                    3'b101: begin
                        case (funct7)
                            // srl
                            7'b0000000: res_R = src1R >> src2R[4:0];
                            // sra
                            7'b0100000: res_R = $signed(src1R) >>> src2R[4:0];
                            default: res_R = 0;
                        endcase
                    end
                    // or
                    3'b110:  res_R = src1R | src2R;
                    // and
                    3'b111:  res_R = src1R & src2R;
                    default: res_R = 0;
                endcase
                res_F = 0;
                res_M = 0;
            end
            7'b0001111: begin  // fence
                npc   = snpc;
                res_R = 0;
                res_F = 0;
                res_M = 0;
            end
            7'b1110011: begin  // ecall/ebreak
                npc   = snpc;
                res_R = 0;
                res_F = 0;
                res_M = 0;
            end
            // RV32F
            7'b0000111: begin  // flw
                npc   = snpc;
                res_R = src1R + immI;
                res_F = 0;
                res_M = 0;
            end
            7'b0100111: begin  // fsw
                npc   = snpc;
                res_R = src1R + immS;
                res_F = 0;
                res_M = 0;
            end
            7'b1010011: begin  //type R
                npc   = snpc;
                res_R = fR(funct7byte, src1R, src2R);
                res_F = fR(funct7byte, src1F, src2F);
                res_M = 0;
            end
            default: begin
                npc   = snpc;
                res_R = 0;
                res_F = 0;
                res_M = 0;
            end
        endcase
    end
endmodule
