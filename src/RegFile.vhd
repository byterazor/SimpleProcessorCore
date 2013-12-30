-------------------------------------------------------
--! @file 
--! @brief RegisterFile for the Simple Processor Core (Geraffel Processor)
--! @author Dominik Meyer
--! @email dmeyer@federationhq.de
--! @licence GPLv2
--! @date unknown
-------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.all;

library work;
    use work.cpupkg.all;
    use ieee.numeric_std.all;

--! RegisterFile for the Simple Processor Core (Geraffel Processor)
--! 
--! This Code is based on a processor core used at the Helmut Schmidt University for
--! educational purposes.
--!

entity RegFile is
    port(
        iClk        : in    std_logic;                       --! main sytem clock signal
        iReset      : in    std_logic;                       --! main system active high reset

        icRegAsel   : in    std_logic_vector(4 downto 0);    --! address of register A
        icRegBsel   : in    std_logic_vector(4 downto 0);    --! address of register B
        odRegA      : out   DATA;                            --! output of the register A Value
        odRegB      : out   DATA;                            --! output of the register B Value

        icPC        : in    std_logic;                       --! select the PC Input as the input value, required for ret instruction
        idPC        : in    DATA;                            --! input of the PC, required for the ret instruction

        icRegINsel  : in    std_logic_vector(4 downto 0);    --! address of the register to which to save the input

        idDataIn    : in    DATA;                            --! data input, normally from the ALU
        idCarryIn   : in    std_logic;                           --! Carry Flag of the last Operation
        idZeroIn    : in    std_logic;                       --! Zero Flag of the last Operation

        icLoadEn    : in    std_logic;                       --! actually save the input Data to the selected register

        odCarryOut  : out   std_logic;                       --! output of the currently saved carry flag
        odZeroOut   : out   std_logic                        --! output of the currently saved zero flag
    );
end RegFile;

architecture Behavioral of RegFile is

    type registerFileType is array (0 to 31) of DATA;
    signal registerFile : registerFileType;

    signal sdData  : DATA;
    signal sdCarry : std_logic;
    signal sdZero  : std_logic;
begin





    -- Execute Transition
    process(iClk, iReset)
    begin
        if (iReset = '1') then
            for i in 31 downto 0 loop
                registerFile(i) <= (others => '0');
            end loop;

            sdCarry <= '0';
            sdZero  <= '0';

        elsif (rising_edge(iClk)) then
            if (icLoadEn = '1') then
                if (icPC = '0') then
                    registerFile(to_integer(unsigned(icRegINsel))) <= idDataIn;
                else
                    registerFile(to_integer(unsigned(icRegINsel))) <= idPC;
                end if;
                sdCarry <= idCarryIn;
                sdZero  <= idZeroIn;

            end if;

        end if;

    end process;


    odRegA     <= registerFile(to_integer(unsigned(icRegAsel)));
    odRegB     <= registerFile(to_integer(unsigned(icRegBsel)));
    odCarryOut <= sdCarry;
    odZeroOut  <= sdZero;

end Behavioral;
