--------------------------------------------------------------------------------
-- Entity: UART
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : UART.vhd
-- Creation date     : 2011-05-27
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : <short description>
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-27   1.00     marcel     Creation of File
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART is
    generic(
        GEN_SysClockinHz    : integer                       := 33000000;
        GEN_Baudrate        : integer                       := 115200;       --! Baudrate to use 
	GEN_HasExternBaudLimit : boolean			    := false
    );
	port  (
		iSysClk 	: in  std_logic;
		ieClkEn     : in  std_logic;
		iReset		: in  std_logic;

		icBaudLExt   : in  integer := 0;
		
		icSend		: in  std_logic;
		idDataSend	: in  std_logic_vector(7 downto 0);
		ocSEmpty	: out std_logic;
		ocSFull		: out std_logic;
		ocSAlmostE	: out std_logic;
		ocSAlmostF	: out std_logic;
		
		odTransmit	: out std_logic;
		
		odDataRcvd	: out  std_logic_vector(7 downto 0);
		ocREmpty	: out std_logic;
		ocRFull		: out std_logic;
		ocRAlmostE	: out std_logic;
		ocRAlmostF	: out std_logic;
		icRReadEn	: in  std_logic;
		
		idReceive	: in  std_logic
	);
end UART;

architecture arch of UART is
	
--  component clkDivider is
--      generic(
--          GEN_FreqIn_Hz   : integer := 200000000;
--          GEN_FreqOut_Hz  : integer := 100000000
--      );
--      port ( 
--          iClk_in         : in  STD_LOGIC;
--          iReset          : in  STD_LOGIC;
--          oClk_out        : out STD_LOGIC);
--  end component;
	
	component clkEnable is
    generic(
        GEN_FreqIn_Hz   : integer := 200000000; --! signal description input clock frequency in Hz for <iClkIn>
        GEN_FreqOut_Hz  : integer := 100000000  --! signal description output clock frequency in Hz for <oClkEn>
    );
    port ( 
        iClkin         : in  STD_LOGIC;        --! signal description input clock
        iReset         : in  STD_LOGIC;        --! signal description synchronous reset (should be tied to '0')
        oeClkEn        : out STD_LOGIC         --! signal description output clockEnable
    );
    end component;

    component clkEnableProgrammable is
    port (
        iClkin         : in  STD_LOGIC;        --! input clock
        iReset         : in  STD_LOGIC;        --! synchronous reset (should be tied to '0')
        icLimit        : in  integer;        --! programmable limit value for generating the ClkEnable pulse
        oeClkEn        : out STD_LOGIC         --! output clockEnable
    );
    end component clkEnableProgrammable;
	
	component SenderAndFifo is
		port  (
			iSysClk 	: in  std_logic;
			ieClkEn     : in  std_logic;
			ieBaudClkEn	: in  std_logic;	
			iReset		: in  std_logic;
			
			icSend		: in  std_logic;
			idDataSend	: in  std_logic_vector(7 downto 0);
			ocSEmpty	: out std_logic;
			ocSFull		: out std_logic;
			ocSAlmostE	: out std_logic;
			ocSAlmostF	: out std_logic;
			
			odTransmit	: out std_logic
		);
	end component;
	
	component ReceiverAndFifo is
		port  (
			iSysClk 	: in  std_logic;
			ieClkEn     : in  std_logic;
			ie4xBaudClkEn	: in  std_logic;	
			iReset		: in  std_logic;
			
			odDataRcvd	: out  std_logic_vector(7 downto 0);
			ocREmpty	: out std_logic;
			ocRFull		: out std_logic;
			ocRAlmostE	: out std_logic;
			ocRAlmostF	: out std_logic;
			icRReadEn	: in  std_logic;
			
			idReceive	: in  std_logic
		);
	end component;
	
	signal seBauDSender		: std_logic;
	signal se4BaudReceiver  : std_logic;

	signal ExtBLimitx4	: integer;
		
begin


--  sendDivider : clkDivider 
--                  GENERIC MAP (
--                      GEN_FreqIn_Hz   => 4,
--                      GEN_FreqOut_Hz  => 1
--                  )
--                  PORT MAP(
--                      iClk_in     => i4xBaudClk,
--                      iReset      => '0',
--                      oClk_out    => sBAUDSender
--                  );
fixedBaudLimit : if GEN_HasExternBaudLimit = false generate	
	clkEnableSender : clkEnable 
    generic map(
        GEN_FreqIn_Hz   => GEN_SysClockinHz,
        GEN_FreqOut_Hz  => GEN_Baudrate
    )
    port map( 
        iClkin         => iSysClk,
        iReset         => '0',
        oeClkEn        => seBauDSender
    );
    
    clkEnableReceiver : clkEnable 
    generic map(
        GEN_FreqIn_Hz   => GEN_SysClockinHz,
        GEN_FreqOut_Hz  => 4 * GEN_Baudrate
    )
    port map( 
        iClkin         => iSysClk,
        iReset         => '0',
        oeClkEn        => se4BaudReceiver
    );
end generate;
	
extBaudLimit :  if GEN_HasExternBaudLimit = true generate
   clkEnableSender : clkEnableProgrammable
    port map(
        iClkin         => iSysClk,
        iReset         => '0',
	icLimit	       => icBaudLExt,
        oeClkEn        => seBauDSender
    );

    ExtBLimitx4 <= icBaudLExt / 4;
    clkEnableReceiver : clkEnableProgrammable
    port map(
        iClkin         => iSysClk,
        iReset         => '0',
	icLimit        => ExtBLimitx4,
        oeClkEn        => se4BaudReceiver
    );
end generate;

	SenderAndFifo1 : SenderAndFifo 
					PORT MAP (
						iSysClk 	=> iSysClk,
						ieClkEn     => ieClkEn,
						ieBaudClkEn	=> seBAUDSender,
						iReset		=> iReset,
						
						icSend		=> icSend,
						idDataSend	=> idDataSend,
						ocSEmpty	=> ocSEmpty,
						ocSFull		=> ocSFull,
						ocSAlmostE	=> ocSAlmostE,
						ocSAlmostF	=> ocSAlmostF,
						
						odTransmit	=> odTransmit
					);
	
	ReceiverAndFifo1 : ReceiverAndFifo 
					PORT MAP (
						iSysClk 	=> iSysClk,
						ieClkEn     => ieClkEn,
						ie4xBaudClkEn	=> se4BaudReceiver,
						iReset		=> iReset,
						
						odDataRcvd	=> odDataRcvd,
						ocREmpty	=> ocREmpty,
						ocRFull		=> ocRFull,
						ocRAlmostE	=> ocRAlmostE,
						ocRAlmostF	=> ocRAlmostF,
						icRReadEn	=> icRReadEn,
						
						idReceive	=> idReceive
					);
	
end arch;

