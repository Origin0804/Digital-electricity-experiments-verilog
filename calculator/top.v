// 计算器顶层模块 - 新版交互设计
// Top-Level Module for Calculator - New Interactive Design
// 整合所有组件用于EGO1 FPGA开发板
// Integrates all components for EGO1 FPGA board
// Lab6_8: 加减乘除计算器，支持小数运算
// Lab6_8: Calculator with add/subtract/multiply/divide, supports decimals

module top(
    input clk,              // 100MHz时钟 (P17)
    input s0,               // S0按键: 左移 Left navigation (R11)
    input s1,               // S1按键: 保留 Reserved (R17)
    input s2,               // S2按键: 确认/小数点 Confirm/Decimal (R15)
    input s3,               // S3按键: 右移 Right navigation (V1)
    input s4,               // S4按键: 保留 Reserved (U4)
    input [7:0] sw,         // 拨码开关 Switches (SW0-SW7)
    output [7:0] an,        // 数码管位选 Anode select
    output [7:0] duan,      // 右侧段选 Segment data for right bank
    output [7:0] duan1      // 左侧段选 Segment data for left bank
);

    // 内部时钟信号 Internal clock signals
    wire clk_scan;          // 扫描时钟 Scan clock
    wire clk_db;            // 消抖时钟 Debounce clock
    wire clk_blink;         // 闪烁时钟 Blink clock
    
    // 消抖后的信号 Debounced signals
    wire s0_db, s1_db, s2_db_level, s3_db, s4_db;
    wire [7:0] sw_db;
    
    // S2的短按和长按信号 S2 short and long press signals
    wire s2_short, s2_long;
    
    // 计算器逻辑输出 Calculator logic outputs
    wire [63:0] operand1, operand2, result;
    wire [1:0] operation;
    wire [2:0] state;
    wire [2:0] digit_pos;
    wire [2:0] decimal_pos1, decimal_pos2;
    wire is_negative1, is_negative2;
    wire blink_state;
    
    // 复位信号 (未使用S0作为复位) Reset signal (not using S0 as reset)
    wire rst = 1'b0;
    
    // 从SW提取数字输入 (SW4-7用于数字，SW0-3用于运算)
    // Extract digit input from SW (SW4-7 for digits, SW0-3 for operation)
    wire [3:0] sw_digit = {sw_db[7], sw_db[6], sw_db[5], sw_db[4]};
    wire [3:0] sw_op = sw_db[3:0];
    
    // 时钟分频模块实例 Clock divider instance
    clk_div u_clk_div(
        .clk(clk),
        .rst(rst),
        .clk_scan(clk_scan),
        .clk_db(clk_db),
        .clk_blink(clk_blink)
    );
    
    // 消抖模块实例 Debounce instance
    debounce u_debounce(
        .clk_db(clk_db),
        .rst(rst),
        .s0_in(s0),
        .s1_in(s1),
        .s2_in(s2),
        .s3_in(s3),
        .s4_in(s4),
        .sw_in(sw),
        .s0_out(s0_db),
        .s1_out(s1_db),
        .s2_out(s2_db_level),  // S2输出电平 S2 outputs level
        .s3_out(s3_db),
        .s4_out(s4_db),
        .sw_out(sw_db)
    );
    
    // 长按检测模块实例 Long press detector instance
    long_press_detector u_long_press(
        .clk_db(clk_db),
        .rst(rst),
        .btn_in(s2_db_level),
        .short_press(s2_short),
        .long_press(s2_long)
    );
    
    // 计算器逻辑模块实例 Calculator logic instance
    calc_logic u_calc(
        .clk_db(clk_db),
        .clk_blink(clk_blink),
        .rst(rst),
        .btn_left(s0_db),
        .btn_right(s3_db),
        .s2_short(s2_short),
        .s2_long(s2_long),
        .sw_op(sw_op),
        .sw_digit(sw_digit),
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .operation(operation),
        .state(state),
        .digit_pos(digit_pos),
        .decimal_pos1(decimal_pos1),
        .decimal_pos2(decimal_pos2),
        .is_negative1(is_negative1),
        .is_negative2(is_negative2),
        .blink_state(blink_state)
    );
    
    // 显示驱动模块实例 Display driver instance
    display_driver u_display(
        .clk_scan(clk_scan),
        .rst(rst),
        .state(state),
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .operation(operation),
        .digit_pos(digit_pos),
        .decimal_pos1(decimal_pos1),
        .decimal_pos2(decimal_pos2),
        .is_negative1(is_negative1),
        .is_negative2(is_negative2),
        .blink_state(blink_state),
        .an(an),
        .duan(duan),
        .duan1(duan1)
    );

endmodule
