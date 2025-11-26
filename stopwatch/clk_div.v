// Clock Divider Module for Digital Stopwatch
// Generates clk_100Hz (timing), clk_scan (display), clk_db (debounce)
// Input: 100MHz clock (P17)

module clk_div(
    input clk,              // 100MHz input clock
    input rst,              // Active high reset
    output reg clk_100Hz,   // 100Hz clock for stopwatch timing (0.01s resolution)
    output reg clk_scan,    // 1kHz clock for display scanning
    output reg clk_db       // 100Hz clock for debouncing
);

    // Counter registers
    reg [19:0] cnt_100Hz;   // For 100Hz: 100MHz / 100Hz / 2 = 500000
    reg [16:0] cnt_scan;    // For 1kHz: 100MHz / 1kHz / 2 = 50000
    reg [19:0] cnt_db;      // For 100Hz debounce: 100MHz / 100Hz / 2 = 500000

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

    // 100Hz clock for debouncing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_db <= 20'd0;
            clk_db <= 1'b0;
        end
        else if (cnt_db >= 20'd499999) begin
            cnt_db <= 20'd0;
            clk_db <= ~clk_db;
        end
        else begin
            cnt_db <= cnt_db + 1'b1;
        end
    end

endmodule
