`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 06:35:43 PM
// Design Name: 
// Module Name: tile_fall
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


module tile_fall (
    input  logic clk,        // use vsync or 25 MHz
    input  logic reset,
    output logic [9:0] TileX,
    output logic [9:0] TileY
);

    localparam TILE_SIZE = 120;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            TileX <= 160;      // lane 2 (adjust if needed)
            TileY <= 0;        // start at the top
        end
        else begin
            TileY <= TileY + 2;   // falling speed

            // If off screen, restart at top
            if (TileY > 480)
                TileY <= 0;
        end
    end
endmodule
