`timescale 1ns / 1ps

module Display_Driver (
    input  wire        clk_i,  
    input  wire        reset_i,
    input  wire        cs_i,   
    input  wire [31:0] i_data_i,
    
    output wire [7:0]  o_seg_o,  
    output wire [7:0]  o_sel_o   
);

    reg [14:0] scan_clk_count_r;
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i)
            scan_clk_count_r <= 0;
        else
            scan_clk_count_r <= scan_clk_count_r + 1'b1;
    end
    
    wire seg7_clk_w = scan_clk_count_r; 

    reg [2:0] seg7_addr_r;
    always @(posedge seg7_clk_w or posedge reset_i) begin
        if (reset_i)
            seg7_addr_r <= 3'b0;
        else
            seg7_addr_r <= seg7_addr_r + 1'b1;
    end

    reg [7:0] o_sel_r;
    always @(*) begin
        case (seg7_addr_r)
            3'd7:   o_sel_r = 8'b01111111; 
            3'd6:   o_sel_r = 8'b10111111; 
            3'd5:   o_sel_r = 8'b11011111; 
            3'd4:   o_sel_r = 8'b11101111; 
            3'd3:   o_sel_r = 8'b11110111; 
            3'd2:   o_sel_r = 8'b11111011; 
            3'd1:   o_sel_r = 8'b11111101; 
            3'd0:   o_sel_r = 8'b11111110; 
            default: o_sel_r = 8'b11111111;
        endcase
    end
    assign o_sel_o = o_sel_r;

    reg [31:0] data_store_r;
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i)
            data_store_r <= 32'b0;
        else if (cs_i)
            data_store_r <= i_data_i;
    end

    reg [3:0] seg_data_r;
    always @(*) begin
        case (seg7_addr_r)
            3'd0:   seg_data_r = data_store_r[3:0];
            3'd1:   seg_data_r = data_store_r[7:4];
            3'd2:   seg_data_r = data_store_r[11:8];
            3'd3:   seg_data_r = data_store_r[15:12];
            3'd4:   seg_data_r = data_store_r[19:16];
            3'd5:   seg_data_r = data_store_r[23:20];
            3'd6:   seg_data_r = data_store_r[27:24];
            3'd7:   seg_data_r = data_store_r[31:28];
            default: seg_data_r = 4'b0;
        endcase
    end

    reg [7:0] o_seg_r;
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            o_seg_r <= 8'hFF; 
        end else begin
            case (seg_data_r)
                4'h0: o_seg_r <= 8'hC0; 
                4'h1: o_seg_r <= 8'hF9; 
                4'h2: o_seg_r <= 8'hA4; 
                4'h3: o_seg_r <= 8'hB0; 
                4'h4: o_seg_r <= 8'h99;
                4'h5: o_seg_r <= 8'h92; 
                4'h6: o_seg_r <= 8'h82; 
                4'h7: o_seg_r <= 8'hF8; 
                4'h8: o_seg_r <= 8'h80; 
                4'h9: o_seg_r <= 8'h90; 
                4'ha: o_seg_r <= 8'h88; 
                4'hb: o_seg_r <= 8'h83; 
                4'hc: o_seg_r <= 8'hC6; 
                4'hd: o_seg_r <= 8'hA1; 
                4'he: o_seg_r <= 8'h86; 
                4'hf: o_seg_r <= 8'h8E; 
                default: o_seg_r <= 8'hFF;
            endcase
        end
    end
    assign o_seg_o = o_seg_r;

endmodule
