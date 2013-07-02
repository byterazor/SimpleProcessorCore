----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:43 05/10/2011 
-- Design Name: 
-- Module Name:    FetchDecode - Behavioral 
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

entity FetchDecode is
	Port(
		iClk			: in  std_logic;
		iReset		: in  std_logic;
		
		idData		: in  DATA;
		icAddrSel	: in  std_logic;
		icLoadInstr	: in  std_logic;
		icJump		: in  std_logic;
		icNextPC		: in  std_logic;
		
		odAddress	: out ADDRESS;
		odImmidiate : out DATA;
		ocOperation	: out OPTYPE	
	);
end FetchDecode;

architecture Behavioral of FetchDecode is
	signal sdPC, sdPC_next 		: ADDRESS;
	signal sdAdr, sdAdr_next 	: ADDRESS;
	signal sdImmidate, sdImmidiate_next : DATA;
	
	signal scOp, scOp_next 		: OPTYPE;
	
begin
	Transition: process(idData, icLoadInstr, icJump, icNextPC, sdAdr, sdPC, scOp)
	begin
		-- defaults
		sdAdr_next <= sdAdr;
		sdPC_next  <= sdPC;
		scOp_next  <= scOp;
	    sdImmidiate_next   <= sdImmidate;
	    
		if (icLoadInstr = '1') then
			sdAdr_next <= idData(11 downto 0);
			sdImmidiate_next <= "0000" & idData(11 downto 0);
			
			case idData(15 downto 12) is
				when "0000" => scOp_next <= shl;
				when "0001" => scOp_next <= shr; 
				when "0010"	=> scOp_next <= sto; 
				when "0011"	=> scOp_next <= loa; 
				when "0100"	=> scOp_next <= add; 
				when "0101"	=> scOp_next <= sub; 
				when "0110"	=> scOp_next <= addc; 
				when "0111"	=> scOp_next <= subc; 
				when "1000"	=> scOp_next <= opor; 
				when "1001"	=> scOp_next <= opand; 
				when "1010"	=> scOp_next <= opxor; 
				when "1011"	=> scOp_next <= opnot; 
				when "1100"	=> scOp_next <= jpz;
				when "1101"	=> scOp_next <= jpc;
				when "1110"	=> scOp_next <= jmp; 
				when "1111" => scOP_next <= li;
				when others	=> scOp_next <= hlt;
			end case;
		end if;
					
		if (icJump = '1') then
			sdPC_next  <= sdAdr;
		
		end if;
		
		if (icNextPC = '1') then
			sdPC_next  <= sdPC + '1';
	
		end if;
	end process;


	-- Execute Transition
	process(iClk, iReset)
	begin
		if (iReset = '1') then
			sdPC  <= (others => '0');
			sdAdr <= (others => '0');
			sdImmidate   <= (others=>'0');
			scOp  <= hlt;
		
		elsif (rising_edge(iClk)) then
			sdPC  <= sdPC_next;
			sdAdr <= sdAdr_next;
			scOp  <= scOp_next;
		    sdImmidate    <= sdImmidiate_next;
		end if;
	
	end process;

	-- Output
	odAddress <= 	sdAdr when icAddrSel = '0' and icLoadInstr = '0' else
						sdAdr_next when icAddrSel = '0' and icLoadInstr = '1' else
						sdPC; -- addr_sel = '1'
						
	ocOperation <= scOp when icLoadInstr = '0' else
						scOp_next;				

end Behavioral;

