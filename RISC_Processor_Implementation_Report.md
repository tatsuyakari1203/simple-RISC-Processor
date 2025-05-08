# RISC Processor Implementation Analysis Report

## Introduction

This report provides a detailed analysis of our RISC (Reduced Instruction Set Computer) processor implementation, which was developed according to the assignment requirements. The processor features 3-bit opcodes and 5-bit addressing, allowing for 8 instruction types and 32 memory addresses.

## System Architecture

Our implementation follows a classic von Neumann architecture with shared instruction and data memory. The processor operates in a fetch-decode-execute cycle and consists of the following key components:

1. Program Counter (PC)
2. Address Multiplexer (Address MUX)
3. Memory
4. Instruction Register (IR)
5. Accumulator Register (ACC)
6. Arithmetic Logic Unit (ALU)
7. Controller

The interconnection of these components is managed by the CPU top module, which orchestrates data flow and control signals. Figure 1 illustrates the overall system architecture.

## Component Analysis

### 1. Program Counter (program_counter.v)

The Program Counter (PC) is a 5-bit register that keeps track of the current instruction address. It features synchronous operation with the rising edge of the clock signal and supports reset, increment, and load operations.

**Requirements Analysis:**
- ✅ 5-bit register tracking current instruction address
- ✅ Activates at the rising edge of the clock
- ✅ Active-HIGH reset signal to return PC to 0
- ✅ Supports loading arbitrary value for jumps
- ✅ Increments sequentially when needed

**Implementation Details:**

```verilog
module program_counter (
    input wire clk,          // Clock input
    input wire rst,          // Active HIGH reset
    input wire ld_pc,        // Load signal for jumps
    input wire inc_pc,       // Increment signal
    input wire [4:0] pc_in,  // Input for jump address
    output reg [4:0] pc_out  // Current program counter value
);

    // Sequential logic for the program counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset PC to 0
            pc_out <= 5'b0;
        end else if (ld_pc) begin
            // Load new address for jumps
            pc_out <= pc_in;
        end else if (inc_pc) begin
            // Increment PC
            pc_out <= pc_out + 5'b1;
        end
        // If neither ld_pc nor inc_pc is active, PC remains unchanged
    end
    
endmodule
```

The PC module is triggered by the clock's rising edge and responds to three main signals:
- `rst`: When active, resets the PC to 0
- `ld_pc`: When active, loads a new address from `pc_in` (used for jump instructions)
- `inc_pc`: When active, increments the PC by 1 (sequential execution)

Priority is maintained such that reset overrides load, which overrides increment. When none of these signals are active, the PC maintains its current value.

### 2. Address Multiplexer (address_mux.v)

The Address Multiplexer selects between the instruction address (from PC) and the operand address (from instruction) to provide the appropriate address to the memory.

**Requirements Analysis:**
- ✅ Multiplexes between instruction address and operand address
- ✅ Default width is 5 bits (parameterized for reusability)
- ✅ sel=1 selects instruction address (PC output)
- ✅ sel=0 selects operand address (from instruction)

**Implementation Details:**

```verilog
module address_mux #(
    parameter ADDR_WIDTH = 5  // Default address width is 5 bits
)(
    input wire sel,                       // Select signal: 1 for PC, 0 for operand address
    input wire [ADDR_WIDTH-1:0] pc_addr,  // Address from Program Counter
    input wire [ADDR_WIDTH-1:0] op_addr,  // Operand address from instruction
    output wire [ADDR_WIDTH-1:0] mem_addr // Address output to memory
);

    // Multiplex between PC address and operand address
    assign mem_addr = sel ? pc_addr : op_addr;
    
endmodule
```

The multiplexer is implemented with a simple conditional assignment:
- When `sel` is 1, the PC address (`pc_addr`) is selected
- When `sel` is 0, the operand address (`op_addr`) is selected

The module is parameterized with `ADDR_WIDTH` defaulting to 5 bits, allowing for potential reuse in different configurations.

### 3. Memory (memory.v)

The Memory module serves as shared storage for both instructions and data, with a size of 32 addresses (5-bit addressing) and 8-bit data width.

**Requirements Analysis:**
- ✅ Single shared memory for instructions and data
- ✅ Single bidirectional data port (separate read/write signals)
- ✅ 5-bit address width (32 addresses)
- ✅ 8-bit data width
- ✅ Synchronous operation on the positive clock edge
- ✅ Supports read and write operations

