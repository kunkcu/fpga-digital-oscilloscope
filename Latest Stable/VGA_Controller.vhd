----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - VGA_Controller
----------------------------------------------------------------------------------
-- Definitions:
---- CLK                       Master clock
---- S1E, S2E                  CH1 & CH2 signal VGA display enable
---- data                      XADC 12Bit converted input
---- ready                     XADC ready state indicator input
---- S1F, S2F, S1V, S2V        CH1 & CH2 frequency and peak-to-peak voltage level inputs
---- VGA_R, VGA_G, VGA_B       RGB color output for VGA
---- VGA_HS, VGA_VS            Horizontal and vertivcal sync output for VGA
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.TermProjectLibrary.ALL;

entity VGA_Controller is
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
end VGA_Controller;

architecture Behavioral of VGA_Controller is
-------------------------- Components --------------------------
component VGA_Sync
    Port ( 
        CLK : in STD_LOGIC;
        bg_red, bg_green, bg_blue : in std_logic_vector(3 downto 0);
        CLK_OUT : out std_logic;
        H_PosOut, V_PosOut : out std_logic_vector(11 downto 0);
        VGA_HS, VGA_VS : out STD_LOGIC;
        VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR (3 downto 0));
end component;
----------------------------------------------------------------
--------------------------- Constants --------------------------
constant FRAME_WIDTH : natural := 1024;
constant FRAME_HEIGHT : natural := 768;
-- Frame Constants
constant xFrameLeft : natural := 50; 
constant xFrameRight : natural := 190;
constant yFrameTop : natural := 92;
constant yFrameBottom : natural := 46;
-- Static Constants
constant xFrameWidth : natural := (FRAME_WIDTH - xFrameLeft - xFrameRight) - (FRAME_WIDTH - xFrameLeft - xFrameRight) rem 70;
constant xFrameCenter : natural := xFrameLeft + (xFrameWidth / 2);
constant xFrameGrid : natural := xFrameWidth / 14;
constant yFrameHeight : natural := (FRAME_HEIGHT - yFrameTop - yFrameBottom) - (FRAME_HEIGHT - yFrameTop - yFrameBottom) rem 40;
constant yFrameCenter : natural := yFrameTop + (yFrameHeight / 2);
constant yFrameGrid : natural := yFrameHeight / 8;
----------------------------------------------------------------
--------------------------- Signals ----------------------------
signal pxl_clk : std_logic;
signal H_Pos, V_Pos : std_logic_vector(11 downto 0);
signal bg_red, bg_green, bg_blue :  std_logic_vector(3 downto 0);
signal S1Pk : integer := 0;
signal STMR : integer := 1;
----------------------------------------------------------------
--------------------------- Strings ----------------------------
signal CH1DivLabel, CH2DivLabel : String(1 to  5);
signal CH1DivValueLabel, CH2DivValueLabel, SecDivValueLabel : String(1 to  5);
signal RightTopLabel, ProbeLabel : String (1 to  7);
signal SecDivLabel, ProbeValue : String (1 to  3);
signal TriggerValue : String (1 to 4);
signal TriggerLabel : String (1 to 9);
----------------------------------------------------------------
----------------------------- RAM ------------------------------
type sRecord is array (0 to 769) of integer;
signal s1Record : sRecord;
----------------------------------------------------------------
begin
    VGA_Sync_Module: VGA_Sync port map(CLK => CLK, CLK_OUT => pxl_clk, bg_red => bg_red, bg_green => bg_green, bg_blue => bg_blue, H_PosOut => H_Pos, V_PosOut => V_Pos, VGA_HS => VGA_HS, VGA_VS => VGA_VS, VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B);

    -- Record signal
    process(CLK)
    variable count, count2, w : integer := 0;
    variable max : integer := -1000000000;
    variable min : integer := 1000000000;
    begin
        if (rising_edge(CLK)) then -- STM:2 ratio:2
            if (ready = '1') then   
                if (count < 770) then
                    if ((STM = 0 and count2 < 1 - 1) or (STM = 1 and count2 < 2 - 1) or (STM = 2 and count2 < 20 - 1) or
                    (STM = 3 and count2 < 200 - 1) or (STM = 4 and count2 < 400 - 1) or (STM = 5 and count2 < 1000 - 1) or
                    (STM = 6 and count2 < 2000 - 1) or (STM = 7 and count2 < 5000 - 1) or (STM = 8 and count2 < 10000 - 1)) then
                        count2 := count2 + 1;
                    else
                        count2 := 0;
                        
                        if (PM = '1') then
                            s1Record(count) <= data * 10;
                        else
                            s1Record(count) <= data;
                        end if;

                        count := count + 1;
                        
                        if (data > max) then
                            max := data;
                        end if;
                        
                        if (data < min) then
                            min := data;
                        end if;
                    end if;         
                elsif (count < 100000) then
                    count := count + 1;
                else
                    count := 0;
                    max := -1000000000;
                    min := 1000000000;
                    
                    S1Pk <= max - min;
                end if;
            end if;
        end if;
    end process;

    -- Frame Labels
    CH1DivLabel <= "<CH1>" when ModeSelect = 10 else " CH1 ";
    CH2DivLabel <= "<CH2>" when ModeSelect = 11 else " CH2 ";
    SecDivLabel <= "<M>" when ModeSelect = 20 else " M ";
    RightTopLabel <= "Setting" when ModeSelect = 30 else "Measure";
    ProbeLabel <= "<Probe>" when SettingSelect = 10 else " Probe ";
    TriggerLabel <= "<Trigger>" when SettingSelect = 11 else " Trigger ";
    
    -- Frame Values
    with S1VM select CH1DivValueLabel <=
        "20mV " when 0,
        "50mV " when 1,
        "100mV" when 2,
        "200mV" when 3,
        "500mV" when 4,
        "1V   " when 5,
        "2V   " when 6,
        "5V   " when 7,
        "10V  " when 8,
        "200mV" when others;
    with S2VM select CH2DivValueLabel <=
        "20mV " when 0,
        "50mV " when 1,
        "100mV" when 2,
        "200mV" when 3,
        "500mV" when 4,
        "1V   " when 5,
        "2V   " when 6,
        "5V   " when 7,
        "10V  " when 8,
        "200mV" when others;
    with STM select SecDivValueLabel <=
        "50us " when 0,
        "100us" when 1,
        "1ms  " when 2,
        "10ms " when 3,
        "20ms " when 4,
        "50ms " when 5,
        "100ms" when 6,
        "250ms" when 7,
        "500ms" when 8,
        "50us " when others;
        
    -- Ratios
    with STM select STMR <=
        1     when 0,
        2     when 1,
        20    when 2,
        200   when 3,
        400   when 4,
        1000  when 5,
        2000  when 6,
        5000  when 7,
        10000 when 8,
        1     when others;
        
    -- Setting Values
    ProbeValue <= "1 X" when PM = '0' else "10X";
    TriggerValue <= "Rise" when TM = '0' else "Fall";

    -- Draw screen
     process(pxl_clk)
     variable VoltageOne, VoltageTwo, FreqOne, FreqTwo : string(1 to 3) := "---";
     begin
     
         if (rising_edge(pxl_clk)) then
             -- Draw background
             bg_red <= "0000";
             bg_green <= "0000";
             bg_blue <= "0101";
             
             if (V_Pos < yFrameTop) then -- Top
                 if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft, 50, "Digital Oscilloscope (Experimental)", false, 2)) then
                     bg_red <= (others => '1');
                     bg_green <= (others => '1');
                     bg_blue <= (others => '1');
                 elsif (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft, 15, "Burak Kunkcu's", false, 2)) then
                     bg_red <= (others => '1');
                     bg_green <= (others => '1');
                     bg_blue <= (others => '1');
                 elsif (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), 66, RightTopLabel, true, 2)) then
                     bg_red <= (others => '1');
                     bg_green <= (others => '1');
                     bg_blue <= (others => '1');
                 end if;
             elsif (V_Pos >= yFrameTop and V_Pos <= yFrameTop + yFrameHeight) then -- Middle
                 if (H_Pos >= xFrameLeft and H_Pos <= xFrameLeft + xFrameWidth) then -- Middle in/on Frame
                     if (V_Pos = yFrameTop or V_Pos = yFrameTop + yFrameHeight or H_Pos = xFrameLeft or H_Pos = xFrameLeft + xFrameWidth) then -- Middle on Frame
                         -- Draw white borders
                         bg_red <= (others => '1');
                         bg_green <= (others => '1');
                         bg_blue <= (others => '1');
                     else -- Middle in Frame
                         if (S1E = '1' and ((S1VM = 0 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 20)) or
                         (S1VM = 1 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 50)) or
                         (S1VM = 2 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 100)) or
                         (S1VM = 3 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 200)) or
                         (S1VM = 4 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 500)) or
                         (S1VM = 5 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 1000)) or
                         (S1VM = 6 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 2000)) or
                         (S1VM = 7 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 5000)) or
                         (S1VM = 8 and yFrameCenter - conv_integer(V_Pos) = s1Record(conv_integer(H_Pos) - xFrameLeft) * 78 / (1000 * 10000)) )) then -- 78/1000 from Screen/Volt 
                             -- Draw CH1 signal
                             bg_red <= "1110";
                             bg_green <= "1101";
                             bg_blue <= "0100";
                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and ((conv_integer(V_Pos) - yFrameTop) rem yFrameGrid = 0)) or (((conv_integer(H_Pos) - xFrameLeft) rem xFrameGrid = 0) and ((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0))) then
                             -- Draw reference points
                             bg_red <= (others => '1');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '1');                                                                 
                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and (V_Pos < yFrameTop + 8 or V_Pos > yFrameTop + yFrameHeight - 8)) or (((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0) and (H_Pos < xFrameLeft + 6 or H_Pos > xFrameLeft + xFrameWidth - 6))) then
                             -- Draw reference lines
                             bg_red <= (others => '1');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '1');                         
                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and (V_Pos < (yFrameCenter + 4) and V_Pos > (yFrameCenter - 4))) or (((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0) and (H_Pos < (xFrameCenter + 3) and H_Pos > (xFrameCenter - 3)))) then
                             -- Draw reference lines - Center
                             bg_red <= (others => '1');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '1');
                         else
                             -- Draw black bakground
                             bg_red <= (others => '0');
                             bg_green <= (others => '0');
                             bg_blue <= (others => '0');
                         end if;
                     end if;
                 else -- Middle on/in Left Right Bars
                     if (((conv_integer(V_Pos) - yFrameTop) rem (2 * yFrameGrid) = 0) and H_Pos > xFrameLeft + xFrameWidth + 20 and H_Pos < FRAME_WIDTH - 20) then
                         bg_red <= (others => '1');
                         bg_green <= (others => '1');
                         bg_blue <= (others => '1');
                     else
                         if (ModeSelect = 30) then
                             if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 1 * ((yFrameHeight - 24 * 8) / 16) + 1 * 8, ProbeLabel, true, 2) or 
                                 draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 3 * ((yFrameHeight - 24 * 8) / 16) + 5 * 8, ProbeValue, true, 2) or 
                                 draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 5 * ((yFrameHeight - 24 * 8) / 16) + 7 * 8, TriggerLabel, true, 2) or       
                                 draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 7 * ((yFrameHeight - 24 * 8) / 16) + 11 * 8, TriggerValue, true, 2)) then
                                     bg_red <= (others => '1');
                                     bg_green <= (others => '1');
                                     bg_blue <= (others => '1');
                             end if;
                         else
                             if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 1 * ((yFrameHeight - 24 * 8) / 16) + 1 * 8, "CH1", true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 2 * ((yFrameHeight - 24 * 8) / 16) + 3 * 8, "Pk-Pk", true, 2) or
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 3 * ((yFrameHeight - 24 * 8) / 16) + 5 * 8, VoltageOne, true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 5 * ((yFrameHeight - 24 * 8) / 16) + 7 * 8, "CH1", true, 2) or       
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 6 * ((yFrameHeight - 24 * 8) / 16) + 9 * 8, "Freq", true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 7 * ((yFrameHeight - 24 * 8) / 16) + 11 * 8, FreqOne, true, 2)) then
                                 bg_red <= "1110";
                                 bg_green <= "1101";
                                 bg_blue <= "0100";
                             elsif (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 9 * ((yFrameHeight - 24 * 8) / 16) + 13 * 8, "CH2", true, 2) or
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 10 * ((yFrameHeight - 24 * 8) / 16) + 15 * 8, "Pk-Pk", true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 11 * ((yFrameHeight - 24 * 8) / 16) + 17 * 8, VoltageTwo, true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 13 * ((yFrameHeight - 24 * 8) / 16) + 19 * 8, "CH2", true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 14 * ((yFrameHeight - 24 * 8) / 16) + 21 * 8, "Freq", true, 2) or 
                             draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth + (xFrameRight/2), yFrameTop + 15 * ((yFrameHeight - 24 * 8) / 16) + 23 * 8, FreqTwo, true, 2)) then
                                 bg_red <= "0001";
                                 bg_green <= "1001";
                                 bg_blue <= "1111";
                             end if;
                         end if;
                     end if;
                 end if;
             elsif (V_Pos > yFrameTop + yFrameHeight) then -- Bottom
                 if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft, yFrameTop + yFrameHeight + 16, CH1DivLabel & ": " & CH1DivValueLabel, false, 2)) then
                     bg_red <= "1110";
                     bg_green <= "1101";
                     bg_blue <= "0100";           
                 elsif (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + xFrameWidth / 3, yFrameTop + yFrameHeight + 16, CH2DivLabel & ": " & CH2DivValueLabel, false, 2)) then
                     bg_red <= "0001";
                     bg_green <= "1001";
                     bg_blue <= "1111";
                 elsif (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameLeft + 2 * xFrameWidth / 3, yFrameTop + yFrameHeight + 16, SecDivLabel & ": " & SecDivValueLabel, false, 2)) then
                     bg_red <= (others => '1');
                     bg_green <= (others => '1');
                     bg_blue <= (others => '1');
                 end if;
             end if;
         end if;
     end process;
end Behavioral;
