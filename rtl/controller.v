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