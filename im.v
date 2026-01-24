`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:03:57
// Design Name: 
// Module Name: im
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


module im(
input [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];
    
    initial begin
        // Sample program: add, sub with hazards
        mem[0] = 32'h00500093;  // addi x1, x0, 5
        mem[1] = 32'h00a00113;  // addi x2, x0, 10
        mem[2] = 32'h002081b3;  // add x3, x1, x2  (RAW hazard on x1, x2)
        mem[3] = 32'h40208233;  // sub x4, x1, x2  (RAW hazard on x1, x2)
        mem[4] = 32'h003102b3;  // add x5, x2, x3  (RAW hazard on x3)
    end
    
    assign instruction = mem[addr[31:2]];
endmodule