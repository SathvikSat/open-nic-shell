`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps

module qdma_subsystem_wrapper #(
    parameter int MIN_PKT_LEN_W   = 64,   //Bytes
    parameter int MAX_PKT_LEN_W   = 1518, //Bytes
    parameter int USE_PHYS_FUNC_W = 1,
    parameter int NUM_PHYS_FUNC_W = 1,
    parameter int NUM_QUEUE_W     = 512
) (
  input                          s_axil_awvalid_wrap,
  input                   [31:0] s_axil_awaddr_wrap,
  output                         s_axil_awready_wrap,
  input                          s_axil_wvalid_wrap,
  input                   [31:0] s_axil_wdata_wrap,
  output                         s_axil_wready_wrap,
  output                         s_axil_bvalid_wrap,
  output                   [1:0] s_axil_bresp_wrap,
  input                          s_axil_bready_wrap,
  input                          s_axil_arvalid_wrap,
  input                   [31:0] s_axil_araddr_wrap,
  output                         s_axil_arready_wrap,
  output                         s_axil_rvalid_wrap,
  output                  [31:0] s_axil_rdata_wrap,
  output                   [1:0] s_axil_rresp_wrap,
  input                          s_axil_rready_wrap,

  output     [NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tvalid_wrap,
  output [512*NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tdata_wrap,
  output  [64*NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tkeep_wrap,
  output     [NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tlast_wrap,
  output  [16*NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tuser_size_wrap,
  output  [16*NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tuser_src_wrap,
  output  [16*NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tuser_dst_wrap,
  input      [NUM_PHYS_FUNC_W-1:0] m_axis_h2c_tready_wrap,

  input      [NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tvalid_wrap,
  input  [512*NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tdata_wrap,
  input   [64*NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tkeep_wrap,
  input      [NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tlast_wrap,
  input   [16*NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tuser_size_wrap,
  input   [16*NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tuser_src_wrap,
  input   [16*NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tuser_dst_wrap,
  output     [NUM_PHYS_FUNC_W-1:0] s_axis_c2h_tready_wrap,

`ifdef __synthesis__
  input                   [15:0] pcie_rxp_wrap,
  input                   [15:0] pcie_rxn_wrap,
  output                  [15:0] pcie_txp_wrap,
  output                  [15:0] pcie_txn_wrap,

  // BAR2-mapped master AXI-Lite feeding into system configuration block
  output                         m_axil_pcie_awvalid_wrap,
  output                  [31:0] m_axil_pcie_awaddr_wrap,
  input                          m_axil_pcie_awready_wrap,
  output                         m_axil_pcie_wvalid_wrap,
  output                  [31:0] m_axil_pcie_wdata_wrap,
  input                          m_axil_pcie_wready_wrap,
  input                          m_axil_pcie_bvalid_wrap,
  input                    [1:0] m_axil_pcie_bresp_wrap,
  output                         m_axil_pcie_bready_wrap,
  output                         m_axil_pcie_arvalid_wrap,
  output                  [31:0] m_axil_pcie_araddr_wrap,
  input                          m_axil_pcie_arready_wrap,
  input                          m_axil_pcie_rvalid_wrap,
  input                   [31:0] m_axil_pcie_rdata_wrap,
  input                    [1:0] m_axil_pcie_rresp_wrap,
  output                         m_axil_pcie_rready_wrap,

  input                          pcie_refclk_p_wrap,
  input                          pcie_refclk_n_wrap,
  input                          pcie_rstn_wrap,
  output                         user_lnk_up_wrap,
  output                         phy_ready_wrap,

   // This reset signal serves as a power-up reset for the entire system.  It is
  // routed into the `system_config` submodule to generate proper reset signals
  // for each submodule.
  output                         powerup_rstn_wrap,
`else // !`ifdef __synthesis__

  input                          s_axis_qdma_h2c_tvalid_wrap,
  input                  [511:0] s_axis_qdma_h2c_tdata_wrap,
  input                   [31:0] s_axis_qdma_h2c_tcrc_wrap,
  input                          s_axis_qdma_h2c_tlast_wrap,
  input                   [10:0] s_axis_qdma_h2c_tuser_qid_wrap,
  input                    [2:0] s_axis_qdma_h2c_tuser_port_id_wrap,
  input                          s_axis_qdma_h2c_tuser_err_wrap,
  input                   [31:0] s_axis_qdma_h2c_tuser_mdata_wrap,
  input                    [5:0] s_axis_qdma_h2c_tuser_mty_wrap,
  input                          s_axis_qdma_h2c_tuser_zero_byte_wrap,
  output                         s_axis_qdma_h2c_tready_wrap,

  output                         m_axis_qdma_c2h_tvalid_wrap,
  output                 [511:0] m_axis_qdma_c2h_tdata_wrap,
  output                  [31:0] m_axis_qdma_c2h_tcrc_wrap,
  output                         m_axis_qdma_c2h_tlast_wrap,
  output                         m_axis_qdma_c2h_ctrl_marker_wrap,
  output                   [2:0] m_axis_qdma_c2h_ctrl_port_id_wrap,
  output                   [6:0] m_axis_qdma_c2h_ctrl_ecc_wrap,
  output                  [15:0] m_axis_qdma_c2h_ctrl_len_wrap,
  output                  [10:0] m_axis_qdma_c2h_ctrl_qid_wrap,
  output                         m_axis_qdma_c2h_ctrl_has_cmpt_wrap,
  output                   [5:0] m_axis_qdma_c2h_mty_wrap,
  input                          m_axis_qdma_c2h_tready_wrap, 

  output                         m_axis_qdma_cpl_tvalid_wrap,
  output                 [511:0] m_axis_qdma_cpl_tdata_wrap,
  output                   [1:0] m_axis_qdma_cpl_size_wrap,
  output                  [15:0] m_axis_qdma_cpl_dpar_wrap,
  output                  [10:0] m_axis_qdma_cpl_ctrl_qid_wrap,
  output                   [1:0] m_axis_qdma_cpl_ctrl_cmpt_type_wrap,
  output                  [15:0] m_axis_qdma_cpl_ctrl_wait_pld_pkt_id_wrap,
  output                   [2:0] m_axis_qdma_cpl_ctrl_port_id_wrap,
  output                         m_axis_qdma_cpl_ctrl_marker_wrap,
  output                         m_axis_qdma_cpl_ctrl_user_trig_wrap,
  output                   [2:0] m_axis_qdma_cpl_ctrl_col_idx_wrap,
  output                   [2:0] m_axis_qdma_cpl_ctrl_err_idx_wrap,
  output                         m_axis_qdma_cpl_ctrl_no_wrb_marker_wrap,
  input                          m_axis_qdma_cpl_tready_wrap,

