// Display Driver Module for Scrolling Display
// Multiplexes 8 characters onto EGO1 dual-bank 7-segment display
// Supports alphanumeric characters (0-9, H, E, U, L, J, Y, space)

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [4:0] char0,      // Character for position 0 (rightmost)
    input [4:0] char1,
    input [4:0] char2,
    input [4:0] char3,
    input [4:0] char4,
    input [4:0] char5,
    input [4:0] char6,
    input [4:0] char7,      // Character for position 7 (leftmost)
    output reg [7:0] an,    // Anode select for AN0-AN7 (active high)
    output reg [7:0] duan,  // Segment data for right bank (AN0-AN3)
    output reg [7:0] duan1  // Segment data for left bank (AN4-AN7)
);

    // Scan counter (0-3 for 4 scan cycles)
    reg [1:0] scan_cnt;
    
    // Current character for right and left banks
    reg [4:0] curr_char_right;
    reg [4:0] curr_char_left;
    
    // Segment patterns (active high segments)
    // Bit mapping: [7]=dp, [6]=a, [5]=b, [4]=c, [3]=d, [2]=e, [1]=f, [0]=g
    function [7:0] seg_decode;
        input [4:0] ch;
        begin
            case (ch)
                5'd0:  seg_decode = 8'b01111110;  // 0
                5'd1:  seg_decode = 8'b00110000;  // 1
                5'd2:  seg_decode = 8'b01101101;  // 2
                5'd3:  seg_decode = 8'b01111001;  // 3
                5'd4:  seg_decode = 8'b00110011;  // 4
                5'd5:  seg_decode = 8'b01011011;  // 5
                5'd6:  seg_decode = 8'b01011111;  // 6
                5'd7:  seg_decode = 8'b01110000;  // 7
                5'd8:  seg_decode = 8'b01111111;  // 8
                5'd9:  seg_decode = 8'b01111011;  // 9
                5'd10: seg_decode = 8'b00110111;  // H (bcefg)
                5'd11: seg_decode = 8'b01001111;  // E (adefg)
                5'd12: seg_decode = 8'b00111110;  // U (bcdef)
                5'd13: seg_decode = 8'b00001110;  // L (def)
                5'd14: seg_decode = 8'b01111100;  // J (bcde) - modified for clarity
                5'd15: seg_decode = 8'b00111011;  // Y (bcfg) - modified: bcdfg
                5'd16: seg_decode = 8'b00000000;  // space (blank)
                default: seg_decode = 8'b00000001; // dash for unknown
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

    // Character selection based on scan position
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b00000000;
            curr_char_right <= 5'd16;
            curr_char_left <= 5'd16;
        end
        else begin
            case (scan_cnt)
                2'd0: begin
                    an <= 8'b00010001;          // AN4 + AN0 active
                    curr_char_left <= char4;    // Position 4 (AN4)
                    curr_char_right <= char0;   // Position 0 (AN0)
                end
                2'd1: begin
                    an <= 8'b00100010;          // AN5 + AN1 active
                    curr_char_left <= char5;    // Position 5 (AN5)
                    curr_char_right <= char1;   // Position 1 (AN1)
                end
                2'd2: begin
                    an <= 8'b01000100;          // AN6 + AN2 active
                    curr_char_left <= char6;    // Position 6 (AN6)
                    curr_char_right <= char2;   // Position 2 (AN2)
                end
                2'd3: begin
                    an <= 8'b10001000;          // AN7 + AN3 active
                    curr_char_left <= char7;    // Position 7 (AN7)
                    curr_char_right <= char3;   // Position 3 (AN3)
                end
            endcase
        end
    end

    // Segment output generation
    always @(*) begin
        duan = seg_decode(curr_char_right);
        duan1 = seg_decode(curr_char_left);
    end

endmodule
