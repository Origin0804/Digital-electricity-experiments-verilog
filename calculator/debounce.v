// Debounce Module for Simple Calculator
// Debounces button inputs

module debounce(
    input clk_db,           // Debounce clock (100Hz)
    input rst,              // Active high reset
    input s0_in,            // S0 button input (Clear)
    input s1_in,            // S1 button input (Add)
    input s2_in,            // S2 button input (Subtract)
    input s3_in,            // S3 button input (Multiply)
    input s4_in,            // S4 button input (Enter/Equals)
    input [7:0] sw_in,      // SW0-SW7 for number input
    output reg s0_out,      // Debounced S0 (pulse)
    output reg s1_out,      // Debounced S1 (pulse)
    output reg s2_out,      // Debounced S2 (pulse)
    output reg s3_out,      // Debounced S3 (pulse)
    output reg s4_out,      // Debounced S4 (pulse)
    output reg [7:0] sw_out // Debounced SW (level)
);

    // Shift registers for debouncing
    reg [2:0] s0_shift, s1_shift, s2_shift, s3_shift, s4_shift;
    reg [2:0] sw_shift [7:0];
    
    // Previous state for edge detection
    reg s0_prev, s1_prev, s2_prev, s3_prev, s4_prev;
    
    // Debounced stable values
    reg s0_stable, s1_stable, s2_stable, s3_stable, s4_stable;

    integer i;

    // Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_shift <= 3'b000; s1_shift <= 3'b000;
            s2_shift <= 3'b000; s3_shift <= 3'b000;
            s4_shift <= 3'b000;
            for (i = 0; i < 8; i = i + 1)
                sw_shift[i] <= 3'b000;
            s0_stable <= 1'b0; s1_stable <= 1'b0;
            s2_stable <= 1'b0; s3_stable <= 1'b0;
            s4_stable <= 1'b0;
            sw_out <= 8'b0;
        end
        else begin
            // Shift in new samples
            s0_shift <= {s0_shift[1:0], s0_in};
            s1_shift <= {s1_shift[1:0], s1_in};
            s2_shift <= {s2_shift[1:0], s2_in};
            s3_shift <= {s3_shift[1:0], s3_in};
            s4_shift <= {s4_shift[1:0], s4_in};
            for (i = 0; i < 8; i = i + 1)
                sw_shift[i] <= {sw_shift[i][1:0], sw_in[i]};
            
            // Check for stable high
            if (s0_shift == 3'b111) s0_stable <= 1'b1;
            else if (s0_shift == 3'b000) s0_stable <= 1'b0;
            
            if (s1_shift == 3'b111) s1_stable <= 1'b1;
            else if (s1_shift == 3'b000) s1_stable <= 1'b0;
            
            if (s2_shift == 3'b111) s2_stable <= 1'b1;
            else if (s2_shift == 3'b000) s2_stable <= 1'b0;
            
            if (s3_shift == 3'b111) s3_stable <= 1'b1;
            else if (s3_shift == 3'b000) s3_stable <= 1'b0;
            
            if (s4_shift == 3'b111) s4_stable <= 1'b1;
            else if (s4_shift == 3'b000) s4_stable <= 1'b0;
            
            // Switches output level
            for (i = 0; i < 8; i = i + 1) begin
                if (sw_shift[i] == 3'b111) sw_out[i] <= 1'b1;
                else if (sw_shift[i] == 3'b000) sw_out[i] <= 1'b0;
            end
        end
    end

    // Edge detection for pulse output
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_prev <= 1'b0; s1_prev <= 1'b0;
            s2_prev <= 1'b0; s3_prev <= 1'b0;
            s4_prev <= 1'b0;
            s0_out <= 1'b0; s1_out <= 1'b0;
            s2_out <= 1'b0; s3_out <= 1'b0;
            s4_out <= 1'b0;
        end
        else begin
            s0_prev <= s0_stable;
            s1_prev <= s1_stable;
            s2_prev <= s2_stable;
            s3_prev <= s3_stable;
            s4_prev <= s4_stable;
            
            s0_out <= s0_stable & ~s0_prev;
            s1_out <= s1_stable & ~s1_prev;
            s2_out <= s2_stable & ~s2_prev;
            s3_out <= s3_stable & ~s3_prev;
            s4_out <= s4_stable & ~s4_prev;
        end
    end

endmodule
