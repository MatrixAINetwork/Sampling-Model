//all 'size' is real size
`define PARA_SIZE 4 // the number of rand_buff ports, the total number parallel FSMs is `PARA_SIZE*`BLOCKS_PER_32 
`define BIT_WID 8
`define BLOCKS_PER_32 4 //32/BIT_WID 
`define POSSI_S 32 //the number of all possible states
`define RESULT_SIZE 5 // log(2,POSSI_S)

//`define STAT_WAIT 0
`define STAT_READ 1
`define STAT_FINI 2 

module trng_fpga_top(
    input    clk_p_i,
    input    clk_n_i,
    input    reset_i
   // output   done
);

(*MARK_DEBUG = "TRUE"*) wire [31:0] rdata;
wire        sel;
wire        clk;
wire [31:0] addr;
wire [31:0] wdata;
wire        scan_mode;
wire        resetn;
(*MARK_DEBUG = "TRUE"*) wire        write;

assign resetn = ~reset_i;

`ifdef XILINX_FPGA
wire locked;
xilinx_pll u_xilinx_pll
 (
  .clk_in1_p(clk_p_i),
  .clk_in1_n(clk_n_i),
  
  .clk_out1(clk),
  .reset(reset_i),
  .locked(locked)
 );

`else
    assign clk = clk_p_i;
`endif


trng_drive u_trng_drive
(
  .CLK_I(clk),
  .RESETN_I(resetn),
  .RDATA_I(rdata),
  .SEL_O(sel),     
  .ADDR_O(addr),   
  .WRITE_O(write),   
  .WDATA_O(wdata), 
  .SCAN_MODE_O(scan_mode)
);


 trng_top dut(
           .CLK_I       (clk),
           .RESETN_I    (resetn),

           .SEL_I       (sel),       //chip select
           .ADDR_I      (addr),      //address
           .WRITE_I     (write),     //1:write  0:read
           .WDATA_I     (wdata),       //write data
           .RDATA_I     (rdata),       //read data

           .SCAN_MODE_I (scan_mode)  //scan mode enable 
);   


  wire [3:0] rd;
  (*MARK_DEBUG = "TRUE"*) wire [3:0] ready;
  wire [127:0] data_O;

  buff inst(.clk_trng(clk),
            .clk_sample(clk),
            .rstn(resetn),
            .rd(rd),
            .data_I(rdata),
            .data_O(data_O),
            .ready(ready));
        
  //reg enable;
  wire sam_ready; 
  wire [`BIT_WID*`POSSI_S-1:0] accu_distr;
   (*MARK_DEBUG = "TRUE"*) wire [`RESULT_SIZE*`PARA_SIZE*`BLOCKS_PER_32-1:0] result;
   (*MARK_DEBUG = "TRUE"*) wire done;
  
  generate
    genvar dis;
    for(dis = 0; dis < 32; dis = dis+1) begin: test_dis
      assign accu_distr[(dis+1)*`BIT_WID-1:dis*`BIT_WID] = (dis+1)*8-1; // uniform distribution, 2^`BIT_WID / `POSSI
    end
  endgenerate
  
  sample ss1
  (
  .rand_rd(rd),
  .rand_ready(ready),
  .rand_data(data_O),
  
  .clk(clk),
  .rstn(resetn),
  .enable(1'b1),
  .accu_distr(accu_distr),
  
  .done(done),
  .ready(sam_ready),
  .result(result)
  );


endmodule
