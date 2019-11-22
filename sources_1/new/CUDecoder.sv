module CUDecoder(WB_IR, WB_IR_EN, MEM_IR, MEM_IR_EN, EXE_IR, EXE_IR_EN, DEC_IR, DEC_IR_EN, BR_LT, BR_EQ, BR_LTU, ALU_FUNC, ALU_SRCA, ALU_SRCB, PCSOURCE, RF_WR_SEL);
    input [31:0] WB_IR, MEM_IR, EXE_IR, DEC_IR;
    input BR_LT, BR_EQ, BR_LTU;
    output logic [3:0] ALU_FUNC;
    output logic ALU_SRCA, REG_WR_EN, CSR_REG_EN, MEM_READ1, MEM_READ2, MEM_SIGN;
    output logic NO_OP;
    output logic [1:0] ALU_SRCB, RF_WR_SEL, MEM_SIZE;
    output logic [2:0] PC_SOURCE;

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
    opcode_t EXEC_OPCODE;

    assign DEC_OPCODE = opcode_t'(DEC_IR[6:0]);
    assign EXEC_OPCODE = opcode_t'(EXE_IR[6:0]);
    assign MEM_OPCODE = opcode_t'(MEM_IR[6:0]);
    assign WB_OPCODE = opcode_t'(WB_IR[6:0]);

    typedef enum logic [2:0] {
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
    } func3_t;
    func3_t func3_exe;

    assign func3_exe = func3_t'(EXE_IR[14:12]);
    assign func3_wb = func3_t'(WB_IR[14:12]);

    assign func7 = EXE_IR[31:25];

    always_comb
    begin

      PC_SOURCE = 0; // PC SIGNAL

      NO_OP = 0; // IR REGISTER SIGNAL
      
      MEM_READ1 = 1; // FETCH STAGE SIGNAL

      REG_WR_EN = 0; CSR_REG_EN = 0; RF_WR_EN = 0; ALU_SRCA = 0; ALU_SRCB = 0; // DECODE STAGE SIGNALS

      ALU_FUNC = 0; // EXECUTE STAGE SIGNAL

      MEM_READ2 = (MEM_OPCODE == LOAD) ? 1:0; MEM_WRITE2 = (MEM_OPCODE == STORE) ? 1:0; MEM_SIGN = MEM_IR[14]; MEM_SIZE = MEM_IR[13:12]; // MEMORY STAGE SIGNALS

      case (DEC_OPCODE) // Handles ALU_SRCA | ALU_SRCB
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
        default:
          begin
            ALU_SRCA = 0; ALU_SRCB = 0;
          end
      endcase

      case (EXEC_OPCODE) // HANDLES PC_SOURCE | ALU_FUNC
        LUI:
          begin
            ALU_FUNC = 9;
          end

        JAL:
          begin
            PC_SOURCE = 3;
          end
        JALR:
          begin
            PC_SOURCE = 1;
          end
        BRANCH:
          case(func3_exe)
            BEQ:
              begin
                PC_SOURCE = (BR_EQ == 1) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            BNE:
              begin
                PC_SOURCE = (BR_EQ == 0) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            BLT:
              begin
                PC_SOURCE = (BR_LT == 1) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            BGE:
              begin
                PC_SOURCE = (BR_LT == 0) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            BLTU:
              begin
                PC_SOURCE = (BR_LTU == 1) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            BGEU:
              begin
                PC_SOURCE = (BR_LTU == 0) ? 2 : 0;
                NO_OP = (PC_SOURCE == 2) ? 1 : 0;
              end
            default:
              begin
                PC_SOURCE = 0; NO_OP = 0;
              end
          endcase
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
              PC_SOURCE = (func3_exe == 0) ? 5 : 0;
          end
        default:
          begin
            PC_SOURCE = 0; ALU_FUNC = 0;
          end
      endcase

      PC_SOURCE = (INT_TAKEN) ? 4:PC_SOURCE; // Haven't determined how to handle intTaken


      case (WB_OPCODE) // HANDLES REG_WR_EN | CSR_REG_EN
        LUI, AUIPC, JAL, JALR, OP_IMM, OP, LOAD:
          begin
              REG_WR_EN = 1;
          end
        SYSTEM:
          begin
            REG_WR_EN = (func3_wb == 1) ? 1:0;
            CSR_REG_EN = 1;
          end
        default:
          REG_WR_EN = 0; CSR_REG_EN = 0;
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
