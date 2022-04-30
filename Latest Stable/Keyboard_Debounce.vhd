----------------------------------------------------------------------------------
-- Burak Kunkcu
-- Term Project - Keyboard_Debounce
----------------------------------------------------------------------------------
-- Definitions:
---- CLK                       Master clock
---- deb_in                    In signal
---- deb_out                   Out signal
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Keyboard_Debounce IS
    Generic(
        counter_size : integer := 19);
    Port(
        CLK : in  std_logic;
        deb_in : in  std_logic;  
        deb_out : out std_logic);
end Keyboard_Debounce;

architecture Behavioral OF Keyboard_Debounce IS
signal ff   : std_logic_vector(1 downto 0);
signal counter_set : std_logic;
signal counter_out : std_logic_vector(counter_size downto 0) := (others => '0');
begin

  counter_set <= ff(0) xor ff(1);
  
  process(CLK)
    begin
        if(rising_edge(CLK)) then
            ff(0) <= deb_in;
            ff(1) <= ff(0);
        
            if(counter_set = '1') then
                counter_out <= (others => '0');
            elsif(counter_out(counter_size) = '0') then 
                counter_out <= counter_out + 1;
            else
                deb_out <= ff(1);
            end if;    
        end if;
    end process;
end Behavioral;
