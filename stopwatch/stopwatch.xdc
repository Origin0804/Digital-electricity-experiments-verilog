# Stopwatch Constraints File for EGO1 FPGA Board

# Clock - 100MHz
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN P17 [get_ports clk]

# Reset S0 (active high)
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN R15 [get_ports rst]

# Start S1
set_property IOSTANDARD LVCMOS33 [get_ports start]
set_property PACKAGE_PIN U4 [get_ports start]

# Stop S2
set_property IOSTANDARD LVCMOS33 [get_ports stop]
set_property PACKAGE_PIN V1 [get_ports stop]

# Set Minute S3
set_property IOSTANDARD LVCMOS33 [get_ports set_min]
set_property PACKAGE_PIN R11 [get_ports set_min]

# Set Hour S4
set_property IOSTANDARD LVCMOS33 [get_ports set_hour]
set_property PACKAGE_PIN R17 [get_ports set_hour]

# Countdown Mode Switch SW7
set_property IOSTANDARD LVCMOS33 [get_ports countdown_sw]
set_property PACKAGE_PIN P5 [get_ports countdown_sw]

# Digit Select (wei) - Active High
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {wei[0]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {wei[1]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {wei[2]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {wei[3]}]

# Left bank segments (duan) - for hh-mm display
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {duan[7]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {duan[6]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {duan[5]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {duan[4]}]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports {duan[3]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {duan[2]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {duan[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {duan[0]}]

# Right bank segments (duan1) - for ss-xx display
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {duan1[7]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {duan1[6]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {duan1[5]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {duan1[4]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {duan1[3]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {duan1[2]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {duan1[1]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {duan1[0]}]

# Suppress DRC warnings
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
