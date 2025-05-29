# addition
.define SOME_REGISTER s2

.macro li reg1, imm32
    lui reg1, imm32 # (imm32 >> 16)
    ori reg1, imm32 # (imm32 & 16)
.endmacro

li s1, 5
li SOME_REGISTER, 7
li s3, 9
add s0, s1, s2 # 12 = 5 + 7
sub s0, s0, s3 # 3 = 12 - 9
