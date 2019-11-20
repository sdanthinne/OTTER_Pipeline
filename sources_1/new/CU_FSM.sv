`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2019 10:00:36 AM
// Design Name: 
// Module Name: 
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


module CU_FSM(CLK,INT, RST, CU_OPCODE,PC_WRITE,REG_WRITE,MEM_WRITE,MEM_READ1,MEM_READ2,CSR_WRITE,INT_TAKEN, FUNC3);
input CLK, INT, RST;
input[6:0] CU_OPCODE;
input [2:0] FUNC3;//unsure of this one
output logic PC_WRITE, REG_WRITE, MEM_WRITE, MEM_READ1, MEM_READ2,CSR_WRITE,INT_TAKEN;

 typedef enum logic [6:0] {
    LUI = 7'b0110111,
    AUIPC = 7'b0010111,
    JAL = 7'b1101111,
    JALR = 7'b1100111,
    BRANCH = 7'b1100011,
    LOAD = 7'b0000011,
    STORE = 7'b0100011,
    OP_IMM = 7'b0010011,
    OP = 7'b0110011,
    SYSTEM = 7'b1110011
    } opcode_t;
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(CU_OPCODE);
    
typedef enum logic[1:0] {FTCH,EXE,WB,INTR} state;
state PS, NS;
state INT_t;


always_ff @ (posedge CLK)
begin
PS <= RST ? FTCH : NS;
end

always_comb
begin
PC_WRITE= 0;
REG_WRITE = 0;
MEM_WRITE= 0;
MEM_READ1 = 0; 
MEM_READ2 = 0;
CSR_WRITE = 0;
INT_TAKEN = 0;

case(PS)
    FTCH:
    begin
        NS = EXE;
        MEM_READ1 = 1;
    end
    EXE:
    begin
    
        MEM_READ1 = 0;
        MEM_READ2 = (OPCODE == LOAD) ? 1:0;
        MEM_WRITE = (OPCODE == STORE) ? 1:0;
        PC_WRITE = 0;
        REG_WRITE = 0;
        NS =  FTCH;
        
        
        case(OPCODE)
            LUI, AUIPC, JAL, JALR,OP_IMM, OP:
            begin
                PC_WRITE = 1;
                REG_WRITE = 1;
            end
            BRANCH,STORE:
            begin
                PC_WRITE = 1;
                REG_WRITE = 0;
            end
            LOAD:
            begin
                NS = WB;
                if(INT== 1) NS = INTR;
                PC_WRITE = 0;
                REG_WRITE = 0;
            end
            SYSTEM:
            begin
                PC_WRITE = 1;
                CSR_WRITE = (FUNC3 == 1) ? 1:0;
                REG_WRITE = (FUNC3 == 1) ? 1:0;
            end
            default: 
            begin
                PC_WRITE = 0;
                REG_WRITE = 0;
                $display("FSM ERROR, default state reached for execute state");
            end
    endcase
        if(INT==1) NS = INTR;
    end
    WB:
    begin
    
        NS = FTCH;
        if(INT == 1) NS = INTR;
        
        PC_WRITE = 1;
        REG_WRITE = 1;
        MEM_READ1 = 0;
    end
    INTR:
    begin
        NS = FTCH;
        PC_WRITE= 1;
        REG_WRITE = 0;
        MEM_WRITE= 0;
        MEM_READ1 = 0; 
        MEM_READ2 = 0;
        CSR_WRITE = 0;
        INT_TAKEN = 1;
    end
    default:
    begin
    NS = FTCH;
    $display("FSM ERROR, default state reached for main case opcode:" );
   
    end
endcase
end
 
    
endmodule




