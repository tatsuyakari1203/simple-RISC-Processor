module instruction_reg (
    input wire clk,           // Clock input
    input wire rst,           // Active HIGH reset
    input wire ld_ir,         // Load enable for instruction register
    input wire [7:0] data_in, // Instruction data from memory
    output reg [7:0] ir_out   // Instruction register output
);

    // Instruction register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset instruction register to 0
            ir_out <= 8'h00;
        end else if (ld_ir) begin
            // Load new instruction
            ir_out <= data_in;
        end
        // Otherwise, maintain current instruction
    end
    
endmodule 