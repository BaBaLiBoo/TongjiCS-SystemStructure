`timescale 1ns / 1ps

module Register_IF_ID (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire        stall_i,  // 停顿信号
    input  wire        branch_i, // 分支刷新信号
    input  wire [31:0] npc_i,
    input  wire [31:0] instruction_i,
    
    output reg  [31:0] npc_o,
    output reg  [31:0] instruction_o
);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            npc_o <= 32'b0;
            instruction_o <= 32'b0;
        end 
        else if (stall_i) begin
            // 停顿
            if (branch_i) begin
                npc_o <= 32'b0;
                instruction_o <= 32'b0;
            end
            else begin
                // 保持不变
                npc_o <= npc_o;
                instruction_o <= instruction_o;
            end
        end 
        else if (branch_i) begin
            // 分支刷新
            npc_o <= 32'b0;
            instruction_o <= 32'b0; // 注入 nop
        end
        else begin
            // 正常流动
            npc_o <= npc_i;
            instruction_o <= instruction_i;
        end
    end

endmodule