library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cpupkg.all;

entity top is	
generic(
        GEN_SYS_CLK     :   integer := 50000000; --! system clock in HZ
        GEN_SOC_CLK     :   integer :=  5000000  --! soc clock in HZ
);												
port(	icclk			: in std_logic;							-- Taktsignal
		icreset			: in std_logic;							-- Resetsignal
		
		odLED           : out std_logic_vector(7 downto 0);
		
		odRS232       :   out std_logic;
		idRS232       :    in std_logic
		);							
end top;

architecture arch of top is

   component SOC
        generic (
            GEN_SYS_CLK : integer;
            GEN_SOC_CLK : integer
        );
        port (
            icclk : in std_logic;
            icreset : in std_logic;
            odLED : out std_logic_vector ( 7 downto 0 );
            odRS232 : out std_logic;
            idRS232 : in std_logic
        );
    end component;

	
	signal scClk   :   std_logic;
	
begin   

     soc0:entity work.SOC
     generic map(
         GEN_SYS_CLK => 50000000,
         GEN_SOC_CLK =>  5000000
     )
     port map(
         icclk       => icclk,
         icreset     => icreset,
         odLED       => odLED,
         odRS232     => odRS232,
         idRS232     => idRS232
     );
      
    
    
    
end arch;
