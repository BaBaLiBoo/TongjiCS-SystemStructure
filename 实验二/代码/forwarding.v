`include "mips_def.vh"
`timescale 1ns / 1ps

module data_forward(
    input               clk_sig,
    input               rst_sig,
    input [5:0]         opcode,
    input [5:0]         func_code,
    input               rs_rena,
    input               rt_rena,
    input [4:0]         rs_idx,
    input [4:0]         rt_idx,

    input [5:0]         exe_opcode,
    input [5:0]         exe_func_code,
    input [31:0]        exe_hi_data,
    input [31:0]        exe_lo_data,
    input [31:0]        exe_rd_data,
    input               exe_hi_wena,
    input               exe_lo_wena,
    input               exe_rd_wena,
    input [4:0]         exe_rd_idx,

    input [31:0]        mem_hi_data,
    input [31:0]        mem_lo_data,
    input [31:0]        mem_rd_data,
    input               mem_hi_wena,
    input               mem_lo_wena,
    input               mem_rd_wena,
    input [4:0]         mem_rd_idx,

    output reg          stall_out,
    output reg          forward_out,
    output reg          is_rs_out,
    output reg          is_rt_out,
    output reg [31:0]   rs_data_out,
    output reg [31:0]   rt_data_out,
    output reg [31:0]   hi_data_out,
    output reg [31:0]   lo_data_out
    );


    always@(negedge clk_sig or posedge rst_sig) 
    begin
        if(rst_sig) 
        begin
            stall_out       <= 1'b0;
            rs_data_out     <= 32'b0;
            rt_data_out     <= 32'b0;
            hi_data_out     <= 32'b0;
            lo_data_out     <= 32'b0;
            forward_out  <= 1'b0;
            is_rs_out       <= 1'b0;
            is_rt_out       <= 1'b0;
        end 
        else if(stall_out) 
        begin
            stall_out <= 1'b0;
            if(is_rs_out) 
                rs_data_out <= mem_rd_data;
            else if(is_rt_out)
                rt_data_out <= mem_rd_data;
        end 
        else if(~stall_out) 
        begin
            forward_out = 0;
            is_rs_out = 0;
            is_rt_out = 0;
            if(opcode == `OPC_MFHI && func_code == `FNC_MFHI) 
            begin
                if(exe_hi_wena) 
                begin
                    hi_data_out     <= exe_hi_data;
                    forward_out  <= 1'b1;
                end 
                else if(mem_hi_wena) 
                begin
                    hi_data_out     <= mem_hi_data;
                    forward_out  <= 1'b1;
                end
            end 
            else if(opcode == `OPC_MFLO && func_code == `FNC_MFLO) 
            begin
                if(exe_lo_wena) 
                begin
                    lo_data_out     <= exe_lo_data;
                    forward_out  <= 1'b1;
                end 
                else if(mem_lo_wena) 
                begin
                    lo_data_out     <= mem_lo_data;
                    forward_out  <= 1'b1;
                end
            end 
            else 
            begin
                if(exe_rd_wena && rs_rena && exe_rd_idx == rs_idx) 
                begin
                    if(exe_opcode == `OPC_LW || exe_opcode == `OPC_LH || exe_opcode == `OPC_LHU || exe_opcode == `OPC_LB || exe_opcode == `OPC_LBU) 
                    begin
                        is_rs_out       <= 1'b1;
                        stall_out       <= 1'b1;
                        forward_out  <= 1'b1;
                    end
                    else 
                    begin
                        is_rs_out       <= 1'b1;
                        rs_data_out     <= exe_rd_data;
                        forward_out  <= 1'b1;
                    end
                end
                else if(mem_rd_wena && rs_rena && mem_rd_idx == rs_idx) 
                begin
                    is_rs_out       <= 1'b1;
                    rs_data_out     <= mem_rd_data;
                    forward_out  <= 1'b1;
                end
                if(exe_rd_wena && rt_rena && exe_rd_idx == rt_idx) 
                begin
                    if(exe_opcode == `OPC_LW || exe_opcode == `OPC_LH || exe_opcode == `OPC_LHU || exe_opcode == `OPC_LB || exe_opcode == `OPC_LBU) 
                    begin
                        is_rt_out       <= 1'b1;
                        stall_out       <= 1'b1;
                        forward_out  <= 1'b1;
                    end 
                    else 
                    begin
                        is_rt_out       <= 1'b1;
                        rt_data_out     <= exe_rd_data;
                        forward_out  <= 1'b1;
                    end
                end 
                else if(mem_rd_wena && rt_rena && mem_rd_idx == rt_idx) 
                begin
                    is_rt_out       <= 1'b1;
                    rt_data_out     <= mem_rd_data;
                    forward_out  <= 1'b1;
                end
            end
        end
	end      

endmodule