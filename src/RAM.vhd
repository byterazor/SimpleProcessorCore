-------------------------------------------------------
--! @file 
--! @brief simple RAM for the IIB2 Akkumulator machine
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @date 2010-11-18
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.cpupkg.all;

--! simple RAM for the IIB2 Akkumulator machine using word addressing

entity RAM is
    port  (
    	iClk			:	in		std_logic;
    	iReset		:	in 	std_logic;
    	bdData		:	inout	DATA;		--! connection to databus
    	idAddress   :	in		ADDRESS;		--! connection to addressbus
    	icEnable		:	in 	std_logic;		--! enable or disable RAM
    	icRnotW		:	in		std_logic		--! read/write control
    	
    );
end RAM;

architecture arch of RAM is
	
	type MEMORY is ARRAY(0 to 255) of DATA;		--! array of data words
	
	constant Prog1 : MEMORY := (		--! 4k * 16bit of RAM	
		0		=>  B"0011_000000001010",		-- loa 10 (n)
		1		=>	 B"1100_000000001000",		-- jpz 8
		2		=>  B"0101_000000001100",		-- sub <1>
		3		=>  B"0010_000000001010",		-- sto 10 (n)
		4		=>  B"0011_000000001011",		-- loa 11 (a)
		5		=>  B"0100_000000001001",		-- add <result>
		6		=>  B"0010_000000001001",		-- sto <result>
		7		=>  B"1110_000000000000",		-- jmp 0
		8		=>  B"1111_000000000000",		-- hlt
		9		=>  B"0000_000000000000",		-- result
		10		=>  B"0000_000000000011",		-- n=3
		11		=>  B"0000_000000000101",		-- a=1
		12		=>  B"0000_000000000001",		-- 1
		 
		
		others	=>	(others => '0')
	);
	
	signal sRam 			: MEMORY;
	signal tData			: DATA;
	
	
begin
	
	
	
	
	--! functionality of the RAM
	process(iClk, iReset)
	begin
		if (iReset = '1') then
			sRam <= Prog1;
			tData <= (others => '0');
			
		elsif (rising_edge(iClk)) then
				if (icRnotW = '0' and icEnable = '1') then
					sRam(conv_integer(unsigned(idAddress))) <= bdData;	
				else
					tData <= sRam(conv_integer(unsigned(idAddress)));
				end if;
				
		end if;
		
	end process;

	bdData <= tData when icRnotW = '1' else
					(others => 'Z');

end arch;

