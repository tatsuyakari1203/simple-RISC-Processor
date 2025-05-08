module tb_alu;
    // Testbench signals
    reg [7:0] in_a;
    reg [7:0] in_b;
    reg [2:0] opcode;
    wire [7:0] alu_out;
    wire is_zero;
    
    // Instantiate the ALU
    alu dut (
        .in_a(in_a),
        .in_b(in_b),
        .opcode(opcode),
        .alu_out(alu_out),
        .is_zero(is_zero)
    );
    
    // Constants for opcodes
    localparam [2:0] 
        HLT = 3'b000,  // Halt program
        SKZ = 3'b001,  // Skip if zero
        ADD = 3'b010,  // Add in_a and in_b
        AND = 3'b011,  // Logical AND
        XOR = 3'b100,  // Logical XOR
        LDA = 3'b101,  // Load from memory
        STO = 3'b110,  // Store to memory
        JMP = 3'b111;  // Jump
    
    // Test sequence
    initial begin
        // Initialize signals
        in_a = 8'h00;
        in_b = 8'h00;
        opcode = HLT;
        
        // Display header
        $display("Time\tOP\tIN_A\tIN_B\tALU_OUT\tIS_ZERO");
        
        // Test HLT opcode (pass through in_a)
        in_a = 8'h5A;
        in_b = 8'hA5;
        opcode = HLT;
        #10;
        $display("%0t\tHLT\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test SKZ opcode (pass through in_a)
        opcode = SKZ;
        #10;
        $display("%0t\tSKZ\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test ADD opcode
        opcode = ADD;
        #10;
        $display("%0t\tADD\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test AND opcode
        opcode = AND;
        #10;
        $display("%0t\tAND\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test XOR opcode
        opcode = XOR;
        #10;
        $display("%0t\tXOR\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test LDA opcode (pass through in_b)
        opcode = LDA;
        #10;
        $display("%0t\tLDA\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test STO opcode (pass through in_a)
        opcode = STO;
        #10;
        $display("%0t\tSTO\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test JMP opcode (pass through in_a)
        opcode = JMP;
        #10;
        $display("%0t\tJMP\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // Test zero detection
        in_a = 8'h00;
        opcode = HLT;
        #10;
        $display("%0t\tHLT\t%h\t%h\t%h\t%b", $time, in_a, in_b, alu_out, is_zero);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 