`endif

  input                          mod_rstn_wrap,
  output                         mod_rst_done_wrap,

`ifdef __synthesis__
  output                         axil_aclk_wrap,

  `ifdef __au55n__
    output                         ref_clk_100mhz_wrap,
  `elsif __au55c__
    output                         ref_clk_100mhz_wrap,
  `endif
  output                         axis_aclk_wrap //no comma?

`else // !`ifdef __synthesis__
  output reg                     axil_aclk_wrap,

  `ifdef __au55n__
    output reg                     ref_clk_100mhz_wrap,
  `elsif __au55c__
    output reg                     ref_clk_100mhz_wrap,
  `endif
  
  output reg                     axis_aclk_wrap
`endif

);


qdma_subsystem #(
    .MIN_PKT_LEN(MIN_PKT_LEN_W),
    .MAX_PKT_LEN(MAX_PKT_LEN_W),
    .USE_PHYS_FUNC(USE_PHYS_FUNC_W),
    .NUM_PHYS_FUNC(NUM_PHYS_FUNC_W),
    .NUM_QUEUE(NUM_PHYS_FUNC_W)    
) qdma_subsystem_inst (
        .s_axil_awvalid( s_axil_awvalid_wrap ),
        .s_axil_awaddr( s_axil_awaddr_wrap ),
        .s_axil_awready( s_axil_awready_wrap ),
        .s_axil_wvalid( s_axil_wvalid_wrap ),
        .s_axil_wdata( s_axil_wdata_wrap ),
        .s_axil_wready( s_axil_wready_wrap ),
        .s_axil_bvalid( s_axil_bvalid_wrap ),
        .s_axil_bresp( s_axil_bresp_wrap ),
        .s_axil_bready( s_axil_bready_wrap ),
        .s_axil_arvalid( s_axil_arvalid_wrap ),
        .s_axil_araddr( s_axil_araddr_wrap ),
        .s_axil_arready( s_axil_arready_wrap ),
        .s_axil_rvalid( s_axil_rvalid_wrap ),
        .s_axil_rdata( s_axil_rdata_wrap ),
        .s_axil_rresp( s_axil_rresp_wrap ),
        .s_axil_rready( s_axil_rready_wrap ),

        .m_axis_h2c_tvalid( m_axis_h2c_tvalid_wrap ),
        .m_axis_h2c_tdata( m_axis_h2c_tdata_wrap ),
        .m_axis_h2c_tkeep( m_axis_h2c_tkeep_wrap ),
        .m_axis_h2c_tlast( m_axis_h2c_tlast_wrap ),
        .m_axis_h2c_tuser_size( m_axis_h2c_tuser_size_wrap ),
        .m_axis_h2c_tuser_src( m_axis_h2c_tuser_src_wrap ),
        .m_axis_h2c_tuser_dst( m_axis_h2c_tuser_dst_wrap ),
        .m_axis_h2c_tready( m_axis_h2c_tready_wrap ),

        .s_axis_c2h_tvalid( s_axis_c2h_tvalid_wrap ),
        .s_axis_c2h_tdata( s_axis_c2h_tdata_wrap ),
        .s_axis_c2h_tkeep( s_axis_c2h_tkeep_wrap ),
        .s_axis_c2h_tlast( s_axis_c2h_tlast_wrap ),
        .s_axis_c2h_tuser_size( s_axis_c2h_tuser_size_wrap ),
        .s_axis_c2h_tuser_src( s_axis_c2h_tuser_src_wrap ),
        .s_axis_c2h_tuser_dst( s_axis_c2h_tuser_dst_wrap ),
        .s_axis_c2h_tready( s_axis_c2h_tready_wrap ),
`ifdef __synthesis__
        .pcie_rxp( pcie_rxp_wrap ),
        .pcie_rxn( pcie_rxn_wrap ),
        .pcie_txp( pcie_txp_wrap ),
        .pcie_txn( pcie_txn_wrap ),

  // BAR2-mapped master AXI-Lite feeding into system configuration block

        .m_axil_pcie_awvalid( m_axil_pcie_awvalid_wrap ), 
        .m_axil_pcie_awaddr( m_axil_pcie_awaddr_wrap ), 
        .m_axil_pcie_awready( m_axil_pcie_awready_wrap ), 
        .m_axil_pcie_wvalid( m_axil_pcie_wvalid_wrap ), 
        .m_axil_pcie_wdata( m_axil_pcie_wdata_wrap ), 
        .m_axil_pcie_wready( m_axil_pcie_wready_wrap ), 
        .m_axil_pcie_bvalid( m_axil_pcie_bvalid_wrap ), 
        .m_axil_pcie_bresp( m_axil_pcie_bresp_wrap ), 
        .m_axil_pcie_bready( m_axil_pcie_bready_wrap ), 
        .m_axil_pcie_arvalid( m_axil_pcie_arvalid_wrap ), 
        .m_axil_pcie_araddr( m_axil_pcie_araddr_wrap ), 
        .m_axil_pcie_arready( m_axil_pcie_arready_wrap ), 
        .m_axil_pcie_rvalid( m_axil_pcie_rvalid_wrap ), 
        .m_axil_pcie_rdata( m_axil_pcie_rdata_wrap ), 
        .m_axil_pcie_rresp( m_axil_pcie_rresp_wrap ), 
        .m_axil_pcie_rready( m_axil_pcie_rready_wrap ), 

        .pcie_refclk_p( pcie_refclk_p_wrap ),
        .pcie_refclk_n( pcie_refclk_n_wrap ),
        .pcie_rstn( pcie_rstn_wrap ),
        .user_lnk_up( user_lnk_up_wrap ),
        .phy_ready( phy_ready_wrap ),

    // This reset signal serves as a power-up reset for the entire system.  It is
  // routed into the `system_config` submodule to generate proper reset signals
  // for each submodule.
        .powerup_rstn( powerup_rstn_wrap ),
`else // !`ifdef __synthesis__
        .s_axis_qdma_h2c_tvalid(  s_axis_qdma_h2c_tvalid_wrap ),
        .s_axis_qdma_h2c_tdata(  s_axis_qdma_h2c_tdata_wrap ),
        .s_axis_qdma_h2c_tcrc(  s_axis_qdma_h2c_tcrc_wrap ),
        .s_axis_qdma_h2c_tlast(  s_axis_qdma_h2c_tlast_wrap ),
        .s_axis_qdma_h2c_tuser_qid(  s_axis_qdma_h2c_tuser_qid_wrap ),
        .s_axis_qdma_h2c_tuser_port_id(  s_axis_qdma_h2c_tuser_port_id_wrap ),
        .s_axis_qdma_h2c_tuser_err(  s_axis_qdma_h2c_tuser_err_wrap ),
        .s_axis_qdma_h2c_tuser_mdata(  s_axis_qdma_h2c_tuser_mdata_wrap ),
        .s_axis_qdma_h2c_tuser_mty(  s_axis_qdma_h2c_tuser_mty_wrap ),
        .s_axis_qdma_h2c_tuser_zero_byte(  s_axis_qdma_h2c_tuser_zero_byte_wrap ),
        .s_axis_qdma_h2c_tready(  s_axis_qdma_h2c_tready_wrap ),

        .m_axis_qdma_c2h_tvalid( m_axis_qdma_c2h_tvalid_wrap ),
        .m_axis_qdma_c2h_tdata( m_axis_qdma_c2h_tdata_wrap ),
        .m_axis_qdma_c2h_tcrc( m_axis_qdma_c2h_tcrc_wrap ),
        .m_axis_qdma_c2h_tlast( m_axis_qdma_c2h_tlast_wrap ),
        .m_axis_qdma_c2h_ctrl_marker( m_axis_qdma_c2h_ctrl_marker_wrap ),
        .m_axis_qdma_c2h_ctrl_port_id( m_axis_qdma_c2h_ctrl_port_id_wrap ),
        .m_axis_qdma_c2h_ctrl_ecc( m_axis_qdma_c2h_ctrl_ecc_wrap ),
        .m_axis_qdma_c2h_ctrl_len( m_axis_qdma_c2h_ctrl_len_wrap ),
        .m_axis_qdma_c2h_ctrl_qid( m_axis_qdma_c2h_ctrl_qid_wrap ),
        .m_axis_qdma_c2h_ctrl_has_cmpt( m_axis_qdma_c2h_ctrl_has_cmpt_wrap ),
        .m_axis_qdma_c2h_mty( m_axis_qdma_c2h_mty_wrap ),
        .m_axis_qdma_c2h_tready( m_axis_qdma_c2h_tready_wrap ),

        .m_axis_qdma_cpl_tvalid( m_axis_qdma_cpl_tvalid_wrap ),
        .m_axis_qdma_cpl_tdata( m_axis_qdma_cpl_tdata_wrap ),
        .m_axis_qdma_cpl_size( m_axis_qdma_cpl_size_wrap ),
        .m_axis_qdma_cpl_dpar( m_axis_qdma_cpl_dpar_wrap ),
        .m_axis_qdma_cpl_ctrl_qid( m_axis_qdma_cpl_ctrl_qid_wrap ),
        .m_axis_qdma_cpl_ctrl_cmpt_type( m_axis_qdma_cpl_ctrl_cmpt_type_wrap ),
        .m_axis_qdma_cpl_ctrl_wait_pld_pkt_id( m_axis_qdma_cpl_ctrl_wait_pld_pkt_id_wrap ),
        .m_axis_qdma_cpl_ctrl_port_id( m_axis_qdma_cpl_ctrl_port_id_wrap ),
        .m_axis_qdma_cpl_ctrl_marker( m_axis_qdma_cpl_ctrl_marker_wrap ),
        .m_axis_qdma_cpl_ctrl_user_trig( m_axis_qdma_cpl_ctrl_user_trig_wrap ),
        .m_axis_qdma_cpl_ctrl_col_idx( m_axis_qdma_cpl_ctrl_col_idx_wrap ),
        .m_axis_qdma_cpl_ctrl_err_idx( m_axis_qdma_cpl_ctrl_err_idx_wrap ),
        .m_axis_qdma_cpl_ctrl_no_wrb_marker( m_axis_qdma_cpl_ctrl_no_wrb_marker_wrap ),
        .m_axis_qdma_cpl_tready( m_axis_qdma_cpl_tready_wrap ),
`endif 
        .mod_rstn( mod_rstn_wrap ),
        .mod_rst_done( mod_rst_done_wrap ),
`ifdef __synthesis__
        .axil_aclk( axil_aclk_wrap ),
  `ifdef __au55n__
        .ref_clk_100mhz( ref_clk_100mhz_wrap ),
  `elsif __au55c__
        .ref_clk_100mhz( ref_clk_100mhz_wrap ),
  `endif
        .axis_aclk( axis_aclk_wrap ) //No comma?
`else
        .axil_aclk(axil_aclk_wrap ),
  `ifdef __au55n__
        .ref_clk_100mhz( ref_clk_100mhz_wrap ),
  `elsif __au55c__
        .ref_clk_100mhz( ref_clk_100mhz_wrap ),
  `endif
        .axis_aclk( axis_aclk_wrap )
`endif 
); 

  wire         axis_qdma_h2c_tvalid;
  wire [511:0] axis_qdma_h2c_tdata;
  wire  [31:0] axis_qdma_h2c_tcrc;
  wire         axis_qdma_h2c_tlast;
  wire  [10:0] axis_qdma_h2c_tuser_qid;
  wire   [2:0] axis_qdma_h2c_tuser_port_id;
  wire         axis_qdma_h2c_tuser_err;
  wire  [31:0] axis_qdma_h2c_tuser_mdata;
  wire   [5:0] axis_qdma_h2c_tuser_mty;
  wire         axis_qdma_h2c_tuser_zero_byte;
  wire         axis_qdma_h2c_tready;

  wire         axis_qdma_c2h_tvalid;
  wire [511:0] axis_qdma_c2h_tdata;
  wire  [31:0] axis_qdma_c2h_tcrc;
  wire         axis_qdma_c2h_tlast;
  wire         axis_qdma_c2h_ctrl_marker;
  wire   [2:0] axis_qdma_c2h_ctrl_port_id;
  wire   [6:0] axis_qdma_c2h_ctrl_ecc;
  wire  [15:0] axis_qdma_c2h_ctrl_len;
  wire  [10:0] axis_qdma_c2h_ctrl_qid;
  wire         axis_qdma_c2h_ctrl_has_cmpt;
  wire   [5:0] axis_qdma_c2h_mty;
  wire         axis_qdma_c2h_tready;

  wire         axis_qdma_cpl_tvalid;
  wire [511:0] axis_qdma_cpl_tdata;
  wire   [1:0] axis_qdma_cpl_size;
  wire  [15:0] axis_qdma_cpl_dpar;
  wire  [10:0] axis_qdma_cpl_ctrl_qid;
  wire   [1:0] axis_qdma_cpl_ctrl_cmpt_type;
  wire  [15:0] axis_qdma_cpl_ctrl_wait_pld_pkt_id;
  wire   [2:0] axis_qdma_cpl_ctrl_port_id;
  wire         axis_qdma_cpl_ctrl_marker;
  wire         axis_qdma_cpl_ctrl_user_trig;
  wire   [2:0] axis_qdma_cpl_ctrl_col_idx;
  wire   [2:0] axis_qdma_cpl_ctrl_err_idx;
  wire         axis_qdma_cpl_ctrl_no_wrb_marker;
  wire         axis_qdma_cpl_tready;

  wire         h2c_byp_out_vld;
  wire [255:0] h2c_byp_out_dsc;
  wire         h2c_byp_out_st_mm;
  wire   [1:0] h2c_byp_out_dsc_sz;
  wire  [10:0] h2c_byp_out_qid;
  wire         h2c_byp_out_error;
  wire   [7:0] h2c_byp_out_func;
  wire  [15:0] h2c_byp_out_cidx;
  wire   [2:0] h2c_byp_out_port_id;
  wire   [3:0] h2c_byp_out_fmt;
  wire         h2c_byp_out_rdy;

  wire         h2c_byp_in_st_vld;
  wire  [63:0] h2c_byp_in_st_addr;
  wire  [15:0] h2c_byp_in_st_len;
  wire         h2c_byp_in_st_eop;
  wire         h2c_byp_in_st_sop;
  wire         h2c_byp_in_st_mrkr_req;
  wire   [2:0] h2c_byp_in_st_port_id;
  wire         h2c_byp_in_st_sdi;
  wire  [10:0] h2c_byp_in_st_qid;
  wire         h2c_byp_in_st_error;
  wire   [7:0] h2c_byp_in_st_func;
  wire  [15:0] h2c_byp_in_st_cidx;
  wire         h2c_byp_in_st_no_dma;
  wire         h2c_byp_in_st_rdy;

  wire         c2h_byp_out_vld;
  wire [255:0] c2h_byp_out_dsc;
  wire         c2h_byp_out_st_mm;
  wire  [10:0] c2h_byp_out_qid;
  wire   [1:0] c2h_byp_out_dsc_sz;
  wire         c2h_byp_out_error;
  wire   [7:0] c2h_byp_out_func;
  wire  [15:0] c2h_byp_out_cidx;
  wire   [2:0] c2h_byp_out_port_id;
  wire   [3:0] c2h_byp_out_fmt;
  wire   [6:0] c2h_byp_out_pfch_tag;
  wire         c2h_byp_out_rdy;

  wire         c2h_byp_in_st_csh_vld;
  wire  [63:0] c2h_byp_in_st_csh_addr;
  wire   [2:0] c2h_byp_in_st_csh_port_id;
  wire  [10:0] c2h_byp_in_st_csh_qid;
  wire         c2h_byp_in_st_csh_error;
  wire   [7:0] c2h_byp_in_st_csh_func;
  wire   [6:0] c2h_byp_in_st_csh_pfch_tag;
  wire         c2h_byp_in_st_csh_rdy;

  wire         axil_aresetn;

  // Reset is clocked by the 125MHz AXI-Lite clock
  generic_reset #(
    .NUM_INPUT_CLK  (1),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn_wrap),
    .mod_rst_done (mod_rst_done_wrap),
    .clk          (axil_aclk_wrap),
    .rstn         (axil_aresetn)
  );
    
