argOS
=====

This is a really generic Operating System (argOS), which is intended
to be a playground in which to write operating system code.

For build instructions, see the BUILD.md file.

For license information, see the LICENSE file.

For contributor information, see the CONTRIBUTORS file.

WhereAmI
--------

* [X] Successfully cross-compile elf64 kernel
* [ ] Setup 32-bit multiboot bootstrap
* [ ] ???
* [ ] Profit

Resources
---------

* https://git.uwaterloo.ca/mkarsten/KOS
* http://os.phil-opp.com/multiboot-kernel.html
* http://wiki.osdev.org/Creating_a_64-bit_kernel
* http://wiki.osdev.org/LLVM_Cross-Compiler
* https://www.linux.com/blog/cross-compiling-arm
* http://clang.llvm.org/docs/CrossCompilation.html
* https://falstaff.agner.ch/2015/03/03/cross-compile-linux-for-arm-using-llvmclang-on-arch-linux/


Attribution
-----------

Some of this code comes from existing sources, this is limited to:

from http://wiki.osdev.org/Creating_a_64-bit_kernel#link.ld
* link.ld

from http://os.phil-opp.com/multiboot-kernel.html
* bootstrap.ld
* multiboot_header.asm
* boot.asm

from https://git.uwaterloo.ca/mkarsten/KOS
* some of setup.sh
