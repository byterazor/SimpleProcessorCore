--------------------------------------------------------------------------------
-- Entity: Receiver
--------------------------------------------------------------------------------
-- Copyright ... 2011
-- Filename          : Receiver.vhd
-- Creation date     : 2011-05-25
-- Author(s)         : marcel
-- Version           : 1.00
-- Description       : implements an RS232 Receiver
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2011-05-25   1.00     marcel     Creation of File
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! brief
--! implements an RS232 Receiver

--! detailed
--! implements an RS232 Receiver, 8 Bits, no parity check and no Stop Bits
--! sending parities or stop bits should not produce errors
entity Receiver is
    Port ( 
    	iSysClk    : in  std_logic;                    
        ie4BaudClkEn : in  std_logic;reset 		: in std_logic;			--! signal description asynchronous reset
        Rx 			: in  STD_LOGIC;		--! signal description signal for the RS232 Rx line
        data 		: out STD_LOGIC_VECTOR (7 downto 0);	--! signal description last data received
		ready 		: out STD_LOGIC);		--! '0' signals receving in progress, if '1' after a previous '0' signals data available at <data> 
end Receiver;

architecture Behavioral of Receiver is
	signal z, tz : integer range 0 to 63;
	signal result, tresult : STD_LOGIC_VECTOR(7 downto 0);

begin
	process (z, Rx)
	begin
			if z = 0 then
				if (Rx ='0') then
					tz <= 1;
				else
					tz <= 0;
				end if;
				
			elsif z <= 36 then
				tz <= z + 1;
					
			else
				tz <= 0;		

			end if;
	end process;
	
	tresult <= Rx & result(7 downto 1);	
	
	process (reset, iSysClk)
	begin
		if (iSysClk'event and iSysClk = '1') then
		  if reset = '1' then
            z <= 0;
          elsif ie4BaudClkEn = '1' then
			z <= tz;
			case z is
					
				when 5 =>
					result <= tresult;		-- D(0)
					
				when 9 =>
					result <= tresult;		-- D(1)
					
				when 13 =>
					result <= tresult;		-- D(2)

				when 17 =>
					result <= tresult;		-- D(3)

				when 21 =>
					result <= tresult;		-- D(4)
				
				when 25 =>
					result <= tresult;		-- D(5)
					
				when 29 =>
					result <= tresult;		-- D(6)
					
				when 33 =>
					result <= tresult;		-- D(7)
					
				-- optional TODO: add check for STOP-Bit(s) 
					
				when others => result <= result;
			end case;
		  end if;
		end if;
	end process;

	data <= result;
	ready <= '1' when z = 0 else '0';
	
end Behavioral;

