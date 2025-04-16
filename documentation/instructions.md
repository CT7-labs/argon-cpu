# Instructions
These are the instructions usable by the programmmer.

## Memory operations
- LB rs1, rs2 (8-bit)
- LBU rs1, rs2 (8-bit)
- LW rs1, rs2 (16-bit)
- SB rs1, rs2 (8-bit)
- SW rs1, rs2 (16-bit)

## ALU Operations
- ADD rd, rs1, rs2
- SUB rd, rs1, rs2
- AND rd, rs1, rs2
- OR  rd, rs1, rs2
- XOR rd, rs1, rs2

- ADDI rd, rs1, imm8
- SUBI rd, rs1, imm8
- ANDI rd, rs1, imm8
- ORI  rd, rs1, imm8
- XORI rd, rs1, imm8

*Note, these immediates can be treated as signed/unsigned*

- SLT rd, rs1, rs2
- SLTU rd, rs1, rs2
- SLL rd, rs1, rs2
- SRL rd, rs1, rs2
- SRA rd, rs1, rs2
- SEP rd, rs1

- SLTI rd, rs1, imm8
- SLTIU rd, rs1, imm8
- SLLI rd, rs1, imm8
- SRLI rd, rs1, imm8
- SRAI rd, rs1, imm8

*Note, these immediates are all unsigned*

## Branching
- BEQ rs1, rs2, imm12
- BNE rs1, rs2, imm12
- BGE rs1, rs2, imm12
- BGEU rs1, rs2, imm12
- BLT rs1, rs2, imm12
- BLTU rs1, rs2, imm12

## Unconditional Jumps
- JMP addr16
- JAL rd, addr16
- JALR rd, rs1, off16

addr16 -> 16-bit address
off16 -> signed 16-bit offset

# Pseudo-instructions & Macros
- NOT rd, rs1
- MOV rd, rs1
- CALL rd, subroutine
- RET rd, subroutine
