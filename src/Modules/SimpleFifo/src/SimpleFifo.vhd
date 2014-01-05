-------------------------------------------------------
--! @file 
--! @brief Simple Fifo, using the dual_port_block_ram to work on all FPGAs
--! @author Dominik Meyer
--! @email dmeyer@federationhq.de
--! @licence GPLv2
--! @date 2013-11-20
-------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use ieee.math_real.all;


--! Simple Fifo, using the dual_port_block_ram to work on all FPGAs

--! This is a very simple Fifo !
entity SimpleFifo is

    generic (
        GEN_WIDTH     : integer    := 8;        --! Data width of each data word
        GEN_DEPTH     : integer    := 256;      --! how many values can be stored in Fifo

        GEN_A_EMPTY : integer := 2;             --! when is the FIFO signaled as almost empty
        GEN_A_FULL  : integer := 250            --! when is the FIFO signaled as almost full

    );


port (
    odData       : out std_logic_vector(GEN_WIDTH-1 downto 0);      --! Data output of the fifo
    icReadClk    : in  std_logic;                                   --! read from fifo clock
    icReadEnable : in  std_logic;                                   --! we have read the value


    idData       : in  std_logic_vector(GEN_WIDTH-1 downto 0);      --! data input to fifo
    icWriteClk   : in  std_logic;                                   --! clock for writing to the fifo
    icWe         : in  std_logic;                                   --! write enable for writing to the fifo

    ocEmpty      : out std_logic;                                   --! signal fifo empty
    ocFull       : out std_logic;                                   --! signal fifo full
    ocAempty     : out std_logic;                                   --! signal fifo almost empty
    ocAfull      : out std_logic;                                   --! signal fifo almost full

    icClkEnable  : in  std_logic;                                   --! active high clock enable signal
    icReset      : in  std_logic                                    --! active high reset, values in RAM are not overwritten, just FIFO
                                                                    --! counters are resetted

);


end SimpleFifo;

architecture behavioral of SimpleFifo is

    component CDC_fifoIF
        generic (
            GEN_Data_size : integer
        );
        port (
            idData      : in std_logic_vector ( GEN_Data_size - 1 downto 0 );
            icWe        : in std_logic;
            ocFull      : out std_logic;
            icWriteClk  : in std_logic;
            odData      : out std_logic_vector ( GEN_Data_size - 1 downto 0 );
            ocDataAvail : out std_logic;
            icRe        : in std_logic;
            icReadClk   : in std_logic;
            icReset     : in std_logic
        );
    end component;


    component dual_port_block_ram
        generic (
            GEN_WIDTH     : integer;
            GEN_DEPTH     : integer;
            GEN_ADDR_SIZE : integer
        );
        port (
            icClkA  : in std_logic;
            icWeA   : in std_logic;
            icEnA   : in std_logic;
            idAddrA : in std_logic_vector ( GEN_ADDR_SIZE - 1 downto 0 );
            idDataA : in std_logic_vector ( GEN_WIDTH - 1 downto 0 );
            icClkB  : in std_logic;
            icEnB   : in std_logic;
            idAddrB : in std_logic_vector ( GEN_ADDR_SIZE - 1 downto 0 );
            odDataB : out std_logic_vector ( GEN_WIDTH - 1 downto 0 )
        );
    end component;


    --
    -- General Signals
    -- 
    signal scEmpty : std_logic;
    signal scFull  : std_logic;


    --
    -- Signals for CDC
    -- 
    signal sdRead2WriteIN   : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH)))) downto 0);
    signal sdRead2WriteOut  : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH)))) downto 0);
    signal scRead2WriteWe   : std_logic;
    signal scRead2WriteFull : std_logic;
    signal scRead2WriteDA   : std_logic;
    signal scRead2WriteRe   : std_logic;


    signal sdWrite2ReadIN   : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH)))) downto 0);
    signal sdWrite2ReadOUT  : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH)))) downto 0);
    signal scWrite2ReadWe   : std_logic;
    signal scWrite2ReadFull : std_logic;
    signal scWrite2ReadDA   : std_logic;
    signal scWrite2ReadRe   : std_logic;

    --
    -- Signals for the Read side
    -- 
    signal srReadAddr          : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH))))-1 downto 0);
    signal srReadOverflow      : std_logic;
    signal srWriteAddrRead     : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH))))-1 downto 0);
    signal srWriteOverflowRead : std_logic;

    signal srDataOut : std_logic_vector(GEN_WIDTH - 1 downto 0);
    signal sdDataOut : std_logic_vector(GEN_WIDTH - 1 downto 0);

    --
    -- Signals for the Write side
    --     
    signal srWriteAddr         : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH))))-1 downto 0);
    signal srWriteOverflow     : std_logic;
    signal srReadAddrWrite     : std_logic_vector(integer(ceil(log2(real(GEN_DEPTH))))-1 downto 0);
    signal srReadOverflowWrite : std_logic;


    -- signals for RAM
    signal scRAMwriteEnable : std_logic;


