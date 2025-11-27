// Display Driver Module for Simple Calculator
// Displays result on 7-segment display (up to 9999)

module display_driver(
    input clk_scan,         // 1kHz scan clock
    input rst,              // Active high reset
    input [15:0] result,    // Result to display
    input [7:0] num_input,  // Current input value
    input [1:0] op_display, // Current operation indicator
    output reg [7:0] an,    // Anode select
    output reg [7:0] duan,  // Segment data for right bank
    output reg [7:0] duan1  // Segment data for left bank
);

    // Scan counter
    reg [1:0] scan_cnt;
    
    // Current digit values
    reg [3:0] digit_right;
    reg [3:0] digit_left;
    
    // BCD conversion for result (simplified, only 4 digits)
    wire [3:0] result_ones = result % 10;
    wire [3:0] result_tens = (result / 10) % 10;
    wire [3:0] result_hundreds = (result / 100) % 10;
    wire [3:0] result_thousands = (result / 1000) % 10;
    
    // BCD for input
    wire [3:0] input_ones = num_input % 10;
    wire [3:0] input_tens = (num_input / 10) % 10;
    wire [3:0] input_hundreds = (num_input / 100) % 10;
    
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
                4'd10: seg_decode = 8'b00000001; // dash for operation
                4'd11: seg_decode = 8'b00000000; // blank
                default: seg_decode = 8'b00000001;
            endcase
        end
    endfunction
    
    // Operation symbol patterns
    function [7:0] op_decode;
        input [1:0] op;
        begin
            case (op)
                2'd1: op_decode = 8'b00000001; // + (horizontal line, simplified)
                2'd2: op_decode = 8'b00000001; // - (horizontal line)
                2'd3: op_decode = 8'b00110111; // * (simplified as H-like)
                default: op_decode = 8'b00000000; // blank
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
    // Left bank (AN7-AN4): Result (thousands, hundreds, tens, ones)
    // Right bank (AN3-AN0): Input (hundreds, tens, ones) + operation indicator
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b00000000;
            digit_right <= 4'd0;
            digit_left <= 4'd0;
        end
        else begin
            case (scan_cnt)
                2'd0: begin
                    an <= 8'b00010001;              // AN4 + AN0 active
                    digit_left <= result_ones;      // Result ones
                    digit_right <= input_ones;      // Input ones
                end
                2'd1: begin
                    an <= 8'b00100010;              // AN5 + AN1 active
                    digit_left <= result_tens;      // Result tens
                    digit_right <= input_tens;      // Input tens
                end
                2'd2: begin
                    an <= 8'b01000100;              // AN6 + AN2 active
                    digit_left <= result_hundreds;  // Result hundreds
                    digit_right <= input_hundreds;  // Input hundreds
                end
                2'd3: begin
                    an <= 8'b10001000;              // AN7 + AN3 active
                    digit_left <= result_thousands; // Result thousands
                    digit_right <= 4'd10;           // Operation indicator position
                end
            endcase
        end
    end

    // Segment output
    always @(*) begin
        if (scan_cnt == 2'd3 && op_display != 2'd0) begin
            // Show operation symbol
            duan = op_decode(op_display);
        end
        else begin
            duan = seg_decode(digit_right);
        end
        duan1 = seg_decode(digit_left);
    end

endmodule
