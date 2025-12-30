`timescale 1ns / 1ps

module CPU_Wrapper (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [31:0] init_floors_i,
    input  wire [31:0] init_resistance_i,
    
    output wire [31:0] pc_o,
    output wire [31:0] instruction_o,
    
    output wire [31:0] attempt_count_o,
    output wire [31:0] broken_count_o,
    output wire        last_broken_o,
    
    output wire [31:0] cost_f1_o,
    output wire [31:0] cost_f2_o
);

    // IF 阶段输出
    wire [31:0] if_pc_w;
    wire [31:0] if_npc_w;
    wire [31:0] if_instruction_w;

    // ID 阶段输入
    wire [31:0] id_npc_w;
    wire [31:0] id_instruction_w;

    // ID 阶段输出
    wire        id_dmem_ena_w;
    wire        id_dmem_wena_w;
    wire [1:0]  id_dmem_type_w;
    wire [4:0]  id_rd_waddr_w;
    wire        id_rd_sel_w;
    wire        id_rd_wena_w;
    wire [1:0]  id_pc_sel_w;
    wire        id_alu_a_sel_w;
    wire        id_alu_b_sel_w;
    wire [3:0]  id_alu_sel_w;
    wire        id_stall_w;
    wire        id_branch_w;

    // ID 阶段输出
    wire [31:0] id_rs_data_w;
    wire [31:0] id_rt_data_w;
    wire [31:0] id_immed_w;
    wire [31:0] id_shamt_w;
    wire [31:0] id_pc_baddr_w;
    wire [31:0] id_pc_jaddr_w;

    // EX 阶段输入
    wire        ex_dmem_ena_w;
    wire        ex_dmem_wena_w;
    wire [1:0]  ex_dmem_type_w;
    wire [31:0] ex_rs_data_w;
    wire [31:0] ex_rt_data_w;
    wire [4:0]  ex_rd_waddr_w;
    wire        ex_rd_wena_w;
    wire        ex_rd_sel_w;
    wire [31:0] ex_immed_w;
    wire [31:0] ex_shamt_w;
    wire        ex_alu_a_sel_w;
    wire        ex_alu_b_sel_w;
    wire [3:0]  ex_alu_sel_w;

    // EX 阶段输出
    wire        ex_out_dmem_ena_w;
    wire        ex_out_dmem_wena_w;
    wire [1:0]  ex_out_dmem_type_w;
    wire [31:0] ex_out_rs_data_w;
    wire [31:0] ex_out_rt_data_w;
    wire [4:0]  ex_out_rd_waddr_w;
    wire        ex_out_rd_sel_w;
    wire        ex_out_rd_wena_w;
    wire [31:0] ex_out_alu_result_w;

    // MEM 阶段输入
    wire        mem_dmem_ena_w;
    wire        mem_dmem_wena_w;
    wire [1:0]  mem_dmem_type_w;
    wire [31:0] mem_rs_data_w;
    wire [31:0] mem_rt_data_w;
    wire [4:0]  mem_rd_waddr_w;
    wire        mem_rd_sel_w;
    wire        mem_rd_wena_w;
    wire [31:0] mem_alu_result_w;

    // MEM 阶段输出
    wire [4:0]  mem_out_rd_waddr_w;
    wire        mem_out_rd_sel_w;
    wire        mem_out_rd_wena_w;
    wire [31:0] mem_out_alu_result_w;
    wire [31:0] mem_out_dmem_data_w;

    // WB 阶段输入
    wire [4:0]  wb_rd_waddr_w;
    wire        wb_rd_sel_w;
    wire        wb_rd_wena_w;
    wire [31:0] wb_alu_result_w;
    wire [31:0] wb_dmem_data_w;
    
    // WB 阶段输出
    wire [4:0]  wb_out_rd_waddr_w;
    wire        wb_out_rd_wena_w;
    wire [31:0] wb_out_rd_data_w;


    // 1. IF 阶段
    Stage_IF stage_if_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .stall_i(id_stall_w), // 停顿信号
       .pc_baddr_i(id_pc_baddr_w),
       .pc_jaddr_i(id_pc_jaddr_w),
       .pc_sel_i(id_pc_sel_w),
       .pc_o(if_pc_w),
       .npc_o(if_npc_w),
       .instruction_o(if_instruction_w)
    );
    assign pc_o = if_pc_w;
    assign instruction_o = if_instruction_w;

    // 2. IF/ID 流水线寄存器
    Register_IF_ID reg_if_id_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .stall_i(id_stall_w),  // 停顿信号
       .branch_i(id_branch_w), // 分支刷新信号
       .npc_i(if_npc_w),
       .instruction_i(if_instruction_w),
       .npc_o(id_npc_w),
       .instruction_o(id_instruction_w)
    );

    // 3. ID 阶段
    Stage_ID stage_id_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .npc_i(id_npc_w),
       .instruction_i(id_instruction_w),
        
        // 冒险检测所需数据
       .ex_waddr_i(ex_out_rd_waddr_w),
       .mem_waddr_i(mem_out_rd_waddr_w),
       .ex_wena_i(ex_out_rd_wena_w),
       .mem_wena_i(mem_out_rd_wena_w),
        
        // 写回数据
       .wb_reg_addr_i(wb_out_rd_waddr_w),
       .wb_reg_ena_i(wb_out_rd_wena_w),
       .wb_reg_data_i(wb_out_rd_data_w),
        
        // 初始值输入
       .init_floors_i(init_floors_i),
       .init_resistance_i(init_resistance_i),
        
        // ID 阶段数据输出
       .rs_data_o(id_rs_data_w),
       .rt_data_o(id_rt_data_w),
       .immed_o(id_immed_w),
       .shamt_o(id_shamt_w),
        
        // ID 阶段控制输出
       .rd_waddr_o(id_rd_waddr_w),
       .rd_sel_o(id_rd_sel_w),
       .rd_wena_o(id_rd_wena_w),
       .dmem_ena_o(id_dmem_ena_w),
       .dmem_wena_o(id_dmem_wena_w),
       .dmem_type_o(id_dmem_type_w),
       .pc_baddr_o(id_pc_baddr_w),
       .pc_jaddr_o(id_pc_jaddr_w),
       .pc_sel_o(id_pc_sel_w),
       .alu_a_sel_o(id_alu_a_sel_w),
       .alu_b_sel_o(id_alu_b_sel_w),
       .alu_sel_o(id_alu_sel_w),
        
        // 停顿与分支信号
       .stall_o(id_stall_w),
       .branch_o(id_branch_w),
        
        // 结果输出
       .attempt_count_o(attempt_count_o),
       .broken_count_o(broken_count_o),
       .last_broken_o(last_broken_o),
        
        // 成本函数输出
       .cost_f1_o(cost_f1_o),
       .cost_f2_o(cost_f2_o)
    );

    // 4. ID/EX 流水线寄存器
    Register_ID_EX reg_id_ex_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .dmem_ena_i(id_dmem_ena_w),
       .dmem_wena_i(id_dmem_wena_w),
       .dmem_type_i(id_dmem_type_w),
       .rs_data_i(id_rs_data_w),
       .rt_data_i(id_rt_data_w),
       .rd_waddr_i(id_rd_waddr_w),
       .rd_sel_i(id_rd_sel_w),
       .rd_wena_i(id_rd_wena_w),
       .immed_i(id_immed_w),
       .shamt_i(id_shamt_w),
       .alu_a_sel_i(id_alu_a_sel_w),
       .alu_b_sel_i(id_alu_b_sel_w),
       .alu_sel_i(id_alu_sel_w),
       .stall_i(id_stall_w), // 停顿时清空此寄存器
        
       .dmem_ena_o(ex_dmem_ena_w),
       .dmem_wena_o(ex_dmem_wena_w),
       .dmem_type_o(ex_dmem_type_w),
       .rs_data_o(ex_rs_data_w),
       .rt_data_o(ex_rt_data_w),
       .rd_waddr_o(ex_rd_waddr_w),
       .rd_sel_o(ex_rd_sel_w),
       .rd_wena_o(ex_rd_wena_w),
       .immed_o(ex_immed_w),
       .shamt_o(ex_shamt_w),
       .alu_a_sel_o(ex_alu_a_sel_w),
       .alu_b_sel_o(ex_alu_b_sel_w),
       .alu_sel_o(ex_alu_sel_w)
    );

    // 5. EX 阶段
    Stage_EX stage_ex_inst (
       .rst_i(rst_i),
       .dmem_ena_i(ex_dmem_ena_w),
       .dmem_wena_i(ex_dmem_wena_w),
       .dmem_type_i(ex_dmem_type_w),
       .rs_data_i(ex_rs_data_w),
       .rt_data_i(ex_rt_data_w),
       .rd_waddr_i(ex_rd_waddr_w),
       .rd_sel_i(ex_rd_sel_w),
       .rd_wena_i(ex_rd_wena_w),
       .immed_i(ex_immed_w),
       .shamt_i(ex_shamt_w),
       .alu_a_sel_i(ex_alu_a_sel_w),
       .alu_b_sel_i(ex_alu_b_sel_w),
       .alu_sel_i(ex_alu_sel_w),
        
       .dmem_ena_o(ex_out_dmem_ena_w),
       .dmem_wena_o(ex_out_dmem_wena_w),
       .dmem_type_o(ex_out_dmem_type_w),
       .rs_data_o(ex_out_rs_data_w),
       .rt_data_o(ex_out_rt_data_w),
       .rd_waddr_o(ex_out_rd_waddr_w),
       .rd_sel_o(ex_out_rd_sel_w),
       .rd_wena_o(ex_out_rd_wena_w),
       .alu_result_o(ex_out_alu_result_w)
    );

    // 6. EX/MEM 流水线寄存器
    Register_EX_MEM reg_ex_mem_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .dmem_ena_i(ex_out_dmem_ena_w),
       .dmem_wena_i(ex_out_dmem_wena_w),
       .dmem_type_i(ex_out_dmem_type_w),
       .rs_data_i(ex_out_rs_data_w),
       .rt_data_i(ex_out_rt_data_w),
       .rd_waddr_i(ex_out_rd_waddr_w),
       .rd_sel_i(ex_out_rd_sel_w),
       .rd_wena_i(ex_out_rd_wena_w),
       .alu_result_i(ex_out_alu_result_w),
        
       .dmem_ena_o(mem_dmem_ena_w),
       .dmem_wena_o(mem_dmem_wena_w),
       .dmem_type_o(mem_dmem_type_w),
       .rs_data_o(mem_rs_data_w),
       .rt_data_o(mem_rt_data_w),
       .rd_waddr_o(mem_rd_waddr_w),
       .rd_sel_o(mem_rd_sel_w),
       .rd_wena_o(mem_rd_wena_w),
       .alu_result_o(mem_alu_result_w)
    );

    // 7. MEM 阶段
    Stage_MEM stage_mem_inst (
       .clk_i(clk_i),
       .dmem_ena_i(mem_dmem_ena_w),
       .dmem_wena_i(mem_dmem_wena_w),
       .dmem_type_i(mem_dmem_type_w),
       .rs_data_i(mem_rs_data_w),
       .rt_data_i(mem_rt_data_w),
       .rd_waddr_i(mem_rd_waddr_w),
       .rd_sel_i(mem_rd_sel_w),
       .rd_wena_i(mem_rd_wena_w),
       .alu_result_i(mem_alu_result_w),
        
       .rd_waddr_o(mem_out_rd_waddr_w),
       .rd_sel_o(mem_out_rd_sel_w),
       .rd_wena_o(mem_out_rd_wena_w),
       .alu_result_o(mem_out_alu_result_w),
       .dmem_data_o(mem_out_dmem_data_w)
    );

    // 8. MEM/WB 流水线寄存器
    Register_MEM_WB reg_mem_wb_inst (
       .clk_i(clk_i),
       .rst_i(rst_i),
       .rd_waddr_i(mem_out_rd_waddr_w),
       .rd_sel_i(mem_out_rd_sel_w),
       .rd_wena_i(mem_out_rd_wena_w),
       .alu_result_i(mem_out_alu_result_w),
       .dmem_data_i(mem_out_dmem_data_w),
        
       .rd_waddr_o(wb_rd_waddr_w),
       .rd_sel_o(wb_rd_sel_w),
       .rd_wena_o(wb_rd_wena_w),
       .alu_result_o(wb_alu_result_w),
       .dmem_data_o(wb_dmem_data_w)
    );

    // 9. WB 阶段
    Stage_WB stage_wb_inst (
       .rd_waddr_i(wb_rd_waddr_w),
       .rd_sel_i(wb_rd_sel_w),
       .rd_wena_i(wb_rd_wena_w),
       .alu_result_i(wb_alu_result_w),
       .dmem_data_i(wb_dmem_data_w),
        
        // 最终写回数据
       .rd_waddr_o(wb_out_rd_waddr_w),
       .rd_wdata_o(wb_out_rd_data_w),
       .rd_wena_o(wb_out_rd_wena_w)
    );

endmodule
