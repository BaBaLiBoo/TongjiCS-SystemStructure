`timescale 1ns / 1ps

module Register_File(
    input  wire        clk_i,
    input  wire        rst_i,

    input  wire        rs_rena_i,
    input  wire [4:0]  rs_addr_i,
    output reg  [31:0] rs_data_o,

    input  wire        rt_rena_i,
    input  wire [4:0]  rt_addr_i,
    output reg  [31:0] rt_data_o,

    input  wire        rd_wena_i,
    input  wire [4:0]  rd_addr_i,
    input  wire [31:0] rd_data_i,

    input  wire [31:0] init_floors_i,
    input  wire [31:0] init_resistance_i,

    output wire [31:0] attempt_count_o,
    output wire [31:0] broken_count_o,
    output wire        last_broken_o,
    output wire [31:0] cost_f1_o,
    output wire [31:0] cost_f2_o
);

    reg [31:0] reg_array_r [0:31];
    integer i;
    
    assign attempt_count_o = reg_array_r[4];
    assign broken_count_o  = reg_array_r[5];
    assign last_broken_o   = reg_array_r[6][0]; 
    assign cost_f1_o       = reg_array_r[7];
    assign cost_f2_o       = reg_array_r[8];

    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_array_r[i] <= 32'b0;
            end
            reg_array_r[2] <= init_floors_i;       // $v0 = init floors
            reg_array_r[3] <= init_resistance_i;   // $v1 = init resistance
        end else begin
            if (rd_wena_i && (rd_addr_i != 5'b00000)) begin
                reg_array_r[rd_addr_i] <= rd_data_i;
            end
        end
    end

    always @(*) begin
        if (rs_addr_i == 5'b00000) begin
            rs_data_o = 32'b0;
        end else if (rs_rena_i) begin
            if (rd_wena_i && (rd_addr_i == rs_addr_i) && (rd_addr_i != 5'b00000))
                rs_data_o = rd_data_i;
            else
                rs_data_o = reg_array_r[rs_addr_i];
        end else begin
            rs_data_o = 32'b0;
        end

        if (rt_addr_i == 5'b00000) begin
            rt_data_o = 32'b0;
        end else if (rt_rena_i) begin
            if (rd_wena_i && (rd_addr_i == rt_addr_i) && (rd_addr_i != 5'b00000))
                rt_data_o = rd_data_i;
            else
                rt_data_o = reg_array_r[rt_addr_i];
        end else begin
            rt_data_o = 32'b0;
        end
    end

endmodule
