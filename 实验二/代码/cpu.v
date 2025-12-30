`timescale 1ns / 1ps

module processor(
    input           clk,
    input           rst,
    input           ena,
    output [31:0]   pc,
    output [31:0]   instr,
    output [31:0]   reg28
);

    wire pc_enable;
    wire id_ex_stage_we;
    wire ex_mem_stage_we;
    wire mem_wb_stage_we;
    assign {pc_enable, id_ex_stage_we, ex_mem_stage_we, mem_wb_stage_we} = {4{ena}};

    wire pipe_stall;
    wire branch_flush;
    wire [31:0] npc_from_if; 
    wire [31:0] pc4_from_if;
    wire [31:0] if_bus_pc4;
    wire [31:0] if_bus_npc;
    assign if_bus_pc4 = pc4_from_if;
    assign if_bus_npc = npc_from_if;

    wire [31:0] id_latch_pc4;
    wire [31:0] id_latch_instr;

    wire [2:0]  id_stage_pc_sel;
    wire [5:0]  id_stage_opcode;
    wire [5:0]  id_stage_func;
    wire [31:0] id_stage_immed;
    wire [31:0] id_stage_shamt;
    wire [31:0] id_stage_pc4;
    wire [31:0] id_stage_eaddr;
    wire [31:0] id_stage_baddr;
    wire [31:0] id_stage_jaddr;
    wire [31:0] id_stage_raddr;
    wire [31:0] id_stage_rs;  
    wire [31:0] id_stage_rt;
    wire [31:0] id_stage_hi;
    wire [31:0] id_stage_lo;
    wire [31:0] id_stage_cp0;
    wire        id_stage_alu_a_sel;
    wire [1:0]  id_stage_alu_b_sel;
    wire [3:0]  id_stage_aluc;
    wire        id_stage_mul_en;
    wire        id_stage_div_en;
    wire        id_stage_clz_en;
    wire        id_stage_mul_signed;
    wire        id_stage_div_signed;
    wire        id_stage_cut_sign;
    wire        id_stage_cut_addr_sel;
    wire [2:0]  id_stage_cut_sel;
    wire        id_stage_dmem_en;
    wire        id_stage_dmem_we;
    wire [1:0]  id_stage_dmem_wsel;
    wire [1:0]  id_stage_dmem_rsel;
    wire        id_stage_hi_we;
    wire        id_stage_lo_we;
    wire        id_stage_rd_we;
    wire [1:0]  id_stage_hi_sel;
    wire [1:0]  id_stage_lo_sel;
    wire [2:0]  id_stage_rd_sel;
    wire [4:0]  id_stage_rd_addr;


    wire [5:0]  ex_pipe_op;
    wire [5:0]  ex_pipe_func;
    wire [31:0] ex_pipe_pc4;
    wire [31:0] ex_pipe_immed;
    wire [31:0] ex_pipe_shamt;
    wire [31:0] ex_pipe_rs_data;
    wire [31:0] ex_pipe_rt_data;
    wire [31:0] ex_pipe_hi_data;
    wire [31:0] ex_pipe_lo_data;
    wire [31:0] ex_pipe_cp0_data;
    wire        ex_pipe_alu_a_sel;
    wire [1:0]  ex_pipe_alu_b_sel;
    wire [3:0]  ex_pipe_aluc;
    wire        ex_pipe_mul_en;
    wire        ex_pipe_div_en;
    wire        ex_pipe_clz_en;
    wire        ex_pipe_mul_signed;
    wire        ex_pipe_div_signed;
    wire        ex_pipe_cut_sign;
    wire        ex_pipe_cut_addr_sel;
    wire [2:0]  ex_pipe_cut_sel;
    wire        ex_pipe_dmem_en;
    wire        ex_pipe_dmem_we;
    wire [1:0]  ex_pipe_dmem_wsel;
    wire [1:0]  ex_pipe_dmem_rsel;
    wire        ex_pipe_hi_we;
    wire        ex_pipe_lo_we;
    wire        ex_pipe_rd_we;
    wire [1:0]  ex_pipe_hi_sel;
    wire [1:0]  ex_pipe_lo_sel;
    wire [2:0]  ex_pipe_rd_sel;
    wire [4:0]  ex_pipe_rd_addr;

    wire [31:0] ex_stage_pc4;
    wire [31:0] ex_stage_rs_data;
    wire [31:0] ex_stage_rt_data;
    wire [31:0] ex_stage_hi_data;
    wire [31:0] ex_stage_lo_data;
    wire [31:0] ex_stage_cp0_data;
    wire [31:0] ex_stage_alu_data;
    wire [31:0] ex_stage_mul_hi;
    wire [31:0] ex_stage_mul_lo;
    wire [31:0] ex_stage_div_r;
    wire [31:0] ex_stage_div_q;
    wire [31:0] ex_stage_clz_data;
    wire        ex_stage_cut_sign;
    wire        ex_stage_cut_addr_sel;
    wire [2:0]  ex_stage_cut_sel;
    wire        ex_stage_dmem_en;
    wire        ex_stage_dmem_we;
    wire [1:0]  ex_stage_dmem_wsel;
    wire [1:0]  ex_stage_dmem_rsel;
    wire        ex_stage_hi_we;
    wire        ex_stage_lo_we;
    wire        ex_stage_rd_we;
    wire [1:0]  ex_stage_hi_sel;
    wire [1:0]  ex_stage_lo_sel;
    wire [2:0]  ex_stage_rd_sel;
    wire [4:0]  ex_stage_rd_addr;


    wire        mem_pipe_dmem_en;
    wire        mem_pipe_dmem_we;
    wire [1:0]  mem_pipe_dmem_wsel;
    wire [1:0]  mem_pipe_dmem_rsel;
    wire        mem_pipe_hi_we;
    wire        mem_pipe_lo_we;
    wire        mem_pipe_rd_we;
    wire [1:0]  mem_pipe_hi_sel;
    wire [1:0]  mem_pipe_lo_sel;
    wire [2:0]  mem_pipe_rd_sel;
    wire [31:0] mem_pipe_pc4;
    wire [31:0] mem_pipe_rs_data;
    wire [31:0] mem_pipe_rt_data;
    wire [31:0] mem_pipe_hi_data;
    wire [31:0] mem_pipe_lo_data;
    wire [31:0] mem_pipe_cp0_data;
    wire [31:0] mem_pipe_alu_data;
    wire [31:0] mem_pipe_mul_hi;
    wire [31:0] mem_pipe_mul_lo;  
    wire [31:0] mem_pipe_div_r;
    wire [31:0] mem_pipe_div_q;
    wire [31:0] mem_pipe_clz_data;
    wire        mem_pipe_cut_sign;
    wire        mem_pipe_cut_addr_sel;
    wire [2:0]  mem_pipe_cut_sel;
    wire [4:0]  mem_pipe_rd_addr;

    wire [31:0] mem_stage_pc4;
    wire [31:0] mem_stage_rs_data;
    wire [31:0] mem_stage_hi_data;
    wire [31:0] mem_stage_lo_data;
    wire [31:0] mem_stage_cp0_data;
    wire [31:0] mem_stage_alu_data;
    wire [31:0] mem_stage_mul_hi;
    wire [31:0] mem_stage_mul_lo;
    wire [31:0] mem_stage_div_r;
    wire [31:0] mem_stage_div_q;
    wire [31:0] mem_stage_clz_data;
    wire [31:0] mem_stage_dmem_data;
    wire        mem_stage_rd_we; 
    wire        mem_stage_hi_we;
    wire        mem_stage_lo_we;      
    wire [1:0]  mem_stage_lo_sel;
    wire [1:0]  mem_stage_hi_sel;
    wire [2:0]  mem_stage_rd_sel;
    wire [4:0]  mem_stage_rd_addr;


    wire [31:0] wb_buf_pc4;
    wire [31:0] wb_buf_rs;
    wire [31:0] wb_buf_hi;
    wire [31:0] wb_buf_lo;
    wire [31:0] wb_buf_cp0;
    wire [31:0] wb_buf_alu;
    wire [31:0] wb_buf_mul_hi;
    wire [31:0] wb_buf_mul_lo;
    wire [31:0] wb_buf_div_r;
    wire [31:0] wb_buf_div_q;
    wire [31:0] wb_buf_clz;
    wire [31:0] wb_buf_mem;
    wire        wb_buf_hi_we;
    wire        wb_buf_lo_we;
    wire        wb_buf_rd_we;
    wire [1:0]  wb_buf_hi_sel;
    wire [1:0]  wb_buf_lo_sel;
    wire [2:0]  wb_buf_rd_sel;
    wire [4:0]  wb_buf_rd_addr;

    wire        wb_stage_hi_we;
    wire        wb_stage_lo_we;
    wire        wb_stage_rd_we;
    wire [31:0] wb_stage_hi_data;
    wire [31:0] wb_stage_lo_data;
    wire [31:0] wb_stage_rd_data;
    wire [4:0]  wb_stage_rd_addr;


    assign pc_enable        = ena;
    assign id_ex_stage_we   = ena;
    assign ex_mem_stage_we  = ena;
    assign mem_wb_stage_we  = ena;
	
	program_counter pc_inst(
	    .clk_in(clk),
        .rst_in(rst),
        .ena_in(pc_enable),
        .stall_in(pipe_stall),
        .pc_in(if_bus_npc),
        .pc_out(pc)
    );

    pipe_if pipe_if_inst(
        .clk_sig(clk),
        .pc_val(pc),
        .pc_sel(id_stage_pc_sel),
        .pc_eaddr(id_stage_eaddr),
        .pc_baddr(id_stage_baddr),
        .pc_raddr(id_stage_raddr),
        .pc_jaddr(id_stage_jaddr),
        .npc_out(npc_from_if),
        .pc4_out(pc4_from_if),
        .instr_out(instr)
    );

    pipe_if_id pipe_if_id_inst(
        .clk_sig(clk),
        .rst_sig(rst),
        .stall_sig(pipe_stall),
        .branch_sig(branch_flush),
        .pc4_in(if_bus_pc4),
        .instr_in(instr),
        .pc4_out(id_latch_pc4),
        .instr_out(id_latch_instr)
    );

    pipe_id pipe_id_inst(
        .clk_sig(clk),
        .rst_sig(rst),
        .pc4_in(id_latch_pc4),
        .instr_in(id_latch_instr),
        .hi_wena_in(wb_stage_hi_we),
        .lo_wena_in(wb_stage_lo_we),
        .rd_wena_in(wb_stage_rd_we),
        .rd_waddr_in(wb_stage_rd_addr),
        .hi_data_in(wb_stage_hi_data),
        .lo_data_in(wb_stage_lo_data),
        .rd_data_in(wb_stage_rd_data),
        .ex_op_in(ex_pipe_op),
        .ex_func_in(ex_pipe_func),
        .ex_pc4_in(ex_stage_pc4),
        .ex_alu_data_in(ex_stage_alu_data),
        .ex_mul_hi_in(ex_stage_mul_hi),
        .ex_mul_lo_in(ex_stage_mul_lo),
        .ex_div_r_in(ex_stage_div_r),
        .ex_div_q_in(ex_stage_div_q),
        .ex_clz_data_in(ex_stage_clz_data),
        .ex_hi_data_in(ex_stage_hi_data),
        .ex_lo_data_in(ex_stage_lo_data),
        .ex_rs_data_in(ex_stage_rs_data),
        .ex_hi_wena_in(ex_stage_hi_we),
        .ex_lo_wena_in(ex_stage_lo_we),
        .ex_rd_wena_in(ex_stage_rd_we),
        .ex_hi_sel_in(ex_stage_hi_sel),
        .ex_lo_sel_in(ex_stage_lo_sel),
        .ex_rd_sel_in(ex_stage_rd_sel),
        .ex_rd_waddr_in(ex_stage_rd_addr),
        .mem_pc4_in(mem_stage_pc4),
        .mem_alu_data_in(mem_stage_alu_data),
        .mem_mul_hi_in(mem_stage_mul_hi),
        .mem_mul_lo_in(mem_stage_mul_lo),
        .mem_div_q_in(mem_stage_div_r),
        .mem_div_r_in(mem_stage_div_q),
        .mem_clz_data_in(mem_stage_clz_data),
        .mem_lo_data_in(mem_stage_lo_data),
        .mem_hi_data_in(mem_stage_hi_data),
        .mem_rs_data_in(mem_stage_rs_data),
        .mem_dmem_data_in(mem_stage_dmem_data),
        .mem_hi_wena_in(mem_stage_hi_we),
        .mem_lo_wena_in(mem_stage_lo_we),
        .mem_rd_wena_in(mem_stage_rd_we),
        .mem_hi_sel_in(mem_stage_hi_sel),
        .mem_lo_sel_in(mem_stage_lo_sel),
        .mem_rd_sel_in(mem_stage_rd_sel),
        .mem_rd_waddr_in(mem_stage_rd_addr),
        .stall_out(pipe_stall),
        .branch_out(branch_flush),
        .op_out(id_stage_opcode),
        .func_out(id_stage_func),
        .pc_sel_out(id_stage_pc_sel),
        .pc4_out(id_stage_pc4),
        .immed_out(id_stage_immed),
        .shamt_out(id_stage_shamt),
        .pc_eaddr_out(id_stage_eaddr),
        .pc_baddr_out(id_stage_baddr),
        .pc_jaddr_out(id_stage_jaddr),
        .pc_raddr_out(id_stage_raddr),
        .rs_data_out(id_stage_rs),
        .rt_data_out(id_stage_rt),
        .hi_data_out(id_stage_hi),
        .lo_data_out(id_stage_lo),
        .cp0_data_out(id_stage_cp0),
        .alu_a_sel_out(id_stage_alu_a_sel),
        .alu_b_sel_out(id_stage_alu_b_sel),
        .aluc_out(id_stage_aluc),
        .mul_ena_out(id_stage_mul_en),
        .div_ena_out(id_stage_div_en),
        .clz_ena_out(id_stage_clz_en),
        .mul_sign_out(id_stage_mul_signed),
        .div_sign_out(id_stage_div_signed),
        .hi_wena_out(id_stage_hi_we),
        .lo_wena_out(id_stage_lo_we),
        .rd_wena_out(id_stage_rd_we),
        .cutter_sign_out(id_stage_cut_sign),
        .cutter_addr_sel_out(id_stage_cut_addr_sel),
        .cutter_sel_out(id_stage_cut_sel),
        .dmem_ena_out(id_stage_dmem_en),
        .dmem_wena_out(id_stage_dmem_we),
        .dmem_wsel_out(id_stage_dmem_wsel),
        .dmem_rsel_out(id_stage_dmem_rsel),
        .hi_sel_out(id_stage_hi_sel),
        .lo_sel_out(id_stage_lo_sel),
        .rd_sel_out(id_stage_rd_sel),
        .rd_waddr_out(id_stage_rd_addr),
        .reg28_out(reg28)
    );

    pipe_id_ex pipe_id_ex_inst(
        .idex_clk(clk),
        .idex_rst(rst),
        .idex_we_in(id_ex_stage_we),
        .idex_stall_in(pipe_stall),
        .idex_op_in(id_stage_opcode),
        .idex_func_in(id_stage_func),
        .idex_pc4_in(id_stage_pc4),
        .idex_imm_in(id_stage_immed),
        .idex_shamt_in(id_stage_shamt),
        .idex_rs_in(id_stage_rs),
        .idex_rt_in(id_stage_rt),
        .idex_hi_in(id_stage_hi),
        .idex_lo_in(id_stage_lo),
        .idex_cp0_in(id_stage_cp0),
        .idex_alu_a_sel_in(id_stage_alu_a_sel),
        .idex_alu_b_sel_in(id_stage_alu_b_sel),
        .idex_aluc_in(id_stage_aluc),
        .idex_mul_en_in(id_stage_mul_en),
        .idex_clz_en_in(id_stage_clz_en),
        .idex_div_en_in(id_stage_div_en),
        .idex_mul_signed_in(id_stage_mul_signed),
        .idex_div_signed_in(id_stage_div_signed),
        .idex_cut_sign_in(id_stage_cut_sign),
        .idex_cut_addr_sel_in(id_stage_cut_addr_sel),
        .idex_cut_sel_in(id_stage_cut_sel),
        .idex_dmem_en_in(id_stage_dmem_en),
        .idex_dmem_we_in(id_stage_dmem_we),
        .idex_dmem_wsel_in(id_stage_dmem_wsel),
        .idex_dmem_rsel_in(id_stage_dmem_rsel),
        .idex_hi_we_in(id_stage_hi_we),
        .idex_lo_we_in(id_stage_lo_we),
        .idex_rd_we_in(id_stage_rd_we),
        .idex_hi_sel_in(id_stage_hi_sel),
        .idex_lo_sel_in(id_stage_lo_sel),
        .idex_rd_sel_in(id_stage_rd_sel),
        .idex_rd_addr_in(id_stage_rd_addr),
        .idex_op_out(ex_pipe_op),
        .idex_func_out(ex_pipe_func),
        .idex_pc4_out(ex_pipe_pc4),
        .idex_imm_out(ex_pipe_immed),
        .idex_shamt_out(ex_pipe_shamt),
        .idex_rs_out(ex_pipe_rs_data),
        .idex_rt_out(ex_pipe_rt_data),
        .idex_hi_out(ex_pipe_hi_data),
        .idex_lo_out(ex_pipe_lo_data),
        .idex_cp0_out(ex_pipe_cp0_data),
        .idex_alu_a_sel_out(ex_pipe_alu_a_sel),
        .idex_alu_b_sel_out(ex_pipe_alu_b_sel),
        .idex_aluc_out(ex_pipe_aluc),
        .idex_clz_en_out(ex_pipe_clz_en),
        .idex_mul_en_out(ex_pipe_mul_en),
        .idex_div_en_out(ex_pipe_div_en),
        .idex_mul_signed_out(ex_pipe_mul_signed),
        .idex_div_signed_out(ex_pipe_div_signed),
        .idex_cut_sign_out(ex_pipe_cut_sign),
        .idex_cut_addr_sel_out(ex_pipe_cut_addr_sel),
        .idex_cut_sel_out(ex_pipe_cut_sel),
        .idex_dmem_en_out(ex_pipe_dmem_en),
        .idex_dmem_we_out(ex_pipe_dmem_we),
        .idex_dmem_wsel_out(ex_pipe_dmem_wsel),
        .idex_dmem_rsel_out(ex_pipe_dmem_rsel),
        .idex_rd_we_out(ex_pipe_rd_we),
        .idex_hi_we_out(ex_pipe_hi_we),
        .idex_lo_we_out(ex_pipe_lo_we),
        .idex_hi_sel_out(ex_pipe_hi_sel),
        .idex_lo_sel_out(ex_pipe_lo_sel),
        .idex_rd_sel_out(ex_pipe_rd_sel),
        .idex_rd_addr_out(ex_pipe_rd_addr)
    );

    pipe_ex pipe_ex_inst(
        .rst_ex(rst),
        .pc4_ex_in(ex_pipe_pc4),
        .imm_ex_in(ex_pipe_immed),
        .shamt_ex_in(ex_pipe_shamt),
        .rs_ex_in(ex_pipe_rs_data),
        .rt_ex_in(ex_pipe_rt_data),
        .hi_ex_in(ex_pipe_hi_data),
        .lo_ex_in(ex_pipe_lo_data),
        .cp0_ex_in(ex_pipe_cp0_data),
        .alu_a_sel_ex(ex_pipe_alu_a_sel),
        .alu_b_sel_ex(ex_pipe_alu_b_sel),
        .aluc_ex(ex_pipe_aluc),
        .mul_en_ex(ex_pipe_mul_en),
        .div_en_ex(ex_pipe_div_en),
        .clz_en_ex(ex_pipe_clz_en),
        .mul_signed_ex(ex_pipe_mul_signed),
        .div_signed_ex(ex_pipe_div_signed),
        .cut_sign_ex(ex_pipe_cut_sign),
        .cut_addr_sel_ex(ex_pipe_cut_addr_sel),
        .cut_sel_ex(ex_pipe_cut_sel),
        .dmem_en_ex(ex_pipe_dmem_en),
        .dmem_we_ex(ex_pipe_dmem_we),
        .dmem_wsel_ex(ex_pipe_dmem_wsel),
        .dmem_rsel_ex(ex_pipe_dmem_rsel),
        .rd_we_ex(ex_pipe_rd_we),
        .hi_we_ex(ex_pipe_hi_we),
        .lo_we_ex(ex_pipe_lo_we),
        .hi_sel_ex(ex_pipe_hi_sel),
        .lo_sel_ex(ex_pipe_lo_sel),
        .rd_sel_ex(ex_pipe_rd_sel),
        .rd_addr_ex_in(ex_pipe_rd_addr),
        .pc4_ex_out(ex_stage_pc4),
        .mul_hi_ex_out(ex_stage_mul_hi),
        .mul_lo_ex_out(ex_stage_mul_lo),
        .div_r_ex_out(ex_stage_div_r),
        .div_q_ex_out(ex_stage_div_q),
        .rs_ex_out(ex_stage_rs_data),
        .rt_ex_out(ex_stage_rt_data),
        .hi_ex_out(ex_stage_hi_data),
        .lo_ex_out(ex_stage_lo_data),
        .cp0_ex_out(ex_stage_cp0_data),
        .clz_ex_out(ex_stage_clz_data),
        .alu_ex_out(ex_stage_alu_data),
        .cut_sign_ex_out(ex_stage_cut_sign),
        .cut_addr_sel_ex_out(ex_stage_cut_addr_sel),
        .cut_sel_ex_out(ex_stage_cut_sel),
        .dmem_en_ex_out(ex_stage_dmem_en),
        .dmem_we_ex_out(ex_stage_dmem_we),
        .dmem_wsel_ex_out(ex_stage_dmem_wsel),
        .dmem_rsel_ex_out(ex_stage_dmem_rsel),
        .hi_we_ex_out(ex_stage_hi_we),
        .lo_we_ex_out(ex_stage_lo_we),
        .rd_we_ex_out(ex_stage_rd_we),
        .hi_sel_ex_out(ex_stage_hi_sel),
        .lo_sel_ex_out(ex_stage_lo_sel),
        .rd_sel_ex_out(ex_stage_rd_sel),
        .rd_addr_ex_out(ex_stage_rd_addr)
    );


    pipe_ex_mem pipe_ex_mem_inst(
        .clk_exmem(clk),
        .rst_exmem(rst),
        .exmem_we_in(ex_mem_stage_we),
        .exmem_pc4_in(ex_stage_pc4),
        .exmem_rs_in(ex_stage_rs_data),
        .exmem_rt_in(ex_stage_rt_data),
        .exmem_hi_in(ex_stage_hi_data),
        .exmem_lo_in(ex_stage_lo_data),
        .exmem_cp0_in(ex_stage_cp0_data),
        .exmem_alu_in(ex_stage_alu_data),
        .exmem_mul_hi_in(ex_stage_mul_hi),
        .exmem_mul_lo_in(ex_stage_mul_lo),
        .exmem_div_r_in(ex_stage_div_r),
        .exmem_div_q_in(ex_stage_div_q),
        .exmem_clz_in(ex_stage_clz_data),
        .exmem_cut_sign_in(ex_stage_cut_sign),
        .exmem_cut_sel_in(ex_stage_cut_sel),
        .exmem_cut_addr_sel_in(ex_stage_cut_addr_sel),
        .exmem_dmem_en_in(ex_stage_dmem_en),
        .exmem_dmem_we_in(ex_stage_dmem_we),
        .exmem_dmem_wsel_in(ex_stage_dmem_wsel),
        .exmem_dmem_rsel_in(ex_stage_dmem_rsel),
        .exmem_hi_we_in(ex_stage_hi_we),
        .exmem_lo_we_in(ex_stage_lo_we),
        .exmem_rd_we_in(ex_stage_rd_we),
        .exmem_hi_sel_in(ex_stage_hi_sel),
        .exmem_lo_sel_in(ex_stage_lo_sel),
        .exmem_rd_sel_in(ex_stage_rd_sel),
        .exmem_rd_addr_in(ex_stage_rd_addr),
        .exmem_pc4_out(mem_pipe_pc4),
        .exmem_rs_out(mem_pipe_rs_data),
        .exmem_rt_out(mem_pipe_rt_data),
        .exmem_hi_out(mem_pipe_hi_data),
        .exmem_lo_out(mem_pipe_lo_data),
        .exmem_cp0_out(mem_pipe_cp0_data),
        .exmem_alu_out(mem_pipe_alu_data),
        .exmem_mul_hi_out(mem_pipe_mul_hi),
        .exmem_mul_lo_out(mem_pipe_mul_lo),
        .exmem_div_r_out(mem_pipe_div_r),
        .exmem_div_q_out(mem_pipe_div_q),
        .exmem_clz_out(mem_pipe_clz_data),
        .exmem_cut_sign_out(mem_pipe_cut_sign),
        .exmem_cut_addr_sel_out(mem_pipe_cut_addr_sel),
        .exmem_cut_sel_out(mem_pipe_cut_sel),
        .exmem_dmem_en_out(mem_pipe_dmem_en),
        .exmem_dmem_we_out(mem_pipe_dmem_we),
        .exmem_dmem_wsel_out(mem_pipe_dmem_wsel),
        .exmem_dmem_rsel_out(mem_pipe_dmem_rsel),
        .exmem_rd_we_out(mem_pipe_rd_we),
        .exmem_hi_we_out(mem_pipe_hi_we),
        .exmem_lo_we_out(mem_pipe_lo_we),
        .exmem_hi_sel_out(mem_pipe_hi_sel),
        .exmem_lo_sel_out(mem_pipe_lo_sel),
        .exmem_rd_sel_out(mem_pipe_rd_sel),
        .exmem_rd_addr_out(mem_pipe_rd_addr)
    );

    pipe_mem pipe_mem_inst(
        .mem_clk(clk),
        .mem_pc4_in(mem_pipe_pc4),
        .mem_rs_in(mem_pipe_rs_data),
        .mem_rt_in(mem_pipe_rt_data),
        .mem_hi_in(mem_pipe_hi_data),
        .mem_lo_in(mem_pipe_lo_data),
        .mem_cp0_in(mem_pipe_cp0_data),
        .mem_alu_in(mem_pipe_alu_data),
        .mem_mul_hi_in(mem_pipe_mul_hi),
        .mem_mul_lo_in(mem_pipe_mul_lo),
        .mem_div_r_in(mem_pipe_div_r),
        .mem_div_q_in(mem_pipe_div_q),
        .mem_clz_in(mem_pipe_clz_data),
        .mem_cut_sign_in(mem_pipe_cut_sign),
        .mem_cut_addr_sel_in(mem_pipe_cut_addr_sel),
        .mem_cut_sel_in(mem_pipe_cut_sel),
        .mem_dmem_wsel_in(mem_pipe_dmem_wsel),
        .mem_dmem_rsel_in(mem_pipe_dmem_rsel),
        .mem_dmem_en_in(mem_pipe_dmem_en),
        .mem_dmem_we_in(mem_pipe_dmem_we),
        .mem_hi_we_in(mem_pipe_hi_we),
        .mem_lo_we_in(mem_pipe_lo_we),
        .mem_rd_we_in(mem_pipe_rd_we),
        .mem_hi_sel_in(mem_pipe_hi_sel),
        .mem_lo_sel_in(mem_pipe_lo_sel),
        .mem_rd_sel_in(mem_pipe_rd_sel),
        .mem_rd_addr_in(mem_pipe_rd_addr),
        .mem_pc4_out(mem_stage_pc4),
        .mem_rs_out(mem_stage_rs_data),
        .mem_hi_out(mem_stage_hi_data),
        .mem_lo_out(mem_stage_lo_data),
        .mem_cp0_out(mem_stage_cp0_data),
        .mem_alu_out(mem_stage_alu_data),
        .mem_mul_hi_out(mem_stage_mul_hi),
        .mem_mul_lo_out(mem_stage_mul_lo),
        .mem_div_r_out(mem_stage_div_r),
        .mem_div_q_out(mem_stage_div_q),
        .mem_clz_out(mem_stage_clz_data),
        .mem_dmem_data_out(mem_stage_dmem_data),
        .mem_hi_we_out(mem_stage_hi_we),
        .mem_lo_we_out(mem_stage_lo_we),
        .mem_rd_we_out(mem_stage_rd_we),
        .mem_hi_sel_out(mem_stage_hi_sel),
        .mem_lo_sel_out(mem_stage_lo_sel),
        .mem_rd_sel_out(mem_stage_rd_sel),
        .mem_rd_addr_out(mem_stage_rd_addr)
    );

    pipe_mem_wb pipe_mem_wb_inst(
        .memwb_clk(clk),
        .memwb_rst(rst),
        .memwb_we_in(mem_wb_stage_we),
        .memwb_pc4_in(mem_stage_pc4),
        .memwb_rs_in(mem_stage_rs_data),
        .memwb_hi_in(mem_stage_hi_data),
        .memwb_lo_in(mem_stage_lo_data),
        .memwb_cp0_in(mem_stage_cp0_data),
        .memwb_alu_in(mem_stage_alu_data),
        .memwb_mul_hi_in(mem_stage_mul_hi),
        .memwb_mul_lo_in(mem_stage_mul_lo),
        .memwb_div_r_in(mem_stage_div_r),
        .memwb_div_q_in(mem_stage_div_q),
        .memwb_clz_in(mem_stage_clz_data),
        .memwb_dmem_in(mem_stage_dmem_data),
        .memwb_hi_we_in(mem_stage_hi_we),
        .memwb_lo_we_in(mem_stage_lo_we),
        .memwb_rd_we_in(mem_stage_rd_we),
        .memwb_hi_sel_in(mem_stage_hi_sel),
        .memwb_lo_sel_in(mem_stage_lo_sel),
        .memwb_rd_sel_in(mem_stage_rd_sel),
        .memwb_rd_addr_in(mem_stage_rd_addr),
        .memwb_pc4_out(wb_buf_pc4),
        .memwb_rs_out(wb_buf_rs),
        .memwb_hi_out(wb_buf_hi),
        .memwb_lo_out(wb_buf_lo),
        .memwb_cp0_out(wb_buf_cp0),
        .memwb_alu_out(wb_buf_alu),
        .memwb_mul_hi_out(wb_buf_mul_hi),
        .memwb_mul_lo_out(wb_buf_mul_lo),
        .memwb_div_r_out(wb_buf_div_r),
        .memwb_div_q_out(wb_buf_div_q),
        .memwb_clz_out(wb_buf_clz),
        .memwb_dmem_out(wb_buf_mem),
        .memwb_hi_we_out(wb_buf_hi_we),
        .memwb_lo_we_out(wb_buf_lo_we),
        .memwb_rd_we_out(wb_buf_rd_we),
        .memwb_hi_sel_out(wb_buf_hi_sel),
        .memwb_lo_sel_out(wb_buf_lo_sel),
        .memwb_rd_sel_out(wb_buf_rd_sel),
        .memwb_rd_addr_out(wb_buf_rd_addr)
    );

    pipe_wb pipe_wb_inst(
        .wb_pc4_in(wb_buf_pc4),
        .wb_rs_in(wb_buf_rs),
        .wb_hi_in(wb_buf_hi),
        .wb_lo_in(wb_buf_lo),
        .wb_cp0_in(wb_buf_cp0),
        .wb_alu_in(wb_buf_alu),
        .wb_mul_hi_in(wb_buf_mul_hi),
        .wb_mul_lo_in(wb_buf_mul_lo),
        .wb_div_r_in(wb_buf_div_q),
        .wb_div_q_in(wb_buf_div_q),
        .wb_clz_in(wb_buf_clz),
        .wb_dmem_in(wb_buf_mem),
        .wb_hi_we_in(wb_buf_hi_we),
        .wb_lo_we_in(wb_buf_lo_we),
        .wb_rd_we_in(wb_buf_rd_we),
        .wb_hi_sel_in(wb_buf_hi_sel),
        .wb_lo_sel_in(wb_buf_lo_sel),
        .wb_rd_sel_in(wb_buf_rd_sel),
        .wb_rd_addr_in(wb_buf_rd_addr),
        .wb_hi_we_out(wb_stage_hi_we),
        .wb_lo_we_out(wb_stage_lo_we),
        .wb_rd_we_out(wb_stage_rd_we),
        .wb_rd_addr_out(wb_stage_rd_addr),
        .wb_hi_out(wb_stage_hi_data),
        .wb_lo_out(wb_stage_lo_data),
        .wb_data_out(wb_stage_rd_data)
    );

endmodule