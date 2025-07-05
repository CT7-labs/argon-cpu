# Reserved
### 0x00
    Default value for the instruction register on bootup. Argon simply fetches the first real instruction from memory then carries on with execution

# R-type
### 0x01
    This contains every R-type instruction thanks to the funct6 field in the instruction

    *treats `rs` and `rt` as signed values
    `pc` is the program counter

| funct6 | Mnemonic | Operation             |
|-------|-----------------|-----------------------|
| 0     | `add`             | `rd` = `rs` + `rt`          |
| 1     | `sub`             | `rd` = `rs` - `rt`          |
| 2     | `and`             | `rd` = `rs` & `rt`          |
| 3     | `or`              | `rd` = `rs` \| `rt`         |
| 4     | `nor`             | `rd` = ~(`rs` \| `rt`)      |
| 5     | `xor`             | `rd` = `rs` ^ `rt`          |
| 6     | `setb`            | `rd`[`shamt`] = 1              |
| 7     | `clrb`            | `rd`[`shamt`] = 0              |
| 8    | `sll`             | `rd` = `rt` << `shamt`      |
| 9    | `srl`             | `rd` = `rt` >> `shamt`      |
| 10    | `sra`             | `rd` = `rt` >>> `shamt`      |
| 11    | `sllv`            | `rd` = `rt` << `rs`         |
| 12    | `srlv`            | `rd` = `rt` >> `rs`         |
| 13    | `srav`            | `rd` = `rt` >>> `rs`         |
| 14    | `slt`*            | `rd` = (`rs` < `rt`) ? 1 : 0 |
| 15    | `sltu`            | `rd` = (`rs` < `rt`) ? 1 : 0 |
| 16    | `jmpr`            | `pc` = `rs` |
| 17    | `jalr`            | `rd` = `pc+4` then `pc` = `rs` |

# I-type
    Because the I-type instructions don't have space for a funct6 field, each instruction takes up a regular opcode.
    *treats imm16 as a signed immediate

| Opcode | Mnemonic | Operation             |
|-------|-----------------|-----------------------|
| 2     | `addi`            | `rd` = `rs` + `imm16`         |
| 3     | `subi`            | `rd` = `rs` - `imm16`         |
| 4     | `andi`            | `rd` = `rs` & `imm16`         |
| 5     | `ori`             | `rd` = `rs` \| `imm16`        |
| 6     | `nori`            | `rd` = ~(`rs` \| `imm16`)     |
| 7     | `xori`            | `rd` = `rs` ^ `imm16`         |
| 8     | `beq`*            | if `rs` == `rt`: `pc` += `imm16` |
| 9     | `bne`*            | if `rs` != `rt`: `pc` += `imm16` |
| 10    | `lui`             | `rd[31:16]` = `imm16` |
| 11    | `lw`*             | `rd` = `mem[rs+imm16]` |
| 12    | `lh`*             | `rd[15:0]` = `mem[rs+imm16]` |
| 13    | `lb`*             | `rd[7:0]` = `mem[rs+imm16]` |
| 14    | `sw`*             | `mem[rs+imm16]` = `rt` |
| 15    | `sh`*             | `mem[rs+imm16]` = `rt` |
| 16    | `sb`*             | `mem[rs+imm16]` = `rt` |

# J-type
    There's only 2 J-type instructions that Argon can execute.

    The 32-bit address is computed by left shifting `jtarg26` twice, then using the same upper 4 bits as the current PC value.

Note that `ra` is the return address register
| Opcode | Mnemonic | Operation |
|--------|----------|-----------|
| 17     | `jmp`    | `pc` = `{pc[31:28], jtarg26}` |
| 18     | `jal`    | `ra` = `pc+4` then `pc` = `{pc[31:28], jtarg26}` |