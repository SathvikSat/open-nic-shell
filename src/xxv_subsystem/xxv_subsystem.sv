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


 // Tx data axi slave:
//s_tvalid
//s_tdata [511:0]  -------->> [63:0]
//s_tkeep [63:0]
//s_tlast
//s_tuser_err
//output s_tready


//Rx master data axi master:
//rx_tvalid
//rx_tdata [511:0]
//rx_tkeep [63:0]
//rx_tlast
//rx_tuser_err


//gt

input s_axil_awvalid,
intput 












);
endmodule: xxv_ethernet