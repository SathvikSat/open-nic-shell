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
module xxv_subsystem_xxv_wrapper #(
  parameter int XXV_ID = 0
) (
    //10G/25G 
    input    [0:0] gt_rxp,
    input    [0:0] gt_rxn,
    output   [0:0] gt_txp,
    output   [0:0] gt_txn,

    //AXI lite for configuration via PCIe BAR
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

    output         m_axis_rx_tvalid,
    output [63:0] m_axis_rx_tdata,
    output  [8:0] m_axis_rx_tkeep,
    output         m_axis_rx_tlast,
    output         m_axis_rx_tuser_err,

    input          s_axis_tx_tvalid,
    input  [63:0]  s_axis_tx_tdata,
    input   [8:0]  s_axis_tx_tkeep,
    input          s_axis_tx_tlast,
    input          s_axis_tx_tuser_err,
    output         s_axis_tx_tready,

    input          gt_refclk_p,
    input          gt_refclk_n,
    
    output         xxv_clk,
    input          xxv_sys_reset,
    input          axil_aclk,
    input          ref_clk_100mhz

);

  wire tx_clk_out_0;
  wire rx_clk_out_0;
  wire rxrecclkout_0;

  //Regardless of AXI lite port; needs to be set 
  wire ctl_tx_send_idle;
  wire ctl_tx_send_rfi;
  wire ctl_tx_send_lfi; 



  assign xxv_clk = tx_clk_out_0;
  assign ctl_tx_send_idle        = 1'b0;
  assign ctl_tx_send_rfi         = 1'b0;
  assign ctl_tx_send_lfi         = 1'b0; 
  
  generate if (XXV_ID == 0 ) begin
    xxv_ethernet_0 xxv_inst(
    .gt_rxp_in                           (gt_rxp),
    .gt_rxn_in                           (gt_rxn),
    .gt_txp_out                          (gt_txp),
    .gt_txn_out                          (gt_txn),

    /** Inputs, 1bit */
    /**
     * This port is available when the Include GT subcore option in the 
     * example design is selected
     */
    .sys_reset(xxv_sys_reset),
    //External 100Mhz source verify this clk 100Mhz?
    /**
      * This port is available when the Include GT subcore in example design 
      * option is selected
      */
    .dlck(ref_clk_100mhz), //TODO: 100Mhz ?
    //.sys_reset_0(xxv_sys_reset),
    
    
    /**
     * The port is available when Soft RS-FEC TX and Hard RS-FEC RX options are enabled
     *
     */
    //.dlck_0                              (ref_clk_100mhz),
    
    //.clk_322()
    //.locked_out_322()
    
    .gt_ref_clk_p                        (gt_refclk_p),
    .gt_ref_clk_n                        (gt_refclk_n),
    
    //2/4 bit shared logic is part of core
    //.qpll0clk_in( )
    //ASK: what is the difference between clock and refclk?
    //.qpll0refclk_in( )
    //.qpll1clk_in( )
    //.qpll1refclk_in( )
    
    //.gtwiz_reset_qpll0lock_in()
    //.gtwiz_reset_qpll0reset_out()
    //.gtwiz_reset_qpll1lock_in()

    //output signals 1bit
    //.gtwiz_reset_qpll1reset_out()
    
    /** TX user clock output from GT. */
    /** tx_clk_out_0 for axi stream data clocking == tc_serdes_refclk == 156.25Mhz */
    .tx_clk_out_0(tx_clk_out_0),
    
    //ASK: check IP version

    /** This interface is used to connect to the physical layer, 
      * where this is a separate device or implemented in the 
      * FPGA beside the Ethernet MAC core.
      */
    //.tx_mii_clk_0()

    /** rx_serdes_clk
    * The rx_serdes_clk is derived from the incoming data stream within the GT block. 
    * The incoming data stream is processed by the RX core in this clock domain.
    *
    * rx_clk_out
    * The rx_clk_out output signal is presented as a reference for the RX control 
    * and status signals processed by the RX core. It is the same frequency as the rx_serdes_clk.
    *
    */
    .rx_clk_out_0(rx_clk_out),
    
    /** With example design */
    //.rx_serdes_clk_0()
    //.rx_serdes_reset_0()

    //output
    .rxrecclkout_0(rxrecclkout_0),

    //input When include GT sub-core in example design
    //.tx_core_clk_0()
    .rx_core_clk_0(tx_clk_out_0) //tx and rx streams in same clock domain
    .tx_reset_0()

    //output
    .user_tx_reset_0()
    .gt_reset_tx_done_out_0()

    //input
    rx_reset_0()

    //output
    user_rx_reset_0()
    gt_reset_rx_done_out_0()
    
    //input
    gtwiz_reset_all_in_0()

    //Out
    ctl_gt_reset_all_0()

    .gtwiz_tx_datapath_reset_in_0(gtwiz_reset_tx_datapath)
    
    //Out
    ctl_gt_tx_reset_0()
    gtwiz_rx_datapath_reset_in_0()
    //Out
    ctl_gt_rx_reset_0()
    gt_reset_all_in_0()
    gt_tx_reset_in_0()
    gt_rx_reset_in_0()
    
    //Out
    gt_refclk_out_0()
    //Out
    gtpowergood_out_0()
    TXOUTCLKSEL_IN_0()

    RXOUTCLKSEL_IN_0()
    gtm_txusrclk2_0()
    gtm_rxusrclk2_0()
    gt_loopback_in_0()
    gt_loopback_out_0()
    gt_txp_out()
    gt_txn_out() 
    gt_rxn_in()
    gt_rxp_in()
    gt_rxp_in_0
    gt_rxn_in_0( )
    gt_rxp_in_1( )
    gt_rxn_in_1( )
    gt_rxp_in_2( )
    gt_rxn_in_2( )
    gt_rxp_in_3( )
    gt_rxn_in_3( )
    gt_txp_out_0( )

    gt_txn_out_0()
    gt_txp_out_1()
    gt_txn_out_1()
    gt_txp_out_2()
    gt_txn_out_2()
    gt_txp_out_3()
    gt_txn_out_3()
    gtwiz_loopback_0()
    gtwiz_tx_rate_0()
    gtwiz_rx_rate()
    rxgearboxslip_in()
    rxdatavalid_out()
    rx_serdes_data_out()
    rxdata_out()
    rxheader_out()
    rxheadervalid_out()
    tx_serdes_data_in()
    txdata_in_()
    mst_tx_resetdone()
    mst_rx_resetdone()
    tx_pma_resetdone()
    rx_pma_resetdone()
    mst_tx_reset()
    mst_rx_reset()
    txuserrdy_out()
    mst_tx_dp_reset()
    mst_rx_dp_reset()
    rxuserrdy_out()
    tx_resetdone_out()
    rx_resetdone_out()
    txheader_in()

  //Transreceiver core status and debug port not handled
  //AXI lite
    s_axi_aclk_0()
    s_axi_aresetn_0()
    pm_tick_0()

    s_axi_awaddr_0(s_axil_awaddr)   
    s_axi_awvalid_0(s_axil_awvalid)
    s_axi_awready_0(s_axil_awready)
    s_axi_wdata_0(s_axil_wdata)
    s_axi_wstrb_0(4'hF)
    s_axi_wvalid_0(s_axil_wvalid)
    s_axi_wready_0(s_axil_wready)
    s_axi_bresp_0(s_axil_bresp)
    s_axi_bvalid_0(s_axil_bvalid)
    s_axi_bready_0(s_axil_bready)
    s_axi_araddr_0(s_axil_araddr)
    s_axi_arvalid_0(s_axil_arvalid)
    s_axi_arready_0(s_axil_arready)
    s_axi_rdata_0(s_axil_rdata)
    s_axi_rresp_0(s_axil_rresp)
    s_axi_rvalid_0(s_axil_rvalid)
    s_axi_rready_0(s_axil_rready)

    //AXI stream user interface signals
    tx_unfout_0()
    tx_unfout_0()
    tx_axis_tready_0()
    tx_axis_tvalid_0()
    tx_axis_tdata_0()
    tx_axis_tlast_0()
    tx_axis_tkeep_0()
    tx_axis_tuser_0()
    tx_preamblein_0()
    tx_parityin_0()
    rx_axis_tvalid_0()
    rx_axis_tdata_0()
    rx_axis_tlast_0()
    rx_axis_tkeep_0()
    rx_axis_tuser_0()
    rx_preamblein_0()
    rx_parityout_0()
    //test

    //control/status/statistics signals not handled
      .ctl_tx_send_idle                    (ctl_tx_send_idle),
      .ctl_tx_send_rfi                     (ctl_tx_send_rfi),
      .ctl_tx_send_lfi                     (ctl_tx_send_lfi)

  // Note: all other control signals are handled via AXI lite interface
    //TODO: does that mean just no external signal, but the signal still needs to be handled?
    //TODO: How is value received from AXI lite assigned, well axi_addr etc signals!

    //stat signals are all output.

    //Enable Tx flow control is not handled as of now 

    )
  end 
  endgenerate

endmodule:xxv_subsystem_xxv_wrapper

