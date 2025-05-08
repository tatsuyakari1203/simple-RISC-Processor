module address_mux #(
    parameter ADDR_WIDTH = 5  // Default address width is 5 bits
)(
    input wire sel,                       // Select signal: 1 for PC, 0 for operand address
    input wire [ADDR_WIDTH-1:0] pc_addr,  // Address from Program Counter
    input wire [ADDR_WIDTH-1:0] op_addr,  // Operand address from instruction
    output wire [ADDR_WIDTH-1:0] mem_addr // Address output to memory
);

    // Multiplex between PC address and operand address
    assign mem_addr = sel ? pc_addr : op_addr;
    
endmodule 