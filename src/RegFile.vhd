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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegFile is
	Port(
		iClk			: in  std_logic;
		iReset		: in  std_logic;
	
		idDataIn		: in  DATA;
		idCarryIn	: in  std_logic;
		idZeroIn		: in  std_logic;
	
		icLoadEn		: in std_logic;
		
		odDataOut	: out DATA;
		odCarryOut	: out std_logic;
		odZeroOut	: out	std_logic
	);
end RegFile;

architecture Behavioral of RegFile is
	signal sdData	: DATA;
	signal sdCarry	: std_logic;
	signal sdZero 	: std_logic;
begin

	-- Execute Transition
	process(iClk, iReset)
	begin
		if (iReset = '1') then
			sdData  <= (others => '0');
			sdCarry <= '0';
			sdZero  <= '0';
			
		elsif (rising_edge(iClk)) then
			if (icLoadEn = '1') then
				sdData  <= idDataIn;
				sdCarry <= idCarryIn;
				sdZero  <= idZeroIn;
				
			end if;
			
		end if;
	
	end process;

	-- Output
	odDataOut	<= sdData;
	odCarryOut	<= sdCarry;
	odZeroOut	<= sdZero;

end Behavioral;

