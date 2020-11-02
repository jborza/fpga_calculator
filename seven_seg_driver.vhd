----------------------------------------------------------------------------------
-- Iteratively outputs A,B,C on the SevenSegment output at a reasonable refresh rate
-- outputs also the Enable bits for the individual digits
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           B : in  STD_LOGIC_VECTOR (7 downto 0);
           C : in  STD_LOGIC_VECTOR (7 downto 0);
           SevenSegment : out  STD_LOGIC_VECTOR (7 downto 0);
			  Enable : out STD_LOGIC_VECTOR (2 downto 0);
           Clk12Mhz : in  STD_LOGIC);
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
signal digit_counter : unsigned (1 downto 0); -- 2-bit counter going 0,1,2,0,1,2,....
signal clk_refresh_counter : unsigned (14 downto 0); --16-bit counter from 0 to 65535
signal clk_refresh : STD_LOGIC;
begin

--process to generate slower refresh period than the main clock
--should be triggered at 12,000,000 / 65536 ~= 183 Hz
process(Clk12Mhz)
begin
	if rising_edge(Clk12Mhz) then
		clk_refresh_counter <= clk_refresh_counter + 1;
		if(clk_refresh_counter = 0) then
			clk_refresh <= '1';
		else
			clk_refresh <= '0';
		end if;
	end if;
end process;

process(clk_refresh) 
begin
	if rising_edge(clk_refresh) then
		case digit_counter is
			when "00" => 
				SevenSegment <= A;
				Enable <= "011";
				digit_counter <= "01";
			when "01" =>
				SevenSegment <= B;
				Enable <= "101";
				digit_counter <= "10";
			when others => 
				SevenSegment <= C;
				Enable <= "110";
				digit_counter <= "00";
		end case;
	end if;
end process;
	


end Behavioral;