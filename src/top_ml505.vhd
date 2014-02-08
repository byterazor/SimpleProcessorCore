library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cpupkg.all;

entity top is	
generic(
        GEN_SYS_CLK     :   integer := 200000000; --! system clock in HZ
        GEN_SOC_CLK     :   integer :=  30000000  --! soc clock in HZ
);												
port(	icclk			: in std_logic;							-- Taktsignal
		icreset_n			: in std_logic;							-- Resetsignal
		
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

	
    signal scReset  :   std_logic;	
begin   

    scReset <= not icReset;
    
     soc0:entity work.SOC
     generic map(
         GEN_SYS_CLK => GEN_SYS_CLK,
         GEN_SOC_CLK => GEN_SOC_CLK
     )
     port map(
         icclk       => icclk,
         icreset     => screset,
         odLED       => odLED,
         odRS232     => odRS232,
         idRS232     => idRS232
     );
      
    
    
    
end arch;
