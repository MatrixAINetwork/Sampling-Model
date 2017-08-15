//all 'size' is real size
`define PARA_SIZE 4 // the number of rand_buff ports, the total number parallel FSMs is `PARA_SIZE*`BLOCKS_PER_32 
`define BIT_WID 8
`define BLOCKS_PER_32 4 //32/BIT_WID 
`define POSSI_S 32 //the number of all possible states
`define RESULT_SIZE 5 // log(2,POSSI_S)

`define STAT_WAIT 0
`define STAT_READ 1
`define STAT_FINI 2 
module sample
  (
  output [`PARA_SIZE-1:0] rand_rd,
  input [`PARA_SIZE-1:0] rand_ready,
  input [32*`PARA_SIZE-1:0] rand_data,
  
  input clk,
  input rstn,
  input enable,
  input [`BIT_WID*`POSSI_S-1:0] accu_distr,
  output done,
  output ready,
  output [`RESULT_SIZE*`PARA_SIZE*`BLOCKS_PER_32-1:0] result
  );
  
  wire [`BLOCKS_PER_32-1:0] temp_rd [`PARA_SIZE-1:0];
  wire [`PARA_SIZE*`BLOCKS_PER_32-1:0] finish;
  wire [`PARA_SIZE*`BLOCKS_PER_32-1:0] temp_ready;
  wire [`BIT_WID-1:0] rand [`PARA_SIZE-1:0][`BLOCKS_PER_32-1:0];
  assign done = &finish;
  assign ready = &temp_ready;
  
  generate
    genvar k1, k2;
    for(k1 = 0; k1 < `PARA_SIZE; k1=k1+1) begin: ports
      
      assign rand_rd[k1] = &temp_rd[k1];
      
      for(k2 = 0; k2 < `BLOCKS_PER_32; k2=k2+1) begin: blocks
        sample_FSM fsm(
                       .clk(clk),
                       .rstn(rstn),
                       .done(done),
                       .enable(enable),
                       .rand_ready(rand_ready[k1]),
                       .rand_data(rand_data[32*k1+`BIT_WID*(k2+1)-1:32*k1+`BIT_WID*k2]),
  
                       .rand_rd(rand_rd[k1]),
                       .temp_rd(temp_rd[k1][k2]),
                       .finish(finish[k1*`BLOCKS_PER_32+k2]),
                       .ready(temp_ready[k1*`BLOCKS_PER_32+k2]),
                       .rand(rand[k1][k2])    //maybe prob
                      );
        sample_comb_32S  comb_32s(
                       .accu_distr(accu_distr),
                       .rand(rand[k1][k2]),
                       .result(result[`RESULT_SIZE*`BLOCKS_PER_32*k1+`RESULT_SIZE*(k2+1)-1:`RESULT_SIZE*`BLOCKS_PER_32*k1+`RESULT_SIZE*k2]) //unfinished 
                     );
      end
    end
  endgenerate
  
endmodule

module sample_FSM
  (
  input clk,
  input rstn,
  input done,
  input enable,
  input rand_ready,
  input[`BIT_WID-1:0] rand_data,
  
  input rand_rd,
  output temp_rd,
  output finish,
  output ready,
  output reg[`BIT_WID-1:0] rand
  );
  
  reg [1:0] state;
  
  always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
      state <= `STAT_WAIT;
      rand <= 0;
    end
    else begin
      case(state)
        `STAT_WAIT: begin
          if(enable&rand_ready) begin
            state <= `STAT_READ;
            rand <= rand_data;
          end
          else begin
            state <= `STAT_WAIT;
          end
        end
        `STAT_READ: begin
          if(rand_rd) begin
            state <= `STAT_FINI;
          end
          else begin
            state <= `STAT_READ;
          end
        end
        `STAT_FINI: begin
          if(done) begin
            state <= `STAT_WAIT;
          end
          else begin
            state <= `STAT_FINI;
          end
        end
      endcase
    end
  end
  
  assign ready = (state == `STAT_WAIT);
  assign temp_rd = (state == `STAT_READ);
  assign finish = (state == `STAT_FINI);
endmodule

module sample_comb_32S  //only use for `POSSI_S == 32
  (
  input[`BIT_WID*`POSSI_S-1:0] accu_distr,
  input[`BIT_WID-1:0] rand,
  output[`RESULT_SIZE-1:0] result 
  );
  
  wire[1:0] stage1 [15:0];
  wire[2:0] stage2 [7:0];
  wire[3:0] stage3 [3:0];
  wire[4:0] stage4 [1:0];
  
  assign stage1[1] = (rand>accu_distr[(2*1+1)*`BIT_WID-1:2*1*`BIT_WID]) + (rand>accu_distr[(2*1+2)*`BIT_WID-1:(2*1+1)*`BIT_WID]);

  generate
    genvar s1;
    for(s1 = 0; s1 < 16; s1=s1+1) begin: sta1
      assign stage1[s1] = (rand>accu_distr[(2*s1+1)*`BIT_WID-1:2*s1*`BIT_WID]) + (rand>accu_distr[(2*s1+2)*`BIT_WID-1:(2*s1+1)*`BIT_WID]);
    end
  endgenerate
  
  generate
    genvar s2;
    for(s2 = 0; s2 < 8; s2=s2+1) begin: sta2
      assign stage2[s2] = stage1[2*s2] + stage1[2*s2+1];
    end
  endgenerate
  
  generate
    genvar s3;
    for(s3 = 0; s3 < 4; s3=s3+1) begin: sta3
      assign stage3[s3] = stage2[2*s3] + stage2[2*s3+1];
    end
  endgenerate
  
  assign stage4[0] = stage3[0] + stage3[1];
  assign stage4[1] = stage3[2] + stage3[3];
  
  assign result = stage4[0] + stage4[1];
endmodule