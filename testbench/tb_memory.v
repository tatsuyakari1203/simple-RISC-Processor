module tb_memory;
    // Testbench signals
    reg clk;
    reg rst;
    reg rd;
    reg wr;
    reg [4:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;
    
    // Instantiate the memory
    memory dut (
        .clk(clk),
        .rst(rst),
        .rd(rd),
        .wr(wr),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
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
        rd = 0;
        wr = 0;
        addr = 5'h00;
        data_in = 8'h00;
        
        // Display header
        $display("Time\tRST\tRD\tWR\tADDR\tDATA_IN\tDATA_OUT");
        
        // Apply reset for a few clock cycles
        repeat (3) @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // Release reset and write to a few addresses
        rst = 0;
        @(posedge clk);
        
        // Write to address 5
        addr = 5'h05;
        data_in = 8'hA5;
        wr = 1;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        wr = 0;
        
        // Write to address 10
        addr = 5'h0A;
        data_in = {3'b101, 5'd10};  // Instruction LDA 10
        wr = 1;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        wr = 0;
        
        // Read from address 5
        addr = 5'h05;
        rd = 1;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // Read from address 10
        addr = 5'h0A;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // Read from uninitialized address
        addr = 5'h0F;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // Test simultaneous read and write (write should take precedence)
        addr = 5'h15;
        data_in = 8'h55;
        rd = 1;
        wr = 1;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // Read the same address to verify the write
        wr = 0;
        @(posedge clk);
        $display("%0t\t%b\t%b\t%b\t%h\t%h\t%h", $time, rst, rd, wr, addr, data_in, data_out);
        
        // End simulation
        rd = 0;
        #10 $finish;
    end
    
endmodule 