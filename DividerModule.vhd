library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DividerModule is
    port(
        clk     : in std_logic;
        enable  : in std_logic;
        sum     : in std_logic_vector(3 downto 0); -- Total sum
        count   : in std_logic_vector(3 downto 0); -- Count of nonzero values
        mean    : out std_logic_vector(3 downto 0); -- Computed mean
        div_done: out std_logic -- Signals when division is complete
    );
end entity;

architecture beh of DividerModule is
    signal mean_reg : unsigned(3 downto 0) := (others => '0'); -- Holds mean
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if count /= "0000" then -- Prevent division by zero
                    mean_reg <= unsigned(sum) / unsigned(count);
                else
                    mean_reg <= (others => '0'); -- Output 0 if count is 0
                end if;
                div_done <= '1'; -- Indicate division is complete
            else
                div_done <= '0';
            end if;
        end if;
    end process;

    -- Assign output
    mean <= std_logic_vector(mean_reg);
end beh;
