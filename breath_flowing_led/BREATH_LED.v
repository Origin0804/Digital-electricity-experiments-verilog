`timescale 1ns/1ps

module breathing_water_led (
    input  wire        clk,              
    input  wire        rst,              
    input  wire        dip_switch_mode,  
    output reg [15:0]  led               
);

    // === 参数定义 ===
    localparam CLK_FREQ        = 100_000_000;    // 100MHz
    localparam PWM_FREQ        = 1000;           // 1KHz PWM
    localparam PWM_PERIOD      = CLK_FREQ / PWM_FREQ;           // 100_000
    localparam BREATH_STEP_CNT = 100;            // 亮度100级
    localparam BREATH_TOTAL_MS = 8000;           // 呼吸8秒周期
    localparam BREATH_CNT_STEP = BREATH_TOTAL_MS / (BREATH_STEP_CNT*2); // 8s/200步
    localparam BREATH_STEP_CLK = (CLK_FREQ/1000) * BREATH_CNT_STEP; // 每步多少时钟

    // === 状态寄存器定义 ===
    reg [$clog2(PWM_PERIOD)-1:0]     pwm_cnt = 0;               // PWM计数
    reg [$clog2(BREATH_STEP_CLK)-1:0] breath_time_cnt = 0;      // 亮度step计数
    reg [6:0]                        breath_step = 0;           // 当前亮度等级
    reg                              breath_up = 1;             // 呼吸升降

    // ---- 流水呼吸灯专用
    reg [3:0]   led_main = 0;      // 当前主亮LED
    reg [3:0]   led_fade = 0;      // 上一个渐灭LED
    reg [6:0]   bright_main = 0;   // 正在变亮LED亮度
    reg [6:0]   bright_fade = 0;   // 渐灭LED亮度
    reg         fw_dir = 0;        // 流动方向：0右/1左
    reg [31:0]  water_timer = 0;   // 步进计时

    // === 拨码开关控制模式 ===
    wire fn_mode = dip_switch_mode; // 拨码控制功能切换，0为呼吸灯，1为流水灯

    // === 呼吸灯亮度（功能1） ===
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            breath_step     <= 0;
            breath_up       <= 1;
            breath_time_cnt <= 0;
        end else if (!fn_mode) begin
            // 仅在呼吸灯模式下工作
            if (breath_time_cnt < BREATH_STEP_CLK - 1)
                breath_time_cnt <= breath_time_cnt + 1;
            else begin
                breath_time_cnt <= 0;
                if (breath_up) begin
                    if (breath_step < BREATH_STEP_CNT)
                        breath_step <= breath_step + 1;
                    else
                        breath_up <= 0;
                end else begin
                    if (breath_step > 0)
                        breath_step <= breath_step - 1;
                    else
                        breath_up <= 1;
                end
            end
        end
    end

    // === PWM计数器 ===
    always @(posedge clk or posedge rst) begin
        if (rst)
            pwm_cnt <= 0;
        else if (pwm_cnt < PWM_PERIOD - 1)
            pwm_cnt <= pwm_cnt + 1;
        else
            pwm_cnt <= 0;
    end

    // === 流水呼吸逻辑（功能2） ===
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_main    <= 0;
            led_fade    <= 0;
            bright_main <= 0;
            bright_fade <= 0;
            fw_dir      <= 0;
            water_timer <= 0;
        end else if (fn_mode) begin
            if (water_timer < BREATH_STEP_CLK-1)
                water_timer <= water_timer + 1;
            else begin
                water_timer <= 0;
                // 主LED变亮
                if (bright_main < BREATH_STEP_CNT)
                    bright_main <= bright_main + 1;
                // 渐灭LED变暗
                if (bright_fade > 0)
                    bright_fade <= bright_fade - 1;

                // 主LED到顶，开启下一位，让上一位fade
                if (bright_main == BREATH_STEP_CNT) begin
                    led_fade     <= led_main;        // 当前位转为渐灭
                    bright_fade  <= BREATH_STEP_CNT; // 渐灭亮度拉满
                    // 改变主LED位置
                    if (!fw_dir) begin
                        if (led_main < 15)
                            led_main <= led_main + 1;
                        else begin
                            led_main <= 14;
                            fw_dir   <= 1;
                        end
                    end else begin
                        if (led_main > 0)
                            led_main <= led_main - 1;
                        else begin
                            led_main <= 1;
                            fw_dir <= 0;
                        end
                    end
                    bright_main <= 0; // 新主LED从0开始变亮
                end
            end
        end
    end

    // === PWM驱动输出 ===
    reg [15:0] led_pwm;
    always @(posedge clk or posedge rst) begin
        if (rst)
            led <= 16'b0;
        else if (!fn_mode) begin
            // 功能1：呼吸灯模式，左8与右8反向
            // 左8亮度上升，右8亮度下降
            if (pwm_cnt < breath_step * PWM_PERIOD / BREATH_STEP_CNT)
                led[7:0] <= 8'hFF;
            else
                led[7:0] <= 8'h00;
            if (pwm_cnt < (BREATH_STEP_CNT-breath_step) * PWM_PERIOD / BREATH_STEP_CNT)
                led[15:8] <= 8'hFF;
            else
                led[15:8] <= 8'h00;
        end else begin
            // 功能2：流水呼吸模式，两灯亮度渐变重叠
            led_pwm = 16'b0;
            if (pwm_cnt < (bright_main * PWM_PERIOD / BREATH_STEP_CNT))
                led_pwm[led_main] = 1'b1;
            if (bright_fade > 0 && (led_fade != led_main))
                if (pwm_cnt < (bright_fade * PWM_PERIOD / BREATH_STEP_CNT))
                    led_pwm[led_fade] = 1'b1;
            led <= led_pwm;
        end
    end

endmodule
