`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/08/2019 12:49:17 PM
// Design Name:
// Module Name: OTTER_MCU
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

module OTTER_MCU(
    CLK,RST,INT, IOBUS_IN, IOBUS_OUT, IOBUS_ADDR,IOBUS_WR
);
    input CLK,RST,INT;
    input [31:0] IOBUS_IN;
    output [31:0] IOBUS_OUT, IOBUS_ADDR;
    output IOBUS_WR;

    // Temporary variables
    logic [31:0] decode_i, decode_pc, execute_i, execute_pc, memory_i, memory_pc,
    wb_i, wb_pc, pc_wait_out, rf_wr_out, jalr, branch, jump, mtvec, mepc, pc_mux_out, pc_out,
    pc_4, ir, dout2, mem_data_after, mem_addr_after, rf_mux_out, rs1, rs2, i_type,
    s_type, b_type, u_type, j_type, rs1_mux_out, rs2_mux_out, md1_out, reg_A_out,
    md2_out, reg_B_out, alu_out, alu_reg_out, wb_reg_out,csr_reg,hzdOut, hzd1_out, hzd2_out,jalr_wait,wb_pc_4;
    logic pc_write, csrWrite, mie, memRead2, mem_we_after, mem_sign, regWrite, br_eq,
    br_lt, br_ltu, alu_srcA, clear,  reg_en;
    logic [1:0] mem_size, rf_wr_sel, alu_srcB;
    logic [2:0] pc_src;
    logic [3:0] alu_func;
    logic [4:0] wa;


    //Register jalrReg(.clk(CLK),.en(1),.din(jalr),.dout(jalr_wait),.rst(RST),.setnull(0));
    mux8_3 pc_mux(
        .ZERO(pc_4),
        .ONE(jump),
        .TWO(branch),
        .THREE(jalr),
        .FOUR(mtvec),
        .FIVE(mepc),
        .SEL(pc_src),
        .MUXOUT(pc_mux_out));

    PC OTTER_PC(
        .D_IN(pc_mux_out),
        .PC_WRITE(pc_write),
        .RST(RST),
        .CLK(CLK),
        .D_OUT(pc_out));
    assign pc_4 = pc_out + 4;

    Register DECODE_IR(.clk(CLK),.en(1'b1),.din(ir),.dout(decode_i),.rst(RST),.setnull(clear));
    Register DECODE_PC(.clk(CLK),.en(1'b1),.din(pc_wait_out),.dout(decode_pc),.rst(RST),.setnull(clear));

    Decode_Decoder DEC_DECODER(
        .DEC_IR(decode_i),
        .BR_EQ(br_eq),
        .BR_LTU(br_ltu),
        .BR_LT(br_lt),
        .ALU_SRCB(alu_srcB),
        .ALU_SRCA(alu_srcA),
        .PC_SOURCE(pc_src),
        .CLEAR(clear)
    );

    DataResolution data_resolution(
        .hzd_in(hzd2_out),
        .decodeIR_out(decode_i),
        .executeIR_out(execute_i),
        .reg_en(reg_en),
        .pc_write(pc_write),
        .hzd_out(hzdOut)
    );
    

    Register HZD1(
        .clk(CLK),
        .en(1),
        .din(hzdOut),
        .dout(hzd1_out),
        .rst(0),
        .setnull(0)
    );

    Register HZD2(
        .clk(CLK),
        .en(1),
        .din(hzd1_out),
        .dout(hzd2_out),
        .rst(0),
        .setnull(0)
    );

    Register EXECUTE_IR(.clk(CLK),.en(reg_en),.din(decode_i),.dout(execute_i),.rst(RST),.setnull(clear));
    Register EXECUTE_PC(.clk(CLK),.en(reg_en),.din(decode_pc),.dout(execute_pc),.rst(RST),.setnull(clear));

    Execute_Decoder EXE_DECODER(
        .EXE_IR(execute_i),
        .ALU_FUNC(alu_func)
    );

    Register MEMORY_IR(.clk(CLK),.en(1),.din(execute_i),.dout(memory_i),.rst(RST),.setnull());
    Register MEMORY_PC(.clk(CLK),.en(1),.din(execute_pc),.dout(memory_pc),.rst(RST),.setnull());

    Memory_Decoder MEM_DECODER(
        .MEM_IR(memory_i),
        .MEM_READ2(memRead2),
        .MEM_WRITE2(memWrite),
        .MEM_SIGN(mem_sign),
        .MEM_SIZE(mem_size)
    );

    Register WB_IR(.clk(CLK),.en(1),.din(memory_i),.dout(wb_i),.rst(RST),.setnull());
    Register WB_PC(.clk(CLK),.en(1),.din(memory_pc),.dout(wb_pc),.rst(RST),.setnull());

    Writeback_Decoder WB_DECODER(
        .WB_IR(wb_i),
        .CSR_WRITE(csrWrite),
        .REG_WR_EN(regWrite),
        .RF_WR_SEL(rf_wr_sel),
        .WB_WA(wa)
    );
    assign wb_pc_4 = wb_pc + 4;

    Register PC_WAIT(.clk(CLK),.en(1),.din(pc_out),.dout(pc_wait_out),.rst(RST),.setnull(0));

    CSR csr_intr(
        .CLK(CLK),
        .RST(rst_new),
        .INT_TAKEN(intTaken),
        .ADDR(ir[31:20]),
        .PC(pc_out),
        .WD(wb_reg_out),
        .WR_EN(csrWrite),
        .RD(csr_reg),
        .CSR_MEPC(mepc), //return ADDRess after handling trap-interrupt
        .CSR_MTVEC(mtvec),  //trap handler ADDRess
        .CSR_MIE(mie) //interrupt enable register
    );

    OTTER_mem_byte OTTER_MEMORY(
        .MEM_CLK(CLK),
        .MEM_ADDR1(pc_out),
        .MEM_READ1(1'b1),
        .MEM_DOUT1(ir),
        .MEM_DOUT2(dout2),
        .MEM_DIN2(md2_out),
        .MEM_ADDR2(alu_reg_out),
        .MEM_SIZE(mem_size),
        .MEM_READ2(memRead2),
        .MEM_WRITE2(memWrite),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_SIGN(mem_sign)
    );

    mux4_1 rf_wr_mux(
        .ZERO(wb_pc_4),
        .ONE(csr_reg),
        .TWO(dout2),
        .THREE(wb_reg_out),
        .SEL(rf_wr_sel),
        .MUXOUT(rf_wr_out)
    );

    RegisterFile32x32 GPRs(
        .CLK(CLK),
        .EN(regWrite),
        .WD(rf_wr_out),
        .ADR1(ir[19:15]),
        .ADR2(ir[24:20]),
        .WA(wa),
        .RS1(rs1),
        .RS2(rs2)
    );

    CondGen condition_generator(
        .RS1(rs1),
        .RS2(rs2),
        .BR_EQ(br_eq),
        .BR_LT(br_lt),
        .BR_LTU(br_ltu)
    );

    ImmGen immediate_generator(
        .IR(decode_i),
        .I(i_type),
        .S(s_type),
        .B(b_type),
        .U(u_type),
        .J(j_type));

    mux2_1 rs1Mux(
        .ZERO(rs1),
        .ONE(u_type),
        .SEL(alu_srcA),
        .MUXOUT(rs1_mux_out));

    mux4_1 rs2Mux(
        .ZERO(rs2),
        .ONE(i_type),
        .TWO(s_type),
        .THREE(decode_pc),
        .SEL(alu_srcB),
        .MUXOUT(rs2_mux_out));

    Register registerA(
        .din(rs1_mux_out),
        .en(reg_en),
        .clk(CLK),
        .rst(0),
        .dout(reg_A_out)
    );

    Register registerB(
        .din(rs2_mux_out),
        .en(reg_en),
        .clk(CLK),
        .rst(0),
        .dout(reg_B_out)
    );

    Register MD1(
        .din(rs2),
        .en(reg_en),
        .clk(CLK),
        .rst(0),
        .dout(md1_out)
    );

    Register MD2(
        .din(md1_out),
        .en(1),
        .clk(CLK),
        .rst(0),
        .dout(md2_out)
    );
    ALU alu_main(
        .A(reg_A_out),
        .B(reg_B_out),
        .ALU_FUN(alu_func),
        .ALU_OUT(alu_out)
    );

    Register alu_reg(
        .din(alu_out),
        .en(1),
        .clk(CLK),
        .rst(0),
        .dout(alu_reg_out)
    );

    Register wb_reg(
        .din(alu_reg_out),
        .en(1),
        .clk(CLK),
        .rst(0),
        .dout(wb_reg_out) 
        
    );
    assign IOBUS_OUT = rs2;
    assign IOBUS_ADDR = alu_out;
    TarGen tar_gen_main (.RS1(rs1),.I_TYPE(i_type),.B_TYPE(b_type),.J_TYPE(j_type),.PC_OUT(decode_pc),.JALR(jalr),.BRANCH(branch),.JUMP(jump));
    
endmodule





//module OTTER_MCU_old(
//CLK,RST,INT, IOBUS_IN, IOBUS_OUT, IOBUS_ADDR,IOBUS_WR,RX,TX
//    );
//    input CLK,RST,INT;
//    input [31:0] IOBUS_IN;
//    input RX;
//    output TX;
//    output [31:0] IOBUS_OUT, IOBUS_ADDR;
//    output IOBUS_WR;
//    logic [31:0] jalr, branch, jump, pc_4, d_in, pc_out,ir,
//    csr_reg,dout2,wd,rs1,rs2, alu_a, alu_b, utype, itype,stype,jtype,
//    btype, alu_out,mepc,mtvec,
//    prog_ram_addr,prog_ram_data, mem_data_after,mem_size,mem_addr_after;
//    logic [3:0] alu_fun;
//    logic [1:0] rf_wr_sel, alu_srcB;
//    logic [2:0] pcSource;
//    logic pc_write, regWrite, alu_srcA,br_eq,br_lt,br_ltu,memRead1,
//     memRead2,memWrite,intTaken,csrWrite, interrupt,mie,
//     rst_new,prog_rst,prg_we, mem_we_after;

//    or or1(rst_new, RST,prog_rst);
//    //assign rst_new = RST | prog_rst;
//    assign mem_we_after = memWrite | prg_we;

//    //everything below this line is pipelining additions
//    logic [31:0] decodeIRout,executeIRout, executeRS1out,executeRS2out,executeMD2out,memoryIRout,memoryALU_OUTout,memoryMD2out,wa;

//    OTTER_mem_byte mem_main(
//    .MEM_CLK(CLK),
//    .MEM_ADDR1(pc_out),
//    .MEM_READ1(memRead1),
//    .MEM_DOUT1(ir),
//    .MEM_DOUT2(dout2),
//    .MEM_DIN2(mem_data_after),
//    .MEM_ADDR2(mem_addr_after),
//    .MEM_SIZE(mem_size),
//    .MEM_READ2(memRead2),
//    .MEM_WRITE2(mem_we_after),
//    .IO_IN(IOBUS_IN),
//    .IO_WR(IOBUS_WR),
//    .MEM_SIGN(ir[14])

//    ); //should be done
//    //OTTER_mem_byte(MEM_CLK,MEM_ADDR1,MEM_ADDR2,MEM_DIN2,MEM_WRITE2,MEM_READ1,MEM_READ2,ERR,MEM_DOUT1,MEM_DOUT2,IO_IN,IO_WR,MEM_SIZE,MEM_SIGN);

////    Register decodeIR(.clk(CLK),.enable(decodeIRen),.rst(),.din(ir),.dout(decodeIRout));

////    Register executeIR(.clk(CLK),.enable(executeIRen),.rst(),.din(decodeIRout),.dout(executeIRout));

////    Register executeRS1(.clk(CLK),.enable(executeRS1en),.rst(),.din(rs1),.dout(executeRS1out));

////    Register executeRS2(.clk(CLK),.enable(executeRS2en),.rst(),.din(rs2),.dout(executeRS2out));

////    Register executeMD2(.clk(CLK),.enable(executeMemoryData2en),.rst(),.din(rs2),.dout(executeMD2out));

////    Register memoryIR(.clk(CLK),.enable(memoryIRen),.rst(),.din(executeIRout),.dout(memoryIRout));

////    Register memoryALU_OUT(.clk(CLK),.enable(memoryALU_OUTen),.rst(),.din(alu_out),.dout(memoryALU_OUTout));

////    Register memoryMD2(.clk(CLK),.enable(memoryMemoryData2en),.rst(),.din(executeMD2out),.dout(memoryMD2out));

////    Register writebackIR(.clk(CLK),.enable(writebackIRen),.rst(),.din(memoryIRout),.dout(wa));

////    Register writebackData(.clk(CLK),.enable(writebackDataen),.rst(),.din((wbsel)?dout2:memoryALU_OUTout),.dout(wd));




//    ALU alu_main(.A(alu_a),.B(alu_b),.ALU_FUN(alu_fun),.ALU_OUT(alu_out));

//    CondGen gen_decoder(.RS1(rs1),.RS2(rs2),.BR_EQ(br_eq),.BR_LT(br_lt),.BR_LTU(br_ltu));// done

//    CUDecoder cudecoder_main(.BR_EQ(br_eq),.BR_LT(br_lt),.BR_LTU(br_ltu),.FUNC3(ir[14:12]),.FUNC7(ir[31:25]),.CU_OPCODE(ir[6:0]),.ALU_FUN(alu_fun),.ALU_SRCA(alu_srcA),.ALU_SRCB(alu_srcB),.PC_SOURCE(pcSource),.RF_WR_SEL(rf_wr_sel),.INT_TAKEN(intTaken));//BR_EQ, BR_LT,BR_LTU, FUNC3, FUNC7, CU_OPCODE,ALU_FUN, ALU_SRCA, ALU_SRCB, PC_SOURCE, RF_WR_SEL

//    PC pc_main(.CLK(CLK),.RST(rst_new),.D_IN(d_in),.D_OUT(pc_out),.PC_WRITE(pc_write)); //done

//    RegisterFile32x32 rf_main(.CLK(CLK),.ADR1(ir[19:15]),.ADR2(ir[24:20]),.WA(ir[11:7]),.EN(regWrite),.WD(wd),.RS1(rs1),.RS2(rs2));//done

//    mux2_1 alu_mux_2(.SEL(alu_srcA),.ZERO(rs1),.ONE(utype),.MUXOUT(alu_a));//done

//    mux2_1 din1_mux_2(.SEL(prg_we),.ZERO(rs2),.ONE(prog_ram_data),.MUXOUT(mem_data_after));

//    mux2_1 addr2_mux_2(.SEL(prg_we),.ZERO(alu_out),.ONE(prog_ram_addr),.MUXOUT(mem_addr_after));

//    mux2_1 size_mux_2(.SEL(prg_we),.ZERO(ir[13:12]),.ONE(2'b10),.MUXOUT(mem_size));

//    mux4_1 alu_mux_4(.SEL(alu_srcB),.ZERO(rs2),.ONE(itype),.TWO(stype),.THREE(pc_out),.MUXOUT(alu_b)); //done

//    mux4_1 reg_mux_4(.SEL(rf_wr_sel),.ZERO(pc_4),.ONE(csr_reg),.TWO(dout2),.THREE(alu_out),.MUXOUT(wd)); //done

//    mux8_3 pc_mux_8 (.ZERO(pc_4),.ONE(jalr),.TWO(branch),.THREE(jump),.FOUR(mtvec),.FIVE(mepc),.SEL(pcSource),.MUXOUT(d_in)); //done

//    ImmGen imm_gen_main (.IR(ir),.I(itype),.S(stype),.B(btype),.U(utype),.J(jtype));

//    TarGen tar_gen_main (.RS1(rs1),.I_TYPE(itype),.B_TYPE(btype),.J_TYPE(jtype),.PC_OUT(pc_out),.JALR(jalr),.BRANCH(branch),.JUMP(jump));

//    CU_FSM fsm_main(.CLK(CLK),.RST(rst_new),.INT(interrupt),.CSR_WRITE(csrWrite),.CU_OPCODE(ir[6:0]),.FUNC3(ir[14:12]),.PC_WRITE(pc_write),.REG_WRITE(regWrite),.MEM_WRITE(memWrite),.MEM_READ1(memRead1),.MEM_READ2(memRead2),.INT_TAKEN(intTaken));//CLK,INT, RST, CU_OPCODE,PC_WRITE,REG_WRITE,MEM_WRITE,MEM_READ1,MEM_READ2

//    CSR csr_intr  (.CLK(CLK), .RST(rst_new),.INT_TAKEN(intTaken),.ADDR(ir[31:20]), .PC(pc_out),.WD(alu_out),.WR_EN(csrWrite),.RD(csr_reg),.CSR_MEPC(mepc), //return ADDRess after handling trap-interrupt
//            .CSR_MTVEC(mtvec),  //trap handler ADDRess
//           .CSR_MIE(mie) //interrupt enable register
//    );

//    programmer #(.CLK_RATE(50), .BAUD(115200), .IB_TIMEOUT(200),
//    .WAIT_TIMEOUT(500))
//    programmer(.clk(CLK), .rst(RST), .srx(RX), .stx(TX),
//    .mcu_reset(prog_rst), .ram_addr(prog_ram_addr),
//    .ram_data(prog_ram_data), .ram_we(prg_we));

//    assign pc_4 = pc_out + 4;
//    assign IOBUS_ADDR = mem_addr_after;
//    assign IOBUS_OUT = mem_data_after;
//    assign interrupt = mie & INT;

//endmodule


module ImmGen(IR,I,S,B,U,J);
    input [31:0] IR;
    output [31:0] I, S, B, U, J;
    assign I = {{21{IR[31]}},IR[30:20]};
    //shoulc all be correct bit widths
    assign S = {{21{IR[31]}},IR[30:25],IR[11:7]};
    //b is correct
    assign B = {{20 {IR[31]}},IR[7],IR[30:25],IR[11:8],1'b0};
    //U-type shoud now be correct.
    assign U = {IR[31],IR[30:20],IR[19:12],{12{1'b0}}};
    //J us right bit width
    assign J = {{12{IR[31]}},IR[19:12],IR[20],IR[30:25],IR[24:21],1'b0};


endmodule

module TarGen(RS1,I_TYPE,B_TYPE,J_TYPE,PC_OUT,JALR,BRANCH,JUMP);
input[31:0] RS1, I_TYPE,B_TYPE,J_TYPE,PC_OUT;
output logic [31:0] JALR, BRANCH, JUMP;
assign BRANCH = PC_OUT + B_TYPE;
assign JALR = RS1 + I_TYPE;
assign JUMP = PC_OUT + J_TYPE;
endmodule

module CondGen(RS1,RS2,BR_LT,BR_LTU, BR_EQ);
    input [31:0] RS1,RS2;
    output logic BR_LT,BR_LTU,BR_EQ;
    always_comb
    begin
    BR_EQ = (RS1 == RS2) ? 1:0;
    BR_LT = ($signed(RS1) < $signed(RS2)) ? 1:0;
    BR_LTU = (RS1 < RS2) ? 1 : 0;
    end


endmodule

