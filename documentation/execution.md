# Instruction Execution
We're not pipelining this CPU *yet*, so instead of going for all that complexity now, I'm going to lay the foundation for it.

Because of my lack of experience and want for simplicity, I've made some interesting architectural decisions:
1. Memory interface is strictly 16-bit read/write with 16-bit addressing
2. Instruction fetches take 2 cycles (because instructions are 32-bit)
3. Execution of instructions not involving memory cost 3 cycles (ID, EX, WB)
4. Execution of instructions involving memory cost 4+ cycles, where the MEM stage is a variable waiting time (ID, EX, MEM, WB)

# Instruction cycles (reg/reg)
### ID
- Set muxes to funnel data correctly to and from the ALU
- Set ALU operand

### EX
- Correct data is latched into ALU

### WB
- Correct data is latched from ALU into destination register (register file, program counter, memory pointer, etc.)

# Instruction cycles (branch)
### ID
- Set muxes to funnel data correctly to and from the ALU
- Set ALU operand
- Set Branch Manager operand
- Target address computed and ready to be latched

### EX
- Comparison data is latched into ALU
- 

### WB
- Program counter is offset