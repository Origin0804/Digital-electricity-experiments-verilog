// Debounce Module for Multi-function Digital Clock
// Debounces button inputs S3 (mode), S4 (inc) and en switch

module debounce(
    input clk_db,           // Debounce clock (100Hz)
    input rst,              // Active high reset
    input s3_in,            // S3 button input (Mode)
    input s4_in,            // S4 button input (Increment)
    input en_in,            // EN switch input (Pause)
    output reg s3_out,      // Debounced S3 (pulse)
    output reg s4_out,      // Debounced S4 (pulse)
    output reg en_out       // Debounced EN (level)
);

    // Shift registers for debouncing (3-bit for buttons)
    reg [2:0] s3_shift, s4_shift;
    reg [2:0] en_shift;
    
    // Previous state for edge detection
    reg s3_prev, s4_prev;
    
    // Debounced stable values
    reg s3_stable, s4_stable;

    // Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s3_shift <= 3'b000;
            s4_shift <= 3'b000;
            en_shift <= 3'b000;
            s3_stable <= 1'b0;
            s4_stable <= 1'b0;
            en_out <= 1'b0;
        end
        else begin
            // Shift in new samples
            s3_shift <= {s3_shift[1:0], s3_in};
            s4_shift <= {s4_shift[1:0], s4_in};
            en_shift <= {en_shift[1:0], en_in};
            
            // Check for stable high (all 1s)
            if (s3_shift == 3'b111) s3_stable <= 1'b1;
            else if (s3_shift == 3'b000) s3_stable <= 1'b0;
            
            if (s4_shift == 3'b111) s4_stable <= 1'b1;
            else if (s4_shift == 3'b000) s4_stable <= 1'b0;
            
            // EN is a switch, output level (not pulse)
            if (en_shift == 3'b111) en_out <= 1'b1;
            else if (en_shift == 3'b000) en_out <= 1'b0;
        end
    end

    // Edge detection for pulse output
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s3_prev <= 1'b0;
            s4_prev <= 1'b0;
            s3_out <= 1'b0;
            s4_out <= 1'b0;
        end
        else begin
            s3_prev <= s3_stable;
            s4_prev <= s4_stable;
            
            // Rising edge detection (button press)
            s3_out <= s3_stable & ~s3_prev;
            s4_out <= s4_stable & ~s4_prev;
        end
    end

endmodule
