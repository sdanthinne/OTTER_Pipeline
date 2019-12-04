// Handles data hazards when a subsequent instruction uses register contents that
// need to be updated in a previous instruction

module DataResolution(
  input [31:0] hzd_in,
  input [31:0] decodeIR_out,
  input [31:0] executeIR_out,
  output logic reg_en=1, pc_write=1,
  output logic [31:0] hzd_out=0,
  output logic clear=0,
  output logic hzd_delay_rst = 0
);

// decodeIR_out is the output of the decode register
// executeIR_out is the output of the execute register
// decodeIR_en is the enable bit for the decode register
// executeIR_en is the enable bit for the execute register
logic hzd_taken = 0;
logic [4:0] rd_exec,rs1_dec,rs2_dec;
assign rd_exec  =  executeIR_out[11:7];
assign rs1_dec = decodeIR_out[19:15];
assign rs2_dec = decodeIR_out[24:20];


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
logic hit_if = 0;
opcode_t decode_opcode,execute_opcode;
assign decode_opcode = opcode_t'(decodeIR_out[6:0]);
assign execute_opcode = opcode_t'(executeIR_out[6:0]);

//decodeIR_out[2:0] != 3'b111  || (decodeIR_out[6:0] == 6'b1100111)
  always_comb
  begin
    if (execute_opcode != BRANCH && execute_opcode != STORE) // opcodes with rd
      begin

        if ((decode_opcode == BRANCH || decode_opcode == STORE || decode_opcode == OP)
            && rd_exec == rs2_dec) // opcodes with rs2; checks if rs2 = rd
          begin

            reg_en = 0; clear = 1; pc_write = 0; hzd_out = 1; hzd_taken = 1; // halt the flow of data from new instructions
          end
        else if (decode_opcode != AUIPC && decode_opcode != JAL && decode_opcode != LUI && rs1_dec == rd_exec) // opcodes with rs1; checks if rs1 = rd
          begin
            hit_if = 1;
            reg_en = 0; clear = 1; pc_write = 0; hzd_out = 1; hzd_taken = 1; // halt the flow of data from new instructions
          end
        else
        begin
          hit_if = 0;
        end
      end


      if (hzd_in == 1)
      begin
        reg_en = 1; pc_write = 1; hzd_out = 0; hzd_delay_rst = 1;
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
//decodeIR_out,executeIR_out,clk,reg_en,clear,pc_write

module DataResolution_mod(
input [31:0] decodeIR_out,
input [31:0] executeIR_out,
input clk,
output logic reg_en=1,pc_write=1,clear=0);


logic [1:0] counter = 0;
logic hzd = 0;
logic [4:0] rd_exec,rs1_dec,rs2_dec;
assign rd_exec  =  executeIR_out[11:7];
assign rs1_dec = decodeIR_out[19:15];
assign rs2_dec = decodeIR_out[24:20];

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
opcode_t decode_opcode,execute_opcode;
assign decode_opcode = opcode_t'(decodeIR_out[6:0]);
assign execute_opcode = opcode_t'(executeIR_out[6:0]);

always_ff @(posedge clk)
begin
  if (hzd)
    begin
      counter = counter + 1;
    end
end
always_comb
begin
  if (execute_opcode != BRANCH && execute_opcode != STORE && decode_opcode != 0) // opcodes with rd
    begin

      if ((decode_opcode == BRANCH || decode_opcode == STORE || decode_opcode == OP)
          && rd_exec == rs2_dec) // opcodes with rs2; checks if rs2 = rd
        begin

          reg_en = 0; clear = 1; pc_write = 0; hzd = 1; // halt the flow of data from new instructions
        end
      else if (decode_opcode != AUIPC && decode_opcode != JAL && decode_opcode != LUI && rs1_dec == rd_exec) // opcodes with rs1; checks if rs1 = rd
        begin
          reg_en = 0; clear = 1; pc_write = 0; hzd = 1; // halt the flow of data from new instructions
        end

    end


    if (counter == 3)
    begin
      reg_en = 1; pc_write = 1;
      clear = 0; hzd = 0; counter = 0;
    end
    else if(hzd == 1)
    begin
      reg_en = 0;
      pc_write = 0;
      clear = 1;

    end

  end
endmodule
