// Debounce Module for Traffic Light Controller
// Debounces button inputs

module debounce(
    input clk_db,           // Debounce clock (100Hz)
    input rst,              // Active high reset
    input s0_in,            // S0 button input (Minor road emergency)
    input s1_in,            // S1 button input (Major road emergency)
    input s4_in,            // S4 button input (Reset)
    output reg s0_out,      // Debounced S0 (level)
    output reg s1_out,      // Debounced S1 (level)
    output reg s4_out       // Debounced S4 (pulse)
);

    // Shift registers for debouncing
    reg [2:0] s0_shift, s1_shift, s4_shift;
    
    // Previous state for edge detection
    reg s4_prev;
    reg s4_stable;

    // Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_shift <= 3'b000;
            s1_shift <= 3'b000;
            s4_shift <= 3'b000;
            s0_out <= 1'b0;
            s1_out <= 1'b0;
            s4_stable <= 1'b0;
        end
        else begin
            // Shift in new samples
            s0_shift <= {s0_shift[1:0], s0_in};
            s1_shift <= {s1_shift[1:0], s1_in};
            s4_shift <= {s4_shift[1:0], s4_in};
            
            // S0 and S1 output level (for emergency hold)
            if (s0_shift == 3'b111) s0_out <= 1'b1;
            else if (s0_shift == 3'b000) s0_out <= 1'b0;
            
            if (s1_shift == 3'b111) s1_out <= 1'b1;
            else if (s1_shift == 3'b000) s1_out <= 1'b0;
            
            // S4 stable state
            if (s4_shift == 3'b111) s4_stable <= 1'b1;
            else if (s4_shift == 3'b000) s4_stable <= 1'b0;
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
