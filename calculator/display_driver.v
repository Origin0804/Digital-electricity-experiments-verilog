// 显示驱动模块 - 新版计算器
// Display Driver Module - New Calculator
// 
// 显示布局 Display Layout:
//   第1个数码管: 符号(+/-) 1st display: Sign (+/-)
//   第2-8个数码管: 数字(7位) 2nd-8th displays: Digits (7 digits)
// 
// 注意: 显示方向已修正(原来是反的) Note: Display direction corrected (was reversed)

module display_driver(
    input clk_scan,             // 1kHz扫描时钟 Scan clock
    input rst,                  // 复位信号 Reset signal
    input [2:0] state,          // 当前状态 Current state
    input [3:0] digits1 [6:0],  // 第一个数的各位数字 Digits of first operand
    input [3:0] digits2 [6:0],  // 第二个数的各位数字 Digits of second operand
    input [3:0] result_digits [6:0], // 结果的各位数字 Digits of result
    input [1:0] operation,      // 运算类型 Operation type: 0=add, 1=sub, 2=mul, 3=div
    input [2:0] digit_pos,      // 当前输入位置 Current digit position
    input [2:0] decimal_pos1,   // 第一个数小数点位置 Decimal position for operand1
    input [2:0] decimal_pos2,   // 第二个数小数点位置 Decimal position for operand2
    input is_negative1,         // 第一个数是否为负 Is operand1 negative
    input is_negative2,         // 第二个数是否为负 Is operand2 negative
    input is_result_negative,   // 结果是否为负 Is result negative
    input blink_state,          // 闪烁状态 Blink state
    output reg [7:0] an,        // 数码管位选 Anode select
    output reg [7:0] duan,      // 右侧段选 Segment data for right bank
    output reg [7:0] duan1      // 左侧段选 Segment data for left bank
);

    // 状态定义 State definitions
    localparam STATE_INPUT1 = 3'd0;
    localparam STATE_OP_SELECT = 3'd1;
    localparam STATE_INPUT2 = 3'd2;
    localparam STATE_RESULT = 3'd3;

    // 扫描计数器 Scan counter (0-7)
    reg [2:0] scan_cnt;
    
    // 当前数字显示值 Current digit values
    reg [3:0] digit_value;
    reg show_decimal;           // 是否显示小数点 Show decimal point
    reg show_negative;          // 是否显示负号 Show negative sign
    
    // 临时数字数组用于显示 Temporary digit array for display
    reg [3:0] display_digits [7:0];  // 8位: [0]=符号位, [1-7]=数字位
    integer i;

    // 7段译码函数 7-segment decode function
    function [7:0] seg_decode;
        input [3:0] digit;
        input show_dp;          // 是否显示小数点 Show decimal point
        reg [7:0] base_pattern;
        begin
            case (digit)
                4'd0: base_pattern = 8'b11111100;  // 0
                4'd1: base_pattern = 8'b01100000;  // 1
                4'd2: base_pattern = 8'b11011010;  // 2
                4'd3: base_pattern = 8'b11110010;  // 3
                4'd4: base_pattern = 8'b01100110;  // 4
                4'd5: base_pattern = 8'b10110110;  // 5
                4'd6: base_pattern = 8'b10111110;  // 6
                4'd7: base_pattern = 8'b11100000;  // 7
                4'd8: base_pattern = 8'b11111110;  // 8
                4'd9: base_pattern = 8'b11110110;  // 9
                4'd10: base_pattern = 8'b00000010; // 负号 Negative sign (-)
                4'd11: base_pattern = 8'b00000000; // 空白 Blank
                4'd12: base_pattern = 8'b11101110; // A
                4'd13: base_pattern = 8'b00111110; // d
                4'd14: base_pattern = 8'b10011110; // E
                4'd15: base_pattern = 8'b10001110; // P/F
                default: base_pattern = 8'b00000000;
            endcase
            // 添加小数点 Add decimal point
            seg_decode = show_dp ? (base_pattern | 8'b00000001) : base_pattern;
        end
    endfunction

    // 扫描计数器 Scan counter
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 3'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // 根据状态准备显示数据 Prepare display data based on state
    always @(*) begin
        // 默认值 Default values
        for (i = 0; i < 8; i = i + 1)
            display_digits[i] = 4'd0;
        show_negative = 1'b0;
        
        case (state)
            STATE_INPUT1: begin
                // 状态0: 显示第一个输入的数字 State 0: Show first input number
                for (i = 0; i < 7; i = i + 1)
                    display_digits[i] = digits1[i];
                display_digits[7] = 4'd11;  // 符号位 Sign bit
                show_negative = is_negative1;
            end
            
            STATE_OP_SELECT: begin
                // 状态1: 显示运算符的英文 State 1: Show operation in English
                // Add=Add, Sub=Sub, Mul=Mul, Div=div
                case (operation)
                    2'd0: begin  // Add
                        display_digits[7] = 4'd11;  // 空白
                        display_digits[6] = 4'd11;
                        display_digits[5] = 4'd11;
                        display_digits[4] = 4'd11;
                        display_digits[3] = 4'd11;
                        display_digits[2] = 4'd12;  // A
                        display_digits[1] = 4'd13;  // d
                        display_digits[0] = 4'd13;  // d -> "Add"
                    end
                    2'd1: begin  // Sub
                        display_digits[7] = 4'd11;
                        display_digits[6] = 4'd11;
                        display_digits[5] = 4'd11;
                        display_digits[4] = 4'd11;
                        display_digits[3] = 4'd11;
                        display_digits[2] = 4'd5;   // S
                        display_digits[1] = 4'd0;   // u (显示为0)
                        display_digits[0] = 4'd11;  // b (显示为空白) -> "S0b"
                    end
                    2'd2: begin  // Mul
                        display_digits[7] = 4'd11;
                        display_digits[6] = 4'd11;
                        display_digits[5] = 4'd11;
                        display_digits[4] = 4'd11;
                        display_digits[3] = 4'd11;
                        display_digits[2] = 4'd11;  // M (无法完美显示)
                        display_digits[1] = 4'd0;   // u
                        display_digits[0] = 4'd11;  // L -> "MuL"
                    end
                    2'd3: begin  // div
                        display_digits[7] = 4'd11;
                        display_digits[6] = 4'd11;
                        display_digits[5] = 4'd11;
                        display_digits[4] = 4'd11;
                        display_digits[3] = 4'd11;
                        display_digits[2] = 4'd13;  // d
                        display_digits[1] = 4'd1;   // i (显示为1)
                        display_digits[0] = 4'd0;   // v (显示为0) -> "d10"
                    end
                endcase
            end
            
            STATE_INPUT2: begin
                // 状态2: 显示第二个输入的数字 State 2: Show second input number
                for (i = 0; i < 7; i = i + 1)
                    display_digits[i] = digits2[i];
                display_digits[7] = 4'd11;  // 符号位 Sign bit
                show_negative = is_negative2;
            end
            
            STATE_RESULT: begin
                // 状态3: 显示结果 State 3: Show result
                for (i = 0; i < 7; i = i + 1)
                    display_digits[i] = result_digits[i];
                display_digits[7] = 4'd11;  // 符号位 Sign bit
                show_negative = is_result_negative;
            end
        endcase
    end

    // 位选和段选输出 Anode and segment output
    // 注意: 修正显示方向 Note: Corrected display direction
    // AN7(左侧) -> 符号, AN6-AN0(右侧) -> 数字6到数字0
    // AN7(left) -> sign, AN6-AN0(right) -> digit6 to digit0
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b11111111;  // 全部关闭 All off
            duan <= 8'b00000000;
            duan1 <= 8'b00000000;
        end
        else begin
            // 位选信号 Anode select (active low)
            case (scan_cnt)
                3'd0: an <= 8'b01111111;  // AN7 (符号位 Sign)
                3'd1: an <= 8'b10111111;  // AN6 (数字6 Digit 6)
                3'd2: an <= 8'b11011111;  // AN5 (数字5 Digit 5)
                3'd3: an <= 8'b11101111;  // AN4 (数字4 Digit 4)
                3'd4: an <= 8'b11110111;  // AN3 (数字3 Digit 3)
                3'd5: an <= 8'b11111011;  // AN2 (数字2 Digit 2)
                3'd6: an <= 8'b11111101;  // AN1 (数字1 Digit 1)
                3'd7: an <= 8'b11111110;  // AN0 (数字0 Digit 0)
            endcase
            
            // 段选信号 Segment select
            if (scan_cnt == 3'd0) begin
                // 显示符号 Display sign
                if (show_negative)
                    digit_value = 4'd10;  // 负号 Negative sign
                else
                    digit_value = 4'd11;  // 空白 Blank (positive)
                show_decimal = 1'b0;
            end
            else begin
                // 显示数字 Display digits
                digit_value = display_digits[7 - scan_cnt];  // 修正方向 Corrected direction
                
                // 判断是否显示小数点 Determine if decimal point should be shown
                if (state == STATE_INPUT1)
                    show_decimal = (decimal_pos1 == (7 - scan_cnt));
                else if (state == STATE_INPUT2)
                    show_decimal = (decimal_pos2 == (7 - scan_cnt));
                else
                    show_decimal = 1'b0;
            end
            
            // 处理闪烁 Handle blinking
            if ((state == STATE_INPUT1 || state == STATE_INPUT2) && 
                !blink_state && (7 - scan_cnt) == digit_pos) begin
                // 当前位闪烁时显示空白 Show blank when current digit is blinking
                duan <= 8'b00000000;
                duan1 <= 8'b00000000;
            end
            else begin
                // 正常显示 Normal display
                duan <= seg_decode(digit_value, show_decimal);
                duan1 <= seg_decode(digit_value, show_decimal);
            end
        end
    end

endmodule
