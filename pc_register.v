`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:01:02
// Design Name: 
// Module Name: pc_register
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


module pc_register (
    input clk, rst,
    input stall,
    input pc_src,
    input [31:0] branch_target,
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h00000000;
        else if (!stall)
            pc <= pc_src ? branch_target : pc + 4;
    end
endmodule