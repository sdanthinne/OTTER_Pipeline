module Decode_Decoder(DEC_IR,BR_EQ,BR_LT,BR_LTU,ALU_SRCA,ALU_SRCB,PC_SOURCE,CLEAR);
    input [31:0] DEC_IR;
    input BR_EQ, BR_LTU,BR_LT;
    output logic [1:0] ALU_SRCB;
    output logic [2:0] PC_SOURCE;
    output logic ALU_SRCA,CLEAR;
   


    typedef enum logic [2:0] {
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
    } func3_t;

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
    
    opcode_t DEC_OPCODE_T;
    assign DEC_OPCODE_T = opcode_t'(DEC_IR[6:0]);
    
    func3_t func3_exe;

    assign func3_exe = func3_t'(DEC_IR[14:12]);

    always_comb
    
    begin
    ALU_SRCA = 0;
    ALU_SRCB = 0;
    PC_SOURCE = 0;
    CLEAR = 0;
    case (DEC_OPCODE_T) // Handles ALU_SRCA | ALU_SRCB | PC_SOURCE | CLEAR
        LUI:
          begin
              ALU_SRCA = 1;
          end
        AUIPC:
          begin
            ALU_SRCA = 1;
            ALU_SRCB = 3;
          end
        OP_IMM, LOAD:
          begin
            ALU_SRCB = 1;
          end
        STORE:
          begin
              ALU_SRCB = 2;
          end
        BRANCH:
        begin
          //evaluates beanch statements in decode to save clock cycles that we need to clear. 
          //Should have split up clear to clear the pc/fetch state and the decode state of the next instruction(s)
          
          case(func3_exe)
            BEQ:
              begin
                PC_SOURCE = (BR_EQ == 1) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            BNE:
              begin
                PC_SOURCE = (BR_EQ == 0) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            BLT:
              begin
                PC_SOURCE = (BR_LT == 1) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            BGE:
              begin
                PC_SOURCE = (BR_LT == 0) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            BLTU:
              begin
                PC_SOURCE = (BR_LTU == 1) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            BGEU:
              begin
                PC_SOURCE = (BR_LTU == 0) ? 2 : 0;
                CLEAR = (PC_SOURCE == 2) ? 1 : 0;
              end
            default:
              begin
                PC_SOURCE = 0; CLEAR = 0;
              end
          endcase
        end
        JALR:
        begin
          PC_SOURCE = 3;
          CLEAR = 1;
        end
        JAL:
        begin
          PC_SOURCE = 1;
          CLEAR = 1;
        end
        SYSTEM:
        begin
          PC_SOURCE = (func3_exe == 0) ? 5 : 0;
        end
        default:
          begin
            ALU_SRCA = 0; ALU_SRCB = 0;
          end
    endcase
    end
endmodule

module Execute_Decoder(EXE_IR,ALU_FUNC);
    //I need to draw out some diagrams 
    input [31:0] EXE_IR;
    
    output logic [3:0] ALU_FUNC;

    
    //not sure if PC_source should be set here or not. 
    

