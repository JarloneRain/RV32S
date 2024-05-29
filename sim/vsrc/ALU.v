// 纯组合逻辑，尽管会用reg
module ALU (
    // 指令中的操作码
    input [6:0] opcode,
    input [6:0] funct7,
    input [2:0] funct3,
    input [2:0] funct3Y,
    input [1:0] funct2R4,
    input [4:0] rs2,
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

    wire [31:0] m1[0:3][0:3];
    wire [31:0] m2[0:3][0:3];
    wire [31:0] m3[0:3][0:3];
    //reg [31:0] mres[0:3][0:3];

    assign m1[0][0] = src1M[31:0];
    assign m1[0][1] = src1M[63:32];
    assign m1[0][2] = src1M[95:64];
    assign m1[0][3] = src1M[127:96];
    assign m1[1][0] = src1M[159:128];
    assign m1[1][1] = src1M[191:160];
    assign m1[1][2] = src1M[223:192];
    assign m1[1][3] = src1M[255:224];
    assign m1[2][0] = src1M[287:256];
    assign m1[2][1] = src1M[319:288];
    assign m1[2][2] = src1M[351:320];
    assign m1[2][3] = src1M[383:352];
    assign m1[3][0] = src1M[415:384];
    assign m1[3][1] = src1M[447:416];
    assign m1[3][2] = src1M[479:448];
    assign m1[3][3] = src1M[511:480];

    assign m2[0][0] = src2M[31:0];
    assign m2[0][1] = src2M[63:32];
    assign m2[0][2] = src2M[95:64];
    assign m2[0][3] = src2M[127:96];
    assign m2[1][0] = src2M[159:128];
    assign m2[1][1] = src2M[191:160];
    assign m2[1][2] = src2M[223:192];
    assign m2[1][3] = src2M[255:224];
    assign m2[2][0] = src2M[287:256];
    assign m2[2][1] = src2M[319:288];
    assign m2[2][2] = src2M[351:320];
    assign m2[2][3] = src2M[383:352];
    assign m2[3][0] = src2M[415:384];
    assign m2[3][1] = src2M[447:416];
    assign m2[3][2] = src2M[479:448];
    assign m2[3][3] = src2M[511:480];

    assign m3[0][0] = src3M[31:0];
    assign m3[0][1] = src3M[63:32];
    assign m3[0][2] = src3M[95:64];
    assign m3[0][3] = src3M[127:96];
    assign m3[1][0] = src3M[159:128];
    assign m3[1][1] = src3M[191:160];
    assign m3[1][2] = src3M[223:192];
    assign m3[1][3] = src3M[255:224];
    assign m3[2][0] = src3M[287:256];
    assign m3[2][1] = src3M[319:288];
    assign m3[2][2] = src3M[351:320];
    assign m3[2][3] = src3M[383:352];
    assign m3[3][0] = src3M[415:384];
    assign m3[3][1] = src3M[447:416];
    assign m3[3][2] = src3M[479:448];
    assign m3[3][3] = src3M[511:480];



    `include "alu_dpic.v"

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
            7'b1000011: begin  // fmadd
                npc   = snpc;
                res_R = 0;
                res_F = fmadd_s(src1F, src2F, src3F);
                res_M = 0;
            end
            7'b1000111: begin  // fmsub
                npc   = snpc;
                res_R = 0;
                res_F = fmsub_s(src1F, src2F, src3F);
                res_M = 0;
            end
            7'b1001011: begin  // fnmsub
                npc   = snpc;
                res_R = 0;
                res_F = fnmsub_s(src1F, src2F, src3F);
                res_M = 0;
            end
            7'b1001111: begin  // fnmadd
                npc   = snpc;
                res_R = 0;
                res_F = fnmadd_s(src1F, src2F, src3F);
                res_M = 0;
            end
            7'b1010011: begin  //type R
                npc = snpc;
                case (funct7)
                    7'b0000000: begin  // fadd
                        res_R = 0;
                        res_F = fadd_s(src1F, src2F);
                    end
                    7'b0000100: begin  // fsub
                        res_R = 0;
                        res_F = fsub_s(src1F, src2F);
                    end
                    7'b0001000: begin  // fmul
                        res_R = 0;
                        res_F = fmul_s(src1F, src2F);
                    end
                    7'b0001100: begin  // fdiv
                        res_R = 0;
                        res_F = fdiv_s(src1F, src2F);
                    end
                    7'b0101100: begin  // fsqrt
                        res_R = 0;
                        res_F = fsqrt_s(src1F);
                    end
                    7'b0010000: begin  // fsgnj
                        res_R = 0;
                        res_F = fsgnj_s(src1F, src2F);
                    end
                    7'b0010001: begin  // fsgnjn
                        res_R = 0;
                        res_F = fsgnjn_s(src1F, src2F);
                    end
                    7'b0010010: begin  // fsgnjx
                        res_R = 0;
                        res_F = fsgnjx_s(src1F, src2F);
                    end
                    7'b0010100: begin  // fmin
                        res_R = 0;
                        res_F = fmin_s(src1F, src2F);
                    end
                    7'b0010101: begin  // fmax
                        res_R = 0;
                        res_F = fmax_s(src1F, src2F);
                    end
                    7'b1100000: begin  // fcvt.w(u).s
                        case (rs2)
                            // fcvt.w.s
                            5'b00000: res_R = fcvt_w_s(src1F);
                            // fcvt.wu.s
                            5'b00001: res_R = fcvt_wu_s(src1F);
                            default:  res_R = 0;
                        endcase
                        res_F = 0;
                    end
                    7'b1110000: begin  // fmv.x.w
                        res_R = src1F;
                        res_F = 0;
                    end
                    7'b1010000: begin  // feq.s,flt.s,fle.s
                        case (funct3)
                            //feq.s
                            3'b010:  res_R = feq_s(src1F, src2F);
                            //flt.s
                            3'b001:  res_R = flt_s(src1F, src2F);
                            //fle.s
                            3'b000:  res_R = fle_s(src1F, src2F);
                            default: res_R = 0;
                        endcase
                        res_F = 0;
                    end
                    7'b1110001: begin  // fclass.s
                        res_R = fclass_s(src1F);
                        res_F = 0;
                    end
                    7'b1101000: begin  // fcvt.s.w(u)
                        res_R = 0;
                        case (rs2)
                            //fcvt.s.w
                            5'b00000: res_F = fcvt_s_w(src1R);
                            //fcvt.s.wu
                            5'b00001: res_F = fcvt_s_wu(src1R);
                            default:  /* do nothing */;
                        endcase
                    end
                    7'b1111000: begin  // fmv.w.x
                        res_R = 0;
                        res_F = src1R;
                    end
                    default: begin
                        res_F = 0;
                        res_R = 0;
                    end
                endcase
                res_M = 0;
            end
            //RV32S 偷个懒，只实现用到了的指令
            // 7'b1010111:begin // move and trans
            // npc = snpc;
            // res_R=0;
            //     case (funct3)
            //         3'b000:begin
            //             res_F=m1[matI][matJ];
            //             res_M=0;
            //         end 

            //         default: begin
            //             res_F=0;
            //             res_M=0;
            //         end
            //     endcase
            // end
            7'b1111011: begin  // sml(d)
                npc   = snpc;
                res_R = src1R + immI;
                res_F = 0;
                res_M = 0;
            end
            7'b1111111: begin  // sms(d)
                npc   = snpc;
                res_R = src1R + immS;
                res_F = 0;
                res_M = 0;
            end
            7'b1011011: begin  // transpose gen cal
                npc   = snpc;
                res_R = 0;
                case (funct7)
                    7'b0001000: begin  // smmp
                        res_F = 0;
                        smmmp(  //
                            src1M[31:0], src1M[63:32], src1M[95:64], src1M[127:96],  //
                            src1M[159:128], src1M[191:160], src1M[223:192], src1M[255:224],  //
                            src1M[287:256], src1M[319:288], src1M[351:320], src1M[383:352],  //
                            src1M[415:384], src1M[447:416], src1M[479:448], src1M[511:480],  //
                            src2M[31:0], src2M[63:32], src2M[95:64], src2M[127:96],  //
                            src2M[159:128], src2M[191:160], src2M[223:192], src2M[255:224],  //
                            src2M[287:256], src2M[319:288], src2M[351:320], src2M[383:352],  //
                            src2M[415:384], src2M[447:416], src2M[479:448], src2M[511:480],  //
                            res_M[31:0], res_M[63:32], res_M[95:64], res_M[127:96],  //
                            res_M[159:128], res_M[191:160], res_M[223:192], res_M[255:224],  //
                            res_M[287:256], res_M[319:288], res_M[351:320], res_M[383:352],  //
                            res_M[415:384], res_M[447:416], res_M[479:448], res_M[511:480]);
                    end
                    default: begin
                        res_F = 0;
                        res_M = 0;
                    end
                endcase
            end
            7'b1011111: begin
                npc   = snpc;
                res_R = 0;
                res_F = 0;
                smma(src1M[31:0], src1M[63:32], src1M[95:64], src1M[127:96],  //
                     src1M[159:128], src1M[191:160], src1M[223:192], src1M[255:224],  //
                     src1M[287:256], src1M[319:288], src1M[351:320], src1M[383:352],  //
                     src1M[415:384], src1M[447:416], src1M[479:448], src1M[511:480],  //
                     src2M[31:0], src2M[63:32], src2M[95:64], src2M[127:96],  //
                     src2M[159:128], src2M[191:160], src2M[223:192], src2M[255:224],  //
                     src2M[287:256], src2M[319:288], src2M[351:320], src2M[383:352],  //
                     src2M[415:384], src2M[447:416], src2M[479:448], src2M[511:480],  //
                     src3M[31:0], src3M[63:32], src3M[95:64], src3M[127:96],  //
                     src3M[159:128], src3M[191:160], src3M[223:192], src3M[255:224],  //
                     src3M[287:256], src3M[319:288], src3M[351:320], src3M[383:352],  //
                     src3M[415:384], src3M[447:416], src3M[479:448], src3M[511:480],  //
                     res_M[31:0], res_M[63:32], res_M[95:64], res_M[127:96],  //
                     res_M[159:128], res_M[191:160], res_M[223:192], res_M[255:224],  //
                     res_M[287:256], res_M[319:288], res_M[351:320], res_M[383:352],  //
                     res_M[415:384], res_M[447:416], res_M[479:448], res_M[511:480]);

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
