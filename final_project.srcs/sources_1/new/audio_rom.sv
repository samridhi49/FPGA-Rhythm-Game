`timescale 1ns / 1ps



//audio_rom.sv

module audio_rom (
	input logic clk,
	input logic [16:0] address,
	output logic [15:0] q
);

logic [15:0] memory [0:83399] /* synthesis ram_init_file = "./up_arrow/up_arrow.COE" */;

always_ff @ (posedge clk) begin
	q <= memory[address];
end

endmodule

