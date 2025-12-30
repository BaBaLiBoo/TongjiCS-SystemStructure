`timescale 1ns / 1ps

module top_module(
    input           clk,
    input           ena,
    input           rst,
    input  [1:0]    switch,
    output [7:0]    o_seg,
    output [7:0]    o_sel
    );

    wire [31:0] disp_payload;
    wire [31:0] pc_snapshot;
    wire [31:0] instr_snapshot;
    wire [31:0] reg28_snapshot;

    wire        clk_core;
    reg  [20:0] clk_div_counter;

    always@(posedge clk)
        clk_div_counter <= clk_div_counter + 1;
    assign clk_core = clk;
    selector_4_32 sel_display(reg28_snapshot, pc_snapshot, instr_snapshot, 32'b0, switch, disp_payload);
    display_7seg display_inst(clk, rst, 1'b1, disp_payload, o_seg, o_sel);
    processor proc_inst(clk_core, rst, ena, pc_snapshot, instr_snapshot, reg28_snapshot);

endmodule
