-------------------------------------------------------
--! @file 
--! @brief Clock Domain Crossing Module
--! @author Dominik Meyer
--! @email dmeyer@federationhq.de
--! @date 2013-04-30
-------------------------------------------------------


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;


--! Clock Domain Crossing Module

--! This component can be used to cross clock domain borders.
--! It is using a handshake protocol to make sure the data
--! has travelled across the border
entity CDC_fifoIF is
    generic (
        GEN_Data_size : integer := 8
    );
    port  (

        idData     : in  std_logic_vector(GEN_Data_size-1 downto 0); --! data we want to send cross clock domains
        icWe       : in  std_logic;                                  --! data should be written to the other side
        ocFull     : out std_logic;                                  --! module currently holds data
        icWriteClk : in  std_logic;                                  --! write clock


        odData      : out std_logic_vector(GEN_Data_size-1 downto 0); --! data from the other side
        ocDataAvail : out std_logic;                                  --! data is available from module
        icRe        : in  std_logic;                                  --! ReadEnable signal
        icReadClk   : in  std_logic;                                  --! Read Clock

        icReset : in  std_logic                                  --! synchronous active high reset, triggered by the Write Clock, has to ne high at least 4 clock ticks
    );
end CDC_fifoIF;

architecture arch of CDC_fifoIF is


    signal srDataIn  : std_logic_vector(GEN_Data_size-1 downto 0);
    signal srDataOut : std_logic_vector(GEN_Data_size-1 downto 0);
    signal scEnable  : std_logic;

    signal scWEnableBuf  : std_logic;
    signal scWEnableBuf2 : std_logic;
    signal scREnableBuf  : std_logic;
    signal scREnableBuf2 : std_logic;
    signal scREnableBuf3 : std_logic;
    signal scREnable     : std_logic;

    signal scDataAvail : std_logic;


    -- 
    -- Input FSM
    -- 
    type INPUT_STATES is (s_start, s_idle, s_hold);
    signal input_state : INPUT_STATES;

begin

    ocFull      <= scEnable or scREnableBuf3 or scREnableBuf2;
    ocDataAvail <= (icRe or scDataAvail) and not scREnable;


    input : process(icWriteClk)
    begin
        if (rising_edge(icWriteClk)) then
            if (icReset = '1') then

                srDataIn      <= (others => '0');
                scEnable      <= '0';
                scREnableBuf  <= '0';
                scREnableBuf2 <= '0';
                scREnableBuf3 <= '0';

            else

                if (icWe = '1') then
                    srDataIn <= idData;
                    scEnable <= '1';
                elsif (scREnableBuf3 = '1') then
                    scEnable <= '0';
                else
                    scEnable <= scEnable;
                end if;

                scREnableBuf  <= scREnable;
                scREnableBuf2 <= scREnableBuf;
                scREnableBuf3 <= scREnableBuf2;

            end if;
        end if;
    end process;




    output : process(icReadClk)
    begin
        if (rising_edge(icReadClk)) then
            if (icReset = '1') then
                scWEnableBuf  <= '0';
                scWEnableBuf2 <= '0';
                scDataAvail   <= '0';
                srDataOut     <= (others => '0');
                scREnable     <= '0';
            else

                if (icRe = '1') then
                    scREnable <= '1';
                elsif (scDataAvail = '0') then
                    scREnable <= '0';
                end if;

                if (scWEnableBuf2 = '1') then
                    srDataOut <= srDataIn;
                else
                    srDataOut <= srDataOut;
                end if;


                scWEnableBuf  <= scEnable;
                scWEnableBuf2 <= scWEnableBuf;
                scDataAvail   <= scWEnableBuf2;

            end if;
        end if;
    end process;

    odData <= srDataOut;

end arch;
