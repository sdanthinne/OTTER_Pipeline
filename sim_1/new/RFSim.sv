`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2019 09:00:17 AM
// Design Name: 
// Module Name: RFSim
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


module RFSim();
    logic CLK, EN;
    logic [31:0] WD, RS1, RS2;
    logic [4:0] ADR1, ADR2, WA;
    RegisterFile mainReg (.*);
    always
    begin
        CLK = 0; #5; CLK = 1; #5;
    end
    initial
    begin
        EN = 1; WD = 32'h12; WA = 0;
        //Should not write because WA = 0
        #10
        WA = 1;ADR1 = 1;
        #10
        WA = 2;ADR2 = 1; ADR1 = 2;
        #10
        EN = 0;WD = 32'hFF;
        //should not write anything, enable off, preserve last value in location 2
        #10
        WA = 3; EN = 1; ADR2 = 3;
        //should continue writing
        #10
        WA = 4;ADR2 = 4;
        #10
        WA = 5;ADR2 = 5;
        #10
        WA = 6;ADR2 = 6;
        #10
        WA = 7;ADR2 = 7;
        #10
        WA = 31;ADR2 = 31;
    end
endmodule

module ALUSim();
    //logic CLK;
    ALU alu1 (.*);
    logic [31:0] A, B, ALU_OUT;
    logic [3:0] ALU_FUN;
    initial
    begin
    //add
    A = 32'hAA;
    B = 32'hAA;
    ALU_FUN = 0;
    #5;
    assert (ALU_OUT == 32'h154) $display("test 1 pass (add)");
        else $error("test 1 failed");
    #5;
    //sub
    A = 32'hC8;
    B = 32'h37;
    ALU_FUN = 8;
    #5;
    assert (ALU_OUT == 32'h91) $display("test 2 pass (sub)");
        else $error("test 2 failed");
    #5;

    //or
    A = 32'hc8;
    B = 32'h64;
    ALU_FUN = 6;
    #5;
    assert (ALU_OUT == 32'hec) $display("test 3 pass (or)");
        else $error("test 3 failed");
    #5;
    //and
    A = 32'h12c8;
    B = 32'h12c8;
    ALU_FUN = 7;
    #5;
    assert (ALU_OUT == 32'h12c8) $display("test 4 pass (and)");
        else $error("test 4 failed");
    #5;
    //xor
    A = 32'hAAaabbbb;
    B = 32'hffffffff;
    ALU_FUN = 4;
    #5;
    assert (ALU_OUT == 32'h55554444) $display("test 4 pass (xor)");
        else $error("test 4 failed");
    #5;
    //srl
    A = 32'hAAAA;
    B = 32'h0A;
    ALU_FUN = 5;
    #5;
    assert (ALU_OUT == 32'h2a) $display("test 5 pass (srl)");
        else $error("test 5 failed");
    #5;
    //sll
    //has error
    A = 32'hAA;
    B = 32'h0c;
    ALU_FUN = 1;
    #5;
    assert (ALU_OUT == 32'h000aa000) $display("test 6 pass (sll)");
        else $error("test 6 failed");
    #5;
    //sra
    A = 32'hAA;
    B = 32'h03;
    ALU_FUN = 13;
    #5;
    assert (ALU_OUT == 32'h15) $display("test 7 pass (sra)");
        else $error("test 7 failed");
    #5;
    //sra
    A = -32'd20;
    B = 32'd2;
    ALU_FUN = 13;
    #5;
    assert (ALU_OUT == 32'hfffffffb) $display("test 7.1 pass (sra)");
        else $error("test 7.1 failed");
    #5;
    //slt
    A = 32'hAA;
    B = 32'hAA;
    ALU_FUN = 2;
    #5;
    assert (ALU_OUT == 32'h0) $display("test 8 pass (slt)");
        else $error("test 8 failed");
    #5;
    //slt
    A = -32'd5;
    B = -32'd10;
    ALU_FUN = 2;
    #5;
    assert (ALU_OUT == 32'h0) $display("test 8 pass (slt)");
        else $error("test 8 failed");
    #5;
    //sltu
    A = 32'hAA;
    B = 32'h55;
    ALU_FUN = 3;
    #5;
    assert (ALU_OUT == 32'h0) $display("test 9 pass (sltu)");
        else $error("test 9 failed");
    #5;
    //copy(lui)
    A = 32'hABC12301;
    B = 32'h12345678;
    ALU_FUN = 9;
    #5;
    assert (ALU_OUT == 32'hABC12301) $display("test 10 pass (copy)");
        else $error("test 10 failed");
    #5;
    
    
    
    end
endmodule