`ifdef __synthesis__
  wire         pcie_refclk_gt;
  wire         pcie_refclk;

 IBUFDS_GTE4 pcie_refclk_buf (
    .CEB   (1'b0),
    .I     (pcie_refclk_p_wrap),
    .IB    (pcie_refclk_n_wrap),
    .O     (pcie_refclk_gt),
    .ODIV2 (pcie_refclk)
  );

assign h2c_byp_out_rdy            = 1'b1;
  assign h2c_byp_in_st_vld          = 1'b0;
  assign h2c_byp_in_st_addr         = 0;
  assign h2c_byp_in_st_len          = 0;
  assign h2c_byp_in_st_eop          = 1'b0;
  assign h2c_byp_in_st_sop          = 1'b0;
  assign h2c_byp_in_st_mrkr_req     = 1'b0;
  assign h2c_byp_in_st_port_id      = 0;
  assign h2c_byp_in_st_sdi          = 1'b0;
  assign h2c_byp_in_st_qid          = 0;
  assign h2c_byp_in_st_error        = 1'b0;
  assign h2c_byp_in_st_func         = 0;
  assign h2c_byp_in_st_cidx         = 0;
  assign h2c_byp_in_st_no_dma       = 1'b0;

  assign c2h_byp_out_rdy            = 1'b1;
  assign c2h_byp_in_st_csh_vld      = 1'b0;
  assign c2h_byp_in_st_csh_addr     = 0;
  assign c2h_byp_in_st_csh_port_id  = 0;
  assign c2h_byp_in_st_csh_qid      = 0;
  assign c2h_byp_in_st_csh_error    = 1'b0;
  assign c2h_byp_in_st_csh_func     = 0;
  assign c2h_byp_in_st_csh_pfch_tag = 0;

  qdma_subsystem_qdma_wrapper qdma_wrapper_inst (
    .pcie_rxp                        ( pcie_rxp_wrap ),
    .pcie_rxn                        ( pcie_rxn_wrap ),
    .pcie_txp                        ( pcie_txp_wrap ),
    .pcie_txn                        ( pcie_txn_wrap ),

    .m_axil_awvalid                  ( m_axil_pcie_awvalid_wrap ),
    .m_axil_awaddr                   ( m_axil_pcie_awaddr_wrap ),
    .m_axil_awready                  ( m_axil_pcie_awready_wrap ),
    .m_axil_wvalid                   ( m_axil_pcie_wvalid_wrap ),
    .m_axil_wdata                    ( m_axil_pcie_wdata_wrap ),
    .m_axil_wready                   ( m_axil_pcie_wready_wrap ),
    .m_axil_bvalid                   ( m_axil_pcie_bvalid_wrap ),
    .m_axil_bresp                    ( m_axil_pcie_bresp_wrap ),
    .m_axil_bready                   ( m_axil_pcie_bready_wrap ),
    .m_axil_arvalid                  ( m_axil_pcie_arvalid_wrap ),
    .m_axil_araddr                   ( m_axil_pcie_araddr_wrap ),
    .m_axil_arready                  ( m_axil_pcie_arready_wrap ),
    .m_axil_rvalid                   ( m_axil_pcie_rvalid_wrap ),
    .m_axil_rdata                    ( m_axil_pcie_rdata_wrap ),
    .m_axil_rresp                    ( m_axil_pcie_rresp_wrap ),
    .m_axil_rready                   ( m_axil_pcie_rready_wrap ),

    .m_axis_h2c_tvalid               (axis_qdma_h2c_tvalid),
    .m_axis_h2c_tdata                (axis_qdma_h2c_tdata),
    .m_axis_h2c_tcrc                 (axis_qdma_h2c_tcrc),
    .m_axis_h2c_tlast                (axis_qdma_h2c_tlast),
    .m_axis_h2c_tuser_qid            (axis_qdma_h2c_tuser_qid),
    .m_axis_h2c_tuser_port_id        (axis_qdma_h2c_tuser_port_id),
    .m_axis_h2c_tuser_err            (axis_qdma_h2c_tuser_err),
    .m_axis_h2c_tuser_mdata          (axis_qdma_h2c_tuser_mdata),
    .m_axis_h2c_tuser_mty            (axis_qdma_h2c_tuser_mty),
    .m_axis_h2c_tuser_zero_byte      (axis_qdma_h2c_tuser_zero_byte),
    .m_axis_h2c_tready               (axis_qdma_h2c_tready),

    .s_axis_c2h_tvalid               (axis_qdma_c2h_tvalid),
    .s_axis_c2h_tdata                (axis_qdma_c2h_tdata),
    .s_axis_c2h_tcrc                 (axis_qdma_c2h_tcrc),
    .s_axis_c2h_tlast                (axis_qdma_c2h_tlast),
    .s_axis_c2h_ctrl_marker          (axis_qdma_c2h_ctrl_marker),
    .s_axis_c2h_ctrl_port_id         (axis_qdma_c2h_ctrl_port_id),
    .s_axis_c2h_ctrl_ecc             (axis_qdma_c2h_ctrl_ecc),
    .s_axis_c2h_ctrl_len             (axis_qdma_c2h_ctrl_len),
    .s_axis_c2h_ctrl_qid             (axis_qdma_c2h_ctrl_qid),
    .s_axis_c2h_ctrl_has_cmpt        (axis_qdma_c2h_ctrl_has_cmpt),
    .s_axis_c2h_mty                  (axis_qdma_c2h_mty),
    .s_axis_c2h_tready               (axis_qdma_c2h_tready),

    .s_axis_cpl_tvalid               (axis_qdma_cpl_tvalid),
    .s_axis_cpl_tdata                (axis_qdma_cpl_tdata),
    .s_axis_cpl_size                 (axis_qdma_cpl_size),
    .s_axis_cpl_dpar                 (axis_qdma_cpl_dpar),
    .s_axis_cpl_ctrl_qid             (axis_qdma_cpl_ctrl_qid),
    .s_axis_cpl_ctrl_cmpt_type       (axis_qdma_cpl_ctrl_cmpt_type),
    .s_axis_cpl_ctrl_wait_pld_pkt_id (axis_qdma_cpl_ctrl_wait_pld_pkt_id),
    .s_axis_cpl_ctrl_port_id         (axis_qdma_cpl_ctrl_port_id),
    .s_axis_cpl_ctrl_marker          (axis_qdma_cpl_ctrl_marker),
    .s_axis_cpl_ctrl_user_trig       (axis_qdma_cpl_ctrl_user_trig),
    .s_axis_cpl_ctrl_col_idx         (axis_qdma_cpl_ctrl_col_idx),
    .s_axis_cpl_ctrl_err_idx         (axis_qdma_cpl_ctrl_err_idx),
    .s_axis_cpl_ctrl_no_wrb_marker   (axis_qdma_cpl_ctrl_no_wrb_marker),
    .s_axis_cpl_tready               (axis_qdma_cpl_tready),

    .h2c_byp_out_vld                 (h2c_byp_out_vld),
    .h2c_byp_out_dsc                 (h2c_byp_out_dsc),
    .h2c_byp_out_st_mm               (h2c_byp_out_st_mm),
    .h2c_byp_out_dsc_sz              (h2c_byp_out_dsc_sz),
    .h2c_byp_out_qid                 (h2c_byp_out_qid),
    .h2c_byp_out_error               (h2c_byp_out_error),
    .h2c_byp_out_func                (h2c_byp_out_func),
    .h2c_byp_out_cidx                (h2c_byp_out_cidx),
    .h2c_byp_out_port_id             (h2c_byp_out_port_id),
    .h2c_byp_out_fmt                 (h2c_byp_out_fmt),
    .h2c_byp_out_rdy                 (h2c_byp_out_rdy),

    .h2c_byp_in_st_vld               (h2c_byp_in_st_vld),
    .h2c_byp_in_st_addr              (h2c_byp_in_st_addr),
    .h2c_byp_in_st_len               (h2c_byp_in_st_len),
    .h2c_byp_in_st_eop               (h2c_byp_in_st_eop),
    .h2c_byp_in_st_sop               (h2c_byp_in_st_sop),
    .h2c_byp_in_st_mrkr_req          (h2c_byp_in_st_mrkr_req),
    .h2c_byp_in_st_port_id           (h2c_byp_in_st_port_id),
    .h2c_byp_in_st_sdi               (h2c_byp_in_st_sdi),
    .h2c_byp_in_st_qid               (h2c_byp_in_st_qid),
    .h2c_byp_in_st_error             (h2c_byp_in_st_error),
    .h2c_byp_in_st_func              (h2c_byp_in_st_func),
    .h2c_byp_in_st_cidx              (h2c_byp_in_st_cidx),
    .h2c_byp_in_st_no_dma            (h2c_byp_in_st_no_dma),
    .h2c_byp_in_st_rdy               (h2c_byp_in_st_rdy),

    .c2h_byp_out_vld                 (c2h_byp_out_vld),
    .c2h_byp_out_dsc                 (c2h_byp_out_dsc),
    .c2h_byp_out_st_mm               (c2h_byp_out_st_mm),
    .c2h_byp_out_qid                 (c2h_byp_out_qid),
    .c2h_byp_out_dsc_sz              (c2h_byp_out_dsc_sz),
    .c2h_byp_out_error               (c2h_byp_out_error),
    .c2h_byp_out_func                (c2h_byp_out_func),
    .c2h_byp_out_cidx                (c2h_byp_out_cidx),
    .c2h_byp_out_port_id             (c2h_byp_out_port_id),
    .c2h_byp_out_fmt                 (c2h_byp_out_fmt),
    .c2h_byp_out_pfch_tag            (c2h_byp_out_pfch_tag),
    .c2h_byp_out_rdy                 (c2h_byp_out_rdy),

    .c2h_byp_in_st_csh_vld           (c2h_byp_in_st_csh_vld),
    .c2h_byp_in_st_csh_addr          (c2h_byp_in_st_csh_addr),
    .c2h_byp_in_st_csh_port_id       (c2h_byp_in_st_csh_port_id),
    .c2h_byp_in_st_csh_qid           (c2h_byp_in_st_csh_qid),
    .c2h_byp_in_st_csh_error         (c2h_byp_in_st_csh_error),
    .c2h_byp_in_st_csh_func          (c2h_byp_in_st_csh_func),
    .c2h_byp_in_st_csh_pfch_tag      (c2h_byp_in_st_csh_pfch_tag),
    .c2h_byp_in_st_csh_rdy           (c2h_byp_in_st_csh_rdy),

    .pcie_refclk                     (pcie_refclk),
    .pcie_refclk_gt                  (pcie_refclk_gt),
    .pcie_rstn                       (pcie_rstn_wrap),
    .user_lnk_up                     (user_lnk_up_wrap),
    .phy_ready                       (phy_ready_wrap),

    .soft_reset_n                    (axil_aresetn),
    .axil_aclk                       (axil_aclk_wrap),
    .axis_aclk                       (axis_aclk_wrap),
  `ifdef __au55n__
    .ref_clk_100mhz                  (ref_clk_100mhz_wrap),
  `elsif __au55c__
    .ref_clk_100mhz                  (ref_clk_100mhz_wrap),
  `endif
    .aresetn                         (powerup_rstn_wrap)

  );
