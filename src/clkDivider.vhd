--------------------------------------------------------------------------------
-- Entity: clkDivider
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : clkDivider.vhd
-- Creation date     : 2011-05-25
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : generates a clock frequency <GEN_FreqOut_Hz> based on 
-- 					   input freuency <GEN_FreqOut_Hz>
-- 					   Attention: avoid "strange" samples as 3:2
--------------------------------------------------------------------------------
-- File History:
-- Date         Version Author	Comment
-- unknown   	0.10    marcel	Creation of File
-- 2011-05-25	1.00	marcel	GENERICs added	
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


--! brief
--! generates a clock frequency <GEN_FreqOut_Hz> based on 
--! input freuency <GEN_FreqOut_Hz>
--! Generics can also be used to define ratio (like 4 (IN) : 1(Out))
--! Attention: avoid "strange" ratios (like 3:2)

--! detailed
--! see brief

entity clkDivider is
    generic(
    	GEN_FreqIn_Hz	: integer := 200000000;	--! signal description input clock frequency in Hz for <iClk_in>
    	GEN_FreqOut_Hz	: integer := 100000000  --! signal description output clock frequency in Hz for <oClk_out>
    );
    port ( 
    	iClk_in 		: in  STD_LOGIC;		--! signal description input clock
		iReset			: in  STD_LOGIC;		--! signal description asynchronous reset (can be tied to '0')
        oClk_out 		: out STD_LOGIC			--! signal description output clock
    );
end clkDivider;

architecture Behavioral of clkDivider is
	constant cLimit : integer := GEN_FreqIn_Hz / (2 * GEN_FreqOut_Hz);
	signal sCounter : integer := 0;
	signal sClk_out	: STD_LOGIC := '0';
begin

	process (iClk_in, iReset)
	begin
		if (iReset = '1') then
			sCounter 	<= 0;
			sClk_out 	<= '0';
			
		elsif (rising_edge(iClk_in)) then
			if (sCounter = (cLimit-1)) then
				sCounter <= 0;
				sClk_out <= not sClk_out;
				
			else
				sCounter <= sCounter + 1;
				 
			end if;
			
		end if;
		
	end process;
	
	oClk_out <= sClk_out;

end Behavioral;

