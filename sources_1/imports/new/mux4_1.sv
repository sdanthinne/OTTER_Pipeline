`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2019 11:25:04 AM
// Design Name: 
// Module Name: mux4_1
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

module Lab1Top(JALR,BRANCH,JUMP,PC_SOURCE,PC_WRITE,RESET,CLK,MEM_READ1,DOUT);
    input [31:0] JALR, BRANCH, JUMP;
    input [1:0] PC_SOURCE;
    input PC_WRITE, RESET, CLK, MEM_READ1;
    output logic [31:0] DOUT;
    
    logic [31:0] pc_in, pc_out, pc_4;
    
    //mux4_1 PCMux(.ZERO(pc_4),.ONE(JALR),.TWO(BRANCH),.THREE(JUMP),.SEL(PC_SOURCE),.MUXOUT(pc_in));
    //PC counter1(.D_IN(pc_in),.PC_WRITE(PC_WRITE),.RST(RESET),.CLK(CLK),.D_OUT(pc_out));
    
    //assign pc_4 = pc_out + 4;
    //OTTER_mem_byte mem1(.MEM_CLK(CLK),.MEM_ADDR1(pc_out),.MEM_READ1(MEM_READ1),.MEM_DOUT1(DOUT));
    
endmodule


module mux4_1(
    input [31:0] ZERO,
    input [31:0] ONE,
    input [31:0] TWO,
    input [31:0] THREE,
    input [1:0] SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb 
    begin
        case(SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT =ONE;
            2:MUXOUT = TWO;
            3: MUXOUT = THREE;
            default: MUXOUT = ZERO;
        endcase
    end
endmodule

module mux8_3(
    input [31:0] ZERO,
    input [31:0] ONE,
    input [31:0] TWO,
    input [31:0] THREE,
    input [31:0] FOUR,
    input [31:0] FIVE,
    input [31:0] SIX,
    input [31:0] SEVEN,
    input [2:0] SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb 
    begin
        case(SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT =ONE;
            2:MUXOUT = TWO;
            3: MUXOUT = THREE;
            4: MUXOUT = FOUR;
            5: MUXOUT = FIVE;
            6: MUXOUT = SIX;
            7: MUXOUT = SEVEN;
            
            default: MUXOUT = ZERO;
        endcase
    end
endmodule

module mux2_1(
    input [31:0] ZERO,
    input [31:0] ONE,
    input SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb 
    begin
        case(SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT =ONE;
            default: MUXOUT = ZERO;
        endcase
    end
endmodule

module PC (
input [31:0] D_IN,
input PC_WRITE, RST, CLK,
output logic [31:0] D_OUT=0);

    always_ff @(posedge CLK)
    begin
        if(RST)
            D_OUT <= 0;
        else if(PC_WRITE)
            D_OUT <= D_IN;
            //not having a final else statement creates it as memory
    end

endmodule
