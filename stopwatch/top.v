// Top Module for Stopwatch
// Connects all modules: clock divider, debounce, stopwatch logic, display driver
// Display format: hh-mm-ss-xx (Hours, Minutes, Seconds, Centiseconds)
module top(
    input clk,              // 100MHz system clock (P17)
    input s0_reset,         // Reset button (R15 - Center)
    input s1_start,         // Start button (U4 - Up)
    input s2_stop,          // Stop button (V1 - Left)
    input s3_set_min,       // Set minutes button (R11 - Down)
    input s4_set_hour,      // Set hours button (R17 - Right)
    input sw7_countdown,    // Countdown mode switch (P5 - Slide Switch)
    output [3:0] wei,       // Digit select
    output [7:0] duan,      // Segment data for right display block
    output [7:0] duan1      // Segment data for left display block
);

    // Internal wires
    wire clk_100hz;
    wire clk_1khz;
    wire rst_debounced;
    wire start_debounced;
    wire stop_debounced;
    wire set_min_debounced;
    wire set_hour_debounced;
    wire countdown_level;   // Debounced stable level for slide switch
    
    wire [7:0] xx, ss, mm, hh;

    // Clock divider instance
    clk_div u_clk_div (
        .clk(clk),
        .rst(1'b0),          // Clock divider should not be reset
        .clk_100hz(clk_100hz),
        .clk_1khz(clk_1khz)
    );

    // Debounce instances for all button inputs
    debounce u_debounce_reset (
        .clk(clk),
        .rst(1'b0),
        .btn_in(s0_reset),
        .btn_out(rst_debounced),
        .level_out()         // Not used for buttons
    );

    debounce u_debounce_start (
        .clk(clk),
        .rst(1'b0),
        .btn_in(s1_start),
        .btn_out(start_debounced),
        .level_out()         // Not used for buttons
    );

    debounce u_debounce_stop (
        .clk(clk),
        .rst(1'b0),
        .btn_in(s2_stop),
        .btn_out(stop_debounced),
        .level_out()         // Not used for buttons
    );

    debounce u_debounce_set_min (
        .clk(clk),
        .rst(1'b0),
        .btn_in(s3_set_min),
        .btn_out(set_min_debounced),
        .level_out()         // Not used for buttons
    );

    debounce u_debounce_set_hour (
        .clk(clk),
        .rst(1'b0),
        .btn_in(s4_set_hour),
        .btn_out(set_hour_debounced),
        .level_out()         // Not used for buttons
    );

    // Debounce for slide switch (use level output, not pulse)
    debounce u_debounce_countdown (
        .clk(clk),
        .rst(1'b0),
        .btn_in(sw7_countdown),
        .btn_out(),          // Not used for slide switches
        .level_out(countdown_level)  // Use stable level for mode selection
    );

    // Stopwatch logic instance
    stopwatch_logic u_stopwatch_logic (
        .clk_100hz(clk_100hz),
        .clk(clk),
        .rst(rst_debounced),
        .start(start_debounced),
        .stop(stop_debounced),
        .countdown_mode(countdown_level),  // Use debounced stable level from slide switch
        .set_min(set_min_debounced),
        .set_hour(set_hour_debounced),
        .xx(xx),
        .ss(ss),
        .mm(mm),
        .hh(hh)
    );

    // Display driver instance
    display_driver u_display_driver (
        .clk_1khz(clk_1khz),
        .rst(rst_debounced),
        .xx(xx),
        .ss(ss),
        .mm(mm),
        .hh(hh),
        .wei(wei),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
