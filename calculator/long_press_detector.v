// 长按检测模块
// 区分短按和长按S2按键
// Long Press Detection Module
// Distinguishes between short and long press of S2 button

module long_press_detector(
    input clk_db,               // 消抖时钟 Debounce clock (100Hz)
    input rst,                  // 复位信号 Reset signal
    input btn_in,               // 按键输入 Button input
    output reg short_press,     // 短按脉冲输出 Short press pulse output
    output reg long_press       // 长按脉冲输出 Long press pulse output
);

    // 长按阈值: 1秒 = 100个时钟周期 (100Hz时钟)
    // Long press threshold: 1 second = 100 clock cycles (at 100Hz clock)
    parameter LONG_PRESS_THRESHOLD = 100;
    
    reg [7:0] press_counter;    // 按键按下计数器 Press counter
    reg btn_prev;               // 上一个时钟周期的按键状态 Previous button state
    reg press_detected;         // 已检测到长按 Long press detected

    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            press_counter <= 8'd0;
            btn_prev <= 1'b0;
            short_press <= 1'b0;
            long_press <= 1'b0;
            press_detected <= 1'b0;
        end
        else begin
            btn_prev <= btn_in;
            short_press <= 1'b0;  // 默认清除脉冲 Clear pulse by default
            long_press <= 1'b0;
            
            if (btn_in && !btn_prev) begin
                // 按键刚按下 Button just pressed
                press_counter <= 8'd0;
                press_detected <= 1'b0;
            end
            else if (btn_in && btn_prev) begin
                // 按键持续按下 Button held down
                if (press_counter < LONG_PRESS_THRESHOLD) begin
                    press_counter <= press_counter + 1'b1;
                end
                else if (!press_detected) begin
                    // 达到长按阈值 Reached long press threshold
                    long_press <= 1'b1;
                    press_detected <= 1'b1;
                end
            end
            else if (!btn_in && btn_prev) begin
                // 按键释放 Button released
                if (press_counter < LONG_PRESS_THRESHOLD && !press_detected) begin
                    // 短按 Short press
                    short_press <= 1'b1;
                end
                press_counter <= 8'd0;
                press_detected <= 1'b0;
            end
        end
    end

endmodule
