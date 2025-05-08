# Simple RISC Processor

A simple RISC (Reduced Instruction Set Computer) processor implementation in Verilog HDL. This project implements a basic CPU with a simplified instruction set architecture for educational purposes.

## Project Structure

- `/rtl` - Register Transfer Level design files
  - `cpu_top.v` - Top-level CPU module
  - `controller.v` - Control unit implementation
  - `alu.v` - Arithmetic Logic Unit
  - `accumulator.v` - Accumulator register
  - `memory.v` - Memory implementation
  - `instruction_reg.v` - Instruction register
  - `address_mux.v` - Address multiplexer
  - `program_counter.v` - Program counter

- `/sim` - Simulation files
  - `/test_programs` - Example programs for testing
    - `testprog.v` - Basic test program
    - `simple_program.v` - Simple program implementation

- `/testbench` - Testbench files for verification
  - `tb_cpu_top.v` - Testbench for top-level CPU
  - `tb_controller.v` - Testbench for controller
  - Various other component-specific testbenches

## Architecture

This processor implements a simple RISC architecture with:
- Single accumulator design
- Fetch-decode-execute pipeline
- Basic instruction set including arithmetic, logical, and control flow operations

## How to Use

### Simulation
To simulate the processor:
1. Load the design in your preferred Verilog simulator (ModelSim, Vivado, etc.)
2. Run the testbench files in the `/testbench` directory

### Running Test Programs
The `/sim/test_programs` directory contains example programs that can be loaded into the processor's memory for testing.

## Documentation

For detailed information about the implementation and design choices, refer to:
- `RISC_Processor_Implementation_Report.md` - Detailed implementation report
- `research.md` - Research documentation
- `assignment.md` - Original project requirements

## License

This project is available for educational purposes. 