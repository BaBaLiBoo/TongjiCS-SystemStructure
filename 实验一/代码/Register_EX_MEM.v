`timescale 1ns / 1ps

module Register_EX_MEM (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire        dmem_ena_i,
    input  wire        dmem_wena_i,
    input  wire [1:0]  dmem_type_i,
    input  wire [31:0] rs_data_i,
    input  wire [31:0] rt_data_i,
    input  wire [4:0]  rd_waddr_i,
    input  wire        rd_sel_i,
    input  wire        rd_wena_i,
    input  wire [31:0] alu_result_i,
    
    output reg         dmem_ena_o,
    output reg         dmem_wena_o,
    output reg  [1:0]  dmem_type_o,
    output reg  [31:0] rs_data_o,
    output reg  [31:0] rt_data_o,
    output reg  [4:0]  rd_waddr_o,
    output reg         rd_sel_o,
    output reg         rd_wena_o,
    output reg  [31:0] alu_result_o
);

    always @(posedge clk_i) begin
        if (rst_i) begin
            dmem_ena_o   <= 1'b0;
            dmem_wena_o  <= 1'b0;
            dmem_type_o  <= 2'b0;
            rs_data_o    <= 32'b0;
            rt_data_o    <= 32'b0;
            rd_waddr_o   <= 5'b0;
            rd_sel_o     <= 1'b0;
            rd_wena_o    <= 1'b0;
            alu_result_o <= 32'b0;
        end 
        else begin
            dmem_ena_o   <= dmem_ena_i;
            dmem_wena_o  <= dmem_wena_i;
            dmem_type_o  <= dmem_type_i;
            rs_data_o    <= rs_data_i;
            rt_data_o    <= rt_data_i;
            rd_waddr_o   <= rd_waddr_i;
            rd_sel_o     <= rd_sel_i;
            rd_wena_o    <= rd_wena_i;
            alu_result_o <= alu_result_i;
        end
    end
endmodule
