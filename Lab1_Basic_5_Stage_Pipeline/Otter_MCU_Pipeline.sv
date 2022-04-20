`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU
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

module OTTER_MCU_Pipeline(input CLK,
                input INTR,
                input RST,
                input [31:0] IOBUS_IN,
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output logic IOBUS_WR 
);

  typedef enum logic [6:0] {
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011
 } opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
} instr_t;

    wire [6:0] opcode;
    
    //wire [31:0] pc, pc_value, next_pc, jalr_pc, branch_pc, jump_pc, 
    wire [31:0] int_pc;
    //wire [31:0] A,B, /*alu_srcA, alu_srcB instead of A and B*/
    //wire [31:0] I_immed,S_immed,U_immed,alu_B,alu_A,aluResult,
    //wire [31:0] rfIn,
    
    wire [31:0] csr_reg; //mem_data;
    
    //wire [31:0] IR;
    //wire memRead1,
    //wire memRead2;
    
    //wire pcWrite,
    //wire regWrite,memWrite, 
    wire op1_sel,mem_op,IorD,pcWriteCond,memRead;
    //wire [1:0] opB_sel, rf_sel, wb_sel, 
    wire [1:0] mSize;
    logic [1:0] pc_sel;
    //wire [3:0]alu_fun;
    //wire opA_sel;
    
    //logic br_lt,br_eq,br_ltu;
//==============================================================
    //For Fetch 
    //PC  
    logic [31:0] pc_value, pc, next_pc; //in, out, pc+4
    logic [31:0] jalr_pc, branch_pc, jump_pc; //int_pc?
    logic pcWrite;
    logic [1:0] pc_source;
    logic memRead1;
    
    
    
//==== Instruction Fetch ===========================================

     logic [31:0] if_de_pc;
     
     //PC Module 
     MUX4_1 PC_MUX(.zero(next_pc), .one(jalr_pc), .two(branch_pc), .three(jump_pc), .SEL(pc_source), .out(pc_value));
     //PC
     PC PC(.CLK(CLK), .Din(pc_value), .pcWrite(pcWrite), .reset(RST), .PC_COUNT(pc));
     
     assign next_pc = pc + 4;
     assign pcWrite = 1'b1; 	//Hardwired high, assuming no hazards
     assign memRead1 = 1'b1; 	//Fetch new instruction every cycle
     
     always_ff @(posedge CLK) 
        begin
                if_de_pc <= pc;
        end

//==== Fetch End ===================================================    
    
    
//==== Instruction Decode ===========================================
    logic [31:0] IR;
    //ALU MUX A
    logic alu_srcA;
    //ALU MUX B
    logic [1:0] alu_srcB; 
    logic [31:0] I_immed,S_immed,U_immed, J_Immed, B_Immed;       
    //Decoder
    logic [1:0] wb_sel;
    logic memRead2, regWrite, memWrite;
    //RegFile
    logic [31:0] rs1, rs2; //Register File output A,B
    logic [31:0] rfIn;
    //ALU
    logic [31:0] alu_A, alu_B, alu_out; //addr2   
    logic [3:0] alu_fun;

    logic [31:0] de_ex_opA; //Output from ALU MUXA sent to Execute State 
    logic [31:0] de_ex_opB; //Output from ALU MUXB sent to Execute State
    logic [31:0] de_ex_rs2;
    logic [2:0] de_ex_func3;
    logic [31:0] de_ex_Itype, de_ex_Jtype, de_ex_Btype;
    

    instr_t de_ex_inst, de_inst;
    
    opcode_t OPCODE;
    assign opcode = IR[6:0];
    assign OPCODE = opcode_t'(opcode);
    
    assign de_inst.rs1_addr=IR[19:15];
    assign de_inst.rs2_addr=IR[24:20];
    assign de_inst.rd_addr=IR[11:7];
    assign de_inst.opcode=OPCODE;
    assign de_inst.alu_fun = alu_fun;
    assign de_inst.memWrite = (OPCODE == STORE)? 1:0; //enable on store inst only
    assign de_inst.memRead2 = (OPCODE == LOAD)? 1:0; //enable on load
    assign de_inst.regWrite = (OPCODE != BRANCH && OPCODE != STORE)? 1:0; //enable if not Branch or Store 
    assign de_inst.rf_wr_sel = wb_sel;
    assign de_inst.mem_type = IR[14:12];
    assign de_inst.pc = if_de_pc;
    
    assign de_inst.rs1_used=    de_inst.rs1_addr != 0
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
                                
    assign de_inst.rs2_used =   de_inst.rs2_addr != 0  
                                && (de_inst.opcode == BRANCH
                                || de_inst.opcode == STORE
                                || de_inst.opcode == OP);  
                                
    assign de_inst.rd_used =    de_inst.rd_addr != 0
                                && de_inst.opcode != BRANCH
                                && de_inst.opcode != STORE;  
                                                                               
    /******* Modules in DE stage **************/
    //Decoder, Regegister File, ALU Mux A & B,                             
    Decoder CU_Decoder(.CU_OPCODE(IR[6:0]), .FUNC3(IR[14:12]), .FUNC7(IR[31:25]), 
                .ALU_FUN(alu_fun), .ALU_SRCA(alu_srcA), 
                .ALU_SRCB(alu_srcB), .RF_WR_SEL(wb_sel));
                
    RegisterFile RegFile(.CLK(CLK), .WD(rfIn), .R1(de_inst.rs1_addr), .R2(de_inst.rs2_addr), 
                        .WA(mem_wb_inst.rd_addr), .EN(mem_wb_inst.regWrite), .RS1(rs1), .RS2(rs2));
                
    IMMED_GEN IMMED_GEN(.IR(IR), .UType(U_immed), .SType(S_immed), .IType(I_immed), .JType(J_Immed), .BType(B_Immed)); 
                
    //ALU MUX A 
    MUX2_1 ALU_MUXA(.zero(rs1), .one(U_immed), .SEL(alu_srcA), .out(alu_A));
    //ALU MUX B
    MUX4_1 ALU_MUXB(.zero(rs2), .one(I_immed), .two(S_immed), .three(if_de_pc), .SEL(alu_srcB), .out(alu_B));
    /*******************************************/
    
    always_ff @(posedge CLK)
    begin
        de_ex_opA <= alu_A;
        de_ex_opB <= alu_B;
        de_ex_rs2 <= rs2; //ASK ASK ASK
        de_ex_func3 <= IR[14:12];
        de_ex_Itype <= I_immed;
        de_ex_Jtype <= J_Immed;
        de_ex_Btype <= B_Immed;
        de_ex_inst <= de_inst;
    end
//==== Decode End ===================================================	
	
	
//==== Execute ======================================================
	logic br_cond, br_lt, br_eq, br_ltu;
	logic [31:0] aluResult;

     instr_t ex_mem_inst;
     logic [31:0] ex_mem_rs2;
     logic [31:0] ex_mem_aluRes = 0;
     logic [31:0] opA_forwarded;
     logic [31:0] opB_forwarded;
     
     assign ex_func3 = de_ex_func3;
     
     /******* Modules in EX stage **************/
     //Target Gen, Branch CondGen, ALU
     //Target Gen 
     TargetGen Target_Gen(.RS1(de_ex_opA), .IType(de_ex_Itype), 
                .JType(de_ex_Jtype), .BType(de_ex_Btype), .PC_OUT(de_ex_inst.pc),
                .JAL(jump_pc), .JALR(jalr_pc), .BRANCH(branch_pc));
     
     //Branch Cond Gen 
     BranchCondGen BR_COND_GEN(.A(de_ex_opA), .B(de_ex_opB),
                .EQ(br_eq), .LT(br_lt), .LTU(br_ltu));
                
     //Branch logic 
     always_comb
     begin
        case(de_ex_func3)
            3'b000: br_cond = br_eq;    //BEQ 
            3'b001: br_cond = ~br_eq;   //BNE   
            3'b100: br_cond = br_lt;    //BLT 
            3'b101: br_cond = ~br_lt;   //BGE 
            3'b110: br_cond = br_ltu;   //BLTU  
            3'b111: br_cond = ~br_ltu;  //BGEU
            default: br_cond = 0;
        endcase
     end  
     
     //PC Source 
     always_comb
     begin
        case (de_ex_inst.opcode)
            JALR:       pc_source = 3'b001;
            BRANCH:     pc_source = (br_cond) ? 3'b010 : 3'b000;
            JAL:        pc_source = 3'b011;
            SYSTEM:     pc_source = (de_ex_func3==3'b000)? 3'b101:3'b000;
            default:    pc_source = 3'b000;
        endcase
    end
    
     // Creates a RISC-V ALU
    ALU ALU(.ALU_FUNC(de_ex_inst.alu_fun), .A(de_ex_opA), .B(de_ex_opB), .OUT(aluResult)); // the ALU
    /*******************************************/
     
    always_ff @(posedge CLK)
    begin
        ex_mem_aluRes <= aluResult;
        ex_mem_inst <= de_ex_inst;
        ex_mem_rs2 <= de_ex_rs2;
    end
//==== Execute End =================================================


//==== Memory ======================================================
    logic [31:0] mem_data;

    instr_t mem_wb_inst;
    logic [31:0] mem_wb_aluRes; 
    assign IOBUS_ADDR = ex_mem_aluRes;
    assign IOBUS_OUT = ex_mem_rs2;
    
    //Mem Module
    OTTER_mem_byte_new #(14) memory( .MEM_CLK(CLK), .MEM_ADDR1(pc),
            .MEM_ADDR2(ex_mem_aluRes), .MEM_DIN2(IOBUS_OUT),
            .MEM_WRITE2(ex_mem_inst.memWrite), .MEM_READ1(memRead1),
            .MEM_READ2(ex_mem_inst.memRead2), .ERR(), .MEM_DOUT1(IR),
            .MEM_DOUT2(mem_data), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR),
            .MEM_SIZE(ex_mem_inst.mem_type[1:0]), .MEM_SIGN(ex_mem_inst.mem_type[2]));
    
    always_ff @(posedge CLK)
    begin
        mem_wb_inst <= ex_mem_inst;
        mem_wb_aluRes <= ex_mem_aluRes;
    end
 
     
//==== Write Back ==================================================
   logic [31:0] wb_next_pc;
   assign wb_next_pc = mem_wb_inst.pc + 4; 
   
        MUX4_1 REG_WB_MUX(.zero(wb_next_pc), .one(), 
                .two(mem_data), .three(mem_wb_aluRes), 
                .SEL(mem_wb_inst.rf_wr_sel), .out(rfIn));
            
endmodule
