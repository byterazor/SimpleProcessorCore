-------------------------------------------------------
--! @file 
--! @brief Maps memory devices to a given memory space
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @date 2010-06-03
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--! Maps memory devices to a given memory space
entity MemoryMapper is
        port(
            start       :   in std_logic_vector(15 downto 0);           --! start of memory space
            stop        :   in std_logic_vector(15 downto 0);           --! end of mempry space
            
            adr_in      :   in std_logic_vector(15 downto 0);
            
            req_in      :   in std_logic;         --! ram request type
            req_out     :   out std_logic;        --! ram request type
            
            enable      :   out std_logic;
                                    
            adr_out     :   out std_logic_vector(15 downto 0)
            
    );
end MemoryMapper;


--! architecture to map memory devices to memory space
architecture arch of MemoryMapper is

begin

    process(adr_in, req_in, start, stop)
    begin
    
        if (adr_in >= start and adr_in <= stop) then
           req_out <= req_in;
           adr_out <= adr_in-start;
           enable   <= '1';
        else
            req_out <= '0';
            enable <= '0'; 
            adr_out <= (others => 'Z');
        end if;
    end process;

end arch;

