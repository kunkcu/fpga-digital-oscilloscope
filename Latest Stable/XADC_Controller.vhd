----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - XADC_Controller
----------------------------------------------------------------------------------
-- Definitions:
---- CLK                       Master clock
---- S1P, S2P                  CH1 & CH2 active reference input required for XADC
---- S1N, S2N                  CH1 & CH2 ground reference input required for XADC
---- SLE                       CH1 signal LED display enable
---- dataOut                   XADC 12Bit converted output
---- readyOut                  XADC ready state indicator output
---- S1F, S2F, S1V, S2V        CH1 & CH2 frequency and peak-to-peak voltage level outputs
---- LED                       LED output
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TermProjectLibrary.all;

entity XADC_Controller is
    Port ( 
        CLK, S1P, S1N, S2P, S2N, SLE : in std_logic;
        dataOut : out integer;
        readyOut : out std_logic;
        LED : out std_logic_vector(15 downto 0));
end XADC_Controller;

architecture Behavioral of XADC_Controller is
-------------------------- Components --------------------------
component xadc_wiz_0 is
   port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    vauxp6          : in  STD_LOGIC;                         -- Auxiliary Channel 6
    vauxn6          : in  STD_LOGIC;
    vauxp14          : in  STD_LOGIC;                         -- Auxiliary Channel 14
    vauxn14          : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end component;
----------------------------------------------------------------
--------------------------- Signals ----------------------------
signal enable, ready : std_logic;
signal data : std_logic_vector(15 downto 0);
signal DDADDR : std_Logic_vector(6 downto 0);
----------------------------------------------------------------
------------------------ Dummy Signals -------------------------
signal di_in_dummy : std_logic_vector (15 downto 0);
signal dwe_in_dummy : std_logic;
----------------------------------------------------------------
begin
    XADC : xadc_wiz_0 port map(daddr_in => DDADDR, den_in => enable, di_in => di_in_dummy, eos_out => open, 
        dwe_in => dwe_in_dummy, busy_out => open, channel_out => open, alarm_out => open, vp_in => '0', 
        vn_in => '0', dclk_in => clk, vauxp6 => S1P, vauxn6 => S1N, vauxp14 => S2P, vauxn14 => S2N,
        do_out => data, eoc_out => enable, drdy_out => ready);
        
    DDADDR <= "0010110"; -- Channel One
    -- DDADDR <= "0010110"; -- Channel Two
    
    readyOut <= ready;

--    -- Frequency Measurement
--    process(clk)
--    variable i1, i2, catch : integer := 0;
--    variable count : integer := 0;
--    variable enable : std_logic := '0';
--    begin
--        if (rising_edge(clk)) then
--            if (ready = '1' and enable = '0') then
--                if (to_integer(signed(data)) = 0 and catch = 0) then
--                    i1 := count; 
--                    catch := 1;
--                elsif (to_integer(signed(data)) = 0 and catch = 1) then
--                    i2 := count;
--                    catch := 0;
                    
--                    S1F <= (i2 - i1) * 2; -- According to the 100MHz master clock
--                    enable := '1';
--                end if;
                
--                count := count + 1;
--            end if;
--        end if;
--    end process;
        
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (ready = '1') then
                dataOut <= 244 * to_integer(signed(data(15 downto 4)));
            
                if (SLE = '1') then
                    if data(15) = '0' then
                        case data(14 downto 12) is
                            when "000" => led <= "0000000100000000";
                            when "001" => led <= "0000001100000000";
                            when "010" => led <= "0000011100000000";
                            when "011" => led <= "0000111100000000";
                            when "100" => led <= "0001111100000000";
                            when "101" => led <= "0011111100000000";
                            when "110" => led <= "0111111100000000";
                            when "111" => led <= "1111111100000000";
                            when others => led <= "0000000000000000";
                        end case;
                        
                    elsif data(15) = '1' then
                         case data(14 downto 12) is
                               when "000" => led <= "0000000011111111";
                               when "001" => led <= "0000000011111110";
                               when "010" => led <= "0000000011111100";
                               when "011" => led <= "0000000011111000";
                               when "100" => led <= "0000000011110000";
                               when "101" => led <= "0000000011100000";
                               when "110" => led <= "0000000011000000";
                               when "111" => led <= "0000000010000000";
                               when others => led <= "0000000000000000";
                           end case;
                    end if;
                else
                    led <= "0000000000000000";
                end if;
            end if;
        end if;
    end process;
end Behavioral;
