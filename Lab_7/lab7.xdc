# Lab7 频率测量与控制系统约束文件
# 目标板卡：EGO1 FPGA开发板 (Artix-7)
# 实验内容：NE555频率测量与DAC0832控制

# ========================================
# 时钟约束
# ========================================
# 系统时钟 100MHz (P17)
set_property PACKAGE_PIN P17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.0 -name sys_clk [get_ports clk]

# ========================================
# 复位按键
# ========================================
# RST/S6 复位按键 (P15) - 按下为高电平
set_property PACKAGE_PIN P15 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# ========================================
# NE555信号输入
# ========================================
# J5扩展口 - 使用通用扩展引脚
# 
# 重要提示：
# 推荐默认使用 J5 的 IO_L18N 引脚 (G17)，如硬件连接不同请改为实际引脚
#
# 可能的备选引脚（根据您的硬件连接选择）：
# - B16, B17, A15, A16, A13, A14, B18, A18, F13, F14,
#   B13, B14, D14, C14, B11, A11, E15, E16, D15, C15,
#   H16, G16, F15, F16, H14, G14, E17, D17, K13, J13,
#   H17, G17
set_property PACKAGE_PIN G17 [get_ports signal_in]
set_property IOSTANDARD LVCMOS33 [get_ports signal_in]

# ========================================
# 拨码开关 (SW0~SW7)
# ========================================
# 底部拨码开关组，用于控制DAC输出
set_property PACKAGE_PIN R1 [get_ports {sw[0]}]
set_property PACKAGE_PIN N4 [get_ports {sw[1]}]
set_property PACKAGE_PIN M4 [get_ports {sw[2]}]
set_property PACKAGE_PIN R2 [get_ports {sw[3]}]
set_property PACKAGE_PIN P2 [get_ports {sw[4]}]
set_property PACKAGE_PIN P3 [get_ports {sw[5]}]
set_property PACKAGE_PIN P4 [get_ports {sw[6]}]
set_property PACKAGE_PIN P5 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

# ========================================
# DAC0832控制信号
# ========================================
# DAC数据输出 DI7~DI0（使用DIP开关引脚或其他可用引脚）
# 这里使用DIP开关引脚作为DAC数据输出示例
# 实际使用时需要根据硬件连接确定
set_property PACKAGE_PIN T5 [get_ports {dac_data[0]}]
set_property PACKAGE_PIN T3 [get_ports {dac_data[1]}]
set_property PACKAGE_PIN R3 [get_ports {dac_data[2]}]
set_property PACKAGE_PIN V4 [get_ports {dac_data[3]}]
set_property PACKAGE_PIN V5 [get_ports {dac_data[4]}]
set_property PACKAGE_PIN V2 [get_ports {dac_data[5]}]
set_property PACKAGE_PIN U2 [get_ports {dac_data[6]}]
set_property PACKAGE_PIN U3 [get_ports {dac_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[*]}]

# DAC控制信号（使用可用引脚）
set_property PACKAGE_PIN M3 [get_ports dac_wr1]
set_property PACKAGE_PIN L6 [get_ports dac_wr2]
set_property PACKAGE_PIN N1 [get_ports dac_cs]
set_property IOSTANDARD LVCMOS33 [get_ports dac_wr1]
set_property IOSTANDARD LVCMOS33 [get_ports dac_wr2]
set_property IOSTANDARD LVCMOS33 [get_ports dac_cs]

# ========================================
# 数码管位选信号 (AN0~AN7)
# ========================================
# 位选信号（高有效）
set_property PACKAGE_PIN G2 [get_ports {an[0]}]
set_property PACKAGE_PIN C2 [get_ports {an[1]}]
set_property PACKAGE_PIN C1 [get_ports {an[2]}]
set_property PACKAGE_PIN H1 [get_ports {an[3]}]
set_property PACKAGE_PIN G1 [get_ports {an[4]}]
set_property PACKAGE_PIN F1 [get_ports {an[5]}]
set_property PACKAGE_PIN E1 [get_ports {an[6]}]
set_property PACKAGE_PIN G6 [get_ports {an[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

# ========================================
# 数码管段选信号 - 右侧组 (seg0, AN0-AN3)
# ========================================
# 段码映射: [7]=dp, [6]=a, [5]=b, [4]=c, [3]=d, [2]=e, [1]=f, [0]=g
# 硬件引脚: CA=B4, CB=A4, CC=A3, CD=B1, CE=A1, CF=B3, CG=B2, DP=D5
set_property PACKAGE_PIN D5 [get_ports {seg0[7]}]
set_property PACKAGE_PIN B4 [get_ports {seg0[6]}]
set_property PACKAGE_PIN A4 [get_ports {seg0[5]}]
set_property PACKAGE_PIN A3 [get_ports {seg0[4]}]
set_property PACKAGE_PIN B1 [get_ports {seg0[3]}]
set_property PACKAGE_PIN A1 [get_ports {seg0[2]}]
set_property PACKAGE_PIN B3 [get_ports {seg0[1]}]
set_property PACKAGE_PIN B2 [get_ports {seg0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg0[*]}]

# ========================================
# 数码管段选信号 - 左侧组 (seg1, AN4-AN7)
# ========================================
# 硬件引脚: CA=D4, CB=E3, CC=D3, CD=F4, CE=F3, CF=E2, CG=D2, DP=H2
set_property PACKAGE_PIN H2 [get_ports {seg1[7]}]
set_property PACKAGE_PIN D4 [get_ports {seg1[6]}]
set_property PACKAGE_PIN E3 [get_ports {seg1[5]}]
set_property PACKAGE_PIN D3 [get_ports {seg1[4]}]
set_property PACKAGE_PIN F4 [get_ports {seg1[3]}]
set_property PACKAGE_PIN F3 [get_ports {seg1[2]}]
set_property PACKAGE_PIN E2 [get_ports {seg1[1]}]
set_property PACKAGE_PIN D2 [get_ports {seg1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[*]}]

# ========================================
# LED指示灯 (LED0~LED3)
# ========================================
# 用于调试和状态指示
set_property PACKAGE_PIN K3 [get_ports {led[0]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN L1 [get_ports {led[2]}]
set_property PACKAGE_PIN K6 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# ========================================
# 其他约束
# ========================================
# 抑制未约束I/O的DRC警告
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# 时序约束
# 为生成的时钟添加约束（可选，增强时序分析）
# create_generated_clock -name clk_1Hz -source [get_ports clk] -divide_by 100000000 [get_pins u_clk_div/clk_1Hz_reg/Q]
# create_generated_clock -name clk_scan -source [get_ports clk] -divide_by 100000 [get_pins u_clk_div/clk_scan_reg/Q]
