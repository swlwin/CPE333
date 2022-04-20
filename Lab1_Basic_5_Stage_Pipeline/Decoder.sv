`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 01/27/2019 09:22:55 AM
// Design Name: 
// Module Name: CU_Decoder
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
//`include "opcodes.svh"

module Decoder(
    input [6:0] CU_OPCODE,
    input [2:0] FUNC3,
    input [6:0] FUNC7,
    //input intTaken,
    output logic [3:0] ALU_FUN,
    output logic ALU_SRCA,
    output logic [1:0] ALU_SRCB,
    output logic [1:0] RF_WR_SEL   
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
        
        
//        typedef enum logic [2:0] {
//                Func3_CSRRW  = 3'b001,
//                Func3_CSRRS  = 3'b010,
//                Func3_CSRRC  = 3'b011,
//                Func3_CSRRWI = 3'b101,
//                Func3_CSRRSI = 3'b110,
//                Func3_CSRRCI = 3'b111,
//                Func3_PRIV   = 3'b000       //mret
//        } funct3_system_t;

       
        opcode_t OPCODE;
        assign OPCODE = opcode_t'(CU_OPCODE);
        
       //DECODING  (does not depend on state)  ////////////////////////////////////////////
       //SEPERATE DECODER
        always_comb
            case(CU_OPCODE)
                OP_IMM: ALU_FUN= (FUNC3==3'b101)?{FUNC7[5],FUNC3}:{1'b0,FUNC3};
                LUI,SYSTEM: ALU_FUN = 4'b1001;
                OP: ALU_FUN = {FUNC7[5],FUNC3};
                default: ALU_FUN = 4'b0;
            endcase
            
         always_comb
         begin
            //if(state==1 || state==2)
                case(CU_OPCODE)
                    JAL:    RF_WR_SEL=0;
                    JALR:    RF_WR_SEL=0;
                    LOAD:    RF_WR_SEL=2;
                    SYSTEM:  RF_WR_SEL=1;
                    default: RF_WR_SEL=3; 
                endcase
            //else CU_RF_WR_SEL=3;   
          end   
          
          
         always_comb
         begin
         // if(state!=0)
            case(CU_OPCODE)
                STORE:  ALU_SRCB=2;  //S-type
                LOAD:   ALU_SRCB=1;  //I-type
                JAL:    ALU_SRCB=1;  //I-type
                OP_IMM: ALU_SRCB=1;  //I-type
                AUIPC:  ALU_SRCB=3;  // U-type (special) LUI does not use B
                default: ALU_SRCB=0;  //R-type    //OP  BRANCH-does not use
            endcase
          //else CU_ALU_SRCB=3;
         end
           
       assign ALU_SRCA = (CU_OPCODE==LUI || CU_OPCODE==AUIPC) ? 1 : 0;
                
        //assign CU_MSIZE = CU_FUNC3[1:0];        

endmodule 






//===================================================================================

//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Engineer: Sandra Lwin
//// Create Date: 01/30/2022 12:16:55 AM
//// Module Name: CU_Decoder
////////////////////////////////////////////////////////////////////////////////////


//module Decoder(
//    //input BR_EQ, BR_LT, BR_LTU,
//    input [6:0] INPUT_OPCODE, //Opcode 
//    input [2:0] FUNC3, //usually ir[14:12]
//    input [6:0] FUNC7, //ir[31:25]
//    output logic [3:0] ALU_FUNC, 
//    output logic ALU_SRCA, 
//    output logic [1:0] ALU_SRCB, rf_wr_sel // PC_SOURCE, 
//    );
    
//    //Create enumeration datatype for the opcode.
//    typedef enum logic [6:0] {
//        LUI = 7'b0110111,
//        AUIPC = 7'b0010111,
//        JAL = 7'b1101111,
//        JALR = 7'b1100111,
//        BRANCH = 7'b1100011,
//        LOAD = 7'b0000011,
//        STORE = 7'b0100011,
//        OP_IMM = 7'b0010011,
//        OP = 7'b0110011
//        //SYSTEM   = 7'b1110011
//        } opcode_t;
        
//        opcode_t OPCODE;    //Define variable of newly defined type
//        //Cast input bits as enum, for showing opcode names during simulation
//        assign OPCODE = opcode_t'(INPUT_OPCODE);
        
//        always_comb
//        begin
//            //initialize all output 
//            ALU_FUNC = 0; ALU_SRCA = 0; ALU_SRCB = 0; //PC_SOURCE = 0; 
//            rf_wr_sel = 0;
            
//            case(INPUT_OPCODE)
//            LUI:
//                begin 
//                    ALU_FUNC = 9;
//                    ALU_SRCA = 1;  ALU_SRCB = 0;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 3;
//                end
//            AUIPC:
//                begin 
//                    ALU_FUNC = 0;
//                    ALU_SRCA = 1;  ALU_SRCB = 3;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 3;
//                end
//            JAL:
//                begin 
//                    ALU_FUNC = 0;
//                    ALU_SRCA = 0;  ALU_SRCB = 1;
//                    //PC_SOURCE = 3;
//                    rf_wr_sel = 0;
//                end
//            JALR:
//                begin 
//                    ALU_FUNC = 0;
//                    ALU_SRCA = 0;  ALU_SRCB = 0;
//                    //PC_SOURCE = 1;
//                    rf_wr_sel = 0;
//                end
//            BRANCH:
//                begin
//                    rf_wr_sel = 0;
//                    ALU_SRCA = 0;
//                    ALU_SRCB = 0;
//                    ALU_FUNC = 0;
//                end
//            LOAD:
//                begin
//                    ALU_FUNC = 0;
//                    ALU_SRCA = 0;  ALU_SRCB = 1;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 2;
//                end
//            STORE:
//                begin
//                    ALU_FUNC = 0;
//                    ALU_SRCA = 0;  ALU_SRCB = 2;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 0; //irrelevant
//                end
//            OP_IMM:
//                begin
//                    ALU_SRCA = 0;  ALU_SRCB = 1;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 3; 
//                    if ( FUNC3 == 3'b101)
//                        ALU_FUNC = { FUNC7[5], FUNC3};
//                    else 
//                        ALU_FUNC = { 1'b0, FUNC3 };
                    
//                end
//             OP: 
//                begin
//                    ALU_SRCA = 0;  ALU_SRCB = 0;
//                    //PC_SOURCE = 0;
//                    rf_wr_sel = 3; 
//                    ALU_FUNC = {FUNC7[5], FUNC3} ; 
//                end
////            SYSTEM: 
////                begin
////                    ALU_FUNC = 9;
////                    rf_wr_sel = 1;
////                    if(FUNC3 == 0)
////                        PC_SOURCE = 5;
////                end
//            endcase
        
//        end

//endmodule