`else // !`ifdef __synthesis__
    initial begin
    axil_aclk_wrap = 1'b1; 
    axis_aclk_wrap = 1'b1;

  `ifdef __au55n__
    ref_clk_100mhz_wrap = 1'b1;
  `elsif __au55c__
    ref_clk_100mhz_wrap = 1'b1;
    end

  always #4000ps axil_aclk_wrap = ~axil_aclk_wrap;
  always #2000ps axis_aclk_wrap = ~axis_aclk_wrap;

`ifdef __au55n__
  always #5000ps ref_clk_100mhz_wrap = ~ref_clk_100mhz_wrap;
`elsif __au55c__
  always #5000ps ref_clk_100mhz_wrap = ~ref_clk_100mhz_wrap;
`endif

// TODO: cross verify tReady
  assign axis_qdma_h2c_tvalid                 = s_axis_qdma_h2c_tvalid_wrap;
  assign axis_qdma_h2c_tdata                  = s_axis_qdma_h2c_tdata_wrap;
  assign axis_qdma_h2c_tcrc                   = s_axis_qdma_h2c_tcrc_wrap;
  assign axis_qdma_h2c_tlast                  = s_axis_qdma_h2c_tlast_wrap;
  assign axis_qdma_h2c_tuser_qid              = s_axis_qdma_h2c_tuser_qid_wrap;
  assign axis_qdma_h2c_tuser_port_id          = s_axis_qdma_h2c_tuser_port_id_wrap;
  assign axis_qdma_h2c_tuser_err              = s_axis_qdma_h2c_tuser_err_wrap;
  assign axis_qdma_h2c_tuser_mdata            = s_axis_qdma_h2c_tuser_mdata_wrap;
  assign axis_qdma_h2c_tuser_mty              = s_axis_qdma_h2c_tuser_mty_wrap;
  assign axis_qdma_h2c_tuser_zero_byte        = s_axis_qdma_h2c_tuser_zero_byte_wrap;
  assign s_axis_qdma_h2c_tready_wrap          = axis_qdma_h2c_tready; 

  assign m_axis_qdma_c2h_tvalid_wrap               = axis_qdma_c2h_tvalid;
  assign m_axis_qdma_c2h_tdata_wrap                = axis_qdma_c2h_tdata;
  assign m_axis_qdma_c2h_tcrc_wrap                 = axis_qdma_c2h_tcrc;
  assign m_axis_qdma_c2h_tlast_wrap                = axis_qdma_c2h_tlast;
  assign m_axis_qdma_c2h_ctrl_marker_wrap          = axis_qdma_c2h_ctrl_marker;
  assign m_axis_qdma_c2h_ctrl_port_id_wrap         = axis_qdma_c2h_ctrl_port_id;
  assign m_axis_qdma_c2h_ctrl_ecc_wrap             = axis_qdma_c2h_ctrl_ecc;
  assign m_axis_qdma_c2h_ctrl_len_wrap             = axis_qdma_c2h_ctrl_len;
  assign m_axis_qdma_c2h_ctrl_qid_wrap             = axis_qdma_c2h_ctrl_qid;
  assign m_axis_qdma_c2h_ctrl_has_cmpt_wrap        = axis_qdma_c2h_ctrl_has_cmpt;
  assign m_axis_qdma_c2h_mty_wrap                  = axis_qdma_c2h_mty;
  assign axis_qdma_c2h_tready                      = m_axis_qdma_c2h_tready_wrap;

  assign m_axis_qdma_cpl_tvalid_wrap               = axis_qdma_cpl_tvalid;
  assign m_axis_qdma_cpl_tdata_wrap                = axis_qdma_cpl_tdata;
  assign m_axis_qdma_cpl_size_wrap                 = axis_qdma_cpl_size;
  assign m_axis_qdma_cpl_dpar_wrap                 = axis_qdma_cpl_dpar;
  assign m_axis_qdma_cpl_ctrl_qid_wrap             = axis_qdma_cpl_ctrl_qid;
  assign m_axis_qdma_cpl_ctrl_cmpt_type_wrap       = axis_qdma_cpl_ctrl_cmpt_type;
  assign m_axis_qdma_cpl_ctrl_wait_pld_pkt_id_wrap = axis_qdma_cpl_ctrl_wait_pld_pkt_id;
  assign m_axis_qdma_cpl_ctrl_port_id_wrap         = axis_qdma_cpl_ctrl_port_id;
  assign m_axis_qdma_cpl_ctrl_marker_wrap          = axis_qdma_cpl_ctrl_marker;
  assign m_axis_qdma_cpl_ctrl_user_trig_wrap       = axis_qdma_cpl_ctrl_user_trig;
  assign m_axis_qdma_cpl_ctrl_col_idx_wrap         = axis_qdma_cpl_ctrl_col_idx;
  assign m_axis_qdma_cpl_ctrl_err_idx_wrap         = axis_qdma_cpl_ctrl_err_idx;
  assign m_axis_qdma_cpl_ctrl_no_wrb_marker_wrap   = axis_qdma_cpl_ctrl_no_wrb_marker;
  assign axis_qdma_cpl_tready                      = m_axis_qdma_cpl_tready_wrap;
`endif // if !synthesis

