.section CODE
.main:
    beq r0, r0, .test
    lui r1, 0xFFFF

.test:
    lui r1, 0xAAAA