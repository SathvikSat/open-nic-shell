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
module xxv_subsystem #(
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


  //actual output of the xxv_subsystem, actual output is fed to box322Mhz
  //TODO: tready not specified here for final output of xxv_subsystem to box322
  output         m_axis_xxv_fifo_box322_tvalid, 
  output [511:0] m_axis_xxv_fifo_box322_tdata,
  output [63:0]  m_axis_xxv_fifo_box322_tkeep,
  output         m_axis_xxv_fifo_box322_tlast,
  output         m_axis_xxv_fifo_box322_tuser_err,

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

  wire         axis_xxv_tx_tvalid;
  wire [63:0]  axis_xxv_tx_tdata;
  wire  [7:0]  axis_xxv_tx_tkeep;
  wire         axis_xxv_tx_tlast;
  wire         axis_xxv_tx_tuser_err;
  wire         axis_xxv_tx_tready;


//capture the XXV_IP output into below wire
  wire         axis_xxv_rx_tvalid;
  wire [63:0]  axis_xxv_rx_tdata;
  wire  [7:0]  axis_xxv_rx_tkeep;
  wire         axis_xxv_rx_tlast;
  wire         axis_xxv_rx_tuser_err;

  //register slice btw XXV IP and data_wdith upsizer
  wire         m_axis_xxv_rx_tvalid,
  wire [63:0]  m_axis_xxv_rx_tdata,
  wire  [7:0]  m_axis_xxv_rx_tkeep,
  wire         m_axis_xxv_rx_tlast,
  wire         m_axis_xxv_rx_tuser_err,

  //Output of the width converter 512 bits upsized
  wire         m_axis_xxv_width_up_tvalid;
  wire [511:0] m_axis_xxv_width_up_tdata;
  wire  [63:0] m_axis_xxv_width_up_tkeep;
  wire         m_axis_xxv_width_up_tlast;
  wire         m_axis_xxv_width_up_tuser_err;

  //TODO: cross check how output of fifo occurs
  wire         m_axis_xxv_fifo_rx_tvalid;
  wire [511:0] m_axis_xxv_fifo_rx_tdata;
  wire  [63:0] m_axis_xxv_fifo_rx_tkeep;
  wire         m_axis_xxv_fifo_rx_tlast;
  wire         m_axis_xxv_fifo_rx_tuser_err;


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


//1st instance of register slice in Rx, getting data from XXV_Ethernet_IP
axi_stream_register_slice #(
  .TDATA_W (64),
  //TODO: cross check all signal widths everywhere
  .TUSER_W (1),
  .MODE    ("full")
) rx_slice_inst (
  .s_axis_tvalid (axis_xxv_rx_tvalid),
  .s_axis_tdata  (axis_xxv_rx_tdata),
  .s_axis_tkeep  (axis_xxv_rx_tkeep),
  .s_axis_tlast  (axis_xxv_rx_tlast),
  //.s_axis_tid    (0),
  //.s_axis_tdest  (0),
  .s_axis_tuser  (axis_xxv_rx_tuser_err),
  //.s_axis_tready (),

  //TODO: use this as input to axi width converter instance
  //TODO: please verify tvalid and tready direction wrt master and slave
  .m_axis_tvalid (m_axis_xxv_rx_tvalid),
  .m_axis_tdata  (m_axis_xxv_rx_tdata),
  .m_axis_tkeep  (m_axis_xxv_rx_tkeep),
  .m_axis_tlast  (m_axis_xxv_rx_tlast),
  //Unused as of now
  //.m_axis_tid    (),
  //.m_axis_tdest  (),
  .m_axis_tuser  (m_axis_xxv_rx_tuser_err),
  .m_axis_tready (1'b1),
  //TODO: check the freq here xxv_clk will be 161.xx?
  .aclk          (xxv_clk),
  .aresetn       (xxv_rstn)
);


//2nd instance of axi_register slice in rx direction between FIFO out and Box322 In
axi_stream_register_slice #(
  .TDATA_W(512),
  .TUSER_W(48),
  .MODE("full")
) rx_slice_inst_fifo_322(

//use the output of fifo as input
  .s_axis_tvalid (m_axis_xxv_fifo_rx_tvalid),
  .s_axis_tdata  (m_axis_xxv_fifo_rx_tdata),
  .s_axis_tkeep  (m_axis_xxv_fifo_rx_tkeep),
  .s_axis_tlast  (m_axis_xxv_fifo_rx_tlast),

//TODO: for register slice Tuser specififed as parameter?? .TUSER_W(48) ?
//m_axis_xxv_fifo_tuser_err

//capture the register slice output and feed it to box322Mhz similar to CMAC_subsystem
.m_axis_tvalid(m_axis_xxv_fifo_box322_tvalid),
.m_axis_tdata(m_axis_xxv_fifo_box322_tdata),
.m_axis_tkeep(m_axis_xxv_fifo_box322_tkeep),
.m_axis_tlast(m_axis_xxv_fifo_box322_tlast),
.m_axis_tuser(m_axis_xxv_fifo_box322_tuser_err),
//TODO: cross check no tready?
//.m_axis_tready(),


//TODO: clock of 322Mhz? as fifo output should be 322Mhz rate..
.aclk(),
.aresetn()
);



