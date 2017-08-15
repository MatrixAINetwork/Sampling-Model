
module trng_drive
(
  input                  CLK_I,
  input                  RESETN_I,
  input      [31:0]      RDATA_I,
  output reg             SEL_O,     
  output reg [31:0]      ADDR_O,   
  output reg             WRITE_O,   
  output reg [31:0]      WDATA_O, 
  output                 SCAN_MODE_O 
);

//////////////////////////////////////////////////////////////////////
// parameter
//////////////////////////////////////////////////////////////////////
parameter S_IDLE        = 3'b000;
parameter S_RST_TRNG    = 3'b001;
parameter S_TRNG_EN     = 3'b010;
parameter S_TRNG_RUN    = 3'b011;
parameter S_RD_STAT     = 3'b100;
parameter S_RD_DATA     = 3'b101;


parameter  DCS_TRNG_CTRL_ADDR       = 16'h0000;  // trng_start_ctrl
parameter  DCS_TRNG_BIT_ADDR_0      = 16'h0004;  // Out_bit0_reg 
parameter  DCS_TRNG_STATE_ADDR_0    = 16'h0008;  // Out_state0
parameter  DCS_TRNG_BIT_ADDR_1      = 16'h000c;  // Out_bit1_reg
parameter  DCS_TRNG_STATE_ADDR_1    = 16'h0010;  // Out_state1
parameter  DCS_TRNG_BIT_ADDR_2      = 16'h0014;  // Out_bit2_reg
parameter  DCS_TRNG_STATE_ADDR_2    = 16'h0018;  // Out_state2
parameter  DCS_TRNG_BIT_ADDR_3      = 16'h001c;  // Out_bit3_reg
parameter  DCS_TRNG_STATE_ADDR_3    = 16'h0020;  // Out_state3    
parameter  DCS_TRNG_BIT_XOR_ADDR    = 16'h0024;  // Out_bit_xor_reg
parameter  DCS_TRNG_STATE_CTRL_ADDR = 16'h0028;  // Out_control

parameter  DCS_TRNG_RESET    = 32'h0280f700;
parameter  DCS_TRNG_ENABLE   = 32'h0280f70b;
parameter  DCS_TRNG_RUN      = 32'h0280f76b;
parameter  DCS_TRNG_RD_EN    = 32'h0280f77b;

//////////////////////////////////////////////////////////////////////
// internal signal
//////////////////////////////////////////////////////////////////////
reg    [2:0]   cur_state;
reg    [2:0]   next_state;


reg    [7:0]   srst_delay_cnt;
reg    [7:0]   trng_rst_cnt;
reg            rd_stat_valid;
reg            trng_data_valid;
wire           srst_cnt_flag;
wire           trng_rst_finish;
reg            trng_rst;

reg  trng_rd_data_s0;
reg  trng_rd_data_s1;
reg  trng_rd_data_s2;
reg  trng_rd_data_s3;
wire trng_rd_data_s;

reg    trng_enable;
reg    trng_run;
reg    trng_rdata_en;
reg    trng_rd_stat_en;

assign SCAN_MODE_O = 1'b0;

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        srst_delay_cnt <= 8'h0;
    end
    else if(~srst_cnt_flag)begin
        srst_delay_cnt <= srst_delay_cnt + 8'h1;
    end
end

assign srst_cnt_flag = &srst_delay_cnt;


always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        trng_rst_cnt  <= 8'h0;
    end
    else if(trng_rst_finish)begin
        trng_rst_cnt  <= trng_rst_cnt;
    end
    else if(~trng_rst)begin
        trng_rst_cnt<= trng_rst_cnt+ 8'h1;
    end
end

assign trng_rst_finish  = &trng_rst_cnt;

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        cur_state  <= 3'h0;
    end
    else begin
        cur_state  <= next_state;
    end
end

