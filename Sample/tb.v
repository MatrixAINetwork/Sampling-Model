//all 'size' is real size
`define PARA_SIZE 4 // the number of rand_buff ports, the total number parallel FSMs is `PARA_SIZE*`BLOCKS_PER_32 
`define BIT_WID 8
`define BLOCKS_PER_32 4 //32/BIT_WID 
`define POSSI_S 32 //the number of all possible states
`define RESULT_SIZE 5 // log(2,POSSI_S)

`define STAT_WAIT 0
`define STAT_READ 1
`define STAT_FINI 2 

module tb(input clk,
          
          input rstn,
          input [31:0] data_I,
          input enable,
          output[`RESULT_SIZE*`PARA_SIZE*`BLOCKS_PER_32-1:0] result,
          output done);
 
  wire [3:0] rd;
  wire [3:0] ready;
  wire [127:0] data_O;
  //reg [31:0] cnt;
  buff inst(.clk_trng(clk),
            .clk_sample(clk),
            .rstn(rstn),
            .rd(rd),
            .data_I(data_I),
            .data_O(data_O),
            .ready(ready));
        
 // wire done;
  wire sam_ready; 
  wire [`BIT_WID*`POSSI_S-1:0] accu_distr;
 // wire [`RESULT_SIZE*`PARA_SIZE*`BLOCKS_PER_32-1:0] result;
  
  generate
    genvar dis;
    for(dis = 0; dis < 32; dis = dis+1) begin: test_dis
      assign accu_distr[(dis+1)*`BIT_WID-1:dis*`BIT_WID] = (dis+1)*8-1; // uniform distribution
    end
  endgenerate
  
  sample ss1
  (
  .rand_rd(rd),
  .rand_ready(ready),
  .rand_data(data_O),
  
  .clk(clk),
  .rstn(rstn),
  .enable(enable),
  .accu_distr(accu_distr),
  
  .done(done),
  .ready(sam_ready),
  .result(result)
  );
 
endmodule
