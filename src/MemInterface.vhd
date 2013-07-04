----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:03:34 05/11/2011 
-- Design Name: 
-- Module Name:    MemInterface - Behavioral 
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

entity MemInterface is
	Port(
		bdDataBus		: inout 	DATA;
		odAddress		: out		ADDRESS;
		ocRnotW			: out		std_logic;
		ocEnable			: out		std_logic;
	
		icBusCtrlCPU	: in     std_logic;
		icRAMEnable		: in		std_logic;
		odDataOutCPU	: out    DATA;
		idDataInCPU		: in     DATA;
		idAddressCPU	: in		ADDRESS		
		);
end MemInterface;

architecture Behavioral of MemInterface is

begin

	ocRnotW		<= icBusCtrlCPU;
	odAddress	<= idAddressCPU when icRAMEnable='1' else (others=>'0');
	ocEnable		<= icRAMEnable;
	
	odDataOutCPU <= bdDataBus;
	bdDataBus	 <= idDataInCPU when icBusCtrlCPU = '0' else
						 (others => 'Z');

end Behavioral;