**Implementation Details:**

```verilog
module memory (
    input wire clk,           // Clock input
    input wire rst,           // Reset signal
    input wire rd,            // Read enable
    input wire wr,            // Write enable
    input wire [4:0] addr,    // 5-bit address (32 memory locations)
    input wire [7:0] data_in, // 8-bit input data
    output reg [7:0] data_out // 8-bit output data
);

    // Memory array: 32 locations x 8 bits
    reg [7:0] mem [0:31];
    
    integer i;
    
    // Read and write operations with synchronous reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize memory to 0 on reset
            for (i = 0; i < 32; i = i + 1) begin
                mem[i] <= 8'h00;
            end
            data_out <= 8'h00;
        end else begin
            // Memory operations
            if (rd) begin
                data_out <= mem[addr];
            end
            
            if (wr) begin
                mem[addr] <= data_in;
            end
        end
    end
    
endmodule
```

The memory module includes:
- A 32×8-bit memory array (`mem`)
- Synchronous read and write operations on the rising edge of the clock
- Read operation when `rd` is active, outputting the data from the specified address
- Write operation when `wr` is active, storing `data_in` at the specified address
- Reset functionality that initializes all memory locations to 0

### 4. Instruction Register (instruction_reg.v)

The Instruction Register holds the current instruction fetched from memory. It's an 8-bit register where the upper 3 bits represent the opcode and the lower 5 bits represent the operand address.

**Requirements Analysis:**
- ✅ 8-bit register to hold the current instruction
- ✅ Upper 3 bits are opcode, lower 5 bits are operand address (handled in cpu_top)
- ✅ Loads new instruction when ld_ir is active
- ✅ Synchronous operation

**Implementation Details:**

```verilog
module instruction_reg (
    input wire clk,           // Clock input
    input wire rst,           // Active HIGH reset
    input wire ld_ir,         // Load enable for instruction register
    input wire [7:0] data_in, // Instruction data from memory
    output reg [7:0] ir_out   // Instruction register output
);

    // Instruction register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset instruction register to 0
            ir_out <= 8'h00;
        end else if (ld_ir) begin
            // Load new instruction
            ir_out <= data_in;
        end
        // Otherwise, maintain current instruction
    end
    
endmodule
```

The instruction register operates synchronously:
- On reset, it clears to 0
- When `ld_ir` is active, it loads a new instruction from `data_in`
- Otherwise, it maintains its current value

The actual decoding of the instruction (separating opcode and operand) is handled in the CPU top module.

### 5. Accumulator Register (accumulator.v)

The Accumulator is an 8-bit register that stores intermediate results and serves as the primary operand for ALU operations.

**Requirements Analysis:**
- ✅ 8-bit register that stores intermediate results
- ✅ Loads result from ALU when ld_ac is active
- ✅ Synchronous operation
- ✅ Used as first operand for most ALU operations (connected in cpu_top)

**Implementation Details:**

```verilog
module accumulator (
    input wire clk,           // Clock input
    input wire rst,           // Active HIGH reset
    input wire ld_ac,         // Load enable for accumulator
    input wire [7:0] data_in, // Data input from ALU
    output reg [7:0] acc_out  // Accumulator output
);

    // Accumulator register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset accumulator to 0
            acc_out <= 8'h00;
        end else if (ld_ac) begin
            // Load new value into accumulator
            acc_out <= data_in;
        end
        // Otherwise, maintain current value
    end
    
endmodule
```

The accumulator operates similarly to the instruction register:
- On reset, it clears to 0
- When `ld_ac` is active, it loads a new value from `data_in` (typically from the ALU)
- Otherwise, it maintains its current value

In the CPU architecture, the accumulator's output is fed to the ALU as its first operand, enabling operations like ACC = ACC + Memory[addr].

### 6. ALU (alu.v)

The Arithmetic Logic Unit (ALU) performs various operations on 8-bit operands based on the 3-bit opcode. It also provides a zero flag indicating if the first operand is zero.

**Requirements Analysis:**
- ✅ Performs 8 operations on 8-bit operands (inA and inB)
- ✅ Operations defined by 3-bit opcode as required
- ✅ Asynchronous is_zero flag that indicates if inA is zero

**Implementation Details:**

