module text_renderer #(
    parameter MAX_LEN = 32,
    parameter SCALE   = 1,                     // text scaling factor
    parameter [7:0] TXT_R = 8'h00,
    parameter [7:0] TXT_G = 8'h00,
    parameter [7:0] TXT_B = 8'h00
)(
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic       active,

    input  logic [9:0] text_x,
    input  logic [9:0] text_y,

    input  logic [MAX_LEN-1:0][7:0] message,

    output logic       text_on,
    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
);

    // ---------------------------------------------------------
    // Relative pixel coordinates to text origin
    // ---------------------------------------------------------
    logic signed [11:0] rel_x, rel_y;
    assign rel_x = pixel_x - text_x;
    assign rel_y = pixel_y - text_y;

    // Total rendered width and height
    localparam int GLYPH_W = 8 * SCALE;
    localparam int GLYPH_H = 8 * SCALE;
    localparam int TEXT_W  = MAX_LEN * GLYPH_W;


    // ---------------------------------------------------------
    // Character index and glyph row/column
    // ---------------------------------------------------------
    logic [5:0] char_idx;  // up to 63 chars
    logic [2:0] row;
    logic [2:0] col;

    always_comb begin
        if (rel_x < 0 || rel_y < 0) begin
            char_idx = 0;
            row = 0;
            col = 0;
        end else begin
            char_idx = rel_x / GLYPH_W;
            row      = (rel_y / SCALE) % 8;
            col      = (rel_x / SCALE) % 8;
        end
    end


    // ---------------------------------------------------------
    // Fetch glyph row from ROM
    // ---------------------------------------------------------
    logic [7:0] bits;

    font_rom rom (
        .char_code(message[char_idx]),
        .row(row),
        .bits(bits)
    );

    logic pixel_bit = bits[7 - col];  // leftmost is MSB


    // ---------------------------------------------------------
    // TEXT ON/OFF (critical to avoid repetition)
    // ---------------------------------------------------------
    always_comb begin
        text_on = 1'b0;

        // Entirely off if VGA inactive
        if (!active) begin
            text_on = 0;
        end

        // Before text box
        else if (rel_x < 0 || rel_y < 0) begin
            text_on = 0;
        end

        // Beyond rendered width
        else if (rel_x >= (MAX_LEN * GLYPH_W)) begin
            text_on = 0;
        end

        // Beyond glyph height
        else if (rel_y >= GLYPH_H) begin
            text_on = 0;
        end

        // After last meaningful character
        else if (char_idx >= MAX_LEN) begin
            text_on = 0;
        end

        // Otherwise valid pixel
        else begin
            text_on = pixel_bit;
        end
    end


    // ---------------------------------------------------------
    // Output pixel color
    // ---------------------------------------------------------
    always_comb begin
        if (text_on) begin
            R = TXT_R;
            G = TXT_G;
            B = TXT_B;
        end else begin
            R = 0;
            G = 0;
            B = 0;
        end
    end

endmodule



