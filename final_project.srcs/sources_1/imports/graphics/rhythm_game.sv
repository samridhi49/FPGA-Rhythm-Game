module rhythm_game #(
    parameter H_RES    = 640,
    parameter V_RES    = 480,
    parameter LANE_W   = 80,
    parameter X_OFFSET = 80,
    parameter N_TILES  = 8
)(
    input  logic        clk_pix,
    input  logic        reset,
    input  logic        vsync,
    input  logic [31:0] keycode,

    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    input  logic        active,

    output logic [7:0]  R8,
    output logic [7:0]  G8,
    output logic [7:0]  B8
);
    // ============================
    // FRAME TICK
    // ============================
    logic vsync_d;
    always_ff @(posedge clk_pix or posedge reset) begin
        if (reset) vsync_d <= 0;
        else       vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;

    // ============================
    // KEY DECODING
    // ============================
    logic one_key_valid;
    logic [1:0] lane_pressed;
    logic key_SPACE_pulse;

    usb_key_decoder_rhythm keydec(
        .clk(clk_pix),
        .reset(reset),
        .keycode(keycode),
        .one_key_valid(one_key_valid),
        .lane(lane_pressed),
        .key_SPACE_pulse(key_SPACE_pulse)
    );

    // ============================
    // HUD EXPORTS
    // ============================
    logic [1:0]  hud_misses;
    logic [15:0] hud_score;

     logic [15:0] final_score;
    always_ff @(posedge clk_pix or posedge reset) begin
    if (reset) begin
        final_score <= 16'd0;
    end
    else if (state == GAME_PLAY && misses_out == 2'd3) begin
        final_score <= score_out;   // ? LATCH SCORE ON GAME OVER
    end
end
    // ============================
    // GAME FSM
    // ============================
    game_state_t state;
    logic restart_game;
    logic [1:0] misses_out;
    logic [15:0] score_out;

   game_fsm fsm(
    .clk          (clk_pix),
    .reset        (reset),
    .space_pressed(key_SPACE_pulse),
    .miss_count   (misses_out),
    .state        (state),
    .restart_game (restart_game)
);

    wire game_tick = frame_tick & (state == GAME_PLAY);

    // ============================
    // TILE SPEED
    // ============================
    logic [7:0] tile_speed;

    tile_speed_controller spd(
        .clk(clk_pix),
        .reset(reset || restart_game),
        .game_tick(game_tick),
        .tile_speed(tile_speed)
    );

    // ============================
    // TILE LOGIC
    // ============================
    logic [N_TILES-1:0][1:0] tile_lane;
    logic [N_TILES-1:0][9:0] tile_y;
    logic [N_TILES-1:0] tile_active;
    logic [N_TILES-1:0] tile_hit;

    tile_hit_detector hitdet(
        .clk(clk_pix),
        .reset(reset),
        .one_key_valid(one_key_valid),
        .lane_pressed(lane_pressed),
        .tile_lane(tile_lane),
        .tile_y(tile_y),
        .tile_active(tile_active),
        .tile_hit(tile_hit)
    );

    tile_manager tm(
        .clk(clk_pix),
        .reset(reset),
        .game_tick(game_tick),
        .tile_speed(tile_speed),
        .tile_hit(tile_hit),
        .tile_lane(tile_lane),
        .tile_y(tile_y),
        .tile_active(tile_active)
    );

    // ============================
    // HIT & MISS PULSES
    // ============================
    logic tile_hit_pulse;
    logic tile_missed_pulse;

    logic [N_TILES-1:0] hit_latched;
    logic [N_TILES-1:0] miss_latched;

    always_ff @(posedge clk_pix or posedge reset) begin
        if (reset) begin
            hit_latched <= '0;
            tile_hit_pulse <= 0;
        end else begin
            tile_hit_pulse <= 0;

            for (int i=0;i<N_TILES;i++) begin
                if (tile_hit[i] && !hit_latched[i]) begin
                    tile_hit_pulse <= 1;
                    hit_latched[i] <= 1;
                end
                if (!tile_active[i])
                    hit_latched[i] <= 0;
            end
        end
    end

    always_ff @(posedge clk_pix or posedge reset) begin
        if (reset) begin
            miss_latched <= '0;
            tile_missed_pulse <= 0;
        end else begin
            tile_missed_pulse <= 0;

            for (int i=0;i<N_TILES;i++) begin
                if (tile_active[i] &&
                    tile_y[i] >= V_RES-4 &&
                    !miss_latched[i]) begin

                    tile_missed_pulse <= 1;
                    miss_latched[i] <= 1;
                end
                if (!tile_active[i])
                    miss_latched[i] <= 0;
            end
        end
    end

    // ============================
    // BACKGROUND
    // ============================
    logic [7:0] bgR,bgG,bgB;
    lane_background #(
        .H_RES(H_RES), .V_RES(V_RES),
        .LANE_W(LANE_W), .X_OFFSET(X_OFFSET)
    ) bg(
        .pixel_x(drawX), .pixel_y(drawY),
        .active(active),
        .R(bgR), .G(bgG), .B(bgB)
    );

    // ============================
    // RENDER TILES
    // ============================
    logic tile_on;
    logic [7:0] tileR,tileG,tileB;

    tile_renderer #(
        .H_RES(H_RES), .V_RES(V_RES),
        .LANE_W(LANE_W), .X_OFFSET(X_OFFSET),
        .TILE_W(48), .TILE_H(32), .N_TILES(N_TILES)
    ) tr(
        .pixel_x(drawX), .pixel_y(drawY),
        .active(active),
        .tile_lane(tile_lane),
        .tile_y(tile_y),
        .tile_active(tile_active),
        .tile_on(tile_on),
        .R(tileR), .G(tileG), .B(tileB)
    );

    // ============================
    // HUD
    // ============================
    logic hud_on;
    logic [7:0] hudR,hudG,hudB;

   hud_renderer hud(
    .clk        (clk_pix),
    .reset      (reset),
    .game_active(state == GAME_PLAY),
    .tile_hit   (tile_hit_pulse),
    .tile_missed(tile_missed_pulse),
    

    .pixel_x    (drawX),
    .pixel_y    (drawY),
    .active     (active),
    .restart_game (restart_game),

    .misses_out (misses_out),
    .score_out  (score_out),

    .hud_on     (hud_on),
    .R          (hudR),
    .G          (hudG),
    .B          (hudB)
);
    // ============================
    // START SCREEN
    // ============================
    logic ss_on;
    logic [7:0] ssR,ssG,ssB;

    start_screen_renderer ss(
        .pixel_x(drawX), .pixel_y(drawY),
        .active(active),
        .draw_on(ss_on),
        .R(ssR), .G(ssG), .B(ssB)
    );

    // ============================
    // GAME OVER SCREEN
    // ============================
    logic go_on;
    logic [7:0] goR,goG,goB;

    game_over_renderer go(
        .pixel_x(drawX), .pixel_y(drawY),
        .active(active),
        .final_score(final_score),
        .gameover_on(go_on),
        .R(goR), .G(goG), .B(goB)
    );

    // ============================
    // FINAL MUX
    // ============================
    always_comb begin
        if (!active) begin
            R8=0; G8=0; B8=0;
        end
        else begin
            R8=bgR; G8=bgG; B8=bgB;

            if (state == START_SCREEN && ss_on)
                {R8,G8,B8} = {ssR,ssG,ssB};

            else if (state == GAME_PLAY) begin
                if (tile_on) {R8,G8,B8} = {tileR,tileG,tileB};
                if (hud_on)  {R8,G8,B8} = {hudR,hudG,hudB};
            end

            else if (state == GAME_OVER && go_on)
                {R8,G8,B8} = {goR,goG,goB};
        end
    end
    
endmodule





