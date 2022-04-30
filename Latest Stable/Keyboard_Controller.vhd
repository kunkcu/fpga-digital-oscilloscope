----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - Keyboard_Controller
----------------------------------------------------------------------------------
-- Definitions:
---- CLK                       Master clock
---- PS2CLK                    Clock signal from PS/2 keyboard
---- PS2DATA                   Data signal from PS/2 keyboard
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Keyboard_Controller is
    Port ( 
        CLK : in std_logic;
        PS2CLK : in std_logic;
        PS2DATA : in std_logic;
        ModeOut, SettingOut, S1VM, S2VM, STM : out integer;
        PM, TM : out std_logic);
end Keyboard_Controller;

architecture Behavioral of Keyboard_Controller is
component Keyboard_Interface is
    Port (
        CLK : in std_logic;
        PS2CLK : in std_logic;
        PS2DATA : in std_logic;
        PS2Available : out std_logic;
        PS2Code : out std_logic_vector(7 downto 0));
end component;

signal PS2Available : std_Logic;
signal PS2Code : std_Logic_vector(7 downto 0);
signal Mode, SettingMode : integer := 0;
signal S1VMTemp, S2VMTemp, STMTemp : integer := 3;
signal PMTemp, TMTemp : std_logic := '0';
begin
    Keyboard_Interface_Module : Keyboard_Interface port map(CLK => CLK, PS2CLK => PS2CLK, PS2DATA => PS2DATA, PS2Available => PS2Available, PS2Code => PS2Code);
    
    process(clk)
    variable lastCode : std_logic_vector(7 downto 0);
    variable count : integer := 0; 
    begin
        if (rising_edge(clk)) then
            if (PS2Available = '1') then            
                if (PS2Code = "00011010" and lastCode /= PS2Code) then -- Key: Z Hex: 1A 
                    lastCode := PS2Code;
                    
                    count := count + 1;
                    if (count = 2) then
                        mode <= 10; -- CH1 Volt/Div
                        count := 0;
                    end if;
                elsif (PS2Code = "00100010" and lastCode /= PS2Code) then -- Key: X Hex: 22
                    lastCode := PS2Code;
                    
                    count := count + 1;
                    if (count = 2) then
                        mode <= 11; -- CH2 Volt/Div
                        count := 0;
                    end if;
                elsif (PS2Code = "00100001" and lastCode /= PS2Code) then -- Key: C Hex: 21
                    lastCode := PS2Code;

                    count := count + 1;
                    if (count = 2) then
                        mode <= 20; -- Sec/Div
                        count := 0;
                    end if;
                elsif (PS2Code = "00101010" and lastCode /= PS2Code) then -- Key: V Hex: 2A
                    lastCode := PS2Code;
    
                    count := count + 1;
                    if (count = 2) then
                        mode <= 30; -- Settings
                        SettingMode <= 10;
                        count := 0;
                end if;
                elsif (PS2Code = "00011101" and lastCode /= PS2Code) then -- Key : W Hex: 1D
                    lastCode := PS2Code;
                    
                    count := count + 1;
                    if (count = 2) then
                        if (mode = 10 and S1VMTemp < 8) then
                            S1VMTemp <= S1VMTemp + 1;
                        elsif (mode = 11 and S2VMTemp < 8) then
                            S2VMTemp <= S2VMTemp + 1;
                        elsif (mode = 20 and STMTemp < 8) then
                            STMTemp <= STMTemp + 1;
                        elsif (mode = 30 and SettingMode = 11) then
                            SettingMode <= 10;
                        end if;
                        
                        count := 0;
                    end if;
                elsif (PS2Code = "00011011" and lastCode /= PS2Code) then -- Key : S Hex: 1B
                    lastCode := PS2Code;
                    
                    count := count + 1;
                    if (count = 2) then
                        if (mode = 10 and S1VMTemp > 0) then
                            S1VMTemp <= S1VMTemp - 1;
                        elsif (mode = 11 and S2VMTemp > 0) then
                            S2VMTemp <= S2VMTemp - 1;
                        elsif (mode = 20 and STMTemp > 0) then
                            STMTemp <= STMTemp - 1;
                        elsif (mode = 30 and SettingMode = 10) then
                            SettingMode <= 11;
                        end if;
                        
                        count := 0;
                    end if;
                elsif ((PS2Code = "00011100" or PS2Code = "00100011") and lastCode /= PS2Code) then -- Key : A Hex: 1C or Key : D Hex: 23
                    lastCode := PS2Code;
                    
                    count := count + 1;
                    if (count = 2) then
                        if (SettingMode = 10 and mode = 30) then
                            PMTemp <= not PMTemp;
                        elsif (SettingMode = 11 and mode = 30) then
                            TMTemp <= not TMTemp;
                        end if;
                        
                        count := 0;
                    end if;    
                elsif (PS2Code = "11110000") then -- Key Release Hex: F0
                    lastCode := "00000000";
                end if;
            end if;
        end if;
    end process;
    
    ModeOut <= Mode;
    SettingOut <= SettingMode;
    S1VM <= S1VMTemp;
    S2VM <= S2VMTemp;
    STM <= STMTemp;
    PM <= PMTemp;
    TM <= TMTemp;
end Behavioral;
