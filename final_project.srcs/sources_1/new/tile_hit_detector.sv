//==============================================================
//  tile_hit_detector.sv
//  Determines which tiles were hit correctly this frame
//  by matching lane_pressed with tile lane + y-position window
//==============================================================

module tile_hit_detector #(
    parameter integer N_TILES = 8,
    parameter integer HIT_Y0  = 420,   // hit window start
    parameter integer HIT_Y1  = 460    // hit window end
)(
    input  logic clk,
    input  logic reset,

    // From USB key decoder
    input  logic        one_key_valid,     // exactly 1 key pressed (A/S/D/F)
    input  logic [1:0]  lane_pressed,      // which lane is pressed (0..3)

    // From tile manager
    input  logic [N_TILES-1:0][1:0] tile_lane,     // lane of each tile
    input  logic [N_TILES-1:0][9:0] tile_y,        // y position
    input  logic [N_TILES-1:0]      tile_active,   // only active tiles can be hit

    // Output
    output logic [N_TILES-1:0]      tile_hit       // hit event per tile
);

    integer i;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tile_hit <= '0;

        end else begin
            // default: no hits this cycle
            tile_hit <= '0;

            // only allow hits when exactly 1 key is down
            if (one_key_valid) begin
                for (i = 0; i < N_TILES; i++) begin

                    if ( tile_active[i] &&                    // tile exists
                         (tile_lane[i] == lane_pressed) &&    // correct lane
                         (tile_y[i]   >= HIT_Y0) &&
                         (tile_y[i]   <= HIT_Y1)              // inside hit window
                       ) begin
                        tile_hit[i] <= 1'b1;                  // register hit
                    end
                end
            end
        end
    end

endmodule


