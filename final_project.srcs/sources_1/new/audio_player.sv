`timescale 1ns / 1ps

module audio_player (
    input  logic        clk_100mhz,
    input  logic        reset_n,
    input  logic        play,
    input  logic        sample_en,

    output logic [16:0] rom_addr,
    input  logic [7:0]  rom_sample,

    output logic [7:0]  audio_sample,
    output logic        sample_valid
);

    localparam int END_INDEX = 229871;

    logic [16:0] index;

    logic [7:0] rom_sample_d;

    always_ff @(posedge sample_en or negedge reset_n) begin
        if (!reset_n) begin
            index         <= 0;
            rom_addr      <= 0;
            rom_sample_d  <= 0;
            audio_sample  <= 0;
            sample_valid  <= 0;
        end
        else begin
            rom_sample_d <= rom_sample;
            sample_valid <= 0;

            if (play) begin
                // output the sample from 1 cycle earlier
                audio_sample <= rom_sample_d + 8'd128;
                sample_valid <= 1;

                // update read address for next sample
                if (index == END_INDEX) begin
                    index    <= 0;
                    rom_addr <= 0;
                end else begin
                    index    <= index + 1;
                    rom_addr <= index + 1;
                end
            end
            else begin
                // freeze playback when not playing
                audio_sample <= 0;
            end
        end
    end
endmodule
