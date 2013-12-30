-------------------------------------------------------
--! @file 
--! @brief Fetch/Decode Component  for the Simple Processor Core (Geraffel Processor)
--! @author Dominik Meyer/ Marcel Eckert
--! @email dmeyer@federationhq.de
--! @licence GPLv2
--! @date unknown
-------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
    use work.cpupkg.all;

--! Fetch/Decode Component for the Simple Processor Core (Geraffel Processor)
--! 
--! This Code is based on a processor core used at the Helmut Schmidt University for
--! educational purposes.
--!

entity FetchDecode is
    port(

        iClk          : in  std_logic;                       --! main system clock
        iReset        : in  std_logic;                       --! system active high reset

        idData        : in  DATA;                            --! Data input coming from the RAM with instruction
        icAddrSel     : in  std_logic;                       --! Put AddressRegister to Address BUS
        icDecodeInstr : in  std_logic;                       --! Decode the loaded instrcution
        icJump        : in  std_logic;                       --! executed instruction is a jump, put jump register to address bus
        icNextPC      : in  std_logic;                       --! increment the PC
        odPC          : out ADDRESS;                         --! put out the current PC
        idPC          : in  ADDRESS;                         --! input for a new PC from extern
        icUsePC       : in  std_logic;                       --! use the external PC
        odAddress     : out ADDRESS;                         --! output to the address bus
        odImmidiate   : out DATA;                            --! output the loaded immediate
        odRegAsel     : out std_logic_vector(4 downto 0);    --! output the decoded register addr
        odRegBsel     : out std_logic_vector(4 downto 0);    --! output the decoded register addr
        odRegINsel    : out std_logic_vector(4 downto 0);    --! output the decoded result register addr
        ocOperation   : out OPTYPE                           --! output which operation to perform

    );
end FetchDecode;

architecture Behavioral of FetchDecode is
    signal sdPC, sdPC_next              : ADDRESS;
    signal sdAdr, sdAdr_next            : ADDRESS;
    signal sdImmidate, sdImmidiate_next : DATA;

    signal sdRegAsel, sdRegAsel_next   : std_logic_vector(4 downto 0);
    signal sdRegBsel, sdRegBsel_next   : std_logic_vector(4 downto 0);
    signal sdRegINsel, sdRegINsel_next : std_logic_vector(4 downto 0);

    signal scOp, scOp_next : OPTYPE;

begin

    Transition : process(idData, sdImmidate, icDecodeInstr, icJump, icNextPC, sdAdr, sdPC, scOp, sdRegAsel, sdRegBsel, sdRegINsel, icUsePC, idPC)
    begin

        -- default values for all signals/registers
        sdAdr_next       <= sdAdr;
        sdPC_next        <= sdPC;
        scOp_next        <= scOp;
        sdImmidiate_next <= sdImmidate;

        -- fill the next register values with the old ones
        sdRegAsel_next  <= sdRegAsel;
        sdRegBsel_next  <= sdRegBsel;
        sdRegINsel_next <= sdRegINsel;

        --! ISA Definition, for the Decode run
        if (icDecodeInstr = '1') then

            -- because of the fixed bit positions we can fill in the correct values to the next register values
            sdAdr_next       <= idData(15 downto 0);
            sdImmidiate_next <= "0000000000000000" & idData(15 downto 0);
            sdRegINsel_next  <= idData(25 downto 21);
            sdRegAsel_next   <= idData(20 downto 16);
            sdRegBsel_next   <= idData(15 downto 11);


            -- select the operation to do according to the decoded opcode
            case idData(31 downto 26) is
                when "000000" => scOp_next <= shl;
                when "000001" => scOp_next <= shr;
                when "000010" => scOp_next <= sto;
                when "000011" => scOp_next <= loa;
                when "000100" => scOp_next <= add;
                when "000101" => scOp_next <= sub;
                when "000110" => scOp_next <= addc;
                when "000111" => scOp_next <= subc;
                when "001000" => scOp_next <= opor;
                when "001001" => scOp_next <= opand;
                when "001010" => scOp_next <= opxor;
                when "001011" => scOp_next <= opnot;
                when "001100" => scOp_next <= jpz;
                when "001101" => scOp_next <= jpc;
                when "001110" => scOp_next <= jmp;
                when "001111" => scOP_next <= li;
                when "010000" => scOp_next <= jmc;
                when "010001" => scOp_next <= ret;
                when others   => scOp_next <= hlt;
            end case;
        end if;

        -- set registers according of some special external control signals
        if (icUsePC = '1') then
            sdPC_next <= idPC;
        end if;

        if (icJump = '1') then
            sdPC_next <= sdAdr;

        end if;

        if (icNextPC = '1') then
            sdPC_next <= sdPC + '1';
        end if;


    end process;


    -- Execute Transition, set register values to the calculated next register values
    process(iClk, iReset)
    begin
        if (iReset = '1') then
            sdPC       <= (others => '0');
            sdAdr      <= (others => '0');
            sdImmidate <= (others => '0');
            sdRegAsel  <= (others => '0');
            sdRegBsel  <= (others => '0');
            sdRegINsel <= (others => '0');

            scOp <= hlt;

        elsif (rising_edge(iClk)) then
            sdPC       <= sdPC_next;
            sdAdr      <= sdAdr_next;
            scOp       <= scOp_next;
            sdImmidate <= sdImmidiate_next;
            sdRegAsel  <= sdRegAsel_next;
            sdRegBsel  <= sdRegBsel_next;
            sdRegINsel <= sdRegINsel_next;
        end if;

    end process;

    -- Output everything to the correct output signal
    odAddress <= idPC  when icUsePC = '1' else
                   sdAdr when icAddrSel = '0' and icDecodeInstr = '0' else
                   sdAdr_next when icAddrSel = '0' and icDecodeInstr = '1' else
                   sdPC; -- addr_sel = '1'

    odPC <= sdPC;

    ocOperation <= scOp when icDecodeInstr = '0' else
                        scOp_next;                

    odImmidiate <= sdImmidate when icDecodeInstr = '0' else sdImmidiate_next;

    odRegAsel  <= sdRegAsel  when icDecodeInstr = '0' else sdRegAsel_next;
    odRegBsel  <= sdRegBsel  when icDecodeInstr = '0' else sdRegBsel_next;
    odRegINsel <= sdRegINsel when icDecodeInstr = '0' else sdRegINsel_next;


end Behavioral;
