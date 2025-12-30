`timescale 1ns / 1ps

module arithmetic_unit (
    input [31:0]    op_a,    
    input [31:0]    op_b, 
    input [3:0]     ctrl,
    output [31:0]   result,
    output          zero_flag,
    output          carry_flag, 
    output          neg_flag, 
    output          ovf_flag
    );

    wire signed [31:0] sig_a, sig_b;
    reg [32:0] res;
    
    assign sig_a = op_a;
    assign sig_b = op_b;

    always@(*) 
    begin
        case(ctrl)
            4'b0000: res = op_a + op_b;
            4'b0010: res = sig_a + sig_b;
            4'b0001: res = op_a - op_b;
            4'b0011: res = sig_a - sig_b;
            4'b0100: res = op_a & op_b;
            4'b0101: res = op_a | op_b;
            4'b0110: res = op_a ^ op_b;
            4'b0111: res = ~(op_a | op_b);
            4'b1000: res = { op_b[15:0], 16'b0 };
            4'b1001: res = { op_b[15:0], 16'b0 };
            4'b1011: res = (sig_a < sig_b);
            4'b1010: res = (op_a < op_b);
            4'b1100:
            begin
                if(op_a == 0) 
                    { res[31:0], res[32] } = { sig_b, 1'b0 };
                else
                    { res[31:0], res[32] } = sig_b >>> (op_a - 1);
            end
            4'b1110: res = op_b << op_a;
            4'b1111: res = op_b << op_a;
            4'b1101:
            begin
                if(op_a == 0) 
                    { res[31:0], res[32] } = { op_b, 1'b0 };
                else
                    { res[31:0], res[32] } = op_b >> (op_a - 1);
            end
        endcase
    end
    
    assign result     = res[31:0];

    assign zero_flag  = (res == 32'b0) ? 1'b1 : 1'b0;
    assign carry_flag = res[32];
    assign ovf_flag   = res[32] ^ res[31];
    assign neg_flag   = res[31];
    
endmodule