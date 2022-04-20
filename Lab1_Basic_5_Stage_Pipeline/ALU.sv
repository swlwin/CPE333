`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////
// Engineer: Sandra Lwin
// Module Name: ALU
/////////////////////////////////////////////////////////////////////////////

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_FUNC,
    output logic [31:0] OUT
    );
    
    always_comb 
    begin
        case(ALU_FUNC)
            4'b0000: 
            begin
            OUT = A + B; //add
            end
            
            4'b1000:
            begin 
            OUT = A - B; //sub
            end
            
            4'b0110:
            begin
            OUT = A | B; //or
            end
            
            4'b0111:
            begin
            OUT = A & B; //and
            end
            
            4'b0100:
            begin 
            OUT = A ^ B; //xor          
            end

            4'b0101:
            begin
            OUT = A >> B[4:0]; // srl
            end
            
            4'b0001:
            begin
            OUT = A << B[4:0]; //sll
            end
            
            4'b1101:
            begin
            OUT = $signed(A) >>> B[4:0]; //sra
            //R[rd] = $signed(R[rs1]) >>> R[rs2](4:0)
            end
            
            4'b0010:
            begin
            OUT = ($signed(A) < $signed(B)) ?1:0; //slt
            //R[rd] = ($signed(R[rs1]) < $signed(R[rs2])) ? 1 : 0
            end
            
            4'b0011: 
            begin 
            OUT = (A < B) ?1:0; //sltu
            //R[rd] = (R[rs1] < R[rs2]) ? 1 : 0
            end
            
            4'b1001:
            begin
            OUT = A; //lui
            //upper immediate
            end
            
            default: 
                OUT = A;
            
        endcase
    end 
endmodule
