######################################################################
# Configuration
arch      ?= x86_64
build     ?= build
src       ?= src
kernel    := $(build)/isofiles/boot/kernel-$(arch).bin
iso       := $(build)/os-$(arch).iso

ld_script := $(src)/arch/$(arch)/bootstrap.ld
grub_cfg  := $(src)/arch/$(arch)/grub.cfg
asm_src   := $(wildcard $(src)/arch/$(arch)/*.asm)
asm_obj   := $(patsubst $(src)/arch/$(arch)/%.asm, \
	build/arch/$(arch)/%.o, $(asm_src))

CROSS    = cross
ASM      = nasm
ASMFLAGS = -f elf64
CC       = $(CROSS)/bin/x86_64-elf-gcc
CFLAGS   = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -std=c11
LD       = $(CROSS)/bin/x86_64-elf-ld
LDPRE    = -ffreestanding -T link.ld
LDPOST   = -nostdlib -lgcc
XORRISO  = $(CROSS)/bin/xorriso
GRUBMKR  = $(CROSS)/bin/grub-mkrescue
QEMU	 = qemu-system-x86_64

######################################################################
# Edit past here at your own risk!
.PHONY: clean all qemu

all: $(kernel) $(iso)

qemu: $(iso)
	$(QEMU) $(QEMUFLAGS) -cdrom $(iso)

clean:
	@rm -r $(build)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p $(build)/isofiles/boot/grub
	cp $(grub_cfg) $(build)/isofiles/boot/grub/
	$(GRUBMKR) --xorriso=$(PWD)/$(XORRISO) -o $@ $(build)/isofiles

$(kernel): $(asm_obj)
	@mkdir -p $(build)/isofiles/boot
	$(LD) -n -o $@ -T $(ld_script) $^

# Make the implicit explicit
$(build)/arch/$(arch)/%.o : $(src)/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	$(ASM) $(ASMFLAGS) $< -o $@

$(build)/arch/$(arch)/%.o : $(src)/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	$(CC) -c $(CFLAGS) $(CFLAGS) $< -o $@

% : %.o
	$(CC) $(LDPRE) $^ -o $@ $(LDPOST)
