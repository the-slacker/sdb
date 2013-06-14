src 	:= $(wildcard *.c)
obj 	:= sdb.o
bin	:= sdb

libs 	:= -lncurses
opts	:=

bindir	:= ..

all: $(src)
	gcc $(opts) -o $(bindir)/$(bin) $(src) $(libs)

.SILENT: clean
.PHONY: clean
clean:
	rm -f *~
	rm -f ../sdb
