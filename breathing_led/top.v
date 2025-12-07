// Top-Level Module for Breathing LED
// Integrates all components for EGO1 FPGA board
// Lab6_7: PWM-controlled breathing LED effects

module top(
    input clk,              // 100MHz clock (P17)
    input s4,               // Reset button (U4)
    input sw0,              // Mode switch (R1): 0=alternate, 1=flowing
    output [15:0] led       // 16 LED outputs
);

    // Internal wires
    wire clk_pwm;
    wire clk_breath;
    wire clk_db;
    
    // Debounced signals
    wire s4_db;
    wire mode_db;
    
    // Reset from S4
    wire rst = s4_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s4),
        .clk_pwm(clk_pwm),
        .clk_breath(clk_breath),
        .clk_db(clk_db)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(s4),
        .s4_in(s4),
        .mode_in(sw0),
        .s4_out(s4_db),
        .mode_out(mode_db)
    );
    
    // Breathing logic instance
    breathing_logic u_breathing(
        .clk(clk),
        .clk_pwm(clk_pwm),
        .clk_breath(clk_breath),
        .rst(rst),
        .mode(mode_db),
        .led(led)
    );

endmodule
