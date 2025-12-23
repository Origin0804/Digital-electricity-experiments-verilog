# EGO1 用户手册
2018.04 ver2.2
依元素科技有限公司（E-ELEMENTS）
XILINX UNIVERSITY PROGRAM PARTNER
Xilinx 全球合作伙伴
官网：www.e-elements.com

## 目录
- [EGO1 用户手册](#ego1-用户手册)
  - [目录](#目录)
  - [1. 概述](#1-概述)
    - [平台外设概览](#平台外设概览)
  - [2. FPGA](#2-fpga)
  - [3. 板卡供电](#3-板卡供电)
  - [4. 系统时钟](#4-系统时钟)
  - [5. FPGA 配置](#5-fpga-配置)
  - [6. 通用I/O 接口](#6-通用io-接口)
    - [6.1 按键](#61-按键)
    - [6.2 开关](#62-开关)
    - [6.3 LED 灯](#63-led-灯)
    - [6.4 七段数码管](#64-七段数码管)
  - [7. VGA 接口](#7-vga-接口)
  - [8. 音频接口](#8-音频接口)
    - [脉冲宽度调制原理](#脉冲宽度调制原理)
  - [9. USB-UART/JTAG 接口](#9-usb-uartjtag-接口)
    - [UART 协议说明](#uart-协议说明)
    - [UART 数据帧格式](#uart-数据帧格式)
  - [10. USB 转PS2 接口](#10-usb-转ps2-接口)
  - [11. SRAM 接口](#11-sram-接口)
    - [SRAM 写操作时序](#sram-写操作时序)
    - [SRAM 读操作时序](#sram-读操作时序)
    - [管脚约束](#管脚约束)
  - [12. 模拟电压输入](#12-模拟电压输入)
    - [XADC 模块框图说明](#xadc-模块框图说明)
    - [XADC 模块通道](#xadc-模块通道)
    - [XADC 模块片上传感器](#xadc-模块片上传感器)
    - [XADC 模块操作模式](#xadc-模块操作模式)
    - [XADC 模块使用方法](#xadc-模块使用方法)
    - [EGO1 模拟电压输入说明](#ego1-模拟电压输入说明)
  - [13. DAC 输出接口](#13-dac-输出接口)
    - [DAC0832 操作时序](#dac0832-操作时序)
    - [管脚约束](#管脚约束-1)
  - [14. 蓝牙模块](#14-蓝牙模块)
  - [15. 通用扩展I/O](#15-通用扩展io)
    - [管脚约束](#管脚约束-2)

## 1. 概述
EGO1 是依元素科技基于Xilinx Artix-7 FPGA 研发的便携式数模混合基础教学平台。EGO1 配备的FPGA（XC7A35T-1CSG324C）具有大容量、高性能等特点，能实现较复杂的数字逻辑设计；在FPGA 内可以构建MicroBlaze 处理器系统，可进行SoC 设计。该平台拥有丰富的外设，以及灵活的通用扩展接口。

### 平台外设概览
| 编号 | 描述 | 描述 |
| --- | --- | --- |
| 1 | VGA 接口 | 1 个模拟电压输入 |
| 2 | 音频接口 | 1 个 DAC 输出接口 |
| 3 | USB-UART/JTAG 接口 | SRAM 存储器 |
| 4 | USB 转 PS2 接口 | SPI FLASH 存储器 |
| 5 | 2 个 4 位数码管 | 蓝牙模块 |
| 6 | 16 个 LED 灯 | 通用扩展接口 |
| 7 | 8 个拔码开关 | |
| 8 | 1 个 8 位 DIP 开关 | |
| 9 | 5 个按键 | |

## 2. FPGA
EGO1 采用Xilinx Artix-7 系列XC7A35T-1CSG324C FPGA，其资源如下：

| 类别 | 规格项 | XC7A12T | XC7A15T | XC7A25T | XC7A35T |
| --- | --- | --- | --- | --- | --- |
| Logic Resources | Logic Cells | 12,800 | 16,640 | 23,360 | 33,280 |
| | Slices | 2,000 | 2,600 | 3,650 | 5,200 |
| | CLB Flip-Flops | 16,000 | 20,800 | 29,200 | 41,600 |
| Memory Resources | Maximum Distributed RAM (Kb) | 171 | 200 | 313 | 400 |
| | Block RAM/FIFO w/ ECC (36 Kb each) | 20 | 25 | 45 | 50 |
| | Total Block RAM (Kb) | 720 | 900 | 1,620 | 1,800 |
| Clock Resources | CMTS (1 MMCM + 1 PLL) | 3 | 5 | 3 | 5 |
| I/O Resources | Maximum Single-Ended I/O | 150 | 250 | 150 | 250 |
| | Maximum Differential I/O Pairs | 72 | 120 | 72 | 120 |
| | DSP Slices | 40 | 45 | 80 | 90 |
| Embedded Hard IP Resources | PCle\* Gen2 $^{(1)}$ | 1 | 1 | 1 | 1 |
| | Analog Mixed Signal (AMS) / XADC | 1 | 1 | 1 | 1 |
| | Configuration AES / HMAC Blocks | 1 | 1 | 1 | 1 |
| | GTP Transceivers (6.6 Gb/s Max Rate) | 2 | 4 | 4 | 4 |
| Commercial Speed Grades | - | -1,-2 | -1,-2 | -1,-2 | -1,-2 |
| Extended Speed Grades | - | -2L,-3 | -2L,-3 | -2L,-3 | -2L,-3 |
| Industrial Speed Grades | - | -1,-2,-1L | -1,-2,-1L | -1,-2,-1L | -1,-2,-1L |

## 3. 板卡供电
EGo1 提供两种供电方式：Type-C 和外接直流电源。EGo1 提供了一个Type-C 接口，功能为UART 和JTAG，该接口可以用于为板卡供电。板卡上提供电压转换电路将Type-C 输入的5V 电压转换为板卡上各类芯片需要的工作电压。上电成功后红色LED 灯（D18）点亮。

## 4. 系统时钟
EGO1 搭载一个100MHz 的时钟芯片，输出的时钟信号直接与FPGA 全局时钟输入引脚（P17）相连。若设计中还需要其他频率的时钟，可以采用FPGA 内部的MMCM 生成。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| 时钟引脚 | SYS_CLK | P17 |

## 5. FPGA 配置
EES328 在开始工作前必须先配置FPGA，板上提供以下方式配置FPGA：
- USB 转UART/JTAG 接口J6
- 6-pin JTAG 连接器接口J3
- SPI Flash 上电自启动

FPGA 的配置文件为后缀名.bit 的文件，用户可以通过上述的三种方法将该bit 文件烧写到FPGA 中，该文件可以通过Vivado 工具生成，BIT 文件的具体功能由用户的原始设计文件决定。

在使用SPI Flash 配置FPGA 时，需要提前将配置文件写入到Flash 中。Xilinx 开发工具Vivado 提供了写入Flash 的功能。板上SPI Flash 型号为N25Q32，支持3.3V 电压配置。FPGA 配置成功后D24 将点亮。

## 6. 通用I/O 接口
通用I/O 接口外设包括2 个专用按键、5 个通用按键、8 个拨码开关、1 个8 位DIP 开关、16 个LED 灯、8 个七段数码管。

### 6.1 按键
两个专用按键分别用于逻辑复位RST（S6）和擦除FPGA 配置PROG（S5），当设计中不需要外部触发复位时，RST 按键可以用作其他逻辑触发功能。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| 复位引脚 | FPGA_RESET | P15 |

五个通用按键，默认为低电平，按键按下时输出高电平。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| S0 | PB0 | R11 |
| S1 | PB1 | R17 |
| S2 | PB2 | R15 |
| S3 | PB3 | V1 |
| S4 | PB4 | U4 |

### 6.2 开关
开关包括8 个拨码开关和一个8 位DIP 开关。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| SW0 | SW_0 | R1 |
| SW1 | SW_1 | N4 |
| SW2 | SW_2 | M4 |
| SW3 | SW_3 | R2 |
| SW4 | SW_4 | P2 |
| SW5 | SW_5 | P3 |
| SW6 | SW_6 | P4 |
| SW7 | SW_7 | P5 |
| SW8 | SW0 | T5 |
| SW1 | T3 | - |
| SW2 | R3 | - |
| SW3 | V4 | - |
| SW4 | V5 | - |
| SW5 | V2 | - |
| SW6 | U2 | - |
| SW7 | U3 | - |

### 6.3 LED 灯
LED 在FPGA 输出高电平时被点亮。

| 名称 | 原理图标号 | FPGA IO PIN | 颜色 |
| --- | --- | --- | --- |
| D1_0 | LED1_0 | K3 | Green |
| D1_1 | LED1_1 | M1 | Green |
| D1_2 | LED1_2 | L1 | Green |
| D1_3 | LED1_3 | K6 | Green |
| D1_4 | LED1_4 | J5 | Green |
| D1_5 | LED1_5 | H5 | Green |
| D1_6 | LED1_6 | H6 | Green |
| D1_7 | LED1_7 | K1 | Green |
| D2_0 | LED2_0 | K2 | Green |
| D2_1 | LED2_1 | J2 | Green |
| D2_2 | LED2_2 | J3 | Green |
| D2_3 | LED2_3 | H4 | Green |
| D2_4 | LED2_4 | J4 | Green |
| D2_5 | LED2_5 | G3 | Green |
| D2_6 | LED2_6 | G4 | Green |
| D2_7 | LED2_7 | F6 | Green |

### 6.4 七段数码管
数码管为共阴极数码管，即公共极输入低电平。共阴极由三极管驱动，FPGA 需要提供正向信号。同时段选端连接高电平，数码管上的对应位置才可以被点亮。因此，FPGA 输出有效的片选信号和段选信号都应该是高电平。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| A0 | CA0 | B4 |
| B0 | CB0 | A4 |
| C0 | CC0 | A3 |
| D0 | CD0 | B1 |
| E0 | CE0 | A1 |
| F0 | CF0 | B3 |
| G0 | CG0 | B2 |
| DP0 | DP0 | D5 |
| A1 | CA1 | D4 |
| B1 | CB1 | E3 |
| C1 | CC1 | D3 |
| D1 | CD1 | F4 |
| E1 | CE1 | F3 |
| F1 | CF1 | E2 |
| G1 | CG1 | D2 |
| DP1 | DP1 | H2 |
| DN0_K1 | BIT1 | G2 |
| DN0_K2 | BIT2 | C2 |
| DN0_K3 | BIT3 | C1 |
| DN0_K4 | BIT4 | H1 |
| DN1_K1 | BIT5 | G1 |
| DN1_K2 | BIT6 | F1 |
| DN1_K3 | BIT7 | E1 |
| DN1_K4 | BIT8 | G6 |

## 7. VGA 接口
EGO1 上的VGA 接口（J1）通过14 位信号线与FPGA 连接，红、绿、蓝三个颜色信号各占4 位，另外还包括行同步和场同步信号。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| RED | VGA_R0 | F5 |
| - | VGA_R1 | C6 |
| - | VGA_R2 | C5 |
| - | VGA_R3 | B7 |
| GREEN | VGA_G0 | B6 |
| - | VGA_G1 | A6 |
| - | VGA_G2 | A5 |
| - | VGA_G3 | D8 |
| BLUE | VGA_B0 | C7 |
| - | VGA_B1 | E6 |
| - | VGA_B2 | E5 |
| - | VGA_B3 | E7 |
| H-SYNC | VGA_HSYNC | D7 |
| V-SYNC | VGA_VSYNC | C4 |

## 8. 音频接口
EGO1 上的单声道音频输出接口（J12）由低通滤波器电路驱动。滤波器的输入信号（AUDIO_PWM）是由FPGA 产生的脉冲宽度调制信号（PWM）或脉冲密度调制信号（PDM）。低通滤波器将输入的数字信号转化为模拟电压信号输出到音频插孔上。

### 脉冲宽度调制原理
脉冲宽度调制信号是一连串频率固定的脉冲信号，每个脉冲的宽度都可能不同。这种数字信号在通过一个简单的低通滤波器后，被转化为模拟电压信号，电压的大小跟一定区间内的平均脉冲宽度成正比。这个区间由低通滤波器的3dB 截止频率和脉冲频率共同决定。例如，脉冲为高电平的时间占有效脉冲周期的10%的话，滤波电路产生的模拟电压值就是Vdd 电压的十分之一。

低通滤波器3dB 频率要比PWM 信号频率低一个数量级，这样PWM 频率上的信号能量才能从输入信号中过滤出来。例如，要得到一个最高频率为5KHz 的音频信号，那么PWM 信号的频率至少为50KHz 或者更高。通常，考虑到模拟信号的保真度，PWM 信号的频率越高越好。滤波器输出信号幅度与Vdd 的比值等于PWM 信号的占空比。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| AUDIO PWM | AUDIO_PWM | T1 |
| AUDIO SD | AUDIO_SD# | M6 |

## 9. USB-UART/JTAG 接口
该模块将UART/JTAG 转换成USB 接口。用户可以非常方便的直接采用USB 线缆连接板卡与PC 机USB 接口，通过Xilinx 的配置软件如Vivado 完成对板卡的配置。同时也可以通过串口功能与上位机进行通信。

| 名称 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| UART RX | UART_RX | (FPGA 串口发送端) |
| UART TX | UART_TX | (FPGA 串口接收端) |

### UART 协议说明
UATR 的全称是通用异步收发器，是实现设备之间低速数据通信的标准协议。“异步”指不需要额外的时钟线进行数据的同步传输，双方约定在同一个频率下收发数据，此接口只需要两条信号线（RXD、TXD）就可以完成数据的相互通信，接收和发送可以同时进行，也就是全双工。

收发的过程：在发送器空闲时间，数据线处于逻辑1 状态，当提示有数据要传输时，首先使数据线的逻辑状态为低，之后是8 个数据位、一位校验位、一位停止位，校验一般是奇偶校验，停止位用于标示一帧的结束，接收过程亦类似，当检测到数据线变低时，开始对数据线以约定的频率抽样，完成接收过程。本例数据帧采用：无校验位，停止位为一位。

### UART 数据帧格式
起始位 → 8位数据 → 奇偶校验位 → 停止位
0 → 0/1 0/1 0/1 0/1 0/1 0/1 0/1 0/1 → 0/1 → 1

## 10. USB 转PS2 接口
为方便用户直接使用键盘鼠标，EGO1 直接支持USB 键盘鼠标设备。用户可将标准的USB 键盘鼠标设备直接接入板上J4 USB 接口，通过PIC24FJ128，转换为标准的PS/2 协议接口。该接口不支持USB 集线器，只能连接一个鼠标或键盘。鼠标和键盘通过标准的PS/2 接口信号与FPGA 进行通信。

| 序号 | PIC24FJ128 标号 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- | --- |
| 15 | - | PS2_CLK | K5 |
| 12 | - | PS2_DATA | L4 |

## 11. SRAM 接口
板卡搭载的IS61WV12816BLL SRAM 芯片，总容量8Mbit。该SRAM 为异步式SRAM，最高存取时间可达8ns。操控简单，易于读写。

### SRAM 写操作时序
（详细请参考SRAM 用户手册）
| 时序参数 | 说明 |
| --- | --- |
| twc | 写周期时间 |
| tHA | 地址保持时间 |
| tAw | 地址建立时间 |
| PWE1 | 写使能脉冲宽度 |
| tsA | 地址稳定到数据有效时间 |
| tPBW | 数据保持时间 |
| tHZWE | 写使能无效到高阻时间 |
| tLZWE | 写使能有效到数据有效时间 |

### SRAM 读操作时序
（详细请参考SRAM 用户手册）
| 时序参数 | 说明 |
| --- | --- |
| tRC | 读周期时间 |
| tAA | 地址访问时间 |
| tOHA | 输出保持时间 |
| tDOE | 输出使能到数据有效时间 |
| tHZOE | 输出使能无效到高阻时间 |
| tLZOE | 输出使能有效到数据有效时间 |
| tLZCE | 片选有效到数据有效时间 |
| tHZCE | 片选无效到高阻时间 |
| tAC | 地址变化到数据有效时间 |
| tPD | 传播延迟 |

### 管脚约束
| SRAM 引脚标号 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| I/O0 | MEM_D0 | U17 |
| I/O1 | MEM_D1 | U18 |
| I/O2 | MEM_D2 | U16 |
| I/O3 | MEM_D3 | V17 |
| I/O4 | MEM_D4 | T11 |
| I/O5 | MEM_D5 | U11 |
| I/O6 | MEM_D6 | U12 |
| I/O7 | MEM_D7 | V12 |
| I/O8 | MEM_D8 | V10 |
| I/O9 | MEM_D9 | V11 |
| I/O10 | MEM_D10 | U14 |
| I/O11 | MEM_D11 | V14 |
| I/O12 | MEM_D12 | T13 |
| I/O13 | MEM_D13 | U13 |
| I/O14 | MEM_D14 | T9 |
| I/O15 | MEM_D15 | T10 |
| A00 | MEM_A00 | T15 |
| A01 | MEM_A01 | T14 |
| A02 | MEM_A02 | N16 |
| A03 | MEM_A03 | N15 |
| A04 | MEM_A04 | M17 |
| A05 | MEM_A05 | M16 |
| A06 | MEM_A06 | P18 |
| A07 | MEM_A07 | N17 |
| A08 | MEM_A08 | P14 |
| A09 | MEM_A09 | N14 |
| A10 | MEM_A10 | T18 |
| A11 | MEM_A11 | R18 |
| A12 | MEM_A12 | M13 |
| A13 | MEM_A13 | R13 |
| A14 | MEM_A14 | R12 |
| A15 | MEM_A15 | M18 |
| A16 | MEM_A16 | L18 |
| A17 | MEM_A17 | L16 |
| A18 | MEM_A18 | L15 |
| OE | SRAM_OE# | T16 |
| CE | SRAM_CE# | V15 |
| WE | SRAM_WE# | V16 |
| UB | SRAM_UB | R16 |
| LB | SRAM_LB | R10 |

## 12. 模拟电压输入
Xilinx 7 系列的FPGA 芯片内部集成了两个12bit 位宽、采样率为1MSPS 的ADC，拥有多达17 个外部模拟信号输入通道，为用户的设计提供了通用的、高精度的模拟输入接口。

### XADC 模块框图说明
XADC 模块包含片上温度传感器、供电电压传感器、1.25V 片上参考电压、控制状态寄存器、两个12 位1MSPS ADC、多路选择器、DRP 接口、JTAG 接口等。

### XADC 模块通道
XADC 模块有一专用的支持差分输入的模拟通道输入引脚（VP/VN），另外还最多有16 个辅助的模拟通道输入引脚（ADxP 和ADxN，x 为0 到15）。

### XADC 模块片上传感器
XADC 模块包括一定数量的片上传感器用来测量片上的供电电压和芯片温度，这些测量转换数据存储在状态寄存器（status registers）内，可由FPGA 内部的动态配置端口（Dynamic Reconfiguration Port (DRP)）的16 位同步读写端口访问。ADC 转换数据也可以由JTAG TAP 访问，此时不需要直接例化XADC 模块，XADC 模块工作在缺省模式，专用于监视芯片上的供电电压和芯片温度。

### XADC 模块操作模式
XADC 模块的操作模式由用户通过DRP 或JTAG 接口写控制寄存器选择，控制寄存器的初始值可在设计中例化XADC 模块时的块属性（block attributes）指定。模式选择由控制寄存器41H 的SEQ3 到SEQ0 比特决定：

| SEQ3 | SEQ2 | SEQ1 | SEQ0 | Function |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | Default Mode |
| 0 | 0 | 0 | 1 | Single pass sequence |
| 0 | 0 | 1 | 0 | Continuous sequence mode |
| 0 | 0 | 1 | 1 | Single Channel mode (Sequencer Off) |
| 0 | 1 | x | x | Simultaneous Sampling Mode |
| 1 | 0 | x | x | Independent ADC Mode |
| 1 | 1 | x | x | Default Mode |

### XADC 模块使用方法
1. 直接用FPGA JTAG 专用接口访问，这时XADC 模块工作在缺省模式；
2. 在设计中例化XADC 模块，可通过FPGA 逻辑或ZYNQ 器件的PS 到ADC 模块的专用接口访问。（详细请参考XADC 用户手册ug480_7Series_XADC.pdf）

### EGO1 模拟电压输入说明
EGO1 通过电位器（W1）向FPGA 提供模拟电压输入，输入的模拟电压随着电位器的旋转在0 ~ 1V 之间变化。输入的模拟信号与FPGA 的C12 引脚相连，最终通过通道1 输入到内部ADC。

## 13. DAC 输出接口
EGO1 上集成了8 位的模数转换芯片（DAC0832），DAC 输出的模拟信号连接到接口J2 上。

### DAC0832 操作时序
（详细请参考DAC0832 用户手册）
| 时序参数 | 说明 |
| --- | --- |
| tcs | 片选信号有效时间 |
| tCH | 片选信号保持时间 |
| tos | 数据建立时间 |
| toH | 数据保持时间 |

### 管脚约束
| DAC0832 引脚标号 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| DI0 | DAC_D0 | T8 |
| DI1 | DAC_D1 | R8 |
| DI2 | DAC_D2 | T6 |
| DI3 | DAC_D3 | R7 |
| DI4 | DAC_D4 | U6 |
| DI5 | DAC_D5 | U7 |
| DI6 | DAC_D6 | V9 |
| DI7 | DAC_D7 | U9 |
| ILE(BYTE2) | DAC_BYTE2 | R5 |
| CS | DAC_CS# | N6 |
| WR1 | DAC_WR1# | V6 |
| WR2 | DAC_WR2# | R6 |
| XFER | DAC_XFER# | V7 |

## 14. 蓝牙模块
EGO1 上集成了蓝牙模块（BLE-CC41-A），FPGA 通过串口和蓝牙模块进行通信。波特率支持1200、2400、4800、9600、14400、19200、38400、57600、115200 和230400bps。串口缺省波特率为9600bps。该模块支持AT 命令操作方法。

| BLE-CC41-A 标号 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| UART_RX | BT_RX | (FPGA 串口发送端) |
| UART_TX | BT_TX | (FPGA 串口接收端) |

## 15. 通用扩展I/O
EGO1 上为用户提供了灵活的通用接口（J5）用来作I/O 扩展，共提供32 个双向IO，每个IO 支持过流过压保护。

### 管脚约束
| 2x18 标号 | 原理图标号 | FPGA IO PIN |
| --- | --- | --- |
| 1 | AD2P_15 | B16 |
| 2 | AD2N_15 | B17 |
| 3 | AD10P_15 | A15 |
| 4 | AD10N_15 | A16 |
| 5 | AD3P_15 | A13 |
| 6 | AD3N_15 | A14 |
| 7 | AD11P_15 | B18 |
| 8 | AD11N_15 | A18 |
| 9 | AD9P_15 | F13 |
| 10 | AD9N_15 | F14 |
| 11 | AD8P_15 | B13 |
| 12 | AD8N_15 | B14 |
| 13 | AD0P_15 | D14 |
| 14 | AD0N_15 | C14 |
| 15 | IO_L4P | B11 |
| 16 | IO_L4N | A11 |
| 17 | IO_L11P | E15 |
| 18 | IO_L11N | E16 |
| 19 | IO_L12P | D15 |
| 20 | IO_L12N | C15 |
| 21 | IO_L13P | H16 |
| 22 | IO_L13N | G16 |
| 23 | IO_L14P | F15 |
| 24 | IO_L14N | F16 |
| 25 | IO_L15P | H14 |
| 26 | IO_L15N | G14 |
| 27 | IO_L16P | E17 |
| 28 | IO_L16N | D17 |
| 29 | IO_L17P | K13 |
| 30 | IO_L17N | J13 |
| 31 | IO_L18P | H17 |
| 32 | IO_L18N | G17 |