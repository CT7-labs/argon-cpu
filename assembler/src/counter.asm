.equ COUNT_TO, 5
.equ result, r1
.equ counter, r2

.init:
    addi result, r0, COUNT_TO
    jmp .loop

.loop:
    addi counter, counter, 1
    bne counter, result, .loop
    add r31, counter, r0
    sll r31, r31, 24