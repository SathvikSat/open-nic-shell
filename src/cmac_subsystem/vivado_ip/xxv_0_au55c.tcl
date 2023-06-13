# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************

set xxv_ethernet xxv_ethernet_0
create_ip -name xxv_ethernet -vendor xilinx.com -library ip - module_name $xxv_ethernet -dir ${ip_build_dir}
set_property -dict{
#ALLOWED_SIM_MODELS	rtl
#CLASS	bd_cell

CONFIG.ADD_GT_CNTRL_STS_PORTS	{0}

CONFIG.ANLT_CLK_IN_MHZ	{100}


#CONFIG.BASE_R_KR	{BASE-KR}


#ASK: What's asynchronous clock
CONFIG.CLOCKING	{Asynchronous}

#ASK: how location is identified?
#CONFIG.CMAC_CORE_SELECT	{CMACE4_X0Y0}

CONFIG.CORE	Ethernet {MAC+PCS/PMA 64-bit}
            #CONFIG.Component_Name	design_1_xxv_ethernet_0_0
CONFIG.DATA_PATH_INTERFACE	{AXI Stream}

#ASK: Gt_ref_clk0/1?
CONFIG.DIFFCLK_BOARD_INTERFACE	{Custom}
CONFIG.ENABLE_DATAPATH_PARITY	{0}
CONFIG.ENABLE_PIPELINE_REG	{0}
CONFIG.ENABLE_PREEMPTION	{0}
CONFIG.ENABLE_PREEMPTION_FIFO	{0}

#ASK: FLOW control
CONFIG.ENABLE_RX_FLOW_CONTROL_LOGIC	{0}
CONFIG.ENABLE_TIME_STAMPING	{0}
CONFIG.ENABLE_TX_FLOW_CONTROL_LOGIC	{0}
CONFIG.ENABLE_VLANE_ADJUST_MODE	{0}

#ASK: qsfp1/0?
CONFIG.ETHERNET_BOARD_INTERFACE	{Custom}
#CONFIG.FAST_SIM_MODE	0
#CONFIG.GTM_GROUP_SELECT	NA
#CONFIG.GT_DRP_CLK	100.00
CONFIG.GT_GROUP_SELECT	{Quad_X0Y6}
CONFIG.GT_LOCATION	{1}

#qsfp0_refclk0 156.25 Mhz * 64bits = 10G 
CONFIG.GT_REF_CLK_FREQ	{156.25} 
CONFIG.GT_TYPE	{GTY}
CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC	{None}
CONFIG.INCLUDE_AXI4_INTERFACE	{0}
CONFIG.INCLUDE_FEC_LOGIC	{0}
CONFIG.INCLUDE_HYBRID_CMAC_RSFEC_LOGIC	{0}
CONFIG.INCLUDE_RSFEC_LOGIC	{0}

#ASK: GT and MAC?
CONFIG.INCLUDE_SHARED_LOGIC	{1}
CONFIG.INCLUDE_STATISTICS_COUNTERS	{0}
CONFIG.INCLUDE_USER_FIFO	{1}
#CONFIG.INS_LOSS_NYQ	{30}

#25/10G lane1?
CONFIG.LANE1_GT_LOC	{X0Y24} 

#25/10G lane2?
CONFIG.LANE2_GT_LOC	{NA}

#25/10G lane3?
CONFIG.LANE3_GT_LOC	{NA}

#25/10G lane4?
CONFIG.LANE4_GT_LOC	{NA}
CONFIG.LINE_RATE	{10}
CONFIG.NUM_OF_CORES	{1}
CONFIG.PTP_CLOCKING_MODE	{0}
CONFIG.PTP_OPERATION_MODE	{2}
CONFIG.RUNTIME_SWITCH	{0}
CONFIG.RX_EQ_MODE	{AUTO}
CONFIG.STATISTICS_REGS_TYPE	{0}
CONFIG.SWITCH_1_10_25G	{0}

#ASK:
#CONFIG.SYS_CLK	{4000}
CONFIG.TX_LATENCY_ADJUST	0
CONFIG.USE_BOARD_FLOW	true
CONFIG.XGMII_INTERFACE	1
LOCATION	4 1460 760
NAME	{xxv_ethernet_0}
PATH	{/xxv_ethernet_0}
#SCREENSIZE	440 916
#SELECTED_SIM_MODEL	rtl
TYPE	{ip}
VLNV	{xilinx.com:ip:xxv_ethernet:3.3}
} [get_ips $xxv_ethernet]
set_property CONFIG.RX_MIN_PACKET_LEN $min_pkt_len []