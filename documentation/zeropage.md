# Zero page
The first 64 bytes in the 64K window are dedicated to memory-mapped registers

Such registers will include:
- Clock divider (2 registers)
- CPU state / flags (1 register)
- Interrupt control (1 register)
- GPIO (28 I/O pins * 2 + control = 4 registers)*
- PMod (2 registers)
- PS/2 controller (2 registers)
- UART controller (data 0-7 + control = 9 registers)
- Memory bank (1 register, controls upper 16 bits of the hardware address)**
- Timer (3 registers)
- RNG (1 register)
- 6 registers (12 bytes) left for other things

*LED pins can fit in I/O
**the external HyperRAM contains 16MB, or 2^24 bytes, but future proofing is nice