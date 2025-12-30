`timescale 1ns / 1ps

module display_7seg(
    input clk,
	 input reset,
	 input cs,
	 input [31:0] data_in,
	 output [7:0] seg_out,
	 output [7:0] sel_out
    );

    reg [14:0] counter;
	 always @ (posedge clk, posedge reset)
      if (reset)
        counter <= 0;
      else
        counter <= counter + 1'b1;
 
    wire seg_clk = counter[14]; 
	 
	 reg [2:0] seg_addr;
	 
	 always @ (posedge seg_clk, posedge reset)
	   if(reset)
		  seg_addr <= 0;
		else
		  seg_addr <= seg_addr + 1'b1;
		  
	 reg [7:0] sel_reg;
	 
	 always @ (*)
	   case(seg_addr)
		  7 : sel_reg = 8'b01111111;
		  6 : sel_reg = 8'b10111111;
		  5 : sel_reg = 8'b11011111;
		  4 : sel_reg = 8'b11101111;
		  3 : sel_reg = 8'b11110111;
		  2 : sel_reg = 8'b11111011;
		  1 : sel_reg = 8'b11111101;
		  0 : sel_reg = 8'b11111110;
		endcase
	
	 reg [31:0] data_reg;
	 always @ (posedge clk, posedge reset)
	   if(reset)
		  data_reg <= 0;
		else if(cs)
		  data_reg <= data_in;
		  
	 reg [7:0] seg_data;
	 always @ (*)
	   case(seg_addr)
		  0 : seg_data = data_reg[3:0];
		  1 : seg_data = data_reg[7:4];
		  2 : seg_data = data_reg[11:8];
		  3 : seg_data = data_reg[15:12];
		  4 : seg_data = data_reg[19:16];
		  5 : seg_data = data_reg[23:20];
		  6 : seg_data = data_reg[27:24];
		  7 : seg_data = data_reg[31:28];
		endcase
	 
	 reg [7:0] seg_reg;
	 always @ (posedge clk, posedge reset)
	   if(reset)
		  seg_reg <= 8'hff;
		else
		  case(seg_data)
		      4'h0 : seg_reg <= 8'hC0;
              4'h1 : seg_reg <= 8'hF9;
              4'h2 : seg_reg <= 8'hA4;
              4'h3 : seg_reg <= 8'hB0;
              4'h4 : seg_reg <= 8'h99;
              4'h5 : seg_reg <= 8'h92;
              4'h6 : seg_reg <= 8'h82;
              4'h7 : seg_reg <= 8'hF8;
              4'h8 : seg_reg <= 8'h80;
              4'h9 : seg_reg <= 8'h90;
              4'hA : seg_reg <= 8'h88;
              4'hB : seg_reg <= 8'h83;
              4'hC : seg_reg <= 8'hC6;
              4'hD : seg_reg <= 8'hA1;
              4'hE : seg_reg <= 8'h86;
              4'hF : seg_reg <= 8'h8E;
		  endcase
		  
	 assign sel_out = sel_reg;
	 assign seg_out = seg_reg;

endmodule
