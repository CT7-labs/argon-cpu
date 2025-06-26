# addition
.define reg1, s0
.define imm32, 0x1234CDEF

.section CODE
.main:
    add r1, r2, reg1
    addi r1, r1, 15
    jmp .test

.test:
    subi r1, r1, 15 + 1
    add r0, r0, r0