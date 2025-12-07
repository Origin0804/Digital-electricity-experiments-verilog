// Stopwatch Logic Module
// Implements state machine and counters for hh:mm:ss:xx (hours, minutes, seconds, centiseconds)
// Supports both count up (stopwatch) and count down (countdown timer) modes

module stopwatch_logic(
    input clk_100Hz,        // 100Hz timing clock
    input rst,              // Active high reset
    input start,            // Start button (pulse)
    input stop,             // Stop button (pulse)
    input min_inc,          // Minute increment button (pulse)
    input hour_inc,         // Hour increment button (pulse)
    input countdown_mode,   // Countdown mode enable (level, debounced)
    output reg [7:0] hours,     // Hours (0-99)
    output reg [7:0] minutes,   // Minutes (0-59)
    output reg [7:0] seconds,   // Seconds (0-59)
    output reg [7:0] centisec,  // Centiseconds (0-99)
    output stopped              // High when state machine is in STOPPED
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam RUNNING = 2'b01;
    localparam STOPPED = 2'b10;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    // Previous countdown mode state for edge detection
    reg countdown_mode_prev;
    
    // State machine - next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = RUNNING;
            end
            RUNNING: begin
                if (stop)
                    next_state = STOPPED;
                // Stop at zero in countdown mode
                if (countdown_mode && hours == 0 && minutes == 0 && 
                    seconds == 0 && centisec == 0)
                    next_state = STOPPED;
            end
            STOPPED: begin
                if (start)
                    next_state = RUNNING;
            end
            default: next_state = IDLE;
        endcase
    end
    
    // State machine - state register
    always @(posedge clk_100Hz or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Expose STOPPED state for blink/indication
    assign stopped = (state == STOPPED);
    
    // Counter logic
    always @(posedge clk_100Hz or posedge rst) begin
        if (rst) begin
            hours <= 8'd0;
            minutes <= 8'd0;
            seconds <= 8'd0;
            centisec <= 8'd0;
            countdown_mode_prev <= 1'b0;
        end
        else begin
            // Store previous countdown mode for edge detection
            countdown_mode_prev <= countdown_mode;
            
            // Load default countdown value when entering countdown mode (rising edge)
            if (countdown_mode && !countdown_mode_prev) begin
                // Load default 1 minute when countdown mode is enabled
                hours <= 8'd0;
                minutes <= 8'd1;
                seconds <= 8'd0;
                centisec <= 8'd0;
            end
            // Clear when leaving countdown mode (falling edge)
            else if (!countdown_mode && countdown_mode_prev) begin
                hours <= 8'd0;
                minutes <= 8'd0;
                seconds <= 8'd0;
                centisec <= 8'd0;
            end
            // Time adjustment in countdown mode (when not running)
            else if (countdown_mode && (state == IDLE || state == STOPPED)) begin
                if (min_inc) begin
                    if (minutes >= 8'd59)
                        minutes <= 8'd0;
                    else
                        minutes <= minutes + 1'b1;
                end
                if (hour_inc) begin
                    if (hours >= 8'd99)
                        hours <= 8'd0;
                    else
                        hours <= hours + 1'b1;
                end
            end
            // Running state - counting
            else if (state == RUNNING) begin
                if (countdown_mode) begin
                    // Countdown logic (state machine handles zero detection and state transition)
                    if (centisec > 0) begin
                        centisec <= centisec - 1'b1;
                    end
                    else begin
                        centisec <= 8'd99;
                        if (seconds > 0) begin
                            seconds <= seconds - 1'b1;
                        end
                        else begin
                            seconds <= 8'd59;
                            if (minutes > 0) begin
                                minutes <= minutes - 1'b1;
                            end
                            else begin
                                minutes <= 8'd59;
                                if (hours > 0) begin
                                    hours <= hours - 1'b1;
                                end
                                else begin
                                    // Reached zero
                                    hours <= 8'd0;
                                    minutes <= 8'd0;
                                    seconds <= 8'd0;
                                    centisec <= 8'd0;
                                end
                            end
                        end
                    end
                end
                else begin
                    // Count up logic (stopwatch mode)
                    if (centisec >= 8'd99) begin
                        centisec <= 8'd0;
                        if (seconds >= 8'd59) begin
                            seconds <= 8'd0;
                            if (minutes >= 8'd59) begin
                                minutes <= 8'd0;
                                if (hours >= 8'd99)
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
                    else begin
                        centisec <= centisec + 1'b1;
                    end
                end
            end
        end
    end

endmodule
