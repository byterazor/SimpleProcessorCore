-------------------------------------------------------
--! @file 
--! @brief the control unit for the Simple Processor Core (Geraffel Processor)
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @licence GPLv2
--! @date 2010-11-19
-------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

library work;
    use work.cpupkg.all;


--! the control unit for the Simple Processor Core (Geraffel Processor)
--! 
--! This Code is based on a processor core used at the Helmut Schmidt University for
--! educational purposes.
--!

entity ControlUnit is
    port  (
        iClk         : in     std_logic;        --! iClk signal
        iReset       : in     std_logic;        --! iReset signal
        icOpCode     : in     optype;           --! icOpCode bus
        idCarry      : in     std_logic;        --! carry from register file
        idZero       : in     std_logic;        --! zero flag from register file
        ocRnotWRam   : out    std_logic;        --! r_notw to RAM
        ocLoadEn     : out    std_logic;        --! safe result of alu
        ocEnableRAM  : out    std_logic;        --! put akku on databus
        ocLoadInstr  : out    std_logic;        --! load instruction control signal
        ocNextPC     : out    std_logic;        --! increment pc
        ocAddrSel    : out    std_logic;        --! pc on addressbus
        ocJump       : out    std_logic;        --! do a ocJump
        ocPCregister : out    std_logic;        --! put PC to register File
        ocUsePC      : out    std_logic;        --! use Register to fill in the PC
        ocLoad       : out    std_logic         --! put databus to ALU immediate port
    );
end ControlUnit;

architecture arch of ControlUnit is

    type STATES    is (load, decode, exshl, exshr, exsto, exloa, exloa2, exli, exadd, exsub, exaddc, exsubc,
        exopor, exopand, exopxor, exopnot, exjpz, exjpc, exjmp, exhlt, exjmc, exret);

    signal sState, sState_next : STATES;

begin


--! switch sStates if needed
    sState_change : process(iClk,iReset)
    begin
        if (iReset = '1') then

            sState <= load;

        elsif (rising_edge(iClk)) then
            sState <= sState_next;
        end if;
    end process;


--! calculate the next state of the FSM
    calc_sState_next : process(sState, icOpCode, idCarry, idZero)
    begin

        case sState is
            when load    =>
                sState_next <= decode;
            when decode    =>
                case icOpCode is
                    when shl   => sState_next <= exshl;
                    when shr   => sState_next <= exshr;
                    when sto   => sState_next <= exsto;
                    when loa   => sState_next <= exloa;
                    when li    => sState_next <= exli;
                    when add   => sState_next <= exadd;
                    when sub   => sState_next <= exsub;
                    when addc  => sState_next <= exaddc;
                    when subc  => sState_next <= exsubc;
                    when opand => sState_next <= exopand;
                    when opor  => sState_next <= exopor;
                    when opxor => sState_next <= exopxor;
                    when opnot => sState_next <= exopnot;
                    when jpz   => 
                        if (idZero = '1') then
                            sState_next <= exjpz;
                        else
                            sState_next <= load;
                        end if;
                    when jpc => 
                        if (idCarry = '1') then
                            sState_next <= exjpc;
                        else
                            sState_next <= load;
                        end if;
                    when jmp => sState_next <= exjmp;
                    when jmc => sState_next <= exjmc;
                    when ret => sState_next <= exret;
                    when hlt => sState_next <= exhlt;
                end case;
            when exhlt  => sState_next <= exhlt;
            when exloa  => sState_next <= exloa2;
            when others => sState_next <= load;
        end case;

    end process;



--! calculate the  output in each sState
    calc_output : process(sState)
    begin

        case sState is

            when load     =>
                ocRnotWRam   <= '1';    -- read from RAM
                ocLoadEn     <= '0';    -- do not save result
                ocEnableRAM  <= '1';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- load instruction
                ocNextPC     <= '0';    -- do not increment pc
                ocAddrSel    <= '1';    -- pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when decode    =>
                ocRnotWRam   <= '1';    -- read from RAM
                ocLoadEn     <= '0';    -- do not save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '1';    -- load instruction
                ocNextPC     <= '1';    -- do not increment pc
                ocAddrSel    <= '0';    -- pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exshl    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exshr    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exsto    =>
                ocRnotWRam   <= '0';    -- write to RAM
                ocLoadEn     <= '0';    -- do not save result
                ocEnableRAM  <= '1';    -- put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exloa    =>
                ocRnotWRam   <= '1';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '1';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';


            when exli    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exadd    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exsub    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exaddc    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';
            when exloa2    =>
                ocRnotWRam   <= '1';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '1';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '1';

            when exsubc    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exopor    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exopand =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exopxor =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exopnot =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exjpz     =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '0';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '1';    -- ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exjpc     =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '0';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '1';    -- ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exjmp    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '0';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '1';    -- ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exjmc    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '1';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '1';    -- ocJump
                ocPCregister <= '1';    -- put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when exret    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '0';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- ocJump
                ocPCregister <= '0';    -- put PC to register File
                ocUsePC      <= '1';
                ocLoad       <= '0';

            when exhlt    =>
                ocRnotWRam   <= '0';    -- read from RAM
                ocLoadEn     <= '0';    -- save result
                ocEnableRAM  <= '0';    -- do not put akku on databus
                ocLoadInstr  <= '0';    -- do not load instruction
                ocNextPC     <= '0';    -- increment pc
                ocAddrSel    <= '0';    -- no pc on addressbus
                ocJump       <= '0';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

            when others =>
                ocRnotWRam   <= '-';    -- read from RAM
                ocLoadEn     <= '-';    -- save result
                ocEnableRAM  <= '-';    -- do not put akku on databus
                ocLoadInstr  <= '-';    -- do not load instruction
                ocNextPC     <= '-';    -- increment pc
                ocAddrSel    <= '-';    -- no pc on addressbus
                ocJump       <= '-';    -- no ocJump
                ocPCregister <= '0';    -- do not put PC to register File
                ocUsePC      <= '0';
                ocLoad       <= '0';

        end case;

    end process;


end arch;
