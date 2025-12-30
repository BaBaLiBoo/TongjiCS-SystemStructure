`timescale 1ns / 1ps

module Stage_EX (
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
    
    output wire        dmem_ena_o,
    output wire        dmem_wena_o,
    output wire [1:0]  dmem_type_o,
    output wire [31:0] rs_data_o,
    output wire [31:0] rt_data_o,
    output wire [4:0]  rd_waddr_o,
    output wire        rd_sel_o,
    output wire        rd_wena_o,
    output wire [31:0] alu_result_o
);

    wire [31:0] alu_in_a_w;
    wire [31:0] alu_in_b_w;
    wire        zero_w, carry_w, negative_w, overflow_w;

    assign dmem_ena_o  = dmem_ena_i;
    assign dmem_wena_o = dmem_wena_i;
    assign dmem_type_o = dmem_type_i;
    assign rs_data_o   = rs_data_i;
    assign rt_data_o   = rt_data_i;
    assign rd_waddr_o  = rd_waddr_i;
    assign rd_sel_o    = rd_sel_i;
    assign rd_wena_o   = rd_wena_i;
    assign alu_in_a_w = alu_a_sel_i? shamt_i : rs_data_i;
    assign alu_in_b_w = alu_b_sel_i? immed_i : rt_data_i;

    ALU_Core alu_inst (
       .a_i(alu_in_a_w),
       .b_i(alu_in_b_w),
       .aluc_i(alu_sel_i),
       .y_o(alu_result_o),
       .zero_o(zero_w),
       .carry_o(carry_w),
       .negative_o(negative_w),
       .overflow_o(overflow_w)
    );

endmodule
