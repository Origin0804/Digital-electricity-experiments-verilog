// Breathing LED Logic Module
// Implements PWM-based breathing effect for LEDs
// Features:
//   - Mode 1: Left 8 LEDs and right 8 LEDs alternate breathing (8s period)
//   - Mode 2: Flowing breathing effect (LEDs breath one by one)

module breathing_logic(
    input clk,              // Main clock
    input clk_pwm,          // PWM clock
    input clk_breath,       // Breathing update clock
    input rst,              // Active high reset
    input mode,             // 0=Mode1 (alternate), 1=Mode2 (flowing)
    output reg [15:0] led   // 16 LED outputs
);

    // PWM counter (8-bit for 256 brightness levels)
    reg [7:0] pwm_counter;
    
    // Brightness values
    reg [7:0] brightness;       // Current brightness level (0-255)
    reg direction;              // 0=increasing, 1=decreasing
    
    // Phase offset for mode 1 (second group is 180 degrees out of phase)
    reg [7:0] brightness_alt;
    
    // Flow position for mode 2
    reg [3:0] flow_pos;         // Current LED being lit (0-15)
    reg [7:0] flow_brightness;  // Brightness of current LED
    reg flow_direction;         // Direction of brightness change
    
    // Timing counter for 8-second cycle (at ~50Hz update rate = 400 steps per 8 seconds)
    // Each half cycle (fade in or fade out) = 200 steps
    // Brightness increment = 255 / 200 ≈ 1.27, use 1 for simplicity
    
    // PWM counter
    always @(posedge clk_pwm or posedge rst) begin
        if (rst)
            pwm_counter <= 8'd0;
        else
            pwm_counter <= pwm_counter + 1'b1;
    end
    
    // Brightness ramping for mode 1
    always @(posedge clk_breath or posedge rst) begin
        if (rst) begin
            brightness <= 8'd0;
            direction <= 1'b0;
        end
        else begin
            if (direction == 1'b0) begin
                // Increasing
                if (brightness >= 8'd254)
                    direction <= 1'b1;
                else
                    brightness <= brightness + 1'b1;
            end
            else begin
                // Decreasing
                if (brightness <= 8'd1)
                    direction <= 1'b0;
                else
                    brightness <= brightness - 1'b1;
            end
        end
    end
    
    // Alternate brightness (180 degrees out of phase)
    always @(*) begin
        brightness_alt = 8'd255 - brightness;
    end
    
    // Flow effect for mode 2
    always @(posedge clk_breath or posedge rst) begin
        if (rst) begin
            flow_pos <= 4'd0;
            flow_brightness <= 8'd0;
            flow_direction <= 1'b0;
        end
        else if (mode) begin
            if (flow_direction == 1'b0) begin
                // Increasing
                if (flow_brightness >= 8'd254) begin
                    flow_direction <= 1'b1;
                end
                else begin
                    flow_brightness <= flow_brightness + 8'd2;  // Faster for flow effect
                end
            end
            else begin
                // Decreasing
                if (flow_brightness <= 8'd1) begin
                    flow_direction <= 1'b0;
                    // Move to next LED
                    if (flow_pos >= 4'd15)
                        flow_pos <= 4'd0;
                    else
                        flow_pos <= flow_pos + 1'b1;
                end
                else begin
                    flow_brightness <= flow_brightness - 8'd2;
                end
            end
        end
    end
    
    // LED output generation with PWM
    always @(*) begin
        if (mode == 1'b0) begin
            // Mode 1: Alternate breathing
            // Left 8 LEDs use brightness, right 8 use brightness_alt
            if (pwm_counter < brightness)
                led[15:8] = 8'hFF;  // Left LEDs on
            else
                led[15:8] = 8'h00;  // Left LEDs off
                
            if (pwm_counter < brightness_alt)
                led[7:0] = 8'hFF;   // Right LEDs on
            else
                led[7:0] = 8'h00;   // Right LEDs off
        end
        else begin
            // Mode 2: Flowing breathing
            led = 16'h0000;
            if (pwm_counter < flow_brightness)
                led[flow_pos] = 1'b1;
        end
    end

endmodule
