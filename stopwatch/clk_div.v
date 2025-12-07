// Clock Divider Module for Digital Stopwatch
// Generates clk_100Hz (timing), clk_2Hz (flash), clk_scan (display), clk_db (debounce)
// Input: 100MHz clock (P17)

module clk_div(
    input clk,              // 100MHz input clock
    input rst,              // Active high reset
    output reg clk_100Hz,   // 100Hz clock for stopwatch timing (0.01s resolution)
    output reg clk_2Hz,     // 2Hz clock for LED flashing
    output reg clk_scan,    // 1kHz clock for display scanning
    output clk_db           // 100Hz clock for debouncing (same as clk_100Hz)
);

    // Counter registers
    reg [19:0] cnt_100Hz;   // For 100Hz: 100MHz / 100Hz / 2 = 500000
    reg [25:0] cnt_2Hz;     // For 2Hz: 100MHz / 2Hz / 2 = 25000000
    reg [16:0] cnt_scan;    // For 1kHz: 100MHz / 1kHz / 2 = 50000
    
    // Use the same clock for debouncing to avoid clock domain issues
    assign clk_db = clk_100Hz;

    // 100Hz clock generation (for stopwatch timing - 0.01s resolution)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_100Hz <= 20'd0;
            clk_100Hz <= 1'b0;
        end
        else if (cnt_100Hz >= 20'd499999) begin
            cnt_100Hz <= 20'd0;
            clk_100Hz <= ~clk_100Hz;
        end
        else begin
            cnt_100Hz <= cnt_100Hz + 1'b1;
        end
    end

    // 2Hz clock generation (for LED flashing)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_2Hz <= 26'd0;
            clk_2Hz <= 1'b0;
        end
        else if (cnt_2Hz >= 26'd24999999) begin
            cnt_2Hz <= 26'd0;
            clk_2Hz <= ~clk_2Hz;
        end
        else begin
            cnt_2Hz <= cnt_2Hz + 1'b1;
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
