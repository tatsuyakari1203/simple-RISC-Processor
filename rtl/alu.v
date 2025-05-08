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