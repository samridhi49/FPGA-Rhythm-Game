`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 07:17:03 PM
// Design Name: 
// Module Name: pwm_clk_gen
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


module pwm_clk_gen (
    input  logic clk_100mhz,
    output logic pwm_clk
);
    localparam DIV = 200;
    logic [$clog2(DIV)-1:0] counter = 0;

    always_ff @(posedge clk_100mhz) begin
        if (counter == DIV-1) begin
            counter <= 0;
            pwm_clk <= ~pwm_clk;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

