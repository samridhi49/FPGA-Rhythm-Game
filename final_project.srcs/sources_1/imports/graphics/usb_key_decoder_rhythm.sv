module usb_key_decoder_rhythm(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] keycode,   // keycode0_gpio from MicroBlaze

    output logic        one_key_valid,   // exactly 1 lane key pressed
    output logic [1:0]  lane,            // 0=A, 1=S, 2=D, 3=F
    output logic        key_SPACE_pulse
);

    // USB HID codes for keys
    localparam logic [7:0] HID_A     = 8'h04;
    localparam logic [7:0] HID_S     = 8'h16;
    localparam logic [7:0] HID_D     = 8'h07;
    localparam logic [7:0] HID_F     = 8'h09;
    localparam logic [7:0] HID_SPACE = 8'h2C;

    // detect lane keys in any of the 4 slots
    logic isA, isS, isD, isF, isSPACE;

    always_comb begin
        isA = (keycode[7:0]   == HID_A) ||
              (keycode[15:8]  == HID_A) ||
              (keycode[23:16] == HID_A) ||
              (keycode[31:24] == HID_A);

        isS = (keycode[7:0]   == HID_S) ||
              (keycode[15:8]  == HID_S) ||
              (keycode[23:16] == HID_S) ||
              (keycode[31:24] == HID_S);

        isD = (keycode[7:0]   == HID_D) ||
              (keycode[15:8]  == HID_D) ||
              (keycode[23:16] == HID_D) ||
              (keycode[31:24] == HID_D);

        isF = (keycode[7:0]   == HID_F) ||
              (keycode[15:8]  == HID_F) ||
              (keycode[23:16] == HID_F) ||
              (keycode[31:24] == HID_F);

        isSPACE = (keycode[7:0]   == HID_SPACE) ||
                  (keycode[15:8]  == HID_SPACE) ||
                  (keycode[23:16] == HID_SPACE) ||
                  (keycode[31:24] == HID_SPACE);
    end

    // SPACE → pulse
    logic prev_space;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            prev_space <= 1'b0;
        else
            prev_space <= isSPACE;
    end

    assign key_SPACE_pulse = isSPACE & ~prev_space;

    // count lane keys
    logic [2:0] key_count;
    always_comb begin
        key_count = isA + isS + isD + isF;
    end

    assign one_key_valid = (key_count == 1);

    always_comb begin
        if (!one_key_valid) begin
            lane = 2'b00;
        end else begin
            case (1'b1)
                isA: lane = 2'd0;
                isS: lane = 2'd1;
                isD: lane = 2'd2;
                isF: lane = 2'd3;
                default: lane = 2'd0;
            endcase
        end
    end

endmodule
