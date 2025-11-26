// Debounce Module
// Debounces button inputs with ~10ms delay
// Input: Raw button signal
// Output: 
//   btn_out - Clean debounced signal (active high pulse for one clock on press)
//   level_out - Stable debounced level (for slide switches)
module debounce(
    input clk,          // System clock (100MHz)
    input rst,          // Reset signal
    input btn_in,       // Raw button input
    output reg btn_out, // Debounced output (one clock pulse on press)
    output reg level_out // Debounced stable level output (for slide switches)
);

    // Debounce counter - approx 10ms at 100MHz = 1,000,000 cycles
    reg [19:0] cnt;
    reg btn_prev;
    reg btn_stable;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 20'd0;
            btn_prev <= 1'b0;
            btn_stable <= 1'b0;
            btn_out <= 1'b0;
            level_out <= 1'b0;
        end
        else begin
            btn_out <= 1'b0;  // Default: no pulse
            
            if (btn_in != btn_prev) begin
                // Button state changed, reset counter
                cnt <= 20'd0;
                btn_prev <= btn_in;
            end
            else if (cnt >= 20'd999999) begin
                // Stable for 10ms
                if (btn_in && !btn_stable) begin
                    // Rising edge detected - generate one pulse
                    btn_out <= 1'b1;
                end
                btn_stable <= btn_in;
                level_out <= btn_in;  // Update stable level output
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule
