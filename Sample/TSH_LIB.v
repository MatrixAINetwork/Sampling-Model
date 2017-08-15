//////////////////////////////////////////////////////////////////////
module TSH_BUF(input A , output X);

//`ifndef SYNTHESIS
//   assign #1 X = A;
`define FPGA
        LUT6 #(  
          .INIT(64'hffffffff00000000) 
          ) LUT6_inst_tsh_buf (
          .O(X_TMP), 
          .I0(), 
          .I1(), 
          .I2(), 
          .I3(), 
          .I4(), 
          .I5(A) 
          );
assign #1 X= X_TMP;
//   assign #1 X = A;
//`else
//   SEP_BUF_2 SEP_BUF_2(.A(A),.X(X));
//`endif

endmodule

//////////////////////////////////////////////////////////////////////
module TSH_MUX2(output X,input S,input D0,input D1);

//`ifndef SYNTHESIS
//   assign #1 X = S ? D1 : D0;
//`define FPGA
//        LUT6 #(  
//          .INIT(64'hffff0000ff00ff00) 
//          ) LUT6_inst_tsh_mux (
//          .O(X_TMP), 
//          .I0(), 
//          .I1(), 
//          .I2(), 
//          .I3(D0), 
//          .I4(D1), 
//          .I5(S) 
//          );
//
//assign #1 X= X_TMP;
   assign #1 X = S ? D1 : D0;
//`else
//   SEP_MUX2_2 SEP_MUX2_2(.X(X),.S(S),.D0(D0),D1(D1));
//`endif
endmodule

//////////////////////////////////////////////////////////////////////
module TSH_RO_AN2 (input A1, input A2, output X);

//`ifndef SYNTHESIS
//   assign #1 X = A1 & A2;
//`define FPGA
//        LUT6 #(  
//          .INIT(64'hffff000000000000) 
//          ) LUT6_inst_an2 (
//          .O(X_TMP), 
//          .I0(), 
//          .I1(), 
//          .I2(), 
//          .I3(), 
//          .I4(A1), 
//          .I5(A2) 
//          );
//assign #1 X= X_TMP;
   assign #1 X = A1 & A2;
//`else
//   SEP_AN2_S_4 SEP_AN2_S_4(.A1(A1),.A2(A2),.X(X));
//`endif

endmodule

//////////////////////////////////////////////////////////////////////
module TSH_RO_INV (input A, output X);

//`ifndef SYNTHESIS
//   assign #1 X =  !A;
//`define FPGA
//        LUT6 #(  
//          .INIT(64'h00000000ffffffff) 
//          ) LUT6_inst_inv (
//          .O(X_TMP), 
//          .I0(), 
//          .I1(), 
//          .I2(), 
//          .I3(), 
//          .I4(), 
//          .I5(A) 
//          );
//assign #1 X= X_TMP;
   assign #1 X =  !A;
//`else
//   SEP_INV_S_4 SEP_INV_S_4 (.A(andout),.X(a[0]));
//`endif

endmodule

//////////////////////////////////////////////////////////////////////
module TSH_RO_DEL(input A, output X);

//`ifndef SYNTHESIS
//   reg X_TMP;
//   always #(100+$random%15) X_TMP = A;
//   assign X = X_TMP;
//`define FPGA
reg X_TMP1;
        LUT6 #(  
          .INIT(64'hffffffff00000000) 
          //.INIT(64'h00000000ffffffff) 
          ) LUT6_inst_del (
          .O(X_TMP0), 
          .I0(), 
          .I1(), 
          .I2(), 
          .I3(), 
          .I4(), 
          .I5(A) 
          );
always #(100+$random%15) X_TMP1= X_TMP0;
assign #1 X= X_TMP1;
//`else
//    SEP_DEL_L6_8  SEP_DEL_L6_8(.A(a[i]),.X(a[i+1]));
//`endif
endmodule

//////////////////////////////////////////////////////////////////////
module TSH_RO_BUF(input A, output X);

//`ifndef SYNTHESIS
//   assign #1 X = A;
//`define FPGA
        LUT6 #(  
          .INIT(64'hffffffff00000000) 
          ) LUT6_inst_buf (
          .O(X_TMP), 
          .I0(), 
          .I1(), 
          .I2(), 
          .I3(), 
          .I4(), 
          .I5(A) 
          );
assign #1 X= X_TMP;
//   assign #1 X = A;
//`else
//   SEP_BUF_S_10 SEP_BUF_S_10(.A(a[stage-1]),.X(ro_out));
//`endif

endmodule


