----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:48 05/11/2011 
-- Design Name: 
-- Module Name:    CPU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.cpupkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
	Port(
		iClk			:	in		std_logic;
    	iReset		:	in 	std_logic;
    	bdData		:	inout	DATA;		--! connection to databus
    	odAddress   :	out	ADDRESS;		--! connection to addressbus
    	ocEnable		:	out 	std_logic;		--! enable or disable RAM
    	ocRnotW		:	out	std_logic		--! read/write control
	);
end CPU;

architecture Behavioral of CPU is
	component Steuerwerk is
    port  (
        iClk 			:	in 	std_logic;	--! iClk signal
        iReset			:	in		std_logic;	--! iReset signal
        icOpCode		:	in		optype;		--! icOpCode bus
        idCarry		:	in		std_logic;	--! carry from register file
        idZero			:	in		std_logic;	--! zero flag from register file
        ocRnotWRam	:	out	std_logic;	--! r_notw to RAM
        ocLoadEn		:	out	std_logic;	--! safe result of alu
        ocEnableRAM	:	out	std_logic;	--! put akku on databus
        ocLoadInstr	:	out	std_logic;	--! load instruction control signal
        ocNextPC		:	out	std_logic;	--! increment pc
        ocAddrSel		:	out	std_logic;	--! pc on addressbus
        ocJump			:	out	std_logic;	--! do a ocJump
        ocPCregister    :   out std_logic;  --! put PC to register File
        ocUsePC         :   out std_logic;  --! use Register to fill in the PC
        ocLoad          :   out std_logic   --! put databus to ALU immediate port  
    );
	end component;
	
	component RegFile is
	Port(
		iClk          : in  std_logic;
        iReset          : in  std_logic;
           
        icRegAsel       : in  std_logic_vector(4 downto 0);  
        icRegBsel       : in  std_logic_vector(4 downto 0);
        odRegA          : out DATA;
        odRegB          : out DATA;
        
        icPC            :  in std_logic;   -- select PC as input to RegisterFile
        idPC            :  in DATA;
        
        icRegINsel      : in  std_logic_vector(4 downto 0);
        
        idDataIn        : in  DATA;
        idCarryIn   : in  std_logic;
        idZeroIn        : in  std_logic;
    
        icLoadEn        : in std_logic;
        
        odCarryOut  : out std_logic;
        odZeroOut   : out   std_logic
	);
	end component;
	
	component ALU is
	Port(
		idOperand1	: in  DATA;
		idOperand2	: in  DATA;
		idImmidiate : in  DATA;
		idCarryIn	: in  std_logic;
		
		odResult		: out DATA;
		odCarryOut	: out std_logic;
		odZeroOut	: out std_logic;
		
		icOperation	: in  OPTYPE
	);
	end component;
	
	component FetchDecode is
	Port(
		iClk          : in  std_logic;
        iReset      : in  std_logic;
        
        idData      : in  DATA;
        icAddrSel   : in  std_logic;
        icLoadInstr : in  std_logic;
        icJump      : in  std_logic;
        icNextPC        : in  std_logic;
        idPC        : in  ADDRESS;
        icUsePC     : in  std_logic;
        odPC        : out ADDRESS;
        
        odAddress   : out ADDRESS;
        odImmidiate : out DATA;
        odRegAsel   : out std_logic_vector(4 downto 0);
        odRegBsel   : out std_logic_vector(4 downto 0);
        odRegINsel  : out std_logic_vector(4 downto 0);
        ocOperation : out OPTYPE
	);
	end component;
	
	component MemInterface is
	Port(
		bdDataBus		: inout 	DATA;
		odAddress		: out		ADDRESS;
		ocRnotW			: out		std_logic;
		ocEnable			: out		std_logic;
	
		icBusCtrlCPU	: in     std_logic;
		icRAMEnable		: in		std_logic;
		odDataOutCPU	: out    DATA;
		idDataInCPU		: in     DATA;
		idAddressCPU	: in		ADDRESS		
		);
	end component;
    
   
   signal sdPC          :   DATA;
   signal scPCregister  :   std_logic;         
   
   signal scUsePC       :   std_logic;
   signal sdPCfetch     :   ADDRESS;
   
   signal scLoad        :   std_logic;
   
   signal scOpCode		: optype;	
   signal sdCarryRF		: std_logic;
   signal sdZeroRF		: std_logic;	
   signal scRnotWRam		: std_logic;
   signal scLoadEn		: std_logic;	
   signal scEnableRAM	: std_logic;
   signal scLoadInstr	: std_logic;
   signal scNextPC		: std_logic;	
   signal scAddrSel		: std_logic;	
   signal scJump			: std_logic;
   signal sdAkkuRes		: DATA;
   signal sdCarryAkku	: std_logic;
   signal sdZeroAkku		: std_logic;	
   signal sdDataIn 		: DATA;
   signal sdAddress		: ADDRESS;
   signal sdImmidiate   : DATA;
   signal sdImmidiateALU: DATA;
   signal sdRegAsel     : std_logic_vector(4 downto 0);
   signal sdRegBsel     : std_logic_vector(4 downto 0);
   signal sdRegINsel    : std_logic_vector(4 downto 0);
   signal sdRegA        : DATA;
   signal sdRegB        : DATA;
    
