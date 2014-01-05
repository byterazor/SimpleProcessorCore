-------------------------------------------------------
--! @file 
--! @brief dual port block ram description - write to one port, read from the other
--! @author Dominik Meyer
--! @email dmeyer@federationhq.de
--! @licence GPLv2
--! @date 2013-11-20
-------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


--! dual port block ram description - write to one port, read from the other

--! dual port block ream description
--! Port A is used for writing to the ram, while Port B is used for reading only.
--! written in a way that the Xilinx Tools will use the onboard block ram
--! if available, otherwise using logic cells
entity dual_port_block_ram is

    generic (
        GEN_WIDTH         : integer    := 8;        --! the width of one data word
        GEN_DEPTH         : integer := 256;         --! how many words should be storeable in the ram
        GEN_ADDR_SIZE     : integer := 8            --! how many address bits shall be used

    );


    port (
        icClkA          : in    std_logic;                                      --! clock for port A
        icWeA           : in    std_logic;                                      --! active high write enable for port A
        icEnA           : in    std_logic;                                      --! active high enable for port A
        idAddrA         : in    std_logic_vector(GEN_ADDR_SIZE - 1 downto 0);   --! address for port A
        idDataA         : in    std_logic_vector(GEN_WIDTH - 1 downto 0);       --! data input for port A

        icClkB          : in    std_logic;                                      --! clock for port B
        icEnB           : in    std_logic;                                      --! active high enable signal for port B
        idAddrB         : in    std_logic_vector(GEN_ADDR_SIZE - 1 downto 0);   --! address for port B
        odDataB         : out   std_logic_vector(GEN_WIDTH - 1 downto 0)        --! data output of port B

    );

end dual_port_block_ram;

architecture behavioral of dual_port_block_ram is

    type ramType is array (0 to GEN_DEPTH-1) of std_logic_vector(GEN_WIDTH-1 downto 0);
    signal ram : ramType := (others => (others => '0'));

    signal sdDataOut     : std_logic_vector(GEN_WIDTH-1 downto 0);

begin

    portA : process(icClkA)
    begin
        if (rising_edge(icClkA)) then
            if (icEnA = '1') then
                if (icWeA = '1') then
                    ram(conv_integer(idAddrA)) <= idDataA;
                end if;
            end if;
        end if;
    end process;



    portB : process(icClkB)
    begin
        if (rising_edge(icClkB)) then
            if (icEnB = '1') then
                sdDataOut     <= ram(conv_integer(idAddrB));
            end if;
        end if;

    end process;

    odDataB     <= sdDataOut;
    
end behavioral;
