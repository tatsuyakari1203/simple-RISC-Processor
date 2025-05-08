module tb_cpu_top;
    // Testbench signals
    reg clk;
    reg rst;
    wire halt;
    
    // Instantiate the CPU
    cpu_top dut (
        .clk(clk),
        .rst(rst),
        .halt(halt)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        
        // Load test program into memory
        // This is a comprehensive program that:
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
        
        // Instructions
        // Address 0: LDA 10 (Load from address 10)
        dut.mem.mem[0] = {3'b101, 5'd10};  // 101 (LDA) + addr 10
        
        // Address 1: ADD 11 (Add value from address 11)
        dut.mem.mem[1] = {3'b010, 5'd11};  // 010 (ADD) + addr 11
        
        // Address 2: STO 12 (Store to address 12)
        dut.mem.mem[2] = {3'b110, 5'd12};  // 110 (STO) + addr 12
        
        // Address 3: LDA 13 (Load from address 13)
        dut.mem.mem[3] = {3'b101, 5'd13};  // 101 (LDA) + addr 13
        
        // Address 4: AND 14 (AND with value from address 14)
        dut.mem.mem[4] = {3'b011, 5'd14};  // 011 (AND) + addr 14
        
        // Address 5: STO 15 (Store to address 15)
        dut.mem.mem[5] = {3'b110, 5'd15};  // 110 (STO) + addr 15
        
        // Address 6: JMP 20 (Jump to address 20)
        dut.mem.mem[6] = {3'b111, 5'd20};  // 111 (JMP) + addr 20
        
        // Address 7: HLT (Should be skipped due to jump)
        dut.mem.mem[7] = {3'b000, 5'd0};   // 000 (HLT)
        
        // More instructions at jump target
        // Address 20: LDA 16 (Load from address 16)
        dut.mem.mem[20] = {3'b101, 5'd16}; // 101 (LDA) + addr 16
        
        // Address 21: XOR 17 (XOR with value from address 17)
        dut.mem.mem[21] = {3'b100, 5'd17}; // 100 (XOR) + addr 17
        
        // Address 22: STO 18 (Store to address 18)
        dut.mem.mem[22] = {3'b110, 5'd18}; // 110 (STO) + addr 18
        
        // Address 23: HLT (Halt)
        dut.mem.mem[23] = {3'b000, 5'd0};  // 000 (HLT)
        
        // Data values
        dut.mem.mem[10] = 8'd5;            // Value 5 at address 10
        dut.mem.mem[11] = 8'd10;           // Value 10 at address 11
        dut.mem.mem[13] = 8'hF0;           // Value F0 at address 13
        dut.mem.mem[14] = 8'h0F;           // Value 0F at address 14
        dut.mem.mem[16] = 8'hAA;           // Value AA at address 16
        dut.mem.mem[17] = 8'h55;           // Value 55 at address 17
        
        // Apply reset for a few clock cycles
        repeat (3) @(posedge clk);
        rst = 0;
        
        // Run until halt or timeout
        repeat (500) begin  // Extended timeout for longer program
            @(posedge clk);
            if (halt) begin
                $display("CPU halted!");
                break;
            end
        end
        
        // Check results
        $display("Final results:");
        $display("Memory[12] = %h (Expected: 0F = 5 + 10)", dut.mem.mem[12]);
        $display("Memory[15] = %h (Expected: 00 = F0 & 0F)", dut.mem.mem[15]);
        $display("Memory[18] = %h (Expected: FF = AA ^ 55)", dut.mem.mem[18]);
        
        // Verify all results
        if (dut.mem.mem[12] == 8'h0F && dut.mem.mem[15] == 8'h00 && dut.mem.mem[18] == 8'hFF)
            $display("TEST PASSED: All results are correct!");
        else
            $display("TEST FAILED: One or more results are incorrect!");
        
        // End simulation
        #20 $finish;
    end
    
    // Monitor CPU state
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0t, State=%0d, PC=%0d, IR=%b, ACC=%0d", 
                     $time, dut.ctrl.current_state, dut.pc_out, dut.ir_out, dut.acc_out);
        end
    end
    
endmodule 