.section CODE
.main:
    addi r8, r0, 42
    add r9, r8, r8
    andi r10, r9, 0x0F
    or r9, r8, r10
    sub r10, r9, r10