`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 02/01/2022 10:27:50 AM
// Module Name: BranchCondGen
//////////////////////////////////////////////////////////////////////////////////


module BranchCondGen(
    input [31:0] A, B,
    output logic EQ,
    output logic LT,
    output logic LTU
    );
    
    always_comb
    begin
    EQ = 0; LT = 0; LTU = 0;
        if (A == B)
            EQ = 1;
        if (A < B)
            LTU = 1;
        if ($signed(A) < $signed(B))
            LT = 1;
        
    end
endmodule
