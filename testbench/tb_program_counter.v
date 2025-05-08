module tb_program_counter;
    // Testbench signals
    reg clk;
    reg rst;
    reg ld_pc;
    reg inc_pc;
    reg [4:0] pc_in;
    wire [4:0] pc_out;
    
    // Instantiate the program counter
    program_counter dut (
        .clk(clk),
        .rst(rst),
        .ld_pc(ld_pc),
        .inc_pc(inc_pc),
        .pc_in(pc_in),
        .pc_out(pc_out)
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
        ld_pc = 0;
        inc_pc = 0;
        pc_in = 5'b0;
        
        // Display header
        $display("Time\tRST\tLD\tINC\tPC_IN\tPC_OUT");
        
        // Apply reset
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // Release reset and test increment
        rst = 0;
        #10;
        inc_pc = 1;
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // Test load
        inc_pc = 0;
        ld_pc = 1;
        pc_in = 5'd15;
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // Test increment after load
        ld_pc = 0;
        inc_pc = 1;
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // Test priority (load has priority over increment)
        ld_pc = 1;
        inc_pc = 1;
        pc_in = 5'd7;
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // Test reset overrides all
        rst = 1;
        #10;
        $display("%0t\t%b\t%b\t%b\t%d\t%d", $time, rst, ld_pc, inc_pc, pc_in, pc_out);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 