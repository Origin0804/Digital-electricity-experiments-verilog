这里的项目都是基于我们使用的板卡EGO1设计的，它的数码管是分成两个片区，具体的引脚可以参考Ego1_UserManual

以下是 EGO1 开发板主要外设的引脚分配总结。为了方便查阅，我将其按功能模块进行了分类。

### 1. 时钟与复位 (Clock & Reset)
* [cite_start]**系统时钟 (100MHz):** P17 [cite: 38]
* [cite_start]**复位按键 (RST/S6):** P15 [cite: 87]
    * [cite_start]*注意：此按键也可用作普通输入，若设计中不需要外部触发复位。* [cite: 73]

---

### 2. 开关 (Switches)
EGO1 板载两组开关：一组是位于板子下方的**拨码开关 (Slide Switches)**，另一组是**8位 DIP 开关组**。

#### 通用拨码开关 (Slide Switches, SW0-SW7)
位于板卡边缘，通常用于模式选择或数据输入。

| 开关名称 | FPGA 引脚 |
| :--- | :--- |
| **SW0** | [cite_start]R1 [cite: 114] |
| **SW1** | [cite_start]N4 [cite: 114] |
| **SW2** | [cite_start]M4 [cite: 114] |
| **SW3** | [cite_start]R2 [cite: 114] |
| **SW4** | [cite_start]P2 [cite: 114] |
| **SW5** | [cite_start]P3 [cite: 114] |
| **SW6** | [cite_start]P4 [cite: 114] |
| **SW7** | [cite_start]P5 [cite: 114] |

#### 8位 DIP 开关 (DIP Switch Block, SW8)
位于板卡中间区域的红色开关组。

| 开关位 | FPGA 引脚 |
| :--- | :--- |
| **DIP_SW0** | [cite_start]T5 [cite: 114] |
| **DIP_SW1** | [cite_start]T3 [cite: 114] |
| **DIP_SW2** | [cite_start]R3 [cite: 114] |
| **DIP_SW3** | [cite_start]V4 [cite: 114] |
| **DIP_SW4** | [cite_start]V5 [cite: 114] |
| **DIP_SW5** | [cite_start]V2 [cite: 114] |
| **DIP_SW6** | [cite_start]U2 [cite: 114] |
| **DIP_SW7** | [cite_start]U3 [cite: 114] |

---

### 3. 按键 (Push Buttons)
[cite_start]板载 5 个通用按键，按下时输出**高电平** [cite: 89]。

| 按键名称 | FPGA 引脚 | 原理图标号 |
| :--- | :--- | :--- |
| **S0** (Center) | [cite_start]R11 [cite: 97] | PB0 |
| **S1** (Up) | [cite_start]R17 [cite: 97] | PB1 |
| **S2** (Left) | [cite_start]R15 [cite: 97] | PB2 |
| **S3** (Down) | [cite_start]V1 [cite: 97] | PB3 |
| **S4** (Right) | [cite_start]U4 [cite: 97] | PB4 |

---

### 4. LED 指示灯 (LEDs)
[cite_start]LED 在 FPGA 输出**高电平**时点亮 [cite: 116]。

| LED 编号 | FPGA 引脚 | LED 编号 | FPGA 引脚 |
| :--- | :--- | :--- | :--- |
| **LED0** | [cite_start]K3 [cite: 165] | **LED8** | [cite_start]K2 [cite: 165] |
| **LED1** | [cite_start]M1 [cite: 165] | **LED9** | [cite_start]J2 [cite: 165] |
| **LED2** | [cite_start]L1 [cite: 165] | **LED10** | [cite_start]J3 [cite: 165] |
| **LED3** | [cite_start]K6 [cite: 165] | **LED11** | [cite_start]H4 [cite: 165] |
| **LED4** | [cite_start]J5 [cite: 165] | **LED12** | [cite_start]J4 [cite: 165] |
| **LED5** | [cite_start]H5 [cite: 165] | **LED13** | [cite_start]G3 [cite: 165] |
| **LED6** | [cite_start]H6 [cite: 165] | **LED14** | [cite_start]G4 [cite: 165] |
| **LED7** | [cite_start]K1 [cite: 165] | **LED15** | [cite_start]F6 [cite: 165] |

---

