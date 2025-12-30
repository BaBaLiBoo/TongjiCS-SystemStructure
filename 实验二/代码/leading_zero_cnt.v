`timescale 1ns / 1ps

module leading_zero_cnt(
    input [31:0] 		data_in,
    input 				enable,
    output reg [31:0] 	count_out
);
	
	always@(*) 
	begin
		if(enable) 
		begin
			casex(data_in)
				32'b1xxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd0;
				32'b01xxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd1;
				32'b001xxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd2;
				32'b0001xxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd3;
				32'b00001xxx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd4;
				32'b000001xx_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd5;
				32'b0000001x_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd6;
				32'b00000001_xxxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd7;
				32'b00000000_1xxxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd8;
				32'b00000000_01xxxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd9;
				32'b00000000_001xxxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd10;
				32'b00000000_0001xxxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd11;
				32'b00000000_00001xxx_xxxxxxxx_xxxxxxxx : count_out <= 32'd12;
				32'b00000000_000001xx_xxxxxxxx_xxxxxxxx : count_out <= 32'd13;
				32'b00000000_0000001x_xxxxxxxx_xxxxxxxx : count_out <= 32'd14;
				32'b00000000_00000001_xxxxxxxx_xxxxxxxx : count_out <= 32'd15;
				32'b00000000_00000000_1xxxxxxx_xxxxxxxx : count_out <= 32'd16;
				32'b00000000_00000000_01xxxxxx_xxxxxxxx : count_out <= 32'd17;
				32'b00000000_00000000_001xxxxx_xxxxxxxx : count_out <= 32'd18;
				32'b00000000_00000000_0001xxxx_xxxxxxxx : count_out <= 32'd19;
				32'b00000000_00000000_00001xxx_xxxxxxxx : count_out <= 32'd20;
				32'b00000000_00000000_000001xx_xxxxxxxx : count_out <= 32'd21;
				32'b00000000_00000000_0000001x_xxxxxxxx : count_out <= 32'd22;
				32'b00000000_00000000_00000001_xxxxxxxx : count_out <= 32'd23;
				32'b00000000_00000000_00000000_1xxxxxxx : count_out <= 32'd24;
				32'b00000000_00000000_00000000_01xxxxxx : count_out <= 32'd25;
				32'b00000000_00000000_00000000_001xxxxx : count_out <= 32'd26;
				32'b00000000_00000000_00000000_0001xxxx : count_out <= 32'd27;
				32'b00000000_00000000_00000000_00001xxx : count_out <= 32'd28;
				32'b00000000_00000000_00000000_000001xx : count_out <= 32'd29;
				32'b00000000_00000000_00000000_0000001x : count_out <= 32'd30;
				32'b00000000_00000000_00000000_00000001 : count_out <= 32'd31;
				32'b00000000_00000000_00000000_00000000 : count_out <= 32'd32;
				default:								  count_out <= 32'dz;
			endcase
		end
    end
	
endmodule