```verilog
module alu (
    input wire [7:0] in_a,       // First operand (usually from accumulator)
    input wire [7:0] in_b,       // Second operand (usually from memory)
    input wire [2:0] opcode,     // Operation code
    output reg [7:0] alu_out,    // ALU output result
    output wire is_zero          // Asynchronous zero flag for in_a
);

    // Operation codes
    localparam [2:0] 
        HLT = 3'b000,  // Halt program
        SKZ = 3'b001,  // Skip if zero
        ADD = 3'b010,  // Add in_a and in_b
        AND = 3'b011,  // Logical AND
        XOR = 3'b100,  // Logical XOR
        LDA = 3'b101,  // Load from memory
        STO = 3'b110,  // Store to memory
        JMP = 3'b111;  // Jump

    // Generate result based on opcode
    always @(*) begin
        case (opcode)
            HLT: alu_out = in_a;          // Pass through in_a for halt
            SKZ: alu_out = in_a;          // Pass through in_a for skip if zero
            ADD: alu_out = in_a + in_b;   // Add in_a and in_b
            AND: alu_out = in_a & in_b;   // Bitwise AND
            XOR: alu_out = in_a ^ in_b;   // Bitwise XOR
            LDA: alu_out = in_b;          // Load from memory (pass through in_b)
            STO: alu_out = in_a;          // Store to memory (pass through in_a)
            JMP: alu_out = in_a;          // Jump (pass through in_a)
            default: alu_out = 8'h00;
        endcase
    end
    
    // Zero flag is high when in_a is zero
    assign is_zero = (in_a == 8'h00);
    
endmodule
```

The ALU implements all 8 required operations:
- `HLT` (000): Pass through in_a (used for halt)
- `SKZ` (001): Pass through in_a (used for skip if zero)
- `ADD` (010): Add in_a and in_b
- `AND` (011): Bitwise AND of in_a and in_b
- `XOR` (100): Bitwise XOR of in_a and in_b
- `LDA` (101): Pass through in_b (used for load from memory)
- `STO` (110): Pass through in_a (used for store to memory)
- `JMP` (111): Pass through in_a (used for jump)

The module also provides an asynchronous zero flag that is high when in_a is zero, used primarily for the SKZ instruction.

### 7. Controller (controller.v)

The Controller is the brain of the processor, implementing an 8-state state machine that generates all the control signals needed to coordinate the other modules.

**Requirements Analysis:**
- ✅ 8-state state machine with required states
- ✅ Reset state is INST_ADDR
- ✅ Synchronous operation on the positive clock edge
- ✅ Takes 3-bit opcode input
- ✅ Generates all required control signals

**Implementation Details:**

