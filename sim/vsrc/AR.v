`include "define.v"

module AR (
    // AXI 读地址通道兼指令地址
    input [31:0] pcraddr,
    input pcrvalid,
    output pcrready,
    input [31:0] araddr,
    input arvalid,
    output arready,
    // AXI 读数据通道兼指令内容
    output [31:0] rdata,
    output rvalid,
    output [31:0] inst,
    output irvalid,
    input rready,
    input irready,
    // AXI 写地址通道
    input [31:0] awaddr,
    input awvalid,
    output awready,
    // AXI 写数据通道
    input [31:0] wdata,
    input [3:0] wstrb,
    input wvalid,
    output wready,
    // AXI 写响应通道
    output [1:0] bresp,
    output bvalid,
    input bready,
    //上面是面向CPU的接口，下面是面向内存的接口
    // AXI 读地址通道
    output [31:0] m_araddr,
    output m_arvalid,
    input m_arready,
    // AXI 读数据通道
    input [31:0] m_rdata,
    input m_rvalid,
    output m_rready,
    // AXI 写地址通道
    output [31:0] m_awaddr,
    output m_awvalid,
    input m_awready,
    // AXI 写数据通道
    output [31:0] m_wdata,
    output [3:0] m_wstrb,
    output m_wvalid,
    input m_wready,
    // AXI 写响应通道
    input [1:0] m_bresp,
    input m_bvalid,
    output m_bready
);
    wire data_req = arvalid | rready | awvalid | wvalid | bready;
    assign pcrready  = m_arready & !data_req;
    assign arready   = m_arready;
    assign rdata     = m_rdata;
    assign rvalid    = m_rvalid & data_req;
    assign inst      = m_rdata;
    assign irvalid   = m_rvalid & !data_req;
    assign awready   = m_awready;
    assign wready    = m_wready;
    assign bresp     = m_bresp;
    assign bvalid    = m_bvalid;
    assign m_araddr  = data_req ? araddr : pcraddr;
    assign m_arvalid = data_req ? arvalid : pcrvalid;
    assign m_rready  = data_req ? rready : irready;
    assign m_awaddr  = awaddr;
    assign m_awvalid = awvalid;
    assign m_wdata   = wdata;
    assign m_wstrb   = wstrb;
    assign m_wvalid  = wvalid;
    assign m_bready  = bready;
endmodule
