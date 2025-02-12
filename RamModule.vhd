library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RamModule is 
    port(
        clk      : in std_logic;
        rw       : in std_logic;  -- 0 = Write, 1 = Read
        address  : in std_logic_vector(2 downto 0); -- 5-bit address (0-31)
        dataIn   : in std_logic_vector(3 downto 0); -- 4-bit data input
        dataOut  : out std_logic_vector(3 downto 0) -- 4-bit data output
    );
end entity;

architecture beh of RamModule is
    -- Define a 32x4 RAM
    type mem is array(0 to 7) of std_logic_vector(3 downto 0);
    signal memoryArray : mem := (others => (others => '0'));  -- Initialize to 0

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rw = '0' then
                -- Write data to memory
                memoryArray(to_integer(unsigned(address))) <= dataIn;
            elsif rw = '1' then
                -- Read data from memory
                dataOut <= memoryArray(to_integer(unsigned(address)));
            else
                -- Default to 0 if not reading/writing
                dataOut <= (others => '0');
            end if;
        end if;
    end process;
end beh;
