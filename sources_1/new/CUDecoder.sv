module CUDecoder(WB_IR,MEM_IR,EXE_IR,DEC_IR,BR_LT,BR_EQ,BR_LTU, ALU_FUNC, ALU_SRCA, ALU_SRCB, PCSOURCE, RF_WR_SEL);
    input [31:0] WB_IR,MEM_IR,EXE_IR,DEC_IR;
    input BR_LT,BR_EQ,BR_LTU;
    output logic [3:0] ALU_FUNC;
    output logic ALU_SRCA,REG_WR_EN,CSR_REG_EN,MEM_READ2;
    output logic [1:0] ALU_SRCB,RF_WR_SEL;
    output logic [2:0] PCSOURCE;
    
   
    // this is for all of the signals associated with the writeback state
    always_comb
    begin
        
    end

    // this is for all of the signals associated with the execute state
    always_comb
    begin
        
    end

    // this is for all of the signals associated with the PC
    always_comb
    begin
        
    end

endmodule