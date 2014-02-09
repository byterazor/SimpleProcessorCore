            Very small building guide for the SPC
           ----------------------------------------
           
           
If you have a ML-505 or Spartan 3e Starter Kit available the building of the SPC
is very simple.

1. cd into the main project directory
2. make menuconfig (gcc, libncurses-dev required) or make config (gcc required)
3. select the evaluation board you posess
4. under General Tool Options, setup the correct paths for the xilinx tools. Please
   select the directory in which the directories for each version live, for example
   the directory where you can finde 14.1, 15.1, etc
5. select your xilinx version
6. select the xilinx license server, you can give a path to a license file too
7. select if you have the 32bit or 64bit xilinx tools installed
8. leave the configuration tool and save config data
9. call make all and wait
10.if everything has gone well, do a make program to program your board
11.the rs232 interface is running at 57600 baud and should print "Geraffel Processor"