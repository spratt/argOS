global start
;;; Resources:
;;; http://cs.lmu.edu/~ray/notes/nasmtutorial/
;;; http://nasmcodeasy.blogspot.ca/2014/04/
;;; https://en.wikibooks.org/wiki/X86_Assembly/Shift_and_Rotate
;;; https://en.wikipedia.org/wiki/VGA-compatible_text_mode#Text_buffer
;;; https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
;;; stackoverflow.com/questions/12063840/

section .text
bits 32
start:
    mov eax, 0xdead3210
    call error
    hlt

;;; error: print an error code, then halt!
;;; input:
;;;     eax: error code
error:
    mov dword [0xb8000], 0x4f524f45 ; RE
    mov dword [0xb8004], 0x4f3a4f52 ; :R
    mov dword [0xb8008], 0x4f204f20 ;
    mov ch, 0x4f
    mov ebx, 0xa
    call print_dword
    hlt

;;; print_qword: prints 8 bytes of hex as ascii
;;; input:
;;;     eax:     bytes to print
;;;     ebx:    offset at which to print
;;;     ch:     vga color
;;; stomps:
;;;     edx
print_qword:
;;; Only compiles in 64-bit
    ;; mov rdx, rax
    ;; shr rdx, 0x38
    ;; call print_byte
    ;; mov rdx, rax
    ;; shr rdx, 0x30
    ;; call print_byte
    ;; mov rdx, rax
    ;; shr rdx, 0x28
    ;; call print_byte
    ;; mov rdx, rax
    ;; shr rdx, 0x20
    ;; call print_byte
    ;; call print_dword
    ret    

;;; print_dword: prints 4 bytes of hex as ascii
;;; input:
;;;     eax:     bytes to print
;;;     ebx:    offset at which to print
;;;     ch:     vga color
;;; stomps:
;;;     edx
print_dword:
    mov edx, eax
    shr edx, 0x18
    call print_byte
    mov edx, eax
    shr edx, 0x10
    call print_byte
    call print_word
    ret    
    
;;; print_word: prints 2 bytes of hex as ascii
;;; input:
;;;     ax:     bytes to print
;;;     ebx:    offset at which to print
;;;     ch:     vga color
;;; stomps:
;;;     edx
print_word:
    mov dh, ah
    shr dx, 8
    call print_byte
    mov dl, al
    call print_byte
    ret
    
;;; print_byte: prints a single byte of hex as ascii
;;; input:
;;;     dl:     byte to print
;;;     ebx:    offset at which to print
;;;     ch:     vga color
print_byte:
    ror dl, 4
    call hex_to_ascii
    call put_char
    add ebx, 2
    ror dl, 4
    call hex_to_ascii
    call put_char
    add ebx, 2
    ret
    
;;; vga_test: prints all the colors of the vga palette
;;; stomps:
;;;     eax
;;;     ebx
;;;     ecx
;;;     edx
vga_test:
    mov eax, 0
    mov ebx, 0
.loop:
;;; Print first nibble
    mov dl, al
    shr dl, 4
    call hex_to_ascii
    mov ch, al
    call put_char
;;; Print second nibble
    add ebx, 2
    mov dl, al
    call hex_to_ascii
    mov ch, al
    call put_char
;;; finally, increment and loop
    add ebx, 2
    inc al
    cmp al, 0x80
    jne .loop
    ret

;;; hex_to_ascii: convert a nibble from hex to ascii
;;;     e.g.,   0x0 -> 0x30, 0x1 -> 0x31, ...
;;;             0xa -> 0x61, 0xb -> 0x62, ...
;;; input:
;;;     dl (the lower nibble)
;;;
;;; output:
;;;     cl
hex_to_ascii:
    mov cl, dl
    and cl, 0xf                 ; get rid of the upper nibble
    cmp cl, 0x9
    jbe .small
    add cl, 0x27
.small:
    add cl, 0x30
    ret

;;; put_char: put a single character on the screen
;;; input:
;;;     ch:     vga color
;;;     cl:     ascii character
;;;     ebx:    offset from the top left
;;; 
;;; The screen output buffer is located at memory address 0xb8000
;;; Each word is a (color,character) pair, where:
;;;         color:      1 byte (2 hex digits) vga color (see next note)
;;;         character:  1 byte ascii character
;;; 
;;; e.g.,   0030 is:
;;;         00: color
;;;         30: ascii 0
;;;     So this prints 0 colored according to the following palette:
;;;
;;; Background & foreground:
;;;         0: black
;;;         1: blue
;;;         2: green
;;;         3: cyan
;;;         4: red
;;;         5: magenta
;;;         6: brown
;;;         7: gray
;;; Foreground only, since background uses 1000 bit to flash:
;;;         8: dark gray
;;;         9: bright blue
;;;         a: bright green
;;;         b: bright cyan
;;;         c: bright red
;;;         d: bright magenta
;;;         e: yellow
;;;         f: white
put_char:
    mov word [0xb8000 + ebx], cx
    ret
