--------------------------------------------------------------------------------
-- Entity: SenderAndFifo
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : SenderAndFifo.vhd
-- Creation date     : 2011-05-31
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : implements an RS232 Sender with additional Fifo
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-31   1.00     marcel     Creation of File
--------------------------------------------------------------------------------


--! brief
--! implements an RS232 Sender with additional Fifo

--! detailed
--! implements an RS232 Sender with additonal Fifo (8 Bit data width, 4k data depth)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SenderAndFifo is
	port  (
		iSysClk 	: in  std_logic;					--! signal description System side clock
		ieClkEn     : in  std_logic;
		ieBaudClkEn	: in  std_logic;					--! signal description UART clock (BAUD Rate frequency!)
		iReset		: in  std_logic;					--! signal description asynchronous reset
		
		icSend		: in  std_logic;					--! signal description add data <idDataSend> to Fifo (Enable Signal)
		idDataSend	: in  std_logic_vector(7 downto 0); --! signal description data to be added to the Fifo
		ocSEmpty	: out std_logic;					--! signal description indicates that Fifo is empty
		ocSFull		: out std_logic;					--! signal description indicates that Fifo is full
		ocSAlmostE	: out std_logic;					--! signal description indicates that Fifo is empty to half full
		ocSAlmostF	: out std_logic;					--! signal description indicates that Fifo is half full to full
		
		odTransmit	: out std_logic						--! signal description signal for the RS232 Tx line
	);
end SenderAndFifo;

architecture arch of SenderAndFifo is
	component Sender is
	    port ( 	
	    	iSysClk    : in  std_logic;                    
            ieBaudClkEn : in  std_logic;
    		iReset		: in  STD_LOGIC;
           	icSend 		: in  STD_LOGIC;
           	idData 		: in  STD_LOGIC_VECTOR (7 downto 0);
          	odTransmit 	: out  STD_LOGIC;
			ocReady		: out  STD_LOGIC;
			ocSyn		: out  STD_LOGIC);
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
	
	signal scSenderRead		: std_logic;
	signal scSenderReadEn   : std_logic;
	
	signal sdDataToSend		: STD_LOGIC_VECTOR (7 downto 0);
	signal scSenderEmpty	: std_logic;
	signal scSenderFull		: std_logic;
	signal scSenderAEmpty	: std_logic;
	signal scSenderAFull	: std_logic;
	
	signal scSenderReady	: std_logic;
	signal scSenderSendReq	: std_logic;
	signal scSyn			: std_logic;
	
	type SenderCtrlType is (SENDER_WAITING, SENDER_SEND, SENDER_SENDING, SENDER_SENDING_SYN);
	signal sSenderCtrlState : SenderCtrlType;
	
	signal seSend : std_logic;
	
begin
	
	scSenderReadEn <= scSenderRead and ieBaudClkEn;
	seSend         <= icSend and ieClkEn;
	
	sendFifo : Fifo
					PORT MAP(
						iReset		=> iReset,
			
						iClkWrite 	=> iSysClk,
						icWriteEn	=> seSend,
						
						iClkRead 	=> iSysClk,
						icReadEn	=> scSenderReadEn,
						
						idDataIn	=> idDataSend,
						odDataOut	=> sdDataToSend,
						
						ocEmpty		=> scSenderEmpty,
						ocFull		=> scSenderFull,
						
						ocAlmostE	=> scSenderAEmpty,
						ocAlmostF	=> scSenderAFull
					);

	ocSEmpty	<= scSenderEmpty;
	ocSFull		<= scSenderFull;
	ocSAlmostE	<= scSenderAEmpty;
	ocSAlmostF	<= scSenderAFull;
	
	RS232Sender : Sender
					PORT MAP(
						iSysClk     => iSysClk,      
                        ieBaudClkEn => ieBaudClkEn,
			    		iReset		=> iReset,
			           	icSend 		=> scSenderSendReq,
			           	idData 		=> sdDataToSend,
			          	odTransmit 	=> odTransmit,
						ocReady		=> scSenderReady,
						ocSyn		=> scSyn
					);
	
	SenderCtrl : process (iSysClk, iReset, sSenderCtrlState, scSenderReady, ieclken, scsenderempty, scsyn)
	begin
		if (rising_edge(iSysClk)) then
		    if (iReset = '1') then
                sSenderCtrlState <= SENDER_WAITING;
        
            elsif ieClkEn = '1' then
    			case sSenderCtrlState is 
    			     when SENDER_WAITING =>
    			        if scSenderEmpty = '0' then
    				        sSenderCtrlState <= SENDER_SEND;
    				    end if;
    				
    			     when SENDER_SEND => 
    			        if scSenderReady = '0' then
    				        sSenderCtrlState <= SENDER_SENDING;
    				    end if;
    		
    			     when SENDER_SENDING => 
    			        if scSyn = '1' then
    			            sSenderCtrlState <= SENDER_SENDING_SYN;
    			        end if;
    				
    			     when SENDER_SENDING_SYN =>
    			        if scSyn = '0' then
    				        sSenderCtrlState <= SENDER_WAITING;
    				    end if;
    				
    			end case;
		    end if;
		end if;
		
		scSenderRead 	<= '0';
		scSenderSendReq <= '0';
		
		if (sSenderCtrlState = SENDER_SEND) then
			scSenderSendReq <= '1';
			
		end if;
		
		if (sSenderCtrlState = SENDER_SENDING_SYN) then
			scSenderRead <= '1';
		end if;
	
	end process;


end arch;