begin

    ocEmpty <= scEmpty;
    ocFull  <= scFull;


    scRAMwriteEnable <= not scFull and icWe;

    ram0 : dual_port_block_ram
    generic map(
        GEN_WIDTH     => GEN_WIDTH,
        GEN_DEPTH     => GEN_DEPTH,
        GEN_ADDR_SIZE => integer(ceil(log2(real(GEN_DEPTH))))
    )
    port map(
        icClkA  => icWriteClk,
        icWeA   => scRAMwriteEnable,
        icEnA   => icClkEnable,
        idAddrA => srWriteAddr,
        idDataA => idData,
        icClkB  => icWriteClk,
        icEnB   => icClkEnable,
        idAddrB => srReadAddr,
        odDataB => odData
    );

    scFull <= '1' when srWriteOverflow = '0' and srReadOverflowWrite = '0' and srWriteAddr - srReadAddrWrite >= GEN_DEPTH-1 else
               '1' when srWriteOverflow = '1' and srReadOverflowWrite = '0' and GEN_DEPTH-srReadAddrWrite+srWriteAddr >= GEN_DEPTH-1 else
               '1' when srWriteOverflow = '0' and srReadOverflowWrite = '1' and GEN_DEPTH-srReadAddrWrite+srWriteAddr >= GEN_DEPTH-1 else
               '1' when srWriteOverflow = '1' and srWriteOverflowRead = '1' and srWriteAddr - srReadAddrWrite >= GEN_DEPTH-1 else
               '0';

    scEmpty <= '1' when srWriteOverflowRead = '0' and srReadOverflow = '0' and srWriteAddrRead - srReadAddr = 0 else
               '1' when srWriteOverflowRead = '1' and srReadOverflow = '1' and srWriteAddrRead - srReadAddr = 0 else                
               '0';



    ocAfull <= '1' when srWriteOverflow = '0' and srReadOverflowWrite = '0' and srWriteAddr - srReadAddrWrite >= GEN_A_FULL else
               '1' when srWriteOverflow = '1' and srReadOverflowWrite = '0' and GEN_DEPTH-srReadAddrWrite+srWriteAddr >= GEN_A_FULL else
               '1' when srWriteOverflow = '0' and srReadOverflowWrite = '1' and GEN_DEPTH-srReadAddrWrite+srWriteAddr >= GEN_A_FULL else
               '1' when srWriteOverflow = '1' and srWriteOverflowRead = '1' and srWriteAddr - srReadAddrWrite >= GEN_A_FULL else
               '0';


    ocAempty                                                                                                       <= '1' when srWriteOverflow = '0' and srReadOverflowWrite = '0' and srWriteAddr - srReadAddrWrite <= GEN_A_EMPTY else
                '1' when srWriteOverflow = '1' and srReadOverflowWrite = '0' and GEN_DEPTH-srReadAddrWrite+srWriteAddr <= GEN_A_EMPTY else
                '1' when srWriteOverflow = '0' and srReadOverflowWrite = '1' and GEN_DEPTH-srReadAddrWrite+srWriteAddr <= GEN_A_EMPTY else
                '1' when srWriteOverflow = '1' and srWriteOverflowRead = '1' and srWriteAddr - srReadAddrWrite         <= GEN_A_EMPTY else
                '0';


    -- write FSM
    Writefsm : process(icWriteClk)
    begin
        if (rising_edge(icWriteClk)) then
            if (icReset = '1') then

                srWriteAddr     <= (others => '0');
                srWriteOverflow <= '0';

                srReadAddrWrite     <= (others => '0');
                srReadOverflowWrite <= '0';

            elsif (icClkEnable = '1') then

                if (scWrite2ReadFull = '0') then
                    scWrite2ReadWe <= '1';
                else
                    scWrite2ReadWe <= '0';
                end if;

                if (scRead2WriteDA = '1') then
                    scRead2WriteRe      <= '1';
                    srReadAddrWrite     <= sdRead2WriteOUT(integer(ceil(log2(real(GEN_DEPTH)))) downto 1);
                    srReadOverflowWrite <= sdRead2WriteOUT(0);
                else
                    scRead2WriteRe <= '0';
                end if;

                if (icWe = '1' and scFull = '0') then
                    if (srWriteAddr >= GEN_DEPTH-1 ) then
                        srWriteAddr     <= (others => '0');
                        srWriteOverflow <= not srWriteOverflow;
                    else
                        srWriteAddr <= srWriteAddr + 1;
                    end if;
                end if;

            end if;
        end if;
    end process;


    cdcWrite2Read : CDC_fifoIF
    generic map(
        GEN_Data_size => integer(ceil(log2(real(GEN_DEPTH))))+1
    )
    port map(
        idData      => sdWrite2ReadIN,
        icWe        => scWrite2ReadWe,
        ocFull      => scWrite2ReadFull,
        icWriteClk  => icWriteClk,
        odData      => sdWrite2ReadOUT,
        ocDataAvail => scWrite2ReadDA,
        icRe        => scWrite2ReadRe,
        icReadClk   => icReadClk,
        icReset     => icReset
    );


    sdWrite2ReadIN <= srWriteAddr & srWriteOverflow;





    -- write FSM
    Readfsm : process(icReadClk)
    begin
        if (rising_edge(icReadClk)) then
            if (icReset = '1') then

                srReadAddr          <= (others => '0');
                srWriteAddrRead     <= (others => '0');
                srWriteOverflowRead <= '0';
                srReadOverflow      <= '0';

            elsif (icClkEnable = '1') then

                if (scRead2WriteFull = '0') then
                    scRead2WriteWe <= '1';
                else
                    scRead2WriteWe <= '0';
                end if;

                if (scWrite2ReadDA = '1') then
                    scWrite2ReadRe      <= '1';
                    srWriteAddrRead     <= sdWrite2ReadOUT(integer(ceil(log2(real(GEN_DEPTH)))) downto 1);
                    srWriteOverflowRead <= sdWrite2ReadOut(0);
                else
                    scWrite2ReadRe <= '0';
                end if;

                if (icReadEnable = '1' and scEmpty = '0') then
                    if (srReadAddr  >= GEN_DEPTH-1) then
                        srReadAddr     <= (others => '0');
                        srReadOverflow <= not srReadOverflow;
                    else
                        srReadAddr <= srReadAddr + 1;
                    end if;
                end if;

            end if;
        end if;
    end process;


    cdcRead2Write : CDC_fifoIF
    generic map(
        GEN_Data_size => integer(ceil(log2(real(GEN_DEPTH))))+1
    )
    port map(
        idData      => sdRead2WriteIN,
        icWe        => scRead2WriteRe,
        ocFull      => scRead2WriteFull,
        icWriteClk  => icWriteClk,
        odData      => sdRead2WriteOut,
        ocDataAvail => scRead2WriteDA,
        icRe        => scRead2WriteRe,
        icReadClk   => icReadClk,
        icReset     => icReset
    );



    sdRead2WriteIN <= srReadAddr & srReadOverflow;



end behavioral;