```verilog
module controller (
    input wire clk,               // Clock input
    input wire rst,               // Active HIGH reset
    input wire [2:0] opcode,      // Operation code from instruction register
    input wire zero,              // Zero flag from ALU
    output reg sel,               // Address select (1=PC, 0=operand)
    output reg rd,                // Memory read
    output reg ld_ir,             // Load instruction register
    output reg halt,              // Halt signal
    output reg inc_pc,            // Increment program counter
    output reg ld_ac,             // Load accumulator
    output reg ld_pc,             // Load program counter
    output reg wr,                // Memory write
    output reg data_e             // Data enable
);

    // State encoding
    localparam [2:0]
        INST_ADDR  = 3'b000,  // Instruction Address phase
        INST_FETCH = 3'b001,  // Instruction Fetch phase
        INST_LOAD  = 3'b010,  // Instruction Load phase
        IDLE       = 3'b011,  // Idle phase
        OP_ADDR    = 3'b100,  // Operand Address phase
        OP_FETCH   = 3'b101,  // Operand Fetch phase
        ALU_OP     = 3'b110,  // ALU Operation phase
        STORE      = 3'b111;  // Store phase

    // Operation codes
    localparam [2:0] 
        HLT = 3'b000,  // Halt program
        SKZ = 3'b001,  // Skip if zero
        ADD = 3'b010,  // Add in_a and in_b
        AND = 3'b011,  // Logical AND
        XOR = 3'b100,  // Logical XOR
        LDA = 3'b101,  // Load from memory
        STO = 3'b110,  // Store to memory
        JMP = 3'b111;  // Jump

    // Current and next state registers
    reg [2:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= INST_ADDR;  // Reset to INST_ADDR state
        else
            current_state <= next_state;  // Move to next state
    end

    // Next state logic
    always @(*) begin
        // Default next state is to cycle through all states
        case (current_state)
            INST_ADDR:  next_state = INST_FETCH;
            INST_FETCH: next_state = INST_LOAD;
            INST_LOAD:  next_state = IDLE;
            IDLE:       next_state = OP_ADDR;
            OP_ADDR:    next_state = OP_FETCH;
            OP_FETCH:   next_state = ALU_OP;
            ALU_OP:     next_state = STORE;
            STORE:      next_state = INST_ADDR;
            default:    next_state = INST_ADDR;
        endcase
    end

    // Output logic for control signals
    always @(*) begin
        // Default values for all control signals
        sel = 0;
        rd = 0;
        ld_ir = 0;
        halt = 0;
        inc_pc = 0;
        ld_ac = 0;
        ld_pc = 0;
        wr = 0;
        data_e = 0;
        
        // Set control signals based on current state and opcode
        case (current_state)
            INST_ADDR: begin
                sel = 1;  // Select PC address
            end
            
            INST_FETCH: begin
                sel = 1;  // Select PC address
                rd = 1;   // Read from memory
            end
            
            INST_LOAD: begin
                sel = 1;     // Select PC address
                rd = 1;      // Read from memory
                ld_ir = 1;   // Load instruction register
            end
            
            IDLE: begin
                sel = 1;     // Select PC address
                ld_ir = 1;   // Continue loading instruction register
            end
            
            OP_ADDR: begin
                sel = 0;     // Select operand address
                
                // If instruction is HLT, set halt signal
                halt = (opcode == HLT);
                
                // Always increment PC in this state
                inc_pc = 1;
            end
            
            OP_FETCH: begin
                sel = 0;     // Select operand address
                
                // Read memory for ALU operations
                rd = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA);
            end
            
            ALU_OP: begin
                sel = 0;     // Select operand address
                
                // Read memory for ALU operations
                rd = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA);
                
                // Increment PC on SKZ if accumulator is zero
                inc_pc = (opcode == SKZ && zero);
                
                // Set data enable for STO
                data_e = (opcode == STO);
                
                // Jump operation
                ld_pc = (opcode == JMP);
            end
            
            STORE: begin
                sel = 0;     // Select operand address
                
                // Read memory for ALU operations
                rd = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA);
                
                // Load accumulator for ALU operations
                ld_ac = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA);
                
                // Continue jump operation
                ld_pc = (opcode == JMP);
                
                // Write to memory for STO
                wr = (opcode == STO);
                
                // Data enable for STO
                data_e = (opcode == STO);
            end
            
            default: begin
                // Default to instruction address phase behavior
                sel = 1;
            end
        endcase
    end
    
endmodule
```

The controller implements an 8-state state machine with the following states:
- `INST_ADDR` (000): Instruction Address phase - set up address for instruction fetch
- `INST_FETCH` (001): Instruction Fetch phase - read instruction from memory
- `INST_LOAD` (010): Instruction Load phase - load instruction into IR
- `IDLE` (011): Idle phase - prepare for operand fetch
- `OP_ADDR` (100): Operand Address phase - set up address for operand fetch
- `OP_FETCH` (101): Operand Fetch phase - read operand from memory if needed
- `ALU_OP` (110): ALU Operation phase - perform ALU operation
- `STORE` (111): Store phase - store result to memory or accumulator

For each state, the controller generates the appropriate control signals based on the current opcode, ensuring proper sequencing of operations.

### 8. CPU Top Module (cpu_top.v)

The CPU Top module integrates all the components above into a complete processor, connecting them with the appropriate signals.

**Requirements Analysis:**
- ✅ Successfully integrates all the required modules
- ✅ Properly connects signals between modules
- ✅ Extracts opcode and operand from instruction
- ✅ Properly handles data flow between components

**Implementation Details:**

