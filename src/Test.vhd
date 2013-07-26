--------------------------------------------------------------------------------
-- Entity: Test
-- Date:2013-07-18  
-- Author: byterazor     
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Test is
	port  (
	    idRS232    : in    std_logic;
	    odRS232    : out   std_logic;
	    icReset    : in    std_logic;
		icClk      : in    std_logic        -- input clock, xx MHz.
	);
end Test;

architecture arch of Test is

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


begin

    uart0: UART
    generic map(
        GEN_SysClockinHz       => 100000000,
        GEN_Baudrate           => GEN_Baudrate,
        GEN_HasExternBaudLimit => GEN_HasExternBaudLimit
    )
    port map(
        iSysClk                => iSysClk,
        ieClkEn                => ieClkEn,
        iReset                 => iReset,
        icBaudLExt             => icBaudLExt,
        icSend                 => icSend,
        idDataSend             => idDataSend,
        ocSEmpty               => ocSEmpty,
        ocSFull                => ocSFull,
        ocSAlmostE             => ocSAlmostE,
        ocSAlmostF             => ocSAlmostF,
        odTransmit             => odTransmit,
        odDataRcvd             => odDataRcvd,
        ocREmpty               => ocREmpty,
        ocRFull                => ocRFull,
        ocRAlmostE             => ocRAlmostE,
        ocRAlmostF             => ocRAlmostF,
        icRReadEn              => icRReadEn,
        idReceive              => idReceive
    );
    

end arch;

