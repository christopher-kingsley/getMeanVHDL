library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myCounterModule is
    port(
        clk         : in std_logic;
        reset       : in std_logic;
        enable      : in std_logic;
        dataIn      : in std_logic_vector(3 downto 0); -- Data read from RAM
        address     : out std_logic_vector(2 downto 0); -- Current RAM address
        count       : out std_logic_vector(3 downto 0); -- Count of nonzero values
        counter_done: out std_logic -- Signals when all addresses have been checked
    );
end entity;

architecture beh of myCounterModule is
    signal addr_reg : unsigned(2 downto 0) := (others => '0'); -- Address tracker (3 bits)
    signal count_reg : unsigned(3 downto 0) := (others => '0'); -- Nonzero counter
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset address and count
                addr_reg <= (others => '0');
                count_reg <= (others => '0');
                counter_done <= '0';
            elsif enable = '1' then
                if addr_reg < "111" then -- Max address is 7 (3 bits)
                    -- Increment address
                    addr_reg <= addr_reg + 1;
                    
                    -- Count only if dataIn is greater than 0
                    if dataIn /= "0000" then
                        count_reg <= count_reg + 1;
                    end if;
                    
                    -- Not done yet
                    counter_done <= '0';
                else
                    -- Finished counting all addresses
                    addr_reg <= "000"; -- Reset address to 0 if needed
                    counter_done <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Assign output signals
    address <= std_logic_vector(addr_reg); -- Output current address
    count   <= std_logic_vector(count_reg); -- Output nonzero count
end beh;