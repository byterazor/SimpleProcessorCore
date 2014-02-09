#main makefile for the Simple Processor Core Makefile scripts
#written 2014 by Dominik Meyer <dmeyer@federationhq.de>
#License: GPLv2
#
-include .config
include $(MAKEFILES_PATH)/Makefile.boards
export MAKEFILES_PATH

ifndef FPGA
	FPGA=$(CONFIG_FPGA_TYPE)
endif

# impact device number for jtag chain
ifndef DEVICE_NR
DEVICE_NR=$(subst ", , $(CONFIG_IMPACT_TARGET))
#")
endif

TOP=top
BIT=soc.bit

ifndef UCF
UCF=$(subst ", , $(CONFIG_UCF_NAME))
endif

ifndef SD
SD=$(subst ", , $(CONFIG_NGC_LOOKUP))
endif

ifndef XILINX_XST
XILINX_XST=$(subst ", ,$(CONFIG_XILINX_XST_FLAGS))
#")
endif

ifndef XILINX_NGDBUILD
XILINX_NGDBUILD=$(subst ", , $(XILINX_NGDBUILD_FLAGS))
#")
endif

ifndef XILINX_MAP
XILINX_MAP=$(subst ", , $(CONFIG_XILINX_MAP_FLAGS))
#")
endif

ifndef XILINX_PAR
XILINX_PAR=$(subst ", ,$(CONFIG_XILINX_PAR_FLAGS))
#")
endif

ifndef XILINX_BITGEN
XILINX_BITGEN=$(subst ", ,$(CONFIG_XILINX_BITGEN_FLAGS))
#")
endif

ifndef FLAGS
FLAGS=$(subst ", ,$(CONFIG_MODELSIM_VCOM_FLAGS))
#")
endif

XILINX_LICENSE=$(CONFIG_XILINX_SERVER)

#path to Xilinx tools
XILINX_INSTALL_DIR=$(subst ",,$(CONFIG_XILINX_INSTALL_DIR))
XILINX_VERSION=$(subst ",,$(CONFIG_XILINX_VERSION))
ifndef XILINX_PATH
ifeq ($(CONFIG_SYSTEM_64),y)
XILINX_PATH=$(XILINX_INSTALL_DIR)/$(XILINX_VERSION)/ISE_DS/ISE/bin/lin64/
else
XILINX_PATH=$(XILINX_INSTALL_DIR)/$(XILINX_VERSION)/ISE_DS/ISE/bin/lin/
endif
endif

#modelsim license server
MODELSIM_LICENSE=$(CONFIG_MODELSIM_SERVER)

#path to modelsim tools
ifndef MODELSIM_PATH
MODELSIM_PATH=$(CONFIG_MODELSIM_INSTALL_DIR)
endif

ifndef VERBOSE_OUTPUT
ifdef CONFIG_XILINX_VERBOSE_OUTPUT
VERBOSE_OUTPUT=1
else
VERBOSE_OUTPUT=0
endif
endif


.PHONY: clean all real_clean

all: soc.bit

real_clean:
	git clean -x -f

clean: kconfig_clean 
	-@rm -rf Make.sources ${CLEAN_FILES} $(OBJ)


Make.sources: .config Makefile.files Makefile.modules
	@clear
	@echo "****************************************************************************************"
	@echo "****      XILINX Synthesis, Map, Place, Route and Modelsim Makefile Version " $(VERSION)
	@echo "****"
	@echo "****      written 2012 by Dominik Meyer <dmeyer@hsu-hh.de>"
	@echo "****                      Marcel Eckert <eckert@hsu-hh.de>"
	@echo "****"
	@echo "**** Creating Make.sources ****"
	@make  -s -f $(MAKEFILES_PATH)Makefile.gensources TOPDIR=$(CURDIR) MAKEFILES_PATH=$(MAKEFILES_PATH) BOARD_TARGET=$(BOARD_TARGET) FPGA_FAMILY=$(FPGA_FAMILY) Make.sources
	@echo "**** Make.sources created"


impact.script:
	@echo "setMode -bs" > $@
	@echo "setCable -p auto" >> $@
	@echo "identify" >> $@
	@$(foreach d,$(DEVICE_NR),echo "AssignFile -p ${d} -file flash.bit" >> $@ ;)
	@$(foreach d,$(DEVICE_NR),echo "program -p ${d}" >> $@ ;)
	@echo "quit" >> $@

program: impact.script 
	@echo "**** Programming FPGA ****"
	@[ -n "$(BIT)"                 ] || ( echo "**** Please give Bitfile on commandline with BIT=<FILE>" && exit 1)
	@cp $(BIT) flash.bit
	@$(XILINX_PATH)/impact -batch impact.script 1>/dev/null
	@rm impact.script


include $(MAKEFILES_PATH)/Makefile.configure
include $(MAKEFILES_PATH)/Makefile.synth
include $(MAKEFILES_PATH)/Makefile.Modelsim
include $(MAKEFILES_PATH)/Makefile.isim
include $(MAKEFILES_PATH)/Makefile.doxygen