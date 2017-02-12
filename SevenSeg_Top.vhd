----------------------------------------------------------------------------
--	SevenSeg_Demo -- Nexys4DDR GPIO/7Seg Demonstration Project
----------------------------------------------------------------------------
-- Author:  Vinayaka Jyothi 
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	The GPIO/7Seg Demo project demonstrates usage of the Nexys4DDR's 
--  GPIO and 7Seg. The behavior is as follows:
--
--    *The 16 User LEDs are tied to the 16 User Switches. While the center
--	User button is pressed, the LEDs are instead tied to GND
--    *The 7-Segment display displays counter or static value based on SW0 and SW1.
--    SW1,SW0=00 or 10 -->  Static value on 7seg
--	      =11 --> Live Counter on 7Seg  
--	      =01 --> Counter stops and shown last count 			    
--    *Note that the center user button behaves as a user reset button
--        and is referred to as such in the code comments below
--    *NOTE: BTN1 to 3 are unused and produces warning while generating bitstream. It can be neglected.    
--																
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--The IEEE.std_logic_unsigned contains definitions that allow 
--std_logic_vector types to be used with the + operator to instantiate a 
--counter.
use IEEE.std_logic_unsigned.all;

entity SevenSeg_Demo is
    Port ( SW 			: in  STD_LOGIC_VECTOR (15 downto 0);
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);
           CLK 			: in  STD_LOGIC;
           LED 			: out  STD_LOGIC_VECTOR (15 downto 0);
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0)
			  );
end SevenSeg_Demo;

architecture Behavioral of SevenSeg_Demo is

component Hex2LED 
port (CLK: in STD_LOGIC; X: in STD_LOGIC_VECTOR (3 downto 0); Y: out STD_LOGIC_VECTOR (7 downto 0)); 
end component; 

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;

constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second
constant VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9

constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms


--This is used to determine when the 7-segment display should be
--incremented
signal Cntr : std_logic_vector(26 downto 0) := (others => '0');

--This counter keeps track of which number is currently being displayed
--on the 7-segment.
signal Val : std_logic_vector(3 downto 0) := (others => '0');

--This is the signal that holds the hex value to be diplayed
signal hexval: std_logic_vector(31 downto 0):=x"0123ABCD";


signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0'); 


begin

----------------------------------------------------------
------                LED Control                  -------
----------------------------------------------------------

with BTN(4) select --btn4 IS BTNU
	LED <= SW 			when '0',
			 "0000000000000000" when others;

---- This updates what value needs to sent to 7seg display bases on Switch status
process(CLK,SW(1 downto 0)) --Last 2 switches control what value you see on the 7seg
Begin
	if BTN(0) ='1' then -- btn0 is BTNC -- acts as reset for the hexval
			hexval<=x"00000000";
		elsif rising_edge(clk) then
			case SW(1 downto 0) is
				when "11" => hexval<=hexval+'1'; -- SW=11 will make hexval as counter ans show output... Its so fast that you only see top 4 digits updating... last 4 digits are changing but you will not be able to changing
				when "10" => hexval<=x"ABCDEFFF";
				when "01" => hexval<=hexval; -- Making SW=10 will bring stop the counter display its value.
				when others => hexval<=x"0123ABCD";
			end case;
	end if;
end process;	
----------------------------------------------------------
------           7-Seg Display Control             -------
----------------------------------------------------------
--Digits are incremented every second, and are blanked in
--response to button presses.

--This process controls the counter that triggers the 7-segment
--to be incremented. It counts 100,000,000 and then resets.		  
timer_counter_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if ((Cntr = CNTR_MAX) or (BTN(4) = '1')) then
			Cntr <= (others => '0');
		else
			Cntr <= Cntr + 1;
		end if;
	end if;
end process;

--This process increments the digit being displayed on the 
--7-segment display every second.
timer_inc_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (BTN(4) = '1') then
			Val <= (others => '0');
		elsif (Cntr = CNTR_MAX) then
			if (Val = VAL_MAX) then
				Val <= (others => '0');
			else
				Val <= Val + 1;
			end if;
		end if;
	end if;
end process;

--This select statement selects the 7-segment diplay anode. 
with Val select
	SSEG_AN <= "01111111" when "0001",
				  "10111111" when "0010",
				  "11011111" when "0011",
				  "11101111" when "0100",
				  "11110111" when "0101",
				  "11111011" when "0110",
				  "11111101" when "0111",
				  "11111110" when "1000",
				  "11111111" when others;

--This select statement selects the value of HexVal to the necessary
--cathode signals to display it on the 7-segment
with Val select
	SSEG_CA <= NAME(0) when "0001",
				  NAME(1) when "0010",
				  NAME(2)when "0011",
				  NAME(3) when "0100",
				  NAME(4) when "0101",
				  NAME(5) when "0110",
				  NAME(6) when "0111",
				  NAME(7) when "1000",
				  NAME(0) when others;


CONV1: Hex2LED port map (CLK => CLK, X => HexVal(31 downto 28), Y => NAME(0));
CONV2: Hex2LED port map (CLK => CLK, X => HexVal(27 downto 24), Y => NAME(1));
CONV3: Hex2LED port map (CLK => CLK, X => HexVal(23 downto 20), Y => NAME(2));
CONV4: Hex2LED port map (CLK => CLK, X => HexVal(19 downto 16), Y => NAME(3));		
CONV5: Hex2LED port map (CLK => CLK, X => HexVal(15 downto 12), Y => NAME(4));
CONV6: Hex2LED port map (CLK => CLK, X => HexVal(11 downto 8), Y => NAME(5));
CONV7: Hex2LED port map (CLK => CLK, X => HexVal(7 downto 4), Y => NAME(6));
CONV8: Hex2LED port map (CLK => CLK, X => HexVal(3 downto 0), Y => NAME(7));

end Behavioral;
