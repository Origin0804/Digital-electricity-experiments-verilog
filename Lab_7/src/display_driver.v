// 4位数码管显示驱动模块 - 4-Digit 7-Segment Display Driver
// 显示频率值（0~9999 Hz）
// 支持EGO1板载数码管左右段线独立
// 使用4位数码管：AN0-AN3（右侧4位）

module display_driver(
    input clk_scan,             // 1kHz 扫描时钟
    input rst,                  // 复位信号（高有效）
    input [15:0] freq,          // 频率值（0~65535 Hz）
    output reg [7:0] an,        // 位选信号 AN0-AN7（高有效）
    output reg [7:0] seg0,      // 右侧段选信号（高有效，用于AN0-AN3）
    output reg [7:0] seg1       // 左侧段选信号（高有效，用于AN4-AN7，本项目不使用）
);

    // 扫描计数器（0~3，对应4个数码管）
    reg [1:0] scan_cnt;
    
    // 当前显示的数字
    reg [3:0] digit;
    
    // 频率值的各位数字
    wire [3:0] digit_0;  // 个位
    wire [3:0] digit_1;  // 十位
    wire [3:0] digit_2;  // 百位
    wire [3:0] digit_3;  // 千位
    
    // BCD分离（十进制）
    // 限制显示范围为0~9999
    wire [15:0] freq_limited = (freq > 16'd9999) ? 16'd9999 : freq;
    
    assign digit_0 = freq_limited % 10;
    assign digit_1 = (freq_limited / 10) % 10;
    assign digit_2 = (freq_limited / 100) % 10;
    assign digit_3 = (freq_limited / 1000) % 10;
    
    // 七段码译码器（共阴极，高有效）
    // 段码映射：[7]=dp, [6]=a, [5]=b, [4]=c, [3]=d, [2]=e, [1]=f, [0]=g
    //      aaa
    //     f   b
    //      ggg
    //     e   c
    //      ddd  .dp
    function [7:0] seg_decode;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seg_decode = 8'b01111110;  // 0: abcdef
                4'd1: seg_decode = 8'b00110000;  // 1: bc
                4'd2: seg_decode = 8'b01101101;  // 2: abdeg
                4'd3: seg_decode = 8'b01111001;  // 3: abcdg
                4'd4: seg_decode = 8'b00110011;  // 4: bcfg
                4'd5: seg_decode = 8'b01011011;  // 5: acdfg
                4'd6: seg_decode = 8'b01011111;  // 6: acdefg
                4'd7: seg_decode = 8'b01110000;  // 7: abc
                4'd8: seg_decode = 8'b01111111;  // 8: abcdefg
                4'd9: seg_decode = 8'b01111011;  // 9: abcdfg
                default: seg_decode = 8'b00000000;  // 全灭
            endcase
        end
    endfunction
    
    // 扫描计数器
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_cnt <= 2'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end
    
    // 数码管扫描显示
    // 物理布局（从左到右）：AN0-AN1-AN2-AN3 (右侧4位)
    // 显示内容：千位-百位-十位-个位
    // AN0显示千位，AN1显示百位，AN2显示十位，AN3显示个位
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            an <= 8'b00000000;
            seg0 <= 8'b00000000;
            seg1 <= 8'b00000000;
            digit <= 4'd0;
        end else begin
            case (scan_cnt)
                2'd0: begin
                    an <= 8'b00000001;      // 选通AN0（千位）
                    digit <= digit_3;
                end
                2'd1: begin
                    an <= 8'b00000010;      // 选通AN1（百位）
                    digit <= digit_2;
                end
                2'd2: begin
                    an <= 8'b00000100;      // 选通AN2（十位）
                    digit <= digit_1;
                end
                2'd3: begin
                    an <= 8'b00001000;      // 选通AN3（个位）
                    digit <= digit_0;
                end
            endcase
            
            // 段码输出
            seg0 <= seg_decode(digit);
            seg1 <= 8'b00000000;  // 左侧数码管不使用，全灭
        end
    end

endmodule
