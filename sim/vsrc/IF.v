`include "define.v"

module IF_CTRL (
    input clk,
    input rst,
    // 通信协议
    output reg valid,
    output ready,
    input AR_valid,
    input ID_ready,
    // 解决分支问题
    input pc_opt
);
    assign ready = (ID_ready | !valid) & !pc_opt;
    always @(posedge clk)
        if (rst) valid <= 0;
        else if (ready) valid <= AR_valid;
        else if (ID_ready) valid <= 0;
endmodule

module IFU (
    input clk,
    input ready,
    //
    input [31:0] AR_inst,
    output reg [31:0] inst
);
    always @(posedge clk) begin
        if (ready) begin
            inst <= AR_inst;
            if (inst == 32'h00100073) begin
                $display("Ebreak");
                $finish;
            end
            if (inst == 32'h00000073) begin
                $display("Ecall");
                $finish;
            end
        end
    end
endmodule

module PC1 (
    input clk,
    input ready,
    //
    input [31:0] PC_snpc,
    output reg [31:0] snpc
);
    always @(posedge clk) begin
        if (ready) begin
            snpc <= PC_snpc;
        end
    end
endmodule
