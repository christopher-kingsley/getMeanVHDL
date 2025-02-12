library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity getMeanQualityCount is
    port(
        clk       : in std_logic; -- Input fast clock
        reset     : in std_logic; -- Reset signal
        start     : in std_logic; -- Start signal for FSM
        rw        : in std_logic; -- Read/Write control signal
        address   : in std_logic_vector(2 downto 0); -- User input address for RAM
        dataIn    : in std_logic_vector(3 downto 0); -- Input data for RAM
        SEG       : out std_logic_vector(6 downto 0); -- Seven-segment display for RAM input
        SEG2      : out std_logic_vector(6 downto 0); -- Seven-segment display for final mean
        SEG3      : out std_logic_vector(6 downto 0); -- Seven-segment display for RAM output
        SEG4      : out std_logic_vector(6 downto 0); -- Seven-segment display for Accumulator output
        ledOUT    : out std_logic -- LED output from clock divider
    );
end entity;

architecture beh of getMeanQualityCount is

    -- Component Declarations
    component clockdivider is
        port(
            clk    : in std_logic;  -- Input fast clock
            Clock  : out std_logic; -- Slow clock output
            led    : out std_logic  -- LED signal (optional debugging)
        );
    end component;

    component RamModule is
        port(
            clk      : in std_logic;
            rw       : in std_logic;
            address  : in std_logic_vector(2 downto 0);
            dataIn   : in std_logic_vector(3 downto 0);
            dataOut  : out std_logic_vector(3 downto 0)
        );
    end component;

    component myCounterModule is
        port(
            clk         : in std_logic;
            reset       : in std_logic;
            enable      : in std_logic;
            dataIn      : in std_logic_vector(3 downto 0); -- Data read from RAM
            address     : out std_logic_vector(2 downto 0); -- Current RAM address
            count       : out std_logic_vector(3 downto 0); -- Count of nonzero values
            counter_done: out std_logic -- Signals when all addresses have been checked
        );
    end component;

    component Accumulator is
        port(
            clk     : in std_logic;
            reset   : in std_logic;
            enable  : in std_logic;
            dataIn  : in std_logic_vector(3 downto 0);
            prevSum : in std_logic_vector(3 downto 0);
            sum     : out std_logic_vector(3 downto 0)
        );
    end component;

    component DividerModule is
        port(
            clk      : in std_logic;
            enable   : in std_logic;
            sum      : in std_logic_vector(3 downto 0);
            count    : in std_logic_vector(3 downto 0);
            mean     : out std_logic_vector(3 downto 0);
            div_done : out std_logic
        );
    end component;

    component fsm is
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
    end component;

    component sevensegmentdisplay is
        port(
            BCD : in  std_logic_vector(3 downto 0);
            SEG : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Internal Signals
    signal ram_dataOut      : std_logic_vector(3 downto 0);
    signal counter_done     : std_logic;
    signal div_done         : std_logic;
    signal counter_en       : std_logic;
    signal accum_en         : std_logic;
    signal div_en           : std_logic;
    signal display_en       : std_logic;
    signal ram_en           : std_logic;
    signal slow_clk         : std_logic; -- Output of clock divider

    signal counter_address  : std_logic_vector(2 downto 0);
    signal counter_count    : std_logic_vector(3 downto 0);
    signal accumulator_sum  : std_logic_vector(3 downto 0);
    signal prev_sum         : std_logic_vector(3 downto 0) := (others => '0'); -- Initialize to 0
    signal final_mean       : std_logic_vector(3 downto 0);
    signal selected_address : std_logic_vector(2 downto 0); -- Selected address for RAM

begin

    -- Clock Divider Module
    CLOCK_DIVIDER_INST: clockdivider
        port map(
            clk    => clk,         -- Input fast clock
            Clock  => slow_clk,    -- Slow clock output
            led    => ledOUT       -- LED output
        );

    -- Counter Module
    COUNTER_INST: myCounterModule
        port map(
            clk          => slow_clk, -- Use slow clock
            reset        => reset,
            enable       => counter_en,
            dataIn       => ram_dataOut,
            address      => counter_address,
            count        => counter_count,
            counter_done => counter_done
        );

    -- Address Multiplexer
    process(counter_en, address, counter_address)
    begin
        if counter_en = '1' then
            selected_address <= counter_address; -- Use counter address during READ_ACCUMULATE
        else
            selected_address <= address; -- Use user input address during WRITE
        end if;
    end process;

    -- RAM Module
    RAM_INST: RamModule
        port map(
            clk      => slow_clk,       -- Use slow clock for synchronization
            rw       => rw,
            address  => selected_address, -- Use selected address (user or counter)
            dataIn   => dataIn,
            dataOut  => ram_dataOut
        );

    -- Accumulator Module
    ACCUMULATOR_INST: Accumulator
        port map(
            clk     => slow_clk,  -- Use slow clock
            reset   => reset,
            enable  => accum_en,
            dataIn  => ram_dataOut,
            prevSum => prev_sum,
            sum     => accumulator_sum
        );

    -- Feedback Connection for Accumulator
    prev_sum <= accumulator_sum;

    -- Divider Module
    DIVIDER_INST: DividerModule
        port map(
            clk      => slow_clk, -- Use slow clock
            enable   => div_en,
            sum      => accumulator_sum,
            count    => counter_count,
            mean     => final_mean,
            div_done => div_done
        );

    -- FSM Module
    FSM_INST: fsm
        port map(
            clk         => slow_clk, -- Use slow clock
            reset       => reset,
            start       => start,
            rw          => rw,
            counter_done=> counter_done,
            div_done    => div_done,
            ram_en      => ram_en,
            counter_en  => counter_en,
            accum_en    => accum_en,
            div_en      => div_en,
            display_en  => display_en
        );

    -- First Seven-Segment Display for RAM Input (dataIn)
    SEVEN_SEG_INPUT_INST: sevensegmentdisplay
        port map(
            BCD => dataIn, -- Show the current value being written to RAM
            SEG => SEG     -- Output segments for the RAM input display
        );

    -- Second Seven-Segment Display for Final Mean
    SEVEN_SEG_OUTPUT_INST: sevensegmentdisplay
        port map(
            BCD => final_mean, -- Input to display is the final mean
            SEG => SEG2        -- Output segments for the final mean display
        );

    -- Third Seven-Segment Display for RAM Output (dataOut)
    SEVEN_SEG_RAM_OUTPUT_INST: sevensegmentdisplay
        port map(
            BCD => ram_dataOut, -- Show the value being read from RAM
            SEG => SEG3         -- Output segments for the RAM output display
        );

    -- Fourth Seven-Segment Display for Accumulator Output (accumulator_sum)
    SEVEN_SEG_ACCUM_OUTPUT_INST: sevensegmentdisplay
        port map(
            BCD => accumulator_sum, -- Display the current sum in the accumulator
            SEG => SEG4             -- Output segments for the accumulator display
        );

end beh;



