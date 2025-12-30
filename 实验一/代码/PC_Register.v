`timescale 1ns / 1ps

module PC_Register (
    input  wire        clk_i,
    input  wire        ena_i,
    input  wire        rst_i,
    input  wire        stall_i,
    input  wire [31:0] pc_in_i,
    output reg  [31:0] pc_out_o
);

    parameter PC_START_ADDR = 32'h00400000;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            pc_out_o <= PC_START_ADDR;
        end
        else if (ena_i) begin
            if (stall_i) begin
                // 停顿, PC 保持不变
                pc_out_o <= pc_out_o;
            end
            else begin
                // 正常更新
                pc_out_o <= pc_in_i;
            end
        end
        else begin
            pc_out_o <= 32'bz; // 高阻态
        end
    end

endmodule
