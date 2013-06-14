src	:= boot1.asm
out	:= boot1.bin

fsdir	:= ../../fs

.SILENT:
all: $(out)

boot1.bin: boot1.asm
	fasm boot1.asm $(fsdir)/boot/boot1.bin

.PHONY: clean
clean:
	rm -f *~ *.bin
