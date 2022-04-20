`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: MUX
// Module Name: mux4_1
//////////////////////////////////////////////////////////////////////////////////

module MUX4_1  #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] zero,
    input logic [WIDTH-1:0] one,
    input logic [WIDTH-1:0] two,
    input logic [WIDTH-1:0] three,
    input logic [1:0] SEL,
    
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
            2:
            begin
                out = two;
            end
            3: 
            begin
                out = three;
            end
        endcase
    end 
endmodule

