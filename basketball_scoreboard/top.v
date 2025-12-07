// Top-Level Module for Basketball Scoreboard
// Integrates all components for EGO1 FPGA board
// Lab6_5: Basketball scoring with 24-second shot clock

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Reset button (R11)
    input s1,               // +1 point button (R17)
    input s2,               // +2 points button (R15)
    input s3,               // +3 points button (V1)
    input sw0,              // Team A possession switch (R1)
    input sw7,              // Team B possession switch (P5)
    output [7:0] an,        // Anode select
    output [7:0] duan,      // Segment data for right bank
    output [7:0] duan1      // Segment data for left bank
);

    // Internal wires
    wire clk_1Hz;
    wire clk_scan;
    wire clk_db;
    
    // Debounced signals
    wire s0_db, s1_db, s2_db, s3_db;
    wire sw0_db, sw7_db;
    
    // Scoreboard outputs
    wire [7:0] score_a, score_b;
    wire [5:0] shot_clock;
    
    // Reset from S0
    wire rst = s0_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s0),
        .clk_1Hz(clk_1Hz),
        .clk_scan(clk_scan),
        .clk_db(clk_db)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(s0),
        .s0_in(s0),
        .s1_in(s1),
        .s2_in(s2),
        .s3_in(s3),
        .sw0_in(sw0),
        .sw7_in(sw7),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db),
        .s3_out(s3_db),
        .sw0_out(sw0_db),
        .sw7_out(sw7_db)
    );
    
    // Scoreboard logic instance
    scoreboard_logic u_scoreboard(
        .clk_1Hz(clk_1Hz),
        .clk_db(clk_db),
        .rst(rst),
        .add_1(s1_db),
        .add_2(s2_db),
        .add_3(s3_db),
        .team_a_poss(sw0_db),
        .team_b_poss(sw7_db),
        .score_a(score_a),
        .score_b(score_b),
        .shot_clock(shot_clock)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .score_a(score_a),
        .score_b(score_b),
        .shot_clock(shot_clock),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
