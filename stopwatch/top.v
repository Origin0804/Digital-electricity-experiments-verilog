module top(
    input clk,           // 100MHz system clock (P17)
    input rst,           // Reset S0 (R15)
    input start,         // Start S1 (U4)
    input stop,          // Stop S2 (V1)
    input set_min,       // Set minute S3 (R11)
    input set_hour,      // Set hour S4 (R17)
    input countdown_sw,  // Countdown mode switch SW7 (P5)
    output [3:0] wei,    // Digit position select
    output [7:0] duan,   // Segment data left bank (hh-mm)
    output [7:0] duan1   // Segment data right bank (ss-xx)
);

    // Internal wires
    wire clk_100hz;
    wire clk_200hz;
    wire [5:0] btn_debounced;
    wire [7:0] centisec, sec, min, hour;
    
    // Raw button inputs packed
    wire [5:0] btn_raw;
    assign btn_raw = {countdown_sw, set_hour, set_min, stop, start, rst};

    // Clock divider instance
    clkdiv u_clkdiv (
        .clk(clk),
        .rst(1'b0),  // Clock divider should not be reset by button
        .clk_100hz(clk_100hz),
        .clk_200hz(clk_200hz)
    );

    // Debounce instance
    debounce u_debounce (
        .clk(clk_200hz),
        .rst(1'b0),  // Debounce should not be reset
        .btn_in(btn_raw),
        .btn_out(btn_debounced)
    );

    // Stopwatch/Countdown controller instance
    clocks_ctrl u_clocks_ctrl (
        .clk_100hz(clk_100hz),
        .clk_200hz(clk_200hz),
        .rst(btn_debounced[0]),        // S0 - Reset
        .start(btn_debounced[1]),      // S1 - Start
        .stop(btn_debounced[2]),       // S2 - Stop
        .set_min(btn_debounced[3]),    // S3 - Set minute
        .set_hour(btn_debounced[4]),   // S4 - Set hour
        .countdown_mode(btn_debounced[5]), // SW7 - Countdown mode
        .centisec(centisec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    // 7-segment display driver instance
    hex7seg u_hex7seg (
        .clk(clk_200hz),
        .rst(btn_debounced[0]),
        .centisec(centisec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .wei(wei),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
