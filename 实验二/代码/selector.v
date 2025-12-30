`timescale 1ns / 1ps

module selector_2_5(
    input [4:0]         in0,
    input [4:0]         in1,
    input               sel_sig,
    output reg [4:0]    out_val
    );
	
    always@(*) 
    begin
        case(sel_sig)
            1'b0: out_val <= in0;
            1'b1: out_val <= in1;
        endcase
    end
	
endmodule

module selector_2_32(
    input [31:0]        in0,
    input [31:0]        in1,
    input               sel_sig,
    output reg [31:0]   out_val
    );
	
    always@(*) 
    begin
        case(sel_sig)
            1'b0: out_val <= in0;
            1'b1: out_val <= in1;
        endcase
    end
	
endmodule

module selector_4_32(
    input   [31:0]      in0,
    input   [31:0]      in1,
    input   [31:0]      in2,
    input   [31:0]      in3,
    input   [1:0]       sel_sig,
    output reg [31:0]   out_val
    );
	
    always@(*) 
    begin
        case(sel_sig)
            2'b00:      out_val <= in0;
            2'b01:      out_val <= in1;
            2'b10:      out_val <= in2;
            2'b11:      out_val <= in3;
        endcase
   end

endmodule

module selector_8_32(
    input   [31:0]      in0,
    input   [31:0]      in1,
    input   [31:0]      in2,
    input   [31:0]      in3,
    input   [31:0]      in4,
    input   [31:0]      in5,
    input   [31:0]      in6,
    input   [31:0]      in7,
    input   [2:0]       sel_sig,
    output reg [31:0]   out_val
    ); 
	
    always@(*) 
    begin
        case(sel_sig)
            3'b000:     out_val <= in0;
            3'b001:     out_val <= in1;
            3'b010:     out_val <= in2;
            3'b011:     out_val <= in3;
            3'b100:     out_val <= in4;
            3'b101:     out_val <= in5;
            3'b110:     out_val <= in6;
            3'b111:     out_val <= in7;
        endcase
    end
	
endmodule
