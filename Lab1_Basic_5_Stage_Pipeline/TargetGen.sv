`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2022 02:20:05 PM
// Design Name: 
// Module Name: TargetGen
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


module TargetGen(
    input [31:0] RS1, IType, JType, BType, PC_OUT,
    output logic [31:0] JAL, JALR, BRANCH
    );
    
    always_comb
    begin 
    JALR = RS1 + IType;
    JAL = PC_OUT + JType;
    BRANCH = PC_OUT + BType;
    end 
endmodule
