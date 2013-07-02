-------------------------------------------------------
--! @file 
--! @brief anti beat device for key buttons on the fpga
--! @author Dominik Meyer
--! @email dmeyer@hsu-hh.de
--! @date 2010-06-22
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--! anti beat device for key buttons on the fpga

--! this anti beat device makes sure that button_in is only transmitted to button_output once every second
entity antibeat_device is
    port  (
        button_in   :   in   std_logic;      --! the button input, for example the button from an fpga
        button_out  :   out  std_logic;      --! the button output, for example going to the reset or clk of a processor
        counter		:	in	 std_logic_vector(31 downto 0);	--! the number of clk ticks to wait
        clk         :   in   std_logic;       --! input clock
        reset		:	in	std_logic
      );
end antibeat_device;

architecture arch of antibeat_device is
    
begin
    
    process(clk,button_in)
        variable waiting : integer := 0;
        variable running : boolean := false;
    begin
        
		if (button_in = '1' and running=false) then
			running:=true;
			waiting:=0;
			button_out <= '1';
		elsif (rising_edge(clk)) then
			if (running = true) then
				waiting := waiting + 1;
			end if;
			
			if (waiting> counter and button_in='0') then
				running := false;
				button_out <= '0';
			end if;
						
        end if;
        
    end process;
    
end arch;

