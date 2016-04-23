argOS
=====

This is a really generic Operating System (argOS), which is intended
to be a playground in which to write operating system code.

The minimal build/run process is:

'''bash
$ ./setup.sh gcc xorriso grub
$ make
$ make qemu
'''

For detailed build instructions, see the BUILD.md file.

For license information, see the LICENSE file.

For contributor information, see the CONTRIBUTORS file.


WhereAmI
--------

* [X] Successfully cross-compile elf64 kernel
* [X] Setup 32-bit multiboot bootstrap
* [X] Fully automate build process
* [X] Separate src and bin
* [ ] Call custom code
* [ ] Switch to long mode
* [ ] ???
* [ ] Profit


Resources
---------

Phil Opp got me started:

* http://os.phil-opp.com/multiboot-kernel.html

I took a course with Prof Karsten, who wrote an experimental kernel
from which I stole some configuration:

* https://git.uwaterloo.ca/mkarsten/KOS

Of course, osdev.org provided so many resources:

* http://wiki.osdev.org/Creating_a_64-bit_kernel
* http://wiki.osdev.org/LLVM_Cross-Compiler
* http://wiki.osdev.org/GRUB_2

And I found a bunch of miscellaneous resources on the way:

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
