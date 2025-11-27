// Display Driver Module for Ticket Machine
// Displays 2-digit BCD values on 7-segment display

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input clk_2Hz,          // 2Hz flash clock
    input rst,              // Active high reset
    input [7:0] display_val,    // Value to display
    input [7:0] total_sales,    // Total sales
    input [1:0] display_mode,   // 0=price, 1=inserted, 2=change
    input alarm,                // Alarm signal for flashing
    output reg [7:0] an,        // Anode select
    output reg [7:0] duan,      // Segment data for right bank
    output reg [7:0] duan1      // Segment data for left bank
);

    // Scan counter
    reg [1:0] scan_cnt;
    
    // Current digit values
    reg [3:0] digit_right;
    reg [3:0] digit_left;
    
    // Flash control for alarm
    reg flash_state;
    
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

    // Flash state update
    always @(posedge clk_2Hz or posedge rst) begin
        if (rst)
            flash_state <= 1'b1;
        else
            flash_state <= ~flash_state;
    end

    // Scan counter
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 2'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // Display layout:
    // AN7-AN6: Total sales (tens, ones)
    // AN5-AN4: Display mode indicator
    // AN3-AN2: Display value (tens, ones)
    // AN1-AN0: Not used
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
                    digit_left <= 4'd0;             // Mode indicator placeholder
                    digit_right <= display_val % 10; // Value ones
                end
                2'd1: begin
                    an <= 8'b00101000;              // AN5 + AN3 active
                    digit_left <= 4'd0;             // Mode indicator placeholder
                    digit_right <= display_val / 10; // Value tens
                end
                2'd2: begin
                    an <= 8'b01000000;              // AN6 active only
                    digit_left <= total_sales % 10; // Sales ones
                    digit_right <= 4'd0;
                end
                2'd3: begin
                    an <= 8'b10000000;              // AN7 active only
                    digit_left <= total_sales / 10; // Sales tens
                    digit_right <= 4'd0;
                end
            endcase
        end
    end

    // Segment output with alarm flash
    always @(*) begin
        if (alarm && !flash_state) begin
            duan = 8'b00000000;
            duan1 = 8'b00000000;
        end
        else begin
            duan = seg_decode(digit_right);
            duan1 = seg_decode(digit_left);
        end
    end

endmodule
