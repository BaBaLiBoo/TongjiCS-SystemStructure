`timescale 1ns / 1ps

module pipe_if(
    input           clk_sig,
    input   [31:0]  pc_val,
    input   [2:0]   pc_sel,
    input   [31:0]  pc_eaddr,
    input   [31:0]  pc_baddr,
    input   [31:0]  pc_raddr,
    input   [31:0]  pc_jaddr,
    output  [31:0]  npc_out,
    output  [31:0]  pc4_out,
    output  [31:0]  instr_out 
    );
    wire [10:0] imem_addr = (pc_val - 32'h00400000) >> 2;
    
    assign pc4_out = pc_val + 32'd4;
	imem imem_inst(
        .clka(clk_sig),
        .ena(1'b1),
        .wea(1'b0),
        .addra(imem_addr),
        .dina(32'b0),
        .douta(instr_out)
    );
    selector_8_32 sel_npc(pc_jaddr, pc_raddr, pc4_out, 32'h00400004, 
                    pc_baddr, pc_eaddr, 32'bz, 32'bz, pc_sel, npc_out);

endmodule

module pipe_if_id(
    input               clk_sig,
    input               rst_sig,
    input               stall_sig,
    input               branch_sig,
    input [31:0]        pc4_in,
    input [31:0]        instr_in,
    output reg [31:0]   pc4_out,
    output reg [31:0]   instr_out 
    );

    always @(posedge clk_sig or posedge rst_sig)
    begin
		if(rst_sig) 
        begin
		    pc4_out   <= 32'b0;
		    instr_out <= 32'b0;       
		end 
        else if(branch_sig)
        begin
            pc4_out   <= 32'b0;
            instr_out <= 32'b0;
        end 
        else if(~stall_sig) 
        begin
		    pc4_out   <= pc4_in;
		    instr_out <= instr_in;
		end
	end
	
endmodule


module pipe_id(
	input           clk_sig,
    input           rst_sig,
    input [31:0]    pc4_in,
    input [31:0]    instr_in,
    input           hi_wena_in,
    input           lo_wena_in,
    input           rd_wena_in,
    input [4:0]     rd_waddr_in,
    input [31:0]    hi_data_in,
    input [31:0]    lo_data_in,
    input [31:0]    rd_data_in,

    input [5:0]     ex_op_in,
    input [5:0]     ex_func_in,
    input [31:0]    ex_pc4_in,
    input [31:0]    ex_alu_data_in,
    input [31:0]    ex_mul_hi_in,
    input [31:0]    ex_mul_lo_in,
    input [31:0]    ex_div_r_in,
    input [31:0]    ex_div_q_in,
    input [31:0]    ex_clz_data_in,
    input [31:0]    ex_hi_data_in,
    input [31:0]    ex_lo_data_in,
    input [31:0]    ex_rs_data_in,
    input           ex_hi_wena_in,
    input           ex_lo_wena_in,
    input           ex_rd_wena_in,
    input [1:0]     ex_hi_sel_in,
    input [1:0]     ex_lo_sel_in,
    input [2:0]     ex_rd_sel_in,
    input [4:0]     ex_rd_waddr_in,

    input [31:0]    mem_pc4_in,
    input [31:0]    mem_alu_data_in,
    input [31:0]    mem_mul_hi_in,
    input [31:0]    mem_mul_lo_in,
    input [31:0]    mem_div_q_in,
    input [31:0]    mem_div_r_in,
    input [31:0]    mem_clz_data_in,
    input [31:0]    mem_lo_data_in,
    input [31:0]    mem_hi_data_in,
    input [31:0]    mem_rs_data_in,
    input [31:0]    mem_dmem_data_in,
    input           mem_hi_wena_in,
    input           mem_lo_wena_in,
    input           mem_rd_wena_in,
    input [1:0]     mem_hi_sel_in,
    input [1:0]     mem_lo_sel_in,
    input [2:0]     mem_rd_sel_in,
    input [4:0]     mem_rd_waddr_in,


    output          stall_out,
    output          branch_out,
    output [5:0]    op_out,
    output [5:0]    func_out,
    output [2:0]    pc_sel_out,
    output [31:0]   pc4_out,
    output [31:0]   immed_out,
    output [31:0]   shamt_out,
    output [31:0]   pc_eaddr_out,
    output [31:0]   pc_baddr_out,
    output [31:0]   pc_jaddr_out,
    output [31:0]   pc_raddr_out,
    output [31:0]   rs_data_out,
    output [31:0]   rt_data_out,
    output [31:0]   hi_data_out,
    output [31:0]   lo_data_out,
    output [31:0]   cp0_data_out,
    output          alu_a_sel_out,
    output [1:0]    alu_b_sel_out,
    output [3:0]    aluc_out,
    output          mul_ena_out,
    output          div_ena_out,
    output          clz_ena_out,
    output          mul_sign_out,
    output          div_sign_out,
    output          hi_wena_out,
    output          lo_wena_out,
    output          rd_wena_out,
    output          cutter_sign_out,
    output          cutter_addr_sel_out,
    output [2:0]    cutter_sel_out,
    output          dmem_ena_out,
    output          dmem_wena_out,
    output [1:0]    dmem_wsel_out,
    output [1:0]    dmem_rsel_out,
    output [1:0]    hi_sel_out,
    output [1:0]    lo_sel_out,
    output [2:0]    rd_sel_out,
    output [4:0]    rd_waddr_out,
    output [31:0]   reg28_out
    );

    wire [5:0] opcode   = instr_in[31:26];
    wire [5:0] func_code = instr_in[5:0];
    wire [4:0] rs_idx  = instr_in[25:21];
    wire [4:0] rt_idx  = instr_in[20:16];
    wire rs_rena;
    wire rt_rena;

    wire immed_sign;
    wire mfc0_flag;
    wire mtc0_flag;
    wire eret_flag;
    
    wire [31:0] ex_df_hi_data;
    wire [31:0] ex_df_lo_data;
    wire [31:0] ex_df_rd_data;
    wire [31:0] mem_df_hi_data;
    wire [31:0] mem_df_lo_data;
    wire [31:0] mem_df_rd_data;
    
    wire        ext5_sel;
    wire [4:0]  ext5_data;
    
    wire forward_flag;
    wire is_rs_flag, is_rt_flag;
    wire [31:0] hi_df_data;
    wire [31:0] lo_df_data;
    wire [31:0] rs_df_data;
    wire [31:0] rt_df_data;
    wire [31:0] hi_data;
    wire [31:0] lo_data;
    wire [31:0] rs_data;
    wire [31:0] rt_data;

    wire        cp0_exec_flag;
    wire [4:0]  cp0_addr;
    wire [4:0]  cp0_cause;
    wire [31:0] cp0_status;

    assign immed_out    = { { 16{ immed_sign & instr_in[15] } }, instr_in[15:0] };
    assign shamt_out    = { 27'b0, ext5_data };

    assign pc_baddr_out = pc4_in + { { { 14{ instr_in[15] } }, instr_in[15:0], 2'b00 } };
    assign pc_jaddr_out = { pc4_in[31:28], instr_in[25:0], 2'b00 };
    assign pc_raddr_out = rs_data_out;

    assign rs_data_out  = (forward_flag && is_rs_flag) ? rs_df_data : rs_data;
    assign rt_data_out  = (forward_flag && is_rt_flag) ? rt_df_data : rt_data;
    assign hi_data_out  = forward_flag ? hi_df_data : hi_data;
    assign lo_data_out  = forward_flag ? lo_df_data : lo_data;

    assign pc4_out      = pc4_in;
    assign op_out       = opcode;
    assign func_out     = func_code;

    selector_2_5 sel_extend5(instr_in[10:6], rs_data_out[4:0], ext5_sel, ext5_data);

    selector_4_32 sel_ex_df_hi(ex_div_r_in, ex_mul_hi_in, ex_rs_data_in, 32'hz, ex_hi_sel_in, ex_df_hi_data);
    selector_4_32 sel_ex_df_lo(ex_div_q_in, ex_mul_lo_in, ex_rs_data_in, 32'hz, ex_lo_sel_in, ex_df_lo_data);
    selector_8_32 sel_ex_df_rd(ex_lo_data_in, ex_pc4_in, ex_clz_data_in, 32'hz, 32'hz, ex_alu_data_in, ex_hi_data_in, ex_mul_lo_in, ex_rd_sel_in, ex_df_rd_data);

    selector_4_32 sel_mem_df_hi(mem_div_q_in, mem_mul_hi_in, mem_rs_data_in, 32'hz, mem_hi_sel_in, mem_df_hi_data);
    selector_4_32 sel_mem_df_lo(mem_div_r_in, mem_mul_lo_in, mem_rs_data_in, 32'hz, mem_lo_sel_in, mem_df_lo_data);
    selector_8_32 sel_mem_df_rd(mem_lo_data_in, mem_pc4_in, mem_clz_data_in, 32'hz, mem_dmem_data_in, mem_alu_data_in, mem_hi_data_in, mem_mul_lo_in, mem_rd_sel_in, mem_df_rd_data);

    reg_bank regfile_inst(clk_sig, rst_sig, rd_wena_in, rs_idx, rt_idx, rs_rena, rt_rena, rd_waddr_in, rd_data_in, rs_data, rt_data, reg28_out);
    coprocessor0 cp0_inst(clk_sig, rst_sig, mfc0_flag, mtc0_flag, pc4_in - 32'd4, cp0_addr, rt_data_out, cp0_exec_flag, eret_flag, cp0_cause, cp0_data_out, cp0_status, pc_eaddr_out);

    reg_storage hi_inst(clk_sig, rst_sig, hi_wena_in, hi_data_in, hi_data);
    reg_storage lo_inst(clk_sig, rst_sig, lo_wena_in, lo_data_in, lo_data);

    data_forward forward_inst(
        .clk_sig(clk_sig),
        .rst_sig(rst_sig),
        .opcode(opcode),
        .func_code(func_code),
        .rs_rena(rs_rena),
        .rt_rena(rt_rena),
        .rs_idx(rs_idx),
        .rt_idx(rt_idx),
        .exe_opcode(ex_op_in),
        .exe_func_code(ex_func_in),
        .exe_hi_data(ex_df_hi_data),
        .exe_lo_data(ex_df_lo_data),
        .exe_rd_data(ex_df_rd_data),
        .exe_hi_wena(ex_hi_wena_in),
        .exe_lo_wena(ex_lo_wena_in),
        .exe_rd_wena(ex_rd_wena_in),
        .exe_rd_idx(ex_rd_waddr_in),
        .mem_hi_data(mem_df_hi_data),
        .mem_lo_data(mem_df_lo_data),
        .mem_rd_data(mem_df_rd_data),
        .mem_hi_wena(mem_hi_wena_in),
        .mem_lo_wena(mem_lo_wena_in),
        .mem_rd_wena(mem_rd_wena_in),
        .mem_rd_idx(mem_rd_waddr_in),
        .stall_out(stall_out),
        .forward_out(forward_flag),
        .is_rs_out(is_rs_flag),
        .is_rt_out(is_rt_flag),
        .rs_data_out(rs_df_data),
        .rt_data_out(rt_df_data),
        .hi_data_out(hi_df_data),
        .lo_data_out(lo_df_data)
        );
	
    branch_comp comp_inst(clk_sig, rst_sig, rs_data_out, rt_data_out, opcode, func_code, cp0_exec_flag, branch_out);

    ctrl_unit ctrl_inst(
        .branch_flag(branch_out),
        .status_val(cp0_status),
        .instr_val(instr_in),
        .pc_sel_out(pc_sel_out),
        .immed_sign_out(immed_sign),
        .ext5_sel_out(ext5_sel),
        .rs_rena_out(rs_rena),
        .rt_rena_out(rt_rena),
        .alu_a_sel_out(alu_a_sel_out),
        .alu_b_sel_out(alu_b_sel_out),
        .aluc_out(aluc_out),
        .mul_ena_out(mul_ena_out),
        .div_ena_out(div_ena_out),
        .clz_ena_out(clz_ena_out),
        .mul_sign_out(mul_sign_out),
        .div_sign_out(div_sign_out),
        .cutter_sign_out(cutter_sign_out),
        .cutter_addr_sel_out(cutter_addr_sel_out),
        .cutter_sel_out(cutter_sel_out),
        .dmem_ena_out(dmem_ena_out),
        .dmem_wena_out(dmem_wena_out),
        .dmem_wsel_out(dmem_wsel_out),
        .dmem_rsel_out(dmem_rsel_out),
        .eret_out(eret_flag),
        .cause_out(cp0_cause),
        .exception_out(cp0_exec_flag),
        .cp0_addr_out(cp0_addr),
        .mfc0_out(mfc0_flag),
        .mtc0_out(mtc0_flag),
        .hi_wena_out(hi_wena_out),
        .lo_wena_out(lo_wena_out),
        .rd_wena_out(rd_wena_out),
        .hi_sel_out(hi_sel_out),
        .lo_sel_out(lo_sel_out),
        .rd_sel_out(rd_sel_out),
        .rdc_out(rd_waddr_out)
        );

endmodule

module pipe_id_ex(
    input               idex_clk,
    input               idex_rst,
    input               idex_we_in,
    input               idex_stall_in,
    input [5:0]         idex_op_in,
    input [5:0]         idex_func_in,
    input [31:0]        idex_pc4_in,
    input [31:0]        idex_imm_in,
    input [31:0]        idex_shamt_in,
    input [31:0]        idex_rs_in,
    input [31:0]        idex_rt_in,
    input [31:0]        idex_hi_in,
    input [31:0]        idex_lo_in,
    input [31:0]        idex_cp0_in,
    input               idex_alu_a_sel_in,
    input [1:0]         idex_alu_b_sel_in,
    input [3:0]         idex_aluc_in,
    input               idex_mul_en_in,
    input               idex_clz_en_in,
    input               idex_div_en_in,
    input               idex_mul_signed_in,
    input               idex_div_signed_in,
    input               idex_cut_sign_in,
    input               idex_cut_addr_sel_in,
    input [2:0]         idex_cut_sel_in,
    input               idex_dmem_en_in,
    input               idex_dmem_we_in,
    input [1:0]         idex_dmem_wsel_in,
    input [1:0]         idex_dmem_rsel_in,
    input               idex_hi_we_in,
    input               idex_lo_we_in,
    input               idex_rd_we_in,
    input [1:0]         idex_hi_sel_in,
    input [1:0]         idex_lo_sel_in,
    input [2:0]         idex_rd_sel_in,
    input [4:0]         idex_rd_addr_in,

    output reg [5:0]    idex_op_out,
    output reg [5:0]    idex_func_out,
    output reg [31:0]   idex_pc4_out,
    output reg [31:0]   idex_imm_out,
    output reg [31:0]   idex_shamt_out,
    output reg [31:0]   idex_rs_out,
    output reg [31:0]   idex_rt_out,
    output reg [31:0]   idex_hi_out,
    output reg [31:0]   idex_lo_out,
    output reg [31:0]   idex_cp0_out,
    output reg          idex_alu_a_sel_out,
    output reg [1:0]    idex_alu_b_sel_out,
    output reg [3:0]    idex_aluc_out,
    output reg          idex_clz_en_out,
    output reg          idex_mul_en_out,
    output reg          idex_div_en_out,
    output reg          idex_mul_signed_out,
    output reg          idex_div_signed_out,
    output reg          idex_cut_sign_out,
    output reg          idex_cut_addr_sel_out,
    output reg [2:0]    idex_cut_sel_out,
    output reg          idex_dmem_en_out,
    output reg          idex_dmem_we_out,
    output reg [1:0]    idex_dmem_wsel_out,
    output reg [1:0]    idex_dmem_rsel_out,
    output reg          idex_rd_we_out,
    output reg          idex_hi_we_out,
    output reg          idex_lo_we_out,
    output reg [1:0]    idex_hi_sel_out,
    output reg [1:0]    idex_lo_sel_out,
    output reg [2:0]    idex_rd_sel_out,
    output reg [4:0]    idex_rd_addr_out
    );

    always @(posedge idex_clk or posedge idex_rst) 
    begin
        if(idex_rst) 
        begin
            idex_cut_sign_out      <= 1'b0;
            idex_cut_addr_sel_out  <= 1'b0;
            idex_cut_sel_out       <= 3'b0;
            idex_dmem_en_out       <= 1'b0;
            idex_dmem_we_out       <= 1'b0;
            idex_dmem_wsel_out     <= 2'b0;
            idex_dmem_rsel_out     <= 2'b0;
            idex_op_out            <= 6'b0;
            idex_func_out          <= 6'b0;
            idex_imm_out           <= 32'b0;
            idex_shamt_out         <= 32'b0;
            idex_pc4_out           <= 32'b0;
            idex_rs_out            <= 32'b0;
            idex_rt_out            <= 32'b0;
            idex_hi_out            <= 32'b0;
            idex_lo_out            <= 32'b0;
            idex_cp0_out           <= 32'b0;
            idex_alu_a_sel_out     <= 1'b0;
            idex_alu_b_sel_out     <= 1'b0;
            idex_aluc_out          <= 4'b0;
            idex_mul_en_out        <= 1'b0;
            idex_div_en_out        <= 1'b0;
            idex_clz_en_out        <= 1'b0;
            idex_mul_signed_out    <= 1'b0;
            idex_div_signed_out    <= 1'b0;
            idex_hi_we_out         <= 1'b0;
            idex_lo_we_out         <= 1'b0;
            idex_rd_we_out         <= 1'b0;
            idex_hi_sel_out        <= 2'b0;
            idex_lo_sel_out        <= 2'b0;
            idex_rd_sel_out        <= 3'b0;
            idex_rd_addr_out       <= 5'b0;
        end
        else if(idex_stall_in)
        begin
            // Stall时插入NOP：清零控制信号，但保持数据（或清零数据）
            idex_cut_sign_out     <= 1'b0;
            idex_cut_addr_sel_out <= 1'b0;
            idex_cut_sel_out      <= 3'b0;
            idex_dmem_en_out      <= 1'b0;
            idex_dmem_we_out      <= 1'b0;
            idex_dmem_wsel_out    <= 2'b0;
            idex_dmem_rsel_out    <= 2'b0;
            idex_op_out           <= 6'b0;
            idex_func_out         <= 6'b0;
            idex_rd_we_out        <= 1'b0;
            idex_hi_we_out        <= 1'b0;
            idex_lo_we_out        <= 1'b0;
            idex_mul_en_out       <= 1'b0;
            idex_div_en_out       <= 1'b0;
            idex_clz_en_out       <= 1'b0;
            // 数据可以保持或清零，这里选择清零以避免X�?
            idex_imm_out           <= 32'b0;
            idex_shamt_out         <= 32'b0;
            idex_pc4_out           <= 32'b0;
            idex_rs_out            <= 32'b0;
            idex_rt_out            <= 32'b0;
            idex_hi_out            <= 32'b0;
            idex_lo_out            <= 32'b0;
            idex_cp0_out           <= 32'b0;
            idex_alu_a_sel_out     <= 1'b0;
            idex_alu_b_sel_out     <= 1'b0;
            idex_aluc_out          <= 4'b0;
            idex_mul_signed_out    <= 1'b0;
            idex_div_signed_out    <= 1'b0;
            idex_hi_sel_out        <= 2'b0;
            idex_lo_sel_out        <= 2'b0;
            idex_rd_sel_out        <= 3'b0;
            idex_rd_addr_out       <= 5'b0;
        end
        else if(idex_we_in && !idex_stall_in) 
        begin
            idex_op_out              <= idex_op_in;
            idex_func_out            <= idex_func_in;
            idex_imm_out             <= idex_imm_in;
            idex_shamt_out           <= idex_shamt_in;
            idex_pc4_out             <= idex_pc4_in;
            idex_dmem_en_out         <= idex_dmem_en_in;
            idex_dmem_we_out         <= idex_dmem_we_in;
            idex_dmem_wsel_out       <= idex_dmem_wsel_in;
            idex_dmem_rsel_out       <= idex_dmem_rsel_in;
            idex_alu_a_sel_out       <= idex_alu_a_sel_in;
            idex_alu_b_sel_out       <= idex_alu_b_sel_in;
            idex_aluc_out            <= idex_aluc_in;
            idex_rs_out              <= idex_rs_in;
            idex_rt_out              <= idex_rt_in;
            idex_hi_out              <= idex_hi_in;
            idex_lo_out              <= idex_lo_in;
            idex_cp0_out             <= idex_cp0_in;
            idex_cut_sign_out        <= idex_cut_sign_in;
            idex_cut_addr_sel_out    <= idex_cut_addr_sel_in;
            idex_cut_sel_out         <= idex_cut_sel_in;
            idex_mul_en_out          <= idex_mul_en_in;
            idex_div_en_out          <= idex_div_en_in;
            idex_clz_en_out          <= idex_clz_en_in;
            idex_mul_signed_out      <= idex_mul_signed_in;
            idex_div_signed_out      <= idex_div_signed_in;
            idex_hi_we_out           <= idex_hi_we_in;
            idex_lo_we_out           <= idex_lo_we_in;
            idex_rd_we_out           <= idex_rd_we_in;
            idex_hi_sel_out          <= idex_hi_sel_in;
            idex_lo_sel_out          <= idex_lo_sel_in;
            idex_rd_sel_out          <= idex_rd_sel_in;
            idex_rd_addr_out         <= idex_rd_addr_in;
        end
    end 
endmodule

module pipe_ex(
    input           rst_ex,
    input [31:0]    pc4_ex_in,
    input [31:0]    imm_ex_in,
    input [31:0]    shamt_ex_in,
    input [31:0]    rs_ex_in,
    input [31:0]    rt_ex_in,
    input [31:0]    hi_ex_in,
    input [31:0]    lo_ex_in,
    input [31:0]    cp0_ex_in,
    input           alu_a_sel_ex,
    input [1:0]     alu_b_sel_ex,
    input [3:0]     aluc_ex,
    input           mul_en_ex,
    input           div_en_ex,
    input           clz_en_ex,
    input           mul_signed_ex,
    input           div_signed_ex,
    input           cut_sign_ex,
    input           cut_addr_sel_ex,
    input [2:0]     cut_sel_ex,
    input           dmem_en_ex,
    input           dmem_we_ex,
    input [1:0]     dmem_wsel_ex,
    input [1:0]     dmem_rsel_ex,
    input           rd_we_ex,
    input           hi_we_ex,
    input           lo_we_ex,
    input [1:0]     hi_sel_ex,
    input [1:0]     lo_sel_ex,
    input [2:0]     rd_sel_ex,
    input [4:0]     rd_addr_ex_in,
    output [31:0]   pc4_ex_out,
    output [31:0]   mul_hi_ex_out,
    output [31:0]   mul_lo_ex_out,
    output [31:0]   div_r_ex_out,
    output [31:0]   div_q_ex_out,
    output [31:0]   rs_ex_out,
    output [31:0]   rt_ex_out,
    output [31:0]   hi_ex_out,
    output [31:0]   lo_ex_out,
    output [31:0]   cp0_ex_out,
    output [31:0]   clz_ex_out,
    output [31:0]   alu_ex_out,
    output          cut_sign_ex_out,
    output          cut_addr_sel_ex_out,
    output [2:0]    cut_sel_ex_out,
    output          dmem_en_ex_out,
    output          dmem_we_ex_out,
    output [1:0]    dmem_wsel_ex_out,
    output [1:0]    dmem_rsel_ex_out,
    output          hi_we_ex_out,
    output          lo_we_ex_out,
    output          rd_we_ex_out,
    output [1:0]    hi_sel_ex_out,
    output [1:0]    lo_sel_ex_out,
    output [2:0]    rd_sel_ex_out,
    output [4:0]    rd_addr_ex_out
);

    wire [31:0] alu_src_a_ex;
    wire [31:0] alu_src_b_ex;
    wire zero_flag_ex, carry_flag_ex, neg_flag_ex, ovf_flag_ex;

    assign pc4_ex_out           = pc4_ex_in;
    assign cut_sign_ex_out      = cut_sign_ex;
    assign cut_addr_sel_ex_out  = cut_addr_sel_ex;
    assign cut_sel_ex_out       = cut_sel_ex;
    assign dmem_en_ex_out       = dmem_en_ex;
    assign dmem_we_ex_out       = dmem_we_ex;
    assign dmem_rsel_ex_out     = dmem_rsel_ex;
    assign dmem_wsel_ex_out     = dmem_wsel_ex;
    assign rs_ex_out            = rs_ex_in;
    assign rt_ex_out            = rt_ex_in;
    assign hi_ex_out            = hi_ex_in;
    assign lo_ex_out            = lo_ex_in;
    assign cp0_ex_out           = cp0_ex_in;
    assign rd_we_ex_out         = rd_we_ex;
    assign hi_we_ex_out         = hi_we_ex;
    assign lo_we_ex_out         = lo_we_ex;
    assign hi_sel_ex_out        = hi_sel_ex;
    assign lo_sel_ex_out        = lo_sel_ex;
    assign rd_sel_ex_out        = rd_sel_ex;
    assign rd_addr_ex_out       = rd_addr_ex_in;

    selector_2_32 sel_alu_a(shamt_ex_in, rs_ex_in, alu_a_sel_ex, alu_src_a_ex);
    selector_4_32 sel_alu_b(rt_ex_in, imm_ex_in, 32'bz, 32'bz, alu_b_sel_ex, alu_src_b_ex);
    arithmetic_unit alu_inst(alu_src_a_ex, alu_src_b_ex, aluc_ex, alu_ex_out, zero_flag_ex, carry_flag_ex, neg_flag_ex, ovf_flag_ex);

    multiplier mult_inst(rst_ex, mul_en_ex, mul_signed_ex, rs_ex_in, rt_ex_in, mul_hi_ex_out, mul_lo_ex_out);
    divider    div_inst(rst_ex, div_en_ex, div_signed_ex, rs_ex_in, rt_ex_in, div_q_ex_out, div_r_ex_out);

    leading_zero_cnt clz_inst(rs_ex_in, clz_en_ex, clz_ex_out);

endmodule


module pipe_ex_mem(
    input               clk_exmem,
    input               rst_exmem,
    input               exmem_we_in,
    input [31:0]        exmem_pc4_in,
    input [31:0]        exmem_rs_in,
    input [31:0]        exmem_rt_in,
    input [31:0]        exmem_hi_in,
    input [31:0]        exmem_lo_in,
    input [31:0]        exmem_cp0_in,
    input [31:0]        exmem_alu_in,
    input [31:0]        exmem_mul_hi_in,
    input [31:0]        exmem_mul_lo_in,
    input [31:0]        exmem_div_r_in,
    input [31:0]        exmem_div_q_in,
    input [31:0]        exmem_clz_in,
    input               exmem_cut_sign_in,
    input [2:0]         exmem_cut_sel_in,
    input               exmem_cut_addr_sel_in,
    input               exmem_dmem_en_in,
    input               exmem_dmem_we_in,
    input [1:0]         exmem_dmem_wsel_in,
    input [1:0]         exmem_dmem_rsel_in,
    input               exmem_hi_we_in,
    input               exmem_lo_we_in,
    input               exmem_rd_we_in,
    input [1:0]         exmem_hi_sel_in,
    input [1:0]         exmem_lo_sel_in,
    input [2:0]         exmem_rd_sel_in,
    input [4:0]         exmem_rd_addr_in,

    output reg [31:0]   exmem_pc4_out,
    output reg [31:0]   exmem_rs_out,
    output reg [31:0]   exmem_rt_out,
    output reg [31:0]   exmem_hi_out,
    output reg [31:0]   exmem_lo_out,
    output reg [31:0]   exmem_cp0_out,
    output reg [31:0]   exmem_alu_out,
    output reg [31:0]   exmem_mul_hi_out,
    output reg [31:0]   exmem_mul_lo_out,
    output reg [31:0]   exmem_div_r_out,
    output reg [31:0]   exmem_div_q_out,
    output reg [31:0]   exmem_clz_out,
    output reg          exmem_cut_sign_out,
    output reg          exmem_cut_addr_sel_out,
    output reg [2:0]    exmem_cut_sel_out,
    output reg          exmem_dmem_en_out,
    output reg          exmem_dmem_we_out,
    output reg [1:0]    exmem_dmem_wsel_out,
    output reg [1:0]    exmem_dmem_rsel_out,
    output reg          exmem_rd_we_out,
    output reg          exmem_hi_we_out,
    output reg          exmem_lo_we_out,
    output reg [1:0]    exmem_hi_sel_out,
    output reg [1:0]    exmem_lo_sel_out,
    output reg [2:0]    exmem_rd_sel_out,
    output reg [4:0]    exmem_rd_addr_out
);

always @(posedge clk_exmem or posedge rst_exmem) 
begin
    if(rst_exmem) 
    begin
        exmem_pc4_out           <= 32'b0;
        exmem_rs_out            <= 32'b0;
        exmem_rt_out            <= 32'b0;
        exmem_alu_out           <= 32'b0;
        exmem_mul_hi_out        <= 32'b0;
        exmem_mul_lo_out        <= 32'b0;
        exmem_div_r_out         <= 32'b0;
        exmem_div_q_out         <= 32'b0;
        exmem_clz_out           <= 32'b0;
        exmem_hi_out            <= 32'b0;
        exmem_lo_out            <= 32'b0;
        exmem_cp0_out           <= 32'b0;
        exmem_rd_addr_out       <= 5'b0;
        exmem_cut_sign_out      <= 1'b0;
        exmem_cut_addr_sel_out  <= 1'b0;
        exmem_cut_sel_out       <= 3'b0;
        exmem_dmem_en_out       <= 1'b0;
        exmem_dmem_we_out       <= 1'b0;
        exmem_dmem_wsel_out     <= 1'b0;
        exmem_dmem_rsel_out     <= 1'b0;
        exmem_hi_we_out         <= 1'b0;
        exmem_lo_we_out         <= 1'b0;
        exmem_rd_we_out         <= 1'b0;
        exmem_hi_sel_out        <= 2'b0;
        exmem_lo_sel_out        <= 2'b0;
        exmem_rd_sel_out        <= 3'b0;
    end 
    else if(exmem_we_in) 
    begin
        exmem_mul_hi_out        <= exmem_mul_hi_in;
        exmem_mul_lo_out        <= exmem_mul_lo_in;
        exmem_div_r_out         <= exmem_div_r_in;
        exmem_div_q_out         <= exmem_div_q_in;
        exmem_clz_out           <= exmem_clz_in;
        exmem_alu_out           <= exmem_alu_in;
        exmem_pc4_out           <= exmem_pc4_in;
        exmem_rs_out            <= exmem_rs_in;
        exmem_rt_out            <= exmem_rt_in;
        exmem_hi_out            <= exmem_hi_in;
        exmem_lo_out            <= exmem_lo_in;
        exmem_cp0_out           <= exmem_cp0_in;
        exmem_cut_sign_out      <= exmem_cut_sign_in;
        exmem_cut_addr_sel_out  <= exmem_cut_addr_sel_in;
        exmem_cut_sel_out       <= exmem_cut_sel_in;
        exmem_dmem_en_out       <= exmem_dmem_en_in;
        exmem_dmem_we_out       <= exmem_dmem_we_in;
        exmem_dmem_wsel_out     <= exmem_dmem_wsel_in;
        exmem_dmem_rsel_out     <= exmem_dmem_rsel_in;
        exmem_hi_we_out         <= exmem_hi_we_in;
        exmem_lo_we_out         <= exmem_lo_we_in;
        exmem_rd_we_out         <= exmem_rd_we_in;
        exmem_hi_sel_out        <= exmem_hi_sel_in;
        exmem_lo_sel_out        <= exmem_lo_sel_in;
        exmem_rd_sel_out        <= exmem_rd_sel_in;
        exmem_rd_addr_out       <= exmem_rd_addr_in;
    end
end

endmodule

module pipe_mem(
    input           mem_clk,
    input [31:0]    mem_pc4_in,
    input [31:0]    mem_rs_in,
    input [31:0]    mem_rt_in,
    input [31:0]    mem_hi_in,
    input [31:0]    mem_lo_in,
    input [31:0]    mem_cp0_in,
    input [31:0]    mem_alu_in,
    input [31:0]    mem_mul_hi_in,
    input [31:0]    mem_mul_lo_in,
    input [31:0]    mem_div_r_in,
    input [31:0]    mem_div_q_in,
    input [31:0]    mem_clz_in,
    input           mem_cut_sign_in,
    input           mem_cut_addr_sel_in,
    input [2:0]     mem_cut_sel_in,
    input [1:0]     mem_dmem_wsel_in,
    input [1:0]     mem_dmem_rsel_in,
    input           mem_dmem_en_in,
    input           mem_dmem_we_in,
    input           mem_hi_we_in,
    input           mem_lo_we_in,
    input           mem_rd_we_in,
    input [1:0]     mem_hi_sel_in,
    input [1:0]     mem_lo_sel_in,
    input [2:0]     mem_rd_sel_in,
    input [4:0]     mem_rd_addr_in,

    output [31:0]   mem_pc4_out,
    output [31:0]   mem_rs_out,
    output [31:0]   mem_hi_out,
    output [31:0]   mem_lo_out,
    output [31:0]   mem_cp0_out,
    output [31:0]   mem_alu_out,
    output [31:0]   mem_mul_hi_out,
    output [31:0]   mem_mul_lo_out,
    output [31:0]   mem_div_r_out,
    output [31:0]   mem_div_q_out,
    output [31:0]   mem_clz_out,
    output [31:0]   mem_dmem_data_out,
    output          mem_hi_we_out,
    output          mem_lo_we_out,
    output          mem_rd_we_out,
    output [1:0]    mem_hi_sel_out,
    output [1:0]    mem_lo_sel_out,
    output [2:0]    mem_rd_sel_out,
    output [4:0]    mem_rd_addr_out
    );

    wire [31:0] cut_data_in;
	wire [31:0] dmem_word_tmp;

    assign mem_pc4_out      = mem_pc4_in;
	assign mem_mul_hi_out   = mem_mul_hi_in;
    assign mem_mul_lo_out   = mem_mul_lo_in;
    assign mem_div_q_out    = mem_div_q_in;
    assign mem_div_r_out    = mem_div_r_in;
    assign mem_clz_out      = mem_clz_in;
    assign mem_alu_out      = mem_alu_in;
    assign mem_rs_out       = mem_rs_in;
    assign mem_hi_out       = mem_hi_in;
    assign mem_lo_out       = mem_lo_in;
    assign mem_cp0_out      = mem_cp0_in;
    assign mem_hi_we_out    = mem_hi_we_in;
    assign mem_lo_we_out    = mem_lo_we_in;
    assign mem_rd_we_out    = mem_rd_we_in;
    assign mem_hi_sel_out   = mem_hi_sel_in;
    assign mem_lo_sel_out   = mem_lo_sel_in;
    assign mem_rd_sel_out   = mem_rd_sel_in;
    assign mem_rd_addr_out  = mem_rd_addr_in;

    selector_2_32 sel_cutter(mem_rt_in, dmem_word_tmp, mem_cut_addr_sel_in, cut_data_in);
    data_extractor extractor_inst(cut_data_in, mem_cut_sel_in, mem_cut_sign_in, mem_dmem_data_out);

    data_memory dmem_inst(mem_clk, mem_dmem_en_in, mem_dmem_we_in, mem_dmem_wsel_in, mem_dmem_rsel_in, 
                    mem_dmem_data_out, mem_alu_in, dmem_word_tmp);

endmodule
module pipe_mem_wb(
    input               memwb_clk,
    input               memwb_rst,
    input               memwb_we_in,
    input [31:0]        memwb_pc4_in,
    input [31:0]        memwb_rs_in,
    input [31:0]        memwb_hi_in,
    input [31:0]        memwb_lo_in,
    input [31:0]        memwb_cp0_in,
    input [31:0]        memwb_alu_in,
    input [31:0]        memwb_mul_hi_in,
    input [31:0]        memwb_mul_lo_in,
    input [31:0]        memwb_div_r_in,
    input [31:0]        memwb_div_q_in,
    input [31:0]        memwb_clz_in,
    input [31:0]        memwb_dmem_in,
    input               memwb_hi_we_in,
    input               memwb_lo_we_in,
    input               memwb_rd_we_in,
    input [1:0]         memwb_hi_sel_in,
    input [1:0]         memwb_lo_sel_in,
    input [2:0]         memwb_rd_sel_in,
    input [4:0]         memwb_rd_addr_in,

    output reg [31:0]   memwb_pc4_out,
    output reg [31:0]   memwb_rs_out,
    output reg [31:0]   memwb_hi_out,
    output reg [31:0]   memwb_lo_out,
    output reg [31:0]   memwb_cp0_out,
    output reg [31:0]   memwb_alu_out,
    output reg [31:0]   memwb_mul_hi_out,
    output reg [31:0]   memwb_mul_lo_out,
    output reg [31:0]   memwb_div_r_out,
    output reg [31:0]   memwb_div_q_out,
    output reg [31:0]   memwb_clz_out,
    output reg [31:0]   memwb_dmem_out,
    output reg          memwb_hi_we_out,
    output reg          memwb_lo_we_out,
    output reg          memwb_rd_we_out,
    output reg [1:0]    memwb_hi_sel_out,
    output reg [1:0]    memwb_lo_sel_out,
    output reg [2:0]    memwb_rd_sel_out,
    output reg [4:0]    memwb_rd_addr_out
    );

    always @(posedge memwb_clk or posedge memwb_rst) 
    begin
        if(memwb_rst)
        begin
            memwb_pc4_out      <= 32'b0;
            memwb_rs_out       <= 32'b0;
            memwb_hi_out       <= 32'b0;
            memwb_lo_out       <= 32'b0;
            memwb_cp0_out      <= 32'b0;
            memwb_alu_out      <= 32'b0;
            memwb_mul_hi_out   <= 32'b0;
            memwb_mul_lo_out   <= 32'b0;
            memwb_div_r_out    <= 32'b0;
            memwb_div_q_out    <= 32'b0;
            memwb_clz_out      <= 32'b0;
            memwb_dmem_out     <= 32'b0;
            memwb_rd_we_out    <= 1'b0;
            memwb_hi_we_out    <= 1'b0;
            memwb_lo_we_out    <= 1'b0;
            memwb_hi_sel_out   <= 2'b0;
            memwb_lo_sel_out   <= 2'b0;
            memwb_rd_sel_out   <= 3'b0;
            memwb_rd_addr_out  <= 5'b0;
        end
        else if(memwb_we_in)
        begin
            memwb_pc4_out      <= memwb_pc4_in;		    
            memwb_rs_out       <= memwb_rs_in;
            memwb_hi_out       <= memwb_hi_in;
            memwb_lo_out       <= memwb_lo_in;
            memwb_cp0_out      <= memwb_cp0_in;
            memwb_alu_out      <= memwb_alu_in;
            memwb_mul_hi_out   <= memwb_mul_hi_in;			
            memwb_mul_lo_out   <= memwb_mul_lo_in;
            memwb_div_r_out    <= memwb_div_r_in;			
            memwb_div_q_out    <= memwb_div_q_in;
            memwb_clz_out      <= memwb_clz_in;
            memwb_dmem_out     <= memwb_dmem_in;
            memwb_rd_we_out    <= memwb_rd_we_in;
            memwb_hi_we_out    <= memwb_hi_we_in;
            memwb_lo_we_out    <= memwb_lo_we_in;
            memwb_hi_sel_out   <= memwb_hi_sel_in;
            memwb_lo_sel_out   <= memwb_lo_sel_in;
            memwb_rd_sel_out   <= memwb_rd_sel_in;
            memwb_rd_addr_out  <= memwb_rd_addr_in;
        end
    end 

endmodule

module pipe_wb(
    input [31:0]    wb_pc4_in,
    input [31:0]    wb_rs_in,
    input [31:0]    wb_hi_in,
    input [31:0]    wb_lo_in,
    input [31:0]    wb_cp0_in,
    input [31:0]    wb_alu_in,
    input [31:0]    wb_mul_hi_in,
    input [31:0]    wb_mul_lo_in,
    input [31:0]    wb_div_r_in,
    input [31:0]    wb_div_q_in,
    input [31:0]    wb_clz_in,
    input [31:0]    wb_dmem_in,
    input           wb_hi_we_in,
    input           wb_lo_we_in,
    input           wb_rd_we_in,
    input [1:0]     wb_hi_sel_in,
    input [1:0]     wb_lo_sel_in,
    input [2:0]     wb_rd_sel_in,
    input [4:0]     wb_rd_addr_in,

    output          wb_hi_we_out,
    output          wb_lo_we_out,
    output          wb_rd_we_out,
    output [4:0]    wb_rd_addr_out,
    output [31:0]   wb_hi_out,
    output [31:0]   wb_lo_out,
    output [31:0]   wb_data_out
    );
	
    assign wb_hi_we_out   = wb_hi_we_in;
    assign wb_lo_we_out   = wb_lo_we_in;
	assign wb_rd_we_out   = wb_rd_we_in;
	assign wb_rd_addr_out = wb_rd_addr_in;

    selector_4_32 sel_hi(wb_div_r_in, wb_mul_hi_in, wb_rs_in, 32'hz, wb_hi_sel_in, wb_hi_out);
    selector_4_32 sel_lo(wb_div_q_in, wb_mul_lo_in, wb_rs_in, 32'hz, wb_lo_sel_in, wb_lo_out);

    selector_8_32 sel_rd(wb_lo_out, wb_pc4_in, wb_clz_in, wb_cp0_in, 
                    wb_dmem_in, wb_alu_in, wb_hi_out, wb_mul_lo_in, 
                    wb_rd_sel_in, wb_data_out);

endmodule
