----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - Keyboard_Interface
----------------------------------------------------------------------------------
-- Definitions:
---- CLK                       Master clock
---- PS2CLK                    Clock signal from PS/2 keyboard
---- PS2DATA                   Data signal from PS/2 keyboard
---- PS2Available              Available indicator signal of the PS2 interface
---- PS2Code                   Code output of the PS2 interaface
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Keyboard_Interface is
    Port ( 
        CLK : in std_logic;
        PS2CLK : in std_logic;
        PS2DATA : in std_logic;
        PS2Available : out std_logic;
        PS2Code : out std_logic_vector(7 downto 0));
end Keyboard_Interface;

architecture Behavioral of Keyboard_Interface is
signal synchronizer : std_logic_vector(1 downto 0);
signal PS2CLKDeb, PS2DATADeb  : std_logic;
signal ps2_word : std_logic_vector(10 downto 0);
signal error : std_logic;

component Keyboard_Debounce IS
    Generic(
        counter_size : integer := 19);
    Port(
        CLK : in  std_logic;
        deb_in : in  std_logic;  
        deb_out : out std_logic);
end component;
begin
    Keyboard_Debounce_PS2CLK: Keyboard_Debounce generic map(counter_size => 4) port map(CLK => CLK, deb_in => synchronizer(0), deb_out => PS2CLKDeb);
    Keyboard_Debounce_PS2DATA: Keyboard_Debounce generic map(counter_size => 4) port map(CLK => CLK, deb_in => synchronizer(1), deb_out => PS2DATADeb);

    process(CLK)
    begin
        if(rising_edge(CLK)) then
            synchronizer(0) <= PS2CLK; 
            synchronizer(1) <= PS2DATA;
        end if;
    end process;
    
    process(CLK)
    variable count : integer range 0 to 100000000/18000;
    begin
        if(rising_edge(CLK)) then
            if(PS2CLKDeb = '0') then
                count := 0;
            elsif(count /= 100000000/18000) then
                count := count + 1;
            end if;
        
            if(count = 100000000/18000 and error = '0') then 
                PS2Available <= '1'; 
                PS2CODE <= ps2_word(8 downto 1);
            else
                PS2Available <= '0';
            end if;
        end if;
    end process;

    process(PS2CLKDeb)
    begin
        if(falling_edge(PS2CLKDeb)) then
            ps2_word <= PS2DATADeb & ps2_word(10 downto 1);
        end if;
    end process;

  
    error <= not (not ps2_word(0) and ps2_word(10) and (ps2_word(9) xor ps2_word(8) xor
        ps2_word(7) xor ps2_word(6) xor ps2_word(5) xor ps2_word(4) xor ps2_word(3) xor 
        ps2_word(2) xor ps2_word(1)));  
end Behavioral;
