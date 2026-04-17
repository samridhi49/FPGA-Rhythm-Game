`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 07:08:07 PM
// Design Name: 
// Module Name: clk_16k_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_16k_gen (
    input  logic clk_100mhz,
    output logic clk_16k
);
    localparam DIV = 3125;
    logic [$clog2(DIV)-1:0] counter = 0;

    always_ff @(posedge clk_100mhz) begin
        if (counter == DIV-1) begin
            counter <= 0;
            clk_16k <= ~clk_16k;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

