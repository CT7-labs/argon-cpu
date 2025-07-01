# addition
.define reg1, s0
.define imm32, 0x1234CDEF

.section CODE
.main:
    ori r1, zero, 0xFF
    ori r2, zero, 0xFFFF
    sll r2, r2, 16
    add r3, r1, r2
    lui r31, 0xAAAA