begin

	SW	: Steuerwerk PORT MAP (
        iClk 			=> iClk,
        iReset			=> iReset,
        icOpCode		=> scOpCode,
        idCarry		=> sdCarryRF,
        idZero			=> sdZeroRF,
        ocRnotWRam	=> scRnotWRam,
        ocLoadEn		=> scLoadEn,
        ocEnableRAM	=> scEnableRAM,
        ocLoadInstr	=> scLoadInstr,
        ocNextPC		=> scNextPC,
        ocAddrSel		=> scAddrSel,
        ocJump			=> scJump,
        ocPCregister    => scPCregister,
        ocUsePC         => scUsePC,
        ocLoad          => scLoad
    );
	 
	RF: RegFile PORT MAP(
			iClk			=> iClk,
			iReset		=> iReset,
		    
		    icRegAsel   => sdRegAsel,
		    icRegBsel   => sdRegBsel,
		    icRegINsel  => sdRegINsel,
		    
		    icPC        => scPCregister,
            idPC        => sdPC,
		    
			idDataIn		=> sdAkkuRes,
			idCarryIn	=> sdCarryAkku,
			idZeroIn		=> sdZeroAkku,
		
			icLoadEn		=> scLoadEn,
			
			odRegA	    => sdRegA,
			odRegB      => sdRegB,
			odCarryOut	=> sdCarryRF,
			odZeroOut	=> sdZeroRF
	);
	
	Calc : ALU Port MAP(
			idOperand1	=> sdRegA,
			idOperand2	=> sdRegB,
			idImmidiate => sdImmidiateALU,
			idCarryIn	=> sdCarryRF,
			
			odResult		=> sdAkkuRes,
			odCarryOut	=> sdCarryAkku,
			odZeroOut	=> sdZeroAkku,
			
			icOperation	=> scOpCode
	);
	
	
	sdPC(31 downto 16) <= (others=>'0');
	FaD : FetchDecode PORT MAP(
			iClk			=> iClk,
			iReset		=> iReset,
			
			idData		=> sdDataIn,
			icAddrSel	=> scAddrSel,
			icLoadInstr	=> scLoadInstr,
			icJump		=> scJump,
			icNextPC	=> scNextPC,
			
			odPC        => sdPC(15 downto 0),
			idPC        => sdRegA(15 downto 0),
            icUsePC     => scUsePC,
			odAddress	=> sdAddress,
			odImmidiate => sdImmidiate,
			odRegAsel   => sdRegAsel,
            odRegBsel   => sdRegBsel,
            odRegINsel  => sdRegINsel,
			ocOperation	=> scOpCode
	);
	
	MemIF : MemInterface PORT MAP(
		bdDataBus		=> bdData,
		odAddress		=> odAddress,
		ocRnotW			=> ocRnotW,
		ocEnable			=> ocEnable,
	
		icBusCtrlCPU	=> scRnotWRam,
		icRAMEnable		=> scEnableRAM,
		odDataOutCPU	=> sdDataIn,
		idDataInCPU		=> sdRegA,
		idAddressCPU	=> sdAddress
		);

    
    sdImmidiateALU  <= bdData when scLoad='1' else
                       sdImmidiate;
    
end Behavioral;

