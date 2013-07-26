--------------------------------------------------------------------------------
-- Entity: ReceiverAndFifo
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : ReceiverAndFifo.vhd
-- Creation date     : 2011-05-31
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : implements an RS232 Receiver with additional Fifo
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-31   1.00     marcel     Creation of File
--------------------------------------------------------------------------------
--! brief
--! implements an RS232 Receiver with additional Fifo

--! detailed
--! implements an RS232 Receiver with additonal Fifo (8 Bit data width, 4k data depth)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ReceiverAndFifo is
	port  (
		iSysClk 	: in  std_logic;						--! signal description System side clock
		ieClkEn     : in  std_logic;
		ie4xBaudClkEn : in  std_logic;      				--! signal description UART clock (4xBAUD Rate frequency!)
		iReset		: in  std_logic;						--! signal description asynchronous reset
		
		odDataRcvd	: out  std_logic_vector(7 downto 0);	--! signal description data from Fifo
		ocREmpty	: out std_logic;						--! signal description indicates that Fifo is empty
		ocRFull		: out std_logic;						--! signal description indicates that Fifo is full
		ocRAlmostE	: out std_logic;						--! signal description indicates that Fifo is empty to half full
		ocRAlmostF	: out std_logic;						--! signal description indicates that Fifo is half full to full
		icRReadEn	: in  std_logic;						--! signal description get next value from Fifo (Fifo is in First Word Fall Through Mode!)
		
		idReceive	: in  std_logic							--! signal description signal for the RS232 Tx line
	);
end ReceiverAndFifo;

architecture arch of ReceiverAndFifo is

	component Receiver is
	    port ( 
	    	iSysClk    : in  std_logic;                    
            ie4BaudClkEn : in  std_logic;
	    	reset 	: in  STD_LOGIC;
	        Rx 		: in  STD_LOGIC;
	        data 	: out STD_LOGIC_VECTOR (7 downto 0);
			ready 	: out STD_LOGIC);
	end component;
	
	component Fifo is
		port  (
			iReset		: in  std_logic;
			
			iClkWrite 	: in  std_logic; 
			icWriteEn	: in  std_logic;
			
			iClkRead 	: in  std_logic; 
			icReadEn	: in  std_logic;
			
			idDataIn	: in  std_logic_vector(7 downto 0);
			odDataOut	: out std_logic_vector(7 downto 0);
			
			ocEmpty		: out std_logic;
			ocFull		: out std_logic;
			
			ocAlmostE	: out std_logic;
			ocAlmostF	: out std_logic
		);
	end component;

    signal scRWrite         : std_logic;
	signal scRWriteEn 		: std_logic;
	signal seRReadEn        : std_logic;
	signal sdDataRcvd		: STD_LOGIC_VECTOR (7 downto 0);
	
	signal scRcvrEmpty		: std_logic;
	signal scRcvrFull		: std_logic;
	signal scRcvrAEmpty		: std_logic;
	signal scRcvrAFull		: std_logic;
	signal scReaderReady	: std_logic;
	
	type ReceiverCtrlType is (RCVR_WAITING, RCVR_RCV, RCVR_READY);
	signal sRCVRCtrlState : ReceiverCtrlType;
	
begin
    scRWriteEn <= scRWrite and ie4xBaudClkEn;
    seRReadEn <= icRReadEn and ieClkEn;
    
	rcvFifo : Fifo
					PORT MAP(
						iReset		=> iReset,
			
						iClkWrite 	=> iSysClk,
						icWriteEn	=> scRWriteEn,
						
						iClkRead 	=> iSysClk,
						icReadEn	=> seRReadEn,
						
						idDataIn	=> sdDataRcvd,
						odDataOut	=> odDataRcvd,
						
						ocEmpty		=> scRcvrEmpty,
						ocFull		=> scRcvrFull,
						
						ocAlmostE	=> scRcvrAEmpty,
						ocAlmostF	=> scRcvrAFull
					);

	ocREmpty	<= scRcvrEmpty;
	ocRFull		<= scRcvrFull;
	ocRAlmostE	<= scRcvrAEmpty;
	ocRAlmostF	<= scRcvrAFull;
	
	RS232Receiver : Receiver
						port map( 
						    iSysClk    => iSysClk,              
                            ie4BaudClkEn => ie4xBaudClkEn,
					    	reset	=> iReset, 
					        Rx 		=> idReceive,
					        data 	=> sdDataRcvd,
							ready 	=> scReaderReady
						);
						
	ReceiverCtrl : process (iSysClk)
    begin
        if (rising_edge(iSysClk)) then
		  if (iReset = '1') then
            sRCVRCtrlState    <= RCVR_WAITING;
        
          elsif ie4xBaudClkEn = '1' then
            
            case sRCVRCtrlState is
                when RCVR_WAITING  => 
                    if scReaderReady = '0' then
                        sRCVRCtrlState <= RCVR_RCV;
                    end if;
            
                when RCVR_RCV =>
                    if scReaderReady = '1' then
                        sRCVRCtrlState <= RCVR_READY;
                    end if;
            
                when RCVR_READY =>
                    sRCVRCtrlState <= RCVR_WAITING;
                
            end case;
            
--            if (sRCVRCtrlState = RCVR_WAITING and scReaderReady = '0' ) then
--              sRCVRCtrlState <= RCVR_RCV;
--          
--          elsif (sRCVRCtrlState = RCVR_RCV and scReaderReady = '1') then
--              sRCVRCtrlState <= RCVR_READY;
--          
--          elsif (sRCVRCtrlState <= RCVR_READY) then
--              sRCVRCtrlState <= RCVR_WAITING;
--              
--          end if;
	       end if;
		end if;
		
	end process;
	
	scRWrite <= 	'1' when sRCVRCtrlState = RCVR_READY else
					'0';

end arch;

