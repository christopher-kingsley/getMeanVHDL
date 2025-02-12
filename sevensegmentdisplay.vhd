library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevensegmentdisplay is
    Port ( BCD : in  std_logic_vector(3 downto 0);
           SEG : out std_logic_vector(6 downto 0));
end sevensegmentdisplay;

architecture Behavioral of sevensegmentdisplay is
begin
    process (BCD)
    begin
        case BCD is
            when "0000" =>
                SEG <= "1000000"; -- 0
            when "0001" =>
                SEG <= "1111001"; -- 1
            when "0010" =>
                SEG <= "0100100"; -- 2
            when "0011" =>
                SEG <= "0110000"; -- 3
            when "0100" =>
                SEG <= "0011001"; -- 4
            when "0101" =>
                SEG <= "0010010"; -- 5
            when "0110" =>
                SEG <= "0000010"; -- 6
            when "0111" =>
                SEG <= "1111000"; -- 7
            when "1000" =>
                SEG <= "0000000"; -- 8
            when "1001" =>
                SEG <= "0010000"; -- 9
            when "1010" =>
                SEG <= "0001000"; -- A
            when "1011" =>
                SEG <= "0000011"; -- B
            when "1100" =>
                SEG <= "1000110"; -- C
            when "1101" =>
                SEG <= "0100001"; -- D
            when "1110" =>
                SEG <= "0000110"; -- E
            when "1111" =>
                SEG <= "0001110"; -- F
            when others =>
                SEG <= "1111111"; -- All segments off
        end case;
    end process;
end Behavioral;