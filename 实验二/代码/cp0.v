`include "mips_def.vh"
`timescale 1ns / 1ps

module coprocessor0(
    input           clk_sig,
    input           rst_sig,
    input           mfc0_flag,
    input           mtc0_flag,
    input   [31:0]  pc_val,
    input   [4:0]   reg_idx,
    input   [31:0]  wr_data,
    input           exc_flag,
    input           eret_flag,
    input   [4:0]   cause_val,
    output  [31:0]  rd_data,
    output  [31:0]  status_out,
    output  [31:0]  eaddr_out
);

    reg [31:0] cp0_array [31:0];
    integer idx;

    always@(posedge clk_sig or posedge rst_sig)
    begin
        if(rst_sig)
        begin
            for(idx = 0; idx < 32; idx = idx + 1)
                cp0_array[idx] <= 32'b0;
        end
        else if(mtc0_flag)
        begin
            cp0_array[reg_idx] <= wr_data;
        end
        else if(exc_flag)
        begin
            cp0_array[`STATUS] <= { cp0_array[`STATUS][26:0], 5'b0 };
            cp0_array[`CAUSE]  <= { 25'd0, cause_val, 2'd0 };
            cp0_array[`EPC]    <= pc_val;
        end
        else if(eret_flag)
        begin
            cp0_array[`STATUS] <= { 5'b0, cp0_array[`STATUS][31:5] };
        end    
    end
   
    
    assign status_out  = cp0_array[`STATUS];
    assign eaddr_out   = eret_flag ? cp0_array[`EPC] : 32'h00400004;  
    assign rd_data   = mfc0_flag ? cp0_array[reg_idx] : 32'bz;

endmodule
