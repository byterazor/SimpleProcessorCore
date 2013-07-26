--------------------------------------------------------------------------------
-- Entity: ClkEnable
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          :  ClkEnable.vhd
-- Creation date     :  2012-04-06
-- Author(s)         :  marcel eckert (eckert@hsu-hh.de)
--------------------------------------------------------------------------------
--! @file
--! @brief Implements a generic ClkEnable generator
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--! brief Implements a generic ClkEnable generator

--! detailed Implements a generic ClkEnable generator. Based on an input frequency
--! <GEN_FreqIn_Hz>, an output enable (1 <GEN_FreqIn_Hz> period) is generated every 
--! <GEN_FreqOut_Hz> periods

entity clkEnable is
    generic(
        GEN_FreqIn_Hz   : integer := 200000000; --! signal description input clock frequency in Hz for <iClkIn>
        GEN_FreqOut_Hz  : integer := 100000000  --! signal description output clock frequency in Hz for <oClkEn>
    );
    port ( 
        iClkin         : in  STD_LOGIC;        --! signal description input clock
        iReset         : in  STD_LOGIC;        --! signal description synchronous reset (should be tied to '0')
        oeClkEn        : out STD_LOGIC         --! signal description output clockEnable
    );
end clkEnable;

architecture Behavioral of clkEnable is
    constant cLimit : integer := GEN_FreqIn_Hz / GEN_FreqOut_Hz;
    signal sCounter : integer range 0 to (cLimit-1) := 0;
    signal seClkEn   : STD_LOGIC := '1';
begin

    process (iClkIn)
    begin            
        if (rising_edge(iClkIn)) then
            if (iReset = '1') then
                sCounter    <= 0;
                seClkEn    <= '1';
                
            elsif (sCounter = (cLimit-1)) then
                sCounter    <= 0;
                seClkEn     <= '1';
                
            else
                sCounter    <= sCounter + 1;
                seClkEn     <= '0'; 
            end if;
            
        end if;
        
    end process;
    
    oeClkEn <= seClkEn;

end Behavioral;

