----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - Main (Top Module)
----------------------------------------------------------------------------------
-- Definitions:
---- S1E, S2E                  CH1 & CH2 signal VGA display enable
---- SLE                       CH1 signal LED display enable
---- S1P, S2P                  CH1 & CH2 active reference input required for XADC
---- S1N, S2N                  CH1 & CH2 ground reference input required for XADC
---- PS2CLK                    Clock signal from PS/2 keyboard
---- PS2DATA                   Data signal from PS/2 keyboard
---- LED                       LED output
---- VGA_R, VGA_G, VGA_B       RGB color output for VGA
---- VGA_HS, VGA_VS            Horizontal and vertivcal sync output for VGA 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Main is
    Port (
        S1E, S2E, SLE : in std_logic;
        CLK : in  std_logic;
        S1P, S1N, S2P, S2N : in std_logic;
        PS2CLK : in std_logic;
        PS2DATA : in std_logic;
        LED : out std_logic_vector(15 downto 0);
        VGA_R, VGA_G, VGA_B : out  std_logic_vector (3 downto 0);
        VGA_HS, VGA_VS : out  std_logic);
end Main;

architecture Behavioral of Main is
-------------------------- Components --------------------------
component XADC_Controller is
    Port ( 
        CLK, S1P, S1N, S2P, S2N, SLE : in std_logic;
        dataOut : out integer;
        readyOut : out std_logic;
        LED : out std_logic_vector(15 downto 0));
end component;
component VGA_Controller is
    Port ( 
        CLK : in std_logic;
        ModeSelect, SettingSelect : in integer;
        S1E, S2E : in std_logic;
        S1VM, S2VM, STM : in integer;
        PM, TM : in std_logic;
        data : in integer;
        ready : in std_logic;
        VGA_HS, VGA_VS : out std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector (3 downto 0));
end component;
component Keyboard_Controller is
    Port ( 
        CLK : in std_logic;
        PS2CLK : in std_logic;
        PS2DATA : in std_logic;
        ModeOut, SettingOut, S1VM, S2VM, STM : out integer;
        PM, TM : out std_logic);
end component;
----------------------------------------------------------------
--------------------------- Signals ----------------------------
signal dataTemp, S1VMTemp, S2VMTemp, STMTemp : integer;
signal readyTemp : std_logic;
signal PMTemp, TMTemp : std_logic;
signal ModeTemp, SettingTemp : integer;
----------------------------------------------------------------
begin
    XADC_ControllerModule : XADC_Controller port map(CLK => CLK, SLE => SLE, S1P => S1P,
        S1N => S1N, S2P => S2P, S2N => S2N, dataOut => dataTemp, readyOut => readyTemp, LED => LED);
    
    VGA_Controller_Module : VGA_Controller port map(CLK => CLK, ModeSelect => ModeTemp,
        S1E => S1E, S2E => S2E, S1VM => S1VMTemp, S2VM => S2VMTemp, STM => STMTemp, 
        PM => PMTemp, TM => TMTemp, data => dataTemp, ready => readyTemp, VGA_HS => VGA_HS, 
        VGA_VS => VGA_VS, VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B, SettingSelect => SettingTemp);

    Keyboard_Controller_Module : Keyboard_Controller port map(CLK => CLK, PS2CLK => PS2CLK, PS2DATA => PS2DATA,
         ModeOut => ModeTemp, S1VM => S1VMTemp, S2VM => S2VMTemp, STM => STMTemp, PM => PMTemp, TM => TMTemp, 
         SettingOut => SettingTemp);
end Behavioral;
