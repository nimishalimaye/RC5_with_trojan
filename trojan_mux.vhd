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

entity trojan is
generic (SLICE_NUM1: string := "SLICE_X40Y4"
			);
port(   x: in std_logic;
        sel: in std_logic;
        trojan_trigger : out std_logic
         );
end trojan;

architecture Behavioral of trojan is
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


begin


  trig1_lut : LUT6
    generic map(
      INIT => X"6000000000000000"
    )
    port map (
      I0 => x,
      I1 => sel,
      I2 => '1',
      I3 => '1',
      I5 => '1',
      I4 => '1',
      O => trojan_trigger
    );
	 
 

end Behavioral;
