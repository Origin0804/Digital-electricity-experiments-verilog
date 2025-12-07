// Enhanced Stopwatch Logic Module with Multi-Timer and Lap Timing
// Supports 2 independent timers with lap recording (up to 10 laps each)
// Higher resolution: milliseconds (0.001s) instead of centiseconds
// Display format: HH-MM-SS-MS (hours, minutes, seconds, milliseconds 0-999)

module stopwatch_multi_logic(
    input clk_1kHz,         // 1kHz timing clock for millisecond resolution
    input rst,              // Active high reset
    input start,            // Start button (pulse) - starts/resumes current timer
    input stop,             // Stop button (pulse) - stops current timer
    input lap,              // Lap button (pulse) - records lap time
    input timer_sel,        // Timer select switch (0=Timer1, 1=Timer2)
    input view_sel,         // View select (0=current time, 1=lap records)
    input [3:0] lap_view,   // Which lap to view (0-9)
    input min_inc,          // Minute increment button (pulse)
    input hour_inc,         // Hour increment button (pulse)
    input countdown_mode,   // Countdown mode enable (level, debounced)
    output reg [7:0] hours,     // Hours (0-99)
    output reg [7:0] minutes,   // Minutes (0-59)
    output reg [7:0] seconds,   // Seconds (0-59)
    output reg [9:0] millisec,  // Milliseconds (0-999)
    output stopped,             // High when current timer is stopped
    output reg [3:0] lap_count  // Number of laps recorded for current timer
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam RUNNING = 2'b01;
    localparam STOPPED = 2'b10;
    
    // Timer 1 registers
    reg [1:0] state1;
    reg [7:0] hours1, minutes1, seconds1;
    reg [9:0] millisec1;
    reg [3:0] lap_count1;
    
    // Timer 2 registers
    reg [1:0] state2;
    reg [7:0] hours2, minutes2, seconds2;
    reg [9:0] millisec2;
    reg [3:0] lap_count2;
    
    // Lap storage for Timer 1 (10 laps max)
    reg [7:0] lap1_hours [0:9];
    reg [7:0] lap1_minutes [0:9];
    reg [7:0] lap1_seconds [0:9];
    reg [9:0] lap1_millisec [0:9];
    
    // Lap storage for Timer 2 (10 laps max)
    reg [7:0] lap2_hours [0:9];
    reg [7:0] lap2_minutes [0:9];
    reg [7:0] lap2_seconds [0:9];
    reg [9:0] lap2_millisec [0:9];
    
    // Previous countdown mode state for edge detection (shared across timers)
    reg countdown_mode_prev;
    
    // Current timer selection
    wire is_timer1 = ~timer_sel;
    wire is_timer2 = timer_sel;
    
    // Current timer state and values
    wire [1:0] current_state = is_timer1 ? state1 : state2;
    wire [7:0] current_hours = is_timer1 ? hours1 : hours2;
    wire [7:0] current_minutes = is_timer1 ? minutes1 : minutes2;
    wire [7:0] current_seconds = is_timer1 ? seconds1 : seconds2;
    wire [9:0] current_millisec = is_timer1 ? millisec1 : millisec2;
    wire [3:0] current_lap_count = is_timer1 ? lap_count1 : lap_count2;
    
    // Output current timer status
    assign stopped = (current_state == STOPPED);
    
    // Output display values based on view selection
    always @(*) begin
        lap_count = current_lap_count;
        
        if (view_sel && lap_view < current_lap_count) begin
            // Display lap record
            if (is_timer1) begin
                hours = lap1_hours[lap_view];
                minutes = lap1_minutes[lap_view];
                seconds = lap1_seconds[lap_view];
                millisec = lap1_millisec[lap_view];
            end else begin
                hours = lap2_hours[lap_view];
                minutes = lap2_minutes[lap_view];
                seconds = lap2_seconds[lap_view];
                millisec = lap2_millisec[lap_view];
            end
        end else begin
            // Display current timer value
            hours = current_hours;
            minutes = current_minutes;
            seconds = current_seconds;
            millisec = current_millisec;
        end
    end
    
    // Integer for loop initialization
    integer i;
    
    // Countdown mode edge detection (shared, updated every clock cycle)
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst)
            countdown_mode_prev <= 1'b0;
        else
            countdown_mode_prev <= countdown_mode;
    end
    
    // Timer 1 control and counting
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst) begin
            state1 <= IDLE;
            hours1 <= 8'd0;
            minutes1 <= 8'd0;
            seconds1 <= 8'd0;
            millisec1 <= 10'd0;
            lap_count1 <= 4'd0;
            
            // Clear all lap records for timer 1
            for (i = 0; i < 10; i = i + 1) begin
                lap1_hours[i] <= 8'd0;
                lap1_minutes[i] <= 8'd0;
                lap1_seconds[i] <= 8'd0;
                lap1_millisec[i] <= 10'd0;
            end
        end
        else if (is_timer1) begin
            
            // State machine logic
            case (state1)
                IDLE: begin
                    if (start) begin
                        state1 <= RUNNING;
                        lap_count1 <= 4'd0;  // Reset lap count on new start
                    end
                    
                    // Load default countdown value when entering countdown mode (rising edge)
                    if (countdown_mode && !countdown_mode_prev) begin
                        hours1 <= 8'd0;
                        minutes1 <= 8'd1;
                        seconds1 <= 8'd0;
                        millisec1 <= 10'd0;
                    end
                    // Clear when leaving countdown mode (falling edge)
                    else if (!countdown_mode && countdown_mode_prev) begin
                        hours1 <= 8'd0;
                        minutes1 <= 8'd0;
                        seconds1 <= 8'd0;
                        millisec1 <= 10'd0;
                    end
                    // Time adjustment in countdown mode
                    else if (countdown_mode) begin
                        if (min_inc) begin
                            if (minutes1 >= 8'd59)
                                minutes1 <= 8'd0;
                            else
                                minutes1 <= minutes1 + 1'b1;
                        end
                        if (hour_inc) begin
                            if (hours1 >= 8'd99)
                                hours1 <= 8'd0;
                            else
                                hours1 <= hours1 + 1'b1;
                        end
                    end
                end
                
                RUNNING: begin
                    if (stop) begin
                        state1 <= STOPPED;
                    end
                    // Record lap time
                    else if (lap && lap_count1 < 4'd10) begin
                        lap1_hours[lap_count1] <= hours1;
                        lap1_minutes[lap_count1] <= minutes1;
                        lap1_seconds[lap_count1] <= seconds1;
                        lap1_millisec[lap_count1] <= millisec1;
                        lap_count1 <= lap_count1 + 1'b1;
                    end
                    
                    // Stop at zero in countdown mode
                    if (countdown_mode && hours1 == 0 && minutes1 == 0 && 
                        seconds1 == 0 && millisec1 == 0) begin
                        state1 <= STOPPED;
                    end
                    else begin
                        // Counting logic
                        if (countdown_mode) begin
                            // Countdown logic
                            if (millisec1 > 0) begin
                                millisec1 <= millisec1 - 1'b1;
                            end
                            else begin
                                millisec1 <= 10'd999;
                                if (seconds1 > 0) begin
                                    seconds1 <= seconds1 - 1'b1;
                                end
                                else begin
                                    seconds1 <= 8'd59;
                                    if (minutes1 > 0) begin
                                        minutes1 <= minutes1 - 1'b1;
                                    end
                                    else begin
                                        minutes1 <= 8'd59;
                                        if (hours1 > 0) begin
                                            hours1 <= hours1 - 1'b1;
                                        end
                                        else begin
                                            // Reached zero
                                            hours1 <= 8'd0;
                                            minutes1 <= 8'd0;
                                            seconds1 <= 8'd0;
                                            millisec1 <= 10'd0;
                                        end
                                    end
                                end
                            end
                        end
                        else begin
                            // Count up logic
                            if (millisec1 >= 10'd999) begin
                                millisec1 <= 10'd0;
                                if (seconds1 >= 8'd59) begin
                                    seconds1 <= 8'd0;
                                    if (minutes1 >= 8'd59) begin
                                        minutes1 <= 8'd0;
                                        if (hours1 >= 8'd99)
                                            hours1 <= 8'd0;
                                        else
                                            hours1 <= hours1 + 1'b1;
                                    end
                                    else begin
                                        minutes1 <= minutes1 + 1'b1;
                                    end
                                end
                                else begin
                                    seconds1 <= seconds1 + 1'b1;
                                end
                            end
                            else begin
                                millisec1 <= millisec1 + 1'b1;
                            end
                        end
                    end
                end
                
                STOPPED: begin
                    if (start) begin
                        state1 <= RUNNING;
                    end
                    // Time adjustment in countdown mode when stopped
                    else if (countdown_mode && state1 == STOPPED) begin
                        if (min_inc) begin
                            if (minutes1 >= 8'd59)
                                minutes1 <= 8'd0;
                            else
                                minutes1 <= minutes1 + 1'b1;
                        end
                        if (hour_inc) begin
                            if (hours1 >= 8'd99)
                                hours1 <= 8'd0;
                            else
                                hours1 <= hours1 + 1'b1;
                        end
                    end
                    // Record lap time when stopped (stopwatch mode)
                    else if (!countdown_mode && lap && lap_count1 < 4'd10) begin
                        lap1_hours[lap_count1] <= hours1;
                        lap1_minutes[lap_count1] <= minutes1;
                        lap1_seconds[lap_count1] <= seconds1;
                        lap1_millisec[lap_count1] <= millisec1;
                        lap_count1 <= lap_count1 + 1'b1;
                    end
                end
                
                default: state1 <= IDLE;
            endcase
        end
    end
    
    // Timer 2 control and counting
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst) begin
            state2 <= IDLE;
            hours2 <= 8'd0;
            minutes2 <= 8'd0;
            seconds2 <= 8'd0;
            millisec2 <= 10'd0;
            lap_count2 <= 4'd0;
            
            // Clear all lap records for timer 2
            for (i = 0; i < 10; i = i + 1) begin
                lap2_hours[i] <= 8'd0;
                lap2_minutes[i] <= 8'd0;
                lap2_seconds[i] <= 8'd0;
                lap2_millisec[i] <= 10'd0;
            end
        end
        else if (is_timer2) begin
            // State machine logic
            case (state2)
                IDLE: begin
                    if (start) begin
                        state2 <= RUNNING;
                        lap_count2 <= 4'd0;  // Reset lap count on new start
                    end
                    
                    // Load default countdown value when entering countdown mode (rising edge)
                    if (countdown_mode && !countdown_mode_prev) begin
                        hours2 <= 8'd0;
                        minutes2 <= 8'd1;
                        seconds2 <= 8'd0;
                        millisec2 <= 10'd0;
                    end
                    // Clear when leaving countdown mode (falling edge)
                    else if (!countdown_mode && countdown_mode_prev) begin
                        hours2 <= 8'd0;
                        minutes2 <= 8'd0;
                        seconds2 <= 8'd0;
                        millisec2 <= 10'd0;
                    end
                    // Time adjustment in countdown mode
                    else if (countdown_mode) begin
                        if (min_inc) begin
                            if (minutes2 >= 8'd59)
                                minutes2 <= 8'd0;
                            else
                                minutes2 <= minutes2 + 1'b1;
                        end
                        if (hour_inc) begin
                            if (hours2 >= 8'd99)
                                hours2 <= 8'd0;
                            else
                                hours2 <= hours2 + 1'b1;
                        end
                    end
                end
                
                RUNNING: begin
                    if (stop) begin
                        state2 <= STOPPED;
                    end
                    // Record lap time
                    else if (lap && lap_count2 < 4'd10) begin
                        lap2_hours[lap_count2] <= hours2;
                        lap2_minutes[lap_count2] <= minutes2;
                        lap2_seconds[lap_count2] <= seconds2;
                        lap2_millisec[lap_count2] <= millisec2;
                        lap_count2 <= lap_count2 + 1'b1;
                    end
                    
                    // Stop at zero in countdown mode
                    if (countdown_mode && hours2 == 0 && minutes2 == 0 && 
                        seconds2 == 0 && millisec2 == 0) begin
                        state2 <= STOPPED;
                    end
                    else begin
                        // Counting logic
                        if (countdown_mode) begin
                            // Countdown logic
                            if (millisec2 > 0) begin
                                millisec2 <= millisec2 - 1'b1;
                            end
                            else begin
                                millisec2 <= 10'd999;
                                if (seconds2 > 0) begin
                                    seconds2 <= seconds2 - 1'b1;
                                end
                                else begin
                                    seconds2 <= 8'd59;
                                    if (minutes2 > 0) begin
                                        minutes2 <= minutes2 - 1'b1;
                                    end
                                    else begin
                                        minutes2 <= 8'd59;
                                        if (hours2 > 0) begin
                                            hours2 <= hours2 - 1'b1;
                                        end
                                        else begin
                                            // Reached zero
                                            hours2 <= 8'd0;
                                            minutes2 <= 8'd0;
                                            seconds2 <= 8'd0;
                                            millisec2 <= 10'd0;
                                        end
                                    end
                                end
                            end
                        end
                        else begin
                            // Count up logic
                            if (millisec2 >= 10'd999) begin
                                millisec2 <= 10'd0;
                                if (seconds2 >= 8'd59) begin
                                    seconds2 <= 8'd0;
                                    if (minutes2 >= 8'd59) begin
                                        minutes2 <= 8'd0;
                                        if (hours2 >= 8'd99)
                                            hours2 <= 8'd0;
                                        else
                                            hours2 <= hours2 + 1'b1;
                                    end
                                    else begin
                                        minutes2 <= minutes2 + 1'b1;
                                    end
                                end
                                else begin
                                    seconds2 <= seconds2 + 1'b1;
                                end
                            end
                            else begin
                                millisec2 <= millisec2 + 1'b1;
                            end
                        end
                    end
                end
                
                STOPPED: begin
                    if (start) begin
                        state2 <= RUNNING;
                    end
                    // Time adjustment in countdown mode when stopped
                    else if (countdown_mode && state2 == STOPPED) begin
                        if (min_inc) begin
                            if (minutes2 >= 8'd59)
                                minutes2 <= 8'd0;
                            else
                                minutes2 <= minutes2 + 1'b1;
                        end
                        if (hour_inc) begin
                            if (hours2 >= 8'd99)
                                hours2 <= 8'd0;
                            else
                                hours2 <= hours2 + 1'b1;
                        end
                    end
                    // Record lap time when stopped (stopwatch mode)
                    else if (!countdown_mode && lap && lap_count2 < 4'd10) begin
                        lap2_hours[lap_count2] <= hours2;
                        lap2_minutes[lap_count2] <= minutes2;
                        lap2_seconds[lap_count2] <= seconds2;
                        lap2_millisec[lap_count2] <= millisec2;
                        lap_count2 <= lap_count2 + 1'b1;
                    end
                end
                
                default: state2 <= IDLE;
            endcase
        end
    end

endmodule
