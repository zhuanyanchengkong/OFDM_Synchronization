// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2.1 (win64) Build 1302555 Wed Aug  5 13:06:02 MDT 2015
// Date        : Wed Dec 14 00:35:41 2016
// Host        : FUTURE2 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               G:/jiaweiwei/Project/OFDM_Synchronization/OFDM_Synchronization/OFDM_Synchronization.srcs/sources_1/ip/dsp48_mul_ip/dsp48_mul_ip_stub.v
// Design      : dsp48_mul_ip
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045fbg676-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "xbip_dsp48_macro_v3_0,Vivado 2015.2.1" *)
module dsp48_mul_ip(CLK, A, B, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[17:0],B[17:0],P[47:0]" */;
  input CLK;
  input [17:0]A;
  input [17:0]B;
  output [47:0]P;
endmodule
