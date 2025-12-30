`timescale 1ns / 1ps

module Stage_IF (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire        stall_i,        // 来自ID阶段的停顿信号
    input  wire [31:0] pc_jaddr_i,     // 跳转地址
    input  wire [31:0] pc_baddr_i,     // 分支地址
    input  wire [1:0]  pc_sel_i,       // PC源选择
    
    output wire [31:0] pc_o,           // 当前PC
    output wire [31:0] npc_o,          // PC+4
    output wire [31:0] instruction_o   // 取出的指令
);

    localparam integer IMEM_AW = 11;

    wire [31:0] next_pc_addr_w;
    wire [31:0] pc_plus_4_w;

    // PC 寄存器
    PC_Register pc_register_inst (
       .clk_i   (clk_i),
       .ena_i   (1'b1),
       .rst_i   (rst_i),
       .stall_i (stall_i),
       .pc_in_i (next_pc_addr_w),
       .pc_out_o(pc_o)
    );

    // PC+4
    assign pc_plus_4_w = pc_o + 32'd4;
    assign npc_o       = pc_plus_4_w;

    Mux_4x32 pc_select_mux_inst (
       .d0_i (pc_plus_4_w),   
       .d1_i (pc_baddr_i),    
       .d2_i (pc_jaddr_i),    
       .d3_i (32'b0),         
       .sel_i(pc_sel_i),
       .y_o  (next_pc_addr_w)
    );

    wire [IMEM_AW-1:0] rom_idx = pc_o[IMEM_AW+1 : 2];

    imem imem_rom_inst (
       .clka  (clk_i),
       .ena   (1'b1),
       .addra (rom_idx),
       .douta (instruction_o)
    );

endmodule
