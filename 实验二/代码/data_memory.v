`timescale 1ns / 1ps

module data_memory(
    input 				clk_sig,
    input 				ena_sig,
    input 				wr_en,
    input [1:0] 		wr_sel,
    input [1:0] 		rd_sel, 
    input [31:0] 		data_in,
    input [31:0] 		addr_in,
    output reg [31:0] 	data_out
    );

	reg [31:0] mem_array [2047:0];
	
	wire [9:0] addr_high = (addr_in - 32'h10010000) >> 2;
	wire [1:0] addr_low = (addr_in - 32'h10010000) & 2'b11;

    always@(*) 
	begin
        if(ena_sig && ~wr_en) 
		begin
		case(rd_sel)
			2'b01:
			begin
				data_out <= mem_array[addr_high];
			end
			2'b10:
			begin
				case(addr_low)
					2'b00:data_out <= mem_array[addr_high][15:0];
					2'b10:data_out <= mem_array[addr_high][31:16];
				endcase
			end
			2'b11:
			begin
				case(addr_low)
					2'b00:	data_out <= mem_array[addr_high][7:0];
					2'b01:	data_out <= mem_array[addr_high][15:8];
					2'b10:	data_out <= mem_array[addr_high][23:16];
					2'b11:	data_out <= mem_array[addr_high][31:24];
				endcase
			end
		endcase
        end
    end

    always@(posedge clk_sig) 
	begin
        if(ena_sig) 
		begin
            if(wr_en)
			begin
			case(wr_sel)
                2'b01:
				begin
					mem_array[addr_high] <= data_in; 
				end
                2'b10:
				begin
					case(addr_low)
						2'b00:	mem_array[addr_high][15:0] 	<= data_in[15:0];
						2'b11:	mem_array[addr_high][31:16] <= data_in[15:0];
					endcase
				end
                2'b11:
				begin
					case(addr_low)
						2'b00:	mem_array[addr_high][7:0] 	<= data_in[7:0];
						2'b01:	mem_array[addr_high][15:8] 	<= data_in[7:0];
						2'b10:	mem_array[addr_high][23:16] <= data_in[7:0];
						2'b11:	mem_array[addr_high][31:24] <= data_in[7:0];
					endcase
				end
            endcase
            end
        end
    end
endmodule

module data_extractor(
    input [31:0] 		data_in,
    input [2:0] 		sel_in,
    input 				sign_flag,
    output reg [31:0] 	data_out
    );
	
    always@(*) 
	begin
        case(sel_in)
            3'b010: 	data_out <= { { 24{ sign_flag & data_in[7] } }, data_in[7:0] };
            3'b011: 	data_out <= { 24'b0, data_in[7:0] };
			3'b001: 	data_out <= { { 16{ sign_flag & data_in[15] } }, data_in[15:0] };
            3'b100: 	data_out <= { 16'b0, data_in[15:0] };
            default: 	data_out <= data_in;
        endcase
    end

endmodule
