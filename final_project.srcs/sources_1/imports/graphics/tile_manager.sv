module tile_manager #(
    parameter integer N_TILES = 8,
    parameter integer V_RES   = 480,
    parameter integer TILE_H  = 32
)(
    input  logic clk,
    input  logic reset,
    input  logic game_tick,
    input  logic [7:0] tile_speed,
    input  logic [N_TILES-1:0] tile_hit,

    output logic [N_TILES-1:0][1:0] tile_lane,   // 0..3
    output logic [N_TILES-1:0][9:0] tile_y,
    output logic [N_TILES-1:0]      tile_active
);

    // simple LFSR for randomness
    logic [7:0] lfsr;
    wire fb = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            lfsr <= 8'hA5;
        else if (game_tick)
            lfsr <= {lfsr[6:0], fb};
    end

    integer i;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < N_TILES; i++) begin
                tile_active[i] <= 1'b0;
                tile_lane[i]   <= i[1:0];
                tile_y[i]      <= 10'd0;
            end
        end else if (game_tick) begin
            for (i = 0; i < N_TILES; i++) begin
                if (tile_hit[i]) begin
                    tile_active[i] <= 1'b0;
                end else if (!tile_active[i]) begin
                    // spawn new tile
                    tile_active[i] <= 1'b1;
                    tile_lane[i]   <= lfsr[1:0];   // 0..3
                    tile_y[i]      <= 10'd0;       // top
                end else begin
                    // fall down
                    tile_y[i] <= tile_y[i] + tile_speed;

                    if (tile_y[i] >= V_RES)
                        tile_active[i] <= 1'b0;
                end
            end
        end
    end

endmodule
