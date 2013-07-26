--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package cpupkg is
	type OPTYPE is (jmc, shl, shr, sto, loa, li, add, sub, addc, subc, opor, opand, opxor, opnot, jpz, jpc, jmp, hlt, ret);

	subtype DATA is std_logic_vector(31 downto 0);
	subtype ADDRESS is std_logic_vector(15 downto 0);

end cpupkg;


