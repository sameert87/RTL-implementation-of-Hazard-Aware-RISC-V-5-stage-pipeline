`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:29:52
// Design Name: 
// Module Name: id_ex
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


module id_ex (
    input clk, rst, flush,
    input [31:0] pc_in, rs1_data_in, rs2_data_in, imm_in,
    input [4:0] rs1_in, rs2_in, rd_in,
    input branch_in, mem_read_in, mem_to_reg_in, mem_write_in, alu_src_in, reg_write_in,
    input [3:0] alu_op_in,
    output reg [31:0] pc_out, rs1_data_out, rs2_data_out, imm_out,
    output reg [4:0] rs1_out, rs2_out, rd_out,
    output reg branch_out, mem_read_out, mem_to_reg_out, mem_write_out, alu_src_out, reg_write_out,
    output reg [3:0] alu_op_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_out <= 0; rs1_data_out <= 0; rs2_data_out <= 0; imm_out <= 0;
            rs1_out <= 0; rs2_out <= 0; rd_out <= 0;
            branch_out <= 0; mem_read_out <= 0; mem_to_reg_out <= 0;
            mem_write_out <= 0; alu_src_out <= 0; reg_write_out <= 0;
            alu_op_out <= 0;
        end else begin
            pc_out <= pc_in; rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in; imm_out <= imm_in;
            rs1_out <= rs1_in; rs2_out <= rs2_in; rd_out <= rd_in;
            branch_out <= branch_in; mem_read_out <= mem_read_in;
            mem_to_reg_out <= mem_to_reg_in; mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in; reg_write_out <= reg_write_in;
            alu_op_out <= alu_op_in;
        end
    end
endmodule