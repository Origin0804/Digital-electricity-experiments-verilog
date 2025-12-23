// Top-Level Module for Multi-Timer Digital Stopwatch
// Enhanced version with:
// - 2 independent timers
// - Lap timing (up to 10 laps per timer)
// - Higher resolution (milliseconds instead of centiseconds)
// - Display switching between different views
// Integrates all components for EGO1 FPGA board

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Reset button (R11)
    input s1,               // Start/Resume button (R17)
    input s2,               // Stop/Pause button (R15)
    input s3,               // Lap button / Minute Increment (V1)
    input s4,               // View scroll button / Hour Increment (U4)
    input sw0,              // Timer Select switch (R1): 0=Timer1, 1=Timer2
    input sw1,              // Display View Mode (N4): 0=HH-MM-SS-CS, 1=MM-SS-MS
    input sw7,              // Countdown Mode Enable switch (P5)
    output [7:0] an,        // Anode select for AN0-AN7
    output [7:0] duan,      // Segment data for right bank (AN0-AN3)
    output [7:0] duan1,     // Segment data for left bank (AN4-AN7)
    output reg led_alarm,   // Alarm LED (blinks when countdown finishes)
    output led_t1,          // Timer 1 indicator LED
    output led_t2           // Timer 2 indicator LED
);

    // Internal wires
    wire clk_1kHz;          // 1kHz clock for timing (millisecond resolution)
    wire clk_scan;          // 1kHz clock for display scanning
    wire clk_db;            // Clock for debouncing (100Hz)
    
    // Debounced button signals
    wire s0_db, s1_db, s2_db, s3_db, s4_db;
    wire sw0_db, sw1_db, sw7_db;
    
    // Time values from stopwatch logic
    wire [7:0] hours, minutes, seconds;
    wire [9:0] millisec;
    wire [3:0] lap_count;

    // State indicators
    wire stopped;

    // Alarm detection and blink divider
    wire alarm_active;
    reg [9:0] blink_div;  // For 1kHz clock: divide by 500 for ~1Hz blink

    // Display blink when stopped
    reg [9:0] blink_disp_div;
    reg blink_disp;
    
    // Lap view control
    reg lap_view_mode;      // 0=show current time, 1=show lap record
    reg [3:0] lap_index;    // Which lap to display (0-9)
    reg s4_prev;            // For edge detection on view scroll button
    
    // Global reset (active high from S0 button)
    wire rst;
    
    // Raw reset for clock and debounce modules (uses raw S0 input for startup reliability)
    wire raw_rst = s0;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(raw_rst),      // Use raw reset for startup reliability
        .clk_1kHz(clk_1kHz),
        .clk_scan(clk_scan),
        .clk_db(clk_db)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(raw_rst),      // Use raw reset for startup reliability
        .s0_in(s0),
        .s1_in(s1),
        .s2_in(s2),
        .s3_in(s3),
        .s4_in(s4),
        .sw0_in(sw0),
        .sw1_in(sw1),
        .sw7_in(sw7),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db),
        .s3_out(s3_db),
        .s4_out(s4_db),
        .sw0_out(sw0_db),
        .sw1_out(sw1_db),
        .sw7_out(sw7_db)
    );
    
    // Reset signal - use raw S0 directly to avoid debounce module reset blocking
    assign rst = s0;
    
    // Lap view control: S4 cycles through lap records when in lap view mode
    // SW1 high + S4 press = toggle lap view mode
    // When in lap view mode, S4 press = scroll through laps
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            lap_view_mode <= 1'b0;
            lap_index <= 4'd0;
            s4_prev <= 1'b0;
        end else begin
            s4_prev <= s4_db;
            
            // Detect rising edge of S4
            if (s4_db && !s4_prev) begin
                if (sw1_db) begin
                    // SW1 is high: toggle lap view mode
                    lap_view_mode <= ~lap_view_mode;
                    if (!lap_view_mode) begin
                        // Entering lap view mode, start at lap 0
                        lap_index <= 4'd0;
                    end
                end else if (lap_view_mode) begin
                    // In lap view mode, scroll through laps
                    if (lap_index < lap_count - 1)
                        lap_index <= lap_index + 1'b1;
                    else
                        lap_index <= 4'd0;  // Wrap around
                end
            end
        end
    end
    
    // Multi-timer stopwatch logic instance
    stopwatch_multi_logic u_stopwatch(
        .clk_1kHz(clk_1kHz),
        .rst(rst),
        .start(s1_db),
        .stop(s2_db),
        .lap(s3_db),
        .timer_sel(sw0_db),
        .view_sel(lap_view_mode),
        .lap_view(lap_index),
        .min_inc(s3_db),
        .hour_inc(s4_db),
        .countdown_mode(sw7_db),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .millisec(millisec),
        .stopped(stopped),
        .lap_count(lap_count)
    );
    
    // Enhanced display driver instance
    display_driver_multi u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .millisec(millisec),
        .blink_en(stopped),
        .blink_phase(blink_disp),
        .view_mode(sw1_db),
        .timer_sel(sw0_db),
        .lap_view(lap_view_mode),
        .lap_num(lap_index),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

    // Timer indicator LEDs
    assign led_t1 = ~sw0_db;  // LED on when Timer 1 selected
    assign led_t2 = sw0_db;   // LED on when Timer 2 selected

    // Alarm is active when countdown mode is enabled and time has reached zero
    assign alarm_active = sw7_db && (hours == 8'd0) && (minutes == 8'd0) && 
                          (seconds == 8'd0) && (millisec == 10'd0);

    // Blink LED at ~1 Hz (toggle every 500 cycles of 1kHz clock) when alarm is active
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst) begin
            blink_div <= 10'd0;
            led_alarm <= 1'b0;
        end else if (!alarm_active) begin
            blink_div <= 10'd0;
            led_alarm <= 1'b0;
        end else begin
            if (blink_div == 10'd499) begin
                blink_div <= 10'd0;
                led_alarm <= ~led_alarm;
            end else begin
                blink_div <= blink_div + 1'b1;
            end
        end
    end

    // Display blink (~2 Hz) when stopwatch is stopped
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst) begin
            blink_disp_div <= 10'd0;
            blink_disp <= 1'b1;       // Start visible
        end else if (!stopped) begin
            blink_disp_div <= 10'd0;
            blink_disp <= 1'b1;       // Solid on when running/idle
        end else begin
            if (blink_disp_div == 10'd249) begin  // ~2Hz blink
                blink_disp_div <= 10'd0;
                blink_disp <= ~blink_disp;
            end else begin
                blink_disp_div <= blink_disp_div + 1'b1;
            end
        end
    end

endmodule
