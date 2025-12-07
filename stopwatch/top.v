// Top-Level Module for Digital Stopwatch
// Integrates all components for EGO1 FPGA board

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Reset button (R11)
    input s1,               // Start button (R17)
    input s2,               // Stop button (R15)
    input s3,               // Minute Increment button (V1)
    input s4,               // Hour Increment button (U4)
    input sw7,              // Countdown Mode Enable switch (P5)
    output [7:0] an,        // Anode select for AN0-AN7
    output [7:0] duan,      // Segment data for right bank (AN0-AN3)
    output [7:0] duan1,     // Segment data for left bank (AN4-AN7)
    output reg led_alarm    // Alarm LED (blinks when countdown finishes)
);

    // Internal wires
    wire clk_100Hz;         // 100Hz clock for timing
    wire clk_scan;          // 1kHz clock for display scanning
    wire clk_db;            // Clock for debouncing
    
    // Debounced button signals
    wire s0_db, s1_db, s2_db, s3_db, s4_db, sw7_db;
    
    // Time values
    wire [7:0] hours, minutes, seconds, centisec;

    // State indicators
    wire stopped;

    // Alarm detection and blink divider
    wire alarm_active;
    reg [6:0] blink_div;

    // Display blink when stopped
    reg [6:0] blink_disp_div;
    reg blink_disp;
    
    // Global reset (active high from S0 button)
    wire rst;
    
    // Raw reset for clock and debounce modules (uses raw S0 input for startup reliability)
    wire raw_rst = s0;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(raw_rst),      // Use raw reset for startup reliability
        .clk_100Hz(clk_100Hz),
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
        .sw7_in(sw7),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db),
        .s3_out(s3_db),
        .s4_out(s4_db),
        .sw7_out(sw7_db)
    );
    
    // Reset signal - use raw S0 directly to avoid debounce module reset blocking
    // Note: When S0 is pressed, it also resets the debounce module, which clears s0_db.
    // Therefore, we must use the raw S0 signal for resetting the stopwatch logic.
    assign rst = s0;
    
    // Stopwatch logic instance
    stopwatch_logic u_stopwatch(
        .clk_100Hz(clk_100Hz),
        .rst(rst),
        .start(s1_db),
        .stop(s2_db),
        .min_inc(s3_db),
        .hour_inc(s4_db),
        .countdown_mode(sw7_db),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .centisec(centisec),
        .stopped(stopped)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .centisec(centisec),
        .blink_en(stopped),
        .blink_phase(blink_disp),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

    // Alarm is active when countdown mode is enabled and time has reached zero
    assign alarm_active = sw7_db && (hours == 8'd0) && (minutes == 8'd0) && (seconds == 8'd0) && (centisec == 8'd0);

    // Blink LED at ~1 Hz (toggle every 50 cycles of 100 Hz clock) when alarm is active
    always @(posedge clk_100Hz or posedge rst) begin
        if (rst) begin
            blink_div <= 7'd0;
            led_alarm <= 1'b0;
        end else if (!alarm_active) begin
            blink_div <= 7'd0;
            led_alarm <= 1'b0;
        end else begin
            if (blink_div == 7'd49) begin
                blink_div <= 7'd0;
                led_alarm <= ~led_alarm;
            end else begin
                blink_div <= blink_div + 1'b1;
            end
        end
    end

    // Display blink (~2 Hz) when stopwatch is stopped (not in IDLE/RUNNING)
    always @(posedge clk_100Hz or posedge rst) begin
        if (rst) begin
            blink_disp_div <= 7'd0;
            blink_disp <= 1'b1;       // Start visible
        end else if (!stopped) begin
            blink_disp_div <= 7'd0;
            blink_disp <= 1'b1;       // Solid on when running/idle
        end else begin
            if (blink_disp_div == 7'd24) begin
                blink_disp_div <= 7'd0;
                blink_disp <= ~blink_disp;
            end else begin
                blink_disp_div <= blink_disp_div + 1'b1;
            end
        end
    end

endmodule
