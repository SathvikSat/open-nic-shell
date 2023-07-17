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

#TODO: update this 
set axis_dwidth_converter axis_dwidth_converter_0
create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -module_name $axis_dwidth_converter -dir ${ip_build_dir}
set_property -dict { 
    #TODO:recheck properties for all new additions of IPs, XXV etc
    #TODO: need to cross-verify configs
    ALLOWED_SIM_MODELS	{rtl} 
    #CLASS	bd_cell 
    CONFIG.Component_Name 	{design_1_axis_dwidth_converter_0_0}
    CONFIG.HAS_ACLKEN 	{0}
    CONFIG.HAS_MI_TKEEP 	{1}
    CONFIG.HAS_TKEEP 	{1}
    CONFIG.HAS_TLAST 	{1}
    CONFIG.HAS_TREADY 	{1}
    CONFIG.HAS_TSTRB 	{0}
    #TODO: TUSER needs to be handled for >1x instance of XXV
    CONFIG.M_TDATA_NUM_BYTES 	{64} 
    CONFIG.S_TDATA_NUM_BYTES 	{8}
    CONFIG.TDEST_WIDTH 	{0}
    CONFIG.TID_WIDTH 	{0}
    CONFIG.TUSER_BITS_PER_BYTE 	{0}
    LOCATION	3  860 970
    NAME	{axis_dwidth_converter_0} 
    PATH	{/axis_dwidth_converter_0} 
    #SCREENSIZE	340  216
    SELECTED_SIM_MODEL	{rtl} 
    TYPE	{ip} 
    VLNV	{xilinx .com:ip:axis_dwidth_converter:1.1}
} [get_ips $axis_dwidth_converter]
