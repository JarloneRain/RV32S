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
    wire [31:0] PC1_snpc;
    // ID
    //  ID_CTRL
    wire ID_CTRL_valid;
    wire ID_CTRL_ready;
    wire ID_CTRL_conflict;  // just for debug
    //  IDU
    wire [6:0] IDU_opcode;
    wire [6:0] IDU_funct7;
    wire [2:0] IDU_funct3;
    wire [2:0] IDU_funct3Y;
    wire [1:0] IDU_funct2R4;
    wire [1:0] IDU_rd_group;
    wire [4:0] IDU_rd_index;
    wire [1:0] IDU_rs1_group;
    wire [4:0] IDU_rs1_index;
    wire [1:0] IDU_rs2_group;
    wire [4:0] IDU_rs2_index;
    wire [1:0] IDU_rs3_group;
    wire [4:0] IDU_rs3_index;
    wire [31:0] IDU_immU;
    wire [31:0] IDU_immJ;
    wire [31:0] IDU_immB;
    wire [31:0] IDU_immS;
    wire [31:0] IDU_immI;
    wire [1:0] IDU_matI;
    wire [1:0] IDU_matJ;
    wire IDU_pc_opt;
    //  Inst1
    wire [6:0] Inst1_opcode;
    wire [6:0] Inst1_funct7;
    wire [2:0] Inst1_funct3;
    wire [2:0] Inst1_funct3Y;
    wire [1:0] Inst1_funct2R4;
    wire [4:0] Inst1_rs2;
    wire [1:0] Inst1_rd_group;
    wire [4:0] Inst1_rd_index;
    wire [1:0] Inst1_rs1_group;
    wire [4:0] Inst1_rs1_index;
    wire [1:0] Inst1_rs2_group;
    wire [4:0] Inst1_rs2_index;
    wire [1:0] Inst1_rs3_group;
    wire [4:0] Inst1_rs3_index;
    wire Inst1_pc_opt;
    //  Srcs
    wire [31:0] Srcs_immU;
    wire [31:0] Srcs_immJ;
    wire [31:0] Srcs_immB;
    wire [31:0] Srcs_immS;
    wire [31:0] Srcs_immI;
    wire [1:0] Srcs_matI;
    wire [1:0] Srcs_matJ;
    wire [31:0] Srcs_src1R;
    wire [31:0] Srcs_src2R;
    wire [31:0] Srcs_src3R;
    wire [31:0] Srcs_src1F;
    wire [31:0] Srcs_src2F;
    wire [31:0] Srcs_src3F;
    wire [511:0] Srcs_src1M;
    wire [511:0] Srcs_src2M;
    wire [511:0] Srcs_src3M;
    //  PC2
    wire [31:0] PC2_snpc;
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
    wire [31:0] AR_m_wdata;
    wire [3:0] AR_m_wstrb;
    wire AR_m_wvalid;
    wire AR_m_bready;
    wire pc_opt = (IF_CTRL_valid & IDU_pc_opt)
                | (ID_CTRL_valid & Inst1_pc_opt)
                | (EX_CTRL_valid & Inst2_pc_opt)
                | (ME_CTRL_valid & Inst3_pc_opt);
    wire we_PC = ME_CTRL_valid & Inst3_pc_opt;

    IF_CTRL _IF_CTRL (
        .clk(clk),
        .rst(rst),
        .valid(IF_CTRL_valid),
        .ready(IF_CTRL_ready),
        .AR_valid(AR_irvalid),
        .ID_ready(ID_CTRL_ready),
        .pc_opt(pc_opt)
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
        .PC_snpc(PC_pc),
        .snpc(PC1_snpc)
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
        .I1_valid(ID_CTRL_valid),
        .I1_rd_group(Inst1_rd_group),
        .I1_rd_index(Inst1_rd_index),
        .I2_valid(EX_CTRL_valid),
        .I2_rd_group(Inst2_rd_group),
        .I2_rd_index(Inst2_rd_index),
        .I3_valid(ME_CTRL_valid),
        .I3_rd_group(Inst3_rd_group),
        .I3_rd_index(Inst3_rd_index),
        .conflict(ID_CTRL_conflict)
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
        ._rs2(Inst1_rs2),
        ._rd_group(IDU_rd_group),
        ._rd_index(IDU_rd_index),
        // ._rs1_group(IDU_rs1_group),
        // ._rs1_index(IDU_rs1_index),
        // ._rs2_group(IDU_rs2_group),
        // ._rs2_index(IDU_rs2_index),
        // ._rs3_group(IDU_rs3_group),
        // ._rs3_index(IDU_rs3_index),
        ._pc_opt(IDU_pc_opt),
        .opcode(Inst1_opcode),
        .funct7(Inst1_funct7),
        .funct3(Inst1_funct3),
        .funct3Y(Inst1_funct3Y),
        .funct2R4(Inst1_funct2R4),
        .rs2(Inst1_rs2),
        .rd_group(Inst1_rd_group),
        .rd_index(Inst1_rd_index),
        // .rs1_group(Inst1_rs1_group),
        // .rs1_index(Inst1_rs1_index),
        // .rs2_group(Inst1_rs2_group),
        // .rs2_index(Inst1_rs2_index),
        // .rs3_group(Inst1_rs3_group),
        // .rs3_index(Inst1_rs3_index),
        .pc_opt(Inst1_pc_opt)
    );

    Srcs _Srcs (
        .clk(clk),
        .ready(ID_CTRL_ready),
        ._immU(IDU_immU),
        ._immJ(IDU_immJ),
        ._immB(IDU_immB),
        ._immS(IDU_immS),
        ._immI(IDU_immI),
        ._matI(IDU_matI),
        ._matJ(IDU_matJ),
        ._src1R(Gpr_dout_R_rs1),
        ._src2R(Gpr_dout_R_rs2),
        ._src3R(Gpr_dout_R_rs3),
        ._src1F(Gpr_dout_F_rs1),
        ._src2F(Gpr_dout_F_rs2),
        ._src3F(Gpr_dout_F_rs3),
        ._src1M(Gpr_dout_M_rs1),
        ._src2M(Gpr_dout_M_rs2),
        ._src3M(Gpr_dout_M_rs3),
        .immU(Srcs_immU),
        .immJ(Srcs_immJ),
        .immB(Srcs_immB),
        .immS(Srcs_immS),
        .immI(Srcs_immI),
        .matI(Srcs_matI),
        .matJ(Srcs_matJ),
        .src1R(Srcs_src1R),
        .src2R(Srcs_src2R),
        .src3R(Srcs_src3R),
        .src1F(Srcs_src1F),
        .src2F(Srcs_src2F),
        .src3F(Srcs_src3F),
        .src1M(Srcs_src1M),
        .src2M(Srcs_src2M),
        .src3M(Srcs_src3M)
    );

    PC2 _PC2 (
        .clk(clk),
        .ready(ID_CTRL_ready),
        .PC1_snpc(PC1_snpc),
        .snpc(PC2_snpc)
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
        .opcode(Inst1_opcode),
        .funct7(Inst1_funct7),
        .funct3(Inst1_funct3),
        .funct3Y(Inst1_funct3Y),
        .funct2R4(Inst1_funct2R4),
        .rs2(Inst1_rs2),
        .immU(Srcs_immU),
        .immJ(Srcs_immJ),
        .immB(Srcs_immB),
        .immS(Srcs_immS),
        .immI(Srcs_immI),
        .matI(Srcs_matI),
        .matJ(Srcs_matJ),
        .snpc(PC2_snpc),
        .src1R(Srcs_src1R),
        .src2R(Srcs_src2R),
        .src3R(Srcs_src3R),
        .src1F(Srcs_src1F),
        .src2F(Srcs_src2F),
        .src3F(Srcs_src3F),
        .src1M(Srcs_src1M),
        .src2M(Srcs_src2M),
        .src3M(Srcs_src3M),
        .npc(ALU_npc),
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
        .opcode(Inst2_opcode),
        .funct3(Inst2_funct3),
        .addr(ALU_OUT1_res_R),
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
        .rs1_group(IDU_rs1_group),
        .rs1_index(IDU_rs1_index),
        .dout_R_rs1(Gpr_dout_R_rs1),
        .dout_F_rs1(Gpr_dout_F_rs1),
        .dout_M_rs1(Gpr_dout_M_rs1),
        .rs2_group(IDU_rs2_group),
        .rs2_index(IDU_rs2_index),
        .dout_R_rs2(Gpr_dout_R_rs2),
        .dout_F_rs2(Gpr_dout_F_rs2),
        .dout_M_rs2(Gpr_dout_M_rs2),
        .rs3_group(IDU_rs3_group),
        .rs3_index(IDU_rs3_index),
        .dout_R_rs3(Gpr_dout_R_rs3),
        .dout_F_rs3(Gpr_dout_F_rs3),
        .dout_M_rs3(Gpr_dout_M_rs3)
    );


    // PC还要加一个we
    PC _PC (
        .clk(clk),
        .rst(rst),
        .ME_valid(ME_CTRL_valid),
        .AR_ready(AR_pcrready),
        .IF_valid(IF_CTRL_valid),
        .valid(PC_valid),
        .we(we_PC),
        .npc(ALU_OUT2_npc),
        .pc(PC_pc),
        .pc_opt(pc_opt),
        .IF_snpc(PC1_snpc)
    );

    AR _AR (
        .clk(clk),
        .rst(rst),
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
        .rready(DC_mrready),
        .irready(IF_CTRL_ready),
        .awaddr(DC_mawaddr),
        .awvalid(DC_mawvalid),
        .awready(AR_awready),
        .wdata(DC_mwdata),
        .wstrb(DC_mwstrb),
        .wvalid(DC_mwvalid),
        .wready(AR_wready),
        .bresp(AR_bresp),
        .bvalid(AR_bvalid),
        .bready(DC_mbready),
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

    integer t = 0;
    always @(posedge clk) begin
        $display("\nt=%d rst=%d pc_opt=%d", t, rst, pc_opt);
        t = t + 1;
        $display("\tIF valid=%d  ready=%d", IF_CTRL_valid, IF_CTRL_ready);
        if (IF_CTRL_valid) begin
            $display("\t\tIFU inst=%h", IFU_inst);
            $display("\t\tPC1 snpc=%h", PC1_snpc);
            $display("\t\tIDU opcode=%h  funct7=%h  funct3=%h  funct3Y=%h  funct2R4=%h",
                     IDU_opcode, IDU_funct7, IDU_funct3, IDU_funct3Y, IDU_funct2R4);
            $display(
                "\t\tIDU rd_group=%d  rd_index=%d  rs1_group=%d  rs1_index=%d  rs2_group=%d  rs2_index=%d  rs3_group=%d  rs3_index=%d",
                IDU_rd_group, IDU_rd_index, IDU_rs1_group, IDU_rs1_index, IDU_rs2_group,
                IDU_rs2_index, IDU_rs3_group, IDU_rs3_index);
            $display("\t\tIDU immU=%h  immJ=%h  immB=%h  immS=%h  immI=%h  matI=%h  matJ=%h",
                     IDU_immU, IDU_immJ, IDU_immB, IDU_immS, IDU_immI, IDU_matI, IDU_matJ);
            $display("\t\tIDU pc_opt=%d", IDU_pc_opt);
        end
        $display("\tID valid=%d  ready=%d conflict=%d", ID_CTRL_valid, ID_CTRL_ready,
                 ID_CTRL_conflict);
        if (ID_CTRL_valid) begin
            $display("\t\tInst1 opcode=%h  funct7=%h  funct3=%h  funct3Y=%h  funct2R4=%h",
                     Inst1_opcode, Inst1_funct7, Inst1_funct3, Inst1_funct3Y, Inst1_funct2R4);
            $display("\t\t      rd_group=%d rd_index=%d pc_opt=%d",  //
                     Inst1_rd_group, Inst1_rd_index, Inst1_pc_opt);
            $display("\t\tSrcs immU=%h  immJ=%h  immB=%h  immS=%h  immI=%h  matI=%h  matJ=%h",
                     Srcs_immU, Srcs_immJ, Srcs_immB, Srcs_immS, Srcs_immI, Srcs_matI, Srcs_matJ);
            $display("\t\t     src1R=%h src1F=%h src1M=%h", Srcs_src1R, Srcs_src1F, Srcs_src1M);
            $display("\t\t     src2R=%h src2F=%h src2M=%h", Srcs_src2R, Srcs_src2F, Srcs_src2M);
            $display("\t\t     src3R=%h src3F=%h src3M=%h", Srcs_src3R, Srcs_src3F, Srcs_src3M);
            $display("\t\tPC2 snpc=%h", PC2_snpc);
            $display("\t\tALU npc=%h  res_R=%h  res_F=%h  res_M=%h", ALU_npc, ALU_res_R, ALU_res_F,
                     ALU_res_M);
        end
        $display("\tEX valid=%d  ready=%d", EX_CTRL_valid, EX_CTRL_ready);
        if (EX_CTRL_valid) begin
            $display("\t\tInst2 opcode=%h  funct7=%h  funct3=%h  funct3Y=%h  funct2R4=%h",
                     Inst2_opcode, Inst2_funct7, Inst2_funct3, Inst2_funct3Y, Inst2_funct2R4);
            $display(
                "\t\t      rs1_group=%d rs1_index=%d rs2_group=%d rs2_index=%d rs3_group=%d rs3_index=%d",
                Inst1_rs1_group, Inst1_rs1_index, Inst1_rs2_group, Inst1_rs2_index,
                Inst1_rs3_group, Inst1_rs3_index);
            $display("\t\t      rd_group=%d rd_index=%d pc_opt=%d", Inst2_rd_group, Inst2_rd_index,
                     Inst3_pc_opt);
            $display(
                "\t\tALU_OUT1 npc=%h  res_R=%h  res_F=%h  res_M=%h  rs2_R=%h  rs2_F=%h  rs2_M=%h",
                ALU_OUT1_npc, ALU_OUT1_res_R, ALU_OUT1_res_F, ALU_OUT1_res_M, ALU_OUT1_rs2_R,
                ALU_OUT1_rs2_F, ALU_OUT1_rs2_M);
        end
        $display(
            "\t  Data_Cache state=%h  rdata_R_valid=%d  rdata_R=%h  rdata_F_valid=%d  rdata_F=%h  rdata_M_valid=%d  rdata_M=%h",
            DC_state, DC_rdata_R_valid, DC_rdata_R, DC_rdata_F_valid, DC_rdata_F, DC_rdata_M_valid,
            DC_rdata_M);
        $display(
            "\t  Data_Cache maraddr=%h  marvalid=%d  mrready=%d  mawaddr=%h  mawvalid=%d  mwdata=%h  mwstrb=%h  mwvalid=%d  mbready=%d",
            DC_maraddr, DC_marvalid, DC_mrready, DC_mawaddr, DC_mawvalid, DC_mwdata, DC_mwstrb,
            DC_mwvalid, DC_mbready);
        $display("\tME valid=%d  ready=%d", ME_CTRL_valid, ME_CTRL_ready);
        if (ME_CTRL_valid) begin
            $display("\t\tInst3 opcode=%h  funct7=%h  funct3=%h  funct3Y=%h  funct2R4=%h",
                     Inst3_opcode, Inst3_funct7, Inst3_funct3, Inst3_funct3Y, Inst3_funct2R4);
            $display("\t\t      rd_group=%d rd_index=%d pc_opt=%d", Inst3_rd_group, Inst3_rd_index,
                     Inst3_pc_opt);
            $display("\t\tALU_OUT2 npc=%h  res_R=%h  res_F=%h  res_M=%h", ALU_OUT2_npc,
                     ALU_OUT2_res_R, ALU_OUT2_res_F, ALU_OUT2_res_M);
            $display("\t\tGprMux we=%d  R=%h  F=%h  M=%h", GprMux_we, GprMux_R, GprMux_F, GprMux_M);
        end
        //$display("\tWB valid=%d  ready=%d", WB_CTRL_valid, WB_CTRL_ready);
        $display("\tGpr dout_R_rs1=%h  dout_F_rs1=%h  dout_M_rs1=%h",  //
                 Gpr_dout_R_rs1, Gpr_dout_F_rs1, Gpr_dout_M_rs1);
        $display("\t    dout_R_rs2=%h  dout_F_rs2=%h  dout_M_rs2=%h",  //
                 Gpr_dout_R_rs2, Gpr_dout_F_rs2, Gpr_dout_M_rs2);
        $display("\t    dout_R_rs3=%h  dout_F_rs3=%h  dout_M_rs3=%h",  //
                 Gpr_dout_R_rs3, Gpr_dout_F_rs3, Gpr_dout_M_rs3);
        $display("\tPC valid=%d  pc=%h", PC_valid, PC_pc);
        $display(
            "\tAR pcrready=%d  arready=%d  rdata=%h  rvalid=%d  inst=%h  irvalid=%d  awready=%d  wready=%d  bresp=%h  bvalid=%d",
            AR_pcrready, AR_arready, AR_rdata, AR_rvalid, AR_inst, AR_irvalid, AR_awready,
            AR_wready, AR_bresp, AR_bvalid);
        $display(
            "\t   m_araddr=%h  m_arvalid=%d  m_rready=%d  m_awaddr=%h  m_awvalid=%d  m_wdata=%h  m_wstrb=%h  m_wvalid=%d  m_bready=%d",
            AR_m_araddr, AR_m_arvalid, AR_m_rready, AR_m_awaddr, AR_m_awvalid, AR_m_wdata,
            AR_m_wstrb, AR_m_wvalid, AR_m_bready);
        //AXI
        $display("\tAXI");
        $display("\t\taraddr=%h,arvalid =%b, arready=%b",  //
                 AXI_araddr, AXI_arvalid, AXI_arready);
        $display("\t\trdata =%h, rvalid =%b, rready =%b",  //
                 AXI_rdata, AXI_rvalid, AXI_rready);
        $display("\t\tawaddr=%h, awvalid=%b, awready=%b",  //
                 AXI_awaddr, AXI_awvalid, AXI_awready);
        $display("\t\twdata =%h, wvalid =%b, wready =%b, wstrb=%h",  //
                 AXI_wdata, AXI_wvalid, AXI_wready, AXI_wstrb);
        $display("\t\tbresp =%h, bvalid =%b, bready =%b",  //
                 AXI_bresp, AXI_bvalid, AXI_bready);
    end

endmodule
