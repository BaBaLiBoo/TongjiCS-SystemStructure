`timescale 1ns / 1ps

module testbench();
    reg           clk, rst, ena;
    reg  [1:0]    switch;
    wire [7:0]    o_seg, o_sel;

    initial 
    begin
        clk = 1'b0;
        rst = 1'b1;
        ena = 1'b1;
        switch = 2'b00;
        #1 
        rst = 1'b0;
    end

    always 
    begin
        #1 
        clk = ~clk;
    end

    wire [31:0] pc      = testbench.top_module_inst.proc_inst.pc;
    wire [31:0] instr   = testbench.top_module_inst.proc_inst.instr;
    wire [31:0] reg0    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[0];
    wire [31:0] reg1    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[1];
    wire [31:0] reg2    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[2];   
    wire [31:0] reg3    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[3];
    wire [31:0] reg4    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[4];
    wire [31:0] reg5    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[5];
    wire [31:0] reg6    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[6];
    wire [31:0] reg7    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[7];
    wire [31:0] reg8    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[8];
    wire [31:0] reg9    = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[9];
    wire [31:0] reg10   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[10];
    wire [31:0] reg11   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[11];
    wire [31:0] reg12   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[12];
    wire [31:0] reg13   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[13];
    wire [31:0] reg14   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[14];
    wire [31:0] reg15   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[15];
    wire [31:0] reg16   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[16];
    wire [31:0] reg17   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[17];
    wire [31:0] reg18   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[18];
    wire [31:0] reg19   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[19];
    wire [31:0] reg20   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[20];
    wire [31:0] reg21   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[21];
    wire [31:0] reg22   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[22];
    wire [31:0] reg23   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[23];
    wire [31:0] reg24   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[24];
    wire [31:0] reg25   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[25];
    wire [31:0] reg26   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[26];
    wire [31:0] reg27   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[27];
    wire [31:0] reg28   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[28];
    wire [31:0] reg29   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[29];
    wire [31:0] reg30   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[30];
    wire [31:0] reg31   = testbench.top_module_inst.proc_inst.pipe_id_inst.regfile_inst.reg_array[31];

    top_module top_module_inst(.clk(clk), .rst(rst), .ena(ena), .switch(switch), .o_seg(o_seg), .o_sel(o_sel));

endmodule