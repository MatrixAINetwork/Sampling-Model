`define STAT_WAIT 0 
`define STAT_READY 1
`define STAT_FULL 2
`define STAT_WRITE 3
`define QUEUE_SIZE 7
`define PTR_SIZE 2

module singlethread
  (
  input clk_sample,
  input rstn,
  input full,
  input[`PTR_SIZE:0] ptr_I,
  input rd,
  
  output empty,
  output reg[`PTR_SIZE:0] ptr_O,
  output ready
  );
  
  reg state;
  wire [`PTR_SIZE:0] ptr_I_p1, ptr_I_p2;
  assign ptr_I_p1 = ptr_I + 1;   //if we directly write (ptr_I+2 == ptr_O) as a condition, it won't be triggered
  assign ptr_I_p2 = ptr_I + 2;
  
  always @(posedge clk_sample or negedge rstn) begin
    if(~rstn) begin
      state <= `STAT_WAIT;
      ptr_O <= 0;
    end
    else if(state == `STAT_WAIT) begin
      if(ptr_I_p1 != ptr_O || full) begin
        state <= `STAT_READY;
      end
      else begin
        state <= `STAT_WAIT;
      end
    end
    else if(state == `STAT_READY) begin
      if(~rd) begin
        state <= `STAT_READY;
      end
      else begin
        if(ptr_I == ptr_O) begin
          state <= `STAT_WAIT;
          ptr_O <= ptr_O + 1;
        end
        else begin
          state <= `STAT_READY;
          ptr_O <= ptr_O + 1;
        end
      end
    end
  end
  
  assign ready = (state == `STAT_READY);
  assign empty = (state == `STAT_WAIT);

endmodule
