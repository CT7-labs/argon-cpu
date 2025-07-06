.section CODE
.main:
    lui r2, 0x1234
    ori r2, r2, 0x5678
    sw r2, r0, 0x8
    