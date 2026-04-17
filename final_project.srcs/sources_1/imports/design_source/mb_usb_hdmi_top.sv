//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//    10-14-25                                                           --
//                                                                       --
//    Fall 2025 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    output logic audio_out,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    logic [7:0] game_R8, game_G8, game_B8;

    logic sample_en;
    logic pwm_ce;
    logic [16:0] rom_addr;
    logic [7:0] rom_sample;
    logic [7:0] audio_sample;
    logic        audio_valid;
    
    assign reset_ah = reset_rtl_0;
    
//    logic [9:0] TileX, TileY;
//    logic [3:0] tile_red, tile_green, tile_blue;
     
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    // Rhythm game graphics
    rhythm_game game_inst (
    .clk_pix (clk_25MHz),
    .reset   (reset_ah),
    .vsync   (vsync),
    .keycode (keycode0_gpio),
    .drawX   (drawX),
    .drawY   (drawY),
    .active  (vde),
    .R8      (game_R8),
    .G8      (game_G8),
    .B8      (game_B8)
);

assign red   = game_R8[7:4];
assign green = game_G8[7:4];
assign blue  = game_B8[7:4];

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );
    
    //Ball Module
//   ball ball_instance(
//      .Reset(reset_ah),
//        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move
        //.keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
//        .BallX(ballxsig),
//        .BallY(ballysig),
//        .BallS(ballsizesig)
//   );

//tile tile_instance (
//    .Reset(reset_ah),
//    .frame_clk(vsync),   // updates once per frame
//    .TileX(TileX),
//    .TileY(TileY)
//);

//    color_mapper tile_color_mapper (
//    .TileX(TileX),
//    .TileY(TileY),
//    .DrawX(drawX),
//    .DrawY(drawY),
//    .Red(tile_red),
//    .Green(tile_green),
//    .Blue(tile_blue)
//);

    
///Color Mapper Module   
//    color_mapper color_instance(
//        .BallX(ballxsig),
//        .BallY(ballysig),
//        .DrawX(drawX),
//        .DrawY(drawY),
//        .Ball_size(ballsizesig),
//        .Red(red),
//        .Green(green),
//        .Blue(blue)
//   );
    
      audio_rom rom_inst (
        .clka   (Clk),
        .addra (rom_addr),
        .douta (rom_sample)
    );
    
     sample_enable_pwm sample_en_gen (
        .clk_100mhz(Clk),
        .sample_en_11m  (pwm_ce),
        .sample_en_44k (sample_en)
    );

    
    
    audio_player player_inst (
        .clk_100mhz      (Clk),
        .reset_n        (1'b1),       // always running
        .play         (1'b1),       // start immediately
        .rom_addr     (rom_addr),
        .sample_en    (sample_en),
        .rom_sample   (rom_sample),
        .audio_sample (audio_sample),
        .sample_valid (sample_valid)
    );
    

    
    pwm_audio pwm_inst (
        .clk_100mhz      (Clk),
        .pwm_ce (pwm_ce),
        .sample   (audio_sample),
        .pwm_out  (audio_out)
    );


    
//    // Instantiate modules with separate outputs
//lanes_example lanes_instance (
//    .vga_clk(clk_25MHz),
//    .DrawX(drawX),
//    .DrawY(drawY),
//    .blank(vde),
//    .red(lane_red),
//    .green(lane_green),
//    .blue(lane_blue)
//);
    
//    up_arrow_example up_arrow_instance(
//    .vga_clk(clk_25MHz),
//    .DrawX(drawX),
//    .DrawY(drawY),
//    .blank(vde),
//    .red(arrow_red),
//    .green(arrow_green),
//    .blue(arrow_blue)
//);
    
//assign red   = tile_red;
//assign green = tile_green;
//assign blue  = tile_blue;

endmodule


