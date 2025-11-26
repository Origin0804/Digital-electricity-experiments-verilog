// Clock Divider Module
// Generates 100Hz clock for timing and ~1kHz clock for display scanning
// Input: 100MHz system clock
module clk_div(
    input clk,          // 100MHz system clock
    input rst,          // Reset signal
    output reg clk_100hz,   // 100Hz timing clock (0.01s resolution)
    output reg clk_1khz     // ~1kHz scanning clock for display
);

    // For 100Hz from 100MHz: divide by 1,000,000 (toggle at 500,000)
    // For ~1kHz from 100MHz: divide by 100,000 (toggle at 50,000)
    
    reg [19:0] cnt_100hz;   // Counter for 100Hz
    reg [16:0] cnt_1khz;    // Counter for 1kHz

    // 100Hz clock generation (for 0.01s timing resolution)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_100hz <= 20'd0;
            clk_100hz <= 1'b0;
        end
        else if (cnt_100hz >= 20'd499999) begin
            cnt_100hz <= 20'd0;
            clk_100hz <= ~clk_100hz;
        end
        else begin
            cnt_100hz <= cnt_100hz + 1'b1;
        end
    end

    // ~1kHz clock generation (for display scanning)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1khz <= 17'd0;
            clk_1khz <= 1'b0;
        end
        else if (cnt_1khz >= 17'd49999) begin
            cnt_1khz <= 17'd0;
            clk_1khz <= ~clk_1khz;
        end
        else begin
            cnt_1khz <= cnt_1khz + 1'b1;
        end
    end

endmodule
