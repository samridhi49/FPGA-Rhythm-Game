module tile_speed_controller #(
    parameter integer INITIAL_SPEED  = 2,
    parameter integer MAX_SPEED      = 12,
    parameter integer TICKS_PER_STEP = 300   // ~5 seconds @ 60 FPS
)(
    input  logic clk,
    input  logic reset,
    input  logic game_tick,       // one pulse per frame while playing

    output logic [7:0] tile_speed
);

    logic [15:0] tick_counter;
    logic [7:0]  speed_level;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_counter <= 0;
            speed_level  <= 0;
        end else if (game_tick) begin
            tick_counter <= tick_counter + 1;
            if (tick_counter >= TICKS_PER_STEP) begin
                tick_counter <= 0;
                if (speed_level < (MAX_SPEED - INITIAL_SPEED))
                    speed_level <= speed_level + 1;
            end
        end
    end

    always_comb begin
        tile_speed = INITIAL_SPEED + speed_level;
        if (tile_speed > MAX_SPEED)
            tile_speed = MAX_SPEED;
    end

endmodule
