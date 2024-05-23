
module Top (
    input clk,
    input rst
);
    // AXI 读地址通道
    wire [31:0] AXI_araddr;
    wire AXI_arvalid;
    wire AXI_arready;
    // AXI 读数据通道
    wire [31:0] AXI_rdata;
    wire AXI_rvalid;
    wire AXI_rready;
    // AXI 写地址通道
    wire [31:0] AXI_awaddr;
    wire AXI_awvalid;
    wire AXI_awready;
    // AXI 写数据通道
    wire [31:0] AXI_wdata;
    wire [3:0] AXI_wstrb;
    wire AXI_wvalid;
    wire AXI_wready;
    // AXI 写响应通道
    wire [1:0] AXI_bresp;
    wire AXI_bvalid;
    wire AXI_bready;

    
    CPU _CPU (
        .clk(clk),
        .rst(rst),
        .AXI_araddr(AXI_araddr),
        .AXI_arvalid(AXI_arvalid),
        .AXI_arready(AXI_arready),
        .AXI_rdata(AXI_rdata),
        .AXI_rvalid(AXI_rvalid),
        .AXI_rready(AXI_rready),
        .AXI_awaddr(AXI_awaddr),
        .AXI_awvalid(AXI_awvalid),
        .AXI_awready(AXI_awready),
        .AXI_wdata(AXI_wdata),
        .AXI_wstrb(AXI_wstrb),
        .AXI_wvalid(AXI_wvalid),
        .AXI_wready(AXI_wready),
        .AXI_bresp(AXI_bresp),
        .AXI_bvalid(AXI_bvalid),
        .AXI_bready(AXI_bready)
    );

    RAM _RAM (
        .clk(clk),
        .rst(rst),
        .araddr(AXI_araddr),
        .arvalid(AXI_arvalid),
        .arready(AXI_arready),
        .rdata(AXI_rdata),
        .rvalid(AXI_rvalid),
        .rready(AXI_rready),
        .awaddr(AXI_awaddr),
        .awvalid(AXI_awvalid),
        .awready(AXI_awready),
        .wdata(AXI_wdata),
        .wstrb(AXI_wstrb),
        .wvalid(AXI_wvalid),
        .wready(AXI_wready),
        .bresp(AXI_bresp),
        .bvalid(AXI_bvalid),
        .bready(AXI_bready)
    );

    always @(posedge clk) begin
        // if (AXI_rdata == 32'h00100073) begin
        //     $display("Ebreak detected!\nFinish soon.");
        //     $finish;
        // end
    end
endmodule
