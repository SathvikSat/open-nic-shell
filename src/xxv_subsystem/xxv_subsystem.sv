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
    parameter int XXV_ID = 0, 
    parameter int MIN_PKT_LEN = 64, 
    parameter int MAX_PKT_LEN = 1518,
    //TODO: pass this PKT_CAP parameter
    parameter int PKT_CAP = 1.5
)(
 
 /** NOTE: 1 axiLite set for each CMAC or XXV instance */

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

  //This might change once tx direction is handled
  //input          s_axis_xxv_tx_tvalid,
  //input  [63:0]  s_axis_xxv_tx_tdata,
  //input   [7:0]  s_axis_xxv_tx_tkeep,
  //input          s_axis_xxv_tx_tlast,
  //input          s_axis_xxv_tx_tuser_err,
  //output         s_axis_xxv_tx_tready,

  //Input to xxv_subsystem from Tx side post box_322Mhz
  input          s_axis_xxv_box322_fifo_tvalid,
  input  [511:0] s_axis_xxv_box322_fifo_tdata,
  input   [63:0] s_axis_xxv_box322_fifo_tkeep,
  input          s_axis_xxv_box322_fifo_tlast,
  input          s_axis_xxv_box322_fifo_tuser_err,
  input  [15:0]  s_axis_xxv_box322_fifo_tuser_dst;
  output         s_axis_xxv_box322_fifo_tready,


  /** actual output of the xxv_subsystem, actual output is fed to box322Mhz read from register slice instance 02 in XXV sub-system */
  //TODO: note switch with 4 instances is not handled
  output         m_axis_xxv_fifo_box322_tvalid, 
  output [511:0] m_axis_xxv_fifo_box322_tdata,
  output [63:0]  m_axis_xxv_fifo_box322_tkeep,
  output         m_axis_xxv_fifo_box322_tlast,
  output         m_axis_xxv_fifo_box322_tuser_err,

  //output []
  

  `ifdef __synthesis__
  /** for 4 instances of XXV vector size will change later */
  input    [0:0] gt_rxp,
  input    [0:0] gt_rxn,
  output   [0:0] gt_txp,
  output   [0:0] gt_txn,
  input          gt_refclk_p,
  input          gt_refclk_n,

  output    xxv_clk,
`else
    /** TODO: simulation signals */
`endif
  input          mod_rstn,
  output         mod_rst_done,
  input          axil_aclk,
  //TODO: verify this, src for ref_clk_100mhz      
  input          ref_clk_100mhz
);

wire         bad_dst;
wire         dropping;
reg          pkt_started;
reg          dropping_more;

/** For XXV Rx side buffering */
localparam XXV_FIFO_RX_ADDR_W = $clog2(int'($ceil(real'( MAX_PKT_LEN * 8* 3) / 512 * PKT_CAP)));
localparam XXV_FIFO_RX_DEPTH  = 1 << XXV_FIFO_ADDR_W;

wire         drop;
wire         drop_busy;


/** For Rx output signals rcvd from Width Up converter */
assign drop = (m_axis_xxv_width_up_tvalid && m_axis_xxv_width_up_tlast && m_axis_xxv_width_up_tuser_err );
              /** No ready minotored here, always set to 1, ref open-NIC-shell doc */
              /** || (axis_buf_tvalid && ~axis_buf_tready); */

/** For XXV Rx side buffering with drop feature */
 axi_stream_packet_buffer #(
    .CLOCKING_MODE   ("independent_clock"),
    //TODO: creteria for CDC stages?
    .CDC_SYNC_STAGES (2),
    //TODO: verify data width in rx for all locations
    .TDATA_W         (512),
    .MIN_PKT_LEN     (MIN_PKT_LEN),
    .MAX_PKT_LEN     (MAX_PKT_LEN),
    .PKT_CAP         (PKT_CAP)
 ) xxv_pkt_buf_rx_fifo_with_drop_inst (
    .s_axis_tvalid     (m_axis_xxv_width_up_tvalid),
    .s_axis_tdata      (m_axis_xxv_width_up_tdata),
    .s_axis_tkeep      (m_axis_xxv_width_up_tkeep),
    .s_axis_tlast      (m_axis_xxv_width_up_tlast),
    .s_axis_tid        (0),
    .s_axis_tdest      (0),
    //TODO: m_axis_xxv_width_up_tuser_err
    .s_axis_tuser      (0),
    //TODO: tready not needed here?
    //.s_axis_tready     (axis_buf_tready),

  //In rx it is good to have drop feature?
  .drop(drop),

  /** Output */
  .drop_busy (drop_busy),

  .m_axis_tvalid     (m_axis_xxv_fifo_rx_tvalid),
  .m_axis_tdata      (m_axis_xxv_fifo_rx_tdata),
  .m_axis_tkeep      (m_axis_xxv_fifo_rx_tkeep),
  .m_axis_tlast      (m_axis_xxv_fifo_rx_tlast),
  .m_axis_tid        (),
  .m_axis_tdest      (),
  //TODO: verify user err signal usage
  .m_axis_tuser      (m_axis_xxv_fifo_rx_tuser_err),
  //TODO: verify user_size output signal for side band information : MAC addr provider?
  .m_axis_tuser_size (m_axis_rx_tuser_size),
  /** Ready always set high in Rx */
  //.m_axis_tready     (m_axis_rx_tready),

  
 //todo: Verify usage of right clk 
 .s_aclk            (xxv_clk),
 .s_aresetn         (xxv_rstn),
 //TODO: No need of async clk here?
 .m_aclk            ( xxv_clk /**a xis_aclk */)

);

//TODO: need to assign actual value to axis_xxv_box322_fifo_tuser_dst
assign bad_dst = ((axis_xxv_box322_fifo_tuser_dst & (16'h1 << (XXV_ID + 6))) == 0); 
assign dropping = (~pkt_started && axis_xxv_box322_fifo_tvalid && axis_xxv_box322_fifo_tready && bad_dst) || dropping_more;


/** Perhaps not needed */
 always @(posedge axis_aclk) begin
    if (~axil_aresetn) begin
      pkt_started   <= 1'b0;
      dropping_more <= 1'b0;
    end
    else if (~pkt_started && axis_tx_tvalid && axis_tx_tready) begin
      if (axis_tx_tlast) begin
        pkt_started   <= 1'b0;
        dropping_more <= 1'b0;
      end
      else begin
        pkt_started   <= 1'b1;
        dropping_more <= bad_dst;
      end
    end
    else if (axis_tx_tvalid && axis_tx_tlast && axis_tx_tready) begin
      pkt_started   <= 1'b0;
      dropping_more <= 1'b0;
    end
  end


/** For XXV Tx side buffering/FIFO after down conversion of transfers */
axi_stream_packet_fifo #(
    .CDC_SYNC_STAGES  (2),
    .CLOCKING_MODE    ("independent_clock"),
    .ECC_MODE         ("no_ecc"),
    .FIFO_DEPTH       (XXV_FIFO_DEPTH),
    .FIFO_MEMORY_TYPE ("auto"),
    .RELATED_CLOCKS   (0),
    //TODO: verify data_widths
    .TDATA_WIDTH      (64)
  ) tx_cdc_fifo_inst (

    .s_axis_tvalid      (axis_xxv_box322_fifo_tvalid && ~dropping),
    .s_axis_tdata       (axis_xxv_box322_fifo_tdata),
    .s_axis_tkeep       (axis_xxv_box322_fifo_tkeep),
    .s_axis_tstrb       ({64{1'b1}}),
    .s_axis_tlast       (axis_xxv_box322_fifo_tlast),
    .s_axis_tuser       (0),
    .s_axis_tid         (0),
    .s_axis_tdest       (0),
    .s_axis_tready      (axis_xxv_box322_fifo_tready),

    .m_axis_tvalid      (),
    .m_axis_tdata       (),
    .m_axis_tkeep       (),
    .m_axis_tstrb       (),
    .m_axis_tlast       (),
    .m_axis_tuser       (),
    .m_axis_tid         (),
    .m_axis_tdest       (),
    .m_axis_tready      (),

    .almost_empty_axis  (),
    .prog_empty_axis    (),
    .almost_full_axis   (),
    .prog_full_axis     (),
    .wr_data_count_axis (),
    .rd_data_count_axis (),

    .injectsbiterr_axis (),
    .injectdbiterr_axis (),
    .sbiterr_axis       (),
    .dbiterr_axis       (),

    .s_aclk             (),
    .m_aclk             (),
    .s_aresetn          ()

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
  wire        fifoaxil_qsfp_wready;
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

  //Output of register slice in Tx btw Box322 and FIFO captured here
  wire axis_xxv_box322_fifo_tvalid,
  wire axis_xxv_box322_fifo_tdata,
  wire axis_xxv_box322_fifo_tkeep,
  wire axis_xxv_box322_fifo_tlast,
  wire axis_xxv_box322_fifo_tuser_dst,
  wire axis_xxv_box322_fifo_tuser_err,
  wire axis_xxv_box322_fifo_tready
  

//Input to the .... TODO
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

  wire         s_axis_xxv_width_down_tvalid;
  wire [63:0]  s_axis_xxv_width_down_tdata;
  wire  [7:0]  s_axis_xxv_width_down_tkeep;
  wire         s_axis_xxv_width_down_tlast;
  wire         s_axis_xxv_width_down_tuser_err;
  //TODO: in tx for width conversion, t_ready needs to be handled everywhere? and valid doesn't matter as per openNIC doc..?

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

//1st instance of axi_stream_register_slice btw 322 and FIFO //tx
  input          ,
  input  [511:0] ,
  input   [63:0] ,
  input          ,
  input          ,
  output         ,
axi_stream_register_slice #(
  .TDATA_W (512),
  //TODO: cross check all signal widths everywhere
  //TODO: address Tuser_W
  .TUSER_W (1),
  .MODE    ("full")
) tx_slice_322_fifo_inst (
  .s_axis_tvalid (s_axis_xxv_box322_fifo_tvalid),
  .s_axis_tdata  (s_axis_xxv_box322_fifo_tdata),
  .s_axis_tkeep  (s_axis_xxv_box322_fifo_tkeep),
  .s_axis_tlast  (s_axis_xxv_box322_fifo_tlast),
  //.s_axis_tid    (0),
  .s_axis_tdest  (s_axis_xxv_box322_fifo_tuser_dst),
  //TODO: verify tuser
  .s_axis_tuser  (s_axis_xxv_box322_fifo_tuser_err),
  .s_axis_tready (s_axis_xxv_box322_fifo_tready)


  //TODO: use this as input to axi width converter instance
  //TODO: please verify tvalid and tready direction wrt master and slave
  .m_axis_tvalid (axis_xxv_box322_fifo_tvalid),
  .m_axis_tdata  (axis_xxv_box322_fifo_tdata),
  .m_axis_tkeep  (axis_xxv_box322_fifo_tkeep),
  .m_axis_tlast  (axis_xxv_box322_fifo_tlast),
  //Unused as of now
  //.m_axis_tid    (),
  //.m_axis_tdest  (),
  .m_axis_tuser  (axis_xxv_box322_fifo_tuser_err),
  .m_axis_tready (axis_xxv_box322_fifo_tready),
  //TODO: check the freq here xxv_clk will be 161.xx?
  .aclk          (),
  .aresetn       ()
);

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
  .m_axis_tdest  (axis_xxv_box322_fifo_tuser_dst),
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
//m_axis_xxv_fifo_rx_tuser_err
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
  .m_axis_tdata(  m_axis_xxv_width_up_tdata ),
  .m_axis_tkeep(  m_axis_xxv_width_up_tkeep ),
  .m_axis_tlast(  m_axis_xxv_width_up_tlast ),
  .m_axis_tuser(  m_axis_xxv_width_up_tuser_err )  
  
);

//Tx Down converter
axis_dwidth_converter_0 #(
  //TODO: need to specify parameters?
) axis_dwidth_down_converter_inst (
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

  //TODO: verify the widths after downconversion
  //define wire types to capture the width converter ouput and feed it to a RegSlice towards XXV IP 
  .m_axis_tvalid( s_axis_xxv_width_down_tvalid ),
  .m_axis_tdata(  s_axis_xxv_width_down_tdata ),
  .m_axis_tkeep(  s_axis_xxv_width_down_tkeep ),
  .m_axis_tlast(  s_axis_xxv_width_down_tlast ),
  .m_axis_tuser(  s_axis_xxv_width_down_tuser_err )  
  
);


axi_stream_packet_fifo #(
  //CDC stage creteria
  .CDC_SYNC_STAGES  (2),
  .CLOCKING_MODE    ("independent_clock"),
  .ECC_MODE         ("no_ecc"),
  .FIFO_DEPTH       (C_FIFO_DEPTH),
  .FIFO_MEMORY_TYPE ("auto"),
  .RELATED_CLOCKS   (0),
  .TDATA_WIDTH      (512)

);




//Remove this as axi_stream_packet_buffer module is used instead in Rx
//axis_data_fifo_0 #(
//
//  //TODO: check the configs in tcl file
//) axis_data_fifo_inst(
//  .s_axis_tdata( m_axis_xxv_width_up_tdata ),
//  .s_axis_tkeep( m_axis_xxv_width_up_tkeep ),
//  //tready for FIFO what if buffer gets full?
//  //.s_axis_tready(),
//  .s_axis_tuser( m_axis_xxv_width_up_tuser_err ),
//  .s_axis_tvalid( m_axis_xxv_width_up_tvalid ),
//  .s_axis_tlast( m_axis_xxv_width_up_tlast ),
//
//  .s_axis_aresetn(),
//  .s_axis_aclk(),
//  .m_axis_aclk(),
//
//  //Capture the output of fifo using wire and feed it to register slice or Box322Mhz for now
//  .m_axis_tdata(m_axis_xxv_fifo_rx_tdata),
//  .m_axis_tkeep(m_axis_xxv_fifo_rx_tkeep),
//  .m_axis_tlast(m_axis_xxv_fifo_rx_tlast),
//  //TODO: check if t_ready will be required?
//  //.m_axis_tready(),
//  .m_axis_tuser(m_axis_xxv_fifo_rx_tuser_err),
//  //TODO: verify is valid is mapped to valid for all axi signals everywhere
//  .m_axis_tvalid(m_axis_xxv_fifo_rx_tvalid)
//
//  );


//Tx direction 
//TODO: axi register slice -> AXI packet fifo -> AXI4 stream Downconverter -> AXI Register Slice -> XXV Ethernet 
//1st instance of axi register slice in Tx direction btw box322 and FIFO

//2nd instance of axi_register slice in tx direction between XXV IP and wdith up converter
axi_stream_register_slice #(
  .TDATA_W(64),
  .TUSER_W(/** TODO */),
  .MODE("full")
) tx_slice_inst(

//use the output of fifo as input




//s_axis_xxv_width_down_tuser_err
.s_axis_tvalid (s_axis_xxv_width_down_tvalid ),
.s_axis_tdata  (s_axis_xxv_width_down_tdata ),
.s_axis_tkeep  (s_axis_xxv_width_down_tkeep ),
.s_axis_tlast  (s_axis_xxv_width_down_tlast ),
//TODO: s_axis_tuser_err in tx direction ref cmac

//TODO: for register slice Tuser specififed as parameter?? .TUSER_W(48) ?
//m_axis_xxv_fifo_tuser_err

//capture the register slice output and feed it to XXV IP instance
.m_axis_tvalid(axis_xxv_tx_tvalid),
.m_axis_tdata (axis_xxv_tx_tdata),
.m_axis_tkeep (axis_xxv_tx_tkeep),
.m_axis_tlast (axis_xxv_tx_tlast),
.m_axis_tuser (axis_xxv_tx_tuser_err),
//TODO: cross check no tready?
.m_axis_tready(axis_xxv_tx_tready),


//TODO: clock of 322Mhz? as fifo output should be 322Mhz rate..
.aclk(),
.aresetn()
);



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
    .s_axis_tx_tvalid( axis_xxv_tx_tvalid ),
    .s_axis_tx_tdata( axis_xxv_tx_tdata ),
    .s_axis_tx_tkeep( axis_xxv_tx_tkeep ),
    .s_axis_tx_tlast( axis_xxv_tx_tlast ),
    .s_axis_tx_tuser_err( axis_xxv_tx_tuser_err ),
    .s_axis_tx_tready( axis_xxv_tx_tready ),


    .gt_refclk_p         (gt_refclk_p),
    .gt_refclk_n         (gt_refclk_n),
    .xxv_clk             (xxv_clk),
    .xxv_sys_reset      (~axil_aresetn),

    .axil_aclk           (axil_aclk),
    .ref_clk_100mhz       (ref_clk_100mhz)
);
`endif
//simulation case not handled.
endmodule: xxv_subsystem