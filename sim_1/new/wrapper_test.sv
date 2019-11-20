`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2019 04:18:24 PM
// Design Name: 
// Module Name: wrapper_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrapper_test();
logic CLK;
logic [15:0] LEDS;
logic [7:0] CATHODES;
logic [3:0] ANODES;
logic btnc,btnl;
OTTER_Wrapper w1(.CLK(CLK),.SWITCHES(0),.LEDS(LEDS),.CATHODES(CATHODES),.ANODES(ANODES),.BTNC(btnc),.BTNL(btnl));
always
    begin
        CLK = 0; #5; CLK = 1; #5;
    end
initial
begin
//OTTER_Wrapper(
//   input CLK,
//   input BTNL,
//   input BTNC,
//   input [15:0] SWITCHES,
//   output logic [15:0] LEDS,
//   output [7:0] CATHODES,
//   output [3:0] ANODES
//   );
btnc = 1;
#5
btnc = 0;
btnl = 1;
#800
btnl = 0;




end
endmodule
