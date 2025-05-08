module tb_accumulator;
    // Testbench signals
    reg clk;
    reg rst;
    reg ld_ac;
    reg [7:0] data_in;
    wire [7:0] acc_out;
    
    // Instantiate the accumulator
    accumulator dut (
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .data_in(data_in),
        .acc_out(acc_out)
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
        ld_ac = 0;
        data_in = 8'h00;
        
        // Display header
        $display("Time\tRST\tLD_AC\tDATA_IN\tACC_OUT");
        
        // Apply reset
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ac, data_in, acc_out);
        
        // Release reset and test load
        rst = 0;
        data_in = 8'hA5;
        ld_ac = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ac, data_in, acc_out);
        
        // Change data without load enabled (should not affect accumulator)
        ld_ac = 0;
        data_in = 8'h5A;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ac, data_in, acc_out);
        
        // Load new value
        ld_ac = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ac, data_in, acc_out);
        
        // Test reset overrides load
        rst = 1;
        #10;
        $display("%0t\t%b\t%b\t%h\t%h", $time, rst, ld_ac, data_in, acc_out);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 