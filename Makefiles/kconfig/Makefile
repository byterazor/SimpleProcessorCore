lxdialog := lxdialog/checklist.o lxdialog/util.o lxdialog/inputbox.o
lxdialog += lxdialog/textbox.o lxdialog/yesno.o lxdialog/menubox.o

conf-objs       := conf.o  zconf.tab.o
mconf-objs     := mconf.o zconf.tab.o $(lxdialog)
nconf-objs     := nconf.o zconf.tab.o nconf.gui.o
kxgettext-objs  := kxgettext.o zconf.tab.o
qconf-cxxobjs   := qconf.o
qconf-objs      := zconf.tab.o
gconf-objs      := gconf.o zconf.tab.o

clean-files     := qconf.moc .tmp_qtcheck .tmp_gtkcheck
clean-files     += zconf.tab.c zconf.lex.c zconf.hash.c gconf.glade.h
clean-files     += mconf qconf gconf nconf
clean-files     += config.pot linux.pot


HOSTCC	:= gcc

.PHONY: clean

clean:
	-rm -r *.o
	-rm conf mconf nconf qconf gconf

mconf:	$(mconf-objs)
	$(HOSTCC) $? -o $@ -lncurses

conf:	$(conf-objs)
	$(HOSTCC) $? -o $@

%.o:	%.c
	$(HOSTCC) -c $? -o $@