always @(*) begin
    next_state = S_IDLE;
    trng_rst   = 1'b0;
    trng_enable  = 1'b0;
    trng_run     = 1'b0;
    trng_rdata_en = 1'b0;
    trng_rd_stat_en = 1'b0;
    case(cur_state)
        S_IDLE : begin
            if(srst_cnt_flag) begin
                next_state = S_RST_TRNG;
                trng_rst   =  1'b1;
            end
        end
        S_RST_TRNG : begin
            if(trng_rst_finish) begin
                next_state   = S_TRNG_EN;
            end
            else begin
                next_state   = S_RST_TRNG;
            end
        end
        S_TRNG_EN : begin
            trng_enable  = 1'b1;
            next_state   = S_TRNG_RUN;
        end
        S_TRNG_RUN : begin
            trng_run     = 1'b1;
            next_state   = S_RD_STAT;
        end
        S_RD_STAT : begin
            if(trng_data_valid) begin
                trng_rdata_en = 1'b1;
                next_state = S_RD_DATA;
            end
            else begin
                trng_rd_stat_en = 1'b1;
                next_state = S_RD_STAT;
            end
        end
        S_RD_DATA : begin
            if(trng_rd_data_s3 ) begin
                next_state = S_RD_STAT;
            end
            else begin
                next_state = S_RD_DATA;
            end
        end
        default: begin
            next_state = S_IDLE;
        end
    endcase
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
    end
    else begin
    end
end



always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        trng_rd_data_s0 <= 1'b0;
        trng_rd_data_s1 <= 1'b0;
        trng_rd_data_s2 <= 1'b0;
        trng_rd_data_s3 <= 1'b0;
    end
    else begin
        trng_rd_data_s0 <= trng_rdata_en;
        trng_rd_data_s1 <= trng_rd_data_s0;
        trng_rd_data_s2 <= trng_rd_data_s1;
        trng_rd_data_s3 <= trng_rd_data_s2;
    end
end

assign trng_rd_data_s = trng_rd_data_s0 || trng_rd_data_s1 || trng_rd_data_s2;



always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        SEL_O  <= 1'b0;
    end
    else if(trng_rst || trng_enable || trng_run || trng_rd_stat_en || trng_rd_data_s) begin
        SEL_O  <= 1'b1;
    end
    else begin
        SEL_O  <= 1'b0;
    end
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        WRITE_O  <= 1'b0;
    end
    else if(trng_rst || trng_enable || trng_run || trng_rd_data_s0 || trng_rd_data_s2) begin
        WRITE_O  <= 1'b1;
    end
    else begin
        WRITE_O  <= 1'b0;
    end
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        ADDR_O <= 32'h0;
    end
    else if(trng_rst || trng_enable || trng_run)  begin
        ADDR_O <= DCS_TRNG_CTRL_ADDR ;
    end
    else if(trng_rd_stat_en)  begin
        ADDR_O <= DCS_TRNG_STATE_CTRL_ADDR;
    end
    else if(trng_rd_data_s0 || trng_rd_data_s2)  begin
        ADDR_O <= DCS_TRNG_CTRL_ADDR ;
    end
    else if(trng_rd_data_s1 )  begin
        ADDR_O <= DCS_TRNG_BIT_XOR_ADDR;
    end
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        WDATA_O <= 32'h0;
    end
    else if(trng_rst)  begin
        WDATA_O <= DCS_TRNG_RESET;
    end
    else if(trng_enable)  begin
        WDATA_O <= DCS_TRNG_ENABLE;
    end
    else if(trng_run)  begin
        WDATA_O <= DCS_TRNG_RUN;
    end
    else if(trng_rd_data_s0)  begin
        WDATA_O <= DCS_TRNG_RD_EN;
    end
    else if(trng_rd_data_s2 )  begin
        WDATA_O <= DCS_TRNG_RUN;
    end
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        rd_stat_valid <= 1'b0;
    end
    else if(SEL_O && (ADDR_O == DCS_TRNG_STATE_CTRL_ADDR)) begin
        rd_stat_valid <= 1'b1;
    end
    else begin
        rd_stat_valid <= 1'b0;
    end
end

always @(posedge CLK_I or negedge RESETN_I) begin
    if(~RESETN_I) begin
        trng_data_valid  <= 1'b0;
    end
    else if(rd_stat_valid &&(RDATA_I[2] == 1'b0))begin
        trng_data_valid  <= 1'b1;
    end
    else begin
        trng_data_valid  <= 1'b0;
    end
end





endmodule
