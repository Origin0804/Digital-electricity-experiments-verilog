// Top-Level Module for Multi-function Digital Clock
// Integrates all components for EGO1 FPGA board
// Lab6_1: 24-hour clock with time adjustment and hourly chime

module top(
    input clk,              // 100MHz clock (P17)
    input s3,               // Mode button (V1) - toggle adjustment mode
    input s4,               // Increment button (U4) - add to current field
    input en,               // Pause switch (R1/SW0) - pause clock
    output [7:0] an,        // Anode select for AN0-AN7
    output [7:0] duan,      // Segment data for right bank (AN0-AN3)
    output [7:0] duan1,     // Segment data for left bank (AN4-AN7)
    output [7:0] led        // LED outputs for hourly chime
);

    // Internal wires
    wire clk_1Hz;           // 1Hz clock for timing
    wire clk_2Hz;           // 2Hz clock for flashing
    wire clk_scan;          // 1kHz clock for display scanning
    wire clk_db;            // Clock for debouncing
    
    // Debounced signals
    wire s3_db, s4_db, en_db;
    
    // Time values
    wire [7:0] hours, minutes, seconds;
    wire [1:0] adj_mode;
    wire chime;
    
    // Raw reset from mode button for initialization
    wire rst = 1'b0;  // No reset button, always run
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(rst),
        .clk_1Hz(clk_1Hz),
        .clk_2Hz(clk_2Hz),
        .clk_scan(clk_scan),
        .clk_db(clk_db)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(rst),
        .s3_in(s3),
        .s4_in(s4),
        .en_in(en),
        .s3_out(s3_db),
        .s4_out(s4_db),
        .en_out(en_db)
    );
    
    // Clock logic instance
    clock_logic u_clock(
        .clk_1Hz(clk_1Hz),
        .rst(rst),
        .en(en_db),
        .mode(s3_db),
        .inc(s4_db),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .adj_mode(adj_mode),
        .chime(chime)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .clk_2Hz(clk_2Hz),
        .rst(rst),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .adj_mode(adj_mode),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );
    
    // LED output for hourly chime (all LEDs flash)
    assign led = chime ? 8'hFF : 8'h00;

endmodule
