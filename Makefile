-include .config
MAKEFILES_PATH=$(CURDIR)/Makefiles/
include Makefile.modules
include $(MAKEFILES_PATH)/Makefile


ifeq ($(BOARD_TARGET), spartan3e)
	UCF=UCF/spartan3e.ucf
else
ifeq ($(BOARD_TARGET), ml505)
	UCF=UCF/ML505.ucf
endif
endif


define XST_PARAMS
-opt_mode Speed 
-opt_level 1 
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
-iobuf YES 
-keep_hierarchy NO 
-max_fanout 100000 
-bufg 32 
-register_duplication YES 
-register_balancing No 
-optimize_primitives NO 
endef
export XST_PARAMS

test:
	@echo $(BOARD_TARGET)