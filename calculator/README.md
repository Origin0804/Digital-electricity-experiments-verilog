# 计算器 (Calculator) - 交互式逐位输入设计

## 功能概述 (Feature Overview)

这是一个基于FPGA的交互式计算器，支持加减乘除运算和小数运算。采用4状态交互流程，提供直观的逐位数字输入体验。

This is an FPGA-based interactive calculator supporting add, subtract, multiply, and divide operations with decimal support. Features a 4-state interaction flow with intuitive digit-by-digit input.

## 硬件要求 (Hardware Requirements)

- **FPGA开发板**: EGO1
- **时钟**: 100MHz (P17)
- **按键**: S0 (左移), S2 (确认/小数点), S3 (右移)
- **拨码开关**: SW0-SW7
  - SW0-SW3: 运算选择 (加/减/乘/除)
  - SW4-SW7: 数字输入 (BCD码)
- **显示**: 8个七段数码管
  - 第1个: 符号 (+/-)
  - 第2-8个: 数字 (7位)

## 操作说明 (Operation Instructions)

### 4状态交互流程 (4-State Interaction Flow)

#### 状态0: 输入第一个数字 (State 0: Input First Number)
1. 使用 **S0/S3** 左右移动光标选择数位
2. 通过 **SW4-SW7** 输入数字 (二进制转BCD)
3. **长按S2** (1秒) 标记当前位为小数点
4. 当前输入位会**闪烁**提示
5. **短按S2** 确认并进入下一步

#### 状态1: 选择运算 (State 1: Select Operation)
1. 使用 **SW0-SW3** 选择运算类型:
   - SW0: 加法 (Add) - 显示 "Add"
   - SW1: 减法 (Sub) - 显示 "S0 "
   - SW2: 乘法 (Mul) - 显示 "P0 "
   - SW3: 除法 (Div) - 显示 "d10"
2. 若多个开关同时上拨，优先级: SW3 > SW2 > SW1 > SW0
3. **短按S2** 确认并进入下一步

#### 状态2: 输入第二个数字 (State 2: Input Second Number)
操作方式与状态0相同

#### 状态3: 显示结果 (State 3: Display Result)
1. 自动显示计算结果
2. 结果会自动作为下一轮计算的第一个数
3. **短按S2** 开始新的计算

## 模块说明 (Module Description)

### 1. top.v - 顶层模块
整合所有子模块，负责信号连接和接口定义。

### 2. calc_logic.v - 计算器逻辑
- 4状态状态机实现
- 数字输入管理
- 算术运算执行
- 定点数运算 (小数点后4位精度)

### 3. display_driver.v - 显示驱动
- 8位七段数码管驱动
- 1kHz扫描频率
- 符号显示 (+/-)
- 小数点显示
- 光标闪烁 (2Hz)

### 4. long_press_detector.v - 长按检测
- 区分短按和长按
- 长按阈值: 1秒 (100个时钟周期 @ 100Hz)
- 边沿检测和脉冲输出

### 5. clk_div.v - 时钟分频
- 扫描时钟: 1kHz (显示刷新)
- 消抖时钟: 100Hz (按键消抖)
- 闪烁时钟: 2Hz (光标闪烁)

### 6. debounce.v - 消抖模块
- 按键消抖
- 开关消抖
- 移位寄存器实现

## 技术特性 (Technical Features)

### 定点数运算 (Fixed-Point Arithmetic)
- 内部使用64位定点数
- 小数点后4位精度 (10000倍放大)
- 支持7位十进制数字显示

### 数据流 (Data Flow)
```
输入数字 → 数字数组 [6:0] → 定点数转换 → 运算 → 结果数组 → 显示
```

### 显示映射 (Display Mapping)
```
AN7: 符号位    AN6-AN0: 数字6到数字0
[±] [6] [5] [4] [3] [2] [1] [0]
```

## 注意事项 (Notes)

1. **小数点位置**: 
   - 从右往左: 0 (个位), 1 (十位), ... , 6 (百万位)
   - 小数点位置决定了定点数的缩放

2. **除零保护**: 
   - 除数为0时返回0

3. **溢出处理**: 
   - 7位显示限制，超出范围会截断

4. **开关输入**:
   - SW4-SW7组成4位BCD码 (0-15)
   - 只接受0-9的有效数字

## 示例 (Examples)

### 示例1: 简单加法 (Simple Addition)
```
输入第一个数: 123
选择运算: SW0 (加法)
输入第二个数: 456
结果: 579
```

### 示例2: 小数运算 (Decimal Operation)
```
输入第一个数: 12.5 (输入125，在位置1长按S2标记小数点)
选择运算: SW2 (乘法)
输入第二个数: 2
结果: 25
```

## 调试提示 (Debugging Tips)

1. 如果显示不正确，检查 `an` 位选信号
2. 如果数字不更新，检查开关消抖逻辑
3. 如果长按不工作，检查时钟分频配置
4. 如果运算错误，检查定点数转换逻辑

## 文件清单 (File List)

- `top.v` - 顶层模块
- `calc_logic.v` - 计算器逻辑
- `display_driver.v` - 显示驱动
- `long_press_detector.v` - 长按检测
- `clk_div.v` - 时钟分频
- `debounce.v` - 消抖模块
- `calculator.xdc` - 约束文件 (引脚配置)
- `README.md` - 本文档

## 作者 (Author)

Implementation Date: 2025-12-09
