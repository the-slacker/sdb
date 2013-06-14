bootdir		:= boot

.SILENT:	boot clean
.PHONY: 	all boot clean
all: boot

boot:
	make -C $(bootdir)/

clean:
	rm -f *~
	make -C $(bootdir)/ clean
