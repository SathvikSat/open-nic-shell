// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************
`timescale 1ns/1ps
module xxv_ethernet #(
    parameter int XXV_ID = 0, //How many instances to use?
    parameter int MIN_PKT_LEN = 64, //Use in AXI_tdata?
    parameter int MAX_PKT_LEN = 1518
)(
 // Config axi -lite slave signals:
 //YES
 //master for axiLite slave will be ? 
 //1 axiLite set for each CMAC or XXV instance
 //BAR2 is mapped to systemConfig a addr range of BAR2 is used for CMACi same can 
 //be used for XXV

  input          s_axil_awvalid,
  input   [31:0] s_axil_awaddr,
  output         s_axil_awready,
  input          s_axil_wvalid,
  input   [31:0] s_axil_wdata,
  output         s_axil_wready,
  output         s_axil_bvalid,
  output   [1:0] s_axil_bresp,
  input          s_axil_bready,
  input          s_axil_arvalid,
  input   [31:0] s_axil_araddr,
  output         s_axil_arready,
  output         s_axil_rvalid,
  output  [31:0] s_axil_rdata,
  output   [1:0] s_axil_rresp,
  input          s_axil_rready,

  input          s_axis_xxv_tx_tvalid,
  input  [63:0] s_axis_xxv_tx_tdata,
  input   [7:0] s_axis_xxv_tx_tkeep,
  input          s_axis_xxv_tx_tlast,
  input          s_axis_xxv_tx_tuser_err,
  output         s_axis_xxv_tx_tready,

  output         m_axis_xxv_rx_tvalid,
  output [63:0] m_axis_xxv_rx_tdata,
  output  [7:0] m_axis_xxv_rx_tkeep,
  output         m_axis_xxv_rx_tlast,
  output         m_axis_xxv_rx_tuser_err,

  `ifdef __synthesis__
  //TODO:confirm this
  input    [0:0] gt_rxp,
  input    [0:0] gt_rxn,
  output   [0:0] gt_txp,
  output   [0:0] gt_txn,
  input          gt_refclk_p,
  input          gt_refclk_n,
  output         xxv_clk,
`else
    /** TODO: simulation signals */
`endif
  input          mod_rstn,
  output         mod_rst_done,
  input          axil_aclk    
);

    wire axil_aresetn;
    wire xxv_rstn;

  wire         axil_xxv_awvalid;
  wire  [31:0] axil_xxv_awaddr;
  wire         axil_xxv_awready;
  wire  [31:0] axil_xxv_wdata;
  wire         axil_xxv_wvalid;
  wire         axil_xxv_wready;
  wire   [1:0] axil_xxv_bresp;
  wire         axil_xxv_bvalid;
  wire         axil_xxv_bready;
  wire  [31:0] axil_xxv_araddr;
  wire         axil_xxv_arvalid;
  wire         axil_xxv_arready;
  wire  [31:0] axil_xxv_rdata;
  wire   [1:0] axil_xxv_rresp;
  wire         axil_xxv_rvalid;
  wire         axil_xxv_rready;

  wire         axil_qsfp_awvalid;
  wire  [31:0] axil_qsfp_awaddr;
  wire         axil_qsfp_awready;
  wire  [31:0] axil_qsfp_wdata;
  wire         axil_qsfp_wvalid;
  wire         axil_qsfp_wready;
  wire   [1:0] axil_qsfp_bresp;
  wire         axil_qsfp_bvalid;
  wire         axil_qsfp_bready;
  wire  [31:0] axil_qsfp_araddr;
  wire         axil_qsfp_arvalid;
  wire         axil_qsfp_arready;
  wire  [31:0] axil_qsfp_rdata;
  wire   [1:0] axil_qsfp_rresp;
  wire         axil_qsfp_rvalid;
  wire         axil_qsfp_rready;

    // Reset is clocked by the 125MHz AXI-Lite clock
    generic_reset #(
      .NUM_INPUT_CLK  (2),
      .RESET_DURATION (100)
    )
    reset_inst (
        .mod_rstn     (mod_rstn),
        .mod_rst_done (mod_rst_done),
        .clk          ({ xxv_clk, axil_aclk}),  
        .rstn         ({xxv_rstn, axil_aresetn})
    );

