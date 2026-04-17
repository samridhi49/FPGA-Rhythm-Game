module hud_renderer #(
    parameter SCORE_SCALE  = 1,
    parameter HEART_SCALE  = 2   // ? hearts slightly bigger
)(
    input  logic        clk,
    input  logic        reset,

    input  logic        game_active,
    input  logic        tile_hit,
    input  logic        tile_missed,

    input  logic [9:0]  pixel_x,
    input  logic [9:0]  pixel_y,
    input  logic        active,
    
    input logic restart_game,

    // outputs used by FSM / game-over screen
    output logic [15:0] score_out,
    output logic [1:0]  misses_out,

    output logic        hud_on,
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);

    // ============================================================
    // SCORE + MISSES REGISTERS
    // ============================================================
    logic [15:0] score;
    logic [1:0]  misses;

    always_ff @(posedge clk or posedge reset) begin
        if (reset || restart_game) begin
            score  <= 16'd0;
            misses <= 2'd0;
        end
        else if (game_active) begin
            if (tile_hit)
                score <= score + 16'd1;

            if (tile_missed && misses < 2'd3)
                misses <= misses + 2'd1;
        end
    end

    assign score_out  = score;
    assign misses_out = misses;

    // ============================================================
    // SCORE ? ASCII DIGITS
    // ============================================================
    logic [7:0] d0, d1, d2, d3;
    logic [15:0] s;

    always_comb begin
        s  = score;
        d0 = "0" + (s % 10); s = s / 10;
        d1 = "0" + (s % 10); s = s / 10;
        d2 = "0" + (s % 10); s = s / 10;
        d3 = "0" + (s % 10);
    end

    logic [3:0][7:0] score_digits;
    always_comb begin
        score_digits[0] = d3;
        score_digits[1] = d2;
        score_digits[2] = d1;
        score_digits[3] = d0;
    end

    // ============================================================
    // SCORE LABEL
    // ============================================================
    logic [5:0][7:0] score_label;
    always_comb begin
        score_label[0] = "S";
        score_label[1] = "c";
        score_label[2] = "o";
        score_label[3] = "r";
        score_label[4] = "e";
        score_label[5] = ":";
    end

    // ============================================================
    // HEARTS (LIVES)
    // ============================================================
    logic [2:0][7:0] heart_msg;
    always_comb begin
        heart_msg[0] = (misses > 0) ? "X" : "H";
        heart_msg[1] = (misses > 1) ? "X" : "H";
        heart_msg[2] = (misses > 2) ? "X" : "H";
    end

    // ============================================================
    // TEXT RENDERERS
    // ============================================================
    logic hearts_on, score_lbl_on, score_dig_on;
    logic [7:0] hr, hg, hb;
    logic [7:0] sl_r, sl_g, sl_b;
    logic [7:0] sd_r, sd_g, sd_b;

    // ---------- HEARTS (TOP RIGHT, BIGGER) ----------
    text_renderer #(
        .MAX_LEN(3),
        .SCALE  (HEART_SCALE),
        .TXT_R  (8'hFF),
        .TXT_G  (8'h40),
        .TXT_B  (8'h40)
    ) hearts_draw (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active (active),
        .text_x (640 - (3 * 8 * HEART_SCALE) - 10),
        .text_y (10),
        .message(heart_msg),
        .text_on(hearts_on),
        .R(hr), .G(hg), .B(hb)
    );

    // ---------- "Score:" ----------
    text_renderer #(
        .MAX_LEN(6),
        .SCALE  (SCORE_SCALE),
        .TXT_R  (8'hFF),
        .TXT_G  (8'hFF),
        .TXT_B  (8'hFF)
    ) score_label_draw (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active (active),
        .text_x (20),
        .text_y (20),
        .message(score_label),
        .text_on(score_lbl_on),
        .R(sl_r), .G(sl_g), .B(sl_b)
    );

    // ---------- SCORE DIGITS ----------
    text_renderer #(
        .MAX_LEN(4),
        .SCALE  (SCORE_SCALE),
        .TXT_R  (8'hFF),
        .TXT_G  (8'hFF),
        .TXT_B  (8'h40)
    ) score_digits_draw (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active (active),
        .text_x (20 + 6 * 8 * SCORE_SCALE),
        .text_y (20),
        .message(score_digits),
        .text_on(score_dig_on),
        .R(sd_r), .G(sd_g), .B(sd_b)
    );

    // ============================================================
    // HUD OUTPUT MUX
    // ============================================================
    always_comb begin
        hud_on = 1'b0;
        R = 8'd0;
        G = 8'd0;
        B = 8'd0;

        if (active && game_active) begin
            if (hearts_on) begin
                hud_on = 1'b1;
                R = hr; G = hg; B = hb;
            end
            else if (score_lbl_on) begin
                hud_on = 1'b1;
                R = sl_r; G = sl_g; B = sl_b;
            end
            else if (score_dig_on) begin
                hud_on = 1'b1;
                R = sd_r; G = sd_g; B = sd_b;
            end
        end
    end

endmodule