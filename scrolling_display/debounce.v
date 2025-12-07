// Debounce Module for Scrolling Display
// Debounces S0 reset button and SW7 pause switch

module debounce(
    input clk,              // 100MHz clock
    input s0_in,            // S0 button input (Reset)
    input sw7_in,           // SW7 switch input (Pause)
    output reg s0_out,      // Debounced S0 (pulse)
    output reg sw7_out      // Debounced SW7 (level)
);

    // Counter for debounce clock generation
    reg [19:0] cnt_db;
    reg clk_db;
    
    // Shift registers for debouncing
    reg [2:0] s0_shift, sw7_shift;
    
    // Previous state for edge detection
    reg s0_prev;
    reg s0_stable;

    // 100Hz debounce clock
    always @(posedge clk) begin
        if (cnt_db >= 20'd499999) begin
            cnt_db <= 20'd0;
            clk_db <= ~clk_db;
        end
        else begin
            cnt_db <= cnt_db + 1'b1;
        end
    end

    // Shift register sampling and debouncing
    always @(posedge clk_db) begin
        // Shift in new samples
        s0_shift <= {s0_shift[1:0], s0_in};
        sw7_shift <= {sw7_shift[1:0], sw7_in};
        
        // Check for stable high (all 1s)
        if (s0_shift == 3'b111) s0_stable <= 1'b1;
        else if (s0_shift == 3'b000) s0_stable <= 1'b0;
        
        // SW7 is a switch, output level
        if (sw7_shift == 3'b111) sw7_out <= 1'b1;
        else if (sw7_shift == 3'b000) sw7_out <= 1'b0;
    end

    // Edge detection for S0 pulse output
    always @(posedge clk_db) begin
        s0_prev <= s0_stable;
        s0_out <= s0_stable & ~s0_prev;
    end

endmodule
