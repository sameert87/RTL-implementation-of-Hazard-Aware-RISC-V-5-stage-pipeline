`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:34:15
// Design Name: 
// Module Name: data_memory
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

module data_memory (
  input clk,
    input [31:0] addr, write_data,
    input mem_read, mem_write,
    output [31:0] read_data
);
    reg [31:0] mem [0:255];
    
    always @(posedge clk) begin
        if (mem_write)
            mem[addr[31:2]] <= write_data;
    end
    
    assign read_data = mem_read ? mem[addr[31:2]] : 32'h00000000;
endmodule