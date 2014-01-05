--------------------------------------------------------------------------------
-- Entity: Sender
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : Sender.vhd
-- Creation date     : 2011-05-25
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : implements an RS232 Sender
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-25   1.00     marcel     Creation of File
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! brief
--! implements an RS232 Sender

--! detailed
--! implements an RS232 Sender, 8 Bits without parity and 2 Stop Bits
entity Sender is
    port ( 	
            iSysClk     : in  std_logic;                        --! signal description System side clock
            ieBaudClkEn : in  std_logic;                        --! signal description clock enable signal for needed BAUD rate 
    		iReset		: in  STD_LOGIC;						--! signal description synchronous reset
           	icSend 		: in  STD_LOGIC;						--! signal description force a send of <idData>
           	idData 		: in  STD_LOGIC_VECTOR (7 downto 0);	--! signal description the data to be sent
           	idParity    : in  std_logic;                        --! signal description the parity bit of the data
           	icEnableParity:in std_logic;                        --! signal description enable sending of the parity bit
          	odTransmit 	: out  STD_LOGIC;						--! signal description signal for the RS232 Tx line
			ocReady		: out  STD_LOGIC;						--! signal description signals availability of the Sender (no Sending in Progress)
			ocSyn		: out  STD_LOGIC);						--! signal description signals sending of first Stop Bit 
end Sender;

architecture Behavioral of Sender is
	signal temp, tnext  :STD_LOGIC_VECTOR(12 downto 0);
	
	type StateType is (WAITING, INIT, HIGH, START, DATA0, DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7, PARITY, STOP1, STOP2);
	signal state : StateType;
begin
	process(iSysClk)
	begin
		if (iSysClk'event and iSysClk = '1') then
			if (iReset = '1') then
                temp <= (others => '1');
                state <= WAITING;
                odTransmit <= '1';
                ocSyn <= '0';
        
            elsif ieBaudClkEn = '1' then 
    			temp <= tnext;
    			odTransmit <= temp(0);
    			case state is
    				when WAITING => 
    					if (icSend = '1') then
    					   if (icEnableParity = '1') then
    					    temp <= "11" & idParity & idData &  "01";
    					   else
    						temp <= "111" & idData & "01";
    					   end if;
    						state <= INIT;
    					else
    						state <= WAITING;
    					end if;
    				
    				when INIT =>
    					state <= HIGH;
    				
    				when HIGH => 
    					state <= START;
    				
    				when START =>
    					state <= DATA0;
    					
    				when DATA0 =>
    					state <= DATA1;
    					
    				when DATA1 =>
    					state <= DATA2;
    					
    				when DATA2 =>
    					state <= DATA3;
    					
    				when DATA3 =>
    					state <= DATA4;
    				
    				when DATA4 =>
    					state <= DATA5;
    					
    				when DATA5 =>
    					state <= DATA6;
    				
    				when DATA6 =>
    					state <= DATA7;
    					
    				when DATA7 =>
    				    if (icEnableParity = '1') then
    				        state <= PARITY;
    				    else
    					   state <= STOP1;
    					end if;
    					
    			    when PARITY  =>
    			         state <= STOP1;
    				
    				when STOP1 =>
    					state <= STOP2;
    					ocSyn <= '1';
    					
    				when STOP2 =>
    					state <= WAITING;
    					ocSyn <= '0';
    			end case;
    		end if;
		end if;
	end process;

	tnext <= '1' & temp(12 downto 1);
	ocReady <= '1' when state = WAITING else
				'0';
	
end Behavioral;

