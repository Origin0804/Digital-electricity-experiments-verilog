// Display Driver Module for Digital Stopwatch
// Multiplexes 8 digits onto EGO1 dual-bank 7-segment display
// Display format: hh-mm-ss-xx (with dashes as separators)

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [7:0] hours,      // Hours value (0-99)
    input [7:0] minutes,    // Minutes value (0-59)
    input [7:0] seconds,    // Seconds value (0-59)
    input [7:0] centisec,   // Centiseconds value (0-99)
    output reg [3:0] wei,   // Digit select (active high)
    output reg [7:0] duan,  // Segment data for first bank
    output reg [7:0] duan1  // Segment data for second bank
);

    // Scan counter (0-3 for 4 digit positions, each position drives 2 digits)
    reg [2:0] scan_cnt;
    
    // Current digit values
    reg [3:0] digit_low;    // Lower digit (ones place)
    reg [3:0] digit_high;   // Upper digit (tens place)
    
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
            scan_cnt <= 3'd0;
        else if (scan_cnt >= 3'd3)
            scan_cnt <= 3'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // Digit selection and value extraction
    // Display format: HH-MM-SS-XX
    // Position 0 (wei=0001): centisec ones (X) and centisec tens (X)
    // Position 1 (wei=0010): seconds ones (S) and seconds tens (S)
    // Position 2 (wei=0100): minutes ones (M) and minutes tens (M)
    // Position 3 (wei=1000): hours ones (H) and hours tens (H)
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            wei <= 4'b0000;
            digit_low <= 4'd0;
            digit_high <= 4'd0;
        end
        else begin
            case (scan_cnt)
                3'd0: begin
                    wei <= 4'b0001;
                    digit_low <= centisec % 10;     // Centisec ones
                    digit_high <= centisec / 10;    // Centisec tens
                end
                3'd1: begin
                    wei <= 4'b0010;
                    digit_low <= seconds % 10;      // Seconds ones
                    digit_high <= seconds / 10;     // Seconds tens
                end
                3'd2: begin
                    wei <= 4'b0100;
                    digit_low <= minutes % 10;      // Minutes ones
                    digit_high <= minutes / 10;     // Minutes tens
                end
                3'd3: begin
                    wei <= 4'b1000;
                    digit_low <= hours % 10;        // Hours ones
                    digit_high <= hours / 10;       // Hours tens
                end
                default: begin
                    wei <= 4'b0000;
                    digit_low <= 4'd0;
                    digit_high <= 4'd0;
                end
            endcase
        end
    end

    // Segment output generation
    // duan drives lower digit, duan1 drives upper digit
    // Add decimal point (dp) between pairs to show separator (hh.mm.ss.xx)
    always @(*) begin
        // Lower digit (ones place) - no decimal point
        duan = seg_decode(digit_low);
        // Upper digit (tens place) - add decimal point for separator
        duan1 = seg_decode(digit_high) | 8'b10000000;  // Set dp bit
    end

endmodule
