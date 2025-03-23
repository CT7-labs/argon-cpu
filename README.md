# Argon v1.6
RISC-like CPU written in SystemVerilog, part of the Oganesson SoC I'm developing to improve my Verilog and RTL design skills

Argon will be implemented on an iCE40HX8K, and because of Krypton (graphics unit), Argon only has 4kB of BRAM and a budget of
~3K LUTs/FFs to work with.

This means I can go pretty crazy with the register file, caches, HyperRAM controller, and more.

This is a learning CPU after all. I can practice optimizing for size or simplicity later.

~1K LUTs/FFs are reserved for a UART controller, where the Oganesson board can be connected to a device and interacted with via
a USB cable.

That's neither here nor there though...

### Argon Overview
- 16-bit data width
- 24-bit addressable space with banking (1 byte at each memory location)
- 32-bit instruction width
- 4kB system cache (I/D) with 64B I-cache
- 16x registers
- Dedicated I/O instructions because why not
- 5-stage instruction execution (Classic RISC pipeline) without pipelining (v2 perhaps?)
- Hardware stack