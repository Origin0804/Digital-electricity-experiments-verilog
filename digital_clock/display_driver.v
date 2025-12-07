// Display Driver Module for Multi-function Digital Clock
// Multiplexes 8 digits onto EGO1 dual-bank 7-segment display
// Display format: HH-MM-SS
// Supports flashing of hours or minutes during adjustment mode

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input clk_2Hz,          // 2Hz flash clock
    input rst,              // Active high reset
    input [7:0] hours,      // Hours value (0-23)
    input [7:0] minutes,    // Minutes value (0-59)
    input [7:0] seconds,    // Seconds value (0-59)
    input [1:0] adj_mode,   // 0=normal, 1=adjust hour, 2=adjust minute
    output reg [7:0] an,    // Anode select for AN0-AN7 (active high)
    output reg [7:0] duan,  // Segment data for right bank (AN0-AN3)
    output reg [7:0] duan1  // Segment data for left bank (AN4-AN7)
);

    // Scan counter (0-3 for 4 scan cycles)
    reg [1:0] scan_cnt;
    
    // Current digit values for right and left banks
    reg [3:0] digit_right;
    reg [3:0] digit_left;
    reg show_dp_right;
    reg show_dp_left;
    
    // Flash control
    reg flash_hours;
    reg flash_minutes;
    
    // Segment patterns (active high segments)
    function [7:0] seg_decode;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seg_decode = 8'b01111110;  // 0
                4'd1: seg_decode = 8'b00110000;  // 1
                4'd2: seg_decode = 8'b01101101;  // 2
                4'd3: seg_decode = 8'b01111001;  // 3
                4'd4: seg_decode = 8'b00110011;  // 4
                4'd5: seg_decode = 8'b01011011;  // 5
                4'd6: seg_decode = 8'b01011111;  // 6
                4'd7: seg_decode = 8'b01110000;  // 7
                4'd8: seg_decode = 8'b01111111;  // 8
                4'd9: seg_decode = 8'b01111011;  // 9
                default: seg_decode = 8'b00000001; // dash
            endcase
        end
    endfunction

    // Flash state update
    always @(posedge clk_2Hz or posedge rst) begin
        if (rst) begin
            flash_hours <= 1'b1;
            flash_minutes <= 1'b1;
        end
        else begin
            if (adj_mode == 2'd1)
                flash_hours <= ~flash_hours;
            else
                flash_hours <= 1'b1;
                
            if (adj_mode == 2'd2)
                flash_minutes <= ~flash_minutes;
            else
                flash_minutes <= 1'b1;
        end
    end

    // Scan counter
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 2'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // Display layout: HH-MM-SS (6 digits used, AN2-AN7)
    // AN7: H tens, AN6: H ones, AN5: M tens, AN4: M ones
    // AN3: S tens, AN2: S ones, AN1/AN0: not used (display 0)
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
                    digit_left <= minutes % 10;     // M ones (AN4)
                    digit_right <= 4'd0;            // Display 0 (AN0)
                    show_dp_left <= 1'b1;           // dp on M ones (separator)
                    show_dp_right <= 1'b0;
                end
                2'd1: begin
                    an <= 8'b00100010;              // AN5 + AN1 active
                    digit_left <= minutes / 10;     // M tens (AN5)
                    digit_right <= 4'd0;            // Display 0 (AN1)
                    show_dp_left <= 1'b0;
                    show_dp_right <= 1'b0;
                end
                2'd2: begin
                    an <= 8'b01000100;              // AN6 + AN2 active
                    digit_left <= hours % 10;       // H ones (AN6)
                    digit_right <= seconds % 10;    // S ones (AN2)
                    show_dp_left <= 1'b1;           // dp on H ones (separator)
                    show_dp_right <= 1'b0;
                end
                2'd3: begin
                    an <= 8'b10001000;              // AN7 + AN3 active
                    digit_left <= hours / 10;       // H tens (AN7)
                    digit_right <= seconds / 10;    // S tens (AN3)
                    show_dp_left <= 1'b0;
                    show_dp_right <= 1'b0;
                end
            endcase
        end
    end

    // Segment output with flash control
    always @(*) begin
        // Left bank (hours and minutes)
        if ((adj_mode == 2'd1 && !flash_hours && (scan_cnt == 2'd2 || scan_cnt == 2'd3)) ||
            (adj_mode == 2'd2 && !flash_minutes && (scan_cnt == 2'd0 || scan_cnt == 2'd1))) begin
            duan1 = 8'b00000000;  // Blank during flash-off
        end
        else begin
            duan1 = seg_decode(digit_left) | {show_dp_left, 7'b0000000};
        end
        
        // Right bank (seconds)
        duan = seg_decode(digit_right) | {show_dp_right, 7'b0000000};
    end

endmodule
