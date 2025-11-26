// Stopwatch Logic Module
// Manages state (Run/Stop), mode (Up/Down), and time counters
// Display format: hh-mm-ss-xx (hours, minutes, seconds, centiseconds)
module stopwatch_logic(
    input clk_100hz,        // 100Hz timing clock
    input clk,              // System clock for state changes
    input rst,              // Reset signal (S0)
    input start,            // Start signal (S1)
    input stop,             // Stop signal (S2)
    input countdown_mode,   // Countdown mode switch (SW7)
    input set_min,          // Set minutes (S3) - increment minutes in countdown mode
    input set_hour,         // Set hours (S4) - increment hours in countdown mode
    output reg [7:0] xx,    // Centiseconds (0-99)
    output reg [7:0] ss,    // Seconds (0-59)
    output reg [7:0] mm,    // Minutes (0-59)
    output reg [7:0] hh     // Hours (0-99)
);

    // State definitions
    localparam STOPPED = 1'b0;
    localparam RUNNING = 1'b1;

    reg state;
    reg prev_clk_100hz;

    // State machine for run/stop control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STOPPED;
        end
        else begin
            if (start) begin
                state <= RUNNING;
            end
            else if (stop) begin
                state <= STOPPED;
            end
        end
    end

    // Time counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            xx <= 8'd0;
            ss <= 8'd0;
            mm <= 8'd0;
            hh <= 8'd0;
            prev_clk_100hz <= 1'b0;
        end
        else begin
            prev_clk_100hz <= clk_100hz;
            
            // Handle set_min and set_hour in stopped state when countdown mode is enabled
            if (state == STOPPED && countdown_mode) begin
                if (set_min) begin
                    if (mm >= 8'd59) begin
                        mm <= 8'd0;
                    end
                    else begin
                        mm <= mm + 1'b1;
                    end
                end
                if (set_hour) begin
                    if (hh >= 8'd99) begin
                        hh <= 8'd0;
                    end
                    else begin
                        hh <= hh + 1'b1;
                    end
                end
            end
            
            // Running state - count on rising edge of 100Hz clock
            if (state == RUNNING && clk_100hz && !prev_clk_100hz) begin
                if (countdown_mode) begin
                    // Countdown mode
                    if (xx == 8'd0 && ss == 8'd0 && mm == 8'd0 && hh == 8'd0) begin
                        // Already at zero, stop or stay at zero
                        // Stay at zero
                    end
                    else if (xx > 8'd0) begin
                        xx <= xx - 1'b1;
                    end
                    else begin
                        xx <= 8'd99;
                        if (ss > 8'd0) begin
                            ss <= ss - 1'b1;
                        end
                        else begin
                            ss <= 8'd59;
                            if (mm > 8'd0) begin
                                mm <= mm - 1'b1;
                            end
                            else begin
                                mm <= 8'd59;
                                if (hh > 8'd0) begin
                                    hh <= hh - 1'b1;
                                end
                                else begin
                                    // Countdown complete - wrap around to 00:00:00:00
                                    hh <= 8'd0;
                                    mm <= 8'd0;
                                    ss <= 8'd0;
                                    xx <= 8'd0;
                                end
                            end
                        end
                    end
                end
                else begin
                    // Stopwatch mode (count up)
                    if (xx >= 8'd99) begin
                        xx <= 8'd0;
                        if (ss >= 8'd59) begin
                            ss <= 8'd0;
                            if (mm >= 8'd59) begin
                                mm <= 8'd0;
                                if (hh >= 8'd99) begin
                                    hh <= 8'd0;
                                end
                                else begin
                                    hh <= hh + 1'b1;
                                end
                            end
                            else begin
                                mm <= mm + 1'b1;
                            end
                        end
                        else begin
                            ss <= ss + 1'b1;
                        end
                    end
                    else begin
                        xx <= xx + 1'b1;
                    end
                end
            end
        end
    end

endmodule
