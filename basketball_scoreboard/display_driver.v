// Display Driver Module for Basketball Scoreboard
// Displays Team A score, Team B score, and 24-second shot clock

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [7:0] score_a,    // Team A score
    input [7:0] score_b,    // Team B score
    input [5:0] shot_clock, // 24-second shot clock
    output reg [7:0] an,    // Anode select
    output reg [7:0] duan,  // Segment data for right bank
    output reg [7:0] duan1  // Segment data for left bank
);

    // Scan counter
    reg [1:0] scan_cnt;
    
    // Current digit values
    reg [3:0] digit_right;
    reg [3:0] digit_left;
    
    // Segment patterns
    function [7:0] seg_decode;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seg_decode = 8'b01111110;
                4'd1: seg_decode = 8'b00110000;
                4'd2: seg_decode = 8'b01101101;
                4'd3: seg_decode = 8'b01111001;
                4'd4: seg_decode = 8'b00110011;
                4'd5: seg_decode = 8'b01011011;
                4'd6: seg_decode = 8'b01011111;
                4'd7: seg_decode = 8'b01110000;
                4'd8: seg_decode = 8'b01111111;
                4'd9: seg_decode = 8'b01111011;
                default: seg_decode = 8'b00000001;
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

    // Display layout:
    // Left bank (AN7-AN4): Team A score (AN7-AN6), Shot clock (AN5-AN4)
    // Right bank (AN3-AN0): Team B score (AN3-AN2), unused (AN1-AN0)
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b00000000;
            digit_right <= 4'd0;
            digit_left <= 4'd0;
        end
        else begin
            case (scan_cnt)
                2'd0: begin
                    an <= 8'b00010100;              // AN4 + AN2 active
                    digit_left <= shot_clock % 10;  // Shot clock ones
                    digit_right <= score_b % 10;    // Team B ones
                end
                2'd1: begin
                    an <= 8'b00101000;              // AN5 + AN3 active
                    digit_left <= shot_clock / 10;  // Shot clock tens
                    digit_right <= score_b / 10;    // Team B tens
                end
                2'd2: begin
                    an <= 8'b01000000;              // AN6 active
                    digit_left <= score_a % 10;     // Team A ones
                    digit_right <= 4'd0;
                end
                2'd3: begin
                    an <= 8'b10000000;              // AN7 active
                    digit_left <= score_a / 10;     // Team A tens
                    digit_right <= 4'd0;
                end
            endcase
        end
    end

    // Segment output
    always @(*) begin
        duan = seg_decode(digit_right);
        duan1 = seg_decode(digit_left);
    end

endmodule
