`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2019 10:25:47 AM
// Design Name: 
// Module Name: Lab1Top_sim
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


module Lab1Top_sim(

    );
    logic [31:0] JALR,BRANCH,JUMP, DOUT;
    logic  CLK, RESET, MEM_READ1, PC_WRITE;
    logic [1:0] PC_SOURCE;
    Lab1Top lab1Test(.*);
    always 
    begin
        CLK = 0; #5; CLK = 1; #5;
    end
    initial 
    begin
        RESET = 1;
        #10;
        JALR = 12; JUMP = 4; BRANCH = 8; PC_WRITE = 1; MEM_READ1 = 1; PC_SOURCE = 0; RESET = 0;
        #50;
        PC_WRITE = 1; MEM_READ1 = 0;
        #10;
        MEM_READ1 = 1; PC_SOURCE = 1;
        #10;
        PC_SOURCE = 2;
        #10;
        PC_SOURCE = 3;
        #10
        RESET = 1;
        #10;
        RESET = 0; PC_SOURCE = 1; PC_WRITE = 0;
        #20;
        MEM_READ1 = 0; PC_WRITE = 1; PC_SOURCE = 2;
        #10
        PC_WRITE = 0;
        
        
        
        
        
        
    end
endmodule
