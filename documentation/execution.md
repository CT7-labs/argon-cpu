# Instruction Execution
Because we're not pipelining, Argon isn't limited to the classic RISC pipeline, though I will draw inspiration from it.

Here is the palette of execution steps:
- Instruction Fetch 1 (IF1)
- Instruction Fetch 2 (IF2)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access 1 (MEM1)
- Memory Access 2 (MEM2)
- Register Writeback (WB)

Accessing the system cache is a 2 step process:
1. Tell the cache the address you want
2. Wait for valid data, then write into proper register

At the fastest, this could be a 2-cycle proces.

Yes, this could be done in a single-cycle process by giving the correct address to the system cache sooner,
not unlike prefetching, but I'd like to keep things simple. I can make this optimization later

# Register/register
### IF1
Tell cache what address to read

### IF2
Read from cache into instruction register

### ID
Set control registers:
- `rs1`, `rs2`, `rd`
- ALU opcode

### EX
ALU computes result and sets output

### WB
ALU result is written to `rd`