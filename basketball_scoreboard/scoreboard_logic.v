// Scoreboard Logic Module for Basketball Scoreboard
// Implements score tracking and 24-second shot clock
// Features:
//   - Team A and Team B scores
//   - 24-second shot clock for possession
//   - Add 1, 2, or 3 points
// Control:
//   - SW0 high: Team A 24s countdown running
//   - SW0 low: Press S1/S2/S3 to add 1/2/3 points to Team A
//   - SW7 high: Team B 24s countdown running
//   - SW7 low: Press S1/S2/S3 to add 1/2/3 points to Team B

module scoreboard_logic(
    input clk_1Hz,          // 1Hz clock for countdown
    input clk_db,           // Debounce clock for score updates
    input rst,              // Active high reset
    input add_1,            // Add 1 point (S1)
    input add_2,            // Add 2 points (S2)
    input add_3,            // Add 3 points (S3)
    input team_a_poss,      // Team A possession (SW0 high = countdown)
    input team_b_poss,      // Team B possession (SW7 high = countdown)
    output reg [7:0] score_a,   // Team A score (0-99)
    output reg [7:0] score_b,   // Team B score (0-99)
    output reg [5:0] shot_clock // 24-second shot clock (0-24)
);

    // Previous possession states for edge detection
    reg team_a_poss_prev, team_b_poss_prev;
    reg reset_shot_clock;
    
    // Shot clock countdown logic
    always @(posedge clk_1Hz or posedge rst) begin
        if (rst) begin
            shot_clock <= 6'd24;
        end
        else if (reset_shot_clock) begin
            shot_clock <= 6'd24;
        end
        else begin
            // Countdown when either team has possession
            if (team_a_poss || team_b_poss) begin
                if (shot_clock > 0)
                    shot_clock <= shot_clock - 1'b1;
            end
        end
    end
    
    // Score and shot clock reset logic
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            score_a <= 8'd0;
            score_b <= 8'd0;
            team_a_poss_prev <= 1'b0;
            team_b_poss_prev <= 1'b0;
            reset_shot_clock <= 1'b0;
        end
        else begin
            team_a_poss_prev <= team_a_poss;
            team_b_poss_prev <= team_b_poss;
            reset_shot_clock <= 1'b0;
            
            // Reset shot clock when possession starts (rising edge)
            if ((team_a_poss && !team_a_poss_prev) || (team_b_poss && !team_b_poss_prev)) begin
                reset_shot_clock <= 1'b1;
            end
            
            // Team A scoring (when SW0 is low - countdown stopped)
            if (!team_a_poss) begin
                if (add_1) begin
                    if (score_a < 8'd99) score_a <= score_a + 8'd1;
                end
                else if (add_2) begin
                    if (score_a < 8'd98) score_a <= score_a + 8'd2;
                end
                else if (add_3) begin
                    if (score_a < 8'd97) score_a <= score_a + 8'd3;
                end
            end
            
            // Team B scoring (when SW7 is low - countdown stopped)
            if (!team_b_poss) begin
                if (add_1) begin
                    if (score_b < 8'd99) score_b <= score_b + 8'd1;
                end
                else if (add_2) begin
                    if (score_b < 8'd98) score_b <= score_b + 8'd2;
                end
                else if (add_3) begin
                    if (score_b < 8'd97) score_b <= score_b + 8'd3;
                end
            end
        end
    end

endmodule
