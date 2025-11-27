// Calculator Logic Module
// Implements simple calculator with add, subtract, multiply
// Features:
//   - Sequential operations (no operator precedence)
//   - Accumulator-based calculation
//   - 16-bit result display

module calc_logic(
    input clk_db,           // Debounce clock
    input rst,              // Active high reset (clear)
    input op_add,           // Add operation (S1)
    input op_sub,           // Subtract operation (S2)
    input op_mul,           // Multiply operation (S3)
    input op_enter,         // Enter/Equals (S4)
    input [7:0] num_input,  // Number input from switches
    output reg [15:0] result,   // Current result
    output reg [1:0] op_display // Current operation: 0=none, 1=add, 2=sub, 3=mul
);

    // Internal registers
    reg [15:0] accumulator;     // Running total
    reg [15:0] operand;         // Current operand
    reg [1:0] pending_op;       // Pending operation
    reg first_entry;            // Flag for first number entry
    
    // State machine
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            accumulator <= 16'd0;
            operand <= 16'd0;
            pending_op <= 2'd0;
            result <= 16'd0;
            op_display <= 2'd0;
            first_entry <= 1'b1;
        end
        else begin
            // Read current input value
            operand <= {8'd0, num_input};
            
            // Enter/Equals - execute pending operation
            if (op_enter) begin
                case (pending_op)
                    2'd0: begin
                        // No pending operation, just store the value
                        accumulator <= {8'd0, num_input};
                        result <= {8'd0, num_input};
                    end
                    2'd1: begin
                        // Add
                        accumulator <= accumulator + {8'd0, num_input};
                        result <= accumulator + {8'd0, num_input};
                    end
                    2'd2: begin
                        // Subtract
                        accumulator <= accumulator - {8'd0, num_input};
                        result <= accumulator - {8'd0, num_input};
                    end
                    2'd3: begin
                        // Multiply
                        accumulator <= accumulator * {8'd0, num_input};
                        result <= accumulator * {8'd0, num_input};
                    end
                endcase
                pending_op <= 2'd0;
                op_display <= 2'd0;
                first_entry <= 1'b0;
            end
            // Operation buttons
            else if (op_add) begin
                if (first_entry) begin
                    accumulator <= {8'd0, num_input};
                    result <= {8'd0, num_input};
                    first_entry <= 1'b0;
                end
                else if (pending_op != 2'd0) begin
                    // Execute previous operation first
                    case (pending_op)
                        2'd1: accumulator <= accumulator + {8'd0, num_input};
                        2'd2: accumulator <= accumulator - {8'd0, num_input};
                        2'd3: accumulator <= accumulator * {8'd0, num_input};
                        default: accumulator <= accumulator;
                    endcase
                    result <= accumulator;
                end
                pending_op <= 2'd1;  // Set add as pending
                op_display <= 2'd1;
            end
            else if (op_sub) begin
                if (first_entry) begin
                    accumulator <= {8'd0, num_input};
                    result <= {8'd0, num_input};
                    first_entry <= 1'b0;
                end
                else if (pending_op != 2'd0) begin
                    case (pending_op)
                        2'd1: accumulator <= accumulator + {8'd0, num_input};
                        2'd2: accumulator <= accumulator - {8'd0, num_input};
                        2'd3: accumulator <= accumulator * {8'd0, num_input};
                        default: accumulator <= accumulator;
                    endcase
                    result <= accumulator;
                end
                pending_op <= 2'd2;  // Set subtract as pending
                op_display <= 2'd2;
            end
            else if (op_mul) begin
                if (first_entry) begin
                    accumulator <= {8'd0, num_input};
                    result <= {8'd0, num_input};
                    first_entry <= 1'b0;
                end
                else if (pending_op != 2'd0) begin
                    case (pending_op)
                        2'd1: accumulator <= accumulator + {8'd0, num_input};
                        2'd2: accumulator <= accumulator - {8'd0, num_input};
                        2'd3: accumulator <= accumulator * {8'd0, num_input};
                        default: accumulator <= accumulator;
                    endcase
                    result <= accumulator;
                end
                pending_op <= 2'd3;  // Set multiply as pending
                op_display <= 2'd3;
            end
        end
    end

endmodule
