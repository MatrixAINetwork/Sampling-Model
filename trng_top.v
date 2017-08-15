/*
    --This confidential and proprietary code may be used 
    --only as authorized by a licensing agreement from 
    --RCG.TWRI. 
    --In the event of publication, the following notice is 
    --applicable: 
    -- 
    -- (C) COPYRIGHT 2016 RCG.TWRI. 
    -- ALL RIGHTS RESERVED 
    -- 
    -- The entire notice above must be reproduced on all 
    --authorized copies. 
    -- 
    -- Filename     : trng_top.v 
    -- Author       : Sunjj
    -- Date         : 16/09/20
    -- Version      : 0.1 
    -- Description  : trng_top
    -- 
    -- Modification History: 
    -- Date      By    Version   Change Description 
    --        
======================================================== 
    -- 16/09/20   TH     0.1     Original 
--  
========================================================  
*/

module trng_top 
  (
  input                 CLK_I,
  input                 RESETN_I,

  input                 SEL_I,         //chip select
  input  [31:0]         ADDR_I,        //address
  input                 WRITE_I,       //1:write  0:read
  input  [31:0]         WDATA_I,       //write data
  output [31:0]         RDATA_I,       //read data

  input                 SCAN_MODE_I     //scan mode enable
  
);


endmodule
