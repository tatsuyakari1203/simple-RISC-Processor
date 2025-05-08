module tb_address_mux;
    // Testbench signals
    reg sel;
    reg [4:0] pc_addr;
    reg [4:0] op_addr;
    wire [4:0] mem_addr;
    
    // Instantiate the address multiplexer
    address_mux dut (
        .sel(sel),
        .pc_addr(pc_addr),
        .op_addr(op_addr),
        .mem_addr(mem_addr)
    );
    
    // Test sequence
    initial begin
        // Initialize signals
        sel = 0;
        pc_addr = 5'h0A;  // 10
        op_addr = 5'h14;  // 20
        
        // Display header
        $display("Time\tSEL\tPC_ADDR\tOP_ADDR\tMEM_ADDR");
        
        // Test select = 0 (select operand address)
        #10;
        $display("%0t\t%b\t%h\t%h\t%h", $time, sel, pc_addr, op_addr, mem_addr);
        
        // Test select = 1 (select PC address)
        sel = 1;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h", $time, sel, pc_addr, op_addr, mem_addr);
        
        // Change addresses and test again
        pc_addr = 5'h1F;  // 31
        op_addr = 5'h03;  // 3
        #10;
        $display("%0t\t%b\t%h\t%h\t%h", $time, sel, pc_addr, op_addr, mem_addr);
        
        // Switch selection again
        sel = 0;
        #10;
        $display("%0t\t%b\t%h\t%h\t%h", $time, sel, pc_addr, op_addr, mem_addr);
        
        // End simulation
        #10 $finish;
    end
    
endmodule 