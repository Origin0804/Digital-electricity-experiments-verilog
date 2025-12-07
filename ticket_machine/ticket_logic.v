// Ticket Machine Logic Module
// Implements automatic ticket vending machine
// Features:
//   - Tickets: 2, 3, 4, 5 yuan
//   - Coins: 1, 5, 10 yuan
//   - Change calculation and ticket dispensing
//   - Insufficient funds alarm

module ticket_logic(
    input clk,              // System clock
    input rst,              // Active high reset
    input clear_sales,      // Clear total sales (S0)
    input coin_1,           // Insert 1 yuan coin (S1)
    input coin_5,           // Insert 5 yuan coin (S2)
    input coin_10,          // Insert 10 yuan coin (S3)
    input [3:0] ticket_sel, // Ticket selection SW0-SW3 (2,3,4,5 yuan)
    input confirm,          // Confirm transaction (SW7)
    output reg [7:0] display_val,  // Value to display (price/inserted/change)
    output reg [7:0] total_sales,  // Total sales amount
    output reg [3:0] ticket_out,   // Ticket output LEDs (D1-D4)
    output reg alarm,              // Insufficient funds alarm
    output reg [1:0] display_mode  // 0=price, 1=inserted, 2=change
);

    // Internal registers
    reg [7:0] inserted_amount;  // Amount inserted so far
    reg [7:0] ticket_price;     // Selected ticket price
    reg [7:0] change_amount;    // Change to return
    
    // Alarm timer (3 seconds at assumed clock rate)
    reg [7:0] alarm_counter;
    
    // State machine
    localparam IDLE = 2'd0;
    localparam INSERTING = 2'd1;
    localparam DISPENSING = 2'd2;
    localparam ALARMING = 2'd3;
    
    reg [1:0] state;
    reg confirm_prev;
    
    // Ticket price decoder
    always @(*) begin
        case (ticket_sel)
            4'b0001: ticket_price = 8'd2;   // SW0: 2 yuan
            4'b0010: ticket_price = 8'd3;   // SW1: 3 yuan
            4'b0100: ticket_price = 8'd4;   // SW2: 4 yuan
            4'b1000: ticket_price = 8'd5;   // SW3: 5 yuan
            default: ticket_price = 8'd0;   // No selection
        endcase
    end
    
    // Main state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            inserted_amount <= 8'd0;
            change_amount <= 8'd0;
            total_sales <= 8'd0;
            ticket_out <= 4'b0000;
            alarm <= 1'b0;
            alarm_counter <= 8'd0;
            display_val <= 8'd0;
            display_mode <= 2'd0;
            confirm_prev <= 1'b0;
        end
        else begin
            confirm_prev <= confirm;
            
            // Clear sales
            if (clear_sales) begin
                total_sales <= 8'd0;
            end
            
            case (state)
                IDLE: begin
                    ticket_out <= 4'b0000;
                    alarm <= 1'b0;
                    inserted_amount <= 8'd0;
                    change_amount <= 8'd0;
                    display_val <= ticket_price;
                    display_mode <= 2'd0;  // Show price
                    
                    // Start transaction when coin inserted
                    if (coin_1 || coin_5 || coin_10) begin
                        if (coin_1) inserted_amount <= 8'd1;
                        else if (coin_5) inserted_amount <= 8'd5;
                        else if (coin_10) inserted_amount <= 8'd10;
                        state <= INSERTING;
                    end
                end
                
                INSERTING: begin
                    display_val <= inserted_amount;
                    display_mode <= 2'd1;  // Show inserted amount
                    
                    // Accept more coins
                    if (coin_1) inserted_amount <= inserted_amount + 8'd1;
                    else if (coin_5) inserted_amount <= inserted_amount + 8'd5;
                    else if (coin_10) inserted_amount <= inserted_amount + 8'd10;
                    
                    // Check for transaction confirmation (rising edge)
                    if (confirm && !confirm_prev) begin
                        if (ticket_price == 0) begin
                            // No ticket selected, return to idle
                            state <= IDLE;
                        end
                        else if (inserted_amount >= ticket_price) begin
                            // Sufficient funds
                            change_amount <= inserted_amount - ticket_price;
                            total_sales <= total_sales + ticket_price;
                            state <= DISPENSING;
                        end
                        else begin
                            // Insufficient funds
                            alarm_counter <= 8'd150;  // 3 seconds at 50Hz assumed
                            state <= ALARMING;
                        end
                    end
                end
                
                DISPENSING: begin
                    display_val <= change_amount;
                    display_mode <= 2'd2;  // Show change
                    
                    // Indicate ticket dispensed based on selection
                    ticket_out <= ticket_sel;
                    
                    // Return to idle after a brief display
                    if (!confirm) begin
                        state <= IDLE;
                    end
                end
                
                ALARMING: begin
                    alarm <= 1'b1;
                    display_val <= inserted_amount;
                    display_mode <= 2'd1;
                    
                    if (alarm_counter > 0) begin
                        alarm_counter <= alarm_counter - 1'b1;
                    end
                    else begin
                        alarm <= 1'b0;
                        state <= INSERTING;  // Return to inserting state
                    end
                end
            endcase
        end
    end

endmodule
