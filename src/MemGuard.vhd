-------------------------------------------------------
--! @file 
--! @brief memory guard to only answer for the correct memory space
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @date 2013-07-18
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--! memory guard to only answer for the correct memory space

entity MemGuard is
    generic (
        GEN_start   :   std_logic_vector(15 downto 0) := x"0000";
        GEN_end     :   std_logic_vector(15 downto 0) := x"0004" 
        
    );
    
    port  (
        icAddr      :   in  std_logic_vector(15 downto 0);
        ocEnable    :   out std_logic
                
    );
end MemGuard;

architecture arch of MemGuard is

begin
    
    
    process(icAddr)
    begin
        if (icAddr >= GEN_start and icAddr <= GEN_end) then
            ocEnable <= '1';
        else
            ocEnable <= '0';
        end if;
    end process;
    
end arch;

