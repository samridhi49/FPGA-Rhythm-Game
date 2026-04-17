module up_arrow_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:14399] /* synthesis ram_init_file = "./up_arrow/up_arrow.COE" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
