// Debounce Module for Ticket Machine
// Debounces button inputs and switch inputs

module debounce(
    input clk_db,           // Debounce clock (100Hz)
    input rst,              // Active high reset
    input s0_in,            // S0 button input (Clear sales)
    input s1_in,            // S1 button input (Insert 1 yuan)
    input s2_in,            // S2 button input (Insert 5 yuan)
    input s3_in,            // S3 button input (Insert 10 yuan)
    input [3:0] sw_in,      // SW0-SW3 for ticket selection
    input sw7_in,           // SW7 for confirm transaction
    output reg s0_out,      // Debounced S0 (pulse)
    output reg s1_out,      // Debounced S1 (pulse)
    output reg s2_out,      // Debounced S2 (pulse)
    output reg s3_out,      // Debounced S3 (pulse)
    output reg [3:0] sw_out,// Debounced SW0-SW3 (level)
    output reg sw7_out      // Debounced SW7 (level)
);

    // Shift registers for debouncing
    reg [2:0] s0_shift, s1_shift, s2_shift, s3_shift;
    reg [2:0] sw0_shift, sw1_shift, sw2_shift, sw3_shift, sw7_shift;
    
    // Previous state for edge detection
    reg s0_prev, s1_prev, s2_prev, s3_prev;
    
    // Debounced stable values
    reg s0_stable, s1_stable, s2_stable, s3_stable;

    // Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_shift <= 3'b000; s1_shift <= 3'b000;
            s2_shift <= 3'b000; s3_shift <= 3'b000;
            sw0_shift <= 3'b000; sw1_shift <= 3'b000;
            sw2_shift <= 3'b000; sw3_shift <= 3'b000;
            sw7_shift <= 3'b000;
            s0_stable <= 1'b0; s1_stable <= 1'b0;
            s2_stable <= 1'b0; s3_stable <= 1'b0;
            sw_out <= 4'b0000;
            sw7_out <= 1'b0;
        end
        else begin
            // Shift in new samples
            s0_shift <= {s0_shift[1:0], s0_in};
            s1_shift <= {s1_shift[1:0], s1_in};
            s2_shift <= {s2_shift[1:0], s2_in};
            s3_shift <= {s3_shift[1:0], s3_in};
            sw0_shift <= {sw0_shift[1:0], sw_in[0]};
            sw1_shift <= {sw1_shift[1:0], sw_in[1]};
            sw2_shift <= {sw2_shift[1:0], sw_in[2]};
            sw3_shift <= {sw3_shift[1:0], sw_in[3]};
            sw7_shift <= {sw7_shift[1:0], sw7_in};
            
            // Check for stable high
            if (s0_shift == 3'b111) s0_stable <= 1'b1;
            else if (s0_shift == 3'b000) s0_stable <= 1'b0;
            
            if (s1_shift == 3'b111) s1_stable <= 1'b1;
            else if (s1_shift == 3'b000) s1_stable <= 1'b0;
            
            if (s2_shift == 3'b111) s2_stable <= 1'b1;
            else if (s2_shift == 3'b000) s2_stable <= 1'b0;
            
            if (s3_shift == 3'b111) s3_stable <= 1'b1;
            else if (s3_shift == 3'b000) s3_stable <= 1'b0;
            
            // Switches output level
            if (sw0_shift == 3'b111) sw_out[0] <= 1'b1;
            else if (sw0_shift == 3'b000) sw_out[0] <= 1'b0;
            
            if (sw1_shift == 3'b111) sw_out[1] <= 1'b1;
            else if (sw1_shift == 3'b000) sw_out[1] <= 1'b0;
            
            if (sw2_shift == 3'b111) sw_out[2] <= 1'b1;
            else if (sw2_shift == 3'b000) sw_out[2] <= 1'b0;
            
            if (sw3_shift == 3'b111) sw_out[3] <= 1'b1;
            else if (sw3_shift == 3'b000) sw_out[3] <= 1'b0;
            
            if (sw7_shift == 3'b111) sw7_out <= 1'b1;
            else if (sw7_shift == 3'b000) sw7_out <= 1'b0;
        end
    end

    // Edge detection for pulse output
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_prev <= 1'b0; s1_prev <= 1'b0;
            s2_prev <= 1'b0; s3_prev <= 1'b0;
            s0_out <= 1'b0; s1_out <= 1'b0;
            s2_out <= 1'b0; s3_out <= 1'b0;
        end
        else begin
            s0_prev <= s0_stable;
            s1_prev <= s1_stable;
            s2_prev <= s2_stable;
            s3_prev <= s3_stable;
            
            s0_out <= s0_stable & ~s0_prev;
            s1_out <= s1_stable & ~s1_prev;
            s2_out <= s2_stable & ~s2_prev;
            s3_out <= s3_stable & ~s3_prev;
        end
    end

endmodule
