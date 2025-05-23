# Argon Architecture
- RISC ISA
- 32-bit data width
- 32-bit fixed-width instructions
- I-type, R-type, and J-type instructions (inspired by MIPS)
- 32-bit address space (4,294,967,296 bytes maximum memory)
- 64 opcodes

Argon will be implemented on an iCE40HX8K that has quite a few pins
broken out to pin headers and peripherals (PMOD, SD card in SPI mode, GPIO, etc.)
so I'm dedicating a few registers to I/O instead of writing a fancy MMU in Verilog.

# Instruction types
### I-type
6-bit opcode
5-bit rs
5-bit rd
16-bit immediate

### R-type
6-bit opcode
5-bit rs
5-bit rt
5-bit rd
5-bit shamt
6-bit funct

### J-types
6-bit opcode
26-bit offset (instructions, not bytes)

# Register file
### r0
Read-only zero

### r1-11
General purpose registers (caller)

### r12-22
General purpose registers (callee)

### r23-27
Special registers that should only be written to by the caller
- Global pointer
- Stack pointer
- Status register
- Interrupt status
- Return address

Note, for interrupt status, only the first 16 pins in PORTA are available for custom interrupts.
Another 8 bits are reserved for internal interrupts (UART master, Krypton graphics chip, etc.),
and the final 8 bits are control bits (global interrupt enable, etc.)

### r28-31
I/O registers (map to 64 pins with direction control)

PORTA
DDIRA
PORTB
DDIRB

*technically* it's "6" registers, but the programmmer sees 4 because the "read only" and "write only" registers are merged.
Reading from the PORTA register returns the value from the "read only" register, and writing to the PORTA register sets
the value in "write only" register.

# Opcodes
### ALU arithmetic
- ADD rd, rs, rt
- SUB rd, rs, rt
- ADDI rd, rs, imm16
- SUBI rd, rs, imm16

### ALU logical
- AND rd, rs, rt
- OR rd, rs, rt
- NOR rd, rs, rt
- XOR rd, rs, rt
- ANDI rd, rs, imm16
- ORI rd, rs, imm16
- NORI rd, rs, imm16
- XORI rd, rs, imm16

### ALU bitwise
- SETB rd, shamt
- CLRB rd, shamt
- READB rd, rs, shamt
- SETBR rd, rs, shamt

### ALU shifting
- SLL rd, rs, rs
- SLLI rd, rs, shamt
- SRL rd, rs, rs
- SRLI rd, rs, shamt
- SRA rd, rs, rs
- SRAI rd, rs, shamt

### Branching / jumping
- BEQ rs, rt, offset16
- BNE rs, rt, offset16
- SLT rd, rs, rt
- SLTU rd, rs, rt
- JMP offset26
- JAL rd, offset26
- JALR rd, rs
- JMPR rs

### Memory operations
- LUI rd, imm16
- LW rd, rs
- LH rd, rs
- LB rd, rs
- SW rs, rt
- SH rs, rt
- SB rs, rt