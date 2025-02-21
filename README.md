# Argon v1.5
16-bit hardwired CPU implemented in Verilog with Yosys-compatible SystemVerilog

## Features
- Hardware user stack/call stack
- 8x registers (with zero registers)
- Up to 32 instructions (5-bit opcode)
- PC is not directly program-accessible
- 16-bit address space (Theoretically 24-bit with memory banking)
- Strictly unsigned operations

Extensions like signed operations are planned to come in Argon v2.

## Register file

### R0
Hardwired zero register

### R1
General-purpose register

### R2
General-purpose register

### R3
General-purpose register

### R4
General-purpose register

### MB / SP
Upper 8 bits serve as the memory bank
Lower 8 bits serve as read-only stack pointer

### C (R6)
Config/control register

Interrupt control
PLL control, like a divider?

### F (R7)
ALU flags register

7 -> Error
5 -> Borrow
4 -> Less
3 -> Greater
2 -> Equal
1 -> Zero
0 -> Carry

# ISA
RS1 -> register source 1
RS1 -> register source 2
RD  -> register destination
F   -> flags register
MP  -> memory pointer
SP  -> stack pointer
CSP -> call stack pointer

## Instruction format
Instructions are 32-bit words, containing a 6-bit opcode, 3x 3-bit register indices (source 1, source 2, destination), a RFU bit, and a 16-bit immediate value
OOOOOORR-RSSSDDDF-IIIIIIII-IIIIIIII

O -> opcode bit
R -> RS1 bit
S -> RS2 bit
F -> RFU (reserved for future use) bit
I -> immediate bit

## ALU operations
*instruction updates flags register

### ADD* RS1, RS2, RD
RD = RS1 + RS2

### ADC* RS1, RS2, RD
RD = RS1 + RS2 + CF

### SBB* RS1, RS2, RD
RD = RS1 - RS2 - BF

### CMP* RS1, RS2, RD
RD = 0
F = RS1 CMP RS2

### INC RS1, RS2, RD
RD = RS1 + 1

### DEC RS1, RS2, RD
RD = RS1 - 1

### NAND RS1, RS2, RD
RD = ~(RS1 & RS2)

### AND RS1, RS2, RD
RD = RS1 & RS2

### OR RS1, RS2, RD
RD = RS1 | RS2

### NOR RS1, RS2, RD
RD = ~(RS1 | RS2)

### XOR RS1, RS2, RD
RD = RS1 ^ RS2

### LSH RS1, RS2, RD
RD = RS1 << RS2

### RSH RS1, RS2, RD
RD = RS1 >> RS2

## Memory operations
### LW RS1, RD
MP = RS1
RD = memory[address]

### SW RS1, RS2
MP = RS1
memory[address] = RS2

### PUSH RS1
stack[SP] = RS1
SP -= 1

### POP RD
RD = stack[SP+1]
SP += 1

## Flow control
### CALL RS1
callstack[CSP] = PC
PC = RS1
CSP -= 1

### RET
PC = callstack[CSP+1]
CSP += 1

### BEQ RS1
if EF: PC = RS1

### BNQ RS1
if ~EF: PC = RS1

### BC RS1
if CF: PC = RS1

### BNC RS1
if ~EF: PC = RS1

### BZ RS1
if ZF: PC = RS1

### BNZ RS1
if ~ZF: PC = RS1

### BGT RS1
if GF: PC = RS1

### BLT RS1
if ~LF: PC = RS1