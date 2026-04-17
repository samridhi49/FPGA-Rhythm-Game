module lane_background #(
    parameter H_RES    = 640,
    parameter V_RES    = 480,
    parameter LANE_W   = 80,
    parameter X_OFFSET = 80,
    parameter TILE_H   = 32,

    // central background gradient colors
    parameter [7:0] BG_TOP_R = 8'h10,
    parameter [7:0] BG_TOP_G = 8'h10,
    parameter [7:0] BG_TOP_B = 8'h20,
    parameter [7:0] BG_BOT_R = 8'h40,
    parameter [7:0] BG_BOT_G = 8'h40,
    parameter [7:0] BG_BOT_B = 8'h80,

    // side (left + right) gradient colors
    parameter [7:0] SIDE_TOP_R = 8'h05,
    parameter [7:0] SIDE_TOP_G = 8'h05,
    parameter [7:0] SIDE_TOP_B = 8'h10,
    parameter [7:0] SIDE_BOT_R = 8'h20,
    parameter [7:0] SIDE_BOT_G = 8'h20,
    parameter [7:0] SIDE_BOT_B = 8'h50,

    // divider + hit line color
    parameter [7:0] LINE_R = 8'hFF,
    parameter [7:0] LINE_G = 8'hFF,
    parameter [7:0] LINE_B = 8'hFF,

    // divider thickness
    parameter integer LINE_THICK = 3
)(
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic       active,

    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
);

    // =========================================================
    // GRADIENTS
    // =========================================================
    logic [7:0] grad_r, grad_g, grad_b;
    logic [7:0] side_r, side_g, side_b;

    always_comb begin
        grad_r = BG_TOP_R + ((BG_BOT_R - BG_TOP_R) * pixel_y) / V_RES;
        grad_g = BG_TOP_G + ((BG_BOT_G - BG_TOP_G) * pixel_y) / V_RES;
        grad_b = BG_TOP_B + ((BG_BOT_B - BG_TOP_B) * pixel_y) / V_RES;

        side_r = SIDE_TOP_R + ((SIDE_BOT_R - SIDE_TOP_R) * pixel_y) / V_RES;
        side_g = SIDE_TOP_G + ((SIDE_BOT_G - SIDE_TOP_G) * pixel_y) / V_RES;
        side_b = SIDE_TOP_B + ((SIDE_BOT_B - SIDE_TOP_B) * pixel_y) / V_RES;
    end

    // =========================================================
    // LANE DIVIDERS (5 vertical lines)
    // =========================================================
    logic divider_on;

    always_comb begin
        divider_on = 1'b0;

        for (int i = 1; i <= 5; i++) begin
            int x_line = X_OFFSET + i * LANE_W;
            if (pixel_x >= x_line - LINE_THICK/2 &&
                pixel_x <  x_line + LINE_THICK/2)
                divider_on = 1'b1;
        end
    end

    // =========================================================
    // HIT LINE (MATCHES tile_manager + hit detector)
    // =========================================================
    localparam int HIT_LINE_Y = V_RES - TILE_H;

    // Only center 4 lanes
    localparam int LANES_LEFT  = X_OFFSET + LANE_W;
    localparam int LANES_RIGHT = X_OFFSET + 5*LANE_W;

    logic hit_line_on;
    always_comb begin
        hit_line_on = 1'b0;

        if (pixel_y >= HIT_LINE_Y - LINE_THICK/2 &&
            pixel_y <  HIT_LINE_Y + LINE_THICK/2 &&
            pixel_x >= LANES_LEFT &&
            pixel_x <  LANES_RIGHT)
            hit_line_on = 1'b1;
    end

    // =========================================================
    // FINAL COLOR SELECT
    // =========================================================
    always_comb begin
        if (!active) begin
            R = 0; G = 0; B = 0;
        end
        else if (divider_on || hit_line_on) begin
            R = LINE_R;
            G = LINE_G;
            B = LINE_B;
        end
        else if (pixel_x < LANES_LEFT || pixel_x >= LANES_RIGHT) begin
            R = side_r;
            G = side_g;
            B = side_b;
        end
        else begin
            R = grad_r;
            G = grad_g;
            B = grad_b;
        end
    end

endmodule