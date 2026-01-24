# Example Output, Analysis, and Future Scope
EL Phase-2 | Computer Architecture  
Project Title: 5-Stage Pipelined RISC-V Processor with Hazard Handling

---

## Example Program Executed

The processor was simulated using a Verilog testbench
(`riscv_processor_tb.v`) to verify pipelined execution,
data hazard detection, and operand forwarding.

The following RISC-V program was executed:

```assembly
addi x1, x0, 5
addi x2, x0, 10
add  x3, x1, x2
sub  x4, x1, x2
add  x5, x2, x3
This program intentionally introduces multiple Read-After-Write (RAW)
data hazards to validate the forwarding mechanism.

## Simulation Output Summary

The simulation completed successfully with correct execution across
all five pipeline stages.

### Final Register File State

| Register | Hex Value | Decimal Value |
|--------|-----------|---------------|
| x1 | 0x00000005 | 5 |
| x2 | 0x0000000A | 10 |
| x3 | 0x0000000F | 15 |
| x4 | 0xFFFFFFFB | -5 |
| x5 | 0x00000019 | 25 |

All register values match the expected results.

---

## Output Analysis

### Pipeline Execution
The processor operates using a five-stage pipeline consisting of
Instruction Fetch (IF), Instruction Decode (ID), Execute (EX),
Memory Access (MEM), and Write Back (WB). Multiple instructions
are executed concurrently, demonstrating correct pipelined behavior.

### Data Hazard Handling
The executed program introduces multiple Read-After-Write (RAW)
data hazards between dependent instructions. These hazards are
successfully resolved using operand forwarding without stalling
the pipeline.

### Forwarding Mechanism
Simulation logs confirm forwarding from:
- EX/MEM pipeline register
- MEM/WB pipeline register

This ensures that dependent instructions receive correct operands
before register write-back, maintaining pipeline efficiency.

### Write-Back Verification
All register updates occur only in the Write Back (WB) stage.
The final register file contents match the expected arithmetic results,
confirming correct ALU operation and control signal generation.

### Pipeline Completion
After the final instruction completes execution, the pipeline fetches
invalid instructions (shown as undefined values), indicating normal
pipeline drain behavior.

---

## Verification Results

Expected vs Actual Results:
- x1 = 5 → PASS
- x2 = 10 → PASS
- x3 = 15 → PASS
- x4 = -5 → PASS
- x5 = 25 → PASS

All test cases passed successfully.

---

## Future Scope
- Extension of the processor to support RISC-V M-extension instructions
- Early branch resolution and branch prediction
- True superscalar execution with multi-issue capability
- Cache memory integration for improved performance
- FPGA-based synthesis and real hardware validation