typedef enum logic [2:0] {
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
    } func3_t;
    
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
    opcode_t EXEC_OPCODE_T;
    
    
    func3_t func3_exe;

    assign func3_exe = func3_t'(EXE_IR[14:12]);
    
    logic [6:0] func7;
    
    assign func7 = EXE_IR[31:25];

    assign EXEC_OPCODE_T = opcode_t'(EXE_IR[6:0]);
    always_comb
    begin
    case (EXEC_OPCODE_T) // HANDLES PC_SOURCE | ALU_FUNC
        LUI,JAL,JALR:
          begin
            ALU_FUNC = 9;
          end
        OP_IMM:
          begin
            if(func7 == 32 && func3_exe == 5)
                begin
                  ALU_FUNC = {func7[5], func3_exe};
                end
            else
                begin
                  ALU_FUNC = {1'b0, func3_exe};
                end
          end
        OP:
          begin
            ALU_FUNC = {func7[5], func3_exe};
          end
        SYSTEM:
          begin
              ALU_FUNC = 9;
          end
        default:
          begin
            ALU_FUNC = 0;
          end
      endcase
    end
endmodule

module Memory_Decoder(MEM_IR,MEM_READ2, MEM_WRITE2, MEM_SIGN, MEM_SIZE);
    input [31:0] MEM_IR;
    output logic MEM_READ2,MEM_WRITE2, MEM_SIGN;
    output logic [1:0] MEM_SIZE;

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
    opcode_t MEM_OPCODE;

    assign MEM_OPCODE = opcode_t'(MEM_IR[6:0]);

    assign MEM_READ2 = (MEM_OPCODE == LOAD) ? 1:0; 
    assign MEM_WRITE2 = (MEM_OPCODE == STORE) ? 1:0; 
    assign MEM_SIGN = MEM_IR[14]; 
    assign MEM_SIZE = MEM_IR[13:12]; // MEMORY STAGE SIGNALS
endmodule

module Writeback_Decoder(WB_IR,CSR_WRITE,REG_WR_EN,RF_WR_SEL,WB_WA);
    input [31:0] WB_IR;
    output logic CSR_WRITE, REG_WR_EN;
    output logic [1:0] RF_WR_SEL; 
    output logic [4:0] WB_WA;

    typedef enum logic [2:0] {
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
    } func3_t;
    func3_t func3_wb;

    assign func3_wb = func3_t'(WB_IR[14:12]);
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
    opcode_t WB_OPCODE;
    assign WB_WA = WB_IR[11:7];
    assign WB_OPCODE = opcode_t'(WB_IR[6:0]);
always_comb
begin
CSR_WRITE = 0;
    case (WB_OPCODE) // HANDLES REG_WR_EN | CSR_WRITE
        LUI, AUIPC, JAL, JALR, OP_IMM, OP, LOAD:
          begin
              REG_WR_EN = 1;
          end
        SYSTEM:
          begin
            REG_WR_EN = (func3_wb == 1) ? 1:0;
            CSR_WRITE = 1;
          end
        default:
        begin
          REG_WR_EN = 0; 
          CSR_WRITE = 0;
        end
      endcase

      case (WB_OPCODE) // Handles RF_WR_SEL
        LUI, AUIPC, OP_IMM, OP:
          begin
            RF_WR_SEL = 3;
          end
        LOAD:
          begin
            RF_WR_SEL = 2;
          end
        SYSTEM:
          begin
            RF_WR_SEL = 1;
          end
        default:
          begin
            RF_WR_SEL = 0;
          end
      endcase
  end
    
endmodule

//module CUDecoder_old(WB_IR, WB_IR_EN, MEM_IR, MEM_IR_EN, EXE_IR, EXE_IR_EN, DEC_IR, DEC_IR_EN, BR_LT, BR_EQ, BR_LTU, ALU_FUNC, ALU_SRCA, ALU_SRCB, PCSOURCE, RF_WR_SEL);
//    input [31:0] WB_IR, MEM_IR, EXE_IR, DEC_IR;
//    input BR_LT, BR_EQ, BR_LTU;
//    output logic [3:0] ALU_FUNC;
//    output logic ALU_SRCA, REG_WR_EN, CSR_WRITE, MEM_READ2, MEM_SIGN;
//    output logic CLEAR;
//    output logic [1:0] ALU_SRCB, RF_WR_SEL, MEM_SIZE;
//    output logic [2:0] PC_SOURCE;

//    typedef enum logic [6:0] {
//    LUI = 7'b0110111,
//    AUIPC = 7'b0010111,
//    JAL = 7'b1101111,
//    JALR = 7'b1100111,
//    BRANCH = 7'b1100011,
//    LOAD = 7'b0000011,
//    STORE = 7'b0100011,
//    OP_IMM = 7'b0010011,
//    OP = 7'b0110011,
//    SYSTEM = 7'b1110011
//    } opcode_t;
//    opcode_t EXEC_OPCODE;

   
    
//    //assign WB_OPCODE = opcode_t'(WB_IR[6:0]);

    


//    always_comb
//    begin

//      PC_SOURCE = 0; // PC SIGNAL

//      CLEAR = 0; // IR REGISTER SIGNAL

//      //REG_WR_EN = 0; CSR_WRITE = 0; RF_WR_EN = 0; ALU_SRCA = 0; ALU_SRCB = 0; // DECODE STAGE SIGNALS

//      ALU_FUNC = 0; // EXECUTE STAGE SIGNAL

      

     

      

//      //PC_SOURCE = (INT_TAKEN) ? 4:PC_SOURCE; // Haven't determined how to handle intTaken
//      //int_taken will be set in execute state, and the interrupts will be triggered from then on. 
//      //Value that is stored in the decode state of the last instruction PC value will be stored back into the CSR
      
//    end

      
//endmodule
