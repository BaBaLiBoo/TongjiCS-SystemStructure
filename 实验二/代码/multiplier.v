`timescale 1ns / 1ps

module multiplier(  
    input           rst_sig,
    input           ena_sig,     
    input           sign_flag, 
    input [31:0]    op_a,
    input [31:0]    op_b,
    output [31:0]   hi_out,
    output [31:0]   lo_out
    );

	reg [31:0] a_temp;
	reg [31:0] b_temp;
    reg [63:0] res_temp;
    reg [63:0] result;
    reg neg_flag;

    integer idx;
	
    always@(*) 
    begin
        if(rst_sig) 
        begin
		    a_temp   <= 0;
            b_temp   <= 0;
            result     <= 0;
            neg_flag     <= 0;
        end 
        else if(ena_sig) 
        begin
            if(op_a == 0 || op_b == 0) 
            begin
                result <= 0;
            end 
            else if(~sign_flag) 
            begin
                result = 0;
                for(idx = 0; idx < 32; idx = idx + 1) 
                begin
                    res_temp = op_b[idx] ?({ 32'b0, op_a } << idx) : 64'b0;
                    result = result + res_temp;       
                end
            end 
            else 
            begin
                result = 0;
                neg_flag = op_a[31] ^ op_b[31];
                a_temp = op_a;
                b_temp = op_b;
                if(op_a[31]) 
                begin
                    a_temp = op_a ^ 32'hffffffff;
                    a_temp = a_temp + 1;
                end
                if(op_b[31]) 
                begin
                    b_temp = op_b ^ 32'hffffffff;
                    b_temp = b_temp + 1;
                end
                for(idx = 0; idx < 32; idx = idx + 1) 
                begin
                    res_temp = b_temp[idx] ?({ 32'b0, a_temp } << idx):64'b0;
                    result = result + res_temp;       
                end
                if(neg_flag) 
                begin
                    result = result ^ 64'hffffffffffffffff;
                    result = result + 1;
                end
            end
        end
    end

	assign lo_out = ena_sig ? result[31:0]  : 32'b0;
    assign hi_out = ena_sig ? result[63:32] : 32'b0;
    
endmodule
