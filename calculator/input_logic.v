// 数字输入逻辑模块
// 实现逐位数字输入，支持小数点标记
// Number Input Logic Module
// Implements digit-by-digit input with decimal point marking

module input_logic(
    input clk_db,               // 消抖时钟 Debounce clock
    input clk_blink,            // 闪烁时钟 Blink clock (for digit flashing)
    input rst,                  // 复位信号 Reset signal
    input btn_left,             // S0: 左移按键 Left navigation button
    input btn_right,            // S3: 右移按键 Right navigation button
    input btn_confirm,          // S2短按: 确认按键 Confirm button (short press)
    input btn_decimal,          // S2长按: 小数点标记 Decimal point marker (long press)
    input [3:0] sw_digit,       // SW拨码开关输入数字 Switch input for digit (0-9)
    input start_input,          // 启动输入模式 Start input mode
    output reg input_done,      // 输入完成标志 Input complete flag
    output reg [31:0] number,   // 输出数字(定点数，小数点后4位) Output number (fixed-point, 4 decimal places)
    output reg [2:0] digit_pos, // 当前输入位置 Current digit position (0-6, excluding sign)
    output reg [2:0] decimal_pos,// 小数点位置 Decimal point position (0=no decimal, 1-7=position)
    output reg is_negative,     // 是否为负数 Is negative flag
    output reg blink_state      // 闪烁状态 Blink state for display
);

    // 内部寄存器 Internal registers
    reg [3:0] digits [6:0];     // 7位数字存储 (不包含符号位) 7 digits storage (excluding sign)
    reg input_active;           // 输入激活标志 Input active flag
    integer i;

    // 闪烁状态生成 Blink state generation
    always @(posedge clk_blink or posedge rst) begin
        if (rst)
            blink_state <= 1'b0;
        else if (input_active)
            blink_state <= ~blink_state;
        else
            blink_state <= 1'b1;  // 不闪烁时始终显示 Always show when not blinking
    end

    // 主逻辑 Main logic
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            // 复位所有状态 Reset all states
            number <= 32'd0;
            digit_pos <= 3'd6;      // 从最高位开始 Start from leftmost digit
            decimal_pos <= 3'd0;    // 无小数点 No decimal point
            is_negative <= 1'b0;    // 默认为正数 Default positive
            input_done <= 1'b0;
            input_active <= 1'b0;
            for (i = 0; i < 7; i = i + 1)
                digits[i] <= 4'd0;
        end
        else if (start_input && !input_active) begin
            // 开始输入模式 Start input mode
            input_active <= 1'b1;
            input_done <= 1'b0;
            digit_pos <= 3'd6;
            for (i = 0; i < 7; i = i + 1)
                digits[i] <= 4'd0;
        end
        else if (input_active) begin
            // 左移按键 - 向左移动光标 Left button - move cursor left
            if (btn_left && digit_pos < 3'd6) begin
                digit_pos <= digit_pos + 1'b1;
            end
            // 右移按键 - 向右移动光标 Right button - move cursor right
            else if (btn_right && digit_pos > 3'd0) begin
                digit_pos <= digit_pos - 1'b1;
            end
            // 小数点标记 Decimal point marker
            else if (btn_decimal) begin
                decimal_pos <= digit_pos;  // 标记当前位置为小数点 Mark current position as decimal
            end
            // 确认按键 - 完成输入 Confirm button - complete input
            else if (btn_confirm) begin
                input_active <= 1'b0;
                input_done <= 1'b1;
                // 计算最终数字值 Calculate final number value
                number <= calculate_number();
            end
            // 更新当前位的数字 Update current digit
            else if (sw_digit <= 4'd9) begin
                digits[digit_pos] <= sw_digit;
            end
        end
        else begin
            input_done <= 1'b0;
        end
    end

    // 计算数字值函数 Calculate number value function
    function [31:0] calculate_number;
        reg [31:0] temp_value;
        integer j;
        begin
            temp_value = 32'd0;
            // 将各位数字转换为实际数值 Convert digits to actual value
            for (j = 0; j < 7; j = j + 1) begin
                temp_value = temp_value + (digits[j] * power_of_10(j));
            end
            // 如果有小数点，调整为定点数 If decimal point exists, adjust to fixed-point
            if (decimal_pos > 0) begin
                // 小数点后保留4位 Keep 4 decimal places
                temp_value = temp_value * 10000 / power_of_10(decimal_pos);
            end
            else begin
                // 没有小数点，直接乘以10000转为定点数 No decimal, convert to fixed-point
                temp_value = temp_value * 10000;
            end
            calculate_number = temp_value;
        end
    endfunction

    // 10的幂次函数 Power of 10 function
    function [31:0] power_of_10;
        input integer exp;
        integer k;
        begin
            power_of_10 = 32'd1;
            for (k = 0; k < exp; k = k + 1)
                power_of_10 = power_of_10 * 10;
        end
    endfunction

endmodule