generate if (USE_PHYS_FUNC_W == 0) begin
    // Terminate the AXI-lite interface for QDMA subsystem registers
    axi_lite_slave #(
      .REG_ADDR_W (15),
      .REG_PREFIX (16'h0D0A) // for "QDMA"
    ) qdma_reg_inst (
      .s_axil_awvalid (s_axil_awvalid_wrap ),
      .s_axil_awaddr  (s_axil_awaddr_wrap ),
      .s_axil_awready (s_axil_awready_wrap ),
      .s_axil_wvalid  (s_axil_wvalid_wrap ),
      .s_axil_wdata   (s_axil_wdata_wrap ),
      .s_axil_wready  (s_axil_wready_wrap ),
      .s_axil_bvalid  (s_axil_bvalid_wrap ),
      .s_axil_bresp   (s_axil_bresp_wrap ),
      .s_axil_bready  (s_axil_bready_wrap ),
      .s_axil_arvalid (s_axil_arvalid_wrap ),
      .s_axil_araddr  (s_axil_araddr_wrap ),
      .s_axil_arready (s_axil_arready_wrap ),
      .s_axil_rvalid  (s_axil_rvalid_wrap ),
      .s_axil_rdata   (s_axil_rdata_wrap ),
      .s_axil_rresp   (s_axil_rresp_wrap ),
      .s_axil_rready  (s_axil_rready_wrap ),

      .aresetn        (axil_aresetn),
      .aclk           (axil_aclk_wrap)
    );

    // Terminate H2C and C2H interfaces to QDMA IP
    // Terminate H2C and C2H interfaces to QDMA IP
    assign axis_qdma_h2c_tready               = 1'b1;

    assign axis_qdma_c2h_tvalid               = 1'b0;
    assign axis_qdma_c2h_tdata                = 0;
    assign axis_qdma_c2h_tcrc                 = 0;
    assign axis_qdma_c2h_tlast                = 1'b0;
    assign axis_qdma_c2h_ctrl_marker          = 1'b0;
    assign axis_qdma_c2h_ctrl_port_id         = 0;
    assign axis_qdma_c2h_ctrl_ecc             = 0;
    assign axis_qdma_c2h_ctrl_len             = 0;
    assign axis_qdma_c2h_ctrl_qid             = 0;
    assign axis_qdma_c2h_ctrl_has_cmpt        = 1'b0;
    assign axis_qdma_c2h_mty                  = 0;

    assign axis_qdma_cpl_tvalid               = 1'b0;
    assign axis_qdma_cpl_tdata                = 0;
    assign axis_qdma_cpl_size                 = 0;
    assign axis_qdma_cpl_dpar                 = 0;
    assign axis_qdma_cpl_ctrl_qid             = 0;
    assign axis_qdma_cpl_ctrl_cmpt_type       = 0;
    assign axis_qdma_cpl_ctrl_wait_pld_pkt_id = 0;
    assign axis_qdma_cpl_ctrl_port_id         = 0;
    assign axis_qdma_cpl_ctrl_marker          = 1'b0;
    assign axis_qdma_cpl_ctrl_user_trig       = 1'b0;
    assign axis_qdma_cpl_ctrl_col_idx         = 0;
    assign axis_qdma_cpl_ctrl_err_idx         = 0;
    assign axis_qdma_cpl_ctrl_no_wrb_marker   = 1'b0;

    // Terminate H2C and C2H interfaces of the shell
    assign m_axis_h2c_tvalid_wrap     = 1'b0;
    assign m_axis_h2c_tdata_wrap      = 0;
    assign m_axis_h2c_tkeep_wrap      = 0;
    assign m_axis_h2c_tlast_wrap      = 1'b0;
    assign m_axis_h2c_tuser_size_wrap = 0;
    assign m_axis_h2c_tuser_src_wrap  = 0;
    assign m_axis_h2c_tuser_dst_wrap  = 0;
    assign m_axis_h2c_tready_wrap = 0;

    assign s_axis_c2h_tready_wrap     = 1'b1;
    end
    else begin
    wire                         axil_awvalid;
    wire                  [31:0] axil_awaddr;
    wire                         axil_awready;
    wire                         axil_wvalid;
    wire                  [31:0] axil_wdata;
    wire                         axil_wready;
    wire                         axil_bvalid;
    wire                   [1:0] axil_bresp;
    wire                         axil_bready;
    wire                         axil_arvalid;
    wire                  [31:0] axil_araddr;
    wire                         axil_arready;
    wire                         axil_rvalid;
    wire                  [31:0] axil_rdata;
    wire                   [1:0] axil_rresp;
    wire                         axil_rready;

    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_awvalid;
    wire  [32*NUM_PHYS_FUNC_W-1:0] axil_func_awaddr;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_awready;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_wvalid;
    wire  [32*NUM_PHYS_FUNC_W-1:0] axil_func_wdata;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_wready;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_bvalid;
    wire   [2*NUM_PHYS_FUNC_W-1:0] axil_func_bresp;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_bready;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_arvalid;
    wire  [32*NUM_PHYS_FUNC_W-1:0] axil_func_araddr;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_arready;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_rvalid;
    wire  [32*NUM_PHYS_FUNC_W-1:0] axil_func_rdata;
    wire   [2*NUM_PHYS_FUNC_W-1:0] axil_func_rresp;
    wire   [1*NUM_PHYS_FUNC_W-1:0] axil_func_rready;

    wire     [NUM_PHYS_FUNC_W-1:0] axis_h2c_tvalid;
    wire [512*NUM_PHYS_FUNC_W-1:0] axis_h2c_tdata;
    wire     [NUM_PHYS_FUNC_W-1:0] axis_h2c_tlast;
    wire  [16*NUM_PHYS_FUNC_W-1:0] axis_h2c_tuser_size;
    wire  [11*NUM_PHYS_FUNC_W-1:0] axis_h2c_tuser_qid;
    wire     [NUM_PHYS_FUNC_W-1:0] axis_h2c_tready;

    wire                         h2c_status_valid;
    wire                  [15:0] h2c_status_bytes;
    wire                   [1:0] h2c_status_func_id;

    wire     [NUM_PHYS_FUNC_W-1:0] axis_c2h_tvalid;
    wire [512*NUM_PHYS_FUNC_W-1:0] axis_c2h_tdata;
    wire     [NUM_PHYS_FUNC_W-1:0] axis_c2h_tlast;
    wire  [16*NUM_PHYS_FUNC_W-1:0] axis_c2h_tuser_size;
    wire  [11*NUM_PHYS_FUNC_W-1:0] axis_c2h_tuser_qid;
    wire     [NUM_PHYS_FUNC_W-1:0] axis_c2h_tready;

    wire                         c2h_status_valid;
    wire                  [15:0] c2h_status_bytes;
    wire                   [1:0] c2h_status_func_id;


    end
    endgenerate
endmodule