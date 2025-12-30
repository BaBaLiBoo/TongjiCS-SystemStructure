`timescale 1ns / 1ps

module Stage_ID (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [31:0] npc_i,
    input  wire [31:0] instruction_i,
    input  wire [4:0]  ex_waddr_i,
    input  wire [4:0]  mem_waddr_i,
    input  wire        ex_wena_i,
    input  wire        mem_wena_i,
    input  wire [4:0]  wb_reg_addr_i,
    input  wire        wb_reg_ena_i,
    input  wire [31:0] wb_reg_data_i,
    input  wire [31:0] init_floors_i,
    input  wire [31:0] init_resistance_i,
    // 数据输出
    output wire [31:0] rs_data_o,
    output wire [31:0] rt_data_o,
    output wire [31:0] immed_o,
    output wire [31:0] shamt_o,
    // 控制信号输出
    output wire [4:0]  rd_waddr_o,
    output wire        rd_sel_o,
    output wire        rd_wena_o,
    output wire        dmem_ena_o,
    output wire        dmem_wena_o,
    output wire [1:0]  dmem_type_o,
    output wire [31:0] pc_baddr_o,
    output wire [31:0] pc_jaddr_o,
    output wire [1:0]  pc_sel_o,
    output wire        alu_a_sel_o,
    output wire        alu_b_sel_o,
    output wire [3:0]  alu_sel_o,
    // 冒险与分支信号输出
    output wire        stall_o,
    output wire        branch_o,
    // 最终结果输出
    output wire [31:0] attempt_count_o,
    output wire [31:0] broken_count_o,
    output wire        last_broken_o,
    // 成本函数输出
    output wire [31:0] cost_f1_o,
    output wire [31:0] cost_f2_o
);

    // 指令字段解析
    wire [5:0] inst_op_w   = instruction_i[31:26];
    wire [5:0] inst_func_w = instruction_i[5:0];
    wire [4:0] rs_addr_w   = instruction_i[25:21];
    wire [4:0] rt_addr_w   = instruction_i[20:16];
    wire [4:0] rd_addr_w   = instruction_i[15:11];

    wire       rs_rena_w;
    wire       rt_rena_w;
    wire       ext_signed_w;

    // 立即数和地址计算
    assign immed_o = { {16{ext_signed_w & instruction_i}}, instruction_i[15:0] };
    assign shamt_o = { 27'b0, instruction_i[10:6] };
    
    assign pc_baddr_o = npc_i + { {14{instruction_i}}, instruction_i[15:0], 2'b0 };
    assign pc_jaddr_o = { npc_i[31:28], instruction_i[25:0], 2'b0 };

    // 分支条件判断
    assign branch_o = ( (inst_op_w == 6'b000100) && (rs_data_o == rt_data_o) ) |

| // beq
                      ( (inst_op_w == 6'b000101) && (rs_data_o!= rt_data_o) ) |

| // bne
                      ( inst_op_w == 6'b000010 ); // j

    // 1. 例化寄存器堆
    Register_File reg_file_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .rs_rena_i(rs_rena_w),
       .rt_rena_i(rt_rena_w),
       .rd_wena_i(wb_reg_ena_i),     // 写使能来自 WB
       .rd_addr_i(wb_reg_addr_i),   // 写地址来自 WB
       .rs_addr_i(rs_addr_w),       // 读地址1
       .rt_addr_i(rt_addr_w),       // 读地址2
       .rd_data_i(wb_reg_data_i),   // 写数据来自 WB
        
       .init_floors_i(init_floors_i),
       .init_resistance_i(init_resistance_i),
        
       .rs_data_o(rs_data_o),
       .rt_data_o(rt_data_o),
        
       .attempt_count_o(attempt_count_o),
       .broken_count_o(broken_count_o),
       .last_broken_o(last_broken_o),
        
       .cost_f1_o(cost_f1_o),
       .cost_f2_o(cost_f2_o)
    );

    // 2. 例化主控制器
    Control_Unit controller_inst (
       .branch_taken_i(branch_o),
       .instruction_i(instruction_i),
       .rs_rena_o(rs_rena_w),
       .rt_rena_o(rt_rena_w),
       .rd_wena_o(rd_wena_o),
       .rd_sel_o(rd_sel_o),
       .rd_addr_o(rd_waddr_o),
       .dmem_ena_o(dmem_ena_o),
       .dmem_wena_o(dmem_wena_o),
       .dmem_type_o(dmem_type_o),
       .ext_signed_o(ext_signed_w),
       .alu_a_sel_o(alu_a_sel_o),
       .alu_b_sel_o(alu_b_sel_o),
       .alu_sel_o(alu_sel_o),
       .pc_sel_o(pc_sel_o)
    );

    // 3. 例化冒险检测单元
    Hazard_Unit hazard_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
        
        // 当前ID阶段的读请求
       .id_rs_addr_i(rs_addr_w),
       .id_rt_addr_i(rt_addr_w),
       .id_rs_rena_i(rs_rena_w),
       .id_rt_rena_i(rt_rena_w),
        
        // EX 阶段的写回
       .ex_wena_i(ex_wena_i),
       .ex_waddr_i(ex_waddr_i),
        
        // MEM 阶段的写回
       .mem_wena_i(mem_wena_i),
       .mem_waddr_i(mem_waddr_i),
        
       .stall_o(stall_o) // 输出停顿信号
    );

endmodule
