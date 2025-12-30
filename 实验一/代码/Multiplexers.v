`timescale 1ns / 1ps

module Mux_4x5 (
    input  wire [4:0]  d0_i,
    input  wire [4:0]  d1_i,
    input  wire [4:0]  d2_i,
    input  wire [4:0]  d3_i,
    input  wire [1:0]  sel_i,
    output reg  [4:0]  y_o
);

    always @(*) begin
        case (sel_i)
            2'b00:  y_o = d0_i;
            2'b01:  y_o = d1_i;
            2'b10:  y_o = d2_i;
            2'b11:  y_o = d3_i;
            default: y_o = 5'bx;
        endcase
    end
endmodule

module Mux_4x32 (
    input  wire [31:0] d0_i,
    input  wire [31:0] d1_i,
    input  wire [31:0] d2_i,
    input  wire [31:0] d3_i,
    input  wire [1:0]  sel_i,
    output reg  [31:0] y_o
);

    always @(*) begin
        case (sel_i)
            2'b00:  y_o = d0_i;
            2'b01:  y_o = d1_i;
            2'b10:  y_o = d2_i;
            2'b11:  y_o = d3_i;
            default: y_o = 32'bx;
        endcase
    end
endmodule