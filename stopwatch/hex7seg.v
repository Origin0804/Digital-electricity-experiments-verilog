module hex7seg(
    input clk,               // Scan clock (~200Hz)
    input rst,               // Reset signal
    input [7:0] centisec,    // 00-99 centiseconds
    input [7:0] sec,         // 00-59 seconds
    input [7:0] min,         // 00-59 minutes
    input [7:0] hour,        // 00-99 hours
    output reg [3:0] wei,    // Digit select (active high)
    output reg [7:0] duan,   // Segment data for left bank (hour, min)
    output reg [7:0] duan1   // Segment data for right bank (sec, centisec)
);

    // Scan counter for 4 digits per bank (8 total)
    reg [1:0] scan_cnt;
    
    // Current digit values for each position
    reg [3:0] digit_left;  // Current digit for left bank
    reg [3:0] digit_right; // Current digit for right bank
    
    // Scan counter increment
    always @(posedge clk or posedge rst) begin
        if (rst)
            scan_cnt <= 2'b00;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end
    
    // Digit selection and wei output
    // Display format: hh-mm-ss-xx
    // Left bank (duan): hh-mm (positions 3,2,1,0)
    // Right bank (duan1): ss-xx (positions 3,2,1,0)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wei <= 4'b0000;
            digit_left <= 4'd0;
            digit_right <= 4'd0;
        end
        else begin
            case (scan_cnt)
                2'b00: begin
                    wei <= 4'b0001;  // Position 0 (rightmost in each bank)
                    digit_left <= min % 10;         // min ones
                    digit_right <= centisec % 10;   // centisec ones
                end
                2'b01: begin
                    wei <= 4'b0010;  // Position 1
                    digit_left <= min / 10;         // min tens
                    digit_right <= centisec / 10;   // centisec tens
                end
                2'b10: begin
                    wei <= 4'b0100;  // Position 2
                    digit_left <= hour % 10;        // hour ones
                    digit_right <= sec % 10;        // sec ones
                end
                2'b11: begin
                    wei <= 4'b1000;  // Position 3 (leftmost in each bank)
                    digit_left <= hour / 10;        // hour tens
                    digit_right <= sec / 10;        // sec tens
                end
            endcase
        end
    end
    
    // 7-segment decoder for left bank (duan)
    // Segments: dp-g-f-e-d-c-b-a (active high)
    always @(*) begin
        case (digit_left)
            4'd0: duan = 8'b11111100; // 0
            4'd1: duan = 8'b01100000; // 1
            4'd2: duan = 8'b11011010; // 2
            4'd3: duan = 8'b11110010; // 3
            4'd4: duan = 8'b01100110; // 4
            4'd5: duan = 8'b10110110; // 5
            4'd6: duan = 8'b10111110; // 6
            4'd7: duan = 8'b11100000; // 7
            4'd8: duan = 8'b11111110; // 8
            4'd9: duan = 8'b11110110; // 9
            default: duan = 8'b00000000; // Blank
        endcase
    end
    
    // 7-segment decoder for right bank (duan1)
    always @(*) begin
        case (digit_right)
            4'd0: duan1 = 8'b11111100; // 0
            4'd1: duan1 = 8'b01100000; // 1
            4'd2: duan1 = 8'b11011010; // 2
            4'd3: duan1 = 8'b11110010; // 3
            4'd4: duan1 = 8'b01100110; // 4
            4'd5: duan1 = 8'b10110110; // 5
            4'd6: duan1 = 8'b10111110; // 6
            4'd7: duan1 = 8'b11100000; // 7
            4'd8: duan1 = 8'b11111110; // 8
            4'd9: duan1 = 8'b11110110; // 9
            default: duan1 = 8'b00000000; // Blank
        endcase
    end

endmodule
