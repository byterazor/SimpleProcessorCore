include .config
#location of Makefiles
MAKEFILES_PATH=/home/dmeyer/Programmieren/Make/Makefiles/

#which FPGA are we synthesizing for ?
FPGA=xc5vlx110t-1-ff1136

#NR of the FPGA in jtag chain
DEVICE_NR=5

SD= NGC/

#which is the TOP Module of the project ?
TOP=HSU_MIPS_SOC
UCF=UCF/xc5vlx110t-1-ff1136.ucf

#is this a partial reconfiguration project 
RECONFIGURATION=0

#modelsim vcom Flags
FLAGS = -O0  -rangecheck -check_synthesis  +acc=full

#xilinx license server
XILINX_LICENSE=2100@192.168.1.5
#path to Xilinx tools
XILINX_PATH=/home/Xilinx/14.1/ISE_DS/ISE/bin/lin64/

#modelsim license server
MODELSIM_LICENSE=1718@192.168.1.5
#path to modelsim tools
MODELSIM_PATH=/home/modeltech/modelsim/linux_x86_64



# additional parameters for xilinx tools
XILINX_XST=
XILINX_NGDBUILD=
XILINX_MAP=
XILINX_PAR=
XILINX_BITGEN=


# xst file parameters
define XST_PARAMS
-opt_mode Speed 
-opt_level 1 
-power NO 
-iuc NO 
-netlist_hierarchy as_optimized 
-rtlview Yes 
-glob_opt AllClockNets 
-read_cores YES 
-write_timing_constraints NO 
-cross_clock_analysis NO 
-hierarchy_separator / 
-bus_delimiter <>
-case maintain 
-slice_utilization_ratio 100 
-bram_utilization_ratio 100 
-dsp_utilization_ratio 100 
-lc off 
-reduce_control_sets off 
-fsm_extract YES 
-fsm_encoding Auto 
-safe_implementation Yes 
-fsm_style lut 
-ram_extract Yes 
-ram_style Auto 
-rom_extract Yes 
-shreg_extract YES 
-rom_style Auto 
-auto_bram_packing NO 
-resource_sharing YES 
-async_to_sync NO 
-use_dsp48 auto 
-iobuf YES 
-keep_hierarchy NO 
-max_fanout 100000 
-bufg 32 
-register_duplication YES 
-register_balancing No 
-optimize_primitives NO 
endef
export XST_PARAMS

%/blockRAM.o: %/blockRAM.vhd
	@export LM_LICENSE_FILE=$(MODELSIM_LICENSE);$(MODELSIM_PATH)/vcom -ignorevitalerrors -permissive -work work $< | grep -E 'Compiling|Error:|Warning:'
	@touch $@

include $(MAKEFILES_PATH)/Makefile
