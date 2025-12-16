// DAC0832控制模块 - DAC0832 Control Module
// 基本任务模式：将8位拨码开关的值直接输出给DAC0832
// DAC0832工作在直通模式，WR1和WR2同时有效

module dac_ctrl(
    input clk,              // 100MHz 系统时钟
    input rst,              // 复位信号（高有效）
    input [7:0] sw,         // 8位拨码开关输入（SW0~SW7）
    output reg [7:0] dac_data,  // DAC数据输出（DI7~DI0）
    output reg dac_wr1,     // DAC写使能1（低有效）
    output reg dac_wr2,     // DAC写使能2（低有效）
    output reg dac_cs       // DAC片选（低有效）
);

    // DAC0832工作在直通模式
    // WR1和WR2同时拉低，将数据直接写入DAC
    // CS保持低电平有效
    
    // 同步拨码开关输入（防止亚稳态）
    reg [7:0] sw_sync1, sw_sync2;
    
    // 写控制状态机
    localparam IDLE = 2'b00;
    localparam WRITE = 2'b01;
    localparam HOLD = 2'b10;
    
    reg [1:0] state;
    reg [3:0] hold_cnt;     // 保持计数器
    
    // 同步拨码开关输入
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_sync1 <= 8'd0;
            sw_sync2 <= 8'd0;
        end else begin
            sw_sync1 <= sw;
            sw_sync2 <= sw_sync1;
        end
    end
    
    // DAC控制状态机
    // 简化版本：直接输出，CS、WR1、WR2保持有效
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dac_data <= 8'd0;
            dac_cs <= 1'b0;      // 片选始终有效（低有效）
            dac_wr1 <= 1'b0;     // WR1始终有效（低有效）
            dac_wr2 <= 1'b0;     // WR2始终有效（低有效）
            state <= IDLE;
            hold_cnt <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    dac_data <= sw_sync2;
                    dac_cs <= 1'b0;
                    dac_wr1 <= 1'b0;
                    dac_wr2 <= 1'b0;
                    state <= WRITE;
                end
                
                WRITE: begin
                    // 数据有效，等待几个时钟周期以确保DAC响应
                    dac_data <= sw_sync2;
                    dac_cs <= 1'b0;
                    dac_wr1 <= 1'b0;
                    dac_wr2 <= 1'b0;
                    hold_cnt <= 4'd0;
                    state <= HOLD;
                end
                
                HOLD: begin
                    // 保持写使能一段时间（至少100ns，确保DAC0832建立时间）
                    // DAC0832典型建立时间为1us，这里保持10个时钟周期（100ns）作为最小值
                    if (hold_cnt >= 4'd10) begin
                        hold_cnt <= 4'd0;
                        state <= IDLE;
                    end else begin
                        hold_cnt <= hold_cnt + 1'b1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
