library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cpupkg.all;

entity SOC is													-- Rechner setzt sich aus CPU, RAM und Bus zusammen
port(	clk			: in std_logic;							-- Taktsignal
		reset			: in std_logic;							-- Resetsignal
		odRS232       :   out std_logic;
		idRS232       :    in std_logic;
		data_print_1: out DATA;
		data_print_2: out DATA;
		ic200MhzClk   :   in  std_logic
		);							
end SOC;

architecture arch of SOC is

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
    
    
    component MemoryMapper
        port (
            start : in std_logic_vector ( 15 downto 0 );
            stop : in std_logic_vector ( 15 downto 0 );
            adr_in : in std_logic_vector ( 15 downto 0 );
            req_in : in std_logic;
            req_out : out std_logic;
            enable : out std_logic;
            adr_out : out std_logic_vector ( 15 downto 0 )
        );
    end component;

        
    component MMIO_Uart
        generic (
            GEN_start : std_logic_vector ( 15 downto 0 );
            GEN_SysClockinHz : integer;
            GEN_Baudrate : integer;
            GEN_HasExternBaudLimit : boolean
        );
        port (
            odRS232 : out std_logic;
            idRS232 : in std_logic;
            ocInterrupt     :   out std_logic;          --! high if data is available
            odDebug : out std_logic_vector(7 downto 0);
            iClk : in std_logic;
            iReset : in std_logic;
            bdData : inout DATA;
            idAddress : in ADDRESS;
            icEnable : in std_logic;
            icRnotW : in std_logic
        );
    end component;

    component clkDivider
        generic (
            GEN_FreqIn_Hz : integer;
            GEN_FreqOut_Hz : integer
        );
        port (
            iClk_in : in STD_LOGIC;
            iReset : in STD_LOGIC;
            oClk_out : out STD_LOGIC
        );
    end component;

    
    signal DATAbus  : std_logic_vector(31 downto 0);        -- DATAbus
    signal address  : std_logic_vector(15 downto 0);        -- Adressbus
    signal rw_ram   : std_logic;                                -- read/write-Signal RAM
    signal enable   : std_logic;
	
	signal scRAMenable         :   std_logic;
	signal scRAM_RnotW         :   std_logic;
	signal scRAM_address       :   std_logic_vector(15 downto 0);
	
	signal scUARTenable        :   std_logic;
	signal scUART_RnotW        :   std_logic;
	signal scUART_address      :   std_logic_vector(15 downto 0);
	
	signal scClk20Mhz          :   std_logic;
	
	signal sdDebug             :   std_logic_vector(7 downto 0);
	
	signal scReset             :   std_logic;
	
begin   

    scReset     <= not reset;
    
    divider0:clkDivider
    generic map(
        GEN_FreqIn_Hz  => 200000000,
        GEN_FreqOut_Hz => 20000000
    )
    port map(
        iClk_in        => ic200MhzClk,
        iReset         => '0',
        oClk_out       => scClk20Mhz
    );
    

    
    
	CPU_1: CPU port map(	
								iClk 			=> scClk20Mhz, 
								iReset 		=> scReset,
								bdData 		=> DATAbus,
								odAddress	=> address, 
								ocEnable		=> enable,
								ocRnotW 		=> rw_ram);
	
    

    mapperRAM: MemoryMapper
    port map(
        start   => x"0000",
        stop    => x"00FF",
        adr_in  => address,
        req_in  => rw_ram,
        req_out => scRAM_RnotW,
        enable  => scRAMenable,
        adr_out => scRAM_address
    );
    
    
    
	RAM_1: RAM port map(	
								iClk			=> scClk20Mhz,
								iReset 		=> scReset,
								bdData 		=> DATAbus, 
								idAddress	=> scRAM_address, 
								icEnable 	=> scRAMenable, 
								icRnotW     => scRAM_RnotW);
    
    
    
    mapperUart: MemoryMapper
    port map(
        start   => x"FFF0",
        stop    => x"FFF2",
        adr_in  => address,
        req_in  => rw_ram,
        req_out => scUART_RnotW,
        enable  => scUARTenable,
        adr_out => scUART_address
    );
     
           
    uart0: MMIO_Uart
    generic map(
        GEN_start              => x"0000",
        GEN_SysClockinHz       => 20000000,
        GEN_Baudrate           => 57600,
        GEN_HasExternBaudLimit => false
    )
    port map(
        odRS232                => odRS232,
        idRS232                => idRS232,
        ocInterrupt            => open,
        odDebug                => sdDebug,
        iClk                   => scClk20Mhz,
        iReset                 => scReset,
        bdData                 => DATAbus,
        idAddress              => scUART_address,
        icEnable               => scUARTenable,
        icRnotW                => scUART_RnotW
    );
    
    
	data_print_1 <= DATAbus;
	data_print_2 <= x"000000" & sdDebug;

end arch;
