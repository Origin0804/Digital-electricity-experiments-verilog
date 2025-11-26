module clocks_ctrl(
    input clk_100hz,         // 100Hz timing clock
    input clk_200hz,         // 200Hz for edge detection
    input rst,               // Reset signal (S0)
    input start,             // Start signal (S1)
    input stop,              // Stop signal (S2)
    input set_min,           // Increment minutes (S3)
    input set_hour,          // Increment hours (S4)
    input countdown_mode,    // Countdown switch (SW7)
    output reg [7:0] centisec, // 00-99 centiseconds
    output reg [7:0] sec,      // 00-59 seconds
    output reg [7:0] min,      // 00-59 minutes
    output reg [7:0] hour      // 00-99 hours
);

    // State machine states
    localparam STOPPED = 2'b00;
    localparam RUNNING = 2'b01;
    
    reg [1:0] state;
    
    // Edge detection for buttons
    reg start_prev, stop_prev, set_min_prev, set_hour_prev, countdown_mode_prev;
    wire start_edge, stop_edge, set_min_edge, set_hour_edge, countdown_mode_edge;
    
    assign start_edge = start & ~start_prev;
    assign stop_edge = stop & ~stop_prev;
    assign set_min_edge = set_min & ~set_min_prev;
    assign set_hour_edge = set_hour & ~set_hour_prev;
    assign countdown_mode_edge = countdown_mode & ~countdown_mode_prev;
    
    // Edge detection registers update
    always @(posedge clk_200hz or posedge rst) begin
        if (rst) begin
            start_prev <= 1'b0;
            stop_prev <= 1'b0;
            set_min_prev <= 1'b0;
            set_hour_prev <= 1'b0;
            countdown_mode_prev <= 1'b0;
        end
        else begin
            start_prev <= start;
            stop_prev <= stop;
            set_min_prev <= set_min;
            set_hour_prev <= set_hour;
            countdown_mode_prev <= countdown_mode;
        end
    end
    
    // Check if timer is at zero
    wire at_zero;
    assign at_zero = (hour == 8'd0) && (min == 8'd0) && (sec == 8'd0) && (centisec == 8'd0);
    
    // State machine and counter logic
    always @(posedge clk_100hz or posedge rst) begin
        if (rst) begin
            state <= STOPPED;
            centisec <= 8'd0;
            sec <= 8'd0;
            min <= 8'd0;
            hour <= 8'd0;
        end
        else begin
            // Handle mode switching - set default countdown value when entering countdown mode
            if (countdown_mode_edge) begin
                // Entering countdown mode - set to 1 minute default
                centisec <= 8'd0;
                sec <= 8'd0;
                min <= 8'd1;
                hour <= 8'd0;
                state <= STOPPED;
            end
            // Handle start button
            else if (start_edge) begin
                state <= RUNNING;
            end
            // Handle stop button
            else if (stop_edge) begin
                state <= STOPPED;
            end
            // Handle set_min button (only in countdown mode when stopped)
            else if (countdown_mode && state == STOPPED && set_min_edge) begin
                if (min >= 8'd59)
                    min <= 8'd0;
                else
                    min <= min + 1'b1;
            end
            // Handle set_hour button (only in countdown mode when stopped)
            else if (countdown_mode && state == STOPPED && set_hour_edge) begin
                if (hour >= 8'd99)
                    hour <= 8'd0;
                else
                    hour <= hour + 1'b1;
            end
            // Counter operation when running
            else if (state == RUNNING) begin
                if (countdown_mode) begin
                    // Countdown mode
                    if (!at_zero) begin
                        if (centisec > 8'd0) begin
                            centisec <= centisec - 1'b1;
                        end
                        else begin
                            centisec <= 8'd99;
                            if (sec > 8'd0) begin
                                sec <= sec - 1'b1;
                            end
                            else begin
                                sec <= 8'd59;
                                if (min > 8'd0) begin
                                    min <= min - 1'b1;
                                end
                                else begin
                                    min <= 8'd59;
                                    if (hour > 8'd0) begin
                                        hour <= hour - 1'b1;
                                    end
                                    else begin
                                        // Reached zero - stop
                                        centisec <= 8'd0;
                                        sec <= 8'd0;
                                        min <= 8'd0;
                                        hour <= 8'd0;
                                        state <= STOPPED;
                                    end
                                end
                            end
                        end
                    end
                    // Note: The at_zero==true case is handled inside the countdown logic
                    // which sets state to STOPPED when hour hits 0 and all others are 0
                end
                else begin
                    // Stopwatch mode (count up)
                    if (centisec >= 8'd99) begin
                        centisec <= 8'd0;
                        if (sec >= 8'd59) begin
                            sec <= 8'd0;
                            if (min >= 8'd59) begin
                                min <= 8'd0;
                                if (hour >= 8'd99) begin
                                    hour <= 8'd0; // Wrap around
                                end
                                else begin
                                    hour <= hour + 1'b1;
                                end
                            end
                            else begin
                                min <= min + 1'b1;
                            end
                        end
                        else begin
                            sec <= sec + 1'b1;
                        end
                    end
                    else begin
                        centisec <= centisec + 1'b1;
                    end
                end
            end
        end
    end

endmodule
