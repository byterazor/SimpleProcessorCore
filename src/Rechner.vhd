library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cpupkg.all;

entity Rechner is													-- Rechner setzt sich aus CPU, RAM und Bus zusammen
port(	clk			: in std_logic;							-- Taktsignal
		reset			: in std_logic;							-- Resetsignal
		data_print_1: out DATA;
		data_print_2: out DATA
		);							
end Rechner;

architecture Struktur of Rechner is

	signal DATAbus	: std_logic_vector(31 downto 0);		-- DATAbus
	signal address	: std_logic_vector(15 downto 0);		-- Adressbus
	signal rw_ram	: std_logic;								-- read/write-Signal RAM
	signal enable 	: std_logic;
	 
	component CPU is
		Port(
			iClk			:	in		std_logic;
			iReset		:	in 	std_logic;
			bdData		:	inout	DATA;		--! connection to databus
			odAddress   :	out	std_logic_vector(15 downto 0);		--! connection to addressbus
			ocEnable		:	out 	std_logic;		--! enable or disable RAM
			ocRnotW		:	out	std_logic		--! read/write control
		);
	end component; 
	 
	component RAM is
		 port  (
			iClk			:	in		std_logic;
			iReset		:	in 	std_logic;
			bdData		:	inout	DATA;		--! connection to databus
			idAddress   :	in		std_logic_vector(15 downto 0);		--! connection to addressbus
			icEnable		:	in 	std_logic;		--! enable or disable RAM
			icRnotW		:	in		std_logic		--! read/write control
			
		 );
	end component;

	
begin


	CPU_1: CPU port map(	
								iClk 			=> clk, 
								iReset 		=> reset,
								bdData 		=> DATAbus,
								odAddress	=> address, 
								ocEnable		=> enable,
								ocRnotW 		=> rw_ram);
	
	RAM_1: RAM port map(	
								iClk			=> clk,
								iReset 		=> reset,
								bdData 		=> DATAbus, 
								idAddress	=> address, 
								icEnable 	=> enable, 
								icRnotW 		=> rw_ram);

	data_print_1 <= DATAbus;	-- Ausgabe des DATAbus auf dem LCD-Display
	data_print_2 <= "0000000000000000" & address;

end Struktur;
