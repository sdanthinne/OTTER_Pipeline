`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2019 03:19:15 PM
// Design Name: 
// Module Name: mcu_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// ω =
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mcu_test(

    );
    logic clk,rst,INT, iobus_wr;
    logic [31:0] iobus_in, iobus_out, iobus_addr;
    
    OTTER_MCU mcu(.CLK(clk),.RST(rst),.INT(INT), .IOBUS_IN(iobus_in), .IOBUS_OUT(iobus_out), .IOBUS_ADDR(iobus_addr),.IOBUS_WR(iobus_wr)
     );
    always
    begin
        clk = 0; #5; clk = 1; #5;
    end
    initial 
    begin
    rst = 1;
    #5
    rst = 0;
    INT = 1;
    #220
    INT = 0;
    #220
    INT = 1;
    
    end
endmodule
