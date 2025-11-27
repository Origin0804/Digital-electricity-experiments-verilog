// Top-Level Module for Simple Calculator
// Integrates all components for EGO1 FPGA board
// Lab6_8: Add, subtract, multiply with sequential execution

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Clear button (R11)
    input s1,               // Add button (R17)
    input s2,               // Subtract button (R15)
    input s3,               // Multiply button (V1)
    input s4,               // Enter/Equals button (U4)
    input [7:0] sw,         // Number input switches (SW0-SW7)
    output [7:0] an,        // Anode select
    output [7:0] duan,      // Segment data for right bank
    output [7:0] duan1      // Segment data for left bank
);

    // Internal wires
    wire clk_scan;
    wire clk_db;
    
    // Debounced signals
    wire s0_db, s1_db, s2_db, s3_db, s4_db;
    wire [7:0] sw_db;
    
    // Calculator outputs
    wire [15:0] result;
    wire [1:0] op_display;
    
    // Reset from S0
    wire rst = s0_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s0),
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
        .s4_in(s4),
        .sw_in(sw),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db),
        .s3_out(s3_db),
        .s4_out(s4_db),
        .sw_out(sw_db)
    );
    
    // Calculator logic instance
    calc_logic u_calc(
        .clk_db(clk_db),
        .rst(rst),
        .op_add(s1_db),
        .op_sub(s2_db),
        .op_mul(s3_db),
        .op_enter(s4_db),
        .num_input(sw_db),
        .result(result),
        .op_display(op_display)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .result(result),
        .num_input(sw_db),
        .op_display(op_display),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
