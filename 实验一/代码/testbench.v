`timescale 1ns/1ps
module testbench;

  reg         clk;
  reg         rst;        
  reg  [15:0] init_data;
  reg         is_init_floors;
  reg         is_init_resistance;
  wire        last_broken;

  wire [7:0]  seg_data;
  wire [7:0]  seg_anode;
  integer regfile_output;

  Top_Level_Design uut (
    .clk_i                (clk),
    .rst_i                (rst),             
    .in_data_i            (init_data),
    .is_init_floors_i     (is_init_floors),
    .is_init_resistance_i (is_init_resistance),
    .o_seg_o              (seg_data),
    .o_sel_o              (seg_anode),
    .last_broken_o        (last_broken)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  wire [31:0] if_pc    = uut.cpu_core_inst.stage_if_inst.pc_o;
  wire [31:0] if_instr = uut.cpu_core_inst.stage_if_inst.instruction_o;

  wire [31:0] mem_dout = uut.cpu_core_inst.stage_mem_inst.dmem_data_o;

  wire [31:0] rf_r4 = uut.cpu_core_inst.stage_id_inst.reg_file_inst.reg_array_r[4];
  wire [31:0] rf_r5 = uut.cpu_core_inst.stage_id_inst.reg_file_inst.reg_array_r[5];
  wire [31:0] rf_r6 = uut.cpu_core_inst.stage_id_inst.reg_file_inst.reg_array_r[6];

  initial begin
    regfile_output = $fopen("regfile_output.txt", "w");

    clk                = 1'b0;
    rst                = 1'b1; 
    init_data          = 16'd0;
    is_init_floors     = 1'b0;
    is_init_resistance = 1'b0;

    // Â¥²ã = 30
    #20 init_data          = 16'd30;
    #20 is_init_floors     = 1'b1;
    #20 is_init_floors     = 1'b0;
    // ÄÍË¤ = 19
    #20 init_data          = 16'd19;
    #20 is_init_resistance = 1'b1;
    #20 is_init_resistance = 1'b0;
    // ÊÍ·Å¸´Î»
    #20 rst = 1'b0;
    repeat (200000) @(posedge clk);

    $display("[TB-END] pc=%h instr=%h mem_dout=%h  r4=%0d r5=%0d r6=%0d last=%0d",
              if_pc, if_instr, mem_dout, rf_r4, rf_r5, rf_r6, last_broken);
    $fdisplay(regfile_output,
              "[TB-END] pc=%h instr=%h mem_dout=%h  r4=%0d r5=%0d r6=%0d last=%0d",
              if_pc, if_instr, mem_dout, rf_r4, rf_r5, rf_r6, last_broken);

    $fclose(regfile_output);
    $stop;
  end

  reg [9:0] us_div;
  always @(posedge clk) begin
    if (rst) begin
      us_div <= 10'd0;
    end else begin
      if (us_div == 10'd999) begin
        us_div <= 10'd0;
        $fdisplay(regfile_output,
          "t=%0t ns  pc=%h instr=%h  r4=%0d r5=%0d r6=%0d  last=%0d",
          $time, if_pc, if_instr, rf_r4, rf_r5, rf_r6, last_broken);
      end else begin
        us_div <= us_div + 10'd1;
      end
    end
  end
endmodule