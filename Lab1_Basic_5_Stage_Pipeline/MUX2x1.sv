`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: MUX
// Module Name: mux2_1
//////////////////////////////////////////////////////////////////////////////////

module MUX2_1  #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] zero,
    input logic [WIDTH-1:0] one,
    input logic SEL,
  
    output logic [WIDTH-1:0] out
    );
   
    always_comb
    begin 
        case(SEL)   
            0:
            begin
                out = zero;
            end
            1:
            begin
                out = one;
            end
        endcase
    end 
endmodule

