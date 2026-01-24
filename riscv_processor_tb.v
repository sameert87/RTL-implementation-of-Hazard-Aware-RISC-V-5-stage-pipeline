`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 11:42:25
// Design Name: 
// Module Name: riscv_processor_tb
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


module riscv_processor_tb();
// Testbench for RISC-V Pipelined Processor with Hazard Handling

    reg clk, rst;
    
    // Instantiate the processor
    riscv_processor uut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize waveform dump
        $dumpfile("riscv_processor.vcd");
        $dumpvars(0, riscv_processor_tb);
        
        // Display header
        $display("=========================================");
        $display("RISC-V Pipelined Processor Testbench");
        $display("Testing Hazard Detection and Forwarding");
        $display("=========================================");
        $display("");
        
        // Reset sequence
        rst = 1;
        #15;
        rst = 0;
        $display("Time=%0t: Reset released, starting execution", $time);
        $display("");
        
        // Monitor register file changes
        $display("Monitoring Register Updates:");
        $display("--------------------------------------------");
        
        // Run for enough cycles to execute the program
        repeat(20) begin
            @(posedge clk);
            #1; // Small delay to see register updates
            
            // Display register file state after each cycle
            if (uut.reg_write_wb && uut.rd_wb != 0) begin
                $display("Time=%0t: WB Stage - Writing x%0d = %h (%0d)", 
                         $time, uut.rd_wb, uut.write_data, $signed(uut.write_data));
            end
            
            // Display forwarding activity
            if (uut.forward_a != 2'b00 || uut.forward_b != 2'b00) begin
                $display("Time=%0t: EX Stage - Forwarding detected:", $time);
                if (uut.forward_a == 2'b10)
                    $display("           Forward A from MEM stage (x%0d)", uut.rs1_ex);
                else if (uut.forward_a == 2'b01)
                    $display("           Forward A from WB stage (x%0d)", uut.rs1_ex);
                if (uut.forward_b == 2'b10)
                    $display("           Forward B from MEM stage (x%0d)", uut.rs2_ex);
                else if (uut.forward_b == 2'b01)
                    $display("           Forward B from WB stage (x%0d)", uut.rs2_ex);
            end
            
            // Display stall activity
            if (uut.stall) begin
                $display("Time=%0t: STALL detected - Load-use hazard", $time);
            end
        end
        
        $display("");
        $display("--------------------------------------------");
        $display("Final Register File State:");
        $display("--------------------------------------------");
        display_registers();
        
        $display("");
        $display("=========================================");
        $display("Verification:");
        $display("=========================================");
        verify_results();
        
        $display("");
        $display("Simulation completed successfully!");
        $finish;
    end
    
    // Task to display register file contents
    task display_registers;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                if (uut.regfile.registers[i] != 0) begin
                    $display("x%2d = 0x%08h (%0d)", i, 
                             uut.regfile.registers[i], 
                             $signed(uut.regfile.registers[i]));
                end
            end
        end
    endtask
    
    // Task to verify expected results
    task verify_results;
        reg [31:0] expected_x1, expected_x2, expected_x3, expected_x4, expected_x5;
        reg test_passed;
        begin
            // Expected values based on the program:
            // x1 = 5, x2 = 10, x3 = 15, x4 = -5, x5 = 25
            expected_x1 = 32'd5;
            expected_x2 = 32'd10;
            expected_x3 = 32'd15;   // x1 + x2 = 5 + 10 = 15
            expected_x4 = -32'd5;   // x1 - x2 = 5 - 10 = -5
            expected_x5 = 32'd25;   // x2 + x3 = 10 + 15 = 25
            
            test_passed = 1;
            
            $display("Expected vs Actual:");
            
            if (uut.regfile.registers[1] == expected_x1)
                $display("x1:  PASS (Expected: %0d, Got: %0d)", 
                         $signed(expected_x1), $signed(uut.regfile.registers[1]));
            else begin
                $display("x1:  FAIL (Expected: %0d, Got: %0d)", 
                         $signed(expected_x1), $signed(uut.regfile.registers[1]));
                test_passed = 0;
            end
            
            if (uut.regfile.registers[2] == expected_x2)
                $display("x2:  PASS (Expected: %0d, Got: %0d)", 
                         $signed(expected_x2), $signed(uut.regfile.registers[2]));
            else begin
                $display("x2:  FAIL (Expected: %0d, Got: %0d)", 
                         $signed(expected_x2), $signed(uut.regfile.registers[2]));
                test_passed = 0;
            end
            
            if (uut.regfile.registers[3] == expected_x3)
                $display("x3:  PASS (Expected: %0d, Got: %0d)", 
                         $signed(expected_x3), $signed(uut.regfile.registers[3]));
            else begin
                $display("x3:  FAIL (Expected: %0d, Got: %0d)", 
                         $signed(expected_x3), $signed(uut.regfile.registers[3]));
                test_passed = 0;
            end
            
            if (uut.regfile.registers[4] == expected_x4)
                $display("x4:  PASS (Expected: %0d, Got: %0d)", 
                         $signed(expected_x4), $signed(uut.regfile.registers[4]));
            else begin
                $display("x4:  FAIL (Expected: %0d, Got: %0d)", 
                         $signed(expected_x4), $signed(uut.regfile.registers[4]));
                test_passed = 0;
            end
            
            if (uut.regfile.registers[5] == expected_x5)
                $display("x5:  PASS (Expected: %0d, Got: %0d)", 
                         $signed(expected_x5), $signed(uut.regfile.registers[5]));
            else begin
                $display("x5:  FAIL (Expected: %0d, Got: %0d)", 
                         $signed(expected_x5), $signed(uut.regfile.registers[5]));
                test_passed = 0;
            end
            
            $display("");
            if (test_passed)
                $display("*** ALL TESTS PASSED ***");
            else
                $display("*** SOME TESTS FAILED ***");
        end
    endtask
    
    // Pipeline stage monitoring
    initial begin
        $display("");
        $display("Pipeline Stage Monitoring:");
        $display("--------------------------------------------");
        
        #20; // Wait for reset
        
        repeat(25) begin
            @(posedge clk);
            #1;
            $display("");
            $display("Cycle %0t:", $time/10);
            $display("  IF:  PC=0x%h, Instr=0x%h", uut.pc, uut.instruction);
            $display("  ID:  PC=0x%h, Instr=0x%h, rs1=x%0d, rs2=x%0d, rd=x%0d", 
                     uut.pc_id, uut.instr_id, uut.rs1, uut.rs2, uut.rd_id);
            $display("  EX:  rd=x%0d, ALU_A=%0d, ALU_B=%0d, ALU_Result=%0d", 
                     uut.rd_ex, $signed(uut.alu_a), $signed(uut.alu_b), 
                     $signed(uut.alu_result));
            $display("  MEM: rd=x%0d, ALU_Result=%0d, MemRead=%b, MemWrite=%b", 
                     uut.rd_mem, $signed(uut.alu_result_mem), 
                     uut.mem_read_mem, uut.mem_write_mem);
            $display("  WB:  rd=x%0d, WriteData=%0d, RegWrite=%b", 
                     uut.rd_wb, $signed(uut.write_data), uut.reg_write_wb);
            
            if (uut.stall)
                $display("  >>> PIPELINE STALLED <<<");
        end
    end
    
    // Watchdog timer
    initial begin
        #5000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end
    
endmodule
