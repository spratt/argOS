CROSS   = cross
PACKAGES= packages
ASM     = nasm
ASMFLAGS= -f elf64
CC      = $(CROSS)/bin/x86_64-elf-gcc
CFLAGS  = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -std=c11
LD      = $(CROSS)/bin/x86_64-elf-ld
LDPRE   = -ffreestanding -T link.ld
LDPOST  = -nostdlib -lgcc
XORRISO = $(CROSS)/bin/xorriso
GRUBMKR = $(CROSS)/bin/grub-mkrescue

.PHONY: clean all

all: kernel kernel.bin os.iso

kernel: kernel.o

os.iso: isofiles
	$(GRUBMKR) --xorriso=$(PWD)/$(XORRISO) -o $@ $<

kernel.bin: multiboot_header.o boot.o
	$(LD) -n -o $@ -T bootstrap.ld $^

clean:
	rm -f kernel.bin kernel multiboot_header os.iso *.o

# Make the implicit explicit
%.o : %.asm
	$(ASM) $(ASMFLAGS) $<

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

% : %.o
	$(CC) $(LDPRE) $^ -o $@ $(LDPOST)
