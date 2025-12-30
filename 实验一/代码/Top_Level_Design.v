`timescale 1ns / 1ps

module Top_Level_Design (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [15:0] in_data_i,
    input  wire        is_init_floors_i,
    input  wire        is_init_resistance_i,
    
    output wire [7:0]  o_seg_o,
    output wire [7:0]  o_sel_o,
    output wire        last_broken_o
);

    wire [31:0] pc_debug_w;
    wire [31:0] instruction_debug_w;
    
    reg  [15:0] init_floors_r;
    reg  [15:0] init_resistance_r;
    
    wire [31:0] attempt_count_w;
    wire [31:0] broken_count_w;
    
    wire [31:0] cost_f1_w;
    wire [31:0] cost_f2_w;
    
    wire        new_clk_w;

    Clock_Manager #(.k(4) ) clk_divider_inst (
       .clk_i(clk_i),
       .clk_o(new_clk_w)
    );

    always @(posedge clk_i) begin
        if (is_init_floors_i)
            init_floors_r <= in_data_i;
        else if (is_init_resistance_i)
            init_resistance_r <= in_data_i;
    end

    CPU_Wrapper cpu_core_inst (
       .clk_i(new_clk_w),
       .rst_i(rst_i),
       .init_floors_i({16'b0, init_floors_r}),
       .init_resistance_i({16'b0, init_resistance_r}),
        
       .pc_o(pc_debug_w),
       .instruction_o(instruction_debug_w),
        
       .attempt_count_o(attempt_count_w),
       .broken_count_o(broken_count_w),
       .last_broken_o(last_broken_o),
        
       .cost_f1_o(cost_f1_w),
       .cost_f2_o(cost_f2_w)
    );

    Display_Driver seg7_driver_inst (
       .clk_i(clk_i),
       .reset_i(rst_i),
       .cs_i(1'b1),
       .i_data_i({attempt_count_w[15:0], broken_count_w[15:0]}),
       .o_seg_o(o_seg_o),
       .o_sel_o(o_sel_o)
    );

endmodule
