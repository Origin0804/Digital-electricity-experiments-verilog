// Display Driver Module
// Drives 8 digits by scanning 4 positions and using duan (right) and duan1 (left) simultaneously
// Display format: hh-mm-ss-xx
// Right block (duan): ss-xx (seconds and centiseconds)
// Left block (duan1): hh-mm (hours and minutes)
// Scan 0: xx ones (duan) and mm ones (duan1)
// Scan 1: xx tens (duan) and mm tens (duan1)
// Scan 2: ss ones (duan) and hh ones (duan1)
// Scan 3: ss tens (duan) and hh tens (duan1)
module display_driver(
    input clk_1khz,         // ~1kHz scanning clock
    input rst,              // Reset signal
    input [7:0] xx,         // Centiseconds (0-99)
    input [7:0] ss,         // Seconds (0-59)
    input [7:0] mm,         // Minutes (0-59)
    input [7:0] hh,         // Hours (0-99)
    output reg [3:0] wei,   // Digit select (active high)
    output reg [7:0] duan,  // Segment data for right display block
    output reg [7:0] duan1  // Segment data for left display block
);

    reg [1:0] scan_cnt;     // Scan counter (0-3)
    reg [3:0] digit_right;  // Current digit for right block
    reg [3:0] digit_left;   // Current digit for left block

    // Scan counter
    always @(posedge clk_1khz or posedge rst) begin
        if (rst) begin
            scan_cnt <= 2'd0;
        end
        else begin
            scan_cnt <= scan_cnt + 1'b1;
        end
    end

    // Digit selection and wei control
    always @(posedge clk_1khz or posedge rst) begin
        if (rst) begin
            wei <= 4'd0;
            digit_right <= 4'd0;
            digit_left <= 4'd0;
        end
        else begin
            case (scan_cnt)
                2'b00: begin
                    wei <= 4'b0001;
                    digit_right <= xx % 10;     // xx ones digit (rightmost)
                    digit_left <= mm % 10;      // mm ones digit
                end
                2'b01: begin
                    wei <= 4'b0010;
                    digit_right <= xx / 10;     // xx tens digit
                    digit_left <= mm / 10;      // mm tens digit
                end
                2'b10: begin
                    wei <= 4'b0100;
                    digit_right <= ss % 10;     // ss ones digit
                    digit_left <= hh % 10;      // hh ones digit
                end
                2'b11: begin
                    wei <= 4'b1000;
                    digit_right <= ss / 10;     // ss tens digit (leftmost of right block)
                    digit_left <= hh / 10;      // hh tens digit (leftmost)
                end
            endcase
        end
    end

    // Seven-segment decoder for right display (duan)
    always @(*) begin
        case (digit_right)
            4'd0:    duan = 8'b11111100;  // 0
            4'd1:    duan = 8'b01100000;  // 1
            4'd2:    duan = 8'b11011010;  // 2
            4'd3:    duan = 8'b11110010;  // 3
            4'd4:    duan = 8'b01100110;  // 4
            4'd5:    duan = 8'b10110110;  // 5
            4'd6:    duan = 8'b10111110;  // 6
            4'd7:    duan = 8'b11100000;  // 7
            4'd8:    duan = 8'b11111110;  // 8
            4'd9:    duan = 8'b11110110;  // 9
            default: duan = 8'b00000000;  // Blank
        endcase
    end

    // Seven-segment decoder for left display (duan1)
    always @(*) begin
        case (digit_left)
            4'd0:    duan1 = 8'b11111100;  // 0
            4'd1:    duan1 = 8'b01100000;  // 1
            4'd2:    duan1 = 8'b11011010;  // 2
            4'd3:    duan1 = 8'b11110010;  // 3
            4'd4:    duan1 = 8'b01100110;  // 4
            4'd5:    duan1 = 8'b10110110;  // 5
            4'd6:    duan1 = 8'b10111110;  // 6
            4'd7:    duan1 = 8'b11100000;  // 7
            4'd8:    duan1 = 8'b11111110;  // 8
            4'd9:    duan1 = 8'b11110110;  // 9
            default: duan1 = 8'b00000000;  // Blank
        endcase
    end

endmodule
