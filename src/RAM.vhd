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
	
	signal sRAM : MEMORY := (		--! 4k * 32bit of RAM
    0    => B"00001100001000000000000011001000", --loa $1, 200
    1    => B"01000011111000000000000000001101", --jmc print
    2    => B"00001100001000000000000011001001", --loa $1, 201
    3    => B"01000011111000000000000000001101", --jmc print
    4    => B"00001100001000000000000011001010", --loa $1, 202
    5    => B"01000011111000000000000000001101", --jmc print
    6    => B"00001100001000000000000011001011", --loa $1, 203
    7    => B"01000011111000000000000000001101", --jmc print
    8    => B"00001100001000000000000011001100", --loa $1, 204
    9    => B"01000011111000000000000000001101", --jmc print
   10    => B"00111100001000000000001000000000", --lui $1, 512
   11    => B"01000011111000000000000000011010", --jmc printAscii
   12    => B"11111100000000000000000000000000", --hlt
   13    => B"00010010100000010000000000000000", --add $20, $1, $0
   14    => B"00001000000101001111111111110001", --sto $20, 65521
   15    => B"00000110100101000000000000000000", --shr $20, $20, $0
   16    => B"00000110100101000000000000000000", --shr $20, $20, $0
   17    => B"00000110100101000000000000000000", --shr $20, $20, $0
   18    => B"00000110100101000000000000000000", --shr $20, $20, $0
   19    => B"00000110100101000000000000000000", --shr $20, $20, $0
   20    => B"00000110100101000000000000000000", --shr $20, $20, $0
   21    => B"00000110100101000000000000000000", --shr $20, $20, $0
   22    => B"00000110100101000000000000000000", --shr $20, $20, $0
   23    => B"00110000000000000000000000011001", --jpz endPrint
   24    => B"00111000000000000000000000001110", --jmp printLoop
   25    => B"01000100000111110000000000000000", --ret
   26    => B"00010010100000010000000000000000", --add $20, $1, $0
   27    => B"00100110101101000111100000000000", --and $21, $20, 15
   28    => B"00100010101101011000000000000000", --or  $21, $21, 48
   29    => B"00010110110101010101000000000000", --sub $22, $21, 10
   30    => B"00110100000000000000000000100000", --jpc smaller
   31    => B"00010010101101010011100000000000", --add $21, $21, 7
   32    => B"00001000000101011111111111110001", --sto $21, 65521
   33    => B"00000110100101000000000000000000", --shr $20, $20, $0
   34    => B"00000110100101000000000000000000", --shr $20, $20, $0
   35    => B"00000110100101000000000000000000", --shr $20, $20, $0
   36    => B"00000110100101000000000000000000", --shr $20, $20, $0
   37    => B"00110000000000000000000000000000", --jpz asciloop:
   38    => B"01000100000111110000000000000000", --ret
		 
   --
   -- Some variables
   -- 
   
   -- Geraffel
   200   => x"61726547",
   201   => x"6c656666",
   
   -- Processor
   202   => x"6f725020",
   203   => x"73736563",
   204   => x"0a20726f",
   
   -- Return
   205   => x"0a202020",
   
   
	others	=>	(others => '0')
	);
	
	signal tData			: DATA;
	
	
begin
	
	
	
	
	--! functionality of the RAM
	process(iClk, iReset)
	begin
		if (iReset = '1') then
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

