.section CODE
.main:
    ADDI r8, r0, 42
    ADD r9, r8, r8
    ANDI r10, r9, 0x0F
    OR r9, r8, r10
    SUB r10, r9, r10