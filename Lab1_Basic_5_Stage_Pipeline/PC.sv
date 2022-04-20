`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////
// Engineer: Sandra Lwin
// Module Name: program_counter
/////////////////////////////////////////////////////////////////////////////

module PC #(parameter WIDTH = 32)(
    input [WIDTH-1:0] Din, // output of the mux
    input CLK,
    input pcWrite, //LD
    input reset, //clr
    output logic [WIDTH-1:0] PC_COUNT = 0 //counter output
    );
    
    always_ff @ (posedge CLK)
    begin
        if (reset)
            PC_COUNT = 0;
        else if (pcWrite) //input the mux output when load is high
            PC_COUNT = Din;
    end
            
endmodule
