.section CODE
.main:
    jmp .test
    lui r1, 0xFFFF

.test:
    lui r1, 0xAAAA
    jal .main
    lui r1, 0xFFFF