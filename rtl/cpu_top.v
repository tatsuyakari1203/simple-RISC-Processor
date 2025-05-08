module cpu_top (
    input wire clk,          // Clock input
    input wire rst,          // Active HIGH reset
    output wire halt         // Halt signal
);

    // Internal wires for connecting modules
    wire [4:0] pc_out;           // PC output
    wire [4:0] mem_addr;         // Memory address
    wire [7:0] mem_data_out;     // Data output from memory
    wire [7:0] mem_data_in;      // Data input to memory
    wire [7:0] ir_out;           // Instruction register output
    wire [7:0] acc_out;          // Accumulator output
    wire [7:0] alu_out;          // ALU output
    
    // Control signals
    wire sel;                    // Address select
    wire rd;                     // Memory read
    wire ld_ir;                  // Load instruction register
    wire inc_pc;                 // Increment program counter
    wire ld_ac;                  // Load accumulator
    wire ld_pc;                  // Load program counter
    wire wr;                     // Memory write
    wire data_e;                 // Data enable
    wire is_zero;                // Zero flag from ALU
    
    // Instruction fields
    wire [2:0] opcode;           // Opcode from instruction
    wire [4:0] operand;          // Operand address from instruction
    
    // Extract opcode and operand from instruction
    assign opcode = ir_out[7:5];
    assign operand = ir_out[4:0];
    
    // Memory data input multiplexer
    assign mem_data_in = data_e ? acc_out : 8'h00;
    
    // Instantiate Program Counter
    program_counter pc (
        .clk(clk),
        .rst(rst),
        .ld_pc(ld_pc),
        .inc_pc(inc_pc),
        .pc_in(operand),
        .pc_out(pc_out)
    );
    
    // Instantiate Address Multiplexer
    address_mux addr_mux (
        .sel(sel),
        .pc_addr(pc_out),
        .op_addr(operand),
        .mem_addr(mem_addr)
    );
    
    // Instantiate Memory
    memory mem (
        .clk(clk),
        .rst(rst),
        .rd(rd),
        .wr(wr),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );
    
    // Instantiate Instruction Register
    instruction_reg ir (
        .clk(clk),
        .rst(rst),
        .ld_ir(ld_ir),
        .data_in(mem_data_out),
        .ir_out(ir_out)
    );
    
    // Instantiate Accumulator
    accumulator acc (
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .data_in(alu_out),
        .acc_out(acc_out)
    );
    
    // Instantiate ALU
    alu alu_inst (
        .in_a(acc_out),
        .in_b(mem_data_out),
        .opcode(opcode),
        .alu_out(alu_out),
        .is_zero(is_zero)
    );
    
    // Instantiate Controller
    controller ctrl (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .zero(is_zero),
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
    
endmodule 