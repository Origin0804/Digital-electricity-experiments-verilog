// Digital Clock Logic Module
// Implements 24-hour clock with time adjustment and hourly chime
// Features:
//   - 24-hour format HH:MM:SS display
//   - Time adjustment mode (mode button toggles hour/minute adjustment)
//   - Increment button for time setting
//   - Hourly chime: LED flashes for 5 seconds before each hour

module clock_logic(
    input clk_1Hz,          // 1Hz timing clock
    input rst,              // Active high reset
    input en,               // Pause signal (1 = paused)
    input mode,             // Mode button (pulse) - toggle adjustment mode
    input inc,              // Increment button (pulse) - add to current field
    output reg [7:0] hours,     // Hours (0-23)
    output reg [7:0] minutes,   // Minutes (0-59)
    output reg [7:0] seconds,   // Seconds (0-59)
    output reg [1:0] adj_mode,  // 0=normal, 1=adjust hour, 2=adjust minute
    output reg chime            // Hourly chime signal (LED flash)
);

    // Chime counter (counts down from 5 to 0) - 4 bits to accommodate values up to 5
    reg [3:0] chime_counter;
    
    // Mode state machine
    // 0: Normal running mode
    // 1: Adjust hours mode
    // 2: Adjust minutes mode
    
    always @(posedge clk_1Hz or posedge rst) begin
        if (rst) begin
            hours <= 8'd0;
            minutes <= 8'd0;
            seconds <= 8'd0;
            adj_mode <= 2'd0;
            chime <= 1'b0;
            chime_counter <= 3'd0;
        end
        else begin
            // Mode button handling
            if (mode) begin
                if (adj_mode == 2'd0)
                    adj_mode <= 2'd1;  // Enter hour adjustment
                else if (adj_mode == 2'd1)
                    adj_mode <= 2'd2;  // Switch to minute adjustment
                else
                    adj_mode <= 2'd0;  // Exit adjustment mode
            end
            
            // Increment button handling (only in adjustment mode)
            if (inc && adj_mode != 2'd0) begin
                if (adj_mode == 2'd1) begin
                    // Adjust hours
                    if (hours >= 8'd23)
                        hours <= 8'd0;
                    else
                        hours <= hours + 1'b1;
                end
                else if (adj_mode == 2'd2) begin
                    // Adjust minutes
                    if (minutes >= 8'd59)
                        minutes <= 8'd0;
                    else
                        minutes <= minutes + 1'b1;
                end
            end
            
            // Normal clock operation (only when not paused and not in adjustment mode)
            if (!en && adj_mode == 2'd0) begin
                // Seconds counter
                if (seconds >= 8'd59) begin
                    seconds <= 8'd0;
                    // Minutes counter
                    if (minutes >= 8'd59) begin
                        minutes <= 8'd0;
                        // Hours counter
                        if (hours >= 8'd23)
                            hours <= 8'd0;
                        else
                            hours <= hours + 1'b1;
                    end
                    else begin
                        minutes <= minutes + 1'b1;
                    end
                end
                else begin
                    seconds <= seconds + 1'b1;
                end
            end
            
            // Hourly chime logic
            // Chime starts 5 seconds before the hour (when seconds = 55 and minutes = 59)
            if (minutes == 8'd59 && seconds >= 8'd55 && adj_mode == 2'd0) begin
                chime <= 1'b1;
                chime_counter <= 4'd5 - (seconds - 8'd55); // Count down from 5 to 0
            end
            else if (chime_counter > 0) begin
                chime_counter <= chime_counter - 1'b1;
                chime <= 1'b1;
            end
            else begin
                chime <= 1'b0;
            end
        end
    end

endmodule
