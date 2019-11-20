`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2019 09:56:39 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
input [31:0] A,B,input [3:0] ALU_FUN, output logic [31:0] ALU_OUT
    );
    typedef enum logic [3:0] {ADD = 4'b0000,
    SUB = 4'b1000,
    OR = 4'b0110,
    AND = 4'b0111,
    XOR = 4'b0100,
    SRL = 4'b0101,
    SLL = 4'b0001,
    SRA = 4'b1101,
    SLT = 4'b0010,
    SLTU = 4'b0011,
    LUI = 4'b1001} op_type;
    op_type ALU_FUN_t;
    
    assign ALU_FUN_t = op_type'(ALU_FUN);
    
    always_comb
    begin
    case(ALU_FUN_t)
        ADD: ALU_OUT = A+B;//add
        SUB: ALU_OUT = A-B;//sub
        OR: ALU_OUT = A|B;//or
        AND: ALU_OUT = A&B;//and
        XOR: ALU_OUT = A^B;//xor
        SRL: ALU_OUT = A>>B[4:0];//SRL
        SLL: ALU_OUT = A<<B[4:0];//sll
        SRA: ALU_OUT = $signed(A)>>>B[4:0];//sra
        SLT: ALU_OUT = ($signed(A)<$signed(B)) ? 1:0;//slt
        SLTU: ALU_OUT = (A<B) ? 1:0;//sltu
        LUI: ALU_OUT = A;//LUI
        default:ALU_OUT = 0;
    endcase
    end
endmodule
