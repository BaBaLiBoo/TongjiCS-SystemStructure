`timescale 1ns / 1ps

module Data_Memory (
    input  wire        clk_i,  
    input  wire        ena_i,     
    input  wire        wena_i,  
    input  wire [10:0] addr_i,    
    input  wire [1:0]  type_i,    
    input  wire [31:0] data_in_i,
    output reg  [31:0] data_out_o
);

    reg [31:0] ram_r [0:2047];
    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1)
            ram_r[i] = 32'b0;
        data_out_o = 32'b0;
    end

    always @(posedge clk_i) begin
        if (ena_i) begin
            if (wena_i) begin
                case (type_i)
                    2'b00:  ram_r[addr_i]         <= data_in_i;         
                    2'b01:  ram_r[addr_i][15:0]   <= data_in_i[15:0];    
                    2'b10:  ram_r[addr_i][7:0]    <= data_in_i[7:0];  
                    default:;
                endcase
            end

            if (!wena_i) begin
                data_out_o <= ram_r[addr_i];
            end
        end
        else begin
            data_out_o <= data_out_o;
        end
    end

endmodule

