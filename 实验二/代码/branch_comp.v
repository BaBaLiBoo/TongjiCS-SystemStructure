`include "mips_def.vh"
`timescale 1ns / 1ps

module branch_comp(
    input 			clk_in,
    input 			rst_in,
    input 	[31:0] 	val_a, 
    input 	[31:0] 	val_b,
    input 	[5:0] 	opcode,
    input 	[5:0] 	func_code,
    input 			exc_flag,
    output reg 		branch_out 
    );
	
	always@(*) 
	begin
	    if(rst_in)
	        branch_out <= 1'b0;
		else if(opcode == `OPC_BEQ) 
			branch_out <= (val_a == val_b);
	    else if(opcode == `OPC_BNE) 
			branch_out <= (val_a != val_b);
		else if(opcode == `OPC_BGEZ) 
			branch_out <= (val_a >= 0);
	    else if(opcode == `OPC_J)
			branch_out <= 1'b1;
	    else if(opcode == `OPC_JR && func_code == `FNC_JR)
            branch_out <= 1'b1;
	    else if(opcode == `OPC_JAL)
	        branch_out <= 1'b1;
        else if(opcode == `OPC_JALR && func_code == `FNC_JALR)
            branch_out <= 1'b1;
		else if(opcode == `OPC_TEQ && func_code == `FNC_TEQ)
			branch_out <= (val_a == val_b);
        else if(exc_flag)
            branch_out <= 1'b1;
        else
            branch_out <= 1'b0;
	end
	
endmodule
