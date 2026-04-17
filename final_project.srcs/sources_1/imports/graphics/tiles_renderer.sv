module tile_renderer #(
    parameter integer H_RES    = 640,
    parameter integer V_RES    = 480,
    parameter integer LANE_W   = 80,
    parameter integer X_OFFSET = 80,
    parameter integer TILE_W   = 48,
    parameter integer TILE_H   = 32,
    parameter integer N_TILES  = 8,

    parameter [7:0] TILE_R = 8'h8F,
    parameter [7:0] TILE_G = 8'h14,
    parameter [7:0] TILE_B = 8'h02
)(
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic       active,

    input  logic [N_TILES-1:0][1:0] tile_lane,
    input  logic [N_TILES-1:0][9:0] tile_y,
    input  logic [N_TILES-1:0]      tile_active,

    output logic       tile_on,
    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
);

    integer i;
    logic hit;
    logic [7:0] hr, hg, hb;

    always_comb begin
        hit = 1'b0;
        hr = 8'd0; hg = 8'd0; hb = 8'd0;

        if (active) begin
            for (i = 0; i < N_TILES; i++) begin
                if (tile_active[i]) begin
                    int glane = tile_lane[i] + 1; // 0..3 → global lanes 1..4

                    int lane_x_start = X_OFFSET + glane * LANE_W;
                    int x0 = lane_x_start + (LANE_W - TILE_W)/2;
                    int x1 = x0 + TILE_W;
                    int y0 = tile_y[i];
                    int y1 = y0 + TILE_H;

                    if (pixel_x >= x0 && pixel_x < x1 &&
                        pixel_y >= y0 && pixel_y < y1) begin
                        hit = 1'b1;
                        hr  = TILE_R;
                        hg  = TILE_G;
                        hb  = TILE_B;
                    end
                end
            end
        end
    end

    always_comb begin
        tile_on = hit;
        if (hit) begin
            R = hr; G = hg; B = hb;
        end else begin
            R = 8'd0; G = 8'd0; B = 8'd0;
        end
    end

endmodule
