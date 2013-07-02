----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:27 05/10/2011 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.cpupkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
	Port(
		idOperand1	: in  DATA;
		idOperand2	: in  DATA;
		idCarryIn	: in  std_logic;
		idImmidiate : in  DATA;
		
		odResult		: out DATA;
		odCarryOut	: out std_logic;
		odZeroOut	: out std_logic;
		
		icOperation	: in  OPTYPE
	);
end ALU;

architecture Behavioral of ALU is
	signal sdTempResult, sdOp1, sdOp2 : std_logic_vector(16 downto 0);
begin
	sdOp1 <= '0' & idOperand1;
	sdOp2 <= '0' & idOperand2;

	process (sdOp1, sdOp2, idCarryIn, icOperation, idImmidiate)
	begin
		if (icOperation = shl) then
			sdTempResult <= sdOp1(15 downto 0) & "0"; 
			
		elsif (icOperation = shr) then
			sdTempResult <= sdOp1(0) & "0" & sdOp1(15 downto 1);
	
		elsif (icOperation = sto) then
			sdTempResult <= (others => '-');
		
		elsif (icOperation = loa) then
			sdTempResult <= sdOp2;
		elsif (icOperation = li) then
		    sdTempResult <= '0' & idImmidiate;
		elsif (icOperation = add) then
			sdTempResult <= sdOp1 + sdOp2;
			
		elsif (icOperation = sub) then
			sdTempResult <= sdOp1 - sdOp2;
		
		elsif (icOperation = addc) then
			sdTempResult <= sdOp1 + sdOp2 + ("0000000000000000" & idCarryIn);
			
		elsif (icOperation = subc) then
			sdTempResult <= sdOp1 - sdOp2 - ("0000000000000000" & idCarryIn);
			
		elsif (icOperation = opor) then
			sdTempResult <= sdOp1 or sdOp2;
			
		elsif (icOperation = opand) then
			sdTempResult <= sdOp1 and sdOp2;
			
		elsif (icOperation = opxor) then
			sdTempResult <= sdOp1 xor sdOp2;
		
		elsif (icOperation = opnot) then
			sdTempResult <= not sdOp1;
			
		elsif (icOperation = jpz) then
			sdTempResult <= (others => '-');
			
		elsif (icOperation = jpc) then
			sdTempResult <= (others => '-');
			
		elsif (icOperation = jmp) then
			sdTempResult <= (others => '-');
			
		else -- (icOperation = hlt)
			sdTempResult <= (others => '-');
		
		end if;
	end process;
	
	odResult 	<= sdTempResult(15 downto 0);
	odCarryOut	<= sdTempResult(16);
	odZeroOut	<= '1' when sdTempResult(15 downto 0) = "0000000000000000" else
						'0';

end Behavioral;

