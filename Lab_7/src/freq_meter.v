// 频率测量模块 - Frequency Meter Module
// 使用测频法测量输入方波信号的频率
// 测量原理：在固定时间窗口（1秒）内对输入信号的上升沿进行计数
// 频率 = 计数值 / 窗口时间

module freq_meter(
    input clk,              // 100MHz 系统时钟
    input rst,              // 复位信号（高有效）
    input clk_1Hz,          // 1Hz 测量窗口tick
    input signal_in,        // 待测方波信号输入（来自NE555，经J5扩展口）
    output reg [15:0] freq  // 测得的频率值（Hz，最大65535Hz）
);

    // 两级同步寄存器（异步输入必须同步）
    reg signal_sync1, signal_sync2;
    
    // 边沿检测
    reg signal_prev;
    wire signal_posedge;
    
    // 计数器
    reg [15:0] edge_count;      // 当前窗口内的上升沿计数
    
    // 两级同步输入信号（防止亚稳态）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_sync1 <= 1'b0;
            signal_sync2 <= 1'b0;
        end else begin
            signal_sync1 <= signal_in;
            signal_sync2 <= signal_sync1;
        end
    end
    
    // 上升沿检测
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_prev <= 1'b0;
        end else begin
            signal_prev <= signal_sync2;
        end
    end
    
    assign signal_posedge = signal_sync2 & ~signal_prev;
    
    // 上升沿计数器
    // 修正：先锁存再清零，避免边界丢失
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_count <= 16'd0;
        end else begin
            if (clk_1Hz) begin
                // 窗口结束tick，重置计数器（下一个窗口开始）
                edge_count <= 16'd0;
            end else if (signal_posedge) begin
                // 检测到上升沿，计数加1
                edge_count <= edge_count + 1'b1;
            end
        end
    end
    
    // 频率值输出
    // 修正：在窗口tick到来时锁存当前计数值
    // 时序说明：由于使用非阻塞赋值（<=），当clk_1Hz为高时，两个always块并发执行：
    //   - 本块读取edge_count的"旧值"并锁存到freq（锁存操作）
    //   - 上面的块将edge_count清零（清零操作）
    // 这确保了在窗口边界处，先完成锁存再清零，不会丢失边界脉冲
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            freq <= 16'd0;
        end else begin
            if (clk_1Hz) begin
                // 窗口tick，锁存当前计数值作为频率（读取edge_count旧值）
                freq <= edge_count;
            end
        end
    end

endmodule
