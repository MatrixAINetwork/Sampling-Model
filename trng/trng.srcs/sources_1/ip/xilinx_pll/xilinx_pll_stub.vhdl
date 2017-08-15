-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
-- Date        : Thu Apr 27 18:01:58 2017
-- Host        : wds040 running 64-bit CentOS release 6.8 (Final)
-- Command     : write_vhdl -force -mode synth_stub
--               /proj/rcpfpga/wa/wangyf/trng_ip/fpga_proj_release/vc709/trng/trng.srcs/sources_1/ip/xilinx_pll/xilinx_pll_stub.vhdl
-- Design      : xilinx_pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1761-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xilinx_pll is
  Port ( 
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC
  );

end xilinx_pll;

architecture stub of xilinx_pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_in1_p,clk_in1_n,clk_out1,reset,locked";
begin
end;
