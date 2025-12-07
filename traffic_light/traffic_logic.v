// Traffic Light Controller Logic Module
// Implements traffic light control for major and minor roads
// Features:
//   - Major road: 40s green, 5s yellow
//   - Minor road: 20s green, 5s yellow
//   - Emergency mode for either road
//   - Green-to-red has yellow transition, red-to-green is direct

module traffic_logic(
    input clk_1Hz,          // 1Hz timing clock
    input rst,              // Active high reset
    input minor_emergency,  // Minor road emergency (S0)
    input major_emergency,  // Major road emergency (S1)
    output reg [5:0] major_countdown,   // Major road countdown
    output reg [5:0] minor_countdown,   // Minor road countdown
    output reg [2:0] major_light,       // Major: [2]=R, [1]=Y, [0]=G
    output reg [2:0] minor_light        // Minor: [2]=R, [1]=Y, [0]=G
);

    // State definitions
    localparam MAJOR_GREEN  = 3'd0;  // Major green, minor red
    localparam MAJOR_YELLOW = 3'd1;  // Major yellow, minor red
    localparam MINOR_GREEN  = 3'd2;  // Minor green, major red
    localparam MINOR_YELLOW = 3'd3;  // Minor yellow, major red
    localparam EMERGENCY_MAJOR = 3'd4;  // Emergency: major green
    localparam EMERGENCY_MINOR = 3'd5;  // Emergency: minor green
    
    reg [2:0] state;
    reg [5:0] timer;
    
    // Timing parameters
    localparam MAJOR_GREEN_TIME = 6'd40;
    localparam MINOR_GREEN_TIME = 6'd20;
    localparam YELLOW_TIME = 6'd5;
    
    // State machine
    always @(posedge clk_1Hz or posedge rst) begin
        if (rst) begin
            state <= MAJOR_GREEN;
            timer <= MAJOR_GREEN_TIME;
            major_countdown <= MAJOR_GREEN_TIME;
            minor_countdown <= MAJOR_GREEN_TIME + YELLOW_TIME;
            major_light <= 3'b001;  // Green
            minor_light <= 3'b100;  // Red
        end
        else begin
            // Emergency handling
            if (minor_emergency) begin
                state <= EMERGENCY_MINOR;
                major_light <= 3'b100;  // Major red
                minor_light <= 3'b001;  // Minor green
                major_countdown <= 6'd0;
                minor_countdown <= 6'd0;
            end
            else if (major_emergency) begin
                state <= EMERGENCY_MAJOR;
                major_light <= 3'b001;  // Major green
                minor_light <= 3'b100;  // Minor red
                major_countdown <= 6'd0;
                minor_countdown <= 6'd0;
            end
            else begin
                // Normal operation
                case (state)
                    MAJOR_GREEN: begin
                        major_light <= 3'b001;  // Green
                        minor_light <= 3'b100;  // Red
                        major_countdown <= timer;
                        minor_countdown <= timer + YELLOW_TIME;
                        
                        if (timer > 0)
                            timer <= timer - 1'b1;
                        else begin
                            state <= MAJOR_YELLOW;
                            timer <= YELLOW_TIME;
                        end
                    end
                    
                    MAJOR_YELLOW: begin
                        major_light <= 3'b010;  // Yellow
                        minor_light <= 3'b100;  // Red
                        major_countdown <= timer;
                        minor_countdown <= timer;
                        
                        if (timer > 0)
                            timer <= timer - 1'b1;
                        else begin
                            state <= MINOR_GREEN;
                            timer <= MINOR_GREEN_TIME;
                        end
                    end
                    
                    MINOR_GREEN: begin
                        major_light <= 3'b100;  // Red
                        minor_light <= 3'b001;  // Green
                        major_countdown <= timer + YELLOW_TIME;
                        minor_countdown <= timer;
                        
                        if (timer > 0)
                            timer <= timer - 1'b1;
                        else begin
                            state <= MINOR_YELLOW;
                            timer <= YELLOW_TIME;
                        end
                    end
                    
                    MINOR_YELLOW: begin
                        major_light <= 3'b100;  // Red
                        minor_light <= 3'b010;  // Yellow
                        major_countdown <= timer;
                        minor_countdown <= timer;
                        
                        if (timer > 0)
                            timer <= timer - 1'b1;
                        else begin
                            state <= MAJOR_GREEN;
                            timer <= MAJOR_GREEN_TIME;
                        end
                    end
                    
                    EMERGENCY_MAJOR: begin
                        major_light <= 3'b001;  // Green
                        minor_light <= 3'b100;  // Red
                        // Stay in emergency until released, then handled above
                    end
                    
                    EMERGENCY_MINOR: begin
                        major_light <= 3'b100;  // Red
                        minor_light <= 3'b001;  // Green
                        // Stay in emergency until released
                    end
                    
                    default: begin
                        state <= MAJOR_GREEN;
                        timer <= MAJOR_GREEN_TIME;
                    end
                endcase
            end
        end
    end

endmodule
