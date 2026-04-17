module game_over_renderer(
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic       active,

    input  logic [15:0] final_score,

    output logic       gameover_on,
    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
);

    // ==========================================================
    // "GAME OVER" TEXT
    // ==========================================================
    localparam int GO_LEN = 9;
    logic [GO_LEN-1:0][7:0] msg_go =
        '{ "R","E","V","O"," ","E","M","A","G" };

    // ==========================================================
    // SCORE ? 4 ASCII DIGITS
    // ==========================================================
    logic [7:0] d0, d1, d2, d3;
    logic [15:0] s;

    always_comb begin
        s = final_score;

        d0 = "0" + (s % 10);  s /= 10;
        d1 = "0" + (s % 10);  s /= 10;
        d2 = "0" + (s % 10);  s /= 10;
        d3 = "0" + (s % 10);
    end

    logic [3:0][7:0] score_digits;
    always_comb begin
        score_digits[0] = d3;
        score_digits[1] = d2;
        score_digits[2] = d1;
        score_digits[3] = d0;
    end

    // ==========================================================
    // COMPUTE PERFECT CENTERING
    // ==========================================================
    localparam int SCALE = 2;
    localparam int CHAR_W = 8 * SCALE;   // 16 px
    localparam int CHAR_H = 8 * SCALE;   // 16 px

    // Horizontal widths
    localparam int GO_W = GO_LEN * CHAR_W;  // 9*16 = 144px
    localparam int SC_W = 4 * CHAR_W;       // 4*16 = 64px

    // Screen center
    localparam int CX = (640 - GO_W) / 2;   // horizontally centered
    localparam int CY = 240;                // vertical midline

    // Layout:
    // GAME OVER at CY - 20
    // Score at CY + 10
    localparam int GO_Y = CY - 20;
    localparam int SC_Y = CY + 10;

    // Center score as well
    localparam int SC_X = (640 - SC_W) / 2;

    // ==========================================================
    // TEXT RENDERERS
    // ==========================================================

    logic go_on, sc_on;
    logic [7:0] goR, goG, goB;
    logic [7:0] scR, scG, scB;

    // GAME OVER text
    text_renderer #(
        .MAX_LEN(GO_LEN), .SCALE(SCALE),
        .TXT_R(8'hFF), .TXT_G(8'h20), .TXT_B(8'h20)
    ) draw_go (
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .active(active),
        .text_x(CX), .text_y(GO_Y),
        .message(msg_go),
        .text_on(go_on),
        .R(goR), .G(goG), .B(goB)
    );

    // Score digits (centered)
    text_renderer #(
        .MAX_LEN(4), .SCALE(SCALE),
        .TXT_R(8'hFF), .TXT_G(8'hFF), .TXT_B(8'h40)
    ) draw_sc (
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .active(active),
        .text_x(SC_X), .text_y(SC_Y),
        .message(score_digits),
        .text_on(sc_on),
        .R(scR), .G(scG), .B(scB)
    );

    // ==========================================================
    // OUTPUT MUX
    // ==========================================================
    always_comb begin
        gameover_on = go_on || sc_on;

        if (go_on)
            {R, G, B} = {goR, goG, goB};
        else if (sc_on)
            {R, G, B} = {scR, scG, scB};
        else
            {R, G, B} = {8'd0, 8'd0, 8'd0};
    end

endmodule





