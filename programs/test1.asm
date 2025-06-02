# addition
.define SOME_REGISTER s2
.define RANDOM 5

.macro li reg1, imm32
    lui reg1, (imm32 >> 16)
    ori reg1, (imm32 & 0xFFFF)
.endmacro

.section .text
main:
    li s1, (RANDOM + 5)