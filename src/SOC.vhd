library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.cpupkg.all;

entity SOC is											-- Testumgebung f�r Rechner
port(clk			: in std_logic;									-- Taktsignal
	  clk_man	: in std_logic;									-- manuelles Taktsignal
     reset		: in std_logic;  									-- Resetsignal
     led			: out std_logic_vector(7 downto 0);
     switch 	: in std_logic_vector(1 downto 0));
     
end SOC;
   
architecture Struktur of SOC is

component Rechner is													-- Rechner setzt sich aus CPU, RAM und Bus zusammen
port(	clk			: in std_logic;							-- Taktsignal
		reset			: in std_logic;							-- Resetsignal
		data_print_1: out DATA;
		data_print_2: out DATA);								-- Ausgabe
end component Rechner;

component antibeat_device is
    port  (
        button_in   :   in   std_logic;      --! the button input, for example the button from an fpga
        button_out  :   out  std_logic;      --! the button output, for example going to the reset or clk of a processor
        counter		:	in	 std_logic_vector(31 downto 0);	--! the number of clk ticks to wait
        clk         :   in   std_logic;       --! input clock
        reset		:	in	std_logic
      );
end component antibeat_device;


signal data_print_1	: std_logic_vector(31 downto 0);		
signal data_print_2	: std_logic_vector(31 downto 0);
signal sig_entprellt	: std_logic;

signal output : std_logic_vector(15 downto 0);   
signal clk_out : std_logic;
begin

	-- select what to display on led
	led <= --(others => '1') when reset='1' else
		   output(15 downto 8) when switch(0)='1' else
		   output(7 downto 0);
		   
	output <= data_print_1(15 downto 0) when switch(1) = '0' else
				 data_print_2(15 downto 0);
	
	antibeat: antibeat_device
	port map(
	    button_in  => clk_man,
	    button_out => clk_out,
	    counter    => x"019BFCC0",
	    clk        => clk,
	    reset      => reset
	);
	
										
	Rechner_0		: Rechner 		port map(clk			=> clk_out, 
														reset		=> reset, 
														data_print_1=> data_print_1,
														data_print_2=> data_print_2);

end Struktur;
