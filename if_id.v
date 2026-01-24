`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:39:02
// Design Name: 
// Module Name: if_id
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


module if_id (
    input clk, rst, stall, flush,
    input [31:0] pc_in, instr_in,
    output reg [31:0] pc_out, instr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_out <= 0;
            instr_out <= 32'h00000013; // NOP
        end else if (!stall) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule