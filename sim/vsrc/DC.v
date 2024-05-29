`include "define.v"


module Data_Cache (
    input clk,
    input rst,
    input ready,
    output reg [5:0] state,
    input [6:0] opcode,
    input [2:0] funct3,
    input [31:0] addr,
    input [31:0] wdata_R,
    input [31:0] wdata_F,
    input [511:0] wdata_M,
    output reg rdata_R_valid,
    output [31:0] rdata_R,
    output reg rdata_F_valid,
    output [31:0] rdata_F,
    output reg rdata_M_valid,
    output [511:0] rdata_M,
    //AXI
    // AXI 读地址通道
    output [31:0] maraddr,
    output reg marvalid,
    input marready,
    // AXI 读数据通道
    input [31:0] mrdata,
    input mrvalid,
    output reg mrready,
    // AXI 写地址通道
    output [31:0] mawaddr,
    output reg mawvalid,
    input mawready,
    // AXI 写数据通道
    output [31:0] mwdata,
    output reg [3:0] mwstrb,
    output reg mwvalid,
    input mwready,
    // AXI 写响应通道
    input [1:0] mbresp,
    input mbvalid,
    output reg mbready
);
    integer i, j;

    // reg [31:0] addr;
    reg [31:0] cache[0:3][0:3];
    //reg [ 6:0] opcode;
    reg [2:0] _funct3;
    assign rdata_R          = cache[0][0];
    assign rdata_F          = cache[0][0];
    assign rdata_M[31:0]    = cache[0][0];
    assign rdata_M[63:32]   = cache[0][1];
    assign rdata_M[95:64]   = cache[0][2];
    assign rdata_M[127:96]  = cache[0][3];
    assign rdata_M[159:128] = cache[1][0];
    assign rdata_M[191:160] = cache[1][1];
    assign rdata_M[223:192] = cache[1][2];
    assign rdata_M[255:224] = cache[1][3];
    assign rdata_M[287:256] = cache[2][0];
    assign rdata_M[319:288] = cache[2][1];
    assign rdata_M[351:320] = cache[2][2];
    assign rdata_M[383:352] = cache[2][3];
    assign rdata_M[415:384] = cache[3][0];
    assign rdata_M[447:416] = cache[3][1];
    assign rdata_M[479:448] = cache[3][2];
    assign rdata_M[511:480] = cache[3][3];

    //assign mwstrb           = 1 << funct3;
    always @(posedge clk) begin
        if (rst) begin
            rdata_R_valid <= 0;
            rdata_F_valid <= 0;
            rdata_M_valid <= 0;
            state         <= `STATE_FREE;
            mrready       <= 0;
        end else  /* if (ready)*/ begin
            case (state)
                `STATE_FREE:
                if (ready) begin
                    _funct3 <= funct3;
                    case (opcode)
                        7'b0000011: begin  //load
                            maraddr  <= addr;
                            state    <= `STATE_R_WORD;
                            mrready  <= 1;
                            marvalid <= 1;
                        end
                        7'b0100011: begin  //store
                            state       <= `STATE_W_WORD;
                            cache[0][0] <= wdata_R;
                            mawaddr     <= addr;
                            mawvalid    <= 1;
                            mwdata      <= wdata_R;
                            mwvalid     <= 1;
                            mbready     <= 1;
                            mwstrb      <= (1 << (1 << funct3)) - 1;
                        end
                        7'b0000111: begin  //flw
                            maraddr  <= addr;
                            state    <= `STATE_R_WORD;
                            mrready  <= 1;
                            marvalid <= 1;
                        end
                        7'b0100111: begin  //fsw
                            state       <= `STATE_W_WORD;
                            cache[0][0] <= wdata_R;
                            mawaddr     <= addr;
                            mawvalid    <= 1;
                            mwdata      <= wdata_F;
                            mwvalid     <= 1;
                            mbready     <= 1;
                            mwstrb      <= (1 << (1 << funct3)) - 1;
                        end
                        7'b1111011: begin  // sml(d)
                            case (funct3)
                                3'b000: state <= `STATE_R_MATRIX_00;
                                3'b001: state <= `STATE_R_DIAGONAL_0;
                                default:  /*do nothing*/;
                            endcase
                            maraddr  <= addr;
                            marvalid <= 1;
                            mrready  <= 1;
                        end
                        7'b1111111: begin  //sms
                            case (funct3)
                                3'b000: state <= `STATE_W_MATRIX_00;
                                3'b001: state <= `STATE_W_DIAGONAL_0;
                                default:  /*do nothing*/;
                            endcase
                            cache[0][0] <= wdata_M[31:0];
                            cache[0][1] <= wdata_M[63:32];
                            cache[0][2] <= wdata_M[95:64];
                            cache[0][3] <= wdata_M[127:96];
                            cache[1][0] <= wdata_M[159:128];
                            cache[1][1] <= wdata_M[191:160];
                            cache[1][2] <= wdata_M[223:192];
                            cache[1][3] <= wdata_M[255:224];
                            cache[2][0] <= wdata_M[287:256];
                            cache[2][1] <= wdata_M[319:288];
                            cache[2][2] <= wdata_M[351:320];
                            cache[2][3] <= wdata_M[383:352];
                            cache[3][0] <= wdata_M[415:384];
                            cache[3][1] <= wdata_M[447:416];
                            cache[3][2] <= wdata_M[479:448];
                            cache[3][3] <= wdata_M[511:480];
                            mawaddr     <= addr;
                            mawvalid    <= 1;
                            mwdata      <= wdata_M[31:0];
                            mwvalid     <= 1;
                            mbready     <= 1;
                            mwstrb      <= 4'b1111;
                        end
                        default:  /*do nothing*/;
                    endcase
                end
                `STATE_R_WORD: begin
                    if (marready) begin
                        marvalid <= 0;
                    end
                    if (mrvalid) begin
                        case (_funct3)
                            //lb
                            3'b000:  cache[0][0] <= {{24{mrdata[7]}}, mrdata[7:0]};
                            //lh
                            3'b001:  cache[0][0] <= {{16{mrdata[15]}}, mrdata[15:0]};
                            //lbu
                            3'b100:  cache[0][0] <= {{24{1'b0}}, mrdata[7:0]};
                            //lhu
                            3'b101:  cache[0][0] <= {{16{1'b0}}, mrdata[15:0]};
                            // lw, or default
                            default: cache[0][0] <= mrdata;
                        endcase
                        rdata_R_valid <= 1;
                        rdata_F_valid <= 1;
                        state         <= `STATE_FINISH;
                        mrready       <= 0;
                    end
                end
                `STATE_W_WORD: begin
                    if (mawready & mwready) begin
                        mawvalid <= 0;
                        mwvalid  <= 0;
                    end
                    if (mbvalid) begin
                        mbready <= 0;
                        state   <= `STATE_FINISH;
                    end
                end

                `STATE_R_DIAGONAL_0: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[0][0] <= mrdata;
                        cache[0][1] <= `fzero;
                        cache[0][2] <= `fzero;
                        cache[0][3] <= `fzero;
                        state       <= `STATE_R_DIAGONAL_1;
                    end
                end
                `STATE_R_DIAGONAL_1: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[1][0] <= `fzero;
                        cache[1][1] <= mrdata;
                        cache[1][2] <= `fzero;
                        cache[1][3] <= `fzero;
                        state       <= `STATE_R_DIAGONAL_2;
                    end
                end
                `STATE_R_DIAGONAL_2: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[2][0] <= `fzero;
                        cache[2][1] <= `fzero;
                        cache[2][2] <= mrdata;
                        cache[2][3] <= `fzero;
                        state       <= `STATE_R_DIAGONAL_3;
                    end
                end
                `STATE_R_DIAGONAL_3: begin
                    if (marready) begin
                        marvalid <= 0;
                    end
                    if (mrvalid) begin
                        cache[3][0]   <= `fzero;
                        cache[3][1]   <= `fzero;
                        cache[3][2]   <= `fzero;
                        cache[3][3]   <= mrdata;
                        state         <= `STATE_FINISH;
                        rdata_M_valid <= 1;
                    end
                end
                `STATE_W_DIAGONAL_0: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[1][1];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_DIAGONAL_1;
                    end
                end
                `STATE_W_DIAGONAL_1: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[2][2];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_DIAGONAL_2;
                    end
                end
                `STATE_W_DIAGONAL_2: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[3][3];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_DIAGONAL_3;
                    end
                end
                `STATE_W_DIAGONAL_3: begin
                    if (mawready & mwready) begin
                        mawvalid <= 0;
                        mwvalid  <= 0;
                    end
                    if (mbvalid) begin
                        mbready <= 0;
                        state   <= `STATE_FINISH;
                    end
                end

                `STATE_R_MATRIX_00: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[0][0] <= mrdata;
                        state       <= `STATE_R_MATRIX_01;
                    end
                end
                `STATE_R_MATRIX_01: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[0][1] <= mrdata;
                        state       <= `STATE_R_MATRIX_02;
                    end
                end
                `STATE_R_MATRIX_02: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[0][2] <= mrdata;
                        state       <= `STATE_R_MATRIX_03;
                    end
                end
                `STATE_R_MATRIX_03: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[0][3] <= mrdata;
                        state       <= `STATE_R_MATRIX_10;
                    end
                end
                `STATE_R_MATRIX_10: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[1][0] <= mrdata;
                        state       <= `STATE_R_MATRIX_11;
                    end
                end
                `STATE_R_MATRIX_11: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[1][1] <= mrdata;
                        state       <= `STATE_R_MATRIX_12;
                    end
                end
                `STATE_R_MATRIX_12: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[1][2] <= mrdata;
                        state       <= `STATE_R_MATRIX_13;
                    end
                end
                `STATE_R_MATRIX_13: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[1][3] <= mrdata;
                        state       <= `STATE_R_MATRIX_20;
                    end
                end
                `STATE_R_MATRIX_20: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[2][0] <= mrdata;
                        state       <= `STATE_R_MATRIX_21;
                    end
                end
                `STATE_R_MATRIX_21: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[2][1] <= mrdata;
                        state       <= `STATE_R_MATRIX_22;
                    end
                end
                `STATE_R_MATRIX_22: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[2][2] <= mrdata;
                        state       <= `STATE_R_MATRIX_23;
                    end
                end
                `STATE_R_MATRIX_23: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[2][3] <= mrdata;
                        state       <= `STATE_R_MATRIX_30;
                    end
                end
                `STATE_R_MATRIX_30: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[3][0] <= mrdata;
                        state       <= `STATE_R_MATRIX_31;
                    end
                end
                `STATE_R_MATRIX_31: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[3][1] <= mrdata;
                        state       <= `STATE_R_MATRIX_32;
                    end
                end
                `STATE_R_MATRIX_32: begin
                    if (marready) begin
                        maraddr <= maraddr + 4;
                    end
                    if (mrvalid) begin
                        cache[3][2] <= mrdata;
                        state       <= `STATE_R_MATRIX_33;
                    end
                end
                `STATE_R_MATRIX_33: begin
                    if (marready) begin
                        marvalid <= 0;
                    end
                    if (mrvalid) begin
                        cache[3][3]   <= mrdata;
                        state         <= `STATE_FINISH;
                        rdata_M_valid <= 1;
                    end
                end

                `STATE_W_MATRIX_00: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[0][1];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_01;
                    end
                end
                `STATE_W_MATRIX_01: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[0][2];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_02;
                    end
                end
                `STATE_W_MATRIX_02: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[0][3];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_03;
                    end
                end
                `STATE_W_MATRIX_03: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[1][0];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_10;
                    end
                end
                `STATE_W_MATRIX_10: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[1][1];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_11;
                    end
                end
                `STATE_W_MATRIX_11: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[1][2];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_12;
                    end
                end
                `STATE_W_MATRIX_12: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[1][3];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_13;
                    end
                end
                `STATE_W_MATRIX_13: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[2][0];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_20;
                    end
                end
                `STATE_W_MATRIX_20: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[2][1];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_21;
                    end
                end
                `STATE_W_MATRIX_21: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[2][2];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_22;
                    end
                end
                `STATE_W_MATRIX_22: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[2][3];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_23;
                    end
                end
                `STATE_W_MATRIX_23: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[3][0];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_30;
                    end
                end
                `STATE_W_MATRIX_30: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[3][1];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_31;
                    end
                end
                `STATE_W_MATRIX_31: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[3][2];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_32;
                    end
                end
                `STATE_W_MATRIX_32: begin
                    if (mawready & mwready) begin
                        mawaddr <= mawaddr + 4;
                        mwdata  <= cache[3][3];
                    end
                    if (mbvalid) begin
                        state <= `STATE_W_MATRIX_33;
                    end
                end
                `STATE_W_MATRIX_33: begin
                    if (mawready & mwready) begin
                        mawvalid <= 0;
                        mwvalid  <= 0;
                    end
                    if (mbvalid) begin
                        mbready <= 0;
                        state   <= `STATE_FINISH;
                    end
                end

                `STATE_FINISH: begin
                    // 数据保留一个周期后直接扔掉,问就是约定
                    state         <= `STATE_FREE;
                    rdata_R_valid <= 0;
                    rdata_F_valid <= 0;
                    rdata_M_valid <= 0;
                end
                default:  /*do nothing*/;
            endcase
        end
    end

endmodule
