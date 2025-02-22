.section __TEXT,__text,regular,pure_instructions
.globl _bootstrap_entry
.align 4

_bootstrap_entry:
    # Save registers and create stack frame
    stp     x29, x30, [sp, #-16]!    @ Save frame pointer and link register
    mov     x29, sp                  @ Set up frame pointer
    sub     sp, sp, #80             @ Allocate stack space for locals and saved registers
    stp     x19, x20, [sp, #32]     @ Save callee-saved registers
    stp     x21, x22, [sp, #16]
    stp     x23, x24, [sp, #0]

    # Load library path and attempt to load library
    adrp    x19, library_path@PAGE  @ Load library path address
    add     x19, x19, library_path@PAGEOFF
    mov     x0, x19                 @ First argument: library path
    mov     x1, #6                  @ RTLD_NOW | RTLD_GLOBAL flags for maximum compatibility
    bl      _dlopen                 @ Call dlopen
    mov     x20, x0                 @ Save handle

    # Check for dlopen error
    cbz     x20, 1f                 @ If handle is null, jump to error handling

    # Library loaded successfully, restore and return
    mov     x0, x20                 @ Return handle in x0
    b       2f                      @ Jump to cleanup

1:  # Error handling
    bl      _dlerror                @ Get error string
    mov     x0, #0                  @ Return null to indicate error

2:  # Cleanup and return
    ldp     x23, x24, [sp, #0]
    ldp     x21, x22, [sp, #16]
    ldp     x19, x20, [sp, #32]
    mov     sp, x29                 @ Restore stack pointer
    ldp     x29, x30, [sp], #16    @ Restore frame pointer and link register
    ret                            @ Return

.section __TEXT,__cstring,cstring_literals
library_path:
    .asciz  "/path/to/injected/library.dylib"

.section __DATA,__data
.align 3
library_handle:                    @ Cache for library handle
    .quad   0                      @ Initialize to null