`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 05:05:45 PM
// Design Name: 
// Module Name: pwm_audio
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


// pwm_audio.sv

module pwm_audio (
    input  logic        clk_100mhz, // 100 MHz
    input  logic        pwm_ce,
    input  logic [7:0]  sample,
    output logic        pwm_out
);

    logic [7:0] counter = 0;

    always_ff @(posedge clk_100mhz) begin
        if (pwm_ce) begin
            counter <= counter + 1;
        end
        pwm_out <= (counter < sample);
    end
endmodule

//module pwm_audio (
//    input  logic        clk,       // 100 MHz
//    input  logic [15:0] sample,
//    output logic        pwm_out
//);


//    logic [15:0] counter;

//    always_ff @(posedge clk) begin
//        counter <= counter + 1;
//        pwm_out <= (counter < sample);
//    end

//endmodule