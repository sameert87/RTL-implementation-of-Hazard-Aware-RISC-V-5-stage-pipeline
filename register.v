`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:06:15
// Design Name: 
// Module Name: register
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


module register(
    input clk, rst,
    input [4:0] rs1, rs2, rd_wb,
    input reg_write_wb,
    input [31:0] write_data,
    output [31:0] rs1_data, rs2_data
);
    reg [31:0] registers [0:31];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 0;
        end else if (reg_write_wb && rd_wb != 0) begin
            registers[rd_wb] <= write_data;
        end
    end
    
    assign rs1_data = (rs1 == 0) ? 0 :
                 (reg_write_wb && rs1 == rd_wb) ? write_data : registers[rs1];
    assign rs2_data = (rs2 == 0) ? 0 :
                 (reg_write_wb && rs2 == rd_wb) ? write_data : registers[rs2];
endmodule