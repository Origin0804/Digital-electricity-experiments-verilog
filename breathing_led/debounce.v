// Debounce Module for Breathing LED
// Debounces button inputs

module debounce(
    input clk_db,           // Debounce clock (100Hz)
    input rst,              // Active high reset
    input s4_in,            // S4 button input (Reset)
    input mode_in,          // Mode switch input
    output reg s4_out,      // Debounced S4 (pulse)
    output reg mode_out     // Debounced mode (level)
);

    // Shift registers for debouncing
    reg [2:0] s4_shift, mode_shift;
    
    // Previous state for edge detection
    reg s4_prev;
    reg s4_stable;

    // Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s4_shift <= 3'b000;
            mode_shift <= 3'b000;
            s4_stable <= 1'b0;
            mode_out <= 1'b0;
        end
        else begin
            // Shift in new samples
            s4_shift <= {s4_shift[1:0], s4_in};
            mode_shift <= {mode_shift[1:0], mode_in};
            
            // S4 stable state
            if (s4_shift == 3'b111) s4_stable <= 1'b1;
            else if (s4_shift == 3'b000) s4_stable <= 1'b0;
            
            // Mode is a switch, output level
            if (mode_shift == 3'b111) mode_out <= 1'b1;
            else if (mode_shift == 3'b000) mode_out <= 1'b0;
        end
    end

    // Edge detection for S4 pulse output
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s4_prev <= 1'b0;
            s4_out <= 1'b0;
        end
        else begin
            s4_prev <= s4_stable;
            s4_out <= s4_stable & ~s4_prev;
        end
    end

endmodule
