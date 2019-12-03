// Handles data hazards when a subsequent instruction uses register contents that
// need to be updated in a previous instruction

module DataResolution(
  input [31:0] hzd_in,
  input [31:0] decodeIR_out,
  input [31:0] executeIR_out,
  output logic reg_en=1, pc_write=1,
  output logic [31:0] hzd_out=0,
  output logic clear=0
);

// decodeIR_out is the output of the decode register
// executeIR_out is the output of the execute register
// decodeIR_en is the enable bit for the decode register
// executeIR_en is the enable bit for the execute register
logic hzd_taken = 0;
  always_comb
  begin
  
    if (executeIR_out[6:0] != 7'b1100011 && executeIR_out[6:0] != 7'b0100011) // opcodes with rd
      begin
        if ((decodeIR_out[6:0] == 7'b1100011 || decodeIR_out[6:0] == 7'b0100011
            || decodeIR_out[6:0] == 7'b0110011) && executeIR_out[11:7] == decodeIR_out[24:20]) // opcodes with rs2; checks if rs2 = rd
          begin
            reg_en = 0; clear = 1; pc_write = 0; hzd_out = 1; hzd_taken = 1; // halt the flow of data from new instructions
          end
        else if (decodeIR_out[2:0] != 3'b111 && decodeIR_out[19:15] == executeIR_out[11:7]) // opcodes with rs1; checks if rs1 = rd
          begin
            reg_en = 0; clear = 1; pc_write = 0; hzd_out = 1; hzd_taken = 1; // halt the flow of data from new instructions
          end
      end
      if (hzd_in == 1) 
      begin
        reg_en = 1; pc_write = 1; hzd_out = 0;
        hzd_taken = 0;
        clear = 0;
      end
      else if(hzd_taken == 1)
      begin
        reg_en = 0;
        pc_write = 0;
        clear = 1;

        //hzd_out = 0;
        //hzd_taken = 1;
      end
  end
endmodule

module DataResolution_mod(decodeIR_out,executeIR_out,clk,decodeIR_en,executeIR_en,pc_write);
input [31:0] decodeIR_out;
input [31:0] executeIR_out;
input clk;
output logic decodeIR_en, executeIR_en,pc_write;


endmodule
