module memory (
    input wire clk,           // Clock input
    input wire rst,           // Reset signal
    input wire rd,            // Read enable
    input wire wr,            // Write enable
    input wire [4:0] addr,    // 5-bit address (32 memory locations)
    input wire [7:0] data_in, // 8-bit input data
    output reg [7:0] data_out // 8-bit output data
);

    // Memory array: 32 locations x 8 bits
    reg [7:0] mem [0:31];
    
    integer i;
    
    // Read and write operations with synchronous reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize memory to 0 on reset
            for (i = 0; i < 32; i = i + 1) begin
                mem[i] <= 8'h00;
            end
            data_out <= 8'h00;
        end else begin
            // Memory operations
            if (rd) begin
                data_out <= mem[addr];
            end
            
            if (wr) begin
                mem[addr] <= data_in;
            end
        end
    end
    
endmodule 