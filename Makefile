ASM     = nasm
ASMFLAGS= -f elf64
CC      = cross/bin/x86_64-elf-gcc
CFLAGS  = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -std=c11
LD      = cross/bin/x86_64-elf-ld
LDPRE   = -ffreestanding -T link.ld
LDPOST  = -nostdlib -lgcc

.PHONY: clean all

all: kernel kernel.bin

kernel: kernel.o

kernel.bin: multiboot_header.o boot.o
	$(LD) -n -o $@ -T bootstrap.ld $^

clean:
	rm -f kernel.bin kernel multiboot_header *.o

# Make the implicit explicit
%.o : %.asm
	$(ASM) $(ASMFLAGS) $<

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

% : %.o
	$(CC) $(LDPRE) $^ -o $@ $(LDPOST)
