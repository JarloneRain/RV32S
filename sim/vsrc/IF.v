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
    input ID_pc_opt,
    input I1_valid,
    input I1_pc_opt,
    input I2_valid,
    input I2_pc_opt,
    input I3_valid,
    input I3_pc_opt
);
    assign ready = (ID_ready| !valid) & !ID_pc_opt
                    & !(I1_valid & I1_pc_opt)
                    & !(I2_valid & I2_pc_opt)
                    & !(I3_valid & I3_pc_opt);
    always @(posedge clk) begin
        valid <= !rst | ready & AR_valid;
    end
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
        end
    end
endmodule

module PC1 (
    input clk,
    input ready,
    //
    input [31:0] PC_pc,
    output reg [31:0] pc
);
    always @(posedge clk) begin
        if (ready) begin
            pc <= PC_pc;
        end
    end
endmodule
