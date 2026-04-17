//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------
//    module tile
//(
//    input  logic        Reset,
//    input  logic        frame_clk,   // same as vsync or frame clock
//    output logic [9:0]  TileX,
//    output logic [9:0]  TileY
//);

//    parameter TILE_SIZE = 120;

//    // Screen boundaries (640x480)
//    parameter [9:0] Y_MAX = 479;
//    parameter [9:0] Y_MIN = 0;

//    // Lane selection (0-3)
//    // For now, drop from lane 2
//    parameter [1:0] LANE = 2;

//    // Lane width = 640/4 = 160
//    localparam LANE_WIDTH = 160;

//    // Speed of falling per frame
//    parameter [9:0] SPEED = 4;   //CONTROL SPEED

//    // INTERNAL REGISTERS
//    logic [9:0] Tile_Y_next;
    
//    // TileX depends only on lane ? no movement in X
//    always_comb begin
//        TileX = LANE * LANE_WIDTH + (LANE_WIDTH - TILE_SIZE)/2;
//    end

    
//    // TILE FALLING LOGIC
//    always_comb begin
//        Tile_Y_next = TileY + SPEED;

//        // When tile passes bottom of screen ? restart at top
//        if (TileY >= (Y_MAX + TILE_SIZE))
//            Tile_Y_next = -TILE_SIZE;
//    end

//    // UPDATE ON FRAME CLOCK
//    always_ff @(posedge frame_clk) begin
//        if (Reset) begin
//            TileY <= -TILE_SIZE;    // start off-screen
//        end else begin
//            TileY <= Tile_Y_next;
//        end
//    end

//endmodule

//module  ball 
//( 
//    input  logic        Reset, 
//    input  logic        frame_clk,
//    input  logic [7:0]  keycode,

//    output logic [9:0]  BallX, 
//    output logic [9:0]  BallY, 
//    output logic [9:0]  BallS 
//);
	 
//    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
//    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

//    logic [9:0] Ball_X_Motion;
//    logic [9:0] Ball_X_Motion_next;
//    logic [9:0] Ball_Y_Motion;
//    logic [9:0] Ball_Y_Motion_next;

//    logic [9:0] Ball_X_next;
//    logic [9:0] Ball_Y_next;

//    always_comb begin
//        Ball_Y_Motion_next = Ball_Y_Motion; // set default motion to be same as prev clock cycle 
//        Ball_X_Motion_next = Ball_X_Motion;

//        //modify to control ball motion with the keycode
//        if (keycode == 8'h1A) //'W'
//        begin
//            Ball_Y_Motion_next = (~ (Ball_Y_Step) + 1'b1);
//            Ball_X_Motion_next = 0;
//        end

//        else if (keycode == 8'h04) //'A'
//        begin
//            Ball_Y_Motion_next = 0;
//            Ball_X_Motion_next = (~ (Ball_X_Step) + 1'b1);
//        end

//        else if (keycode == 8'h16) //'S'
//        begin
//            Ball_Y_Motion_next = Ball_Y_Step;
//            Ball_X_Motion_next = 0;
//        end        

//        else if (keycode == 8'h07) //'D'
//        begin
//            Ball_Y_Motion_next = 0;
//            Ball_X_Motion_next = Ball_X_Step;
//        end  

//        else
//        begin
//            Ball_X_Motion_next = Ball_X_Motion;
//            Ball_Y_Motion_next = Ball_Y_Motion;
//        end  
        
//        /* Vertical */
//        if ( (BallY + BallS) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
//        begin
//            Ball_Y_Motion_next = (~ (Ball_Y_Step) + 1'b1);  // set to -1 via 2's complement.
//        end

//        else if ( (BallY - BallS) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
//        begin
//            Ball_Y_Motion_next = Ball_Y_Step;
//        end  

//        /* Horizontal */
//        if ( (BallX + BallS) >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
//        begin
//            Ball_X_Motion_next = (~ (Ball_X_Step) + 1'b1);
//        end

//        else if ( (BallX - BallS) <= Ball_X_Min )  // Ball is at the left edge, BOUNCE!
//        begin
//            Ball_X_Motion_next = Ball_X_Step;
//        end  

//        //fill in the rest of the motion equations here to bounce left and right

//    end

//    assign BallS = 16;  // default ball size
//    assign Ball_X_next = (BallX + Ball_X_Motion_next);
//    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
   
//    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
//    begin: Move_Ball
//        if (Reset)
//        begin 
//            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
//			Ball_X_Motion <= 10'd1; //Ball_X_Step;
            
//			BallY <= Ball_Y_Center;
//			BallX <= Ball_X_Center;
//        end
//        else 
//        begin 

//			Ball_Y_Motion <= Ball_Y_Motion_next; 
//			Ball_X_Motion <= Ball_X_Motion_next; 

//            BallY <= Ball_Y_next;  // Update ball position
//            BallX <= Ball_X_next;
			
//		end  
//    end

//endmodule

module ball 
(
    input  logic        Reset, 
    input  logic        frame_clk,

    output logic [9:0]  BallX, 
    output logic [10:0] BallY, 
    output logic [9:0]  BallS
);

    parameter Ball_Size  = 160;      
    parameter Ball_Y_Min = 0;        
    parameter Ball_Y_Max = 479;      
    parameter Speed      = 4;        

    assign BallS = Ball_Size;
 
    localparam LANE_WIDTH = 160;
    localparam LANE = 2;

    always_comb begin
        BallX = LANE*LANE_WIDTH;
    end

 
    logic [10:0] Ball_Y_next;

    always_comb begin
        // fall down by constant speed
        Ball_Y_next = BallY + Speed;

        // if ball moves completely off-screen, restart above top
        if (BallY >= (Ball_Y_Max + Ball_Size))
            Ball_Y_next = 0;
    end

   
    always_ff @(posedge frame_clk) begin
        if (Reset)
            BallY <= Ball_Size;   // start above the screen
        else
            BallY <= Ball_Y_next;
    end

endmodule
