// Top-Level Module for Traffic Light Controller
// Integrates all components for EGO1 FPGA board
// Lab6_6: Traffic light control with emergency modes

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Minor road emergency (R11)
    input s1,               // Major road emergency (R17)
    input s4,               // Reset button (U4)
    output [7:0] an,        // Anode select
    output [7:0] duan,      // Segment data for right bank
    output [7:0] duan1,     // Segment data for left bank
    output [5:0] led        // Traffic light LEDs: [5:3]=Major RYG, [2:0]=Minor RYG
);

    // Internal wires
    wire clk_1Hz;
    wire clk_scan;
    wire clk_db;
    
    // Debounced signals
    wire s0_db, s1_db, s4_db;
    
    // Traffic light outputs
    wire [5:0] major_countdown, minor_countdown;
    wire [2:0] major_light, minor_light;
    
    // Reset from S4
    wire rst = s4_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s4),
        .clk_1Hz(clk_1Hz),
        .clk_scan(clk_scan),
        .clk_db(clk_db)
    );
    
    // Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(s4),
        .s0_in(s0),
        .s1_in(s1),
        .s4_in(s4),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s4_out(s4_db)
    );
    
    // Traffic logic instance
    traffic_logic u_traffic(
        .clk_1Hz(clk_1Hz),
        .rst(rst),
        .minor_emergency(s0_db),
        .major_emergency(s1_db),
        .major_countdown(major_countdown),
        .minor_countdown(minor_countdown),
        .major_light(major_light),
        .minor_light(minor_light)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .major_countdown(major_countdown),
        .minor_countdown(minor_countdown),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );
    
    // LED output: Major road lights (LED5-3: R,Y,G), Minor road lights (LED2-0: R,Y,G)
    assign led = {major_light, minor_light};

endmodule
