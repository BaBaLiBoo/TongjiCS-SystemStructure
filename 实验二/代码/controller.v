`include "mips_def.vh"
`timescale 1ns / 1ps

module ctrl_unit (
    input           branch_flag,
    input [31:0]    status_val,
    input [31:0]    instr_val,

    output [2:0]    pc_sel_out,
    output          immed_sign_out,
    output          ext5_sel_out,
    output          rs_rena_out,
    output          rt_rena_out,
    output          alu_a_sel_out,
    output [1:0]    alu_b_sel_out,
    output [3:0]    aluc_out,
    output          mul_ena_out,
    output          div_ena_out,
    output          clz_ena_out,
    output          mul_sign_out,
    output          div_sign_out,
    output          cutter_sign_out,
    output          cutter_addr_sel_out,
    output [2:0]    cutter_sel_out,
    output          dmem_ena_out,
    output          dmem_wena_out,
    output [1:0]    dmem_wsel_out,
    output [1:0]    dmem_rsel_out,
    output          eret_out,
    output [4:0]    cause_out,
    output          exception_out,
    output [4:0]    cp0_addr_out,
    output          mfc0_out,
    output          mtc0_out,
    output          hi_wena_out,
    output          lo_wena_out,
    output          rd_wena_out,
    output [1:0]    hi_sel_out,
    output [1:0]    lo_sel_out,
    output [2:0]    rd_sel_out,
    output [4:0]    rdc_out
    );

    wire [5:0] opcode   = instr_val[31:26];
    wire [5:0] func_code = instr_val[5:0];

    wire is_addi       = (opcode == 6'b001000);
    wire is_addiu      = (opcode == 6'b001001);
    wire is_andi       = (opcode == 6'b001100);
    wire is_ori        = (opcode == 6'b001101);
    wire is_sltiu      = (opcode == 6'b001011);
    wire is_lui        = (opcode == 6'b001111);
    wire is_xori       = (opcode == 6'b001110);
    wire is_slti       = (opcode == 6'b001010);
    wire is_addu       = (opcode == 6'b000000 && func_code == 6'b100001);
    wire is_and        = (opcode == 6'b000000 && func_code == 6'b100100);
    wire is_beq        = (opcode == 6'b000100);
    wire is_bne        = (opcode == 6'b000101);
    wire is_j          = (opcode == 6'b000010);
    wire is_jal        = (opcode == 6'b000011);
    wire is_jr         = (opcode == 6'b000000 && func_code == 6'b001000);
    wire is_lw         = (opcode == 6'b100011);
    wire is_xor        = (opcode == 6'b000000 && func_code == 6'b100110);
    wire is_nor        = (opcode == 6'b000000 && func_code == 6'b100111);
    wire is_or         = (opcode == 6'b000000 && func_code == 6'b100101);
    wire is_sll        = (opcode == 6'b000000 && func_code == 6'b000000);
    wire is_sllv       = (opcode == 6'b000000 && func_code == 6'b000100);
    wire is_sltu       = (opcode == 6'b000000 && func_code == 6'b101011);
    wire is_sra        = (opcode == 6'b000000 && func_code == 6'b000011);
    wire is_srl        = (opcode == 6'b000000 && func_code == 6'b000010);
    wire is_subu       = (opcode == 6'b000000 && func_code == 6'b100011);
    wire is_sw         = (opcode == 6'b101011);
    wire is_add        = (opcode == 6'b000000 && func_code == 6'b100000);
    wire is_sub        = (opcode == 6'b000000 && func_code == 6'b100010);
    wire is_slt        = (opcode == 6'b000000 && func_code == 6'b101010);
    wire is_srlv       = (opcode == 6'b000000 && func_code == 6'b000110);
    wire is_srav       = (opcode == 6'b000000 && func_code == 6'b000111);
    wire is_clz        = (opcode == 6'b011100 && func_code == 6'b100000);
    wire is_divu       = (opcode == 6'b000000 && func_code == 6'b011011);
    wire is_eret       = (opcode == 6'b010000 && func_code == 6'b011000);
    wire is_jalr       = (opcode == 6'b000000 && func_code == 6'b001001);
    wire is_lb         = (opcode == 6'b100000);
    wire is_lbu        = (opcode == 6'b100100);
    wire is_lhu        = (opcode == 6'b100101);
    wire is_sb         = (opcode == 6'b101000);
    wire is_sh         = (opcode == 6'b101001);
    wire is_lh         = (opcode == 6'b100001);
    wire is_mfc0       = (instr_val[31:21] == 11'b01000000000 && instr_val[10:3] == 8'b0);
    wire is_mfhi       = (opcode == 6'b000000 && func_code == 6'b010000);
    wire is_mflo       = (opcode == 6'b000000 && func_code == 6'b010010);
    wire is_mtc0       = (instr_val[31:21] == 11'b01000000100 && instr_val[10:3] == 8'b0);
	wire is_mthi       = (opcode == 6'b000000 && func_code == 6'b010001);
	wire is_mtlo       = (opcode == 6'b000000 && func_code == 6'b010011);
    wire is_mul        = (opcode == 6'b011100 && func_code == 6'b000010);
	wire is_multu      = (opcode == 6'b000000 && func_code == 6'b011001);
	wire is_syscall    = (opcode == 6'b000000 && func_code == 6'b001100);
	wire is_div        = (opcode == 6'b000000 && func_code == 6'b011010);
	wire is_teq        = (opcode == 6'b000000 && func_code == 6'b110100);
    wire is_bgez       = (opcode == 6'b000001);
    wire is_break      = (opcode == 6'b000000 && func_code == 6'b001101);

    assign pc_sel_out[2] = (is_beq & branch_flag) | (is_bne & branch_flag) | (is_bgez & branch_flag) | is_eret;
    assign pc_sel_out[1] = ~(is_j | is_jr | is_jal | is_jalr | (is_beq & branch_flag) | (is_bne & branch_flag) | (is_bgez & branch_flag) | is_eret);
    assign pc_sel_out[0] = is_eret | exception_out | is_jr | is_jalr;

    assign ext5_sel_out     = is_sllv | is_srav | is_srlv;
    assign immed_sign_out   = is_addi | is_addiu | is_sltiu | is_slti;

    assign aluc_out[3]      = is_lui | is_srl | is_slt | is_sltu | is_sllv | is_srlv | is_srav | is_sra | is_slti | is_sltiu | is_sll;
    assign aluc_out[2]      = is_and | is_or | is_xor | is_nor | is_sll | is_srl | is_sra | is_sllv | is_srlv | is_srav | is_andi | is_ori | is_xori;
    assign aluc_out[1]      = is_add | is_sub | is_xor | is_nor | is_slt | is_sltu | is_sll | is_sllv | is_addi | is_xori | is_beq | is_bne | is_slti | is_sltiu | is_bgez | is_teq;
    assign aluc_out[0]      = is_subu | is_sub | is_or | is_nor | is_slt | is_sllv | is_srlv | is_sll | is_srl | is_slti | is_ori | is_beq | is_bne | is_bgez | is_teq;
    assign alu_a_sel_out    = ~(is_sll | is_srl | is_sra | is_div | is_divu | is_mul | is_multu | is_j | is_jr | is_jal | is_jalr | is_mfc0 | is_mtc0 | is_mfhi | is_mflo | is_mthi | is_mtlo | is_clz | is_eret | is_syscall | is_break);
    assign alu_b_sel_out[1] = is_bgez;
    assign alu_b_sel_out[0] = is_addi | is_addiu | is_andi | is_ori | is_xori | is_slti | is_sltiu | is_lb | is_lbu | is_lh | is_lhu | is_lw | is_sb | is_sh | is_sw | is_lui;

    assign mul_ena_out   = is_mul | is_multu;
    assign div_ena_out   = is_div | is_divu;
    assign mul_sign_out  = is_mul;
    assign div_sign_out  = is_div;
    assign clz_ena_out   = is_clz;

    assign dmem_ena_out     = is_lw | is_sw | is_lh | is_sh | is_lb | is_sb | is_lhu | is_lbu;
    assign dmem_wena_out    = is_sw | is_sh | is_sb;
    assign dmem_wsel_out[1] = is_sh | is_sb;
    assign dmem_wsel_out[0] = is_sw | is_sb;
    assign dmem_rsel_out[1] = is_lh | is_lb | is_lhu | is_lbu;
    assign dmem_rsel_out[0] = is_lw | is_lb | is_lbu;     
    assign cutter_sign_out  = is_lh | is_lb;
    
    assign cutter_addr_sel_out  = ~(is_sb | is_sh | is_sw);
    assign cutter_sel_out[2]    = is_sh;
    assign cutter_sel_out[1]    = is_lb | is_lbu | is_sb;
    assign cutter_sel_out[0]    = is_lh | is_lhu | is_sb;

    assign rs_rena_out   = is_addi | is_addiu | is_andi | is_ori | is_sltiu | is_xori | is_slti | is_addu | is_and | is_beq | is_bne | is_jr | is_lw | is_xor | is_nor | is_or | is_sllv | is_sltu | is_subu | is_sw | is_add | is_sub | is_slt | is_srlv | is_srav | is_clz | is_divu | is_jalr | is_lb | is_lbu | is_lhu | is_sb | is_sh | is_lh | is_mul | is_multu | is_teq | is_div;
    assign rt_rena_out   = is_addu | is_and | is_beq | is_bne | is_xor | is_nor | is_or | is_sll | is_sllv | is_sltu | is_sra | is_srl | is_subu | is_sw | is_add | is_sub | is_slt | is_srlv | is_srav | is_divu | is_sb | is_sh | is_mtc0 | is_mul | is_multu | is_teq | is_div;
    assign rd_wena_out   = is_addi | is_addiu | is_andi | is_ori | is_sltiu | is_lui | is_xori | is_slti | is_addu | is_and | is_xor | is_nor | is_or | is_sll | is_sllv | is_sltu | is_sra | is_srl | is_subu | is_add | is_sub | is_slt | is_srlv | is_srav | is_lb | is_lbu | is_lh | is_lhu | is_lw | is_mfc0 | is_clz | is_jal | is_jalr | is_mfhi | is_mflo | is_mul;
    assign rdc_out = (is_add | is_addu | is_sub | is_subu | is_and | is_or | is_xor | is_nor | is_slt | is_sltu | is_sll | is_srl | is_sra | is_sllv | is_srlv | is_srav | is_clz | is_jalr | is_mfhi | is_mflo | is_mul) ? 
                   instr_val[15:11] : (( is_addi | is_addiu | is_andi | is_ori | is_xori | is_lb | is_lbu | is_lh | is_lhu | is_lw | is_slti | is_sltiu | is_lui | is_mfc0) ? 
                   instr_val[20:16] : (is_jal ? 5'd31 : 5'b0));
    assign rd_sel_out[2] = ~(is_beq | is_bne | is_bgez | is_div | is_divu | is_sb | is_multu | is_sh | is_sw | is_j | is_jr | is_jal | is_jalr | is_mfc0 | is_mtc0 | is_mflo | is_mthi | is_mtlo | is_clz | is_eret | is_syscall | is_teq | is_break);
    assign rd_sel_out[1] = is_mul | is_mfc0 | is_mtc0 | is_clz | is_mfhi;
    assign rd_sel_out[0] = ~(is_beq | is_bne | is_bgez | is_div | is_divu | is_multu | is_lb | is_lbu | is_lh | is_lhu | is_lw | is_sb | is_sh | is_sw | is_j | is_mtc0 | is_mfhi | is_mflo | is_mthi | is_mtlo | is_clz | is_eret | is_syscall | is_teq | is_break);
    
    assign hi_wena_out   = is_mul | is_multu | is_div | is_divu | is_mthi;
    assign hi_sel_out[1] = is_mthi;
    assign hi_sel_out[0] = is_mul | is_multu;
    assign lo_wena_out   = is_mul | is_multu | is_div | is_divu | is_mtlo; 
    assign lo_sel_out[1] = is_mtlo;
    assign lo_sel_out[0] = is_mul | is_multu;
	
    assign mfc0_out  = is_mfc0;
    assign mtc0_out  = is_mtc0;

    assign cause_out        = is_break ? `CAUSE_BREAK : (is_syscall ? `CAUSE_SYSCALL : (is_teq ? `CAUSE_TEQ : 5'bz));
    assign eret_out         = is_eret; 
    assign cp0_addr_out     = instr_val[15:11];
    assign exception_out    = status_val[0] && ((is_syscall && status_val[1]) || (is_break && status_val[2]) || (is_teq && status_val[3]));

endmodule
