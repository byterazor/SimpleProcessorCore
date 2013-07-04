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
		odRegAsel   : out std_logic_vector(4 downto 0);
		odRegBsel   : out std_logic_vector(4 downto 0);
		odRegINsel  : out std_logic_vector(4 downto 0);
		ocOperation	: out OPTYPE
			
	);
end FetchDecode;

architecture Behavioral of FetchDecode is
	signal sdPC, sdPC_next 		: ADDRESS;
	signal sdAdr, sdAdr_next 	: ADDRESS;
	signal sdImmidate, sdImmidiate_next : DATA;
	
	signal sdRegAsel, sdRegAsel_next   :   std_logic_vector(4 downto 0);
	signal sdRegBsel, sdRegBsel_next   :   std_logic_vector(4 downto 0);
	signal sdRegINsel, sdRegINsel_next   :   std_logic_vector(4 downto 0);
	
	signal scOp, scOp_next 		: OPTYPE;
	
begin
	Transition: process(idData, sdImmidate, icLoadInstr, icJump, icNextPC, sdAdr, sdPC, scOp, sdRegAsel, sdRegBsel, sdRegINsel)
	begin
		-- defaults
		sdAdr_next <= sdAdr;
		sdPC_next  <= sdPC;
		scOp_next  <= scOp;
	    sdImmidiate_next   <= sdImmidate;
        
        sdRegAsel_next  <= sdRegAsel;
        sdRegBsel_next  <= sdRegBsel;
        sdRegINsel_next <= sdRegINsel;
        
        --! ISA Definition	    
		if (icLoadInstr = '1') then
			sdAdr_next <= "0000" & idData(11 downto 0);
			sdImmidiate_next <= "0000000000000000" & idData(15 downto 0);
			sdRegINsel_next  <= idData(25 downto 21);
			sdRegAsel_next   <= idData(20 downto 16);
			sdRegBsel_next   <= idData(15 downto 11);
			
			case idData(31 downto 26) is
				when "000000" => scOp_next <= shl;
				when "000001" => scOp_next <= shr; 
				when "000010"	=> scOp_next <= sto; 
				when "000011"	=> scOp_next <= loa; 
				when "000100"	=> scOp_next <= add; 
				when "000101"	=> scOp_next <= sub; 
				when "000110"	=> scOp_next <= addc; 
				when "000111"	=> scOp_next <= subc; 
				when "001000"	=> scOp_next <= opor; 
				when "001001"	=> scOp_next <= opand; 
				when "001010"	=> scOp_next <= opxor; 
				when "001011"	=> scOp_next <= opnot; 
				when "001100"	=> scOp_next <= jpz;
				when "001101"	=> scOp_next <= jpc;
				when "001110"	=> scOp_next <= jmp; 
				when "001111" => scOP_next <= li;
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
			sdRegAsel    <= (others=>'0');
			sdRegBsel    <= (others=>'0');
			sdRegINsel   <= (others=>'0');
			
			scOp  <= hlt;
		      
		elsif (rising_edge(iClk)) then
			sdPC  <= sdPC_next;
			sdAdr <= sdAdr_next;
			scOp  <= scOp_next;
		    sdImmidate    <= sdImmidiate_next;
		    sdRegAsel     <= sdRegAsel_next;
		    sdRegBsel     <= sdRegBsel_next;
		    sdRegINsel    <= sdRegINsel_next;
		end if;
	
	end process;

	-- Output
	odAddress <= 	sdAdr when icAddrSel = '0' and icLoadInstr = '0' else
						sdAdr_next when icAddrSel = '0' and icLoadInstr = '1' else
						sdPC; -- addr_sel = '1'
						
	ocOperation <= scOp when icLoadInstr = '0' else
						scOp_next;				
    
    odImmidiate <= sdImmidate when icLoadInstr = '0' else sdImmidiate_next;
    
    odRegAsel   <= sdRegAsel  when icLoadInstr = '0' else sdRegAsel_next;
    odRegBsel   <= sdRegBsel  when icLoadInstr = '0' else sdRegBsel_next;
    odRegINsel  <= sdRegINsel when icLoadInstr = '0' else sdRegINsel_next;
    
    
end Behavioral;

