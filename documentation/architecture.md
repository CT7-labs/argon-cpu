# Argon Architecture Overview
- RISC ISA
- Big-Endian (it's slightly less of a headache)
- 32-bit data width
- 32-bit fixed-width instructions
- I-type, R-type, and J-type instructions (inspired by MIPS)
- 32-bit address space (4,294,967,296 bytes maximum memory)
- 64 opcodes

Argon will be implemented on an iCE40HX8K that has quite a few pins
broken out to pin headers and peripherals (PMOD, SD card in SPI mode, GPIO, etc.) so I'm dedicating a few registers to I/O instead of writing a fancy MMU in Verilog. The mmu will still have to handle writing to Krypton
and other things like the UART master and timer, but that's alright.

# Memory
Addressed with 32-bit words, but the CPU can request half-words or
bytes from the MMU too.

# Instruction types
### I-type
6-bit opcode
5-bit rd
5-bit rs
16-bit immediate

### R-type
6-bit opcode
5-bit rd
5-bit rs
5-bit rt
5-bit shamt
6-bit funct

### J-types
6-bit opcode
26-bit offset (instructions, not bytes)

# Register file
### r0 (zero)
Read-only zero

### r1-4 (a0-3)
Function arguments (caller)

### r5-6 (v0-1)
Return values (callee)

### r7-r14 (s0-7)
General purpose saved registers (caller)

### r15-22 (t0-7)
General purpose temporary registers (callee)

### r23-27
Special registers
- Global pointer (gp)
- Stack pointer (sp)
- Status register (st)
- Interrupt status (is)
- Return address (ra)

Status register:
- halt (0)
- error (1)
- reserved (3-31)

### r28-31
I/O registers (map to 64 pins with direction control)

porta
ddira
portb
ddirb

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

### ALU bit operations
- SETB rd, rs, rt
- CLRB rd, rs, rt
- SETBI rd, rs, shamt
- CLRBI rd, rs, shamt

### ALU shifting
- SLL rd, rs, shamt
- SRL rd, rs, shamt
- SRA rd, rs, shamt
- SLLV rd, rs, rs
- SRLV rd, rs, rs
- SRAV rd, rs, rs

### Branching / jumping
- BEQ rs, rt, imm16
- BNE rs, rt, imm16
- SLT rd, rs, rt
- SLTU rd, rs, rt
- JMP jtarg26
- JMPR rs
- JAL jtarg26
- JALR rd, rs

### Memory operations
- LUI rd, imm16
- LW rd, rs, imm16
- LH rd, rs, imm16  // Sign-extends
- LW rd, rs, imm16  // Sign-extends
- LHU rd, rs, imm16 // Zero-extends
- LBU rd, rs, imm16 // Zero-extends
- SW rs, rt, imm16
- SH rs, rt, imm16
- SB rs, rt, imm16