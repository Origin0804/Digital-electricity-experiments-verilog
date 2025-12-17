// 时钟分频模块 - Clock Divider Module
// 为Lab7频率测量与控制系统生成各种时钟信号
// 输入：100MHz系统时钟
// 输出：1Hz测量窗口tick、1kHz数码管扫描时钟、100Hz消抖时钟

module clk_div(
    input clk,              // 100MHz 系统时钟 (P17)
    input rst,              // 复位信号（高有效）
    output reg clk_1Hz,     // 1Hz 测量窗口tick（用于频率测量）
    output reg clk_scan,    // 1kHz 数码管扫描时钟
    output reg clk_db       // 100Hz 消抖时钟
);

    // 时钟频率参数
    parameter CLK_FREQ = 100_000_000;  // 100MHz
    
    // 分频计数器
    // 1Hz: 100,000,000 / 1 = 100,000,000 计数
    // 1kHz: 100,000,000 / 1000 = 100,000 计数
    // 100Hz: 100,000,000 / 100 = 1,000,000 计数
    
    localparam CNT_1HZ = CLK_FREQ / 2;        // 50,000,000 (翻转周期)
    localparam CNT_1KHZ = CLK_FREQ / 2000;    // 50,000 (翻转周期)
    localparam CNT_100HZ = CLK_FREQ / 200;    // 500,000 (翻转周期)
    
    reg [25:0] cnt_1Hz;      // 1Hz计数器（需要26位以容纳50,000,000）
    reg [16:0] cnt_1kHz;     // 1kHz计数器（需要17位以容纳50,000）
    reg [19:0] cnt_100Hz;    // 100Hz计数器（需要20位以容纳500,000）
    
    // 1Hz时钟生成（测量窗口tick）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1Hz <= 26'd0;
            clk_1Hz <= 1'b0;
        end else begin
            if (cnt_1Hz >= CNT_1HZ - 1) begin
                cnt_1Hz <= 26'd0;
                clk_1Hz <= ~clk_1Hz;
            end else begin
                cnt_1Hz <= cnt_1Hz + 1'b1;
            end
        end
    end
    
    // 1kHz时钟生成（数码管扫描）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1kHz <= 17'd0;
            clk_scan <= 1'b0;
        end else begin
            if (cnt_1kHz >= CNT_1KHZ - 1) begin
                cnt_1kHz <= 17'd0;
                clk_scan <= ~clk_scan;
            end else begin
                cnt_1kHz <= cnt_1kHz + 1'b1;
            end
        end
    end
    
    // 100Hz时钟生成（按键消抖）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_100Hz <= 20'd0;
            clk_db <= 1'b0;
        end else begin
            if (cnt_100Hz >= CNT_100HZ - 1) begin
                cnt_100Hz <= 20'd0;
                clk_db <= ~clk_db;
            end else begin
                cnt_100Hz <= cnt_100Hz + 1'b1;
            end
        end
    end

endmodule