xxv_subsystem_address_map address_map_inst(

    //Input information
    .s_axil_awvalid ( s_axil_awvalid ),
    .s_axil_awaddr ( s_axil_awaddr ),
    .s_axil_awready ( s_axil_awready ),
    .s_axil_wvalid ( s_axil_wvalid ),
    .s_axil_wdata ( s_axil_wdata ),
    .s_axil_wready ( s_axil_wready ),
    .s_axil_bvalid ( s_axil_bvalid ),
    .s_axil_bresp ( s_axil_bresp ),
    .s_axil_bready ( s_axil_bready ),
    .s_axil_arvalid ( s_axil_arvalid ),
    .s_axil_araddr ( s_axil_araddr ),
    .s_axil_arready ( s_axil_arready ),
    .s_axil_rvalid ( s_axil_rvalid ),
    .s_axil_rdata ( s_axil_rdata ),
    .s_axil_rresp ( s_axil_rresp ),
    .s_axil_rready ( s_axil_rready ),

    //Output information from axi lite
    .m_axil_xxv_awvalid ( axil_xxv_awvalid ),
    .m_axil_xxv_awaddr ( axil_xxv_awaddr ),
    .m_axil_xxv_awready ( axil_xxv_awready ),
    .m_axil_xxv_wvalid ( axil_xxv_wvalid ),
    .m_axil_xxv_wdata ( axil_xxv_wdata ),
    .m_axil_xxv_wready ( axil_xxv_wready ),
    .m_axil_xxv_bvalid ( axil_xxv_bvalid ),
    .m_axil_xxv_bresp ( axil_xxv_bresp ),
    .m_axil_xxv_bready ( axil_xxv_bready ),
    .m_axil_xxv_arvalid ( axil_xxv_arvalid ),
    .m_axil_xxv_araddr ( axil_xxv_araddr ),
    .m_axil_xxv_arready ( axil_xxv_arready ),
    .m_axil_xxv_rvalid ( axil_xxv_rvalid ),
    .m_axil_xxv_rdata ( axil_xxv_rdata ),
    .m_axil_xxv_rresp ( axil_xxv_rresp ),
    .m_axil_xxv_rready ( axil_xxv_rready ),

    //QSFP not handled
    .m_axil_qsfp_awvalid (axil_qsfp_awvalid),
    .m_axil_qsfp_awaddr  (axil_qsfp_awaddr),
    .m_axil_qsfp_awready (axil_qsfp_awready),
    .m_axil_qsfp_wvalid  (axil_qsfp_wvalid),
    .m_axil_qsfp_wdata   (axil_qsfp_wdata),
    .m_axil_qsfp_wready  (axil_qsfp_wready),
    .m_axil_qsfp_bvalid  (axil_qsfp_bvalid),
    .m_axil_qsfp_bresp   (axil_qsfp_bresp),
    .m_axil_qsfp_bready  (axil_qsfp_bready),
    .m_axil_qsfp_arvalid (axil_qsfp_arvalid),
    .m_axil_qsfp_araddr  (axil_qsfp_araddr),
    .m_axil_qsfp_arready (axil_qsfp_arready),
    .m_axil_qsfp_rvalid  (axil_qsfp_rvalid),
    .m_axil_qsfp_rdata   (axil_qsfp_rdata),
    .m_axil_qsfp_rresp   (axil_qsfp_rresp),
    .m_axil_qsfp_rready  (axil_qsfp_rready),

    .aclk (axil_aclk),
    .aresetn (axil_aresetn)
);

// [TODO] replace this with an actual register access block
  axi_lite_slave #(
    //ASK: 12 bit wide?
    .REG_ADDR_W (12),
    //ASK:
    .REG_PREFIX (16'hC028 + (XXV_ID << 8)) // for "XXV0/1 QSFP28"
  ) qsfp_reg_inst (
    .s_axil_awvalid (axil_qsfp_awvalid),
    .s_axil_awaddr  (axil_qsfp_awaddr),
    .s_axil_awready (axil_qsfp_awready),
    .s_axil_wvalid  (axil_qsfp_wvalid),
    .s_axil_wdata   (axil_qsfp_wdata),
    .s_axil_wready  (axil_qsfp_wready),
    .s_axil_bvalid  (axil_qsfp_bvalid),
    .s_axil_bresp   (axil_qsfp_bresp),
    .s_axil_bready  (axil_qsfp_bready),
    .s_axil_arvalid (axil_qsfp_arvalid),
    .s_axil_araddr  (axil_qsfp_araddr),
    .s_axil_arready (axil_qsfp_arready),
    .s_axil_rvalid  (axil_qsfp_rvalid),
    .s_axil_rdata   (axil_qsfp_rdata),
    .s_axil_rresp   (axil_qsfp_rresp),
    .s_axil_rready  (axil_qsfp_rready),

    .aresetn        (axil_aresetn),
    .aclk           (axil_aclk)
  );

//axi_stream_register_slice() //tx
//axi_stream_register_slice() //rx



`ifdef __synthesis__
xxv_subsystem_xxv_wrapper #(
    .XXV_ID (XXV_ID)
)
(
    .gt_rxp              (gt_rxp),
    .gt_rxn              (gt_rxn),
    .gt_txp              (gt_txp),
    .gt_txn              (gt_txn),

    .s_axil_awaddr       (axil_xxv_awaddr),
    .s_axil_awvalid      (axil_xxv_awvalid),
    .s_axil_awready      (axil_xxv_awready),
    .s_axil_wdata        (axil_xxv_wdata),
    .s_axil_wvalid       (axil_xxv_wvalid),
    .s_axil_wready       (axil_xxv_wready),
    .s_axil_bresp        (axil_xxv_bresp),
    .s_axil_bvalid       (axil_xxv_bvalid),
    .s_axil_bready       (axil_xxv_bready),
    .s_axil_araddr       (axil_xxv_araddr),
    .s_axil_arvalid      (axil_xxv_arvalid),
    .s_axil_arready      (axil_xxv_arready),
    .s_axil_rdata        (axil_xxv_rdata),
    .s_axil_rresp        (axil_xxv_rresp),
    .s_axil_rvalid       (axil_xxv_rvalid),
    .s_axil_rready       (axil_xxv_rready),

    //TODO: actual TX and RX data to be handled 
    
    .gt_refclk_p         (gt_refclk_p),
    .gt_refclk_n         (gt_refclk_n),
    .xxv_clk             (xxv_clk),
    .xxv_sys_reset      (~axil_aresetn),

    .axil_aclk           (axil_aclk)
);
`endif
//simulation case not handled.
endmodule: xxv_ethernet