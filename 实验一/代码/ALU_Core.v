`timescale 1ns / 1ps

module ALU_Core (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [3:0]  aluc_i,
    
    output reg  [31:0] y_o,    
    output wire        zero_o,
    output wire        carry_o,
    output wire        negative_o,
    output wire        overflow_o
);

    wire signed [31:0] signed_a_w = a_i;
    wire signed [31:0] signed_b_w = b_i;
    
    reg  [32:0] result_r;

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_ADDU = 4'b0001;
    localparam ALU_SUB  = 4'b0010;
    localparam ALU_SUBU = 4'b0011;
    localparam ALU_AND  = 4'b0100;
    localparam ALU_OR   = 4'b0101;
    localparam ALU_XOR  = 4'b0110;
    localparam ALU_NOR  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_SLL  = 4'b1010;
    localparam ALU_SRL  = 4'b1011;
    localparam ALU_SRA  = 4'b1100;
    localparam ALU_LUI  = 4'b1101;

    always @(*) begin
        case (aluc_i)
            ALU_ADD:  result_r = signed_a_w + signed_b_w;
            ALU_ADDU: result_r = a_i + b_i;
            ALU_SUB:  result_r = signed_a_w - signed_b_w;
            ALU_SUBU: result_r = a_i - b_i;
            ALU_AND:  result_r = {1'b0, a_i & b_i};
            ALU_OR:   result_r = {1'b0, a_i | b_i};
            ALU_XOR:  result_r = {1'b0, a_i ^ b_i};
            ALU_NOR:  result_r = {1'b0, ~(a_i | b_i)};
            ALU_SLT:  result_r = {32'b0, (signed_a_w < signed_b_w)};
            ALU_SLTU: result_r = {32'b0, (a_i < b_i)};
            ALU_SLL:  result_r = {1'b0, b_i << a_i[4:0]};
            ALU_SRL:  result_r = {1'b0, b_i >> a_i[4:0]};
            ALU_SRA:  result_r = {1'b0, signed_b_w >>> a_i[4:0]};
            ALU_LUI:  result_r = {1'b0, {b_i[15:0], 16'b0}};
            default:  result_r = 33'bx; 
        endcase
        
        y_o = result_r[31:0];
    end

    assign zero_o     = (y_o == 32'b0);
    assign negative_o = y_o;
    
    assign carry_o    = ( (aluc_i == ALU_ADDU) |

| (aluc_i == ALU_SUBU) )? result_r : 1'b0;
    
    wire overflow_add = (a_i == b_i) && (y_o!= a_i);
    wire overflow_sub = (a_i!= b_i) && (y_o!= a_i);
    
    assign overflow_o = ( (aluc_i == ALU_ADD) && overflow_add ) ||
                        ( (aluc_i == ALU_SUB) && overflow_sub );

endmodule