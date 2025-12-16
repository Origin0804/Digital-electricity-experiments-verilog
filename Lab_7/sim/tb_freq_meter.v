// Lab7 简单测试台 - Testbench for Frequency Meter
// 用于验证频率测量模块的基本功能

`timescale 1ns / 1ps

module tb_freq_meter();

    // 时钟和复位
    reg clk;
    reg rst;
    
    // 测试信号
    reg signal_in;
    reg clk_1Hz;
    wire [15:0] freq;
    
    // 频率测量模块实例化
    freq_meter uut(
        .clk(clk),
        .rst(rst),
        .clk_1Hz(clk_1Hz),
        .signal_in(signal_in),
        .freq(freq)
    );
    
    // 生成100MHz时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns周期 = 100MHz
    end
    
    // 生成1Hz tick（简化版）
    initial begin
        clk_1Hz = 0;
        forever #500_000_000 clk_1Hz = ~clk_1Hz;  // 1秒周期
    end
    
    // 生成测试信号（1kHz方波）
    initial begin
        signal_in = 0;
        #1000;  // 等待初始化
        forever #500_000 signal_in = ~signal_in;  // 1ms周期 = 1kHz
    end
    
    // 测试流程
    initial begin
        $display("=== Lab7 频率测量模块仿真测试 ===");
        
        // 初始化
        rst = 1;
        #100;
        rst = 0;
        
        // 运行2秒，观察频率测量结果
        #2_000_000_000;
        
        $display("测量频率: %d Hz (预期: 约1000 Hz)", freq);
        
        // 改变输入频率为2kHz
        $display("\n改变输入频率为2kHz...");
        // 在实际仿真中，这里可以停止之前的信号生成，启动新频率
        
        #2_000_000_000;
        
        $display("\n仿真完成");
        $finish;
    end
    
    // 监控频率变化
    always @(freq) begin
        if (!rst) begin
            $display("时间: %t ns, 测得频率: %d Hz", $time, freq);
        end
    end

endmodule
