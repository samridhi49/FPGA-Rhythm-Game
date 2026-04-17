//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

//module color_mapper (
//    input  logic [9:0] TileX, TileY,      // tile position
//    input  logic [9:0] DrawX, DrawY,      // VGA pixel coordinates
//    output logic [3:0] Red, Green, Blue
//);

//    localparam TILE_SIZE = 120;

//    // tile detection
//    logic tile_on;

//    always_comb begin
//        tile_on = (DrawX >= TileX) &&
//                  (DrawX <  TileX + TILE_SIZE) &&
//                  (DrawY >= TileY) &&
//                  (DrawY <  TileY + TILE_SIZE);
//    end

//    // lane boundaries (vertical lines)
//    logic lane_line;
//    always_comb begin
//        // black lane separators at 160, 320, 480
//        lane_line = (DrawX == 10'd160) ||
//                    (DrawX == 10'd320) ||
//                    (DrawX == 10'd480);
//    end

//    // pixel color output
//    always_comb begin
//        if (tile_on) begin
//            // tile color
//            Red   = 4'hF;
//            Green = 4'h7;
//            Blue  = 4'h0;
//        end
//        else if (lane_line) begin
//            // black lane lines
//            Red   = 4'h0;
//            Green = 4'h0;
//            Blue  = 4'h0;
//        end
//        else begin
//            // white background
//            Red   = 4'hF;
//            Green = 4'hF;
//            Blue  = 4'hF;
//        end
//    end

//endmodule

module  color_mapper ( input  logic [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
                       output logic [3:0]  Red, Green, Blue );
    
    logic ball_on;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*BallS, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))
       )

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 120 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
//    int DistX, DistY, Size;
//    assign DistX = DrawX - BallX;
//    assign DistY = DrawY - BallY;
//    assign Size = Ball_size;
  
  //logic [3:0] intensity;
   
    always_comb
    begin:Ball_on_proc
        if ((DrawX >= BallX) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY) &&
       (DrawY <= BallY + Ball_size))
       
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
     
     logic lane_line;
    always_comb begin
        // black lanes at 160, 320, 480
        lane_line = (DrawX == 10'd160) ||  (DrawX == 10'd320) ||  (DrawX == 10'd480);
    end
       
    always_comb
    begin:RGB_Display
        if ((ball_on == 1'b1)) begin 
            Red = 4'hf;
            Green = 4'h5;
            Blue = 4'h4;
        end       
        else if (lane_line) begin
            // black lane lines
            Red   = 4'h0;
            Green = 4'h0;
            Blue  = 4'h0;
        end
        else begin          
            Red   = 4'h6;
            Green = 4'hd;
            Blue  = 4'hF;
        end
    end
endmodule
