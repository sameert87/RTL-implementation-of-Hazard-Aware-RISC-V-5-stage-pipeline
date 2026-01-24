`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:36:23
// Design Name: 
// Module Name: riscv_processor
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

module riscv_processor (
    input clk, rst
);
    // IF stage
    wire [31:0] pc, pc_next, instruction;
    wire stall, flush_id, pc_src;
    wire [31:0] branch_target_mem;
    
    // ID stage
    wire [31:0] pc_id, instr_id;
    wire [31:0] rs1_data, rs2_data, imm;
    wire [4:0] rs1, rs2, rd_id;
    wire branch_id, mem_read_id, mem_to_reg_id, mem_write_id, alu_src_id, reg_write_id;
    wire [3:0] alu_op_id;
    
    // EX stage
    wire [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire branch_ex, mem_read_ex, mem_to_reg_ex, mem_write_ex, alu_src_ex, reg_write_ex;
    wire [3:0] alu_op_ex;
    wire [31:0] alu_a, alu_b, alu_result;
    wire [1:0] forward_a, forward_b;
    wire [31:0] forward_data_a, forward_data_b;
    wire zero;
    
    // MEM stage
    wire [31:0] alu_result_mem, rs2_data_mem, branch_target_mem_out;
    wire [4:0] rd_mem;
    wire zero_mem, branch_mem, mem_read_mem, mem_to_reg_mem, mem_write_mem, reg_write_mem;
    wire [31:0] mem_data;
    wire [31:0] alu_result_prev;  // NEW: For EX-to-EX forwarding
    wire [4:0] rd_prev;            // NEW: For EX-to-EX forwarding
    wire reg_write_prev;           // NEW: For EX-to-EX forwarding
    
    // WB stage
    wire [31:0] alu_result_wb, mem_data_wb, write_data;
    wire [4:0] rd_wb;
    wire mem_to_reg_wb, reg_write_wb;
    
    // IF Stage
    pc_register pc_reg(.clk(clk), .rst(rst), .stall(stall), .pc_src(pc_src),
                       .branch_target(branch_target_mem_out), .pc(pc));
    
    im imem(.addr(pc), .instruction(instruction));
    
    if_id if_id(.clk(clk), .rst(rst), .stall(stall), .flush(flush_id),
                    .pc_in(pc), .instr_in(instruction),
                    .pc_out(pc_id), .instr_out(instr_id));
    
    // ID Stage
    assign rs1 = instr_id[19:15];
    assign rs2 = instr_id[24:20];
    assign rd_id = instr_id[11:7];
    assign imm = {{20{instr_id[31]}}, instr_id[31:20]}; // I-type immediate
    
    register regfile(.clk(clk), .rst(rst), .rs1(rs1), .rs2(rs2),
                         .rd_wb(rd_wb), .reg_write_wb(reg_write_wb),
                         .write_data(write_data),
                         .rs1_data(rs1_data), .rs2_data(rs2_data));
    
    cu ctrl(.opcode(instr_id[6:0]), .funct3(instr_id[14:12]),
                     .funct7(instr_id[31:25]),
                     .branch(branch_id), .mem_read(mem_read_id),
                     .mem_to_reg(mem_to_reg_id), .mem_write(mem_write_id),
                     .alu_src(alu_src_id), .reg_write(reg_write_id),
                     .alu_op(alu_op_id));
    
    hazard_detection hazard(.rs1_id(rs1), .rs2_id(rs2), .rd_ex(rd_ex),
                           .rd_mem(rd_mem), .mem_read_ex(mem_read_ex),
                           .stall(stall), .flush(flush_id));
    
    id_ex id_ex(.clk(clk), .rst(rst), .flush(flush_id),  // FIXED: Now uses flush signal
                    .pc_in(pc_id), .rs1_data_in(rs1_data), .rs2_data_in(rs2_data), .imm_in(imm),
                    .rs1_in(rs1), .rs2_in(rs2), .rd_in(rd_id),
                    .branch_in(branch_id), .mem_read_in(mem_read_id),
                    .mem_to_reg_in(mem_to_reg_id), .mem_write_in(mem_write_id),
                    .alu_src_in(alu_src_id), .reg_write_in(reg_write_id),
                    .alu_op_in(alu_op_id),
                    .pc_out(pc_ex), .rs1_data_out(rs1_data_ex),
                    .rs2_data_out(rs2_data_ex), .imm_out(imm_ex),
                    .rs1_out(rs1_ex), .rs2_out(rs2_ex), .rd_out(rd_ex),
                    .branch_out(branch_ex), .mem_read_out(mem_read_ex),
                    .mem_to_reg_out(mem_to_reg_ex), .mem_write_out(mem_write_ex),
                    .alu_src_out(alu_src_ex), .reg_write_out(reg_write_ex),
                    .alu_op_out(alu_op_ex));
    
    // EX Stage - UPDATED: Now uses enhanced forwarding with EX-to-EX support
    forwarding_unit forward(.rs1_ex(rs1_ex), .rs2_ex(rs2_ex),
                           .rd_ex(rd_prev), .rd_mem(rd_mem), .rd_wb(rd_wb),  // CHANGED: rd_ex now uses rd_prev
                           .reg_write_ex(reg_write_prev), .reg_write_mem(reg_write_mem), .reg_write_wb(reg_write_wb),
                           .forward_a(forward_a), .forward_b(forward_b));
    
    // UPDATED: Forwarding mux now includes EX-to-EX path (2'b11)
    assign forward_data_a = (forward_a == 2'b11) ? alu_result_prev :  // EX-to-EX forwarding
                           (forward_a == 2'b10) ? alu_result_mem :    // MEM-to-EX forwarding
                           (forward_a == 2'b01) ? write_data :        // WB-to-EX forwarding
                           rs1_data_ex;                               // No forwarding
    
    assign forward_data_b = (forward_b == 2'b11) ? alu_result_prev :  // EX-to-EX forwarding
                           (forward_b == 2'b10) ? alu_result_mem :    // MEM-to-EX forwarding
                           (forward_b == 2'b01) ? write_data :        // WB-to-EX forwarding
                           rs2_data_ex;                               // No forwarding
    
    assign alu_a = forward_data_a;
    assign alu_b = alu_src_ex ? imm_ex : forward_data_b;
    
    alu alu_inst(.a(alu_a), .b(alu_b), .alu_op(alu_op_ex),
                .result(alu_result), .zero(zero));
    
    ex_mem ex_mem(.clk(clk), .rst(rst),
                      .alu_result_in(alu_result), .rs2_data_in(forward_data_b),
                      .branch_target_in(pc_ex + imm_ex), .rd_in(rd_ex),
                      .zero_in(zero), .branch_in(branch_ex),
                      .mem_read_in(mem_read_ex), .mem_to_reg_in(mem_to_reg_ex),
                      .mem_write_in(mem_write_ex), .reg_write_in(reg_write_ex),
                      .alu_result_out(alu_result_mem), .rs2_data_out(rs2_data_mem),
                      .branch_target_out(branch_target_mem_out), .rd_out(rd_mem),
                      .zero_out(zero_mem), .branch_out(branch_mem),
                      .mem_read_out(mem_read_mem), .mem_to_reg_out(mem_to_reg_mem),
                      .mem_write_out(mem_write_mem), .reg_write_out(reg_write_mem),
                      .alu_result_prev(alu_result_prev), .rd_prev(rd_prev), .reg_write_prev(reg_write_prev));
    
    // MEM Stage
    assign pc_src = branch_mem & zero_mem;
    
    data_memory dmem(.clk(clk), .addr(alu_result_mem), .write_data(rs2_data_mem),
                    .mem_read(mem_read_mem), .mem_write(mem_write_mem),
                    .read_data(mem_data));
    
    mem_wb mem_wb(.clk(clk), .rst(rst),
                      .alu_result_in(alu_result_mem), .mem_data_in(mem_data),
                      .rd_in(rd_mem), .mem_to_reg_in(mem_to_reg_mem),
                      .reg_write_in(reg_write_mem),
                      .alu_result_out(alu_result_wb), .mem_data_out(mem_data_wb),
                      .rd_out(rd_wb), .mem_to_reg_out(mem_to_reg_wb),
                      .reg_write_out(reg_write_wb));
    
    // WB Stage
    assign write_data = mem_to_reg_wb ? mem_data_wb : alu_result_wb;
endmodule