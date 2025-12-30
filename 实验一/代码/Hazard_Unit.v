`timescale 1ns / 1ps

module Hazard_Unit (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [4:0]  id_rs_addr_i,
    input  wire [4:0]  id_rt_addr_i,
    input  wire        id_rs_rena_i,
    input  wire        id_rt_rena_i,
    input  wire        ex_wena_i,
    input  wire [4:0]  ex_waddr_i,
    input  wire        mem_wena_i,
    input  wire [4:0]  mem_waddr_i,
    output reg         stall_o
);

    reg stall_counter_r;

    wire ex_hazard_w = ex_wena_i && (ex_waddr_i!= 5'b0) &&
                     ( (id_rs_rena_i && (ex_waddr_i == id_rs_addr_i)) |

| 
                       (id_rt_rena_i && (ex_waddr_i == id_rt_addr_i)) );
            
    wire mem_hazard_w = mem_wena_i && (mem_waddr_i!= 5'b0) &&
                      ( (id_rs_rena_i && (mem_waddr_i == id_rs_addr_i)) |

| 
                        (id_rt_rena_i && (mem_waddr_i == id_rt_addr_i)) );

    always @(negedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            stall_o <= 1'b1; 
            stall_counter_r <= 1'b0;
        end
        else if (stall_counter_r == 1'b1) begin
            stall_o <= 1'b1;
            stall_counter_r <= 1'b0; 
        end
        else begin
            if (ex_hazard_w) begin
                stall_o <= 1'b1;
                stall_counter_r <= 1'b1; 
            end
            else if (mem_hazard_w) begin
                stall_o <= 1'b1;
                stall_counter_r <= 1'b0; 
            end
            else begin
                stall_o <= 1'b0;
                stall_counter_r <= 1'b0;
            end
        end
    end

endmodule