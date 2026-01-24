`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:32:25
// Design Name: 
// Module Name: ex_mem
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


module ex_mem (
    input clk, rst,
    input [31:0] alu_result_in, rs2_data_in, branch_target_in,
    input [4:0] rd_in,
    input zero_in, branch_in, mem_read_in, mem_to_reg_in, mem_write_in, reg_write_in,
    output reg [31:0] alu_result_out, rs2_data_out, branch_target_out,
    output reg [4:0] rd_out,
    output reg zero_out, branch_out, mem_read_out, mem_to_reg_out, mem_write_out, reg_write_out,
    output reg [31:0] alu_result_prev,  // NEW: Previous ALU result for EX-to-EX forwarding
    output reg [4:0] rd_prev,            // NEW: Previous rd for EX-to-EX forwarding
    output reg reg_write_prev            // NEW: Previous reg_write for EX-to-EX forwarding
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 0; rs2_data_out <= 0; branch_target_out <= 0;
            rd_out <= 0; zero_out <= 0; branch_out <= 0;
            mem_read_out <= 0; mem_to_reg_out <= 0; mem_write_out <= 0; reg_write_out <= 0;
            alu_result_prev <= 0; rd_prev <= 0; reg_write_prev <= 0;
        end else begin
            // Store current values as "previous" for next cycle
            alu_result_prev <= alu_result_in;
            rd_prev <= rd_in;
            reg_write_prev <= reg_write_in;
            
            // Normal pipeline progression
            alu_result_out <= alu_result_in; rs2_data_out <= rs2_data_in;
            branch_target_out <= branch_target_in; rd_out <= rd_in;
            zero_out <= zero_in; branch_out <= branch_in;
            mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
            mem_write_out <= mem_write_in; reg_write_out <= reg_write_in;
        end
    end
endmodule