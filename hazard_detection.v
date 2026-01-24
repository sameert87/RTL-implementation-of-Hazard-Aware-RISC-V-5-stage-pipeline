`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:09:32
// Design Name: 
// Module Name: hazard_detection
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


module hazard_detection (
    input [4:0] rs1_id, rs2_id, rd_ex, rd_mem,
    input mem_read_ex,
    output reg stall, flush
);
    always @(*) begin
        stall = 0; flush = 0;
        
        // Load-use hazard detection
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall = 1;
            flush = 1;
        end
    end
endmodule
