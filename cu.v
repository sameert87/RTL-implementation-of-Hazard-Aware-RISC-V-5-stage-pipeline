`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:07:16
// Design Name: 
// Module Name: cu
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


module cu(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write,
    output reg [3:0] alu_op
);
    always @(*) begin
        // Defaults
        branch = 0; mem_read = 0; mem_to_reg = 0;
        mem_write = 0; alu_src = 0; reg_write = 0; alu_op = 4'b0000;
        
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1;
                case ({funct7, funct3})
                    10'b0000000_000: alu_op = 4'b0000; // ADD
                    10'b0100000_000: alu_op = 4'b0001; // SUB
                    10'b0000000_111: alu_op = 4'b0010; // AND
                    10'b0000000_110: alu_op = 4'b0011; // OR
                    10'b0000000_100: alu_op = 4'b0100; // XOR
                    10'b0000000_001: alu_op = 4'b0101; // SLL
                    10'b0000000_101: alu_op = 4'b0110; // SRL
                    10'b0000000_010: alu_op = 4'b0111; // SLT
                endcase
            end
            7'b0010011: begin // I-type (immediate)
                reg_write = 1; alu_src = 1;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b111: alu_op = 4'b0010; // ANDI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b100: alu_op = 4'b0100; // XORI
                endcase
            end
            7'b0000011: begin // Load
                reg_write = 1; alu_src = 1; mem_read = 1; mem_to_reg = 1;
                alu_op = 4'b0000; // ADD for address
            end
            7'b0100011: begin // Store
                alu_src = 1; mem_write = 1;
                alu_op = 4'b0000; // ADD for address
            end
            7'b1100011: begin // Branch
                branch = 1;
                alu_op = 4'b0001; // SUB for comparison
            end
        endcase
    end
endmodule