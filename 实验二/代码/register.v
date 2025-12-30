`timescale 1ns / 1ps

module reg_storage(
    input               clk_sig, 
    input               rst_sig, 
    input               wr_en, 
    input [31:0]        data_in, 
    output reg [31:0]   data_out 
    );
	
    always@(negedge clk_sig or posedge rst_sig)
    begin
        if(rst_sig) 
            data_out <= 32'b0;
        else if(wr_en) 
            data_out <= data_in;
    end

endmodule