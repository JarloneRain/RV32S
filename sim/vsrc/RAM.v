`include "define.v"

module RAM (
    input clk,
    input rst,
    // AXI
    // AXI 读地址通道
    input [31:0] araddr,
    input arvalid,
    output arready,
    // AXI 读数据通道
    output reg [31:0] rdata,
    output reg rvalid,
    input rready,
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
    output reg [1:0] bresp,
    output reg bvalid,
    input bready
);
    // 1MB
    reg [7:0] memory[MEM_BASE:MEM_SIZE-1];
    // 读取部分
    //    读地址
    reg _arvalid;
    reg [31:0] _araddr;
    assign arready = !_arvalid;
    //    读数据
    //端口都声明完了，这里就不用再写了

    // 写入部分
    //    写地址
    reg _awvalid;
    reg [31:0] _awaddr;
    assign awready = !_awvalid & !bvalid;
    //    写数据
    reg _wvalid;
    reg [31:0] _wdata;
    reg [3:0] _wstrb;
    assign wready = !_wvalid & !bvalid;
    //    写响应
    //端口都声明完了，这里就不用再写了

    always @(posedge clk) begin
        if (rst) begin
            _arvalid <= 0;
            _awvalid <= 0;
            _wvalid  <= 0;
            bvalid   <= 0;
        end else begin
            // 读取的逻辑
            if (arready) begin  // 可以写入新的读取地址
                _arvalid <= arvalid;
                _araddr  <= araddr;
                rvalid   <= 0;
            end else if (_arvalid) begin  // 读取地址可用，读取数据
                rdata <= {memory[_araddr+3], memory[_araddr+2], memory[_araddr+1], memory[_araddr]};
                rvalid <= 1;
            end else if (rready & rvalid) begin  // 数据已被读走
                rvalid   <= 0;
                _arvalid <= 0;
            end
            // 写入
            if (awready & wready) begin
                _awvalid <= awvalid;
                _awaddr  <= awaddr;
                _wvalid  <= wvalid;
                _wdata   <= wdata;
                _wstrb   <= wstrb;
            end else if (_awvalid & _wvalid) begin
                if (MEM_BASE <= _awaddr & _awaddr < MEM_BASE + MEM_SIZE) begin
                    memory[_awaddr+0] <= _wstrb[0] ? _wdata[7:0] : memory[_awaddr];
                    memory[_awaddr+1] <= _wstrb[1] ? _wdata[15:8] : memory[_awaddr+1];
                    memory[_awaddr+2] <= _wstrb[2] ? _wdata[23:16] : memory[_awaddr+2];
                    memory[_awaddr+3] <= _wstrb[3] ? _wdata[31:24] : memory[_awaddr+3];
                    bresp             <= AXI_RESP_OK;
                end else begin
                    bresp <= AXI_RESP_DECERR;
                end
                bvalid   <= 1;
                _awvalid <= 0;
                _wvalid  <= 0;
            end else if (bready & bvalid) begin
                bvalid <= 0;
            end
        end
    end
endmodule
