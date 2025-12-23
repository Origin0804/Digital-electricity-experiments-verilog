// Enhanced Display Driver Module for Multi-Timer Stopwatch
// Multiplexes 8 digits onto EGO1 dual-bank 7-segment display
// Display format switches between two views:
//   View 1 (MM-SS-MS): MM.SS.MSH.MSL (minutes, seconds, milliseconds high/low)
//   View 2 (HH-MM-SS): HH.MM.SS.XX (hours, minutes, seconds, centiseconds)
// Physical layout on EGO1 (left to right): AN0-AN1-AN2-AN3 | AN4-AN5-AN6-AN7

module display_driver_multi(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [7:0] hours,      // Hours value (0-99)
    input [7:0] minutes,    // Minutes value (0-59)
    input [7:0] seconds,    // Seconds value (0-59)
    input [9:0] millisec,   // Milliseconds value (0-999)
    input blink_en,         // Enable blinking (blank when blink_phase=0)
    input blink_phase,      // Blink phase: 1=show, 0=blank
    input view_mode,        // Display view: 0=HH-MM-SS-CS, 1=MM-SS-MS
    input timer_sel,        // Timer indicator: 0=Timer1, 1=Timer2
    input lap_view,         // Lap view mode indicator
    input [3:0] lap_num,    // Current lap number being displayed
    output reg [7:0] an,    // Anode select for AN0-AN7 (active high)
    output reg [7:0] duan,  // Segment data for right bank (AN0-AN3)
    output reg [7:0] duan1  // Segment data for left bank (AN4-AN7)
);

    // Scan counter (0-3 for 4 scan cycles, each cycle drives 2 digits simultaneously)
    reg [1:0] scan_cnt;
    reg [7:0] an_scan;       // Raw anode drive before blink masking
    
    // Current digit values for right and left banks
    reg [3:0] digit_right;  // Digit value for right bank (duan)
    reg [3:0] digit_left;   // Digit value for left bank (duan1)
    reg show_dp_right;      // Show decimal point on right digit
    reg show_dp_left;       // Show decimal point on left digit
    
    // Derived values - computed in combinational logic
    reg [7:0] centisec;     // Centiseconds from milliseconds
    reg [7:0] ms_high;      // Hundreds digit of milliseconds
    reg [7:0] ms_low;       // Tens digit of milliseconds
    
    // Segment patterns (active high segments)
    // 7-Segment Display Bit Mapping (active-high encoding):
    //   Bit 7: dp (decimal point)
    //   Bit 6: a  (top horizontal segment)
    //   Bit 5: b  (upper-right vertical segment)
    //   Bit 4: c  (lower-right vertical segment)
    //   Bit 3: d  (bottom horizontal segment)
    //   Bit 2: e  (lower-left vertical segment)
    //   Bit 1: f  (upper-left vertical segment)
    //   Bit 0: g  (middle horizontal segment)
    //
    // Visual representation of segments:
    //      aaa
    //     f   b
    //      ggg
    //     e   c
    //      ddd  .dp
    //
    function [7:0] seg_decode;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seg_decode = 8'b01111110;  // abcdef  (0)
                4'd1: seg_decode = 8'b00110000;  // bc      (1)
                4'd2: seg_decode = 8'b01101101;  // abdeg   (2)
                4'd3: seg_decode = 8'b01111001;  // abcdg   (3)
                4'd4: seg_decode = 8'b00110011;  // bcfg    (4)
                4'd5: seg_decode = 8'b01011011;  // acdfg   (5)
                4'd6: seg_decode = 8'b01011111;  // acdefg  (6)
                4'd7: seg_decode = 8'b01110000;  // abc     (7)
                4'd8: seg_decode = 8'b01111111;  // abcdefg (8)
                4'd9: seg_decode = 8'b01111011;  // abcdfg  (9)
                default: seg_decode = 8'b00000001; // g only (dash for invalid input)
            endcase
        end
    endfunction
    
    // Special character for 'L' (for Lap display)
    function [7:0] seg_L;
        input dummy;
        begin
            seg_L = 8'b00001110;  // def (L)
        end
    endfunction

    // Scan counter
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 2'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end
    
    // Compute derived values from milliseconds
    always @(*) begin
        centisec = millisec / 10;           // Convert milliseconds to centiseconds
        ms_high = (millisec / 100) % 10;    // Hundreds digit of milliseconds
        ms_low = (millisec / 10) % 10;      // Tens digit of milliseconds
    end

    // Anode selection and digit value extraction
    // Physical display layout on EGO1 (left to right): AN0-AN1-AN2-AN3 | AN4-AN5-AN6-AN7
    //
    // View Mode 0: HH-MM-SS-CS (hours, minutes, seconds, centiseconds)
    //   AN0: H (tens), AN1: H (ones), AN2: M (tens), AN3: M (ones)
    //   AN4: S (tens), AN5: S (ones), AN6: C (tens), AN7: C (ones)
    //
    // View Mode 1: MM-SS-MS (minutes, seconds, milliseconds)
    //   AN0: M (tens), AN1: M (ones), AN2: S (tens), AN3: S (ones)
    //   AN4: MS high (hundreds), AN5: MS (tens), AN6: MS (ones), AN7: Timer indicator (1 or 2)
    //
    // Lap View Mode: Show "L" and lap number on leftmost digits
    //   AN0: L, AN1: lap_num, rest same as above
    //
    // Scan pairing (4 cycles, each drives one left group + one right group digit):
    //   Scan 0: AN0 & AN4
    //   Scan 1: AN1 & AN5
    //   Scan 2: AN2 & AN6
    //   Scan 3: AN3 & AN7
    //
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an_scan <= 8'b00000000;
            digit_right <= 4'd0;
            digit_left <= 4'd0;
            show_dp_right <= 1'b0;
            show_dp_left <= 1'b0;
        end
        else begin
            case (scan_cnt)
                2'd0: begin
                    an_scan <= 8'b00010001;         // AN4 + AN0 active
                    if (view_mode) begin
                        // View 1: MM-SS-MS
                        digit_right <= minutes / 10;      // M tens (AN0)
                        digit_left <= ms_high;            // MS hundreds (AN4)
                        show_dp_right <= lap_view;        // Show dp if lap view
                        show_dp_left <= 1'b0;
                    end else begin
                        // View 0: HH-MM-SS-CS
                        digit_right <= hours / 10;        // H tens (AN0)
                        digit_left <= seconds / 10;       // S tens (AN4)
                        show_dp_right <= lap_view;        // Show dp if lap view
                        show_dp_left <= 1'b0;
                    end
                end
                2'd1: begin
                    an_scan <= 8'b00100010;         // AN5 + AN1 active
                    if (view_mode) begin
                        // View 1: MM-SS-MS
                        digit_right <= minutes % 10;      // M ones (AN1)
                        digit_left <= ms_low;             // MS tens (AN5)
                        show_dp_right <= 1'b1;            // dp separator MM-SS
                        show_dp_left <= 1'b0;
                    end else begin
                        // View 0: HH-MM-SS-CS
                        digit_right <= hours % 10;        // H ones (AN1)
                        digit_left <= seconds % 10;       // S ones (AN5)
                        show_dp_right <= 1'b1;            // dp separator HH-MM
                        show_dp_left <= 1'b1;             // dp separator SS-CS
                    end
                end
                2'd2: begin
                    an_scan <= 8'b01000100;         // AN6 + AN2 active
                    if (view_mode) begin
                        // View 1: MM-SS-MS
                        digit_right <= seconds / 10;      // S tens (AN2)
                        digit_left <= (millisec % 10);    // MS ones (AN6)
                        show_dp_right <= 1'b0;
                        show_dp_left <= 1'b1;             // dp before MS
                    end else begin
                        // View 0: HH-MM-SS-CS
                        digit_right <= minutes / 10;      // M tens (AN2)
                        digit_left <= centisec / 10;      // CS tens (AN6)
                        show_dp_right <= 1'b0;
                        show_dp_left <= 1'b0;
                    end
                end
                2'd3: begin
                    an_scan <= 8'b10001000;         // AN7 + AN3 active
                    if (view_mode) begin
                        // View 1: MM-SS-MS - show timer number
                        digit_right <= seconds % 10;      // S ones (AN3)
                        digit_left <= timer_sel ? 4'd2 : 4'd1;  // Timer indicator (AN7)
                        show_dp_right <= 1'b1;            // dp separator SS-MS
                        show_dp_left <= 1'b0;
                    end else begin
                        // View 0: HH-MM-SS-CS
                        digit_right <= minutes % 10;      // M ones (AN3)
                        digit_left <= centisec % 10;      // CS ones (AN7)
                        show_dp_right <= 1'b1;            // dp separator MM-SS
                        show_dp_left <= 1'b0;
                    end
                end
            endcase
        end
    end

    // Segment output generation
    always @(*) begin
        if (blink_en && !blink_phase) begin
            // Blank display during off phase
            duan = 8'b00000000;
            duan1 = 8'b00000000;
            an = 8'b00000000;
        end else begin
            // Normal display with optional lap indicator
            if (lap_view && scan_cnt == 2'd0) begin
                // Show 'L' for lap view on AN0
                duan = seg_L(1'b0) | {show_dp_right, 7'b0000000};
            end else if (lap_view && scan_cnt == 2'd1) begin
                // Show lap number on AN1 (lap_num is guaranteed to be 0-9 from controlling logic)
                duan = seg_decode(lap_num) | {show_dp_right, 7'b0000000};
            end else begin
                duan = seg_decode(digit_right) | {show_dp_right, 7'b0000000};
            end
            duan1 = seg_decode(digit_left) | {show_dp_left, 7'b0000000};
            an = an_scan;
        end
    end

endmodule
