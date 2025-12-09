// 消抖模块 - 新版计算器
// Debounce Module - New Calculator
// 对按键输入进行消抖处理
// Debounces button inputs

module debounce(
    input clk_db,               // 消抖时钟 (100Hz) Debounce clock (100Hz)
    input rst,                  // 复位信号 Active high reset
    input s0_in,                // S0按键输入 (左移) S0 button input (left)
    input s1_in,                // S1按键输入 (保留) S1 button input (reserved)
    input s2_in,                // S2按键输入 (确认/小数点) S2 button input (confirm/decimal)
    input s3_in,                // S3按键输入 (右移) S3 button input (right)
    input s4_in,                // S4按键输入 (保留) S4 button input (reserved)
    input [7:0] sw_in,          // SW0-SW7拨码开关 SW0-SW7 switches
    output reg s0_out,          // 消抖后S0 (脉冲) Debounced S0 (pulse)
    output reg s1_out,          // 消抖后S1 (脉冲) Debounced S1 (pulse)
    output reg s2_out,          // 消抖后S2 (电平) Debounced S2 (level)
    output reg s3_out,          // 消抖后S3 (脉冲) Debounced S3 (pulse)
    output reg s4_out,          // 消抖后S4 (脉冲) Debounced S4 (pulse)
    output reg [7:0] sw_out     // 消抖后SW (电平) Debounced SW (level)
);

    // 移位寄存器用于消抖 Shift registers for debouncing
    reg [2:0] s0_shift, s1_shift, s2_shift, s3_shift, s4_shift;
    reg [2:0] sw_shift [7:0];
    
    // 上一状态用于边沿检测 Previous state for edge detection
    reg s0_prev, s1_prev, s2_prev, s3_prev, s4_prev;
    
    // 消抖后的稳定值 Debounced stable values
    reg s0_stable, s1_stable, s2_stable, s3_stable, s4_stable;

    integer i;

    // 移位寄存器采样和消抖 Shift register sampling and debouncing
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_shift <= 3'b000; s1_shift <= 3'b000;
            s2_shift <= 3'b000; s3_shift <= 3'b000;
            s4_shift <= 3'b000;
            for (i = 0; i < 8; i = i + 1)
                sw_shift[i] <= 3'b000;
            s0_stable <= 1'b0; s1_stable <= 1'b0;
            s2_stable <= 1'b0; s3_stable <= 1'b0;
            s4_stable <= 1'b0;
            sw_out <= 8'b0;
        end
        else begin
            // 移入新采样 Shift in new samples
            s0_shift <= {s0_shift[1:0], s0_in};
            s1_shift <= {s1_shift[1:0], s1_in};
            s2_shift <= {s2_shift[1:0], s2_in};
            s3_shift <= {s3_shift[1:0], s3_in};
            s4_shift <= {s4_shift[1:0], s4_in};
            for (i = 0; i < 8; i = i + 1)
                sw_shift[i] <= {sw_shift[i][1:0], sw_in[i]};
            
            // 检查稳定高电平 Check for stable high
            if (s0_shift == 3'b111) s0_stable <= 1'b1;
            else if (s0_shift == 3'b000) s0_stable <= 1'b0;
            
            if (s1_shift == 3'b111) s1_stable <= 1'b1;
            else if (s1_shift == 3'b000) s1_stable <= 1'b0;
            
            if (s2_shift == 3'b111) s2_stable <= 1'b1;
            else if (s2_shift == 3'b000) s2_stable <= 1'b0;
            
            if (s3_shift == 3'b111) s3_stable <= 1'b1;
            else if (s3_shift == 3'b000) s3_stable <= 1'b0;
            
            if (s4_shift == 3'b111) s4_stable <= 1'b1;
            else if (s4_shift == 3'b000) s4_stable <= 1'b0;
            
            // 开关输出电平 Switches output level
            for (i = 0; i < 8; i = i + 1) begin
                if (sw_shift[i] == 3'b111) sw_out[i] <= 1'b1;
                else if (sw_shift[i] == 3'b000) sw_out[i] <= 1'b0;
            end
        end
    end

    // 边沿检测用于脉冲输出 Edge detection for pulse output
    // 注意: S2输出电平信号而非脉冲,用于长按检测
    // Note: S2 outputs level signal instead of pulse for long press detection
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            s0_prev <= 1'b0; s1_prev <= 1'b0;
            s2_prev <= 1'b0; s3_prev <= 1'b0;
            s4_prev <= 1'b0;
            s0_out <= 1'b0; s1_out <= 1'b0;
            s2_out <= 1'b0; s3_out <= 1'b0;
            s4_out <= 1'b0;
        end
        else begin
            s0_prev <= s0_stable;
            s1_prev <= s1_stable;
            s2_prev <= s2_stable;
            s3_prev <= s3_stable;
            s4_prev <= s4_stable;
            
            // S0, S1, S3, S4输出脉冲 S0, S1, S3, S4 output pulses
            s0_out <= s0_stable & ~s0_prev;
            s1_out <= s1_stable & ~s1_prev;
            s3_out <= s3_stable & ~s3_prev;
            s4_out <= s4_stable & ~s4_prev;
            
            // S2输出电平 S2 outputs level
            s2_out <= s2_stable;
        end
    end

endmodule
