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
    output [7:0] duan1      // Segment data for left bank (AN4-AN7)
);

    // Internal wires
    wire clk_100Hz;         // 100Hz clock for timing
    wire clk_scan;          // 1kHz clock for display scanning
    wire clk_db;            // Clock for debouncing
    
    // Debounced button signals
    wire s0_db, s1_db, s2_db, s3_db, s4_db, sw7_db;
    
    // Time values
    wire [7:0] hours, minutes, seconds, centisec;
    
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
        .centisec(centisec)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .centisec(centisec),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
