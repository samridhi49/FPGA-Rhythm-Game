typedef enum logic [1:0] {
    START_SCREEN = 2'd0,
    GAME_PLAY    = 2'd1,
    GAME_OVER    = 2'd2
} game_state_t;

module game_fsm(
    input  logic       clk,
    input  logic       reset,
    input  logic       space_pressed,
    input  logic [1:0] miss_count,

    output game_state_t state,
    output logic        restart_game   // NEW
);

    game_state_t next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= START_SCREEN;
        else
            state <= next_state;
    end

    always_comb begin
        next_state   = state;
        restart_game = 1'b0;

        case (state)

            START_SCREEN: begin
                if (space_pressed) begin
                    next_state   = GAME_PLAY;
                    restart_game = 1'b1;   // reset score/misses
                end
            end

            GAME_PLAY: begin
                if (miss_count == 2'd3)
                    next_state = GAME_OVER;
            end

            GAME_OVER: begin
                if (space_pressed) begin
                    next_state   = START_SCREEN;
                    restart_game = 1'b1;   // reset for new run
                end
            end

        endcase
    end

endmodule