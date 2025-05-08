module accumulator (
    input wire clk,           // Clock input
    input wire rst,           // Active HIGH reset
    input wire ld_ac,         // Load enable for accumulator
    input wire [7:0] data_in, // Data input from ALU
    output reg [7:0] acc_out  // Accumulator output
);

    // Accumulator register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset accumulator to 0
            acc_out <= 8'h00;
        end else if (ld_ac) begin
            // Load new value into accumulator
            acc_out <= data_in;
        end
        // Otherwise, maintain current value
    end
    
endmodule 