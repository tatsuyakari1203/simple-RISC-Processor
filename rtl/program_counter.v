module program_counter (
    input wire clk,          // Clock input
    input wire rst,          // Active HIGH reset
    input wire ld_pc,        // Load signal for jumps
    input wire inc_pc,       // Increment signal
    input wire [4:0] pc_in,  // Input for jump address
    output reg [4:0] pc_out  // Current program counter value
);

    // Sequential logic for the program counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset PC to 0
            pc_out <= 5'b0;
        end else if (ld_pc) begin
            // Load new address for jumps
            pc_out <= pc_in;
        end else if (inc_pc) begin
            // Increment PC
            pc_out <= pc_out + 5'b1;
        end
        // If neither ld_pc nor inc_pc is active, PC remains unchanged
    end
    
endmodule 