--------------------------------------------------------------------------------
-- Entity: Fifo
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : Fifo.vhd
-- Creation date     : 2011-05-27
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : <short description>
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-27   1.00     marcel     Creation of File
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Fifo is
	port  (
		iReset		: in  std_logic;
		
		iClkWrite 	: in  std_logic; 
		icWriteEn	: in  std_logic;
		
		iClkRead 	: in  std_logic; 
		icReadEn	: in  std_logic;
		
		idDataIn	: in  std_logic_vector(8 downto 0);
		odDataOut	: out std_logic_vector(8 downto 0);
		
		ocEmpty		: out std_logic;
		ocFull		: out std_logic;
		
		ocAlmostE	: out std_logic;
		ocAlmostF	: out std_logic
	);
end Fifo;

architecture arch of Fifo is
	signal sdDataOut : std_logic_vector(31 downto 0);
	signal sdDataIn	 : std_logic_vector(31 downto 0);
	signal sdParityIN: std_logic_vector(3 downto 0);
	signal sdParityOut:std_logic_vector(3 downto 0);
begin

	 FIFO36_inst : FIFO36
	   generic map (
	      ALMOST_FULL_OFFSET 	=> X"0080", -- Sets almost full threshold
	      ALMOST_EMPTY_OFFSET 	=> X"0080", -- Sets the almost empty threshold
	      DATA_WIDTH			=> 9,    	-- Sets data width to 4, 9, 18, or 36
	      DO_REG 				=> 1,       -- Enable output register ( 0 or 1)
	                                      	-- Must be 1 if the EN_SYN = FALSE
	      EN_SYN 				=> FALSE,   -- Specified FIFO as Asynchronous (FALSE) or 
	                                      	-- Synchronous (TRUE)
	      FIRST_WORD_FALL_THROUGH => TRUE, 	-- Sets the FIFO FWFT to TRUE or FALSE
	      SIM_MODE 				=> "FAST") 	-- Simulation: "SAFE" vs "FAST", see "Synthesis and Simulation
	                          				-- Design Guide" for details
	   port map (
	      ALMOSTEMPTY 	=> ocAlmostE, 	-- 1-bit almost empty output flag
	      ALMOSTFULL	=> ocAlmostF,	-- 1-bit almost full output flag
	      DO 			=> sdDataOut, 	-- 32-bit data output
	      DOP 			=> sdParityOut, -- 4-bit parity data output
	      EMPTY 		=> ocEmpty,		-- 1-bit empty output flag
	      FULL 			=> ocFull,		-- 1-bit full output flag
	      RDCOUNT 		=> open,		-- 13-bit read count output
	      RDERR 		=> open,		-- 1-bit read error output
	      WRCOUNT 		=> open,		-- 13-bit write count output
	      WRERR 		=> open,		-- 1-bit write error
	      DI 			=> sdDataIn,	-- 32-bit data input
	      DIP 			=> sdParityIn,  -- 4-bit parity input
	      RDCLK 		=> iClkRead,	-- 1-bit read clock input
	      RDEN 			=> icReadEn,	-- 1-bit read enable input
	      RST 			=> iReset,		-- 1-bit reset input
	      WRCLK 		=> iClkWrite,	-- 1-bit write clock input
	      WREN 			=> icWriteEn    -- 1-bit write enable input
	   );
	   
	   odDataOut(8 downto 1) <= sdDataOut(7 downto 0);
	   odDataOut(0)          <= sdParityOut(0); 
	   sdDataIn <= X"000000" & idDataIn(8 downto 1);
	   sdParityIN  <= "000" & idDataIn(0);
end arch;

