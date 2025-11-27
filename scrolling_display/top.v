// Top-Level Module for Student ID Scrolling Display
// Integrates all components for EGO1 FPGA board
// Lab6_3: Scrolls "HEU LJY 20190000" on 8-digit 7-segment display

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Reset button (R11)
    input sw7,              // Pause switch (P5)
    output [7:0] an,        // Anode select for AN0-AN7
    output [7:0] duan,      // Segment data for right bank (AN0-AN3)
    output [7:0] duan1      // Segment data for left bank (AN4-AN7)
);

    // Internal wires
    wire clk_4Hz;           // 4Hz clock for scrolling
    wire clk_scan;          // 1kHz clock for display scanning
    
    // Debounced signals
    wire s0_db, sw7_db;
    
    // Character outputs from scroll logic
    wire [4:0] char0, char1, char2, char3, char4, char5, char6, char7;
    
    // Reset signal from debounced S0
    wire rst = s0_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s0),           // Use raw S0 for clock reset
        .clk_4Hz(clk_4Hz),
        .clk_scan(clk_scan)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk(clk),
        .s0_in(s0),
        .sw7_in(sw7),
        .s0_out(s0_db),
        .sw7_out(sw7_db)
    );
    
    // Scroll logic instance
    scroll_logic u_scroll(
        .clk_4Hz(clk_4Hz),
        .rst(rst),
        .pause(sw7_db),
        .char0(char0),
        .char1(char1),
        .char2(char2),
        .char3(char3),
        .char4(char4),
        .char5(char5),
        .char6(char6),
        .char7(char7)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .char0(char0),
        .char1(char1),
        .char2(char2),
        .char3(char3),
        .char4(char4),
        .char5(char5),
        .char6(char6),
        .char7(char7),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
