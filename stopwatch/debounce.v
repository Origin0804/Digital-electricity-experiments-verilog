module debounce(
    input clk,              // ~200Hz debounce clock
    input rst,              // Reset signal
    input [5:0] btn_in,     // Raw button inputs: [5]=SW7, [4]=S4, [3]=S3, [2]=S2, [1]=S1, [0]=S0
    output reg [5:0] btn_out // Debounced outputs
);

    // Debounce using shift registers - require stable input for multiple cycles
    reg [3:0] shift_reg [5:0];  // 4-bit shift registers for each button
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 6; i = i + 1) begin
                shift_reg[i] <= 4'b0000;
            end
            btn_out <= 6'b000000;
        end
        else begin
            for (i = 0; i < 6; i = i + 1) begin
                // Shift in the new input
                shift_reg[i] <= {shift_reg[i][2:0], btn_in[i]};
                
                // Output is high only if all 4 samples are high
                if (shift_reg[i] == 4'b1111)
                    btn_out[i] <= 1'b1;
                else if (shift_reg[i] == 4'b0000)
                    btn_out[i] <= 1'b0;
                // Otherwise keep current value (hysteresis)
            end
        end
    end

endmodule
