`timescale 1ns / 1ps

module Clock_Manager #(
    parameter k = 20 
)(
    input  wire clk_i,
    output reg  clk_o = 1'b0
);

    integer counter_r = 0;

    always @(posedge clk_i) begin
        counter_r = (counter_r + 1) % (k / 2);
        if (counter_r == 0) begin
            clk_o <= ~clk_o;
        end
    end

endmodule
