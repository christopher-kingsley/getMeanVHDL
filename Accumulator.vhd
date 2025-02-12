library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator is
    port(
        clk     : in std_logic;
        reset   : in std_logic;  -- Reset signal
        enable  : in std_logic;  -- Enables accumulation
        dataIn  : in std_logic_vector(3 downto 0); -- Current value from RAM
        prevSum : in std_logic_vector(3 downto 0); -- Previous sum (feedback)
        sum     : out std_logic_vector(3 downto 0) -- Accumulated sum (4-bit output)
    );
end entity;

architecture beh of Accumulator is
    signal sum_reg : unsigned(3 downto 0) := (others => '0'); -- Holds sum (4-bit)
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset sum
                sum_reg <= (others => '0');
            elsif enable = '1' then
                -- Add incoming data to previous sum (remains 4-bit)
                sum_reg <= unsigned(dataIn) + unsigned(prevSum);
            end if;
        end if;
    end process;

    -- Assign output
    sum <= std_logic_vector(sum_reg);
end beh;
