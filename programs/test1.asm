.section CODE
.main:
    lui r1, 0xAAAA
    jmp .test
    ori r1, r1, 0x1234

.test:
    lui r1, 0xFFFF
    ori r1, r1, 0xFFFF