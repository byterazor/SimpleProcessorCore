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
    0    => B"00111111110000000000000000000001", --lui $30, 1
    1    => B"00001100001000001111111111110000", --loa $1, 65520
    2    => B"01000011111000000000000000000101", --jmc print
    3    => B"01000011111000000000000000100011", --jmc wait
    4    => B"00111000000000000000000000000000", --jmp start
    5    => B"00010010100000010000000000000000", --add $20, $1, $0
    6    => B"00001000000101001111111111110001", --sto $20, 65521
    7    => B"00000110100101000000000000000000", --shr $20, $20, $0
    8    => B"00000110100101000000000000000000", --shr $20, $20, $0
    9    => B"00000110100101000000000000000000", --shr $20, $20, $0
   10    => B"00000110100101000000000000000000", --shr $20, $20, $0
   11    => B"00000110100101000000000000000000", --shr $20, $20, $0
   12    => B"00000110100101000000000000000000", --shr $20, $20, $0
   13    => B"00000110100101000000000000000000", --shr $20, $20, $0
   14    => B"00000110100101000000000000000000", --shr $20, $20, $0
   15    => B"00001000000101001111111111110001", --sto $20, 65521
   16    => B"00000110100101000000000000000000", --shr $20, $20, $0
   17    => B"00000110100101000000000000000000", --shr $20, $20, $0
   18    => B"00000110100101000000000000000000", --shr $20, $20, $0
   19    => B"00000110100101000000000000000000", --shr $20, $20, $0
   20    => B"00000110100101000000000000000000", --shr $20, $20, $0
   21    => B"00000110100101000000000000000000", --shr $20, $20, $0
   22    => B"00000110100101000000000000000000", --shr $20, $20, $0
   23    => B"00000110100101000000000000000000", --shr $20, $20, $0
   24    => B"00001000000101001111111111110001", --sto $20, 65521
   25    => B"00000110100101000000000000000000", --shr $20, $20, $0
   26    => B"00000110100101000000000000000000", --shr $20, $20, $0
   27    => B"00000110100101000000000000000000", --shr $20, $20, $0
   28    => B"00000110100101000000000000000000", --shr $20, $20, $0
   29    => B"00000110100101000000000000000000", --shr $20, $20, $0
   30    => B"00000110100101000000000000000000", --shr $20, $20, $0
   31    => B"00000110100101000000000000000000", --shr $20, $20, $0
   32    => B"00000110100101000000000000000000", --shr $20, $20, $0
   33    => B"00001000000101001111111111110001", --sto $20, 65521
   34    => B"01000100000111110000000000000000", --ret
   35    => B"00111101010000000000001001011000", --lui $10, 600
   36    => B"00000001010010100000000000000000", --shl $10, $10, $0
   37    => B"00000001010010100000000000000000", --shl $10, $10, $0
   38    => B"00000001010010100000000000000000", --shl $10, $10, $0
   39    => B"00000001010010100000000000000000", --shl $10, $10, $0
   40    => B"00000001010010100000000000000000", --shl $10, $10, $0
   41    => B"00000001010010100000000000000000", --shl $10, $10, $0
   42    => B"00000001010010100000000000000000", --shl $10, $10, $0
   43    => B"00000001010010100000000000000000", --shl $10, $10, $0
   44    => B"00000001010010100000000000000000", --shl $10, $10, $0
   45    => B"00000001010010100000000000000000", --shl $10, $10, $0
   46    => B"00000001010010100000000000000000", --shl $10, $10, $0
   47    => B"00000001010010100000000000000000", --shl $10, $10, $0
   48    => B"00000001010010100000000000000000", --shl $10, $10, $0
   49    => B"00000001010010100000000000000000", --shl $10, $10, $0
   50    => B"00000001010010100000000000000000", --shl $10, $10, $0
   51    => B"00111101011000000000000000000001", --lui $11, 1
   52    => B"00010101010010100101100000000000", --sub $10, $10, $11
   53    => B"00110000000000000000000000110111", --jpz endloop
   54    => B"00111000000000000000000000110100", --jmp loop
   55    => B"01000100000111110000000000000000", --ret
		 
		
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
				if (icEnable = '1') then
    				if (icRnotW = '0') then
    					sRam(conv_integer(unsigned(idAddress))) <= bdData;	
    				else
    					tData <= sRam(conv_integer(unsigned(idAddress)));
    				end if;
    	       end if;
				
		end if;
		
	end process;

	bdData <= tData when icRnotW = '1' and icEnable='1' else
					(others => 'Z');

end arch;

