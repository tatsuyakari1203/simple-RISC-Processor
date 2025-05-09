# RISC Processor Waveform Capture Guide

This guide lists the important signals to include in your project report.

## Key Signals for Report

### Basic Control
- `clk` - System clock
- `rst` - Reset signal
- `halt` - Halt signal (indicates program termination)

### CPU State
- `current_state` - Current state of the controller FSM

### Program Execution
- `pc_out` - Program Counter output
- `ir_out` - Instruction Register output
- `opcode` - Extracted operation code
- `operand` - Extracted operand value

### Data Path
- `acc_out` - Accumulator output
- `alu_out` - ALU output
- `mem_addr` - Memory address
- `mem_data_in` - Memory data input
- `mem_data_out` - Memory data output

### Control Signals
- `sel` - Address select
- `rd` - Memory read
- `ld_ir` - Load instruction register
- `inc_pc` - Increment program counter
- `ld_ac` - Load accumulator
- `ld_pc` - Load program counter
- `wr` - Memory write
- `data_e` - Data enable
- `is_zero` - Zero flag

## Important Operations to Capture

For your report, focus on capturing waveforms during these key operations:

1. **Instruction Fetch**: Shows how the processor fetches instructions from memory
2. **Instruction Decode**: Shows how opcode and operand are extracted
3. **Instruction Execution**: 
   - LDA (Load Accumulator)
   - STO (Store)
   - ADD
   - AND
   - XOR
   - JMP (Jump)
   - SKZ (Skip if Zero)
   - HLT (Halt)
4. **Memory Operations**: Read and write cycles
5. **Jump Execution**: PC update during jumps

These signals and operations will provide comprehensive evidence of your processor's functionality. 