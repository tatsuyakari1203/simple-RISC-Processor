// Simple test program for the RISC processor
// This program:
// 1. Loads a value from memory location 10
// 2. Adds a value from memory location 11
// 3. Stores the result to memory location 12
// 4. Loads a value from memory location 13
// 5. ANDs it with the value in memory location 14
// 6. Stores the result to memory location 15
// 7. Jumps to location 20
// 8. At location 20, loads a value from memory location 16
// 9. XORs it with the value in memory location 17
// 10. Stores the result to memory location 18
// 11. Halts

module test_program;

// VCD dump for EPWave
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end

// Memory initialization task
task initialize_memory;
    output [7:0] mem [0:31];
    begin
        // Instructions
        // Address 0: LDA 10 (Load from address 10)
        mem[0] = {3'b101, 5'd10};  // 101 (LDA) + addr 10
        
        // Address 1: ADD 11 (Add value from address 11)
        mem[1] = {3'b010, 5'd11};  // 010 (ADD) + addr 11
        
        // Address 2: STO 12 (Store to address 12)
        mem[2] = {3'b110, 5'd12};  // 110 (STO) + addr 12
        
        // Address 3: LDA 13 (Load from address 13)
        mem[3] = {3'b101, 5'd13};  // 101 (LDA) + addr 13
        
        // Address 4: AND 14 (AND with value from address 14)
        mem[4] = {3'b011, 5'd14};  // 011 (AND) + addr 14
        
        // Address 5: STO 15 (Store to address 15)
        mem[5] = {3'b110, 5'd15};  // 110 (STO) + addr 15
        
        // Address 6: JMP 20 (Jump to address 20)
        mem[6] = {3'b111, 5'd20};  // 111 (JMP) + addr 20
        
        // Address 7: HLT (Should be skipped due to jump)
        mem[7] = {3'b000, 5'd0};   // 000 (HLT)
        
        // More instructions at jump target
        // Address 20: LDA 16 (Load from address 16)
        mem[20] = {3'b101, 5'd16}; // 101 (LDA) + addr 16
        
        // Address 21: XOR 17 (XOR with value from address 17)
        mem[21] = {3'b100, 5'd17}; // 100 (XOR) + addr 17
        
        // Address 22: STO 18 (Store to address 18)
        mem[22] = {3'b110, 5'd18}; // 110 (STO) + addr 18
        
        // Address 23: HLT (Halt)
        mem[23] = {3'b000, 5'd0};  // 000 (HLT)
        
        // Data values
        mem[10] = 8'd5;            // Value 5 at address 10
        mem[11] = 8'd10;           // Value 10 at address 11
        mem[13] = 8'hF0;           // Value F0 at address 13
        mem[14] = 8'h0F;           // Value 0F at address 14
        mem[16] = 8'hAA;           // Value AA at address 16
        mem[17] = 8'h55;           // Value 55 at address 17
        
        // Expected results after execution:
        // mem[12] = 15 (5 + 10)
        // mem[15] = 0 (F0 & 0F)
        // mem[18] = FF (AA ^ 55)
    end
endtask

endmodule 