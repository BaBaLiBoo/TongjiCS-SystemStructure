`timescale 1ns / 1ps

module Stage_MEM (
    input  wire        clk_i,
    input  wire        dmem_ena_i,
    input  wire        dmem_wena_i,
    input  wire [1:0]  dmem_type_i,
    input  wire [31:0] rs_data_i,
    input  wire [31:0] rt_data_i,
    input  wire [4:0]  rd_waddr_i,
    input  wire        rd_sel_i,
    input  wire        rd_wena_i,
    input  wire [31:0] alu_result_i, 
    
    output wire [4:0]  rd_waddr_o,
    output wire        rd_sel_o,
    output wire        rd_wena_o,
    output wire [31:0] alu_result_o,
    output wire [31:0] dmem_data_o
);

    localparam integer DMEM_AW = 11;

    wire [DMEM_AW-1:0] dmem_idx = alu_result_i[DMEM_AW+1 : 2];

    assign rd_waddr_o   = rd_waddr_i;
    assign rd_sel_o     = rd_sel_i;
    assign rd_wena_o    = rd_wena_i;
    assign alu_result_o = alu_result_i;  

    Data_Memory dmem_inst (
       .clk_i     (clk_i),
       .ena_i     (dmem_ena_i),    
       .wena_i    (dmem_wena_i),   
       .addr_i    (dmem_idx),      
       .type_i    (dmem_type_i),   
       .data_in_i (rt_data_i),     
       .data_out_o(dmem_data_o)   
    );

endmodule