### 5. 七段数码管 (7-Segment Display)
[cite_start]数码管为**共阴极**，位选（片选）信号和段选信号均为**高电平有效** [cite: 167, 168]。

#### 位选信号 (Digit Select / AN)
| 数码管位 | FPGA 引脚 | 描述 |
| :--- | :--- | :--- |
| **AN0** (BIT1) | [cite_start]G2 [cite: 220] | 右侧第1位 |
| **AN1** (BIT2) | [cite_start]C2 [cite: 220] | 右侧第2位 |
| **AN2** (BIT3) | [cite_start]C1 [cite: 220] | 右侧第3位 |
| **AN3** (BIT4) | [cite_start]H1 [cite: 220] | 右侧第4位 |
| **AN4** (BIT5) | [cite_start]G1 [cite: 220] | 左侧第1位 |
| **AN5** (BIT6) | [cite_start]F1 [cite: 220] | 左侧第2位 |
| **AN6** (BIT7) | [cite_start]E1 [cite: 220] | 左侧第3位 |
| **AN7** (BIT8) | [cite_start]G6 [cite: 220] | 左侧第4位 |

#### 段选信号 (Segment Data)
注意：手册中将段选分为了两组 (A0-G0 和 A1-G1)，通常建议先测试左侧（A1组）和右侧（A0组）是否复用或独立。

| 段名 | 组0 (右4位) | 组1 (左4位) | 段名 | 组0 (右4位) | 组1 (左4位) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **CA** | [cite_start]B4 [cite: 220] | [cite_start]D4 [cite: 220] | **CE** | [cite_start]A1 [cite: 220] | [cite_start]F3 [cite: 220] |
| **CB** | [cite_start]A4 [cite: 220] | [cite_start]E3 [cite: 220] | **CF** | [cite_start]B3 [cite: 220] | [cite_start]E2 [cite: 220] |
| **CC** | [cite_start]A3 [cite: 220] | [cite_start]D3 [cite: 220] | **CG** | [cite_start]B2 [cite: 220] | [cite_start]D2 [cite: 220] |
| **CD** | [cite_start]B1 [cite: 220] | [cite_start]F4 [cite: 220] | **DP** | [cite_start]D5 [cite: 220] | [cite_start]H2 [cite: 220] |

---

### 6. 其他常用接口

#### VGA 接口 (12-bit Color)
| 信号 | [cite_start]引脚 [cite: 309] | 信号 | [cite_start]引脚 [cite: 309] | 信号 | [cite_start]引脚 [cite: 309] |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Red 0** | F5 | **Green 0** | B6 | **Blue 0** | C7 |
| **Red 1** | C6 | **Green 1** | A6 | **Blue 1** | E6 |
| **Red 2** | C5 | **Green 2** | A5 | **Blue 2** | E5 |
| **Red 3** | B7 | **Green 3** | D8 | **Blue 3** | E7 |
| **HSYNC** | D7 | **VSYNC** | C4 | | |

#### 音频接口 (Audio)
| 名称 | FPGA 引脚 |
| :--- | :--- |
| **AUDIO_PWM** | [cite_start]T1 [cite: 317] |
| **AUDIO_SD** (Shutdown) | [cite_start]M6 [cite: 317] |

#### USB-UART (串口)
| 名称 | FPGA 引脚 | 说明 |
| :--- | :--- | :--- |
| **UART_RX** | [cite_start]T4 [cite: 317] | FPGA 发送端 (连接上位机 RX) |
| **UART_TX** | [cite_start]N5 [cite: 317] | FPGA 接收端 (连接上位机 TX) |

#### PS2 接口 (键盘/鼠标)
| 名称 | FPGA 引脚 |
| :--- | :--- |
| **PS2_CLK** | [cite_start]K5 [cite: 319] |
| **PS2_DATA** | [cite_start]L4 [cite: 319] |

#### 蓝牙模块 (Bluetooth)
| 名称 | FPGA 引脚 | 说明 |
| :--- | :--- | :--- |
| **BT_RX** | [cite_start]N2 [cite: 334] | FPGA 发送 |
| **BT_TX** | [cite_start]L3 [cite: 334] | FPGA 接收 |

### Circumstance of experiment_6
This experiment request us to finish 8 different peojects as file request.md
No.2 stopwatch has been finished fundamentally. Others are gennerated by copilot, which are not ensured to be correct.