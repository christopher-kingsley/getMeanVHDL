library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TotalRegister is
    port (
        clk   : in  std_logic;                          -- Clock signal
        reset : in  std_logic;                          -- Reset signal (active high)
        load  : in  std_logic;                          -- Load enable signal
        data_in : in  std_logic_vector(3 downto 0);    -- Input data to load into the register
        data_out : out std_logic_vector(3 downto 0)    -- Output data from the register
    );
end entity;

architecture beh of TotalRegister is
    signal reg_value : std_logic_vector(3 downto 0) := (others => '0'); -- Internal register
begin

    process(clk, reset)
    begin
        if reset = '1' then
            reg_value <= (others => '0'); -- Reset register to zero
        elsif rising_edge(clk) then
            if load = '1' then
                reg_value <= data_in; -- Load new data when enabled
            end if;
        end if;
    end process;

    data_out <= reg_value; -- Output the current register value

end beh;
