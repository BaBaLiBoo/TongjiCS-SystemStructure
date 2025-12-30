`timescale 1ns / 1ps

module Register_MEM_WB (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [4:0]  rd_waddr_i,
    input  wire        rd_sel_i,
    input  wire        rd_wena_i,
    input  wire [31:0] alu_result_i,
    input  wire [31:0] dmem_data_i,
    
    output reg  [4:0]  rd_waddr_o,
    output reg         rd_wena_o,
    output reg         rd_sel_o,
    output reg  [31:0] alu_result_o,
    output reg  [31:0] dmem_data_o
);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1) begin
            rd_waddr_o   <= 5'b0;
            rd_sel_o     <= 1'b0;
            rd_wena_o    <= 1'b0;
            alu_result_o <= 32'b0;
            dmem_data_o  <= 32'b0;
        end 
        else begin
            rd_waddr_o   <= rd_waddr_i;
            rd_sel_o     <= rd_sel_i;
            rd_wena_o    <= rd_wena_i;
            alu_result_o <= alu_result_i;
            dmem_data_o  <= dmem_data_i;
        end
    end

endmodule
