`include "define.v"


module Data_Cache (
    input clk,
    input rst,
    input ready,
    input [6:0] _opcode,
    input [2:0] _funct3,
    input [31:0] _addr,
    input wdata_R_valid,
    input [31:0] wdata_R,
    input wdata_F_valid,
    input [31:0] wdata_F,
    input wdata_M_valid,
    input [31:0] wdata_M[0:3][0:3],
    output reg rdata_R_valid,
    output [31:0] rdata_R,
    output reg rdata_F_valid,
    output [31:0] rdata_F,
    output reg rdata_M_valid,
    output [31:0] rdata_M[0:3][0:3],
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
    output [3:0] mwstrb,
    output reg mwvalid,
    input mwready,
    // AXI 写响应通道
    input [1:0] mbresp,
    input mbvalid,
    output reg mbready
);
    integer i, j;

    reg [ 5:0] state;
    reg [31:0] addr;
    reg [31:0] cache  [0:3][0:3];
    reg [ 6:0] opcode;
    reg [ 2:0] funct3;
    assign rdata_R       = cache[0][0];
    assign rdata_F       = cache[0][0];
    assign rdata_M[0][0] = cache[0][0];
    assign rdata_M[0][1] = cache[0][1];
    assign rdata_M[0][2] = cache[0][2];
    assign rdata_M[0][3] = cache[0][3];
    assign rdata_M[1][0] = cache[1][0];
    assign rdata_M[1][1] = cache[1][1];
    assign rdata_M[1][2] = cache[1][2];
    assign rdata_M[1][3] = cache[1][3];
    assign rdata_M[2][0] = cache[2][0];
    assign rdata_M[2][1] = cache[2][1];
    assign rdata_M[2][2] = cache[2][2];
    assign rdata_M[2][3] = cache[2][3];
    assign rdata_M[3][0] = cache[3][0];
    assign rdata_M[3][1] = cache[3][1];
    assign rdata_M[3][2] = cache[3][2];
    assign rdata_M[3][3] = cache[3][3];
    assign mwstrb        = 1 << funct3;
    always @(posedge clk) begin
        if (rst) begin
            rdata_R_valid <= 0;
            rdata_F_valid <= 0;
            rdata_M_valid <= 0;
            state         <= `STATE_FREE;
            mrready       <= 0;
        end else if (ready) begin
            opcode <= _opcode;
            funct3 <= _funct3;
            case (state)
                `STATE_FREE: begin
                    case (opcode)
                        7'b0000011: begin  //load
                            addr     <= _addr;
                            state    <= `STATE_R_WORD;
                            mrready  <= 1;
                            marvalid <= 1;
                        end
                        7'b0100011: begin  //store
                            addr        <= _addr;
                            state       <= `STATE_W_WORD;
                            cache[0][0] <= wdata_R;
                            mawvalid    <= 1;
                            mwvalid     <= 1;
                            mbready     <= 1;
                        end
                    endcase
                end
                `STATE_R_WORD: begin
                    if (rvalid) begin
                        case (funct3)
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
                        state         <= `STATE_FINISH;
                        mrready       <= 0;
                        marvalid      <= 0;
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

                `STATE_R_DIAGONAL_0:
                if (rvalid) begin
                    cache[0][0] <= mrdata;
                    cache[0][1] <= `fzero;
                    cache[0][2] <= `fzero;
                    cache[0][3] <= `fzero;
                    state       <= `STATE_R_DIAGONAL_1;
                    addr        <= addr + 4;
                end
                `STATE_R_DIAGONAL_1:
                if (rvalid) begin
                    cache[1][0] <= `fzero;
                    cache[1][1] <= mrdata;
                    cache[1][2] <= `fzero;
                    cache[1][3] <= `fzero;
                    state       <= `STATE_R_DIAGONAL_2;
                    addr        <= addr + 4;
                end
                `STATE_R_DIAGONAL_2:
                if (rvalid) begin
                    cache[2][0] <= `fzero;
                    cache[2][1] <= `fzero;
                    cache[2][2] <= mrdata;
                    cache[2][3] <= `fzero;
                    state       <= `STATE_R_DIAGONAL_3;
                    addr        <= addr + 4;
                end
                `STATE_R_DIAGONAL_3:
                if (rvalid) begin
                    cache[3][0]   <= `fzero;
                    cache[3][1]   <= `fzero;
                    cache[3][2]   <= `fzero;
                    cache[3][3]   <= mrdata;
                    state         <= `STATE_FINISH;
                    rdata_M_valid <= 1;
                    marvalid      <= 0;
                    mrvalid       <= 0;
                end

                //TODO

                `STATE_FINISH: begin
                    // 数据保留一个周期后直接扔掉,问就是约定
                    state         <= `STATE_FREE;
                    rdata_R_valid <= 0;
                    rdata_F_valid <= 0;
                    rdata_M_valid <= 0;
                end

            endcase
        end
    end

endmodule
