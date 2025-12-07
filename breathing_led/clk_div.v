// Clock Divider Module for Breathing LED
// Generates various clock signals for PWM and effects
// Input: 100MHz clock (P17)

module clk_div(
    input clk,              // 100MHz input clock
    input rst,              // Active high reset
    output reg clk_pwm,     // Fast PWM clock (~100kHz)
    output reg clk_breath,  // Slow clock for brightness ramping
    output reg clk_db       // 100Hz clock for debouncing
);

    // Counter registers
    reg [9:0] cnt_pwm;      // For 100kHz: 100MHz / 100kHz / 2 = 500
    reg [20:0] cnt_breath;  // For brightness update (~50Hz for smooth breathing)
    reg [19:0] cnt_db;      // For 100Hz debounce

    // 100kHz PWM clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_pwm <= 10'd0;
            clk_pwm <= 1'b0;
        end
        else if (cnt_pwm >= 10'd499) begin
            cnt_pwm <= 10'd0;
            clk_pwm <= ~clk_pwm;
        end
        else begin
            cnt_pwm <= cnt_pwm + 1'b1;
        end
    end

    // ~50Hz breathing update clock (for smooth 8-second cycle)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_breath <= 21'd0;
            clk_breath <= 1'b0;
        end
        else if (cnt_breath >= 21'd999999) begin  // ~50Hz
            cnt_breath <= 21'd0;
            clk_breath <= ~clk_breath;
        end
        else begin
            cnt_breath <= cnt_breath + 1'b1;
        end
    end

    // 100Hz clock for debouncing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_db <= 20'd0;
            clk_db <= 1'b0;
        end
        else if (cnt_db >= 20'd499999) begin
            cnt_db <= 20'd0;
            clk_db <= ~clk_db;
        end
        else begin
            cnt_db <= cnt_db + 1'b1;
        end
    end

endmodule
