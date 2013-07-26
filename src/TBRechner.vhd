--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:43:10 05/11/2011
-- Design Name:   
-- Module Name:   /home/marcel/Lehre/II-B2/ProzessorPimped/TBRechner.vhd
-- Project Name:  SoC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Rechner
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TBRechner IS
END TBRechner;
 
ARCHITECTURE behavior OF TBRechner IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SOC
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         odRS232       :   out std_logic;
         idRS232       :    in std_logic;
         ic200MhzClk   :   in  std_logic;
         data_print_1 : OUT  std_logic_vector(31 downto 0);
			data_print_2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	signal data_print_1 : std_logic_vector(31 downto 0);
	signal data_print_2 : std_logic_vector(31 downto 0);
    
    signal idRS232, odRS232 :   std_logic;
    
       -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SOC PORT MAP (
          clk => clk,
          ic200MhzClk => clk,
          reset => reset,
          idRS232   => idRS232,
          odRS232   => odRS232,
          data_print_1 => data_print_1,
			 data_print_2 => data_print_2
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		reset <= '1';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
