`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/27/2022 09:58:18 AM
// Module Name: Reg_File
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile(
    input CLK,
    input [31:0] WD, //Write Data
    input [4:0] R1, R2, WA, //register to read or write, 
    input EN, //rf_wr, write enable 
    output logic [31:0] RS1, RS2 // D1_OUT, D2_OUT
    
);

    // Create a memory module with 32-bit width and 512 addresses 
    logic [31:0] regs [0:31];
    
    always_comb
        if(R1 == 0)
            RS1 = 0;
        else
            RS1 = regs[R1];
    always_comb 
        if(R2 == 0)
            RS2 = 0;
        else 
            RS2 = regs[R2];
        
    always_ff @(negedge CLK) 
    begin 
        if(EN && WA !=0)
            regs[WA] <= WD;
    end
    
endmodule

/*
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/27/2022 09:58:18 AM
// Module Name: Reg_File
//////////////////////////////////////////////////////////////////////////////////


module Reg_File(
    input CLK,
    input [31:0] WD, //DATA IN  or WARD
    input [4:0] ADR1, ADR2, WA,
    input EN, //rf_wr, write enable 
    output [31:0] RS1, RS2 // D1_OUT, D2_OUT
    
);

    // Create a memory module with 32-bit width and 512 addresses 
    logic [31:0] regs [0:31];
    
    initial
    begin
        for (int i=0; i<32; i++) 
        begin 
            regs[i] = 0;
        end
    end 
    
    //Synchronous write 
    always_ff @(posedge CLK) 
    begin 
        if(EN && WA != 0)
        begin
            regs[WA] = WD;
        end
    end
    
    assign RS1 = (ADR1==0)? 0: regs[ADR1];
    assign RS2 = (ADR2==0)? 0: regs[ADR2]; 
    
endmodule

            
*/         
