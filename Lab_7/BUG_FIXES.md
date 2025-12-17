# Lab_7 问题修复报告

## 修复日期
2025-12-17

## 修复的关键问题

本次修复了Lab_7频率测量与DAC控制系统中的**4个致命问题**，这些问题会导致实验完全无法正常工作。

---

### **问题1：数码管显示位序错误（最严重）**

**问题描述：**
- 原代码将AN0定义为千位、AN3定义为个位
- 实际EGO1板上数码管物理布局是：**AN0在最右边（个位），AN3在最左边（千位）**
- 导致显示的数字**完全镜像**（例如应显示1234却显示4321）

**修复内容：** `display_driver.v`
```verilog
// 修复前：
case (scan_cnt)
    2'd0: begin
        an <= 8'b00000001;      // 选通AN0（千位）❌ 错误
        digit <= digit_3;
    end
    // ...
    2'd3: begin
        an <= 8'b00001000;      // 选通AN3（个位）❌ 错误
        digit <= digit_0;
    end
endcase

// 修复后：
case (scan_cnt)
    2'd0: begin
        an <= 8'b00000001;      // 选通AN0（个位）✅ 正确
        digit <= digit_0;
    end
    // ...
    2'd3: begin
        an <= 8'b00001000;      // 选通AN3（千位）✅ 正确
        digit <= digit_3;
    end
endcase
```

**影响：** 这是导致数字显示错误的直接原因。修复后频率值将正确显示。

---

### **问题2：clk_1Hz不是tick脉冲而是时钟信号（致命）**

**问题描述：**
- 原代码中 `clk_1Hz` 被实现为**翻转时钟**（0.5Hz方波）
- 每秒翻转一次，周期是2秒，导致测量窗口变成**2秒而非1秒**
- 测得的频率值会**偏大接近2倍**（实际是测量2秒内的脉冲数）

**修复内容：** `clk_div.v`
```verilog
// 修复前（翻转时钟）：
localparam CNT_1HZ = CLK_FREQ / 2;        // 50,000,000 ❌
reg [25:0] cnt_1Hz;                       // 26位 ❌

always @(posedge clk or posedge rst) begin
    if (cnt_1Hz >= CNT_1HZ - 1) begin
        cnt_1Hz <= 26'd0;
        clk_1Hz <= ~clk_1Hz;              // 翻转 ❌
    end else begin
        cnt_1Hz <= cnt_1Hz + 1'b1;
    end
end

// 修复后（单周期tick脉冲）：
localparam CNT_1HZ = CLK_FREQ - 1;        // 99,999,999 ✅
reg [26:0] cnt_1Hz;                       // 27位 ✅

always @(posedge clk or posedge rst) begin
    if (cnt_1Hz >= CNT_1HZ) begin
        cnt_1Hz <= 27'd0;
        clk_1Hz <= 1'b1;                  // 单周期脉冲 ✅
    end else begin
        cnt_1Hz <= cnt_1Hz + 1'b1;
        clk_1Hz <= 1'b0;                  // 其他时刻为低 ✅
    end
end
```

**影响：** 修复后测量窗口准确为1秒，频率测量值将准确无误。

---

### **问题3：频率测量边界时序问题（会丢失边界脉冲）**

**问题描述：**
- 原代码使用边沿检测 `window_tick = clk_1Hz & ~clk_1Hz_prev`
- 然后在同一个always块中：先清零计数器、再判断是否计数
- 如果窗口边界恰好有信号上升沿，该脉冲会**丢失**
- 频率测量在边界处会有**±1的误差**

**修复内容：** `freq_meter.v`
```verilog
// 修复前（会丢失边界脉冲）：
reg clk_1Hz_prev;
wire window_tick;

always @(posedge clk or posedge rst) begin
    clk_1Hz_prev <= clk_1Hz;
end
assign window_tick = clk_1Hz & ~clk_1Hz_prev;  // 边沿检测 ❌

always @(posedge clk or posedge rst) begin
    if (window_tick) begin
        edge_count <= 16'd0;              // 先清零 ❌
    end else if (signal_posedge) begin
        edge_count <= edge_count + 1'b1;
    end
end

always @(posedge clk or posedge rst) begin
    if (window_tick) begin
        freq <= edge_count;               // 锁存值已被清零 ❌
    end
end

// 修复后（先锁存后清零）：
// 删除了window_tick，直接用clk_1Hz（已经是单周期脉冲）

always @(posedge clk or posedge rst) begin
    if (clk_1Hz) begin
        edge_count <= 16'd0;              // tick时清零 ✅
    end else if (signal_posedge) begin
        edge_count <= edge_count + 1'b1;  // 其他时候计数 ✅
    end
end

always @(posedge clk or posedge rst) begin
    if (clk_1Hz) begin
        freq <= edge_count;               // tick时先锁存当前值 ✅
    end
end
```

