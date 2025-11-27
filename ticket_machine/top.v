// Top-Level Module for Automatic Ticket Machine
// Integrates all components for EGO1 FPGA board
// Lab6_4: Ticket vending machine with coin input and change calculation

module top(
    input clk,              // 100MHz clock (P17)
    input s0,               // Clear sales button (R11)
    input s1,               // Insert 1 yuan (R17)
    input s2,               // Insert 5 yuan (R15)
    input s3,               // Insert 10 yuan (V1)
    input [3:0] sw,         // SW0-SW3 ticket selection (R1, N4, M4, R2)
    input sw7,              // Confirm transaction (P5)
    output [7:0] an,        // Anode select
    output [7:0] duan,      // Segment data for right bank
    output [7:0] duan1,     // Segment data for left bank
    output [3:0] led_ticket,// Ticket dispensed LEDs (D1-D4)
    output [7:0] led_alarm  // Alarm LEDs (D9-D16)
);

    // Internal wires
    wire clk_2Hz;
    wire clk_scan;
    wire clk_db;
    
    // Debounced signals
    wire s0_db, s1_db, s2_db, s3_db;
    wire [3:0] sw_db;
    wire sw7_db;
    
    // Ticket logic outputs
    wire [7:0] display_val;
    wire [7:0] total_sales;
    wire [3:0] ticket_out;
    wire alarm;
    wire [1:0] display_mode;
    
    // Reset from S0
    wire rst = s0_db;
    
    // Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(s0),
        .clk_2Hz(clk_2Hz),
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
        .sw_in(sw),
        .sw7_in(sw7),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db),
        .s3_out(s3_db),
        .sw_out(sw_db),
        .sw7_out(sw7_db)
    );
    
    // Ticket logic instance
    ticket_logic u_ticket(
        .clk(clk_db),
        .rst(rst),
        .clear_sales(s0_db),
        .coin_1(s1_db),
        .coin_5(s2_db),
        .coin_10(s3_db),
        .ticket_sel(sw_db),
        .confirm(sw7_db),
        .display_val(display_val),
        .total_sales(total_sales),
        .ticket_out(ticket_out),
        .alarm(alarm),
        .display_mode(display_mode)
    );
    
    // Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .clk_2Hz(clk_2Hz),
        .rst(rst),
        .display_val(display_val),
        .total_sales(total_sales),
        .display_mode(display_mode),
        .alarm(alarm),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );
    
    // Output assignments
    assign led_ticket = ticket_out;
    assign led_alarm = alarm ? 8'hFF : 8'h00;

endmodule
