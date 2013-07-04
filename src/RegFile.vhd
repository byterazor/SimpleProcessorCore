----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:05:19 05/10/2011 
-- Design Name: 
-- Module Name:    RegFile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

library work;
use work.cpupkg.all;
use ieee.numeric_std.all;


entity RegFile is
	Port(
		iClk			: in  std_logic;
		iReset		    : in  std_logic;
	       
	    icRegAsel       : in  std_logic_vector(4 downto 0);  
	    icRegBsel       : in  std_logic_vector(4 downto 0);
	    odRegA          : out DATA;
	    odRegB          : out DATA;
	    
	    
	    icRegINsel      : in  std_logic_vector(4 downto 0);
		
		idDataIn		: in  DATA;
		idCarryIn	: in  std_logic;
		idZeroIn		: in  std_logic;
	
		icLoadEn		: in std_logic;
		
		odCarryOut	: out std_logic;
		odZeroOut	: out	std_logic
	);
end RegFile;

architecture Behavioral of RegFile is
	
	type registerFileType is array (0 to 31) of DATA;
    signal registerFile : registerFileType;
	
	signal sdData	: DATA;
	signal sdCarry	: std_logic;
	signal sdZero 	: std_logic;
begin
    
    
    
    
        
	-- Execute Transition
	process(iClk, iReset)
	begin
		if (iReset = '1') then
		    for i in 31 downto 0 loop
                    registerFile(i) <= (others=>'0');
            end loop;
			
			sdCarry <= '0';
			sdZero  <= '0';
			
		elsif (rising_edge(iClk)) then
			if (icLoadEn = '1') then
			    registerFile(to_integer(unsigned(icRegINsel))) <= idDataIn;
				sdCarry <= idCarryIn;
				sdZero  <= idZeroIn;
				
			end if;
			
		end if;
	
	end process;
    
    
    odRegA  <= registerFile(to_integer(unsigned(icRegAsel)));
    odRegB  <= registerFile(to_integer(unsigned(icRegBsel)));
	odCarryOut	<= sdCarry;
	odZeroOut	<= sdZero;

end Behavioral;

