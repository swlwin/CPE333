`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2022 10:28:58 AM
// Design Name: 
// Module Name: Immed_Gen
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


module IMMED_GEN(
    input [31:0] IR, 
    output logic [31:0] UType, IType, SType, JType, BType
    );
    
    always_comb
    begin 
    UType = {IR[31:12],12'b0};
    IType = {{21{IR[31]}},IR[30:25], IR[24:21], IR[20]};
    SType = {{21{IR[31]}}, IR[30:25], IR[11:8], IR[7]};
    JType = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0};
    BType = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
    end 
endmodule
