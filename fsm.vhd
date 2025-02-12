library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port(
        clk         : in std_logic;
        reset       : in std_logic;
        start       : in std_logic;
        rw          : in std_logic;
        counter_done: in std_logic;
        div_done    : in std_logic;
        ram_en      : out std_logic;
        counter_en  : out std_logic;
        accum_en    : out std_logic;
        div_en      : out std_logic;
        display_en  : out std_logic
    );
end entity;

architecture beh of fsm is
    type state_type is (IDLE, WRITE, READ_ACCUMULATE, DIVIDE, DISPLAY);
    signal current_state, next_state: state_type;

begin
    -- State Transition Process
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE; -- Reset state to IDLE
        elsif rising_edge(clk) then
            current_state <= next_state; -- Move to the next state
        end if;
    end process;

    -- State Transition and Output Logic Combined
    process(current_state, start, rw, counter_done, div_done)
    begin
        -- Default Outputs: Everything OFF
        ram_en     <= '0';
        counter_en <= '0';
        accum_en   <= '0';
        div_en     <= '0';
        display_en <= '0';

        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= WRITE; -- Start writing
                else
                    next_state <= IDLE;
                end if;

            when WRITE =>
                ram_en <= '1'; -- Enable RAM for writing
                if rw = '1' then
                    next_state <= READ_ACCUMULATE; -- Switch to reading & accumulating
                else
                    next_state <= WRITE;
                end if;

            when READ_ACCUMULATE =>
                ram_en <= '1';        -- Enable RAM for reading
                counter_en <= '1';   -- Enable Counter
                accum_en <= '1';     -- Enable Accumulator
                if counter_done = '1' then
                    next_state <= DIVIDE; -- Transition to division
                else
                    next_state <= READ_ACCUMULATE;
                end if;

            when DIVIDE =>
                div_en <= '1'; -- Enable Divider
                if div_done = '1' then
                    next_state <= DISPLAY; -- Transition to displaying result
                else
                    next_state <= DIVIDE;
                end if;

            when DISPLAY =>
                display_en <= '1'; -- Enable Display
                next_state <= DISPLAY; -- Remain in DISPLAY state until reset

            when others =>
                next_state <= IDLE; -- Default to IDLE
        end case;
    end process;

end beh;
