// 计算器逻辑模块 - 新版交互设计
// Calculator Logic Module - New Interactive Design
// 
// 功能特性 Features:
//   - 4状态交互流程: 输入数字1 -> 选择运算 -> 输入数字2 -> 显示结果
//   - 4-state interaction: Input num1 -> Select operation -> Input num2 -> Show result
//   - 支持加减乘除运算 Supports add, subtract, multiply, divide
//   - 结果自动作为下一轮第一个数字 Result automatically becomes first number for next round
//   - 支持小数运算 Supports decimal operations

module calc_logic(
    input clk_db,               // 消抖时钟 Debounce clock
    input clk_blink,            // 闪烁时钟 Blink clock for digit display
    input rst,                  // 复位信号 Active high reset
    input btn_left,             // S0: 左移按键 Left navigation
    input btn_right,            // S3: 右移按键 Right navigation  
    input s2_short,             // S2短按: 进入下一步 Short press to next step
    input s2_long,              // S2长按: 标记小数点 Long press for decimal point
    input [3:0] sw_op,          // SW0-3: 运算选择 Operation selection (add/sub/mul/div)
    input [3:0] sw_digit,       // SW输入数字 Digit input from switches
    output reg [3:0] digits1 [6:0], // 第一个数的各位数字 Digits of first operand
    output reg [3:0] digits2 [6:0], // 第二个数的各位数字 Digits of second operand  
    output reg [3:0] result_digits [6:0], // 结果的各位数字 Digits of result
    output reg [1:0] operation, // 当前运算 Current operation: 0=add, 1=sub, 2=mul, 3=div
    output reg [2:0] state,     // 当前状态 Current state: 0=input1, 1=op_select, 2=input2, 3=result
    output reg [2:0] digit_pos, // 当前数字位置 Current digit position
    output reg [2:0] decimal_pos1, // 第一个数的小数点位置 Decimal position for operand1
    output reg [2:0] decimal_pos2, // 第二个数的小数点位置 Decimal position for operand2
    output reg is_negative1,    // 第一个数是否为负 Is operand1 negative
    output reg is_negative2,    // 第二个数是否为负 Is operand2 negative
    output reg is_result_negative, // 结果是否为负 Is result negative
    output reg blink_state      // 闪烁状态 Blink state
);

    // 状态定义 State definitions
    localparam STATE_INPUT1 = 3'd0;     // 输入第一个数字 Input first number
    localparam STATE_OP_SELECT = 3'd1;  // 选择运算 Select operation
    localparam STATE_INPUT2 = 3'd2;     // 输入第二个数字 Input second number
    localparam STATE_RESULT = 3'd3;     // 显示结果 Show result

    // 内部寄存器 Internal registers
    reg result_ready;           // 结果准备好标志 Result ready flag
    integer i;

    // 闪烁状态生成 Blink state generation
    always @(posedge clk_blink or posedge rst) begin
        if (rst)
            blink_state <= 1'b0;
        else if (state == STATE_INPUT1 || state == STATE_INPUT2)
            blink_state <= ~blink_state;
        else
            blink_state <= 1'b1;  // 非输入状态不闪烁 No blinking in non-input states
    end

    // 主状态机 Main state machine
    always @(posedge clk_db or posedge rst) begin
        if (rst) begin
            // 复位所有状态 Reset all states
            state <= STATE_INPUT1;
            digit_pos <= 3'd6;
            decimal_pos1 <= 3'd0;
            decimal_pos2 <= 3'd0;
            is_negative1 <= 1'b0;
            is_negative2 <= 1'b0;
            is_result_negative <= 1'b0;
            operation <= 2'd0;
            result_ready <= 1'b0;
            for (i = 0; i < 7; i = i + 1) begin
                digits1[i] <= 4'd0;
                digits2[i] <= 4'd0;
                result_digits[i] <= 4'd0;
            end
        end
        else begin
            case (state)
                STATE_INPUT1: begin
                    // 状态0: 输入第一个数字 State 0: Input first number
                    // 如果上一轮有结果，复制到第一个数 If previous result exists, copy to first operand
                    if (result_ready && !s2_short) begin
                        for (i = 0; i < 7; i = i + 1)
                            digits1[i] <= result_digits[i];
                        is_negative1 <= is_result_negative;
                        result_ready <= 1'b0;
                    end
                    
                    // 左移 Left navigation
                    if (btn_left && digit_pos < 3'd6) begin
                        digit_pos <= digit_pos + 1'b1;
                    end
                    // 右移 Right navigation
                    if (btn_right && digit_pos > 3'd0) begin
                        digit_pos <= digit_pos - 1'b1;
                    end
                    // 长按标记小数点 Long press for decimal point
                    if (s2_long) begin
                        decimal_pos1 <= digit_pos;
                    end
                    // 短按进入下一步 Short press to next step
                    if (s2_short) begin
                        state <= STATE_OP_SELECT;
                        digit_pos <= 3'd6;  // 重置位置 Reset position
                    end
                    // 持续更新当前位数字 Continuously update current digit
                    // 使用SW4-7作为BCD输入 Use SW4-7 as BCD input
                    digits1[digit_pos] <= sw_digit;
                end

                STATE_OP_SELECT: begin
                    // 状态1: 选择运算符 State 1: Select operation
                    // 使用SW0-3选择运算 Use SW0-3 to select operation
                    // SW3=除法, SW2=乘法, SW1=减法, SW0=加法
                    // SW3=div, SW2=mul, SW1=sub, SW0=add
                    if (sw_op[3])
                        operation <= 2'd3;  // 除法 Divide
                    else if (sw_op[2])
                        operation <= 2'd2;  // 乘法 Multiply
                    else if (sw_op[1])
                        operation <= 2'd1;  // 减法 Subtract
                    else if (sw_op[0])
                        operation <= 2'd0;  // 加法 Add
                    
                    // 短按S2进入下一步 Short press S2 to next step
                    if (s2_short) begin
                        state <= STATE_INPUT2;
                        digit_pos <= 3'd6;  // 重置位置 Reset position
                    end
                end

                STATE_INPUT2: begin
                    // 状态2: 输入第二个数字 State 2: Input second number
                    // 左移 Left navigation
                    if (btn_left && digit_pos < 3'd6) begin
                        digit_pos <= digit_pos + 1'b1;
                    end
                    // 右移 Right navigation
                    if (btn_right && digit_pos > 3'd0) begin
                        digit_pos <= digit_pos - 1'b1;
                    end
                    // 长按标记小数点 Long press for decimal point
                    if (s2_long) begin
                        decimal_pos2 <= digit_pos;
                    end
                    // 短按进入计算 Short press to calculate
                    if (s2_short) begin
                        state <= STATE_RESULT;
                        // 执行计算 Perform calculation
                        calculate_and_store_result();
                    end
                    // 持续更新当前位数字 Continuously update current digit
                    digits2[digit_pos] <= sw_digit;
                end

                STATE_RESULT: begin
                    // 状态3: 显示结果 State 3: Show result
                    result_ready <= 1'b1;
                    // 短按S2开始新的计算 Short press S2 to start new calculation
                    if (s2_short) begin
                        state <= STATE_INPUT1;
                        digit_pos <= 3'd6;
                        decimal_pos2 <= 3'd0;
                        for (i = 0; i < 7; i = i + 1)
                            digits2[i] <= 4'd0;
                    end
                end
            endcase
        end
    end

    // 计算并存储结果任务 Calculate and store result task
    task calculate_and_store_result;
        reg signed [63:0] op1, op2, res;
        reg [63:0] temp_res;
        integer j;
        begin
            // 将数字数组转换为数值 Convert digit arrays to values
            op1 = 64'd0;
            op2 = 64'd0;
            for (j = 0; j < 7; j = j + 1) begin
                op1 = op1 + (digits1[j] * power_of_10(j));
                op2 = op2 + (digits2[j] * power_of_10(j));
            end
            
            // 调整小数点 Adjust for decimal points
            if (decimal_pos1 > 0)
                op1 = op1 * 10000 / power_of_10(decimal_pos1);
            else
                op1 = op1 * 10000;
                
            if (decimal_pos2 > 0)
                op2 = op2 * 10000 / power_of_10(decimal_pos2);
            else
                op2 = op2 * 10000;
            
            // 处理符号 Handle signs
            op1 = is_negative1 ? -op1 : op1;
            op2 = is_negative2 ? -op2 : op2;
            
            // 执行运算 Perform operation
            case (operation)
                2'd0: res = op1 + op2;  // 加法 Add
                2'd1: res = op1 - op2;  // 减法 Subtract
                2'd2: res = (op1 * op2) / 10000;  // 乘法 Multiply
                2'd3: begin  // 除法 Divide
                    if (op2 != 0)
                        res = (op1 * 10000) / op2;
                    else
                        res = 64'd0;
                end
                default: res = 64'd0;
            endcase
            
            // 处理结果符号 Handle result sign
            is_result_negative = (res < 0);
            temp_res = is_result_negative ? -res : res;
            
            // 转换回定点数后的整数部分 Convert back to integer after fixed-point
            temp_res = temp_res / 10000;
            
            // 存储结果到数字数组 Store result in digit array
            for (j = 0; j < 7; j = j + 1) begin
                result_digits[j] = temp_res % 10;
                temp_res = temp_res / 10;
            end
        end
    endtask

    // 10的幂次函数 Power of 10 function
    function [63:0] power_of_10;
        input integer exp;
        integer k;
        begin
            power_of_10 = 64'd1;
            for (k = 0; k < exp; k = k + 1)
                power_of_10 = power_of_10 * 10;
        end
    endfunction

endmodule