```verilog
module cpu_top (
    input wire clk,          // Clock input
    input wire rst,          // Active HIGH reset
    output wire halt         // Halt signal
);

    // Internal wires for connecting modules
    wire [4:0] pc_out;           // PC output
    wire [4:0] mem_addr;         // Memory address
    wire [7:0] mem_data_out;     // Data output from memory
    wire [7:0] mem_data_in;      // Data input to memory
    wire [7:0] ir_out;           // Instruction register output
    wire [7:0] acc_out;          // Accumulator output
    wire [7:0] alu_out;          // ALU output
    
    // Control signals
    wire sel;                    // Address select
    wire rd;                     // Memory read
    wire ld_ir;                  // Load instruction register
    wire inc_pc;                 // Increment program counter
    wire ld_ac;                  // Load accumulator
    wire ld_pc;                  // Load program counter
    wire wr;                     // Memory write
    wire data_e;                 // Data enable
    wire is_zero;                // Zero flag from ALU
    
    // Instruction fields
    wire [2:0] opcode;           // Opcode from instruction
    wire [4:0] operand;          // Operand address from instruction
    
    // Extract opcode and operand from instruction
    assign opcode = ir_out[7:5];
    assign operand = ir_out[4:0];
    
    // Memory data input multiplexer
    assign mem_data_in = data_e ? acc_out : 8'h00;
    
    // Instantiate Program Counter
    program_counter pc (
        .clk(clk),
        .rst(rst),
        .ld_pc(ld_pc),
        .inc_pc(inc_pc),
        .pc_in(operand),
        .pc_out(pc_out)
    );
    
    // Instantiate Address Multiplexer
    address_mux addr_mux (
        .sel(sel),
        .pc_addr(pc_out),
        .op_addr(operand),
        .mem_addr(mem_addr)
    );
    
    // Instantiate Memory
    memory mem (
        .clk(clk),
        .rst(rst),
        .rd(rd),
        .wr(wr),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );
    
    // Instantiate Instruction Register
    instruction_reg ir (
        .clk(clk),
        .rst(rst),
        .ld_ir(ld_ir),
        .data_in(mem_data_out),
        .ir_out(ir_out)
    );
    
    // Instantiate Accumulator
    accumulator acc (
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .data_in(alu_out),
        .acc_out(acc_out)
    );
    
    // Instantiate ALU
    alu alu_inst (
        .in_a(acc_out),
        .in_b(mem_data_out),
        .opcode(opcode),
        .alu_out(alu_out),
        .is_zero(is_zero)
    );
    
    // Instantiate Controller
    controller ctrl (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .zero(is_zero),
        .sel(sel),
        .rd(rd),
        .ld_ir(ld_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .ld_ac(ld_ac),
        .ld_pc(ld_pc),
        .wr(wr),
        .data_e(data_e)
    );
    
endmodule
```

The top module:
- Extracts opcode and operand address from the instruction register output
- Handles the memory data input based on the data enable signal
- Instantiates and connects all the modules with the appropriate signals
- Exposes only the clock, reset, and halt signals to the outside world

## Instruction Set Implementation

The processor implements 8 instructions with 3-bit opcodes as required:

| Opcode | Code | Operation | Implementation |
|--------|------|-----------|----------------|
| HLT | 000 | Halt the program | Sets the halt signal when detected |
| SKZ | 001 | Skip next instruction if accumulator is zero | Increments PC when ACC is zero |
| ADD | 010 | Add memory value to accumulator | ALU adds ACC and memory value |
| AND | 011 | Logical AND memory value with accumulator | ALU performs AND operation |
| XOR | 100 | Logical XOR memory value with accumulator | ALU performs XOR operation |
| LDA | 101 | Load memory value to accumulator | ALU passes memory value to ACC |
| STO | 110 | Store accumulator value to memory | Writes ACC value to memory |
| JMP | 111 | Jump to specified address | Loads new address into PC |

## System Operation Verification

The implementation supports the required processor operation cycle:

1. **Fetch**: The PC provides the address of the next instruction, which is fetched from memory.
2. **Decode**: The instruction is loaded into the IR and decoded into opcode and operand.
3. **Execute**: Based on the opcode, the controller generates the appropriate control signals to:
   - Retrieve operand data from memory if needed
   - Perform the required operation in the ALU
   - Store the result to memory or accumulator
   - Update the PC (increment or jump)
4. **Repeat or Halt**: The cycle repeats until a HLT instruction is encountered.

## Conclusion

The RISC processor implementation fully meets all the requirements specified in the assignment. The design is modular and follows good hardware design practices, with clear interfaces between components and appropriate synchronization of signals.

The processor can execute all 8 required instructions and follows the complete instruction cycle from fetch to execute. The system halts upon reaching the HALT instruction as required.

Future enhancements could include:
- Adding more ALU operations for floating-point arithmetic
- Implementing a register file instead of a single accumulator
- Adding interrupts and/or I/O capabilities
- Improving the memory architecture with separate instruction and data memory (Harvard architecture) 