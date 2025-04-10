# Argon v0.6 Specs
- 16-bit data width
- 16-bit address width
- 16 registers (1x zero register, 15x GP registers)
- 32-bit fixed-size instructions

# Instruction Types
## Register/Register
- 6-bit opcode
- 4-bit rs1 select
- 4-bit rs2 select
- 4-bit rd select
- 6-bit function
- 8-bit immediate

opcode[5:0]
rd[9:6]
rs1[13:10]
rs2[17:14]
funct6[23:18]
imm8[31:24]

The 8-bit immediate is odd, but I think it's better than adding a new instruction type

## Jump
- 6-bit opcode
- 4-bit rd select
- 22-bit relative jump (-2M instructions to + 2M instructions, so it actually covers the entire 24-bit address space)

opcode[5:0]
rd[9:6]
imm22[31:10]

## Branch
- 6-bit opcode
- 4-bit rs1 select
- 4-bit rs2 select
- 6-bit function
- 12-bit offset (-2048 to +2047 instructions)

opcode[5:0]
imm12-3:0[9:6]
rs1[13:10]
rs2[17:14]
funct6[23:18]
imm12-11:4[31:24]

## Store
- 6-bit opcode
- 4-bit rs1 select
- 4-bit rs2 select
- 6-bit function
- 12-bit immediate offset (-2048 to +2047 bytes)

opcode[5:0]
offset-3:0[9:6]
rs1[13:10]
rs2[17:14]
funct6[23:18]
offset-11:4[31:24]

## Immediate
- 6-bit opcode
- 4-bit rd select
- 4-bit rs select
- 16-bit immediate
- 2 reserved bits

opcode[5:0]
rd[9:6]
rs1[13:10]
2 reserved bits
imm16[31:16]

funct6[23:18]
offset-11:4[31:24]
