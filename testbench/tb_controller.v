module tb_controller;
    // Testbench signals
    reg clk;
    reg rst;
    reg [2:0] opcode;
    reg zero;
    wire sel;
    wire rd;
    wire ld_ir;
    wire halt;
    wire inc_pc;
    wire ld_ac;
    wire ld_pc;
    wire wr;
    wire data_e;
    
    // Instantiate the controller
    controller dut (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .zero(zero),
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
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end
    
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
    
    // Constants for states
    localparam [2:0]
        INST_ADDR  = 3'b000,  // Instruction Address phase
        INST_FETCH = 3'b001,  // Instruction Fetch phase
        INST_LOAD  = 3'b010,  // Instruction Load phase
        IDLE       = 3'b011,  // Idle phase
        OP_ADDR    = 3'b100,  // Operand Address phase
        OP_FETCH   = 3'b101,  // Operand Fetch phase
        ALU_OP     = 3'b110,  // ALU Operation phase
        STORE      = 3'b111;  // Store phase
    
    // Monitor controller state and outputs
    task display_state;
        input [2:0] state;
        begin
            case (state)
                INST_ADDR:  $write("INST_ADDR");
                INST_FETCH: $write("INST_FETCH");
                INST_LOAD:  $write("INST_LOAD");
                IDLE:       $write("IDLE");
                OP_ADDR:    $write("OP_ADDR");
                OP_FETCH:   $write("OP_FETCH");
                ALU_OP:     $write("ALU_OP");
                STORE:      $write("STORE");
                default:    $write("UNKNOWN");
            endcase
        end
    endtask
    
    // Display opcode as string
    task display_opcode;
        input [2:0] op;
        begin
            case (op)
                HLT: $write("HLT");
                SKZ: $write("SKZ");
                ADD: $write("ADD");
                AND: $write("AND");
                XOR: $write("XOR");
                LDA: $write("LDA");
                STO: $write("STO");
                JMP: $write("JMP");
                default: $write("UNK");
            endcase
        end
    endtask
    
    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        opcode = ADD;  // Default opcode
        zero = 0;      // Zero flag not set
        
        // Display header
        $display("Time\tState\tOpcode\tZero\tsel\trd\tld_ir\thalt\tinc_pc\tld_ac\tld_pc\twr\tdata_e");
        
        // Apply reset for a few clock cycles
        repeat (2) @(posedge clk);
        
        // Print initial state
        $write("%0t\t", $time);
        display_state(dut.current_state);
        $write("\t");
        display_opcode(opcode);
        $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        
        // Release reset and watch state transitions for ADD instruction
        rst = 0;
        opcode = ADD;
        
        // Cycle through all states (8 cycles)
        repeat (8) begin
            @(posedge clk);
            $write("%0t\t", $time);
            display_state(dut.current_state);
            $write("\t");
            display_opcode(opcode);
            $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                    zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        end
        
        // Test HLT opcode
        opcode = HLT;
        
        // Cycle through all states
        repeat (8) begin
            @(posedge clk);
            $write("%0t\t", $time);
            display_state(dut.current_state);
            $write("\t");
            display_opcode(opcode);
            $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                    zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        end
        
        // Test SKZ opcode with zero flag set
        opcode = SKZ;
        zero = 1;
        
        // Cycle through all states
        repeat (8) begin
            @(posedge clk);
            $write("%0t\t", $time);
            display_state(dut.current_state);
            $write("\t");
            display_opcode(opcode);
            $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                    zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        end
        
        // Test STO opcode
        opcode = STO;
        zero = 0;
        
        // Cycle through all states
        repeat (8) begin
            @(posedge clk);
            $write("%0t\t", $time);
            display_state(dut.current_state);
            $write("\t");
            display_opcode(opcode);
            $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                    zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        end
        
        // Test JMP opcode
        opcode = JMP;
        
        // Cycle through all states
        repeat (8) begin
            @(posedge clk);
            $write("%0t\t", $time);
            display_state(dut.current_state);
            $write("\t");
            display_opcode(opcode);
            $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                    zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        end
        
        // Test reset during execution
        rst = 1;
        @(posedge clk);
        $write("%0t\t", $time);
        display_state(dut.current_state);
        $write("\t");
        display_opcode(opcode);
        $display("\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 