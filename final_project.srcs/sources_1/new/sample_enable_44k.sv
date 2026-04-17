`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 09:24:12 PM
// Design Name: 
// Module Name: sample_enable_44k
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


module sample_enable_pwm (
    input  logic clk_100mhz,
    output logic sample_en_11m,  // 1 pulse at 44.1*2^(8) kHz
    output logic sample_en_44k
);
    // 100000000/11289600 = 9
    logic [3:0] counter = 0;
    logic clk_11M;

    always_ff @(posedge clk_100mhz) begin
        if (counter == 8) begin
            counter   <= 0;
            sample_en_11m <= 1'b1;
            clk_11M <=1'b1;
        end else begin
            counter   <= counter + 1;
            sample_en_11m <= 1'b0;
            clk_11M     <= 1'b0;
        end
    end
    
    logic [7:0] cnt_pwm=0;
    
     always_ff @(posedge clk_100mhz) begin
        if (clk_11M) begin
            if (cnt_pwm == 255) begin
                cnt_pwm   <= 0;
                sample_en_44k <= 1'b1;
            end else begin
                cnt_pwm   <= cnt_pwm + 1;
                sample_en_44k <= 1'b0;
            end
        end else begin
            sample_en_44k <= 1'b0;
        end
    end
endmodule

