//all 'size' means real size -1.
`define PARA_SIZE 3
`define PARA_PTR_SIZE 1
`define STAT_WAIT 0 
`define STAT_READY 1
`define STAT_FULL 2
`define STAT_WRITE 3
`define QUEUE_SIZE 7
`define PTR_SIZE 2

//needs improving: if one thread is empty, it should be filled first.

module buff
(
  input clk_trng,
  input clk_sample,
  input rstn,
  input [31:0] data_I,
  
  input [`PARA_SIZE:0] rd,
  output [`PARA_SIZE:0] ready,
  output [32*(`PARA_SIZE+1)-1:0] data_O
);  

  reg[1:0] state_I;
  
  reg [`PARA_SIZE:0] full;
  reg [31:0] queue [`PARA_SIZE:0][`QUEUE_SIZE:0];
  reg [`PTR_SIZE:0] ptr_I [`PARA_SIZE:0];
  wire [`PTR_SIZE:0] ptr_O [`PARA_SIZE:0];
  wire empty[`PARA_SIZE:0];
  wire [`PTR_SIZE:0] ptr_I_p1[`PARA_SIZE:0], ptr_I_p2[`PARA_SIZE:0];
  
  generate 
    genvar i;
    for(i = 0; i <= `PARA_SIZE; i = i+1) begin: gen_threads
      singlethread thread(.clk_sample(clk_sample),
                        .rstn(rstn),
                        .full(full[i]),
                        .ptr_I(ptr_I[i]),
                        .rd(rd[i]),
                        .empty(empty[i]),
                        .ready(ready[i]),
                        .ptr_O(ptr_O[i])
                        );
      assign data_O[(i+1)*32-1:i*32] = queue[i][ptr_O[i]];
      assign ptr_I_p1[i] = ptr_I[i] + 1;   
      assign ptr_I_p2[i] = ptr_I[i] + 2;
    end
  endgenerate
  
  /*singlethread thread1(.clk_sample(clk_sample),
                        .rstn(rstn),
                        .full(full[0]),
                        .ptr_I(ptr_I[0]),
                        .rd(rd[0]),
                        .empty(empty[0]),
                        .ready(ready[0]),
                        .ptr_O(ptr_O[0])
                        );
                        
  singlethread thread2(.clk_sample(clk_sample),
                        .rstn(rstn),
                        .full(full[1]),
                        .ptr_I(ptr_I[1]),
                        .rd(rd[1]),
                        .empty(empty[1]),
                        .ready(ready[1]),
                        .ptr_O(ptr_O[1])
                        );
 
  assign data_O[31:0] = queue[0][ptr_O[0]];
  assign data_O[63:32] = queue[1][ptr_O[1]];
  
  
  assign ptr_I_p1[0] = ptr_I[0] + 1;   
  assign ptr_I_p2[0] = ptr_I[0] + 2;
  assign ptr_I_p1[1] = ptr_I[1] + 1;   
  assign ptr_I_p2[1] = ptr_I[1] + 2;*/
  
  
  reg [`PARA_PTR_SIZE:0] para_ptr;
  integer j;
  
  always @(posedge clk_trng or negedge rstn) begin
    if(~rstn) begin
      
      for(j = 0; j <= `PARA_SIZE; j = j+1)
        ptr_I[j] <= -1;
      
      //ptr_I[0] <= -1;
      //ptr_I[1] <= -1;
      
      state_I <= `STAT_WAIT;
      para_ptr <= 0;
      full <= 0;
    end
    else begin
      case(state_I) 
        `STAT_WAIT : begin
          if(full[para_ptr]) begin
            state_I <= `STAT_FULL;
          end
          else if(data_I == 32'h00000071) begin
            state_I <= `STAT_READY;
          end
          else begin
            state_I <= `STAT_WAIT; 
          end
        end
        `STAT_READY : begin
          if(data_I == 32'h0280f76b) begin
            state_I <= `STAT_WRITE;
          end
          else begin
            state_I <= `STAT_READY;
          end
        end
        `STAT_WRITE : begin
          if(ptr_I_p2[para_ptr] == ptr_O[para_ptr]) begin
            state_I <= `STAT_WAIT;
            para_ptr <= (para_ptr == `PARA_SIZE) ? 0 : (para_ptr+1);
            full[para_ptr] <= 1;
            ptr_I[para_ptr] <= ptr_I[para_ptr] + 1;
            queue[para_ptr][(ptr_I[para_ptr]+1)&`QUEUE_SIZE] <= data_I;
          end
          else begin
            state_I <= `STAT_WAIT;
            para_ptr <= (para_ptr == `PARA_SIZE) ? 0 : (para_ptr+1);
            ptr_I[para_ptr] <= ptr_I[para_ptr] + 1;
            queue[para_ptr][(ptr_I[para_ptr]+1)&`QUEUE_SIZE] <= data_I;
          end
        end
        `STAT_FULL : begin
          if(ptr_I_p1[para_ptr] != ptr_O[para_ptr] || empty[para_ptr]) begin
            state_I <= `STAT_WAIT;
            full[para_ptr] <= 0;
          end
          else begin
            state_I <= `STAT_WAIT;
            para_ptr <= (para_ptr == `PARA_SIZE) ? 0 : (para_ptr+1);
          end
        end
        default : begin
          state_I <= `STAT_WAIT;
        end
      endcase
    end
  end

  
endmodule
