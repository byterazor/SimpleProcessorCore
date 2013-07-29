-------------------------------------------------------
--! @file 
--! @brief <short description>
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @date 2013-07-18
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.cpupkg.all;

entity MMIO_Uart is
    generic (
        GEN_start   :   std_logic_vector(15 downto 0) := x"FFF0";
        GEN_SysClockinHz : integer := 100000000;
        GEN_Baudrate : integer := 57600;
        GEN_HasExternBaudLimit : boolean := true
    );
    port  (
        
        odRS232         :   out std_logic;
        idRS232         :    in std_logic;
        
        ocInterrupt     :   out std_logic;          --! high if data is available
        
        odDebug         :   out std_logic_vector(7 downto 0);
        
        
        iClk            :   in      std_logic;
        iReset          :   in  std_logic;
        bdData          :   inout   DATA;       --! connection to databus
        idAddress       :   in      ADDRESS;        --! connection to addressbus
        icEnable        :   in  std_logic;      --! enable or disable RAM
        icRnotW         :   in      std_logic       --! read/write control
    );
end MMIO_Uart;

architecture arch of MMIO_Uart is
    
        component UART
        generic (
            GEN_SysClockinHz : integer;
            GEN_Baudrate : integer;
            GEN_HasExternBaudLimit : boolean
        );
        port (
            iSysClk : in std_logic;
            ieClkEn : in std_logic;
            iReset : in std_logic;
            icBaudLExt : in integer;
            icSend : in std_logic;
            idDataSend : in std_logic_vector ( 7 downto 0 );
            ocSEmpty : out std_logic;
            ocSFull : out std_logic;
            ocSAlmostE : out std_logic;
            ocSAlmostF : out std_logic;
            odTransmit : out std_logic;
            odDataRcvd : out std_logic_vector ( 7 downto 0 );
            ocREmpty : out std_logic;
            ocRFull : out std_logic;
            ocRAlmostE : out std_logic;
            ocRAlmostF : out std_logic;
            icRReadEn : in std_logic;
            idReceive : in std_logic
        );
    end component;

    
    
    signal srTransmit    :   std_logic_vector(31 downto 0);
    signal srReceive     :   std_logic_vector(31 downto 0);
    signal srStatus      :   std_logic_vector(31 downto 0);
    signal srBaud        :   std_logic_vector(31 downto 0);
    signal scBaud        :   integer;
    
    
    signal tData            : DATA;
    
    --
    -- UART
    -- 
    signal scUARTsend, scUartReadEnable     :   std_logic;
    signal scUARTSempty, scUARTSfull        :   std_logic; 
    signal scUARTSalmostE, scUARTSalmostF   :   std_logic;
    signal scUARTRempty, scUARTRfull        :   std_logic; 
    signal scUARTRalmostE, scUARTRalmostF   :   std_logic;
    
    
    --
    -- FSM
    -- 
    type states is (st_start, st_idle, st_read, st_write);
    signal current_state : states;
    
begin
    
    scBaud  <=  to_integer(unsigned(srBaud));
    
    odDebug <= scUARTRempty & srReceive(6 downto 0);
    
    uart0: UART
    generic map(
        GEN_SysClockinHz       => GEN_SysClockinHz,
        GEN_Baudrate           => GEN_Baudrate,
        GEN_HasExternBaudLimit => GEN_HasExternBaudLimit
    )
    port map(
        iSysClk                => iClk,
        ieClkEn                => '1',
        iReset                 => iReset,
        icBaudLExt             => scBaud,
        icSend                 => scUARTsend,
        idDataSend             => srTransmit(7 downto 0),
        ocSEmpty               => scUARTSempty,
        ocSFull                => scUARTSfull,
        ocSAlmostE             => scUARTSalmostE,
        ocSAlmostF             => scUARTSalmostF,
        odTransmit             => odRS232,
        odDataRcvd             => srReceive(7 downto 0),
        ocREmpty               => scUARTRempty,
        ocRFull                => scUARTRfull,
        ocRAlmostE             => scUARTRalmostE,
        ocRAlmostF             => scUARTRalmostF,
        icRReadEn              => scUartReadEnable,
        idReceive              => idRS232
    );
    
    srStatus    <= scUARTRempty & scUARTRfull &  scUARTRalmostE & scUARTRalmostF & scUARTSempty & scUARTSfull & scUARTSalmostE & scUARTSalmostF & x"000000";
    
    ocInterrupt <= not scUARTRempty;
    
    process(iClk, iReset)
    begin
        if (iReset = '1') then
            srBaud          <= (others=>'0');
            srTransmit      <= x"00000000";
            srReceive(30 downto 8)       <= (others=>'0');
            
            current_state   <= st_start;
            
        elsif (rising_edge(iClk)) then
            case current_state is
                when st_start   =>
                                    scUARTsend          <= '0';
                                    scUartReadEnable    <= '0';
                                    
                                    current_state       <= st_idle;
                when st_idle    =>
                                    if (icEnable = '1' and idAddress >= GEN_start and idAddress <= GEN_start + 2) then
                                        
                                        -- Status Register
                                        if (idAddress = GEN_start) then
                                            if (icRnotW = '0') then

                                                scUARTsend          <= '0';
                                                scUartReadEnable    <= '0';
                                    
                                    
                                                current_state       <= st_write;
                                                
                                            else
                                                
                                                scUARTsend          <= '0';
                                                scUartReadEnable    <= '0';
                                    
                                    
                                                current_state       <= st_read;
                                            end if;
                                        -- Transmit Register    
                                        elsif(idAddress = GEN_start+1) then
                                            if (icRnotW = '0') then
                                                srTransmit  <= bdData;
                                                
                                                scUARTsend          <= '1';
                                                scUartReadEnable    <= '0';
                                    
                                    
                                                current_state       <= st_write;
                                                
                                            else
                                                tData   <= (others=>'0');
                                                
                                                scUARTsend          <= '0';
                                                scUartReadEnable    <= '0';
                                    
                                    
                                                current_state       <= st_read;
                                            end if;    
                                        
                                        -- receive Register    
                                        elsif(idAddress = GEN_start+2) then
                                            if (icRnotW = '0') then
                                                
                                                scUARTsend          <= '0';
                                                scUartReadEnable    <= '0';
                                    
                                                
                                                current_state       <= st_write;
                                                
                                            else
                                                tData   <= srReceive;
                                                
                                                scUARTsend          <= '0';
                                                scUartReadEnable    <= '1';
                                    
                                    
                                                current_state       <= st_read;
                                            end if;    
                                        end if;
                                        
                                    else
                                        scUARTsend          <= '0';
                                        scUartReadEnable    <= '0';
                                        
                                        current_state   <= st_idle;
                                    end if;
                when st_read    =>
                                    scUARTsend          <= '0';
                                    scUartReadEnable    <= '0';
                                        
                                    current_state   <= st_idle;
                                    
                when st_write   =>  
                                    scUARTsend          <= '0';
                                    scUartReadEnable    <= '0';
                                        
                                    current_state   <= st_idle;          
            end case;
        end if;
    end process;     


    bdData <= srStatus  when icRnotW = '1' and idAddress=GEN_start else
              srReceive when icRnotW = '1' and idAddress=GEN_start+2 else
                    (others => 'Z');

end arch;







































