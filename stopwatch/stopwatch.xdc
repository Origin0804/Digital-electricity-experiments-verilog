# Constraint file for Digital Stopwatch on EGO1 FPGA Board

# Clock - 100MHz
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN P17 [get_ports clk]

# Control Buttons
# S0 - Reset (R15)
set_property IOSTANDARD LVCMOS33 [get_ports s0]
set_property PACKAGE_PIN R15 [get_ports s0]

# S1 - Start (U4)
set_property IOSTANDARD LVCMOS33 [get_ports s1]
set_property PACKAGE_PIN U4 [get_ports s1]

# S2 - Stop (V1)
set_property IOSTANDARD LVCMOS33 [get_ports s2]
set_property PACKAGE_PIN V1 [get_ports s2]

# S3 - Minute Increment (R11)
set_property IOSTANDARD LVCMOS33 [get_ports s3]
set_property PACKAGE_PIN R11 [get_ports s3]

# S4 - Hour Increment (R17)
set_property IOSTANDARD LVCMOS33 [get_ports s4]
set_property PACKAGE_PIN R17 [get_ports s4]

# SW7 - Countdown Mode Enable (P5)
set_property IOSTANDARD LVCMOS33 [get_ports sw7]
set_property PACKAGE_PIN P5 [get_ports sw7]

# 7-Segment Display - Digit Select (wei)
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {wei[0]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {wei[1]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {wei[2]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {wei[3]}]

# 7-Segment Display - Segment Data Bank 1 (duan)
# Bit order: [7]=dp, [6]=a, [5]=b, [4]=c, [3]=d, [2]=e, [1]=f, [0]=g
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {duan[7]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {duan[6]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {duan[5]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {duan[4]}]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports {duan[3]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {duan[2]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {duan[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {duan[0]}]

# 7-Segment Display - Segment Data Bank 2 (duan1)
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {duan1[7]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {duan1[6]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {duan1[5]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {duan1[4]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {duan1[3]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {duan1[2]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {duan1[1]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {duan1[0]}]

# Suppress DRC warnings for unconstrained/unspecified I/O
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
