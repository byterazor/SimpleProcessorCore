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
	
	constant Prog1 : MEMORY := (		--! 4k * 32bit of RAM
		1      => B"00111100001000000000000000000101", --lui $1, 5
    2    => B"00111100010000000000000000000110", --lui $2, 6
    3    => B"00111100011000000000000000000000", --lui $3, 0
    4    => B"00111100100000000000000000000001", --lui $4, 1
    5    => B"00010000101000000001000000000000", --add $5, $0, $2
    6    => B"00010000011000110000100000000000", --add $3, $3, $1
    7    => B"00010100101001010010000000000000", --sub $5, $5, $4
    8    => B"00110000000000000000000000001010", --jpz end
    9    => B"00111000000000000000000000000110", --jmp loop
   10    => B"11111100000000000000000000000000", --hlt

		 
		
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

