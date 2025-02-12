library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MultiplierModule is
    Port (
        clk        : in std_logic;
        reset      : in std_logic;
        start      : in std_logic;  -- FSM Start signal
        actualCount: in std_logic_vector(3 downto 0);  -- 4-bit value from RAM
        count      : in std_logic_vector(3 downto 0);  -- 4-bit total count from Counter Module
        total      : out std_logic_vector(7 downto 0); -- 7-bit product output
        done       : out std_logic  -- Signals FSM when finished
    );
end entity;

architecture Behavioral of MultiplierModule is
    signal actualCount_unsigned : unsigned(3 downto 0);
    signal indexOffset          : unsigned(3 downto 0); -- Tracks 0, 1, 2, ... until count
    signal count_unsigned       : unsigned(3 downto 0);
    signal product_result       : unsigned(7 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            indexOffset <= (others => '0'); -- Reset to 0
            done <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
                if indexOffset < count_unsigned then
                    product_result <= actualCount_unsigned * indexOffset;
                    indexOffset <= indexOffset + 1; -- Increment indexOffset
                    done <= '0'; -- Still processing
                else
                    done <= '1'; -- Done when indexOffset == count
                end if;
            else
                done <= '0'; -- Reset done when not running
            end if;
        end if;
    end process;

    -- Convert inputs to unsigned
    actualCount_unsigned <= unsigned(actualCount);
    count_unsigned <= unsigned(count);

    -- Assign outputs
    total <= std_logic_vector(product_result);
end Behavioral;
