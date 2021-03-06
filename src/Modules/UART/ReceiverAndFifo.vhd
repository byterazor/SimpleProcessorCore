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
		iSysClk 	  : in  std_logic;						--! signal description System side clock
		ieClkEn       : in  std_logic;
		ie4xBaudClkEn : in  std_logic;      				--! signal description UART clock (4xBAUD Rate frequency!)
		iReset		  : in  std_logic;						--! signal description asynchronous reset
	    icEnableParity: in  std_logic;                      --! signal description allow reception of parity bit	
		odDataRcvd	  : out  std_logic_vector(7 downto 0);	--! signal description data from Fifo
		odParity      : out  std_logic;                       --! possible parity bit
		ocREmpty	  : out std_logic;						--! signal description indicates that Fifo is empty
		ocRFull		  : out std_logic;						--! signal description indicates that Fifo is full
		ocRAlmostE	  : out std_logic;						--! signal description indicates that Fifo is empty to half full
		ocRAlmostF	  : out std_logic;						--! signal description indicates that Fifo is half full to full
		icRReadEn	  : in  std_logic;						--! signal description get next value from Fifo (Fifo is in First Word Fall Through Mode!)
		idReceive	  : in  std_logic							--! signal description signal for the RS232 Tx line
	);
end ReceiverAndFifo;

architecture arch of ReceiverAndFifo is

	component Receiver is
	    port ( 
	    	iSysClk       : in  std_logic;                    
            ie4BaudClkEn  : in  std_logic;
	    	reset 	      : in  STD_LOGIC;
	        Rx 		      : in  STD_LOGIC;
	        data 	      : out STD_LOGIC_VECTOR (7 downto 0);
	        parity        : out std_logic;
	        icEnableParity: in  std_logic;
			ready 	      : out STD_LOGIC);
	end component;
	
    component SimpleFifo is
        generic (
        GEN_WIDTH     : integer    := 9;        --! Data width of each data word
        GEN_DEPTH     : integer    := 256;      --! how many values can be stored in Fifo

        GEN_A_EMPTY : integer := 2;             --! when is the FIFO signaled as almost empty
        GEN_A_FULL  : integer := 250            --! when is the FIFO signaled as almost full

    );
        port  (
            icWriteClk      : in  std_logic;
            icWe         : in  std_logic;

            icReadClk       : in  std_logic;
            icReadEnable : in  std_logic;

            idData            : in  std_logic_vector(8 downto 0);
            odData            : out std_logic_vector(8 downto 0);

            ocEmpty         : out std_logic;
            ocFull          : out std_logic;

            ocAempty     : out std_logic;
            ocAfull     : out std_logic;
            
            icClkEnable  : in  std_logic;                                   --! active high clock enable signal
            icReset      : in  std_logic                                    --! active high reset, values in RAM are not overwritten, just FIFO     
        );
    end component;

    signal scRWrite         : std_logic;
	signal scRWriteEn 		: std_logic;
	signal seRReadEn        : std_logic;
	signal sdDataRcvd		: STD_LOGIC_VECTOR (8 downto 0);
	signal sdParity         : std_logic;
	
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
    
	rcvFifo : SimpleFifo
					PORT MAP(
						icReset		=> iReset,
			
						icWriteClk 	=> iSysClk,
						icWe	=> scRWriteEn,
						
						icReadClk 	=> iSysClk,
						icReadEnable	=> seRReadEn,
						
						idData	=> sdDataRcvd,
						odData(8 downto 1)	=> odDataRcvd,
					    odData(0)            => odParity,
						
						ocEmpty		=> scRcvrEmpty,
						ocFull		=> scRcvrFull,
						
						ocAempty	=> scRcvrAEmpty,
						ocAfull	=> scRcvrAFull,
						icClkEnable => ieClkEn
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
					        data 	=> sdDataRcvd(8 downto 1),
					        parity  => sdDataRcvd(0),
					        icEnableParity => icEnableParity,
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

