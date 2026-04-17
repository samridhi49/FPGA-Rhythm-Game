`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 02:47:19 PM
// Design Name: 
// Module Name: clk_gen_audio
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


module clk_gen_audio(

   input  logic        clk_100M,     // 100 MHz input
    output logic        clk_44k1,     // 44.1 kHz output
    output logic        clk_11M2896   // 11.2896 MHz output
);

    // Generate 44.1 kHz from 100 MHz
    // 100,000,000 / 44,100 ? 2268 (need 2267.57, close enough)
    localparam DIV_44K = 2268;
    logic [11:0] counter_44k = 0;
    
    always_ff @(posedge clk_100M) begin
        if (counter_44k == DIV_44K - 1) begin
            counter_44k <= 0;
            clk_44k1 <= ~clk_44k1;  // Toggle for 50% duty
        end else begin
            counter_44k <= counter_44k + 1;
        end
    end
    
    // Generate 11.2896 MHz from 100 MHz
    // 100,000,000 / 11,289,600 ? 8.86 (use 9 with proper duty)
    localparam DIV_11M = 9;
    logic [3:0] counter_11M = 0;
    
    always_ff @(posedge clk_100M) begin
        if (counter_11M == DIV_11M - 1) begin
            counter_11M <= 0;
            clk_11M2896 <= ~clk_11M2896;
        end else begin
            counter_11M <= counter_11M + 1;
        end
    end

endmodule