axis_dwidth_converter_0 #(
  //TODO: need to specify parameters?
) axis_dwidth_up_converter_inst (
  //Reference for signals taken from block design dummy configuration
  
  .s_axis_tvalid(m_axis_xxv_rx_tvalid),
  //xxv sends continously, doesnt wait for slaves tready
  //.s_axis_tready(),  
  .s_axis_tdata(m_axis_xxv_rx_tdata),
  .s_axis_tkeep(m_axis_xxv_rx_tkeep),
  .s_axis_tlast(m_axis_xxv_rx_tlast),
  .s_axis_tuser(m_axis_xxv_rx_tuser_err),  
  
  .aclk(),
  .aresetn(),
  .aclken(),

  //define wire types to capture the width converter ouput and feed it to a FIFO 
  .m_axis_tvalid( m_axis_xxv_width_up_tvalid ),
  .m_axis_tdata( m_axis_xxv_width_up_tdata ),
  .m_axis_tkeep( m_axis_xxv_width_up_tkeep ),
  .m_axis_tlast( m_axis_xxv_width_up_tlast ),
  .m_axis_tuser( m_axis_xxv_width_up_tuser_err )  
  
);

axis_data_fifo_0 #(

  //TODO: check the configs in tcl file
) axis_data_fifo_inst(
  .s_axis_tdata( m_axis_xxv_width_up_tdata ),
  .s_axis_tkeep( m_axis_xxv_width_up_tkeep ),
  //tready for FIFO what if buffer gets full?
  //.s_axis_tready(),
  .s_axis_tuser( m_axis_xxv_width_up_tuser_err ),
  .s_axis_tvalid( m_axis_xxv_width_up_tvalid ),
  .s_axis_tlast( m_axis_xxv_width_up_tlast ),

  .s_axis_aresetn(),
  .s_axis_aclk(),
  .m_axis_aclk(),

  //Capture the output of fifo using wire and feed it to register slice or Box322Mhz for now
  .m_axis_tdata(m_axis_xxv_fifo_tdata),
  .m_axis_tkeep(m_axis_xxv_fifo_tkeep),
  .m_axis_tlast(m_axis_xxv_fifo_tlast),
  //TODO: check if t_ready will be required?
  //.m_axis_tready(),
  .m_axis_tuser(m_axis_xxv_fifo_tuser_err),
  .m_axis_tvalid(m_axis_xxv_fifo_tvalid)

  );


//Tx direction 
//TODO: axi register slice -> AXI packet fifo -> AXI4 stream Downconverter -> AXI Register Slice -> XXV Ethernet 


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

    //Rx data coming out of XXV_IP towards width converter/register slice 
    //TODO: verify these names ".m_axis_rx_tvalid" 
    .m_axis_rx_tvalid(axis_xxv_rx_tvalid),
    .m_axis_rx_tdata(axis_xxv_rx_tdata),
    .m_axis_rx_tkeep(axis_xxv_rx_tkeep),
    .m_axis_rx_tlast(axis_xxv_rx_tlast),
    //TODO: check handling of T_user from IP doc and here
    .m_axis_rx_tuser_err(),
    //no tready as XXV do not buffer
    

    // TODO: Tx pending


    .gt_refclk_p         (gt_refclk_p),
    .gt_refclk_n         (gt_refclk_n),
    .xxv_clk             (xxv_clk),
    .xxv_sys_reset      (~axil_aresetn),

    .axil_aclk           (axil_aclk)
);
`endif
//simulation case not handled.
endmodule: xxv_subsystem