module start_screen_renderer(
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic       active,

    output logic       draw_on,
    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
);

    // ======================================================
    // FRAME TICK FOR BLINKING (uses VGA frame start)
    // ======================================================
    logic frame_tick;
    assign frame_tick = (pixel_x == 0 && pixel_y == 0);  // ~60 Hz tick

    logic [7:0] blink_cnt = 0;  
    logic blink_on;

    always_ff @(posedge frame_tick)
        blink_cnt <= blink_cnt + 1;

    assign blink_on = blink_cnt[6];   // slower blink (~0.5 Hz)


    // ======================================================
    // TITLE: "KeySync"
    // ======================================================
    localparam int TITLE_LEN = 7;
    localparam int SCALE = 3;      // makes text 24px tall (8×3)

    // Characters LEFT ? RIGHT
    localparam logic [TITLE_LEN-1:0][7:0] title_msg = '{
        "c","n","y","S","y","e","K"
    };

    // Title rectangle: narrower for better look
    localparam int TITLE_BAR_X1 = 140;
    localparam int TITLE_BAR_X2 = 500;
    localparam int TITLE_BAR_Y1 = 100;
    localparam int TITLE_BAR_Y2 = 160;

    localparam int TITLE_BAR_WIDTH = TITLE_BAR_X2 - TITLE_BAR_X1;
    localparam int TITLE_BAR_HEIGHT = TITLE_BAR_Y2 - TITLE_BAR_Y1;

    // Scaled text width
    localparam int TITLE_W = TITLE_LEN * 8 * SCALE;
    localparam int TITLE_H = 8 * SCALE;

    // Center text inside bar
    localparam int TITLE_X = TITLE_BAR_X1 + (TITLE_BAR_WIDTH - TITLE_W)/2;
    localparam int TITLE_Y = TITLE_BAR_Y1 + (TITLE_BAR_HEIGHT - TITLE_H)/2;


    // ======================================================
    // PROMPT: "Press Spacebar to Start"
    // ======================================================
    localparam int PROMPT_LEN = 23;

    // Stored backwards ON PURPOSE (your requirement)
    localparam logic [PROMPT_LEN-1:0][7:0] prompt_msg = '{
        "t","r","a","t","S"," ",
        "o","t"," ",
        "r","a","b","e","c","a","p","S"," ",
        "s","s","e","r","P"
    };

    // Prompt bar stays wide
    localparam int PROMPT_BAR_X1 = 120;
    localparam int PROMPT_BAR_X2 = 520;
    localparam int PROMPT_BAR_Y1 = 260;
    localparam int PROMPT_BAR_Y2 = 300;

    localparam int PROMPT_BAR_WIDTH = PROMPT_BAR_X2 - PROMPT_BAR_X1;

    // Prompt is NOT scaled (normal 8px tall)
    localparam int PROMPT_W = PROMPT_LEN * 8;

    // Center prompt text horizontally
    localparam int PROMPT_X = PROMPT_BAR_X1 + (PROMPT_BAR_WIDTH - PROMPT_W)/2 + 8;
    localparam int PROMPT_Y = 275;


    // ======================================================
    // TEXT RENDERERS
    // ======================================================
    logic title_on;
    logic [7:0] tR1, tG1, tB1;

    text_renderer #(
        .MAX_LEN(TITLE_LEN),
        .SCALE(SCALE),
        .TXT_R(8'h00), .TXT_G(8'h00), .TXT_B(8'h00)
    ) title_text (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active(active),
        .text_x(TITLE_X),
        .text_y(TITLE_Y),
        .message(title_msg),
        .text_on(title_on),
        .R(tR1), .G(tG1), .B(tB1)
    );

    logic prompt_on;
    logic [7:0] tR2, tG2, tB2;

    text_renderer #(
        .MAX_LEN(PROMPT_LEN),
        .SCALE(1),
        .TXT_R(8'h00), .TXT_G(8'h00), .TXT_B(8'h00)
    ) prompt_text (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active(active),
        .text_x(PROMPT_X),
        .text_y(PROMPT_Y),
        .message(prompt_msg),
        .text_on(prompt_on),
        .R(tR2), .G(tG2), .B(tB2)
    );


    // ======================================================
    // FINAL DRAW LOGIC
    // ======================================================
    always_comb begin
        draw_on = 0;
        R = 0; G = 0; B = 0;

        if (active) begin

            // Title bar (orange)
            if (pixel_y >= TITLE_BAR_Y1 && pixel_y < TITLE_BAR_Y2 &&
                pixel_x >= TITLE_BAR_X1 && pixel_x < TITLE_BAR_X2) begin
                draw_on = 1;
                R = 8'hFF; G = 8'hC0; B = 8'h40;
            end

            // Prompt bar (white)
            if (pixel_y >= PROMPT_BAR_Y1 && pixel_y < PROMPT_BAR_Y2 &&
                pixel_x >= PROMPT_BAR_X1 && pixel_x < PROMPT_BAR_X2) begin
                draw_on = 1;
                R = 8'hFF; G = 8'hFF; B = 8'hFF;
            end

            // Title text
            if (title_on) begin
                draw_on = 1;
                R = tR1; G = tG1; B = tB1;
            end

            // Prompt text (only text blinks)
            if (prompt_on && blink_on) begin
                draw_on = 1;
                R = tR2; G = tG2; B = tB2;
            end
        end
    end

endmodule



