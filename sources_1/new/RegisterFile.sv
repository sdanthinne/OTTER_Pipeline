`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2019 10:42:45 AM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile32x32(
    input CLK,
    input EN,//enable?
    input [31:0] WD,//write data
    input [4:0] ADR1, ADR2, WA,//addresses?
    output [31:0] RS1,RS2 //unsure of diff
    );
    logic [31:0] mem [0:31];//[word size (32)] mem [address]
    initial
    begin
        for( int i = 0; i<32; i++)begin
            mem[i] = 0;
        end
    end
    //synch write to write address (WA)
    //synch write only on EN(able) and WA == 0 
    //(Register zero must always be zero)
    always_ff @ (posedge CLK)
    begin
        
        if(EN == 1 && WA !=0)
            mem[WA] <=WD;
    end
    
    //asynch read from memory locations ADR1 and ADR2
    assign RS1 = mem[ADR1];
    assign RS2 = mem[ADR2];
endmodule

module Register(clk, enable, din, dout,rst,setnull);
    input [31:0] din;
    input enable, clk,rst;
    //enable is equivalent to writeEnable
    output logic [31:0] dout=0;
    //basic instruction register
    
    
    always_ff @ (posedge clk)
    begin
        if(enable) dout <= din;
        if (rst) dout <= 0;
        if (setnull) dout <= 32'b00000013;
        dout<=dout;
    end
endmodule

module Register2(clk, enable, din1, dout1,pcin,pcout,rst,setnull);
    input [31:0] din1;
    input [31:0] pcin;
    input enable, clk,rst;
    output logic [31:0] dout1=0;
    output logic [31:0] pcout=0;

    //basic instruction register
    
    
    always_ff @ (posedge clk)
    begin
        if(enable)begin
            pcout <= pcin;
            dout1 <= din1;
        end 
        if (rst) 
        begin
            dout1<=0;
            pcout<=0;
        end

        if (setnull) 
        begin
            dout1 <= 32'b00000013;
            pcout <= pcout;
        end
        pcout<=pcout;
        dout1<=dout1;
    end
endmodule