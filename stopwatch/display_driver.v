// Display Driver Module for Digital Stopwatch
// Multiplexes 8 digits onto EGO1 dual-bank 7-segment display
// Display format: HH-MM-SS-XX
// Physical layout on EGO1 (left to right): AN0-AN1-AN2-AN3 | AN4-AN5-AN6-AN7
// Left group (AN0-AN3/duan): HH-MM (hours tens, hours ones, minutes tens, minutes ones)
// Right group (AN4-AN7/duan1): SS-XX (seconds tens, seconds ones, centisec tens, centisec ones)

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [7:0] hours,      // Hours value (0-99)
    input [7:0] minutes,    // Minutes value (0-59)
    input [7:0] seconds,    // Seconds value (0-59)
    input [7:0] centisec,   // Centiseconds value (0-99)
    output reg [7:0] an,    // Anode select for AN0-AN7 (active high)
    output reg [7:0] duan,  // Segment data for right bank (AN0-AN3)
    output reg [7:0] duan1  // Segment data for left bank (AN4-AN7)
);

    // Scan counter (0-3 for 4 scan cycles, each cycle drives 2 digits simultaneously)
    reg [1:0] scan_cnt;
    
    // Current digit values for right and left banks
    reg [3:0] digit_right;  // Digit value for right bank (duan)
    reg [3:0] digit_left;   // Digit value for left bank (duan1)
    reg show_dp_right;      // Show decimal point on right digit
    reg show_dp_left;       // Show decimal point on left digit
    
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

    // Scan counter
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 2'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // Anode selection and digit value extraction
    // Physical display layout on EGO1 (left to right): AN0-AN1-AN2-AN3 | AN4-AN5-AN6-AN7
    // Desired display: HH-MM-SS-XX (hours on left, centisec on right)
    //   AN0: H (tens), AN1: H (ones), AN2: M (tens), AN3: M (ones)
    //   AN4: S (tens), AN5: S (ones), AN6: X (tens), AN7: X (ones)
    //
    // Scan pairing (4 cycles, each drives one left group + one right group digit):
    //   Scan 0: AN0 (H tens) & AN4 (S tens) - duan=H_tens, duan1=S_tens
    //   Scan 1: AN1 (H ones) & AN5 (S ones) - duan=H_ones, duan1=S_ones
    //   Scan 2: AN2 (M tens) & AN6 (X tens) - duan=M_tens, duan1=X_tens
    //   Scan 3: AN3 (M ones) & AN7 (X ones) - duan=M_ones, duan1=X_ones
    //
    // Decimal point placement for separator display (HH.MM.SS.XX):
    //   - Show dp on AN1 (H ones) to separate HH-MM
    //   - Show dp on AN3 (M ones) to separate MM-SS
    //   - Show dp on AN5 (S ones) to separate SS-XX
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b00000000;
            digit_right <= 4'd0;
            digit_left <= 4'd0;
            show_dp_right <= 1'b0;
            show_dp_left <= 1'b0;
        end
        else begin
            case (scan_cnt)
                2'd0: begin
                    an <= 8'b00010001;              // AN4 + AN0 active
                    digit_right <= hours / 10;      // H tens (AN0)
                    digit_left <= seconds / 10;     // S tens (AN4)
                    show_dp_right <= 1'b0;
                    show_dp_left <= 1'b0;
                end
                2'd1: begin
                    an <= 8'b00100010;              // AN5 + AN1 active
                    digit_right <= hours % 10;      // H ones (AN1)
                    digit_left <= seconds % 10;     // S ones (AN5)
                    show_dp_right <= 1'b1;          // dp on H ones (separator HH-MM)
                    show_dp_left <= 1'b1;           // dp on S ones (separator SS-XX)
                end
                2'd2: begin
                    an <= 8'b01000100;              // AN6 + AN2 active
                    digit_right <= minutes / 10;    // M tens (AN2)
                    digit_left <= centisec / 10;    // X tens (AN6)
                    show_dp_right <= 1'b0;
                    show_dp_left <= 1'b0;
                end
                2'd3: begin
                    an <= 8'b10001000;              // AN7 + AN3 active
                    digit_right <= minutes % 10;    // M ones (AN3)
                    digit_left <= centisec % 10;    // X ones (AN7)
                    show_dp_right <= 1'b1;          // dp on M ones (separator MM-SS)
                    show_dp_left <= 1'b0;
                end
            endcase
        end
    end

    // Segment output generation
    always @(*) begin
        duan = seg_decode(digit_right) | {show_dp_right, 7'b0000000};
        duan1 = seg_decode(digit_left) | {show_dp_left, 7'b0000000};
    end

endmodule
