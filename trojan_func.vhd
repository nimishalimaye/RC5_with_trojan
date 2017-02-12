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

entity main is
generic (SLICE_NUM1: string := "SLICE_X45Y88"
          --SLICE_NUM2: string := "SLICE_X42Y7"
			);
port(   A : in std_logic;
			B: in std_logic;
            Y : out std_logic   );
end main;

architecture Behavioral of main is
--------------------------- trojan lut -----------------
---------------------- Remove 1 slice also for 4 inv------

--signal temp_out      : std_logic;


--
-- Attributes to stop delay logic from being optimised.
--
attribute S : string;
--attribute S of temp_out : signal is "true";


------------------ MAPPING LUT's---------------------------------->>>
attribute LOC : string;
attribute LOC of trojan_lut            : label is SLICE_NUM1;
--attribute LOC of trig2_lut            : label is SLICE_NUM2;

---- 
attribute lock_pins: string;
attribute lock_pins of trojan_lut: label is "all";
--attribute lock_pins of trig2_lut: label is "all";


attribute bel : string;
attribute bel of trojan_lut: label is "A6LUT";
--attribute bel of trig2_lut: label is "B6LUT";


--attribute syn_keep : boolean;
--attribute KEEP : string;

--attribute syn_keep of temp_out : signal is true;


--attribute KEEP of temp_out : signal is "TRUE";




begin


  trojan_lut : LUT6
    generic map(
      --LOC => "SLICE_X70Y23",
      INIT => X"AAAA5555AAAA5555"
    )
    port map (
      I1 => '1',
      I0 => '1',
      I2 => '1',
      I3 => '1',
      I4 => A,
      I5 => B,
      O => Y
    ); 
 

end Behavioral;
