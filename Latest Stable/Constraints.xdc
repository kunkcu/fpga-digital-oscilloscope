## System Clock
set_property PACKAGE_PIN W5 [get_ports CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
    create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK]

## Pmod Header JXADC
set_property PACKAGE_PIN J3 [get_ports {S1P}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {S1P}]
set_property PACKAGE_PIN K3 [get_ports {S1N}]				
    set_property IOSTANDARD LVCMOS33 [get_ports {S1N}]
set_property PACKAGE_PIN L3 [get_ports {S2P}]				
    set_property IOSTANDARD LVCMOS33 [get_ports {S2P}]     
set_property PACKAGE_PIN M3 [get_ports {S2N}]				
    set_property IOSTANDARD LVCMOS33 [get_ports {S2N}]
        
## LEDs
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]

## VGA Connector
set_property PACKAGE_PIN G19 [get_ports {VGA_R[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[0]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_R[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[1]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_R[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[2]}]
set_property PACKAGE_PIN N19 [get_ports {VGA_R[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[3]}]
set_property PACKAGE_PIN J17 [get_ports {VGA_G[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[0]}]
set_property PACKAGE_PIN H17 [get_ports {VGA_G[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[1]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_G[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[2]}]
set_property PACKAGE_PIN D17 [get_ports {VGA_G[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[3]}]
set_property PACKAGE_PIN N18 [get_ports {VGA_B[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[0]}]
set_property PACKAGE_PIN L18 [get_ports {VGA_B[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[1]}]
set_property PACKAGE_PIN K18 [get_ports {VGA_B[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[2]}]
set_property PACKAGE_PIN J18 [get_ports {VGA_B[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[3]}]
set_property PACKAGE_PIN P19 [get_ports VGA_HS]
    set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property PACKAGE_PIN R19 [get_ports VGA_VS]
    set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]
    
## Switches
set_property PACKAGE_PIN R2 [get_ports S1E]
    set_property IOSTANDARD LVCMOS33 [get_ports S1E]
set_property PACKAGE_PIN T1 [get_ports S2E]
    set_property IOSTANDARD LVCMOS33 [get_ports S2E]
set_property PACKAGE_PIN V17 [get_ports SLE]
    set_property IOSTANDARD LVCMOS33 [get_ports SLE]
        
## USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports PS2CLK]                        
    set_property IOSTANDARD LVCMOS33 [get_ports PS2CLK]
    set_property PULLUP true [get_ports PS2CLK]
set_property PACKAGE_PIN B17 [get_ports PS2DATA]                    
    set_property IOSTANDARD LVCMOS33 [get_ports PS2DATA]    
    set_property PULLUP true [get_ports PS2DATA]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]












