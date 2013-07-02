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
		
		idDataIn	: in  std_logic_vector(7 downto 0);
		odDataOut	: out std_logic_vector(7 downto 0);
		
		ocEmpty		: out std_logic;
		ocFull		: out std_logic;
		
		ocAlmostE	: out std_logic;
		ocAlmostF	: out std_logic
	);
end Fifo;

architecture arch of Fifo is
    component fifo_generator_v7_2
        port (
        rst: in std_logic;
        wr_clk: in std_logic;
        rd_clk: in std_logic;
        din: in std_logic_vector(7 downto 0);
        wr_en: in std_logic;
        rd_en: in std_logic;
        dout: out std_logic_vector(7 downto 0);
        full: out std_logic;
        almost_full: out std_logic;
        empty: out std_logic;
        almost_empty: out std_logic);
    end component;
	
begin

	fifo_generator_v7_2_0 : fifo_generator_v7_2
  		port map (		
    		rst 		=> iReset,
		    wr_clk 		=> iClkWrite,
		    rd_clk 		=> iClkRead,
		    din 		=> idDataIn,
		    wr_en 		=> icWriteEn,
		    rd_en 		=> icReadEn,
		    dout 		=> odDataOut,
		    full 		=> ocFull,
		    almost_full => ocAlmostF,
		    empty 		=> ocEmpty,
		    almost_empty => ocAlmostE
  	);
	 
end arch;

