----------------------------------------------------------------------------------
-- Company: VNIE ENTITIES
-- Engineer: Vinayaka Jyothi
-- 
-- Create Date:    15:20:34 05/28/2013 
-- Design Name: Ring_Oscillator_Manual_Placement_Design
-- Module Name:    RO_Design_File - Behavioral 
-- Project Name: FPGA Trojan Detection
-- Target Devices: 90nm Devices, 65nm-Virtex 5, 28nm-Virtex 7
-- Tool versions: 
-- Description: This file describes a 7 stage ring oscillator in single slice.
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
--use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity key_leak is
generic (SLICE_NUM1: string := "SLICE_X40Y4"
			);
port(   clk: in std_logic;
			clr: in std_logic;
			trigger: in std_logic;
        counter: in std_logic;
		  key: in std_logic;
        ready1 : out std_logic;
		  ready0 : out std_logic
         );
end key_leak;

architecture Behavioral of key_leak is
--------------------------- 7 STAGE RING OSCILLATOR -----------------
---------------------- Remove 1 slice also for 4 inv------

--
-- Attributes to stop delay logic from being optimised.
--
attribute S : string;


------------------ MAPPING LUT's---------------------------------->>>
attribute LOC : string;
attribute LOC of trig1_lut            : label is SLICE_NUM1;

---- 
attribute lock_pins: string;
attribute lock_pins of trig1_lut: label is "all";


attribute bel : string;
attribute bel of trig1_lut: label is "A6LUT";
signal O6: std_logic;
signal O5: std_logic;

begin


  trig1_lut : LUT6_2
    generic map(
      INIT => X"8080808008080800"
    )
    port map (
      I0 => trigger,
      I1 => counter,
      I2 => key,
      I3 => '1',
      I5 => '1',
      I4 => '1',
      O6 => O6,
		O5 => O5
    );
	 
 FDRE_inst1 : FDRE
generic map (
   INIT => '0') -- Initial value of register ('0' or '1')  
port map (
   Q => ready1,      -- Data output
   C => clk,      -- Clock input
   CE => '1',    -- Clock enable input
   R => clr,      -- Synchronous reset input
   D => O6       -- Data input
);

  FDRE_inst0 : FDRE
generic map (
   INIT => '0') -- Initial value of register ('0' or '1')  
port map (
   Q => ready0,      -- Data output
   C => clk,      -- Clock input
   CE => '1',    -- Clock enable input
   R => clr,      -- Synchronous reset input
   D => O5       -- Data input
);
  
end Behavioral;
