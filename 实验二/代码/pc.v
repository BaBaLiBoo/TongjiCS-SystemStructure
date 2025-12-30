`timescale 1ns / 1ps

module program_counter(
    input               clk_in,
    input               rst_in,
    input               ena_in,
    input               stall_in,
    input  [31:0]       pc_in,
    output reg [31:0]   pc_out
    );

    always@(posedge clk_in or posedge rst_in)
    begin
        if(rst_in) 
            pc_out <= 32'h00400000;
        else if(~stall_in) 
        begin
            if(ena_in) 
                pc_out <= pc_in;
        end
    end

endmodule