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
set axis_data_fifo axis_data_fifo
create_ip -name axis_data_fifo -vendor xilinx.com -library ip -module_name $axis_data_fifo -dir ${ip_build_dir}
set_property -dict {
#TODO: set properties as per requirement
ALLOWED_SIM_MODELS	rtl
#CLASS	bd_cell
CONFIG.ACLKEN_CONV_MODE	0
CONFIG.Component_Name	design_1_axis_data_fifo_2_0
CONFIG.ENABLE_ECC	0
CONFIG.FIFO_DEPTH	512
CONFIG.FIFO_MEMORY_TYPE	auto
CONFIG.FIFO_MODE	1
CONFIG.HAS_AEMPTY	0
CONFIG.HAS_AFULL	0
CONFIG.HAS_ECC_ERR_INJECT	0
CONFIG.HAS_PROG_EMPTY	0
CONFIG.HAS_PROG_FULL	0
CONFIG.HAS_RD_DATA_COUNT	0
CONFIG.HAS_TKEEP	0
CONFIG.HAS_TLAST	0
CONFIG.HAS_TREADY	1
CONFIG.HAS_TSTRB	0
CONFIG.HAS_WR_DATA_COUNT	0
CONFIG.IS_ACLK_ASYNC	0
CONFIG.PROG_EMPTY_THRESH	5
CONFIG.PROG_FULL_THRESH	11
CONFIG.SYNCHRONIZATION_STAGES	3
CONFIG.TDATA_NUM_BYTES	1
CONFIG.TDEST_WIDTH	0
CONFIG.TID_WIDTH	0
CONFIG.TUSER_WIDTH	0
LOCATION	3 860 -140
NAME	axis_data_fifo_2
PATH	/axis_data_fifo_2
SCREENSIZE	200 116
SELECTED_SIM_MODEL	rtl
TYPE	ip
VLNV	xilinx.com:ip:axis_data_fifo:2.0

} [get_ips $axis_data_fifo]