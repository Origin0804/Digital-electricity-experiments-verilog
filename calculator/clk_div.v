// 时钟分频模块 - 计算器
// Clock Divider Module for Calculator
// 生成扫描时钟、消抖时钟和闪烁时钟
// Generates scan clock, debounce clock, and blink clock
// 输入: 100MHz时钟 (P17) Input: 100MHz clock (P17)

module clk_div(
    input clk,              // 100MHz输入时钟 100MHz input clock
    input rst,              // 复位信号 Active high reset
    output reg clk_scan,    // 1kHz扫描时钟 1kHz clock for display scanning
    output reg clk_db,      // 100Hz消抖时钟 100Hz clock for debouncing
    output reg clk_blink    // 2Hz闪烁时钟 2Hz clock for blinking
);

    // 计数器寄存器 Counter registers
    reg [16:0] cnt_scan;    // 1kHz: 100MHz / 1kHz / 2 = 50000
    reg [19:0] cnt_db;      // 100Hz: 100MHz / 100Hz / 2 = 500000
    reg [24:0] cnt_blink;   // 2Hz: 100MHz / 2Hz / 2 = 25000000

    // 1kHz时钟生成 1kHz clock generation
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

    // 100Hz消抖时钟生成 100Hz debounce clock generation
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

    // 2Hz闪烁时钟生成 2Hz blink clock generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_blink <= 25'd0;
            clk_blink <= 1'b0;
        end
        else if (cnt_blink >= 25'd24999999) begin
            cnt_blink <= 25'd0;
            clk_blink <= ~clk_blink;
        end
        else begin
            cnt_blink <= cnt_blink + 1'b1;
        end
    end

endmodule
