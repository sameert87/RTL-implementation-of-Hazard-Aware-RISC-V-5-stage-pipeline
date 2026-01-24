`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 10:14:16
// Design Name: 
// Module Name: forwarding_unit
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

module forwarding_unit (
    input [4:0] rs1_ex, rs2_ex, rd_ex, rd_mem, rd_wb,
    input reg_write_ex, reg_write_mem, reg_write_wb,
    output reg [1:0] forward_a, forward_b
);
    always @(*) begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // **NEW: EX-to-EX forwarding (highest priority)**
        // This forwards the ALU result from the same EX stage (previous instruction's result)
        // This is needed when an instruction immediately follows another that writes to a register it reads
        if (reg_write_ex && (rd_ex != 0) && (rd_ex == rs1_ex))
            forward_a = 2'b11;  // Forward from EX stage (ALU result from previous cycle)
        if (reg_write_ex && (rd_ex != 0) && (rd_ex == rs2_ex))
            forward_b = 2'b11;  // Forward from EX stage (ALU result from previous cycle)
        
        // MEM-to-EX forwarding (forward from MEM stage)
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex) && 
            !(reg_write_ex && (rd_ex != 0) && (rd_ex == rs1_ex)))
            forward_a = 2'b10;
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex) &&
            !(reg_write_ex && (rd_ex != 0) && (rd_ex == rs2_ex)))
            forward_b = 2'b10;
            
        // WB-to-EX forwarding (forward from WB stage - lowest priority)
        if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs1_ex) && 
            !(reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex)) &&
            !(reg_write_ex && (rd_ex != 0) && (rd_ex == rs1_ex)))
            forward_a = 2'b01;
        if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs2_ex) &&
            !(reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex)) &&
            !(reg_write_ex && (rd_ex != 0) && (rd_ex == rs2_ex)))
            forward_b = 2'b01;
    end
endmodule
