`timescale 1ns / 1ps

module divider(
    input           rst_sig,
    input           ena_sig,
    input           sign_flag,
    input [31:0]    op_a,
    input [31:0]    op_b,
    output [31:0]   q_out,
    output [31:0]   r_out
    );

    reg neg_flag;
    reg div_neg_flag;
    reg [63:0] dividend_temp;
    reg [63:0] divisor_temp;

    integer idx;
	
    always@(*) 
    begin
        if(rst_sig) 
        begin
            dividend_temp    <= 0;
            divisor_temp     <= 0;
            neg_flag             <= 0;
            div_neg_flag         <= 0;
        end 
        else if(ena_sig) 
        begin
            if(sign_flag) 
            begin
                dividend_temp = op_a;
                divisor_temp = { op_b, 32'b0 }; 
                for(idx = 0; idx < 32; idx = idx + 1)
                begin
                    dividend_temp = dividend_temp << 1;
                    if(dividend_temp >= divisor_temp)
                    begin
                        dividend_temp = dividend_temp - divisor_temp;
                        dividend_temp = dividend_temp + 1;
                    end
                end
                idx = 0;
            end 
            else 
            begin
                dividend_temp    <= op_a;
                divisor_temp     <= { op_b, 32'b0 };
                neg_flag             <= op_a[31] ^ op_b[31];
                div_neg_flag         <= op_a[31];
                
                if(op_a[31]) 
                begin
					dividend_temp = op_a ^ 32'hffffffff;
					dividend_temp = dividend_temp + 1;
                end
                if(op_b[31]) 
                begin
                    divisor_temp = {op_b ^ 32'hffffffff, 32'b0};
                    divisor_temp = divisor_temp + 64'h0000000100000000;
                end 
                for(idx = 0; idx < 32; idx = idx + 1) 
                begin
                    dividend_temp = dividend_temp << 1;
                    if(dividend_temp >= divisor_temp) 
                    begin
                        dividend_temp = dividend_temp - divisor_temp;
                        dividend_temp = dividend_temp + 1;
                    end
                end
                if(div_neg_flag) 
                begin
                    dividend_temp = dividend_temp ^ 64'hffffffff00000000;
                    dividend_temp = dividend_temp + 64'h0000000100000000;
                end          
                if(neg_flag) 
                begin
                    dividend_temp = dividend_temp ^ 64'h00000000ffffffff;
                    dividend_temp = dividend_temp + 64'h0000000000000001;
                    if(dividend_temp[31:0] == 32'b0) 
                        dividend_temp = dividend_temp - 64'h0000000100000000;

                end
            end
        end
    end
    
	assign q_out = ena_sig ? dividend_temp[31:0] : 32'b0;
    assign r_out = ena_sig ? dividend_temp[63:32]: 32'b0;

endmodule
