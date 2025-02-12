library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clockdivider is
    port(
        clk         : in std_logic;
        Clock   : out std_logic;
        led        : out std_logic
    );
end entity;

architecture behavioral of clockdivider is
    signal cnt : unsigned(24 downto 0) := (others => '0');
    signal Clock_sig : std_logic := '0'; -- Initialize slowClock_sig

begin
    process
    begin
        wait until rising_edge(clk);
        
        cnt <= cnt + 1;

        Clock <= cnt(24);
     
        Clock_sig <= cnt(24);
        
        if (Clock_sig = '1') then
            led <= '1';
        else
            led <= '0';
        end if;
    end process;
end behavioral;