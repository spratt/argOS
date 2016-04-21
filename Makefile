CC      = cross/bin/x86_64-elf-gcc
CFLAGS  = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -std=c11
LD      = cross/bin/x86_64-elf-gcc
LDLIBS  =
LDPRE   = -ffreestanding -T link.ld
LDPOST  = -nostdlib -lgcc

.PHONY: clean

kernel: kernel.o

clean:
	rm -f kernel multiboot_header *.o

# Make the implicit explicit
%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

% : %.o
	$(LD) $(LDPRE) $^ -o $@ $(LDPOST)

#main: main.o
#	$(CC) $(CFLAGS) $^ -o $@

#main.o: main.c
#	$(CC) $(CFLAGS) -c $< -o $@ $(LDFLAGS) $(LDLIBS)
