`timescale 1ns / 1ps

module Control_Unit (
    input  wire        branch_taken_i,
    input  wire [31:0] instruction_i,
    
    output wire        rs_rena_o,    // 读 rs
    output wire        rt_rena_o,    // 读 rt
    output wire        rd_wena_o,    // 写 rd
    output wire [4:0]  rd_addr_o,    // 目标寄存器地址
    output wire        rd_sel_o,     // 写回 MUX 选择
    output wire        dmem_ena_o,   // DMem 使能
    output wire        dmem_wena_o,  // DMem 写使能
    output wire [1:0]  dmem_type_o,  // DMem 类型
    output wire        ext_signed_o, // 立即数符号扩展
    output wire        alu_a_sel_o,  // ALU A MUX
    output wire        alu_b_sel_o,  // ALU B MUX
    output wire [3:0]  alu_sel_o,    // ALU 操作码
    output wire [1:0]  pc_sel_o      // PC MUX
);

    // 指令译码
    wire [5:0] op   = instruction_i[31:26];
    wire [5:0] func = instruction_i[5:0];
    wire [4:0] rt_addr = instruction_i[20:16];
    wire [4:0] rd_addr = instruction_i[15:11];

    wire R_Type = (op == 6'b000000);
    wire is_Add  = R_Type && (func == 6'b100000);
    wire is_Addu = R_Type && (func == 6'b100001);
    wire is_Sub  = R_Type && (func == 6'b100010);
    wire is_Subu = R_Type && (func == 6'b100011);
    wire is_And  = R_Type && (func == 6'b100100);
    wire is_Or   = R_Type && (func == 6'b100101);
    wire is_Xor  = R_Type && (func == 6'b100110);
    wire is_Nor  = R_Type && (func == 6'b100111);
    wire is_Slt  = R_Type && (func == 6'b101010);
    wire is_Sltu = R_Type && (func == 6'b101011);
    wire is_Sll  = R_Type && (func == 6'b000000) && (instruction_i[10:6] != 5'b0); 
    wire is_Srl  = R_Type && (func == 6'b000010);
    wire is_Sra  = R_Type && (func == 6'b000011);
    wire is_Sllv = R_Type && (func == 6'b000100);
    wire is_Srlv = R_Type && (func == 6'b000110);
    wire is_Srav = R_Type && (func == 6'b000111);
    wire is_Jr   = R_Type && (func == 6'b001000);
    wire is_Addi  = (op == 6'b001000);
    wire is_Addiu = (op == 6'b001001);
    wire is_Andi  = (op == 6'b001100);
    wire is_Ori   = (op == 6'b001101);
    wire is_Xori  = (op == 6'b001110);
    wire is_Lw    = (op == 6'b100011);
    wire is_Sw    = (op == 6'b101011);
    wire is_Beq   = (op == 6'b000100);
    wire is_Bne   = (op == 6'b000101);
    wire is_Slti  = (op == 6'b001010);
    wire is_Sltiu = (op == 6'b001011);
    wire is_Lui   = (op == 6'b001111);
    wire I_Type   = is_Addi | is_Addiu | is_Andi | is_Ori | is_Xori | is_Lw | is_Sw |
                    is_Beq | is_Bne | is_Slti | is_Sltiu | is_Lui;
    wire is_J   = (op == 6'b000010);
    wire is_Jal = (op == 6'b000011);
    
    // 读使能
    assign rs_rena_o = is_Add | is_Addu | is_Sub | is_Subu | is_And | is_Or | 
                       is_Xor | is_Nor | is_Slt | is_Sltu | is_Sllv | is_Srlv | 
                       is_Srav | is_Jr | is_Addi | is_Addiu | is_Andi | is_Ori | 
                       is_Xori | is_Lw | is_Sw | is_Beq | is_Bne | is_Slti | is_Sltiu;
                       
    assign rt_rena_o = is_Add | is_Addu | is_Sub | is_Subu | is_And | is_Or | 
                       is_Xor | is_Nor | is_Slt | is_Sltu | is_Sll | is_Srl | 
                       is_Sra | is_Sllv | is_Srlv | is_Srav | is_Beq | is_Bne | is_Sw;

    // 写回使能
    assign rd_wena_o = is_Add | is_Addu | is_Sub | is_Subu | is_And | is_Or | 
                       is_Xor | is_Nor | is_Slt | is_Sltu | is_Sll | is_Srl | 
                       is_Sra | is_Sllv | is_Srlv | is_Srav | is_Addi | is_Addiu | 
                       is_Andi | is_Ori | is_Xori | is_Lw | is_Slti | is_Sltiu | is_Lui | is_Jal;

    // 写回 MUX
    assign rd_sel_o = ~is_Lw; 

    assign dmem_ena_o = is_Sw | is_Lw;
    assign dmem_wena_o = is_Sw;
    assign dmem_type_o = 2'b00; 

    assign ext_signed_o = is_Addi | is_Lw | is_Sw | is_Slti;

    assign alu_a_sel_o = is_Sll | is_Srl | is_Sra | is_Jal; 

    assign alu_b_sel_o = is_Addi | is_Addiu | is_Andi | is_Ori | is_Xori | 
                         is_Lw | is_Sw | is_Slti | is_Sltiu | is_Lui | is_Jal;

    reg [1:0] pc_sel_reg;
    always @(*) begin
        if (is_Jr)              pc_sel_reg = 2'b01;
        else if (is_J || is_Jal) pc_sel_reg = 2'b10;
        else if ((is_Beq | is_Bne) && branch_taken_i) pc_sel_reg = 2'b11;
        else                   pc_sel_reg = 2'b00;
    end
    assign pc_sel_o = pc_sel_reg;

    reg [3:0] alu_sel_reg;
    always @(*) begin
        alu_sel_reg = 4'hF;

        if (is_Add  || is_Addi || is_Addu || is_Addiu) alu_sel_reg = 4'h0; // ADD
        else if (is_Sub || is_Subu)                   alu_sel_reg = 4'h1; // SUB
        else if (is_And || is_Andi)                   alu_sel_reg = 4'h2; // AND
        else if (is_Or  || is_Ori)                    alu_sel_reg = 4'h3; // OR
        else if (is_Xor || is_Xori)                   alu_sel_reg = 4'h4; // XOR
        else if (is_Nor)                              alu_sel_reg = 4'h5; // NOR
        else if (is_Slt || is_Slti)                   alu_sel_reg = 4'h6; // SLT
        else if (is_Sltu || is_Sltiu)                 alu_sel_reg = 4'h7; // SLTU
        else if (is_Sll || is_Sllv)                   alu_sel_reg = 4'h8; // SLL
        else if (is_Srl || is_Srlv)                   alu_sel_reg = 4'h9; // SRL
        else if (is_Sra || is_Srav)                   alu_sel_reg = 4'hA; // SRA
        else if (is_Lui)                              alu_sel_reg = 4'hB; // LUI
        else                                          alu_sel_reg = 4'hF; // NOP/unknown
    end
    assign alu_sel_o = alu_sel_reg;

    Mux_4x5 rd_addr_mux_inst (
       .d0_i(5'b0),
       .d1_i(rt_addr),
       .d2_i(rd_addr),
       .d3_i( (is_Jal)? 5'd31 : 5'b0 ), 
       .sel_i({R_Type | is_Jal, I_Type}),
       .y_o(rd_addr_o)
    );

endmodule
