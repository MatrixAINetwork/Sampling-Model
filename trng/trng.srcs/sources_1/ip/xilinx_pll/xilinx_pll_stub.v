// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
// Date        : Thu Apr 27 18:01:58 2017
// Host        : wds040 running 64-bit CentOS release 6.8 (Final)
// Command     : write_verilog -force -mode synth_stub
//               /proj/rcpfpga/wa/wangyf/trng_ip/fpga_proj_release/vc709/trng/trng.srcs/sources_1/ip/xilinx_pll/xilinx_pll_stub.v
// Design      : xilinx_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xilinx_pll(clk_in1_p, clk_in1_n, clk_out1, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1_p,clk_in1_n,clk_out1,reset,locked" */;
  input clk_in1_p;
  input clk_in1_n;
  output clk_out1;
  input reset;
  output locked;
endmodule
