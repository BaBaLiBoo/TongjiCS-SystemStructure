`timescale 1ns / 1ps

module Register_ID_EX (
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
    input  wire [31:0] immed_i,
    input  wire [31:0] shamt_i,
    input  wire        alu_a_sel_i,
    input  wire        alu_b_sel_i,
    input  wire [3:0]  alu_sel_i,
    input  wire        stall_i,
    
    output reg         dmem_ena_o,
    output reg         dmem_wena_o,
    output reg  [1:0]  dmem_type_o,
    output reg  [31:0] rs_data_o,
    output reg  [31:0] rt_data_o,
    output reg  [4:0]  rd_waddr_o,
    output reg         rd_sel_o,
    output reg         rd_wena_o,
    output reg  [31:0] immed_o,
    output reg  [31:0] shamt_o,
    output reg         alu_a_sel_o,
    output reg         alu_b_sel_o,
    output reg  [3:0]  alu_sel_o
);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i |

| stall_i) begin
            dmem_ena_o  <= 1'b0;
            dmem_wena_o <= 1'b0;
            dmem_type_o <= 2'b0;
            rs_data_o   <= 32'b0;
            rt_data_o   <= 32'b0;
            rd_waddr_o  <= 5'b0;
            rd_sel_o    <= 1'b0;
            rd_wena_o   <= 1'b0;
            immed_o     <= 32'b0;
            shamt_o     <= 32'b0;
            alu_a_sel_o <= 1'b0;
            alu_b_sel_o <= 1'b0;
            alu_sel_o   <= 4'b0;
        end
        else begin
            dmem_ena_o  <= dmem_ena_i;
            dmem_wena_o <= dmem_wena_i;
            dmem_type_o <= dmem_type_i;
            rs_data_o   <= rs_data_i;
            rt_data_o   <= rt_data_i;
            rd_waddr_o  <= rd_waddr_i;
            rd_sel_o    <= rd_sel_i;
            rd_wena_o   <= rd_wena_i;
            immed_o     <= immed_i;
            shamt_o     <= shamt_i;
            alu_a_sel_o <= alu_a_sel_i;
            alu_b_sel_o <= alu_b_sel_i;
            alu_sel_o   <= alu_sel_i;
        end
    end

endmodule