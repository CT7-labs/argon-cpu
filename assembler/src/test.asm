.equ TEST, 0x10

.init:
    ori r1, r0, TEST
    ori r2, r0, 128
    add r3, r1, r2
    jmp .shifter

.skipthis
    add r3, r0, r0

.shifter:
    sll r3, r3, TEST