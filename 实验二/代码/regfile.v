`timescale 1ns / 1ps

module reg_bank(
    input 				clk_sig, 
    input 				rst_sig, 
    input 				wr_en, 
    input 	[4:0]		rs_addr, 
    input 	[4:0]		rt_addr, 
    input 				rs_en,
    input 				rt_en,
    input 	[4:0] 		rd_addr, 
    input 	[31:0] 		rd_data, 
    output reg [31:0] 	rs_data, 
    output reg [31:0] 	rt_data,
    output [31:0] 		reg28_out
    );
    
    reg [31:0] reg_array [31:0];
	integer idx;

	always@(posedge clk_sig or posedge rst_sig) 
    begin
        if(rst_sig) 
		begin
		    for(idx = 0; idx < 32; idx = idx + 1)
                reg_array[idx] <= 32'b0;
        end 
		else 
		begin
            if(wr_en && (rd_addr != 0))
                reg_array[rd_addr] <= rd_data;
        end
	end

	always@(*) 
	begin
	    if (rst_sig) 
			rs_data = 32'b0;
	    else if (rs_addr == 5'b0) 
	  		rs_data = 32'b0;
	    else if((rs_addr == rd_addr) && wr_en && rs_en) 
	  	    rs_data = rd_data;
	    else if(rs_en) 
	        rs_data = reg_array[rs_addr];
	    else 
	        rs_data = 32'bz;
	end

	always@(*) 
    begin
	    if(rst_sig) 
			rt_data = 32'b0;
	    else if(rt_addr == 5'b0) 
	  		rt_data = 32'b0;
        else if((rt_addr == rd_addr) && wr_en && rt_en) 
            rt_data = rd_data;
	    else if(rt_en) 
	        rt_data = reg_array[rt_addr];
	    else 
	        rt_data = 32'bz;
	end

	assign reg28_out = reg_array[28];

endmodule

