# Stopwatch Constraint File for EGO1 FPGA Board
# Display format: hh-mm-ss-xx (Hours, Minutes, Seconds, Centiseconds)

# System Clock (100MHz)
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN P17 [get_ports clk]

# Button S0 (Reset) - Center button
set_property IOSTANDARD LVCMOS33 [get_ports s0_reset]
set_property PACKAGE_PIN R15 [get_ports s0_reset]

# Button S1 (Start) - Up button
set_property IOSTANDARD LVCMOS33 [get_ports s1_start]
set_property PACKAGE_PIN U4 [get_ports s1_start]

# Button S2 (Stop) - Left button
set_property IOSTANDARD LVCMOS33 [get_ports s2_stop]
set_property PACKAGE_PIN V1 [get_ports s2_stop]

# Button S3 (Set Minutes in countdown mode) - Down button
set_property IOSTANDARD LVCMOS33 [get_ports s3_set_min]
set_property PACKAGE_PIN R11 [get_ports s3_set_min]

# Button S4 (Set Hours in countdown mode) - Right button
set_property IOSTANDARD LVCMOS33 [get_ports s4_set_hour]
set_property PACKAGE_PIN R17 [get_ports s4_set_hour]

# SW7 (Countdown Mode) - Slide Switch
set_property IOSTANDARD LVCMOS33 [get_ports sw7_countdown]
set_property PACKAGE_PIN P5 [get_ports sw7_countdown]

# Digit Select (wei) - Active high
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {wei[0]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {wei[1]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {wei[2]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {wei[3]}]

# Segment Data for Right Display Block (duan)
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {duan[0]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {duan[1]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {duan[2]}]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports {duan[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {duan[4]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {duan[5]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {duan[6]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {duan[7]}]

# Segment Data for Left Display Block (duan1)
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {duan1[0]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {duan1[1]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {duan1[2]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {duan1[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {duan1[4]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {duan1[5]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {duan1[6]}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {duan1[7]}]

# Suppress DRC warnings
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
