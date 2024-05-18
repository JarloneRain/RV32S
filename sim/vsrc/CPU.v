

module CPU (
    input clk,
    input rst,
    // AXI 读地址通道
    output [31:0] AXI_araddr,
    output AXI_arvalid,
    input AXI_arready,
    // AXI 读数据通道
    input [31:0] AXI_rdata,
    input AXI_rvalid,
    output AXI_rready,
    // AXI 写地址通道
    output [31:0] AXI_awaddr,
    output AXI_awvalid,
    input AXI_awready,
    // AXI 写数据通道
    output [31:0] AXI_wdata,
    output [3:0] AXI_wstrb,
    output AXI_wvalid,
    input AXI_wready,
    // AXI 写响应通道
    input [1:0] AXI_bresp,
    input AXI_bvalid,
    output AXI_bready
);

    // IF
    //  IF_CTRL
    wire IF_CTRL_valid;
    wire IF_CTRL_ready;
    //  IFU
    wire [31:0] IFU_inst;
    //  PC1
    wire [31:0] PC1_pc;
    // ID
    //  ID_CTRL
    wire ID_CTRL_valid;
    wire ID_CTRL_ready;
    //  IDU
    wire [31:0] IDU_opcode;
    wire [31:0] IDU_funct7;
    wire [31:0] IDU_funct3;
    wire [31:0] IDU_funct3Y;
    wire [31:0] IDU_funct2R4;
    wire [31:0] IDU_rd_group;
    wire [31:0] IDU_rd_index;
    wire [31:0] IDU_rs1_group;
    wire [31:0] IDU_rs1_index;
    wire [31:0] IDU_rs2_group;
    wire [31:0] IDU_rs2_index;
    wire [31:0] IDU_rs3_group;
    wire [31:0] IDU_rs3_index;
    wire [31:0] IDU_immU;
    wire [31:0] IDU_immJ;
    wire [31:0] IDU_immB;
    wire [31:0] IDU_immS;
    wire [31:0] IDU_immI;
    wire [1:0] IDU_matI;
    wire [1:0] IDU_matJ;
    wire IDU_pc_opt;
    //  Inst1
    wire [31:0] Inst1_opcode;
    wire [31:0] Inst1_funct7;
    wire [31:0] Inst1_funct3;
    wire [31:0] Inst1_funct3Y;
    wire [31:0] Inst1_funct2R4;
    wire [31:0] Inst1_rd_group;
    wire [31:0] Inst1_rd_index;
    wire [31:0] Inst1_rs1_group;
    wire [31:0] Inst1_rs1_index;
    wire [31:0] Inst1_rs2_group;
    wire [31:0] Inst1_rs2_index;
    wire [31:0] Inst1_rs3_group;
    wire [31:0] Inst1_rs3_index;
    wire Inst1_pc_opt;
    //  Srcs
    wire [31:0] Srcs_immU;
    wire [31:0] Srcs_immJ;
    wire [31:0] Srcs_immB;
    wire [31:0] Srcs_immS;
    wire [31:0] Srcs_immI;
    wire [1:0] Srcs_matI;
    wire [1:0] Srcs_matJ;
    //  PC2
    wire [31:0] PC2_pc;
    // EX
    //  EX_CTRL
    wire EX_CTRL_valid;
    wire EX_CTRL_ready;
    //  ALU
    wire [31:0] ALU_npc;
    wire [31:0] ALU_res_R;
    wire [31:0] ALU_res_F;
    wire [511:0] ALU_res_M;
    //  Inst2
    wire [6:0] Inst2_opcode;
    wire [6:0] Inst2_funct7;
    wire [2:0] Inst2_funct3;
    wire [2:0] Inst2_funct3Y;
    wire [1:0] Inst2_funct2R4;
    wire [1:0] Inst2_rd_group;
    wire [4:0] Inst2_rd_index;
    wire Inst2_pc_opt;
    //  ALU_OUT1
    wire [31:0] ALU_OUT1_npc;
    wire [31:0] ALU_OUT1_res_R;
    wire [31:0] ALU_OUT1_res_F;
    wire [511:0] ALU_OUT1_res_M;
    wire [31:0] ALU_OUT1_rs2_R;
    wire [31:0] ALU_OUT1_rs2_F;
    wire [511:0] ALU_OUT1_rs2_M;
    // ME
    //  ME_CTRL
    wire ME_CTRL_valid;
    wire ME_CTRL_ready;
    //  Inst3
    wire [6:0] Inst3_opcode;
    wire [6:0] Inst3_funct7;
    wire [2:0] Inst3_funct3;
    wire [2:0] Inst3_funct3Y;
    wire [1:0] Inst3_funct2R4;
    wire [1:0] Inst3_rd_group;
    wire [4:0] Inst3_rd_index;
    wire Inst3_pc_opt;
    //  ALU_OUT2
    wire [31:0] ALU_OUT2_npc;
    wire [31:0] ALU_OUT2_res_R;
    wire [31:0] ALU_OUT2_res_F;
    wire [511:0] ALU_OUT2_res_M;
    //  DC
    wire [5:0] DC_state;
    wire DC_rdata_R_valid;
    wire [31:0] DC_rdata_R;
    wire DC_rdata_F_valid;
    wire [31:0] DC_rdata_F;
    wire DC_rdata_M_valid;
    wire [511:0] DC_rdata_M;
    wire [31:0] DC_maraddr;
    wire DC_marvalid;
    wire DC_mrready;
    wire [31:0] DC_mawaddr;
    wire DC_mawvalid;
    wire [31:0] DC_mwdata;
    wire [3:0] DC_mwstrb;
    wire DC_mwvalid;
    wire DC_mbready;
    // WB
    //  WB_CTRL
    wire WB_CTRL_valid;
    wire WB_CTRL_ready;
    //  GprMux
    wire GprMux_we;
    wire [31:0] GprMux_R;
    wire [31:0] GprMux_F;
    wire [511:0] GprMux_M;
    //  Gpr
    wire [31:0] Gpr_dout_R_rs1;
    wire [31:0] Gpr_dout_F_rs1;
    wire [511:0] Gpr_dout_M_rs1;
    wire [31:0] Gpr_dout_R_rs2;
    wire [31:0] Gpr_dout_F_rs2;
    wire [511:0] Gpr_dout_M_rs2;
    wire [31:0] Gpr_dout_R_rs3;
    wire [31:0] Gpr_dout_F_rs3;
    wire [511:0] Gpr_dout_M_rs3;
    //  PC
    wire PC_valid;
    wire [31:0] PC_pc;
    // Others
    // AR
    wire AR_pcrready;
    wire AR_arready;
    wire [31:0] AR_rdata;
    wire AR_rvalid;
    wire [31:0] AR_inst;
    wire AR_irvalid;
    wire AR_awready;
    wire AR_wready;
    wire [1:0] AR_bresp;
    wire AR_bvalid;
    wire [31:0] AR_m_araddr;
    wire AR_m_arvalid;
    wire AR_m_rready;
    wire [31:0] AR_m_awaddr;
    wire AR_m_awvalid;
    wire AR_m_wdata;
    wire [3:0] AR_m_wstrb;
    wire AR_m_wvalid;
    wire AR_m_bready;

    IF_CTRL _IF_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(IF_CTRL_valid),
        .ready(IF_CTRL_ready),
        .AR_valid(AR_irvalid),
        .ID_ready(ID_CTRL_ready),
        .ID_pc_opt(IDU_pc_opt),
        .I1_valid(ID_CTRL_valid_valid),
        .I1_pc_opt(Inst1_pc_opt),
        .I2_valid(EX_CTRL_valid_valid),
        .I2_pc_opt(Inst2_pc_opt),
        .I3_valid(ME_CTRL_valid_valid),
        .I3_pc_opt(Inst3_pc_opt)
    );

    IFU _IFU (
        .clk(clk),
        .ready(IF_CTRL_ready),
        .AR_inst(AR_inst),
        .inst(IFU_inst)
    );

    PC1 _PC1 (
        .clk(clk),
        .ready(IF_CTRL_ready),
        .PC_pc(PC_pc),
        .pc(PC1_pc)
    );

    ID_CTRL _ID_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(ID_CTRL_valid),
        .ready(ID_CTRL_ready),
        .IF_valid(IF_CTRL_valid),
        .EX_ready(EX_CTRL_ready),
        .rs1_group(IDU_rs1_group),
        .rs1_index(IDU_rs1_index),
        .rs2_group(IDU_rs2_group),
        .rs2_index(IDU_rs2_index),
        .rs3_group(IDU_rs3_group),
        .rs3_index(IDU_rs3_index),
        .I2_rd_group(Inst2_rd_group),
        .I2_rd_index(Inst2_rd_index),
        .I3_rd_group(Inst3_rd_group),
        .I3_rd_index(Inst3_rd_index)
    );

    IDU _IDU (
        .inst(IFU_inst),
        .opcode(IDU_opcode),
        .funct7(IDU_funct7),
        .funct3(IDU_funct3),
        .funct3Y(IDU_funct3Y),
        .funct2R4(IDU_funct2R4),
        .rd_group(IDU_rd_group),
        .rd_index(IDU_rd_index),
        .rs1_group(IDU_rs1_group),
        .rs1_index(IDU_rs1_index),
        .rs2_group(IDU_rs2_group),
        .rs2_index(IDU_rs2_index),
        .rs3_group(IDU_rs3_group),
        .rs3_index(IDU_rs3_index),
        .immU(IDU_immU),
        .immJ(IDU_immJ),
        .immB(IDU_immB),
        .immS(IDU_immS),
        .immI(IDU_immI),
        .matI(IDU_matI),
        .matJ(IDU_matJ),
        .pc_opt(IDU_pc_opt)
    );

    Inst1 _Inst1 (
        .clk(clk),
        .ready(ID_CTRL_ready),
        ._opcode(IDU_opcode),
        ._funct7(IDU_funct7),
        ._funct3(IDU_funct3),
        ._funct3Y(IDU_funct3Y),
        ._funct2R4(IDU_funct2R4),
        ._rd_group(IDU_rd_group),
        ._rd_index(IDU_rd_index),
        ._rs1_group(IDU_rs1_group),
        ._rs1_index(IDU_rs1_index),
        ._rs2_group(IDU_rs2_group),
        ._rs2_index(IDU_rs2_index),
        ._rs3_group(IDU_rs3_group),
        ._rs3_index(IDU_rs3_index),
        ._pc_opt(IDU_pc_opt),
        .opcode(Inst1_opcode),
        .funct7(Inst1_funct7),
        .funct3(Inst1_funct3),
        .funct3Y(Inst1_funct3Y),
        .funct2R4(Inst1_funct2R4),
        .rd_group(Inst1_rd_group),
        .rd_index(Inst1_rd_index),
        .rs1_group(Inst1_rs1_group),
        .rs1_index(Inst1_rs1_index),
        .rs2_group(Inst1_rs2_group),
        .rs2_index(Inst1_rs2_index),
        .rs3_group(Inst1_rs3_group),
        .rs3_index(Inst1_rs3_index),
        .pc_opt(Inst1_pc_opt)
    );

    Srcs _Srcs (
        .clk  (clk),
        .ready(ID_CTRL_ready),
        ._immU(IDU_immU),
        ._immJ(IDU_immJ),
        ._immB(IDU_immB),
        ._immS(IDU_immS),
        ._immI(IDU_immI),
        ._matI(IDU_matI),
        ._matJ(IDU_matJ),
        .immU (Srcs_immU),
        .immJ (Srcs_immJ),
        .immB (Srcs_immB),
        .immS (Srcs_immS),
        .immI (Srcs_immI),
        .matI (Srcs_matI),
        .matJ (Srcs_matJ)
    );

    PC2 _PC2 (
        .clk(clk),
        .ready(ID_CTRL_ready),
        .PC1_pc(PC_pc),
        .pc(PC2_pc)
    );

    EX_CTRL _EX_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(EX_CTRL_valid),
        .ready(EX_CTRL_ready),
        .ID_valid(ID_CTRL_valid),
        .ME_ready(ME_CTRL_ready)
    );

    Inst2 _Inst2 (
        .clk(clk),
        .ready(EX_CTRL_ready),
        ._opcode(Inst1_opcode),
        ._funct7(Inst1_funct7),
        ._funct3(Inst1_funct3),
        ._funct3Y(Inst1_funct3Y),
        ._funct2R4(Inst1_funct2R4),
        ._rd_group(Inst1_rd_group),
        ._rd_index(Inst1_rd_index),
        ._pc_opt(Inst1_pc_opt),
        .opcode(Inst2_opcode),
        .funct7(Inst2_funct7),
        .funct3(Inst2_funct3),
        .funct3Y(Inst2_funct3Y),
        .funct2R4(Inst2_funct2R4),
        .rd_group(Inst2_rd_group),
        .rd_index(Inst2_rd_index),
        .pc_opt(Inst2_pc_opt)
    );

    ALU _ALU (
        .npc  (PC2_pc),
        .opcode(Inst1_opcode),
        .funct7(Inst1_funct7),
        .funct3(Inst1_funct3),
        .funct3Y(Inst1_funct3Y),
        .funct2R4(Inst1_funct2R4),
        .immU (Srcs_immU),
        .immJ (Srcs_immJ),
        .immB (Srcs_immB),
        .immS (Srcs_immS),
        .immI (Srcs_immI),
        .matI (Srcs_matI),
        .matJ (Srcs_matJ),
        .pc   (PC2_pc),
        .src1R(Gpr_dout_R_rs1),
        .src1F(Gpr_dout_F_rs1),
        .src1M(Gpr_dout_M_rs1),
        .src2R(Gpr_dout_R_rs2),
        .src2F(Gpr_dout_F_rs2),
        .src2M(Gpr_dout_M_rs2),
        .src3R(Gpr_dout_R_rs3),
        .src3F(Gpr_dout_F_rs3),
        .src3M(Gpr_dout_M_rs3),
        .npc  (ALU_npc),
        .res_R(ALU_res_R),
        .res_F(ALU_res_F),
        .res_M(ALU_res_M)
    );

    ALU_OUT1 _ALU_OUT1 (
        .clk(clk),
        .ready(EX_CTRL_ready),
        ._npc(ALU_npc),
        ._res_R(ALU_res_R),
        ._res_F(ALU_res_F),
        ._res_M(ALU_res_M),
        ._rs2_R(Gpr_dout_R_rs2),
        ._rs2_F(Gpr_dout_F_rs2),
        ._rs2_M(Gpr_dout_M_rs2),
        .rs2_R(ALU_OUT1_rs2_R),
        .rs2_F(ALU_OUT1_rs2_F),
        .rs2_M(ALU_OUT1_rs2_M),
        .npc(ALU_OUT1_npc),
        .res_R(ALU_OUT1_res_R),
        .res_F(ALU_OUT1_res_F),
        .res_M(ALU_OUT1_res_M)
    );

    ME_CTRL _ME_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(ME_CTRL_valid),
        .ready(ME_CTRL_ready),
        .EX_valid(EX_CTRL_valid),
        .WB_ready(WB_CTRL_ready),
        .Data_Cache_state(DC_state)
    );

    Inst3 _Inst3 (
        .clk(clk),
        .ready(ME_CTRL_ready),
        ._opcode(Inst2_opcode),
        ._funct7(Inst2_funct7),
        ._funct3(Inst2_funct3),
        ._funct3Y(Inst2_funct3Y),
        ._funct2R4(Inst2_funct2R4),
        ._rd_group(Inst2_rd_group),
        ._rd_index(Inst2_rd_index),
        ._pc_opt(Inst2_pc_opt),
        .opcode(Inst3_opcode),
        .funct7(Inst3_funct7),
        .funct3(Inst3_funct3),
        .funct3Y(Inst3_funct3Y),
        .funct2R4(Inst3_funct2R4),
        .rd_group(Inst3_rd_group),
        .rd_index(Inst3_rd_index),
        .pc_opt(Inst3_pc_opt)
    );

    ALU_OUT2 _ALU_OUT2 (
        .clk(clk),
        .ready(ME_CTRL_ready),
        ._npc(ALU_OUT1_npc),
        ._res_R(ALU_OUT1_res_R),
        ._res_F(ALU_OUT1_res_F),
        ._res_M(ALU_OUT1_res_M),
        .npc(ALU_OUT2_npc),
        .res_R(ALU_OUT2_res_R),
        .res_F(ALU_OUT2_res_F),
        .res_M(ALU_OUT2_res_M)
    );

    Data_Cache _Data_Cache (
        .clk(clk),
        .rst(rst),
        .ready(ME_CTRL_ready),
        .state(DC_state),
        ._opcode(Inst2_opcode),
        ._funct3(Inst2_funct3),
        ._addr(ALU_OUT1_res_R),
        .wdata_R(ALU_OUT1_rs2_R),
        .wdata_F(ALU_OUT1_rs2_F),
        .wdata_M(ALU_OUT1_rs2_M),
        .rdata_R_valid(DC_rdata_R_valid),
        .rdata_R(DC_rdata_R),
        .rdata_F_valid(DC_rdata_F_valid),
        .rdata_F(DC_rdata_F),
        .rdata_M_valid(DC_rdata_M_valid),
        .rdata_M(DC_rdata_M),
        .maraddr(DC_maraddr),
        .marvalid(DC_marvalid),
        .marready(AR_arready),
        .mrdata(AR_rdata),
        .mrvalid(AR_rvalid),
        .mrready(DC_mrready),
        .mawaddr(DC_mawaddr),
        .mawvalid(DC_mawvalid),
        .mawready(AR_awready),
        .mwdata(DC_mwdata),
        .mwstrb(DC_mwstrb),
        .mwvalid(DC_mwvalid),
        .mwready(AR_wready),
        .mbresp(AR_bresp),
        .mbvalid(AR_bvalid),
        .mbready(DC_mbready)
    );

    WB_CTRL _WB_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(WB_CTRL_valid),
        .ready(WB_CTRL_ready),
        .ME_valid(ME_CTRL_valid)
    );

    GprMux _GprMux (
        .ME_valid(ME_CTRL_valid),
        .opcode(Inst3_opcode),
        .funct7(Inst3_funct7),
        .funct3(Inst3_funct3),
        .funct3Y(Inst3_funct3Y),
        .funct2R4(Inst3_funct2R4),
        .ALU_OUT2_res_R(ALU_OUT2_res_R),
        .ALU_OUT2_res_F(ALU_OUT2_res_F),
        .ALU_OUT2_res_M(ALU_OUT2_res_M),
        .DC_R_valid(DC_rdata_R_valid),
        .DC_data_R(DC_rdata_R),
        .DC_F_valid(DC_rdata_F_valid),
        .DC_data_F(DC_rdata_F),
        .DC_M_valid(DC_rdata_M_valid),
        .DC_data_M(DC_rdata_M),
        .we(GprMux_we),
        .R(GprMux_R),
        .F(GprMux_F),
        .M(GprMux_M)
    );

    Gpr _Gpr (
        .clk(clk),
        .rst(rst),
        .we(GprMux_we),
        .rd_group(Inst3_rd_group),
        .rd_index(Inst3_rd_index),
        .din_R(GprMux_R),
        .din_F(GprMux_F),
        .din_M(GprMux_M),
        .rs1_group(Inst1_rs1_group),
        .rs1_index(Inst1_rs1_index),
        .dout_R_rs1(Gpr_dout_R_rs1),
        .dout_F_rs1(Gpr_dout_F_rs1),
        .dout_M_rs1(Gpr_dout_M_rs1),
        .rs2_group(Inst1_rs2_group),
        .rs2_index(Inst1_rs2_index),
        .dout_R_rs2(Gpr_dout_R_rs2),
        .dout_F_rs2(Gpr_dout_F_rs2),
        .dout_M_rs2(Gpr_dout_M_rs2),
        .rs3_group(Inst1_rs3_group),
        .rs3_index(Inst1_rs3_index),
        .dout_R_rs3(Gpr_dout_R_rs3),
        .dout_F_rs3(Gpr_dout_F_rs3),
        .dout_M_rs3(Gpr_dout_M_rs3)
    );


    // PC还要加一个we
    PC _PC (
        .clk(clk),
        .rst(rst),
        .AR_ready(AR_pcrready),
        .IF_ready(IF_CTRL_ready),
        .valid(PC_valid),
        .pc_opt(Inst3_pc_opt),
        .npc(ALU_OUT2_npc),
        .pc(PC_pc)
    );

    AR _AR (
        .pcraddr(PC_pc),
        .pcrvalid(PC_valid),
        .pcrready(AR_pcrready),
        .araddr(DC_maraddr),
        .arvalid(DC_marvalid),
        .arready(AR_arready),
        .rdata(AR_rdata),
        .rvalid(AR_rvalid),
        .inst(AR_inst),
        .irvalid(AR_irvalid),
        .awaddr(DC_mawaddr),
        .awvalid(DC_mawvalid),
        .awready(AR_awready),
        .wdata(DC_mwdata),
        .wstrb(DC_mwstrb),
        .wvalid(DC_mwvalid),
        .wready(AR_wready),
        .bresp(DC_mbresp),
        .bvalid(DC_mbvalid),
        .bready(AXI_bready),
        .m_araddr(AR_m_araddr),
        .m_arvalid(AR_m_arvalid),
        .m_arready(AXI_arready),
        .m_rdata(AXI_rdata),
        .m_rvalid(AXI_rvalid),
        .m_rready(AR_m_rready),
        .m_awaddr(AR_m_awaddr),
        .m_awvalid(AR_m_awvalid),
        .m_awready(AXI_awready),
        .m_wdata(AR_m_wdata),
        .m_wstrb(AR_m_wstrb),
        .m_wvalid(AR_m_wvalid),
        .m_wready(AXI_wready),
        .m_bresp(AXI_bresp),
        .m_bvalid(AXI_bvalid),
        .m_bready(AR_m_bready)
    );

    assign AXI_araddr  = AR_m_araddr;
    assign AXI_arvalid = AR_m_arvalid;
    assign AXI_rready  = AR_m_rready;
    assign AXI_awaddr  = AR_m_awaddr;
    assign AXI_awvalid = AR_m_awvalid;
    assign AXI_wdata   = AR_m_wdata;
    assign AXI_wstrb   = AR_m_wstrb;
    assign AXI_wvalid  = AR_m_wvalid;
    assign AXI_bready  = AR_m_bready;

endmodule
