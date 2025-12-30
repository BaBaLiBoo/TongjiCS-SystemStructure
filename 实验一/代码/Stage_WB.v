`timescale 1ns / 1ps

module Stage_WB (
    input  wire [4:0]  rd_waddr_i,
    input  wire        rd_wena_i,
    input  wire        rd_sel_i, 
    input  wire [31:0] alu_result_i,
    input  wire [31:0] dmem_data_i,
    
    output wire [4:0]  rd_waddr_o,
    output wire        rd_wena_o,
    output wire [31:0] rd_wdata_o  
);

    assign rd_waddr_o = rd_waddr_i;
    assign rd_wena_o  = rd_wena_i;
    assign rd_wdata_o = (rd_sel_i == 1'b0)? dmem_data_i  
                                          : alu_result_i; 
endmodule
