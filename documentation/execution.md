# Instruction Execution
We're not pipelining this CPU *yet*, so instead of going for all that complexity now, I'm going to lay the foundation for it.

Because of my lack of experience and want for simplicity, I've made some interesting architectural decisions:
1. Memory interface is strictly 32-bit read/write with 32-bit addressing
2. Assuming cache hit, instructions take 1 cycle to load (some crude prefetching on the WB step to make this happen)
3. Execution of instructions not involving memory cost 4 cycles (IF, ID, EX, WB)
4. Execution of instructions involving memory cost 5 cycles (IF, ID, EX, MEM, WB)