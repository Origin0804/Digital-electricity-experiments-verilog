// Clock Divider Module for Scrolling Display
// Generates clk_4Hz (scroll timing), clk_scan (display)
// Input: 100MHz clock (P17)

module clk_div(
    input clk,              // 100MHz input clock
    input rst,              // Active high reset
    output reg clk_4Hz,     // 4Hz clock for scroll timing
    output reg clk_scan     // 1kHz clock for display scanning
);

    // Counter registers
    reg [24:0] cnt_4Hz;     // For 4Hz: 100MHz / 4Hz / 2 = 12500000
    reg [16:0] cnt_scan;    // For 1kHz: 100MHz / 1kHz / 2 = 50000

    // 4Hz clock generation (for scrolling)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_4Hz <= 25'd0;
            clk_4Hz <= 1'b0;
        end
        else if (cnt_4Hz >= 25'd12499999) begin
            cnt_4Hz <= 25'd0;
            clk_4Hz <= ~clk_4Hz;
        end
        else begin
            cnt_4Hz <= cnt_4Hz + 1'b1;
        end
    end

    // 1kHz clock generation (for display scanning)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_scan <= 17'd0;
            clk_scan <= 1'b0;
        end
        else if (cnt_scan >= 17'd49999) begin
            cnt_scan <= 17'd0;
            clk_scan <= ~clk_scan;
        end
        else begin
            cnt_scan <= cnt_scan + 1'b1;
        end
    end

endmodule
