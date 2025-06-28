# Instruction Execution
We're not pipelining this CPU *yet*, so instead of going for all that complexity now, I'm going to lay the foundation for it.

Because of my lack of experience and want for simplicity, I've made some interesting architectural decisions:
1. Memory interface is strictly 32-bit read/write with 32-bit addressing
2. Assuming cache hit, instructions take 1 cycle to load (some crude prefetching on the WB step to make this happen)
3. Every instruction will cost 5 clock cycles

# R-type memory access instruction
1. Instruction Fetch
    - Latch instruction from memory
2. Instruction Decode
    - Setup control signals
3. Instruction Execute
    - Latch address into memory
4. Memory
    - Wait 1 cycle
    - Latch new instruction address into memory
5. Register Writeback
    - Latch memory output into register
    - Wait 1 cycle

# ALU usage
1. Instruction Fetch
    - Latch PC and 4 into ALU sources
2. Instruction Decode
    - Setup control signals
    - New PC is latched to ALU output
3. Instruction Execute
    - Latch new sources into ALU
    - Latch ALU output into PC
4. Memory
    - New ALU output is available
5. Register Writeback
    - Latch ALU output into destination register