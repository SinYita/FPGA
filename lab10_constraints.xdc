# ============================================================
# Constraints for Exercise Lab 10: LED Bouncing Pattern
# Target Board: PYNQ-Z2 or similar Xilinx FPGA board
# ============================================================

# CLK source 125 MHz
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -period 8.000 -name sys_clk_pin -waveform {0 4} -add [get_ports {clk}]

# Reset button (active low)
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {rst_n}]

# BTN0 - mode toggle (Mode A/B)
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btn0}]
# BTN1 - speed toggle (1s/3s)
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btn1}]

# LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {leds[3]}]
