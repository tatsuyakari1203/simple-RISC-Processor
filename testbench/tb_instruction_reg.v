module tb_instruction_reg;
    // Testbench signals
    reg clk;
    reg rst;
    reg ld_ir;
    reg [7:0] data_in;
    wire [7:0] ir_out;
    
    // Instantiate the instruction register
    instruction_reg dut (
        .clk(clk),
        .rst(rst),
        .ld_ir(ld_ir),
        .data_in(data_in),
        .ir_out(ir_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        ld_ir = 0;
        data_in = 8'h00;
        
        // Display header
        $display("Time\tRST\tLD_IR\tDATA_IN\tIR_OUT");
        
        // Apply reset
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ir, data_in, ir_out);
        
        // Release reset and test load
        rst = 0;
        data_in = {3'b101, 5'd10};  // LDA 10
        ld_ir = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ir, data_in, ir_out);
        
        // Change data without load enabled (should not affect IR)
        ld_ir = 0;
        data_in = {3'b010, 5'd15};  // ADD 15
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ir, data_in, ir_out);
        
        // Load new instruction
        ld_ir = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ir, data_in, ir_out);
        
        // Test reset overrides load
        rst = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ir, data_in, ir_out);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 