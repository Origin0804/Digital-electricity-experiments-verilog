// Scrolling Logic Module for Student ID Display
// Scrolls "HEU XXX 20190000" (school + name + ID) on 8-digit display
// Characters shift left at 4Hz frequency

module scroll_logic(
    input clk_4Hz,          // 4Hz scroll clock
    input rst,              // Active high reset
    input pause,            // Pause scrolling (1 = paused)
    output reg [4:0] char0, // Character for position 0 (rightmost)
    output reg [4:0] char1, // Character for position 1
    output reg [4:0] char2, // Character for position 2
    output reg [4:0] char3, // Character for position 3
    output reg [4:0] char4, // Character for position 4
    output reg [4:0] char5, // Character for position 5
    output reg [4:0] char6, // Character for position 6
    output reg [4:0] char7  // Character for position 7 (leftmost)
);

    // Character encoding (5-bit to support letters and numbers)
    // 0-9: digits
    // 10: H, 11: E, 12: U, 13: L, 14: J, 15: Y
    // 16: space, 17-30: reserved, 31: blank
    
    // Message string: "HEU LJY 2019XXXX" (example, 16 chars + spaces for padding)
    // We'll use a 24-character buffer for smooth scrolling
    localparam MSG_LEN = 24;
    
    // Message ROM (HEU LJY 20190000 with padding spaces)
    // Character sequence: space space space space space space space space H E U space L J Y space 2 0 1 9 0 0 0 0
    reg [4:0] message [0:MSG_LEN-1];
    
    // Scroll position counter
    reg [4:0] scroll_pos;
    
    // Initialize message (space=16, H=10, E=11, U=12, L=13, J=14, Y=15)
    initial begin
        message[0]  = 5'd16; // space
        message[1]  = 5'd16; // space
        message[2]  = 5'd16; // space
        message[3]  = 5'd16; // space
        message[4]  = 5'd16; // space
        message[5]  = 5'd16; // space
        message[6]  = 5'd16; // space
        message[7]  = 5'd16; // space
        message[8]  = 5'd10; // H
        message[9]  = 5'd11; // E
        message[10] = 5'd12; // U
        message[11] = 5'd16; // space
        message[12] = 5'd13; // L
        message[13] = 5'd14; // J
        message[14] = 5'd15; // Y
        message[15] = 5'd16; // space
        message[16] = 5'd2;  // 2
        message[17] = 5'd0;  // 0
        message[18] = 5'd1;  // 1
        message[19] = 5'd9;  // 9
        message[20] = 5'd0;  // 0
        message[21] = 5'd0;  // 0
        message[22] = 5'd0;  // 0
        message[23] = 5'd0;  // 0
    end
    
    // Scroll position and character output
    always @(posedge clk_4Hz or posedge rst) begin
        if (rst) begin
            scroll_pos <= 5'd0;
        end
        else if (!pause) begin
            if (scroll_pos >= MSG_LEN - 1)
                scroll_pos <= 5'd0;
            else
                scroll_pos <= scroll_pos + 1'b1;
        end
    end
    
    // Character assignment with wrap-around
    always @(*) begin
        char7 = message[(scroll_pos + 0) % MSG_LEN];
        char6 = message[(scroll_pos + 1) % MSG_LEN];
        char5 = message[(scroll_pos + 2) % MSG_LEN];
        char4 = message[(scroll_pos + 3) % MSG_LEN];
        char3 = message[(scroll_pos + 4) % MSG_LEN];
        char2 = message[(scroll_pos + 5) % MSG_LEN];
        char1 = message[(scroll_pos + 6) % MSG_LEN];
        char0 = message[(scroll_pos + 7) % MSG_LEN];
    end

endmodule
