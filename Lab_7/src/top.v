// Lab7 顶层模块 - Top Module for Frequency Measurement and Control System
// 功能：测量NE555输出频率，并通过DAC0832控制其振荡频率
// 板卡：EGO1 FPGA开发板

module top(
    // 系统时钟与复位
    input clk,                  // 100MHz 系统时钟 (P17)
    input rst,                  // 复位按键 S6 (P15)，高有效
    
    // NE555信号输入（频率测量）
    input signal_in,            // NE555输出信号，经J5扩展口输入
    
    // 拨码开关输入（DAC控制）
    input [7:0] sw,             // 8位拨码开关 SW0~SW7
    
    // DAC0832控制输出
    output [7:0] dac_data,      // DAC数据输出 DI7~DI0
    output dac_wr1,             // DAC写使能1（低有效）
    output dac_wr2,             // DAC写使能2（低有效）
    output dac_cs,              // DAC片选（低有效）
    
    // 数码管显示输出
    output [7:0] an,            // 数码管位选 AN0~AN7（高有效）
    output [7:0] seg0,          // 右侧段选信号（高有效，用于AN0-AN3）
    output [7:0] seg1,          // 左侧段选信号（高有效，用于AN4-AN7）
    
    // LED指示（可选，用于调试）
    output [3:0] led            // LED0~LED3，显示状态
);

    // 内部时钟信号
    wire clk_1Hz;               // 1Hz 测量窗口tick
    wire clk_scan;              // 1kHz 数码管扫描时钟
    wire clk_db;                // 100Hz 消抖时钟
    
    // 频率测量值
    wire [15:0] freq;           // 测得的频率值（Hz）
    
    // 复位信号同步
    reg rst_sync1, rst_sync2;
    wire rst_sync;
    
    // 复位信号两级同步
    always @(posedge clk) begin
        rst_sync1 <= rst;
        rst_sync2 <= rst_sync1;
    end
    assign rst_sync = rst_sync2;
    
    // 时钟分频模块实例化
    clk_div u_clk_div(
        .clk(clk),
        .rst(rst_sync),
        .clk_1Hz(clk_1Hz),
        .clk_scan(clk_scan),
        .clk_db(clk_db)
    );
    
    // 频率测量模块实例化
    freq_meter u_freq_meter(
        .clk(clk),
        .rst(rst_sync),
        .clk_1Hz(clk_1Hz),
        .signal_in(signal_in),
        .freq(freq)
    );
    
    // DAC控制模块实例化
    dac_ctrl u_dac_ctrl(
        .clk(clk),
        .rst(rst_sync),
        .sw(sw),
        .dac_data(dac_data),
        .dac_wr1(dac_wr1),
        .dac_wr2(dac_wr2),
        .dac_cs(dac_cs)
    );
    
    // 显示驱动模块实例化
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst_sync),
        .freq(freq),
        .an(an),
        .seg0(seg0),
        .seg1(seg1)
    );
    
    // LED状态指示
    // LED0: 测量窗口指示（使用寄存器锁存）
    // LED1: 信号输入指示
    // LED2~LED3: 频率范围指示
    reg led0_reg;
    
    // 1Hz tick指示（锁存1Hz上升沿）
    always @(posedge clk or posedge rst_sync) begin
        if (rst_sync) begin
            led0_reg <= 1'b0;
        end else begin
            if (clk_1Hz) begin
                led0_reg <= ~led0_reg;  // 切换LED状态
            end
        end
    end
    
    assign led[0] = led0_reg;
    assign led[1] = signal_in;
    assign led[2] = (freq > 16'd1000);  // 频率 > 1kHz
    assign led[3] = (freq > 16'd5000);  // 频率 > 5kHz

endmodule
