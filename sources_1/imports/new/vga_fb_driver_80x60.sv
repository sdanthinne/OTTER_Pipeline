`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Paul Hummel
//
// Create Date: 06/07/2018 06:00:59 PM
// Design Name:
// Module Name: vga_fb_driver_80x60
// Project Name: VGA 80x60
// Target Devices: OTTER MCU on Basys3
// Description: VGA framebuffer interface driver for the the OTTER MCU. Creates
//              8k x 8 framebuffer, control input interfaces (WA, WD, WE, RD),
//              and VGA output signals (ROUT, GOUT, BOUT, HS, VS).
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.10 - (Keefe Johnson) Renamed clocks for clarity. Other minor style
//                 tweaks.
//////////////////////////////////////////////////////////////////////////////////


module vga_fb_driver_80x60(
    input CLK_50MHz,
    input [12:0] WA,
    input [7:0] WD,
    input WE,
    output [7:0] RD,
    output [2:0] ROUT,
    output [2:0] GOUT,
    output [1:0] BOUT,
    output HS,
    output VS
    );
    
    logic CLK_25MHz = 0;
    logic [7:0] s_fb_rd;
    logic [12:0] s_fb_ra;
    logic [2:0] s_vga_red;
    logic [2:0] s_vga_green;
    logic [1:0] s_vga_blue;
    logic [9:0] s_vga_row;
    logic [9:0] s_vga_col;
    
    // divide by 2 clock divider to create 25 MHz clock
    always_ff @(posedge CLK_50MHz) begin
        CLK_25MHz <= ~CLK_25MHz;
    end

    // VGA output
    vga_driver_80x60 vga_out(.CLK_25MHz(CLK_25MHz), .RED(s_vga_red),
                             .GREEN(s_vga_green), .BLUE(s_vga_blue),
                             .ROW(s_vga_row), .COLUMN(s_vga_col), .ROUT(ROUT),
                             .GOUT(GOUT), .BOUT(BOUT), .HSYNC(HS), .VSYNC(VS));
    
    // Framebuffer
    ram8k_8_80x60 framebuffer(.CLK_50MHz(CLK_50MHz), .WE(WE), .RA2(s_fb_ra),
                              .WA1(WA), .WD(WD), .RD2(s_fb_rd), .RD1(RD));
    
    // combine row and column from the vga_driver to create read address RA2
    // for the framebuffer which returns color data as RD2
    assign s_fb_ra = {s_vga_row[8:3], s_vga_col[9:3]};  // MSB of row not needed
    
    // divide the color data from the framebuffer into individual RGB values
    // for the vga_driver
    assign s_vga_red = s_fb_rd[7:5];
    assign s_vga_green = s_fb_rd[4:2];
    assign s_vga_blue = s_fb_rd[1:0];

endmodule


module vga_fb_driver_320x240(
    input CLK_50MHz,
    input [16:0] WA,
    input [7:0] WD,
    input WE,
    output [7:0] RD,
    output [2:0] ROUT,
    output [2:0] GOUT,
    output [1:0] BOUT,
    output HS,
    output VS
    );
    
    logic CLK_25MHz = 0;
    logic [7:0] s_fb_rd;
    logic [16:0] s_fb_ra;
    logic [2:0] s_vga_red;
    logic [2:0] s_vga_green;
    logic [1:0] s_vga_blue;
    logic [9:0] s_vga_row;
    logic [9:0] s_vga_col;
    
    // divide by 2 clock divider to create 25 MHz clock
    always_ff @(posedge CLK_50MHz) begin
        CLK_25MHz <= ~CLK_25MHz;
    end

    // VGA output
    vga_driver_640x480 vga_out(.CLK_25MHz(CLK_25MHz), .RED(s_vga_red),
                             .GREEN(s_vga_green), .BLUE(s_vga_blue),
                             .ROW(s_vga_row), .COLUMN(s_vga_col), .ROUT(ROUT),
                             .GOUT(GOUT), .BOUT(BOUT), .HSYNC(HS), .VSYNC(VS));
    
    // Framebuffer
    //ram8k_8_640x480 framebuffer(.CLK_50MHz(CLK_50MHz), .WE(WE), .RA2(s_fb_ra),
    //                          .WA1(WA), .WD(WD), .RD2(s_fb_rd), .RD1(RD)); 
//   blk_mem_gen_0 mem_128x8 (
//  .clka(CLK_50MHz),    // input wire clka
//  .ena(WE),      // input wire ena
//  .wea(WE),      // input wire [0 : 0] wea
//  .addra(s_fb_ra),  // input wire [14 : 0] addra
//  .dina(WD),    // input wire [7 : 0] dina
//  .douta(s_fb_rd)  // output wire [7 : 0] douta
//);

blk_mem_gen_0 mem_128x8 (
  .clka(CLK_50MHz),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(WE),      // input wire [0 : 0] wea
  .addra(WA),  // input wire [16 : 0] addra
  .dina(WD),    // input wire [8 : 0] dina
  .clkb(CLK_50MHz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(s_fb_ra),  // input wire [16 : 0] addrb
  .doutb(s_fb_rd)  // output wire [8 : 0] doutb
);

    // combine row and column from the vga_driver to create read address RA2
    // for the framebuffer which returns color data as RD2
    //this line can be changed to use much less memory
    //for every 320 addresses is one row
    assign s_fb_ra = (320*s_vga_row[8:1])+ s_vga_col[9:1];
    //assign s_fb_ra = {s_vga_row[8:1], s_vga_col[9:1]};  // MSB of row not needed
    
    // divide the color data from the framebuffer into individual RGB values
    // for the vga_driver
    assign s_vga_red = s_fb_rd[7:5];
    assign s_vga_green = s_fb_rd[4:2];
    assign s_vga_blue = s_fb_rd[1:0];

endmodule