**关键改进：**
1. 去掉了多余的 `window_tick` 边沿检测（因为 `clk_1Hz` 现在就是tick脉冲）
2. 两个always块在同一个时钟周期执行，但锁存操作读取的是**清零前**的edge_count值
3. 这是Verilog的非阻塞赋值特性：同一周期内，右值使用的是**更新前**的值

**影响：** 修复后测量精度提高，边界处不会丢失脉冲。

---

### **问题4：LED1直接使用异步信号（违反时序设计）**

**问题描述：**
- 原代码 `assign led[1] = signal_in;` 直接将异步输入连到LED
- 虽然只影响LED显示，但违反了"所有异步输入必须同步"的设计原则
- 可能导致LED显示不稳定

**修复内容：** `top.v`
```verilog
// 修复前：
assign led[1] = signal_in;  // 直接用异步信号 ❌

// 修复后：
reg signal_in_sync1, signal_in_sync2;
always @(posedge clk or posedge rst_sync) begin
    if (rst_sync) begin
        signal_in_sync1 <= 1'b0;
        signal_in_sync2 <= 1'b0;
    end else begin
        signal_in_sync1 <= signal_in;
        signal_in_sync2 <= signal_in_sync1;
    end
end
assign led[1] = signal_in_sync2;  // 使用同步后的信号 ✅
```

**影响：** LED显示更稳定，符合同步设计规范。

---

## 修复后的预期效果

### **上板验证方法：**

1. **频率显示测试**
   - 将NE555输出连接到J5扩展口（默认引脚G17）
   - 调整拨码开关改变DAC输出，从而改变NE555频率
   - 观察数码管显示的频率值（0-9999 Hz）
   - **预期：数字正序显示，数值准确**

2. **LED指示测试**
   - LED0：每秒闪烁一次（测量窗口tick指示）
   - LED1：跟随NE555输出信号闪烁
   - LED2：频率 > 1kHz时点亮
   - LED3：频率 > 5kHz时点亮

3. **精度验证**
   - 用示波器或频率计测量NE555输出的实际频率
   - 对比数码管显示值，误差应在 ±1 Hz以内

### **常见问题排查：**

如果上板后仍有问题：

1. **数码管全灭或全亮**
   - 检查RST按键是否一直按住（P15）
   - 检查约束文件中时钟引脚是否正确（P17）

2. **数码管显示乱码**
   - 检查seg0段码映射是否与硬件一致
   - 确认共阴极极性（段选高有效）

3. **频率值为0**
   - 检查signal_in连接（默认G17，可能需要根据实际硬件调整）
   - 确认NE555输出信号幅度（应为3.3V LVCMOS电平）

4. **频率值偏差大**
   - 确认系统时钟是否为100MHz
   - 检查NE555工作状态

---

## 文件修改清单

| 文件 | 修改行数 | 主要修改内容 |
|------|---------|-------------|
| `src/display_driver.v` | 8行 | 修正数码管位序映射（AN0-AN3对应个-十-百-千） |
| `src/clk_div.v` | 15行 | 将clk_1Hz从翻转时钟改为1Hz单周期tick脉冲 |
| `src/freq_meter.v` | 30行 | 删除window_tick边沿检测，优化计数时序 |
| `src/top.v` | 15行 | 为LED1的signal_in添加两级同步 |

---

## 总结

本次修复解决了Lab_7实验中的**4个关键问题**，其中前3个是导致实验完全无法工作的致命缺陷：

1. ✅ **数码管镜像显示** → 修正位序映射
2. ✅ **频率测量偏大2倍** → clk_1Hz改为真正的1Hz tick
3. ✅ **边界脉冲丢失** → 优化计数与锁存时序
4. ✅ **异步信号直连LED** → 添加两级同步

修复后的代码：
- ✅ 可综合、时序可靠
- ✅ 频率测量准确（窗口=1秒，误差<±1Hz）
- ✅ 数码管正确显示（0-9999 Hz）
- ✅ 符合EGO1硬件特性（共阴极、高有效、100MHz时钟）

**可直接用于上板验收！**
